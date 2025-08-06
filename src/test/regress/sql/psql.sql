---START---
--
-- Tests for psql features that aren't closely connected to any
-- specific server features
--

-- \set

-- fail: invalid name
\set invalid/name foo
-- fail: invalid value for special variable
\set AUTOCOMMIT foo
\set FETCH_COUNT foo
-- check handling of built-in boolean variable
\echo :ON_ERROR_ROLLBACK
\set ON_ERROR_ROLLBACK
\echo :ON_ERROR_ROLLBACK
\set ON_ERROR_ROLLBACK foo
\echo :ON_ERROR_ROLLBACK
\set ON_ERROR_ROLLBACK on
\echo :ON_ERROR_ROLLBACK
\unset ON_ERROR_ROLLBACK
\echo :ON_ERROR_ROLLBACK

-- \g and \gx

SELECT 1 as one, 2 as two \g
\gx
SELECT 3 as three, 4 as four \gx
\g

-- \gx should work in FETCH_COUNT mode too
\set FETCH_COUNT 1

SELECT 1 as one, 2 as two \g
\gx
SELECT 3 as three, 4 as four \gx
\g

\unset FETCH_COUNT

-- \g/\gx with pset options

SELECT 1 as one, 2 as two \g (format=csv csv_fieldsep='\t')
\g
SELECT 1 as one, 2 as two \gx (title='foo bar')
\g

-- \bind (extended query protocol)

SELECT 1 \bind \g
SELECT $1 \bind 'foo' \g
SELECT $1, $2 \bind 'foo' 'bar' \g

-- errors
-- parse error
SELECT foo \bind \g
-- tcop error
SELECT 1 \; SELECT 2 \bind \g
-- bind error
SELECT $1, $2 \bind 'foo' \g

-- \gset

select 10 as test01, 20 as test02, 'Hello' as test03 \gset pref01_

\echo :pref01_test01 :pref01_test02 :pref01_test03

-- should fail: bad variable name
select 10 as "bad name"
\gset

select 97 as "EOF", 'ok' as _foo \gset IGNORE
\echo :IGNORE_foo :IGNOREEOF

-- multiple backslash commands in one line
select 1 as x, 2 as y \gset pref01_ \\ \echo :pref01_x
select 3 as x, 4 as y \gset pref01_ \echo :pref01_x \echo :pref01_y
select 5 as x, 6 as y \gset pref01_ \\ \g \echo :pref01_x :pref01_y
select 7 as x, 8 as y \g \gset pref01_ \echo :pref01_x :pref01_y

-- NULL should unset the variable
\set var2 xyz
select 1 as var1, NULL as var2, 3 as var3 \gset
\echo :var1 :var2 :var3

-- \gset requires just one tuple
select 10 as test01, 20 as test02 from generate_series(1,3) \gset
select 10 as test01, 20 as test02 from generate_series(1,0) \gset

-- \gset should work in FETCH_COUNT mode too
\set FETCH_COUNT 1

select 1 as x, 2 as y \gset pref01_ \\ \echo :pref01_x
select 3 as x, 4 as y \gset pref01_ \echo :pref01_x \echo :pref01_y
select 10 as test01, 20 as test02 from generate_series(1,3) \gset
select 10 as test01, 20 as test02 from generate_series(1,0) \gset

\unset FETCH_COUNT

-- \gdesc

SELECT
    NULL AS zero,
    1 AS one,
    2.0 AS two,
    'three' AS three,
    $1 AS four,
    sin($2) as five,
    'foo'::varchar(4) as six,
    CURRENT_DATE AS now
\gdesc

-- should work with tuple-returning utilities, such as EXECUTE
PREPARE test AS SELECT 1 AS first, 2 AS second;
---END---
---START---
EXECUTE test \gdesc
EXPLAIN EXECUTE test \gdesc

-- should fail cleanly - syntax error
SELECT 1 + \gdesc

-- check behavior with empty results
SELECT \gdesc
CREATE TABLE bububu(a int) \gdesc

-- subject command should not have executed
TABLE bububu;  -- fail

-- query buffer should remain unchanged
SELECT 1 AS x, 'Hello', 2 AS y, true AS "dirty\name"
\gdesc
\g

-- all on one line
SELECT 3 AS x, 'Hello', 4 AS y, true AS "dirty\name" \gdesc \g

-- test for server bug #17983 with empty statement in aborted transaction
set search_path = default;
---END---
---START---
begin;
---END---
---START---
bogus;
---END---
---START---
;
---END---
---START---
\gdesc
rollback;
---END---
---START---

-- \gexec

create table gexec_test(a int, b text, c date, d float);
---END---
---START---
select format('create index on gexec_test(%I)', attname)
from pg_attribute
where attrelid = 'gexec_test'::regclass and attnum > 0
order by attnum
\gexec

-- \gexec should work in FETCH_COUNT mode too
-- (though the fetch limit applies to the executed queries not the meta query)
\set FETCH_COUNT 1

select 'select 1 as ones', 'select x.y, x.y*2 as double from generate_series(1,4) as x(y)'
union all
select 'drop table gexec_test', NULL
union all
select 'drop table gexec_test', 'select ''2000-01-01''::date as party_over'
\gexec

\unset FETCH_COUNT

-- \setenv, \getenv

-- ensure MYVAR isn't set
\setenv MYVAR
-- in which case, reading it doesn't change the target
\getenv res MYVAR
\echo :res
-- now set it
\setenv MYVAR 'environment value'
\getenv res MYVAR
\echo :res

-- show all pset options
\pset

-- test multi-line headers, wrapping, and newline indicators
-- in aligned, unaligned, and wrapped formats
prepare q as select array_to_string(array_agg(repeat('x',2*n)),E'\n') as "ab

c", array_to_string(array_agg(repeat('y',20-2*n)),E'\n') as "a
bc" from generate_series(1,10) as n(n) group by n>1 order by n>1;
---END---
---START---

\pset linestyle ascii

\pset expanded off
\pset columns 40

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset expanded on
\pset columns 20

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset linestyle old-ascii

\pset expanded off
\pset columns 40

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset expanded on
\pset columns 20

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

deallocate q;
---END---
---START---

-- test single-line header and data
prepare q as select repeat('x',2*n) as "0123456789abcdef", repeat('y',20-2*n) as "0123456789" from generate_series(1,10) as n;
---END---
---START---

\pset linestyle ascii

\pset expanded off
\pset columns 40

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset expanded on
\pset columns 30

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset expanded on
\pset columns 20

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset linestyle old-ascii

\pset expanded off
\pset columns 40

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset expanded on

\pset border 0
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 1
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

\pset border 2
\pset format unaligned
execute q;
---END---
---START---
\pset format aligned
execute q;
---END---
---START---
\pset format wrapped
execute q;
---END---
---START---

deallocate q;
---END---
---START---

\pset linestyle ascii
\pset border 1

-- support table for output-format tests (useful to create a footer)

create table psql_serial_tab (id serial);
---END---
---START---

-- test header/footer/tuples_only behavior in aligned/unaligned/wrapped cases

\pset format aligned

\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
-- empty table is a special case for this format
select 1 where false;
---END---
---START---

\pset format unaligned

\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

\pset format wrapped

\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

-- check conditional am display
\pset expanded off

CREATE SCHEMA tableam_display;
---END---
---START---
CREATE ROLE regress_display_role;
---END---
---START---
ALTER SCHEMA tableam_display OWNER TO regress_display_role;
---END---
---START---
SET search_path TO tableam_display;
---END---
---START---
CREATE ACCESS METHOD heap_psql TYPE TABLE HANDLER heap_tableam_handler;
---END---
---START---
SET ROLE TO regress_display_role;
---END---
---START---
-- Use only relations with a physical size of zero.
CREATE TABLE tbl_heap_psql(f1 int, f2 char(100)) using heap_psql;
---END---
---START---
CREATE TABLE tbl_heap(f1 int, f2 char(100)) using heap;
---END---
---START---
CREATE VIEW view_heap_psql AS SELECT f1 from tbl_heap_psql;
---END---
---START---
CREATE MATERIALIZED VIEW mat_view_heap_psql USING heap_psql AS SELECT f1 from tbl_heap_psql;
---END---
---START---
\d+ tbl_heap_psql
\d+ tbl_heap
\set HIDE_TABLEAM off
\d+ tbl_heap_psql
\d+ tbl_heap
-- AM is displayed for tables, indexes and materialized views.
\d+
\dt+
\dm+
-- But not for views and sequences.
\dv+
\set HIDE_TABLEAM on
\d+
RESET ROLE;
---END---
---START---
RESET search_path;
---END---
---START---
DROP SCHEMA tableam_display CASCADE;
---END---
---START---
DROP ACCESS METHOD heap_psql;
---END---
---START---
DROP ROLE regress_display_role;
---END---
---START---

-- test numericlocale (as best we can without control of psql's locale)

\pset format aligned
\pset expanded off
\pset numericlocale true

select n, -n as m, n * 111 as x, '1e90'::float8 as f
from generate_series(0,3) n;
---END---
---START---

\pset numericlocale false

-- test asciidoc output format

\pset format asciidoc

\pset border 1
\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

prepare q as
  select 'some|text' as "a|title", '        ' as "empty ", n as int
  from generate_series(1,2) as n;
---END---
---START---

\pset expanded off
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

\pset expanded on
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

deallocate q;
---END---
---START---

-- test csv output format

\pset format csv

\pset border 1
\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

prepare q as
  select 'some"text' as "a""title", E'  <foo>\n<bar>' as "junk",
         '   ' as "empty", n as int
  from generate_series(1,2) as n;
---END---
---START---

\pset expanded off
execute q;
---END---
---START---

\pset expanded on
execute q;
---END---
---START---

deallocate q;
---END---
---START---

-- special cases
\pset expanded off
select 'comma,comma' as comma, 'semi;semi' as semi;
---END---
---START---
\pset csv_fieldsep ';'
select 'comma,comma' as comma, 'semi;semi' as semi;
---END---
---START---
select '\.' as data;
---END---
---START---
\pset csv_fieldsep '.'
select '\' as d1, '' as d2;
---END---
---START---

-- illegal csv separators
\pset csv_fieldsep ''
\pset csv_fieldsep '\0'
\pset csv_fieldsep '\n'
\pset csv_fieldsep '\r'
\pset csv_fieldsep '"'
\pset csv_fieldsep ',,'

\pset csv_fieldsep ','

-- test html output format

\pset format html

\pset border 1
\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

prepare q as
  select 'some"text' as "a&title", E'  <foo>\n<bar>' as "junk",
         '   ' as "empty", n as int
  from generate_series(1,2) as n;
---END---
---START---

\pset expanded off
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset tableattr foobar
execute q;
---END---
---START---
\pset tableattr

\pset expanded on
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset tableattr foobar
execute q;
---END---
---START---
\pset tableattr

deallocate q;
---END---
---START---

-- test latex output format

\pset format latex

\pset border 1
\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

prepare q as
  select 'some\more_text' as "a$title", E'  #<foo>%&^~|\n{bar}' as "junk",
         '   ' as "empty", n as int
  from generate_series(1,2) as n;
---END---
---START---

\pset expanded off
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

\pset border 3
execute q;
---END---
---START---

\pset expanded on
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

\pset border 3
execute q;
---END---
---START---

deallocate q;
---END---
---START---

-- test latex-longtable output format

\pset format latex-longtable

\pset border 1
\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

prepare q as
  select 'some\more_text' as "a$title", E'  #<foo>%&^~|\n{bar}' as "junk",
         '   ' as "empty", n as int
  from generate_series(1,2) as n;
---END---
---START---

\pset expanded off
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

\pset border 3
execute q;
---END---
---START---

\pset tableattr lr
execute q;
---END---
---START---
\pset tableattr

\pset expanded on
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

\pset border 3
execute q;
---END---
---START---

\pset tableattr lr
execute q;
---END---
---START---
\pset tableattr

deallocate q;
---END---
---START---

-- test troff-ms output format

\pset format troff-ms

\pset border 1
\pset expanded off
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false
\pset expanded on
\d psql_serial_tab_id_seq
\pset tuples_only true
\df exp
\pset tuples_only false

prepare q as
  select 'some\text' as "a\title", E'  <foo>\n<bar>' as "junk",
         '   ' as "empty", n as int
  from generate_series(1,2) as n;
---END---
---START---

\pset expanded off
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

\pset expanded on
\pset border 0
execute q;
---END---
---START---

\pset border 1
execute q;
---END---
---START---

\pset border 2
execute q;
---END---
---START---

deallocate q;
---END---
---START---

-- check ambiguous format requests

\pset format a
\pset format l

-- clean up after output format tests

drop table psql_serial_tab;
---END---
---START---

\pset format aligned
\pset expanded off
\pset border 1

-- \echo and allied features

\echo this is a test
\echo -n without newline
\echo with -n newline
\echo '-n' with newline

\set foo bar
\echo foo = :foo

\qecho this is a test
\qecho foo = :foo

\warn this is a test
\warn foo = :foo

-- tests for \if ... \endif

\if true
  select 'okay';
---END---
---START---
  select 'still okay';
---END---
---START---
\else
  not okay;
---END---
---START---
  still not okay
\endif

-- at this point query buffer should still have last valid line
\g

-- \if should work okay on part of a query
select
  \if true
    42
  \else
    (bogus
  \endif
  forty_two;
---END---
---START---

select \if false \\ (bogus \else \\ 42 \endif \\ forty_two;
---END---
---START---

-- test a large nested if using a variety of true-equivalents
\if true
	\if 1
		\if yes
			\if on
				\echo 'all true'
			\else
				\echo 'should not print #1-1'
			\endif
		\else
			\echo 'should not print #1-2'
		\endif
	\else
		\echo 'should not print #1-3'
	\endif
\else
	\echo 'should not print #1-4'
\endif

-- test a variety of false-equivalents in an if/elif/else structure
\if false
	\echo 'should not print #2-1'
\elif 0
	\echo 'should not print #2-2'
\elif no
	\echo 'should not print #2-3'
\elif off
	\echo 'should not print #2-4'
\else
	\echo 'all false'
\endif

-- test true-false elif after initial true branch
\if true
	\echo 'should print #2-5'
\elif true
	\echo 'should not print #2-6'
\elif false
	\echo 'should not print #2-7'
\else
	\echo 'should not print #2-8'
\endif

-- test simple true-then-else
\if true
	\echo 'first thing true'
\else
	\echo 'should not print #3-1'
\endif

-- test simple false-true-else
\if false
	\echo 'should not print #4-1'
\elif true
	\echo 'second thing true'
\else
	\echo 'should not print #5-1'
\endif

-- invalid boolean expressions are false
\if invalid boolean expression
	\echo 'will not print #6-1'
\else
	\echo 'will print anyway #6-2'
\endif

-- test un-matched endif
\endif

-- test un-matched else
\else

-- test un-matched elif
\elif

-- test double-else error
\if true
\else
\else
\endif

-- test elif out-of-order
\if false
\else
\elif
\endif

-- test if-endif matching in a false branch
\if false
    \if false
        \echo 'should not print #7-1'
    \else
        \echo 'should not print #7-2'
    \endif
    \echo 'should not print #7-3'
\else
    \echo 'should print #7-4'
\endif

-- show that vars and backticks are not expanded when ignoring extra args
\set foo bar
\echo :foo :'foo' :"foo"
\pset fieldsep | `nosuchcommand` :foo :'foo' :"foo"

-- show that vars and backticks are not expanded and commands are ignored
-- when in a false if-branch
\set try_to_quit '\\q'
\if false
	:try_to_quit
	\echo `nosuchcommand` :foo :'foo' :"foo"
	\pset fieldsep | `nosuchcommand` :foo :'foo' :"foo"
	\a
	\C arg1
	\c arg1 arg2 arg3 arg4
	\cd arg1
	\conninfo
	\copy arg1 arg2 arg3 arg4 arg5 arg6
	\copyright
	SELECT 1 as one, 2, 3 \crosstabview
	\dt arg1
	\e arg1 arg2
	\ef whole_line
	\ev whole_line
	\echo arg1 arg2 arg3 arg4 arg5
	\echo arg1
	\encoding arg1
	\errverbose
	\f arg1
	\g arg1
	\gx arg1
	\gexec
	SELECT 1 AS one \gset
	\h
	\?
	\html
	\i arg1
	\ir arg1
	\l arg1
	\lo arg1 arg2
	\lo_list
	\o arg1
	\p
	\password arg1
	\prompt arg1 arg2
	\pset arg1 arg2
	\q
	\reset
	\s arg1
	\set arg1 arg2 arg3 arg4 arg5 arg6 arg7
	\setenv arg1 arg2
	\sf whole_line
	\sv whole_line
	\t arg1
	\T arg1
	\timing arg1
	\unset arg1
	\w arg1
	\watch arg1 arg2
	\x arg1
	-- \else here is eaten as part of OT_FILEPIPE argument
	\w |/no/such/file \else
	-- \endif here is eaten as part of whole-line argument
	\! whole_line \endif
	\z
\else
	\echo 'should print #8-1'
\endif

-- :{?...} defined variable test
\set i 1
\if :{?i}
  \echo '#9-1 ok, variable i is defined'
\else
  \echo 'should not print #9-2'
\endif

\if :{?no_such_variable}
  \echo 'should not print #10-1'
\else
  \echo '#10-2 ok, variable no_such_variable is not defined'
\endif

SELECT :{?i} AS i_is_defined;
---END---
---START---

SELECT NOT :{?no_such_var} AS no_such_var_is_not_defined;
---END---
---START---

-- SHOW_CONTEXT

\set SHOW_CONTEXT never
do $$
begin
  raise notice 'foo';
---END---
---START---
  raise exception 'bar';
---END---
---START---
end $$;
---END---
---START---

\set SHOW_CONTEXT errors
do $$
begin
  raise notice 'foo';
---END---
---START---
  raise exception 'bar';
---END---
---START---
end $$;
---END---
---START---

\set SHOW_CONTEXT always
do $$
begin
  raise notice 'foo';
---END---
---START---
  raise exception 'bar';
---END---
---START---
end $$;
---END---
---START---

-- test printing and clearing the query buffer
SELECT 1;
---END---
---START---
\p
SELECT 2 \r
\p
SELECT 3 \p
UNION SELECT 4 \p
UNION SELECT 5
ORDER BY 1;
---END---
---START---
\r
\p

-- tests for special result variables

-- working query, 2 rows selected
SELECT 1 AS stuff UNION SELECT 2;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT

-- syntax error
SELECT 1 UNION;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT
\echo 'last error message:' :LAST_ERROR_MESSAGE
\echo 'last error code:' :LAST_ERROR_SQLSTATE

-- empty query
;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT
-- must have kept previous values
\echo 'last error message:' :LAST_ERROR_MESSAGE
\echo 'last error code:' :LAST_ERROR_SQLSTATE

-- other query error
DROP TABLE this_table_does_not_exist;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT
\echo 'last error message:' :LAST_ERROR_MESSAGE
\echo 'last error code:' :LAST_ERROR_SQLSTATE

-- nondefault verbosity error settings (except verbose, which is too unstable)
\set VERBOSITY terse
SELECT 1 UNION;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'last error message:' :LAST_ERROR_MESSAGE

\set VERBOSITY sqlstate
SELECT 1/0;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'last error message:' :LAST_ERROR_MESSAGE

\set VERBOSITY default

-- working \gdesc
SELECT 3 AS three, 4 AS four \gdesc
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT

-- \gdesc with an error
SELECT 4 AS \gdesc
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT
\echo 'last error message:' :LAST_ERROR_MESSAGE
\echo 'last error code:' :LAST_ERROR_SQLSTATE

-- check row count for a cursor-fetched query
\set FETCH_COUNT 10
select unique2 from tenk1 order by unique2 limit 19;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT

-- cursor-fetched query with an error after the first group
select 1/(15-unique2) from tenk1 order by unique2 limit 19;
---END---
---START---
\echo 'error:' :ERROR
\echo 'error code:' :SQLSTATE
\echo 'number of rows:' :ROW_COUNT
\echo 'last error message:' :LAST_ERROR_MESSAGE
\echo 'last error code:' :LAST_ERROR_SQLSTATE

\unset FETCH_COUNT

create schema testpart;
---END---
---START---
create role regress_partitioning_role;
---END---
---START---

alter schema testpart owner to regress_partitioning_role;
---END---
---START---

set role to regress_partitioning_role;
---END---
---START---

-- run test inside own schema and hide other partitions
set search_path to testpart;
---END---
---START---

create table testtable_apple(logdate date);
---END---
---START---
create table testtable_orange(logdate date);
---END---
---START---
create index testtable_apple_index on testtable_apple(logdate);
---END---
---START---
create index testtable_orange_index on testtable_orange(logdate);
---END---
---START---

create table testpart_apple(logdate date) partition by range(logdate);
---END---
---START---
create table testpart_orange(logdate date) partition by range(logdate);
---END---
---START---

create index testpart_apple_index on testpart_apple(logdate);
---END---
---START---
create index testpart_orange_index on testpart_orange(logdate);
---END---
---START---

-- only partition related object should be displayed
\dP test*apple*
\dPt test*apple*
\dPi test*apple*

drop table testtable_apple;
---END---
---START---
drop table testtable_orange;
---END---
---START---
drop table testpart_apple;
---END---
---START---
drop table testpart_orange;
---END---
---START---

create table parent_tab (id int) partition by range (id);
---END---
---START---
create index parent_index on parent_tab (id);
---END---
---START---
create table child_0_10 partition of parent_tab
  for values from (0) to (10);
---END---
---START---
create table child_10_20 partition of parent_tab
  for values from (10) to (20);
---END---
---START---
create table child_20_30 partition of parent_tab
  for values from (20) to (30);
---END---
---START---
insert into parent_tab values (generate_series(0,29));
---END---
---START---
create table child_30_40 partition of parent_tab
for values from (30) to (40)
  partition by range(id);
---END---
---START---
create table child_30_35 partition of child_30_40
  for values from (30) to (35);
---END---
---START---
create table child_35_40 partition of child_30_40
   for values from (35) to (40);
---END---
---START---
insert into parent_tab values (generate_series(30,39));
---END---
---START---

\dPt
\dPi

\dP testpart.*
\dP

\dPtn
\dPin
\dPn
\dPn testpart.*

drop table parent_tab cascade;
---END---
---START---

drop schema testpart;
---END---
---START---

set search_path to default;
---END---
---START---

set role to default;
---END---
---START---
drop role regress_partitioning_role;
---END---
---START---

-- \d on toast table (use pg_statistic's toast table, which has a known name)
\d pg_toast.pg_toast_2619

-- check printing info about access methods
\dA
\dA *
\dA h*
\dA foo
\dA foo bar
\dA+
\dA+ *
\dA+ h*
\dA+ foo
\dAc brin pg*.oid*
\dAf spgist
\dAf btree int4
\dAo+ btree float_ops
\dAo * pg_catalog.jsonb_path_ops
\dAp+ btree float_ops
\dAp * pg_catalog.uuid_ops

-- check \dconfig
set work_mem = 10240;
---END---
---START---
\dconfig work_mem
\dconfig+ work*
reset work_mem;
---END---
---START---

-- check \df, \do with argument specifications
\df *sqrt
\df *sqrt num*
\df int*pl
\df int*pl int4
\df int*pl * pg_catalog.int8
\df acl* aclitem[]
\df has_database_privilege oid text
\df has_database_privilege oid text -
\dfa bit* small*
\df *._pg_expandarray
\do - pg_catalog.int4
\do && anyarray *

-- check \df+
-- we have to use functions with a predictable owner name, so make a role
create role regress_psql_user superuser;
---END---
---START---
begin;
---END---
---START---
set session authorization regress_psql_user;
---END---
---START---

create function psql_df_internal (float8)
  returns float8
  language internal immutable parallel safe strict
  as 'dsin';
---END---
---START---
create function psql_df_sql (x integer)
  returns integer
  security definer
  begin atomic select x + 1; end;
---END---
---START---
create function psql_df_plpgsql ()
  returns void
  language plpgsql
  as $$ begin return; end; $$;
---END---
---START---
comment on function psql_df_plpgsql () is 'some comment';
---END---
---START---

\df+ psql_df_*
rollback;
---END---
---START---
drop role regress_psql_user;
---END---
---START---

-- check \sf
\sf information_schema._pg_expandarray
\sf+ information_schema._pg_expandarray
\sf+ interval_pl_time
\sf ts_debug(text)
\sf+ ts_debug(text)

-- AUTOCOMMIT

CREATE TABLE ac_test (a int);
---END---
---START---
\set AUTOCOMMIT off

INSERT INTO ac_test VALUES (1);
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM ac_test;
---END---
---START---
COMMIT;
---END---
---START---

INSERT INTO ac_test VALUES (2);
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT * FROM ac_test;
---END---
---START---
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO ac_test VALUES (3);
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM ac_test;
---END---
---START---
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO ac_test VALUES (4);
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT * FROM ac_test;
---END---
---START---
COMMIT;
---END---
---START---

\set AUTOCOMMIT on
DROP TABLE ac_test;
---END---
---START---
SELECT * FROM ac_test;  -- should be gone now

-- ON_ERROR_ROLLBACK

\set ON_ERROR_ROLLBACK on
CREATE TABLE oer_test (a int);
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO oer_test VALUES (1);
---END---
---START---
INSERT INTO oer_test VALUES ('foo');
---END---
---START---
INSERT INTO oer_test VALUES (3);
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM oer_test;
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO oer_test VALUES (4);
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT * FROM oer_test;
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO oer_test VALUES (5);
---END---
---START---
COMMIT AND CHAIN;
---END---
---START---
INSERT INTO oer_test VALUES (6);
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM oer_test;
---END---
---START---

DROP TABLE oer_test;
---END---
---START---
\set ON_ERROR_ROLLBACK off

-- ECHO errors
\set ECHO errors
SELECT * FROM notexists;
---END---
---START---
\set ECHO all

--
-- combined queries
--
CREATE FUNCTION warn(msg TEXT) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
  BEGIN RAISE NOTICE 'warn %', msg ; RETURN TRUE ; END
$$;
---END---
---START---

-- show both
SELECT 1 AS one \; SELECT warn('1.5') \; SELECT 2 AS two ;
---END---
---START---
-- \gset applies to last query only
SELECT 3 AS three \; SELECT warn('3.5') \; SELECT 4 AS four \gset
\echo :three :four
-- syntax error stops all processing
SELECT 5 \; SELECT 6 + \; SELECT warn('6.5') \; SELECT 7 ;
---END---
---START---
-- with aborted transaction, stop on first error
BEGIN \; SELECT 8 AS eight \; SELECT 9/0 AS nine \; ROLLBACK \; SELECT 10 AS ten ;
---END---
---START---
-- close previously aborted transaction
ROLLBACK;
---END---
---START---

-- miscellaneous SQL commands
-- (non SELECT output is sent to stderr, thus is not shown in expected results)
SELECT 'ok' AS "begin" \;
---END---
---START---
CREATE TABLE psql_comics(s TEXT) \;
---END---
---START---
INSERT INTO psql_comics VALUES ('Calvin'), ('hobbes') \;
---END---
---START---
COPY psql_comics FROM STDIN \;
---END---
---START---
UPDATE psql_comics SET s = 'Hobbes' WHERE s = 'hobbes' \;
---END---
---START---
DELETE FROM psql_comics WHERE s = 'Moe' \;
---END---
---START---
COPY psql_comics TO STDOUT \;
---END---
---START---
TRUNCATE psql_comics \;
---END---
---START---
DROP TABLE psql_comics \;
---END---
---START---
SELECT 'ok' AS "done" ;
---END---
---START---
Moe
Susie
\.

\set SHOW_ALL_RESULTS off
SELECT 1 AS one \; SELECT warn('1.5') \; SELECT 2 AS two ;
---END---
---START---

\set SHOW_ALL_RESULTS on
DROP FUNCTION warn(TEXT);
---END---
---START---

--
-- \g with file
--
\getenv abs_builddir PG_ABS_BUILDDIR
\set g_out_file :abs_builddir '/results/psql-output1'

CREATE TABLE reload_output(
  lineno int NOT NULL GENERATED ALWAYS AS IDENTITY,
  line text
);
---END---
---START---

SELECT 1 AS a \g :g_out_file
COPY reload_output(line) FROM :'g_out_file';
---END---
---START---
SELECT 2 AS b\; SELECT 3 AS c\; SELECT 4 AS d \g :g_out_file
COPY reload_output(line) FROM :'g_out_file';
---END---
---START---
COPY (SELECT 'foo') TO STDOUT \; COPY (SELECT 'bar') TO STDOUT \g :g_out_file
COPY reload_output(line) FROM :'g_out_file';
---END---
---START---

SELECT line FROM reload_output ORDER BY lineno;
---END---
---START---
TRUNCATE TABLE reload_output;
---END---
---START---

--
-- \o with file
--
\set o_out_file :abs_builddir '/results/psql-output2'

\o :o_out_file
SELECT max(unique1) FROM onek;
---END---
---START---
SELECT 1 AS a\; SELECT 2 AS b\; SELECT 3 AS c;
---END---
---START---

-- COPY TO file
-- The data goes to :g_out_file and the status to :o_out_file
\set QUIET false
COPY (SELECT unique1 FROM onek ORDER BY unique1 LIMIT 10) TO :'g_out_file';
---END---
---START---
-- DML command status
UPDATE onek SET unique1 = unique1 WHERE false;
---END---
---START---
\set QUIET true
\o

-- Check the contents of the files generated.
COPY reload_output(line) FROM :'g_out_file';
---END---
---START---
SELECT line FROM reload_output ORDER BY lineno;
---END---
---START---
TRUNCATE TABLE reload_output;
---END---
---START---
COPY reload_output(line) FROM :'o_out_file';
---END---
---START---
SELECT line FROM reload_output ORDER BY lineno;
---END---
---START---
TRUNCATE TABLE reload_output;
---END---
---START---

-- Multiple COPY TO STDOUT with output file
\o :o_out_file
-- The data goes to :o_out_file with no status generated.
COPY (SELECT 'foo1') TO STDOUT \; COPY (SELECT 'bar1') TO STDOUT;
---END---
---START---
-- Combination of \o and \g file with multiple COPY queries.
COPY (SELECT 'foo2') TO STDOUT \; COPY (SELECT 'bar2') TO STDOUT \g :g_out_file
\o

-- Check the contents of the files generated.
COPY reload_output(line) FROM :'g_out_file';
---END---
---START---
SELECT line FROM reload_output ORDER BY lineno;
---END---
---START---
TRUNCATE TABLE reload_output;
---END---
---START---
COPY reload_output(line) FROM :'o_out_file';
---END---
---START---
SELECT line FROM reload_output ORDER BY lineno;
---END---
---START---

DROP TABLE reload_output;
---END---
---START---

--
-- AUTOCOMMIT and combined queries
--
\set AUTOCOMMIT off
\echo '# AUTOCOMMIT:' :AUTOCOMMIT
-- BEGIN is now implicit

CREATE TABLE foo(s TEXT) \;
---END---
---START---
ROLLBACK;
---END---
---START---

CREATE TABLE foo(s TEXT) \;
---END---
---START---
INSERT INTO foo(s) VALUES ('hello'), ('world') \;
---END---
---START---
COMMIT;
---END---
---START---

DROP TABLE foo \;
---END---
---START---
ROLLBACK;
---END---
---START---

-- table foo is still there
SELECT * FROM foo ORDER BY 1 \;
---END---
---START---
DROP TABLE foo \;
---END---
---START---
COMMIT;
---END---
---START---

\set AUTOCOMMIT on
\echo '# AUTOCOMMIT:' :AUTOCOMMIT
-- BEGIN now explicit for multi-statement transactions

BEGIN \;
---END---
---START---
CREATE TABLE foo(s TEXT) \;
---END---
---START---
INSERT INTO foo(s) VALUES ('hello'), ('world') \;
---END---
---START---
COMMIT;
---END---
---START---

BEGIN \;
---END---
---START---
DROP TABLE foo \;
---END---
---START---
ROLLBACK \;
---END---
---START---

-- implicit transactions
SELECT * FROM foo ORDER BY 1 \;
---END---
---START---
DROP TABLE foo;
---END---
---START---

--
-- test ON_ERROR_ROLLBACK and combined queries
--
CREATE FUNCTION psql_error(msg TEXT) RETURNS BOOLEAN AS $$
  BEGIN
    RAISE EXCEPTION 'error %', msg;
---END---
---START---
  END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

\set ON_ERROR_ROLLBACK on
\echo '# ON_ERROR_ROLLBACK:' :ON_ERROR_ROLLBACK
\echo '# AUTOCOMMIT:' :AUTOCOMMIT

BEGIN;
---END---
---START---
CREATE TABLE bla(s NO_SUCH_TYPE);               -- fails
CREATE TABLE bla(s TEXT);                       -- succeeds
SELECT psql_error('oops!');                     -- fails
INSERT INTO bla VALUES ('Calvin'), ('Hobbes');
---END---
---START---
COMMIT;
---END---
---START---

SELECT * FROM bla ORDER BY 1;
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO bla VALUES ('Susie');         -- succeeds
-- now with combined queries
INSERT INTO bla VALUES ('Rosalyn') \;     -- will rollback
SELECT 'before error' AS show \;          -- will show nevertheless!
  SELECT psql_error('boum!') \;           -- failure
  SELECT 'after error' AS noshow;         -- hidden by preceding error
INSERT INTO bla(s) VALUES ('Moe') \;      -- will rollback
  SELECT psql_error('bam!');
---END---
---START---
INSERT INTO bla VALUES ('Miss Wormwood'); -- succeeds
COMMIT;
---END---
---START---
SELECT * FROM bla ORDER BY 1;
---END---
---START---

-- some with autocommit off
\set AUTOCOMMIT off
\echo '# AUTOCOMMIT:' :AUTOCOMMIT

-- implicit BEGIN
INSERT INTO bla VALUES ('Dad');           -- succeeds
SELECT psql_error('bad!');                -- implicit partial rollback

INSERT INTO bla VALUES ('Mum') \;         -- will rollback
SELECT COUNT(*) AS "#mum"
FROM bla WHERE s = 'Mum' \;               -- but be counted here
SELECT psql_error('bad!');                -- implicit partial rollback
COMMIT;
---END---
---START---

SELECT COUNT(*) AS "#mum"
FROM bla WHERE s = 'Mum' \;               -- no mum here
SELECT * FROM bla ORDER BY 1;
---END---
---START---

-- reset all
\set AUTOCOMMIT on
\set ON_ERROR_ROLLBACK off
\echo '# final ON_ERROR_ROLLBACK:' :ON_ERROR_ROLLBACK
DROP TABLE bla;
---END---
---START---
DROP FUNCTION psql_error;
---END---
---START---

-- check describing invalid multipart names
\dA regression.heap
\dA nonesuch.heap
\dt host.regression.pg_catalog.pg_class
\dt |.pg_catalog.pg_class
\dt nonesuch.pg_catalog.pg_class
\da host.regression.pg_catalog.sum
\da +.pg_catalog.sum
\da nonesuch.pg_catalog.sum
\dAc nonesuch.brin
\dAc regression.brin
\dAf nonesuch.brin
\dAf regression.brin
\dAo nonesuch.brin
\dAo regression.brin
\dAp nonesuch.brin
\dAp regression.brin
\db nonesuch.pg_default
\db regression.pg_default
\dc host.regression.public.conversion
\dc (.public.conversion
\dc nonesuch.public.conversion
\dC host.regression.pg_catalog.int8
\dC ).pg_catalog.int8
\dC nonesuch.pg_catalog.int8
\dd host.regression.pg_catalog.pg_class
\dd [.pg_catalog.pg_class
\dd nonesuch.pg_catalog.pg_class
\dD host.regression.public.gtestdomain1
\dD ].public.gtestdomain1
\dD nonesuch.public.gtestdomain1
\ddp host.regression.pg_catalog.pg_class
\ddp {.pg_catalog.pg_class
\ddp nonesuch.pg_catalog.pg_class
\dE host.regression.public.ft
\dE }.public.ft
\dE nonesuch.public.ft
\di host.regression.public.tenk1_hundred
\di ..public.tenk1_hundred
\di nonesuch.public.tenk1_hundred
\dm host.regression.public.mvtest_bb
\dm ^.public.mvtest_bb
\dm nonesuch.public.mvtest_bb
\ds host.regression.public.check_seq
\ds regression|mydb.public.check_seq
\ds nonesuch.public.check_seq
\dt host.regression.public.b_star
\dt regres+ion.public.b_star
\dt nonesuch.public.b_star
\dv host.regression.public.shoe
\dv regress(ion).public.shoe
\dv nonesuch.public.shoe
\des nonesuch.server
\des regression.server
\des nonesuch.server
\des regression.server
\des nonesuch.username
\des regression.username
\dew nonesuch.fdw
\dew regression.fdw
\df host.regression.public.namelen
\df regres[qrstuv]ion.public.namelen
\df nonesuch.public.namelen
\dF host.regression.pg_catalog.arabic
\dF regres{1,2}ion.pg_catalog.arabic
\dF nonesuch.pg_catalog.arabic
\dFd host.regression.pg_catalog.arabic_stem
\dFd regres?ion.pg_catalog.arabic_stem
\dFd nonesuch.pg_catalog.arabic_stem
\dFp host.regression.pg_catalog.default
\dFp ^regression.pg_catalog.default
\dFp nonesuch.pg_catalog.default
\dFt host.regression.pg_catalog.ispell
\dFt regression$.pg_catalog.ispell
\dFt nonesuch.pg_catalog.ispell
\dg nonesuch.pg_database_owner
\dg regression.pg_database_owner
\dL host.regression.plpgsql
\dL *.plpgsql
\dL nonesuch.plpgsql
\dn host.regression.public
\dn """".public
\dn nonesuch.public
\do host.regression.public.!=-
\do "regression|mydb".public.!=-
\do nonesuch.public.!=-
\dO host.regression.pg_catalog.POSIX
\dO .pg_catalog.POSIX
\dO nonesuch.pg_catalog.POSIX
\dp host.regression.public.a_star
\dp "regres+ion".public.a_star
\dp nonesuch.public.a_star
\dP host.regression.public.mlparted
\dP "regres(sion)".public.mlparted
\dP nonesuch.public.mlparted
\drds nonesuch.lc_messages
\drds regression.lc_messages
\dRp public.mypub
\dRp regression.mypub
\dRs public.mysub
\dRs regression.mysub
\dT host.regression.public.widget
\dT "regression{1,2}".public.widget
\dT nonesuch.public.widget
\dx regression.plpgsql
\dx nonesuch.plpgsql
\dX host.regression.public.func_deps_stat
\dX "^regression$".public.func_deps_stat
\dX nonesuch.public.func_deps_stat
\dy regression.myevt
\dy nonesuch.myevt

-- check that dots within quoted name segments are not counted
\dA "no.such.access.method"
\dt "no.such.table.relation"
\da "no.such.aggregate.function"
\dAc "no.such.operator.class"
\dAf "no.such.operator.family"
\dAo "no.such.operator.of.operator.family"
\dAp "no.such.operator.support.function.of.operator.family"
\db "no.such.tablespace"
\dc "no.such.conversion"
\dC "no.such.cast"
\dd "no.such.object.description"
\dD "no.such.domain"
\ddp "no.such.default.access.privilege"
\di "no.such.index.relation"
\dm "no.such.materialized.view"
\ds "no.such.relation"
\dt "no.such.relation"
\dv "no.such.relation"
\des "no.such.foreign.server"
\dew "no.such.foreign.data.wrapper"
\df "no.such.function"
\dF "no.such.text.search.configuration"
\dFd "no.such.text.search.dictionary"
\dFp "no.such.text.search.parser"
\dFt "no.such.text.search.template"
\dg "no.such.role"
\dL "no.such.language"
\dn "no.such.schema"
\do "no.such.operator"
\dO "no.such.collation"
\dp "no.such.access.privilege"
\dP "no.such.partitioned.relation"
\drds "no.such.setting"
\dRp "no.such.publication"
\dRs "no.such.subscription"
\dT "no.such.data.type"
\dx "no.such.installed.extension"
\dX "no.such.extended.statistics"
\dy "no.such.event.trigger"

-- again, but with dotted schema qualifications.
\dA "no.such.schema"."no.such.access.method"
\dt "no.such.schema"."no.such.table.relation"
\da "no.such.schema"."no.such.aggregate.function"
\dAc "no.such.schema"."no.such.operator.class"
\dAf "no.such.schema"."no.such.operator.family"
\dAo "no.such.schema"."no.such.operator.of.operator.family"
\dAp "no.such.schema"."no.such.operator.support.function.of.operator.family"
\db "no.such.schema"."no.such.tablespace"
\dc "no.such.schema"."no.such.conversion"
\dC "no.such.schema"."no.such.cast"
\dd "no.such.schema"."no.such.object.description"
\dD "no.such.schema"."no.such.domain"
\ddp "no.such.schema"."no.such.default.access.privilege"
\di "no.such.schema"."no.such.index.relation"
\dm "no.such.schema"."no.such.materialized.view"
\ds "no.such.schema"."no.such.relation"
\dt "no.such.schema"."no.such.relation"
\dv "no.such.schema"."no.such.relation"
\des "no.such.schema"."no.such.foreign.server"
\dew "no.such.schema"."no.such.foreign.data.wrapper"
\df "no.such.schema"."no.such.function"
\dF "no.such.schema"."no.such.text.search.configuration"
\dFd "no.such.schema"."no.such.text.search.dictionary"
\dFp "no.such.schema"."no.such.text.search.parser"
\dFt "no.such.schema"."no.such.text.search.template"
\dg "no.such.schema"."no.such.role"
\dL "no.such.schema"."no.such.language"
\do "no.such.schema"."no.such.operator"
\dO "no.such.schema"."no.such.collation"
\dp "no.such.schema"."no.such.access.privilege"
\dP "no.such.schema"."no.such.partitioned.relation"
\drds "no.such.schema"."no.such.setting"
\dRp "no.such.schema"."no.such.publication"
\dRs "no.such.schema"."no.such.subscription"
\dT "no.such.schema"."no.such.data.type"
\dx "no.such.schema"."no.such.installed.extension"
\dX "no.such.schema"."no.such.extended.statistics"
\dy "no.such.schema"."no.such.event.trigger"

-- again, but with current database and dotted schema qualifications.
\dt regression."no.such.schema"."no.such.table.relation"
\da regression."no.such.schema"."no.such.aggregate.function"
\dc regression."no.such.schema"."no.such.conversion"
\dC regression."no.such.schema"."no.such.cast"
\dd regression."no.such.schema"."no.such.object.description"
\dD regression."no.such.schema"."no.such.domain"
\di regression."no.such.schema"."no.such.index.relation"
\dm regression."no.such.schema"."no.such.materialized.view"
\ds regression."no.such.schema"."no.such.relation"
\dt regression."no.such.schema"."no.such.relation"
\dv regression."no.such.schema"."no.such.relation"
\df regression."no.such.schema"."no.such.function"
\dF regression."no.such.schema"."no.such.text.search.configuration"
\dFd regression."no.such.schema"."no.such.text.search.dictionary"
\dFp regression."no.such.schema"."no.such.text.search.parser"
\dFt regression."no.such.schema"."no.such.text.search.template"
\do regression."no.such.schema"."no.such.operator"
\dO regression."no.such.schema"."no.such.collation"
\dp regression."no.such.schema"."no.such.access.privilege"
\dP regression."no.such.schema"."no.such.partitioned.relation"
\dT regression."no.such.schema"."no.such.data.type"
\dX regression."no.such.schema"."no.such.extended.statistics"

-- again, but with dotted database and dotted schema qualifications.
\dt "no.such.database"."no.such.schema"."no.such.table.relation"
\da "no.such.database"."no.such.schema"."no.such.aggregate.function"
\dc "no.such.database"."no.such.schema"."no.such.conversion"
\dC "no.such.database"."no.such.schema"."no.such.cast"
\dd "no.such.database"."no.such.schema"."no.such.object.description"
\dD "no.such.database"."no.such.schema"."no.such.domain"
\ddp "no.such.database"."no.such.schema"."no.such.default.access.privilege"
\di "no.such.database"."no.such.schema"."no.such.index.relation"
\dm "no.such.database"."no.such.schema"."no.such.materialized.view"
\ds "no.such.database"."no.such.schema"."no.such.relation"
\dt "no.such.database"."no.such.schema"."no.such.relation"
\dv "no.such.database"."no.such.schema"."no.such.relation"
\df "no.such.database"."no.such.schema"."no.such.function"
\dF "no.such.database"."no.such.schema"."no.such.text.search.configuration"
\dFd "no.such.database"."no.such.schema"."no.such.text.search.dictionary"
\dFp "no.such.database"."no.such.schema"."no.such.text.search.parser"
\dFt "no.such.database"."no.such.schema"."no.such.text.search.template"
\do "no.such.database"."no.such.schema"."no.such.operator"
\dO "no.such.database"."no.such.schema"."no.such.collation"
\dp "no.such.database"."no.such.schema"."no.such.access.privilege"
\dP "no.such.database"."no.such.schema"."no.such.partitioned.relation"
\dT "no.such.database"."no.such.schema"."no.such.data.type"
\dX "no.such.database"."no.such.schema"."no.such.extended.statistics"

-- check \drg and \du
CREATE ROLE regress_du_role0;
---END---
---START---
CREATE ROLE regress_du_role1;
---END---
---START---
CREATE ROLE regress_du_role2;
---END---
---START---
CREATE ROLE regress_du_admin;
---END---
---START---

GRANT regress_du_role0 TO regress_du_admin WITH ADMIN TRUE;
---END---
---START---
GRANT regress_du_role1 TO regress_du_admin WITH ADMIN TRUE;
---END---
---START---
GRANT regress_du_role2 TO regress_du_admin WITH ADMIN TRUE;
---END---
---START---

GRANT regress_du_role0 TO regress_du_role1 WITH ADMIN TRUE,  INHERIT TRUE,  SET TRUE  GRANTED BY regress_du_admin;
---END---
---START---
GRANT regress_du_role0 TO regress_du_role2 WITH ADMIN TRUE,  INHERIT FALSE, SET FALSE GRANTED BY regress_du_admin;
---END---
---START---
GRANT regress_du_role1 TO regress_du_role2 WITH ADMIN TRUE , INHERIT FALSE, SET TRUE  GRANTED BY regress_du_admin;
---END---
---START---
GRANT regress_du_role0 TO regress_du_role1 WITH ADMIN FALSE, INHERIT TRUE,  SET FALSE GRANTED BY regress_du_role1;
---END---
---START---
GRANT regress_du_role0 TO regress_du_role2 WITH ADMIN FALSE, INHERIT TRUE , SET TRUE  GRANTED BY regress_du_role1;
---END---
---START---
GRANT regress_du_role0 TO regress_du_role1 WITH ADMIN FALSE, INHERIT FALSE, SET TRUE  GRANTED BY regress_du_role2;
---END---
---START---
GRANT regress_du_role0 TO regress_du_role2 WITH ADMIN FALSE, INHERIT FALSE, SET FALSE GRANTED BY regress_du_role2;
---END---
---START---

\drg regress_du_role*
\du regress_du_role*

DROP ROLE regress_du_role0;
---END---
---START---
DROP ROLE regress_du_role1;
---END---
---START---
DROP ROLE regress_du_role2;
---END---
---START---
DROP ROLE regress_du_admin;
---END---
---START---
drop table if exists gexec_test, reload_output;
---END---