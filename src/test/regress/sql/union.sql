---START---
--
-- UNION (also INTERSECT, EXCEPT)
--

-- Simple UNION constructs

SELECT 1 AS two UNION SELECT 2 ORDER BY 1;
---END---
---START---

SELECT 1 AS one UNION SELECT 1 ORDER BY 1;
---END---
---START---

SELECT 1 AS two UNION ALL SELECT 2;
---END---
---START---

SELECT 1 AS two UNION ALL SELECT 1;
---END---
---START---

SELECT 1 AS three UNION SELECT 2 UNION SELECT 3 ORDER BY 1;
---END---
---START---

SELECT 1 AS two UNION SELECT 2 UNION SELECT 2 ORDER BY 1;
---END---
---START---

SELECT 1 AS three UNION SELECT 2 UNION ALL SELECT 2 ORDER BY 1;
---END---
---START---

SELECT 1.1 AS two UNION SELECT 2.2 ORDER BY 1;
---END---
---START---

-- Mixed types

SELECT 1.1 AS two UNION SELECT 2 ORDER BY 1;
---END---
---START---

SELECT 1 AS two UNION SELECT 2.2 ORDER BY 1;
---END---
---START---

SELECT 1 AS one UNION SELECT 1.0::float8 ORDER BY 1;
---END---
---START---

SELECT 1.1 AS two UNION ALL SELECT 2 ORDER BY 1;
---END---
---START---

SELECT 1.0::float8 AS two UNION ALL SELECT 1 ORDER BY 1;
---END---
---START---

SELECT 1.1 AS three UNION SELECT 2 UNION SELECT 3 ORDER BY 1;
---END---
---START---

SELECT 1.1::float8 AS two UNION SELECT 2 UNION SELECT 2.0::float8 ORDER BY 1;
---END---
---START---

SELECT 1.1 AS three UNION SELECT 2 UNION ALL SELECT 2 ORDER BY 1;
---END---
---START---

SELECT 1.1 AS two UNION (SELECT 2 UNION ALL SELECT 2) ORDER BY 1;
---END---
---START---

--
-- Try testing from tables...
--

SELECT f1 AS five FROM FLOAT8_TBL
UNION
SELECT f1 FROM FLOAT8_TBL
ORDER BY 1;
---END---
---START---

SELECT f1 AS ten FROM FLOAT8_TBL
UNION ALL
SELECT f1 FROM FLOAT8_TBL;
---END---
---START---

SELECT f1 AS nine FROM FLOAT8_TBL
UNION
SELECT f1 FROM INT4_TBL
ORDER BY 1;
---END---
---START---

SELECT f1 AS ten FROM FLOAT8_TBL
UNION ALL
SELECT f1 FROM INT4_TBL;
---END---
---START---

SELECT f1 AS five FROM FLOAT8_TBL
  WHERE f1 BETWEEN -1e6 AND 1e6
UNION
SELECT f1 FROM INT4_TBL
  WHERE f1 BETWEEN 0 AND 1000000
ORDER BY 1;
---END---
---START---

SELECT CAST(f1 AS char(4)) AS three FROM VARCHAR_TBL
UNION
SELECT f1 FROM CHAR_TBL
ORDER BY 1;
---END---
---START---

SELECT f1 AS three FROM VARCHAR_TBL
UNION
SELECT CAST(f1 AS varchar) FROM CHAR_TBL
ORDER BY 1;
---END---
---START---

SELECT f1 AS eight FROM VARCHAR_TBL
UNION ALL
SELECT f1 FROM CHAR_TBL;
---END---
---START---

SELECT f1 AS five FROM TEXT_TBL
UNION
SELECT f1 FROM VARCHAR_TBL
UNION
SELECT TRIM(TRAILING FROM f1) FROM CHAR_TBL
ORDER BY 1;
---END---
---START---

--
-- INTERSECT and EXCEPT
--

SELECT q2 FROM int8_tbl INTERSECT SELECT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q2 FROM int8_tbl INTERSECT ALL SELECT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q2 FROM int8_tbl EXCEPT SELECT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q2 FROM int8_tbl EXCEPT ALL SELECT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q2 FROM int8_tbl EXCEPT ALL SELECT DISTINCT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q1 FROM int8_tbl EXCEPT SELECT q2 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q1 FROM int8_tbl EXCEPT ALL SELECT q2 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q1 FROM int8_tbl EXCEPT ALL SELECT DISTINCT q2 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q1 FROM int8_tbl EXCEPT ALL SELECT q1 FROM int8_tbl FOR NO KEY UPDATE;
---END---
---START---

-- nested cases
(SELECT 1,2,3 UNION SELECT 4,5,6) INTERSECT SELECT 4,5,6;
---END---
---START---
(SELECT 1,2,3 UNION SELECT 4,5,6 ORDER BY 1,2) INTERSECT SELECT 4,5,6;
---END---
---START---
(SELECT 1,2,3 UNION SELECT 4,5,6) EXCEPT SELECT 4,5,6;
---END---
---START---
(SELECT 1,2,3 UNION SELECT 4,5,6 ORDER BY 1,2) EXCEPT SELECT 4,5,6;
---END---
---START---

-- exercise both hashed and sorted implementations of UNION/INTERSECT/EXCEPT

set enable_hashagg to on;
---END---
---START---

explain (costs off)
select count(*) from
  ( select unique1 from tenk1 union select fivethous from tenk1 ) ss;
---END---
---START---
select count(*) from
  ( select unique1 from tenk1 union select fivethous from tenk1 ) ss;
---END---
---START---

explain (costs off)
select count(*) from
  ( select unique1 from tenk1 intersect select fivethous from tenk1 ) ss;
---END---
---START---
select count(*) from
  ( select unique1 from tenk1 intersect select fivethous from tenk1 ) ss;
---END---
---START---

explain (costs off)
select unique1 from tenk1 except select unique2 from tenk1 where unique2 != 10;
---END---
---START---
select unique1 from tenk1 except select unique2 from tenk1 where unique2 != 10;
---END---
---START---

set enable_hashagg to off;
---END---
---START---

explain (costs off)
select count(*) from
  ( select unique1 from tenk1 union select fivethous from tenk1 ) ss;
---END---
---START---
select count(*) from
  ( select unique1 from tenk1 union select fivethous from tenk1 ) ss;
---END---
---START---

explain (costs off)
select count(*) from
  ( select unique1 from tenk1 intersect select fivethous from tenk1 ) ss;
---END---
---START---
select count(*) from
  ( select unique1 from tenk1 intersect select fivethous from tenk1 ) ss;
---END---
---START---

explain (costs off)
select unique1 from tenk1 except select unique2 from tenk1 where unique2 != 10;
---END---
---START---
select unique1 from tenk1 except select unique2 from tenk1 where unique2 != 10;
---END---
---START---

reset enable_hashagg;
---END---
---START---

-- non-hashable type
set enable_hashagg to on;
---END---
---START---

explain (costs off)
select x from (values (100::money), (200::money)) _(x) union select x from (values (100::money), (300::money)) _(x);
---END---
---START---

set enable_hashagg to off;
---END---
---START---

explain (costs off)
select x from (values (100::money), (200::money)) _(x) union select x from (values (100::money), (300::money)) _(x);
---END---
---START---

reset enable_hashagg;
---END---
---START---

-- arrays
set enable_hashagg to on;
---END---
---START---

explain (costs off)
select x from (values (array[1, 2]), (array[1, 3])) _(x) union select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
select x from (values (array[1, 2]), (array[1, 3])) _(x) union select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
explain (costs off)
select x from (values (array[1, 2]), (array[1, 3])) _(x) intersect select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
select x from (values (array[1, 2]), (array[1, 3])) _(x) intersect select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
explain (costs off)
select x from (values (array[1, 2]), (array[1, 3])) _(x) except select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
select x from (values (array[1, 2]), (array[1, 3])) _(x) except select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---

-- non-hashable type
explain (costs off)
select x from (values (array[100::money]), (array[200::money])) _(x) union select x from (values (array[100::money]), (array[300::money])) _(x);
---END---
---START---
select x from (values (array[100::money]), (array[200::money])) _(x) union select x from (values (array[100::money]), (array[300::money])) _(x);
---END---
---START---

set enable_hashagg to off;
---END---
---START---

explain (costs off)
select x from (values (array[1, 2]), (array[1, 3])) _(x) union select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
select x from (values (array[1, 2]), (array[1, 3])) _(x) union select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
explain (costs off)
select x from (values (array[1, 2]), (array[1, 3])) _(x) intersect select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
select x from (values (array[1, 2]), (array[1, 3])) _(x) intersect select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
explain (costs off)
select x from (values (array[1, 2]), (array[1, 3])) _(x) except select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---
select x from (values (array[1, 2]), (array[1, 3])) _(x) except select x from (values (array[1, 2]), (array[1, 4])) _(x);
---END---
---START---

reset enable_hashagg;
---END---
---START---

-- records
set enable_hashagg to on;
---END---
---START---

explain (costs off)
select x from (values (row(1, 2)), (row(1, 3))) _(x) union select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
select x from (values (row(1, 2)), (row(1, 3))) _(x) union select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
explain (costs off)
select x from (values (row(1, 2)), (row(1, 3))) _(x) intersect select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
select x from (values (row(1, 2)), (row(1, 3))) _(x) intersect select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
explain (costs off)
select x from (values (row(1, 2)), (row(1, 3))) _(x) except select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
select x from (values (row(1, 2)), (row(1, 3))) _(x) except select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---

-- non-hashable type

-- With an anonymous row type, the typcache does not report that the
-- type is hashable.  (Otherwise, this would fail at execution time.)
explain (costs off)
select x from (values (row(100::money)), (row(200::money))) _(x) union select x from (values (row(100::money)), (row(300::money))) _(x);
---END---
---START---
select x from (values (row(100::money)), (row(200::money))) _(x) union select x from (values (row(100::money)), (row(300::money))) _(x);
---END---
---START---

-- With a defined row type, the typcache can inspect the type's fields
-- for hashability.
create type ct1 as (f1 money);
---END---
---START---
explain (costs off)
select x from (values (row(100::money)::ct1), (row(200::money)::ct1)) _(x) union select x from (values (row(100::money)::ct1), (row(300::money)::ct1)) _(x);
---END---
---START---
select x from (values (row(100::money)::ct1), (row(200::money)::ct1)) _(x) union select x from (values (row(100::money)::ct1), (row(300::money)::ct1)) _(x);
---END---
---START---
drop type ct1;
---END---
---START---

set enable_hashagg to off;
---END---
---START---

explain (costs off)
select x from (values (row(1, 2)), (row(1, 3))) _(x) union select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
select x from (values (row(1, 2)), (row(1, 3))) _(x) union select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
explain (costs off)
select x from (values (row(1, 2)), (row(1, 3))) _(x) intersect select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
select x from (values (row(1, 2)), (row(1, 3))) _(x) intersect select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
explain (costs off)
select x from (values (row(1, 2)), (row(1, 3))) _(x) except select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---
select x from (values (row(1, 2)), (row(1, 3))) _(x) except select x from (values (row(1, 2)), (row(1, 4))) _(x);
---END---
---START---

reset enable_hashagg;
---END---
---START---

--
-- Mixed types
--

SELECT f1 FROM float8_tbl INTERSECT SELECT f1 FROM int4_tbl ORDER BY 1;
---END---
---START---

SELECT f1 FROM float8_tbl EXCEPT SELECT f1 FROM int4_tbl ORDER BY 1;
---END---
---START---

--
-- Operator precedence and (((((extra))))) parentheses
--

SELECT q1 FROM int8_tbl INTERSECT SELECT q2 FROM int8_tbl UNION ALL SELECT q2 FROM int8_tbl  ORDER BY 1;
---END---
---START---

SELECT q1 FROM int8_tbl INTERSECT (((SELECT q2 FROM int8_tbl UNION ALL SELECT q2 FROM int8_tbl))) ORDER BY 1;
---END---
---START---

(((SELECT q1 FROM int8_tbl INTERSECT SELECT q2 FROM int8_tbl ORDER BY 1))) UNION ALL SELECT q2 FROM int8_tbl;
---END---
---START---

SELECT q1 FROM int8_tbl UNION ALL SELECT q2 FROM int8_tbl EXCEPT SELECT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

SELECT q1 FROM int8_tbl UNION ALL (((SELECT q2 FROM int8_tbl EXCEPT SELECT q1 FROM int8_tbl ORDER BY 1)));
---END---
---START---

(((SELECT q1 FROM int8_tbl UNION ALL SELECT q2 FROM int8_tbl))) EXCEPT SELECT q1 FROM int8_tbl ORDER BY 1;
---END---
---START---

--
-- Subqueries with ORDER BY & LIMIT clauses
--

-- In this syntax, ORDER BY/LIMIT apply to the result of the EXCEPT
SELECT q1,q2 FROM int8_tbl EXCEPT SELECT q2,q1 FROM int8_tbl
ORDER BY q2,q1;
---END---
---START---

-- This should fail, because q2 isn't a name of an EXCEPT output column
SELECT q1 FROM int8_tbl EXCEPT SELECT q2 FROM int8_tbl ORDER BY q2 LIMIT 1;
---END---
---START---

-- But this should work:
SELECT q1 FROM int8_tbl EXCEPT (((SELECT q2 FROM int8_tbl ORDER BY q2 LIMIT 1))) ORDER BY 1;
---END---
---START---

--
-- New syntaxes (7.1) permit new tests
--

(((((select * from int8_tbl)))));
---END---
---START---

--
-- Check behavior with empty select list (allowed since 9.4)
--

select union select;
---END---
---START---
select intersect select;
---END---
---START---
select except select;
---END---
---START---

-- check hashed implementation
set enable_hashagg = true;
---END---
---START---
set enable_sort = false;
---END---
---START---

explain (costs off)
select from generate_series(1,5) union select from generate_series(1,3);
---END---
---START---
explain (costs off)
select from generate_series(1,5) intersect select from generate_series(1,3);
---END---
---START---

select from generate_series(1,5) union select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) union all select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) intersect select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) intersect all select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) except select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) except all select from generate_series(1,3);
---END---
---START---

-- check sorted implementation
set enable_hashagg = false;
---END---
---START---
set enable_sort = true;
---END---
---START---

explain (costs off)
select from generate_series(1,5) union select from generate_series(1,3);
---END---
---START---
explain (costs off)
select from generate_series(1,5) intersect select from generate_series(1,3);
---END---
---START---

select from generate_series(1,5) union select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) union all select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) intersect select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) intersect all select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) except select from generate_series(1,3);
---END---
---START---
select from generate_series(1,5) except all select from generate_series(1,3);
---END---
---START---

reset enable_hashagg;
---END---
---START---
reset enable_sort;
---END---
---START---

--
-- Check handling of a case with unknown constants.  We don't guarantee
-- an undecorated constant will work in all cases, but historically this
-- usage has worked, so test we don't break it.
--

SELECT a.f1 FROM (SELECT 'test' AS f1 FROM varchar_tbl) a
UNION
SELECT b.f1 FROM (SELECT f1 FROM varchar_tbl) b
ORDER BY 1;
---END---
---START---

-- This should fail, but it should produce an error cursor
SELECT '3.4'::numeric UNION SELECT 'foo';
---END---
---START---

--
-- Test that expression-index constraints can be pushed down through
-- UNION or UNION ALL
--

CREATE TABLE t1 (a text, b text);
---END---
---START---
CREATE INDEX t1_ab_idx on t1 ((a || b));
---END---
---START---
CREATE TABLE t2 (ab text primary key);
---END---
---START---
INSERT INTO t1 VALUES ('a', 'b'), ('x', 'y');
---END---
---START---
INSERT INTO t2 VALUES ('ab'), ('xy');
---END---
---START---

set enable_seqscan = off;
---END---
---START---
set enable_indexscan = on;
---END---
---START---
set enable_bitmapscan = off;
---END---
---START---

explain (costs off)
 SELECT * FROM
 (SELECT a || b AS ab FROM t1
  UNION ALL
  SELECT * FROM t2) t
 WHERE ab = 'ab';
---END---
---START---

explain (costs off)
 SELECT * FROM
 (SELECT a || b AS ab FROM t1
  UNION
  SELECT * FROM t2) t
 WHERE ab = 'ab';
---END---
---START---

--
-- Test that ORDER BY for UNION ALL can be pushed down to inheritance
-- children.
--

CREATE TABLE t1c (b text, a text);
---END---
---START---
ALTER TABLE t1c INHERIT t1;
---END---
---START---
CREATE TABLE t2c (primary key (ab)) INHERITS (t2);
---END---
---START---
INSERT INTO t1c VALUES ('v', 'w'), ('c', 'd'), ('m', 'n'), ('e', 'f');
---END---
---START---
INSERT INTO t2c VALUES ('vw'), ('cd'), ('mn'), ('ef');
---END---
---START---
CREATE INDEX t1c_ab_idx on t1c ((a || b));
---END---
---START---

set enable_seqscan = on;
---END---
---START---
set enable_indexonlyscan = off;
---END---
---START---

explain (costs off)
  SELECT * FROM
  (SELECT a || b AS ab FROM t1
   UNION ALL
   SELECT ab FROM t2) t
  ORDER BY 1 LIMIT 8;
---END---
---START---

  SELECT * FROM
  (SELECT a || b AS ab FROM t1
   UNION ALL
   SELECT ab FROM t2) t
  ORDER BY 1 LIMIT 8;
---END---
---START---

reset enable_seqscan;
---END---
---START---
reset enable_indexscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---

-- This simpler variant of the above test has been observed to fail differently

create table events (event_id int primary key);
---END---
---START---
create table other_events (event_id int primary key);
---END---
---START---
create table events_child () inherits (events);
---END---
---START---

explain (costs off)
select event_id
 from (select event_id from events
       union all
       select event_id from other_events) ss
 order by event_id;
---END---
---START---

drop table events_child, events, other_events;
---END---
---START---

reset enable_indexonlyscan;
---END---
---START---

-- Test constraint exclusion of UNION ALL subqueries
explain (costs off)
 SELECT * FROM
  (SELECT 1 AS t, * FROM tenk1 a
   UNION ALL
   SELECT 2 AS t, * FROM tenk1 b) c
 WHERE t = 2;
---END---
---START---

-- Test that we push quals into UNION sub-selects only when it's safe
explain (costs off)
SELECT * FROM
  (SELECT 1 AS t, 2 AS x
   UNION
   SELECT 2 AS t, 4 AS x) ss
WHERE x < 4
ORDER BY x;
---END---
---START---

SELECT * FROM
  (SELECT 1 AS t, 2 AS x
   UNION
   SELECT 2 AS t, 4 AS x) ss
WHERE x < 4
ORDER BY x;
---END---
---START---

explain (costs off)
SELECT * FROM
  (SELECT 1 AS t, generate_series(1,10) AS x
   UNION
   SELECT 2 AS t, 4 AS x) ss
WHERE x < 4
ORDER BY x;
---END---
---START---

SELECT * FROM
  (SELECT 1 AS t, generate_series(1,10) AS x
   UNION
   SELECT 2 AS t, 4 AS x) ss
WHERE x < 4
ORDER BY x;
---END---
---START---

explain (costs off)
SELECT * FROM
  (SELECT 1 AS t, (random()*3)::int AS x
   UNION
   SELECT 2 AS t, 4 AS x) ss
WHERE x > 3
ORDER BY x;
---END---
---START---

SELECT * FROM
  (SELECT 1 AS t, (random()*3)::int AS x
   UNION
   SELECT 2 AS t, 4 AS x) ss
WHERE x > 3
ORDER BY x;
---END---
---START---

-- Test cases where the native ordering of a sub-select has more pathkeys
-- than the outer query cares about
explain (costs off)
select distinct q1 from
  (select distinct * from int8_tbl i81
   union all
   select distinct * from int8_tbl i82) ss
where q2 = q2;
---END---
---START---

select distinct q1 from
  (select distinct * from int8_tbl i81
   union all
   select distinct * from int8_tbl i82) ss
where q2 = q2;
---END---
---START---

explain (costs off)
select distinct q1 from
  (select distinct * from int8_tbl i81
   union all
   select distinct * from int8_tbl i82) ss
where -q1 = q2;
---END---
---START---

select distinct q1 from
  (select distinct * from int8_tbl i81
   union all
   select distinct * from int8_tbl i82) ss
where -q1 = q2;
---END---
---START---

-- Test proper handling of parameterized appendrel paths when the
-- potential join qual is expensive
create function expensivefunc(int) returns int
language plpgsql immutable strict cost 10000
as $$begin return $1; end$$;
---END---
---START---

create table t3 as select generate_series(-1000,1000) as x;
---END---
---START---
create index t3i on t3 (expensivefunc(x));
---END---
---START---
analyze t3;
---END---
---START---

explain (costs off)
select * from
  (select * from t3 a union all select * from t3 b) ss
  join int4_tbl on f1 = expensivefunc(x);
---END---
---START---
select * from
  (select * from t3 a union all select * from t3 b) ss
  join int4_tbl on f1 = expensivefunc(x);
---END---
---START---

drop table t1c;
drop table t2c;
drop table t1;
drop table t2;
drop table t3;
---END---
---START---
drop function expensivefunc(int);
---END---
---START---

-- Test handling of appendrel quals that const-simplify into an AND
explain (costs off)
select * from
  (select *, 0 as x from int8_tbl a
   union all
   select *, 1 as x from int8_tbl b) ss
where (x = 0) or (q1 >= q2 and q1 <= q2);
---END---
---START---
select * from
  (select *, 0 as x from int8_tbl a
   union all
   select *, 1 as x from int8_tbl b) ss
where (x = 0) or (q1 >= q2 and q1 <= q2);
---END---
