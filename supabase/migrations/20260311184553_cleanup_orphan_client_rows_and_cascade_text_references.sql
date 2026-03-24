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
  delete from public.weekly_checkins where client_id = old.id::text;
  return old;
end;
$$;
drop trigger if exists cleanup_client_text_references_before_delete on public.clients;
create trigger cleanup_client_text_references_before_delete
before delete on public.clients
for each row
execute function public.cleanup_deleted_client_text_references();
delete from public.completed_actions target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.client_meetings target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.client_facts target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.client_reminders target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.wins_learnings target
where target.client_id is not null
  and not exists (
    select 1
    from public.clients client
    where client.id::text = target.client_id
  );
delete from public.client_upsells target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.marketing_naming_templates target
where target.client_id is not null
  and not exists (
    select 1
    from public.clients client
    where client.id::text = target.client_id
  );
delete from public.client_meta_oauth_tokens target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.client_integrations target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.onboarding_phases target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.weekly_management_rows target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.marketing_costs_daily target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.leadgen_figma_jobs target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.marketing_campaigns target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
delete from public.weekly_checkins target
where not exists (
  select 1
  from public.clients client
  where client.id::text = target.client_id
);
