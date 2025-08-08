---START---
CREATE TABLE inhx (_gemini_pk serial PRIMARY KEY, xx text DEFAULT 'text');
---END---
---START---
CREATE TABLE ctla (_gemini_pk serial PRIMARY KEY, aa text);
---END---
---START---
CREATE TABLE ctlb (_gemini_pk serial PRIMARY KEY, bb text) INHERITS (ctla);
---END---
---START---
CREATE TABLE foo (_gemini_pk serial PRIMARY KEY, LIKE nonexistent);
---END---
---START---
CREATE TABLE inhe (_gemini_pk serial PRIMARY KEY, ee text, LIKE inhx) INHERITS (ctlb);
---END---
---START---
INSERT INTO inhe VALUES ('ee-col1', 'ee-col2', DEFAULT, 'ee-col4');
---END---
---START---
SELECT * FROM inhe;
---END---
---START---
/* Columns aa, bb, xx value NULL, ee */
SELECT * FROM inhx;
---END---
---START---
/* Empty set since LIKE inherits structure only */
SELECT * FROM ctlb;
---END---
---START---
/* Has ee entry */
SELECT * FROM ctla;
---END---
---START---
CREATE TABLE inhf (_gemini_pk serial PRIMARY KEY, LIKE inhx, LIKE inhx);
---END---
---START---
CREATE TABLE inhf (_gemini_pk serial PRIMARY KEY, LIKE inhx INCLUDING CONSTRAINTS INCLUDING DEFAULTS);
---END---
---START---
INSERT INTO inhf DEFAULT VALUES;
---END---
---START---
SELECT * FROM inhf;
---END---
---START---
/* Single entry with value 'text' */

ALTER TABLE inhx add constraint foo CHECK (xx = 'text');
---END---
---START---
ALTER TABLE inhx ADD PRIMARY KEY (xx);
---END---
---START---
CREATE TABLE inhg (_gemini_pk serial PRIMARY KEY, LIKE inhx);
---END---
---START---
/* Doesn't copy constraint */
INSERT INTO inhg VALUES ('foo');
---END---
---START---
DROP TABLE inhg;
---END---
---START---
CREATE TABLE inhg (_gemini_pk serial PRIMARY KEY, x text, LIKE inhx INCLUDING CONSTRAINTS, y text);
---END---
---START---
/* Copies constraints */
INSERT INTO inhg VALUES ('x', 'text', 'y');
---END---
---START---
/* Succeeds */
INSERT INTO inhg VALUES ('x', 'text', 'y');
---END---
---START---
/* Succeeds -- Unique constraints not copied */
INSERT INTO inhg VALUES ('x', 'foo',  'y');
---END---
---START---
/* fails due to constraint */
SELECT * FROM inhg;
---END---
---START---
/* Two records with three columns in order x=x, xx=text, y=y */
DROP TABLE inhg;
---END---
---START---
CREATE TABLE test_like_id_1 (_gemini_pk serial PRIMARY KEY, a bigint GENERATED ALWAYS AS IDENTITY, b text);
---END---
---START---
\d test_like_id_1
INSERT INTO test_like_id_1 (b) VALUES ('b1');
---END---
---START---
SELECT * FROM test_like_id_1;
---END---
---START---
CREATE TABLE test_like_id_2 (_gemini_pk serial PRIMARY KEY, LIKE test_like_id_1);
---END---
---START---
\d test_like_id_2
INSERT INTO test_like_id_2 (b) VALUES ('b2');
---END---
---START---
SELECT * FROM test_like_id_2;
---END---
---START---
CREATE TABLE test_like_id_3 (_gemini_pk serial PRIMARY KEY, LIKE test_like_id_1 INCLUDING IDENTITY);
---END---
---START---
\d test_like_id_3
INSERT INTO test_like_id_3 (b) VALUES ('b3');
---END---
---START---
SELECT * FROM test_like_id_3;
---END---
---START---
-- identity was copied and applied
DROP TABLE test_like_id_1, test_like_id_2, test_like_id_3;
---END---
---START---
CREATE TABLE test_like_gen_1 (_gemini_pk serial PRIMARY KEY, a integer, b integer GENERATED ALWAYS AS (a * 2) STORED);
---END---
---START---
\d test_like_gen_1
INSERT INTO test_like_gen_1 (a) VALUES (1);
---END---
---START---
SELECT * FROM test_like_gen_1;
---END---
---START---
CREATE TABLE test_like_gen_2 (_gemini_pk serial PRIMARY KEY, LIKE test_like_gen_1);
---END---
---START---
\d test_like_gen_2
INSERT INTO test_like_gen_2 (a) VALUES (1);
---END---
---START---
SELECT * FROM test_like_gen_2;
---END---
---START---
CREATE TABLE test_like_gen_3 (_gemini_pk serial PRIMARY KEY, LIKE test_like_gen_1 INCLUDING GENERATED);
---END---
---START---
\d test_like_gen_3
INSERT INTO test_like_gen_3 (a) VALUES (1);
---END---
---START---
SELECT * FROM test_like_gen_3;
---END---
---START---
DROP TABLE test_like_gen_1, test_like_gen_2, test_like_gen_3;
---END---
---START---
CREATE TABLE test_like_4 (_gemini_pk serial PRIMARY KEY, b integer DEFAULT 42, c integer GENERATED ALWAYS AS (a * 2) STORED, a integer CHECK (a > 0));
---END---
---START---
\d test_like_4
CREATE TABLE test_like_4a (LIKE test_like_4);
---END---
---START---
CREATE TABLE test_like_4b (_gemini_pk serial PRIMARY KEY, LIKE test_like_4 INCLUDING DEFAULTS);
---END---
---START---
CREATE TABLE test_like_4c (_gemini_pk serial PRIMARY KEY, LIKE test_like_4 INCLUDING GENERATED);
---END---
---START---
CREATE TABLE test_like_4d (_gemini_pk serial PRIMARY KEY, LIKE test_like_4 INCLUDING DEFAULTS INCLUDING GENERATED);
---END---
---START---
\d test_like_4a
INSERT INTO test_like_4a (a) VALUES(11);
---END---
---START---
SELECT a, b, c FROM test_like_4a;
---END---
---START---
\d test_like_4b
INSERT INTO test_like_4b (a) VALUES(11);
---END---
---START---
SELECT a, b, c FROM test_like_4b;
---END---
---START---
\d test_like_4c
INSERT INTO test_like_4c (a) VALUES(11);
---END---
---START---
SELECT a, b, c FROM test_like_4c;
---END---
---START---
\d test_like_4d
INSERT INTO test_like_4d (a) VALUES(11);
---END---
---START---
SELECT a, b, c FROM test_like_4d;
---END---
---START---
CREATE TABLE test_like_5 (_gemini_pk serial PRIMARY KEY, x point, y point, z point);
---END---
---START---
CREATE TABLE test_like_5x (_gemini_pk serial PRIMARY KEY, p integer CHECK (p > 0), q integer GENERATED ALWAYS AS (p * 2) STORED);
---END---
---START---
CREATE TABLE test_like_5c (_gemini_pk serial PRIMARY KEY, LIKE test_like_4 INCLUDING ALL) INHERITS (test_like_5, test_like_5x);
---END---
---START---
\d test_like_5c

DROP TABLE test_like_4, test_like_4a, test_like_4b, test_like_4c, test_like_4d;
---END---
---START---
DROP TABLE test_like_5, test_like_5x, test_like_5c;
---END---
---START---
CREATE TABLE inhg (_gemini_pk serial PRIMARY KEY, x text, LIKE inhx INCLUDING INDEXES, y text);
---END---
---START---
/* copies indexes */
INSERT INTO inhg VALUES (5, 10);
---END---
---START---
INSERT INTO inhg VALUES (20, 10);
---END---
---START---
-- should fail
DROP TABLE inhg;
---END---
---START---
/* Multiple primary keys creation should fail */
CREATE TABLE inhg (x text, LIKE inhx INCLUDING INDEXES, PRIMARY KEY(x));
---END---
---START---
CREATE TABLE inhz (_gemini_pk serial PRIMARY KEY, xx text DEFAULT 'text', yy integer UNIQUE);
---END---
---START---
CREATE UNIQUE INDEX inhz_xx_idx on inhz (xx) WHERE xx <> 'test';
---END---
---START---
CREATE TABLE inhg (_gemini_pk serial PRIMARY KEY, x text UNIQUE, LIKE inhz INCLUDING INDEXES);
---END---
---START---
INSERT INTO inhg (xx, yy, x) VALUES ('test', 5, 10);
---END---
---START---
INSERT INTO inhg (xx, yy, x) VALUES ('test', 10, 15);
---END---
---START---
INSERT INTO inhg (xx, yy, x) VALUES ('foo', 10, 15);
---END---
---START---
-- should fail
DROP TABLE inhg;
---END---
---START---
DROP TABLE inhz;
---END---
---START---
CREATE TABLE inhz (_gemini_pk serial PRIMARY KEY, x text REFERENCES inhz, LIKE inhx INCLUDING INDEXES);
---END---
---START---
\d inhz
DROP TABLE inhz;
---END---
---START---
-- including storage and comments
CREATE TABLE ctlt1 (a text CHECK (length(a) > 2) PRIMARY KEY, b text);
---END---
---START---
CREATE INDEX ctlt1_b_key ON ctlt1 (b);
---END---
---START---
CREATE INDEX ctlt1_fnidx ON ctlt1 ((a || b));
---END---
---START---
CREATE STATISTICS ctlt1_a_b_stat ON a,b FROM ctlt1;
---END---
---START---
CREATE STATISTICS ctlt1_expr_stat ON (a || b) FROM ctlt1;
---END---
---START---
COMMENT ON STATISTICS ctlt1_a_b_stat IS 'ab stats';
---END---
---START---
COMMENT ON STATISTICS ctlt1_expr_stat IS 'ab expr stats';
---END---
---START---
COMMENT ON COLUMN ctlt1.a IS 'A';
---END---
---START---
COMMENT ON COLUMN ctlt1.b IS 'B';
---END---
---START---
COMMENT ON CONSTRAINT ctlt1_a_check ON ctlt1 IS 't1_a_check';
---END---
---START---
COMMENT ON INDEX ctlt1_pkey IS 'index pkey';
---END---
---START---
COMMENT ON INDEX ctlt1_b_key IS 'index b_key';
---END---
---START---
ALTER TABLE ctlt1 ALTER COLUMN a SET STORAGE MAIN;
---END---
---START---
CREATE TABLE ctlt2 (_gemini_pk serial PRIMARY KEY, c text);
---END---
---START---
ALTER TABLE ctlt2 ALTER COLUMN c SET STORAGE EXTERNAL;
---END---
---START---
COMMENT ON COLUMN ctlt2.c IS 'C';
---END---
---START---
CREATE TABLE ctlt3 (_gemini_pk serial PRIMARY KEY, a text CHECK (length(a) < 5), c text CHECK (length(c) < 7));
---END---
---START---
ALTER TABLE ctlt3 ALTER COLUMN c SET STORAGE EXTERNAL;
---END---
---START---
ALTER TABLE ctlt3 ALTER COLUMN a SET STORAGE MAIN;
---END---
---START---
CREATE INDEX ctlt3_fnidx ON ctlt3 ((a || c));
---END---
---START---
COMMENT ON COLUMN ctlt3.a IS 'A3';
---END---
---START---
COMMENT ON COLUMN ctlt3.c IS 'C';
---END---
---START---
COMMENT ON CONSTRAINT ctlt3_a_check ON ctlt3 IS 't3_a_check';
---END---
---START---
CREATE TABLE ctlt4 (_gemini_pk serial PRIMARY KEY, a text, c text);
---END---
---START---
ALTER TABLE ctlt4 ALTER COLUMN c SET STORAGE EXTERNAL;
---END---
---START---
CREATE TABLE ctlt12_storage (_gemini_pk serial PRIMARY KEY, LIKE ctlt1 INCLUDING STORAGE, LIKE ctlt2 INCLUDING STORAGE);
---END---
---START---
\d+ ctlt12_storage
CREATE TABLE ctlt12_comments (LIKE ctlt1 INCLUDING COMMENTS, LIKE ctlt2 INCLUDING COMMENTS);
---END---
---START---
\d+ ctlt12_comments
CREATE TABLE ctlt1_inh (LIKE ctlt1 INCLUDING CONSTRAINTS INCLUDING COMMENTS) INHERITS (ctlt1);
---END---
---START---
\d+ ctlt1_inh
SELECT description FROM pg_description, pg_constraint c WHERE classoid = 'pg_constraint'::regclass AND objoid = c.oid AND c.conrelid = 'ctlt1_inh'::regclass;
---END---
---START---
CREATE TABLE ctlt13_inh (_gemini_pk serial PRIMARY KEY) INHERITS (ctlt1, ctlt3);
---END---
---START---
\d+ ctlt13_inh
CREATE TABLE ctlt13_like (LIKE ctlt3 INCLUDING CONSTRAINTS INCLUDING INDEXES INCLUDING COMMENTS INCLUDING STORAGE) INHERITS (ctlt1);
---END---
---START---
\d+ ctlt13_like
SELECT description FROM pg_description, pg_constraint c WHERE classoid = 'pg_constraint'::regclass AND objoid = c.oid AND c.conrelid = 'ctlt13_like'::regclass;
---END---
---START---
CREATE TABLE ctlt_all (_gemini_pk serial PRIMARY KEY, LIKE ctlt1 INCLUDING ALL);
---END---
---START---
\d+ ctlt_all
SELECT c.relname, objsubid, description FROM pg_description, pg_index i, pg_class c WHERE classoid = 'pg_class'::regclass AND objoid = i.indexrelid AND c.oid = i.indexrelid AND i.indrelid = 'ctlt_all'::regclass ORDER BY c.relname, objsubid;
---END---
---START---
SELECT s.stxname, objsubid, description FROM pg_description, pg_statistic_ext s WHERE classoid = 'pg_statistic_ext'::regclass AND objoid = s.oid AND s.stxrelid = 'ctlt_all'::regclass ORDER BY s.stxname, objsubid;
---END---
---START---
CREATE TABLE inh_error1 (_gemini_pk serial PRIMARY KEY) INHERITS (ctlt1, ctlt4);
---END---
---START---
CREATE TABLE inh_error2 (_gemini_pk serial PRIMARY KEY, LIKE ctlt4 INCLUDING STORAGE) INHERITS (ctlt1);
---END---
---START---
CREATE TABLE pg_attrdef (_gemini_pk serial PRIMARY KEY, LIKE ctlt1 INCLUDING ALL);
---END---
---START---
\d+ public.pg_attrdef
DROP TABLE public.pg_attrdef;
---END---
---START---
-- Check that LIKE isn't confused when new table masks the old, either
BEGIN;
---END---
---START---
CREATE SCHEMA ctl_schema;
---END---
---START---
SET LOCAL search_path = ctl_schema, public;
---END---
---START---
CREATE TABLE ctlt1 (_gemini_pk serial PRIMARY KEY, LIKE ctlt1 INCLUDING ALL);
---END---
---START---
\d+ ctlt1
ROLLBACK;
---END---
---START---
DROP TABLE ctlt1, ctlt2, ctlt3, ctlt4, ctlt12_storage, ctlt12_comments, ctlt1_inh, ctlt13_inh, ctlt13_like, ctlt_all, ctla, ctlb CASCADE;
---END---
---START---
CREATE TABLE noinh_con_copy (_gemini_pk serial PRIMARY KEY, a integer CHECK (a > 0) NO INHERIT);
---END---
---START---
CREATE TABLE noinh_con_copy1 (_gemini_pk serial PRIMARY KEY, LIKE noinh_con_copy INCLUDING CONSTRAINTS);
---END---
---START---
\d noinh_con_copy1

-- fail, as partitioned tables don't allow NO INHERIT constraints
CREATE TABLE noinh_con_copy1_parted (LIKE noinh_con_copy INCLUDING ALL)
  PARTITION BY LIST (a);
---END---
---START---
DROP TABLE noinh_con_copy, noinh_con_copy1;
---END---
---START---
CREATE TABLE ctlt4 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
CREATE SEQUENCE ctlseq1;
---END---
---START---
CREATE TABLE ctlt10 (_gemini_pk serial PRIMARY KEY, LIKE ctlseq1);
---END---
---START---
-- fail

CREATE VIEW ctlv1 AS SELECT * FROM ctlt4;
---END---
---START---
CREATE TABLE ctlt11 (_gemini_pk serial PRIMARY KEY, LIKE ctlv1);
---END---
---START---
CREATE TABLE ctlt11a (_gemini_pk serial PRIMARY KEY, LIKE ctlv1 INCLUDING ALL);
---END---
---START---
CREATE TYPE ctlty1 AS (a int, b text);
---END---
---START---
CREATE TABLE ctlt12 (_gemini_pk serial PRIMARY KEY, LIKE ctlty1);
---END---
---START---
DROP SEQUENCE ctlseq1;
---END---
---START---
DROP TYPE ctlty1;
---END---
---START---
DROP VIEW ctlv1;
---END---
---START---
DROP TABLE IF EXISTS ctlt4, ctlt10, ctlt11, ctlt11a, ctlt12;
---END---
