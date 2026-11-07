-- Run in Supabase SQL Editor.
create table if not exists public.site_visits (
 id bigint generated always as identity primary key,
 visitor_id text not null check (char_length(visitor_id) between 8 and 100),
 created_at timestamptz not null default now()
);
alter table public.site_visits enable row level security;
drop policy if exists "Anyone can record anonymous page views" on public.site_visits;
create policy "Anyone can record anonymous page views" on public.site_visits
 for insert to anon, authenticated with check (char_length(visitor_id) between 8 and 100);
drop policy if exists "Only owner can read traffic" on public.site_visits;
create policy "Only owner can read traffic" on public.site_visits
 for select to authenticated using (lower(coalesce(auth.jwt()->>'email',''))='tagzzvr@gmail.com');
grant insert on public.site_visits to anon, authenticated;
grant select on public.site_visits to authenticated;
