-- Detox V0 — gamification functions and triggers.
-- XP / HP / level / feed are written ONLY here, never by the client.

-- ---------------------------------------------------------------------------
-- Pure helpers
-- ---------------------------------------------------------------------------

-- xp_for_level(L) = 50 * L * (L - 1)  →  L2 = 100, L3 = 300, L4 = 600, L5 = 1000…
create or replace function public.xp_for_level(p_level int)
returns bigint
language sql
immutable
set search_path = ''
as $$
  select 50::bigint * greatest(p_level, 1) * (greatest(p_level, 1) - 1);
$$;

-- Inverse of xp_for_level: floor((1 + sqrt(1 + xp / 12.5)) / 2).
-- The two guards fix any floating point drift at exact level boundaries.
-- Mirrored in Dart: lib/features/gamification/domain/leveling.dart
create or replace function public.level_for_xp(p_xp bigint)
returns int
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_xp bigint := greatest(coalesce(p_xp, 0), 0);
  v_level int;
begin
  v_level := floor((1 + sqrt(1 + v_xp / 12.5)) / 2)::int;
  if public.xp_for_level(v_level + 1) <= v_xp then
    v_level := v_level + 1;
  elsif public.xp_for_level(v_level) > v_xp then
    v_level := v_level - 1;
  end if;
  return greatest(v_level, 1);
end;
$$;

-- Label shown to the squad: a private addiction never leaks its label.
create or replace function private.public_label(p_label text, p_is_private boolean)
returns text
language sql
immutable
set search_path = ''
as $$
  select case when p_is_private then 'une addiction privée' else p_label end;
$$;

create or replace function private.xp_per_day(p_type text)
returns int
language sql
stable
set search_path = ''
as $$
  select coalesce((select r.xp_per_day from private.addiction_xp_rules r where r.type = p_type), 0);
$$;

create or replace function public.is_squad_member(p_squad_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.squad_members m
    where m.squad_id = p_squad_id and m.user_id = auth.uid()
  );
$$;

create or replace function private.squad_of(p_user_id uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.squad_id from public.squad_members m where m.user_id = p_user_id;
$$;

-- Inserts a feed event in the user's squad (no-op if the user has no squad).
-- Username and avatar are embedded so the event stays readable after a member leaves.
create or replace function private.push_feed(p_user_id uuid, p_type text, p_payload jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_squad uuid := private.squad_of(p_user_id);
  v_profile public.profiles%rowtype;
begin
  if v_squad is null then
    return;
  end if;
  select * into v_profile from public.profiles where id = p_user_id;
  insert into public.feed_events (squad_id, user_id, type, payload)
  values (
    v_squad,
    p_user_id,
    p_type,
    jsonb_build_object('username', v_profile.username, 'avatar_emoji', v_profile.avatar_emoji)
      || coalesce(p_payload, '{}'::jsonb)
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- New user → player_stats row (the profile is created during onboarding).
-- ---------------------------------------------------------------------------

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.player_stats (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ---------------------------------------------------------------------------
-- Ledger → player_stats
-- ---------------------------------------------------------------------------

create or replace function private.on_ledger_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_old_level int;
  v_new_level int;
begin
  insert into public.player_stats (user_id) values (new.user_id)
  on conflict (user_id) do nothing;

  select level into v_old_level
  from public.player_stats where user_id = new.user_id
  for update;

  update public.player_stats
  set xp = xp + new.amount_xp,
      hp = least(100, greatest(0, hp + new.amount_hp)),
      level = public.level_for_xp(xp + new.amount_xp),
      updated_at = now()
  where user_id = new.user_id
  returning level into v_new_level;

  if v_new_level > v_old_level then
    perform private.push_feed(new.user_id, 'level_up', jsonb_build_object('level', v_new_level));
  end if;
  return new;
end;
$$;

create trigger on_ledger_insert
  after insert on public.xp_ledger
  for each row execute function private.on_ledger_insert();

-- ---------------------------------------------------------------------------
-- Clean days
-- ---------------------------------------------------------------------------

-- Awards every full clean day (24 h of real time) not yet awarded for one addiction,
-- up to p_as_of, plus the milestone bonuses crossed. Idempotent thanks to
-- awarded_clean_days, updated in the same transaction under a row lock.
create or replace function private.award_addiction_days(p_addiction_id uuid, p_as_of timestamptz)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_add public.addictions%rowtype;
  v_days int;
  v_xp int;
  v_milestone record;
begin
  select * into v_add from public.addictions where id = p_addiction_id for update;
  if not found or v_add.archived_at is not null then
    return;
  end if;

  v_days := floor(extract(epoch from (p_as_of - v_add.streak_started_at)) / 86400)::int;
  if v_days <= v_add.awarded_clean_days then
    return;
  end if;

  v_xp := private.xp_per_day(v_add.type);
  insert into public.xp_ledger (user_id, amount_xp, amount_hp, reason, ref_id)
  select v_add.user_id, v_xp, 5, 'clean_day', v_add.id
  from generate_series(v_add.awarded_clean_days + 1, v_days);

  for v_milestone in
    select m.days, m.bonus_xp from private.milestones m
    where m.days > v_add.awarded_clean_days and m.days <= v_days
    order by m.days
  loop
    insert into public.xp_ledger (user_id, amount_xp, amount_hp, reason, ref_id)
    values (v_add.user_id, v_milestone.bonus_xp, 0, 'milestone', v_add.id);
    perform private.push_feed(
      v_add.user_id,
      'milestone',
      jsonb_build_object(
        'days', v_milestone.days,
        'bonus_xp', v_milestone.bonus_xp,
        'addiction_type', case when v_add.is_private then null else v_add.type end,
        'addiction_label', private.public_label(v_add.label, v_add.is_private)
      )
    );
  end loop;

  update public.addictions set awarded_clean_days = v_days where id = v_add.id;
end;
$$;

-- pg_cron entry point (hourly).
create or replace function private.award_clean_days()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  for v_id in
    select a.id from public.addictions a
    where a.archived_at is null
      and floor(extract(epoch from (now() - a.streak_started_at)) / 86400) > a.awarded_clean_days
  loop
    perform private.award_addiction_days(v_id, now());
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Addictions: server-controlled streak columns
-- ---------------------------------------------------------------------------

-- On insert the client only chooses the quit date. The streak starts there.
-- Days already clean before the addiction was added count for the timer and the
-- record, but do not grant retroactive XP or milestones (XP is earned in the app).
create or replace function private.on_addiction_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.user_id := coalesce(auth.uid(), new.user_id);
  if new.quit_started_at > now() + interval '1 minute' then
    raise exception 'quit_date_in_future' using errcode = 'P0001';
  end if;
  new.streak_started_at := new.quit_started_at;
  new.best_streak_seconds := 0;
  new.awarded_clean_days := greatest(0, floor(extract(epoch from (now() - new.quit_started_at)) / 86400)::int);
  new.archived_at := null;
  return new;
end;
$$;

create trigger on_addiction_before_insert
  before insert on public.addictions
  for each row execute function private.on_addiction_before_insert();

-- ---------------------------------------------------------------------------
-- Relapses
-- ---------------------------------------------------------------------------

create or replace function private.on_relapse_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_add public.addictions%rowtype;
begin
  select * into v_add from public.addictions where id = new.addiction_id;
  if not found or (auth.uid() is not null and v_add.user_id <> auth.uid()) then
    raise exception 'addiction_not_found' using errcode = 'P0001';
  end if;
  if v_add.archived_at is not null then
    raise exception 'addiction_archived' using errcode = 'P0001';
  end if;
  if new.occurred_at > now() + interval '1 minute' then
    raise exception 'relapse_in_future' using errcode = 'P0001';
  end if;
  if new.occurred_at < v_add.streak_started_at then
    raise exception 'relapse_before_streak' using errcode = 'P0001';
  end if;
  new.user_id := v_add.user_id;
  return new;
end;
$$;

create trigger on_relapse_before_insert
  before insert on public.relapses
  for each row execute function private.on_relapse_before_insert();

create or replace function private.on_relapse_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_add public.addictions%rowtype;
  v_streak_seconds bigint;
begin
  -- Award the clean days earned before the relapse (the hourly job may lag).
  perform private.award_addiction_days(new.addiction_id, new.occurred_at);

  select * into v_add from public.addictions where id = new.addiction_id for update;
  v_streak_seconds := greatest(0, floor(extract(epoch from (new.occurred_at - v_add.streak_started_at))))::bigint;

  update public.addictions
  set best_streak_seconds = greatest(best_streak_seconds, v_streak_seconds),
      streak_started_at = new.occurred_at,
      awarded_clean_days = 0
  where id = v_add.id;

  -- A relapse never removes XP: it only costs HP.
  insert into public.xp_ledger (user_id, amount_xp, amount_hp, reason, ref_id)
  values (new.user_id, 0, -25, 'relapse', new.id);

  if new.shared then
    perform private.push_feed(
      new.user_id,
      'relapse',
      jsonb_build_object(
        'addiction_type', case when v_add.is_private then null else v_add.type end,
        'addiction_label', private.public_label(v_add.label, v_add.is_private),
        'streak_seconds', v_streak_seconds
      )
    );
  end if;
  return new;
end;
$$;

create trigger on_relapse_insert
  after insert on public.relapses
  for each row execute function private.on_relapse_insert();

-- ---------------------------------------------------------------------------
-- Squad RPCs
-- ---------------------------------------------------------------------------

create or replace function private.generate_invite_code()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  v_chars constant text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  v_code text;
begin
  loop
    select string_agg(substr(v_chars, 1 + floor(random() * 36)::int, 1), '')
    into v_code
    from generate_series(1, 6);
    exit when not exists (select 1 from public.squads s where s.invite_code = v_code);
  end loop;
  return v_code;
end;
$$;

create or replace function public.create_squad(name text)
returns public.squads
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_squad public.squads;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid) then
    raise exception 'profile_required' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.squad_members where user_id = v_uid) then
    raise exception 'already_in_squad' using errcode = 'P0001';
  end if;
  if char_length(btrim(coalesce(name, ''))) not between 1 and 40 then
    raise exception 'invalid_squad_name' using errcode = 'P0001';
  end if;

  insert into public.squads (name, invite_code, created_by)
  values (btrim(name), private.generate_invite_code(), v_uid)
  returning * into v_squad;

  insert into public.squad_members (squad_id, user_id, role)
  values (v_squad.id, v_uid, 'owner');

  return v_squad;
end;
$$;

create or replace function public.join_squad(code text)
returns public.squads
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_squad public.squads;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid) then
    raise exception 'profile_required' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.squad_members where user_id = v_uid) then
    raise exception 'already_in_squad' using errcode = 'P0001';
  end if;

  select * into v_squad
  from public.squads
  where invite_code = upper(btrim(coalesce(code, '')))
  for update;
  if not found then
    raise exception 'invalid_invite_code' using errcode = 'P0001';
  end if;

  if (select count(*) from public.squad_members where squad_id = v_squad.id) >= 10 then
    raise exception 'squad_full' using errcode = 'P0001';
  end if;

  insert into public.squad_members (squad_id, user_id, role)
  values (v_squad.id, v_uid, 'member');

  perform private.push_feed(v_uid, 'joined_squad', '{}'::jsonb);
  return v_squad;
end;
$$;

create or replace function public.leave_squad()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_member public.squad_members;
  v_next uuid;
begin
  select * into v_member from public.squad_members where user_id = v_uid;
  if not found then
    return;
  end if;

  -- Feed first, while the user is still a member.
  perform private.push_feed(v_uid, 'left_squad', '{}'::jsonb);
  delete from public.squad_members where user_id = v_uid;

  select m.user_id into v_next
  from public.squad_members m
  where m.squad_id = v_member.squad_id
  order by m.joined_at
  limit 1;

  if v_next is null then
    delete from public.squads where id = v_member.squad_id;
  elsif v_member.role = 'owner' then
    update public.squad_members set role = 'owner'
    where squad_id = v_member.squad_id and user_id = v_next;
  end if;
end;
$$;

-- Weekly leaderboard (week starts Monday 00:00 Europe/Zurich).
create or replace function public.squad_leaderboard()
returns table (
  user_id uuid,
  username text,
  avatar_emoji text,
  level int,
  hp int,
  xp bigint,
  weekly_xp bigint
)
language sql
stable
security definer
set search_path = ''
as $$
  with week as (
    select (date_trunc('week', now() at time zone 'Europe/Zurich') at time zone 'Europe/Zurich') as start_at
  )
  select
    m.user_id,
    p.username,
    p.avatar_emoji,
    coalesce(s.level, 1),
    coalesce(s.hp, 100),
    coalesce(s.xp, 0),
    coalesce((
      select sum(l.amount_xp) from public.xp_ledger l, week w
      where l.user_id = m.user_id and l.created_at >= w.start_at
    ), 0)::bigint as weekly_xp
  from public.squad_members m
  join public.profiles p on p.id = m.user_id
  left join public.player_stats s on s.user_id = m.user_id
  where m.squad_id = private.squad_of(auth.uid())
  order by weekly_xp desc, coalesce(s.xp, 0) desc, p.username;
$$;

-- Username availability during onboarding (profiles are not readable outside the squad).
create or replace function public.is_username_available(name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (
    select 1 from public.profiles p
    where lower(p.username) = lower(btrim(name)) and p.id <> coalesce(auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid)
  );
$$;
