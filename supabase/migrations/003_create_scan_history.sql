create table scan_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  food_item_id uuid references food_items(id) on delete set null,
  category_id uuid references categories(id),
  detected_label text,
  confidence_score float,
  image_url text,
  was_saved_to_inventory boolean default false,
  scanned_at timestamptz default now()
);
