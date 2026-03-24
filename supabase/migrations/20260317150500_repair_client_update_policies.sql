-- Re-assert permissive client edit policies for authenticated team members.
-- Some remote environments still behave as if the legacy owner-only update
-- policy is active for existing client rows.

alter table public.clients enable row level security;
alter table public.client_team_members enable row level security;
drop policy if exists "Users can update own clients" on public.clients;
drop policy if exists "Authenticated users can update clients" on public.clients;
create policy "Authenticated users can update clients"
  on public.clients
  for update
  to authenticated
  using (true)
  with check (true);
drop policy if exists "Allowed users can insert client team members" on public.client_team_members;
drop policy if exists "Allowed users can update client team members" on public.client_team_members;
drop policy if exists "Allowed users can delete client team members" on public.client_team_members;
drop policy if exists "Authenticated users can insert client team members" on public.client_team_members;
drop policy if exists "Authenticated users can update client team members" on public.client_team_members;
drop policy if exists "Authenticated users can delete client team members" on public.client_team_members;
create policy "Authenticated users can insert client team members"
  on public.client_team_members
  for insert
  to authenticated
  with check (true);
create policy "Authenticated users can update client team members"
  on public.client_team_members
  for update
  to authenticated
  using (true)
  with check (true);
create policy "Authenticated users can delete client team members"
  on public.client_team_members
  for delete
  to authenticated
  using (true);
