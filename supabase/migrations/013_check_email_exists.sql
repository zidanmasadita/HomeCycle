-- Create an RPC to check if an email exists in auth.users
CREATE OR REPLACE FUNCTION check_email_exists(p_email text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM auth.users 
    WHERE email = p_email
  );
END;
$$;
