---START---
--
-- Test for ALTER some_object {RENAME TO, OWNER TO, SET SCHEMA}
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

CREATE FUNCTION test_opclass_options_func(internal)
    RETURNS void
    AS :'regresslib', 'test_opclass_options_func'
    LANGUAGE C;
---END---
---START---

-- Clean up in case a prior regression run failed
SET client_min_messages TO 'warning';
---END---
---START---

DROP ROLE IF EXISTS regress_alter_generic_user1;
---END---
---START---
DROP ROLE IF EXISTS regress_alter_generic_user2;
---END---
---START---
DROP ROLE IF EXISTS regress_alter_generic_user3;
---END---
---START---

RESET client_min_messages;
---END---
---START---

CREATE USER regress_alter_generic_user3;
---END---
---START---
CREATE USER regress_alter_generic_user2;
---END---
---START---
CREATE USER regress_alter_generic_user1 IN ROLE regress_alter_generic_user3;
---END---
---START---

CREATE SCHEMA alt_nsp1;
---END---
---START---
CREATE SCHEMA alt_nsp2;
---END---
---START---

GRANT ALL ON SCHEMA alt_nsp1, alt_nsp2 TO public;
---END---
---START---

SET search_path = alt_nsp1, public;
---END---
---START---

--
-- Function and Aggregate
--
SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---
CREATE FUNCTION alt_func1(int) RETURNS int LANGUAGE sql
  AS 'SELECT $1 + 1';
---END---
---START---
CREATE FUNCTION alt_func2(int) RETURNS int LANGUAGE sql
  AS 'SELECT $1 - 1';
---END---
---START---
CREATE AGGREGATE alt_agg1 (
  sfunc1 = int4pl, basetype = int4, stype1 = int4, initcond = 0
);
---END---
---START---
CREATE AGGREGATE alt_agg2 (
  sfunc1 = int4mi, basetype = int4, stype1 = int4, initcond = 0
);
---END---
---START---
ALTER AGGREGATE alt_func1(int) RENAME TO alt_func3;  -- failed (not aggregate)
ALTER AGGREGATE alt_func1(int) OWNER TO regress_alter_generic_user3;  -- failed (not aggregate)
ALTER AGGREGATE alt_func1(int) SET SCHEMA alt_nsp2;  -- failed (not aggregate)

ALTER FUNCTION alt_func1(int) RENAME TO alt_func2;  -- failed (name conflict)
ALTER FUNCTION alt_func1(int) RENAME TO alt_func3;  -- OK
ALTER FUNCTION alt_func2(int) OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER FUNCTION alt_func2(int) OWNER TO regress_alter_generic_user3;  -- OK
ALTER FUNCTION alt_func2(int) SET SCHEMA alt_nsp1;  -- OK, already there
ALTER FUNCTION alt_func2(int) SET SCHEMA alt_nsp2;  -- OK

ALTER AGGREGATE alt_agg1(int) RENAME TO alt_agg2;   -- failed (name conflict)
ALTER AGGREGATE alt_agg1(int) RENAME TO alt_agg3;   -- OK
ALTER AGGREGATE alt_agg2(int) OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER AGGREGATE alt_agg2(int) OWNER TO regress_alter_generic_user3;  -- OK
ALTER AGGREGATE alt_agg2(int) SET SCHEMA alt_nsp2;  -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---
CREATE FUNCTION alt_func1(int) RETURNS int LANGUAGE sql
  AS 'SELECT $1 + 2';
---END---
---START---
CREATE FUNCTION alt_func2(int) RETURNS int LANGUAGE sql
  AS 'SELECT $1 - 2';
---END---
---START---
CREATE AGGREGATE alt_agg1 (
  sfunc1 = int4pl, basetype = int4, stype1 = int4, initcond = 100
);
---END---
---START---
CREATE AGGREGATE alt_agg2 (
  sfunc1 = int4mi, basetype = int4, stype1 = int4, initcond = -100
);
---END---
---START---

ALTER FUNCTION alt_func3(int) RENAME TO alt_func4;	-- failed (not owner)
ALTER FUNCTION alt_func1(int) RENAME TO alt_func4;	-- OK
ALTER FUNCTION alt_func3(int) OWNER TO regress_alter_generic_user2;	-- failed (not owner)
ALTER FUNCTION alt_func2(int) OWNER TO regress_alter_generic_user3;	-- failed (no role membership)
ALTER FUNCTION alt_func3(int) SET SCHEMA alt_nsp2;      -- failed (not owner)
ALTER FUNCTION alt_func2(int) SET SCHEMA alt_nsp2;	-- failed (name conflicts)

ALTER AGGREGATE alt_agg3(int) RENAME TO alt_agg4;   -- failed (not owner)
ALTER AGGREGATE alt_agg1(int) RENAME TO alt_agg4;   -- OK
ALTER AGGREGATE alt_agg3(int) OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER AGGREGATE alt_agg2(int) OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER AGGREGATE alt_agg3(int) SET SCHEMA alt_nsp2;  -- failed (not owner)
ALTER AGGREGATE alt_agg2(int) SET SCHEMA alt_nsp2;  -- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---

SELECT n.nspname, proname, prorettype::regtype, prokind, a.rolname
  FROM pg_proc p, pg_namespace n, pg_authid a
  WHERE p.pronamespace = n.oid AND p.proowner = a.oid
    AND n.nspname IN ('alt_nsp1', 'alt_nsp2')
  ORDER BY nspname, proname;
---END---
---START---

--
-- We would test collations here, but it's not possible because the error
-- messages tend to be nonportable.
--

--
-- Conversion
--
SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---
CREATE CONVERSION alt_conv1 FOR 'LATIN1' TO 'UTF8' FROM iso8859_1_to_utf8;
---END---
---START---
CREATE CONVERSION alt_conv2 FOR 'LATIN1' TO 'UTF8' FROM iso8859_1_to_utf8;
---END---
---START---

ALTER CONVERSION alt_conv1 RENAME TO alt_conv2;  -- failed (name conflict)
ALTER CONVERSION alt_conv1 RENAME TO alt_conv3;  -- OK
ALTER CONVERSION alt_conv2 OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER CONVERSION alt_conv2 OWNER TO regress_alter_generic_user3;  -- OK
ALTER CONVERSION alt_conv2 SET SCHEMA alt_nsp2;  -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---
CREATE CONVERSION alt_conv1 FOR 'LATIN1' TO 'UTF8' FROM iso8859_1_to_utf8;
---END---
---START---
CREATE CONVERSION alt_conv2 FOR 'LATIN1' TO 'UTF8' FROM iso8859_1_to_utf8;
---END---
---START---

ALTER CONVERSION alt_conv3 RENAME TO alt_conv4;  -- failed (not owner)
ALTER CONVERSION alt_conv1 RENAME TO alt_conv4;  -- OK
ALTER CONVERSION alt_conv3 OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER CONVERSION alt_conv2 OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER CONVERSION alt_conv3 SET SCHEMA alt_nsp2;  -- failed (not owner)
ALTER CONVERSION alt_conv2 SET SCHEMA alt_nsp2;  -- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---

SELECT n.nspname, c.conname, a.rolname
  FROM pg_conversion c, pg_namespace n, pg_authid a
  WHERE c.connamespace = n.oid AND c.conowner = a.oid
    AND n.nspname IN ('alt_nsp1', 'alt_nsp2')
  ORDER BY nspname, conname;
---END---
---START---

--
-- Foreign Data Wrapper and Foreign Server
--
CREATE FOREIGN DATA WRAPPER alt_fdw1;
---END---
---START---
CREATE FOREIGN DATA WRAPPER alt_fdw2;
---END---
---START---

CREATE SERVER alt_fserv1 FOREIGN DATA WRAPPER alt_fdw1;
---END---
---START---
CREATE SERVER alt_fserv2 FOREIGN DATA WRAPPER alt_fdw2;
---END---
---START---

ALTER FOREIGN DATA WRAPPER alt_fdw1 RENAME TO alt_fdw2;  -- failed (name conflict)
ALTER FOREIGN DATA WRAPPER alt_fdw1 RENAME TO alt_fdw3;  -- OK

ALTER SERVER alt_fserv1 RENAME TO alt_fserv2;   -- failed (name conflict)
ALTER SERVER alt_fserv1 RENAME TO alt_fserv3;   -- OK

SELECT fdwname FROM pg_foreign_data_wrapper WHERE fdwname like 'alt_fdw%';
---END---
---START---
SELECT srvname FROM pg_foreign_server WHERE srvname like 'alt_fserv%';
---END---
---START---

--
-- Procedural Language
--
CREATE LANGUAGE alt_lang1 HANDLER plpgsql_call_handler;
---END---
---START---
CREATE LANGUAGE alt_lang2 HANDLER plpgsql_call_handler;
---END---
---START---

ALTER LANGUAGE alt_lang1 OWNER TO regress_alter_generic_user1;  -- OK
ALTER LANGUAGE alt_lang2 OWNER TO regress_alter_generic_user2;  -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---
ALTER LANGUAGE alt_lang1 RENAME TO alt_lang2;   -- failed (name conflict)
ALTER LANGUAGE alt_lang2 RENAME TO alt_lang3;   -- failed (not owner)
ALTER LANGUAGE alt_lang1 RENAME TO alt_lang3;   -- OK

ALTER LANGUAGE alt_lang2 OWNER TO regress_alter_generic_user3;  -- failed (not owner)
ALTER LANGUAGE alt_lang3 OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER LANGUAGE alt_lang3 OWNER TO regress_alter_generic_user3;  -- OK

RESET SESSION AUTHORIZATION;
---END---
---START---
SELECT lanname, a.rolname
  FROM pg_language l, pg_authid a
  WHERE l.lanowner = a.oid AND l.lanname like 'alt_lang%'
  ORDER BY lanname;
---END---
---START---

--
-- Operator
--
SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---

CREATE OPERATOR @-@ ( leftarg = int4, rightarg = int4, procedure = int4mi );
---END---
---START---
CREATE OPERATOR @+@ ( leftarg = int4, rightarg = int4, procedure = int4pl );
---END---
---START---

ALTER OPERATOR @+@(int4, int4) OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER OPERATOR @+@(int4, int4) OWNER TO regress_alter_generic_user3;  -- OK
ALTER OPERATOR @-@(int4, int4) SET SCHEMA alt_nsp2;           -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---

CREATE OPERATOR @-@ ( leftarg = int4, rightarg = int4, procedure = int4mi );
---END---
---START---

ALTER OPERATOR @+@(int4, int4) OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER OPERATOR @-@(int4, int4) OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER OPERATOR @+@(int4, int4) SET SCHEMA alt_nsp2;   -- failed (not owner)
-- can't test this: the error message includes the raw oid of namespace
-- ALTER OPERATOR @-@(int4, int4) SET SCHEMA alt_nsp2;   -- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---

SELECT n.nspname, oprname, a.rolname,
    oprleft::regtype, oprright::regtype, oprcode::regproc
  FROM pg_operator o, pg_namespace n, pg_authid a
  WHERE o.oprnamespace = n.oid AND o.oprowner = a.oid
    AND n.nspname IN ('alt_nsp1', 'alt_nsp2')
  ORDER BY nspname, oprname;
---END---
---START---

--
-- OpFamily and OpClass
--
CREATE OPERATOR FAMILY alt_opf1 USING hash;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf2 USING hash;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf1 USING hash OWNER TO regress_alter_generic_user1;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf2 USING hash OWNER TO regress_alter_generic_user1;
---END---
---START---

CREATE OPERATOR CLASS alt_opc1 FOR TYPE uuid USING hash AS STORAGE uuid;
---END---
---START---
CREATE OPERATOR CLASS alt_opc2 FOR TYPE uuid USING hash AS STORAGE uuid;
---END---
---START---
ALTER OPERATOR CLASS alt_opc1 USING hash OWNER TO regress_alter_generic_user1;
---END---
---START---
ALTER OPERATOR CLASS alt_opc2 USING hash OWNER TO regress_alter_generic_user1;
---END---
---START---

SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---

ALTER OPERATOR FAMILY alt_opf1 USING hash RENAME TO alt_opf2;  -- failed (name conflict)
ALTER OPERATOR FAMILY alt_opf1 USING hash RENAME TO alt_opf3;  -- OK
ALTER OPERATOR FAMILY alt_opf2 USING hash OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER OPERATOR FAMILY alt_opf2 USING hash OWNER TO regress_alter_generic_user3;  -- OK
ALTER OPERATOR FAMILY alt_opf2 USING hash SET SCHEMA alt_nsp2;  -- OK

ALTER OPERATOR CLASS alt_opc1 USING hash RENAME TO alt_opc2;  -- failed (name conflict)
ALTER OPERATOR CLASS alt_opc1 USING hash RENAME TO alt_opc3;  -- OK
ALTER OPERATOR CLASS alt_opc2 USING hash OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER OPERATOR CLASS alt_opc2 USING hash OWNER TO regress_alter_generic_user3;  -- OK
ALTER OPERATOR CLASS alt_opc2 USING hash SET SCHEMA alt_nsp2;  -- OK

RESET SESSION AUTHORIZATION;
---END---
---START---

CREATE OPERATOR FAMILY alt_opf1 USING hash;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf2 USING hash;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf1 USING hash OWNER TO regress_alter_generic_user2;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf2 USING hash OWNER TO regress_alter_generic_user2;
---END---
---START---

CREATE OPERATOR CLASS alt_opc1 FOR TYPE macaddr USING hash AS STORAGE macaddr;
---END---
---START---
CREATE OPERATOR CLASS alt_opc2 FOR TYPE macaddr USING hash AS STORAGE macaddr;
---END---
---START---
ALTER OPERATOR CLASS alt_opc1 USING hash OWNER TO regress_alter_generic_user2;
---END---
---START---
ALTER OPERATOR CLASS alt_opc2 USING hash OWNER TO regress_alter_generic_user2;
---END---
---START---

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---

ALTER OPERATOR FAMILY alt_opf3 USING hash RENAME TO alt_opf4;	-- failed (not owner)
ALTER OPERATOR FAMILY alt_opf1 USING hash RENAME TO alt_opf4;  -- OK
ALTER OPERATOR FAMILY alt_opf3 USING hash OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER OPERATOR FAMILY alt_opf2 USING hash OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER OPERATOR FAMILY alt_opf3 USING hash SET SCHEMA alt_nsp2;  -- failed (not owner)
ALTER OPERATOR FAMILY alt_opf2 USING hash SET SCHEMA alt_nsp2;  -- failed (name conflict)

ALTER OPERATOR CLASS alt_opc3 USING hash RENAME TO alt_opc4;	-- failed (not owner)
ALTER OPERATOR CLASS alt_opc1 USING hash RENAME TO alt_opc4;  -- OK
ALTER OPERATOR CLASS alt_opc3 USING hash OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER OPERATOR CLASS alt_opc2 USING hash OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER OPERATOR CLASS alt_opc3 USING hash SET SCHEMA alt_nsp2;  -- failed (not owner)
ALTER OPERATOR CLASS alt_opc2 USING hash SET SCHEMA alt_nsp2;  -- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---

SELECT nspname, opfname, amname, rolname
  FROM pg_opfamily o, pg_am m, pg_namespace n, pg_authid a
  WHERE o.opfmethod = m.oid AND o.opfnamespace = n.oid AND o.opfowner = a.oid
    AND n.nspname IN ('alt_nsp1', 'alt_nsp2')
	AND NOT opfname LIKE 'alt_opc%'
  ORDER BY nspname, opfname;
---END---
---START---

SELECT nspname, opcname, amname, rolname
  FROM pg_opclass o, pg_am m, pg_namespace n, pg_authid a
  WHERE o.opcmethod = m.oid AND o.opcnamespace = n.oid AND o.opcowner = a.oid
    AND n.nspname IN ('alt_nsp1', 'alt_nsp2')
  ORDER BY nspname, opcname;
---END---
---START---

-- ALTER OPERATOR FAMILY ... ADD/DROP

-- Should work. Textbook case of CREATE / ALTER ADD / ALTER DROP / DROP
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf4 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD
  -- int4 vs int2
  OPERATOR 1 < (int4, int2) ,
  OPERATOR 2 <= (int4, int2) ,
  OPERATOR 3 = (int4, int2) ,
  OPERATOR 4 >= (int4, int2) ,
  OPERATOR 5 > (int4, int2) ,
  FUNCTION 1 btint42cmp(int4, int2);
---END---
---START---

ALTER OPERATOR FAMILY alt_opf4 USING btree DROP
  -- int4 vs int2
  OPERATOR 1 (int4, int2) ,
  OPERATOR 2 (int4, int2) ,
  OPERATOR 3 (int4, int2) ,
  OPERATOR 4 (int4, int2) ,
  OPERATOR 5 (int4, int2) ,
  FUNCTION 1 (int4, int2) ;
---END---
---START---
DROP OPERATOR FAMILY alt_opf4 USING btree;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. Invalid values for ALTER OPERATOR FAMILY .. ADD / DROP
CREATE OPERATOR FAMILY alt_opf4 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf4 USING invalid_index_method ADD  OPERATOR 1 < (int4, int2); -- invalid indexing_method
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD OPERATOR 6 < (int4, int2); -- operator number should be between 1 and 5
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD OPERATOR 0 < (int4, int2); -- operator number should be between 1 and 5
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD OPERATOR 1 < ; -- operator without argument types
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD FUNCTION 0 btint42cmp(int4, int2); -- invalid options parsing function
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD FUNCTION 6 btint42cmp(int4, int2); -- function number should be between 1 and 5
ALTER OPERATOR FAMILY alt_opf4 USING btree ADD STORAGE invalid_storage; -- Ensure STORAGE is not a part of ALTER OPERATOR FAMILY
DROP OPERATOR FAMILY alt_opf4 USING btree;
---END---
---START---

-- Should fail. Need to be SUPERUSER to do ALTER OPERATOR FAMILY .. ADD / DROP
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_alter_generic_user5 NOSUPERUSER;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf5 USING btree;
---END---
---START---
SET ROLE regress_alter_generic_user5;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf5 USING btree ADD OPERATOR 1 < (int4, int2), FUNCTION 1 btint42cmp(int4, int2);
---END---
---START---
RESET ROLE;
---END---
---START---
DROP OPERATOR FAMILY alt_opf5 USING btree;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. Need rights to namespace for ALTER OPERATOR FAMILY .. ADD / DROP
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_alter_generic_user6;
---END---
---START---
CREATE SCHEMA alt_nsp6;
---END---
---START---
REVOKE ALL ON SCHEMA alt_nsp6 FROM regress_alter_generic_user6;
---END---
---START---
CREATE OPERATOR FAMILY alt_nsp6.alt_opf6 USING btree;
---END---
---START---
SET ROLE regress_alter_generic_user6;
---END---
---START---
ALTER OPERATOR FAMILY alt_nsp6.alt_opf6 USING btree ADD OPERATOR 1 < (int4, int2);
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. Only two arguments required for ALTER OPERATOR FAMILY ... DROP OPERATOR
CREATE OPERATOR FAMILY alt_opf7 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf7 USING btree ADD OPERATOR 1 < (int4, int2);
---END---
---START---
ALTER OPERATOR FAMILY alt_opf7 USING btree DROP OPERATOR 1 (int4, int2, int8);
---END---
---START---
DROP OPERATOR FAMILY alt_opf7 USING btree;
---END---
---START---

-- Should work. During ALTER OPERATOR FAMILY ... DROP OPERATOR
-- when left type is the same as right type, a DROP with only one argument type should work
CREATE OPERATOR FAMILY alt_opf8 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf8 USING btree ADD OPERATOR 1 < (int4, int4);
---END---
---START---
DROP OPERATOR FAMILY alt_opf8 USING btree;
---END---
---START---

-- Should work. Textbook case of ALTER OPERATOR FAMILY ... ADD OPERATOR with FOR ORDER BY
CREATE OPERATOR FAMILY alt_opf9 USING gist;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf9 USING gist ADD OPERATOR 1 < (int4, int4) FOR ORDER BY float_ops;
---END---
---START---
DROP OPERATOR FAMILY alt_opf9 USING gist;
---END---
---START---

-- Should fail. Ensure correct ordering methods in ALTER OPERATOR FAMILY ... ADD OPERATOR .. FOR ORDER BY
CREATE OPERATOR FAMILY alt_opf10 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf10 USING btree ADD OPERATOR 1 < (int4, int4) FOR ORDER BY float_ops;
---END---
---START---
DROP OPERATOR FAMILY alt_opf10 USING btree;
---END---
---START---

-- Should work. Textbook case of ALTER OPERATOR FAMILY ... ADD OPERATOR with FOR ORDER BY
CREATE OPERATOR FAMILY alt_opf11 USING gist;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf11 USING gist ADD OPERATOR 1 < (int4, int4) FOR ORDER BY float_ops;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf11 USING gist DROP OPERATOR 1 (int4, int4);
---END---
---START---
DROP OPERATOR FAMILY alt_opf11 USING gist;
---END---
---START---

-- Should fail. btree comparison functions should return INTEGER in ALTER OPERATOR FAMILY ... ADD FUNCTION
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf12 USING btree;
---END---
---START---
CREATE FUNCTION fn_opf12  (int4, int2) RETURNS BIGINT AS 'SELECT NULL::BIGINT;' LANGUAGE SQL;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf12 USING btree ADD FUNCTION 1 fn_opf12(int4, int2);
---END---
---START---
DROP OPERATOR FAMILY alt_opf12 USING btree;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. hash comparison functions should return INTEGER in ALTER OPERATOR FAMILY ... ADD FUNCTION
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf13 USING hash;
---END---
---START---
CREATE FUNCTION fn_opf13  (int4) RETURNS BIGINT AS 'SELECT NULL::BIGINT;' LANGUAGE SQL;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf13 USING hash ADD FUNCTION 1 fn_opf13(int4);
---END---
---START---
DROP OPERATOR FAMILY alt_opf13 USING hash;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. btree comparison functions should have two arguments in ALTER OPERATOR FAMILY ... ADD FUNCTION
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf14 USING btree;
---END---
---START---
CREATE FUNCTION fn_opf14 (int4) RETURNS BIGINT AS 'SELECT NULL::BIGINT;' LANGUAGE SQL;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf14 USING btree ADD FUNCTION 1 fn_opf14(int4);
---END---
---START---
DROP OPERATOR FAMILY alt_opf14 USING btree;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. hash comparison functions should have one argument in ALTER OPERATOR FAMILY ... ADD FUNCTION
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR FAMILY alt_opf15 USING hash;
---END---
---START---
CREATE FUNCTION fn_opf15 (int4, int2) RETURNS BIGINT AS 'SELECT NULL::BIGINT;' LANGUAGE SQL;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf15 USING hash ADD FUNCTION 1 fn_opf15(int4, int2);
---END---
---START---
DROP OPERATOR FAMILY alt_opf15 USING hash;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Should fail. In gist throw an error when giving different data types for function argument
-- without defining left / right type in ALTER OPERATOR FAMILY ... ADD FUNCTION
CREATE OPERATOR FAMILY alt_opf16 USING gist;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf16 USING gist ADD FUNCTION 1 btint42cmp(int4, int2);
---END---
---START---
DROP OPERATOR FAMILY alt_opf16 USING gist;
---END---
---START---

-- Should fail. duplicate operator number / function number in ALTER OPERATOR FAMILY ... ADD FUNCTION
CREATE OPERATOR FAMILY alt_opf17 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf17 USING btree ADD OPERATOR 1 < (int4, int4), OPERATOR 1 < (int4, int4); -- operator # appears twice in same statement
ALTER OPERATOR FAMILY alt_opf17 USING btree ADD OPERATOR 1 < (int4, int4); -- operator 1 requested first-time
ALTER OPERATOR FAMILY alt_opf17 USING btree ADD OPERATOR 1 < (int4, int4); -- operator 1 requested again in separate statement
ALTER OPERATOR FAMILY alt_opf17 USING btree ADD
  OPERATOR 1 < (int4, int2) ,
  OPERATOR 2 <= (int4, int2) ,
  OPERATOR 3 = (int4, int2) ,
  OPERATOR 4 >= (int4, int2) ,
  OPERATOR 5 > (int4, int2) ,
  FUNCTION 1 btint42cmp(int4, int2) ,
  FUNCTION 1 btint42cmp(int4, int2);    -- procedure 1 appears twice in same statement
ALTER OPERATOR FAMILY alt_opf17 USING btree ADD
  OPERATOR 1 < (int4, int2) ,
  OPERATOR 2 <= (int4, int2) ,
  OPERATOR 3 = (int4, int2) ,
  OPERATOR 4 >= (int4, int2) ,
  OPERATOR 5 > (int4, int2) ,
  FUNCTION 1 btint42cmp(int4, int2);    -- procedure 1 appears first time
ALTER OPERATOR FAMILY alt_opf17 USING btree ADD
  OPERATOR 1 < (int4, int2) ,
  OPERATOR 2 <= (int4, int2) ,
  OPERATOR 3 = (int4, int2) ,
  OPERATOR 4 >= (int4, int2) ,
  OPERATOR 5 > (int4, int2) ,
  FUNCTION 1 btint42cmp(int4, int2);    -- procedure 1 requested again in separate statement
DROP OPERATOR FAMILY alt_opf17 USING btree;
---END---
---START---


-- Should fail. Ensure that DROP requests for missing OPERATOR / FUNCTIONS
-- return appropriate message in ALTER OPERATOR FAMILY ... DROP OPERATOR / FUNCTION
CREATE OPERATOR FAMILY alt_opf18 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf18 USING btree DROP OPERATOR 1 (int4, int4);
---END---
---START---
ALTER OPERATOR FAMILY alt_opf18 USING btree ADD
  OPERATOR 1 < (int4, int2) ,
  OPERATOR 2 <= (int4, int2) ,
  OPERATOR 3 = (int4, int2) ,
  OPERATOR 4 >= (int4, int2) ,
  OPERATOR 5 > (int4, int2) ,
  FUNCTION 1 btint42cmp(int4, int2);
---END---
---START---
-- Should fail. Not allowed to have cross-type equalimage function.
ALTER OPERATOR FAMILY alt_opf18 USING btree
  ADD FUNCTION 4 (int4, int2) btequalimage(oid);
---END---
---START---
ALTER OPERATOR FAMILY alt_opf18 USING btree DROP FUNCTION 2 (int4, int4);
---END---
---START---
DROP OPERATOR FAMILY alt_opf18 USING btree;
---END---
---START---

-- Should fail. Invalid opclass options function (#5) specifications.
CREATE OPERATOR FAMILY alt_opf19 USING btree;
---END---
---START---
ALTER OPERATOR FAMILY alt_opf19 USING btree ADD FUNCTION 5 test_opclass_options_func(internal, text[], bool);
---END---
---START---
ALTER OPERATOR FAMILY alt_opf19 USING btree ADD FUNCTION 5 (int4) btint42cmp(int4, int2);
---END---
---START---
ALTER OPERATOR FAMILY alt_opf19 USING btree ADD FUNCTION 5 (int4, int2) btint42cmp(int4, int2);
---END---
---START---
ALTER OPERATOR FAMILY alt_opf19 USING btree ADD FUNCTION 5 (int4) test_opclass_options_func(internal); -- Ok
ALTER OPERATOR FAMILY alt_opf19 USING btree DROP FUNCTION 5 (int4, int4);
---END---
---START---
DROP OPERATOR FAMILY alt_opf19 USING btree;
---END---
---START---

--
-- Statistics
--
SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---
CREATE TABLE alt_regress_1 (a INTEGER, b INTEGER);
---END---
---START---
CREATE STATISTICS alt_stat1 ON a, b FROM alt_regress_1;
---END---
---START---
CREATE STATISTICS alt_stat2 ON a, b FROM alt_regress_1;
---END---
---START---

ALTER STATISTICS alt_stat1 RENAME TO alt_stat2;   -- failed (name conflict)
ALTER STATISTICS alt_stat1 RENAME TO alt_stat3;   -- OK
ALTER STATISTICS alt_stat2 OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER STATISTICS alt_stat2 OWNER TO regress_alter_generic_user3;  -- OK
ALTER STATISTICS alt_stat2 SET SCHEMA alt_nsp2;    -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---
CREATE TABLE alt_regress_2 (a INTEGER, b INTEGER);
---END---
---START---
CREATE STATISTICS alt_stat1 ON a, b FROM alt_regress_2;
---END---
---START---
CREATE STATISTICS alt_stat2 ON a, b FROM alt_regress_2;
---END---
---START---

ALTER STATISTICS alt_stat3 RENAME TO alt_stat4;    -- failed (not owner)
ALTER STATISTICS alt_stat1 RENAME TO alt_stat4;    -- OK
ALTER STATISTICS alt_stat3 OWNER TO regress_alter_generic_user2; -- failed (not owner)
ALTER STATISTICS alt_stat2 OWNER TO regress_alter_generic_user3; -- failed (no role membership)
ALTER STATISTICS alt_stat3 SET SCHEMA alt_nsp2;		-- failed (not owner)
ALTER STATISTICS alt_stat2 SET SCHEMA alt_nsp2;		-- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---
SELECT nspname, stxname, rolname
  FROM pg_statistic_ext s, pg_namespace n, pg_authid a
 WHERE s.stxnamespace = n.oid AND s.stxowner = a.oid
   AND n.nspname in ('alt_nsp1', 'alt_nsp2')
 ORDER BY nspname, stxname;
---END---
---START---

--
-- Text Search Dictionary
--
SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---
CREATE TEXT SEARCH DICTIONARY alt_ts_dict1 (template=simple);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY alt_ts_dict2 (template=simple);
---END---
---START---

ALTER TEXT SEARCH DICTIONARY alt_ts_dict1 RENAME TO alt_ts_dict2;  -- failed (name conflict)
ALTER TEXT SEARCH DICTIONARY alt_ts_dict1 RENAME TO alt_ts_dict3;  -- OK
ALTER TEXT SEARCH DICTIONARY alt_ts_dict2 OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER TEXT SEARCH DICTIONARY alt_ts_dict2 OWNER TO regress_alter_generic_user3;  -- OK
ALTER TEXT SEARCH DICTIONARY alt_ts_dict2 SET SCHEMA alt_nsp2;  -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---
CREATE TEXT SEARCH DICTIONARY alt_ts_dict1 (template=simple);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY alt_ts_dict2 (template=simple);
---END---
---START---

ALTER TEXT SEARCH DICTIONARY alt_ts_dict3 RENAME TO alt_ts_dict4;  -- failed (not owner)
ALTER TEXT SEARCH DICTIONARY alt_ts_dict1 RENAME TO alt_ts_dict4;  -- OK
ALTER TEXT SEARCH DICTIONARY alt_ts_dict3 OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER TEXT SEARCH DICTIONARY alt_ts_dict2 OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER TEXT SEARCH DICTIONARY alt_ts_dict3 SET SCHEMA alt_nsp2;  -- failed (not owner)
ALTER TEXT SEARCH DICTIONARY alt_ts_dict2 SET SCHEMA alt_nsp2;  -- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---

SELECT nspname, dictname, rolname
  FROM pg_ts_dict t, pg_namespace n, pg_authid a
  WHERE t.dictnamespace = n.oid AND t.dictowner = a.oid
    AND n.nspname in ('alt_nsp1', 'alt_nsp2')
  ORDER BY nspname, dictname;
---END---
---START---

--
-- Text Search Configuration
--
SET SESSION AUTHORIZATION regress_alter_generic_user1;
---END---
---START---
CREATE TEXT SEARCH CONFIGURATION alt_ts_conf1 (copy=english);
---END---
---START---
CREATE TEXT SEARCH CONFIGURATION alt_ts_conf2 (copy=english);
---END---
---START---

ALTER TEXT SEARCH CONFIGURATION alt_ts_conf1 RENAME TO alt_ts_conf2;  -- failed (name conflict)
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf1 RENAME TO alt_ts_conf3;  -- OK
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf2 OWNER TO regress_alter_generic_user2;  -- failed (no role membership)
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf2 OWNER TO regress_alter_generic_user3;  -- OK
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf2 SET SCHEMA alt_nsp2;  -- OK

SET SESSION AUTHORIZATION regress_alter_generic_user2;
---END---
---START---
CREATE TEXT SEARCH CONFIGURATION alt_ts_conf1 (copy=english);
---END---
---START---
CREATE TEXT SEARCH CONFIGURATION alt_ts_conf2 (copy=english);
---END---
---START---

ALTER TEXT SEARCH CONFIGURATION alt_ts_conf3 RENAME TO alt_ts_conf4;  -- failed (not owner)
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf1 RENAME TO alt_ts_conf4;  -- OK
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf3 OWNER TO regress_alter_generic_user2;  -- failed (not owner)
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf2 OWNER TO regress_alter_generic_user3;  -- failed (no role membership)
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf3 SET SCHEMA alt_nsp2;  -- failed (not owner)
ALTER TEXT SEARCH CONFIGURATION alt_ts_conf2 SET SCHEMA alt_nsp2;  -- failed (name conflict)

RESET SESSION AUTHORIZATION;
---END---
---START---

SELECT nspname, cfgname, rolname
  FROM pg_ts_config t, pg_namespace n, pg_authid a
  WHERE t.cfgnamespace = n.oid AND t.cfgowner = a.oid
    AND n.nspname in ('alt_nsp1', 'alt_nsp2')
  ORDER BY nspname, cfgname;
---END---
---START---

--
-- Text Search Template
--
CREATE TEXT SEARCH TEMPLATE alt_ts_temp1 (lexize=dsimple_lexize);
---END---
---START---
CREATE TEXT SEARCH TEMPLATE alt_ts_temp2 (lexize=dsimple_lexize);
---END---
---START---

ALTER TEXT SEARCH TEMPLATE alt_ts_temp1 RENAME TO alt_ts_temp2; -- failed (name conflict)
ALTER TEXT SEARCH TEMPLATE alt_ts_temp1 RENAME TO alt_ts_temp3; -- OK
ALTER TEXT SEARCH TEMPLATE alt_ts_temp2 SET SCHEMA alt_nsp2;    -- OK

CREATE TEXT SEARCH TEMPLATE alt_ts_temp2 (lexize=dsimple_lexize);
---END---
---START---
ALTER TEXT SEARCH TEMPLATE alt_ts_temp2 SET SCHEMA alt_nsp2;    -- failed (name conflict)

-- invalid: non-lowercase quoted identifiers
CREATE TEXT SEARCH TEMPLATE tstemp_case ("Init" = init_function);
---END---
---START---

SELECT nspname, tmplname
  FROM pg_ts_template t, pg_namespace n
  WHERE t.tmplnamespace = n.oid AND nspname like 'alt_nsp%'
  ORDER BY nspname, tmplname;
---END---
---START---

--
-- Text Search Parser
--

CREATE TEXT SEARCH PARSER alt_ts_prs1
    (start = prsd_start, gettoken = prsd_nexttoken, end = prsd_end, lextypes = prsd_lextype);
---END---
---START---
CREATE TEXT SEARCH PARSER alt_ts_prs2
    (start = prsd_start, gettoken = prsd_nexttoken, end = prsd_end, lextypes = prsd_lextype);
---END---
---START---

ALTER TEXT SEARCH PARSER alt_ts_prs1 RENAME TO alt_ts_prs2; -- failed (name conflict)
ALTER TEXT SEARCH PARSER alt_ts_prs1 RENAME TO alt_ts_prs3; -- OK
ALTER TEXT SEARCH PARSER alt_ts_prs2 SET SCHEMA alt_nsp2;   -- OK

CREATE TEXT SEARCH PARSER alt_ts_prs2
    (start = prsd_start, gettoken = prsd_nexttoken, end = prsd_end, lextypes = prsd_lextype);
---END---
---START---
ALTER TEXT SEARCH PARSER alt_ts_prs2 SET SCHEMA alt_nsp2;   -- failed (name conflict)

-- invalid: non-lowercase quoted identifiers
CREATE TEXT SEARCH PARSER tspars_case ("Start" = start_function);
---END---
---START---

SELECT nspname, prsname
  FROM pg_ts_parser t, pg_namespace n
  WHERE t.prsnamespace = n.oid AND nspname like 'alt_nsp%'
  ORDER BY nspname, prsname;
---END---
---START---

---
--- Cleanup resources
---
DROP FOREIGN DATA WRAPPER alt_fdw2 CASCADE;
---END---
---START---
DROP FOREIGN DATA WRAPPER alt_fdw3 CASCADE;
---END---
---START---

DROP LANGUAGE alt_lang2 CASCADE;
---END---
---START---
DROP LANGUAGE alt_lang3 CASCADE;
---END---
---START---

DROP SCHEMA alt_nsp1 CASCADE;
---END---
---START---
DROP SCHEMA alt_nsp2 CASCADE;
---END---
---START---

DROP USER regress_alter_generic_user1;
---END---
---START---
DROP USER regress_alter_generic_user2;
---END---
---START---
DROP USER regress_alter_generic_user3;
---END---
