-- Store next reporting meeting per client
CREATE TABLE public.client_meetings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id TEXT NOT NULL UNIQUE,
  next_meeting_date TIMESTAMP WITH TIME ZONE,
  meeting_notes TEXT,
  updated_by UUID,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
ALTER TABLE public.client_meetings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view meetings"
  ON public.client_meetings FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert meetings"
  ON public.client_meetings FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update meetings"
  ON public.client_meetings FOR UPDATE USING (auth.uid() IS NOT NULL);
