-- Direct GHL lead delivery logging + generic publish validation message

CREATE TABLE IF NOT EXISTS public.marketing_lead_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source TEXT NOT NULL DEFAULT 'meta',
  received_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  leadgen_id TEXT,
  meta_form_id TEXT,
  meta_campaign_id TEXT,

  campaign_id UUID REFERENCES public.marketing_campaigns(id) ON DELETE SET NULL,
  form_id UUID REFERENCES public.marketing_campaign_forms(id) ON DELETE SET NULL,
  ghl_subaccount_id TEXT,

  status TEXT NOT NULL CHECK (status IN ('received', 'delivered', 'failed', 'ignored')),
  error_message TEXT,

  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  delivery_response JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_marketing_lead_events_received
  ON public.marketing_lead_events (received_at DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_lead_events_status
  ON public.marketing_lead_events (status, received_at DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_lead_events_form
  ON public.marketing_lead_events (form_id, received_at DESC);
ALTER TABLE public.marketing_lead_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated users can view marketing lead events" ON public.marketing_lead_events;
CREATE POLICY "Authenticated users can view marketing lead events"
  ON public.marketing_lead_events FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Service role can manage marketing lead events" ON public.marketing_lead_events;
CREATE POLICY "Service role can manage marketing lead events"
  ON public.marketing_lead_events FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
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
