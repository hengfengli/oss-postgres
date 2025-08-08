---START---
--
-- BTREE_INDEX
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

CREATE TABLE bt_i4_heap (
	seqno 		int4,
	random 		int4
);
---END---
---START---
CREATE TABLE bt_name_heap (gemini_pk serial PRIMARY KEY, seqno name, random int4);
---END---
---START---
CREATE TABLE bt_txt_heap (gemini_pk serial PRIMARY KEY, seqno text, random int4);
---END---
---START---
CREATE TABLE bt_f8_heap (gemini_pk serial PRIMARY KEY, seqno float8, random int4);
---END---
---START---
\set filename :abs_srcdir '/data/desc.data'
COPY bt_i4_heap FROM :'filename';
---END---
---START---
\set filename :abs_srcdir '/data/hash.data'
COPY bt_name_heap FROM :'filename';
---END---
---START---
\set filename :abs_srcdir '/data/desc.data'
COPY bt_txt_heap FROM :'filename';
---END---
---START---
\set filename :abs_srcdir '/data/hash.data'
COPY bt_f8_heap FROM :'filename';
---END---
---START---
ANALYZE bt_i4_heap;
---END---
---START---
ANALYZE bt_name_heap;
---END---
---START---
ANALYZE bt_txt_heap;
---END---
---START---
ANALYZE bt_f8_heap;
---END---
---START---
--
-- BTREE ascending/descending cases
--
-- we load int4/text from pure descending data (each key is a new
-- low key) and name/f8 from pure ascending data (each key is a new
-- high key).  we had a bug where new low keys would sometimes be
-- "lost".
--
CREATE INDEX bt_i4_index ON bt_i4_heap USING btree (seqno int4_ops);
---END---
---START---
CREATE INDEX bt_name_index ON bt_name_heap USING btree (seqno name_ops);
---END---
---START---
CREATE INDEX bt_txt_index ON bt_txt_heap USING btree (seqno text_ops);
---END---
---START---
CREATE INDEX bt_f8_index ON bt_f8_heap USING btree (seqno float8_ops);
---END---
---START---
--
-- test retrieval of min/max keys for each index
--

SELECT b.*
   FROM bt_i4_heap b
   WHERE b.seqno < 1;
---END---
---START---
SELECT b.*
   FROM bt_i4_heap b
   WHERE b.seqno >= 9999;
---END---
---START---
SELECT b.*
   FROM bt_i4_heap b
   WHERE b.seqno = 4500;
---END---
---START---
SELECT b.*
   FROM bt_name_heap b
   WHERE b.seqno < '1'::name;
---END---
---START---
SELECT b.*
   FROM bt_name_heap b
   WHERE b.seqno >= '9999'::name;
---END---
---START---
SELECT b.*
   FROM bt_name_heap b
   WHERE b.seqno = '4500'::name;
---END---
---START---
SELECT b.*
   FROM bt_txt_heap b
   WHERE b.seqno < '1'::text;
---END---
---START---
SELECT b.*
   FROM bt_txt_heap b
   WHERE b.seqno >= '9999'::text;
---END---
---START---
SELECT b.*
   FROM bt_txt_heap b
   WHERE b.seqno = '4500'::text;
---END---
---START---
SELECT b.*
   FROM bt_f8_heap b
   WHERE b.seqno < '1'::float8;
---END---
---START---
SELECT b.*
   FROM bt_f8_heap b
   WHERE b.seqno >= '9999'::float8;
---END---
---START---
SELECT b.*
   FROM bt_f8_heap b
   WHERE b.seqno = '4500'::float8;
---END---
---START---
--
-- Check correct optimization of LIKE (special index operator support)
-- for both indexscan and bitmapscan cases
--

set enable_seqscan to false;
---END---
---START---
set enable_indexscan to true;
---END---
---START---
set enable_bitmapscan to false;
---END---
---START---
explain (costs off)
select proname from pg_proc where proname like E'RI\\_FKey%del' order by 1;
---END---
---START---
select proname from pg_proc where proname like E'RI\\_FKey%del' order by 1;
---END---
---START---
explain (costs off)
select proname from pg_proc where proname ilike '00%foo' order by 1;
---END---
---START---
select proname from pg_proc where proname ilike '00%foo' order by 1;
---END---
---START---
explain (costs off)
select proname from pg_proc where proname ilike 'ri%foo' order by 1;
---END---
---START---
set enable_indexscan to false;
---END---
---START---
set enable_bitmapscan to true;
---END---
---START---
explain (costs off)
select proname from pg_proc where proname like E'RI\\_FKey%del' order by 1;
---END---
---START---
select proname from pg_proc where proname like E'RI\\_FKey%del' order by 1;
---END---
---START---
explain (costs off)
select proname from pg_proc where proname ilike '00%foo' order by 1;
---END---
---START---
select proname from pg_proc where proname ilike '00%foo' order by 1;
---END---
---START---
explain (costs off)
select proname from pg_proc where proname ilike 'ri%foo' order by 1;
---END---
---START---
reset enable_seqscan;
---END---
---START---
reset enable_indexscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---
-- Also check LIKE optimization with binary-compatible cases

DROP TABLE IF EXISTS btree_bpchar;

CREATE TABLE btree_bpchar (gemini_pk serial PRIMARY KEY, f1 text COLLATE "C");
---END---
---START---
create index on btree_bpchar(f1 bpchar_ops) WITH (deduplicate_items=on);
---END---
---START---
insert into btree_bpchar values ('foo'), ('fool'), ('bar'), ('quux');
---END---
---START---
-- doesn't match index:
explain (costs off)
select * from btree_bpchar where f1 like 'foo';
---END---
---START---
select * from btree_bpchar where f1 like 'foo';
---END---
---START---
explain (costs off)
select * from btree_bpchar where f1 like 'foo%';
---END---
---START---
select * from btree_bpchar where f1 like 'foo%';
---END---
---START---
-- these do match the index:
explain (costs off)
select * from btree_bpchar where f1::bpchar like 'foo';
---END---
---START---
select * from btree_bpchar where f1::bpchar like 'foo';
---END---
---START---
explain (costs off)
select * from btree_bpchar where f1::bpchar like 'foo%';
---END---
---START---
select * from btree_bpchar where f1::bpchar like 'foo%';
---END---
---START---
-- get test coverage for "single value" deduplication strategy:
insert into btree_bpchar select 'foo' from generate_series(1,1500);
---END---
---START---
CREATE TABLE dedup_unique_test_table (gemini_pk serial PRIMARY KEY, a integer) WITH (autovacuum_enabled = 'false');
---END---
---START---
CREATE UNIQUE INDEX dedup_unique ON dedup_unique_test_table (a) WITH (deduplicate_items=on);
---END---
---START---
CREATE UNIQUE INDEX plain_unique ON dedup_unique_test_table (a) WITH (deduplicate_items=off);
---END---
---START---
-- Generate enough garbage tuples in index to ensure that even the unique index
-- with deduplication enabled has to check multiple leaf pages during unique
-- checking (at least with a BLCKSZ of 8192 or less)
DO $$
BEGIN
    FOR r IN 1..1350 LOOP
        DELETE FROM dedup_unique_test_table;
        INSERT INTO dedup_unique_test_table SELECT 1;
    END LOOP;
END$$;
---END---
---START---
-- Exercise the LP_DEAD-bit-set tuple deletion code with a posting list tuple.
-- The implementation prefers deleting existing items to merging any duplicate
-- tuples into a posting list, so we need an explicit test to make sure we get
-- coverage (note that this test also assumes BLCKSZ is 8192 or less):
DROP INDEX plain_unique;
---END---
---START---
DELETE FROM dedup_unique_test_table WHERE a = 1;
---END---
---START---
INSERT INTO dedup_unique_test_table SELECT i FROM generate_series(0,450) i;
---END---
---START---
CREATE TABLE btree_tall_tbl (gemini_pk serial PRIMARY KEY, id int4, t text);
---END---
---START---
alter table btree_tall_tbl alter COLUMN t set storage plain;
---END---
---START---
create index btree_tall_idx on btree_tall_tbl (t, id) with (fillfactor = 10);
---END---
---START---
insert into btree_tall_tbl select g, repeat('x', 250)
from generate_series(1, 130) g;
---END---
---START---
CREATE TABLE delete_test_table (gemini_pk serial PRIMARY KEY, a bigint, b bigint, c bigint, d bigint);
---END---
---START---
INSERT INTO delete_test_table SELECT i, 1, 2, 3 FROM generate_series(1,80000) i;
---END---
---START---
ALTER TABLE delete_test_table ADD PRIMARY KEY (a,b,c,d);
---END---
---START---
-- Delete most entries, and vacuum, deleting internal pages and creating "fast
-- root"
DELETE FROM delete_test_table WHERE a < 79990;
---END---
---START---
VACUUM delete_test_table;
---END---
---START---
--
-- Test B-tree insertion with a metapage update (XLOG_BTREE_INSERT_META
-- WAL record type). This happens when a "fast root" page is split.  This
-- also creates coverage for nbtree FSM page recycling.
--
-- The vacuum above should've turned the leaf page into a fast root. We just
-- need to insert some rows to cause the fast root page to split.
INSERT INTO delete_test_table SELECT i, 1, 2, 3 FROM generate_series(1,1000) i;
---END---
---START---
-- Test unsupported btree opclass parameters
create index on btree_tall_tbl (id int4_ops(foo=1));
---END---
---START---
-- Test case of ALTER INDEX with abuse of column names for indexes.
-- This grammar is not officially supported, but the parser allows it.
CREATE INDEX btree_tall_idx2 ON btree_tall_tbl (id);
---END---
---START---
ALTER INDEX btree_tall_idx2 ALTER COLUMN id SET (n_distinct=100);
---END---
---START---
DROP INDEX btree_tall_idx2;
---END---
---START---
CREATE TABLE btree_part (gemini_pk serial PRIMARY KEY, id int4) PARTITION BY range (id);
---END---
---START---
CREATE INDEX btree_part_idx ON btree_part(id);
---END---
---START---
ALTER INDEX btree_part_idx ALTER COLUMN id SET (n_distinct=100);
---END---
---START---
DROP TABLE btree_part;
---END---
