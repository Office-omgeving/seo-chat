-- Persist API usage costs so Costs page survives browser sessions.
create extension if not exists pgcrypto;
create table if not exists public.cost_logs (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references public.clients(id) on delete set null,
  client_name text not null default 'Onbekende klant',
  action_type text not null check (
    action_type in (
      'suggest-competitors',
      'suggest-keywords',
      'run-analysis',
      'suggest-topics',
      'write-blog',
      'generate-blog-image'
    )
  ),
  action_label text not null,
  prompt_tokens integer not null default 0 check (prompt_tokens >= 0),
  completion_tokens integer not null default 0 check (completion_tokens >= 0),
  total_tokens integer not null default 0 check (total_tokens >= 0),
  estimated_cost_eur numeric(12, 4) not null default 0 check (estimated_cost_eur >= 0),
  model text not null default 'unknown',
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) default auth.uid()
);
create index if not exists idx_cost_logs_created_at
  on public.cost_logs (created_at desc);
create index if not exists idx_cost_logs_client_created_at
  on public.cost_logs (client_id, created_at desc);
create index if not exists idx_cost_logs_action_created_at
  on public.cost_logs (action_type, created_at desc);
alter table public.cost_logs enable row level security;
drop policy if exists "Users can read cost logs" on public.cost_logs;
create policy "Users can read cost logs"
  on public.cost_logs
  for select
  using (
    client_id is null
    or public.can_access_client(client_id)
  );
drop policy if exists "Users can insert cost logs" on public.cost_logs;
create policy "Users can insert cost logs"
  on public.cost_logs
  for insert
  with check (
    auth.uid() is not null
    and (
      client_id is null
      or public.can_access_client(client_id)
    )
  );
drop policy if exists "Users can update cost logs" on public.cost_logs;
create policy "Users can update cost logs"
  on public.cost_logs
  for update
  using (
    client_id is null
    or public.can_access_client(client_id)
  )
  with check (
    client_id is null
    or public.can_access_client(client_id)
  );
drop policy if exists "Users can delete cost logs" on public.cost_logs;
create policy "Users can delete cost logs"
  on public.cost_logs
  for delete
  using (
    client_id is null
    or public.can_access_client(client_id)
  );
grant select, insert, update, delete on table public.cost_logs to authenticated;
