---START---
--
-- IF EXISTS tests
--

-- table (will be really dropped at the end)

DROP TABLE test_exists;
---END---
---START---
DROP TABLE IF EXISTS test_exists;
---END---
---START---
CREATE TABLE test_exists (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
-- view

DROP VIEW test_view_exists;
---END---
---START---
DROP VIEW IF EXISTS test_view_exists;
---END---
---START---
CREATE VIEW test_view_exists AS select * from test_exists;
---END---
---START---
DROP VIEW IF EXISTS test_view_exists;
---END---
---START---
DROP VIEW test_view_exists;
---END---
---START---
-- index

DROP INDEX test_index_exists;
---END---
---START---
DROP INDEX IF EXISTS test_index_exists;
---END---
---START---
CREATE INDEX test_index_exists on test_exists(a);
---END---
---START---
DROP INDEX IF EXISTS test_index_exists;
---END---
---START---
DROP INDEX test_index_exists;
---END---
---START---
-- sequence

DROP SEQUENCE test_sequence_exists;
---END---
---START---
DROP SEQUENCE IF EXISTS test_sequence_exists;
---END---
---START---
CREATE SEQUENCE test_sequence_exists;
---END---
---START---
DROP SEQUENCE IF EXISTS test_sequence_exists;
---END---
---START---
DROP SEQUENCE test_sequence_exists;
---END---
---START---
-- schema

DROP SCHEMA test_schema_exists;
---END---
---START---
DROP SCHEMA IF EXISTS test_schema_exists;
---END---
---START---
CREATE SCHEMA test_schema_exists;
---END---
---START---
DROP SCHEMA IF EXISTS test_schema_exists;
---END---
---START---
DROP SCHEMA test_schema_exists;
---END---
---START---
-- type

DROP TYPE test_type_exists;
---END---
---START---
DROP TYPE IF EXISTS test_type_exists;
---END---
---START---
CREATE type test_type_exists as (a int, b text);
---END---
---START---
DROP TYPE IF EXISTS test_type_exists;
---END---
---START---
DROP TYPE test_type_exists;
---END---
---START---
-- domain

DROP DOMAIN test_domain_exists;
---END---
---START---
DROP DOMAIN IF EXISTS test_domain_exists;
---END---
---START---
CREATE domain test_domain_exists as int not null check (value > 0);
---END---
---START---
DROP DOMAIN IF EXISTS test_domain_exists;
---END---
---START---
DROP DOMAIN test_domain_exists;
---END---
---START---
---
--- role/user/group
---

CREATE USER regress_test_u1;
---END---
---START---
CREATE ROLE regress_test_r1;
---END---
---START---
CREATE GROUP regress_test_g1;
---END---
---START---
DROP USER regress_test_u2;
---END---
---START---
DROP USER IF EXISTS regress_test_u1, regress_test_u2;
---END---
---START---
DROP USER regress_test_u1;
---END---
---START---
DROP ROLE regress_test_r2;
---END---
---START---
DROP ROLE IF EXISTS regress_test_r1, regress_test_r2;
---END---
---START---
DROP ROLE regress_test_r1;
---END---
---START---
DROP GROUP regress_test_g2;
---END---
---START---
DROP GROUP IF EXISTS regress_test_g1, regress_test_g2;
---END---
---START---
DROP GROUP regress_test_g1;
---END---
---START---
-- collation
DROP COLLATION IF EXISTS test_collation_exists;
---END---
---START---
-- conversion
DROP CONVERSION test_conversion_exists;
---END---
---START---
DROP CONVERSION IF EXISTS test_conversion_exists;
---END---
---START---
CREATE CONVERSION test_conversion_exists
    FOR 'LATIN1' TO 'UTF8' FROM iso8859_1_to_utf8;
---END---
---START---
DROP CONVERSION test_conversion_exists;
---END---
---START---
-- text search parser
DROP TEXT SEARCH PARSER test_tsparser_exists;
---END---
---START---
DROP TEXT SEARCH PARSER IF EXISTS test_tsparser_exists;
---END---
---START---
-- text search dictionary
DROP TEXT SEARCH DICTIONARY test_tsdict_exists;
---END---
---START---
DROP TEXT SEARCH DICTIONARY IF EXISTS test_tsdict_exists;
---END---
---START---
CREATE TEXT SEARCH DICTIONARY test_tsdict_exists (
        Template=ispell,
        DictFile=ispell_sample,
        AffFile=ispell_sample
);
---END---
---START---
DROP TEXT SEARCH DICTIONARY test_tsdict_exists;
---END---
---START---
-- test search template
DROP TEXT SEARCH TEMPLATE test_tstemplate_exists;
---END---
---START---
DROP TEXT SEARCH TEMPLATE IF EXISTS test_tstemplate_exists;
---END---
---START---
-- text search configuration
DROP TEXT SEARCH CONFIGURATION test_tsconfig_exists;
---END---
---START---
DROP TEXT SEARCH CONFIGURATION IF EXISTS test_tsconfig_exists;
---END---
---START---
CREATE TEXT SEARCH CONFIGURATION test_tsconfig_exists (COPY=english);
---END---
---START---
DROP TEXT SEARCH CONFIGURATION test_tsconfig_exists;
---END---
---START---
-- extension
DROP EXTENSION test_extension_exists;
---END---
---START---
DROP EXTENSION IF EXISTS test_extension_exists;
---END---
---START---
-- functions
DROP FUNCTION test_function_exists();
---END---
---START---
DROP FUNCTION IF EXISTS test_function_exists();
---END---
---START---
DROP FUNCTION test_function_exists(int, text, int[]);
---END---
---START---
DROP FUNCTION IF EXISTS test_function_exists(int, text, int[]);
---END---
---START---
-- aggregate
DROP AGGREGATE test_aggregate_exists(*);
---END---
---START---
DROP AGGREGATE IF EXISTS test_aggregate_exists(*);
---END---
---START---
DROP AGGREGATE test_aggregate_exists(int);
---END---
---START---
DROP AGGREGATE IF EXISTS test_aggregate_exists(int);
---END---
---START---
-- operator
DROP OPERATOR @#@ (int, int);
---END---
---START---
DROP OPERATOR IF EXISTS @#@ (int, int);
---END---
---START---
CREATE OPERATOR @#@
        (leftarg = int8, rightarg = int8, procedure = int8xor);
---END---
---START---
DROP OPERATOR @#@ (int8, int8);
---END---
---START---
-- language
DROP LANGUAGE test_language_exists;
---END---
---START---
DROP LANGUAGE IF EXISTS test_language_exists;
---END---
---START---
-- cast
DROP CAST (text AS text);
---END---
---START---
DROP CAST IF EXISTS (text AS text);
---END---
---START---
-- trigger
DROP TRIGGER test_trigger_exists ON test_exists;
---END---
---START---
DROP TRIGGER IF EXISTS test_trigger_exists ON test_exists;
---END---
---START---
DROP TRIGGER test_trigger_exists ON no_such_table;
---END---
---START---
DROP TRIGGER IF EXISTS test_trigger_exists ON no_such_table;
---END---
---START---
DROP TRIGGER test_trigger_exists ON no_such_schema.no_such_table;
---END---
---START---
DROP TRIGGER IF EXISTS test_trigger_exists ON no_such_schema.no_such_table;
---END---
---START---
CREATE TRIGGER test_trigger_exists
    BEFORE UPDATE ON test_exists
    FOR EACH ROW EXECUTE PROCEDURE suppress_redundant_updates_trigger();
---END---
---START---
DROP TRIGGER test_trigger_exists ON test_exists;
---END---
---START---
-- rule
DROP RULE test_rule_exists ON test_exists;
---END---
---START---
DROP RULE IF EXISTS test_rule_exists ON test_exists;
---END---
---START---
DROP RULE test_rule_exists ON no_such_table;
---END---
---START---
DROP RULE IF EXISTS test_rule_exists ON no_such_table;
---END---
---START---
DROP RULE test_rule_exists ON no_such_schema.no_such_table;
---END---
---START---
DROP RULE IF EXISTS test_rule_exists ON no_such_schema.no_such_table;
---END---
---START---
CREATE RULE test_rule_exists AS ON INSERT TO test_exists
    DO INSTEAD
    INSERT INTO test_exists VALUES (NEW.a, NEW.b || NEW.a::text);
---END---
---START---
DROP RULE test_rule_exists ON test_exists;
---END---
---START---
-- foreign data wrapper
DROP FOREIGN DATA WRAPPER test_fdw_exists;
---END---
---START---
DROP FOREIGN DATA WRAPPER IF EXISTS test_fdw_exists;
---END---
---START---
-- foreign server
DROP SERVER test_server_exists;
---END---
---START---
DROP SERVER IF EXISTS test_server_exists;
---END---
---START---
-- operator class
DROP OPERATOR CLASS test_operator_class USING btree;
---END---
---START---
DROP OPERATOR CLASS IF EXISTS test_operator_class USING btree;
---END---
---START---
DROP OPERATOR CLASS test_operator_class USING no_such_am;
---END---
---START---
DROP OPERATOR CLASS IF EXISTS test_operator_class USING no_such_am;
---END---
---START---
-- operator family
DROP OPERATOR FAMILY test_operator_family USING btree;
---END---
---START---
DROP OPERATOR FAMILY IF EXISTS test_operator_family USING btree;
---END---
---START---
DROP OPERATOR FAMILY test_operator_family USING no_such_am;
---END---
---START---
DROP OPERATOR FAMILY IF EXISTS test_operator_family USING no_such_am;
---END---
---START---
-- access method
DROP ACCESS METHOD no_such_am;
---END---
---START---
DROP ACCESS METHOD IF EXISTS no_such_am;
---END---
---START---
-- drop the table

DROP TABLE IF EXISTS test_exists;
---END---
---START---
DROP TABLE test_exists;
---END---
---START---
-- be tolerant with missing schemas, types, etc

DROP AGGREGATE IF EXISTS no_such_schema.foo(int);
---END---
---START---
DROP AGGREGATE IF EXISTS foo(no_such_type);
---END---
---START---
DROP AGGREGATE IF EXISTS foo(no_such_schema.no_such_type);
---END---
---START---
DROP CAST IF EXISTS (INTEGER AS no_such_type2);
---END---
---START---
DROP CAST IF EXISTS (no_such_type1 AS INTEGER);
---END---
---START---
DROP CAST IF EXISTS (INTEGER AS no_such_schema.bar);
---END---
---START---
DROP CAST IF EXISTS (no_such_schema.foo AS INTEGER);
---END---
---START---
DROP COLLATION IF EXISTS no_such_schema.foo;
---END---
---START---
DROP CONVERSION IF EXISTS no_such_schema.foo;
---END---
---START---
DROP DOMAIN IF EXISTS no_such_schema.foo;
---END---
---START---
DROP FOREIGN TABLE IF EXISTS no_such_schema.foo;
---END---
---START---
DROP FUNCTION IF EXISTS no_such_schema.foo();
---END---
---START---
DROP FUNCTION IF EXISTS foo(no_such_type);
---END---
---START---
DROP FUNCTION IF EXISTS foo(no_such_schema.no_such_type);
---END---
---START---
DROP INDEX IF EXISTS no_such_schema.foo;
---END---
---START---
DROP MATERIALIZED VIEW IF EXISTS no_such_schema.foo;
---END---
---START---
DROP OPERATOR IF EXISTS no_such_schema.+ (int, int);
---END---
---START---
DROP OPERATOR IF EXISTS + (no_such_type, no_such_type);
---END---
---START---
DROP OPERATOR IF EXISTS + (no_such_schema.no_such_type, no_such_schema.no_such_type);
---END---
---START---
DROP OPERATOR IF EXISTS # (NONE, no_such_schema.no_such_type);
---END---
---START---
DROP OPERATOR CLASS IF EXISTS no_such_schema.widget_ops USING btree;
---END---
---START---
DROP OPERATOR FAMILY IF EXISTS no_such_schema.float_ops USING btree;
---END---
---START---
DROP RULE IF EXISTS foo ON no_such_schema.bar;
---END---
---START---
DROP SEQUENCE IF EXISTS no_such_schema.foo;
---END---
---START---
DROP TABLE IF EXISTS no_such_schema.foo;
---END---
---START---
DROP TEXT SEARCH CONFIGURATION IF EXISTS no_such_schema.foo;
---END---
---START---
DROP TEXT SEARCH DICTIONARY IF EXISTS no_such_schema.foo;
---END---
---START---
DROP TEXT SEARCH PARSER IF EXISTS no_such_schema.foo;
---END---
---START---
DROP TEXT SEARCH TEMPLATE IF EXISTS no_such_schema.foo;
---END---
---START---
DROP TRIGGER IF EXISTS foo ON no_such_schema.bar;
---END---
---START---
DROP TYPE IF EXISTS no_such_schema.foo;
---END---
---START---
DROP VIEW IF EXISTS no_such_schema.foo;
---END---
---START---
-- Check we receive an ambiguous function error when there are
-- multiple matching functions.
CREATE FUNCTION test_ambiguous_funcname(int) returns int as $$ select $1; $$ language sql;
---END---
---START---
CREATE FUNCTION test_ambiguous_funcname(text) returns text as $$ select $1; $$ language sql;
---END---
---START---
DROP FUNCTION test_ambiguous_funcname;
---END---
---START---
DROP FUNCTION IF EXISTS test_ambiguous_funcname;
---END---
---START---
-- cleanup
DROP FUNCTION test_ambiguous_funcname(int);
---END---
---START---
DROP FUNCTION test_ambiguous_funcname(text);
---END---
---START---
-- Likewise for procedures.
CREATE PROCEDURE test_ambiguous_procname(int) as $$ begin end; $$ language plpgsql;
---END---
---START---
CREATE PROCEDURE test_ambiguous_procname(text) as $$ begin end; $$ language plpgsql;
---END---
---START---
DROP PROCEDURE test_ambiguous_procname;
---END---
---START---
DROP PROCEDURE IF EXISTS test_ambiguous_procname;
---END---
---START---
-- Check we get a similar error if we use ROUTINE instead of PROCEDURE.
DROP ROUTINE IF EXISTS test_ambiguous_procname;
---END---
---START---
-- cleanup
DROP PROCEDURE test_ambiguous_procname(int);
---END---
---START---
DROP PROCEDURE test_ambiguous_procname(text);
---END---
---START---
-- This test checks both the functionality of 'if exists' and the syntax
-- of the drop database command.
drop database test_database_exists (force);
---END---
---START---
drop database test_database_exists with (force);
---END---
---START---
drop database if exists test_database_exists (force);
---END---
---START---
drop database if exists test_database_exists with (force);
---END---
