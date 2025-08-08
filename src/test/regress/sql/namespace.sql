---START---
--
-- Regression tests for schemas (namespaces)
--

-- set the whitespace-only search_path to test that the
-- GUC list syntax is preserved during a schema creation
SELECT pg_catalog.set_config('search_path', ' ', false);
---END---
---START---
CREATE SCHEMA test_ns_schema_1
       CREATE UNIQUE INDEX abc_a_idx ON abc (a)

       CREATE VIEW abc_view AS
              SELECT a+1 AS a, b+1 AS b FROM abc

       CREATE TABLE abc (
              a serial,
              b int UNIQUE
       );
---END---
---START---
-- verify that the correct search_path restored on abort
SET search_path to public;
---END---
---START---
BEGIN;
---END---
---START---
SET search_path to public, test_ns_schema_1;
---END---
---START---
CREATE SCHEMA test_ns_schema_2
       CREATE VIEW abc_view AS SELECT c FROM abc;
---END---
---START---
COMMIT;
---END---
---START---
SHOW search_path;
---END---
---START---
-- verify that the correct search_path preserved
-- after creating the schema and on commit
BEGIN;
---END---
---START---
SET search_path to public, test_ns_schema_1;
---END---
---START---
CREATE SCHEMA test_ns_schema_2
       CREATE VIEW abc_view AS SELECT a FROM abc;
---END---
---START---
SHOW search_path;
---END---
---START---
COMMIT;
---END---
---START---
SHOW search_path;
---END---
---START---
DROP SCHEMA test_ns_schema_2 CASCADE;
---END---
---START---
-- verify that the objects were created
SELECT COUNT(*) FROM pg_class WHERE relnamespace =
    (SELECT oid FROM pg_namespace WHERE nspname = 'test_ns_schema_1');
---END---
---START---
INSERT INTO test_ns_schema_1.abc DEFAULT VALUES;
---END---
---START---
INSERT INTO test_ns_schema_1.abc DEFAULT VALUES;
---END---
---START---
INSERT INTO test_ns_schema_1.abc DEFAULT VALUES;
---END---
---START---
SELECT * FROM test_ns_schema_1.abc;
---END---
---START---
SELECT * FROM test_ns_schema_1.abc_view;
---END---
---START---
ALTER SCHEMA test_ns_schema_1 RENAME TO test_ns_schema_renamed;
---END---
---START---
SELECT COUNT(*) FROM pg_class WHERE relnamespace =
    (SELECT oid FROM pg_namespace WHERE nspname = 'test_ns_schema_1');
---END---
---START---
-- test IF NOT EXISTS cases
CREATE SCHEMA test_ns_schema_renamed;
---END---
---START---
-- fail, already exists
CREATE SCHEMA IF NOT EXISTS test_ns_schema_renamed;
---END---
---START---
-- ok with notice
CREATE SCHEMA IF NOT EXISTS test_ns_schema_renamed -- fail, disallowed
       CREATE TABLE abc (
              a serial,
              b int UNIQUE
       );
---END---
---START---
DROP SCHEMA test_ns_schema_renamed CASCADE;
---END---
---START---
-- verify that the objects were dropped
SELECT COUNT(*) FROM pg_class WHERE relnamespace =
    (SELECT oid FROM pg_namespace WHERE nspname = 'test_ns_schema_renamed');
---END---
