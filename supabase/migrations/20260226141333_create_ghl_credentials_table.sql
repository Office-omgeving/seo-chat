-- Create Profit Pulse compatible GHL credentials table for shared location metadata.

CREATE TABLE IF NOT EXISTS public.ghl_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  location_id TEXT,
  location_name TEXT NOT NULL,
  access_token TEXT NOT NULL DEFAULT '',
  api_version TEXT NOT NULL DEFAULT '',
  sync_cursor TEXT,
  last_sync_status TEXT,
  appointments_sync_cursor TEXT,
  appointments_last_sync_status TEXT,
  appointments_last_synced_at TIMESTAMPTZ,
  brand TEXT,
  brand_id TEXT,
  partner_id TEXT,
  province_id TEXT,
  sector_id TEXT,
  sector_ids JSONB,
  is_reference BOOLEAN,
  is_test BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'ghl_credentials_brand_check'
      AND conrelid = 'public.ghl_credentials'::regclass
  ) THEN
    ALTER TABLE public.ghl_credentials
      DROP CONSTRAINT ghl_credentials_brand_check;
  END IF;
END $$;
ALTER TABLE public.ghl_credentials
  ADD CONSTRAINT ghl_credentials_brand_check
  CHECK (
    brand IS NULL
    OR brand IN ('Verbouwingen', 'Vastgoed', 'Coworking', 'Marketing')
  );
CREATE UNIQUE INDEX IF NOT EXISTS idx_ghl_credentials_location_id_unique
  ON public.ghl_credentials (location_id);
CREATE INDEX IF NOT EXISTS idx_ghl_credentials_brand
  ON public.ghl_credentials (brand);
-- Keep legacy client behavior: never persist NULL access tokens.
CREATE OR REPLACE FUNCTION public.normalize_ghl_access_token()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
BEGIN
  NEW.access_token := COALESCE(NEW.access_token, '');
  RETURN NEW;
END;
$fn$;
DROP TRIGGER IF EXISTS trg_normalize_ghl_access_token ON public.ghl_credentials;
CREATE TRIGGER trg_normalize_ghl_access_token
  BEFORE INSERT OR UPDATE ON public.ghl_credentials
  FOR EACH ROW
  EXECUTE FUNCTION public.normalize_ghl_access_token();
ALTER TABLE public.ghl_credentials ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS authenticated_all ON public.ghl_credentials;
DROP POLICY IF EXISTS authenticated_read ON public.ghl_credentials;
DROP POLICY IF EXISTS authenticated_insert ON public.ghl_credentials;
DROP POLICY IF EXISTS authenticated_update ON public.ghl_credentials;
CREATE POLICY authenticated_read
  ON public.ghl_credentials
  FOR SELECT
  TO authenticated
  USING (true);
CREATE POLICY authenticated_insert
  ON public.ghl_credentials
  FOR INSERT
  TO authenticated
  WITH CHECK (true);
CREATE POLICY authenticated_update
  ON public.ghl_credentials
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
-- Align client permissions with Profit Pulse lockdown: hide secret token fields.
DO $$
DECLARE
  cols TEXT;
BEGIN
  REVOKE ALL PRIVILEGES ON TABLE public.ghl_credentials FROM anon, authenticated;

  SELECT string_agg(quote_ident(column_name), ', ')
    INTO cols
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'ghl_credentials'
    AND column_name NOT IN ('access_token', 'refresh_token');

  IF cols IS NOT NULL THEN
    EXECUTE format('GRANT SELECT (%s) ON TABLE public.ghl_credentials TO authenticated;', cols);
    EXECUTE format('GRANT INSERT (%s) ON TABLE public.ghl_credentials TO authenticated;', cols);
    EXECUTE format('GRANT UPDATE (%s) ON TABLE public.ghl_credentials TO authenticated;', cols);
  END IF;

  GRANT ALL PRIVILEGES ON TABLE public.ghl_credentials TO service_role;
END $$;
