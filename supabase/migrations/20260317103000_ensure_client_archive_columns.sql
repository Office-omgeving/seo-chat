ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS relationship_status_set boolean NOT NULL DEFAULT false;
UPDATE public.clients
SET relationship_status_set = CASE
  WHEN relationship_status = 'neutral' THEN false
  ELSE true
END
WHERE relationship_status_set IS DISTINCT FROM CASE
  WHEN relationship_status = 'neutral' THEN false
  ELSE true
END;
COMMENT ON COLUMN public.clients.relationship_status_set IS 'Of de relatiestatus expliciet werd ingesteld';
ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS archived_at timestamp with time zone;
COMMENT ON COLUMN public.clients.archived_at IS 'Wanneer de klant naar het archief is verhuisd';
NOTIFY pgrst, 'reload schema';
