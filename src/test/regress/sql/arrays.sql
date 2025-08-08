---START---
--
-- ARRAYS
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

CREATE TABLE arrtest (
	a 			int2[],
	b 			int4[][][],
	c 			name[],
	d			text[][],
	e 			float8[],
	f			char(5)[],
	g			varchar(5)[]
);
---END---
---START---
CREATE TABLE array_op_test (gemini_pk serial PRIMARY KEY, seqno int4, i int4[], t text[]);
---END---
---START---
\set filename :abs_srcdir '/data/array.data'
COPY array_op_test FROM :'filename';
---END---
---START---
ANALYZE array_op_test;
---END---
---START---
--
-- only the 'e' array is 0-based, the others are 1-based.
--

INSERT INTO arrtest (a[1:5], b[1:1][1:2][1:2], c, d, f, g)
   VALUES ('{1,2,3,4,5}', '{{{0,0},{1,2}}}', '{}', '{}', '{}', '{}');
---END---
---START---
UPDATE arrtest SET e[0] = '1.1';
---END---
---START---
UPDATE arrtest SET e[1] = '2.2';
---END---
---START---
INSERT INTO arrtest (f)
   VALUES ('{"too long"}');
---END---
---START---
INSERT INTO arrtest (a, b[1:2][1:2], c, d, e, f, g)
   VALUES ('{11,12,23}', '{{3,4},{4,5}}', '{"foobar"}',
           '{{"elt1", "elt2"}}', '{"3.4", "6.7"}',
           '{"abc","abcde"}', '{"abc","abcde"}');
---END---
---START---
INSERT INTO arrtest (a, b[1:2], c, d[1:2])
   VALUES ('{}', '{3,4}', '{foo,bar}', '{bar,foo}');
---END---
---START---
INSERT INTO arrtest (b[2]) VALUES(now());
---END---
---START---
-- error, type mismatch

INSERT INTO arrtest (b[1:2]) VALUES(now());
---END---
---START---
-- error, type mismatch

SELECT * FROM arrtest;
---END---
---START---
SELECT arrtest.a[1],
          arrtest.b[1][1][1],
          arrtest.c[1],
          arrtest.d[1][1],
          arrtest.e[0]
   FROM arrtest;
---END---
---START---
SELECT a[1], b[1][1][1], c[1], d[1][1], e[0]
   FROM arrtest;
---END---
---START---
SELECT a[1:3],
          b[1:1][1:2][1:2],
          c[1:2],
          d[1:1][1:2]
   FROM arrtest;
---END---
---START---
SELECT array_ndims(a) AS a,array_ndims(b) AS b,array_ndims(c) AS c
   FROM arrtest;
---END---
---START---
SELECT array_dims(a) AS a,array_dims(b) AS b,array_dims(c) AS c
   FROM arrtest;
---END---
---START---
-- returns nothing
SELECT *
   FROM arrtest
   WHERE a[1] < 5 and
         c = '{"foobar"}'::_name;
---END---
---START---
UPDATE arrtest
  SET a[1:2] = '{16,25}'
  WHERE NOT a = '{}'::_int2;
---END---
---START---
UPDATE arrtest
  SET b[1:1][1:1][1:2] = '{113, 117}',
      b[1:1][1:2][2:2] = '{142, 147}'
  WHERE array_dims(b) = '[1:1][1:2][1:2]';
---END---
---START---
UPDATE arrtest
  SET c[2:2] = '{"new_word"}'
  WHERE array_dims(c) is not null;
---END---
---START---
SELECT a,b,c FROM arrtest;
---END---
---START---
SELECT a[1:3],
          b[1:1][1:2][1:2],
          c[1:2],
          d[1:1][2:2]
   FROM arrtest;
---END---
---START---
SELECT b[1:1][2][2],
       d[1:1][2]
   FROM arrtest;
---END---
---START---
INSERT INTO arrtest(a) VALUES('{1,null,3}');
---END---
---START---
SELECT a FROM arrtest;
---END---
---START---
UPDATE arrtest SET a[4] = NULL WHERE a[2] IS NULL;
---END---
---START---
SELECT a FROM arrtest WHERE a[2] IS NULL;
---END---
---START---
DELETE FROM arrtest WHERE a[2] IS NULL AND b IS NULL;
---END---
---START---
SELECT a,b,c FROM arrtest;
---END---
---START---
-- test non-error-throwing API
SELECT pg_input_is_valid('{1,2,3}', 'integer[]');
---END---
---START---
SELECT pg_input_is_valid('{1,2', 'integer[]');
---END---
---START---
SELECT pg_input_is_valid('{1,zed}', 'integer[]');
---END---
---START---
SELECT * FROM pg_input_error_info('{1,zed}', 'integer[]');
---END---
---START---
-- test mixed slice/scalar subscripting
select '{{1,2,3},{4,5,6},{7,8,9}}'::int[];
---END---
---START---
select ('{{1,2,3},{4,5,6},{7,8,9}}'::int[])[1:2][2];
---END---
---START---
select '[0:2][0:2]={{1,2,3},{4,5,6},{7,8,9}}'::int[];
---END---
---START---
select ('[0:2][0:2]={{1,2,3},{4,5,6},{7,8,9}}'::int[])[1:2][2];
---END---
---START---
--
-- check subscription corner cases
--
-- More subscripts than MAXDIM (6)
SELECT ('{}'::int[])[1][2][3][4][5][6][7];
---END---
---START---
-- NULL index yields NULL when selecting
SELECT ('{{{1},{2},{3}},{{4},{5},{6}}}'::int[])[1][NULL][1];
---END---
---START---
SELECT ('{{{1},{2},{3}},{{4},{5},{6}}}'::int[])[1][NULL:1][1];
---END---
---START---
SELECT ('{{{1},{2},{3}},{{4},{5},{6}}}'::int[])[1][1:NULL][1];
---END---
---START---
-- NULL index in assignment is an error
UPDATE arrtest
  SET c[NULL] = '{"can''t assign"}'
  WHERE array_dims(c) is not null;
---END---
---START---
UPDATE arrtest
  SET c[NULL:1] = '{"can''t assign"}'
  WHERE array_dims(c) is not null;
---END---
---START---
UPDATE arrtest
  SET c[1:NULL] = '{"can''t assign"}'
  WHERE array_dims(c) is not null;
---END---
---START---
-- Un-subscriptable type
SELECT (now())[1];
---END---
---START---
-- test slices with empty lower and/or upper index
DROP TABLE IF EXISTS arrtest_s;

CREATE TABLE arrtest_s (gemini_pk serial PRIMARY KEY, a int2[], b int2[][]);
---END---
---START---
INSERT INTO arrtest_s VALUES ('{1,2,3,4,5}', '{{1,2,3}, {4,5,6}, {7,8,9}}');
---END---
---START---
INSERT INTO arrtest_s VALUES ('[0:4]={1,2,3,4,5}', '[0:2][0:2]={{1,2,3}, {4,5,6}, {7,8,9}}');
---END---
---START---
SELECT * FROM arrtest_s;
---END---
---START---
SELECT a[:3], b[:2][:2] FROM arrtest_s;
---END---
---START---
SELECT a[2:], b[2:][2:] FROM arrtest_s;
---END---
---START---
SELECT a[:], b[:] FROM arrtest_s;
---END---
---START---
-- updates
UPDATE arrtest_s SET a[:3] = '{11, 12, 13}', b[:2][:2] = '{{11,12}, {14,15}}'
  WHERE array_lower(a,1) = 1;
---END---
---START---
SELECT * FROM arrtest_s;
---END---
---START---
UPDATE arrtest_s SET a[3:] = '{23, 24, 25}', b[2:][2:] = '{{25,26}, {28,29}}';
---END---
---START---
SELECT * FROM arrtest_s;
---END---
---START---
UPDATE arrtest_s SET a[:] = '{11, 12, 13, 14, 15}';
---END---
---START---
SELECT * FROM arrtest_s;
---END---
---START---
UPDATE arrtest_s SET a[:] = '{23, 24, 25}';
---END---
---START---
-- fail, too small
INSERT INTO arrtest_s VALUES(NULL, NULL);
---END---
---START---
UPDATE arrtest_s SET a[:] = '{11, 12, 13, 14, 15}';
---END---
---START---
-- fail, no good with null

-- we want to work with a point_tbl that includes a null
DROP TABLE IF EXISTS point_tbl;

CREATE TABLE point_tbl AS SELECT * FROM public.point_tbl;
---END---
---START---
INSERT INTO POINT_TBL(f1) VALUES (NULL);
---END---
---START---
-- check with fixed-length-array type, such as point
SELECT f1[0:1] FROM POINT_TBL;
---END---
---START---
SELECT f1[0:] FROM POINT_TBL;
---END---
---START---
SELECT f1[:1] FROM POINT_TBL;
---END---
---START---
SELECT f1[:] FROM POINT_TBL;
---END---
---START---
-- subscript assignments to fixed-width result in NULL if previous value is NULL
UPDATE point_tbl SET f1[0] = 10 WHERE f1 IS NULL RETURNING *;
---END---
---START---
INSERT INTO point_tbl(f1[0]) VALUES(0) RETURNING *;
---END---
---START---
-- NULL assignments get ignored
UPDATE point_tbl SET f1[0] = NULL WHERE f1::text = '(10,10)'::point::text RETURNING *;
---END---
---START---
-- but non-NULL subscript assignments work
UPDATE point_tbl SET f1[0] = -10, f1[1] = -10 WHERE f1::text = '(10,10)'::point::text RETURNING *;
---END---
---START---
-- but not to expand the range
UPDATE point_tbl SET f1[3] = 10 WHERE f1::text = '(-10,-10)'::point::text RETURNING *;
---END---
---START---
--
-- test array extension
--
DROP TABLE IF EXISTS arrtest1;

CREATE TABLE arrtest1 (gemini_pk serial PRIMARY KEY, i integer[], t text[]);
---END---
---START---
insert into arrtest1 values(array[1,2,null,4], array['one','two',null,'four']);
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[2] = 22, t[2] = 'twenty-two';
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[5] = 5, t[5] = 'five';
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[8] = 8, t[8] = 'eight';
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[0] = 0, t[0] = 'zero';
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[-3] = -3, t[-3] = 'minus-three';
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[0:2] = array[10,11,12], t[0:2] = array['ten','eleven','twelve'];
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[8:10] = array[18,null,20], t[8:10] = array['p18',null,'p20'];
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[11:12] = array[null,22], t[11:12] = array[null,'p22'];
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[15:16] = array[null,26], t[15:16] = array[null,'p26'];
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[-5:-3] = array[-15,-14,-13], t[-5:-3] = array['m15','m14','m13'];
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[-7:-6] = array[-17,null], t[-7:-6] = array['m17',null];
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[-12:-10] = array[-22,null,-20], t[-12:-10] = array['m22',null,'m20'];
---END---
---START---
select * from arrtest1;
---END---
---START---
delete from arrtest1;
---END---
---START---
insert into arrtest1 values(array[1,2,null,4], array['one','two',null,'four']);
---END---
---START---
select * from arrtest1;
---END---
---START---
update arrtest1 set i[0:5] = array[0,1,2,null,4,5], t[0:5] = array['z','p1','p2',null,'p4','p5'];
---END---
---START---
select * from arrtest1;
---END---
---START---
--
-- array expressions and operators
--

-- table creation and INSERTs
DROP TABLE IF EXISTS arrtest2;

CREATE TABLE arrtest2 (gemini_pk serial PRIMARY KEY, i integer[4], f float8[], n numeric[], t text[], d timestamp[]);
---END---
---START---
INSERT INTO arrtest2 VALUES(
  ARRAY[[[113,142],[1,147]]],
  ARRAY[1.1,1.2,1.3]::float8[],
  ARRAY[1.1,1.2,1.3],
  ARRAY[[['aaa','aab'],['aba','abb'],['aca','acb']],[['baa','bab'],['bba','bbb'],['bca','bcb']]],
  ARRAY['19620326','19931223','19970117']::timestamp[]
);
---END---
---START---
-- some more test data
DROP TABLE IF EXISTS arrtest_f;

CREATE TABLE arrtest_f (gemini_pk serial PRIMARY KEY, f0 integer, f1 text, f2 float8);
---END---
---START---
insert into arrtest_f values(1,'cat1',1.21);
---END---
---START---
insert into arrtest_f values(2,'cat1',1.24);
---END---
---START---
insert into arrtest_f values(3,'cat1',1.18);
---END---
---START---
insert into arrtest_f values(4,'cat1',1.26);
---END---
---START---
insert into arrtest_f values(5,'cat1',1.15);
---END---
---START---
insert into arrtest_f values(6,'cat2',1.15);
---END---
---START---
insert into arrtest_f values(7,'cat2',1.26);
---END---
---START---
insert into arrtest_f values(8,'cat2',1.32);
---END---
---START---
insert into arrtest_f values(9,'cat2',1.30);
---END---
---START---
DROP TABLE IF EXISTS arrtest_i;

CREATE TABLE arrtest_i (gemini_pk serial PRIMARY KEY, f0 integer, f1 text, f2 integer);
---END---
---START---
insert into arrtest_i values(1,'cat1',21);
---END---
---START---
insert into arrtest_i values(2,'cat1',24);
---END---
---START---
insert into arrtest_i values(3,'cat1',18);
---END---
---START---
insert into arrtest_i values(4,'cat1',26);
---END---
---START---
insert into arrtest_i values(5,'cat1',15);
---END---
---START---
insert into arrtest_i values(6,'cat2',15);
---END---
---START---
insert into arrtest_i values(7,'cat2',26);
---END---
---START---
insert into arrtest_i values(8,'cat2',32);
---END---
---START---
insert into arrtest_i values(9,'cat2',30);
---END---
---START---
-- expressions
SELECT t.f[1][3][1] AS "131", t.f[2][2][1] AS "221" FROM (
  SELECT ARRAY[[[111,112],[121,122],[131,132]],[[211,212],[221,122],[231,232]]] AS f
) AS t;
---END---
---START---
SELECT ARRAY[[[[[['hello'],['world']]]]]];
---END---
---START---
SELECT ARRAY[ARRAY['hello'],ARRAY['world']];
---END---
---START---
SELECT ARRAY(select f2 from arrtest_f order by f2) AS "ARRAY";
---END---
---START---
-- with nulls
SELECT '{1,null,3}'::int[];
---END---
---START---
SELECT ARRAY[1,NULL,3];
---END---
---START---
-- functions
SELECT array_append(array[42], 6) AS "{42,6}";
---END---
---START---
SELECT array_prepend(6, array[42]) AS "{6,42}";
---END---
---START---
SELECT array_cat(ARRAY[1,2], ARRAY[3,4]) AS "{1,2,3,4}";
---END---
---START---
SELECT array_cat(ARRAY[1,2], ARRAY[[3,4],[5,6]]) AS "{{1,2},{3,4},{5,6}}";
---END---
---START---
SELECT array_cat(ARRAY[[3,4],[5,6]], ARRAY[1,2]) AS "{{3,4},{5,6},{1,2}}";
---END---
---START---
SELECT array_position(ARRAY[1,2,3,4,5], 4);
---END---
---START---
SELECT array_position(ARRAY[5,3,4,2,1], 4);
---END---
---START---
SELECT array_position(ARRAY[[1,2],[3,4]], 3);
---END---
---START---
SELECT array_position(ARRAY['sun','mon','tue','wed','thu','fri','sat'], 'mon');
---END---
---START---
SELECT array_position(ARRAY['sun','mon','tue','wed','thu','fri','sat'], 'sat');
---END---
---START---
SELECT array_position(ARRAY['sun','mon','tue','wed','thu','fri','sat'], NULL);
---END---
---START---
SELECT array_position(ARRAY['sun','mon','tue','wed','thu',NULL,'fri','sat'], NULL);
---END---
---START---
SELECT array_position(ARRAY['sun','mon','tue','wed','thu',NULL,'fri','sat'], 'sat');
---END---
---START---
SELECT array_positions(NULL, 10);
---END---
---START---
SELECT array_positions(NULL, NULL::int);
---END---
---START---
SELECT array_positions(ARRAY[1,2,3,4,5,6,1,2,3,4,5,6], 4);
---END---
---START---
SELECT array_positions(ARRAY[[1,2],[3,4]], 4);
---END---
---START---
SELECT array_positions(ARRAY[1,2,3,4,5,6,1,2,3,4,5,6], NULL);
---END---
---START---
SELECT array_positions(ARRAY[1,2,3,NULL,5,6,1,2,3,NULL,5,6], NULL);
---END---
---START---
SELECT array_length(array_positions(ARRAY(SELECT 'AAAAAAAAAAAAAAAAAAAAAAAAA'::text || i % 10
                                          FROM generate_series(1,100) g(i)),
                                  'AAAAAAAAAAAAAAAAAAAAAAAAA5'), 1);
---END---
---START---
DO $$
DECLARE
  o int;
  a int[] := ARRAY[1,2,3,2,3,1,2];
BEGIN
  o := array_position(a, 2);
  WHILE o IS NOT NULL
  LOOP
    RAISE NOTICE '%', o;
    o := array_position(a, 2, o + 1);
  END LOOP;
END
$$ LANGUAGE plpgsql;
---END---
---START---
SELECT array_position('[2:4]={1,2,3}'::int[], 1);
---END---
---START---
SELECT array_positions('[2:4]={1,2,3}'::int[], 1);
---END---
---START---
SELECT
    array_position(ids, (1, 1)),
    array_positions(ids, (1, 1))
        FROM
(VALUES
    (ARRAY[(0, 0), (1, 1)]),
    (ARRAY[(1, 1)])
) AS f (ids);
---END---
---START---
-- operators
SELECT a FROM arrtest WHERE b = ARRAY[[[113,142],[1,147]]];
---END---
---START---
SELECT NOT ARRAY[1.1,1.2,1.3] = ARRAY[1.1,1.2,1.3] AS "FALSE";
---END---
---START---
SELECT ARRAY[1,2] || 3 AS "{1,2,3}";
---END---
---START---
SELECT 0 || ARRAY[1,2] AS "{0,1,2}";
---END---
---START---
SELECT ARRAY[1,2] || ARRAY[3,4] AS "{1,2,3,4}";
---END---
---START---
SELECT ARRAY[[['hello','world']]] || ARRAY[[['happy','birthday']]] AS "ARRAY";
---END---
---START---
SELECT ARRAY[[1,2],[3,4]] || ARRAY[5,6] AS "{{1,2},{3,4},{5,6}}";
---END---
---START---
SELECT ARRAY[0,0] || ARRAY[1,1] || ARRAY[2,2] AS "{0,0,1,1,2,2}";
---END---
---START---
SELECT 0 || ARRAY[1,2] || 3 AS "{0,1,2,3}";
---END---
---START---
SELECT ARRAY[1.1] || ARRAY[2,3,4];
---END---
---START---
SELECT array_agg(x) || array_agg(x) FROM (VALUES (ROW(1,2)), (ROW(3,4))) v(x);
---END---
---START---
SELECT ROW(1,2) || array_agg(x) FROM (VALUES (ROW(3,4)), (ROW(5,6))) v(x);
---END---
---START---
SELECT * FROM array_op_test WHERE i @> '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i && '{32}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i @> '{17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i && '{17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i @> '{32,17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i && '{32,17}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i <@ '{38,34,32,89}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i = '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i @> '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i && '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i <@ '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i = '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i @> '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i && '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE i <@ '{NULL}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t @> '{AAAAAAAA72908}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t && '{AAAAAAAA72908}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t @> '{AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t && '{AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t @> '{AAAAAAAA72908,AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t && '{AAAAAAAA72908,AAAAAAAAAA646}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t <@ '{AAAAAAAA72908,AAAAAAAAAAAAAAAAAAA17075,AA88409,AAAAAAAAAAAAAAAAAA36842,AAAAAAA48038,AAAAAAAAAAAAAA10611}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t = '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t @> '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t && '{}' ORDER BY seqno;
---END---
---START---
SELECT * FROM array_op_test WHERE t <@ '{}' ORDER BY seqno;
---END---
---START---
-- array casts
SELECT ARRAY[1,2,3]::text[]::int[]::float8[] AS "{1,2,3}";
---END---
---START---
SELECT pg_typeof(ARRAY[1,2,3]::text[]::int[]::float8[]) AS "double precision[]";
---END---
---START---
SELECT ARRAY[['a','bc'],['def','hijk']]::text[]::varchar[] AS "{{a,bc},{def,hijk}}";
---END---
---START---
SELECT pg_typeof(ARRAY[['a','bc'],['def','hijk']]::text[]::varchar[]) AS "character varying[]";
---END---
---START---
SELECT CAST(ARRAY[[[[[['a','bb','ccc']]]]]] as text[]) as "{{{{{{a,bb,ccc}}}}}}";
---END---
---START---
SELECT NULL::text[]::int[] AS "NULL";
---END---
---START---
-- scalar op any/all (array)
select 33 = any ('{1,2,3}');
---END---
---START---
select 33 = any ('{1,2,33}');
---END---
---START---
select 33 = all ('{1,2,33}');
---END---
---START---
select 33 >= all ('{1,2,33}');
---END---
---START---
-- boundary cases
select null::int >= all ('{1,2,33}');
---END---
---START---
select null::int >= all ('{}');
---END---
---START---
select null::int >= any ('{}');
---END---
---START---
-- cross-datatype
select 33.4 = any (array[1,2,3]);
---END---
---START---
select 33.4 > all (array[1,2,3]);
---END---
---START---
-- errors
select 33 * any ('{1,2,3}');
---END---
---START---
select 33 * any (44);
---END---
---START---
-- nulls
select 33 = any (null::int[]);
---END---
---START---
select null::int = any ('{1,2,3}');
---END---
---START---
select 33 = any ('{1,null,3}');
---END---
---START---
select 33 = any ('{1,null,33}');
---END---
---START---
select 33 = all (null::int[]);
---END---
---START---
select null::int = all ('{1,2,3}');
---END---
---START---
select 33 = all ('{1,null,3}');
---END---
---START---
select 33 = all ('{33,null,33}');
---END---
---START---
-- nulls later in the bitmap
SELECT -1 != ALL(ARRAY(SELECT NULLIF(g.i, 900) FROM generate_series(1,1000) g(i)));
---END---
---START---
-- test indexes on arrays
DROP TABLE IF EXISTS arr_tbl;

CREATE TABLE arr_tbl (gemini_pk serial PRIMARY KEY, f1 integer[] UNIQUE);
---END---
---START---
insert into arr_tbl values ('{1,2,3}');
---END---
---START---
insert into arr_tbl values ('{1,2}');
---END---
---START---
-- failure expected:
insert into arr_tbl values ('{1,2,3}');
---END---
---START---
insert into arr_tbl values ('{2,3,4}');
---END---
---START---
insert into arr_tbl values ('{1,5,3}');
---END---
---START---
insert into arr_tbl values ('{1,2,10}');
---END---
---START---
set enable_seqscan to off;
---END---
---START---
set enable_bitmapscan to off;
---END---
---START---
select * from arr_tbl where f1 > '{1,2,3}' and f1 <= '{1,5,3}';
---END---
---START---
select * from arr_tbl where f1 >= '{1,2,3}' and f1 < '{1,5,3}';
---END---
---START---
-- test ON CONFLICT DO UPDATE with arrays
DROP TABLE IF EXISTS arr_pk_tbl;

create table arr_pk_tbl (pk int4 primary key, f1 int[]);
---END---
---START---
insert into arr_pk_tbl values (1, '{1,2,3}');
---END---
---START---
insert into arr_pk_tbl values (1, '{3,4,5}') on conflict (pk)
  do update set f1[1] = excluded.f1[1], f1[3] = excluded.f1[3]
  returning pk, f1;
---END---
---START---
insert into arr_pk_tbl(pk, f1[1:2]) values (1, '{6,7,8}') on conflict (pk)
  do update set f1[1] = excluded.f1[1],
    f1[2] = excluded.f1[2],
    f1[3] = excluded.f1[3]
  returning pk, f1;
---END---
---START---
-- note: if above selects don't produce the expected tuple order,
-- then you didn't get an indexscan plan, and something is busted.
reset enable_seqscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---
-- test [not] (like|ilike) (any|all) (...)
select 'foo' like any (array['%a', '%o']);
---END---
---START---
-- t
select 'foo' like any (array['%a', '%b']);
---END---
---START---
-- f
select 'foo' like all (array['f%', '%o']);
---END---
---START---
-- t
select 'foo' like all (array['f%', '%b']);
---END---
---START---
-- f
select 'foo' not like any (array['%a', '%b']);
---END---
---START---
-- t
select 'foo' not like all (array['%a', '%o']);
---END---
---START---
-- f
select 'foo' ilike any (array['%A', '%O']);
---END---
---START---
-- t
select 'foo' ilike all (array['F%', '%O']);
---END---
---START---
-- t

--
-- General array parser tests
--

-- none of the following should be accepted
select '{{1,{2}},{2,3}}'::text[];
---END---
---START---
select '{{},{}}'::text[];
---END---
---START---
select E'{{1,2},\\{2,3}}'::text[];
---END---
---START---
select '{{"1 2" x},{3}}'::text[];
---END---
---START---
select '{}}'::text[];
---END---
---START---
select '{ }}'::text[];
---END---
---START---
select array[];
---END---
---START---
-- none of the above should be accepted

-- all of the following should be accepted
select '{}'::text[];
---END---
---START---
select '{{{1,2,3,4},{2,3,4,5}},{{3,4,5,6},{4,5,6,7}}}'::text[];
---END---
---START---
select '{0 second  ,0 second}'::interval[];
---END---
---START---
select '{ { "," } , { 3 } }'::text[];
---END---
---START---
select '  {   {  "  0 second  "   ,  0 second  }   }'::text[];
---END---
---START---
select '{
           0 second,
           @ 1 hour @ 42 minutes @ 20 seconds
         }'::interval[];
---END---
---START---
select array[]::text[];
---END---
---START---
select '[0:1]={1.1,2.2}'::float8[];
---END---
---START---
-- all of the above should be accepted

-- tests for array aggregates
DROP TABLE IF EXISTS arraggtest;

CREATE TABLE arraggtest (gemini_pk serial PRIMARY KEY, f1 integer[], f2 text[][], f3 double precision[]);
---END---
---START---
INSERT INTO arraggtest (f1, f2, f3) VALUES
('{1,2,3,4}','{{grey,red},{blue,blue}}','{1.6, 0.0}');
---END---
---START---
INSERT INTO arraggtest (f1, f2, f3) VALUES
('{1,2,3}','{{grey,red},{grey,blue}}','{1.6}');
---END---
---START---
SELECT max(f1), min(f1), max(f2), min(f2), max(f3), min(f3) FROM arraggtest;
---END---
---START---
INSERT INTO arraggtest (f1, f2, f3) VALUES
('{3,3,2,4,5,6}','{{white,yellow},{pink,orange}}','{2.1,3.3,1.8,1.7,1.6}');
---END---
---START---
SELECT max(f1), min(f1), max(f2), min(f2), max(f3), min(f3) FROM arraggtest;
---END---
---START---
INSERT INTO arraggtest (f1, f2, f3) VALUES
('{2}','{{black,red},{green,orange}}','{1.6,2.2,2.6,0.4}');
---END---
---START---
SELECT max(f1), min(f1), max(f2), min(f2), max(f3), min(f3) FROM arraggtest;
---END---
---START---
INSERT INTO arraggtest (f1, f2, f3) VALUES
('{4,2,6,7,8,1}','{{red},{black},{purple},{blue},{blue}}',NULL);
---END---
---START---
SELECT max(f1), min(f1), max(f2), min(f2), max(f3), min(f3) FROM arraggtest;
---END---
---START---
INSERT INTO arraggtest (f1, f2, f3) VALUES
('{}','{{pink,white,blue,red,grey,orange}}','{2.1,1.87,1.4,2.2}');
---END---
---START---
SELECT max(f1), min(f1), max(f2), min(f2), max(f3), min(f3) FROM arraggtest;
---END---
---START---
-- A few simple tests for arrays of composite types

create type comptype as (f1 int, f2 text);
---END---
---START---
CREATE TABLE comptable (gemini_pk serial PRIMARY KEY, c1 comptype, c2 comptype[]);
---END---
---START---
-- XXX would like to not have to specify row() construct types here ...
insert into comptable
  values (row(1,'foo'), array[row(2,'bar')::comptype, row(3,'baz')::comptype]);
---END---
---START---
-- check that implicitly named array type _comptype isn't a problem
create type _comptype as enum('fooey');
---END---
---START---
select * from comptable;
---END---
---START---
select c2[2].f2 from comptable;
---END---
---START---
drop type _comptype;
---END---
---START---
drop table comptable;
---END---
---START---
drop type comptype;
---END---
---START---
create or replace function unnest1(anyarray)
returns setof anyelement as $$
select $1[s] from generate_subscripts($1,1) g(s);
$$ language sql immutable;
---END---
---START---
create or replace function unnest2(anyarray)
returns setof anyelement as $$
select $1[s1][s2] from generate_subscripts($1,1) g1(s1),
                   generate_subscripts($1,2) g2(s2);
$$ language sql immutable;
---END---
---START---
select * from unnest1(array[1,2,3]);
---END---
---START---
select * from unnest2(array[[1,2,3],[4,5,6]]);
---END---
---START---
drop function unnest1(anyarray);
---END---
---START---
drop function unnest2(anyarray);
---END---
---START---
select array_fill(null::integer, array[3,3],array[2,2]);
---END---
---START---
select array_fill(null::integer, array[3,3]);
---END---
---START---
select array_fill(null::text, array[3,3],array[2,2]);
---END---
---START---
select array_fill(null::text, array[3,3]);
---END---
---START---
select array_fill(7, array[3,3],array[2,2]);
---END---
---START---
select array_fill(7, array[3,3]);
---END---
---START---
select array_fill('juhu'::text, array[3,3],array[2,2]);
---END---
---START---
select array_fill('juhu'::text, array[3,3]);
---END---
---START---
select a, a = '{}' as is_eq, array_dims(a)
  from (select array_fill(42, array[0]) as a) ss;
---END---
---START---
select a, a = '{}' as is_eq, array_dims(a)
  from (select array_fill(42, '{}') as a) ss;
---END---
---START---
select a, a = '{}' as is_eq, array_dims(a)
  from (select array_fill(42, '{}', '{}') as a) ss;
---END---
---START---
-- raise exception
select array_fill(1, null, array[2,2]);
---END---
---START---
select array_fill(1, array[2,2], null);
---END---
---START---
select array_fill(1, array[2,2], '{}');
---END---
---START---
select array_fill(1, array[3,3], array[1,1,1]);
---END---
---START---
select array_fill(1, array[1,2,null]);
---END---
---START---
select array_fill(1, array[[1,2],[3,4]]);
---END---
---START---
select string_to_array('1|2|3', '|');
---END---
---START---
select string_to_array('1|2|3|', '|');
---END---
---START---
select string_to_array('1||2|3||', '||');
---END---
---START---
select string_to_array('1|2|3', '');
---END---
---START---
select string_to_array('', '|');
---END---
---START---
select string_to_array('1|2|3', NULL);
---END---
---START---
select string_to_array(NULL, '|') IS NULL;
---END---
---START---
select string_to_array('abc', '');
---END---
---START---
select string_to_array('abc', '', 'abc');
---END---
---START---
select string_to_array('abc', ',');
---END---
---START---
select string_to_array('abc', ',', 'abc');
---END---
---START---
select string_to_array('1,2,3,4,,6', ',');
---END---
---START---
select string_to_array('1,2,3,4,,6', ',', '');
---END---
---START---
select string_to_array('1,2,3,4,*,6', ',', '*');
---END---
---START---
select v, v is null as "is null" from string_to_table('1|2|3', '|') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1|2|3|', '|') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1||2|3||', '||') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1|2|3', '') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('', '|') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1|2|3', NULL) g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table(NULL, '|') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('abc', '') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('abc', '', 'abc') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('abc', ',') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('abc', ',', 'abc') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1,2,3,4,,6', ',') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1,2,3,4,,6', ',', '') g(v);
---END---
---START---
select v, v is null as "is null" from string_to_table('1,2,3,4,*,6', ',', '*') g(v);
---END---
---START---
select array_to_string(NULL::int4[], ',') IS NULL;
---END---
---START---
select array_to_string('{}'::int4[], ',');
---END---
---START---
select array_to_string(array[1,2,3,4,NULL,6], ',');
---END---
---START---
select array_to_string(array[1,2,3,4,NULL,6], ',', '*');
---END---
---START---
select array_to_string(array[1,2,3,4,NULL,6], NULL);
---END---
---START---
select array_to_string(array[1,2,3,4,NULL,6], ',', NULL);
---END---
---START---
select array_to_string(string_to_array('1|2|3', '|'), '|');
---END---
---START---
select array_length(array[1,2,3], 1);
---END---
---START---
select array_length(array[[1,2,3], [4,5,6]], 0);
---END---
---START---
select array_length(array[[1,2,3], [4,5,6]], 1);
---END---
---START---
select array_length(array[[1,2,3], [4,5,6]], 2);
---END---
---START---
select array_length(array[[1,2,3], [4,5,6]], 3);
---END---
---START---
select cardinality(NULL::int[]);
---END---
---START---
select cardinality('{}'::int[]);
---END---
---START---
select cardinality(array[1,2,3]);
---END---
---START---
select cardinality('[2:4]={5,6,7}'::int[]);
---END---
---START---
select cardinality('{{1,2}}'::int[]);
---END---
---START---
select cardinality('{{1,2},{3,4},{5,6}}'::int[]);
---END---
---START---
select cardinality('{{{1,9},{5,6}},{{2,3},{3,4}}}'::int[]);
---END---
---START---
-- array_agg(anynonarray)
select array_agg(unique1) from (select unique1 from tenk1 where unique1 < 15 order by unique1) ss;
---END---
---START---
select array_agg(ten) from (select ten from tenk1 where unique1 < 15 order by unique1) ss;
---END---
---START---
select array_agg(nullif(ten, 4)) from (select ten from tenk1 where unique1 < 15 order by unique1) ss;
---END---
---START---
select array_agg(unique1) from tenk1 where unique1 < -15;
---END---
---START---
-- array_agg(anyarray)
select array_agg(ar)
  from (values ('{1,2}'::int[]), ('{3,4}'::int[])) v(ar);
---END---
---START---
select array_agg(distinct ar order by ar desc)
  from (select array[i / 2] from generate_series(1,10) a(i)) b(ar);
---END---
---START---
select array_agg(ar)
  from (select array_agg(array[i, i+1, i-1])
        from generate_series(1,2) a(i)) b(ar);
---END---
---START---
select array_agg(array[i+1.2, i+1.3, i+1.4]) from generate_series(1,3) g(i);
---END---
---START---
select array_agg(array['Hello', i::text]) from generate_series(9,11) g(i);
---END---
---START---
select array_agg(array[i, nullif(i, 3), i+1]) from generate_series(1,4) g(i);
---END---
---START---
-- errors
select array_agg('{}'::int[]) from generate_series(1,2);
---END---
---START---
select array_agg(null::int[]) from generate_series(1,2);
---END---
---START---
select array_agg(ar)
  from (values ('{1,2}'::int[]), ('{3}'::int[])) v(ar);
---END---
---START---
select unnest(array[1,2,3]);
---END---
---START---
select * from unnest(array[1,2,3]);
---END---
---START---
select unnest(array[1,2,3,4.5]::float8[]);
---END---
---START---
select unnest(array[1,2,3,4.5]::numeric[]);
---END---
---START---
select unnest(array[1,2,3,null,4,null,null,5,6]);
---END---
---START---
select unnest(array[1,2,3,null,4,null,null,5,6]::text[]);
---END---
---START---
select abs(unnest(array[1,2,null,-3]));
---END---
---START---
select array_remove(array[1,2,2,3], 2);
---END---
---START---
select array_remove(array[1,2,2,3], 5);
---END---
---START---
select array_remove(array[1,NULL,NULL,3], NULL);
---END---
---START---
select array_remove(array['A','CC','D','C','RR'], 'RR');
---END---
---START---
select array_remove(array[1.0, 2.1, 3.3], 1);
---END---
---START---
select array_remove('{{1,2,2},{1,4,3}}', 2);
---END---
---START---
-- not allowed
select array_remove(array['X','X','X'], 'X') = '{}';
---END---
---START---
select array_replace(array[1,2,5,4],5,3);
---END---
---START---
select array_replace(array[1,2,5,4],5,NULL);
---END---
---START---
select array_replace(array[1,2,NULL,4,NULL],NULL,5);
---END---
---START---
select array_replace(array['A','B','DD','B'],'B','CC');
---END---
---START---
select array_replace(array[1,NULL,3],NULL,NULL);
---END---
---START---
select array_replace(array['AB',NULL,'CDE'],NULL,'12');
---END---
---START---
-- array(select array-value ...)
select array(select array[i,i/2] from generate_series(1,5) i);
---END---
---START---
select array(select array['Hello', i::text] from generate_series(9,11) i);
---END---
---START---
-- Insert/update on a column that is array of composite

DROP TABLE IF EXISTS t1;

CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, f1 int8_tbl[]);
---END---
---START---
insert into t1 (f1[5].q1) values(42);
---END---
---START---
select * from t1;
---END---
---START---
update t1 set f1[5].q2 = 43;
---END---
---START---
select * from t1;
---END---
---START---
-- Check that arrays of composites are safely detoasted when needed

DROP TABLE IF EXISTS src;

CREATE TABLE src (gemini_pk serial PRIMARY KEY, f1 text);
---END---
---START---
insert into src
  select string_agg(random()::text,'') from generate_series(1,10000);
---END---
---START---
create type textandtext as (c1 text, c2 text);
---END---
---START---
DROP TABLE IF EXISTS dest;

CREATE TABLE dest (gemini_pk serial PRIMARY KEY, f1 textandtext[]);
---END---
---START---
insert into dest select array[row(f1,f1)::textandtext] from src;
---END---
---START---
select length(fipshash((f1[1]).c2)) from dest;
---END---
---START---
delete from src;
---END---
---START---
select length(fipshash((f1[1]).c2)) from dest;
---END---
---START---
truncate table src;
---END---
---START---
drop table src;
---END---
---START---
select length(fipshash((f1[1]).c2)) from dest;
---END---
---START---
drop table dest;
---END---
---START---
drop type textandtext;
---END---
---START---
-- Tests for polymorphic-array form of width_bucket()

-- this exercises the varwidth and float8 code paths
SELECT
    op,
    width_bucket(op::numeric, ARRAY[1, 3, 5, 10.0]::numeric[]) AS wb_n1,
    width_bucket(op::numeric, ARRAY[0, 5.5, 9.99]::numeric[]) AS wb_n2,
    width_bucket(op::numeric, ARRAY[-6, -5, 2.0]::numeric[]) AS wb_n3,
    width_bucket(op::float8, ARRAY[1, 3, 5, 10.0]::float8[]) AS wb_f1,
    width_bucket(op::float8, ARRAY[0, 5.5, 9.99]::float8[]) AS wb_f2,
    width_bucket(op::float8, ARRAY[-6, -5, 2.0]::float8[]) AS wb_f3
FROM (VALUES
  (-5.2),
  (-0.0000000001),
  (0.000000000001),
  (1),
  (1.99999999999999),
  (2),
  (2.00000000000001),
  (3),
  (4),
  (4.5),
  (5),
  (5.5),
  (6),
  (7),
  (8),
  (9),
  (9.99999999999999),
  (10),
  (10.0000000000001)
) v(op);
---END---
---START---
-- ensure float8 path handles NaN properly
SELECT
    op,
    width_bucket(op, ARRAY[1, 3, 9, 'NaN', 'NaN']::float8[]) AS wb
FROM (VALUES
  (-5.2::float8),
  (4::float8),
  (77::float8),
  ('NaN'::float8)
) v(op);
---END---
---START---
-- these exercise the generic fixed-width code path
SELECT
    op,
    width_bucket(op, ARRAY[1, 3, 5, 10]) AS wb_1
FROM generate_series(0,11) as op;
---END---
---START---
SELECT width_bucket(now(),
                    array['yesterday', 'today', 'tomorrow']::timestamptz[]);
---END---
---START---
-- corner cases
SELECT width_bucket(5, ARRAY[3]);
---END---
---START---
SELECT width_bucket(5, '{}');
---END---
---START---
-- error cases
SELECT width_bucket('5'::text, ARRAY[3, 4]::integer[]);
---END---
---START---
SELECT width_bucket(5, ARRAY[3, 4, NULL]);
---END---
---START---
SELECT width_bucket(5, ARRAY[ARRAY[1, 2], ARRAY[3, 4]]);
---END---
---START---
-- trim_array

SELECT arr, trim_array(arr, 2)
FROM
(VALUES ('{1,2,3,4,5,6}'::bigint[]),
        ('{1,2}'),
        ('[10:16]={1,2,3,4,5,6,7}'),
        ('[-15:-10]={1,2,3,4,5,6}'),
        ('{{1,10},{2,20},{3,30},{4,40}}')) v(arr);
---END---
---START---
SELECT trim_array(ARRAY[1, 2, 3], -1);
---END---
---START---
-- fail
SELECT trim_array(ARRAY[1, 2, 3], 10);
---END---
---START---
-- fail
SELECT trim_array(ARRAY[]::int[], 1);
---END---
---START---
-- fail

-- array_shuffle
SELECT array_shuffle('{1,2,3,4,5,6}'::int[]) <@ '{1,2,3,4,5,6}';
---END---
---START---
SELECT array_shuffle('{1,2,3,4,5,6}'::int[]) @> '{1,2,3,4,5,6}';
---END---
---START---
SELECT array_dims(array_shuffle('[-1:2][2:3]={{1,2},{3,NULL},{5,6},{7,8}}'::int[]));
---END---
---START---
SELECT array_dims(array_shuffle('{{{1,2},{3,NULL}},{{5,6},{7,8}},{{9,10},{11,12}}}'::int[]));
---END---
---START---
-- array_sample
SELECT array_sample('{1,2,3,4,5,6}'::int[], 3) <@ '{1,2,3,4,5,6}';
---END---
---START---
SELECT array_length(array_sample('{1,2,3,4,5,6}'::int[], 3), 1);
---END---
---START---
SELECT array_dims(array_sample('[-1:2][2:3]={{1,2},{3,NULL},{5,6},{7,8}}'::int[], 3));
---END---
---START---
SELECT array_dims(array_sample('{{{1,2},{3,NULL}},{{5,6},{7,8}},{{9,10},{11,12}}}'::int[], 2));
---END---
---START---
SELECT array_sample('{1,2,3,4,5,6}'::int[], -1);
---END---
---START---
-- fail
SELECT array_sample('{1,2,3,4,5,6}'::int[], 7);
---END---
