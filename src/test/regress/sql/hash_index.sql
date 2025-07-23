---START---
--
-- HASH_INDEX
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

CREATE TABLE hash_i4_heap (
	seqno 		int4,
	random 		int4
);
---END---
---START---

CREATE TABLE hash_name_heap (
	seqno 		int4,
	random 		name
);
---END---
---START---

CREATE TABLE hash_txt_heap (
	seqno 		int4,
	random 		text
);
---END---
---START---

CREATE TABLE hash_f8_heap (
	seqno		int4,
	random 		float8
);
---END---
---START---

\set filename :abs_srcdir '/data/hash.data'
COPY hash_i4_heap FROM :'filename';
---END---
---START---
COPY hash_name_heap FROM :'filename';
---END---
---START---
COPY hash_txt_heap FROM :'filename';
---END---
---START---
COPY hash_f8_heap FROM :'filename';
---END---
---START---

-- the data in this file has a lot of duplicates in the index key
-- fields, leading to long bucket chains and lots of table expansion.
-- this is therefore a stress test of the bucket overflow code (unlike
-- the data in hash.data, which has unique index keys).
--
-- \set filename :abs_srcdir '/data/hashovfl.data'
-- COPY hash_ovfl_heap FROM :'filename';
---END---
---START---

ANALYZE hash_i4_heap;
---END---
---START---
ANALYZE hash_name_heap;
---END---
---START---
ANALYZE hash_txt_heap;
---END---
---START---
ANALYZE hash_f8_heap;
---END---
---START---

CREATE INDEX hash_i4_index ON hash_i4_heap USING hash (random int4_ops);
---END---
---START---

CREATE INDEX hash_name_index ON hash_name_heap USING hash (random name_ops);
---END---
---START---

CREATE INDEX hash_txt_index ON hash_txt_heap USING hash (random text_ops);
---END---
---START---

CREATE INDEX hash_f8_index ON hash_f8_heap USING hash (random float8_ops)
  WITH (fillfactor=60);
---END---
---START---

--
-- Also try building functional, expressional, and partial indexes on
-- tables that already contain data.
--
create unique index hash_f8_index_1 on hash_f8_heap(abs(random));
---END---
---START---
create unique index hash_f8_index_2 on hash_f8_heap((seqno + 1), random);
---END---
---START---
create unique index hash_f8_index_3 on hash_f8_heap(random) where seqno > 1000;
---END---
---START---

--
-- hash index
-- grep 843938989 hash.data
--
SELECT * FROM hash_i4_heap
   WHERE hash_i4_heap.random = 843938989;
---END---
---START---

--
-- hash index
-- grep 66766766 hash.data
--
SELECT * FROM hash_i4_heap
   WHERE hash_i4_heap.random = 66766766;
---END---
---START---

--
-- hash index
-- grep 1505703298 hash.data
--
SELECT * FROM hash_name_heap
   WHERE hash_name_heap.random = '1505703298'::name;
---END---
---START---

--
-- hash index
-- grep 7777777 hash.data
--
SELECT * FROM hash_name_heap
   WHERE hash_name_heap.random = '7777777'::name;
---END---
---START---

--
-- hash index
-- grep 1351610853 hash.data
--
SELECT * FROM hash_txt_heap
   WHERE hash_txt_heap.random = '1351610853'::text;
---END---
---START---

--
-- hash index
-- grep 111111112222222233333333 hash.data
--
SELECT * FROM hash_txt_heap
   WHERE hash_txt_heap.random = '111111112222222233333333'::text;
---END---
---START---

--
-- hash index
-- grep 444705537 hash.data
--
SELECT * FROM hash_f8_heap
   WHERE hash_f8_heap.random = '444705537'::float8;
---END---
---START---

--
-- hash index
-- grep 88888888 hash.data
--
SELECT * FROM hash_f8_heap
   WHERE hash_f8_heap.random = '88888888'::float8;
---END---
---START---

--
-- hash index
-- grep '^90[^0-9]' hashovfl.data
--
-- SELECT count(*) AS i988 FROM hash_ovfl_heap
--    WHERE x = 90;
---END---
---START---

--
-- hash index
-- grep '^1000[^0-9]' hashovfl.data
--
-- SELECT count(*) AS i0 FROM hash_ovfl_heap
--    WHERE x = 1000;
---END---
---START---

--
-- HASH
--
UPDATE hash_i4_heap
   SET random = 1
   WHERE hash_i4_heap.seqno = 1492;
---END---
---START---

SELECT h.seqno AS i1492, h.random AS i1
   FROM hash_i4_heap h
   WHERE h.random = 1;
---END---
---START---

UPDATE hash_i4_heap
   SET seqno = 20000
   WHERE hash_i4_heap.random = 1492795354;
---END---
---START---

SELECT h.seqno AS i20000
   FROM hash_i4_heap h
   WHERE h.random = 1492795354;
---END---
---START---

UPDATE hash_name_heap
   SET random = '0123456789abcdef'::name
   WHERE hash_name_heap.seqno = 6543;
---END---
---START---

SELECT h.seqno AS i6543, h.random AS c0_to_f
   FROM hash_name_heap h
   WHERE h.random = '0123456789abcdef'::name;
---END---
---START---

UPDATE hash_name_heap
   SET seqno = 20000
   WHERE hash_name_heap.random = '76652222'::name;
---END---
---START---

--
-- this is the row we just replaced; index scan should return zero rows
--
SELECT h.seqno AS emptyset
   FROM hash_name_heap h
   WHERE h.random = '76652222'::name;
---END---
---START---

UPDATE hash_txt_heap
   SET random = '0123456789abcdefghijklmnop'::text
   WHERE hash_txt_heap.seqno = 4002;
---END---
---START---

SELECT h.seqno AS i4002, h.random AS c0_to_p
   FROM hash_txt_heap h
   WHERE h.random = '0123456789abcdefghijklmnop'::text;
---END---
---START---

UPDATE hash_txt_heap
   SET seqno = 20000
   WHERE hash_txt_heap.random = '959363399'::text;
---END---
---START---

SELECT h.seqno AS t20000
   FROM hash_txt_heap h
   WHERE h.random = '959363399'::text;
---END---
---START---

UPDATE hash_f8_heap
   SET random = '-1234.1234'::float8
   WHERE hash_f8_heap.seqno = 8906;
---END---
---START---

SELECT h.seqno AS i8096, h.random AS f1234_1234
   FROM hash_f8_heap h
   WHERE h.random = '-1234.1234'::float8;
---END---
---START---

UPDATE hash_f8_heap
   SET seqno = 20000
   WHERE hash_f8_heap.random = '488912369'::float8;
---END---
---START---

SELECT h.seqno AS f20000
   FROM hash_f8_heap h
   WHERE h.random = '488912369'::float8;
---END---
---START---

-- UPDATE hash_ovfl_heap
--    SET x = 1000
--   WHERE x = 90;
---END---
---START---

-- this vacuums the index as well
-- VACUUM hash_ovfl_heap;
---END---
---START---

-- SELECT count(*) AS i0 FROM hash_ovfl_heap
--   WHERE x = 90;
---END---
---START---

-- SELECT count(*) AS i988 FROM hash_ovfl_heap
--  WHERE x = 1000;
---END---
---START---

--
-- Cause some overflow insert and splits.
--
CREATE TABLE hash_split_heap (keycol INT);
---END---
---START---
INSERT INTO hash_split_heap SELECT 1 FROM generate_series(1, 500) a;
---END---
---START---
CREATE INDEX hash_split_index on hash_split_heap USING HASH (keycol);
---END---
---START---
INSERT INTO hash_split_heap SELECT 1 FROM generate_series(1, 5000) a;
---END---
---START---

-- Let's do a backward scan.
BEGIN;
---END---
---START---
SET enable_seqscan = OFF;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---

DECLARE c CURSOR FOR SELECT * from hash_split_heap WHERE keycol = 1;
---END---
---START---
MOVE FORWARD ALL FROM c;
---END---
---START---
MOVE BACKWARD 10000 FROM c;
---END---
---START---
MOVE BACKWARD ALL FROM c;
---END---
---START---
CLOSE c;
---END---
---START---
END;
---END---
---START---

-- DELETE, INSERT, VACUUM.
DELETE FROM hash_split_heap WHERE keycol = 1;
---END---
---START---
INSERT INTO hash_split_heap SELECT a/2 FROM generate_series(1, 25000) a;
---END---
---START---

VACUUM hash_split_heap;
---END---
---START---

-- Rebuild the index using a different fillfactor
ALTER INDEX hash_split_index SET (fillfactor = 10);
---END---
---START---
REINDEX INDEX hash_split_index;
---END---
---START---

-- Clean up.
DROP TABLE hash_split_heap;
---END---
---START---

-- Index on temp table.
CREATE TEMP TABLE hash_temp_heap (x int, y int);
---END---
---START---
INSERT INTO hash_temp_heap VALUES (1,1);
---END---
---START---
CREATE INDEX hash_idx ON hash_temp_heap USING hash (x);
---END---
---START---
DROP TABLE hash_temp_heap CASCADE;
---END---
---START---

-- Float4 type.
CREATE TABLE hash_heap_float4 (x float4, y int);
---END---
---START---
INSERT INTO hash_heap_float4 VALUES (1.1,1);
---END---
---START---
CREATE INDEX hash_idx ON hash_heap_float4 USING hash (x);
---END---
---START---
DROP TABLE hash_heap_float4 CASCADE;
---END---
---START---

-- Test out-of-range fillfactor values
CREATE INDEX hash_f8_index2 ON hash_f8_heap USING hash (random float8_ops)
	WITH (fillfactor=9);
---END---
---START---
CREATE INDEX hash_f8_index2 ON hash_f8_heap USING hash (random float8_ops)
	WITH (fillfactor=101);
---END---
