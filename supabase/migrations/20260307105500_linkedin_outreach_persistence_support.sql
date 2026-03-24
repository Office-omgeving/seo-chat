alter table public.linkedin_outreach_prospects
  add column if not exists profile_summary text not null default '',
  add column if not exists personalization_hooks text[] not null default '{}';
insert into public.clients (
  id,
  name,
  contact_person,
  contact_email,
  contact_phone,
  contacts,
  contract_type,
  mrr,
  start_date,
  initial_lead_type,
  funnel_type,
  kpis,
  account_manager_id,
  account_manager_name,
  status,
  ad_accounts,
  regions,
  created_by
)
values (
  'ac0f8f1d-bc94-4b5f-8f22-b0f62be8923c',
  'Client Check - LinkedIn Outreach',
  '',
  '',
  '',
  '[]'::jsonb,
  '',
  0,
  '',
  '',
  '',
  '{}',
  '',
  '',
  'healthy',
  '{}',
  '{}',
  null
)
on conflict (id) do nothing;
comment on column public.linkedin_outreach_prospects.profile_summary is
  'Korte samenvatting van de profiel- en activity-signalen gebruikt voor personalisatie.';
comment on column public.linkedin_outreach_prospects.personalization_hooks is
  'Concrete personalisatiehoeken die in het outreach-bericht gebruikt kunnen worden.';
