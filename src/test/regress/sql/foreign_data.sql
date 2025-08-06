---START---
--
-- Test foreign-data wrapper and server management.
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

CREATE FUNCTION test_fdw_handler()
    RETURNS fdw_handler
    AS :'regresslib', 'test_fdw_handler'
    LANGUAGE C;
---END---
---START---

-- Clean up in case a prior regression run failed

-- Suppress NOTICE messages when roles don't exist
SET client_min_messages TO 'warning';
---END---
---START---

DROP ROLE IF EXISTS regress_foreign_data_user, regress_test_role, regress_test_role2, regress_test_role_super, regress_test_indirect, regress_unprivileged_role;
---END---
---START---

RESET client_min_messages;
---END---
---START---

CREATE ROLE regress_foreign_data_user LOGIN SUPERUSER;
---END---
---START---
SET SESSION AUTHORIZATION 'regress_foreign_data_user';
---END---
---START---

CREATE ROLE regress_test_role;
---END---
---START---
CREATE ROLE regress_test_role2;
---END---
---START---
CREATE ROLE regress_test_role_super SUPERUSER;
---END---
---START---
CREATE ROLE regress_test_indirect;
---END---
---START---
CREATE ROLE regress_unprivileged_role;
---END---
---START---

CREATE FOREIGN DATA WRAPPER dummy;
---END---
---START---
COMMENT ON FOREIGN DATA WRAPPER dummy IS 'useless';
---END---
---START---
CREATE FOREIGN DATA WRAPPER postgresql VALIDATOR postgresql_fdw_validator;
---END---
---START---

-- At this point we should have 2 built-in wrappers and no servers.
SELECT fdwname, fdwhandler::regproc, fdwvalidator::regproc, fdwoptions FROM pg_foreign_data_wrapper ORDER BY 1, 2, 3;
---END---
---START---
SELECT srvname, srvoptions FROM pg_foreign_server;
---END---
---START---
SELECT * FROM pg_user_mapping;
---END---
---START---

-- CREATE FOREIGN DATA WRAPPER
CREATE FOREIGN DATA WRAPPER foo VALIDATOR bar;            -- ERROR
CREATE FOREIGN DATA WRAPPER foo;
---END---
---START---
\dew

CREATE FOREIGN DATA WRAPPER foo; -- duplicate
DROP FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE FOREIGN DATA WRAPPER foo OPTIONS (testing '1');
---END---
---START---
\dew+

DROP FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE FOREIGN DATA WRAPPER foo OPTIONS (testing '1', testing '2');   -- ERROR
CREATE FOREIGN DATA WRAPPER foo OPTIONS (testing '1', another '2');
---END---
---START---
\dew+

DROP FOREIGN DATA WRAPPER foo;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
CREATE FOREIGN DATA WRAPPER foo; -- ERROR
RESET ROLE;
---END---
---START---
CREATE FOREIGN DATA WRAPPER foo VALIDATOR postgresql_fdw_validator;
---END---
---START---
\dew+

-- HANDLER related checks
CREATE FUNCTION invalid_fdw_handler() RETURNS int LANGUAGE SQL AS 'SELECT 1;';
---END---
---START---
CREATE FOREIGN DATA WRAPPER test_fdw HANDLER invalid_fdw_handler;  -- ERROR
CREATE FOREIGN DATA WRAPPER test_fdw HANDLER test_fdw_handler HANDLER invalid_fdw_handler;  -- ERROR
CREATE FOREIGN DATA WRAPPER test_fdw HANDLER test_fdw_handler;
---END---
---START---
DROP FOREIGN DATA WRAPPER test_fdw;
---END---
---START---

-- ALTER FOREIGN DATA WRAPPER
ALTER FOREIGN DATA WRAPPER foo OPTIONS (nonexistent 'fdw');         -- ERROR

ALTER FOREIGN DATA WRAPPER foo;                             -- ERROR
ALTER FOREIGN DATA WRAPPER foo VALIDATOR bar;               -- ERROR
ALTER FOREIGN DATA WRAPPER foo NO VALIDATOR;
---END---
---START---
\dew+

ALTER FOREIGN DATA WRAPPER foo OPTIONS (a '1', b '2');
---END---
---START---
ALTER FOREIGN DATA WRAPPER foo OPTIONS (SET c '4');         -- ERROR
ALTER FOREIGN DATA WRAPPER foo OPTIONS (DROP c);            -- ERROR
ALTER FOREIGN DATA WRAPPER foo OPTIONS (ADD x '1', DROP x);
---END---
---START---
\dew+

ALTER FOREIGN DATA WRAPPER foo OPTIONS (DROP a, SET b '3', ADD c '4');
---END---
---START---
\dew+

ALTER FOREIGN DATA WRAPPER foo OPTIONS (a '2');
---END---
---START---
ALTER FOREIGN DATA WRAPPER foo OPTIONS (b '4');             -- ERROR
\dew+

SET ROLE regress_test_role;
---END---
---START---
ALTER FOREIGN DATA WRAPPER foo OPTIONS (ADD d '5');         -- ERROR
SET ROLE regress_test_role_super;
---END---
---START---
ALTER FOREIGN DATA WRAPPER foo OPTIONS (ADD d '5');
---END---
---START---
\dew+

ALTER FOREIGN DATA WRAPPER foo OWNER TO regress_test_role;  -- ERROR
ALTER FOREIGN DATA WRAPPER foo OWNER TO regress_test_role_super;
---END---
---START---
ALTER ROLE regress_test_role_super NOSUPERUSER;
---END---
---START---
SET ROLE regress_test_role_super;
---END---
---START---
ALTER FOREIGN DATA WRAPPER foo OPTIONS (ADD e '6');         -- ERROR
RESET ROLE;
---END---
---START---
\dew+

ALTER FOREIGN DATA WRAPPER foo RENAME TO foo1;
---END---
---START---
\dew+
ALTER FOREIGN DATA WRAPPER foo1 RENAME TO foo;
---END---
---START---

-- HANDLER related checks
ALTER FOREIGN DATA WRAPPER foo HANDLER invalid_fdw_handler;  -- ERROR
ALTER FOREIGN DATA WRAPPER foo HANDLER test_fdw_handler HANDLER anything;  -- ERROR
ALTER FOREIGN DATA WRAPPER foo HANDLER test_fdw_handler;
---END---
---START---
DROP FUNCTION invalid_fdw_handler();
---END---
---START---

-- DROP FOREIGN DATA WRAPPER
DROP FOREIGN DATA WRAPPER nonexistent;                      -- ERROR
DROP FOREIGN DATA WRAPPER IF EXISTS nonexistent;
---END---
---START---
\dew+

DROP ROLE regress_test_role_super;                          -- ERROR
SET ROLE regress_test_role_super;
---END---
---START---
DROP FOREIGN DATA WRAPPER foo;
---END---
---START---
RESET ROLE;
---END---
---START---
DROP ROLE regress_test_role_super;
---END---
---START---
\dew+

CREATE FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE SERVER s1 FOREIGN DATA WRAPPER foo;
---END---
---START---
COMMENT ON SERVER s1 IS 'foreign server';
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER s1;
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER s1;				-- ERROR
CREATE USER MAPPING IF NOT EXISTS FOR current_user SERVER s1; -- NOTICE
\dew+
\des+
\deu+
DROP FOREIGN DATA WRAPPER foo;                              -- ERROR
SET ROLE regress_test_role;
---END---
---START---
DROP FOREIGN DATA WRAPPER foo CASCADE;                      -- ERROR
RESET ROLE;
---END---
---START---
DROP FOREIGN DATA WRAPPER foo CASCADE;
---END---
---START---
\dew+
\des+
\deu+

-- exercise CREATE SERVER
CREATE SERVER s1 FOREIGN DATA WRAPPER foo;                  -- ERROR
CREATE FOREIGN DATA WRAPPER foo OPTIONS ("test wrapper" 'true');
---END---
---START---
CREATE SERVER s1 FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE SERVER s1 FOREIGN DATA WRAPPER foo;                  -- ERROR
CREATE SERVER IF NOT EXISTS s1 FOREIGN DATA WRAPPER foo;	-- No ERROR, just NOTICE
CREATE SERVER s2 FOREIGN DATA WRAPPER foo OPTIONS (host 'a', dbname 'b');
---END---
---START---
CREATE SERVER s3 TYPE 'oracle' FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE SERVER s4 TYPE 'oracle' FOREIGN DATA WRAPPER foo OPTIONS (host 'a', dbname 'b');
---END---
---START---
CREATE SERVER s5 VERSION '15.0' FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE SERVER s6 VERSION '16.0' FOREIGN DATA WRAPPER foo OPTIONS (host 'a', dbname 'b');
---END---
---START---
CREATE SERVER s7 TYPE 'oracle' VERSION '17.0' FOREIGN DATA WRAPPER foo OPTIONS (host 'a', dbname 'b');
---END---
---START---
CREATE SERVER s8 FOREIGN DATA WRAPPER postgresql OPTIONS (foo '1'); -- ERROR
CREATE SERVER s8 FOREIGN DATA WRAPPER postgresql OPTIONS (host 'localhost', dbname 's8db');
---END---
---START---
\des+
SET ROLE regress_test_role;
---END---
---START---
CREATE SERVER t1 FOREIGN DATA WRAPPER foo;                 -- ERROR: no usage on FDW
RESET ROLE;
---END---
---START---
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_role;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
CREATE SERVER t1 FOREIGN DATA WRAPPER foo;
---END---
---START---
RESET ROLE;
---END---
---START---
\des+

REVOKE USAGE ON FOREIGN DATA WRAPPER foo FROM regress_test_role;
---END---
---START---
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_indirect;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
CREATE SERVER t2 FOREIGN DATA WRAPPER foo;                 -- ERROR
RESET ROLE;
---END---
---START---
GRANT regress_test_indirect TO regress_test_role;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
CREATE SERVER t2 FOREIGN DATA WRAPPER foo;
---END---
---START---
\des+
RESET ROLE;
---END---
---START---
REVOKE regress_test_indirect FROM regress_test_role;
---END---
---START---

-- ALTER SERVER
ALTER SERVER s0;                                            -- ERROR
ALTER SERVER s0 OPTIONS (a '1');                            -- ERROR
ALTER SERVER s1 VERSION '1.0' OPTIONS (servername 's1');
---END---
---START---
ALTER SERVER s2 VERSION '1.1';
---END---
---START---
ALTER SERVER s3 OPTIONS ("tns name" 'orcl', port '1521');
---END---
---START---
GRANT USAGE ON FOREIGN SERVER s1 TO regress_test_role;
---END---
---START---
GRANT USAGE ON FOREIGN SERVER s6 TO regress_test_role2 WITH GRANT OPTION;
---END---
---START---
\des+
SET ROLE regress_test_role;
---END---
---START---
ALTER SERVER s1 VERSION '1.1';                              -- ERROR
ALTER SERVER s1 OWNER TO regress_test_role;                 -- ERROR
RESET ROLE;
---END---
---START---
ALTER SERVER s1 OWNER TO regress_test_role;
---END---
---START---
GRANT regress_test_role2 TO regress_test_role;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
ALTER SERVER s1 VERSION '1.1';
---END---
---START---
ALTER SERVER s1 OWNER TO regress_test_role2;                -- ERROR
RESET ROLE;
---END---
---START---
ALTER SERVER s8 OPTIONS (foo '1');                          -- ERROR option validation
ALTER SERVER s8 OPTIONS (connect_timeout '30', SET dbname 'db1', DROP host);
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
ALTER SERVER s1 OWNER TO regress_test_indirect;             -- ERROR
RESET ROLE;
---END---
---START---
GRANT regress_test_indirect TO regress_test_role;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
ALTER SERVER s1 OWNER TO regress_test_indirect;
---END---
---START---
RESET ROLE;
---END---
---START---
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_indirect;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
ALTER SERVER s1 OWNER TO regress_test_indirect;
---END---
---START---
RESET ROLE;
---END---
---START---
DROP ROLE regress_test_indirect;                            -- ERROR
\des+

ALTER SERVER s8 RENAME to s8new;
---END---
---START---
\des+
ALTER SERVER s8new RENAME to s8;
---END---
---START---

-- DROP SERVER
DROP SERVER nonexistent;                                    -- ERROR
DROP SERVER IF EXISTS nonexistent;
---END---
---START---
\des
SET ROLE regress_test_role;
---END---
---START---
DROP SERVER s2;                                             -- ERROR
DROP SERVER s1;
---END---
---START---
RESET ROLE;
---END---
---START---
\des
ALTER SERVER s2 OWNER TO regress_test_role;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
DROP SERVER s2;
---END---
---START---
RESET ROLE;
---END---
---START---
\des
CREATE USER MAPPING FOR current_user SERVER s3;
---END---
---START---
\deu
DROP SERVER s3;                                             -- ERROR
DROP SERVER s3 CASCADE;
---END---
---START---
\des
\deu

-- CREATE USER MAPPING
CREATE USER MAPPING FOR regress_test_missing_role SERVER s1;  -- ERROR
CREATE USER MAPPING FOR current_user SERVER s1;             -- ERROR
CREATE USER MAPPING FOR current_user SERVER s4;
---END---
---START---
CREATE USER MAPPING FOR user SERVER s4;                     -- ERROR duplicate
CREATE USER MAPPING FOR public SERVER s4 OPTIONS ("this mapping" 'is public');
---END---
---START---
CREATE USER MAPPING FOR user SERVER s8 OPTIONS (username 'test', password 'secret');    -- ERROR
CREATE USER MAPPING FOR user SERVER s8 OPTIONS (user 'test', password 'secret');
---END---
---START---
ALTER SERVER s5 OWNER TO regress_test_role;
---END---
---START---
ALTER SERVER s6 OWNER TO regress_test_indirect;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER s5;
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER s6 OPTIONS (username 'test');
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER s7;             -- ERROR
CREATE USER MAPPING FOR public SERVER s8;                   -- ERROR
RESET ROLE;
---END---
---START---

ALTER SERVER t1 OWNER TO regress_test_indirect;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER t1 OPTIONS (username 'bob', password 'boo');
---END---
---START---
CREATE USER MAPPING FOR public SERVER t1;
---END---
---START---
RESET ROLE;
---END---
---START---
\deu

-- ALTER USER MAPPING
ALTER USER MAPPING FOR regress_test_missing_role SERVER s4 OPTIONS (gotcha 'true'); -- ERROR
ALTER USER MAPPING FOR user SERVER ss4 OPTIONS (gotcha 'true'); -- ERROR
ALTER USER MAPPING FOR public SERVER s5 OPTIONS (gotcha 'true');            -- ERROR
ALTER USER MAPPING FOR current_user SERVER s8 OPTIONS (username 'test');    -- ERROR
ALTER USER MAPPING FOR current_user SERVER s8 OPTIONS (DROP user, SET password 'public');
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
ALTER USER MAPPING FOR current_user SERVER s5 OPTIONS (ADD modified '1');
---END---
---START---
ALTER USER MAPPING FOR public SERVER s4 OPTIONS (ADD modified '1'); -- ERROR
ALTER USER MAPPING FOR public SERVER t1 OPTIONS (ADD modified '1');
---END---
---START---
RESET ROLE;
---END---
---START---
\deu+

-- DROP USER MAPPING
DROP USER MAPPING FOR regress_test_missing_role SERVER s4;  -- ERROR
DROP USER MAPPING FOR user SERVER ss4;
---END---
---START---
DROP USER MAPPING FOR public SERVER s7;                     -- ERROR
DROP USER MAPPING IF EXISTS FOR regress_test_missing_role SERVER s4;
---END---
---START---
DROP USER MAPPING IF EXISTS FOR user SERVER ss4;
---END---
---START---
DROP USER MAPPING IF EXISTS FOR public SERVER s7;
---END---
---START---
CREATE USER MAPPING FOR public SERVER s8;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
DROP USER MAPPING FOR public SERVER s8;                     -- ERROR
RESET ROLE;
---END---
---START---
DROP SERVER s7;
---END---
---START---
\deu

-- CREATE FOREIGN TABLE
CREATE SCHEMA foreign_schema;
---END---
---START---
CREATE SERVER s0 FOREIGN DATA WRAPPER dummy;
---END---
---START---
CREATE FOREIGN TABLE ft1 ();                                    -- ERROR
CREATE FOREIGN TABLE ft1 () SERVER no_server;                   -- ERROR
CREATE FOREIGN TABLE ft1 (
	c1 integer OPTIONS ("param 1" 'val1') PRIMARY KEY,
	c2 text OPTIONS (param2 'val2', param3 'val3'),
	c3 date
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value'); -- ERROR
CREATE TABLE ref_table (id integer PRIMARY KEY);
---END---
---START---
CREATE FOREIGN TABLE ft1 (
	c1 integer OPTIONS ("param 1" 'val1') REFERENCES ref_table (id),
	c2 text OPTIONS (param2 'val2', param3 'val3'),
	c3 date
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value'); -- ERROR
DROP TABLE ref_table;
---END---
---START---
CREATE FOREIGN TABLE ft1 (
	c1 integer OPTIONS ("param 1" 'val1') NOT NULL,
	c2 text OPTIONS (param2 'val2', param3 'val3'),
	c3 date,
	UNIQUE (c3)
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value'); -- ERROR
CREATE FOREIGN TABLE ft1 (
	c1 integer OPTIONS ("param 1" 'val1') NOT NULL,
	c2 text OPTIONS (param2 'val2', param3 'val3') CHECK (c2 <> ''),
	c3 date,
	CHECK (c3 BETWEEN '1994-01-01'::date AND '1994-01-31'::date)
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
COMMENT ON FOREIGN TABLE ft1 IS 'ft1';
---END---
---START---
COMMENT ON COLUMN ft1.c1 IS 'ft1.c1';
---END---
---START---
\d+ ft1
\det+
CREATE INDEX id_ft1_c2 ON ft1 (c2);                             -- ERROR
SELECT * FROM ft1;                                              -- ERROR
EXPLAIN SELECT * FROM ft1;                                      -- ERROR

CREATE TABLE lt1 (a INT) PARTITION BY RANGE (a);
---END---
---START---
CREATE FOREIGN TABLE ft_part1
  PARTITION OF lt1 FOR VALUES FROM (0) TO (1000) SERVER s0;
---END---
---START---
CREATE INDEX ON lt1 (a);                              -- skips partition
CREATE UNIQUE INDEX ON lt1 (a);                                 -- ERROR
ALTER TABLE lt1 ADD PRIMARY KEY (a);                            -- ERROR
DROP TABLE lt1;
---END---
---START---

CREATE TABLE lt1 (a INT) PARTITION BY RANGE (a);
---END---
---START---
CREATE INDEX ON lt1 (a);
---END---
---START---
CREATE FOREIGN TABLE ft_part1
  PARTITION OF lt1 FOR VALUES FROM (0) TO (1000) SERVER s0;
---END---
---START---
CREATE FOREIGN TABLE ft_part2 (a INT) SERVER s0;
---END---
---START---
ALTER TABLE lt1 ATTACH PARTITION ft_part2 FOR VALUES FROM (1000) TO (2000);
---END---
---START---
DROP FOREIGN TABLE ft_part1, ft_part2;
---END---
---START---
CREATE UNIQUE INDEX ON lt1 (a);
---END---
---START---
ALTER TABLE lt1 ADD PRIMARY KEY (a);
---END---
---START---
CREATE FOREIGN TABLE ft_part1
  PARTITION OF lt1 FOR VALUES FROM (0) TO (1000) SERVER s0;     -- ERROR
CREATE FOREIGN TABLE ft_part2 (a INT NOT NULL) SERVER s0;
---END---
---START---
ALTER TABLE lt1 ATTACH PARTITION ft_part2
  FOR VALUES FROM (1000) TO (2000);                             -- ERROR
DROP TABLE lt1;
---END---
---START---
DROP FOREIGN TABLE ft_part2;
---END---
---START---

CREATE TABLE lt1 (a INT) PARTITION BY RANGE (a);
---END---
---START---
CREATE INDEX ON lt1 (a);
---END---
---START---
CREATE TABLE lt1_part1
  PARTITION OF lt1 FOR VALUES FROM (0) TO (1000)
  PARTITION BY RANGE (a);
---END---
---START---
CREATE FOREIGN TABLE ft_part_1_1
  PARTITION OF lt1_part1 FOR VALUES FROM (0) TO (100) SERVER s0;
---END---
---START---
CREATE FOREIGN TABLE ft_part_1_2 (a INT) SERVER s0;
---END---
---START---
ALTER TABLE lt1_part1 ATTACH PARTITION ft_part_1_2 FOR VALUES FROM (100) TO (200);
---END---
---START---
CREATE UNIQUE INDEX ON lt1 (a);
---END---
---START---
ALTER TABLE lt1 ADD PRIMARY KEY (a);
---END---
---START---
DROP FOREIGN TABLE ft_part_1_1, ft_part_1_2;
---END---
---START---
CREATE UNIQUE INDEX ON lt1 (a);
---END---
---START---
ALTER TABLE lt1 ADD PRIMARY KEY (a);
---END---
---START---
CREATE FOREIGN TABLE ft_part_1_1
  PARTITION OF lt1_part1 FOR VALUES FROM (0) TO (100) SERVER s0;
---END---
---START---
CREATE FOREIGN TABLE ft_part_1_2 (a INT NOT NULL) SERVER s0;
---END---
---START---
ALTER TABLE lt1_part1 ATTACH PARTITION ft_part_1_2 FOR VALUES FROM (100) TO (200);
---END---
---START---
DROP TABLE lt1;
---END---
---START---
DROP FOREIGN TABLE ft_part_1_2;
---END---
---START---

-- ALTER FOREIGN TABLE
COMMENT ON FOREIGN TABLE ft1 IS 'foreign table';
---END---
---START---
COMMENT ON FOREIGN TABLE ft1 IS NULL;
---END---
---START---
COMMENT ON COLUMN ft1.c1 IS 'foreign column';
---END---
---START---
COMMENT ON COLUMN ft1.c1 IS NULL;
---END---
---START---

ALTER FOREIGN TABLE ft1 ADD COLUMN c4 integer;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c5 integer DEFAULT 0;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c6 integer;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c7 integer NOT NULL;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c8 integer;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c9 integer;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD COLUMN c10 integer OPTIONS (p1 'v1');
---END---
---START---

ALTER FOREIGN TABLE ft1 ALTER COLUMN c4 SET DEFAULT 0;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c5 DROP DEFAULT;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c6 SET NOT NULL;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c7 DROP NOT NULL;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 TYPE char(10) USING '0'; -- ERROR
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 TYPE char(10);
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 SET DATA TYPE text;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN xmin OPTIONS (ADD p1 'v1'); -- ERROR
ALTER FOREIGN TABLE ft1 ALTER COLUMN c7 OPTIONS (ADD p1 'v1', ADD p2 'v2'),
                        ALTER COLUMN c8 OPTIONS (ADD p1 'v1', ADD p2 'v2');
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 OPTIONS (SET p2 'V2', DROP p1);
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c1 SET STATISTICS 10000;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c1 SET (n_distinct = 100);
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 SET STATISTICS -1;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 SET STORAGE PLAIN;
---END---
---START---
\d+ ft1
-- can't change the column type if it's used elsewhere
CREATE TABLE use_ft1_column_type (x ft1);
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER COLUMN c8 SET DATA TYPE integer;	-- ERROR
DROP TABLE use_ft1_column_type;
---END---
---START---
ALTER FOREIGN TABLE ft1 ADD PRIMARY KEY (c7);                   -- ERROR
ALTER FOREIGN TABLE ft1 ADD CONSTRAINT ft1_c9_check CHECK (c9 < 0) NOT VALID;
---END---
---START---
ALTER FOREIGN TABLE ft1 ALTER CONSTRAINT ft1_c9_check DEFERRABLE; -- ERROR
ALTER FOREIGN TABLE ft1 DROP CONSTRAINT ft1_c9_check;
---END---
---START---
ALTER FOREIGN TABLE ft1 DROP CONSTRAINT no_const;               -- ERROR
ALTER FOREIGN TABLE ft1 DROP CONSTRAINT IF EXISTS no_const;
---END---
---START---
ALTER FOREIGN TABLE ft1 OWNER TO regress_test_role;
---END---
---START---
ALTER FOREIGN TABLE ft1 OPTIONS (DROP delimiter, SET quote '~', ADD escape '@');
---END---
---START---
ALTER FOREIGN TABLE ft1 DROP COLUMN no_column;                  -- ERROR
ALTER FOREIGN TABLE ft1 DROP COLUMN IF EXISTS no_column;
---END---
---START---
ALTER FOREIGN TABLE ft1 DROP COLUMN c9;
---END---
---START---
ALTER FOREIGN TABLE ft1 SET SCHEMA foreign_schema;
---END---
---START---
ALTER FOREIGN TABLE ft1 SET TABLESPACE ts;                      -- ERROR
ALTER FOREIGN TABLE foreign_schema.ft1 RENAME c1 TO foreign_column_1;
---END---
---START---
ALTER FOREIGN TABLE foreign_schema.ft1 RENAME TO foreign_table_1;
---END---
---START---
\d foreign_schema.foreign_table_1

-- alter noexisting table
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ADD COLUMN c4 integer;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ADD COLUMN c6 integer;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ADD COLUMN c7 integer NOT NULL;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ADD COLUMN c8 integer;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ADD COLUMN c9 integer;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ADD COLUMN c10 integer OPTIONS (p1 'v1');
---END---
---START---

ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ALTER COLUMN c6 SET NOT NULL;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ALTER COLUMN c7 DROP NOT NULL;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ALTER COLUMN c8 TYPE char(10);
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ALTER COLUMN c8 SET DATA TYPE text;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ALTER COLUMN c7 OPTIONS (ADD p1 'v1', ADD p2 'v2'),
                        ALTER COLUMN c8 OPTIONS (ADD p1 'v1', ADD p2 'v2');
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 ALTER COLUMN c8 OPTIONS (SET p2 'V2', DROP p1);
---END---
---START---

ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 DROP CONSTRAINT IF EXISTS no_const;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 DROP CONSTRAINT ft1_c1_check;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 OWNER TO regress_test_role;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 OPTIONS (DROP delimiter, SET quote '~', ADD escape '@');
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 DROP COLUMN IF EXISTS no_column;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 DROP COLUMN c9;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 SET SCHEMA foreign_schema;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 RENAME c1 TO foreign_column_1;
---END---
---START---
ALTER FOREIGN TABLE IF EXISTS doesnt_exist_ft1 RENAME TO foreign_table_1;
---END---
---START---

-- Information schema

SELECT * FROM information_schema.foreign_data_wrappers ORDER BY 1, 2;
---END---
---START---
SELECT * FROM information_schema.foreign_data_wrapper_options ORDER BY 1, 2, 3;
---END---
---START---
SELECT * FROM information_schema.foreign_servers ORDER BY 1, 2;
---END---
---START---
SELECT * FROM information_schema.foreign_server_options ORDER BY 1, 2, 3;
---END---
---START---
SELECT * FROM information_schema.user_mappings ORDER BY lower(authorization_identifier), 2, 3;
---END---
---START---
SELECT * FROM information_schema.user_mapping_options ORDER BY lower(authorization_identifier), 2, 3, 4;
---END---
---START---
SELECT * FROM information_schema.usage_privileges WHERE object_type LIKE 'FOREIGN%' AND object_name IN ('s6', 'foo') ORDER BY 1, 2, 3, 4, 5;
---END---
---START---
SELECT * FROM information_schema.role_usage_grants WHERE object_type LIKE 'FOREIGN%' AND object_name IN ('s6', 'foo') ORDER BY 1, 2, 3, 4, 5;
---END---
---START---
SELECT * FROM information_schema.foreign_tables ORDER BY 1, 2, 3;
---END---
---START---
SELECT * FROM information_schema.foreign_table_options ORDER BY 1, 2, 3, 4;
---END---
---START---
SET ROLE regress_test_role;
---END---
---START---
SELECT * FROM information_schema.user_mapping_options ORDER BY 1, 2, 3, 4;
---END---
---START---
SELECT * FROM information_schema.usage_privileges WHERE object_type LIKE 'FOREIGN%' AND object_name IN ('s6', 'foo') ORDER BY 1, 2, 3, 4, 5;
---END---
---START---
SELECT * FROM information_schema.role_usage_grants WHERE object_type LIKE 'FOREIGN%' AND object_name IN ('s6', 'foo') ORDER BY 1, 2, 3, 4, 5;
---END---
---START---
DROP USER MAPPING FOR current_user SERVER t1;
---END---
---START---
SET ROLE regress_test_role2;
---END---
---START---
SELECT * FROM information_schema.user_mapping_options ORDER BY 1, 2, 3, 4;
---END---
---START---
RESET ROLE;
---END---
---START---


-- has_foreign_data_wrapper_privilege
SELECT has_foreign_data_wrapper_privilege('regress_test_role',
    (SELECT oid FROM pg_foreign_data_wrapper WHERE fdwname='foo'), 'USAGE');
---END---
---START---
SELECT has_foreign_data_wrapper_privilege('regress_test_role', 'foo', 'USAGE');
---END---
---START---
SELECT has_foreign_data_wrapper_privilege(
    (SELECT oid FROM pg_roles WHERE rolname='regress_test_role'),
    (SELECT oid FROM pg_foreign_data_wrapper WHERE fdwname='foo'), 'USAGE');
---END---
---START---
SELECT has_foreign_data_wrapper_privilege(
    (SELECT oid FROM pg_foreign_data_wrapper WHERE fdwname='foo'), 'USAGE');
---END---
---START---
SELECT has_foreign_data_wrapper_privilege(
    (SELECT oid FROM pg_roles WHERE rolname='regress_test_role'), 'foo', 'USAGE');
---END---
---START---
SELECT has_foreign_data_wrapper_privilege('foo', 'USAGE');
---END---
---START---
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_role;
---END---
---START---
SELECT has_foreign_data_wrapper_privilege('regress_test_role', 'foo', 'USAGE');
---END---
---START---

-- has_server_privilege
SELECT has_server_privilege('regress_test_role',
    (SELECT oid FROM pg_foreign_server WHERE srvname='s8'), 'USAGE');
---END---
---START---
SELECT has_server_privilege('regress_test_role', 's8', 'USAGE');
---END---
---START---
SELECT has_server_privilege(
    (SELECT oid FROM pg_roles WHERE rolname='regress_test_role'),
    (SELECT oid FROM pg_foreign_server WHERE srvname='s8'), 'USAGE');
---END---
---START---
SELECT has_server_privilege(
    (SELECT oid FROM pg_foreign_server WHERE srvname='s8'), 'USAGE');
---END---
---START---
SELECT has_server_privilege(
    (SELECT oid FROM pg_roles WHERE rolname='regress_test_role'), 's8', 'USAGE');
---END---
---START---
SELECT has_server_privilege('s8', 'USAGE');
---END---
---START---
GRANT USAGE ON FOREIGN SERVER s8 TO regress_test_role;
---END---
---START---
SELECT has_server_privilege('regress_test_role', 's8', 'USAGE');
---END---
---START---
REVOKE USAGE ON FOREIGN SERVER s8 FROM regress_test_role;
---END---
---START---

GRANT USAGE ON FOREIGN SERVER s4 TO regress_test_role;
---END---
---START---
DROP USER MAPPING FOR public SERVER s4;
---END---
---START---
ALTER SERVER s6 OPTIONS (DROP host, DROP dbname);
---END---
---START---
ALTER USER MAPPING FOR regress_test_role SERVER s6 OPTIONS (DROP username);
---END---
---START---
ALTER FOREIGN DATA WRAPPER foo VALIDATOR postgresql_fdw_validator;
---END---
---START---

-- Privileges
SET ROLE regress_unprivileged_role;
---END---
---START---
CREATE FOREIGN DATA WRAPPER foobar;                             -- ERROR
ALTER FOREIGN DATA WRAPPER foo OPTIONS (gotcha 'true');         -- ERROR
ALTER FOREIGN DATA WRAPPER foo OWNER TO regress_unprivileged_role; -- ERROR
DROP FOREIGN DATA WRAPPER foo;                                  -- ERROR
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_role;   -- ERROR
CREATE SERVER s9 FOREIGN DATA WRAPPER foo;                      -- ERROR
ALTER SERVER s4 VERSION '0.5';                                  -- ERROR
ALTER SERVER s4 OWNER TO regress_unprivileged_role;             -- ERROR
DROP SERVER s4;                                                 -- ERROR
GRANT USAGE ON FOREIGN SERVER s4 TO regress_test_role;          -- ERROR
CREATE USER MAPPING FOR public SERVER s4;                       -- ERROR
ALTER USER MAPPING FOR regress_test_role SERVER s6 OPTIONS (gotcha 'true'); -- ERROR
DROP USER MAPPING FOR regress_test_role SERVER s6;              -- ERROR
RESET ROLE;
---END---
---START---

GRANT USAGE ON FOREIGN DATA WRAPPER postgresql TO regress_unprivileged_role;
---END---
---START---
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_unprivileged_role WITH GRANT OPTION;
---END---
---START---
SET ROLE regress_unprivileged_role;
---END---
---START---
CREATE FOREIGN DATA WRAPPER foobar;                             -- ERROR
ALTER FOREIGN DATA WRAPPER foo OPTIONS (gotcha 'true');         -- ERROR
DROP FOREIGN DATA WRAPPER foo;                                  -- ERROR
GRANT USAGE ON FOREIGN DATA WRAPPER postgresql TO regress_test_role; -- WARNING
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_role;
---END---
---START---
CREATE SERVER s9 FOREIGN DATA WRAPPER postgresql;
---END---
---START---
ALTER SERVER s6 VERSION '0.5';                                  -- ERROR
DROP SERVER s6;                                                 -- ERROR
GRANT USAGE ON FOREIGN SERVER s6 TO regress_test_role;          -- ERROR
GRANT USAGE ON FOREIGN SERVER s9 TO regress_test_role;
---END---
---START---
CREATE USER MAPPING FOR public SERVER s6;                       -- ERROR
CREATE USER MAPPING FOR public SERVER s9;
---END---
---START---
ALTER USER MAPPING FOR regress_test_role SERVER s6 OPTIONS (gotcha 'true'); -- ERROR
DROP USER MAPPING FOR regress_test_role SERVER s6;              -- ERROR
RESET ROLE;
---END---
---START---

REVOKE USAGE ON FOREIGN DATA WRAPPER foo FROM regress_unprivileged_role; -- ERROR
REVOKE USAGE ON FOREIGN DATA WRAPPER foo FROM regress_unprivileged_role CASCADE;
---END---
---START---
SET ROLE regress_unprivileged_role;
---END---
---START---
GRANT USAGE ON FOREIGN DATA WRAPPER foo TO regress_test_role;   -- ERROR
CREATE SERVER s10 FOREIGN DATA WRAPPER foo;                     -- ERROR
ALTER SERVER s9 VERSION '1.1';
---END---
---START---
GRANT USAGE ON FOREIGN SERVER s9 TO regress_test_role;
---END---
---START---
CREATE USER MAPPING FOR current_user SERVER s9;
---END---
---START---
DROP SERVER s9 CASCADE;
---END---
---START---
RESET ROLE;
---END---
---START---
CREATE SERVER s9 FOREIGN DATA WRAPPER foo;
---END---
---START---
GRANT USAGE ON FOREIGN SERVER s9 TO regress_unprivileged_role;
---END---
---START---
SET ROLE regress_unprivileged_role;
---END---
---START---
ALTER SERVER s9 VERSION '1.2';                                  -- ERROR
GRANT USAGE ON FOREIGN SERVER s9 TO regress_test_role;          -- WARNING
CREATE USER MAPPING FOR current_user SERVER s9;
---END---
---START---
DROP SERVER s9 CASCADE;                                         -- ERROR

-- Check visibility of user mapping data
SET ROLE regress_test_role;
---END---
---START---
CREATE SERVER s10 FOREIGN DATA WRAPPER foo;
---END---
---START---
CREATE USER MAPPING FOR public SERVER s10 OPTIONS (user 'secret');
---END---
---START---
CREATE USER MAPPING FOR regress_unprivileged_role SERVER s10 OPTIONS (user 'secret');
---END---
---START---
-- owner of server can see some option fields
\deu+
RESET ROLE;
---END---
---START---
-- superuser can see all option fields
\deu+
-- unprivileged user cannot see any option field
SET ROLE regress_unprivileged_role;
---END---
---START---
\deu+
RESET ROLE;
---END---
---START---
DROP SERVER s10 CASCADE;
---END---
---START---

-- Triggers
CREATE FUNCTION dummy_trigger() RETURNS TRIGGER AS $$
  BEGIN
    RETURN NULL;
---END---
---START---
  END
$$ language plpgsql;
---END---
---START---

CREATE TRIGGER trigtest_before_stmt BEFORE INSERT OR UPDATE OR DELETE
ON foreign_schema.foreign_table_1
FOR EACH STATEMENT
EXECUTE PROCEDURE dummy_trigger();
---END---
---START---

CREATE TRIGGER trigtest_after_stmt AFTER INSERT OR UPDATE OR DELETE
ON foreign_schema.foreign_table_1
FOR EACH STATEMENT
EXECUTE PROCEDURE dummy_trigger();
---END---
---START---

CREATE TRIGGER trigtest_after_stmt_tt AFTER INSERT OR UPDATE OR DELETE -- ERROR
ON foreign_schema.foreign_table_1
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT
EXECUTE PROCEDURE dummy_trigger();
---END---
---START---

CREATE TRIGGER trigtest_before_row BEFORE INSERT OR UPDATE OR DELETE
ON foreign_schema.foreign_table_1
FOR EACH ROW
EXECUTE PROCEDURE dummy_trigger();
---END---
---START---

CREATE TRIGGER trigtest_after_row AFTER INSERT OR UPDATE OR DELETE
ON foreign_schema.foreign_table_1
FOR EACH ROW
EXECUTE PROCEDURE dummy_trigger();
---END---
---START---

CREATE CONSTRAINT TRIGGER trigtest_constraint AFTER INSERT OR UPDATE OR DELETE
ON foreign_schema.foreign_table_1
FOR EACH ROW
EXECUTE PROCEDURE dummy_trigger();
---END---
---START---

ALTER FOREIGN TABLE foreign_schema.foreign_table_1
	DISABLE TRIGGER trigtest_before_stmt;
---END---
---START---
ALTER FOREIGN TABLE foreign_schema.foreign_table_1
	ENABLE TRIGGER trigtest_before_stmt;
---END---
---START---

DROP TRIGGER trigtest_before_stmt ON foreign_schema.foreign_table_1;
---END---
---START---
DROP TRIGGER trigtest_before_row ON foreign_schema.foreign_table_1;
---END---
---START---
DROP TRIGGER trigtest_after_stmt ON foreign_schema.foreign_table_1;
---END---
---START---
DROP TRIGGER trigtest_after_row ON foreign_schema.foreign_table_1;
---END---
---START---

DROP FUNCTION dummy_trigger();
---END---
---START---

-- Table inheritance
CREATE TABLE fd_pt1 (
	c1 integer NOT NULL,
	c2 text,
	c3 date
);
---END---
---START---
CREATE FOREIGN TABLE ft2 () INHERITS (fd_pt1)
  SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
\d+ fd_pt1
\d+ ft2
DROP FOREIGN TABLE ft2;
---END---
---START---
\d+ fd_pt1
CREATE FOREIGN TABLE ft2 (
	c1 integer NOT NULL,
	c2 text,
	c3 date
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
\d+ ft2
ALTER FOREIGN TABLE ft2 INHERIT fd_pt1;
---END---
---START---
\d+ fd_pt1
\d+ ft2
CREATE TABLE ct3() INHERITS(ft2);
---END---
---START---
CREATE FOREIGN TABLE ft3 (
	c1 integer NOT NULL,
	c2 text,
	c3 date
) INHERITS(ft2)
  SERVER s0;
---END---
---START---
\d+ ft2
\d+ ct3
\d+ ft3

-- add attributes recursively
ALTER TABLE fd_pt1 ADD COLUMN c4 integer;
---END---
---START---
ALTER TABLE fd_pt1 ADD COLUMN c5 integer DEFAULT 0;
---END---
---START---
ALTER TABLE fd_pt1 ADD COLUMN c6 integer;
---END---
---START---
ALTER TABLE fd_pt1 ADD COLUMN c7 integer NOT NULL;
---END---
---START---
ALTER TABLE fd_pt1 ADD COLUMN c8 integer;
---END---
---START---
\d+ fd_pt1
\d+ ft2
\d+ ct3
\d+ ft3

-- alter attributes recursively
ALTER TABLE fd_pt1 ALTER COLUMN c4 SET DEFAULT 0;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c5 DROP DEFAULT;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c6 SET NOT NULL;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c7 DROP NOT NULL;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c8 TYPE char(10) USING '0';        -- ERROR
ALTER TABLE fd_pt1 ALTER COLUMN c8 TYPE char(10);
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c8 SET DATA TYPE text;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c1 SET STATISTICS 10000;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c1 SET (n_distinct = 100);
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c8 SET STATISTICS -1;
---END---
---START---
ALTER TABLE fd_pt1 ALTER COLUMN c8 SET STORAGE EXTERNAL;
---END---
---START---
\d+ fd_pt1
\d+ ft2

-- drop attributes recursively
ALTER TABLE fd_pt1 DROP COLUMN c4;
---END---
---START---
ALTER TABLE fd_pt1 DROP COLUMN c5;
---END---
---START---
ALTER TABLE fd_pt1 DROP COLUMN c6;
---END---
---START---
ALTER TABLE fd_pt1 DROP COLUMN c7;
---END---
---START---
ALTER TABLE fd_pt1 DROP COLUMN c8;
---END---
---START---
\d+ fd_pt1
\d+ ft2

-- add constraints recursively
ALTER TABLE fd_pt1 ADD CONSTRAINT fd_pt1chk1 CHECK (c1 > 0) NO INHERIT;
---END---
---START---
ALTER TABLE fd_pt1 ADD CONSTRAINT fd_pt1chk2 CHECK (c2 <> '');
---END---
---START---
-- connoinherit should be true for NO INHERIT constraint
SELECT relname, conname, contype, conislocal, coninhcount, connoinherit
  FROM pg_class AS pc JOIN pg_constraint AS pgc ON (conrelid = pc.oid)
  WHERE pc.relname = 'fd_pt1'
  ORDER BY 1,2;
---END---
---START---
-- child does not inherit NO INHERIT constraints
\d+ fd_pt1
\d+ ft2
DROP FOREIGN TABLE ft2; -- ERROR
DROP FOREIGN TABLE ft2 CASCADE;
---END---
---START---
CREATE FOREIGN TABLE ft2 (
	c1 integer NOT NULL,
	c2 text,
	c3 date
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
-- child must have parent's INHERIT constraints
ALTER FOREIGN TABLE ft2 INHERIT fd_pt1;                            -- ERROR
ALTER FOREIGN TABLE ft2 ADD CONSTRAINT fd_pt1chk2 CHECK (c2 <> '');
---END---
---START---
ALTER FOREIGN TABLE ft2 INHERIT fd_pt1;
---END---
---START---
-- child does not inherit NO INHERIT constraints
\d+ fd_pt1
\d+ ft2

-- drop constraints recursively
ALTER TABLE fd_pt1 DROP CONSTRAINT fd_pt1chk1 CASCADE;
---END---
---START---
ALTER TABLE fd_pt1 DROP CONSTRAINT fd_pt1chk2 CASCADE;
---END---
---START---

-- NOT VALID case
INSERT INTO fd_pt1 VALUES (1, 'fd_pt1'::text, '1994-01-01'::date);
---END---
---START---
ALTER TABLE fd_pt1 ADD CONSTRAINT fd_pt1chk3 CHECK (c2 <> '') NOT VALID;
---END---
---START---
\d+ fd_pt1
\d+ ft2
-- VALIDATE CONSTRAINT need do nothing on foreign tables
ALTER TABLE fd_pt1 VALIDATE CONSTRAINT fd_pt1chk3;
---END---
---START---
\d+ fd_pt1
\d+ ft2

-- changes name of an attribute recursively
ALTER TABLE fd_pt1 RENAME COLUMN c1 TO f1;
---END---
---START---
ALTER TABLE fd_pt1 RENAME COLUMN c2 TO f2;
---END---
---START---
ALTER TABLE fd_pt1 RENAME COLUMN c3 TO f3;
---END---
---START---
-- changes name of a constraint recursively
ALTER TABLE fd_pt1 RENAME CONSTRAINT fd_pt1chk3 TO f2_check;
---END---
---START---
\d+ fd_pt1
\d+ ft2

DROP TABLE fd_pt1 CASCADE;
---END---
---START---

-- IMPORT FOREIGN SCHEMA
IMPORT FOREIGN SCHEMA s1 FROM SERVER s9 INTO public; -- ERROR
IMPORT FOREIGN SCHEMA s1 LIMIT TO (t1) FROM SERVER s9 INTO public; --ERROR
IMPORT FOREIGN SCHEMA s1 EXCEPT (t1) FROM SERVER s9 INTO public; -- ERROR
IMPORT FOREIGN SCHEMA s1 EXCEPT (t1, t2) FROM SERVER s9 INTO public
OPTIONS (option1 'value1', option2 'value2'); -- ERROR

-- DROP FOREIGN TABLE
DROP FOREIGN TABLE no_table;                                    -- ERROR
DROP FOREIGN TABLE IF EXISTS no_table;
---END---
---START---
DROP FOREIGN TABLE foreign_schema.foreign_table_1;
---END---
---START---

-- REASSIGN OWNED/DROP OWNED of foreign objects
REASSIGN OWNED BY regress_test_role TO regress_test_role2;
---END---
---START---
DROP OWNED BY regress_test_role2;
---END---
---START---
DROP OWNED BY regress_test_role2 CASCADE;
---END---
---START---

-- Foreign partition DDL stuff
CREATE TABLE fd_pt2 (
	c1 integer NOT NULL,
	c2 text,
	c3 date
) PARTITION BY LIST (c1);
---END---
---START---
CREATE FOREIGN TABLE fd_pt2_1 PARTITION OF fd_pt2 FOR VALUES IN (1)
  SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
\d+ fd_pt2
\d+ fd_pt2_1

-- partition cannot have additional columns
DROP FOREIGN TABLE fd_pt2_1;
---END---
---START---
CREATE FOREIGN TABLE fd_pt2_1 (
	c1 integer NOT NULL,
	c2 text,
	c3 date,
	c4 char
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
\d+ fd_pt2_1
ALTER TABLE fd_pt2 ATTACH PARTITION fd_pt2_1 FOR VALUES IN (1);       -- ERROR

DROP FOREIGN TABLE fd_pt2_1;
---END---
---START---
\d+ fd_pt2
CREATE FOREIGN TABLE fd_pt2_1 (
	c1 integer NOT NULL,
	c2 text,
	c3 date
) SERVER s0 OPTIONS (delimiter ',', quote '"', "be quoted" 'value');
---END---
---START---
\d+ fd_pt2_1
-- no attach partition validation occurs for foreign tables
ALTER TABLE fd_pt2 ATTACH PARTITION fd_pt2_1 FOR VALUES IN (1);
---END---
---START---
\d+ fd_pt2
\d+ fd_pt2_1

-- cannot add column to a partition
ALTER TABLE fd_pt2_1 ADD c4 char;
---END---
---START---

-- ok to have a partition's own constraints though
ALTER TABLE fd_pt2_1 ALTER c3 SET NOT NULL;
---END---
---START---
ALTER TABLE fd_pt2_1 ADD CONSTRAINT p21chk CHECK (c2 <> '');
---END---
---START---
\d+ fd_pt2
\d+ fd_pt2_1

-- cannot drop inherited NOT NULL constraint from a partition
ALTER TABLE fd_pt2_1 ALTER c1 DROP NOT NULL;
---END---
---START---

-- partition must have parent's constraints
ALTER TABLE fd_pt2 DETACH PARTITION fd_pt2_1;
---END---
---START---
ALTER TABLE fd_pt2 ALTER c2 SET NOT NULL;
---END---
---START---
\d+ fd_pt2
\d+ fd_pt2_1
ALTER TABLE fd_pt2 ATTACH PARTITION fd_pt2_1 FOR VALUES IN (1);       -- ERROR
ALTER FOREIGN TABLE fd_pt2_1 ALTER c2 SET NOT NULL;
---END---
---START---
ALTER TABLE fd_pt2 ATTACH PARTITION fd_pt2_1 FOR VALUES IN (1);
---END---
---START---

ALTER TABLE fd_pt2 DETACH PARTITION fd_pt2_1;
---END---
---START---
ALTER TABLE fd_pt2 ADD CONSTRAINT fd_pt2chk1 CHECK (c1 > 0);
---END---
---START---
\d+ fd_pt2
\d+ fd_pt2_1
ALTER TABLE fd_pt2 ATTACH PARTITION fd_pt2_1 FOR VALUES IN (1);       -- ERROR
ALTER FOREIGN TABLE fd_pt2_1 ADD CONSTRAINT fd_pt2chk1 CHECK (c1 > 0);
---END---
---START---
ALTER TABLE fd_pt2 ATTACH PARTITION fd_pt2_1 FOR VALUES IN (1);
---END---
---START---

DROP FOREIGN TABLE fd_pt2_1;
---END---
---START---
DROP TABLE fd_pt2;
---END---
---START---

-- foreign table cannot be part of partition tree made of temporary
-- relations.
CREATE TABLE temp_parted (a int) PARTITION BY LIST (a);
---END---
---START---
CREATE FOREIGN TABLE foreign_part PARTITION OF temp_parted DEFAULT
  SERVER s0;  -- ERROR
CREATE FOREIGN TABLE foreign_part (a int) SERVER s0;
---END---
---START---
ALTER TABLE temp_parted ATTACH PARTITION foreign_part DEFAULT;  -- ERROR
DROP FOREIGN TABLE foreign_part;
---END---
---START---
DROP TABLE temp_parted;
---END---
---START---

-- Cleanup
DROP SCHEMA foreign_schema CASCADE;
---END---
---START---
DROP ROLE regress_test_role;                                -- ERROR
DROP SERVER t1 CASCADE;
---END---
---START---
DROP USER MAPPING FOR regress_test_role SERVER s6;
---END---
---START---
DROP FOREIGN DATA WRAPPER foo CASCADE;
---END---
---START---
DROP SERVER s8 CASCADE;
---END---
---START---
DROP ROLE regress_test_indirect;
---END---
---START---
DROP ROLE regress_test_role;
---END---
---START---
DROP ROLE regress_unprivileged_role;                        -- ERROR
REVOKE ALL ON FOREIGN DATA WRAPPER postgresql FROM regress_unprivileged_role;
---END---
---START---
DROP ROLE regress_unprivileged_role;
---END---
---START---
DROP ROLE regress_test_role2;
---END---
---START---
DROP FOREIGN DATA WRAPPER postgresql CASCADE;
---END---
---START---
DROP FOREIGN DATA WRAPPER dummy CASCADE;
---END---
---START---
\c
DROP ROLE regress_foreign_data_user;
---END---
---START---

-- At this point we should have no wrappers, no servers, and no mappings.
SELECT fdwname, fdwhandler, fdwvalidator, fdwoptions FROM pg_foreign_data_wrapper;
---END---
---START---
SELECT srvname, srvoptions FROM pg_foreign_server;
---END---
---START---
SELECT * FROM pg_user_mapping;
---END---
