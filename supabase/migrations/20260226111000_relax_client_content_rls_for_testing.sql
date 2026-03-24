-- Temporary testing migration: allow unauthenticated testing of client/content flows.
-- IMPORTANT: revert before production rollout.

-- clients
drop policy if exists "Users can view own clients" on public.clients;
drop policy if exists "Users can create own clients" on public.clients;
drop policy if exists "Users can update own clients" on public.clients;
drop policy if exists "Users can delete own clients" on public.clients;
create policy "Users can view own clients"
  on public.clients for select
  using (true);
create policy "Users can create own clients"
  on public.clients for insert
  with check (true);
create policy "Users can update own clients"
  on public.clients for update
  using (true)
  with check (true);
create policy "Users can delete own clients"
  on public.clients for delete
  using (true);
-- client_analyses
drop policy if exists "Users can read client analyses" on public.client_analyses;
drop policy if exists "Users can insert client analyses" on public.client_analyses;
drop policy if exists "Users can update client analyses" on public.client_analyses;
drop policy if exists "Users can delete client analyses" on public.client_analyses;
create policy "Users can read client analyses"
  on public.client_analyses for select
  using (true);
create policy "Users can insert client analyses"
  on public.client_analyses for insert
  with check (true);
create policy "Users can update client analyses"
  on public.client_analyses for update
  using (true)
  with check (true);
create policy "Users can delete client analyses"
  on public.client_analyses for delete
  using (true);
-- client_blog_batches
drop policy if exists "Users can read client blog batches" on public.client_blog_batches;
drop policy if exists "Users can insert client blog batches" on public.client_blog_batches;
drop policy if exists "Users can update client blog batches" on public.client_blog_batches;
drop policy if exists "Users can delete client blog batches" on public.client_blog_batches;
create policy "Users can read client blog batches"
  on public.client_blog_batches for select
  using (true);
create policy "Users can insert client blog batches"
  on public.client_blog_batches for insert
  with check (true);
create policy "Users can update client blog batches"
  on public.client_blog_batches for update
  using (true)
  with check (true);
create policy "Users can delete client blog batches"
  on public.client_blog_batches for delete
  using (true);
-- client_blog_posts
drop policy if exists "Users can read client blog posts" on public.client_blog_posts;
drop policy if exists "Users can insert client blog posts" on public.client_blog_posts;
drop policy if exists "Users can update client blog posts" on public.client_blog_posts;
drop policy if exists "Users can delete client blog posts" on public.client_blog_posts;
create policy "Users can read client blog posts"
  on public.client_blog_posts for select
  using (true);
create policy "Users can insert client blog posts"
  on public.client_blog_posts for insert
  with check (true);
create policy "Users can update client blog posts"
  on public.client_blog_posts for update
  using (true)
  with check (true);
create policy "Users can delete client blog posts"
  on public.client_blog_posts for delete
  using (true);
