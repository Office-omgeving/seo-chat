ALTER TABLE public.wins_learnings
  ADD COLUMN IF NOT EXISTS sector text;
NOTIFY pgrst, 'reload schema';
