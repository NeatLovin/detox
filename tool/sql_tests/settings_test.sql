-- Settings tests (migration 20261021120000_settings.sql): account deletion and
-- app configuration.

\o /dev/null
set client_min_messages = notice;

create schema t3;
grant usage on schema t3 to authenticated, anon;

create function t3.eq(actual anyelement, expected anyelement, label text)
returns void language plpgsql as $$
begin
  if actual is distinct from expected then
    raise exception 'FAIL %: expected %, got %', label, expected, actual;
  end if;
  raise notice 'ok   %', label;
end;
$$;

create function t3.fails(p_sql text, p_expected text, label text)
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

create function t3.login(p_user uuid) returns void language sql as $$
  select set_config('request.jwt.claim.sub', p_user::text, false);
$$;

-- Rows owned by a user in every public table that references auth.users, so a
-- table added later is covered without touching this test.
create function t3.owned_rows(p_user uuid) returns bigint language plpgsql security definer as $$
declare
  v_fk record;
  v_count bigint;
  v_total bigint := 0;
begin
  for v_fk in
    select c.conrelid::regclass as tbl, a.attname as col
    from pg_constraint c
    join pg_attribute a on a.attrelid = c.conrelid and a.attnum = c.conkey[1]
    where c.contype = 'f'
      and c.confrelid = 'auth.users'::regclass
      and c.connamespace = 'public'::regnamespace
  loop
    execute format('select count(*) from %s where %I = $1', v_fk.tbl, v_fk.col)
      into v_count using p_user;
    v_total := v_total + v_count;
  end loop;
  return v_total;
end;
$$;

create function t3.feed_mentions(p_user uuid) returns bigint language sql security definer as $$
  select count(*) from public.feed_events
  where user_id = p_user or payload ->> 'to_user_id' = p_user::text;
$$;
grant execute on all functions in schema t3 to authenticated, anon;

create table t3.ids (key text primary key, id uuid);
grant select on t3.ids to authenticated;

-- Fixtures: A (will delete their account) and B (stays, supports A's SOS).
insert into auth.users (id, email) values
  ('dddddddd-0000-0000-0000-00000000000a', 'sa@test'),
  ('dddddddd-0000-0000-0000-00000000000b', 'sb@test');
insert into public.profiles (id, username) values
  ('dddddddd-0000-0000-0000-00000000000a', 'set_a'),
  ('dddddddd-0000-0000-0000-00000000000b', 'set_b');

set role authenticated;
select t3.login('dddddddd-0000-0000-0000-00000000000a');
insert into public.addictions (type, label, unit_label, quit_started_at)
  values ('snus', 'Snus', 'sachets', now() - interval '3 days');
insert into public.daily_quests (type, label, unit_label, target) values ('water', 'Eau', 'verres', 8);
insert into public.motivations (text) values ('Pour ma santé');
select public.make_pledge();
select public.register_push_token('token-set-a-' || repeat('a', 30));
reset role;
insert into t3.ids select 'a_snus', id from public.addictions
  where user_id = 'dddddddd-0000-0000-0000-00000000000a';
insert into t3.ids select 'a_water', id from public.daily_quests
  where user_id = 'dddddddd-0000-0000-0000-00000000000a';

set role authenticated;
select t3.login('dddddddd-0000-0000-0000-00000000000a');
insert into public.relapses (addiction_id, occurred_at)
  values ((select id from t3.ids where key = 'a_snus'), now() - interval '1 day');
insert into public.cravings (addiction_id, intensity, resisted)
  values ((select id from t3.ids where key = 'a_snus'), 3, true);
select public.log_quest((select id from t3.ids where key = 'a_water'), 8);
reset role;
insert into t3.ids select 'a_sos', public.start_sos((select id from t3.ids where key = 'a_snus'))
  from (select t3.login('dddddddd-0000-0000-0000-00000000000a')) _;

set role authenticated;
select t3.login('dddddddd-0000-0000-0000-00000000000b');
select public.support_sos((select id from t3.ids where key = 'a_sos'), '💪');
reset role;

select t3.eq(t3.owned_rows('dddddddd-0000-0000-0000-00000000000a') > 8, true, 'fixture: A owns data everywhere');
select t3.eq(t3.feed_mentions('dddddddd-0000-0000-0000-00000000000a') >= 2, true,
  'fixture: the feed mentions A (own events + B''s support)');
select t3.eq((select count(*) from public.sos_supports
  where user_id = 'dddddddd-0000-0000-0000-00000000000b'), 1::bigint, 'fixture: B supported A');

-- 1. Account deletion -----------------------------------------------------------
set role anon;
select t3.fails($$select public.delete_my_account()$$, '42501', 'anon cannot call delete_my_account');
set role authenticated;
select set_config('request.jwt.claim.sub', '', false);
select t3.fails($$select public.delete_my_account()$$, 'not_authenticated', 'delete_my_account needs a session');

select t3.login('dddddddd-0000-0000-0000-00000000000a');
select public.delete_my_account();
reset role;

select t3.eq((select count(*) from auth.users where id = 'dddddddd-0000-0000-0000-00000000000a'),
  0::bigint, 'the auth user is deleted');
select t3.eq(t3.owned_rows('dddddddd-0000-0000-0000-00000000000a'), 0::bigint,
  'no row of A is left in any user table');
select t3.eq(t3.feed_mentions('dddddddd-0000-0000-0000-00000000000a'), 0::bigint,
  'no feed event mentions A anymore');
select t3.eq((select count(*) from public.feed_events where user_id is null), 0::bigint,
  'no orphan feed event is left behind');
select t3.eq((select count(*) from public.push_tokens where token like 'token-set-a-%'), 0::bigint,
  'A''s push token is gone');
select t3.eq((select count(*) from public.relapses r
  where not exists (select 1 from public.addictions a where a.id = r.addiction_id)), 0::bigint,
  'no orphan relapse');
select t3.eq((select count(*) from public.profiles where id = 'dddddddd-0000-0000-0000-00000000000b'),
  1::bigint, 'B is untouched');
select t3.eq((select xp > 0 from public.player_stats where user_id = 'dddddddd-0000-0000-0000-00000000000b'),
  true, 'B keeps their XP');
select t3.eq((select count(*) from public.leaderboard() where username = 'set_a'), 0::bigint,
  'A left the leaderboard');
select t3.eq(public.is_username_available('set_a'), true, 'A''s username is free again');

-- 2. App configuration -----------------------------------------------------------
set role anon;
select t3.fails($$select * from public.app_config$$, '42501', 'anon cannot read app_config');
set role authenticated;
select t3.login('dddddddd-0000-0000-0000-00000000000b');
select t3.eq((select count(*) from public.app_config), 1::bigint, 'players read the single config row');
select t3.eq((select twint_phone from public.app_config), null::text, 'no TWINT number by default');
select t3.fails($$update public.app_config set twint_phone = '079 000 00 00'$$, '42501',
  'players cannot edit app_config');
select t3.fails($$insert into public.app_config (id) values (true)$$, '42501',
  'players cannot insert into app_config');
reset role;
select t3.fails($$insert into public.app_config (id) values (false)$$, '23514', 'app_config is a single row');
select t3.fails($$update public.app_config set twint_phone = 'call me'$$, '23514',
  'the TWINT number must look like a phone number');
update public.app_config set twint_phone = '+41 79 000 00 00';
select t3.eq((select twint_phone from public.app_config), '+41 79 000 00 00', 'the owner can set the number');
