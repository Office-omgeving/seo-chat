-- Global upsell templates table
CREATE TABLE public.upsell_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  type text NOT NULL DEFAULT 'other',
  default_mrr integer NOT NULL DEFAULT 0,
  description text NOT NULL DEFAULT '',
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);
ALTER TABLE public.upsell_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view upsell templates" ON public.upsell_templates FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert upsell templates" ON public.upsell_templates FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update upsell templates" ON public.upsell_templates FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete upsell templates" ON public.upsell_templates FOR DELETE USING (auth.uid() IS NOT NULL);
CREATE TRIGGER update_upsell_templates_updated_at BEFORE UPDATE ON public.upsell_templates FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
-- Add hidden_upsell_templates column to track which global templates are hidden per client
ALTER TABLE public.client_upsells ADD COLUMN template_id uuid REFERENCES public.upsell_templates(id) ON DELETE SET NULL;
-- Seed default templates
INSERT INTO public.upsell_templates (title, type, default_mrr, description, sort_order) VALUES
  ('Call center uitbesteden', 'other', 800, 'Volledige uitbesteding van inbound/outbound calls', 1),
  ('Wervingscampagne', 'funnel', 500, 'Recruitment marketing campagne opzetten', 2),
  ('SEO & GPT traject', 'seo', 1500, 'Organische vindbaarheid en AI-optimalisatie', 3),
  ('PPA afspraken', 'other', 0, 'Pay-per-appointment model voor agency klanten', 4),
  ('Video producties', 'creative', 1200, 'Professionele video content voor ads en socials', 5),
  ('Bookingstool', 'other', 300, 'Online planning en reserveringssysteem', 6),
  ('Dashboarding', 'dashboard', 500, 'Custom real-time rapportage dashboard', 7),
  ('AI Leadqualifier Bot', 'other', 600, 'Automatische leadkwalificatie via AI chatbot', 8);
