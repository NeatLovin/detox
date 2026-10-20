-- Detox V0 — Row Level Security, grants, realtime and cron.

-- ---------------------------------------------------------------------------
-- Grants: the client gets the strict minimum. Column-level grants keep the
-- server-controlled columns (streaks, XP, HP…) out of reach.
-- ---------------------------------------------------------------------------

revoke all on all tables in schema private from public, anon, authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
alter default privileges in schema private revoke execute on functions from public;

revoke all on public.profiles, public.squads, public.squad_members, public.addictions,
  public.relapses, public.xp_ledger, public.player_stats, public.feed_events
  from anon, authenticated;

grant select on public.profiles to authenticated;
grant insert (id, username, avatar_emoji) on public.profiles to authenticated;
grant update (username, avatar_emoji) on public.profiles to authenticated;

grant select on public.squads, public.squad_members, public.feed_events to authenticated;

grant select, delete on public.addictions to authenticated;
grant insert (type, label, unit_label, unit_cost, baseline_per_day, is_private, quit_started_at)
  on public.addictions to authenticated;
grant update (label, unit_label, unit_cost, baseline_per_day, is_private, archived_at)
  on public.addictions to authenticated;

grant select, delete on public.relapses to authenticated;
grant insert (addiction_id, occurred_at, note, shared) on public.relapses to authenticated;
grant update (note, shared) on public.relapses to authenticated;

grant select on public.xp_ledger, public.player_stats to authenticated;

revoke execute on all functions in schema public from public, anon;
grant execute on function
  public.xp_for_level(int),
  public.level_for_xp(bigint),
  public.is_squad_member(uuid),
  public.create_squad(text),
  public.join_squad(text),
  public.leave_squad(),
  public.squad_leaderboard(),
  public.is_username_available(text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.squads enable row level security;
alter table public.squad_members enable row level security;
alter table public.addictions enable row level security;
alter table public.relapses enable row level security;
alter table public.xp_ledger enable row level security;
alter table public.player_stats enable row level security;
alter table public.feed_events enable row level security;
alter table private.addiction_xp_rules enable row level security;
alter table private.milestones enable row level security;

-- profiles: self + squad mates can read, only self can write.
create policy profiles_select on public.profiles
  for select to authenticated
  using (
    id = (select auth.uid())
    or exists (
      select 1 from public.squad_members m
      where m.user_id = profiles.id and public.is_squad_member(m.squad_id)
    )
  );
create policy profiles_insert on public.profiles
  for insert to authenticated
  with check (id = (select auth.uid()));
create policy profiles_update on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- squads / members / feed: read by members only. Writes go through RPCs and triggers.
create policy squads_select on public.squads
  for select to authenticated
  using (public.is_squad_member(id));
create policy squad_members_select on public.squad_members
  for select to authenticated
  using (public.is_squad_member(squad_id));
create policy feed_events_select on public.feed_events
  for select to authenticated
  using (public.is_squad_member(squad_id));

-- addictions / relapses: owner only. Squad mates never read them directly.
create policy addictions_select on public.addictions
  for select to authenticated
  using (user_id = (select auth.uid()));
create policy addictions_insert on public.addictions
  for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy addictions_update on public.addictions
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy addictions_delete on public.addictions
  for delete to authenticated
  using (user_id = (select auth.uid()));

create policy relapses_select on public.relapses
  for select to authenticated
  using (user_id = (select auth.uid()));
create policy relapses_insert on public.relapses
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.addictions a
      where a.id = relapses.addiction_id and a.user_id = (select auth.uid())
    )
  );
create policy relapses_update on public.relapses
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy relapses_delete on public.relapses
  for delete to authenticated
  using (user_id = (select auth.uid()));

-- ledger / stats: owner read only, no client write.
create policy xp_ledger_select on public.xp_ledger
  for select to authenticated
  using (user_id = (select auth.uid()));
create policy player_stats_select on public.player_stats
  for select to authenticated
  using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Realtime
-- ---------------------------------------------------------------------------

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.feed_events, public.player_stats;
  else
    raise notice 'supabase_realtime publication not found, skipping';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- pg_cron: award clean days every hour (minute 5).
-- ---------------------------------------------------------------------------

do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron with schema pg_catalog;
    perform cron.schedule('award-clean-days', '5 * * * *', 'select private.award_clean_days()');
  else
    raise notice 'pg_cron not available, skipping schedule';
  end if;
end;
$$;
