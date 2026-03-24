-- Add relationship_status column to clients table
ALTER TABLE public.clients 
ADD COLUMN relationship_status text NOT NULL DEFAULT 'neutral';
-- Add comment for clarity
COMMENT ON COLUMN public.clients.relationship_status IS 'Account manager assessment: positive, neutral, negative';
