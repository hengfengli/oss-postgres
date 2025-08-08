---START---
--
-- Test the LOCK statement
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

-- Setup
CREATE SCHEMA lock_schema1;
---END---
---START---
SET search_path = lock_schema1;
---END---
---START---
CREATE TABLE lock_tbl1 (gemini_pk serial PRIMARY KEY, a bigint);
---END---
---START---
CREATE TABLE lock_tbl1a (gemini_pk serial PRIMARY KEY, a bigint);
---END---
---START---
CREATE VIEW lock_view1 AS SELECT * FROM lock_tbl1;
---END---
---START---
CREATE VIEW lock_view2(a,b) AS SELECT * FROM lock_tbl1, lock_tbl1a;
---END---
---START---
CREATE VIEW lock_view3 AS SELECT * from lock_view2;
---END---
---START---
CREATE VIEW lock_view4 AS SELECT (select a from lock_tbl1a limit 1) from lock_tbl1;
---END---
---START---
CREATE VIEW lock_view5 AS SELECT * from lock_tbl1 where a in (select * from lock_tbl1a);
---END---
---START---
CREATE VIEW lock_view6 AS SELECT * from (select * from lock_tbl1) sub;
---END---
---START---
CREATE ROLE regress_rol_lock1;
---END---
---START---
ALTER ROLE regress_rol_lock1 SET search_path = lock_schema1;
---END---
---START---
GRANT USAGE ON SCHEMA lock_schema1 TO regress_rol_lock1;
---END---
---START---
-- Try all valid lock options; also try omitting the optional TABLE keyword.
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_tbl1 IN ACCESS SHARE MODE;
---END---
---START---
LOCK lock_tbl1 IN ROW SHARE MODE;
---END---
---START---
LOCK TABLE lock_tbl1 IN ROW EXCLUSIVE MODE;
---END---
---START---
LOCK TABLE lock_tbl1 IN SHARE UPDATE EXCLUSIVE MODE;
---END---
---START---
LOCK TABLE lock_tbl1 IN SHARE MODE;
---END---
---START---
LOCK lock_tbl1 IN SHARE ROW EXCLUSIVE MODE;
---END---
---START---
LOCK TABLE lock_tbl1 IN EXCLUSIVE MODE;
---END---
---START---
LOCK TABLE lock_tbl1 IN ACCESS EXCLUSIVE MODE;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Try using NOWAIT along with valid options.
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_tbl1 IN ACCESS SHARE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN ROW SHARE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN ROW EXCLUSIVE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN SHARE UPDATE EXCLUSIVE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN SHARE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN EXCLUSIVE MODE NOWAIT;
---END---
---START---
LOCK TABLE lock_tbl1 IN ACCESS EXCLUSIVE MODE NOWAIT;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Verify that we can lock views.
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view1 IN EXCLUSIVE MODE;
---END---
---START---
-- lock_view1 and lock_tbl1 are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'ExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view2 IN EXCLUSIVE MODE;
---END---
---START---
-- lock_view1, lock_tbl1, and lock_tbl1a are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'ExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view3 IN EXCLUSIVE MODE;
---END---
---START---
-- lock_view3, lock_view2, lock_tbl1, and lock_tbl1a are locked recursively.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'ExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view4 IN EXCLUSIVE MODE;
---END---
---START---
-- lock_view4, lock_tbl1, and lock_tbl1a are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'ExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view5 IN EXCLUSIVE MODE;
---END---
---START---
-- lock_view5, lock_tbl1, and lock_tbl1a are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'ExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view6 IN EXCLUSIVE MODE;
---END---
---START---
-- lock_view6 an lock_tbl1 are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'ExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Verify that we cope with infinite recursion in view definitions.
CREATE OR REPLACE VIEW lock_view2 AS SELECT * from lock_view3;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view2 IN EXCLUSIVE MODE;
---END---
---START---
ROLLBACK;
---END---
---START---
CREATE VIEW lock_view7 AS SELECT * from lock_view2;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_view7 IN EXCLUSIVE MODE;
---END---
---START---
ROLLBACK;
---END---
---START---
CREATE TABLE lock_tbl2 (gemini_pk serial PRIMARY KEY, b bigint) INHERITS (lock_tbl1);
---END---
---START---
CREATE TABLE lock_tbl3 (gemini_pk serial PRIMARY KEY) INHERITS (lock_tbl2);
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
LOCK TABLE lock_tbl1 * IN ACCESS EXCLUSIVE MODE;
---END---
---START---
ROLLBACK;
---END---
---START---
-- Child tables are locked without granting explicit permission to do so as
-- long as we have permission to lock the parent.
GRANT UPDATE ON TABLE lock_tbl1 TO regress_rol_lock1;
---END---
---START---
SET ROLE regress_rol_lock1;
---END---
---START---
-- fail when child locked directly
BEGIN;
---END---
---START---
LOCK TABLE lock_tbl2;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_tbl1 * IN ACCESS EXCLUSIVE MODE;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE ONLY lock_tbl1;
---END---
---START---
ROLLBACK;
---END---
---START---
RESET ROLE;
---END---
---START---
REVOKE UPDATE ON TABLE lock_tbl1 FROM regress_rol_lock1;
---END---
---START---
-- Tables referred to by views are locked without explicit permission to do so
-- as long as we have permission to lock the view itself.
SET ROLE regress_rol_lock1;
---END---
---START---
-- fail without permissions on the view
BEGIN;
---END---
---START---
LOCK TABLE lock_view1;
---END---
---START---
ROLLBACK;
---END---
---START---
RESET ROLE;
---END---
---START---
GRANT UPDATE ON TABLE lock_view1 TO regress_rol_lock1;
---END---
---START---
SET ROLE regress_rol_lock1;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_view1 IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- lock_view1 and lock_tbl1 (plus children lock_tbl2 and lock_tbl3) are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'AccessExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
RESET ROLE;
---END---
---START---
REVOKE UPDATE ON TABLE lock_view1 FROM regress_rol_lock1;
---END---
---START---
-- Tables referred to by security invoker views require explicit permission to
-- be locked.
CREATE VIEW lock_view8 WITH (security_invoker) AS SELECT * FROM lock_tbl1;
---END---
---START---
SET ROLE regress_rol_lock1;
---END---
---START---
-- fail without permissions on the view
BEGIN;
---END---
---START---
LOCK TABLE lock_view8;
---END---
---START---
ROLLBACK;
---END---
---START---
RESET ROLE;
---END---
---START---
GRANT UPDATE ON TABLE lock_view8 TO regress_rol_lock1;
---END---
---START---
SET ROLE regress_rol_lock1;
---END---
---START---
-- fail without permissions on the table referenced by the view
BEGIN;
---END---
---START---
LOCK TABLE lock_view8;
---END---
---START---
ROLLBACK;
---END---
---START---
RESET ROLE;
---END---
---START---
GRANT UPDATE ON TABLE lock_tbl1 TO regress_rol_lock1;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_view8 IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- lock_view8 and lock_tbl1 (plus children lock_tbl2 and lock_tbl3) are locked.
select relname from pg_locks l, pg_class c
 where l.relation = c.oid and relname like '%lock_%' and mode = 'AccessExclusiveLock'
 order by relname;
---END---
---START---
ROLLBACK;
---END---
---START---
RESET ROLE;
---END---
---START---
REVOKE UPDATE ON TABLE lock_view8 FROM regress_rol_lock1;
---END---
---START---
--
-- Clean up
--
DROP VIEW lock_view8;
---END---
---START---
DROP VIEW lock_view7;
---END---
---START---
DROP VIEW lock_view6;
---END---
---START---
DROP VIEW lock_view5;
---END---
---START---
DROP VIEW lock_view4;
---END---
---START---
DROP VIEW lock_view3 CASCADE;
---END---
---START---
DROP VIEW lock_view1;
---END---
---START---
DROP TABLE lock_tbl3;
---END---
---START---
DROP TABLE lock_tbl2;
---END---
---START---
DROP TABLE lock_tbl1;
---END---
---START---
DROP TABLE lock_tbl1a;
---END---
---START---
DROP SCHEMA lock_schema1 CASCADE;
---END---
---START---
DROP ROLE regress_rol_lock1;
---END---
---START---
-- atomic ops tests
RESET search_path;
---END---
---START---
CREATE FUNCTION test_atomic_ops()
    RETURNS bool
    AS :'regresslib'
    LANGUAGE C;
---END---
---START---
SELECT test_atomic_ops();
---END---
