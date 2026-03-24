-- Exacte voortgang van seo-analyse runs (voor frontend polling).

create table if not exists public.analysis_run_progress (
  run_id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null check (status in ('running', 'completed', 'failed')),
  progress integer not null default 0 check (progress >= 0 and progress <= 100),
  stage text not null default '',
  detail text,
  error text,
  started_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  finished_at timestamptz,
  expires_at timestamptz not null default (now() + interval '6 hours')
);
create index if not exists analysis_run_progress_user_updated_idx
  on public.analysis_run_progress (user_id, updated_at desc);
create index if not exists analysis_run_progress_expires_idx
  on public.analysis_run_progress (expires_at);
alter table public.analysis_run_progress enable row level security;
drop policy if exists "Users can read own analysis run progress" on public.analysis_run_progress;
create policy "Users can read own analysis run progress"
  on public.analysis_run_progress
  for select
  to authenticated
  using (user_id = auth.uid());
drop policy if exists "Service role manage analysis run progress" on public.analysis_run_progress;
create policy "Service role manage analysis run progress"
  on public.analysis_run_progress
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
revoke all on table public.analysis_run_progress from anon;
revoke all on table public.analysis_run_progress from authenticated;
grant select, insert, update, delete on table public.analysis_run_progress to service_role;
