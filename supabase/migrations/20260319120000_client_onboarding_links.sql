-- Secure per-client onboarding links for customer-facing Meta connect flows.

CREATE TABLE IF NOT EXISTS public.client_onboarding_links (
  client_id UUID PRIMARY KEY REFERENCES public.clients(id) ON DELETE CASCADE,
  token_nonce TEXT NOT NULL,
  token_hash TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'shared', 'opened', 'meta_connected', 'completed', 'expired', 'revoked')),
  expires_at TIMESTAMPTZ NOT NULL,
  shared_at TIMESTAMPTZ,
  first_opened_at TIMESTAMPTZ,
  last_opened_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  requirements JSONB NOT NULL DEFAULT '{}'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_client_onboarding_links_expires_at
  ON public.client_onboarding_links (expires_at);
ALTER TABLE public.client_onboarding_links ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can manage client onboarding links" ON public.client_onboarding_links;
CREATE POLICY "Service role can manage client onboarding links"
  ON public.client_onboarding_links FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
DROP TRIGGER IF EXISTS update_client_onboarding_links_updated_at ON public.client_onboarding_links;
CREATE TRIGGER update_client_onboarding_links_updated_at
  BEFORE UPDATE ON public.client_onboarding_links
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
