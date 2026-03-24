-- Subscriptions and forecast settings for Costs page
create extension if not exists pgcrypto;
do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'subscription_billing_type'
      and n.nspname = 'public'
  ) then
    create type public.subscription_billing_type as enum (
      'fixed_monthly',
      'usage_based',
      'minimum_commit',
      'hybrid'
    );
  end if;
end
$$;
create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
create table if not exists public.subscription_cost_items (
  id uuid primary key default gen_random_uuid(),
  provider_key text not null,
  name text not null,
  billing_type public.subscription_billing_type not null,
  currency text not null default 'USD',
  amount_per_month numeric(12, 2),
  unit_price numeric(12, 4),
  unit_label text,
  manual_eur_per_month numeric(12, 2),
  active boolean not null default true,
  notes text,
  source_url text,
  source_checked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists subscription_cost_items_provider_key_idx
  on public.subscription_cost_items(provider_key);
create table if not exists public.cost_forecast_settings (
  id integer primary key default 1 check (id = 1),
  analyses_per_month integer not null default 50 check (analyses_per_month >= 0),
  keyword_calls_per_analysis integer not null default 2 check (keyword_calls_per_analysis >= 0),
  blogs_per_month integer not null default 20 check (blogs_per_month >= 0),
  updated_at timestamptz not null default now()
);
drop trigger if exists set_subscription_cost_items_updated_at on public.subscription_cost_items;
create trigger set_subscription_cost_items_updated_at
before update on public.subscription_cost_items
for each row execute function public.set_updated_at_timestamp();
drop trigger if exists set_cost_forecast_settings_updated_at on public.cost_forecast_settings;
create trigger set_cost_forecast_settings_updated_at
before update on public.cost_forecast_settings
for each row execute function public.set_updated_at_timestamp();
alter table public.subscription_cost_items enable row level security;
alter table public.cost_forecast_settings enable row level security;
drop policy if exists subscription_cost_items_anon_all on public.subscription_cost_items;
create policy subscription_cost_items_anon_all
on public.subscription_cost_items
for all
to anon
using (true)
with check (true);
drop policy if exists subscription_cost_items_auth_all on public.subscription_cost_items;
create policy subscription_cost_items_auth_all
on public.subscription_cost_items
for all
to authenticated
using (true)
with check (true);
drop policy if exists cost_forecast_settings_anon_all on public.cost_forecast_settings;
create policy cost_forecast_settings_anon_all
on public.cost_forecast_settings
for all
to anon
using (true)
with check (true);
drop policy if exists cost_forecast_settings_auth_all on public.cost_forecast_settings;
create policy cost_forecast_settings_auth_all
on public.cost_forecast_settings
for all
to authenticated
using (true)
with check (true);
grant select, insert, update, delete on table public.subscription_cost_items to anon, authenticated;
grant select, insert, update, delete on table public.cost_forecast_settings to anon, authenticated;
insert into public.subscription_cost_items (
  provider_key,
  name,
  billing_type,
  currency,
  unit_price,
  unit_label,
  notes,
  source_url,
  source_checked_at
)
values
  (
    'dataforseo',
    'DataForSEO',
    'usage_based',
    'USD',
    0.075,
    'per request',
    'Pay-as-you-go keyword volume calls.',
    'https://docs.dataforseo.com/v3/keywords_data-google_ads-search_volume-live/',
    now()
  ),
  (
    'supabase',
    'Supabase',
    'fixed_monthly',
    'USD',
    null,
    null,
    'Baseline Pro-plan voor productie.',
    'https://supabase.com/pricing',
    now()
  ),
  (
    'openai',
    'OpenAI',
    'usage_based',
    'USD',
    null,
    'per usage (manueel)',
    'Voeg je eigen usage-rate toe indien nodig.',
    'https://platform.openai.com/pricing',
    now()
  ),
  (
    'google_maps',
    'Google Maps',
    'usage_based',
    'USD',
    null,
    'per usage (manueel)',
    'Voeg je eigen usage-rate toe indien nodig.',
    'https://mapsplatform.google.com/pricing/',
    now()
  )
on conflict (provider_key) do update
set
  name = excluded.name,
  billing_type = excluded.billing_type,
  currency = excluded.currency,
  unit_price = coalesce(public.subscription_cost_items.unit_price, excluded.unit_price),
  unit_label = coalesce(public.subscription_cost_items.unit_label, excluded.unit_label),
  notes = coalesce(public.subscription_cost_items.notes, excluded.notes),
  source_url = excluded.source_url,
  source_checked_at = excluded.source_checked_at;
update public.subscription_cost_items
set amount_per_month = 25
where provider_key = 'supabase'
  and amount_per_month is null;
insert into public.cost_forecast_settings (
  id,
  analyses_per_month,
  keyword_calls_per_analysis,
  blogs_per_month
)
values (1, 50, 2, 20)
on conflict (id) do nothing;
