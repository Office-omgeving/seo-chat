-- Fix JSON comparison in weekly lock trigger.
-- row_to_json returns JSON (not comparable with =), so we compare JSONB payloads.

CREATE OR REPLACE FUNCTION public.enforce_weekly_checkin_lock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  is_admin BOOLEAN := false;
BEGIN
  is_admin := auth.role() = 'service_role'
    OR COALESCE(public.has_role(auth.uid(), 'admin'::public.app_role), false);

  IF OLD.status = 'frozen'
     AND to_jsonb(OLD) IS DISTINCT FROM to_jsonb(NEW)
     AND NOT is_admin THEN
    RAISE EXCEPTION 'Frozen check-ins can only be edited by admins';
  END IF;

  IF OLD.status = 'draft' AND NEW.status = 'frozen' THEN
    IF NOT is_admin THEN
      RAISE EXCEPTION 'Only admins can freeze weekly check-ins';
    END IF;
    NEW.frozen_at := now();
    NEW.frozen_by := auth.uid();
  ELSIF OLD.status = 'frozen' AND NEW.status = 'draft' THEN
    IF NOT is_admin THEN
      RAISE EXCEPTION 'Only admins can unfreeze weekly check-ins';
    END IF;
    NEW.frozen_at := NULL;
    NEW.frozen_by := NULL;
  ELSIF NEW.status = 'frozen' AND NEW.frozen_at IS NULL THEN
    NEW.frozen_at := now();
    NEW.frozen_by := COALESCE(NEW.frozen_by, auth.uid());
  END IF;

  RETURN NEW;
END;
$$;
