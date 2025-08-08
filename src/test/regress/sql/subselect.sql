---START---
--
-- SUBSELECT
--

SELECT 1 AS one WHERE 1 IN (SELECT 1);
---END---
---START---
SELECT 1 AS zero WHERE 1 NOT IN (SELECT 1);
---END---
---START---
SELECT 1 AS zero WHERE 1 IN (SELECT 2);
---END---
---START---
-- Check grammar's handling of extra parens in assorted contexts

SELECT * FROM (SELECT 1 AS x) ss;
---END---
---START---
SELECT * FROM ((SELECT 1 AS x)) ss;
---END---
---START---
SELECT * FROM ((SELECT 1 AS x)), ((SELECT * FROM ((SELECT 2 AS y))));
---END---
---START---
(SELECT 2) UNION SELECT 2;
---END---
---START---
((SELECT 2)) UNION SELECT 2;
---END---
---START---
SELECT ((SELECT 2) UNION SELECT 2);
---END---
---START---
SELECT (((SELECT 2)) UNION SELECT 2);
---END---
---START---
SELECT (SELECT ARRAY[1,2,3])[1];
---END---
---START---
SELECT ((SELECT ARRAY[1,2,3]))[2];
---END---
---START---
SELECT (((SELECT ARRAY[1,2,3])))[3];
---END---
---START---
CREATE TABLE subselect_tbl (gemini_pk serial PRIMARY KEY, f1 integer, f2 integer, f3 double precision);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (1, 2, 3);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (2, 3, 4);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (3, 4, 5);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (1, 1, 1);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (2, 2, 2);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (3, 3, 3);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (6, 7, 8);
---END---
---START---
INSERT INTO SUBSELECT_TBL VALUES (8, 9, NULL);
---END---
---START---
SELECT * FROM SUBSELECT_TBL;
---END---
---START---
-- Uncorrelated subselects

SELECT f1 AS "Constant Select" FROM SUBSELECT_TBL
  WHERE f1 IN (SELECT 1);
---END---
---START---
SELECT f1 AS "Uncorrelated Field" FROM SUBSELECT_TBL
  WHERE f1 IN (SELECT f2 FROM SUBSELECT_TBL);
---END---
---START---
SELECT f1 AS "Uncorrelated Field" FROM SUBSELECT_TBL
  WHERE f1 IN (SELECT f2 FROM SUBSELECT_TBL WHERE
    f2 IN (SELECT f1 FROM SUBSELECT_TBL));
---END---
---START---
SELECT f1, f2
  FROM SUBSELECT_TBL
  WHERE (f1, f2) NOT IN (SELECT f2, CAST(f3 AS int4) FROM SUBSELECT_TBL
                         WHERE f3 IS NOT NULL);
---END---
---START---
-- Correlated subselects

SELECT f1 AS "Correlated Field", f2 AS "Second Field"
  FROM SUBSELECT_TBL upper
  WHERE f1 IN (SELECT f2 FROM SUBSELECT_TBL WHERE f1 = upper.f1);
---END---
---START---
-- @hengfeng: this crashes the emulator
-- SELECT f1 AS "Correlated Field", f3 AS "Second Field"
--   FROM SUBSELECT_TBL upper
--   WHERE f1 IN
--     (SELECT f2 FROM SUBSELECT_TBL WHERE CAST(upper.f2 AS float) = f3);
---END---
---START---
-- @hengfeng: this crashes the emulator
-- SELECT f1 AS "Correlated Field", f3 AS "Second Field"
--   FROM SUBSELECT_TBL upper
--   WHERE f3 IN (SELECT upper.f1 + f2 FROM SUBSELECT_TBL
--                WHERE f2 = CAST(f3 AS integer));
---END---
---START---
SELECT f1 AS "Correlated Field"
  FROM SUBSELECT_TBL
  WHERE (f1, f2) IN (SELECT f2, CAST(f3 AS int4) FROM SUBSELECT_TBL
                     WHERE f3 IS NOT NULL);
---END---
---START---
-- Subselects without aliases

SELECT count FROM (SELECT COUNT(DISTINCT name) FROM road);
---END---
---START---
SELECT COUNT(*) FROM (SELECT DISTINCT name FROM road);
---END---
---START---
SELECT * FROM (SELECT * FROM int4_tbl), (VALUES (123456)) WHERE f1 = column1;
---END---
---START---
CREATE VIEW view_unnamed_ss AS
SELECT * FROM (SELECT * FROM (SELECT abs(f1) AS a1 FROM int4_tbl)),
              (SELECT * FROM int8_tbl)
  WHERE a1 < 10 AND q1 > a1 ORDER BY q1, q2;
---END---
---START---
SELECT * FROM view_unnamed_ss;
---END---
---START---
\sv view_unnamed_ss

DROP VIEW view_unnamed_ss;
---END---
---START---
-- Test matching of locking clause to correct alias

CREATE VIEW view_unnamed_ss_locking AS
SELECT * FROM (SELECT * FROM int4_tbl), int8_tbl AS unnamed_subquery
  WHERE f1 = q1
  FOR UPDATE OF unnamed_subquery;
---END---
---START---
\sv view_unnamed_ss_locking

DROP VIEW view_unnamed_ss_locking;
---END---
---START---
--
-- Use some existing tables in the regression test
--

SELECT ss.f1 AS "Correlated Field", ss.f3 AS "Second Field"
  FROM SUBSELECT_TBL ss
  WHERE f1 NOT IN (SELECT f1+1 FROM INT4_TBL
                   WHERE f1 != ss.f1 AND f1 < 2147483647);
---END---
---START---
select q1, float8(count(*)) / (select count(*) from int8_tbl)
from int8_tbl group by q1 order by q1;
---END---
---START---
-- Unspecified-type literals in output columns should resolve as text

SELECT *, pg_typeof(f1) FROM
  (SELECT 'foo' AS f1 FROM generate_series(1,3)) ss ORDER BY 1;
---END---
---START---
-- ... unless there's context to suggest differently

explain (verbose, costs off) select '42' union all select '43';
---END---
---START---
explain (verbose, costs off) select '42' union all select 43;
---END---
---START---
-- check materialization of an initplan reference (bug #14524)
explain (verbose, costs off)
select 1 = all (select (select 1));
---END---
---START---
select 1 = all (select (select 1));
---END---
---START---
--
-- Check EXISTS simplification with LIMIT
--
explain (costs off)
select * from int4_tbl o where exists
  (select 1 from int4_tbl i where i.f1=o.f1 limit null);
---END---
---START---
explain (costs off)
select * from int4_tbl o where not exists
  (select 1 from int4_tbl i where i.f1=o.f1 limit 1);
---END---
---START---
explain (costs off)
select * from int4_tbl o where exists
  (select 1 from int4_tbl i where i.f1=o.f1 limit 0);
---END---
---START---
--
-- Test cases to catch unpleasant interactions between IN-join processing
-- and subquery pullup.
--

select count(*) from
  (select 1 from tenk1 a
   where unique1 IN (select hundred from tenk1 b)) ss;
---END---
---START---
select count(distinct ss.ten) from
  (select ten from tenk1 a
   where unique1 IN (select hundred from tenk1 b)) ss;
---END---
---START---
select count(*) from
  (select 1 from tenk1 a
   where unique1 IN (select distinct hundred from tenk1 b)) ss;
---END---
---START---
select count(distinct ss.ten) from
  (select ten from tenk1 a
   where unique1 IN (select distinct hundred from tenk1 b)) ss;
---END---
---START---
--
-- Test cases to check for overenthusiastic optimization of
-- "IN (SELECT DISTINCT ...)" and related cases.  Per example from
-- Luca Pireddu and Michael Fuhr.
--

DROP TABLE IF EXISTS foo;

CREATE TABLE foo (gemini_pk serial PRIMARY KEY, id integer);
---END---
---START---
DROP TABLE IF EXISTS bar;

CREATE TABLE bar (gemini_pk serial PRIMARY KEY, id1 integer, id2 integer);
---END---
---START---
INSERT INTO foo VALUES (1);
---END---
---START---
INSERT INTO bar VALUES (1, 1);
---END---
---START---
INSERT INTO bar VALUES (2, 2);
---END---
---START---
INSERT INTO bar VALUES (3, 1);
---END---
---START---
-- These cases require an extra level of distinct-ing above subquery s
SELECT * FROM foo WHERE id IN
    (SELECT id2 FROM (SELECT DISTINCT id1, id2 FROM bar) AS s);
---END---
---START---
SELECT * FROM foo WHERE id IN
    (SELECT id2 FROM (SELECT id1,id2 FROM bar GROUP BY id1,id2) AS s);
---END---
---START---
SELECT * FROM foo WHERE id IN
    (SELECT id2 FROM (SELECT id1, id2 FROM bar UNION
                      SELECT id1, id2 FROM bar) AS s);
---END---
---START---
-- These cases do not
SELECT * FROM foo WHERE id IN
    (SELECT id2 FROM (SELECT DISTINCT ON (id2) id1, id2 FROM bar) AS s);
---END---
---START---
SELECT * FROM foo WHERE id IN
    (SELECT id2 FROM (SELECT id2 FROM bar GROUP BY id2) AS s);
---END---
---START---
SELECT * FROM foo WHERE id IN
    (SELECT id2 FROM (SELECT id2 FROM bar UNION
                      SELECT id2 FROM bar) AS s);
---END---
---START---
CREATE TABLE orderstest (gemini_pk serial PRIMARY KEY, approver_ref integer, po_ref integer, ordercanceled boolean);
---END---
---START---
INSERT INTO orderstest VALUES (1, 1, false);
---END---
---START---
INSERT INTO orderstest VALUES (66, 5, false);
---END---
---START---
INSERT INTO orderstest VALUES (66, 6, false);
---END---
---START---
INSERT INTO orderstest VALUES (66, 7, false);
---END---
---START---
INSERT INTO orderstest VALUES (66, 1, true);
---END---
---START---
INSERT INTO orderstest VALUES (66, 8, false);
---END---
---START---
INSERT INTO orderstest VALUES (66, 1, false);
---END---
---START---
INSERT INTO orderstest VALUES (77, 1, false);
---END---
---START---
INSERT INTO orderstest VALUES (1, 1, false);
---END---
---START---
INSERT INTO orderstest VALUES (66, 1, false);
---END---
---START---
INSERT INTO orderstest VALUES (1, 1, false);
---END---
---START---
CREATE VIEW orders_view AS
SELECT *,
(SELECT CASE
   WHEN ord.approver_ref=1 THEN '---' ELSE 'Approved'
 END) AS "Approved",
(SELECT CASE
 WHEN ord.ordercanceled
 THEN 'Canceled'
 ELSE
  (SELECT CASE
		WHEN ord.po_ref=1
		THEN
		 (SELECT CASE
				WHEN ord.approver_ref=1
				THEN '---'
				ELSE 'Approved'
			END)
		ELSE 'PO'
	END)
END) AS "Status",
(CASE
 WHEN ord.ordercanceled
 THEN 'Canceled'
 ELSE
  (CASE
		WHEN ord.po_ref=1
		THEN
		 (CASE
				WHEN ord.approver_ref=1
				THEN '---'
				ELSE 'Approved'
			END)
		ELSE 'PO'
	END)
END) AS "Status_OK"
FROM orderstest ord;
---END---
---START---
SELECT * FROM orders_view;
---END---
---START---
DROP TABLE orderstest cascade;
---END---
---START---
--
-- Test cases to catch situations where rule rewriter fails to propagate
-- hasSubLinks flag correctly.  Per example from Kyle Bateman.
--

DROP TABLE IF EXISTS parts;

CREATE TABLE parts (gemini_pk serial PRIMARY KEY, partnum text, cost float8);
---END---
---START---
DROP TABLE IF EXISTS shipped;

CREATE TABLE shipped (gemini_pk serial PRIMARY KEY, ttype varchar, ordnum int8, partnum text, value float8);
---END---
---START---
create temp view shipped_view as
    select * from shipped where ttype = 'wt';
---END---
---START---
create rule shipped_view_insert as on insert to shipped_view do instead
    insert into shipped values('wt', new.ordnum, new.partnum, new.value);
---END---
---START---
insert into parts (partnum, cost) values (1, 1234.56);
---END---
---START---
insert into shipped_view (ordnum, partnum, value)
    values (0, 1, (select cost from parts where partnum = '1'));
---END---
---START---
select * from shipped_view;
---END---
---START---
create rule shipped_view_update as on update to shipped_view do instead
    update shipped set partnum = new.partnum, value = new.value
        where ttype = new.ttype and ordnum = new.ordnum;
---END---
---START---
update shipped_view set value = 11
    from int4_tbl a join int4_tbl b
      on (a.f1 = (select f1 from int4_tbl c where c.f1=b.f1))
    where ordnum = a.f1;
---END---
---START---
select * from shipped_view;
---END---
---START---
select f1, ss1 as relabel from
    (select *, (select sum(f1) from int4_tbl b where f1 >= a.f1) as ss1
     from int4_tbl a) ss;
---END---
---START---
--
-- Test cases involving PARAM_EXEC parameters and min/max index optimizations.
-- Per bug report from David Sanchez i Gregori.
--

select * from (
  select max(unique1) from tenk1 as a
  where exists (select 1 from tenk1 as b where b.thousand = a.unique2)
) ss;
---END---
---START---
select * from (
  select min(unique1) from tenk1 as a
  where not exists (select 1 from tenk1 as b where b.unique2 = 10000)
) ss;
---END---
---START---
--
-- Test that an IN implemented using a UniquePath does unique-ification
-- with the right semantics, as per bug #4113.  (Unfortunately we have
-- no simple way to ensure that this test case actually chooses that type
-- of plan, but it does in releases 7.4-8.3.  Note that an ordering difference
-- here might mean that some other plan type is being used, rendering the test
-- pointless.)
--

DROP TABLE IF EXISTS numeric_table;

CREATE TABLE numeric_table (gemini_pk serial PRIMARY KEY, num_col numeric);
---END---
---START---
insert into numeric_table values (1), (1.000000000000000000001), (2), (3);
---END---
---START---
DROP TABLE IF EXISTS float_table;

CREATE TABLE float_table (gemini_pk serial PRIMARY KEY, float_col float8);
---END---
---START---
insert into float_table values (1), (2), (3);
---END---
---START---
select * from float_table
  where float_col in (select num_col from numeric_table);
---END---
---START---
select * from numeric_table
  where num_col in (select float_col from float_table);
---END---
---START---
--
-- Test case for bug #4290: bogus calculation of subplan param sets
--

DROP TABLE IF EXISTS ta;

create table ta (id int primary key, val int);
---END---
---START---
insert into ta values(1,1);
---END---
---START---
insert into ta values(2,2);
---END---
---START---
DROP TABLE IF EXISTS tb;

create table tb (id int primary key, aval int);
---END---
---START---
insert into tb values(1,1);
---END---
---START---
insert into tb values(2,1);
---END---
---START---
insert into tb values(3,2);
---END---
---START---
insert into tb values(4,2);
---END---
---START---
DROP TABLE IF EXISTS tc;

create table tc (id int primary key, aid int);
---END---
---START---
insert into tc values(1,1);
---END---
---START---
insert into tc values(2,2);
---END---
---START---
select
  ( select min(tb.id) from tb
    where tb.aval = (select ta.val from ta where ta.id = tc.aid) ) as min_tb_id
from tc;
---END---
---START---
--
-- Test case for 8.3 "failed to locate grouping columns" bug
--

DROP TABLE IF EXISTS t1;

CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, f1 numeric(14, 0), f2 varchar(30));
---END---
---START---
select * from
  (select distinct f1, f2, (select f2 from t1 x where x.f1 = up.f1) as fs
   from t1 up) ss
group by f1,f2,fs;
---END---
---START---
--
-- Test case for bug #5514 (mishandling of whole-row Vars in subselects)
--

DROP TABLE IF EXISTS table_a;

CREATE TABLE table_a (gemini_pk serial PRIMARY KEY, id integer);
---END---
---START---
insert into table_a values (42);
---END---
---START---
create temp view view_a as select * from table_a;
---END---
---START---
select view_a from view_a;
---END---
---START---
select (select view_a) from view_a;
---END---
---START---
select (select (select view_a)) from view_a;
---END---
---START---
select (select (a.*)::text) from view_a a;
---END---
---START---
--
-- Check that whole-row Vars reading the result of a subselect don't include
-- any junk columns therein
--

select q from (select max(f1) from int4_tbl group by f1 order by f1) q;
---END---
---START---
with q as (select max(f1) from int4_tbl group by f1 order by f1)
  select q from q;
---END---
---START---
--
-- Test case for sublinks pulled up into joinaliasvars lists in an
-- inherited update/delete query
--

begin;
---END---
---START---
--  this shouldn't delete anything, but be safe

delete from road
where exists (
  select 1
  from
    int4_tbl cross join
    ( select f1, array(select q1 from int8_tbl) as arr
      from text_tbl ) ss
  where road.name = ss.f1 );
---END---
---START---
rollback;
---END---
---START---
--
-- Test case for sublinks pushed down into subselects via join alias expansion
--

select
  (select sq1) as qq1
from
  (select exists(select 1 from int4_tbl where f1 = q2) as sq1, 42 as dummy
   from int8_tbl) sq0
  join
  int4_tbl i4 on dummy = i4.f1;
---END---
---START---
--
-- Test case for subselect within UPDATE of INSERT...ON CONFLICT DO UPDATE
--
DROP TABLE IF EXISTS upsert;

create table upsert(key int8 primary key, val text);
---END---
---START---
insert into upsert values(1, 'val') on conflict (key) do update set val = 'not seen';
---END---
---START---
insert into upsert values(1, 'val') on conflict (key) do update set val = 'seen with subselect ' || (select f1 from int4_tbl where f1 != 0 limit 1)::text;
---END---
---START---
select * from upsert;
---END---
---START---
with aa as (select 'int4_tbl' u from int4_tbl limit 1)
insert into upsert values (1, 'x'), (999, 'y')
on conflict (key) do update set val = (select u from aa)
returning *;
---END---
---START---
--
-- Test case for cross-type partial matching in hashed subplan (bug #7597)
--

DROP TABLE IF EXISTS outer_7597;

CREATE TABLE outer_7597 (gemini_pk serial PRIMARY KEY, f1 int8, f2 int8);
---END---
---START---
insert into outer_7597 values (0, 0);
---END---
---START---
insert into outer_7597 values (1, 0);
---END---
---START---
insert into outer_7597 values (0, null);
---END---
---START---
insert into outer_7597 values (1, null);
---END---
---START---
DROP TABLE IF EXISTS inner_7597;

CREATE TABLE inner_7597 (gemini_pk serial PRIMARY KEY, c1 int8, c2 int8);
---END---
---START---
insert into inner_7597 values(0, null);
---END---
---START---
select * from outer_7597 where (f1, f2) not in (select * from inner_7597);
---END---
---START---
--
-- Similar test case using text that verifies that collation
-- information is passed through by execTuplesEqual() in nodeSubplan.c
-- (otherwise it would error in texteq())
--

DROP TABLE IF EXISTS outer_text;

CREATE TABLE outer_text (gemini_pk serial PRIMARY KEY, f1 text, f2 text);
---END---
---START---
insert into outer_text values ('a', 'a');
---END---
---START---
insert into outer_text values ('b', 'a');
---END---
---START---
insert into outer_text values ('a', null);
---END---
---START---
insert into outer_text values ('b', null);
---END---
---START---
DROP TABLE IF EXISTS inner_text;

CREATE TABLE inner_text (gemini_pk serial PRIMARY KEY, c1 text, c2 text);
---END---
---START---
insert into inner_text values ('a', null);
---END---
---START---
insert into inner_text values ('123', '456');
---END---
---START---
select * from outer_text where (f1, f2) not in (select * from inner_text);
---END---
---START---
--
-- Another test case for cross-type hashed subplans: comparison of
-- inner-side values must be done with appropriate operator
--

explain (verbose, costs off)
select 'foo'::text in (select 'bar'::name union all select 'bar'::name);
---END---
---START---
select 'foo'::text in (select 'bar'::name union all select 'bar'::name);
---END---
---START---
--
-- Test that we don't try to hash nested records (bug #17363)
-- (Hashing could be supported, but for now we don't)
--

explain (verbose, costs off)
select row(row(row(1))) = any (select row(row(1)));
---END---
---START---
select row(row(row(1))) = any (select row(row(1)));
---END---
---START---
--
-- Test case for premature memory release during hashing of subplan output
--

select '1'::text in (select '1'::name union all select '1'::name);
---END---
---START---
--
-- Test that we don't try to use a hashed subplan if the simplified
-- testexpr isn't of the right shape
--

-- this fails by default, of course
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
begin;
---END---
---START---
-- make an operator to allow it to succeed
create function bogus_int8_text_eq(int8, text) returns boolean
language sql as 'select $1::text = $2';
---END---
---START---
create operator = (procedure=bogus_int8_text_eq, leftarg=int8, rightarg=text);
---END---
---START---
explain (costs off)
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
-- inlining of this function results in unusual number of hash clauses,
-- which we can still cope with
create or replace function bogus_int8_text_eq(int8, text) returns boolean
language sql as 'select $1::text = $2 and $1::text = $2';
---END---
---START---
explain (costs off)
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
-- inlining of this function causes LHS and RHS to be switched,
-- which we can't cope with, so hashing should be abandoned
create or replace function bogus_int8_text_eq(int8, text) returns boolean
language sql as 'select $2 = $1::text';
---END---
---START---
explain (costs off)
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
select * from int8_tbl where q1 in (select c1 from inner_text);
---END---
---START---
rollback;
---END---
---START---
-- to get rid of the bogus operator

--
-- Test resolution of hashed vs non-hashed implementation of EXISTS subplan
--
explain (costs off)
select count(*) from tenk1 t
where (exists(select 1 from tenk1 k where k.unique1 = t.unique2) or ten < 0);
---END---
---START---
select count(*) from tenk1 t
where (exists(select 1 from tenk1 k where k.unique1 = t.unique2) or ten < 0);
---END---
---START---
explain (costs off)
select count(*) from tenk1 t
where (exists(select 1 from tenk1 k where k.unique1 = t.unique2) or ten < 0)
  and thousand = 1;
---END---
---START---
select count(*) from tenk1 t
where (exists(select 1 from tenk1 k where k.unique1 = t.unique2) or ten < 0)
  and thousand = 1;
---END---
---START---
-- It's possible for the same EXISTS to get resolved both ways
DROP TABLE IF EXISTS exists_tbl;

CREATE TABLE exists_tbl (gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer) PARTITION BY list (c1);
---END---
---START---
DROP TABLE IF EXISTS exists_tbl_null;

create table exists_tbl_null partition of exists_tbl for values in (null);
---END---
---START---
DROP TABLE IF EXISTS exists_tbl_def;

create table exists_tbl_def partition of exists_tbl default;
---END---
---START---
insert into exists_tbl select x, x/2, x+1 from generate_series(0,10) x;
---END---
---START---
analyze exists_tbl;
---END---
---START---
explain (costs off)
select * from exists_tbl t1
  where (exists(select 1 from exists_tbl t2 where t1.c1 = t2.c2) or c3 < 0);
---END---
---START---
select * from exists_tbl t1
  where (exists(select 1 from exists_tbl t2 where t1.c1 = t2.c2) or c3 < 0);
---END---
---START---
--
-- Test case for planner bug with nested EXISTS handling
--
select a.thousand from tenk1 a, tenk1 b
where a.thousand = b.thousand
  and exists ( select 1 from tenk1 c where b.hundred = c.hundred
                   and not exists ( select 1 from tenk1 d
                                    where a.thousand = d.thousand ) );
---END---
---START---
--
-- Check that nested sub-selects are not pulled up if they contain volatiles
--
explain (verbose, costs off)
  select x, x from
    (select (select now()) as x from (values(1),(2)) v(y)) ss;
---END---
---START---
explain (verbose, costs off)
  select x, x from
    (select (select random()) as x from (values(1),(2)) v(y)) ss;
---END---
---START---
explain (verbose, costs off)
  select x, x from
    (select (select now() where y=y) as x from (values(1),(2)) v(y)) ss;
---END---
---START---
explain (verbose, costs off)
  select x, x from
    (select (select random() where y=y) as x from (values(1),(2)) v(y)) ss;
---END---
---START---
--
-- Test rescan of a hashed subplan (the use of random() is to prevent the
-- sub-select from being pulled up, which would result in not hashing)
--
explain (verbose, costs off)
select sum(ss.tst::int) from
  onek o cross join lateral (
  select i.ten in (select f1 from int4_tbl where f1 <= o.hundred) as tst,
         random() as r
  from onek i where i.unique1 = o.unique1 ) ss
where o.ten = 0;
---END---
---START---
select sum(ss.tst::int) from
  onek o cross join lateral (
  select i.ten in (select f1 from int4_tbl where f1 <= o.hundred) as tst,
         random() as r
  from onek i where i.unique1 = o.unique1 ) ss
where o.ten = 0;
---END---
---START---
--
-- Test rescan of a SetOp node
--
explain (costs off)
select count(*) from
  onek o cross join lateral (
    select * from onek i1 where i1.unique1 = o.unique1
    except
    select * from onek i2 where i2.unique1 = o.unique2
  ) ss
where o.ten = 1;
---END---
---START---
select count(*) from
  onek o cross join lateral (
    select * from onek i1 where i1.unique1 = o.unique1
    except
    select * from onek i2 where i2.unique1 = o.unique2
  ) ss
where o.ten = 1;
---END---
---START---
--
-- Test rescan of a RecursiveUnion node
--
explain (costs off)
select sum(o.four), sum(ss.a) from
  onek o cross join lateral (
    with recursive x(a) as
      (select o.four as a
       union
       select a + 1 from x
       where a < 10)
    select * from x
  ) ss
where o.ten = 1;
---END---
---START---
select sum(o.four), sum(ss.a) from
  onek o cross join lateral (
    with recursive x(a) as
      (select o.four as a
       union
       select a + 1 from x
       where a < 10)
    select * from x
  ) ss
where o.ten = 1;
---END---
---START---
--
-- Check we don't misoptimize a NOT IN where the subquery returns no rows.
--
DROP TABLE IF EXISTS notinouter;

CREATE TABLE notinouter (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
DROP TABLE IF EXISTS notininner;

CREATE TABLE notininner (gemini_pk serial PRIMARY KEY, b integer NOT NULL);
---END---
---START---
insert into notinouter values (null), (1);
---END---
---START---
select * from notinouter where a not in (select b from notininner);
---END---
---START---
--
-- Check we behave sanely in corner case of empty SELECT list (bug #8648)
--
DROP TABLE IF EXISTS nocolumns;

CREATE TABLE nocolumns (gemini_pk serial PRIMARY KEY);
---END---
---START---
select exists(select * from nocolumns);
---END---
---START---
--
-- Check behavior with a SubPlan in VALUES (bug #14924)
--
select val.x
  from generate_series(1,10) as s(i),
  lateral (
    values ((select s.i + 1)), (s.i + 101)
  ) as val(x)
where s.i < 10 and (select val.x) < 110;
---END---
---START---
-- another variant of that (bug #16213)
explain (verbose, costs off)
select * from
(values
  (3 not in (select * from (values (1), (2)) ss1)),
  (false)
) ss;
---END---
---START---
select * from
(values
  (3 not in (select * from (values (1), (2)) ss1)),
  (false)
) ss;
---END---
---START---
--
-- Check sane behavior with nested IN SubLinks
--
explain (verbose, costs off)
select * from int4_tbl where
  (case when f1 in (select unique1 from tenk1 a) then f1 else null end) in
  (select ten from tenk1 b);
---END---
---START---
select * from int4_tbl where
  (case when f1 in (select unique1 from tenk1 a) then f1 else null end) in
  (select ten from tenk1 b);
---END---
---START---
--
-- Check for incorrect optimization when IN subquery contains a SRF
--
explain (verbose, costs off)
select * from int4_tbl o where (f1, f1) in
  (select f1, generate_series(1,50) / 10 g from int4_tbl i group by f1);
---END---
---START---
select * from int4_tbl o where (f1, f1) in
  (select f1, generate_series(1,50) / 10 g from int4_tbl i group by f1);
---END---
---START---
--
-- check for over-optimization of whole-row Var referencing an Append plan
--
select (select q from
         (select 1,2,3 where f1 > 0
          union all
          select 4,5,6.0 where f1 <= 0
         ) q )
from int4_tbl;
---END---
---START---
--
-- Check for sane handling of a lateral reference in a subquery's quals
-- (most of the complication here is to prevent the test case from being
-- flattened too much)
--
explain (verbose, costs off)
select * from
    int4_tbl i4,
    lateral (
        select i4.f1 > 1 as b, 1 as id
        from (select random() order by 1) as t1
      union all
        select true as b, 2 as id
    ) as t2
where b and f1 >= 0;
---END---
---START---
select * from
    int4_tbl i4,
    lateral (
        select i4.f1 > 1 as b, 1 as id
        from (select random() order by 1) as t1
      union all
        select true as b, 2 as id
    ) as t2
where b and f1 >= 0;
---END---
---START---
--
-- Check that volatile quals aren't pushed down past a DISTINCT:
-- nextval() should not be called more than the nominal number of times
--
create temp sequence ts1;
---END---
---START---
select * from
  (select distinct ten from tenk1) ss
  where ten < 10 + nextval('ts1')
  order by 1;
---END---
---START---
select nextval('ts1');
---END---
---START---
--
-- Check that volatile quals aren't pushed down past a set-returning function;
-- while a nonvolatile qual can be, if it doesn't reference the SRF.
--
create function tattle(x int, y int) returns bool
volatile language plpgsql as $$
begin
  raise notice 'x = %, y = %', x, y;
  return x > y;
end$$;
---END---
---START---
explain (verbose, costs off)
select * from
  (select 9 as x, unnest(array[1,2,3,11,12,13]) as u) ss
  where tattle(x, 8);
---END---
---START---
select * from
  (select 9 as x, unnest(array[1,2,3,11,12,13]) as u) ss
  where tattle(x, 8);
---END---
---START---
-- if we pretend it's stable, we get different results:
alter function tattle(x int, y int) stable;
---END---
---START---
explain (verbose, costs off)
select * from
  (select 9 as x, unnest(array[1,2,3,11,12,13]) as u) ss
  where tattle(x, 8);
---END---
---START---
select * from
  (select 9 as x, unnest(array[1,2,3,11,12,13]) as u) ss
  where tattle(x, 8);
---END---
---START---
-- although even a stable qual should not be pushed down if it references SRF
explain (verbose, costs off)
select * from
  (select 9 as x, unnest(array[1,2,3,11,12,13]) as u) ss
  where tattle(x, u);
---END---
---START---
select * from
  (select 9 as x, unnest(array[1,2,3,11,12,13]) as u) ss
  where tattle(x, u);
---END---
---START---
drop function tattle(x int, y int);
---END---
---START---
--
-- Test that LIMIT can be pushed to SORT through a subquery that just projects
-- columns.  We check for that having happened by looking to see if EXPLAIN
-- ANALYZE shows that a top-N sort was used.  We must suppress or filter away
-- all the non-invariant parts of the EXPLAIN ANALYZE output.
--
create table sq_limit (pk int primary key, c1 int, c2 int);
---END---
---START---
insert into sq_limit values
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 4),
    (5, 1, 1),
    (6, 2, 2),
    (7, 3, 3),
    (8, 4, 4);
---END---
---START---
create function explain_sq_limit() returns setof text language plpgsql as
$$
declare ln text;
begin
    for ln in
        explain (analyze, summary off, timing off, costs off)
        select * from (select pk,c2 from sq_limit order by c1,pk) as x limit 3
    loop
        ln := regexp_replace(ln, 'Memory: \S*',  'Memory: xxx');
        return next ln;
    end loop;
end;
$$;
---END---
---START---
select * from explain_sq_limit();
---END---
---START---
select * from (select pk,c2 from sq_limit order by c1,pk) as x limit 3;
---END---
---START---
drop function explain_sq_limit();
---END---
---START---
drop table sq_limit;
---END---
---START---
--
-- Ensure that backward scan direction isn't propagated into
-- expression subqueries (bug #15336)
--

begin;
---END---
---START---
declare c1 scroll cursor for
 select * from generate_series(1,4) i
  where i <> all (values (2),(3));
---END---
---START---
move forward all in c1;
---END---
---START---
fetch backward all in c1;
---END---
---START---
commit;
---END---
---START---
--
-- Tests for CTE inlining behavior
--

-- Basic subquery that can be inlined
explain (verbose, costs off)
with x as (select * from (select f1 from subselect_tbl) ss)
select * from x where f1 = 1;
---END---
---START---
-- Explicitly request materialization
explain (verbose, costs off)
with x as materialized (select * from (select f1 from subselect_tbl) ss)
select * from x where f1 = 1;
---END---
---START---
-- Stable functions are safe to inline
explain (verbose, costs off)
with x as (select * from (select f1, now() from subselect_tbl) ss)
select * from x where f1 = 1;
---END---
---START---
-- Volatile functions prevent inlining
explain (verbose, costs off)
with x as (select * from (select f1, random() from subselect_tbl) ss)
select * from x where f1 = 1;
---END---
---START---
-- SELECT FOR UPDATE cannot be inlined
explain (verbose, costs off)
with x as (select * from (select f1 from subselect_tbl for update) ss)
select * from x where f1 = 1;
---END---
---START---
-- Multiply-referenced CTEs are inlined only when requested
explain (verbose, costs off)
with x as (select * from (select f1, now() as n from subselect_tbl) ss)
select * from x, x x2 where x.n = x2.n;
---END---
---START---
explain (verbose, costs off)
with x as not materialized (select * from (select f1, now() as n from subselect_tbl) ss)
select * from x, x x2 where x.n = x2.n;
---END---
---START---
-- Multiply-referenced CTEs can't be inlined if they contain outer self-refs
explain (verbose, costs off)
with recursive x(a) as
  ((values ('a'), ('b'))
   union all
   (with z as not materialized (select * from x)
    select z.a || z1.a as a from z cross join z as z1
    where length(z.a || z1.a) < 5))
select * from x;
---END---
---START---
with recursive x(a) as
  ((values ('a'), ('b'))
   union all
   (with z as not materialized (select * from x)
    select z.a || z1.a as a from z cross join z as z1
    where length(z.a || z1.a) < 5))
select * from x;
---END---
---START---
explain (verbose, costs off)
with recursive x(a) as
  ((values ('a'), ('b'))
   union all
   (with z as not materialized (select * from x)
    select z.a || z.a as a from z
    where length(z.a || z.a) < 5))
select * from x;
---END---
---START---
with recursive x(a) as
  ((values ('a'), ('b'))
   union all
   (with z as not materialized (select * from x)
    select z.a || z.a as a from z
    where length(z.a || z.a) < 5))
select * from x;
---END---
---START---
-- Check handling of outer references
explain (verbose, costs off)
with x as (select * from int4_tbl)
select * from (with y as (select * from x) select * from y) ss;
---END---
---START---
explain (verbose, costs off)
with x as materialized (select * from int4_tbl)
select * from (with y as (select * from x) select * from y) ss;
---END---
---START---
-- Ensure that we inline the currect CTE when there are
-- multiple CTEs with the same name
explain (verbose, costs off)
with x as (select 1 as y)
select * from (with x as (select 2 as y) select * from x) ss;
---END---
---START---
-- Row marks are not pushed into CTEs
explain (verbose, costs off)
with x as (select * from subselect_tbl)
select * from x for update;
---END---
