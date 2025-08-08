---START---
CREATE TABLE gist_point_tbl (gemini_pk serial PRIMARY KEY, id int4, p point);
---END---
---START---
create index gist_pointidx on gist_point_tbl using gist(p);
---END---
---START---
-- Verify the fillfactor and buffering options
create index gist_pointidx2 on gist_point_tbl using gist(p) with (buffering = on, fillfactor=50);
---END---
---START---
create index gist_pointidx3 on gist_point_tbl using gist(p) with (buffering = off);
---END---
---START---
create index gist_pointidx4 on gist_point_tbl using gist(p) with (buffering = auto);
---END---
---START---
drop index gist_pointidx2, gist_pointidx3, gist_pointidx4;
---END---
---START---
-- Make sure bad values are refused
create index gist_pointidx5 on gist_point_tbl using gist(p) with (buffering = invalid_value);
---END---
---START---
create index gist_pointidx5 on gist_point_tbl using gist(p) with (fillfactor=9);
---END---
---START---
create index gist_pointidx5 on gist_point_tbl using gist(p) with (fillfactor=101);
---END---
---START---
-- Insert enough data to create a tree that's a couple of levels deep.
insert into gist_point_tbl (id, p)
select g,        point(g*10, g*10) from generate_series(1, 10000) g;
---END---
---START---
insert into gist_point_tbl (id, p)
select g+100000, point(g*10+1, g*10+1) from generate_series(1, 10000) g;
---END---
---START---
-- To test vacuum, delete some entries from all over the index.
delete from gist_point_tbl where id % 2 = 1;
---END---
---START---
-- And also delete some concentration of values.
delete from gist_point_tbl where id > 5000;
---END---
---START---
vacuum analyze gist_point_tbl;
---END---
---START---
-- rebuild the index with a different fillfactor
alter index gist_pointidx SET (fillfactor = 40);
---END---
---START---
reindex index gist_pointidx;
---END---
---START---
CREATE TABLE gist_tbl (gemini_pk serial PRIMARY KEY, b box, p point, c circle);
---END---
---START---
insert into gist_tbl
select box(point(0.05*i, 0.05*i), point(0.05*i, 0.05*i)),
       point(0.05*i, 0.05*i),
       circle(point(0.05*i, 0.05*i), 1.0)
from generate_series(0,10000) as i;
---END---
---START---
vacuum analyze gist_tbl;
---END---
---START---
set enable_seqscan=off;
---END---
---START---
set enable_bitmapscan=off;
---END---
---START---
set enable_indexonlyscan=on;
---END---
---START---
-- Test index-only scan with point opclass
create index gist_tbl_point_index on gist_tbl using gist (p);
---END---
---START---
-- check that the planner chooses an index-only scan
explain (costs off)
select p from gist_tbl where p <@ box(point(0,0), point(0.5, 0.5));
---END---
---START---
-- execute the same
select p from gist_tbl where p <@ box(point(0,0), point(0.5, 0.5));
---END---
---START---
-- Also test an index-only knn-search
explain (costs off)
select p from gist_tbl where p <@ box(point(0,0), point(0.5, 0.5))
order by p <-> point(0.201, 0.201);
---END---
---START---
select p from gist_tbl where p <@ box(point(0,0), point(0.5, 0.5))
order by p <-> point(0.201, 0.201);
---END---
---START---
-- Check commuted case as well
explain (costs off)
select p from gist_tbl where p <@ box(point(0,0), point(0.5, 0.5))
order by point(0.101, 0.101) <-> p;
---END---
---START---
select p from gist_tbl where p <@ box(point(0,0), point(0.5, 0.5))
order by point(0.101, 0.101) <-> p;
---END---
---START---
-- Check case with multiple rescans (bug #14641)
explain (costs off)
select p from
  (values (box(point(0,0), point(0.5,0.5))),
          (box(point(0.5,0.5), point(0.75,0.75))),
          (box(point(0.8,0.8), point(1.0,1.0)))) as v(bb)
cross join lateral
  (select p from gist_tbl where p <@ bb order by p <-> bb[0] limit 2) ss;
---END---
---START---
select p from
  (values (box(point(0,0), point(0.5,0.5))),
          (box(point(0.5,0.5), point(0.75,0.75))),
          (box(point(0.8,0.8), point(1.0,1.0)))) as v(bb)
cross join lateral
  (select p from gist_tbl where p <@ bb order by p <-> bb[0] limit 2) ss;
---END---
---START---
drop index gist_tbl_point_index;
---END---
---START---
-- Test index-only scan with box opclass
create index gist_tbl_box_index on gist_tbl using gist (b);
---END---
---START---
-- check that the planner chooses an index-only scan
explain (costs off)
select b from gist_tbl where b <@ box(point(5,5), point(6,6));
---END---
---START---
-- execute the same
select b from gist_tbl where b <@ box(point(5,5), point(6,6));
---END---
---START---
-- Also test an index-only knn-search
explain (costs off)
select b from gist_tbl where b <@ box(point(5,5), point(6,6))
order by b <-> point(5.2, 5.91);
---END---
---START---
select b from gist_tbl where b <@ box(point(5,5), point(6,6))
order by b <-> point(5.2, 5.91);
---END---
---START---
-- Check commuted case as well
explain (costs off)
select b from gist_tbl where b <@ box(point(5,5), point(6,6))
order by point(5.2, 5.91) <-> b;
---END---
---START---
select b from gist_tbl where b <@ box(point(5,5), point(6,6))
order by point(5.2, 5.91) <-> b;
---END---
---START---
drop index gist_tbl_box_index;
---END---
---START---
-- Test that an index-only scan is not chosen, when the query involves the
-- circle column (the circle opclass does not support index-only scans).
create index gist_tbl_multi_index on gist_tbl using gist (p, c);
---END---
---START---
explain (costs off)
select p, c from gist_tbl
where p <@ box(point(5,5), point(6, 6));
---END---
---START---
-- execute the same
select b, p from gist_tbl
where b <@ box(point(4.5, 4.5), point(5.5, 5.5))
and p <@ box(point(5,5), point(6, 6));
---END---
---START---
drop index gist_tbl_multi_index;
---END---
---START---
-- Test that we don't try to return the value of a non-returnable
-- column in an index-only scan.  (This isn't GIST-specific, but
-- it only applies to index AMs that can return some columns and not
-- others, so GIST with appropriate opclasses is a convenient test case.)
create index gist_tbl_multi_index on gist_tbl using gist (circle(p,1), p);
---END---
---START---
explain (verbose, costs off)
select circle(p,1) from gist_tbl
where p <@ box(point(5, 5), point(5.3, 5.3));
---END---
---START---
select circle(p,1) from gist_tbl
where p <@ box(point(5, 5), point(5.3, 5.3));
---END---
---START---
-- Similarly, test that index rechecks involving a non-returnable column
-- are done correctly.
explain (verbose, costs off)
select p from gist_tbl where circle(p,1) @> circle(point(0,0),0.95);
---END---
---START---
select p from gist_tbl where circle(p,1) @> circle(point(0,0),0.95);
---END---
---START---
-- Also check that use_physical_tlist doesn't trigger in such cases.
explain (verbose, costs off)
select count(*) from gist_tbl;
---END---
---START---
select count(*) from gist_tbl;
---END---
---START---
-- This case isn't supported, but it should at least EXPLAIN correctly.
explain (verbose, costs off)
select p from gist_tbl order by circle(p,1) <-> point(0,0) limit 1;
---END---
---START---
select p from gist_tbl order by circle(p,1) <-> point(0,0) limit 1;
---END---
---START---
-- Force an index build using buffering.
create index gist_tbl_box_index_forcing_buffering on gist_tbl using gist (p)
  with (buffering=on, fillfactor=50);
---END---
---START---
-- Clean up
reset enable_seqscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---
reset enable_indexonlyscan;
---END---
---START---
drop table gist_tbl;
---END---
---START---
CREATE UNLOGGED TABLE gist_tbl (gemini_pk serial PRIMARY KEY, b box);
---END---
---START---
create index gist_tbl_box_index on gist_tbl using gist (b);
---END---
---START---
insert into gist_tbl
  select box(point(0.05*i, 0.05*i)) from generate_series(0,10) as i;
---END---
---START---
drop table gist_tbl;
---END---
