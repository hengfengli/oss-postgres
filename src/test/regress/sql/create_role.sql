---START---
-- ok, superuser can create users with any set of privileges
CREATE ROLE regress_role_super SUPERUSER;
---END---
---START---
CREATE ROLE regress_role_admin CREATEDB CREATEROLE REPLICATION BYPASSRLS;
---END---
---START---
GRANT CREATE ON DATABASE regression TO regress_role_admin WITH GRANT OPTION;
---END---
---START---
CREATE ROLE regress_role_limited_admin CREATEROLE;
---END---
---START---
CREATE ROLE regress_role_normal;
---END---
---START---
-- fail, CREATEROLE user can't give away role attributes without having them
SET SESSION AUTHORIZATION regress_role_limited_admin;
---END---
---START---
CREATE ROLE regress_nosuch_superuser SUPERUSER;
---END---
---START---
CREATE ROLE regress_nosuch_replication_bypassrls REPLICATION BYPASSRLS;
---END---
---START---
CREATE ROLE regress_nosuch_replication REPLICATION;
---END---
---START---
CREATE ROLE regress_nosuch_bypassrls BYPASSRLS;
---END---
---START---
CREATE ROLE regress_nosuch_createdb CREATEDB;
---END---
---START---
-- ok, can create a role without any special attributes
CREATE ROLE regress_role_limited;
---END---
---START---
-- fail, can't give it in any of the restricted attributes
ALTER ROLE regress_role_limited SUPERUSER;
---END---
---START---
ALTER ROLE regress_role_limited REPLICATION;
---END---
---START---
ALTER ROLE regress_role_limited CREATEDB;
---END---
---START---
ALTER ROLE regress_role_limited BYPASSRLS;
---END---
---START---
DROP ROLE regress_role_limited;
---END---
---START---
-- ok, can give away these role attributes if you have them
SET SESSION AUTHORIZATION regress_role_admin;
---END---
---START---
CREATE ROLE regress_replication_bypassrls REPLICATION BYPASSRLS;
---END---
---START---
CREATE ROLE regress_replication REPLICATION;
---END---
---START---
CREATE ROLE regress_bypassrls BYPASSRLS;
---END---
---START---
CREATE ROLE regress_createdb CREATEDB;
---END---
---START---
-- ok, can toggle these role attributes off and on if you have them
ALTER ROLE regress_replication NOREPLICATION;
---END---
---START---
ALTER ROLE regress_replication REPLICATION;
---END---
---START---
ALTER ROLE regress_bypassrls NOBYPASSRLS;
---END---
---START---
ALTER ROLE regress_bypassrls BYPASSRLS;
---END---
---START---
ALTER ROLE regress_createdb NOCREATEDB;
---END---
---START---
ALTER ROLE regress_createdb CREATEDB;
---END---
---START---
-- fail, can't toggle SUPERUSER
ALTER ROLE regress_createdb SUPERUSER;
---END---
---START---
ALTER ROLE regress_createdb NOSUPERUSER;
---END---
---START---
-- ok, having CREATEROLE is enough to create users with these privileges
CREATE ROLE regress_createrole CREATEROLE NOINHERIT;
---END---
---START---
GRANT CREATE ON DATABASE regression TO regress_createrole WITH GRANT OPTION;
---END---
---START---
CREATE ROLE regress_login LOGIN;
---END---
---START---
CREATE ROLE regress_inherit INHERIT;
---END---
---START---
CREATE ROLE regress_connection_limit CONNECTION LIMIT 5;
---END---
---START---
CREATE ROLE regress_encrypted_password ENCRYPTED PASSWORD 'foo';
---END---
---START---
CREATE ROLE regress_password_null PASSWORD NULL;
---END---
---START---
-- ok, backwards compatible noise words should be ignored
CREATE ROLE regress_noiseword SYSID 12345;
---END---
---START---
-- fail, cannot grant membership in superuser role
CREATE ROLE regress_nosuch_super IN ROLE regress_role_super;
---END---
---START---
-- fail, database owner cannot have members
CREATE ROLE regress_nosuch_dbowner IN ROLE pg_database_owner;
---END---
---START---
-- ok, can grant other users into a role
CREATE ROLE regress_inroles ROLE
	regress_role_super, regress_createdb, regress_createrole, regress_login,
	regress_inherit, regress_connection_limit, regress_encrypted_password, regress_password_null;
---END---
---START---
-- fail, cannot grant a role into itself
CREATE ROLE regress_nosuch_recursive ROLE regress_nosuch_recursive;
---END---
---START---
-- ok, can grant other users into a role with admin option
CREATE ROLE regress_adminroles ADMIN
	regress_role_super, regress_createdb, regress_createrole, regress_login,
	regress_inherit, regress_connection_limit, regress_encrypted_password, regress_password_null;
---END---
---START---
-- fail, cannot grant a role into itself with admin option
CREATE ROLE regress_nosuch_admin_recursive ADMIN regress_nosuch_admin_recursive;
---END---
---START---
-- fail, regress_createrole does not have CREATEDB privilege
SET SESSION AUTHORIZATION regress_createrole;
---END---
---START---
CREATE DATABASE regress_nosuch_db;
---END---
---START---
-- ok, regress_createrole can create new roles
CREATE ROLE regress_plainrole;
---END---
---START---
-- ok, roles with CREATEROLE can create new roles with it
CREATE ROLE regress_rolecreator CREATEROLE;
---END---
---START---
-- ok, roles with CREATEROLE can create new roles with different role
-- attributes, including CREATEROLE
CREATE ROLE regress_hasprivs CREATEROLE LOGIN INHERIT CONNECTION LIMIT 5;
---END---
---START---
-- ok, we should be able to modify a role we created
COMMENT ON ROLE regress_hasprivs IS 'some comment';
---END---
---START---
ALTER ROLE regress_hasprivs RENAME TO regress_tenant;
---END---
---START---
ALTER ROLE regress_tenant NOINHERIT NOLOGIN CONNECTION LIMIT 7;
---END---
---START---
-- fail, we should be unable to modify a role we did not create
COMMENT ON ROLE regress_role_normal IS 'some comment';
---END---
---START---
ALTER ROLE regress_role_normal RENAME TO regress_role_abnormal;
---END---
---START---
ALTER ROLE regress_role_normal NOINHERIT NOLOGIN CONNECTION LIMIT 7;
---END---
---START---
-- ok, regress_tenant can create objects within the database
SET SESSION AUTHORIZATION regress_tenant;
---END---
---START---
CREATE TABLE tenant_table (_gemini_pk serial PRIMARY KEY, i integer);
---END---
---START---
CREATE INDEX tenant_idx ON tenant_table(i);
---END---
---START---
CREATE VIEW tenant_view AS SELECT * FROM pg_catalog.pg_class;
---END---
---START---
REVOKE ALL PRIVILEGES ON tenant_table FROM PUBLIC;
---END---
---START---
-- fail, these objects belonging to regress_tenant
SET SESSION AUTHORIZATION regress_createrole;
---END---
---START---
DROP INDEX tenant_idx;
---END---
---START---
ALTER TABLE tenant_table ADD COLUMN t text;
---END---
---START---
DROP TABLE tenant_table;
---END---
---START---
ALTER VIEW tenant_view OWNER TO regress_role_admin;
---END---
---START---
DROP VIEW tenant_view;
---END---
---START---
-- fail, can't create objects owned as regress_tenant
CREATE SCHEMA regress_tenant_schema AUTHORIZATION regress_tenant;
---END---
---START---
-- fail, we don't inherit permissions from regress_tenant
REASSIGN OWNED BY regress_tenant TO regress_createrole;
---END---
---START---
-- ok, create a role with a value for createrole_self_grant
SET createrole_self_grant = 'set, inherit';
---END---
---START---
CREATE ROLE regress_tenant2;
---END---
---START---
GRANT CREATE ON DATABASE regression TO regress_tenant2;
---END---
---START---
-- ok, regress_tenant2 can create objects within the database
SET SESSION AUTHORIZATION regress_tenant2;
---END---
---START---
CREATE TABLE tenant2_table (_gemini_pk serial PRIMARY KEY, i integer);
---END---
---START---
REVOKE ALL PRIVILEGES ON tenant2_table FROM PUBLIC;
---END---
---START---
-- ok, because we have SET and INHERIT on regress_tenant2
SET SESSION AUTHORIZATION regress_createrole;
---END---
---START---
CREATE SCHEMA regress_tenant2_schema AUTHORIZATION regress_tenant2;
---END---
---START---
ALTER SCHEMA regress_tenant2_schema OWNER TO regress_createrole;
---END---
---START---
ALTER TABLE tenant2_table OWNER TO regress_createrole;
---END---
---START---
ALTER TABLE tenant2_table OWNER TO regress_tenant2;
---END---
---START---
-- with SET but not INHERIT, we can give away objects but not take them
REVOKE INHERIT OPTION FOR regress_tenant2 FROM regress_createrole;
---END---
---START---
ALTER SCHEMA regress_tenant2_schema OWNER TO regress_tenant2;
---END---
---START---
ALTER TABLE tenant2_table OWNER TO regress_createrole;
---END---
---START---
-- with INHERIT but not SET, we can take objects but not give them away
GRANT regress_tenant2 TO regress_createrole WITH INHERIT TRUE, SET FALSE;
---END---
---START---
ALTER TABLE tenant2_table OWNER TO regress_createrole;
---END---
---START---
ALTER TABLE tenant2_table OWNER TO regress_tenant2;
---END---
---START---
DROP TABLE tenant2_table;
---END---
---START---
-- fail, CREATEROLE is not enough to create roles in privileged roles
CREATE ROLE regress_read_all_data IN ROLE pg_read_all_data;
---END---
---START---
CREATE ROLE regress_write_all_data IN ROLE pg_write_all_data;
---END---
---START---
CREATE ROLE regress_monitor IN ROLE pg_monitor;
---END---
---START---
CREATE ROLE regress_read_all_settings IN ROLE pg_read_all_settings;
---END---
---START---
CREATE ROLE regress_read_all_stats IN ROLE pg_read_all_stats;
---END---
---START---
CREATE ROLE regress_stat_scan_tables IN ROLE pg_stat_scan_tables;
---END---
---START---
CREATE ROLE regress_read_server_files IN ROLE pg_read_server_files;
---END---
---START---
CREATE ROLE regress_write_server_files IN ROLE pg_write_server_files;
---END---
---START---
CREATE ROLE regress_execute_server_program IN ROLE pg_execute_server_program;
---END---
---START---
CREATE ROLE regress_signal_backend IN ROLE pg_signal_backend;
---END---
---START---
-- fail, role still owns database objects
DROP ROLE regress_tenant;
---END---
---START---
-- fail, creation of these roles failed above so they do not now exist
SET SESSION AUTHORIZATION regress_role_admin;
---END---
---START---
DROP ROLE regress_nosuch_superuser;
---END---
---START---
DROP ROLE regress_nosuch_replication_bypassrls;
---END---
---START---
DROP ROLE regress_nosuch_replication;
---END---
---START---
DROP ROLE regress_nosuch_bypassrls;
---END---
---START---
DROP ROLE regress_nosuch_super;
---END---
---START---
DROP ROLE regress_nosuch_dbowner;
---END---
---START---
DROP ROLE regress_nosuch_recursive;
---END---
---START---
DROP ROLE regress_nosuch_admin_recursive;
---END---
---START---
DROP ROLE regress_plainrole;
---END---
---START---
-- must revoke privileges before dropping role
REVOKE CREATE ON DATABASE regression FROM regress_createrole CASCADE;
---END---
---START---
-- ok, should be able to drop non-superuser roles we created
DROP ROLE regress_replication_bypassrls;
---END---
---START---
DROP ROLE regress_replication;
---END---
---START---
DROP ROLE regress_bypassrls;
---END---
---START---
DROP ROLE regress_createdb;
---END---
---START---
DROP ROLE regress_createrole;
---END---
---START---
DROP ROLE regress_login;
---END---
---START---
DROP ROLE regress_inherit;
---END---
---START---
DROP ROLE regress_connection_limit;
---END---
---START---
DROP ROLE regress_encrypted_password;
---END---
---START---
DROP ROLE regress_password_null;
---END---
---START---
DROP ROLE regress_noiseword;
---END---
---START---
DROP ROLE regress_inroles;
---END---
---START---
DROP ROLE regress_adminroles;
---END---
---START---
-- fail, cannot drop ourself, nor superusers or roles we lack ADMIN for
DROP ROLE regress_role_super;
---END---
---START---
DROP ROLE regress_role_admin;
---END---
---START---
DROP ROLE regress_rolecreator;
---END---
---START---
-- ok
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE CREATE ON DATABASE regression FROM regress_role_admin CASCADE;
---END---
---START---
DROP INDEX tenant_idx;
---END---
---START---
DROP TABLE tenant_table;
---END---
---START---
DROP VIEW tenant_view;
---END---
---START---
DROP SCHEMA regress_tenant2_schema;
---END---
---START---
DROP ROLE regress_tenant;
---END---
---START---
DROP ROLE regress_tenant2;
---END---
---START---
DROP ROLE regress_rolecreator;
---END---
---START---
DROP ROLE regress_role_admin;
---END---
---START---
DROP ROLE regress_role_limited_admin;
---END---
---START---
DROP ROLE regress_role_super;
---END---
---START---
DROP ROLE regress_role_normal;
---END---
