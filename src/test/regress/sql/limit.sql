---START---
--
-- LIMIT
-- Check the LIMIT/OFFSET feature of SELECT
--

SELECT ''::text AS two, unique1, unique2, stringu1
		FROM onek WHERE unique1 > 50
		ORDER BY unique1 LIMIT 2;
---END---
---START---
SELECT ''::text AS five, unique1, unique2, stringu1
		FROM onek WHERE unique1 > 60
		ORDER BY unique1 LIMIT 5;
---END---
---START---
SELECT ''::text AS two, unique1, unique2, stringu1
		FROM onek WHERE unique1 > 60 AND unique1 < 63
		ORDER BY unique1 LIMIT 5;
---END---
---START---
SELECT ''::text AS three, unique1, unique2, stringu1
		FROM onek WHERE unique1 > 100
		ORDER BY unique1 LIMIT 3 OFFSET 20;
---END---
---START---
SELECT ''::text AS zero, unique1, unique2, stringu1
		FROM onek WHERE unique1 < 50
		ORDER BY unique1 DESC LIMIT 8 OFFSET 99;
---END---
---START---
SELECT ''::text AS eleven, unique1, unique2, stringu1
		FROM onek WHERE unique1 < 50
		ORDER BY unique1 DESC LIMIT 20 OFFSET 39;
---END---
---START---
SELECT ''::text AS ten, unique1, unique2, stringu1
		FROM onek
		ORDER BY unique1 OFFSET 990;
---END---
---START---
SELECT ''::text AS five, unique1, unique2, stringu1
		FROM onek
		ORDER BY unique1 OFFSET 990 LIMIT 5;
---END---
---START---
SELECT ''::text AS five, unique1, unique2, stringu1
		FROM onek
		ORDER BY unique1 LIMIT 5 OFFSET 900;
---END---
---START---

-- Test null limit and offset.  The planner would discard a simple null
-- constant, so to ensure executor is exercised, do this:
select * from int8_tbl limit (case when random() < 0.5 then null::bigint end);
---END---
---START---
select * from int8_tbl offset (case when random() < 0.5 then null::bigint end);
---END---
---START---

-- Test assorted cases involving backwards fetch from a LIMIT plan node
begin;
---END---
---START---

declare c1 cursor for select * from int8_tbl limit 10;
---END---
---START---
fetch all in c1;
---END---
---START---
fetch 1 in c1;
---END---
---START---
fetch backward 1 in c1;
---END---
---START---
fetch backward all in c1;
---END---
---START---
fetch backward 1 in c1;
---END---
---START---
fetch all in c1;
---END---
---START---

declare c2 cursor for select * from int8_tbl limit 3;
---END---
---START---
fetch all in c2;
---END---
---START---
fetch 1 in c2;
---END---
---START---
fetch backward 1 in c2;
---END---
---START---
fetch backward all in c2;
---END---
---START---
fetch backward 1 in c2;
---END---
---START---
fetch all in c2;
---END---
---START---

declare c3 cursor for select * from int8_tbl offset 3;
---END---
---START---
fetch all in c3;
---END---
---START---
fetch 1 in c3;
---END---
---START---
fetch backward 1 in c3;
---END---
---START---
fetch backward all in c3;
---END---
---START---
fetch backward 1 in c3;
---END---
---START---
fetch all in c3;
---END---
---START---

declare c4 cursor for select * from int8_tbl offset 10;
---END---
---START---
fetch all in c4;
---END---
---START---
fetch 1 in c4;
---END---
---START---
fetch backward 1 in c4;
---END---
---START---
fetch backward all in c4;
---END---
---START---
fetch backward 1 in c4;
---END---
---START---
fetch all in c4;
---END---
---START---

declare c5 cursor for select * from int8_tbl order by q1 fetch first 2 rows with ties;
---END---
---START---
fetch all in c5;
---END---
---START---
fetch 1 in c5;
---END---
---START---
fetch backward 1 in c5;
---END---
---START---
fetch backward 1 in c5;
---END---
---START---
fetch all in c5;
---END---
---START---
fetch backward all in c5;
---END---
---START---
fetch all in c5;
---END---
---START---
fetch backward all in c5;
---END---
---START---

rollback;
---END---
---START---

-- Stress test for variable LIMIT in conjunction with bounded-heap sorting

SELECT
  (SELECT n
     FROM (VALUES (1)) AS x,
          (SELECT n FROM generate_series(1,10) AS n
             ORDER BY n LIMIT 1 OFFSET s-1) AS y) AS z
  FROM generate_series(1,10) AS s;
---END---
---START---

--
-- Test behavior of volatile and set-returning functions in conjunction
-- with ORDER BY and LIMIT.
--

create temp sequence testseq;
---END---
---START---

explain (verbose, costs off)
select unique1, unique2, nextval('testseq')
  from tenk1 order by unique2 limit 10;
---END---
---START---

select unique1, unique2, nextval('testseq')
  from tenk1 order by unique2 limit 10;
---END---
---START---

select currval('testseq');
---END---
---START---

explain (verbose, costs off)
select unique1, unique2, nextval('testseq')
  from tenk1 order by tenthous limit 10;
---END---
---START---

select unique1, unique2, nextval('testseq')
  from tenk1 order by tenthous limit 10;
---END---
---START---

select currval('testseq');
---END---
---START---

explain (verbose, costs off)
select unique1, unique2, generate_series(1,10)
  from tenk1 order by unique2 limit 7;
---END---
---START---

select unique1, unique2, generate_series(1,10)
  from tenk1 order by unique2 limit 7;
---END---
---START---

explain (verbose, costs off)
select unique1, unique2, generate_series(1,10)
  from tenk1 order by tenthous limit 7;
---END---
---START---

select unique1, unique2, generate_series(1,10)
  from tenk1 order by tenthous limit 7;
---END---
---START---

-- use of random() is to keep planner from folding the expressions together
explain (verbose, costs off)
select generate_series(0,2) as s1, generate_series((random()*.1)::int,2) as s2;
---END---
---START---

select generate_series(0,2) as s1, generate_series((random()*.1)::int,2) as s2;
---END---
---START---

explain (verbose, costs off)
select generate_series(0,2) as s1, generate_series((random()*.1)::int,2) as s2
order by s2 desc;
---END---
---START---

select generate_series(0,2) as s1, generate_series((random()*.1)::int,2) as s2
order by s2 desc;
---END---
---START---

-- test for failure to set all aggregates' aggtranstype
explain (verbose, costs off)
select sum(tenthous) as s1, sum(tenthous) + random()*0 as s2
  from tenk1 group by thousand order by thousand limit 3;
---END---
---START---

select sum(tenthous) as s1, sum(tenthous) + random()*0 as s2
  from tenk1 group by thousand order by thousand limit 3;
---END---
---START---

--
-- FETCH FIRST
-- Check the WITH TIES clause
--

SELECT  thousand
		FROM onek WHERE thousand < 5
		ORDER BY thousand FETCH FIRST 2 ROW WITH TIES;
---END---
---START---

SELECT  thousand
		FROM onek WHERE thousand < 5
		ORDER BY thousand FETCH FIRST ROWS WITH TIES;
---END---
---START---

SELECT  thousand
		FROM onek WHERE thousand < 5
		ORDER BY thousand FETCH FIRST 1 ROW WITH TIES;
---END---
---START---

SELECT  thousand
		FROM onek WHERE thousand < 5
		ORDER BY thousand FETCH FIRST 2 ROW ONLY;
---END---
---START---

-- SKIP LOCKED and WITH TIES are incompatible
SELECT  thousand
		FROM onek WHERE thousand < 5
		ORDER BY thousand FETCH FIRST 1 ROW WITH TIES FOR UPDATE SKIP LOCKED;
---END---
---START---

-- should fail
SELECT ''::text AS two, unique1, unique2, stringu1
		FROM onek WHERE unique1 > 50
		FETCH FIRST 2 ROW WITH TIES;
---END---
---START---

-- test ruleutils
CREATE VIEW limit_thousand_v_1 AS SELECT thousand FROM onek WHERE thousand < 995
		ORDER BY thousand FETCH FIRST 5 ROWS WITH TIES OFFSET 10;
---END---
---START---
\d+ limit_thousand_v_1
CREATE VIEW limit_thousand_v_2 AS SELECT thousand FROM onek WHERE thousand < 995
		ORDER BY thousand OFFSET 10 FETCH FIRST 5 ROWS ONLY;
---END---
---START---
\d+ limit_thousand_v_2
CREATE VIEW limit_thousand_v_3 AS SELECT thousand FROM onek WHERE thousand < 995
		ORDER BY thousand FETCH FIRST NULL ROWS WITH TIES;		-- fails
CREATE VIEW limit_thousand_v_3 AS SELECT thousand FROM onek WHERE thousand < 995
		ORDER BY thousand FETCH FIRST (NULL+1) ROWS WITH TIES;
---END---
---START---
\d+ limit_thousand_v_3
CREATE VIEW limit_thousand_v_4 AS SELECT thousand FROM onek WHERE thousand < 995
		ORDER BY thousand FETCH FIRST NULL ROWS ONLY;
---END---
