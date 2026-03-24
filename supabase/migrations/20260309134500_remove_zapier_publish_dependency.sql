CREATE OR REPLACE FUNCTION public.can_publish_campaign(p_campaign_id UUID)
RETURNS TABLE(ok BOOLEAN, reason TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_campaign public.marketing_campaigns%ROWTYPE;
  v_form_count INTEGER := 0;
  v_missing_meta_forms INTEGER := 0;
  v_missing_ghl_subaccounts INTEGER := 0;
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
  INTO v_missing_meta_forms
  FROM public.marketing_campaign_forms f
  WHERE f.campaign_id = p_campaign_id
    AND f.is_current
    AND f.status <> 'archived'
    AND COALESCE(trim(f.meta_form_id), '') = '';

  IF v_missing_meta_forms > 0 THEN
    RETURN QUERY SELECT false, 'Niet alle forms hebben een gekoppelde Meta lead form';
    RETURN;
  END IF;

  SELECT count(*)
  INTO v_missing_ghl_subaccounts
  FROM public.marketing_campaign_forms f
  WHERE f.campaign_id = p_campaign_id
    AND f.is_current
    AND f.status <> 'archived'
    AND COALESCE(trim(f.ghl_subaccount_id), '') = '';

  IF v_missing_ghl_subaccounts > 0 THEN
    RETURN QUERY SELECT false, 'Niet alle forms hebben een GHL subaccount';
    RETURN;
  END IF;

  RETURN QUERY SELECT true, ''::TEXT;
END;
$$;
