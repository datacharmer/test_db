select timediff(
    (select update_time from information_schema.tables where table_schema='employees' and table_name='salaries'),
    (select create_time from information_schema.tables where table_schema='employees' and table_name='employees')
) as data_load_time_diff;

