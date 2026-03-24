create table if not exists public.client_profitability_snapshots (
  client_id uuid not null references public.clients(id) on delete cascade,
  month_key text not null,
  summary jsonb not null default '{}'::jsonb,
  tasks jsonb not null default '[]'::jsonb,
  sync_state text not null default 'ready',
  synced_at timestamptz null,
  last_error text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint client_profitability_snapshots_pkey primary key (client_id, month_key),
  constraint client_profitability_snapshots_month_key_check check (month_key ~ '^\d{4}-\d{2}$'),
  constraint client_profitability_snapshots_sync_state_check check (sync_state in ('ready', 'refreshing', 'failed'))
);
create index if not exists client_profitability_snapshots_month_key_idx
  on public.client_profitability_snapshots (month_key);
create index if not exists client_profitability_snapshots_synced_at_idx
  on public.client_profitability_snapshots (synced_at desc nulls last);
alter table public.client_profitability_snapshots enable row level security;
drop policy if exists "Authenticated users can read profitability snapshots" on public.client_profitability_snapshots;
create policy "Authenticated users can read profitability snapshots"
  on public.client_profitability_snapshots
  for select
  to authenticated
  using (true);
drop policy if exists "Service role manage profitability snapshots" on public.client_profitability_snapshots;
create policy "Service role manage profitability snapshots"
  on public.client_profitability_snapshots
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
revoke all on table public.client_profitability_snapshots from anon;
grant select on table public.client_profitability_snapshots to authenticated;
grant select, insert, update, delete on table public.client_profitability_snapshots to service_role;
drop trigger if exists update_client_profitability_snapshots_updated_at
  on public.client_profitability_snapshots;
create trigger update_client_profitability_snapshots_updated_at
  before update on public.client_profitability_snapshots
  for each row execute function public.update_updated_at_column();
