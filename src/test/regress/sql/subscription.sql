---START---
--
-- SUBSCRIPTION
--

CREATE ROLE regress_subscription_user LOGIN SUPERUSER;
---END---
---START---
CREATE ROLE regress_subscription_user2;
---END---
---START---
CREATE ROLE regress_subscription_user3 IN ROLE pg_create_subscription;
---END---
---START---
CREATE ROLE regress_subscription_user_dummy LOGIN NOSUPERUSER;
---END---
---START---
SET SESSION AUTHORIZATION 'regress_subscription_user';
---END---
---START---

-- fail - no publications
CREATE SUBSCRIPTION regress_testsub CONNECTION 'foo';
---END---
---START---

-- fail - no connection
CREATE SUBSCRIPTION regress_testsub PUBLICATION foo;
---END---
---START---

-- fail - cannot do CREATE SUBSCRIPTION CREATE SLOT inside transaction block
BEGIN;
---END---
---START---
CREATE SUBSCRIPTION regress_testsub CONNECTION 'testconn' PUBLICATION testpub WITH (create_slot);
---END---
---START---
COMMIT;
---END---
---START---

-- fail - invalid connection string
CREATE SUBSCRIPTION regress_testsub CONNECTION 'testconn' PUBLICATION testpub;
---END---
---START---

-- fail - duplicate publications
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION foo, testpub, foo WITH (connect = false);
---END---
---START---

-- ok
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false);
---END---
---START---

COMMENT ON SUBSCRIPTION regress_testsub IS 'test subscription';
---END---
---START---
SELECT obj_description(s.oid, 'pg_subscription') FROM pg_subscription s;
---END---
---START---

-- Check if the subscription stats are created and stats_reset is updated
-- by pg_stat_reset_subscription_stats().
SELECT subname, stats_reset IS NULL stats_reset_is_null FROM pg_stat_subscription_stats WHERE subname = 'regress_testsub';
---END---
---START---
SELECT pg_stat_reset_subscription_stats(oid) FROM pg_subscription WHERE subname = 'regress_testsub';
---END---
---START---
SELECT subname, stats_reset IS NULL stats_reset_is_null FROM pg_stat_subscription_stats WHERE subname = 'regress_testsub';
---END---
---START---

-- Reset the stats again and check if the new reset_stats is updated.
SELECT stats_reset as prev_stats_reset FROM pg_stat_subscription_stats WHERE subname = 'regress_testsub' \gset
SELECT pg_stat_reset_subscription_stats(oid) FROM pg_subscription WHERE subname = 'regress_testsub';
---END---
---START---
SELECT :'prev_stats_reset' < stats_reset FROM pg_stat_subscription_stats WHERE subname = 'regress_testsub';
---END---
---START---

-- fail - name already exists
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false);
---END---
---START---

-- fail - must be superuser
SET SESSION AUTHORIZATION 'regress_subscription_user2';
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION foo WITH (connect = false);
---END---
---START---
SET SESSION AUTHORIZATION 'regress_subscription_user';
---END---
---START---

-- fail - invalid option combinations
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, copy_data = true);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, enabled = true);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, create_slot = true);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, enabled = true);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, enabled = false, create_slot = true);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, enabled = false);
---END---
---START---
CREATE SUBSCRIPTION regress_testsub2 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, create_slot = false);
---END---
---START---

-- ok - with slot_name = NONE
CREATE SUBSCRIPTION regress_testsub3 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, connect = false);
---END---
---START---
-- fail
ALTER SUBSCRIPTION regress_testsub3 ENABLE;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub3 REFRESH PUBLICATION;
---END---
---START---

-- fail - origin must be either none or any
CREATE SUBSCRIPTION regress_testsub4 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, connect = false, origin = foo);
---END---
---START---

-- now it works
CREATE SUBSCRIPTION regress_testsub4 CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (slot_name = NONE, connect = false, origin = none);
---END---
---START---
\dRs+ regress_testsub4
ALTER SUBSCRIPTION regress_testsub4 SET (origin = any);
---END---
---START---
\dRs+ regress_testsub4

DROP SUBSCRIPTION regress_testsub3;
---END---
---START---
DROP SUBSCRIPTION regress_testsub4;
---END---
---START---

-- fail, connection string does not parse
CREATE SUBSCRIPTION regress_testsub5 CONNECTION 'i_dont_exist=param' PUBLICATION testpub;
---END---
---START---

-- fail, connection string parses, but doesn't work (and does so without
-- connecting, so this is reliable and safe)
CREATE SUBSCRIPTION regress_testsub5 CONNECTION 'port=-1' PUBLICATION testpub;
---END---
---START---

-- fail - invalid connection string during ALTER
ALTER SUBSCRIPTION regress_testsub CONNECTION 'foobar';
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET PUBLICATION testpub2, testpub3 WITH (refresh = false);
---END---
---START---
ALTER SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist2';
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET (slot_name = 'newname');
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET (password_required = false);
---END---
---START---
\dRs+

ALTER SUBSCRIPTION regress_testsub SET (password_required = true);
---END---
---START---

-- fail
ALTER SUBSCRIPTION regress_testsub SET (slot_name = '');
---END---
---START---

-- fail
ALTER SUBSCRIPTION regress_doesnotexist CONNECTION 'dbname=regress_doesnotexist2';
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET (create_slot = false);
---END---
---START---

-- ok
ALTER SUBSCRIPTION regress_testsub SKIP (lsn = '0/12345');
---END---
---START---

\dRs+

-- ok - with lsn = NONE
ALTER SUBSCRIPTION regress_testsub SKIP (lsn = NONE);
---END---
---START---

-- fail
ALTER SUBSCRIPTION regress_testsub SKIP (lsn = '0/0');
---END---
---START---

\dRs+

BEGIN;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub ENABLE;
---END---
---START---

\dRs

ALTER SUBSCRIPTION regress_testsub DISABLE;
---END---
---START---

\dRs

COMMIT;
---END---
---START---

-- fail - must be owner of subscription
SET ROLE regress_subscription_user_dummy;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub RENAME TO regress_testsub_dummy;
---END---
---START---
RESET ROLE;
---END---
---START---

ALTER SUBSCRIPTION regress_testsub RENAME TO regress_testsub_foo;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub_foo SET (synchronous_commit = local);
---END---
---START---
ALTER SUBSCRIPTION regress_testsub_foo SET (synchronous_commit = foobar);
---END---
---START---

\dRs+

-- rename back to keep the rest simple
ALTER SUBSCRIPTION regress_testsub_foo RENAME TO regress_testsub;
---END---
---START---

-- ok, we're a superuser
ALTER SUBSCRIPTION regress_testsub OWNER TO regress_subscription_user2;
---END---
---START---

-- fail - cannot do DROP SUBSCRIPTION inside transaction block with slot name
BEGIN;
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---
COMMIT;
---END---
---START---

ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---

-- now it works
BEGIN;
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---
COMMIT;
---END---
---START---

DROP SUBSCRIPTION IF EXISTS regress_testsub;
---END---
---START---
DROP SUBSCRIPTION regress_testsub;  -- fail

-- fail - binary must be boolean
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, binary = foo);
---END---
---START---

-- now it works
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, binary = true);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (binary = false);
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---

\dRs+

DROP SUBSCRIPTION regress_testsub;
---END---
---START---

-- fail - streaming must be boolean or 'parallel'
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, streaming = foo);
---END---
---START---

-- now it works
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, streaming = true);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (streaming = parallel);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (streaming = false);
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---

\dRs+

-- fail - publication already exists
ALTER SUBSCRIPTION regress_testsub ADD PUBLICATION testpub WITH (refresh = false);
---END---
---START---

-- fail - publication used more than once
ALTER SUBSCRIPTION regress_testsub ADD PUBLICATION testpub1, testpub1 WITH (refresh = false);
---END---
---START---

-- ok - add two publications into subscription
ALTER SUBSCRIPTION regress_testsub ADD PUBLICATION testpub1, testpub2 WITH (refresh = false);
---END---
---START---

-- fail - publications already exist
ALTER SUBSCRIPTION regress_testsub ADD PUBLICATION testpub1, testpub2 WITH (refresh = false);
---END---
---START---

\dRs+

-- fail - publication used more than once
ALTER SUBSCRIPTION regress_testsub DROP PUBLICATION testpub1, testpub1 WITH (refresh = false);
---END---
---START---

-- fail - all publications are deleted
ALTER SUBSCRIPTION regress_testsub DROP PUBLICATION testpub, testpub1, testpub2 WITH (refresh = false);
---END---
---START---

-- fail - publication does not exist in subscription
ALTER SUBSCRIPTION regress_testsub DROP PUBLICATION testpub3 WITH (refresh = false);
---END---
---START---

-- ok - delete publications
ALTER SUBSCRIPTION regress_testsub DROP PUBLICATION testpub1, testpub2 WITH (refresh = false);
---END---
---START---

\dRs+

DROP SUBSCRIPTION regress_testsub;
---END---
---START---

CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION mypub
       WITH (connect = false, create_slot = false, copy_data = false);
---END---
---START---

ALTER SUBSCRIPTION regress_testsub ENABLE;
---END---
---START---

-- fail - ALTER SUBSCRIPTION with refresh is not allowed in a transaction
-- block or function
BEGIN;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET PUBLICATION mypub WITH (refresh = true);
---END---
---START---
END;
---END---
---START---

BEGIN;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub REFRESH PUBLICATION;
---END---
---START---
END;
---END---
---START---

CREATE FUNCTION func() RETURNS VOID AS
$$ ALTER SUBSCRIPTION regress_testsub SET PUBLICATION mypub WITH (refresh = true) $$ LANGUAGE SQL;
---END---
---START---
SELECT func();
---END---
---START---

ALTER SUBSCRIPTION regress_testsub DISABLE;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---
DROP FUNCTION func;
---END---
---START---

-- fail - two_phase must be boolean
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, two_phase = foo);
---END---
---START---

-- now it works
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, two_phase = true);
---END---
---START---

\dRs+
--fail - alter of two_phase option not supported.
ALTER SUBSCRIPTION regress_testsub SET (two_phase = false);
---END---
---START---

-- but can alter streaming when two_phase enabled
ALTER SUBSCRIPTION regress_testsub SET (streaming = true);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---

-- two_phase and streaming are compatible.
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, streaming = true, two_phase = true);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---

-- fail - disable_on_error must be boolean
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, disable_on_error = foo);
---END---
---START---

-- now it works
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, disable_on_error = false);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (disable_on_error = true);
---END---
---START---

\dRs+

ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---

-- let's do some tests with pg_create_subscription rather than superuser
SET SESSION AUTHORIZATION regress_subscription_user3;
---END---
---START---

-- fail, not enough privileges
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false);
---END---
---START---

-- fail, must specify password
RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT CREATE ON DATABASE REGRESSION TO regress_subscription_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_subscription_user3;
---END---
---START---
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false);
---END---
---START---

-- fail, can't set password_required=false
RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT CREATE ON DATABASE REGRESSION TO regress_subscription_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_subscription_user3;
---END---
---START---
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist' PUBLICATION testpub WITH (connect = false, password_required = false);
---END---
---START---

-- ok
RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT CREATE ON DATABASE REGRESSION TO regress_subscription_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_subscription_user3;
---END---
---START---
CREATE SUBSCRIPTION regress_testsub CONNECTION 'dbname=regress_doesnotexist password=regress_fakepassword' PUBLICATION testpub WITH (connect = false);
---END---
---START---

-- we cannot give the subscription away to some random user
ALTER SUBSCRIPTION regress_testsub OWNER TO regress_subscription_user;
---END---
---START---

-- but we can rename the subscription we just created
ALTER SUBSCRIPTION regress_testsub RENAME TO regress_testsub2;
---END---
---START---

-- ok, even after losing pg_create_subscription we can still rename it
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE pg_create_subscription FROM regress_subscription_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_subscription_user3;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub2 RENAME TO regress_testsub;
---END---
---START---

-- fail, after losing CREATE on the database we can't rename it any more
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE CREATE ON DATABASE REGRESSION FROM regress_subscription_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_subscription_user3;
---END---
---START---
ALTER SUBSCRIPTION regress_testsub RENAME TO regress_testsub2;
---END---
---START---

-- ok, owning it is enough for this stuff
ALTER SUBSCRIPTION regress_testsub SET (slot_name = NONE);
---END---
---START---
DROP SUBSCRIPTION regress_testsub;
---END---
---START---

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP ROLE regress_subscription_user;
---END---
---START---
DROP ROLE regress_subscription_user2;
---END---
---START---
DROP ROLE regress_subscription_user3;
---END---
---START---
DROP ROLE regress_subscription_user_dummy;
---END---
