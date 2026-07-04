# CLAUDE.md — Database Setup (HomeCycle)

Panduan ini digunakan oleh Claude Code (atau developer) untuk setup, migrasi, dan maintain database Supabase project **HomeCycle** — aplikasi scan buah/sayur untuk deteksi kesegaran dan manajemen inventory guna mengurangi food waste.

---

## 1. Overview Project

- **Database**: PostgreSQL via Supabase
- **Auth**: Supabase Auth (built-in `auth.users`)
- **Storage**: Supabase Storage (untuk foto hasil scan)
- **Automation**: `pg_cron` + Edge Functions (untuk notifikasi expired)
- **Client**: Flutter, package `supabase_flutter`

Semua file SQL migration disimpan di `supabase/migrations/`, seed data di `supabase/seed/`, dan Edge Function di `supabase/functions/`.

---

## 2. Prasyarat

```bash
# Install Supabase CLI (jika belum)
npm install -g supabase

# Login ke akun Supabase
supabase login

# Link ke project Supabase yang sudah dibuat di dashboard
supabase link --project-ref <PROJECT_REF>
```

Environment variable yang dibutuhkan di Flutter (`.env` atau `--dart-define`):

```
SUPABASE_URL=https://<PROJECT_REF>.supabase.co
SUPABASE_ANON_KEY=<ANON_KEY>
```

**PENTING**: Jangan pernah commit `SUPABASE_SERVICE_ROLE_KEY` ke repository. Key ini hanya dipakai di Edge Function/server-side, bukan di client Flutter.

---

## 3. Urutan Migrasi

Jalankan migration **sesuai urutan** di bawah ini karena ada dependency foreign key antar tabel. Jangan skip urutan.

| Order | File | Deskripsi |
|---|---|---|
| 001 | `001_create_categories.sql` | Master data jenis buah/sayur |
| 002 | `002_create_food_items.sql` | Tabel inventory utama |
| 003 | `003_create_scan_history.sql` | Log setiap aktivitas scan |
| 004 | `004_create_consumption_log.sql` | Log konsumsi/wasted untuk statistik |
| 005 | `005_create_notifications.sql` | Reminder expired |
| 006 | `006_create_user_preferences.sql` | Preferensi user |
| 007 | `007_create_achievements.sql` | Data gamifikasi |
| 008 | `008_create_rls_policies.sql` | Row Level Security semua tabel |
| 009 | `009_create_views.sql` | View untuk dashboard/statistik |
| 010 | `010_create_functions_triggers.sql` | Function & trigger (updated_at, dll) |

Jalankan migrasi:

```bash
supabase migration up
```

Atau apply manual satu-satu lewat SQL Editor di Supabase Dashboard jika CLI tidak dipakai.

---

## 4. Skema Tabel

### 4.1 `categories`

Master data referensi jenis buah/sayur, termasuk data untuk estimasi expired dan kalkulasi dampak (CO2 & uang).

```sql
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
```

**Catatan**: Tabel ini bersifat read-only untuk user biasa. Hanya di-update lewat seed data atau admin panel.

### 4.2 `food_items`

Data inventory utama milik user.

```sql
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
```

### 4.3 `scan_history`

Log semua aktivitas scan, termasuk yang tidak disimpan ke inventory (untuk analitik akurasi model).

```sql
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
```

### 4.4 `consumption_log`

Basis utama statistik food waste & impact (uang/CO2 saved).

```sql
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
```

### 4.5 `notifications`

```sql
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
```

### 4.6 `user_preferences`

```sql
create table user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  notify_days_before_expiry int default 2,
  household_size int default 1,
  preferred_units text default 'metric',
  preferred_language text default 'id',
  updated_at timestamptz default now()
);
```

### 4.7 `achievements` & `user_achievements`

```sql
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
```

---

## 5. Row Level Security (RLS)

**WAJIB diaktifkan untuk semua tabel yang berisi data personal user.** Jangan pernah deploy ke production tanpa RLS aktif.

Pola standar yang dipakai di semua tabel bertipe personal (`food_items`, `scan_history`, `consumption_log`, `notifications`, `user_achievements`):

```sql
alter table <table_name> enable row level security;

create policy "Users can view own data"
on <table_name> for select
using (auth.uid() = user_id);

create policy "Users can insert own data"
on <table_name> for insert
with check (auth.uid() = user_id);

create policy "Users can update own data"
on <table_name> for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete own data"
on <table_name> for delete
using (auth.uid() = user_id);
```

Untuk `user_preferences` (primary key = `user_id`, bukan kolom terpisah):

```sql
alter table user_preferences enable row level security;

create policy "Users can manage own preferences"
on user_preferences for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

Untuk tabel referensi (`categories`, `achievements`) — read-only public, tanpa write dari client:

```sql
alter table categories enable row level security;

create policy "Anyone can read categories"
on categories for select
using (true);

-- tidak ada policy insert/update/delete untuk role 'authenticated'
-- perubahan hanya lewat service_role (admin/seed script)
```

**Checklist verifikasi RLS** setelah migrasi:

```sql
select tablename, rowsecurity 
from pg_tables 
where schemaname = 'public';
```

Semua tabel personal harus menunjukkan `rowsecurity = true`.

---

## 6. Views untuk Dashboard

```sql
create view monthly_waste_stats as
select 
  user_id,
  date_trunc('month', logged_at) as month,
  action,
  category_id,
  count(*) as total_items,
  sum(quantity) as total_quantity
from consumption_log
group by user_id, month, action, category_id;

create view user_impact_stats as
select
  user_id,
  sum(case when action = 'consumed' then money_saved else 0 end) as total_money_saved,
  sum(case when action = 'consumed' then co2_saved_kg else 0 end) as total_co2_saved,
  count(case when action = 'consumed' then 1 end) as items_saved,
  count(case when action = 'wasted' then 1 end) as items_wasted
from consumption_log
group by user_id;
```

**Catatan**: Views otomatis mewarisi RLS dari tabel dasarnya (`consumption_log`) selama query dijalankan sebagai role `authenticated`, jadi tidak perlu RLS terpisah di view.

---

## 7. Function & Trigger

### Auto-update `updated_at`

```sql
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_food_items_updated_at
before update on food_items
for each row execute function set_updated_at();
```

### Auto-create `user_preferences` saat user baru daftar

```sql
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.user_preferences (user_id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger trg_on_auth_user_created
after insert on auth.users
for each row execute function handle_new_user();
```

---

## 8. Seed Data

Jalankan setelah semua tabel dibuat, sebelum testing fitur scan/inventory:

```bash
supabase db execute -f supabase/seed/categories_seed.sql
```

`categories_seed.sql` minimal berisi jenis buah/sayur yang **didukung oleh model TFLite** (harus sinkron dengan label output model ML — jangan seed kategori yang modelnya tidak bisa deteksi).

Kolom wajib diisi saat seeding: `name`, `type`, `default_shelf_life_days`, `co2_factor_kg`, `avg_price_per_unit`, `avg_weight_per_unit_gram`. Tanpa data ini, fitur estimasi expired date dan impact calculator (CO2/uang saved) tidak akan berfungsi.

---

## 9. Storage Bucket

Buat bucket untuk foto hasil scan:

```sql
insert into storage.buckets (id, name, public)
values ('scan-photos', 'scan-photos', false);

create policy "Users can upload own scan photos"
on storage.objects for insert
with check (bucket_id = 'scan-photos' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "Users can view own scan photos"
on storage.objects for select
using (bucket_id = 'scan-photos' and auth.uid()::text = (storage.foldername(name))[1]);
```

Konvensi path upload dari Flutter: `scan-photos/{user_id}/{food_item_id}.jpg`

---

## 10. Edge Function — Cek Expired Harian

Lokasi: `supabase/functions/check-expiry/index.ts`

Fungsi ini dijalankan otomatis via `pg_cron`, mengecek `food_items` yang mendekati `estimated_expired_date`, lalu insert ke `notifications`.

Setup cron (jalankan sekali via SQL Editor):

```sql
create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.schedule(
  'check-expiring-items',
  '0 8 * * *',  -- setiap jam 08:00
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/check-expiry',
    headers := jsonb_build_object('Authorization', 'Bearer <SERVICE_ROLE_KEY>')
  )
  $$
);
```

Deploy Edge Function:

```bash
supabase functions deploy check-expiry
```

---

## 11. Testing Checklist Setelah Setup

- [ ] Semua migration berhasil dijalankan tanpa error, urut sesuai nomor
- [ ] RLS aktif di semua tabel personal (`select rowsecurity from pg_tables`)
- [ ] Coba insert row dengan `user_id` berbeda dari user yang login → harus **ditolak**
- [ ] Seed data `categories` sudah masuk dan field `co2_factor_kg`, `avg_price_per_unit` terisi
- [ ] Trigger `handle_new_user` bekerja — daftar user baru otomatis membuat row di `user_preferences`
- [ ] Storage bucket `scan-photos` bisa diupload dan URL bisa diakses lewat app (private, pakai signed URL)
- [ ] View `monthly_waste_stats` dan `user_impact_stats` mengembalikan data yang sesuai
- [ ] Edge Function `check-expiry` bisa dipanggil manual dan berhasil insert ke `notifications`
- [ ] pg_cron job terdaftar (`select * from cron.job;`)

---

## 12. Aturan untuk Perubahan Schema Selanjutnya

- **Selalu buat file migration baru**, jangan edit file migration lama yang sudah di-apply ke production
- Format nama file: `NNN_deskripsi_singkat.sql` (nomor urut 3 digit)
- Setiap migration yang menambah tabel baru dengan data personal **wajib** langsung menyertakan RLS policy di migration yang sama, jangan dipisah ke migration terpisah
- Update dokumen ini (`CLAUDE.md`) setiap kali ada perubahan struktur tabel signifikan
- Sebelum mengubah kolom yang sudah dipakai model Dart di Flutter, cek dulu semua `fromJson`/`toJson` yang terdampak di `lib/features/*/models/`