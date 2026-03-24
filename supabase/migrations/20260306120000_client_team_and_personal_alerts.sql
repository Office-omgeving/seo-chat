CREATE OR REPLACE FUNCTION public.try_numeric(_value TEXT)
RETURNS NUMERIC
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  IF _value IS NULL OR btrim(_value) = '' THEN
    RETURN NULL;
  END IF;

  RETURN replace(btrim(_value), ',', '.')::numeric;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$;
CREATE OR REPLACE FUNCTION public.try_timestamptz(_value TEXT)
RETURNS TIMESTAMP WITH TIME ZONE
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  IF _value IS NULL OR btrim(_value) = '' THEN
    RETURN NULL;
  END IF;

  RETURN _value::timestamptz;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$;
CREATE TABLE IF NOT EXISTS public.client_team_members (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  assignment_role public.app_role NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (client_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_client_team_members_client
  ON public.client_team_members (client_id, assignment_role);
CREATE INDEX IF NOT EXISTS idx_client_team_members_user
  ON public.client_team_members (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_team_members_primary_am
  ON public.client_team_members (client_id)
  WHERE is_primary = true AND assignment_role = 'account_manager'::public.app_role;
ALTER TABLE public.client_team_members ENABLE ROW LEVEL SECURITY;
CREATE OR REPLACE FUNCTION public.can_manage_client_team(_client_id UUID, _user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    public.has_role(_user_id, 'admin'::public.app_role)
    OR public.has_role(_user_id, 'management'::public.app_role)
    OR EXISTS (
      SELECT 1
      FROM public.clients c
      WHERE c.id = _client_id
        AND c.created_by = _user_id
    )
    OR EXISTS (
      SELECT 1
      FROM public.client_team_members ctm
      WHERE ctm.client_id = _client_id
        AND ctm.user_id = _user_id
        AND ctm.assignment_role = 'account_manager'::public.app_role
        AND ctm.is_primary = true
    ),
    false
  );
$$;
DROP POLICY IF EXISTS "Authenticated users can view client team members" ON public.client_team_members;
CREATE POLICY "Authenticated users can view client team members"
  ON public.client_team_members FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Allowed users can insert client team members" ON public.client_team_members;
CREATE POLICY "Allowed users can insert client team members"
  ON public.client_team_members FOR INSERT
  WITH CHECK (public.can_manage_client_team(client_id, auth.uid()));
DROP POLICY IF EXISTS "Allowed users can update client team members" ON public.client_team_members;
CREATE POLICY "Allowed users can update client team members"
  ON public.client_team_members FOR UPDATE
  USING (public.can_manage_client_team(client_id, auth.uid()))
  WITH CHECK (public.can_manage_client_team(client_id, auth.uid()));
DROP POLICY IF EXISTS "Allowed users can delete client team members" ON public.client_team_members;
CREATE POLICY "Allowed users can delete client team members"
  ON public.client_team_members FOR DELETE
  USING (public.can_manage_client_team(client_id, auth.uid()));
CREATE OR REPLACE FUNCTION public.enforce_client_team_member_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  global_role public.app_role;
BEGIN
  global_role := public.get_user_role(NEW.user_id);

  IF global_role IS NULL THEN
    RAISE EXCEPTION 'Kan geen klantteamlid koppelen zonder globale rol';
  END IF;

  IF NEW.assignment_role <> global_role THEN
    RAISE EXCEPTION 'Klantteamrol (%) moet overeenkomen met de globale rol (%)', NEW.assignment_role, global_role;
  END IF;

  IF NEW.is_primary AND NEW.assignment_role <> 'account_manager'::public.app_role THEN
    RAISE EXCEPTION 'Alleen een account manager kan primair zijn op een klant';
  END IF;

  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS enforce_client_team_member_role ON public.client_team_members;
CREATE TRIGGER enforce_client_team_member_role
  BEFORE INSERT OR UPDATE ON public.client_team_members
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_client_team_member_role();
CREATE OR REPLACE FUNCTION public.sync_primary_account_manager_mirror(_client_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  primary_assignment RECORD;
BEGIN
  SELECT
    ctm.user_id,
    COALESCE(p.display_name, '') AS display_name
  INTO primary_assignment
  FROM public.client_team_members ctm
  LEFT JOIN public.profiles p ON p.user_id = ctm.user_id
  WHERE ctm.client_id = _client_id
    AND ctm.assignment_role = 'account_manager'::public.app_role
    AND ctm.is_primary = true
  ORDER BY ctm.created_at ASC
  LIMIT 1;

  UPDATE public.clients
  SET
    account_manager_id = COALESCE(primary_assignment.user_id::text, ''),
    account_manager_name = COALESCE(primary_assignment.display_name, '')
  WHERE id = _client_id;
END;
$$;
CREATE OR REPLACE FUNCTION public.handle_client_team_member_sync()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_client_id UUID;
BEGIN
  target_client_id := COALESCE(NEW.client_id, OLD.client_id);
  PERFORM public.sync_primary_account_manager_mirror(target_client_id);
  RETURN COALESCE(NEW, OLD);
END;
$$;
DROP TRIGGER IF EXISTS update_client_team_members_updated_at ON public.client_team_members;
CREATE TRIGGER update_client_team_members_updated_at
  BEFORE UPDATE ON public.client_team_members
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
DROP TRIGGER IF EXISTS sync_client_team_member_mirror ON public.client_team_members;
CREATE TRIGGER sync_client_team_member_mirror
  AFTER INSERT OR UPDATE OR DELETE ON public.client_team_members
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_client_team_member_sync();
INSERT INTO public.client_team_members (
  client_id,
  user_id,
  assignment_role,
  is_primary,
  created_by
)
SELECT
  c.id,
  matched.user_id,
  'account_manager'::public.app_role,
  true,
  c.created_by
FROM public.clients c
JOIN LATERAL (
  SELECT
    p.user_id,
    p.display_name
  FROM public.profiles p
  JOIN public.user_roles ur
    ON ur.user_id = p.user_id
   AND ur.role = 'account_manager'::public.app_role
  WHERE lower(trim(p.display_name)) = lower(trim(c.account_manager_name))
  ORDER BY p.created_at ASC
  LIMIT 1
) AS matched ON true
WHERE trim(COALESCE(c.account_manager_name, '')) <> ''
ON CONFLICT (client_id, user_id) DO UPDATE
SET
  assignment_role = EXCLUDED.assignment_role,
  is_primary = EXCLUDED.is_primary;
DO $$
DECLARE
  client_row RECORD;
BEGIN
  FOR client_row IN SELECT id FROM public.clients LOOP
    PERFORM public.sync_primary_account_manager_mirror(client_row.id);
  END LOOP;
END;
$$;
CREATE TABLE IF NOT EXISTS public.user_alert_rules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  rule_kind TEXT NOT NULL CHECK (
    rule_kind IN (
      'metric_threshold',
      'stale_contact_days',
      'missing_checkin_days',
      'blocker_count_at_least',
      'completeness_below',
      'prepared_for_call_is_false'
    )
  ),
  metric_key TEXT CHECK (metric_key IS NULL OR metric_key IN ('spend', 'leads', 'cpl', 'roas')),
  period TEXT CHECK (period IS NULL OR period IN ('7d', '14d', '30d')),
  comparator TEXT CHECK (comparator IS NULL OR comparator IN ('lt', 'lte', 'gt', 'gte', 'eq')),
  threshold_numeric NUMERIC(14, 2),
  threshold_boolean BOOLEAN,
  severity TEXT NOT NULL DEFAULT 'warning' CHECK (severity IN ('warning', 'critical')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_user_alert_rules_user
  ON public.user_alert_rules (user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_user_alert_rules_client
  ON public.user_alert_rules (client_id);
ALTER TABLE public.user_alert_rules ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own alert rules" ON public.user_alert_rules;
CREATE POLICY "Users can view own alert rules"
  ON public.user_alert_rules FOR SELECT
  USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own alert rules" ON public.user_alert_rules;
CREATE POLICY "Users can insert own alert rules"
  ON public.user_alert_rules FOR INSERT
  WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own alert rules" ON public.user_alert_rules;
CREATE POLICY "Users can update own alert rules"
  ON public.user_alert_rules FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own alert rules" ON public.user_alert_rules;
CREATE POLICY "Users can delete own alert rules"
  ON public.user_alert_rules FOR DELETE
  USING (auth.uid() = user_id);
CREATE OR REPLACE FUNCTION public.validate_user_alert_rule()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF NEW.rule_kind = 'metric_threshold' THEN
    IF NEW.metric_key IS NULL OR NEW.period IS NULL OR NEW.comparator IS NULL OR NEW.threshold_numeric IS NULL THEN
      RAISE EXCEPTION 'Metric alertregels vereisen metric_key, period, comparator en threshold_numeric';
    END IF;
    NEW.threshold_boolean := NULL;
  ELSIF NEW.rule_kind = 'prepared_for_call_is_false' THEN
    NEW.metric_key := NULL;
    NEW.period := NULL;
    NEW.comparator := NULL;
    NEW.threshold_numeric := NULL;
    NEW.threshold_boolean := false;
  ELSE
    NEW.metric_key := NULL;
    NEW.period := NULL;
    NEW.comparator := NULL;
    NEW.threshold_boolean := NULL;

    IF NEW.threshold_numeric IS NULL THEN
      RAISE EXCEPTION 'Deze alertregel vereist threshold_numeric';
    END IF;
  END IF;

  IF NEW.rule_kind = 'completeness_below' AND (NEW.threshold_numeric < 0 OR NEW.threshold_numeric > 100) THEN
    RAISE EXCEPTION 'Completeness alertregel moet tussen 0 en 100 liggen';
  END IF;

  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS validate_user_alert_rule ON public.user_alert_rules;
CREATE TRIGGER validate_user_alert_rule
  BEFORE INSERT OR UPDATE ON public.user_alert_rules
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_user_alert_rule();
DROP TRIGGER IF EXISTS update_user_alert_rules_updated_at ON public.user_alert_rules;
CREATE TRIGGER update_user_alert_rules_updated_at
  BEFORE UPDATE ON public.user_alert_rules
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE VIEW public.client_alert_signal_snapshot AS
WITH latest_checkin AS (
  SELECT DISTINCT ON (wc.client_id)
    wc.client_id,
    wc.id,
    wc.week_start_date,
    wc.completeness_score,
    wc.prepared_for_call,
    wc.account_manager,
    wc.operations,
    wc.performance
  FROM public.weekly_checkins wc
  ORDER BY wc.client_id, wc.week_start_date DESC, wc.created_at DESC
),
live_costs AS (
  SELECT
    m.client_id,
    m.cost_date,
    COALESCE(m.spend, 0)::numeric AS spend,
    COALESCE((
      SELECT max(public.try_numeric(action ->> 'value'))
      FROM jsonb_array_elements(COALESCE(m.raw -> 'actions', '[]'::jsonb)) AS action
      WHERE lower(COALESCE(action ->> 'action_type', '')) LIKE '%lead%'
    ), 0)::numeric AS leads
  FROM public.marketing_costs_daily m
),
live_rollup AS (
  SELECT
    lc.client_id,
    count(*) FILTER (WHERE lc.cost_date >= current_date - 6) AS live_rows_7d,
    count(*) FILTER (WHERE lc.cost_date >= current_date - 13) AS live_rows_14d,
    count(*) FILTER (WHERE lc.cost_date >= current_date - 29) AS live_rows_30d,
    COALESCE(sum(lc.spend) FILTER (WHERE lc.cost_date >= current_date - 6), 0)::numeric AS spend_live_7d,
    COALESCE(sum(lc.leads) FILTER (WHERE lc.cost_date >= current_date - 6), 0)::numeric AS leads_live_7d,
    COALESCE(sum(lc.spend) FILTER (WHERE lc.cost_date >= current_date - 13), 0)::numeric AS spend_live_14d,
    COALESCE(sum(lc.leads) FILTER (WHERE lc.cost_date >= current_date - 13), 0)::numeric AS leads_live_14d,
    COALESCE(sum(lc.spend) FILTER (WHERE lc.cost_date >= current_date - 29), 0)::numeric AS spend_live_30d,
    COALESCE(sum(lc.leads) FILTER (WHERE lc.cost_date >= current_date - 29), 0)::numeric AS leads_live_30d
  FROM live_costs lc
  GROUP BY lc.client_id
)
SELECT
  c.id AS client_id,
  c.name AS client_name,
  c.client_type,
  c.account_manager_id,
  c.account_manager_name,
  latest.id AS latest_checkin_id,
  latest.week_start_date AS latest_week_start,
  CASE
    WHEN latest.week_start_date IS NULL THEN NULL
    ELSE (current_date - latest.week_start_date)::integer
  END AS days_since_checkin,
  latest.completeness_score,
  latest.prepared_for_call,
  CASE
    WHEN public.try_timestamptz(latest.account_manager ->> 'lastContactDate') IS NULL THEN NULL
    ELSE (current_date - (public.try_timestamptz(latest.account_manager ->> 'lastContactDate'))::date)::integer
  END AS last_contact_days,
  COALESCE(blockers.blocker_count, 0) AS blocker_count,
  CASE
    WHEN COALESCE(lr.live_rows_7d, 0) > 0 THEN lr.spend_live_7d
    ELSE public.try_numeric(latest.performance #>> '{metrics7d,spend}')
  END AS spend_7d,
  CASE
    WHEN COALESCE(lr.live_rows_7d, 0) > 0 THEN lr.leads_live_7d
    ELSE public.try_numeric(latest.performance #>> '{metrics7d,leads}')
  END AS leads_7d,
  CASE
    WHEN COALESCE(lr.live_rows_7d, 0) > 0 AND COALESCE(lr.leads_live_7d, 0) > 0
      THEN round(lr.spend_live_7d / NULLIF(lr.leads_live_7d, 0), 2)
    WHEN COALESCE(lr.live_rows_7d, 0) > 0
      THEN NULL
    ELSE public.try_numeric(latest.performance #>> '{metrics7d,cpl}')
  END AS cpl_7d,
  public.try_numeric(latest.performance #>> '{metrics7d,roas}') AS roas_7d,
  CASE
    WHEN COALESCE(lr.live_rows_14d, 0) > 0 THEN lr.spend_live_14d
    ELSE public.try_numeric(latest.performance #>> '{metrics14d,spend}')
  END AS spend_14d,
  CASE
    WHEN COALESCE(lr.live_rows_14d, 0) > 0 THEN lr.leads_live_14d
    ELSE public.try_numeric(latest.performance #>> '{metrics14d,leads}')
  END AS leads_14d,
  CASE
    WHEN COALESCE(lr.live_rows_14d, 0) > 0 AND COALESCE(lr.leads_live_14d, 0) > 0
      THEN round(lr.spend_live_14d / NULLIF(lr.leads_live_14d, 0), 2)
    WHEN COALESCE(lr.live_rows_14d, 0) > 0
      THEN NULL
    ELSE public.try_numeric(latest.performance #>> '{metrics14d,cpl}')
  END AS cpl_14d,
  public.try_numeric(latest.performance #>> '{metrics14d,roas}') AS roas_14d,
  CASE
    WHEN COALESCE(lr.live_rows_30d, 0) > 0 THEN lr.spend_live_30d
    ELSE public.try_numeric(latest.performance #>> '{metrics30d,spend}')
  END AS spend_30d,
  CASE
    WHEN COALESCE(lr.live_rows_30d, 0) > 0 THEN lr.leads_live_30d
    ELSE public.try_numeric(latest.performance #>> '{metrics30d,leads}')
  END AS leads_30d,
  CASE
    WHEN COALESCE(lr.live_rows_30d, 0) > 0 AND COALESCE(lr.leads_live_30d, 0) > 0
      THEN round(lr.spend_live_30d / NULLIF(lr.leads_live_30d, 0), 2)
    WHEN COALESCE(lr.live_rows_30d, 0) > 0
      THEN NULL
    ELSE public.try_numeric(latest.performance #>> '{metrics30d,cpl}')
  END AS cpl_30d,
  public.try_numeric(latest.performance #>> '{metrics30d,roas}') AS roas_30d,
  COALESCE(lr.live_rows_7d, 0) > 0 AS has_live_metrics_7d,
  COALESCE(lr.live_rows_14d, 0) > 0 AS has_live_metrics_14d,
  COALESCE(lr.live_rows_30d, 0) > 0 AS has_live_metrics_30d
FROM public.clients c
LEFT JOIN latest_checkin latest
  ON latest.client_id = c.id::text
LEFT JOIN live_rollup lr
  ON lr.client_id = c.id::text
LEFT JOIN LATERAL (
  SELECT count(*)::integer AS blocker_count
  FROM jsonb_array_elements(COALESCE(latest.operations, '[]'::jsonb)) AS operation
  WHERE lower(COALESCE(operation ->> 'isBlocker', 'false')) = 'true'
) AS blockers ON true;
