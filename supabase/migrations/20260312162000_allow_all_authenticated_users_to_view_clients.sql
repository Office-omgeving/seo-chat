drop policy if exists "Users can view assigned clients" on public.clients;
drop policy if exists "Users can view own clients" on public.clients;
create policy "Authenticated users can view clients"
  on public.clients for select
  using (auth.uid() is not null);
