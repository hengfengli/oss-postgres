---START---
/*
 * This test is intended to pass on all platforms supported by Postgres.
 * We can therefore only assume that the default, C, and POSIX collations
 * are available --- and since the regression tests are often run in a
 * C-locale database, these may well all have the same behavior.  But
 * fortunately, the system doesn't know that and will treat them as
 * incompatible collations.  It is therefore at least possible to test
 * parser behaviors such as collation conflict resolution.  This test will,
 * however, be more revealing when run in a database with non-C locale,
 * since any departure from C sorting behavior will show as a failure.
 */

CREATE SCHEMA collate_tests;
---END---
---START---
SET search_path = collate_tests;
---END---
---START---
CREATE TABLE collate_test1 (_gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "C" NOT NULL);
---END---
---START---
\d collate_test1

CREATE TABLE collate_test_fail (
    a int COLLATE "C",
    b text
);
---END---
---START---
CREATE TABLE collate_test_like (_gemini_pk serial PRIMARY KEY, LIKE collate_test1);
---END---
---START---
\d collate_test_like

CREATE TABLE collate_test2 (
    a int,
    b text COLLATE "POSIX"
);
---END---
---START---
INSERT INTO collate_test1 VALUES (1, 'abc'), (2, 'Abc'), (3, 'bbc'), (4, 'ABD');
---END---
---START---
INSERT INTO collate_test2 SELECT * FROM collate_test1;
---END---
---START---
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'abc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b >= 'abc' COLLATE "C";
---END---
---START---
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'abc' COLLATE "C";
---END---
---START---
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc' COLLATE "POSIX";
---END---
---START---
-- fail

CREATE DOMAIN testdomain_p AS text COLLATE "POSIX";
---END---
---START---
CREATE DOMAIN testdomain_i AS int COLLATE "POSIX";
---END---
---START---
CREATE TABLE collate_test4 (_gemini_pk serial PRIMARY KEY, a integer, b testdomain_p);
---END---
---START---
INSERT INTO collate_test4 SELECT * FROM collate_test1;
---END---
---START---
SELECT a, b FROM collate_test4 ORDER BY b;
---END---
---START---
CREATE TABLE collate_test5 (_gemini_pk serial PRIMARY KEY, a integer, b testdomain_p COLLATE "C");
---END---
---START---
INSERT INTO collate_test5 SELECT * FROM collate_test1;
---END---
---START---
SELECT a, b FROM collate_test5 ORDER BY b;
---END---
---START---
SELECT a, b FROM collate_test1 ORDER BY b;
---END---
---START---
SELECT a, b FROM collate_test2 ORDER BY b;
---END---
---START---
SELECT a, b FROM collate_test1 ORDER BY b COLLATE "C";
---END---
---START---
-- star expansion
SELECT * FROM collate_test1 ORDER BY b;
---END---
---START---
SELECT * FROM collate_test2 ORDER BY b;
---END---
---START---
-- constant expression folding
SELECT 'bbc' COLLATE "C" > 'Abc' COLLATE "C" AS "true";
---END---
---START---
SELECT 'bbc' COLLATE "POSIX" < 'Abc' COLLATE "POSIX" AS "false";
---END---
---START---
CREATE TABLE collate_test10 (_gemini_pk serial PRIMARY KEY, a integer, x text COLLATE "C", y text COLLATE "POSIX");
---END---
---START---
INSERT INTO collate_test10 VALUES (1, 'hij', 'hij'), (2, 'HIJ', 'HIJ');
---END---
---START---
SELECT a, lower(x), lower(y), upper(x), upper(y), initcap(x), initcap(y) FROM collate_test10;
---END---
---START---
SELECT a, lower(x COLLATE "C"), lower(y COLLATE "C") FROM collate_test10;
---END---
---START---
SELECT a, x, y FROM collate_test10 ORDER BY lower(y), a;
---END---
---START---
-- backwards parsing

CREATE VIEW collview1 AS SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc';
---END---
---START---
CREATE VIEW collview2 AS SELECT a, b FROM collate_test1 ORDER BY b COLLATE "C";
---END---
---START---
CREATE VIEW collview3 AS SELECT a, lower((x || x) COLLATE "POSIX") FROM collate_test10;
---END---
---START---
SELECT table_name, view_definition FROM information_schema.views
  WHERE table_name LIKE 'collview%' ORDER BY 1;
---END---
---START---
-- collation propagation in various expression types

SELECT a, coalesce(b, 'foo') FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, coalesce(b, 'foo') FROM collate_test2 ORDER BY 2;
---END---
---START---
SELECT a, lower(coalesce(x, 'foo')), lower(coalesce(y, 'foo')) FROM collate_test10;
---END---
---START---
SELECT a, b, greatest(b, 'CCC') FROM collate_test1 ORDER BY 3;
---END---
---START---
SELECT a, b, greatest(b, 'CCC') FROM collate_test2 ORDER BY 3;
---END---
---START---
SELECT a, x, y, lower(greatest(x, 'foo')), lower(greatest(y, 'foo')) FROM collate_test10;
---END---
---START---
SELECT a, nullif(b, 'abc') FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, nullif(b, 'abc') FROM collate_test2 ORDER BY 2;
---END---
---START---
SELECT a, lower(nullif(x, 'foo')), lower(nullif(y, 'foo')) FROM collate_test10;
---END---
---START---
SELECT a, CASE b WHEN 'abc' THEN 'abcd' ELSE b END FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, CASE b WHEN 'abc' THEN 'abcd' ELSE b END FROM collate_test2 ORDER BY 2;
---END---
---START---
CREATE DOMAIN testdomain AS text;
---END---
---START---
SELECT a, b::testdomain FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, b::testdomain FROM collate_test2 ORDER BY 2;
---END---
---START---
SELECT a, b::testdomain_p FROM collate_test2 ORDER BY 2;
---END---
---START---
SELECT a, lower(x::testdomain), lower(y::testdomain) FROM collate_test10;
---END---
---START---
SELECT min(b), max(b) FROM collate_test1;
---END---
---START---
SELECT min(b), max(b) FROM collate_test2;
---END---
---START---
SELECT array_agg(b ORDER BY b) FROM collate_test1;
---END---
---START---
SELECT array_agg(b ORDER BY b) FROM collate_test2;
---END---
---START---
-- In aggregates, ORDER BY expressions don't affect aggregate's collation
SELECT string_agg(x COLLATE "C", y COLLATE "POSIX") FROM collate_test10;
---END---
---START---
-- fail
SELECT array_agg(x COLLATE "C" ORDER BY y COLLATE "POSIX") FROM collate_test10;
---END---
---START---
SELECT array_agg(a ORDER BY x COLLATE "C", y COLLATE "POSIX") FROM collate_test10;
---END---
---START---
SELECT array_agg(a ORDER BY x||y) FROM collate_test10;
---END---
---START---
-- fail

SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test2 UNION SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test2 WHERE a < 4 INTERSECT SELECT a, b FROM collate_test2 WHERE a > 1 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test2 EXCEPT SELECT a, b FROM collate_test2 WHERE a < 2 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
-- fail
SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test2;
---END---
---START---
-- ok
SELECT a, b FROM collate_test1 UNION SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
-- fail
SELECT a, b COLLATE "C" FROM collate_test1 UNION SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
-- ok
SELECT a, b FROM collate_test1 INTERSECT SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
-- fail
SELECT a, b FROM collate_test1 EXCEPT SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
-- fail

CREATE TABLE test_u AS SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test2;
---END---
---START---
-- fail

-- ideally this would be a parse-time error, but for now it must be run-time:
select x < y from collate_test10;
---END---
---START---
-- fail
select x || y from collate_test10;
---END---
---START---
-- ok, because || is not collation aware
select x, y from collate_test10 order by x || y;
---END---
---START---
-- not so ok

-- collation mismatch between recursive and non-recursive term
WITH RECURSIVE foo(x) AS
   (SELECT x FROM (VALUES('a' COLLATE "C"),('b')) t(x)
   UNION ALL
   SELECT (x || 'c') COLLATE "POSIX" FROM foo WHERE length(x) < 10)
SELECT * FROM foo;
---END---
---START---
SELECT a, b, a < b as lt FROM
  (VALUES ('a', 'B'), ('A', 'b' COLLATE "C")) v(a,b);
---END---
---START---
-- collation mismatch in subselects
SELECT * FROM collate_test10 WHERE (x, y) NOT IN (SELECT y, x FROM collate_test10);
---END---
---START---
-- now it works with overrides
SELECT * FROM collate_test10 WHERE (x COLLATE "POSIX", y COLLATE "C") NOT IN (SELECT y, x FROM collate_test10);
---END---
---START---
SELECT * FROM collate_test10 WHERE (x, y) NOT IN (SELECT y COLLATE "C", x COLLATE "POSIX" FROM collate_test10);
---END---
---START---
-- casting

SELECT CAST('42' AS text COLLATE "C");
---END---
---START---
SELECT a, CAST(b AS varchar) FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, CAST(b AS varchar) FROM collate_test2 ORDER BY 2;
---END---
---START---
-- result of a SQL function

CREATE FUNCTION vc (text) RETURNS text LANGUAGE sql
    AS 'select $1::varchar';
---END---
---START---
SELECT a, b FROM collate_test1 ORDER BY a, vc(b);
---END---
---START---
-- polymorphism

SELECT * FROM unnest((SELECT array_agg(b ORDER BY b) FROM collate_test1)) ORDER BY 1;
---END---
---START---
SELECT * FROM unnest((SELECT array_agg(b ORDER BY b) FROM collate_test2)) ORDER BY 1;
---END---
---START---
CREATE FUNCTION dup (anyelement) RETURNS anyelement
    AS 'select $1' LANGUAGE sql;
---END---
---START---
SELECT a, dup(b) FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, dup(b) FROM collate_test2 ORDER BY 2;
---END---
---START---
-- indexes

CREATE INDEX collate_test1_idx1 ON collate_test1 (b);
---END---
---START---
CREATE INDEX collate_test1_idx2 ON collate_test1 (b COLLATE "POSIX");
---END---
---START---
CREATE INDEX collate_test1_idx3 ON collate_test1 ((b COLLATE "POSIX"));
---END---
---START---
-- this is different grammatically
CREATE INDEX collate_test1_idx4 ON collate_test1 (((b||'foo') COLLATE "POSIX"));
---END---
---START---
CREATE INDEX collate_test1_idx5 ON collate_test1 (a COLLATE "POSIX");
---END---
---START---
-- fail
CREATE INDEX collate_test1_idx6 ON collate_test1 ((a COLLATE "POSIX"));
---END---
---START---
-- fail

SELECT relname, pg_get_indexdef(oid) FROM pg_class WHERE relname LIKE 'collate_test%_idx%' ORDER BY 1;
---END---
---START---
-- foreign keys

-- force indexes and mergejoins to be used for FK checking queries,
-- else they might not exercise collation-dependent operators
SET enable_seqscan TO 0;
---END---
---START---
SET enable_hashjoin TO 0;
---END---
---START---
SET enable_nestloop TO 0;
---END---
---START---
CREATE TABLE collate_test20 (f1 text COLLATE "C" PRIMARY KEY);
---END---
---START---
INSERT INTO collate_test20 VALUES ('foo'), ('bar');
---END---
---START---
CREATE TABLE collate_test21 (_gemini_pk serial PRIMARY KEY, f2 text COLLATE "POSIX" REFERENCES collate_test20);
---END---
---START---
INSERT INTO collate_test21 VALUES ('foo'), ('bar');
---END---
---START---
INSERT INTO collate_test21 VALUES ('baz');
---END---
---START---
CREATE TABLE collate_test22 (_gemini_pk serial PRIMARY KEY, f2 text COLLATE "POSIX");
---END---
---START---
INSERT INTO collate_test22 VALUES ('foo'), ('bar'), ('baz');
---END---
---START---
ALTER TABLE collate_test22 ADD FOREIGN KEY (f2) REFERENCES collate_test20;
---END---
---START---
-- fail
DELETE FROM collate_test22 WHERE f2 = 'baz';
---END---
---START---
ALTER TABLE collate_test22 ADD FOREIGN KEY (f2) REFERENCES collate_test20;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_hashjoin;
---END---
---START---
RESET enable_nestloop;
---END---
---START---
-- EXPLAIN

EXPLAIN (COSTS OFF)
  SELECT * FROM collate_test10 ORDER BY x, y;
---END---
---START---
EXPLAIN (COSTS OFF)
  SELECT * FROM collate_test10 ORDER BY x DESC, y COLLATE "C" ASC NULLS FIRST;
---END---
---START---
-- CREATE/DROP COLLATION

CREATE COLLATION mycoll1 FROM "C";
---END---
---START---
CREATE COLLATION mycoll2 ( LC_COLLATE = "POSIX", LC_CTYPE = "POSIX" );
---END---
---START---
CREATE COLLATION mycoll3 FROM "default";
---END---
---START---
-- intentionally unsupported

DROP COLLATION mycoll1;
---END---
---START---
CREATE TABLE collate_test23 (_gemini_pk serial PRIMARY KEY, f1 text COLLATE mycoll2);
---END---
---START---
DROP COLLATION mycoll2;
---END---
---START---
-- fail

-- invalid: non-lowercase quoted identifiers
CREATE COLLATION case_coll ("Lc_Collate" = "POSIX", "Lc_Ctype" = "POSIX");
---END---
---START---
-- 9.1 bug with useless COLLATE in an expression subject to length coercion

DROP TABLE IF EXISTS vctable;

CREATE TABLE vctable (_gemini_pk serial PRIMARY KEY, f1 varchar(25));
---END---
---START---
INSERT INTO vctable VALUES ('foo' COLLATE "C");
---END---
---START---
SELECT collation for ('foo');
---END---
---START---
-- unknown type - null
SELECT collation for ('foo'::text);
---END---
---START---
SELECT collation for ((SELECT a FROM collate_test1 LIMIT 1));
---END---
---START---
-- non-collatable type - error
SELECT collation for ((SELECT b FROM collate_test1 LIMIT 1));
---END---
---START---
-- old bug with not dropping COLLATE when coercing to non-collatable type
CREATE VIEW collate_on_int AS
SELECT c1+1 AS c1p FROM
  (SELECT ('4' COLLATE "C")::INT AS c1) ss;
---END---
---START---
\d+ collate_on_int

-- Check conflicting or redundant options in CREATE COLLATION
-- LC_COLLATE
CREATE COLLATION coll_dup_chk (LC_COLLATE = "POSIX", LC_COLLATE = "NONSENSE", LC_CTYPE = "POSIX");
---END---
---START---
-- LC_CTYPE
CREATE COLLATION coll_dup_chk (LC_CTYPE = "POSIX", LC_CTYPE = "NONSENSE", LC_COLLATE = "POSIX");
---END---
---START---
-- PROVIDER
CREATE COLLATION coll_dup_chk (PROVIDER = icu, PROVIDER = NONSENSE, LC_COLLATE = "POSIX", LC_CTYPE = "POSIX");
---END---
---START---
-- LOCALE
CREATE COLLATION case_sensitive (LOCALE = '', LOCALE = "NONSENSE");
---END---
---START---
-- DETERMINISTIC
CREATE COLLATION coll_dup_chk (DETERMINISTIC = TRUE, DETERMINISTIC = NONSENSE, LOCALE = '');
---END---
---START---
-- VERSION
CREATE COLLATION coll_dup_chk (VERSION = '1', VERSION = "NONSENSE", LOCALE = '');
---END---
---START---
-- LOCALE conflicts with LC_COLLATE and LC_CTYPE
CREATE COLLATION coll_dup_chk (LC_COLLATE = "POSIX", LC_CTYPE = "POSIX", LOCALE = '');
---END---
---START---
-- LOCALE conflicts with LC_COLLATE
CREATE COLLATION coll_dup_chk (LC_COLLATE = "POSIX", LOCALE = '');
---END---
---START---
-- LOCALE conflicts with LC_CTYPE
CREATE COLLATION coll_dup_chk (LC_CTYPE = "POSIX", LOCALE = '');
---END---
---START---
-- FROM conflicts with any other option
CREATE COLLATION coll_dup_chk (FROM = "C", VERSION = "1");
---END---
---START---
--
-- Clean up.  Many of these table names will be re-used if the user is
-- trying to run any platform-specific collation tests later, so we
-- must get rid of them.
--
DROP SCHEMA collate_tests CASCADE;
---END---
