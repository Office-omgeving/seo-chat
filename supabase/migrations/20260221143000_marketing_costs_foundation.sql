-- Foundation for loading daily marketing costs per client.

ALTER TABLE public.client_integrations
  ADD COLUMN IF NOT EXISTS meta_ad_account_id TEXT,
  ADD COLUMN IF NOT EXISTS google_ads_customer_id TEXT;
CREATE INDEX IF NOT EXISTS idx_client_integrations_meta_account
  ON public.client_integrations (meta_ad_account_id);
CREATE TABLE IF NOT EXISTS public.marketing_costs_daily (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id TEXT NOT NULL,
  source TEXT NOT NULL CHECK (source IN ('meta')),
  ad_account_id TEXT NOT NULL,
  cost_date DATE NOT NULL,
  spend NUMERIC(14, 2) NOT NULL DEFAULT 0,
  impressions INTEGER,
  clicks INTEGER,
  currency TEXT,
  raw JSONB NOT NULL DEFAULT '{}'::jsonb,
  synced_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (client_id, source, ad_account_id, cost_date)
);
CREATE INDEX IF NOT EXISTS idx_marketing_costs_daily_client_date
  ON public.marketing_costs_daily (client_id, cost_date DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_costs_daily_source_date
  ON public.marketing_costs_daily (source, cost_date DESC);
ALTER TABLE public.marketing_costs_daily ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated users can read marketing costs" ON public.marketing_costs_daily;
CREATE POLICY "Authenticated users can read marketing costs"
  ON public.marketing_costs_daily FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Service role can insert marketing costs" ON public.marketing_costs_daily;
CREATE POLICY "Service role can insert marketing costs"
  ON public.marketing_costs_daily FOR INSERT
  WITH CHECK (auth.role() = 'service_role');
DROP POLICY IF EXISTS "Service role can update marketing costs" ON public.marketing_costs_daily;
CREATE POLICY "Service role can update marketing costs"
  ON public.marketing_costs_daily FOR UPDATE
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
DROP POLICY IF EXISTS "Service role can delete marketing costs" ON public.marketing_costs_daily;
CREATE POLICY "Service role can delete marketing costs"
  ON public.marketing_costs_daily FOR DELETE
  USING (auth.role() = 'service_role');
DROP TRIGGER IF EXISTS update_marketing_costs_daily_updated_at ON public.marketing_costs_daily;
CREATE TRIGGER update_marketing_costs_daily_updated_at
  BEFORE UPDATE ON public.marketing_costs_daily
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
