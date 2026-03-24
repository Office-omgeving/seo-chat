-- Store optional media sources per blog batch.

alter table public.client_blog_batches
  add column if not exists media_folder_url text not null default '',
  add column if not exists image_urls text[] not null default '{}';
