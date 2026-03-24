-- Add a column to remember when a client was archived
ALTER TABLE public.clients
  ADD COLUMN archived_at timestamp with time zone;
COMMENT ON COLUMN public.clients.archived_at IS 'Wanneer de klant naar het archief is verhuisd';
