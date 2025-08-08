---START---
--
-- Create access method tests
--

-- Make gist2 over gisthandler. In fact, it would be a synonym to gist.
CREATE ACCESS METHOD gist2 TYPE INDEX HANDLER gisthandler;
---END---
---START---
-- Verify return type checks for handlers
CREATE ACCESS METHOD bogus TYPE INDEX HANDLER int4in;
---END---
---START---
CREATE ACCESS METHOD bogus TYPE INDEX HANDLER heap_tableam_handler;
---END---
---START---
-- Try to create gist2 index on fast_emp4000: fail because opclass doesn't exist
CREATE INDEX grect2ind2 ON fast_emp4000 USING gist2 (home_base);
---END---
---START---
-- Make operator class for boxes using gist2
CREATE OPERATOR CLASS box_ops DEFAULT
	FOR TYPE box USING gist2 AS
	OPERATOR 1	<<,
	OPERATOR 2	&<,
	OPERATOR 3	&&,
	OPERATOR 4	&>,
	OPERATOR 5	>>,
	OPERATOR 6	~=,
	OPERATOR 7	@>,
	OPERATOR 8	<@,
	OPERATOR 9	&<|,
	OPERATOR 10	<<|,
	OPERATOR 11	|>>,
	OPERATOR 12	|&>,
	FUNCTION 1	gist_box_consistent(internal, box, smallint, oid, internal),
	FUNCTION 2	gist_box_union(internal, internal),
	-- don't need compress, decompress, or fetch functions
	FUNCTION 5	gist_box_penalty(internal, internal, internal),
	FUNCTION 6	gist_box_picksplit(internal, internal),
	FUNCTION 7	gist_box_same(box, box, internal);
---END---
---START---
-- Create gist2 index on fast_emp4000
CREATE INDEX grect2ind2 ON fast_emp4000 USING gist2 (home_base);
---END---
---START---
-- Now check the results from plain indexscan; temporarily drop existing
-- index grect2ind to ensure it doesn't capture the plan
BEGIN;
---END---
---START---
DROP INDEX grect2ind;
---END---
---START---
SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = ON;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM fast_emp4000
    WHERE home_base <@ '(200,200),(2000,1000)'::box
    ORDER BY (home_base[0])[0];
---END---
---START---
SELECT * FROM fast_emp4000
    WHERE home_base <@ '(200,200),(2000,1000)'::box
    ORDER BY (home_base[0])[0];
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM fast_emp4000 WHERE home_base && '(1000,1000,0,0)'::box;
---END---
---START---
SELECT count(*) FROM fast_emp4000 WHERE home_base && '(1000,1000,0,0)'::box;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM fast_emp4000 WHERE home_base IS NULL;
---END---
---START---
SELECT count(*) FROM fast_emp4000 WHERE home_base IS NULL;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Try to drop access method: fail because of dependent objects
DROP ACCESS METHOD gist2;
---END---
---START---
-- Drop access method cascade
-- To prevent a (rare) deadlock against autovacuum,
-- we must lock the table that owns the index that will be dropped
BEGIN;
---END---
---START---
LOCK TABLE fast_emp4000;
---END---
---START---
DROP ACCESS METHOD gist2 CASCADE;
---END---
---START---
COMMIT;
---END---
---START---
--
-- Test table access methods
--

-- prevent empty values
SET default_table_access_method = '';
---END---
---START---
-- prevent nonexistent values
SET default_table_access_method = 'I do not exist AM';
---END---
---START---
-- prevent setting it to an index AM
SET default_table_access_method = 'btree';
---END---
---START---
-- Create a heap2 table am handler with heapam handler
CREATE ACCESS METHOD heap2 TYPE TABLE HANDLER heap_tableam_handler;
---END---
---START---
-- Verify return type checks for handlers
CREATE ACCESS METHOD bogus TYPE TABLE HANDLER int4in;
---END---
---START---
CREATE ACCESS METHOD bogus TYPE TABLE HANDLER bthandler;
---END---
---START---
SELECT amname, amhandler, amtype FROM pg_am where amtype = 't' ORDER BY 1, 2;
---END---
---START---
-- First create tables employing the new AM using USING

-- plain CREATE TABLE
CREATE TABLE tableam_tbl_heap2(f1 int) USING heap2;
---END---
---START---
INSERT INTO tableam_tbl_heap2 VALUES(1);
---END---
---START---
SELECT f1 FROM tableam_tbl_heap2 ORDER BY f1;
---END---
---START---
-- CREATE TABLE AS
CREATE TABLE tableam_tblas_heap2 USING heap2 AS SELECT * FROM tableam_tbl_heap2;
---END---
---START---
SELECT f1 FROM tableam_tbl_heap2 ORDER BY f1;
---END---
---START---
-- SELECT INTO doesn't support USING
SELECT INTO tableam_tblselectinto_heap2 USING heap2 FROM tableam_tbl_heap2;
---END---
---START---
-- CREATE VIEW doesn't support USING
CREATE VIEW tableam_view_heap2 USING heap2 AS SELECT * FROM tableam_tbl_heap2;
---END---
---START---
-- CREATE SEQUENCE doesn't support USING
CREATE SEQUENCE tableam_seq_heap2 USING heap2;
---END---
---START---
-- CREATE MATERIALIZED VIEW does support USING
CREATE MATERIALIZED VIEW tableam_tblmv_heap2 USING heap2 AS SELECT * FROM tableam_tbl_heap2;
---END---
---START---
SELECT f1 FROM tableam_tblmv_heap2 ORDER BY f1;
---END---
---START---
-- CREATE TABLE ..  PARTITION BY doesn't not support USING
CREATE TABLE tableam_parted_heap2 (a text, b int) PARTITION BY list (a) USING heap2;
---END---
---START---
CREATE TABLE tableam_parted_heap2 (a text, b int) PARTITION BY list (a);
---END---
---START---
-- new partitions will inherit from the current default, rather the partition root
SET default_table_access_method = 'heap';
---END---
---START---
CREATE TABLE tableam_parted_a_heap2 PARTITION OF tableam_parted_heap2 FOR VALUES IN ('a');
---END---
---START---
SET default_table_access_method = 'heap2';
---END---
---START---
CREATE TABLE tableam_parted_b_heap2 PARTITION OF tableam_parted_heap2 FOR VALUES IN ('b');
---END---
---START---
RESET default_table_access_method;
---END---
---START---
-- but the method can be explicitly specified
CREATE TABLE tableam_parted_c_heap2 PARTITION OF tableam_parted_heap2 FOR VALUES IN ('c') USING heap;
---END---
---START---
CREATE TABLE tableam_parted_d_heap2 PARTITION OF tableam_parted_heap2 FOR VALUES IN ('d') USING heap2;
---END---
---START---
-- List all objects in AM
SELECT
    pc.relkind,
    pa.amname,
    CASE WHEN relkind = 't' THEN
        (SELECT 'toast for ' || relname::regclass FROM pg_class pcm WHERE pcm.reltoastrelid = pc.oid)
    ELSE
        relname::regclass::text
    END COLLATE "C" AS relname
FROM pg_class AS pc,
    pg_am AS pa
WHERE pa.oid = pc.relam
   AND pa.amname = 'heap2'
ORDER BY 3, 1, 2;
---END---
---START---
-- Show dependencies onto AM - there shouldn't be any for toast
SELECT pg_describe_object(classid,objid,objsubid) AS obj
FROM pg_depend, pg_am
WHERE pg_depend.refclassid = 'pg_am'::regclass
    AND pg_am.oid = pg_depend.refobjid
    AND pg_am.amname = 'heap2'
ORDER BY classid, objid, objsubid;
---END---
---START---
-- ALTER TABLE SET ACCESS METHOD
CREATE TABLE heaptable USING heap AS
  SELECT a, repeat(a::text, 100) FROM generate_series(1,9) AS a;
---END---
---START---
SELECT amname FROM pg_class c, pg_am am
  WHERE c.relam = am.oid AND c.oid = 'heaptable'::regclass;
---END---
---START---
-- Switching to heap2 adds new dependency entry to the AM.
ALTER TABLE heaptable SET ACCESS METHOD heap2;
---END---
---START---
SELECT pg_describe_object(classid, objid, objsubid) as obj,
       pg_describe_object(refclassid, refobjid, refobjsubid) as objref,
       deptype
  FROM pg_depend
  WHERE classid = 'pg_class'::regclass AND
        objid = 'heaptable'::regclass
  ORDER BY 1, 2;
---END---
---START---
-- Switching to heap should not have a dependency entry to the AM.
ALTER TABLE heaptable SET ACCESS METHOD heap;
---END---
---START---
SELECT pg_describe_object(classid, objid, objsubid) as obj,
       pg_describe_object(refclassid, refobjid, refobjsubid) as objref,
       deptype
  FROM pg_depend
  WHERE classid = 'pg_class'::regclass AND
        objid = 'heaptable'::regclass
  ORDER BY 1, 2;
---END---
---START---
ALTER TABLE heaptable SET ACCESS METHOD heap2;
---END---
---START---
SELECT amname FROM pg_class c, pg_am am
  WHERE c.relam = am.oid AND c.oid = 'heaptable'::regclass;
---END---
---START---
SELECT COUNT(a), COUNT(1) FILTER(WHERE a=1) FROM heaptable;
---END---
---START---
-- ALTER MATERIALIZED VIEW SET ACCESS METHOD
CREATE MATERIALIZED VIEW heapmv USING heap AS SELECT * FROM heaptable;
---END---
---START---
SELECT amname FROM pg_class c, pg_am am
  WHERE c.relam = am.oid AND c.oid = 'heapmv'::regclass;
---END---
---START---
ALTER MATERIALIZED VIEW heapmv SET ACCESS METHOD heap2;
---END---
---START---
SELECT amname FROM pg_class c, pg_am am
  WHERE c.relam = am.oid AND c.oid = 'heapmv'::regclass;
---END---
---START---
SELECT COUNT(a), COUNT(1) FILTER(WHERE a=1) FROM heapmv;
---END---
---START---
-- No support for multiple subcommands
ALTER TABLE heaptable SET ACCESS METHOD heap, SET ACCESS METHOD heap2;
---END---
---START---
ALTER MATERIALIZED VIEW heapmv SET ACCESS METHOD heap, SET ACCESS METHOD heap2;
---END---
---START---
DROP MATERIALIZED VIEW heapmv;
---END---
---START---
DROP TABLE heaptable;
---END---
---START---
-- No support for partitioned tables.
CREATE TABLE am_partitioned(x INT, y INT)
  PARTITION BY hash (x);
---END---
---START---
ALTER TABLE am_partitioned SET ACCESS METHOD heap2;
---END---
---START---
DROP TABLE am_partitioned;
---END---
---START---
-- Second, create objects in the new AM by changing the default AM
BEGIN;
---END---
---START---
SET LOCAL default_table_access_method = 'heap2';
---END---
---START---
-- following tests should all respect the default AM
CREATE TABLE tableam_tbl_heapx(f1 int);
---END---
---START---
CREATE TABLE tableam_tblas_heapx AS SELECT * FROM tableam_tbl_heapx;
---END---
---START---
SELECT INTO tableam_tblselectinto_heapx FROM tableam_tbl_heapx;
---END---
---START---
CREATE MATERIALIZED VIEW tableam_tblmv_heapx USING heap2 AS SELECT * FROM tableam_tbl_heapx;
---END---
---START---
CREATE TABLE tableam_parted_heapx (a text, b int) PARTITION BY list (a);
---END---
---START---
CREATE TABLE tableam_parted_1_heapx PARTITION OF tableam_parted_heapx FOR VALUES IN ('a', 'b');
---END---
---START---
-- but an explicitly set AM overrides it
CREATE TABLE tableam_parted_2_heapx PARTITION OF tableam_parted_heapx FOR VALUES IN ('c', 'd') USING heap;
---END---
---START---
-- sequences, views and foreign servers shouldn't have an AM
CREATE VIEW tableam_view_heapx AS SELECT * FROM tableam_tbl_heapx;
---END---
---START---
CREATE SEQUENCE tableam_seq_heapx;
---END---
---START---
CREATE FOREIGN DATA WRAPPER fdw_heap2 VALIDATOR postgresql_fdw_validator;
---END---
---START---
CREATE SERVER fs_heap2 FOREIGN DATA WRAPPER fdw_heap2;
---END---
---START---
CREATE FOREIGN table tableam_fdw_heapx () SERVER fs_heap2;
---END---
---START---
-- Verify that new AM was used for tables, matviews, but not for sequences, views and fdws
SELECT
    pc.relkind,
    pa.amname,
    CASE WHEN relkind = 't' THEN
        (SELECT 'toast for ' || relname::regclass FROM pg_class pcm WHERE pcm.reltoastrelid = pc.oid)
    ELSE
        relname::regclass::text
    END COLLATE "C" AS relname
FROM pg_class AS pc
    LEFT JOIN pg_am AS pa ON (pa.oid = pc.relam)
WHERE pc.relname LIKE 'tableam_%_heapx'
ORDER BY 3, 1, 2;
---END---
---START---
-- don't want to keep those tables, nor the default
ROLLBACK;
---END---
---START---
-- Third, check that we can neither create a table using a nonexistent
-- AM, nor using an index AM
CREATE TABLE i_am_a_failure() USING "";
---END---
---START---
CREATE TABLE i_am_a_failure() USING i_do_not_exist_am;
---END---
---START---
CREATE TABLE i_am_a_failure() USING "I do not exist AM";
---END---
---START---
CREATE TABLE i_am_a_failure() USING "btree";
---END---
---START---
-- Drop table access method, which fails as objects depends on it
DROP ACCESS METHOD heap2;
---END---
