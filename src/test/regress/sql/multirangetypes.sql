---START---
-- Tests for multirange data types.

--
-- test input parser
--

-- negative tests; should fail
select ''::textmultirange;
---END---
---START---
select '{,}'::textmultirange;
---END---
---START---
select '{(,)}.'::textmultirange;
---END---
---START---
select '{[a,c),}'::textmultirange;
---END---
---START---
select '{,[a,c)}'::textmultirange;
---END---
---START---
select '{-[a,z)}'::textmultirange;
---END---
---START---
select '{[a,z) - }'::textmultirange;
---END---
---START---
select '{(",a)}'::textmultirange;
---END---
---START---
select '{(,,a)}'::textmultirange;
---END---
---START---
select '{(),a)}'::textmultirange;
---END---
---START---
select '{(a,))}'::textmultirange;
---END---
---START---
select '{(],a)}'::textmultirange;
---END---
---START---
select '{(a,])}'::textmultirange;
---END---
---START---
select '{[z,a]}'::textmultirange;
---END---
---START---
-- should succeed
select '{}'::textmultirange;
---END---
---START---
select '  {}  '::textmultirange;
---END---
---START---
select ' { empty, empty }  '::textmultirange;
---END---
---START---
select ' {( " a " " a ", " z " " z " )  }'::textmultirange;
---END---
---START---
select textrange('\\\\', repeat('a', 200))::textmultirange;
---END---
---START---
select '{(,z)}'::textmultirange;
---END---
---START---
select '{(a,)}'::textmultirange;
---END---
---START---
select '{[,z]}'::textmultirange;
---END---
---START---
select '{[a,]}'::textmultirange;
---END---
---START---
select '{(,)}'::textmultirange;
---END---
---START---
select '{[ , ]}'::textmultirange;
---END---
---START---
select '{["",""]}'::textmultirange;
---END---
---START---
select '{[",",","]}'::textmultirange;
---END---
---START---
select '{["\\","\\"]}'::textmultirange;
---END---
---START---
select '{["""","\""]}'::textmultirange;
---END---
---START---
select '{(\\,a)}'::textmultirange;
---END---
---START---
select '{((,z)}'::textmultirange;
---END---
---START---
select '{([,z)}'::textmultirange;
---END---
---START---
select '{(!,()}'::textmultirange;
---END---
---START---
select '{(!,[)}'::textmultirange;
---END---
---START---
select '{[a,a]}'::textmultirange;
---END---
---START---
select '{[a,a],[a,b]}'::textmultirange;
---END---
---START---
select '{[a,b), [b,e]}'::textmultirange;
---END---
---START---
select '{[a,d), [b,f]}'::textmultirange;
---END---
---START---
select '{[a,a],[b,b]}'::textmultirange;
---END---
---START---
-- without canonicalization, we can't join these:
select '{[a,a], [b,b]}'::textmultirange;
---END---
---START---
-- with canonicalization, we can join these:
select '{[1,2], [3,4]}'::int4multirange;
---END---
---START---
select '{[a,a], [b,b], [c,c]}'::textmultirange;
---END---
---START---
select '{[a,d], [b,e]}'::textmultirange;
---END---
---START---
select '{[a,d), [d,e)}'::textmultirange;
---END---
---START---
-- these are allowed but normalize to empty:
select '{[a,a)}'::textmultirange;
---END---
---START---
select '{(a,a]}'::textmultirange;
---END---
---START---
select '{(a,a)}'::textmultirange;
---END---
---START---
-- Also try it with non-error-throwing API
select pg_input_is_valid('{[1,2], [4,5]}', 'int4multirange');
---END---
---START---
select pg_input_is_valid('{[1,2], [4,5]', 'int4multirange');
---END---
---START---
select * from pg_input_error_info('{[1,2], [4,5]', 'int4multirange');
---END---
---START---
select pg_input_is_valid('{[1,2], [4,zed]}', 'int4multirange');
---END---
---START---
select * from pg_input_error_info('{[1,2], [4,zed]}', 'int4multirange');
---END---
---START---
--
-- test the constructor
---
select textmultirange();
---END---
---START---
select textmultirange(textrange('a', 'c'));
---END---
---START---
select textmultirange(textrange('a', 'c'), textrange('f', 'g'));
---END---
---START---
select textmultirange(textrange('\\\\', repeat('a', 200)), textrange('c', 'd'));
---END---
---START---
--
-- test casts, both a built-in range type and a user-defined one:
--
select 'empty'::int4range::int4multirange;
---END---
---START---
select int4range(1, 3)::int4multirange;
---END---
---START---
select int4range(1, null)::int4multirange;
---END---
---START---
select int4range(null, null)::int4multirange;
---END---
---START---
select 'empty'::textrange::textmultirange;
---END---
---START---
select textrange('a', 'c')::textmultirange;
---END---
---START---
select textrange('a', null)::textmultirange;
---END---
---START---
select textrange(null, null)::textmultirange;
---END---
---START---
--
-- test unnest(multirange) function
--
select unnest(int4multirange(int4range('5', '6'), int4range('1', '2')));
---END---
---START---
select unnest(textmultirange(textrange('a', 'b'), textrange('d', 'e')));
---END---
---START---
select unnest(textmultirange(textrange('\\\\', repeat('a', 200)), textrange('c', 'd')));
---END---
---START---
CREATE TABLE nummultirange_test (_gemini_pk serial PRIMARY KEY, nmr nummultirange);
---END---
---START---
CREATE INDEX nummultirange_test_btree ON nummultirange_test(nmr);
---END---
---START---
INSERT INTO nummultirange_test VALUES('{}');
---END---
---START---
INSERT INTO nummultirange_test VALUES('{[,)}');
---END---
---START---
INSERT INTO nummultirange_test VALUES('{[3,]}');
---END---
---START---
INSERT INTO nummultirange_test VALUES('{[,), [3,]}');
---END---
---START---
INSERT INTO nummultirange_test VALUES('{[, 5)}');
---END---
---START---
INSERT INTO nummultirange_test VALUES(nummultirange());
---END---
---START---
INSERT INTO nummultirange_test VALUES(nummultirange(variadic '{}'::numrange[]));
---END---
---START---
INSERT INTO nummultirange_test VALUES(nummultirange(numrange(1.1, 2.2)));
---END---
---START---
INSERT INTO nummultirange_test VALUES('{empty}');
---END---
---START---
INSERT INTO nummultirange_test VALUES(nummultirange(numrange(1.7, 1.7, '[]'), numrange(1.7, 1.9)));
---END---
---START---
INSERT INTO nummultirange_test VALUES(nummultirange(numrange(1.7, 1.7, '[]'), numrange(1.9, 2.1)));
---END---
---START---
SELECT nmr, isempty(nmr), lower(nmr), upper(nmr) FROM nummultirange_test ORDER BY nmr;
---END---
---START---
SELECT nmr, lower_inc(nmr), lower_inf(nmr), upper_inc(nmr), upper_inf(nmr) FROM nummultirange_test ORDER BY nmr;
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr = '{}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr = '{(,5)}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr = '{[3,)}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr = '{[1.7,1.7]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr = '{[1.7,1.7],[1.9,2.1)}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr < '{}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr < '{[-1000.0, -1000.0]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr < '{[0.0, 1.0]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr < '{[1000.0, 1001.0]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr <= '{}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr <= '{[3,)}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr >= '{}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr >= '{[3,)}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr > '{}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr > '{[-1000.0, -1000.0]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr > '{[0.0, 1.0]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr > '{[1000.0, 1001.0]}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr <> '{}';
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr <> '{(,5)}';
---END---
---START---
select nummultirange(numrange(2.0, 1.0));
---END---
---START---
select nummultirange(numrange(5.0, 6.0), numrange(1.0, 2.0));
---END---
---START---
analyze nummultirange_test;
---END---
---START---
-- overlaps
SELECT * FROM nummultirange_test WHERE range_overlaps_multirange(numrange(4.0, 4.2), nmr);
---END---
---START---
SELECT * FROM nummultirange_test WHERE numrange(4.0, 4.2) && nmr;
---END---
---START---
SELECT * FROM nummultirange_test WHERE multirange_overlaps_range(nmr, numrange(4.0, 4.2));
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr && numrange(4.0, 4.2);
---END---
---START---
SELECT * FROM nummultirange_test WHERE multirange_overlaps_multirange(nmr, nummultirange(numrange(4.0, 4.2), numrange(6.0, 7.0)));
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr && nummultirange(numrange(4.0, 4.2), numrange(6.0, 7.0));
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr && nummultirange(numrange(6.0, 7.0));
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr && nummultirange(numrange(6.0, 7.0), numrange(8.0, 9.0));
---END---
---START---
-- mr contains x
SELECT * FROM nummultirange_test WHERE multirange_contains_elem(nmr, 4.0);
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr @> 4.0;
---END---
---START---
SELECT * FROM nummultirange_test WHERE multirange_contains_range(nmr, numrange(4.0, 4.2));
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr @> numrange(4.0, 4.2);
---END---
---START---
SELECT * FROM nummultirange_test WHERE multirange_contains_multirange(nmr, '{[4.0,4.2), [6.0, 8.0)}');
---END---
---START---
SELECT * FROM nummultirange_test WHERE nmr @> '{[4.0,4.2), [6.0, 8.0)}'::nummultirange;
---END---
---START---
-- x is contained by mr
SELECT * FROM nummultirange_test WHERE elem_contained_by_multirange(4.0, nmr);
---END---
---START---
SELECT * FROM nummultirange_test WHERE 4.0 <@ nmr;
---END---
---START---
SELECT * FROM nummultirange_test WHERE range_contained_by_multirange(numrange(4.0, 4.2), nmr);
---END---
---START---
SELECT * FROM nummultirange_test WHERE numrange(4.0, 4.2) <@ nmr;
---END---
---START---
SELECT * FROM nummultirange_test WHERE multirange_contained_by_multirange('{[4.0,4.2), [6.0, 8.0)}', nmr);
---END---
---START---
SELECT * FROM nummultirange_test WHERE '{[4.0,4.2), [6.0, 8.0)}'::nummultirange <@ nmr;
---END---
---START---
-- overlaps
SELECT 'empty'::numrange && nummultirange();
---END---
---START---
SELECT 'empty'::numrange && nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange() && 'empty'::numrange;
---END---
---START---
SELECT nummultirange(numrange(1,2)) && 'empty'::numrange;
---END---
---START---
SELECT nummultirange() && nummultirange();
---END---
---START---
SELECT nummultirange() && nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) && nummultirange();
---END---
---START---
SELECT nummultirange(numrange(3,4)) && nummultirange(numrange(1,2), numrange(7,8));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(7,8)) && nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(3,4)) && nummultirange(numrange(1,2), numrange(3.5,8));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(3.5,8)) && numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(3.5,8)) && nummultirange(numrange(3,4));
---END---
---START---
select '{(10,20),(30,40),(50,60)}'::nummultirange && '(42,92)'::numrange;
---END---
---START---
-- contains
SELECT nummultirange() @> nummultirange();
---END---
---START---
SELECT nummultirange() @> 'empty'::numrange;
---END---
---START---
SELECT nummultirange(numrange(null,null)) @> numrange(1,2);
---END---
---START---
SELECT nummultirange(numrange(null,null)) @> numrange(null,2);
---END---
---START---
SELECT nummultirange(numrange(null,null)) @> numrange(2,null);
---END---
---START---
SELECT nummultirange(numrange(null,5)) @> numrange(null,3);
---END---
---START---
SELECT nummultirange(numrange(null,5)) @> numrange(null,8);
---END---
---START---
SELECT nummultirange(numrange(5,null)) @> numrange(8,null);
---END---
---START---
SELECT nummultirange(numrange(5,null)) @> numrange(3,null);
---END---
---START---
SELECT nummultirange(numrange(1,5)) @> numrange(8,9);
---END---
---START---
SELECT nummultirange(numrange(1,5)) @> numrange(3,9);
---END---
---START---
SELECT nummultirange(numrange(1,5)) @> numrange(1,4);
---END---
---START---
SELECT nummultirange(numrange(1,5)) @> numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(-4,-2), numrange(1,5)) @> numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(1,5), numrange(8,9)) @> numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(1,5), numrange(8,9)) @> numrange(6,7);
---END---
---START---
SELECT nummultirange(numrange(1,5), numrange(6,9)) @> numrange(6,7);
---END---
---START---
SELECT '{[1,5)}'::nummultirange @> '{[1,5)}';
---END---
---START---
SELECT '{[-4,-2), [1,5)}'::nummultirange @> '{[1,5)}';
---END---
---START---
SELECT '{[1,5), [8,9)}'::nummultirange @> '{[1,5)}';
---END---
---START---
SELECT '{[1,5), [8,9)}'::nummultirange @> '{[6,7)}';
---END---
---START---
SELECT '{[1,5), [6,9)}'::nummultirange @> '{[6,7)}';
---END---
---START---
select '{(10,20),(30,40),(50,60)}'::nummultirange @> '(52,56)'::numrange;
---END---
---START---
SELECT numrange(null,null) @> nummultirange(numrange(1,2));
---END---
---START---
SELECT numrange(null,null) @> nummultirange(numrange(null,2));
---END---
---START---
SELECT numrange(null,null) @> nummultirange(numrange(2,null));
---END---
---START---
SELECT numrange(null,5) @> nummultirange(numrange(null,3));
---END---
---START---
SELECT numrange(null,5) @> nummultirange(numrange(null,8));
---END---
---START---
SELECT numrange(5,null) @> nummultirange(numrange(8,null));
---END---
---START---
SELECT numrange(5,null) @> nummultirange(numrange(3,null));
---END---
---START---
SELECT numrange(1,5) @> nummultirange(numrange(8,9));
---END---
---START---
SELECT numrange(1,5) @> nummultirange(numrange(3,9));
---END---
---START---
SELECT numrange(1,5) @> nummultirange(numrange(1,4));
---END---
---START---
SELECT numrange(1,5) @> nummultirange(numrange(1,5));
---END---
---START---
SELECT numrange(1,9) @> nummultirange(numrange(-4,-2), numrange(1,5));
---END---
---START---
SELECT numrange(1,9) @> nummultirange(numrange(1,5), numrange(8,9));
---END---
---START---
SELECT numrange(1,9) @> nummultirange(numrange(1,5), numrange(6,9));
---END---
---START---
SELECT numrange(1,9) @> nummultirange(numrange(1,5), numrange(6,10));
---END---
---START---
SELECT '{[1,9)}' @> '{[1,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,9)}' @> '{[-4,-2), [1,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,9)}' @> '{[1,5), [8,9)}'::nummultirange;
---END---
---START---
SELECT '{[1,9)}' @> '{[1,5), [6,9)}'::nummultirange;
---END---
---START---
SELECT '{[1,9)}' @> '{[1,5), [6,10)}'::nummultirange;
---END---
---START---
-- is contained by
SELECT nummultirange() <@ nummultirange();
---END---
---START---
SELECT 'empty'::numrange <@ nummultirange();
---END---
---START---
SELECT numrange(1,2) <@ nummultirange(numrange(null,null));
---END---
---START---
SELECT numrange(null,2) <@ nummultirange(numrange(null,null));
---END---
---START---
SELECT numrange(2,null) <@ nummultirange(numrange(null,null));
---END---
---START---
SELECT numrange(null,3) <@ nummultirange(numrange(null,5));
---END---
---START---
SELECT numrange(null,8) <@ nummultirange(numrange(null,5));
---END---
---START---
SELECT numrange(8,null) <@ nummultirange(numrange(5,null));
---END---
---START---
SELECT numrange(3,null) <@ nummultirange(numrange(5,null));
---END---
---START---
SELECT numrange(8,9) <@ nummultirange(numrange(1,5));
---END---
---START---
SELECT numrange(3,9) <@ nummultirange(numrange(1,5));
---END---
---START---
SELECT numrange(1,4) <@ nummultirange(numrange(1,5));
---END---
---START---
SELECT numrange(1,5) <@ nummultirange(numrange(1,5));
---END---
---START---
SELECT numrange(1,5) <@ nummultirange(numrange(-4,-2), numrange(1,5));
---END---
---START---
SELECT numrange(1,5) <@ nummultirange(numrange(1,5), numrange(8,9));
---END---
---START---
SELECT numrange(6,7) <@ nummultirange(numrange(1,5), numrange(8,9));
---END---
---START---
SELECT numrange(6,7) <@ nummultirange(numrange(1,5), numrange(6,9));
---END---
---START---
SELECT '{[1,5)}' <@ '{[1,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,5)}' <@ '{[-4,-2), [1,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,5)}' <@ '{[1,5), [8,9)}'::nummultirange;
---END---
---START---
SELECT '{[6,7)}' <@ '{[1,5), [8,9)}'::nummultirange;
---END---
---START---
SELECT '{[6,7)}' <@ '{[1,5), [6,9)}'::nummultirange;
---END---
---START---
SELECT nummultirange(numrange(1,2)) <@ numrange(null,null);
---END---
---START---
SELECT nummultirange(numrange(null,2)) <@ numrange(null,null);
---END---
---START---
SELECT nummultirange(numrange(2,null)) <@ numrange(null,null);
---END---
---START---
SELECT nummultirange(numrange(null,3)) <@ numrange(null,5);
---END---
---START---
SELECT nummultirange(numrange(null,8)) <@ numrange(null,5);
---END---
---START---
SELECT nummultirange(numrange(8,null)) <@ numrange(5,null);
---END---
---START---
SELECT nummultirange(numrange(3,null)) <@ numrange(5,null);
---END---
---START---
SELECT nummultirange(numrange(8,9)) <@ numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(3,9)) <@ numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(1,4)) <@ numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(1,5)) <@ numrange(1,5);
---END---
---START---
SELECT nummultirange(numrange(-4,-2), numrange(1,5)) <@ numrange(1,9);
---END---
---START---
SELECT nummultirange(numrange(1,5), numrange(8,9)) <@ numrange(1,9);
---END---
---START---
SELECT nummultirange(numrange(1,5), numrange(6,9)) <@ numrange(1,9);
---END---
---START---
SELECT nummultirange(numrange(1,5), numrange(6,10)) <@ numrange(1,9);
---END---
---START---
SELECT '{[1,5)}'::nummultirange <@ '{[1,9)}';
---END---
---START---
SELECT '{[-4,-2), [1,5)}'::nummultirange <@ '{[1,9)}';
---END---
---START---
SELECT '{[1,5), [8,9)}'::nummultirange <@ '{[1,9)}';
---END---
---START---
SELECT '{[1,5), [6,9)}'::nummultirange <@ '{[1,9)}';
---END---
---START---
SELECT '{[1,5), [6,10)}'::nummultirange <@ '{[1,9)}';
---END---
---START---
-- overleft
SELECT 'empty'::numrange &< nummultirange();
---END---
---START---
SELECT 'empty'::numrange &< nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange() &< 'empty'::numrange;
---END---
---START---
SELECT nummultirange(numrange(1,2)) &< 'empty'::numrange;
---END---
---START---
SELECT nummultirange() &< nummultirange();
---END---
---START---
SELECT nummultirange(numrange(1,2)) &< nummultirange();
---END---
---START---
SELECT nummultirange() &< nummultirange(numrange(1,2));
---END---
---START---
SELECT numrange(6,7) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT numrange(1,2) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT numrange(1,4) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT numrange(1,6) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT numrange(3.5,6) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(6,7)) &< numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(1,2)) &< numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(1,4)) &< numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(1,6)) &< numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(3.5,6)) &< numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(6,7)) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,2)) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,4)) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,6)) &< nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(3.5,6)) &< nummultirange(numrange(3,4));
---END---
---START---
-- overright
SELECT nummultirange() &> 'empty'::numrange;
---END---
---START---
SELECT nummultirange(numrange(1,2)) &> 'empty'::numrange;
---END---
---START---
SELECT 'empty'::numrange &> nummultirange();
---END---
---START---
SELECT 'empty'::numrange &> nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange() &> nummultirange();
---END---
---START---
SELECT nummultirange() &> nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) &> nummultirange();
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> numrange(6,7);
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> numrange(1,2);
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> numrange(1,4);
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> numrange(1,6);
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> numrange(3.5,6);
---END---
---START---
SELECT numrange(3,4) &> nummultirange(numrange(6,7));
---END---
---START---
SELECT numrange(3,4) &> nummultirange(numrange(1,2));
---END---
---START---
SELECT numrange(3,4) &> nummultirange(numrange(1,4));
---END---
---START---
SELECT numrange(3,4) &> nummultirange(numrange(1,6));
---END---
---START---
SELECT numrange(3,4) &> nummultirange(numrange(3.5,6));
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> nummultirange(numrange(6,7));
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> nummultirange(numrange(1,4));
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> nummultirange(numrange(1,6));
---END---
---START---
SELECT nummultirange(numrange(3,4)) &> nummultirange(numrange(3.5,6));
---END---
---START---
-- meets
SELECT 'empty'::numrange -|- nummultirange();
---END---
---START---
SELECT 'empty'::numrange -|- nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange() -|- 'empty'::numrange;
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- 'empty'::numrange;
---END---
---START---
SELECT nummultirange() -|- nummultirange();
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- nummultirange();
---END---
---START---
SELECT nummultirange() -|- nummultirange(numrange(1,2));
---END---
---START---
SELECT numrange(1,2) -|- nummultirange(numrange(2,4));
---END---
---START---
SELECT numrange(1,2) -|- nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- numrange(2,4);
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- numrange(3,4);
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- nummultirange(numrange(2,4));
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(5,6)) -|- nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(5,6)) -|- nummultirange(numrange(6,7));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(5,6)) -|- nummultirange(numrange(8,9));
---END---
---START---
SELECT nummultirange(numrange(1,2)) -|- nummultirange(numrange(2,4), numrange(6,7));
---END---
---START---
-- strictly left
select 'empty'::numrange << nummultirange();
---END---
---START---
select numrange(1,2) << nummultirange();
---END---
---START---
select numrange(1,2) << nummultirange(numrange(3,4));
---END---
---START---
select numrange(1,2) << nummultirange(numrange(0,4));
---END---
---START---
select numrange(1,2) << nummultirange(numrange(0,4), numrange(7,8));
---END---
---START---
select nummultirange() << 'empty'::numrange;
---END---
---START---
select nummultirange() << numrange(1,2);
---END---
---START---
select nummultirange(numrange(3,4)) << numrange(3,6);
---END---
---START---
select nummultirange(numrange(0,2)) << numrange(3,6);
---END---
---START---
select nummultirange(numrange(0,2), numrange(7,8)) << numrange(3,6);
---END---
---START---
select nummultirange(numrange(-4,-2), numrange(0,2)) << numrange(3,6);
---END---
---START---
select nummultirange() << nummultirange();
---END---
---START---
select nummultirange() << nummultirange(numrange(1,2));
---END---
---START---
select nummultirange(numrange(1,2)) << nummultirange();
---END---
---START---
select nummultirange(numrange(1,2)) << nummultirange(numrange(1,2));
---END---
---START---
select nummultirange(numrange(1,2)) << nummultirange(numrange(3,4));
---END---
---START---
select nummultirange(numrange(1,2)) << nummultirange(numrange(3,4), numrange(7,8));
---END---
---START---
select nummultirange(numrange(1,2), numrange(4,5)) << nummultirange(numrange(3,4), numrange(7,8));
---END---
---START---
-- strictly right
select nummultirange() >> 'empty'::numrange;
---END---
---START---
select nummultirange() >> numrange(1,2);
---END---
---START---
select nummultirange(numrange(3,4)) >> numrange(1,2);
---END---
---START---
select nummultirange(numrange(0,4)) >> numrange(1,2);
---END---
---START---
select nummultirange(numrange(0,4), numrange(7,8)) >> numrange(1,2);
---END---
---START---
select 'empty'::numrange >> nummultirange();
---END---
---START---
select numrange(1,2) >> nummultirange();
---END---
---START---
select numrange(3,6) >> nummultirange(numrange(3,4));
---END---
---START---
select numrange(3,6) >> nummultirange(numrange(0,2));
---END---
---START---
select numrange(3,6) >> nummultirange(numrange(0,2), numrange(7,8));
---END---
---START---
select numrange(3,6) >> nummultirange(numrange(-4,-2), numrange(0,2));
---END---
---START---
select nummultirange() >> nummultirange();
---END---
---START---
select nummultirange(numrange(1,2)) >> nummultirange();
---END---
---START---
select nummultirange() >> nummultirange(numrange(1,2));
---END---
---START---
select nummultirange(numrange(1,2)) >> nummultirange(numrange(1,2));
---END---
---START---
select nummultirange(numrange(3,4)) >> nummultirange(numrange(1,2));
---END---
---START---
select nummultirange(numrange(3,4), numrange(7,8)) >> nummultirange(numrange(1,2));
---END---
---START---
select nummultirange(numrange(3,4), numrange(7,8)) >> nummultirange(numrange(1,2), numrange(4,5));
---END---
---START---
-- union
SELECT nummultirange() + nummultirange();
---END---
---START---
SELECT nummultirange() + nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) + nummultirange();
---END---
---START---
SELECT nummultirange(numrange(1,2)) + nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) + nummultirange(numrange(2,4));
---END---
---START---
SELECT nummultirange(numrange(1,2)) + nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) + nummultirange(numrange(2,4));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) + nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) + nummultirange(numrange(0,9));
---END---
---START---
-- merge
SELECT range_merge(nummultirange());
---END---
---START---
SELECT range_merge(nummultirange(numrange(1,2)));
---END---
---START---
SELECT range_merge(nummultirange(numrange(1,2), numrange(7,8)));
---END---
---START---
-- minus
SELECT nummultirange() - nummultirange();
---END---
---START---
SELECT nummultirange() - nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) - nummultirange();
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(3,4)) - nummultirange();
---END---
---START---
SELECT nummultirange(numrange(1,2)) - nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) - nummultirange(numrange(2,4));
---END---
---START---
SELECT nummultirange(numrange(1,2)) - nummultirange(numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,4)) - nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,4)) - nummultirange(numrange(2,3));
---END---
---START---
SELECT nummultirange(numrange(1,4)) - nummultirange(numrange(0,8));
---END---
---START---
SELECT nummultirange(numrange(1,4)) - nummultirange(numrange(0,2));
---END---
---START---
SELECT nummultirange(numrange(1,8)) - nummultirange(numrange(0,2), numrange(3,4));
---END---
---START---
SELECT nummultirange(numrange(1,8)) - nummultirange(numrange(2,3), numrange(5,null));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) - nummultirange(numrange(-2,0));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) - nummultirange(numrange(2,4));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) - nummultirange(numrange(3,5));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) - nummultirange(numrange(0,9));
---END---
---START---
SELECT nummultirange(numrange(1,3), numrange(4,5)) - nummultirange(numrange(2,9));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) - nummultirange(numrange(8,9));
---END---
---START---
SELECT nummultirange(numrange(1,2), numrange(4,5)) - nummultirange(numrange(-2,0), numrange(8,9));
---END---
---START---
-- intersection
SELECT nummultirange() * nummultirange();
---END---
---START---
SELECT nummultirange() * nummultirange(numrange(1,2));
---END---
---START---
SELECT nummultirange(numrange(1,2)) * nummultirange();
---END---
---START---
SELECT '{[1,3)}'::nummultirange * '{[1,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,3)}'::nummultirange * '{[0,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,3)}'::nummultirange * '{[0,2)}'::nummultirange;
---END---
---START---
SELECT '{[1,3)}'::nummultirange * '{[2,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,4)}'::nummultirange * '{[2,3)}'::nummultirange;
---END---
---START---
SELECT '{[1,4)}'::nummultirange * '{[0,2), [3,5)}'::nummultirange;
---END---
---START---
SELECT '{[1,4), [7,10)}'::nummultirange * '{[0,8), [9,12)}'::nummultirange;
---END---
---START---
SELECT '{[1,4), [7,10)}'::nummultirange * '{[9,12)}'::nummultirange;
---END---
---START---
SELECT '{[1,4), [7,10)}'::nummultirange * '{[-5,-4), [5,6), [9,12)}'::nummultirange;
---END---
---START---
SELECT '{[1,4), [7,10)}'::nummultirange * '{[0,2), [3,8), [9,12)}'::nummultirange;
---END---
---START---
SELECT '{[1,4), [7,10)}'::nummultirange * '{[0,2), [3,8), [9,12)}'::nummultirange;
---END---
---START---
CREATE TABLE test_multirange_gist (_gemini_pk serial PRIMARY KEY, mr int4multirange);
---END---
---START---
insert into test_multirange_gist select int4multirange(int4range(g, g+10),int4range(g+20, g+30),int4range(g+40, g+50)) from generate_series(1,2000) g;
---END---
---START---
insert into test_multirange_gist select '{}'::int4multirange from generate_series(1,500) g;
---END---
---START---
insert into test_multirange_gist select int4multirange(int4range(g, g+10000)) from generate_series(1,1000) g;
---END---
---START---
insert into test_multirange_gist select int4multirange(int4range(NULL, g*10, '(]'), int4range(g*10, g*20, '(]')) from generate_series(1,100) g;
---END---
---START---
insert into test_multirange_gist select int4multirange(int4range(g*10, g*20, '(]'), int4range(g*20, NULL, '(]')) from generate_series(1,100) g;
---END---
---START---
create index test_mulrirange_gist_idx on test_multirange_gist using gist (mr);
---END---
---START---
-- test statistics and selectivity estimation as well
--
-- We don't check the accuracy of selectivity estimation, but at least check
-- it doesn't fall.
analyze test_multirange_gist;
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
select count(*) from test_multirange_gist where mr = '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr && 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr <@ 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr << 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr >> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr &< 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr &> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr -|- 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr && '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr <@ '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr << '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr >> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr &< '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr &> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr -|- '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr = int4multirange(int4range(10,20), int4range(30,40), int4range(50,60));
---END---
---START---
select count(*) from test_multirange_gist where mr @> 10;
---END---
---START---
select count(*) from test_multirange_gist where mr @> int4range(10,20);
---END---
---START---
select count(*) from test_multirange_gist where mr && int4range(10,20);
---END---
---START---
select count(*) from test_multirange_gist where mr <@ int4range(10,50);
---END---
---START---
select count(*) from test_multirange_gist where mr << int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr >> int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr &< int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr &> int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr -|- int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> int4multirange(int4range(10,20), int4range(30,40));
---END---
---START---
select count(*) from test_multirange_gist where mr && '{(10,20),(30,40),(50,60)}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr <@ '{(10,30),(40,60),(70,90)}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr << int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr >> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr &< int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr &> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr -|- int4multirange(int4range(100,200), int4range(400,500));
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
select count(*) from test_multirange_gist where mr = '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr && 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr <@ 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr << 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr >> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr &< 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr &> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr -|- 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr && '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr <@ '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr << '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr >> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr &< '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr &> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr -|- '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> 'empty'::int4range;
---END---
---START---
select count(*) from test_multirange_gist where mr = int4multirange(int4range(10,20), int4range(30,40), int4range(50,60));
---END---
---START---
select count(*) from test_multirange_gist where mr @> 10;
---END---
---START---
select count(*) from test_multirange_gist where mr @> int4range(10,20);
---END---
---START---
select count(*) from test_multirange_gist where mr && int4range(10,20);
---END---
---START---
select count(*) from test_multirange_gist where mr <@ int4range(10,50);
---END---
---START---
select count(*) from test_multirange_gist where mr << int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr >> int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr &< int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr &> int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr -|- int4range(100,500);
---END---
---START---
select count(*) from test_multirange_gist where mr @> '{}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr @> int4multirange(int4range(10,20), int4range(30,40));
---END---
---START---
select count(*) from test_multirange_gist where mr && '{(10,20),(30,40),(50,60)}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr <@ '{(10,30),(40,60),(70,90)}'::int4multirange;
---END---
---START---
select count(*) from test_multirange_gist where mr << int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr >> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr &< int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr &> int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
select count(*) from test_multirange_gist where mr -|- int4multirange(int4range(100,200), int4range(400,500));
---END---
---START---
drop table test_multirange_gist;
---END---
---START---
CREATE TABLE reservations (_gemini_pk serial PRIMARY KEY, room_id integer NOT NULL, booked_during daterange);
---END---
---START---
insert into reservations values
-- 1: has a meets and a gap
(1, daterange('2018-07-01', '2018-07-07')),
(1, daterange('2018-07-07', '2018-07-14')),
(1, daterange('2018-07-20', '2018-07-22')),
-- 2: just a single row
(2, daterange('2018-07-01', '2018-07-03')),
-- 3: one null range
(3, NULL),
-- 4: two null ranges
(4, NULL),
(4, NULL),
-- 5: a null range and a non-null range
(5, NULL),
(5, daterange('2018-07-01', '2018-07-03')),
-- 6: has overlap
(6, daterange('2018-07-01', '2018-07-07')),
(6, daterange('2018-07-05', '2018-07-10')),
-- 7: two ranges that meet: no gap or overlap
(7, daterange('2018-07-01', '2018-07-07')),
(7, daterange('2018-07-07', '2018-07-14')),
-- 8: an empty range
(8, 'empty'::daterange);
---END---
---START---
SELECT   room_id, range_agg(booked_during)
FROM     reservations
GROUP BY room_id
ORDER BY room_id;
---END---
---START---
-- range_agg on a custom range type too
SELECT  range_agg(r)
FROM    (VALUES
          ('[a,c]'::textrange),
          ('[b,b]'::textrange),
          ('[c,f]'::textrange),
          ('[g,h)'::textrange),
          ('[h,j)'::textrange)
        ) t(r);
---END---
---START---
-- range_agg with multirange inputs
select range_agg(nmr) from nummultirange_test;
---END---
---START---
select range_agg(nmr) from nummultirange_test where false;
---END---
---START---
select range_agg(null::nummultirange) from nummultirange_test;
---END---
---START---
select range_agg(nmr) from (values ('{}'::nummultirange)) t(nmr);
---END---
---START---
select range_agg(nmr) from (values ('{}'::nummultirange), ('{}'::nummultirange)) t(nmr);
---END---
---START---
select range_agg(nmr) from (values ('{[1,2]}'::nummultirange)) t(nmr);
---END---
---START---
select range_agg(nmr) from (values ('{[1,2], [5,6]}'::nummultirange)) t(nmr);
---END---
---START---
select range_agg(nmr) from (values ('{[1,2], [2,3]}'::nummultirange)) t(nmr);
---END---
---START---
select range_agg(nmr) from (values ('{[1,2]}'::nummultirange), ('{[5,6]}'::nummultirange)) t(nmr);
---END---
---START---
select range_agg(nmr) from (values ('{[1,2]}'::nummultirange), ('{[2,3]}'::nummultirange)) t(nmr);
---END---
---START---
--
-- range_intersect_agg function
--
select range_intersect_agg(nmr) from nummultirange_test;
---END---
---START---
select range_intersect_agg(nmr) from nummultirange_test where false;
---END---
---START---
select range_intersect_agg(null::nummultirange) from nummultirange_test;
---END---
---START---
select range_intersect_agg(nmr) from (values ('{[1,3]}'::nummultirange), ('{[6,12]}'::nummultirange)) t(nmr);
---END---
---START---
select range_intersect_agg(nmr) from (values ('{[1,6]}'::nummultirange), ('{[3,12]}'::nummultirange)) t(nmr);
---END---
---START---
select range_intersect_agg(nmr) from (values ('{[1,6], [10,12]}'::nummultirange), ('{[4,14]}'::nummultirange)) t(nmr);
---END---
---START---
-- test with just one input:
select range_intersect_agg(nmr) from (values ('{}'::nummultirange)) t(nmr);
---END---
---START---
select range_intersect_agg(nmr) from (values ('{[1,2]}'::nummultirange)) t(nmr);
---END---
---START---
select range_intersect_agg(nmr) from (values ('{[1,6], [10,12]}'::nummultirange)) t(nmr);
---END---
---START---
select range_intersect_agg(nmr) from nummultirange_test where nmr @> 4.0;
---END---
---START---
CREATE TABLE nummultirange_test2 (_gemini_pk serial PRIMARY KEY, nmr nummultirange);
---END---
---START---
create index nummultirange_test2_hash_idx on nummultirange_test2 using hash (nmr);
---END---
---START---
INSERT INTO nummultirange_test2 VALUES('{[, 5)}');
---END---
---START---
INSERT INTO nummultirange_test2 VALUES(nummultirange(numrange(1.1, 2.2)));
---END---
---START---
INSERT INTO nummultirange_test2 VALUES(nummultirange(numrange(1.1, 2.2)));
---END---
---START---
INSERT INTO nummultirange_test2 VALUES(nummultirange(numrange(1.1, 2.2,'()')));
---END---
---START---
INSERT INTO nummultirange_test2 VALUES('{}');
---END---
---START---
select * from nummultirange_test2 where nmr = '{}';
---END---
---START---
select * from nummultirange_test2 where nmr = nummultirange(numrange(1.1, 2.2));
---END---
---START---
select * from nummultirange_test2 where nmr = nummultirange(numrange(1.1, 2.3));
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
select * from nummultirange_test natural join nummultirange_test2 order by nmr;
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
select * from nummultirange_test natural join nummultirange_test2 order by nmr;
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
select * from nummultirange_test natural join nummultirange_test2 order by nmr;
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
DROP TABLE nummultirange_test2;
---END---
---START---
--
-- Test user-defined multirange of floats
--

select '{[123.001, 5.e9)}'::float8multirange @> 888.882::float8;
---END---
---START---
CREATE TABLE float8multirange_test (_gemini_pk serial PRIMARY KEY, f8mr float8multirange, i integer);
---END---
---START---
insert into float8multirange_test values(float8multirange(float8range(-100.00007, '1.111113e9')), 42);
---END---
---START---
select * from float8multirange_test;
---END---
---START---
drop table float8multirange_test;
---END---
---START---
--
-- Test multirange types over domains
--

create domain mydomain as int4;
---END---
---START---
create type mydomainrange as range(subtype=mydomain);
---END---
---START---
select '{[4,50)}'::mydomainmultirange @> 7::mydomain;
---END---
---START---
drop domain mydomain cascade;
---END---
---START---
--
-- Test domains over multirange types
--

create domain restrictedmultirange as int4multirange check (upper(value) < 10);
---END---
---START---
select '{[4,5)}'::restrictedmultirange @> 7;
---END---
---START---
select '{[4,50)}'::restrictedmultirange @> 7;
---END---
---START---
-- should fail
drop domain restrictedmultirange;
---END---
---START---
---
-- Check automatic naming of multiranges
---

create type intr as range(subtype=int);
---END---
---START---
select intr_multirange(intr(1,10));
---END---
---START---
drop type intr;
---END---
---START---
create type intmultirange as (x int, y int);
---END---
---START---
create type intrange as range(subtype=int);
---END---
---START---
-- should fail
drop type intmultirange;
---END---
---START---
create type intr_multirange as (x int, y int);
---END---
---START---
create type intr as range(subtype=int);
---END---
---START---
-- should fail
drop type intr_multirange;
---END---
---START---
--
-- Test multiple multirange types over the same subtype and manual naming of
-- the multirange type.
--

-- should fail
create type textrange1 as range(subtype=text, multirange_type_name=int, collation="C");
---END---
---START---
-- should pass
create type textrange1 as range(subtype=text, multirange_type_name=multirange_of_text, collation="C");
---END---
---START---
-- should pass, because existing _textrange1 is automatically renamed
create type textrange2 as range(subtype=text, multirange_type_name=_textrange1, collation="C");
---END---
---START---
select multirange_of_text(textrange2('a','Z'));
---END---
---START---
-- should fail
select multirange_of_text(textrange1('a','Z')) @> 'b'::text;
---END---
---START---
select unnest(multirange_of_text(textrange1('a','b'), textrange1('d','e')));
---END---
---START---
select _textrange1(textrange2('a','z')) @> 'b'::text;
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

create function anyarray_anymultirange_func(a anyarray, r anymultirange)
  returns anyelement as 'select $1[1] + lower($2);' language sql;
---END---
---START---
select anyarray_anymultirange_func(ARRAY[1,2], int4multirange(int4range(10,20)));
---END---
---START---
-- should fail
select anyarray_anymultirange_func(ARRAY[1,2], nummultirange(numrange(10,20)));
---END---
---START---
drop function anyarray_anymultirange_func(anyarray, anymultirange);
---END---
---START---
-- should fail
create function bogus_func(anyelement)
  returns anymultirange as 'select int4multirange(int4range(1,10))' language sql;
---END---
---START---
-- should fail
create function bogus_func(int)
  returns anymultirange as 'select int4multirange(int4range(1,10))' language sql;
---END---
---START---
create function range_add_bounds(anymultirange)
  returns anyelement as 'select lower($1) + upper($1)' language sql;
---END---
---START---
select range_add_bounds(int4multirange(int4range(1, 17)));
---END---
---START---
select range_add_bounds(nummultirange(numrange(1.0001, 123.123)));
---END---
---START---
create function multirangetypes_sql(q anymultirange, b anyarray, out c anyelement)
  as $$ select upper($1) + $2[1] $$
  language sql;
---END---
---START---
select multirangetypes_sql(int4multirange(int4range(1,10)), ARRAY[2,20]);
---END---
---START---
select multirangetypes_sql(nummultirange(numrange(1,10)), ARRAY[2,20]);
---END---
---START---
-- match failure

create function anycompatiblearray_anycompatiblemultirange_func(a anycompatiblearray, mr anycompatiblemultirange)
  returns anycompatible as 'select $1[1] + lower($2);' language sql;
---END---
---START---
select anycompatiblearray_anycompatiblemultirange_func(ARRAY[1,2], multirange(int4range(10,20)));
---END---
---START---
select anycompatiblearray_anycompatiblemultirange_func(ARRAY[1,2], multirange(numrange(10,20)));
---END---
---START---
-- should fail
select anycompatiblearray_anycompatiblemultirange_func(ARRAY[1.1,2], multirange(int4range(10,20)));
---END---
---START---
drop function anycompatiblearray_anycompatiblemultirange_func(anycompatiblearray, anycompatiblemultirange);
---END---
---START---
create function anycompatiblerange_anycompatiblemultirange_func(r anycompatiblerange, mr anycompatiblemultirange)
  returns anycompatible as 'select lower($1) + lower($2);' language sql;
---END---
---START---
select anycompatiblerange_anycompatiblemultirange_func(int4range(1,2), multirange(int4range(10,20)));
---END---
---START---
-- should fail
select anycompatiblerange_anycompatiblemultirange_func(numrange(1,2), multirange(int4range(10,20)));
---END---
---START---
drop function anycompatiblerange_anycompatiblemultirange_func(anycompatiblerange, anycompatiblemultirange);
---END---
---START---
-- should fail
create function bogus_func(anycompatible)
  returns anycompatiblerange as 'select int4range(1,10)' language sql;
---END---
---START---
--
-- Arrays of multiranges
--

select ARRAY[nummultirange(numrange(1.1, 1.2)), nummultirange(numrange(12.3, 155.5))];
---END---
---START---
CREATE TABLE i8mr_array (_gemini_pk serial PRIMARY KEY, f1 integer, f2 int8multirange[]);
---END---
---START---
insert into i8mr_array values (42, array[int8multirange(int8range(1,10)), int8multirange(int8range(2,20))]);
---END---
---START---
select * from i8mr_array;
---END---
---START---
drop table i8mr_array;
---END---
---START---
--
-- Multiranges of arrays
--

select arraymultirange(arrayrange(ARRAY[1,2], ARRAY[2,1]));
---END---
---START---
select arraymultirange(arrayrange(ARRAY[2,1], ARRAY[1,2]));
---END---
---START---
-- fail

select array[1,1] <@ arraymultirange(arrayrange(array[1,2], array[2,1]));
---END---
---START---
select array[1,3] <@ arraymultirange(arrayrange(array[1,2], array[2,1]));
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
  (values (two_ints_multirange(two_ints_range(row(1,2), row(3,4)))),
          (two_ints_multirange(two_ints_range(row(5,6), row(7,8))))) v(t);
---END---
---START---
drop type two_ints cascade;
---END---
---START---
--
-- Check behavior when subtype lacks a hash function
--

set enable_sort = off;
---END---
---START---
-- try to make it pick a hash setop implementation

select '{(2,5)}'::cashmultirange except select '{(5,6)}'::cashmultirange;
---END---
---START---
reset enable_sort;
---END---
---START---
--
-- OUT/INOUT/TABLE functions
--

-- infer anymultirange from anymultirange
create function mr_outparam_succeed(i anymultirange, out r anymultirange, out t text)
  as $$ select $1, 'foo'::text $$ language sql;
---END---
---START---
select * from mr_outparam_succeed(int4multirange(int4range(1,2)));
---END---
---START---
-- infer anyarray from anymultirange
create function mr_outparam_succeed2(i anymultirange, out r anyarray, out t text)
  as $$ select ARRAY[upper($1)], 'foo'::text $$ language sql;
---END---
---START---
select * from mr_outparam_succeed2(int4multirange(int4range(1,2)));
---END---
---START---
-- infer anyrange from anymultirange
create function mr_outparam_succeed3(i anymultirange, out r anyrange, out t text)
  as $$ select range_merge($1), 'foo'::text $$ language sql;
---END---
---START---
select * from mr_outparam_succeed3(int4multirange(int4range(1,2)));
---END---
---START---
-- infer anymultirange from anyrange
create function mr_outparam_succeed4(i anyrange, out r anymultirange, out t text)
  as $$ select multirange($1), 'foo'::text $$ language sql;
---END---
---START---
select * from mr_outparam_succeed4(int4range(1,2));
---END---
---START---
-- infer anyelement from anymultirange
create function mr_inoutparam_succeed(out i anyelement, inout r anymultirange)
  as $$ select upper($1), $1 $$ language sql;
---END---
---START---
select * from mr_inoutparam_succeed(int4multirange(int4range(1,2)));
---END---
---START---
-- infer anyelement+anymultirange from anyelement+anymultirange
create function mr_table_succeed(i anyelement, r anymultirange) returns table(i anyelement, r anymultirange)
  as $$ select $1, $2 $$ language sql;
---END---
---START---
select * from mr_table_succeed(123, int4multirange(int4range(1,11)));
---END---
---START---
-- use anymultirange in plpgsql
create function mr_polymorphic(i anyrange) returns anymultirange
  as $$ begin return multirange($1); end; $$ language plpgsql;
---END---
---START---
select mr_polymorphic(int4range(1, 4));
---END---
---START---
-- should fail
create function mr_outparam_fail(i anyelement, out r anymultirange, out t text)
  as $$ select '[1,10]', 'foo' $$ language sql;
---END---
---START---
--should fail
create function mr_inoutparam_fail(inout i anyelement, out r anymultirange)
  as $$ select $1, '[1,10]' $$ language sql;
---END---
---START---
--should fail
create function mr_table_fail(i anyelement) returns table(i anyelement, r anymultirange)
  as $$ select $1, '[1,10]' $$ language sql;
---END---
