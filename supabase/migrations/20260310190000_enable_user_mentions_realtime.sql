DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.user_mentions;
EXCEPTION
  WHEN duplicate_object THEN NULL;
  WHEN undefined_object THEN NULL;
END;
$$;
