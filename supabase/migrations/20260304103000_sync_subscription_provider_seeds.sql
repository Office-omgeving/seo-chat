-- Apply subscription provider seed updates on already-running environments.
-- This backfills rows that were added after the original subscription migration.

insert into public.subscription_cost_items (
  provider_key,
  name,
  billing_type,
  currency,
  amount_per_month,
  unit_price,
  unit_label,
  active,
  notes,
  source_url,
  source_checked_at
)
values
  (
    'dataforseo_backlinks',
    'DataForSEO Backlinks',
    'minimum_commit',
    'USD',
    50,
    null,
    null,
    false,
    'Module vereist aparte activering in DataForSEO account.',
    'https://help.dataforseo.com/en/articles/12954384-important-updates-to-backlinks-api-access',
    now()
  ),
  (
    'dataforseo_llm_mentions',
    'DataForSEO LLM Mentions',
    'minimum_commit',
    'USD',
    50,
    null,
    null,
    false,
    'Module vereist aparte activering in DataForSEO account.',
    'https://help.dataforseo.com/en/articles/11976320-get-access-to-our-llm-optimization-api',
    now()
  )
on conflict (provider_key) do nothing;
update public.subscription_cost_items
set
  name = 'DataForSEO Backlinks',
  billing_type = 'minimum_commit',
  currency = 'USD',
  amount_per_month = coalesce(amount_per_month, 50),
  unit_price = null,
  unit_label = null,
  notes = coalesce(notes, 'Module vereist aparte activering in DataForSEO account.'),
  source_url = 'https://help.dataforseo.com/en/articles/12954384-important-updates-to-backlinks-api-access',
  source_checked_at = now()
where provider_key = 'dataforseo_backlinks';
update public.subscription_cost_items
set
  name = 'DataForSEO LLM Mentions',
  billing_type = 'minimum_commit',
  currency = 'USD',
  amount_per_month = coalesce(amount_per_month, 50),
  unit_price = null,
  unit_label = null,
  notes = coalesce(notes, 'Module vereist aparte activering in DataForSEO account.'),
  source_url = 'https://help.dataforseo.com/en/articles/11976320-get-access-to-our-llm-optimization-api',
  source_checked_at = now()
where provider_key = 'dataforseo_llm_mentions';
update public.subscription_cost_items
set
  active = false,
  notes = case
    when notes is null or btrim(notes) = '' then 'Deprecated provider: Google Maps gebruikt deze flow niet meer.'
    when notes ilike '%deprecated provider: google maps gebruikt deze flow niet meer.%' then notes
    else notes || ' Deprecated provider: Google Maps gebruikt deze flow niet meer.'
  end
where provider_key = 'google_maps';
