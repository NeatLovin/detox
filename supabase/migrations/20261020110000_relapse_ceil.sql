-- Detox — backdated relapse: round the carried-over paid days UP.
-- 20261020100000_anticheat.sql used floor(): a relapse dated at a fraction of a
-- day (e.g. 14 days paid, relapse at day 0.5 → floor(13.5) = 13) paid day 14
-- and its milestone a second time. With ceil() we would rather underpay a
-- fraction of a day than pay a day or a milestone twice.
-- Same function as before, only the awarded_clean_days rounding changes.

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
      awarded_clean_days = greatest(0, ceil(extract(epoch from (v_awarded_end - new.occurred_at)) / 86400))::int
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
