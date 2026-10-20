-- Detox — in-app updates.
-- The CI uploads every release APK to the public `releases` storage bucket and
-- records it here; the app compares its own build number with the latest row
-- and offers the update. Written by the CI only (service role), read by all.

create table public.app_releases (
  version_code int primary key check (version_code > 0),
  version_name text not null,
  apk_url text not null check (apk_url ~ '^https://'),
  notes text,
  created_at timestamptz not null default now()
);

revoke all on public.app_releases from anon, authenticated;
grant select on public.app_releases to anon, authenticated;

alter table public.app_releases enable row level security;
create policy app_releases_select on public.app_releases
  for select to anon, authenticated
  using (true);

-- Public bucket for the APKs (Supabase only; skipped on a plain Postgres).
do $$
begin
  if exists (select 1 from pg_namespace where nspname = 'storage')
     and exists (select 1 from pg_tables where schemaname = 'storage' and tablename = 'buckets') then
    insert into storage.buckets (id, name, public)
    values ('releases', 'releases', true)
    on conflict (id) do update set public = true;
  else
    raise notice 'storage schema not found, skipping releases bucket';
  end if;
end;
$$;
