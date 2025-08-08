---START---
--
-- SELECT_DISTINCT
--

--
-- awk '{print $3;}' onek.data | sort -n | uniq
--
SELECT DISTINCT two FROM onek ORDER BY 1;
---END---
---START---
--
-- awk '{print $5;}' onek.data | sort -n | uniq
--
SELECT DISTINCT ten FROM onek ORDER BY 1;
---END---
---START---
--
-- awk '{print $16;}' onek.data | sort -d | uniq
--
SELECT DISTINCT string4 FROM onek ORDER BY 1;
---END---
---START---
--
-- awk '{print $3,$16,$5;}' onek.data | sort -d | uniq |
-- sort +0n -1 +1d -2 +2n -3
--
SELECT DISTINCT two, string4, ten
   FROM onek
   ORDER BY two using <, string4 using <, ten using <;
---END---
---START---
--
-- awk '{print $2;}' person.data |
-- awk '{if(NF!=1){print $2;}else{print;}}' - emp.data |
-- awk '{if(NF!=1){print $2;}else{print;}}' - student.data |
-- awk 'BEGIN{FS="      ";}{if(NF!=1){print $5;}else{print;}}' - stud_emp.data |
-- sort -n -r | uniq
--
SELECT DISTINCT p.age FROM person* p ORDER BY age using >;
---END---
---START---
--
-- Check mentioning same column more than once
--

EXPLAIN (VERBOSE, COSTS OFF)
SELECT count(*) FROM
  (SELECT DISTINCT two, four, two FROM tenk1) ss;
---END---
---START---
SELECT count(*) FROM
  (SELECT DISTINCT two, four, two FROM tenk1) ss;
---END---
---START---
--
-- Compare results between plans using sorting and plans using hash
-- aggregation. Force spilling in both cases by setting work_mem low.
--

SET work_mem='64kB';
---END---
---START---
-- Produce results with sorting.

SET enable_hashagg=FALSE;
---END---
---START---
SET jit_above_cost=0;
---END---
---START---
EXPLAIN (costs off)
SELECT DISTINCT g%1000 FROM generate_series(0,9999) g;
---END---
---START---
CREATE TABLE distinct_group_1 AS
SELECT DISTINCT g%1000 FROM generate_series(0,9999) g;
---END---
---START---
SET jit_above_cost TO DEFAULT;
---END---
---START---
CREATE TABLE distinct_group_2 AS
SELECT DISTINCT (g%1000)::text FROM generate_series(0,9999) g;
---END---
---START---
SET enable_seqscan = 0;
---END---
---START---
-- Check to see we get an incremental sort plan
EXPLAIN (costs off)
SELECT DISTINCT hundred, two FROM tenk1;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
SET enable_hashagg=TRUE;
---END---
---START---
-- Produce results with hash aggregation.

SET enable_sort=FALSE;
---END---
---START---
SET jit_above_cost=0;
---END---
---START---
EXPLAIN (costs off)
SELECT DISTINCT g%1000 FROM generate_series(0,9999) g;
---END---
---START---
CREATE TABLE distinct_hash_1 AS
SELECT DISTINCT g%1000 FROM generate_series(0,9999) g;
---END---
---START---
SET jit_above_cost TO DEFAULT;
---END---
---START---
CREATE TABLE distinct_hash_2 AS
SELECT DISTINCT (g%1000)::text FROM generate_series(0,9999) g;
---END---
---START---
SET enable_sort=TRUE;
---END---
---START---
SET work_mem TO DEFAULT;
---END---
---START---
-- Compare results

(SELECT * FROM distinct_hash_1 EXCEPT SELECT * FROM distinct_group_1)
  UNION ALL
(SELECT * FROM distinct_group_1 EXCEPT SELECT * FROM distinct_hash_1);
---END---
---START---
(SELECT * FROM distinct_hash_1 EXCEPT SELECT * FROM distinct_group_1)
  UNION ALL
(SELECT * FROM distinct_group_1 EXCEPT SELECT * FROM distinct_hash_1);
---END---
---START---
DROP TABLE distinct_hash_1;
---END---
---START---
DROP TABLE distinct_hash_2;
---END---
---START---
DROP TABLE distinct_group_1;
---END---
---START---
DROP TABLE distinct_group_2;
---END---
---START---
-- Test parallel DISTINCT
SET parallel_tuple_cost=0;
---END---
---START---
SET parallel_setup_cost=0;
---END---
---START---
SET min_parallel_table_scan_size=0;
---END---
---START---
SET max_parallel_workers_per_gather=2;
---END---
---START---
-- Ensure we get a parallel plan
EXPLAIN (costs off)
SELECT DISTINCT four FROM tenk1;
---END---
---START---
-- Ensure the parallel plan produces the correct results
SELECT DISTINCT four FROM tenk1;
---END---
---START---
CREATE OR REPLACE FUNCTION distinct_func(a INT) RETURNS INT AS $$
  BEGIN
    RETURN a;
  END;
$$ LANGUAGE plpgsql PARALLEL UNSAFE;
---END---
---START---
-- Ensure we don't do parallel distinct with a parallel unsafe function
EXPLAIN (COSTS OFF)
SELECT DISTINCT distinct_func(1) FROM tenk1;
---END---
---START---
-- make the function parallel safe
CREATE OR REPLACE FUNCTION distinct_func(a INT) RETURNS INT AS $$
  BEGIN
    RETURN a;
  END;
$$ LANGUAGE plpgsql PARALLEL SAFE;
---END---
---START---
-- Ensure we do parallel distinct now that the function is parallel safe
EXPLAIN (COSTS OFF)
SELECT DISTINCT distinct_func(1) FROM tenk1;
---END---
---START---
RESET max_parallel_workers_per_gather;
---END---
---START---
RESET min_parallel_table_scan_size;
---END---
---START---
RESET parallel_setup_cost;
---END---
---START---
RESET parallel_tuple_cost;
---END---
---START---
--
-- Test the planner's ability to use a LIMIT 1 instead of a Unique node when
-- all of the distinct_pathkeys have been marked as redundant
--

-- Ensure we get a plan with a Limit 1
EXPLAIN (COSTS OFF)
SELECT DISTINCT four FROM tenk1 WHERE four = 0;
---END---
---START---
-- Ensure the above gives us the correct result
SELECT DISTINCT four FROM tenk1 WHERE four = 0;
---END---
---START---
-- Ensure we get a plan with a Limit 1
EXPLAIN (COSTS OFF)
SELECT DISTINCT four FROM tenk1 WHERE four = 0 AND two <> 0;
---END---
---START---
-- Ensure no rows are returned
SELECT DISTINCT four FROM tenk1 WHERE four = 0 AND two <> 0;
---END---
---START---
-- Ensure we get a plan with a Limit 1 when the SELECT list contains constants
EXPLAIN (COSTS OFF)
SELECT DISTINCT four,1,2,3 FROM tenk1 WHERE four = 0;
---END---
---START---
-- Ensure we only get 1 row
SELECT DISTINCT four,1,2,3 FROM tenk1 WHERE four = 0;
---END---
---START---
--
-- Also, some tests of IS DISTINCT FROM, which doesn't quite deserve its
-- very own regression file.
--

CREATE TEMP TABLE disttable (f1 integer);
---END---
---START---
INSERT INTO DISTTABLE VALUES(1);
---END---
---START---
INSERT INTO DISTTABLE VALUES(2);
---END---
---START---
INSERT INTO DISTTABLE VALUES(3);
---END---
---START---
INSERT INTO DISTTABLE VALUES(NULL);
---END---
---START---
-- basic cases
SELECT f1, f1 IS DISTINCT FROM 2 as "not 2" FROM disttable;
---END---
---START---
SELECT f1, f1 IS DISTINCT FROM NULL as "not null" FROM disttable;
---END---
---START---
SELECT f1, f1 IS DISTINCT FROM f1 as "false" FROM disttable;
---END---
---START---
SELECT f1, f1 IS DISTINCT FROM f1+1 as "not null" FROM disttable;
---END---
---START---
-- check that optimizer constant-folds it properly
SELECT 1 IS DISTINCT FROM 2 as "yes";
---END---
---START---
SELECT 2 IS DISTINCT FROM 2 as "no";
---END---
---START---
SELECT 2 IS DISTINCT FROM null as "yes";
---END---
---START---
SELECT null IS DISTINCT FROM null as "no";
---END---
---START---
-- negated form
SELECT 1 IS NOT DISTINCT FROM 2 as "no";
---END---
---START---
SELECT 2 IS NOT DISTINCT FROM 2 as "yes";
---END---
---START---
SELECT 2 IS NOT DISTINCT FROM null as "no";
---END---
---START---
SELECT null IS NOT DISTINCT FROM null as "yes";
---END---
