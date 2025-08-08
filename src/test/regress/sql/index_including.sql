---START---
CREATE TABLE tbl_include_reg (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
INSERT INTO tbl_include_reg SELECT x, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
CREATE INDEX tbl_include_reg_idx ON tbl_include_reg (c1, c2) INCLUDE (c3, c4);
---END---
---START---
-- duplicate column is pretty pointless, but we allow it anyway
CREATE INDEX ON tbl_include_reg (c1, c2) INCLUDE (c1, c3);
---END---
---START---
SELECT pg_get_indexdef(i.indexrelid)
FROM pg_index i JOIN pg_class c ON i.indexrelid = c.oid
WHERE i.indrelid = 'tbl_include_reg'::regclass ORDER BY c.relname;
---END---
---START---
\d tbl_include_reg_idx

-- Unique index and unique constraint
CREATE TABLE tbl_include_unique1 (c1 int, c2 int, c3 int, c4 box);
---END---
---START---
INSERT INTO tbl_include_unique1 SELECT x, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
CREATE UNIQUE INDEX tbl_include_unique1_idx_unique ON tbl_include_unique1 using btree (c1, c2) INCLUDE (c3, c4);
---END---
---START---
ALTER TABLE tbl_include_unique1 add UNIQUE USING INDEX tbl_include_unique1_idx_unique;
---END---
---START---
ALTER TABLE tbl_include_unique1 add UNIQUE (c1, c2) INCLUDE (c3, c4);
---END---
---START---
SELECT pg_get_indexdef(i.indexrelid)
FROM pg_index i JOIN pg_class c ON i.indexrelid = c.oid
WHERE i.indrelid = 'tbl_include_unique1'::regclass ORDER BY c.relname;
---END---
---START---
CREATE TABLE tbl_include_unique2 (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
INSERT INTO tbl_include_unique2 SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
CREATE UNIQUE INDEX tbl_include_unique2_idx_unique ON tbl_include_unique2 using btree (c1, c2) INCLUDE (c3, c4);
---END---
---START---
ALTER TABLE tbl_include_unique2 add UNIQUE (c1, c2) INCLUDE (c3, c4);
---END---
---START---
CREATE TABLE tbl_include_pk (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
INSERT INTO tbl_include_pk SELECT 1, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
ALTER TABLE tbl_include_pk add PRIMARY KEY (c1, c2) INCLUDE (c3, c4);
---END---
---START---
SELECT pg_get_indexdef(i.indexrelid)
FROM pg_index i JOIN pg_class c ON i.indexrelid = c.oid
WHERE i.indrelid = 'tbl_include_pk'::regclass ORDER BY c.relname;
---END---
---START---
CREATE TABLE tbl_include_box (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
INSERT INTO tbl_include_box SELECT 1, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
CREATE UNIQUE INDEX tbl_include_box_idx_unique ON tbl_include_box using btree (c1, c2) INCLUDE (c3, c4);
---END---
---START---
ALTER TABLE tbl_include_box add PRIMARY KEY USING INDEX tbl_include_box_idx_unique;
---END---
---START---
SELECT pg_get_indexdef(i.indexrelid)
FROM pg_index i JOIN pg_class c ON i.indexrelid = c.oid
WHERE i.indrelid = 'tbl_include_box'::regclass ORDER BY c.relname;
---END---
---START---
CREATE TABLE tbl_include_box_pk (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
INSERT INTO tbl_include_box_pk SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
ALTER TABLE tbl_include_box_pk add PRIMARY KEY (c1, c2) INCLUDE (c3, c4);
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, CONSTRAINT covering UNIQUE (c1, c2) INCLUDE (c3, c4));
---END---
---START---
SELECT indexrelid::regclass, indnatts, indnkeyatts, indisunique, indisprimary, indkey, indclass FROM pg_index WHERE indrelid = 'tbl'::regclass::oid;
---END---
---START---
SELECT pg_get_constraintdef(oid), conname, conkey FROM pg_constraint WHERE conrelid = 'tbl'::regclass::oid;
---END---
---START---
-- ensure that constraint works
INSERT INTO tbl SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (c1 int,c2 int, c3 int, c4 box,
				CONSTRAINT covering PRIMARY KEY(c1,c2) INCLUDE(c3,c4));
---END---
---START---
SELECT indexrelid::regclass, indnatts, indnkeyatts, indisunique, indisprimary, indkey, indclass FROM pg_index WHERE indrelid = 'tbl'::regclass::oid;
---END---
---START---
SELECT pg_get_constraintdef(oid), conname, conkey FROM pg_constraint WHERE conrelid = 'tbl'::regclass::oid;
---END---
---START---
-- ensure that constraint works
INSERT INTO tbl SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
INSERT INTO tbl SELECT 1, NULL, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
INSERT INTO tbl SELECT x, 2*x, NULL, NULL FROM generate_series(1,300) AS x;
---END---
---START---
explain (costs off)
select * from tbl where (c1,c2,c3) < (2,5,1);
---END---
---START---
select * from tbl where (c1,c2,c3) < (2,5,1);
---END---
---START---
-- row comparison that compares high key at page boundary
SET enable_seqscan = off;
---END---
---START---
explain (costs off)
select * from tbl where (c1,c2,c3) < (262,1,1) limit 1;
---END---
---START---
select * from tbl where (c1,c2,c3) < (262,1,1) limit 1;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, UNIQUE (c1, c2) INCLUDE (c3, c4));
---END---
---START---
SELECT indexrelid::regclass, indnatts, indnkeyatts, indisunique, indisprimary, indkey, indclass FROM pg_index WHERE indrelid = 'tbl'::regclass::oid;
---END---
---START---
SELECT pg_get_constraintdef(oid), conname, conkey FROM pg_constraint WHERE conrelid = 'tbl'::regclass::oid;
---END---
---START---
-- ensure that constraint works
INSERT INTO tbl SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (c1 int,c2 int, c3 int, c4 box,
				PRIMARY KEY(c1,c2) INCLUDE(c3,c4));
---END---
---START---
SELECT indexrelid::regclass, indnatts, indnkeyatts, indisunique, indisprimary, indkey, indclass FROM pg_index WHERE indrelid = 'tbl'::regclass::oid;
---END---
---START---
SELECT pg_get_constraintdef(oid), conname, conkey FROM pg_constraint WHERE conrelid = 'tbl'::regclass::oid;
---END---
---START---
-- ensure that constraint works
INSERT INTO tbl SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
INSERT INTO tbl SELECT 1, NULL, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
INSERT INTO tbl SELECT x, 2*x, NULL, NULL FROM generate_series(1,10) AS x;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, EXCLUDE USING btree (c1 WITH OPERATOR(=)) INCLUDE (c3, c4));
---END---
---START---
SELECT indexrelid::regclass, indnatts, indnkeyatts, indisunique, indisprimary, indkey, indclass FROM pg_index WHERE indrelid = 'tbl'::regclass::oid;
---END---
---START---
SELECT pg_get_constraintdef(oid), conname, conkey FROM pg_constraint WHERE conrelid = 'tbl'::regclass::oid;
---END---
---START---
-- ensure that constraint works
INSERT INTO tbl SELECT 1, 2, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
INSERT INTO tbl SELECT x, 2*x, NULL, NULL FROM generate_series(1,10) AS x;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 integer);
---END---
---START---
CREATE UNIQUE INDEX tbl_idx ON tbl using btree(c1, c2, c3, c4);
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl DROP COLUMN c3;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
CREATE UNIQUE INDEX tbl_idx ON tbl using btree(c1, c2) INCLUDE(c3,c4);
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl DROP COLUMN c3;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, UNIQUE (c1, c2) INCLUDE (c3, c4));
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl DROP COLUMN c3;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl DROP COLUMN c1;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer);
---END---
---START---
CREATE INDEX tbl_idx ON tbl (c1, (c1+0)) INCLUDE (c2);
---END---
---START---
ALTER INDEX tbl_idx ALTER COLUMN 1 SET STATISTICS 1000;
---END---
---START---
ALTER INDEX tbl_idx ALTER COLUMN 2 SET STATISTICS 1000;
---END---
---START---
ALTER INDEX tbl_idx ALTER COLUMN 3 SET STATISTICS 1000;
---END---
---START---
ALTER INDEX tbl_idx ALTER COLUMN 4 SET STATISTICS 1000;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, UNIQUE (c1, c2) INCLUDE (c3, c4));
---END---
---START---
INSERT INTO tbl SELECT x, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,1000) AS x;
---END---
---START---
CREATE UNIQUE INDEX CONCURRENTLY on tbl (c1, c2) INCLUDE (c3, c4);
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, UNIQUE (c1, c2) INCLUDE (c3, c4));
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl DROP COLUMN c3;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
REINDEX INDEX tbl_c1_c2_c3_c4_key;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
ALTER TABLE tbl DROP COLUMN c1;
---END---
---START---
SELECT indexdef FROM pg_indexes WHERE tablename = 'tbl' ORDER BY indexname;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 box, c4 box);
---END---
---START---
CREATE INDEX on tbl USING brin(c1, c2) INCLUDE (c3, c4);
---END---
---START---
CREATE INDEX on tbl USING gist(c3) INCLUDE (c1, c4);
---END---
---START---
CREATE INDEX on tbl USING spgist(c3) INCLUDE (c4);
---END---
---START---
CREATE INDEX on tbl USING gin(c1, c2) INCLUDE (c3, c4);
---END---
---START---
CREATE INDEX on tbl USING hash(c1, c2) INCLUDE (c3, c4);
---END---
---START---
CREATE INDEX on tbl USING rtree(c3) INCLUDE (c1, c4);
---END---
---START---
CREATE INDEX on tbl USING btree(c1, c2) INCLUDE (c3, c4);
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box);
---END---
---START---
INSERT INTO tbl SELECT x, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
CREATE UNIQUE INDEX tbl_idx_unique ON tbl using btree(c1, c2) INCLUDE (c3,c4);
---END---
---START---
UPDATE tbl SET c1 = 100 WHERE c1 = 2;
---END---
---START---
UPDATE tbl SET c1 = 1 WHERE c1 = 3;
---END---
---START---
-- should fail
UPDATE tbl SET c2 = 2 WHERE c1 = 1;
---END---
---START---
UPDATE tbl SET c3 = 1;
---END---
---START---
DELETE FROM tbl WHERE c1 = 5 OR c3 = 12;
---END---
---START---
DROP TABLE tbl;
---END---
---START---
CREATE TABLE tbl (_gemini_pk serial PRIMARY KEY, c1 integer, c2 integer, c3 integer, c4 box, UNIQUE (c1, c2) INCLUDE (c3, c4));
---END---
---START---
INSERT INTO tbl SELECT x, 2*x, 3*x, box('4,4,4,4') FROM generate_series(1,10) AS x;
---END---
---START---
ALTER TABLE tbl ALTER c1 TYPE bigint;
---END---
---START---
ALTER TABLE tbl ALTER c3 TYPE bigint;
---END---
---START---
\d tbl
DROP TABLE tbl;
---END---
