-- Social tests (migration 20261021140000_social.sql): weekly leaderboard and
-- winner, feed reactions, crash reports.

\o /dev/null
set client_min_messages = notice;

create schema t4;
grant usage on schema t4 to authenticated, anon;

create function t4.eq(actual anyelement, expected anyelement, label text)
returns void language plpgsql as $$
begin
  if actual is distinct from expected then
    raise exception 'FAIL %: expected %, got %', label, expected, actual;
  end if;
  raise notice 'ok   %', label;
end;
$$;

create function t4.fails(p_sql text, p_expected text, label text)
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

create function t4.login(p_user uuid) returns void language sql as $$
  select set_config('request.jwt.claim.sub', p_user::text, false);
$$;

create function t4.week_rows(p_user uuid) returns bigint language sql security definer as $$
  select count(*) from public.feed_events where type = 'week_winner' and user_id = p_user;
$$;
create function t4.errors(p_user uuid) returns bigint language sql security definer as $$
  select coalesce(sum(count), 0)::bigint from private.client_errors where user_id = p_user;
$$;
create function t4.error_kinds(p_user uuid) returns bigint language sql security definer as $$
  select count(*) from private.client_errors where user_id = p_user;
$$;
grant execute on all functions in schema t4 to authenticated, anon;

create table t4.ids (key text primary key, id uuid);
grant select on t4.ids to authenticated;

-- Fixtures: A, B public; C private; D public without XP.
insert into auth.users (id, email) values
  ('eeeeeeee-0000-0000-0000-00000000000a', 'wa@test'),
  ('eeeeeeee-0000-0000-0000-00000000000b', 'wb@test'),
  ('eeeeeeee-0000-0000-0000-00000000000c', 'wc@test'),
  ('eeeeeeee-0000-0000-0000-00000000000d', 'wd@test');
insert into public.profiles (id, username, is_private) values
  ('eeeeeeee-0000-0000-0000-00000000000a', 'week_a', false),
  ('eeeeeeee-0000-0000-0000-00000000000b', 'week_b', false),
  ('eeeeeeee-0000-0000-0000-00000000000c', 'week_c', true),
  ('eeeeeeee-0000-0000-0000-00000000000d', 'week_d', false);

-- Last week: B wins (300) ahead of A (200). This week: A 120, C 90, B 40.
insert into public.xp_ledger (user_id, amount_xp, reason, created_at) values
  ('eeeeeeee-0000-0000-0000-00000000000a', 200, 'clean_day', private.zurich_week_start() - interval '3 days'),
  ('eeeeeeee-0000-0000-0000-00000000000b', 300, 'clean_day', private.zurich_week_start() - interval '2 days'),
  ('eeeeeeee-0000-0000-0000-00000000000a', 120, 'clean_day', private.zurich_week_start() + interval '1 minute'),
  ('eeeeeeee-0000-0000-0000-00000000000c',  90, 'clean_day', private.zurich_week_start() + interval '2 minutes'),
  ('eeeeeeee-0000-0000-0000-00000000000b',  40, 'clean_day', private.zurich_week_start() + interval '3 minutes');

-- 1. Week boundaries -------------------------------------------------------------
select t4.eq(extract(isodow from private.zurich_week_start() at time zone 'Europe/Zurich')::int, 1,
  'the week starts on a Monday (Zurich)');
select t4.eq((private.zurich_week_start() at time zone 'Europe/Zurich')::time, '00:00'::time,
  'the week starts at midnight (Zurich)');
select t4.eq(private.zurich_week_start('2026-10-25 22:30:00+00'), '2026-10-19 00:00:00+02'::timestamptz,
  'Sunday 23:30 Zurich (winter time) still belongs to the summer-time week');
select t4.eq(private.zurich_week_start('2026-10-25 23:30:00+00'), '2026-10-26 00:00:00+01'::timestamptz,
  'Monday 00:30 Zurich opens a new week');

-- 2. Weekly leaderboard ----------------------------------------------------------
set role anon;
select t4.fails($$select * from public.leaderboard_week()$$, '42501', 'anon cannot read the weekly leaderboard');
set role authenticated;
select t4.login('eeeeeeee-0000-0000-0000-00000000000d');
select t4.eq((select xp from public.leaderboard_week() where username = 'week_a'), 120::bigint,
  'weekly XP only counts this week');
select t4.eq((select rank from public.leaderboard_week() where username = 'week_a'), 1::bigint, 'A leads the week');
select t4.eq((select rank from public.leaderboard_week() where username = 'week_c'), 2::bigint,
  'private players are ranked too');
select t4.eq((select is_private from public.leaderboard_week() where username = 'week_c'), true,
  'and flagged private');
select t4.eq((select rank from public.leaderboard_week() where username = 'week_b'), 3::bigint,
  'B is third this week despite the best total');
select t4.eq((select xp from public.leaderboard_week() where username = 'week_d'), 0::bigint,
  'a player without XP this week shows 0');
select t4.eq((select rank from public.leaderboard() where username = 'week_b'), 1::bigint,
  'the all-time leaderboard is unchanged');
reset role;

-- 3. Weekly winner ---------------------------------------------------------------
set role authenticated;
select t4.login('eeeeeeee-0000-0000-0000-00000000000b');
select public.register_push_token('token-week-b-' || repeat('b', 30));
reset role;

select private.announce_week_winner();
select t4.eq(t4.week_rows('eeeeeeee-0000-0000-0000-00000000000b'), 1::bigint, 'last week''s winner is announced');
select t4.eq(t4.week_rows('eeeeeeee-0000-0000-0000-00000000000a'), 0::bigint, 'the runner-up is not');
select t4.eq((select (payload ->> 'xp')::int from public.feed_events where type = 'week_winner'), 300,
  'the announcement carries the winning XP');
select t4.eq((select count(*) from private.push_log where kind = 'week_winner'
  and 'eeeeeeee-0000-0000-0000-00000000000b' = any (user_ids)), 1::bigint, 'the winner gets a push');
select private.announce_week_winner();
select t4.eq((select count(*) from public.feed_events where type = 'week_winner'), 1::bigint,
  'a week is announced only once');

-- A tie shares the title; a week without XP announces nobody.
delete from private.week_winners;
delete from public.feed_events where type = 'week_winner';
insert into public.xp_ledger (user_id, amount_xp, reason, created_at) values
  ('eeeeeeee-0000-0000-0000-00000000000a', 100, 'clean_day', private.zurich_week_start() - interval '1 day');
select private.announce_week_winner();
select t4.eq((select count(*) from public.feed_events where type = 'week_winner'), 2::bigint, 'a tie crowns both');
select t4.eq((select (payload ->> 'tie')::boolean from public.feed_events
  where type = 'week_winner' limit 1), true, 'and says it is a tie');

delete from private.week_winners;
delete from public.feed_events where type = 'week_winner';
delete from public.xp_ledger where created_at < private.zurich_week_start();
select private.announce_week_winner();
select t4.eq((select count(*) from public.feed_events where type = 'week_winner'), 0::bigint,
  'a week without XP has no winner');
select t4.eq((select count(*) from private.week_winners), 1::bigint, 'but is marked as handled');

-- 4. Feed reactions --------------------------------------------------------------
insert into t4.ids select 'a_joined', id from public.feed_events
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000a' and type = 'joined';
insert into t4.ids select 'c_joined', id from public.feed_events
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000c' and type = 'joined';
insert into public.feed_events (user_id, type, payload)
  values ('eeeeeeee-0000-0000-0000-00000000000a', 'sos', '{"username": "week_a"}');
insert into t4.ids select 'a_sos', id from public.feed_events
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000a' and type = 'sos';

set role anon;
select t4.fails($$select public.react_feed((select id from t4.ids where key = 'a_joined'), '🔥')$$, '42501',
  'anon cannot react');
set role authenticated;
select t4.login('eeeeeeee-0000-0000-0000-00000000000b');
select t4.eq(public.react_feed((select id from t4.ids where key = 'a_joined'), '🔥'), '🔥', 'B reacts 🔥');
select t4.eq(public.react_feed((select id from t4.ids where key = 'a_joined'), '🔥'), null::text,
  'the same emoji again removes it');
select t4.eq(public.react_feed((select id from t4.ids where key = 'a_joined'), '👏'), '👏', 'B reacts 👏');
select t4.eq(public.react_feed((select id from t4.ids where key = 'a_joined'), '❤️'), '❤️', 'another emoji replaces it');
select t4.eq((select count(*) from public.feed_reactions
  where event_id = (select id from t4.ids where key = 'a_joined')), 1::bigint, 'one reaction per player and event');
select t4.fails($$select public.react_feed((select id from t4.ids where key = 'a_joined'), '💩')$$,
  'invalid_reaction', 'only the five reactions are allowed');
select t4.fails($$select public.react_feed((select id from t4.ids where key = 'c_joined'), '🔥')$$,
  'event_not_found', 'a private player''s event cannot be reacted to');
select t4.fails($$select public.react_feed(gen_random_uuid(), '🔥')$$, 'event_not_found', 'unknown event');
select t4.fails($$select public.react_feed((select id from t4.ids where key = 'a_sos'), '😂')$$,
  'invalid_reaction', 'an SOS only takes supportive reactions');
select t4.eq(public.react_feed((select id from t4.ids where key = 'a_sos'), '💪'), '💪', 'like 💪');
select t4.fails($$insert into public.feed_reactions (event_id, emoji) values ((select id from t4.ids where key = 'a_joined'), '🔥')$$,
  '42501', 'reactions are written only through react_feed');

select t4.login('eeeeeeee-0000-0000-0000-00000000000a');
select t4.fails($$select public.react_feed((select id from t4.ids where key = 'a_joined'), '🔥')$$,
  'own_event', 'nobody reacts to their own event');
select t4.eq((select emoji from public.feed_reactions
  where event_id = (select id from t4.ids where key = 'a_joined')), '❤️', 'A sees B''s reaction on their event');

select t4.login('eeeeeeee-0000-0000-0000-00000000000c');
select t4.eq(public.react_feed((select id from t4.ids where key = 'a_joined'), '💪'), '💪',
  'a private player can react');
select t4.eq((select count(*) from public.feed_reactions
  where event_id = (select id from t4.ids where key = 'a_joined')), 2::bigint, 'and sees their own reaction');

select t4.login('eeeeeeee-0000-0000-0000-00000000000a');
select t4.eq((select count(*) from public.feed_reactions
  where event_id = (select id from t4.ids where key = 'a_joined')), 1::bigint,
  'a private player''s reaction stays hidden from others');
reset role;

-- 5. Crash reports ---------------------------------------------------------------
set role anon;
select t4.fails($$select public.report_error('boom')$$, '42501', 'anon cannot report errors');
set role authenticated;
select t4.login('eeeeeeee-0000-0000-0000-00000000000a');
select public.report_error('Null check operator used on a null value', '#0 HomeScreen.build', 'widget', 18, 'android');
select public.report_error('Null check operator used on a null value', '#0 HomeScreen.build', 'widget', 18, 'android');
select public.report_error('RangeError (index)', '#0 QuestsScreen.build', null, 18, 'android');
select t4.eq(t4.error_kinds('eeeeeeee-0000-0000-0000-00000000000a'), 2::bigint, 'identical errors are grouped');
select t4.eq(t4.errors('eeeeeeee-0000-0000-0000-00000000000a'), 3::bigint, 'and counted');
select t4.fails($$select * from private.client_errors$$, '42501', 'players cannot read crash reports');
select public.report_error('flood ' || i) from generate_series(1, 40) i;
select t4.eq(t4.error_kinds('eeeeeeee-0000-0000-0000-00000000000a'), 30::bigint,
  'at most 30 new error kinds per player and day');
select public.report_error('Null check operator used on a null value', '#0 HomeScreen.build', 'widget', 19, 'android');
select t4.eq(t4.errors('eeeeeeee-0000-0000-0000-00000000000a') > 30, true, 'known errors are still counted after the cap');
select t4.login('eeeeeeee-0000-0000-0000-00000000000d');
select public.report_error(repeat('x', 5000), repeat('y', 9000));
reset role;
select t4.eq((select max(build) from private.client_errors
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000a'), 19, 'the latest build is kept');
select t4.eq((select length(message) from private.client_errors
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000d'), 1000, 'messages are truncated');
select t4.eq((select length(stack) from private.client_errors
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000d'), 4000, 'stacks are truncated');

-- 6. Account deletion ------------------------------------------------------------
set role authenticated;
select t4.login('eeeeeeee-0000-0000-0000-00000000000b');
select public.delete_my_account();
select t4.login('eeeeeeee-0000-0000-0000-00000000000a');
select public.delete_my_account();
reset role;
select t4.eq(t4.error_kinds('eeeeeeee-0000-0000-0000-00000000000a'), 0::bigint, 'crash reports leave with the account');
select t4.eq((select count(*) from public.feed_reactions
  where user_id = 'eeeeeeee-0000-0000-0000-00000000000b'), 0::bigint, 'reactions leave with the account');
select t4.eq((select count(*) from public.feed_reactions), 0::bigint,
  'reactions on a deleted player''s events go too');
