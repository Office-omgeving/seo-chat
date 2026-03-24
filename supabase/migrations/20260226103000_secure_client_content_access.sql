-- Tighten RLS policies for client/content tables.
-- Replaces permissive "using (true)" rules with owner or management checks.

create or replace function public.can_access_client(p_client_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.clients c
    where c.id = p_client_id
      and (
        c.created_by = auth.uid()
        or public.has_role(auth.uid(), 'management'::public.app_role)
      )
  )
$$;
-- clients
drop policy if exists "Users can view own clients" on public.clients;
drop policy if exists "Users can create own clients" on public.clients;
drop policy if exists "Users can update own clients" on public.clients;
drop policy if exists "Users can delete own clients" on public.clients;
create policy "Users can view own clients"
  on public.clients for select
  using (
    created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  );
create policy "Users can create own clients"
  on public.clients for insert
  with check (
    auth.uid() is not null
    and (
      created_by is null
      or created_by = auth.uid()
      or public.has_role(auth.uid(), 'management'::public.app_role)
    )
  );
create policy "Users can update own clients"
  on public.clients for update
  using (
    created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  )
  with check (
    created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  );
create policy "Users can delete own clients"
  on public.clients for delete
  using (
    created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  );
-- client_analyses
drop policy if exists "Users can read client analyses" on public.client_analyses;
drop policy if exists "Users can insert client analyses" on public.client_analyses;
drop policy if exists "Users can update client analyses" on public.client_analyses;
drop policy if exists "Users can delete client analyses" on public.client_analyses;
create policy "Users can read client analyses"
  on public.client_analyses for select
  using (public.can_access_client(client_id));
create policy "Users can insert client analyses"
  on public.client_analyses for insert
  with check (public.can_access_client(client_id));
create policy "Users can update client analyses"
  on public.client_analyses for update
  using (public.can_access_client(client_id))
  with check (public.can_access_client(client_id));
create policy "Users can delete client analyses"
  on public.client_analyses for delete
  using (public.can_access_client(client_id));
-- client_blog_batches
drop policy if exists "Users can read client blog batches" on public.client_blog_batches;
drop policy if exists "Users can insert client blog batches" on public.client_blog_batches;
drop policy if exists "Users can update client blog batches" on public.client_blog_batches;
drop policy if exists "Users can delete client blog batches" on public.client_blog_batches;
create policy "Users can read client blog batches"
  on public.client_blog_batches for select
  using (public.can_access_client(client_id));
create policy "Users can insert client blog batches"
  on public.client_blog_batches for insert
  with check (public.can_access_client(client_id));
create policy "Users can update client blog batches"
  on public.client_blog_batches for update
  using (public.can_access_client(client_id))
  with check (public.can_access_client(client_id));
create policy "Users can delete client blog batches"
  on public.client_blog_batches for delete
  using (public.can_access_client(client_id));
-- client_blog_posts
drop policy if exists "Users can read client blog posts" on public.client_blog_posts;
drop policy if exists "Users can insert client blog posts" on public.client_blog_posts;
drop policy if exists "Users can update client blog posts" on public.client_blog_posts;
drop policy if exists "Users can delete client blog posts" on public.client_blog_posts;
create policy "Users can read client blog posts"
  on public.client_blog_posts for select
  using (public.can_access_client(client_id));
create policy "Users can insert client blog posts"
  on public.client_blog_posts for insert
  with check (
    public.can_access_client(client_id)
    and exists (
      select 1
      from public.client_blog_batches b
      where b.id = batch_id
        and b.client_id = client_id
    )
  );
create policy "Users can update client blog posts"
  on public.client_blog_posts for update
  using (public.can_access_client(client_id))
  with check (
    public.can_access_client(client_id)
    and exists (
      select 1
      from public.client_blog_batches b
      where b.id = batch_id
        and b.client_id = client_id
    )
  );
create policy "Users can delete client blog posts"
  on public.client_blog_posts for delete
  using (public.can_access_client(client_id));
