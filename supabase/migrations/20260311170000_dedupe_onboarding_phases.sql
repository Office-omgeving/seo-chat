WITH ranked_phases AS (
  SELECT
    id,
    client_id,
    sort_order,
    first_value(label) OVER phase_window AS keep_label,
    bool_or(is_current) OVER partition_window AS keep_current,
    bool_or(is_completed) OVER partition_window AS keep_completed,
    max(completed_at) OVER partition_window AS keep_completed_at,
    row_number() OVER phase_window AS row_number
  FROM public.onboarding_phases
  WINDOW
    partition_window AS (PARTITION BY client_id, sort_order),
    phase_window AS (PARTITION BY client_id, sort_order ORDER BY created_at ASC, id ASC)
),
updated AS (
  UPDATE public.onboarding_phases AS target
  SET
    label = ranked.keep_label,
    is_current = ranked.keep_current,
    is_completed = ranked.keep_completed,
    completed_at = CASE WHEN ranked.keep_completed THEN ranked.keep_completed_at ELSE NULL END
  FROM ranked_phases AS ranked
  WHERE target.id = ranked.id
    AND ranked.row_number = 1
  RETURNING target.id
)
DELETE FROM public.onboarding_phases AS target
USING ranked_phases AS ranked
WHERE target.id = ranked.id
  AND ranked.row_number > 1;
CREATE UNIQUE INDEX IF NOT EXISTS onboarding_phases_client_sort_order_key
  ON public.onboarding_phases (client_id, sort_order);
