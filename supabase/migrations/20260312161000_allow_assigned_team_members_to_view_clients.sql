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
        or public.has_role(auth.uid(), 'admin'::public.app_role)
        or public.has_role(auth.uid(), 'management'::public.app_role)
        or exists (
          select 1
          from public.client_team_members ctm
          where ctm.client_id = c.id
            and ctm.user_id = auth.uid()
        )
      )
  )
$$;
drop policy if exists "Users can view own clients" on public.clients;
create policy "Users can view assigned clients"
  on public.clients for select
  using (public.can_access_client(id));
