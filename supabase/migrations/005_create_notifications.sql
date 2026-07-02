create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  food_item_id uuid references food_items(id) on delete cascade,
  type text check (type in ('expiring_soon', 'expired', 'tip', 'achievement')),
  title text not null,
  body text not null,
  is_read boolean default false,
  scheduled_at timestamptz,
  sent_at timestamptz,
  created_at timestamptz default now()
);
