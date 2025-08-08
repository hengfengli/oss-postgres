---START---
--
-- Test access privileges
--

-- Clean up in case a prior regression run failed

-- Suppress NOTICE messages when users/groups don't exist
SET client_min_messages TO 'warning';
---END---
---START---
DROP ROLE IF EXISTS regress_priv_group1;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_group2;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user1;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user2;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user3;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user4;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user5;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user6;
---END---
---START---
DROP ROLE IF EXISTS regress_priv_user7;
---END---
---START---
SELECT lo_unlink(oid) FROM pg_largeobject_metadata WHERE oid >= 1000 AND oid < 3000 ORDER BY oid;
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- test proper begins here

CREATE USER regress_priv_user1;
---END---
---START---
CREATE USER regress_priv_user2;
---END---
---START---
CREATE USER regress_priv_user3;
---END---
---START---
CREATE USER regress_priv_user4;
---END---
---START---
CREATE USER regress_priv_user5;
---END---
---START---
CREATE USER regress_priv_user5;
---END---
---START---
-- duplicate
CREATE USER regress_priv_user6;
---END---
---START---
CREATE USER regress_priv_user7;
---END---
---START---
CREATE USER regress_priv_user8;
---END---
---START---
CREATE USER regress_priv_user9;
---END---
---START---
CREATE USER regress_priv_user10;
---END---
---START---
CREATE ROLE regress_priv_role;
---END---
---START---
-- circular ADMIN OPTION grants should be disallowed
GRANT regress_priv_user1 TO regress_priv_user2 WITH ADMIN OPTION;
---END---
---START---
GRANT regress_priv_user1 TO regress_priv_user3 WITH ADMIN OPTION GRANTED BY regress_priv_user2;
---END---
---START---
GRANT regress_priv_user1 TO regress_priv_user2 WITH ADMIN OPTION GRANTED BY regress_priv_user3;
---END---
---START---
-- need CASCADE to revoke grant or admin option if dependent grants exist
REVOKE ADMIN OPTION FOR regress_priv_user1 FROM regress_priv_user2;
---END---
---START---
-- fail
REVOKE regress_priv_user1 FROM regress_priv_user2;
---END---
---START---
-- fail
SELECT member::regrole, admin_option FROM pg_auth_members WHERE roleid = 'regress_priv_user1'::regrole;
---END---
---START---
BEGIN;
---END---
---START---
REVOKE ADMIN OPTION FOR regress_priv_user1 FROM regress_priv_user2 CASCADE;
---END---
---START---
SELECT member::regrole, admin_option FROM pg_auth_members WHERE roleid = 'regress_priv_user1'::regrole;
---END---
---START---
ROLLBACK;
---END---
---START---
REVOKE regress_priv_user1 FROM regress_priv_user2 CASCADE;
---END---
---START---
SELECT member::regrole, admin_option FROM pg_auth_members WHERE roleid = 'regress_priv_user1'::regrole;
---END---
---START---
-- inferred grantor must be a role with ADMIN OPTION
GRANT regress_priv_user1 TO regress_priv_user2 WITH ADMIN OPTION;
---END---
---START---
GRANT regress_priv_user2 TO regress_priv_user3;
---END---
---START---
SET ROLE regress_priv_user3;
---END---
---START---
GRANT regress_priv_user1 TO regress_priv_user4;
---END---
---START---
SELECT grantor::regrole FROM pg_auth_members WHERE roleid = 'regress_priv_user1'::regrole and member = 'regress_priv_user4'::regrole;
---END---
---START---
RESET ROLE;
---END---
---START---
REVOKE regress_priv_user2 FROM regress_priv_user3;
---END---
---START---
REVOKE regress_priv_user1 FROM regress_priv_user2 CASCADE;
---END---
---START---
-- test GRANTED BY with DROP OWNED and REASSIGN OWNED
GRANT regress_priv_user1 TO regress_priv_user2 WITH ADMIN OPTION;
---END---
---START---
GRANT regress_priv_user1 TO regress_priv_user3 GRANTED BY regress_priv_user2;
---END---
---START---
DROP ROLE regress_priv_user2;
---END---
---START---
-- fail, dependency
REASSIGN OWNED BY regress_priv_user2 TO regress_priv_user4;
---END---
---START---
DROP ROLE regress_priv_user2;
---END---
---START---
-- still fail, REASSIGN OWNED doesn't help
DROP OWNED BY regress_priv_user2;
---END---
---START---
DROP ROLE regress_priv_user2;
---END---
---START---
-- ok now, DROP OWNED does the job

-- test that removing granted role or grantee role removes dependency
GRANT regress_priv_user1 TO regress_priv_user3 WITH ADMIN OPTION;
---END---
---START---
GRANT regress_priv_user1 TO regress_priv_user4 GRANTED BY regress_priv_user3;
---END---
---START---
DROP ROLE regress_priv_user3;
---END---
---START---
-- should fail, dependency
DROP ROLE regress_priv_user4;
---END---
---START---
-- ok
DROP ROLE regress_priv_user3;
---END---
---START---
-- ok now
GRANT regress_priv_user1 TO regress_priv_user5 WITH ADMIN OPTION;
---END---
---START---
GRANT regress_priv_user1 TO regress_priv_user6 GRANTED BY regress_priv_user5;
---END---
---START---
DROP ROLE regress_priv_user5;
---END---
---START---
-- should fail, dependency
DROP ROLE regress_priv_user1, regress_priv_user5;
---END---
---START---
-- ok, despite order

-- recreate the roles we just dropped
CREATE USER regress_priv_user1;
---END---
---START---
CREATE USER regress_priv_user2;
---END---
---START---
CREATE USER regress_priv_user3;
---END---
---START---
CREATE USER regress_priv_user4;
---END---
---START---
CREATE USER regress_priv_user5;
---END---
---START---
GRANT pg_read_all_data TO regress_priv_user6;
---END---
---START---
GRANT pg_write_all_data TO regress_priv_user7;
---END---
---START---
GRANT pg_read_all_settings TO regress_priv_user8 WITH ADMIN OPTION;
---END---
---START---
GRANT regress_priv_user9 TO regress_priv_user8;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user8;
---END---
---START---
GRANT pg_read_all_settings TO regress_priv_user9 WITH ADMIN OPTION;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user9;
---END---
---START---
GRANT pg_read_all_settings TO regress_priv_user10;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user8;
---END---
---START---
REVOKE pg_read_all_settings FROM regress_priv_user10 GRANTED BY regress_priv_user9;
---END---
---START---
REVOKE ADMIN OPTION FOR pg_read_all_settings FROM regress_priv_user9;
---END---
---START---
REVOKE pg_read_all_settings FROM regress_priv_user9;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE regress_priv_user9 FROM regress_priv_user8;
---END---
---START---
REVOKE ADMIN OPTION FOR pg_read_all_settings FROM regress_priv_user8;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user8;
---END---
---START---
SET ROLE pg_read_all_settings;
---END---
---START---
RESET ROLE;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE SET OPTION FOR pg_read_all_settings FROM regress_priv_user8;
---END---
---START---
GRANT pg_read_all_stats TO regress_priv_user8 WITH SET FALSE;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user8;
---END---
---START---
SET ROLE pg_read_all_settings;
---END---
---START---
-- fail, no SET option any more
SET ROLE pg_read_all_stats;
---END---
---START---
-- fail, granted without SET option
RESET ROLE;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE pg_read_all_settings FROM regress_priv_user8;
---END---
---START---
DROP USER regress_priv_user10;
---END---
---START---
DROP USER regress_priv_user9;
---END---
---START---
DROP USER regress_priv_user8;
---END---
---START---
CREATE GROUP regress_priv_group1;
---END---
---START---
CREATE GROUP regress_priv_group2 WITH ADMIN regress_priv_user1 USER regress_priv_user2;
---END---
---START---
ALTER GROUP regress_priv_group1 ADD USER regress_priv_user4;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user2 GRANTED BY regress_priv_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
ALTER GROUP regress_priv_group2 ADD USER regress_priv_user2;
---END---
---START---
ALTER GROUP regress_priv_group2 ADD USER regress_priv_user2;
---END---
---START---
-- duplicate
ALTER GROUP regress_priv_group2 DROP USER regress_priv_user2;
---END---
---START---
ALTER USER regress_priv_user2 PASSWORD 'verysecret';
---END---
---START---
-- not permitted
RESET SESSION AUTHORIZATION;
---END---
---START---
ALTER GROUP regress_priv_group2 DROP USER regress_priv_user2;
---END---
---START---
REVOKE ADMIN OPTION FOR regress_priv_group2 FROM regress_priv_user1;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user4 WITH ADMIN OPTION;
---END---
---START---
-- prepare non-leakproof function for later
CREATE FUNCTION leak(integer,integer) RETURNS boolean
  AS 'int4lt'
  LANGUAGE internal IMMUTABLE STRICT;
---END---
---START---
-- but deliberately not LEAKPROOF
ALTER FUNCTION leak(integer,integer) OWNER TO regress_priv_user1;
---END---
---START---
-- test owner privileges

GRANT regress_priv_role TO regress_priv_user1 WITH ADMIN OPTION GRANTED BY regress_priv_role;
---END---
---START---
-- error, doesn't have ADMIN OPTION
GRANT regress_priv_role TO regress_priv_user1 WITH ADMIN OPTION GRANTED BY CURRENT_ROLE;
---END---
---START---
REVOKE ADMIN OPTION FOR regress_priv_role FROM regress_priv_user1 GRANTED BY foo;
---END---
---START---
-- error
REVOKE ADMIN OPTION FOR regress_priv_role FROM regress_priv_user1 GRANTED BY regress_priv_user2;
---END---
---START---
-- warning, noop
REVOKE ADMIN OPTION FOR regress_priv_role FROM regress_priv_user1 GRANTED BY CURRENT_USER;
---END---
---START---
REVOKE regress_priv_role FROM regress_priv_user1 GRANTED BY CURRENT_ROLE;
---END---
---START---
DROP ROLE regress_priv_role;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
SELECT session_user, current_user;
---END---
---START---
CREATE TABLE atest1 ( a int, b text );
---END---
---START---
SELECT * FROM atest1;
---END---
---START---
INSERT INTO atest1 VALUES (1, 'one');
---END---
---START---
DELETE FROM atest1;
---END---
---START---
UPDATE atest1 SET a = 1 WHERE b = 'blech';
---END---
---START---
TRUNCATE atest1;
---END---
---START---
BEGIN;
---END---
---START---
LOCK atest1 IN ACCESS EXCLUSIVE MODE;
---END---
---START---
COMMIT;
---END---
---START---
REVOKE ALL ON atest1 FROM PUBLIC;
---END---
---START---
SELECT * FROM atest1;
---END---
---START---
GRANT ALL ON atest1 TO regress_priv_user2;
---END---
---START---
GRANT SELECT ON atest1 TO regress_priv_user3, regress_priv_user4;
---END---
---START---
SELECT * FROM atest1;
---END---
---START---
CREATE TABLE atest2 (col1 varchar(10), col2 boolean);
---END---
---START---
GRANT SELECT ON atest2 TO regress_priv_user2;
---END---
---START---
GRANT UPDATE ON atest2 TO regress_priv_user3;
---END---
---START---
GRANT INSERT ON atest2 TO regress_priv_user4 GRANTED BY CURRENT_USER;
---END---
---START---
GRANT TRUNCATE ON atest2 TO regress_priv_user5 GRANTED BY CURRENT_ROLE;
---END---
---START---
GRANT TRUNCATE ON atest2 TO regress_priv_user4 GRANTED BY regress_priv_user5;
---END---
---START---
-- error


SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT session_user, current_user;
---END---
---START---
-- try various combinations of queries on atest1 and atest2

SELECT * FROM atest1;
---END---
---START---
-- ok
SELECT * FROM atest2;
---END---
---START---
-- ok
INSERT INTO atest1 VALUES (2, 'two');
---END---
---START---
-- ok
INSERT INTO atest2 VALUES ('foo', true);
---END---
---START---
-- fail
INSERT INTO atest1 SELECT 1, b FROM atest1;
---END---
---START---
-- ok
UPDATE atest1 SET a = 1 WHERE a = 2;
---END---
---START---
-- ok
UPDATE atest2 SET col2 = NOT col2;
---END---
---START---
-- fail
SELECT * FROM atest1 FOR UPDATE;
---END---
---START---
-- ok
SELECT * FROM atest2 FOR UPDATE;
---END---
---START---
-- fail
DELETE FROM atest2;
---END---
---START---
-- fail
TRUNCATE atest2;
---END---
---START---
-- fail
BEGIN;
---END---
---START---
LOCK atest2 IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- fail
COMMIT;
---END---
---START---
COPY atest2 FROM stdin; -- fail
GRANT ALL ON atest1 TO PUBLIC; -- fail

-- checks in subquery, both ok
SELECT * FROM atest1 WHERE ( b IN ( SELECT col1 FROM atest2 ) );
SELECT * FROM atest2 WHERE ( col1 IN ( SELECT b FROM atest1 ) );

SET SESSION AUTHORIZATION regress_priv_user6;
SELECT * FROM atest1; -- ok
SELECT * FROM atest2; -- ok
INSERT INTO atest2 VALUES ('foo', true); -- fail

SET SESSION AUTHORIZATION regress_priv_user7;
SELECT * FROM atest1; -- fail
SELECT * FROM atest2; -- fail
INSERT INTO atest2 VALUES ('foo', true); -- ok
UPDATE atest2 SET col2 = true; -- ok
DELETE FROM atest2; -- ok

-- Make sure we are not able to modify system catalogs
UPDATE pg_catalog.pg_class SET relname = '123'; -- fail
DELETE FROM pg_catalog.pg_class; -- fail
UPDATE pg_toast.pg_toast_1213 SET chunk_id = 1; -- fail

SET SESSION AUTHORIZATION regress_priv_user3;
SELECT session_user, current_user;

SELECT * FROM atest1; -- ok
SELECT * FROM atest2; -- fail
INSERT INTO atest1 VALUES (2, 'two'); -- fail
INSERT INTO atest2 VALUES ('foo', true); -- fail
INSERT INTO atest1 SELECT 1, b FROM atest1; -- fail
UPDATE atest1 SET a = 1 WHERE a = 2; -- fail
UPDATE atest2 SET col2 = NULL; -- ok
UPDATE atest2 SET col2 = NOT col2; -- fails; requires SELECT on atest2
UPDATE atest2 SET col2 = true FROM atest1 WHERE atest1.a = 5; -- ok
SELECT * FROM atest1 FOR UPDATE; -- fail
SELECT * FROM atest2 FOR UPDATE; -- fail
DELETE FROM atest2; -- fail
TRUNCATE atest2; -- fail
BEGIN;
LOCK atest2 IN ACCESS EXCLUSIVE MODE; -- ok
COMMIT;
COPY atest2 FROM stdin; -- fail

-- checks in subquery, both fail
SELECT * FROM atest1 WHERE ( b IN ( SELECT col1 FROM atest2 ) );
SELECT * FROM atest2 WHERE ( col1 IN ( SELECT b FROM atest1 ) );

SET SESSION AUTHORIZATION regress_priv_user4;
COPY atest2 FROM stdin; -- ok
bar	true
\.
---END---
---START---
SELECT * FROM atest1;
---END---
---START---
-- ok


-- test leaky-function protections in selfuncs

-- regress_priv_user1 will own a table and provide views for it.
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
CREATE TABLE atest12 as
  SELECT x AS a, 10001 - x AS b FROM generate_series(1,10000) x;
---END---
---START---
CREATE INDEX ON atest12 (a);
---END---
---START---
CREATE INDEX ON atest12 (abs(a));
---END---
---START---
-- results below depend on having quite accurate stats for atest12, so...
ALTER TABLE atest12 SET (autovacuum_enabled = off);
---END---
---START---
SET default_statistics_target = 10000;
---END---
---START---
VACUUM ANALYZE atest12;
---END---
---START---
RESET default_statistics_target;
---END---
---START---
CREATE OPERATOR <<< (procedure = leak, leftarg = integer, rightarg = integer,
                     restrict = scalarltsel);
---END---
---START---
-- views with leaky operator
CREATE VIEW atest12v AS
  SELECT * FROM atest12 WHERE b <<< 5;
---END---
---START---
CREATE VIEW atest12sbv WITH (security_barrier=true) AS
  SELECT * FROM atest12 WHERE b <<< 5;
---END---
---START---
GRANT SELECT ON atest12v TO PUBLIC;
---END---
---START---
GRANT SELECT ON atest12sbv TO PUBLIC;
---END---
---START---
-- This plan should use nestloop, knowing that few rows will be selected.
EXPLAIN (COSTS OFF) SELECT * FROM atest12v x, atest12v y WHERE x.a = y.b;
---END---
---START---
-- And this one.
EXPLAIN (COSTS OFF) SELECT * FROM atest12 x, atest12 y
  WHERE x.a = y.b and abs(y.a) <<< 5;
---END---
---START---
-- This should also be a nestloop, but the security barrier forces the inner
-- scan to be materialized
EXPLAIN (COSTS OFF) SELECT * FROM atest12sbv x, atest12sbv y WHERE x.a = y.b;
---END---
---START---
-- Check if regress_priv_user2 can break security.
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
CREATE FUNCTION leak2(integer,integer) RETURNS boolean
  AS $$begin raise notice 'leak % %', $1, $2; return $1 > $2; end$$
  LANGUAGE plpgsql immutable;
---END---
---START---
CREATE OPERATOR >>> (procedure = leak2, leftarg = integer, rightarg = integer,
                     restrict = scalargtsel);
---END---
---START---
-- This should not show any "leak" notices before failing.
EXPLAIN (COSTS OFF) SELECT * FROM atest12 WHERE a >>> 0;
---END---
---START---
-- These plans should continue to use a nestloop, since they execute with the
-- privileges of the view owner.
EXPLAIN (COSTS OFF) SELECT * FROM atest12v x, atest12v y WHERE x.a = y.b;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM atest12sbv x, atest12sbv y WHERE x.a = y.b;
---END---
---START---
-- A non-security barrier view does not guard against information leakage.
EXPLAIN (COSTS OFF) SELECT * FROM atest12v x, atest12v y
  WHERE x.a = y.b and abs(y.a) <<< 5;
---END---
---START---
-- But a security barrier view isolates the leaky operator.
EXPLAIN (COSTS OFF) SELECT * FROM atest12sbv x, atest12sbv y
  WHERE x.a = y.b and abs(y.a) <<< 5;
---END---
---START---
-- Now regress_priv_user1 grants sufficient access to regress_priv_user2.
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT SELECT (a, b) ON atest12 TO PUBLIC;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
-- regress_priv_user2 should continue to get a good row estimate.
EXPLAIN (COSTS OFF) SELECT * FROM atest12v x, atest12v y WHERE x.a = y.b;
---END---
---START---
-- But not for this, due to lack of table-wide permissions needed
-- to make use of the expression index's statistics.
EXPLAIN (COSTS OFF) SELECT * FROM atest12 x, atest12 y
  WHERE x.a = y.b and abs(y.a) <<< 5;
---END---
---START---
-- clean up (regress_priv_user1's objects are all dropped later)
DROP FUNCTION leak2(integer, integer) CASCADE;
---END---
---START---
-- groups

SET SESSION AUTHORIZATION regress_priv_user3;
---END---
---START---
CREATE TABLE atest3 (one int, two int, three int);
---END---
---START---
GRANT DELETE ON atest3 TO GROUP regress_priv_group2;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
SELECT * FROM atest3;
---END---
---START---
-- fail
DELETE FROM atest3;
---END---
---START---
-- ok

BEGIN;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
ALTER ROLE regress_priv_user1 NOINHERIT;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
DELETE FROM atest3;
---END---
---START---
-- ok because grant-level option is unchanged
ROLLBACK TO s1;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user1 WITH INHERIT FALSE;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
DELETE FROM atest3;
---END---
---START---
-- fail
ROLLBACK TO s1;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE INHERIT OPTION FOR regress_priv_group2 FROM regress_priv_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
DELETE FROM atest3;
---END---
---START---
-- also fail
ROLLBACK;
---END---
---START---
-- views

SET SESSION AUTHORIZATION regress_priv_user3;
---END---
---START---
CREATE VIEW atestv1 AS SELECT * FROM atest1;
---END---
---START---
-- ok
/* The next *should* fail, but it's not implemented that way yet. */
CREATE VIEW atestv2 AS SELECT * FROM atest2;
---END---
---START---
CREATE VIEW atestv3 AS SELECT * FROM atest3;
---END---
---START---
-- ok
/* Empty view is a corner case that failed in 9.2. */
CREATE VIEW atestv0 AS SELECT 0 as x WHERE false;
---END---
---START---
-- ok

SELECT * FROM atestv1;
---END---
---START---
-- ok
SELECT * FROM atestv2;
---END---
---START---
-- fail
GRANT SELECT ON atestv1, atestv3 TO regress_priv_user4;
---END---
---START---
GRANT SELECT ON atestv2 TO regress_priv_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT * FROM atestv1;
---END---
---START---
-- ok
SELECT * FROM atestv2;
---END---
---START---
-- fail
SELECT * FROM atestv3;
---END---
---START---
-- ok
SELECT * FROM atestv0;
---END---
---START---
-- fail

-- Appendrels excluded by constraints failed to check permissions in 8.4-9.2.
select * from
  ((select a.q1 as x from int8_tbl a offset 0)
   union all
   (select b.q2 as x from int8_tbl b offset 0)) ss
where false;
---END---
---START---
set constraint_exclusion = on;
---END---
---START---
select * from
  ((select a.q1 as x, random() from int8_tbl a where q1 > 0)
   union all
   (select b.q2 as x, random() from int8_tbl b where q2 > 0)) ss
where x < 0;
---END---
---START---
reset constraint_exclusion;
---END---
---START---
CREATE VIEW atestv4 AS SELECT * FROM atestv3;
---END---
---START---
-- nested view
SELECT * FROM atestv4;
---END---
---START---
-- ok
GRANT SELECT ON atestv4 TO regress_priv_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
-- Two complex cases:

SELECT * FROM atestv3;
---END---
---START---
-- fail
SELECT * FROM atestv4;
---END---
---START---
-- ok (even though regress_priv_user2 cannot access underlying atestv3)

SELECT * FROM atest2;
---END---
---START---
-- ok
SELECT * FROM atestv2;
---END---
---START---
-- fail (even though regress_priv_user2 can access underlying atest2)

-- Test column level permissions

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
CREATE TABLE atest5 (one int, two int unique, three int, four int unique);
---END---
---START---
CREATE TABLE atest6 (one int, two int, blue int);
---END---
---START---
GRANT SELECT (one), INSERT (two), UPDATE (three) ON atest5 TO regress_priv_user4;
---END---
---START---
GRANT ALL (one) ON atest5 TO regress_priv_user3;
---END---
---START---
INSERT INTO atest5 VALUES (1,2,3);
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT * FROM atest5;
---END---
---START---
-- fail
SELECT one FROM atest5;
---END---
---START---
COPY atest5 (one) TO stdout; -- ok
SELECT two FROM atest5; -- fail
COPY atest5 (two) TO stdout; -- fail
SELECT atest5 FROM atest5; -- fail
COPY atest5 (one,two) TO stdout; -- fail
SELECT 1 FROM atest5; -- ok
SELECT 1 FROM atest5 a JOIN atest5 b USING (one); -- ok
SELECT 1 FROM atest5 a JOIN atest5 b USING (two); -- fail
SELECT 1 FROM atest5 a NATURAL JOIN atest5 b; -- fail
SELECT * FROM (atest5 a JOIN atest5 b USING (one)) j; -- fail
SELECT j.* FROM (atest5 a JOIN atest5 b USING (one)) j; -- fail
SELECT (j.*) IS NULL FROM (atest5 a JOIN atest5 b USING (one)) j; -- fail
SELECT one FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)) j; -- ok
SELECT j.one FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)) j; -- ok
SELECT two FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)) j; -- fail
SELECT j.two FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)) j; -- fail
SELECT y FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)) j; -- fail
SELECT j.y FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)) j; -- fail
SELECT * FROM (atest5 a JOIN atest5 b USING (one)); -- fail
SELECT a.* FROM (atest5 a JOIN atest5 b USING (one)); -- fail
SELECT (a.*) IS NULL FROM (atest5 a JOIN atest5 b USING (one)); -- fail
SELECT two FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT a.two FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT y FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT b.y FROM (atest5 a JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT y FROM (atest5 a LEFT JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT b.y FROM (atest5 a LEFT JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT y FROM (atest5 a FULL JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT b.y FROM (atest5 a FULL JOIN atest5 b(one,x,y,z) USING (one)); -- fail
SELECT 1 FROM atest5 WHERE two = 2; -- fail
SELECT * FROM atest1, atest5; -- fail
SELECT atest1.* FROM atest1, atest5; -- ok
SELECT atest1.*,atest5.one FROM atest1, atest5; -- ok
SELECT atest1.*,atest5.one FROM atest1 JOIN atest5 ON (atest1.a = atest5.two); -- fail
SELECT atest1.*,atest5.one FROM atest1 JOIN atest5 ON (atest1.a = atest5.one); -- ok
SELECT one, two FROM atest5; -- fail

SET SESSION AUTHORIZATION regress_priv_user1;
GRANT SELECT (one,two) ON atest6 TO regress_priv_user4;

SET SESSION AUTHORIZATION regress_priv_user4;
SELECT one, two FROM atest5 NATURAL JOIN atest6; -- fail still

SET SESSION AUTHORIZATION regress_priv_user1;
GRANT SELECT (two) ON atest5 TO regress_priv_user4;

SET SESSION AUTHORIZATION regress_priv_user4;
SELECT one, two FROM atest5 NATURAL JOIN atest6; -- ok now

-- test column-level privileges for INSERT and UPDATE
INSERT INTO atest5 (two) VALUES (3); -- ok
COPY atest5 FROM stdin; -- fail
COPY atest5 (two) FROM stdin; -- ok
1
\.
---END---
---START---
INSERT INTO atest5 (three) VALUES (4);
---END---
---START---
-- fail
INSERT INTO atest5 VALUES (5,5,5);
---END---
---START---
-- fail
UPDATE atest5 SET three = 10;
---END---
---START---
-- ok
UPDATE atest5 SET one = 8;
---END---
---START---
-- fail
UPDATE atest5 SET three = 5, one = 2;
---END---
---START---
-- fail
-- Check that column level privs are enforced in RETURNING
-- Ok.
INSERT INTO atest5(two) VALUES (6) ON CONFLICT (two) DO UPDATE set three = 10;
---END---
---START---
-- Error. No SELECT on column three.
INSERT INTO atest5(two) VALUES (6) ON CONFLICT (two) DO UPDATE set three = 10 RETURNING atest5.three;
---END---
---START---
-- Ok.  May SELECT on column "one":
INSERT INTO atest5(two) VALUES (6) ON CONFLICT (two) DO UPDATE set three = 10 RETURNING atest5.one;
---END---
---START---
-- Check that column level privileges are enforced for EXCLUDED
-- Ok. we may select one
INSERT INTO atest5(two) VALUES (6) ON CONFLICT (two) DO UPDATE set three = EXCLUDED.one;
---END---
---START---
-- Error. No select rights on three
INSERT INTO atest5(two) VALUES (6) ON CONFLICT (two) DO UPDATE set three = EXCLUDED.three;
---END---
---START---
INSERT INTO atest5(two) VALUES (6) ON CONFLICT (two) DO UPDATE set one = 8;
---END---
---START---
-- fails (due to UPDATE)
INSERT INTO atest5(three) VALUES (4) ON CONFLICT (two) DO UPDATE set three = 10;
---END---
---START---
-- fails (due to INSERT)

-- Check that the columns in the inference require select privileges
INSERT INTO atest5(four) VALUES (4);
---END---
---START---
-- fail

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT INSERT (four) ON atest5 TO regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
INSERT INTO atest5(four) VALUES (4) ON CONFLICT (four) DO UPDATE set three = 3;
---END---
---START---
-- fails (due to SELECT)
INSERT INTO atest5(four) VALUES (4) ON CONFLICT ON CONSTRAINT atest5_four_key DO UPDATE set three = 3;
---END---
---START---
-- fails (due to SELECT)
INSERT INTO atest5(four) VALUES (4);
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT SELECT (four) ON atest5 TO regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
INSERT INTO atest5(four) VALUES (4) ON CONFLICT (four) DO UPDATE set three = 3;
---END---
---START---
-- ok
INSERT INTO atest5(four) VALUES (4) ON CONFLICT ON CONSTRAINT atest5_four_key DO UPDATE set three = 3;
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
REVOKE ALL (one) ON atest5 FROM regress_priv_user4;
---END---
---START---
GRANT SELECT (one,two,blue) ON atest6 TO regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT one FROM atest5;
---END---
---START---
-- fail
UPDATE atest5 SET one = 1;
---END---
---START---
-- fail
SELECT atest6 FROM atest6;
---END---
---START---
-- ok
COPY atest6 TO stdout;
---END---
---START---
-- ok

-- test column privileges with MERGE
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
CREATE TABLE mtarget (a int, b text);
---END---
---START---
CREATE TABLE msource (a int, b text);
---END---
---START---
INSERT INTO mtarget VALUES (1, 'init1'), (2, 'init2');
---END---
---START---
INSERT INTO msource VALUES (1, 'source1'), (2, 'source2'), (3, 'source3');
---END---
---START---
GRANT SELECT (a) ON msource TO regress_priv_user4;
---END---
---START---
GRANT SELECT (a) ON mtarget TO regress_priv_user4;
---END---
---START---
GRANT INSERT (a,b) ON mtarget TO regress_priv_user4;
---END---
---START---
GRANT UPDATE (b) ON mtarget TO regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
--
-- test source privileges
--

-- fail (no SELECT priv on s.b)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = s.b
WHEN NOT MATCHED THEN
	INSERT VALUES (a, NULL);
---END---
---START---
-- fail (s.b used in the INSERTed values)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = 'x'
WHEN NOT MATCHED THEN
	INSERT VALUES (a, b);
---END---
---START---
-- fail (s.b used in the WHEN quals)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED AND s.b = 'x' THEN
	UPDATE SET b = 'x'
WHEN NOT MATCHED THEN
	INSERT VALUES (a, NULL);
---END---
---START---
-- this should be ok since only s.a is accessed
BEGIN;
---END---
---START---
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = 'ok'
WHEN NOT MATCHED THEN
	INSERT VALUES (a, NULL);
---END---
---START---
ROLLBACK;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT SELECT (b) ON msource TO regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
-- should now be ok
BEGIN;
---END---
---START---
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = s.b
WHEN NOT MATCHED THEN
	INSERT VALUES (a, b);
---END---
---START---
ROLLBACK;
---END---
---START---
--
-- test target privileges
--

-- fail (no SELECT priv on t.b)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = t.b
WHEN NOT MATCHED THEN
	INSERT VALUES (a, NULL);
---END---
---START---
-- fail (no UPDATE on t.a)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = s.b, a = t.a + 1
WHEN NOT MATCHED THEN
	INSERT VALUES (a, b);
---END---
---START---
-- fail (no SELECT on t.b)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED AND t.b IS NOT NULL THEN
	UPDATE SET b = s.b
WHEN NOT MATCHED THEN
	INSERT VALUES (a, b);
---END---
---START---
-- ok
BEGIN;
---END---
---START---
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = s.b;
---END---
---START---
ROLLBACK;
---END---
---START---
-- fail (no DELETE)
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED AND t.b IS NOT NULL THEN
	DELETE;
---END---
---START---
-- grant delete privileges
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT DELETE ON mtarget TO regress_priv_user4;
---END---
---START---
-- should be ok now
BEGIN;
---END---
---START---
MERGE INTO mtarget t USING msource s ON t.a = s.a
WHEN MATCHED AND t.b IS NOT NULL THEN
	DELETE;
---END---
---START---
ROLLBACK;
---END---
---START---
-- check error reporting with column privs
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
CREATE TABLE t1 (c1 int, c2 int, c3 int check (c3 < 5), primary key (c1, c2));
---END---
---START---
GRANT SELECT (c1) ON t1 TO regress_priv_user2;
---END---
---START---
GRANT INSERT (c1, c2, c3) ON t1 TO regress_priv_user2;
---END---
---START---
GRANT UPDATE (c1, c2, c3) ON t1 TO regress_priv_user2;
---END---
---START---
-- seed data
INSERT INTO t1 VALUES (1, 1, 1);
---END---
---START---
INSERT INTO t1 VALUES (1, 2, 1);
---END---
---START---
INSERT INTO t1 VALUES (2, 1, 2);
---END---
---START---
INSERT INTO t1 VALUES (2, 2, 2);
---END---
---START---
INSERT INTO t1 VALUES (3, 1, 3);
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
INSERT INTO t1 (c1, c2) VALUES (1, 1);
---END---
---START---
-- fail, but row not shown
UPDATE t1 SET c2 = 1;
---END---
---START---
-- fail, but row not shown
INSERT INTO t1 (c1, c2) VALUES (null, null);
---END---
---START---
-- fail, but see columns being inserted
INSERT INTO t1 (c3) VALUES (null);
---END---
---START---
-- fail, but see columns being inserted or have SELECT
INSERT INTO t1 (c1) VALUES (5);
---END---
---START---
-- fail, but see columns being inserted or have SELECT
UPDATE t1 SET c3 = 10;
---END---
---START---
-- fail, but see columns with SELECT rights, or being modified

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
DROP TABLE t1;
---END---
---START---
-- check error reporting with column privs on a partitioned table
CREATE TABLE errtst(a text, b text NOT NULL, c text, secret1 text, secret2 text) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE errtst_part_1(secret2 text, c text, a text, b text NOT NULL, secret1 text);
---END---
---START---
CREATE TABLE errtst_part_2(secret1 text, secret2 text, a text, c text, b text NOT NULL);
---END---
---START---
ALTER TABLE errtst ATTACH PARTITION errtst_part_1 FOR VALUES IN ('aaa');
---END---
---START---
ALTER TABLE errtst ATTACH PARTITION errtst_part_2 FOR VALUES IN ('aaaa');
---END---
---START---
GRANT SELECT (a, b, c) ON TABLE errtst TO regress_priv_user2;
---END---
---START---
GRANT UPDATE (a, b, c) ON TABLE errtst TO regress_priv_user2;
---END---
---START---
GRANT INSERT (a, b, c) ON TABLE errtst TO regress_priv_user2;
---END---
---START---
INSERT INTO errtst_part_1 (a, b, c, secret1, secret2)
VALUES ('aaa', 'bbb', 'ccc', 'the body', 'is in the attic');
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
-- Perform a few updates that violate the NOT NULL constraint. Make sure
-- the error messages don't leak the secret fields.

-- simple insert.
INSERT INTO errtst (a, b) VALUES ('aaa', NULL);
---END---
---START---
-- simple update.
UPDATE errtst SET b = NULL;
---END---
---START---
-- partitioning key is updated, doesn't move the row.
UPDATE errtst SET a = 'aaa', b = NULL;
---END---
---START---
-- row is moved to another partition.
UPDATE errtst SET a = 'aaaa', b = NULL;
---END---
---START---
-- row is moved to another partition. This differs from the previous case in
-- that the new partition is excluded by constraint exclusion, so its
-- ResultRelInfo is not created at ExecInitModifyTable, but needs to be
-- constructed on the fly when the updated tuple is routed to it.
UPDATE errtst SET a = 'aaaa', b = NULL WHERE a = 'aaa';
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
DROP TABLE errtst;
---END---
---START---
-- test column-level privileges when involved with DELETE
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
ALTER TABLE atest6 ADD COLUMN three integer;
---END---
---START---
GRANT DELETE ON atest5 TO regress_priv_user3;
---END---
---START---
GRANT SELECT (two) ON atest5 TO regress_priv_user3;
---END---
---START---
REVOKE ALL (one) ON atest5 FROM regress_priv_user3;
---END---
---START---
GRANT SELECT (one) ON atest5 TO regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT atest6 FROM atest6;
---END---
---START---
-- fail
SELECT one FROM atest5 NATURAL JOIN atest6;
---END---
---START---
-- fail

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
ALTER TABLE atest6 DROP COLUMN three;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT atest6 FROM atest6;
---END---
---START---
-- ok
SELECT one FROM atest5 NATURAL JOIN atest6;
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
ALTER TABLE atest6 DROP COLUMN two;
---END---
---START---
REVOKE SELECT (one,blue) ON atest6 FROM regress_priv_user4;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT * FROM atest6;
---END---
---START---
-- fail
SELECT 1 FROM atest6;
---END---
---START---
-- fail

SET SESSION AUTHORIZATION regress_priv_user3;
---END---
---START---
DELETE FROM atest5 WHERE one = 1;
---END---
---START---
-- fail
DELETE FROM atest5 WHERE two = 2;
---END---
---START---
-- ok

-- check inheritance cases
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
CREATE TABLE atestp1 (f1 int, f2 int);
---END---
---START---
CREATE TABLE atestp2 (fx int, fy int);
---END---
---START---
CREATE TABLE atestc (fz int) INHERITS (atestp1, atestp2);
---END---
---START---
GRANT SELECT(fx,fy,tableoid) ON atestp2 TO regress_priv_user2;
---END---
---START---
GRANT SELECT(fx) ON atestc TO regress_priv_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT fx FROM atestp2;
---END---
---START---
-- ok
SELECT fy FROM atestp2;
---END---
---START---
-- ok
SELECT atestp2 FROM atestp2;
---END---
---START---
-- ok
SELECT tableoid FROM atestp2;
---END---
---START---
-- ok
SELECT fy FROM atestc;
---END---
---START---
-- fail

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT SELECT(fy,tableoid) ON atestc TO regress_priv_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT fx FROM atestp2;
---END---
---START---
-- still ok
SELECT fy FROM atestp2;
---END---
---START---
-- ok
SELECT atestp2 FROM atestp2;
---END---
---START---
-- ok
SELECT tableoid FROM atestp2;
---END---
---START---
-- ok

-- child's permissions do not apply when operating on parent
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
REVOKE ALL ON atestc FROM regress_priv_user2;
---END---
---START---
GRANT ALL ON atestp1 TO regress_priv_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT f2 FROM atestp1;
---END---
---START---
-- ok
SELECT f2 FROM atestc;
---END---
---START---
-- fail
DELETE FROM atestp1;
---END---
---START---
-- ok
DELETE FROM atestc;
---END---
---START---
-- fail
UPDATE atestp1 SET f1 = 1;
---END---
---START---
-- ok
UPDATE atestc SET f1 = 1;
---END---
---START---
-- fail
TRUNCATE atestp1;
---END---
---START---
-- ok
TRUNCATE atestc;
---END---
---START---
-- fail
BEGIN;
---END---
---START---
LOCK atestp1;
---END---
---START---
END;
---END---
---START---
BEGIN;
---END---
---START---
LOCK atestc;
---END---
---START---
END;
---END---
---START---
-- privileges on functions, languages

-- switch to superuser
\c -

REVOKE ALL PRIVILEGES ON LANGUAGE sql FROM PUBLIC;
---END---
---START---
GRANT USAGE ON LANGUAGE sql TO regress_priv_user1;
---END---
---START---
-- ok
GRANT USAGE ON LANGUAGE c TO PUBLIC;
---END---
---START---
-- fail

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT USAGE ON LANGUAGE sql TO regress_priv_user2;
---END---
---START---
-- fail
CREATE FUNCTION priv_testfunc1(int) RETURNS int AS 'select 2 * $1;' LANGUAGE sql;
---END---
---START---
CREATE FUNCTION priv_testfunc2(int) RETURNS int AS 'select 3 * $1;' LANGUAGE sql;
---END---
---START---
CREATE AGGREGATE priv_testagg1(int) (sfunc = int4pl, stype = int4);
---END---
---START---
CREATE PROCEDURE priv_testproc1(int) AS 'select $1;' LANGUAGE sql;
---END---
---START---
REVOKE ALL ON FUNCTION priv_testfunc1(int), priv_testfunc2(int), priv_testagg1(int) FROM PUBLIC;
---END---
---START---
GRANT EXECUTE ON FUNCTION priv_testfunc1(int), priv_testfunc2(int), priv_testagg1(int) TO regress_priv_user2;
---END---
---START---
REVOKE ALL ON FUNCTION priv_testproc1(int) FROM PUBLIC;
---END---
---START---
-- fail, not a function
REVOKE ALL ON PROCEDURE priv_testproc1(int) FROM PUBLIC;
---END---
---START---
GRANT EXECUTE ON PROCEDURE priv_testproc1(int) TO regress_priv_user2;
---END---
---START---
GRANT USAGE ON FUNCTION priv_testfunc1(int) TO regress_priv_user3;
---END---
---START---
-- semantic error
GRANT USAGE ON FUNCTION priv_testagg1(int) TO regress_priv_user3;
---END---
---START---
-- semantic error
GRANT USAGE ON PROCEDURE priv_testproc1(int) TO regress_priv_user3;
---END---
---START---
-- semantic error
GRANT ALL PRIVILEGES ON FUNCTION priv_testfunc1(int) TO regress_priv_user4;
---END---
---START---
GRANT ALL PRIVILEGES ON FUNCTION priv_testfunc_nosuch(int) TO regress_priv_user4;
---END---
---START---
GRANT ALL PRIVILEGES ON FUNCTION priv_testagg1(int) TO regress_priv_user4;
---END---
---START---
GRANT ALL PRIVILEGES ON PROCEDURE priv_testproc1(int) TO regress_priv_user4;
---END---
---START---
CREATE FUNCTION priv_testfunc4(boolean) RETURNS text
  AS 'select col1 from atest2 where col2 = $1;'
  LANGUAGE sql SECURITY DEFINER;
---END---
---START---
GRANT EXECUTE ON FUNCTION priv_testfunc4(boolean) TO regress_priv_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT priv_testfunc1(5), priv_testfunc2(5);
---END---
---START---
-- ok
CREATE FUNCTION priv_testfunc3(int) RETURNS int AS 'select 2 * $1;' LANGUAGE sql;
---END---
---START---
-- fail
SELECT priv_testagg1(x) FROM (VALUES (1), (2), (3)) _(x);
---END---
---START---
-- ok
CALL priv_testproc1(6);
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_priv_user3;
---END---
---START---
SELECT priv_testfunc1(5);
---END---
---START---
-- fail
SELECT priv_testagg1(x) FROM (VALUES (1), (2), (3)) _(x);
---END---
---START---
-- fail
CALL priv_testproc1(6);
---END---
---START---
-- fail
SELECT col1 FROM atest2 WHERE col2 = true;
---END---
---START---
-- fail
SELECT priv_testfunc4(true);
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT priv_testfunc1(5);
---END---
---START---
-- ok
SELECT priv_testagg1(x) FROM (VALUES (1), (2), (3)) _(x);
---END---
---START---
-- ok
CALL priv_testproc1(6);
---END---
---START---
-- ok

DROP FUNCTION priv_testfunc1(int);
---END---
---START---
-- fail
DROP AGGREGATE priv_testagg1(int);
---END---
---START---
-- fail
DROP PROCEDURE priv_testproc1(int);
---END---
---START---
-- fail

\c -

DROP FUNCTION priv_testfunc1(int);
---END---
---START---
-- ok
-- restore to sanity
GRANT ALL PRIVILEGES ON LANGUAGE sql TO PUBLIC;
---END---
---START---
-- verify privilege checks on array-element coercions
BEGIN;
---END---
---START---
SELECT '{1}'::int4[]::int8[];
---END---
---START---
REVOKE ALL ON FUNCTION int8(integer) FROM PUBLIC;
---END---
---START---
SELECT '{1}'::int4[]::int8[];
---END---
---START---
--superuser, succeed
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT '{1}'::int4[]::int8[];
---END---
---START---
--other user, fail
ROLLBACK;
---END---
---START---
-- privileges on types

-- switch to superuser
\c -

CREATE TYPE priv_testtype1 AS (a int, b text);
---END---
---START---
REVOKE USAGE ON TYPE priv_testtype1 FROM PUBLIC;
---END---
---START---
GRANT USAGE ON TYPE priv_testtype1 TO regress_priv_user2;
---END---
---START---
GRANT USAGE ON TYPE _priv_testtype1 TO regress_priv_user2;
---END---
---START---
-- fail
GRANT USAGE ON DOMAIN priv_testtype1 TO regress_priv_user2;
---END---
---START---
-- fail

CREATE DOMAIN priv_testdomain1 AS int;
---END---
---START---
REVOKE USAGE on DOMAIN priv_testdomain1 FROM PUBLIC;
---END---
---START---
GRANT USAGE ON DOMAIN priv_testdomain1 TO regress_priv_user2;
---END---
---START---
GRANT USAGE ON TYPE priv_testdomain1 TO regress_priv_user2;
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
-- commands that should fail

CREATE AGGREGATE priv_testagg1a(priv_testdomain1) (sfunc = int4_sum, stype = bigint);
---END---
---START---
CREATE DOMAIN priv_testdomain2a AS priv_testdomain1;
---END---
---START---
CREATE DOMAIN priv_testdomain3a AS int;
---END---
---START---
CREATE FUNCTION castfunc(int) RETURNS priv_testdomain3a AS $$ SELECT $1::priv_testdomain3a $$ LANGUAGE SQL;
---END---
---START---
CREATE CAST (priv_testdomain1 AS priv_testdomain3a) WITH FUNCTION castfunc(int);
---END---
---START---
DROP FUNCTION castfunc(int) CASCADE;
---END---
---START---
DROP DOMAIN priv_testdomain3a;
---END---
---START---
CREATE FUNCTION priv_testfunc5a(a priv_testdomain1) RETURNS int LANGUAGE SQL AS $$ SELECT $1 $$;
---END---
---START---
CREATE FUNCTION priv_testfunc6a(b int) RETURNS priv_testdomain1 LANGUAGE SQL AS $$ SELECT $1::priv_testdomain1 $$;
---END---
---START---
CREATE OPERATOR !+! (PROCEDURE = int4pl, LEFTARG = priv_testdomain1, RIGHTARG = priv_testdomain1);
---END---
---START---
CREATE TABLE test5a (a int, b priv_testdomain1);
---END---
---START---
CREATE TABLE test6a OF priv_testtype1;
---END---
---START---
CREATE TABLE test10a (a int[], b priv_testtype1[]);
---END---
---START---
CREATE TABLE test9a (a int, b int);
---END---
---START---
ALTER TABLE test9a ADD COLUMN c priv_testdomain1;
---END---
---START---
ALTER TABLE test9a ALTER COLUMN b TYPE priv_testdomain1;
---END---
---START---
CREATE TYPE test7a AS (a int, b priv_testdomain1);
---END---
---START---
CREATE TYPE test8a AS (a int, b int);
---END---
---START---
ALTER TYPE test8a ADD ATTRIBUTE c priv_testdomain1;
---END---
---START---
ALTER TYPE test8a ALTER ATTRIBUTE b TYPE priv_testdomain1;
---END---
---START---
CREATE TABLE test11a AS (SELECT 1::priv_testdomain1 AS a);
---END---
---START---
REVOKE ALL ON TYPE priv_testtype1 FROM PUBLIC;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
-- commands that should succeed

CREATE AGGREGATE priv_testagg1b(priv_testdomain1) (sfunc = int4_sum, stype = bigint);
---END---
---START---
CREATE DOMAIN priv_testdomain2b AS priv_testdomain1;
---END---
---START---
CREATE DOMAIN priv_testdomain3b AS int;
---END---
---START---
CREATE FUNCTION castfunc(int) RETURNS priv_testdomain3b AS $$ SELECT $1::priv_testdomain3b $$ LANGUAGE SQL;
---END---
---START---
CREATE CAST (priv_testdomain1 AS priv_testdomain3b) WITH FUNCTION castfunc(int);
---END---
---START---
CREATE FUNCTION priv_testfunc5b(a priv_testdomain1) RETURNS int LANGUAGE SQL AS $$ SELECT $1 $$;
---END---
---START---
CREATE FUNCTION priv_testfunc6b(b int) RETURNS priv_testdomain1 LANGUAGE SQL AS $$ SELECT $1::priv_testdomain1 $$;
---END---
---START---
CREATE OPERATOR !! (PROCEDURE = priv_testfunc5b, RIGHTARG = priv_testdomain1);
---END---
---START---
CREATE TABLE test5b (a int, b priv_testdomain1);
---END---
---START---
CREATE TABLE test6b OF priv_testtype1;
---END---
---START---
CREATE TABLE test10b (a int[], b priv_testtype1[]);
---END---
---START---
CREATE TABLE test9b (a int, b int);
---END---
---START---
ALTER TABLE test9b ADD COLUMN c priv_testdomain1;
---END---
---START---
ALTER TABLE test9b ALTER COLUMN b TYPE priv_testdomain1;
---END---
---START---
CREATE TYPE test7b AS (a int, b priv_testdomain1);
---END---
---START---
CREATE TYPE test8b AS (a int, b int);
---END---
---START---
ALTER TYPE test8b ADD ATTRIBUTE c priv_testdomain1;
---END---
---START---
ALTER TYPE test8b ALTER ATTRIBUTE b TYPE priv_testdomain1;
---END---
---START---
CREATE TABLE test11b AS (SELECT 1::priv_testdomain1 AS a);
---END---
---START---
REVOKE ALL ON TYPE priv_testtype1 FROM PUBLIC;
---END---
---START---
\c -
DROP AGGREGATE priv_testagg1b(priv_testdomain1);
---END---
---START---
DROP DOMAIN priv_testdomain2b;
---END---
---START---
DROP OPERATOR !! (NONE, priv_testdomain1);
---END---
---START---
DROP FUNCTION priv_testfunc5b(a priv_testdomain1);
---END---
---START---
DROP FUNCTION priv_testfunc6b(b int);
---END---
---START---
DROP TABLE test5b;
---END---
---START---
DROP TABLE test6b;
---END---
---START---
DROP TABLE test9b;
---END---
---START---
DROP TABLE test10b;
---END---
---START---
DROP TYPE test7b;
---END---
---START---
DROP TYPE test8b;
---END---
---START---
DROP CAST (priv_testdomain1 AS priv_testdomain3b);
---END---
---START---
DROP FUNCTION castfunc(int) CASCADE;
---END---
---START---
DROP DOMAIN priv_testdomain3b;
---END---
---START---
DROP TABLE test11b;
---END---
---START---
DROP TYPE priv_testtype1;
---END---
---START---
-- ok
DROP DOMAIN priv_testdomain1;
---END---
---START---
-- ok


-- truncate
SET SESSION AUTHORIZATION regress_priv_user5;
---END---
---START---
TRUNCATE atest2;
---END---
---START---
-- ok
TRUNCATE atest3;
---END---
---START---
-- fail

-- has_table_privilege function

-- bad-input checks
select has_table_privilege(NULL,'pg_authid','select');
---END---
---START---
select has_table_privilege('pg_shad','select');
---END---
---START---
select has_table_privilege('nosuchuser','pg_authid','select');
---END---
---START---
select has_table_privilege('pg_authid','sel');
---END---
---START---
select has_table_privilege(-999999,'pg_authid','update');
---END---
---START---
select has_table_privilege(1,'select');
---END---
---START---
-- superuser
\c -

select has_table_privilege(current_user,'pg_authid','select');
---END---
---START---
select has_table_privilege(current_user,'pg_authid','insert');
---END---
---START---
select has_table_privilege(t2.oid,'pg_authid','update')
from (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(t2.oid,'pg_authid','delete')
from (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
-- 'rule' privilege no longer exists, but for backwards compatibility
-- has_table_privilege still recognizes the keyword and says FALSE
select has_table_privilege(current_user,t1.oid,'rule')
from (select oid from pg_class where relname = 'pg_authid') as t1;
---END---
---START---
select has_table_privilege(current_user,t1.oid,'references')
from (select oid from pg_class where relname = 'pg_authid') as t1;
---END---
---START---
select has_table_privilege(t2.oid,t1.oid,'select')
from (select oid from pg_class where relname = 'pg_authid') as t1,
  (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(t2.oid,t1.oid,'insert')
from (select oid from pg_class where relname = 'pg_authid') as t1,
  (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege('pg_authid','update');
---END---
---START---
select has_table_privilege('pg_authid','delete');
---END---
---START---
select has_table_privilege('pg_authid','truncate');
---END---
---START---
select has_table_privilege(t1.oid,'select')
from (select oid from pg_class where relname = 'pg_authid') as t1;
---END---
---START---
select has_table_privilege(t1.oid,'trigger')
from (select oid from pg_class where relname = 'pg_authid') as t1;
---END---
---START---
-- non-superuser
SET SESSION AUTHORIZATION regress_priv_user3;
---END---
---START---
select has_table_privilege(current_user,'pg_class','select');
---END---
---START---
select has_table_privilege(current_user,'pg_class','insert');
---END---
---START---
select has_table_privilege(t2.oid,'pg_class','update')
from (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(t2.oid,'pg_class','delete')
from (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(current_user,t1.oid,'references')
from (select oid from pg_class where relname = 'pg_class') as t1;
---END---
---START---
select has_table_privilege(t2.oid,t1.oid,'select')
from (select oid from pg_class where relname = 'pg_class') as t1,
  (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(t2.oid,t1.oid,'insert')
from (select oid from pg_class where relname = 'pg_class') as t1,
  (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege('pg_class','update');
---END---
---START---
select has_table_privilege('pg_class','delete');
---END---
---START---
select has_table_privilege('pg_class','truncate');
---END---
---START---
select has_table_privilege(t1.oid,'select')
from (select oid from pg_class where relname = 'pg_class') as t1;
---END---
---START---
select has_table_privilege(t1.oid,'trigger')
from (select oid from pg_class where relname = 'pg_class') as t1;
---END---
---START---
select has_table_privilege(current_user,'atest1','select');
---END---
---START---
select has_table_privilege(current_user,'atest1','insert');
---END---
---START---
select has_table_privilege(t2.oid,'atest1','update')
from (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(t2.oid,'atest1','delete')
from (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(current_user,t1.oid,'references')
from (select oid from pg_class where relname = 'atest1') as t1;
---END---
---START---
select has_table_privilege(t2.oid,t1.oid,'select')
from (select oid from pg_class where relname = 'atest1') as t1,
  (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege(t2.oid,t1.oid,'insert')
from (select oid from pg_class where relname = 'atest1') as t1,
  (select oid from pg_roles where rolname = current_user) as t2;
---END---
---START---
select has_table_privilege('atest1','update');
---END---
---START---
select has_table_privilege('atest1','delete');
---END---
---START---
select has_table_privilege('atest1','truncate');
---END---
---START---
select has_table_privilege(t1.oid,'select')
from (select oid from pg_class where relname = 'atest1') as t1;
---END---
---START---
select has_table_privilege(t1.oid,'trigger')
from (select oid from pg_class where relname = 'atest1') as t1;
---END---
---START---
-- has_column_privilege function

-- bad-input checks (as non-super-user)
select has_column_privilege('pg_authid',NULL,'select');
---END---
---START---
select has_column_privilege('pg_authid','nosuchcol','select');
---END---
---START---
select has_column_privilege(9999,'nosuchcol','select');
---END---
---START---
select has_column_privilege(9999,99::int2,'select');
---END---
---START---
select has_column_privilege('pg_authid',99::int2,'select');
---END---
---START---
select has_column_privilege(9999,99::int2,'select');
---END---
---START---
create temp table mytable(f1 int, f2 int, f3 int);
---END---
---START---
alter table mytable drop column f2;
---END---
---START---
select has_column_privilege('mytable','f2','select');
---END---
---START---
select has_column_privilege('mytable','........pg.dropped.2........','select');
---END---
---START---
select has_column_privilege('mytable',2::int2,'select');
---END---
---START---
select has_column_privilege('mytable',99::int2,'select');
---END---
---START---
revoke select on table mytable from regress_priv_user3;
---END---
---START---
select has_column_privilege('mytable',2::int2,'select');
---END---
---START---
select has_column_privilege('mytable',99::int2,'select');
---END---
---START---
drop table mytable;
---END---
---START---
-- Grant options

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
CREATE TABLE atest4 (a int);
---END---
---START---
GRANT SELECT ON atest4 TO regress_priv_user2 WITH GRANT OPTION;
---END---
---START---
GRANT UPDATE ON atest4 TO regress_priv_user2;
---END---
---START---
GRANT SELECT ON atest4 TO GROUP regress_priv_group1 WITH GRANT OPTION;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
GRANT SELECT ON atest4 TO regress_priv_user3;
---END---
---START---
GRANT UPDATE ON atest4 TO regress_priv_user3;
---END---
---START---
-- fail

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
REVOKE SELECT ON atest4 FROM regress_priv_user3;
---END---
---START---
-- does nothing
SELECT has_table_privilege('regress_priv_user3', 'atest4', 'SELECT');
---END---
---START---
-- true
REVOKE SELECT ON atest4 FROM regress_priv_user2;
---END---
---START---
-- fail
REVOKE GRANT OPTION FOR SELECT ON atest4 FROM regress_priv_user2 CASCADE;
---END---
---START---
-- ok
SELECT has_table_privilege('regress_priv_user2', 'atest4', 'SELECT');
---END---
---START---
-- true
SELECT has_table_privilege('regress_priv_user3', 'atest4', 'SELECT');
---END---
---START---
-- false

SELECT has_table_privilege('regress_priv_user1', 'atest4', 'SELECT WITH GRANT OPTION');
---END---
---START---
-- true


-- security-restricted operations
\c -
CREATE ROLE regress_sro_user;
---END---
---START---
-- Check that index expressions and predicates are run as the table's owner

-- A dummy index function checking current_user
CREATE FUNCTION sro_ifun(int) RETURNS int AS $$
BEGIN
	-- Below we set the table's owner to regress_sro_user
	ASSERT current_user = 'regress_sro_user',
		format('sro_ifun(%s) called by %s', $1, current_user);
	RETURN $1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
---END---
---START---
-- Create a table owned by regress_sro_user
CREATE TABLE sro_tab (a int);
---END---
---START---
ALTER TABLE sro_tab OWNER TO regress_sro_user;
---END---
---START---
INSERT INTO sro_tab VALUES (1), (2), (3);
---END---
---START---
-- Create an expression index with a predicate
CREATE INDEX sro_idx ON sro_tab ((sro_ifun(a) + sro_ifun(0)))
	WHERE sro_ifun(a + 10) > sro_ifun(10);
---END---
---START---
DROP INDEX sro_idx;
---END---
---START---
-- Do the same concurrently
CREATE INDEX CONCURRENTLY sro_idx ON sro_tab ((sro_ifun(a) + sro_ifun(0)))
	WHERE sro_ifun(a + 10) > sro_ifun(10);
---END---
---START---
-- REINDEX
REINDEX TABLE sro_tab;
---END---
---START---
REINDEX INDEX sro_idx;
---END---
---START---
REINDEX TABLE CONCURRENTLY sro_tab;
---END---
---START---
DROP INDEX sro_idx;
---END---
---START---
-- CLUSTER
CREATE INDEX sro_cluster_idx ON sro_tab ((sro_ifun(a) + sro_ifun(0)));
---END---
---START---
CLUSTER sro_tab USING sro_cluster_idx;
---END---
---START---
DROP INDEX sro_cluster_idx;
---END---
---START---
-- BRIN index
CREATE INDEX sro_brin ON sro_tab USING brin ((sro_ifun(a) + sro_ifun(0)));
---END---
---START---
SELECT brin_desummarize_range('sro_brin', 0);
---END---
---START---
SELECT brin_summarize_range('sro_brin', 0);
---END---
---START---
DROP TABLE sro_tab;
---END---
---START---
-- Check with a partitioned table
CREATE TABLE sro_ptab (a int) PARTITION BY RANGE (a);
---END---
---START---
ALTER TABLE sro_ptab OWNER TO regress_sro_user;
---END---
---START---
CREATE TABLE sro_part PARTITION OF sro_ptab FOR VALUES FROM (1) TO (10);
---END---
---START---
ALTER TABLE sro_part OWNER TO regress_sro_user;
---END---
---START---
INSERT INTO sro_ptab VALUES (1), (2), (3);
---END---
---START---
CREATE INDEX sro_pidx ON sro_ptab ((sro_ifun(a) + sro_ifun(0)))
	WHERE sro_ifun(a + 10) > sro_ifun(10);
---END---
---START---
REINDEX TABLE sro_ptab;
---END---
---START---
REINDEX INDEX CONCURRENTLY sro_pidx;
---END---
---START---
SET SESSION AUTHORIZATION regress_sro_user;
---END---
---START---
CREATE FUNCTION unwanted_grant() RETURNS void LANGUAGE sql AS
	'GRANT regress_priv_group2 TO regress_sro_user';
---END---
---START---
CREATE FUNCTION mv_action() RETURNS bool LANGUAGE sql AS
	'DECLARE c CURSOR WITH HOLD FOR SELECT unwanted_grant(); SELECT true';
---END---
---START---
-- REFRESH of this MV will queue a GRANT at end of transaction
CREATE MATERIALIZED VIEW sro_mv AS SELECT mv_action() WITH NO DATA;
---END---
---START---
REFRESH MATERIALIZED VIEW sro_mv;
---END---
---START---
\c -
REFRESH MATERIALIZED VIEW sro_mv;
---END---
---START---
SET SESSION AUTHORIZATION regress_sro_user;
---END---
---START---
-- INSERT to this table will queue a GRANT at end of transaction
CREATE TABLE sro_trojan_table ();
---END---
---START---
CREATE FUNCTION sro_trojan() RETURNS trigger LANGUAGE plpgsql AS
	'BEGIN PERFORM unwanted_grant(); RETURN NULL; END';
---END---
---START---
CREATE CONSTRAINT TRIGGER t AFTER INSERT ON sro_trojan_table
    INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE sro_trojan();
---END---
---START---
-- Now, REFRESH will issue such an INSERT, queueing the GRANT
CREATE OR REPLACE FUNCTION mv_action() RETURNS bool LANGUAGE sql AS
	'INSERT INTO sro_trojan_table DEFAULT VALUES; SELECT true';
---END---
---START---
REFRESH MATERIALIZED VIEW sro_mv;
---END---
---START---
\c -
REFRESH MATERIALIZED VIEW sro_mv;
---END---
---START---
BEGIN;
---END---
---START---
SET CONSTRAINTS ALL IMMEDIATE;
---END---
---START---
REFRESH MATERIALIZED VIEW sro_mv;
---END---
---START---
COMMIT;
---END---
---START---
-- REFRESH MATERIALIZED VIEW CONCURRENTLY use of eval_const_expressions()
SET SESSION AUTHORIZATION regress_sro_user;
---END---
---START---
CREATE FUNCTION unwanted_grant_nofail(int) RETURNS int
	IMMUTABLE LANGUAGE plpgsql AS $$
BEGIN
	PERFORM unwanted_grant();
	RAISE WARNING 'owned';
	RETURN 1;
EXCEPTION WHEN OTHERS THEN
	RETURN 2;
END$$;
---END---
---START---
CREATE MATERIALIZED VIEW sro_index_mv AS SELECT 1 AS c;
---END---
---START---
CREATE UNIQUE INDEX ON sro_index_mv (c) WHERE unwanted_grant_nofail(1) > 0;
---END---
---START---
\c -
REFRESH MATERIALIZED VIEW CONCURRENTLY sro_index_mv;
---END---
---START---
REFRESH MATERIALIZED VIEW sro_index_mv;
---END---
---START---
DROP OWNED BY regress_sro_user;
---END---
---START---
DROP ROLE regress_sro_user;
---END---
---START---
-- Admin options

SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
CREATE FUNCTION dogrant_ok() RETURNS void LANGUAGE sql SECURITY DEFINER AS
	'GRANT regress_priv_group2 TO regress_priv_user5';
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user5;
---END---
---START---
-- ok: had ADMIN OPTION
SET ROLE regress_priv_group2;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user5;
---END---
---START---
-- fails: SET ROLE suspended privilege

SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user5;
---END---
---START---
-- fails: no ADMIN OPTION
SELECT dogrant_ok();
---END---
---START---
-- ok: SECURITY DEFINER conveys ADMIN
SET ROLE regress_priv_group2;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user5;
---END---
---START---
-- fails: SET ROLE did not help

SET SESSION AUTHORIZATION regress_priv_group2;
---END---
---START---
GRANT regress_priv_group2 TO regress_priv_user5;
---END---
---START---
-- fails: no self-admin

SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
DROP FUNCTION dogrant_ok();
---END---
---START---
REVOKE regress_priv_group2 FROM regress_priv_user5;
---END---
---START---
-- has_sequence_privilege tests
\c -

CREATE SEQUENCE x_seq;
---END---
---START---
GRANT USAGE on x_seq to regress_priv_user2;
---END---
---START---
SELECT has_sequence_privilege('regress_priv_user1', 'atest1', 'SELECT');
---END---
---START---
SELECT has_sequence_privilege('regress_priv_user1', 'x_seq', 'INSERT');
---END---
---START---
SELECT has_sequence_privilege('regress_priv_user1', 'x_seq', 'SELECT');
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT has_sequence_privilege('x_seq', 'USAGE');
---END---
---START---
-- largeobject privilege tests
\c -
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
SELECT lo_create(1001);
---END---
---START---
SELECT lo_create(1002);
---END---
---START---
SELECT lo_create(1003);
---END---
---START---
SELECT lo_create(1004);
---END---
---START---
SELECT lo_create(1005);
---END---
---START---
GRANT ALL ON LARGE OBJECT 1001 TO PUBLIC;
---END---
---START---
GRANT SELECT ON LARGE OBJECT 1003 TO regress_priv_user2;
---END---
---START---
GRANT SELECT,UPDATE ON LARGE OBJECT 1004 TO regress_priv_user2;
---END---
---START---
GRANT ALL ON LARGE OBJECT 1005 TO regress_priv_user2;
---END---
---START---
GRANT SELECT ON LARGE OBJECT 1005 TO regress_priv_user2 WITH GRANT OPTION;
---END---
---START---
GRANT SELECT, INSERT ON LARGE OBJECT 1001 TO PUBLIC;
---END---
---START---
-- to be failed
GRANT SELECT, UPDATE ON LARGE OBJECT 1001 TO nosuchuser;
---END---
---START---
-- to be failed
GRANT SELECT, UPDATE ON LARGE OBJECT  999 TO PUBLIC;
---END---
---START---
-- to be failed

\c -
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
SELECT lo_create(2001);
---END---
---START---
SELECT lo_create(2002);
---END---
---START---
SELECT loread(lo_open(1001, x'20000'::int), 32);
---END---
---START---
-- allowed, for now
SELECT lowrite(lo_open(1001, x'40000'::int), 'abcd');
---END---
---START---
-- fail, wrong mode

SELECT loread(lo_open(1001, x'40000'::int), 32);
---END---
---START---
SELECT loread(lo_open(1002, x'40000'::int), 32);
---END---
---START---
-- to be denied
SELECT loread(lo_open(1003, x'40000'::int), 32);
---END---
---START---
SELECT loread(lo_open(1004, x'40000'::int), 32);
---END---
---START---
SELECT lowrite(lo_open(1001, x'20000'::int), 'abcd');
---END---
---START---
SELECT lowrite(lo_open(1002, x'20000'::int), 'abcd');
---END---
---START---
-- to be denied
SELECT lowrite(lo_open(1003, x'20000'::int), 'abcd');
---END---
---START---
-- to be denied
SELECT lowrite(lo_open(1004, x'20000'::int), 'abcd');
---END---
---START---
GRANT SELECT ON LARGE OBJECT 1005 TO regress_priv_user3;
---END---
---START---
GRANT UPDATE ON LARGE OBJECT 1006 TO regress_priv_user3;
---END---
---START---
-- to be denied
REVOKE ALL ON LARGE OBJECT 2001, 2002 FROM PUBLIC;
---END---
---START---
GRANT ALL ON LARGE OBJECT 2001 TO regress_priv_user3;
---END---
---START---
SELECT lo_unlink(1001);
---END---
---START---
-- to be denied
SELECT lo_unlink(2002);
---END---
---START---
\c -
-- confirm ACL setting
SELECT oid, pg_get_userbyid(lomowner) ownername, lomacl FROM pg_largeobject_metadata WHERE oid >= 1000 AND oid < 3000 ORDER BY oid;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user3;
---END---
---START---
SELECT loread(lo_open(1001, x'40000'::int), 32);
---END---
---START---
SELECT loread(lo_open(1003, x'40000'::int), 32);
---END---
---START---
-- to be denied
SELECT loread(lo_open(1005, x'40000'::int), 32);
---END---
---START---
SELECT lo_truncate(lo_open(1005, x'20000'::int), 10);
---END---
---START---
-- to be denied
SELECT lo_truncate(lo_open(2001, x'20000'::int), 10);
---END---
---START---
-- compatibility mode in largeobject permission
\c -
SET lo_compat_privileges = false;
---END---
---START---
-- default setting
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT loread(lo_open(1002, x'40000'::int), 32);
---END---
---START---
-- to be denied
SELECT lowrite(lo_open(1002, x'20000'::int), 'abcd');
---END---
---START---
-- to be denied
SELECT lo_truncate(lo_open(1002, x'20000'::int), 10);
---END---
---START---
-- to be denied
SELECT lo_put(1002, 1, 'abcd');
---END---
---START---
-- to be denied
SELECT lo_unlink(1002);
---END---
---START---
-- to be denied
SELECT lo_export(1001, '/dev/null');
---END---
---START---
-- to be denied
SELECT lo_import('/dev/null');
---END---
---START---
-- to be denied
SELECT lo_import('/dev/null', 2003);
---END---
---START---
-- to be denied

\c -
SET lo_compat_privileges = true;
---END---
---START---
-- compatibility mode
SET SESSION AUTHORIZATION regress_priv_user4;
---END---
---START---
SELECT loread(lo_open(1002, x'40000'::int), 32);
---END---
---START---
SELECT lowrite(lo_open(1002, x'20000'::int), 'abcd');
---END---
---START---
SELECT lo_truncate(lo_open(1002, x'20000'::int), 10);
---END---
---START---
SELECT lo_unlink(1002);
---END---
---START---
SELECT lo_export(1001, '/dev/null');
---END---
---START---
-- to be denied

-- don't allow unpriv users to access pg_largeobject contents
\c -
SELECT * FROM pg_largeobject LIMIT 0;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
SELECT * FROM pg_largeobject LIMIT 0;
---END---
---START---
-- to be denied

-- test pg_database_owner
RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT pg_database_owner TO regress_priv_user1;
---END---
---START---
GRANT regress_priv_user1 TO pg_database_owner;
---END---
---START---
CREATE TABLE datdba_only ();
---END---
---START---
ALTER TABLE datdba_only OWNER TO pg_database_owner;
---END---
---START---
REVOKE DELETE ON datdba_only FROM pg_database_owner;
---END---
---START---
SELECT
	pg_has_role('regress_priv_user1', 'pg_database_owner', 'USAGE') as priv,
	pg_has_role('regress_priv_user1', 'pg_database_owner', 'MEMBER') as mem,
	pg_has_role('regress_priv_user1', 'pg_database_owner',
				'MEMBER WITH ADMIN OPTION') as admin;
---END---
---START---
BEGIN;
---END---
---START---
DO $$BEGIN EXECUTE format(
	'ALTER DATABASE %I OWNER TO regress_priv_group2', current_catalog); END$$;
---END---
---START---
SELECT
	pg_has_role('regress_priv_user1', 'pg_database_owner', 'USAGE') as priv,
	pg_has_role('regress_priv_user1', 'pg_database_owner', 'MEMBER') as mem,
	pg_has_role('regress_priv_user1', 'pg_database_owner',
				'MEMBER WITH ADMIN OPTION') as admin;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user1;
---END---
---START---
TABLE information_schema.enabled_roles ORDER BY role_name COLLATE "C";
---END---
---START---
TABLE information_schema.applicable_roles ORDER BY role_name COLLATE "C";
---END---
---START---
INSERT INTO datdba_only DEFAULT VALUES;
---END---
---START---
SAVEPOINT q;
---END---
---START---
DELETE FROM datdba_only;
---END---
---START---
ROLLBACK TO q;
---END---
---START---
SET SESSION AUTHORIZATION regress_priv_user2;
---END---
---START---
TABLE information_schema.enabled_roles;
---END---
---START---
INSERT INTO datdba_only DEFAULT VALUES;
---END---
---START---
ROLLBACK;
---END---
---START---
-- test default ACLs
\c -

CREATE SCHEMA testns;
---END---
---START---
GRANT ALL ON SCHEMA testns TO regress_priv_user1;
---END---
---START---
CREATE TABLE testns.acltest1 (x int);
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'SELECT');
---END---
---START---
-- no
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'INSERT');
---END---
---START---
-- no

-- placeholder for test with duplicated schema and role names
ALTER DEFAULT PRIVILEGES IN SCHEMA testns,testns GRANT SELECT ON TABLES TO public,public;
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'SELECT');
---END---
---START---
-- no
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'INSERT');
---END---
---START---
-- no

DROP TABLE testns.acltest1;
---END---
---START---
CREATE TABLE testns.acltest1 (x int);
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'SELECT');
---END---
---START---
-- yes
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'INSERT');
---END---
---START---
-- no

ALTER DEFAULT PRIVILEGES IN SCHEMA testns GRANT INSERT ON TABLES TO regress_priv_user1;
---END---
---START---
DROP TABLE testns.acltest1;
---END---
---START---
CREATE TABLE testns.acltest1 (x int);
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'SELECT');
---END---
---START---
-- yes
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'INSERT');
---END---
---START---
-- yes

ALTER DEFAULT PRIVILEGES IN SCHEMA testns REVOKE INSERT ON TABLES FROM regress_priv_user1;
---END---
---START---
DROP TABLE testns.acltest1;
---END---
---START---
CREATE TABLE testns.acltest1 (x int);
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'SELECT');
---END---
---START---
-- yes
SELECT has_table_privilege('regress_priv_user1', 'testns.acltest1', 'INSERT');
---END---
---START---
-- no

ALTER DEFAULT PRIVILEGES FOR ROLE regress_priv_user1 REVOKE EXECUTE ON FUNCTIONS FROM public;
---END---
---START---
ALTER DEFAULT PRIVILEGES IN SCHEMA testns GRANT USAGE ON SCHEMAS TO regress_priv_user2;
---END---
---START---
-- error

-- Test makeaclitem()
SELECT makeaclitem('regress_priv_user1'::regrole, 'regress_priv_user2'::regrole,
	'SELECT', TRUE);
---END---
---START---
-- single privilege
SELECT makeaclitem('regress_priv_user1'::regrole, 'regress_priv_user2'::regrole,
	'SELECT, INSERT,  UPDATE , DELETE  ', FALSE);
---END---
---START---
-- multiple privileges
SELECT makeaclitem('regress_priv_user1'::regrole, 'regress_priv_user2'::regrole,
	'SELECT, fake_privilege', FALSE);
---END---
---START---
-- error

-- Test non-throwing aclitem I/O
SELECT pg_input_is_valid('regress_priv_user1=r/regress_priv_user2', 'aclitem');
---END---
---START---
SELECT pg_input_is_valid('regress_priv_user1=r/', 'aclitem');
---END---
---START---
SELECT * FROM pg_input_error_info('regress_priv_user1=r/', 'aclitem');
---END---
---START---
SELECT pg_input_is_valid('regress_priv_user1=r/regress_no_such_user', 'aclitem');
---END---
---START---
SELECT * FROM pg_input_error_info('regress_priv_user1=r/regress_no_such_user', 'aclitem');
---END---
---START---
SELECT pg_input_is_valid('regress_priv_user1=rY', 'aclitem');
---END---
---START---
SELECT * FROM pg_input_error_info('regress_priv_user1=rY', 'aclitem');
---END---
---START---
--
-- Testing blanket default grants is very hazardous since it might change
-- the privileges attached to objects created by concurrent regression tests.
-- To avoid that, be sure to revoke the privileges again before committing.
--
BEGIN;
---END---
---START---
ALTER DEFAULT PRIVILEGES GRANT USAGE ON SCHEMAS TO regress_priv_user2;
---END---
---START---
CREATE SCHEMA testns2;
---END---
---START---
SELECT has_schema_privilege('regress_priv_user2', 'testns2', 'USAGE');
---END---
---START---
-- yes
SELECT has_schema_privilege('regress_priv_user6', 'testns2', 'USAGE');
---END---
---START---
-- yes
SELECT has_schema_privilege('regress_priv_user2', 'testns2', 'CREATE');
---END---
---START---
-- no

ALTER DEFAULT PRIVILEGES REVOKE USAGE ON SCHEMAS FROM regress_priv_user2;
---END---
---START---
CREATE SCHEMA testns3;
---END---
---START---
SELECT has_schema_privilege('regress_priv_user2', 'testns3', 'USAGE');
---END---
---START---
-- no
SELECT has_schema_privilege('regress_priv_user2', 'testns3', 'CREATE');
---END---
---START---
-- no

ALTER DEFAULT PRIVILEGES GRANT ALL ON SCHEMAS TO regress_priv_user2;
---END---
---START---
CREATE SCHEMA testns4;
---END---
---START---
SELECT has_schema_privilege('regress_priv_user2', 'testns4', 'USAGE');
---END---
---START---
-- yes
SELECT has_schema_privilege('regress_priv_user2', 'testns4', 'CREATE');
---END---
---START---
-- yes

ALTER DEFAULT PRIVILEGES REVOKE ALL ON SCHEMAS FROM regress_priv_user2;
---END---
---START---
COMMIT;
---END---
---START---
-- Test for DROP OWNED BY with shared dependencies.  This is done in a
-- separate, rollbacked, transaction to avoid any trouble with other
-- regression sessions.
BEGIN;
---END---
---START---
ALTER DEFAULT PRIVILEGES GRANT ALL ON FUNCTIONS TO regress_priv_user2;
---END---
---START---
ALTER DEFAULT PRIVILEGES GRANT ALL ON SCHEMAS TO regress_priv_user2;
---END---
---START---
ALTER DEFAULT PRIVILEGES GRANT ALL ON SEQUENCES TO regress_priv_user2;
---END---
---START---
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO regress_priv_user2;
---END---
---START---
ALTER DEFAULT PRIVILEGES GRANT ALL ON TYPES TO regress_priv_user2;
---END---
---START---
SELECT count(*) FROM pg_shdepend
  WHERE deptype = 'a' AND
        refobjid = 'regress_priv_user2'::regrole AND
	classid = 'pg_default_acl'::regclass;
---END---
---START---
DROP OWNED BY regress_priv_user2, regress_priv_user2;
---END---
---START---
SELECT count(*) FROM pg_shdepend
  WHERE deptype = 'a' AND
        refobjid = 'regress_priv_user2'::regrole AND
	classid = 'pg_default_acl'::regclass;
---END---
---START---
ROLLBACK;
---END---
---START---
CREATE SCHEMA testns5;
---END---
---START---
SELECT has_schema_privilege('regress_priv_user2', 'testns5', 'USAGE');
---END---
---START---
-- no
SELECT has_schema_privilege('regress_priv_user2', 'testns5', 'CREATE');
---END---
---START---
-- no

SET ROLE regress_priv_user1;
---END---
---START---
CREATE FUNCTION testns.foo() RETURNS int AS 'select 1' LANGUAGE sql;
---END---
---START---
CREATE AGGREGATE testns.agg1(int) (sfunc = int4pl, stype = int4);
---END---
---START---
CREATE PROCEDURE testns.bar() AS 'select 1' LANGUAGE sql;
---END---
---START---
SELECT has_function_privilege('regress_priv_user2', 'testns.foo()', 'EXECUTE');
---END---
---START---
-- no
SELECT has_function_privilege('regress_priv_user2', 'testns.agg1(int)', 'EXECUTE');
---END---
---START---
-- no
SELECT has_function_privilege('regress_priv_user2', 'testns.bar()', 'EXECUTE');
---END---
---START---
-- no

ALTER DEFAULT PRIVILEGES IN SCHEMA testns GRANT EXECUTE ON ROUTINES to public;
---END---
---START---
DROP FUNCTION testns.foo();
---END---
---START---
CREATE FUNCTION testns.foo() RETURNS int AS 'select 1' LANGUAGE sql;
---END---
---START---
DROP AGGREGATE testns.agg1(int);
---END---
---START---
CREATE AGGREGATE testns.agg1(int) (sfunc = int4pl, stype = int4);
---END---
---START---
DROP PROCEDURE testns.bar();
---END---
---START---
CREATE PROCEDURE testns.bar() AS 'select 1' LANGUAGE sql;
---END---
---START---
SELECT has_function_privilege('regress_priv_user2', 'testns.foo()', 'EXECUTE');
---END---
---START---
-- yes
SELECT has_function_privilege('regress_priv_user2', 'testns.agg1(int)', 'EXECUTE');
---END---
---START---
-- yes
SELECT has_function_privilege('regress_priv_user2', 'testns.bar()', 'EXECUTE');
---END---
---START---
-- yes (counts as function here)

DROP FUNCTION testns.foo();
---END---
---START---
DROP AGGREGATE testns.agg1(int);
---END---
---START---
DROP PROCEDURE testns.bar();
---END---
---START---
ALTER DEFAULT PRIVILEGES FOR ROLE regress_priv_user1 REVOKE USAGE ON TYPES FROM public;
---END---
---START---
CREATE DOMAIN testns.priv_testdomain1 AS int;
---END---
---START---
SELECT has_type_privilege('regress_priv_user2', 'testns.priv_testdomain1', 'USAGE');
---END---
---START---
-- no

ALTER DEFAULT PRIVILEGES IN SCHEMA testns GRANT USAGE ON TYPES to public;
---END---
---START---
DROP DOMAIN testns.priv_testdomain1;
---END---
---START---
CREATE DOMAIN testns.priv_testdomain1 AS int;
---END---
---START---
SELECT has_type_privilege('regress_priv_user2', 'testns.priv_testdomain1', 'USAGE');
---END---
---START---
-- yes

DROP DOMAIN testns.priv_testdomain1;
---END---
---START---
RESET ROLE;
---END---
---START---
SELECT count(*)
  FROM pg_default_acl d LEFT JOIN pg_namespace n ON defaclnamespace = n.oid
  WHERE nspname = 'testns';
---END---
---START---
DROP SCHEMA testns CASCADE;
---END---
---START---
DROP SCHEMA testns2 CASCADE;
---END---
---START---
DROP SCHEMA testns3 CASCADE;
---END---
---START---
DROP SCHEMA testns4 CASCADE;
---END---
---START---
DROP SCHEMA testns5 CASCADE;
---END---
---START---
SELECT d.*     -- check that entries went away
  FROM pg_default_acl d LEFT JOIN pg_namespace n ON defaclnamespace = n.oid
  WHERE nspname IS NULL AND defaclnamespace != 0;
---END---
---START---
-- Grant on all objects of given type in a schema
\c -

CREATE SCHEMA testns;
---END---
---START---
CREATE TABLE testns.t1 (f1 int);
---END---
---START---
CREATE TABLE testns.t2 (f1 int);
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.t1', 'SELECT');
---END---
---START---
-- false

GRANT ALL ON ALL TABLES IN SCHEMA testns TO regress_priv_user1;
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.t1', 'SELECT');
---END---
---START---
-- true
SELECT has_table_privilege('regress_priv_user1', 'testns.t2', 'SELECT');
---END---
---START---
-- true

REVOKE ALL ON ALL TABLES IN SCHEMA testns FROM regress_priv_user1;
---END---
---START---
SELECT has_table_privilege('regress_priv_user1', 'testns.t1', 'SELECT');
---END---
---START---
-- false
SELECT has_table_privilege('regress_priv_user1', 'testns.t2', 'SELECT');
---END---
---START---
-- false

CREATE FUNCTION testns.priv_testfunc(int) RETURNS int AS 'select 3 * $1;' LANGUAGE sql;
---END---
---START---
CREATE AGGREGATE testns.priv_testagg(int) (sfunc = int4pl, stype = int4);
---END---
---START---
CREATE PROCEDURE testns.priv_testproc(int) AS 'select 3' LANGUAGE sql;
---END---
---START---
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testfunc(int)', 'EXECUTE');
---END---
---START---
-- true by default
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testagg(int)', 'EXECUTE');
---END---
---START---
-- true by default
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testproc(int)', 'EXECUTE');
---END---
---START---
-- true by default

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA testns FROM PUBLIC;
---END---
---START---
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testfunc(int)', 'EXECUTE');
---END---
---START---
-- false
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testagg(int)', 'EXECUTE');
---END---
---START---
-- false
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testproc(int)', 'EXECUTE');
---END---
---START---
-- still true, not a function

REVOKE ALL ON ALL PROCEDURES IN SCHEMA testns FROM PUBLIC;
---END---
---START---
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testproc(int)', 'EXECUTE');
---END---
---START---
-- now false

GRANT ALL ON ALL ROUTINES IN SCHEMA testns TO PUBLIC;
---END---
---START---
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testfunc(int)', 'EXECUTE');
---END---
---START---
-- true
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testagg(int)', 'EXECUTE');
---END---
---START---
-- true
SELECT has_function_privilege('regress_priv_user1', 'testns.priv_testproc(int)', 'EXECUTE');
---END---
---START---
-- true

DROP SCHEMA testns CASCADE;
---END---
---START---
-- Change owner of the schema & and rename of new schema owner
\c -

CREATE ROLE regress_schemauser1 superuser login;
---END---
---START---
CREATE ROLE regress_schemauser2 superuser login;
---END---
---START---
SET SESSION ROLE regress_schemauser1;
---END---
---START---
CREATE SCHEMA testns;
---END---
---START---
SELECT nspname, rolname FROM pg_namespace, pg_roles WHERE pg_namespace.nspname = 'testns' AND pg_namespace.nspowner = pg_roles.oid;
---END---
---START---
ALTER SCHEMA testns OWNER TO regress_schemauser2;
---END---
---START---
ALTER ROLE regress_schemauser2 RENAME TO regress_schemauser_renamed;
---END---
---START---
SELECT nspname, rolname FROM pg_namespace, pg_roles WHERE pg_namespace.nspname = 'testns' AND pg_namespace.nspowner = pg_roles.oid;
---END---
---START---
set session role regress_schemauser_renamed;
---END---
---START---
DROP SCHEMA testns CASCADE;
---END---
---START---
-- clean up
\c -

DROP ROLE regress_schemauser1;
---END---
---START---
DROP ROLE regress_schemauser_renamed;
---END---
---START---
-- test that dependent privileges are revoked (or not) properly
\c -

set session role regress_priv_user1;
---END---
---START---
create table dep_priv_test (a int);
---END---
---START---
grant select on dep_priv_test to regress_priv_user2 with grant option;
---END---
---START---
grant select on dep_priv_test to regress_priv_user3 with grant option;
---END---
---START---
set session role regress_priv_user2;
---END---
---START---
grant select on dep_priv_test to regress_priv_user4 with grant option;
---END---
---START---
set session role regress_priv_user3;
---END---
---START---
grant select on dep_priv_test to regress_priv_user4 with grant option;
---END---
---START---
set session role regress_priv_user4;
---END---
---START---
grant select on dep_priv_test to regress_priv_user5;
---END---
---START---
\dp dep_priv_test
set session role regress_priv_user2;
---END---
---START---
revoke select on dep_priv_test from regress_priv_user4 cascade;
---END---
---START---
\dp dep_priv_test
set session role regress_priv_user3;
---END---
---START---
revoke select on dep_priv_test from regress_priv_user4 cascade;
---END---
---START---
\dp dep_priv_test
set session role regress_priv_user1;
---END---
---START---
drop table dep_priv_test;
---END---
---START---
-- clean up

\c

drop sequence x_seq;
---END---
---START---
DROP AGGREGATE priv_testagg1(int);
---END---
---START---
DROP FUNCTION priv_testfunc2(int);
---END---
---START---
DROP FUNCTION priv_testfunc4(boolean);
---END---
---START---
DROP PROCEDURE priv_testproc1(int);
---END---
---START---
DROP VIEW atestv0;
---END---
---START---
DROP VIEW atestv1;
---END---
---START---
DROP VIEW atestv2;
---END---
---START---
-- this should cascade to drop atestv4
DROP VIEW atestv3 CASCADE;
---END---
---START---
-- this should complain "does not exist"
DROP VIEW atestv4;
---END---
---START---
DROP TABLE atest1;
---END---
---START---
DROP TABLE atest2;
---END---
---START---
DROP TABLE atest3;
---END---
---START---
DROP TABLE atest4;
---END---
---START---
DROP TABLE atest5;
---END---
---START---
DROP TABLE atest6;
---END---
---START---
DROP TABLE atestc;
---END---
---START---
DROP TABLE atestp1;
---END---
---START---
DROP TABLE atestp2;
---END---
---START---
SELECT lo_unlink(oid) FROM pg_largeobject_metadata WHERE oid >= 1000 AND oid < 3000 ORDER BY oid;
---END---
---START---
DROP GROUP regress_priv_group1;
---END---
---START---
DROP GROUP regress_priv_group2;
---END---
---START---
-- these are needed to clean up permissions
REVOKE USAGE ON LANGUAGE sql FROM regress_priv_user1;
---END---
---START---
DROP OWNED BY regress_priv_user1;
---END---
---START---
DROP USER regress_priv_user1;
---END---
---START---
DROP USER regress_priv_user2;
---END---
---START---
DROP USER regress_priv_user3;
---END---
---START---
DROP USER regress_priv_user4;
---END---
---START---
DROP USER regress_priv_user5;
---END---
---START---
DROP USER regress_priv_user6;
---END---
---START---
DROP USER regress_priv_user7;
---END---
---START---
DROP USER regress_priv_user8;
---END---
---START---
-- does not exist


-- permissions with LOCK TABLE
CREATE USER regress_locktable_user;
---END---
---START---
CREATE TABLE lock_table (a int);
---END---
---START---
-- LOCK TABLE and SELECT permission
GRANT SELECT ON lock_table TO regress_locktable_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_locktable_user;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS SHARE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ROW EXCLUSIVE MODE;
---END---
---START---
-- should fail
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- should fail
ROLLBACK;
---END---
---START---
\c
REVOKE SELECT ON lock_table FROM regress_locktable_user;
---END---
---START---
-- LOCK TABLE and INSERT permission
GRANT INSERT ON lock_table TO regress_locktable_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_locktable_user;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS SHARE MODE;
---END---
---START---
-- should pass
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ROW EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- should fail
ROLLBACK;
---END---
---START---
\c
REVOKE INSERT ON lock_table FROM regress_locktable_user;
---END---
---START---
-- LOCK TABLE and UPDATE permission
GRANT UPDATE ON lock_table TO regress_locktable_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_locktable_user;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS SHARE MODE;
---END---
---START---
-- should pass
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ROW EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
\c
REVOKE UPDATE ON lock_table FROM regress_locktable_user;
---END---
---START---
-- LOCK TABLE and DELETE permission
GRANT DELETE ON lock_table TO regress_locktable_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_locktable_user;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS SHARE MODE;
---END---
---START---
-- should pass
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ROW EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
\c
REVOKE DELETE ON lock_table FROM regress_locktable_user;
---END---
---START---
-- LOCK TABLE and TRUNCATE permission
GRANT TRUNCATE ON lock_table TO regress_locktable_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_locktable_user;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS SHARE MODE;
---END---
---START---
-- should pass
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ROW EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
LOCK TABLE lock_table IN ACCESS EXCLUSIVE MODE;
---END---
---START---
-- should pass
COMMIT;
---END---
---START---
\c
REVOKE TRUNCATE ON lock_table FROM regress_locktable_user;
---END---
---START---
-- clean up
DROP TABLE lock_table;
---END---
---START---
DROP USER regress_locktable_user;
---END---
---START---
-- test to check privileges of system views pg_shmem_allocations and
-- pg_backend_memory_contexts.

-- switch to superuser
\c -

CREATE ROLE regress_readallstats;
---END---
---START---
SELECT has_table_privilege('regress_readallstats','pg_backend_memory_contexts','SELECT');
---END---
---START---
-- no
SELECT has_table_privilege('regress_readallstats','pg_shmem_allocations','SELECT');
---END---
---START---
-- no

GRANT pg_read_all_stats TO regress_readallstats;
---END---
---START---
SELECT has_table_privilege('regress_readallstats','pg_backend_memory_contexts','SELECT');
---END---
---START---
-- yes
SELECT has_table_privilege('regress_readallstats','pg_shmem_allocations','SELECT');
---END---
---START---
-- yes

-- run query to ensure that functions within views can be executed
SET ROLE regress_readallstats;
---END---
---START---
SELECT COUNT(*) >= 0 AS ok FROM pg_backend_memory_contexts;
---END---
---START---
SELECT COUNT(*) >= 0 AS ok FROM pg_shmem_allocations;
---END---
---START---
RESET ROLE;
---END---
---START---
-- clean up
DROP ROLE regress_readallstats;
---END---
---START---
-- test role grantor machinery
CREATE ROLE regress_group;
---END---
---START---
CREATE ROLE regress_group_direct_manager;
---END---
---START---
CREATE ROLE regress_group_indirect_manager;
---END---
---START---
CREATE ROLE regress_group_member;
---END---
---START---
GRANT regress_group TO regress_group_direct_manager WITH INHERIT FALSE, ADMIN TRUE;
---END---
---START---
GRANT regress_group_direct_manager TO regress_group_indirect_manager;
---END---
---START---
SET SESSION AUTHORIZATION regress_group_direct_manager;
---END---
---START---
GRANT regress_group TO regress_group_member;
---END---
---START---
SELECT member::regrole::text, CASE WHEN grantor = 10 THEN 'BOOTSTRAP SUPERUSER' ELSE grantor::regrole::text END FROM pg_auth_members WHERE roleid = 'regress_group'::regrole ORDER BY 1, 2;
---END---
---START---
REVOKE regress_group FROM regress_group_member;
---END---
---START---
SET SESSION AUTHORIZATION regress_group_indirect_manager;
---END---
---START---
GRANT regress_group TO regress_group_member;
---END---
---START---
SELECT member::regrole::text, CASE WHEN grantor = 10 THEN 'BOOTSTRAP SUPERUSER' ELSE grantor::regrole::text END FROM pg_auth_members WHERE roleid = 'regress_group'::regrole ORDER BY 1, 2;
---END---
---START---
REVOKE regress_group FROM regress_group_member;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP ROLE regress_group;
---END---
---START---
DROP ROLE regress_group_direct_manager;
---END---
---START---
DROP ROLE regress_group_indirect_manager;
---END---
---START---
DROP ROLE regress_group_member;
---END---
---START---
-- test SET and INHERIT options with object ownership changes
CREATE ROLE regress_roleoption_protagonist;
---END---
---START---
CREATE ROLE regress_roleoption_donor;
---END---
---START---
CREATE ROLE regress_roleoption_recipient;
---END---
---START---
CREATE SCHEMA regress_roleoption;
---END---
---START---
GRANT CREATE, USAGE ON SCHEMA regress_roleoption TO PUBLIC;
---END---
---START---
GRANT regress_roleoption_donor TO regress_roleoption_protagonist WITH INHERIT TRUE, SET FALSE;
---END---
---START---
GRANT regress_roleoption_recipient TO regress_roleoption_protagonist WITH INHERIT FALSE, SET TRUE;
---END---
---START---
SET SESSION AUTHORIZATION regress_roleoption_protagonist;
---END---
---START---
CREATE TABLE regress_roleoption.t1 (a int);
---END---
---START---
CREATE TABLE regress_roleoption.t2 (a int);
---END---
---START---
SET SESSION AUTHORIZATION regress_roleoption_donor;
---END---
---START---
CREATE TABLE regress_roleoption.t3 (a int);
---END---
---START---
SET SESSION AUTHORIZATION regress_roleoption_recipient;
---END---
---START---
CREATE TABLE regress_roleoption.t4 (a int);
---END---
---START---
SET SESSION AUTHORIZATION regress_roleoption_protagonist;
---END---
---START---
ALTER TABLE regress_roleoption.t1 OWNER TO regress_roleoption_donor;
---END---
---START---
-- fails, can't be come donor
ALTER TABLE regress_roleoption.t2 OWNER TO regress_roleoption_recipient;
---END---
---START---
-- works
ALTER TABLE regress_roleoption.t3 OWNER TO regress_roleoption_protagonist;
---END---
---START---
-- works
ALTER TABLE regress_roleoption.t4 OWNER TO regress_roleoption_protagonist;
---END---
---START---
-- fails, we don't inherit from recipient
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE regress_roleoption.t1;
---END---
---START---
DROP TABLE regress_roleoption.t2;
---END---
---START---
DROP TABLE regress_roleoption.t3;
---END---
---START---
DROP TABLE regress_roleoption.t4;
---END---
---START---
DROP SCHEMA regress_roleoption;
---END---
---START---
DROP ROLE regress_roleoption_protagonist;
---END---
---START---
DROP ROLE regress_roleoption_donor;
---END---
---START---
DROP ROLE regress_roleoption_recipient;
---END---
