---START---
--
-- MISC
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR
\getenv abs_builddir PG_ABS_BUILDDIR
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

CREATE FUNCTION overpaid(emp)
   RETURNS bool
   AS :'regresslib'
   LANGUAGE C STRICT;
---END---
---START---
CREATE FUNCTION reverse_name(name)
   RETURNS name
   AS :'regresslib'
   LANGUAGE C STRICT;
---END---
---START---
--
-- BTREE
--
UPDATE onek
   SET unique1 = onek.unique1 + 1;
---END---
---START---
UPDATE onek
   SET unique1 = onek.unique1 - 1;
---END---
---START---
--
-- BTREE partial
--
-- UPDATE onek2
--   SET unique1 = onek2.unique1 + 1;

--UPDATE onek2
--   SET unique1 = onek2.unique1 - 1;

--
-- BTREE shutting out non-functional updates
--
-- the following two tests seem to take a long time on some
-- systems.    This non-func update stuff needs to be examined
-- more closely.  			- jolly (2/22/96)
--
SELECT two, stringu1, ten, string4
   INTO TABLE tmp
   FROM onek;
---END---
---START---
UPDATE tmp
   SET stringu1 = reverse_name(onek.stringu1)
   FROM onek
   WHERE onek.stringu1 = 'JBAAAA' and
	  onek.stringu1 = tmp.stringu1;
---END---
---START---
UPDATE tmp
   SET stringu1 = reverse_name(onek2.stringu1)
   FROM onek2
   WHERE onek2.stringu1 = 'JCAAAA' and
	  onek2.stringu1 = tmp.stringu1;
---END---
---START---
DROP TABLE tmp;
---END---
---START---
--UPDATE person*
--   SET age = age + 1;

--UPDATE person*
--   SET age = age + 3
--   WHERE name = 'linda';

--
-- copy
--
\set filename :abs_builddir '/results/onek.data'
COPY onek TO :'filename';
---END---
---START---
DROP TABLE IF EXISTS onek_copy;

CREATE TABLE onek_copy (gemini_pk serial PRIMARY KEY, LIKE onek);
---END---
---START---
COPY onek_copy FROM :'filename';
---END---
---START---
SELECT * FROM onek EXCEPT ALL SELECT * FROM onek_copy;
---END---
---START---
SELECT * FROM onek_copy EXCEPT ALL SELECT * FROM onek;
---END---
---START---
\set filename :abs_builddir '/results/stud_emp.data'
COPY BINARY stud_emp TO :'filename';
---END---
---START---
DROP TABLE IF EXISTS stud_emp_copy;

CREATE TABLE stud_emp_copy (gemini_pk serial PRIMARY KEY, LIKE stud_emp);
---END---
---START---
COPY BINARY stud_emp_copy FROM :'filename';
---END---
---START---
SELECT * FROM stud_emp_copy;
---END---
---START---
CREATE TABLE hobbies_r (gemini_pk serial PRIMARY KEY, name text, person text);
---END---
---START---
CREATE TABLE equipment_r (gemini_pk serial PRIMARY KEY, name text, hobby text);
---END---
---START---
INSERT INTO hobbies_r (name, person)
   SELECT 'posthacking', p.name
   FROM person* p
   WHERE p.name = 'mike' or p.name = 'jeff';
---END---
---START---
INSERT INTO hobbies_r (name, person)
   SELECT 'basketball', p.name
   FROM person p
   WHERE p.name = 'joe' or p.name = 'sally';
---END---
---START---
INSERT INTO hobbies_r (name) VALUES ('skywalking');
---END---
---START---
INSERT INTO equipment_r (name, hobby) VALUES ('advil', 'posthacking');
---END---
---START---
INSERT INTO equipment_r (name, hobby) VALUES ('peet''s coffee', 'posthacking');
---END---
---START---
INSERT INTO equipment_r (name, hobby) VALUES ('hightops', 'basketball');
---END---
---START---
INSERT INTO equipment_r (name, hobby) VALUES ('guts', 'skywalking');
---END---
---START---
--
-- postquel functions
--

CREATE FUNCTION hobbies(person)
   RETURNS setof hobbies_r
   AS 'select * from hobbies_r where person = $1.name'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION hobby_construct(text, text)
   RETURNS hobbies_r
   AS 'select $1 as name, $2 as hobby'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION hobby_construct_named(name text, hobby text)
   RETURNS hobbies_r
   AS 'select name, hobby'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION hobbies_by_name(hobbies_r.name%TYPE)
   RETURNS hobbies_r.person%TYPE
   AS 'select person from hobbies_r where name = $1'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment(hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = $1.name'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment_named(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where equipment_r.hobby = equipment_named.hobby.name'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment_named_ambiguous_1a(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = equipment_named_ambiguous_1a.hobby.name'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment_named_ambiguous_1b(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where equipment_r.hobby = hobby.name'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment_named_ambiguous_1c(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = hobby.name'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment_named_ambiguous_2a(hobby text)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = equipment_named_ambiguous_2a.hobby'
   LANGUAGE SQL;
---END---
---START---
CREATE FUNCTION equipment_named_ambiguous_2b(hobby text)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where equipment_r.hobby = hobby'
   LANGUAGE SQL;
---END---
---START---
--
-- mike does post_hacking,
-- joe and sally play basketball, and
-- everyone else does nothing.
--
SELECT p.name, name(p.hobbies) FROM ONLY person p;
---END---
---START---
--
-- as above, but jeff also does post_hacking.
--
SELECT p.name, name(p.hobbies) FROM person* p;
---END---
---START---
--
-- the next two queries demonstrate how functions generate bogus duplicates.
-- this is a "feature" ..
--
SELECT DISTINCT hobbies_r.name, name(hobbies_r.equipment) FROM hobbies_r
  ORDER BY 1,2;
---END---
---START---
SELECT hobbies_r.name, (hobbies_r.equipment).name FROM hobbies_r;
---END---
---START---
--
-- mike needs advil and peet's coffee,
-- joe and sally need hightops, and
-- everyone else is fine.
--
SELECT p.name, name(p.hobbies), name(equipment(p.hobbies)) FROM ONLY person p;
---END---
---START---
--
-- as above, but jeff needs advil and peet's coffee as well.
--
SELECT p.name, name(p.hobbies), name(equipment(p.hobbies)) FROM person* p;
---END---
---START---
--
-- just like the last two, but make sure that the target list fixup and
-- unflattening is being done correctly.
--
SELECT name(equipment(p.hobbies)), p.name, name(p.hobbies) FROM ONLY person p;
---END---
---START---
SELECT (p.hobbies).equipment.name, p.name, name(p.hobbies) FROM person* p;
---END---
---START---
SELECT (p.hobbies).equipment.name, name(p.hobbies), p.name FROM ONLY person p;
---END---
---START---
SELECT name(equipment(p.hobbies)), name(p.hobbies), p.name FROM person* p;
---END---
---START---
SELECT name(equipment(hobby_construct(text 'skywalking', text 'mer')));
---END---
---START---
SELECT name(equipment(hobby_construct_named(text 'skywalking', text 'mer')));
---END---
---START---
SELECT name(equipment_named(hobby_construct_named(text 'skywalking', text 'mer')));
---END---
---START---
SELECT name(equipment_named_ambiguous_1a(hobby_construct_named(text 'skywalking', text 'mer')));
---END---
---START---
SELECT name(equipment_named_ambiguous_1b(hobby_construct_named(text 'skywalking', text 'mer')));
---END---
---START---
SELECT name(equipment_named_ambiguous_1c(hobby_construct_named(text 'skywalking', text 'mer')));
---END---
---START---
SELECT name(equipment_named_ambiguous_2a(text 'skywalking'));
---END---
---START---
SELECT name(equipment_named_ambiguous_2b(text 'skywalking'));
---END---
---START---
SELECT hobbies_by_name('basketball');
---END---
---START---
SELECT name, overpaid(emp.*) FROM emp;
---END---
---START---
--
-- Try a few cases with SQL-spec row constructor expressions
--
SELECT * FROM equipment(ROW('skywalking', 'mer'));
---END---
---START---
SELECT name(equipment(ROW('skywalking', 'mer')));
---END---
---START---
SELECT *, name(equipment(h.*)) FROM hobbies_r h;
---END---
---START---
SELECT *, (equipment(CAST((h.*) AS hobbies_r))).name FROM hobbies_r h;
---END---
