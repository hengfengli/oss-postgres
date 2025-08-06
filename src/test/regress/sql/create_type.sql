---START---
--
-- CREATE_TYPE
--

-- directory path and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

--
-- Test the "old style" approach of making the I/O functions first,
-- with no explicit shell type creation.
--
CREATE FUNCTION widget_in(cstring)
   RETURNS widget
   AS :'regresslib'
   LANGUAGE C STRICT IMMUTABLE;
---END---
---START---

CREATE FUNCTION widget_out(widget)
   RETURNS cstring
   AS :'regresslib'
   LANGUAGE C STRICT IMMUTABLE;
---END---
---START---

CREATE FUNCTION int44in(cstring)
   RETURNS city_budget
   AS :'regresslib'
   LANGUAGE C STRICT IMMUTABLE;
---END---
---START---

CREATE FUNCTION int44out(city_budget)
   RETURNS cstring
   AS :'regresslib'
   LANGUAGE C STRICT IMMUTABLE;
---END---
---START---

CREATE TYPE widget (
   internallength = 24,
   input = widget_in,
   output = widget_out,
   typmod_in = numerictypmodin,
   typmod_out = numerictypmodout,
   alignment = double
);
---END---
---START---

CREATE TYPE city_budget (
   internallength = 16,
   input = int44in,
   output = int44out,
   element = int4,
   category = 'x',   -- just to verify the system will take it
   preferred = true  -- ditto
);
---END---
---START---

-- Test creation and destruction of shell types
CREATE TYPE shell;
---END---
---START---
CREATE TYPE shell;   -- fail, type already present
DROP TYPE shell;
---END---
---START---
DROP TYPE shell;     -- fail, type not exist

-- also, let's leave one around for purposes of pg_dump testing
CREATE TYPE myshell;
---END---
---START---

--
-- Test type-related default values (broken in releases before PG 7.2)
--
-- This part of the test also exercises the "new style" approach of making
-- a shell type and then filling it in.
--
CREATE TYPE int42;
---END---
---START---
CREATE TYPE text_w_default;
---END---
---START---

-- Make dummy I/O routines using the existing internal support for int4, text
CREATE FUNCTION int42_in(cstring)
   RETURNS int42
   AS 'int4in'
   LANGUAGE internal STRICT IMMUTABLE;
---END---
---START---
CREATE FUNCTION int42_out(int42)
   RETURNS cstring
   AS 'int4out'
   LANGUAGE internal STRICT IMMUTABLE;
---END---
---START---
CREATE FUNCTION text_w_default_in(cstring)
   RETURNS text_w_default
   AS 'textin'
   LANGUAGE internal STRICT IMMUTABLE;
---END---
---START---
CREATE FUNCTION text_w_default_out(text_w_default)
   RETURNS cstring
   AS 'textout'
   LANGUAGE internal STRICT IMMUTABLE;
---END---
---START---

CREATE TYPE int42 (
   internallength = 4,
   input = int42_in,
   output = int42_out,
   alignment = int4,
   default = 42,
   passedbyvalue
);
---END---
---START---

CREATE TYPE text_w_default (
   internallength = variable,
   input = text_w_default_in,
   output = text_w_default_out,
   alignment = int4,
   default = 'zippo'
);
---END---
---START---

CREATE TABLE default_test (f1 text_w_default, f2 int42);
---END---
---START---

INSERT INTO default_test DEFAULT VALUES;
---END---
---START---

SELECT * FROM default_test;
---END---
---START---

-- We need a shell type to test some CREATE TYPE failure cases with
CREATE TYPE bogus_type;
---END---
---START---

-- invalid: non-lowercase quoted identifiers
CREATE TYPE bogus_type (
	"Internallength" = 4,
	"Input" = int42_in,
	"Output" = int42_out,
	"Alignment" = int4,
	"Default" = 42,
	"Passedbyvalue"
);
---END---
---START---

-- invalid: input/output function incompatibility
CREATE TYPE bogus_type (INPUT = array_in,
    OUTPUT = array_out,
    ELEMENT = int,
    INTERNALLENGTH = 32);
---END---
---START---

DROP TYPE bogus_type;
---END---
---START---

-- It no longer is possible to issue CREATE TYPE without making a shell first
CREATE TYPE bogus_type (INPUT = array_in,
    OUTPUT = array_out,
    ELEMENT = int,
    INTERNALLENGTH = 32);
---END---
---START---

-- Test stand-alone composite type

CREATE TYPE default_test_row AS (f1 text_w_default, f2 int42);
---END---
---START---

CREATE FUNCTION get_default_test() RETURNS SETOF default_test_row AS '
  SELECT * FROM default_test;
---END---
---START---
' LANGUAGE SQL;
---END---
---START---

SELECT * FROM get_default_test();
---END---
---START---

-- Test comments
COMMENT ON TYPE bad IS 'bad comment';
---END---
---START---
COMMENT ON TYPE default_test_row IS 'good comment';
---END---
---START---
COMMENT ON TYPE default_test_row IS NULL;
---END---
---START---
COMMENT ON COLUMN default_test_row.nope IS 'bad comment';
---END---
---START---
COMMENT ON COLUMN default_test_row.f1 IS 'good comment';
---END---
---START---
COMMENT ON COLUMN default_test_row.f1 IS NULL;
---END---
---START---

-- Check shell type create for existing types
CREATE TYPE text_w_default;		-- should fail

DROP TYPE default_test_row CASCADE;
---END---
---START---

DROP TABLE default_test;
---END---
---START---

-- Check dependencies are established when creating a new type
CREATE TYPE base_type;
---END---
---START---
CREATE FUNCTION base_fn_in(cstring) RETURNS base_type AS 'boolin'
    LANGUAGE internal IMMUTABLE STRICT;
---END---
---START---
CREATE FUNCTION base_fn_out(base_type) RETURNS cstring AS 'boolout'
    LANGUAGE internal IMMUTABLE STRICT;
---END---
---START---
CREATE TYPE base_type(INPUT = base_fn_in, OUTPUT = base_fn_out);
---END---
---START---
DROP FUNCTION base_fn_in(cstring); -- error
DROP FUNCTION base_fn_out(base_type); -- error
DROP TYPE base_type; -- error
DROP TYPE base_type CASCADE;
---END---
---START---

-- Check usage of typmod with a user-defined type
-- (we have borrowed numeric's typmod functions)

CREATE TABLE mytab (foo widget(42,13,7));     -- should fail
CREATE TABLE mytab (foo widget(42,13));
---END---
---START---

SELECT format_type(atttypid,atttypmod) FROM pg_attribute
WHERE attrelid = 'mytab'::regclass AND attnum > 0;
---END---
---START---

-- might as well exercise the widget type while we're here
INSERT INTO mytab VALUES ('(1,2,3)'), ('(-44,5.5,12)');
---END---
---START---
TABLE mytab;
---END---
---START---

-- and test format_type() a bit more, too
select format_type('varchar'::regtype, 42);
---END---
---START---
select format_type('bpchar'::regtype, null);
---END---
---START---
-- this behavior difference is intentional
select format_type('bpchar'::regtype, -1);
---END---
---START---

-- Test non-error-throwing APIs using widget, which still throws errors
SELECT pg_input_is_valid('(1,2,3)', 'widget');
---END---
---START---
SELECT pg_input_is_valid('(1,2)', 'widget');  -- hard error expected
SELECT pg_input_is_valid('{"(1,2,3)"}', 'widget[]');
---END---
---START---
SELECT pg_input_is_valid('{"(1,2)"}', 'widget[]');  -- hard error expected
SELECT pg_input_is_valid('("(1,2,3)")', 'mytab');
---END---
---START---
SELECT pg_input_is_valid('("(1,2)")', 'mytab');  -- hard error expected

-- Test creation of an operator over a user-defined type

CREATE FUNCTION pt_in_widget(point, widget)
   RETURNS bool
   AS :'regresslib'
   LANGUAGE C STRICT;
---END---
---START---

CREATE OPERATOR <% (
   leftarg = point,
   rightarg = widget,
   procedure = pt_in_widget,
   commutator = >% ,
   negator = >=%
);
---END---
---START---

SELECT point '(1,2)' <% widget '(0,0,3)' AS t,
       point '(1,2)' <% widget '(0,0,1)' AS f;
---END---
---START---

-- exercise city_budget type
CREATE TABLE city (
	name		name,
	location 	box,
	budget 		city_budget
);
---END---
---START---

INSERT INTO city VALUES
('Podunk', '(1,2),(3,4)', '100,127,1000'),
('Gotham', '(1000,34),(1100,334)', '123456,127,-1000,6789');
---END---
---START---

TABLE city;
---END---
---START---

--
-- Test CREATE/ALTER TYPE using a type that's compatible with varchar,
-- so we can re-use those support functions
--
CREATE TYPE myvarchar;
---END---
---START---

CREATE FUNCTION myvarcharin(cstring, oid, integer) RETURNS myvarchar
LANGUAGE internal IMMUTABLE PARALLEL SAFE STRICT AS 'varcharin';
---END---
---START---

CREATE FUNCTION myvarcharout(myvarchar) RETURNS cstring
LANGUAGE internal IMMUTABLE PARALLEL SAFE STRICT AS 'varcharout';
---END---
---START---

CREATE FUNCTION myvarcharsend(myvarchar) RETURNS bytea
LANGUAGE internal STABLE PARALLEL SAFE STRICT AS 'varcharsend';
---END---
---START---

CREATE FUNCTION myvarcharrecv(internal, oid, integer) RETURNS myvarchar
LANGUAGE internal STABLE PARALLEL SAFE STRICT AS 'varcharrecv';
---END---
---START---

-- fail, it's still a shell:
ALTER TYPE myvarchar SET (storage = extended);
---END---
---START---

CREATE TYPE myvarchar (
    input = myvarcharin,
    output = myvarcharout,
    alignment = integer,
    storage = main
);
---END---
---START---

-- want to check updating of a domain over the target type, too
CREATE DOMAIN myvarchardom AS myvarchar;
---END---
---START---

ALTER TYPE myvarchar SET (storage = plain);  -- not allowed

ALTER TYPE myvarchar SET (storage = extended);
---END---
---START---

ALTER TYPE myvarchar SET (
    send = myvarcharsend,
    receive = myvarcharrecv,
    typmod_in = varchartypmodin,
    typmod_out = varchartypmodout,
    -- these are bogus, but it's safe as long as we don't use the type:
    analyze = ts_typanalyze,
    subscript = raw_array_subscript_handler
);
---END---
---START---

SELECT typinput, typoutput, typreceive, typsend, typmodin, typmodout,
       typanalyze, typsubscript, typstorage
FROM pg_type WHERE typname = 'myvarchar';
---END---
---START---

SELECT typinput, typoutput, typreceive, typsend, typmodin, typmodout,
       typanalyze, typsubscript, typstorage
FROM pg_type WHERE typname = '_myvarchar';
---END---
---START---

SELECT typinput, typoutput, typreceive, typsend, typmodin, typmodout,
       typanalyze, typsubscript, typstorage
FROM pg_type WHERE typname = 'myvarchardom';
---END---
---START---

SELECT typinput, typoutput, typreceive, typsend, typmodin, typmodout,
       typanalyze, typsubscript, typstorage
FROM pg_type WHERE typname = '_myvarchardom';
---END---
---START---

-- ensure dependencies are straight
DROP FUNCTION myvarcharsend(myvarchar);  -- fail
DROP TYPE myvarchar;  -- fail

DROP TYPE myvarchar CASCADE;

drop table mytab;
---END---
