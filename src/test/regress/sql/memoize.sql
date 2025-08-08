---START---
-- Perform tests on the Memoize node.

-- The cache hits/misses/evictions from the Memoize node can vary between
-- machines.  Let's just replace the number with an 'N'.  In order to allow us
-- to perform validation when the measure was zero, we replace a zero value
-- with "Zero".  All other numbers are replaced with 'N'.
create function explain_memoize(query text, hide_hitmiss bool) returns setof text
language plpgsql as
$$
declare
    ln text;
begin
    for ln in
        execute format('explain (analyze, costs off, summary off, timing off) %s',
            query)
    loop
        if hide_hitmiss = true then
                ln := regexp_replace(ln, 'Hits: 0', 'Hits: Zero');
                ln := regexp_replace(ln, 'Hits: \d+', 'Hits: N');
                ln := regexp_replace(ln, 'Misses: 0', 'Misses: Zero');
                ln := regexp_replace(ln, 'Misses: \d+', 'Misses: N');
        end if;
        ln := regexp_replace(ln, 'Evictions: 0', 'Evictions: Zero');
        ln := regexp_replace(ln, 'Evictions: \d+', 'Evictions: N');
        ln := regexp_replace(ln, 'Memory Usage: \d+', 'Memory Usage: N');
	ln := regexp_replace(ln, 'Heap Fetches: \d+', 'Heap Fetches: N');
	ln := regexp_replace(ln, 'loops=\d+', 'loops=N');
        return next ln;
    end loop;
end;
$$;
---END---
---START---
-- Ensure we get a memoize node on the inner side of the nested loop
SET enable_hashjoin TO off;
---END---
---START---
SET enable_bitmapscan TO off;
---END---
---START---
SELECT explain_memoize('
SELECT COUNT(*),AVG(t1.unique1) FROM tenk1 t1
INNER JOIN tenk1 t2 ON t1.unique1 = t2.twenty
WHERE t2.unique1 < 1000;', false);
---END---
---START---
-- And check we get the expected results.
SELECT COUNT(*),AVG(t1.unique1) FROM tenk1 t1
INNER JOIN tenk1 t2 ON t1.unique1 = t2.twenty
WHERE t2.unique1 < 1000;
---END---
---START---
-- Try with LATERAL joins
SELECT explain_memoize('
SELECT COUNT(*),AVG(t2.unique1) FROM tenk1 t1,
LATERAL (SELECT t2.unique1 FROM tenk1 t2
         WHERE t1.twenty = t2.unique1 OFFSET 0) t2
WHERE t1.unique1 < 1000;', false);
---END---
---START---
-- And check we get the expected results.
SELECT COUNT(*),AVG(t2.unique1) FROM tenk1 t1,
LATERAL (SELECT t2.unique1 FROM tenk1 t2
         WHERE t1.twenty = t2.unique1 OFFSET 0) t2
WHERE t1.unique1 < 1000;
---END---
---START---
-- Reduce work_mem and hash_mem_multiplier so that we see some cache evictions
SET work_mem TO '64kB';
---END---
---START---
SET hash_mem_multiplier TO 1.0;
---END---
---START---
SET enable_mergejoin TO off;
---END---
---START---
-- Ensure we get some evictions.  We're unable to validate the hits and misses
-- here as the number of entries that fit in the cache at once will vary
-- between different machines.
SELECT explain_memoize('
SELECT COUNT(*),AVG(t1.unique1) FROM tenk1 t1
INNER JOIN tenk1 t2 ON t1.unique1 = t2.thousand
WHERE t2.unique1 < 1200;', true);
---END---
---START---
CREATE TABLE flt (_gemini_pk serial PRIMARY KEY, f double precision);
---END---
---START---
CREATE INDEX flt_f_idx ON flt (f);
---END---
---START---
INSERT INTO flt VALUES('-0.0'::float),('+0.0'::float);
---END---
---START---
ANALYZE flt;
---END---
---START---
SET enable_seqscan TO off;
---END---
---START---
-- Ensure memoize operates in logical mode
SELECT explain_memoize('
SELECT * FROM flt f1 INNER JOIN flt f2 ON f1.f = f2.f;', false);
---END---
---START---
-- Ensure memoize operates in binary mode
SELECT explain_memoize('
SELECT * FROM flt f1 INNER JOIN flt f2 ON f1.f >= f2.f;', false);
---END---
---START---
DROP TABLE flt;
---END---
---START---
CREATE TABLE strtest (_gemini_pk serial PRIMARY KEY, n name, t text);
---END---
---START---
CREATE INDEX strtest_n_idx ON strtest (n);
---END---
---START---
CREATE INDEX strtest_t_idx ON strtest (t);
---END---
---START---
INSERT INTO strtest VALUES('one','one'),('two','two'),('three',repeat(fipshash('three'),100));
---END---
---START---
-- duplicate rows so we get some cache hits
INSERT INTO strtest SELECT * FROM strtest;
---END---
---START---
ANALYZE strtest;
---END---
---START---
-- Ensure we get 3 hits and 3 misses
SELECT explain_memoize('
SELECT * FROM strtest s1 INNER JOIN strtest s2 ON s1.n >= s2.n;', false);
---END---
---START---
-- Ensure we get 3 hits and 3 misses
SELECT explain_memoize('
SELECT * FROM strtest s1 INNER JOIN strtest s2 ON s1.t >= s2.t;', false);
---END---
---START---
DROP TABLE strtest;
---END---
---START---
-- Ensure memoize works with partitionwise join
SET enable_partitionwise_join TO on;
---END---
---START---
CREATE TABLE prt (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt_p1 PARTITION OF prt FOR VALUES FROM (0) TO (10);
---END---
---START---
CREATE TABLE prt_p2 PARTITION OF prt FOR VALUES FROM (10) TO (20);
---END---
---START---
INSERT INTO prt VALUES (0), (0), (0), (0);
---END---
---START---
INSERT INTO prt VALUES (10), (10), (10), (10);
---END---
---START---
CREATE INDEX iprt_p1_a ON prt_p1 (a);
---END---
---START---
CREATE INDEX iprt_p2_a ON prt_p2 (a);
---END---
---START---
ANALYZE prt;
---END---
---START---
SELECT explain_memoize('
SELECT * FROM prt t1 INNER JOIN prt t2 ON t1.a = t2.a;', false);
---END---
---START---
-- Ensure memoize works with parameterized union-all Append path
SET enable_partitionwise_join TO off;
---END---
---START---
SELECT explain_memoize('
SELECT * FROM prt_p1 t1 INNER JOIN
(SELECT * FROM prt_p1 UNION ALL SELECT * FROM prt_p2) t2
ON t1.a = t2.a;', false);
---END---
---START---
DROP TABLE prt;
---END---
---START---
RESET enable_partitionwise_join;
---END---
---START---
-- Exercise Memoize code that flushes the cache when a parameter changes which
-- is not part of the cache key.

-- Ensure we get a Memoize plan
EXPLAIN (COSTS OFF)
SELECT unique1 FROM tenk1 t0
WHERE unique1 < 3
  AND EXISTS (
	SELECT 1 FROM tenk1 t1
	INNER JOIN tenk1 t2 ON t1.unique1 = t2.hundred
	WHERE t0.ten = t1.twenty AND t0.two <> t2.four OFFSET 0);
---END---
---START---
-- Ensure the above query returns the correct result
SELECT unique1 FROM tenk1 t0
WHERE unique1 < 3
  AND EXISTS (
	SELECT 1 FROM tenk1 t1
	INNER JOIN tenk1 t2 ON t1.unique1 = t2.hundred
	WHERE t0.ten = t1.twenty AND t0.two <> t2.four OFFSET 0);
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_mergejoin;
---END---
---START---
RESET work_mem;
---END---
---START---
RESET hash_mem_multiplier;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
RESET enable_hashjoin;
---END---
---START---
-- Test parallel plans with Memoize
SET min_parallel_table_scan_size TO 0;
---END---
---START---
SET parallel_setup_cost TO 0;
---END---
---START---
SET parallel_tuple_cost TO 0;
---END---
---START---
SET max_parallel_workers_per_gather TO 2;
---END---
---START---
-- Ensure we get a parallel plan.
EXPLAIN (COSTS OFF)
SELECT COUNT(*),AVG(t2.unique1) FROM tenk1 t1,
LATERAL (SELECT t2.unique1 FROM tenk1 t2 WHERE t1.twenty = t2.unique1) t2
WHERE t1.unique1 < 1000;
---END---
---START---
-- And ensure the parallel plan gives us the correct results.
SELECT COUNT(*),AVG(t2.unique1) FROM tenk1 t1,
LATERAL (SELECT t2.unique1 FROM tenk1 t2 WHERE t1.twenty = t2.unique1) t2
WHERE t1.unique1 < 1000;
---END---
---START---
RESET max_parallel_workers_per_gather;
---END---
---START---
RESET parallel_tuple_cost;
---END---
---START---
RESET parallel_setup_cost;
---END---
---START---
RESET min_parallel_table_scan_size;
---END---
