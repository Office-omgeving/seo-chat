WITH chosen_current AS (
  SELECT
    client_id,
    max(sort_order) FILTER (WHERE is_current AND NOT is_completed) AS selected_sort_order,
    min(sort_order) FILTER (WHERE NOT is_completed) AS fallback_sort_order
  FROM public.onboarding_phases
  GROUP BY client_id
)
UPDATE public.onboarding_phases AS phase
SET is_current = CASE
  WHEN COALESCE(chosen.selected_sort_order, chosen.fallback_sort_order) IS NULL THEN false
  WHEN phase.sort_order = COALESCE(chosen.selected_sort_order, chosen.fallback_sort_order)
    AND NOT phase.is_completed THEN true
  ELSE false
END
FROM chosen_current AS chosen
WHERE phase.client_id = chosen.client_id;
