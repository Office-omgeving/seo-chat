-- Foundation tables for Figma-based leadgen creative extraction.

CREATE TABLE IF NOT EXISTS public.leadgen_figma_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id TEXT NOT NULL,
  campaign_id UUID REFERENCES public.marketing_campaigns(id) ON DELETE SET NULL,
  figma_url TEXT NOT NULL,
  file_key TEXT NOT NULL,
  root_node_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'imported'
    CHECK (status IN ('imported', 'importing', 'needs_review', 'needs_manual_fix', 'approved', 'published', 'rejected', 'error')),
  error_message TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_leadgen_figma_jobs_client
  ON public.leadgen_figma_jobs (client_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leadgen_figma_jobs_status
  ON public.leadgen_figma_jobs (status, created_at DESC);
CREATE TABLE IF NOT EXISTS public.leadgen_figma_creatives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES public.leadgen_figma_jobs(id) ON DELETE CASCADE,
  node_id TEXT NOT NULL,
  frame_name TEXT NOT NULL,
  format TEXT NOT NULL CHECK (format IN ('facebook_feed', 'story', 'other')),
  locale TEXT,
  width NUMERIC(10, 2),
  height NUMERIC(10, 2),
  aspect_ratio NUMERIC(10, 4),
  status TEXT NOT NULL DEFAULT 'needs_review'
    CHECK (status IN ('imported', 'needs_review', 'needs_manual_fix', 'approved', 'published', 'rejected')),
  warnings_json JSONB NOT NULL DEFAULT '[]'::jsonb,
  screenshot_path TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (job_id, node_id)
);
CREATE INDEX IF NOT EXISTS idx_leadgen_figma_creatives_job
  ON public.leadgen_figma_creatives (job_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leadgen_figma_creatives_status
  ON public.leadgen_figma_creatives (status, created_at DESC);
CREATE TABLE IF NOT EXISTS public.leadgen_figma_copy_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creative_id UUID NOT NULL REFERENCES public.leadgen_figma_creatives(id) ON DELETE CASCADE,
  field TEXT NOT NULL CHECK (field IN ('headline', 'body', 'cta', 'url')),
  text TEXT NOT NULL DEFAULT '',
  confidence NUMERIC(4, 3) NOT NULL DEFAULT 0
    CHECK (confidence >= 0 AND confidence <= 1),
  source_node_id TEXT,
  edited_by_user BOOLEAN NOT NULL DEFAULT false,
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (creative_id, field)
);
CREATE INDEX IF NOT EXISTS idx_leadgen_figma_copy_fields_creative
  ON public.leadgen_figma_copy_fields (creative_id);
CREATE TABLE IF NOT EXISTS public.leadgen_figma_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creative_id UUID NOT NULL REFERENCES public.leadgen_figma_creatives(id) ON DELETE CASCADE,
  kind TEXT NOT NULL DEFAULT 'image' CHECK (kind IN ('image', 'video', 'svg', 'other')),
  source_node_id TEXT,
  asset_url TEXT,
  cached_path TEXT,
  expires_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_leadgen_figma_assets_creative
  ON public.leadgen_figma_assets (creative_id, created_at DESC);
ALTER TABLE public.leadgen_figma_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leadgen_figma_creatives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leadgen_figma_copy_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leadgen_figma_assets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated users can view leadgen figma jobs" ON public.leadgen_figma_jobs;
CREATE POLICY "Authenticated users can view leadgen figma jobs"
  ON public.leadgen_figma_jobs FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit leadgen figma jobs" ON public.leadgen_figma_jobs;
CREATE POLICY "Authenticated users can edit leadgen figma jobs"
  ON public.leadgen_figma_jobs FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view leadgen figma creatives" ON public.leadgen_figma_creatives;
CREATE POLICY "Authenticated users can view leadgen figma creatives"
  ON public.leadgen_figma_creatives FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit leadgen figma creatives" ON public.leadgen_figma_creatives;
CREATE POLICY "Authenticated users can edit leadgen figma creatives"
  ON public.leadgen_figma_creatives FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view leadgen figma copy fields" ON public.leadgen_figma_copy_fields;
CREATE POLICY "Authenticated users can view leadgen figma copy fields"
  ON public.leadgen_figma_copy_fields FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit leadgen figma copy fields" ON public.leadgen_figma_copy_fields;
CREATE POLICY "Authenticated users can edit leadgen figma copy fields"
  ON public.leadgen_figma_copy_fields FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can view leadgen figma assets" ON public.leadgen_figma_assets;
CREATE POLICY "Authenticated users can view leadgen figma assets"
  ON public.leadgen_figma_assets FOR SELECT
  USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Authenticated users can edit leadgen figma assets" ON public.leadgen_figma_assets;
CREATE POLICY "Authenticated users can edit leadgen figma assets"
  ON public.leadgen_figma_assets FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
