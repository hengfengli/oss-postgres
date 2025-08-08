---START---
--
-- SELECT_INTO
--

SELECT *
   INTO TABLE sitmp1
   FROM onek
   WHERE onek.unique1 < 2;
---END---
---START---
DROP TABLE sitmp1;
---END---
---START---
SELECT *
   INTO TABLE sitmp1
   FROM onek2
   WHERE onek2.unique1 < 2;
---END---
---START---
DROP TABLE sitmp1;
---END---
---START---
--
-- SELECT INTO and INSERT permission, if owner is not allowed to insert.
--
CREATE SCHEMA selinto_schema;
---END---
---START---
CREATE USER regress_selinto_user;
---END---
---START---
ALTER DEFAULT PRIVILEGES FOR ROLE regress_selinto_user
	  REVOKE INSERT ON TABLES FROM regress_selinto_user;
---END---
---START---
GRANT ALL ON SCHEMA selinto_schema TO public;
---END---
---START---
SET SESSION AUTHORIZATION regress_selinto_user;
---END---
---START---
-- WITH DATA, passes.
CREATE TABLE selinto_schema.tbl_withdata1 (a)
  AS SELECT generate_series(1,3) WITH DATA;
---END---
---START---
INSERT INTO selinto_schema.tbl_withdata1 VALUES (4);
---END---
---START---
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE selinto_schema.tbl_withdata2 (a) AS
  SELECT generate_series(1,3) WITH DATA;
---END---
---START---
-- WITH NO DATA, passes.
CREATE TABLE selinto_schema.tbl_nodata1 (a) AS
  SELECT generate_series(1,3) WITH NO DATA;
---END---
---START---
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE selinto_schema.tbl_nodata2 (a) AS
  SELECT generate_series(1,3) WITH NO DATA;
---END---
---START---
-- EXECUTE and WITH DATA, passes.
PREPARE data_sel AS SELECT generate_series(1,3);
---END---
---START---
CREATE TABLE selinto_schema.tbl_withdata3 (a) AS
  EXECUTE data_sel WITH DATA;
---END---
---START---
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE selinto_schema.tbl_withdata4 (a) AS
  EXECUTE data_sel WITH DATA;
---END---
---START---
-- EXECUTE and WITH NO DATA, passes.
CREATE TABLE selinto_schema.tbl_nodata3 (a) AS
  EXECUTE data_sel WITH NO DATA;
---END---
---START---
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE selinto_schema.tbl_nodata4 (a) AS
  EXECUTE data_sel WITH NO DATA;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
ALTER DEFAULT PRIVILEGES FOR ROLE regress_selinto_user
	  GRANT INSERT ON TABLES TO regress_selinto_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_selinto_user;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DEALLOCATE data_sel;
---END---
---START---
DROP SCHEMA selinto_schema CASCADE;
---END---
---START---
DROP USER regress_selinto_user;
---END---
---START---
CREATE TABLE ctas_base (_gemini_pk serial PRIMARY KEY, i integer, j integer);
---END---
---START---
INSERT INTO ctas_base VALUES (1, 2);
---END---
---START---
CREATE TABLE ctas_nodata (ii, jj, kk) AS SELECT i, j FROM ctas_base;
---END---
---START---
-- Error
CREATE TABLE ctas_nodata (ii, jj, kk) AS SELECT i, j FROM ctas_base WITH NO DATA;
---END---
---START---
-- Error
CREATE TABLE ctas_nodata (ii, jj) AS SELECT i, j FROM ctas_base;
---END---
---START---
-- OK
CREATE TABLE ctas_nodata_2 (ii, jj) AS SELECT i, j FROM ctas_base WITH NO DATA;
---END---
---START---
-- OK
CREATE TABLE ctas_nodata_3 (ii) AS SELECT i, j FROM ctas_base;
---END---
---START---
-- OK
CREATE TABLE ctas_nodata_4 (ii) AS SELECT i, j FROM ctas_base WITH NO DATA;
---END---
---START---
-- OK
SELECT * FROM ctas_nodata;
---END---
---START---
SELECT * FROM ctas_nodata_2;
---END---
---START---
SELECT * FROM ctas_nodata_3;
---END---
---START---
SELECT * FROM ctas_nodata_4;
---END---
---START---
DROP TABLE ctas_base;
---END---
---START---
DROP TABLE ctas_nodata;
---END---
---START---
DROP TABLE ctas_nodata_2;
---END---
---START---
DROP TABLE ctas_nodata_3;
---END---
---START---
DROP TABLE ctas_nodata_4;
---END---
---START---
--
-- CREATE TABLE AS/SELECT INTO as last command in a SQL function
-- have been known to cause problems
--
CREATE FUNCTION make_table() RETURNS VOID
AS $$
  CREATE TABLE created_table AS SELECT * FROM int8_tbl;
$$ LANGUAGE SQL;
---END---
---START---
SELECT make_table();
---END---
---START---
SELECT * FROM created_table;
---END---
---START---
-- Try EXPLAIN ANALYZE SELECT INTO and EXPLAIN ANALYZE CREATE TABLE AS
-- WITH NO DATA, but hide the outputs since they won't be stable.
DO $$
BEGIN
	EXECUTE 'EXPLAIN ANALYZE SELECT * INTO TABLE easi FROM int8_tbl';
	EXECUTE 'EXPLAIN ANALYZE CREATE TABLE easi2 AS SELECT * FROM int8_tbl WITH NO DATA';
END$$;
---END---
---START---
DROP TABLE created_table;
---END---
---START---
DROP TABLE easi, easi2;
---END---
---START---
--
-- Disallowed uses of SELECT ... INTO.  All should fail
--
DECLARE foo CURSOR FOR SELECT 1 INTO int4_tbl;
---END---
---START---
COPY (SELECT 1 INTO frak UNION SELECT 2) TO 'blob';
---END---
---START---
SELECT * FROM (SELECT 1 INTO f) bar;
---END---
---START---
-- @hengfeng: the emulator gets stuck
-- CREATE VIEW foo AS SELECT 1 INTO int4_tbl;
---END---
---START---
INSERT INTO int4_tbl SELECT 1 INTO f;
---END---
---START---
-- Test CREATE TABLE AS ... IF NOT EXISTS
CREATE TABLE ctas_ine_tbl AS SELECT 1;
---END---
---START---
CREATE TABLE ctas_ine_tbl AS SELECT 1 / 0;
---END---
---START---
-- error
CREATE TABLE IF NOT EXISTS ctas_ine_tbl AS SELECT 1 / 0;
---END---
---START---
-- ok
CREATE TABLE ctas_ine_tbl AS SELECT 1 / 0 WITH NO DATA;
---END---
---START---
-- error
CREATE TABLE IF NOT EXISTS ctas_ine_tbl AS SELECT 1 / 0 WITH NO DATA;
---END---
---START---
-- ok
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE ctas_ine_tbl AS SELECT 1 / 0;
---END---
---START---
-- error
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE IF NOT EXISTS ctas_ine_tbl AS SELECT 1 / 0;
---END---
---START---
-- ok
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE ctas_ine_tbl AS SELECT 1 / 0 WITH NO DATA;
---END---
---START---
-- error
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE IF NOT EXISTS ctas_ine_tbl AS SELECT 1 / 0 WITH NO DATA;
---END---
---START---
-- ok
PREPARE ctas_ine_query AS SELECT 1 / 0;
---END---
---START---
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE ctas_ine_tbl AS EXECUTE ctas_ine_query;
---END---
---START---
-- error
EXPLAIN (ANALYZE, COSTS OFF, SUMMARY OFF, TIMING OFF)
  CREATE TABLE IF NOT EXISTS ctas_ine_tbl AS EXECUTE ctas_ine_query;
---END---
---START---
-- ok
DROP TABLE ctas_ine_tbl;
---END---
