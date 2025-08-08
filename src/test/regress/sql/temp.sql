---START---
CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, col integer);
---END---
---START---
CREATE INDEX i_temptest ON temptest(col);
---END---
---START---
DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, tcol integer);
---END---
---START---
CREATE INDEX i_temptest ON temptest(tcol);
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
DROP INDEX i_temptest;
---END---
---START---
DROP TABLE temptest;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
DROP INDEX i_temptest;
---END---
---START---
DROP TABLE temptest;
---END---
---START---
CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, col integer);
---END---
---START---
INSERT INTO temptest VALUES (1);
---END---
---START---
DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, tcol double precision);
---END---
---START---
INSERT INTO temptest VALUES (2.1);
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
DROP TABLE temptest;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
DROP TABLE temptest;
---END---
---START---
-- test temp table deletion

DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, col integer);
---END---
---START---
\c

SELECT * FROM temptest;
---END---
---START---
-- Test ON COMMIT DELETE ROWS

DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, col integer) ON COMMIT DELETE ROWS;
---END---
---START---
-- while we're here, verify successful truncation of index with SQL function
CREATE INDEX ON temptest(bit_length(''));
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO temptest VALUES (1);
---END---
---START---
INSERT INTO temptest VALUES (2);
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
DROP TABLE temptest;
---END---
---START---
BEGIN;
---END---
---START---
DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest(col) ON COMMIT DELETE ROWS AS SELECT 1;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
DROP TABLE temptest;
---END---
---START---
-- Test ON COMMIT DROP

BEGIN;
---END---
---START---
DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, col integer) ON COMMIT DROP;
---END---
---START---
INSERT INTO temptest VALUES (1);
---END---
---START---
INSERT INTO temptest VALUES (2);
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
BEGIN;
---END---
---START---
DROP TABLE IF EXISTS temptest;

CREATE TABLE temptest(col) ON COMMIT DROP AS SELECT 1;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM temptest;
---END---
---START---
CREATE TABLE temptest (gemini_pk serial PRIMARY KEY, col integer) ON COMMIT DELETE ROWS;
---END---
---START---
CREATE TABLE temptest(col) ON COMMIT DELETE ROWS AS SELECT 1;
---END---
---START---
-- Test foreign keys
BEGIN;
---END---
---START---
DROP TABLE IF EXISTS temptest1;

CREATE TABLE temptest1(col int PRIMARY KEY);
---END---
---START---
DROP TABLE IF EXISTS temptest2;

CREATE TABLE temptest2 (gemini_pk serial PRIMARY KEY, col integer REFERENCES temptest1) ON COMMIT DELETE ROWS;
---END---
---START---
INSERT INTO temptest1 VALUES (1);
---END---
---START---
INSERT INTO temptest2 VALUES (1);
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM temptest1;
---END---
---START---
SELECT * FROM temptest2;
---END---
---START---
BEGIN;
---END---
---START---
DROP TABLE IF EXISTS temptest3;

CREATE TABLE temptest3(col int PRIMARY KEY) ON COMMIT DELETE ROWS;
---END---
---START---
DROP TABLE IF EXISTS temptest4;

CREATE TABLE temptest4 (gemini_pk serial PRIMARY KEY, col integer REFERENCES temptest3);
---END---
---START---
COMMIT;
---END---
---START---
CREATE TABLE public.whereami (gemini_pk serial PRIMARY KEY, f1 text);
---END---
---START---
insert into public.whereami values ('public');
---END---
---START---
DROP TABLE IF EXISTS whereami;

CREATE TABLE whereami (gemini_pk serial PRIMARY KEY, f1 text);
---END---
---START---
insert into whereami values ('temp');
---END---
---START---
create function public.whoami() returns text
  as $$select 'public'::text$$ language sql;
---END---
---START---
create function pg_temp.whoami() returns text
  as $$select 'temp'::text$$ language sql;
---END---
---START---
-- default should have pg_temp implicitly first, but only for tables
select * from whereami;
---END---
---START---
select whoami();
---END---
---START---
-- can list temp first explicitly, but it still doesn't affect functions
set search_path = pg_temp, public;
---END---
---START---
select * from whereami;
---END---
---START---
select whoami();
---END---
---START---
-- or put it last for security
set search_path = public, pg_temp;
---END---
---START---
select * from whereami;
---END---
---START---
select whoami();
---END---
---START---
-- you can invoke a temp function explicitly, though
select pg_temp.whoami();
---END---
---START---
drop table public.whereami;
---END---
---START---
-- types in temp schema
set search_path = pg_temp, public;
---END---
---START---
create domain pg_temp.nonempty as text check (value <> '');
---END---
---START---
-- function-syntax invocation of types matches rules for functions
select nonempty('');
---END---
---START---
select pg_temp.nonempty('');
---END---
---START---
-- other syntax matches rules for tables
select ''::nonempty;
---END---
---START---
reset search_path;
---END---
---START---
-- For partitioned temp tables, ON COMMIT actions ignore storage-less
-- partitioned tables.
begin;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit;

CREATE TABLE temp_parted_oncommit (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY list (a) ON COMMIT DELETE ROWS;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_1;

create table temp_parted_oncommit_1
  partition of temp_parted_oncommit
  for values in (1) on commit delete rows;
---END---
---START---
insert into temp_parted_oncommit values (1);
---END---
---START---
commit;
---END---
---START---
-- partitions are emptied by the previous commit
select * from temp_parted_oncommit;
---END---
---START---
drop table temp_parted_oncommit;
---END---
---START---
-- Check dependencies between ON COMMIT actions with a partitioned
-- table and its partitions.  Using ON COMMIT DROP on a parent removes
-- the whole set.
begin;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_test;

CREATE TABLE temp_parted_oncommit_test (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY list (a) ON COMMIT DROP;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_test1;

create table temp_parted_oncommit_test1
  partition of temp_parted_oncommit_test
  for values in (1) on commit delete rows;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_test2;

create table temp_parted_oncommit_test2
  partition of temp_parted_oncommit_test
  for values in (2) on commit drop;
---END---
---START---
insert into temp_parted_oncommit_test values (1), (2);
---END---
---START---
commit;
---END---
---START---
-- no relations remain in this case.
select relname from pg_class where relname ~ '^temp_parted_oncommit_test';
---END---
---START---
-- Using ON COMMIT DELETE on a partitioned table does not remove
-- all rows if partitions preserve their data.
begin;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_test;

CREATE TABLE temp_parted_oncommit_test (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY list (a) ON COMMIT DELETE ROWS;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_test1;

create table temp_parted_oncommit_test1
  partition of temp_parted_oncommit_test
  for values in (1) on commit preserve rows;
---END---
---START---
DROP TABLE IF EXISTS temp_parted_oncommit_test2;

create table temp_parted_oncommit_test2
  partition of temp_parted_oncommit_test
  for values in (2) on commit drop;
---END---
---START---
insert into temp_parted_oncommit_test values (1), (2);
---END---
---START---
commit;
---END---
---START---
-- Data from the remaining partition is still here as its rows are
-- preserved.
select * from temp_parted_oncommit_test;
---END---
---START---
-- two relations remain in this case.
select relname from pg_class where relname ~ '^temp_parted_oncommit_test'
  order by relname;
---END---
---START---
drop table temp_parted_oncommit_test;
---END---
---START---
-- Check dependencies between ON COMMIT actions with inheritance trees.
-- Using ON COMMIT DROP on a parent removes the whole set.
begin;
---END---
---START---
DROP TABLE IF EXISTS temp_inh_oncommit_test;

CREATE TABLE temp_inh_oncommit_test (gemini_pk serial PRIMARY KEY, a integer) ON COMMIT DROP;
---END---
---START---
DROP TABLE IF EXISTS temp_inh_oncommit_test1;

CREATE TABLE temp_inh_oncommit_test1 (gemini_pk serial PRIMARY KEY) INHERITS (temp_inh_oncommit_test) ON COMMIT DELETE ROWS;
---END---
---START---
insert into temp_inh_oncommit_test1 values (1);
---END---
---START---
commit;
---END---
---START---
-- no relations remain in this case
select relname from pg_class where relname ~ '^temp_inh_oncommit_test';
---END---
---START---
-- Data on the parent is removed, and the child goes away.
begin;
---END---
---START---
DROP TABLE IF EXISTS temp_inh_oncommit_test;

CREATE TABLE temp_inh_oncommit_test (gemini_pk serial PRIMARY KEY, a integer) ON COMMIT DELETE ROWS;
---END---
---START---
DROP TABLE IF EXISTS temp_inh_oncommit_test1;

CREATE TABLE temp_inh_oncommit_test1 (gemini_pk serial PRIMARY KEY) INHERITS (temp_inh_oncommit_test) ON COMMIT DROP;
---END---
---START---
insert into temp_inh_oncommit_test1 values (1);
---END---
---START---
insert into temp_inh_oncommit_test values (1);
---END---
---START---
commit;
---END---
---START---
select * from temp_inh_oncommit_test;
---END---
---START---
-- one relation remains
select relname from pg_class where relname ~ '^temp_inh_oncommit_test';
---END---
---START---
drop table temp_inh_oncommit_test;
---END---
---START---
-- Tests with two-phase commit
-- Transactions creating objects in a temporary namespace cannot be used
-- with two-phase commit.

-- These cases generate errors about temporary namespace.
-- Function creation
begin;
---END---
---START---
create function pg_temp.twophase_func() returns void as
  $$ select '2pc_func'::text $$ language sql;
---END---
---START---
prepare transaction 'twophase_func';
---END---
---START---
-- Function drop
create function pg_temp.twophase_func() returns void as
  $$ select '2pc_func'::text $$ language sql;
---END---
---START---
begin;
---END---
---START---
drop function pg_temp.twophase_func();
---END---
---START---
prepare transaction 'twophase_func';
---END---
---START---
-- Operator creation
begin;
---END---
---START---
create operator pg_temp.@@ (leftarg = int4, rightarg = int4, procedure = int4mi);
---END---
---START---
prepare transaction 'twophase_operator';
---END---
---START---
-- These generate errors about temporary tables.
begin;
---END---
---START---
create type pg_temp.twophase_type as (a int);
---END---
---START---
prepare transaction 'twophase_type';
---END---
---START---
begin;
---END---
---START---
create view pg_temp.twophase_view as select 1;
---END---
---START---
prepare transaction 'twophase_view';
---END---
---START---
begin;
---END---
---START---
create sequence pg_temp.twophase_seq;
---END---
---START---
prepare transaction 'twophase_sequence';
---END---
---START---
-- Temporary tables cannot be used with two-phase commit.
DROP TABLE IF EXISTS twophase_tab;

CREATE TABLE twophase_tab (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
begin;
---END---
---START---
select a from twophase_tab;
---END---
---START---
prepare transaction 'twophase_tab';
---END---
---START---
begin;
---END---
---START---
insert into twophase_tab values (1);
---END---
---START---
prepare transaction 'twophase_tab';
---END---
---START---
begin;
---END---
---START---
lock twophase_tab in access exclusive mode;
---END---
---START---
prepare transaction 'twophase_tab';
---END---
---START---
begin;
---END---
---START---
drop table twophase_tab;
---END---
---START---
prepare transaction 'twophase_tab';
---END---
---START---
-- Corner case: current_schema may create a temporary schema if namespace
-- creation is pending, so check after that.  First reset the connection
-- to remove the temporary namespace.
\c -
SET search_path TO 'pg_temp';
---END---
---START---
BEGIN;
---END---
---START---
SELECT current_schema() ~ 'pg_temp' AS is_temp_schema;
---END---
---START---
PREPARE TRANSACTION 'twophase_search';
---END---
