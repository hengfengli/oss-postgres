---START---
--
-- PARALLEL
--

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

--
-- Test write operations that has an underlying query that is eligible
-- for parallel plans
--
explain (costs off) create table parallel_write as
    select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---
create table parallel_write as
    select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---
drop table parallel_write;
---END---
---START---

explain (costs off) select length(stringu1) into parallel_write
    from tenk1 group by length(stringu1);
---END---
---START---
select length(stringu1) into parallel_write
    from tenk1 group by length(stringu1);
---END---
---START---
drop table parallel_write;
---END---
---START---

explain (costs off) create materialized view parallel_mat_view as
    select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---
create materialized view parallel_mat_view as
    select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---
create unique index on parallel_mat_view(length);
---END---
---START---
refresh materialized view parallel_mat_view;
---END---
---START---
refresh materialized view concurrently parallel_mat_view;
---END---
---START---
drop materialized view parallel_mat_view;
---END---
---START---

prepare prep_stmt as select length(stringu1) from tenk1 group by length(stringu1);
---END---
---START---
explain (costs off) create table parallel_write as execute prep_stmt;
---END---
---START---
create table parallel_write as execute prep_stmt;
---END---
---START---
drop table parallel_write;
---END---
---START---

rollback;
---END---
