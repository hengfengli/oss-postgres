---START---
CREATE TABLE a_star (_gemini_pk serial PRIMARY KEY, class char, a int4);
---END---
---START---
CREATE TABLE b_star (_gemini_pk serial PRIMARY KEY, b text) INHERITS (a_star);
---END---
---START---
CREATE TABLE c_star (_gemini_pk serial PRIMARY KEY, c name) INHERITS (a_star);
---END---
---START---
CREATE TABLE d_star (_gemini_pk serial PRIMARY KEY, d float8) INHERITS (b_star, c_star);
---END---
---START---
CREATE TABLE e_star (_gemini_pk serial PRIMARY KEY, e int2) INHERITS (c_star);
---END---
---START---
CREATE TABLE f_star (_gemini_pk serial PRIMARY KEY, f polygon) INHERITS (e_star);
---END---
---START---
INSERT INTO a_star (class, a) VALUES ('a', 1);
---END---
---START---
INSERT INTO a_star (class, a) VALUES ('a', 2);
---END---
---START---
INSERT INTO a_star (class) VALUES ('a');
---END---
---START---
INSERT INTO b_star (class, a, b) VALUES ('b', 3, 'mumble'::text);
---END---
---START---
INSERT INTO b_star (class, a) VALUES ('b', 4);
---END---
---START---
INSERT INTO b_star (class, b) VALUES ('b', 'bumble'::text);
---END---
---START---
INSERT INTO b_star (class) VALUES ('b');
---END---
---START---
INSERT INTO c_star (class, a, c) VALUES ('c', 5, 'hi mom'::name);
---END---
---START---
INSERT INTO c_star (class, a) VALUES ('c', 6);
---END---
---START---
INSERT INTO c_star (class, c) VALUES ('c', 'hi paul'::name);
---END---
---START---
INSERT INTO c_star (class) VALUES ('c');
---END---
---START---
INSERT INTO d_star (class, a, b, c, d)
   VALUES ('d', 7, 'grumble'::text, 'hi sunita'::name, '0.0'::float8);
---END---
---START---
INSERT INTO d_star (class, a, b, c)
   VALUES ('d', 8, 'stumble'::text, 'hi koko'::name);
---END---
---START---
INSERT INTO d_star (class, a, b, d)
   VALUES ('d', 9, 'rumble'::text, '1.1'::float8);
---END---
---START---
INSERT INTO d_star (class, a, c, d)
   VALUES ('d', 10, 'hi kristin'::name, '10.01'::float8);
---END---
---START---
INSERT INTO d_star (class, b, c, d)
   VALUES ('d', 'crumble'::text, 'hi boris'::name, '100.001'::float8);
---END---
---START---
INSERT INTO d_star (class, a, b)
   VALUES ('d', 11, 'fumble'::text);
---END---
---START---
INSERT INTO d_star (class, a, c)
   VALUES ('d', 12, 'hi avi'::name);
---END---
---START---
INSERT INTO d_star (class, a, d)
   VALUES ('d', 13, '1000.0001'::float8);
---END---
---START---
INSERT INTO d_star (class, b, c)
   VALUES ('d', 'tumble'::text, 'hi andrew'::name);
---END---
---START---
INSERT INTO d_star (class, b, d)
   VALUES ('d', 'humble'::text, '10000.00001'::float8);
---END---
---START---
INSERT INTO d_star (class, c, d)
   VALUES ('d', 'hi ginger'::name, '100000.000001'::float8);
---END---
---START---
INSERT INTO d_star (class, a) VALUES ('d', 14);
---END---
---START---
INSERT INTO d_star (class, b) VALUES ('d', 'jumble'::text);
---END---
---START---
INSERT INTO d_star (class, c) VALUES ('d', 'hi jolly'::name);
---END---
---START---
INSERT INTO d_star (class, d) VALUES ('d', '1000000.0000001'::float8);
---END---
---START---
INSERT INTO d_star (class) VALUES ('d');
---END---
---START---
INSERT INTO e_star (class, a, c, e)
   VALUES ('e', 15, 'hi carol'::name, '-1'::int2);
---END---
---START---
INSERT INTO e_star (class, a, c)
   VALUES ('e', 16, 'hi bob'::name);
---END---
---START---
INSERT INTO e_star (class, a, e)
   VALUES ('e', 17, '-2'::int2);
---END---
---START---
INSERT INTO e_star (class, c, e)
   VALUES ('e', 'hi michelle'::name, '-3'::int2);
---END---
---START---
INSERT INTO e_star (class, a)
   VALUES ('e', 18);
---END---
---START---
INSERT INTO e_star (class, c)
   VALUES ('e', 'hi elisa'::name);
---END---
---START---
INSERT INTO e_star (class, e)
   VALUES ('e', '-4'::int2);
---END---
---START---
INSERT INTO f_star (class, a, c, e, f)
   VALUES ('f', 19, 'hi claire'::name, '-5'::int2, '(1,3),(2,4)'::polygon);
---END---
---START---
INSERT INTO f_star (class, a, c, e)
   VALUES ('f', 20, 'hi mike'::name, '-6'::int2);
---END---
---START---
INSERT INTO f_star (class, a, c, f)
   VALUES ('f', 21, 'hi marcel'::name, '(11,44),(22,55),(33,66)'::polygon);
---END---
---START---
INSERT INTO f_star (class, a, e, f)
   VALUES ('f', 22, '-7'::int2, '(111,555),(222,666),(333,777),(444,888)'::polygon);
---END---
---START---
INSERT INTO f_star (class, c, e, f)
   VALUES ('f', 'hi keith'::name, '-8'::int2,
	   '(1111,3333),(2222,4444)'::polygon);
---END---
---START---
INSERT INTO f_star (class, a, c)
   VALUES ('f', 24, 'hi marc'::name);
---END---
---START---
INSERT INTO f_star (class, a, e)
   VALUES ('f', 25, '-9'::int2);
---END---
---START---
INSERT INTO f_star (class, a, f)
   VALUES ('f', 26, '(11111,33333),(22222,44444)'::polygon);
---END---
---START---
INSERT INTO f_star (class, c, e)
   VALUES ('f', 'hi allison'::name, '-10'::int2);
---END---
---START---
INSERT INTO f_star (class, c, f)
   VALUES ('f', 'hi jeff'::name,
           '(111111,333333),(222222,444444)'::polygon);
---END---
---START---
INSERT INTO f_star (class, e, f)
   VALUES ('f', '-11'::int2, '(1111111,3333333),(2222222,4444444)'::polygon);
---END---
---START---
INSERT INTO f_star (class, a) VALUES ('f', 27);
---END---
---START---
INSERT INTO f_star (class, c) VALUES ('f', 'hi carl'::name);
---END---
---START---
INSERT INTO f_star (class, e) VALUES ('f', '-12'::int2);
---END---
---START---
INSERT INTO f_star (class, f)
   VALUES ('f', '(11111111,33333333),(22222222,44444444)'::polygon);
---END---
---START---
INSERT INTO f_star (class) VALUES ('f');
---END---
---START---
-- Analyze the X_star tables for better plan stability in later tests
ANALYZE a_star;
---END---
---START---
ANALYZE b_star;
---END---
---START---
ANALYZE c_star;
---END---
---START---
ANALYZE d_star;
---END---
---START---
ANALYZE e_star;
---END---
---START---
ANALYZE f_star;
---END---
---START---
--
-- inheritance stress test
--
SELECT * FROM a_star*;
---END---
---START---
SELECT *
   FROM b_star* x
   WHERE x.b = text 'bumble' or x.a < 3;
---END---
---START---
SELECT class, a
   FROM c_star* x
   WHERE x.c ~ text 'hi';
---END---
---START---
SELECT class, b, c
   FROM d_star* x
   WHERE x.a < 100;
---END---
---START---
SELECT class, c FROM e_star* x WHERE x.c NOTNULL;
---END---
---START---
SELECT * FROM f_star* x WHERE x.c ISNULL;
---END---
---START---
-- grouping and aggregation on inherited sets have been busted in the past...

SELECT sum(a) FROM a_star*;
---END---
---START---
SELECT class, sum(a) FROM a_star* GROUP BY class ORDER BY class;
---END---
---START---
ALTER TABLE f_star RENAME COLUMN f TO ff;
---END---
---START---
ALTER TABLE e_star* RENAME COLUMN e TO ee;
---END---
---START---
ALTER TABLE d_star* RENAME COLUMN d TO dd;
---END---
---START---
ALTER TABLE c_star* RENAME COLUMN c TO cc;
---END---
---START---
ALTER TABLE b_star* RENAME COLUMN b TO bb;
---END---
---START---
ALTER TABLE a_star* RENAME COLUMN a TO aa;
---END---
---START---
SELECT class, aa
   FROM a_star* x
   WHERE aa ISNULL;
---END---
---START---
-- As of Postgres 7.1, ALTER implicitly recurses,
-- so this should be same as ALTER a_star*

ALTER TABLE a_star RENAME COLUMN aa TO foo;
---END---
---START---
SELECT class, foo
   FROM a_star* x
   WHERE x.foo >= 2;
---END---
---START---
ALTER TABLE a_star RENAME COLUMN foo TO aa;
---END---
---START---
SELECT *
   from a_star*
   WHERE aa < 1000;
---END---
---START---
ALTER TABLE f_star ADD COLUMN f int4;
---END---
---START---
UPDATE f_star SET f = 10;
---END---
---START---
ALTER TABLE e_star* ADD COLUMN e int4;
---END---
---START---
--UPDATE e_star* SET e = 42;

SELECT * FROM e_star*;
---END---
---START---
ALTER TABLE a_star* ADD COLUMN a text;
---END---
---START---
-- That ALTER TABLE should have added TOAST tables.
SELECT relname, reltoastrelid <> 0 AS has_toast_table
   FROM pg_class
   WHERE oid::regclass IN ('a_star', 'c_star')
   ORDER BY 1;
---END---
---START---
--UPDATE b_star*
--   SET a = text 'gazpacho'
--   WHERE aa > 4;

SELECT class, aa, a FROM a_star*;
---END---
