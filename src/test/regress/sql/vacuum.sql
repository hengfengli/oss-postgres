---START---
--
-- VACUUM
--

CREATE TABLE vactst (i INT);
---END---
---START---
INSERT INTO vactst VALUES (1);
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst VALUES (0);
---END---
---START---
SELECT count(*) FROM vactst;
---END---
---START---
DELETE FROM vactst WHERE i != 0;
---END---
---START---
SELECT * FROM vactst;
---END---
---START---
VACUUM FULL vactst;
---END---
---START---
UPDATE vactst SET i = i + 1;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst SELECT * FROM vactst;
---END---
---START---
INSERT INTO vactst VALUES (0);
---END---
---START---
SELECT count(*) FROM vactst;
---END---
---START---
DELETE FROM vactst WHERE i != 0;
---END---
---START---
VACUUM (FULL) vactst;
---END---
---START---
DELETE FROM vactst;
---END---
---START---
SELECT * FROM vactst;
---END---
---START---

VACUUM (FULL, FREEZE) vactst;
---END---
---START---
VACUUM (ANALYZE, FULL) vactst;
---END---
---START---

CREATE TABLE vaccluster (i INT PRIMARY KEY);
---END---
---START---
ALTER TABLE vaccluster CLUSTER ON vaccluster_pkey;
---END---
---START---
CLUSTER vaccluster;
---END---
---START---

CREATE FUNCTION do_analyze() RETURNS VOID VOLATILE LANGUAGE SQL
	AS 'ANALYZE pg_am';
---END---
---START---
CREATE FUNCTION wrap_do_analyze(c INT) RETURNS INT IMMUTABLE LANGUAGE SQL
	AS 'SELECT $1 FROM do_analyze()';
---END---
---START---
CREATE INDEX ON vaccluster(wrap_do_analyze(i));
---END---
---START---
INSERT INTO vaccluster VALUES (1), (2);
---END---
---START---
ANALYZE vaccluster;
---END---
---START---

-- Test ANALYZE in transaction, where the transaction surrounding
-- analyze performed modifications. This tests for the bug at
-- https://postgr.es/m/c7988239-d42c-ddc4-41db-171b23b35e4f%40ssinger.info
-- (which hopefully is unlikely to be reintroduced), but also seems
-- independently worthwhile to cover.
INSERT INTO vactst SELECT generate_series(1, 300);
---END---
---START---
DELETE FROM vactst WHERE i % 7 = 0; -- delete a few rows outside
BEGIN;
---END---
---START---
INSERT INTO vactst SELECT generate_series(301, 400);
---END---
---START---
DELETE FROM vactst WHERE i % 5 <> 0; -- delete a few rows inside
ANALYZE vactst;
---END---
---START---
COMMIT;
---END---
---START---

VACUUM FULL pg_am;
---END---
---START---
VACUUM FULL pg_class;
---END---
---START---
VACUUM FULL pg_database;
---END---
---START---
VACUUM FULL vaccluster;
---END---
---START---
VACUUM FULL vactst;
---END---
---START---

VACUUM (DISABLE_PAGE_SKIPPING) vaccluster;
---END---
---START---

-- PARALLEL option
CREATE TABLE pvactst (i INT, a INT[], p POINT) with (autovacuum_enabled = off);
---END---
---START---
INSERT INTO pvactst SELECT i, array[1,2,3], point(i, i+1) FROM generate_series(1,1000) i;
---END---
---START---
CREATE INDEX btree_pvactst ON pvactst USING btree (i);
---END---
---START---
CREATE INDEX hash_pvactst ON pvactst USING hash (i);
---END---
---START---
CREATE INDEX brin_pvactst ON pvactst USING brin (i);
---END---
---START---
CREATE INDEX gin_pvactst ON pvactst USING gin (a);
---END---
---START---
CREATE INDEX gist_pvactst ON pvactst USING gist (p);
---END---
---START---
CREATE INDEX spgist_pvactst ON pvactst USING spgist (p);
---END---
---START---

-- VACUUM invokes parallel index cleanup
SET min_parallel_index_scan_size to 0;
---END---
---START---
VACUUM (PARALLEL 2) pvactst;
---END---
---START---

-- VACUUM invokes parallel bulk-deletion
UPDATE pvactst SET i = i WHERE i < 1000;
---END---
---START---
VACUUM (PARALLEL 2) pvactst;
---END---
---START---

UPDATE pvactst SET i = i WHERE i < 1000;
---END---
---START---
VACUUM (PARALLEL 0) pvactst; -- disable parallel vacuum

VACUUM (PARALLEL -1) pvactst; -- error
VACUUM (PARALLEL 2, INDEX_CLEANUP FALSE) pvactst;
---END---
---START---
VACUUM (PARALLEL 2, FULL TRUE) pvactst; -- error, cannot use both PARALLEL and FULL
VACUUM (PARALLEL) pvactst; -- error, cannot use PARALLEL option without parallel degree

-- Test different combinations of parallel and full options for temporary tables
CREATE TABLE tmp (a int PRIMARY KEY);
---END---
---START---
CREATE INDEX tmp_idx1 ON tmp (a);
---END---
---START---
VACUUM (PARALLEL 1, FULL FALSE) tmp; -- parallel vacuum disabled for temp tables
VACUUM (PARALLEL 0, FULL TRUE) tmp; -- can specify parallel disabled (even though that's implied by FULL)
RESET min_parallel_index_scan_size;
---END---
---START---
DROP TABLE pvactst;
---END---
---START---

-- INDEX_CLEANUP option
CREATE TABLE no_index_cleanup (i INT PRIMARY KEY, t TEXT);
---END---
---START---
-- Use uncompressed data stored in toast.
CREATE INDEX no_index_cleanup_idx ON no_index_cleanup(t);
---END---
---START---
ALTER TABLE no_index_cleanup ALTER COLUMN t SET STORAGE EXTERNAL;
---END---
---START---
INSERT INTO no_index_cleanup(i, t) VALUES (generate_series(1,30),
    repeat('1234567890',269));
---END---
---START---
-- index cleanup option is ignored if VACUUM FULL
VACUUM (INDEX_CLEANUP TRUE, FULL TRUE) no_index_cleanup;
---END---
---START---
VACUUM (FULL TRUE) no_index_cleanup;
---END---
---START---
-- Toast inherits the value from its parent table.
ALTER TABLE no_index_cleanup SET (vacuum_index_cleanup = false);
---END---
---START---
DELETE FROM no_index_cleanup WHERE i < 15;
---END---
---START---
-- Nothing is cleaned up.
VACUUM no_index_cleanup;
---END---
---START---
-- Both parent relation and toast are cleaned up.
ALTER TABLE no_index_cleanup SET (vacuum_index_cleanup = true);
---END---
---START---
VACUUM no_index_cleanup;
---END---
---START---
ALTER TABLE no_index_cleanup SET (vacuum_index_cleanup = auto);
---END---
---START---
VACUUM no_index_cleanup;
---END---
---START---
-- Parameter is set for both the parent table and its toast relation.
INSERT INTO no_index_cleanup(i, t) VALUES (generate_series(31,60),
    repeat('1234567890',269));
---END---
---START---
DELETE FROM no_index_cleanup WHERE i < 45;
---END---
---START---
-- Only toast index is cleaned up.
ALTER TABLE no_index_cleanup SET (vacuum_index_cleanup = off,
    toast.vacuum_index_cleanup = yes);
---END---
---START---
VACUUM no_index_cleanup;
---END---
---START---
-- Only parent is cleaned up.
ALTER TABLE no_index_cleanup SET (vacuum_index_cleanup = true,
    toast.vacuum_index_cleanup = false);
---END---
---START---
VACUUM no_index_cleanup;
---END---
---START---
-- Test some extra relations.
VACUUM (INDEX_CLEANUP FALSE) vaccluster;
---END---
---START---
VACUUM (INDEX_CLEANUP AUTO) vactst; -- index cleanup option is ignored if no indexes
VACUUM (INDEX_CLEANUP FALSE, FREEZE TRUE) vaccluster;
---END---
---START---

-- TRUNCATE option
CREATE TABLE vac_truncate_test(i INT NOT NULL, j text)
	WITH (vacuum_truncate=true, autovacuum_enabled=false);
---END---
---START---
INSERT INTO vac_truncate_test VALUES (1, NULL), (NULL, NULL);
---END---
---START---
VACUUM (TRUNCATE FALSE, DISABLE_PAGE_SKIPPING) vac_truncate_test;
---END---
---START---
SELECT pg_relation_size('vac_truncate_test') > 0;
---END---
---START---
VACUUM (DISABLE_PAGE_SKIPPING) vac_truncate_test;
---END---
---START---
SELECT pg_relation_size('vac_truncate_test') = 0;
---END---
---START---
VACUUM (TRUNCATE FALSE, FULL TRUE) vac_truncate_test;
---END---
---START---
DROP TABLE vac_truncate_test;
---END---
---START---

-- partitioned table
CREATE TABLE vacparted (a int, b char) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE vacparted1 PARTITION OF vacparted FOR VALUES IN (1);
---END---
---START---
INSERT INTO vacparted VALUES (1, 'a');
---END---
---START---
UPDATE vacparted SET b = 'b';
---END---
---START---
VACUUM (ANALYZE) vacparted;
---END---
---START---
VACUUM (FULL) vacparted;
---END---
---START---
VACUUM (FREEZE) vacparted;
---END---
---START---

-- check behavior with duplicate column mentions
VACUUM ANALYZE vacparted(a,b,a);
---END---
---START---
ANALYZE vacparted(a,b,b);
---END---
---START---

-- partitioned table with index
CREATE TABLE vacparted_i (a int primary key, b varchar(100))
  PARTITION BY HASH (a);
---END---
---START---
CREATE TABLE vacparted_i1 PARTITION OF vacparted_i
  FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE vacparted_i2 PARTITION OF vacparted_i
  FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO vacparted_i SELECT i, 'test_'|| i from generate_series(1,10) i;
---END---
---START---
VACUUM (ANALYZE) vacparted_i;
---END---
---START---
VACUUM (FULL) vacparted_i;
---END---
---START---
VACUUM (FREEZE) vacparted_i;
---END---
---START---
SELECT relname, relhasindex FROM pg_class
  WHERE relname LIKE 'vacparted_i%' AND relkind IN ('p','r')
  ORDER BY relname;
---END---
---START---
DROP TABLE vacparted_i;
---END---
---START---

-- multiple tables specified
VACUUM vaccluster, vactst;
---END---
---START---
VACUUM vacparted, does_not_exist;
---END---
---START---
VACUUM (FREEZE) vacparted, vaccluster, vactst;
---END---
---START---
VACUUM (FREEZE) does_not_exist, vaccluster;
---END---
---START---
VACUUM ANALYZE vactst, vacparted (a);
---END---
---START---
VACUUM ANALYZE vactst (does_not_exist), vacparted (b);
---END---
---START---
VACUUM FULL vacparted, vactst;
---END---
---START---
VACUUM FULL vactst, vacparted (a, b), vaccluster (i);
---END---
---START---
ANALYZE vactst, vacparted;
---END---
---START---
ANALYZE vacparted (b), vactst;
---END---
---START---
ANALYZE vactst, does_not_exist, vacparted;
---END---
---START---
ANALYZE vactst (i), vacparted (does_not_exist);
---END---
---START---
ANALYZE vactst, vactst;
---END---
---START---
BEGIN;  -- ANALYZE behaves differently inside a transaction block
ANALYZE vactst, vactst;
---END---
---START---
COMMIT;
---END---
---START---

-- parenthesized syntax for ANALYZE
ANALYZE (VERBOSE) does_not_exist;
---END---
---START---
ANALYZE (nonexistent-arg) does_not_exist;
---END---
---START---
ANALYZE (nonexistentarg) does_not_exit;
---END---
---START---

-- ensure argument order independence, and that SKIP_LOCKED on non-existing
-- relation still errors out.  Suppress WARNING messages caused by concurrent
-- autovacuums.
SET client_min_messages TO 'ERROR';
---END---
---START---
ANALYZE (SKIP_LOCKED, VERBOSE) does_not_exist;
---END---
---START---
ANALYZE (VERBOSE, SKIP_LOCKED) does_not_exist;
---END---
---START---

-- SKIP_LOCKED option
VACUUM (SKIP_LOCKED) vactst;
---END---
---START---
VACUUM (SKIP_LOCKED, FULL) vactst;
---END---
---START---
ANALYZE (SKIP_LOCKED) vactst;
---END---
---START---
RESET client_min_messages;
---END---
---START---

-- ensure VACUUM and ANALYZE don't have a problem with serializable
SET default_transaction_isolation = serializable;
---END---
---START---
VACUUM vactst;
---END---
---START---
ANALYZE vactst;
---END---
---START---
RESET default_transaction_isolation;
---END---
---START---
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
ANALYZE vactst;
---END---
---START---
COMMIT;
---END---
---START---

-- PROCESS_TOAST option
CREATE TABLE vac_option_tab (a INT, t TEXT);
---END---
---START---
INSERT INTO vac_option_tab SELECT a, 't' || a FROM generate_series(1, 10) AS a;
---END---
---START---
ALTER TABLE vac_option_tab ALTER COLUMN t SET STORAGE EXTERNAL;
---END---
---START---
-- Check the number of vacuums done on table vac_option_tab and on its
-- toast relation, to check that PROCESS_TOAST and PROCESS_MAIN work on
-- what they should.
CREATE VIEW vac_option_tab_counts AS
  SELECT CASE WHEN c.relname IS NULL
    THEN 'main' ELSE 'toast' END as rel,
  s.vacuum_count
  FROM pg_stat_all_tables s
  LEFT JOIN pg_class c ON s.relid = c.reltoastrelid
  WHERE c.relname = 'vac_option_tab' OR s.relname = 'vac_option_tab'
  ORDER BY rel;
---END---
---START---
VACUUM (PROCESS_TOAST TRUE) vac_option_tab;
---END---
---START---
SELECT * FROM vac_option_tab_counts;
---END---
---START---
VACUUM (PROCESS_TOAST FALSE) vac_option_tab;
---END---
---START---
SELECT * FROM vac_option_tab_counts;
---END---
---START---
VACUUM (PROCESS_TOAST FALSE, FULL) vac_option_tab; -- error

-- PROCESS_MAIN option
-- Only the toast table is processed.
VACUUM (PROCESS_MAIN FALSE) vac_option_tab;
---END---
---START---
SELECT * FROM vac_option_tab_counts;
---END---
---START---
-- Nothing is processed.
VACUUM (PROCESS_MAIN FALSE, PROCESS_TOAST FALSE) vac_option_tab;
---END---
---START---
SELECT * FROM vac_option_tab_counts;
---END---
---START---
-- Check if the filenodes nodes have been updated as wanted after FULL.
SELECT relfilenode AS main_filenode FROM pg_class
  WHERE relname = 'vac_option_tab' \gset
SELECT t.relfilenode AS toast_filenode FROM pg_class c, pg_class t
  WHERE c.reltoastrelid = t.oid AND c.relname = 'vac_option_tab' \gset
-- Only the toast relation is processed.
VACUUM (PROCESS_MAIN FALSE, FULL) vac_option_tab;
---END---
---START---
SELECT relfilenode = :main_filenode AS is_same_main_filenode
  FROM pg_class WHERE relname = 'vac_option_tab';
---END---
---START---
SELECT t.relfilenode = :toast_filenode AS is_same_toast_filenode
  FROM pg_class c, pg_class t
  WHERE c.reltoastrelid = t.oid AND c.relname = 'vac_option_tab';
---END---
---START---

-- BUFFER_USAGE_LIMIT option
VACUUM (BUFFER_USAGE_LIMIT '512 kB') vac_option_tab;
---END---
---START---
ANALYZE (BUFFER_USAGE_LIMIT '512 kB') vac_option_tab;
---END---
---START---
-- try disabling the buffer usage limit
VACUUM (BUFFER_USAGE_LIMIT 0) vac_option_tab;
---END---
---START---
ANALYZE (BUFFER_USAGE_LIMIT 0) vac_option_tab;
---END---
---START---
-- value exceeds max size error
VACUUM (BUFFER_USAGE_LIMIT 16777220) vac_option_tab;
---END---
---START---
-- value is less than min size error
VACUUM (BUFFER_USAGE_LIMIT 120) vac_option_tab;
---END---
---START---
-- integer overflow error
VACUUM (BUFFER_USAGE_LIMIT 10000000000) vac_option_tab;
---END---
---START---
-- incompatible with VACUUM FULL error
VACUUM (BUFFER_USAGE_LIMIT '512 kB', FULL) vac_option_tab;
---END---
---START---

-- SKIP_DATABASE_STATS option
VACUUM (SKIP_DATABASE_STATS) vactst;
---END---
---START---

-- ONLY_DATABASE_STATS option
VACUUM (ONLY_DATABASE_STATS);
---END---
---START---
VACUUM (ONLY_DATABASE_STATS) vactst;  -- error

DROP VIEW vac_option_tab_counts;
---END---
---START---
DROP TABLE vac_option_tab;
---END---
---START---
DROP TABLE vaccluster;
---END---
---START---
DROP TABLE vactst;
---END---
---START---
DROP TABLE vacparted;
---END---
---START---
DROP TABLE no_index_cleanup;
---END---
---START---

-- relation ownership, WARNING logs generated as all are skipped.
CREATE TABLE vacowned (a int);
---END---
---START---
CREATE TABLE vacowned_parted (a int) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE vacowned_part1 PARTITION OF vacowned_parted FOR VALUES IN (1);
---END---
---START---
CREATE TABLE vacowned_part2 PARTITION OF vacowned_parted FOR VALUES IN (2);
---END---
---START---
CREATE ROLE regress_vacuum;
---END---
---START---
SET ROLE regress_vacuum;
---END---
---START---
-- Simple table
VACUUM vacowned;
---END---
---START---
ANALYZE vacowned;
---END---
---START---
VACUUM (ANALYZE) vacowned;
---END---
---START---
-- Catalog
VACUUM pg_catalog.pg_class;
---END---
---START---
ANALYZE pg_catalog.pg_class;
---END---
---START---
VACUUM (ANALYZE) pg_catalog.pg_class;
---END---
---START---
-- Shared catalog
VACUUM pg_catalog.pg_authid;
---END---
---START---
ANALYZE pg_catalog.pg_authid;
---END---
---START---
VACUUM (ANALYZE) pg_catalog.pg_authid;
---END---
---START---
-- Partitioned table and its partitions, nothing owned by other user.
-- Relations are not listed in a single command to test ownership
-- independently.
VACUUM vacowned_parted;
---END---
---START---
VACUUM vacowned_part1;
---END---
---START---
VACUUM vacowned_part2;
---END---
---START---
ANALYZE vacowned_parted;
---END---
---START---
ANALYZE vacowned_part1;
---END---
---START---
ANALYZE vacowned_part2;
---END---
---START---
VACUUM (ANALYZE) vacowned_parted;
---END---
---START---
VACUUM (ANALYZE) vacowned_part1;
---END---
---START---
VACUUM (ANALYZE) vacowned_part2;
---END---
---START---
RESET ROLE;
---END---
---START---
-- Partitioned table and one partition owned by other user.
ALTER TABLE vacowned_parted OWNER TO regress_vacuum;
---END---
---START---
ALTER TABLE vacowned_part1 OWNER TO regress_vacuum;
---END---
---START---
SET ROLE regress_vacuum;
---END---
---START---
VACUUM vacowned_parted;
---END---
---START---
VACUUM vacowned_part1;
---END---
---START---
VACUUM vacowned_part2;
---END---
---START---
ANALYZE vacowned_parted;
---END---
---START---
ANALYZE vacowned_part1;
---END---
---START---
ANALYZE vacowned_part2;
---END---
---START---
VACUUM (ANALYZE) vacowned_parted;
---END---
---START---
VACUUM (ANALYZE) vacowned_part1;
---END---
---START---
VACUUM (ANALYZE) vacowned_part2;
---END---
---START---
RESET ROLE;
---END---
---START---
-- Only one partition owned by other user.
ALTER TABLE vacowned_parted OWNER TO CURRENT_USER;
---END---
---START---
SET ROLE regress_vacuum;
---END---
---START---
VACUUM vacowned_parted;
---END---
---START---
VACUUM vacowned_part1;
---END---
---START---
VACUUM vacowned_part2;
---END---
---START---
ANALYZE vacowned_parted;
---END---
---START---
ANALYZE vacowned_part1;
---END---
---START---
ANALYZE vacowned_part2;
---END---
---START---
VACUUM (ANALYZE) vacowned_parted;
---END---
---START---
VACUUM (ANALYZE) vacowned_part1;
---END---
---START---
VACUUM (ANALYZE) vacowned_part2;
---END---
---START---
RESET ROLE;
---END---
---START---
-- Only partitioned table owned by other user.
ALTER TABLE vacowned_parted OWNER TO regress_vacuum;
---END---
---START---
ALTER TABLE vacowned_part1 OWNER TO CURRENT_USER;
---END---
---START---
SET ROLE regress_vacuum;
---END---
---START---
VACUUM vacowned_parted;
---END---
---START---
VACUUM vacowned_part1;
---END---
---START---
VACUUM vacowned_part2;
---END---
---START---
ANALYZE vacowned_parted;
---END---
---START---
ANALYZE vacowned_part1;
---END---
---START---
ANALYZE vacowned_part2;
---END---
---START---
VACUUM (ANALYZE) vacowned_parted;
---END---
---START---
VACUUM (ANALYZE) vacowned_part1;
---END---
---START---
VACUUM (ANALYZE) vacowned_part2;
---END---
---START---
RESET ROLE;
---END---
---START---
DROP TABLE vacowned;
---END---
---START---
DROP TABLE vacowned_parted;
---END---
---START---
DROP ROLE regress_vacuum;

drop table tmp;
drop table vac_truncate_test;
---END---
