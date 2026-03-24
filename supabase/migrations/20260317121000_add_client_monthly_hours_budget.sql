ALTER TABLE public.clients
ADD COLUMN IF NOT EXISTS monthly_hours_budget INTEGER;
