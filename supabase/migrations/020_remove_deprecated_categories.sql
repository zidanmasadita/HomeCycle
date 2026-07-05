update food_items set category_id = (select id from categories where name = 'paprika')
where category_id in (select id from categories where name in ('bell pepper', 'capsicum'));

-- raddish & turnip -> tidak ada pengganti jelas, set null agar user pilih ulang manual
update food_items set category_id = null
where category_id in (select id from categories where name in ('raddish', 'turnip'));

update scan_history set category_id = (select id from categories where name = 'paprika')
where category_id in (select id from categories where name in ('bell pepper', 'capsicum'));

update scan_history set category_id = null
where category_id in (select id from categories where name in ('raddish', 'turnip'));

update consumption_log set category_id = (select id from categories where name = 'paprika')
where category_id in (select id from categories where name in ('bell pepper', 'capsicum'));

update consumption_log set category_id = null
where category_id in (select id from categories where name in ('raddish', 'turnip'));

-- Baru hapus kategorinya setelah semua referensi aman
delete from categories where name in ('bell pepper', 'capsicum', 'raddish', 'turnip');
