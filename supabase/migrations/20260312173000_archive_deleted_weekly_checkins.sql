-- Preserve deleted weekly check-ins and their revision history so week notes
-- can be restored after accidental deletes or client cleanups.

create table if not exists public.deleted_weekly_checkins (
  archive_id uuid primary key default gen_random_uuid(),
  original_checkin_id uuid not null,
  client_id text not null,
  client_name text,
  week_start_date date not null,
  week_number integer not null,
  year integer not null,
  delete_reason text not null default 'direct_delete'
    check (delete_reason in ('direct_delete', 'client_delete', 'unknown')),
  snapshot jsonb not null,
  deleted_at timestamptz not null default timezone('utc', now()),
  deleted_by uuid references auth.users(id),
  restored_at timestamptz,
  restored_by uuid references auth.users(id),
  restored_checkin_id uuid,
  restore_target_client_id text
);
create index if not exists deleted_weekly_checkins_client_deleted_idx
  on public.deleted_weekly_checkins (client_id, deleted_at desc);
create index if not exists deleted_weekly_checkins_week_deleted_idx
  on public.deleted_weekly_checkins (week_start_date desc, deleted_at desc);
create unique index if not exists deleted_weekly_checkins_active_original_idx
  on public.deleted_weekly_checkins (original_checkin_id)
  where restored_at is null;
create table if not exists public.deleted_weekly_checkin_revisions (
  archive_revision_id uuid primary key default gen_random_uuid(),
  archive_id uuid not null references public.deleted_weekly_checkins(archive_id) on delete cascade,
  original_revision_id uuid,
  original_checkin_id uuid not null,
  revision_no integer not null,
  snapshot jsonb not null,
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists deleted_weekly_checkin_revisions_archive_idx
  on public.deleted_weekly_checkin_revisions (archive_id, revision_no);
alter table public.deleted_weekly_checkins enable row level security;
alter table public.deleted_weekly_checkin_revisions enable row level security;
create or replace function public.can_manage_deleted_weekly_checkins()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    auth.role() = 'service_role'
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
    or coalesce(public.has_role(auth.uid(), 'management'::public.app_role), false)
$$;
drop policy if exists "deleted_weekly_checkins_select" on public.deleted_weekly_checkins;
create policy "deleted_weekly_checkins_select"
on public.deleted_weekly_checkins
for select
using (
  auth.uid() is not null
  and public.can_manage_deleted_weekly_checkins()
);
drop policy if exists "deleted_weekly_checkin_revisions_select" on public.deleted_weekly_checkin_revisions;
create policy "deleted_weekly_checkin_revisions_select"
on public.deleted_weekly_checkin_revisions
for select
using (
  auth.uid() is not null
  and public.can_manage_deleted_weekly_checkins()
);
revoke all on table public.deleted_weekly_checkins from anon;
revoke all on table public.deleted_weekly_checkin_revisions from anon;
grant select on table public.deleted_weekly_checkins to authenticated;
grant select on table public.deleted_weekly_checkin_revisions to authenticated;
grant all on table public.deleted_weekly_checkins to service_role;
grant all on table public.deleted_weekly_checkin_revisions to service_role;
create or replace function public.archive_deleted_weekly_checkin()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  archive_reason text := coalesce(nullif(current_setting('app.weekly_checkin_delete_reason', true), ''), 'direct_delete');
  archived_client_name text := null;
  archived_row public.deleted_weekly_checkins%rowtype;
begin
  if archive_reason not in ('direct_delete', 'client_delete') then
    archive_reason := 'unknown';
  end if;

  if btrim(old.client_id) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    select c.name
    into archived_client_name
    from public.clients c
    where c.id = btrim(old.client_id)::uuid;
  end if;

  insert into public.deleted_weekly_checkins (
    original_checkin_id,
    client_id,
    client_name,
    week_start_date,
    week_number,
    year,
    delete_reason,
    snapshot,
    deleted_at,
    deleted_by
  )
  values (
    old.id,
    old.client_id,
    archived_client_name,
    old.week_start_date,
    old.week_number,
    old.year,
    archive_reason,
    to_jsonb(old),
    timezone('utc', now()),
    auth.uid()
  )
  returning *
  into archived_row;

  insert into public.deleted_weekly_checkin_revisions (
    archive_id,
    original_revision_id,
    original_checkin_id,
    revision_no,
    snapshot,
    created_at
  )
  select
    archived_row.archive_id,
    revision.id,
    old.id,
    revision.revision_no,
    to_jsonb(revision),
    coalesce(revision.created_at, timezone('utc', now()))
  from public.weekly_checkin_revisions revision
  where revision.checkin_id = old.id
  order by revision.revision_no;

  return old;
end;
$$;
drop trigger if exists archive_deleted_weekly_checkin_before_delete on public.weekly_checkins;
create trigger archive_deleted_weekly_checkin_before_delete
before delete on public.weekly_checkins
for each row
execute function public.archive_deleted_weekly_checkin();
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
  if coalesce(current_setting('app.skip_weekly_checkin_revision_capture', true), 'false') = 'true' then
    return new;
  end if;

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
create or replace function public.restore_deleted_weekly_checkin(
  p_archive_id uuid,
  p_target_client_id text default null,
  p_restore_revisions boolean default true
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  archived_row public.deleted_weekly_checkins%rowtype;
  restored_checkin_row public.weekly_checkins%rowtype;
  target_client_id text;
  restored_checkin_uuid uuid;
begin
  if not (
    auth.role() = 'service_role'
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  ) then
    raise exception 'Only admins can restore deleted weekly check-ins';
  end if;

  select *
  into archived_row
  from public.deleted_weekly_checkins
  where archive_id = p_archive_id
  for update;

  if not found then
    raise exception 'Archived weekly check-in % not found', p_archive_id;
  end if;

  if archived_row.restored_at is not null then
    raise exception 'Archived weekly check-in % was already restored at %', p_archive_id, archived_row.restored_at;
  end if;

  target_client_id := coalesce(nullif(btrim(p_target_client_id), ''), archived_row.client_id);

  if target_client_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    raise exception 'Target client id "%" is not a valid UUID', target_client_id;
  end if;

  if not exists (
    select 1
    from public.clients client
    where client.id = target_client_id::uuid
  ) then
    raise exception 'Target client % does not exist', target_client_id;
  end if;

  if exists (
    select 1
    from public.weekly_checkins checkin
    where checkin.client_id = target_client_id
      and checkin.week_start_date = archived_row.week_start_date
  ) then
    raise exception 'A weekly check-in already exists for client % on week_start_date %', target_client_id, archived_row.week_start_date;
  end if;

  restored_checkin_row := jsonb_populate_record(
    null::public.weekly_checkins,
    jsonb_set(archived_row.snapshot, '{client_id}', to_jsonb(target_client_id), false)
  );

  perform set_config('app.skip_weekly_checkin_revision_capture', 'true', true);

  insert into public.weekly_checkins
  select (restored_checkin_row).*
  returning id into restored_checkin_uuid;

  if p_restore_revisions then
    insert into public.weekly_checkin_revisions
    select (
      jsonb_populate_record(
        null::public.weekly_checkin_revisions,
        jsonb_set(
          jsonb_set(
            jsonb_set(
              jsonb_set(archived_revision.snapshot, '{checkin_id}', to_jsonb(restored_checkin_uuid), false),
              '{client_id}',
              to_jsonb(target_client_id),
              false
            ),
            '{snapshot,id}',
            to_jsonb(restored_checkin_uuid),
            false
          ),
          '{snapshot,client_id}',
          to_jsonb(target_client_id),
          false
        )
      )
    ).*
    from public.deleted_weekly_checkin_revisions archived_revision
    where archived_revision.archive_id = archived_row.archive_id
    order by archived_revision.revision_no;
  end if;

  update public.deleted_weekly_checkins
  set restored_at = timezone('utc', now()),
      restored_by = auth.uid(),
      restored_checkin_id = restored_checkin_uuid,
      restore_target_client_id = target_client_id
  where archive_id = p_archive_id;

  return restored_checkin_uuid;
end;
$$;
create or replace function public.cleanup_deleted_client_text_references()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.completed_actions where client_id = old.id::text;
  delete from public.client_meetings where client_id = old.id::text;
  delete from public.client_facts where client_id = old.id::text;
  delete from public.client_reminders where client_id = old.id::text;
  delete from public.wins_learnings where client_id = old.id::text;
  delete from public.client_upsells where client_id = old.id::text;
  delete from public.marketing_naming_templates where client_id = old.id::text;
  delete from public.client_meta_oauth_tokens where client_id = old.id::text;
  delete from public.client_integrations where client_id = old.id::text;
  delete from public.onboarding_phases where client_id = old.id::text;
  delete from public.weekly_management_rows where client_id = old.id::text;
  delete from public.marketing_costs_daily where client_id = old.id::text;
  delete from public.leadgen_figma_jobs where client_id = old.id::text;
  delete from public.marketing_campaigns where client_id = old.id::text;

  perform set_config('app.weekly_checkin_delete_reason', 'client_delete', true);
  delete from public.weekly_checkins where client_id = old.id::text;

  return old;
end;
$$;
