---START---
DROP TABLE IF EXISTS x;

CREATE TABLE x (gemini_pk serial PRIMARY KEY, a serial, b integer, c text NOT NULL DEFAULT 'stuff', d text, e text);
---END---
---START---
CREATE FUNCTION fn_x_before () RETURNS TRIGGER AS '
  BEGIN
		NEW.e := ''before trigger fired''::text;
		return NEW;
	END;
' LANGUAGE plpgsql;
---END---
---START---
CREATE FUNCTION fn_x_after () RETURNS TRIGGER AS '
  BEGIN
		UPDATE x set e=''after trigger fired'' where c=''stuff'';
		return NULL;
	END;
' LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER trg_x_after AFTER INSERT ON x
FOR EACH ROW EXECUTE PROCEDURE fn_x_after();
---END---
---START---
CREATE TRIGGER trg_x_before BEFORE INSERT ON x
FOR EACH ROW EXECUTE PROCEDURE fn_x_before();
---END---
---START---
COPY x (a, b, c, d, e) from stdin;
9999	\N	\\N	\NN	\N
10000	21	31	41	51
\.
---END---
---START---
COPY x (b, d) from stdin;
1	test_1
\.
---END---
---START---
COPY x (b, d) from stdin;
2	test_2
3	test_3
4	test_4
5	test_5
\.
---END---
---START---
COPY x (a, b, c, d, e) from stdin;
10001	22	32	42	52
10002	23	33	43	53
10003	24	34	44	54
10004	25	35	45	55
10005	26	36	46	56
\.
---END---
---START---
COPY x (xyz) from stdin;

-- redundant options
COPY x from stdin (format CSV, FORMAT CSV);
COPY x from stdin (freeze off, freeze on);
COPY x from stdin (delimiter ',', delimiter ',');
COPY x from stdin (null ' ', null ' ');
COPY x from stdin (header off, header on);
COPY x from stdin (quote ':', quote ':');
COPY x from stdin (escape ':', escape ':');
COPY x from stdin (force_quote (a), force_quote *);
COPY x from stdin (force_not_null (a), force_not_null (b));
COPY x from stdin (force_null (a), force_null (b));
COPY x from stdin (convert_selectively (a), convert_selectively (b));
COPY x from stdin (encoding 'sql_ascii', encoding 'sql_ascii');

-- incorrect options
COPY x to stdin (format BINARY, delimiter ',');
COPY x to stdin (format BINARY, null 'x');
COPY x to stdin (format TEXT, force_quote(a));
COPY x from stdin (format CSV, force_quote(a));
COPY x to stdout (format TEXT, force_not_null(a));
COPY x to stdin (format CSV, force_not_null(a));
COPY x to stdout (format TEXT, force_null(a));
COPY x to stdin (format CSV, force_null(a));

-- too many columns in column list: should fail
COPY x (a, b, c, d, e, d, c) from stdin;

-- missing data: should fail
COPY x from stdin;

\.
---END---
---START---
COPY x from stdin;
2000	230	23	23
\.
---END---
---START---
COPY x from stdin;
2001	231	\N	\N
\.
---END---
---START---
COPY x from stdin;
2002	232	40	50	60	70	80
\.
---END---
---START---
COPY options: delimiters, oids, NULL string, encoding
COPY x (b, c, d, e) from stdin delimiter ',' null 'x';
x,45,80,90
x,\x,\\x,\\\x
x,\,,\\\,,\\
\.
---END---
---START---
COPY x from stdin WITH DELIMITER AS ';' NULL AS '';
3000;;c;;
\.
---END---
---START---
COPY x from stdin WITH DELIMITER AS ':' NULL AS E'\\X' ENCODING 'sql_ascii';
4000:\X:C:\X:\X
4001:1:empty::
4002:2:null:\X:\X
4003:3:Backslash:\\:\\
4004:4:BackslashX:\\X:\\X
4005:5:N:\N:\N
4006:6:BackslashN:\\N:\\N
4007:7:XX:\XX:\XX
4008:8:Delimiter:\::\:
\.
---END---
---START---
COPY x TO stdout WHERE a = 1;
COPY x from stdin WHERE a = 50004;
50003	24	34	44	54
50004	25	35	45	55
50005	26	36	46	56
\.
---END---
---START---
COPY x from stdin WHERE a > 60003;
60001	22	32	42	52
60002	23	33	43	53
60003	24	34	44	54
60004	25	35	45	55
60005	26	36	46	56
\.
---END---
---START---
COPY x from stdin WHERE f > 60003;

COPY x from stdin WHERE a = max(x.b);

COPY x from stdin WHERE a IN (SELECT 1 FROM x);

COPY x from stdin WHERE a IN (generate_series(1,5));

COPY x from stdin WHERE a = row_number() over(b);


-- check results of copy in
SELECT * FROM x;

-- check copy out
COPY x TO stdout;
COPY x (c, e) TO stdout;
COPY x (b, e) TO stdout WITH NULL 'I''m null';

DROP TABLE IF EXISTS y;
CREATE TABLE y (
	col1 text,
	col2 text
);

INSERT INTO y VALUES ('Jackson, Sam', E'\\h');
INSERT INTO y VALUES ('It is "perfect".',E'\t');
INSERT INTO y VALUES ('', NULL);

COPY y TO stdout WITH CSV;
COPY y TO stdout WITH CSV QUOTE '''' DELIMITER '|';
COPY y TO stdout WITH CSV FORCE QUOTE col2 ESCAPE E'\\' ENCODING 'sql_ascii';
COPY y TO stdout WITH CSV FORCE QUOTE *;

-- Repeat above tests with new 9.0 option syntax

COPY y TO stdout (FORMAT CSV);
COPY y TO stdout (FORMAT CSV, QUOTE '''', DELIMITER '|');
COPY y TO stdout (FORMAT CSV, FORCE_QUOTE (col2), ESCAPE E'\\');
COPY y TO stdout (FORMAT CSV, FORCE_QUOTE *);

\copy y TO stdout (FORMAT CSV)
\copy y TO stdout (FORMAT CSV, QUOTE '''', DELIMITER '|')
\copy y TO stdout (FORMAT CSV, FORCE_QUOTE (col2), ESCAPE E'\\')
\copy y TO stdout (FORMAT CSV, FORCE_QUOTE *)

--test that we read consecutive LFs properly

DROP TABLE IF EXISTS testnl;
CREATE TABLE testnl (a int, b text, c int);

COPY testnl FROM stdin CSV;
1,"a field with two LFs

inside",2
\.
---END---
---START---
copy marker
DROP TABLE IF EXISTS testeoc;
CREATE TABLE testeoc (a text);

COPY testeoc FROM stdin CSV;
a\.
\.b
c\.d
"\."
\.
---END---
---START---
COPY testeoc TO stdout CSV;

-- test handling of nonstandard null marker that violates escaping rules

DROP TABLE IF EXISTS testnull;
CREATE TABLE testnull(a int, b text);
INSERT INTO testnull VALUES (1, E'\\0'), (NULL, NULL);

COPY testnull TO stdout WITH NULL AS E'\\0';

COPY testnull FROM stdin WITH NULL AS E'\\0';
42	\\0
\0	\0
\.
---END---
---START---
SELECT * FROM testnull;
---END---
---START---
BEGIN;
---END---
---START---
CREATE TABLE vistest (gemini_pk serial PRIMARY KEY, LIKE testeoc);
---END---
---START---
COPY vistest FROM stdin CSV;
a0
b
\.
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
BEGIN;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
COPY vistest FROM stdin CSV;
a1
b
\.
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
COPY vistest FROM stdin CSV;
d1
e
\.
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
BEGIN;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
a2
b
\.
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
d2
e
\.
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
BEGIN;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
x
y
\.
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
COMMIT;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
p
g
\.
---END---
---START---
BEGIN;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
m
k
\.
---END---
---START---
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO vistest VALUES ('z');
---END---
---START---
SAVEPOINT s1;
---END---
---START---
TRUNCATE vistest;
---END---
---START---
ROLLBACK TO SAVEPOINT s1;
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
d3
e
\.
---END---
---START---
COMMIT;
---END---
---START---
CREATE FUNCTION truncate_in_subxact() RETURNS VOID AS
$$
BEGIN
	TRUNCATE vistest;
EXCEPTION
  WHEN OTHERS THEN
	INSERT INTO vistest VALUES ('subxact failure');
END;
$$ language plpgsql;
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO vistest VALUES ('z');
---END---
---START---
SELECT truncate_in_subxact();
---END---
---START---
COPY vistest FROM stdin CSV FREEZE;
d4
e
\.
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM vistest;
---END---
---START---
-- Test FORCE_NOT_NULL and FORCE_NULL options
DROP TABLE IF EXISTS forcetest;

CREATE TABLE forcetest (gemini_pk serial PRIMARY KEY, a integer NOT NULL, b text NOT NULL, c text, d text, e text);
---END---
---START---
\pset null NULL
-- should succeed with no effect ("b" remains an empty string, "c" remains NULL)
BEGIN;
---END---
---START---
COPY forcetest (a, b, c) FROM STDIN WITH (FORMAT csv, FORCE_NOT_NULL(b), FORCE_NULL(c));
1,,""
\.
---END---
---START---
COMMIT;
---END---
---START---
SELECT b, c FROM forcetest WHERE a = 1;
---END---
---START---
-- should succeed, FORCE_NULL and FORCE_NOT_NULL can be both specified
BEGIN;
---END---
---START---
COPY forcetest (a, b, c, d) FROM STDIN WITH (FORMAT csv, FORCE_NOT_NULL(c,d), FORCE_NULL(c,d));
2,'a',,""
\.
---END---
---START---
COMMIT;
---END---
---START---
SELECT c, d FROM forcetest WHERE a = 2;
---END---
---START---
-- should fail with not-null constraint violation
BEGIN;
---END---
---START---
COPY forcetest (a, b, c) FROM STDIN WITH (FORMAT csv, FORCE_NULL(b), FORCE_NOT_NULL(c));
3,,""
\.
---END---
---START---
ROLLBACK;
---END---
---START---
-- should fail with "not referenced by COPY" error
BEGIN;
---END---
---START---
COPY forcetest (d, e) FROM STDIN WITH (FORMAT csv, FORCE_NOT_NULL(b));
ROLLBACK;
-- should fail with "not referenced by COPY" error
BEGIN;
COPY forcetest (d, e) FROM STDIN WITH (FORMAT csv, FORCE_NULL(b));
ROLLBACK;
\pset null ''

-- test case with whole-row Var in a check constraint
create table check_con_tbl (f1 int);
create function check_con_function(check_con_tbl) returns bool as $$
begin
  raise notice 'input = %', row_to_json($1);
  return $1.f1 > 0;
end $$ language plpgsql immutable;
alter table check_con_tbl add check (check_con_function(check_con_tbl.*));
\d+ check_con_tbl
copy check_con_tbl from stdin;
1
\N
---END---
---START---
copy check_con_tbl from stdin;
0
\.
---END---
---START---
select * from check_con_tbl;
---END---
---START---
-- test with RLS enabled.
CREATE ROLE regress_rls_copy_user;
---END---
---START---
CREATE ROLE regress_rls_copy_user_colperms;
---END---
---START---
CREATE TABLE rls_t1 (gemini_pk serial PRIMARY KEY, a integer, b integer, c integer);
---END---
---START---
COPY rls_t1 (a, b, c) from stdin;
1	4	1
2	3	2
3	2	3
4	1	4
\.
---END---
---START---
CREATE POLICY p1 ON rls_t1 FOR SELECT USING (a % 2 = 0);
---END---
---START---
ALTER TABLE rls_t1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE rls_t1 FORCE ROW LEVEL SECURITY;
---END---
---START---
GRANT SELECT ON TABLE rls_t1 TO regress_rls_copy_user;
---END---
---START---
GRANT SELECT (a, b) ON TABLE rls_t1 TO regress_rls_copy_user_colperms;
---END---
---START---
COPY rls_t1 TO stdout;
COPY rls_t1 (a, b, c) TO stdout;

-- subset of columns
COPY rls_t1 (a) TO stdout;
COPY rls_t1 (a, b) TO stdout;

-- column reordering
COPY rls_t1 (b, a) TO stdout;

SET SESSION AUTHORIZATION regress_rls_copy_user;

-- all columns
COPY rls_t1 TO stdout;
COPY rls_t1 (a, b, c) TO stdout;

-- subset of columns
COPY rls_t1 (a) TO stdout;
COPY rls_t1 (a, b) TO stdout;

-- column reordering
COPY rls_t1 (b, a) TO stdout;

RESET SESSION AUTHORIZATION;

SET SESSION AUTHORIZATION regress_rls_copy_user_colperms;

-- attempt all columns (should fail)
COPY rls_t1 TO stdout;
COPY rls_t1 (a, b, c) TO stdout;

-- try to copy column with no privileges (should fail)
COPY rls_t1 (c) TO stdout;

-- subset of columns (should succeed)
COPY rls_t1 (a) TO stdout;
COPY rls_t1 (a, b) TO stdout;

RESET SESSION AUTHORIZATION;

-- test with INSTEAD OF INSERT trigger on a view
CREATE TABLE instead_of_insert_tbl(id serial, name text);
CREATE VIEW instead_of_insert_tbl_view AS SELECT ''::text AS str;

COPY instead_of_insert_tbl_view FROM stdin; -- fail
test1
\.
---END---
---START---
CREATE FUNCTION fun_instead_of_insert_tbl() RETURNS trigger AS $$
BEGIN
  INSERT INTO instead_of_insert_tbl (name) VALUES (NEW.str);
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER trig_instead_of_insert_tbl_view
  INSTEAD OF INSERT ON instead_of_insert_tbl_view
  FOR EACH ROW EXECUTE PROCEDURE fun_instead_of_insert_tbl();
---END---
---START---
COPY instead_of_insert_tbl_view FROM stdin;
test1
\.
---END---
---START---
SELECT * FROM instead_of_insert_tbl;
---END---
---START---
COPY optimization with view using INSTEAD OF INSERT
-- trigger when relation is created in the same transaction as
-- when COPY is executed.
BEGIN;
CREATE VIEW instead_of_insert_tbl_view_2 as select ''::text as str;
CREATE TRIGGER trig_instead_of_insert_tbl_view_2
  INSTEAD OF INSERT ON instead_of_insert_tbl_view_2
  FOR EACH ROW EXECUTE PROCEDURE fun_instead_of_insert_tbl();

COPY instead_of_insert_tbl_view_2 FROM stdin;
test1
\.
---END---
---START---
SELECT * FROM instead_of_insert_tbl;
---END---
---START---
COMMIT;
---END---
---START---
-- clean up
DROP TABLE forcetest;
---END---
---START---
DROP TABLE vistest;
---END---
---START---
DROP FUNCTION truncate_in_subxact();
---END---
---START---
DROP TABLE x, y;
---END---
---START---
DROP TABLE rls_t1 CASCADE;
---END---
---START---
DROP ROLE regress_rls_copy_user;
---END---
---START---
DROP ROLE regress_rls_copy_user_colperms;
---END---
---START---
DROP FUNCTION fn_x_before();
---END---
---START---
DROP FUNCTION fn_x_after();
---END---
---START---
DROP TABLE instead_of_insert_tbl;
---END---
---START---
DROP VIEW instead_of_insert_tbl_view;
---END---
---START---
DROP VIEW instead_of_insert_tbl_view_2;
---END---
---START---
DROP FUNCTION fun_instead_of_insert_tbl();
---END---
---START---
COPY FROM ... DEFAULT
--

DROP TABLE IF EXISTS copy_default;
create table copy_default (
	id integer primary key,
	text_value text not null default 'test',
	ts_value timestamp without time zone not null default '2022-07-05'
);

-- if DEFAULT is not specified, then the marker will be regular data
copy copy_default from stdin;
1	value	'2022-07-04'
2	\D	'2022-07-05'
\.
---END---
---START---
select id, text_value, ts_value from copy_default;
---END---
---START---
truncate copy_default;
---END---
---START---
copy copy_default from stdin with (format csv);
1,value,2022-07-04
2,\D,2022-07-05
\.
---END---
---START---
select id, text_value, ts_value from copy_default;
---END---
---START---
truncate copy_default;
---END---
---START---
copy copy_default from stdin with (format binary, default '\D');

-- DEFAULT cannot be new line nor carriage return
copy copy_default from stdin with (default E'\n');
copy copy_default from stdin with (default E'\r');

-- DELIMITER cannot appear in DEFAULT spec
copy copy_default from stdin with (delimiter ';', default 'test;test');

-- CSV quote cannot appear in DEFAULT spec
copy copy_default from stdin with (format csv, quote '"', default 'test"test');

-- NULL and DEFAULT spec must be different
copy copy_default from stdin with (default '\N');

-- cannot use DEFAULT marker in column that has no DEFAULT value
copy copy_default from stdin with (default '\D');
\D	value	'2022-07-04'
2	\D	'2022-07-05'
\.
---END---
---START---
copy copy_default from stdin with (format csv, default '\D');
\D,value,2022-07-04
2,\D,2022-07-05
\.
---END---
---START---
copy copy_default from stdin with (default '\D');
1	\D	'2022-07-04'
2	\\D	'2022-07-04'
3	"\D"	'2022-07-04'
\.
---END---
---START---
select id, text_value, ts_value from copy_default;
---END---
---START---
truncate copy_default;
---END---
---START---
copy copy_default from stdin with (format csv, default '\D');
1,\D,2022-07-04
2,\\D,2022-07-04
3,"\D",2022-07-04
\.
---END---
---START---
select id, text_value, ts_value from copy_default;
---END---
---START---
truncate copy_default;
---END---
---START---
copy copy_default from stdin with (default '\D');
1	value	'2022-07-04'
2	\D	'2022-07-03'
3	\D	\D
\.
---END---
---START---
select id, text_value, ts_value from copy_default;
---END---
---START---
truncate copy_default;
---END---
---START---
copy copy_default from stdin with (format csv, default '\D');
1,value,2022-07-04
2,\D,2022-07-03
3,\D,\D
\.
---END---
---START---
select id, text_value, ts_value from copy_default;
---END---
---START---
truncate copy_default;
---END---
---START---
-- DEFAULT cannot be used in COPY TO
copy (select 1 as test) TO stdout with (default '\D');
---END---
