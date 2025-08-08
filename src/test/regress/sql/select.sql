---START---
--
-- SELECT
--

-- btree index
-- awk '{if($1<10){print;}else{next;}}' onek.data | sort +0n -1
--
SELECT * FROM onek
   WHERE onek.unique1 < 10
   ORDER BY onek.unique1;
---END---
---START---
--
-- awk '{if($1<20){print $1,$14;}else{next;}}' onek.data | sort +0nr -1
--
SELECT onek.unique1, onek.stringu1 FROM onek
   WHERE onek.unique1 < 20
   ORDER BY unique1 using >;
---END---
---START---
--
-- awk '{if($1>980){print $1,$14;}else{next;}}' onek.data | sort +1d -2
--
SELECT onek.unique1, onek.stringu1 FROM onek
   WHERE onek.unique1 > 980
   ORDER BY stringu1 using <;
---END---
---START---
--
-- awk '{if($1>980){print $1,$16;}else{next;}}' onek.data |
-- sort +1d -2 +0nr -1
--
SELECT onek.unique1, onek.string4 FROM onek
   WHERE onek.unique1 > 980
   ORDER BY string4 using <, unique1 using >;
---END---
---START---
--
-- awk '{if($1>980){print $1,$16;}else{next;}}' onek.data |
-- sort +1dr -2 +0n -1
--
SELECT onek.unique1, onek.string4 FROM onek
   WHERE onek.unique1 > 980
   ORDER BY string4 using >, unique1 using <;
---END---
---START---
--
-- awk '{if($1<20){print $1,$16;}else{next;}}' onek.data |
-- sort +0nr -1 +1d -2
--
SELECT onek.unique1, onek.string4 FROM onek
   WHERE onek.unique1 < 20
   ORDER BY unique1 using >, string4 using <;
---END---
---START---
--
-- awk '{if($1<20){print $1,$16;}else{next;}}' onek.data |
-- sort +0n -1 +1dr -2
--
SELECT onek.unique1, onek.string4 FROM onek
   WHERE onek.unique1 < 20
   ORDER BY unique1 using <, string4 using >;
---END---
---START---
--
-- test partial btree indexes
--
-- As of 7.2, planner probably won't pick an indexscan without stats,
-- so ANALYZE first.  Also, we want to prevent it from picking a bitmapscan
-- followed by sort, because that could hide index ordering problems.
--
ANALYZE onek2;
---END---
---START---
SET enable_seqscan TO off;
---END---
---START---
SET enable_bitmapscan TO off;
---END---
---START---
SET enable_sort TO off;
---END---
---START---
--
-- awk '{if($1<10){print $0;}else{next;}}' onek.data | sort +0n -1
--
SELECT onek2.* FROM onek2 WHERE onek2.unique1 < 10;
---END---
---START---
--
-- awk '{if($1<20){print $1,$14;}else{next;}}' onek.data | sort +0nr -1
--
SELECT onek2.unique1, onek2.stringu1 FROM onek2
    WHERE onek2.unique1 < 20
    ORDER BY unique1 using >;
---END---
---START---
--
-- awk '{if($1>980){print $1,$14;}else{next;}}' onek.data | sort +1d -2
--
SELECT onek2.unique1, onek2.stringu1 FROM onek2
   WHERE onek2.unique1 > 980;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
RESET enable_sort;
---END---
---START---
--
-- awk '{print $1,$2;}' person.data |
-- awk '{if(NF!=2){print $3,$2;}else{print;}}' - emp.data |
-- awk '{if(NF!=2){print $3,$2;}else{print;}}' - student.data |
-- awk 'BEGIN{FS="      ";}{if(NF!=2){print $4,$5;}else{print;}}' - stud_emp.data
--
-- SELECT name, age FROM person*; ??? check if different
SELECT p.name, p.age FROM person* p;
---END---
---START---
--
-- awk '{print $1,$2;}' person.data |
-- awk '{if(NF!=2){print $3,$2;}else{print;}}' - emp.data |
-- awk '{if(NF!=2){print $3,$2;}else{print;}}' - student.data |
-- awk 'BEGIN{FS="      ";}{if(NF!=1){print $4,$5;}else{print;}}' - stud_emp.data |
-- sort +1nr -2
--
SELECT p.name, p.age FROM person* p ORDER BY age using >, name;
---END---
---START---
--
-- Test some cases involving whole-row Var referencing a subquery
--
select foo from (select 1 offset 0) as foo;
---END---
---START---
select foo from (select null offset 0) as foo;
---END---
---START---
select foo from (select 'xyzzy',1,null offset 0) as foo;
---END---
---START---
--
-- Test VALUES lists
--
select * from onek, (values(147, 'RFAAAA'), (931, 'VJAAAA')) as v (i, j)
    WHERE onek.unique1 = v.i and onek.stringu1 = v.j;
---END---
---START---
-- a more complex case
-- looks like we're coding lisp :-)
select * from onek,
  (values ((select i from
    (values(10000), (2), (389), (1000), (2000), ((select 10029))) as foo(i)
    order by i asc limit 1))) bar (i)
  where onek.unique1 = bar.i;
---END---
---START---
-- try VALUES in a subquery
select * from onek
    where (unique1,ten) in (values (1,1), (20,0), (99,9), (17,99))
    order by unique1;
---END---
---START---
-- VALUES is also legal as a standalone query or a set-operation member
VALUES (1,2), (3,4+4), (7,77.7);
---END---
---START---
VALUES (1,2), (3,4+4), (7,77.7)
UNION ALL
SELECT 2+2, 57
UNION ALL
TABLE int8_tbl;
---END---
---START---
-- corner case: VALUES with no columns
CREATE TEMP TABLE nocols();
---END---
---START---
INSERT INTO nocols DEFAULT VALUES;
---END---
---START---
SELECT * FROM nocols n, LATERAL (VALUES(n.*)) v;
---END---
---START---
--
-- Test ORDER BY options
--

CREATE TEMP TABLE foo (f1 int);
---END---
---START---
INSERT INTO foo VALUES (42),(3),(10),(7),(null),(null),(1);
---END---
---START---
SELECT * FROM foo ORDER BY f1;
---END---
---START---
SELECT * FROM foo ORDER BY f1 ASC;
---END---
---START---
-- same thing
SELECT * FROM foo ORDER BY f1 NULLS FIRST;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC NULLS LAST;
---END---
---START---
-- check if indexscans do the right things
CREATE INDEX fooi ON foo (f1);
---END---
---START---
SET enable_sort = false;
---END---
---START---
SELECT * FROM foo ORDER BY f1;
---END---
---START---
SELECT * FROM foo ORDER BY f1 NULLS FIRST;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC NULLS LAST;
---END---
---START---
DROP INDEX fooi;
---END---
---START---
CREATE INDEX fooi ON foo (f1 DESC);
---END---
---START---
SELECT * FROM foo ORDER BY f1;
---END---
---START---
SELECT * FROM foo ORDER BY f1 NULLS FIRST;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC NULLS LAST;
---END---
---START---
DROP INDEX fooi;
---END---
---START---
CREATE INDEX fooi ON foo (f1 DESC NULLS LAST);
---END---
---START---
SELECT * FROM foo ORDER BY f1;
---END---
---START---
SELECT * FROM foo ORDER BY f1 NULLS FIRST;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC;
---END---
---START---
SELECT * FROM foo ORDER BY f1 DESC NULLS LAST;
---END---
---START---
--
-- Test planning of some cases with partial indexes
--

-- partial index is usable
explain (costs off)
select * from onek2 where unique2 = 11 and stringu1 = 'ATAAAA';
---END---
---START---
select * from onek2 where unique2 = 11 and stringu1 = 'ATAAAA';
---END---
---START---
-- actually run the query with an analyze to use the partial index
explain (costs off, analyze on, timing off, summary off)
select * from onek2 where unique2 = 11 and stringu1 = 'ATAAAA';
---END---
---START---
explain (costs off)
select unique2 from onek2 where unique2 = 11 and stringu1 = 'ATAAAA';
---END---
---START---
select unique2 from onek2 where unique2 = 11 and stringu1 = 'ATAAAA';
---END---
---START---
-- partial index predicate implies clause, so no need for retest
explain (costs off)
select * from onek2 where unique2 = 11 and stringu1 < 'B';
---END---
---START---
select * from onek2 where unique2 = 11 and stringu1 < 'B';
---END---
---START---
explain (costs off)
select unique2 from onek2 where unique2 = 11 and stringu1 < 'B';
---END---
---START---
select unique2 from onek2 where unique2 = 11 and stringu1 < 'B';
---END---
---START---
-- but if it's an update target, must retest anyway
explain (costs off)
select unique2 from onek2 where unique2 = 11 and stringu1 < 'B' for update;
---END---
---START---
select unique2 from onek2 where unique2 = 11 and stringu1 < 'B' for update;
---END---
---START---
-- partial index is not applicable
explain (costs off)
select unique2 from onek2 where unique2 = 11 and stringu1 < 'C';
---END---
---START---
select unique2 from onek2 where unique2 = 11 and stringu1 < 'C';
---END---
---START---
-- partial index implies clause, but bitmap scan must recheck predicate anyway
SET enable_indexscan TO off;
---END---
---START---
explain (costs off)
select unique2 from onek2 where unique2 = 11 and stringu1 < 'B';
---END---
---START---
select unique2 from onek2 where unique2 = 11 and stringu1 < 'B';
---END---
---START---
RESET enable_indexscan;
---END---
---START---
-- check multi-index cases too
explain (costs off)
select unique1, unique2 from onek2
  where (unique2 = 11 or unique1 = 0) and stringu1 < 'B';
---END---
---START---
select unique1, unique2 from onek2
  where (unique2 = 11 or unique1 = 0) and stringu1 < 'B';
---END---
---START---
explain (costs off)
select unique1, unique2 from onek2
  where (unique2 = 11 and stringu1 < 'B') or unique1 = 0;
---END---
---START---
select unique1, unique2 from onek2
  where (unique2 = 11 and stringu1 < 'B') or unique1 = 0;
---END---
---START---
--
-- Test some corner cases that have been known to confuse the planner
--

-- ORDER BY on a constant doesn't really need any sorting
SELECT 1 AS x ORDER BY x;
---END---
---START---
-- But ORDER BY on a set-valued expression does
create function sillysrf(int) returns setof int as
  'values (1),(10),(2),($1)' language sql immutable;
---END---
---START---
select sillysrf(42);
---END---
---START---
select sillysrf(-1) order by 1;
---END---
---START---
drop function sillysrf(int);
---END---
---START---
-- X = X isn't a no-op, it's effectively X IS NOT NULL assuming = is strict
-- (see bug #5084)
select * from (values (2),(null),(1)) v(k) where k = k order by k;
---END---
---START---
select * from (values (2),(null),(1)) v(k) where k = k;
---END---
---START---
-- Test partitioned tables with no partitions, which should be handled the
-- same as the non-inheritance case when expanding its RTE.
create table list_parted_tbl (a int,b int) partition by list (a);
---END---
---START---
create table list_parted_tbl1 partition of list_parted_tbl
  for values in (1) partition by list(b);
---END---
---START---
explain (costs off) select * from list_parted_tbl;
---END---
---START---
drop table list_parted_tbl;
---END---
