alter table public.user_mentions
  add column if not exists mentioned_user_name text not null default '',
  add column if not exists author_acknowledged_at timestamptz;
update public.user_mentions as mention
set mentioned_user_name = coalesce(nullif(trim(profile.display_name), ''), mention.mentioned_user_name)
from public.profiles as profile
where profile.user_id = mention.mentioned_user_id
  and coalesce(mention.mentioned_user_name, '') = '';
create index if not exists idx_user_mentions_author_seen_inbox
  on public.user_mentions (author_user_id, is_resolved, author_acknowledged_at, resolved_at desc);
drop policy if exists "Mentioned users can resolve own mentions" on public.user_mentions;
drop policy if exists "Mention participants can update own mentions" on public.user_mentions;
create policy "Mention participants can update own mentions"
  on public.user_mentions for update
  using (
    auth.uid() = mentioned_user_id
    or auth.uid() = author_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  )
  with check (
    auth.uid() = mentioned_user_id
    or auth.uid() = author_user_id
    or coalesce(public.has_role(auth.uid(), 'admin'::public.app_role), false)
  );
