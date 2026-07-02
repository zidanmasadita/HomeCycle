create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('fruit', 'vegetable')),
  default_shelf_life_days int not null,
  fridge_shelf_life_days int,
  storage_tip text,
  icon_url text,
  co2_factor_kg numeric,              -- kg CO2e per kg makanan
  avg_price_per_unit numeric,         -- untuk kalkulasi money saved
  avg_weight_per_unit_gram numeric,   -- konversi pcs -> kg
  created_at timestamptz default now()
);
