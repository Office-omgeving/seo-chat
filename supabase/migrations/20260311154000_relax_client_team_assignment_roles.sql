alter table public.client_team_members
  drop constraint if exists client_team_members_client_id_user_id_key;
create unique index if not exists idx_client_team_members_unique_assignment
  on public.client_team_members (client_id, user_id, assignment_role);
create or replace function public.enforce_client_team_member_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  global_role public.app_role;
begin
  global_role := public.get_user_role(new.user_id);

  if global_role is null then
    raise exception 'Kan geen klantteamlid koppelen zonder globale rol';
  end if;

  if new.is_primary and new.assignment_role <> 'account_manager'::public.app_role then
    raise exception 'Alleen een account manager kan primair zijn op een klant';
  end if;

  return new;
end;
$$;
