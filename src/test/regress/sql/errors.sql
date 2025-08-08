---START---
--
-- ERRORS
--

-- bad in postquel, but ok in PostgreSQL
select 1;
---END---
---START---
--
-- UNSUPPORTED STUFF

-- doesn't work
-- notify pg_class
--

--
-- SELECT

-- this used to be a syntax error, but now we allow an empty target list
select;
---END---
---START---
-- no such relation
select * from nonesuch;
---END---
---START---
-- bad name in target list
select nonesuch from pg_database;
---END---
---START---
-- empty distinct list isn't OK
select distinct from pg_database;
---END---
---START---
-- bad attribute name on lhs of operator
select * from pg_database where nonesuch = pg_database.datname;
---END---
---START---
-- bad attribute name on rhs of operator
select * from pg_database where pg_database.datname = nonesuch;
---END---
---START---
-- bad attribute name in select distinct on
select distinct on (foobar) * from pg_database;
---END---
---START---
-- grouping with FOR UPDATE
select null from pg_database group by datname for update;
---END---
---START---
select null from pg_database group by grouping sets (()) for update;
---END---
---START---
--
-- DELETE

-- missing relation name (this had better not wildcard!)
delete from;
---END---
---START---
-- no such relation
delete from nonesuch;
---END---
---START---
--
-- DROP

-- missing relation name (this had better not wildcard!)
drop table;
---END---
---START---
-- no such relation
drop table nonesuch;
---END---
---START---
--
-- ALTER TABLE

-- relation renaming

-- missing relation name
alter table rename;
---END---
---START---
-- no such relation
alter table nonesuch rename to newnonesuch;
---END---
---START---
-- no such relation
alter table nonesuch rename to stud_emp;
---END---
---START---
-- conflict
alter table stud_emp rename to student;
---END---
---START---
-- self-conflict
alter table stud_emp rename to stud_emp;
---END---
---START---
-- attribute renaming

-- no such relation
alter table nonesuchrel rename column nonesuchatt to newnonesuchatt;
---END---
---START---
-- no such attribute
alter table emp rename column nonesuchatt to newnonesuchatt;
---END---
---START---
-- conflict
alter table emp rename column salary to manager;
---END---
---START---
-- conflict
alter table emp rename column salary to ctid;
---END---
---START---
--
-- TRANSACTION STUFF

-- not in a xact
abort;
---END---
---START---
-- not in a xact
end;
---END---
---START---
--
-- CREATE AGGREGATE

-- sfunc/finalfunc type disagreement
create aggregate newavg2 (sfunc = int4pl,
			  basetype = int4,
			  stype = int4,
			  finalfunc = int2um,
			  initcond = '0');
---END---
---START---
-- left out basetype
create aggregate newcnt1 (sfunc = int4inc,
			  stype = int4,
			  initcond = '0');
---END---
---START---
--
-- DROP INDEX

-- missing index name
drop index;
---END---
---START---
-- bad index name
drop index 314159;
---END---
---START---
-- no such index
drop index nonesuch;
---END---
---START---
--
-- DROP AGGREGATE

-- missing aggregate name
drop aggregate;
---END---
---START---
-- missing aggregate type
drop aggregate newcnt1;
---END---
---START---
-- bad aggregate name
drop aggregate 314159 (int);
---END---
---START---
-- bad aggregate type
drop aggregate newcnt (nonesuch);
---END---
---START---
-- no such aggregate
drop aggregate nonesuch (int4);
---END---
---START---
-- no such aggregate for type
drop aggregate newcnt (float4);
---END---
---START---
--
-- DROP FUNCTION

-- missing function name
drop function ();
---END---
---START---
-- bad function name
drop function 314159();
---END---
---START---
-- no such function
drop function nonesuch();
---END---
---START---
--
-- DROP TYPE

-- missing type name
drop type;
---END---
---START---
-- bad type name
drop type 314159;
---END---
---START---
-- no such type
drop type nonesuch;
---END---
---START---
--
-- DROP OPERATOR

-- missing everything
drop operator;
---END---
---START---
-- bad operator name
drop operator equals;
---END---
---START---
-- missing type list
drop operator ===;
---END---
---START---
-- missing parentheses
drop operator int4, int4;
---END---
---START---
-- missing operator name
drop operator (int4, int4);
---END---
---START---
-- missing type list contents
drop operator === ();
---END---
---START---
-- no such operator
drop operator === (int4);
---END---
---START---
-- no such operator by that name
drop operator === (int4, int4);
---END---
---START---
-- no such type1
drop operator = (nonesuch);
---END---
---START---
-- no such type1
drop operator = ( , int4);
---END---
---START---
-- no such type1
drop operator = (nonesuch, int4);
---END---
---START---
-- no such type2
drop operator = (int4, nonesuch);
---END---
---START---
-- no such type2
drop operator = (int4, );
---END---
---START---
--
-- DROP RULE

-- missing rule name
drop rule;
---END---
---START---
-- bad rule name
drop rule 314159;
---END---
---START---
-- no such rule
drop rule nonesuch on noplace;
---END---
---START---
-- these postquel variants are no longer supported
drop tuple rule nonesuch;
---END---
---START---
drop instance rule nonesuch on noplace;
---END---
---START---
drop rewrite rule nonesuch;
---END---
---START---
--
-- Check that division-by-zero is properly caught.
--

select 1/0;
---END---
---START---
select 1::int8/0;
---END---
---START---
select 1/0::int8;
---END---
---START---
select 1::int2/0;
---END---
---START---
select 1/0::int2;
---END---
---START---
select 1::numeric/0;
---END---
---START---
select 1/0::numeric;
---END---
---START---
select 1::float8/0;
---END---
---START---
select 1/0::float8;
---END---
---START---
select 1::float4/0;
---END---
---START---
select 1/0::float4;
---END---
---START---
CREATE foo;
---END---
---START---
CREATE TABLE;
---END---
---START---
CREATE TABLE
\g

INSERT INTO foo VALUES(123) foo;
---END---
---START---
INSERT INTO 123
VALUES(123);
---END---
---START---
INSERT INTO foo
VALUES(123) 123;
---END---
---START---
-- with a tab
CREATE TABLE foo
  (id INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY,
	id3 INTEGER NOT NUL,
   id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL);
---END---
---START---
-- long line to be truncated on the left
CREATE TABLE foo(id INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY, id3 INTEGER NOT NUL,
id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL);
---END---
---START---
-- long line to be truncated on the right
CREATE TABLE foo(
id3 INTEGER NOT NUL, id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL, id INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY);
---END---
---START---
-- long line to be truncated both ways
CREATE TABLE foo(id INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY, id3 INTEGER NOT NUL, id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL);
---END---
---START---
-- long line to be truncated on the left, many lines
DROP TABLE IF EXISTS foo;
CREATE
TABLE
foo(id INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY, id3 INTEGER NOT NUL,
id4 INT4
UNIQUE
NOT
NULL,
id5 TEXT
UNIQUE
NOT
NULL);
---END---
---START---
-- long line to be truncated on the right, many lines
DROP TABLE IF EXISTS foo;
CREATE
TABLE
foo(
id3 INTEGER NOT NUL, id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL, id INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY);
---END---
---START---
-- long line to be truncated both ways, many lines
DROP TABLE IF EXISTS foo;
CREATE
TABLE
foo
(id
INT4
UNIQUE NOT NULL, idx INT4 UNIQUE NOT NULL, idy INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY, id3 INTEGER NOT NUL, id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL,
idz INT4 UNIQUE NOT NULL,
idv INT4 UNIQUE NOT NULL);
---END---
---START---
-- more than 10 lines...
DROP TABLE IF EXISTS foo;
CREATE
TABLE
foo
(id
INT4
UNIQUE
NOT
NULL
,
idm
INT4
UNIQUE
NOT
NULL,
idx INT4 UNIQUE NOT NULL, idy INT4 UNIQUE NOT NULL, id2 TEXT NOT NULL PRIMARY KEY, id3 INTEGER NOT NUL, id4 INT4 UNIQUE NOT NULL, id5 TEXT UNIQUE NOT NULL,
idz INT4 UNIQUE NOT NULL,
idv
INT4
UNIQUE
NOT
NULL);
---END---
