alter table public.clients
  add column if not exists relationship_status_set boolean not null default false;
update public.clients
set relationship_status_set = true
where relationship_status in ('positive', 'negative');
