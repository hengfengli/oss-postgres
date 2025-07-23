---START---
--
-- AGGREGATES
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

-- avoid bit-exact output here because operations may not be bit-exact.
SET extra_float_digits = 0;
---END---
---START---

-- prepare some test data
CREATE TABLE aggtest (
	a 			int2,
	b			float4
);
---END---
---START---

\set filename :abs_srcdir '/data/agg.data'
COPY aggtest FROM :'filename';
---END---
---START---

ANALYZE aggtest;
---END---
---START---


SELECT avg(four) AS avg_1 FROM onek;
---END---
---START---

SELECT avg(a) AS avg_32 FROM aggtest WHERE a < 100;
---END---
---START---

SELECT any_value(v) FROM (VALUES (1), (2), (3)) AS v (v);
---END---
---START---
SELECT any_value(v) FROM (VALUES (NULL)) AS v (v);
---END---
---START---
SELECT any_value(v) FROM (VALUES (NULL), (1), (2)) AS v (v);
---END---
---START---
SELECT any_value(v) FROM (VALUES (array['hello', 'world'])) AS v (v);
---END---
---START---

-- In 7.1, avg(float4) is computed using float8 arithmetic.
-- Round the result to 3 digits to avoid platform-specific results.

SELECT avg(b)::numeric(10,3) AS avg_107_943 FROM aggtest;
---END---
---START---

SELECT avg(gpa) AS avg_3_4 FROM ONLY student;
---END---
---START---


SELECT sum(four) AS sum_1500 FROM onek;
---END---
---START---
SELECT sum(a) AS sum_198 FROM aggtest;
---END---
---START---
SELECT sum(b) AS avg_431_773 FROM aggtest;
---END---
---START---
SELECT sum(gpa) AS avg_6_8 FROM ONLY student;
---END---
---START---

SELECT max(four) AS max_3 FROM onek;
---END---
---START---
SELECT max(a) AS max_100 FROM aggtest;
---END---
---START---
SELECT max(aggtest.b) AS max_324_78 FROM aggtest;
---END---
---START---
SELECT max(student.gpa) AS max_3_7 FROM student;
---END---
---START---

SELECT stddev_pop(b) FROM aggtest;
---END---
---START---
SELECT stddev_samp(b) FROM aggtest;
---END---
---START---
SELECT var_pop(b) FROM aggtest;
---END---
---START---
SELECT var_samp(b) FROM aggtest;
---END---
---START---

SELECT stddev_pop(b::numeric) FROM aggtest;
---END---
---START---
SELECT stddev_samp(b::numeric) FROM aggtest;
---END---
---START---
SELECT var_pop(b::numeric) FROM aggtest;
---END---
---START---
SELECT var_samp(b::numeric) FROM aggtest;
---END---
---START---

-- population variance is defined for a single tuple, sample variance
-- is not
SELECT var_pop(1.0::float8), var_samp(2.0::float8);
---END---
---START---
SELECT stddev_pop(3.0::float8), stddev_samp(4.0::float8);
---END---
---START---
SELECT var_pop('inf'::float8), var_samp('inf'::float8);
---END---
---START---
SELECT stddev_pop('inf'::float8), stddev_samp('inf'::float8);
---END---
---START---
SELECT var_pop('nan'::float8), var_samp('nan'::float8);
---END---
---START---
SELECT stddev_pop('nan'::float8), stddev_samp('nan'::float8);
---END---
---START---
SELECT var_pop(1.0::float4), var_samp(2.0::float4);
---END---
---START---
SELECT stddev_pop(3.0::float4), stddev_samp(4.0::float4);
---END---
---START---
SELECT var_pop('inf'::float4), var_samp('inf'::float4);
---END---
---START---
SELECT stddev_pop('inf'::float4), stddev_samp('inf'::float4);
---END---
---START---
SELECT var_pop('nan'::float4), var_samp('nan'::float4);
---END---
---START---
SELECT stddev_pop('nan'::float4), stddev_samp('nan'::float4);
---END---
---START---
SELECT var_pop(1.0::numeric), var_samp(2.0::numeric);
---END---
---START---
SELECT stddev_pop(3.0::numeric), stddev_samp(4.0::numeric);
---END---
---START---
SELECT var_pop('inf'::numeric), var_samp('inf'::numeric);
---END---
---START---
SELECT stddev_pop('inf'::numeric), stddev_samp('inf'::numeric);
---END---
---START---
SELECT var_pop('nan'::numeric), var_samp('nan'::numeric);
---END---
---START---
SELECT stddev_pop('nan'::numeric), stddev_samp('nan'::numeric);
---END---
---START---

-- verify correct results for null and NaN inputs
select sum(null::int4) from generate_series(1,3);
---END---
---START---
select sum(null::int8) from generate_series(1,3);
---END---
---START---
select sum(null::numeric) from generate_series(1,3);
---END---
---START---
select sum(null::float8) from generate_series(1,3);
---END---
---START---
select avg(null::int4) from generate_series(1,3);
---END---
---START---
select avg(null::int8) from generate_series(1,3);
---END---
---START---
select avg(null::numeric) from generate_series(1,3);
---END---
---START---
select avg(null::float8) from generate_series(1,3);
---END---
---START---
select sum('NaN'::numeric) from generate_series(1,3);
---END---
---START---
select avg('NaN'::numeric) from generate_series(1,3);
---END---
---START---

-- verify correct results for infinite inputs
SELECT sum(x::float8), avg(x::float8), var_pop(x::float8)
FROM (VALUES ('1'), ('infinity')) v(x);
---END---
---START---
SELECT sum(x::float8), avg(x::float8), var_pop(x::float8)
FROM (VALUES ('infinity'), ('1')) v(x);
---END---
---START---
SELECT sum(x::float8), avg(x::float8), var_pop(x::float8)
FROM (VALUES ('infinity'), ('infinity')) v(x);
---END---
---START---
SELECT sum(x::float8), avg(x::float8), var_pop(x::float8)
FROM (VALUES ('-infinity'), ('infinity')) v(x);
---END---
---START---
SELECT sum(x::float8), avg(x::float8), var_pop(x::float8)
FROM (VALUES ('-infinity'), ('-infinity')) v(x);
---END---
---START---
SELECT sum(x::numeric), avg(x::numeric), var_pop(x::numeric)
FROM (VALUES ('1'), ('infinity')) v(x);
---END---
---START---
SELECT sum(x::numeric), avg(x::numeric), var_pop(x::numeric)
FROM (VALUES ('infinity'), ('1')) v(x);
---END---
---START---
SELECT sum(x::numeric), avg(x::numeric), var_pop(x::numeric)
FROM (VALUES ('infinity'), ('infinity')) v(x);
---END---
---START---
SELECT sum(x::numeric), avg(x::numeric), var_pop(x::numeric)
FROM (VALUES ('-infinity'), ('infinity')) v(x);
---END---
---START---
SELECT sum(x::numeric), avg(x::numeric), var_pop(x::numeric)
FROM (VALUES ('-infinity'), ('-infinity')) v(x);
---END---
---START---

-- test accuracy with a large input offset
SELECT avg(x::float8), var_pop(x::float8)
FROM (VALUES (100000003), (100000004), (100000006), (100000007)) v(x);
---END---
---START---
SELECT avg(x::float8), var_pop(x::float8)
FROM (VALUES (7000000000005), (7000000000007)) v(x);
---END---
---START---

-- SQL2003 binary aggregates
SELECT regr_count(b, a) FROM aggtest;
---END---
---START---
SELECT regr_sxx(b, a) FROM aggtest;
---END---
---START---
SELECT regr_syy(b, a) FROM aggtest;
---END---
---START---
SELECT regr_sxy(b, a) FROM aggtest;
---END---
---START---
SELECT regr_avgx(b, a), regr_avgy(b, a) FROM aggtest;
---END---
---START---
SELECT regr_r2(b, a) FROM aggtest;
---END---
---START---
SELECT regr_slope(b, a), regr_intercept(b, a) FROM aggtest;
---END---
---START---
SELECT covar_pop(b, a), covar_samp(b, a) FROM aggtest;
---END---
---START---
SELECT corr(b, a) FROM aggtest;
---END---
---START---

-- check single-tuple behavior
SELECT covar_pop(1::float8,2::float8), covar_samp(3::float8,4::float8);
---END---
---START---
SELECT covar_pop(1::float8,'inf'::float8), covar_samp(3::float8,'inf'::float8);
---END---
---START---
SELECT covar_pop(1::float8,'nan'::float8), covar_samp(3::float8,'nan'::float8);
---END---
---START---

-- test accum and combine functions directly
CREATE TABLE regr_test (x float8, y float8);
---END---
---START---
INSERT INTO regr_test VALUES (10,150),(20,250),(30,350),(80,540),(100,200);
---END---
---START---
SELECT count(*), sum(x), regr_sxx(y,x), sum(y),regr_syy(y,x), regr_sxy(y,x)
FROM regr_test WHERE x IN (10,20,30,80);
---END---
---START---
SELECT count(*), sum(x), regr_sxx(y,x), sum(y),regr_syy(y,x), regr_sxy(y,x)
FROM regr_test;
---END---
---START---
SELECT float8_accum('{4,140,2900}'::float8[], 100);
---END---
---START---
SELECT float8_regr_accum('{4,140,2900,1290,83075,15050}'::float8[], 200, 100);
---END---
---START---
SELECT count(*), sum(x), regr_sxx(y,x), sum(y),regr_syy(y,x), regr_sxy(y,x)
FROM regr_test WHERE x IN (10,20,30);
---END---
---START---
SELECT count(*), sum(x), regr_sxx(y,x), sum(y),regr_syy(y,x), regr_sxy(y,x)
FROM regr_test WHERE x IN (80,100);
---END---
---START---
SELECT float8_combine('{3,60,200}'::float8[], '{0,0,0}'::float8[]);
---END---
---START---
SELECT float8_combine('{0,0,0}'::float8[], '{2,180,200}'::float8[]);
---END---
---START---
SELECT float8_combine('{3,60,200}'::float8[], '{2,180,200}'::float8[]);
---END---
---START---
SELECT float8_regr_combine('{3,60,200,750,20000,2000}'::float8[],
                           '{0,0,0,0,0,0}'::float8[]);
---END---
---START---
SELECT float8_regr_combine('{0,0,0,0,0,0}'::float8[],
                           '{2,180,200,740,57800,-3400}'::float8[]);
---END---
---START---
SELECT float8_regr_combine('{3,60,200,750,20000,2000}'::float8[],
                           '{2,180,200,740,57800,-3400}'::float8[]);
---END---
---START---
DROP TABLE regr_test;
---END---
---START---

-- test count, distinct
SELECT count(four) AS cnt_1000 FROM onek;
---END---
---START---
SELECT count(DISTINCT four) AS cnt_4 FROM onek;
---END---
---START---

select ten, count(*), sum(four) from onek
group by ten order by ten;
---END---
---START---

select ten, count(four), sum(DISTINCT four) from onek
group by ten order by ten;
---END---
---START---

-- user-defined aggregates
SELECT newavg(four) AS avg_1 FROM onek;
---END---
---START---
SELECT newsum(four) AS sum_1500 FROM onek;
---END---
---START---
SELECT newcnt(four) AS cnt_1000 FROM onek;
---END---
---START---
SELECT newcnt(*) AS cnt_1000 FROM onek;
---END---
---START---
SELECT oldcnt(*) AS cnt_1000 FROM onek;
---END---
---START---
SELECT sum2(q1,q2) FROM int8_tbl;
---END---
---START---

-- test for outer-level aggregates

-- this should work
select ten, sum(distinct four) from onek a
group by ten
having exists (select 1 from onek b where sum(distinct a.four) = b.four);
---END---
---START---

-- this should fail because subquery has an agg of its own in WHERE
select ten, sum(distinct four) from onek a
group by ten
having exists (select 1 from onek b
               where sum(distinct a.four + b.four) = b.four);
---END---
---START---

-- Test handling of sublinks within outer-level aggregates.
-- Per bug report from Daniel Grace.
select
  (select max((select i.unique2 from tenk1 i where i.unique1 = o.unique1)))
from tenk1 o;
---END---
---START---

-- Test handling of Params within aggregate arguments in hashed aggregation.
-- Per bug report from Jeevan Chalke.
explain (verbose, costs off)
select s1, s2, sm
from generate_series(1, 3) s1,
     lateral (select s2, sum(s1 + s2) sm
              from generate_series(1, 3) s2 group by s2) ss
order by 1, 2;
---END---
---START---
select s1, s2, sm
from generate_series(1, 3) s1,
     lateral (select s2, sum(s1 + s2) sm
              from generate_series(1, 3) s2 group by s2) ss
order by 1, 2;
---END---
---START---

explain (verbose, costs off)
select array(select sum(x+y) s
            from generate_series(1,3) y group by y order by s)
  from generate_series(1,3) x;
---END---
---START---
select array(select sum(x+y) s
            from generate_series(1,3) y group by y order by s)
  from generate_series(1,3) x;
---END---
---START---

--
-- test for bitwise integer aggregates
--
CREATE TEMPORARY TABLE bitwise_test(
  i2 INT2,
  i4 INT4,
  i8 INT8,
  i INTEGER,
  x INT2,
  y BIT(4)
);
---END---
---START---

-- empty case
SELECT
  BIT_AND(i2) AS "?",
  BIT_OR(i4)  AS "?",
  BIT_XOR(i8) AS "?"
FROM bitwise_test;
---END---
---START---

COPY bitwise_test FROM STDIN NULL 'null';
---END---
---START---
1	1	1	1	1	B0101
3	3	3	null	2	B0100
7	7	7	3	4	B1100
\.

SELECT
  BIT_AND(i2) AS "1",
  BIT_AND(i4) AS "1",
  BIT_AND(i8) AS "1",
  BIT_AND(i)  AS "?",
  BIT_AND(x)  AS "0",
  BIT_AND(y)  AS "0100",

  BIT_OR(i2)  AS "7",
  BIT_OR(i4)  AS "7",
  BIT_OR(i8)  AS "7",
  BIT_OR(i)   AS "?",
  BIT_OR(x)   AS "7",
  BIT_OR(y)   AS "1101",

  BIT_XOR(i2) AS "5",
  BIT_XOR(i4) AS "5",
  BIT_XOR(i8) AS "5",
  BIT_XOR(i)  AS "?",
  BIT_XOR(x)  AS "7",
  BIT_XOR(y)  AS "1101"
FROM bitwise_test;
---END---
---START---

--
-- test boolean aggregates
--
-- first test all possible transition and final states

SELECT
  -- boolean and transitions
  -- null because strict
  booland_statefunc(NULL, NULL)  IS NULL AS "t",
  booland_statefunc(TRUE, NULL)  IS NULL AS "t",
  booland_statefunc(FALSE, NULL) IS NULL AS "t",
  booland_statefunc(NULL, TRUE)  IS NULL AS "t",
  booland_statefunc(NULL, FALSE) IS NULL AS "t",
  -- and actual computations
  booland_statefunc(TRUE, TRUE) AS "t",
  NOT booland_statefunc(TRUE, FALSE) AS "t",
  NOT booland_statefunc(FALSE, TRUE) AS "t",
  NOT booland_statefunc(FALSE, FALSE) AS "t";
---END---
---START---

SELECT
  -- boolean or transitions
  -- null because strict
  boolor_statefunc(NULL, NULL)  IS NULL AS "t",
  boolor_statefunc(TRUE, NULL)  IS NULL AS "t",
  boolor_statefunc(FALSE, NULL) IS NULL AS "t",
  boolor_statefunc(NULL, TRUE)  IS NULL AS "t",
  boolor_statefunc(NULL, FALSE) IS NULL AS "t",
  -- actual computations
  boolor_statefunc(TRUE, TRUE) AS "t",
  boolor_statefunc(TRUE, FALSE) AS "t",
  boolor_statefunc(FALSE, TRUE) AS "t",
  NOT boolor_statefunc(FALSE, FALSE) AS "t";
---END---
---START---

CREATE TEMPORARY TABLE bool_test(
  b1 BOOL,
  b2 BOOL,
  b3 BOOL,
  b4 BOOL);
---END---
---START---

-- empty case
SELECT
  BOOL_AND(b1)   AS "n",
  BOOL_OR(b3)    AS "n"
FROM bool_test;
---END---
---START---

COPY bool_test FROM STDIN NULL 'null';
---END---
---START---
TRUE	null	FALSE	null
FALSE	TRUE	null	null
null	TRUE	FALSE	null
\.

SELECT
  BOOL_AND(b1)     AS "f",
  BOOL_AND(b2)     AS "t",
  BOOL_AND(b3)     AS "f",
  BOOL_AND(b4)     AS "n",
  BOOL_AND(NOT b2) AS "f",
  BOOL_AND(NOT b3) AS "t"
FROM bool_test;
---END---
---START---

SELECT
  EVERY(b1)     AS "f",
  EVERY(b2)     AS "t",
  EVERY(b3)     AS "f",
  EVERY(b4)     AS "n",
  EVERY(NOT b2) AS "f",
  EVERY(NOT b3) AS "t"
FROM bool_test;
---END---
---START---

SELECT
  BOOL_OR(b1)      AS "t",
  BOOL_OR(b2)      AS "t",
  BOOL_OR(b3)      AS "f",
  BOOL_OR(b4)      AS "n",
  BOOL_OR(NOT b2)  AS "f",
  BOOL_OR(NOT b3)  AS "t"
FROM bool_test;
---END---
---START---

--
-- Test cases that should be optimized into indexscans instead of
-- the generic aggregate implementation.
--

-- Basic cases
explain (costs off)
  select min(unique1) from tenk1;
---END---
---START---
select min(unique1) from tenk1;
---END---
---START---
explain (costs off)
  select max(unique1) from tenk1;
---END---
---START---
select max(unique1) from tenk1;
---END---
---START---
explain (costs off)
  select max(unique1) from tenk1 where unique1 < 42;
---END---
---START---
select max(unique1) from tenk1 where unique1 < 42;
---END---
---START---
explain (costs off)
  select max(unique1) from tenk1 where unique1 > 42;
---END---
---START---
select max(unique1) from tenk1 where unique1 > 42;
---END---
---START---

-- the planner may choose a generic aggregate here if parallel query is
-- enabled, since that plan will be parallel safe and the "optimized"
-- plan, which has almost identical cost, will not be.  we want to test
-- the optimized plan, so temporarily disable parallel query.
begin;
---END---
---START---
set local max_parallel_workers_per_gather = 0;
---END---
---START---
explain (costs off)
  select max(unique1) from tenk1 where unique1 > 42000;
---END---
---START---
select max(unique1) from tenk1 where unique1 > 42000;
---END---
---START---
rollback;
---END---
---START---

-- multi-column index (uses tenk1_thous_tenthous)
explain (costs off)
  select max(tenthous) from tenk1 where thousand = 33;
---END---
---START---
select max(tenthous) from tenk1 where thousand = 33;
---END---
---START---
explain (costs off)
  select min(tenthous) from tenk1 where thousand = 33;
---END---
---START---
select min(tenthous) from tenk1 where thousand = 33;
---END---
---START---

-- check parameter propagation into an indexscan subquery
explain (costs off)
  select f1, (select min(unique1) from tenk1 where unique1 > f1) AS gt
    from int4_tbl;
---END---
---START---
select f1, (select min(unique1) from tenk1 where unique1 > f1) AS gt
  from int4_tbl;
---END---
---START---

-- check some cases that were handled incorrectly in 8.3.0
explain (costs off)
  select distinct max(unique2) from tenk1;
---END---
---START---
select distinct max(unique2) from tenk1;
---END---
---START---
explain (costs off)
  select max(unique2) from tenk1 order by 1;
---END---
---START---
select max(unique2) from tenk1 order by 1;
---END---
---START---
explain (costs off)
  select max(unique2) from tenk1 order by max(unique2);
---END---
---START---
select max(unique2) from tenk1 order by max(unique2);
---END---
---START---
explain (costs off)
  select max(unique2) from tenk1 order by max(unique2)+1;
---END---
---START---
select max(unique2) from tenk1 order by max(unique2)+1;
---END---
---START---
explain (costs off)
  select max(unique2), generate_series(1,3) as g from tenk1 order by g desc;
---END---
---START---
select max(unique2), generate_series(1,3) as g from tenk1 order by g desc;
---END---
---START---

-- interesting corner case: constant gets optimized into a seqscan
explain (costs off)
  select max(100) from tenk1;
---END---
---START---
select max(100) from tenk1;
---END---
---START---

-- try it on an inheritance tree
create table minmaxtest(f1 int);
---END---
---START---
create table minmaxtest1() inherits (minmaxtest);
---END---
---START---
create table minmaxtest2() inherits (minmaxtest);
---END---
---START---
create table minmaxtest3() inherits (minmaxtest);
---END---
---START---
create index minmaxtesti on minmaxtest(f1);
---END---
---START---
create index minmaxtest1i on minmaxtest1(f1);
---END---
---START---
create index minmaxtest2i on minmaxtest2(f1 desc);
---END---
---START---
create index minmaxtest3i on minmaxtest3(f1) where f1 is not null;
---END---
---START---

insert into minmaxtest values(11), (12);
---END---
---START---
insert into minmaxtest1 values(13), (14);
---END---
---START---
insert into minmaxtest2 values(15), (16);
---END---
---START---
insert into minmaxtest3 values(17), (18);
---END---
---START---

explain (costs off)
  select min(f1), max(f1) from minmaxtest;
---END---
---START---
select min(f1), max(f1) from minmaxtest;
---END---
---START---

-- DISTINCT doesn't do anything useful here, but it shouldn't fail
explain (costs off)
  select distinct min(f1), max(f1) from minmaxtest;
---END---
---START---
select distinct min(f1), max(f1) from minmaxtest;
---END---
---START---

drop table minmaxtest cascade;
---END---
---START---

-- check for correct detection of nested-aggregate errors
select max(min(unique1)) from tenk1;
---END---
---START---
select (select max(min(unique1)) from int8_tbl) from tenk1;
---END---
---START---
select avg((select avg(a1.col1 order by (select avg(a2.col2) from tenk1 a3))
            from tenk1 a1(col1)))
from tenk1 a2(col2);
---END---
---START---

--
-- Test removal of redundant GROUP BY columns
--

create temp table t1 (a int, b int, c int, d int, primary key (a, b));
---END---
---START---
create temp table t2 (x int, y int, z int, primary key (x, y));
---END---
---START---
create temp table t3 (a int, b int, c int, primary key(a, b) deferrable);
---END---
---START---

-- Non-primary-key columns can be removed from GROUP BY
explain (costs off) select * from t1 group by a,b,c,d;
---END---
---START---

-- No removal can happen if the complete PK is not present in GROUP BY
explain (costs off) select a,c from t1 group by a,c,d;
---END---
---START---

-- Test removal across multiple relations
explain (costs off) select *
from t1 inner join t2 on t1.a = t2.x and t1.b = t2.y
group by t1.a,t1.b,t1.c,t1.d,t2.x,t2.y,t2.z;
---END---
---START---

-- Test case where t1 can be optimized but not t2
explain (costs off) select t1.*,t2.x,t2.z
from t1 inner join t2 on t1.a = t2.x and t1.b = t2.y
group by t1.a,t1.b,t1.c,t1.d,t2.x,t2.z;
---END---
---START---

-- Cannot optimize when PK is deferrable
explain (costs off) select * from t3 group by a,b,c;
---END---
---START---

create temp table t1c () inherits (t1);
---END---
---START---

-- Ensure we don't remove any columns when t1 has a child table
explain (costs off) select * from t1 group by a,b,c,d;
---END---
---START---

-- Okay to remove columns if we're only querying the parent.
explain (costs off) select * from only t1 group by a,b,c,d;
---END---
---START---

create temp table p_t1 (
  a int,
  b int,
  c int,
  d int,
  primary key(a,b)
) partition by list(a);
---END---
---START---
create temp table p_t1_1 partition of p_t1 for values in(1);
---END---
---START---
create temp table p_t1_2 partition of p_t1 for values in(2);
---END---
---START---

-- Ensure we can remove non-PK columns for partitioned tables.
explain (costs off) select * from p_t1 group by a,b,c,d;
---END---
---START---

drop table t1 cascade;
---END---
---START---
drop table t2;
---END---
---START---
drop table t3;
---END---
---START---
drop table p_t1;
---END---
---START---

--
-- Test GROUP BY matching of join columns that are type-coerced due to USING
--

create temp table t1(f1 int, f2 int);
---END---
---START---
create temp table t2(f1 bigint, f2 oid);
---END---
---START---

select f1 from t1 left join t2 using (f1) group by f1;
---END---
---START---
select f1 from t1 left join t2 using (f1) group by t1.f1;
---END---
---START---
select t1.f1 from t1 left join t2 using (f1) group by t1.f1;
---END---
---START---
-- only this one should fail:
select t1.f1 from t1 left join t2 using (f1) group by f1;
---END---
---START---

-- check case where we have to inject nullingrels into coerced join alias
select f1, count(*) from
t1 x(x0,x1) left join (t1 left join t2 using(f1)) on (x0 = 0)
group by f1;
---END---
---START---

-- same, for a RelabelType coercion
select f2, count(*) from
t1 x(x0,x1) left join (t1 left join t2 using(f2)) on (x0 = 0)
group by f2;
---END---
---START---

drop table t1, t2;
---END---
---START---

--
-- Test planner's selection of pathkeys for ORDER BY aggregates
--

-- Ensure we order by four.  This suits the most aggregate functions.
explain (costs off)
select sum(two order by two),max(four order by four), min(four order by four)
from tenk1;
---END---
---START---

-- Ensure we order by two.  It's a tie between ordering by two and four but
-- we tiebreak on the aggregate's position.
explain (costs off)
select
  sum(two order by two), max(four order by four),
  min(four order by four), max(two order by two)
from tenk1;
---END---
---START---

-- Similar to above, but tiebreak on ordering by four
explain (costs off)
select
  max(four order by four), sum(two order by two),
  min(four order by four), max(two order by two)
from tenk1;
---END---
---START---

-- Ensure this one orders by ten since there are 3 aggregates that require ten
-- vs two that suit two and four.
explain (costs off)
select
  max(four order by four), sum(two order by two),
  min(four order by four), max(two order by two),
  sum(ten order by ten), min(ten order by ten), max(ten order by ten)
from tenk1;
---END---
---START---

-- Try a case involving a GROUP BY clause where the GROUP BY column is also
-- part of an aggregate's ORDER BY clause.  We want a sort order that works
-- for the GROUP BY along with the first and the last aggregate.
explain (costs off)
select
  sum(unique1 order by ten, two), sum(unique1 order by four),
  sum(unique1 order by two, four)
from tenk1
group by ten;
---END---
---START---

-- Ensure that we never choose to provide presorted input to an Aggref with
-- a volatile function in the ORDER BY / DISTINCT clause.  We want to ensure
-- these sorts are performed individually rather than at the query level.
explain (costs off)
select
  sum(unique1 order by two), sum(unique1 order by four),
  sum(unique1 order by four, two), sum(unique1 order by two, random()),
  sum(unique1 order by two, random(), random() + 1)
from tenk1
group by ten;
---END---
---START---

-- Ensure consecutive NULLs are properly treated as distinct from each other
select array_agg(distinct val)
from (select null as val from generate_series(1, 2));
---END---
---START---

-- Ensure no ordering is requested when enable_presorted_aggregate is off
set enable_presorted_aggregate to off;
---END---
---START---
explain (costs off)
select sum(two order by two) from tenk1;
---END---
---START---
reset enable_presorted_aggregate;
---END---
---START---

--
-- Test combinations of DISTINCT and/or ORDER BY
--

select array_agg(a order by b)
  from (values (1,4),(2,3),(3,1),(4,2)) v(a,b);
---END---
---START---
select array_agg(a order by a)
  from (values (1,4),(2,3),(3,1),(4,2)) v(a,b);
---END---
---START---
select array_agg(a order by a desc)
  from (values (1,4),(2,3),(3,1),(4,2)) v(a,b);
---END---
---START---
select array_agg(b order by a desc)
  from (values (1,4),(2,3),(3,1),(4,2)) v(a,b);
---END---
---START---

select array_agg(distinct a)
  from (values (1),(2),(1),(3),(null),(2)) v(a);
---END---
---START---
select array_agg(distinct a order by a)
  from (values (1),(2),(1),(3),(null),(2)) v(a);
---END---
---START---
select array_agg(distinct a order by a desc)
  from (values (1),(2),(1),(3),(null),(2)) v(a);
---END---
---START---
select array_agg(distinct a order by a desc nulls last)
  from (values (1),(2),(1),(3),(null),(2)) v(a);
---END---
---START---

-- multi-arg aggs, strict/nonstrict, distinct/order by

select aggfstr(a,b,c)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c);
---END---
---START---
select aggfns(a,b,c)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c);
---END---
---START---

select aggfstr(distinct a,b,c)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,3) i;
---END---
---START---
select aggfns(distinct a,b,c)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,3) i;
---END---
---START---

select aggfstr(distinct a,b,c order by b)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,3) i;
---END---
---START---
select aggfns(distinct a,b,c order by b)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,3) i;
---END---
---START---

-- test specific code paths

select aggfns(distinct a,a,c order by c using ~<~,a)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,2) i;
---END---
---START---
select aggfns(distinct a,a,c order by c using ~<~)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,2) i;
---END---
---START---
select aggfns(distinct a,a,c order by a)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,2) i;
---END---
---START---
select aggfns(distinct a,b,c order by a,c using ~<~,b)
  from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
       generate_series(1,2) i;
---END---
---START---

-- check node I/O via view creation and usage, also deparsing logic

create view agg_view1 as
  select aggfns(a,b,c)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c);
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

create or replace view agg_view1 as
  select aggfns(distinct a,b,c)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
         generate_series(1,3) i;
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

create or replace view agg_view1 as
  select aggfns(distinct a,b,c order by b)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
         generate_series(1,3) i;
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

create or replace view agg_view1 as
  select aggfns(a,b,c order by b+1)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c);
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

create or replace view agg_view1 as
  select aggfns(a,a,c order by b)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c);
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

create or replace view agg_view1 as
  select aggfns(a,b,c order by c using ~<~)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c);
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

create or replace view agg_view1 as
  select aggfns(distinct a,b,c order by a,c using ~<~,b)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
         generate_series(1,2) i;
---END---
---START---

select * from agg_view1;
---END---
---START---
select pg_get_viewdef('agg_view1'::regclass);
---END---
---START---

drop view agg_view1;
---END---
---START---

-- incorrect DISTINCT usage errors

select aggfns(distinct a,b,c order by i)
  from (values (1,1,'foo')) v(a,b,c), generate_series(1,2) i;
---END---
---START---
select aggfns(distinct a,b,c order by a,b+1)
  from (values (1,1,'foo')) v(a,b,c), generate_series(1,2) i;
---END---
---START---
select aggfns(distinct a,b,c order by a,b,i,c)
  from (values (1,1,'foo')) v(a,b,c), generate_series(1,2) i;
---END---
---START---
select aggfns(distinct a,a,c order by a,b)
  from (values (1,1,'foo')) v(a,b,c), generate_series(1,2) i;
---END---
---START---

-- string_agg tests
select string_agg(a,',') from (values('aaaa'),('bbbb'),('cccc')) g(a);
---END---
---START---
select string_agg(a,',') from (values('aaaa'),(null),('bbbb'),('cccc')) g(a);
---END---
---START---
select string_agg(a,'AB') from (values(null),(null),('bbbb'),('cccc')) g(a);
---END---
---START---
select string_agg(a,',') from (values(null),(null)) g(a);
---END---
---START---

-- check some implicit casting cases, as per bug #5564
select string_agg(distinct f1, ',' order by f1) from varchar_tbl;  -- ok
select string_agg(distinct f1::text, ',' order by f1) from varchar_tbl;  -- not ok
select string_agg(distinct f1, ',' order by f1::text) from varchar_tbl;  -- not ok
select string_agg(distinct f1::text, ',' order by f1::text) from varchar_tbl;  -- ok

-- string_agg bytea tests
create table bytea_test_table(v bytea);
---END---
---START---

select string_agg(v, '') from bytea_test_table;
---END---
---START---

insert into bytea_test_table values(decode('ff','hex'));
---END---
---START---

select string_agg(v, '') from bytea_test_table;
---END---
---START---

insert into bytea_test_table values(decode('aa','hex'));
---END---
---START---

select string_agg(v, '') from bytea_test_table;
---END---
---START---
select string_agg(v, NULL) from bytea_test_table;
---END---
---START---
select string_agg(v, decode('ee', 'hex')) from bytea_test_table;
---END---
---START---

drop table bytea_test_table;
---END---
---START---

-- Test parallel string_agg and array_agg
create table pagg_test (x int, y int);
---END---
---START---
insert into pagg_test
select (case x % 4 when 1 then null else x end), x % 10
from generate_series(1,5000) x;
---END---
---START---

set parallel_setup_cost TO 0;
---END---
---START---
set parallel_tuple_cost TO 0;
---END---
---START---
set parallel_leader_participation TO 0;
---END---
---START---
set min_parallel_table_scan_size = 0;
---END---
---START---
set bytea_output = 'escape';
---END---
---START---
set max_parallel_workers_per_gather = 2;
---END---
---START---

-- create a view as we otherwise have to repeat this query a few times.
create view v_pagg_test AS
select
	y,
	min(t) AS tmin,max(t) AS tmax,count(distinct t) AS tndistinct,
	min(b) AS bmin,max(b) AS bmax,count(distinct b) AS bndistinct,
	min(a) AS amin,max(a) AS amax,count(distinct a) AS andistinct,
	min(aa) AS aamin,max(aa) AS aamax,count(distinct aa) AS aandistinct
from (
	select
		y,
		unnest(regexp_split_to_array(a1.t, ','))::int AS t,
		unnest(regexp_split_to_array(a1.b::text, ',')) AS b,
		unnest(a1.a) AS a,
		unnest(a1.aa) AS aa
	from (
		select
			y,
			string_agg(x::text, ',') AS t,
			string_agg(x::text::bytea, ',') AS b,
			array_agg(x) AS a,
			array_agg(ARRAY[x]) AS aa
		from pagg_test
		group by y
	) a1
) a2
group by y;
---END---
---START---

-- Ensure results are correct.
select * from v_pagg_test order by y;
---END---
---START---

-- Ensure parallel aggregation is actually being used.
explain (costs off) select * from v_pagg_test order by y;
---END---
---START---

set max_parallel_workers_per_gather = 0;
---END---
---START---

-- Ensure results are the same without parallel aggregation.
select * from v_pagg_test order by y;
---END---
---START---

-- Clean up
reset max_parallel_workers_per_gather;
---END---
---START---
reset bytea_output;
---END---
---START---
reset min_parallel_table_scan_size;
---END---
---START---
reset parallel_leader_participation;
---END---
---START---
reset parallel_tuple_cost;
---END---
---START---
reset parallel_setup_cost;
---END---
---START---

drop view v_pagg_test;
---END---
---START---
drop table pagg_test;
---END---
---START---

-- FILTER tests

select min(unique1) filter (where unique1 > 100) from tenk1;
---END---
---START---

select sum(1/ten) filter (where ten > 0) from tenk1;
---END---
---START---

select ten, sum(distinct four) filter (where four::text ~ '123') from onek a
group by ten;
---END---
---START---

select ten, sum(distinct four) filter (where four > 10) from onek a
group by ten
having exists (select 1 from onek b where sum(distinct a.four) = b.four);
---END---
---START---

select max(foo COLLATE "C") filter (where (bar collate "POSIX") > '0')
from (values ('a', 'b')) AS v(foo,bar);
---END---
---START---

select any_value(v) filter (where v > 2) from (values (1), (2), (3)) as v (v);
---END---
---START---

-- outer reference in FILTER (PostgreSQL extension)
select (select count(*)
        from (values (1)) t0(inner_c))
from (values (2),(3)) t1(outer_c); -- inner query is aggregation query
select (select count(*) filter (where outer_c <> 0)
        from (values (1)) t0(inner_c))
from (values (2),(3)) t1(outer_c); -- outer query is aggregation query
select (select count(inner_c) filter (where outer_c <> 0)
        from (values (1)) t0(inner_c))
from (values (2),(3)) t1(outer_c); -- inner query is aggregation query
select
  (select max((select i.unique2 from tenk1 i where i.unique1 = o.unique1))
     filter (where o.unique1 < 10))
from tenk1 o;					-- outer query is aggregation query

-- subquery in FILTER clause (PostgreSQL extension)
select sum(unique1) FILTER (WHERE
  unique1 IN (SELECT unique1 FROM onek where unique1 < 100)) FROM tenk1;
---END---
---START---

-- exercise lots of aggregate parts with FILTER
select aggfns(distinct a,b,c order by a,c using ~<~,b) filter (where a > 1)
    from (values (1,3,'foo'),(0,null,null),(2,2,'bar'),(3,1,'baz')) v(a,b,c),
    generate_series(1,2) i;
---END---
---START---

-- check handling of bare boolean Var in FILTER
select max(0) filter (where b1) from bool_test;
---END---
---START---
select (select max(0) filter (where b1)) from bool_test;
---END---
---START---

-- check for correct detection of nested-aggregate errors in FILTER
select max(unique1) filter (where sum(ten) > 0) from tenk1;
---END---
---START---
select (select max(unique1) filter (where sum(ten) > 0) from int8_tbl) from tenk1;
---END---
---START---
select max(unique1) filter (where bool_or(ten > 0)) from tenk1;
---END---
---START---
select (select max(unique1) filter (where bool_or(ten > 0)) from int8_tbl) from tenk1;
---END---
---START---


-- ordered-set aggregates

select p, percentile_cont(p) within group (order by x::float8)
from generate_series(1,5) x,
     (values (0::float8),(0.1),(0.25),(0.4),(0.5),(0.6),(0.75),(0.9),(1)) v(p)
group by p order by p;
---END---
---START---

select p, percentile_cont(p order by p) within group (order by x)  -- error
from generate_series(1,5) x,
     (values (0::float8),(0.1),(0.25),(0.4),(0.5),(0.6),(0.75),(0.9),(1)) v(p)
group by p order by p;
---END---
---START---

select p, sum() within group (order by x::float8)  -- error
from generate_series(1,5) x,
     (values (0::float8),(0.1),(0.25),(0.4),(0.5),(0.6),(0.75),(0.9),(1)) v(p)
group by p order by p;
---END---
---START---

select p, percentile_cont(p,p)  -- error
from generate_series(1,5) x,
     (values (0::float8),(0.1),(0.25),(0.4),(0.5),(0.6),(0.75),(0.9),(1)) v(p)
group by p order by p;
---END---
---START---

select percentile_cont(0.5) within group (order by b) from aggtest;
---END---
---START---
select percentile_cont(0.5) within group (order by b), sum(b) from aggtest;
---END---
---START---
select percentile_cont(0.5) within group (order by thousand) from tenk1;
---END---
---START---
select percentile_disc(0.5) within group (order by thousand) from tenk1;
---END---
---START---
select rank(3) within group (order by x)
from (values (1),(1),(2),(2),(3),(3),(4)) v(x);
---END---
---START---
select cume_dist(3) within group (order by x)
from (values (1),(1),(2),(2),(3),(3),(4)) v(x);
---END---
---START---
select percent_rank(3) within group (order by x)
from (values (1),(1),(2),(2),(3),(3),(4),(5)) v(x);
---END---
---START---
select dense_rank(3) within group (order by x)
from (values (1),(1),(2),(2),(3),(3),(4)) v(x);
---END---
---START---

select percentile_disc(array[0,0.1,0.25,0.5,0.75,0.9,1]) within group (order by thousand)
from tenk1;
---END---
---START---
select percentile_cont(array[0,0.25,0.5,0.75,1]) within group (order by thousand)
from tenk1;
---END---
---START---
select percentile_disc(array[[null,1,0.5],[0.75,0.25,null]]) within group (order by thousand)
from tenk1;
---END---
---START---
select percentile_cont(array[0,1,0.25,0.75,0.5,1,0.3,0.32,0.35,0.38,0.4]) within group (order by x)
from generate_series(1,6) x;
---END---
---START---

select ten, mode() within group (order by string4) from tenk1 group by ten;
---END---
---START---

select percentile_disc(array[0.25,0.5,0.75]) within group (order by x)
from unnest('{fred,jim,fred,jack,jill,fred,jill,jim,jim,sheila,jim,sheila}'::text[]) u(x);
---END---
---START---

-- check collation propagates up in suitable cases:
select pg_collation_for(percentile_disc(1) within group (order by x collate "POSIX"))
  from (values ('fred'),('jim')) v(x);
---END---
---START---

-- ordered-set aggs created with CREATE AGGREGATE
select test_rank(3) within group (order by x)
from (values (1),(1),(2),(2),(3),(3),(4)) v(x);
---END---
---START---
select test_percentile_disc(0.5) within group (order by thousand) from tenk1;
---END---
---START---

-- ordered-set aggs can't use ungrouped vars in direct args:
select rank(x) within group (order by x) from generate_series(1,5) x;
---END---
---START---

-- outer-level agg can't use a grouped arg of a lower level, either:
select array(select percentile_disc(a) within group (order by x)
               from (values (0.3),(0.7)) v(a) group by a)
  from generate_series(1,5) g(x);
---END---
---START---

-- agg in the direct args is a grouping violation, too:
select rank(sum(x)) within group (order by x) from generate_series(1,5) x;
---END---
---START---

-- hypothetical-set type unification and argument-count failures:
select rank(3) within group (order by x) from (values ('fred'),('jim')) v(x);
---END---
---START---
select rank(3) within group (order by stringu1,stringu2) from tenk1;
---END---
---START---
select rank('fred') within group (order by x) from generate_series(1,5) x;
---END---
---START---
select rank('adam'::text collate "C") within group (order by x collate "POSIX")
  from (values ('fred'),('jim')) v(x);
---END---
---START---
-- hypothetical-set type unification successes:
select rank('adam'::varchar) within group (order by x) from (values ('fred'),('jim')) v(x);
---END---
---START---
select rank('3') within group (order by x) from generate_series(1,5) x;
---END---
---START---

-- divide by zero check
select percent_rank(0) within group (order by x) from generate_series(1,0) x;
---END---
---START---

-- deparse and multiple features:
create view aggordview1 as
select ten,
       percentile_disc(0.5) within group (order by thousand) as p50,
       percentile_disc(0.5) within group (order by thousand) filter (where hundred=1) as px,
       rank(5,'AZZZZ',50) within group (order by hundred, string4 desc, hundred)
  from tenk1
 group by ten order by ten;
---END---
---START---

select pg_get_viewdef('aggordview1');
---END---
---START---
select * from aggordview1 order by ten;
---END---
---START---
drop view aggordview1;
---END---
---START---

-- variadic aggregates
select least_agg(q1,q2) from int8_tbl;
---END---
---START---
select least_agg(variadic array[q1,q2]) from int8_tbl;
---END---
---START---

select cleast_agg(q1,q2) from int8_tbl;
---END---
---START---
select cleast_agg(4.5,f1) from int4_tbl;
---END---
---START---
select cleast_agg(variadic array[4.5,f1]) from int4_tbl;
---END---
---START---
select pg_typeof(cleast_agg(variadic array[4.5,f1])) from int4_tbl;
---END---
---START---

-- test aggregates with common transition functions share the same states
begin work;
---END---
---START---

create type avg_state as (total bigint, count bigint);
---END---
---START---

create or replace function avg_transfn(state avg_state, n int) returns avg_state as
$$
declare new_state avg_state;
---END---
---START---
begin
	raise notice 'avg_transfn called with %', n;
---END---
---START---
	if state is null then
		if n is not null then
			new_state.total := n;
---END---
---START---
			new_state.count := 1;
---END---
---START---
			return new_state;
---END---
---START---
		end if;
---END---
---START---
		return null;
---END---
---START---
	elsif n is not null then
		state.total := state.total + n;
---END---
---START---
		state.count := state.count + 1;
---END---
---START---
		return state;
---END---
---START---
	end if;
---END---
---START---

	return null;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create function avg_finalfn(state avg_state) returns int4 as
$$
begin
	if state is null then
		return NULL;
---END---
---START---
	else
		return state.total / state.count;
---END---
---START---
	end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create function sum_finalfn(state avg_state) returns int4 as
$$
begin
	if state is null then
		return NULL;
---END---
---START---
	else
		return state.total;
---END---
---START---
	end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create aggregate my_avg(int4)
(
   stype = avg_state,
   sfunc = avg_transfn,
   finalfunc = avg_finalfn
);
---END---
---START---

create aggregate my_sum(int4)
(
   stype = avg_state,
   sfunc = avg_transfn,
   finalfunc = sum_finalfn
);
---END---
---START---

-- aggregate state should be shared as aggs are the same.
select my_avg(one),my_avg(one) from (values(1),(3)) t(one);
---END---
---START---

-- aggregate state should be shared as transfn is the same for both aggs.
select my_avg(one),my_sum(one) from (values(1),(3)) t(one);
---END---
---START---

-- same as previous one, but with DISTINCT, which requires sorting the input.
select my_avg(distinct one),my_sum(distinct one) from (values(1),(3),(1)) t(one);
---END---
---START---

-- shouldn't share states due to the distinctness not matching.
select my_avg(distinct one),my_sum(one) from (values(1),(3)) t(one);
---END---
---START---

-- shouldn't share states due to the filter clause not matching.
select my_avg(one) filter (where one > 1),my_sum(one) from (values(1),(3)) t(one);
---END---
---START---

-- this should not share the state due to different input columns.
select my_avg(one),my_sum(two) from (values(1,2),(3,4)) t(one,two);
---END---
---START---

-- exercise cases where OSAs share state
select
  percentile_cont(0.5) within group (order by a),
  percentile_disc(0.5) within group (order by a)
from (values(1::float8),(3),(5),(7)) t(a);
---END---
---START---

select
  percentile_cont(0.25) within group (order by a),
  percentile_disc(0.5) within group (order by a)
from (values(1::float8),(3),(5),(7)) t(a);
---END---
---START---

-- these can't share state currently
select
  rank(4) within group (order by a),
  dense_rank(4) within group (order by a)
from (values(1),(3),(5),(7)) t(a);
---END---
---START---

-- test that aggs with the same sfunc and initcond share the same agg state
create aggregate my_sum_init(int4)
(
   stype = avg_state,
   sfunc = avg_transfn,
   finalfunc = sum_finalfn,
   initcond = '(10,0)'
);
---END---
---START---

create aggregate my_avg_init(int4)
(
   stype = avg_state,
   sfunc = avg_transfn,
   finalfunc = avg_finalfn,
   initcond = '(10,0)'
);
---END---
---START---

create aggregate my_avg_init2(int4)
(
   stype = avg_state,
   sfunc = avg_transfn,
   finalfunc = avg_finalfn,
   initcond = '(4,0)'
);
---END---
---START---

-- state should be shared if INITCONDs are matching
select my_sum_init(one),my_avg_init(one) from (values(1),(3)) t(one);
---END---
---START---

-- Varying INITCONDs should cause the states not to be shared.
select my_sum_init(one),my_avg_init2(one) from (values(1),(3)) t(one);
---END---
---START---

rollback;
---END---
---START---

-- test aggregate state sharing to ensure it works if one aggregate has a
-- finalfn and the other one has none.
begin work;
---END---
---START---

create or replace function sum_transfn(state int4, n int4) returns int4 as
$$
declare new_state int4;
---END---
---START---
begin
	raise notice 'sum_transfn called with %', n;
---END---
---START---
	if state is null then
		if n is not null then
			new_state := n;
---END---
---START---
			return new_state;
---END---
---START---
		end if;
---END---
---START---
		return null;
---END---
---START---
	elsif n is not null then
		state := state + n;
---END---
---START---
		return state;
---END---
---START---
	end if;
---END---
---START---

	return null;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create function halfsum_finalfn(state int4) returns int4 as
$$
begin
	if state is null then
		return NULL;
---END---
---START---
	else
		return state / 2;
---END---
---START---
	end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create aggregate my_sum(int4)
(
   stype = int4,
   sfunc = sum_transfn
);
---END---
---START---

create aggregate my_half_sum(int4)
(
   stype = int4,
   sfunc = sum_transfn,
   finalfunc = halfsum_finalfn
);
---END---
---START---

-- Agg state should be shared even though my_sum has no finalfn
select my_sum(one),my_half_sum(one) from (values(1),(2),(3),(4)) t(one);
---END---
---START---

rollback;
---END---
---START---


-- test that the aggregate transition logic correctly handles
-- transition / combine functions returning NULL

-- First test the case of a normal transition function returning NULL
BEGIN;
---END---
---START---
CREATE FUNCTION balkifnull(int8, int4)
RETURNS int8
STRICT
LANGUAGE plpgsql AS $$
BEGIN
    IF $1 IS NULL THEN
       RAISE 'erroneously called with NULL argument';
---END---
---START---
    END IF;
---END---
---START---
    RETURN NULL;
---END---
---START---
END$$;
---END---
---START---

CREATE AGGREGATE balk(int4)
(
    SFUNC = balkifnull(int8, int4),
    STYPE = int8,
    PARALLEL = SAFE,
    INITCOND = '0'
);
---END---
---START---

SELECT balk(hundred) FROM tenk1;
---END---
---START---

ROLLBACK;
---END---
---START---

-- Secondly test the case of a parallel aggregate combiner function
-- returning NULL. For that use normal transition function, but a
-- combiner function returning NULL.
BEGIN;
---END---
---START---
CREATE FUNCTION balkifnull(int8, int8)
RETURNS int8
PARALLEL SAFE
STRICT
LANGUAGE plpgsql AS $$
BEGIN
    IF $1 IS NULL THEN
       RAISE 'erroneously called with NULL argument';
---END---
---START---
    END IF;
---END---
---START---
    RETURN NULL;
---END---
---START---
END$$;
---END---
---START---

CREATE AGGREGATE balk(int4)
(
    SFUNC = int4_sum(int8, int4),
    STYPE = int8,
    COMBINEFUNC = balkifnull(int8, int8),
    PARALLEL = SAFE,
    INITCOND = '0'
);
---END---
---START---

-- force use of parallelism
ALTER TABLE tenk1 set (parallel_workers = 4);
---END---
---START---
SET LOCAL parallel_setup_cost=0;
---END---
---START---
SET LOCAL max_parallel_workers_per_gather=4;
---END---
---START---

EXPLAIN (COSTS OFF) SELECT balk(hundred) FROM tenk1;
---END---
---START---
SELECT balk(hundred) FROM tenk1;
---END---
---START---

ROLLBACK;
---END---
---START---

-- test multiple usage of an aggregate whose finalfn returns a R/W datum
BEGIN;
---END---
---START---

CREATE FUNCTION rwagg_sfunc(x anyarray, y anyarray) RETURNS anyarray
LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
    RETURN array_fill(y[1], ARRAY[4]);
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

CREATE FUNCTION rwagg_finalfunc(x anyarray) RETURNS anyarray
LANGUAGE plpgsql STRICT IMMUTABLE AS $$
DECLARE
    res x%TYPE;
---END---
---START---
BEGIN
    -- assignment is essential for this test, it expands the array to R/W
    res := array_fill(x[1], ARRAY[4]);
---END---
---START---
    RETURN res;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

CREATE AGGREGATE rwagg(anyarray) (
    STYPE = anyarray,
    SFUNC = rwagg_sfunc,
    FINALFUNC = rwagg_finalfunc
);
---END---
---START---

CREATE FUNCTION eatarray(x real[]) RETURNS real[]
LANGUAGE plpgsql STRICT IMMUTABLE AS $$
BEGIN
    x[1] := x[1] + 1;
---END---
---START---
    RETURN x;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

SELECT eatarray(rwagg(ARRAY[1.0::real])), eatarray(rwagg(ARRAY[1.0::real]));
---END---
---START---

ROLLBACK;
---END---
---START---

-- test coverage for aggregate combine/serial/deserial functions
BEGIN;
---END---
---START---

SET parallel_setup_cost = 0;
---END---
---START---
SET parallel_tuple_cost = 0;
---END---
---START---
SET min_parallel_table_scan_size = 0;
---END---
---START---
SET max_parallel_workers_per_gather = 4;
---END---
---START---
SET parallel_leader_participation = off;
---END---
---START---
SET enable_indexonlyscan = off;
---END---
---START---

-- variance(int4) covers numeric_poly_combine
-- sum(int8) covers int8_avg_combine
-- regr_count(float8, float8) covers int8inc_float8_float8 and aggregates with > 1 arg
EXPLAIN (COSTS OFF, VERBOSE)
SELECT variance(unique1::int4), sum(unique1::int8), regr_count(unique1::float8, unique1::float8)
FROM (SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1) u;
---END---
---START---

SELECT variance(unique1::int4), sum(unique1::int8), regr_count(unique1::float8, unique1::float8)
FROM (SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1) u;
---END---
---START---

-- variance(int8) covers numeric_combine
-- avg(numeric) covers numeric_avg_combine
EXPLAIN (COSTS OFF, VERBOSE)
SELECT variance(unique1::int8), avg(unique1::numeric)
FROM (SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1) u;
---END---
---START---

SELECT variance(unique1::int8), avg(unique1::numeric)
FROM (SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1
      UNION ALL SELECT * FROM tenk1) u;
---END---
---START---

ROLLBACK;
---END---
---START---

-- test coverage for dense_rank
SELECT dense_rank(x) WITHIN GROUP (ORDER BY x) FROM (VALUES (1),(1),(2),(2),(3),(3)) v(x) GROUP BY (x) ORDER BY 1;
---END---
---START---


-- Ensure that the STRICT checks for aggregates does not take NULLness
-- of ORDER BY columns into account. See bug report around
-- 2a505161-2727-2473-7c46-591ed108ac52@email.cz
SELECT min(x ORDER BY y) FROM (VALUES(1, NULL)) AS d(x,y);
---END---
---START---
SELECT min(x ORDER BY y) FROM (VALUES(1, 2)) AS d(x,y);
---END---
---START---

-- check collation-sensitive matching between grouping expressions
select v||'a', case v||'a' when 'aa' then 1 else 0 end, count(*)
  from unnest(array['a','b']) u(v)
 group by v||'a' order by 1;
---END---
---START---
select v||'a', case when v||'a' = 'aa' then 1 else 0 end, count(*)
  from unnest(array['a','b']) u(v)
 group by v||'a' order by 1;
---END---
---START---

-- Make sure that generation of HashAggregate for uniqification purposes
-- does not lead to array overflow due to unexpected duplicate hash keys
-- see CAFeeJoKKu0u+A_A9R9316djW-YW3-+Gtgvy3ju655qRHR3jtdA@mail.gmail.com
set enable_memoize to off;
---END---
---START---
explain (costs off)
  select 1 from tenk1
   where (hundred, thousand) in (select twothousand, twothousand from onek);
---END---
---START---
reset enable_memoize;
---END---
---START---

--
-- Hash Aggregation Spill tests
--

set enable_sort=false;
---END---
---START---
set work_mem='64kB';
---END---
---START---

select unique1, count(*), sum(twothousand) from tenk1
group by unique1
having sum(fivethous) > 4975
order by sum(twothousand);
---END---
---START---

set work_mem to default;
---END---
---START---
set enable_sort to default;
---END---
---START---

--
-- Compare results between plans using sorting and plans using hash
-- aggregation. Force spilling in both cases by setting work_mem low.
--

set work_mem='64kB';
---END---
---START---

create table agg_data_2k as
select g from generate_series(0, 1999) g;
---END---
---START---
analyze agg_data_2k;
---END---
---START---

create table agg_data_20k as
select g from generate_series(0, 19999) g;
---END---
---START---
analyze agg_data_20k;
---END---
---START---

-- Produce results with sorting.

set enable_hashagg = false;
---END---
---START---

set jit_above_cost = 0;
---END---
---START---

explain (costs off)
select g%10000 as c1, sum(g::numeric) as c2, count(*) as c3
  from agg_data_20k group by g%10000;
---END---
---START---

create table agg_group_1 as
select g%10000 as c1, sum(g::numeric) as c2, count(*) as c3
  from agg_data_20k group by g%10000;
---END---
---START---

create table agg_group_2 as
select * from
  (values (100), (300), (500)) as r(a),
  lateral (
    select (g/2)::numeric as c1,
           array_agg(g::numeric) as c2,
	   count(*) as c3
    from agg_data_2k
    where g < r.a
    group by g/2) as s;
---END---
---START---

set jit_above_cost to default;
---END---
---START---

create table agg_group_3 as
select (g/2)::numeric as c1, sum(7::int4) as c2, count(*) as c3
  from agg_data_2k group by g/2;
---END---
---START---

create table agg_group_4 as
select (g/2)::numeric as c1, array_agg(g::numeric) as c2, count(*) as c3
  from agg_data_2k group by g/2;
---END---
---START---

-- Produce results with hash aggregation

set enable_hashagg = true;
---END---
---START---
set enable_sort = false;
---END---
---START---

set jit_above_cost = 0;
---END---
---START---

explain (costs off)
select g%10000 as c1, sum(g::numeric) as c2, count(*) as c3
  from agg_data_20k group by g%10000;
---END---
---START---

create table agg_hash_1 as
select g%10000 as c1, sum(g::numeric) as c2, count(*) as c3
  from agg_data_20k group by g%10000;
---END---
---START---

create table agg_hash_2 as
select * from
  (values (100), (300), (500)) as r(a),
  lateral (
    select (g/2)::numeric as c1,
           array_agg(g::numeric) as c2,
	   count(*) as c3
    from agg_data_2k
    where g < r.a
    group by g/2) as s;
---END---
---START---

set jit_above_cost to default;
---END---
---START---

create table agg_hash_3 as
select (g/2)::numeric as c1, sum(7::int4) as c2, count(*) as c3
  from agg_data_2k group by g/2;
---END---
---START---

create table agg_hash_4 as
select (g/2)::numeric as c1, array_agg(g::numeric) as c2, count(*) as c3
  from agg_data_2k group by g/2;
---END---
---START---

set enable_sort = true;
---END---
---START---
set work_mem to default;
---END---
---START---

-- Compare group aggregation results to hash aggregation results

(select * from agg_hash_1 except select * from agg_group_1)
  union all
(select * from agg_group_1 except select * from agg_hash_1);
---END---
---START---

(select * from agg_hash_2 except select * from agg_group_2)
  union all
(select * from agg_group_2 except select * from agg_hash_2);
---END---
---START---

(select * from agg_hash_3 except select * from agg_group_3)
  union all
(select * from agg_group_3 except select * from agg_hash_3);
---END---
---START---

(select * from agg_hash_4 except select * from agg_group_4)
  union all
(select * from agg_group_4 except select * from agg_hash_4);
---END---
---START---

drop table agg_group_1;
---END---
---START---
drop table agg_group_2;
---END---
---START---
drop table agg_group_3;
---END---
---START---
drop table agg_group_4;
---END---
---START---
drop table agg_hash_1;
---END---
---START---
drop table agg_hash_2;
---END---
---START---
drop table agg_hash_3;
---END---
---START---
drop table agg_hash_4;
---END---
