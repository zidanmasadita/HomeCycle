-- Seed data achievements untuk HomeCycle
-- Jalankan setelah migration 011_alter_achievements_criteria_type.sql

insert into achievements (code, title, description, criteria_type, criteria_value) values
  -- Milestone item terselamatkan
  ('first_rescue',      'First Rescue',        'Consume your first saved item before it expires',   'items_count', 1),
  ('getting_started',   'Getting Started',     'Consume 10 items before they expire',               'items_count', 10),
  ('waste_warrior',     'Waste Warrior',       'Consume 50 items before they expire',               'items_count', 50),
  ('century_saver',     'Century Saver',       'Consume 100 items before they expire',              'items_count', 100),
  ('local_hero',        'Local Hero',          'Consume 500 items before they expire',              'items_count', 500),

  -- Zero waste streak
  ('first_week_clean',  'First Week Clean',    '1 week straight with zero wasted items',            'streak_weeks', 1),
  ('habit_builder',     'Habit Builder',       '4 weeks straight with zero wasted items',           'streak_weeks', 4),
  ('zero_waste_master', 'Zero Waste Master',   '12 weeks straight with zero wasted items',          'streak_weeks', 12),

  -- Uang terselamatkan
  ('budget_saver',      'Budget Saver',        'Save Rp 100,000 in total from rescued food',        'money_threshold', 100000),
  ('smart_spender',     'Smart Spender',       'Save Rp 500,000 in total from rescued food',        'money_threshold', 500000),
  ('rp1juta_club',      'Rp 1 Juta Club',      'Save Rp 1,000,000 in total from rescued food',      'money_threshold', 1000000),

  -- Dampak lingkungan
  ('green_starter',     'Green Starter',       'Save 1 kg of CO2 emissions in total',               'co2_threshold', 1),
  ('carbon_cutter',     'Carbon Cutter',       'Save 10 kg of CO2 emissions in total',              'co2_threshold', 10),
  ('climate_champion',  'Climate Champion',    'Save 50 kg of CO2 emissions in total',              'co2_threshold', 50);
