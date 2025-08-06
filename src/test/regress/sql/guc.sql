---START---
-- pg_regress should ensure that this default value applies; however
-- we can't rely on any specific default value of vacuum_cost_delay
SHOW datestyle;
---END---
---START---

-- SET to some nondefault value
SET vacuum_cost_delay TO 40;
---END---
---START---
SET datestyle = 'ISO, YMD';
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- SET LOCAL has no effect outside of a transaction
SET LOCAL vacuum_cost_delay TO 50;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET LOCAL datestyle = 'SQL';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- SET LOCAL within a transaction that commits
BEGIN;
---END---
---START---
SET LOCAL vacuum_cost_delay TO 50;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET LOCAL datestyle = 'SQL';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
COMMIT;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- SET should be reverted after ROLLBACK
BEGIN;
---END---
---START---
SET vacuum_cost_delay TO 60;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET datestyle = 'German';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- Some tests with subtransactions
BEGIN;
---END---
---START---
SET vacuum_cost_delay TO 70;
---END---
---START---
SET datestyle = 'MDY';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
SAVEPOINT first_sp;
---END---
---START---
SET vacuum_cost_delay TO 80.1;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET datestyle = 'German, DMY';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK TO first_sp;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
SAVEPOINT second_sp;
---END---
---START---
SET vacuum_cost_delay TO '900us';
---END---
---START---
SET datestyle = 'SQL, YMD';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
SAVEPOINT third_sp;
---END---
---START---
SET vacuum_cost_delay TO 100;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET datestyle = 'Postgres, MDY';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK TO third_sp;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK TO second_sp;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- SET LOCAL with Savepoints
BEGIN;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
SAVEPOINT sp;
---END---
---START---
SET LOCAL vacuum_cost_delay TO 30;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET LOCAL datestyle = 'Postgres, MDY';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK TO sp;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- SET LOCAL persists through RELEASE (which was not true in 8.0-8.2)
BEGIN;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
SAVEPOINT sp;
---END---
---START---
SET LOCAL vacuum_cost_delay TO 30;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET LOCAL datestyle = 'Postgres, MDY';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
RELEASE SAVEPOINT sp;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
ROLLBACK;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- SET followed by SET LOCAL
BEGIN;
---END---
---START---
SET vacuum_cost_delay TO 40;
---END---
---START---
SET LOCAL vacuum_cost_delay TO 50;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SET datestyle = 'ISO, DMY';
---END---
---START---
SET LOCAL datestyle = 'Postgres, MDY';
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
COMMIT;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

--
-- Test RESET.  We use datestyle because the reset value is forced by
-- pg_regress, so it doesn't depend on the installation's configuration.
--
SET datestyle = iso, ymd;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---
RESET datestyle;
---END---
---START---
SHOW datestyle;
---END---
---START---
SELECT '2006-08-13 12:34:56'::timestamptz;
---END---
---START---

-- Test some simple error cases
SET seq_page_cost TO 'NaN';
---END---
---START---
SET vacuum_cost_delay TO '10s';
---END---
---START---
SET no_such_variable TO 42;
---END---
---START---

-- Test "custom" GUCs created on the fly (which aren't really an
-- intended feature, but many people use them).
SHOW custom.my_guc;  -- error, not known yet
SET custom.my_guc = 42;
---END---
---START---
SHOW custom.my_guc;
---END---
---START---
RESET custom.my_guc;  -- this makes it go to empty, not become unknown again
SHOW custom.my_guc;
---END---
---START---
SET custom.my.qualified.guc = 'foo';
---END---
---START---
SHOW custom.my.qualified.guc;
---END---
---START---
SET custom."bad-guc" = 42;  -- disallowed because -c cannot set this name
SHOW custom."bad-guc";
---END---
---START---
SET special."weird name" = 'foo';  -- could be allowed, but we choose not to
SHOW special."weird name";
---END---
---START---

-- Check what happens when you try to set a "custom" GUC within the
-- namespace of an extension.
SET plpgsql.extra_foo_warnings = true;  -- allowed if plpgsql is not loaded yet
LOAD 'plpgsql';  -- this will throw a warning and delete the variable
SET plpgsql.extra_foo_warnings = true;  -- now, it's an error
SHOW plpgsql.extra_foo_warnings;
---END---
---START---

--
-- Test DISCARD TEMP
--
CREATE TABLE reset_test ( data text ) ON COMMIT DELETE ROWS;
---END---
---START---
SELECT relname FROM pg_class WHERE relname = 'reset_test';
---END---
---START---
DISCARD TEMP;
---END---
---START---
SELECT relname FROM pg_class WHERE relname = 'reset_test';
---END---
---START---
drop table reset_test;
---END---
---START---

--
-- Test DISCARD ALL
--

-- do changes
DECLARE foo CURSOR WITH HOLD FOR SELECT 1;
---END---
---START---
PREPARE foo AS SELECT 1;
---END---
---START---
LISTEN foo_event;
---END---
---START---
SET vacuum_cost_delay = 13;
---END---
---START---
CREATE TABLE tmp_foo (data text) ON COMMIT DELETE ROWS;
---END---
---START---
CREATE ROLE regress_guc_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_guc_user;
---END---
---START---
-- look changes
SELECT pg_listening_channels();
---END---
---START---
SELECT name FROM pg_prepared_statements;
---END---
---START---
SELECT name FROM pg_cursors;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SELECT relname from pg_class where relname = 'tmp_foo';
---END---
---START---
SELECT current_user = 'regress_guc_user';
---END---
---START---
-- discard everything
DISCARD ALL;
---END---
---START---
-- look again
SELECT pg_listening_channels();
---END---
---START---
SELECT name FROM pg_prepared_statements;
---END---
---START---
SELECT name FROM pg_cursors;
---END---
---START---
SHOW vacuum_cost_delay;
---END---
---START---
SELECT relname from pg_class where relname = 'tmp_foo';
---END---
---START---
SELECT current_user = 'regress_guc_user';
---END---
---START---
DROP ROLE regress_guc_user;
---END---
---START---

--
-- search_path should react to changes in pg_namespace
--

set search_path = foo, public, not_there_initially;
---END---
---START---
select current_schemas(false);
---END---
---START---
create schema not_there_initially;
---END---
---START---
select current_schemas(false);
---END---
---START---
drop schema not_there_initially;
---END---
---START---
select current_schemas(false);
---END---
---START---
reset search_path;
---END---
---START---

--
-- Tests for function-local GUC settings
--

set work_mem = '3MB';
---END---
---START---

create function report_guc(text) returns text as
$$ select current_setting($1) $$ language sql
set work_mem = '1MB';
---END---
---START---

select report_guc('work_mem'), current_setting('work_mem');
---END---
---START---

alter function report_guc(text) set work_mem = '2MB';
---END---
---START---

select report_guc('work_mem'), current_setting('work_mem');
---END---
---START---

alter function report_guc(text) reset all;
---END---
---START---

select report_guc('work_mem'), current_setting('work_mem');
---END---
---START---

-- SET LOCAL is restricted by a function SET option
create or replace function myfunc(int) returns text as $$
begin
  set local work_mem = '2MB';
---END---
---START---
  return current_setting('work_mem');
---END---
---START---
end $$
language plpgsql
set work_mem = '1MB';
---END---
---START---

select myfunc(0), current_setting('work_mem');
---END---
---START---

alter function myfunc(int) reset all;
---END---
---START---

select myfunc(0), current_setting('work_mem');
---END---
---START---

set work_mem = '3MB';
---END---
---START---

-- but SET isn't
create or replace function myfunc(int) returns text as $$
begin
  set work_mem = '2MB';
---END---
---START---
  return current_setting('work_mem');
---END---
---START---
end $$
language plpgsql
set work_mem = '1MB';
---END---
---START---

select myfunc(0), current_setting('work_mem');
---END---
---START---

set work_mem = '3MB';
---END---
---START---

-- it should roll back on error, though
create or replace function myfunc(int) returns text as $$
begin
  set work_mem = '2MB';
---END---
---START---
  perform 1/$1;
---END---
---START---
  return current_setting('work_mem');
---END---
---START---
end $$
language plpgsql
set work_mem = '1MB';
---END---
---START---

select myfunc(0);
---END---
---START---
select current_setting('work_mem');
---END---
---START---
select myfunc(1), current_setting('work_mem');
---END---
---START---

-- check current_setting()'s behavior with invalid setting name

select current_setting('nosuch.setting');  -- FAIL
select current_setting('nosuch.setting', false);  -- FAIL
select current_setting('nosuch.setting', true) is null;
---END---
---START---

-- after this, all three cases should yield 'nada'
set nosuch.setting = 'nada';
---END---
---START---

select current_setting('nosuch.setting');
---END---
---START---
select current_setting('nosuch.setting', false);
---END---
---START---
select current_setting('nosuch.setting', true);
---END---
---START---

-- Normally, CREATE FUNCTION should complain about invalid values in
-- function SET options; but not if check_function_bodies is off,
-- because that creates ordering hazards for pg_dump

create function func_with_bad_set() returns int as $$ select 1 $$
language sql
set default_text_search_config = no_such_config;
---END---
---START---

set check_function_bodies = off;
---END---
---START---

create function func_with_bad_set() returns int as $$ select 1 $$
language sql
set default_text_search_config = no_such_config;
---END---
---START---

select func_with_bad_set();
---END---
---START---

reset check_function_bodies;
---END---
---START---

set default_with_oids to f;
---END---
---START---
-- Should not allow to set it to true.
set default_with_oids to t;
---END---
---START---

-- Test GUC categories and flag patterns
SELECT pg_settings_get_flags(NULL);
---END---
---START---
SELECT pg_settings_get_flags('does_not_exist');
---END---
---START---
CREATE TABLE tab_settings_flags AS SELECT name, category,
    'EXPLAIN'          = ANY(flags) AS explain,
    'NO_RESET'         = ANY(flags) AS no_reset,
    'NO_RESET_ALL'     = ANY(flags) AS no_reset_all,
    'NOT_IN_SAMPLE'    = ANY(flags) AS not_in_sample,
    'RUNTIME_COMPUTED' = ANY(flags) AS runtime_computed
  FROM pg_show_all_settings() AS psas,
    pg_settings_get_flags(psas.name) AS flags;
---END---
---START---

-- Developer GUCs should be flagged with GUC_NOT_IN_SAMPLE:
SELECT name FROM tab_settings_flags
  WHERE category = 'Developer Options' AND NOT not_in_sample
  ORDER BY 1;
---END---
---START---
-- Most query-tuning GUCs are flagged as valid for EXPLAIN.
-- default_statistics_target is an exception.
SELECT name FROM tab_settings_flags
  WHERE category ~ '^Query Tuning' AND NOT explain
  ORDER BY 1;
---END---
---START---
-- Runtime-computed GUCs should be part of the preset category.
SELECT name FROM tab_settings_flags
  WHERE NOT category = 'Preset Options' AND runtime_computed
  ORDER BY 1;
---END---
---START---
-- Preset GUCs are flagged as NOT_IN_SAMPLE.
SELECT name FROM tab_settings_flags
  WHERE category = 'Preset Options' AND NOT not_in_sample
  ORDER BY 1;
---END---
---START---
-- NO_RESET implies NO_RESET_ALL.
SELECT name FROM tab_settings_flags
  WHERE no_reset AND NOT no_reset_all
  ORDER BY 1;
---END---
---START---
DROP TABLE tab_settings_flags;
drop table tmp_foo;
---END---
