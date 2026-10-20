-- Detox — local dev seed (supabase db reset). NEVER run on production.
-- 3 fake players (Charlie has a private profile). Sign in locally with the OTP
-- sent to alice@detox.local / bob@detox.local / charlie@detox.local
-- (emails are visible in Mailpit: http://127.0.0.1:54324).

do $$
declare
  v_alice constant uuid := '11111111-1111-1111-1111-111111111111';
  v_bob constant uuid := '22222222-2222-2222-2222-222222222222';
  v_charlie constant uuid := '33333333-3333-3333-3333-333333333333';
  v_user record;
begin
  for v_user in
    select * from (values
      (v_alice, 'alice@detox.local'),
      (v_bob, 'bob@detox.local'),
      (v_charlie, 'charlie@detox.local')
    ) as t(id, email)
  loop
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) values (
      '00000000-0000-0000-0000-000000000000', v_user.id, 'authenticated', 'authenticated',
      v_user.email, '', now(),
      '{"provider":"email","providers":["email"]}', '{}', now(), now(),
      '', '', '', ''
    );
    insert into auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    values (
      gen_random_uuid(), v_user.id::text, v_user.id,
      jsonb_build_object('sub', v_user.id::text, 'email', v_user.email, 'email_verified', true),
      'email', now(), now(), now()
    );
  end loop;

  insert into public.profiles (id, username, avatar_emoji, is_private) values
    (v_alice, 'Alice', '🦊', false),
    (v_bob, 'Bob', '🐻', false),
    (v_charlie, 'Charlie', '🐸', true);

  insert into public.addictions (user_id, type, label, unit_label, unit_cost, baseline_per_day, is_private, quit_started_at) values
    (v_alice, 'snus', 'Snus', 'sachets', 0.45, 10, false, now() - interval '32 days 3 hours'),
    (v_alice, 'sugar', 'Sucre', 'portions', 2, 2, false, now() - interval '5 days 2 hours'),
    (v_bob, 'cigarette', 'Cigarette', 'cigarettes', 0.45, 15, false, now() - interval '12 days 6 hours'),
    (v_bob, 'porn', 'Porno', 'sessions', 0, 1, true, now() - interval '8 days 1 hour'),
    (v_charlie, 'weed', 'Beuh', 'joints', 10, 1, false, now() - interval '3 days 5 hours'),
    (v_charlie, 'alcohol', 'Alcool', 'verres', 6, 2, false, now() - interval '18 days');

  -- Replay the clean days through the real gamification code (XP, HP, milestones, feed).
  update public.addictions set awarded_clean_days = 0;
  perform private.award_clean_days();

  -- A shared relapse (private addiction → label hidden in the feed).
  insert into public.relapses (addiction_id, occurred_at, note, shared)
  select id, now() - interval '1 day', 'Soirée compliquée', true
  from public.addictions where user_id = v_bob and type = 'porn';

  update public.feed_events set created_at = created_at - interval '1 minute' * (random() * 600)::int;
end;
$$;
