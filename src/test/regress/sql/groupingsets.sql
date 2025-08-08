---START---
--
-- grouping sets
--

-- test data sources

create temp view gstest1(a,b,v)
  as values (1,1,10),(1,1,11),(1,2,12),(1,2,13),(1,3,14),
            (2,3,15),
            (3,3,16),(3,4,17),
            (4,1,18),(4,1,19);
---END---
---START---
create temp table gstest2 (a integer, b integer, c integer, d integer,
                           e integer, f integer, g integer, h integer);
---END---
---START---
copy gstest2 from stdin;
1	1	1	1	1	1	1	1
1	1	1	1	1	1	1	2
1	1	1	1	1	1	2	2
1	1	1	1	1	2	2	2
1	1	1	1	2	2	2	2
1	1	1	2	2	2	2	2
1	1	2	2	2	2	2	2
1	2	2	2	2	2	2	2
2	2	2	2	2	2	2	2
\.
---END---
---START---
create temp table gstest3 (a integer, b integer, c integer, d integer);
---END---
---START---
copy gstest3 from stdin;
1	1	1	1
2	2	2	2
\.
---END---
---START---
alter table gstest3 add primary key (a);
---END---
---START---
create temp table gstest4(id integer, v integer,
                          unhashable_col bit(4), unsortable_col xid);
---END---
---START---
insert into gstest4
values (1,1,b'0000','1'), (2,2,b'0001','1'),
       (3,4,b'0010','2'), (4,8,b'0011','2'),
       (5,16,b'0000','2'), (6,32,b'0001','2'),
       (7,64,b'0010','1'), (8,128,b'0011','1');
---END---
---START---
create temp table gstest_empty (a integer, b integer, v integer);
---END---
---START---
create function gstest_data(v integer, out a integer, out b integer)
  returns setof record
  as $f$
    begin
      return query select v, i from generate_series(1,3) i;
    end;
  $f$ language plpgsql;
---END---
---START---
-- basic functionality

set enable_hashagg = false;
---END---
---START---
-- test hashing explicitly later

-- simple rollup with multiple plain aggregates, with and without ordering
-- (and with ordering differing from grouping)

select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by rollup (a,b);
---END---
---START---
select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by rollup (a,b) order by a,b;
---END---
---START---
select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by rollup (a,b) order by b desc, a;
---END---
---START---
select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by rollup (a,b) order by coalesce(a,0)+coalesce(b,0);
---END---
---START---
-- various types of ordered aggs
select a, b, grouping(a,b),
       array_agg(v order by v),
       string_agg(v::text, ':' order by v desc),
       percentile_disc(0.5) within group (order by v),
       rank(1,2,12) within group (order by a,b,v)
  from gstest1 group by rollup (a,b) order by a,b;
---END---
---START---
-- test usage of grouped columns in direct args of aggs
select grouping(a), a, array_agg(b),
       rank(a) within group (order by b nulls first),
       rank(a) within group (order by b nulls last)
  from (values (1,1),(1,4),(1,5),(3,1),(3,2)) v(a,b)
 group by rollup (a) order by a;
---END---
---START---
-- nesting with window functions
select a, b, sum(c), sum(sum(c)) over (order by a,b) as rsum
  from gstest2 group by rollup (a,b) order by rsum, a, b;
---END---
---START---
-- nesting with grouping sets
select sum(c) from gstest2
  group by grouping sets((), grouping sets((), grouping sets(())))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets((), grouping sets((), grouping sets(((a, b)))))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets(grouping sets(rollup(c), grouping sets(cube(c))))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets(a, grouping sets(a, cube(b)))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets(grouping sets((a, (b))))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets(grouping sets((a, b)))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets(grouping sets(a, grouping sets(a), a))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets(grouping sets(a, grouping sets(a, grouping sets(a), ((a)), a, grouping sets(a), (a)), a))
  order by 1 desc;
---END---
---START---
select sum(c) from gstest2
  group by grouping sets((a,(a,b)), grouping sets((a,(a,b)),a))
  order by 1 desc;
---END---
---START---
-- empty input: first is 0 rows, second 1, third 3 etc.
select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),a);
---END---
---START---
select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),());
---END---
---START---
select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),(),(),());
---END---
---START---
select sum(v), count(*) from gstest_empty group by grouping sets ((),(),());
---END---
---START---
-- empty input with joins tests some important code paths
select t1.a, t2.b, sum(t1.v), count(*) from gstest_empty t1, gstest_empty t2
 group by grouping sets ((t1.a,t2.b),());
---END---
---START---
-- simple joins, var resolution, GROUPING on join vars
select t1.a, t2.b, grouping(t1.a, t2.b), sum(t1.v), max(t2.a)
  from gstest1 t1, gstest2 t2
 group by grouping sets ((t1.a, t2.b), ());
---END---
---START---
select t1.a, t2.b, grouping(t1.a, t2.b), sum(t1.v), max(t2.a)
  from gstest1 t1 join gstest2 t2 on (t1.a=t2.a)
 group by grouping sets ((t1.a, t2.b), ());
---END---
---START---
select a, b, grouping(a, b), sum(t1.v), max(t2.c)
  from gstest1 t1 join gstest2 t2 using (a,b)
 group by grouping sets ((a, b), ());
---END---
---START---
-- check that functionally dependent cols are not nulled
select a, d, grouping(a,b,c)
  from gstest3
 group by grouping sets ((a,b), (a,c));
---END---
---START---
-- check that distinct grouping columns are kept separate
-- even if they are equal()
explain (costs off)
select g as alias1, g as alias2
  from generate_series(1,3) g
 group by alias1, rollup(alias2);
---END---
---START---
select g as alias1, g as alias2
  from generate_series(1,3) g
 group by alias1, rollup(alias2);
---END---
---START---
-- check that pulled-up subquery outputs still go to null when appropriate
select four, x
  from (select four, ten, 'foo'::text as x from tenk1) as t
  group by grouping sets (four, x)
  having x = 'foo';
---END---
---START---
select four, x || 'x'
  from (select four, ten, 'foo'::text as x from tenk1) as t
  group by grouping sets (four, x)
  order by four;
---END---
---START---
select (x+y)*1, sum(z)
 from (select 1 as x, 2 as y, 3 as z) s
 group by grouping sets (x+y, x);
---END---
---START---
select x, not x as not_x, q2 from
  (select *, q1 = 1 as x from int8_tbl i1) as t
  group by grouping sets(x, q2)
  order by x, q2;
---END---
---START---
-- check qual push-down rules for a subquery with grouping sets
explain (verbose, costs off)
select * from (
  select 1 as x, q1, sum(q2)
  from int8_tbl i1
  group by grouping sets(1, 2)
) ss
where x = 1 and q1 = 123;
---END---
---START---
select * from (
  select 1 as x, q1, sum(q2)
  from int8_tbl i1
  group by grouping sets(1, 2)
) ss
where x = 1 and q1 = 123;
---END---
---START---
-- check handling of pulled-up SubPlan in GROUPING() argument (bug #17479)
explain (verbose, costs off)
select grouping(ss.x)
from int8_tbl i1
cross join lateral (select (select i1.q1) as x) ss
group by ss.x;
---END---
---START---
select grouping(ss.x)
from int8_tbl i1
cross join lateral (select (select i1.q1) as x) ss
group by ss.x;
---END---
---START---
explain (verbose, costs off)
select (select grouping(ss.x))
from int8_tbl i1
cross join lateral (select (select i1.q1) as x) ss
group by ss.x;
---END---
---START---
select (select grouping(ss.x))
from int8_tbl i1
cross join lateral (select (select i1.q1) as x) ss
group by ss.x;
---END---
---START---
-- simple rescan tests

select a, b, sum(v.x)
  from (values (1),(2)) v(x), gstest_data(v.x)
 group by rollup (a,b);
---END---
---START---
select *
  from (values (1),(2)) v(x),
       lateral (select a, b, sum(v.x) from gstest_data(v.x) group by rollup (a,b)) s;
---END---
---START---
-- min max optimization should still work with GROUP BY ()
explain (costs off)
  select min(unique1) from tenk1 GROUP BY ();
---END---
---START---
-- Views with GROUPING SET queries
CREATE VIEW gstest_view AS select a, b, grouping(a,b), sum(c), count(*), max(c)
  from gstest2 group by rollup ((a,b,c),(c,d));
---END---
---START---
select pg_get_viewdef('gstest_view'::regclass, true);
---END---
---START---
-- Nested queries with 3 or more levels of nesting
select(select (select grouping(a,b) from (values (1)) v2(c)) from (values (1,2)) v1(a,b) group by (a,b)) from (values(6,7)) v3(e,f) GROUP BY ROLLUP(e,f);
---END---
---START---
select(select (select grouping(e,f) from (values (1)) v2(c)) from (values (1,2)) v1(a,b) group by (a,b)) from (values(6,7)) v3(e,f) GROUP BY ROLLUP(e,f);
---END---
---START---
select(select (select grouping(c) from (values (1)) v2(c) GROUP BY c) from (values (1,2)) v1(a,b) group by (a,b)) from (values(6,7)) v3(e,f) GROUP BY ROLLUP(e,f);
---END---
---START---
-- Combinations of operations
select a, b, c, d from gstest2 group by rollup(a,b),grouping sets(c,d);
---END---
---START---
select a, b from (values (1,2),(2,3)) v(a,b) group by a,b, grouping sets(a);
---END---
---START---
-- Tests for chained aggregates
select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by grouping sets ((a,b),(a+1,b+1),(a+2,b+2)) order by 3,6;
---END---
---START---
select(select (select grouping(a,b) from (values (1)) v2(c)) from (values (1,2)) v1(a,b) group by (a,b)) from (values(6,7)) v3(e,f) GROUP BY ROLLUP((e+1),(f+1));
---END---
---START---
select(select (select grouping(a,b) from (values (1)) v2(c)) from (values (1,2)) v1(a,b) group by (a,b)) from (values(6,7)) v3(e,f) GROUP BY CUBE((e+1),(f+1)) ORDER BY (e+1),(f+1);
---END---
---START---
select a, b, sum(c), sum(sum(c)) over (order by a,b) as rsum
  from gstest2 group by cube (a,b) order by rsum, a, b;
---END---
---START---
select a, b, sum(c) from (values (1,1,10),(1,1,11),(1,2,12),(1,2,13),(1,3,14),(2,3,15),(3,3,16),(3,4,17),(4,1,18),(4,1,19)) v(a,b,c) group by rollup (a,b);
---END---
---START---
select a, b, sum(v.x)
  from (values (1),(2)) v(x), gstest_data(v.x)
 group by cube (a,b) order by a,b;
---END---
---START---
-- Test reordering of grouping sets
explain (costs off)
select * from gstest1 group by grouping sets((a,b,v),(v)) order by v,b,a;
---END---
---START---
-- Agg level check. This query should error out.
select (select grouping(a,b) from gstest2) from gstest2 group by a,b;
---END---
---START---
--Nested queries
select a, b, sum(c), count(*) from gstest2 group by grouping sets (rollup(a,b),a);
---END---
---START---
-- HAVING queries
select ten, sum(distinct four) from onek a
group by grouping sets((ten,four),(ten))
having exists (select 1 from onek b where sum(distinct a.four) = b.four);
---END---
---START---
-- Tests around pushdown of HAVING clauses, partially testing against previous bugs
select a,count(*) from gstest2 group by rollup(a) order by a;
---END---
---START---
select a,count(*) from gstest2 group by rollup(a) having a is distinct from 1 order by a;
---END---
---START---
explain (costs off)
  select a,count(*) from gstest2 group by rollup(a) having a is distinct from 1 order by a;
---END---
---START---
select v.c, (select count(*) from gstest2 group by () having v.c)
  from (values (false),(true)) v(c) order by v.c;
---END---
---START---
explain (costs off)
  select v.c, (select count(*) from gstest2 group by () having v.c)
    from (values (false),(true)) v(c) order by v.c;
---END---
---START---
-- HAVING with GROUPING queries
select ten, grouping(ten) from onek
group by grouping sets(ten) having grouping(ten) >= 0
order by 2,1;
---END---
---START---
select ten, grouping(ten) from onek
group by grouping sets(ten, four) having grouping(ten) > 0
order by 2,1;
---END---
---START---
select ten, grouping(ten) from onek
group by rollup(ten) having grouping(ten) > 0
order by 2,1;
---END---
---START---
select ten, grouping(ten) from onek
group by cube(ten) having grouping(ten) > 0
order by 2,1;
---END---
---START---
select ten, grouping(ten) from onek
group by (ten) having grouping(ten) >= 0
order by 2,1;
---END---
---START---
-- FILTER queries
select ten, sum(distinct four) filter (where four::text ~ '123') from onek a
group by rollup(ten);
---END---
---START---
-- More rescan tests
select * from (values (1),(2)) v(a) left join lateral (select v.a, four, ten, count(*) from onek group by cube(four,ten)) s on true order by v.a,four,ten;
---END---
---START---
select array(select row(v.a,s1.*) from (select two,four, count(*) from onek group by cube(two,four) order by two,four) s1) from (values (1),(2)) v(a);
---END---
---START---
-- Grouping on text columns
select sum(ten) from onek group by two, rollup(four::text) order by 1;
---END---
---START---
select sum(ten) from onek group by rollup(four::text), two order by 1;
---END---
---START---
-- hashing support

set enable_hashagg = true;
---END---
---START---
-- failure cases

select count(*) from gstest4 group by rollup(unhashable_col,unsortable_col);
---END---
---START---
select array_agg(v order by v) from gstest4 group by grouping sets ((id,unsortable_col),(id));
---END---
---START---
-- simple cases

select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by grouping sets ((a),(b)) order by 3,1,2;
---END---
---START---
explain (costs off) select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by grouping sets ((a),(b)) order by 3,1,2;
---END---
---START---
select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by cube(a,b) order by 3,1,2;
---END---
---START---
explain (costs off) select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by cube(a,b) order by 3,1,2;
---END---
---START---
-- shouldn't try and hash
explain (costs off)
  select a, b, grouping(a,b), array_agg(v order by v)
    from gstest1 group by cube(a,b);
---END---
---START---
-- unsortable cases
select unsortable_col, count(*)
  from gstest4 group by grouping sets ((unsortable_col),(unsortable_col))
  order by unsortable_col::text;
---END---
---START---
-- mixed hashable/sortable cases
select unhashable_col, unsortable_col,
       grouping(unhashable_col, unsortable_col),
       count(*), sum(v)
  from gstest4 group by grouping sets ((unhashable_col),(unsortable_col))
 order by 3, 5;
---END---
---START---
explain (costs off)
  select unhashable_col, unsortable_col,
         grouping(unhashable_col, unsortable_col),
         count(*), sum(v)
    from gstest4 group by grouping sets ((unhashable_col),(unsortable_col))
   order by 3,5;
---END---
---START---
select unhashable_col, unsortable_col,
       grouping(unhashable_col, unsortable_col),
       count(*), sum(v)
  from gstest4 group by grouping sets ((v,unhashable_col),(v,unsortable_col))
 order by 3,5;
---END---
---START---
explain (costs off)
  select unhashable_col, unsortable_col,
         grouping(unhashable_col, unsortable_col),
         count(*), sum(v)
    from gstest4 group by grouping sets ((v,unhashable_col),(v,unsortable_col))
   order by 3,5;
---END---
---START---
-- empty input: first is 0 rows, second 1, third 3 etc.
select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),a);
---END---
---START---
explain (costs off)
  select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),a);
---END---
---START---
select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),());
---END---
---START---
select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),(),(),());
---END---
---START---
explain (costs off)
  select a, b, sum(v), count(*) from gstest_empty group by grouping sets ((a,b),(),(),());
---END---
---START---
select sum(v), count(*) from gstest_empty group by grouping sets ((),(),());
---END---
---START---
explain (costs off)
  select sum(v), count(*) from gstest_empty group by grouping sets ((),(),());
---END---
---START---
-- check that functionally dependent cols are not nulled
select a, d, grouping(a,b,c)
  from gstest3
 group by grouping sets ((a,b), (a,c));
---END---
---START---
explain (costs off)
  select a, d, grouping(a,b,c)
    from gstest3
   group by grouping sets ((a,b), (a,c));
---END---
---START---
-- simple rescan tests

select a, b, sum(v.x)
  from (values (1),(2)) v(x), gstest_data(v.x)
 group by grouping sets (a,b)
 order by 1, 2, 3;
---END---
---START---
explain (costs off)
  select a, b, sum(v.x)
    from (values (1),(2)) v(x), gstest_data(v.x)
   group by grouping sets (a,b)
   order by 3, 1, 2;
---END---
---START---
select *
  from (values (1),(2)) v(x),
       lateral (select a, b, sum(v.x) from gstest_data(v.x) group by grouping sets (a,b)) s;
---END---
---START---
explain (costs off)
  select *
    from (values (1),(2)) v(x),
         lateral (select a, b, sum(v.x) from gstest_data(v.x) group by grouping sets (a,b)) s;
---END---
---START---
-- Tests for chained aggregates
select a, b, grouping(a,b), sum(v), count(*), max(v)
  from gstest1 group by grouping sets ((a,b),(a+1,b+1),(a+2,b+2)) order by 3,6;
---END---
---START---
explain (costs off)
  select a, b, grouping(a,b), sum(v), count(*), max(v)
    from gstest1 group by grouping sets ((a,b),(a+1,b+1),(a+2,b+2)) order by 3,6;
---END---
---START---
select a, b, sum(c), sum(sum(c)) over (order by a,b) as rsum
  from gstest2 group by cube (a,b) order by rsum, a, b;
---END---
---START---
explain (costs off)
  select a, b, sum(c), sum(sum(c)) over (order by a,b) as rsum
    from gstest2 group by cube (a,b) order by rsum, a, b;
---END---
---START---
select a, b, sum(v.x)
  from (values (1),(2)) v(x), gstest_data(v.x)
 group by cube (a,b) order by a,b;
---END---
---START---
explain (costs off)
  select a, b, sum(v.x)
    from (values (1),(2)) v(x), gstest_data(v.x)
   group by cube (a,b) order by a,b;
---END---
---START---
-- Verify that we correctly handle the child node returning a
-- non-minimal slot, which happens if the input is pre-sorted,
-- e.g. due to an index scan.
BEGIN;
---END---
---START---
SET LOCAL enable_hashagg = false;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT a, b, count(*), max(a), max(b) FROM gstest3 GROUP BY GROUPING SETS(a, b,()) ORDER BY a, b;
---END---
---START---
SELECT a, b, count(*), max(a), max(b) FROM gstest3 GROUP BY GROUPING SETS(a, b,()) ORDER BY a, b;
---END---
---START---
SET LOCAL enable_seqscan = false;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT a, b, count(*), max(a), max(b) FROM gstest3 GROUP BY GROUPING SETS(a, b,()) ORDER BY a, b;
---END---
---START---
SELECT a, b, count(*), max(a), max(b) FROM gstest3 GROUP BY GROUPING SETS(a, b,()) ORDER BY a, b;
---END---
---START---
COMMIT;
---END---
---START---
-- More rescan tests
select * from (values (1),(2)) v(a) left join lateral (select v.a, four, ten, count(*) from onek group by cube(four,ten)) s on true order by v.a,four,ten;
---END---
---START---
select array(select row(v.a,s1.*) from (select two,four, count(*) from onek group by cube(two,four) order by two,four) s1) from (values (1),(2)) v(a);
---END---
---START---
-- Rescan logic changes when there are no empty grouping sets, so test
-- that too:
select * from (values (1),(2)) v(a) left join lateral (select v.a, four, ten, count(*) from onek group by grouping sets(four,ten)) s on true order by v.a,four,ten;
---END---
---START---
select array(select row(v.a,s1.*) from (select two,four, count(*) from onek group by grouping sets(two,four) order by two,four) s1) from (values (1),(2)) v(a);
---END---
---START---
-- test the knapsack

set enable_indexscan = false;
---END---
---START---
set hash_mem_multiplier = 1.0;
---END---
---START---
set work_mem = '64kB';
---END---
---START---
explain (costs off)
  select unique1,
         count(two), count(four), count(ten),
         count(hundred), count(thousand), count(twothousand),
         count(*)
    from tenk1 group by grouping sets (unique1,twothousand,thousand,hundred,ten,four,two);
---END---
---START---
explain (costs off)
  select unique1,
         count(two), count(four), count(ten),
         count(hundred), count(thousand), count(twothousand),
         count(*)
    from tenk1 group by grouping sets (unique1,hundred,ten,four,two);
---END---
---START---
set work_mem = '384kB';
---END---
---START---
explain (costs off)
  select unique1,
         count(two), count(four), count(ten),
         count(hundred), count(thousand), count(twothousand),
         count(*)
    from tenk1 group by grouping sets (unique1,twothousand,thousand,hundred,ten,four,two);
---END---
---START---
-- check collation-sensitive matching between grouping expressions
-- (similar to a check for aggregates, but there are additional code
-- paths for GROUPING, so check again here)

select v||'a', case grouping(v||'a') when 1 then 1 else 0 end, count(*)
  from unnest(array[1,1], array['a','b']) u(i,v)
 group by rollup(i, v||'a') order by 1,3;
---END---
---START---
select v||'a', case when grouping(v||'a') = 1 then 1 else 0 end, count(*)
  from unnest(array[1,1], array['a','b']) u(i,v)
 group by rollup(i, v||'a') order by 1,3;
---END---
---START---
-- Bug #16784
create table bug_16784(i int, j int);
---END---
---START---
analyze bug_16784;
---END---
---START---
alter table bug_16784 set (autovacuum_enabled = 'false');
---END---
---START---
update pg_class set reltuples = 10 where relname='bug_16784';
---END---
---START---
insert into bug_16784 select g/10, g from generate_series(1,40) g;
---END---
---START---
set work_mem='64kB';
---END---
---START---
set enable_sort = false;
---END---
---START---
select * from
  (values (1),(2)) v(a),
  lateral (select a, i, j, count(*) from
             bug_16784 group by cube(i,j)) s
  order by v.a, i, j;
---END---
---START---
--
-- Compare results between plans using sorting and plans using hash
-- aggregation. Force spilling in both cases by setting work_mem low
-- and altering the statistics.
--

create table gs_data_1 as
select g%1000 as g1000, g%100 as g100, g%10 as g10, g
   from generate_series(0,1999) g;
---END---
---START---
analyze gs_data_1;
---END---
---START---
alter table gs_data_1 set (autovacuum_enabled = 'false');
---END---
---START---
update pg_class set reltuples = 10 where relname='gs_data_1';
---END---
---START---
set work_mem='64kB';
---END---
---START---
-- Produce results with sorting.

set enable_sort = true;
---END---
---START---
set enable_hashagg = false;
---END---
---START---
set jit_above_cost = 0;
---END---
---START---
explain (costs off)
select g100, g10, sum(g::numeric), count(*), max(g::text)
from gs_data_1 group by cube (g1000, g100,g10);
---END---
---START---
create table gs_group_1 as
select g100, g10, sum(g::numeric), count(*), max(g::text)
from gs_data_1 group by cube (g1000, g100,g10);
---END---
---START---
-- Produce results with hash aggregation.

set enable_hashagg = true;
---END---
---START---
set enable_sort = false;
---END---
---START---
explain (costs off)
select g100, g10, sum(g::numeric), count(*), max(g::text)
from gs_data_1 group by cube (g1000, g100,g10);
---END---
---START---
create table gs_hash_1 as
select g100, g10, sum(g::numeric), count(*), max(g::text)
from gs_data_1 group by cube (g1000, g100,g10);
---END---
---START---
set enable_sort = true;
---END---
---START---
set work_mem to default;
---END---
---START---
set hash_mem_multiplier to default;
---END---
---START---
-- Compare results

(select * from gs_hash_1 except select * from gs_group_1)
  union all
(select * from gs_group_1 except select * from gs_hash_1);
---END---
---START---
drop table gs_group_1;
---END---
---START---
drop table gs_hash_1;
---END---
---START---
-- GROUP BY DISTINCT

-- "normal" behavior...
select a, b, c
from (values (1, 2, 3), (4, null, 6), (7, 8, 9)) as t (a, b, c)
group by all rollup(a, b), rollup(a, c)
order by a, b, c;
---END---
---START---
-- ...which is also the default
select a, b, c
from (values (1, 2, 3), (4, null, 6), (7, 8, 9)) as t (a, b, c)
group by rollup(a, b), rollup(a, c)
order by a, b, c;
---END---
---START---
-- "group by distinct" behavior...
select a, b, c
from (values (1, 2, 3), (4, null, 6), (7, 8, 9)) as t (a, b, c)
group by distinct rollup(a, b), rollup(a, c)
order by a, b, c;
---END---
---START---
-- ...which is not the same as "select distinct"
select distinct a, b, c
from (values (1, 2, 3), (4, null, 6), (7, 8, 9)) as t (a, b, c)
group by rollup(a, b), rollup(a, c)
order by a, b, c;
---END---
---START---
-- test handling of outer GroupingFunc within subqueries
explain (costs off)
select (select grouping(v1)) from (values ((select 1))) v(v1) group by cube(v1);
---END---
---START---
select (select grouping(v1)) from (values ((select 1))) v(v1) group by cube(v1);
---END---
---START---
explain (costs off)
select (select grouping(v1)) from (values ((select 1))) v(v1) group by v1;
---END---
---START---
select (select grouping(v1)) from (values ((select 1))) v(v1) group by v1;
---END---
