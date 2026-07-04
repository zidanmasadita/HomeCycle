-- Memperjelas criteria_type di tabel achievements supaya provider bisa
-- membedakan threshold uang vs CO2, bukan satu 'threshold' generik.
-- Jalankan setelah migration 007_create_achievements.sql.

alter table achievements drop constraint if exists achievements_criteria_type_check;

alter table achievements add constraint achievements_criteria_type_check
  check (criteria_type in ('items_count', 'streak_weeks', 'money_threshold', 'co2_threshold'));
