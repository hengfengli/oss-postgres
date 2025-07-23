---START---
--
-- TRANSACTIONS
--

BEGIN;
---END---
---START---

CREATE TABLE xacttest (a smallint, b real);
---END---
---START---
INSERT INTO xacttest VALUES
  (56, 7.8),
  (100, 99.097),
  (0, 0.09561),
  (42, 324.78);
---END---
---START---
INSERT INTO xacttest (a, b) VALUES (777, 777.777);
---END---
---START---

END;
---END---
---START---

-- should retrieve one value--
SELECT a FROM xacttest WHERE a > 100;
---END---
---START---


BEGIN;
---END---
---START---

CREATE TABLE disappear (a int4);
---END---
---START---

DELETE FROM xacttest;
---END---
---START---

-- should be empty
SELECT * FROM xacttest;
---END---
---START---

ABORT;
---END---
---START---

-- should not exist
SELECT oid FROM pg_class WHERE relname = 'disappear';
---END---
---START---

-- should have members again
SELECT * FROM xacttest;
---END---
---START---

-- Test that transaction characteristics cannot be reset.
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
SELECT COUNT(*) FROM xacttest;
---END---
---START---
RESET transaction_isolation; -- error
END;
---END---
---START---

BEGIN TRANSACTION READ ONLY;
---END---
---START---
SELECT COUNT(*) FROM xacttest;
---END---
---START---
RESET transaction_read_only; -- error
END;
---END---
---START---

BEGIN TRANSACTION DEFERRABLE;
---END---
---START---
SELECT COUNT(*) FROM xacttest;
---END---
---START---
RESET transaction_deferrable; -- error
END;
---END---
---START---

CREATE FUNCTION errfunc() RETURNS int LANGUAGE SQL AS 'SELECT 1'
SET transaction_read_only = on; -- error

-- Read-only tests

CREATE TABLE writetest (a int);
---END---
---START---
CREATE TEMPORARY TABLE temptest (a int);
---END---
---START---

BEGIN;
---END---
---START---
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE, READ ONLY, DEFERRABLE; -- ok
SELECT * FROM writetest; -- ok
SET TRANSACTION READ WRITE; --fail
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
SET TRANSACTION READ ONLY; -- ok
SET TRANSACTION READ WRITE; -- ok
SET TRANSACTION READ ONLY; -- ok
SELECT * FROM writetest; -- ok
SAVEPOINT x;
---END---
---START---
SET TRANSACTION READ ONLY; -- ok
SELECT * FROM writetest; -- ok
SET TRANSACTION READ ONLY; -- ok
SET TRANSACTION READ WRITE; --fail
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
SET TRANSACTION READ WRITE; -- ok
SAVEPOINT x;
---END---
---START---
SET TRANSACTION READ WRITE; -- ok
SET TRANSACTION READ ONLY; -- ok
SELECT * FROM writetest; -- ok
SET TRANSACTION READ ONLY; -- ok
SET TRANSACTION READ WRITE; --fail
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
SET TRANSACTION READ WRITE; -- ok
SAVEPOINT x;
---END---
---START---
SET TRANSACTION READ ONLY; -- ok
SELECT * FROM writetest; -- ok
ROLLBACK TO SAVEPOINT x;
---END---
---START---
SHOW transaction_read_only;  -- off
SAVEPOINT y;
---END---
---START---
SET TRANSACTION READ ONLY; -- ok
SELECT * FROM writetest; -- ok
RELEASE SAVEPOINT y;
---END---
---START---
SHOW transaction_read_only;  -- off
COMMIT;
---END---
---START---

SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY;
---END---
---START---

DROP TABLE writetest; -- fail
INSERT INTO writetest VALUES (1); -- fail
SELECT * FROM writetest; -- ok
DELETE FROM temptest; -- ok
UPDATE temptest SET a = 0 FROM writetest WHERE temptest.a = 1 AND writetest.a = temptest.a; -- ok
PREPARE test AS UPDATE writetest SET a = 0; -- ok
EXECUTE test; -- fail
SELECT * FROM writetest, temptest; -- ok
CREATE TABLE test AS SELECT * FROM writetest; -- fail

START TRANSACTION READ WRITE;
---END---
---START---
DROP TABLE writetest; -- ok
COMMIT;
---END---
---START---

-- Subtransactions, basic tests
-- create & drop tables
SET SESSION CHARACTERISTICS AS TRANSACTION READ WRITE;
---END---
---START---
CREATE TABLE trans_foobar (a int);
---END---
---START---
BEGIN;
---END---
---START---
	CREATE TABLE trans_foo (a int);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		DROP TABLE trans_foo;
---END---
---START---
		CREATE TABLE trans_bar (a int);
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
	RELEASE SAVEPOINT one;
---END---
---START---
	SAVEPOINT two;
---END---
---START---
		CREATE TABLE trans_baz (a int);
---END---
---START---
	RELEASE SAVEPOINT two;
---END---
---START---
	drop TABLE trans_foobar;
---END---
---START---
	CREATE TABLE trans_barbaz (a int);
---END---
---START---
COMMIT;
---END---
---START---
-- should exist: trans_barbaz, trans_baz, trans_foo
SELECT * FROM trans_foo;		-- should be empty
SELECT * FROM trans_bar;		-- shouldn't exist
SELECT * FROM trans_barbaz;	-- should be empty
SELECT * FROM trans_baz;		-- should be empty

-- inserts
BEGIN;
---END---
---START---
	INSERT INTO trans_foo VALUES (1);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		INSERT into trans_bar VALUES (1);
---END---
---START---
	ROLLBACK TO one;
---END---
---START---
	RELEASE SAVEPOINT one;
---END---
---START---
	SAVEPOINT two;
---END---
---START---
		INSERT into trans_barbaz VALUES (1);
---END---
---START---
	RELEASE two;
---END---
---START---
	SAVEPOINT three;
---END---
---START---
		SAVEPOINT four;
---END---
---START---
			INSERT INTO trans_foo VALUES (2);
---END---
---START---
		RELEASE SAVEPOINT four;
---END---
---START---
	ROLLBACK TO SAVEPOINT three;
---END---
---START---
	RELEASE SAVEPOINT three;
---END---
---START---
	INSERT INTO trans_foo VALUES (3);
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM trans_foo;		-- should have 1 and 3
SELECT * FROM trans_barbaz;	-- should have 1

-- test whole-tree commit
BEGIN;
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		SELECT trans_foo;
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
	RELEASE SAVEPOINT one;
---END---
---START---
	SAVEPOINT two;
---END---
---START---
		CREATE TABLE savepoints (a int);
---END---
---START---
		SAVEPOINT three;
---END---
---START---
			INSERT INTO savepoints VALUES (1);
---END---
---START---
			SAVEPOINT four;
---END---
---START---
				INSERT INTO savepoints VALUES (2);
---END---
---START---
				SAVEPOINT five;
---END---
---START---
					INSERT INTO savepoints VALUES (3);
---END---
---START---
				ROLLBACK TO SAVEPOINT five;
---END---
---START---
COMMIT;
---END---
---START---
COMMIT;		-- should not be in a transaction block
SELECT * FROM savepoints;
---END---
---START---

-- test whole-tree rollback
BEGIN;
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		DELETE FROM savepoints WHERE a=1;
---END---
---START---
	RELEASE SAVEPOINT one;
---END---
---START---
	SAVEPOINT two;
---END---
---START---
		DELETE FROM savepoints WHERE a=1;
---END---
---START---
		SAVEPOINT three;
---END---
---START---
			DELETE FROM savepoints WHERE a=2;
---END---
---START---
ROLLBACK;
---END---
---START---
COMMIT;		-- should not be in a transaction block

SELECT * FROM savepoints;
---END---
---START---

-- test whole-tree commit on an aborted subtransaction
BEGIN;
---END---
---START---
	INSERT INTO savepoints VALUES (4);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (5);
---END---
---START---
		SELECT trans_foo;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM savepoints;
---END---
---START---

BEGIN;
---END---
---START---
	INSERT INTO savepoints VALUES (6);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (7);
---END---
---START---
	RELEASE SAVEPOINT one;
---END---
---START---
	INSERT INTO savepoints VALUES (8);
---END---
---START---
COMMIT;
---END---
---START---
-- rows 6 and 8 should have been created by the same xact
SELECT a.xmin = b.xmin FROM savepoints a, savepoints b WHERE a.a=6 AND b.a=8;
---END---
---START---
-- rows 6 and 7 should have been created by different xacts
SELECT a.xmin = b.xmin FROM savepoints a, savepoints b WHERE a.a=6 AND b.a=7;
---END---
---START---

BEGIN;
---END---
---START---
	INSERT INTO savepoints VALUES (9);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (10);
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (11);
---END---
---START---
COMMIT;
---END---
---START---
SELECT a FROM savepoints WHERE a in (9, 10, 11);
---END---
---START---
-- rows 9 and 11 should have been created by different xacts
SELECT a.xmin = b.xmin FROM savepoints a, savepoints b WHERE a.a=9 AND b.a=11;
---END---
---START---

BEGIN;
---END---
---START---
	INSERT INTO savepoints VALUES (12);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (13);
---END---
---START---
		SAVEPOINT two;
---END---
---START---
			INSERT INTO savepoints VALUES (14);
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (15);
---END---
---START---
		SAVEPOINT two;
---END---
---START---
			INSERT INTO savepoints VALUES (16);
---END---
---START---
			SAVEPOINT three;
---END---
---START---
				INSERT INTO savepoints VALUES (17);
---END---
---START---
COMMIT;
---END---
---START---
SELECT a FROM savepoints WHERE a BETWEEN 12 AND 17;
---END---
---START---

BEGIN;
---END---
---START---
	INSERT INTO savepoints VALUES (18);
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (19);
---END---
---START---
		SAVEPOINT two;
---END---
---START---
			INSERT INTO savepoints VALUES (20);
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (21);
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
		INSERT INTO savepoints VALUES (22);
---END---
---START---
COMMIT;
---END---
---START---
SELECT a FROM savepoints WHERE a BETWEEN 18 AND 22;
---END---
---START---

DROP TABLE savepoints;
---END---
---START---

-- only in a transaction block:
SAVEPOINT one;
---END---
---START---
ROLLBACK TO SAVEPOINT one;
---END---
---START---
RELEASE SAVEPOINT one;
---END---
---START---

-- Only "rollback to" allowed in aborted state
BEGIN;
---END---
---START---
  SAVEPOINT one;
---END---
---START---
  SELECT 0/0;
---END---
---START---
  SAVEPOINT two;    -- ignored till the end of ...
  RELEASE SAVEPOINT one;      -- ignored till the end of ...
  ROLLBACK TO SAVEPOINT one;
---END---
---START---
  SELECT 1;
---END---
---START---
COMMIT;
---END---
---START---
SELECT 1;			-- this should work

-- check non-transactional behavior of cursors
BEGIN;
---END---
---START---
	DECLARE c CURSOR FOR SELECT unique2 FROM tenk1 ORDER BY unique2;
---END---
---START---
	SAVEPOINT one;
---END---
---START---
		FETCH 10 FROM c;
---END---
---START---
	ROLLBACK TO SAVEPOINT one;
---END---
---START---
		FETCH 10 FROM c;
---END---
---START---
	RELEASE SAVEPOINT one;
---END---
---START---
	FETCH 10 FROM c;
---END---
---START---
	CLOSE c;
---END---
---START---
	DECLARE c CURSOR FOR SELECT unique2/0 FROM tenk1 ORDER BY unique2;
---END---
---START---
	SAVEPOINT two;
---END---
---START---
		FETCH 10 FROM c;
---END---
---START---
	ROLLBACK TO SAVEPOINT two;
---END---
---START---
	-- c is now dead to the world ...
		FETCH 10 FROM c;
---END---
---START---
	ROLLBACK TO SAVEPOINT two;
---END---
---START---
	RELEASE SAVEPOINT two;
---END---
---START---
	FETCH 10 FROM c;
---END---
---START---
COMMIT;
---END---
---START---

--
-- Check that "stable" functions are really stable.  They should not be
-- able to see the partial results of the calling query.  (Ideally we would
-- also check that they don't see commits of concurrent transactions, but
-- that's a mite hard to do within the limitations of pg_regress.)
--
select * from xacttest;
---END---
---START---

create or replace function max_xacttest() returns smallint language sql as
'select max(a) from xacttest' stable;
---END---
---START---

begin;
---END---
---START---
update xacttest set a = max_xacttest() + 10 where a > 0;
---END---
---START---
select * from xacttest;
---END---
---START---
rollback;
---END---
---START---

-- But a volatile function can see the partial results of the calling query
create or replace function max_xacttest() returns smallint language sql as
'select max(a) from xacttest' volatile;
---END---
---START---

begin;
---END---
---START---
update xacttest set a = max_xacttest() + 10 where a > 0;
---END---
---START---
select * from xacttest;
---END---
---START---
rollback;
---END---
---START---

-- Now the same test with plpgsql (since it depends on SPI which is different)
create or replace function max_xacttest() returns smallint language plpgsql as
'begin return max(a) from xacttest; end' stable;
---END---
---START---

begin;
---END---
---START---
update xacttest set a = max_xacttest() + 10 where a > 0;
---END---
---START---
select * from xacttest;
---END---
---START---
rollback;
---END---
---START---

create or replace function max_xacttest() returns smallint language plpgsql as
'begin return max(a) from xacttest; end' volatile;
---END---
---START---

begin;
---END---
---START---
update xacttest set a = max_xacttest() + 10 where a > 0;
---END---
---START---
select * from xacttest;
---END---
---START---
rollback;
---END---
---START---


-- test case for problems with dropping an open relation during abort
BEGIN;
---END---
---START---
	savepoint x;
---END---
---START---
		CREATE TABLE koju (a INT UNIQUE);
---END---
---START---
		INSERT INTO koju VALUES (1);
---END---
---START---
		INSERT INTO koju VALUES (1);
---END---
---START---
	rollback to x;
---END---
---START---

	CREATE TABLE koju (a INT UNIQUE);
---END---
---START---
	INSERT INTO koju VALUES (1);
---END---
---START---
	INSERT INTO koju VALUES (1);
---END---
---START---
ROLLBACK;
---END---
---START---

DROP TABLE trans_foo;
---END---
---START---
DROP TABLE trans_baz;
---END---
---START---
DROP TABLE trans_barbaz;
---END---
---START---


-- test case for problems with revalidating an open relation during abort
create function inverse(int) returns float8 as
$$
begin
  analyze revalidate_bug;
---END---
---START---
  return 1::float8/$1;
---END---
---START---
exception
  when division_by_zero then return 0;
---END---
---START---
end$$ language plpgsql volatile;
---END---
---START---

create table revalidate_bug (c float8 unique);
---END---
---START---
insert into revalidate_bug values (1);
---END---
---START---
insert into revalidate_bug values (inverse(0));
---END---
---START---

drop table revalidate_bug;
---END---
---START---
drop function inverse(int);
---END---
---START---


-- verify that cursors created during an aborted subtransaction are
-- closed, but that we do not rollback the effect of any FETCHs
-- performed in the aborted subtransaction
begin;
---END---
---START---

savepoint x;
---END---
---START---
create table trans_abc (a int);
---END---
---START---
insert into trans_abc values (5);
---END---
---START---
insert into trans_abc values (10);
---END---
---START---
declare foo cursor for select * from trans_abc;
---END---
---START---
fetch from foo;
---END---
---START---
rollback to x;
---END---
---START---

-- should fail
fetch from foo;
---END---
---START---
commit;
---END---
---START---

begin;
---END---
---START---

create table trans_abc (a int);
---END---
---START---
insert into trans_abc values (5);
---END---
---START---
insert into trans_abc values (10);
---END---
---START---
insert into trans_abc values (15);
---END---
---START---
declare foo cursor for select * from trans_abc;
---END---
---START---

fetch from foo;
---END---
---START---

savepoint x;
---END---
---START---
fetch from foo;
---END---
---START---
rollback to x;
---END---
---START---

fetch from foo;
---END---
---START---

abort;
---END---
---START---


-- Test for proper cleanup after a failure in a cursor portal
-- that was created in an outer subtransaction
CREATE FUNCTION invert(x float8) RETURNS float8 LANGUAGE plpgsql AS
$$ begin return 1/x; end $$;
---END---
---START---

CREATE FUNCTION create_temp_tab() RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  CREATE TEMP TABLE new_table (f1 float8);
---END---
---START---
  -- case of interest is that we fail while holding an open
  -- relcache reference to new_table
  INSERT INTO new_table SELECT invert(0.0);
---END---
---START---
  RETURN 'foo';
---END---
---START---
END $$;
---END---
---START---

BEGIN;
---END---
---START---
DECLARE ok CURSOR FOR SELECT * FROM int8_tbl;
---END---
---START---
DECLARE ctt CURSOR FOR SELECT create_temp_tab();
---END---
---START---
FETCH ok;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
FETCH ok;  -- should work
FETCH ctt; -- error occurs here
ROLLBACK TO s1;
---END---
---START---
FETCH ok;  -- should work
FETCH ctt; -- must be rejected
COMMIT;
---END---
---START---

DROP FUNCTION create_temp_tab();
---END---
---START---
DROP FUNCTION invert(x float8);
---END---
---START---


-- Tests for AND CHAIN

CREATE TABLE trans_abc (a int);
---END---
---START---

-- set nondefault value so we have something to override below
SET default_transaction_read_only = on;
---END---
---START---

START TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ WRITE, DEFERRABLE;
---END---
---START---
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
INSERT INTO trans_abc VALUES (1);
---END---
---START---
INSERT INTO trans_abc VALUES (2);
---END---
---START---
COMMIT AND CHAIN;  -- TBLOCK_END
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
INSERT INTO trans_abc VALUES ('error');
---END---
---START---
INSERT INTO trans_abc VALUES (3);  -- check it's really aborted
COMMIT AND CHAIN;  -- TBLOCK_ABORT_END
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
INSERT INTO trans_abc VALUES (4);
---END---
---START---
COMMIT;
---END---
---START---

START TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ WRITE, DEFERRABLE;
---END---
---START---
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
SAVEPOINT x;
---END---
---START---
INSERT INTO trans_abc VALUES ('error');
---END---
---START---
COMMIT AND CHAIN;  -- TBLOCK_ABORT_PENDING
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
INSERT INTO trans_abc VALUES (5);
---END---
---START---
COMMIT;
---END---
---START---

START TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ WRITE, DEFERRABLE;
---END---
---START---
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
SAVEPOINT x;
---END---
---START---
COMMIT AND CHAIN;  -- TBLOCK_SUBCOMMIT
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
COMMIT;
---END---
---START---

-- different mix of options just for fun
START TRANSACTION ISOLATION LEVEL SERIALIZABLE, READ WRITE, NOT DEFERRABLE;
---END---
---START---
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
INSERT INTO trans_abc VALUES (6);
---END---
---START---
ROLLBACK AND CHAIN;  -- TBLOCK_ABORT_PENDING
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
INSERT INTO trans_abc VALUES ('error');
---END---
---START---
ROLLBACK AND CHAIN;  -- TBLOCK_ABORT_END
SHOW transaction_isolation;
---END---
---START---
SHOW transaction_read_only;
---END---
---START---
SHOW transaction_deferrable;
---END---
---START---
ROLLBACK;
---END---
---START---

-- not allowed outside a transaction block
COMMIT AND CHAIN;  -- error
ROLLBACK AND CHAIN;  -- error

SELECT * FROM trans_abc ORDER BY 1;
---END---
---START---

RESET default_transaction_read_only;
---END---
---START---

DROP TABLE trans_abc;
---END---
---START---


-- Test assorted behaviors around the implicit transaction block created
-- when multiple SQL commands are sent in a single Query message.  These
-- tests rely on the fact that psql will not break SQL commands apart at a
-- backslash-quoted semicolon, but will send them as one Query.

create temp table i_table (f1 int);
---END---
---START---

-- psql will show all results of a multi-statement Query
SELECT 1\; SELECT 2\; SELECT 3;
---END---
---START---

-- this implicitly commits:
insert into i_table values(1)\; select * from i_table;
---END---
---START---
-- 1/0 error will cause rolling back the whole implicit transaction
insert into i_table values(2)\; select * from i_table\; select 1/0;
---END---
---START---
select * from i_table;
---END---
---START---

rollback;  -- we are not in a transaction at this point

-- can use regular begin/commit/rollback within a single Query
begin\; insert into i_table values(3)\; commit;
---END---
---START---
rollback;  -- we are not in a transaction at this point
begin\; insert into i_table values(4)\; rollback;
---END---
---START---
rollback;  -- we are not in a transaction at this point

-- begin converts implicit transaction into a regular one that
-- can extend past the end of the Query
select 1\; begin\; insert into i_table values(5);
---END---
---START---
commit;
---END---
---START---
select 1\; begin\; insert into i_table values(6);
---END---
---START---
rollback;
---END---
---START---

-- commit in implicit-transaction state commits but issues a warning.
insert into i_table values(7)\; commit\; insert into i_table values(8)\; select 1/0;
---END---
---START---
-- similarly, rollback aborts but issues a warning.
insert into i_table values(9)\; rollback\; select 2;
---END---
---START---

select * from i_table;
---END---
---START---

rollback;  -- we are not in a transaction at this point

-- implicit transaction block is still a transaction block, for e.g. VACUUM
SELECT 1\; VACUUM;
---END---
---START---
SELECT 1\; COMMIT\; VACUUM;
---END---
---START---

-- we disallow savepoint-related commands in implicit-transaction state
SELECT 1\; SAVEPOINT sp;
---END---
---START---
SELECT 1\; COMMIT\; SAVEPOINT sp;
---END---
---START---
ROLLBACK TO SAVEPOINT sp\; SELECT 2;
---END---
---START---
SELECT 2\; RELEASE SAVEPOINT sp\; SELECT 3;
---END---
---START---

-- but this is OK, because the BEGIN converts it to a regular xact
SELECT 1\; BEGIN\; SAVEPOINT sp\; ROLLBACK TO SAVEPOINT sp\; COMMIT;
---END---
---START---


-- Tests for AND CHAIN in implicit transaction blocks

SET TRANSACTION READ ONLY\; COMMIT AND CHAIN;  -- error
SHOW transaction_read_only;
---END---
---START---

SET TRANSACTION READ ONLY\; ROLLBACK AND CHAIN;  -- error
SHOW transaction_read_only;
---END---
---START---

CREATE TABLE trans_abc (a int);
---END---
---START---

-- COMMIT/ROLLBACK + COMMIT/ROLLBACK AND CHAIN
INSERT INTO trans_abc VALUES (7)\; COMMIT\; INSERT INTO trans_abc VALUES (8)\; COMMIT AND CHAIN;  -- 7 commit, 8 error
INSERT INTO trans_abc VALUES (9)\; ROLLBACK\; INSERT INTO trans_abc VALUES (10)\; ROLLBACK AND CHAIN;  -- 9 rollback, 10 error

-- COMMIT/ROLLBACK AND CHAIN + COMMIT/ROLLBACK
INSERT INTO trans_abc VALUES (11)\; COMMIT AND CHAIN\; INSERT INTO trans_abc VALUES (12)\; COMMIT;  -- 11 error, 12 not reached
INSERT INTO trans_abc VALUES (13)\; ROLLBACK AND CHAIN\; INSERT INTO trans_abc VALUES (14)\; ROLLBACK;  -- 13 error, 14 not reached

-- START TRANSACTION + COMMIT/ROLLBACK AND CHAIN
START TRANSACTION ISOLATION LEVEL REPEATABLE READ\; INSERT INTO trans_abc VALUES (15)\; COMMIT AND CHAIN;  -- 15 ok
SHOW transaction_isolation;  -- transaction is active at this point
COMMIT;
---END---
---START---

START TRANSACTION ISOLATION LEVEL REPEATABLE READ\; INSERT INTO trans_abc VALUES (16)\; ROLLBACK AND CHAIN;  -- 16 ok
SHOW transaction_isolation;  -- transaction is active at this point
ROLLBACK;
---END---
---START---

SET default_transaction_isolation = 'read committed';
---END---
---START---

-- START TRANSACTION + COMMIT/ROLLBACK + COMMIT/ROLLBACK AND CHAIN
START TRANSACTION ISOLATION LEVEL REPEATABLE READ\; INSERT INTO trans_abc VALUES (17)\; COMMIT\; INSERT INTO trans_abc VALUES (18)\; COMMIT AND CHAIN;  -- 17 commit, 18 error
SHOW transaction_isolation;  -- out of transaction block

START TRANSACTION ISOLATION LEVEL REPEATABLE READ\; INSERT INTO trans_abc VALUES (19)\; ROLLBACK\; INSERT INTO trans_abc VALUES (20)\; ROLLBACK AND CHAIN;  -- 19 rollback, 20 error
SHOW transaction_isolation;  -- out of transaction block

RESET default_transaction_isolation;
---END---
---START---

SELECT * FROM trans_abc ORDER BY 1;
---END---
---START---

DROP TABLE trans_abc;
---END---
---START---


-- Test for successful cleanup of an aborted transaction at session exit.
-- THIS MUST BE THE LAST TEST IN THIS FILE.

begin;
---END---
---START---
select 1/0;
---END---
---START---
rollback to X;
---END---
