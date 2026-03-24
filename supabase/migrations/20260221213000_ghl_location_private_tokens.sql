-- Per-location private API keys for GoHighLevel sub-accounts.

CREATE TABLE IF NOT EXISTS public.ghl_location_tokens (
  location_id TEXT PRIMARY KEY,
  company_id TEXT,
  location_name TEXT,
  api_key TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ghl_location_tokens_company
  ON public.ghl_location_tokens (company_id);
ALTER TABLE public.ghl_location_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can manage ghl location tokens" ON public.ghl_location_tokens;
CREATE POLICY "Service role can manage ghl location tokens"
  ON public.ghl_location_tokens FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
DROP TRIGGER IF EXISTS update_ghl_location_tokens_updated_at ON public.ghl_location_tokens;
CREATE TRIGGER update_ghl_location_tokens_updated_at
  BEFORE UPDATE ON public.ghl_location_tokens
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
