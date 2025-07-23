---START---
-- JSON_OBJECT()
SELECT JSON_OBJECT();
---END---
---START---
SELECT JSON_OBJECT(RETURNING json);
---END---
---START---
SELECT JSON_OBJECT(RETURNING json FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT(RETURNING jsonb);
---END---
---START---
SELECT JSON_OBJECT(RETURNING jsonb FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT(RETURNING text);
---END---
---START---
SELECT JSON_OBJECT(RETURNING text FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT(RETURNING text FORMAT JSON ENCODING UTF8);
---END---
---START---
SELECT JSON_OBJECT(RETURNING text FORMAT JSON ENCODING INVALID_ENCODING);
---END---
---START---
SELECT JSON_OBJECT(RETURNING bytea);
---END---
---START---
SELECT JSON_OBJECT(RETURNING bytea FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT(RETURNING bytea FORMAT JSON ENCODING UTF8);
---END---
---START---
SELECT JSON_OBJECT(RETURNING bytea FORMAT JSON ENCODING UTF16);
---END---
---START---
SELECT JSON_OBJECT(RETURNING bytea FORMAT JSON ENCODING UTF32);
---END---
---START---

SELECT JSON_OBJECT('foo': NULL::int FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT('foo': NULL::int FORMAT JSON ENCODING UTF8);
---END---
---START---
SELECT JSON_OBJECT('foo': NULL::json FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT('foo': NULL::json FORMAT JSON ENCODING UTF8);
---END---
---START---
SELECT JSON_OBJECT('foo': NULL::jsonb FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT('foo': NULL::jsonb FORMAT JSON ENCODING UTF8);
---END---
---START---

SELECT JSON_OBJECT(NULL: 1);
---END---
---START---
SELECT JSON_OBJECT('a': 2 + 3);
---END---
---START---
SELECT JSON_OBJECT('a' VALUE 2 + 3);
---END---
---START---
--SELECT JSON_OBJECT(KEY 'a' VALUE 2 + 3);
---END---
---START---
SELECT JSON_OBJECT('a' || 2: 1);
---END---
---START---
SELECT JSON_OBJECT(('a' || 2) VALUE 1);
---END---
---START---
--SELECT JSON_OBJECT('a' || 2 VALUE 1);
---END---
---START---
--SELECT JSON_OBJECT(KEY 'a' || 2 VALUE 1);
---END---
---START---
SELECT JSON_OBJECT('a': 2::text);
---END---
---START---
SELECT JSON_OBJECT('a' VALUE 2::text);
---END---
---START---
--SELECT JSON_OBJECT(KEY 'a' VALUE 2::text);
---END---
---START---
SELECT JSON_OBJECT(1::text: 2);
---END---
---START---
SELECT JSON_OBJECT((1::text) VALUE 2);
---END---
---START---
--SELECT JSON_OBJECT(1::text VALUE 2);
---END---
---START---
--SELECT JSON_OBJECT(KEY 1::text VALUE 2);
---END---
---START---
SELECT JSON_OBJECT(json '[1]': 123);
---END---
---START---
SELECT JSON_OBJECT(ARRAY[1,2,3]: 'aaa');
---END---
---START---

SELECT JSON_OBJECT(
	'a': '123',
	1.23: 123,
	'c': json '[ 1,true,{ } ]',
	'd': jsonb '{ "x" : 123.45 }'
);
---END---
---START---

SELECT JSON_OBJECT(
	'a': '123',
	1.23: 123,
	'c': json '[ 1,true,{ } ]',
	'd': jsonb '{ "x" : 123.45 }'
	RETURNING jsonb
);
---END---
---START---

/*
SELECT JSON_OBJECT(
	'a': '123',
	KEY 1.23 VALUE 123,
	'c' VALUE json '[1, true, {}]'
);
---END---
---START---
*/

SELECT JSON_OBJECT('a': '123', 'b': JSON_OBJECT('a': 111, 'b': 'aaa'));
---END---
---START---
SELECT JSON_OBJECT('a': '123', 'b': JSON_OBJECT('a': 111, 'b': 'aaa' RETURNING jsonb));
---END---
---START---

SELECT JSON_OBJECT('a': JSON_OBJECT('b': 1 RETURNING text));
---END---
---START---
SELECT JSON_OBJECT('a': JSON_OBJECT('b': 1 RETURNING text) FORMAT JSON);
---END---
---START---
SELECT JSON_OBJECT('a': JSON_OBJECT('b': 1 RETURNING bytea));
---END---
---START---
SELECT JSON_OBJECT('a': JSON_OBJECT('b': 1 RETURNING bytea) FORMAT JSON);
---END---
---START---

SELECT JSON_OBJECT('a': '1', 'b': NULL, 'c': 2);
---END---
---START---
SELECT JSON_OBJECT('a': '1', 'b': NULL, 'c': 2 NULL ON NULL);
---END---
---START---
SELECT JSON_OBJECT('a': '1', 'b': NULL, 'c': 2 ABSENT ON NULL);
---END---
---START---

SELECT JSON_OBJECT(1: 1, '1': NULL WITH UNIQUE);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '1': NULL ABSENT ON NULL WITH UNIQUE);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '1': NULL NULL ON NULL WITH UNIQUE RETURNING jsonb);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '1': NULL ABSENT ON NULL WITH UNIQUE RETURNING jsonb);
---END---
---START---

SELECT JSON_OBJECT(1: 1, '2': NULL, '1': 1 NULL ON NULL WITH UNIQUE);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '2': NULL, '1': 1 ABSENT ON NULL WITH UNIQUE);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '2': NULL, '1': 1 ABSENT ON NULL WITHOUT UNIQUE);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '2': NULL, '1': 1 ABSENT ON NULL WITH UNIQUE RETURNING jsonb);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '2': NULL, '1': 1 ABSENT ON NULL WITHOUT UNIQUE RETURNING jsonb);
---END---
---START---
SELECT JSON_OBJECT(1: 1, '2': NULL, '3': 1, 4: NULL, '5': 'a' ABSENT ON NULL WITH UNIQUE RETURNING jsonb);
---END---
---START---


-- JSON_ARRAY()
SELECT JSON_ARRAY();
---END---
---START---
SELECT JSON_ARRAY(RETURNING json);
---END---
---START---
SELECT JSON_ARRAY(RETURNING json FORMAT JSON);
---END---
---START---
SELECT JSON_ARRAY(RETURNING jsonb);
---END---
---START---
SELECT JSON_ARRAY(RETURNING jsonb FORMAT JSON);
---END---
---START---
SELECT JSON_ARRAY(RETURNING text);
---END---
---START---
SELECT JSON_ARRAY(RETURNING text FORMAT JSON);
---END---
---START---
SELECT JSON_ARRAY(RETURNING text FORMAT JSON ENCODING UTF8);
---END---
---START---
SELECT JSON_ARRAY(RETURNING text FORMAT JSON ENCODING INVALID_ENCODING);
---END---
---START---
SELECT JSON_ARRAY(RETURNING bytea);
---END---
---START---
SELECT JSON_ARRAY(RETURNING bytea FORMAT JSON);
---END---
---START---
SELECT JSON_ARRAY(RETURNING bytea FORMAT JSON ENCODING UTF8);
---END---
---START---
SELECT JSON_ARRAY(RETURNING bytea FORMAT JSON ENCODING UTF16);
---END---
---START---
SELECT JSON_ARRAY(RETURNING bytea FORMAT JSON ENCODING UTF32);
---END---
---START---

SELECT JSON_ARRAY('aaa', 111, true, array[1,2,3], NULL, json '{"a": [1]}', jsonb '["a",3]');
---END---
---START---

SELECT JSON_ARRAY('a',  NULL, 'b' NULL   ON NULL);
---END---
---START---
SELECT JSON_ARRAY('a',  NULL, 'b' ABSENT ON NULL);
---END---
---START---
SELECT JSON_ARRAY(NULL, NULL, 'b' ABSENT ON NULL);
---END---
---START---
SELECT JSON_ARRAY('a',  NULL, 'b' NULL   ON NULL RETURNING jsonb);
---END---
---START---
SELECT JSON_ARRAY('a',  NULL, 'b' ABSENT ON NULL RETURNING jsonb);
---END---
---START---
SELECT JSON_ARRAY(NULL, NULL, 'b' ABSENT ON NULL RETURNING jsonb);
---END---
---START---

SELECT JSON_ARRAY(JSON_ARRAY('{ "a" : 123 }' RETURNING text));
---END---
---START---
SELECT JSON_ARRAY(JSON_ARRAY('{ "a" : 123 }' FORMAT JSON RETURNING text));
---END---
---START---
SELECT JSON_ARRAY(JSON_ARRAY('{ "a" : 123 }' FORMAT JSON RETURNING text) FORMAT JSON);
---END---
---START---

SELECT JSON_ARRAY(SELECT i FROM (VALUES (1), (2), (NULL), (4)) foo(i));
---END---
---START---
SELECT JSON_ARRAY(SELECT i FROM (VALUES (NULL::int[]), ('{1,2}'), (NULL), (NULL), ('{3,4}'), (NULL)) foo(i));
---END---
---START---
SELECT JSON_ARRAY(SELECT i FROM (VALUES (NULL::int[]), ('{1,2}'), (NULL), (NULL), ('{3,4}'), (NULL)) foo(i) RETURNING jsonb);
---END---
---START---
--SELECT JSON_ARRAY(SELECT i FROM (VALUES (NULL::int[]), ('{1,2}'), (NULL), (NULL), ('{3,4}'), (NULL)) foo(i) NULL ON NULL);
---END---
---START---
--SELECT JSON_ARRAY(SELECT i FROM (VALUES (NULL::int[]), ('{1,2}'), (NULL), (NULL), ('{3,4}'), (NULL)) foo(i) NULL ON NULL RETURNING jsonb);
---END---
---START---
SELECT JSON_ARRAY(SELECT i FROM (VALUES (3), (1), (NULL), (2)) foo(i) ORDER BY i);
---END---
---START---
-- Should fail
SELECT JSON_ARRAY(SELECT FROM (VALUES (1)) foo(i));
---END---
---START---
SELECT JSON_ARRAY(SELECT i, i FROM (VALUES (1)) foo(i));
---END---
---START---
SELECT JSON_ARRAY(SELECT * FROM (VALUES (1, 2)) foo(i, j));
---END---
---START---

-- JSON_ARRAYAGG()
SELECT	JSON_ARRAYAGG(i) IS NULL,
		JSON_ARRAYAGG(i RETURNING jsonb) IS NULL
FROM generate_series(1, 0) i;
---END---
---START---

SELECT	JSON_ARRAYAGG(i),
		JSON_ARRAYAGG(i RETURNING jsonb)
FROM generate_series(1, 5) i;
---END---
---START---

SELECT JSON_ARRAYAGG(i ORDER BY i DESC)
FROM generate_series(1, 5) i;
---END---
---START---

SELECT JSON_ARRAYAGG(i::text::json)
FROM generate_series(1, 5) i;
---END---
---START---

SELECT JSON_ARRAYAGG(JSON_ARRAY(i, i + 1 RETURNING text) FORMAT JSON)
FROM generate_series(1, 5) i;
---END---
---START---

SELECT	JSON_ARRAYAGG(NULL),
		JSON_ARRAYAGG(NULL RETURNING jsonb)
FROM generate_series(1, 5);
---END---
---START---

SELECT	JSON_ARRAYAGG(NULL NULL ON NULL),
		JSON_ARRAYAGG(NULL NULL ON NULL RETURNING jsonb)
FROM generate_series(1, 5);
---END---
---START---

\x
SELECT
	JSON_ARRAYAGG(bar) as no_options,
	JSON_ARRAYAGG(bar RETURNING jsonb) as returning_jsonb,
	JSON_ARRAYAGG(bar ABSENT ON NULL) as absent_on_null,
	JSON_ARRAYAGG(bar ABSENT ON NULL RETURNING jsonb) as absentonnull_returning_jsonb,
	JSON_ARRAYAGG(bar NULL ON NULL) as null_on_null,
	JSON_ARRAYAGG(bar NULL ON NULL RETURNING jsonb) as nullonnull_returning_jsonb,
	JSON_ARRAYAGG(foo) as row_no_options,
	JSON_ARRAYAGG(foo RETURNING jsonb) as row_returning_jsonb,
	JSON_ARRAYAGG(foo ORDER BY bar) FILTER (WHERE bar > 2) as row_filtered_agg,
	JSON_ARRAYAGG(foo ORDER BY bar RETURNING jsonb) FILTER (WHERE bar > 2) as row_filtered_agg_returning_jsonb
FROM
	(VALUES (NULL), (3), (1), (NULL), (NULL), (5), (2), (4), (NULL)) foo(bar);
---END---
---START---
\x

SELECT
	bar, JSON_ARRAYAGG(bar) FILTER (WHERE bar > 2) OVER (PARTITION BY foo.bar % 2)
FROM
	(VALUES (NULL), (3), (1), (NULL), (NULL), (5), (2), (4), (NULL), (5), (4)) foo(bar);
---END---
---START---

-- JSON_OBJECTAGG()
SELECT	JSON_OBJECTAGG('key': 1) IS NULL,
		JSON_OBJECTAGG('key': 1 RETURNING jsonb) IS NULL
WHERE FALSE;
---END---
---START---

SELECT JSON_OBJECTAGG(NULL: 1);
---END---
---START---

SELECT JSON_OBJECTAGG(NULL: 1 RETURNING jsonb);
---END---
---START---

SELECT
	JSON_OBJECTAGG(i: i),
--	JSON_OBJECTAGG(i VALUE i),
--	JSON_OBJECTAGG(KEY i VALUE i),
	JSON_OBJECTAGG(i: i RETURNING jsonb)
FROM
	generate_series(1, 5) i;
---END---
---START---

SELECT
	JSON_OBJECTAGG(k: v),
	JSON_OBJECTAGG(k: v NULL ON NULL),
	JSON_OBJECTAGG(k: v ABSENT ON NULL),
	JSON_OBJECTAGG(k: v RETURNING jsonb),
	JSON_OBJECTAGG(k: v NULL ON NULL RETURNING jsonb),
	JSON_OBJECTAGG(k: v ABSENT ON NULL RETURNING jsonb)
FROM
	(VALUES (1, 1), (1, NULL), (2, NULL), (3, 3)) foo(k, v);
---END---
---START---

SELECT JSON_OBJECTAGG(k: v WITH UNIQUE KEYS)
FROM (VALUES (1, 1), (1, NULL), (2, 2)) foo(k, v);
---END---
---START---

SELECT JSON_OBJECTAGG(k: v ABSENT ON NULL WITH UNIQUE KEYS)
FROM (VALUES (1, 1), (1, NULL), (2, 2)) foo(k, v);
---END---
---START---

SELECT JSON_OBJECTAGG(k: v ABSENT ON NULL WITH UNIQUE KEYS)
FROM (VALUES (1, 1), (0, NULL), (3, NULL), (2, 2), (4, NULL)) foo(k, v);
---END---
---START---

SELECT JSON_OBJECTAGG(k: v WITH UNIQUE KEYS RETURNING jsonb)
FROM (VALUES (1, 1), (1, NULL), (2, 2)) foo(k, v);
---END---
---START---

SELECT JSON_OBJECTAGG(k: v ABSENT ON NULL WITH UNIQUE KEYS RETURNING jsonb)
FROM (VALUES (1, 1), (1, NULL), (2, 2)) foo(k, v);
---END---
---START---

-- Test JSON_OBJECT deparsing
EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_OBJECT('foo' : '1' FORMAT JSON, 'bar' : 'baz' RETURNING json);
---END---
---START---

CREATE VIEW json_object_view AS
SELECT JSON_OBJECT('foo' : '1' FORMAT JSON, 'bar' : 'baz' RETURNING json);
---END---
---START---

\sv json_object_view

DROP VIEW json_object_view;
---END---
---START---

-- Test JSON_ARRAY deparsing
EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_ARRAY('1' FORMAT JSON, 2 RETURNING json);
---END---
---START---

CREATE VIEW json_array_view AS
SELECT JSON_ARRAY('1' FORMAT JSON, 2 RETURNING json);
---END---
---START---

\sv json_array_view

DROP VIEW json_array_view;
---END---
---START---

-- Test JSON_OBJECTAGG deparsing
EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_OBJECTAGG(i: ('111' || i)::bytea FORMAT JSON WITH UNIQUE RETURNING text) FILTER (WHERE i > 3)
FROM generate_series(1,5) i;
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_OBJECTAGG(i: ('111' || i)::bytea FORMAT JSON WITH UNIQUE RETURNING text) OVER (PARTITION BY i % 2)
FROM generate_series(1,5) i;
---END---
---START---

CREATE VIEW json_objectagg_view AS
SELECT JSON_OBJECTAGG(i: ('111' || i)::bytea FORMAT JSON WITH UNIQUE RETURNING text) FILTER (WHERE i > 3)
FROM generate_series(1,5) i;
---END---
---START---

\sv json_objectagg_view

DROP VIEW json_objectagg_view;
---END---
---START---

-- Test JSON_ARRAYAGG deparsing
EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_ARRAYAGG(('111' || i)::bytea FORMAT JSON NULL ON NULL RETURNING text) FILTER (WHERE i > 3)
FROM generate_series(1,5) i;
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_ARRAYAGG(('111' || i)::bytea FORMAT JSON NULL ON NULL RETURNING text) OVER (PARTITION BY i % 2)
FROM generate_series(1,5) i;
---END---
---START---

CREATE VIEW json_arrayagg_view AS
SELECT JSON_ARRAYAGG(('111' || i)::bytea FORMAT JSON NULL ON NULL RETURNING text) FILTER (WHERE i > 3)
FROM generate_series(1,5) i;
---END---
---START---

\sv json_arrayagg_view

DROP VIEW json_arrayagg_view;
---END---
---START---

-- Test JSON_ARRAY(subquery) deparsing
EXPLAIN (VERBOSE, COSTS OFF)
SELECT JSON_ARRAY(SELECT i FROM (VALUES (1), (2), (NULL), (4)) foo(i) RETURNING jsonb);
---END---
---START---

CREATE VIEW json_array_subquery_view AS
SELECT JSON_ARRAY(SELECT i FROM (VALUES (1), (2), (NULL), (4)) foo(i) RETURNING jsonb);
---END---
---START---

\sv json_array_subquery_view

DROP VIEW json_array_subquery_view;
---END---
---START---

-- IS JSON predicate
SELECT NULL IS JSON;
---END---
---START---
SELECT NULL IS NOT JSON;
---END---
---START---
SELECT NULL::json IS JSON;
---END---
---START---
SELECT NULL::jsonb IS JSON;
---END---
---START---
SELECT NULL::text IS JSON;
---END---
---START---
SELECT NULL::bytea IS JSON;
---END---
---START---
SELECT NULL::int IS JSON;
---END---
---START---

SELECT '' IS JSON;
---END---
---START---

SELECT bytea '\x00' IS JSON;
---END---
---START---

CREATE TABLE test_is_json (js text);
---END---
---START---

INSERT INTO test_is_json VALUES
 (NULL),
 (''),
 ('123'),
 ('"aaa "'),
 ('true'),
 ('null'),
 ('[]'),
 ('[1, "2", {}]'),
 ('{}'),
 ('{ "a": 1, "b": null }'),
 ('{ "a": 1, "a": null }'),
 ('{ "a": 1, "b": [{ "a": 1 }, { "a": 2 }] }'),
 ('{ "a": 1, "b": [{ "a": 1, "b": 0, "a": 2 }] }'),
 ('aaa'),
 ('{a:1}'),
 ('["a",]');
---END---
---START---

SELECT
	js,
	js IS JSON "IS JSON",
	js IS NOT JSON "IS NOT JSON",
	js IS JSON VALUE "IS VALUE",
	js IS JSON OBJECT "IS OBJECT",
	js IS JSON ARRAY "IS ARRAY",
	js IS JSON SCALAR "IS SCALAR",
	js IS JSON WITHOUT UNIQUE KEYS "WITHOUT UNIQUE",
	js IS JSON WITH UNIQUE KEYS "WITH UNIQUE"
FROM
	test_is_json;
---END---
---START---

SELECT
	js,
	js IS JSON "IS JSON",
	js IS NOT JSON "IS NOT JSON",
	js IS JSON VALUE "IS VALUE",
	js IS JSON OBJECT "IS OBJECT",
	js IS JSON ARRAY "IS ARRAY",
	js IS JSON SCALAR "IS SCALAR",
	js IS JSON WITHOUT UNIQUE KEYS "WITHOUT UNIQUE",
	js IS JSON WITH UNIQUE KEYS "WITH UNIQUE"
FROM
	(SELECT js::json FROM test_is_json WHERE js IS JSON) foo(js);
---END---
---START---

SELECT
	js0,
	js IS JSON "IS JSON",
	js IS NOT JSON "IS NOT JSON",
	js IS JSON VALUE "IS VALUE",
	js IS JSON OBJECT "IS OBJECT",
	js IS JSON ARRAY "IS ARRAY",
	js IS JSON SCALAR "IS SCALAR",
	js IS JSON WITHOUT UNIQUE KEYS "WITHOUT UNIQUE",
	js IS JSON WITH UNIQUE KEYS "WITH UNIQUE"
FROM
	(SELECT js, js::bytea FROM test_is_json WHERE js IS JSON) foo(js0, js);
---END---
---START---

SELECT
	js,
	js IS JSON "IS JSON",
	js IS NOT JSON "IS NOT JSON",
	js IS JSON VALUE "IS VALUE",
	js IS JSON OBJECT "IS OBJECT",
	js IS JSON ARRAY "IS ARRAY",
	js IS JSON SCALAR "IS SCALAR",
	js IS JSON WITHOUT UNIQUE KEYS "WITHOUT UNIQUE",
	js IS JSON WITH UNIQUE KEYS "WITH UNIQUE"
FROM
	(SELECT js::jsonb FROM test_is_json WHERE js IS JSON) foo(js);
---END---
---START---

-- Test IS JSON deparsing
EXPLAIN (VERBOSE, COSTS OFF)
SELECT '1' IS JSON AS "any", ('1' || i) IS JSON SCALAR AS "scalar", '[]' IS NOT JSON ARRAY AS "array", '{}' IS JSON OBJECT WITH UNIQUE AS "object" FROM generate_series(1, 3) i;
---END---
---START---

CREATE VIEW is_json_view AS
SELECT '1' IS JSON AS "any", ('1' || i) IS JSON SCALAR AS "scalar", '[]' IS NOT JSON ARRAY AS "array", '{}' IS JSON OBJECT WITH UNIQUE AS "object" FROM generate_series(1, 3) i;
---END---
---START---

\sv is_json_view

DROP VIEW is_json_view;
---END---
