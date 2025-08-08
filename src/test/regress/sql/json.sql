---START---
-- Strings.
SELECT '""'::json;
---END---
---START---
-- OK.
SELECT $$''$$::json;
---END---
---START---
-- ERROR, single quotes are not allowed
SELECT '"abc"'::json;
---END---
---START---
-- OK
SELECT '"abc'::json;
---END---
---START---
-- ERROR, quotes not closed
SELECT '"abc
def"'::json;
---END---
---START---
-- ERROR, unescaped newline in string constant
SELECT '"\n\"\\"'::json;
---END---
---START---
-- OK, legal escapes
SELECT '"\v"'::json;
---END---
---START---
-- ERROR, not a valid JSON escape

-- Check fast path for longer strings (at least 16 bytes long)
SELECT ('"'||repeat('.', 12)||'abc"')::json;
---END---
---START---
-- OK
SELECT ('"'||repeat('.', 12)||'abc\n"')::json;
---END---
---START---
-- OK, legal escapes

-- see json_encoding test for input with unicode escapes

-- Numbers.
SELECT '1'::json;
---END---
---START---
-- OK
SELECT '0'::json;
---END---
---START---
-- OK
SELECT '01'::json;
---END---
---START---
-- ERROR, not valid according to JSON spec
SELECT '0.1'::json;
---END---
---START---
-- OK
SELECT '9223372036854775808'::json;
---END---
---START---
-- OK, even though it's too large for int8
SELECT '1e100'::json;
---END---
---START---
-- OK
SELECT '1.3e100'::json;
---END---
---START---
-- OK
SELECT '1f2'::json;
---END---
---START---
-- ERROR
SELECT '0.x1'::json;
---END---
---START---
-- ERROR
SELECT '1.3ex100'::json;
---END---
---START---
-- ERROR

-- Arrays.
SELECT '[]'::json;
---END---
---START---
-- OK
SELECT '[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]'::json;
---END---
---START---
-- OK
SELECT '[1,2]'::json;
---END---
---START---
-- OK
SELECT '[1,2,]'::json;
---END---
---START---
-- ERROR, trailing comma
SELECT '[1,2'::json;
---END---
---START---
-- ERROR, no closing bracket
SELECT '[1,[2]'::json;
---END---
---START---
-- ERROR, no closing bracket

-- Objects.
SELECT '{}'::json;
---END---
---START---
-- OK
SELECT '{"abc"}'::json;
---END---
---START---
-- ERROR, no value
SELECT '{"abc":1}'::json;
---END---
---START---
-- OK
SELECT '{1:"abc"}'::json;
---END---
---START---
-- ERROR, keys must be strings
SELECT '{"abc",1}'::json;
---END---
---START---
-- ERROR, wrong separator
SELECT '{"abc"=1}'::json;
---END---
---START---
-- ERROR, totally wrong separator
SELECT '{"abc"::1}'::json;
---END---
---START---
-- ERROR, another wrong separator
SELECT '{"abc":1,"def":2,"ghi":[3,4],"hij":{"klm":5,"nop":[6]}}'::json;
---END---
---START---
-- OK
SELECT '{"abc":1:2}'::json;
---END---
---START---
-- ERROR, colon in wrong spot
SELECT '{"abc":1,3}'::json;
---END---
---START---
-- ERROR, no value

-- Recursion.
SET max_stack_depth = '100kB';
---END---
---START---
SELECT repeat('[', 10000)::json;
---END---
---START---
SELECT repeat('{"a":', 10000)::json;
---END---
---START---
RESET max_stack_depth;
---END---
---START---
-- Miscellaneous stuff.
SELECT 'true'::json;
---END---
---START---
-- OK
SELECT 'false'::json;
---END---
---START---
-- OK
SELECT 'null'::json;
---END---
---START---
-- OK
SELECT ' true '::json;
---END---
---START---
-- OK, even with extra whitespace
SELECT 'true false'::json;
---END---
---START---
-- ERROR, too many values
SELECT 'true, false'::json;
---END---
---START---
-- ERROR, too many values
SELECT 'truf'::json;
---END---
---START---
-- ERROR, not a keyword
SELECT 'trues'::json;
---END---
---START---
-- ERROR, not a keyword
SELECT ''::json;
---END---
---START---
-- ERROR, no value
SELECT '    '::json;
---END---
---START---
-- ERROR, no value

-- Multi-line JSON input to check ERROR reporting
SELECT '{
		"one": 1,
		"two":"two",
		"three":
		true}'::json;
---END---
---START---
-- OK
SELECT '{
		"one": 1,
		"two":,"two",  -- ERROR extraneous comma before field "two"
		"three":
		true}'::json;
---END---
---START---
SELECT '{
		"one": 1,
		"two":"two",
		"averyveryveryveryveryveryveryveryveryverylongfieldname":}'::json;
---END---
---START---
-- ERROR missing value for last field

-- test non-error-throwing input
select pg_input_is_valid('{"a":true}', 'json');
---END---
---START---
select pg_input_is_valid('{"a":true', 'json');
---END---
---START---
select * from pg_input_error_info('{"a":true', 'json');
---END---
---START---
--constructors
-- array_to_json

SELECT array_to_json(array(select 1 as a));
---END---
---START---
SELECT array_to_json(array_agg(q),false) from (select x as b, x * 2 as c from generate_series(1,3) x) q;
---END---
---START---
SELECT array_to_json(array_agg(q),true) from (select x as b, x * 2 as c from generate_series(1,3) x) q;
---END---
---START---
SELECT array_to_json(array_agg(q),false)
  FROM ( SELECT $$a$$ || x AS b, y AS c,
               ARRAY[ROW(x.*,ARRAY[1,2,3]),
               ROW(y.*,ARRAY[4,5,6])] AS z
         FROM generate_series(1,2) x,
              generate_series(4,5) y) q;
---END---
---START---
SELECT array_to_json(array_agg(x),false) from generate_series(5,10) x;
---END---
---START---
SELECT array_to_json('{{1,5},{99,100}}'::int[]);
---END---
---START---
-- row_to_json
SELECT row_to_json(row(1,'foo'));
---END---
---START---
SELECT row_to_json(q)
FROM (SELECT $$a$$ || x AS b,
         y AS c,
         ARRAY[ROW(x.*,ARRAY[1,2,3]),
               ROW(y.*,ARRAY[4,5,6])] AS z
      FROM generate_series(1,2) x,
           generate_series(4,5) y) q;
---END---
---START---
SELECT row_to_json(q,true)
FROM (SELECT $$a$$ || x AS b,
         y AS c,
         ARRAY[ROW(x.*,ARRAY[1,2,3]),
               ROW(y.*,ARRAY[4,5,6])] AS z
      FROM generate_series(1,2) x,
           generate_series(4,5) y) q;
---END---
---START---
DROP TABLE IF EXISTS rows;

CREATE TABLE rows AS
SELECT x, 'txt' || x as y
FROM generate_series(1,3) AS x;
---END---
---START---
SELECT row_to_json(q,true)
FROM rows q;
---END---
---START---
SELECT row_to_json(row((select array_agg(x) as d from generate_series(5,10) x)),false);
---END---
---START---
-- anyarray column

analyze rows;
---END---
---START---
select attname, to_json(histogram_bounds) histogram_bounds
from pg_stats
where tablename = 'rows' and
      schemaname = pg_my_temp_schema()::regnamespace::text
order by 1;
---END---
---START---
-- to_json, timestamps

select to_json(timestamp '2014-05-28 12:22:35.614298');
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL TIME ZONE 10.5;
---END---
---START---
select to_json(timestamptz '2014-05-28 12:22:35.614298-04');
---END---
---START---
SET LOCAL TIME ZONE -8;
---END---
---START---
select to_json(timestamptz '2014-05-28 12:22:35.614298-04');
---END---
---START---
COMMIT;
---END---
---START---
select to_json(date '2014-05-28');
---END---
---START---
select to_json(date 'Infinity');
---END---
---START---
select to_json(date '-Infinity');
---END---
---START---
select to_json(timestamp 'Infinity');
---END---
---START---
select to_json(timestamp '-Infinity');
---END---
---START---
select to_json(timestamptz 'Infinity');
---END---
---START---
select to_json(timestamptz '-Infinity');
---END---
---START---
--json_agg

SELECT json_agg(q)
  FROM ( SELECT $$a$$ || x AS b, y AS c,
               ARRAY[ROW(x.*,ARRAY[1,2,3]),
               ROW(y.*,ARRAY[4,5,6])] AS z
         FROM generate_series(1,2) x,
              generate_series(4,5) y) q;
---END---
---START---
SELECT json_agg(q ORDER BY x, y)
  FROM rows q;
---END---
---START---
UPDATE rows SET x = NULL WHERE x = 1;
---END---
---START---
SELECT json_agg(q ORDER BY x NULLS FIRST, y)
  FROM rows q;
---END---
---START---
-- non-numeric output
SELECT row_to_json(q)
FROM (SELECT 'NaN'::float8 AS "float8field") q;
---END---
---START---
SELECT row_to_json(q)
FROM (SELECT 'Infinity'::float8 AS "float8field") q;
---END---
---START---
SELECT row_to_json(q)
FROM (SELECT '-Infinity'::float8 AS "float8field") q;
---END---
---START---
-- json input
SELECT row_to_json(q)
FROM (SELECT '{"a":1,"b": [2,3,4,"d","e","f"],"c":{"p":1,"q":2}}'::json AS "jsonfield") q;
---END---
---START---
-- json extraction functions

DROP TABLE IF EXISTS test_json;

CREATE TABLE test_json (gemini_pk serial PRIMARY KEY, json_type text, test_json pg_catalog.json);
---END---
---START---
INSERT INTO test_json VALUES
('scalar','"a scalar"'),
('array','["zero", "one","two",null,"four","five", [1,2,3],{"f1":9}]'),
('object','{"field1":"val1","field2":"val2","field3":null, "field4": 4, "field5": [1,2,3], "field6": {"f1":9}}');
---END---
---START---
SELECT test_json -> 'x'
FROM test_json
WHERE json_type = 'scalar';
---END---
---START---
SELECT test_json -> 'x'
FROM test_json
WHERE json_type = 'array';
---END---
---START---
SELECT test_json -> 'x'
FROM test_json
WHERE json_type = 'object';
---END---
---START---
SELECT test_json->'field2'
FROM test_json
WHERE json_type = 'object';
---END---
---START---
SELECT test_json->>'field2'
FROM test_json
WHERE json_type = 'object';
---END---
---START---
SELECT test_json -> 2
FROM test_json
WHERE json_type = 'scalar';
---END---
---START---
SELECT test_json -> 2
FROM test_json
WHERE json_type = 'array';
---END---
---START---
SELECT test_json -> -1
FROM test_json
WHERE json_type = 'array';
---END---
---START---
SELECT test_json -> 2
FROM test_json
WHERE json_type = 'object';
---END---
---START---
SELECT test_json->>2
FROM test_json
WHERE json_type = 'array';
---END---
---START---
SELECT test_json ->> 6 FROM test_json WHERE json_type = 'array';
---END---
---START---
SELECT test_json ->> 7 FROM test_json WHERE json_type = 'array';
---END---
---START---
SELECT test_json ->> 'field4' FROM test_json WHERE json_type = 'object';
---END---
---START---
SELECT test_json ->> 'field5' FROM test_json WHERE json_type = 'object';
---END---
---START---
SELECT test_json ->> 'field6' FROM test_json WHERE json_type = 'object';
---END---
---START---
SELECT json_object_keys(test_json)
FROM test_json
WHERE json_type = 'scalar';
---END---
---START---
SELECT json_object_keys(test_json)
FROM test_json
WHERE json_type = 'array';
---END---
---START---
SELECT json_object_keys(test_json)
FROM test_json
WHERE json_type = 'object';
---END---
---START---
-- test extending object_keys resultset - initial resultset size is 256

select count(*) from
    (select json_object_keys(json_object(array_agg(g)))
     from (select unnest(array['f'||n,n::text])as g
           from generate_series(1,300) as n) x ) y;
---END---
---START---
-- nulls

select (test_json->'field3') is null as expect_false
from test_json
where json_type = 'object';
---END---
---START---
select (test_json->>'field3') is null as expect_true
from test_json
where json_type = 'object';
---END---
---START---
select (test_json->3) is null as expect_false
from test_json
where json_type = 'array';
---END---
---START---
select (test_json->>3) is null as expect_true
from test_json
where json_type = 'array';
---END---
---START---
-- corner cases

select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json -> null::text;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json -> null::int;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json -> 1;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json -> -1;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json -> 'z';
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json -> '';
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json -> 1;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json -> 3;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json -> 'z';
---END---
---START---
select '{"a": "c", "b": null}'::json -> 'b';
---END---
---START---
select '"foo"'::json -> 1;
---END---
---START---
select '"foo"'::json -> 'z';
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json ->> null::text;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json ->> null::int;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json ->> 1;
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json ->> 'z';
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json ->> '';
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json ->> 1;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json ->> 3;
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json ->> 'z';
---END---
---START---
select '{"a": "c", "b": null}'::json ->> 'b';
---END---
---START---
select '"foo"'::json ->> 1;
---END---
---START---
select '"foo"'::json ->> 'z';
---END---
---START---
-- array length

SELECT json_array_length('[1,2,3,{"f1":1,"f2":[5,6]},4]');
---END---
---START---
SELECT json_array_length('[]');
---END---
---START---
SELECT json_array_length('{"f1":1,"f2":[5,6]}');
---END---
---START---
SELECT json_array_length('4');
---END---
---START---
-- each

select json_each('{"f1":[1,2,3],"f2":{"f3":1},"f4":null}');
---END---
---START---
select * from json_each('{"f1":[1,2,3],"f2":{"f3":1},"f4":null,"f5":99,"f6":"stringy"}') q;
---END---
---START---
select json_each_text('{"f1":[1,2,3],"f2":{"f3":1},"f4":null,"f5":"null"}');
---END---
---START---
select * from json_each_text('{"f1":[1,2,3],"f2":{"f3":1},"f4":null,"f5":99,"f6":"stringy"}') q;
---END---
---START---
-- extract_path, extract_path_as_text

select json_extract_path('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f4','f6');
---END---
---START---
select json_extract_path('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f2');
---END---
---START---
select json_extract_path('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',0::text);
---END---
---START---
select json_extract_path('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',1::text);
---END---
---START---
select json_extract_path_text('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f4','f6');
---END---
---START---
select json_extract_path_text('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f2');
---END---
---START---
select json_extract_path_text('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',0::text);
---END---
---START---
select json_extract_path_text('{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}','f2',1::text);
---END---
---START---
-- extract_path nulls

select json_extract_path('{"f2":{"f3":1},"f4":{"f5":null,"f6":"stringy"}}','f4','f5') is null as expect_false;
---END---
---START---
select json_extract_path_text('{"f2":{"f3":1},"f4":{"f5":null,"f6":"stringy"}}','f4','f5') is null as expect_true;
---END---
---START---
select json_extract_path('{"f2":{"f3":1},"f4":[0,1,2,null]}','f4','3') is null as expect_false;
---END---
---START---
select json_extract_path_text('{"f2":{"f3":1},"f4":[0,1,2,null]}','f4','3') is null as expect_true;
---END---
---START---
-- extract_path operators

select '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::json#>array['f4','f6'];
---END---
---START---
select '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::json#>array['f2'];
---END---
---START---
select '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::json#>array['f2','0'];
---END---
---START---
select '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::json#>array['f2','1'];
---END---
---START---
select '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::json#>>array['f4','f6'];
---END---
---START---
select '{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}'::json#>>array['f2'];
---END---
---START---
select '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::json#>>array['f2','0'];
---END---
---START---
select '{"f2":["f3",1],"f4":{"f5":99,"f6":"stringy"}}'::json#>>array['f2','1'];
---END---
---START---
-- corner cases for same
select '{"a": {"b":{"c": "foo"}}}'::json #> '{}';
---END---
---START---
select '[1,2,3]'::json #> '{}';
---END---
---START---
select '"foo"'::json #> '{}';
---END---
---START---
select '42'::json #> '{}';
---END---
---START---
select 'null'::json #> '{}';
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a', null];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a', ''];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a','b'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a','b','c'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a','b','c','d'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #> array['a','z','c'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json #> array['a','1','b'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json #> array['a','z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json #> array['1','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json #> array['z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": null}]'::json #> array['1','b'];
---END---
---START---
select '"foo"'::json #> array['z'];
---END---
---START---
select '42'::json #> array['f2'];
---END---
---START---
select '42'::json #> array['0'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> '{}';
---END---
---START---
select '[1,2,3]'::json #>> '{}';
---END---
---START---
select '"foo"'::json #>> '{}';
---END---
---START---
select '42'::json #>> '{}';
---END---
---START---
select 'null'::json #>> '{}';
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a', null];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a', ''];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a','b'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a','b','c'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a','b','c','d'];
---END---
---START---
select '{"a": {"b":{"c": "foo"}}}'::json #>> array['a','z','c'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json #>> array['a','1','b'];
---END---
---START---
select '{"a": [{"b": "c"}, {"b": "cc"}]}'::json #>> array['a','z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json #>> array['1','b'];
---END---
---START---
select '[{"b": "c"}, {"b": "cc"}]'::json #>> array['z','b'];
---END---
---START---
select '[{"b": "c"}, {"b": null}]'::json #>> array['1','b'];
---END---
---START---
select '"foo"'::json #>> array['z'];
---END---
---START---
select '42'::json #>> array['f2'];
---END---
---START---
select '42'::json #>> array['0'];
---END---
---START---
-- array_elements

select json_array_elements('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false,"stringy"]');
---END---
---START---
select * from json_array_elements('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false,"stringy"]') q;
---END---
---START---
select json_array_elements_text('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false,"stringy"]');
---END---
---START---
select * from json_array_elements_text('[1,true,[1,[2,3]],null,{"f1":1,"f2":[7,8,9]},false,"stringy"]') q;
---END---
---START---
-- populate_record
create type jpop as (a text, b int, c timestamp);
---END---
---START---
CREATE DOMAIN js_int_not_null  AS int     NOT NULL;
---END---
---START---
CREATE DOMAIN js_int_array_1d  AS int[]   CHECK(array_length(VALUE, 1) = 3);
---END---
---START---
CREATE DOMAIN js_int_array_2d  AS int[][] CHECK(array_length(VALUE, 2) = 3);
---END---
---START---
create type j_unordered_pair as (x int, y int);
---END---
---START---
create domain j_ordered_pair as j_unordered_pair check((value).x <= (value).y);
---END---
---START---
CREATE TYPE jsrec AS (
	i	int,
	ia	_int4,
	ia1	int[],
	ia2	int[][],
	ia3	int[][][],
	ia1d	js_int_array_1d,
	ia2d	js_int_array_2d,
	t	text,
	ta	text[],
	c	char(10),
	ca	char(10)[],
	ts	timestamp,
	js	json,
	jsb	jsonb,
	jsa	json[],
	rec	jpop,
	reca	jpop[]
);
---END---
---START---
CREATE TYPE jsrec_i_not_null AS (
	i	js_int_not_null
);
---END---
---START---
select * from json_populate_record(null::jpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---
select * from json_populate_record(row('x',3,'2012-12-31 15:30:56')::jpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---
select * from json_populate_record(null::jpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---
select * from json_populate_record(row('x',3,'2012-12-31 15:30:56')::jpop,'{"a":"blurfl","x":43.2}') q;
---END---
---START---
select * from json_populate_record(null::jpop,'{"a":[100,200,false],"x":43.2}') q;
---END---
---START---
select * from json_populate_record(row('x',3,'2012-12-31 15:30:56')::jpop,'{"a":[100,200,false],"x":43.2}') q;
---END---
---START---
select * from json_populate_record(row('x',3,'2012-12-31 15:30:56')::jpop,'{"c":[100,200,false],"x":43.2}') q;
---END---
---START---
select * from json_populate_record(row('x',3,'2012-12-31 15:30:56')::jpop,'{}') q;
---END---
---START---
SELECT i FROM json_populate_record(NULL::jsrec_i_not_null, '{"x": 43.2}') q;
---END---
---START---
SELECT i FROM json_populate_record(NULL::jsrec_i_not_null, '{"i": null}') q;
---END---
---START---
SELECT i FROM json_populate_record(NULL::jsrec_i_not_null, '{"i": 12345}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": null}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": 123}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": [[1, 2], [3, 4]]}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": [[1], 2]}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": [[1], [2, 3]]}') q;
---END---
---START---
SELECT ia FROM json_populate_record(NULL::jsrec, '{"ia": "{1,2,3}"}') q;
---END---
---START---
SELECT ia1 FROM json_populate_record(NULL::jsrec, '{"ia1": null}') q;
---END---
---START---
SELECT ia1 FROM json_populate_record(NULL::jsrec, '{"ia1": 123}') q;
---END---
---START---
SELECT ia1 FROM json_populate_record(NULL::jsrec, '{"ia1": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia1 FROM json_populate_record(NULL::jsrec, '{"ia1": [[1, 2, 3]]}') q;
---END---
---START---
SELECT ia1d FROM json_populate_record(NULL::jsrec, '{"ia1d": null}') q;
---END---
---START---
SELECT ia1d FROM json_populate_record(NULL::jsrec, '{"ia1d": 123}') q;
---END---
---START---
SELECT ia1d FROM json_populate_record(NULL::jsrec, '{"ia1d": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia1d FROM json_populate_record(NULL::jsrec, '{"ia1d": [1, "2", null]}') q;
---END---
---START---
SELECT ia2 FROM json_populate_record(NULL::jsrec, '{"ia2": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia2 FROM json_populate_record(NULL::jsrec, '{"ia2": [[1, 2], [null, 4]]}') q;
---END---
---START---
SELECT ia2 FROM json_populate_record(NULL::jsrec, '{"ia2": [[], []]}') q;
---END---
---START---
SELECT ia2 FROM json_populate_record(NULL::jsrec, '{"ia2": [[1, 2], [3]]}') q;
---END---
---START---
SELECT ia2 FROM json_populate_record(NULL::jsrec, '{"ia2": [[1, 2], 3, 4]}') q;
---END---
---START---
SELECT ia2d FROM json_populate_record(NULL::jsrec, '{"ia2d": [[1, "2"], [null, 4]]}') q;
---END---
---START---
SELECT ia2d FROM json_populate_record(NULL::jsrec, '{"ia2d": [[1, "2", 3], [null, 5, 6]]}') q;
---END---
---START---
SELECT ia3 FROM json_populate_record(NULL::jsrec, '{"ia3": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ia3 FROM json_populate_record(NULL::jsrec, '{"ia3": [[1, 2], [null, 4]]}') q;
---END---
---START---
SELECT ia3 FROM json_populate_record(NULL::jsrec, '{"ia3": [ [[], []], [[], []], [[], []] ]}') q;
---END---
---START---
SELECT ia3 FROM json_populate_record(NULL::jsrec, '{"ia3": [ [[1, 2]], [[3, 4]] ]}') q;
---END---
---START---
SELECT ia3 FROM json_populate_record(NULL::jsrec, '{"ia3": [ [[1, 2], [3, 4]], [[5, 6], [7, 8]] ]}') q;
---END---
---START---
SELECT ia3 FROM json_populate_record(NULL::jsrec, '{"ia3": [ [[1, 2], [3, 4]], [[5, 6], [7, 8], [9, 10]] ]}') q;
---END---
---START---
SELECT ta FROM json_populate_record(NULL::jsrec, '{"ta": null}') q;
---END---
---START---
SELECT ta FROM json_populate_record(NULL::jsrec, '{"ta": 123}') q;
---END---
---START---
SELECT ta FROM json_populate_record(NULL::jsrec, '{"ta": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ta FROM json_populate_record(NULL::jsrec, '{"ta": [[1, 2, 3], {"k": "v"}]}') q;
---END---
---START---
SELECT c FROM json_populate_record(NULL::jsrec, '{"c": null}') q;
---END---
---START---
SELECT c FROM json_populate_record(NULL::jsrec, '{"c": "aaa"}') q;
---END---
---START---
SELECT c FROM json_populate_record(NULL::jsrec, '{"c": "aaaaaaaaaa"}') q;
---END---
---START---
SELECT c FROM json_populate_record(NULL::jsrec, '{"c": "aaaaaaaaaaaaa"}') q;
---END---
---START---
SELECT ca FROM json_populate_record(NULL::jsrec, '{"ca": null}') q;
---END---
---START---
SELECT ca FROM json_populate_record(NULL::jsrec, '{"ca": 123}') q;
---END---
---START---
SELECT ca FROM json_populate_record(NULL::jsrec, '{"ca": [1, "2", null, 4]}') q;
---END---
---START---
SELECT ca FROM json_populate_record(NULL::jsrec, '{"ca": ["aaaaaaaaaaaaaaaa"]}') q;
---END---
---START---
SELECT ca FROM json_populate_record(NULL::jsrec, '{"ca": [[1, 2, 3], {"k": "v"}]}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": null}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": true}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": 123.45}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": "123.45"}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": "abc"}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": [123, "123", null, {"key": "value"}]}') q;
---END---
---START---
SELECT js FROM json_populate_record(NULL::jsrec, '{"js": {"a": "bbb", "b": null, "c": 123.45}}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": null}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": true}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": 123.45}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": "123.45"}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": "abc"}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": [123, "123", null, {"key": "value"}]}') q;
---END---
---START---
SELECT jsb FROM json_populate_record(NULL::jsrec, '{"jsb": {"a": "bbb", "b": null, "c": 123.45}}') q;
---END---
---START---
SELECT jsa FROM json_populate_record(NULL::jsrec, '{"jsa": null}') q;
---END---
---START---
SELECT jsa FROM json_populate_record(NULL::jsrec, '{"jsa": 123}') q;
---END---
---START---
SELECT jsa FROM json_populate_record(NULL::jsrec, '{"jsa": [1, "2", null, 4]}') q;
---END---
---START---
SELECT jsa FROM json_populate_record(NULL::jsrec, '{"jsa": ["aaa", null, [1, 2, "3", {}], { "k" : "v" }]}') q;
---END---
---START---
SELECT rec FROM json_populate_record(NULL::jsrec, '{"rec": 123}') q;
---END---
---START---
SELECT rec FROM json_populate_record(NULL::jsrec, '{"rec": [1, 2]}') q;
---END---
---START---
SELECT rec FROM json_populate_record(NULL::jsrec, '{"rec": {"a": "abc", "c": "01.02.2003", "x": 43.2}}') q;
---END---
---START---
SELECT rec FROM json_populate_record(NULL::jsrec, '{"rec": "(abc,42,01.02.2003)"}') q;
---END---
---START---
SELECT reca FROM json_populate_record(NULL::jsrec, '{"reca": 123}') q;
---END---
---START---
SELECT reca FROM json_populate_record(NULL::jsrec, '{"reca": [1, 2]}') q;
---END---
---START---
SELECT reca FROM json_populate_record(NULL::jsrec, '{"reca": [{"a": "abc", "b": 456}, null, {"c": "01.02.2003", "x": 43.2}]}') q;
---END---
---START---
SELECT reca FROM json_populate_record(NULL::jsrec, '{"reca": ["(abc,42,01.02.2003)"]}') q;
---END---
---START---
SELECT reca FROM json_populate_record(NULL::jsrec, '{"reca": "{\"(abc,42,01.02.2003)\"}"}') q;
---END---
---START---
SELECT rec FROM json_populate_record(
	row(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		row('x',3,'2012-12-31 15:30:56')::jpop,NULL)::jsrec,
	'{"rec": {"a": "abc", "c": "01.02.2003", "x": 43.2}}'
) q;
---END---
---START---
-- anonymous record type
SELECT json_populate_record(null::record, '{"x": 0, "y": 1}');
---END---
---START---
SELECT json_populate_record(row(1,2), '{"f1": 0, "f2": 1}');
---END---
---START---
SELECT * FROM
  json_populate_record(null::record, '{"x": 776}') AS (x int, y int);
---END---
---START---
-- composite domain
SELECT json_populate_record(null::j_ordered_pair, '{"x": 0, "y": 1}');
---END---
---START---
SELECT json_populate_record(row(1,2)::j_ordered_pair, '{"x": 0}');
---END---
---START---
SELECT json_populate_record(row(1,2)::j_ordered_pair, '{"x": 1, "y": 0}');
---END---
---START---
-- populate_recordset

select * from json_populate_recordset(null::jpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(row('def',99,null)::jpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(null::jpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(row('def',99,null)::jpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(row('def',99,null)::jpop,'[{"a":[100,200,300],"x":43.2},{"a":{"z":true},"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(row('def',99,null)::jpop,'[{"c":[100,200,300],"x":43.2},{"a":{"z":true},"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
create type jpop2 as (a int, b json, c int, d int);
---END---
---START---
select * from json_populate_recordset(null::jpop2, '[{"a":2,"c":3,"b":{"z":4},"d":6}]') q;
---END---
---START---
select * from json_populate_recordset(null::jpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(row('def',99,null)::jpop,'[{"a":"blurfl","x":43.2},{"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
select * from json_populate_recordset(row('def',99,null)::jpop,'[{"a":[100,200,300],"x":43.2},{"a":{"z":true},"b":3,"c":"2012-01-20 10:42:53"}]') q;
---END---
---START---
-- anonymous record type
SELECT json_populate_recordset(null::record, '[{"x": 0, "y": 1}]');
---END---
---START---
SELECT json_populate_recordset(row(1,2), '[{"f1": 0, "f2": 1}]');
---END---
---START---
SELECT i, json_populate_recordset(row(i,50), '[{"f1":"42"},{"f2":"43"}]')
FROM (VALUES (1),(2)) v(i);
---END---
---START---
SELECT * FROM
  json_populate_recordset(null::record, '[{"x": 776}]') AS (x int, y int);
---END---
---START---
-- empty array is a corner case
SELECT json_populate_recordset(null::record, '[]');
---END---
---START---
SELECT json_populate_recordset(row(1,2), '[]');
---END---
---START---
SELECT * FROM json_populate_recordset(NULL::jpop,'[]') q;
---END---
---START---
SELECT * FROM
  json_populate_recordset(null::record, '[]') AS (x int, y int);
---END---
---START---
-- composite domain
SELECT json_populate_recordset(null::j_ordered_pair, '[{"x": 0, "y": 1}]');
---END---
---START---
SELECT json_populate_recordset(row(1,2)::j_ordered_pair, '[{"x": 0}, {"y": 3}]');
---END---
---START---
SELECT json_populate_recordset(row(1,2)::j_ordered_pair, '[{"x": 1, "y": 0}]');
---END---
---START---
-- negative cases where the wrong record type is supplied
select * from json_populate_recordset(row(0::int),'[{"a":"1","b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
select * from json_populate_recordset(row(0::int,0::int),'[{"a":"1","b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
select * from json_populate_recordset(row(0::int,0::int,0::int),'[{"a":"1","b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
select * from json_populate_recordset(row(1000000000::int,50::int),'[{"b":"2"},{"a":"3"}]') q (a text, b text);
---END---
---START---
-- test type info caching in json_populate_record()
DROP TABLE IF EXISTS jspoptest;

CREATE TABLE jspoptest (gemini_pk serial PRIMARY KEY, js pg_catalog.json);
---END---
---START---
INSERT INTO jspoptest
SELECT '{
	"jsa": [1, "2", null, 4],
	"rec": {"a": "abc", "c": "01.02.2003", "x": 43.2},
	"reca": [{"a": "abc", "b": 456}, null, {"c": "01.02.2003", "x": 43.2}]
}'::json
FROM generate_series(1, 3);
---END---
---START---
SELECT (json_populate_record(NULL::jsrec, js)).* FROM jspoptest;
---END---
---START---
DROP TYPE jsrec;
---END---
---START---
DROP TYPE jsrec_i_not_null;
---END---
---START---
DROP DOMAIN js_int_not_null;
---END---
---START---
DROP DOMAIN js_int_array_1d;
---END---
---START---
DROP DOMAIN js_int_array_2d;
---END---
---START---
DROP DOMAIN j_ordered_pair;
---END---
---START---
DROP TYPE j_unordered_pair;
---END---
---START---
--json_typeof() function
select value, json_typeof(value)
  from (values (json '123.4'),
               (json '-1'),
               (json '"foo"'),
               (json 'true'),
               (json 'false'),
               (json 'null'),
               (json '[1, 2, 3]'),
               (json '[]'),
               (json '{"x":"foo", "y":123}'),
               (json '{}'),
               (NULL::json))
      as data(value);
---END---
---START---
-- json_build_array, json_build_object, json_object_agg

SELECT json_build_array('a',1,'b',1.2,'c',true,'d',null,'e',json '{"x": 3, "y": [1,2,3]}');
---END---
---START---
SELECT json_build_array('a', NULL);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC NULL::text[]);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC '{}'::text[]);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC '{a,b,c}'::text[]);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC ARRAY['a', NULL]::text[]);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC '{1,2,3,4}'::text[]);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC '{1,2,3,4}'::int[]);
---END---
---START---
-- ok
SELECT json_build_array(VARIADIC '{{1,4},{2,5},{3,6}}'::int[][]);
---END---
---START---
-- ok

SELECT json_build_object('a',1,'b',1.2,'c',true,'d',null,'e',json '{"x": 3, "y": [1,2,3]}');
---END---
---START---
SELECT json_build_object(
       'a', json_build_object('b',false,'c',99),
       'd', json_build_object('e',array[9,8,7]::int[],
           'f', (select row_to_json(r) from ( select relkind, oid::regclass as name from pg_class where relname = 'pg_class') r)));
---END---
---START---
SELECT json_build_object('{a,b,c}'::text[]);
---END---
---START---
-- error
SELECT json_build_object('{a,b,c}'::text[], '{d,e,f}'::text[]);
---END---
---START---
-- error, key cannot be array
SELECT json_build_object('a', 'b', 'c');
---END---
---START---
-- error
SELECT json_build_object(NULL, 'a');
---END---
---START---
-- error, key cannot be NULL
SELECT json_build_object('a', NULL);
---END---
---START---
-- ok
SELECT json_build_object(VARIADIC NULL::text[]);
---END---
---START---
-- ok
SELECT json_build_object(VARIADIC '{}'::text[]);
---END---
---START---
-- ok
SELECT json_build_object(VARIADIC '{a,b,c}'::text[]);
---END---
---START---
-- error
SELECT json_build_object(VARIADIC ARRAY['a', NULL]::text[]);
---END---
---START---
-- ok
SELECT json_build_object(VARIADIC ARRAY[NULL, 'a']::text[]);
---END---
---START---
-- error, key cannot be NULL
SELECT json_build_object(VARIADIC '{1,2,3,4}'::text[]);
---END---
---START---
-- ok
SELECT json_build_object(VARIADIC '{1,2,3,4}'::int[]);
---END---
---START---
-- ok
SELECT json_build_object(VARIADIC '{{1,4},{2,5},{3,6}}'::int[][]);
---END---
---START---
-- ok

-- empty objects/arrays
SELECT json_build_array();
---END---
---START---
SELECT json_build_object();
---END---
---START---
-- make sure keys are quoted
SELECT json_build_object(1,2);
---END---
---START---
-- keys must be scalar and not null
SELECT json_build_object(null,2);
---END---
---START---
SELECT json_build_object(r,2) FROM (SELECT 1 AS a, 2 AS b) r;
---END---
---START---
SELECT json_build_object(json '{"a":1,"b":2}', 3);
---END---
---START---
SELECT json_build_object('{1,2,3}'::int[], 3);
---END---
---START---
DROP TABLE IF EXISTS foo;

CREATE TABLE foo (gemini_pk serial PRIMARY KEY, serial_num integer, name text, type text);
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
SELECT json_build_object('turbines',json_object_agg(serial_num,json_build_object('name',name,'type',type)))
FROM foo;
---END---
---START---
SELECT json_object_agg(name, type) FROM foo;
---END---
---START---
INSERT INTO foo VALUES (999999, NULL, 'bar');
---END---
---START---
SELECT json_object_agg(name, type) FROM foo;
---END---
---START---
-- json_object

-- empty object, one dimension
SELECT json_object('{}');
---END---
---START---
-- empty object, two dimensions
SELECT json_object('{}', '{}');
---END---
---START---
-- one dimension
SELECT json_object('{a,1,b,2,3,NULL,"d e f","a b c"}');
---END---
---START---
-- same but with two dimensions
SELECT json_object('{{a,1},{b,2},{3,NULL},{"d e f","a b c"}}');
---END---
---START---
-- odd number error
SELECT json_object('{a,b,c}');
---END---
---START---
-- one column error
SELECT json_object('{{a},{b}}');
---END---
---START---
-- too many columns error
SELECT json_object('{{a,b,c},{b,c,d}}');
---END---
---START---
-- too many dimensions error
SELECT json_object('{{{a,b},{c,d}},{{b,c},{d,e}}}');
---END---
---START---
--two argument form of json_object

select json_object('{a,b,c,"d e f"}','{1,2,3,"a b c"}');
---END---
---START---
-- too many dimensions
SELECT json_object('{{a,1},{b,2},{3,NULL},{"d e f","a b c"}}', '{{a,1},{b,2},{3,NULL},{"d e f","a b c"}}');
---END---
---START---
-- mismatched dimensions

select json_object('{a,b,c,"d e f",g}','{1,2,3,"a b c"}');
---END---
---START---
select json_object('{a,b,c,"d e f"}','{1,2,3,"a b c",g}');
---END---
---START---
-- null key error

select json_object('{a,b,NULL,"d e f"}','{1,2,3,"a b c"}');
---END---
---START---
-- empty key is allowed

select json_object('{a,b,"","d e f"}','{1,2,3,"a b c"}');
---END---
---START---
-- json_to_record and json_to_recordset

select * from json_to_record('{"a":1,"b":"foo","c":"bar"}')
    as x(a int, b text, d text);
---END---
---START---
select * from json_to_recordset('[{"a":1,"b":"foo","d":false},{"a":2,"b":"bar","c":true}]')
    as x(a int, b text, c boolean);
---END---
---START---
select * from json_to_recordset('[{"a":1,"b":{"d":"foo"},"c":true},{"a":2,"c":false,"b":{"d":"bar"}}]')
    as x(a int, b json, c boolean);
---END---
---START---
select *, c is null as c_is_null
from json_to_record('{"a":1, "b":{"c":16, "d":2}, "x":8, "ca": ["1 2", 3], "ia": [[1,2],[3,4]], "r": {"a": "aaa", "b": 123}}'::json)
    as t(a int, b json, c text, x int, ca char(5)[], ia int[][], r jpop);
---END---
---START---
select *, c is null as c_is_null
from json_to_recordset('[{"a":1, "b":{"c":16, "d":2}, "x":8}]'::json)
    as t(a int, b json, c text, x int);
---END---
---START---
select * from json_to_record('{"ia": null}') as x(ia _int4);
---END---
---START---
select * from json_to_record('{"ia": 123}') as x(ia _int4);
---END---
---START---
select * from json_to_record('{"ia": [1, "2", null, 4]}') as x(ia _int4);
---END---
---START---
select * from json_to_record('{"ia": [[1, 2], [3, 4]]}') as x(ia _int4);
---END---
---START---
select * from json_to_record('{"ia": [[1], 2]}') as x(ia _int4);
---END---
---START---
select * from json_to_record('{"ia": [[1], [2, 3]]}') as x(ia _int4);
---END---
---START---
select * from json_to_record('{"ia2": [1, 2, 3]}') as x(ia2 int[][]);
---END---
---START---
select * from json_to_record('{"ia2": [[1, 2], [3, 4]]}') as x(ia2 int4[][]);
---END---
---START---
select * from json_to_record('{"ia2": [[[1], [2], [3]]]}') as x(ia2 int4[][]);
---END---
---START---
select * from json_to_record('{"out": {"key": 1}}') as x(out json);
---END---
---START---
select * from json_to_record('{"out": [{"key": 1}]}') as x(out json);
---END---
---START---
select * from json_to_record('{"out": "{\"key\": 1}"}') as x(out json);
---END---
---START---
select * from json_to_record('{"out": {"key": 1}}') as x(out jsonb);
---END---
---START---
select * from json_to_record('{"out": [{"key": 1}]}') as x(out jsonb);
---END---
---START---
select * from json_to_record('{"out": "{\"key\": 1}"}') as x(out jsonb);
---END---
---START---
-- json_strip_nulls

select json_strip_nulls(null);
---END---
---START---
select json_strip_nulls('1');
---END---
---START---
select json_strip_nulls('"a string"');
---END---
---START---
select json_strip_nulls('null');
---END---
---START---
select json_strip_nulls('[1,2,null,3,4]');
---END---
---START---
select json_strip_nulls('{"a":1,"b":null,"c":[2,null,3],"d":{"e":4,"f":null}}');
---END---
---START---
select json_strip_nulls('[1,{"a":1,"b":null,"c":2},3]');
---END---
---START---
-- an empty object is not null and should not be stripped
select json_strip_nulls('{"a": {"b": null, "c": null}, "d": {} }');
---END---
---START---
-- json to tsvector
select to_tsvector('{"a": "aaa bbb ddd ccc", "b": ["eee fff ggg"], "c": {"d": "hhh iii"}}'::json);
---END---
---START---
-- json to tsvector with config
select to_tsvector('simple', '{"a": "aaa bbb ddd ccc", "b": ["eee fff ggg"], "c": {"d": "hhh iii"}}'::json);
---END---
---START---
-- json to tsvector with stop words
select to_tsvector('english', '{"a": "aaa in bbb ddd ccc", "b": ["the eee fff ggg"], "c": {"d": "hhh. iii"}}'::json);
---END---
---START---
-- json to tsvector with numeric values
select to_tsvector('english', '{"a": "aaa in bbb ddd ccc", "b": 123, "c": 456}'::json);
---END---
---START---
-- json_to_tsvector
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"all"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"key"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"string"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"numeric"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"boolean"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '["string", "numeric"]');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"all"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"key"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"string"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"numeric"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '"boolean"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '["string", "numeric"]');
---END---
---START---
-- to_tsvector corner cases
select to_tsvector('""'::json);
---END---
---START---
select to_tsvector('{}'::json);
---END---
---START---
select to_tsvector('[]'::json);
---END---
---START---
select to_tsvector('null'::json);
---END---
---START---
-- json_to_tsvector corner cases
select json_to_tsvector('""'::json, '"all"');
---END---
---START---
select json_to_tsvector('{}'::json, '"all"');
---END---
---START---
select json_to_tsvector('[]'::json, '"all"');
---END---
---START---
select json_to_tsvector('null'::json, '"all"');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '""');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '{}');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '[]');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, 'null');
---END---
---START---
select json_to_tsvector('english', '{"a": "aaa in bbb", "b": 123, "c": 456, "d": true, "f": false, "g": null}'::json, '["all", null]');
---END---
---START---
-- ts_headline for json
select ts_headline('{"a": "aaa bbb", "b": {"c": "ccc ddd fff", "c1": "ccc1 ddd1"}, "d": ["ggg hhh", "iii jjj"]}'::json, tsquery('bbb & ddd & hhh'));
---END---
---START---
select ts_headline('english', '{"a": "aaa bbb", "b": {"c": "ccc ddd fff"}, "d": ["ggg hhh", "iii jjj"]}'::json, tsquery('bbb & ddd & hhh'));
---END---
---START---
select ts_headline('{"a": "aaa bbb", "b": {"c": "ccc ddd fff", "c1": "ccc1 ddd1"}, "d": ["ggg hhh", "iii jjj"]}'::json, tsquery('bbb & ddd & hhh'), 'StartSel = <, StopSel = >');
---END---
---START---
select ts_headline('english', '{"a": "aaa bbb", "b": {"c": "ccc ddd fff", "c1": "ccc1 ddd1"}, "d": ["ggg hhh", "iii jjj"]}'::json, tsquery('bbb & ddd & hhh'), 'StartSel = <, StopSel = >');
---END---
---START---
-- corner cases for ts_headline with json
select ts_headline('null'::json, tsquery('aaa & bbb'));
---END---
---START---
select ts_headline('{}'::json, tsquery('aaa & bbb'));
---END---
---START---
select ts_headline('[]'::json, tsquery('aaa & bbb'));
---END---
