-- 1. Update notifications type constraint to allow 'invite'
-- Since the constraint might have an auto-generated name, we'll try dropping it if it's named notifications_type_check
DO $$ 
DECLARE
  constraint_name text;
BEGIN
  SELECT conname INTO constraint_name
  FROM pg_constraint
  WHERE conrelid = 'notifications'::regclass AND contype = 'c' AND conname LIKE '%type%';

  IF constraint_name IS NOT NULL THEN
    EXECUTE 'ALTER TABLE notifications DROP CONSTRAINT ' || constraint_name;
  END IF;
END $$;

ALTER TABLE notifications 
ADD CONSTRAINT notifications_type_check 
CHECK (type in ('expiring_soon', 'expired', 'tip', 'achievement', 'invite'));

-- 2. Fix the RPC to use 'body' instead of 'message'
CREATE OR REPLACE FUNCTION invite_household_member(p_username text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_inviter_id uuid := auth.uid();
  v_invitee_id uuid;
  v_existing_member uuid;
  v_existing_admin uuid;
  v_existing_invite uuid;
BEGIN
  IF v_inviter_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Find user by username
  SELECT id INTO v_invitee_id
  FROM auth.users
  WHERE (raw_user_meta_data->>'username' = p_username OR 
         raw_user_meta_data->>'name' = p_username OR
         raw_user_meta_data->>'full_name' = p_username)
  LIMIT 1;

  IF v_invitee_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'User not found');
  END IF;

  IF v_invitee_id = v_inviter_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'You cannot invite yourself');
  END IF;

  -- Check if they are already in a household
  SELECT id INTO v_existing_member
  FROM household_members
  WHERE member_id = v_invitee_id
  LIMIT 1;

  IF v_existing_member IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'User is already in a household');
  END IF;

  -- Check if they have a pending invite from this household
  SELECT id INTO v_existing_invite
  FROM household_invitations
  WHERE inviter_id = v_inviter_id AND invitee_id = v_invitee_id AND status = 'pending'
  LIMIT 1;

  IF v_existing_invite IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'User already has a pending invitation from you');
  END IF;

  -- Insert Invitation
  INSERT INTO household_invitations (inviter_id, invitee_id, status)
  VALUES (v_inviter_id, v_invitee_id, 'pending');

  -- Create Notification using 'body' instead of 'message'
  INSERT INTO notifications (user_id, title, body, type, is_read)
  VALUES (
    v_invitee_id, 
    'Household Invitation', 
    'You have been invited to join a household.', 
    'invite', 
    false
  );

  RETURN jsonb_build_object('success', true, 'message', 'Invitation sent successfully');
END;
$$;
