---START---
-- default for superuser is false
CREATE ROLE regress_test_def_superuser;
---END---
---START---

SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_superuser';
---END---
---START---
CREATE ROLE regress_test_superuser WITH SUPERUSER;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_superuser';
---END---
---START---
ALTER ROLE regress_test_superuser WITH NOSUPERUSER;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_superuser';
---END---
---START---
ALTER ROLE regress_test_superuser WITH SUPERUSER;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_superuser';
---END---
---START---

-- default for inherit is true
CREATE ROLE regress_test_def_inherit;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_inherit';
---END---
---START---
CREATE ROLE regress_test_inherit WITH NOINHERIT;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_inherit';
---END---
---START---
ALTER ROLE regress_test_inherit WITH INHERIT;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_inherit';
---END---
---START---
ALTER ROLE regress_test_inherit WITH NOINHERIT;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_inherit';
---END---
---START---

-- default for create role is false
CREATE ROLE regress_test_def_createrole;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_createrole';
---END---
---START---
CREATE ROLE regress_test_createrole WITH CREATEROLE;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_createrole';
---END---
---START---
ALTER ROLE regress_test_createrole WITH NOCREATEROLE;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_createrole';
---END---
---START---
ALTER ROLE regress_test_createrole WITH CREATEROLE;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_createrole';
---END---
---START---

-- default for create database is false
CREATE ROLE regress_test_def_createdb;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_createdb';
---END---
---START---
CREATE ROLE regress_test_createdb WITH CREATEDB;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_createdb';
---END---
---START---
ALTER ROLE regress_test_createdb WITH NOCREATEDB;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_createdb';
---END---
---START---
ALTER ROLE regress_test_createdb WITH CREATEDB;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_createdb';
---END---
---START---

-- default for can login is false for role
CREATE ROLE regress_test_def_role_canlogin;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_role_canlogin';
---END---
---START---
CREATE ROLE regress_test_role_canlogin WITH LOGIN;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_role_canlogin';
---END---
---START---
ALTER ROLE regress_test_role_canlogin WITH NOLOGIN;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_role_canlogin';
---END---
---START---
ALTER ROLE regress_test_role_canlogin WITH LOGIN;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_role_canlogin';
---END---
---START---

-- default for can login is true for user
CREATE USER regress_test_def_user_canlogin;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_user_canlogin';
---END---
---START---
CREATE USER regress_test_user_canlogin WITH NOLOGIN;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_user_canlogin';
---END---
---START---
ALTER USER regress_test_user_canlogin WITH LOGIN;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_user_canlogin';
---END---
---START---
ALTER USER regress_test_user_canlogin WITH NOLOGIN;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_user_canlogin';
---END---
---START---

-- default for replication is false
CREATE ROLE regress_test_def_replication;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_replication';
---END---
---START---
CREATE ROLE regress_test_replication WITH REPLICATION;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_replication';
---END---
---START---
ALTER ROLE regress_test_replication WITH NOREPLICATION;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_replication';
---END---
---START---
ALTER ROLE regress_test_replication WITH REPLICATION;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_replication';
---END---
---START---

-- default for bypassrls is false
CREATE ROLE regress_test_def_bypassrls;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_def_bypassrls';
---END---
---START---
CREATE ROLE regress_test_bypassrls WITH BYPASSRLS;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_bypassrls';
---END---
---START---
ALTER ROLE regress_test_bypassrls WITH NOBYPASSRLS;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_bypassrls';
---END---
---START---
ALTER ROLE regress_test_bypassrls WITH BYPASSRLS;
---END---
---START---
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls, rolconnlimit, rolpassword, rolvaliduntil FROM pg_authid WHERE rolname = 'regress_test_bypassrls';
---END---
---START---

-- clean up roles
DROP ROLE regress_test_def_superuser;
---END---
---START---
DROP ROLE regress_test_superuser;
---END---
---START---
DROP ROLE regress_test_def_inherit;
---END---
---START---
DROP ROLE regress_test_inherit;
---END---
---START---
DROP ROLE regress_test_def_createrole;
---END---
---START---
DROP ROLE regress_test_createrole;
---END---
---START---
DROP ROLE regress_test_def_createdb;
---END---
---START---
DROP ROLE regress_test_createdb;
---END---
---START---
DROP ROLE regress_test_def_role_canlogin;
---END---
---START---
DROP ROLE regress_test_role_canlogin;
---END---
---START---
DROP USER regress_test_def_user_canlogin;
---END---
---START---
DROP USER regress_test_user_canlogin;
---END---
---START---
DROP ROLE regress_test_def_replication;
---END---
---START---
DROP ROLE regress_test_replication;
---END---
---START---
DROP ROLE regress_test_def_bypassrls;
---END---
---START---
DROP ROLE regress_test_bypassrls;
---END---
