-- Personal Data Tables
-- food_items
alter table food_items enable row level security;
create policy "Users can view own data" on food_items for select using (auth.uid() = user_id);
create policy "Users can insert own data" on food_items for insert with check (auth.uid() = user_id);
create policy "Users can update own data" on food_items for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own data" on food_items for delete using (auth.uid() = user_id);

-- scan_history
alter table scan_history enable row level security;
create policy "Users can view own data" on scan_history for select using (auth.uid() = user_id);
create policy "Users can insert own data" on scan_history for insert with check (auth.uid() = user_id);
create policy "Users can update own data" on scan_history for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own data" on scan_history for delete using (auth.uid() = user_id);

-- consumption_log
alter table consumption_log enable row level security;
create policy "Users can view own data" on consumption_log for select using (auth.uid() = user_id);
create policy "Users can insert own data" on consumption_log for insert with check (auth.uid() = user_id);
create policy "Users can update own data" on consumption_log for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own data" on consumption_log for delete using (auth.uid() = user_id);

-- notifications
alter table notifications enable row level security;
create policy "Users can view own data" on notifications for select using (auth.uid() = user_id);
create policy "Users can insert own data" on notifications for insert with check (auth.uid() = user_id);
create policy "Users can update own data" on notifications for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own data" on notifications for delete using (auth.uid() = user_id);

-- user_achievements
alter table user_achievements enable row level security;
create policy "Users can view own data" on user_achievements for select using (auth.uid() = user_id);
create policy "Users can insert own data" on user_achievements for insert with check (auth.uid() = user_id);
create policy "Users can update own data" on user_achievements for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own data" on user_achievements for delete using (auth.uid() = user_id);

-- user_preferences
alter table user_preferences enable row level security;
create policy "Users can manage own preferences" on user_preferences for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Reference Tables
-- categories
alter table categories enable row level security;
create policy "Anyone can read categories" on categories for select using (true);

-- achievements
alter table achievements enable row level security;
create policy "Anyone can read achievements" on achievements for select using (true);

-- Storage bucket is not done via migration files natively usually unless stated, but CLAUDE.md mentions:
insert into storage.buckets (id, name, public) values ('scan-photos', 'scan-photos', false);
create policy "Users can upload own scan photos" on storage.objects for insert with check (bucket_id = 'scan-photos' and auth.uid()::text = (storage.foldername(name))[1]);
create policy "Users can view own scan photos" on storage.objects for select using (bucket_id = 'scan-photos' and auth.uid()::text = (storage.foldername(name))[1]);
