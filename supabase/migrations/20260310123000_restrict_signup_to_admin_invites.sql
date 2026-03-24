-- Only allow new accounts that originate from an admin invite flow.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  signup_role public.app_role;
BEGIN
  IF NEW.invited_at IS NULL THEN
    RAISE EXCEPTION 'Nieuwe accounts moeten via een superadmin-uitnodiging worden aangemaakt';
  END IF;

  IF NEW.raw_user_meta_data->>'role' IS NULL THEN
    RAISE EXCEPTION 'Rol is verplicht bij accountaanmaak';
  END IF;

  BEGIN
    signup_role := (NEW.raw_user_meta_data->>'role')::public.app_role;
  EXCEPTION
    WHEN invalid_text_representation THEN
      RAISE EXCEPTION 'Ongeldige rol bij accountaanmaak';
  END;

  INSERT INTO public.profiles (user_id, display_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email),
    NEW.email
  );

  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, signup_role);

  RETURN NEW;
END;
$$;
