create table achievements (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,          -- 'zero_waste_week', '100_items_saved', dll
  title text not null,
  description text,
  icon_url text,
  criteria_type text,                 -- 'streak', 'count', 'threshold'
  criteria_value numeric,
  created_at timestamptz default now()
);

create table user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  achievement_id uuid references achievements(id) not null,
  achieved_at timestamptz default now(),
  unique(user_id, achievement_id)
);
