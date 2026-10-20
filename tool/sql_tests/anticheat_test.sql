-- Anti-cheat regression tests (migration 20261020100000_anticheat.sql).
-- Run with tool/sql_tests/run.sh. Any failed assertion raises and stops the run.

-- Query results are discarded: only the `ok` notices and failures are shown.
\o /dev/null
set client_min_messages = notice;

-- Helpers ---------------------------------------------------------------------
create schema tests;
grant usage on schema tests to authenticated;

create function tests.eq(actual anyelement, expected anyelement, label text)
returns void language plpgsql as $$
begin
  if actual is distinct from expected then
    raise exception 'FAIL %: expected %, got %', label, expected, actual;
  end if;
  raise notice 'ok   %', label;
end;
$$;

-- Runs p_sql and expects it to fail with p_expected (an SQLSTATE or a message).
create function tests.fails(p_sql text, p_expected text, label text)
returns void language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    if sqlstate = p_expected or sqlerrm = p_expected then
      raise notice 'ok   %', label;
      return;
    end if;
    raise exception 'FAIL %: expected error %, got % (%)', label, p_expected, sqlstate, sqlerrm;
  end;
  raise exception 'FAIL %: expected error %, but it succeeded', label, p_expected;
end;
$$;
grant execute on all functions in schema tests to authenticated;

create function tests.login(p_user uuid) returns void language sql as $$
  select set_config('request.jwt.claim.sub', p_user::text, false);
$$;
grant execute on function tests.login(uuid) to authenticated;

-- Back to server-side context (no JWT): auth.uid() is null.
create function tests.logout() returns void language sql as $$
  select set_config('request.jwt.claim.sub', '', false);
$$;

create function tests.xp(p_user uuid) returns bigint language sql as $$
  select xp from public.player_stats where user_id = p_user;
$$;

create function tests.ledger_count(p_user uuid, p_reason text) returns bigint language sql as $$
  select count(*) from public.xp_ledger where user_id = p_user and reason = p_reason;
$$;

insert into auth.users (id, email) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'archive@test'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'other@test'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'backdate@test'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'cap@test'),
  ('aaaaaaaa-0000-0000-0000-000000000005', 'custom@test'),
  ('aaaaaaaa-0000-0000-0000-000000000006', 'batch@test'),
  ('aaaaaaaa-0000-0000-0000-000000000007', 'fraction@test');

-- 1. Un-archiving -------------------------------------------------------------
set role authenticated;
select tests.login('aaaaaaaa-0000-0000-0000-000000000001');
insert into public.addictions (type, label, unit_label, quit_started_at)
values ('snus', 'Snus', 'sachets', now() - interval '20 days');
select public.archive_addiction(id) from public.addictions;
select tests.eq((select archived_at is not null from public.addictions), true,
  'archive_addiction sets archived_at');
select tests.fails($$update public.addictions set archived_at = null$$, '42501',
  'client cannot un-archive with a direct UPDATE');
select tests.fails($$update public.addictions set label = 'Snus 2'$$, 'addiction_archived',
  'an archived addiction is frozen (other columns too)');
select tests.fails($$select public.archive_addiction(id) from public.addictions$$, 'addiction_archived',
  'archiving twice is refused');
select tests.fails($$insert into public.relapses (addiction_id) select id from public.addictions$$,
  'addiction_archived', 'no relapse on an archived addiction');

select tests.login('aaaaaaaa-0000-0000-0000-000000000002');
reset role;
select tests.logout();
select id as archived_id from public.addictions
where user_id = 'aaaaaaaa-0000-0000-0000-000000000001' \gset
set role authenticated;
select tests.fails(format('select public.archive_addiction(%L)', :'archived_id'), 'addiction_not_found',
  'cannot archive somebody else''s addiction');
reset role;
select tests.logout();
select tests.fails(format('update public.addictions set archived_at = null where id = %L', :'archived_id'),
  'addiction_archived', 'even server-side code cannot un-archive');
select tests.eq(has_function_privilege('anon', 'public.archive_addiction(uuid)', 'execute'), false,
  'anon cannot call archive_addiction');

-- 2. Backdated relapse --------------------------------------------------------
-- 10 clean days credited, then a relapse dated at day 7.
insert into public.addictions (user_id, type, label, unit_label, quit_started_at)
values ('aaaaaaaa-0000-0000-0000-000000000003', 'snus', 'Snus', 'sachets', now() - interval '10 days');
update public.addictions set awarded_clean_days = 0
where user_id = 'aaaaaaaa-0000-0000-0000-000000000003';
select private.award_clean_days();
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000003', 'clean_day'), 10::bigint,
  '10 clean days credited');
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000003'), (10 * 30 + 20 + 50 + 100)::bigint,
  'XP = 10 days + milestones 1, 3, 7');
select id as backdate_id, streak_started_at as backdate_start from public.addictions
where user_id = 'aaaaaaaa-0000-0000-0000-000000000003' \gset

set role authenticated;
select tests.login('aaaaaaaa-0000-0000-0000-000000000003');
insert into public.relapses (addiction_id, occurred_at)
values (:'backdate_id', :'backdate_start'::timestamptz + interval '7 days');
reset role;
select tests.logout();

select tests.eq((select awarded_clean_days from public.addictions where id = :'backdate_id'), 3,
  'days 8-10 already paid are carried into the new streak');
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000003'), 470::bigint,
  'a relapse never removes XP');

select private.award_clean_days();
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000003'), 470::bigint,
  'next job right after the relapse credits 0 XP');

-- Simulate time passing by moving the streak start back (now() cannot be faked).
-- Day 10 was reached "now": 23 h 59 later nothing more is due…
update public.addictions set streak_started_at = streak_started_at - interval '23 hours 59 minutes'
where id = :'backdate_id';
select private.award_clean_days();
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000003'), 470::bigint,
  '23 h 59 after day 10: still 0 XP');

-- …and 24 h after day 10, exactly one more clean day.
update public.addictions set streak_started_at = streak_started_at - interval '2 minutes'
where id = :'backdate_id';
select private.award_clean_days();
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000003'), 500::bigint,
  '24 h after day 10: one more day (+30 XP)');
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000003', 'clean_day'), 11::bigint,
  '11 clean days in total');
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000003', 'milestone'), 3::bigint,
  'milestones 1 and 3 are not paid twice');

-- A relapse right at the streak start (nothing paid beyond it) still resets to 0.
set role authenticated;
select tests.login('aaaaaaaa-0000-0000-0000-000000000003');
insert into public.relapses (addiction_id, occurred_at) values (:'backdate_id', now());
reset role;
select tests.logout();
select tests.eq((select awarded_clean_days from public.addictions where id = :'backdate_id'), 0,
  'relapse now: awarded_clean_days back to 0');

-- Relapse at a fraction of a day (migration 20261020110000_relapse_ceil.sql):
-- 14 days paid, relapse at day 0.5. ceil(13.5) = 14 days are carried over, so
-- neither day 14 nor its milestone can be paid again.
insert into public.addictions (user_id, type, label, unit_label, quit_started_at)
values ('aaaaaaaa-0000-0000-0000-000000000007', 'snus', 'Snus', 'sachets', now() - interval '14 days');
update public.addictions set awarded_clean_days = 0
where user_id = 'aaaaaaaa-0000-0000-0000-000000000007';
select private.award_clean_days();
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000007'), (14 * 30 + 20 + 50 + 100 + 150)::bigint,
  'fraction: 14 days + milestones 1, 3, 7, 14 credited');
select id as fraction_id, streak_started_at as fraction_start from public.addictions
where user_id = 'aaaaaaaa-0000-0000-0000-000000000007' \gset

set role authenticated;
select tests.login('aaaaaaaa-0000-0000-0000-000000000007');
insert into public.relapses (addiction_id, occurred_at)
values (:'fraction_id', :'fraction_start'::timestamptz + interval '12 hours');
reset role;
select tests.logout();

select tests.eq((select awarded_clean_days from public.addictions where id = :'fraction_id'), 14,
  'fraction: ceil(13.5) = 14 paid days carried over');
select private.award_clean_days();
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000007', 'clean_day'), 14::bigint,
  'fraction: no clean day right after the relapse');

-- "Now" is day 14 of the old streak. Move time to day 15.5 minus 1 minute…
update public.addictions set streak_started_at = streak_started_at - interval '1 day 11 hours 59 minutes'
where id = :'fraction_id';
select private.award_clean_days();
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000007', 'clean_day'), 14::bigint,
  'fraction: still no clean day just before day 15.5');
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000007', 'milestone'), 4::bigint,
  'fraction: milestone 14 not paid again before day 15.5');

-- …then past day 15.5 (day 15 of the new streak): exactly one more clean day.
update public.addictions set streak_started_at = streak_started_at - interval '2 minutes'
where id = :'fraction_id';
select private.award_clean_days();
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000007', 'clean_day'), 15::bigint,
  'fraction: day 15 of the new streak credited at day 15.5');
select tests.eq(tests.ledger_count('aaaaaaaa-0000-0000-0000-000000000007', 'milestone'), 4::bigint,
  'fraction: milestone 14 is never paid twice');
select tests.eq(tests.xp('aaaaaaaa-0000-0000-0000-000000000007'), (740 + 30)::bigint,
  'fraction: XP = 740 + one day');

-- 3. Addiction cap ------------------------------------------------------------
set role authenticated;
select tests.login('aaaaaaaa-0000-0000-0000-000000000004');
insert into public.addictions (type, label, unit_label) values
  ('porn', 'Porno', 'sessions'),
  ('snus', 'Snus', 'sachets'),
  ('cigarette', 'Cigarette', 'cigarettes'),
  ('vape', 'Vape', 'sessions'),
  ('weed', 'Beuh', 'joints'),
  ('custom', 'Café', 'tasses');
select tests.eq((select count(*) from public.addictions), 6::bigint, '6 active addictions allowed');
select tests.fails($$insert into public.addictions (type, label, unit_label) values ('sugar', 'Sucre', 'portions')$$,
  'too_many_addictions', 'the 7th active addiction is refused');
select public.archive_addiction(id) from public.addictions where type = 'porn';
insert into public.addictions (type, label, unit_label) values ('sugar', 'Sucre', 'portions');
select tests.eq((select count(*) from public.addictions where archived_at is null), 6::bigint,
  'archiving one frees a slot');

select tests.login('aaaaaaaa-0000-0000-0000-000000000005');
insert into public.addictions (type, label, unit_label) values
  ('custom', 'Café', 'tasses'),
  ('custom', 'TikTok', 'heures');
select tests.fails($$insert into public.addictions (type, label, unit_label) values ('custom', 'Jeux', 'heures')$$,
  'too_many_addictions', 'the 3rd custom addiction is refused');
insert into public.addictions (type, label, unit_label) values ('alcohol', 'Alcool', 'verres');
select tests.eq((select count(*) from public.addictions), 3::bigint, 'non-custom still allowed');

select tests.login('aaaaaaaa-0000-0000-0000-000000000006');
select tests.fails($$insert into public.addictions (type, label, unit_label) values
  ('porn', 'a', 'u'), ('snus', 'b', 'u'), ('cigarette', 'c', 'u'), ('vape', 'd', 'u'),
  ('weed', 'e', 'u'), ('alcohol', 'f', 'u'), ('sugar', 'g', 'u')$$,
  'too_many_addictions', 'a single 7-row INSERT cannot bypass the cap');
select tests.eq((select count(*) from public.addictions), 0::bigint, 'the whole batch is rolled back');
reset role;
select tests.logout();
