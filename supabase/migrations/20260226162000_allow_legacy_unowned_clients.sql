-- Keep legacy clients without created_by visible for authenticated users.
-- This prevents older data from disappearing after stricter ownership RLS.

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
        c.created_by is null
        or c.created_by = auth.uid()
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
    created_by is null
    or created_by = auth.uid()
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
    created_by is null
    or created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  )
  with check (
    created_by is null
    or created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  );
create policy "Users can delete own clients"
  on public.clients for delete
  using (
    created_by is null
    or created_by = auth.uid()
    or public.has_role(auth.uid(), 'management'::public.app_role)
  );
