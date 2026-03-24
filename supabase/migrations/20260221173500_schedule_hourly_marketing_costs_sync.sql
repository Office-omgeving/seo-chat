-- Hourly scheduler for Meta marketing costs sync.
-- Runs every hour and refreshes a short rolling window to keep spend metrics current.

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
DO $$
DECLARE
  existing_job_id BIGINT;
BEGIN
  SELECT jobid
  INTO existing_job_id
  FROM cron.job
  WHERE jobname = 'marketing_costs_sync_hourly';

  IF existing_job_id IS NOT NULL THEN
    PERFORM cron.unschedule(existing_job_id);
  END IF;

  PERFORM cron.schedule(
    'marketing_costs_sync_hourly',
    '5 * * * *',
    $cron$
      SELECT net.http_post(
        url := 'https://ubbthfgfxhttxlkyqdlw.supabase.co/functions/v1/marketing-costs-sync',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InViYnRoZmdmeGh0dHhsa3lxZGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3ODU2MDgsImV4cCI6MjA2MDM2MTYwOH0.ggKnBIA6nHFn1wom8Rl40dUbxJM8fGGgN4Ksm5xOwxY',
          'apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InViYnRoZmdmeGh0dHhsa3lxZGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3ODU2MDgsImV4cCI6MjA2MDM2MTYwOH0.ggKnBIA6nHFn1wom8Rl40dUbxJM8fGGgN4Ksm5xOwxY'
        ),
        body := jsonb_build_object(
          'from', to_char((timezone('UTC', now())::date - INTERVAL '2 day')::date, 'YYYY-MM-DD'),
          'to', to_char(timezone('UTC', now())::date, 'YYYY-MM-DD'),
          'autoMap', false
        ),
        timeout_milliseconds := 120000
      );
    $cron$
  );
END
$$;
