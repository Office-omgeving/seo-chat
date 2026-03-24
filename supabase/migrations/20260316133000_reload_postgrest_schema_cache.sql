-- Force PostgREST to refresh its schema cache after adding archived_at to clients
NOTIFY pgrst, 'reload schema';
