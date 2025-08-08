---START---
-- tests for tidrangescans

SET enable_seqscan TO off;
---END---
---START---
CREATE TABLE tidrangescan (gemini_pk serial PRIMARY KEY, id integer, data text);
---END---
---START---
-- empty table
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid < '(1, 0)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid < '(1, 0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid > '(9, 0)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid > '(9, 0)';
---END---
---START---
-- insert enough tuples to fill at least two pages
INSERT INTO tidrangescan SELECT i,repeat('x', 100) FROM generate_series(1,200) AS s(i);
---END---
---START---
-- remove all tuples after the 10th tuple on each page.  Trying to ensure
-- we get the same layout with all CPU architectures and smaller than standard
-- page sizes.
DELETE FROM tidrangescan
WHERE substring(ctid::text FROM ',(\d+)\)')::integer > 10 OR substring(ctid::text FROM '\((\d+),')::integer > 2;
---END---
---START---
VACUUM tidrangescan;
---END---
---START---
-- range scans with upper bound
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid < '(1,0)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid < '(1,0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid <= '(1,5)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid <= '(1,5)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid < '(0,0)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid < '(0,0)';
---END---
---START---
-- range scans with lower bound
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid > '(2,8)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid > '(2,8)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE '(2,8)' < ctid;
---END---
---START---
SELECT ctid FROM tidrangescan WHERE '(2,8)' < ctid;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid >= '(2,8)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid >= '(2,8)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid >= '(100,0)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid >= '(100,0)';
---END---
---START---
-- range scans with both bounds
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE ctid > '(1,4)' AND '(1,7)' >= ctid;
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid > '(1,4)' AND '(1,7)' >= ctid;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid FROM tidrangescan WHERE '(1,7)' >= ctid AND ctid > '(1,4)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE '(1,7)' >= ctid AND ctid > '(1,4)';
---END---
---START---
-- extreme offsets
SELECT ctid FROM tidrangescan WHERE ctid > '(0,65535)' AND ctid < '(1,0)' LIMIT 1;
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid < '(0,0)' LIMIT 1;
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid > '(4294967295,65535)';
---END---
---START---
SELECT ctid FROM tidrangescan WHERE ctid < '(0,0)';
---END---
---START---
-- NULLs in the range cannot return tuples
SELECT ctid FROM tidrangescan WHERE ctid >= (SELECT NULL::tid);
---END---
---START---
-- rescans
EXPLAIN (COSTS OFF)
SELECT t.ctid,t2.c FROM tidrangescan t,
LATERAL (SELECT count(*) c FROM tidrangescan t2 WHERE t2.ctid <= t.ctid) t2
WHERE t.ctid < '(1,0)';
---END---
---START---
SELECT t.ctid,t2.c FROM tidrangescan t,
LATERAL (SELECT count(*) c FROM tidrangescan t2 WHERE t2.ctid <= t.ctid) t2
WHERE t.ctid < '(1,0)';
---END---
---START---
-- cursors

-- Ensure we get a TID Range scan without a Materialize node.
EXPLAIN (COSTS OFF)
DECLARE c SCROLL CURSOR FOR SELECT ctid FROM tidrangescan WHERE ctid < '(1,0)';
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c SCROLL CURSOR FOR SELECT ctid FROM tidrangescan WHERE ctid < '(1,0)';
---END---
---START---
FETCH NEXT c;
---END---
---START---
FETCH NEXT c;
---END---
---START---
FETCH PRIOR c;
---END---
---START---
FETCH FIRST c;
---END---
---START---
FETCH LAST c;
---END---
---START---
COMMIT;
---END---
---START---
DROP TABLE tidrangescan;
---END---
---START---
RESET enable_seqscan;
---END---
