-- Fix RLS recursion by using a security definer function to get the user's admin_id
CREATE OR REPLACE FUNCTION get_user_household_admin(p_user_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT admin_id FROM household_members WHERE member_id = p_user_id LIMIT 1;
$$;

-- Drop the old policy
DROP POLICY IF EXISTS "Users can view their own household members" ON household_members;

-- Create the new policy
CREATE POLICY "Users can view members of their household"
  ON household_members FOR SELECT
  USING (
    auth.uid() = admin_id OR 
    admin_id = get_user_household_admin(auth.uid())
  );
