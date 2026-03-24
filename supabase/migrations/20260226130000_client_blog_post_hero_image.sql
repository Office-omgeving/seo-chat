-- Persist optional hero image per generated blog post.

alter table public.client_blog_posts
  add column if not exists hero_image_url text not null default '';
