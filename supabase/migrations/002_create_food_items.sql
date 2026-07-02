create table food_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  category_id uuid references categories(id) not null,
  custom_name text,
  condition text check (condition in ('fresh', 'ripe', 'overripe', 'rotten')),
  confidence_score float,
  quantity numeric default 1,
  unit text default 'pcs' check (unit in ('pcs', 'kg', 'gram', 'ikat')),
  storage_location text check (storage_location in ('fridge', 'room_temp', 'freezer')),
  scanned_at timestamptz default now(),
  estimated_expired_date date not null,
  actual_status text default 'active' check (actual_status in ('active', 'consumed', 'wasted', 'expired')),
  image_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_food_items_user on food_items(user_id);
create index idx_food_items_expired on food_items(estimated_expired_date);
create index idx_food_items_status on food_items(actual_status);
