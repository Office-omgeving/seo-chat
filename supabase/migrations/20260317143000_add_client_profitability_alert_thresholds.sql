ALTER TABLE public.clients
ADD COLUMN IF NOT EXISTS profitability_alert_threshold_percent INTEGER;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'clients_profitability_alert_threshold_percent_check'
  ) THEN
    ALTER TABLE public.clients
    ADD CONSTRAINT clients_profitability_alert_threshold_percent_check
    CHECK (
      profitability_alert_threshold_percent IS NULL
      OR (
        profitability_alert_threshold_percent >= 1
        AND profitability_alert_threshold_percent <= 100
      )
    );
  END IF;
END $$;
CREATE TABLE IF NOT EXISTS public.client_profitability_alert_notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  month_key TEXT NOT NULL,
  threshold_percent INTEGER NOT NULL,
  recipient_email TEXT NOT NULL,
  tracked_minutes INTEGER NOT NULL DEFAULT 0,
  budget_minutes INTEGER NOT NULL DEFAULT 0,
  usage_percent NUMERIC(7,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  last_attempt_at TIMESTAMPTZ NULL,
  sent_at TIMESTAMPTZ NULL,
  error_message TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT client_profitability_alert_notifications_threshold_percent_check CHECK (threshold_percent >= 1 AND threshold_percent <= 100),
  CONSTRAINT client_profitability_alert_notifications_budget_minutes_check CHECK (budget_minutes >= 0),
  CONSTRAINT client_profitability_alert_notifications_tracked_minutes_check CHECK (tracked_minutes >= 0),
  CONSTRAINT client_profitability_alert_notifications_usage_percent_check CHECK (usage_percent >= 0),
  CONSTRAINT client_profitability_alert_notifications_status_check CHECK (status IN ('pending', 'sent')),
  CONSTRAINT client_profitability_alert_notifications_unique_month UNIQUE (client_id, month_key, threshold_percent, recipient_email)
);
CREATE INDEX IF NOT EXISTS idx_client_profitability_alert_notifications_client_month
  ON public.client_profitability_alert_notifications(client_id, month_key);
ALTER TABLE public.client_profitability_alert_notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can read profitability alert notifications" ON public.client_profitability_alert_notifications;
CREATE POLICY "Admins can read profitability alert notifications"
  ON public.client_profitability_alert_notifications
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.user_roles
      WHERE user_roles.user_id = auth.uid()
        AND user_roles.role = 'admin'
    )
  );
DROP TRIGGER IF EXISTS update_client_profitability_alert_notifications_updated_at
  ON public.client_profitability_alert_notifications;
CREATE TRIGGER update_client_profitability_alert_notifications_updated_at
  BEFORE UPDATE ON public.client_profitability_alert_notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
