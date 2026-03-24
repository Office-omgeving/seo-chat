ALTER TABLE public.client_integrations
  ADD COLUMN IF NOT EXISTS default_website_url TEXT,
  ADD COLUMN IF NOT EXISTS default_call_to_action TEXT,
  ADD COLUMN IF NOT EXISTS default_audience_preset_id TEXT;
ALTER TABLE public.marketing_campaigns
  ADD COLUMN IF NOT EXISTS source_meta_adset_id TEXT,
  ADD COLUMN IF NOT EXISTS website_url TEXT,
  ADD COLUMN IF NOT EXISTS call_to_action TEXT,
  ADD COLUMN IF NOT EXISTS audience_preset_id TEXT,
  ADD COLUMN IF NOT EXISTS launch_mode TEXT NOT NULL DEFAULT 'advanced'
    CHECK (launch_mode IN ('cockpit', 'advanced')),
  ADD COLUMN IF NOT EXISTS latest_clicks INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS latest_impressions INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS latest_cpc NUMERIC(12, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS latest_ctr NUMERIC(7, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS runtime_summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS runtime_refreshed_at TIMESTAMPTZ;
ALTER TABLE public.marketing_campaign_metrics_hourly
  ADD COLUMN IF NOT EXISTS clicks INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS impressions INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ctr NUMERIC(7, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cpc NUMERIC(12, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS primary_result_value NUMERIC(12, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS primary_result_label TEXT;
UPDATE public.marketing_campaigns
SET
  source_meta_adset_id = COALESCE(source_meta_adset_id, NULLIF(payload->>'targetMetaAdsetId', '')),
  website_url = COALESCE(website_url, NULLIF(payload->>'websiteUrl', '')),
  call_to_action = COALESCE(call_to_action, NULLIF(payload->>'callToAction', '')),
  audience_preset_id = COALESCE(audience_preset_id, NULLIF(payload->>'audiencePresetId', '')),
  launch_mode = COALESCE(NULLIF(launch_mode, ''), 'advanced');
CREATE OR REPLACE FUNCTION public.can_publish_campaign(p_campaign_id UUID)
RETURNS TABLE(ok BOOLEAN, reason TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_campaign public.marketing_campaigns%ROWTYPE;
  v_form_count INTEGER := 0;
  v_missing_routes INTEGER := 0;
BEGIN
  SELECT *
  INTO v_campaign
  FROM public.marketing_campaigns
  WHERE id = p_campaign_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Campagne niet gevonden';
    RETURN;
  END IF;

  IF v_campaign.objective = 'traffic' THEN
    IF COALESCE(trim(v_campaign.website_url), '') = '' THEN
      RETURN QUERY SELECT false, 'Traffic vereist een website URL';
      RETURN;
    END IF;

    RETURN QUERY SELECT true, ''::TEXT;
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
  INTO v_missing_routes
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

  IF v_missing_routes > 0 THEN
    RETURN QUERY SELECT false, 'Niet alle forms hebben een bruikbare delivery-route (direct GHL of fallback)';
    RETURN;
  END IF;

  RETURN QUERY SELECT true, ''::TEXT;
END;
$$;
