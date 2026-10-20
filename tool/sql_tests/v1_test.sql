-- V1 regression tests (migration 20261020120000_v1.sql): cravings, SOS,
-- daily quests, pledge, badges, motivations, grants and RLS.
-- Run with tool/sql_tests/run.sh. Any failed assertion raises and stops the run.

\o /dev/null
set client_min_messages = notice;

-- Helpers (own schema: other test files may define theirs) ---------------------
create schema t1;
grant usage on schema t1 to authenticated, anon;

create function t1.eq(actual anyelement, expected anyelement, label text)
returns void language plpgsql as $$
begin
  if actual is distinct from expected then
    raise exception 'FAIL %: expected %, got %', label, expected, actual;
  end if;
  raise notice 'ok   %', label;
end;
$$;

create function t1.fails(p_sql text, p_expected text, label text)
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

create function t1.login(p_user uuid) returns void language sql as $$
  select set_config('request.jwt.claim.sub', p_user::text, false);
$$;
grant execute on all functions in schema t1 to authenticated, anon;

-- Server-side readers (bypass RLS: run as the test superuser).
create function t1.xp(p_user uuid) returns bigint language sql security definer as $$
  select xp from public.player_stats where user_id = p_user;
$$;
create function t1.ledger(p_user uuid, p_reason text) returns bigint language sql security definer as $$
  select count(*) from public.xp_ledger where user_id = p_user and reason = p_reason;
$$;
create function t1.has_badge(p_user uuid, p_key text) returns boolean language sql security definer as $$
  select exists (select 1 from public.badges where user_id = p_user and key = p_key);
$$;
create function t1.feed(p_user uuid, p_type text) returns bigint language sql security definer as $$
  select count(*) from public.feed_events where user_id = p_user and type = p_type;
$$;
create function t1.today() returns date language sql security definer as $$
  select private.zurich_today();
$$;
grant execute on all functions in schema t1 to authenticated, anon;

-- Fixtures: A, B, C, D public players, E has a private profile --------------
insert into auth.users (id, email) values
  ('bbbbbbbb-0000-0000-0000-00000000000a', 'a@test'),
  ('bbbbbbbb-0000-0000-0000-00000000000b', 'b@test'),
  ('bbbbbbbb-0000-0000-0000-00000000000c', 'c@test'),
  ('bbbbbbbb-0000-0000-0000-00000000000d', 'd@test'),
  ('bbbbbbbb-0000-0000-0000-00000000000e', 'e@test');
insert into public.profiles (id, username) values
  ('bbbbbbbb-0000-0000-0000-00000000000a', 'v1_alice'),
  ('bbbbbbbb-0000-0000-0000-00000000000b', 'v1_bob'),
  ('bbbbbbbb-0000-0000-0000-00000000000c', 'v1_carl'),
  ('bbbbbbbb-0000-0000-0000-00000000000d', 'v1_dana'),
  ('bbbbbbbb-0000-0000-0000-00000000000e', 'v1_eva');
update public.profiles set is_private = true where id = 'bbbbbbbb-0000-0000-0000-00000000000e';

set role authenticated;
select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
insert into public.addictions (type, label, unit_label) values ('snus', 'Snus', 'sachets');
insert into public.addictions (type, label, unit_label, is_private) values ('porn', 'Porno', 'sessions', true);
reset role;

create table t1.ctx (key text primary key, id uuid);
grant select on t1.ctx to authenticated;
insert into t1.ctx
  select 'a_snus', id from public.addictions
  where user_id = 'bbbbbbbb-0000-0000-0000-00000000000a' and type = 'snus';
insert into t1.ctx
  select 'a_porn', id from public.addictions
  where user_id = 'bbbbbbbb-0000-0000-0000-00000000000a' and type = 'porn';

set role authenticated;
select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
insert into public.addictions (type, label, unit_label) values ('cigarette', 'Clope', 'cigarettes');
select t1.login('bbbbbbbb-0000-0000-0000-00000000000d');
insert into public.addictions (type, label, unit_label) values ('sugar', 'Sucre', 'portions');
reset role;
insert into t1.ctx
  select 'd_sugar', id from public.addictions where user_id = 'bbbbbbbb-0000-0000-0000-00000000000d';
insert into t1.ctx
  select 'b_cig', id from public.addictions where user_id = 'bbbbbbbb-0000-0000-0000-00000000000b';

-- 1. Grants -------------------------------------------------------------------
set role anon;
select t1.fails($$select * from public.cravings$$, '42501', 'anon cannot read cravings');
select t1.fails($$select public.make_pledge()$$, '42501', 'anon cannot pledge');
set role authenticated;
select t1.login('bbbbbbbb-0000-0000-0000-00000000000d');
select t1.fails($$insert into public.badges (user_id, key) values (auth.uid(), 'helper')$$, '42501',
  'client cannot grant itself a badge');
select t1.fails($$insert into public.cravings (addiction_id, intensity, resisted, via_sos)
  values ((select id from t1.ctx where key = 'd_sugar'), 3, true, true)$$, '42501',
  'client cannot flag a craving as SOS (bonus XP)');
select t1.fails($$insert into public.quest_logs (quest_id, user_id, day, value, done)
  values (gen_random_uuid(), auth.uid(), current_date, 1, true)$$, '42501',
  'client cannot write quest logs directly');
select t1.fails($$insert into public.pledges (user_id, day) values (auth.uid(), current_date)$$, '42501',
  'client cannot write pledges directly');

-- 2. Cravings: XP, daily cap, validation, badges -------------------------------
insert into public.cravings (addiction_id, intensity, trigger, resisted)
values ((select id from t1.ctx where key = 'd_sugar'), 4, 'stress', true);
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000d'), 10::bigint, 'resisted craving: +10 XP');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000d', 'first_resist'), true, 'first_resist badge');
select t1.eq((select xp_awarded from public.cravings limit 1), 10, 'craving shows the XP it earned');

insert into public.cravings (addiction_id, intensity, resisted)
values ((select id from t1.ctx where key = 'd_sugar'), 2, false);
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000d'), 10::bigint, 'craving not resisted: no XP');

insert into public.cravings (addiction_id, intensity, resisted)
select (select id from t1.ctx where key = 'd_sugar'), 3, true from generate_series(1, 3);
select t1.eq(t1.ledger('bbbbbbbb-0000-0000-0000-00000000000d', 'craving'), 3::bigint,
  'craving XP capped at 3 per day');
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000d'), 30::bigint, 'capped cravings earn nothing more');

insert into public.cravings (addiction_id, intensity, resisted)
select (select id from t1.ctx where key = 'd_sugar'), 3, true from generate_series(1, 6);
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000d', 'resist_10'), true,
  'resist_10 badge (counts resisted cravings, not XP)');

select t1.fails($$insert into public.cravings (addiction_id, intensity, resisted)
  values ((select id from t1.ctx where key = 'a_snus'), 3, true)$$, 'addiction_not_found',
  'cannot log a craving on someone else''s addiction');
select t1.fails($$insert into public.cravings (addiction_id, intensity, resisted, occurred_at)
  values ((select id from t1.ctx where key = 'd_sugar'), 3, true, now() + interval '1 hour')$$,
  'craving_in_future', 'craving in the future refused');
select t1.fails($$insert into public.cravings (addiction_id, intensity, resisted, occurred_at)
  values ((select id from t1.ctx where key = 'd_sugar'), 3, true, now() - interval '8 days')$$,
  'craving_too_old', 'craving older than 7 days refused');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
select t1.eq((select count(*) from public.cravings), 0::bigint, 'cravings are owner-only (RLS)');

-- 3. SOS ------------------------------------------------------------------------
select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
reset role;
create table t1.sos (id uuid);
grant all on t1.sos to authenticated;
set role authenticated;
insert into t1.sos select public.start_sos((select id from t1.ctx where key = 'a_porn'));
select t1.eq(public.start_sos((select id from t1.ctx where key = 'a_porn')), (select id from t1.sos),
  'start_sos is idempotent for an open alert');
select t1.eq(t1.feed('bbbbbbbb-0000-0000-0000-00000000000a', 'sos'), 1::bigint, 'SOS announced once');
reset role;
select t1.eq((select payload->>'addiction_label' from public.feed_events where type = 'sos'),
  'une addiction privée', 'SOS on a private addiction never leaks its label');
select t1.eq((select addiction_label from public.sos_alerts), 'une addiction privée',
  'stored SOS label is masked too');

set role authenticated;
select t1.fails($$select public.support_sos((select id from t1.sos), '💪')$$, 'sos_own_alert',
  'cannot support your own SOS');
select t1.fails($$select public.start_sos((select id from t1.ctx where key = 'b_cig'))$$,
  'addiction_not_found', 'cannot start an SOS on someone else''s addiction');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
select t1.eq((select count(*) from public.sos_alerts), 1::bigint, 'another player sees a public player''s SOS');
select public.support_sos((select id from t1.sos), '💪');
select public.support_sos((select id from t1.sos), '🔥');
select t1.eq((select count(*) from public.sos_supports), 1::bigint, 'one support per player per alert');
select t1.eq(t1.ledger('bbbbbbbb-0000-0000-0000-00000000000b', 'sos_support'), 1::bigint, 'supporter earns XP once');
select t1.eq(t1.feed('bbbbbbbb-0000-0000-0000-00000000000b', 'sos_support'), 1::bigint, 'support announced');
select t1.fails($$select public.support_sos((select id from t1.sos), '🍺')$$, '23514',
  'only allowed emojis');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000c');
select t1.eq((select count(*) from public.sos_alerts), 1::bigint, 'everyone sees a public SOS');
select t1.eq((select count(*) from public.sos_supports), 1::bigint, 'everyone sees its supports');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
select t1.fails($$select public.resolve_sos((select id from t1.sos), true)$$, 'sos_not_found',
  'only the owner resolves an SOS');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
select public.resolve_sos((select id from t1.sos), true, 5, 'screen');
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000a'), 15::bigint, 'craving resisted via SOS: +15 XP');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000a', 'sos_first'), true, 'sos_first badge');
select t1.eq((select via_sos from public.cravings), true, 'SOS outcome logged as a craving');
select t1.eq(t1.feed('bbbbbbbb-0000-0000-0000-00000000000a', 'sos_resolved'), 1::bigint, 'victory announced');
select t1.fails($$select public.resolve_sos((select id from t1.sos), true)$$, 'sos_already_resolved',
  'an SOS is resolved once');

insert into t1.sos select public.start_sos((select id from t1.ctx where key = 'a_snus'));
reset role;
select t1.eq((select count(*) from public.sos_alerts where resolved_at is null), 1::bigint,
  'a new SOS opens after the previous one is resolved');
set role authenticated;
select public.resolve_sos((select a.id from public.sos_alerts a where a.resolved_at is null), false);
select t1.eq(t1.feed('bbbbbbbb-0000-0000-0000-00000000000a', 'sos_resolved'), 1::bigint,
  'a relapse after SOS is never announced automatically');

-- 4. Quests -------------------------------------------------------------------
select t1.login('bbbbbbbb-0000-0000-0000-00000000000c');
insert into public.daily_quests (type, label, unit_label, target) values
  ('water', 'Eau', 'verres', 8),
  ('sport', 'Sport', 'min', 30),
  ('sleep', 'Sommeil', 'h', 7.5);
reset role;
insert into t1.ctx select 'c_' || type, id from public.daily_quests
  where user_id = 'bbbbbbbb-0000-0000-0000-00000000000c';
set role authenticated;

select public.log_quest((select id from t1.ctx where key = 'c_water'), 4);
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000c'), 0::bigint, 'partial quest: no XP');
select public.log_quest((select id from t1.ctx where key = 'c_water'), 8);
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000c'), 10::bigint, 'quest done: +10 XP');
select public.log_quest((select id from t1.ctx where key = 'c_water'), 3);
select public.log_quest((select id from t1.ctx where key = 'c_water'), 9);
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000c'), 10::bigint,
  'undo/redo a quest earns nothing more');
select t1.eq((select done from public.quest_logs where quest_id = (select id from t1.ctx where key = 'c_water')),
  true, 'done is computed server-side');

select t1.fails($$select public.log_quest((select id from t1.ctx where key = 'c_water'), 1, t1.today() - 2)$$,
  'quest_day_out_of_range', 'cannot log two days back');
select t1.fails($$select public.log_quest((select id from t1.ctx where key = 'c_water'), 1, t1.today() + 1)$$,
  'quest_day_out_of_range', 'cannot log the future');
select t1.fails($$select public.log_quest((select id from t1.ctx where key = 'c_water'), -1)$$,
  'quest_invalid_value', 'negative value refused');

select public.log_quest((select id from t1.ctx where key = 'c_sport'), 45);
select t1.eq(t1.ledger('bbbbbbbb-0000-0000-0000-00000000000c', 'quests_all_done'), 0::bigint,
  'no bonus while a quest is left');
select public.log_quest((select id from t1.ctx where key = 'c_sleep'), 8);
select t1.eq(t1.ledger('bbbbbbbb-0000-0000-0000-00000000000c', 'quests_all_done'), 1::bigint,
  'all 3 quests done: bonus');
select t1.eq(t1.xp('bbbbbbbb-0000-0000-0000-00000000000c'), 50::bigint, '3 quests + bonus = 50 XP');
select t1.eq(t1.feed('bbbbbbbb-0000-0000-0000-00000000000c', 'quests_all_done'), 1::bigint,
  'all-done announced in the global feed');

select public.log_quest((select id from t1.ctx where key = 'c_water'), 0);
select public.log_quest((select id from t1.ctx where key = 'c_water'), 8);
select t1.eq(t1.ledger('bbbbbbbb-0000-0000-0000-00000000000c', 'quests_all_done'), 1::bigint,
  'the all-done bonus is paid once per day');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
select t1.fails($$select public.log_quest((select id from t1.ctx where key = 'c_water'), 8)$$,
  'quest_not_found', 'cannot log someone else''s quest');
select t1.eq((select count(*) from public.daily_quests), 0::bigint, 'quests are owner-only (RLS)');

select t1.login('bbbbbbbb-0000-0000-0000-00000000000c');
insert into public.daily_quests (type, label, unit_label, target)
select 'custom', 'Q' || g, 'fois', 1 from generate_series(1, 5) g;
select t1.fails($$insert into public.daily_quests (type, label, unit_label, target)
  values ('custom', 'Q9', 'fois', 1)$$, 'too_many_quests', '9th active quest refused');
update public.daily_quests set archived_at = now() where label = 'Q5';
insert into public.daily_quests (type, label, unit_label, target) values ('custom', 'Q6', 'fois', 1);
select t1.fails($$update public.daily_quests set archived_at = null where label = 'Q5'$$,
  'too_many_quests', 'un-archiving cannot bypass the cap');

-- Quest streak badge: 6 previous done days, then today.
reset role;
insert into public.quest_logs (quest_id, user_id, day, value, done)
select (select id from t1.ctx where key = 'c_sport'), 'bbbbbbbb-0000-0000-0000-00000000000c', t1.today() - g, 30, true
from generate_series(1, 6) g;
set role authenticated;
select public.log_quest((select id from t1.ctx where key = 'c_sport'), 30);
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000c', 'quest_streak_7'), true,
  'quest_streak_7 badge after 7 days in a row');

-- 5. Pledge -------------------------------------------------------------------
select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
select t1.eq(public.make_pledge(), true, 'first pledge of the day');
select t1.eq(public.make_pledge(), false, 'second pledge the same day is a no-op');
select t1.eq(t1.ledger('bbbbbbbb-0000-0000-0000-00000000000b', 'pledge'), 1::bigint, 'pledge XP once a day');
select t1.eq(t1.feed('bbbbbbbb-0000-0000-0000-00000000000b', 'pledge'), 1::bigint, 'pledge announced once');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000b', 'first_pledge'), true, 'first_pledge badge');

reset role;
insert into public.pledges (user_id, day)
select 'bbbbbbbb-0000-0000-0000-00000000000e', t1.today() - g from generate_series(1, 6) g;
set role authenticated;
select t1.login('bbbbbbbb-0000-0000-0000-00000000000e');
select public.make_pledge();
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000e', 'pledge_streak_7'), true,
  'pledge_streak_7 badge after 7 days in a row');

-- 6. Streak, comeback and level badges ----------------------------------------
reset role;
insert into public.xp_ledger (user_id, amount_xp, reason, ref_id)
values ('bbbbbbbb-0000-0000-0000-00000000000b', 100, 'milestone', (select id from t1.ctx where key = 'b_cig'));
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000b', 'streak_7'), true, 'streak_7 badge on the J7 milestone');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000b', 'comeback'), false, 'no comeback without a relapse');

set role authenticated;
select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
insert into public.relapses (addiction_id) values ((select id from t1.ctx where key = 'b_cig'));
reset role;
insert into public.xp_ledger (user_id, amount_xp, reason, ref_id)
values ('bbbbbbbb-0000-0000-0000-00000000000b', 300, 'milestone', (select id from t1.ctx where key = 'b_cig'));
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000b', 'streak_30'), true, 'streak_30 badge');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000b', 'comeback'), true, 'comeback badge: 30 days after a relapse');

insert into public.xp_ledger (user_id, amount_xp, reason)
values ('bbbbbbbb-0000-0000-0000-00000000000e', 1000, 'clean_day');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000e', 'level_5'), true, 'level_5 badge at 1000 XP');
select t1.eq(t1.has_badge('bbbbbbbb-0000-0000-0000-00000000000e', 'level_10'), false, 'no level_10 yet');

-- Badges: public players' badges are visible, a private player's are not.
set role authenticated;
select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
select t1.eq((select count(*) > 0 from public.badges where user_id = 'bbbbbbbb-0000-0000-0000-00000000000b'),
  true, 'anyone sees a public player''s badges');
select t1.eq((select count(*) from public.badges where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  0::bigint, 'a private player''s badges are hidden');
select t1.login('bbbbbbbb-0000-0000-0000-00000000000e');
select t1.eq((select count(*) > 0 from public.badges where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  true, 'a private player sees their own badges');

-- 6b. Community: leaderboard, player profiles, global feed ---------------------
select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
select t1.eq((select count(*) from public.leaderboard()
  where user_id::text like 'bbbbbbbb-%'), 5::bigint, 'leaderboard lists every player, private ones included');
select t1.eq((select is_private from public.leaderboard() where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  true, 'leaderboard flags private players');
select t1.eq((select username from public.leaderboard() order by rank limit 1), 'v1_eva',
  'leaderboard is ordered by total XP');
select t1.eq((select rank from public.leaderboard() where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  1::bigint, 'rank 1 for the top XP');

select t1.eq((public.player_profile('bbbbbbbb-0000-0000-0000-00000000000b')->>'username'), 'v1_bob',
  'a public profile opens');
select t1.eq((jsonb_array_length(public.player_profile('bbbbbbbb-0000-0000-0000-00000000000b')->'badges') > 0),
  true, 'public profile shows badges');
select t1.eq((select count(*) from jsonb_array_elements(
  public.player_profile('bbbbbbbb-0000-0000-0000-00000000000a')->'addictions')), 1::bigint,
  'public profile hides private addictions');
select t1.eq((public.player_profile('bbbbbbbb-0000-0000-0000-00000000000a')->'addictions'->0->>'label'), 'Snus',
  'public profile shows non-private addictions');
select t1.fails($$select public.player_profile('bbbbbbbb-0000-0000-0000-00000000000e')$$, 'profile_private',
  'a private profile does not open for others');
select t1.fails($$select public.player_profile(gen_random_uuid())$$, 'player_not_found',
  'unknown player');

select t1.eq((select count(*) from public.feed_events where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  0::bigint, 'a private player''s events are hidden from others');
select t1.eq((select count(*) > 0 from public.feed_events where user_id = 'bbbbbbbb-0000-0000-0000-00000000000b'),
  true, 'public events are in the global feed');
select t1.eq((select count(*) from public.feed_events
  where type = 'joined' and user_id = 'bbbbbbbb-0000-0000-0000-00000000000d'), 1::bigint,
  'a new player is announced');
select t1.login('bbbbbbbb-0000-0000-0000-00000000000e');
select t1.eq((public.player_profile('bbbbbbbb-0000-0000-0000-00000000000e')->>'username'), 'v1_eva',
  'a private player opens their own profile');
select t1.eq((select count(*) > 0 from public.feed_events where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  true, 'a private player sees their own events');

-- A private player's SOS is not shown to others.
insert into public.addictions (type, label, unit_label) values ('vape', 'Vape', 'sessions');
insert into t1.sos select public.start_sos((select id from public.addictions where type = 'vape'));
select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
select t1.eq((select count(*) from public.sos_alerts where user_id = 'bbbbbbbb-0000-0000-0000-00000000000e'),
  0::bigint, 'a private player''s SOS is hidden');
select t1.fails($$select public.support_sos(
    (select id from t1.sos where id not in (select id from public.sos_alerts)), '💪')$$,
  'sos_not_found', 'a private player''s SOS cannot be supported');

-- Client can set its own privacy flag, nothing else changes hands.
select t1.login('bbbbbbbb-0000-0000-0000-00000000000d');
update public.profiles set is_private = true where id = auth.uid();
update public.profiles set is_private = true where id = 'bbbbbbbb-0000-0000-0000-00000000000b';
reset role;
select t1.eq((select is_private from public.profiles where id = 'bbbbbbbb-0000-0000-0000-00000000000d'),
  true, 'a player can make their profile private');
select t1.eq((select is_private from public.profiles where id = 'bbbbbbbb-0000-0000-0000-00000000000b'),
  false, 'a player cannot change someone else''s privacy');
set role authenticated;

-- 7. Motivations ----------------------------------------------------------------
select t1.login('bbbbbbbb-0000-0000-0000-00000000000a');
insert into public.motivations (text) select 'Raison ' || g from generate_series(1, 5) g;
select t1.fails($$insert into public.motivations (text) values ('Raison 6')$$, 'too_many_motivations',
  '6th motivation refused');
select t1.login('bbbbbbbb-0000-0000-0000-00000000000b');
select t1.eq((select count(*) from public.motivations), 0::bigint, 'motivations are owner-only (RLS)');

reset role;
