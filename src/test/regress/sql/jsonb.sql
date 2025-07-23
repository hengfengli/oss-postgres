---START---
-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

CREATE TABLE testjsonb (
       j jsonb
);
---END---
---START---

\set filename :abs_srcdir '/data/jsonb.data'
COPY testjsonb FROM :'filename';
---END---
---START---

-- Strings.
SELECT '""'::jsonb;				-- OK.
SELECT $$''$$::jsonb;			-- ERROR, single quotes are not allowed
SELECT '"abc"'::jsonb;			-- OK
SELECT '"abc'::jsonb;			-- ERROR, quotes not closed
SELECT '"abc
def"'::jsonb;					-- ERROR, unescaped newline in string constant
SELECT '"\n\"\\"'::jsonb;		-- OK, legal escapes
SELECT '"\v"'::jsonb;			-- ERROR, not a valid JSON escape
-- see json_encoding test for input with unicode escapes

-- Numbers.
SELECT '1'::jsonb;				-- OK
SELECT '0'::jsonb;				-- OK
SELECT '01'::jsonb;				-- ERROR, not valid according to JSON spec
SELECT '0.1'::jsonb;				-- OK
SELECT '9223372036854775808'::jsonb;	-- OK, even though it's too large for int8
SELECT '1e100'::jsonb;			-- OK
SELECT '1.3e100'::jsonb;			-- OK
SELECT '1f2'::jsonb;				-- ERROR
SELECT '0.x1'::jsonb;			-- ERROR
SELECT '1.3ex100'::jsonb;		-- ERROR

-- Arrays.
SELECT '[]'::jsonb;				-- OK
SELECT '[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]'::jsonb;  -- OK
SELECT '[1,2]'::jsonb;			-- OK
SELECT '[1,2,]'::jsonb;			-- ERROR, trailing comma
SELECT '[1,2'::jsonb;			-- ERROR, no closing bracket
SELECT '[1,[2]'::jsonb;			-- ERROR, no closing bracket

-- Objects.
SELECT '{}'::jsonb;				-- OK
SELECT '{"abc"}'::jsonb;			-- ERROR, no value
SELECT '{"abc":1}'::jsonb;		-- OK
SELECT '{1:"abc"}'::jsonb;		-- ERROR, keys must be strings
SELECT '{"abc",1}'::jsonb;		-- ERROR, wrong separator
SELECT '{"abc"=1}'::jsonb;		-- ERROR, totally wrong separator
SELECT '{"abc"::1}'::jsonb;		-- ERROR, another wrong separator
SELECT '{"abc":1,"def":2,"ghi":[3,4],"hij":{"klm":5,"nop":[6]}}'::jsonb; -- OK
SELECT '{"abc":1:2}'::jsonb;		-- ERROR, colon in wrong spot
SELECT '{"abc":1,3}'::jsonb;		-- ERROR, no value

-- Recursion.
SET max_stack_depth = '100kB';
---END---
---START---
SELECT repeat('[', 10000)::jsonb;
---END---
---START---
SELECT repeat('{"a":', 10000)::jsonb;
---END---
---START---
RESET max_stack_depth;
---END---
---START---

-- Miscellaneous stuff.
SELECT 'true'::jsonb;			-- OK
SELECT 'false'::jsonb;			-- OK
SELECT 'null'::jsonb;			-- OK
SELECT ' true '::jsonb;			-- OK, even with extra whitespace
SELECT 'true false'::jsonb;		-- ERROR, too many values
SELECT 'true, false'::jsonb;		-- ERROR, too many values
SELECT 'truf'::jsonb;			-- ERROR, not a keyword
SELECT 'trues'::jsonb;			-- ERROR, not a keyword
SELECT ''::jsonb;				-- ERROR, no value
SELECT '    '::jsonb;			-- ERROR, no value

-- Multi-line JSON input to check ERROR reporting
SELECT '{
		"one": 1,
		"two":"two",
		"three":
		true}'::jsonb; -- OK
SELECT '{
		"one": 1,
		"two":,"two",  -- ERROR extraneous comma before field "two"
		"three":
		true}'::jsonb;
---END---
---START---
SELECT '{
		"one": 1,
		"two":"two",
		"averyveryveryveryveryveryveryveryveryverylongfieldname":}'::jsonb;
---END---
---START---
-- ERROR missing value for last field

-- test non-error-throwing input
select pg_input_is_valid('{"a":true}', 'jsonb');
---END---
---START---
select pg_input_is_valid('{"a":true', 'jsonb');
---END---
---START---
select * from pg_input_error_info('{"a":true', 'jsonb');
---END---
---START---
select * from pg_input_error_info('{"a":1e1000000}', 'jsonb');
---END---
---START---

-- make sure jsonb is passed through json generators without being escaped
SELECT array_to_json(ARRAY [jsonb '{"a":1}', jsonb '{"b":[2,3]}']);
---END---
---START---

-- anyarray column

CREATE TEMP TABLE rows AS
SELECT x, 'txt' || x as y
FROM generate_series(1,3) AS x;
---END---
---START---

analyze rows;
---END---
---START---

select attname, to_jsonb(histogram_bounds) histogram_bounds
from pg_stats
where tablename = 'rows' and
      schemaname = pg_my_temp_schema()::regnamespace::text
order by 1;
---END---
---START---

-- to_jsonb, timestamps

select to_jsonb(timestamp '2014-05-28 12:22:35.614298');
---END---
---START---

BEGIN;
---END---
---START---
SET LOCAL TIME ZONE 10.5;
---END---
---START---
select to_jsonb(timestamptz '2014-05-28 12:22:35.614298-04');
---END---
---START---
SET LOCAL TIME ZONE -8;
---END---
---START---
select to_jsonb(timestamptz '2014-05-28 12:22:35.614298-04');
---END---
---START---
COMMIT;
---END---
---START---

select to_jsonb(date '2014-05-28');
---END---
---START---

select to_jsonb(date 'Infinity');
---END---
---START---
select to_jsonb(date '-Infinity');
---END---
---START---
select to_jsonb(timestamp 'Infinity');
---END---
---START---
select to_jsonb(timestamp '-Infinity');
---END---
---START---
select to_jsonb(timestamptz 'Infinity');
---END---
---START---
select to_jsonb(timestamptz '-Infinity');
---END---
---START---

--jsonb_agg

SELECT jsonb_agg(q)
  FROM ( SELECT $$a$$ || x AS b, y AS c,
               ARRAY[ROW(x.*,ARRAY[1,2,3]),
               ROW(y.*,ARRAY[4,5,6])] AS z
         FROM generate_series(1,2) x,
              generate_series(4,5) y) q;
---END---
---START---

SELECT jsonb_agg(q ORDER BY x, y)
  FROM rows q;
---END---
---START---

UPDATE rows SET x = NULL WHERE x = 1;
---END---
---START---

SELECT jsonb_agg(q ORDER BY x NULLS FIRST, y)
  FROM rows q;
---END---
---START---

-- jsonb extraction functions
CREATE TEMP TABLE test_jsonb (
       json_type text,
       test_json jsonb
);
---END---
---START---

INSERT INTO test_jsonb VALUES
('scalar','"a scalar"'),
('array','["zero", "one","two",null,"four","five", [1,2,3],{"f1":9}]'),
('object','{"field1":"val1","field2":"val2","field3":null, "field4": 4, "field5": [1,2,3], "field6": {"f1":9}}');
---END---
---START---

SELECT test_json -> 'x' FROM test_jsonb WHERE json_type = 'scalar';
---END---
---START---
SELECT test_json -> 'x' FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT test_json -> 'x' FROM test_jsonb WHERE json_type = 'object';
---END---
---START---
SELECT test_json -> 'field2' FROM test_jsonb WHERE json_type = 'object';
---END---
---START---

SELECT test_json ->> 'field2' FROM test_jsonb WHERE json_type = 'scalar';
---END---
---START---
SELECT test_json ->> 'field2' FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT test_json ->> 'field2' FROM test_jsonb WHERE json_type = 'object';
---END---
---START---

SELECT test_json -> 2 FROM test_jsonb WHERE json_type = 'scalar';
---END---
---START---
SELECT test_json -> 2 FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT test_json -> 9 FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT test_json -> 2 FROM test_jsonb WHERE json_type = 'object';
---END---
---START---

SELECT test_json ->> 6 FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT test_json ->> 7 FROM test_jsonb WHERE json_type = 'array';
---END---
---START---

SELECT test_json ->> 'field4' FROM test_jsonb WHERE json_type = 'object';
---END---
---START---
SELECT test_json ->> 'field5' FROM test_jsonb WHERE json_type = 'object';
---END---
---START---
SELECT test_json ->> 'field6' FROM test_jsonb WHERE json_type = 'object';
---END---
---START---

SELECT test_json ->> 2 FROM test_jsonb WHERE json_type = 'scalar';
---END---
---START---
SELECT test_json ->> 2 FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT test_json ->> 2 FROM test_jsonb WHERE json_type = 'object';
---END---
---START---

SELECT jsonb_object_keys(test_json) FROM test_jsonb WHERE json_type = 'scalar';
---END---
---START---
SELECT jsonb_object_keys(test_json) FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT jsonb_object_keys(test_json) FROM test_jsonb WHERE json_type = 'object';
---END---
---START---

-- nulls
SELECT (test_json->'field3') IS NULL AS expect_false FROM test_jsonb WHERE json_type = 'object';
---END---
---START---
SELECT (test_json->>'field3') IS NULL AS expect_true FROM test_jsonb WHERE json_type = 'object';
---END---
---START---
SELECT (test_json->3) IS NULL AS expect_false FROM test_jsonb WHERE json_type = 'array';
---END---
---START---
SELECT (test_json->>3) IS NULL AS expect_true FROM test_jsonb WHERE json_type = 'array';
---END---
---START---

-- corner cases
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb -> null::text;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb -> null::int;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb -> 1;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb -> 'z';
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb -> '';
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb -> 1;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb -> 3;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb -> 'z';
---END---
---START---
select '{"a": "c", "b": null}'::jsonb -> 'b';
---END---
---START---
select '"foo"'::jsonb -> 1;
---END---
---START---
select '"foo"'::jsonb -> 'z';
---END---
---START---

select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb ->> null::text;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb ->> null::int;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb ->> 1;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb ->> 'z';
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb ->> '';
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb ->> 1;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb ->> 3;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb ->> 'z';
---END---
---START---
select '{"a": "c", "b": null}'::jsonb ->> 'b';
---END---
---START---
select '"foo"'::jsonb ->> 1;
---END---
---START---
select '"foo"'::jsonb ->> 'z';
---END---
---START---

-- equality and inequality
SELECT '{"x":"y"}'::jsonb = '{"x":"y"}'::jsonb;
---END---
---START---
SELECT '{"x":"y"}'::jsonb = '{"x":"z"}'::jsonb;
---END---
---START---

SELECT '{"x":"y"}'::jsonb <> '{"x":"y"}'::jsonb;
---END---
---START---
SELECT '{"x":"y"}'::jsonb <> '{"x":"z"}'::jsonb;
---END---
---START---

-- containment
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"a":"b"}');
---END---
---START---
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"a":"b", "c":null}');
---END---
---START---
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"a":"b", "g":null}');
---END---
---START---
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"g":null}');
---END---
---START---
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"a":"c"}');
---END---
---START---
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"a":"b"}');
---END---
---START---
SELECT jsonb_contains('{"a":"b", "b":1, "c":null}', '{"a":"b", "c":"q"}');
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"a":"b"}';
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"a":"b", "c":null}';
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"a":"b", "g":null}';
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"g":null}';
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"a":"c"}';
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"a":"b"}';
---END---
---START---
SELECT '{"a":"b", "b":1, "c":null}'::jsonb @> '{"a":"b", "c":"q"}';
---END---
---START---

SELECT '[1,2]'::jsonb @> '[1,2,2]'::jsonb;
---END---
---START---
SELECT '[1,1,2]'::jsonb @> '[1,2,2]'::jsonb;
---END---
---START---
SELECT '[[1,2]]'::jsonb @> '[[1,2,2]]'::jsonb;
---END---
---START---
SELECT '[1,2,2]'::jsonb <@ '[1,2]'::jsonb;
---END---
---START---
SELECT '[1,2,2]'::jsonb <@ '[1,1,2]'::jsonb;
---END---
---START---
SELECT '[[1,2,2]]'::jsonb <@ '[[1,2]]'::jsonb;
---END---
---START---

SELECT jsonb_contained('{"a":"b"}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT jsonb_contained('{"a":"b", "c":null}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT jsonb_contained('{"a":"b", "g":null}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT jsonb_contained('{"g":null}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT jsonb_contained('{"a":"c"}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT jsonb_contained('{"a":"b"}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT jsonb_contained('{"a":"b", "c":"q"}', '{"a":"b", "b":1, "c":null}');
---END---
---START---
SELECT '{"a":"b"}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
SELECT '{"a":"b", "c":null}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
SELECT '{"a":"b", "g":null}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
SELECT '{"g":null}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
SELECT '{"a":"c"}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
SELECT '{"a":"b"}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
SELECT '{"a":"b", "c":"q"}'::jsonb <@ '{"a":"b", "b":1, "c":null}';
---END---
---START---
-- Raw scalar may contain another raw scalar, array may contain a raw scalar
SELECT '[5]'::jsonb @> '[5]';
---END---
---START---
SELECT '5'::jsonb @> '5';
---END---
---START---
SELECT '[5]'::jsonb @> '5';
---END---
---START---
-- But a raw scalar cannot contain an array
SELECT '5'::jsonb @> '[5]';
---END---
---START---
-- In general, one thing should always contain itself. Test array containment:
SELECT '["9", ["7", "3"], 1]'::jsonb @> '["9", ["7", "3"], 1]'::jsonb;
---END---
---START---
SELECT '["9", ["7", "3"], ["1"]]'::jsonb @> '["9", ["7", "3"], ["1"]]'::jsonb;
---END---
---START---
-- array containment string matching confusion bug
SELECT '{ "name": "Bob", "tags": [ "enim", "qui"]}'::jsonb @> '{"tags":["qu"]}';
---END---
---START---

-- array length
SELECT jsonb_array_length('[1,2,3,{"f1":1,"f2":[5,6]},4]');
---END---
---START---
SELECT jsonb_array_length('[]');
---END---
---START---
SELECT jsonb_array_length('{"f1":1,"f2":[5,6]}');
---END---
---START---
SELECT jsonb_array_length('4');
---END---
---START---

-- each
SELECT jsonb_each('{"f1":[1,2,3],"f2":{"f3":1},"f4":null}');
---END---
---START---
SELECT jsonb_each('{"a":{"b":"c","c":"b","1":"first"},"b":[1,2],"c":"cc","1":"first","n":null}'::jsonb) AS q;
---END---
---START---
SELECT * FROM jsonb_each('{"f1":[1,2,3],"f2":{"f3":1},"f4":null,"f5":99,"f6":"stringy"}') q;
---END---
---START---
SELECT * FROM jsonb_each('{"a":{"b":"c","c":"b","1":"first"},"b":[1,2],"c":"cc","1":"first","n":null}'::jsonb) AS q;
---END---
---START---

SELECT jsonb_each_text('{"f1":[1,2,3],"f2":{"f3":1},"f4":null,"f5":"null"}');
---END---
---START---
SELECT jsonb_each_text('{"a":{"b":"c","c":"b","1":"first"},"b":[1,2],"c":"cc","1":"first","n":null}'::jsonb) AS q;
---END---
---START---
SELECT * FROM jsonb_each_text('{"f1":[1,2,3],"f2":{"f3":1},"f4":null,"f5":99,"f6":"stringy"}') q;
---END---
---START---
SELECT * FROM jsonb_each_text('{"a":{"b":"c","c":"b","1":"first"},"b":[1,2],"c":"cc","1":"first","n":null}'::jsonb) AS q;
---END---
---START---

-- exists
SELECT jsonb_exists('{"a":null, "b":"qq"}', 'a');
---END---
---START---
SELECT jsonb_exists('{"a":null, "b":"qq"}', 'b');
---END---
---START---
SELECT jsonb_exists('{"a":null, "b":"qq"}', 'c');
---END---
---START---
SELECT jsonb_exists('{"a":"null", "b":"qq"}', 'a');
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ? 'a';
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ? 'b';
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ? 'c';
---END---
---START---
SELECT jsonb '{"a":"null", "b":"qq"}' ? 'a';
---END---
---START---
-- array exists - array elements should behave as keys
SELECT count(*) from testjsonb  WHERE j->'array' ? 'bar';
---END---
---START---
-- type sensitive array exists - should return no rows (since "exists" only
-- matches strings that are either object keys or array elements)
SELECT count(*) from testjsonb  WHERE j->'array' ? '5'::text;
---END---
---START---
-- However, a raw scalar is *contained* within the array
SELECT count(*) from testjsonb  WHERE j->'array' @> '5'::jsonb;
---END---
---START---

SELECT jsonb_exists_any('{"a":null, "b":"qq"}', ARRAY['a','b']);
---END---
---START---
SELECT jsonb_exists_any('{"a":null, "b":"qq"}', ARRAY['b','a']);
---END---
---START---
SELECT jsonb_exists_any('{"a":null, "b":"qq"}', ARRAY['c','a']);
---END---
---START---
SELECT jsonb_exists_any('{"a":null, "b":"qq"}', ARRAY['c','d']);
---END---
---START---
SELECT jsonb_exists_any('{"a":null, "b":"qq"}', '{}'::text[]);
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?| ARRAY['a','b'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?| ARRAY['b','a'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?| ARRAY['c','a'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?| ARRAY['c','d'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?| '{}'::text[];
---END---
---START---

SELECT jsonb_exists_all('{"a":null, "b":"qq"}', ARRAY['a','b']);
---END---
---START---
SELECT jsonb_exists_all('{"a":null, "b":"qq"}', ARRAY['b','a']);
---END---
---START---
SELECT jsonb_exists_all('{"a":null, "b":"qq"}', ARRAY['c','a']);
---END---
---START---
SELECT jsonb_exists_all('{"a":null, "b":"qq"}', ARRAY['c','d']);
---END---
---START---
SELECT jsonb_exists_all('{"a":null, "b":"qq"}', '{}'::text[]);
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?& ARRAY['a','b'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?& ARRAY['b','a'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?& ARRAY['c','a'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?& ARRAY['c','d'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?& ARRAY['a','a', 'b', 'b', 'b'];
---END---
---START---
SELECT jsonb '{"a":null, "b":"qq"}' ?& '{}'::text[];
---END---
---START---

-- typeof
SELECT jsonb_typeof('{}') AS object;
---END---
---START---
SELECT jsonb_typeof('{"c":3,"p":"o"}') AS object;
---END---
---START---
SELECT jsonb_typeof('[]') AS array;
---END---
---START---
SELECT jsonb_typeof('["a", 1]') AS array;
---END---
---START---
SELECT jsonb_typeof('null') AS "null";
---END---
---START---
SELECT jsonb_typeof('1') AS number;
---END---
---START---
SELECT jsonb_typeof('-1') AS number;
---END---
---START---
SELECT jsonb_typeof('1.0') AS number;
---END---
---START---
SELECT jsonb_typeof('1e2') AS number;
---END---
---START---
SELECT jsonb_typeof('-1.0') AS number;
---END---
---START---
SELECT jsonb_typeof('true') AS boolean;
---END---
---START---
SELECT jsonb_typeof('false') AS boolean;
---END---
---START---
SELECT jsonb_typeof('"hello"') AS string;
---END---
---START---
SELECT jsonb_typeof('"true"') AS string;
---END---
---START---
SELECT jsonb_typeof('"1.0"') AS string;
---END---
---START---

-- jsonb_build_array, jsonb_build_object, jsonb_object_agg

SELECT jsonb_build_array('a',1,'b',1.2,'c',true,'d',null,'e',json '{"x": 3, "y": [1,2,3]}');
---END---
---START---
SELECT jsonb_build_array('a', NULL); -- ok
SELECT jsonb_build_array(VARIADIC NULL::text[]); -- ok
SELECT jsonb_build_array(VARIADIC '{}'::text[]); -- ok
SELECT jsonb_build_array(VARIADIC '{a,b,c}'::text[]); -- ok
SELECT jsonb_build_array(VARIADIC ARRAY['a', NULL]::text[]); -- ok
SELECT jsonb_build_array(VARIADIC '{1,2,3,4}'::text[]); -- ok
SELECT jsonb_build_array(VARIADIC '{1,2,3,4}'::int[]); -- ok
SELECT jsonb_build_array(VARIADIC '{{1,4},{2,5},{3,6}}'::int[][]); -- ok

SELECT jsonb_build_object('a',1,'b',1.2,'c',true,'d',null,'e',json '{"x": 3, "y": [1,2,3]}');
---END---
---START---

SELECT jsonb_build_object(
       'a', jsonb_build_object('b',false,'c',99),
       'd', jsonb_build_object('e',array[9,8,7]::int[],
           'f', (select row_to_json(r) from ( select relkind, oid::regclass as name from pg_class where relname = 'pg_class') r)));
---END---
---START---
SELECT jsonb_build_object('{a,b,c}'::text[]); -- error
SELECT jsonb_build_object('{a,b,c}'::text[], '{d,e,f}'::text[]); -- error, key cannot be array
SELECT jsonb_build_object('a', 'b', 'c'); -- error
SELECT jsonb_build_object(NULL, 'a'); -- error, key cannot be NULL
SELECT jsonb_build_object('a', NULL); -- ok
SELECT jsonb_build_object(VARIADIC NULL::text[]); -- ok
SELECT jsonb_build_object(VARIADIC '{}'::text[]); -- ok
SELECT jsonb_build_object(VARIADIC '{a,b,c}'::text[]); -- error
SELECT jsonb_build_object(VARIADIC ARRAY['a', NULL]::text[]); -- ok
SELECT jsonb_build_object(VARIADIC ARRAY[NULL, 'a']::text[]); -- error, key cannot be NULL
SELECT jsonb_build_object(VARIADIC '{1,2,3,4}'::text[]); -- ok
SELECT jsonb_build_object(VARIADIC '{1,2,3,4}'::int[]); -- ok
SELECT jsonb_build_object(VARIADIC '{{1,4},{2,5},{3,6}}'::int[][]); -- ok

-- empty objects/arrays
SELECT jsonb_build_array();
---END---
---START---

SELECT jsonb_build_object();
---END---
---START---

-- make sure keys are quoted
SELECT jsonb_build_object(1,2);
---END---
---START---

-- keys must be scalar and not null
SELECT jsonb_build_object(null,2);
---END---
---START---

SELECT jsonb_build_object(r,2) FROM (SELECT 1 AS a, 2 AS b) r;
---END---
---START---

SELECT jsonb_build_object(json '{"a":1,"b":2}', 3);
---END---
---START---

SELECT jsonb_build_object('{1,2,3}'::int[], 3);
---END---
---START---

-- handling of NULL values
SELECT jsonb_object_agg(1, NULL::jsonb);
---END---
---START---
SELECT jsonb_object_agg(NULL, '{"a":1}');
---END---
---START---

CREATE TEMP TABLE foo (serial_num int, name text, type text);
---END---
---START---
INSERT INTO foo VALUES (847001,'t15','GE1043');
---END---
---START---
INSERT INTO foo VALUES (847002,'t16','GE1043');
---END---
---START---
INSERT INTO foo VALUES (847003,'sub-alpha','GESS90');
---END---
---START---

SELECT jsonb_build_object('turbines',jsonb_object_agg(serial_num,jsonb_build_object('name',name,'type',type)))
FROM foo;
---END---
---START---

SELECT jsonb_object_agg(name, type) FROM foo;
---END---
---START---

INSERT INTO foo VALUES (999999, NULL, 'bar');
---END---
---START---
SELECT jsonb_object_agg(name, type) FROM foo;
---END---
---START---

-- jsonb_object

-- empty object, one dimension
SELECT jsonb_object('{}');
---END---
---START---

-- empty object, two dimensions
SELECT jsonb_object('{}', '{}');
---END---
---START---

-- one dimension
SELECT jsonb_object('{a,1,b,2,3,NULL,"d e f","a b c"}');
---END---
---START---

-- same but with two dimensions
SELECT jsonb_object('{{a,1},{b,2},{3,NULL},{"d e f","a b c"}}');
---END---
---START---

-- odd number error
SELECT jsonb_object('{a,b,c}');
---END---
---START---

-- one column error
SELECT jsonb_object('{{a},{b}}');
---END---
---START---

-- too many columns error
SELECT jsonb_object('{{a,b,c},{b,c,d}}');
---END---
---START---

-- too many dimensions error
SELECT jsonb_object('{{{a,b},{c,d}},{{b,c},{d,e}}}');
---END---
---START---

--two argument form of jsonb_object

select jsonb_object('{a,b,c,"d e f"}','{1,2,3,"a b c"}');
---END---
---START---

-- too many dimensions
SELECT jsonb_object('{{a,1},{b,2},{3,NULL},{"d e f","a b c"}}', '{{a,1},{b,2},{3,NULL},{"d e f","a b c"}}');
---END---
---START---

-- mismatched dimensions

select jsonb_object('{a,b,c,"d e f",g}','{1,2,3,"a b c"}');
---END---
---START---

select jsonb_object('{a,b,c,"d e f"}','{1,2,3,"a b c",g}');
---END---
---START---

-- null key error

select jsonb_object('{a,b,NULL,"d e f"}','{1,2,3,"a b c"}');
---END---
---START---

-- empty key is allowed

select jsonb_object('{a,b,"","d e f"}','{1,2,3,"a b c"}');
---END---
---START---



-- extract_path, extract_path_as_text
SELECT jsonb_extract_path('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f4','f6');
---END---
---START---
SELECT jsonb_extract_path('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f2');
---END---
---START---
SELECT jsonb_extract_path('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',0::text);
---END---
---START---
SELECT jsonb_extract_path('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',1::text);
---END---
---START---
SELECT jsonb_extract_path_text('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f4','f6');
---END---
---START---
SELECT jsonb_extract_path_text('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f2');
---END---
---START---
SELECT jsonb_extract_path_text('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',0::text);
---END---
---START---
SELECT jsonb_extract_path_text('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',1::text);
---END---
---START---

-- extract_path nulls
SELECT jsonb_extract_path('{"f2":{"f3":1},"f4":{"f5":null,"f6":"stringy"}}','f4','f5') IS NULL AS expect_false;
---END---
---START---
SELECT jsonb_extract_path_text('{"f2":{"f3":1},"f4":{"f5":null,"f6":"stringy"}}','f4','f5') IS NULL AS expect_true;
---END---
---START---
SELECT jsonb_extract_path('{"f2":{"f3":1},"f4":[0,1,2,null]}','f4','3') IS NULL AS expect_false;
---END---
---START---
SELECT jsonb_extract_path_text('{"f2":{"f3":1},"f4":[0,1,2,null]}','f4','3') IS NULL AS expect_true;
---END---
---START---

-- extract_path operators
SELECT '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>array['f4','f6'];
---END---
---START---
SELECT '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>array['f2'];
---END---
---START---
SELECT '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>array['f2','0'];
---END---
---START---
SELECT '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>array['f2','1'];
---END---
---START---

SELECT '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>>array['f4','f6'];
---END---
---START---
SELECT '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>>array['f2'];
---END---
---START---
SELECT '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>>array['f2','0'];
---END---
---START---
SELECT '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::jsonb#>>array['f2','1'];
---END---
---START---

-- corner cases for same
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> '{}';
---END---
---START---
select '[1,2,3]'::jsonb #> '{}';
---END---
---START---
select '"foo"'::jsonb #> '{}';
---END---
---START---
select '42'::jsonb #> '{}';
---END---
---START---
select 'null'::jsonb #> '{}';
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a', null];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a', ''];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a','b'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a','b','c'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a','b','c','d'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #> array['a','z','c'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb #> array['a','1','b'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb #> array['a','z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb #> array['1','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb #> array['z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": null}]'::jsonb #> array['1','b'];
---END---
---START---
select '"foo"'::jsonb #> array['z'];
---END---
---START---
select '42'::jsonb #> array['f2'];
---END---
---START---
select '42'::jsonb #> array['0'];
---END---
---START---

select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> '{}';
---END---
---START---
select '[1,2,3]'::jsonb #>> '{}';
---END---
---START---
select '"foo"'::jsonb #>> '{}';
---END---
---START---
select '42'::jsonb #>> '{}';
---END---
---START---
select 'null'::jsonb #>> '{}';
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a', null];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a', ''];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a','b'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a','b','c'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a','b','c','d'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::jsonb #>> array['a','z','c'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb #>> array['a','1','b'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::jsonb #>> array['a','z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb #>> array['1','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::jsonb #>> array['z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": null}]'::jsonb #>> array['1','b'];
---END---
---START---
select '"foo"'::jsonb #>> array['z'];
---END---
---START---
select '42'::jsonb #>> array['f2'];
---END---
---START---
select '42'::jsonb #>> array['0'];
---END---
---START---

-- array_elements
SELECT jsonb_array_elements('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false]');
---END---
---START---
SELECT * FROM jsonb_array_elements('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false]') q;
---END---
---START---
SELECT jsonb_array_elements_text('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false,"stringy"]');
---END---
---START---
SELECT * FROM jsonb_array_elements_text('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false,"stringy"]') q;
---END---
---START---

-- populate_record
CREATE TYPE jbpop AS (a text, b int, c timestamp);
---END---
---START---

CREATE DOMAIN jsb_int_not_null  AS int     NOT NULL;
---END---
---START---
CREATE DOMAIN jsb_int_array_1d  AS int[]   CHECK(array_length(VALUE, 1) = 3);
---END---
---START---
CREATE DOMAIN jsb_int_array_2d  AS int[][] CHECK(array_length(VALUE, 2) = 3);
---END---
---START---

create type jb_unordered_pair as (x int, y int);
---END---
---START---
create domain jb_ordered_pair as jb_unordered_pair check((value).x <= (value).y);
---END---
---START---

CREATE TYPE jsbrec AS (
	i	int,
	ia	_int4,
	ia1	int[],
	ia2	int[][],
	ia3	int[][][],
	ia1d	jsb_int_array_1d,
	ia2d	jsb_int_array_2d,
	t	text,
	ta	text[],
	c	char(10),
	ca	char(10)[],
	ts	timestamp,
	js	json,
	jsb	jsonb,
	jsa	json[],
	rec	jbpop,
	reca	jbpop[]
);
---END---
---START---

CREATE TYPE jsbrec_i_not_null AS (
	i	jsb_int_not_null
);
---END---
---START---

SELECT * FROM jsonb_populate_record(NULL::jbpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---
SELECT * FROM jsonb_populate_record(row('x',3,'2012-12-31 15:30:56')::jbpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---

SELECT * FROM jsonb_populate_record(NULL::jbpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---
SELECT * FROM jsonb_populate_record(row('x',3,'2012-12-31 15:30:56')::jbpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---

SELECT * FROM jsonb_populate_record(NULL::jbpop,'{"a":[100,200,false],"x":43.2}') q;
---END---
---START---
SELECT * FROM jsonb_populate_record(row('x',3,'2012-12-31 15:30:56')::jbpop,'{"a":[100,200,false],"x":43.2}') q;
---END---
---START---
SELECT * FROM jsonb_populate_record(row('x',3,'2012-12-31 15:30:56')::jbpop,'{"c":[100,200,false],"x":43.2}') q;
---END---
---START---

SELECT * FROM jsonb_populate_record(row('x',3,'2012-12-31 15:30:56')::jbpop, '{}') q;
---END---
---START---

SELECT i FROM jsonb_populate_record(NULL::jsbrec_i_not_null, '{"x": 43.2}') q;
---END---
---START---
SELECT i FROM jsonb_populate_record(NULL::jsbrec_i_not_null, '{"i": null}') q;
---END---
---START---
SELECT i FROM jsonb_populate_record(NULL::jsbrec_i_not_null, '{"i": 12345}') q;
---END---
---START---

SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": null}') q;
---END---
---START---
SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": 123}') q;
---END---
---START---
SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": [[1, 2], [3, 4]]}') q;
---END---
---START---
SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": [[1], 2]}') q;
---END---
---START---
SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": [[1], [2, 3]]}') q;
---END---
---START---
SELECT ia FROM jsonb_populate_record(NULL::jsbrec, '{"ia": "{1,2,3}"}') q;
---END---
---START---

SELECT ia1 FROM jsonb_populate_record(NULL::jsbrec, '{"ia1": null}') q;
---END---
---START---
SELECT ia1 FROM jsonb_populate_record(NULL::jsbrec, '{"ia1": 123}') q;
---END---
---START---
SELECT ia1 FROM jsonb_populate_record(NULL::jsbrec, '{"ia1": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia1 FROM jsonb_populate_record(NULL::jsbrec, '{"ia1": [[1, 2, 3]]}') q;
---END---
---START---

SELECT ia1d FROM jsonb_populate_record(NULL::jsbrec, '{"ia1d": null}') q;
---END---
---START---
SELECT ia1d FROM jsonb_populate_record(NULL::jsbrec, '{"ia1d": 123}') q;
---END---
---START---
SELECT ia1d FROM jsonb_populate_record(NULL::jsbrec, '{"ia1d": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia1d FROM jsonb_populate_record(NULL::jsbrec, '{"ia1d": [1, "2", null]}') q;
---END---
---START---

SELECT ia2 FROM jsonb_populate_record(NULL::jsbrec, '{"ia2": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia2 FROM jsonb_populate_record(NULL::jsbrec, '{"ia2": [[1, 2], [null, 4]]}') q;
---END---
---START---
SELECT ia2 FROM jsonb_populate_record(NULL::jsbrec, '{"ia2": [[], []]}') q;
---END---
---START---
SELECT ia2 FROM jsonb_populate_record(NULL::jsbrec, '{"ia2": [[1, 2], [3]]}') q;
---END---
---START---
SELECT ia2 FROM jsonb_populate_record(NULL::jsbrec, '{"ia2": [[1, 2], 3, 4]}') q;
---END---
---START---

SELECT ia2d FROM jsonb_populate_record(NULL::jsbrec, '{"ia2d": [[1, "2"], [null, 4]]}') q;
---END---
---START---
SELECT ia2d FROM jsonb_populate_record(NULL::jsbrec, '{"ia2d": [[1, "2", 3], [null, 5, 6]]}') q;
---END---
---START---

SELECT ia3 FROM jsonb_populate_record(NULL::jsbrec, '{"ia3": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia3 FROM jsonb_populate_record(NULL::jsbrec, '{"ia3": [[1, 2], [null, 4]]}') q;
---END---
---START---
SELECT ia3 FROM jsonb_populate_record(NULL::jsbrec, '{"ia3": [ [[], []], [[], []], [[], []] ]}') q;
---END---
---START---
SELECT ia3 FROM jsonb_populate_record(NULL::jsbrec, '{"ia3": [ [[1, 2]], [[3, 4]] ]}') q;
---END---
---START---
SELECT ia3 FROM jsonb_populate_record(NULL::jsbrec, '{"ia3": [ [[1, 2], [3, 4]], [[5, 6], [7, 8]] ]}') q;
---END---
---START---
SELECT ia3 FROM jsonb_populate_record(NULL::jsbrec, '{"ia3": [ [[1, 2], [3, 4]], [[5, 6], [7, 8], [9, 10]] ]}') q;
---END---
---START---

SELECT ta FROM jsonb_populate_record(NULL::jsbrec, '{"ta": null}') q;
---END---
---START---
SELECT ta FROM jsonb_populate_record(NULL::jsbrec, '{"ta": 123}') q;
---END---
---START---
SELECT ta FROM jsonb_populate_record(NULL::jsbrec, '{"ta": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ta FROM jsonb_populate_record(NULL::jsbrec, '{"ta": [[1, 2, 3], {"k": "v"}]}') q;
---END---
---START---

SELECT c FROM jsonb_populate_record(NULL::jsbrec, '{"c": null}') q;
---END---
---START---
SELECT c FROM jsonb_populate_record(NULL::jsbrec, '{"c": "aaa"}') q;
---END---
---START---
SELECT c FROM jsonb_populate_record(NULL::jsbrec, '{"c": "aaaaaaaaaa"}') q;
---END---
---START---
SELECT c FROM jsonb_populate_record(NULL::jsbrec, '{"c": "aaaaaaaaaaaaa"}') q;
---END---
---START---

SELECT ca FROM jsonb_populate_record(NULL::jsbrec, '{"ca": null}') q;
---END---
---START---
SELECT ca FROM jsonb_populate_record(NULL::jsbrec, '{"ca": 123}') q;
---END---
---START---
SELECT ca FROM jsonb_populate_record(NULL::jsbrec, '{"ca": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ca FROM jsonb_populate_record(NULL::jsbrec, '{"ca": ["aaaaaaaaaaaaaaaa"]}') q;
---END---
---START---
SELECT ca FROM jsonb_populate_record(NULL::jsbrec, '{"ca": [[1, 2, 3], {"k": "v"}]}') q;
---END---
---START---

SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": null}') q;
---END---
---START---
SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": true}') q;
---END---
---START---
SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": 123.45}') q;
---END---
---START---
SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": "123.45"}') q;
---END---
---START---
SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": "abc"}') q;
---END---
---START---
SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": [123, "123", null, {"key": "value"}]}') q;
---END---
---START---
SELECT js FROM jsonb_populate_record(NULL::jsbrec, '{"js": {"a": "bbb", "b": null, "c": 123.45}}') q;
---END---
---START---

SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": null}') q;
---END---
---START---
SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": true}') q;
---END---
---START---
SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": 123.45}') q;
---END---
---START---
SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": "123.45"}') q;
---END---
---START---
SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": "abc"}') q;
---END---
---START---
SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": [123, "123", null, {"key": "value"}]}') q;
---END---
---START---
SELECT jsb FROM jsonb_populate_record(NULL::jsbrec, '{"jsb": {"a": "bbb", "b": null, "c": 123.45}}') q;
---END---
---START---

SELECT jsa FROM jsonb_populate_record(NULL::jsbrec, '{"jsa": null}') q;
---END---
---START---
SELECT jsa FROM jsonb_populate_record(NULL::jsbrec, '{"jsa": 123}') q;
---END---
---START---
SELECT jsa FROM jsonb_populate_record(NULL::jsbrec, '{"jsa": [1, "2", null, 4]}') q;
---END---
---START---
SELECT jsa FROM jsonb_populate_record(NULL::jsbrec, '{"jsa": ["aaa", null, [1, 2, "3", {}], { "k" : "v" }]}') q;
---END---
---START---

SELECT rec FROM jsonb_populate_record(NULL::jsbrec, '{"rec": 123}') q;
---END---
---START---
SELECT rec FROM jsonb_populate_record(NULL::jsbrec, '{"rec": [1, 2]}') q;
---END---
---START---
SELECT rec FROM jsonb_populate_record(NULL::jsbrec, '{"rec": {"a": "abc", "c": "01.02.2003", "x": 43.2}}') q;
---END---
---START---
SELECT rec FROM jsonb_populate_record(NULL::jsbrec, '{"rec": "(abc,42,01.02.2003)"}') q;
---END---
---START---

SELECT reca FROM jsonb_populate_record(NULL::jsbrec, '{"reca": 123}') q;
---END---
---START---
SELECT reca FROM jsonb_populate_record(NULL::jsbrec, '{"reca": [1, 2]}') q;
---END---
---START---
SELECT reca FROM jsonb_populate_record(NULL::jsbrec, '{"reca": [{"a": "abc", "b": 456}, null, {"c": "01.02.2003", "x": 43.2}]}') q;
---END---
---START---
SELECT reca FROM jsonb_populate_record(NULL::jsbrec, '{"reca": ["(abc,42,01.02.2003)"]}') q;
---END---
---START---
SELECT reca FROM jsonb_populate_record(NULL::jsbrec, '{"reca": "{\"(abc,42,01.02.2003)\"}"}') q;
---END---
---START---

SELECT rec FROM jsonb_populate_record(
	row(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		row('x',3,'2012-12-31 15:30:56')::jbpop,NULL)::jsbrec,
	'{"rec": {"a": "abc", "c": "01.02.2003", "x": 43.2}}'
) q;
---END---
---START---

-- anonymous record type
SELECT jsonb_populate_record(null::record, '{"x": 0, "y": 1}');
---END---
---START---
SELECT jsonb_populate_record(row(1,2), '{"f1": 0, "f2": 1}');
---END---
---START---
SELECT * FROM
  jsonb_populate_record(null::record, '{"x": 776}') AS (x int, y int);
---END---
---START---

-- composite domain
SELECT jsonb_populate_record(null::jb_ordered_pair, '{"x": 0, "y": 1}');
---END---
---START---
SELECT jsonb_populate_record(row(1,2)::jb_ordered_pair, '{"x": 0}');
---END---
---START---
SELECT jsonb_populate_record(row(1,2)::jb_ordered_pair, '{"x": 1, "y": 0}');
---END---
---START---

-- populate_recordset
SELECT * FROM jsonb_populate_recordset(NULL::jbpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(row('def',99,NULL)::jbpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(NULL::jbpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(row('def',99,NULL)::jbpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(row('def',99,NULL)::jbpop,'[{"a":[100,200,300],"x":43.2},{"a":{"z":true},"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(row('def',99,NULL)::jbpop,'[{"c":[100,200,300],"x":43.2},{"a":{"z":true},"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---

SELECT * FROM jsonb_populate_recordset(NULL::jbpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(row('def',99,NULL)::jbpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
SELECT * FROM jsonb_populate_recordset(row('def',99,NULL)::jbpop,'[{"a":[100,200,300],"x":43.2},{"a":{"z":true},"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---

-- anonymous record type
SELECT jsonb_populate_recordset(null::record, '[{"x": 0, "y": 1}]');
---END---
---START---
SELECT jsonb_populate_recordset(row(1,2), '[{"f1": 0, "f2": 1}]');
---END---
---START---
SELECT i, jsonb_populate_recordset(row(i,50), '[{"f1":"42"},{"f2":"43"}]')
FROM (VALUES (1),(2)) v(i);
---END---
---START---
SELECT * FROM
  jsonb_populate_recordset(null::record, '[{"x": 776}]') AS (x int, y int);
---END---
---START---

-- empty array is a corner case
SELECT jsonb_populate_recordset(null::record, '[]');
---END---
---START---
SELECT jsonb_populate_recordset(row(1,2), '[]');
---END---
---START---
SELECT * FROM jsonb_populate_recordset(NULL::jbpop,'[]') q;
---END---
---START---
SELECT * FROM
  jsonb_populate_recordset(null::record, '[]') AS (x int, y int);
---END---
---START---

-- composite domain
SELECT jsonb_populate_recordset(null::jb_ordered_pair, '[{"x": 0, "y": 1}]');
---END---
---START---
SELECT jsonb_populate_recordset(row(1,2)::jb_ordered_pair, '[{"x": 0}, {"y": 3}]');
---END---
---START---
SELECT jsonb_populate_recordset(row(1,2)::jb_ordered_pair, '[{"x": 1, "y": 0}]');
---END---
---START---

-- negative cases where the wrong record type is supplied
select * from jsonb_populate_recordset(row(0::int),'[{"a":"1","b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
select * from jsonb_populate_recordset(row(0::int,0::int),'[{"a":"1","b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
select * from jsonb_populate_recordset(row(0::int,0::int,0::int),'[{"a":"1","b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
select * from jsonb_populate_recordset(row(1000000000::int,50::int),'[{"b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---

-- jsonb_to_record and jsonb_to_recordset

select * from jsonb_to_record('{"a":1,"b":"foo","c":"bar"}')
    as x(a int, b text, d text);
---END---
---START---

select * from jsonb_to_recordset('[{"a":1,"b":"foo","d":false},{"a":2,"b":"bar","c":true}]')
    as x(a int, b text, c boolean);
---END---
---START---

select *, c is null as c_is_null
from jsonb_to_record('{"a":1, "b":{"c":16, "d":2}, "x":8, "ca": ["1 2", 3], "ia": [[1,2],[3,4]], "r": {"a": "aaa", "b": 123}}'::jsonb)
    as t(a int, b jsonb, c text, x int, ca char(5)[], ia int[][], r jbpop);
---END---
---START---

select *, c is null as c_is_null
from jsonb_to_recordset('[{"a":1, "b":{"c":16, "d":2}, "x":8}]'::jsonb)
    as t(a int, b jsonb, c text, x int);
---END---
---START---

select * from jsonb_to_record('{"ia": null}') as x(ia _int4);
---END---
---START---
select * from jsonb_to_record('{"ia": 123}') as x(ia _int4);
---END---
---START---
select * from jsonb_to_record('{"ia": [1, "2", null, 4]}') as x(ia _int4);
---END---
---START---
select * from jsonb_to_record('{"ia": [[1, 2], [3, 4]]}') as x(ia _int4);
---END---
---START---
select * from jsonb_to_record('{"ia": [[1], 2]}') as x(ia _int4);
---END---
---START---
select * from jsonb_to_record('{"ia": [[1], [2, 3]]}') as x(ia _int4);
---END---
---START---

select * from jsonb_to_record('{"ia2": [1, 2, 3]}') as x(ia2 int[][]);
---END---
---START---
select * from jsonb_to_record('{"ia2": [[1, 2], [3, 4]]}') as x(ia2 int4[][]);
---END---
---START---
select * from jsonb_to_record('{"ia2": [[[1], [2], [3]]]}') as x(ia2 int4[][]);
---END---
---START---

select * from jsonb_to_record('{"out": {"key": 1}}') as x(out json);
---END---
---START---
select * from jsonb_to_record('{"out": [{"key": 1}]}') as x(out json);
---END---
---START---
select * from jsonb_to_record('{"out": "{\"key\": 1}"}') as x(out json);
---END---
---START---
select * from jsonb_to_record('{"out": {"key": 1}}') as x(out jsonb);
---END---
---START---
select * from jsonb_to_record('{"out": [{"key": 1}]}') as x(out jsonb);
---END---
---START---
select * from jsonb_to_record('{"out": "{\"key\": 1}"}') as x(out jsonb);
---END---
---START---

-- test type info caching in jsonb_populate_record()
CREATE TEMP TABLE jsbpoptest (js jsonb);
---END---
---START---

INSERT INTO jsbpoptest
SELECT '{
	"jsa": [1, "2", null, 4],
	"rec": {"a": "abc", "c": "01.02.2003", "x": 43.2},
	"reca": [{"a": "abc", "b": 456}, null, {"c": "01.02.2003", "x": 43.2}]
}'::jsonb
FROM generate_series(1, 3);
---END---
---START---

SELECT (jsonb_populate_record(NULL::jsbrec, js)).* FROM jsbpoptest;
---END---
---START---

DROP TYPE jsbrec;
---END---
---START---
DROP TYPE jsbrec_i_not_null;
---END---
---START---
DROP DOMAIN jsb_int_not_null;
---END---
---START---
DROP DOMAIN jsb_int_array_1d;
---END---
---START---
DROP DOMAIN jsb_int_array_2d;
---END---
---START---
DROP DOMAIN jb_ordered_pair;
---END---
---START---
DROP TYPE jb_unordered_pair;
---END---
---START---

-- indexing
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":null}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":"CC"}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":"CC", "public":true}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"age":25}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"age":25.0}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ? 'public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ? 'bar';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ?| ARRAY['public','disabled'];
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ?& ARRAY['public','disabled'];
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == null';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '"CC" == $.wait';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == "CC" && true == $.public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.age == 25';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.age == 25.0';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.public)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.bar)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.public) || exists($.disabled)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.public) && exists($.disabled)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? (@ == null)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? ("CC" == @)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.wait == "CC" && true == @.public)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.age ? (@ == 25)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.age == 25.0)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.bar';
---END---
---START---

CREATE INDEX jidx ON testjsonb USING gin (j);
---END---
---START---
SET enable_seqscan = off;
---END---
---START---

SELECT count(*) FROM testjsonb WHERE j @> '{"wait":null}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":"CC"}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":"CC", "public":true}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"age":25}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"age":25.0}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"array":["foo"]}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"array":["bar"]}';
---END---
---START---
-- exercise GIN_SEARCH_MODE_ALL
SELECT count(*) FROM testjsonb WHERE j @> '{}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ? 'public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ? 'bar';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ?| ARRAY['public','disabled'];
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j ?& ARRAY['public','disabled'];
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == null';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == null';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($ ? (@.wait == null))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.wait ? (@ == null))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '"CC" == $.wait';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == "CC" && true == $.public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.age == 25';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.age == 25.0';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.array[*] == "foo"';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.array[*] == "bar"';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($ ? (@.array[*] == "bar"))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.array ? (@[*] == "bar"))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.array[*] ? (@ == "bar"))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.public)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.bar)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.public) || exists($.disabled)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.public) && exists($.disabled)';
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? (@ == null)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? (@ == null)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? ("CC" == @)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.wait == "CC" && true == @.public)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.age ? (@ == 25)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.age == 25.0)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.array[*] == "bar")';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.array ? (@[*] == "bar")';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.array[*] ? (@ == "bar")';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.bar';
---END---
---START---

-- array exists - array elements should behave as keys (for GIN index scans too)
CREATE INDEX jidx_array ON testjsonb USING gin((j->'array'));
---END---
---START---
SELECT count(*) from testjsonb  WHERE j->'array' ? 'bar';
---END---
---START---
-- type sensitive array exists - should return no rows (since "exists" only
-- matches strings that are either object keys or array elements)
SELECT count(*) from testjsonb  WHERE j->'array' ? '5'::text;
---END---
---START---
-- However, a raw scalar is *contained* within the array
SELECT count(*) from testjsonb  WHERE j->'array' @> '5'::jsonb;
---END---
---START---

RESET enable_seqscan;
---END---
---START---

SELECT count(*) FROM (SELECT (jsonb_each(j)).key FROM testjsonb) AS wow;
---END---
---START---
SELECT key, count(*) FROM (SELECT (jsonb_each(j)).key FROM testjsonb) AS wow GROUP BY key ORDER BY count DESC, key;
---END---
---START---

-- sort/hash
SELECT count(distinct j) FROM testjsonb;
---END---
---START---
SET enable_hashagg = off;
---END---
---START---
SELECT count(*) FROM (SELECT j FROM (SELECT * FROM testjsonb UNION ALL SELECT * FROM testjsonb) js GROUP BY j) js2;
---END---
---START---
SET enable_hashagg = on;
---END---
---START---
SET enable_sort = off;
---END---
---START---
SELECT count(*) FROM (SELECT j FROM (SELECT * FROM testjsonb UNION ALL SELECT * FROM testjsonb) js GROUP BY j) js2;
---END---
---START---
SELECT distinct * FROM (values (jsonb '{}' || ''::text),('{}')) v(j);
---END---
---START---
SET enable_sort = on;
---END---
---START---

RESET enable_hashagg;
---END---
---START---
RESET enable_sort;
---END---
---START---

DROP INDEX jidx;
---END---
---START---
DROP INDEX jidx_array;
---END---
---START---
-- btree
CREATE INDEX jidx ON testjsonb USING btree (j);
---END---
---START---
SET enable_seqscan = off;
---END---
---START---

SELECT count(*) FROM testjsonb WHERE j > '{"p":1}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j = '{"pos":98, "line":371, "node":"CBA", "indexed":true}';
---END---
---START---

--gin path opclass
DROP INDEX jidx;
---END---
---START---
CREATE INDEX jidx ON testjsonb USING gin (j jsonb_path_ops);
---END---
---START---
SET enable_seqscan = off;
---END---
---START---

SELECT count(*) FROM testjsonb WHERE j @> '{"wait":null}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":"CC"}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"wait":"CC", "public":true}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"age":25}';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @> '{"age":25.0}';
---END---
---START---
-- exercise GIN_SEARCH_MODE_ALL
SELECT count(*) FROM testjsonb WHERE j @> '{}';
---END---
---START---

SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == null';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($ ? (@.wait == null))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.wait ? (@ == null))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '"CC" == $.wait';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.wait == "CC" && true == $.public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.age == 25';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.age == 25.0';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.array[*] == "foo"';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ '$.array[*] == "bar"';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($ ? (@.array[*] == "bar"))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.array ? (@[*] == "bar"))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($.array[*] ? (@ == "bar"))';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @@ 'exists($)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? (@ == null)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? (@ == null)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.wait ? ("CC" == @)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.wait == "CC" && true == @.public)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.age ? (@ == 25)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.age == 25.0)';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$ ? (@.array[*] == "bar")';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.array ? (@[*] == "bar")';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.array[*] ? (@ == "bar")';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.public';
---END---
---START---
SELECT count(*) FROM testjsonb WHERE j @? '$.bar';
---END---
---START---

RESET enable_seqscan;
---END---
---START---
DROP INDEX jidx;
---END---
---START---

-- nested tests
SELECT '{"ff":{"a":12,"b":16}}'::jsonb;
---END---
---START---
SELECT '{"ff":{"a":12,"b":16},"qq":123}'::jsonb;
---END---
---START---
SELECT '{"aa":["a","aaa"],"qq":{"a":12,"b":16,"c":["c1","c2"],"d":{"d1":"d1","d2":"d2","d1":"d3"}}}'::jsonb;
---END---
---START---
SELECT '{"aa":["a","aaa"],"qq":{"a":"12","b":"16","c":["c1","c2"],"d":{"d1":"d1","d2":"d2"}}}'::jsonb;
---END---
---START---
SELECT '{"aa":["a","aaa"],"qq":{"a":"12","b":"16","c":["c1","c2",["c3"],{"c4":4}],"d":{"d1":"d1","d2":"d2"}}}'::jsonb;
---END---
---START---
SELECT '{"ff":["a","aaa"]}'::jsonb;
---END---
---START---

SELECT
  '{"ff":{"a":12,"b":16},"qq":123,"x":[1,2],"Y":null}'::jsonb -> 'ff',
  '{"ff":{"a":12,"b":16},"qq":123,"x":[1,2],"Y":null}'::jsonb -> 'qq',
  ('{"ff":{"a":12,"b":16},"qq":123,"x":[1,2],"Y":null}'::jsonb -> 'Y') IS NULL AS f,
  ('{"ff":{"a":12,"b":16},"qq":123,"x":[1,2],"Y":null}'::jsonb ->> 'Y') IS NULL AS t,
   '{"ff":{"a":12,"b":16},"qq":123,"x":[1,2],"Y":null}'::jsonb -> 'x';
---END---
---START---

-- nested containment
SELECT '{"a":[1,2],"c":"b"}'::jsonb @> '{"a":[1,2]}';
---END---
---START---
SELECT '{"a":[2,1],"c":"b"}'::jsonb @> '{"a":[1,2]}';
---END---
---START---
SELECT '{"a":{"1":2},"c":"b"}'::jsonb @> '{"a":[1,2]}';
---END---
---START---
SELECT '{"a":{"2":1},"c":"b"}'::jsonb @> '{"a":[1,2]}';
---END---
---START---
SELECT '{"a":{"1":2},"c":"b"}'::jsonb @> '{"a":{"1":2}}';
---END---
---START---
SELECT '{"a":{"2":1},"c":"b"}'::jsonb @> '{"a":{"1":2}}';
---END---
---START---
SELECT '["a","b"]'::jsonb @> '["a","b","c","b"]';
---END---
---START---
SELECT '["a","b","c","b"]'::jsonb @> '["a","b"]';
---END---
---START---
SELECT '["a","b","c",[1,2]]'::jsonb @> '["a",[1,2]]';
---END---
---START---
SELECT '["a","b","c",[1,2]]'::jsonb @> '["b",[1,2]]';
---END---
---START---

SELECT '{"a":[1,2],"c":"b"}'::jsonb @> '{"a":[1]}';
---END---
---START---
SELECT '{"a":[1,2],"c":"b"}'::jsonb @> '{"a":[2]}';
---END---
---START---
SELECT '{"a":[1,2],"c":"b"}'::jsonb @> '{"a":[3]}';
---END---
---START---

SELECT '{"a":[1,2,{"c":3,"x":4}],"c":"b"}'::jsonb @> '{"a":[{"c":3}]}';
---END---
---START---
SELECT '{"a":[1,2,{"c":3,"x":4}],"c":"b"}'::jsonb @> '{"a":[{"x":4}]}';
---END---
---START---
SELECT '{"a":[1,2,{"c":3,"x":4}],"c":"b"}'::jsonb @> '{"a":[{"x":4},3]}';
---END---
---START---
SELECT '{"a":[1,2,{"c":3,"x":4}],"c":"b"}'::jsonb @> '{"a":[{"x":4},1]}';
---END---
---START---

-- check some corner cases for indexed nested containment (bug #13756)
create temp table nestjsonb (j jsonb);
---END---
---START---
insert into nestjsonb (j) values ('{"a":[["b",{"x":1}],["b",{"x":2}]],"c":3}');
---END---
---START---
insert into nestjsonb (j) values ('[[14,2,3]]');
---END---
---START---
insert into nestjsonb (j) values ('[1,[14,2,3]]');
---END---
---START---
create index on nestjsonb using gin(j jsonb_path_ops);
---END---
---START---

set enable_seqscan = on;
---END---
---START---
set enable_bitmapscan = off;
---END---
---START---
select * from nestjsonb where j @> '{"a":[[{"x":2}]]}'::jsonb;
---END---
---START---
select * from nestjsonb where j @> '{"c":3}';
---END---
---START---
select * from nestjsonb where j @> '[[14]]';
---END---
---START---
set enable_seqscan = off;
---END---
---START---
set enable_bitmapscan = on;
---END---
---START---
select * from nestjsonb where j @> '{"a":[[{"x":2}]]}'::jsonb;
---END---
---START---
select * from nestjsonb where j @> '{"c":3}';
---END---
---START---
select * from nestjsonb where j @> '[[14]]';
---END---
---START---
reset enable_seqscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---

-- nested object field / array index lookup
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'n';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'a';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'b';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'c';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'd';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'd' -> '1';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 'e';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb -> 0; --expecting error

SELECT '["a","b","c",[1,2],null]'::jsonb -> 0;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> 1;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> 2;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> 3;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> 3 -> 1;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> 4;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> 5;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> -1;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> -5;
---END---
---START---
SELECT '["a","b","c",[1,2],null]'::jsonb -> -6;
---END---
---START---

--nested path extraction
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{0}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{a}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,0}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,1}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,2}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,3}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,-1}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,-3}';
---END---
---START---
SELECT '{"a":"b","c":[1,2,3]}'::jsonb #> '{c,-4}';
---END---
---START---

SELECT '[0,1,2,[3,4],{"5":"five"}]'::jsonb #> '{0}';
---END---
---START---
SELECT '[0,1,2,[3,4],{"5":"five"}]'::jsonb #> '{3}';
---END---
---START---
SELECT '[0,1,2,[3,4],{"5":"five"}]'::jsonb #> '{4}';
---END---
---START---
SELECT '[0,1,2,[3,4],{"5":"five"}]'::jsonb #> '{4,5}';
---END---
---START---

--nested exists
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb ? 'n';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb ? 'a';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb ? 'b';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb ? 'c';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb ? 'd';
---END---
---START---
SELECT '{"n":null,"a":1,"b":[1,2],"c":{"1":2},"d":{"1":[2,3]}}'::jsonb ? 'e';
---END---
---START---

-- jsonb_strip_nulls

select jsonb_strip_nulls(null);
---END---
---START---

select jsonb_strip_nulls('1');
---END---
---START---

select jsonb_strip_nulls('"a string"');
---END---
---START---

select jsonb_strip_nulls('null');
---END---
---START---

select jsonb_strip_nulls('[1,2,null,3,4]');
---END---
---START---

select jsonb_strip_nulls('{"a":1,"b":null,"c":[2,null,3],"d":{"e":4,"f":null}}');
---END---
---START---

select jsonb_strip_nulls('[1,{"a":1,"b":null,"c":2},3]');
---END---
---START---

-- an empty object is not null and should not be stripped
select jsonb_strip_nulls('{"a": {"b": null, "c": null}, "d": {} }');
---END---
---START---


select jsonb_pretty('{"a": "test", "b": [1, 2, 3], "c": "test3", "d":{"dd": "test4", "dd2":{"ddd": "test5"}}}');
---END---
---START---
select jsonb_pretty('[{"f1":1,"f2":null},2,null,[[{"x":true},6,7],8],3]');
---END---
---START---
select jsonb_pretty('{"a":["b", "c"], "d": {"e":"f"}}');
---END---
---START---

select jsonb_concat('{"d": "test", "a": [1, 2]}', '{"g": "test2", "c": {"c1":1, "c2":2}}');
---END---
---START---

select '{"aa":1 , "b":2, "cq":3}'::jsonb || '{"cq":"l", "b":"g", "fg":false}';
---END---
---START---
select '{"aa":1 , "b":2, "cq":3}'::jsonb || '{"aq":"l"}';
---END---
---START---
select '{"aa":1 , "b":2, "cq":3}'::jsonb || '{"aa":"l"}';
---END---
---START---
select '{"aa":1 , "b":2, "cq":3}'::jsonb || '{}';
---END---
---START---

select '["a", "b"]'::jsonb || '["c"]';
---END---
---START---
select '["a", "b"]'::jsonb || '["c", "d"]';
---END---
---START---
select '["c"]' || '["a", "b"]'::jsonb;
---END---
---START---

select '["a", "b"]'::jsonb || '"c"';
---END---
---START---
select '"c"' || '["a", "b"]'::jsonb;
---END---
---START---

select '[]'::jsonb || '["a"]'::jsonb;
---END---
---START---
select '[]'::jsonb || '"a"'::jsonb;
---END---
---START---
select '"b"'::jsonb || '"a"'::jsonb;
---END---
---START---
select '{}'::jsonb || '{"a":"b"}'::jsonb;
---END---
---START---
select '[]'::jsonb || '{"a":"b"}'::jsonb;
---END---
---START---
select '{"a":"b"}'::jsonb || '[]'::jsonb;
---END---
---START---

select '"a"'::jsonb || '{"a":1}';
---END---
---START---
select '{"a":1}' || '"a"'::jsonb;
---END---
---START---

select '[3]'::jsonb || '{}'::jsonb;
---END---
---START---
select '3'::jsonb || '[]'::jsonb;
---END---
---START---
select '3'::jsonb || '4'::jsonb;
---END---
---START---
select '3'::jsonb || '{}'::jsonb;
---END---
---START---

select '["a", "b"]'::jsonb || '{"c":1}';
---END---
---START---
select '{"c": 1}'::jsonb || '["a", "b"]';
---END---
---START---

select '{}'::jsonb || '{"cq":"l", "b":"g", "fg":false}';
---END---
---START---

select pg_column_size('{}'::jsonb || '{}'::jsonb) = pg_column_size('{}'::jsonb);
---END---
---START---
select pg_column_size('{"aa":1}'::jsonb || '{"b":2}'::jsonb) = pg_column_size('{"aa":1, "b":2}'::jsonb);
---END---
---START---
select pg_column_size('{"aa":1, "b":2}'::jsonb || '{}'::jsonb) = pg_column_size('{"aa":1, "b":2}'::jsonb);
---END---
---START---
select pg_column_size('{}'::jsonb || '{"aa":1, "b":2}'::jsonb) = pg_column_size('{"aa":1, "b":2}'::jsonb);
---END---
---START---

select jsonb_delete('{"a":1 , "b":2, "c":3}'::jsonb, 'a');
---END---
---START---
select jsonb_delete('{"a":null , "b":2, "c":3}'::jsonb, 'a');
---END---
---START---
select jsonb_delete('{"a":1 , "b":2, "c":3}'::jsonb, 'b');
---END---
---START---
select jsonb_delete('{"a":1 , "b":2, "c":3}'::jsonb, 'c');
---END---
---START---
select jsonb_delete('{"a":1 , "b":2, "c":3}'::jsonb, 'd');
---END---
---START---
select '{"a":1 , "b":2, "c":3}'::jsonb - 'a';
---END---
---START---
select '{"a":null , "b":2, "c":3}'::jsonb - 'a';
---END---
---START---
select '{"a":1 , "b":2, "c":3}'::jsonb - 'b';
---END---
---START---
select '{"a":1 , "b":2, "c":3}'::jsonb - 'c';
---END---
---START---
select '{"a":1 , "b":2, "c":3}'::jsonb - 'd';
---END---
---START---
select pg_column_size('{"a":1 , "b":2, "c":3}'::jsonb - 'b') = pg_column_size('{"a":1, "b":2}'::jsonb);
---END---
---START---

select '["a","b","c"]'::jsonb - 3;
---END---
---START---
select '["a","b","c"]'::jsonb - 2;
---END---
---START---
select '["a","b","c"]'::jsonb - 1;
---END---
---START---
select '["a","b","c"]'::jsonb - 0;
---END---
---START---
select '["a","b","c"]'::jsonb - -1;
---END---
---START---
select '["a","b","c"]'::jsonb - -2;
---END---
---START---
select '["a","b","c"]'::jsonb - -3;
---END---
---START---
select '["a","b","c"]'::jsonb - -4;
---END---
---START---

select '{"a":1 , "b":2, "c":3}'::jsonb - '{b}'::text[];
---END---
---START---
select '{"a":1 , "b":2, "c":3}'::jsonb - '{c,b}'::text[];
---END---
---START---
select '{"a":1 , "b":2, "c":3}'::jsonb - '{}'::text[];
---END---
---START---

select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{n}', '[1,2,3]');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{b,-1}', '[1,2,3]');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{d,1,0}', '[1,2,3]');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{d,NULL,0}', '[1,2,3]');
---END---
---START---

select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{n}', '{"1": 2}');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{b,-1}', '{"1": 2}');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{d,1,0}', '{"1": 2}');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{d,NULL,0}', '{"1": 2}');
---END---
---START---

select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{b,-1}', '"test"');
---END---
---START---
select jsonb_set('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb, '{b,-1}', '{"f": "test"}');
---END---
---START---

select jsonb_delete_path('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}', '{n}');
---END---
---START---
select jsonb_delete_path('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}', '{b,-1}');
---END---
---START---
select jsonb_delete_path('{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}', '{d,1,0}');
---END---
---START---

select '{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb #- '{n}';
---END---
---START---
select '{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb #- '{b,-1}';
---END---
---START---
select '{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb #- '{b,-1e}'; -- invalid array subscript
select '{"n":null, "a":1, "b":[1,2], "c":{"1":2}, "d":{"1":[2,3]}}'::jsonb #- '{d,1,0}';
---END---
---START---


-- empty structure and error conditions for delete and replace

select '"a"'::jsonb - 'a'; -- error
select '{}'::jsonb - 'a';
---END---
---START---
select '[]'::jsonb - 'a';
---END---
---START---
select '"a"'::jsonb - 1; -- error
select '{}'::jsonb -  1; -- error
select '[]'::jsonb - 1;
---END---
---START---
select '"a"'::jsonb #- '{a}'; -- error
select '{}'::jsonb #- '{a}';
---END---
---START---
select '[]'::jsonb #- '{a}';
---END---
---START---
select jsonb_set('"a"','{a}','"b"'); --error
select jsonb_set('{}','{a}','"b"', false);
---END---
---START---
select jsonb_set('[]','{1}','"b"', false);
---END---
---START---
select jsonb_set('[{"f1":1,"f2":null},2,null,3]', '{0}','[2,3,4]', false);
---END---
---START---

-- jsonb_set adding instead of replacing

-- prepend to array
select jsonb_set('{"a":1,"b":[0,1,2],"c":{"d":4}}','{b,-33}','{"foo":123}');
---END---
---START---
-- append to array
select jsonb_set('{"a":1,"b":[0,1,2],"c":{"d":4}}','{b,33}','{"foo":123}');
---END---
---START---
-- check nesting levels addition
select jsonb_set('{"a":1,"b":[4,5,[0,1,2],6,7],"c":{"d":4}}','{b,2,33}','{"foo":123}');
---END---
---START---
-- add new key
select jsonb_set('{"a":1,"b":[0,1,2],"c":{"d":4}}','{c,e}','{"foo":123}');
---END---
---START---
-- adding doesn't do anything if elements before last aren't present
select jsonb_set('{"a":1,"b":[0,1,2],"c":{"d":4}}','{x,-33}','{"foo":123}');
---END---
---START---
select jsonb_set('{"a":1,"b":[0,1,2],"c":{"d":4}}','{x,y}','{"foo":123}');
---END---
---START---
-- add to empty object
select jsonb_set('{}','{x}','{"foo":123}');
---END---
---START---
--add to empty array
select jsonb_set('[]','{0}','{"foo":123}');
---END---
---START---
select jsonb_set('[]','{99}','{"foo":123}');
---END---
---START---
select jsonb_set('[]','{-99}','{"foo":123}');
---END---
---START---
select jsonb_set('{"a": [1, 2, 3]}', '{a, non_integer}', '"new_value"');
---END---
---START---
select jsonb_set('{"a": {"b": [1, 2, 3]}}', '{a, b, non_integer}', '"new_value"');
---END---
---START---
select jsonb_set('{"a": {"b": [1, 2, 3]}}', '{a, b, NULL}', '"new_value"');
---END---
---START---

-- jsonb_set_lax

\pset null NULL

-- pass though non nulls to jsonb_set
select jsonb_set_lax('{"a":1,"b":2}','{b}','5') ;
---END---
---START---
select jsonb_set_lax('{"a":1,"b":2}','{d}','6', true) ;
---END---
---START---
-- using the default treatment
select jsonb_set_lax('{"a":1,"b":2}','{b}',null);
---END---
---START---
select jsonb_set_lax('{"a":1,"b":2}','{d}',null,true);
---END---
---START---
-- errors
select jsonb_set_lax('{"a":1,"b":2}', '{b}', null, true, null);
---END---
---START---
select jsonb_set_lax('{"a":1,"b":2}', '{b}', null, true, 'no_such_treatment');
---END---
---START---
-- explicit treatments
select jsonb_set_lax('{"a":1,"b":2}', '{b}', null, null_value_treatment => 'raise_exception') as raise_exception;
---END---
---START---
select jsonb_set_lax('{"a":1,"b":2}', '{b}', null, null_value_treatment => 'return_target') as return_target;
---END---
---START---
select jsonb_set_lax('{"a":1,"b":2}', '{b}', null, null_value_treatment => 'delete_key') as delete_key;
---END---
---START---
select jsonb_set_lax('{"a":1,"b":2}', '{b}', null, null_value_treatment => 'use_json_null') as use_json_null;
---END---
---START---

\pset null ''

-- jsonb_insert
select jsonb_insert('{"a": [0,1,2]}', '{a, 1}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 1}', '"new_value"', true);
---END---
---START---
select jsonb_insert('{"a": {"b": {"c": [0, 1, "test1", "test2"]}}}', '{a, b, c, 2}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": {"b": {"c": [0, 1, "test1", "test2"]}}}', '{a, b, c, 2}', '"new_value"', true);
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 1}', '{"b": "value"}');
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 1}', '["value1", "value2"]');
---END---
---START---

-- edge cases
select jsonb_insert('{"a": [0,1,2]}', '{a, 0}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 0}', '"new_value"', true);
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 2}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 2}', '"new_value"', true);
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, -1}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, -1}', '"new_value"', true);
---END---
---START---
select jsonb_insert('[]', '{1}', '"new_value"');
---END---
---START---
select jsonb_insert('[]', '{1}', '"new_value"', true);
---END---
---START---
select jsonb_insert('{"a": []}', '{a, 1}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": []}', '{a, 1}', '"new_value"', true);
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, 10}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": [0,1,2]}', '{a, -10}', '"new_value"');
---END---
---START---

-- jsonb_insert should be able to insert new value for objects, but not to replace
select jsonb_insert('{"a": {"b": "value"}}', '{a, c}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": {"b": "value"}}', '{a, c}', '"new_value"', true);
---END---
---START---

select jsonb_insert('{"a": {"b": "value"}}', '{a, b}', '"new_value"');
---END---
---START---
select jsonb_insert('{"a": {"b": "value"}}', '{a, b}', '"new_value"', true);
---END---
---START---

-- jsonb subscript
select ('123'::jsonb)['a'];
---END---
---START---
select ('123'::jsonb)[0];
---END---
---START---
select ('123'::jsonb)[NULL];
---END---
---START---
select ('{"a": 1}'::jsonb)['a'];
---END---
---START---
select ('{"a": 1}'::jsonb)[0];
---END---
---START---
select ('{"a": 1}'::jsonb)['not_exist'];
---END---
---START---
select ('{"a": 1}'::jsonb)[NULL];
---END---
---START---
select ('[1, "2", null]'::jsonb)['a'];
---END---
---START---
select ('[1, "2", null]'::jsonb)[0];
---END---
---START---
select ('[1, "2", null]'::jsonb)['1'];
---END---
---START---
select ('[1, "2", null]'::jsonb)[1.0];
---END---
---START---
select ('[1, "2", null]'::jsonb)[2];
---END---
---START---
select ('[1, "2", null]'::jsonb)[3];
---END---
---START---
select ('[1, "2", null]'::jsonb)[-2];
---END---
---START---
select ('[1, "2", null]'::jsonb)[1]['a'];
---END---
---START---
select ('[1, "2", null]'::jsonb)[1][0];
---END---
---START---
select ('{"a": 1, "b": "c", "d": [1, 2, 3]}'::jsonb)['b'];
---END---
---START---
select ('{"a": 1, "b": "c", "d": [1, 2, 3]}'::jsonb)['d'];
---END---
---START---
select ('{"a": 1, "b": "c", "d": [1, 2, 3]}'::jsonb)['d'][1];
---END---
---START---
select ('{"a": 1, "b": "c", "d": [1, 2, 3]}'::jsonb)['d']['a'];
---END---
---START---
select ('{"a": {"a1": {"a2": "aaa"}}, "b": "bbb", "c": "ccc"}'::jsonb)['a']['a1'];
---END---
---START---
select ('{"a": {"a1": {"a2": "aaa"}}, "b": "bbb", "c": "ccc"}'::jsonb)['a']['a1']['a2'];
---END---
---START---
select ('{"a": {"a1": {"a2": "aaa"}}, "b": "bbb", "c": "ccc"}'::jsonb)['a']['a1']['a2']['a3'];
---END---
---START---
select ('{"a": ["a1", {"b1": ["aaa", "bbb", "ccc"]}], "b": "bb"}'::jsonb)['a'][1]['b1'];
---END---
---START---
select ('{"a": ["a1", {"b1": ["aaa", "bbb", "ccc"]}], "b": "bb"}'::jsonb)['a'][1]['b1'][2];
---END---
---START---

-- slices are not supported
select ('{"a": 1}'::jsonb)['a':'b'];
---END---
---START---
select ('[1, "2", null]'::jsonb)[1:2];
---END---
---START---
select ('[1, "2", null]'::jsonb)[:2];
---END---
---START---
select ('[1, "2", null]'::jsonb)[1:];
---END---
---START---
select ('[1, "2", null]'::jsonb)[:];
---END---
---START---

create TEMP TABLE test_jsonb_subscript (
       id int,
       test_json jsonb
);
---END---
---START---

insert into test_jsonb_subscript values
(1, '{}'), -- empty jsonb
(2, '{"key": "value"}'); -- jsonb with data

-- update empty jsonb
update test_jsonb_subscript set test_json['a'] = '1' where id = 1;
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- update jsonb with some data
update test_jsonb_subscript set test_json['a'] = '1' where id = 2;
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- replace jsonb
update test_jsonb_subscript set test_json['a'] = '"test"';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- replace by object
update test_jsonb_subscript set test_json['a'] = '{"b": 1}'::jsonb;
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- replace by array
update test_jsonb_subscript set test_json['a'] = '[1, 2, 3]'::jsonb;
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- use jsonb subscription in where clause
select * from test_jsonb_subscript where test_json['key'] = '"value"';
---END---
---START---
select * from test_jsonb_subscript where test_json['key_doesnt_exists'] = '"value"';
---END---
---START---
select * from test_jsonb_subscript where test_json['key'] = '"wrong_value"';
---END---
---START---

-- NULL
update test_jsonb_subscript set test_json[NULL] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['another_key'] = NULL;
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- NULL as jsonb source
insert into test_jsonb_subscript values (3, NULL);
---END---
---START---
update test_jsonb_subscript set test_json['a'] = '1' where id = 3;
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

update test_jsonb_subscript set test_json = NULL where id = 3;
---END---
---START---
update test_jsonb_subscript set test_json[0] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- Fill the gaps logic
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '[0]');
---END---
---START---

update test_jsonb_subscript set test_json[5] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

update test_jsonb_subscript set test_json[-4] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

update test_jsonb_subscript set test_json[-8] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- keep consistent values position
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '[]');
---END---
---START---

update test_jsonb_subscript set test_json[5] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- create the whole path
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{}');
---END---
---START---
update test_jsonb_subscript set test_json['a'][0]['b'][0]['c'] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{}');
---END---
---START---
update test_jsonb_subscript set test_json['a'][2]['b'][2]['c'][2] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- create the whole path with already existing keys
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{"b": 1}');
---END---
---START---
update test_jsonb_subscript set test_json['a'][0] = '2';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- the start jsonb is an object, first subscript is treated as a key
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{}');
---END---
---START---
update test_jsonb_subscript set test_json[0]['a'] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- the start jsonb is an array
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '[]');
---END---
---START---
update test_jsonb_subscript set test_json[0]['a'] = '1';
---END---
---START---
update test_jsonb_subscript set test_json[2]['b'] = '2';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- overwriting an existing path
delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{}');
---END---
---START---
update test_jsonb_subscript set test_json['a']['b'][1] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['a']['b'][10] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '[]');
---END---
---START---
update test_jsonb_subscript set test_json[0][0][0] = '1';
---END---
---START---
update test_jsonb_subscript set test_json[0][0][1] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{}');
---END---
---START---
update test_jsonb_subscript set test_json['a']['b'][10] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['a'][10][10] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- an empty sub element

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{"a": {}}');
---END---
---START---
update test_jsonb_subscript set test_json['a']['b']['c'][2] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{"a": []}');
---END---
---START---
update test_jsonb_subscript set test_json['a'][1]['c'][2] = '1';
---END---
---START---
select * from test_jsonb_subscript;
---END---
---START---

-- trying replace assuming a composite object, but it's an element or a value

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, '{"a": 1}');
---END---
---START---
update test_jsonb_subscript set test_json['a']['b'] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['a']['b']['c'] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['a'][0] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['a'][0]['c'] = '1';
---END---
---START---
update test_jsonb_subscript set test_json['a'][0][0] = '1';
---END---
---START---

-- trying replace assuming a composite object, but it's a raw scalar

delete from test_jsonb_subscript;
---END---
---START---
insert into test_jsonb_subscript values (1, 'null');
---END---
---START---
update test_jsonb_subscript set test_json[0] = '1';
---END---
---START---
update test_jsonb_subscript set test_json[0][0] = '1';
---END---
---START---

-- try some things with short-header and toasted subscript values

drop table test_jsonb_subscript;
---END---
---START---
create temp table test_jsonb_subscript (
       id text,
       test_json jsonb
);
---END---
---START---

insert into test_jsonb_subscript values('foo', '{"foo": "bar"}');
---END---
---START---
insert into test_jsonb_subscript
  select s, ('{"' || s || '": "bar"}')::jsonb from repeat('xyzzy', 500) s;
---END---
---START---
select length(id), test_json[id] from test_jsonb_subscript;
---END---
---START---
update test_jsonb_subscript set test_json[id] = '"baz"';
---END---
---START---
select length(id), test_json[id] from test_jsonb_subscript;
---END---
---START---
\x
table test_jsonb_subscript;
---END---
---START---
\x

-- jsonb to tsvector
select to_tsvector('{"a": "aaa bbb ddd ccc", "b": ["eee fff ggg"], "c": {"d": "hhh iii"}}'::jsonb);
---END---
---START---

-- jsonb to tsvector with config
select to_tsvector('simple', '{"a": "aaa bbb ddd ccc", "b": ["eee fff ggg"], "c": {"d": "hhh iii"}}'::jsonb);
---END---
---START---

-- jsonb to tsvector with stop words
select to_tsvector('english', '{"a": "aaa in bbb ddd ccc", "b": ["the eee fff ggg"], "c": {"d": "hhh. iii"}}'::jsonb);
---END---
---START---

-- jsonb to tsvector with numeric values
select to_tsvector('english', '{"a": "aaa in bbb ddd ccc", "b": 123, "c": 456}'::jsonb);
---END---
---START---

-- jsonb_to_tsvector
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"all"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"key"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"string"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"numeric"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"boolean"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '["string", "numeric"]');
---END---
---START---

select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"all"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"key"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"string"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"numeric"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '"boolean"');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '["string", "numeric"]');
---END---
---START---

-- to_tsvector corner cases
select to_tsvector('""'::jsonb);
---END---
---START---
select to_tsvector('{}'::jsonb);
---END---
---START---
select to_tsvector('[]'::jsonb);
---END---
---START---
select to_tsvector('null'::jsonb);
---END---
---START---

-- jsonb_to_tsvector corner cases
select jsonb_to_tsvector('""'::jsonb, '"all"');
---END---
---START---
select jsonb_to_tsvector('{}'::jsonb, '"all"');
---END---
---START---
select jsonb_to_tsvector('[]'::jsonb, '"all"');
---END---
---START---
select jsonb_to_tsvector('null'::jsonb, '"all"');
---END---
---START---

select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '""');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '{}');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '[]');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, 'null');
---END---
---START---
select jsonb_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::jsonb, '["all", null]');
---END---
---START---

-- ts_headline for jsonb
select ts_headline('{"a": "aaa bbb", "b": {"c": "ccc ddd fff", "c1": "ccc1 ddd1"}, "d": ["ggg hhh", "iii jjj"]}'::jsonb, tsquery('bbb & ddd & hhh'));
---END---
---START---
select ts_headline('english', '{"a": "aaa bbb", "b": {"c": "ccc ddd fff"}, "d": ["ggg hhh", "iii jjj"]}'::jsonb, tsquery('bbb & ddd & hhh'));
---END---
---START---
select ts_headline('{"a": "aaa bbb", "b": {"c": "ccc ddd fff", "c1": "ccc1 ddd1"}, "d": ["ggg hhh", "iii jjj"]}'::jsonb, tsquery('bbb & ddd & hhh'), 'StartSel = <, StopSel = >');
---END---
---START---
select ts_headline('english', '{"a": "aaa bbb", "b": {"c": "ccc ddd fff", "c1": "ccc1 ddd1"}, "d": ["ggg hhh", "iii jjj"]}'::jsonb, tsquery('bbb & ddd & hhh'), 'StartSel = <, StopSel = >');
---END---
---START---

-- corner cases for ts_headline with jsonb
select ts_headline('null'::jsonb, tsquery('aaa & bbb'));
---END---
---START---
select ts_headline('{}'::jsonb, tsquery('aaa & bbb'));
---END---
---START---
select ts_headline('[]'::jsonb, tsquery('aaa & bbb'));
---END---
---START---

-- casts
select 'true'::jsonb::bool;
---END---
---START---
select '[]'::jsonb::bool;
---END---
---START---
select '1.0'::jsonb::float;
---END---
---START---
select '[1.0]'::jsonb::float;
---END---
---START---
select '12345'::jsonb::int4;
---END---
---START---
select '"hello"'::jsonb::int4;
---END---
---START---
select '12345'::jsonb::numeric;
---END---
---START---
select '{}'::jsonb::numeric;
---END---
---START---
select '12345.05'::jsonb::numeric;
---END---
---START---
select '12345.05'::jsonb::float4;
---END---
---START---
select '12345.05'::jsonb::float8;
---END---
---START---
select '12345.05'::jsonb::int2;
---END---
---START---
select '12345.05'::jsonb::int4;
---END---
---START---
select '12345.05'::jsonb::int8;
---END---
---START---
select '12345.0000000000000000000000000000000000000000000005'::jsonb::numeric;
---END---
---START---
select '12345.0000000000000000000000000000000000000000000005'::jsonb::float4;
---END---
---START---
select '12345.0000000000000000000000000000000000000000000005'::jsonb::float8;
---END---
---START---
select '12345.0000000000000000000000000000000000000000000005'::jsonb::int2;
---END---
---START---
select '12345.0000000000000000000000000000000000000000000005'::jsonb::int4;
---END---
---START---
select '12345.0000000000000000000000000000000000000000000005'::jsonb::int8;
---END---
