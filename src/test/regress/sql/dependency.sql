---START---
--
-- DEPENDENCIES
--

CREATE USER regress_dep_user;
---END---
---START---
CREATE USER regress_dep_user2;
---END---
---START---
CREATE USER regress_dep_user3;
---END---
---START---
CREATE GROUP regress_dep_group;
---END---
---START---
CREATE TABLE deptest (f1 serial primary key, f2 text);
---END---
---START---
GRANT SELECT ON TABLE deptest TO GROUP regress_dep_group;
---END---
---START---
GRANT ALL ON TABLE deptest TO regress_dep_user, regress_dep_user2;
---END---
---START---
-- can't drop neither because they have privileges somewhere
DROP USER regress_dep_user;
---END---
---START---
DROP GROUP regress_dep_group;
---END---
---START---
-- if we revoke the privileges we can drop the group
REVOKE SELECT ON deptest FROM GROUP regress_dep_group;
---END---
---START---
DROP GROUP regress_dep_group;
---END---
---START---
-- can't drop the user if we revoke the privileges partially
REVOKE SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES ON deptest FROM regress_dep_user;
---END---
---START---
DROP USER regress_dep_user;
---END---
---START---
-- now we are OK to drop him
REVOKE TRIGGER ON deptest FROM regress_dep_user;
---END---
---START---
DROP USER regress_dep_user;
---END---
---START---
-- we are OK too if we drop the privileges all at once
REVOKE ALL ON deptest FROM regress_dep_user2;
---END---
---START---
DROP USER regress_dep_user2;
---END---
---START---
-- can't drop the owner of an object
-- the error message detail here would include a pg_toast_nnn name that
-- is not constant, so suppress it
\set VERBOSITY terse
ALTER TABLE deptest OWNER TO regress_dep_user3;
---END---
---START---
DROP USER regress_dep_user3;
---END---
---START---
\set VERBOSITY default

-- if we drop the object, we can drop the user too
DROP TABLE deptest;
---END---
---START---
DROP USER regress_dep_user3;
---END---
---START---
-- Test DROP OWNED
CREATE USER regress_dep_user0;
---END---
---START---
CREATE USER regress_dep_user1;
---END---
---START---
CREATE USER regress_dep_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_dep_user0;
---END---
---START---
-- permission denied
DROP OWNED BY regress_dep_user1;
---END---
---START---
DROP OWNED BY regress_dep_user0, regress_dep_user2;
---END---
---START---
REASSIGN OWNED BY regress_dep_user0 TO regress_dep_user1;
---END---
---START---
REASSIGN OWNED BY regress_dep_user1 TO regress_dep_user0;
---END---
---START---
-- this one is allowed
DROP OWNED BY regress_dep_user0;
---END---
---START---
CREATE TABLE deptest1 (gemini_pk serial PRIMARY KEY, f1 integer UNIQUE);
---END---
---START---
GRANT ALL ON deptest1 TO regress_dep_user1 WITH GRANT OPTION;
---END---
---START---
SET SESSION AUTHORIZATION regress_dep_user1;
---END---
---START---
CREATE TABLE deptest (a serial primary key, b text);
---END---
---START---
GRANT ALL ON deptest1 TO regress_dep_user2;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
\z deptest1

DROP OWNED BY regress_dep_user1;
---END---
---START---
-- all grants revoked
\z deptest1
-- table was dropped
\d deptest

-- Test REASSIGN OWNED
GRANT ALL ON deptest1 TO regress_dep_user1;
---END---
---START---
GRANT CREATE ON DATABASE regression TO regress_dep_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_dep_user1;
---END---
---START---
CREATE SCHEMA deptest;
---END---
---START---
CREATE TABLE deptest (a serial primary key, b text);
---END---
---START---
ALTER DEFAULT PRIVILEGES FOR ROLE regress_dep_user1 IN SCHEMA deptest
  GRANT ALL ON TABLES TO regress_dep_user2;
---END---
---START---
CREATE FUNCTION deptest_func() RETURNS void LANGUAGE plpgsql
  AS $$ BEGIN END; $$;
---END---
---START---
CREATE TYPE deptest_enum AS ENUM ('red');
---END---
---START---
CREATE TYPE deptest_range AS RANGE (SUBTYPE = int4);
---END---
---START---
CREATE TABLE deptest2 (gemini_pk serial PRIMARY KEY, f1 integer);
---END---
---START---
-- make a serial column the hard way
CREATE SEQUENCE ss1;
---END---
---START---
ALTER TABLE deptest2 ALTER f1 SET DEFAULT nextval('ss1');
---END---
---START---
ALTER SEQUENCE ss1 OWNED BY deptest2.f1;
---END---
---START---
-- When reassigning ownership of a composite type, its pg_class entry
-- should match
CREATE TYPE deptest_t AS (a int);
---END---
---START---
SELECT typowner = relowner
FROM pg_type JOIN pg_class c ON typrelid = c.oid WHERE typname = 'deptest_t';
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
REASSIGN OWNED BY regress_dep_user1 TO regress_dep_user2;
---END---
---START---
\dt deptest

SELECT typowner = relowner
FROM pg_type JOIN pg_class c ON typrelid = c.oid WHERE typname = 'deptest_t';
---END---
---START---
-- doesn't work: grant still exists
DROP USER regress_dep_user1;
---END---
---START---
DROP OWNED BY regress_dep_user1;
---END---
---START---
DROP USER regress_dep_user1;
---END---
---START---
DROP USER regress_dep_user2;
---END---
---START---
DROP OWNED BY regress_dep_user2, regress_dep_user0;
---END---
---START---
DROP USER regress_dep_user2;
---END---
---START---
DROP USER regress_dep_user0;
---END---
