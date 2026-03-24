ALTER TABLE public.clients
ALTER COLUMN profitability_alert_threshold_percent
SET DEFAULT 60;
UPDATE public.clients
SET profitability_alert_threshold_percent = 60
WHERE profitability_alert_threshold_percent IS NULL;
