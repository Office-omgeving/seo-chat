-- Durable backup tracking and daily export scheduler for weekly client check-ins.
-- Primary storage remains in Postgres; this table only tracks backup executions.

create table if not exists public.backup_runs (
  id uuid primary key default gen_random_uuid(),
  backup_scope text not null default 'weekly_checkins',
  trigger_source text not null default 'manual' check (trigger_source in ('manual', 'scheduled')),
  status text not null check (status in ('running', 'success', 'error')),
  started_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  row_count integer not null default 0 check (row_count >= 0),
  checksum text,
  storage_key text,
  manifest_storage_key text,
  error_message text,
  details jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) on delete set null
);
create index if not exists backup_runs_scope_started_idx
  on public.backup_runs (backup_scope, started_at desc);
create index if not exists backup_runs_scope_status_started_idx
  on public.backup_runs (backup_scope, status, started_at desc);
alter table public.backup_runs enable row level security;
drop policy if exists "service_role_manage_backup_runs" on public.backup_runs;
create policy "service_role_manage_backup_runs"
  on public.backup_runs
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
drop policy if exists "management_read_backup_runs" on public.backup_runs;
create policy "management_read_backup_runs"
  on public.backup_runs
  for select
  to authenticated
  using (
    coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
    or coalesce(public.has_role(auth.uid(), 'management'::public.app_role), false)
  );
revoke all on table public.backup_runs from anon;
grant select on table public.backup_runs to authenticated;
grant select, insert, update, delete on table public.backup_runs to service_role;
create extension if not exists pg_cron with schema extensions;
create extension if not exists pg_net with schema extensions;
do $$
declare
  existing_job_id bigint;
begin
  select jobid
  into existing_job_id
  from cron.job
  where jobname = 'weekly_checkins_backup_daily';

  if existing_job_id is not null then
    perform cron.unschedule(existing_job_id);
  end if;

  perform cron.schedule(
    'weekly_checkins_backup_daily',
    '15 1 * * *',
    $cron$
      select net.http_post(
        url := 'https://ubbthfgfxhttxlkyqdlw.supabase.co/functions/v1/weekly-checkins-backup',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InViYnRoZmdmeGh0dHhsa3lxZGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3ODU2MDgsImV4cCI6MjA2MDM2MTYwOH0.ggKnBIA6nHFn1wom8Rl40dUbxJM8fGGgN4Ksm5xOwxY',
          'apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InViYnRoZmdmeGh0dHhsa3lxZGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3ODU2MDgsImV4cCI6MjA2MDM2MTYwOH0.ggKnBIA6nHFn1wom8Rl40dUbxJM8fGGgN4Ksm5xOwxY'
        ),
        body := jsonb_build_object(
          'trigger', 'scheduled'
        ),
        timeout_milliseconds := 600000
      );
    $cron$
  );
end
$$;
