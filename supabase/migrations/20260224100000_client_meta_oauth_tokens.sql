-- Per-client Meta OAuth tokens for "Connect Meta" flows.
-- Tokens are only accessible through service-role edge functions.

CREATE TABLE IF NOT EXISTS public.client_meta_oauth_tokens (
  client_id TEXT PRIMARY KEY,
  meta_user_id TEXT,
  access_token TEXT NOT NULL,
  token_type TEXT,
  expires_at TIMESTAMPTZ,
  scopes TEXT[] NOT NULL DEFAULT '{}'::text[],
  granted_scopes TEXT[] NOT NULL DEFAULT '{}'::text[],
  declined_scopes TEXT[] NOT NULL DEFAULT '{}'::text[],
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_client_meta_oauth_tokens_expires_at
  ON public.client_meta_oauth_tokens (expires_at);
ALTER TABLE public.client_meta_oauth_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can manage client meta oauth tokens" ON public.client_meta_oauth_tokens;
CREATE POLICY "Service role can manage client meta oauth tokens"
  ON public.client_meta_oauth_tokens FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
DROP TRIGGER IF EXISTS update_client_meta_oauth_tokens_updated_at ON public.client_meta_oauth_tokens;
CREATE TRIGGER update_client_meta_oauth_tokens_updated_at
  BEFORE UPDATE ON public.client_meta_oauth_tokens
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
