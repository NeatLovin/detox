-- Detox V0 — core schema.
-- Tables, constraints and gamification rule tables.
-- Internal (non-API) objects live in the `private` schema, which is not exposed by PostgREST.

create schema if not exists private;
revoke all on schema private from public;

-- ---------------------------------------------------------------------------
-- Gamification rules (source of truth on the server side).
-- Mirrored in Dart by lib/features/addictions/domain/addiction_catalog.dart
-- and lib/features/gamification/domain/milestones.dart.
-- test/sql_parity_test.dart parses the blocks below: keep the markers.
-- ---------------------------------------------------------------------------

create table private.addiction_xp_rules (
  type text primary key,
  xp_per_day int not null check (xp_per_day >= 0)
);

-- @rules:xp_per_day:begin
insert into private.addiction_xp_rules (type, xp_per_day) values
  ('porn', 30),
  ('snus', 30),
  ('cigarette', 30),
  ('vape', 25),
  ('weed', 25),
  ('alcohol', 25),
  ('sugar', 15),
  ('custom', 20);
-- @rules:xp_per_day:end

create table private.milestones (
  days int primary key check (days > 0),
  bonus_xp int not null check (bonus_xp >= 0)
);

-- @rules:milestones:begin
insert into private.milestones (days, bonus_xp) values
  (1, 20),
  (3, 50),
  (7, 100),
  (14, 150),
  (30, 300),
  (60, 400),
  (90, 600),
  (180, 1000),
  (365, 2000);
-- @rules:milestones:end

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null check (username ~ '^[A-Za-z0-9_.-]{3,20}$'),
  avatar_emoji text not null default '😎' check (char_length(avatar_emoji) between 1 and 16),
  created_at timestamptz not null default now()
);
create unique index profiles_username_lower_key on public.profiles (lower(username));

create table public.squads (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 40),
  invite_code text not null unique check (invite_code ~ '^[A-Z0-9]{6}$'),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.squad_members (
  squad_id uuid not null references public.squads (id) on delete cascade,
  -- V0: one squad per user.
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'member')),
  joined_at timestamptz not null default now(),
  primary key (squad_id, user_id)
);

create table public.addictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  type text not null check (type in ('porn', 'snus', 'cigarette', 'vape', 'weed', 'alcohol', 'sugar', 'custom')),
  label text not null check (char_length(btrim(label)) between 1 and 40),
  unit_label text not null check (char_length(btrim(unit_label)) between 1 and 30),
  unit_cost numeric(10, 2) not null default 0 check (unit_cost >= 0),
  baseline_per_day numeric(10, 2) not null default 1 check (baseline_per_day >= 0),
  is_private boolean not null default false,
  quit_started_at timestamptz not null default now(),
  streak_started_at timestamptz not null default now(),
  best_streak_seconds bigint not null default 0 check (best_streak_seconds >= 0),
  awarded_clean_days int not null default 0 check (awarded_clean_days >= 0),
  archived_at timestamptz,
  created_at timestamptz not null default now()
);
create index addictions_user_idx on public.addictions (user_id);
create index addictions_active_idx on public.addictions (archived_at) where archived_at is null;

create table public.relapses (
  id uuid primary key default gen_random_uuid(),
  addiction_id uuid not null references public.addictions (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  occurred_at timestamptz not null default now(),
  note text check (note is null or char_length(note) <= 500),
  shared boolean not null default false,
  created_at timestamptz not null default now()
);
create index relapses_addiction_idx on public.relapses (addiction_id);

-- Append-only. XP is never negative: a relapse costs HP only.
create table public.xp_ledger (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  amount_xp int not null default 0 check (amount_xp >= 0),
  amount_hp int not null default 0,
  reason text not null check (reason in ('clean_day', 'milestone', 'relapse')),
  ref_id uuid,
  created_at timestamptz not null default now()
);
create index xp_ledger_user_created_idx on public.xp_ledger (user_id, created_at);

create table public.player_stats (
  user_id uuid primary key references auth.users (id) on delete cascade,
  xp bigint not null default 0 check (xp >= 0),
  level int not null default 1 check (level >= 1),
  hp int not null default 100 check (hp between 0 and 100),
  updated_at timestamptz not null default now()
);

create table public.feed_events (
  id uuid primary key default gen_random_uuid(),
  squad_id uuid not null references public.squads (id) on delete cascade,
  user_id uuid references auth.users (id) on delete set null,
  type text not null check (type in ('joined_squad', 'left_squad', 'milestone', 'level_up', 'relapse')),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index feed_events_squad_created_idx on public.feed_events (squad_id, created_at desc);
