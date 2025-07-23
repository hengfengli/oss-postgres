---START---
CREATE TEMP TABLE x (
	a serial,
	b int,
	c text not null default 'stuff',
	d text,
	e text
) ;
---END---
---START---

CREATE FUNCTION fn_x_before () RETURNS TRIGGER AS '
  BEGIN
		NEW.e := ''before trigger fired''::text;
---END---
---START---
		return NEW;
---END---
---START---
	END;
---END---
---START---
' LANGUAGE plpgsql;
---END---
---START---

CREATE FUNCTION fn_x_after () RETURNS TRIGGER AS '
  BEGIN
		UPDATE x set e=''after trigger fired'' where c=''stuff'';
---END---
---START---
		return NULL;
---END---
---START---
	END;
---END---
---START---
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
---END---
---START---
9999	\N	\\N	\NN	\N
10000	21	31	41	51
\.

COPY x (b, d) from stdin;
---END---
---START---
1	test_1
\.

COPY x (b, d) from stdin;
---END---
---START---
2	test_2
3	test_3
4	test_4
5	test_5
\.

COPY x (a, b, c, d, e) from stdin;
---END---
---START---
10001	22	32	42	52
10002	23	33	43	53
10003	24	34	44	54
10004	25	35	45	55
10005	26	36	46	56
\.

-- non-existent column in column list: should fail
COPY x (xyz) from stdin;
---END---
---START---

-- redundant options
COPY x from stdin (format CSV, FORMAT CSV);
---END---
---START---
COPY x from stdin (freeze off, freeze on);
---END---
---START---
COPY x from stdin (delimiter ',', delimiter ',');
---END---
---START---
COPY x from stdin (null ' ', null ' ');
---END---
---START---
COPY x from stdin (header off, header on);
---END---
---START---
COPY x from stdin (quote ':', quote ':');
---END---
---START---
COPY x from stdin (escape ':', escape ':');
---END---
---START---
COPY x from stdin (force_quote (a), force_quote *);
---END---
---START---
COPY x from stdin (force_not_null (a), force_not_null (b));
---END---
---START---
COPY x from stdin (force_null (a), force_null (b));
---END---
---START---
COPY x from stdin (convert_selectively (a), convert_selectively (b));
---END---
---START---
COPY x from stdin (encoding 'sql_ascii', encoding 'sql_ascii');
---END---
---START---

-- incorrect options
COPY x to stdin (format BINARY, delimiter ',');
---END---
---START---
COPY x to stdin (format BINARY, null 'x');
---END---
---START---
COPY x to stdin (format TEXT, force_quote(a));
---END---
---START---
COPY x from stdin (format CSV, force_quote(a));
---END---
---START---
COPY x to stdout (format TEXT, force_not_null(a));
---END---
---START---
COPY x to stdin (format CSV, force_not_null(a));
---END---
---START---
COPY x to stdout (format TEXT, force_null(a));
---END---
---START---
COPY x to stdin (format CSV, force_null(a));
---END---
---START---

-- too many columns in column list: should fail
COPY x (a, b, c, d, e, d, c) from stdin;
---END---
---START---

-- missing data: should fail
COPY x from stdin;
---END---
---START---

\.
COPY x from stdin;
---END---
---START---
2000	230	23	23
\.
COPY x from stdin;
---END---
---START---
2001	231	\N	\N
\.

-- extra data: should fail
COPY x from stdin;
---END---
---START---
2002	232	40	50	60	70	80
\.

-- various COPY options: delimiters, oids, NULL string, encoding
COPY x (b, c, d, e) from stdin delimiter ',' null 'x';
---END---
---START---
x,45,80,90
x,\x,\\x,\\\x
x,\,,\\\,,\\
\.

COPY x from stdin WITH DELIMITER AS ';' NULL AS '';
---END---
---START---
3000;;c;;
---END---
---START---
\.

COPY x from stdin WITH DELIMITER AS ':' NULL AS E'\\X' ENCODING 'sql_ascii';
---END---
---START---
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

COPY x TO stdout WHERE a = 1;
---END---
---START---
COPY x from stdin WHERE a = 50004;
---END---
---START---
50003	24	34	44	54
50004	25	35	45	55
50005	26	36	46	56
\.

COPY x from stdin WHERE a > 60003;
---END---
---START---
60001	22	32	42	52
60002	23	33	43	53
60003	24	34	44	54
60004	25	35	45	55
60005	26	36	46	56
\.

COPY x from stdin WHERE f > 60003;
---END---
---START---

COPY x from stdin WHERE a = max(x.b);
---END---
---START---

COPY x from stdin WHERE a IN (SELECT 1 FROM x);
---END---
---START---

COPY x from stdin WHERE a IN (generate_series(1,5));
---END---
---START---

COPY x from stdin WHERE a = row_number() over(b);
---END---
---START---


-- check results of copy in
SELECT * FROM x;
---END---
---START---

-- check copy out
COPY x TO stdout;
---END---
---START---
COPY x (c, e) TO stdout;
---END---
---START---
COPY x (b, e) TO stdout WITH NULL 'I''m null';
---END---
---START---

CREATE TEMP TABLE y (
	col1 text,
	col2 text
);
---END---
---START---

INSERT INTO y VALUES ('Jackson, Sam', E'\\h');
---END---
---START---
INSERT INTO y VALUES ('It is "perfect".',E'\t');
---END---
---START---
INSERT INTO y VALUES ('', NULL);
---END---
---START---

COPY y TO stdout WITH CSV;
---END---
---START---
COPY y TO stdout WITH CSV QUOTE '''' DELIMITER '|';
---END---
---START---
COPY y TO stdout WITH CSV FORCE QUOTE col2 ESCAPE E'\\' ENCODING 'sql_ascii';
---END---
---START---
COPY y TO stdout WITH CSV FORCE QUOTE *;
---END---
---START---

-- Repeat above tests with new 9.0 option syntax

COPY y TO stdout (FORMAT CSV);
---END---
---START---
COPY y TO stdout (FORMAT CSV, QUOTE '''', DELIMITER '|');
---END---
---START---
COPY y TO stdout (FORMAT CSV, FORCE_QUOTE (col2), ESCAPE E'\\');
---END---
---START---
COPY y TO stdout (FORMAT CSV, FORCE_QUOTE *);
---END---
---START---

\copy y TO stdout (FORMAT CSV)
\copy y TO stdout (FORMAT CSV, QUOTE '''', DELIMITER '|')
\copy y TO stdout (FORMAT CSV, FORCE_QUOTE (col2), ESCAPE E'\\')
\copy y TO stdout (FORMAT CSV, FORCE_QUOTE *)

--test that we read consecutive LFs properly

CREATE TEMP TABLE testnl (a int, b text, c int);
---END---
---START---

COPY testnl FROM stdin CSV;
---END---
---START---
1,"a field with two LFs

inside",2
\.

-- test end of copy marker
CREATE TEMP TABLE testeoc (a text);
---END---
---START---

COPY testeoc FROM stdin CSV;
---END---
---START---
a\.
\.b
c\.d
"\."
\.

COPY testeoc TO stdout CSV;
---END---
---START---

-- test handling of nonstandard null marker that violates escaping rules

CREATE TEMP TABLE testnull(a int, b text);
---END---
---START---
INSERT INTO testnull VALUES (1, E'\\0'), (NULL, NULL);
---END---
---START---

COPY testnull TO stdout WITH NULL AS E'\\0';
---END---
---START---

COPY testnull FROM stdin WITH NULL AS E'\\0';
---END---
---START---
42	\\0
\0	\0
\.

SELECT * FROM testnull;
---END---
---START---

BEGIN;
---END---
---START---
CREATE TABLE vistest (LIKE testeoc);
---END---
---START---
COPY vistest FROM stdin CSV;
---END---
---START---
a0
b
\.
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
---END---
---START---
a1
b
\.
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
---END---
---START---
d1
e
\.
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
---END---
---START---
a2
b
\.
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
---END---
---START---
d2
e
\.
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
---END---
---START---
x
y
\.
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
---END---
---START---
p
g
\.
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
---END---
---START---
m
k
\.
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
---END---
---START---
d3
e
\.
COMMIT;
---END---
---START---
CREATE FUNCTION truncate_in_subxact() RETURNS VOID AS
$$
BEGIN
	TRUNCATE vistest;
---END---
---START---
EXCEPTION
  WHEN OTHERS THEN
	INSERT INTO vistest VALUES ('subxact failure');
---END---
---START---
END;
---END---
---START---
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
---END---
---START---
d4
e
\.
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
CREATE TEMP TABLE forcetest (
    a INT NOT NULL,
    b TEXT NOT NULL,
    c TEXT,
    d TEXT,
    e TEXT
);
---END---
---START---
\pset null NULL
-- should succeed with no effect ("b" remains an empty string, "c" remains NULL)
BEGIN;
---END---
---START---
COPY forcetest (a, b, c) FROM STDIN WITH (FORMAT csv, FORCE_NOT_NULL(b), FORCE_NULL(c));
---END---
---START---
1,,""
\.
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
---END---
---START---
2,'a',,""
\.
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
---END---
---START---
3,,""
\.
ROLLBACK;
---END---
---START---
-- should fail with "not referenced by COPY" error
BEGIN;
---END---
---START---
COPY forcetest (d, e) FROM STDIN WITH (FORMAT csv, FORCE_NOT_NULL(b));
---END---
---START---
ROLLBACK;
---END---
---START---
-- should fail with "not referenced by COPY" error
BEGIN;
---END---
---START---
COPY forcetest (d, e) FROM STDIN WITH (FORMAT csv, FORCE_NULL(b));
---END---
---START---
ROLLBACK;
---END---
---START---
\pset null ''

-- test case with whole-row Var in a check constraint
create table check_con_tbl (f1 int);
---END---
---START---
create function check_con_function(check_con_tbl) returns bool as $$
begin
  raise notice 'input = %', row_to_json($1);
---END---
---START---
  return $1.f1 > 0;
---END---
---START---
end $$ language plpgsql immutable;
---END---
---START---
alter table check_con_tbl add check (check_con_function(check_con_tbl.*));
---END---
---START---
\d+ check_con_tbl
copy check_con_tbl from stdin;
---END---
---START---
1
\N
\.
copy check_con_tbl from stdin;
---END---
---START---
0
\.
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
CREATE TABLE rls_t1 (a int, b int, c int);
---END---
---START---

COPY rls_t1 (a, b, c) from stdin;
---END---
---START---
1	4	1
2	3	2
3	2	3
4	1	4
\.

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

-- all columns
COPY rls_t1 TO stdout;
---END---
---START---
COPY rls_t1 (a, b, c) TO stdout;
---END---
---START---

-- subset of columns
COPY rls_t1 (a) TO stdout;
---END---
---START---
COPY rls_t1 (a, b) TO stdout;
---END---
---START---

-- column reordering
COPY rls_t1 (b, a) TO stdout;
---END---
---START---

SET SESSION AUTHORIZATION regress_rls_copy_user;
---END---
---START---

-- all columns
COPY rls_t1 TO stdout;
---END---
---START---
COPY rls_t1 (a, b, c) TO stdout;
---END---
---START---

-- subset of columns
COPY rls_t1 (a) TO stdout;
---END---
---START---
COPY rls_t1 (a, b) TO stdout;
---END---
---START---

-- column reordering
COPY rls_t1 (b, a) TO stdout;
---END---
---START---

RESET SESSION AUTHORIZATION;
---END---
---START---

SET SESSION AUTHORIZATION regress_rls_copy_user_colperms;
---END---
---START---

-- attempt all columns (should fail)
COPY rls_t1 TO stdout;
---END---
---START---
COPY rls_t1 (a, b, c) TO stdout;
---END---
---START---

-- try to copy column with no privileges (should fail)
COPY rls_t1 (c) TO stdout;
---END---
---START---

-- subset of columns (should succeed)
COPY rls_t1 (a) TO stdout;
---END---
---START---
COPY rls_t1 (a, b) TO stdout;
---END---
---START---

RESET SESSION AUTHORIZATION;
---END---
---START---

-- test with INSTEAD OF INSERT trigger on a view
CREATE TABLE instead_of_insert_tbl(id serial, name text);
---END---
---START---
CREATE VIEW instead_of_insert_tbl_view AS SELECT ''::text AS str;
---END---
---START---

COPY instead_of_insert_tbl_view FROM stdin; -- fail
test1
\.

CREATE FUNCTION fun_instead_of_insert_tbl() RETURNS trigger AS $$
BEGIN
  INSERT INTO instead_of_insert_tbl (name) VALUES (NEW.str);
---END---
---START---
  RETURN NULL;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER trig_instead_of_insert_tbl_view
  INSTEAD OF INSERT ON instead_of_insert_tbl_view
  FOR EACH ROW EXECUTE PROCEDURE fun_instead_of_insert_tbl();
---END---
---START---

COPY instead_of_insert_tbl_view FROM stdin;
---END---
---START---
test1
\.

SELECT * FROM instead_of_insert_tbl;
---END---
---START---

-- Test of COPY optimization with view using INSTEAD OF INSERT
-- trigger when relation is created in the same transaction as
-- when COPY is executed.
BEGIN;
---END---
---START---
CREATE VIEW instead_of_insert_tbl_view_2 as select ''::text as str;
---END---
---START---
CREATE TRIGGER trig_instead_of_insert_tbl_view_2
  INSTEAD OF INSERT ON instead_of_insert_tbl_view_2
  FOR EACH ROW EXECUTE PROCEDURE fun_instead_of_insert_tbl();
---END---
---START---

COPY instead_of_insert_tbl_view_2 FROM stdin;
---END---
---START---
test1
\.

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

--
-- COPY FROM ... DEFAULT
--

create temp table copy_default (
	id integer primary key,
	text_value text not null default 'test',
	ts_value timestamp without time zone not null default '2022-07-05'
);
---END---
---START---

-- if DEFAULT is not specified, then the marker will be regular data
copy copy_default from stdin;
---END---
---START---
1	value	'2022-07-04'
2	\D	'2022-07-05'
\.

select id, text_value, ts_value from copy_default;
---END---
---START---

truncate copy_default;
---END---
---START---

copy copy_default from stdin with (format csv);
---END---
---START---
1,value,2022-07-04
2,\D,2022-07-05
\.

select id, text_value, ts_value from copy_default;
---END---
---START---

truncate copy_default;
---END---
---START---

-- DEFAULT cannot be used in binary mode
copy copy_default from stdin with (format binary, default '\D');
---END---
---START---

-- DEFAULT cannot be new line nor carriage return
copy copy_default from stdin with (default E'\n');
---END---
---START---
copy copy_default from stdin with (default E'\r');
---END---
---START---

-- DELIMITER cannot appear in DEFAULT spec
copy copy_default from stdin with (delimiter ';', default 'test;test');
---END---
---START---

-- CSV quote cannot appear in DEFAULT spec
copy copy_default from stdin with (format csv, quote '"', default 'test"test');
---END---
---START---

-- NULL and DEFAULT spec must be different
copy copy_default from stdin with (default '\N');
---END---
---START---

-- cannot use DEFAULT marker in column that has no DEFAULT value
copy copy_default from stdin with (default '\D');
---END---
---START---
\D	value	'2022-07-04'
2	\D	'2022-07-05'
\.

copy copy_default from stdin with (format csv, default '\D');
---END---
---START---
\D,value,2022-07-04
2,\D,2022-07-05
\.

-- The DEFAULT marker must be unquoted and unescaped or it's not recognized
copy copy_default from stdin with (default '\D');
---END---
---START---
1	\D	'2022-07-04'
2	\\D	'2022-07-04'
3	"\D"	'2022-07-04'
\.

select id, text_value, ts_value from copy_default;
---END---
---START---

truncate copy_default;
---END---
---START---

copy copy_default from stdin with (format csv, default '\D');
---END---
---START---
1,\D,2022-07-04
2,\\D,2022-07-04
3,"\D",2022-07-04
\.

select id, text_value, ts_value from copy_default;
---END---
---START---

truncate copy_default;
---END---
---START---

-- successful usage of DEFAULT option in COPY
copy copy_default from stdin with (default '\D');
---END---
---START---
1	value	'2022-07-04'
2	\D	'2022-07-03'
3	\D	\D
\.

select id, text_value, ts_value from copy_default;
---END---
---START---

truncate copy_default;
---END---
---START---

copy copy_default from stdin with (format csv, default '\D');
---END---
---START---
1,value,2022-07-04
2,\D,2022-07-03
3,\D,\D
\.

select id, text_value, ts_value from copy_default;
---END---
---START---

truncate copy_default;
---END---
---START---

-- DEFAULT cannot be used in COPY TO
copy (select 1 as test) TO stdout with (default '\D');
---END---
