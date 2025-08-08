---START---
CREATE TABLE reloptions_test (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = 30, autovacuum_enabled = 'false', autovacuum_analyze_scale_factor = 0.2);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = 2);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = 110);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_analyze_scale_factor = -10.0);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_analyze_scale_factor = 110.0);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (not_existing_option = 2);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (not_existing_namespace.fillfactor = 2);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = -30.1);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = 'string');
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = 'true');
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_enabled = 12);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_enabled = 30.5);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_enabled = 'string');
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_analyze_scale_factor = 'string');
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (autovacuum_analyze_scale_factor = 'true');
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor = 30, fillfactor = 40);
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (fillfactor);
---END---
---START---
-- Simple ALTER TABLE
ALTER TABLE reloptions_test SET (fillfactor=31,
	autovacuum_analyze_scale_factor = 0.3);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
-- Set boolean option to true without specifying value
ALTER TABLE reloptions_test SET (autovacuum_enabled, fillfactor=32);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
-- Check that RESET works well
ALTER TABLE reloptions_test RESET (fillfactor);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
-- Resetting all values causes the column to become null
ALTER TABLE reloptions_test RESET (autovacuum_enabled,
	autovacuum_analyze_scale_factor);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass AND
       reloptions IS NULL;
---END---
---START---
-- RESET fails if a value is specified
ALTER TABLE reloptions_test RESET (fillfactor=12);
---END---
---START---
-- Test vacuum_truncate option
DROP TABLE reloptions_test;
---END---
---START---
DROP TABLE IF EXISTS reloptions_test;

CREATE TABLE reloptions_test (gemini_pk serial PRIMARY KEY, i integer NOT NULL, j text) WITH (vacuum_truncate = 'false', toast.vacuum_truncate = 'false', autovacuum_enabled = 'false');
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
INSERT INTO reloptions_test VALUES (1, NULL), (NULL, NULL);
---END---
---START---
-- Do an aggressive vacuum to prevent page-skipping.
VACUUM (FREEZE, DISABLE_PAGE_SKIPPING) reloptions_test;
---END---
---START---
SELECT pg_relation_size('reloptions_test') > 0;
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid =
	(SELECT reltoastrelid FROM pg_class
	WHERE oid = 'reloptions_test'::regclass);
---END---
---START---
ALTER TABLE reloptions_test RESET (vacuum_truncate);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
INSERT INTO reloptions_test VALUES (1, NULL), (NULL, NULL);
---END---
---START---
-- Do an aggressive vacuum to prevent page-skipping.
VACUUM (FREEZE, DISABLE_PAGE_SKIPPING) reloptions_test;
---END---
---START---
SELECT pg_relation_size('reloptions_test') = 0;
---END---
---START---
-- Test toast.* options
DROP TABLE reloptions_test;
---END---
---START---
CREATE TABLE reloptions_test (gemini_pk serial PRIMARY KEY, s varchar) WITH (toast.autovacuum_vacuum_cost_delay = 23);
---END---
---START---
SELECT reltoastrelid as toast_oid
	FROM pg_class WHERE oid = 'reloptions_test'::regclass \gset
SELECT reloptions FROM pg_class WHERE oid = :toast_oid;
---END---
---START---
ALTER TABLE reloptions_test SET (toast.autovacuum_vacuum_cost_delay = 24);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = :toast_oid;
---END---
---START---
ALTER TABLE reloptions_test RESET (toast.autovacuum_vacuum_cost_delay);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = :toast_oid;
---END---
---START---
CREATE TABLE reloptions_test2 (gemini_pk serial PRIMARY KEY, i integer) WITH (toast.not_existing_option = 42);
---END---
---START---
-- Mix TOAST & heap
DROP TABLE reloptions_test;
---END---
---START---
CREATE TABLE reloptions_test (gemini_pk serial PRIMARY KEY, s varchar) WITH (toast.autovacuum_vacuum_cost_delay = 23, autovacuum_vacuum_cost_delay = 24, fillfactor = 40);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test'::regclass;
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = (
	SELECT reltoastrelid FROM pg_class WHERE oid = 'reloptions_test'::regclass);
---END---
---START---
--
-- CREATE INDEX, ALTER INDEX for btrees
--

CREATE INDEX reloptions_test_idx ON reloptions_test (s) WITH (fillfactor=30);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test_idx'::regclass;
---END---
---START---
-- Fail when option and namespace do not exist
CREATE INDEX reloptions_test_idx ON reloptions_test (s)
	WITH (not_existing_option=2);
---END---
---START---
CREATE INDEX reloptions_test_idx ON reloptions_test (s)
	WITH (not_existing_ns.fillfactor=2);
---END---
---START---
-- Check allowed ranges
CREATE INDEX reloptions_test_idx2 ON reloptions_test (s) WITH (fillfactor=1);
---END---
---START---
CREATE INDEX reloptions_test_idx2 ON reloptions_test (s) WITH (fillfactor=130);
---END---
---START---
-- Check ALTER
ALTER INDEX reloptions_test_idx SET (fillfactor=40);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test_idx'::regclass;
---END---
---START---
-- Check ALTER on empty reloption list
CREATE INDEX reloptions_test_idx3 ON reloptions_test (s);
---END---
---START---
ALTER INDEX reloptions_test_idx3 SET (fillfactor=40);
---END---
---START---
SELECT reloptions FROM pg_class WHERE oid = 'reloptions_test_idx3'::regclass;
---END---
