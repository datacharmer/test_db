--  Sample employee database 
--  See changelog for details
--  Copyright (C) 2007,2008, MySQL AB
--  
--  Original data created by Fusheng Wang and Carlo Zaniolo
--  http://www.cs.aau.dk/TimeCenter/software.htm
--  http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- 
--  Current schema by Giuseppe Maxia 
--  Data conversion from XML to relational by Patrick Crews
-- 
-- This work is licensed under the 
-- Creative Commons Attribution-Share Alike 3.0 Unported License. 
-- To view a copy of this license, visit 
-- http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
-- Creative Commons, 171 Second Street, Suite 300, San Francisco, 
-- California, 94105, USA.
-- 
--  DISCLAIMER
--  To the best of our knowledge, this data is fabricated, and
--  it does not correspond to real people. 
--  Any similarity to existing people is purely coincidental.
-- 

USE employees;

SELECT 'TESTING INSTALLATION' as 'INFO';

DROP TABLE IF EXISTS expected_values, found_values;
CREATE TABLE expected_values (
    table_name varchar(30) not null primary key,
    recs int not null,
    crc_sha varchar(100) not null,
    crc_md5 varchar(100) not null
);


CREATE TABLE found_values LIKE expected_values;

INSERT INTO `expected_values` VALUES 
('employees',   300024,'4d4aa689914d8fd41db7e45c2168e7dcb9697359',
                        '4ec56ab5ba37218d187cf6ab09ce1aa1'),
('departments',      9,'4b315afa0e35ca6649df897b958345bcb3d2b764',
                       'd1af5e170d2d1591d776d5638d71fc5f'),
('dept_manager',    24,'9687a7d6f93ca8847388a42a6d8d93982a841c6c',
                       '8720e2f0853ac9096b689c14664f847e'),
('dept_emp',    331603, 'd95ab9fe07df0865f592574b3b33b9c741d9fd1b',
                       'ccf6fe516f990bdaa49713fc478701b7'),
('titles',      443308,'d12d5f746b88f07e69b9e36675b6067abb01b60e',
                       'bfa016c472df68e70a03facafa1bc0a8'),
('salaries',   2844047,'b5a1785c27d75e33a4173aaa22ccf41ebd7d4a9f',
                       'fd220654e95aea1b169624ffe3fca934');
SELECT table_name, recs AS expected_records, crc_sha AS expected_crc FROM expected_values;

DROP TABLE IF EXISTS tchecksum;
CREATE TABLE tchecksum (chk char(100));

SET @crc= '';

INSERT INTO tchecksum 
    SELECT @crc := sha(CONCAT_WS('#',@crc,
                emp_no,birth_date,first_name,last_name,gender,hire_date)) 
    FROM employees ORDER BY emp_no;
INSERT INTO found_values VALUES ('employees', (SELECT COUNT(*) FROM employees), @crc,@crc);

SET @crc = '';
INSERT INTO tchecksum 
    SELECT @crc := sha(CONCAT_WS('#',@crc, dept_no,dept_name)) 
    FROM departments ORDER BY dept_no;
INSERT INTO found_values values ('departments', (SELECT COUNT(*) FROM departments), @crc,@crc);

SET @crc = '';
INSERT INTO tchecksum 
    SELECT @crc := sha(CONCAT_WS('#',@crc, dept_no,emp_no, from_date,to_date)) 
    FROM dept_manager ORDER BY dept_no,emp_no;
INSERT INTO found_values values ('dept_manager', (SELECT COUNT(*) FROM dept_manager), @crc,@crc);

SET @crc = '';
INSERT INTO tchecksum 
    SELECT @crc := sha(CONCAT_WS('#',@crc, dept_no,emp_no, from_date,to_date)) 
    FROM dept_emp ORDER BY dept_no,emp_no;
INSERT INTO found_values values ('dept_emp', (SELECT COUNT(*) FROM dept_emp), @crc,@crc);

SET @crc = '';
INSERT INTO tchecksum 
    SELECT @crc := sha(CONCAT_WS('#',@crc, emp_no, title, from_date,to_date)) 
    FROM titles order by emp_no,title, from_date;
INSERT INTO found_values values ('titles', (SELECT COUNT(*) FROM titles), @crc,@crc);

SET @crc = '';
INSERT INTO tchecksum 
    SELECT @crc := sha(CONCAT_WS('#',@crc, emp_no, salary, from_date,to_date)) 
    FROM salaries order by emp_no,from_date,to_date;
INSERT INTO found_values values ('salaries', (SELECT COUNT(*) FROM salaries), @crc,@crc);

DROP TABLE tchecksum;

SELECT table_name, recs as 'found_records   ', crc_sha as found_crc from found_values;

SELECT  
    e.table_name, 
    IF(e.recs=f.recs,'OK', 'not ok') AS records_match, 
    IF(e.crc_sha=f.crc_sha,'ok','not ok') AS crc_match 
from 
    expected_values e INNER JOIN found_values f USING (table_name); 

set @crc_fail=(select count(*) from expected_values e inner join found_values f on (e.table_name=f.table_name) where f.crc_sha != e.crc_sha);
set @count_fail=(select count(*) from expected_values e inner join found_values f on (e.table_name=f.table_name) where f.recs != e.recs);

select timediff(
    now(),
    (select create_time from information_schema.tables where table_schema='employees' and table_name='expected_values')
) as computation_time;
DROP TABLE expected_values,found_values;

select 'CRC' as summary,  if(@crc_fail = 0, "OK", "FAIL" ) as 'result'
union all
select 'count', if(@count_fail = 0, "OK", "FAIL" ) as 'count';


