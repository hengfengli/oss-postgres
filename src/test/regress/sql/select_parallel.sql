---START---
--
-- PARALLEL
--

create function sp_parallel_restricted(int) returns int as
  $$begin return $1; end$$ language plpgsql parallel restricted;
---END---
---START---

begin;
---END---
---START---

-- encourage use of parallel plans
set parallel_setup_cost=0;
---END---
---START---
set parallel_tuple_cost=0;
---END---
---START---
set min_parallel_table_scan_size=0;
---END---
---START---
set max_parallel_workers_per_gather=4;
---END---
---START---

-- Parallel Append with partial-subplans
explain (costs off)
  select round(avg(aa)), sum(aa) from a_star;
---END---
---START---
select round(avg(aa)), sum(aa) from a_star a1;
---END---
---START---

-- Parallel Append with both partial and non-partial subplans
alter table c_star set (parallel_workers = 0);
---END---
---START---
alter table d_star set (parallel_workers = 0);
---END---
---START---
explain (costs off)
  select round(avg(aa)), sum(aa) from a_star;
---END---
---START---
select round(avg(aa)), sum(aa) from a_star a2;
---END---
---START---

-- Parallel Append with only non-partial subplans
alter table a_star set (parallel_workers = 0);
---END---
---START---
alter table b_star set (parallel_workers = 0);
---END---
---START---
alter table e_star set (parallel_workers = 0);
---END---
---START---
alter table f_star set (parallel_workers = 0);
---END---
---START---
explain (costs off)
  select round(avg(aa)), sum(aa) from a_star;
---END---
---START---
select round(avg(aa)), sum(aa) from a_star a3;
---END---
---START---

-- Disable Parallel Append
alter table a_star reset (parallel_workers);
---END---
---START---
alter table b_star reset (parallel_workers);
---END---
---START---
alter table c_star reset (parallel_workers);
---END---
---START---
alter table d_star reset (parallel_workers);
---END---
---START---
alter table e_star reset (parallel_workers);
---END---
---START---
alter table f_star reset (parallel_workers);
---END---
---START---
set enable_parallel_append to off;
---END---
---START---
explain (costs off)
  select round(avg(aa)), sum(aa) from a_star;
---END---
---START---
select round(avg(aa)), sum(aa) from a_star a4;
---END---
---START---
reset enable_parallel_append;
---END---
---START---

-- Parallel Append that runs serially
create function sp_test_func() returns setof text as
$$ select 'foo'::varchar union all select 'bar'::varchar $$
language sql stable;
---END---
---START---
select sp_test_func() order by 1;
---END---
---START---

-- Parallel Append is not to be used when the subpath depends on the outer param
create table part_pa_test(a int, b int) partition by range(a);
---END---
---START---
create table part_pa_test_p1 partition of part_pa_test for values from (minvalue) to (0);
---END---
---START---
create table part_pa_test_p2 partition of part_pa_test for values from (0) to (maxvalue);
---END---
---START---
explain (costs off)
	select (select max((select pa1.b from part_pa_test pa1 where pa1.a = pa2.a)))
	from part_pa_test pa2;
---END---
---START---
drop table part_pa_test;
---END---
---START---

-- test with leader participation disabled
set parallel_leader_participation = off;
---END---
---START---
explain (costs off)
  select count(*) from tenk1 where stringu1 = 'GRAAAA';
---END---
---START---
select count(*) from tenk1 where stringu1 = 'GRAAAA';
---END---
---START---

-- test with leader participation disabled, but no workers available (so
-- the leader will have to run the plan despite the setting)
set max_parallel_workers = 0;
---END---
---START---
explain (costs off)
  select count(*) from tenk1 where stringu1 = 'GRAAAA';
---END---
---START---
select count(*) from tenk1 where stringu1 = 'GRAAAA';
---END---
---START---

reset max_parallel_workers;
---END---
---START---
reset parallel_leader_participation;
---END---
---START---

-- test that parallel_restricted function doesn't run in worker
alter table tenk1 set (parallel_workers = 4);
---END---
---START---
explain (verbose, costs off)
select sp_parallel_restricted(unique1) from tenk1
  where stringu1 = 'GRAAAA' order by 1;
---END---
---START---

-- test parallel plan when group by expression is in target list.
explain (costs off)
	select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---
select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---

explain (costs off)
	select stringu1, count(*) from tenk1 group by stringu1 order by stringu1;
---END---
---START---

-- test that parallel plan for aggregates is not selected when
-- target list contains parallel restricted clause.
explain (costs off)
	select  sum(sp_parallel_restricted(unique1)) from tenk1
	group by(sp_parallel_restricted(unique1));
---END---
---START---

-- test prepared statement
prepare tenk1_count(integer) As select  count((unique1)) from tenk1 where hundred > $1;
---END---
---START---
explain (costs off) execute tenk1_count(1);
---END---
---START---
execute tenk1_count(1);
---END---
---START---
deallocate tenk1_count;
---END---
---START---

-- test parallel plans for queries containing un-correlated subplans.
alter table tenk2 set (parallel_workers = 0);
---END---
---START---
explain (costs off)
	select count(*) from tenk1 where (two, four) not in
	(select hundred, thousand from tenk2 where thousand > 100);
---END---
---START---
select count(*) from tenk1 where (two, four) not in
	(select hundred, thousand from tenk2 where thousand > 100);
---END---
---START---
-- this is not parallel-safe due to use of random() within SubLink's testexpr:
explain (costs off)
	select * from tenk1 where (unique1 + random())::integer not in
	(select ten from tenk2);
---END---
---START---
alter table tenk2 reset (parallel_workers);
---END---
---START---

-- test parallel plan for a query containing initplan.
set enable_indexscan = off;
---END---
---START---
set enable_indexonlyscan = off;
---END---
---START---
set enable_bitmapscan = off;
---END---
---START---
alter table tenk2 set (parallel_workers = 2);
---END---
---START---

explain (costs off)
	select count(*) from tenk1
        where tenk1.unique1 = (Select max(tenk2.unique1) from tenk2);
---END---
---START---
select count(*) from tenk1
    where tenk1.unique1 = (Select max(tenk2.unique1) from tenk2);
---END---
---START---

reset enable_indexscan;
---END---
---START---
reset enable_indexonlyscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---
alter table tenk2 reset (parallel_workers);
---END---
---START---

-- test parallel index scans.
set enable_seqscan to off;
---END---
---START---
set enable_bitmapscan to off;
---END---
---START---

explain (costs off)
	select  count((unique1)) from tenk1 where hundred > 1;
---END---
---START---
select  count((unique1)) from tenk1 where hundred > 1;
---END---
---START---

-- test parallel index-only scans.
explain (costs off)
	select  count(*) from tenk1 where thousand > 95;
---END---
---START---
select  count(*) from tenk1 where thousand > 95;
---END---
---START---

-- test rescan cases too
set enable_material = false;
---END---
---START---

explain (costs off)
select * from
  (select count(unique1) from tenk1 where hundred > 10) ss
  right join (values (1),(2),(3)) v(x) on true;
---END---
---START---
select * from
  (select count(unique1) from tenk1 where hundred > 10) ss
  right join (values (1),(2),(3)) v(x) on true;
---END---
---START---

explain (costs off)
select * from
  (select count(*) from tenk1 where thousand > 99) ss
  right join (values (1),(2),(3)) v(x) on true;
---END---
---START---
select * from
  (select count(*) from tenk1 where thousand > 99) ss
  right join (values (1),(2),(3)) v(x) on true;
---END---
---START---

-- test rescans for a Limit node with a parallel node beneath it.
reset enable_seqscan;
---END---
---START---
set enable_indexonlyscan to off;
---END---
---START---
set enable_indexscan to off;
---END---
---START---
alter table tenk1 set (parallel_workers = 0);
---END---
---START---
alter table tenk2 set (parallel_workers = 1);
---END---
---START---
explain (costs off)
select count(*) from tenk1
  left join (select tenk2.unique1 from tenk2 order by 1 limit 1000) ss
  on tenk1.unique1 < ss.unique1 + 1
  where tenk1.unique1 < 2;
---END---
---START---
select count(*) from tenk1
  left join (select tenk2.unique1 from tenk2 order by 1 limit 1000) ss
  on tenk1.unique1 < ss.unique1 + 1
  where tenk1.unique1 < 2;
---END---
---START---
--reset the value of workers for each table as it was before this test.
alter table tenk1 set (parallel_workers = 4);
---END---
---START---
alter table tenk2 reset (parallel_workers);
---END---
---START---

reset enable_material;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---
reset enable_indexonlyscan;
---END---
---START---
reset enable_indexscan;
---END---
---START---

-- test parallel bitmap heap scan.
set enable_seqscan to off;
---END---
---START---
set enable_indexscan to off;
---END---
---START---
set enable_hashjoin to off;
---END---
---START---
set enable_mergejoin to off;
---END---
---START---
set enable_material to off;
---END---
---START---
-- test prefetching, if the platform allows it
DO $$
BEGIN
 SET effective_io_concurrency = 50;
---END---
---START---
EXCEPTION WHEN invalid_parameter_value THEN
END $$;
---END---
---START---
set work_mem='64kB';  --set small work mem to force lossy pages
explain (costs off)
	select count(*) from tenk1, tenk2 where tenk1.hundred > 1 and tenk2.thousand=0;
---END---
---START---
select count(*) from tenk1, tenk2 where tenk1.hundred > 1 and tenk2.thousand=0;
---END---
---START---

create table bmscantest (a int, t text);
---END---
---START---
insert into bmscantest select r, 'fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo' FROM generate_series(1,100000) r;
---END---
---START---
create index i_bmtest ON bmscantest(a);
---END---
---START---
select count(*) from bmscantest where a>1;
---END---
---START---

-- test accumulation of stats for parallel nodes
reset enable_seqscan;
---END---
---START---
alter table tenk2 set (parallel_workers = 0);
---END---
---START---
explain (analyze, timing off, summary off, costs off)
   select count(*) from tenk1, tenk2 where tenk1.hundred > 1
        and tenk2.thousand=0;
---END---
---START---
alter table tenk2 reset (parallel_workers);
---END---
---START---

reset work_mem;
---END---
---START---
create function explain_parallel_sort_stats() returns setof text
language plpgsql as
$$
declare ln text;
---END---
---START---
begin
    for ln in
        explain (analyze, timing off, summary off, costs off)
          select * from
          (select ten from tenk1 where ten < 100 order by ten) ss
          right join (values (1),(2),(3)) v(x) on true
    loop
        ln := regexp_replace(ln, 'Memory: \S*',  'Memory: xxx');
---END---
---START---
        return next ln;
---END---
---START---
    end loop;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---
select * from explain_parallel_sort_stats();
---END---
---START---

reset enable_indexscan;
---END---
---START---
reset enable_hashjoin;
---END---
---START---
reset enable_mergejoin;
---END---
---START---
reset enable_material;
---END---
---START---
reset effective_io_concurrency;
---END---
---START---
drop table bmscantest;
---END---
---START---
drop function explain_parallel_sort_stats();
---END---
---START---

-- test parallel merge join path.
set enable_hashjoin to off;
---END---
---START---
set enable_nestloop to off;
---END---
---START---

explain (costs off)
	select  count(*) from tenk1, tenk2 where tenk1.unique1 = tenk2.unique1;
---END---
---START---
select  count(*) from tenk1, tenk2 where tenk1.unique1 = tenk2.unique1;
---END---
---START---

reset enable_hashjoin;
---END---
---START---
reset enable_nestloop;
---END---
---START---

-- test gather merge
set enable_hashagg = false;
---END---
---START---

explain (costs off)
   select count(*) from tenk1 group by twenty;
---END---
---START---

select count(*) from tenk1 group by twenty;
---END---
---START---

--test expressions in targetlist are pushed down for gather merge
create function sp_simple_func(var1 integer) returns integer
as $$
begin
        return var1 + 10;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql PARALLEL SAFE;
---END---
---START---

explain (costs off, verbose)
    select ten, sp_simple_func(ten) from tenk1 where ten < 100 order by ten;
---END---
---START---

drop function sp_simple_func(integer);
---END---
---START---

-- test handling of SRFs in targetlist (bug in 10.0)

explain (costs off)
   select count(*), generate_series(1,2) from tenk1 group by twenty;
---END---
---START---

select count(*), generate_series(1,2) from tenk1 group by twenty;
---END---
---START---

-- test gather merge with parallel leader participation disabled
set parallel_leader_participation = off;
---END---
---START---

explain (costs off)
   select count(*) from tenk1 group by twenty;
---END---
---START---

select count(*) from tenk1 group by twenty;
---END---
---START---

reset parallel_leader_participation;
---END---
---START---

--test rescan behavior of gather merge
set enable_material = false;
---END---
---START---

explain (costs off)
select * from
  (select string4, count(unique2)
   from tenk1 group by string4 order by string4) ss
  right join (values (1),(2),(3)) v(x) on true;
---END---
---START---

select * from
  (select string4, count(unique2)
   from tenk1 group by string4 order by string4) ss
  right join (values (1),(2),(3)) v(x) on true;
---END---
---START---

reset enable_material;
---END---
---START---

reset enable_hashagg;
---END---
---START---

-- check parallelized int8 aggregate (bug #14897)
explain (costs off)
select avg(unique1::int8) from tenk1;
---END---
---START---

select avg(unique1::int8) from tenk1;
---END---
---START---

-- gather merge test with a LIMIT
explain (costs off)
  select fivethous from tenk1 order by fivethous limit 4;
---END---
---START---

select fivethous from tenk1 order by fivethous limit 4;
---END---
---START---

-- gather merge test with 0 worker
set max_parallel_workers = 0;
---END---
---START---
explain (costs off)
   select string4 from tenk1 order by string4 limit 5;
---END---
---START---
select string4 from tenk1 order by string4 limit 5;
---END---
---START---

-- gather merge test with 0 workers, with parallel leader
-- participation disabled (the leader will have to run the plan
-- despite the setting)
set parallel_leader_participation = off;
---END---
---START---
explain (costs off)
   select string4 from tenk1 order by string4 limit 5;
---END---
---START---
select string4 from tenk1 order by string4 limit 5;
---END---
---START---

reset parallel_leader_participation;
---END---
---START---
reset max_parallel_workers;
---END---
---START---

SAVEPOINT settings;
---END---
---START---
SET LOCAL debug_parallel_query = 1;
---END---
---START---
explain (costs off)
  select stringu1::int2 from tenk1 where unique1 = 1;
---END---
---START---
ROLLBACK TO SAVEPOINT settings;
---END---
---START---

-- exercise record typmod remapping between backends
CREATE FUNCTION make_record(n int)
  RETURNS RECORD LANGUAGE plpgsql PARALLEL SAFE AS
$$
BEGIN
  RETURN CASE n
           WHEN 1 THEN ROW(1)
           WHEN 2 THEN ROW(1, 2)
           WHEN 3 THEN ROW(1, 2, 3)
           WHEN 4 THEN ROW(1, 2, 3, 4)
           ELSE ROW(1, 2, 3, 4, 5)
         END;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
SAVEPOINT settings;
---END---
---START---
SET LOCAL debug_parallel_query = 1;
---END---
---START---
SELECT make_record(x) FROM (SELECT generate_series(1, 5) x) ss ORDER BY x;
---END---
---START---
ROLLBACK TO SAVEPOINT settings;
---END---
---START---
DROP function make_record(n int);
---END---
---START---

-- test the sanity of parallel query after the active role is dropped.
drop role if exists regress_parallel_worker;
---END---
---START---
create role regress_parallel_worker;
---END---
---START---
set role regress_parallel_worker;
---END---
---START---
reset session authorization;
---END---
---START---
drop role regress_parallel_worker;
---END---
---START---
set debug_parallel_query = 1;
---END---
---START---
select count(*) from tenk1;
---END---
---START---
reset debug_parallel_query;
---END---
---START---
reset role;
---END---
---START---

-- Window function calculation can't be pushed to workers.
explain (costs off, verbose)
  select count(*) from tenk1 a where (unique1, two) in
    (select unique1, row_number() over() from tenk1 b);
---END---
---START---


-- LIMIT/OFFSET within sub-selects can't be pushed to workers.
explain (costs off)
  select * from tenk1 a where two in
    (select two from tenk1 b where stringu1 like '%AAAA' limit 3);
---END---
---START---

-- to increase the parallel query test coverage
SAVEPOINT settings;
---END---
---START---
SET LOCAL debug_parallel_query = 1;
---END---
---START---
EXPLAIN (analyze, timing off, summary off, costs off) SELECT * FROM tenk1;
---END---
---START---
ROLLBACK TO SAVEPOINT settings;
---END---
---START---

-- provoke error in worker
-- (make the error message long enough to require multiple bufferloads)
SAVEPOINT settings;
---END---
---START---
SET LOCAL debug_parallel_query = 1;
---END---
---START---
select (stringu1 || repeat('abcd', 5000))::int2 from tenk1 where unique1 = 1;
---END---
---START---
ROLLBACK TO SAVEPOINT settings;
---END---
---START---

-- test interaction with set-returning functions
SAVEPOINT settings;
---END---
---START---

-- multiple subqueries under a single Gather node
-- must set parallel_setup_cost > 0 to discourage multiple Gather nodes
SET LOCAL parallel_setup_cost = 10;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT unique1 FROM tenk1 WHERE fivethous = tenthous + 1
UNION ALL
SELECT unique1 FROM tenk1 WHERE fivethous = tenthous + 1;
---END---
---START---
ROLLBACK TO SAVEPOINT settings;
---END---
---START---

-- can't use multiple subqueries under a single Gather node due to initPlans
EXPLAIN (COSTS OFF)
SELECT unique1 FROM tenk1 WHERE fivethous =
	(SELECT unique1 FROM tenk1 WHERE fivethous = 1 LIMIT 1)
UNION ALL
SELECT unique1 FROM tenk1 WHERE fivethous =
	(SELECT unique2 FROM tenk1 WHERE fivethous = 1 LIMIT 1)
ORDER BY 1;
---END---
---START---

-- test interaction with SRFs
SELECT * FROM information_schema.foreign_data_wrapper_options
ORDER BY 1, 2, 3;
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
SELECT generate_series(1, two), array(select generate_series(1, two))
  FROM tenk1 ORDER BY tenthous;
---END---
---START---

-- must disallow pushing sort below gather when pathkey contains an SRF
EXPLAIN (VERBOSE, COSTS OFF)
SELECT unnest(ARRAY[]::integer[]) + 1 AS pathkey
  FROM tenk1 t1 JOIN tenk1 t2 ON TRUE
  ORDER BY pathkey;
---END---
---START---

-- test passing expanded-value representations to workers
CREATE FUNCTION make_some_array(int,int) returns int[] as
$$declare x int[];
---END---
---START---
  begin
    x[1] := $1;
---END---
---START---
    x[2] := $2;
---END---
---START---
    return x;
---END---
---START---
  end$$ language plpgsql parallel safe;
---END---
---START---
CREATE TABLE fooarr(f1 text, f2 int[], f3 text);
---END---
---START---
INSERT INTO fooarr VALUES('1', ARRAY[1,2], 'one');
---END---
---START---

PREPARE pstmt(text, int[]) AS SELECT * FROM fooarr WHERE f1 = $1 AND f2 = $2;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE pstmt('1', make_some_array(1,2));
---END---
---START---
EXECUTE pstmt('1', make_some_array(1,2));
---END---
---START---
DEALLOCATE pstmt;
---END---
---START---

-- test interaction between subquery and partial_paths
CREATE VIEW tenk1_vw_sec WITH (security_barrier) AS SELECT * FROM tenk1;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT 1 FROM tenk1_vw_sec
  WHERE (SELECT sum(f1) FROM int4_tbl WHERE f1 < unique1) < 100;
---END---
---START---

rollback;
---END---
