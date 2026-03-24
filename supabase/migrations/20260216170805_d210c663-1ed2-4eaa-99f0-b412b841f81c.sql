-- Onboarding phases per client (custom order)
CREATE TABLE public.onboarding_phases (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id TEXT NOT NULL,
  label TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_current BOOLEAN NOT NULL DEFAULT false,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
ALTER TABLE public.onboarding_phases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view onboarding phases"
  ON public.onboarding_phases FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert onboarding phases"
  ON public.onboarding_phases FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update onboarding phases"
  ON public.onboarding_phases FOR UPDATE
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete onboarding phases"
  ON public.onboarding_phases FOR DELETE
  USING (auth.uid() IS NOT NULL);
CREATE INDEX idx_onboarding_client ON public.onboarding_phases (client_id, sort_order);
