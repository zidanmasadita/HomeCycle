-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own data" ON food_items;
DROP POLICY IF EXISTS "Users can insert own data" ON food_items;
DROP POLICY IF EXISTS "Users can update own data" ON food_items;
DROP POLICY IF EXISTS "Users can delete own data" ON food_items;

DROP POLICY IF EXISTS "Users can view own data" ON consumption_log;
DROP POLICY IF EXISTS "Users can insert own data" ON consumption_log;
DROP POLICY IF EXISTS "Users can update own data" ON consumption_log;
DROP POLICY IF EXISTS "Users can delete own data" ON consumption_log;

DROP POLICY IF EXISTS "Users can view own data" ON scan_history;
DROP POLICY IF EXISTS "Users can insert own data" ON scan_history;
DROP POLICY IF EXISTS "Users can update own data" ON scan_history;
DROP POLICY IF EXISTS "Users can delete own data" ON scan_history;

-- Create shared policies for food_items
CREATE POLICY "Users can view household data" ON food_items FOR SELECT USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can insert household data" ON food_items FOR INSERT WITH CHECK (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can update household data" ON food_items FOR UPDATE USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
) WITH CHECK (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can delete household data" ON food_items FOR DELETE USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);

-- Create shared policies for consumption_log
CREATE POLICY "Users can view household data" ON consumption_log FOR SELECT USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can insert household data" ON consumption_log FOR INSERT WITH CHECK (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can update household data" ON consumption_log FOR UPDATE USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
) WITH CHECK (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can delete household data" ON consumption_log FOR DELETE USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);

-- Create shared policies for scan_history
CREATE POLICY "Users can view household data" ON scan_history FOR SELECT USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can insert household data" ON scan_history FOR INSERT WITH CHECK (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can update household data" ON scan_history FOR UPDATE USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
) WITH CHECK (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);
CREATE POLICY "Users can delete household data" ON scan_history FOR DELETE USING (
  user_id = auth.uid() OR
  user_id = get_user_household_admin(auth.uid())
);

-- Create shared policies for storage
DROP POLICY IF EXISTS "Users can view own scan photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own scan photos" ON storage.objects;

CREATE POLICY "Users can view household scan photos" ON storage.objects FOR SELECT USING (
  bucket_id = 'scan-photos' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    (storage.foldername(name))[1] = get_user_household_admin(auth.uid())::text OR
    get_user_household_admin((storage.foldername(name))[1]::uuid) = get_user_household_admin(auth.uid())
  )
);

CREATE POLICY "Users can upload household scan photos" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'scan-photos' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    (storage.foldername(name))[1] = get_user_household_admin(auth.uid())::text
  )
);