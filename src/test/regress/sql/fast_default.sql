---START---
--
-- ALTER TABLE ADD COLUMN DEFAULT test
--

SET search_path = fast_default;
---END---
---START---
CREATE SCHEMA fast_default;
---END---
---START---
CREATE TABLE m (_gemini_pk serial PRIMARY KEY, id oid);
---END---
---START---
INSERT INTO m VALUES (NULL::OID);
---END---
---START---
CREATE FUNCTION set(tabname name) RETURNS VOID
AS $$
BEGIN
  UPDATE m
  SET id = (SELECT c.relfilenode
            FROM pg_class AS c, pg_namespace AS s
            WHERE c.relname = tabname
                AND c.relnamespace = s.oid
                AND s.nspname = 'fast_default');
END;
$$ LANGUAGE 'plpgsql';
---END---
---START---
CREATE FUNCTION comp() RETURNS TEXT
AS $$
BEGIN
  RETURN (SELECT CASE
               WHEN m.id = c.relfilenode THEN 'Unchanged'
               ELSE 'Rewritten'
               END
           FROM m, pg_class AS c, pg_namespace AS s
           WHERE c.relname = 't'
               AND c.relnamespace = s.oid
               AND s.nspname = 'fast_default');
END;
$$ LANGUAGE 'plpgsql';
---END---
---START---
CREATE FUNCTION log_rewrite() RETURNS event_trigger
LANGUAGE plpgsql as
$func$

declare
   this_schema text;
begin
    select into this_schema relnamespace::regnamespace::text
    from pg_class
    where oid = pg_event_trigger_table_rewrite_oid();
    if this_schema = 'fast_default'
    then
        RAISE NOTICE 'rewriting table % for reason %',
          pg_event_trigger_table_rewrite_oid()::regclass,
          pg_event_trigger_table_rewrite_reason();
    end if;
end;
$func$;
---END---
---START---
CREATE TABLE has_volatile AS
SELECT * FROM generate_series(1,10) id;
---END---
---START---
CREATE EVENT TRIGGER has_volatile_rewrite
                  ON table_rewrite
   EXECUTE PROCEDURE log_rewrite();
---END---
---START---
-- only the last of these should trigger a rewrite
ALTER TABLE has_volatile ADD col1 int;
---END---
---START---
ALTER TABLE has_volatile ADD col2 int DEFAULT 1;
---END---
---START---
ALTER TABLE has_volatile ADD col3 timestamptz DEFAULT current_timestamp;
---END---
---START---
ALTER TABLE has_volatile ADD col4 int DEFAULT (random() * 10000)::int;
---END---
---START---
-- Test a large sample of different datatypes
CREATE TABLE T(pk INT NOT NULL PRIMARY KEY, c_int INT DEFAULT 1);
---END---
---START---
SELECT set('t');
---END---
---START---
INSERT INTO T VALUES (1), (2);
---END---
---START---
ALTER TABLE T ADD COLUMN c_bpchar BPCHAR(5) DEFAULT 'hello',
              ALTER COLUMN c_int SET DEFAULT 2;
---END---
---START---
INSERT INTO T VALUES (3), (4);
---END---
---START---
ALTER TABLE T ADD COLUMN c_text TEXT  DEFAULT 'world',
              ALTER COLUMN c_bpchar SET DEFAULT 'dog';
---END---
---START---
INSERT INTO T VALUES (5), (6);
---END---
---START---
ALTER TABLE T ADD COLUMN c_date DATE DEFAULT '2016-06-02',
              ALTER COLUMN c_text SET DEFAULT 'cat';
---END---
---START---
INSERT INTO T VALUES (7), (8);
---END---
---START---
ALTER TABLE T ADD COLUMN c_timestamp TIMESTAMP DEFAULT '2016-09-01 12:00:00',
              ADD COLUMN c_timestamp_null TIMESTAMP,
              ALTER COLUMN c_date SET DEFAULT '2010-01-01';
---END---
---START---
INSERT INTO T VALUES (9), (10);
---END---
---START---
ALTER TABLE T ADD COLUMN c_array TEXT[]
                  DEFAULT '{"This", "is", "the", "real", "world"}',
              ALTER COLUMN c_timestamp SET DEFAULT '1970-12-31 11:12:13',
              ALTER COLUMN c_timestamp_null SET DEFAULT '2016-09-29 12:00:00';
---END---
---START---
INSERT INTO T VALUES (11), (12);
---END---
---START---
ALTER TABLE T ADD COLUMN c_small SMALLINT DEFAULT -5,
              ADD COLUMN c_small_null SMALLINT,
              ALTER COLUMN c_array
                  SET DEFAULT '{"This", "is", "no", "fantasy"}';
---END---
---START---
INSERT INTO T VALUES (13), (14);
---END---
---START---
ALTER TABLE T ADD COLUMN c_big BIGINT DEFAULT 180000000000018,
              ALTER COLUMN c_small SET DEFAULT 9,
              ALTER COLUMN c_small_null SET DEFAULT 13;
---END---
---START---
INSERT INTO T VALUES (15), (16);
---END---
---START---
ALTER TABLE T ADD COLUMN c_num NUMERIC DEFAULT 1.00000000001,
              ALTER COLUMN c_big SET DEFAULT -9999999999999999;
---END---
---START---
INSERT INTO T VALUES (17), (18);
---END---
---START---
ALTER TABLE T ADD COLUMN c_time TIME DEFAULT '12:00:00',
              ALTER COLUMN c_num SET DEFAULT 2.000000000000002;
---END---
---START---
INSERT INTO T VALUES (19), (20);
---END---
---START---
ALTER TABLE T ADD COLUMN c_interval INTERVAL DEFAULT '1 day',
              ALTER COLUMN c_time SET DEFAULT '23:59:59';
---END---
---START---
INSERT INTO T VALUES (21), (22);
---END---
---START---
ALTER TABLE T ADD COLUMN c_hugetext TEXT DEFAULT repeat('abcdefg',1000),
              ALTER COLUMN c_interval SET DEFAULT '3 hours';
---END---
---START---
INSERT INTO T VALUES (23), (24);
---END---
---START---
ALTER TABLE T ALTER COLUMN c_interval DROP DEFAULT,
              ALTER COLUMN c_hugetext SET DEFAULT repeat('poiuyt', 1000);
---END---
---START---
INSERT INTO T VALUES (25), (26);
---END---
---START---
ALTER TABLE T ALTER COLUMN c_bpchar    DROP DEFAULT,
              ALTER COLUMN c_date      DROP DEFAULT,
              ALTER COLUMN c_text      DROP DEFAULT,
              ALTER COLUMN c_timestamp DROP DEFAULT,
              ALTER COLUMN c_array     DROP DEFAULT,
              ALTER COLUMN c_small     DROP DEFAULT,
              ALTER COLUMN c_big       DROP DEFAULT,
              ALTER COLUMN c_num       DROP DEFAULT,
              ALTER COLUMN c_time      DROP DEFAULT,
              ALTER COLUMN c_hugetext  DROP DEFAULT;
---END---
---START---
INSERT INTO T VALUES (27), (28);
---END---
---START---
SELECT pk, c_int, c_bpchar, c_text, c_date, c_timestamp,
       c_timestamp_null, c_array, c_small, c_small_null,
       c_big, c_num, c_time, c_interval,
       c_hugetext = repeat('abcdefg',1000) as c_hugetext_origdef,
       c_hugetext = repeat('poiuyt', 1000) as c_hugetext_newdef
FROM T ORDER BY pk;
---END---
---START---
SELECT comp();
---END---
---START---
DROP TABLE T;
---END---
---START---
-- Test expressions in the defaults
CREATE OR REPLACE FUNCTION foo(a INT) RETURNS TEXT AS $$
DECLARE res TEXT := '';
        i INT;
BEGIN
  i := 0;
  WHILE (i < a) LOOP
    res := res || chr(ascii('a') + i);
    i := i + 1;
  END LOOP;
  RETURN res;
END; $$ LANGUAGE PLPGSQL STABLE;
---END---
---START---
CREATE TABLE T(pk INT NOT NULL PRIMARY KEY, c_int INT DEFAULT LENGTH(foo(6)));
---END---
---START---
SELECT set('t');
---END---
---START---
INSERT INTO T VALUES (1), (2);
---END---
---START---
ALTER TABLE T ADD COLUMN c_bpchar BPCHAR(5) DEFAULT foo(4),
              ALTER COLUMN c_int SET DEFAULT LENGTH(foo(8));
---END---
---START---
INSERT INTO T VALUES (3), (4);
---END---
---START---
ALTER TABLE T ADD COLUMN c_text TEXT  DEFAULT foo(6),
              ALTER COLUMN c_bpchar SET DEFAULT foo(3);
---END---
---START---
INSERT INTO T VALUES (5), (6);
---END---
---START---
ALTER TABLE T ADD COLUMN c_date DATE
                  DEFAULT '2016-06-02'::DATE  + LENGTH(foo(10)),
              ALTER COLUMN c_text SET DEFAULT foo(12);
---END---
---START---
INSERT INTO T VALUES (7), (8);
---END---
---START---
ALTER TABLE T ADD COLUMN c_timestamp TIMESTAMP
                  DEFAULT '2016-09-01'::DATE + LENGTH(foo(10)),
              ALTER COLUMN c_date
                  SET DEFAULT '2010-01-01'::DATE - LENGTH(foo(4));
---END---
---START---
INSERT INTO T VALUES (9), (10);
---END---
---START---
ALTER TABLE T ADD COLUMN c_array TEXT[]
                  DEFAULT ('{"This", "is", "' || foo(4) ||
                           '","the", "real", "world"}')::TEXT[],
              ALTER COLUMN c_timestamp
                  SET DEFAULT '1970-12-31'::DATE + LENGTH(foo(30));
---END---
---START---
INSERT INTO T VALUES (11), (12);
---END---
---START---
ALTER TABLE T ALTER COLUMN c_int DROP DEFAULT,
              ALTER COLUMN c_array
                  SET DEFAULT ('{"This", "is", "' || foo(1) ||
                               '", "fantasy"}')::text[];
---END---
---START---
INSERT INTO T VALUES (13), (14);
---END---
---START---
ALTER TABLE T ALTER COLUMN c_bpchar    DROP DEFAULT,
              ALTER COLUMN c_date      DROP DEFAULT,
              ALTER COLUMN c_text      DROP DEFAULT,
              ALTER COLUMN c_timestamp DROP DEFAULT,
              ALTER COLUMN c_array     DROP DEFAULT;
---END---
---START---
INSERT INTO T VALUES (15), (16);
---END---
---START---
SELECT * FROM T;
---END---
---START---
SELECT comp();
---END---
---START---
DROP TABLE T;
---END---
---START---
DROP FUNCTION foo(INT);
---END---
---START---
-- Fall back to full rewrite for volatile expressions
CREATE TABLE T(pk INT NOT NULL PRIMARY KEY);
---END---
---START---
INSERT INTO T VALUES (1);
---END---
---START---
SELECT set('t');
---END---
---START---
-- now() is stable, because it returns the transaction timestamp
ALTER TABLE T ADD COLUMN c1 TIMESTAMP DEFAULT now();
---END---
---START---
SELECT comp();
---END---
---START---
-- clock_timestamp() is volatile
ALTER TABLE T ADD COLUMN c2 TIMESTAMP DEFAULT clock_timestamp();
---END---
---START---
SELECT comp();
---END---
---START---
DROP TABLE T;
---END---
---START---
-- Simple querie
CREATE TABLE T (pk INT NOT NULL PRIMARY KEY);
---END---
---START---
SELECT set('t');
---END---
---START---
INSERT INTO T SELECT * FROM generate_series(1, 10) a;
---END---
---START---
ALTER TABLE T ADD COLUMN c_bigint BIGINT NOT NULL DEFAULT -1;
---END---
---START---
INSERT INTO T SELECT b, b - 10 FROM generate_series(11, 20) a(b);
---END---
---START---
ALTER TABLE T ADD COLUMN c_text TEXT DEFAULT 'hello';
---END---
---START---
INSERT INTO T SELECT b, b - 10, (b + 10)::text FROM generate_series(21, 30) a(b);
---END---
---START---
-- WHERE clause
SELECT c_bigint, c_text FROM T WHERE c_bigint = -1 LIMIT 1;
---END---
---START---
EXPLAIN (VERBOSE TRUE, COSTS FALSE)
SELECT c_bigint, c_text FROM T WHERE c_bigint = -1 LIMIT 1;
---END---
---START---
SELECT c_bigint, c_text FROM T WHERE c_text = 'hello' LIMIT 1;
---END---
---START---
EXPLAIN (VERBOSE TRUE, COSTS FALSE) SELECT c_bigint, c_text FROM T WHERE c_text = 'hello' LIMIT 1;
---END---
---START---
-- COALESCE
SELECT COALESCE(c_bigint, pk), COALESCE(c_text, pk::text)
FROM T
ORDER BY pk LIMIT 10;
---END---
---START---
-- Aggregate function
SELECT SUM(c_bigint), MAX(c_text COLLATE "C" ), MIN(c_text COLLATE "C") FROM T;
---END---
---START---
-- ORDER BY
SELECT * FROM T ORDER BY c_bigint, c_text, pk LIMIT 10;
---END---
---START---
EXPLAIN (VERBOSE TRUE, COSTS FALSE)
SELECT * FROM T ORDER BY c_bigint, c_text, pk LIMIT 10;
---END---
---START---
-- LIMIT
SELECT * FROM T WHERE c_bigint > -1 ORDER BY c_bigint, c_text, pk LIMIT 10;
---END---
---START---
EXPLAIN (VERBOSE TRUE, COSTS FALSE)
SELECT * FROM T WHERE c_bigint > -1 ORDER BY c_bigint, c_text, pk LIMIT 10;
---END---
---START---
--  DELETE with RETURNING
DELETE FROM T WHERE pk BETWEEN 10 AND 20 RETURNING *;
---END---
---START---
EXPLAIN (VERBOSE TRUE, COSTS FALSE)
DELETE FROM T WHERE pk BETWEEN 10 AND 20 RETURNING *;
---END---
---START---
-- UPDATE
UPDATE T SET c_text = '"' || c_text || '"'  WHERE pk < 10;
---END---
---START---
SELECT * FROM T WHERE c_text LIKE '"%"' ORDER BY PK;
---END---
---START---
SELECT comp();
---END---
---START---
DROP TABLE T;
---END---
---START---
-- Combine with other DDL
CREATE TABLE T(pk INT NOT NULL PRIMARY KEY);
---END---
---START---
SELECT set('t');
---END---
---START---
INSERT INTO T VALUES (1), (2);
---END---
---START---
ALTER TABLE T ADD COLUMN c_int INT NOT NULL DEFAULT -1;
---END---
---START---
INSERT INTO T VALUES (3), (4);
---END---
---START---
ALTER TABLE T ADD COLUMN c_text TEXT DEFAULT 'Hello';
---END---
---START---
INSERT INTO T VALUES (5), (6);
---END---
---START---
ALTER TABLE T ALTER COLUMN c_text SET DEFAULT 'world',
              ALTER COLUMN c_int  SET DEFAULT 1;
---END---
---START---
INSERT INTO T VALUES (7), (8);
---END---
---START---
SELECT * FROM T ORDER BY pk;
---END---
---START---
-- Add an index
CREATE INDEX i ON T(c_int, c_text);
---END---
---START---
SELECT c_text FROM T WHERE c_int = -1;
---END---
---START---
SELECT comp();
---END---
---START---
-- query to exercise expand_tuple function
CREATE TABLE t1 AS
SELECT 1::int AS a , 2::int AS b
FROM generate_series(1,20) q;
---END---
---START---
ALTER TABLE t1 ADD COLUMN c text;
---END---
---START---
SELECT a,
       stddev(cast((SELECT sum(1) FROM generate_series(1,20) x) AS float4))
          OVER (PARTITION BY a,b,c ORDER BY b)
       AS z
FROM t1;
---END---
---START---
DROP TABLE T;
---END---
---START---
-- test that we account for missing columns without defaults correctly
-- in expand_tuple, and that rows are correctly expanded for triggers

CREATE FUNCTION test_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$

begin
    raise notice 'old tuple: %', to_json(OLD)::text;
    if TG_OP = 'DELETE'
    then
       return OLD;
    else
       return NEW;
    end if;
end;

$$;
---END---
---START---
-- 2 new columns, both have defaults
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,3);
---END---
---START---
ALTER TABLE t ADD COLUMN x int NOT NULL DEFAULT 4;
---END---
---START---
ALTER TABLE t ADD COLUMN y int NOT NULL DEFAULT 5;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- 2 new columns, first has default
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,3);
---END---
---START---
ALTER TABLE t ADD COLUMN x int NOT NULL DEFAULT 4;
---END---
---START---
ALTER TABLE t ADD COLUMN y int;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- 2 new columns, second has default
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,3);
---END---
---START---
ALTER TABLE t ADD COLUMN x int;
---END---
---START---
ALTER TABLE t ADD COLUMN y int NOT NULL DEFAULT 5;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- 2 new columns, neither has default
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,3);
---END---
---START---
ALTER TABLE t ADD COLUMN x int;
---END---
---START---
ALTER TABLE t ADD COLUMN y int;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- same as last 4 tests but here the last original column has a NULL value
-- 2 new columns, both have defaults
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,NULL);
---END---
---START---
ALTER TABLE t ADD COLUMN x int NOT NULL DEFAULT 4;
---END---
---START---
ALTER TABLE t ADD COLUMN y int NOT NULL DEFAULT 5;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- 2 new columns, first has default
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,NULL);
---END---
---START---
ALTER TABLE t ADD COLUMN x int NOT NULL DEFAULT 4;
---END---
---START---
ALTER TABLE t ADD COLUMN y int;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- 2 new columns, second has default
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,NULL);
---END---
---START---
ALTER TABLE t ADD COLUMN x int;
---END---
---START---
ALTER TABLE t ADD COLUMN y int NOT NULL DEFAULT 5;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- 2 new columns, neither has default
CREATE TABLE t (id serial PRIMARY KEY, a int, b int, c int);
---END---
---START---
INSERT INTO t (a,b,c) VALUES (1,2,NULL);
---END---
---START---
ALTER TABLE t ADD COLUMN x int;
---END---
---START---
ALTER TABLE t ADD COLUMN y int;
---END---
---START---
CREATE TRIGGER a BEFORE UPDATE ON t FOR EACH ROW EXECUTE PROCEDURE test_trigger();
---END---
---START---
SELECT * FROM t;
---END---
---START---
UPDATE t SET y = 2;
---END---
---START---
SELECT * FROM t;
---END---
---START---
DROP TABLE t;
---END---
---START---
-- make sure expanded tuple has correct self pointer
-- it will be required by the RI trigger doing the cascading delete

CREATE TABLE leader (a int PRIMARY KEY, b int);
---END---
---START---
CREATE TABLE follower (_gemini_pk serial PRIMARY KEY, a integer REFERENCES leader ON DELETE CASCADE, b integer);
---END---
---START---
INSERT INTO leader VALUES (1, 1), (2, 2);
---END---
---START---
ALTER TABLE leader ADD c int;
---END---
---START---
ALTER TABLE leader DROP c;
---END---
---START---
DELETE FROM leader;
---END---
---START---
CREATE TABLE vtype (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO vtype VALUES (1);
---END---
---START---
ALTER TABLE vtype ADD COLUMN b DOUBLE PRECISION DEFAULT 0.2;
---END---
---START---
ALTER TABLE vtype ADD COLUMN c BOOLEAN DEFAULT true;
---END---
---START---
SELECT * FROM vtype;
---END---
---START---
ALTER TABLE vtype
      ALTER b TYPE text USING b::text,
      ALTER c TYPE text USING c::text;
---END---
---START---
SELECT * FROM vtype;
---END---
---START---
CREATE TABLE vtype2 (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO vtype2 VALUES (1);
---END---
---START---
ALTER TABLE vtype2 ADD COLUMN b varchar(10) DEFAULT 'xxx';
---END---
---START---
ALTER TABLE vtype2 ALTER COLUMN b SET DEFAULT 'yyy';
---END---
---START---
INSERT INTO vtype2 VALUES (2);
---END---
---START---
ALTER TABLE vtype2 ALTER COLUMN b TYPE varchar(20) USING b::varchar(20);
---END---
---START---
SELECT * FROM vtype2;
---END---
---START---
-- Ensure that defaults are checked when evaluating whether HOT update
-- is possible, this was broken for a while:
-- https://postgr.es/m/20190202133521.ylauh3ckqa7colzj%40alap3.anarazel.de
BEGIN;
---END---
---START---
CREATE TABLE t (_gemini_pk serial PRIMARY KEY);
---END---
---START---
INSERT INTO t DEFAULT VALUES;
---END---
---START---
ALTER TABLE t ADD COLUMN a int DEFAULT 1;
---END---
---START---
CREATE INDEX ON t(a);
---END---
---START---
-- set column with a default 1 to NULL, due to a bug that wasn't
-- noticed has heap_getattr buggily returned NULL for default columns
UPDATE t SET a = NULL;
---END---
---START---
-- verify that index and non-index scans show the same result
SET LOCAL enable_seqscan = true;
---END---
---START---
SELECT * FROM t WHERE a IS NULL;
---END---
---START---
SET LOCAL enable_seqscan = false;
---END---
---START---
SELECT * FROM t WHERE a IS NULL;
---END---
---START---
ROLLBACK;
---END---
---START---
-- verify that a default set on a non-plain table doesn't set a missing
-- value on the attribute
CREATE FOREIGN DATA WRAPPER dummy;
---END---
---START---
CREATE SERVER s0 FOREIGN DATA WRAPPER dummy;
---END---
---START---
CREATE FOREIGN TABLE ft1 (c1 integer NOT NULL) SERVER s0;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c8 integer DEFAULT 0;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 TYPE char(10);
---END---
---START---
SELECT count(*)
  FROM pg_attribute
  WHERE attrelid = 'ft1'::regclass AND
    (attmissingval IS NOT NULL OR atthasmissing);
---END---
---START---
-- cleanup
DROP FOREIGN TABLE ft1;
---END---
---START---
DROP SERVER s0;
---END---
---START---
DROP FOREIGN DATA WRAPPER dummy;
---END---
---START---
DROP TABLE vtype;
---END---
---START---
DROP TABLE vtype2;
---END---
---START---
DROP TABLE follower;
---END---
---START---
DROP TABLE leader;
---END---
---START---
DROP FUNCTION test_trigger();
---END---
---START---
DROP TABLE t1;
---END---
---START---
DROP FUNCTION set(name);
---END---
---START---
DROP FUNCTION comp();
---END---
---START---
DROP TABLE m;
---END---
---START---
DROP TABLE has_volatile;
---END---
---START---
DROP EVENT TRIGGER has_volatile_rewrite;
---END---
---START---
DROP FUNCTION log_rewrite;
---END---
---START---
DROP SCHEMA fast_default;
---END---
---START---
-- Leave a table with an active fast default in place, for pg_upgrade testing
set search_path = public;
---END---
---START---
CREATE TABLE has_fast_default (_gemini_pk serial PRIMARY KEY, f1 integer);
---END---
---START---
insert into has_fast_default values(1);
---END---
---START---
alter table has_fast_default add column f2 int default 42;
---END---
---START---
table has_fast_default;
---END---
