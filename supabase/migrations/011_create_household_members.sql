create table household_members (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  role text not null default 'Member',
  created_at timestamptz default now()
);

-- Enable RLS
alter table household_members enable row level security;

-- Only admins can view and manage their household members
create policy "Users can view their own household members"
  on household_members for select
  using (auth.uid() = admin_id);

create policy "Users can insert their own household members"
  on household_members for insert
  with check (auth.uid() = admin_id);

create policy "Users can update their own household members"
  on household_members for update
  using (auth.uid() = admin_id);

create policy "Users can delete their own household members"
  on household_members for delete
  using (auth.uid() = admin_id);
