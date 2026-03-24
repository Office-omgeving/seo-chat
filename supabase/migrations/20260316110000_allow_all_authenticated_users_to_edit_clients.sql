-- Allow every authenticated team member to update client master data.
-- The client edit flow also syncs client_team_members, so both tables need aligned RLS.

drop policy if exists "Users can update own clients" on public.clients;
drop policy if exists "Authenticated users can update clients" on public.clients;
create policy "Authenticated users can update clients"
  on public.clients for update
  using (auth.uid() is not null)
  with check (auth.uid() is not null);
drop policy if exists "Allowed users can insert client team members" on public.client_team_members;
drop policy if exists "Allowed users can update client team members" on public.client_team_members;
drop policy if exists "Allowed users can delete client team members" on public.client_team_members;
create policy "Authenticated users can insert client team members"
  on public.client_team_members for insert
  with check (auth.uid() is not null);
create policy "Authenticated users can update client team members"
  on public.client_team_members for update
  using (auth.uid() is not null)
  with check (auth.uid() is not null);
create policy "Authenticated users can delete client team members"
  on public.client_team_members for delete
  using (auth.uid() is not null);
