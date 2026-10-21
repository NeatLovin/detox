-- Detox — weekly leaderboard, feed reactions, crash reports.

-- ---------------------------------------------------------------------------
-- 1. Weekly leaderboard
-- ---------------------------------------------------------------------------
-- The week starts on Monday 00:00 Europe/Zurich. Same shape as leaderboard(),
-- xp = XP won since the start of the week, so the client reuses its model.

create or replace function private.zurich_week_start(p_at timestamptz default now())
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select date_trunc('week', p_at at time zone 'Europe/Zurich') at time zone 'Europe/Zurich';
$$;

-- XP won by each player in [p_from, p_to).
create or replace function private.xp_between(p_from timestamptz, p_to timestamptz)
returns table (user_id uuid, xp bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select l.user_id, sum(l.amount_xp)::bigint
  from public.xp_ledger l
  where l.created_at >= p_from and l.created_at < p_to
  group by l.user_id;
$$;

create function public.leaderboard_week()
returns table (
  rank bigint,
  user_id uuid,
  username text,
  avatar_emoji text,
  level int,
  xp bigint,
  is_private boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  with gains as (
    select * from private.xp_between(private.zurich_week_start(), 'infinity'::timestamptz)
  )
  select
    rank() over (order by coalesce(g.xp, 0) desc),
    p.id,
    p.username,
    p.avatar_emoji,
    coalesce(s.level, 1),
    coalesce(g.xp, 0),
    p.is_private
  from public.profiles p
  left join public.player_stats s on s.user_id = p.id
  left join gains g on g.user_id = p.id
  where auth.uid() is not null
  order by coalesce(g.xp, 0) desc, p.username;
$$;

-- Winners of each finished week, announced once (ties share the title).
create table private.week_winners (
  week_start timestamptz primary key,
  user_ids uuid[] not null default '{}',
  xp bigint not null default 0,
  announced_at timestamptz not null default now()
);

alter table public.feed_events drop constraint feed_events_type_check;
alter table public.feed_events add constraint feed_events_type_check check (type in (
  'joined', 'milestone', 'level_up', 'relapse',
  'pledge', 'badge', 'sos', 'sos_support', 'sos_resolved', 'quests_all_done',
  'week_winner'
));

-- Announces the winner(s) of the previous week in the feed and by push.
-- Runs hourly; does nothing once the previous week has been handled.
create or replace function private.announce_week_winner()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_end timestamptz := private.zurich_week_start();
  v_start timestamptz := private.zurich_week_start(v_end - interval '1 day');
  v_xp bigint;
  v_winners uuid[];
  v_user uuid;
begin
  if exists (select 1 from private.week_winners where week_start = v_start) then
    return;
  end if;

  select max(x.xp) into v_xp
  from private.xp_between(v_start, v_end) x
  join public.profiles p on p.id = x.user_id;

  if coalesce(v_xp, 0) <= 0 then
    insert into private.week_winners (week_start) values (v_start);
    return;
  end if;

  select array_agg(x.user_id order by x.user_id) into v_winners
  from private.xp_between(v_start, v_end) x
  join public.profiles p on p.id = x.user_id
  where x.xp = v_xp;

  insert into private.week_winners (week_start, user_ids, xp)
  values (v_start, v_winners, v_xp);

  foreach v_user in array v_winners loop
    perform private.push_feed(v_user, 'week_winner', jsonb_build_object(
      'xp', v_xp,
      'tie', cardinality(v_winners) > 1
    ));
  end loop;

  perform private.notify(
    'week_winner',
    array(select p.id from public.profiles p where p.id = any (v_winners) and p.notify_reminders),
    '🏆 Tu as gagné la semaine !',
    format('%s XP en 7 jours : personne n’a fait mieux. Nouvelle semaine, nouveau classement.', v_xp),
    jsonb_build_object('route', '/community')
  );
end;
$$;

do $$
begin
  if exists (select 1 from pg_namespace where nspname = 'cron') then
    perform cron.schedule('week-winner', '10 * * * *', 'select private.announce_week_winner()');
  else
    raise notice 'pg_cron not available, week winner not scheduled';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. Feed reactions
-- ---------------------------------------------------------------------------
-- One reaction per player and event (tapping the same emoji again removes
-- it); relapses and SOS only take 💪 and ❤️. Written only through react_feed(). Visible with the event; a private
-- player's reactions stay hidden from others, like the rest of their feed.

create table public.feed_reactions (
  event_id uuid not null references public.feed_events (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  -- @rules:feed_reactions:begin
  emoji text not null check (emoji in ('👏', '🔥', '💪', '❤️', '😂')),
  -- @rules:feed_reactions:end
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);
create index feed_reactions_user_idx on public.feed_reactions (user_id);

alter table public.feed_reactions enable row level security;
create policy feed_reactions_select on public.feed_reactions
  for select to authenticated
  using (
    (user_id = (select auth.uid()) or public.is_public_player(user_id))
    and exists (select 1 from public.feed_events e where e.id = event_id)
  );

revoke all on public.feed_reactions from anon, authenticated;
grant select on public.feed_reactions to authenticated;

-- Returns the player's reaction after the call (null when removed).
create function public.react_feed(p_event_id uuid, p_emoji text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
  v_type text;
  v_current text;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;
  if p_emoji is null or p_emoji not in ('👏', '🔥', '💪', '❤️', '😂') then
    raise exception 'invalid_reaction' using errcode = 'P0001';
  end if;

  select e.user_id, e.type into v_owner, v_type from public.feed_events e where e.id = p_event_id;
  if not found or v_owner is null
     or (v_owner <> v_uid and not public.is_public_player(v_owner)) then
    raise exception 'event_not_found' using errcode = 'P0001';
  end if;
  if v_owner = v_uid then
    raise exception 'own_event' using errcode = 'P0001';
  end if;
  -- A relapse or an SOS only gets support, never a laugh.
  if v_type in ('relapse', 'sos') and p_emoji not in ('💪', '❤️') then
    raise exception 'invalid_reaction' using errcode = 'P0001';
  end if;

  select r.emoji into v_current
  from public.feed_reactions r
  where r.event_id = p_event_id and r.user_id = v_uid;

  if v_current = p_emoji then
    delete from public.feed_reactions where event_id = p_event_id and user_id = v_uid;
    return null;
  end if;

  insert into public.feed_reactions (event_id, user_id, emoji)
  values (p_event_id, v_uid, p_emoji)
  on conflict (event_id, user_id) do update
    set emoji = excluded.emoji, created_at = now();
  return p_emoji;
end;
$$;

revoke all on function public.react_feed(uuid, text) from public, anon;
grant execute on function public.react_feed(uuid, text) to authenticated;
revoke all on function public.leaderboard_week() from public, anon;
grant execute on function public.leaderboard_week() to authenticated;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.feed_reactions;
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Crash reports
-- ---------------------------------------------------------------------------
-- Uncaught app errors, grouped by fingerprint per player. Readable only by
-- the owner (database workflow, mode errors-log); kept 30 days.

create table private.client_errors (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  fingerprint text not null,
  build int not null default 0,
  platform text,
  message text not null,
  stack text,
  context text,
  count int not null default 1,
  first_seen timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  unique (user_id, fingerprint)
);
create index client_errors_last_seen_idx on private.client_errors (last_seen desc);

-- At most 30 new error kinds per player and day; repeats only bump the count.
create function public.report_error(
  p_message text,
  p_stack text default null,
  p_context text default null,
  p_build int default 0,
  p_platform text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_message text := left(coalesce(nullif(btrim(p_message), ''), '?'), 1000);
  v_stack text := left(p_stack, 4000);
  v_fingerprint text;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;

  v_fingerprint := md5(left(v_message, 200) || '|' || coalesce(left(v_stack, 600), ''));

  update private.client_errors
  set count = count + 1,
      last_seen = now(),
      build = greatest(build, coalesce(p_build, 0))
  where user_id = v_uid and fingerprint = v_fingerprint;
  if found then
    return;
  end if;

  if (select count(*) from private.client_errors
      where user_id = v_uid and first_seen >= private.zurich_day_start()) >= 30 then
    return;
  end if;

  insert into private.client_errors (user_id, fingerprint, build, platform, message, stack, context)
  values (
    v_uid,
    v_fingerprint,
    coalesce(p_build, 0),
    left(p_platform, 100),
    v_message,
    v_stack,
    left(p_context, 300)
  );
end;
$$;

revoke all on function public.report_error(text, text, text, int, text) from public, anon;
grant execute on function public.report_error(text, text, text, int, text) to authenticated;

create function private.purge_client_errors()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from private.client_errors where last_seen < now() - interval '30 days';
$$;

do $$
begin
  if exists (select 1 from pg_namespace where nspname = 'cron') then
    perform cron.schedule('purge-client-errors', '40 3 * * *', 'select private.purge_client_errors()');
  else
    raise notice 'pg_cron not available, client errors purge not scheduled';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. Account deletion also forgets the weekly titles
-- ---------------------------------------------------------------------------
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;

  delete from public.feed_events
  where user_id = v_uid
     or payload ->> 'to_user_id' = v_uid::text;

  update private.week_winners
  set user_ids = array_remove(user_ids, v_uid)
  where v_uid = any (user_ids);

  delete from auth.users where id = v_uid;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
