-- 1. Modify household_members to include member_id and enforce UNIQUE constraint
TRUNCATE TABLE household_members CASCADE;

ALTER TABLE household_members
ADD COLUMN member_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- Enforce that a user can only be a member of one household
ALTER TABLE household_members
ADD CONSTRAINT unique_member_id UNIQUE (member_id);

-- 2. Create household_invitations table
CREATE TABLE household_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  inviter_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS for invitations
ALTER TABLE household_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view invites they sent or received"
  ON household_invitations FOR SELECT
  USING (auth.uid() = inviter_id OR auth.uid() = invitee_id);

CREATE POLICY "Invitee can update their received invites"
  ON household_invitations FOR UPDATE
  USING (auth.uid() = invitee_id);

CREATE POLICY "Inviter can delete sent invites"
  ON household_invitations FOR DELETE
  USING (auth.uid() = inviter_id);

-- 3. RPC to Invite a Household Member
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

  -- Create Notification (assuming notifications table exists)
  INSERT INTO notifications (user_id, title, message, type, is_read)
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

-- 4. RPC to Accept an Invite
CREATE OR REPLACE FUNCTION accept_household_invite(p_invite_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_inviter_id uuid;
  v_status text;
  v_existing_member uuid;
  v_username text;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  -- Verify invite exists and belongs to the user
  SELECT inviter_id, status INTO v_inviter_id, v_status
  FROM household_invitations
  WHERE id = p_invite_id AND invitee_id = v_user_id
  LIMIT 1;

  IF v_inviter_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invitation not found');
  END IF;

  IF v_status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invitation is already ' || v_status);
  END IF;

  -- Check again if user is in a household
  SELECT id INTO v_existing_member
  FROM household_members
  WHERE member_id = v_user_id
  LIMIT 1;

  IF v_existing_member IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'You are already in a household');
  END IF;

  -- Get username
  SELECT COALESCE(raw_user_meta_data->>'username', raw_user_meta_data->>'name', raw_user_meta_data->>'full_name', 'Member') 
  INTO v_username
  FROM auth.users
  WHERE id = v_user_id;

  -- Update invite status
  UPDATE household_invitations SET status = 'accepted' WHERE id = p_invite_id;

  -- Insert into household_members
  INSERT INTO household_members (admin_id, member_id, name, role)
  VALUES (v_inviter_id, v_user_id, v_username, 'Member');

  RETURN jsonb_build_object('success', true, 'message', 'Joined household successfully');
END;
$$;

-- 5. RPC to Decline an Invite
CREATE OR REPLACE FUNCTION decline_household_invite(p_invite_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_status text;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
  END IF;

  SELECT status INTO v_status
  FROM household_invitations
  WHERE id = p_invite_id AND invitee_id = v_user_id;

  IF v_status IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invitation not found');
  END IF;

  IF v_status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invitation is already ' || v_status);
  END IF;

  -- Update status
  UPDATE household_invitations SET status = 'declined' WHERE id = p_invite_id;

  RETURN jsonb_build_object('success', true, 'message', 'Invitation declined');
END;
$$;
