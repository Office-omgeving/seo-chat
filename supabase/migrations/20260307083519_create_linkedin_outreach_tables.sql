create or replace function public.touch_linkedin_outreach_record()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    new.created_at = coalesce(new.created_at, timezone('utc', now()));
    new.created_by = coalesce(new.created_by, auth.uid());
  end if;

  new.updated_at = timezone('utc', now());
  new.updated_by = coalesce(auth.uid(), new.updated_by, new.created_by);
  return new;
end;
$$;
create table public.linkedin_outreach_generators (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  created_by uuid default auth.uid(),
  updated_by uuid default auth.uid(),
  name text not null,
  description text not null default '',
  role_description text not null default '',
  requirements text[] not null default '{}',
  company_blurb text not null default '',
  tone text not null check (tone in ('direct', 'warm', 'executive', 'challenger')),
  channel text not null check (channel in ('email', 'linkedin')),
  recruiter_name text not null default '',
  recruiter_title text not null default '',
  recruiter_company text not null default '',
  is_archived boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint linkedin_outreach_generators_name_not_blank check (btrim(name) <> ''),
  constraint linkedin_outreach_generators_id_client_unique unique (id, client_id)
);
create table public.linkedin_outreach_prospects (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  generator_id uuid not null,
  created_by uuid default auth.uid(),
  updated_by uuid default auth.uid(),
  linkedin_url text not null default '',
  name text not null,
  title text not null default '',
  company text not null default '',
  status text not null default 'gegenereerd' check (status in ('gegenereerd', 'verzonden')),
  channel text not null check (channel in ('email', 'linkedin')),
  message_subject text not null default '',
  message_draft text not null,
  notes text not null default '',
  sent_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint linkedin_outreach_prospects_name_not_blank check (btrim(name) <> ''),
  constraint linkedin_outreach_prospects_message_not_blank check (btrim(message_draft) <> ''),
  constraint linkedin_outreach_prospects_generator_fkey
    foreign key (generator_id, client_id)
    references public.linkedin_outreach_generators(id, client_id)
    on delete cascade
);
create index linkedin_outreach_generators_client_id_idx
  on public.linkedin_outreach_generators (client_id, created_at desc);
create index linkedin_outreach_generators_created_by_idx
  on public.linkedin_outreach_generators (created_by);
create index linkedin_outreach_prospects_client_id_idx
  on public.linkedin_outreach_prospects (client_id, created_at desc);
create index linkedin_outreach_prospects_generator_id_idx
  on public.linkedin_outreach_prospects (generator_id, created_at desc);
create index linkedin_outreach_prospects_status_idx
  on public.linkedin_outreach_prospects (status);
create trigger touch_linkedin_outreach_generators
before insert or update on public.linkedin_outreach_generators
for each row
execute function public.touch_linkedin_outreach_record();
create trigger touch_linkedin_outreach_prospects
before insert or update on public.linkedin_outreach_prospects
for each row
execute function public.touch_linkedin_outreach_record();
alter table public.linkedin_outreach_generators enable row level security;
alter table public.linkedin_outreach_prospects enable row level security;
create policy "linkedin_outreach_generators_select"
on public.linkedin_outreach_generators
for select
using (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_generators_insert"
on public.linkedin_outreach_generators
for insert
with check (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_generators_update"
on public.linkedin_outreach_generators
for update
using (
  auth.uid() is not null
  and public.can_access_client(client_id)
)
with check (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_generators_delete"
on public.linkedin_outreach_generators
for delete
using (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_prospects_select"
on public.linkedin_outreach_prospects
for select
using (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_prospects_insert"
on public.linkedin_outreach_prospects
for insert
with check (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_prospects_update"
on public.linkedin_outreach_prospects
for update
using (
  auth.uid() is not null
  and public.can_access_client(client_id)
)
with check (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
create policy "linkedin_outreach_prospects_delete"
on public.linkedin_outreach_prospects
for delete
using (
  auth.uid() is not null
  and public.can_access_client(client_id)
);
comment on table public.linkedin_outreach_generators is
  'Configuratie per outreach-generator voor LinkedIn Outreach.';
comment on table public.linkedin_outreach_prospects is
  'Opgeslagen prospects met het gegenereerde of verzonden outreach-bericht.';
