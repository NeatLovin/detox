-- Detox — anti-cheat fixes found in the V0 review.
-- 1. Un-archiving: archiving goes through an RPC, an archived addiction is frozen.
-- 2. Backdated relapse: days already paid are never credited again.
-- 3. Farming: max 6 active addictions per user, of which max 2 'custom'.

-- ---------------------------------------------------------------------------
-- 1. Archive
-- ---------------------------------------------------------------------------

-- The client can no longer write archived_at (otherwise archived_at = null
-- would resume a streak and pay out the whole archived period).
revoke update (archived_at) on public.addictions from authenticated;

create or replace function public.archive_addiction(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_add public.addictions%rowtype;
begin
  select * into v_add from public.addictions where id = p_id for update;
  if not found or v_add.user_id is distinct from auth.uid() then
    raise exception 'addiction_not_found' using errcode = 'P0001';
  end if;
  if v_add.archived_at is not null then
    raise exception 'addiction_archived' using errcode = 'P0001';
  end if;
  update public.addictions set archived_at = now() where id = p_id;
end;
$$;

revoke execute on function public.archive_addiction(uuid) from public, anon;
grant execute on function public.archive_addiction(uuid) to authenticated;

-- An archived addiction is frozen: no update at all, client or server side.
create or replace function private.on_addiction_before_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.archived_at is not null then
    raise exception 'addiction_archived' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger on_addiction_before_update
  before update on public.addictions
  for each row execute function private.on_addiction_before_update();

-- ---------------------------------------------------------------------------
-- 2. Backdated relapse
-- ---------------------------------------------------------------------------

-- Same as V0, except awarded_clean_days after the reset: the days of the old
-- streak already paid beyond the relapse date count as paid in the new streak,
-- so neither those days nor their milestones are credited twice.
-- A day is 24 h of real time (as in award_addiction_days), hence '24 hours'
-- rather than '1 day', which follows wall-clock time across DST changes.
create or replace function private.on_relapse_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_add public.addictions%rowtype;
  v_streak_seconds bigint;
  v_awarded_end timestamptz;
begin
  -- Award the clean days earned before the relapse (the hourly job may lag).
  perform private.award_addiction_days(new.addiction_id, new.occurred_at);

  select * into v_add from public.addictions where id = new.addiction_id for update;
  v_streak_seconds := greatest(0, floor(extract(epoch from (new.occurred_at - v_add.streak_started_at))))::bigint;
  v_awarded_end := v_add.streak_started_at + v_add.awarded_clean_days * interval '24 hours';

  update public.addictions
  set best_streak_seconds = greatest(best_streak_seconds, v_streak_seconds),
      streak_started_at = new.occurred_at,
      awarded_clean_days = greatest(0, floor(extract(epoch from (v_awarded_end - new.occurred_at)) / 86400))::int
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

-- ---------------------------------------------------------------------------
-- 3. Addiction cap
-- ---------------------------------------------------------------------------

-- Mirrored in Dart: lib/features/addictions/domain/addiction_limits.dart
-- Named so it fires after on_addiction_before_insert (triggers fire in name order),
-- once user_id is resolved. Rows inserted earlier by the same multi-row INSERT
-- are visible here, so a batch cannot bypass the cap.
create or replace function private.on_addiction_cap_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_active int;
  v_custom int;
begin
  -- Serialize concurrent inserts of the same user.
  perform pg_advisory_xact_lock(hashtextextended('addictions:' || new.user_id::text, 0));

  select count(*), count(*) filter (where type = 'custom')
  into v_active, v_custom
  from public.addictions
  where user_id = new.user_id and archived_at is null;

  if v_active >= 6 or (new.type = 'custom' and v_custom >= 2) then
    raise exception 'too_many_addictions' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger on_addiction_cap_before_insert
  before insert on public.addictions
  for each row execute function private.on_addiction_cap_before_insert();

revoke all on all functions in schema private from public, anon, authenticated;
