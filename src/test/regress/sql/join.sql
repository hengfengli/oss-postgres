---START---
--
-- JOIN
-- Test JOIN clauses
--

CREATE TABLE J1_TBL (
  i integer,
  j integer,
  t text
);
---END---
---START---

CREATE TABLE J2_TBL (
  i integer,
  k integer
);
---END---
---START---


INSERT INTO J1_TBL VALUES (1, 4, 'one');
---END---
---START---
INSERT INTO J1_TBL VALUES (2, 3, 'two');
---END---
---START---
INSERT INTO J1_TBL VALUES (3, 2, 'three');
---END---
---START---
INSERT INTO J1_TBL VALUES (4, 1, 'four');
---END---
---START---
INSERT INTO J1_TBL VALUES (5, 0, 'five');
---END---
---START---
INSERT INTO J1_TBL VALUES (6, 6, 'six');
---END---
---START---
INSERT INTO J1_TBL VALUES (7, 7, 'seven');
---END---
---START---
INSERT INTO J1_TBL VALUES (8, 8, 'eight');
---END---
---START---
INSERT INTO J1_TBL VALUES (0, NULL, 'zero');
---END---
---START---
INSERT INTO J1_TBL VALUES (NULL, NULL, 'null');
---END---
---START---
INSERT INTO J1_TBL VALUES (NULL, 0, 'zero');
---END---
---START---

INSERT INTO J2_TBL VALUES (1, -1);
---END---
---START---
INSERT INTO J2_TBL VALUES (2, 2);
---END---
---START---
INSERT INTO J2_TBL VALUES (3, -3);
---END---
---START---
INSERT INTO J2_TBL VALUES (2, 4);
---END---
---START---
INSERT INTO J2_TBL VALUES (5, -5);
---END---
---START---
INSERT INTO J2_TBL VALUES (5, -5);
---END---
---START---
INSERT INTO J2_TBL VALUES (0, NULL);
---END---
---START---
INSERT INTO J2_TBL VALUES (NULL, NULL);
---END---
---START---
INSERT INTO J2_TBL VALUES (NULL, 0);
---END---
---START---

-- useful in some tests below
create table onerow();
---END---
---START---
insert into onerow default values;
---END---
---START---
analyze onerow;
---END---
---START---


--
-- CORRELATION NAMES
-- Make sure that table/column aliases are supported
-- before diving into more complex join syntax.
--

SELECT *
  FROM J1_TBL AS tx;
---END---
---START---

SELECT *
  FROM J1_TBL tx;
---END---
---START---

SELECT *
  FROM J1_TBL AS t1 (a, b, c);
---END---
---START---

SELECT *
  FROM J1_TBL t1 (a, b, c);
---END---
---START---

SELECT *
  FROM J1_TBL t1 (a, b, c), J2_TBL t2 (d, e);
---END---
---START---

SELECT t1.a, t2.e
  FROM J1_TBL t1 (a, b, c), J2_TBL t2 (d, e)
  WHERE t1.a = t2.d;
---END---
---START---


--
-- CROSS JOIN
-- Qualifications are not allowed on cross joins,
-- which degenerate into a standard unqualified inner join.
--

SELECT *
  FROM J1_TBL CROSS JOIN J2_TBL;
---END---
---START---

-- ambiguous column
SELECT i, k, t
  FROM J1_TBL CROSS JOIN J2_TBL;
---END---
---START---

-- resolve previous ambiguity by specifying the table name
SELECT t1.i, k, t
  FROM J1_TBL t1 CROSS JOIN J2_TBL t2;
---END---
---START---

SELECT ii, tt, kk
  FROM (J1_TBL CROSS JOIN J2_TBL)
    AS tx (ii, jj, tt, ii2, kk);
---END---
---START---

SELECT tx.ii, tx.jj, tx.kk
  FROM (J1_TBL t1 (a, b, c) CROSS JOIN J2_TBL t2 (d, e))
    AS tx (ii, jj, tt, ii2, kk);
---END---
---START---

SELECT *
  FROM J1_TBL CROSS JOIN J2_TBL a CROSS JOIN J2_TBL b;
---END---
---START---


--
--
-- Inner joins (equi-joins)
--
--

--
-- Inner joins (equi-joins) with USING clause
-- The USING syntax changes the shape of the resulting table
-- by including a column in the USING clause only once in the result.
--

-- Inner equi-join on specified column
SELECT *
  FROM J1_TBL INNER JOIN J2_TBL USING (i);
---END---
---START---

-- Same as above, slightly different syntax
SELECT *
  FROM J1_TBL JOIN J2_TBL USING (i);
---END---
---START---

SELECT *
  FROM J1_TBL t1 (a, b, c) JOIN J2_TBL t2 (a, d) USING (a)
  ORDER BY a, d;
---END---
---START---

SELECT *
  FROM J1_TBL t1 (a, b, c) JOIN J2_TBL t2 (a, b) USING (b)
  ORDER BY b, t1.a;
---END---
---START---

-- test join using aliases
SELECT * FROM J1_TBL JOIN J2_TBL USING (i) WHERE J1_TBL.t = 'one';  -- ok
SELECT * FROM J1_TBL JOIN J2_TBL USING (i) AS x WHERE J1_TBL.t = 'one';  -- ok
SELECT * FROM (J1_TBL JOIN J2_TBL USING (i)) AS x WHERE J1_TBL.t = 'one';  -- error
SELECT * FROM J1_TBL JOIN J2_TBL USING (i) AS x WHERE x.i = 1;  -- ok
SELECT * FROM J1_TBL JOIN J2_TBL USING (i) AS x WHERE x.t = 'one';  -- error
SELECT * FROM (J1_TBL JOIN J2_TBL USING (i) AS x) AS xx WHERE x.i = 1;  -- error (XXX could use better hint)
SELECT * FROM J1_TBL a1 JOIN J2_TBL a2 USING (i) AS a1;  -- error
SELECT x.* FROM J1_TBL JOIN J2_TBL USING (i) AS x WHERE J1_TBL.t = 'one';
---END---
---START---
SELECT ROW(x.*) FROM J1_TBL JOIN J2_TBL USING (i) AS x WHERE J1_TBL.t = 'one';
---END---
---START---
SELECT row_to_json(x.*) FROM J1_TBL JOIN J2_TBL USING (i) AS x WHERE J1_TBL.t = 'one';
---END---
---START---

--
-- NATURAL JOIN
-- Inner equi-join on all columns with the same name
--

SELECT *
  FROM J1_TBL NATURAL JOIN J2_TBL;
---END---
---START---

SELECT *
  FROM J1_TBL t1 (a, b, c) NATURAL JOIN J2_TBL t2 (a, d);
---END---
---START---

SELECT *
  FROM J1_TBL t1 (a, b, c) NATURAL JOIN J2_TBL t2 (d, a);
---END---
---START---

-- mismatch number of columns
-- currently, Postgres will fill in with underlying names
SELECT *
  FROM J1_TBL t1 (a, b) NATURAL JOIN J2_TBL t2 (a);
---END---
---START---


--
-- Inner joins (equi-joins)
--

SELECT *
  FROM J1_TBL JOIN J2_TBL ON (J1_TBL.i = J2_TBL.i);
---END---
---START---

SELECT *
  FROM J1_TBL JOIN J2_TBL ON (J1_TBL.i = J2_TBL.k);
---END---
---START---


--
-- Non-equi-joins
--

SELECT *
  FROM J1_TBL JOIN J2_TBL ON (J1_TBL.i <= J2_TBL.k);
---END---
---START---


--
-- Outer joins
-- Note that OUTER is a noise word
--

SELECT *
  FROM J1_TBL LEFT OUTER JOIN J2_TBL USING (i)
  ORDER BY i, k, t;
---END---
---START---

SELECT *
  FROM J1_TBL LEFT JOIN J2_TBL USING (i)
  ORDER BY i, k, t;
---END---
---START---

SELECT *
  FROM J1_TBL RIGHT OUTER JOIN J2_TBL USING (i);
---END---
---START---

SELECT *
  FROM J1_TBL RIGHT JOIN J2_TBL USING (i);
---END---
---START---

SELECT *
  FROM J1_TBL FULL OUTER JOIN J2_TBL USING (i)
  ORDER BY i, k, t;
---END---
---START---

SELECT *
  FROM J1_TBL FULL JOIN J2_TBL USING (i)
  ORDER BY i, k, t;
---END---
---START---

SELECT *
  FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (k = 1);
---END---
---START---

SELECT *
  FROM J1_TBL LEFT JOIN J2_TBL USING (i) WHERE (i = 1);
---END---
---START---

--
-- semijoin selectivity for <>
--
explain (costs off)
select * from int4_tbl i4, tenk1 a
where exists(select * from tenk1 b
             where a.twothousand = b.twothousand and a.fivethous <> b.fivethous)
      and i4.f1 = a.tenthous;
---END---
---START---


--
-- More complicated constructs
--

--
-- Multiway full join
--

CREATE TABLE t1 (name TEXT, n INTEGER);
---END---
---START---
CREATE TABLE t2 (name TEXT, n INTEGER);
---END---
---START---
CREATE TABLE t3 (name TEXT, n INTEGER);
---END---
---START---

INSERT INTO t1 VALUES ( 'bb', 11 );
---END---
---START---
INSERT INTO t2 VALUES ( 'bb', 12 );
---END---
---START---
INSERT INTO t2 VALUES ( 'cc', 22 );
---END---
---START---
INSERT INTO t2 VALUES ( 'ee', 42 );
---END---
---START---
INSERT INTO t3 VALUES ( 'bb', 13 );
---END---
---START---
INSERT INTO t3 VALUES ( 'cc', 23 );
---END---
---START---
INSERT INTO t3 VALUES ( 'dd', 33 );
---END---
---START---

SELECT * FROM t1 FULL JOIN t2 USING (name) FULL JOIN t3 USING (name);
---END---
---START---

--
-- Test interactions of join syntax and subqueries
--

-- Basic cases (we expect planner to pull up the subquery here)
SELECT * FROM
(SELECT * FROM t2) as s2
INNER JOIN
(SELECT * FROM t3) s3
USING (name);
---END---
---START---

SELECT * FROM
(SELECT * FROM t2) as s2
LEFT JOIN
(SELECT * FROM t3) s3
USING (name);
---END---
---START---

SELECT * FROM
(SELECT * FROM t2) as s2
FULL JOIN
(SELECT * FROM t3) s3
USING (name);
---END---
---START---

-- Cases with non-nullable expressions in subquery results;
---END---
---START---
-- make sure these go to null as expected
SELECT * FROM
(SELECT name, n as s2_n, 2 as s2_2 FROM t2) as s2
NATURAL INNER JOIN
(SELECT name, n as s3_n, 3 as s3_2 FROM t3) s3;
---END---
---START---

SELECT * FROM
(SELECT name, n as s2_n, 2 as s2_2 FROM t2) as s2
NATURAL LEFT JOIN
(SELECT name, n as s3_n, 3 as s3_2 FROM t3) s3;
---END---
---START---

SELECT * FROM
(SELECT name, n as s2_n, 2 as s2_2 FROM t2) as s2
NATURAL FULL JOIN
(SELECT name, n as s3_n, 3 as s3_2 FROM t3) s3;
---END---
---START---

SELECT * FROM
(SELECT name, n as s1_n, 1 as s1_1 FROM t1) as s1
NATURAL INNER JOIN
(SELECT name, n as s2_n, 2 as s2_2 FROM t2) as s2
NATURAL INNER JOIN
(SELECT name, n as s3_n, 3 as s3_2 FROM t3) s3;
---END---
---START---

SELECT * FROM
(SELECT name, n as s1_n, 1 as s1_1 FROM t1) as s1
NATURAL FULL JOIN
(SELECT name, n as s2_n, 2 as s2_2 FROM t2) as s2
NATURAL FULL JOIN
(SELECT name, n as s3_n, 3 as s3_2 FROM t3) s3;
---END---
---START---

SELECT * FROM
(SELECT name, n as s1_n FROM t1) as s1
NATURAL FULL JOIN
  (SELECT * FROM
    (SELECT name, n as s2_n FROM t2) as s2
    NATURAL FULL JOIN
    (SELECT name, n as s3_n FROM t3) as s3
  ) ss2;
---END---
---START---

SELECT * FROM
(SELECT name, n as s1_n FROM t1) as s1
NATURAL FULL JOIN
  (SELECT * FROM
    (SELECT name, n as s2_n, 2 as s2_2 FROM t2) as s2
    NATURAL FULL JOIN
    (SELECT name, n as s3_n FROM t3) as s3
  ) ss2;
---END---
---START---

-- Constants as join keys can also be problematic
SELECT * FROM
  (SELECT name, n as s1_n FROM t1) as s1
FULL JOIN
  (SELECT name, 2 as s2_n FROM t2) as s2
ON (s1_n = s2_n);
---END---
---START---


-- Test for propagation of nullability constraints into sub-joins

create table x (x1 int, x2 int);
---END---
---START---
insert into x values (1,11);
---END---
---START---
insert into x values (2,22);
---END---
---START---
insert into x values (3,null);
---END---
---START---
insert into x values (4,44);
---END---
---START---
insert into x values (5,null);
---END---
---START---

create table y (y1 int, y2 int);
---END---
---START---
insert into y values (1,111);
---END---
---START---
insert into y values (2,222);
---END---
---START---
insert into y values (3,333);
---END---
---START---
insert into y values (4,null);
---END---
---START---

select * from x;
---END---
---START---
select * from y;
---END---
---START---

select * from x left join y on (x1 = y1 and x2 is not null);
---END---
---START---
select * from x left join y on (x1 = y1 and y2 is not null);
---END---
---START---

select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1);
---END---
---START---
select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1 and x2 is not null);
---END---
---START---
select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1 and y2 is not null);
---END---
---START---
select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1 and xx2 is not null);
---END---
---START---
-- these should NOT give the same answers as above
select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1) where (x2 is not null);
---END---
---START---
select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1) where (y2 is not null);
---END---
---START---
select * from (x left join y on (x1 = y1)) left join x xx(xx1,xx2)
on (x1 = xx1) where (xx2 is not null);
---END---
---START---

--
-- regression test: check for bug with propagation of implied equality
-- to outside an IN
--
select count(*) from tenk1 a where unique1 in
  (select unique1 from tenk1 b join tenk1 c using (unique1)
   where b.unique2 = 42);
---END---
---START---

--
-- regression test: check for failure to generate a plan with multiple
-- degenerate IN clauses
--
select count(*) from tenk1 x where
  x.unique1 in (select a.f1 from int4_tbl a,float8_tbl b where a.f1=b.f1) and
  x.unique1 = 0 and
  x.unique1 in (select aa.f1 from int4_tbl aa,float8_tbl bb where aa.f1=bb.f1);
---END---
---START---

-- try that with GEQO too
begin;
---END---
---START---
set geqo = on;
---END---
---START---
set geqo_threshold = 2;
---END---
---START---
select count(*) from tenk1 x where
  x.unique1 in (select a.f1 from int4_tbl a,float8_tbl b where a.f1=b.f1) and
  x.unique1 = 0 and
  x.unique1 in (select aa.f1 from int4_tbl aa,float8_tbl bb where aa.f1=bb.f1);
---END---
---START---
rollback;
---END---
---START---

--
-- regression test: be sure we cope with proven-dummy append rels
--
explain (costs off)
select aa, bb, unique1, unique1
  from tenk1 right join b_star on aa = unique1
  where bb < bb and bb is null;
---END---
---START---

select aa, bb, unique1, unique1
  from tenk1 right join b_star on aa = unique1
  where bb < bb and bb is null;
---END---
---START---

--
-- regression test: check handling of empty-FROM subquery underneath outer join
--
explain (costs off)
select * from int8_tbl i1 left join (int8_tbl i2 join
  (select 123 as x) ss on i2.q1 = x) on i1.q2 = i2.q2
order by 1, 2;
---END---
---START---

select * from int8_tbl i1 left join (int8_tbl i2 join
  (select 123 as x) ss on i2.q1 = x) on i1.q2 = i2.q2
order by 1, 2;
---END---
---START---

--
-- regression test: check a case where join_clause_is_movable_into()
-- used to give an imprecise result, causing an assertion failure
--
select count(*)
from
  (select t3.tenthous as x1, coalesce(t1.stringu1, t2.stringu1) as x2
   from tenk1 t1
   left join tenk1 t2 on t1.unique1 = t2.unique1
   join tenk1 t3 on t1.unique2 = t3.unique2) ss,
  tenk1 t4,
  tenk1 t5
where t4.thousand = t5.unique1 and ss.x1 = t4.tenthous and ss.x2 = t5.stringu1;
---END---
---START---

--
-- regression test: check a case where we formerly missed including an EC
-- enforcement clause because it was expected to be handled at scan level
--
explain (costs off)
select a.f1, b.f1, t.thousand, t.tenthous from
  tenk1 t,
  (select sum(f1)+1 as f1 from int4_tbl i4a) a,
  (select sum(f1) as f1 from int4_tbl i4b) b
where b.f1 = t.thousand and a.f1 = b.f1 and (a.f1+b.f1+999) = t.tenthous;
---END---
---START---

select a.f1, b.f1, t.thousand, t.tenthous from
  tenk1 t,
  (select sum(f1)+1 as f1 from int4_tbl i4a) a,
  (select sum(f1) as f1 from int4_tbl i4b) b
where b.f1 = t.thousand and a.f1 = b.f1 and (a.f1+b.f1+999) = t.tenthous;
---END---
---START---

--
-- checks for correct handling of quals in multiway outer joins
--
explain (costs off)
select t1.f1
from int4_tbl t1, int4_tbl t2
  left join int4_tbl t3 on t3.f1 > 0
  left join int4_tbl t4 on t3.f1 > 1
where t4.f1 is null;
---END---
---START---

select t1.f1
from int4_tbl t1, int4_tbl t2
  left join int4_tbl t3 on t3.f1 > 0
  left join int4_tbl t4 on t3.f1 > 1
where t4.f1 is null;
---END---
---START---

explain (costs off)
select *
from int4_tbl t1 left join int4_tbl t2 on true
  left join int4_tbl t3 on t2.f1 > 0
  left join int4_tbl t4 on t3.f1 > 0;
---END---
---START---

explain (costs off)
select * from onek t1
  left join onek t2 on t1.unique1 = t2.unique1
  left join onek t3 on t2.unique1 != t3.unique1
  left join onek t4 on t3.unique1 = t4.unique1;
---END---
---START---

explain (costs off)
select * from int4_tbl t1
  left join (select now() from int4_tbl t2
             left join int4_tbl t3 on t2.f1 = t3.f1
             left join int4_tbl t4 on t3.f1 = t4.f1) s on true
  inner join int4_tbl t5 on true;
---END---
---START---

explain (costs off)
select * from int4_tbl t1
  left join int4_tbl t2 on true
  left join int4_tbl t3 on true
  left join int4_tbl t4 on t2.f1 = t3.f1;
---END---
---START---

explain (costs off)
select * from int4_tbl t1
  left join int4_tbl t2 on true
  left join int4_tbl t3 on t2.f1 = t3.f1
  left join int4_tbl t4 on t3.f1 != t4.f1;
---END---
---START---

explain (costs off)
select * from int4_tbl t1
  left join (int4_tbl t2 left join int4_tbl t3 on t2.f1 > 0) on t2.f1 > 1
  left join int4_tbl t4 on t2.f1 > 2 and t3.f1 > 3
where t1.f1 = coalesce(t2.f1, 1);
---END---
---START---

explain (costs off)
select * from int4_tbl t1
  left join ((select t2.f1 from int4_tbl t2
                left join int4_tbl t3 on t2.f1 > 0
                where t3.f1 is null) s
             left join tenk1 t4 on s.f1 > 1)
    on s.f1 = t1.f1;
---END---
---START---

explain (costs off)
select * from int4_tbl t1
  left join ((select t2.f1 from int4_tbl t2
                left join int4_tbl t3 on t2.f1 > 0
                where t2.f1 <> coalesce(t3.f1, -1)) s
             left join tenk1 t4 on s.f1 > 1)
    on s.f1 = t1.f1;
---END---
---START---

explain (costs off)
select * from onek t1
    left join onek t2 on t1.unique1 = t2.unique1
    left join onek t3 on t2.unique1 = t3.unique1
    left join onek t4 on t3.unique1 = t4.unique1 and t2.unique2 = t4.unique2;
---END---
---START---

explain (costs off)
select * from int8_tbl t1 left join
    (int8_tbl t2 left join int8_tbl t3 full join int8_tbl t4 on false on false)
    left join int8_tbl t5 on t2.q1 = t5.q1
on t2.q2 = 123;
---END---
---START---

explain (costs off)
select * from int8_tbl t1
    left join int8_tbl t2 on true
    left join lateral
      (select * from int8_tbl t3 where t3.q1 = t2.q1 offset 0) s
      on t2.q1 = 1;
---END---
---START---

explain (costs off)
select * from int8_tbl t1
    left join int8_tbl t2 on true
    left join lateral
      (select * from generate_series(t2.q1, 100)) s
      on t2.q1 = 1;
---END---
---START---

explain (costs off)
select * from int8_tbl t1
    left join int8_tbl t2 on true
    left join lateral
      (select t2.q1 from int8_tbl t3) s
      on t2.q1 = 1;
---END---
---START---

explain (costs off)
select * from onek t1
    left join onek t2 on true
    left join lateral
      (select * from onek t3 where t3.two = t2.two offset 0) s
      on t2.unique1 = 1;
---END---
---START---

--
-- check a case where we formerly got confused by conflicting sort orders
-- in redundant merge join path keys
--
explain (costs off)
select * from
  j1_tbl full join
  (select * from j2_tbl order by j2_tbl.i desc, j2_tbl.k asc) j2_tbl
  on j1_tbl.i = j2_tbl.i and j1_tbl.i = j2_tbl.k;
---END---
---START---

select * from
  j1_tbl full join
  (select * from j2_tbl order by j2_tbl.i desc, j2_tbl.k asc) j2_tbl
  on j1_tbl.i = j2_tbl.i and j1_tbl.i = j2_tbl.k;
---END---
---START---

--
-- a different check for handling of redundant sort keys in merge joins
--
explain (costs off)
select count(*) from
  (select * from tenk1 x order by x.thousand, x.twothousand, x.fivethous) x
  left join
  (select * from tenk1 y order by y.unique2) y
  on x.thousand = y.unique2 and x.twothousand = y.hundred and x.fivethous = y.unique2;
---END---
---START---

select count(*) from
  (select * from tenk1 x order by x.thousand, x.twothousand, x.fivethous) x
  left join
  (select * from tenk1 y order by y.unique2) y
  on x.thousand = y.unique2 and x.twothousand = y.hundred and x.fivethous = y.unique2;
---END---
---START---

set enable_hashjoin = 0;
---END---
---START---
set enable_nestloop = 0;
---END---
---START---
set enable_hashagg = 0;
---END---
---START---

--
-- Check that we use the pathkeys from a prefix of the group by / order by
-- clause for the join pathkeys when that prefix covers all join quals.  We
-- expect this to lead to an incremental sort for the group by / order by.
--
explain (costs off)
select x.thousand, x.twothousand, count(*)
from tenk1 x inner join tenk1 y on x.thousand = y.thousand
group by x.thousand, x.twothousand
order by x.thousand desc, x.twothousand;
---END---
---START---

reset enable_hashagg;
---END---
---START---
reset enable_nestloop;
---END---
---START---
reset enable_hashjoin;
---END---
---START---

--
-- Clean up
--

DROP TABLE t1;
---END---
---START---
DROP TABLE t2;
---END---
---START---
DROP TABLE t3;
---END---
---START---

DROP TABLE J1_TBL;
---END---
---START---
DROP TABLE J2_TBL;
---END---
---START---

-- Both DELETE and UPDATE allow the specification of additional tables
-- to "join" against to determine which rows should be modified.

CREATE TABLE t1 (a int, b int);
---END---
---START---
CREATE TABLE t2 (a int, b int);
---END---
---START---
CREATE TABLE t3 (x int, y int);
---END---
---START---

INSERT INTO t1 VALUES (5, 10);
---END---
---START---
INSERT INTO t1 VALUES (15, 20);
---END---
---START---
INSERT INTO t1 VALUES (100, 100);
---END---
---START---
INSERT INTO t1 VALUES (200, 1000);
---END---
---START---
INSERT INTO t2 VALUES (200, 2000);
---END---
---START---
INSERT INTO t3 VALUES (5, 20);
---END---
---START---
INSERT INTO t3 VALUES (6, 7);
---END---
---START---
INSERT INTO t3 VALUES (7, 8);
---END---
---START---
INSERT INTO t3 VALUES (500, 100);
---END---
---START---

DELETE FROM t3 USING t1 table1 WHERE t3.x = table1.a;
---END---
---START---
SELECT * FROM t3;
---END---
---START---
DELETE FROM t3 USING t1 JOIN t2 USING (a) WHERE t3.x > t1.a;
---END---
---START---
SELECT * FROM t3;
---END---
---START---
DELETE FROM t3 USING t3 t3_other WHERE t3.x = t3_other.x AND t3.y = t3_other.y;
---END---
---START---
SELECT * FROM t3;
---END---
---START---

-- Test join against inheritance tree

create table t2a () inherits (t2);
---END---
---START---

insert into t2a values (200, 2001);
---END---
---START---

select * from t1 left join t2 on (t1.a = t2.a);
---END---
---START---

-- Test matching of column name with wrong alias

select t1.x from t1 join t3 on (t1.a = t3.x);
---END---
---START---

-- Test matching of locking clause with wrong alias

select t1.*, t2.*, unnamed_join.* from
  t1 join t2 on (t1.a = t2.a), t3 as unnamed_join
  for update of unnamed_join;
---END---
---START---

select foo.*, unnamed_join.* from
  t1 join t2 using (a) as foo, t3 as unnamed_join
  for update of unnamed_join;
---END---
---START---

select foo.*, unnamed_join.* from
  t1 join t2 using (a) as foo, t3 as unnamed_join
  for update of foo;
---END---
---START---

select bar.*, unnamed_join.* from
  (t1 join t2 using (a) as foo) as bar, t3 as unnamed_join
  for update of foo;
---END---
---START---

select bar.*, unnamed_join.* from
  (t1 join t2 using (a) as foo) as bar, t3 as unnamed_join
  for update of bar;
---END---
---START---

--
-- regression test for 8.1 merge right join bug
--

CREATE TABLE tt1 ( tt1_id int4, joincol int4 );
---END---
---START---
INSERT INTO tt1 VALUES (1, 11);
---END---
---START---
INSERT INTO tt1 VALUES (2, NULL);
---END---
---START---

CREATE TABLE tt2 ( tt2_id int4, joincol int4 );
---END---
---START---
INSERT INTO tt2 VALUES (21, 11);
---END---
---START---
INSERT INTO tt2 VALUES (22, 11);
---END---
---START---

set enable_hashjoin to off;
---END---
---START---
set enable_nestloop to off;
---END---
---START---

-- these should give the same results

select tt1.*, tt2.* from tt1 left join tt2 on tt1.joincol = tt2.joincol;
---END---
---START---

select tt1.*, tt2.* from tt2 right join tt1 on tt1.joincol = tt2.joincol;
---END---
---START---

reset enable_hashjoin;
---END---
---START---
reset enable_nestloop;
---END---
---START---

--
-- regression test for bug #13908 (hash join with skew tuples & nbatch increase)
--

set work_mem to '64kB';
---END---
---START---
set enable_mergejoin to off;
---END---
---START---
set enable_memoize to off;
---END---
---START---

explain (costs off)
select count(*) from tenk1 a, tenk1 b
  where a.hundred = b.thousand and (b.fivethous % 10) < 10;
---END---
---START---
select count(*) from tenk1 a, tenk1 b
  where a.hundred = b.thousand and (b.fivethous % 10) < 10;
---END---
---START---

reset work_mem;
---END---
---START---
reset enable_mergejoin;
---END---
---START---
reset enable_memoize;
---END---
---START---

--
-- regression test for 8.2 bug with improper re-ordering of left joins
--

create table tt3(f1 int, f2 text);
---END---
---START---
insert into tt3 select x, repeat('xyzzy', 100) from generate_series(1,10000) x;
---END---
---START---
analyze tt3;
---END---
---START---

create table tt4(f1 int);
---END---
---START---
insert into tt4 values (0),(1),(9999);
---END---
---START---
analyze tt4;
---END---
---START---

set enable_nestloop to off;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT a.f1
FROM tt4 a
LEFT JOIN (
        SELECT b.f1
        FROM tt3 b LEFT JOIN tt3 c ON (b.f1 = c.f1)
        WHERE COALESCE(c.f1, 0) = 0
) AS d ON (a.f1 = d.f1)
WHERE COALESCE(d.f1, 0) = 0
ORDER BY 1;
---END---
---START---

SELECT a.f1
FROM tt4 a
LEFT JOIN (
        SELECT b.f1
        FROM tt3 b LEFT JOIN tt3 c ON (b.f1 = c.f1)
        WHERE COALESCE(c.f1, 0) = 0
) AS d ON (a.f1 = d.f1)
WHERE COALESCE(d.f1, 0) = 0
ORDER BY 1;
---END---
---START---

reset enable_nestloop;
---END---
---START---

--
-- basic semijoin and antijoin recognition tests
--

explain (costs off)
select a.* from tenk1 a
where unique1 in (select unique2 from tenk1 b);
---END---
---START---

-- sadly, this is not an antijoin
explain (costs off)
select a.* from tenk1 a
where unique1 not in (select unique2 from tenk1 b);
---END---
---START---

explain (costs off)
select a.* from tenk1 a
where exists (select 1 from tenk1 b where a.unique1 = b.unique2);
---END---
---START---

explain (costs off)
select a.* from tenk1 a
where not exists (select 1 from tenk1 b where a.unique1 = b.unique2);
---END---
---START---

explain (costs off)
select a.* from tenk1 a left join tenk1 b on a.unique1 = b.unique2
where b.unique2 is null;
---END---
---START---

--
-- regression test for proper handling of outer joins within antijoins
--

create table tt4x(c1 int, c2 int, c3 int);
---END---
---START---

explain (costs off)
select * from tt4x t1
where not exists (
  select 1 from tt4x t2
    left join tt4x t3 on t2.c3 = t3.c1
    left join ( select t5.c1 as c1
                from tt4x t4 left join tt4x t5 on t4.c2 = t5.c1
              ) a1 on t3.c2 = a1.c1
  where t1.c1 = t2.c2
);
---END---
---START---

--
-- regression test for problems of the sort depicted in bug #3494
--

create table tt5(f1 int, f2 int);
---END---
---START---
create table tt6(f1 int, f2 int);
---END---
---START---

insert into tt5 values(1, 10);
---END---
---START---
insert into tt5 values(1, 11);
---END---
---START---

insert into tt6 values(1, 9);
---END---
---START---
insert into tt6 values(1, 2);
---END---
---START---
insert into tt6 values(2, 9);
---END---
---START---

select * from tt5,tt6 where tt5.f1 = tt6.f1 and tt5.f1 = tt5.f2 - tt6.f2;
---END---
---START---

--
-- regression test for problems of the sort depicted in bug #3588
--

create table xx (pkxx int);
---END---
---START---
create table yy (pkyy int, pkxx int);
---END---
---START---

insert into xx values (1);
---END---
---START---
insert into xx values (2);
---END---
---START---
insert into xx values (3);
---END---
---START---

insert into yy values (101, 1);
---END---
---START---
insert into yy values (201, 2);
---END---
---START---
insert into yy values (301, NULL);
---END---
---START---

select yy.pkyy as yy_pkyy, yy.pkxx as yy_pkxx, yya.pkyy as yya_pkyy,
       xxa.pkxx as xxa_pkxx, xxb.pkxx as xxb_pkxx
from yy
     left join (SELECT * FROM yy where pkyy = 101) as yya ON yy.pkyy = yya.pkyy
     left join xx xxa on yya.pkxx = xxa.pkxx
     left join xx xxb on coalesce (xxa.pkxx, 1) = xxb.pkxx;
---END---
---START---

--
-- regression test for improper pushing of constants across outer-join clauses
-- (as seen in early 8.2.x releases)
--

create table zt1 (f1 int primary key);
---END---
---START---
create table zt2 (f2 int primary key);
---END---
---START---
create table zt3 (f3 int primary key);
---END---
---START---
insert into zt1 values(53);
---END---
---START---
insert into zt2 values(53);
---END---
---START---

select * from
  zt2 left join zt3 on (f2 = f3)
      left join zt1 on (f3 = f1)
where f2 = 53;
---END---
---START---

create temp view zv1 as select *,'dummy'::text AS junk from zt1;
---END---
---START---

select * from
  zt2 left join zt3 on (f2 = f3)
      left join zv1 on (f3 = f1)
where f2 = 53;
---END---
---START---

--
-- regression test for improper extraction of OR indexqual conditions
-- (as seen in early 8.3.x releases)
--

select a.unique2, a.ten, b.tenthous, b.unique2, b.hundred
from tenk1 a left join tenk1 b on a.unique2 = b.tenthous
where a.unique1 = 42 and
      ((b.unique2 is null and a.ten = 2) or b.hundred = 3);
---END---
---START---

--
-- test proper positioning of one-time quals in EXISTS (8.4devel bug)
--
prepare foo(bool) as
  select count(*) from tenk1 a left join tenk1 b
    on (a.unique2 = b.unique1 and exists
        (select 1 from tenk1 c where c.thousand = b.unique2 and $1));
---END---
---START---
execute foo(true);
---END---
---START---
execute foo(false);
---END---
---START---

--
-- test for sane behavior with noncanonical merge clauses, per bug #4926
--

begin;
---END---
---START---

set enable_mergejoin = 1;
---END---
---START---
set enable_hashjoin = 0;
---END---
---START---
set enable_nestloop = 0;
---END---
---START---

create table a (i integer);
---END---
---START---
create table b (x integer, y integer);
---END---
---START---

select * from a left join b on i = x and i = y and x = i;
---END---
---START---

rollback;
---END---
---START---

--
-- test handling of merge clauses using record_ops
--
begin;
---END---
---START---

create type mycomptype as (id int, v bigint);
---END---
---START---

create table tidv (idv mycomptype);
---END---
---START---
create index on tidv (idv);
---END---
---START---

explain (costs off)
select a.idv, b.idv from tidv a, tidv b where a.idv = b.idv;
---END---
---START---

set enable_mergejoin = 0;
---END---
---START---
set enable_hashjoin = 0;
---END---
---START---

explain (costs off)
select a.idv, b.idv from tidv a, tidv b where a.idv = b.idv;
---END---
---START---

rollback;
---END---
---START---

--
-- test NULL behavior of whole-row Vars, per bug #5025
--
select t1.q2, count(t2.*)
from int8_tbl t1 left join int8_tbl t2 on (t1.q2 = t2.q1)
group by t1.q2 order by 1;
---END---
---START---

select t1.q2, count(t2.*)
from int8_tbl t1 left join (select * from int8_tbl) t2 on (t1.q2 = t2.q1)
group by t1.q2 order by 1;
---END---
---START---

select t1.q2, count(t2.*)
from int8_tbl t1 left join (select * from int8_tbl offset 0) t2 on (t1.q2 = t2.q1)
group by t1.q2 order by 1;
---END---
---START---

select t1.q2, count(t2.*)
from int8_tbl t1 left join
  (select q1, case when q2=1 then 1 else q2 end as q2 from int8_tbl) t2
  on (t1.q2 = t2.q1)
group by t1.q2 order by 1;
---END---
---START---

--
-- test incorrect failure to NULL pulled-up subexpressions
--
begin;
---END---
---START---

create table a (
     code char not null,
     constraint a_pk primary key (code)
);
---END---
---START---
create table b (
     a char not null,
     num integer not null,
     constraint b_pk primary key (a, num)
);
---END---
---START---
create table c (
     name char not null,
     a char,
     constraint c_pk primary key (name)
);
---END---
---START---

insert into a (code) values ('p');
---END---
---START---
insert into a (code) values ('q');
---END---
---START---
insert into b (a, num) values ('p', 1);
---END---
---START---
insert into b (a, num) values ('p', 2);
---END---
---START---
insert into c (name, a) values ('A', 'p');
---END---
---START---
insert into c (name, a) values ('B', 'q');
---END---
---START---
insert into c (name, a) values ('C', null);
---END---
---START---

select c.name, ss.code, ss.b_cnt, ss.const
from c left join
  (select a.code, coalesce(b_grp.cnt, 0) as b_cnt, -1 as const
   from a left join
     (select count(1) as cnt, b.a from b group by b.a) as b_grp
     on a.code = b_grp.a
  ) as ss
  on (c.a = ss.code)
order by c.name;
---END---
---START---

rollback;
---END---
---START---

--
-- test incorrect handling of placeholders that only appear in targetlists,
-- per bug #6154
--
SELECT * FROM
( SELECT 1 as key1 ) sub1
LEFT JOIN
( SELECT sub3.key3, sub4.value2, COALESCE(sub4.value2, 66) as value3 FROM
    ( SELECT 1 as key3 ) sub3
    LEFT JOIN
    ( SELECT sub5.key5, COALESCE(sub6.value1, 1) as value2 FROM
        ( SELECT 1 as key5 ) sub5
        LEFT JOIN
        ( SELECT 2 as key6, 42 as value1 ) sub6
        ON sub5.key5 = sub6.key6
    ) sub4
    ON sub4.key5 = sub3.key3
) sub2
ON sub1.key1 = sub2.key3;
---END---
---START---

-- test the path using join aliases, too
SELECT * FROM
( SELECT 1 as key1 ) sub1
LEFT JOIN
( SELECT sub3.key3, value2, COALESCE(value2, 66) as value3 FROM
    ( SELECT 1 as key3 ) sub3
    LEFT JOIN
    ( SELECT sub5.key5, COALESCE(sub6.value1, 1) as value2 FROM
        ( SELECT 1 as key5 ) sub5
        LEFT JOIN
        ( SELECT 2 as key6, 42 as value1 ) sub6
        ON sub5.key5 = sub6.key6
    ) sub4
    ON sub4.key5 = sub3.key3
) sub2
ON sub1.key1 = sub2.key3;
---END---
---START---

--
-- test case where a PlaceHolderVar is used as a nestloop parameter
--

EXPLAIN (COSTS OFF)
SELECT qq, unique1
  FROM
  ( SELECT COALESCE(q1, 0) AS qq FROM int8_tbl a ) AS ss1
  FULL OUTER JOIN
  ( SELECT COALESCE(q2, -1) AS qq FROM int8_tbl b ) AS ss2
  USING (qq)
  INNER JOIN tenk1 c ON qq = unique2;
---END---
---START---

SELECT qq, unique1
  FROM
  ( SELECT COALESCE(q1, 0) AS qq FROM int8_tbl a ) AS ss1
  FULL OUTER JOIN
  ( SELECT COALESCE(q2, -1) AS qq FROM int8_tbl b ) AS ss2
  USING (qq)
  INNER JOIN tenk1 c ON qq = unique2;
---END---
---START---

--
-- nested nestloops can require nested PlaceHolderVars
--

create table nt1 (
  id int primary key,
  a1 boolean,
  a2 boolean
);
---END---
---START---
create table nt2 (
  id int primary key,
  nt1_id int,
  b1 boolean,
  b2 boolean,
  foreign key (nt1_id) references nt1(id)
);
---END---
---START---
create table nt3 (
  id int primary key,
  nt2_id int,
  c1 boolean,
  foreign key (nt2_id) references nt2(id)
);
---END---
---START---

insert into nt1 values (1,true,true);
---END---
---START---
insert into nt1 values (2,true,false);
---END---
---START---
insert into nt1 values (3,false,false);
---END---
---START---
insert into nt2 values (1,1,true,true);
---END---
---START---
insert into nt2 values (2,2,true,false);
---END---
---START---
insert into nt2 values (3,3,false,false);
---END---
---START---
insert into nt3 values (1,1,true);
---END---
---START---
insert into nt3 values (2,2,false);
---END---
---START---
insert into nt3 values (3,3,true);
---END---
---START---

explain (costs off)
select nt3.id
from nt3 as nt3
  left join
    (select nt2.*, (nt2.b1 and ss1.a3) AS b3
     from nt2 as nt2
       left join
         (select nt1.*, (nt1.id is not null) as a3 from nt1) as ss1
         on ss1.id = nt2.nt1_id
    ) as ss2
    on ss2.id = nt3.nt2_id
where nt3.id = 1 and ss2.b3;
---END---
---START---

select nt3.id
from nt3 as nt3
  left join
    (select nt2.*, (nt2.b1 and ss1.a3) AS b3
     from nt2 as nt2
       left join
         (select nt1.*, (nt1.id is not null) as a3 from nt1) as ss1
         on ss1.id = nt2.nt1_id
    ) as ss2
    on ss2.id = nt3.nt2_id
where nt3.id = 1 and ss2.b3;
---END---
---START---

--
-- test case where a PlaceHolderVar is propagated into a subquery
--

explain (costs off)
select * from
  int8_tbl t1 left join
  (select q1 as x, 42 as y from int8_tbl t2) ss
  on t1.q2 = ss.x
where
  1 = (select 1 from int8_tbl t3 where ss.y is not null limit 1)
order by 1,2;
---END---
---START---

select * from
  int8_tbl t1 left join
  (select q1 as x, 42 as y from int8_tbl t2) ss
  on t1.q2 = ss.x
where
  1 = (select 1 from int8_tbl t3 where ss.y is not null limit 1)
order by 1,2;
---END---
---START---

--
-- variant where a PlaceHolderVar is needed at a join, but not above the join
--

explain (costs off)
select * from
  int4_tbl as i41,
  lateral
    (select 1 as x from
      (select i41.f1 as lat,
              i42.f1 as loc from
         int8_tbl as i81, int4_tbl as i42) as ss1
      right join int4_tbl as i43 on (i43.f1 > 1)
      where ss1.loc = ss1.lat) as ss2
where i41.f1 > 0;
---END---
---START---

select * from
  int4_tbl as i41,
  lateral
    (select 1 as x from
      (select i41.f1 as lat,
              i42.f1 as loc from
         int8_tbl as i81, int4_tbl as i42) as ss1
      right join int4_tbl as i43 on (i43.f1 > 1)
      where ss1.loc = ss1.lat) as ss2
where i41.f1 > 0;
---END---
---START---

--
-- test the corner cases FULL JOIN ON TRUE and FULL JOIN ON FALSE
--
select * from int4_tbl a full join int4_tbl b on true;
---END---
---START---
select * from int4_tbl a full join int4_tbl b on false;
---END---
---START---

--
-- test for ability to use a cartesian join when necessary
--

create table q1 as select 1 as q1;
---END---
---START---
create table q2 as select 0 as q2;
---END---
---START---
analyze q1;
---END---
---START---
analyze q2;
---END---
---START---

explain (costs off)
select * from
  tenk1 join int4_tbl on f1 = twothousand,
  q1, q2
where q1 = thousand or q2 = thousand;
---END---
---START---

explain (costs off)
select * from
  tenk1 join int4_tbl on f1 = twothousand,
  q1, q2
where thousand = (q1 + q2);
---END---
---START---

--
-- test ability to generate a suitable plan for a star-schema query
--

explain (costs off)
select * from
  tenk1, int8_tbl a, int8_tbl b
where thousand = a.q1 and tenthous = b.q1 and a.q2 = 1 and b.q2 = 2;
---END---
---START---

--
-- test a corner case in which we shouldn't apply the star-schema optimization
--

explain (costs off)
select t1.unique2, t1.stringu1, t2.unique1, t2.stringu2 from
  tenk1 t1
  inner join int4_tbl i1
    left join (select v1.x2, v2.y1, 11 AS d1
               from (select 1,0 from onerow) v1(x1,x2)
               left join (select 3,1 from onerow) v2(y1,y2)
               on v1.x1 = v2.y2) subq1
    on (i1.f1 = subq1.x2)
  on (t1.unique2 = subq1.d1)
  left join tenk1 t2
  on (subq1.y1 = t2.unique1)
where t1.unique2 < 42 and t1.stringu1 > t2.stringu2;
---END---
---START---

select t1.unique2, t1.stringu1, t2.unique1, t2.stringu2 from
  tenk1 t1
  inner join int4_tbl i1
    left join (select v1.x2, v2.y1, 11 AS d1
               from (select 1,0 from onerow) v1(x1,x2)
               left join (select 3,1 from onerow) v2(y1,y2)
               on v1.x1 = v2.y2) subq1
    on (i1.f1 = subq1.x2)
  on (t1.unique2 = subq1.d1)
  left join tenk1 t2
  on (subq1.y1 = t2.unique1)
where t1.unique2 < 42 and t1.stringu1 > t2.stringu2;
---END---
---START---

-- variant that isn't quite a star-schema case

select ss1.d1 from
  tenk1 as t1
  inner join tenk1 as t2
  on t1.tenthous = t2.ten
  inner join
    int8_tbl as i8
    left join int4_tbl as i4
      inner join (select 64::information_schema.cardinal_number as d1
                  from tenk1 t3,
                       lateral (select abs(t3.unique1) + random()) ss0(x)
                  where t3.fivethous < 0) as ss1
      on i4.f1 = ss1.d1
    on i8.q1 = i4.f1
  on t1.tenthous = ss1.d1
where t1.unique1 < i4.f1;
---END---
---START---

-- this variant is foldable by the remove-useless-RESULT-RTEs code

explain (costs off)
select t1.unique2, t1.stringu1, t2.unique1, t2.stringu2 from
  tenk1 t1
  inner join int4_tbl i1
    left join (select v1.x2, v2.y1, 11 AS d1
               from (values(1,0)) v1(x1,x2)
               left join (values(3,1)) v2(y1,y2)
               on v1.x1 = v2.y2) subq1
    on (i1.f1 = subq1.x2)
  on (t1.unique2 = subq1.d1)
  left join tenk1 t2
  on (subq1.y1 = t2.unique1)
where t1.unique2 < 42 and t1.stringu1 > t2.stringu2;
---END---
---START---

select t1.unique2, t1.stringu1, t2.unique1, t2.stringu2 from
  tenk1 t1
  inner join int4_tbl i1
    left join (select v1.x2, v2.y1, 11 AS d1
               from (values(1,0)) v1(x1,x2)
               left join (values(3,1)) v2(y1,y2)
               on v1.x1 = v2.y2) subq1
    on (i1.f1 = subq1.x2)
  on (t1.unique2 = subq1.d1)
  left join tenk1 t2
  on (subq1.y1 = t2.unique1)
where t1.unique2 < 42 and t1.stringu1 > t2.stringu2;
---END---
---START---

-- Here's a variant that we can't fold too aggressively, though,
-- or we end up with noplace to evaluate the lateral PHV
explain (verbose, costs off)
select * from
  (select 1 as x) ss1 left join (select 2 as y) ss2 on (true),
  lateral (select ss2.y as z limit 1) ss3;
---END---
---START---
select * from
  (select 1 as x) ss1 left join (select 2 as y) ss2 on (true),
  lateral (select ss2.y as z limit 1) ss3;
---END---
---START---

-- Test proper handling of appendrel PHVs during useless-RTE removal
explain (costs off)
select * from
  (select 0 as z) as t1
  left join
  (select true as a) as t2
  on true,
  lateral (select true as b
           union all
           select a as b) as t3
where b;
---END---
---START---

select * from
  (select 0 as z) as t1
  left join
  (select true as a) as t2
  on true,
  lateral (select true as b
           union all
           select a as b) as t3
where b;
---END---
---START---

-- Test PHV in a semijoin qual, which confused useless-RTE removal (bug #17700)
explain (verbose, costs off)
with ctetable as not materialized ( select 1 as f1 )
select * from ctetable c1
where f1 in ( select c3.f1 from ctetable c2 full join ctetable c3 on true );
---END---
---START---

with ctetable as not materialized ( select 1 as f1 )
select * from ctetable c1
where f1 in ( select c3.f1 from ctetable c2 full join ctetable c3 on true );
---END---
---START---

-- Test PHV that winds up in a Result node, despite having nonempty nullingrels
explain (verbose, costs off)
select table_catalog, table_name
from int4_tbl t1
  inner join (int8_tbl t2
              left join information_schema.column_udt_usage on null)
  on null;
---END---
---START---

-- Test handling of qual pushdown to appendrel members with non-Var outputs
explain (verbose, costs off)
select * from int4_tbl left join (
  select text 'foo' union all select text 'bar'
) ss(x) on true
where ss.x is null;
---END---
---START---

--
-- test inlining of immutable functions
--
create function f_immutable_int4(i integer) returns integer as
$$ begin return i; end; $$ language plpgsql immutable;
---END---
---START---

-- check optimization of function scan with join
explain (costs off)
select unique1 from tenk1, (select * from f_immutable_int4(1) x) x
where x = unique1;
---END---
---START---

explain (verbose, costs off)
select unique1, x.*
from tenk1, (select *, random() from f_immutable_int4(1) x) x
where x = unique1;
---END---
---START---

explain (costs off)
select unique1 from tenk1, f_immutable_int4(1) x where x = unique1;
---END---
---START---

explain (costs off)
select unique1 from tenk1, lateral f_immutable_int4(1) x where x = unique1;
---END---
---START---

explain (costs off)
select unique1 from tenk1, lateral f_immutable_int4(1) x where x in (select 17);
---END---
---START---

explain (costs off)
select unique1, x from tenk1 join f_immutable_int4(1) x on unique1 = x;
---END---
---START---

explain (costs off)
select unique1, x from tenk1 left join f_immutable_int4(1) x on unique1 = x;
---END---
---START---

explain (costs off)
select unique1, x from tenk1 right join f_immutable_int4(1) x on unique1 = x;
---END---
---START---

explain (costs off)
select unique1, x from tenk1 full join f_immutable_int4(1) x on unique1 = x;
---END---
---START---

-- check that pullup of a const function allows further const-folding
explain (costs off)
select unique1 from tenk1, f_immutable_int4(1) x where x = 42;
---END---
---START---

-- test inlining of immutable functions with PlaceHolderVars
explain (costs off)
select nt3.id
from nt3 as nt3
  left join
    (select nt2.*, (nt2.b1 or i4 = 42) AS b3
     from nt2 as nt2
       left join
         f_immutable_int4(0) i4
         on i4 = nt2.nt1_id
    ) as ss2
    on ss2.id = nt3.nt2_id
where nt3.id = 1 and ss2.b3;
---END---
---START---

drop function f_immutable_int4(int);
---END---
---START---

-- test inlining when function returns composite

create function mki8(bigint, bigint) returns int8_tbl as
$$select row($1,$2)::int8_tbl$$ language sql;
---END---
---START---

create function mki4(int) returns int4_tbl as
$$select row($1)::int4_tbl$$ language sql;
---END---
---START---

explain (verbose, costs off)
select * from mki8(1,2);
---END---
---START---
select * from mki8(1,2);
---END---
---START---

explain (verbose, costs off)
select * from mki4(42);
---END---
---START---
select * from mki4(42);
---END---
---START---

drop function mki8(bigint, bigint);
---END---
---START---
drop function mki4(int);
---END---
---START---

--
-- test extraction of restriction OR clauses from join OR clause
-- (we used to only do this for indexable clauses)
--

explain (costs off)
select * from tenk1 a join tenk1 b on
  (a.unique1 = 1 and b.unique1 = 2) or (a.unique2 = 3 and b.hundred = 4);
---END---
---START---
explain (costs off)
select * from tenk1 a join tenk1 b on
  (a.unique1 = 1 and b.unique1 = 2) or (a.unique2 = 3 and b.ten = 4);
---END---
---START---
explain (costs off)
select * from tenk1 a join tenk1 b on
  (a.unique1 = 1 and b.unique1 = 2) or
  ((a.unique2 = 3 or a.unique2 = 7) and b.hundred = 4);
---END---
---START---

--
-- test placement of movable quals in a parameterized join tree
--

explain (costs off)
select * from tenk1 t1 left join
  (tenk1 t2 join tenk1 t3 on t2.thousand = t3.unique2)
  on t1.hundred = t2.hundred and t1.ten = t3.ten
where t1.unique1 = 1;
---END---
---START---

explain (costs off)
select * from tenk1 t1 left join
  (tenk1 t2 join tenk1 t3 on t2.thousand = t3.unique2)
  on t1.hundred = t2.hundred and t1.ten + t2.ten = t3.ten
where t1.unique1 = 1;
---END---
---START---

explain (costs off)
select count(*) from
  tenk1 a join tenk1 b on a.unique1 = b.unique2
  left join tenk1 c on a.unique2 = b.unique1 and c.thousand = a.thousand
  join int4_tbl on b.thousand = f1;
---END---
---START---

select count(*) from
  tenk1 a join tenk1 b on a.unique1 = b.unique2
  left join tenk1 c on a.unique2 = b.unique1 and c.thousand = a.thousand
  join int4_tbl on b.thousand = f1;
---END---
---START---

explain (costs off)
select b.unique1 from
  tenk1 a join tenk1 b on a.unique1 = b.unique2
  left join tenk1 c on b.unique1 = 42 and c.thousand = a.thousand
  join int4_tbl i1 on b.thousand = f1
  right join int4_tbl i2 on i2.f1 = b.tenthous
  order by 1;
---END---
---START---

select b.unique1 from
  tenk1 a join tenk1 b on a.unique1 = b.unique2
  left join tenk1 c on b.unique1 = 42 and c.thousand = a.thousand
  join int4_tbl i1 on b.thousand = f1
  right join int4_tbl i2 on i2.f1 = b.tenthous
  order by 1;
---END---
---START---

explain (costs off)
select * from
(
  select unique1, q1, coalesce(unique1, -1) + q1 as fault
  from int8_tbl left join tenk1 on (q2 = unique2)
) ss
where fault = 122
order by fault;
---END---
---START---

select * from
(
  select unique1, q1, coalesce(unique1, -1) + q1 as fault
  from int8_tbl left join tenk1 on (q2 = unique2)
) ss
where fault = 122
order by fault;
---END---
---START---

explain (costs off)
select * from
(values (1, array[10,20]), (2, array[20,30])) as v1(v1x,v1ys)
left join (values (1, 10), (2, 20)) as v2(v2x,v2y) on v2x = v1x
left join unnest(v1ys) as u1(u1y) on u1y = v2y;
---END---
---START---

select * from
(values (1, array[10,20]), (2, array[20,30])) as v1(v1x,v1ys)
left join (values (1, 10), (2, 20)) as v2(v2x,v2y) on v2x = v1x
left join unnest(v1ys) as u1(u1y) on u1y = v2y;
---END---
---START---

--
-- test handling of potential equivalence clauses above outer joins
--

explain (costs off)
select q1, unique2, thousand, hundred
  from int8_tbl a left join tenk1 b on q1 = unique2
  where coalesce(thousand,123) = q1 and q1 = coalesce(hundred,123);
---END---
---START---

select q1, unique2, thousand, hundred
  from int8_tbl a left join tenk1 b on q1 = unique2
  where coalesce(thousand,123) = q1 and q1 = coalesce(hundred,123);
---END---
---START---

explain (costs off)
select f1, unique2, case when unique2 is null then f1 else 0 end
  from int4_tbl a left join tenk1 b on f1 = unique2
  where (case when unique2 is null then f1 else 0 end) = 0;
---END---
---START---

select f1, unique2, case when unique2 is null then f1 else 0 end
  from int4_tbl a left join tenk1 b on f1 = unique2
  where (case when unique2 is null then f1 else 0 end) = 0;
---END---
---START---

--
-- another case with equivalence clauses above outer joins (bug #8591)
--

explain (costs off)
select a.unique1, b.unique1, c.unique1, coalesce(b.twothousand, a.twothousand)
  from tenk1 a left join tenk1 b on b.thousand = a.unique1                        left join tenk1 c on c.unique2 = coalesce(b.twothousand, a.twothousand)
  where a.unique2 < 10 and coalesce(b.twothousand, a.twothousand) = 44;
---END---
---START---

select a.unique1, b.unique1, c.unique1, coalesce(b.twothousand, a.twothousand)
  from tenk1 a left join tenk1 b on b.thousand = a.unique1                        left join tenk1 c on c.unique2 = coalesce(b.twothousand, a.twothousand)
  where a.unique2 < 10 and coalesce(b.twothousand, a.twothousand) = 44;
---END---
---START---

-- related case

explain (costs off)
select * from int8_tbl t1 left join int8_tbl t2 on t1.q2 = t2.q1,
  lateral (select * from int8_tbl t3 where t2.q1 = t2.q2) ss;
---END---
---START---

select * from int8_tbl t1 left join int8_tbl t2 on t1.q2 = t2.q1,
  lateral (select * from int8_tbl t3 where t2.q1 = t2.q2) ss;
---END---
---START---

--
-- check handling of join aliases when flattening multiple levels of subquery
--

explain (verbose, costs off)
select foo1.join_key as foo1_id, foo3.join_key AS foo3_id, bug_field from
  (values (0),(1)) foo1(join_key)
left join
  (select join_key, bug_field from
    (select ss1.join_key, ss1.bug_field from
      (select f1 as join_key, 666 as bug_field from int4_tbl i1) ss1
    ) foo2
   left join
    (select unique2 as join_key from tenk1 i2) ss2
   using (join_key)
  ) foo3
using (join_key);
---END---
---START---

select foo1.join_key as foo1_id, foo3.join_key AS foo3_id, bug_field from
  (values (0),(1)) foo1(join_key)
left join
  (select join_key, bug_field from
    (select ss1.join_key, ss1.bug_field from
      (select f1 as join_key, 666 as bug_field from int4_tbl i1) ss1
    ) foo2
   left join
    (select unique2 as join_key from tenk1 i2) ss2
   using (join_key)
  ) foo3
using (join_key);
---END---
---START---

--
-- check handling of a variable-free join alias
--
explain (verbose, costs off)
select * from
int4_tbl i0 left join
( (select *, 123 as x from int4_tbl i1) ss1
  left join
  (select *, q2 as x from int8_tbl i2) ss2
  using (x)
) ss0
on (i0.f1 = ss0.f1)
order by i0.f1, x;
---END---
---START---

select * from
int4_tbl i0 left join
( (select *, 123 as x from int4_tbl i1) ss1
  left join
  (select *, q2 as x from int8_tbl i2) ss2
  using (x)
) ss0
on (i0.f1 = ss0.f1)
order by i0.f1, x;
---END---
---START---

--
-- test successful handling of nested outer joins with degenerate join quals
--

explain (verbose, costs off)
select t1.* from
  text_tbl t1
  left join (select *, '***'::text as d1 from int8_tbl i8b1) b1
    left join int8_tbl i8
      left join (select *, null::int as d2 from int8_tbl i8b2) b2
      on (i8.q1 = b2.q1)
    on (b2.d2 = b1.q2)
  on (t1.f1 = b1.d1)
  left join int4_tbl i4
  on (i8.q2 = i4.f1);
---END---
---START---

select t1.* from
  text_tbl t1
  left join (select *, '***'::text as d1 from int8_tbl i8b1) b1
    left join int8_tbl i8
      left join (select *, null::int as d2 from int8_tbl i8b2) b2
      on (i8.q1 = b2.q1)
    on (b2.d2 = b1.q2)
  on (t1.f1 = b1.d1)
  left join int4_tbl i4
  on (i8.q2 = i4.f1);
---END---
---START---

explain (verbose, costs off)
select t1.* from
  text_tbl t1
  left join (select *, '***'::text as d1 from int8_tbl i8b1) b1
    left join int8_tbl i8
      left join (select *, null::int as d2 from int8_tbl i8b2, int4_tbl i4b2) b2
      on (i8.q1 = b2.q1)
    on (b2.d2 = b1.q2)
  on (t1.f1 = b1.d1)
  left join int4_tbl i4
  on (i8.q2 = i4.f1);
---END---
---START---

select t1.* from
  text_tbl t1
  left join (select *, '***'::text as d1 from int8_tbl i8b1) b1
    left join int8_tbl i8
      left join (select *, null::int as d2 from int8_tbl i8b2, int4_tbl i4b2) b2
      on (i8.q1 = b2.q1)
    on (b2.d2 = b1.q2)
  on (t1.f1 = b1.d1)
  left join int4_tbl i4
  on (i8.q2 = i4.f1);
---END---
---START---

explain (verbose, costs off)
select t1.* from
  text_tbl t1
  left join (select *, '***'::text as d1 from int8_tbl i8b1) b1
    left join int8_tbl i8
      left join (select *, null::int as d2 from int8_tbl i8b2, int4_tbl i4b2
                 where q1 = f1) b2
      on (i8.q1 = b2.q1)
    on (b2.d2 = b1.q2)
  on (t1.f1 = b1.d1)
  left join int4_tbl i4
  on (i8.q2 = i4.f1);
---END---
---START---

select t1.* from
  text_tbl t1
  left join (select *, '***'::text as d1 from int8_tbl i8b1) b1
    left join int8_tbl i8
      left join (select *, null::int as d2 from int8_tbl i8b2, int4_tbl i4b2
                 where q1 = f1) b2
      on (i8.q1 = b2.q1)
    on (b2.d2 = b1.q2)
  on (t1.f1 = b1.d1)
  left join int4_tbl i4
  on (i8.q2 = i4.f1);
---END---
---START---

explain (verbose, costs off)
select * from
  text_tbl t1
  inner join int8_tbl i8
  on i8.q2 = 456
  right join text_tbl t2
  on t1.f1 = 'doh!'
  left join int4_tbl i4
  on i8.q1 = i4.f1;
---END---
---START---

select * from
  text_tbl t1
  inner join int8_tbl i8
  on i8.q2 = 456
  right join text_tbl t2
  on t1.f1 = 'doh!'
  left join int4_tbl i4
  on i8.q1 = i4.f1;
---END---
---START---

-- check handling of a variable-free qual for a non-commutable outer join
explain (costs off)
select nspname
from (select 1 as x) ss1
left join
( select n.nspname, c.relname
  from pg_class c left join pg_namespace n on n.oid = c.relnamespace
  where c.relkind = 'r'
) ss2 on false;
---END---
---START---

-- check handling of apparently-commutable outer joins with non-commutable
-- joins between them
explain (costs off)
select 1 from
  int4_tbl i4
  left join int8_tbl i8 on i4.f1 is not null
  left join (select 1 as a) ss1 on null
  join int4_tbl i42 on ss1.a is null or i8.q1 <> i8.q2
  right join (select 2 as b) ss2
  on ss2.b < i4.f1;
---END---
---START---

--
-- test for appropriate join order in the presence of lateral references
--

explain (verbose, costs off)
select * from
  text_tbl t1
  left join int8_tbl i8
  on i8.q2 = 123,
  lateral (select i8.q1, t2.f1 from text_tbl t2 limit 1) as ss
where t1.f1 = ss.f1;
---END---
---START---

select * from
  text_tbl t1
  left join int8_tbl i8
  on i8.q2 = 123,
  lateral (select i8.q1, t2.f1 from text_tbl t2 limit 1) as ss
where t1.f1 = ss.f1;
---END---
---START---

explain (verbose, costs off)
select * from
  text_tbl t1
  left join int8_tbl i8
  on i8.q2 = 123,
  lateral (select i8.q1, t2.f1 from text_tbl t2 limit 1) as ss1,
  lateral (select ss1.* from text_tbl t3 limit 1) as ss2
where t1.f1 = ss2.f1;
---END---
---START---

select * from
  text_tbl t1
  left join int8_tbl i8
  on i8.q2 = 123,
  lateral (select i8.q1, t2.f1 from text_tbl t2 limit 1) as ss1,
  lateral (select ss1.* from text_tbl t3 limit 1) as ss2
where t1.f1 = ss2.f1;
---END---
---START---

explain (verbose, costs off)
select 1 from
  text_tbl as tt1
  inner join text_tbl as tt2 on (tt1.f1 = 'foo')
  left join text_tbl as tt3 on (tt3.f1 = 'foo')
  left join text_tbl as tt4 on (tt3.f1 = tt4.f1),
  lateral (select tt4.f1 as c0 from text_tbl as tt5 limit 1) as ss1
where tt1.f1 = ss1.c0;
---END---
---START---

select 1 from
  text_tbl as tt1
  inner join text_tbl as tt2 on (tt1.f1 = 'foo')
  left join text_tbl as tt3 on (tt3.f1 = 'foo')
  left join text_tbl as tt4 on (tt3.f1 = tt4.f1),
  lateral (select tt4.f1 as c0 from text_tbl as tt5 limit 1) as ss1
where tt1.f1 = ss1.c0;
---END---
---START---

explain (verbose, costs off)
select 1 from
  int4_tbl as i4
  inner join
    ((select 42 as n from int4_tbl x1 left join int8_tbl x2 on f1 = q1) as ss1
     right join (select 1 as z) as ss2 on true)
  on false,
  lateral (select i4.f1, ss1.n from int8_tbl as i8 limit 1) as ss3;
---END---
---START---

select 1 from
  int4_tbl as i4
  inner join
    ((select 42 as n from int4_tbl x1 left join int8_tbl x2 on f1 = q1) as ss1
     right join (select 1 as z) as ss2 on true)
  on false,
  lateral (select i4.f1, ss1.n from int8_tbl as i8 limit 1) as ss3;
---END---
---START---

--
-- check a case where we formerly generated invalid parameterized paths
--

begin;
---END---
---START---

create table t (a int unique);
---END---
---START---

explain (costs off)
select 1 from t t1
  join lateral (select t1.a from (select 1) foo offset 0) as s1 on true
  join
    (select 1 from t t2
       inner join (t t3
                   left join (t t4 left join t t5 on t4.a = 1)
                   on t3.a = t4.a)
       on false
     where t3.a = coalesce(t5.a,1)) as s2
  on true;
---END---
---START---

rollback;
---END---
---START---

--
-- check a case in which a PlaceHolderVar forces join order
--

explain (verbose, costs off)
select ss2.* from
  int4_tbl i41
  left join int8_tbl i8
    join (select i42.f1 as c1, i43.f1 as c2, 42 as c3
          from int4_tbl i42, int4_tbl i43) ss1
    on i8.q1 = ss1.c2
  on i41.f1 = ss1.c1,
  lateral (select i41.*, i8.*, ss1.* from text_tbl limit 1) ss2
where ss1.c2 = 0;
---END---
---START---

select ss2.* from
  int4_tbl i41
  left join int8_tbl i8
    join (select i42.f1 as c1, i43.f1 as c2, 42 as c3
          from int4_tbl i42, int4_tbl i43) ss1
    on i8.q1 = ss1.c2
  on i41.f1 = ss1.c1,
  lateral (select i41.*, i8.*, ss1.* from text_tbl limit 1) ss2
where ss1.c2 = 0;
---END---
---START---

--
-- test successful handling of full join underneath left join (bug #14105)
--

explain (costs off)
select * from
  (select 1 as id) as xx
  left join
    (tenk1 as a1 full join (select 1 as id) as yy on (a1.unique1 = yy.id))
  on (xx.id = coalesce(yy.id));
---END---
---START---

select * from
  (select 1 as id) as xx
  left join
    (tenk1 as a1 full join (select 1 as id) as yy on (a1.unique1 = yy.id))
  on (xx.id = coalesce(yy.id));
---END---
---START---

--
-- test ability to push constants through outer join clauses
--

explain (costs off)
  select * from int4_tbl a left join tenk1 b on f1 = unique2 where f1 = 0;
---END---
---START---

explain (costs off)
  select * from tenk1 a full join tenk1 b using(unique2) where unique2 = 42;
---END---
---START---

--
-- test that quals attached to an outer join have correct semantics,
-- specifically that they don't re-use expressions computed below the join;
---END---
---START---
-- we force a mergejoin so that coalesce(b.q1, 1) appears as a join input
--

set enable_hashjoin to off;
---END---
---START---
set enable_nestloop to off;
---END---
---START---

explain (verbose, costs off)
  select a.q2, b.q1
    from int8_tbl a left join int8_tbl b on a.q2 = coalesce(b.q1, 1)
    where coalesce(b.q1, 1) > 0;
---END---
---START---
select a.q2, b.q1
  from int8_tbl a left join int8_tbl b on a.q2 = coalesce(b.q1, 1)
  where coalesce(b.q1, 1) > 0;
---END---
---START---

reset enable_hashjoin;
---END---
---START---
reset enable_nestloop;
---END---
---START---

--
-- test join strength reduction with a SubPlan providing the proof
--

explain (costs off)
select a.unique1, b.unique2
  from onek a left join onek b on a.unique1 = b.unique2
  where b.unique2 = any (select q1 from int8_tbl c where c.q1 < b.unique1);
---END---
---START---

select a.unique1, b.unique2
  from onek a left join onek b on a.unique1 = b.unique2
  where b.unique2 = any (select q1 from int8_tbl c where c.q1 < b.unique1);
---END---
---START---

--
-- test full-join strength reduction
--

explain (costs off)
select a.unique1, b.unique2
  from onek a full join onek b on a.unique1 = b.unique2
  where a.unique1 = 42;
---END---
---START---

select a.unique1, b.unique2
  from onek a full join onek b on a.unique1 = b.unique2
  where a.unique1 = 42;
---END---
---START---

explain (costs off)
select a.unique1, b.unique2
  from onek a full join onek b on a.unique1 = b.unique2
  where b.unique2 = 43;
---END---
---START---

select a.unique1, b.unique2
  from onek a full join onek b on a.unique1 = b.unique2
  where b.unique2 = 43;
---END---
---START---

explain (costs off)
select a.unique1, b.unique2
  from onek a full join onek b on a.unique1 = b.unique2
  where a.unique1 = 42 and b.unique2 = 42;
---END---
---START---

select a.unique1, b.unique2
  from onek a full join onek b on a.unique1 = b.unique2
  where a.unique1 = 42 and b.unique2 = 42;
---END---
---START---

--
-- test result-RTE removal underneath a full join
--

explain (costs off)
select * from
  (select * from int8_tbl i81 join (values(123,2)) v(v1,v2) on q2=v1) ss1
full join
  (select * from (values(456,2)) w(v1,v2) join int8_tbl i82 on q2=v1) ss2
on true;
---END---
---START---

select * from
  (select * from int8_tbl i81 join (values(123,2)) v(v1,v2) on q2=v1) ss1
full join
  (select * from (values(456,2)) w(v1,v2) join int8_tbl i82 on q2=v1) ss2
on true;
---END---
---START---

--
-- test join removal
--

begin;
---END---
---START---

CREATE TABLE a (id int PRIMARY KEY, b_id int);
---END---
---START---
CREATE TABLE b (id int PRIMARY KEY, c_id int);
---END---
---START---
CREATE TABLE c (id int PRIMARY KEY);
---END---
---START---
CREATE TABLE d (a int, b int);
---END---
---START---
INSERT INTO a VALUES (0, 0), (1, NULL);
---END---
---START---
INSERT INTO b VALUES (0, 0), (1, NULL);
---END---
---START---
INSERT INTO c VALUES (0), (1);
---END---
---START---
INSERT INTO d VALUES (1,3), (2,2), (3,1);
---END---
---START---

-- all three cases should be optimizable into a simple seqscan
explain (costs off) SELECT a.* FROM a LEFT JOIN b ON a.b_id = b.id;
---END---
---START---
explain (costs off) SELECT b.* FROM b LEFT JOIN c ON b.c_id = c.id;
---END---
---START---
explain (costs off)
  SELECT a.* FROM a LEFT JOIN (b left join c on b.c_id = c.id)
  ON (a.b_id = b.id);
---END---
---START---

-- check optimization of outer join within another special join
explain (costs off)
select id from a where id in (
	select b.id from b left join c on b.id = c.id
);
---END---
---START---

-- check optimization with oddly-nested outer joins
explain (costs off)
select a1.id from
  (a a1 left join a a2 on true)
  left join
  (a a3 left join a a4 on a3.id = a4.id)
  on a2.id = a3.id;
---END---
---START---

explain (costs off)
select a1.id from
  (a a1 left join a a2 on a1.id = a2.id)
  left join
  (a a3 left join a a4 on a3.id = a4.id)
  on a2.id = a3.id;
---END---
---START---

explain (costs off)
select 1 from a t1
    left join a t2 on true
   inner join a t3 on true
    left join a t4 on t2.id = t4.id and t2.id = t3.id;
---END---
---START---

-- another example (bug #17781)
explain (costs off)
select ss1.f1
from int4_tbl as t1
  left join (int4_tbl as t2
             right join int4_tbl as t3 on null
             left join (int4_tbl as t4
                        right join int8_tbl as t5 on null)
               on t2.f1 = t4.f1
             left join ((select null as f1 from int4_tbl as t6) as ss1
                        inner join int8_tbl as t7 on null)
               on t5.q1 = t7.q2)
    on false;
---END---
---START---

-- variant with Var rather than PHV coming from t6
explain (costs off)
select ss1.f1
from int4_tbl as t1
  left join (int4_tbl as t2
             right join int4_tbl as t3 on null
             left join (int4_tbl as t4
                        right join int8_tbl as t5 on null)
               on t2.f1 = t4.f1
             left join ((select f1 from int4_tbl as t6) as ss1
                        inner join int8_tbl as t7 on null)
               on t5.q1 = t7.q2)
    on false;
---END---
---START---

-- per further discussion of bug #17781
explain (costs off)
select ss1.x
from (select f1/2 as x from int4_tbl i4 left join a on a.id = i4.f1) ss1
     right join int8_tbl i8 on true
where current_user is not null;  -- this is to add a Result node

-- and further discussion of bug #17781
explain (costs off)
select *
from int8_tbl t1
  left join (int8_tbl t2 left join onek t3 on t2.q1 > t3.unique1)
    on t1.q2 = t2.q2
  left join onek t4
    on t2.q2 < t3.unique2;
---END---
---START---

-- More tests of correct placement of pseudoconstant quals

-- simple constant-false condition
explain (costs off)
select * from int8_tbl t1 left join
  (int8_tbl t2 inner join int8_tbl t3 on false
   left join int8_tbl t4 on t2.q2 = t4.q2)
on t1.q1 = t2.q1;
---END---
---START---

-- deduce constant-false from an EquivalenceClass
explain (costs off)
select * from int8_tbl t1 left join
  (int8_tbl t2 inner join int8_tbl t3 on (t2.q1-t3.q2) = 0 and (t2.q1-t3.q2) = 1
   left join int8_tbl t4 on t2.q2 = t4.q2)
on t1.q1 = t2.q1;
---END---
---START---

-- pseudoconstant based on an outer-level Param
explain (costs off)
select exists(
  select * from int8_tbl t1 left join
    (int8_tbl t2 inner join int8_tbl t3 on x0.f1 = 1
     left join int8_tbl t4 on t2.q2 = t4.q2)
  on t1.q1 = t2.q1
) from int4_tbl x0;
---END---
---START---

-- check that join removal works for a left join when joining a subquery
-- that is guaranteed to be unique by its GROUP BY clause
explain (costs off)
select d.* from d left join (select * from b group by b.id, b.c_id) s
  on d.a = s.id and d.b = s.c_id;
---END---
---START---

-- similarly, but keying off a DISTINCT clause
explain (costs off)
select d.* from d left join (select distinct * from b) s
  on d.a = s.id and d.b = s.c_id;
---END---
---START---

-- join removal is not possible when the GROUP BY contains a column that is
-- not in the join condition.  (Note: as of 9.6, we notice that b.id is a
-- primary key and so drop b.c_id from the GROUP BY of the resulting plan;
---END---
---START---
-- but this happens too late for join removal in the outer plan level.)
explain (costs off)
select d.* from d left join (select * from b group by b.id, b.c_id) s
  on d.a = s.id;
---END---
---START---

-- similarly, but keying off a DISTINCT clause
explain (costs off)
select d.* from d left join (select distinct * from b) s
  on d.a = s.id;
---END---
---START---

-- join removal is not possible here
explain (costs off)
select 1 from a t1
  left join (a t2 left join a t3 on t2.id = 1) on t2.id = 1;
---END---
---START---

-- check join removal works when uniqueness of the join condition is enforced
-- by a UNION
explain (costs off)
select d.* from d left join (select id from a union select id from b) s
  on d.a = s.id;
---END---
---START---

-- check join removal with a cross-type comparison operator
explain (costs off)
select i8.* from int8_tbl i8 left join (select f1 from int4_tbl group by f1) i4
  on i8.q1 = i4.f1;
---END---
---START---

-- check join removal with lateral references
explain (costs off)
select 1 from (select a.id FROM a left join b on a.b_id = b.id) q,
			  lateral generate_series(1, q.id) gs(i) where q.id = gs.i;
---END---
---START---

-- check join removal within RHS of an outer join
explain (costs off)
select c.id, ss.a from c
  left join (select d.a from onerow, d left join b on d.a = b.id) ss
  on c.id = ss.a;
---END---
---START---

CREATE TABLE parted_b (id int PRIMARY KEY) partition by range(id);
---END---
---START---
CREATE TABLE parted_b1 partition of parted_b for values from (0) to (10);
---END---
---START---

-- test join removals on a partitioned table
explain (costs off)
select a.* from a left join parted_b pb on a.b_id = pb.id;
---END---
---START---

rollback;
---END---
---START---

create table parent (k int primary key, pd int);
---END---
---START---
create table child (k int unique, cd int);
---END---
---START---
insert into parent values (1, 10), (2, 20), (3, 30);
---END---
---START---
insert into child values (1, 100), (4, 400);
---END---
---START---

-- this case is optimizable
select p.* from parent p left join child c on (p.k = c.k);
---END---
---START---
explain (costs off)
  select p.* from parent p left join child c on (p.k = c.k);
---END---
---START---

-- this case is not
select p.*, linked from parent p
  left join (select c.*, true as linked from child c) as ss
  on (p.k = ss.k);
---END---
---START---
explain (costs off)
  select p.*, linked from parent p
    left join (select c.*, true as linked from child c) as ss
    on (p.k = ss.k);
---END---
---START---

-- check for a 9.0rc1 bug: join removal breaks pseudoconstant qual handling
select p.* from
  parent p left join child c on (p.k = c.k)
  where p.k = 1 and p.k = 2;
---END---
---START---
explain (costs off)
select p.* from
  parent p left join child c on (p.k = c.k)
  where p.k = 1 and p.k = 2;
---END---
---START---

select p.* from
  (parent p left join child c on (p.k = c.k)) join parent x on p.k = x.k
  where p.k = 1 and p.k = 2;
---END---
---START---
explain (costs off)
select p.* from
  (parent p left join child c on (p.k = c.k)) join parent x on p.k = x.k
  where p.k = 1 and p.k = 2;
---END---
---START---

-- bug 5255: this is not optimizable by join removal
begin;
---END---
---START---

CREATE TABLE a (id int PRIMARY KEY);
---END---
---START---
CREATE TABLE b (id int PRIMARY KEY, a_id int);
---END---
---START---
INSERT INTO a VALUES (0), (1);
---END---
---START---
INSERT INTO b VALUES (0, 0), (1, NULL);
---END---
---START---

SELECT * FROM b LEFT JOIN a ON (b.a_id = a.id) WHERE (a.id IS NULL OR a.id > 0);
---END---
---START---
SELECT b.* FROM b LEFT JOIN a ON (b.a_id = a.id) WHERE (a.id IS NULL OR a.id > 0);
---END---
---START---

rollback;
---END---
---START---

-- another join removal bug: this is not optimizable, either
begin;
---END---
---START---

create table innertab (id int8 primary key, dat1 int8);
---END---
---START---
insert into innertab values(123, 42);
---END---
---START---

SELECT * FROM
    (SELECT 1 AS x) ss1
  LEFT JOIN
    (SELECT q1, q2, COALESCE(dat1, q1) AS y
     FROM int8_tbl LEFT JOIN innertab ON q2 = id) ss2
  ON true;
---END---
---START---

-- join removal bug #17769: can't remove if there's a pushed-down reference
EXPLAIN (COSTS OFF)
SELECT q2 FROM
  (SELECT *
   FROM int8_tbl LEFT JOIN innertab ON q2 = id) ss
 WHERE COALESCE(dat1, 0) = q1;
---END---
---START---

-- join removal bug #17773: otherwise-removable PHV appears in a qual condition
EXPLAIN (VERBOSE, COSTS OFF)
SELECT q2 FROM
  (SELECT q2, 'constant'::text AS x
   FROM int8_tbl LEFT JOIN innertab ON q2 = id) ss
  RIGHT JOIN int4_tbl ON NULL
 WHERE x >= x;
---END---
---START---

-- join removal bug #17786: check that OR conditions are cleaned up
EXPLAIN (COSTS OFF)
SELECT f1, x
FROM int4_tbl
     JOIN ((SELECT 42 AS x FROM int8_tbl LEFT JOIN innertab ON q1 = id) AS ss1
           RIGHT JOIN tenk1 ON NULL)
        ON tenk1.unique1 = ss1.x OR tenk1.unique2 = ss1.x;
---END---
---START---

rollback;
---END---
---START---

-- another join removal bug: we must clean up correctly when removing a PHV
begin;
---END---
---START---

create table uniquetbl (f1 text unique);
---END---
---START---

explain (costs off)
select t1.* from
  uniquetbl as t1
  left join (select *, '***'::text as d1 from uniquetbl) t2
  on t1.f1 = t2.f1
  left join uniquetbl t3
  on t2.d1 = t3.f1;
---END---
---START---

explain (costs off)
select t0.*
from
 text_tbl t0
 left join
   (select case t1.ten when 0 then 'doh!'::text else null::text end as case1,
           t1.stringu2
     from tenk1 t1
     join int4_tbl i4 ON i4.f1 = t1.unique2
     left join uniquetbl u1 ON u1.f1 = t1.string4) ss
  on t0.f1 = ss.case1
where ss.stringu2 !~* ss.case1;
---END---
---START---

select t0.*
from
 text_tbl t0
 left join
   (select case t1.ten when 0 then 'doh!'::text else null::text end as case1,
           t1.stringu2
     from tenk1 t1
     join int4_tbl i4 ON i4.f1 = t1.unique2
     left join uniquetbl u1 ON u1.f1 = t1.string4) ss
  on t0.f1 = ss.case1
where ss.stringu2 !~* ss.case1;
---END---
---START---

rollback;
---END---
---START---

-- another join removal bug: we must clean up EquivalenceClasses too
begin;
---END---
---START---

create table t (a int unique);
---END---
---START---
insert into t values (1);
---END---
---START---

explain (costs off)
select 1
from t t1
  left join (select 2 as c
             from t t2 left join t t3 on t2.a = t3.a) s
    on true
where t1.a = s.c;
---END---
---START---

select 1
from t t1
  left join (select 2 as c
             from t t2 left join t t3 on t2.a = t3.a) s
    on true
where t1.a = s.c;
---END---
---START---

rollback;
---END---
---START---

-- test cases where we can remove a join, but not a PHV computed at it
begin;
---END---
---START---

create table t (a int unique, b int);
---END---
---START---
insert into t values (1,1), (2,2);
---END---
---START---

explain (costs off)
select 1
from t t1
  left join (select t2.a, 1 as c
             from t t2 left join t t3 on t2.a = t3.a) s
  on true
  left join t t4 on true
where s.a < s.c;
---END---
---START---

explain (costs off)
select t1.a, s.*
from t t1
  left join lateral (select t2.a, coalesce(t1.a, 1) as c
                     from t t2 left join t t3 on t2.a = t3.a) s
  on true
  left join t t4 on true
where s.a < s.c;
---END---
---START---

select t1.a, s.*
from t t1
  left join lateral (select t2.a, coalesce(t1.a, 1) as c
                     from t t2 left join t t3 on t2.a = t3.a) s
  on true
  left join t t4 on true
where s.a < s.c;
---END---
---START---

rollback;
---END---
---START---

-- test case to expose miscomputation of required relid set for a PHV
explain (verbose, costs off)
select i8.*, ss.v, t.unique2
  from int8_tbl i8
    left join int4_tbl i4 on i4.f1 = 1
    left join lateral (select i4.f1 + 1 as v) as ss on true
    left join tenk1 t on t.unique2 = ss.v
where q2 = 456;
---END---
---START---

select i8.*, ss.v, t.unique2
  from int8_tbl i8
    left join int4_tbl i4 on i4.f1 = 1
    left join lateral (select i4.f1 + 1 as v) as ss on true
    left join tenk1 t on t.unique2 = ss.v
where q2 = 456;
---END---
---START---

-- and check a related issue where we miscompute required relids for
-- a PHV that's been translated to a child rel
create table parttbl (a integer primary key) partition by range (a);
---END---
---START---
create table parttbl1 partition of parttbl for values from (1) to (100);
---END---
---START---
insert into parttbl values (11), (12);
---END---
---START---
explain (costs off)
select * from
  (select *, 12 as phv from parttbl) as ss
  right join int4_tbl on true
where ss.a = ss.phv and f1 = 0;
---END---
---START---

select * from
  (select *, 12 as phv from parttbl) as ss
  right join int4_tbl on true
where ss.a = ss.phv and f1 = 0;
---END---
---START---

-- bug #8444: we've historically allowed duplicate aliases within aliased JOINs

select * from
  int8_tbl x join (int4_tbl x cross join int4_tbl y) j on q1 = f1; -- error
select * from
  int8_tbl x join (int4_tbl x cross join int4_tbl y) j on q1 = y.f1; -- error
select * from
  int8_tbl x join (int4_tbl x cross join int4_tbl y(ff)) j on q1 = f1; -- ok

--
-- Test hints given on incorrect column references are useful
--

select t1.uunique1 from
  tenk1 t1 join tenk2 t2 on t1.two = t2.two; -- error, prefer "t1" suggestion
select t2.uunique1 from
  tenk1 t1 join tenk2 t2 on t1.two = t2.two; -- error, prefer "t2" suggestion
select uunique1 from
  tenk1 t1 join tenk2 t2 on t1.two = t2.two; -- error, suggest both at once
select ctid from
  tenk1 t1 join tenk2 t2 on t1.two = t2.two; -- error, need qualification

--
-- Take care to reference the correct RTE
--

select atts.relid::regclass, s.* from pg_stats s join
    pg_attribute a on s.attname = a.attname and s.tablename =
    a.attrelid::regclass::text join (select unnest(indkey) attnum,
    indexrelid from pg_index i) atts on atts.attnum = a.attnum where
    schemaname != 'pg_catalog';
---END---
---START---

-- Test bug in rangetable flattening
explain (verbose, costs off)
select 1 from
  (select * from int8_tbl where q1 <> (select 42) offset 0) ss
where false;
---END---
---START---

--
-- Test LATERAL
--

select unique2, x.*
from tenk1 a, lateral (select * from int4_tbl b where f1 = a.unique1) x;
---END---
---START---
explain (costs off)
  select unique2, x.*
  from tenk1 a, lateral (select * from int4_tbl b where f1 = a.unique1) x;
---END---
---START---
select unique2, x.*
from int4_tbl x, lateral (select unique2 from tenk1 where f1 = unique1) ss;
---END---
---START---
explain (costs off)
  select unique2, x.*
  from int4_tbl x, lateral (select unique2 from tenk1 where f1 = unique1) ss;
---END---
---START---
explain (costs off)
  select unique2, x.*
  from int4_tbl x cross join lateral (select unique2 from tenk1 where f1 = unique1) ss;
---END---
---START---
select unique2, x.*
from int4_tbl x left join lateral (select unique1, unique2 from tenk1 where f1 = unique1) ss on true;
---END---
---START---
explain (costs off)
  select unique2, x.*
  from int4_tbl x left join lateral (select unique1, unique2 from tenk1 where f1 = unique1) ss on true;
---END---
---START---

-- check scoping of lateral versus parent references
-- the first of these should return int8_tbl.q2, the second int8_tbl.q1
select *, (select r from (select q1 as q2) x, (select q2 as r) y) from int8_tbl;
---END---
---START---
select *, (select r from (select q1 as q2) x, lateral (select q2 as r) y) from int8_tbl;
---END---
---START---

-- lateral with function in FROM
select count(*) from tenk1 a, lateral generate_series(1,two) g;
---END---
---START---
explain (costs off)
  select count(*) from tenk1 a, lateral generate_series(1,two) g;
---END---
---START---
explain (costs off)
  select count(*) from tenk1 a cross join lateral generate_series(1,two) g;
---END---
---START---
-- don't need the explicit LATERAL keyword for functions
explain (costs off)
  select count(*) from tenk1 a, generate_series(1,two) g;
---END---
---START---

-- lateral with UNION ALL subselect
explain (costs off)
  select * from generate_series(100,200) g,
    lateral (select * from int8_tbl a where g = q1 union all
             select * from int8_tbl b where g = q2) ss;
---END---
---START---
select * from generate_series(100,200) g,
  lateral (select * from int8_tbl a where g = q1 union all
           select * from int8_tbl b where g = q2) ss;
---END---
---START---

-- lateral with VALUES
explain (costs off)
  select count(*) from tenk1 a,
    tenk1 b join lateral (values(a.unique1)) ss(x) on b.unique2 = ss.x;
---END---
---START---
select count(*) from tenk1 a,
  tenk1 b join lateral (values(a.unique1)) ss(x) on b.unique2 = ss.x;
---END---
---START---

-- lateral with VALUES, no flattening possible
explain (costs off)
  select count(*) from tenk1 a,
    tenk1 b join lateral (values(a.unique1),(-1)) ss(x) on b.unique2 = ss.x;
---END---
---START---
select count(*) from tenk1 a,
  tenk1 b join lateral (values(a.unique1),(-1)) ss(x) on b.unique2 = ss.x;
---END---
---START---

-- lateral injecting a strange outer join condition
explain (costs off)
  select * from int8_tbl a,
    int8_tbl x left join lateral (select a.q1 from int4_tbl y) ss(z)
      on x.q2 = ss.z
  order by a.q1, a.q2, x.q1, x.q2, ss.z;
---END---
---START---
select * from int8_tbl a,
  int8_tbl x left join lateral (select a.q1 from int4_tbl y) ss(z)
    on x.q2 = ss.z
  order by a.q1, a.q2, x.q1, x.q2, ss.z;
---END---
---START---

-- lateral reference to a join alias variable
select * from (select f1/2 as x from int4_tbl) ss1 join int4_tbl i4 on x = f1,
  lateral (select x) ss2(y);
---END---
---START---
select * from (select f1 as x from int4_tbl) ss1 join int4_tbl i4 on x = f1,
  lateral (values(x)) ss2(y);
---END---
---START---
select * from ((select f1/2 as x from int4_tbl) ss1 join int4_tbl i4 on x = f1) j,
  lateral (select x) ss2(y);
---END---
---START---

-- lateral references requiring pullup
select * from (values(1)) x(lb),
  lateral generate_series(lb,4) x4;
---END---
---START---
select * from (select f1/1000000000 from int4_tbl) x(lb),
  lateral generate_series(lb,4) x4;
---END---
---START---
select * from (values(1)) x(lb),
  lateral (values(lb)) y(lbcopy);
---END---
---START---
select * from (values(1)) x(lb),
  lateral (select lb from int4_tbl) y(lbcopy);
---END---
---START---
select * from
  int8_tbl x left join (select q1,coalesce(q2,0) q2 from int8_tbl) y on x.q2 = y.q1,
  lateral (values(x.q1,y.q1,y.q2)) v(xq1,yq1,yq2);
---END---
---START---
select * from
  int8_tbl x left join (select q1,coalesce(q2,0) q2 from int8_tbl) y on x.q2 = y.q1,
  lateral (select x.q1,y.q1,y.q2) v(xq1,yq1,yq2);
---END---
---START---
select x.* from
  int8_tbl x left join (select q1,coalesce(q2,0) q2 from int8_tbl) y on x.q2 = y.q1,
  lateral (select x.q1,y.q1,y.q2) v(xq1,yq1,yq2);
---END---
---START---
select v.* from
  (int8_tbl x left join (select q1,coalesce(q2,0) q2 from int8_tbl) y on x.q2 = y.q1)
  left join int4_tbl z on z.f1 = x.q2,
  lateral (select x.q1,y.q1 union all select x.q2,y.q2) v(vx,vy);
---END---
---START---
select v.* from
  (int8_tbl x left join (select q1,(select coalesce(q2,0)) q2 from int8_tbl) y on x.q2 = y.q1)
  left join int4_tbl z on z.f1 = x.q2,
  lateral (select x.q1,y.q1 union all select x.q2,y.q2) v(vx,vy);
---END---
---START---
select v.* from
  (int8_tbl x left join (select q1,(select coalesce(q2,0)) q2 from int8_tbl) y on x.q2 = y.q1)
  left join int4_tbl z on z.f1 = x.q2,
  lateral (select x.q1,y.q1 from onerow union all select x.q2,y.q2 from onerow) v(vx,vy);
---END---
---START---

explain (verbose, costs off)
select * from
  int8_tbl a left join
  lateral (select *, a.q2 as x from int8_tbl b) ss on a.q2 = ss.q1;
---END---
---START---
select * from
  int8_tbl a left join
  lateral (select *, a.q2 as x from int8_tbl b) ss on a.q2 = ss.q1;
---END---
---START---
explain (verbose, costs off)
select * from
  int8_tbl a left join
  lateral (select *, coalesce(a.q2, 42) as x from int8_tbl b) ss on a.q2 = ss.q1;
---END---
---START---
select * from
  int8_tbl a left join
  lateral (select *, coalesce(a.q2, 42) as x from int8_tbl b) ss on a.q2 = ss.q1;
---END---
---START---

-- lateral can result in join conditions appearing below their
-- real semantic level
explain (verbose, costs off)
select * from int4_tbl i left join
  lateral (select * from int2_tbl j where i.f1 = j.f1) k on true;
---END---
---START---
select * from int4_tbl i left join
  lateral (select * from int2_tbl j where i.f1 = j.f1) k on true;
---END---
---START---
explain (verbose, costs off)
select * from int4_tbl i left join
  lateral (select coalesce(i) from int2_tbl j where i.f1 = j.f1) k on true;
---END---
---START---
select * from int4_tbl i left join
  lateral (select coalesce(i) from int2_tbl j where i.f1 = j.f1) k on true;
---END---
---START---
explain (verbose, costs off)
select * from int4_tbl a,
  lateral (
    select * from int4_tbl b left join int8_tbl c on (b.f1 = q1 and a.f1 = q2)
  ) ss;
---END---
---START---
select * from int4_tbl a,
  lateral (
    select * from int4_tbl b left join int8_tbl c on (b.f1 = q1 and a.f1 = q2)
  ) ss;
---END---
---START---

-- lateral reference in a PlaceHolderVar evaluated at join level
explain (verbose, costs off)
select * from
  int8_tbl a left join lateral
  (select b.q1 as bq1, c.q1 as cq1, least(a.q1,b.q1,c.q1) from
   int8_tbl b cross join int8_tbl c) ss
  on a.q2 = ss.bq1;
---END---
---START---
select * from
  int8_tbl a left join lateral
  (select b.q1 as bq1, c.q1 as cq1, least(a.q1,b.q1,c.q1) from
   int8_tbl b cross join int8_tbl c) ss
  on a.q2 = ss.bq1;
---END---
---START---

-- case requiring nested PlaceHolderVars
explain (verbose, costs off)
select * from
  int8_tbl c left join (
    int8_tbl a left join (select q1, coalesce(q2,42) as x from int8_tbl b) ss1
      on a.q2 = ss1.q1
    cross join
    lateral (select q1, coalesce(ss1.x,q2) as y from int8_tbl d) ss2
  ) on c.q2 = ss2.q1,
  lateral (select ss2.y offset 0) ss3;
---END---
---START---

-- case that breaks the old ph_may_need optimization
explain (verbose, costs off)
select c.*,a.*,ss1.q1,ss2.q1,ss3.* from
  int8_tbl c left join (
    int8_tbl a left join
      (select q1, coalesce(q2,f1) as x from int8_tbl b, int4_tbl b2
       where q1 < f1) ss1
      on a.q2 = ss1.q1
    cross join
    lateral (select q1, coalesce(ss1.x,q2) as y from int8_tbl d) ss2
  ) on c.q2 = ss2.q1,
  lateral (select * from int4_tbl i where ss2.y > f1) ss3;
---END---
---START---

-- check processing of postponed quals (bug #9041)
explain (verbose, costs off)
select * from
  (select 1 as x offset 0) x cross join (select 2 as y offset 0) y
  left join lateral (
    select * from (select 3 as z offset 0) z where z.z = x.x
  ) zz on zz.z = y.y;
---END---
---START---

-- a new postponed-quals issue (bug #17768)
explain (costs off)
select * from int4_tbl t1,
  lateral (select * from int4_tbl t2 inner join int4_tbl t3 on t1.f1 = 1
           inner join (int4_tbl t4 left join int4_tbl t5 on true) on true) ss;
---END---
---START---

-- check dummy rels with lateral references (bug #15694)
explain (verbose, costs off)
select * from int8_tbl i8 left join lateral
  (select *, i8.q2 from int4_tbl where false) ss on true;
---END---
---START---
explain (verbose, costs off)
select * from int8_tbl i8 left join lateral
  (select *, i8.q2 from int4_tbl i1, int4_tbl i2 where false) ss on true;
---END---
---START---

-- check handling of nested appendrels inside LATERAL
select * from
  ((select 2 as v) union all (select 3 as v)) as q1
  cross join lateral
  ((select * from
      ((select 4 as v) union all (select 5 as v)) as q3)
   union all
   (select q1.v)
  ) as q2;
---END---
---START---

-- check the number of columns specified
SELECT * FROM (int8_tbl i cross join int4_tbl j) ss(a,b,c,d);
---END---
---START---

-- check we don't try to do a unique-ified semijoin with LATERAL
explain (verbose, costs off)
select * from
  (values (0,9998), (1,1000)) v(id,x),
  lateral (select f1 from int4_tbl
           where f1 = any (select unique1 from tenk1
                           where unique2 = v.x offset 0)) ss;
---END---
---START---
select * from
  (values (0,9998), (1,1000)) v(id,x),
  lateral (select f1 from int4_tbl
           where f1 = any (select unique1 from tenk1
                           where unique2 = v.x offset 0)) ss;
---END---
---START---

-- check proper extParam/allParam handling (this isn't exactly a LATERAL issue,
-- but we can make the test case much more compact with LATERAL)
explain (verbose, costs off)
select * from (values (0), (1)) v(id),
lateral (select * from int8_tbl t1,
         lateral (select * from
                    (select * from int8_tbl t2
                     where q1 = any (select q2 from int8_tbl t3
                                     where q2 = (select greatest(t1.q1,t2.q2))
                                       and (select v.id=0)) offset 0) ss2) ss
         where t1.q1 = ss.q2) ss0;
---END---
---START---

select * from (values (0), (1)) v(id),
lateral (select * from int8_tbl t1,
         lateral (select * from
                    (select * from int8_tbl t2
                     where q1 = any (select q2 from int8_tbl t3
                                     where q2 = (select greatest(t1.q1,t2.q2))
                                       and (select v.id=0)) offset 0) ss2) ss
         where t1.q1 = ss.q2) ss0;
---END---
---START---

-- test some error cases where LATERAL should have been used but wasn't
select f1,g from int4_tbl a, (select f1 as g) ss;
---END---
---START---
select f1,g from int4_tbl a, (select a.f1 as g) ss;
---END---
---START---
select f1,g from int4_tbl a cross join (select f1 as g) ss;
---END---
---START---
select f1,g from int4_tbl a cross join (select a.f1 as g) ss;
---END---
---START---
-- SQL:2008 says the left table is in scope but illegal to access here
select f1,g from int4_tbl a right join lateral generate_series(0, a.f1) g on true;
---END---
---START---
select f1,g from int4_tbl a full join lateral generate_series(0, a.f1) g on true;
---END---
---START---
-- check we complain about ambiguous table references
select * from
  int8_tbl x cross join (int4_tbl x cross join lateral (select x.f1) ss);
---END---
---START---
-- LATERAL can be used to put an aggregate into the FROM clause of its query
select 1 from tenk1 a, lateral (select max(a.unique1) from int4_tbl b) ss;
---END---
---START---

-- check behavior of LATERAL in UPDATE/DELETE

create table xx1 as select f1 as x1, -f1 as x2 from int4_tbl;
---END---
---START---

-- error, can't do this:
update xx1 set x2 = f1 from (select * from int4_tbl where f1 = x1) ss;
---END---
---START---
update xx1 set x2 = f1 from (select * from int4_tbl where f1 = xx1.x1) ss;
---END---
---START---
-- can't do it even with LATERAL:
update xx1 set x2 = f1 from lateral (select * from int4_tbl where f1 = x1) ss;
---END---
---START---
-- we might in future allow something like this, but for now it's an error:
update xx1 set x2 = f1 from xx1, lateral (select * from int4_tbl where f1 = x1) ss;
---END---
---START---

-- also errors:
delete from xx1 using (select * from int4_tbl where f1 = x1) ss;
---END---
---START---
delete from xx1 using (select * from int4_tbl where f1 = xx1.x1) ss;
---END---
---START---
delete from xx1 using lateral (select * from int4_tbl where f1 = x1) ss;
---END---
---START---

--
-- test LATERAL reference propagation down a multi-level inheritance hierarchy
-- produced for a multi-level partitioned table hierarchy.
--
create table join_pt1 (a int, b int, c varchar) partition by range(a);
---END---
---START---
create table join_pt1p1 partition of join_pt1 for values from (0) to (100) partition by range(b);
---END---
---START---
create table join_pt1p2 partition of join_pt1 for values from (100) to (200);
---END---
---START---
create table join_pt1p1p1 partition of join_pt1p1 for values from (0) to (100);
---END---
---START---
insert into join_pt1 values (1, 1, 'x'), (101, 101, 'y');
---END---
---START---
create table join_ut1 (a int, b int, c varchar);
---END---
---START---
insert into join_ut1 values (101, 101, 'y'), (2, 2, 'z');
---END---
---START---
explain (verbose, costs off)
select t1.b, ss.phv from join_ut1 t1 left join lateral
              (select t2.a as t2a, t3.a t3a, least(t1.a, t2.a, t3.a) phv
					  from join_pt1 t2 join join_ut1 t3 on t2.a = t3.b) ss
              on t1.a = ss.t2a order by t1.a;
---END---
---START---
select t1.b, ss.phv from join_ut1 t1 left join lateral
              (select t2.a as t2a, t3.a t3a, least(t1.a, t2.a, t3.a) phv
					  from join_pt1 t2 join join_ut1 t3 on t2.a = t3.b) ss
              on t1.a = ss.t2a order by t1.a;
---END---
---START---

drop table join_pt1;
---END---
---START---
drop table join_ut1;
---END---
---START---

--
-- test estimation behavior with multi-column foreign key and constant qual
--

begin;
---END---
---START---

create table fkest (x integer, x10 integer, x10b integer, x100 integer);
---END---
---START---
insert into fkest select x, x/10, x/10, x/100 from generate_series(1,1000) x;
---END---
---START---
create unique index on fkest(x, x10, x100);
---END---
---START---
analyze fkest;
---END---
---START---

explain (costs off)
select * from fkest f1
  join fkest f2 on (f1.x = f2.x and f1.x10 = f2.x10b and f1.x100 = f2.x100)
  join fkest f3 on f1.x = f3.x
  where f1.x100 = 2;
---END---
---START---

alter table fkest add constraint fk
  foreign key (x, x10b, x100) references fkest (x, x10, x100);
---END---
---START---

explain (costs off)
select * from fkest f1
  join fkest f2 on (f1.x = f2.x and f1.x10 = f2.x10b and f1.x100 = f2.x100)
  join fkest f3 on f1.x = f3.x
  where f1.x100 = 2;
---END---
---START---

rollback;
---END---
---START---

--
-- test that foreign key join estimation performs sanely for outer joins
--

begin;
---END---
---START---

create table fkest (a int, b int, c int unique, primary key(a,b));
---END---
---START---
create table fkest1 (a int, b int, primary key(a,b));
---END---
---START---

insert into fkest select x/10, x%10, x from generate_series(1,1000) x;
---END---
---START---
insert into fkest1 select x/10, x%10 from generate_series(1,1000) x;
---END---
---START---

alter table fkest1
  add constraint fkest1_a_b_fkey foreign key (a,b) references fkest;
---END---
---START---

analyze fkest;
---END---
---START---
analyze fkest1;
---END---
---START---

explain (costs off)
select *
from fkest f
  left join fkest1 f1 on f.a = f1.a and f.b = f1.b
  left join fkest1 f2 on f.a = f2.a and f.b = f2.b
  left join fkest1 f3 on f.a = f3.a and f.b = f3.b
where f.c = 1;
---END---
---START---

rollback;
---END---
---START---

--
-- test planner's ability to mark joins as unique
--

create table j1 (id int primary key);
---END---
---START---
create table j2 (id int primary key);
---END---
---START---
create table j3 (id int);
---END---
---START---

insert into j1 values(1),(2),(3);
---END---
---START---
insert into j2 values(1),(2),(3);
---END---
---START---
insert into j3 values(1),(1);
---END---
---START---

analyze j1;
---END---
---START---
analyze j2;
---END---
---START---
analyze j3;
---END---
---START---

-- ensure join is properly marked as unique
explain (verbose, costs off)
select * from j1 inner join j2 on j1.id = j2.id;
---END---
---START---

-- ensure join is not unique when not an equi-join
explain (verbose, costs off)
select * from j1 inner join j2 on j1.id > j2.id;
---END---
---START---

-- ensure non-unique rel is not chosen as inner
explain (verbose, costs off)
select * from j1 inner join j3 on j1.id = j3.id;
---END---
---START---

-- ensure left join is marked as unique
explain (verbose, costs off)
select * from j1 left join j2 on j1.id = j2.id;
---END---
---START---

-- ensure right join is marked as unique
explain (verbose, costs off)
select * from j1 right join j2 on j1.id = j2.id;
---END---
---START---

-- ensure full join is marked as unique
explain (verbose, costs off)
select * from j1 full join j2 on j1.id = j2.id;
---END---
---START---

-- a clauseless (cross) join can't be unique
explain (verbose, costs off)
select * from j1 cross join j2;
---END---
---START---

-- ensure a natural join is marked as unique
explain (verbose, costs off)
select * from j1 natural join j2;
---END---
---START---

-- ensure a distinct clause allows the inner to become unique
explain (verbose, costs off)
select * from j1
inner join (select distinct id from j3) j3 on j1.id = j3.id;
---END---
---START---

-- ensure group by clause allows the inner to become unique
explain (verbose, costs off)
select * from j1
inner join (select id from j3 group by id) j3 on j1.id = j3.id;
---END---
---START---

drop table j1;
---END---
---START---
drop table j2;
---END---
---START---
drop table j3;
---END---
---START---

-- test more complex permutations of unique joins

create table j1 (id1 int, id2 int, primary key(id1,id2));
---END---
---START---
create table j2 (id1 int, id2 int, primary key(id1,id2));
---END---
---START---
create table j3 (id1 int, id2 int, primary key(id1,id2));
---END---
---START---

insert into j1 values(1,1),(1,2);
---END---
---START---
insert into j2 values(1,1);
---END---
---START---
insert into j3 values(1,1);
---END---
---START---

analyze j1;
---END---
---START---
analyze j2;
---END---
---START---
analyze j3;
---END---
---START---

-- ensure there's no unique join when not all columns which are part of the
-- unique index are seen in the join clause
explain (verbose, costs off)
select * from j1
inner join j2 on j1.id1 = j2.id1;
---END---
---START---

-- ensure proper unique detection with multiple join quals
explain (verbose, costs off)
select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2;
---END---
---START---

-- ensure we don't detect the join to be unique when quals are not part of the
-- join condition
explain (verbose, costs off)
select * from j1
inner join j2 on j1.id1 = j2.id1 where j1.id2 = 1;
---END---
---START---

-- as above, but for left joins.
explain (verbose, costs off)
select * from j1
left join j2 on j1.id1 = j2.id1 where j1.id2 = 1;
---END---
---START---

create unique index j1_id2_idx on j1(id2) where id2 is not null;
---END---
---START---

-- ensure we don't use a partial unique index as unique proofs
explain (verbose, costs off)
select * from j1
inner join j2 on j1.id2 = j2.id2;
---END---
---START---

drop index j1_id2_idx;
---END---
---START---

-- validate logic in merge joins which skips mark and restore.
-- it should only do this if all quals which were used to detect the unique
-- are present as join quals, and not plain quals.
set enable_nestloop to 0;
---END---
---START---
set enable_hashjoin to 0;
---END---
---START---
set enable_sort to 0;
---END---
---START---

-- create indexes that will be preferred over the PKs to perform the join
create index j1_id1_idx on j1 (id1) where id1 % 1000 = 1;
---END---
---START---
create index j2_id1_idx on j2 (id1) where id1 % 1000 = 1;
---END---
---START---

-- need an additional row in j2, if we want j2_id1_idx to be preferred
insert into j2 values(1,2);
---END---
---START---
analyze j2;
---END---
---START---

explain (costs off) select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2
where j1.id1 % 1000 = 1 and j2.id1 % 1000 = 1;
---END---
---START---

select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2
where j1.id1 % 1000 = 1 and j2.id1 % 1000 = 1;
---END---
---START---

-- Exercise array keys mark/restore B-Tree code
explain (costs off) select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2
where j1.id1 % 1000 = 1 and j2.id1 % 1000 = 1 and j2.id1 = any (array[1]);
---END---
---START---

select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2
where j1.id1 % 1000 = 1 and j2.id1 % 1000 = 1 and j2.id1 = any (array[1]);
---END---
---START---

-- Exercise array keys "find extreme element" B-Tree code
explain (costs off) select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2
where j1.id1 % 1000 = 1 and j2.id1 % 1000 = 1 and j2.id1 >= any (array[1,5]);
---END---
---START---

select * from j1
inner join j2 on j1.id1 = j2.id1 and j1.id2 = j2.id2
where j1.id1 % 1000 = 1 and j2.id1 % 1000 = 1 and j2.id1 >= any (array[1,5]);
---END---
---START---

reset enable_nestloop;
---END---
---START---
reset enable_hashjoin;
---END---
---START---
reset enable_sort;
---END---
---START---

drop table j1;
---END---
---START---
drop table j2;
---END---
---START---
drop table j3;
---END---
---START---

-- check that semijoin inner is not seen as unique for a portion of the outerrel
explain (verbose, costs off)
select t1.unique1, t2.hundred
from onek t1, tenk1 t2
where exists (select 1 from tenk1 t3
              where t3.thousand = t1.unique1 and t3.tenthous = t2.hundred)
      and t1.unique1 < 1;
---END---
---START---

-- ... unless it actually is unique
create table j3 as select unique1, tenthous from onek;
---END---
---START---
vacuum analyze j3;
---END---
---START---
create unique index on j3(unique1, tenthous);
---END---
---START---

explain (verbose, costs off)
select t1.unique1, t2.hundred
from onek t1, tenk1 t2
where exists (select 1 from j3
              where j3.unique1 = t1.unique1 and j3.tenthous = t2.hundred)
      and t1.unique1 < 1;
---END---
---START---

drop table j3;

drop table if exists onerow;
drop table if exists x;
drop table if exists y;
drop table if exists t1;
drop table if exists t2;
drop table if exists t3;
drop table if exists t2a;
drop table if exists tt1;
drop table if exists tt2;
drop table if exists tt3;
drop table if exists tt4;
drop table if exists tt4x;
drop table if exists tt5;
drop table if exists tt6;
drop table if exists xx;
drop table if exists yy;
drop table if exists zt1;
drop table if exists zt2;
drop table if exists zt3;
drop table if exists a;
drop table if exists b;
drop table if exists c;
drop table if exists d;
drop table if exists tidv;
drop table if exists nt1;
drop table if exists nt2;
drop table if exists nt3;
drop table if exists q1;
drop table if exists q2;
drop table if exists t;
drop table if exists parted_b;
drop table if exists parted_b1;
drop table if exists parent;
drop table if exists child;
drop table if exists innertab;
drop table if exists uniquetbl;
drop table if exists parttbl;
drop table if exists parttbl1;
drop table if exists xx1;
---END---
