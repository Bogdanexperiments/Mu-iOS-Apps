-- SCP Foundation online backend
-- Apply in Supabase SQL Editor.
-- Article text is not copied here; the app reads metadata from the public SCP Data API.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  display_name text not null,
  worker_id text unique not null,
  department text not null default 'Field Operations',
  site text not null default 'Site-01',
  clearance smallint not null default 2 check (clearance between 1 and 5),
  avatar_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.scp_catalog_metadata (
  slug text primary key,
  title text,
  scp_label text,
  source_url text not null,
  author_name text,
  author_url text,
  containment_class text,
  rating integer,
  series text,
  created_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.o5_registration_links (
  id uuid primary key default gen_random_uuid(),
  token_hash text unique not null,
  invited_email text not null,
  issued_by uuid references public.profiles(id),
  clearance smallint not null default 5 check (clearance = 5),
  expires_at timestamptz not null,
  used_at timestamptz,
  created_at timestamptz not null default now()
);

insert into public.o5_registration_links (token_hash, invited_email, expires_at)
select 'INITIAL_O5_INVITE_TO_BE_ISSUED_SERVER_SIDE', 'ioiopiphone@icloud.com', now() + interval '30 days'
where not exists (
  select 1 from public.o5_registration_links
  where invited_email = 'ioiopiphone@icloud.com'
);

insert into storage.buckets (id, name, public)
values ('profile-avatars', 'profile-avatars', true)
on conflict (id) do update set public = true;

alter table public.profiles enable row level security;
alter table public.scp_catalog_metadata enable row level security;
alter table public.o5_registration_links enable row level security;

create policy "profiles are readable by their owner"
on public.profiles for select to authenticated
using (auth.uid() = id);

create policy "users update their own profile"
on public.profiles for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "catalog metadata is public"
on public.scp_catalog_metadata for select to anon, authenticated
using (true);

create policy "avatars are public"
on storage.objects for select to public
using (bucket_id = 'profile-avatars');

create policy "users upload their own avatar"
on storage.objects for insert to authenticated
with check (bucket_id = 'profile-avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "users update their own avatar"
on storage.objects for update to authenticated
using (bucket_id = 'profile-avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "users delete their own avatar"
on storage.objects for delete to authenticated
using (bucket_id = 'profile-avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- O5 invite issuing and consumption must be implemented as SECURITY DEFINER
-- Edge Functions or RPCs. Never expose token_hash or service-role keys in the app.
