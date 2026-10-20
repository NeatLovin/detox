-- Detox V1 — cravings journal, SOS with squad support, daily quests,
-- morning pledge, badges and personal motivations.
--
-- Same rules as V0: XP / HP / badges / feed are written ONLY by these functions
-- and triggers; the client never writes them. Every XP source added here is
-- capped per Europe/Zurich day so it cannot be farmed.

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function private.zurich_today()
returns date
language sql
stable
set search_path = ''
as $$
  select (now() at time zone 'Europe/Zurich')::date;
$$;

create or replace function private.zurich_day_start()
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select private.zurich_today()::timestamp at time zone 'Europe/Zurich';
$$;

-- Reward rules: XP granted and how many times per day it can be granted.
-- Mirrored in Dart: lib/features/gamification/domain/rewards.dart
-- test/sql_parity_test.dart parses the block below: keep the markers.
create table private.reward_rules (
  key text primary key,
  reason text not null,
  xp int not null check (xp >= 0),
  daily_cap int not null check (daily_cap >= 1)
);

-- @rules:rewards:begin
insert into private.reward_rules (key, reason, xp, daily_cap) values
  ('craving', 'craving', 10, 3),
  ('craving_sos', 'craving', 15, 3),
  ('quest', 'quest', 10, 6),
  ('quests_all_done', 'quests_all_done', 20, 1),
  ('pledge', 'pledge', 5, 1),
  ('sos_support', 'sos_support', 5, 5);
-- @rules:rewards:end

-- Grants the reward of p_rule unless today's cap for its ledger reason is
-- reached. Returns the XP granted (0 when capped). Serialized per user and
-- reason so concurrent calls cannot exceed the cap.
create or replace function private.try_reward(p_user uuid, p_rule text, p_ref uuid)
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_rule private.reward_rules%rowtype;
  v_count int;
begin
  select * into v_rule from private.reward_rules where key = p_rule;
  if not found then
    raise exception 'unknown_reward_rule' using errcode = 'P0001';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('reward:' || p_user::text || ':' || v_rule.reason, 0));

  select count(*) into v_count
  from public.xp_ledger l
  where l.user_id = p_user
    and l.reason = v_rule.reason
    and l.created_at >= private.zurich_day_start();

  if v_count >= v_rule.daily_cap then
    return 0;
  end if;

  insert into public.xp_ledger (user_id, amount_xp, amount_hp, reason, ref_id)
  values (p_user, v_rule.xp, 0, v_rule.reason, p_ref);
  return v_rule.xp;
end;
$$;

-- New ledger reasons and feed types.
alter table public.xp_ledger drop constraint xp_ledger_reason_check;
alter table public.xp_ledger add constraint xp_ledger_reason_check check (reason in (
  'clean_day', 'milestone', 'relapse',
  'craving', 'quest', 'quests_all_done', 'pledge', 'sos_support'
));

alter table public.feed_events drop constraint feed_events_type_check;
alter table public.feed_events add constraint feed_events_type_check check (type in (
  'joined_squad', 'left_squad', 'milestone', 'level_up', 'relapse',
  'pledge', 'badge', 'sos', 'sos_support', 'sos_resolved', 'quests_all_done'
));

-- ---------------------------------------------------------------------------
-- Badges
-- ---------------------------------------------------------------------------

create table public.badges (
  user_id uuid not null references auth.users (id) on delete cascade,
  key text not null check (key in (
    'first_pledge', 'pledge_streak_7',
    'first_resist', 'resist_10', 'sos_first', 'helper',
    'streak_7', 'streak_30', 'streak_90', 'comeback',
    'quest_streak_7', 'level_5', 'level_10'
  )),
  unlocked_at timestamptz not null default now(),
  primary key (user_id, key)
);

-- Unlocks a badge once and announces it to the squad. True if newly unlocked.
create or replace function private.award_badge(p_user uuid, p_key text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.badges (user_id, key) values (p_user, p_key)
  on conflict (user_id, key) do nothing;
  if not found then
    return false;
  end if;
  perform private.push_feed(p_user, 'badge', jsonb_build_object('badge', p_key));
  return true;
end;
$$;

-- Streak and comeback badges, derived from milestone ledger rows. The bonus
-- amount identifies the milestone (amounts are unique in private.milestones),
-- so award_addiction_days does not need to be rewritten.
create or replace function private.on_ledger_badges()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_days int;
begin
  if new.reason <> 'milestone' then
    return new;
  end if;
  select m.days into v_days from private.milestones m where m.bonus_xp = new.amount_xp;
  if v_days in (7, 30, 90) then
    perform private.award_badge(new.user_id, 'streak_' || v_days);
  end if;
  if v_days = 30 and exists (select 1 from public.relapses r where r.addiction_id = new.ref_id) then
    perform private.award_badge(new.user_id, 'comeback');
  end if;
  return new;
end;
$$;

create trigger on_ledger_badges
  after insert on public.xp_ledger
  for each row execute function private.on_ledger_badges();

create or replace function private.on_level_badges()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.level >= 5 and old.level < 5 then
    perform private.award_badge(new.user_id, 'level_5');
  end if;
  if new.level >= 10 and old.level < 10 then
    perform private.award_badge(new.user_id, 'level_10');
  end if;
  return new;
end;
$$;

create trigger on_level_badges
  after update of level on public.player_stats
  for each row execute function private.on_level_badges();

-- ---------------------------------------------------------------------------
-- Cravings
-- ---------------------------------------------------------------------------

create table public.cravings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  addiction_id uuid not null references public.addictions (id) on delete cascade,
  occurred_at timestamptz not null default now(),
  intensity smallint not null check (intensity between 1 and 5),
  trigger text not null default 'other' check (trigger in (
    'stress', 'boredom', 'party', 'after_meal', 'morning', 'screen', 'social', 'tired', 'other'
  )),
  note text check (note is null or char_length(note) <= 300),
  resisted boolean not null,
  via_sos boolean not null default false,
  xp_awarded int not null default 0,
  created_at timestamptz not null default now()
);
create index cravings_user_occurred_idx on public.cravings (user_id, occurred_at desc);

create or replace function private.on_craving_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_add public.addictions%rowtype;
begin
  new.user_id := coalesce(auth.uid(), new.user_id);
  select * into v_add from public.addictions where id = new.addiction_id;
  if not found or v_add.user_id <> new.user_id then
    raise exception 'addiction_not_found' using errcode = 'P0001';
  end if;
  if v_add.archived_at is not null then
    raise exception 'addiction_archived' using errcode = 'P0001';
  end if;
  if new.occurred_at > now() + interval '1 minute' then
    raise exception 'craving_in_future' using errcode = 'P0001';
  end if;
  if new.occurred_at < now() - interval '7 days' then
    raise exception 'craving_too_old' using errcode = 'P0001';
  end if;
  new.xp_awarded := 0;
  return new;
end;
$$;

create trigger on_craving_before_insert
  before insert on public.cravings
  for each row execute function private.on_craving_before_insert();

create or replace function private.on_craving_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_xp int := 0;
  v_resisted int;
begin
  if not new.resisted then
    return new;
  end if;

  v_xp := private.try_reward(new.user_id, case when new.via_sos then 'craving_sos' else 'craving' end, new.id);
  if v_xp > 0 then
    update public.cravings set xp_awarded = v_xp where id = new.id;
  end if;

  select count(*) into v_resisted from public.cravings where user_id = new.user_id and resisted;
  if v_resisted >= 1 then
    perform private.award_badge(new.user_id, 'first_resist');
  end if;
  if v_resisted >= 10 then
    perform private.award_badge(new.user_id, 'resist_10');
  end if;
  if new.via_sos then
    perform private.award_badge(new.user_id, 'sos_first');
  end if;
  return new;
end;
$$;

create trigger on_craving_insert
  after insert on public.cravings
  for each row execute function private.on_craving_insert();

-- ---------------------------------------------------------------------------
-- SOS
-- ---------------------------------------------------------------------------

create table public.sos_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  squad_id uuid references public.squads (id) on delete set null,
  addiction_id uuid references public.addictions (id) on delete set null,
  -- Label safe to show to the squad (masked for a private addiction).
  addiction_label text not null,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  outcome text check (outcome in ('resisted', 'relapsed'))
);
create index sos_alerts_squad_created_idx on public.sos_alerts (squad_id, created_at desc);
create index sos_alerts_user_created_idx on public.sos_alerts (user_id, created_at desc);

create table public.sos_supports (
  alert_id uuid not null references public.sos_alerts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  emoji text not null check (emoji in ('💪', '🔥', '🫂', '🧠', '🏆')),
  created_at timestamptz not null default now(),
  primary key (alert_id, user_id)
);

-- Starts an SOS for one of the caller's addictions and alerts the squad.
-- Idempotent: an open SOS for the same addiction from the last 30 minutes is reused.
create or replace function public.start_sos(p_addiction_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_add public.addictions%rowtype;
  v_id uuid;
  v_label text;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;
  select * into v_add from public.addictions where id = p_addiction_id;
  if not found or v_add.user_id <> v_uid then
    raise exception 'addiction_not_found' using errcode = 'P0001';
  end if;
  if v_add.archived_at is not null then
    raise exception 'addiction_archived' using errcode = 'P0001';
  end if;

  select a.id into v_id
  from public.sos_alerts a
  where a.user_id = v_uid
    and a.addiction_id = p_addiction_id
    and a.resolved_at is null
    and a.created_at > now() - interval '30 minutes'
  order by a.created_at desc
  limit 1;
  if v_id is not null then
    return v_id;
  end if;

  v_label := private.public_label(v_add.label, v_add.is_private);
  insert into public.sos_alerts (user_id, squad_id, addiction_id, addiction_label)
  values (v_uid, private.squad_of(v_uid), v_add.id, v_label)
  returning id into v_id;

  perform private.push_feed(v_uid, 'sos', jsonb_build_object(
    'alert_id', v_id,
    'addiction_type', case when v_add.is_private then null else v_add.type end,
    'addiction_label', v_label
  ));
  return v_id;
end;
$$;

-- Closes an SOS. The outcome is logged as a craving (resisted ones earn XP).
-- Only a resisted outcome is announced: a relapse is shared only through the
-- relapse flow, where the user chooses whether to share it.
create or replace function public.resolve_sos(
  p_alert_id uuid,
  p_resisted boolean,
  p_intensity int default 3,
  p_trigger text default 'other'
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_alert public.sos_alerts%rowtype;
begin
  select * into v_alert from public.sos_alerts where id = p_alert_id for update;
  if not found or v_alert.user_id is distinct from v_uid then
    raise exception 'sos_not_found' using errcode = 'P0001';
  end if;
  if v_alert.resolved_at is not null then
    raise exception 'sos_already_resolved' using errcode = 'P0001';
  end if;

  update public.sos_alerts
  set resolved_at = now(),
      outcome = case when p_resisted then 'resisted' else 'relapsed' end
  where id = p_alert_id;

  if v_alert.addiction_id is not null then
    insert into public.cravings (user_id, addiction_id, intensity, trigger, resisted, via_sos)
    values (v_uid, v_alert.addiction_id, least(5, greatest(1, coalesce(p_intensity, 3))),
            coalesce(p_trigger, 'other'), p_resisted, true);
  end if;

  if p_resisted then
    perform private.push_feed(v_uid, 'sos_resolved', jsonb_build_object(
      'alert_id', p_alert_id,
      'addiction_label', v_alert.addiction_label
    ));
  end if;
end;
$$;

-- A squad mate sends support to an SOS (once per alert, within 24 h).
create or replace function public.support_sos(p_alert_id uuid, p_emoji text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_alert public.sos_alerts%rowtype;
  v_to public.profiles%rowtype;
  v_count int;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;
  select * into v_alert from public.sos_alerts where id = p_alert_id;
  if not found or v_alert.squad_id is null or v_alert.squad_id is distinct from private.squad_of(v_uid) then
    raise exception 'sos_not_found' using errcode = 'P0001';
  end if;
  if v_alert.user_id = v_uid then
    raise exception 'sos_own_alert' using errcode = 'P0001';
  end if;
  if v_alert.created_at < now() - interval '24 hours' then
    raise exception 'sos_expired' using errcode = 'P0001';
  end if;

  insert into public.sos_supports (alert_id, user_id, emoji)
  values (p_alert_id, v_uid, p_emoji)
  on conflict (alert_id, user_id) do nothing;
  if not found then
    return;
  end if;

  perform private.try_reward(v_uid, 'sos_support', p_alert_id);

  select * into v_to from public.profiles where id = v_alert.user_id;
  perform private.push_feed(v_uid, 'sos_support', jsonb_build_object(
    'alert_id', p_alert_id,
    'emoji', p_emoji,
    'to_user_id', v_alert.user_id,
    'to_username', v_to.username
  ));

  select count(*) into v_count from public.sos_supports where user_id = v_uid;
  if v_count >= 5 then
    perform private.award_badge(v_uid, 'helper');
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- Daily quests
-- ---------------------------------------------------------------------------

create table public.daily_quests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  type text not null check (type in (
    'water', 'sport', 'sleep', 'steps', 'meditation', 'reading', 'no_screen', 'custom'
  )),
  label text not null check (char_length(btrim(label)) between 1 and 40),
  unit_label text not null check (char_length(btrim(unit_label)) between 1 and 20),
  target numeric(10, 2) not null check (target > 0 and target <= 100000),
  archived_at timestamptz,
  created_at timestamptz not null default now()
);
create index daily_quests_user_idx on public.daily_quests (user_id);

create table public.quest_logs (
  quest_id uuid not null references public.daily_quests (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null,
  value numeric(10, 2) not null default 0 check (value >= 0 and value <= 1000000),
  done boolean not null default false,
  xp_awarded boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (quest_id, day)
);
create index quest_logs_user_day_idx on public.quest_logs (user_id, day);

-- Mirrored in Dart: lib/features/quests/domain/quest_catalog.dart (QuestLimits).
create or replace function private.on_quest_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_active int;
begin
  new.user_id := coalesce(auth.uid(), new.user_id);
  new.archived_at := null;
  perform pg_advisory_xact_lock(hashtextextended('quests:' || new.user_id::text, 0));
  select count(*) into v_active
  from public.daily_quests
  where user_id = new.user_id and archived_at is null;
  if v_active >= 8 then
    raise exception 'too_many_quests' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger on_quest_before_insert
  before insert on public.daily_quests
  for each row execute function private.on_quest_before_insert();

-- Un-archiving a quest counts against the same cap.
create or replace function private.on_quest_before_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.user_id := old.user_id;
  new.type := old.type;
  if new.archived_at is null and old.archived_at is not null then
    perform pg_advisory_xact_lock(hashtextextended('quests:' || new.user_id::text, 0));
    if (select count(*) from public.daily_quests
        where user_id = new.user_id and archived_at is null) >= 8 then
      raise exception 'too_many_quests' using errcode = 'P0001';
    end if;
  end if;
  return new;
end;
$$;

create trigger on_quest_before_update
  before update on public.daily_quests
  for each row execute function private.on_quest_before_update();

-- Sets the progress of a quest for today (or yesterday, for late logging).
-- First completion of a quest-day earns XP (capped per day). Completing every
-- active quest today (3 or more) earns a one-shot bonus.
create or replace function public.log_quest(p_quest_id uuid, p_value numeric, p_day date default null)
returns public.quest_logs
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_quest public.daily_quests%rowtype;
  v_today date := private.zurich_today();
  v_day date := coalesce(p_day, private.zurich_today());
  v_log public.quest_logs%rowtype;
  v_active int;
  v_done int;
  v_streak int;
begin
  select * into v_quest from public.daily_quests where id = p_quest_id;
  if not found or v_quest.user_id is distinct from v_uid then
    raise exception 'quest_not_found' using errcode = 'P0001';
  end if;
  if v_quest.archived_at is not null then
    raise exception 'quest_archived' using errcode = 'P0001';
  end if;
  if v_day not in (v_today, v_today - 1) then
    raise exception 'quest_day_out_of_range' using errcode = 'P0001';
  end if;
  if p_value is null or p_value < 0 then
    raise exception 'quest_invalid_value' using errcode = 'P0001';
  end if;

  insert into public.quest_logs (quest_id, user_id, day, value, done, updated_at)
  values (p_quest_id, v_uid, v_day, p_value, p_value >= v_quest.target, now())
  on conflict (quest_id, day) do update
    set value = excluded.value, done = excluded.done, updated_at = now()
  returning * into v_log;

  if v_log.done and not v_log.xp_awarded then
    if private.try_reward(v_uid, 'quest', p_quest_id) > 0 then
      update public.quest_logs set xp_awarded = true
      where quest_id = p_quest_id and day = v_day
      returning * into v_log;
    end if;
  end if;

  if v_log.done then
    select count(*) into v_streak
    from public.quest_logs
    where quest_id = p_quest_id and done and day between v_day - 6 and v_day;
    if v_streak >= 7 then
      perform private.award_badge(v_uid, 'quest_streak_7');
    end if;
  end if;

  if v_log.done and v_day = v_today then
    select count(*) into v_active
    from public.daily_quests where user_id = v_uid and archived_at is null;
    select count(*) into v_done
    from public.quest_logs l
    join public.daily_quests q on q.id = l.quest_id
    where l.user_id = v_uid and l.day = v_today and l.done and q.archived_at is null;
    if v_active >= 3 and v_done >= v_active then
      if private.try_reward(v_uid, 'quests_all_done', null) > 0 then
        perform private.push_feed(v_uid, 'quests_all_done', jsonb_build_object('count', v_active));
      end if;
    end if;
  end if;

  return v_log;
end;
$$;

-- ---------------------------------------------------------------------------
-- Morning pledge
-- ---------------------------------------------------------------------------

create table public.pledges (
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null,
  created_at timestamptz not null default now(),
  primary key (user_id, day)
);

-- Today's pledge (Europe/Zurich). True when newly made, false if already done.
create or replace function public.make_pledge()
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_today date := private.zurich_today();
  v_recent int;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;
  insert into public.pledges (user_id, day) values (v_uid, v_today)
  on conflict (user_id, day) do nothing;
  if not found then
    return false;
  end if;

  perform private.try_reward(v_uid, 'pledge', null);
  perform private.push_feed(v_uid, 'pledge', '{}'::jsonb);
  perform private.award_badge(v_uid, 'first_pledge');

  select count(*) into v_recent
  from public.pledges where user_id = v_uid and day > v_today - 7;
  if v_recent >= 7 then
    perform private.award_badge(v_uid, 'pledge_streak_7');
  end if;
  return true;
end;
$$;

-- ---------------------------------------------------------------------------
-- Motivations ("my reasons"), shown on the SOS screen. Owner only.
-- ---------------------------------------------------------------------------

create table public.motivations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  text text not null check (char_length(btrim(text)) between 1 and 140),
  created_at timestamptz not null default now()
);
create index motivations_user_idx on public.motivations (user_id);

create or replace function private.on_motivation_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.user_id := coalesce(auth.uid(), new.user_id);
  perform pg_advisory_xact_lock(hashtextextended('motivations:' || new.user_id::text, 0));
  if (select count(*) from public.motivations where user_id = new.user_id) >= 5 then
    raise exception 'too_many_motivations' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger on_motivation_before_insert
  before insert on public.motivations
  for each row execute function private.on_motivation_before_insert();

-- ---------------------------------------------------------------------------
-- Grants (Supabase grants everything on new objects by default: start from zero)
-- ---------------------------------------------------------------------------

revoke all on public.badges, public.cravings, public.sos_alerts, public.sos_supports,
  public.daily_quests, public.quest_logs, public.pledges, public.motivations
  from anon, authenticated;

grant select on public.badges, public.sos_alerts, public.sos_supports,
  public.quest_logs, public.pledges to authenticated;

grant select, delete on public.cravings to authenticated;
grant insert (addiction_id, occurred_at, intensity, trigger, note, resisted)
  on public.cravings to authenticated;
grant update (note) on public.cravings to authenticated;

grant select on public.daily_quests to authenticated;
grant insert (type, label, unit_label, target) on public.daily_quests to authenticated;
grant update (label, unit_label, target, archived_at) on public.daily_quests to authenticated;

grant select, delete on public.motivations to authenticated;
grant insert (text) on public.motivations to authenticated;
grant update (text) on public.motivations to authenticated;

revoke execute on function
  public.start_sos(uuid),
  public.resolve_sos(uuid, boolean, int, text),
  public.support_sos(uuid, text),
  public.log_quest(uuid, numeric, date),
  public.make_pledge()
  from public, anon;
grant execute on function
  public.start_sos(uuid),
  public.resolve_sos(uuid, boolean, int, text),
  public.support_sos(uuid, text),
  public.log_quest(uuid, numeric, date),
  public.make_pledge()
  to authenticated;

revoke all on all tables in schema private from public, anon, authenticated;
revoke all on all functions in schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.badges enable row level security;
alter table public.cravings enable row level security;
alter table public.sos_alerts enable row level security;
alter table public.sos_supports enable row level security;
alter table public.daily_quests enable row level security;
alter table public.quest_logs enable row level security;
alter table public.pledges enable row level security;
alter table public.motivations enable row level security;
alter table private.reward_rules enable row level security;

-- Badges are visible to the squad (generic keys, no addiction details).
create policy badges_select on public.badges
  for select to authenticated
  using (
    user_id = (select auth.uid())
    or exists (
      select 1 from public.squad_members m
      where m.user_id = badges.user_id and public.is_squad_member(m.squad_id)
    )
  );

-- Owner-only data.
create policy cravings_select on public.cravings
  for select to authenticated using (user_id = (select auth.uid()));
create policy cravings_insert on public.cravings
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy cravings_update on public.cravings
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy cravings_delete on public.cravings
  for delete to authenticated using (user_id = (select auth.uid()));

create policy daily_quests_select on public.daily_quests
  for select to authenticated using (user_id = (select auth.uid()));
create policy daily_quests_insert on public.daily_quests
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy daily_quests_update on public.daily_quests
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy quest_logs_select on public.quest_logs
  for select to authenticated using (user_id = (select auth.uid()));

create policy pledges_select on public.pledges
  for select to authenticated using (user_id = (select auth.uid()));

create policy motivations_select on public.motivations
  for select to authenticated using (user_id = (select auth.uid()));
create policy motivations_insert on public.motivations
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy motivations_update on public.motivations
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy motivations_delete on public.motivations
  for delete to authenticated using (user_id = (select auth.uid()));

-- SOS: the owner and the squad of the alert.
create policy sos_alerts_select on public.sos_alerts
  for select to authenticated
  using (user_id = (select auth.uid()) or public.is_squad_member(squad_id));
create policy sos_supports_select on public.sos_supports
  for select to authenticated
  using (exists (
    select 1 from public.sos_alerts a
    where a.id = sos_supports.alert_id
      and (a.user_id = (select auth.uid()) or public.is_squad_member(a.squad_id))
  ));

-- ---------------------------------------------------------------------------
-- Realtime
-- ---------------------------------------------------------------------------

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.sos_alerts, public.sos_supports;
  end if;
end;
$$;
