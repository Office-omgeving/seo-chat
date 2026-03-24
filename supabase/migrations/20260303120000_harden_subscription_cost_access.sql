-- Harden costs configuration tables for production use.
-- Removes anonymous access and keeps access behind authenticated users only.

alter table public.subscription_cost_items enable row level security;
alter table public.cost_forecast_settings enable row level security;
drop policy if exists subscription_cost_items_anon_all on public.subscription_cost_items;
drop policy if exists subscription_cost_items_auth_all on public.subscription_cost_items;
create policy subscription_cost_items_auth_all
on public.subscription_cost_items
for all
to authenticated
using (auth.uid() is not null)
with check (auth.uid() is not null);
drop policy if exists cost_forecast_settings_anon_all on public.cost_forecast_settings;
drop policy if exists cost_forecast_settings_auth_all on public.cost_forecast_settings;
create policy cost_forecast_settings_auth_all
on public.cost_forecast_settings
for all
to authenticated
using (auth.uid() is not null)
with check (auth.uid() is not null);
revoke all on table public.subscription_cost_items from anon;
revoke all on table public.cost_forecast_settings from anon;
grant select, insert, update, delete on table public.subscription_cost_items to authenticated;
grant select, insert, update, delete on table public.cost_forecast_settings to authenticated;
