---START---
CREATE TABLE tidscan (gemini_pk serial PRIMARY KEY, id integer);
---END---
---START---
-- only insert a few rows, we don't want to spill onto a second table page
INSERT INTO tidscan VALUES (1), (2), (3);
---END---
---START---
-- show ctids
SELECT ctid, * FROM tidscan;
---END---
---START---
-- ctid equality - implemented as tidscan
EXPLAIN (COSTS OFF)
SELECT ctid, * FROM tidscan WHERE ctid = '(0,1)';
---END---
---START---
SELECT ctid, * FROM tidscan WHERE ctid = '(0,1)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT ctid, * FROM tidscan WHERE '(0,1)' = ctid;
---END---
---START---
SELECT ctid, * FROM tidscan WHERE '(0,1)' = ctid;
---END---
---START---
-- OR'd clauses
EXPLAIN (COSTS OFF)
SELECT ctid, * FROM tidscan WHERE ctid = '(0,2)' OR '(0,1)' = ctid;
---END---
---START---
SELECT ctid, * FROM tidscan WHERE ctid = '(0,2)' OR '(0,1)' = ctid;
---END---
---START---
-- ctid = ScalarArrayOp - implemented as tidscan
EXPLAIN (COSTS OFF)
SELECT ctid, * FROM tidscan WHERE ctid = ANY(ARRAY['(0,1)', '(0,2)']::tid[]);
---END---
---START---
SELECT ctid, * FROM tidscan WHERE ctid = ANY(ARRAY['(0,1)', '(0,2)']::tid[]);
---END---
---START---
-- ctid != ScalarArrayOp - can't be implemented as tidscan
EXPLAIN (COSTS OFF)
SELECT ctid, * FROM tidscan WHERE ctid != ANY(ARRAY['(0,1)', '(0,2)']::tid[]);
---END---
---START---
SELECT ctid, * FROM tidscan WHERE ctid != ANY(ARRAY['(0,1)', '(0,2)']::tid[]);
---END---
---START---
-- tid equality extracted from sub-AND clauses
EXPLAIN (COSTS OFF)
SELECT ctid, * FROM tidscan
WHERE (id = 3 AND ctid IN ('(0,2)', '(0,3)')) OR (ctid = '(0,1)' AND id = 1);
---END---
---START---
SELECT ctid, * FROM tidscan
WHERE (id = 3 AND ctid IN ('(0,2)', '(0,3)')) OR (ctid = '(0,1)' AND id = 1);
---END---
---START---
-- nestloop-with-inner-tidscan joins on tid
SET enable_hashjoin TO off;
---END---
---START---
-- otherwise hash join might win
EXPLAIN (COSTS OFF)
SELECT t1.ctid, t1.*, t2.ctid, t2.*
FROM tidscan t1 JOIN tidscan t2 ON t1.ctid = t2.ctid WHERE t1.id = 1;
---END---
---START---
SELECT t1.ctid, t1.*, t2.ctid, t2.*
FROM tidscan t1 JOIN tidscan t2 ON t1.ctid = t2.ctid WHERE t1.id = 1;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.ctid, t1.*, t2.ctid, t2.*
FROM tidscan t1 LEFT JOIN tidscan t2 ON t1.ctid = t2.ctid WHERE t1.id = 1;
---END---
---START---
SELECT t1.ctid, t1.*, t2.ctid, t2.*
FROM tidscan t1 LEFT JOIN tidscan t2 ON t1.ctid = t2.ctid WHERE t1.id = 1;
---END---
---START---
RESET enable_hashjoin;
---END---
---START---
-- exercise backward scan and rewind
BEGIN;
---END---
---START---
DECLARE c CURSOR FOR
SELECT ctid, * FROM tidscan WHERE ctid = ANY(ARRAY['(0,1)', '(0,2)']::tid[]);
---END---
---START---
FETCH ALL FROM c;
---END---
---START---
FETCH BACKWARD 1 FROM c;
---END---
---START---
FETCH FIRST FROM c;
---END---
---START---
ROLLBACK;
---END---
---START---
-- tidscan via CURRENT OF
BEGIN;
---END---
---START---
DECLARE c CURSOR FOR SELECT ctid, * FROM tidscan;
---END---
---START---
FETCH NEXT FROM c;
---END---
---START---
-- skip one row
FETCH NEXT FROM c;
---END---
---START---
-- perform update
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
UPDATE tidscan SET id = -id WHERE CURRENT OF c RETURNING *;
---END---
---START---
FETCH NEXT FROM c;
---END---
---START---
-- perform update
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
UPDATE tidscan SET id = -id WHERE CURRENT OF c RETURNING *;
---END---
---START---
SELECT * FROM tidscan;
---END---
---START---
-- position cursor past any rows
FETCH NEXT FROM c;
---END---
---START---
-- should error out
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
UPDATE tidscan SET id = -id WHERE CURRENT OF c RETURNING *;
---END---
---START---
ROLLBACK;
---END---
---START---
-- bulk joins on CTID
-- (these plans don't use TID scans, but this still seems like an
-- appropriate place for these tests)
EXPLAIN (COSTS OFF)
SELECT count(*) FROM tenk1 t1 JOIN tenk1 t2 ON t1.ctid = t2.ctid;
---END---
---START---
SELECT count(*) FROM tenk1 t1 JOIN tenk1 t2 ON t1.ctid = t2.ctid;
---END---
---START---
SET enable_hashjoin TO off;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM tenk1 t1 JOIN tenk1 t2 ON t1.ctid = t2.ctid;
---END---
---START---
SELECT count(*) FROM tenk1 t1 JOIN tenk1 t2 ON t1.ctid = t2.ctid;
---END---
---START---
RESET enable_hashjoin;
---END---
---START---
-- check predicate lock on CTID
BEGIN ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
SELECT * FROM tidscan WHERE ctid = '(0,1)';
---END---
---START---
-- locktype should be 'tuple'
SELECT locktype, mode FROM pg_locks WHERE pid = pg_backend_pid() AND mode = 'SIReadLock';
---END---
---START---
ROLLBACK;
---END---
---START---
DROP TABLE tidscan;
---END---
