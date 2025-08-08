---START---
/*
 * This test is for Linux/glibc systems and assumes that a full set of
 * locales is installed.  It must be run in a database with UTF-8 encoding,
 * because other encodings don't support all the characters used.
 */

SELECT getdatabaseencoding() <> 'UTF8' OR
       (SELECT count(*) FROM pg_collation WHERE collname IN ('de_DE', 'en_US', 'sv_SE', 'tr_TR') AND collencoding = pg_char_to_encoding('UTF8')) <> 4 OR
       version() !~ 'linux-gnu'
       AS skip_test \gset
\if :skip_test
\quit
\endif

SET client_encoding TO UTF8;
---END---
---START---
CREATE SCHEMA collate_tests;
---END---
---START---
SET search_path = collate_tests;
---END---
---START---
CREATE TABLE collate_test1 (_gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "en_US" NOT NULL);
---END---
---START---
\d collate_test1

CREATE TABLE collate_test_fail (
    a int,
    b text COLLATE "ja_JP.eucjp"
);
---END---
---START---
CREATE TABLE collate_test_fail (_gemini_pk serial PRIMARY KEY, a integer, b text COLLATE foo);
---END---
---START---
CREATE TABLE collate_test_fail (_gemini_pk serial PRIMARY KEY, a integer COLLATE "en_US", b text);
---END---
---START---
CREATE TABLE collate_test_like (_gemini_pk serial PRIMARY KEY, LIKE collate_test1);
---END---
---START---
\d collate_test_like

CREATE TABLE collate_test2 (
    a int,
    b text COLLATE "sv_SE"
);
---END---
---START---
CREATE TABLE collate_test3 (_gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "C");
---END---
---START---
INSERT INTO collate_test1 VALUES (1, 'abc'), (2, 'äbc'), (3, 'bbc'), (4, 'ABC');
---END---
---START---
INSERT INTO collate_test2 SELECT * FROM collate_test1;
---END---
---START---
INSERT INTO collate_test3 SELECT * FROM collate_test1;
---END---
---START---
SELECT * FROM collate_test1 WHERE b >= 'bbc';
---END---
---START---
SELECT * FROM collate_test2 WHERE b >= 'bbc';
---END---
---START---
SELECT * FROM collate_test3 WHERE b >= 'bbc';
---END---
---START---
SELECT * FROM collate_test3 WHERE b >= 'BBC';
---END---
---START---
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b >= 'bbc' COLLATE "C";
---END---
---START---
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc' COLLATE "C";
---END---
---START---
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc' COLLATE "en_US";
---END---
---START---
CREATE DOMAIN testdomain_sv AS text COLLATE "sv_SE";
---END---
---START---
CREATE DOMAIN testdomain_i AS int COLLATE "sv_SE";
---END---
---START---
CREATE TABLE collate_test4 (_gemini_pk serial PRIMARY KEY, a integer, b testdomain_sv);
---END---
---START---
INSERT INTO collate_test4 SELECT * FROM collate_test1;
---END---
---START---
SELECT a, b FROM collate_test4 ORDER BY b;
---END---
---START---
CREATE TABLE collate_test5 (_gemini_pk serial PRIMARY KEY, a integer, b testdomain_sv COLLATE "en_US");
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
SELECT a, b FROM collate_test3 ORDER BY b;
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
SELECT * FROM collate_test3 ORDER BY b;
---END---
---START---
-- constant expression folding
SELECT 'bbc' COLLATE "en_US" > 'äbc' COLLATE "en_US" AS "true";
---END---
---START---
SELECT 'bbc' COLLATE "sv_SE" > 'äbc' COLLATE "sv_SE" AS "false";
---END---
---START---
CREATE TABLE collate_test10 (_gemini_pk serial PRIMARY KEY, a integer, x text COLLATE "en_US", y text COLLATE "tr_TR");
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
-- LIKE/ILIKE

SELECT * FROM collate_test1 WHERE b LIKE 'abc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b LIKE 'abc%';
---END---
---START---
SELECT * FROM collate_test1 WHERE b LIKE '%bc%';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ILIKE 'abc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ILIKE 'abc%';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ILIKE '%bc%';
---END---
---START---
SELECT 'Türkiye' COLLATE "en_US" ILIKE '%KI%' AS "true";
---END---
---START---
SELECT 'Türkiye' COLLATE "tr_TR" ILIKE '%KI%' AS "false";
---END---
---START---
SELECT 'bıt' ILIKE 'BIT' COLLATE "en_US" AS "false";
---END---
---START---
SELECT 'bıt' ILIKE 'BIT' COLLATE "tr_TR" AS "true";
---END---
---START---
-- The following actually exercises the selectivity estimation for ILIKE.
SELECT relname FROM pg_class WHERE relname ILIKE 'abc%';
---END---
---START---
-- regular expressions

SELECT * FROM collate_test1 WHERE b ~ '^abc$';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ~ '^abc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ~ 'bc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ~* '^abc$';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ~* '^abc';
---END---
---START---
SELECT * FROM collate_test1 WHERE b ~* 'bc';
---END---
---START---
CREATE TABLE collate_test6 (_gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "en_US");
---END---
---START---
INSERT INTO collate_test6 VALUES (1, 'abc'), (2, 'ABC'), (3, '123'), (4, 'ab1'),
                                 (5, 'a1!'), (6, 'a c'), (7, '!.;'), (8, '   '),
                                 (9, 'äbç'), (10, 'ÄBÇ');
---END---
---START---
SELECT b,
       b ~ '^[[:alpha:]]+$' AS is_alpha,
       b ~ '^[[:upper:]]+$' AS is_upper,
       b ~ '^[[:lower:]]+$' AS is_lower,
       b ~ '^[[:digit:]]+$' AS is_digit,
       b ~ '^[[:alnum:]]+$' AS is_alnum,
       b ~ '^[[:graph:]]+$' AS is_graph,
       b ~ '^[[:print:]]+$' AS is_print,
       b ~ '^[[:punct:]]+$' AS is_punct,
       b ~ '^[[:space:]]+$' AS is_space
FROM collate_test6;
---END---
---START---
SELECT 'Türkiye' COLLATE "en_US" ~* 'KI' AS "true";
---END---
---START---
SELECT 'Türkiye' COLLATE "tr_TR" ~* 'KI' AS "false";
---END---
---START---
SELECT 'bıt' ~* 'BIT' COLLATE "en_US" AS "false";
---END---
---START---
SELECT 'bıt' ~* 'BIT' COLLATE "tr_TR" AS "true";
---END---
---START---
-- The following actually exercises the selectivity estimation for ~*.
SELECT relname FROM pg_class WHERE relname ~* '^abc';
---END---
---START---
-- to_char

SET lc_time TO 'tr_TR';
---END---
---START---
SELECT to_char(date '2010-02-01', 'DD TMMON YYYY');
---END---
---START---
SELECT to_char(date '2010-02-01', 'DD TMMON YYYY' COLLATE "tr_TR");
---END---
---START---
SELECT to_char(date '2010-04-01', 'DD TMMON YYYY');
---END---
---START---
SELECT to_char(date '2010-04-01', 'DD TMMON YYYY' COLLATE "tr_TR");
---END---
---START---
-- to_date

SELECT to_date('01 ŞUB 2010', 'DD TMMON YYYY');
---END---
---START---
SELECT to_date('01 Şub 2010', 'DD TMMON YYYY');
---END---
---START---
SELECT to_date('1234567890ab 2010', 'TMMONTH YYYY');
---END---
---START---
-- fail


-- backwards parsing

CREATE VIEW collview1 AS SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc';
---END---
---START---
CREATE VIEW collview2 AS SELECT a, b FROM collate_test1 ORDER BY b COLLATE "C";
---END---
---START---
CREATE VIEW collview3 AS SELECT a, lower((x || x) COLLATE "C") FROM collate_test10;
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
SELECT a, coalesce(b, 'foo') FROM collate_test3 ORDER BY 2;
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
SELECT a, b, greatest(b, 'CCC') FROM collate_test3 ORDER BY 3;
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
SELECT a, nullif(b, 'abc') FROM collate_test3 ORDER BY 2;
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
SELECT a, CASE b WHEN 'abc' THEN 'abcd' ELSE b END FROM collate_test3 ORDER BY 2;
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
SELECT a, b::testdomain FROM collate_test3 ORDER BY 2;
---END---
---START---
SELECT a, b::testdomain_sv FROM collate_test3 ORDER BY 2;
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
SELECT min(b), max(b) FROM collate_test3;
---END---
---START---
SELECT array_agg(b ORDER BY b) FROM collate_test1;
---END---
---START---
SELECT array_agg(b ORDER BY b) FROM collate_test2;
---END---
---START---
SELECT array_agg(b ORDER BY b) FROM collate_test3;
---END---
---START---
SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test1 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test2 UNION SELECT a, b FROM collate_test2 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test3 WHERE a < 4 INTERSECT SELECT a, b FROM collate_test3 WHERE a > 1 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test3 EXCEPT SELECT a, b FROM collate_test3 WHERE a < 2 ORDER BY 2;
---END---
---START---
SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test3 ORDER BY 2;
---END---
---START---
-- fail
SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test3;
---END---
---START---
-- ok
SELECT a, b FROM collate_test1 UNION SELECT a, b FROM collate_test3 ORDER BY 2;
---END---
---START---
-- fail
SELECT a, b COLLATE "C" FROM collate_test1 UNION SELECT a, b FROM collate_test3 ORDER BY 2;
---END---
---START---
-- ok
SELECT a, b FROM collate_test1 INTERSECT SELECT a, b FROM collate_test3 ORDER BY 2;
---END---
---START---
-- fail
SELECT a, b FROM collate_test1 EXCEPT SELECT a, b FROM collate_test3 ORDER BY 2;
---END---
---START---
-- fail

CREATE TABLE test_u AS SELECT a, b FROM collate_test1 UNION ALL SELECT a, b FROM collate_test3;
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
   (SELECT x FROM (VALUES('a' COLLATE "en_US"),('b')) t(x)
   UNION ALL
   SELECT (x || 'c') COLLATE "de_DE" FROM foo WHERE length(x) < 10)
SELECT * FROM foo;
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
SELECT a, CAST(b AS varchar) FROM collate_test3 ORDER BY 2;
---END---
---START---
-- propagation of collation in SQL functions (inlined and non-inlined cases)
-- and plpgsql functions too

CREATE FUNCTION mylt (text, text) RETURNS boolean LANGUAGE sql
    AS $$ select $1 < $2 $$;
---END---
---START---
CREATE FUNCTION mylt_noninline (text, text) RETURNS boolean LANGUAGE sql
    AS $$ select $1 < $2 limit 1 $$;
---END---
---START---
CREATE FUNCTION mylt_plpgsql (text, text) RETURNS boolean LANGUAGE plpgsql
    AS $$ begin return $1 < $2; end $$;
---END---
---START---
SELECT a.b AS a, b.b AS b, a.b < b.b AS lt,
       mylt(a.b, b.b), mylt_noninline(a.b, b.b), mylt_plpgsql(a.b, b.b)
FROM collate_test1 a, collate_test1 b
ORDER BY a.b, b.b;
---END---
---START---
SELECT a.b AS a, b.b AS b, a.b < b.b COLLATE "C" AS lt,
       mylt(a.b, b.b COLLATE "C"), mylt_noninline(a.b, b.b COLLATE "C"),
       mylt_plpgsql(a.b, b.b COLLATE "C")
FROM collate_test1 a, collate_test1 b
ORDER BY a.b, b.b;
---END---
---START---
-- collation override in plpgsql

CREATE FUNCTION mylt2 (x text, y text) RETURNS boolean LANGUAGE plpgsql AS $$
declare
  xx text := x;
  yy text := y;
begin
  return xx < yy;
end
$$;
---END---
---START---
SELECT mylt2('a', 'B' collate "en_US") as t, mylt2('a', 'B' collate "C") as f;
---END---
---START---
CREATE OR REPLACE FUNCTION
  mylt2 (x text, y text) RETURNS boolean LANGUAGE plpgsql AS $$
declare
  xx text COLLATE "POSIX" := x;
  yy text := y;
begin
  return xx < yy;
end
$$;
---END---
---START---
SELECT mylt2('a', 'B') as f;
---END---
---START---
SELECT mylt2('a', 'B' collate "C") as fail;
---END---
---START---
-- conflicting collations
SELECT mylt2('a', 'B' collate "POSIX") as f;
---END---
---START---
-- polymorphism

SELECT * FROM unnest((SELECT array_agg(b ORDER BY b) FROM collate_test1)) ORDER BY 1;
---END---
---START---
SELECT * FROM unnest((SELECT array_agg(b ORDER BY b) FROM collate_test2)) ORDER BY 1;
---END---
---START---
SELECT * FROM unnest((SELECT array_agg(b ORDER BY b) FROM collate_test3)) ORDER BY 1;
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
SELECT a, dup(b) FROM collate_test3 ORDER BY 2;
---END---
---START---
-- indexes

CREATE INDEX collate_test1_idx1 ON collate_test1 (b);
---END---
---START---
CREATE INDEX collate_test1_idx2 ON collate_test1 (b COLLATE "C");
---END---
---START---
CREATE INDEX collate_test1_idx3 ON collate_test1 ((b COLLATE "C"));
---END---
---START---
-- this is different grammatically
CREATE INDEX collate_test1_idx4 ON collate_test1 (((b||'foo') COLLATE "POSIX"));
---END---
---START---
CREATE INDEX collate_test1_idx5 ON collate_test1 (a COLLATE "C");
---END---
---START---
-- fail
CREATE INDEX collate_test1_idx6 ON collate_test1 ((a COLLATE "C"));
---END---
---START---
-- fail

SELECT relname, pg_get_indexdef(oid) FROM pg_class WHERE relname LIKE 'collate_test%_idx%' ORDER BY 1;
---END---
---START---
-- schema manipulation commands

CREATE ROLE regress_test_role;
---END---
---START---
CREATE SCHEMA test_schema;
---END---
---START---
-- We need to do this this way to cope with varying names for encodings:
do $$
BEGIN
  EXECUTE 'CREATE COLLATION test0 (locale = ' ||
          quote_literal((SELECT datcollate FROM pg_database WHERE datname = current_database())) || ');';
END
$$;
---END---
---START---
CREATE COLLATION test0 FROM "C";
---END---
---START---
-- fail, duplicate name
CREATE COLLATION IF NOT EXISTS test0 FROM "C";
---END---
---START---
-- ok, skipped
CREATE COLLATION IF NOT EXISTS test0 (locale = 'foo');
---END---
---START---
-- ok, skipped
do $$
BEGIN
  EXECUTE 'CREATE COLLATION test1 (lc_collate = ' ||
          quote_literal((SELECT datcollate FROM pg_database WHERE datname = current_database())) ||
          ', lc_ctype = ' ||
          quote_literal((SELECT datctype FROM pg_database WHERE datname = current_database())) || ');';
END
$$;
---END---
---START---
CREATE COLLATION test3 (lc_collate = 'en_US.utf8');
---END---
---START---
-- fail, need lc_ctype
CREATE COLLATION testx (locale = 'nonsense');
---END---
---START---
-- fail

CREATE COLLATION test4 FROM nonsense;
---END---
---START---
CREATE COLLATION test5 FROM test0;
---END---
---START---
SELECT collname FROM pg_collation WHERE collname LIKE 'test%' ORDER BY 1;
---END---
---START---
ALTER COLLATION test1 RENAME TO test11;
---END---
---START---
ALTER COLLATION test0 RENAME TO test11;
---END---
---START---
-- fail
ALTER COLLATION test1 RENAME TO test22;
---END---
---START---
-- fail

ALTER COLLATION test11 OWNER TO regress_test_role;
---END---
---START---
ALTER COLLATION test11 OWNER TO nonsense;
---END---
---START---
ALTER COLLATION test11 SET SCHEMA test_schema;
---END---
---START---
COMMENT ON COLLATION test0 IS 'US English';
---END---
---START---
SELECT collname, nspname, obj_description(pg_collation.oid, 'pg_collation')
    FROM pg_collation JOIN pg_namespace ON (collnamespace = pg_namespace.oid)
    WHERE collname LIKE 'test%'
    ORDER BY 1;
---END---
---START---
DROP COLLATION test0, test_schema.test11, test5;
---END---
---START---
DROP COLLATION test0;
---END---
---START---
-- fail
DROP COLLATION IF EXISTS test0;
---END---
---START---
SELECT collname FROM pg_collation WHERE collname LIKE 'test%';
---END---
---START---
DROP SCHEMA test_schema;
---END---
---START---
DROP ROLE regress_test_role;
---END---
---START---
-- ALTER

ALTER COLLATION "en_US" REFRESH VERSION;
---END---
---START---
-- also test for database while we are here
SELECT current_database() AS datname \gset
ALTER DATABASE :"datname" REFRESH COLLATION VERSION;
---END---
---START---
-- dependencies

CREATE COLLATION test0 FROM "C";
---END---
---START---
CREATE TABLE collate_dep_test1 (_gemini_pk serial PRIMARY KEY, a integer, b text COLLATE test0);
---END---
---START---
CREATE DOMAIN collate_dep_dom1 AS text COLLATE test0;
---END---
---START---
CREATE TYPE collate_dep_test2 AS (x int, y text COLLATE test0);
---END---
---START---
CREATE VIEW collate_dep_test3 AS SELECT text 'foo' COLLATE test0 AS foo;
---END---
---START---
CREATE TABLE collate_dep_test4t (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
CREATE INDEX collate_dep_test4i ON collate_dep_test4t (b COLLATE test0);
---END---
---START---
DROP COLLATION test0 RESTRICT;
---END---
---START---
-- fail
DROP COLLATION test0 CASCADE;
---END---
---START---
\d collate_dep_test1
\d collate_dep_test2

DROP TABLE collate_dep_test1, collate_dep_test4t;
---END---
---START---
DROP TYPE collate_dep_test2;
---END---
---START---
-- test range types and collations

create type textrange_c as range(subtype=text, collation="C");
---END---
---START---
create type textrange_en_us as range(subtype=text, collation="en_US");
---END---
---START---
select textrange_c('A','Z') @> 'b'::text;
---END---
---START---
select textrange_en_us('A','Z') @> 'b'::text;
---END---
---START---
drop type textrange_c;
---END---
---START---
drop type textrange_en_us;
---END---
---START---
-- standard collations

SELECT * FROM collate_test2 ORDER BY b COLLATE UCS_BASIC;
---END---
---START---
-- nondeterministic collations
-- (not supported with libc provider)

CREATE COLLATION ctest_det (locale = 'en_US.utf8', deterministic = true);
---END---
---START---
CREATE COLLATION ctest_nondet (locale = 'en_US.utf8', deterministic = false);
---END---
---START---
-- cleanup
SET client_min_messages TO warning;
---END---
---START---
DROP SCHEMA collate_tests CASCADE;
---END---
