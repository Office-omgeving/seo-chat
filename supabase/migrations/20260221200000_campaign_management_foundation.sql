-- Campaign management foundation for Marketing Hub (Meta-first)

ALTER TABLE public.client_integrations
  ADD COLUMN IF NOT EXISTS meta_page_id TEXT,
  ADD COLUMN IF NOT EXISTS meta_instagram_account_id TEXT,
  ADD COLUMN IF NOT EXISTS default_ghl_subaccount_id TEXT,
  ADD COLUMN IF NOT EXISTS default_meta_timezone TEXT NOT NULL DEFAULT 'Europe/Brussels',
  ADD COLUMN IF NOT EXISTS account_mapping_mode TEXT NOT NULL DEFAULT 'client_mapping'
    CHECK (account_mapping_mode IN ('client_mapping', 'last_used', 'manual'));
CREATE TABLE IF NOT EXISTS public.marketing_platform_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider TEXT NOT NULL UNIQUE CHECK (provider IN ('meta', 'zapier', 'ghl')),
  display_name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'disconnected' CHECK (status IN ('connected', 'disconnected', 'error')),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  configured_by UUID REFERENCES auth.users(id),
  configured_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS public.marketing_naming_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id TEXT,
  scope TEXT NOT NULL CHECK (scope IN ('campaign', 'ad_set', 'ad', 'form')),
  name TEXT NOT NULL,
  pattern TEXT NOT NULL,
  required_tokens TEXT[] NOT NULL DEFAULT '{}'::text[],
  optional_tokens TEXT[] NOT NULL DEFAULT '{}'::text[],
  is_default BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (client_id, scope, name)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_marketing_naming_default_per_scope
  ON public.marketing_naming_templates (COALESCE(client_id, ''), scope)
  WHERE is_default;
CREATE TABLE IF NOT EXISTS public.marketing_form_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  objective TEXT NOT NULL DEFAULT 'lead_generation',
  questions JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_system BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS public.marketing_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id TEXT NOT NULL,
  platform TEXT NOT NULL DEFAULT 'meta' CHECK (platform = 'meta'),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'planned', 'live', 'paused', 'ended')),
  objective TEXT NOT NULL CHECK (objective IN ('lead_generation', 'traffic', 'engagement', 'conversions', 'sales', 'awareness', 'other')),

  name TEXT NOT NULL,
  country TEXT,
  timezone TEXT NOT NULL DEFAULT 'Europe/Brussels',

  meta_account_id TEXT,
  meta_page_id TEXT,
  meta_instagram_account_id TEXT,
  source_meta_campaign_id TEXT,

  schedule_mode TEXT NOT NULL DEFAULT 'immediate' CHECK (schedule_mode IN ('immediate', 'scheduled')),
  start_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  end_at TIMESTAMPTZ,

  budget_type TEXT NOT NULL DEFAULT 'daily' CHECK (budget_type IN ('daily', 'lifetime')),
  budget_value NUMERIC(12, 2) NOT NULL DEFAULT 0,

  naming_tokens JSONB NOT NULL DEFAULT '{}'::jsonb,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,

  latest_spend NUMERIC(12, 2) NOT NULL DEFAULT 0,
  latest_cpl NUMERIC(12, 2) NOT NULL DEFAULT 0,
  metrics_refreshed_at TIMESTAMPTZ,

  imported_from_meta BOOLEAN NOT NULL DEFAULT false,
  last_published_at TIMESTAMPTZ,
  paused_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,

  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CHECK (budget_value >= 0),
  CHECK (end_at IS NULL OR end_at >= start_at)
);
CREATE INDEX IF NOT EXISTS idx_marketing_campaigns_client ON public.marketing_campaigns (client_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_campaigns_status ON public.marketing_campaigns (status);
CREATE INDEX IF NOT EXISTS idx_marketing_campaigns_objective ON public.marketing_campaigns (objective);
CREATE INDEX IF NOT EXISTS idx_marketing_campaigns_meta_account ON public.marketing_campaigns (meta_account_id);
CREATE TABLE IF NOT EXISTS public.marketing_campaign_forms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES public.marketing_campaigns(id) ON DELETE CASCADE,
  form_group_id UUID NOT NULL DEFAULT gen_random_uuid(),
  version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),
  is_current BOOLEAN NOT NULL DEFAULT true,

  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'ready', 'live', 'archived')),
  objective TEXT NOT NULL DEFAULT 'lead_generation' CHECK (objective IN ('lead_generation', 'traffic', 'engagement', 'conversions', 'sales', 'awareness', 'other')),

  name TEXT NOT NULL,
  naming_value TEXT NOT NULL DEFAULT '',
  template_id UUID REFERENCES public.marketing_form_templates(id) ON DELETE SET NULL,

  meta_form_id TEXT,
  ghl_subaccount_id TEXT NOT NULL,

  questions JSONB NOT NULL DEFAULT '[]'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

  published_at TIMESTAMPTZ,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (campaign_id, form_group_id, version)
);
CREATE INDEX IF NOT EXISTS idx_marketing_campaign_forms_campaign ON public.marketing_campaign_forms (campaign_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_campaign_forms_group ON public.marketing_campaign_forms (campaign_id, form_group_id, version DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_marketing_campaign_forms_current
  ON public.marketing_campaign_forms (campaign_id, form_group_id)
  WHERE is_current;
CREATE TABLE IF NOT EXISTS public.marketing_form_zaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id UUID NOT NULL REFERENCES public.marketing_campaign_forms(id) ON DELETE CASCADE,
  ghl_subaccount_id TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),

  zapier_zap_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'inactive', 'error', 'archived')),
  is_usable BOOLEAN NOT NULL DEFAULT false,
  is_reusable BOOLEAN NOT NULL DEFAULT false,

  trigger_signature TEXT NOT NULL DEFAULT 'meta_lead_form',
  action_signature TEXT NOT NULL DEFAULT 'leadconnector_upsert',
  validation_notes TEXT,
  error_message TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  last_verified_at TIMESTAMPTZ,

  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (form_id, ghl_subaccount_id, version)
);
CREATE INDEX IF NOT EXISTS idx_marketing_form_zaps_form ON public.marketing_form_zaps (form_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_form_zaps_status ON public.marketing_form_zaps (status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_marketing_form_zaps_reusable
  ON public.marketing_form_zaps (form_id, ghl_subaccount_id)
  WHERE status = 'active' AND is_usable;
CREATE TABLE IF NOT EXISTS public.marketing_campaign_metrics_hourly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES public.marketing_campaigns(id) ON DELETE CASCADE,
  source TEXT NOT NULL DEFAULT 'meta',
  captured_at TIMESTAMPTZ NOT NULL DEFAULT date_trunc('hour', now()),
  spend NUMERIC(12, 2) NOT NULL DEFAULT 0,
  leads INTEGER NOT NULL DEFAULT 0,
  cpl NUMERIC(12, 2) GENERATED ALWAYS AS (
    CASE WHEN leads > 0 THEN round((spend / leads)::numeric, 2) ELSE 0::numeric END
  ) STORED,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (campaign_id, captured_at)
);
CREATE INDEX IF NOT EXISTS idx_marketing_campaign_metrics_hourly_campaign
  ON public.marketing_campaign_metrics_hourly (campaign_id, captured_at DESC);
ALTER TABLE public.marketing_platform_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_naming_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_form_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_campaign_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_form_zaps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_campaign_metrics_hourly ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated users can view marketing platform connections" ON public.marketing_platform_connections;
CREATE POLICY "Authenticated users can view marketing platform connections"
  ON public.marketing_platform_connections FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can update marketing platform connections" ON public.marketing_platform_connections;
CREATE POLICY "Authenticated users can update marketing platform connections"
  ON public.marketing_platform_connections FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view marketing naming templates" ON public.marketing_naming_templates;
CREATE POLICY "Authenticated users can view marketing naming templates"
  ON public.marketing_naming_templates FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit marketing naming templates" ON public.marketing_naming_templates;
CREATE POLICY "Authenticated users can edit marketing naming templates"
  ON public.marketing_naming_templates FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view marketing form templates" ON public.marketing_form_templates;
CREATE POLICY "Authenticated users can view marketing form templates"
  ON public.marketing_form_templates FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit marketing form templates" ON public.marketing_form_templates;
CREATE POLICY "Authenticated users can edit marketing form templates"
  ON public.marketing_form_templates FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view marketing campaigns" ON public.marketing_campaigns;
CREATE POLICY "Authenticated users can view marketing campaigns"
  ON public.marketing_campaigns FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit marketing campaigns" ON public.marketing_campaigns;
CREATE POLICY "Authenticated users can edit marketing campaigns"
  ON public.marketing_campaigns FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view marketing campaign forms" ON public.marketing_campaign_forms;
CREATE POLICY "Authenticated users can view marketing campaign forms"
  ON public.marketing_campaign_forms FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit marketing campaign forms" ON public.marketing_campaign_forms;
CREATE POLICY "Authenticated users can edit marketing campaign forms"
  ON public.marketing_campaign_forms FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view marketing form zaps" ON public.marketing_form_zaps;
CREATE POLICY "Authenticated users can view marketing form zaps"
  ON public.marketing_form_zaps FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit marketing form zaps" ON public.marketing_form_zaps;
CREATE POLICY "Authenticated users can edit marketing form zaps"
  ON public.marketing_form_zaps FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view marketing campaign metrics" ON public.marketing_campaign_metrics_hourly;
CREATE POLICY "Authenticated users can view marketing campaign metrics"
  ON public.marketing_campaign_metrics_hourly FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit marketing campaign metrics" ON public.marketing_campaign_metrics_hourly;
CREATE POLICY "Authenticated users can edit marketing campaign metrics"
  ON public.marketing_campaign_metrics_hourly FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE OR REPLACE FUNCTION public.can_publish_campaign(p_campaign_id UUID)
RETURNS TABLE(ok BOOLEAN, reason TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_campaign public.marketing_campaigns%ROWTYPE;
  v_form_count INTEGER := 0;
  v_missing_zaps INTEGER := 0;
BEGIN
  SELECT *
  INTO v_campaign
  FROM public.marketing_campaigns
  WHERE id = p_campaign_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Campagne niet gevonden';
    RETURN;
  END IF;

  IF v_campaign.objective <> 'lead_generation' THEN
    RETURN QUERY SELECT true, ''::TEXT;
    RETURN;
  END IF;

  SELECT count(*)
  INTO v_form_count
  FROM public.marketing_campaign_forms f
  WHERE f.campaign_id = p_campaign_id
    AND f.is_current
    AND f.status <> 'archived';

  IF v_form_count = 0 THEN
    RETURN QUERY SELECT false, 'Lead Generation vereist minstens 1 actieve form';
    RETURN;
  END IF;

  SELECT count(*)
  INTO v_missing_zaps
  FROM public.marketing_campaign_forms f
  WHERE f.campaign_id = p_campaign_id
    AND f.is_current
    AND f.status <> 'archived'
    AND NOT EXISTS (
      SELECT 1
      FROM public.marketing_form_zaps z
      WHERE z.form_id = f.id
        AND z.ghl_subaccount_id = f.ghl_subaccount_id
        AND z.status = 'active'
        AND z.is_usable
    );

  IF v_missing_zaps > 0 THEN
    RETURN QUERY SELECT false, 'Niet alle forms hebben een bruikbare actieve Zap';
    RETURN;
  END IF;

  RETURN QUERY SELECT true, ''::TEXT;
END;
$$;
CREATE OR REPLACE FUNCTION public.enforce_marketing_campaign_publish_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ok BOOLEAN;
  v_reason TEXT;
BEGIN
  IF NEW.status = 'live' AND COALESCE(OLD.status, '') <> 'live' THEN
    SELECT ok, reason
    INTO v_ok, v_reason
    FROM public.can_publish_campaign(NEW.id)
    LIMIT 1;

    IF NOT COALESCE(v_ok, false) THEN
      RAISE EXCEPTION 'Campagne publiceren geblokkeerd: %', COALESCE(v_reason, 'Onbekende fout');
    END IF;

    NEW.last_published_at := COALESCE(NEW.last_published_at, now());
  END IF;

  IF NEW.status = 'paused' AND COALESCE(OLD.status, '') <> 'paused' THEN
    NEW.paused_at := now();
  END IF;

  IF NEW.status = 'ended' AND COALESCE(OLD.status, '') <> 'ended' THEN
    NEW.ended_at := now();
  END IF;

  IF NEW.updated_by IS NULL THEN
    NEW.updated_by := auth.uid();
  END IF;

  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS update_marketing_platform_connections_updated_at ON public.marketing_platform_connections;
CREATE TRIGGER update_marketing_platform_connections_updated_at
  BEFORE UPDATE ON public.marketing_platform_connections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_marketing_naming_templates_updated_at ON public.marketing_naming_templates;
CREATE TRIGGER update_marketing_naming_templates_updated_at
  BEFORE UPDATE ON public.marketing_naming_templates
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_marketing_form_templates_updated_at ON public.marketing_form_templates;
CREATE TRIGGER update_marketing_form_templates_updated_at
  BEFORE UPDATE ON public.marketing_form_templates
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS enforce_marketing_campaign_publish_rules ON public.marketing_campaigns;
CREATE TRIGGER enforce_marketing_campaign_publish_rules
  BEFORE UPDATE ON public.marketing_campaigns
  FOR EACH ROW EXECUTE FUNCTION public.enforce_marketing_campaign_publish_rules();
DROP TRIGGER IF EXISTS update_marketing_campaigns_updated_at ON public.marketing_campaigns;
CREATE TRIGGER update_marketing_campaigns_updated_at
  BEFORE UPDATE ON public.marketing_campaigns
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_marketing_campaign_forms_updated_at ON public.marketing_campaign_forms;
CREATE TRIGGER update_marketing_campaign_forms_updated_at
  BEFORE UPDATE ON public.marketing_campaign_forms
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_marketing_form_zaps_updated_at ON public.marketing_form_zaps;
CREATE TRIGGER update_marketing_form_zaps_updated_at
  BEFORE UPDATE ON public.marketing_form_zaps
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS update_marketing_campaign_metrics_hourly_updated_at ON public.marketing_campaign_metrics_hourly;
CREATE TRIGGER update_marketing_campaign_metrics_hourly_updated_at
  BEFORE UPDATE ON public.marketing_campaign_metrics_hourly
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
INSERT INTO public.marketing_platform_connections (provider, display_name, status, metadata)
VALUES
  ('meta', 'Meta Business', 'disconnected', '{}'::jsonb),
  ('zapier', 'Zapier', 'disconnected', '{}'::jsonb),
  ('ghl', 'GoHighLevel (LeadConnector)', 'disconnected', '{}'::jsonb)
ON CONFLICT (provider) DO NOTHING;
INSERT INTO public.marketing_naming_templates (
  client_id,
  scope,
  name,
  pattern,
  required_tokens,
  optional_tokens,
  is_default,
  is_active
)
VALUES
  (NULL, 'campaign', 'Default Campaign', '{client}-{objective}-{country}-{date}', ARRAY['client', 'objective', 'country', 'date'], ARRAY['platform', 'audience', 'offer'], true, true),
  (NULL, 'ad_set', 'Default Ad Set', '{client}-{audience}-{country}-{date}', ARRAY['client', 'country', 'date'], ARRAY['objective', 'audience', 'offer', 'platform'], true, true),
  (NULL, 'ad', 'Default Ad', '{client}-{offer}-{audience}-{date}', ARRAY['client', 'date'], ARRAY['objective', 'country', 'offer', 'audience', 'platform'], true, true),
  (NULL, 'form', 'Default Form', '{client}-{objective}-{country}-{date}-form-v{version}', ARRAY['client', 'objective', 'country', 'date'], ARRAY['offer', 'audience', 'platform', 'version'], true, true)
ON CONFLICT (client_id, scope, name) DO NOTHING;
INSERT INTO public.marketing_form_templates (name, description, objective, questions, is_system, is_active, sort_order)
VALUES
  (
    'B2B Lead Intake',
    'Standaard kwalificatie voor B2B leads.',
    'lead_generation',
    '[
      {"type":"multiple_choice","label":"Bedrijfsgrootte","required":true,"options":["1-10","11-50","51-200","200+"]},
      {"type":"short_text","label":"Wat is je grootste uitdaging?","required":true},
      {"type":"phone","label":"Telefoonnummer","required":true},
      {"type":"email","label":"E-mailadres","required":true},
      {"type":"yes_no","label":"Mag ons team je bellen?","required":true}
    ]'::jsonb,
    true,
    true,
    10
  ),
  (
    'Intake Call',
    'Snelle intake voor een kennismakingscall.',
    'lead_generation',
    '[
      {"type":"short_text","label":"Bedrijfsnaam","required":true},
      {"type":"email","label":"Zakelijk e-mailadres","required":true},
      {"type":"phone","label":"Telefoonnummer","required":true},
      {"type":"multiple_choice","label":"Gewenste timing","required":true,"options":["Deze week","Binnen 2 weken","Binnen een maand"]},
      {"type":"yes_no","label":"Heb je al lopende campagnes?","required":true}
    ]'::jsonb,
    true,
    true,
    20
  ),
  (
    'High Ticket Screening',
    'Kwalificatie voor high-ticket aanbod.',
    'lead_generation',
    '[
      {"type":"multiple_choice","label":"Beschikbaar budget","required":true,"options":["<2k","2k-5k","5k-10k",">10k"]},
      {"type":"short_text","label":"Wat wil je bereiken in 90 dagen?","required":true},
      {"type":"email","label":"E-mailadres","required":true},
      {"type":"phone","label":"Telefoonnummer","required":true},
      {"type":"yes_no","label":"Sta je open voor een strategische call?","required":true}
    ]'::jsonb,
    true,
    true,
    30
  )
ON CONFLICT (name) DO NOTHING;
