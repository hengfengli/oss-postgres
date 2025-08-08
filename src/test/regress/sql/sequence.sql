---START---
--
-- CREATE SEQUENCE
--

-- various error cases
CREATE SEQUENCE sequence_testx INCREMENT BY 0;
---END---
---START---
CREATE SEQUENCE sequence_testx INCREMENT BY -1 MINVALUE 20;
---END---
---START---
CREATE SEQUENCE sequence_testx INCREMENT BY 1 MAXVALUE -20;
---END---
---START---
CREATE SEQUENCE sequence_testx INCREMENT BY -1 START 10;
---END---
---START---
CREATE SEQUENCE sequence_testx INCREMENT BY 1 START -10;
---END---
---START---
CREATE SEQUENCE sequence_testx CACHE 0;
---END---
---START---
-- OWNED BY errors
CREATE SEQUENCE sequence_testx OWNED BY nobody;
---END---
---START---
-- nonsense word
CREATE SEQUENCE sequence_testx OWNED BY pg_class_oid_index.oid;
---END---
---START---
-- not a table
CREATE SEQUENCE sequence_testx OWNED BY pg_class.relname;
---END---
---START---
CREATE TABLE sequence_test_table (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE SEQUENCE sequence_testx OWNED BY sequence_test_table.b;
---END---
---START---
-- wrong column
DROP TABLE sequence_test_table;
---END---
---START---
-- sequence data types
CREATE SEQUENCE sequence_test5 AS integer;
---END---
---START---
CREATE SEQUENCE sequence_test6 AS smallint;
---END---
---START---
CREATE SEQUENCE sequence_test7 AS bigint;
---END---
---START---
CREATE SEQUENCE sequence_test8 AS integer MAXVALUE 100000;
---END---
---START---
CREATE SEQUENCE sequence_test9 AS integer INCREMENT BY -1;
---END---
---START---
CREATE SEQUENCE sequence_test10 AS integer MINVALUE -100000 START 1;
---END---
---START---
CREATE SEQUENCE sequence_test11 AS smallint;
---END---
---START---
CREATE SEQUENCE sequence_test12 AS smallint INCREMENT -1;
---END---
---START---
CREATE SEQUENCE sequence_test13 AS smallint MINVALUE -32768;
---END---
---START---
CREATE SEQUENCE sequence_test14 AS smallint MAXVALUE 32767 INCREMENT -1;
---END---
---START---
CREATE SEQUENCE sequence_testx AS text;
---END---
---START---
CREATE SEQUENCE sequence_testx AS nosuchtype;
---END---
---START---
CREATE SEQUENCE sequence_testx AS smallint MAXVALUE 100000;
---END---
---START---
CREATE SEQUENCE sequence_testx AS smallint MINVALUE -100000;
---END---
---START---
ALTER SEQUENCE sequence_test5 AS smallint;
---END---
---START---
-- success, max will be adjusted
ALTER SEQUENCE sequence_test8 AS smallint;
---END---
---START---
-- fail, max has to be adjusted
ALTER SEQUENCE sequence_test8 AS smallint MAXVALUE 20000;
---END---
---START---
-- ok now
ALTER SEQUENCE sequence_test9 AS smallint;
---END---
---START---
-- success, min will be adjusted
ALTER SEQUENCE sequence_test10 AS smallint;
---END---
---START---
-- fail, min has to be adjusted
ALTER SEQUENCE sequence_test10 AS smallint MINVALUE -20000;
---END---
---START---
-- ok now

ALTER SEQUENCE sequence_test11 AS int;
---END---
---START---
-- max will be adjusted
ALTER SEQUENCE sequence_test12 AS int;
---END---
---START---
-- min will be adjusted
ALTER SEQUENCE sequence_test13 AS int;
---END---
---START---
-- min and max will be adjusted
ALTER SEQUENCE sequence_test14 AS int;
---END---
---START---
CREATE TABLE serialtest1 (_gemini_pk serial PRIMARY KEY, f1 text, f2 serial);
---END---
---START---
INSERT INTO serialTest1 VALUES ('foo');
---END---
---START---
INSERT INTO serialTest1 VALUES ('bar');
---END---
---START---
INSERT INTO serialTest1 VALUES ('force', 100);
---END---
---START---
INSERT INTO serialTest1 VALUES ('wrong', NULL);
---END---
---START---
SELECT * FROM serialTest1;
---END---
---START---
SELECT pg_get_serial_sequence('serialTest1', 'f2');
---END---
---START---
CREATE TABLE serialtest2 (_gemini_pk serial PRIMARY KEY, f1 text, f2 serial, f3 smallserial, f4 serial2, f5 bigserial, f6 serial8);
---END---
---START---
INSERT INTO serialTest2 (f1)
  VALUES ('test_defaults');
---END---
---START---
INSERT INTO serialTest2 (f1, f2, f3, f4, f5, f6)
  VALUES ('test_max_vals', 2147483647, 32767, 32767, 9223372036854775807,
          9223372036854775807),
         ('test_min_vals', -2147483648, -32768, -32768, -9223372036854775808,
          -9223372036854775808);
---END---
---START---
-- All these INSERTs should fail:
INSERT INTO serialTest2 (f1, f3)
  VALUES ('bogus', -32769);
---END---
---START---
INSERT INTO serialTest2 (f1, f4)
  VALUES ('bogus', -32769);
---END---
---START---
INSERT INTO serialTest2 (f1, f3)
  VALUES ('bogus', 32768);
---END---
---START---
INSERT INTO serialTest2 (f1, f4)
  VALUES ('bogus', 32768);
---END---
---START---
INSERT INTO serialTest2 (f1, f5)
  VALUES ('bogus', -9223372036854775809);
---END---
---START---
INSERT INTO serialTest2 (f1, f6)
  VALUES ('bogus', -9223372036854775809);
---END---
---START---
INSERT INTO serialTest2 (f1, f5)
  VALUES ('bogus', 9223372036854775808);
---END---
---START---
INSERT INTO serialTest2 (f1, f6)
  VALUES ('bogus', 9223372036854775808);
---END---
---START---
SELECT * FROM serialTest2 ORDER BY f2 ASC;
---END---
---START---
SELECT nextval('serialTest2_f2_seq');
---END---
---START---
SELECT nextval('serialTest2_f3_seq');
---END---
---START---
SELECT nextval('serialTest2_f4_seq');
---END---
---START---
SELECT nextval('serialTest2_f5_seq');
---END---
---START---
SELECT nextval('serialTest2_f6_seq');
---END---
---START---
-- basic sequence operations using both text and oid references
CREATE SEQUENCE sequence_test;
---END---
---START---
CREATE SEQUENCE IF NOT EXISTS sequence_test;
---END---
---START---
SELECT nextval('sequence_test'::text);
---END---
---START---
SELECT nextval('sequence_test'::regclass);
---END---
---START---
SELECT currval('sequence_test'::text);
---END---
---START---
SELECT currval('sequence_test'::regclass);
---END---
---START---
SELECT setval('sequence_test'::text, 32);
---END---
---START---
SELECT nextval('sequence_test'::regclass);
---END---
---START---
SELECT setval('sequence_test'::text, 99, false);
---END---
---START---
SELECT nextval('sequence_test'::regclass);
---END---
---START---
SELECT setval('sequence_test'::regclass, 32);
---END---
---START---
SELECT nextval('sequence_test'::text);
---END---
---START---
SELECT setval('sequence_test'::regclass, 99, false);
---END---
---START---
SELECT nextval('sequence_test'::text);
---END---
---START---
DISCARD SEQUENCES;
---END---
---START---
SELECT currval('sequence_test'::regclass);
---END---
---START---
DROP SEQUENCE sequence_test;
---END---
---START---
-- renaming sequences
CREATE SEQUENCE foo_seq;
---END---
---START---
ALTER TABLE foo_seq RENAME TO foo_seq_new;
---END---
---START---
SELECT * FROM foo_seq_new;
---END---
---START---
SELECT nextval('foo_seq_new');
---END---
---START---
SELECT nextval('foo_seq_new');
---END---
---START---
-- log_cnt can be higher if there is a checkpoint just at the right
-- time, so just test for the expected range
SELECT last_value, log_cnt IN (31, 32) AS log_cnt_ok, is_called FROM foo_seq_new;
---END---
---START---
DROP SEQUENCE foo_seq_new;
---END---
---START---
-- renaming serial sequences
ALTER TABLE serialtest1_f2_seq RENAME TO serialtest1_f2_foo;
---END---
---START---
INSERT INTO serialTest1 VALUES ('more');
---END---
---START---
SELECT * FROM serialTest1;
---END---
---START---
--
-- Check dependencies of serial and ordinary sequences
--
CREATE TEMP SEQUENCE myseq2;
---END---
---START---
CREATE TEMP SEQUENCE myseq3;
---END---
---START---
DROP TABLE IF EXISTS t1;

CREATE TABLE t1 (_gemini_pk serial PRIMARY KEY, f1 serial, f2 integer DEFAULT nextval('myseq2'), f3 integer DEFAULT nextval(CAST('myseq3' AS text)));
---END---
---START---
-- Both drops should fail, but with different error messages:
DROP SEQUENCE t1_f1_seq;
---END---
---START---
DROP SEQUENCE myseq2;
---END---
---START---
-- This however will work:
DROP SEQUENCE myseq3;
---END---
---START---
DROP TABLE t1;
---END---
---START---
-- Fails because no longer existent:
DROP SEQUENCE t1_f1_seq;
---END---
---START---
-- Now OK:
DROP SEQUENCE myseq2;
---END---
---START---
--
-- Alter sequence
--

ALTER SEQUENCE IF EXISTS sequence_test2 RESTART WITH 24
  INCREMENT BY 4 MAXVALUE 36 MINVALUE 5 CYCLE;
---END---
---START---
ALTER SEQUENCE serialTest1 CYCLE;
---END---
---START---
-- error, not a sequence

CREATE SEQUENCE sequence_test2 START WITH 32;
---END---
---START---
CREATE SEQUENCE sequence_test4 INCREMENT BY -1;
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test4');
---END---
---START---
ALTER SEQUENCE sequence_test2 RESTART;
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
ALTER SEQUENCE sequence_test2 RESTART WITH 0;
---END---
---START---
-- error
ALTER SEQUENCE sequence_test4 RESTART WITH 40;
---END---
---START---
-- error

-- test CYCLE and NO CYCLE
ALTER SEQUENCE sequence_test2 RESTART WITH 24
  INCREMENT BY 4 MAXVALUE 36 MINVALUE 5 CYCLE;
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
-- cycled

ALTER SEQUENCE sequence_test2 RESTART WITH 24
  NO CYCLE;
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
-- error

ALTER SEQUENCE sequence_test2 RESTART WITH -24 START WITH -24
  INCREMENT BY -4 MINVALUE -36 MAXVALUE -5 CYCLE;
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
-- cycled

ALTER SEQUENCE sequence_test2 RESTART WITH -24
  NO CYCLE;
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
SELECT nextval('sequence_test2');
---END---
---START---
-- error

-- reset
ALTER SEQUENCE IF EXISTS sequence_test2 RESTART WITH 32 START WITH 32
  INCREMENT BY 4 MAXVALUE 36 MINVALUE 5 CYCLE;
---END---
---START---
SELECT setval('sequence_test2', -100);
---END---
---START---
-- error
SELECT setval('sequence_test2', 100);
---END---
---START---
-- error
SELECT setval('sequence_test2', 5);
---END---
---START---
CREATE SEQUENCE sequence_test3;
---END---
---START---
-- not read from, to test is_called


-- Information schema
SELECT * FROM information_schema.sequences
  WHERE sequence_name ~ ANY(ARRAY['sequence_test', 'serialtest'])
  ORDER BY sequence_name ASC;
---END---
---START---
SELECT schemaname, sequencename, start_value, min_value, max_value, increment_by, cycle, cache_size, last_value
FROM pg_sequences
WHERE sequencename ~ ANY(ARRAY['sequence_test', 'serialtest'])
  ORDER BY sequencename ASC;
---END---
---START---
SELECT * FROM pg_sequence_parameters('sequence_test4'::regclass);
---END---
---START---
\d sequence_test4
\d serialtest2_f2_seq


-- Test comments
COMMENT ON SEQUENCE asdf IS 'won''t work';
---END---
---START---
COMMENT ON SEQUENCE sequence_test2 IS 'will work';
---END---
---START---
COMMENT ON SEQUENCE sequence_test2 IS NULL;
---END---
---START---
-- Test lastval()
CREATE SEQUENCE seq;
---END---
---START---
SELECT nextval('seq');
---END---
---START---
SELECT lastval();
---END---
---START---
SELECT setval('seq', 99);
---END---
---START---
SELECT lastval();
---END---
---START---
DISCARD SEQUENCES;
---END---
---START---
SELECT lastval();
---END---
---START---
CREATE SEQUENCE seq2;
---END---
---START---
SELECT nextval('seq2');
---END---
---START---
SELECT lastval();
---END---
---START---
DROP SEQUENCE seq2;
---END---
---START---
-- should fail
SELECT lastval();
---END---
---START---
-- unlogged sequences
-- (more tests in src/test/recovery/)
CREATE UNLOGGED SEQUENCE sequence_test_unlogged;
---END---
---START---
ALTER SEQUENCE sequence_test_unlogged SET LOGGED;
---END---
---START---
\d sequence_test_unlogged
ALTER SEQUENCE sequence_test_unlogged SET UNLOGGED;
---END---
---START---
\d sequence_test_unlogged
DROP SEQUENCE sequence_test_unlogged;
---END---
---START---
-- Test sequences in read-only transactions
CREATE TEMPORARY SEQUENCE sequence_test_temp1;
---END---
---START---
START TRANSACTION READ ONLY;
---END---
---START---
SELECT nextval('sequence_test_temp1');
---END---
---START---
-- ok
SELECT nextval('sequence_test2');
---END---
---START---
-- error
ROLLBACK;
---END---
---START---
START TRANSACTION READ ONLY;
---END---
---START---
SELECT setval('sequence_test_temp1', 1);
---END---
---START---
-- ok
SELECT setval('sequence_test2', 1);
---END---
---START---
-- error
ROLLBACK;
---END---
---START---
-- privileges tests

CREATE USER regress_seq_user;
---END---
---START---
-- nextval
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT SELECT ON seq3 TO regress_seq_user;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT UPDATE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT USAGE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
-- currval
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT SELECT ON seq3 TO regress_seq_user;
---END---
---START---
SELECT currval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT UPDATE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT currval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT USAGE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT currval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
-- lastval
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT SELECT ON seq3 TO regress_seq_user;
---END---
---START---
SELECT lastval();
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT UPDATE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT lastval();
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
GRANT USAGE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT lastval();
---END---
---START---
ROLLBACK;
---END---
---START---
-- setval
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
CREATE SEQUENCE seq3;
---END---
---START---
REVOKE ALL ON seq3 FROM regress_seq_user;
---END---
---START---
SAVEPOINT save;
---END---
---START---
SELECT setval('seq3', 5);
---END---
---START---
ROLLBACK TO save;
---END---
---START---
GRANT UPDATE ON seq3 TO regress_seq_user;
---END---
---START---
SELECT setval('seq3', 5);
---END---
---START---
SELECT nextval('seq3');
---END---
---START---
ROLLBACK;
---END---
---START---
-- ALTER SEQUENCE
BEGIN;
---END---
---START---
SET LOCAL SESSION AUTHORIZATION regress_seq_user;
---END---
---START---
ALTER SEQUENCE sequence_test2 START WITH 1;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Sequences should get wiped out as well:
DROP TABLE serialTest1, serialTest2;
---END---
---START---
-- Make sure sequences are gone:
SELECT * FROM information_schema.sequences WHERE sequence_name IN
  ('sequence_test2', 'serialtest2_f2_seq', 'serialtest2_f3_seq',
   'serialtest2_f4_seq', 'serialtest2_f5_seq', 'serialtest2_f6_seq')
  ORDER BY sequence_name ASC;
---END---
---START---
DROP USER regress_seq_user;
---END---
---START---
DROP SEQUENCE seq;
---END---
---START---
-- cache tests
CREATE SEQUENCE test_seq1 CACHE 10;
---END---
---START---
SELECT nextval('test_seq1');
---END---
---START---
SELECT nextval('test_seq1');
---END---
---START---
SELECT nextval('test_seq1');
---END---
---START---
DROP SEQUENCE test_seq1;
---END---
