# sqlstring

[![NPM Version][npm-version-image]][npm-url]
[![NPM Downloads][npm-downloads-image]][npm-url]
[![Node.js Version][node-image]][node-url]
[![Build Status][travis-image]][travis-url]
[![Coverage Status][coveralls-image]][coveralls-url]

Simple SQL escape and format for MySQL

## Install

```sh
$ npm install sqlstring
```

## Usage

<!-- eslint-disable no-unused-vars -->

```js
var SqlString = require('sqlstring');
```

### Escaping query values

**Caution** These methods of escaping values only works when the
[NO_BACKSLASH_ESCAPES](https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_no_backslash_escapes)
SQL mode is disabled (which is the default state for MySQL servers).

In order to avoid SQL Injection attacks, you should always escape any user
provided data before using it inside a SQL query. You can do so using the
`SqlString.escape()` method:

```js
var userId = 'some user provided value';
var sql    = 'SELECT * FROM users WHERE id = ' + SqlString.escape(userId);
console.log(sql); // SELECT * FROM users WHERE id = 'some user provided value'
```

Alternatively, you can use `?` characters as placeholders for values you would
like to have escaped like this:

```js
var userId = 1;
var sql    = SqlString.format('SELECT * FROM users WHERE id = ?', [userId]);
console.log(sql); // SELECT * FROM users WHERE id = 1
```

Multiple placeholders are mapped to values in the same order as passed. For example,
in the following query `foo` equals `a`, `bar` equals `b`, `baz` equals `c`, and
`id` will be `userId`:

```js
var userId = 1;
var sql    = SqlString.format('UPDATE users SET foo = ?, bar = ?, baz = ? WHERE id = ?',
  ['a', 'b', 'c', userId]);
console.log(sql); // UPDATE users SET foo = 'a', bar = 'b', baz = 'c' WHERE id = 1
```

This looks similar to prepared statements in MySQL, however it really just uses
the same `SqlString.escape()` method internally.

**Caution** This also differs from prepared statements in that all `?` are
replaced, even those contained in comments and strings.

Different value types are escaped differently, here is how:

* Numbers are left untouched
* Booleans are converted to `true` / `false`
* Date objects are converted to `'YYYY-mm-dd HH:ii:ss'` strings
* Buffers are converted to hex strings, e.g. `X'0fa5'`
* Strings are safely escaped
* Arrays are turned into list, e.g. `['a', 'b']` turns into `'a', 'b'`
* Nested arrays are turned into grouped lists (for bulk inserts), e.g. `[['a',
  'b'], ['c', 'd']]` turns into `('a', 'b'), ('c', 'd')`
* Objects that have a `toSqlString` method will have `.toSqlString()` called
  and the returned value is used as the raw SQL.
* Objects are turned into `key = 'val'` pairs for each enumerable property on
  the object. If the property's value is a function, it is skipped; if the
  property's value is an object, toString() is called on it and the returned
  value is used.
* `undefined` / `null` are converted to `NULL`
* `NaN` / `Infinity` are left as-is. MySQL does not support these, and trying
  to insert them as values will trigger MySQL errors until they implement
  support.

You may have noticed that this escaping allows you to do neat things like this:

```js
var post  = {id: 1, title: 'Hello MySQL'};
var sql = SqlString.format('INSERT INTO posts SET ?', post);
console.log(sql); // INSERT INTO posts SET `id` = 1, `title` = 'Hello MySQL'
```

And the `toSqlString` method allows you to form complex queries with functions:

```js
var CURRENT_TIMESTAMP = { toSqlString: function() { return 'CURRENT_TIMESTAMP()'; } };
var sql = SqlString.format('UPDATE posts SET modified = ? WHERE id = ?', [CURRENT_TIMESTAMP, 42]);
console.log(sql); // UPDATE posts SET modified = CURRENT_TIMESTAMP() WHERE id = 42
```

To generate objects with a `toSqlString` method, the `SqlString.raw()` method can
be used. This creates an object that will be left un-touched when using in a `?`
placeholder, useful for using functions as dynamic values:

**Caution** The string provided to `SqlString.raw()` will skip all escaping
functions when used, so be careful when passing in unvalidated input.

```js
var CURRENT_TIMESTAMP = SqlString.raw('CURRENT_TIMESTAMP()');
var sql = SqlString.format('UPDATE posts SET modified = ? WHERE id = ?', [CURRENT_TIMESTAMP, 42]);
console.log(sql); // UPDATE posts SET modified = CURRENT_TIMESTAMP() WHERE id = 42
```

If you feel the need to escape queries by yourself, you can also use the escaping
function directly:

```js
var sql = 'SELECT * FROM posts WHERE title=' + SqlString.escape('Hello MySQL');
console.log(sql); // SELECT * FROM posts WHERE title='Hello MySQL'
```

### Escaping query identifiers

If you can't trust an SQL identifier (database / table / column name) because it is
provided by a user, you should escape it with `SqlString.escapeId(identifier)` like this:

```js
var sorter = 'date';
var sql    = 'SELECT * FROM posts ORDER BY ' + SqlString.escapeId(sorter);
console.log(sql); // SELECT * FROM posts ORDER BY `date`
```

It also supports adding qualified identifiers. It will escape both parts.

```js
var sorter = 'date';
var sql    = 'SELECT * FROM posts ORDER BY ' + SqlString.escapeId('posts.' + sorter);
console.log(sql); // SELECT * FROM posts ORDER BY `posts`.`date`
```

If you do not want to treat `.` as qualified identifiers, you can set the second
argument to `true` in order to keep the string as a literal identifier:

```js
var sorter = 'date.2';
var sql    = 'SELECT * FROM posts ORDER BY ' + SqlString.escapeId(sorter, true);
console.log(sql); // SELECT * FROM posts ORDER BY `date.2`
```

Alternatively, you can use `??` characters as placeholders for identifiers you would
like to have escaped like this:

```js
var userId = 1;
var columns = ['username', 'email'];
var sql     = SqlString.format('SELECT ?? FROM ?? WHERE id = ?', [columns, 'users', userId]);
console.log(sql); // SELECT `username`, `email` FROM `users` WHERE id = 1
```
**Please note that this last character sequence is experimental and syntax might change**

When you pass an Object to `.escape()` or `.format()`, `.escapeId()` is used to avoid SQL injection in object keys.

### Formatting queries

You can use `SqlString.format` to prepare a query with multiple insertion points,
utilizing the proper escaping for ids and values. A simple example of this follows:

```js
var userId  = 1;
var inserts = ['users', 'id', userId];
var sql     = SqlString.format('SELECT * FROM ?? WHERE ?? = ?', inserts);
console.log(sql); // SELECT * FROM `users` WHERE `id` = 1
```

Following this you then have a valid, escaped query that you can then send to the database safely.
This is useful if you are looking to prepare the query before actually sending it to the database.
You also have the option (but are not required) to pass in `stringifyObject` and `timeZone`,
allowing you provide a custom means of turning objects into strings, as well as a
location-specific/timezone-aware `Date`.

This can be further combined with the `SqlString.raw()` helper to generate SQL
that includes MySQL functions as dynamic vales:

```js
var userId = 1;
var data   = { email: 'foobar@example.com', modified: SqlString.raw('NOW()') };
var sql    = SqlString.format('UPDATE ?? SET ? WHERE `id` = ?', ['users', data, userId]);
console.log(sql); // UPDATE `users` SET `email` = 'foobar@example.com', `modified` = NOW() WHERE `id` = 1
```

## License

[MIT](LICENSE)

[npm-version-image]: https://img.shields.io/npm/v/sqlstring.svg
[npm-downloads-image]: https://img.shields.io/npm/dm/sqlstring.svg
[npm-url]: https://npmjs.org/package/sqlstring
[travis-image]: https://img.shields.io/travis/mysqljs/sqlstring/master.svg
[travis-url]: https://travis-ci.org/mysqljs/sqlstring
[coveralls-image]: https://img.shields.io/coveralls/mysqljs/sqlstring/master.svg
[coveralls-url]: https://coveralls.io/r/mysqljs/sqlstring?branch=master
[node-image]: https://img.shields.io/node/v/sqlstring.svg
[node-url]: https://nodejs.org/en/download
