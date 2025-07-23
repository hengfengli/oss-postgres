---START---
/*
 * 1.1. test CREATE INDEX with buffered build
 */

-- Regular index with included columns
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
-- size is chosen to exceed page size and trigger actual truncation
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,8000) AS x;
---END---
---START---
CREATE INDEX tbl_gist_idx ON tbl_gist using gist (c4) INCLUDE (c1,c2,c3);
---END---
---START---
SELECT pg_get_indexdef(i.indexrelid)
FROM pg_index i JOIN pg_class c ON i.indexrelid = c.oid
WHERE i.indrelid = 'tbl_gist'::regclass ORDER BY c.relname;
---END---
---START---
SELECT * FROM tbl_gist where c4 <@ box(point(1,1),point(10,10));
---END---
---START---
SET enable_bitmapscan TO off;
---END---
---START---
EXPLAIN  (costs off) SELECT * FROM tbl_gist where c4 <@ box(point(1,1),point(10,10));
---END---
---START---
SET enable_bitmapscan TO default;
---END---
---START---
DROP TABLE tbl_gist;
---END---
---START---

/*
 * 1.2. test CREATE INDEX with inserts
 */

-- Regular index with included columns
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
-- size is chosen to exceed page size and trigger actual truncation
CREATE INDEX tbl_gist_idx ON tbl_gist using gist (c4) INCLUDE (c1,c2,c3);
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,8000) AS x;
---END---
---START---
SELECT pg_get_indexdef(i.indexrelid)
FROM pg_index i JOIN pg_class c ON i.indexrelid = c.oid
WHERE i.indrelid = 'tbl_gist'::regclass ORDER BY c.relname;
---END---
---START---
SELECT * FROM tbl_gist where c4 <@ box(point(1,1),point(10,10));
---END---
---START---
SET enable_bitmapscan TO off;
---END---
---START---
EXPLAIN  (costs off) SELECT * FROM tbl_gist where c4 <@ box(point(1,1),point(10,10));
---END---
---START---
SET enable_bitmapscan TO default;
---END---
---START---
DROP TABLE tbl_gist;
---END---
---START---

/*
 * 2. CREATE INDEX CONCURRENTLY
 */
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,10) AS x;
---END---
---START---
CREATE INDEX CONCURRENTLY tbl_gist_idx ON tbl_gist using gist (c4) INCLUDE (c1,c2,c3);
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl_gist' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl_gist;
---END---
---START---


/*
 * 3. REINDEX
 */
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,10) AS x;
---END---
---START---
CREATE INDEX tbl_gist_idx ON tbl_gist using gist (c4) INCLUDE (c1,c3);
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl_gist' ORDER BY indexname;
---END---
---START---
REINDEX INDEX tbl_gist_idx;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl_gist' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl_gist DROP COLUMN c1;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl_gist' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl_gist;
---END---
---START---

/*
 * 4. Update, delete values in indexed table.
 */
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,10) AS x;
---END---
---START---
CREATE INDEX tbl_gist_idx ON tbl_gist using gist (c4) INCLUDE (c1,c3);
---END---
---START---
UPDATE tbl_gist SET c1 = 100 WHERE c1 = 2;
---END---
---START---
UPDATE tbl_gist SET c1 = 1 WHERE c1 = 3;
---END---
---START---
DELETE FROM tbl_gist WHERE c1 = 5 OR c3 = 12;
---END---
---START---
DROP TABLE tbl_gist;
---END---
---START---

/*
 * 5. Alter column type.
 */
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,10) AS x;
---END---
---START---
CREATE INDEX tbl_gist_idx ON tbl_gist using gist (c4) INCLUDE (c1,c3);
---END---
---START---
ALTER TABLE tbl_gist ALTER c1 TYPE bigint;
---END---
---START---
ALTER TABLE tbl_gist ALTER c3 TYPE bigint;
---END---
---START---
\d tbl_gist
DROP TABLE tbl_gist;
---END---
---START---

/*
 * 6. EXCLUDE constraint.
 */
CREATE TABLE tbl_gist (c1 int, c2 int, c3 int, c4 box, EXCLUDE USING gist (c4 WITH &&) INCLUDE (c1, c2, c3));
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(x,x+1),point(2*x,2*x+1)) FROM generate_series(1,10) AS x;
---END---
---START---
INSERT INTO tbl_gist SELECT x, 2*x, 3*x, box(point(3*x,2*x),point(3*x+1,2*x+1)) FROM generate_series(1,10) AS x;
---END---
---START---
EXPLAIN  (costs off) SELECT * FROM tbl_gist where c4 <@ box(point(1,1),point(10,10));
---END---
---START---
\d tbl_gist
DROP TABLE tbl_gist;
---END---
