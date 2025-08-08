---START---
--
-- ROWTYPES
--

-- Make both a standalone composite type and a table rowtype

create type complex as (r float8, i float8);
---END---
---START---
DROP TABLE IF EXISTS fullname;

CREATE TABLE fullname (_gemini_pk serial PRIMARY KEY, first text, last text);
---END---
---START---
-- Nested composite

create type quad as (c1 complex, c2 complex);
---END---
---START---
-- Some simple tests of I/O conversions and row construction

select (1.1,2.2)::complex, row((3.3,4.4),(5.5,null))::quad;
---END---
---START---
select row('Joe', 'Blow')::fullname, '(Joe,Blow)'::fullname;
---END---
---START---
select '(Joe,von Blow)'::fullname, '(Joe,d''Blow)'::fullname;
---END---
---START---
select '(Joe,"von""Blow")'::fullname, E'(Joe,d\\\\Blow)'::fullname;
---END---
---START---
select '(Joe,"Blow,Jr")'::fullname;
---END---
---START---
select '(Joe,)'::fullname;
---END---
---START---
-- ok, null 2nd column
select '(Joe)'::fullname;
---END---
---START---
-- bad
select '(Joe,,)'::fullname;
---END---
---START---
-- bad
select '[]'::fullname;
---END---
---START---
-- bad
select ' (Joe,Blow)  '::fullname;
---END---
---START---
-- ok, extra whitespace
select '(Joe,Blow) /'::fullname;
---END---
---START---
-- bad

-- test non-error-throwing API
SELECT pg_input_is_valid('(1,2)', 'complex');
---END---
---START---
SELECT pg_input_is_valid('(1,2', 'complex');
---END---
---START---
SELECT pg_input_is_valid('(1,zed)', 'complex');
---END---
---START---
SELECT * FROM pg_input_error_info('(1,zed)', 'complex');
---END---
---START---
SELECT * FROM pg_input_error_info('(1,1e400)', 'complex');
---END---
---START---
DROP TABLE IF EXISTS quadtable;

CREATE TABLE quadtable (_gemini_pk serial PRIMARY KEY, f1 integer, q quad);
---END---
---START---
insert into quadtable values (1, ((3.3,4.4),(5.5,6.6)));
---END---
---START---
insert into quadtable values (2, ((null,4.4),(5.5,6.6)));
---END---
---START---
select * from quadtable;
---END---
---START---
select f1, q.c1 from quadtable;
---END---
---START---
-- fails, q is a table reference

select f1, (q).c1, (qq.q).c1.i from quadtable qq;
---END---
---START---
DROP TABLE IF EXISTS people;

CREATE TABLE people (_gemini_pk serial PRIMARY KEY, fn fullname, bd date);
---END---
---START---
insert into people values ('(Joe,Blow)', '1984-01-10');
---END---
---START---
select * from people;
---END---
---START---
-- at the moment this will not work due to ALTER TABLE inadequacy:
alter table fullname add column suffix text default '';
---END---
---START---
-- but this should work:
alter table fullname add column suffix text default null;
---END---
---START---
select * from people;
---END---
---START---
-- test insertion/updating of subfields
update people set fn.suffix = 'Jr';
---END---
---START---
select * from people;
---END---
---START---
insert into quadtable (f1, q.c1.r, q.c2.i) values(44,55,66);
---END---
---START---
update quadtable set q.c1.r = 12 where f1 = 2;
---END---
---START---
update quadtable set q.c1 = 12;
---END---
---START---
-- error, type mismatch

select * from quadtable;
---END---
---START---
-- The object here is to ensure that toasted references inside
-- composite values don't cause problems.  The large f1 value will
-- be toasted inside pp, it must still work after being copied to people.

DROP TABLE IF EXISTS pp;

CREATE TABLE pp (_gemini_pk serial PRIMARY KEY, f1 text);
---END---
---START---
insert into pp values (repeat('abcdefghijkl', 100000));
---END---
---START---
insert into people select ('Jim', f1, null)::fullname, current_date from pp;
---END---
---START---
select (fn).first, substr((fn).last, 1, 20), length((fn).last) from people;
---END---
---START---
-- try an update on a toasted composite value, too
update people set fn.first = 'Jack';
---END---
---START---
select (fn).first, substr((fn).last, 1, 20), length((fn).last) from people;
---END---
---START---
-- Test row comparison semantics.  Prior to PG 8.2 we did this in a totally
-- non-spec-compliant way.

select ROW(1,2) < ROW(1,3) as true;
---END---
---START---
select ROW(1,2) < ROW(1,1) as false;
---END---
---START---
select ROW(1,2) < ROW(1,NULL) as null;
---END---
---START---
select ROW(1,2,3) < ROW(1,3,NULL) as true;
---END---
---START---
-- the NULL is not examined
select ROW(11,'ABC') < ROW(11,'DEF') as true;
---END---
---START---
select ROW(11,'ABC') > ROW(11,'DEF') as false;
---END---
---START---
select ROW(12,'ABC') > ROW(11,'DEF') as true;
---END---
---START---
-- = and <> have different NULL-behavior than < etc
select ROW(1,2,3) < ROW(1,NULL,4) as null;
---END---
---START---
select ROW(1,2,3) = ROW(1,NULL,4) as false;
---END---
---START---
select ROW(1,2,3) <> ROW(1,NULL,4) as true;
---END---
---START---
-- We allow operators beyond the six standard ones, if they have btree
-- operator classes.
select ROW('ABC','DEF') ~<=~ ROW('DEF','ABC') as true;
---END---
---START---
select ROW('ABC','DEF') ~>=~ ROW('DEF','ABC') as false;
---END---
---START---
select ROW('ABC','DEF') ~~ ROW('DEF','ABC') as fail;
---END---
---START---
-- Comparisons of ROW() expressions can cope with some type mismatches
select ROW(1,2) = ROW(1,2::int8);
---END---
---START---
select ROW(1,2) in (ROW(3,4), ROW(1,2));
---END---
---START---
select ROW(1,2) in (ROW(3,4), ROW(1,2::int8));
---END---
---START---
-- Check row comparison with a subselect
select unique1, unique2 from tenk1
where (unique1, unique2) < any (select ten, ten from tenk1 where hundred < 3)
      and unique1 <= 20
order by 1;
---END---
---START---
-- Also check row comparison with an indexable condition
explain (costs off)
select thousand, tenthous from tenk1
where (thousand, tenthous) >= (997, 5000)
order by thousand, tenthous;
---END---
---START---
select thousand, tenthous from tenk1
where (thousand, tenthous) >= (997, 5000)
order by thousand, tenthous;
---END---
---START---
explain (costs off)
select thousand, tenthous, four from tenk1
where (thousand, tenthous, four) > (998, 5000, 3)
order by thousand, tenthous;
---END---
---START---
select thousand, tenthous, four from tenk1
where (thousand, tenthous, four) > (998, 5000, 3)
order by thousand, tenthous;
---END---
---START---
explain (costs off)
select thousand, tenthous from tenk1
where (998, 5000) < (thousand, tenthous)
order by thousand, tenthous;
---END---
---START---
select thousand, tenthous from tenk1
where (998, 5000) < (thousand, tenthous)
order by thousand, tenthous;
---END---
---START---
explain (costs off)
select thousand, hundred from tenk1
where (998, 5000) < (thousand, hundred)
order by thousand, hundred;
---END---
---START---
select thousand, hundred from tenk1
where (998, 5000) < (thousand, hundred)
order by thousand, hundred;
---END---
---START---
-- Test case for bug #14010: indexed row comparisons fail with nulls
DROP TABLE IF EXISTS test_table;

CREATE TABLE test_table (_gemini_pk serial PRIMARY KEY, a text, b text);
---END---
---START---
insert into test_table values ('a', 'b');
---END---
---START---
insert into test_table select 'a', null from generate_series(1,1000);
---END---
---START---
insert into test_table values ('b', 'a');
---END---
---START---
create index on test_table (a,b);
---END---
---START---
set enable_sort = off;
---END---
---START---
explain (costs off)
select a,b from test_table where (a,b) > ('a','a') order by a,b;
---END---
---START---
select a,b from test_table where (a,b) > ('a','a') order by a,b;
---END---
---START---
reset enable_sort;
---END---
---START---
-- Check row comparisons with IN
select * from int8_tbl i8 where i8 in (row(123,456));
---END---
---START---
-- fail, type mismatch

explain (costs off)
select * from int8_tbl i8
where i8 in (row(123,456)::int8_tbl, '(4567890123456789,123)');
---END---
---START---
select * from int8_tbl i8
where i8 in (row(123,456)::int8_tbl, '(4567890123456789,123)');
---END---
---START---
-- Check ability to select columns from an anonymous rowtype
select (row(1, 2.0)).f1;
---END---
---START---
select (row(1, 2.0)).f2;
---END---
---START---
select (row(1, 2.0)).nosuch;
---END---
---START---
-- fail
select (row(1, 2.0)).*;
---END---
---START---
select (r).f1 from (select row(1, 2.0) as r) ss;
---END---
---START---
select (r).f3 from (select row(1, 2.0) as r) ss;
---END---
---START---
-- fail
select (r).* from (select row(1, 2.0) as r) ss;
---END---
---START---
-- Check some corner cases involving empty rowtypes
select ROW();
---END---
---START---
select ROW() IS NULL;
---END---
---START---
select ROW() = ROW();
---END---
---START---
-- Check ability to create arrays of anonymous rowtypes
select array[ row(1,2), row(3,4), row(5,6) ];
---END---
---START---
-- Check ability to compare an anonymous row to elements of an array
select row(1,1.1) = any (array[ row(7,7.7), row(1,1.1), row(0,0.0) ]);
---END---
---START---
select row(1,1.1) = any (array[ row(7,7.7), row(1,1.0), row(0,0.0) ]);
---END---
---START---
-- Check behavior with a non-comparable rowtype
create type cantcompare as (p point, r float8);
---END---
---START---
DROP TABLE IF EXISTS cc;

CREATE TABLE cc (_gemini_pk serial PRIMARY KEY, f1 cantcompare);
---END---
---START---
insert into cc values('("(1,2)",3)');
---END---
---START---
insert into cc values('("(4,5)",6)');
---END---
---START---
select * from cc order by f1;
---END---
---START---
-- fail, but should complain about cantcompare

--
-- Tests for record_{eq,cmp}
--

create type testtype1 as (a int, b int);
---END---
---START---
-- all true
select row(1, 2)::testtype1 < row(1, 3)::testtype1;
---END---
---START---
select row(1, 2)::testtype1 <= row(1, 3)::testtype1;
---END---
---START---
select row(1, 2)::testtype1 = row(1, 2)::testtype1;
---END---
---START---
select row(1, 2)::testtype1 <> row(1, 3)::testtype1;
---END---
---START---
select row(1, 3)::testtype1 >= row(1, 2)::testtype1;
---END---
---START---
select row(1, 3)::testtype1 > row(1, 2)::testtype1;
---END---
---START---
-- all false
select row(1, -2)::testtype1 < row(1, -3)::testtype1;
---END---
---START---
select row(1, -2)::testtype1 <= row(1, -3)::testtype1;
---END---
---START---
select row(1, -2)::testtype1 = row(1, -3)::testtype1;
---END---
---START---
select row(1, -2)::testtype1 <> row(1, -2)::testtype1;
---END---
---START---
select row(1, -3)::testtype1 >= row(1, -2)::testtype1;
---END---
---START---
select row(1, -3)::testtype1 > row(1, -2)::testtype1;
---END---
---START---
-- true, but see *< below
select row(1, -2)::testtype1 < row(1, 3)::testtype1;
---END---
---START---
-- mismatches
create type testtype3 as (a int, b text);
---END---
---START---
select row(1, 2)::testtype1 < row(1, 'abc')::testtype3;
---END---
---START---
select row(1, 2)::testtype1 <> row(1, 'abc')::testtype3;
---END---
---START---
create type testtype5 as (a int);
---END---
---START---
select row(1, 2)::testtype1 < row(1)::testtype5;
---END---
---START---
select row(1, 2)::testtype1 <> row(1)::testtype5;
---END---
---START---
-- non-comparable types
create type testtype6 as (a int, b point);
---END---
---START---
select row(1, '(1,2)')::testtype6 < row(1, '(1,3)')::testtype6;
---END---
---START---
select row(1, '(1,2)')::testtype6 <> row(1, '(1,3)')::testtype6;
---END---
---START---
drop type testtype1, testtype3, testtype5, testtype6;
---END---
---START---
--
-- Tests for record_image_{eq,cmp}
--

create type testtype1 as (a int, b int);
---END---
---START---
-- all true
select row(1, 2)::testtype1 *< row(1, 3)::testtype1;
---END---
---START---
select row(1, 2)::testtype1 *<= row(1, 3)::testtype1;
---END---
---START---
select row(1, 2)::testtype1 *= row(1, 2)::testtype1;
---END---
---START---
select row(1, 2)::testtype1 *<> row(1, 3)::testtype1;
---END---
---START---
select row(1, 3)::testtype1 *>= row(1, 2)::testtype1;
---END---
---START---
select row(1, 3)::testtype1 *> row(1, 2)::testtype1;
---END---
---START---
-- all false
select row(1, -2)::testtype1 *< row(1, -3)::testtype1;
---END---
---START---
select row(1, -2)::testtype1 *<= row(1, -3)::testtype1;
---END---
---START---
select row(1, -2)::testtype1 *= row(1, -3)::testtype1;
---END---
---START---
select row(1, -2)::testtype1 *<> row(1, -2)::testtype1;
---END---
---START---
select row(1, -3)::testtype1 *>= row(1, -2)::testtype1;
---END---
---START---
select row(1, -3)::testtype1 *> row(1, -2)::testtype1;
---END---
---START---
-- This returns the "wrong" order because record_image_cmp works on
-- unsigned datums without knowing about the actual data type.
select row(1, -2)::testtype1 *< row(1, 3)::testtype1;
---END---
---START---
-- other types
create type testtype2 as (a smallint, b bool);
---END---
---START---
-- byval different sizes
select row(1, true)::testtype2 *< row(2, true)::testtype2;
---END---
---START---
select row(-2, true)::testtype2 *< row(-1, true)::testtype2;
---END---
---START---
select row(0, false)::testtype2 *< row(0, true)::testtype2;
---END---
---START---
select row(0, false)::testtype2 *<> row(0, true)::testtype2;
---END---
---START---
create type testtype3 as (a int, b text);
---END---
---START---
-- variable length
select row(1, 'abc')::testtype3 *< row(1, 'abd')::testtype3;
---END---
---START---
select row(1, 'abc')::testtype3 *< row(1, 'abcd')::testtype3;
---END---
---START---
select row(1, 'abc')::testtype3 *> row(1, 'abd')::testtype3;
---END---
---START---
select row(1, 'abc')::testtype3 *<> row(1, 'abd')::testtype3;
---END---
---START---
create type testtype4 as (a int, b point);
---END---
---START---
-- by ref, fixed length
select row(1, '(1,2)')::testtype4 *< row(1, '(1,3)')::testtype4;
---END---
---START---
select row(1, '(1,2)')::testtype4 *<> row(1, '(1,3)')::testtype4;
---END---
---START---
-- mismatches
select row(1, 2)::testtype1 *< row(1, 'abc')::testtype3;
---END---
---START---
select row(1, 2)::testtype1 *<> row(1, 'abc')::testtype3;
---END---
---START---
create type testtype5 as (a int);
---END---
---START---
select row(1, 2)::testtype1 *< row(1)::testtype5;
---END---
---START---
select row(1, 2)::testtype1 *<> row(1)::testtype5;
---END---
---START---
-- non-comparable types
create type testtype6 as (a int, b point);
---END---
---START---
select row(1, '(1,2)')::testtype6 *< row(1, '(1,3)')::testtype6;
---END---
---START---
select row(1, '(1,2)')::testtype6 *>= row(1, '(1,3)')::testtype6;
---END---
---START---
select row(1, '(1,2)')::testtype6 *<> row(1, '(1,3)')::testtype6;
---END---
---START---
-- anonymous rowtypes in coldeflists
select q.a, q.b = row(2), q.c = array[row(3)], q.d = row(row(4)) from
    unnest(array[row(1, row(2), array[row(3)], row(row(4))),
                 row(2, row(3), array[row(4)], row(row(5)))])
      as q(a int, b record, c record[], d record);
---END---
---START---
drop type testtype1, testtype2, testtype3, testtype4, testtype5, testtype6;
---END---
---START---
--
-- Test case derived from bug #5716: check multiple uses of a rowtype result
--

BEGIN;
---END---
---START---
CREATE TABLE price (
    id SERIAL PRIMARY KEY,
    active BOOLEAN NOT NULL,
    price NUMERIC
);
---END---
---START---
CREATE TYPE price_input AS (
    id INTEGER,
    price NUMERIC
);
---END---
---START---
CREATE TYPE price_key AS (
    id INTEGER
);
---END---
---START---
CREATE FUNCTION price_key_from_table(price) RETURNS price_key AS $$
    SELECT $1.id
$$ LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION price_key_from_input(price_input) RETURNS price_key AS $$
    SELECT $1.id
$$ LANGUAGE SQL;
---END---
---START---
insert into price values (1,false,42), (10,false,100), (11,true,17.99);
---END---
---START---
UPDATE price
    SET active = true, price = input_prices.price
    FROM unnest(ARRAY[(10, 123.00), (11, 99.99)]::price_input[]) input_prices
    WHERE price_key_from_table(price.*) = price_key_from_input(input_prices.*);
---END---
---START---
select * from price;
---END---
---START---
rollback;
---END---
---START---
--
-- Test case derived from bug #9085: check * qualification of composite
-- parameters for SQL functions
--

DROP TABLE IF EXISTS compos;

CREATE TABLE compos (_gemini_pk serial PRIMARY KEY, f1 integer, f2 text);
---END---
---START---
create function fcompos1(v compos) returns void as $$
insert into compos values (v);  -- fail
$$ language sql;
---END---
---START---
create function fcompos1(v compos) returns void as $$
insert into compos values (v.*);
$$ language sql;
---END---
---START---
create function fcompos2(v compos) returns void as $$
select fcompos1(v);
$$ language sql;
---END---
---START---
create function fcompos3(v compos) returns void as $$
select fcompos1(fcompos3.v.*);
$$ language sql;
---END---
---START---
select fcompos1(row(1,'one'));
---END---
---START---
select fcompos2(row(2,'two'));
---END---
---START---
select fcompos3(row(3,'three'));
---END---
---START---
select * from compos;
---END---
---START---
--
-- We allow I/O conversion casts from composite types to strings to be
-- invoked via cast syntax, but not functional syntax.  This is because
-- the latter is too prone to be invoked unintentionally.
--
select cast (fullname as text) from fullname;
---END---
---START---
select fullname::text from fullname;
---END---
---START---
select text(fullname) from fullname;
---END---
---START---
-- error
select fullname.text from fullname;
---END---
---START---
-- error
-- same, but RECORD instead of named composite type:
select cast (row('Jim', 'Beam') as text);
---END---
---START---
select (row('Jim', 'Beam'))::text;
---END---
---START---
select text(row('Jim', 'Beam'));
---END---
---START---
-- error
select (row('Jim', 'Beam')).text;
---END---
---START---
-- error

--
-- Check the equivalence of functional and column notation
--
insert into fullname values ('Joe', 'Blow');
---END---
---START---
select f.last from fullname f;
---END---
---START---
select last(f) from fullname f;
---END---
---START---
create function longname(fullname) returns text language sql
as $$select $1.first || ' ' || $1.last$$;
---END---
---START---
select f.longname from fullname f;
---END---
---START---
select longname(f) from fullname f;
---END---
---START---
-- Starting in v11, the notational form does matter if there's ambiguity
alter table fullname add column longname text;
---END---
---START---
select f.longname from fullname f;
---END---
---START---
select longname(f) from fullname f;
---END---
---START---
--
-- Test that composite values are seen to have the correct column names
-- (bug #11210 and other reports)
--

select row_to_json(i) from int8_tbl i;
---END---
---START---
-- since "i" is of type "int8_tbl", attaching aliases doesn't change anything:
select row_to_json(i) from int8_tbl i(x,y);
---END---
---START---
-- in these examples, we'll report the exposed column names of the subselect:
select row_to_json(ss) from
  (select q1, q2 from int8_tbl) as ss;
---END---
---START---
select row_to_json(ss) from
  (select q1, q2 from int8_tbl offset 0) as ss;
---END---
---START---
select row_to_json(ss) from
  (select q1 as a, q2 as b from int8_tbl) as ss;
---END---
---START---
select row_to_json(ss) from
  (select q1 as a, q2 as b from int8_tbl offset 0) as ss;
---END---
---START---
select row_to_json(ss) from
  (select q1 as a, q2 as b from int8_tbl) as ss(x,y);
---END---
---START---
select row_to_json(ss) from
  (select q1 as a, q2 as b from int8_tbl offset 0) as ss(x,y);
---END---
---START---
explain (costs off)
select row_to_json(q) from
  (select thousand, tenthous from tenk1
   where thousand = 42 and tenthous < 2000 offset 0) q;
---END---
---START---
select row_to_json(q) from
  (select thousand, tenthous from tenk1
   where thousand = 42 and tenthous < 2000 offset 0) q;
---END---
---START---
select row_to_json(q) from
  (select thousand as x, tenthous as y from tenk1
   where thousand = 42 and tenthous < 2000 offset 0) q;
---END---
---START---
select row_to_json(q) from
  (select thousand as x, tenthous as y from tenk1
   where thousand = 42 and tenthous < 2000 offset 0) q(a,b);
---END---
---START---
DROP TABLE IF EXISTS tt1;

create table tt1 as select * from int8_tbl limit 2;
---END---
---START---
DROP TABLE IF EXISTS tt2;

CREATE TABLE tt2 (_gemini_pk serial PRIMARY KEY) INHERITS (tt1);
---END---
---START---
insert into tt2 values(0,0);
---END---
---START---
select row_to_json(r) from (select q2,q1 from tt1 offset 0) r;
---END---
---START---
-- check no-op rowtype conversions
DROP TABLE IF EXISTS tt3;

CREATE TABLE tt3 (_gemini_pk serial PRIMARY KEY) INHERITS (tt2);
---END---
---START---
insert into tt3 values(33,44);
---END---
---START---
select row_to_json(tt3::tt2::tt1) from tt3;
---END---
---START---
--
-- IS [NOT] NULL should not recurse into nested composites (bug #14235)
--

explain (verbose, costs off)
select r, r is null as isnull, r is not null as isnotnull
from (values (1,row(1,2)), (1,row(null,null)), (1,null),
             (null,row(1,2)), (null,row(null,null)), (null,null) ) r(a,b);
---END---
---START---
select r, r is null as isnull, r is not null as isnotnull
from (values (1,row(1,2)), (1,row(null,null)), (1,null),
             (null,row(1,2)), (null,row(null,null)), (null,null) ) r(a,b);
---END---
---START---
explain (verbose, costs off)
with r(a,b) as materialized
  (values (1,row(1,2)), (1,row(null,null)), (1,null),
          (null,row(1,2)), (null,row(null,null)), (null,null) )
select r, r is null as isnull, r is not null as isnotnull from r;
---END---
---START---
with r(a,b) as materialized
  (values (1,row(1,2)), (1,row(null,null)), (1,null),
          (null,row(1,2)), (null,row(null,null)), (null,null) )
select r, r is null as isnull, r is not null as isnotnull from r;
---END---
---START---
CREATE TABLE compositetable (_gemini_pk serial PRIMARY KEY, a text, b text);
---END---
---START---
INSERT INTO compositetable(a, b) VALUES('fa', 'fb');
---END---
---START---
-- composite type columns can't directly be accessed (error)
SELECT d.a FROM (SELECT compositetable AS d FROM compositetable) s;
---END---
---START---
-- but can be accessed with proper parens
SELECT (d).a, (d).b FROM (SELECT compositetable AS d FROM compositetable) s;
---END---
---START---
-- system columns can't be accessed in composite types (error)
SELECT (d).ctid FROM (SELECT compositetable AS d FROM compositetable) s;
---END---
---START---
-- accessing non-existing column in NULL datum errors out
SELECT (NULL::compositetable).nonexistent;
---END---
---START---
-- existing column in a NULL composite yield NULL
SELECT (NULL::compositetable).a;
---END---
---START---
-- oids can't be accessed in composite types (error)
SELECT (NULL::compositetable).oid;
---END---
---START---
DROP TABLE compositetable;
---END---
