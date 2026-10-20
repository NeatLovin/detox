-- Detox — push notifications (Firebase Cloud Messaging).
--
-- The database decides WHO gets notified and WHAT the text is; the `push`
-- Edge Function only delivers (it reads the device tokens with the service
-- role and calls FCM). Calls go through pg_net with a shared secret stored in
-- private.push_config by the CI. Every notification is also written to
-- private.push_log, which is what the SQL tests check.

do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_net') then
    create extension if not exists pg_net;
  else
    raise notice 'pg_net not available, notifications are only logged';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- Preferences and device tokens
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column notify_sos boolean not null default true,
  add column notify_reminders boolean not null default true;

grant insert (notify_sos, notify_reminders) on public.profiles to authenticated;
grant update (notify_sos, notify_reminders) on public.profiles to authenticated;

create table public.push_tokens (
  token text primary key check (char_length(token) between 20 and 4096),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null default 'android' check (platform in ('android', 'ios', 'web')),
  updated_at timestamptz not null default now()
);
create index push_tokens_user_idx on public.push_tokens (user_id);

revoke all on public.push_tokens from anon, authenticated;
grant select on public.push_tokens to authenticated;
alter table public.push_tokens enable row level security;
create policy push_tokens_select on public.push_tokens
  for select to authenticated using (user_id = (select auth.uid()));

-- A token belongs to the last user who signed in on that device.
create or replace function public.register_push_token(p_token text, p_platform text default 'android')
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
  insert into public.push_tokens (token, user_id, platform, updated_at)
  values (p_token, v_uid, coalesce(p_platform, 'android'), now())
  on conflict (token) do update
    set user_id = excluded.user_id, platform = excluded.platform, updated_at = now();
  -- Keep a handful of devices per user at most.
  delete from public.push_tokens t
  where t.user_id = v_uid
    and t.token not in (
      select t2.token from public.push_tokens t2
      where t2.user_id = v_uid order by t2.updated_at desc limit 5
    );
end;
$$;

create or replace function public.unregister_push_token(p_token text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.push_tokens where token = p_token and user_id = auth.uid();
$$;

-- ---------------------------------------------------------------------------
-- Delivery
-- ---------------------------------------------------------------------------

create table private.push_config (
  id int primary key default 1 check (id = 1),
  function_url text not null check (function_url ~ '^https://'),
  secret text not null check (char_length(secret) >= 32)
);

create table private.push_log (
  id bigint generated always as identity primary key,
  kind text not null,
  user_ids uuid[] not null,
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  sent boolean not null default false,
  created_at timestamptz not null default now()
);
create index push_log_kind_created_idx on private.push_log (kind, created_at desc);

-- Logs the notification and, when pg_net and the config exist, asks the Edge
-- Function to deliver it. Never raises: a push failure must not roll back the
-- action that triggered it (an SOS, a support…).
create or replace function private.notify(
  p_kind text,
  p_user_ids uuid[],
  p_title text,
  p_body text,
  p_data jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_users uuid[];
  v_config private.push_config%rowtype;
  v_sent boolean := false;
begin
  -- Only users who have at least one device.
  select coalesce(array_agg(distinct t.user_id), '{}') into v_users
  from public.push_tokens t
  where t.user_id = any (coalesce(p_user_ids, '{}'));
  if cardinality(v_users) = 0 then
    return;
  end if;

  begin
    select * into v_config from private.push_config where id = 1;
    if found and exists (select 1 from pg_namespace where nspname = 'net') then
      execute 'select net.http_post(url := $1, body := $2, headers := $3, timeout_milliseconds := 5000)'
      using
        v_config.function_url,
        jsonb_build_object(
          'user_ids', to_jsonb(v_users),
          'title', p_title,
          'body', p_body,
          'data', coalesce(p_data, '{}'::jsonb) || jsonb_build_object('kind', p_kind)
        ),
        jsonb_build_object('Content-Type', 'application/json', 'x-push-secret', v_config.secret);
      v_sent := true;
    end if;
  exception when others then
    raise warning 'push not sent: %', sqlerrm;
  end;

  insert into private.push_log (kind, user_ids, title, body, data, sent)
  values (p_kind, v_users, p_title, p_body, coalesce(p_data, '{}'::jsonb), v_sent);
end;
$$;

-- ---------------------------------------------------------------------------
-- SOS: everyone else is alerted; the owner is told when someone supports them
-- ---------------------------------------------------------------------------

create or replace function private.on_sos_alert_push()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text;
  v_users uuid[];
begin
  -- Same visibility as in the app: a private player's SOS is not shown.
  if not public.is_public_player(new.user_id) then
    return new;
  end if;
  select p.username into v_name from public.profiles p where p.id = new.user_id;
  select coalesce(array_agg(p.id), '{}') into v_users
  from public.profiles p
  where p.id <> new.user_id and p.notify_sos;
  perform private.notify(
    'sos',
    v_users,
    '🆘 ' || v_name || ' a besoin de force',
    v_name || ' traverse une envie (' || new.addiction_label || '). Envoie-lui un soutien 💪',
    jsonb_build_object('alert_id', new.id, 'route', '/community')
  );
  return new;
end;
$$;

create trigger on_sos_alert_push
  after insert on public.sos_alerts
  for each row execute function private.on_sos_alert_push();

create or replace function private.on_sos_support_push()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_owner uuid;
  v_name text;
begin
  select a.user_id into v_owner from public.sos_alerts a where a.id = new.alert_id;
  if v_owner is null
     or not exists (select 1 from public.profiles p where p.id = v_owner and p.notify_sos) then
    return new;
  end if;
  select p.username into v_name from public.profiles p where p.id = new.user_id;
  perform private.notify(
    'sos_support',
    array[v_owner],
    new.emoji || ' ' || v_name || ' te soutient',
    'Tiens bon, tu n''es pas seul. Ouvre ton SOS pour voir les soutiens.',
    jsonb_build_object('alert_id', new.alert_id, 'route', '/home')
  );
  return new;
end;
$$;

create trigger on_sos_support_push
  after insert on public.sos_supports
  for each row execute function private.on_sos_support_push();

-- ---------------------------------------------------------------------------
-- Daily reminders (pg_cron, hourly; sends at 9 h and 20 h Europe/Zurich)
-- ---------------------------------------------------------------------------

-- Hours (Europe/Zurich) of the reminders, mirrored in Dart by
-- lib/features/notifications/domain/notification_prefs.dart (parity test).

-- Players who have not pledged today.
create or replace function private.pledge_reminder_targets(p_day date)
returns uuid[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(p.id), '{}')
  from public.profiles p
  where p.notify_reminders
    and not exists (select 1 from public.pledges g where g.user_id = p.id and g.day = p_day);
$$;

-- (user, quests left) for players with unfinished active quests today.
create or replace function private.quest_reminder_targets(p_day date)
returns table (user_id uuid, left_count int)
language sql
stable
security definer
set search_path = ''
as $$
  select q.user_id, count(*)::int
  from public.daily_quests q
  join public.profiles p on p.id = q.user_id and p.notify_reminders
  where q.archived_at is null
    and not exists (
      select 1 from public.quest_logs l
      where l.quest_id = q.id and l.day = p_day and l.done
    )
  group by q.user_id;
$$;

create or replace function private.send_reminders(p_now timestamptz default now())
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_local timestamp := p_now at time zone 'Europe/Zurich';
  v_day date := v_local::date;
  v_hour int := extract(hour from v_local)::int;
  v_target record;
begin
  -- Once per day and kind, even if the job runs twice in the same hour.
  if v_hour = 9 and not exists (
    select 1 from private.push_log
    where kind = 'reminder_pledge' and (created_at at time zone 'Europe/Zurich')::date = v_day
  ) then
    perform private.notify(
      'reminder_pledge',
      private.pledge_reminder_targets(v_day),
      '🤝 Engagement du jour',
      'Engage-toi à tenir aujourd''hui : +5 XP, et tout le monde le voit dans le feed.',
      jsonb_build_object('route', '/home')
    );
  end if;

  if v_hour = 20 and not exists (
    select 1 from private.push_log
    where kind = 'reminder_quests' and (created_at at time zone 'Europe/Zurich')::date = v_day
  ) then
    for v_target in select * from private.quest_reminder_targets(v_day) loop
      perform private.notify(
        'reminder_quests',
        array[v_target.user_id],
        '🎯 Tes quêtes du jour',
        case when v_target.left_count = 1
          then 'Plus qu''une quête à boucler avant minuit. Tu gères !'
          else 'Encore ' || v_target.left_count || ' quêtes à boucler avant minuit. Tu gères !'
        end,
        jsonb_build_object('route', '/quests')
      );
    end loop;
  end if;
end;
$$;

do $$
begin
  if exists (select 1 from pg_namespace where nspname = 'cron') then
    perform cron.schedule('push-reminders', '0 * * * *', 'select private.send_reminders()');
  else
    raise notice 'pg_cron not available, reminders not scheduled';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on function public.register_push_token(text, text), public.unregister_push_token(text)
  from public, anon;
grant execute on function public.register_push_token(text, text), public.unregister_push_token(text)
  to authenticated;

alter table private.push_config enable row level security;
alter table private.push_log enable row level security;
revoke all on all tables in schema private from public, anon, authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
