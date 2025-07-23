---START---
--
-- TEST_SETUP --- prepare environment expected by regression test scripts
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

--
-- synchronous_commit=off delays when hint bits may be set. Some plans change
-- depending on the number of all-visible pages, which in turn can be
-- influenced by the delayed hint bits. Force synchronous_commit=on to avoid
-- that source of variability.
--
SET synchronous_commit = on;
---END---
---START---

--
-- Postgres formerly made the public schema read/write by default,
-- and most of the core regression tests still expect that.
--
GRANT ALL ON SCHEMA public TO public;
---END---
---START---

-- Create a tablespace we can use in tests.
SET allow_in_place_tablespaces = true;
---END---
---START---
CREATE TABLESPACE regress_tblspace LOCATION '';
---END---
---START---

--
-- These tables have traditionally been referenced by many tests,
-- so create and populate them.  Insert only non-error values here.
-- (Some subsequent tests try to insert erroneous values.  That's okay
-- because the table won't actually change.  Do not change the contents
-- of these tables in later tests, as it may affect other tests.)
--

CREATE TABLE CHAR_TBL(f1 char(4));
---END---
---START---

INSERT INTO CHAR_TBL (f1) VALUES
  ('a'),
  ('ab'),
  ('abcd'),
  ('abcd    ');
---END---
---START---
VACUUM CHAR_TBL;
---END---
---START---

CREATE TABLE FLOAT8_TBL(f1 float8);
---END---
---START---

INSERT INTO FLOAT8_TBL(f1) VALUES
  ('0.0'),
  ('-34.84'),
  ('-1004.30'),
  ('-1.2345678901234e+200'),
  ('-1.2345678901234e-200');
---END---
---START---
VACUUM FLOAT8_TBL;
---END---
---START---

CREATE TABLE INT2_TBL(f1 int2);
---END---
---START---

INSERT INTO INT2_TBL(f1) VALUES
  ('0   '),
  ('  1234 '),
  ('    -1234'),
  ('32767'),  -- largest and smallest values
  ('-32767');
---END---
---START---
VACUUM INT2_TBL;
---END---
---START---

CREATE TABLE INT4_TBL(f1 int4);
---END---
---START---

INSERT INTO INT4_TBL(f1) VALUES
  ('   0  '),
  ('123456     '),
  ('    -123456'),
  ('2147483647'),  -- largest and smallest values
  ('-2147483647');
---END---
---START---
VACUUM INT4_TBL;
---END---
---START---

CREATE TABLE INT8_TBL(q1 int8, q2 int8);
---END---
---START---

INSERT INTO INT8_TBL VALUES
  ('  123   ','  456'),
  ('123   ','4567890123456789'),
  ('4567890123456789','123'),
  (+4567890123456789,'4567890123456789'),
  ('+4567890123456789','-4567890123456789');
---END---
---START---
VACUUM INT8_TBL;
---END---
---START---

CREATE TABLE POINT_TBL(f1 point);
---END---
---START---

INSERT INTO POINT_TBL(f1) VALUES
  ('(0.0,0.0)'),
  ('(-10.0,0.0)'),
  ('(-3.0,4.0)'),
  ('(5.1, 34.5)'),
  ('(-5.0,-12.0)'),
  ('(1e-300,-1e-300)'),  -- To underflow
  ('(1e+300,Inf)'),  -- To overflow
  ('(Inf,1e+300)'),  -- Transposed
  (' ( Nan , NaN ) '),
  ('10.0,10.0');
---END---
---START---
-- We intentionally don't vacuum point_tbl here; geometry depends on that

CREATE TABLE TEXT_TBL (f1 text);
---END---
---START---

INSERT INTO TEXT_TBL VALUES
  ('doh!'),
  ('hi de ho neighbor');
---END---
---START---
VACUUM TEXT_TBL;
---END---
---START---

CREATE TABLE VARCHAR_TBL(f1 varchar(4));
---END---
---START---

INSERT INTO VARCHAR_TBL (f1) VALUES
  ('a'),
  ('ab'),
  ('abcd'),
  ('abcd    ');
---END---
---START---
VACUUM VARCHAR_TBL;
---END---
---START---

CREATE TABLE onek (
	unique1		int4,
	unique2		int4,
	two			int4,
	four		int4,
	ten			int4,
	twenty		int4,
	hundred		int4,
	thousand	int4,
	twothousand	int4,
	fivethous	int4,
	tenthous	int4,
	odd			int4,
	even		int4,
	stringu1	name,
	stringu2	name,
	string4		name
);
---END---
---START---

\set filename :abs_srcdir '/data/onek.data'
COPY onek FROM :'filename';
---END---
---START---
VACUUM ANALYZE onek;
---END---
---START---

CREATE TABLE onek2 AS SELECT * FROM onek;
---END---
---START---
VACUUM ANALYZE onek2;
---END---
---START---

CREATE TABLE tenk1 (
	unique1		int4,
	unique2		int4,
	two			int4,
	four		int4,
	ten			int4,
	twenty		int4,
	hundred		int4,
	thousand	int4,
	twothousand	int4,
	fivethous	int4,
	tenthous	int4,
	odd			int4,
	even		int4,
	stringu1	name,
	stringu2	name,
	string4		name
);
---END---
---START---

\set filename :abs_srcdir '/data/tenk.data'
COPY tenk1 FROM :'filename';
---END---
---START---
VACUUM ANALYZE tenk1;
---END---
---START---

CREATE TABLE tenk2 AS SELECT * FROM tenk1;
---END---
---START---
VACUUM ANALYZE tenk2;
---END---
---START---

CREATE TABLE person (
	name 		text,
	age			int4,
	location 	point
);
---END---
---START---

\set filename :abs_srcdir '/data/person.data'
COPY person FROM :'filename';
---END---
---START---
VACUUM ANALYZE person;
---END---
---START---

CREATE TABLE emp (
	salary 		int4,
	manager 	name
) INHERITS (person);
---END---
---START---

\set filename :abs_srcdir '/data/emp.data'
COPY emp FROM :'filename';
---END---
---START---
VACUUM ANALYZE emp;
---END---
---START---

CREATE TABLE student (
	gpa 		float8
) INHERITS (person);
---END---
---START---

\set filename :abs_srcdir '/data/student.data'
COPY student FROM :'filename';
---END---
---START---
VACUUM ANALYZE student;
---END---
---START---

CREATE TABLE stud_emp (
	percent 	int4
) INHERITS (emp, student);
---END---
---START---

\set filename :abs_srcdir '/data/stud_emp.data'
COPY stud_emp FROM :'filename';
---END---
---START---
VACUUM ANALYZE stud_emp;
---END---
---START---

CREATE TABLE road (
	name		text,
	thepath 	path
);
---END---
---START---

\set filename :abs_srcdir '/data/streets.data'
COPY road FROM :'filename';
---END---
---START---
VACUUM ANALYZE road;
---END---
---START---

CREATE TABLE ihighway () INHERITS (road);
---END---
---START---

INSERT INTO ihighway
   SELECT *
   FROM ONLY road
   WHERE name ~ 'I- .*';
---END---
---START---
VACUUM ANALYZE ihighway;
---END---
---START---

CREATE TABLE shighway (
	surface		text
) INHERITS (road);
---END---
---START---

INSERT INTO shighway
   SELECT *, 'asphalt'
   FROM ONLY road
   WHERE name ~ 'State Hwy.*';
---END---
---START---
VACUUM ANALYZE shighway;
---END---
---START---

--
-- We must have some enum type in the database for opr_sanity and type_sanity.
--

create type stoplight as enum ('red', 'yellow', 'green');
---END---
---START---

--
-- Also create some non-built-in range types.
--

create type float8range as range (subtype = float8, subtype_diff = float8mi);
---END---
---START---

create type textrange as range (subtype = text, collation = "C");
---END---
---START---

--
-- Create some C functions that will be used by various tests.
--

CREATE FUNCTION binary_coercible(oid, oid)
    RETURNS bool
    AS :'regresslib', 'binary_coercible'
    LANGUAGE C STRICT STABLE PARALLEL SAFE;
---END---
---START---

CREATE FUNCTION ttdummy ()
    RETURNS trigger
    AS :'regresslib'
    LANGUAGE C;
---END---
---START---

CREATE FUNCTION get_columns_length(oid[])
    RETURNS int
    AS :'regresslib'
    LANGUAGE C STRICT STABLE PARALLEL SAFE;
---END---
---START---

-- Use hand-rolled hash functions and operator classes to get predictable
-- result on different machines.  The hash function for int4 simply returns
-- the sum of the values passed to it and the one for text returns the length
-- of the non-empty string value passed to it or 0.

create function part_hashint4_noop(value int4, seed int8)
    returns int8 as $$
    select value + seed;
---END---
---START---
    $$ language sql strict immutable parallel safe;
---END---
---START---

create operator class part_test_int4_ops for type int4 using hash as
    operator 1 =,
    function 2 part_hashint4_noop(int4, int8);
---END---
---START---

create function part_hashtext_length(value text, seed int8)
    returns int8 as $$
    select length(coalesce(value, ''))::int8
    $$ language sql strict immutable parallel safe;
---END---
---START---

create operator class part_test_text_ops for type text using hash as
    operator 1 =,
    function 2 part_hashtext_length(text, int8);
---END---
---START---

--
-- These functions are used in tests that used to use md5(), which we now
-- mostly avoid so that the tests will pass in FIPS mode.
--

create function fipshash(bytea)
    returns text
    strict immutable parallel safe leakproof
    return substr(encode(sha256($1), 'hex'), 1, 32);
---END---
---START---

create function fipshash(text)
    returns text
    strict immutable parallel safe leakproof
    return substr(encode(sha256($1::bytea), 'hex'), 1, 32);
---END---
