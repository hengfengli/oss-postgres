---START---
/*
 * This test is for ICU collations.
 */

/* skip test if not UTF8 server encoding or no ICU collations installed */
SELECT getdatabaseencoding() <> 'UTF8' OR
       (SELECT count(*) FROM pg_collation WHERE collprovider = 'i' AND collname <> 'unicode') = 0
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
CREATE TABLE collate_test1 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "en-x-icu" NOT NULL);
---END---
---START---
\d collate_test1

CREATE TABLE collate_test_fail (
    a int,
    b text COLLATE "ja_JP.eucjp-x-icu"
);
---END---
---START---
CREATE TABLE collate_test_fail (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "foo-x-icu");
---END---
---START---
CREATE TABLE collate_test_fail (gemini_pk serial PRIMARY KEY, a integer COLLATE "en-x-icu", b text);
---END---
---START---
CREATE TABLE collate_test_like (gemini_pk serial PRIMARY KEY, LIKE collate_test1);
---END---
---START---
\d collate_test_like

CREATE TABLE collate_test2 (
    a int,
    b text COLLATE "sv-x-icu"
);
---END---
---START---
CREATE TABLE collate_test3 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "C");
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
SELECT * FROM collate_test1 WHERE b COLLATE "C" >= 'bbc' COLLATE "en-x-icu";
---END---
---START---
CREATE DOMAIN testdomain_sv AS text COLLATE "sv-x-icu";
---END---
---START---
CREATE DOMAIN testdomain_i AS int COLLATE "sv-x-icu";
---END---
---START---
CREATE TABLE collate_test4 (gemini_pk serial PRIMARY KEY, a integer, b testdomain_sv);
---END---
---START---
INSERT INTO collate_test4 SELECT * FROM collate_test1;
---END---
---START---
SELECT a, b FROM collate_test4 ORDER BY b;
---END---
---START---
CREATE TABLE collate_test5 (gemini_pk serial PRIMARY KEY, a integer, b testdomain_sv COLLATE "en-x-icu");
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
SELECT 'bbc' COLLATE "en-x-icu" > 'äbc' COLLATE "en-x-icu" AS "true";
---END---
---START---
SELECT 'bbc' COLLATE "sv-x-icu" > 'äbc' COLLATE "sv-x-icu" AS "false";
---END---
---START---
CREATE TABLE collate_test10 (gemini_pk serial PRIMARY KEY, a integer, x text COLLATE "en-x-icu", y text COLLATE "tr-x-icu");
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
SELECT 'Türkiye' COLLATE "en-x-icu" ILIKE '%KI%' AS "true";
---END---
---START---
SELECT 'Türkiye' COLLATE "tr-x-icu" ILIKE '%KI%' AS "false";
---END---
---START---
SELECT 'bıt' ILIKE 'BIT' COLLATE "en-x-icu" AS "false";
---END---
---START---
SELECT 'bıt' ILIKE 'BIT' COLLATE "tr-x-icu" AS "true";
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
CREATE TABLE collate_test6 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE "en-x-icu");
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
SELECT 'Türkiye' COLLATE "en-x-icu" ~* 'KI' AS "true";
---END---
---START---
SELECT 'Türkiye' COLLATE "tr-x-icu" ~* 'KI' AS "true";
---END---
---START---
-- true with ICU

SELECT 'bıt' ~* 'BIT' COLLATE "en-x-icu" AS "false";
---END---
---START---
SELECT 'bıt' ~* 'BIT' COLLATE "tr-x-icu" AS "false";
---END---
---START---
-- false with ICU

-- The following actually exercises the selectivity estimation for ~*.
SELECT relname FROM pg_class WHERE relname ~* '^abc';
---END---
---START---
/* not run by default because it requires tr_TR system locale
-- to_char

SET lc_time TO 'tr_TR';
SELECT to_char(date '2010-04-01', 'DD TMMON YYYY');
SELECT to_char(date '2010-04-01', 'DD TMMON YYYY' COLLATE "tr-x-icu");
*/


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
   (SELECT x FROM (VALUES('a' COLLATE "en-x-icu"),('b')) t(x)
   UNION ALL
   SELECT (x || 'c') COLLATE "de-x-icu" FROM foo WHERE length(x) < 10)
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
SELECT mylt2('a', 'B' collate "en-x-icu") as t, mylt2('a', 'B' collate "C") as f;
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
set enable_seqscan = off;
---END---
---START---
explain (costs off)
select * from collate_test1 where b ilike 'abc';
---END---
---START---
select * from collate_test1 where b ilike 'abc';
---END---
---START---
explain (costs off)
select * from collate_test1 where b ilike 'ABC';
---END---
---START---
select * from collate_test1 where b ilike 'ABC';
---END---
---START---
reset enable_seqscan;
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
SET client_min_messages TO WARNING;
---END---
---START---
SET icu_validation_level = disabled;
---END---
---START---
do $$
BEGIN
  EXECUTE 'CREATE COLLATION test0 (provider = icu, locale = ' ||
          quote_literal((SELECT CASE WHEN datlocprovider='i' THEN daticulocale ELSE datcollate END FROM pg_database WHERE datname = current_database())) || ');';
END
$$;
---END---
---START---
CREATE COLLATION test0 FROM "C";
---END---
---START---
-- fail, duplicate name
do $$
BEGIN
  EXECUTE 'CREATE COLLATION test1 (provider = icu, locale = ' ||
          quote_literal((SELECT CASE WHEN datlocprovider='i' THEN daticulocale ELSE datcollate END FROM pg_database WHERE datname = current_database())) || ');';
END
$$;
---END---
---START---
RESET icu_validation_level;
---END---
---START---
RESET client_min_messages;
---END---
---START---
CREATE COLLATION test3 (provider = icu, lc_collate = 'en_US.utf8');
---END---
---START---
-- fail, needs "locale"
SET icu_validation_level = ERROR;
---END---
---START---
CREATE COLLATION testx (provider = icu, locale = 'nonsense-nowhere');
---END---
---START---
-- fails
CREATE COLLATION testx (provider = icu, locale = '@colStrength=primary;nonsense=yes');
---END---
---START---
-- fails
RESET icu_validation_level;
---END---
---START---
CREATE COLLATION testx (provider = icu, locale = '@colStrength=primary;nonsense=yes');
---END---
---START---
DROP COLLATION testx;
---END---
---START---
CREATE COLLATION testx (provider = icu, locale = 'nonsense-nowhere');
---END---
---START---
DROP COLLATION testx;
---END---
---START---
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

ALTER COLLATION "en-x-icu" REFRESH VERSION;
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
CREATE TABLE collate_dep_test1 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE test0);
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
CREATE TABLE collate_dep_test4t (gemini_pk serial PRIMARY KEY, a integer, b text);
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
create type textrange_en_us as range(subtype=text, collation="en-x-icu");
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
SELECT * FROM collate_test2 ORDER BY b COLLATE UNICODE;
---END---
---START---
-- test ICU collation customization

-- test the attributes handled by icu_set_collation_attributes()

SET client_min_messages=WARNING;
---END---
---START---
CREATE COLLATION testcoll_ignore_accents (provider = icu, locale = '@colStrength=primary;colCaseLevel=yes');
---END---
---START---
RESET client_min_messages;
---END---
---START---
SELECT 'aaá' > 'AAA' COLLATE "und-x-icu", 'aaá' < 'AAA' COLLATE testcoll_ignore_accents;
---END---
---START---
SET client_min_messages=WARNING;
---END---
---START---
CREATE COLLATION testcoll_backwards (provider = icu, locale = '@colBackwards=yes');
---END---
---START---
RESET client_min_messages;
---END---
---START---
SELECT 'coté' < 'côte' COLLATE "und-x-icu", 'coté' > 'côte' COLLATE testcoll_backwards;
---END---
---START---
CREATE COLLATION testcoll_lower_first (provider = icu, locale = '@colCaseFirst=lower');
---END---
---START---
CREATE COLLATION testcoll_upper_first (provider = icu, locale = '@colCaseFirst=upper');
---END---
---START---
SELECT 'aaa' < 'AAA' COLLATE testcoll_lower_first, 'aaa' > 'AAA' COLLATE testcoll_upper_first;
---END---
---START---
CREATE COLLATION testcoll_shifted (provider = icu, locale = '@colAlternate=shifted');
---END---
---START---
SELECT 'de-luge' < 'deanza' COLLATE "und-x-icu", 'de-luge' > 'deanza' COLLATE testcoll_shifted;
---END---
---START---
SET client_min_messages=WARNING;
---END---
---START---
CREATE COLLATION testcoll_numeric (provider = icu, locale = '@colNumeric=yes');
---END---
---START---
RESET client_min_messages;
---END---
---START---
SELECT 'A-21' > 'A-123' COLLATE "und-x-icu", 'A-21' < 'A-123' COLLATE testcoll_numeric;
---END---
---START---
CREATE COLLATION testcoll_error1 (provider = icu, locale = '@colNumeric=lower');
---END---
---START---
-- test that attributes not handled by icu_set_collation_attributes()
-- (handled by ucol_open() directly) also work
CREATE COLLATION testcoll_de_phonebook (provider = icu, locale = 'de@collation=phonebook');
---END---
---START---
SELECT 'Goldmann' < 'Götz' COLLATE "de-x-icu", 'Goldmann' > 'Götz' COLLATE testcoll_de_phonebook;
---END---
---START---
-- rules

CREATE COLLATION testcoll_rules1 (provider = icu, locale = '', rules = '&a < g');
---END---
---START---
CREATE TABLE test7 (gemini_pk serial PRIMARY KEY, a text);
---END---
---START---
-- example from https://unicode-org.github.io/icu/userguide/collation/customization/#syntax
INSERT INTO test7 VALUES ('Abernathy'), ('apple'), ('bird'), ('Boston'), ('Graham'), ('green');
---END---
---START---
SELECT * FROM test7 ORDER BY a COLLATE "en-x-icu";
---END---
---START---
SELECT * FROM test7 ORDER BY a COLLATE testcoll_rules1;
---END---
---START---
DROP TABLE test7;
---END---
---START---
CREATE COLLATION testcoll_rulesx (provider = icu, locale = '', rules = '!!wrong!!');
---END---
---START---
-- nondeterministic collations

CREATE COLLATION ctest_det (provider = icu, locale = '', deterministic = true);
---END---
---START---
CREATE COLLATION ctest_nondet (provider = icu, locale = '', deterministic = false);
---END---
---START---
CREATE TABLE test6 (gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
-- same string in different normal forms
INSERT INTO test6 VALUES (1, U&'\00E4bc');
---END---
---START---
INSERT INTO test6 VALUES (2, U&'\0061\0308bc');
---END---
---START---
SELECT * FROM test6;
---END---
---START---
SELECT * FROM test6 WHERE b = 'äbc' COLLATE ctest_det;
---END---
---START---
SELECT * FROM test6 WHERE b = 'äbc' COLLATE ctest_nondet;
---END---
---START---
CREATE TABLE test6a (gemini_pk serial PRIMARY KEY, a integer, b text[]);
---END---
---START---
INSERT INTO test6a VALUES (1, ARRAY[U&'\00E4bc']);
---END---
---START---
INSERT INTO test6a VALUES (2, ARRAY[U&'\0061\0308bc']);
---END---
---START---
SELECT * FROM test6a;
---END---
---START---
SELECT * FROM test6a WHERE b = ARRAY['äbc'] COLLATE ctest_det;
---END---
---START---
SELECT * FROM test6a WHERE b = ARRAY['äbc'] COLLATE ctest_nondet;
---END---
---START---
CREATE COLLATION case_sensitive (provider = icu, locale = '');
---END---
---START---
CREATE COLLATION case_insensitive (provider = icu, locale = '@colStrength=secondary', deterministic = false);
---END---
---START---
SELECT 'abc' <= 'ABC' COLLATE case_sensitive, 'abc' >= 'ABC' COLLATE case_sensitive;
---END---
---START---
SELECT 'abc' <= 'ABC' COLLATE case_insensitive, 'abc' >= 'ABC' COLLATE case_insensitive;
---END---
---START---
-- test language tags
CREATE COLLATION lt_insensitive (provider = icu, locale = 'en-u-ks-level1', deterministic = false);
---END---
---START---
SELECT 'aBcD' COLLATE lt_insensitive = 'AbCd' COLLATE lt_insensitive;
---END---
---START---
CREATE COLLATION lt_upperfirst (provider = icu, locale = 'und-u-kf-upper');
---END---
---START---
SELECT 'Z' COLLATE lt_upperfirst < 'z' COLLATE lt_upperfirst;
---END---
---START---
CREATE TABLE test1cs (gemini_pk serial PRIMARY KEY, x text COLLATE case_sensitive);
---END---
---START---
CREATE TABLE test2cs (gemini_pk serial PRIMARY KEY, x text COLLATE case_sensitive);
---END---
---START---
CREATE TABLE test3cs (gemini_pk serial PRIMARY KEY, x text COLLATE case_sensitive);
---END---
---START---
INSERT INTO test1cs VALUES ('abc'), ('def'), ('ghi');
---END---
---START---
INSERT INTO test2cs VALUES ('ABC'), ('ghi');
---END---
---START---
INSERT INTO test3cs VALUES ('abc'), ('ABC'), ('def'), ('ghi');
---END---
---START---
SELECT x FROM test3cs WHERE x = 'abc';
---END---
---START---
SELECT x FROM test3cs WHERE x <> 'abc';
---END---
---START---
SELECT x FROM test3cs WHERE x LIKE 'a%';
---END---
---START---
SELECT x FROM test3cs WHERE x ILIKE 'a%';
---END---
---START---
SELECT x FROM test3cs WHERE x SIMILAR TO 'a%';
---END---
---START---
SELECT x FROM test3cs WHERE x ~ 'a';
---END---
---START---
SELECT x FROM test1cs UNION SELECT x FROM test2cs ORDER BY x;
---END---
---START---
SELECT x FROM test2cs UNION SELECT x FROM test1cs ORDER BY x;
---END---
---START---
SELECT x FROM test1cs INTERSECT SELECT x FROM test2cs;
---END---
---START---
SELECT x FROM test2cs INTERSECT SELECT x FROM test1cs;
---END---
---START---
SELECT x FROM test1cs EXCEPT SELECT x FROM test2cs;
---END---
---START---
SELECT x FROM test2cs EXCEPT SELECT x FROM test1cs;
---END---
---START---
SELECT DISTINCT x FROM test3cs ORDER BY x;
---END---
---START---
SELECT count(DISTINCT x) FROM test3cs;
---END---
---START---
SELECT x, count(*) FROM test3cs GROUP BY x ORDER BY x;
---END---
---START---
SELECT x, row_number() OVER (ORDER BY x), rank() OVER (ORDER BY x) FROM test3cs ORDER BY x;
---END---
---START---
CREATE UNIQUE INDEX ON test1cs (x);
---END---
---START---
-- ok
INSERT INTO test1cs VALUES ('ABC');
---END---
---START---
-- ok
CREATE UNIQUE INDEX ON test3cs (x);
---END---
---START---
-- ok
SELECT string_to_array('ABC,DEF,GHI' COLLATE case_sensitive, ',', 'abc');
---END---
---START---
SELECT string_to_array('ABCDEFGHI' COLLATE case_sensitive, NULL, 'b');
---END---
---START---
CREATE TABLE test1ci (gemini_pk serial PRIMARY KEY, x text COLLATE case_insensitive);
---END---
---START---
CREATE TABLE test2ci (gemini_pk serial PRIMARY KEY, x text COLLATE case_insensitive);
---END---
---START---
CREATE TABLE test3ci (gemini_pk serial PRIMARY KEY, x text COLLATE case_insensitive);
---END---
---START---
CREATE INDEX ON test3ci (x text_pattern_ops);
---END---
---START---
-- error
INSERT INTO test1ci VALUES ('abc'), ('def'), ('ghi');
---END---
---START---
INSERT INTO test2ci VALUES ('ABC'), ('ghi');
---END---
---START---
INSERT INTO test3ci VALUES ('abc'), ('ABC'), ('def'), ('ghi');
---END---
---START---
SELECT x FROM test3ci WHERE x = 'abc';
---END---
---START---
SELECT x FROM test3ci WHERE x <> 'abc';
---END---
---START---
SELECT x FROM test3ci WHERE x LIKE 'a%';
---END---
---START---
SELECT x FROM test3ci WHERE x ILIKE 'a%';
---END---
---START---
SELECT x FROM test3ci WHERE x SIMILAR TO 'a%';
---END---
---START---
SELECT x FROM test3ci WHERE x ~ 'a';
---END---
---START---
SELECT x FROM test1ci UNION SELECT x FROM test2ci ORDER BY x;
---END---
---START---
SELECT x FROM test2ci UNION SELECT x FROM test1ci ORDER BY x;
---END---
---START---
SELECT x FROM test1ci INTERSECT SELECT x FROM test2ci ORDER BY x;
---END---
---START---
SELECT x FROM test2ci INTERSECT SELECT x FROM test1ci ORDER BY x;
---END---
---START---
SELECT x FROM test1ci EXCEPT SELECT x FROM test2ci;
---END---
---START---
SELECT x FROM test2ci EXCEPT SELECT x FROM test1ci;
---END---
---START---
SELECT DISTINCT x FROM test3ci ORDER BY x;
---END---
---START---
SELECT count(DISTINCT x) FROM test3ci;
---END---
---START---
SELECT x, count(*) FROM test3ci GROUP BY x ORDER BY x;
---END---
---START---
SELECT x, row_number() OVER (ORDER BY x), rank() OVER (ORDER BY x) FROM test3ci ORDER BY x;
---END---
---START---
CREATE UNIQUE INDEX ON test1ci (x);
---END---
---START---
-- ok
INSERT INTO test1ci VALUES ('ABC');
---END---
---START---
-- error
CREATE UNIQUE INDEX ON test3ci (x);
---END---
---START---
-- error
SELECT string_to_array('ABC,DEF,GHI' COLLATE case_insensitive, ',', 'abc');
---END---
---START---
SELECT string_to_array('ABCDEFGHI' COLLATE case_insensitive, NULL, 'b');
---END---
---START---
CREATE TABLE test1bpci (gemini_pk serial PRIMARY KEY, x char(3) COLLATE case_insensitive);
---END---
---START---
CREATE TABLE test2bpci (gemini_pk serial PRIMARY KEY, x char(3) COLLATE case_insensitive);
---END---
---START---
CREATE TABLE test3bpci (gemini_pk serial PRIMARY KEY, x char(3) COLLATE case_insensitive);
---END---
---START---
CREATE INDEX ON test3bpci (x bpchar_pattern_ops);
---END---
---START---
-- error
INSERT INTO test1bpci VALUES ('abc'), ('def'), ('ghi');
---END---
---START---
INSERT INTO test2bpci VALUES ('ABC'), ('ghi');
---END---
---START---
INSERT INTO test3bpci VALUES ('abc'), ('ABC'), ('def'), ('ghi');
---END---
---START---
SELECT x FROM test3bpci WHERE x = 'abc';
---END---
---START---
SELECT x FROM test3bpci WHERE x <> 'abc';
---END---
---START---
SELECT x FROM test3bpci WHERE x LIKE 'a%';
---END---
---START---
SELECT x FROM test3bpci WHERE x ILIKE 'a%';
---END---
---START---
SELECT x FROM test3bpci WHERE x SIMILAR TO 'a%';
---END---
---START---
SELECT x FROM test3bpci WHERE x ~ 'a';
---END---
---START---
SELECT x FROM test1bpci UNION SELECT x FROM test2bpci ORDER BY x;
---END---
---START---
SELECT x FROM test2bpci UNION SELECT x FROM test1bpci ORDER BY x;
---END---
---START---
SELECT x FROM test1bpci INTERSECT SELECT x FROM test2bpci ORDER BY x;
---END---
---START---
SELECT x FROM test2bpci INTERSECT SELECT x FROM test1bpci ORDER BY x;
---END---
---START---
SELECT x FROM test1bpci EXCEPT SELECT x FROM test2bpci;
---END---
---START---
SELECT x FROM test2bpci EXCEPT SELECT x FROM test1bpci;
---END---
---START---
SELECT DISTINCT x FROM test3bpci ORDER BY x;
---END---
---START---
SELECT count(DISTINCT x) FROM test3bpci;
---END---
---START---
SELECT x, count(*) FROM test3bpci GROUP BY x ORDER BY x;
---END---
---START---
SELECT x, row_number() OVER (ORDER BY x), rank() OVER (ORDER BY x) FROM test3bpci ORDER BY x;
---END---
---START---
CREATE UNIQUE INDEX ON test1bpci (x);
---END---
---START---
-- ok
INSERT INTO test1bpci VALUES ('ABC');
---END---
---START---
-- error
CREATE UNIQUE INDEX ON test3bpci (x);
---END---
---START---
-- error
SELECT string_to_array('ABC,DEF,GHI'::char(11) COLLATE case_insensitive, ',', 'abc');
---END---
---START---
SELECT string_to_array('ABCDEFGHI'::char(9) COLLATE case_insensitive, NULL, 'b');
---END---
---START---
CREATE TABLE test4c (gemini_pk serial PRIMARY KEY, x text COLLATE "C");
---END---
---START---
INSERT INTO test4c VALUES ('abc');
---END---
---START---
CREATE INDEX ON test4c (x);
---END---
---START---
SET enable_seqscan = off;
---END---
---START---
SELECT x FROM test4c WHERE x LIKE 'ABC' COLLATE case_sensitive;
---END---
---START---
-- ok, no rows
SELECT x FROM test4c WHERE x LIKE 'ABC%' COLLATE case_sensitive;
---END---
---START---
-- ok, no rows
SELECT x FROM test4c WHERE x LIKE 'ABC' COLLATE case_insensitive;
---END---
---START---
-- error
SELECT x FROM test4c WHERE x LIKE 'ABC%' COLLATE case_insensitive;
---END---
---START---
-- error
RESET enable_seqscan;
---END---
---START---
-- Unicode special case: different variants of Greek lower case sigma.
-- A naive implementation like citext that just does lower(x) =
-- lower(y) will do the wrong thing here, because lower('Σ') is 'σ'
-- but upper('ς') is 'Σ'.
SELECT 'ὀδυσσεύς' = 'ὈΔΥΣΣΕΎΣ' COLLATE case_sensitive;
---END---
---START---
SELECT 'ὀδυσσεύς' = 'ὈΔΥΣΣΕΎΣ' COLLATE case_insensitive;
---END---
---START---
-- name vs. text comparison operators
SELECT relname FROM pg_class WHERE relname = 'PG_CLASS'::text COLLATE case_insensitive;
---END---
---START---
SELECT relname FROM pg_class WHERE 'PG_CLASS'::text = relname COLLATE case_insensitive;
---END---
---START---
SELECT typname FROM pg_type WHERE typname LIKE 'int_' AND typname <> 'INT2'::text
  COLLATE case_insensitive ORDER BY typname;
---END---
---START---
SELECT typname FROM pg_type WHERE typname LIKE 'int_' AND 'INT2'::text <> typname
  COLLATE case_insensitive ORDER BY typname;
---END---
---START---
-- test case adapted from subselect.sql
DROP TABLE IF EXISTS outer_text;

CREATE TABLE outer_text (gemini_pk serial PRIMARY KEY, f1 text COLLATE case_insensitive, f2 text);
---END---
---START---
INSERT INTO outer_text VALUES ('a', 'a');
---END---
---START---
INSERT INTO outer_text VALUES ('b', 'a');
---END---
---START---
INSERT INTO outer_text VALUES ('A', NULL);
---END---
---START---
INSERT INTO outer_text VALUES ('B', NULL);
---END---
---START---
DROP TABLE IF EXISTS inner_text;

CREATE TABLE inner_text (gemini_pk serial PRIMARY KEY, c1 text COLLATE case_insensitive, c2 text);
---END---
---START---
INSERT INTO inner_text VALUES ('a', NULL);
---END---
---START---
SELECT * FROM outer_text WHERE (f1, f2) NOT IN (SELECT * FROM inner_text);
---END---
---START---
-- accents
SET client_min_messages=WARNING;
---END---
---START---
CREATE COLLATION ignore_accents (provider = icu, locale = '@colStrength=primary;colCaseLevel=yes', deterministic = false);
---END---
---START---
RESET client_min_messages;
---END---
---START---
CREATE TABLE test4 (gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
INSERT INTO test4 VALUES (1, 'cote'), (2, 'côte'), (3, 'coté'), (4, 'côté');
---END---
---START---
SELECT * FROM test4 WHERE b = 'cote';
---END---
---START---
SELECT * FROM test4 WHERE b = 'cote' COLLATE ignore_accents;
---END---
---START---
SELECT * FROM test4 WHERE b = 'Cote' COLLATE ignore_accents;
---END---
---START---
-- still case-sensitive
SELECT * FROM test4 WHERE b = 'Cote' COLLATE case_insensitive;
---END---
---START---
-- foreign keys (should use collation of primary key)

-- PK is case-sensitive, FK is case-insensitive
CREATE TABLE test10pk (x text COLLATE case_sensitive PRIMARY KEY);
---END---
---START---
INSERT INTO test10pk VALUES ('abc'), ('def'), ('ghi');
---END---
---START---
CREATE TABLE test10fk (gemini_pk serial PRIMARY KEY, x text COLLATE case_insensitive REFERENCES test10pk (x) ON DELETE CASCADE ON UPDATE CASCADE);
---END---
---START---
INSERT INTO test10fk VALUES ('abc');
---END---
---START---
-- ok
INSERT INTO test10fk VALUES ('ABC');
---END---
---START---
-- error
INSERT INTO test10fk VALUES ('xyz');
---END---
---START---
-- error
SELECT * FROM test10pk;
---END---
---START---
SELECT * FROM test10fk;
---END---
---START---
-- restrict update even though the values are "equal" in the FK table
UPDATE test10fk SET x = 'ABC' WHERE x = 'abc';
---END---
---START---
-- error
SELECT * FROM test10fk;
---END---
---START---
DELETE FROM test10pk WHERE x = 'abc';
---END---
---START---
SELECT * FROM test10pk;
---END---
---START---
SELECT * FROM test10fk;
---END---
---START---
-- PK is case-insensitive, FK is case-sensitive
CREATE TABLE test11pk (x text COLLATE case_insensitive PRIMARY KEY);
---END---
---START---
INSERT INTO test11pk VALUES ('abc'), ('def'), ('ghi');
---END---
---START---
CREATE TABLE test11fk (gemini_pk serial PRIMARY KEY, x text COLLATE case_sensitive REFERENCES test11pk (x) ON DELETE CASCADE ON UPDATE CASCADE);
---END---
---START---
INSERT INTO test11fk VALUES ('abc');
---END---
---START---
-- ok
INSERT INTO test11fk VALUES ('ABC');
---END---
---START---
-- ok
INSERT INTO test11fk VALUES ('xyz');
---END---
---START---
-- error
SELECT * FROM test11pk;
---END---
---START---
SELECT * FROM test11fk;
---END---
---START---
-- cascade update even though the values are "equal" in the PK table
UPDATE test11pk SET x = 'ABC' WHERE x = 'abc';
---END---
---START---
SELECT * FROM test11fk;
---END---
---START---
DELETE FROM test11pk WHERE x = 'abc';
---END---
---START---
SELECT * FROM test11pk;
---END---
---START---
SELECT * FROM test11fk;
---END---
---START---
CREATE TABLE test20 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE case_insensitive) PARTITION BY list (b);
---END---
---START---
CREATE TABLE test20_1 PARTITION OF test20 FOR VALUES IN ('abc');
---END---
---START---
INSERT INTO test20 VALUES (1, 'abc');
---END---
---START---
INSERT INTO test20 VALUES (2, 'ABC');
---END---
---START---
SELECT * FROM test20_1;
---END---
---START---
CREATE TABLE test21 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE case_insensitive) PARTITION BY range (b);
---END---
---START---
CREATE TABLE test21_1 PARTITION OF test21 FOR VALUES FROM ('ABC') TO ('DEF');
---END---
---START---
INSERT INTO test21 VALUES (1, 'abc');
---END---
---START---
INSERT INTO test21 VALUES (2, 'ABC');
---END---
---START---
SELECT * FROM test21_1;
---END---
---START---
CREATE TABLE test22 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE case_sensitive) PARTITION BY hash (b);
---END---
---START---
CREATE TABLE test22_0 PARTITION OF test22 FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE test22_1 PARTITION OF test22 FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO test22 VALUES (1, 'def');
---END---
---START---
INSERT INTO test22 VALUES (2, 'DEF');
---END---
---START---
-- they end up in different partitions
SELECT (SELECT count(*) FROM test22_0) = (SELECT count(*) FROM test22_1);
---END---
---START---
CREATE TABLE test22a (gemini_pk serial PRIMARY KEY, a integer, b text[] COLLATE case_sensitive) PARTITION BY hash (b);
---END---
---START---
CREATE TABLE test22a_0 PARTITION OF test22a FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE test22a_1 PARTITION OF test22a FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO test22a VALUES (1, ARRAY['def']);
---END---
---START---
INSERT INTO test22a VALUES (2, ARRAY['DEF']);
---END---
---START---
-- they end up in different partitions
SELECT (SELECT count(*) FROM test22a_0) = (SELECT count(*) FROM test22a_1);
---END---
---START---
CREATE TABLE test23 (gemini_pk serial PRIMARY KEY, a integer, b text COLLATE case_insensitive) PARTITION BY hash (b);
---END---
---START---
CREATE TABLE test23_0 PARTITION OF test23 FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE test23_1 PARTITION OF test23 FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO test23 VALUES (1, 'def');
---END---
---START---
INSERT INTO test23 VALUES (2, 'DEF');
---END---
---START---
-- they end up in the same partition (but it's platform-dependent which one)
SELECT (SELECT count(*) FROM test23_0) <> (SELECT count(*) FROM test23_1);
---END---
---START---
CREATE TABLE test23a (gemini_pk serial PRIMARY KEY, a integer, b text[] COLLATE case_insensitive) PARTITION BY hash (b);
---END---
---START---
CREATE TABLE test23a_0 PARTITION OF test23a FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE test23a_1 PARTITION OF test23a FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO test23a VALUES (1, ARRAY['def']);
---END---
---START---
INSERT INTO test23a VALUES (2, ARRAY['DEF']);
---END---
---START---
-- they end up in the same partition (but it's platform-dependent which one)
SELECT (SELECT count(*) FROM test23a_0) <> (SELECT count(*) FROM test23a_1);
---END---
---START---
CREATE TABLE test30 (gemini_pk serial PRIMARY KEY, a integer, b char(3) COLLATE case_insensitive) PARTITION BY list (b);
---END---
---START---
CREATE TABLE test30_1 PARTITION OF test30 FOR VALUES IN ('abc');
---END---
---START---
INSERT INTO test30 VALUES (1, 'abc');
---END---
---START---
INSERT INTO test30 VALUES (2, 'ABC');
---END---
---START---
SELECT * FROM test30_1;
---END---
---START---
CREATE TABLE test31 (gemini_pk serial PRIMARY KEY, a integer, b char(3) COLLATE case_insensitive) PARTITION BY range (b);
---END---
---START---
CREATE TABLE test31_1 PARTITION OF test31 FOR VALUES FROM ('ABC') TO ('DEF');
---END---
---START---
INSERT INTO test31 VALUES (1, 'abc');
---END---
---START---
INSERT INTO test31 VALUES (2, 'ABC');
---END---
---START---
SELECT * FROM test31_1;
---END---
---START---
CREATE TABLE test32 (gemini_pk serial PRIMARY KEY, a integer, b char(3) COLLATE case_sensitive) PARTITION BY hash (b);
---END---
---START---
CREATE TABLE test32_0 PARTITION OF test32 FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE test32_1 PARTITION OF test32 FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO test32 VALUES (1, 'def');
---END---
---START---
INSERT INTO test32 VALUES (2, 'DEF');
---END---
---START---
-- they end up in different partitions
SELECT (SELECT count(*) FROM test32_0) = (SELECT count(*) FROM test32_1);
---END---
---START---
CREATE TABLE test33 (gemini_pk serial PRIMARY KEY, a integer, b char(3) COLLATE case_insensitive) PARTITION BY hash (b);
---END---
---START---
CREATE TABLE test33_0 PARTITION OF test33 FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE test33_1 PARTITION OF test33 FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO test33 VALUES (1, 'def');
---END---
---START---
INSERT INTO test33 VALUES (2, 'DEF');
---END---
---START---
-- they end up in the same partition (but it's platform-dependent which one)
SELECT (SELECT count(*) FROM test33_0) <> (SELECT count(*) FROM test33_1);
---END---
---START---
-- cleanup
RESET search_path;
---END---
---START---
SET client_min_messages TO warning;
---END---
---START---
DROP SCHEMA collate_tests CASCADE;
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- leave a collation for pg_upgrade test
CREATE COLLATION coll_icu_upgrade FROM "und-x-icu";
---END---
