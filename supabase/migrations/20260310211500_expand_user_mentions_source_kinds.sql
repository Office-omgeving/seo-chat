alter table public.user_mentions
  drop constraint if exists user_mentions_source_kind_check;
alter table public.user_mentions
  add constraint user_mentions_source_kind_check
  check (source_kind in ('account_manager_log', 'operations_item', 'performance_note'));
