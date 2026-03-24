-- One-time backfill: infer ad_accounts for existing clients from latest weekly check-in content.
-- Only applies to clients where ad_accounts is currently empty and skips PPA clients.

WITH ranked_checkins AS (
  SELECT
    wc.client_id,
    wc.marketing_input,
    wc.sheet_overview,
    wc.campaigns,
    wc.onboarding,
    ROW_NUMBER() OVER (
      PARTITION BY wc.client_id
      ORDER BY wc.year DESC, wc.week_number DESC, wc.week_start_date DESC, wc.created_at DESC
    ) AS rn
  FROM public.weekly_checkins wc
),
latest_checkins AS (
  SELECT
    rc.client_id,
    LOWER(CONCAT_WS(
      ' ',
      COALESCE(rc.marketing_input ->> 'leadSource', ''),
      COALESCE(rc.marketing_input ->> 'callFollowup', ''),
      COALESCE(rc.sheet_overview ->> 'marketingOverview', ''),
      COALESCE(
        (
          SELECT STRING_AGG(
            CONCAT_WS(
              ' ',
              COALESCE(campaign.value ->> 'type', ''),
              COALESCE(campaign.value ->> 'title', ''),
              COALESCE(campaign.value ->> 'status', '')
            ),
            ' '
          )
          FROM JSONB_ARRAY_ELEMENTS(COALESCE(rc.campaigns, '[]'::jsonb)) AS campaign(value)
        ),
        ''
      ),
      COALESCE(
        (
          SELECT STRING_AGG(
            CONCAT_WS(
              ' ',
              COALESCE(onboarding_row.value ->> 'label', ''),
              COALESCE(onboarding_row.value ->> 'status', '')
            ),
            ' '
          )
          FROM JSONB_ARRAY_ELEMENTS(COALESCE(rc.onboarding -> 'rows', '[]'::jsonb)) AS onboarding_row(value)
        ),
        ''
      )
    )) AS haystack,
    REGEXP_REPLACE(COALESCE(rc.marketing_input ->> 'budgetMeta', ''), '[^0-9]', '', 'g') AS budget_meta_digits,
    REGEXP_REPLACE(COALESCE(rc.marketing_input ->> 'budgetGoogle', ''), '[^0-9]', '', 'g') AS budget_google_digits
  FROM ranked_checkins rc
  WHERE rc.rn = 1
),
derived_accounts AS (
  SELECT
    lc.client_id,
    ARRAY_REMOVE(ARRAY[
      CASE
        WHEN lc.budget_meta_digits ~ '[1-9]' OR lc.haystack ~ '(meta|facebook|instagram)'
          THEN 'Meta Ads'
      END,
      CASE
        WHEN lc.budget_google_digits ~ '[1-9]' OR lc.haystack ~ '(google|adwords|search|youtube)'
          THEN 'Google Ads'
      END,
      CASE WHEN lc.haystack ~ 'linkedin' THEN 'LinkedIn Ads' END,
      CASE WHEN lc.haystack ~ 'tiktok' THEN 'TikTok Ads' END
    ], NULL) AS ad_accounts
  FROM latest_checkins lc
)
UPDATE public.clients c
SET ad_accounts = d.ad_accounts
FROM derived_accounts d
WHERE c.id::text = d.client_id
  AND CARDINALITY(d.ad_accounts) > 0
  AND COALESCE(ARRAY_LENGTH(c.ad_accounts, 1), 0) = 0
  AND LOWER(COALESCE(c.client_type, 'agency')) <> 'ppa';
