create table user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  notify_days_before_expiry int default 2,
  household_size int default 1,
  preferred_units text default 'metric',
  preferred_language text default 'id',
  updated_at timestamptz default now()
);
