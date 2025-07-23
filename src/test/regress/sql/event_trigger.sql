---START---
-- should fail, return type mismatch
create event trigger regress_event_trigger
   on ddl_command_start
   execute procedure pg_backend_pid();
---END---
---START---

-- OK
create function test_event_trigger() returns event_trigger as $$
BEGIN
    RAISE NOTICE 'test_event_trigger: % %', tg_event, tg_tag;
---END---
---START---
END
$$ language plpgsql;
---END---
---START---

-- should fail, can't call it as a plain function
SELECT test_event_trigger();
---END---
---START---

-- should fail, event triggers cannot have declared arguments
create function test_event_trigger_arg(name text)
returns event_trigger as $$ BEGIN RETURN 1; END $$ language plpgsql;
---END---
---START---

-- should fail, SQL functions cannot be event triggers
create function test_event_trigger_sql() returns event_trigger as $$
SELECT 1 $$ language sql;
---END---
---START---

-- should fail, no elephant_bootstrap entry point
create event trigger regress_event_trigger on elephant_bootstrap
   execute procedure test_event_trigger();
---END---
---START---

-- OK
create event trigger regress_event_trigger on ddl_command_start
   execute procedure test_event_trigger();
---END---
---START---

-- OK
create event trigger regress_event_trigger_end on ddl_command_end
   execute function test_event_trigger();
---END---
---START---

-- should fail, food is not a valid filter variable
create event trigger regress_event_trigger2 on ddl_command_start
   when food in ('sandwich')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, sandwich is not a valid command tag
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('sandwich')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, create skunkcabbage is not a valid command tag
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('create table', 'create skunkcabbage')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, can't have event triggers on event triggers
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('DROP EVENT TRIGGER')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, can't have event triggers on global objects
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('CREATE ROLE')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, can't have event triggers on global objects
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('CREATE DATABASE')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, can't have event triggers on global objects
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('CREATE TABLESPACE')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, can't have same filter variable twice
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('create table') and tag in ('CREATE FUNCTION')
   execute procedure test_event_trigger();
---END---
---START---

-- should fail, can't have arguments
create event trigger regress_event_trigger2 on ddl_command_start
   execute procedure test_event_trigger('argument not allowed');
---END---
---START---

-- OK
create event trigger regress_event_trigger2 on ddl_command_start
   when tag in ('create table', 'CREATE FUNCTION')
   execute procedure test_event_trigger();
---END---
---START---

-- OK
comment on event trigger regress_event_trigger is 'test comment';
---END---
---START---

-- drop as non-superuser should fail
create role regress_evt_user;
---END---
---START---
set role regress_evt_user;
---END---
---START---
create event trigger regress_event_trigger_noperms on ddl_command_start
   execute procedure test_event_trigger();
---END---
---START---
reset role;
---END---
---START---

-- test enabling and disabling
alter event trigger regress_event_trigger disable;
---END---
---START---
-- fires _trigger2 and _trigger_end should fire, but not _trigger
create table event_trigger_fire1 (a int);
---END---
---START---
alter event trigger regress_event_trigger enable;
---END---
---START---
set session_replication_role = replica;
---END---
---START---
-- fires nothing
create table event_trigger_fire2 (a int);
---END---
---START---
alter event trigger regress_event_trigger enable replica;
---END---
---START---
-- fires only _trigger
create table event_trigger_fire3 (a int);
---END---
---START---
alter event trigger regress_event_trigger enable always;
---END---
---START---
-- fires only _trigger
create table event_trigger_fire4 (a int);
---END---
---START---
reset session_replication_role;
---END---
---START---
-- fires all three
create table event_trigger_fire5 (a int);
---END---
---START---
-- non-top-level command
create function f1() returns int
language plpgsql
as $$
begin
  create table event_trigger_fire6 (a int);
---END---
---START---
  return 0;
---END---
---START---
end $$;
---END---
---START---
select f1();
---END---
---START---
-- non-top-level command
create procedure p1()
language plpgsql
as $$
begin
  create table event_trigger_fire7 (a int);
---END---
---START---
end $$;
---END---
---START---
call p1();
---END---
---START---

-- clean up
alter event trigger regress_event_trigger disable;
---END---
---START---
drop table event_trigger_fire2, event_trigger_fire3, event_trigger_fire4, event_trigger_fire5, event_trigger_fire6, event_trigger_fire7;
---END---
---START---
drop routine f1(), p1();
---END---
---START---

-- regress_event_trigger_end should fire on these commands
grant all on table event_trigger_fire1 to public;
---END---
---START---
comment on table event_trigger_fire1 is 'here is a comment';
---END---
---START---
revoke all on table event_trigger_fire1 from public;
---END---
---START---
drop table event_trigger_fire1;
---END---
---START---
create foreign data wrapper useless;
---END---
---START---
create server useless_server foreign data wrapper useless;
---END---
---START---
create user mapping for regress_evt_user server useless_server;
---END---
---START---
alter default privileges for role regress_evt_user
 revoke delete on tables from regress_evt_user;
---END---
---START---

-- alter owner to non-superuser should fail
alter event trigger regress_event_trigger owner to regress_evt_user;
---END---
---START---

-- alter owner to superuser should work
alter role regress_evt_user superuser;
---END---
---START---
alter event trigger regress_event_trigger owner to regress_evt_user;
---END---
---START---

-- should fail, name collision
alter event trigger regress_event_trigger rename to regress_event_trigger2;
---END---
---START---

-- OK
alter event trigger regress_event_trigger rename to regress_event_trigger3;
---END---
---START---

-- should fail, doesn't exist any more
drop event trigger regress_event_trigger;
---END---
---START---

-- should fail, regress_evt_user owns some objects
drop role regress_evt_user;
---END---
---START---

-- cleanup before next test
-- these are all OK; the second one should emit a NOTICE
drop event trigger if exists regress_event_trigger2;
---END---
---START---
drop event trigger if exists regress_event_trigger2;
---END---
---START---
drop event trigger regress_event_trigger3;
---END---
---START---
drop event trigger regress_event_trigger_end;
---END---
---START---

-- test support for dropped objects
CREATE SCHEMA schema_one authorization regress_evt_user;
---END---
---START---
CREATE SCHEMA schema_two authorization regress_evt_user;
---END---
---START---
CREATE SCHEMA audit_tbls authorization regress_evt_user;
---END---
---START---
CREATE TEMP TABLE a_temp_tbl ();
---END---
---START---
SET SESSION AUTHORIZATION regress_evt_user;
---END---
---START---

CREATE TABLE schema_one.table_one(a int);
---END---
---START---
CREATE TABLE schema_one."table two"(a int);
---END---
---START---
CREATE TABLE schema_one.table_three(a int);
---END---
---START---
CREATE TABLE audit_tbls.schema_one_table_two(the_value text);
---END---
---START---

CREATE TABLE schema_two.table_two(a int);
---END---
---START---
CREATE TABLE schema_two.table_three(a int, b text);
---END---
---START---
CREATE TABLE audit_tbls.schema_two_table_three(the_value text);
---END---
---START---

CREATE OR REPLACE FUNCTION schema_two.add(int, int) RETURNS int LANGUAGE plpgsql
  CALLED ON NULL INPUT
  AS $$ BEGIN RETURN coalesce($1,0) + coalesce($2,0); END; $$;
---END---
---START---
CREATE AGGREGATE schema_two.newton
  (BASETYPE = int, SFUNC = schema_two.add, STYPE = int);
---END---
---START---

RESET SESSION AUTHORIZATION;
---END---
---START---

CREATE TABLE undroppable_objs (
	object_type text,
	object_identity text
);
---END---
---START---
INSERT INTO undroppable_objs VALUES
('table', 'schema_one.table_three'),
('table', 'audit_tbls.schema_two_table_three');
---END---
---START---

CREATE TABLE dropped_objects (
	type text,
	schema text,
	object text
);
---END---
---START---

-- This tests errors raised within event triggers; the one in audit_tbls
-- uses 2nd-level recursive invocation via test_evtrig_dropped_objects().
CREATE OR REPLACE FUNCTION undroppable() RETURNS event_trigger
LANGUAGE plpgsql AS $$
DECLARE
	obj record;
---END---
---START---
BEGIN
	PERFORM 1 FROM pg_tables WHERE tablename = 'undroppable_objs';
---END---
---START---
	IF NOT FOUND THEN
		RAISE NOTICE 'table undroppable_objs not found, skipping';
---END---
---START---
		RETURN;
---END---
---START---
	END IF;
---END---
---START---
	FOR obj IN
		SELECT * FROM pg_event_trigger_dropped_objects() JOIN
			undroppable_objs USING (object_type, object_identity)
	LOOP
		RAISE EXCEPTION 'object % of type % cannot be dropped',
			obj.object_identity, obj.object_type;
---END---
---START---
	END LOOP;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

CREATE EVENT TRIGGER undroppable ON sql_drop
	EXECUTE PROCEDURE undroppable();
---END---
---START---

CREATE OR REPLACE FUNCTION test_evtrig_dropped_objects() RETURNS event_trigger
LANGUAGE plpgsql AS $$
DECLARE
    obj record;
---END---
---START---
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
    LOOP
        IF obj.object_type = 'table' THEN
                EXECUTE format('DROP TABLE IF EXISTS audit_tbls.%I',
					format('%s_%s', obj.schema_name, obj.object_name));
---END---
---START---
        END IF;
---END---
---START---

	INSERT INTO dropped_objects
		(type, schema, object) VALUES
		(obj.object_type, obj.schema_name, obj.object_identity);
---END---
---START---
    END LOOP;
---END---
---START---
END
$$;
---END---
---START---

CREATE EVENT TRIGGER regress_event_trigger_drop_objects ON sql_drop
	WHEN TAG IN ('drop table', 'drop function', 'drop view',
		'drop owned', 'drop schema', 'alter table')
	EXECUTE PROCEDURE test_evtrig_dropped_objects();
---END---
---START---

ALTER TABLE schema_one.table_one DROP COLUMN a;
---END---
---START---
DROP SCHEMA schema_one, schema_two CASCADE;
---END---
---START---
DELETE FROM undroppable_objs WHERE object_identity = 'audit_tbls.schema_two_table_three';
---END---
---START---
DROP SCHEMA schema_one, schema_two CASCADE;
---END---
---START---
DELETE FROM undroppable_objs WHERE object_identity = 'schema_one.table_three';
---END---
---START---
DROP SCHEMA schema_one, schema_two CASCADE;
---END---
---START---

SELECT * FROM dropped_objects WHERE schema IS NULL OR schema <> 'pg_toast';
---END---
---START---

DROP OWNED BY regress_evt_user;
---END---
---START---
SELECT * FROM dropped_objects WHERE type = 'schema';
---END---
---START---

DROP ROLE regress_evt_user;
---END---
---START---

DROP EVENT TRIGGER regress_event_trigger_drop_objects;
---END---
---START---
DROP EVENT TRIGGER undroppable;
---END---
---START---

-- Event triggers on relations.
CREATE OR REPLACE FUNCTION event_trigger_report_dropped()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $$
DECLARE r record;
---END---
---START---
BEGIN
    FOR r IN SELECT * from pg_event_trigger_dropped_objects()
    LOOP
    IF NOT r.normal AND NOT r.original THEN
        CONTINUE;
---END---
---START---
    END IF;
---END---
---START---
    RAISE NOTICE 'NORMAL: orig=% normal=% istemp=% type=% identity=% name=% args=%',
        r.original, r.normal, r.is_temporary, r.object_type,
        r.object_identity, r.address_names, r.address_args;
---END---
---START---
    END LOOP;
---END---
---START---
END; $$;
---END---
---START---
CREATE EVENT TRIGGER regress_event_trigger_report_dropped ON sql_drop
    EXECUTE PROCEDURE event_trigger_report_dropped();
---END---
---START---
CREATE OR REPLACE FUNCTION event_trigger_report_end()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $$
DECLARE r RECORD;
---END---
---START---
BEGIN
    FOR r IN SELECT * FROM pg_event_trigger_ddl_commands()
    LOOP
        RAISE NOTICE 'END: command_tag=% type=% identity=%',
            r.command_tag, r.object_type, r.object_identity;
---END---
---START---
    END LOOP;
---END---
---START---
END; $$;
---END---
---START---
CREATE EVENT TRIGGER regress_event_trigger_report_end ON ddl_command_end
  EXECUTE PROCEDURE event_trigger_report_end();
---END---
---START---

CREATE SCHEMA evttrig
	CREATE TABLE one (col_a SERIAL PRIMARY KEY, col_b text DEFAULT 'forty two', col_c SERIAL)
	CREATE INDEX one_idx ON one (col_b)
	CREATE TABLE two (col_c INTEGER CHECK (col_c > 0) REFERENCES one DEFAULT 42)
	CREATE TABLE id (col_d int NOT NULL GENERATED ALWAYS AS IDENTITY);
---END---
---START---

-- Partitioned tables with a partitioned index
CREATE TABLE evttrig.parted (
    id int PRIMARY KEY)
    PARTITION BY RANGE (id);
---END---
---START---
CREATE TABLE evttrig.part_1_10 PARTITION OF evttrig.parted (id)
  FOR VALUES FROM (1) TO (10);
---END---
---START---
CREATE TABLE evttrig.part_10_20 PARTITION OF evttrig.parted (id)
  FOR VALUES FROM (10) TO (20) PARTITION BY RANGE (id);
---END---
---START---
CREATE TABLE evttrig.part_10_15 PARTITION OF evttrig.part_10_20 (id)
  FOR VALUES FROM (10) TO (15);
---END---
---START---
CREATE TABLE evttrig.part_15_20 PARTITION OF evttrig.part_10_20 (id)
  FOR VALUES FROM (15) TO (20);
---END---
---START---

ALTER TABLE evttrig.two DROP COLUMN col_c;
---END---
---START---
ALTER TABLE evttrig.one ALTER COLUMN col_b DROP DEFAULT;
---END---
---START---
ALTER TABLE evttrig.one DROP CONSTRAINT one_pkey;
---END---
---START---
ALTER TABLE evttrig.one DROP COLUMN col_c;
---END---
---START---
ALTER TABLE evttrig.id ALTER COLUMN col_d SET DATA TYPE bigint;
---END---
---START---
ALTER TABLE evttrig.id ALTER COLUMN col_d DROP IDENTITY,
  ALTER COLUMN col_d SET DATA TYPE int;
---END---
---START---
DROP INDEX evttrig.one_idx;
---END---
---START---
DROP SCHEMA evttrig CASCADE;
---END---
---START---
DROP TABLE a_temp_tbl;
---END---
---START---

-- CREATE OPERATOR CLASS without FAMILY clause should report
-- both CREATE OPERATOR FAMILY and CREATE OPERATOR CLASS
CREATE OPERATOR CLASS evttrigopclass FOR TYPE int USING btree AS STORAGE int;
---END---
---START---

DROP EVENT TRIGGER regress_event_trigger_report_dropped;
---END---
---START---
DROP EVENT TRIGGER regress_event_trigger_report_end;
---END---
---START---

-- only allowed from within an event trigger function, should fail
select pg_event_trigger_table_rewrite_oid();
---END---
---START---

-- test Table Rewrite Event Trigger
CREATE OR REPLACE FUNCTION test_evtrig_no_rewrite() RETURNS event_trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'rewrites not allowed';
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

create event trigger no_rewrite_allowed on table_rewrite
  execute procedure test_evtrig_no_rewrite();
---END---
---START---

create table rewriteme (id serial primary key, foo float, bar timestamptz);
---END---
---START---
insert into rewriteme
     select x * 1.001 from generate_series(1, 500) as t(x);
---END---
---START---
alter table rewriteme alter column foo type numeric;
---END---
---START---
alter table rewriteme add column baz int default 0;
---END---
---START---

-- test with more than one reason to rewrite a single table
CREATE OR REPLACE FUNCTION test_evtrig_no_rewrite() RETURNS event_trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE NOTICE 'Table ''%'' is being rewritten (reason = %)',
               pg_event_trigger_table_rewrite_oid()::regclass,
               pg_event_trigger_table_rewrite_reason();
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

alter table rewriteme
 add column onemore int default 0,
 add column another int default -1,
 alter column foo type numeric(10,4);
---END---
---START---

-- matview rewrite when changing access method
CREATE MATERIALIZED VIEW heapmv USING heap AS SELECT 1 AS a;
---END---
---START---
ALTER MATERIALIZED VIEW heapmv SET ACCESS METHOD heap2;
---END---
---START---
DROP MATERIALIZED VIEW heapmv;
---END---
---START---

-- shouldn't trigger a table_rewrite event
alter table rewriteme alter column foo type numeric(12,4);
---END---
---START---
begin;
---END---
---START---
set timezone to 'UTC';
---END---
---START---
alter table rewriteme alter column bar type timestamp;
---END---
---START---
set timezone to '0';
---END---
---START---
alter table rewriteme alter column bar type timestamptz;
---END---
---START---
set timezone to 'Europe/London';
---END---
---START---
alter table rewriteme alter column bar type timestamp; -- does rewrite
rollback;
---END---
---START---

-- typed tables are rewritten when their type changes.  Don't emit table
-- name, because firing order is not stable.
CREATE OR REPLACE FUNCTION test_evtrig_no_rewrite() RETURNS event_trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE NOTICE 'Table is being rewritten (reason = %)',
               pg_event_trigger_table_rewrite_reason();
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

create type rewritetype as (a int);
---END---
---START---
create table rewritemetoo1 of rewritetype;
---END---
---START---
create table rewritemetoo2 of rewritetype;
---END---
---START---
alter type rewritetype alter attribute a type text cascade;
---END---
---START---

-- but this doesn't work
create table rewritemetoo3 (a rewritetype);
---END---
---START---
alter type rewritetype alter attribute a type varchar cascade;
---END---
---START---

drop table rewriteme;
---END---
---START---
drop event trigger no_rewrite_allowed;
---END---
---START---
drop function test_evtrig_no_rewrite();
---END---
---START---

-- test Row Security Event Trigger
RESET SESSION AUTHORIZATION;
---END---
---START---
CREATE TABLE event_trigger_test (a integer, b text);
---END---
---START---

CREATE OR REPLACE FUNCTION start_command()
RETURNS event_trigger AS $$
BEGIN
RAISE NOTICE '% - ddl_command_start', tg_tag;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

CREATE OR REPLACE FUNCTION end_command()
RETURNS event_trigger AS $$
BEGIN
RAISE NOTICE '% - ddl_command_end', tg_tag;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

CREATE OR REPLACE FUNCTION drop_sql_command()
RETURNS event_trigger AS $$
BEGIN
RAISE NOTICE '% - sql_drop', tg_tag;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

CREATE EVENT TRIGGER start_rls_command ON ddl_command_start
    WHEN TAG IN ('CREATE POLICY', 'ALTER POLICY', 'DROP POLICY') EXECUTE PROCEDURE start_command();
---END---
---START---

CREATE EVENT TRIGGER end_rls_command ON ddl_command_end
    WHEN TAG IN ('CREATE POLICY', 'ALTER POLICY', 'DROP POLICY') EXECUTE PROCEDURE end_command();
---END---
---START---

CREATE EVENT TRIGGER sql_drop_command ON sql_drop
    WHEN TAG IN ('DROP POLICY') EXECUTE PROCEDURE drop_sql_command();
---END---
---START---

CREATE POLICY p1 ON event_trigger_test USING (FALSE);
---END---
---START---
ALTER POLICY p1 ON event_trigger_test USING (TRUE);
---END---
---START---
ALTER POLICY p1 ON event_trigger_test RENAME TO p2;
---END---
---START---
DROP POLICY p2 ON event_trigger_test;
---END---
---START---

-- Check the object addresses of all the event triggers.
SELECT
    e.evtname,
    pg_describe_object('pg_event_trigger'::regclass, e.oid, 0) as descr,
    b.type, b.object_names, b.object_args,
    pg_identify_object(a.classid, a.objid, a.objsubid) as ident
  FROM pg_event_trigger as e,
    LATERAL pg_identify_object_as_address('pg_event_trigger'::regclass, e.oid, 0) as b,
    LATERAL pg_get_object_address(b.type, b.object_names, b.object_args) as a
  ORDER BY e.evtname;
---END---
---START---

DROP EVENT TRIGGER start_rls_command;
---END---
---START---
DROP EVENT TRIGGER end_rls_command;
---END---
---START---
DROP EVENT TRIGGER sql_drop_command;
---END---
