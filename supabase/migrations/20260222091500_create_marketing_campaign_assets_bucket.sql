-- Bucket for quick-launch media assets used by campaign publishing flows.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'marketing-campaign-assets',
  'marketing-campaign-assets',
  false,
  52428800,
  array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'video/mp4',
    'video/quicktime',
    'video/webm',
    'video/x-msvideo',
    'video/x-matroska'
  ]
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists "Authenticated users can read marketing campaign assets" on storage.objects;
create policy "Authenticated users can read marketing campaign assets"
on storage.objects
for select
to authenticated
using (bucket_id = 'marketing-campaign-assets');
drop policy if exists "Authenticated users can upload marketing campaign assets" on storage.objects;
create policy "Authenticated users can upload marketing campaign assets"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'marketing-campaign-assets');
drop policy if exists "Authenticated users can update marketing campaign assets" on storage.objects;
create policy "Authenticated users can update marketing campaign assets"
on storage.objects
for update
to authenticated
using (bucket_id = 'marketing-campaign-assets')
with check (bucket_id = 'marketing-campaign-assets');
drop policy if exists "Authenticated users can delete marketing campaign assets" on storage.objects;
create policy "Authenticated users can delete marketing campaign assets"
on storage.objects
for delete
to authenticated
using (bucket_id = 'marketing-campaign-assets');
