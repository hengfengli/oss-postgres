---START---
--
-- Cursor regression tests
--

BEGIN;
---END---
---START---
DECLARE foo1 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo2 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo3 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo4 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo5 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo6 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo7 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo8 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo9 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo10 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo11 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo12 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo13 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo14 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo15 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo16 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo17 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo18 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo19 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo20 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo21 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
DECLARE foo22 SCROLL CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DECLARE foo23 SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
FETCH 1 in foo1;
---END---
---START---
FETCH 2 in foo2;
---END---
---START---
FETCH 3 in foo3;
---END---
---START---
FETCH 4 in foo4;
---END---
---START---
FETCH 5 in foo5;
---END---
---START---
FETCH 6 in foo6;
---END---
---START---
FETCH 7 in foo7;
---END---
---START---
FETCH 8 in foo8;
---END---
---START---
FETCH 9 in foo9;
---END---
---START---
FETCH 10 in foo10;
---END---
---START---
FETCH 11 in foo11;
---END---
---START---
FETCH 12 in foo12;
---END---
---START---
FETCH 13 in foo13;
---END---
---START---
FETCH 14 in foo14;
---END---
---START---
FETCH 15 in foo15;
---END---
---START---
FETCH 16 in foo16;
---END---
---START---
FETCH 17 in foo17;
---END---
---START---
FETCH 18 in foo18;
---END---
---START---
FETCH 19 in foo19;
---END---
---START---
FETCH 20 in foo20;
---END---
---START---
FETCH 21 in foo21;
---END---
---START---
FETCH 22 in foo22;
---END---
---START---
FETCH 23 in foo23;
---END---
---START---
FETCH backward 1 in foo23;
---END---
---START---
FETCH backward 2 in foo22;
---END---
---START---
FETCH backward 3 in foo21;
---END---
---START---
FETCH backward 4 in foo20;
---END---
---START---
FETCH backward 5 in foo19;
---END---
---START---
FETCH backward 6 in foo18;
---END---
---START---
FETCH backward 7 in foo17;
---END---
---START---
FETCH backward 8 in foo16;
---END---
---START---
FETCH backward 9 in foo15;
---END---
---START---
FETCH backward 10 in foo14;
---END---
---START---
FETCH backward 11 in foo13;
---END---
---START---
FETCH backward 12 in foo12;
---END---
---START---
FETCH backward 13 in foo11;
---END---
---START---
FETCH backward 14 in foo10;
---END---
---START---
FETCH backward 15 in foo9;
---END---
---START---
FETCH backward 16 in foo8;
---END---
---START---
FETCH backward 17 in foo7;
---END---
---START---
FETCH backward 18 in foo6;
---END---
---START---
FETCH backward 19 in foo5;
---END---
---START---
FETCH backward 20 in foo4;
---END---
---START---
FETCH backward 21 in foo3;
---END---
---START---
FETCH backward 22 in foo2;
---END---
---START---
FETCH backward 23 in foo1;
---END---
---START---
CLOSE foo1;
---END---
---START---
CLOSE foo2;
---END---
---START---
CLOSE foo3;
---END---
---START---
CLOSE foo4;
---END---
---START---
CLOSE foo5;
---END---
---START---
CLOSE foo6;
---END---
---START---
CLOSE foo7;
---END---
---START---
CLOSE foo8;
---END---
---START---
CLOSE foo9;
---END---
---START---
CLOSE foo10;
---END---
---START---
CLOSE foo11;
---END---
---START---
CLOSE foo12;
---END---
---START---
-- leave some cursors open, to test that auto-close works.

-- record this in the system view as well (don't query the time field there
-- however)
SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors ORDER BY 1;
---END---
---START---
END;
---END---
---START---
SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors;
---END---
---START---
--
-- NO SCROLL disallows backward fetching
--

BEGIN;
---END---
---START---
DECLARE foo24 NO SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
FETCH 1 FROM foo24;
---END---
---START---
FETCH BACKWARD 1 FROM foo24;
---END---
---START---
-- should fail

END;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE foo24 NO SCROLL CURSOR FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
FETCH 1 FROM foo24;
---END---
---START---
FETCH ABSOLUTE 2 FROM foo24;
---END---
---START---
-- allowed

FETCH ABSOLUTE 1 FROM foo24;
---END---
---START---
-- should fail

END;
---END---
---START---
--
-- Cursors outside transaction blocks
--


SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE foo25 SCROLL CURSOR WITH HOLD FOR SELECT * FROM tenk2;
---END---
---START---
FETCH FROM foo25;
---END---
---START---
FETCH FROM foo25;
---END---
---START---
COMMIT;
---END---
---START---
FETCH FROM foo25;
---END---
---START---
FETCH BACKWARD FROM foo25;
---END---
---START---
FETCH ABSOLUTE -1 FROM foo25;
---END---
---START---
SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors;
---END---
---START---
CLOSE foo25;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE foo25ns NO SCROLL CURSOR WITH HOLD FOR SELECT * FROM tenk2;
---END---
---START---
FETCH FROM foo25ns;
---END---
---START---
FETCH FROM foo25ns;
---END---
---START---
COMMIT;
---END---
---START---
FETCH FROM foo25ns;
---END---
---START---
FETCH ABSOLUTE 4 FROM foo25ns;
---END---
---START---
FETCH ABSOLUTE 4 FROM foo25ns;
---END---
---START---
-- fail

SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors;
---END---
---START---
CLOSE foo25ns;
---END---
---START---
--
-- ROLLBACK should close holdable cursors
--

BEGIN;
---END---
---START---
DECLARE foo26 CURSOR WITH HOLD FOR SELECT * FROM tenk1 ORDER BY unique2;
---END---
---START---
ROLLBACK;
---END---
---START---
-- should fail
FETCH FROM foo26;
---END---
---START---
--
-- Parameterized DECLARE needs to insert param values into the cursor portal
--

BEGIN;
---END---
---START---
CREATE FUNCTION declares_cursor(text)
   RETURNS void
   AS 'DECLARE c CURSOR FOR SELECT stringu1 FROM tenk1 WHERE stringu1 LIKE $1;'
   LANGUAGE SQL;
---END---
---START---
SELECT declares_cursor('AB%');
---END---
---START---
FETCH ALL FROM c;
---END---
---START---
ROLLBACK;
---END---
---START---
--
-- Test behavior of both volatile and stable functions inside a cursor;
-- in particular we want to see what happens during commit of a holdable
-- cursor
--

DROP TABLE IF EXISTS tt1;

CREATE TABLE tt1 (_gemini_pk serial PRIMARY KEY, f1 integer);
---END---
---START---
create function count_tt1_v() returns int8 as
'select count(*) from tt1' language sql volatile;
---END---
---START---
create function count_tt1_s() returns int8 as
'select count(*) from tt1' language sql stable;
---END---
---START---
begin;
---END---
---START---
insert into tt1 values(1);
---END---
---START---
declare c1 cursor for select count_tt1_v(), count_tt1_s();
---END---
---START---
insert into tt1 values(2);
---END---
---START---
fetch all from c1;
---END---
---START---
rollback;
---END---
---START---
begin;
---END---
---START---
insert into tt1 values(1);
---END---
---START---
declare c2 cursor with hold for select count_tt1_v(), count_tt1_s();
---END---
---START---
insert into tt1 values(2);
---END---
---START---
commit;
---END---
---START---
delete from tt1;
---END---
---START---
fetch all from c2;
---END---
---START---
drop function count_tt1_v();
---END---
---START---
drop function count_tt1_s();
---END---
---START---
-- Create a cursor with the BINARY option and check the pg_cursors view
BEGIN;
---END---
---START---
SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors;
---END---
---START---
DECLARE bc BINARY CURSOR FOR SELECT * FROM tenk1;
---END---
---START---
SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors ORDER BY 1;
---END---
---START---
ROLLBACK;
---END---
---START---
-- We should not see the portal that is created internally to
-- implement EXECUTE in pg_cursors
PREPARE cprep AS
  SELECT name, statement, is_holdable, is_binary, is_scrollable FROM pg_cursors;
---END---
---START---
EXECUTE cprep;
---END---
---START---
-- test CLOSE ALL;
SELECT name FROM pg_cursors ORDER BY 1;
---END---
---START---
CLOSE ALL;
---END---
---START---
SELECT name FROM pg_cursors ORDER BY 1;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE foo1 CURSOR WITH HOLD FOR SELECT 1;
---END---
---START---
DECLARE foo2 CURSOR WITHOUT HOLD FOR SELECT 1;
---END---
---START---
SELECT name FROM pg_cursors ORDER BY 1;
---END---
---START---
CLOSE ALL;
---END---
---START---
SELECT name FROM pg_cursors ORDER BY 1;
---END---
---START---
COMMIT;
---END---
---START---
--
-- Tests for updatable cursors
--

DROP TABLE IF EXISTS uctest;

CREATE TABLE uctest (_gemini_pk serial PRIMARY KEY, f1 integer, f2 text);
---END---
---START---
INSERT INTO uctest VALUES (1, 'one'), (2, 'two'), (3, 'three');
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
-- Check DELETE WHERE CURRENT
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest;
---END---
---START---
FETCH 2 FROM c1;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
-- should show deletion
SELECT * FROM uctest;
---END---
---START---
-- cursor did not move
FETCH ALL FROM c1;
---END---
---START---
-- cursor is insensitive
MOVE BACKWARD ALL IN c1;
---END---
---START---
FETCH ALL FROM c1;
---END---
---START---
COMMIT;
---END---
---START---
-- should still see deletion
SELECT * FROM uctest;
---END---
---START---
-- Check UPDATE WHERE CURRENT; this time use FOR UPDATE
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest FOR UPDATE;
---END---
---START---
FETCH c1;
---END---
---START---
UPDATE uctest SET f1 = 8 WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
-- Check repeated-update and update-then-delete cases
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest;
---END---
---START---
FETCH c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
-- insensitive cursor should not show effects of updates or deletes
FETCH RELATIVE 0 FROM c1;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
-- no-op
SELECT * FROM uctest;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
-- no-op
SELECT * FROM uctest;
---END---
---START---
FETCH RELATIVE 0 FROM c1;
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest FOR UPDATE;
---END---
---START---
FETCH c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
-- no-op
SELECT * FROM uctest;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
-- no-op
SELECT * FROM uctest;
---END---
---START---
--- FOR UPDATE cursors can't currently scroll back, so this is an error:
FETCH RELATIVE 0 FROM c1;
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
-- Check insensitive cursor with INSERT
-- (The above tests don't test the SQL notion of an insensitive cursor
-- correctly, because per SQL standard, changes from WHERE CURRENT OF
-- commands should be visible in the cursor.  So here we make the
-- changes with a command that is independent of the cursor.)
BEGIN;
---END---
---START---
DECLARE c1 INSENSITIVE CURSOR FOR SELECT * FROM uctest;
---END---
---START---
INSERT INTO uctest VALUES (10, 'ten');
---END---
---START---
FETCH NEXT FROM c1;
---END---
---START---
FETCH NEXT FROM c1;
---END---
---START---
FETCH NEXT FROM c1;
---END---
---START---
-- insert not visible
COMMIT;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
DELETE FROM uctest WHERE f1 = 10;
---END---
---START---
-- restore test table state

-- Check inheritance cases
DROP TABLE IF EXISTS ucchild;

CREATE TABLE ucchild (_gemini_pk serial PRIMARY KEY) INHERITS (uctest);
---END---
---START---
INSERT INTO ucchild values(100, 'hundred');
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest FOR UPDATE;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
-- Can update from a self-join, but only if FOR UPDATE says which to use
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest a, uctest b WHERE a.f1 = b.f1 + 5;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
-- fail
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest a, uctest b WHERE a.f1 = b.f1 + 5 FOR UPDATE;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
-- fail
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest a, uctest b WHERE a.f1 = b.f1 + 5 FOR SHARE OF a;
---END---
---START---
FETCH 1 FROM c1;
---END---
---START---
UPDATE uctest SET f1 = f1 + 10 WHERE CURRENT OF c1;
---END---
---START---
SELECT * FROM uctest;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Check various error cases

DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
-- fail, no such cursor
DECLARE cx CURSOR WITH HOLD FOR SELECT * FROM uctest;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF cx;
---END---
---START---
-- fail, can't use held cursor
BEGIN;
---END---
---START---
DECLARE c CURSOR FOR SELECT * FROM tenk2;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c;
---END---
---START---
-- fail, cursor on wrong table
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c CURSOR FOR SELECT * FROM tenk2 FOR SHARE;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c;
---END---
---START---
-- fail, cursor on wrong table
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c CURSOR FOR SELECT * FROM tenk1 JOIN tenk2 USING (unique1);
---END---
---START---
DELETE FROM tenk1 WHERE CURRENT OF c;
---END---
---START---
-- fail, cursor is on a join
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c CURSOR FOR SELECT f1,count(*) FROM uctest GROUP BY f1;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c;
---END---
---START---
-- fail, cursor is on aggregation
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM uctest;
---END---
---START---
DELETE FROM uctest WHERE CURRENT OF c1;
---END---
---START---
-- fail, no current row
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT MIN(f1) FROM uctest FOR UPDATE;
---END---
---START---
ROLLBACK;
---END---
---START---
-- WHERE CURRENT OF may someday work with views, but today is not that day.
-- For now, just make sure it errors out cleanly.
CREATE TEMP VIEW ucview AS SELECT * FROM uctest;
---END---
---START---
CREATE RULE ucrule AS ON DELETE TO ucview DO INSTEAD
  DELETE FROM uctest WHERE f1 = OLD.f1;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE c1 CURSOR FOR SELECT * FROM ucview;
---END---
---START---
FETCH FROM c1;
---END---
---START---
DELETE FROM ucview WHERE CURRENT OF c1;
---END---
---START---
-- fail, views not supported
ROLLBACK;
---END---
---START---
-- Check WHERE CURRENT OF with an index-only scan
BEGIN;
---END---
---START---
EXPLAIN (costs off)
DECLARE c1 CURSOR FOR SELECT stringu1 FROM onek WHERE stringu1 = 'DZAAAA';
---END---
---START---
DECLARE c1 CURSOR FOR SELECT stringu1 FROM onek WHERE stringu1 = 'DZAAAA';
---END---
---START---
FETCH FROM c1;
---END---
---START---
DELETE FROM onek WHERE CURRENT OF c1;
---END---
---START---
SELECT stringu1 FROM onek WHERE stringu1 = 'DZAAAA';
---END---
---START---
ROLLBACK;
---END---
---START---
-- Check behavior with rewinding to a previous child scan node,
-- as per bug #15395
BEGIN;
---END---
---START---
CREATE TABLE current_check (_gemini_pk serial PRIMARY KEY, currentid integer, payload text);
---END---
---START---
CREATE TABLE current_check_1 (_gemini_pk serial PRIMARY KEY) INHERITS (current_check);
---END---
---START---
CREATE TABLE current_check_2 (_gemini_pk serial PRIMARY KEY) INHERITS (current_check);
---END---
---START---
INSERT INTO current_check_1 SELECT i, 'p' || i FROM generate_series(1,9) i;
---END---
---START---
INSERT INTO current_check_2 SELECT i, 'P' || i FROM generate_series(10,19) i;
---END---
---START---
DECLARE c1 SCROLL CURSOR FOR SELECT * FROM current_check;
---END---
---START---
-- This tests the fetch-backwards code path
FETCH ABSOLUTE 12 FROM c1;
---END---
---START---
FETCH ABSOLUTE 8 FROM c1;
---END---
---START---
DELETE FROM current_check WHERE CURRENT OF c1 RETURNING *;
---END---
---START---
-- This tests the ExecutorRewind code path
FETCH ABSOLUTE 13 FROM c1;
---END---
---START---
FETCH ABSOLUTE 1 FROM c1;
---END---
---START---
DELETE FROM current_check WHERE CURRENT OF c1 RETURNING *;
---END---
---START---
SELECT * FROM current_check;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Make sure snapshot management works okay, per bug report in
-- 235395b90909301035v7228ce63q392931f15aa74b31@mail.gmail.com
BEGIN;
---END---
---START---
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
CREATE TABLE cursor (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO cursor VALUES (1);
---END---
---START---
DECLARE c1 NO SCROLL CURSOR FOR SELECT * FROM cursor FOR UPDATE;
---END---
---START---
UPDATE cursor SET a = 2;
---END---
---START---
FETCH ALL FROM c1;
---END---
---START---
COMMIT;
---END---
---START---
DROP TABLE cursor;
---END---
---START---
-- Check rewinding a cursor containing a stable function in LIMIT,
-- per bug report in 8336843.9833.1399385291498.JavaMail.root@quick
begin;
---END---
---START---
create function nochange(int) returns int
  as 'select $1 limit 1' language sql stable;
---END---
---START---
declare c cursor for select * from int8_tbl limit nochange(3);
---END---
---START---
fetch all from c;
---END---
---START---
move backward all in c;
---END---
---START---
fetch all from c;
---END---
---START---
rollback;
---END---
---START---
-- Check handling of non-backwards-scan-capable plans with scroll cursors
begin;
---END---
---START---
explain (costs off) declare c1 cursor for select (select 42) as x;
---END---
---START---
explain (costs off) declare c1 scroll cursor for select (select 42) as x;
---END---
---START---
declare c1 scroll cursor for select (select 42) as x;
---END---
---START---
fetch all in c1;
---END---
---START---
fetch backward all in c1;
---END---
---START---
rollback;
---END---
---START---
begin;
---END---
---START---
explain (costs off) declare c2 cursor for select generate_series(1,3) as g;
---END---
---START---
explain (costs off) declare c2 scroll cursor for select generate_series(1,3) as g;
---END---
---START---
declare c2 scroll cursor for select generate_series(1,3) as g;
---END---
---START---
fetch all in c2;
---END---
---START---
fetch backward all in c2;
---END---
---START---
rollback;
---END---
---START---
-- Check fetching of toasted datums via cursors.
begin;
---END---
---START---
-- Other compression algorithms may cause the compressed data to be stored
-- inline.  Use pglz to ensure consistent results.
set default_toast_compression = 'pglz';
---END---
---START---
CREATE TABLE toasted_data (_gemini_pk serial PRIMARY KEY, f1 integer[]);
---END---
---START---
insert into toasted_data
  select array_agg(i) from generate_series(12345678, 12345678 + 1000) i;
---END---
---START---
declare local_portal cursor for select * from toasted_data;
---END---
---START---
fetch all in local_portal;
---END---
---START---
declare held_portal cursor with hold for select * from toasted_data;
---END---
---START---
commit;
---END---
---START---
drop table toasted_data;
---END---
---START---
fetch all in held_portal;
---END---
---START---
reset default_toast_compression;
---END---
