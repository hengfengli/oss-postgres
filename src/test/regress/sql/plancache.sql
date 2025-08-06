---START---
--
-- Tests to exercise the plan caching/invalidation mechanism
--

CREATE TABLE pcachetest AS SELECT * FROM int8_tbl;
---END---
---START---

-- create and use a cached plan
PREPARE prepstmt AS SELECT * FROM pcachetest;
---END---
---START---

EXECUTE prepstmt;
---END---
---START---

-- and one with parameters
PREPARE prepstmt2(bigint) AS SELECT * FROM pcachetest WHERE q1 = $1;
---END---
---START---

EXECUTE prepstmt2(123);
---END---
---START---

-- invalidate the plans and see what happens
DROP TABLE pcachetest;
---END---
---START---

EXECUTE prepstmt;
---END---
---START---
EXECUTE prepstmt2(123);
---END---
---START---

-- recreate the temp table (this demonstrates that the raw plan is
-- purely textual and doesn't depend on OIDs, for instance)
CREATE TABLE pcachetest AS SELECT * FROM int8_tbl ORDER BY 2;
---END---
---START---

EXECUTE prepstmt;
---END---
---START---
EXECUTE prepstmt2(123);
---END---
---START---

-- prepared statements should prevent change in output tupdesc,
-- since clients probably aren't expecting that to change on the fly
ALTER TABLE pcachetest ADD COLUMN q3 bigint;
---END---
---START---

EXECUTE prepstmt;
---END---
---START---
EXECUTE prepstmt2(123);
---END---
---START---

-- but we're nice guys and will let you undo your mistake
ALTER TABLE pcachetest DROP COLUMN q3;
---END---
---START---

EXECUTE prepstmt;
---END---
---START---
EXECUTE prepstmt2(123);
---END---
---START---

-- Try it with a view, which isn't directly used in the resulting plan
-- but should trigger invalidation anyway
CREATE TEMP VIEW pcacheview AS
  SELECT * FROM pcachetest;
---END---
---START---

PREPARE vprep AS SELECT * FROM pcacheview;
---END---
---START---

EXECUTE vprep;
---END---
---START---

CREATE OR REPLACE TEMP VIEW pcacheview AS
  SELECT q1, q2/2 AS q2 FROM pcachetest;
---END---
---START---

EXECUTE vprep;
---END---
---START---

-- Check basic SPI plan invalidation

create function cache_test(int) returns int as $$
declare total int;
---END---
---START---
begin
	create table t1(f1 int);
---END---
---START---
	insert into t1 values($1);
---END---
---START---
	insert into t1 values(11);
---END---
---START---
	insert into t1 values(12);
---END---
---START---
	insert into t1 values(13);
---END---
---START---
	select sum(f1) into total from t1;
---END---
---START---
	drop table t1;
---END---
---START---
	return total;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select cache_test(1);
---END---
---START---
select cache_test(2);
---END---
---START---
select cache_test(3);
---END---
---START---

-- Check invalidation of plpgsql "simple expression"

create temp view v1 as
  select 2+2 as f1;
---END---
---START---

create function cache_test_2() returns int as $$
begin
	return f1 from v1;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select cache_test_2();
---END---
---START---

create or replace temp view v1 as
  select 2+2+4 as f1;
---END---
---START---
select cache_test_2();
---END---
---START---

create or replace temp view v1 as
  select 2+2+4+(select max(unique1) from tenk1) as f1;
---END---
---START---
select cache_test_2();
---END---
---START---

--- Check that change of search_path is honored when re-using cached plan

create schema s1
  create table abc (f1 int);
---END---
---START---

create schema s2
  create table abc (f1 int);
---END---
---START---

insert into s1.abc values(123);
---END---
---START---
insert into s2.abc values(456);
---END---
---START---

set search_path = s1;
---END---
---START---

prepare p1 as select f1 from abc;
---END---
---START---

execute p1;
---END---
---START---

set search_path = s2;
---END---
---START---

select f1 from abc;
---END---
---START---

execute p1;
---END---
---START---

alter table s1.abc add column f2 float8;   -- force replan

execute p1;
---END---
---START---

drop schema s1 cascade;
---END---
---START---
drop schema s2 cascade;
---END---
---START---

reset search_path;
---END---
---START---

-- Check that invalidation deals with regclass constants

create temp sequence seq;
---END---
---START---

prepare p2 as select nextval('seq');
---END---
---START---

execute p2;
---END---
---START---

drop sequence seq;
---END---
---START---

create temp sequence seq;
---END---
---START---

execute p2;
---END---
---START---

-- Check DDL via SPI, immediately followed by SPI plan re-use
-- (bug in original coding)

create function cachebug() returns void as $$
declare r int;
---END---
---START---
begin
  drop table if exists temptable cascade;
---END---
---START---
  create table temptable as select * from generate_series(1,3) as f1;
---END---
---START---
  create temp view vv as select * from temptable;
---END---
---START---
  for r in select * from vv loop
    raise notice '%', r;
---END---
---START---
  end loop;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select cachebug();
---END---
---START---
select cachebug();
---END---
---START---

-- Check that addition or removal of any partition is correctly dealt with by
-- default partition table when it is being used in prepared statement.
create table pc_list_parted (a int) partition by list(a);
---END---
---START---
create table pc_list_part_null partition of pc_list_parted for values in (null);
---END---
---START---
create table pc_list_part_1 partition of pc_list_parted for values in (1);
---END---
---START---
create table pc_list_part_def partition of pc_list_parted default;
---END---
---START---
prepare pstmt_def_insert (int) as insert into pc_list_part_def values($1);
---END---
---START---
-- should fail
execute pstmt_def_insert(null);
---END---
---START---
execute pstmt_def_insert(1);
---END---
---START---
create table pc_list_part_2 partition of pc_list_parted for values in (2);
---END---
---START---
execute pstmt_def_insert(2);
---END---
---START---
alter table pc_list_parted detach partition pc_list_part_null;
---END---
---START---
-- should be ok
execute pstmt_def_insert(null);
---END---
---START---
drop table pc_list_part_1;
---END---
---START---
-- should be ok
execute pstmt_def_insert(1);
---END---
---START---
drop table pc_list_parted, pc_list_part_null;
---END---
---START---
deallocate pstmt_def_insert;
---END---
---START---

-- Test plan_cache_mode

create table test_mode (a int);
---END---
---START---
insert into test_mode select 1 from generate_series(1,1000) union all select 2;
---END---
---START---
create index on test_mode (a);
---END---
---START---
analyze test_mode;
---END---
---START---

prepare test_mode_pp (int) as select count(*) from test_mode where a = $1;
---END---
---START---
select name, generic_plans, custom_plans from pg_prepared_statements
  where  name = 'test_mode_pp';
---END---
---START---

-- up to 5 executions, custom plan is used
set plan_cache_mode to auto;
---END---
---START---
explain (costs off) execute test_mode_pp(2);
---END---
---START---
select name, generic_plans, custom_plans from pg_prepared_statements
  where  name = 'test_mode_pp';
---END---
---START---

-- force generic plan
set plan_cache_mode to force_generic_plan;
---END---
---START---
explain (costs off) execute test_mode_pp(2);
---END---
---START---
select name, generic_plans, custom_plans from pg_prepared_statements
  where  name = 'test_mode_pp';
---END---
---START---

-- get to generic plan by 5 executions
set plan_cache_mode to auto;
---END---
---START---
execute test_mode_pp(1); -- 1x
execute test_mode_pp(1); -- 2x
execute test_mode_pp(1); -- 3x
execute test_mode_pp(1); -- 4x
select name, generic_plans, custom_plans from pg_prepared_statements
  where  name = 'test_mode_pp';
---END---
---START---
execute test_mode_pp(1); -- 5x
select name, generic_plans, custom_plans from pg_prepared_statements
  where  name = 'test_mode_pp';
---END---
---START---

-- we should now get a really bad plan
explain (costs off) execute test_mode_pp(2);
---END---
---START---

-- but we can force a custom plan
set plan_cache_mode to force_custom_plan;
---END---
---START---
explain (costs off) execute test_mode_pp(2);
---END---
---START---
select name, generic_plans, custom_plans from pg_prepared_statements
  where  name = 'test_mode_pp';
---END---
---START---

drop table test_mode;

drop table if exists pcachetest, t1, temptable;
---END---
