-- Remove Meta account mappings for PPA clients.
DO $$
DECLARE
  v_before BIGINT := 0;
  v_updated BIGINT := 0;
  v_after BIGINT := 0;
BEGIN
  SELECT COUNT(*)
  INTO v_before
  FROM public.client_integrations i
  JOIN public.clients c
    ON c.id::text = i.client_id
  WHERE LOWER(COALESCE(c.client_type, 'agency')) = 'ppa'
    AND i.meta_ad_account_id IS NOT NULL;

  UPDATE public.client_integrations i
  SET meta_ad_account_id = NULL
  FROM public.clients c
  WHERE c.id::text = i.client_id
    AND LOWER(COALESCE(c.client_type, 'agency')) = 'ppa'
    AND i.meta_ad_account_id IS NOT NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  SELECT COUNT(*)
  INTO v_after
  FROM public.client_integrations i
  JOIN public.clients c
    ON c.id::text = i.client_id
  WHERE LOWER(COALESCE(c.client_type, 'agency')) = 'ppa'
    AND i.meta_ad_account_id IS NOT NULL;

  RAISE NOTICE 'Cleanup PPA Meta mappings: before=% updated=% after=%', v_before, v_updated, v_after;
END $$;
