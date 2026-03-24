-- Harden weekly tracking storage so week notes are auditable, client-scoped,
-- and automatically stamped with actor metadata.

create or replace function public.can_access_client_text(p_client_id text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select case
    when p_client_id is null then false
    when btrim(p_client_id) !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then false
    else public.can_access_client(btrim(p_client_id)::uuid)
  end
$$;
create or replace function public.touch_weekly_client_record()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    new.created_at := coalesce(new.created_at, timezone('utc', now()));
    new.created_by := coalesce(new.created_by, auth.uid());
  end if;

  new.updated_at := timezone('utc', now());
  new.updated_by := coalesce(auth.uid(), new.updated_by, new.created_by);
  return new;
end;
$$;
alter table public.weekly_checkins
  alter column created_at set default timezone('utc', now()),
  alter column updated_at set default timezone('utc', now()),
  alter column created_by set default auth.uid(),
  alter column updated_by set default auth.uid();
alter table public.weekly_management_rows
  alter column created_at set default timezone('utc', now()),
  alter column updated_at set default timezone('utc', now()),
  alter column created_by set default auth.uid(),
  alter column updated_by set default auth.uid();
alter table public.client_integrations
  alter column created_at set default timezone('utc', now()),
  alter column updated_at set default timezone('utc', now()),
  alter column created_by set default auth.uid(),
  alter column updated_by set default auth.uid();
drop trigger if exists update_weekly_checkins_updated_at on public.weekly_checkins;
drop trigger if exists update_weekly_management_rows_updated_at on public.weekly_management_rows;
drop trigger if exists update_client_integrations_updated_at on public.client_integrations;
drop trigger if exists touch_weekly_checkins_record on public.weekly_checkins;
create trigger touch_weekly_checkins_record
before insert or update on public.weekly_checkins
for each row
execute function public.touch_weekly_client_record();
drop trigger if exists touch_weekly_management_rows_record on public.weekly_management_rows;
create trigger touch_weekly_management_rows_record
before insert or update on public.weekly_management_rows
for each row
execute function public.touch_weekly_client_record();
drop trigger if exists touch_client_integrations_record on public.client_integrations;
create trigger touch_client_integrations_record
before insert or update on public.client_integrations
for each row
execute function public.touch_weekly_client_record();
drop policy if exists "Authenticated users can view weekly check-ins" on public.weekly_checkins;
drop policy if exists "Authenticated users can insert weekly check-ins" on public.weekly_checkins;
drop policy if exists "Authenticated users can update weekly check-ins" on public.weekly_checkins;
drop policy if exists "Admins can delete weekly check-ins" on public.weekly_checkins;
create policy "weekly_checkins_select"
on public.weekly_checkins
for select
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "weekly_checkins_insert"
on public.weekly_checkins
for insert
with check (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "weekly_checkins_update"
on public.weekly_checkins
for update
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
)
with check (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "weekly_checkins_delete"
on public.weekly_checkins
for delete
using (
  public.has_role(auth.uid(), 'admin'::public.app_role)
  and public.can_access_client_text(client_id)
);
drop policy if exists "Authenticated users can view weekly management rows" on public.weekly_management_rows;
drop policy if exists "Authenticated users can insert weekly management rows" on public.weekly_management_rows;
drop policy if exists "Authenticated users can update weekly management rows" on public.weekly_management_rows;
drop policy if exists "Authenticated users can delete weekly management rows" on public.weekly_management_rows;
create policy "weekly_management_rows_select"
on public.weekly_management_rows
for select
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "weekly_management_rows_insert"
on public.weekly_management_rows
for insert
with check (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "weekly_management_rows_update"
on public.weekly_management_rows
for update
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
)
with check (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "weekly_management_rows_delete"
on public.weekly_management_rows
for delete
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
drop policy if exists "Authenticated users can view client integrations" on public.client_integrations;
drop policy if exists "Authenticated users can insert client integrations" on public.client_integrations;
drop policy if exists "Authenticated users can update client integrations" on public.client_integrations;
drop policy if exists "Authenticated users can delete client integrations" on public.client_integrations;
create policy "client_integrations_select"
on public.client_integrations
for select
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "client_integrations_insert"
on public.client_integrations
for insert
with check (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "client_integrations_update"
on public.client_integrations
for update
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
)
with check (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create policy "client_integrations_delete"
on public.client_integrations
for delete
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
create table if not exists public.weekly_checkin_revisions (
  id uuid primary key default gen_random_uuid(),
  checkin_id uuid not null references public.weekly_checkins(id) on delete cascade,
  client_id text not null,
  revision_no integer not null,
  action text not null check (action in ('created', 'updated', 'status_changed', 'frozen', 'unfrozen')),
  changed_fields text[] not null default '{}',
  snapshot jsonb not null,
  created_at timestamptz not null default timezone('utc', now()),
  created_by uuid references auth.users(id),
  constraint weekly_checkin_revisions_checkin_revision_unique unique (checkin_id, revision_no)
);
create index if not exists weekly_checkin_revisions_checkin_created_idx
  on public.weekly_checkin_revisions (checkin_id, created_at desc);
create index if not exists weekly_checkins_client_updated_idx
  on public.weekly_checkins (client_id, updated_at desc);
create or replace function public.capture_weekly_checkin_revision()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  changed_fields text[] := '{}'::text[];
  action_name text := 'updated';
  next_revision_no integer;
begin
  if tg_op = 'INSERT' then
    changed_fields := array[
      'status',
      'onboarding',
      'marketing_input',
      'campaigns',
      'sheet_overview',
      'account_manager',
      'operations',
      'performance',
      'upsells',
      'external_links'
    ];
    action_name := 'created';
  else
    if old.status is distinct from new.status then
      changed_fields := array_append(changed_fields, 'status');
      action_name := case
        when old.status = 'draft' and new.status = 'frozen' then 'frozen'
        when old.status = 'frozen' and new.status = 'draft' then 'unfrozen'
        else 'status_changed'
      end;
    end if;

    if old.onboarding is distinct from new.onboarding then
      changed_fields := array_append(changed_fields, 'onboarding');
    end if;
    if old.marketing_input is distinct from new.marketing_input then
      changed_fields := array_append(changed_fields, 'marketing_input');
    end if;
    if old.campaigns is distinct from new.campaigns then
      changed_fields := array_append(changed_fields, 'campaigns');
    end if;
    if old.sheet_overview is distinct from new.sheet_overview then
      changed_fields := array_append(changed_fields, 'sheet_overview');
    end if;
    if old.account_manager is distinct from new.account_manager then
      changed_fields := array_append(changed_fields, 'account_manager');
    end if;
    if old.operations is distinct from new.operations then
      changed_fields := array_append(changed_fields, 'operations');
    end if;
    if old.performance is distinct from new.performance then
      changed_fields := array_append(changed_fields, 'performance');
    end if;
    if old.upsells is distinct from new.upsells then
      changed_fields := array_append(changed_fields, 'upsells');
    end if;
    if old.external_links is distinct from new.external_links then
      changed_fields := array_append(changed_fields, 'external_links');
    end if;
    if old.completeness_score is distinct from new.completeness_score then
      changed_fields := array_append(changed_fields, 'completeness_score');
    end if;
    if old.prepared_for_call is distinct from new.prepared_for_call then
      changed_fields := array_append(changed_fields, 'prepared_for_call');
    end if;
    if old.signoff_note is distinct from new.signoff_note then
      changed_fields := array_append(changed_fields, 'signoff_note');
    end if;
    if old.template_type is distinct from new.template_type then
      changed_fields := array_append(changed_fields, 'template_type');
    end if;
    if old.source is distinct from new.source then
      changed_fields := array_append(changed_fields, 'source');
    end if;

    if coalesce(array_length(changed_fields, 1), 0) = 0 then
      return new;
    end if;
  end if;

  select coalesce(max(revision_no), 0) + 1
  into next_revision_no
  from public.weekly_checkin_revisions
  where checkin_id = new.id;

  insert into public.weekly_checkin_revisions (
    checkin_id,
    client_id,
    revision_no,
    action,
    changed_fields,
    snapshot,
    created_at,
    created_by
  )
  values (
    new.id,
    new.client_id,
    next_revision_no,
    action_name,
    changed_fields,
    to_jsonb(new),
    timezone('utc', now()),
    coalesce(auth.uid(), new.updated_by, new.created_by)
  );

  return new;
end;
$$;
drop trigger if exists capture_weekly_checkin_revision on public.weekly_checkins;
create trigger capture_weekly_checkin_revision
after insert or update on public.weekly_checkins
for each row
execute function public.capture_weekly_checkin_revision();
alter table public.weekly_checkin_revisions enable row level security;
drop policy if exists "weekly_checkin_revisions_select" on public.weekly_checkin_revisions;
create policy "weekly_checkin_revisions_select"
on public.weekly_checkin_revisions
for select
using (
  auth.uid() is not null
  and public.can_access_client_text(client_id)
);
