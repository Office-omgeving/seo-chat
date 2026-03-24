create or replace function public.normalize_client_name(value text)
returns text
language sql
immutable
as $$
  select lower(regexp_replace(btrim(coalesce(value, '')), '\s+', ' ', 'g'))
$$;
create temporary table tmp_client_duplicate_merge_map (
  canonical_client_id uuid not null,
  duplicate_client_id uuid not null primary key,
  merged_name text not null
) on commit drop;
insert into tmp_client_duplicate_merge_map (canonical_client_id, duplicate_client_id, merged_name)
values
  ('3e3bdb1c-1be1-4adf-8177-423a75a5d247'::uuid, 'a0fa1cc4-b784-431f-984f-7b1c9cb3c7d4'::uuid, 'Belivert'),
  ('e2989739-498f-44b9-9fb7-18d80ee6cd6f'::uuid, '2fbfd24f-140c-4086-8c8b-d22eed8a18c1'::uuid, 'Maelsteen Real Estate'),
  ('f8472374-7027-4df4-b411-10f447675988'::uuid, 'e7e7566c-6864-42a8-8637-d853c2fb295b'::uuid, 'Oppolia Creations'),
  ('e85a7414-0878-4057-b003-96cfa8dca18b'::uuid, '41cbf63c-e21c-41d6-b0aa-80b2cfb8418b'::uuid, 'Verfspuiten Kempen'),
  ('e85a7414-0878-4057-b003-96cfa8dca18b'::uuid, '480126ad-9284-44a1-acf1-a4e6fb6d58e0'::uuid, 'Verfspuiten Kempen');
do $$
declare
  invalid_count integer;
begin
  select count(*)
  into invalid_count
  from tmp_client_duplicate_merge_map map
  left join public.clients canonical on canonical.id = map.canonical_client_id
  left join public.clients duplicate on duplicate.id = map.duplicate_client_id
  where canonical.id is null
     or duplicate.id is null
     or public.normalize_client_name(canonical.name) <> public.normalize_client_name(duplicate.name);

  if invalid_count > 0 then
    raise exception 'Duplicate client merge map is ongeldig of de live data wijkt af van de audit.';
  end if;
end;
$$;
create temporary table tmp_client_merge_members on commit drop as
select distinct
  groups.canonical_client_id,
  groups.merged_name,
  groups.member_client_id
from (
  select
    map.canonical_client_id,
    map.merged_name,
    map.canonical_client_id as member_client_id
  from tmp_client_duplicate_merge_map map
  union all
  select
    map.canonical_client_id,
    map.merged_name,
    map.duplicate_client_id as member_client_id
  from tmp_client_duplicate_merge_map map
) as groups;
create temporary table tmp_onboarding_source_map on commit drop as
with candidate_groups as (
  select distinct canonical_client_id
  from tmp_client_merge_members
)
select
  group_ids.canonical_client_id,
  coalesce(
    (
      select member.member_client_id
      from tmp_client_merge_members member
      join public.clients client_row on client_row.id = member.member_client_id
      where member.canonical_client_id = group_ids.canonical_client_id
        and client_row.client_type in ('agency', 'ppa_agency')
        and exists (
          select 1
          from public.onboarding_phases phase
          where phase.client_id = member.member_client_id::text
        )
      order by
        case when member.member_client_id = group_ids.canonical_client_id then 0 else 1 end,
        client_row.created_at asc,
        member.member_client_id
      limit 1
    ),
    (
      select member.member_client_id
      from tmp_client_merge_members member
      join public.clients client_row on client_row.id = member.member_client_id
      where member.canonical_client_id = group_ids.canonical_client_id
        and exists (
          select 1
          from public.onboarding_phases phase
          where phase.client_id = member.member_client_id::text
        )
      order by
        (
          select count(*)
          from public.onboarding_phases phase
          where phase.client_id = member.member_client_id::text
        ) desc,
        case when member.member_client_id = group_ids.canonical_client_id then 0 else 1 end,
        client_row.created_at asc,
        member.member_client_id
      limit 1
    )
  ) as source_client_id
from candidate_groups group_ids;
create temporary table tmp_onboarding_phase_seed on commit drop as
select
  source_map.canonical_client_id,
  phase.label,
  phase.sort_order,
  phase.is_current,
  phase.is_completed,
  phase.completed_at,
  phase.created_at,
  phase.id
from tmp_onboarding_source_map source_map
join public.onboarding_phases phase
  on phase.client_id = source_map.source_client_id::text
where source_map.source_client_id is not null;
create temporary table tmp_client_team_seed on commit drop as
select
  members.canonical_client_id as client_id,
  team.user_id,
  team.assignment_role,
  bool_or(team.is_primary) as wants_primary,
  min(team.created_at) as created_at,
  (
    array_agg(team.created_by order by team.created_at asc, team.id asc)
    filter (where team.created_by is not null)
  )[1] as created_by
from public.client_team_members team
join tmp_client_merge_members members
  on members.member_client_id = team.client_id
group by
  members.canonical_client_id,
  team.user_id,
  team.assignment_role;
with group_members as (
  select
    members.canonical_client_id,
    members.merged_name,
    client_row.*
  from tmp_client_merge_members members
  join public.clients client_row
    on client_row.id = members.member_client_id
),
aggregated as (
  select
    member.canonical_client_id,
    max(member.merged_name) as merged_name,
    case
      when bool_or(member.client_type in ('agency', 'ppa_agency')) and bool_or(member.client_type in ('ppa', 'ppa_agency')) then 'ppa_agency'
      when bool_or(member.client_type = 'ppa') then 'ppa'
      when bool_or(member.client_type = 'ppl') then 'ppl'
      else 'agency'
    end as merged_client_type,
    (
      array_agg(nullif(btrim(member.contact_person), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.contact_person), '') is not null)
    )[1] as merged_contact_person,
    (
      array_agg(nullif(btrim(member.contact_email), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.contact_email), '') is not null)
    )[1] as merged_contact_email,
    (
      array_agg(nullif(btrim(member.contact_phone), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.contact_phone), '') is not null)
    )[1] as merged_contact_phone,
    (
      array_agg(nullif(btrim(member.contract_type), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.contract_type), '') is not null)
    )[1] as merged_contract_type,
    max(case when member.client_type in ('agency', 'ppa_agency') then coalesce(member.mrr, 0) else 0 end) as merged_fee,
    greatest(
      max(coalesce(member.cost_per_lead, 0)),
      max(case when member.client_type = 'ppl' and coalesce(member.cost_per_lead, 0) = 0 then coalesce(member.mrr, 0) else 0 end)
    ) as merged_cost_per_lead,
    greatest(
      max(coalesce(member.cost_per_appointment, 0)),
      max(case when member.client_type in ('ppa', 'ppa_agency') and coalesce(member.cost_per_appointment, 0) = 0 then coalesce(member.mrr, 0) else 0 end)
    ) as merged_cost_per_appointment,
    min(nullif(btrim(member.start_date), '')) filter (where nullif(btrim(member.start_date), '') is not null) as merged_start_date,
    (
      array_agg(nullif(btrim(member.initial_lead_type), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.initial_lead_type), '') is not null)
    )[1] as merged_initial_lead_type,
    (
      array_agg(nullif(btrim(member.funnel_type), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.funnel_type), '') is not null)
    )[1] as merged_funnel_type,
    (
      array_agg(nullif(btrim(member.account_manager_id), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.account_manager_id), '') is not null)
    )[1] as merged_account_manager_id,
    (
      array_agg(nullif(btrim(member.account_manager_name), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.account_manager_name), '') is not null)
    )[1] as merged_account_manager_name,
    case
      when bool_or(member.relationship_status = 'negative') then 'negative'
      when bool_or(member.relationship_status = 'neutral') then 'neutral'
      else 'positive'
    end as merged_relationship_status,
    (
      array_agg(nullif(btrim(member.website), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.website), '') is not null)
    )[1] as merged_website,
    (
      array_agg(nullif(btrim(member.sector), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.sector), '') is not null)
    )[1] as merged_sector,
    (
      array_agg(nullif(btrim(member.notes), '') order by case when member.id = member.canonical_client_id then 0 else 1 end, member.created_at, member.id)
      filter (where nullif(btrim(member.notes), '') is not null)
    )[1] as merged_notes,
    (
      select coalesce(jsonb_agg(entry.value order by entry.value::text), '[]'::jsonb)
      from (
        select distinct contact_entry as value
        from group_members nested
        cross join lateral jsonb_array_elements(
          case
            when jsonb_typeof(coalesce(nested.contacts, '[]'::jsonb)) = 'array' then coalesce(nested.contacts, '[]'::jsonb)
            else '[]'::jsonb
          end
        ) as contact_entry
        where nested.canonical_client_id = member.canonical_client_id
      ) as entry
    ) as merged_contacts,
    (
      select coalesce(array_agg(distinct value order by value), '{}'::text[])
      from group_members nested
      cross join lateral unnest(coalesce(nested.kpis, '{}'::text[])) as value
      where nested.canonical_client_id = member.canonical_client_id
        and nullif(btrim(value), '') is not null
    ) as merged_kpis,
    (
      select coalesce(array_agg(distinct value order by value), '{}'::text[])
      from group_members nested
      cross join lateral unnest(coalesce(nested.ad_accounts, '{}'::text[])) as value
      where nested.canonical_client_id = member.canonical_client_id
        and nullif(btrim(value), '') is not null
    ) as merged_ad_accounts,
    (
      select coalesce(array_agg(distinct value order by value), '{}'::text[])
      from group_members nested
      cross join lateral unnest(coalesce(nested.regions, '{}'::text[])) as value
      where nested.canonical_client_id = member.canonical_client_id
        and nullif(btrim(value), '') is not null
    ) as merged_regions,
    (
      select coalesce(candidate.branding, '{}'::jsonb)
      from group_members candidate
      where candidate.canonical_client_id = member.canonical_client_id
        and coalesce(candidate.branding, '{}'::jsonb) <> '{}'::jsonb
      order by case when candidate.id = candidate.canonical_client_id then 0 else 1 end, candidate.created_at, candidate.id
      limit 1
    ) as merged_branding
  from group_members member
  group by member.canonical_client_id
)
update public.clients target
set
  name = aggregated.merged_name,
  contact_person = coalesce(aggregated.merged_contact_person, target.contact_person, ''),
  contact_email = coalesce(aggregated.merged_contact_email, target.contact_email, ''),
  contact_phone = coalesce(aggregated.merged_contact_phone, target.contact_phone, ''),
  contacts = coalesce(aggregated.merged_contacts, target.contacts, '[]'::jsonb),
  contract_type = case
    when aggregated.merged_client_type = 'ppa_agency' then 'PPA + Agency'
    when aggregated.merged_client_type = 'ppa' then 'PPA'
    when aggregated.merged_client_type = 'ppl' then 'PPL'
    else coalesce(aggregated.merged_contract_type, nullif(target.contract_type, ''), 'Performance')
  end,
  mrr = coalesce(aggregated.merged_fee, 0),
  cost_per_lead = coalesce(aggregated.merged_cost_per_lead, 0),
  cost_per_appointment = coalesce(aggregated.merged_cost_per_appointment, 0),
  start_date = coalesce(aggregated.merged_start_date, target.start_date, ''),
  initial_lead_type = coalesce(aggregated.merged_initial_lead_type, target.initial_lead_type, ''),
  funnel_type = coalesce(aggregated.merged_funnel_type, target.funnel_type, ''),
  kpis = coalesce(aggregated.merged_kpis, '{}'::text[]),
  account_manager_id = coalesce(aggregated.merged_account_manager_id, target.account_manager_id, ''),
  account_manager_name = coalesce(aggregated.merged_account_manager_name, target.account_manager_name, ''),
  relationship_status = aggregated.merged_relationship_status,
  status = case
    when aggregated.merged_relationship_status = 'negative' then 'critical'
    when aggregated.merged_relationship_status = 'neutral' then 'risk'
    else 'healthy'
  end,
  ad_accounts = coalesce(aggregated.merged_ad_accounts, '{}'::text[]),
  regions = coalesce(aggregated.merged_regions, '{}'::text[]),
  client_type = aggregated.merged_client_type,
  website = coalesce(aggregated.merged_website, target.website, ''),
  sector = coalesce(aggregated.merged_sector, target.sector, ''),
  notes = coalesce(aggregated.merged_notes, target.notes, ''),
  branding = coalesce(aggregated.merged_branding, target.branding, '{}'::jsonb)
from aggregated
where target.id = aggregated.canonical_client_id;
update public.weekly_checkins target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.weekly_management_rows target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.completed_actions target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.client_meetings target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.client_facts target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.client_reminders target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.wins_learnings target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.client_upsells target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.marketing_naming_templates target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.marketing_campaigns target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.marketing_costs_daily target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.weekly_checkin_revisions target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.client_meta_oauth_tokens target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.leadgen_figma_jobs target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
update public.client_analyses target
set client_id = map.canonical_client_id
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id;
update public.client_blog_batches target
set client_id = map.canonical_client_id
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id;
update public.client_blog_posts target
set client_id = map.canonical_client_id
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id;
update public.user_alert_rules target
set client_id = map.canonical_client_id
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id;
update public.user_mentions target
set client_id = map.canonical_client_id
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id;
update public.cost_logs target
set client_id = map.canonical_client_id
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id;
update public.client_integrations target
set
  wrike_account_id = coalesce(nullif(btrim(target.wrike_account_id), ''), nullif(btrim(source.wrike_account_id), ''), target.wrike_account_id),
  wrike_space_id = coalesce(nullif(btrim(target.wrike_space_id), ''), nullif(btrim(source.wrike_space_id), ''), target.wrike_space_id),
  wrike_folder_id = coalesce(nullif(btrim(target.wrike_folder_id), ''), nullif(btrim(source.wrike_folder_id), ''), target.wrike_folder_id),
  ghl_location_id = coalesce(nullif(btrim(target.ghl_location_id), ''), nullif(btrim(source.ghl_location_id), ''), target.ghl_location_id),
  ghl_pipeline_id = coalesce(nullif(btrim(target.ghl_pipeline_id), ''), nullif(btrim(source.ghl_pipeline_id), ''), target.ghl_pipeline_id),
  ghl_calendar_id = coalesce(nullif(btrim(target.ghl_calendar_id), ''), nullif(btrim(source.ghl_calendar_id), ''), target.ghl_calendar_id),
  metadata = case
    when coalesce(source.metadata, '{}'::jsonb) = '{}'::jsonb then target.metadata
    when coalesce(target.metadata, '{}'::jsonb) = '{}'::jsonb then source.metadata
    else source.metadata || target.metadata
  end,
  meta_ad_account_id = coalesce(nullif(btrim(target.meta_ad_account_id), ''), nullif(btrim(source.meta_ad_account_id), ''), target.meta_ad_account_id),
  google_ads_customer_id = coalesce(nullif(btrim(target.google_ads_customer_id), ''), nullif(btrim(source.google_ads_customer_id), ''), target.google_ads_customer_id),
  meta_page_id = coalesce(nullif(btrim(target.meta_page_id), ''), nullif(btrim(source.meta_page_id), ''), target.meta_page_id),
  meta_instagram_account_id = coalesce(nullif(btrim(target.meta_instagram_account_id), ''), nullif(btrim(source.meta_instagram_account_id), ''), target.meta_instagram_account_id),
  default_ghl_subaccount_id = coalesce(nullif(btrim(target.default_ghl_subaccount_id), ''), nullif(btrim(source.default_ghl_subaccount_id), ''), target.default_ghl_subaccount_id)
from public.client_integrations source
join tmp_client_duplicate_merge_map map
  on map.duplicate_client_id::text = source.client_id
where target.client_id = map.canonical_client_id::text;
update public.client_integrations target
set client_id = map.canonical_client_id::text
from tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text
  and not exists (
    select 1
    from public.client_integrations existing
    where existing.client_id = map.canonical_client_id::text
  );
delete from public.client_integrations target
using tmp_client_duplicate_merge_map map
where target.client_id = map.duplicate_client_id::text;
delete from public.onboarding_phases target
using tmp_client_merge_members members
where target.client_id = members.member_client_id::text;
insert into public.onboarding_phases (
  client_id,
  label,
  sort_order,
  is_current,
  is_completed,
  completed_at,
  created_at
)
select
  seed.canonical_client_id::text,
  seed.label,
  row_number() over (
    partition by seed.canonical_client_id
    order by seed.sort_order asc, seed.created_at asc, seed.id asc
  ) - 1,
  false,
  seed.is_completed,
  seed.completed_at,
  seed.created_at
from tmp_onboarding_phase_seed seed;
update public.onboarding_phases phase
set is_current = true
from (
  select distinct on (seed.canonical_client_id)
    seed.canonical_client_id,
    seed.label
  from tmp_onboarding_phase_seed seed
  where seed.is_current
  order by seed.canonical_client_id, seed.sort_order asc, seed.created_at asc, seed.id asc
) chosen
where phase.client_id = chosen.canonical_client_id::text
  and phase.label = chosen.label;
update public.onboarding_phases phase
set is_current = false
where phase.client_id in (
  select distinct canonical_client_id::text
  from tmp_onboarding_phase_seed
)
  and phase.id not in (
    select current_phase.id
    from public.onboarding_phases current_phase
    where current_phase.client_id in (
      select distinct canonical_client_id::text
      from tmp_onboarding_phase_seed
    )
      and current_phase.is_current
  );
delete from public.client_team_members team
using tmp_client_merge_members members
where team.client_id = members.member_client_id;
insert into public.client_team_members (
  client_id,
  user_id,
  assignment_role,
  is_primary,
  created_by,
  created_at,
  updated_at
)
select
  seed.client_id,
  seed.user_id,
  seed.assignment_role,
  false,
  seed.created_by,
  coalesce(seed.created_at, timezone('utc', now())),
  timezone('utc', now())
from tmp_client_team_seed seed;
update public.client_team_members target
set is_primary = true
from (
  select
    chosen.id
  from (
    select
      team.id,
      row_number() over (
        partition by team.client_id
        order by seed.created_at asc nulls last, team.created_at asc, team.id asc
      ) as row_no
    from public.client_team_members team
    join tmp_client_team_seed seed
      on seed.client_id = team.client_id
     and seed.user_id = team.user_id
     and seed.assignment_role = team.assignment_role
    where team.assignment_role = 'account_manager'::public.app_role
      and seed.wants_primary
  ) chosen
  where chosen.row_no = 1
) primary_rows
where target.id = primary_rows.id;
select public.sync_primary_account_manager_mirror(canonical_ids.canonical_client_id)
from (
  select distinct canonical_client_id
  from tmp_client_merge_members
) canonical_ids;
delete from public.clients target
using tmp_client_duplicate_merge_map map
where target.id = map.duplicate_client_id;
create unique index if not exists clients_normalized_name_unique
  on public.clients (public.normalize_client_name(name));
