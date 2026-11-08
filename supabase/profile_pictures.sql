-- YeepsHub profile-picture review queue
-- Run once in Supabase SQL Editor. Public visitors can submit suggestions;
-- only the signed-in YeepsHub owner can review or publish them.

create table if not exists public.profile_picture_submissions (
 id bigint generated always as identity primary key,
 username text not null check (char_length(username) between 1 and 70),
 image_url text not null check (char_length(image_url) between 9 and 1000 and image_url like 'https://%'),
 created_at timestamptz not null default now()
);
alter table public.profile_picture_submissions enable row level security;
grant insert on public.profile_picture_submissions to anon, authenticated;
grant select, delete on public.profile_picture_submissions to authenticated;
drop policy if exists "Anyone can submit profile pictures" on public.profile_picture_submissions;
create policy "Anyone can submit profile pictures" on public.profile_picture_submissions
 for insert to anon, authenticated with check (
  char_length(username) between 1 and 70
  and char_length(image_url) between 9 and 1000
  and image_url like 'https://%'
 );
drop policy if exists "Owner can review profile picture submissions" on public.profile_picture_submissions;
create policy "Owner can review profile picture submissions" on public.profile_picture_submissions
 for select to authenticated using ((auth.jwt() ->> 'email') = 'tagzzvr@gmail.com');
drop policy if exists "Owner can remove profile picture submissions" on public.profile_picture_submissions;
create policy "Owner can remove profile picture submissions" on public.profile_picture_submissions
 for delete to authenticated using ((auth.jwt() ->> 'email') = 'tagzzvr@gmail.com');

create table if not exists public.player_profile_pictures (
 username text primary key check (char_length(username) between 1 and 70),
 image_url text not null check (char_length(image_url) between 9 and 1000 and image_url like 'https://%'),
 updated_at timestamptz not null default now()
);
alter table public.player_profile_pictures enable row level security;
grant select on public.player_profile_pictures to anon, authenticated;
grant insert, update, delete on public.player_profile_pictures to authenticated;
drop policy if exists "Anyone can view approved profile pictures" on public.player_profile_pictures;
create policy "Anyone can view approved profile pictures" on public.player_profile_pictures
 for select to anon, authenticated using (true);
drop policy if exists "Owner can publish profile pictures" on public.player_profile_pictures;
create policy "Owner can publish profile pictures" on public.player_profile_pictures
 for all to authenticated using ((auth.jwt() ->> 'email') = 'tagzzvr@gmail.com')
 with check ((auth.jwt() ->> 'email') = 'tagzzvr@gmail.com');
