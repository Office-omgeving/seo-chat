ALTER TABLE public.marketing_campaigns
  ADD COLUMN IF NOT EXISTS latest_leads INTEGER NOT NULL DEFAULT 0;
