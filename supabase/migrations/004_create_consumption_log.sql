create table consumption_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  food_item_id uuid references food_items(id) on delete set null,
  category_id uuid references categories(id),
  action text not null check (action in ('consumed', 'wasted')),
  quantity numeric,
  co2_saved_kg numeric,
  money_saved numeric,
  reason text,
  logged_at timestamptz default now()
);

create index idx_consumption_log_user on consumption_log(user_id);
create index idx_consumption_log_action on consumption_log(action);
