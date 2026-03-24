alter table public.profiles
  add column if not exists mention_email_enabled boolean not null default true;
alter table public.user_mentions
  add column if not exists email_notification_status text not null default 'pending',
  add column if not exists email_notification_sent_at timestamptz,
  add column if not exists email_notification_last_attempt_at timestamptz,
  add column if not exists email_notification_error text;
alter table public.user_mentions
  drop constraint if exists user_mentions_email_notification_status_check;
alter table public.user_mentions
  add constraint user_mentions_email_notification_status_check
  check (email_notification_status in ('pending', 'sent', 'skipped', 'failed'));
create index if not exists idx_user_mentions_email_notification_status
  on public.user_mentions (email_notification_status, created_at desc);
