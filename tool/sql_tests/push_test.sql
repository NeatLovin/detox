-- Push notification tests (migration 20261021090000_push.sql). pg_net is not
-- installed locally, so notifications are only logged in private.push_log.

\o /dev/null
set client_min_messages = notice;

create schema t2;
grant usage on schema t2 to authenticated, anon;

create function t2.eq(actual anyelement, expected anyelement, label text)
returns void language plpgsql as $$
begin
  if actual is distinct from expected then
    raise exception 'FAIL %: expected %, got %', label, expected, actual;
  end if;
  raise notice 'ok   %', label;
end;
$$;

create function t2.fails(p_sql text, p_expected text, label text)
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

create function t2.login(p_user uuid) returns void language sql as $$
  select set_config('request.jwt.claim.sub', p_user::text, false);
$$;

-- Number of log rows of a kind that target a user.
create function t2.pushed(p_kind text, p_user uuid) returns bigint language sql security definer as $$
  select count(*) from private.push_log where kind = p_kind and p_user = any (user_ids);
$$;
grant execute on all functions in schema t2 to authenticated, anon;

create table t2.ids (key text primary key, id uuid);
grant select on t2.ids to authenticated;

-- Fixtures: A (public, SOS), B (public, device), C (private, device),
-- D (public, device, SOS notifications off), E (public, no device).
insert into auth.users (id, email) values
  ('cccccccc-0000-0000-0000-00000000000a', 'pa@test'),
  ('cccccccc-0000-0000-0000-00000000000b', 'pb@test'),
  ('cccccccc-0000-0000-0000-00000000000c', 'pc@test'),
  ('cccccccc-0000-0000-0000-00000000000d', 'pd@test'),
  ('cccccccc-0000-0000-0000-00000000000e', 'pe@test');
insert into public.profiles (id, username, is_private, notify_sos) values
  ('cccccccc-0000-0000-0000-00000000000a', 'push_a', false, true),
  ('cccccccc-0000-0000-0000-00000000000b', 'push_b', false, true),
  ('cccccccc-0000-0000-0000-00000000000c', 'push_c', true, true),
  ('cccccccc-0000-0000-0000-00000000000d', 'push_d', false, false),
  ('cccccccc-0000-0000-0000-00000000000e', 'push_e', false, true);

-- 1. Tokens ---------------------------------------------------------------------
set role anon;
select t2.fails($$select public.register_push_token(repeat('x', 40))$$, '42501', 'anon cannot register a token');
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000a');
select public.register_push_token('token-a-' || repeat('a', 30));
select t2.login('cccccccc-0000-0000-0000-00000000000b');
select public.register_push_token('token-b-' || repeat('b', 30));
select t2.login('cccccccc-0000-0000-0000-00000000000c');
select public.register_push_token('token-c-' || repeat('c', 30));
select t2.login('cccccccc-0000-0000-0000-00000000000d');
select public.register_push_token('token-d-' || repeat('d', 30));
select t2.fails($$insert into public.push_tokens (token, user_id) values (repeat('z', 30), auth.uid())$$,
  '42501', 'client cannot write tokens directly');
select t2.eq((select count(*) from public.push_tokens), 1::bigint, 'a player only sees their own tokens');

-- Same device, another account: the token moves to the new user.
select t2.login('cccccccc-0000-0000-0000-00000000000e');
select public.register_push_token('token-d-' || repeat('d', 30));
reset role;
select t2.eq((select user_id from public.push_tokens where token like 'token-d-%'),
  'cccccccc-0000-0000-0000-00000000000e'::uuid, 'a token belongs to the last signed-in user');
set role authenticated;
select public.unregister_push_token('token-d-' || repeat('d', 30));
reset role;
select t2.eq((select count(*) from public.push_tokens where token like 'token-d-%'), 0::bigint,
  'sign-out removes the token');
-- Give D a device again for the opt-out test.
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000d');
select public.register_push_token('token-d2-' || repeat('d', 30));
select t2.login('cccccccc-0000-0000-0000-00000000000a');
select public.register_push_token('token-a' || g || '-' || repeat('a', 30)) from generate_series(2, 7) g;
reset role;
select t2.eq((select count(*) from public.push_tokens where user_id = 'cccccccc-0000-0000-0000-00000000000a'),
  5::bigint, 'at most 5 devices per player');

-- 2. SOS --------------------------------------------------------------------------
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000a');
insert into public.addictions (type, label, unit_label) values ('snus', 'Snus', 'sachets');
reset role;
insert into t2.ids select 'a_snus', id from public.addictions where user_id = 'cccccccc-0000-0000-0000-00000000000a';
set role authenticated;
select public.start_sos((select id from t2.ids where key = 'a_snus'));
reset role;
select t2.eq(t2.pushed('sos', 'cccccccc-0000-0000-0000-00000000000b'), 1::bigint, 'SOS pushed to a public player');
select t2.eq(t2.pushed('sos', 'cccccccc-0000-0000-0000-00000000000c'), 1::bigint, 'SOS pushed to a private player too');
select t2.eq(t2.pushed('sos', 'cccccccc-0000-0000-0000-00000000000a'), 0::bigint, 'not to the one who needs help');
select t2.eq(t2.pushed('sos', 'cccccccc-0000-0000-0000-00000000000d'), 0::bigint, 'not to a player who turned SOS alerts off');
select t2.eq(t2.pushed('sos', 'cccccccc-0000-0000-0000-00000000000e'), 0::bigint, 'not to a player without a device');
select t2.eq((select title from private.push_log where kind = 'sos'), '🆘 push_a a besoin de force', 'SOS title');
select t2.eq((select sent from private.push_log where kind = 'sos'), false, 'without pg_net the push is only logged');

-- Support → the owner.
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000b');
select public.support_sos((select id from public.sos_alerts limit 1), '🔥');
reset role;
select t2.eq(t2.pushed('sos_support', 'cccccccc-0000-0000-0000-00000000000a'), 1::bigint, 'support pushed to the SOS owner');
select t2.eq((select title from private.push_log where kind = 'sos_support'), '🔥 push_b te soutient', 'support title');

-- A private player's SOS is not broadcast.
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000c');
insert into public.addictions (type, label, unit_label) values ('vape', 'Vape', 'sessions');
select public.start_sos((select id from public.addictions where type = 'vape'));
reset role;
select t2.eq((select count(*) from private.push_log where kind = 'sos'), 1::bigint, 'a private player''s SOS is not pushed');

-- 3. Reminders --------------------------------------------------------------------
-- 09:30 Zurich: everyone with a device who has not pledged (B has pledged).
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000b');
select public.make_pledge();
reset role;
select private.send_reminders((private.zurich_today() + time '09:30') at time zone 'Europe/Zurich');
select t2.eq(t2.pushed('reminder_pledge', 'cccccccc-0000-0000-0000-00000000000a'), 1::bigint, 'pledge reminder at 9 h');
select t2.eq(t2.pushed('reminder_pledge', 'cccccccc-0000-0000-0000-00000000000b'), 0::bigint, 'not when already pledged');
select private.send_reminders((private.zurich_today() + time '09:45') at time zone 'Europe/Zurich');
select t2.eq((select count(*) from private.push_log where kind = 'reminder_pledge'), 1::bigint, 'pledge reminder once a day');
select private.send_reminders((private.zurich_today() + time '14:00') at time zone 'Europe/Zurich');
select t2.eq((select count(*) from private.push_log where kind like 'reminder%'), 1::bigint, 'nothing outside reminder hours');

-- 20:00 Zurich: players with unfinished quests, with the count.
set role authenticated;
select t2.login('cccccccc-0000-0000-0000-00000000000b');
insert into public.daily_quests (type, label, unit_label, target) values
  ('water', 'Eau', 'verres', 8), ('sport', 'Sport', 'min', 30);
select public.log_quest((select id from public.daily_quests where type = 'water'), 8);
reset role;
select private.send_reminders((private.zurich_today() + time '20:10') at time zone 'Europe/Zurich');
select t2.eq(t2.pushed('reminder_quests', 'cccccccc-0000-0000-0000-00000000000b'), 1::bigint, 'quests reminder at 20 h');
select t2.eq((select body from private.push_log where kind = 'reminder_quests'),
  'Plus qu''une quête à boucler avant minuit. Tu gères !', 'quests reminder counts what is left');
select t2.eq(t2.pushed('reminder_quests', 'cccccccc-0000-0000-0000-00000000000a'), 0::bigint, 'no quests, no reminder');

update public.profiles set notify_reminders = false where id = 'cccccccc-0000-0000-0000-00000000000a';
select t2.eq('cccccccc-0000-0000-0000-00000000000a' = any (private.pledge_reminder_targets(private.zurich_today() + 1)), false,
  'reminders can be turned off');

-- 4. Privacy of the delivery tables ----------------------------------------------
set role authenticated;
select t2.fails($$select * from private.push_log$$, '42501', 'push log is not readable by clients');
select t2.fails($$select * from private.push_config$$, '42501', 'push config is not readable by clients');
reset role;
