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
revoke select on public.site_visits from anon, authenticated;
grant insert on public.site_visits to anon, authenticated;

-- Public visitors can read aggregate totals only, never individual visitor IDs.
create or replace function public.get_public_site_stats()
returns table (
 total_visits bigint,
 unique_visitors bigint,
 visits_today bigint
)
language sql
security definer
set search_path = public
as $
 select
  count(*)::bigint,
  count(distinct visitor_id)::bigint,
  count(*) filter (where created_at >= date_trunc('day', now()))::bigint
 from public.site_visits
 where created_at >= now() - interval '30 days';
$;

revoke all on function public.get_public_site_stats() from public;
grant execute on function public.get_public_site_stats() to anon, authenticated;
