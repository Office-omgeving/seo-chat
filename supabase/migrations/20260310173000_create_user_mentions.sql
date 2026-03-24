create table if not exists public.user_mentions (
  id uuid primary key default gen_random_uuid(),
  mentioned_user_id uuid not null references auth.users(id) on delete cascade,
  author_user_id uuid references auth.users(id) on delete set null,
  author_name text not null default '',
  client_id uuid not null references public.clients(id) on delete cascade,
  checkin_id uuid references public.weekly_checkins(id) on delete cascade,
  source_kind text not null check (source_kind in ('account_manager_log')),
  source_entry_id text not null,
  content text not null default '',
  is_resolved boolean not null default false,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  unique (mentioned_user_id, source_kind, source_entry_id)
);
create index if not exists idx_user_mentions_user_inbox
  on public.user_mentions (mentioned_user_id, is_resolved, created_at desc);
create index if not exists idx_user_mentions_client_created
  on public.user_mentions (client_id, created_at desc);
alter table public.user_mentions enable row level security;
drop policy if exists "Users can view own mentions inbox" on public.user_mentions;
create policy "Users can view own mentions inbox"
  on public.user_mentions for select
  using (
    auth.uid() = mentioned_user_id
    or auth.uid() = author_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  );
drop policy if exists "Users can insert own authored mentions" on public.user_mentions;
create policy "Users can insert own authored mentions"
  on public.user_mentions for insert
  with check (
    auth.uid() = author_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  );
drop policy if exists "Mentioned users can resolve own mentions" on public.user_mentions;
create policy "Mentioned users can resolve own mentions"
  on public.user_mentions for update
  using (
    auth.uid() = mentioned_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  )
  with check (
    auth.uid() = mentioned_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  );
drop policy if exists "Authors can delete own mentions" on public.user_mentions;
create policy "Authors can delete own mentions"
  on public.user_mentions for delete
  using (
    auth.uid() = author_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  );
