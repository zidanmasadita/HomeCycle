CREATE OR REPLACE FUNCTION get_user_name(p_user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT COALESCE(raw_user_meta_data->>'username', raw_user_meta_data->>'name', raw_user_meta_data->>'full_name', 'Household Admin') 
  FROM auth.users 
  WHERE id = p_user_id;
$$;
