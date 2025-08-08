---START---
-- Tests for range data types.

--
-- test input parser
-- (type textrange was already made in test_setup.sql)
--

-- negative tests; should fail
select ''::textrange;
---END---
---START---
select '-[a,z)'::textrange;
---END---
---START---
select '[a,z) - '::textrange;
---END---
---START---
select '(",a)'::textrange;
---END---
---START---
select '(,,a)'::textrange;
---END---
---START---
select '(),a)'::textrange;
---END---
---START---
select '(a,))'::textrange;
---END---
---START---
select '(],a)'::textrange;
---END---
---START---
select '(a,])'::textrange;
---END---
---START---
select '[z,a]'::textrange;
---END---
---START---
-- should succeed
select '  empty  '::textrange;
---END---
---START---
select ' ( empty, empty )  '::textrange;
---END---
---START---
select ' ( " a " " a ", " z " " z " )  '::textrange;
---END---
---START---
select '(a,)'::textrange;
---END---
---START---
select '[,z]'::textrange;
---END---
---START---
select '[a,]'::textrange;
---END---
---START---
select '(,)'::textrange;
---END---
---START---
select '[ , ]'::textrange;
---END---
---START---
select '["",""]'::textrange;
---END---
---START---
select '[",",","]'::textrange;
---END---
---START---
select '["\\","\\"]'::textrange;
---END---
---START---
select '(\\,a)'::textrange;
---END---
---START---
select '((,z)'::textrange;
---END---
---START---
select '([,z)'::textrange;
---END---
---START---
select '(!,()'::textrange;
---END---
---START---
select '(!,[)'::textrange;
---END---
---START---
select '[a,a]'::textrange;
---END---
---START---
-- these are allowed but normalize to empty:
select '[a,a)'::textrange;
---END---
---START---
select '(a,a]'::textrange;
---END---
---START---
select '(a,a)'::textrange;
---END---
---START---
-- Also try it with non-error-throwing API
select pg_input_is_valid('(1,4)', 'int4range');
---END---
---START---
select pg_input_is_valid('(1,4', 'int4range');
---END---
---START---
select * from pg_input_error_info('(1,4', 'int4range');
---END---
---START---
select pg_input_is_valid('(4,1)', 'int4range');
---END---
---START---
select * from pg_input_error_info('(4,1)', 'int4range');
---END---
---START---
select pg_input_is_valid('(4,zed)', 'int4range');
---END---
---START---
select * from pg_input_error_info('(4,zed)', 'int4range');
---END---
---START---
select pg_input_is_valid('[1,2147483647]', 'int4range');
---END---
---START---
select * from pg_input_error_info('[1,2147483647]', 'int4range');
---END---
---START---
select pg_input_is_valid('[2000-01-01,5874897-12-31]', 'daterange');
---END---
---START---
select * from pg_input_error_info('[2000-01-01,5874897-12-31]', 'daterange');
---END---
---START---
--
-- create some test data and test the operators
--

CREATE TABLE numrange_test (nr NUMRANGE);
---END---
---START---
create index numrange_test_btree on numrange_test(nr);
---END---
---START---
INSERT INTO numrange_test VALUES('[,)');
---END---
---START---
INSERT INTO numrange_test VALUES('[3,]');
---END---
---START---
INSERT INTO numrange_test VALUES('[, 5)');
---END---
---START---
INSERT INTO numrange_test VALUES(numrange(1.1, 2.2));
---END---
---START---
INSERT INTO numrange_test VALUES('empty');
---END---
---START---
INSERT INTO numrange_test VALUES(numrange(1.7, 1.7, '[]'));
---END---
---START---
SELECT nr, isempty(nr), lower(nr), upper(nr) FROM numrange_test;
---END---
---START---
SELECT nr, lower_inc(nr), lower_inf(nr), upper_inc(nr), upper_inf(nr) FROM numrange_test;
---END---
---START---
SELECT * FROM numrange_test WHERE range_contains(nr, numrange(1.9,1.91));
---END---
---START---
SELECT * FROM numrange_test WHERE nr @> numrange(1.0,10000.1);
---END---
---START---
SELECT * FROM numrange_test WHERE range_contained_by(numrange(-1e7,-10000.1), nr);
---END---
---START---
SELECT * FROM numrange_test WHERE 1.9 <@ nr;
---END---
---START---
select * from numrange_test where nr = 'empty';
---END---
---START---
select * from numrange_test where nr = '(1.1, 2.2)';
---END---
---START---
select * from numrange_test where nr = '[1.1, 2.2)';
---END---
---START---
select * from numrange_test where nr < 'empty';
---END---
---START---
select * from numrange_test where nr < numrange(-1000.0, -1000.0,'[]');
---END---
---START---
select * from numrange_test where nr < numrange(0.0, 1.0,'[]');
---END---
---START---
select * from numrange_test where nr < numrange(1000.0, 1001.0,'[]');
---END---
---START---
select * from numrange_test where nr <= 'empty';
---END---
---START---
select * from numrange_test where nr >= 'empty';
---END---
---START---
select * from numrange_test where nr > 'empty';
---END---
---START---
select * from numrange_test where nr > numrange(-1001.0, -1000.0,'[]');
---END---
---START---
select * from numrange_test where nr > numrange(0.0, 1.0,'[]');
---END---
---START---
select * from numrange_test where nr > numrange(1000.0, 1000.0,'[]');
---END---
---START---
select numrange(2.0, 1.0);
---END---
---START---
select numrange(2.0, 3.0) -|- numrange(3.0, 4.0);
---END---
---START---
select range_adjacent(numrange(2.0, 3.0), numrange(3.1, 4.0));
---END---
---START---
select range_adjacent(numrange(2.0, 3.0), numrange(3.1, null));
---END---
---START---
select numrange(2.0, 3.0, '[]') -|- numrange(3.0, 4.0, '()');
---END---
---START---
select numrange(1.0, 2.0) -|- numrange(2.0, 3.0,'[]');
---END---
---START---
select range_adjacent(numrange(2.0, 3.0, '(]'), numrange(1.0, 2.0, '(]'));
---END---
---START---
select numrange(1.1, 3.3) <@ numrange(0.1,10.1);
---END---
---START---
select numrange(0.1, 10.1) <@ numrange(1.1,3.3);
---END---
---START---
select numrange(1.1, 2.2) - numrange(2.0, 3.0);
---END---
---START---
select numrange(1.1, 2.2) - numrange(2.2, 3.0);
---END---
---START---
select numrange(1.1, 2.2,'[]') - numrange(2.0, 3.0);
---END---
---START---
select range_minus(numrange(10.1,12.2,'[]'), numrange(110.0,120.2,'(]'));
---END---
---START---
select range_minus(numrange(10.1,12.2,'[]'), numrange(0.0,120.2,'(]'));
---END---
---START---
select numrange(4.5, 5.5, '[]') && numrange(5.5, 6.5);
---END---
---START---
select numrange(1.0, 2.0) << numrange(3.0, 4.0);
---END---
---START---
select numrange(1.0, 3.0,'[]') << numrange(3.0, 4.0,'[]');
---END---
---START---
select numrange(1.0, 3.0,'()') << numrange(3.0, 4.0,'()');
---END---
---START---
select numrange(1.0, 2.0) >> numrange(3.0, 4.0);
---END---
---START---
select numrange(3.0, 70.0) &< numrange(6.6, 100.0);
---END---
---START---
select numrange(1.1, 2.2) < numrange(1.0, 200.2);
---END---
---START---
select numrange(1.1, 2.2) < numrange(1.1, 1.2);
---END---
---START---
select numrange(1.0, 2.0) + numrange(2.0, 3.0);
---END---
---START---
select numrange(1.0, 2.0) + numrange(1.5, 3.0);
---END---
---START---
select numrange(1.0, 2.0) + numrange(2.5, 3.0);
---END---
---START---
-- should fail

select range_merge(numrange(1.0, 2.0), numrange(2.0, 3.0));
---END---
---START---
select range_merge(numrange(1.0, 2.0), numrange(1.5, 3.0));
---END---
---START---
select range_merge(numrange(1.0, 2.0), numrange(2.5, 3.0));
---END---
---START---
-- shouldn't fail

select numrange(1.0, 2.0) * numrange(2.0, 3.0);
---END---
---START---
select numrange(1.0, 2.0) * numrange(1.5, 3.0);
---END---
---START---
select numrange(1.0, 2.0) * numrange(2.5, 3.0);
---END---
---START---
select range_intersect_agg(nr) from numrange_test;
---END---
---START---
select range_intersect_agg(nr) from numrange_test where false;
---END---
---START---
select range_intersect_agg(nr) from numrange_test where nr @> 4.0;
---END---
---START---
analyze numrange_test;
---END---
---START---
create table numrange_test2(nr numrange);
---END---
---START---
create index numrange_test2_hash_idx on numrange_test2 using hash (nr);
---END---
---START---
INSERT INTO numrange_test2 VALUES('[, 5)');
---END---
---START---
INSERT INTO numrange_test2 VALUES(numrange(1.1, 2.2));
---END---
---START---
INSERT INTO numrange_test2 VALUES(numrange(1.1, 2.2));
---END---
---START---
INSERT INTO numrange_test2 VALUES(numrange(1.1, 2.2,'()'));
---END---
---START---
INSERT INTO numrange_test2 VALUES('empty');
---END---
---START---
select * from numrange_test2 where nr = 'empty'::numrange;
---END---
---START---
select * from numrange_test2 where nr = numrange(1.1, 2.2);
---END---
---START---
select * from numrange_test2 where nr = numrange(1.1, 2.3);
---END---
---START---
set enable_nestloop=t;
---END---
---START---
set enable_hashjoin=f;
---END---
---START---
set enable_mergejoin=f;
---END---
---START---
select * from numrange_test natural join numrange_test2 order by nr;
---END---
---START---
set enable_nestloop=f;
---END---
---START---
set enable_hashjoin=t;
---END---
---START---
set enable_mergejoin=f;
---END---
---START---
select * from numrange_test natural join numrange_test2 order by nr;
---END---
---START---
set enable_nestloop=f;
---END---
---START---
set enable_hashjoin=f;
---END---
---START---
set enable_mergejoin=t;
---END---
---START---
select * from numrange_test natural join numrange_test2 order by nr;
---END---
---START---
set enable_nestloop to default;
---END---
---START---
set enable_hashjoin to default;
---END---
---START---
set enable_mergejoin to default;
---END---
---START---
-- keep numrange_test around to help exercise dump/reload
DROP TABLE numrange_test2;
---END---
---START---
--
-- Apply a subset of the above tests on a collatable type, too
--

CREATE TABLE textrange_test (tr textrange);
---END---
---START---
create index textrange_test_btree on textrange_test(tr);
---END---
---START---
INSERT INTO textrange_test VALUES('[,)');
---END---
---START---
INSERT INTO textrange_test VALUES('["a",]');
---END---
---START---
INSERT INTO textrange_test VALUES('[,"q")');
---END---
---START---
INSERT INTO textrange_test VALUES(textrange('b', 'g'));
---END---
---START---
INSERT INTO textrange_test VALUES('empty');
---END---
---START---
INSERT INTO textrange_test VALUES(textrange('d', 'd', '[]'));
---END---
---START---
SELECT tr, isempty(tr), lower(tr), upper(tr) FROM textrange_test;
---END---
---START---
SELECT tr, lower_inc(tr), lower_inf(tr), upper_inc(tr), upper_inf(tr) FROM textrange_test;
---END---
---START---
SELECT * FROM textrange_test WHERE range_contains(tr, textrange('f', 'fx'));
---END---
---START---
SELECT * FROM textrange_test WHERE tr @> textrange('a', 'z');
---END---
---START---
SELECT * FROM textrange_test WHERE range_contained_by(textrange('0','9'), tr);
---END---
---START---
SELECT * FROM textrange_test WHERE 'e'::text <@ tr;
---END---
---START---
select * from textrange_test where tr = 'empty';
---END---
---START---
select * from textrange_test where tr = '("b","g")';
---END---
---START---
select * from textrange_test where tr = '["b","g")';
---END---
---START---
select * from textrange_test where tr < 'empty';
---END---
---START---
-- test canonical form for int4range
select int4range(1, 10, '[]');
---END---
---START---
select int4range(1, 10, '[)');
---END---
---START---
select int4range(1, 10, '(]');
---END---
---START---
select int4range(1, 10, '()');
---END---
---START---
select int4range(1, 2, '()');
---END---
---START---
-- test canonical form for daterange
select daterange('2000-01-10'::date, '2000-01-20'::date, '[]');
---END---
---START---
select daterange('2000-01-10'::date, '2000-01-20'::date, '[)');
---END---
---START---
select daterange('2000-01-10'::date, '2000-01-20'::date, '(]');
---END---
---START---
select daterange('2000-01-10'::date, '2000-01-20'::date, '()');
---END---
---START---
select daterange('2000-01-10'::date, '2000-01-11'::date, '()');
---END---
---START---
select daterange('2000-01-10'::date, '2000-01-11'::date, '(]');
---END---
---START---
select daterange('-infinity'::date, '2000-01-01'::date, '()');
---END---
---START---
select daterange('-infinity'::date, '2000-01-01'::date, '[)');
---END---
---START---
select daterange('2000-01-01'::date, 'infinity'::date, '[)');
---END---
---START---
select daterange('2000-01-01'::date, 'infinity'::date, '[]');
---END---
---START---
-- test GiST index that's been built incrementally
create table test_range_gist(ir int4range);
---END---
---START---
create index test_range_gist_idx on test_range_gist using gist (ir);
---END---
---START---
insert into test_range_gist select int4range(g, g+10) from generate_series(1,2000) g;
---END---
---START---
insert into test_range_gist select 'empty'::int4range from generate_series(1,500) g;
---END---
---START---
insert into test_range_gist select int4range(g, g+10000) from generate_series(1,1000) g;
---END---
---START---
insert into test_range_gist select 'empty'::int4range from generate_series(1,500) g;
---END---
---START---
insert into test_range_gist select int4range(NULL,g*10,'(]') from generate_series(1,100) g;
---END---
---START---
insert into test_range_gist select int4range(g*10,NULL,'(]') from generate_series(1,100) g;
---END---
---START---
insert into test_range_gist select int4range(g, g+10) from generate_series(1,2000) g;
---END---
---START---
-- test statistics and selectivity estimation as well
--
-- We don't check the accuracy of selectivity estimation, but at least check
-- it doesn't fall.
analyze test_range_gist;
---END---
---START---
-- first, verify non-indexed results
SET enable_seqscan    = t;
---END---
---START---
SET enable_indexscan  = f;
---END---
---START---
SET enable_bitmapscan = f;
---END---
---START---
select count(*) from test_range_gist where ir @> 'empty'::int4range;
---END---
---START---
select count(*) from test_range_gist where ir = int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir @> 10;
---END---
---START---
select count(*) from test_range_gist where ir @> int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir && int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir <@ int4range(10,50);
---END---
---START---
select count(*) from test_range_gist where ir << int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir >> int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir &< int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir &> int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir -|- int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir @> int4multirange(int4range(10,20), int4range(30,40));
---END---
---START---
select count(*) from test_range_gist where ir && '{(10,20),(30,40),(50,60)}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir <@ '{(10,30),(40,60),(70,90)}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir << int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir >> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir &< int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir &> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir -|- int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
-- now check same queries using index
SET enable_seqscan    = f;
---END---
---START---
SET enable_indexscan  = t;
---END---
---START---
SET enable_bitmapscan = f;
---END---
---START---
select count(*) from test_range_gist where ir @> 'empty'::int4range;
---END---
---START---
select count(*) from test_range_gist where ir = int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir @> 10;
---END---
---START---
select count(*) from test_range_gist where ir @> int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir && int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir <@ int4range(10,50);
---END---
---START---
select count(*) from test_range_gist where ir << int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir >> int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir &< int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir &> int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir -|- int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir @> int4multirange(int4range(10,20), int4range(30,40));
---END---
---START---
select count(*) from test_range_gist where ir && '{(10,20),(30,40),(50,60)}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir <@ '{(10,30),(40,60),(70,90)}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir << int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir >> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir &< int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir &> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir -|- int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
-- now check same queries using a bulk-loaded index
drop index test_range_gist_idx;
---END---
---START---
create index test_range_gist_idx on test_range_gist using gist (ir);
---END---
---START---
select count(*) from test_range_gist where ir @> 'empty'::int4range;
---END---
---START---
select count(*) from test_range_gist where ir = int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir @> 10;
---END---
---START---
select count(*) from test_range_gist where ir @> int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir && int4range(10,20);
---END---
---START---
select count(*) from test_range_gist where ir <@ int4range(10,50);
---END---
---START---
select count(*) from test_range_gist where ir << int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir >> int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir &< int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir &> int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir -|- int4range(100,500);
---END---
---START---
select count(*) from test_range_gist where ir @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir @> int4multirange(int4range(10,20), int4range(30,40));
---END---
---START---
select count(*) from test_range_gist where ir && '{(10,20),(30,40),(50,60)}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir <@ '{(10,30),(40,60),(70,90)}'::int4multirange;
---END---
---START---
select count(*) from test_range_gist where ir << int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir >> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir &< int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir &> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_range_gist where ir -|- int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
-- test SP-GiST index that's been built incrementally
create table test_range_spgist(ir int4range);
---END---
---START---
create index test_range_spgist_idx on test_range_spgist using spgist (ir);
---END---
---START---
insert into test_range_spgist select int4range(g, g+10) from generate_series(1,2000) g;
---END---
---START---
insert into test_range_spgist select 'empty'::int4range from generate_series(1,500) g;
---END---
---START---
insert into test_range_spgist select int4range(g, g+10000) from generate_series(1,1000) g;
---END---
---START---
insert into test_range_spgist select 'empty'::int4range from generate_series(1,500) g;
---END---
---START---
insert into test_range_spgist select int4range(NULL,g*10,'(]') from generate_series(1,100) g;
---END---
---START---
insert into test_range_spgist select int4range(g*10,NULL,'(]') from generate_series(1,100) g;
---END---
---START---
insert into test_range_spgist select int4range(g, g+10) from generate_series(1,2000) g;
---END---
---START---
-- first, verify non-indexed results
SET enable_seqscan    = t;
---END---
---START---
SET enable_indexscan  = f;
---END---
---START---
SET enable_bitmapscan = f;
---END---
---START---
select count(*) from test_range_spgist where ir @> 'empty'::int4range;
---END---
---START---
select count(*) from test_range_spgist where ir = int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir @> 10;
---END---
---START---
select count(*) from test_range_spgist where ir @> int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir && int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir <@ int4range(10,50);
---END---
---START---
select count(*) from test_range_spgist where ir << int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir >> int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir &< int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir &> int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir -|- int4range(100,500);
---END---
---START---
-- now check same queries using index
SET enable_seqscan    = f;
---END---
---START---
SET enable_indexscan  = t;
---END---
---START---
SET enable_bitmapscan = f;
---END---
---START---
select count(*) from test_range_spgist where ir @> 'empty'::int4range;
---END---
---START---
select count(*) from test_range_spgist where ir = int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir @> 10;
---END---
---START---
select count(*) from test_range_spgist where ir @> int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir && int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir <@ int4range(10,50);
---END---
---START---
select count(*) from test_range_spgist where ir << int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir >> int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir &< int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir &> int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir -|- int4range(100,500);
---END---
---START---
-- now check same queries using a bulk-loaded index
drop index test_range_spgist_idx;
---END---
---START---
create index test_range_spgist_idx on test_range_spgist using spgist (ir);
---END---
---START---
select count(*) from test_range_spgist where ir @> 'empty'::int4range;
---END---
---START---
select count(*) from test_range_spgist where ir = int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir @> 10;
---END---
---START---
select count(*) from test_range_spgist where ir @> int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir && int4range(10,20);
---END---
---START---
select count(*) from test_range_spgist where ir <@ int4range(10,50);
---END---
---START---
select count(*) from test_range_spgist where ir << int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir >> int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir &< int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir &> int4range(100,500);
---END---
---START---
select count(*) from test_range_spgist where ir -|- int4range(100,500);
---END---
---START---
-- test index-only scans
explain (costs off)
select ir from test_range_spgist where ir -|- int4range(10,20) order by ir;
---END---
---START---
select ir from test_range_spgist where ir -|- int4range(10,20) order by ir;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
RESET enable_indexscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
-- test elem <@ range operator
create table test_range_elem(i int4);
---END---
---START---
create index test_range_elem_idx on test_range_elem (i);
---END---
---START---
insert into test_range_elem select i from generate_series(1,100) i;
---END---
---START---
SET enable_seqscan    = f;
---END---
---START---
select count(*) from test_range_elem where i <@ int4range(10,50);
---END---
---START---
-- also test spgist index on anyrange expression
create index on test_range_elem using spgist(int4range(i,i+10));
---END---
---START---
explain (costs off)
select count(*) from test_range_elem where int4range(i,i+10) <@ int4range(10,30);
---END---
---START---
select count(*) from test_range_elem where int4range(i,i+10) <@ int4range(10,30);
---END---
---START---
RESET enable_seqscan;
---END---
---START---
drop table test_range_elem;
---END---
---START---
--
-- Btree_gist is not included by default, so to test exclusion
-- constraints with range types, use singleton int ranges for the "="
-- portion of the constraint.
--

create table test_range_excl(
  room int4range,
  speaker int4range,
  during tsrange,
  exclude using gist (room with =, during with &&),
  exclude using gist (speaker with =, during with &&)
);
---END---
---START---
insert into test_range_excl
  values(int4range(123, 123, '[]'), int4range(1, 1, '[]'), '[2010-01-02 10:00, 2010-01-02 11:00)');
---END---
---START---
insert into test_range_excl
  values(int4range(123, 123, '[]'), int4range(2, 2, '[]'), '[2010-01-02 11:00, 2010-01-02 12:00)');
---END---
---START---
insert into test_range_excl
  values(int4range(123, 123, '[]'), int4range(3, 3, '[]'), '[2010-01-02 10:10, 2010-01-02 11:00)');
---END---
---START---
insert into test_range_excl
  values(int4range(124, 124, '[]'), int4range(3, 3, '[]'), '[2010-01-02 10:10, 2010-01-02 11:10)');
---END---
---START---
insert into test_range_excl
  values(int4range(125, 125, '[]'), int4range(1, 1, '[]'), '[2010-01-02 10:10, 2010-01-02 11:00)');
---END---
---START---
-- test bigint ranges
select int8range(10000000000::int8, 20000000000::int8,'(]');
---END---
---START---
-- test tstz ranges
set timezone to '-08';
---END---
---START---
select '[2010-01-01 01:00:00 -05, 2010-01-01 02:00:00 -08)'::tstzrange;
---END---
---START---
-- should fail
select '[2010-01-01 01:00:00 -08, 2010-01-01 02:00:00 -05)'::tstzrange;
---END---
---START---
set timezone to default;
---END---
---START---
--
-- Test user-defined range of floats
-- (type float8range was already made in test_setup.sql)
--

--should fail
create type bogus_float8range as range (subtype=float8, subtype_diff=float4mi);
---END---
---START---
select '[123.001, 5.e9)'::float8range @> 888.882::float8;
---END---
---START---
create table float8range_test(f8r float8range, i int);
---END---
---START---
insert into float8range_test values(float8range(-100.00007, '1.111113e9'), 42);
---END---
---START---
select * from float8range_test;
---END---
---START---
drop table float8range_test;
---END---
---START---
--
-- Test range types over domains
--

create domain mydomain as int4;
---END---
---START---
create type mydomainrange as range(subtype=mydomain);
---END---
---START---
select '[4,50)'::mydomainrange @> 7::mydomain;
---END---
---START---
drop domain mydomain;
---END---
---START---
-- fail
drop domain mydomain cascade;
---END---
---START---
--
-- Test domains over range types
--

create domain restrictedrange as int4range check (upper(value) < 10);
---END---
---START---
select '[4,5)'::restrictedrange @> 7;
---END---
---START---
select '[4,50)'::restrictedrange @> 7;
---END---
---START---
-- should fail
drop domain restrictedrange;
---END---
---START---
--
-- Test multiple range types over the same subtype
--

create type textrange1 as range(subtype=text, collation="C");
---END---
---START---
create type textrange2 as range(subtype=text, collation="C");
---END---
---START---
select textrange1('a','Z') @> 'b'::text;
---END---
---START---
select textrange2('a','z') @> 'b'::text;
---END---
---START---
drop type textrange1;
---END---
---START---
drop type textrange2;
---END---
---START---
--
-- Test polymorphic type system
--

create function anyarray_anyrange_func(a anyarray, r anyrange)
  returns anyelement as 'select $1[1] + lower($2);' language sql;
---END---
---START---
select anyarray_anyrange_func(ARRAY[1,2], int4range(10,20));
---END---
---START---
-- should fail
select anyarray_anyrange_func(ARRAY[1,2], numrange(10,20));
---END---
---START---
drop function anyarray_anyrange_func(anyarray, anyrange);
---END---
---START---
-- should fail
create function bogus_func(anyelement)
  returns anyrange as 'select int4range(1,10)' language sql;
---END---
---START---
-- should fail
create function bogus_func(int)
  returns anyrange as 'select int4range(1,10)' language sql;
---END---
---START---
create function range_add_bounds(anyrange)
  returns anyelement as 'select lower($1) + upper($1)' language sql;
---END---
---START---
select range_add_bounds(int4range(1, 17));
---END---
---START---
select range_add_bounds(numrange(1.0001, 123.123));
---END---
---START---
create function rangetypes_sql(q anyrange, b anyarray, out c anyelement)
  as $$ select upper($1) + $2[1] $$
  language sql;
---END---
---START---
select rangetypes_sql(int4range(1,10), ARRAY[2,20]);
---END---
---START---
select rangetypes_sql(numrange(1,10), ARRAY[2,20]);
---END---
---START---
-- match failure

create function anycompatiblearray_anycompatiblerange_func(a anycompatiblearray, r anycompatiblerange)
  returns anycompatible as 'select $1[1] + lower($2);' language sql;
---END---
---START---
select anycompatiblearray_anycompatiblerange_func(ARRAY[1,2], int4range(10,20));
---END---
---START---
select anycompatiblearray_anycompatiblerange_func(ARRAY[1,2], numrange(10,20));
---END---
---START---
-- should fail
select anycompatiblearray_anycompatiblerange_func(ARRAY[1.1,2], int4range(10,20));
---END---
---START---
drop function anycompatiblearray_anycompatiblerange_func(anycompatiblearray, anycompatiblerange);
---END---
---START---
-- should fail
create function bogus_func(anycompatible)
  returns anycompatiblerange as 'select int4range(1,10)' language sql;
---END---
---START---
--
-- Arrays of ranges
--

select ARRAY[numrange(1.1, 1.2), numrange(12.3, 155.5)];
---END---
---START---
create table i8r_array (f1 int, f2 int8range[]);
---END---
---START---
insert into i8r_array values (42, array[int8range(1,10), int8range(2,20)]);
---END---
---START---
select * from i8r_array;
---END---
---START---
drop table i8r_array;
---END---
---START---
--
-- Ranges of arrays
--

create type arrayrange as range (subtype=int4[]);
---END---
---START---
select arrayrange(ARRAY[1,2], ARRAY[2,1]);
---END---
---START---
select arrayrange(ARRAY[2,1], ARRAY[1,2]);
---END---
---START---
-- fail

select array[1,1] <@ arrayrange(array[1,2], array[2,1]);
---END---
---START---
select array[1,3] <@ arrayrange(array[1,2], array[2,1]);
---END---
---START---
--
-- Ranges of composites
--

create type two_ints as (a int, b int);
---END---
---START---
create type two_ints_range as range (subtype = two_ints);
---END---
---START---
-- with debug_parallel_query on, this exercises tqueue.c's range remapping
select *, row_to_json(upper(t)) as u from
  (values (two_ints_range(row(1,2), row(3,4))),
          (two_ints_range(row(5,6), row(7,8)))) v(t);
---END---
---START---
-- this must be rejected to avoid self-inclusion issues:
alter type two_ints add attribute c two_ints_range;
---END---
---START---
drop type two_ints cascade;
---END---
---START---
--
-- Check behavior when subtype lacks a hash function
--

create type cashrange as range (subtype = money);
---END---
---START---
set enable_sort = off;
---END---
---START---
-- try to make it pick a hash setop implementation

select '(2,5)'::cashrange except select '(5,6)'::cashrange;
---END---
---START---
reset enable_sort;
---END---
---START---
--
-- OUT/INOUT/TABLE functions
--

-- infer anyrange from anyrange
create function outparam_succeed(i anyrange, out r anyrange, out t text)
  as $$ select $1, 'foo'::text $$ language sql;
---END---
---START---
select * from outparam_succeed(int4range(1,2));
---END---
---START---
create function outparam2_succeed(r anyrange, out lu anyarray, out ul anyarray)
  as $$ select array[lower($1), upper($1)], array[upper($1), lower($1)] $$
  language sql;
---END---
---START---
select * from outparam2_succeed(int4range(1,11));
---END---
---START---
-- infer anyarray from anyrange
create function outparam_succeed2(i anyrange, out r anyarray, out t text)
  as $$ select ARRAY[upper($1)], 'foo'::text $$ language sql;
---END---
---START---
select * from outparam_succeed2(int4range(int4range(1,2)));
---END---
---START---
-- infer anyelement from anyrange
create function inoutparam_succeed(out i anyelement, inout r anyrange)
  as $$ select upper($1), $1 $$ language sql;
---END---
---START---
select * from inoutparam_succeed(int4range(1,2));
---END---
---START---
create function table_succeed(r anyrange)
  returns table(l anyelement, u anyelement)
  as $$ select lower($1), upper($1) $$
  language sql;
---END---
---START---
select * from table_succeed(int4range(1,11));
---END---
---START---
-- should fail
create function outparam_fail(i anyelement, out r anyrange, out t text)
  as $$ select '[1,10]', 'foo' $$ language sql;
---END---
---START---
--should fail
create function inoutparam_fail(inout i anyelement, out r anyrange)
  as $$ select $1, '[1,10]' $$ language sql;
---END---
---START---
--should fail
create function table_fail(i anyelement) returns table(i anyelement, r anyrange)
  as $$ select $1, '[1,10]' $$ language sql;
---END---
