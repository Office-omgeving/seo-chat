-- Enforce exactly one global role per user. Historical duplicates in public.user_roles
-- can accidentally keep admin privileges active even when the intended role in auth metadata differs.

create or replace function public.get_user_role(_user_id uuid)
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.user_roles
  where user_id = _user_id
  order by id asc
  limit 1
$$;
create temporary table _normalized_user_roles on commit drop as
with normalized_roles as (
  select
    au.id as user_id,
    coalesce(
      case
        when (au.raw_user_meta_data ->> 'role') in ('admin', 'account_manager', 'operations', 'marketing', 'callcenter', 'management')
          then (au.raw_user_meta_data ->> 'role')::public.app_role
        else null
      end,
      (array_agg(ur.role order by ur.id asc))[1]
    ) as role
  from auth.users au
  left join public.user_roles ur
    on ur.user_id = au.id
  group by au.id, au.raw_user_meta_data
)
select user_id, role
from normalized_roles
where role is not null;
delete from public.user_roles;
insert into public.user_roles (user_id, role)
select user_id, role
from _normalized_user_roles;
create unique index if not exists user_roles_user_id_unique_idx
  on public.user_roles (user_id);
