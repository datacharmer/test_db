2.3.1 / 2018-02-24
==================

  * Fix incorrectly replacing non-placeholders in SQL

2.3.0 / 2017-10-01
==================

  * Add `.toSqlString()` escape overriding
  * Add `raw` method to wrap raw strings for escape overriding
  * Small performance improvement on `escapeId`

2.2.0 / 2016-11-01
==================

  * Escape invalid `Date` objects as `NULL`

2.1.0 / 2016-09-26
==================

  * Accept numbers and other value types in `escapeId`
  * Run `buffer.toString()` through escaping

2.0.1 / 2016-06-06
==================

  * Fix npm package to include missing `lib/` directory

2.0.0 / 2016-06-06
==================

  * Bring repository up-to-date with `mysql` module changes
  * Support Node.js 0.6.x

1.0.0 / 2014-11-09
==================

  * Support Node.js 0.8.x

0.0.1 / 2014-02-25
==================

  * Initial release
