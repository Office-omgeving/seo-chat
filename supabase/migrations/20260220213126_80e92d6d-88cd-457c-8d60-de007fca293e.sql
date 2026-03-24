-- Create client_upsells table for tracking all upsell proposals per client
CREATE TABLE public.client_upsells (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id text NOT NULL,
  title text NOT NULL,
  type text NOT NULL DEFAULT 'other',
  status text NOT NULL DEFAULT 'identified',
  potential_mrr integer NOT NULL DEFAULT 0,
  owner text NOT NULL DEFAULT '',
  reason_declined text,
  notes text DEFAULT '',
  created_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);
-- Enable RLS
ALTER TABLE public.client_upsells ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can view client upsells"
  ON public.client_upsells FOR SELECT
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can insert client upsells"
  ON public.client_upsells FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update client upsells"
  ON public.client_upsells FOR UPDATE
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can delete client upsells"
  ON public.client_upsells FOR DELETE
  USING (auth.uid() IS NOT NULL);
-- Trigger for updated_at
CREATE TRIGGER update_client_upsells_updated_at
  BEFORE UPDATE ON public.client_upsells
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
