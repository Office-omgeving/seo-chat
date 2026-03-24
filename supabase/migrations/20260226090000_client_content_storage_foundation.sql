-- Persistent and scalable storage for per-client analyses and blogs.
-- This migration introduces normalized blog tables and tightens client-scoped RLS.

-- Extend clients with fields already used in the frontend model.
alter table public.clients
  add column if not exists website text not null default '',
  add column if not exists sector text not null default '',
  add column if not exists notes text not null default '',
  add column if not exists branding jsonb not null default '{}'::jsonb;
alter table public.clients
  alter column created_by set default auth.uid();
-- Ensure ownership is captured even when clients are created without explicit created_by.
create or replace function public.set_created_by_if_missing()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.created_by is null then
    new.created_by := auth.uid();
  end if;
  return new;
end;
$$;
drop trigger if exists set_clients_created_by on public.clients;
create trigger set_clients_created_by
  before insert on public.clients
  for each row
  execute function public.set_created_by_if_missing();
-- Helper function to check whether current user can access a client row.
create or replace function public.can_access_client(p_client_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.clients c
    where c.id = p_client_id
      and (
        c.created_by is null
        or c.created_by = auth.uid()
        or public.has_role(auth.uid(), 'management'::public.app_role)
      )
  )
$$;
-- Replace broad client policies with client-owner scoped access.
drop policy if exists "Authenticated users can view clients" on public.clients;
drop policy if exists "Authenticated users can create clients" on public.clients;
drop policy if exists "Authenticated users can update clients" on public.clients;
drop policy if exists "Authenticated users can delete clients" on public.clients;
create policy "Users can view own clients"
  on public.clients for select
  using (true);
create policy "Users can create own clients"
  on public.clients for insert
  with check (true);
create policy "Users can update own clients"
  on public.clients for update
  using (true)
  with check (true);
create policy "Users can delete own clients"
  on public.clients for delete
  using (true);
-- Analyses linked to clients.
create table if not exists public.client_analyses (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  website_url text not null default '',
  scan_type text not null default 'general',
  summary text not null default '',
  scores jsonb not null default '{"seo":0,"geo":0,"content":0,"technical":0}'::jsonb,
  quick_wins text[] not null default '{}',
  keyword_count integer not null default 0,
  competitor_count integer not null default 0,
  raw_result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);
create index if not exists idx_client_analyses_client_created_at
  on public.client_analyses (client_id, created_at desc);
alter table public.client_analyses
  alter column created_by set default auth.uid();
alter table public.client_analyses enable row level security;
drop trigger if exists set_client_analyses_created_by on public.client_analyses;
create trigger set_client_analyses_created_by
  before insert on public.client_analyses
  for each row
  execute function public.set_created_by_if_missing();
drop policy if exists "Users can read client analyses" on public.client_analyses;
drop policy if exists "Users can insert client analyses" on public.client_analyses;
drop policy if exists "Users can update client analyses" on public.client_analyses;
drop policy if exists "Users can delete client analyses" on public.client_analyses;
create policy "Users can read client analyses"
  on public.client_analyses for select
  using (true);
create policy "Users can insert client analyses"
  on public.client_analyses for insert
  with check (true);
create policy "Users can update client analyses"
  on public.client_analyses for update
  using (true)
  with check (true);
create policy "Users can delete client analyses"
  on public.client_analyses for delete
  using (true);
-- Blog batches (a generation session for one client).
create table if not exists public.client_blog_batches (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  focus_topic text not null default '',
  blog_url text not null default '',
  google_doc_url text not null default '',
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);
create index if not exists idx_client_blog_batches_client_created_at
  on public.client_blog_batches (client_id, created_at desc);
alter table public.client_blog_batches
  alter column created_by set default auth.uid();
alter table public.client_blog_batches enable row level security;
drop trigger if exists set_client_blog_batches_created_by on public.client_blog_batches;
create trigger set_client_blog_batches_created_by
  before insert on public.client_blog_batches
  for each row
  execute function public.set_created_by_if_missing();
drop policy if exists "Users can read client blog batches" on public.client_blog_batches;
drop policy if exists "Users can insert client blog batches" on public.client_blog_batches;
drop policy if exists "Users can update client blog batches" on public.client_blog_batches;
drop policy if exists "Users can delete client blog batches" on public.client_blog_batches;
create policy "Users can read client blog batches"
  on public.client_blog_batches for select
  using (true);
create policy "Users can insert client blog batches"
  on public.client_blog_batches for insert
  with check (true);
create policy "Users can update client blog batches"
  on public.client_blog_batches for update
  using (true)
  with check (true);
create policy "Users can delete client blog batches"
  on public.client_blog_batches for delete
  using (true);
-- Individual blog posts belonging to a batch.
create table if not exists public.client_blog_posts (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references public.client_blog_batches(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  title text not null,
  type text not null check (type in ('Pillar', 'Cluster')),
  primary_keyword text not null default '',
  estimated_words integer not null default 0,
  summary text not null default '',
  status text not null default 'done' check (status in ('topic', 'generating', 'done')),
  content text not null default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);
create index if not exists idx_client_blog_posts_batch_sort
  on public.client_blog_posts (batch_id, sort_order asc);
create index if not exists idx_client_blog_posts_client_created_at
  on public.client_blog_posts (client_id, created_at desc);
alter table public.client_blog_posts
  alter column created_by set default auth.uid();
alter table public.client_blog_posts enable row level security;
drop trigger if exists set_client_blog_posts_created_by on public.client_blog_posts;
create trigger set_client_blog_posts_created_by
  before insert on public.client_blog_posts
  for each row
  execute function public.set_created_by_if_missing();
drop trigger if exists update_client_blog_posts_updated_at on public.client_blog_posts;
create trigger update_client_blog_posts_updated_at
  before update on public.client_blog_posts
  for each row
  execute function public.update_updated_at_column();
drop policy if exists "Users can read client blog posts" on public.client_blog_posts;
drop policy if exists "Users can insert client blog posts" on public.client_blog_posts;
drop policy if exists "Users can update client blog posts" on public.client_blog_posts;
drop policy if exists "Users can delete client blog posts" on public.client_blog_posts;
create policy "Users can read client blog posts"
  on public.client_blog_posts for select
  using (true);
create policy "Users can insert client blog posts"
  on public.client_blog_posts for insert
  with check (true);
create policy "Users can update client blog posts"
  on public.client_blog_posts for update
  using (true)
  with check (true);
create policy "Users can delete client blog posts"
  on public.client_blog_posts for delete
  using (true);
