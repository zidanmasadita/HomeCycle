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
