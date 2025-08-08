---START---
--
-- CREATE_INDEX
-- Create ancillary data structures (i.e. indices)
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

--
-- BTREE
--
CREATE INDEX onek_unique1 ON onek USING btree(unique1 int4_ops);
---END---
---START---
CREATE INDEX IF NOT EXISTS onek_unique1 ON onek USING btree(unique1 int4_ops);
---END---
---START---
CREATE INDEX IF NOT EXISTS ON onek USING btree(unique1 int4_ops);
---END---
---START---
CREATE INDEX onek_unique2 ON onek USING btree(unique2 int4_ops);
---END---
---START---
CREATE INDEX onek_hundred ON onek USING btree(hundred int4_ops);
---END---
---START---
CREATE INDEX onek_stringu1 ON onek USING btree(stringu1 name_ops);
---END---
---START---
CREATE INDEX tenk1_unique1 ON tenk1 USING btree(unique1 int4_ops);
---END---
---START---
CREATE INDEX tenk1_unique2 ON tenk1 USING btree(unique2 int4_ops);
---END---
---START---
CREATE INDEX tenk1_hundred ON tenk1 USING btree(hundred int4_ops);
---END---
---START---
CREATE INDEX tenk1_thous_tenthous ON tenk1 (thousand, tenthous);
---END---
---START---
CREATE INDEX tenk2_unique1 ON tenk2 USING btree(unique1 int4_ops);
---END---
---START---
CREATE INDEX tenk2_unique2 ON tenk2 USING btree(unique2 int4_ops);
---END---
---START---
CREATE INDEX tenk2_hundred ON tenk2 USING btree(hundred int4_ops);
---END---
---START---
CREATE INDEX rix ON road USING btree (name text_ops);
---END---
---START---
CREATE INDEX iix ON ihighway USING btree (name text_ops);
---END---
---START---
CREATE INDEX six ON shighway USING btree (name text_ops);
---END---
---START---
-- test comments
COMMENT ON INDEX six_wrong IS 'bad index';
---END---
---START---
COMMENT ON INDEX six IS 'good index';
---END---
---START---
COMMENT ON INDEX six IS NULL;
---END---
---START---
--
-- BTREE partial indices
--
CREATE INDEX onek2_u1_prtl ON onek2 USING btree(unique1 int4_ops)
	where unique1 < 20 or unique1 > 980;
---END---
---START---
CREATE INDEX onek2_u2_prtl ON onek2 USING btree(unique2 int4_ops)
	where stringu1 < 'B';
---END---
---START---
CREATE INDEX onek2_stu1_prtl ON onek2 USING btree(stringu1 name_ops)
	where onek2.stringu1 >= 'J' and onek2.stringu1 < 'K';
---END---
---START---
--
-- GiST (rtree-equivalent opclasses only)
--

CREATE TABLE slow_emp4000 (
	home_base	 box
);
---END---
---START---
CREATE TABLE fast_emp4000 (
	home_base	 box
);
---END---
---START---
\set filename :abs_srcdir '/data/rect.data'
COPY slow_emp4000 FROM :'filename';
---END---
---START---
INSERT INTO fast_emp4000 SELECT * FROM slow_emp4000;
---END---
---START---
ANALYZE slow_emp4000;
---END---
---START---
ANALYZE fast_emp4000;
---END---
---START---
CREATE INDEX grect2ind ON fast_emp4000 USING gist (home_base);
---END---
---START---
-- we want to work with a point_tbl that includes a null
CREATE TEMP TABLE point_tbl AS SELECT * FROM public.point_tbl;
---END---
---START---
INSERT INTO POINT_TBL(f1) VALUES (NULL);
---END---
---START---
CREATE INDEX gpointind ON point_tbl USING gist (f1);
---END---
---START---
CREATE TEMP TABLE gpolygon_tbl AS
    SELECT polygon(home_base) AS f1 FROM slow_emp4000;
---END---
---START---
INSERT INTO gpolygon_tbl VALUES ( '(1000,0,0,1000)' );
---END---
---START---
INSERT INTO gpolygon_tbl VALUES ( '(0,1000,1000,1000)' );
---END---
---START---
CREATE TEMP TABLE gcircle_tbl AS
    SELECT circle(home_base) AS f1 FROM slow_emp4000;
---END---
---START---
CREATE INDEX ggpolygonind ON gpolygon_tbl USING gist (f1);
---END---
---START---
CREATE INDEX ggcircleind ON gcircle_tbl USING gist (f1);
---END---
---START---
--
-- Test GiST indexes
--

-- get non-indexed results for comparison purposes

SET enable_seqscan = ON;
---END---
---START---
SET enable_indexscan = OFF;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---
SELECT * FROM fast_emp4000
    WHERE home_base <@ '(200,200),(2000,1000)'::box
    ORDER BY (home_base[0])[0];
---END---
---START---
SELECT count(*) FROM fast_emp4000 WHERE home_base && '(1000,1000,0,0)'::box;
---END---
---START---
SELECT count(*) FROM fast_emp4000 WHERE home_base IS NULL;
---END---
---START---
SELECT count(*) FROM gpolygon_tbl WHERE f1 && '(1000,1000,0,0)'::polygon;
---END---
---START---
SELECT count(*) FROM gcircle_tbl WHERE f1 && '<(500,500),500>'::circle;
---END---
---START---
SELECT count(*) FROM point_tbl WHERE f1 <@ box '(0,0,100,100)';
---END---
---START---
SELECT count(*) FROM point_tbl WHERE box '(0,0,100,100)' @> f1;
---END---
---START---
SELECT count(*) FROM point_tbl WHERE f1 <@ polygon '(0,0),(0,100),(100,100),(50,50),(100,0),(0,0)';
---END---
---START---
SELECT count(*) FROM point_tbl WHERE f1 <@ circle '<(50,50),50>';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 << '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 >> '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 <<| '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 |>> '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 ~= '(-5, -12)';
---END---
---START---
SELECT * FROM point_tbl ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM point_tbl WHERE f1 IS NULL;
---END---
---START---
SELECT * FROM point_tbl WHERE f1 IS NOT NULL ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM point_tbl WHERE f1 <@ '(-10,-10),(10,10)':: box ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM gpolygon_tbl ORDER BY f1 <-> '(0,0)'::point LIMIT 10;
---END---
---START---
SELECT circle_center(f1), round(radius(f1)) as radius FROM gcircle_tbl ORDER BY f1 <-> '(200,300)'::point LIMIT 10;
---END---
---START---
-- Now check the results from plain indexscan
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
EXPLAIN (COSTS OFF)
SELECT count(*) FROM gpolygon_tbl WHERE f1 && '(1000,1000,0,0)'::polygon;
---END---
---START---
SELECT count(*) FROM gpolygon_tbl WHERE f1 && '(1000,1000,0,0)'::polygon;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM gcircle_tbl WHERE f1 && '<(500,500),500>'::circle;
---END---
---START---
SELECT count(*) FROM gcircle_tbl WHERE f1 && '<(500,500),500>'::circle;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl WHERE f1 <@ box '(0,0,100,100)';
---END---
---START---
SELECT count(*) FROM point_tbl WHERE f1 <@ box '(0,0,100,100)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl WHERE box '(0,0,100,100)' @> f1;
---END---
---START---
SELECT count(*) FROM point_tbl WHERE box '(0,0,100,100)' @> f1;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl WHERE f1 <@ polygon '(0,0),(0,100),(100,100),(50,50),(100,0),(0,0)';
---END---
---START---
SELECT count(*) FROM point_tbl WHERE f1 <@ polygon '(0,0),(0,100),(100,100),(50,50),(100,0),(0,0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl WHERE f1 <@ circle '<(50,50),50>';
---END---
---START---
SELECT count(*) FROM point_tbl WHERE f1 <@ circle '<(50,50),50>';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl p WHERE p.f1 << '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 << '(0.0, 0.0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl p WHERE p.f1 >> '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 >> '(0.0, 0.0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl p WHERE p.f1 <<| '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 <<| '(0.0, 0.0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl p WHERE p.f1 |>> '(0.0, 0.0)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 |>> '(0.0, 0.0)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM point_tbl p WHERE p.f1 ~= '(-5, -12)';
---END---
---START---
SELECT count(*) FROM point_tbl p WHERE p.f1 ~= '(-5, -12)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM point_tbl ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM point_tbl ORDER BY f1 <-> '0,1';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM point_tbl WHERE f1 IS NULL;
---END---
---START---
SELECT * FROM point_tbl WHERE f1 IS NULL;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM point_tbl WHERE f1 IS NOT NULL ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM point_tbl WHERE f1 IS NOT NULL ORDER BY f1 <-> '0,1';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM point_tbl WHERE f1 <@ '(-10,-10),(10,10)':: box ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM point_tbl WHERE f1 <@ '(-10,-10),(10,10)':: box ORDER BY f1 <-> '0,1';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM gpolygon_tbl ORDER BY f1 <-> '(0,0)'::point LIMIT 10;
---END---
---START---
SELECT * FROM gpolygon_tbl ORDER BY f1 <-> '(0,0)'::point LIMIT 10;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT circle_center(f1), round(radius(f1)) as radius FROM gcircle_tbl ORDER BY f1 <-> '(200,300)'::point LIMIT 10;
---END---
---START---
SELECT circle_center(f1), round(radius(f1)) as radius FROM gcircle_tbl ORDER BY f1 <-> '(200,300)'::point LIMIT 10;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT point(x,x), (SELECT f1 FROM gpolygon_tbl ORDER BY f1 <-> point(x,x) LIMIT 1) as c FROM generate_series(0,10,1) x;
---END---
---START---
SELECT point(x,x), (SELECT f1 FROM gpolygon_tbl ORDER BY f1 <-> point(x,x) LIMIT 1) as c FROM generate_series(0,10,1) x;
---END---
---START---
-- Now check the results from bitmap indexscan
SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = OFF;
---END---
---START---
SET enable_bitmapscan = ON;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM point_tbl WHERE f1 <@ '(-10,-10),(10,10)':: box ORDER BY f1 <-> '0,1';
---END---
---START---
SELECT * FROM point_tbl WHERE f1 <@ '(-10,-10),(10,10)':: box ORDER BY f1 <-> '0,1';
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_indexscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
--
-- GIN over int[] and text[]
--
-- Note: GIN currently supports only bitmap scans, not plain indexscans
--

CREATE TABLE array_index_op_test (
	seqno		int4,
	i			int4[],
	t			text[]
);
---END---
---START---
\set filename :abs_srcdir '/data/array.data'
COPY array_index_op_test FROM :'filename';
---END---
---START---
ANALYZE array_index_op_test;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i = '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i <@ '{NULL}' ORDER BY seqno;
---END---
---START---
SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = OFF;
---END---
---START---
SET enable_bitmapscan = ON;
---END---
---START---
CREATE INDEX intarrayidx ON array_index_op_test USING gin (i);
---END---
---START---
explain (costs off)
SELECT * FROM array_index_op_test WHERE i @> '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{32,17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{32,17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i <@ '{38,34,32,89}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i = '{47,77}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i = '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i <@ '{}' ORDER BY seqno;
---END---
---START---
CREATE INDEX textarrayidx ON array_index_op_test USING gin (t);
---END---
---START---
explain (costs off)
SELECT * FROM array_index_op_test WHERE t @> '{AAAAAAAA72908}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t @> '{AAAAAAAA72908}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t && '{AAAAAAAA72908}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t @> '{AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t && '{AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t @> '{AAAAAAAA72908,AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t && '{AAAAAAAA72908,AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t <@ '{AAAAAAAA72908,AAAAAAAAAAAAAAAAAAA17075,AA88409,AAAAAAAAAAAAAAAAAA36842,AAAAAAA48038,AAAAAAAAAAAAAA10611}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t = '{AAAAAAAAAA646,A87088}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t = '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t @> '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t && '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t <@ '{}' ORDER BY seqno;
---END---
---START---
-- And try it with a multicolumn GIN index

DROP INDEX intarrayidx, textarrayidx;
---END---
---START---
CREATE INDEX botharrayidx ON array_index_op_test USING gin (i, t);
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t @> '{AAAAAAA80240}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t && '{AAAAAAA80240}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i @> '{32}' AND t && '{AAAAAAA80240}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE i && '{32}' AND t @> '{AAAAAAA80240}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_index_op_test WHERE t = '{}' ORDER BY seqno;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_indexscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
--
-- Try a GIN index with a lot of items with same key. (GIN creates a posting
-- tree when there are enough duplicates)
--
CREATE TABLE array_gin_test (a int[]);
---END---
---START---
INSERT INTO array_gin_test SELECT ARRAY[1, g%5, g] FROM generate_series(1, 10000) g;
---END---
---START---
CREATE INDEX array_gin_test_idx ON array_gin_test USING gin (a);
---END---
---START---
SELECT COUNT(*) FROM array_gin_test WHERE a @> '{2}';
---END---
---START---
DROP TABLE array_gin_test;
---END---
---START---
--
-- Test GIN index's reloptions
--
CREATE INDEX gin_relopts_test ON array_index_op_test USING gin (i)
  WITH (FASTUPDATE=on, GIN_PENDING_LIST_LIMIT=128);
---END---
---START---
\d+ gin_relopts_test

--
-- HASH
--
CREATE UNLOGGED TABLE unlogged_hash_table (id int4);
---END---
---START---
CREATE INDEX unlogged_hash_index ON unlogged_hash_table USING hash (id int4_ops);
---END---
---START---
DROP TABLE unlogged_hash_table;
---END---
---START---
-- CREATE INDEX hash_ovfl_index ON hash_ovfl_heap USING hash (x int4_ops);

-- Test hash index build tuplesorting.  Force hash tuplesort using low
-- maintenance_work_mem setting and fillfactor:
SET maintenance_work_mem = '1MB';
---END---
---START---
CREATE INDEX hash_tuplesort_idx ON tenk1 USING hash (stringu1 name_ops) WITH (fillfactor = 10);
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM tenk1 WHERE stringu1 = 'TVAAAA';
---END---
---START---
SELECT count(*) FROM tenk1 WHERE stringu1 = 'TVAAAA';
---END---
---START---
DROP INDEX hash_tuplesort_idx;
---END---
---START---
RESET maintenance_work_mem;
---END---
---START---
--
-- Test unique null behavior
--
CREATE TABLE unique_tbl (i int, t text);
---END---
---START---
CREATE UNIQUE INDEX unique_idx1 ON unique_tbl (i) NULLS DISTINCT;
---END---
---START---
CREATE UNIQUE INDEX unique_idx2 ON unique_tbl (i) NULLS NOT DISTINCT;
---END---
---START---
INSERT INTO unique_tbl VALUES (1, 'one');
---END---
---START---
INSERT INTO unique_tbl VALUES (2, 'two');
---END---
---START---
INSERT INTO unique_tbl VALUES (3, 'three');
---END---
---START---
INSERT INTO unique_tbl VALUES (4, 'four');
---END---
---START---
INSERT INTO unique_tbl VALUES (5, 'one');
---END---
---START---
INSERT INTO unique_tbl (t) VALUES ('six');
---END---
---START---
INSERT INTO unique_tbl (t) VALUES ('seven');
---END---
---START---
-- error from unique_idx2

DROP INDEX unique_idx1, unique_idx2;
---END---
---START---
INSERT INTO unique_tbl (t) VALUES ('seven');
---END---
---START---
-- build indexes on filled table
CREATE UNIQUE INDEX unique_idx3 ON unique_tbl (i) NULLS DISTINCT;
---END---
---START---
-- ok
CREATE UNIQUE INDEX unique_idx4 ON unique_tbl (i) NULLS NOT DISTINCT;
---END---
---START---
-- error

DELETE FROM unique_tbl WHERE t = 'seven';
---END---
---START---
CREATE UNIQUE INDEX unique_idx4 ON unique_tbl (i) NULLS NOT DISTINCT;
---END---
---START---
-- ok now

\d unique_tbl
\d unique_idx3
\d unique_idx4
SELECT pg_get_indexdef('unique_idx3'::regclass);
---END---
---START---
SELECT pg_get_indexdef('unique_idx4'::regclass);
---END---
---START---
DROP TABLE unique_tbl;
---END---
---START---
--
-- Test functional index
--
CREATE TABLE func_index_heap (f1 text, f2 text);
---END---
---START---
CREATE UNIQUE INDEX func_index_index on func_index_heap (textcat(f1,f2));
---END---
---START---
INSERT INTO func_index_heap VALUES('ABC','DEF');
---END---
---START---
INSERT INTO func_index_heap VALUES('AB','CDEFG');
---END---
---START---
INSERT INTO func_index_heap VALUES('QWE','RTY');
---END---
---START---
-- this should fail because of unique index:
INSERT INTO func_index_heap VALUES('ABCD', 'EF');
---END---
---START---
-- but this shouldn't:
INSERT INTO func_index_heap VALUES('QWERTY');
---END---
---START---
-- while we're here, see that the metadata looks sane
\d func_index_heap
\d func_index_index


--
-- Same test, expressional index
--
DROP TABLE func_index_heap;
---END---
---START---
CREATE TABLE func_index_heap (f1 text, f2 text);
---END---
---START---
CREATE UNIQUE INDEX func_index_index on func_index_heap ((f1 || f2) text_ops);
---END---
---START---
INSERT INTO func_index_heap VALUES('ABC','DEF');
---END---
---START---
INSERT INTO func_index_heap VALUES('AB','CDEFG');
---END---
---START---
INSERT INTO func_index_heap VALUES('QWE','RTY');
---END---
---START---
-- this should fail because of unique index:
INSERT INTO func_index_heap VALUES('ABCD', 'EF');
---END---
---START---
-- but this shouldn't:
INSERT INTO func_index_heap VALUES('QWERTY');
---END---
---START---
-- while we're here, see that the metadata looks sane
\d func_index_heap
\d func_index_index

-- this should fail because of unsafe column type (anonymous record)
create index on func_index_heap ((f1 || f2), (row(f1, f2)));
---END---
---START---
--
-- Test unique index with included columns
--
CREATE TABLE covering_index_heap (f1 int, f2 int, f3 text);
---END---
---START---
CREATE UNIQUE INDEX covering_index_index on covering_index_heap (f1,f2) INCLUDE(f3);
---END---
---START---
INSERT INTO covering_index_heap VALUES(1,1,'AAA');
---END---
---START---
INSERT INTO covering_index_heap VALUES(1,2,'AAA');
---END---
---START---
-- this should fail because of unique index on f1,f2:
INSERT INTO covering_index_heap VALUES(1,2,'BBB');
---END---
---START---
-- and this shouldn't:
INSERT INTO covering_index_heap VALUES(1,4,'AAA');
---END---
---START---
-- Try to build index on table that already contains data
CREATE UNIQUE INDEX covering_pkey on covering_index_heap (f1,f2) INCLUDE(f3);
---END---
---START---
-- Try to use existing covering index as primary key
ALTER TABLE covering_index_heap ADD CONSTRAINT covering_pkey PRIMARY KEY USING INDEX
covering_pkey;
---END---
---START---
DROP TABLE covering_index_heap;
---END---
---START---
--
-- Try some concurrent index builds
--
-- Unfortunately this only tests about half the code paths because there are
-- no concurrent updates happening to the table at the same time.

CREATE TABLE concur_heap (f1 text, f2 text);
---END---
---START---
-- empty table
CREATE INDEX CONCURRENTLY concur_index1 ON concur_heap(f2,f1);
---END---
---START---
CREATE INDEX CONCURRENTLY IF NOT EXISTS concur_index1 ON concur_heap(f2,f1);
---END---
---START---
INSERT INTO concur_heap VALUES  ('a','b');
---END---
---START---
INSERT INTO concur_heap VALUES  ('b','b');
---END---
---START---
-- unique index
CREATE UNIQUE INDEX CONCURRENTLY concur_index2 ON concur_heap(f1);
---END---
---START---
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS concur_index2 ON concur_heap(f1);
---END---
---START---
-- check if constraint is set up properly to be enforced
INSERT INTO concur_heap VALUES ('b','x');
---END---
---START---
-- check if constraint is enforced properly at build time
CREATE UNIQUE INDEX CONCURRENTLY concur_index3 ON concur_heap(f2);
---END---
---START---
-- test that expression indexes and partial indexes work concurrently
CREATE INDEX CONCURRENTLY concur_index4 on concur_heap(f2) WHERE f1='a';
---END---
---START---
CREATE INDEX CONCURRENTLY concur_index5 on concur_heap(f2) WHERE f1='x';
---END---
---START---
-- here we also check that you can default the index name
CREATE INDEX CONCURRENTLY on concur_heap((f2||f1));
---END---
---START---
-- You can't do a concurrent index build in a transaction
BEGIN;
---END---
---START---
CREATE INDEX CONCURRENTLY concur_index7 ON concur_heap(f1);
---END---
---START---
COMMIT;
---END---
---START---
-- test where predicate is able to do a transactional update during
-- a concurrent build before switching pg_index state flags.
CREATE FUNCTION predicate_stable() RETURNS bool IMMUTABLE
LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE 'SELECT txid_current()';
  RETURN true;
END; $$;
---END---
---START---
CREATE INDEX CONCURRENTLY concur_index8 ON concur_heap (f1)
  WHERE predicate_stable();
---END---
---START---
DROP INDEX concur_index8;
---END---
---START---
DROP FUNCTION predicate_stable();
---END---
---START---
-- But you can do a regular index build in a transaction
BEGIN;
---END---
---START---
CREATE INDEX std_index on concur_heap(f2);
---END---
---START---
COMMIT;
---END---
---START---
-- Failed builds are left invalid by VACUUM FULL, fixed by REINDEX
VACUUM FULL concur_heap;
---END---
---START---
REINDEX TABLE concur_heap;
---END---
---START---
DELETE FROM concur_heap WHERE f1 = 'b';
---END---
---START---
VACUUM FULL concur_heap;
---END---
---START---
\d concur_heap
REINDEX TABLE concur_heap;
---END---
---START---
\d concur_heap

-- Temporary tables with concurrent builds and on-commit actions
-- CONCURRENTLY used with CREATE INDEX and DROP INDEX is ignored.
-- PRESERVE ROWS, the default.
CREATE TEMP TABLE concur_temp (f1 int, f2 text)
  ON COMMIT PRESERVE ROWS;
---END---
---START---
INSERT INTO concur_temp VALUES (1, 'foo'), (2, 'bar');
---END---
---START---
CREATE INDEX CONCURRENTLY concur_temp_ind ON concur_temp(f1);
---END---
---START---
DROP INDEX CONCURRENTLY concur_temp_ind;
---END---
---START---
DROP TABLE concur_temp;
---END---
---START---
-- ON COMMIT DROP
BEGIN;
---END---
---START---
CREATE TEMP TABLE concur_temp (f1 int, f2 text)
  ON COMMIT DROP;
---END---
---START---
INSERT INTO concur_temp VALUES (1, 'foo'), (2, 'bar');
---END---
---START---
-- Fails when running in a transaction.
CREATE INDEX CONCURRENTLY concur_temp_ind ON concur_temp(f1);
---END---
---START---
COMMIT;
---END---
---START---
-- ON COMMIT DELETE ROWS
CREATE TEMP TABLE concur_temp (f1 int, f2 text)
  ON COMMIT DELETE ROWS;
---END---
---START---
INSERT INTO concur_temp VALUES (1, 'foo'), (2, 'bar');
---END---
---START---
CREATE INDEX CONCURRENTLY concur_temp_ind ON concur_temp(f1);
---END---
---START---
DROP INDEX CONCURRENTLY concur_temp_ind;
---END---
---START---
DROP TABLE concur_temp;
---END---
---START---
--
-- Try some concurrent index drops
--
DROP INDEX CONCURRENTLY "concur_index2";
---END---
---START---
-- works
DROP INDEX CONCURRENTLY IF EXISTS "concur_index2";
---END---
---START---
-- notice

-- failures
DROP INDEX CONCURRENTLY "concur_index2", "concur_index3";
---END---
---START---
BEGIN;
---END---
---START---
DROP INDEX CONCURRENTLY "concur_index5";
---END---
---START---
ROLLBACK;
---END---
---START---
-- successes
DROP INDEX CONCURRENTLY IF EXISTS "concur_index3";
---END---
---START---
DROP INDEX CONCURRENTLY "concur_index4";
---END---
---START---
DROP INDEX CONCURRENTLY "concur_index5";
---END---
---START---
DROP INDEX CONCURRENTLY "concur_index1";
---END---
---START---
DROP INDEX CONCURRENTLY "concur_heap_expr_idx";
---END---
---START---
\d concur_heap

DROP TABLE concur_heap;
---END---
---START---
--
-- Test ADD CONSTRAINT USING INDEX
--

CREATE TABLE cwi_test( a int , b varchar(10), c char);
---END---
---START---
-- add some data so that all tests have something to work with.

INSERT INTO cwi_test VALUES(1, 2), (3, 4), (5, 6);
---END---
---START---
CREATE UNIQUE INDEX cwi_uniq_idx ON cwi_test(a , b);
---END---
---START---
ALTER TABLE cwi_test ADD primary key USING INDEX cwi_uniq_idx;
---END---
---START---
\d cwi_test
\d cwi_uniq_idx

CREATE UNIQUE INDEX cwi_uniq2_idx ON cwi_test(b , a);
---END---
---START---
ALTER TABLE cwi_test DROP CONSTRAINT cwi_uniq_idx,
	ADD CONSTRAINT cwi_replaced_pkey PRIMARY KEY
		USING INDEX cwi_uniq2_idx;
---END---
---START---
\d cwi_test
\d cwi_replaced_pkey

DROP INDEX cwi_replaced_pkey;
---END---
---START---
-- Should fail; a constraint depends on it

-- Check that non-default index options are rejected
CREATE UNIQUE INDEX cwi_uniq3_idx ON cwi_test(a desc);
---END---
---START---
ALTER TABLE cwi_test ADD UNIQUE USING INDEX cwi_uniq3_idx;
---END---
---START---
-- fail
CREATE UNIQUE INDEX cwi_uniq4_idx ON cwi_test(b collate "POSIX");
---END---
---START---
ALTER TABLE cwi_test ADD UNIQUE USING INDEX cwi_uniq4_idx;
---END---
---START---
-- fail

DROP TABLE cwi_test;
---END---
---START---
-- ADD CONSTRAINT USING INDEX is forbidden on partitioned tables
CREATE TABLE cwi_test(a int) PARTITION BY hash (a);
---END---
---START---
create unique index on cwi_test (a);
---END---
---START---
alter table cwi_test add primary key using index cwi_test_a_idx;
---END---
---START---
DROP TABLE cwi_test;
---END---
---START---
-- PRIMARY KEY constraint cannot be backed by a NULLS NOT DISTINCT index
CREATE TABLE cwi_test(a int, b int);
---END---
---START---
CREATE UNIQUE INDEX cwi_a_nnd ON cwi_test (a) NULLS NOT DISTINCT;
---END---
---START---
ALTER TABLE cwi_test ADD PRIMARY KEY USING INDEX cwi_a_nnd;
---END---
---START---
DROP TABLE cwi_test;
---END---
---START---
--
-- Check handling of indexes on system columns
--
CREATE TABLE syscol_table (a INT);
---END---
---START---
-- System columns cannot be indexed
CREATE INDEX ON syscolcol_table (ctid);
---END---
---START---
-- nor used in expressions
CREATE INDEX ON syscol_table ((ctid >= '(1000,0)'));
---END---
---START---
-- nor used in predicates
CREATE INDEX ON syscol_table (a) WHERE ctid >= '(1000,0)';
---END---
---START---
DROP TABLE syscol_table;
---END---
---START---
--
-- Tests for IS NULL/IS NOT NULL with b-tree indexes
--

CREATE TABLE onek_with_null AS SELECT unique1, unique2 FROM onek;
---END---
---START---
INSERT INTO onek_with_null (unique1,unique2) VALUES (NULL, -1), (NULL, NULL);
---END---
---START---
CREATE UNIQUE INDEX onek_nulltest ON onek_with_null (unique2,unique1);
---END---
---START---
SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = ON;
---END---
---START---
SET enable_bitmapscan = ON;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL AND unique1 > 500;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique1 > 500;
---END---
---START---
DROP INDEX onek_nulltest;
---END---
---START---
CREATE UNIQUE INDEX onek_nulltest ON onek_with_null (unique2 desc,unique1);
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL AND unique1 > 500;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique1 > 500;
---END---
---START---
DROP INDEX onek_nulltest;
---END---
---START---
CREATE UNIQUE INDEX onek_nulltest ON onek_with_null (unique2 desc nulls last,unique1);
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL AND unique1 > 500;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique1 > 500;
---END---
---START---
DROP INDEX onek_nulltest;
---END---
---START---
CREATE UNIQUE INDEX onek_nulltest ON onek_with_null (unique2  nulls first,unique1);
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique2 IS NOT NULL;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NOT NULL AND unique1 > 500;
---END---
---START---
SELECT count(*) FROM onek_with_null WHERE unique1 IS NULL AND unique1 > 500;
---END---
---START---
DROP INDEX onek_nulltest;
---END---
---START---
-- Check initial-positioning logic too

CREATE UNIQUE INDEX onek_nulltest ON onek_with_null (unique2);
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
SELECT unique1, unique2 FROM onek_with_null
  ORDER BY unique2 LIMIT 2;
---END---
---START---
SELECT unique1, unique2 FROM onek_with_null WHERE unique2 >= -1
  ORDER BY unique2 LIMIT 2;
---END---
---START---
SELECT unique1, unique2 FROM onek_with_null WHERE unique2 >= 0
  ORDER BY unique2 LIMIT 2;
---END---
---START---
SELECT unique1, unique2 FROM onek_with_null
  ORDER BY unique2 DESC LIMIT 2;
---END---
---START---
SELECT unique1, unique2 FROM onek_with_null WHERE unique2 >= -1
  ORDER BY unique2 DESC LIMIT 2;
---END---
---START---
SELECT unique1, unique2 FROM onek_with_null WHERE unique2 < 999
  ORDER BY unique2 DESC LIMIT 2;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_indexscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
DROP TABLE onek_with_null;
---END---
---START---
--
-- Check bitmap index path planning
--

EXPLAIN (COSTS OFF)
SELECT * FROM tenk1
  WHERE thousand = 42 AND (tenthous = 1 OR tenthous = 3 OR tenthous = 42);
---END---
---START---
SELECT * FROM tenk1
  WHERE thousand = 42 AND (tenthous = 1 OR tenthous = 3 OR tenthous = 42);
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM tenk1
  WHERE hundred = 42 AND (thousand = 42 OR thousand = 99);
---END---
---START---
SELECT count(*) FROM tenk1
  WHERE hundred = 42 AND (thousand = 42 OR thousand = 99);
---END---
---START---
--
-- Check behavior with duplicate index column contents
--

CREATE TABLE dupindexcols AS
  SELECT unique1 as id, stringu2::text as f1 FROM tenk1;
---END---
---START---
CREATE INDEX dupindexcols_i ON dupindexcols (f1, id, f1 text_pattern_ops);
---END---
---START---
ANALYZE dupindexcols;
---END---
---START---
EXPLAIN (COSTS OFF)
  SELECT count(*) FROM dupindexcols
    WHERE f1 BETWEEN 'WA' AND 'ZZZ' and id < 1000 and f1 ~<~ 'YX';
---END---
---START---
SELECT count(*) FROM dupindexcols
  WHERE f1 BETWEEN 'WA' AND 'ZZZ' and id < 1000 and f1 ~<~ 'YX';
---END---
---START---
--
-- Check ordering of =ANY indexqual results (bug in 9.2.0)
--

explain (costs off)
SELECT unique1 FROM tenk1
WHERE unique1 IN (1,42,7)
ORDER BY unique1;
---END---
---START---
SELECT unique1 FROM tenk1
WHERE unique1 IN (1,42,7)
ORDER BY unique1;
---END---
---START---
explain (costs off)
SELECT thousand, tenthous FROM tenk1
WHERE thousand < 2 AND tenthous IN (1001,3000)
ORDER BY thousand;
---END---
---START---
SELECT thousand, tenthous FROM tenk1
WHERE thousand < 2 AND tenthous IN (1001,3000)
ORDER BY thousand;
---END---
---START---
SET enable_indexonlyscan = OFF;
---END---
---START---
explain (costs off)
SELECT thousand, tenthous FROM tenk1
WHERE thousand < 2 AND tenthous IN (1001,3000)
ORDER BY thousand;
---END---
---START---
SELECT thousand, tenthous FROM tenk1
WHERE thousand < 2 AND tenthous IN (1001,3000)
ORDER BY thousand;
---END---
---START---
RESET enable_indexonlyscan;
---END---
---START---
--
-- Check elimination of constant-NULL subexpressions
--

explain (costs off)
  select * from tenk1 where (thousand, tenthous) in ((1,1001), (null,null));
---END---
---START---
--
-- Check matching of boolean index columns to WHERE conditions and sort keys
--

create temp table boolindex (b bool, i int, unique(b, i), junk float);
---END---
---START---
explain (costs off)
  select * from boolindex order by b, i limit 10;
---END---
---START---
explain (costs off)
  select * from boolindex where b order by i limit 10;
---END---
---START---
explain (costs off)
  select * from boolindex where b = true order by i desc limit 10;
---END---
---START---
explain (costs off)
  select * from boolindex where not b order by i limit 10;
---END---
---START---
explain (costs off)
  select * from boolindex where b is true order by i desc limit 10;
---END---
---START---
explain (costs off)
  select * from boolindex where b is false order by i desc limit 10;
---END---
---START---
--
-- REINDEX (VERBOSE)
--
CREATE TABLE reindex_verbose(id integer primary key);
---END---
---START---
\set VERBOSITY terse \\ -- suppress machine-dependent details
REINDEX (VERBOSE) TABLE reindex_verbose;
---END---
---START---
\set VERBOSITY default
DROP TABLE reindex_verbose;
---END---
---START---
--
-- REINDEX CONCURRENTLY
--
CREATE TABLE concur_reindex_tab (c1 int);
---END---
---START---
-- REINDEX
REINDEX TABLE concur_reindex_tab;
---END---
---START---
-- notice
REINDEX (CONCURRENTLY) TABLE concur_reindex_tab;
---END---
---START---
-- notice
ALTER TABLE concur_reindex_tab ADD COLUMN c2 text;
---END---
---START---
-- add toast index
-- Normal index with integer column
CREATE UNIQUE INDEX concur_reindex_ind1 ON concur_reindex_tab(c1);
---END---
---START---
-- Normal index with text column
CREATE INDEX concur_reindex_ind2 ON concur_reindex_tab(c2);
---END---
---START---
-- UNIQUE index with expression
CREATE UNIQUE INDEX concur_reindex_ind3 ON concur_reindex_tab(abs(c1));
---END---
---START---
-- Duplicate column names
CREATE INDEX concur_reindex_ind4 ON concur_reindex_tab(c1, c1, c2);
---END---
---START---
-- Create table for check on foreign key dependence switch with indexes swapped
ALTER TABLE concur_reindex_tab ADD PRIMARY KEY USING INDEX concur_reindex_ind1;
---END---
---START---
CREATE TABLE concur_reindex_tab2 (c1 int REFERENCES concur_reindex_tab);
---END---
---START---
INSERT INTO concur_reindex_tab VALUES  (1, 'a');
---END---
---START---
INSERT INTO concur_reindex_tab VALUES  (2, 'a');
---END---
---START---
-- Reindex concurrently of exclusion constraint currently not supported
CREATE TABLE concur_reindex_tab3 (c1 int, c2 int4range, EXCLUDE USING gist (c2 WITH &&));
---END---
---START---
INSERT INTO concur_reindex_tab3 VALUES  (3, '[1,2]');
---END---
---START---
REINDEX INDEX CONCURRENTLY  concur_reindex_tab3_c2_excl;
---END---
---START---
-- error
REINDEX TABLE CONCURRENTLY concur_reindex_tab3;
---END---
---START---
-- succeeds with warning
INSERT INTO concur_reindex_tab3 VALUES  (4, '[2,4]');
---END---
---START---
-- Check materialized views
CREATE MATERIALIZED VIEW concur_reindex_matview AS SELECT * FROM concur_reindex_tab;
---END---
---START---
-- Dependency lookup before and after the follow-up REINDEX commands.
-- These should remain consistent.
SELECT pg_describe_object(classid, objid, objsubid) as obj,
       pg_describe_object(refclassid,refobjid,refobjsubid) as objref,
       deptype
FROM pg_depend
WHERE classid = 'pg_class'::regclass AND
  objid in ('concur_reindex_tab'::regclass,
            'concur_reindex_ind1'::regclass,
	    'concur_reindex_ind2'::regclass,
	    'concur_reindex_ind3'::regclass,
	    'concur_reindex_ind4'::regclass,
	    'concur_reindex_matview'::regclass)
  ORDER BY 1, 2;
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_reindex_ind1;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_reindex_tab;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_reindex_matview;
---END---
---START---
SELECT pg_describe_object(classid, objid, objsubid) as obj,
       pg_describe_object(refclassid,refobjid,refobjsubid) as objref,
       deptype
FROM pg_depend
WHERE classid = 'pg_class'::regclass AND
  objid in ('concur_reindex_tab'::regclass,
            'concur_reindex_ind1'::regclass,
	    'concur_reindex_ind2'::regclass,
	    'concur_reindex_ind3'::regclass,
	    'concur_reindex_ind4'::regclass,
	    'concur_reindex_matview'::regclass)
  ORDER BY 1, 2;
---END---
---START---
-- Check that comments are preserved
CREATE TABLE testcomment (i int);
---END---
---START---
CREATE INDEX testcomment_idx1 ON testcomment (i);
---END---
---START---
COMMENT ON INDEX testcomment_idx1 IS 'test comment';
---END---
---START---
SELECT obj_description('testcomment_idx1'::regclass, 'pg_class');
---END---
---START---
REINDEX TABLE testcomment;
---END---
---START---
SELECT obj_description('testcomment_idx1'::regclass, 'pg_class');
---END---
---START---
REINDEX TABLE CONCURRENTLY testcomment;
---END---
---START---
SELECT obj_description('testcomment_idx1'::regclass, 'pg_class');
---END---
---START---
DROP TABLE testcomment;
---END---
---START---
-- Check that indisclustered updates are preserved
CREATE TABLE concur_clustered(i int);
---END---
---START---
CREATE INDEX concur_clustered_i_idx ON concur_clustered(i);
---END---
---START---
ALTER TABLE concur_clustered CLUSTER ON concur_clustered_i_idx;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_clustered;
---END---
---START---
SELECT indexrelid::regclass, indisclustered FROM pg_index
  WHERE indrelid = 'concur_clustered'::regclass;
---END---
---START---
DROP TABLE concur_clustered;
---END---
---START---
-- Check that indisreplident updates are preserved.
CREATE TABLE concur_replident(i int NOT NULL);
---END---
---START---
CREATE UNIQUE INDEX concur_replident_i_idx ON concur_replident(i);
---END---
---START---
ALTER TABLE concur_replident REPLICA IDENTITY
  USING INDEX concur_replident_i_idx;
---END---
---START---
SELECT indexrelid::regclass, indisreplident FROM pg_index
  WHERE indrelid = 'concur_replident'::regclass;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_replident;
---END---
---START---
SELECT indexrelid::regclass, indisreplident FROM pg_index
  WHERE indrelid = 'concur_replident'::regclass;
---END---
---START---
DROP TABLE concur_replident;
---END---
---START---
-- Check that opclass parameters are preserved
CREATE TABLE concur_appclass_tab(i tsvector, j tsvector, k tsvector);
---END---
---START---
CREATE INDEX concur_appclass_ind on concur_appclass_tab
  USING gist (i tsvector_ops (siglen='1000'), j tsvector_ops (siglen='500'));
---END---
---START---
CREATE INDEX concur_appclass_ind_2 on concur_appclass_tab
  USING gist (k tsvector_ops (siglen='300'), j tsvector_ops);
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_appclass_tab;
---END---
---START---
\d concur_appclass_tab
DROP TABLE concur_appclass_tab;
---END---
---START---
-- Partitions
-- Create some partitioned tables
CREATE TABLE concur_reindex_part (c1 int, c2 int) PARTITION BY RANGE (c1);
---END---
---START---
CREATE TABLE concur_reindex_part_0 PARTITION OF concur_reindex_part
  FOR VALUES FROM (0) TO (10) PARTITION BY list (c2);
---END---
---START---
CREATE TABLE concur_reindex_part_0_1 PARTITION OF concur_reindex_part_0
  FOR VALUES IN (1);
---END---
---START---
CREATE TABLE concur_reindex_part_0_2 PARTITION OF concur_reindex_part_0
  FOR VALUES IN (2);
---END---
---START---
-- This partitioned table will have no partitions.
CREATE TABLE concur_reindex_part_10 PARTITION OF concur_reindex_part
  FOR VALUES FROM (10) TO (20) PARTITION BY list (c2);
---END---
---START---
-- Create some partitioned indexes
CREATE INDEX concur_reindex_part_index ON ONLY concur_reindex_part (c1);
---END---
---START---
CREATE INDEX concur_reindex_part_index_0 ON ONLY concur_reindex_part_0 (c1);
---END---
---START---
ALTER INDEX concur_reindex_part_index ATTACH PARTITION concur_reindex_part_index_0;
---END---
---START---
-- This partitioned index will have no partitions.
CREATE INDEX concur_reindex_part_index_10 ON ONLY concur_reindex_part_10 (c1);
---END---
---START---
ALTER INDEX concur_reindex_part_index ATTACH PARTITION concur_reindex_part_index_10;
---END---
---START---
CREATE INDEX concur_reindex_part_index_0_1 ON ONLY concur_reindex_part_0_1 (c1);
---END---
---START---
ALTER INDEX concur_reindex_part_index_0 ATTACH PARTITION concur_reindex_part_index_0_1;
---END---
---START---
CREATE INDEX concur_reindex_part_index_0_2 ON ONLY concur_reindex_part_0_2 (c1);
---END---
---START---
ALTER INDEX concur_reindex_part_index_0 ATTACH PARTITION concur_reindex_part_index_0_2;
---END---
---START---
SELECT relid, parentrelid, level FROM pg_partition_tree('concur_reindex_part_index')
  ORDER BY relid, level;
---END---
---START---
SELECT relid, parentrelid, level FROM pg_partition_tree('concur_reindex_part_index')
  ORDER BY relid, level;
---END---
---START---
-- REINDEX should preserve dependencies of partition tree.
SELECT pg_describe_object(classid, objid, objsubid) as obj,
       pg_describe_object(refclassid,refobjid,refobjsubid) as objref,
       deptype
FROM pg_depend
WHERE classid = 'pg_class'::regclass AND
  objid in ('concur_reindex_part'::regclass,
            'concur_reindex_part_0'::regclass,
            'concur_reindex_part_0_1'::regclass,
            'concur_reindex_part_0_2'::regclass,
            'concur_reindex_part_index'::regclass,
            'concur_reindex_part_index_0'::regclass,
            'concur_reindex_part_index_0_1'::regclass,
            'concur_reindex_part_index_0_2'::regclass)
  ORDER BY 1, 2;
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_reindex_part_index_0_1;
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_reindex_part_index_0_2;
---END---
---START---
SELECT relid, parentrelid, level FROM pg_partition_tree('concur_reindex_part_index')
  ORDER BY relid, level;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_reindex_part_0_1;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_reindex_part_0_2;
---END---
---START---
SELECT pg_describe_object(classid, objid, objsubid) as obj,
       pg_describe_object(refclassid,refobjid,refobjsubid) as objref,
       deptype
FROM pg_depend
WHERE classid = 'pg_class'::regclass AND
  objid in ('concur_reindex_part'::regclass,
            'concur_reindex_part_0'::regclass,
            'concur_reindex_part_0_1'::regclass,
            'concur_reindex_part_0_2'::regclass,
            'concur_reindex_part_index'::regclass,
            'concur_reindex_part_index_0'::regclass,
            'concur_reindex_part_index_0_1'::regclass,
            'concur_reindex_part_index_0_2'::regclass)
  ORDER BY 1, 2;
---END---
---START---
SELECT relid, parentrelid, level FROM pg_partition_tree('concur_reindex_part_index')
  ORDER BY relid, level;
---END---
---START---
-- REINDEX for partitioned indexes
-- REINDEX TABLE fails for partitioned indexes
-- Top-most parent index
REINDEX TABLE concur_reindex_part_index;
---END---
---START---
-- error
REINDEX TABLE CONCURRENTLY concur_reindex_part_index;
---END---
---START---
-- error
-- Partitioned index with no leaves
REINDEX TABLE concur_reindex_part_index_10;
---END---
---START---
-- error
REINDEX TABLE CONCURRENTLY concur_reindex_part_index_10;
---END---
---START---
-- error
-- Cannot run in a transaction block
BEGIN;
---END---
---START---
REINDEX INDEX concur_reindex_part_index;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Helper functions to track changes of relfilenodes in a partition tree.
-- Create a table tracking the relfilenode state.
CREATE OR REPLACE FUNCTION create_relfilenode_part(relname text, indname text)
  RETURNS VOID AS
  $func$
  BEGIN
  EXECUTE format('
    CREATE TABLE %I AS
      SELECT oid, relname, relfilenode, relkind, reltoastrelid
      FROM pg_class
      WHERE oid IN
         (SELECT relid FROM pg_partition_tree(''%I''));',
	 relname, indname);
  END
  $func$ LANGUAGE plpgsql;
---END---
---START---
CREATE OR REPLACE FUNCTION compare_relfilenode_part(tabname text)
  RETURNS TABLE (relname name, relkind "char", state text) AS
  $func$
  BEGIN
    RETURN QUERY EXECUTE
      format(
        'SELECT  b.relname,
                 b.relkind,
                 CASE WHEN a.relfilenode = b.relfilenode THEN ''relfilenode is unchanged''
                 ELSE ''relfilenode has changed'' END
           -- Do not join with OID here as CONCURRENTLY changes it.
           FROM %I b JOIN pg_class a ON b.relname = a.relname
           ORDER BY 1;', tabname);
  END
  $func$ LANGUAGE plpgsql;
---END---
---START---
--  Check that expected relfilenodes are changed, non-concurrent case.
SELECT create_relfilenode_part('reindex_index_status', 'concur_reindex_part_index');
---END---
---START---
REINDEX INDEX concur_reindex_part_index;
---END---
---START---
SELECT * FROM compare_relfilenode_part('reindex_index_status');
---END---
---START---
DROP TABLE reindex_index_status;
---END---
---START---
-- concurrent case.
SELECT create_relfilenode_part('reindex_index_status', 'concur_reindex_part_index');
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_reindex_part_index;
---END---
---START---
SELECT * FROM compare_relfilenode_part('reindex_index_status');
---END---
---START---
DROP TABLE reindex_index_status;
---END---
---START---
-- REINDEX for partitioned tables
-- REINDEX INDEX fails for partitioned tables
-- Top-most parent
REINDEX INDEX concur_reindex_part;
---END---
---START---
-- error
REINDEX INDEX CONCURRENTLY concur_reindex_part;
---END---
---START---
-- error
-- Partitioned with no leaves
REINDEX INDEX concur_reindex_part_10;
---END---
---START---
-- error
REINDEX INDEX CONCURRENTLY concur_reindex_part_10;
---END---
---START---
-- error
-- Cannot run in a transaction block
BEGIN;
---END---
---START---
REINDEX TABLE concur_reindex_part;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Check that expected relfilenodes are changed, non-concurrent case.
-- Note that the partition tree changes of the *indexes* need to be checked.
SELECT create_relfilenode_part('reindex_index_status', 'concur_reindex_part_index');
---END---
---START---
REINDEX TABLE concur_reindex_part;
---END---
---START---
SELECT * FROM compare_relfilenode_part('reindex_index_status');
---END---
---START---
DROP TABLE reindex_index_status;
---END---
---START---
-- concurrent case.
SELECT create_relfilenode_part('reindex_index_status', 'concur_reindex_part_index');
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_reindex_part;
---END---
---START---
SELECT * FROM compare_relfilenode_part('reindex_index_status');
---END---
---START---
DROP TABLE reindex_index_status;
---END---
---START---
DROP FUNCTION create_relfilenode_part;
---END---
---START---
DROP FUNCTION compare_relfilenode_part;
---END---
---START---
-- Cleanup of partition tree used for REINDEX test.
DROP TABLE concur_reindex_part;
---END---
---START---
-- Check errors
-- Cannot run inside a transaction block
BEGIN;
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_reindex_tab;
---END---
---START---
COMMIT;
---END---
---START---
REINDEX TABLE CONCURRENTLY pg_class;
---END---
---START---
-- no catalog relation
REINDEX INDEX CONCURRENTLY pg_class_oid_index;
---END---
---START---
-- no catalog index
-- These are the toast table and index of pg_authid.
REINDEX TABLE CONCURRENTLY pg_toast.pg_toast_1260;
---END---
---START---
-- no catalog toast table
REINDEX INDEX CONCURRENTLY pg_toast.pg_toast_1260_index;
---END---
---START---
-- no catalog toast index
REINDEX SYSTEM CONCURRENTLY postgres;
---END---
---START---
-- not allowed for SYSTEM
REINDEX (CONCURRENTLY) SYSTEM postgres;
---END---
---START---
-- ditto
REINDEX (CONCURRENTLY) SYSTEM;
---END---
---START---
-- ditto
-- Warns about catalog relations
REINDEX SCHEMA CONCURRENTLY pg_catalog;
---END---
---START---
-- Not the current database
REINDEX DATABASE not_current_database;
---END---
---START---
-- Check the relation status, there should not be invalid indexes
\d concur_reindex_tab
DROP MATERIALIZED VIEW concur_reindex_matview;
---END---
---START---
DROP TABLE concur_reindex_tab, concur_reindex_tab2, concur_reindex_tab3;
---END---
---START---
-- Check handling of invalid indexes
CREATE TABLE concur_reindex_tab4 (c1 int);
---END---
---START---
INSERT INTO concur_reindex_tab4 VALUES (1), (1), (2);
---END---
---START---
-- This trick creates an invalid index.
CREATE UNIQUE INDEX CONCURRENTLY concur_reindex_ind5 ON concur_reindex_tab4 (c1);
---END---
---START---
-- Reindexing concurrently this index fails with the same failure.
-- The extra index created is itself invalid, and can be dropped.
REINDEX INDEX CONCURRENTLY concur_reindex_ind5;
---END---
---START---
\d concur_reindex_tab4
DROP INDEX concur_reindex_ind5_ccnew;
---END---
---START---
-- This makes the previous failure go away, so the index can become valid.
DELETE FROM concur_reindex_tab4 WHERE c1 = 1;
---END---
---START---
-- The invalid index is not processed when running REINDEX TABLE.
REINDEX TABLE CONCURRENTLY concur_reindex_tab4;
---END---
---START---
\d concur_reindex_tab4
-- But it is fixed with REINDEX INDEX.
REINDEX INDEX CONCURRENTLY concur_reindex_ind5;
---END---
---START---
\d concur_reindex_tab4
DROP TABLE concur_reindex_tab4;
---END---
---START---
-- Check handling of indexes with expressions and predicates.  The
-- definitions of the rebuilt indexes should match the original
-- definitions.
CREATE TABLE concur_exprs_tab (c1 int , c2 boolean);
---END---
---START---
INSERT INTO concur_exprs_tab (c1, c2) VALUES (1369652450, FALSE),
  (414515746, TRUE),
  (897778963, FALSE);
---END---
---START---
CREATE UNIQUE INDEX concur_exprs_index_expr
  ON concur_exprs_tab ((c1::text COLLATE "C"));
---END---
---START---
CREATE UNIQUE INDEX concur_exprs_index_pred ON concur_exprs_tab (c1)
  WHERE (c1::text > 500000000::text COLLATE "C");
---END---
---START---
CREATE UNIQUE INDEX concur_exprs_index_pred_2
  ON concur_exprs_tab ((1 / c1))
  WHERE ('-H') >= (c2::TEXT) COLLATE "C";
---END---
---START---
ALTER INDEX concur_exprs_index_expr ALTER COLUMN 1 SET STATISTICS 100;
---END---
---START---
ANALYZE concur_exprs_tab;
---END---
---START---
SELECT starelid::regclass, count(*) FROM pg_statistic WHERE starelid IN (
  'concur_exprs_index_expr'::regclass,
  'concur_exprs_index_pred'::regclass,
  'concur_exprs_index_pred_2'::regclass)
  GROUP BY starelid ORDER BY starelid::regclass::text;
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_expr'::regclass);
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_pred'::regclass);
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_pred_2'::regclass);
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_exprs_tab;
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_expr'::regclass);
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_pred'::regclass);
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_pred_2'::regclass);
---END---
---START---
-- ALTER TABLE recreates the indexes, which should keep their collations.
ALTER TABLE concur_exprs_tab ALTER c2 TYPE TEXT;
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_expr'::regclass);
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_pred'::regclass);
---END---
---START---
SELECT pg_get_indexdef('concur_exprs_index_pred_2'::regclass);
---END---
---START---
-- Statistics should remain intact.
SELECT starelid::regclass, count(*) FROM pg_statistic WHERE starelid IN (
  'concur_exprs_index_expr'::regclass,
  'concur_exprs_index_pred'::regclass,
  'concur_exprs_index_pred_2'::regclass)
  GROUP BY starelid ORDER BY starelid::regclass::text;
---END---
---START---
-- attstattarget should remain intact
SELECT attrelid::regclass, attnum, attstattarget
  FROM pg_attribute WHERE attrelid IN (
    'concur_exprs_index_expr'::regclass,
    'concur_exprs_index_pred'::regclass,
    'concur_exprs_index_pred_2'::regclass)
  ORDER BY attrelid::regclass::text, attnum;
---END---
---START---
DROP TABLE concur_exprs_tab;
---END---
---START---
-- Temporary tables and on-commit actions, where CONCURRENTLY is ignored.
-- ON COMMIT PRESERVE ROWS, the default.
CREATE TEMP TABLE concur_temp_tab_1 (c1 int, c2 text)
  ON COMMIT PRESERVE ROWS;
---END---
---START---
INSERT INTO concur_temp_tab_1 VALUES (1, 'foo'), (2, 'bar');
---END---
---START---
CREATE INDEX concur_temp_ind_1 ON concur_temp_tab_1(c2);
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_temp_tab_1;
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_temp_ind_1;
---END---
---START---
-- Still fails in transaction blocks
BEGIN;
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_temp_ind_1;
---END---
---START---
COMMIT;
---END---
---START---
-- ON COMMIT DELETE ROWS
CREATE TEMP TABLE concur_temp_tab_2 (c1 int, c2 text)
  ON COMMIT DELETE ROWS;
---END---
---START---
CREATE INDEX concur_temp_ind_2 ON concur_temp_tab_2(c2);
---END---
---START---
REINDEX TABLE CONCURRENTLY concur_temp_tab_2;
---END---
---START---
REINDEX INDEX CONCURRENTLY concur_temp_ind_2;
---END---
---START---
-- ON COMMIT DROP
BEGIN;
---END---
---START---
CREATE TEMP TABLE concur_temp_tab_3 (c1 int, c2 text)
  ON COMMIT PRESERVE ROWS;
---END---
---START---
INSERT INTO concur_temp_tab_3 VALUES (1, 'foo'), (2, 'bar');
---END---
---START---
CREATE INDEX concur_temp_ind_3 ON concur_temp_tab_3(c2);
---END---
---START---
-- Fails when running in a transaction
REINDEX INDEX CONCURRENTLY concur_temp_ind_3;
---END---
---START---
COMMIT;
---END---
---START---
-- REINDEX SCHEMA processes all temporary relations
CREATE TABLE reindex_temp_before AS
SELECT oid, relname, relfilenode, relkind, reltoastrelid
  FROM pg_class
  WHERE relname IN ('concur_temp_ind_1', 'concur_temp_ind_2');
---END---
---START---
SELECT pg_my_temp_schema()::regnamespace as temp_schema_name \gset
REINDEX SCHEMA CONCURRENTLY :temp_schema_name;
---END---
---START---
SELECT  b.relname,
        b.relkind,
        CASE WHEN a.relfilenode = b.relfilenode THEN 'relfilenode is unchanged'
        ELSE 'relfilenode has changed' END
  FROM reindex_temp_before b JOIN pg_class a ON b.oid = a.oid
  ORDER BY 1;
---END---
---START---
DROP TABLE concur_temp_tab_1, concur_temp_tab_2, reindex_temp_before;
---END---
---START---
--
-- REINDEX SCHEMA
--
REINDEX SCHEMA schema_to_reindex;
---END---
---START---
-- failure, schema does not exist
CREATE SCHEMA schema_to_reindex;
---END---
---START---
SET search_path = 'schema_to_reindex';
---END---
---START---
CREATE TABLE table1(col1 SERIAL PRIMARY KEY);
---END---
---START---
INSERT INTO table1 SELECT generate_series(1,400);
---END---
---START---
CREATE TABLE table2(col1 SERIAL PRIMARY KEY, col2 TEXT NOT NULL);
---END---
---START---
INSERT INTO table2 SELECT generate_series(1,400), 'abc';
---END---
---START---
CREATE INDEX ON table2(col2);
---END---
---START---
CREATE MATERIALIZED VIEW matview AS SELECT col1 FROM table2;
---END---
---START---
CREATE INDEX ON matview(col1);
---END---
---START---
CREATE VIEW view AS SELECT col2 FROM table2;
---END---
---START---
CREATE TABLE reindex_before AS
SELECT oid, relname, relfilenode, relkind, reltoastrelid
	FROM pg_class
	where relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'schema_to_reindex');
---END---
---START---
INSERT INTO reindex_before
SELECT oid, 'pg_toast_TABLE', relfilenode, relkind, reltoastrelid
FROM pg_class WHERE oid IN
	(SELECT reltoastrelid FROM reindex_before WHERE reltoastrelid > 0);
---END---
---START---
INSERT INTO reindex_before
SELECT oid, 'pg_toast_TABLE_index', relfilenode, relkind, reltoastrelid
FROM pg_class where oid in
	(select indexrelid from pg_index where indrelid in
		(select reltoastrelid from reindex_before where reltoastrelid > 0));
---END---
---START---
REINDEX SCHEMA schema_to_reindex;
---END---
---START---
CREATE TABLE reindex_after AS SELECT oid, relname, relfilenode, relkind
	FROM pg_class
	where relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'schema_to_reindex');
---END---
---START---
SELECT  b.relname,
        b.relkind,
        CASE WHEN a.relfilenode = b.relfilenode THEN 'relfilenode is unchanged'
        ELSE 'relfilenode has changed' END
  FROM reindex_before b JOIN pg_class a ON b.oid = a.oid
  ORDER BY 1;
---END---
---START---
REINDEX SCHEMA schema_to_reindex;
---END---
---START---
BEGIN;
---END---
---START---
REINDEX SCHEMA schema_to_reindex;
---END---
---START---
-- failure, cannot run in a transaction
END;
---END---
---START---
-- concurrently
REINDEX SCHEMA CONCURRENTLY schema_to_reindex;
---END---
---START---
-- Failure for unauthorized user
CREATE ROLE regress_reindexuser NOLOGIN;
---END---
---START---
SET SESSION ROLE regress_reindexuser;
---END---
---START---
REINDEX SCHEMA schema_to_reindex;
---END---
---START---
-- Permission failures with toast tables and indexes (pg_authid here)
RESET ROLE;
---END---
---START---
GRANT USAGE ON SCHEMA pg_toast TO regress_reindexuser;
---END---
---START---
SET SESSION ROLE regress_reindexuser;
---END---
---START---
REINDEX TABLE pg_toast.pg_toast_1260;
---END---
---START---
REINDEX INDEX pg_toast.pg_toast_1260_index;
---END---
---START---
-- Clean up
RESET ROLE;
---END---
---START---
REVOKE USAGE ON SCHEMA pg_toast FROM regress_reindexuser;
---END---
---START---
DROP ROLE regress_reindexuser;
---END---
---START---
DROP SCHEMA schema_to_reindex CASCADE;
---END---
