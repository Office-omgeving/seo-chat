-- Remove historical Meta cost rows for PPA clients.
DO $$
DECLARE
  v_before BIGINT := 0;
  v_deleted BIGINT := 0;
  v_after BIGINT := 0;
BEGIN
  SELECT COUNT(*)
  INTO v_before
  FROM public.marketing_costs_daily m
  JOIN public.clients c
    ON c.id::text = m.client_id
  WHERE LOWER(COALESCE(c.client_type, 'agency')) = 'ppa'
    AND m.source = 'meta';

  DELETE FROM public.marketing_costs_daily m
  USING public.clients c
  WHERE c.id::text = m.client_id
    AND LOWER(COALESCE(c.client_type, 'agency')) = 'ppa'
    AND m.source = 'meta';

  GET DIAGNOSTICS v_deleted = ROW_COUNT;

  SELECT COUNT(*)
  INTO v_after
  FROM public.marketing_costs_daily m
  JOIN public.clients c
    ON c.id::text = m.client_id
  WHERE LOWER(COALESCE(c.client_type, 'agency')) = 'ppa'
    AND m.source = 'meta';

  RAISE NOTICE 'Cleanup PPA Meta costs: before=% deleted=% after=%', v_before, v_deleted, v_after;
END $$;
