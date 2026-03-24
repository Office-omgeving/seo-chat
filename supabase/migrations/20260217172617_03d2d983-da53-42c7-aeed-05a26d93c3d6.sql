-- Global report settings
CREATE TABLE public.report_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key text NOT NULL UNIQUE,
  setting_value text NOT NULL DEFAULT '',
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid
);
ALTER TABLE public.report_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view report settings"
  ON public.report_settings FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update report settings"
  ON public.report_settings FOR UPDATE
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert report settings"
  ON public.report_settings FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
INSERT INTO public.report_settings (setting_key, setting_value) VALUES
  ('report_system_prompt', 'Je bent een rapportage-assistent voor een lead generation agency. Je maakt gestructureerde rapportage-outlines voor marketeers op basis van de beschikbare klantdata van een geselecteerde periode. Focus op: performance trends, uitgevoerde optimalisaties, openstaande acties, en aanbevelingen voor de volgende periode.'),
  ('report_tone', 'professioneel'),
  ('report_language', 'nl'),
  ('report_sections', 'Samenvatting,Performance Analyse,Optimalisaties & Aanpassingen,Openstaande Acties,Aanbevelingen');
CREATE TRIGGER update_report_settings_updated_at
  BEFORE UPDATE ON public.report_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
-- Wins & Learnings knowledge base
CREATE TABLE public.wins_learnings (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id text,
  type text NOT NULL DEFAULT 'win' CHECK (type IN ('win', 'learning')),
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  tags text[] NOT NULL DEFAULT '{}',
  channel text,
  funnel_type text,
  is_global boolean NOT NULL DEFAULT true,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);
ALTER TABLE public.wins_learnings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view wins learnings"
  ON public.wins_learnings FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert wins learnings"
  ON public.wins_learnings FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update wins learnings"
  ON public.wins_learnings FOR UPDATE
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete wins learnings"
  ON public.wins_learnings FOR DELETE
  USING (auth.uid() IS NOT NULL);
CREATE TRIGGER update_wins_learnings_updated_at
  BEFORE UPDATE ON public.wins_learnings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
