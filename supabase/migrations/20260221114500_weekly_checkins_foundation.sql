-- Foundation for weekly check-ins, management board rows, and external integrations

CREATE TABLE public.weekly_checkins (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id TEXT NOT NULL,
  week_start_date DATE NOT NULL,
  week_number INTEGER NOT NULL CHECK (week_number BETWEEN 1 AND 53),
  year INTEGER NOT NULL CHECK (year >= 2020),
  template_type TEXT NOT NULL DEFAULT 'agency' CHECK (template_type IN ('agency', 'ppa')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'frozen')),
  onboarding JSONB NOT NULL DEFAULT '{}'::jsonb,
  marketing_input JSONB NOT NULL DEFAULT '{}'::jsonb,
  campaigns JSONB NOT NULL DEFAULT '[]'::jsonb,
  sheet_overview JSONB NOT NULL DEFAULT '{}'::jsonb,
  account_manager JSONB NOT NULL DEFAULT '{}'::jsonb,
  operations JSONB NOT NULL DEFAULT '[]'::jsonb,
  performance JSONB NOT NULL DEFAULT '{}'::jsonb,
  upsells JSONB NOT NULL DEFAULT '[]'::jsonb,
  external_links JSONB NOT NULL DEFAULT '[]'::jsonb,
  completeness_score INTEGER NOT NULL DEFAULT 0 CHECK (completeness_score BETWEEN 0 AND 100),
  prepared_for_call BOOLEAN NOT NULL DEFAULT false,
  signoff_note TEXT,
  source TEXT NOT NULL DEFAULT 'app',
  frozen_at TIMESTAMP WITH TIME ZONE,
  frozen_by UUID REFERENCES auth.users(id),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (client_id, week_start_date)
);
CREATE INDEX idx_weekly_checkins_client_week
  ON public.weekly_checkins (client_id, year DESC, week_number DESC);
CREATE INDEX idx_weekly_checkins_status
  ON public.weekly_checkins (status);
CREATE TABLE public.weekly_management_rows (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  board_type TEXT NOT NULL CHECK (board_type IN ('agency', 'ppa')),
  week_start_date DATE NOT NULL,
  client_id TEXT NOT NULL,
  planning_status TEXT,
  planning_owner TEXT,
  marketing_status TEXT,
  marketing_owner TEXT,
  action_point TEXT,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (board_type, week_start_date, client_id)
);
CREATE INDEX idx_weekly_management_rows_board
  ON public.weekly_management_rows (board_type, week_start_date DESC);
CREATE TABLE public.client_integrations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id TEXT NOT NULL UNIQUE,
  wrike_account_id TEXT,
  wrike_space_id TEXT,
  wrike_folder_id TEXT,
  ghl_location_id TEXT,
  ghl_pipeline_id TEXT,
  ghl_calendar_id TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE INDEX idx_client_integrations_wrike_space
  ON public.client_integrations (wrike_space_id);
CREATE INDEX idx_client_integrations_ghl_location
  ON public.client_integrations (ghl_location_id);
ALTER TABLE public.weekly_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_management_rows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_integrations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view weekly check-ins"
  ON public.weekly_checkins FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert weekly check-ins"
  ON public.weekly_checkins FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update weekly check-ins"
  ON public.weekly_checkins FOR UPDATE
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Admins can delete weekly check-ins"
  ON public.weekly_checkins FOR DELETE
  USING (COALESCE(public.has_role(auth.uid(), 'admin'::public.app_role), false));
CREATE POLICY "Authenticated users can view weekly management rows"
  ON public.weekly_management_rows FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert weekly management rows"
  ON public.weekly_management_rows FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update weekly management rows"
  ON public.weekly_management_rows FOR UPDATE
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete weekly management rows"
  ON public.weekly_management_rows FOR DELETE
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can view client integrations"
  ON public.client_integrations FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert client integrations"
  ON public.client_integrations FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update client integrations"
  ON public.client_integrations FOR UPDATE
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete client integrations"
  ON public.client_integrations FOR DELETE
  USING (auth.uid() IS NOT NULL);
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
     AND row_to_json(OLD) IS DISTINCT FROM row_to_json(NEW)
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
CREATE TRIGGER enforce_weekly_checkin_lock
  BEFORE UPDATE ON public.weekly_checkins
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_weekly_checkin_lock();
CREATE TRIGGER update_weekly_checkins_updated_at
  BEFORE UPDATE ON public.weekly_checkins
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_weekly_management_rows_updated_at
  BEFORE UPDATE ON public.weekly_management_rows
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_client_integrations_updated_at
  BEFORE UPDATE ON public.client_integrations
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
