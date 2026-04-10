# test_db
A sample database with an integrated test suite, used to test your applications and database servers

This repository was migrated from [Launchpad](https://launchpad.net/test-db).

See usage in the [MySQL docs](https://dev.mysql.com/doc/employee/en/index.html)

[![CI MySQL](https://github.com/datacharmer/test_db/actions/workflows/ci-mysql.yml/badge.svg)](https://github.com/datacharmer/test_db/actions/workflows/ci-mysql.yml)
[![CI Percona](https://github.com/datacharmer/test_db/actions/workflows/ci-percona.yml/badge.svg)](https://github.com/datacharmer/test_db/actions/workflows/ci-percona.yml)
[![CI MariaDB](https://github.com/datacharmer/test_db/actions/workflows/ci-mariadb.yml/badge.svg)](https://github.com/datacharmer/test_db/actions/workflows/ci-mariadb.yml)
[![CI PostgreSQL](https://github.com/datacharmer/test_db/actions/workflows/ci-postgresql.yml/badge.svg)](https://github.com/datacharmer/test_db/actions/workflows/ci-postgresql.yml)


## Tested Versions

The database requires MySQL 5.0+ or PostgreSQL 12+. The following versions are tested in CI
using [ProxySQL/dbdeployer](https://github.com/ProxySQL/dbdeployer) on a weekly schedule:

| Vendor | Versions |
|--------|----------|
| MySQL | 5.6, 5.7, 8.0, 8.4, 9.0, 9.2, 9.5, 9.6 |
| Percona Server | 8.0, 8.4 |
| MariaDB | 10.11, 11.4, 12.1 |
| PostgreSQL | 16, 17 |

### MySQL 9.x Notes

Starting with MySQL 9.5, the `SOURCE` command requires the `--commands` flag on the client:

    mysql --commands < employees.sql

Starting with MySQL 9.6, the `MD5()` and `SHA()` functions have been removed from the server.
The integrity test files `test_employees_md5.sql` and `test_employees_sha.sql` will not work on 9.6+.
Use `test_employees_sha2.sql` instead, which uses `SHA2(..., 256)` and is compatible with all versions:

    mysql -t < test_employees_sha2.sql

The SHA-256 checksums are identical across all supported MySQL, Percona, MariaDB, and PostgreSQL versions.


## Tested Versions

The database requires MySQL 5.0+ or compatible server. The following versions are tested in CI
using [ProxySQL/dbdeployer](https://github.com/ProxySQL/dbdeployer) on a weekly schedule:

| Vendor | Versions |
|--------|----------|
| MySQL | 5.6, 5.7, 8.0, 8.4, 9.0, 9.2, 9.5, 9.6 |
| Percona Server | 8.0, 8.4 |
| MariaDB | 10.11, 11.4, 12.1 |

### MySQL 9.x Notes

Starting with MySQL 9.5, the `SOURCE` command requires the `--commands` flag on the client:

    mysql --commands < employees.sql

Starting with MySQL 9.6, the `MD5()` and `SHA()` functions have been removed from the server.
The integrity test files `test_employees_md5.sql` and `test_employees_sha.sql` will not work on 9.6+.
Use `test_employees_sha2.sql` instead, which uses `SHA2(..., 256)` and is compatible with all versions:

    mysql -t < test_employees_sha2.sql

The SHA-256 checksums are identical across all supported MySQL, Percona, and MariaDB versions.


## Where it comes from

The original data was created by Fusheng Wang and Carlo Zaniolo at 
Siemens Corporate Research. The data is in XML format.
http://timecenter.cs.aau.dk/software.htm

Giuseppe Maxia made the relational schema and Patrick Crews exported
the data in relational format.

The database contains about 300,000 employee records with 2.8 million 
salary entries. The export data is 167 MB, which is not huge, but
heavy enough to be non-trivial for testing.

The data was generated, and as such there are inconsistencies and subtle
problems. Rather than removing them, we decided to leave the contents
untouched, and use these issues as data cleaning exercises.

## Prerequisites

You need a MySQL database server (5.0+) and run the commands below through a 
user that has the following privileges:

    SELECT, INSERT, UPDATE, DELETE, 
    CREATE, DROP, RELOAD, REFERENCES, 
    INDEX, ALTER, SHOW DATABASES, 
    CREATE TEMPORARY TABLES, 
    LOCK TABLES, EXECUTE, CREATE VIEW

## Installation:

1. Download the repository
2. Change directory to the repository

> [!IMPORTANT]
> If you are using MySQL client >= 9.x, the new default value of the [`--commands`](https://dev.mysql.com/doc/refman/9.6/en/mysql-command-options.html#option_mysql_commands) parameter is set to `FALSE`. Therefore, the `SOURCE` command won't work. You need to happen `--commands` to each `mysql` command line call.

Then run

    mysql < employees.sql


If you want to install with two large partitioned tables, run

    mysql < employees_partitioned.sql


## Testing the installation

After installing, you can run one of the following integrity tests:

    mysql -t < test_employees_sha2.sql   # SHA-256 (works on all versions including 9.6+)
    mysql -t < test_employees_md5.sql    # MD5 (MySQL 8.0–9.5 only)
    mysql -t < test_employees_sha.sql    # SHA-1 (MySQL 8.0–9.5 only)

For example:

    mysql  -t < test_employees_md5.sql
    +----------------------+
    | INFO                 |
    +----------------------+
    | TESTING INSTALLATION |
    +----------------------+
    +--------------+------------------+----------------------------------+
    | table_name   | expected_records | expected_crc                     |
    +--------------+------------------+----------------------------------+
    | employees    |           300024 | 4ec56ab5ba37218d187cf6ab09ce1aa1 |
    | departments  |                9 | d1af5e170d2d1591d776d5638d71fc5f |
    | dept_manager |               24 | 8720e2f0853ac9096b689c14664f847e |
    | dept_emp     |           331603 | ccf6fe516f990bdaa49713fc478701b7 |
    | titles       |           443308 | bfa016c472df68e70a03facafa1bc0a8 |
    | salaries     |          2844047 | fd220654e95aea1b169624ffe3fca934 |
    +--------------+------------------+----------------------------------+
    +--------------+------------------+----------------------------------+
    | table_name   | found_records    | found_crc                        |
    +--------------+------------------+----------------------------------+
    | employees    |           300024 | 4ec56ab5ba37218d187cf6ab09ce1aa1 |
    | departments  |                9 | d1af5e170d2d1591d776d5638d71fc5f |
    | dept_manager |               24 | 8720e2f0853ac9096b689c14664f847e |
    | dept_emp     |           331603 | ccf6fe516f990bdaa49713fc478701b7 |
    | titles       |           443308 | bfa016c472df68e70a03facafa1bc0a8 |
    | salaries     |          2844047 | fd220654e95aea1b169624ffe3fca934 |
    +--------------+------------------+----------------------------------+
    +--------------+---------------+-----------+
    | table_name   | records_match | crc_match |
    +--------------+---------------+-----------+
    | employees    | OK            | ok        |
    | departments  | OK            | ok        |
    | dept_manager | OK            | ok        |
    | dept_emp     | OK            | ok        |
    | titles       | OK            | ok        |
    | salaries     | OK            | ok        |
    +--------------+---------------+-----------+


## PostgreSQL Installation

The database is also available for PostgreSQL 12+. The schema and data are identical
to the MySQL version. All files are in the `postgresql/` directory.

### Differences from the MySQL version

- **ENUM type**: MySQL `ENUM('M','F')` is replaced with `CHAR(1) CHECK (gender IN ('M','F'))`
- **Stored procedures**: MySQL's `delimiter //` syntax is replaced with PostgreSQL dollar-quoting (`$...$ LANGUAGE plpgsql`)
- **`show_departments()`**: Implemented as a function returning TABLE (use `SELECT * FROM show_departments();` instead of `CALL show_departments();`)
- **User variables**: MySQL's `@var := value` pattern is replaced with PL/pgSQL local variables
- **Integrity tests**: Use the same incremental hashing approach but via PL/pgSQL helper functions instead of MySQL user variables

### Data integrity across databases

The SHA-256 checksums are **identical** between MySQL and PostgreSQL. This is verified in CI:
the same expected values in `test_employees_sha2.sql` and `postgresql/test_employees_sha2.sql`
produce matching results on both databases. The MySQL version uses `SHA2(..., 256)` while
PostgreSQL uses `encode(digest(..., 'sha256'), 'hex')` from the `pgcrypto` extension.

### Installation

1. Download the repository
2. Install PostgreSQL (12+)
3. Run the loading script:

        cd postgresql
        bash load_employees_db.sh

   To use a custom psql command (e.g., from a dbdeployer sandbox):

        PSQL=/path/to/psql bash load_employees_db.sh

### Testing the PostgreSQL installation

        psql -d employees < postgresql/test_employees_sha2.sql   # SHA-256 (recommended)
        psql -d employees < postgresql/test_employees_md5.sql    # MD5
        psql -d employees < postgresql/test_employees_sha.sql    # SHA-1 (requires pgcrypto)

### Optional: load stored procedures and functions

        psql -d employees < postgresql/objects.sql

Available functions: `emp_name()`, `emp_dept_name()`, `emp_dept_id()`, `current_manager()`,
`show_departments()` (use `SELECT * FROM show_departments();`), `employees_help()`.


## DISCLAIMER

To the best of my knowledge, this data is fabricated and
it does not correspond to real people. 
Any similarity to existing people is purely coincidental.


## LICENSE
This work is licensed under the 
Creative Commons Attribution-Share Alike 3.0 Unported License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
Creative Commons, 171 Second Street, Suite 300, San Francisco, 
California, 94105, USA.

## Common Errors

Error: Access denied for user 'root'
Solution: Make sure you are using the correct password and host.
