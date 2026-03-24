-- Table to log completed action items
CREATE TABLE public.completed_actions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id TEXT NOT NULL,
  checkin_id TEXT NOT NULL,
  action_key TEXT NOT NULL,
  completed_by UUID NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(client_id, checkin_id, action_key, completed_by)
);
ALTER TABLE public.completed_actions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view completed actions"
  ON public.completed_actions FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert completed actions"
  ON public.completed_actions FOR INSERT
  WITH CHECK (auth.uid() = completed_by);
CREATE POLICY "Users can delete own completed actions"
  ON public.completed_actions FOR DELETE
  USING (auth.uid() = completed_by);
