-- Create clients table matching the Client type
CREATE TABLE public.clients (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  contact_person text NOT NULL DEFAULT '',
  contact_email text NOT NULL DEFAULT '',
  contact_phone text NOT NULL DEFAULT '',
  contacts jsonb NOT NULL DEFAULT '[]'::jsonb,
  contract_type text NOT NULL DEFAULT '',
  mrr integer NOT NULL DEFAULT 0,
  start_date text NOT NULL DEFAULT '',
  initial_lead_type text NOT NULL DEFAULT '',
  funnel_type text NOT NULL DEFAULT '',
  kpis text[] NOT NULL DEFAULT '{}',
  account_manager_id text NOT NULL DEFAULT '',
  account_manager_name text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'healthy' CHECK (status IN ('healthy', 'risk', 'critical')),
  ad_accounts text[] NOT NULL DEFAULT '{}',
  regions text[] NOT NULL DEFAULT '{}',
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  created_by uuid REFERENCES auth.users(id)
);
-- Enable RLS
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
-- Policies: all authenticated users can read
CREATE POLICY "Authenticated users can view clients"
  ON public.clients FOR SELECT
  USING (auth.uid() IS NOT NULL);
-- Only authenticated users can insert
CREATE POLICY "Authenticated users can create clients"
  ON public.clients FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
-- Only authenticated users can update
CREATE POLICY "Authenticated users can update clients"
  ON public.clients FOR UPDATE
  USING (auth.uid() IS NOT NULL);
-- Only authenticated users can delete
CREATE POLICY "Authenticated users can delete clients"
  ON public.clients FOR DELETE
  USING (auth.uid() IS NOT NULL);
-- Trigger for updated_at
CREATE TRIGGER update_clients_updated_at
  BEFORE UPDATE ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
