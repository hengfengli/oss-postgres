---START---
--
-- TRIGGERS
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set autoinclib :libdir '/autoinc' :dlsuffix
\set refintlib :libdir '/refint' :dlsuffix
\set regresslib :libdir '/regress' :dlsuffix

CREATE FUNCTION autoinc ()
	RETURNS trigger
	AS :'autoinclib'
	LANGUAGE C;
---END---
---START---
CREATE FUNCTION check_primary_key ()
	RETURNS trigger
	AS :'refintlib'
	LANGUAGE C;
---END---
---START---
CREATE FUNCTION check_foreign_key ()
	RETURNS trigger
	AS :'refintlib'
	LANGUAGE C;
---END---
---START---
CREATE FUNCTION trigger_return_old ()
        RETURNS trigger
        AS :'regresslib'
        LANGUAGE C;
---END---
---START---
CREATE FUNCTION set_ttdummy (int4)
        RETURNS int4
        AS :'regresslib'
        LANGUAGE C STRICT;
---END---
---START---
create table pkeys (pkey1 int4 not null, pkey2 text not null);
---END---
---START---
create table fkeys (fkey1 int4, fkey2 text, fkey3 int);
---END---
---START---
create table fkeys2 (fkey21 int4, fkey22 text, pkey23 int not null);
---END---
---START---
create index fkeys_i on fkeys (fkey1, fkey2);
---END---
---START---
create index fkeys2_i on fkeys2 (fkey21, fkey22);
---END---
---START---
create index fkeys2p_i on fkeys2 (pkey23);
---END---
---START---
insert into pkeys values (10, '1');
---END---
---START---
insert into pkeys values (20, '2');
---END---
---START---
insert into pkeys values (30, '3');
---END---
---START---
insert into pkeys values (40, '4');
---END---
---START---
insert into pkeys values (50, '5');
---END---
---START---
insert into pkeys values (60, '6');
---END---
---START---
create unique index pkeys_i on pkeys (pkey1, pkey2);
---END---
---START---
--
-- For fkeys:
-- 	(fkey1, fkey2)	--> pkeys (pkey1, pkey2)
-- 	(fkey3)		--> fkeys2 (pkey23)
--
create trigger check_fkeys_pkey_exist
	before insert or update on fkeys
	for each row
	execute function
	check_primary_key ('fkey1', 'fkey2', 'pkeys', 'pkey1', 'pkey2');
---END---
---START---
create trigger check_fkeys_pkey2_exist
	before insert or update on fkeys
	for each row
	execute function check_primary_key ('fkey3', 'fkeys2', 'pkey23');
---END---
---START---
--
-- For fkeys2:
-- 	(fkey21, fkey22)	--> pkeys (pkey1, pkey2)
--
create trigger check_fkeys2_pkey_exist
	before insert or update on fkeys2
	for each row
	execute procedure
	check_primary_key ('fkey21', 'fkey22', 'pkeys', 'pkey1', 'pkey2');
---END---
---START---
-- Test comments
COMMENT ON TRIGGER check_fkeys2_pkey_bad ON fkeys2 IS 'wrong';
---END---
---START---
COMMENT ON TRIGGER check_fkeys2_pkey_exist ON fkeys2 IS 'right';
---END---
---START---
COMMENT ON TRIGGER check_fkeys2_pkey_exist ON fkeys2 IS NULL;
---END---
---START---
--
-- For pkeys:
-- 	ON DELETE/UPDATE (pkey1, pkey2) CASCADE:
-- 		fkeys (fkey1, fkey2) and fkeys2 (fkey21, fkey22)
--
create trigger check_pkeys_fkey_cascade
	before delete or update on pkeys
	for each row
	execute procedure
	check_foreign_key (2, 'cascade', 'pkey1', 'pkey2',
	'fkeys', 'fkey1', 'fkey2', 'fkeys2', 'fkey21', 'fkey22');
---END---
---START---
--
-- For fkeys2:
-- 	ON DELETE/UPDATE (pkey23) RESTRICT:
-- 		fkeys (fkey3)
--
create trigger check_fkeys2_fkey_restrict
	before delete or update on fkeys2
	for each row
	execute procedure check_foreign_key (1, 'restrict', 'pkey23', 'fkeys', 'fkey3');
---END---
---START---
insert into fkeys2 values (10, '1', 1);
---END---
---START---
insert into fkeys2 values (30, '3', 2);
---END---
---START---
insert into fkeys2 values (40, '4', 5);
---END---
---START---
insert into fkeys2 values (50, '5', 3);
---END---
---START---
-- no key in pkeys
insert into fkeys2 values (70, '5', 3);
---END---
---START---
insert into fkeys values (10, '1', 2);
---END---
---START---
insert into fkeys values (30, '3', 3);
---END---
---START---
insert into fkeys values (40, '4', 2);
---END---
---START---
insert into fkeys values (50, '5', 2);
---END---
---START---
-- no key in pkeys
insert into fkeys values (70, '5', 1);
---END---
---START---
-- no key in fkeys2
insert into fkeys values (60, '6', 4);
---END---
---START---
delete from pkeys where pkey1 = 30 and pkey2 = '3';
---END---
---START---
delete from pkeys where pkey1 = 40 and pkey2 = '4';
---END---
---START---
update pkeys set pkey1 = 7, pkey2 = '70' where pkey1 = 50 and pkey2 = '5';
---END---
---START---
update pkeys set pkey1 = 7, pkey2 = '70' where pkey1 = 10 and pkey2 = '1';
---END---
---START---
SELECT trigger_name, event_manipulation, event_object_schema, event_object_table,
       action_order, action_condition, action_orientation, action_timing,
       action_reference_old_table, action_reference_new_table
  FROM information_schema.triggers
  WHERE event_object_table in ('pkeys', 'fkeys', 'fkeys2')
  ORDER BY trigger_name COLLATE "C", 2;
---END---
---START---
DROP TABLE pkeys;
---END---
---START---
DROP TABLE fkeys;
---END---
---START---
DROP TABLE fkeys2;
---END---
---START---
-- Check behavior when trigger returns unmodified trigtuple
create table trigtest (f1 int, f2 text);
---END---
---START---
create trigger trigger_return_old
	before insert or delete or update on trigtest
	for each row execute procedure trigger_return_old();
---END---
---START---
insert into trigtest values(1, 'foo');
---END---
---START---
select * from trigtest;
---END---
---START---
update trigtest set f2 = f2 || 'bar';
---END---
---START---
select * from trigtest;
---END---
---START---
delete from trigtest;
---END---
---START---
select * from trigtest;
---END---
---START---
-- Also check what happens when such a trigger runs before or after others
create function f1_times_10() returns trigger as
$$ begin new.f1 := new.f1 * 10; return new; end $$ language plpgsql;
---END---
---START---
create trigger trigger_alpha
	before insert or update on trigtest
	for each row execute procedure f1_times_10();
---END---
---START---
insert into trigtest values(1, 'foo');
---END---
---START---
select * from trigtest;
---END---
---START---
update trigtest set f2 = f2 || 'bar';
---END---
---START---
select * from trigtest;
---END---
---START---
delete from trigtest;
---END---
---START---
select * from trigtest;
---END---
---START---
create trigger trigger_zed
	before insert or update on trigtest
	for each row execute procedure f1_times_10();
---END---
---START---
insert into trigtest values(1, 'foo');
---END---
---START---
select * from trigtest;
---END---
---START---
update trigtest set f2 = f2 || 'bar';
---END---
---START---
select * from trigtest;
---END---
---START---
delete from trigtest;
---END---
---START---
select * from trigtest;
---END---
---START---
drop trigger trigger_alpha on trigtest;
---END---
---START---
insert into trigtest values(1, 'foo');
---END---
---START---
select * from trigtest;
---END---
---START---
update trigtest set f2 = f2 || 'bar';
---END---
---START---
select * from trigtest;
---END---
---START---
delete from trigtest;
---END---
---START---
select * from trigtest;
---END---
---START---
drop table trigtest;
---END---
---START---
-- Check behavior with an implicit column default, too (bug #16644)
create table trigtest (
  a integer,
  b bool default true not null,
  c text default 'xyzzy' not null);
---END---
---START---
create trigger trigger_return_old
	before insert or delete or update on trigtest
	for each row execute procedure trigger_return_old();
---END---
---START---
insert into trigtest values(1);
---END---
---START---
select * from trigtest;
---END---
---START---
alter table trigtest add column d integer default 42 not null;
---END---
---START---
select * from trigtest;
---END---
---START---
update trigtest set a = 2 where a = 1 returning *;
---END---
---START---
select * from trigtest;
---END---
---START---
alter table trigtest drop column b;
---END---
---START---
select * from trigtest;
---END---
---START---
update trigtest set a = 2 where a = 1 returning *;
---END---
---START---
select * from trigtest;
---END---
---START---
drop table trigtest;
---END---
---START---
create sequence ttdummy_seq increment 10 start 0 minvalue 0;
---END---
---START---
create table tttest (
	price_id	int4,
	price_val	int4,
	price_on	int4,
	price_off	int4 default 999999
);
---END---
---START---
create trigger ttdummy
	before delete or update on tttest
	for each row
	execute procedure
	ttdummy (price_on, price_off);
---END---
---START---
create trigger ttserial
	before insert or update on tttest
	for each row
	execute procedure
	autoinc (price_on, ttdummy_seq);
---END---
---START---
insert into tttest values (1, 1, null);
---END---
---START---
insert into tttest values (2, 2, null);
---END---
---START---
insert into tttest values (3, 3, 0);
---END---
---START---
select * from tttest;
---END---
---START---
delete from tttest where price_id = 2;
---END---
---START---
select * from tttest;
---END---
---START---
-- what do we see ?

-- get current prices
select * from tttest where price_off = 999999;
---END---
---START---
-- change price for price_id == 3
update tttest set price_val = 30 where price_id = 3;
---END---
---START---
select * from tttest;
---END---
---START---
-- now we want to change pric_id in ALL tuples
-- this gets us not what we need
update tttest set price_id = 5 where price_id = 3;
---END---
---START---
select * from tttest;
---END---
---START---
-- restore data as before last update:
select set_ttdummy(0);
---END---
---START---
delete from tttest where price_id = 5;
---END---
---START---
update tttest set price_off = 999999 where price_val = 30;
---END---
---START---
select * from tttest;
---END---
---START---
-- and try change price_id now!
update tttest set price_id = 5 where price_id = 3;
---END---
---START---
select * from tttest;
---END---
---START---
-- isn't it what we need ?

select set_ttdummy(1);
---END---
---START---
-- we want to correct some "date"
update tttest set price_on = -1 where price_id = 1;
---END---
---START---
-- but this doesn't work

-- try in this way
select set_ttdummy(0);
---END---
---START---
update tttest set price_on = -1 where price_id = 1;
---END---
---START---
select * from tttest;
---END---
---START---
-- isn't it what we need ?

-- get price for price_id == 5 as it was @ "date" 35
select * from tttest where price_on <= 35 and price_off > 35 and price_id = 5;
---END---
---START---
drop table tttest;
---END---
---START---
drop sequence ttdummy_seq;
---END---
---START---
--
-- tests for per-statement triggers
--

CREATE TABLE log_table (tstamp timestamp default timeofday()::timestamp);
---END---
---START---
CREATE TABLE main_table (a int unique, b int);
---END---
---START---
COPY main_table (a,b) FROM stdin;
5	10
20	20
30	10
50	35
80	15
\.
---END---
---START---
CREATE FUNCTION trigger_func() RETURNS trigger LANGUAGE plpgsql AS '
BEGIN
	RAISE NOTICE ''trigger_func(%) called: action = %, when = %, level = %'', TG_ARGV[0], TG_OP, TG_WHEN, TG_LEVEL;
	RETURN NULL;
END;';
---END---
---START---
CREATE TRIGGER before_ins_stmt_trig BEFORE INSERT ON main_table
FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func('before_ins_stmt');
---END---
---START---
CREATE TRIGGER after_ins_stmt_trig AFTER INSERT ON main_table
FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func('after_ins_stmt');
---END---
---START---
--
-- if neither 'FOR EACH ROW' nor 'FOR EACH STATEMENT' was specified,
-- CREATE TRIGGER should default to 'FOR EACH STATEMENT'
--
CREATE TRIGGER after_upd_stmt_trig AFTER UPDATE ON main_table
EXECUTE PROCEDURE trigger_func('after_upd_stmt');
---END---
---START---
-- Both insert and update statement level triggers (before and after) should
-- fire.  Doesn't fire UPDATE before trigger, but only because one isn't
-- defined.
INSERT INTO main_table (a, b) VALUES (5, 10) ON CONFLICT (a)
  DO UPDATE SET b = EXCLUDED.b;
---END---
---START---
CREATE TRIGGER after_upd_row_trig AFTER UPDATE ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('after_upd_row');
---END---
---START---
INSERT INTO main_table DEFAULT VALUES;
---END---
---START---
UPDATE main_table SET a = a + 1 WHERE b < 30;
---END---
---START---
-- UPDATE that effects zero rows should still call per-statement trigger
UPDATE main_table SET a = a + 2 WHERE b > 100;
---END---
---START---
-- constraint now unneeded
ALTER TABLE main_table DROP CONSTRAINT main_table_a_key;
---END---
---START---
COPY should fire per-row and per-statement INSERT triggers
COPY main_table (a, b) FROM stdin;
30	40
50	60
\.
---END---
---START---
SELECT * FROM main_table ORDER BY a, b;
---END---
---START---
--
-- test triggers with WHEN clause
--

CREATE TRIGGER modified_a BEFORE UPDATE OF a ON main_table
FOR EACH ROW WHEN (OLD.a <> NEW.a) EXECUTE PROCEDURE trigger_func('modified_a');
---END---
---START---
CREATE TRIGGER modified_any BEFORE UPDATE OF a ON main_table
FOR EACH ROW WHEN (OLD.* IS DISTINCT FROM NEW.*) EXECUTE PROCEDURE trigger_func('modified_any');
---END---
---START---
CREATE TRIGGER insert_a AFTER INSERT ON main_table
FOR EACH ROW WHEN (NEW.a = 123) EXECUTE PROCEDURE trigger_func('insert_a');
---END---
---START---
CREATE TRIGGER delete_a AFTER DELETE ON main_table
FOR EACH ROW WHEN (OLD.a = 123) EXECUTE PROCEDURE trigger_func('delete_a');
---END---
---START---
CREATE TRIGGER insert_when BEFORE INSERT ON main_table
FOR EACH STATEMENT WHEN (true) EXECUTE PROCEDURE trigger_func('insert_when');
---END---
---START---
CREATE TRIGGER delete_when AFTER DELETE ON main_table
FOR EACH STATEMENT WHEN (true) EXECUTE PROCEDURE trigger_func('delete_when');
---END---
---START---
SELECT trigger_name, event_manipulation, event_object_schema, event_object_table,
       action_order, action_condition, action_orientation, action_timing,
       action_reference_old_table, action_reference_new_table
  FROM information_schema.triggers
  WHERE event_object_table IN ('main_table')
  ORDER BY trigger_name COLLATE "C", 2;
---END---
---START---
INSERT INTO main_table (a) VALUES (123), (456);
---END---
---START---
COPY main_table FROM stdin;
123	999
456	999
\.
---END---
---START---
DELETE FROM main_table WHERE a IN (123, 456);
---END---
---START---
UPDATE main_table SET a = 50, b = 60;
---END---
---START---
SELECT * FROM main_table ORDER BY a, b;
---END---
---START---
SELECT pg_get_triggerdef(oid, true) FROM pg_trigger WHERE tgrelid = 'main_table'::regclass AND tgname = 'modified_a';
---END---
---START---
SELECT pg_get_triggerdef(oid, false) FROM pg_trigger WHERE tgrelid = 'main_table'::regclass AND tgname = 'modified_a';
---END---
---START---
SELECT pg_get_triggerdef(oid, true) FROM pg_trigger WHERE tgrelid = 'main_table'::regclass AND tgname = 'modified_any';
---END---
---START---
-- Test RENAME TRIGGER
ALTER TRIGGER modified_a ON main_table RENAME TO modified_modified_a;
---END---
---START---
SELECT count(*) FROM pg_trigger WHERE tgrelid = 'main_table'::regclass AND tgname = 'modified_a';
---END---
---START---
SELECT count(*) FROM pg_trigger WHERE tgrelid = 'main_table'::regclass AND tgname = 'modified_modified_a';
---END---
---START---
DROP TRIGGER modified_modified_a ON main_table;
---END---
---START---
DROP TRIGGER modified_any ON main_table;
---END---
---START---
DROP TRIGGER insert_a ON main_table;
---END---
---START---
DROP TRIGGER delete_a ON main_table;
---END---
---START---
DROP TRIGGER insert_when ON main_table;
---END---
---START---
DROP TRIGGER delete_when ON main_table;
---END---
---START---
-- Test WHEN condition accessing system columns.
create table table_with_oids(a int);
---END---
---START---
insert into table_with_oids values (1);
---END---
---START---
create trigger oid_unchanged_trig after update on table_with_oids
	for each row
	when (new.tableoid = old.tableoid AND new.tableoid <> 0)
	execute procedure trigger_func('after_upd_oid_unchanged');
---END---
---START---
update table_with_oids set a = a + 1;
---END---
---START---
drop table table_with_oids;
---END---
---START---
-- Test column-level triggers
DROP TRIGGER after_upd_row_trig ON main_table;
---END---
---START---
CREATE TRIGGER before_upd_a_row_trig BEFORE UPDATE OF a ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_upd_a_row');
---END---
---START---
CREATE TRIGGER after_upd_b_row_trig AFTER UPDATE OF b ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('after_upd_b_row');
---END---
---START---
CREATE TRIGGER after_upd_a_b_row_trig AFTER UPDATE OF a, b ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('after_upd_a_b_row');
---END---
---START---
CREATE TRIGGER before_upd_a_stmt_trig BEFORE UPDATE OF a ON main_table
FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func('before_upd_a_stmt');
---END---
---START---
CREATE TRIGGER after_upd_b_stmt_trig AFTER UPDATE OF b ON main_table
FOR EACH STATEMENT EXECUTE PROCEDURE trigger_func('after_upd_b_stmt');
---END---
---START---
SELECT pg_get_triggerdef(oid) FROM pg_trigger WHERE tgrelid = 'main_table'::regclass AND tgname = 'after_upd_a_b_row_trig';
---END---
---START---
UPDATE main_table SET a = 50;
---END---
---START---
UPDATE main_table SET b = 10;
---END---
---START---
--
-- Test case for bug with BEFORE trigger followed by AFTER trigger with WHEN
--

CREATE TABLE some_t (some_col boolean NOT NULL);
---END---
---START---
CREATE FUNCTION dummy_update_func() RETURNS trigger AS $$
BEGIN
  RAISE NOTICE 'dummy_update_func(%) called: action = %, old = %, new = %',
    TG_ARGV[0], TG_OP, OLD, NEW;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER some_trig_before BEFORE UPDATE ON some_t FOR EACH ROW
  EXECUTE PROCEDURE dummy_update_func('before');
---END---
---START---
CREATE TRIGGER some_trig_aftera AFTER UPDATE ON some_t FOR EACH ROW
  WHEN (NOT OLD.some_col AND NEW.some_col)
  EXECUTE PROCEDURE dummy_update_func('aftera');
---END---
---START---
CREATE TRIGGER some_trig_afterb AFTER UPDATE ON some_t FOR EACH ROW
  WHEN (NOT NEW.some_col)
  EXECUTE PROCEDURE dummy_update_func('afterb');
---END---
---START---
INSERT INTO some_t VALUES (TRUE);
---END---
---START---
UPDATE some_t SET some_col = TRUE;
---END---
---START---
UPDATE some_t SET some_col = FALSE;
---END---
---START---
UPDATE some_t SET some_col = TRUE;
---END---
---START---
DROP TABLE some_t;
---END---
---START---
-- bogus cases
CREATE TRIGGER error_upd_and_col BEFORE UPDATE OR UPDATE OF a ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('error_upd_and_col');
---END---
---START---
CREATE TRIGGER error_upd_a_a BEFORE UPDATE OF a, a ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('error_upd_a_a');
---END---
---START---
CREATE TRIGGER error_ins_a BEFORE INSERT OF a ON main_table
FOR EACH ROW EXECUTE PROCEDURE trigger_func('error_ins_a');
---END---
---START---
CREATE TRIGGER error_ins_when BEFORE INSERT OR UPDATE ON main_table
FOR EACH ROW WHEN (OLD.a <> NEW.a)
EXECUTE PROCEDURE trigger_func('error_ins_old');
---END---
---START---
CREATE TRIGGER error_del_when BEFORE DELETE OR UPDATE ON main_table
FOR EACH ROW WHEN (OLD.a <> NEW.a)
EXECUTE PROCEDURE trigger_func('error_del_new');
---END---
---START---
CREATE TRIGGER error_del_when BEFORE INSERT OR UPDATE ON main_table
FOR EACH ROW WHEN (NEW.tableoid <> 0)
EXECUTE PROCEDURE trigger_func('error_when_sys_column');
---END---
---START---
CREATE TRIGGER error_stmt_when BEFORE UPDATE OF a ON main_table
FOR EACH STATEMENT WHEN (OLD.* IS DISTINCT FROM NEW.*)
EXECUTE PROCEDURE trigger_func('error_stmt_when');
---END---
---START---
-- check dependency restrictions
ALTER TABLE main_table DROP COLUMN b;
---END---
---START---
-- this should succeed, but we'll roll it back to keep the triggers around
begin;
---END---
---START---
DROP TRIGGER after_upd_a_b_row_trig ON main_table;
---END---
---START---
DROP TRIGGER after_upd_b_row_trig ON main_table;
---END---
---START---
DROP TRIGGER after_upd_b_stmt_trig ON main_table;
---END---
---START---
ALTER TABLE main_table DROP COLUMN b;
---END---
---START---
rollback;
---END---
---START---
-- Test enable/disable triggers

create table trigtest (i serial primary key);
---END---
---START---
-- test that disabling RI triggers works
create table trigtest2 (i int references trigtest(i) on delete cascade);
---END---
---START---
create function trigtest() returns trigger as $$
begin
	raise notice '% % % %', TG_TABLE_NAME, TG_OP, TG_WHEN, TG_LEVEL;
	return new;
end;$$ language plpgsql;
---END---
---START---
create trigger trigtest_b_row_tg before insert or update or delete on trigtest
for each row execute procedure trigtest();
---END---
---START---
create trigger trigtest_a_row_tg after insert or update or delete on trigtest
for each row execute procedure trigtest();
---END---
---START---
create trigger trigtest_b_stmt_tg before insert or update or delete on trigtest
for each statement execute procedure trigtest();
---END---
---START---
create trigger trigtest_a_stmt_tg after insert or update or delete on trigtest
for each statement execute procedure trigtest();
---END---
---START---
insert into trigtest default values;
---END---
---START---
alter table trigtest disable trigger trigtest_b_row_tg;
---END---
---START---
insert into trigtest default values;
---END---
---START---
alter table trigtest disable trigger user;
---END---
---START---
insert into trigtest default values;
---END---
---START---
alter table trigtest enable trigger trigtest_a_stmt_tg;
---END---
---START---
insert into trigtest default values;
---END---
---START---
set session_replication_role = replica;
---END---
---START---
insert into trigtest default values;
---END---
---START---
-- does not trigger
alter table trigtest enable always trigger trigtest_a_stmt_tg;
---END---
---START---
insert into trigtest default values;
---END---
---START---
-- now it does
reset session_replication_role;
---END---
---START---
insert into trigtest2 values(1);
---END---
---START---
insert into trigtest2 values(2);
---END---
---START---
delete from trigtest where i=2;
---END---
---START---
select * from trigtest2;
---END---
---START---
alter table trigtest disable trigger all;
---END---
---START---
delete from trigtest where i=1;
---END---
---START---
select * from trigtest2;
---END---
---START---
-- ensure we still insert, even when all triggers are disabled
insert into trigtest default values;
---END---
---START---
select *  from trigtest;
---END---
---START---
drop table trigtest2;
---END---
---START---
drop table trigtest;
---END---
---START---
-- dump trigger data
CREATE TABLE trigger_test (
        i int,
        v varchar
);
---END---
---START---
CREATE OR REPLACE FUNCTION trigger_data()  RETURNS trigger
LANGUAGE plpgsql AS $$

declare

	argstr text;
	relid text;

begin

	relid := TG_relid::regclass;

	-- plpgsql can't discover its trigger data in a hash like perl and python
	-- can, or by a sort of reflection like tcl can,
	-- so we have to hard code the names.
	raise NOTICE 'TG_NAME: %', TG_name;
	raise NOTICE 'TG_WHEN: %', TG_when;
	raise NOTICE 'TG_LEVEL: %', TG_level;
	raise NOTICE 'TG_OP: %', TG_op;
	raise NOTICE 'TG_RELID::regclass: %', relid;
	raise NOTICE 'TG_RELNAME: %', TG_relname;
	raise NOTICE 'TG_TABLE_NAME: %', TG_table_name;
	raise NOTICE 'TG_TABLE_SCHEMA: %', TG_table_schema;
	raise NOTICE 'TG_NARGS: %', TG_nargs;

	argstr := '[';
	for i in 0 .. TG_nargs - 1 loop
		if i > 0 then
			argstr := argstr || ', ';
		end if;
		argstr := argstr || TG_argv[i];
	end loop;
	argstr := argstr || ']';
	raise NOTICE 'TG_ARGV: %', argstr;

	if TG_OP != 'INSERT' then
		raise NOTICE 'OLD: %', OLD;
	end if;

	if TG_OP != 'DELETE' then
		raise NOTICE 'NEW: %', NEW;
	end if;

	if TG_OP = 'DELETE' then
		return OLD;
	else
		return NEW;
	end if;

end;
$$;
---END---
---START---
CREATE TRIGGER show_trigger_data_trig
BEFORE INSERT OR UPDATE OR DELETE ON trigger_test
FOR EACH ROW EXECUTE PROCEDURE trigger_data(23,'skidoo');
---END---
---START---
insert into trigger_test values(1,'insert');
---END---
---START---
update trigger_test set v = 'update' where i = 1;
---END---
---START---
delete from trigger_test;
---END---
---START---
DROP TRIGGER show_trigger_data_trig on trigger_test;
---END---
---START---
DROP FUNCTION trigger_data();
---END---
---START---
DROP TABLE trigger_test;
---END---
---START---
--
-- Test use of row comparisons on OLD/NEW
--

CREATE TABLE trigger_test (f1 int, f2 text, f3 text);
---END---
---START---
-- this is the obvious (and wrong...) way to compare rows
CREATE FUNCTION mytrigger() RETURNS trigger LANGUAGE plpgsql as $$
begin
	if row(old.*) = row(new.*) then
		raise notice 'row % not changed', new.f1;
	else
		raise notice 'row % changed', new.f1;
	end if;
	return new;
end$$;
---END---
---START---
CREATE TRIGGER t
BEFORE UPDATE ON trigger_test
FOR EACH ROW EXECUTE PROCEDURE mytrigger();
---END---
---START---
INSERT INTO trigger_test VALUES(1, 'foo', 'bar');
---END---
---START---
INSERT INTO trigger_test VALUES(2, 'baz', 'quux');
---END---
---START---
UPDATE trigger_test SET f3 = 'bar';
---END---
---START---
UPDATE trigger_test SET f3 = NULL;
---END---
---START---
-- this demonstrates that the above isn't really working as desired:
UPDATE trigger_test SET f3 = NULL;
---END---
---START---
-- the right way when considering nulls is
CREATE OR REPLACE FUNCTION mytrigger() RETURNS trigger LANGUAGE plpgsql as $$
begin
	if row(old.*) is distinct from row(new.*) then
		raise notice 'row % changed', new.f1;
	else
		raise notice 'row % not changed', new.f1;
	end if;
	return new;
end$$;
---END---
---START---
UPDATE trigger_test SET f3 = 'bar';
---END---
---START---
UPDATE trigger_test SET f3 = NULL;
---END---
---START---
UPDATE trigger_test SET f3 = NULL;
---END---
---START---
DROP TABLE trigger_test;
---END---
---START---
DROP FUNCTION mytrigger();
---END---
---START---
-- Test snapshot management in serializable transactions involving triggers
-- per bug report in 6bc73d4c0910042358k3d1adff3qa36f8df75198ecea@mail.gmail.com
CREATE FUNCTION serializable_update_trig() RETURNS trigger LANGUAGE plpgsql AS
$$
declare
	rec record;
begin
	new.description = 'updated in trigger';
	return new;
end;
$$;
---END---
---START---
CREATE TABLE serializable_update_tab (
	id int,
	filler  text,
	description text
);
---END---
---START---
CREATE TRIGGER serializable_update_trig BEFORE UPDATE ON serializable_update_tab
	FOR EACH ROW EXECUTE PROCEDURE serializable_update_trig();
---END---
---START---
INSERT INTO serializable_update_tab SELECT a, repeat('xyzxz', 100), 'new'
	FROM generate_series(1, 50) a;
---END---
---START---
BEGIN;
---END---
---START---
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
UPDATE serializable_update_tab SET description = 'no no', id = 1 WHERE id = 1;
---END---
---START---
COMMIT;
---END---
---START---
SELECT description FROM serializable_update_tab WHERE id = 1;
---END---
---START---
DROP TABLE serializable_update_tab;
---END---
---START---
-- minimal update trigger

CREATE TABLE min_updates_test (
	f1	text,
	f2 int,
	f3 int);
---END---
---START---
INSERT INTO min_updates_test VALUES ('a',1,2),('b','2',null);
---END---
---START---
CREATE TRIGGER z_min_update
BEFORE UPDATE ON min_updates_test
FOR EACH ROW EXECUTE PROCEDURE suppress_redundant_updates_trigger();
---END---
---START---
\set QUIET false

UPDATE min_updates_test SET f1 = f1;
---END---
---START---
UPDATE min_updates_test SET f2 = f2 + 1;
---END---
---START---
UPDATE min_updates_test SET f3 = 2 WHERE f3 is null;
---END---
---START---
\set QUIET true

SELECT * FROM min_updates_test;
---END---
---START---
DROP TABLE min_updates_test;
---END---
---START---
--
-- Test triggers on views
--

CREATE VIEW main_view AS SELECT a, b FROM main_table;
---END---
---START---
-- VIEW trigger function
CREATE OR REPLACE FUNCTION view_trigger() RETURNS trigger
LANGUAGE plpgsql AS $$
declare
    argstr text := '';
begin
    for i in 0 .. TG_nargs - 1 loop
        if i > 0 then
            argstr := argstr || ', ';
        end if;
        argstr := argstr || TG_argv[i];
    end loop;

    raise notice '% % % % (%)', TG_TABLE_NAME, TG_WHEN, TG_OP, TG_LEVEL, argstr;

    if TG_LEVEL = 'ROW' then
        if TG_OP = 'INSERT' then
            raise NOTICE 'NEW: %', NEW;
            INSERT INTO main_table VALUES (NEW.a, NEW.b);
            RETURN NEW;
        end if;

        if TG_OP = 'UPDATE' then
            raise NOTICE 'OLD: %, NEW: %', OLD, NEW;
            UPDATE main_table SET a = NEW.a, b = NEW.b WHERE a = OLD.a AND b = OLD.b;
            if NOT FOUND then RETURN NULL; end if;
            RETURN NEW;
        end if;

        if TG_OP = 'DELETE' then
            raise NOTICE 'OLD: %', OLD;
            DELETE FROM main_table WHERE a = OLD.a AND b = OLD.b;
            if NOT FOUND then RETURN NULL; end if;
            RETURN OLD;
        end if;
    end if;

    RETURN NULL;
end;
$$;
---END---
---START---
-- Before row triggers aren't allowed on views
CREATE TRIGGER invalid_trig BEFORE INSERT ON main_view
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_ins_row');
---END---
---START---
CREATE TRIGGER invalid_trig BEFORE UPDATE ON main_view
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_upd_row');
---END---
---START---
CREATE TRIGGER invalid_trig BEFORE DELETE ON main_view
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_del_row');
---END---
---START---
-- After row triggers aren't allowed on views
CREATE TRIGGER invalid_trig AFTER INSERT ON main_view
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_ins_row');
---END---
---START---
CREATE TRIGGER invalid_trig AFTER UPDATE ON main_view
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_upd_row');
---END---
---START---
CREATE TRIGGER invalid_trig AFTER DELETE ON main_view
FOR EACH ROW EXECUTE PROCEDURE trigger_func('before_del_row');
---END---
---START---
-- Truncate triggers aren't allowed on views
CREATE TRIGGER invalid_trig BEFORE TRUNCATE ON main_view
EXECUTE PROCEDURE trigger_func('before_tru_row');
---END---
---START---
CREATE TRIGGER invalid_trig AFTER TRUNCATE ON main_view
EXECUTE PROCEDURE trigger_func('before_tru_row');
---END---
---START---
-- INSTEAD OF triggers aren't allowed on tables
CREATE TRIGGER invalid_trig INSTEAD OF INSERT ON main_table
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_ins');
---END---
---START---
CREATE TRIGGER invalid_trig INSTEAD OF UPDATE ON main_table
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_upd');
---END---
---START---
CREATE TRIGGER invalid_trig INSTEAD OF DELETE ON main_table
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_del');
---END---
---START---
-- Don't support WHEN clauses with INSTEAD OF triggers
CREATE TRIGGER invalid_trig INSTEAD OF UPDATE ON main_view
FOR EACH ROW WHEN (OLD.a <> NEW.a) EXECUTE PROCEDURE view_trigger('instead_of_upd');
---END---
---START---
-- Don't support column-level INSTEAD OF triggers
CREATE TRIGGER invalid_trig INSTEAD OF UPDATE OF a ON main_view
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_upd');
---END---
---START---
-- Don't support statement-level INSTEAD OF triggers
CREATE TRIGGER invalid_trig INSTEAD OF UPDATE ON main_view
EXECUTE PROCEDURE view_trigger('instead_of_upd');
---END---
---START---
-- Valid INSTEAD OF triggers
CREATE TRIGGER instead_of_insert_trig INSTEAD OF INSERT ON main_view
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_ins');
---END---
---START---
CREATE TRIGGER instead_of_update_trig INSTEAD OF UPDATE ON main_view
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_upd');
---END---
---START---
CREATE TRIGGER instead_of_delete_trig INSTEAD OF DELETE ON main_view
FOR EACH ROW EXECUTE PROCEDURE view_trigger('instead_of_del');
---END---
---START---
-- Valid BEFORE statement VIEW triggers
CREATE TRIGGER before_ins_stmt_trig BEFORE INSERT ON main_view
FOR EACH STATEMENT EXECUTE PROCEDURE view_trigger('before_view_ins_stmt');
---END---
---START---
CREATE TRIGGER before_upd_stmt_trig BEFORE UPDATE ON main_view
FOR EACH STATEMENT EXECUTE PROCEDURE view_trigger('before_view_upd_stmt');
---END---
---START---
CREATE TRIGGER before_del_stmt_trig BEFORE DELETE ON main_view
FOR EACH STATEMENT EXECUTE PROCEDURE view_trigger('before_view_del_stmt');
---END---
---START---
-- Valid AFTER statement VIEW triggers
CREATE TRIGGER after_ins_stmt_trig AFTER INSERT ON main_view
FOR EACH STATEMENT EXECUTE PROCEDURE view_trigger('after_view_ins_stmt');
---END---
---START---
CREATE TRIGGER after_upd_stmt_trig AFTER UPDATE ON main_view
FOR EACH STATEMENT EXECUTE PROCEDURE view_trigger('after_view_upd_stmt');
---END---
---START---
CREATE TRIGGER after_del_stmt_trig AFTER DELETE ON main_view
FOR EACH STATEMENT EXECUTE PROCEDURE view_trigger('after_view_del_stmt');
---END---
---START---
\set QUIET false

-- Insert into view using trigger
INSERT INTO main_view VALUES (20, 30);
---END---
---START---
INSERT INTO main_view VALUES (21, 31) RETURNING a, b;
---END---
---START---
-- Table trigger will prevent updates
UPDATE main_view SET b = 31 WHERE a = 20;
---END---
---START---
UPDATE main_view SET b = 32 WHERE a = 21 AND b = 31 RETURNING a, b;
---END---
---START---
-- Remove table trigger to allow updates
DROP TRIGGER before_upd_a_row_trig ON main_table;
---END---
---START---
UPDATE main_view SET b = 31 WHERE a = 20;
---END---
---START---
UPDATE main_view SET b = 32 WHERE a = 21 AND b = 31 RETURNING a, b;
---END---
---START---
-- Before and after stmt triggers should fire even when no rows are affected
UPDATE main_view SET b = 0 WHERE false;
---END---
---START---
-- Delete from view using trigger
DELETE FROM main_view WHERE a IN (20,21);
---END---
---START---
DELETE FROM main_view WHERE a = 31 RETURNING a, b;
---END---
---START---
\set QUIET true

-- Describe view should list triggers
\d main_view

-- Test dropping view triggers
DROP TRIGGER instead_of_insert_trig ON main_view;
---END---
---START---
DROP TRIGGER instead_of_delete_trig ON main_view;
---END---
---START---
\d+ main_view
DROP VIEW main_view;
---END---
---START---
--
-- Test triggers on a join view
--
CREATE TABLE country_table (
    country_id        serial primary key,
    country_name    text unique not null,
    continent        text not null
);
---END---
---START---
INSERT INTO country_table (country_name, continent)
    VALUES ('Japan', 'Asia'),
           ('UK', 'Europe'),
           ('USA', 'North America')
    RETURNING *;
---END---
---START---
CREATE TABLE city_table (
    city_id        serial primary key,
    city_name    text not null,
    population    bigint,
    country_id    int references country_table
);
---END---
---START---
CREATE VIEW city_view AS
    SELECT city_id, city_name, population, country_name, continent
    FROM city_table ci
    LEFT JOIN country_table co ON co.country_id = ci.country_id;
---END---
---START---
CREATE FUNCTION city_insert() RETURNS trigger LANGUAGE plpgsql AS $$
declare
    ctry_id int;
begin
    if NEW.country_name IS NOT NULL then
        SELECT country_id, continent INTO ctry_id, NEW.continent
            FROM country_table WHERE country_name = NEW.country_name;
        if NOT FOUND then
            raise exception 'No such country: "%"', NEW.country_name;
        end if;
    else
        NEW.continent := NULL;
    end if;

    if NEW.city_id IS NOT NULL then
        INSERT INTO city_table
            VALUES(NEW.city_id, NEW.city_name, NEW.population, ctry_id);
    else
        INSERT INTO city_table(city_name, population, country_id)
            VALUES(NEW.city_name, NEW.population, ctry_id)
            RETURNING city_id INTO NEW.city_id;
    end if;

    RETURN NEW;
end;
$$;
---END---
---START---
CREATE TRIGGER city_insert_trig INSTEAD OF INSERT ON city_view
FOR EACH ROW EXECUTE PROCEDURE city_insert();
---END---
---START---
CREATE FUNCTION city_delete() RETURNS trigger LANGUAGE plpgsql AS $$
begin
    DELETE FROM city_table WHERE city_id = OLD.city_id;
    if NOT FOUND then RETURN NULL; end if;
    RETURN OLD;
end;
$$;
---END---
---START---
CREATE TRIGGER city_delete_trig INSTEAD OF DELETE ON city_view
FOR EACH ROW EXECUTE PROCEDURE city_delete();
---END---
---START---
CREATE FUNCTION city_update() RETURNS trigger LANGUAGE plpgsql AS $$
declare
    ctry_id int;
begin
    if NEW.country_name IS DISTINCT FROM OLD.country_name then
        SELECT country_id, continent INTO ctry_id, NEW.continent
            FROM country_table WHERE country_name = NEW.country_name;
        if NOT FOUND then
            raise exception 'No such country: "%"', NEW.country_name;
        end if;

        UPDATE city_table SET city_name = NEW.city_name,
                              population = NEW.population,
                              country_id = ctry_id
            WHERE city_id = OLD.city_id;
    else
        UPDATE city_table SET city_name = NEW.city_name,
                              population = NEW.population
            WHERE city_id = OLD.city_id;
        NEW.continent := OLD.continent;
    end if;

    if NOT FOUND then RETURN NULL; end if;
    RETURN NEW;
end;
$$;
---END---
---START---
CREATE TRIGGER city_update_trig INSTEAD OF UPDATE ON city_view
FOR EACH ROW EXECUTE PROCEDURE city_update();
---END---
---START---
\set QUIET false

-- INSERT .. RETURNING
INSERT INTO city_view(city_name) VALUES('Tokyo') RETURNING *;
---END---
---START---
INSERT INTO city_view(city_name, population) VALUES('London', 7556900) RETURNING *;
---END---
---START---
INSERT INTO city_view(city_name, country_name) VALUES('Washington DC', 'USA') RETURNING *;
---END---
---START---
INSERT INTO city_view(city_id, city_name) VALUES(123456, 'New York') RETURNING *;
---END---
---START---
INSERT INTO city_view VALUES(234567, 'Birmingham', 1016800, 'UK', 'EU') RETURNING *;
---END---
---START---
-- UPDATE .. RETURNING
UPDATE city_view SET country_name = 'Japon' WHERE city_name = 'Tokyo';
---END---
---START---
-- error
UPDATE city_view SET country_name = 'Japan' WHERE city_name = 'Takyo';
---END---
---START---
-- no match
UPDATE city_view SET country_name = 'Japan' WHERE city_name = 'Tokyo' RETURNING *;
---END---
---START---
-- OK

UPDATE city_view SET population = 13010279 WHERE city_name = 'Tokyo' RETURNING *;
---END---
---START---
UPDATE city_view SET country_name = 'UK' WHERE city_name = 'New York' RETURNING *;
---END---
---START---
UPDATE city_view SET country_name = 'USA', population = 8391881 WHERE city_name = 'New York' RETURNING *;
---END---
---START---
UPDATE city_view SET continent = 'EU' WHERE continent = 'Europe' RETURNING *;
---END---
---START---
UPDATE city_view v1 SET country_name = v2.country_name FROM city_view v2
    WHERE v2.city_name = 'Birmingham' AND v1.city_name = 'London' RETURNING *;
---END---
---START---
-- DELETE .. RETURNING
DELETE FROM city_view WHERE city_name = 'Birmingham' RETURNING *;
---END---
---START---
\set QUIET true

-- read-only view with WHERE clause
CREATE VIEW european_city_view AS
    SELECT * FROM city_view WHERE continent = 'Europe';
---END---
---START---
SELECT count(*) FROM european_city_view;
---END---
---START---
CREATE FUNCTION no_op_trig_fn() RETURNS trigger LANGUAGE plpgsql
AS 'begin RETURN NULL; end';
---END---
---START---
CREATE TRIGGER no_op_trig INSTEAD OF INSERT OR UPDATE OR DELETE
ON european_city_view FOR EACH ROW EXECUTE PROCEDURE no_op_trig_fn();
---END---
---START---
\set QUIET false

INSERT INTO european_city_view VALUES (0, 'x', 10000, 'y', 'z');
---END---
---START---
UPDATE european_city_view SET population = 10000;
---END---
---START---
DELETE FROM european_city_view;
---END---
---START---
\set QUIET true

-- rules bypassing no-op triggers
CREATE RULE european_city_insert_rule AS ON INSERT TO european_city_view
DO INSTEAD INSERT INTO city_view
VALUES (NEW.city_id, NEW.city_name, NEW.population, NEW.country_name, NEW.continent)
RETURNING *;
---END---
---START---
CREATE RULE european_city_update_rule AS ON UPDATE TO european_city_view
DO INSTEAD UPDATE city_view SET
    city_name = NEW.city_name,
    population = NEW.population,
    country_name = NEW.country_name
WHERE city_id = OLD.city_id
RETURNING NEW.*;
---END---
---START---
CREATE RULE european_city_delete_rule AS ON DELETE TO european_city_view
DO INSTEAD DELETE FROM city_view WHERE city_id = OLD.city_id RETURNING *;
---END---
---START---
\set QUIET false

-- INSERT not limited by view's WHERE clause, but UPDATE AND DELETE are
INSERT INTO european_city_view(city_name, country_name)
    VALUES ('Cambridge', 'USA') RETURNING *;
---END---
---START---
UPDATE european_city_view SET country_name = 'UK'
    WHERE city_name = 'Cambridge';
---END---
---START---
DELETE FROM european_city_view WHERE city_name = 'Cambridge';
---END---
---START---
-- UPDATE and DELETE via rule and trigger
UPDATE city_view SET country_name = 'UK'
    WHERE city_name = 'Cambridge' RETURNING *;
---END---
---START---
UPDATE european_city_view SET population = 122800
    WHERE city_name = 'Cambridge' RETURNING *;
---END---
---START---
DELETE FROM european_city_view WHERE city_name = 'Cambridge' RETURNING *;
---END---
---START---
-- join UPDATE test
UPDATE city_view v SET population = 599657
    FROM city_table ci, country_table co
    WHERE ci.city_name = 'Washington DC' and co.country_name = 'USA'
    AND v.city_id = ci.city_id AND v.country_name = co.country_name
    RETURNING co.country_id, v.country_name,
              v.city_id, v.city_name, v.population;
---END---
---START---
\set QUIET true

SELECT * FROM city_view;
---END---
---START---
DROP TABLE city_table CASCADE;
---END---
---START---
DROP TABLE country_table;
---END---
---START---
-- Test pg_trigger_depth()

create table depth_a (id int not null primary key);
---END---
---START---
create table depth_b (id int not null primary key);
---END---
---START---
create table depth_c (id int not null primary key);
---END---
---START---
create function depth_a_tf() returns trigger
  language plpgsql as $$
begin
  raise notice '%: depth = %', tg_name, pg_trigger_depth();
  insert into depth_b values (new.id);
  raise notice '%: depth = %', tg_name, pg_trigger_depth();
  return new;
end;
$$;
---END---
---START---
create trigger depth_a_tr before insert on depth_a
  for each row execute procedure depth_a_tf();
---END---
---START---
create function depth_b_tf() returns trigger
  language plpgsql as $$
begin
  raise notice '%: depth = %', tg_name, pg_trigger_depth();
  begin
    execute 'insert into depth_c values (' || new.id::text || ')';
  exception
    when sqlstate 'U9999' then
      raise notice 'SQLSTATE = U9999: depth = %', pg_trigger_depth();
  end;
  raise notice '%: depth = %', tg_name, pg_trigger_depth();
  if new.id = 1 then
    execute 'insert into depth_c values (' || new.id::text || ')';
  end if;
  return new;
end;
$$;
---END---
---START---
create trigger depth_b_tr before insert on depth_b
  for each row execute procedure depth_b_tf();
---END---
---START---
create function depth_c_tf() returns trigger
  language plpgsql as $$
begin
  raise notice '%: depth = %', tg_name, pg_trigger_depth();
  if new.id = 1 then
    raise exception sqlstate 'U9999';
  end if;
  raise notice '%: depth = %', tg_name, pg_trigger_depth();
  return new;
end;
$$;
---END---
---START---
create trigger depth_c_tr before insert on depth_c
  for each row execute procedure depth_c_tf();
---END---
---START---
select pg_trigger_depth();
---END---
---START---
insert into depth_a values (1);
---END---
---START---
select pg_trigger_depth();
---END---
---START---
insert into depth_a values (2);
---END---
---START---
select pg_trigger_depth();
---END---
---START---
drop table depth_a, depth_b, depth_c;
---END---
---START---
drop function depth_a_tf();
---END---
---START---
drop function depth_b_tf();
---END---
---START---
drop function depth_c_tf();
---END---
---START---
--
-- Test updates to rows during firing of BEFORE ROW triggers.
-- As of 9.2, such cases should be rejected (see bug #6123).
--

create temp table parent (
    aid int not null primary key,
    val1 text,
    val2 text,
    val3 text,
    val4 text,
    bcnt int not null default 0);
---END---
---START---
create temp table child (
    bid int not null primary key,
    aid int not null,
    val1 text);
---END---
---START---
create function parent_upd_func()
  returns trigger language plpgsql as
$$
begin
  if old.val1 <> new.val1 then
    new.val2 = new.val1;
    delete from child where child.aid = new.aid and child.val1 = new.val1;
  end if;
  return new;
end;
$$;
---END---
---START---
create trigger parent_upd_trig before update on parent
  for each row execute procedure parent_upd_func();
---END---
---START---
create function parent_del_func()
  returns trigger language plpgsql as
$$
begin
  delete from child where aid = old.aid;
  return old;
end;
$$;
---END---
---START---
create trigger parent_del_trig before delete on parent
  for each row execute procedure parent_del_func();
---END---
---START---
create function child_ins_func()
  returns trigger language plpgsql as
$$
begin
  update parent set bcnt = bcnt + 1 where aid = new.aid;
  return new;
end;
$$;
---END---
---START---
create trigger child_ins_trig after insert on child
  for each row execute procedure child_ins_func();
---END---
---START---
create function child_del_func()
  returns trigger language plpgsql as
$$
begin
  update parent set bcnt = bcnt - 1 where aid = old.aid;
  return old;
end;
$$;
---END---
---START---
create trigger child_del_trig after delete on child
  for each row execute procedure child_del_func();
---END---
---START---
insert into parent values (1, 'a', 'a', 'a', 'a', 0);
---END---
---START---
insert into child values (10, 1, 'b');
---END---
---START---
select * from parent;
---END---
---START---
select * from child;
---END---
---START---
update parent set val1 = 'b' where aid = 1;
---END---
---START---
-- should fail
select * from parent;
---END---
---START---
select * from child;
---END---
---START---
delete from parent where aid = 1;
---END---
---START---
-- should fail
select * from parent;
---END---
---START---
select * from child;
---END---
---START---
-- replace the trigger function with one that restarts the deletion after
-- having modified a child
create or replace function parent_del_func()
  returns trigger language plpgsql as
$$
begin
  delete from child where aid = old.aid;
  if found then
    delete from parent where aid = old.aid;
    return null; -- cancel outer deletion
  end if;
  return old;
end;
$$;
---END---
---START---
delete from parent where aid = 1;
---END---
---START---
select * from parent;
---END---
---START---
select * from child;
---END---
---START---
drop table parent, child;
---END---
---START---
drop function parent_upd_func();
---END---
---START---
drop function parent_del_func();
---END---
---START---
drop function child_ins_func();
---END---
---START---
drop function child_del_func();
---END---
---START---
-- similar case, but with a self-referencing FK so that parent and child
-- rows can be affected by a single operation

create temp table self_ref_trigger (
    id int primary key,
    parent int references self_ref_trigger,
    data text,
    nchildren int not null default 0
);
---END---
---START---
create function self_ref_trigger_ins_func()
  returns trigger language plpgsql as
$$
begin
  if new.parent is not null then
    update self_ref_trigger set nchildren = nchildren + 1
      where id = new.parent;
  end if;
  return new;
end;
$$;
---END---
---START---
create trigger self_ref_trigger_ins_trig before insert on self_ref_trigger
  for each row execute procedure self_ref_trigger_ins_func();
---END---
---START---
create function self_ref_trigger_del_func()
  returns trigger language plpgsql as
$$
begin
  if old.parent is not null then
    update self_ref_trigger set nchildren = nchildren - 1
      where id = old.parent;
  end if;
  return old;
end;
$$;
---END---
---START---
create trigger self_ref_trigger_del_trig before delete on self_ref_trigger
  for each row execute procedure self_ref_trigger_del_func();
---END---
---START---
insert into self_ref_trigger values (1, null, 'root');
---END---
---START---
insert into self_ref_trigger values (2, 1, 'root child A');
---END---
---START---
insert into self_ref_trigger values (3, 1, 'root child B');
---END---
---START---
insert into self_ref_trigger values (4, 2, 'grandchild 1');
---END---
---START---
insert into self_ref_trigger values (5, 3, 'grandchild 2');
---END---
---START---
update self_ref_trigger set data = 'root!' where id = 1;
---END---
---START---
select * from self_ref_trigger;
---END---
---START---
delete from self_ref_trigger;
---END---
---START---
select * from self_ref_trigger;
---END---
---START---
drop table self_ref_trigger;
---END---
---START---
drop function self_ref_trigger_ins_func();
---END---
---START---
drop function self_ref_trigger_del_func();
---END---
---START---
--
-- Check that statement triggers work correctly even with all children excluded
--

create table stmt_trig_on_empty_upd (a int);
---END---
---START---
create table stmt_trig_on_empty_upd1 () inherits (stmt_trig_on_empty_upd);
---END---
---START---
create function update_stmt_notice() returns trigger as $$
begin
	raise notice 'updating %', TG_TABLE_NAME;
	return null;
end;
$$ language plpgsql;
---END---
---START---
create trigger before_stmt_trigger
	before update on stmt_trig_on_empty_upd
	execute procedure update_stmt_notice();
---END---
---START---
create trigger before_stmt_trigger
	before update on stmt_trig_on_empty_upd1
	execute procedure update_stmt_notice();
---END---
---START---
-- inherited no-op update
update stmt_trig_on_empty_upd set a = a where false returning a+1 as aa;
---END---
---START---
-- simple no-op update
update stmt_trig_on_empty_upd1 set a = a where false returning a+1 as aa;
---END---
---START---
drop table stmt_trig_on_empty_upd cascade;
---END---
---START---
drop function update_stmt_notice();
---END---
---START---
--
-- Check that index creation (or DDL in general) is prohibited in a trigger
--

create table trigger_ddl_table (
   col1 integer,
   col2 integer
);
---END---
---START---
create function trigger_ddl_func() returns trigger as $$
begin
  alter table trigger_ddl_table add primary key (col1);
  return new;
end$$ language plpgsql;
---END---
---START---
create trigger trigger_ddl_func before insert on trigger_ddl_table for each row
  execute procedure trigger_ddl_func();
---END---
---START---
insert into trigger_ddl_table values (1, 42);
---END---
---START---
-- fail

create or replace function trigger_ddl_func() returns trigger as $$
begin
  create index on trigger_ddl_table (col2);
  return new;
end$$ language plpgsql;
---END---
---START---
insert into trigger_ddl_table values (1, 42);
---END---
---START---
-- fail

drop table trigger_ddl_table;
---END---
---START---
drop function trigger_ddl_func();
---END---
---START---
--
-- Verify behavior of before and after triggers with INSERT...ON CONFLICT
-- DO UPDATE
--
create table upsert (key int4 primary key, color text);
---END---
---START---
create function upsert_before_func()
  returns trigger language plpgsql as
$$
begin
  if (TG_OP = 'UPDATE') then
    raise warning 'before update (old): %', old.*::text;
    raise warning 'before update (new): %', new.*::text;
  elsif (TG_OP = 'INSERT') then
    raise warning 'before insert (new): %', new.*::text;
    if new.key % 2 = 0 then
      new.key := new.key + 1;
      new.color := new.color || ' trig modified';
      raise warning 'before insert (new, modified): %', new.*::text;
    end if;
  end if;
  return new;
end;
$$;
---END---
---START---
create trigger upsert_before_trig before insert or update on upsert
  for each row execute procedure upsert_before_func();
---END---
---START---
create function upsert_after_func()
  returns trigger language plpgsql as
$$
begin
  if (TG_OP = 'UPDATE') then
    raise warning 'after update (old): %', old.*::text;
    raise warning 'after update (new): %', new.*::text;
  elsif (TG_OP = 'INSERT') then
    raise warning 'after insert (new): %', new.*::text;
  end if;
  return null;
end;
$$;
---END---
---START---
create trigger upsert_after_trig after insert or update on upsert
  for each row execute procedure upsert_after_func();
---END---
---START---
insert into upsert values(1, 'black') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(2, 'red') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(3, 'orange') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(4, 'green') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(5, 'purple') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(6, 'white') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(7, 'pink') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
insert into upsert values(8, 'yellow') on conflict (key) do update set color = 'updated ' || upsert.color;
---END---
---START---
select * from upsert;
---END---
---START---
drop table upsert;
---END---
---START---
drop function upsert_before_func();
---END---
---START---
drop function upsert_after_func();
---END---
---START---
--
-- Verify that triggers with transition tables are not allowed on
-- views
--

create table my_table (i int);
---END---
---START---
create view my_view as select * from my_table;
---END---
---START---
create function my_trigger_function() returns trigger as $$ begin end; $$ language plpgsql;
---END---
---START---
create trigger my_trigger after update on my_view referencing old table as old_table
   for each statement execute procedure my_trigger_function();
---END---
---START---
drop function my_trigger_function();
---END---
---START---
drop view my_view;
---END---
---START---
drop table my_table;
---END---
---START---
--
-- Verify cases that are unsupported with partitioned tables
--
create table parted_trig (a int) partition by list (a);
---END---
---START---
create function trigger_nothing() returns trigger
  language plpgsql as $$ begin end; $$;
---END---
---START---
create trigger failed instead of update on parted_trig
  for each row execute procedure trigger_nothing();
---END---
---START---
create trigger failed after update on parted_trig
  referencing old table as old_table
  for each row execute procedure trigger_nothing();
---END---
---START---
drop table parted_trig;
---END---
---START---
--
-- Verify trigger creation for partitioned tables, and drop behavior
--
create table trigpart (a int, b int) partition by range (a);
---END---
---START---
create table trigpart1 partition of trigpart for values from (0) to (1000);
---END---
---START---
create trigger trg1 after insert on trigpart for each row execute procedure trigger_nothing();
---END---
---START---
create table trigpart2 partition of trigpart for values from (1000) to (2000);
---END---
---START---
create table trigpart3 (like trigpart);
---END---
---START---
alter table trigpart attach partition trigpart3 for values from (2000) to (3000);
---END---
---START---
create table trigpart4 partition of trigpart for values from (3000) to (4000) partition by range (a);
---END---
---START---
create table trigpart41 partition of trigpart4 for values from (3000) to (3500);
---END---
---START---
create table trigpart42 (like trigpart);
---END---
---START---
alter table trigpart4 attach partition trigpart42 for values from (3500) to (4000);
---END---
---START---
select tgrelid::regclass, tgname, tgfoid::regproc from pg_trigger
  where tgrelid::regclass::text like 'trigpart%' order by tgrelid::regclass::text;
---END---
---START---
drop trigger trg1 on trigpart1;
---END---
---START---
-- fail
drop trigger trg1 on trigpart2;
---END---
---START---
-- fail
drop trigger trg1 on trigpart3;
---END---
---START---
-- fail
drop table trigpart2;
---END---
---START---
-- ok, trigger should be gone in that partition
select tgrelid::regclass, tgname, tgfoid::regproc from pg_trigger
  where tgrelid::regclass::text like 'trigpart%' order by tgrelid::regclass::text;
---END---
---START---
drop trigger trg1 on trigpart;
---END---
---START---
-- ok, all gone
select tgrelid::regclass, tgname, tgfoid::regproc from pg_trigger
  where tgrelid::regclass::text like 'trigpart%' order by tgrelid::regclass::text;
---END---
---START---
-- check detach behavior
create trigger trg1 after insert on trigpart for each row execute procedure trigger_nothing();
---END---
---START---
\d trigpart3
alter table trigpart detach partition trigpart3;
---END---
---START---
drop trigger trg1 on trigpart3;
---END---
---START---
-- fail due to "does not exist"
alter table trigpart detach partition trigpart4;
---END---
---START---
drop trigger trg1 on trigpart41;
---END---
---START---
-- fail due to "does not exist"
drop table trigpart4;
---END---
---START---
alter table trigpart attach partition trigpart3 for values from (2000) to (3000);
---END---
---START---
alter table trigpart detach partition trigpart3;
---END---
---START---
alter table trigpart attach partition trigpart3 for values from (2000) to (3000);
---END---
---START---
drop table trigpart3;
---END---
---START---
select tgrelid::regclass::text, tgname, tgfoid::regproc, tgenabled, tgisinternal from pg_trigger
  where tgname ~ '^trg1' order by 1;
---END---
---START---
create table trigpart3 (like trigpart);
---END---
---START---
create trigger trg1 after insert on trigpart3 for each row execute procedure trigger_nothing();
---END---
---START---
\d trigpart3
alter table trigpart attach partition trigpart3 FOR VALUES FROM (2000) to (3000);
---END---
---START---
-- fail
drop table trigpart3;
---END---
---START---
-- check display of unrelated triggers
create trigger samename after delete on trigpart execute function trigger_nothing();
---END---
---START---
create trigger samename after delete on trigpart1 execute function trigger_nothing();
---END---
---START---
\d trigpart1

drop table trigpart;
---END---
---START---
drop function trigger_nothing();
---END---
---START---
--
-- Verify that triggers are fired for partitioned tables
--
create table parted_stmt_trig (a int) partition by list (a);
---END---
---START---
create table parted_stmt_trig1 partition of parted_stmt_trig for values in (1);
---END---
---START---
create table parted_stmt_trig2 partition of parted_stmt_trig for values in (2);
---END---
---START---
create table parted2_stmt_trig (a int) partition by list (a);
---END---
---START---
create table parted2_stmt_trig1 partition of parted2_stmt_trig for values in (1);
---END---
---START---
create table parted2_stmt_trig2 partition of parted2_stmt_trig for values in (2);
---END---
---START---
create or replace function trigger_notice() returns trigger as $$
  begin
    raise notice 'trigger % on % % % for %', TG_NAME, TG_TABLE_NAME, TG_WHEN, TG_OP, TG_LEVEL;
    if TG_LEVEL = 'ROW' then
       return NEW;
    end if;
    return null;
  end;
  $$ language plpgsql;
---END---
---START---
-- insert/update/delete statement-level triggers on the parent
create trigger trig_ins_before before insert on parted_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_ins_after after insert on parted_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_before before update on parted_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_after after update on parted_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_before before delete on parted_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_after after delete on parted_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
-- insert/update/delete row-level triggers on the parent
create trigger trig_ins_after_parent after insert on parted_stmt_trig
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_after_parent after update on parted_stmt_trig
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_after_parent after delete on parted_stmt_trig
  for each row execute procedure trigger_notice();
---END---
---START---
-- insert/update/delete row-level triggers on the first partition
create trigger trig_ins_before_child before insert on parted_stmt_trig1
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_ins_after_child after insert on parted_stmt_trig1
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_before_child before update on parted_stmt_trig1
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_after_child after update on parted_stmt_trig1
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_before_child before delete on parted_stmt_trig1
  for each row execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_after_child after delete on parted_stmt_trig1
  for each row execute procedure trigger_notice();
---END---
---START---
-- insert/update/delete statement-level triggers on the parent
create trigger trig_ins_before_3 before insert on parted2_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_ins_after_3 after insert on parted2_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_before_3 before update on parted2_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_upd_after_3 after update on parted2_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_before_3 before delete on parted2_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
create trigger trig_del_after_3 after delete on parted2_stmt_trig
  for each statement execute procedure trigger_notice();
---END---
---START---
with ins (a) as (
  insert into parted2_stmt_trig values (1), (2) returning a
) insert into parted_stmt_trig select a from ins returning tableoid::regclass, a;
---END---
---START---
with upd as (
  update parted2_stmt_trig set a = a
) update parted_stmt_trig  set a = a;
---END---
---START---
delete from parted_stmt_trig;
---END---
---START---
copy on the parent
copy parted_stmt_trig(a) from stdin;
1
2
\.
---END---
---START---
copy on the first partition
copy parted_stmt_trig1(a) from stdin;
1
\.
---END---
---START---
-- Disabling a trigger in the parent table should disable children triggers too
alter table parted_stmt_trig disable trigger trig_ins_after_parent;
---END---
---START---
insert into parted_stmt_trig values (1);
---END---
---START---
alter table parted_stmt_trig enable trigger trig_ins_after_parent;
---END---
---START---
insert into parted_stmt_trig values (1);
---END---
---START---
drop table parted_stmt_trig, parted2_stmt_trig;
---END---
---START---
-- Verify that triggers fire in alphabetical order
create table parted_trig (a int) partition by range (a);
---END---
---START---
create table parted_trig_1 partition of parted_trig for values from (0) to (1000)
   partition by range (a);
---END---
---START---
create table parted_trig_1_1 partition of parted_trig_1 for values from (0) to (100);
---END---
---START---
create table parted_trig_2 partition of parted_trig for values from (1000) to (2000);
---END---
---START---
create trigger zzz after insert on parted_trig for each row execute procedure trigger_notice();
---END---
---START---
create trigger mmm after insert on parted_trig_1_1 for each row execute procedure trigger_notice();
---END---
---START---
create trigger aaa after insert on parted_trig_1 for each row execute procedure trigger_notice();
---END---
---START---
create trigger bbb after insert on parted_trig for each row execute procedure trigger_notice();
---END---
---START---
create trigger qqq after insert on parted_trig_1_1 for each row execute procedure trigger_notice();
---END---
---START---
insert into parted_trig values (50), (1500);
---END---
---START---
drop table parted_trig;
---END---
---START---
-- Verify propagation of trigger arguments to partitions
create table parted_trig (a int) partition by list (a);
---END---
---START---
create table parted_trig1 partition of parted_trig for values in (1);
---END---
---START---
create or replace function trigger_notice() returns trigger as $$
  declare
    arg1 text = TG_ARGV[0];
    arg2 integer = TG_ARGV[1];
  begin
    raise notice 'trigger % on % % % for % args % %',
		TG_NAME, TG_TABLE_NAME, TG_WHEN, TG_OP, TG_LEVEL, arg1, arg2;
    return null;
  end;
  $$ language plpgsql;
---END---
---START---
create trigger aaa after insert on parted_trig
   for each row execute procedure trigger_notice('quirky', 1);
---END---
---START---
-- Verify propagation of trigger arguments to partitions attached after creating trigger
create table parted_trig2 partition of parted_trig for values in (2);
---END---
---START---
create table parted_trig3 (like parted_trig);
---END---
---START---
alter table parted_trig attach partition parted_trig3 for values in (3);
---END---
---START---
insert into parted_trig values (1), (2), (3);
---END---
---START---
drop table parted_trig;
---END---
---START---
-- test irregular partitions (i.e., different column definitions),
-- including that the WHEN clause works
create function bark(text) returns bool language plpgsql immutable
  as $$ begin raise notice '% <- woof!', $1; return true; end; $$;
---END---
---START---
create or replace function trigger_notice_ab() returns trigger as $$
  begin
    raise notice 'trigger % on % % % for %: (a,b)=(%,%)',
		TG_NAME, TG_TABLE_NAME, TG_WHEN, TG_OP, TG_LEVEL,
		NEW.a, NEW.b;
    if TG_LEVEL = 'ROW' then
       return NEW;
    end if;
    return null;
  end;
  $$ language plpgsql;
---END---
---START---
create table parted_irreg_ancestor (fd text, b text, fd2 int, fd3 int, a int)
  partition by range (b);
---END---
---START---
alter table parted_irreg_ancestor drop column fd,
  drop column fd2, drop column fd3;
---END---
---START---
create table parted_irreg (fd int, a int, fd2 int, b text)
  partition by range (b);
---END---
---START---
alter table parted_irreg drop column fd, drop column fd2;
---END---
---START---
alter table parted_irreg_ancestor attach partition parted_irreg
  for values from ('aaaa') to ('zzzz');
---END---
---START---
create table parted1_irreg (b text, fd int, a int);
---END---
---START---
alter table parted1_irreg drop column fd;
---END---
---START---
alter table parted_irreg attach partition parted1_irreg
  for values from ('aaaa') to ('bbbb');
---END---
---START---
create trigger parted_trig after insert on parted_irreg
  for each row execute procedure trigger_notice_ab();
---END---
---START---
create trigger parted_trig_odd after insert on parted_irreg for each row
  when (bark(new.b) AND new.a % 2 = 1) execute procedure trigger_notice_ab();
---END---
---START---
-- we should hear barking for every insert, but parted_trig_odd only emits
-- noise for odd values of a. parted_trig does it for all inserts.
insert into parted_irreg values (1, 'aardvark'), (2, 'aanimals');
---END---
---START---
insert into parted1_irreg values ('aardwolf', 2);
---END---
---START---
insert into parted_irreg_ancestor values ('aasvogel', 3);
---END---
---START---
drop table parted_irreg_ancestor;
---END---
---START---
-- Before triggers and partitions
create table parted (a int, b int, c text) partition by list (a);
---END---
---START---
create table parted_1 partition of parted for values in (1)
  partition by list (b);
---END---
---START---
create table parted_1_1 partition of parted_1 for values in (1);
---END---
---START---
create function parted_trigfunc() returns trigger language plpgsql as $$
begin
  new.a = new.a + 1;
  return new;
end;
$$;
---END---
---START---
insert into parted values (1, 1, 'uno uno v1');
---END---
---START---
-- works
create trigger t before insert or update or delete on parted
  for each row execute function parted_trigfunc();
---END---
---START---
insert into parted values (1, 1, 'uno uno v2');
---END---
---START---
-- fail
update parted set c = c || 'v3';
---END---
---START---
-- fail
create or replace function parted_trigfunc() returns trigger language plpgsql as $$
begin
  new.b = new.b + 1;
  return new;
end;
$$;
---END---
---START---
insert into parted values (1, 1, 'uno uno v4');
---END---
---START---
-- fail
update parted set c = c || 'v5';
---END---
---START---
-- fail
create or replace function parted_trigfunc() returns trigger language plpgsql as $$
begin
  new.c = new.c || ' did '|| TG_OP;
  return new;
end;
$$;
---END---
---START---
insert into parted values (1, 1, 'uno uno');
---END---
---START---
-- works
update parted set c = c || ' v6';
---END---
---START---
-- works
select tableoid::regclass, * from parted;
---END---
---START---
-- update itself moves tuple to new partition; trigger still works
truncate table parted;
---END---
---START---
create table parted_2 partition of parted for values in (2);
---END---
---START---
insert into parted values (1, 1, 'uno uno v5');
---END---
---START---
update parted set a = 2;
---END---
---START---
select tableoid::regclass, * from parted;
---END---
---START---
-- both trigger and update change the partition
create or replace function parted_trigfunc2() returns trigger language plpgsql as $$
begin
  new.a = new.a + 1;
  return new;
end;
$$;
---END---
---START---
create trigger t2 before update on parted
  for each row execute function parted_trigfunc2();
---END---
---START---
truncate table parted;
---END---
---START---
insert into parted values (1, 1, 'uno uno v6');
---END---
---START---
create table parted_3 partition of parted for values in (3);
---END---
---START---
update parted set a = a + 1;
---END---
---START---
select tableoid::regclass, * from parted;
---END---
---START---
-- there's no partition for a=0, but this update works anyway because
-- the trigger causes the tuple to be routed to another partition
update parted set a = 0;
---END---
---START---
select tableoid::regclass, * from parted;
---END---
---START---
drop table parted;
---END---
---START---
create table parted (a int, b int, c text) partition by list ((a + b));
---END---
---START---
create or replace function parted_trigfunc() returns trigger language plpgsql as $$
begin
  new.a = new.a + new.b;
  return new;
end;
$$;
---END---
---START---
create table parted_1 partition of parted for values in (1, 2);
---END---
---START---
create table parted_2 partition of parted for values in (3, 4);
---END---
---START---
create trigger t before insert or update on parted
  for each row execute function parted_trigfunc();
---END---
---START---
insert into parted values (0, 1, 'zero win');
---END---
---START---
insert into parted values (1, 1, 'one fail');
---END---
---START---
insert into parted values (1, 2, 'two fail');
---END---
---START---
select * from parted;
---END---
---START---
drop table parted;
---END---
---START---
drop function parted_trigfunc();
---END---
---START---
--
-- Constraint triggers and partitioned tables
create table parted_constr_ancestor (a int, b text)
  partition by range (b);
---END---
---START---
create table parted_constr (a int, b text)
  partition by range (b);
---END---
---START---
alter table parted_constr_ancestor attach partition parted_constr
  for values from ('aaaa') to ('zzzz');
---END---
---START---
create table parted1_constr (a int, b text);
---END---
---START---
alter table parted_constr attach partition parted1_constr
  for values from ('aaaa') to ('bbbb');
---END---
---START---
create constraint trigger parted_trig after insert on parted_constr_ancestor
  deferrable
  for each row execute procedure trigger_notice_ab();
---END---
---START---
create constraint trigger parted_trig_two after insert on parted_constr
  deferrable initially deferred
  for each row when (bark(new.b) AND new.a % 2 = 1)
  execute procedure trigger_notice_ab();
---END---
---START---
-- The immediate constraint is fired immediately; the WHEN clause of the
-- deferred constraint is also called immediately.  The deferred constraint
-- is fired at commit time.
begin;
---END---
---START---
insert into parted_constr values (1, 'aardvark');
---END---
---START---
insert into parted1_constr values (2, 'aardwolf');
---END---
---START---
insert into parted_constr_ancestor values (3, 'aasvogel');
---END---
---START---
commit;
---END---
---START---
-- The WHEN clause is immediate, and both constraint triggers are fired at
-- commit time.
begin;
---END---
---START---
set constraints parted_trig deferred;
---END---
---START---
insert into parted_constr values (1, 'aardvark');
---END---
---START---
insert into parted1_constr values (2, 'aardwolf'), (3, 'aasvogel');
---END---
---START---
commit;
---END---
---START---
drop table parted_constr_ancestor;
---END---
---START---
drop function bark(text);
---END---
---START---
-- Test that the WHEN clause is set properly to partitions
create table parted_trigger (a int, b text) partition by range (a);
---END---
---START---
create table parted_trigger_1 partition of parted_trigger for values from (0) to (1000);
---END---
---START---
create table parted_trigger_2 (drp int, a int, b text);
---END---
---START---
alter table parted_trigger_2 drop column drp;
---END---
---START---
alter table parted_trigger attach partition parted_trigger_2 for values from (1000) to (2000);
---END---
---START---
create trigger parted_trigger after update on parted_trigger
  for each row when (new.a % 2 = 1 and length(old.b) >= 2) execute procedure trigger_notice_ab();
---END---
---START---
create table parted_trigger_3 (b text, a int) partition by range (length(b));
---END---
---START---
create table parted_trigger_3_1 partition of parted_trigger_3 for values from (1) to (3);
---END---
---START---
create table parted_trigger_3_2 partition of parted_trigger_3 for values from (3) to (5);
---END---
---START---
alter table parted_trigger attach partition parted_trigger_3 for values from (2000) to (3000);
---END---
---START---
insert into parted_trigger values
    (0, 'a'), (1, 'bbb'), (2, 'bcd'), (3, 'c'),
	(1000, 'c'), (1001, 'ddd'), (1002, 'efg'), (1003, 'f'),
	(2000, 'e'), (2001, 'fff'), (2002, 'ghi'), (2003, 'h');
---END---
---START---
update parted_trigger set a = a + 2;
---END---
---START---
-- notice for odd 'a' values, long 'b' values
drop table parted_trigger;
---END---
---START---
-- try a constraint trigger, also
create table parted_referenced (a int);
---END---
---START---
create table unparted_trigger (a int, b text);
---END---
---START---
-- for comparison purposes
create table parted_trigger (a int, b text) partition by range (a);
---END---
---START---
create table parted_trigger_1 partition of parted_trigger for values from (0) to (1000);
---END---
---START---
create table parted_trigger_2 (drp int, a int, b text);
---END---
---START---
alter table parted_trigger_2 drop column drp;
---END---
---START---
alter table parted_trigger attach partition parted_trigger_2 for values from (1000) to (2000);
---END---
---START---
create constraint trigger parted_trigger after update on parted_trigger
  from parted_referenced
  for each row execute procedure trigger_notice_ab();
---END---
---START---
create constraint trigger parted_trigger after update on unparted_trigger
  from parted_referenced
  for each row execute procedure trigger_notice_ab();
---END---
---START---
create table parted_trigger_3 (b text, a int) partition by range (length(b));
---END---
---START---
create table parted_trigger_3_1 partition of parted_trigger_3 for values from (1) to (3);
---END---
---START---
create table parted_trigger_3_2 partition of parted_trigger_3 for values from (3) to (5);
---END---
---START---
alter table parted_trigger attach partition parted_trigger_3 for values from (2000) to (3000);
---END---
---START---
select tgname, conname, t.tgrelid::regclass, t.tgconstrrelid::regclass,
  c.conrelid::regclass, c.confrelid::regclass
  from pg_trigger t join pg_constraint c on (t.tgconstraint = c.oid)
  where tgname = 'parted_trigger'
  order by t.tgrelid::regclass::text;
---END---
---START---
drop table parted_referenced, parted_trigger, unparted_trigger;
---END---
---START---
-- verify that the "AFTER UPDATE OF columns" event is propagated correctly
create table parted_trigger (a int, b text) partition by range (a);
---END---
---START---
create table parted_trigger_1 partition of parted_trigger for values from (0) to (1000);
---END---
---START---
create table parted_trigger_2 (drp int, a int, b text);
---END---
---START---
alter table parted_trigger_2 drop column drp;
---END---
---START---
alter table parted_trigger attach partition parted_trigger_2 for values from (1000) to (2000);
---END---
---START---
create trigger parted_trigger after update of b on parted_trigger
  for each row execute procedure trigger_notice_ab();
---END---
---START---
create table parted_trigger_3 (b text, a int) partition by range (length(b));
---END---
---START---
create table parted_trigger_3_1 partition of parted_trigger_3 for values from (1) to (4);
---END---
---START---
create table parted_trigger_3_2 partition of parted_trigger_3 for values from (4) to (8);
---END---
---START---
alter table parted_trigger attach partition parted_trigger_3 for values from (2000) to (3000);
---END---
---START---
insert into parted_trigger values (0, 'a'), (1000, 'c'), (2000, 'e'), (2001, 'eeee');
---END---
---START---
update parted_trigger set a = a + 2;
---END---
---START---
-- no notices here
update parted_trigger set b = b || 'b';
---END---
---START---
-- all triggers should fire
drop table parted_trigger;
---END---
---START---
drop function trigger_notice_ab();
---END---
---START---
-- Make sure we don't end up with unnecessary copies of triggers, when
-- cloning them.
create table trg_clone (a int) partition by range (a);
---END---
---START---
create table trg_clone1 partition of trg_clone for values from (0) to (1000);
---END---
---START---
alter table trg_clone add constraint uniq unique (a) deferrable;
---END---
---START---
create table trg_clone2 partition of trg_clone for values from (1000) to (2000);
---END---
---START---
create table trg_clone3 partition of trg_clone for values from (2000) to (3000)
  partition by range (a);
---END---
---START---
create table trg_clone_3_3 partition of trg_clone3 for values from (2000) to (2100);
---END---
---START---
select tgrelid::regclass, count(*) from pg_trigger
  where tgrelid::regclass in ('trg_clone', 'trg_clone1', 'trg_clone2',
	'trg_clone3', 'trg_clone_3_3')
  group by tgrelid::regclass order by tgrelid::regclass;
---END---
---START---
drop table trg_clone;
---END---
---START---
-- Test the interaction between ALTER TABLE .. DISABLE TRIGGER and
-- both kinds of inheritance.  Historically, legacy inheritance has
-- not recursed to children, so that behavior is preserved.
create table parent (a int);
---END---
---START---
create table child1 () inherits (parent);
---END---
---START---
create function trig_nothing() returns trigger language plpgsql
  as $$ begin return null; end $$;
---END---
---START---
create trigger tg after insert on parent
  for each row execute function trig_nothing();
---END---
---START---
create trigger tg after insert on child1
  for each row execute function trig_nothing();
---END---
---START---
alter table parent disable trigger tg;
---END---
---START---
select tgrelid::regclass, tgname, tgenabled from pg_trigger
  where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text;
---END---
---START---
alter table only parent enable always trigger tg;
---END---
---START---
select tgrelid::regclass, tgname, tgenabled from pg_trigger
  where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text;
---END---
---START---
drop table parent, child1;
---END---
---START---
create table parent (a int) partition by list (a);
---END---
---START---
create table child1 partition of parent for values in (1);
---END---
---START---
create trigger tg after insert on parent
  for each row execute procedure trig_nothing();
---END---
---START---
create trigger tg_stmt after insert on parent
  for statement execute procedure trig_nothing();
---END---
---START---
select tgrelid::regclass, tgname, tgenabled from pg_trigger
  where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text, tgname;
---END---
---START---
alter table only parent enable always trigger tg;
---END---
---START---
-- no recursion because ONLY
alter table parent enable always trigger tg_stmt;
---END---
---START---
-- no recursion because statement trigger
select tgrelid::regclass, tgname, tgenabled from pg_trigger
  where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text, tgname;
---END---
---START---
-- The following is a no-op for the parent trigger but not so
-- for the child trigger, so recursion should be applied.
alter table parent enable always trigger tg;
---END---
---START---
select tgrelid::regclass, tgname, tgenabled from pg_trigger
  where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text, tgname;
---END---
---START---
-- This variant malfunctioned in some releases.
alter table parent disable trigger user;
---END---
---START---
select tgrelid::regclass, tgname, tgenabled from pg_trigger
  where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text, tgname;
---END---
---START---
drop table parent, child1;
---END---
---START---
-- Check processing of foreign key triggers
create table parent (a int primary key, f int references parent)
  partition by list (a);
---END---
---START---
create table child1 partition of parent for values in (1);
---END---
---START---
select tgrelid::regclass, rtrim(tgname, '0123456789') as tgname,
  tgfoid::regproc, tgenabled
  from pg_trigger where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text, tgfoid;
---END---
---START---
alter table parent disable trigger all;
---END---
---START---
select tgrelid::regclass, rtrim(tgname, '0123456789') as tgname,
  tgfoid::regproc, tgenabled
  from pg_trigger where tgrelid in ('parent'::regclass, 'child1'::regclass)
  order by tgrelid::regclass::text, tgfoid;
---END---
---START---
drop table parent, child1;
---END---
---START---
-- Verify that firing state propagates correctly on creation, too
CREATE TABLE trgfire (i int) PARTITION BY RANGE (i);
---END---
---START---
CREATE TABLE trgfire1 PARTITION OF trgfire FOR VALUES FROM (1) TO (10);
---END---
---START---
CREATE OR REPLACE FUNCTION tgf() RETURNS trigger LANGUAGE plpgsql
  AS $$ begin raise exception 'except'; end $$;
---END---
---START---
CREATE TRIGGER tg AFTER INSERT ON trgfire FOR EACH ROW EXECUTE FUNCTION tgf();
---END---
---START---
INSERT INTO trgfire VALUES (1);
---END---
---START---
ALTER TABLE trgfire DISABLE TRIGGER tg;
---END---
---START---
INSERT INTO trgfire VALUES (1);
---END---
---START---
CREATE TABLE trgfire2 PARTITION OF trgfire FOR VALUES FROM (10) TO (20);
---END---
---START---
INSERT INTO trgfire VALUES (11);
---END---
---START---
CREATE TABLE trgfire3 (LIKE trgfire);
---END---
---START---
ALTER TABLE trgfire ATTACH PARTITION trgfire3 FOR VALUES FROM (20) TO (30);
---END---
---START---
INSERT INTO trgfire VALUES (21);
---END---
---START---
CREATE TABLE trgfire4 PARTITION OF trgfire FOR VALUES FROM (30) TO (40) PARTITION BY LIST (i);
---END---
---START---
CREATE TABLE trgfire4_30 PARTITION OF trgfire4 FOR VALUES IN (30);
---END---
---START---
INSERT INTO trgfire VALUES (30);
---END---
---START---
CREATE TABLE trgfire5 (LIKE trgfire) PARTITION BY LIST (i);
---END---
---START---
CREATE TABLE trgfire5_40 PARTITION OF trgfire5 FOR VALUES IN (40);
---END---
---START---
ALTER TABLE trgfire ATTACH PARTITION trgfire5 FOR VALUES FROM (40) TO (50);
---END---
---START---
INSERT INTO trgfire VALUES (40);
---END---
---START---
SELECT tgrelid::regclass, tgenabled FROM pg_trigger
  WHERE tgrelid::regclass IN (SELECT oid from pg_class where relname LIKE 'trgfire%')
  ORDER BY tgrelid::regclass::text;
---END---
---START---
ALTER TABLE trgfire ENABLE TRIGGER tg;
---END---
---START---
INSERT INTO trgfire VALUES (1);
---END---
---START---
INSERT INTO trgfire VALUES (11);
---END---
---START---
INSERT INTO trgfire VALUES (21);
---END---
---START---
INSERT INTO trgfire VALUES (30);
---END---
---START---
INSERT INTO trgfire VALUES (40);
---END---
---START---
DROP TABLE trgfire;
---END---
---START---
DROP FUNCTION tgf();
---END---
---START---
--
-- Test the interaction between transition tables and both kinds of
-- inheritance.  We'll dump the contents of the transition tables in a
-- format that shows the attribute order, so that we can distinguish
-- tuple formats (though not dropped attributes).
--

create or replace function dump_insert() returns trigger language plpgsql as
$$
  begin
    raise notice 'trigger = %, new table = %',
                 TG_NAME,
                 (select string_agg(new_table::text, ', ' order by a) from new_table);
    return null;
  end;
$$;
---END---
---START---
create or replace function dump_update() returns trigger language plpgsql as
$$
  begin
    raise notice 'trigger = %, old table = %, new table = %',
                 TG_NAME,
                 (select string_agg(old_table::text, ', ' order by a) from old_table),
                 (select string_agg(new_table::text, ', ' order by a) from new_table);
    return null;
  end;
$$;
---END---
---START---
create or replace function dump_delete() returns trigger language plpgsql as
$$
  begin
    raise notice 'trigger = %, old table = %',
                 TG_NAME,
                 (select string_agg(old_table::text, ', ' order by a) from old_table);
    return null;
  end;
$$;
---END---
---START---
--
-- Verify behavior of statement triggers on partition hierarchy with
-- transition tables.  Tuples should appear to each trigger in the
-- format of the relation the trigger is attached to.
--

-- set up a partition hierarchy with some different TupleDescriptors
create table parent (a text, b int) partition by list (a);
---END---
---START---
-- a child matching parent
create table child1 partition of parent for values in ('AAA');
---END---
---START---
-- a child with a dropped column
create table child2 (x int, a text, b int);
---END---
---START---
alter table child2 drop column x;
---END---
---START---
alter table parent attach partition child2 for values in ('BBB');
---END---
---START---
-- a child with a different column order
create table child3 (b int, a text);
---END---
---START---
alter table parent attach partition child3 for values in ('CCC');
---END---
---START---
create trigger parent_insert_trig
  after insert on parent referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger parent_update_trig
  after update on parent referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger parent_delete_trig
  after delete on parent referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create trigger child1_insert_trig
  after insert on child1 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger child1_update_trig
  after update on child1 referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger child1_delete_trig
  after delete on child1 referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create trigger child2_insert_trig
  after insert on child2 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger child2_update_trig
  after update on child2 referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger child2_delete_trig
  after delete on child2 referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create trigger child3_insert_trig
  after insert on child3 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger child3_update_trig
  after update on child3 referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger child3_delete_trig
  after delete on child3 referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
SELECT trigger_name, event_manipulation, event_object_schema, event_object_table,
       action_order, action_condition, action_orientation, action_timing,
       action_reference_old_table, action_reference_new_table
  FROM information_schema.triggers
  WHERE event_object_table IN ('parent', 'child1', 'child2', 'child3')
  ORDER BY trigger_name COLLATE "C", 2;
---END---
---START---
-- insert directly into children sees respective child-format tuples
insert into child1 values ('AAA', 42);
---END---
---START---
insert into child2 values ('BBB', 42);
---END---
---START---
insert into child3 values (42, 'CCC');
---END---
---START---
-- update via parent sees parent-format tuples
update parent set b = b + 1;
---END---
---START---
-- delete via parent sees parent-format tuples
delete from parent;
---END---
---START---
-- insert into parent sees parent-format tuples
insert into parent values ('AAA', 42);
---END---
---START---
insert into parent values ('BBB', 42);
---END---
---START---
insert into parent values ('CCC', 42);
---END---
---START---
-- delete from children sees respective child-format tuples
delete from child1;
---END---
---START---
delete from child2;
---END---
---START---
delete from child3;
---END---
---START---
copy into parent sees parent-format tuples
copy parent (a, b) from stdin;
AAA	42
BBB	42
CCC	42
\.
---END---
---START---
-- DML affecting parent sees tuples collected from children even if
-- there is no transition table trigger on the children
drop trigger child1_insert_trig on child1;
---END---
---START---
drop trigger child1_update_trig on child1;
---END---
---START---
drop trigger child1_delete_trig on child1;
---END---
---START---
drop trigger child2_insert_trig on child2;
---END---
---START---
drop trigger child2_update_trig on child2;
---END---
---START---
drop trigger child2_delete_trig on child2;
---END---
---START---
drop trigger child3_insert_trig on child3;
---END---
---START---
drop trigger child3_update_trig on child3;
---END---
---START---
drop trigger child3_delete_trig on child3;
---END---
---START---
delete from parent;
---END---
---START---
copy into parent sees tuples collected from children even if there
-- is no transition-table trigger on the children
copy parent (a, b) from stdin;
AAA	42
BBB	42
CCC	42
\.
---END---
---START---
-- insert into parent with a before trigger on a child tuple before
-- insertion, and we capture the newly modified row in parent format
create or replace function intercept_insert() returns trigger language plpgsql as
$$
  begin
    new.b = new.b + 1000;
    return new;
  end;
$$;
---END---
---START---
create trigger intercept_insert_child3
  before insert on child3
  for each row execute procedure intercept_insert();
---END---
---START---
-- insert, parent trigger sees post-modification parent-format tuple
insert into parent values ('AAA', 42), ('BBB', 42), ('CCC', 66);
---END---
---START---
copy parent (a, b) from stdin;
AAA	42
BBB	42
CCC	234
\.
---END---
---START---
drop table child1, child2, child3, parent;
---END---
---START---
drop function intercept_insert();
---END---
---START---
--
-- Verify prohibition of row triggers with transition triggers on
-- partitions
--
create table parent (a text, b int) partition by list (a);
---END---
---START---
create table child partition of parent for values in ('AAA');
---END---
---START---
-- adding row trigger with transition table fails
create trigger child_row_trig
  after insert on child referencing new table as new_table
  for each row execute procedure dump_insert();
---END---
---START---
-- detaching it first works
alter table parent detach partition child;
---END---
---START---
create trigger child_row_trig
  after insert on child referencing new table as new_table
  for each row execute procedure dump_insert();
---END---
---START---
-- but now we're not allowed to reattach it
alter table parent attach partition child for values in ('AAA');
---END---
---START---
-- drop the trigger, and now we're allowed to attach it again
drop trigger child_row_trig on child;
---END---
---START---
alter table parent attach partition child for values in ('AAA');
---END---
---START---
drop table child, parent;
---END---
---START---
--
-- Verify behavior of statement triggers on (non-partition)
-- inheritance hierarchy with transition tables; similar to the
-- partition case, except there is no rerouting on insertion and child
-- tables can have extra columns
--

-- set up inheritance hierarchy with different TupleDescriptors
create table parent (a text, b int);
---END---
---START---
-- a child matching parent
create table child1 () inherits (parent);
---END---
---START---
-- a child with a different column order
create table child2 (b int, a text);
---END---
---START---
alter table child2 inherit parent;
---END---
---START---
-- a child with an extra column
create table child3 (c text) inherits (parent);
---END---
---START---
create trigger parent_insert_trig
  after insert on parent referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger parent_update_trig
  after update on parent referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger parent_delete_trig
  after delete on parent referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create trigger child1_insert_trig
  after insert on child1 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger child1_update_trig
  after update on child1 referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger child1_delete_trig
  after delete on child1 referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create trigger child2_insert_trig
  after insert on child2 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger child2_update_trig
  after update on child2 referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger child2_delete_trig
  after delete on child2 referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create trigger child3_insert_trig
  after insert on child3 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger child3_update_trig
  after update on child3 referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger child3_delete_trig
  after delete on child3 referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
-- insert directly into children sees respective child-format tuples
insert into child1 values ('AAA', 42);
---END---
---START---
insert into child2 values (42, 'BBB');
---END---
---START---
insert into child3 values ('CCC', 42, 'foo');
---END---
---START---
-- update via parent sees parent-format tuples
update parent set b = b + 1;
---END---
---START---
-- delete via parent sees parent-format tuples
delete from parent;
---END---
---START---
-- reinsert values into children for next test...
insert into child1 values ('AAA', 42);
---END---
---START---
insert into child2 values (42, 'BBB');
---END---
---START---
insert into child3 values ('CCC', 42, 'foo');
---END---
---START---
-- delete from children sees respective child-format tuples
delete from child1;
---END---
---START---
delete from child2;
---END---
---START---
delete from child3;
---END---
---START---
copy into parent sees parent-format tuples (no rerouting, so these
-- are really inserted into the parent)
copy parent (a, b) from stdin;
AAA	42
BBB	42
CCC	42
\.
---END---
---START---
copy if there is an index (interesting because rows are
-- captured by a different code path in copyfrom.c if there are indexes)
create index on parent(b);
copy parent (a, b) from stdin;
DDD	42
\.
---END---
---START---
-- DML affecting parent sees tuples collected from children even if
-- there is no transition table trigger on the children
drop trigger child1_insert_trig on child1;
---END---
---START---
drop trigger child1_update_trig on child1;
---END---
---START---
drop trigger child1_delete_trig on child1;
---END---
---START---
drop trigger child2_insert_trig on child2;
---END---
---START---
drop trigger child2_update_trig on child2;
---END---
---START---
drop trigger child2_delete_trig on child2;
---END---
---START---
drop trigger child3_insert_trig on child3;
---END---
---START---
drop trigger child3_update_trig on child3;
---END---
---START---
drop trigger child3_delete_trig on child3;
---END---
---START---
delete from parent;
---END---
---START---
drop table child1, child2, child3, parent;
---END---
---START---
--
-- Verify prohibition of row triggers with transition triggers on
-- inheritance children
--
create table parent (a text, b int);
---END---
---START---
create table child () inherits (parent);
---END---
---START---
-- adding row trigger with transition table fails
create trigger child_row_trig
  after insert on child referencing new table as new_table
  for each row execute procedure dump_insert();
---END---
---START---
-- disinheriting it first works
alter table child no inherit parent;
---END---
---START---
create trigger child_row_trig
  after insert on child referencing new table as new_table
  for each row execute procedure dump_insert();
---END---
---START---
-- but now we're not allowed to make it inherit anymore
alter table child inherit parent;
---END---
---START---
-- drop the trigger, and now we're allowed to make it inherit again
drop trigger child_row_trig on child;
---END---
---START---
alter table child inherit parent;
---END---
---START---
drop table child, parent;
---END---
---START---
--
-- Verify behavior of queries with wCTEs, where multiple transition
-- tuplestores can be active at the same time because there are
-- multiple DML statements that might fire triggers with transition
-- tables
--
create table table1 (a int);
---END---
---START---
create table table2 (a text);
---END---
---START---
create trigger table1_trig
  after insert on table1 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger table2_trig
  after insert on table2 referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
with wcte as (insert into table1 values (42))
  insert into table2 values ('hello world');
---END---
---START---
with wcte as (insert into table1 values (43))
  insert into table1 values (44);
---END---
---START---
select * from table1;
---END---
---START---
select * from table2;
---END---
---START---
drop table table1;
---END---
---START---
drop table table2;
---END---
---START---
--
-- Verify behavior of INSERT ... ON CONFLICT DO UPDATE ... with
-- transition tables.
--

create table my_table (a int primary key, b text);
---END---
---START---
create trigger my_table_insert_trig
  after insert on my_table referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger my_table_update_trig
  after update on my_table referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
-- inserts only
insert into my_table values (1, 'AAA'), (2, 'BBB')
  on conflict (a) do
  update set b = my_table.b || ':' || excluded.b;
---END---
---START---
-- mixture of inserts and updates
insert into my_table values (1, 'AAA'), (2, 'BBB'), (3, 'CCC'), (4, 'DDD')
  on conflict (a) do
  update set b = my_table.b || ':' || excluded.b;
---END---
---START---
-- updates only
insert into my_table values (3, 'CCC'), (4, 'DDD')
  on conflict (a) do
  update set b = my_table.b || ':' || excluded.b;
---END---
---START---
--
-- now using a partitioned table
--

create table iocdu_tt_parted (a int primary key, b text) partition by list (a);
---END---
---START---
create table iocdu_tt_parted1 partition of iocdu_tt_parted for values in (1);
---END---
---START---
create table iocdu_tt_parted2 partition of iocdu_tt_parted for values in (2);
---END---
---START---
create table iocdu_tt_parted3 partition of iocdu_tt_parted for values in (3);
---END---
---START---
create table iocdu_tt_parted4 partition of iocdu_tt_parted for values in (4);
---END---
---START---
create trigger iocdu_tt_parted_insert_trig
  after insert on iocdu_tt_parted referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger iocdu_tt_parted_update_trig
  after update on iocdu_tt_parted referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
-- inserts only
insert into iocdu_tt_parted values (1, 'AAA'), (2, 'BBB')
  on conflict (a) do
  update set b = iocdu_tt_parted.b || ':' || excluded.b;
---END---
---START---
-- mixture of inserts and updates
insert into iocdu_tt_parted values (1, 'AAA'), (2, 'BBB'), (3, 'CCC'), (4, 'DDD')
  on conflict (a) do
  update set b = iocdu_tt_parted.b || ':' || excluded.b;
---END---
---START---
-- updates only
insert into iocdu_tt_parted values (3, 'CCC'), (4, 'DDD')
  on conflict (a) do
  update set b = iocdu_tt_parted.b || ':' || excluded.b;
---END---
---START---
drop table iocdu_tt_parted;
---END---
---START---
--
-- Verify that you can't create a trigger with transition tables for
-- more than one event.
--

create trigger my_table_multievent_trig
  after insert or update on my_table referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
--
-- Verify that you can't create a trigger with transition tables with
-- a column list.
--

create trigger my_table_col_update_trig
  after update of b on my_table referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
drop table my_table;
---END---
---START---
--
-- Test firing of triggers with transition tables by foreign key cascades
--

create table refd_table (a int primary key, b text);
---END---
---START---
create table trig_table (a int, b text,
  foreign key (a) references refd_table on update cascade on delete cascade
);
---END---
---START---
create trigger trig_table_before_trig
  before insert or update or delete on trig_table
  for each statement execute procedure trigger_func('trig_table');
---END---
---START---
create trigger trig_table_insert_trig
  after insert on trig_table referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger trig_table_update_trig
  after update on trig_table referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger trig_table_delete_trig
  after delete on trig_table referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
insert into refd_table values
  (1, 'one'),
  (2, 'two'),
  (3, 'three');
---END---
---START---
insert into trig_table values
  (1, 'one a'),
  (1, 'one b'),
  (2, 'two a'),
  (2, 'two b'),
  (3, 'three a'),
  (3, 'three b');
---END---
---START---
update refd_table set a = 11 where b = 'one';
---END---
---START---
select * from trig_table;
---END---
---START---
delete from refd_table where length(b) = 3;
---END---
---START---
select * from trig_table;
---END---
---START---
drop table refd_table, trig_table;
---END---
---START---
--
-- self-referential FKs are even more fun
--

create table self_ref (a int primary key,
                       b int references self_ref(a) on delete cascade);
---END---
---START---
create trigger self_ref_before_trig
  before delete on self_ref
  for each statement execute procedure trigger_func('self_ref');
---END---
---START---
create trigger self_ref_r_trig
  after delete on self_ref referencing old table as old_table
  for each row execute procedure dump_delete();
---END---
---START---
create trigger self_ref_s_trig
  after delete on self_ref referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
insert into self_ref values (1, null), (2, 1), (3, 2);
---END---
---START---
delete from self_ref where a = 1;
---END---
---START---
-- without AR trigger, cascaded deletes all end up in one transition table
drop trigger self_ref_r_trig on self_ref;
---END---
---START---
insert into self_ref values (1, null), (2, 1), (3, 2), (4, 3);
---END---
---START---
delete from self_ref where a = 1;
---END---
---START---
drop table self_ref;
---END---
---START---
--
-- test transition tables with MERGE
--
create table merge_target_table (a int primary key, b text);
---END---
---START---
create trigger merge_target_table_insert_trig
  after insert on merge_target_table referencing new table as new_table
  for each statement execute procedure dump_insert();
---END---
---START---
create trigger merge_target_table_update_trig
  after update on merge_target_table referencing old table as old_table new table as new_table
  for each statement execute procedure dump_update();
---END---
---START---
create trigger merge_target_table_delete_trig
  after delete on merge_target_table referencing old table as old_table
  for each statement execute procedure dump_delete();
---END---
---START---
create table merge_source_table (a int, b text);
---END---
---START---
insert into merge_source_table
  values (1, 'initial1'), (2, 'initial2'),
		 (3, 'initial3'), (4, 'initial4');
---END---
---START---
merge into merge_target_table t
using merge_source_table s
on t.a = s.a
when not matched then
  insert values (a, b);
---END---
---START---
merge into merge_target_table t
using merge_source_table s
on t.a = s.a
when matched and s.a <= 2 then
	update set b = t.b || ' updated by merge'
when matched and s.a > 2 then
	delete
when not matched then
  insert values (a, b);
---END---
---START---
merge into merge_target_table t
using merge_source_table s
on t.a = s.a
when matched and s.a <= 2 then
	update set b = t.b || ' updated again by merge'
when matched and s.a > 2 then
	delete
when not matched then
  insert values (a, b);
---END---
---START---
drop table merge_source_table, merge_target_table;
---END---
---START---
-- cleanup
drop function dump_insert();
---END---
---START---
drop function dump_update();
---END---
---START---
drop function dump_delete();
---END---
---START---
--
-- Tests for CREATE OR REPLACE TRIGGER
--
create table my_table (id integer);
---END---
---START---
create function funcA() returns trigger as $$
begin
  raise notice 'hello from funcA';
  return null;
end; $$ language plpgsql;
---END---
---START---
create function funcB() returns trigger as $$
begin
  raise notice 'hello from funcB';
  return null;
end; $$ language plpgsql;
---END---
---START---
create trigger my_trig
  after insert on my_table
  for each row execute procedure funcA();
---END---
---START---
create trigger my_trig
  before insert on my_table
  for each row execute procedure funcB();
---END---
---START---
-- should fail

insert into my_table values (1);
---END---
---START---
create or replace trigger my_trig
  before insert on my_table
  for each row execute procedure funcB();
---END---
---START---
-- OK

insert into my_table values (2);
---END---
---START---
-- this insert should become a no-op

table my_table;
---END---
---START---
drop table my_table;
---END---
---START---
-- test CREATE OR REPLACE TRIGGER on partition table
create table parted_trig (a int) partition by range (a);
---END---
---START---
create table parted_trig_1 partition of parted_trig
       for values from (0) to (1000) partition by range (a);
---END---
---START---
create table parted_trig_1_1 partition of parted_trig_1 for values from (0) to (100);
---END---
---START---
create table parted_trig_2 partition of parted_trig for values from (1000) to (2000);
---END---
---START---
create table default_parted_trig partition of parted_trig default;
---END---
---START---
-- test that trigger can be replaced by another one
-- at the same level of partition table
create or replace trigger my_trig
  after insert on parted_trig
  for each row execute procedure funcA();
---END---
---START---
insert into parted_trig (a) values (50);
---END---
---START---
create or replace trigger my_trig
  after insert on parted_trig
  for each row execute procedure funcB();
---END---
---START---
insert into parted_trig (a) values (50);
---END---
---START---
-- test that child trigger cannot be replaced directly
create or replace trigger my_trig
  after insert on parted_trig
  for each row execute procedure funcA();
---END---
---START---
insert into parted_trig (a) values (50);
---END---
---START---
create or replace trigger my_trig
  after insert on parted_trig_1
  for each row execute procedure funcB();
---END---
---START---
-- should fail
insert into parted_trig (a) values (50);
---END---
---START---
drop trigger my_trig on parted_trig;
---END---
---START---
insert into parted_trig (a) values (50);
---END---
---START---
-- test that user trigger can be overwritten by one defined at upper level
create trigger my_trig
  after insert on parted_trig_1
  for each row execute procedure funcA();
---END---
---START---
insert into parted_trig (a) values (50);
---END---
---START---
create trigger my_trig
  after insert on parted_trig
  for each row execute procedure funcB();
---END---
---START---
-- should fail
insert into parted_trig (a) values (50);
---END---
---START---
create or replace trigger my_trig
  after insert on parted_trig
  for each row execute procedure funcB();
---END---
---START---
insert into parted_trig (a) values (50);
---END---
---START---
-- cleanup
drop table parted_trig;
---END---
---START---
drop function funcA();
---END---
---START---
drop function funcB();
---END---
---START---
-- Leave around some objects for other tests
create table trigger_parted (a int primary key) partition by list (a);
---END---
---START---
create function trigger_parted_trigfunc() returns trigger language plpgsql as
  $$ begin end; $$;
---END---
---START---
create trigger aft_row after insert or update on trigger_parted
  for each row execute function trigger_parted_trigfunc();
---END---
---START---
create table trigger_parted_p1 partition of trigger_parted for values in (1)
  partition by list (a);
---END---
---START---
create table trigger_parted_p1_1 partition of trigger_parted_p1 for values in (1);
---END---
---START---
create table trigger_parted_p2 partition of trigger_parted for values in (2)
  partition by list (a);
---END---
---START---
create table trigger_parted_p2_2 partition of trigger_parted_p2 for values in (2);
---END---
---START---
alter table only trigger_parted_p2 disable trigger aft_row;
---END---
---START---
alter table trigger_parted_p2_2 enable always trigger aft_row;
---END---
---START---
-- verify transition table conversion slot's lifetime
-- https://postgr.es/m/39a71864-b120-5a5c-8cc5-c632b6f16761@amazon.com
create table convslot_test_parent (col1 text primary key);
---END---
---START---
create table convslot_test_child (col1 text primary key,
	foreign key (col1) references convslot_test_parent(col1) on delete cascade on update cascade
);
---END---
---START---
alter table convslot_test_child add column col2 text not null default 'tutu';
---END---
---START---
insert into convslot_test_parent(col1) values ('1');
---END---
---START---
insert into convslot_test_child(col1) values ('1');
---END---
---START---
insert into convslot_test_parent(col1) values ('3');
---END---
---START---
insert into convslot_test_child(col1) values ('3');
---END---
---START---
create function convslot_trig1()
returns trigger
language plpgsql
AS $$
begin
raise notice 'trigger = %, old_table = %',
          TG_NAME,
          (select string_agg(old_table::text, ', ' order by col1) from old_table);
return null;
end; $$;
---END---
---START---
create function convslot_trig2()
returns trigger
language plpgsql
AS $$
begin
raise notice 'trigger = %, new table = %',
          TG_NAME,
          (select string_agg(new_table::text, ', ' order by col1) from new_table);
return null;
end; $$;
---END---
---START---
create trigger but_trigger after update on convslot_test_child
referencing new table as new_table
for each statement execute function convslot_trig2();
---END---
---START---
update convslot_test_parent set col1 = col1 || '1';
---END---
---START---
create function convslot_trig3()
returns trigger
language plpgsql
AS $$
begin
raise notice 'trigger = %, old_table = %, new table = %',
          TG_NAME,
          (select string_agg(old_table::text, ', ' order by col1) from old_table),
          (select string_agg(new_table::text, ', ' order by col1) from new_table);
return null;
end; $$;
---END---
---START---
create trigger but_trigger2 after update on convslot_test_child
referencing old table as old_table new table as new_table
for each statement execute function convslot_trig3();
---END---
---START---
update convslot_test_parent set col1 = col1 || '1';
---END---
---START---
create trigger bdt_trigger after delete on convslot_test_child
referencing old table as old_table
for each statement execute function convslot_trig1();
---END---
---START---
delete from convslot_test_parent;
---END---
---START---
drop table convslot_test_child, convslot_test_parent;
---END---
---START---
drop function convslot_trig1();
---END---
---START---
drop function convslot_trig2();
---END---
---START---
drop function convslot_trig3();
---END---
---START---
-- Bug #17607: variant of above in which trigger function raises an error;
-- we don't see any ill effects unless trigger tuple requires mapping

create table convslot_test_parent (id int primary key, val int)
partition by range (id);
---END---
---START---
create table convslot_test_part (val int, id int not null);
---END---
---START---
alter table convslot_test_parent
  attach partition convslot_test_part for values from (1) to (1000);
---END---
---START---
create function convslot_trig4() returns trigger as
$$begin raise exception 'BOOM!'; end$$ language plpgsql;
---END---
---START---
create trigger convslot_test_parent_update
    after update on convslot_test_parent
    referencing old table as old_rows new table as new_rows
    for each statement execute procedure convslot_trig4();
---END---
---START---
insert into convslot_test_parent (id, val) values (1, 2);
---END---
---START---
begin;
---END---
---START---
savepoint svp;
---END---
---START---
update convslot_test_parent set val = 3;
---END---
---START---
-- error expected
rollback to savepoint svp;
---END---
---START---
rollback;
---END---
---START---
drop table convslot_test_parent;
---END---
---START---
drop function convslot_trig4();
---END---
---START---
-- Test trigger renaming on partitioned tables
create table grandparent (id int, primary key (id)) partition by range (id);
---END---
---START---
create table middle partition of grandparent for values from (1) to (10)
partition by range (id);
---END---
---START---
create table chi partition of middle for values from (1) to (5);
---END---
---START---
create table cho partition of middle for values from (6) to (10);
---END---
---START---
create function f () returns trigger as
$$ begin return new; end; $$
language plpgsql;
---END---
---START---
create trigger a after insert on grandparent
for each row execute procedure f();
---END---
---START---
alter trigger a on grandparent rename to b;
---END---
---START---
select tgrelid::regclass, tgname,
(select tgname from pg_trigger tr where tr.oid = pg_trigger.tgparentid) parent_tgname
from pg_trigger where tgrelid in (select relid from pg_partition_tree('grandparent'))
order by tgname, tgrelid::regclass::text COLLATE "C";
---END---
---START---
alter trigger a on only grandparent rename to b;
---END---
---START---
-- ONLY not supported
alter trigger b on middle rename to c;
---END---
---START---
-- can't rename trigger on partition
create trigger c after insert on middle
for each row execute procedure f();
---END---
---START---
alter trigger b on grandparent rename to c;
---END---
---START---
-- Rename cascading does not affect statement triggers
create trigger p after insert on grandparent for each statement execute function f();
---END---
---START---
create trigger p after insert on middle for each statement execute function f();
---END---
---START---
alter trigger p on grandparent rename to q;
---END---
---START---
select tgrelid::regclass, tgname,
(select tgname from pg_trigger tr where tr.oid = pg_trigger.tgparentid) parent_tgname
from pg_trigger where tgrelid in (select relid from pg_partition_tree('grandparent'))
order by tgname, tgrelid::regclass::text COLLATE "C";
---END---
---START---
drop table grandparent;
---END---
---START---
-- Trigger renaming does not recurse on legacy inheritance
create table parent (a int);
---END---
---START---
create table child () inherits (parent);
---END---
---START---
create trigger parenttrig after insert on parent
for each row execute procedure f();
---END---
---START---
create trigger parenttrig after insert on child
for each row execute procedure f();
---END---
---START---
alter trigger parenttrig on parent rename to anothertrig;
---END---
---START---
\d+ child

drop table parent, child;
---END---
---START---
drop function f();
---END---
