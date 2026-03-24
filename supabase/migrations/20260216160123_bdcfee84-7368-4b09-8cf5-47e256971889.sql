-- Add admin to the role enum
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'admin';
