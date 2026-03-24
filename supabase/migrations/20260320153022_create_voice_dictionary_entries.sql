create table if not exists public.voice_dictionary_entries (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) on delete restrict,
  heard_as text not null,
  canonical text not null,
  is_active boolean not null default true,
  constraint voice_dictionary_entries_heard_as_length
    check (char_length(btrim(heard_as)) between 2 and 120),
  constraint voice_dictionary_entries_canonical_length
    check (char_length(btrim(canonical)) between 2 and 120)
);
create unique index if not exists voice_dictionary_entries_heard_as_active_idx
  on public.voice_dictionary_entries ((lower(btrim(heard_as))))
  where is_active = true;
create index if not exists voice_dictionary_entries_created_at_idx
  on public.voice_dictionary_entries (created_at desc);
drop trigger if exists update_voice_dictionary_entries_updated_at on public.voice_dictionary_entries;
create trigger update_voice_dictionary_entries_updated_at
  before update on public.voice_dictionary_entries
  for each row execute function public.update_updated_at_column();
alter table public.voice_dictionary_entries enable row level security;
drop policy if exists "Authenticated users can read voice dictionary entries" on public.voice_dictionary_entries;
create policy "Authenticated users can read voice dictionary entries"
  on public.voice_dictionary_entries
  for select
  to authenticated
  using (is_active = true);
drop policy if exists "Authenticated users can insert voice dictionary entries" on public.voice_dictionary_entries;
create policy "Authenticated users can insert voice dictionary entries"
  on public.voice_dictionary_entries
  for insert
  to authenticated
  with check (auth.uid() = created_by);
grant select, insert on table public.voice_dictionary_entries to authenticated;
grant select, insert, update, delete on table public.voice_dictionary_entries to service_role;
