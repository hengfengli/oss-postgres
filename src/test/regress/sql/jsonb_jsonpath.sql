---START---
select jsonb '{"a": 12}' @? '$';
---END---
---START---
select jsonb '{"a": 12}' @? '1';
---END---
---START---
select jsonb '{"a": 12}' @? '$.a.b';
---END---
---START---
select jsonb '{"a": 12}' @? '$.b';
---END---
---START---
select jsonb '{"a": 12}' @? '$.a + 2';
---END---
---START---
select jsonb '{"a": 12}' @? '$.b + 2';
---END---
---START---
select jsonb '{"a": {"a": 12}}' @? '$.a.a';
---END---
---START---
select jsonb '{"a": {"a": 12}}' @? '$.*.a';
---END---
---START---
select jsonb '{"b": {"a": 12}}' @? '$.*.a';
---END---
---START---
select jsonb '{"b": {"a": 12}}' @? '$.*.b';
---END---
---START---
select jsonb '{"b": {"a": 12}}' @? 'strict $.*.b';
---END---
---START---
select jsonb '{}' @? '$.*';
---END---
---START---
select jsonb '{"a": 1}' @? '$.*';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? 'lax $.**{1}';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? 'lax $.**{2}';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? 'lax $.**{3}';
---END---
---START---
select jsonb '[]' @? '$[*]';
---END---
---START---
select jsonb '[1]' @? '$[*]';
---END---
---START---
select jsonb '[1]' @? '$[1]';
---END---
---START---
select jsonb '[1]' @? 'strict $[1]';
---END---
---START---
select jsonb_path_query('[1]', 'strict $[1]');
---END---
---START---
select jsonb_path_query('[1]', 'strict $[1]', silent => true);
---END---
---START---
select jsonb '[1]' @? 'lax $[10000000000000000]';
---END---
---START---
select jsonb '[1]' @? 'strict $[10000000000000000]';
---END---
---START---
select jsonb_path_query('[1]', 'lax $[10000000000000000]');
---END---
---START---
select jsonb_path_query('[1]', 'strict $[10000000000000000]');
---END---
---START---
select jsonb '[1]' @? '$[0]';
---END---
---START---
select jsonb '[1]' @? '$[0.3]';
---END---
---START---
select jsonb '[1]' @? '$[0.5]';
---END---
---START---
select jsonb '[1]' @? '$[0.9]';
---END---
---START---
select jsonb '[1]' @? '$[1.2]';
---END---
---START---
select jsonb '[1]' @? 'strict $[1.2]';
---END---
---START---
select jsonb '{"a": [1,2,3], "b": [3,4,5]}' @? '$ ? (@.a[*] >  @.b[*])';
---END---
---START---
select jsonb '{"a": [1,2,3], "b": [3,4,5]}' @? '$ ? (@.a[*] >= @.b[*])';
---END---
---START---
select jsonb '{"a": [1,2,3], "b": [3,4,"5"]}' @? '$ ? (@.a[*] >= @.b[*])';
---END---
---START---
select jsonb '{"a": [1,2,3], "b": [3,4,"5"]}' @? 'strict $ ? (@.a[*] >= @.b[*])';
---END---
---START---
select jsonb '{"a": [1,2,3], "b": [3,4,null]}' @? '$ ? (@.a[*] >= @.b[*])';
---END---
---START---
select jsonb '1' @? '$ ? ((@ == "1") is unknown)';
---END---
---START---
select jsonb '1' @? '$ ? ((@ == 1) is unknown)';
---END---
---START---
select jsonb '[{"a": 1}, {"a": 2}]' @? '$[0 to 1] ? (@.a > 1)';
---END---
---START---

select jsonb_path_exists('[{"a": 1}, {"a": 2}, 3]', 'lax $[*].a', silent => false);
---END---
---START---
select jsonb_path_exists('[{"a": 1}, {"a": 2}, 3]', 'lax $[*].a', silent => true);
---END---
---START---
select jsonb_path_exists('[{"a": 1}, {"a": 2}, 3]', 'strict $[*].a', silent => false);
---END---
---START---
select jsonb_path_exists('[{"a": 1}, {"a": 2}, 3]', 'strict $[*].a', silent => true);
---END---
---START---

select jsonb_path_query('1', 'lax $.a');
---END---
---START---
select jsonb_path_query('1', 'strict $.a');
---END---
---START---
select jsonb_path_query('1', 'strict $.*');
---END---
---START---
select jsonb_path_query('1', 'strict $.a', silent => true);
---END---
---START---
select jsonb_path_query('1', 'strict $.*', silent => true);
---END---
---START---
select jsonb_path_query('[]', 'lax $.a');
---END---
---START---
select jsonb_path_query('[]', 'strict $.a');
---END---
---START---
select jsonb_path_query('[]', 'strict $.a', silent => true);
---END---
---START---
select jsonb_path_query('{}', 'lax $.a');
---END---
---START---
select jsonb_path_query('{}', 'strict $.a');
---END---
---START---
select jsonb_path_query('{}', 'strict $.a', silent => true);
---END---
---START---

select jsonb_path_query('1', 'strict $[1]');
---END---
---START---
select jsonb_path_query('1', 'strict $[*]');
---END---
---START---
select jsonb_path_query('[]', 'strict $[1]');
---END---
---START---
select jsonb_path_query('[]', 'strict $["a"]');
---END---
---START---
select jsonb_path_query('1', 'strict $[1]', silent => true);
---END---
---START---
select jsonb_path_query('1', 'strict $[*]', silent => true);
---END---
---START---
select jsonb_path_query('[]', 'strict $[1]', silent => true);
---END---
---START---
select jsonb_path_query('[]', 'strict $["a"]', silent => true);
---END---
---START---

select jsonb_path_query('{"a": 12, "b": {"a": 13}}', '$.a');
---END---
---START---
select jsonb_path_query('{"a": 12, "b": {"a": 13}}', '$.b');
---END---
---START---
select jsonb_path_query('{"a": 12, "b": {"a": 13}}', '$.*');
---END---
---START---
select jsonb_path_query('{"a": 12, "b": {"a": 13}}', 'lax $.*.a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[*].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[*].*');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[0].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[1].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[2].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[0,1].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[0 to 10].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}]', 'lax $[0 to 10 / 0].a');
---END---
---START---
select jsonb_path_query('[12, {"a": 13}, {"b": 14}, "ccc", true]', '$[2.5 - 1 to $.size() - 2]');
---END---
---START---
select jsonb_path_query('1', 'lax $[0]');
---END---
---START---
select jsonb_path_query('1', 'lax $[*]');
---END---
---START---
select jsonb_path_query('[1]', 'lax $[0]');
---END---
---START---
select jsonb_path_query('[1]', 'lax $[*]');
---END---
---START---
select jsonb_path_query('[1,2,3]', 'lax $[*]');
---END---
---START---
select jsonb_path_query('[1,2,3]', 'strict $[*].a');
---END---
---START---
select jsonb_path_query('[1,2,3]', 'strict $[*].a', silent => true);
---END---
---START---
select jsonb_path_query('[]', '$[last]');
---END---
---START---
select jsonb_path_query('[]', '$[last ? (exists(last))]');
---END---
---START---
select jsonb_path_query('[]', 'strict $[last]');
---END---
---START---
select jsonb_path_query('[]', 'strict $[last]', silent => true);
---END---
---START---
select jsonb_path_query('[1]', '$[last]');
---END---
---START---
select jsonb_path_query('[1,2,3]', '$[last]');
---END---
---START---
select jsonb_path_query('[1,2,3]', '$[last - 1]');
---END---
---START---
select jsonb_path_query('[1,2,3]', '$[last ? (@.type() == "number")]');
---END---
---START---
select jsonb_path_query('[1,2,3]', '$[last ? (@.type() == "string")]');
---END---
---START---
select jsonb_path_query('[1,2,3]', '$[last ? (@.type() == "string")]', silent => true);
---END---
---START---

select * from jsonb_path_query('{"a": 10}', '$');
---END---
---START---
select * from jsonb_path_query('{"a": 10}', '$ ? (@.a < $value)');
---END---
---START---
select * from jsonb_path_query('{"a": 10}', '$ ? (@.a < $value)', '1');
---END---
---START---
select * from jsonb_path_query('{"a": 10}', '$ ? (@.a < $value)', '[{"value" : 13}]');
---END---
---START---
select * from jsonb_path_query('{"a": 10}', '$ ? (@.a < $value)', '{"value" : 13}');
---END---
---START---
select * from jsonb_path_query('{"a": 10}', '$ ? (@.a < $value)', '{"value" : 8}');
---END---
---START---
select * from jsonb_path_query('{"a": 10}', '$.a ? (@ < $value)', '{"value" : 13}');
---END---
---START---
select * from jsonb_path_query('[10,11,12,13,14,15]', '$[*] ? (@ < $value)', '{"value" : 13}');
---END---
---START---
select * from jsonb_path_query('[10,11,12,13,14,15]', '$[0,1] ? (@ < $x.value)', '{"x": {"value" : 13}}');
---END---
---START---
select * from jsonb_path_query('[10,11,12,13,14,15]', '$[0 to 2] ? (@ < $value)', '{"value" : 15}');
---END---
---START---
select * from jsonb_path_query('[1,"1",2,"2",null]', '$[*] ? (@ == "1")');
---END---
---START---
select * from jsonb_path_query('[1,"1",2,"2",null]', '$[*] ? (@ == $value)', '{"value" : "1"}');
---END---
---START---
select * from jsonb_path_query('[1,"1",2,"2",null]', '$[*] ? (@ == $value)', '{"value" : null}');
---END---
---START---
select * from jsonb_path_query('[1, "2", null]', '$[*] ? (@ != null)');
---END---
---START---
select * from jsonb_path_query('[1, "2", null]', '$[*] ? (@ == null)');
---END---
---START---
select * from jsonb_path_query('{}', '$ ? (@ == @)');
---END---
---START---
select * from jsonb_path_query('[]', 'strict $ ? (@ == @)');
---END---
---START---

select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{0}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{0 to last}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{1}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{1 to last}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{2}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{2 to last}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{3 to last}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{last}');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{0}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{1}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{0 to last}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{1 to last}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"b": 1}}', 'lax $.**{1 to 2}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**{0}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**{1}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**{0 to last}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**{1 to last}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**{1 to 2}.b ? (@ > 0)');
---END---
---START---
select jsonb_path_query('{"a": {"c": {"b": 1}}}', 'lax $.**{2 to 3}.b ? (@ > 0)');
---END---
---START---

select jsonb '{"a": {"b": 1}}' @? '$.**.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? '$.**{0}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? '$.**{1}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? '$.**{0 to last}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? '$.**{1 to last}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"b": 1}}' @? '$.**{1 to 2}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**{0}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**{1}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**{0 to last}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**{1 to last}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**{1 to 2}.b ? ( @ > 0)';
---END---
---START---
select jsonb '{"a": {"c": {"b": 1}}}' @? '$.**{2 to 3}.b ? ( @ > 0)';
---END---
---START---

select jsonb_path_query('{"g": {"x": 2}}', '$.g ? (exists (@.x))');
---END---
---START---
select jsonb_path_query('{"g": {"x": 2}}', '$.g ? (exists (@.y))');
---END---
---START---
select jsonb_path_query('{"g": {"x": 2}}', '$.g ? (exists (@.x ? (@ >= 2) ))');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'lax $.g ? (exists (@.x))');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'lax $.g ? (exists (@.x + "3"))');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'lax $.g ? ((exists (@.x + "3")) is unknown)');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'strict $.g[*] ? (exists (@.x))');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'strict $.g[*] ? ((exists (@.x)) is unknown)');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'strict $.g ? (exists (@[*].x))');
---END---
---START---
select jsonb_path_query('{"g": [{"x": 2}, {"y": 3}]}', 'strict $.g ? ((exists (@[*].x)) is unknown)');
---END---
---START---

--test ternary logic
select
	x, y,
	jsonb_path_query(
		'[true, false, null]',
		'$[*] ? (@ == true  &&  ($x == true && $y == true) ||
				 @ == false && !($x == true && $y == true) ||
				 @ == null  &&  ($x == true && $y == true) is unknown)',
		jsonb_build_object('x', x, 'y', y)
	) as "x && y"
from
	(values (jsonb 'true'), ('false'), ('"null"')) x(x),
	(values (jsonb 'true'), ('false'), ('"null"')) y(y);
---END---
---START---

select
	x, y,
	jsonb_path_query(
		'[true, false, null]',
		'$[*] ? (@ == true  &&  ($x == true || $y == true) ||
				 @ == false && !($x == true || $y == true) ||
				 @ == null  &&  ($x == true || $y == true) is unknown)',
		jsonb_build_object('x', x, 'y', y)
	) as "x || y"
from
	(values (jsonb 'true'), ('false'), ('"null"')) x(x),
	(values (jsonb 'true'), ('false'), ('"null"')) y(y);
---END---
---START---

select jsonb '{"a": 1, "b":1}' @? '$ ? (@.a == @.b)';
---END---
---START---
select jsonb '{"c": {"a": 1, "b":1}}' @? '$ ? (@.a == @.b)';
---END---
---START---
select jsonb '{"c": {"a": 1, "b":1}}' @? '$.c ? (@.a == @.b)';
---END---
---START---
select jsonb '{"c": {"a": 1, "b":1}}' @? '$.c ? ($.c.a == @.b)';
---END---
---START---
select jsonb '{"c": {"a": 1, "b":1}}' @? '$.* ? (@.a == @.b)';
---END---
---START---
select jsonb '{"a": 1, "b":1}' @? '$.** ? (@.a == @.b)';
---END---
---START---
select jsonb '{"c": {"a": 1, "b":1}}' @? '$.** ? (@.a == @.b)';
---END---
---START---

select jsonb_path_query('{"c": {"a": 2, "b":1}}', '$.** ? (@.a == 1 + 1)');
---END---
---START---
select jsonb_path_query('{"c": {"a": 2, "b":1}}', '$.** ? (@.a == (1 + 1))');
---END---
---START---
select jsonb_path_query('{"c": {"a": 2, "b":1}}', '$.** ? (@.a == @.b + 1)');
---END---
---START---
select jsonb_path_query('{"c": {"a": 2, "b":1}}', '$.** ? (@.a == (@.b + 1))');
---END---
---START---
select jsonb '{"c": {"a": -1, "b":1}}' @? '$.** ? (@.a == - 1)';
---END---
---START---
select jsonb '{"c": {"a": -1, "b":1}}' @? '$.** ? (@.a == -1)';
---END---
---START---
select jsonb '{"c": {"a": -1, "b":1}}' @? '$.** ? (@.a == -@.b)';
---END---
---START---
select jsonb '{"c": {"a": -1, "b":1}}' @? '$.** ? (@.a == - @.b)';
---END---
---START---
select jsonb '{"c": {"a": 0, "b":1}}' @? '$.** ? (@.a == 1 - @.b)';
---END---
---START---
select jsonb '{"c": {"a": 2, "b":1}}' @? '$.** ? (@.a == 1 - - @.b)';
---END---
---START---
select jsonb '{"c": {"a": 0, "b":1}}' @? '$.** ? (@.a == 1 - +@.b)';
---END---
---START---
select jsonb '[1,2,3]' @? '$ ? (+@[*] > +2)';
---END---
---START---
select jsonb '[1,2,3]' @? '$ ? (+@[*] > +3)';
---END---
---START---
select jsonb '[1,2,3]' @? '$ ? (-@[*] < -2)';
---END---
---START---
select jsonb '[1,2,3]' @? '$ ? (-@[*] < -3)';
---END---
---START---
select jsonb '1' @? '$ ? ($ > 0)';
---END---
---START---

-- arithmetic errors
select jsonb_path_query('[1,2,0,3]', '$[*] ? (2 / @ > 0)');
---END---
---START---
select jsonb_path_query('[1,2,0,3]', '$[*] ? ((2 / @ > 0) is unknown)');
---END---
---START---
select jsonb_path_query('0', '1 / $');
---END---
---START---
select jsonb_path_query('0', '1 / $ + 2');
---END---
---START---
select jsonb_path_query('0', '-(3 + 1 % $)');
---END---
---START---
select jsonb_path_query('1', '$ + "2"');
---END---
---START---
select jsonb_path_query('[1, 2]', '3 * $');
---END---
---START---
select jsonb_path_query('"a"', '-$');
---END---
---START---
select jsonb_path_query('[1,"2",3]', '+$');
---END---
---START---
select jsonb_path_query('1', '$ + "2"', silent => true);
---END---
---START---
select jsonb_path_query('[1, 2]', '3 * $', silent => true);
---END---
---START---
select jsonb_path_query('"a"', '-$', silent => true);
---END---
---START---
select jsonb_path_query('[1,"2",3]', '+$', silent => true);
---END---
---START---
select jsonb '["1",2,0,3]' @? '-$[*]';
---END---
---START---
select jsonb '[1,"2",0,3]' @? '-$[*]';
---END---
---START---
select jsonb '["1",2,0,3]' @? 'strict -$[*]';
---END---
---START---
select jsonb '[1,"2",0,3]' @? 'strict -$[*]';
---END---
---START---

-- unwrapping of operator arguments in lax mode
select jsonb_path_query('{"a": [2]}', 'lax $.a * 3');
---END---
---START---
select jsonb_path_query('{"a": [2]}', 'lax $.a + 3');
---END---
---START---
select jsonb_path_query('{"a": [2, 3, 4]}', 'lax -$.a');
---END---
---START---
-- should fail
select jsonb_path_query('{"a": [1, 2]}', 'lax $.a * 3');
---END---
---START---
select jsonb_path_query('{"a": [1, 2]}', 'lax $.a * 3', silent => true);
---END---
---START---

-- extension: boolean expressions
select jsonb_path_query('2', '$ > 1');
---END---
---START---
select jsonb_path_query('2', '$ <= 1');
---END---
---START---
select jsonb_path_query('2', '$ == "2"');
---END---
---START---
select jsonb '2' @? '$ == "2"';
---END---
---START---

select jsonb '2' @@ '$ > 1';
---END---
---START---
select jsonb '2' @@ '$ <= 1';
---END---
---START---
select jsonb '2' @@ '$ == "2"';
---END---
---START---
select jsonb '2' @@ '1';
---END---
---START---
select jsonb '{}' @@ '$';
---END---
---START---
select jsonb '[]' @@ '$';
---END---
---START---
select jsonb '[1,2,3]' @@ '$[*]';
---END---
---START---
select jsonb '[]' @@ '$[*]';
---END---
---START---
select jsonb_path_match('[[1, true], [2, false]]', 'strict $[*] ? (@[0] > $x) [1]', '{"x": 1}');
---END---
---START---
select jsonb_path_match('[[1, true], [2, false]]', 'strict $[*] ? (@[0] < $x) [1]', '{"x": 2}');
---END---
---START---

select jsonb_path_match('[{"a": 1}, {"a": 2}, 3]', 'lax exists($[*].a)', silent => false);
---END---
---START---
select jsonb_path_match('[{"a": 1}, {"a": 2}, 3]', 'lax exists($[*].a)', silent => true);
---END---
---START---
select jsonb_path_match('[{"a": 1}, {"a": 2}, 3]', 'strict exists($[*].a)', silent => false);
---END---
---START---
select jsonb_path_match('[{"a": 1}, {"a": 2}, 3]', 'strict exists($[*].a)', silent => true);
---END---
---START---


select jsonb_path_query('[null,1,true,"a",[],{}]', '$.type()');
---END---
---START---
select jsonb_path_query('[null,1,true,"a",[],{}]', 'lax $.type()');
---END---
---START---
select jsonb_path_query('[null,1,true,"a",[],{}]', '$[*].type()');
---END---
---START---
select jsonb_path_query('null', 'null.type()');
---END---
---START---
select jsonb_path_query('null', 'true.type()');
---END---
---START---
select jsonb_path_query('null', '(123).type()');
---END---
---START---
select jsonb_path_query('null', '"123".type()');
---END---
---START---

select jsonb_path_query('{"a": 2}', '($.a - 5).abs() + 10');
---END---
---START---
select jsonb_path_query('{"a": 2.5}', '-($.a * $.a).floor() % 4.3');
---END---
---START---
select jsonb_path_query('[1, 2, 3]', '($[*] > 2) ? (@ == true)');
---END---
---START---
select jsonb_path_query('[1, 2, 3]', '($[*] > 3).type()');
---END---
---START---
select jsonb_path_query('[1, 2, 3]', '($[*].a > 3).type()');
---END---
---START---
select jsonb_path_query('[1, 2, 3]', 'strict ($[*].a > 3).type()');
---END---
---START---

select jsonb_path_query('[1,null,true,"11",[],[1],[1,2,3],{},{"a":1,"b":2}]', 'strict $[*].size()');
---END---
---START---
select jsonb_path_query('[1,null,true,"11",[],[1],[1,2,3],{},{"a":1,"b":2}]', 'strict $[*].size()', silent => true);
---END---
---START---
select jsonb_path_query('[1,null,true,"11",[],[1],[1,2,3],{},{"a":1,"b":2}]', 'lax $[*].size()');
---END---
---START---

select jsonb_path_query('[0, 1, -2, -3.4, 5.6]', '$[*].abs()');
---END---
---START---
select jsonb_path_query('[0, 1, -2, -3.4, 5.6]', '$[*].floor()');
---END---
---START---
select jsonb_path_query('[0, 1, -2, -3.4, 5.6]', '$[*].ceiling()');
---END---
---START---
select jsonb_path_query('[0, 1, -2, -3.4, 5.6]', '$[*].ceiling().abs()');
---END---
---START---
select jsonb_path_query('[0, 1, -2, -3.4, 5.6]', '$[*].ceiling().abs().type()');
---END---
---START---

select jsonb_path_query('[{},1]', '$[*].keyvalue()');
---END---
---START---
select jsonb_path_query('[{},1]', '$[*].keyvalue()', silent => true);
---END---
---START---
select jsonb_path_query('{}', '$.keyvalue()');
---END---
---START---
select jsonb_path_query('{"a": 1, "b": [1, 2], "c": {"a": "bbb"}}', '$.keyvalue()');
---END---
---START---
select jsonb_path_query('[{"a": 1, "b": [1, 2]}, {"c": {"a": "bbb"}}]', '$[*].keyvalue()');
---END---
---START---
select jsonb_path_query('[{"a": 1, "b": [1, 2]}, {"c": {"a": "bbb"}}]', 'strict $.keyvalue()');
---END---
---START---
select jsonb_path_query('[{"a": 1, "b": [1, 2]}, {"c": {"a": "bbb"}}]', 'lax $.keyvalue()');
---END---
---START---
select jsonb_path_query('[{"a": 1, "b": [1, 2]}, {"c": {"a": "bbb"}}]', 'strict $.keyvalue().a');
---END---
---START---
select jsonb '{"a": 1, "b": [1, 2]}' @? 'lax $.keyvalue()';
---END---
---START---
select jsonb '{"a": 1, "b": [1, 2]}' @? 'lax $.keyvalue().key';
---END---
---START---

select jsonb_path_query('null', '$.double()');
---END---
---START---
select jsonb_path_query('true', '$.double()');
---END---
---START---
select jsonb_path_query('null', '$.double()', silent => true);
---END---
---START---
select jsonb_path_query('true', '$.double()', silent => true);
---END---
---START---
select jsonb_path_query('[]', '$.double()');
---END---
---START---
select jsonb_path_query('[]', 'strict $.double()');
---END---
---START---
select jsonb_path_query('{}', '$.double()');
---END---
---START---
select jsonb_path_query('[]', 'strict $.double()', silent => true);
---END---
---START---
select jsonb_path_query('{}', '$.double()', silent => true);
---END---
---START---
select jsonb_path_query('1.23', '$.double()');
---END---
---START---
select jsonb_path_query('"1.23"', '$.double()');
---END---
---START---
select jsonb_path_query('"1.23aaa"', '$.double()');
---END---
---START---
select jsonb_path_query('1e1000', '$.double()');
---END---
---START---
select jsonb_path_query('"nan"', '$.double()');
---END---
---START---
select jsonb_path_query('"NaN"', '$.double()');
---END---
---START---
select jsonb_path_query('"inf"', '$.double()');
---END---
---START---
select jsonb_path_query('"-inf"', '$.double()');
---END---
---START---
select jsonb_path_query('"inf"', '$.double()', silent => true);
---END---
---START---
select jsonb_path_query('"-inf"', '$.double()', silent => true);
---END---
---START---

select jsonb_path_query('{}', '$.abs()');
---END---
---START---
select jsonb_path_query('true', '$.floor()');
---END---
---START---
select jsonb_path_query('"1.2"', '$.ceiling()');
---END---
---START---
select jsonb_path_query('{}', '$.abs()', silent => true);
---END---
---START---
select jsonb_path_query('true', '$.floor()', silent => true);
---END---
---START---
select jsonb_path_query('"1.2"', '$.ceiling()', silent => true);
---END---
---START---

select jsonb_path_query('["", "a", "abc", "abcabc"]', '$[*] ? (@ starts with "abc")');
---END---
---START---
select jsonb_path_query('["", "a", "abc", "abcabc"]', 'strict $ ? (@[*] starts with "abc")');
---END---
---START---
select jsonb_path_query('["", "a", "abd", "abdabc"]', 'strict $ ? (@[*] starts with "abc")');
---END---
---START---
select jsonb_path_query('["abc", "abcabc", null, 1]', 'strict $ ? (@[*] starts with "abc")');
---END---
---START---
select jsonb_path_query('["abc", "abcabc", null, 1]', 'strict $ ? ((@[*] starts with "abc") is unknown)');
---END---
---START---
select jsonb_path_query('[[null, 1, "abc", "abcabc"]]', 'lax $ ? (@[*] starts with "abc")');
---END---
---START---
select jsonb_path_query('[[null, 1, "abd", "abdabc"]]', 'lax $ ? ((@[*] starts with "abc") is unknown)');
---END---
---START---
select jsonb_path_query('[null, 1, "abd", "abdabc"]', 'lax $[*] ? ((@ starts with "abc") is unknown)');
---END---
---START---

select jsonb_path_query('[null, 1, "abc", "abd", "aBdC", "abdacb", "babc", "adc\nabc", "ab\nadc"]', 'lax $[*] ? (@ like_regex "^ab.*c")');
---END---
---START---
select jsonb_path_query('[null, 1, "abc", "abd", "aBdC", "abdacb", "babc", "adc\nabc", "ab\nadc"]', 'lax $[*] ? (@ like_regex "^ab.*c" flag "i")');
---END---
---START---
select jsonb_path_query('[null, 1, "abc", "abd", "aBdC", "abdacb", "babc", "adc\nabc", "ab\nadc"]', 'lax $[*] ? (@ like_regex "^ab.*c" flag "m")');
---END---
---START---
select jsonb_path_query('[null, 1, "abc", "abd", "aBdC", "abdacb", "babc", "adc\nabc", "ab\nadc"]', 'lax $[*] ? (@ like_regex "^ab.*c" flag "s")');
---END---
---START---
select jsonb_path_query('[null, 1, "a\b", "a\\b", "^a\\b$"]', 'lax $[*] ? (@ like_regex "a\\b" flag "q")');
---END---
---START---
select jsonb_path_query('[null, 1, "a\b", "a\\b", "^a\\b$"]', 'lax $[*] ? (@ like_regex "a\\b" flag "")');
---END---
---START---
select jsonb_path_query('[null, 1, "a\b", "a\\b", "^a\\b$"]', 'lax $[*] ? (@ like_regex "^a\\b$" flag "q")');
---END---
---START---
select jsonb_path_query('[null, 1, "a\b", "a\\b", "^a\\b$"]', 'lax $[*] ? (@ like_regex "^a\\B$" flag "q")');
---END---
---START---
select jsonb_path_query('[null, 1, "a\b", "a\\b", "^a\\b$"]', 'lax $[*] ? (@ like_regex "^a\\B$" flag "iq")');
---END---
---START---
select jsonb_path_query('[null, 1, "a\b", "a\\b", "^a\\b$"]', 'lax $[*] ? (@ like_regex "^a\\b$" flag "")');
---END---
---START---

select jsonb_path_query('null', '$.datetime()');
---END---
---START---
select jsonb_path_query('true', '$.datetime()');
---END---
---START---
select jsonb_path_query('1', '$.datetime()');
---END---
---START---
select jsonb_path_query('[]', '$.datetime()');
---END---
---START---
select jsonb_path_query('[]', 'strict $.datetime()');
---END---
---START---
select jsonb_path_query('{}', '$.datetime()');
---END---
---START---
select jsonb_path_query('"bogus"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"12:34"', '$.datetime("aaa")');
---END---
---START---
select jsonb_path_query('"aaaa"', '$.datetime("HH24")');
---END---
---START---

select jsonb '"10-03-2017"' @? '$.datetime("dd-mm-yyyy")';
---END---
---START---
select jsonb_path_query('"10-03-2017"', '$.datetime("dd-mm-yyyy")');
---END---
---START---
select jsonb_path_query('"10-03-2017"', '$.datetime("dd-mm-yyyy").type()');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34"', '$.datetime("dd-mm-yyyy")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34"', '$.datetime("dd-mm-yyyy").type()');
---END---
---START---

select jsonb_path_query('"10-03-2017 12:34"', '       $.datetime("dd-mm-yyyy HH24:MI").type()');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 +05:20"', '$.datetime("dd-mm-yyyy HH24:MI TZH:TZM").type()');
---END---
---START---
select jsonb_path_query('"12:34:56"', '$.datetime("HH24:MI:SS").type()');
---END---
---START---
select jsonb_path_query('"12:34:56 +05:20"', '$.datetime("HH24:MI:SS TZH:TZM").type()');
---END---
---START---

select jsonb_path_query('"10-03-2017T12:34:56"', '$.datetime("dd-mm-yyyy\"T\"HH24:MI:SS")');
---END---
---START---
select jsonb_path_query('"10-03-2017t12:34:56"', '$.datetime("dd-mm-yyyy\"T\"HH24:MI:SS")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34:56"', '$.datetime("dd-mm-yyyy\"T\"HH24:MI:SS")');
---END---
---START---

set time zone '+00';
---END---
---START---

select jsonb_path_query('"10-03-2017 12:34"', '$.datetime("dd-mm-yyyy HH24:MI")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34"', '$.datetime("dd-mm-yyyy HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 +05"', '$.datetime("dd-mm-yyyy HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 -05"', '$.datetime("dd-mm-yyyy HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 +05:20"', '$.datetime("dd-mm-yyyy HH24:MI TZH:TZM")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 -05:20"', '$.datetime("dd-mm-yyyy HH24:MI TZH:TZM")');
---END---
---START---
select jsonb_path_query('"12:34"', '$.datetime("HH24:MI")');
---END---
---START---
select jsonb_path_query('"12:34"', '$.datetime("HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"12:34 +05"', '$.datetime("HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"12:34 -05"', '$.datetime("HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"12:34 +05:20"', '$.datetime("HH24:MI TZH:TZM")');
---END---
---START---
select jsonb_path_query('"12:34 -05:20"', '$.datetime("HH24:MI TZH:TZM")');
---END---
---START---

set time zone '+10';
---END---
---START---

select jsonb_path_query('"10-03-2017 12:34"', '$.datetime("dd-mm-yyyy HH24:MI")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34"', '$.datetime("dd-mm-yyyy HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 +05"', '$.datetime("dd-mm-yyyy HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 -05"', '$.datetime("dd-mm-yyyy HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 +05:20"', '$.datetime("dd-mm-yyyy HH24:MI TZH:TZM")');
---END---
---START---
select jsonb_path_query('"10-03-2017 12:34 -05:20"', '$.datetime("dd-mm-yyyy HH24:MI TZH:TZM")');
---END---
---START---
select jsonb_path_query('"12:34"', '$.datetime("HH24:MI")');
---END---
---START---
select jsonb_path_query('"12:34"', '$.datetime("HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"12:34 +05"', '$.datetime("HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"12:34 -05"', '$.datetime("HH24:MI TZH")');
---END---
---START---
select jsonb_path_query('"12:34 +05:20"', '$.datetime("HH24:MI TZH:TZM")');
---END---
---START---
select jsonb_path_query('"12:34 -05:20"', '$.datetime("HH24:MI TZH:TZM")');
---END---
---START---

set time zone default;
---END---
---START---

select jsonb_path_query('"2017-03-10"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"2017-03-10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56+3"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56+3"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56+3:10"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56+3:10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10T12:34:56+3:10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10t12:34:56+3:10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10 12:34:56.789+3:10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10T12:34:56.789+3:10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"2017-03-10t12:34:56.789+3:10"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"12:34:56"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"12:34:56"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"12:34:56+3"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"12:34:56+3"', '$.datetime()');
---END---
---START---
select jsonb_path_query('"12:34:56+3:10"', '$.datetime().type()');
---END---
---START---
select jsonb_path_query('"12:34:56+3:10"', '$.datetime()');
---END---
---START---

set time zone '+00';
---END---
---START---

-- date comparison
select jsonb_path_query(
	'["2017-03-10", "2017-03-11", "2017-03-09", "12:34:56", "01:02:03+04", "2017-03-10 00:00:00", "2017-03-10 12:34:56", "2017-03-10 01:02:03+04", "2017-03-10 03:00:00+03"]',
	'$[*].datetime() ? (@ == "10.03.2017".datetime("dd.mm.yyyy"))');
---END---
---START---
select jsonb_path_query(
	'["2017-03-10", "2017-03-11", "2017-03-09", "12:34:56", "01:02:03+04", "2017-03-10 00:00:00", "2017-03-10 12:34:56", "2017-03-10 01:02:03+04", "2017-03-10 03:00:00+03"]',
	'$[*].datetime() ? (@ >= "10.03.2017".datetime("dd.mm.yyyy"))');
---END---
---START---
select jsonb_path_query(
	'["2017-03-10", "2017-03-11", "2017-03-09", "12:34:56", "01:02:03+04", "2017-03-10 00:00:00", "2017-03-10 12:34:56", "2017-03-10 01:02:03+04", "2017-03-10 03:00:00+03"]',
	'$[*].datetime() ? (@ <  "10.03.2017".datetime("dd.mm.yyyy"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10", "2017-03-11", "2017-03-09", "12:34:56", "01:02:03+04", "2017-03-10 00:00:00", "2017-03-10 12:34:56", "2017-03-10 01:02:03+04", "2017-03-10 03:00:00+03"]',
	'$[*].datetime() ? (@ == "10.03.2017".datetime("dd.mm.yyyy"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10", "2017-03-11", "2017-03-09", "12:34:56", "01:02:03+04", "2017-03-10 00:00:00", "2017-03-10 12:34:56", "2017-03-10 01:02:03+04", "2017-03-10 03:00:00+03"]',
	'$[*].datetime() ? (@ >= "10.03.2017".datetime("dd.mm.yyyy"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10", "2017-03-11", "2017-03-09", "12:34:56", "01:02:03+04", "2017-03-10 00:00:00", "2017-03-10 12:34:56", "2017-03-10 01:02:03+04", "2017-03-10 03:00:00+03"]',
	'$[*].datetime() ? (@ <  "10.03.2017".datetime("dd.mm.yyyy"))');
---END---
---START---

-- time comparison
select jsonb_path_query(
	'["12:34:00", "12:35:00", "12:36:00", "12:35:00+00", "12:35:00+01", "13:35:00+01", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00+01"]',
	'$[*].datetime() ? (@ == "12:35".datetime("HH24:MI"))');
---END---
---START---
select jsonb_path_query(
	'["12:34:00", "12:35:00", "12:36:00", "12:35:00+00", "12:35:00+01", "13:35:00+01", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00+01"]',
	'$[*].datetime() ? (@ >= "12:35".datetime("HH24:MI"))');
---END---
---START---
select jsonb_path_query(
	'["12:34:00", "12:35:00", "12:36:00", "12:35:00+00", "12:35:00+01", "13:35:00+01", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00+01"]',
	'$[*].datetime() ? (@ <  "12:35".datetime("HH24:MI"))');
---END---
---START---
select jsonb_path_query_tz(
	'["12:34:00", "12:35:00", "12:36:00", "12:35:00+00", "12:35:00+01", "13:35:00+01", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00+01"]',
	'$[*].datetime() ? (@ == "12:35".datetime("HH24:MI"))');
---END---
---START---
select jsonb_path_query_tz(
	'["12:34:00", "12:35:00", "12:36:00", "12:35:00+00", "12:35:00+01", "13:35:00+01", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00+01"]',
	'$[*].datetime() ? (@ >= "12:35".datetime("HH24:MI"))');
---END---
---START---
select jsonb_path_query_tz(
	'["12:34:00", "12:35:00", "12:36:00", "12:35:00+00", "12:35:00+01", "13:35:00+01", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00+01"]',
	'$[*].datetime() ? (@ <  "12:35".datetime("HH24:MI"))');
---END---
---START---

-- timetz comparison
select jsonb_path_query(
	'["12:34:00+01", "12:35:00+01", "12:36:00+01", "12:35:00+02", "12:35:00-02", "10:35:00", "11:35:00", "12:35:00", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00 +1"]',
	'$[*].datetime() ? (@ == "12:35 +1".datetime("HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query(
	'["12:34:00+01", "12:35:00+01", "12:36:00+01", "12:35:00+02", "12:35:00-02", "10:35:00", "11:35:00", "12:35:00", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00 +1"]',
	'$[*].datetime() ? (@ >= "12:35 +1".datetime("HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query(
	'["12:34:00+01", "12:35:00+01", "12:36:00+01", "12:35:00+02", "12:35:00-02", "10:35:00", "11:35:00", "12:35:00", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00 +1"]',
	'$[*].datetime() ? (@ <  "12:35 +1".datetime("HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query_tz(
	'["12:34:00+01", "12:35:00+01", "12:36:00+01", "12:35:00+02", "12:35:00-02", "10:35:00", "11:35:00", "12:35:00", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00 +1"]',
	'$[*].datetime() ? (@ == "12:35 +1".datetime("HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query_tz(
	'["12:34:00+01", "12:35:00+01", "12:36:00+01", "12:35:00+02", "12:35:00-02", "10:35:00", "11:35:00", "12:35:00", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00 +1"]',
	'$[*].datetime() ? (@ >= "12:35 +1".datetime("HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query_tz(
	'["12:34:00+01", "12:35:00+01", "12:36:00+01", "12:35:00+02", "12:35:00-02", "10:35:00", "11:35:00", "12:35:00", "2017-03-10", "2017-03-10 12:35:00", "2017-03-10 12:35:00 +1"]',
	'$[*].datetime() ? (@ <  "12:35 +1".datetime("HH24:MI TZH"))');
---END---
---START---

-- timestamp comparison
select jsonb_path_query(
	'["2017-03-10 12:34:00", "2017-03-10 12:35:00", "2017-03-10 12:36:00", "2017-03-10 12:35:00+01", "2017-03-10 13:35:00+01", "2017-03-10 12:35:00-01", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ == "10.03.2017 12:35".datetime("dd.mm.yyyy HH24:MI"))');
---END---
---START---
select jsonb_path_query(
	'["2017-03-10 12:34:00", "2017-03-10 12:35:00", "2017-03-10 12:36:00", "2017-03-10 12:35:00+01", "2017-03-10 13:35:00+01", "2017-03-10 12:35:00-01", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ >= "10.03.2017 12:35".datetime("dd.mm.yyyy HH24:MI"))');
---END---
---START---
select jsonb_path_query(
	'["2017-03-10 12:34:00", "2017-03-10 12:35:00", "2017-03-10 12:36:00", "2017-03-10 12:35:00+01", "2017-03-10 13:35:00+01", "2017-03-10 12:35:00-01", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ < "10.03.2017 12:35".datetime("dd.mm.yyyy HH24:MI"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10 12:34:00", "2017-03-10 12:35:00", "2017-03-10 12:36:00", "2017-03-10 12:35:00+01", "2017-03-10 13:35:00+01", "2017-03-10 12:35:00-01", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ == "10.03.2017 12:35".datetime("dd.mm.yyyy HH24:MI"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10 12:34:00", "2017-03-10 12:35:00", "2017-03-10 12:36:00", "2017-03-10 12:35:00+01", "2017-03-10 13:35:00+01", "2017-03-10 12:35:00-01", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ >= "10.03.2017 12:35".datetime("dd.mm.yyyy HH24:MI"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10 12:34:00", "2017-03-10 12:35:00", "2017-03-10 12:36:00", "2017-03-10 12:35:00+01", "2017-03-10 13:35:00+01", "2017-03-10 12:35:00-01", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ < "10.03.2017 12:35".datetime("dd.mm.yyyy HH24:MI"))');
---END---
---START---

-- timestamptz comparison
select jsonb_path_query(
	'["2017-03-10 12:34:00+01", "2017-03-10 12:35:00+01", "2017-03-10 12:36:00+01", "2017-03-10 12:35:00+02", "2017-03-10 12:35:00-02", "2017-03-10 10:35:00", "2017-03-10 11:35:00", "2017-03-10 12:35:00", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ == "10.03.2017 12:35 +1".datetime("dd.mm.yyyy HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query(
	'["2017-03-10 12:34:00+01", "2017-03-10 12:35:00+01", "2017-03-10 12:36:00+01", "2017-03-10 12:35:00+02", "2017-03-10 12:35:00-02", "2017-03-10 10:35:00", "2017-03-10 11:35:00", "2017-03-10 12:35:00", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ >= "10.03.2017 12:35 +1".datetime("dd.mm.yyyy HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query(
	'["2017-03-10 12:34:00+01", "2017-03-10 12:35:00+01", "2017-03-10 12:36:00+01", "2017-03-10 12:35:00+02", "2017-03-10 12:35:00-02", "2017-03-10 10:35:00", "2017-03-10 11:35:00", "2017-03-10 12:35:00", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ < "10.03.2017 12:35 +1".datetime("dd.mm.yyyy HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10 12:34:00+01", "2017-03-10 12:35:00+01", "2017-03-10 12:36:00+01", "2017-03-10 12:35:00+02", "2017-03-10 12:35:00-02", "2017-03-10 10:35:00", "2017-03-10 11:35:00", "2017-03-10 12:35:00", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ == "10.03.2017 12:35 +1".datetime("dd.mm.yyyy HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10 12:34:00+01", "2017-03-10 12:35:00+01", "2017-03-10 12:36:00+01", "2017-03-10 12:35:00+02", "2017-03-10 12:35:00-02", "2017-03-10 10:35:00", "2017-03-10 11:35:00", "2017-03-10 12:35:00", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ >= "10.03.2017 12:35 +1".datetime("dd.mm.yyyy HH24:MI TZH"))');
---END---
---START---
select jsonb_path_query_tz(
	'["2017-03-10 12:34:00+01", "2017-03-10 12:35:00+01", "2017-03-10 12:36:00+01", "2017-03-10 12:35:00+02", "2017-03-10 12:35:00-02", "2017-03-10 10:35:00", "2017-03-10 11:35:00", "2017-03-10 12:35:00", "2017-03-10", "2017-03-11", "12:34:56", "12:34:56+01"]',
	'$[*].datetime() ? (@ < "10.03.2017 12:35 +1".datetime("dd.mm.yyyy HH24:MI TZH"))');
---END---
---START---

-- overflow during comparison
select jsonb_path_query('"1000000-01-01"', '$.datetime() > "2020-01-01 12:00:00".datetime()'::jsonpath);
---END---
---START---

set time zone default;
---END---
---START---

-- jsonpath operators

SELECT jsonb_path_query('[{"a": 1}, {"a": 2}]', '$[*]');
---END---
---START---
SELECT jsonb_path_query('[{"a": 1}, {"a": 2}]', '$[*] ? (@.a > 10)');
---END---
---START---
SELECT jsonb_path_query('[{"a": 1}]', '$undefined_var');
---END---
---START---
SELECT jsonb_path_query('[{"a": 1}]', 'false');
---END---
---START---

SELECT jsonb_path_query_array('[{"a": 1}, {"a": 2}, {}]', 'strict $[*].a');
---END---
---START---
SELECT jsonb_path_query_array('[{"a": 1}, {"a": 2}]', '$[*].a');
---END---
---START---
SELECT jsonb_path_query_array('[{"a": 1}, {"a": 2}]', '$[*].a ? (@ == 1)');
---END---
---START---
SELECT jsonb_path_query_array('[{"a": 1}, {"a": 2}]', '$[*].a ? (@ > 10)');
---END---
---START---
SELECT jsonb_path_query_array('[{"a": 1}, {"a": 2}, {"a": 3}, {"a": 5}]', '$[*].a ? (@ > $min && @ < $max)', vars => '{"min": 1, "max": 4}');
---END---
---START---
SELECT jsonb_path_query_array('[{"a": 1}, {"a": 2}, {"a": 3}, {"a": 5}]', '$[*].a ? (@ > $min && @ < $max)', vars => '{"min": 3, "max": 4}');
---END---
---START---

SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}, {}]', 'strict $[*].a');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}, {}]', 'strict $[*].a', silent => true);
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}]', '$[*].a');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}]', '$[*].a ? (@ == 1)');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}]', '$[*].a ? (@ > 10)');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}, {"a": 3}, {"a": 5}]', '$[*].a ? (@ > $min && @ < $max)', vars => '{"min": 1, "max": 4}');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}, {"a": 2}, {"a": 3}, {"a": 5}]', '$[*].a ? (@ > $min && @ < $max)', vars => '{"min": 3, "max": 4}');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}]', '$undefined_var');
---END---
---START---
SELECT jsonb_path_query_first('[{"a": 1}]', 'false');
---END---
---START---

SELECT jsonb '[{"a": 1}, {"a": 2}]' @? '$[*].a ? (@ > 1)';
---END---
---START---
SELECT jsonb '[{"a": 1}, {"a": 2}]' @? '$[*] ? (@.a > 2)';
---END---
---START---
SELECT jsonb_path_exists('[{"a": 1}, {"a": 2}]', '$[*].a ? (@ > 1)');
---END---
---START---
SELECT jsonb_path_exists('[{"a": 1}, {"a": 2}, {"a": 3}, {"a": 5}]', '$[*] ? (@.a > $min && @.a < $max)', vars => '{"min": 1, "max": 4}');
---END---
---START---
SELECT jsonb_path_exists('[{"a": 1}, {"a": 2}, {"a": 3}, {"a": 5}]', '$[*] ? (@.a > $min && @.a < $max)', vars => '{"min": 3, "max": 4}');
---END---
---START---
SELECT jsonb_path_exists('[{"a": 1}]', '$undefined_var');
---END---
---START---
SELECT jsonb_path_exists('[{"a": 1}]', 'false');
---END---
---START---

SELECT jsonb_path_match('true', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('false', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('null', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('1', '$', silent => true);
---END---
---START---
SELECT jsonb_path_match('1', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('"a"', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('{}', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('[true]', '$', silent => false);
---END---
---START---
SELECT jsonb_path_match('{}', 'lax $.a', silent => false);
---END---
---START---
SELECT jsonb_path_match('{}', 'strict $.a', silent => false);
---END---
---START---
SELECT jsonb_path_match('{}', 'strict $.a', silent => true);
---END---
---START---
SELECT jsonb_path_match('[true, true]', '$[*]', silent => false);
---END---
---START---
SELECT jsonb '[{"a": 1}, {"a": 2}]' @@ '$[*].a > 1';
---END---
---START---
SELECT jsonb '[{"a": 1}, {"a": 2}]' @@ '$[*].a > 2';
---END---
---START---
SELECT jsonb_path_match('[{"a": 1}, {"a": 2}]', '$[*].a > 1');
---END---
---START---
SELECT jsonb_path_match('[{"a": 1}]', '$undefined_var');
---END---
---START---
SELECT jsonb_path_match('[{"a": 1}]', 'false');
---END---
---START---

-- test string comparison (Unicode codepoint collation)
WITH str(j, num) AS
(
	SELECT jsonb_build_object('s', s), num
	FROM unnest('{"", "a", "ab", "abc", "abcd", "b", "A", "AB", "ABC", "ABc", "ABcD", "B"}'::text[]) WITH ORDINALITY AS a(s, num)
)
SELECT
	s1.j, s2.j,
	jsonb_path_query_first(s1.j, '$.s < $s', vars => s2.j) lt,
	jsonb_path_query_first(s1.j, '$.s <= $s', vars => s2.j) le,
	jsonb_path_query_first(s1.j, '$.s == $s', vars => s2.j) eq,
	jsonb_path_query_first(s1.j, '$.s >= $s', vars => s2.j) ge,
	jsonb_path_query_first(s1.j, '$.s > $s', vars => s2.j) gt
FROM str s1, str s2
ORDER BY s1.num, s2.num;
---END---
