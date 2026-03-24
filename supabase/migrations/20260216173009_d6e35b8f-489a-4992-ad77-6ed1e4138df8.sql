-- Client facts: birthdays, personal notes, sales team info
CREATE TABLE public.client_facts (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id text NOT NULL,
  label text NOT NULL,
  value text NOT NULL DEFAULT '',
  fact_date date,
  category text NOT NULL DEFAULT 'general',
  created_by uuid REFERENCES auth.users(id),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);
ALTER TABLE public.client_facts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view client facts" ON public.client_facts FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert client facts" ON public.client_facts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update client facts" ON public.client_facts FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete client facts" ON public.client_facts FOR DELETE USING (auth.uid() IS NOT NULL);
CREATE TRIGGER update_client_facts_updated_at BEFORE UPDATE ON public.client_facts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
-- Client reminders with notification datetime
CREATE TABLE public.client_reminders (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id text NOT NULL,
  title text NOT NULL,
  description text DEFAULT '',
  remind_at timestamp with time zone NOT NULL,
  is_recurring boolean NOT NULL DEFAULT false,
  recurrence_type text,
  is_dismissed boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);
ALTER TABLE public.client_reminders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view reminders" ON public.client_reminders FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert reminders" ON public.client_reminders FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update reminders" ON public.client_reminders FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete reminders" ON public.client_reminders FOR DELETE USING (auth.uid() IS NOT NULL);
CREATE TRIGGER update_client_reminders_updated_at BEFORE UPDATE ON public.client_reminders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
