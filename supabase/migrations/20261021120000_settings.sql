-- Detox — settings screen: account deletion and app-wide configuration.

-- 1. Account deletion -----------------------------------------------------------
-- Every user table references auth.users with "on delete cascade", so deleting
-- the auth user erases profile, stats, ledger, addictions, relapses, cravings,
-- quests, pledges, badges, motivations, SOS and push tokens. Feed events use
-- "on delete set null" (kept for the community history), so they are removed
-- explicitly here, together with the SOS supports other players sent to them.
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;

  delete from public.feed_events
  where user_id = v_uid
     or payload ->> 'to_user_id' = v_uid::text;

  delete from auth.users where id = v_uid;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- 2. App configuration -----------------------------------------------------------
-- Single row edited by the owner from the Supabase dashboard (Table Editor),
-- read by every signed-in player. twint_phone null = donation section hidden.
create table public.app_config (
  id boolean primary key default true check (id),
  twint_phone text check (twint_phone ~ '^\+?[0-9 ]{9,20}$'),
  updated_at timestamptz not null default now()
);

insert into public.app_config default values;

revoke all on public.app_config from anon, authenticated;
grant select on public.app_config to authenticated;

alter table public.app_config enable row level security;
create policy app_config_select on public.app_config
  for select to authenticated
  using (true);
