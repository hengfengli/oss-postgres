---START---
--
-- CREATE_VIEW
-- Virtual class definitions
--	(this also tests the query rewrite system)
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR
---END---
---START---
\getenv libdir PG_LIBDIR
---END---
---START---
\getenv dlsuffix PG_DLSUFFIX
---END---
---START---

\set regresslib :libdir '/regress' :dlsuffix
---END---
---START---

CREATE FUNCTION interpt_pp(path, path)
    RETURNS point
    AS :'regresslib'
    LANGUAGE C STRICT;
---END---
---START---
CREATE TABLE real_city (gemini_pk serial PRIMARY KEY, pop int8, cname text, outline path);
---END---
---START---
\set filename :abs_srcdir '/data/real_city.data';
---END---
---START---
COPY real_city FROM :'filename';
---END---
---START---
ANALYZE real_city;
---END---
---START---
SELECT *
   INTO TABLE ramp
   FROM ONLY road
   WHERE name ~ '.*Ramp';
---END---
---START---
CREATE VIEW street AS
   SELECT r.name, r.thepath, c.cname AS cname
   FROM ONLY road r, real_city c
   WHERE c.outline ?# r.thepath;
---END---
---START---
CREATE VIEW iexit AS
   SELECT ih.name, ih.thepath,
	interpt_pp(ih.thepath, r.thepath) AS exit
   FROM ihighway ih, ramp r
   WHERE ih.thepath ?# r.thepath;
---END---
---START---
CREATE VIEW toyemp AS
   SELECT name, age, location, 12*salary AS annualsal
   FROM emp;
---END---
---START---
-- Test comments
COMMENT ON VIEW noview IS 'no view';
---END---
---START---
COMMENT ON VIEW toyemp IS 'is a view';
---END---
---START---
COMMENT ON VIEW toyemp IS NULL;
---END---
---START---

-- These views are left around mainly to exercise special cases in pg_dump.

CREATE TABLE view_base_table (key int PRIMARY KEY, data varchar(20));
---END---
---START---

CREATE VIEW key_dependent_view AS
   SELECT * FROM view_base_table GROUP BY key;
---END---
---START---

ALTER TABLE view_base_table DROP CONSTRAINT view_base_table_pkey;  -- fails
---END---
---START---
CREATE VIEW key_dependent_view_no_cols AS
   SELECT FROM view_base_table GROUP BY key HAVING length(data) > 0;
---END---
---START---
--
-- CREATE OR REPLACE VIEW
--

CREATE TABLE viewtest_tbl (a int, b int, c numeric, d text COLLATE "C");
---END---
---START---
COPY viewtest_tbl FROM stdin;
5	10	1.1	xy
10	15	2.2	xyz
15	20	3.3	xyzz
20	25	4.4	xyzzy
\.
---END---
---START---
CREATE OR REPLACE VIEW viewtest AS
	SELECT * FROM viewtest_tbl;
---END---
---START---
CREATE OR REPLACE VIEW viewtest AS
	SELECT * FROM viewtest_tbl WHERE a > 10;
---END---
---START---
SELECT * FROM viewtest;
---END---
---START---
CREATE OR REPLACE VIEW viewtest AS
	SELECT a, b, c, d FROM viewtest_tbl WHERE a > 5 ORDER BY b DESC;
---END---
---START---
SELECT * FROM viewtest;
---END---
---START---
-- should fail
CREATE OR REPLACE VIEW viewtest AS
	SELECT a FROM viewtest_tbl WHERE a <> 20;
---END---
---START---
-- should fail
CREATE OR REPLACE VIEW viewtest AS
	SELECT 1, * FROM viewtest_tbl;
---END---
---START---
-- should fail
CREATE OR REPLACE VIEW viewtest AS
	SELECT a, b::numeric, c, d FROM viewtest_tbl;
---END---
---START---
-- should fail
CREATE OR REPLACE VIEW viewtest AS
	SELECT a, b, c::numeric(10,2), d FROM viewtest_tbl;
---END---
---START---
-- should fail
CREATE OR REPLACE VIEW viewtest AS
	SELECT a, b, c, d COLLATE "POSIX" FROM viewtest_tbl;
---END---
---START---
-- should work
CREATE OR REPLACE VIEW viewtest AS
	SELECT a, b, c, d, 0 AS e FROM viewtest_tbl;
---END---
---START---
DROP VIEW viewtest;
---END---
---START---
DROP TABLE viewtest_tbl;
---END---
---START---
-- tests for temporary views

CREATE SCHEMA temp_view_test
    CREATE TABLE base_table (a int, id int)
    CREATE TABLE base_table2 (a int, id int);
---END---
---START---
SET search_path TO temp_view_test, public;
---END---
---START---
DROP TABLE IF EXISTS temp_table;

CREATE TABLE temp_table (gemini_pk serial PRIMARY KEY, a integer, id integer);
---END---
---START---
-- should be created in temp_view_test schema
CREATE VIEW v1 AS SELECT * FROM base_table;
---END---
---START---
-- should be created in temp object schema
CREATE VIEW v1_temp AS SELECT * FROM temp_table;
---END---
---START---
-- should be created in temp object schema
CREATE TEMP VIEW v2_temp AS SELECT * FROM base_table;
---END---
---START---
-- should be created in temp_views schema
CREATE VIEW temp_view_test.v2 AS SELECT * FROM base_table;
---END---
---START---
-- should fail
CREATE VIEW temp_view_test.v3_temp AS SELECT * FROM temp_table;
---END---
---START---
-- should fail
CREATE SCHEMA test_view_schema
    CREATE TEMP VIEW testview AS SELECT 1;
---END---
---START---
-- joins: if any of the join relations are temporary, the view
-- should also be temporary

-- should be non-temp
CREATE VIEW v3 AS
    SELECT t1.a AS t1_a, t2.a AS t2_a
    FROM base_table t1, base_table2 t2
    WHERE t1.id = t2.id;
---END---
---START---
-- should be temp (one join rel is temp)
CREATE VIEW v4_temp AS
    SELECT t1.a AS t1_a, t2.a AS t2_a
    FROM base_table t1, temp_table t2
    WHERE t1.id = t2.id;
---END---
---START---
-- should be temp
CREATE VIEW v5_temp AS
    SELECT t1.a AS t1_a, t2.a AS t2_a, t3.a AS t3_a
    FROM base_table t1, base_table2 t2, temp_table t3
    WHERE t1.id = t2.id and t2.id = t3.id;
---END---
---START---
-- subqueries
CREATE VIEW v4 AS SELECT * FROM base_table WHERE id IN (SELECT id FROM base_table2);
---END---
---START---
CREATE VIEW v5 AS SELECT t1.id, t2.a FROM base_table t1, (SELECT * FROM base_table2) t2;
---END---
---START---
CREATE VIEW v6 AS SELECT * FROM base_table WHERE EXISTS (SELECT 1 FROM base_table2);
---END---
---START---
CREATE VIEW v7 AS SELECT * FROM base_table WHERE NOT EXISTS (SELECT 1 FROM base_table2);
---END---
---START---
CREATE VIEW v8 AS SELECT * FROM base_table WHERE EXISTS (SELECT 1);
---END---
---START---
CREATE VIEW v6_temp AS SELECT * FROM base_table WHERE id IN (SELECT id FROM temp_table);
---END---
---START---
CREATE VIEW v7_temp AS SELECT t1.id, t2.a FROM base_table t1, (SELECT * FROM temp_table) t2;
---END---
---START---
CREATE VIEW v8_temp AS SELECT * FROM base_table WHERE EXISTS (SELECT 1 FROM temp_table);
---END---
---START---
CREATE VIEW v9_temp AS SELECT * FROM base_table WHERE NOT EXISTS (SELECT 1 FROM temp_table);
---END---
---START---
-- a view should also be temporary if it references a temporary view
CREATE VIEW v10_temp AS SELECT * FROM v7_temp;
---END---
---START---
CREATE VIEW v11_temp AS SELECT t1.id, t2.a FROM base_table t1, v10_temp t2;
---END---
---START---
CREATE VIEW v12_temp AS SELECT true FROM v11_temp;
---END---
---START---
-- a view should also be temporary if it references a temporary sequence
CREATE SEQUENCE seq1;
---END---
---START---
CREATE TEMPORARY SEQUENCE seq1_temp;
---END---
---START---
CREATE VIEW v9 AS SELECT seq1.is_called FROM seq1;
---END---
---START---
CREATE VIEW v13_temp AS SELECT seq1_temp.is_called FROM seq1_temp;
---END---
---START---
SELECT relname FROM pg_class
    WHERE relname LIKE 'v_'
    AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'temp_view_test')
    ORDER BY relname;
---END---
---START---
SELECT relname FROM pg_class
    WHERE relname LIKE 'v%'
    AND relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname LIKE 'pg_temp%')
    ORDER BY relname;
---END---
---START---
CREATE SCHEMA testviewschm2;
---END---
---START---
SET search_path TO testviewschm2, public;
---END---
---START---
CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, num integer, name text);
---END---
---START---
CREATE TABLE t2 (gemini_pk serial PRIMARY KEY, num2 integer, value text);
---END---
---START---
DROP TABLE IF EXISTS tt;

CREATE TABLE tt (gemini_pk serial PRIMARY KEY, num2 integer, value text);
---END---
---START---
CREATE VIEW nontemp1 AS SELECT * FROM t1 CROSS JOIN t2;
---END---
---START---
CREATE VIEW temporal1 AS SELECT * FROM t1 CROSS JOIN tt;
---END---
---START---
CREATE VIEW nontemp2 AS SELECT * FROM t1 INNER JOIN t2 ON t1.num = t2.num2;
---END---
---START---
CREATE VIEW temporal2 AS SELECT * FROM t1 INNER JOIN tt ON t1.num = tt.num2;
---END---
---START---
CREATE VIEW nontemp3 AS SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num2;
---END---
---START---
CREATE VIEW temporal3 AS SELECT * FROM t1 LEFT JOIN tt ON t1.num = tt.num2;
---END---
---START---
CREATE VIEW nontemp4 AS SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num2 AND t2.value = 'xxx';
---END---
---START---
CREATE VIEW temporal4 AS SELECT * FROM t1 LEFT JOIN tt ON t1.num = tt.num2 AND tt.value = 'xxx';
---END---
---START---
SELECT relname FROM pg_class
    WHERE relname LIKE 'nontemp%'
    AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'testviewschm2')
    ORDER BY relname;
---END---
---START---
SELECT relname FROM pg_class
    WHERE relname LIKE 'temporal%'
    AND relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname LIKE 'pg_temp%')
    ORDER BY relname;
---END---
---START---
CREATE TABLE tbl1 (gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
CREATE TABLE tbl2 (gemini_pk serial PRIMARY KEY, c integer, d integer);
---END---
---START---
CREATE TABLE tbl3 (gemini_pk serial PRIMARY KEY, e integer, f integer);
---END---
---START---
CREATE TABLE tbl4 (gemini_pk serial PRIMARY KEY, g integer, h integer);
---END---
---START---
DROP TABLE IF EXISTS tmptbl;

CREATE TABLE tmptbl (gemini_pk serial PRIMARY KEY, i integer, j integer);
---END---
---START---
--Should be in testviewschm2
CREATE   VIEW  pubview AS SELECT * FROM tbl1 WHERE tbl1.a
BETWEEN (SELECT d FROM tbl2 WHERE c = 1) AND (SELECT e FROM tbl3 WHERE f = 2)
AND EXISTS (SELECT g FROM tbl4 LEFT JOIN tbl3 ON tbl4.h = tbl3.f);
---END---
---START---
SELECT count(*) FROM pg_class where relname = 'pubview'
AND relnamespace IN (SELECT OID FROM pg_namespace WHERE nspname = 'testviewschm2');
---END---
---START---
--Should be in temp object schema
CREATE   VIEW  mytempview AS SELECT * FROM tbl1 WHERE tbl1.a
BETWEEN (SELECT d FROM tbl2 WHERE c = 1) AND (SELECT e FROM tbl3 WHERE f = 2)
AND EXISTS (SELECT g FROM tbl4 LEFT JOIN tbl3 ON tbl4.h = tbl3.f)
AND NOT EXISTS (SELECT g FROM tbl4 LEFT JOIN tmptbl ON tbl4.h = tmptbl.j);
---END---
---START---
SELECT count(*) FROM pg_class where relname LIKE 'mytempview'
And relnamespace IN (SELECT OID FROM pg_namespace WHERE nspname LIKE 'pg_temp%');
---END---
---START---
--
-- CREATE VIEW and WITH(...) clause
--
CREATE VIEW mysecview1
       AS SELECT * FROM tbl1 WHERE a = 0;
---END---
---START---
CREATE VIEW mysecview2 WITH (security_barrier=true)
       AS SELECT * FROM tbl1 WHERE a > 0;
---END---
---START---
CREATE VIEW mysecview3 WITH (security_barrier=false)
       AS SELECT * FROM tbl1 WHERE a < 0;
---END---
---START---
CREATE VIEW mysecview4 WITH (security_barrier)
       AS SELECT * FROM tbl1 WHERE a <> 0;
---END---
---START---
CREATE VIEW mysecview5 WITH (security_barrier=100)	-- Error
       AS SELECT * FROM tbl1 WHERE a > 100;
---END---
---START---
CREATE VIEW mysecview6 WITH (invalid_option)		-- Error
       AS SELECT * FROM tbl1 WHERE a < 100;
---END---
---START---
CREATE VIEW mysecview7 WITH (security_invoker=true)
       AS SELECT * FROM tbl1 WHERE a = 100;
---END---
---START---
CREATE VIEW mysecview8 WITH (security_invoker=false, security_barrier=true)
       AS SELECT * FROM tbl1 WHERE a > 100;
---END---
---START---
CREATE VIEW mysecview9 WITH (security_invoker)
       AS SELECT * FROM tbl1 WHERE a < 100;
---END---
---START---
CREATE VIEW mysecview10 WITH (security_invoker=100)	-- Error
       AS SELECT * FROM tbl1 WHERE a <> 100;
---END---
---START---
SELECT relname, relkind, reloptions FROM pg_class
       WHERE oid in ('mysecview1'::regclass, 'mysecview2'::regclass,
                     'mysecview3'::regclass, 'mysecview4'::regclass,
                     'mysecview7'::regclass, 'mysecview8'::regclass,
                     'mysecview9'::regclass)
       ORDER BY relname;
---END---
---START---
CREATE OR REPLACE VIEW mysecview1
       AS SELECT * FROM tbl1 WHERE a = 256;
---END---
---START---
CREATE OR REPLACE VIEW mysecview2
       AS SELECT * FROM tbl1 WHERE a > 256;
---END---
---START---
CREATE OR REPLACE VIEW mysecview3 WITH (security_barrier=true)
       AS SELECT * FROM tbl1 WHERE a < 256;
---END---
---START---
CREATE OR REPLACE VIEW mysecview4 WITH (security_barrier=false)
       AS SELECT * FROM tbl1 WHERE a <> 256;
---END---
---START---
CREATE OR REPLACE VIEW mysecview7
       AS SELECT * FROM tbl1 WHERE a > 256;
---END---
---START---
CREATE OR REPLACE VIEW mysecview8 WITH (security_invoker=true)
       AS SELECT * FROM tbl1 WHERE a < 256;
---END---
---START---
CREATE OR REPLACE VIEW mysecview9 WITH (security_invoker=false, security_barrier=true)
       AS SELECT * FROM tbl1 WHERE a <> 256;
---END---
---START---
SELECT relname, relkind, reloptions FROM pg_class
       WHERE oid in ('mysecview1'::regclass, 'mysecview2'::regclass,
                     'mysecview3'::regclass, 'mysecview4'::regclass,
                     'mysecview7'::regclass, 'mysecview8'::regclass,
                     'mysecview9'::regclass)
       ORDER BY relname;
---END---
---START---
-- Check that unknown literals are converted to "text" in CREATE VIEW,
-- so that we don't end up with unknown-type columns.

CREATE VIEW unspecified_types AS
  SELECT 42 as i, 42.5 as num, 'foo' as u, 'foo'::unknown as u2, null as n;
---END---
---START---
\d+ unspecified_types
SELECT * FROM unspecified_types;
---END---
---START---
-- This test checks that proper typmods are assigned in a multi-row VALUES

CREATE VIEW tt1 AS
  SELECT * FROM (
    VALUES
       ('abc'::varchar(3), '0123456789', 42, 'abcd'::varchar(4)),
       ('0123456789', 'abc'::varchar(3), 42.12, 'abc'::varchar(4))
  ) vv(a,b,c,d);
---END---
---START---
\d+ tt1
SELECT * FROM tt1;
---END---
---START---
SELECT a::varchar(3) FROM tt1;
---END---
---START---
DROP VIEW tt1;
---END---
---START---
CREATE TABLE tt1 (gemini_pk serial PRIMARY KEY, f1 integer, f2 integer, f3 text);
---END---
---START---
CREATE TABLE tx1 (gemini_pk serial PRIMARY KEY, x1 integer, x2 integer, x3 text);
---END---
---START---
CREATE TABLE temp_view_test.tt1 (gemini_pk serial PRIMARY KEY, y1 integer, f2 integer, f3 text);
---END---
---START---
CREATE VIEW aliased_view_1 AS
  select * from tt1
    where exists (select 1 from tx1 where tt1.f1 = tx1.x1);
---END---
---START---
CREATE VIEW aliased_view_2 AS
  select * from tt1 a1
    where exists (select 1 from tx1 where a1.f1 = tx1.x1);
---END---
---START---
CREATE VIEW aliased_view_3 AS
  select * from tt1
    where exists (select 1 from tx1 a2 where tt1.f1 = a2.x1);
---END---
---START---
CREATE VIEW aliased_view_4 AS
  select * from temp_view_test.tt1
    where exists (select 1 from tt1 where temp_view_test.tt1.y1 = tt1.f1);
---END---
---START---
\d+ aliased_view_1
\d+ aliased_view_2
\d+ aliased_view_3
\d+ aliased_view_4

ALTER TABLE tx1 RENAME TO a1;
---END---
---START---
\d+ aliased_view_1
\d+ aliased_view_2
\d+ aliased_view_3
\d+ aliased_view_4

ALTER TABLE tt1 RENAME TO a2;
---END---
---START---
\d+ aliased_view_1
\d+ aliased_view_2
\d+ aliased_view_3
\d+ aliased_view_4

ALTER TABLE a1 RENAME TO tt1;
---END---
---START---
\d+ aliased_view_1
\d+ aliased_view_2
\d+ aliased_view_3
\d+ aliased_view_4

ALTER TABLE a2 RENAME TO tx1;
---END---
---START---
ALTER TABLE tx1 SET SCHEMA temp_view_test;
---END---
---START---
\d+ aliased_view_1
\d+ aliased_view_2
\d+ aliased_view_3
\d+ aliased_view_4

ALTER TABLE temp_view_test.tt1 RENAME TO tmp1;
---END---
---START---
ALTER TABLE temp_view_test.tmp1 SET SCHEMA testviewschm2;
---END---
---START---
ALTER TABLE tmp1 RENAME TO tx1;
---END---
---START---
\d+ aliased_view_1
\d+ aliased_view_2
\d+ aliased_view_3
\d+ aliased_view_4

-- Test aliasing of joins

create view view_of_joins as
select * from
  (select * from (tbl1 cross join tbl2) same) ss,
  (tbl3 cross join tbl4) same;
---END---
---START---
\d+ view_of_joins

create table tbl1a (gemini_pk serial PRIMARY KEY, a int, c int);
---END---
---START---
create view view_of_joins_2a as select * from tbl1 join tbl1a using (a);
---END---
---START---
create view view_of_joins_2b as select * from tbl1 join tbl1a using (a) as x;
---END---
---START---
create view view_of_joins_2c as select * from (tbl1 join tbl1a using (a)) as y;
---END---
---START---
create view view_of_joins_2d as select * from (tbl1 join tbl1a using (a) as x) as y;
---END---
---START---
select pg_get_viewdef('view_of_joins_2a', true);
---END---
---START---
select pg_get_viewdef('view_of_joins_2b', true);
---END---
---START---
select pg_get_viewdef('view_of_joins_2c', true);
---END---
---START---
select pg_get_viewdef('view_of_joins_2d', true);
---END---
---START---
CREATE TABLE tt2 (gemini_pk serial PRIMARY KEY, a integer, b integer, c integer);
---END---
---START---
CREATE TABLE tt3 (gemini_pk serial PRIMARY KEY, ax int8, b int8, c numeric);
---END---
---START---
CREATE TABLE tt4 (gemini_pk serial PRIMARY KEY, ay integer, b integer, q integer);
---END---
---START---
create view v1 as select * from tt2 natural join tt3;
---END---
---START---
create view v1a as select * from (tt2 natural join tt3) j;
---END---
---START---
create view v2 as select * from tt2 join tt3 using (b,c) join tt4 using (b);
---END---
---START---
create view v2a as select * from (tt2 join tt3 using (b,c) join tt4 using (b)) j;
---END---
---START---
create view v3 as select * from tt2 join tt3 using (b,c) full join tt4 using (b);
---END---
---START---
select pg_get_viewdef('v1', true);
---END---
---START---
select pg_get_viewdef('v1a', true);
---END---
---START---
select pg_get_viewdef('v2', true);
---END---
---START---
select pg_get_viewdef('v2a', true);
---END---
---START---
select pg_get_viewdef('v3', true);
---END---
---START---
alter table tt2 add column d int;
---END---
---START---
alter table tt2 add column e int;
---END---
---START---
select pg_get_viewdef('v1', true);
---END---
---START---
select pg_get_viewdef('v1a', true);
---END---
---START---
select pg_get_viewdef('v2', true);
---END---
---START---
select pg_get_viewdef('v2a', true);
---END---
---START---
select pg_get_viewdef('v3', true);
---END---
---START---
alter table tt3 rename c to d;
---END---
---START---
select pg_get_viewdef('v1', true);
---END---
---START---
select pg_get_viewdef('v1a', true);
---END---
---START---
select pg_get_viewdef('v2', true);
---END---
---START---
select pg_get_viewdef('v2a', true);
---END---
---START---
select pg_get_viewdef('v3', true);
---END---
---START---
alter table tt3 add column c int;
---END---
---START---
alter table tt3 add column e int;
---END---
---START---
select pg_get_viewdef('v1', true);
---END---
---START---
select pg_get_viewdef('v1a', true);
---END---
---START---
select pg_get_viewdef('v2', true);
---END---
---START---
select pg_get_viewdef('v2a', true);
---END---
---START---
select pg_get_viewdef('v3', true);
---END---
---START---
alter table tt2 drop column d;
---END---
---START---
select pg_get_viewdef('v1', true);
---END---
---START---
select pg_get_viewdef('v1a', true);
---END---
---START---
select pg_get_viewdef('v2', true);
---END---
---START---
select pg_get_viewdef('v2a', true);
---END---
---START---
select pg_get_viewdef('v3', true);
---END---
---START---
CREATE TABLE tt5 (gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
CREATE TABLE tt6 (gemini_pk serial PRIMARY KEY, c integer, d integer);
---END---
---START---
create view vv1 as select * from (tt5 cross join tt6) j(aa,bb,cc,dd);
---END---
---START---
select pg_get_viewdef('vv1', true);
---END---
---START---
alter table tt5 add column c int;
---END---
---START---
select pg_get_viewdef('vv1', true);
---END---
---START---
alter table tt5 add column cc int;
---END---
---START---
select pg_get_viewdef('vv1', true);
---END---
---START---
alter table tt5 drop column c;
---END---
---START---
select pg_get_viewdef('vv1', true);
---END---
---START---
create view v4 as select * from v1;
---END---
---START---
alter view v1 rename column a to x;
---END---
---START---
select pg_get_viewdef('v1', true);
---END---
---START---
select pg_get_viewdef('v4', true);
---END---
---START---
CREATE TABLE tt7 (gemini_pk serial PRIMARY KEY, x integer, xx integer, y integer);
---END---
---START---
alter table tt7 drop column xx;
---END---
---START---
CREATE TABLE tt8 (gemini_pk serial PRIMARY KEY, x integer, z integer);
---END---
---START---
create view vv2 as
select * from (values(1,2,3,4,5)) v(a,b,c,d,e)
union all
select * from tt7 full join tt8 using (x), tt8 tt8x;
---END---
---START---
select pg_get_viewdef('vv2', true);
---END---
---START---
create view vv3 as
select * from (values(1,2,3,4,5,6)) v(a,b,c,x,e,f)
union all
select * from
  tt7 full join tt8 using (x),
  tt7 tt7x full join tt8 tt8x using (x);
---END---
---START---
select pg_get_viewdef('vv3', true);
---END---
---START---
create view vv4 as
select * from (values(1,2,3,4,5,6,7)) v(a,b,c,x,e,f,g)
union all
select * from
  tt7 full join tt8 using (x),
  tt7 tt7x full join tt8 tt8x using (x) full join tt8 tt8y using (x);
---END---
---START---
select pg_get_viewdef('vv4', true);
---END---
---START---
alter table tt7 add column zz int;
---END---
---START---
alter table tt7 add column z int;
---END---
---START---
alter table tt7 drop column zz;
---END---
---START---
alter table tt8 add column z2 int;
---END---
---START---
select pg_get_viewdef('vv2', true);
---END---
---START---
select pg_get_viewdef('vv3', true);
---END---
---START---
select pg_get_viewdef('vv4', true);
---END---
---START---
CREATE TABLE tt7a (gemini_pk serial PRIMARY KEY, x date, xx integer, y integer);
---END---
---START---
alter table tt7a drop column xx;
---END---
---START---
CREATE TABLE tt8a (gemini_pk serial PRIMARY KEY, x timestamptz, z integer);
---END---
---START---
create view vv2a as
select * from (values(now(),2,3,now(),5)) v(a,b,c,d,e)
union all
select * from tt7a left join tt8a using (x), tt8a tt8ax;
---END---
---START---
select pg_get_viewdef('vv2a', true);
---END---
---START---
CREATE TABLE tt9 (gemini_pk serial PRIMARY KEY, x integer, xx integer, y integer);
---END---
---START---
CREATE TABLE tt10 (gemini_pk serial PRIMARY KEY, x integer, z integer);
---END---
---START---
create view vv5 as select x,y,z from tt9 join tt10 using(x);
---END---
---START---
select pg_get_viewdef('vv5', true);
---END---
---START---
alter table tt9 drop column xx;
---END---
---START---
select pg_get_viewdef('vv5', true);
---END---
---START---
CREATE TABLE tt11 (gemini_pk serial PRIMARY KEY, x integer, y integer);
---END---
---START---
CREATE TABLE tt12 (gemini_pk serial PRIMARY KEY, x integer, z integer);
---END---
---START---
CREATE TABLE tt13 (gemini_pk serial PRIMARY KEY, z integer, q integer);
---END---
---START---
create view vv6 as select x,y,z,q from
  (tt11 join tt12 using(x)) join tt13 using(z);
---END---
---START---
select pg_get_viewdef('vv6', true);
---END---
---START---
alter table tt11 add column z int;
---END---
---START---
select pg_get_viewdef('vv6', true);
---END---
---START---
CREATE TABLE tt14t (gemini_pk serial PRIMARY KEY, f1 text, f2 text, f3 text, f4 text);
---END---
---START---
insert into tt14t values('foo', 'bar', 'baz', '42');
---END---
---START---
alter table tt14t drop column f2;
---END---
---START---
create function tt14f() returns setof tt14t as
$$
declare
    rec1 record;
begin
    for rec1 in select * from tt14t
    loop
        return next rec1;
    end loop;
end;
$$
language plpgsql;
---END---
---START---
create view tt14v as select t.* from tt14f() t;
---END---
---START---
select pg_get_viewdef('tt14v', true);
---END---
---START---
select * from tt14v;
---END---
---START---
alter table tt14t drop column f3;
---END---
---START---
-- fail, view has explicit reference to f3

-- We used to have a bug that would allow the above to succeed, posing
-- hazards for later execution of the view.  Check that the internal
-- defenses for those hazards haven't bit-rotted, in case some other
-- bug with similar symptoms emerges.
begin;
---END---
---START---
-- destroy the dependency entry that prevents the DROP:
delete from pg_depend where
  objid = (select oid from pg_rewrite
           where ev_class = 'tt14v'::regclass and rulename = '_RETURN')
  and refobjsubid = 3
returning pg_describe_object(classid, objid, objsubid) as obj,
          pg_describe_object(refclassid, refobjid, refobjsubid) as ref,
          deptype;
---END---
---START---
-- this will now succeed:
alter table tt14t drop column f3;
---END---
---START---
-- column f3 is still in the view, sort of ...
select pg_get_viewdef('tt14v', true);
---END---
---START---
-- ... and you can even EXPLAIN it ...
explain (verbose, costs off) select * from tt14v;
---END---
---START---
-- but it will fail at execution
select f1, f4 from tt14v;
---END---
---START---
select * from tt14v;
---END---
---START---
rollback;
---END---
---START---
-- likewise, altering a referenced column's type is prohibited ...
alter table tt14t alter column f4 type integer using f4::integer;
---END---
---START---
-- fail

-- ... but some bug might let it happen, so check defenses
begin;
---END---
---START---
-- destroy the dependency entry that prevents the ALTER:
delete from pg_depend where
  objid = (select oid from pg_rewrite
           where ev_class = 'tt14v'::regclass and rulename = '_RETURN')
  and refobjsubid = 4
returning pg_describe_object(classid, objid, objsubid) as obj,
          pg_describe_object(refclassid, refobjid, refobjsubid) as ref,
          deptype;
---END---
---START---
-- this will now succeed:
alter table tt14t alter column f4 type integer using f4::integer;
---END---
---START---
-- f4 is still in the view ...
select pg_get_viewdef('tt14v', true);
---END---
---START---
-- but will fail at execution
select f1, f3 from tt14v;
---END---
---START---
select * from tt14v;
---END---
---START---
rollback;
---END---
---START---
drop view tt14v;
---END---
---START---
create view tt14v as select t.f1, t.f4 from tt14f() t;
---END---
---START---
select pg_get_viewdef('tt14v', true);
---END---
---START---
select * from tt14v;
---END---
---START---
alter table tt14t drop column f3;
---END---
---START---
-- ok

select pg_get_viewdef('tt14v', true);
---END---
---START---
explain (verbose, costs off) select * from tt14v;
---END---
---START---
select * from tt14v;
---END---
---START---
-- check display of whole-row variables in some corner cases

create type nestedcomposite as (x int8_tbl);
---END---
---START---
create view tt15v as select row(i)::nestedcomposite from int8_tbl i;
---END---
---START---
select * from tt15v;
---END---
---START---
select pg_get_viewdef('tt15v', true);
---END---
---START---
select row(i.*::int8_tbl)::nestedcomposite from int8_tbl i;
---END---
---START---
create view tt16v as select * from int8_tbl i, lateral(values(i)) ss;
---END---
---START---
select * from tt16v;
---END---
---START---
select pg_get_viewdef('tt16v', true);
---END---
---START---
select * from int8_tbl i, lateral(values(i.*::int8_tbl)) ss;
---END---
---START---
create view tt17v as select * from int8_tbl i where i in (values(i));
---END---
---START---
select * from tt17v;
---END---
---START---
select pg_get_viewdef('tt17v', true);
---END---
---START---
select * from int8_tbl i where i.* in (values(i.*::int8_tbl));
---END---
---START---
CREATE TABLE tt15v_log (gemini_pk serial PRIMARY KEY, o tt15v, n tt15v, incr bool);
---END---
---START---
create rule updlog as on update to tt15v do also
  insert into tt15v_log values(old, new, row(old,old) < row(new,new));
---END---
---START---
\d+ tt15v

-- check unique-ification of overlength names

create view tt18v as
  select * from int8_tbl xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
  union all
  select * from int8_tbl xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz;
---END---
---START---
select pg_get_viewdef('tt18v', true);
---END---
---START---
explain (costs off) select * from tt18v;
---END---
---START---
-- check display of ScalarArrayOp with a sub-select

select 'foo'::text = any(array['abc','def','foo']::text[]);
---END---
---START---
select 'foo'::text = any((select array['abc','def','foo']::text[]));
---END---
---START---
-- fail
select 'foo'::text = any((select array['abc','def','foo']::text[])::text[]);
---END---
---START---
create view tt19v as
select 'foo'::text = any(array['abc','def','foo']::text[]) c1,
       'foo'::text = any((select array['abc','def','foo']::text[])::text[]) c2;
---END---
---START---
select pg_get_viewdef('tt19v', true);
---END---
---START---
-- check display of assorted RTE_FUNCTION expressions

create view tt20v as
select * from
  coalesce(1,2) as c,
  collation for ('x'::text) col,
  current_date as d,
  localtimestamp(3) as t,
  cast(1+2 as int8) as i4,
  cast(1+2 as int8) as i8;
---END---
---START---
select pg_get_viewdef('tt20v', true);
---END---
---START---
-- reverse-listing of various special function syntaxes required by SQL

create view tt201v as
select
  ('2022-12-01'::date + '1 day'::interval) at time zone 'UTC' as atz,
  extract(day from now()) as extr,
  (now(), '1 day'::interval) overlaps
    (current_timestamp(2), '1 day'::interval) as o,
  'foo' is normalized isn,
  'foo' is nfkc normalized isnn,
  normalize('foo') as n,
  normalize('foo', nfkd) as nfkd,
  overlay('foo' placing 'bar' from 2) as ovl,
  overlay('foo' placing 'bar' from 2 for 3) as ovl2,
  position('foo' in 'foobar') as p,
  substring('foo' from 2 for 3) as s,
  substring('foo' similar 'f' escape '#') as ss,
  substring('foo' from 'oo') as ssf,  -- historically-permitted abuse
  trim(' ' from ' foo ') as bt,
  trim(leading ' ' from ' foo ') as lt,
  trim(trailing ' foo ') as rt,
  trim(E'\\000'::bytea from E'\\000Tom\\000'::bytea) as btb,
  trim(leading E'\\000'::bytea from E'\\000Tom\\000'::bytea) as ltb,
  trim(trailing E'\\000'::bytea from E'\\000Tom\\000'::bytea) as rtb,
  CURRENT_DATE as cd,
  (select * from CURRENT_DATE) as cd2,
  CURRENT_TIME as ct,
  (select * from CURRENT_TIME) as ct2,
  CURRENT_TIME (1) as ct3,
  (select * from CURRENT_TIME (1)) as ct4,
  CURRENT_TIMESTAMP as ct5,
  (select * from CURRENT_TIMESTAMP) as ct6,
  CURRENT_TIMESTAMP (1) as ct7,
  (select * from CURRENT_TIMESTAMP (1)) as ct8,
  LOCALTIME as lt1,
  (select * from LOCALTIME) as lt2,
  LOCALTIME (1) as lt3,
  (select * from LOCALTIME (1)) as lt4,
  LOCALTIMESTAMP as lt5,
  (select * from LOCALTIMESTAMP) as lt6,
  LOCALTIMESTAMP (1) as lt7,
  (select * from LOCALTIMESTAMP (1)) as lt8,
  CURRENT_CATALOG as ca,
  (select * from CURRENT_CATALOG) as ca2,
  CURRENT_ROLE as cr,
  (select * from CURRENT_ROLE) as cr2,
  CURRENT_SCHEMA as cs,
  (select * from CURRENT_SCHEMA) as cs2,
  CURRENT_USER as cu,
  (select * from CURRENT_USER) as cu2,
  USER as us,
  (select * from USER) as us2,
  SESSION_USER seu,
  (select * from SESSION_USER) as seu2,
  SYSTEM_USER as su,
  (select * from SYSTEM_USER) as su2;
---END---
---START---
select pg_get_viewdef('tt201v', true);
---END---
---START---
-- corner cases with empty join conditions

create view tt21v as
select * from tt5 natural inner join tt6;
---END---
---START---
select pg_get_viewdef('tt21v', true);
---END---
---START---
create view tt22v as
select * from tt5 natural left join tt6;
---END---
---START---
select pg_get_viewdef('tt22v', true);
---END---
---START---
-- check handling of views with immediately-renamed columns

create view tt23v (col_a, col_b) as
select q1 as other_name1, q2 as other_name2 from int8_tbl
union
select 42, 43;
---END---
---START---
select pg_get_viewdef('tt23v', true);
---END---
---START---
select pg_get_ruledef(oid, true) from pg_rewrite
  where ev_class = 'tt23v'::regclass and ev_type = '1';
---END---
---START---
-- test extraction of FieldSelect field names (get_name_for_var_field)

create view tt24v as
with cte as materialized (select r from (values(1,2),(3,4)) r)
select (r).column2 as col_a, (rr).column2 as col_b from
  cte join (select rr from (values(1,7),(3,8)) rr limit 2) ss
  on (r).column1 = (rr).column1;
---END---
---START---
select pg_get_viewdef('tt24v', true);
---END---
---START---
create view tt25v as
with cte as materialized (select pg_get_keywords() k)
select (k).word from cte;
---END---
---START---
select pg_get_viewdef('tt25v', true);
---END---
---START---
-- also check cases seen only in EXPLAIN
explain (verbose, costs off)
select * from tt24v;
---END---
---START---
explain (verbose, costs off)
select (r).column2 from (select r from (values(1,2),(3,4)) r limit 1) ss;
---END---
---START---
-- test pretty-print parenthesization rules, and SubLink deparsing

create view tt26v as
select x + y + z as c1,
       (x * y) + z as c2,
       x + (y * z) as c3,
       (x + y) * z as c4,
       x * (y + z) as c5,
       x + (y + z) as c6,
       x + (y # z) as c7,
       (x > y) AND (y > z OR x > z) as c8,
       (x > y) OR (y > z AND NOT (x > z)) as c9,
       (x,y) <> ALL (values(1,2),(3,4)) as c10,
       (x,y) <= ANY (values(1,2),(3,4)) as c11
from (values(1,2,3)) v(x,y,z);
---END---
---START---
select pg_get_viewdef('tt26v', true);
---END---
---START---
-- clean up all the random objects we made above
DROP SCHEMA temp_view_test CASCADE;
---END---
---START---
DROP SCHEMA testviewschm2 CASCADE;
---END---
