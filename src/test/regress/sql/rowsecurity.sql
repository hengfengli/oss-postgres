---START---
--
-- Test of Row-level security feature
--

-- Clean up in case a prior regression run failed

-- Suppress NOTICE messages when users/groups don't exist
SET client_min_messages TO 'warning';
---END---
---START---
DROP USER IF EXISTS regress_rls_alice;
---END---
---START---
DROP USER IF EXISTS regress_rls_bob;
---END---
---START---
DROP USER IF EXISTS regress_rls_carol;
---END---
---START---
DROP USER IF EXISTS regress_rls_dave;
---END---
---START---
DROP USER IF EXISTS regress_rls_exempt_user;
---END---
---START---
DROP ROLE IF EXISTS regress_rls_group1;
---END---
---START---
DROP ROLE IF EXISTS regress_rls_group2;
---END---
---START---
DROP SCHEMA IF EXISTS regress_rls_schema CASCADE;
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- initial setup
CREATE USER regress_rls_alice NOLOGIN;
---END---
---START---
CREATE USER regress_rls_bob NOLOGIN;
---END---
---START---
CREATE USER regress_rls_carol NOLOGIN;
---END---
---START---
CREATE USER regress_rls_dave NOLOGIN;
---END---
---START---
CREATE USER regress_rls_exempt_user BYPASSRLS NOLOGIN;
---END---
---START---
CREATE ROLE regress_rls_group1 NOLOGIN;
---END---
---START---
CREATE ROLE regress_rls_group2 NOLOGIN;
---END---
---START---
GRANT regress_rls_group1 TO regress_rls_bob;
---END---
---START---
GRANT regress_rls_group2 TO regress_rls_carol;
---END---
---START---
CREATE SCHEMA regress_rls_schema;
---END---
---START---
GRANT ALL ON SCHEMA regress_rls_schema to public;
---END---
---START---
SET search_path = regress_rls_schema;
---END---
---START---
-- setup of malicious function
CREATE OR REPLACE FUNCTION f_leak(text) RETURNS bool
    COST 0.0000001 LANGUAGE plpgsql
    AS 'BEGIN RAISE NOTICE ''f_leak => %'', $1; RETURN true; END';
---END---
---START---
GRANT EXECUTE ON FUNCTION f_leak(text) TO public;
---END---
---START---
-- BASIC Row-Level Security Scenario

SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE uaccount (
    pguser      name primary key,
    seclv       int
);
---END---
---START---
GRANT SELECT ON uaccount TO public;
---END---
---START---
INSERT INTO uaccount VALUES
    ('regress_rls_alice', 99),
    ('regress_rls_bob', 1),
    ('regress_rls_carol', 2),
    ('regress_rls_dave', 3);
---END---
---START---
CREATE TABLE category (
    cid        int primary key,
    cname      text
);
---END---
---START---
GRANT ALL ON category TO public;
---END---
---START---
INSERT INTO category VALUES
    (11, 'novel'),
    (22, 'science fiction'),
    (33, 'technology'),
    (44, 'manga');
---END---
---START---
CREATE TABLE document (
    did         int primary key,
    cid         int references category(cid),
    dlevel      int not null,
    dauthor     name,
    dtitle      text
);
---END---
---START---
GRANT ALL ON document TO public;
---END---
---START---
INSERT INTO document VALUES
    ( 1, 11, 1, 'regress_rls_bob', 'my first novel'),
    ( 2, 11, 2, 'regress_rls_bob', 'my second novel'),
    ( 3, 22, 2, 'regress_rls_bob', 'my science fiction'),
    ( 4, 44, 1, 'regress_rls_bob', 'my first manga'),
    ( 5, 44, 2, 'regress_rls_bob', 'my second manga'),
    ( 6, 22, 1, 'regress_rls_carol', 'great science fiction'),
    ( 7, 33, 2, 'regress_rls_carol', 'great technology book'),
    ( 8, 44, 1, 'regress_rls_carol', 'great manga'),
    ( 9, 22, 1, 'regress_rls_dave', 'awesome science fiction'),
    (10, 33, 2, 'regress_rls_dave', 'awesome technology book');
---END---
---START---
ALTER TABLE document ENABLE ROW LEVEL SECURITY;
---END---
---START---
-- user's security level must be higher than or equal to document's
CREATE POLICY p1 ON document AS PERMISSIVE
    USING (dlevel <= (SELECT seclv FROM uaccount WHERE pguser = current_user));
---END---
---START---
-- try to create a policy of bogus type
CREATE POLICY p1 ON document AS UGLY
    USING (dlevel <= (SELECT seclv FROM uaccount WHERE pguser = current_user));
---END---
---START---
-- but Dave isn't allowed to anything at cid 50 or above
-- this is to make sure that we sort the policies by name first
-- when applying WITH CHECK, a later INSERT by Dave should fail due
-- to p1r first
CREATE POLICY p2r ON document AS RESTRICTIVE TO regress_rls_dave
    USING (cid <> 44 AND cid < 50);
---END---
---START---
-- and Dave isn't allowed to see manga documents
CREATE POLICY p1r ON document AS RESTRICTIVE TO regress_rls_dave
    USING (cid <> 44);
---END---
---START---
\dp
\d document
SELECT * FROM pg_policies WHERE schemaname = 'regress_rls_schema' AND tablename = 'document' ORDER BY policyname;
---END---
---START---
-- viewpoint from regress_rls_bob
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- try a sampled version
SELECT * FROM document TABLESAMPLE BERNOULLI(50) REPEATABLE(0)
  WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- viewpoint from regress_rls_carol
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- try a sampled version
SELECT * FROM document TABLESAMPLE BERNOULLI(50) REPEATABLE(0)
  WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM document WHERE f_leak(dtitle);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle);
---END---
---START---
-- viewpoint from regress_rls_dave
SET SESSION AUTHORIZATION regress_rls_dave;
---END---
---START---
SELECT * FROM document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM document WHERE f_leak(dtitle);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle);
---END---
---START---
-- 44 would technically fail for both p2r and p1r, but we should get an error
-- back from p1r for this because it sorts first
INSERT INTO document VALUES (100, 44, 1, 'regress_rls_dave', 'testing sorting of policies');
---END---
---START---
-- fail
-- Just to see a p2r error
INSERT INTO document VALUES (100, 55, 1, 'regress_rls_dave', 'testing sorting of policies');
---END---
---START---
-- fail

-- only owner can change policies
ALTER POLICY p1 ON document USING (true);
---END---
---START---
--fail
DROP POLICY p1 ON document;
---END---
---START---
--fail

SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ALTER POLICY p1 ON document USING (dauthor = current_user);
---END---
---START---
-- viewpoint from regress_rls_bob again
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle) ORDER by did;
---END---
---START---
-- viewpoint from rls_regres_carol again
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle) ORDER by did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM document WHERE f_leak(dtitle);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM document NATURAL JOIN category WHERE f_leak(dtitle);
---END---
---START---
-- interaction of FK/PK constraints
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE POLICY p2 ON category
    USING (CASE WHEN current_user = 'regress_rls_bob' THEN cid IN (11, 33)
           WHEN current_user = 'regress_rls_carol' THEN cid IN (22, 44)
           ELSE false END);
---END---
---START---
ALTER TABLE category ENABLE ROW LEVEL SECURITY;
---END---
---START---
-- cannot delete PK referenced by invisible FK
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM document d FULL OUTER JOIN category c on d.cid = c.cid ORDER BY d.did, c.cid;
---END---
---START---
DELETE FROM category WHERE cid = 33;
---END---
---START---
-- fails with FK violation

-- can insert FK referencing invisible PK
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM document d FULL OUTER JOIN category c on d.cid = c.cid ORDER BY d.did, c.cid;
---END---
---START---
INSERT INTO document VALUES (11, 33, 1, current_user, 'hoge');
---END---
---START---
-- UNIQUE or PRIMARY KEY constraint violation DOES reveal presence of row
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
INSERT INTO document VALUES (8, 44, 1, 'regress_rls_bob', 'my third manga');
---END---
---START---
-- Must fail with unique violation, revealing presence of did we can't see
SELECT * FROM document WHERE did = 8;
---END---
---START---
-- and confirm we can't see it

-- RLS policies are checked before constraints
INSERT INTO document VALUES (8, 44, 1, 'regress_rls_carol', 'my third manga');
---END---
---START---
-- Should fail with RLS check violation, not duplicate key violation
UPDATE document SET did = 8, dauthor = 'regress_rls_carol' WHERE did = 5;
---END---
---START---
-- Should fail with RLS check violation, not duplicate key violation

-- database superuser does bypass RLS policy when enabled
RESET SESSION AUTHORIZATION;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM document;
---END---
---START---
SELECT * FROM category;
---END---
---START---
-- database superuser does bypass RLS policy when disabled
RESET SESSION AUTHORIZATION;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM document;
---END---
---START---
SELECT * FROM category;
---END---
---START---
-- database non-superuser with bypass privilege can bypass RLS policy when disabled
SET SESSION AUTHORIZATION regress_rls_exempt_user;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM document;
---END---
---START---
SELECT * FROM category;
---END---
---START---
-- RLS policy does not apply to table owner when RLS enabled.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM document;
---END---
---START---
SELECT * FROM category;
---END---
---START---
-- RLS policy does not apply to table owner when RLS disabled.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM document;
---END---
---START---
SELECT * FROM category;
---END---
---START---
--
-- Table inheritance and RLS policy
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security TO ON;
---END---
---START---
CREATE TABLE t1 (id int not null primary key, a int, junk1 text, b text);
---END---
---START---
ALTER TABLE t1 DROP COLUMN junk1;
---END---
---START---
-- just a disturbing factor
GRANT ALL ON t1 TO public;
---END---
---START---
COPY t1 FROM stdin WITH ;
101	1	aba
102	2	bbb
103	3	ccc
104	4	dad
\.
---END---
---START---
CREATE TABLE t2 (_gemini_pk serial PRIMARY KEY, c double precision) INHERITS (t1);
---END---
---START---
GRANT ALL ON t2 TO public;
---END---
---START---
COPY t2 FROM stdin;
201	1	abc	1.1
202	2	bcd	2.2
203	3	cde	3.3
204	4	def	4.4
\.
---END---
---START---
CREATE TABLE t3 (id int not null primary key, c text, b text, a int);
---END---
---START---
ALTER TABLE t3 INHERIT t1;
---END---
---START---
GRANT ALL ON t3 TO public;
---END---
---START---
COPY t3(id, a,b,c) FROM stdin;
301	1	xxx	X
302	2	yyy	Y
303	3	zzz	Z
\.
---END---
---START---
CREATE POLICY p1 ON t1 FOR ALL TO PUBLIC USING (a % 2 = 0);
---END---
---START---
-- be even number
CREATE POLICY p2 ON t2 FOR ALL TO PUBLIC USING (a % 2 = 1);
---END---
---START---
-- be odd number

ALTER TABLE t1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE t2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1;
---END---
---START---
SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
-- reference to system column
SELECT tableoid::regclass, * FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT *, t1 FROM t1;
---END---
---START---
-- reference to whole-row reference
SELECT *, t1 FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT *, t1 FROM t1;
---END---
---START---
-- for share/update lock
SELECT * FROM t1 FOR SHARE;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1 FOR SHARE;
---END---
---START---
SELECT * FROM t1 WHERE f_leak(b) FOR SHARE;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1 WHERE f_leak(b) FOR SHARE;
---END---
---START---
-- union all query
SELECT a, b, tableoid::regclass FROM t2 UNION ALL SELECT a, b, tableoid::regclass FROM t3;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT a, b, tableoid::regclass FROM t2 UNION ALL SELECT a, b, tableoid::regclass FROM t3;
---END---
---START---
-- superuser is allowed to bypass RLS checks
RESET SESSION AUTHORIZATION;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
-- non-superuser with bypass privilege can bypass RLS policy when disabled
SET SESSION AUTHORIZATION regress_rls_exempt_user;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
--
-- Partitioned Tables
--

SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE part_document (_gemini_pk serial PRIMARY KEY, did integer, cid integer, dlevel integer NOT NULL, dauthor name, dtitle text) PARTITION BY range (cid);
---END---
---START---
GRANT ALL ON part_document TO public;
---END---
---START---
-- Create partitions for document categories
CREATE TABLE part_document_fiction PARTITION OF part_document FOR VALUES FROM (11) to (12);
---END---
---START---
CREATE TABLE part_document_satire PARTITION OF part_document FOR VALUES FROM (55) to (56);
---END---
---START---
CREATE TABLE part_document_nonfiction PARTITION OF part_document FOR VALUES FROM (99) to (100);
---END---
---START---
GRANT ALL ON part_document_fiction TO public;
---END---
---START---
GRANT ALL ON part_document_satire TO public;
---END---
---START---
GRANT ALL ON part_document_nonfiction TO public;
---END---
---START---
INSERT INTO part_document VALUES
    ( 1, 11, 1, 'regress_rls_bob', 'my first novel'),
    ( 2, 11, 2, 'regress_rls_bob', 'my second novel'),
    ( 3, 99, 2, 'regress_rls_bob', 'my science textbook'),
    ( 4, 55, 1, 'regress_rls_bob', 'my first satire'),
    ( 5, 99, 2, 'regress_rls_bob', 'my history book'),
    ( 6, 11, 1, 'regress_rls_carol', 'great science fiction'),
    ( 7, 99, 2, 'regress_rls_carol', 'great technology book'),
    ( 8, 55, 2, 'regress_rls_carol', 'great satire'),
    ( 9, 11, 1, 'regress_rls_dave', 'awesome science fiction'),
    (10, 99, 2, 'regress_rls_dave', 'awesome technology book');
---END---
---START---
ALTER TABLE part_document ENABLE ROW LEVEL SECURITY;
---END---
---START---
-- Create policy on parent
-- user's security level must be higher than or equal to document's
CREATE POLICY pp1 ON part_document AS PERMISSIVE
    USING (dlevel <= (SELECT seclv FROM uaccount WHERE pguser = current_user));
---END---
---START---
-- Dave is only allowed to see cid < 55
CREATE POLICY pp1r ON part_document AS RESTRICTIVE TO regress_rls_dave
    USING (cid < 55);
---END---
---START---
\d+ part_document
SELECT * FROM pg_policies WHERE schemaname = 'regress_rls_schema' AND tablename like '%part_document%' ORDER BY policyname;
---END---
---START---
-- viewpoint from regress_rls_bob
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM part_document WHERE f_leak(dtitle);
---END---
---START---
-- viewpoint from regress_rls_carol
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM part_document WHERE f_leak(dtitle);
---END---
---START---
-- viewpoint from regress_rls_dave
SET SESSION AUTHORIZATION regress_rls_dave;
---END---
---START---
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM part_document WHERE f_leak(dtitle);
---END---
---START---
-- pp1 ERROR
INSERT INTO part_document VALUES (100, 11, 5, 'regress_rls_dave', 'testing pp1');
---END---
---START---
-- fail
-- pp1r ERROR
INSERT INTO part_document VALUES (100, 99, 1, 'regress_rls_dave', 'testing pp1r');
---END---
---START---
-- fail

-- Show that RLS policy does not apply for direct inserts to children
-- This should fail with RLS POLICY pp1r violation.
INSERT INTO part_document VALUES (100, 55, 1, 'regress_rls_dave', 'testing RLS with partitions');
---END---
---START---
-- fail
-- But this should succeed.
INSERT INTO part_document_satire VALUES (100, 55, 1, 'regress_rls_dave', 'testing RLS with partitions');
---END---
---START---
-- success
-- We still cannot see the row using the parent
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- But we can if we look directly
SELECT * FROM part_document_satire WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- Turn on RLS and create policy on child to show RLS is checked before constraints
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ALTER TABLE part_document_satire ENABLE ROW LEVEL SECURITY;
---END---
---START---
CREATE POLICY pp3 ON part_document_satire AS RESTRICTIVE
    USING (cid < 55);
---END---
---START---
-- This should fail with RLS violation now.
SET SESSION AUTHORIZATION regress_rls_dave;
---END---
---START---
INSERT INTO part_document_satire VALUES (101, 55, 1, 'regress_rls_dave', 'testing RLS with partitions');
---END---
---START---
-- fail
-- And now we cannot see directly into the partition either, due to RLS
SELECT * FROM part_document_satire WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- The parent looks same as before
-- viewpoint from regress_rls_dave
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM part_document WHERE f_leak(dtitle);
---END---
---START---
-- viewpoint from regress_rls_carol
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM part_document WHERE f_leak(dtitle);
---END---
---START---
-- only owner can change policies
ALTER POLICY pp1 ON part_document USING (true);
---END---
---START---
--fail
DROP POLICY pp1 ON part_document;
---END---
---START---
--fail

SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ALTER POLICY pp1 ON part_document USING (dauthor = current_user);
---END---
---START---
-- viewpoint from regress_rls_bob again
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
-- viewpoint from rls_regres_carol again
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM part_document WHERE f_leak(dtitle) ORDER BY did;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM part_document WHERE f_leak(dtitle);
---END---
---START---
-- database superuser does bypass RLS policy when enabled
RESET SESSION AUTHORIZATION;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM part_document ORDER BY did;
---END---
---START---
SELECT * FROM part_document_satire ORDER by did;
---END---
---START---
-- database non-superuser with bypass privilege can bypass RLS policy when disabled
SET SESSION AUTHORIZATION regress_rls_exempt_user;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM part_document ORDER BY did;
---END---
---START---
SELECT * FROM part_document_satire ORDER by did;
---END---
---START---
-- RLS policy does not apply to table owner when RLS enabled.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM part_document ORDER by did;
---END---
---START---
SELECT * FROM part_document_satire ORDER by did;
---END---
---START---
-- When RLS disabled, other users get ERROR.
SET SESSION AUTHORIZATION regress_rls_dave;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM part_document ORDER by did;
---END---
---START---
SELECT * FROM part_document_satire ORDER by did;
---END---
---START---
-- Check behavior with a policy that uses a SubPlan not an InitPlan.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security TO ON;
---END---
---START---
CREATE POLICY pp3 ON part_document AS RESTRICTIVE
    USING ((SELECT dlevel <= seclv FROM uaccount WHERE pguser = current_user));
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
INSERT INTO part_document VALUES (100, 11, 5, 'regress_rls_carol', 'testing pp3');
---END---
---START---
-- fail

----- Dependencies -----
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security TO ON;
---END---
---START---
CREATE TABLE dependee (_gemini_pk serial PRIMARY KEY, x integer, y integer);
---END---
---START---
CREATE TABLE dependent (_gemini_pk serial PRIMARY KEY, x integer, y integer);
---END---
---START---
CREATE POLICY d1 ON dependent FOR ALL
    TO PUBLIC
    USING (x = (SELECT d.x FROM dependee d WHERE d.y = y));
---END---
---START---
DROP TABLE dependee;
---END---
---START---
-- Should fail without CASCADE due to dependency on row security qual?

DROP TABLE dependee CASCADE;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM dependent;
---END---
---START---
-- After drop, should be unqualified

-----   RECURSION    ----

--
-- Simple recursion
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE rec1 (_gemini_pk serial PRIMARY KEY, x integer, y integer);
---END---
---START---
CREATE POLICY r1 ON rec1 USING (x = (SELECT r.x FROM rec1 r WHERE y = r.y));
---END---
---START---
ALTER TABLE rec1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rec1;
---END---
---START---
-- fail, direct recursion

--
-- Mutual recursion
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE rec2 (_gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
ALTER POLICY r1 ON rec1 USING (x = (SELECT a FROM rec2 WHERE b = y));
---END---
---START---
CREATE POLICY r2 ON rec2 USING (a = (SELECT x FROM rec1 WHERE y = b));
---END---
---START---
ALTER TABLE rec2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rec1;
---END---
---START---
-- fail, mutual recursion

--
-- Mutual recursion via views
--
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE VIEW rec1v AS SELECT * FROM rec1;
---END---
---START---
CREATE VIEW rec2v AS SELECT * FROM rec2;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ALTER POLICY r1 ON rec1 USING (x = (SELECT a FROM rec2v WHERE b = y));
---END---
---START---
ALTER POLICY r2 ON rec2 USING (a = (SELECT x FROM rec1v WHERE y = b));
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rec1;
---END---
---START---
-- fail, mutual recursion via views

--
-- Mutual recursion via .s.b views
--
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
DROP VIEW rec1v, rec2v CASCADE;
---END---
---START---
CREATE VIEW rec1v WITH (security_barrier) AS SELECT * FROM rec1;
---END---
---START---
CREATE VIEW rec2v WITH (security_barrier) AS SELECT * FROM rec2;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE POLICY r1 ON rec1 USING (x = (SELECT a FROM rec2v WHERE b = y));
---END---
---START---
CREATE POLICY r2 ON rec2 USING (a = (SELECT x FROM rec1v WHERE y = b));
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rec1;
---END---
---START---
-- fail, mutual recursion via s.b. views

--
-- recursive RLS and VIEWs in policy
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE s1 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
INSERT INTO s1 (SELECT x, public.fipshash(x::text) FROM generate_series(-10,10) x);
---END---
---START---
CREATE TABLE s2 (_gemini_pk serial PRIMARY KEY, x integer, y text);
---END---
---START---
INSERT INTO s2 (SELECT x, public.fipshash(x::text) FROM generate_series(-6,6) x);
---END---
---START---
GRANT SELECT ON s1, s2 TO regress_rls_bob;
---END---
---START---
CREATE POLICY p1 ON s1 USING (a in (select x from s2 where y like '%2f%'));
---END---
---START---
CREATE POLICY p2 ON s2 USING (x in (select a from s1 where b like '%22%'));
---END---
---START---
CREATE POLICY p3 ON s1 FOR INSERT WITH CHECK (a = (SELECT a FROM s1));
---END---
---START---
ALTER TABLE s1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE s2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE VIEW v2 AS SELECT * FROM s2 WHERE y like '%af%';
---END---
---START---
SELECT * FROM s1 WHERE f_leak(b);
---END---
---START---
-- fail (infinite recursion)

INSERT INTO s1 VALUES (1, 'foo');
---END---
---START---
-- fail (infinite recursion)

SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP POLICY p3 on s1;
---END---
---START---
ALTER POLICY p2 ON s2 USING (x % 2 = 0);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM s1 WHERE f_leak(b);
---END---
---START---
-- OK
EXPLAIN (COSTS OFF) SELECT * FROM only s1 WHERE f_leak(b);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ALTER POLICY p1 ON s1 USING (a in (select x from v2));
---END---
---START---
-- using VIEW in RLS policy
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM s1 WHERE f_leak(b);
---END---
---START---
-- OK
EXPLAIN (COSTS OFF) SELECT * FROM s1 WHERE f_leak(b);
---END---
---START---
SELECT (SELECT x FROM s1 LIMIT 1) xx, * FROM s2 WHERE y like '%28%';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT (SELECT x FROM s1 LIMIT 1) xx, * FROM s2 WHERE y like '%28%';
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ALTER POLICY p2 ON s2 USING (x in (select a from s1 where b like '%d2%'));
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM s1 WHERE f_leak(b);
---END---
---START---
-- fail (infinite recursion via view)

-- prepared statement with regress_rls_alice privilege
PREPARE p1(int) AS SELECT * FROM t1 WHERE a <= $1;
---END---
---START---
EXECUTE p1(2);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE p1(2);
---END---
---START---
-- superuser is allowed to bypass RLS checks
RESET SESSION AUTHORIZATION;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1 WHERE f_leak(b);
---END---
---START---
-- plan cache should be invalidated
EXECUTE p1(2);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE p1(2);
---END---
---START---
PREPARE p2(int) AS SELECT * FROM t1 WHERE a = $1;
---END---
---START---
EXECUTE p2(2);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE p2(2);
---END---
---START---
-- also, case when privilege switch from superuser
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SET row_security TO ON;
---END---
---START---
EXECUTE p2(2);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE p2(2);
---END---
---START---
--
-- UPDATE / DELETE and Row-level security
--
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
EXPLAIN (COSTS OFF) UPDATE t1 SET b = b || b WHERE f_leak(b);
---END---
---START---
UPDATE t1 SET b = b || b WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) UPDATE only t1 SET b = b || '_updt' WHERE f_leak(b);
---END---
---START---
UPDATE only t1 SET b = b || '_updt' WHERE f_leak(b);
---END---
---START---
-- returning clause with system column
UPDATE only t1 SET b = b WHERE f_leak(b) RETURNING tableoid::regclass, *, t1;
---END---
---START---
UPDATE t1 SET b = b WHERE f_leak(b) RETURNING *;
---END---
---START---
UPDATE t1 SET b = b WHERE f_leak(b) RETURNING tableoid::regclass, *, t1;
---END---
---START---
-- updates with from clause
EXPLAIN (COSTS OFF) UPDATE t2 SET b=t2.b FROM t3
WHERE t2.a = 3 and t3.a = 2 AND f_leak(t2.b) AND f_leak(t3.b);
---END---
---START---
UPDATE t2 SET b=t2.b FROM t3
WHERE t2.a = 3 and t3.a = 2 AND f_leak(t2.b) AND f_leak(t3.b);
---END---
---START---
EXPLAIN (COSTS OFF) UPDATE t1 SET b=t1.b FROM t2
WHERE t1.a = 3 and t2.a = 3 AND f_leak(t1.b) AND f_leak(t2.b);
---END---
---START---
UPDATE t1 SET b=t1.b FROM t2
WHERE t1.a = 3 and t2.a = 3 AND f_leak(t1.b) AND f_leak(t2.b);
---END---
---START---
EXPLAIN (COSTS OFF) UPDATE t2 SET b=t2.b FROM t1
WHERE t1.a = 3 and t2.a = 3 AND f_leak(t1.b) AND f_leak(t2.b);
---END---
---START---
UPDATE t2 SET b=t2.b FROM t1
WHERE t1.a = 3 and t2.a = 3 AND f_leak(t1.b) AND f_leak(t2.b);
---END---
---START---
-- updates with from clause self join
EXPLAIN (COSTS OFF) UPDATE t2 t2_1 SET b = t2_2.b FROM t2 t2_2
WHERE t2_1.a = 3 AND t2_2.a = t2_1.a AND t2_2.b = t2_1.b
AND f_leak(t2_1.b) AND f_leak(t2_2.b) RETURNING *, t2_1, t2_2;
---END---
---START---
UPDATE t2 t2_1 SET b = t2_2.b FROM t2 t2_2
WHERE t2_1.a = 3 AND t2_2.a = t2_1.a AND t2_2.b = t2_1.b
AND f_leak(t2_1.b) AND f_leak(t2_2.b) RETURNING *, t2_1, t2_2;
---END---
---START---
EXPLAIN (COSTS OFF) UPDATE t1 t1_1 SET b = t1_2.b FROM t1 t1_2
WHERE t1_1.a = 4 AND t1_2.a = t1_1.a AND t1_2.b = t1_1.b
AND f_leak(t1_1.b) AND f_leak(t1_2.b) RETURNING *, t1_1, t1_2;
---END---
---START---
UPDATE t1 t1_1 SET b = t1_2.b FROM t1 t1_2
WHERE t1_1.a = 4 AND t1_2.a = t1_1.a AND t1_2.b = t1_1.b
AND f_leak(t1_1.b) AND f_leak(t1_2.b) RETURNING *, t1_1, t1_2;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
SELECT * FROM t1 ORDER BY a,b;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SET row_security TO ON;
---END---
---START---
EXPLAIN (COSTS OFF) DELETE FROM only t1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) DELETE FROM t1 WHERE f_leak(b);
---END---
---START---
DELETE FROM only t1 WHERE f_leak(b) RETURNING tableoid::regclass, *, t1;
---END---
---START---
DELETE FROM t1 WHERE f_leak(b) RETURNING tableoid::regclass, *, t1;
---END---
---START---
--
-- S.b. view on top of Row-level security
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE b1 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
INSERT INTO b1 (SELECT x, public.fipshash(x::text) FROM generate_series(-10,10) x);
---END---
---START---
CREATE POLICY p1 ON b1 USING (a % 2 = 0);
---END---
---START---
ALTER TABLE b1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
GRANT ALL ON b1 TO regress_rls_bob;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE VIEW bv1 WITH (security_barrier) AS SELECT * FROM b1 WHERE a > 0 WITH CHECK OPTION;
---END---
---START---
GRANT ALL ON bv1 TO regress_rls_carol;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM bv1 WHERE f_leak(b);
---END---
---START---
SELECT * FROM bv1 WHERE f_leak(b);
---END---
---START---
INSERT INTO bv1 VALUES (-1, 'xxx');
---END---
---START---
-- should fail view WCO
INSERT INTO bv1 VALUES (11, 'xxx');
---END---
---START---
-- should fail RLS check
INSERT INTO bv1 VALUES (12, 'xxx');
---END---
---START---
-- ok

EXPLAIN (COSTS OFF) UPDATE bv1 SET b = 'yyy' WHERE a = 4 AND f_leak(b);
---END---
---START---
UPDATE bv1 SET b = 'yyy' WHERE a = 4 AND f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) DELETE FROM bv1 WHERE a = 6 AND f_leak(b);
---END---
---START---
DELETE FROM bv1 WHERE a = 6 AND f_leak(b);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM b1;
---END---
---START---
--
-- INSERT ... ON CONFLICT DO UPDATE and Row-level security
--

SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP POLICY p1 ON document;
---END---
---START---
DROP POLICY p1r ON document;
---END---
---START---
CREATE POLICY p1 ON document FOR SELECT USING (true);
---END---
---START---
CREATE POLICY p2 ON document FOR INSERT WITH CHECK (dauthor = current_user);
---END---
---START---
CREATE POLICY p3 ON document FOR UPDATE
  USING (cid = (SELECT cid from category WHERE cname = 'novel'))
  WITH CHECK (dauthor = current_user);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Exists...
SELECT * FROM document WHERE did = 2;
---END---
---START---
-- ...so violates actual WITH CHECK OPTION within UPDATE (not INSERT, since
-- alternative UPDATE path happens to be taken):
INSERT INTO document VALUES (2, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_carol', 'my first novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle, dauthor = EXCLUDED.dauthor;
---END---
---START---
-- Violates USING qual for UPDATE policy p3.
--
-- UPDATE path is taken, but UPDATE fails purely because *existing* row to be
-- updated is not a "novel"/cid 11 (row is not leaked, even though we have
-- SELECT privileges sufficient to see the row in this instance):
INSERT INTO document VALUES (33, 22, 1, 'regress_rls_bob', 'okay science fiction');
---END---
---START---
-- preparation for next statement
INSERT INTO document VALUES (33, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'Some novel, replaces sci-fi') -- takes UPDATE path
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle;
---END---
---START---
-- Fine (we UPDATE, since INSERT WCOs and UPDATE security barrier quals + WCOs
-- not violated):
INSERT INTO document VALUES (2, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'my first novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle RETURNING *;
---END---
---START---
-- Fine (we INSERT, so "cid = 33" ("technology") isn't evaluated):
INSERT INTO document VALUES (78, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'some technology novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle, cid = 33 RETURNING *;
---END---
---START---
-- Fine (same query, but we UPDATE, so "cid = 33", ("technology") is not the
-- case in respect of *existing* tuple):
INSERT INTO document VALUES (78, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'some technology novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle, cid = 33 RETURNING *;
---END---
---START---
-- Same query a third time, but now fails due to existing tuple finally not
-- passing quals:
INSERT INTO document VALUES (78, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'some technology novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle, cid = 33 RETURNING *;
---END---
---START---
-- Don't fail just because INSERT doesn't satisfy WITH CHECK option that
-- originated as a barrier/USING() qual from the UPDATE.  Note that the UPDATE
-- path *isn't* taken, and so UPDATE-related policy does not apply:
INSERT INTO document VALUES (79, (SELECT cid from category WHERE cname = 'technology'), 1, 'regress_rls_bob', 'technology book, can only insert')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle RETURNING *;
---END---
---START---
-- But this time, the same statement fails, because the UPDATE path is taken,
-- and updating the row just inserted falls afoul of security barrier qual
-- (enforced as WCO) -- what we might have updated target tuple to is
-- irrelevant, in fact.
INSERT INTO document VALUES (79, (SELECT cid from category WHERE cname = 'technology'), 1, 'regress_rls_bob', 'technology book, can only insert')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle RETURNING *;
---END---
---START---
-- Test default USING qual enforced as WCO
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP POLICY p1 ON document;
---END---
---START---
DROP POLICY p2 ON document;
---END---
---START---
DROP POLICY p3 ON document;
---END---
---START---
CREATE POLICY p3_with_default ON document FOR UPDATE
  USING (cid = (SELECT cid from category WHERE cname = 'novel'));
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Just because WCO-style enforcement of USING quals occurs with
-- existing/target tuple does not mean that the implementation can be allowed
-- to fail to also enforce this qual against the final tuple appended to
-- relation (since in the absence of an explicit WCO, this is also interpreted
-- as an UPDATE/ALL WCO in general).
--
-- UPDATE path is taken here (fails due to existing tuple).  Note that this is
-- not reported as a "USING expression", because it's an RLS UPDATE check that originated as
-- a USING qual for the purposes of RLS in general, as opposed to an explicit
-- USING qual that is ordinarily a security barrier.  We leave it up to the
-- UPDATE to make this fail:
INSERT INTO document VALUES (79, (SELECT cid from category WHERE cname = 'technology'), 1, 'regress_rls_bob', 'technology book, can only insert')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle RETURNING *;
---END---
---START---
-- UPDATE path is taken here.  Existing tuple passes, since its cid
-- corresponds to "novel", but default USING qual is enforced against
-- post-UPDATE tuple too (as always when updating with a policy that lacks an
-- explicit WCO), and so this fails:
INSERT INTO document VALUES (2, (SELECT cid from category WHERE cname = 'technology'), 1, 'regress_rls_bob', 'my first novel')
    ON CONFLICT (did) DO UPDATE SET cid = EXCLUDED.cid, dtitle = EXCLUDED.dtitle RETURNING *;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP POLICY p3_with_default ON document;
---END---
---START---
--
-- Test ALL policies with ON CONFLICT DO UPDATE (much the same as existing UPDATE
-- tests)
--
CREATE POLICY p3_with_all ON document FOR ALL
  USING (cid = (SELECT cid from category WHERE cname = 'novel'))
  WITH CHECK (dauthor = current_user);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Fails, since ALL WCO is enforced in insert path:
INSERT INTO document VALUES (80, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_carol', 'my first novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle, cid = 33;
---END---
---START---
-- Fails, since ALL policy USING qual is enforced (existing, target tuple is in
-- violation, since it has the "manga" cid):
INSERT INTO document VALUES (4, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'my first novel')
    ON CONFLICT (did) DO UPDATE SET dtitle = EXCLUDED.dtitle;
---END---
---START---
-- Fails, since ALL WCO are enforced:
INSERT INTO document VALUES (1, (SELECT cid from category WHERE cname = 'novel'), 1, 'regress_rls_bob', 'my first novel')
    ON CONFLICT (did) DO UPDATE SET dauthor = 'regress_rls_carol';
---END---
---START---
--
-- MERGE
--
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP POLICY p3_with_all ON document;
---END---
---START---
ALTER TABLE document ADD COLUMN dnotes text DEFAULT '';
---END---
---START---
-- all documents are readable
CREATE POLICY p1 ON document FOR SELECT USING (true);
---END---
---START---
-- one may insert documents only authored by them
CREATE POLICY p2 ON document FOR INSERT WITH CHECK (dauthor = current_user);
---END---
---START---
-- one may only update documents in 'novel' category and new dlevel must be > 0
CREATE POLICY p3 ON document FOR UPDATE
  USING (cid = (SELECT cid from category WHERE cname = 'novel'))
  WITH CHECK (dlevel > 0);
---END---
---START---
-- one may only delete documents in 'manga' category
CREATE POLICY p4 ON document FOR DELETE
  USING (cid = (SELECT cid from category WHERE cname = 'manga'));
---END---
---START---
SELECT * FROM document;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Fails, since update violates WITH CHECK qual on dlevel
MERGE INTO document d
USING (SELECT 1 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge1 ', dlevel = 0;
---END---
---START---
-- Should be OK since USING and WITH CHECK quals pass
MERGE INTO document d
USING (SELECT 1 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge2 ';
---END---
---START---
-- Even when dlevel is updated explicitly, but to the existing value
MERGE INTO document d
USING (SELECT 1 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge3 ', dlevel = 1;
---END---
---START---
-- There is a MATCH for did = 3, but UPDATE's USING qual does not allow
-- updating an item in category 'science fiction'
MERGE INTO document d
USING (SELECT 3 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge ';
---END---
---START---
-- The same thing with DELETE action, but fails again because no permissions
-- to delete items in 'science fiction' category that did 3 belongs to.
MERGE INTO document d
USING (SELECT 3 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	DELETE;
---END---
---START---
-- Document with did 4 belongs to 'manga' category which is allowed for
-- deletion. But this fails because the UPDATE action is matched first and
-- UPDATE policy does not allow updation in the category.
MERGE INTO document d
USING (SELECT 4 as sdid) s
ON did = s.sdid
WHEN MATCHED AND dnotes = '' THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge '
WHEN MATCHED THEN
	DELETE;
---END---
---START---
-- UPDATE action is not matched this time because of the WHEN qual.
-- DELETE still fails because role regress_rls_bob does not have SELECT
-- privileges on 'manga' category row in the category table.
MERGE INTO document d
USING (SELECT 4 as sdid) s
ON did = s.sdid
WHEN MATCHED AND dnotes <> '' THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge '
WHEN MATCHED THEN
	DELETE;
---END---
---START---
-- OK if DELETE is replaced with DO NOTHING
MERGE INTO document d
USING (SELECT 4 as sdid) s
ON did = s.sdid
WHEN MATCHED AND dnotes <> '' THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge '
WHEN MATCHED THEN
	DO NOTHING;
---END---
---START---
SELECT * FROM document WHERE did = 4;
---END---
---START---
-- Switch to regress_rls_carol role and try the DELETE again. It should succeed
-- this time
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
MERGE INTO document d
USING (SELECT 4 as sdid) s
ON did = s.sdid
WHEN MATCHED AND dnotes <> '' THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge '
WHEN MATCHED THEN
	DELETE;
---END---
---START---
-- Switch back to regress_rls_bob role
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Try INSERT action. This fails because we are trying to insert
-- dauthor = regress_rls_dave and INSERT's WITH CHECK does not allow
-- that
MERGE INTO document d
USING (SELECT 12 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	DELETE
WHEN NOT MATCHED THEN
	INSERT VALUES (12, 11, 1, 'regress_rls_dave', 'another novel');
---END---
---START---
-- This should be fine
MERGE INTO document d
USING (SELECT 12 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	DELETE
WHEN NOT MATCHED THEN
	INSERT VALUES (12, 11, 1, 'regress_rls_bob', 'another novel');
---END---
---START---
-- ok
MERGE INTO document d
USING (SELECT 1 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge4 '
WHEN NOT MATCHED THEN
	INSERT VALUES (12, 11, 1, 'regress_rls_bob', 'another novel');
---END---
---START---
-- drop and create a new SELECT policy which prevents us from reading
-- any document except with category 'novel'
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP POLICY p1 ON document;
---END---
---START---
CREATE POLICY p1 ON document FOR SELECT
  USING (cid = (SELECT cid from category WHERE cname = 'novel'));
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- MERGE can no longer see the matching row and hence attempts the
-- NOT MATCHED action, which results in unique key violation
MERGE INTO document d
USING (SELECT 7 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge5 '
WHEN NOT MATCHED THEN
	INSERT VALUES (12, 11, 1, 'regress_rls_bob', 'another novel');
---END---
---START---
-- UPDATE action fails if new row is not visible
MERGE INTO document d
USING (SELECT 1 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge6 ',
			   cid = (SELECT cid from category WHERE cname = 'technology');
---END---
---START---
-- but OK if new row is visible
MERGE INTO document d
USING (SELECT 1 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge7 ',
			   cid = (SELECT cid from category WHERE cname = 'novel');
---END---
---START---
-- OK to insert a new row that is not visible
MERGE INTO document d
USING (SELECT 13 as sdid) s
ON did = s.sdid
WHEN MATCHED THEN
	UPDATE SET dnotes = dnotes || ' notes added by merge8 '
WHEN NOT MATCHED THEN
	INSERT VALUES (13, 44, 1, 'regress_rls_bob', 'new manga');
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
-- drop the restrictive SELECT policy so that we can look at the
-- final state of the table
DROP POLICY p1 ON document;
---END---
---START---
-- Just check everything went per plan
SELECT * FROM document;
---END---
---START---
--
-- ROLE/GROUP
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE z1 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
CREATE TABLE z2 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
GRANT SELECT ON z1,z2 TO regress_rls_group1, regress_rls_group2,
    regress_rls_bob, regress_rls_carol;
---END---
---START---
INSERT INTO z1 VALUES
    (1, 'aba'),
    (2, 'bbb'),
    (3, 'ccc'),
    (4, 'dad');
---END---
---START---
CREATE POLICY p1 ON z1 TO regress_rls_group1 USING (a % 2 = 0);
---END---
---START---
CREATE POLICY p2 ON z1 TO regress_rls_group2 USING (a % 2 = 1);
---END---
---START---
ALTER TABLE z1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
PREPARE plancache_test AS SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test;
---END---
---START---
PREPARE plancache_test2 AS WITH q AS MATERIALIZED (SELECT * FROM z1 WHERE f_leak(b)) SELECT * FROM q,z2;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test2;
---END---
---START---
PREPARE plancache_test3 AS WITH q AS MATERIALIZED (SELECT * FROM z2) SELECT * FROM q,z1 WHERE f_leak(z1.b);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test3;
---END---
---START---
SET ROLE regress_rls_group1;
---END---
---START---
SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test2;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test3;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test2;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test3;
---END---
---START---
SET ROLE regress_rls_group2;
---END---
---START---
SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test2;
---END---
---START---
EXPLAIN (COSTS OFF) EXECUTE plancache_test3;
---END---
---START---
--
-- Views should follow policy for view owner.
--
-- View and Table owner are the same.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE VIEW rls_view AS SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_bob;
---END---
---START---
-- Query as role that is not owner of view or table.  Should return all records.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Query as view/table owner.  Should return all records.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
DROP VIEW rls_view;
---END---
---START---
-- View and Table owners are different.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE VIEW rls_view AS SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_alice;
---END---
---START---
-- Query as role that is not owner of view but is owner of table.
-- Should return records based on view owner policies.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Query as role that is not owner of table but is owner of view.
-- Should return records based on view owner policies.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Query as role that is not the owner of the table or view without permissions.
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.

-- Query as role that is not the owner of the table or view with permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_carol;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Policy requiring access to another table.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE z1_blacklist (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO z1_blacklist VALUES (3), (4);
---END---
---START---
CREATE POLICY p3 ON z1 AS RESTRICTIVE USING (a NOT IN (SELECT a FROM z1_blacklist));
---END---
---START---
-- Query as role that is not owner of table but is owner of view without permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.

-- Query as role that is not the owner of the table or view without permissions.
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.

-- Query as role that is not owner of table but is owner of view with permissions.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
GRANT SELECT ON z1_blacklist TO regress_rls_bob;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Query as role that is not the owner of the table or view with permissions.
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
REVOKE SELECT ON z1_blacklist FROM regress_rls_bob;
---END---
---START---
DROP POLICY p3 ON z1;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
DROP VIEW rls_view;
---END---
---START---
--
-- Security invoker views should follow policy for current user.
--
-- View and table owner are the same.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE VIEW rls_view WITH (security_invoker) AS
    SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_bob;
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_carol;
---END---
---START---
-- Query as table owner.  Should return all records.
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Queries as other users.
-- Should return records based on current user's policies.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- View and table owners are different.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP VIEW rls_view;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE VIEW rls_view WITH (security_invoker) AS
    SELECT * FROM z1 WHERE f_leak(b);
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_alice;
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_carol;
---END---
---START---
-- Query as table owner.  Should return all records.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Queries as other users.
-- Should return records based on current user's policies.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Policy requiring access to another table.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE POLICY p3 ON z1 AS RESTRICTIVE USING (a NOT IN (SELECT a FROM z1_blacklist));
---END---
---START---
-- Query as role that is not owner of table but is owner of view without permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.

-- Query as role that is not the owner of the table or view without permissions.
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.

-- Query as role that is not owner of table but is owner of view with permissions.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
GRANT SELECT ON z1_blacklist TO regress_rls_bob;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
-- Query as role that is not the owner of the table or view without permissions.
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
--fail - permission denied.

-- Query as role that is not the owner of the table or view with permissions.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
GRANT SELECT ON z1_blacklist TO regress_rls_carol;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM rls_view;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_view;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
DROP VIEW rls_view;
---END---
---START---
--
-- Command specific
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE x1 (_gemini_pk serial PRIMARY KEY, a integer, b text, c text);
---END---
---START---
GRANT ALL ON x1 TO PUBLIC;
---END---
---START---
INSERT INTO x1 VALUES
    (1, 'abc', 'regress_rls_bob'),
    (2, 'bcd', 'regress_rls_bob'),
    (3, 'cde', 'regress_rls_carol'),
    (4, 'def', 'regress_rls_carol'),
    (5, 'efg', 'regress_rls_bob'),
    (6, 'fgh', 'regress_rls_bob'),
    (7, 'fgh', 'regress_rls_carol'),
    (8, 'fgh', 'regress_rls_carol');
---END---
---START---
CREATE POLICY p0 ON x1 FOR ALL USING (c = current_user);
---END---
---START---
CREATE POLICY p1 ON x1 FOR SELECT USING (a % 2 = 0);
---END---
---START---
CREATE POLICY p2 ON x1 FOR INSERT WITH CHECK (a % 2 = 1);
---END---
---START---
CREATE POLICY p3 ON x1 FOR UPDATE USING (a % 2 = 0);
---END---
---START---
CREATE POLICY p4 ON x1 FOR DELETE USING (a < 8);
---END---
---START---
ALTER TABLE x1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM x1 WHERE f_leak(b) ORDER BY a ASC;
---END---
---START---
UPDATE x1 SET b = b || '_updt' WHERE f_leak(b) RETURNING *;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SELECT * FROM x1 WHERE f_leak(b) ORDER BY a ASC;
---END---
---START---
UPDATE x1 SET b = b || '_updt' WHERE f_leak(b) RETURNING *;
---END---
---START---
DELETE FROM x1 WHERE f_leak(b) RETURNING *;
---END---
---START---
--
-- Duplicate Policy Names
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE y1 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
CREATE TABLE y2 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
GRANT ALL ON y1, y2 TO regress_rls_bob;
---END---
---START---
CREATE POLICY p1 ON y1 FOR ALL USING (a % 2 = 0);
---END---
---START---
CREATE POLICY p2 ON y1 FOR SELECT USING (a > 2);
---END---
---START---
CREATE POLICY p1 ON y1 FOR SELECT USING (a % 2 = 1);
---END---
---START---
--fail
CREATE POLICY p1 ON y2 FOR ALL USING (a % 2 = 0);
---END---
---START---
--OK

ALTER TABLE y1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE y2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
--
-- Expression structure with SBV
--
-- Create view as table owner.  RLS should NOT be applied.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE VIEW rls_sbv WITH (security_barrier) AS
    SELECT * FROM y1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_sbv WHERE (a = 1);
---END---
---START---
DROP VIEW rls_sbv;
---END---
---START---
-- Create view as role that does not own table.  RLS should be applied.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE VIEW rls_sbv WITH (security_barrier) AS
    SELECT * FROM y1 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM rls_sbv WHERE (a = 1);
---END---
---START---
DROP VIEW rls_sbv;
---END---
---START---
--
-- Expression structure
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
INSERT INTO y2 (SELECT x, public.fipshash(x::text) FROM generate_series(0,20) x);
---END---
---START---
CREATE POLICY p2 ON y2 USING (a % 3 = 0);
---END---
---START---
CREATE POLICY p3 ON y2 USING (a % 4 = 0);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM y2 WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM y2 WHERE f_leak(b);
---END---
---START---
--
-- Qual push-down of leaky functions, when not referring to table
--
SELECT * FROM y2 WHERE f_leak('abc');
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM y2 WHERE f_leak('abc');
---END---
---START---
CREATE TABLE test_qual_pushdown (_gemini_pk serial PRIMARY KEY, abc text);
---END---
---START---
INSERT INTO test_qual_pushdown VALUES ('abc'),('def');
---END---
---START---
SELECT * FROM y2 JOIN test_qual_pushdown ON (b = abc) WHERE f_leak(abc);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM y2 JOIN test_qual_pushdown ON (b = abc) WHERE f_leak(abc);
---END---
---START---
SELECT * FROM y2 JOIN test_qual_pushdown ON (b = abc) WHERE f_leak(b);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM y2 JOIN test_qual_pushdown ON (b = abc) WHERE f_leak(b);
---END---
---START---
DROP TABLE test_qual_pushdown;
---END---
---START---
--
-- Plancache invalidate on user change.
--
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE t1 CASCADE;
---END---
---START---
CREATE TABLE t1 (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
GRANT SELECT ON t1 TO regress_rls_bob, regress_rls_carol;
---END---
---START---
CREATE POLICY p1 ON t1 TO regress_rls_bob USING ((a % 2) = 0);
---END---
---START---
CREATE POLICY p2 ON t1 TO regress_rls_carol USING ((a % 4) = 0);
---END---
---START---
ALTER TABLE t1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
-- Prepare as regress_rls_bob
SET ROLE regress_rls_bob;
---END---
---START---
PREPARE role_inval AS SELECT * FROM t1;
---END---
---START---
-- Check plan
EXPLAIN (COSTS OFF) EXECUTE role_inval;
---END---
---START---
-- Change to regress_rls_carol
SET ROLE regress_rls_carol;
---END---
---START---
-- Check plan- should be different
EXPLAIN (COSTS OFF) EXECUTE role_inval;
---END---
---START---
-- Change back to regress_rls_bob
SET ROLE regress_rls_bob;
---END---
---START---
-- Check plan- should be back to original
EXPLAIN (COSTS OFF) EXECUTE role_inval;
---END---
---START---
--
-- CTE and RLS
--
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE t1 CASCADE;
---END---
---START---
CREATE TABLE t1 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
CREATE POLICY p1 ON t1 USING (a % 2 = 0);
---END---
---START---
ALTER TABLE t1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
GRANT ALL ON t1 TO regress_rls_bob;
---END---
---START---
INSERT INTO t1 (SELECT x, public.fipshash(x::text) FROM generate_series(0,20) x);
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
WITH cte1 AS MATERIALIZED (SELECT * FROM t1 WHERE f_leak(b)) SELECT * FROM cte1;
---END---
---START---
EXPLAIN (COSTS OFF)
WITH cte1 AS MATERIALIZED (SELECT * FROM t1 WHERE f_leak(b)) SELECT * FROM cte1;
---END---
---START---
WITH cte1 AS (UPDATE t1 SET a = a + 1 RETURNING *) SELECT * FROM cte1;
---END---
---START---
--fail
WITH cte1 AS (UPDATE t1 SET a = a RETURNING *) SELECT * FROM cte1;
---END---
---START---
--ok

WITH cte1 AS (INSERT INTO t1 VALUES (21, 'Fail') RETURNING *) SELECT * FROM cte1;
---END---
---START---
--fail
WITH cte1 AS (INSERT INTO t1 VALUES (20, 'Success') RETURNING *) SELECT * FROM cte1;
---END---
---START---
--ok

--
-- Rename Policy
--
RESET SESSION AUTHORIZATION;
---END---
---START---
ALTER POLICY p1 ON t1 RENAME TO p1;
---END---
---START---
--fail

SELECT polname, relname
    FROM pg_policy pol
    JOIN pg_class pc ON (pc.oid = pol.polrelid)
    WHERE relname = 't1';
---END---
---START---
ALTER POLICY p1 ON t1 RENAME TO p2;
---END---
---START---
--ok

SELECT polname, relname
    FROM pg_policy pol
    JOIN pg_class pc ON (pc.oid = pol.polrelid)
    WHERE relname = 't1';
---END---
---START---
--
-- Check INSERT SELECT
--
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
CREATE TABLE t2 (_gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
INSERT INTO t2 (SELECT * FROM t1);
---END---
---START---
EXPLAIN (COSTS OFF) INSERT INTO t2 (SELECT * FROM t1);
---END---
---START---
SELECT * FROM t2;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t2;
---END---
---START---
CREATE TABLE t3 AS SELECT * FROM t1;
---END---
---START---
SELECT * FROM t3;
---END---
---START---
SELECT * INTO t4 FROM t1;
---END---
---START---
SELECT * FROM t4;
---END---
---START---
--
-- RLS with JOIN
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE blog (_gemini_pk serial PRIMARY KEY, id integer, author text, post text);
---END---
---START---
CREATE TABLE comment (_gemini_pk serial PRIMARY KEY, blog_id integer, message text);
---END---
---START---
GRANT ALL ON blog, comment TO regress_rls_bob;
---END---
---START---
CREATE POLICY blog_1 ON blog USING (id % 2 = 0);
---END---
---START---
ALTER TABLE blog ENABLE ROW LEVEL SECURITY;
---END---
---START---
INSERT INTO blog VALUES
    (1, 'alice', 'blog #1'),
    (2, 'bob', 'blog #1'),
    (3, 'alice', 'blog #2'),
    (4, 'alice', 'blog #3'),
    (5, 'john', 'blog #1');
---END---
---START---
INSERT INTO comment VALUES
    (1, 'cool blog'),
    (1, 'fun blog'),
    (3, 'crazy blog'),
    (5, 'what?'),
    (4, 'insane!'),
    (2, 'who did it?');
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Check RLS JOIN with Non-RLS.
SELECT id, author, message FROM blog JOIN comment ON id = blog_id;
---END---
---START---
-- Check Non-RLS JOIN with RLS.
SELECT id, author, message FROM comment JOIN blog ON id = blog_id;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE POLICY comment_1 ON comment USING (blog_id < 4);
---END---
---START---
ALTER TABLE comment ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Check RLS JOIN RLS
SELECT id, author, message FROM blog JOIN comment ON id = blog_id;
---END---
---START---
SELECT id, author, message FROM comment JOIN blog ON id = blog_id;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP TABLE blog, comment;
---END---
---START---
--
-- Default Deny Policy
--
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP POLICY p2 ON t1;
---END---
---START---
ALTER TABLE t1 OWNER TO regress_rls_alice;
---END---
---START---
-- Check that default deny does not apply to superuser.
RESET SESSION AUTHORIZATION;
---END---
---START---
SELECT * FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1;
---END---
---START---
-- Check that default deny does not apply to table owner.
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1;
---END---
---START---
-- Check that default deny applies to non-owner/non-superuser when RLS on.
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SET row_security TO ON;
---END---
---START---
SELECT * FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM t1;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM t1;
---END---
---START---
COPY TO/FROM
--

RESET SESSION AUTHORIZATION;
DROP TABLE copy_t CASCADE;
CREATE TABLE copy_t (a integer, b text);
CREATE POLICY p1 ON copy_t USING (a % 2 = 0);

ALTER TABLE copy_t ENABLE ROW LEVEL SECURITY;

GRANT ALL ON copy_t TO regress_rls_bob, regress_rls_exempt_user;

INSERT INTO copy_t (SELECT x, public.fipshash(x::text) FROM generate_series(0,10) x);

-- Check COPY TO as Superuser/owner.
RESET SESSION AUTHORIZATION;
SET row_security TO OFF;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ',';
SET row_security TO ON;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ',';

-- Check COPY TO as user with permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
SET row_security TO OFF;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ','; --fail - would be affected by RLS
SET row_security TO ON;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ','; --ok

-- Check COPY TO as user with permissions and BYPASSRLS
SET SESSION AUTHORIZATION regress_rls_exempt_user;
SET row_security TO OFF;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ','; --ok
SET row_security TO ON;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ','; --ok

-- Check COPY TO as user without permissions. SET row_security TO OFF;
SET SESSION AUTHORIZATION regress_rls_carol;
SET row_security TO OFF;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ','; --fail - would be affected by RLS
SET row_security TO ON;
COPY (SELECT * FROM copy_t ORDER BY a ASC) TO STDOUT WITH DELIMITER ','; --fail - permission denied

-- Check COPY relation TO; keep it just one row to avoid reordering issues
RESET SESSION AUTHORIZATION;
SET row_security TO ON;
CREATE TABLE copy_rel_to (a integer, b text);
CREATE POLICY p1 ON copy_rel_to USING (a % 2 = 0);

ALTER TABLE copy_rel_to ENABLE ROW LEVEL SECURITY;

GRANT ALL ON copy_rel_to TO regress_rls_bob, regress_rls_exempt_user;

INSERT INTO copy_rel_to VALUES (1, public.fipshash('1'));

-- Check COPY TO as Superuser/owner.
RESET SESSION AUTHORIZATION;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ',';
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ',';

-- Check COPY TO as user with permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --fail - would be affected by RLS
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --ok

-- Check COPY TO as user with permissions and BYPASSRLS
SET SESSION AUTHORIZATION regress_rls_exempt_user;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --ok
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --ok

-- Check COPY TO as user without permissions. SET row_security TO OFF;
SET SESSION AUTHORIZATION regress_rls_carol;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --fail - permission denied
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --fail - permission denied

-- Check behavior with a child table.
RESET SESSION AUTHORIZATION;
SET row_security TO ON;
CREATE TABLE copy_rel_to_child () INHERITS (copy_rel_to);
INSERT INTO copy_rel_to_child VALUES (1, 'one'), (2, 'two');

-- Check COPY TO as Superuser/owner.
RESET SESSION AUTHORIZATION;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ',';
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ',';

-- Check COPY TO as user with permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --fail - would be affected by RLS
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --ok

-- Check COPY TO as user with permissions and BYPASSRLS
SET SESSION AUTHORIZATION regress_rls_exempt_user;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --ok
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --ok

-- Check COPY TO as user without permissions. SET row_security TO OFF;
SET SESSION AUTHORIZATION regress_rls_carol;
SET row_security TO OFF;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --fail - permission denied
SET row_security TO ON;
COPY copy_rel_to TO STDOUT WITH DELIMITER ','; --fail - permission denied

-- Check COPY FROM as Superuser/owner.
RESET SESSION AUTHORIZATION;
SET row_security TO OFF;
COPY copy_t FROM STDIN; --ok
1	abc
2	bcd
3	cde
4	def
\.
---END---
---START---
SET row_security TO ON;
---END---
---START---
COPY copy_t FROM STDIN; --ok
1	abc
2	bcd
3	cde
4	def
\.
---END---
---START---
COPY FROM as user with permissions.
SET SESSION AUTHORIZATION regress_rls_bob;
SET row_security TO OFF;
COPY copy_t FROM STDIN; --fail - would be affected by RLS.
SET row_security TO ON;
COPY copy_t FROM STDIN; --fail - COPY FROM not supported by RLS.

-- Check COPY FROM as user with permissions and BYPASSRLS
SET SESSION AUTHORIZATION regress_rls_exempt_user;
SET row_security TO ON;
COPY copy_t FROM STDIN; --ok
1	abc
2	bcd
3	cde
4	def
\.
---END---
---START---
-- Check COPY FROM as user without permissions.
SET SESSION AUTHORIZATION regress_rls_carol;
---END---
---START---
SET row_security TO OFF;
---END---
---START---
COPY copy_t FROM STDIN;
---END---
---START---
--fail - permission denied.
SET row_security TO ON;
---END---
---START---
COPY copy_t FROM STDIN;
---END---
---START---
--fail - permission denied.

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE copy_t;
---END---
---START---
DROP TABLE copy_rel_to CASCADE;
---END---
---START---
-- Check WHERE CURRENT OF
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE current_check (_gemini_pk serial PRIMARY KEY, currentid integer, payload text, rlsuser text);
---END---
---START---
GRANT ALL ON current_check TO PUBLIC;
---END---
---START---
INSERT INTO current_check VALUES
    (1, 'abc', 'regress_rls_bob'),
    (2, 'bcd', 'regress_rls_bob'),
    (3, 'cde', 'regress_rls_bob'),
    (4, 'def', 'regress_rls_bob');
---END---
---START---
CREATE POLICY p1 ON current_check FOR SELECT USING (currentid % 2 = 0);
---END---
---START---
CREATE POLICY p2 ON current_check FOR DELETE USING (currentid = 4 AND rlsuser = current_user);
---END---
---START---
CREATE POLICY p3 ON current_check FOR UPDATE USING (currentid = 4) WITH CHECK (rlsuser = current_user);
---END---
---START---
ALTER TABLE current_check ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Can SELECT even rows
SELECT * FROM current_check;
---END---
---START---
-- Cannot UPDATE row 2
UPDATE current_check SET payload = payload || '_new' WHERE currentid = 2 RETURNING *;
---END---
---START---
BEGIN;
---END---
---START---
DECLARE current_check_cursor SCROLL CURSOR FOR SELECT * FROM current_check;
---END---
---START---
-- Returns rows that can be seen according to SELECT policy, like plain SELECT
-- above (even rows)
FETCH ABSOLUTE 1 FROM current_check_cursor;
---END---
---START---
-- Still cannot UPDATE row 2 through cursor
UPDATE current_check SET payload = payload || '_new' WHERE CURRENT OF current_check_cursor RETURNING *;
---END---
---START---
-- Can update row 4 through cursor, which is the next visible row
FETCH RELATIVE 1 FROM current_check_cursor;
---END---
---START---
UPDATE current_check SET payload = payload || '_new' WHERE CURRENT OF current_check_cursor RETURNING *;
---END---
---START---
SELECT * FROM current_check;
---END---
---START---
-- Plan should be a subquery TID scan
EXPLAIN (COSTS OFF) UPDATE current_check SET payload = payload WHERE CURRENT OF current_check_cursor;
---END---
---START---
-- Similarly can only delete row 4
FETCH ABSOLUTE 1 FROM current_check_cursor;
---END---
---START---
DELETE FROM current_check WHERE CURRENT OF current_check_cursor RETURNING *;
---END---
---START---
FETCH RELATIVE 1 FROM current_check_cursor;
---END---
---START---
DELETE FROM current_check WHERE CURRENT OF current_check_cursor RETURNING *;
---END---
---START---
SELECT * FROM current_check;
---END---
---START---
COMMIT;
---END---
---START---
--
-- check pg_stats view filtering
--
SET row_security TO ON;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
ANALYZE current_check;
---END---
---START---
-- Stats visible
SELECT row_security_active('current_check');
---END---
---START---
SELECT attname, most_common_vals FROM pg_stats
  WHERE tablename = 'current_check'
  ORDER BY 1;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
-- Stats not visible
SELECT row_security_active('current_check');
---END---
---START---
SELECT attname, most_common_vals FROM pg_stats
  WHERE tablename = 'current_check'
  ORDER BY 1;
---END---
---START---
--
-- Collation support
--
BEGIN;
---END---
---START---
CREATE TABLE coll_t (c) AS VALUES ('bar'::text);
---END---
---START---
CREATE POLICY coll_p ON coll_t USING (c < ('foo'::text COLLATE "C"));
---END---
---START---
ALTER TABLE coll_t ENABLE ROW LEVEL SECURITY;
---END---
---START---
GRANT SELECT ON coll_t TO regress_rls_alice;
---END---
---START---
SELECT (string_to_array(polqual, ':'))[7] AS inputcollid FROM pg_policy WHERE polrelid = 'coll_t'::regclass;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM coll_t;
---END---
---START---
ROLLBACK;
---END---
---START---
--
-- Shared Object Dependencies
--
RESET SESSION AUTHORIZATION;
---END---
---START---
BEGIN;
---END---
---START---
CREATE ROLE regress_rls_eve;
---END---
---START---
CREATE ROLE regress_rls_frank;
---END---
---START---
CREATE TABLE tbl1 (c) AS VALUES ('bar'::text);
---END---
---START---
GRANT SELECT ON TABLE tbl1 TO regress_rls_eve;
---END---
---START---
CREATE POLICY P ON tbl1 TO regress_rls_eve, regress_rls_frank USING (true);
---END---
---START---
SELECT refclassid::regclass, deptype
  FROM pg_depend
  WHERE classid = 'pg_policy'::regclass
  AND refobjid = 'tbl1'::regclass;
---END---
---START---
SELECT refclassid::regclass, deptype
  FROM pg_shdepend
  WHERE classid = 'pg_policy'::regclass
  AND refobjid IN ('regress_rls_eve'::regrole, 'regress_rls_frank'::regrole);
---END---
---START---
SAVEPOINT q;
---END---
---START---
DROP ROLE regress_rls_eve;
---END---
---START---
--fails due to dependency on POLICY p
ROLLBACK TO q;
---END---
---START---
ALTER POLICY p ON tbl1 TO regress_rls_frank USING (true);
---END---
---START---
SAVEPOINT q;
---END---
---START---
DROP ROLE regress_rls_eve;
---END---
---START---
--fails due to dependency on GRANT SELECT
ROLLBACK TO q;
---END---
---START---
REVOKE ALL ON TABLE tbl1 FROM regress_rls_eve;
---END---
---START---
SAVEPOINT q;
---END---
---START---
DROP ROLE regress_rls_eve;
---END---
---START---
--succeeds
ROLLBACK TO q;
---END---
---START---
SAVEPOINT q;
---END---
---START---
DROP ROLE regress_rls_frank;
---END---
---START---
--fails due to dependency on POLICY p
ROLLBACK TO q;
---END---
---START---
DROP POLICY p ON tbl1;
---END---
---START---
SAVEPOINT q;
---END---
---START---
DROP ROLE regress_rls_frank;
---END---
---START---
-- succeeds
ROLLBACK TO q;
---END---
---START---
ROLLBACK;
---END---
---START---
-- cleanup

--
-- Policy expression handling
--
BEGIN;
---END---
---START---
CREATE TABLE t (c) AS VALUES ('bar'::text);
---END---
---START---
CREATE POLICY p ON t USING (max(c));
---END---
---START---
-- fails: aggregate functions are not allowed in policy expressions
ROLLBACK;
---END---
---START---
--
-- Non-target relations are only subject to SELECT policies
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE r1 (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE TABLE r2 (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO r1 VALUES (10), (20);
---END---
---START---
INSERT INTO r2 VALUES (10), (20);
---END---
---START---
GRANT ALL ON r1, r2 TO regress_rls_bob;
---END---
---START---
CREATE POLICY p1 ON r1 USING (true);
---END---
---START---
ALTER TABLE r1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
CREATE POLICY p1 ON r2 FOR SELECT USING (true);
---END---
---START---
CREATE POLICY p2 ON r2 FOR INSERT WITH CHECK (false);
---END---
---START---
CREATE POLICY p3 ON r2 FOR UPDATE USING (false);
---END---
---START---
CREATE POLICY p4 ON r2 FOR DELETE USING (false);
---END---
---START---
ALTER TABLE r2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_bob;
---END---
---START---
SELECT * FROM r1;
---END---
---START---
SELECT * FROM r2;
---END---
---START---
-- r2 is read-only
INSERT INTO r2 VALUES (2);
---END---
---START---
-- Not allowed
UPDATE r2 SET a = 2 RETURNING *;
---END---
---START---
-- Updates nothing
DELETE FROM r2 RETURNING *;
---END---
---START---
-- Deletes nothing

-- r2 can be used as a non-target relation in DML
INSERT INTO r1 SELECT a + 1 FROM r2 RETURNING *;
---END---
---START---
-- OK
UPDATE r1 SET a = r2.a + 2 FROM r2 WHERE r1.a = r2.a RETURNING *;
---END---
---START---
-- OK
DELETE FROM r1 USING r2 WHERE r1.a = r2.a + 2 RETURNING *;
---END---
---START---
-- OK
SELECT * FROM r1;
---END---
---START---
SELECT * FROM r2;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
DROP TABLE r1;
---END---
---START---
DROP TABLE r2;
---END---
---START---
--
-- FORCE ROW LEVEL SECURITY applies RLS to owners too
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security = on;
---END---
---START---
CREATE TABLE r1 (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO r1 VALUES (10), (20);
---END---
---START---
CREATE POLICY p1 ON r1 USING (false);
---END---
---START---
ALTER TABLE r1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r1 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- No error, but no rows
TABLE r1;
---END---
---START---
-- RLS error
INSERT INTO r1 VALUES (1);
---END---
---START---
-- No error (unable to see any rows to update)
UPDATE r1 SET a = 1;
---END---
---START---
TABLE r1;
---END---
---START---
-- No error (unable to see any rows to delete)
DELETE FROM r1;
---END---
---START---
TABLE r1;
---END---
---START---
SET row_security = off;
---END---
---START---
-- these all fail, would be affected by RLS
TABLE r1;
---END---
---START---
UPDATE r1 SET a = 1;
---END---
---START---
DELETE FROM r1;
---END---
---START---
DROP TABLE r1;
---END---
---START---
--
-- FORCE ROW LEVEL SECURITY does not break RI
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security = on;
---END---
---START---
CREATE TABLE r1 (a int PRIMARY KEY);
---END---
---START---
CREATE TABLE r2 (_gemini_pk serial PRIMARY KEY, a integer REFERENCES r1);
---END---
---START---
INSERT INTO r1 VALUES (10), (20);
---END---
---START---
INSERT INTO r2 VALUES (10), (20);
---END---
---START---
-- Create policies on r2 which prevent the
-- owner from seeing any rows, but RI should
-- still see them.
CREATE POLICY p1 ON r2 USING (false);
---END---
---START---
ALTER TABLE r2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r2 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- Errors due to rows in r2
DELETE FROM r1;
---END---
---START---
-- Reset r2 to no-RLS
DROP POLICY p1 ON r2;
---END---
---START---
ALTER TABLE r2 NO FORCE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r2 DISABLE ROW LEVEL SECURITY;
---END---
---START---
-- clean out r2 for INSERT test below
DELETE FROM r2;
---END---
---START---
-- Change r1 to not allow rows to be seen
CREATE POLICY p1 ON r1 USING (false);
---END---
---START---
ALTER TABLE r1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r1 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- No rows seen
TABLE r1;
---END---
---START---
-- No error, RI still sees that row exists in r1
INSERT INTO r2 VALUES (10);
---END---
---START---
DROP TABLE r2;
---END---
---START---
DROP TABLE r1;
---END---
---START---
-- Ensure cascaded DELETE works
CREATE TABLE r1 (a int PRIMARY KEY);
---END---
---START---
CREATE TABLE r2 (_gemini_pk serial PRIMARY KEY, a integer REFERENCES r1 ON DELETE CASCADE);
---END---
---START---
INSERT INTO r1 VALUES (10), (20);
---END---
---START---
INSERT INTO r2 VALUES (10), (20);
---END---
---START---
-- Create policies on r2 which prevent the
-- owner from seeing any rows, but RI should
-- still see them.
CREATE POLICY p1 ON r2 USING (false);
---END---
---START---
ALTER TABLE r2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r2 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- Deletes all records from both
DELETE FROM r1;
---END---
---START---
-- Remove FORCE from r2
ALTER TABLE r2 NO FORCE ROW LEVEL SECURITY;
---END---
---START---
-- As owner, we now bypass RLS
-- verify no rows in r2 now
TABLE r2;
---END---
---START---
DROP TABLE r2;
---END---
---START---
DROP TABLE r1;
---END---
---START---
-- Ensure cascaded UPDATE works
CREATE TABLE r1 (a int PRIMARY KEY);
---END---
---START---
CREATE TABLE r2 (_gemini_pk serial PRIMARY KEY, a integer REFERENCES r1 ON UPDATE CASCADE);
---END---
---START---
INSERT INTO r1 VALUES (10), (20);
---END---
---START---
INSERT INTO r2 VALUES (10), (20);
---END---
---START---
-- Create policies on r2 which prevent the
-- owner from seeing any rows, but RI should
-- still see them.
CREATE POLICY p1 ON r2 USING (false);
---END---
---START---
ALTER TABLE r2 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r2 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- Updates records in both
UPDATE r1 SET a = a+5;
---END---
---START---
-- Remove FORCE from r2
ALTER TABLE r2 NO FORCE ROW LEVEL SECURITY;
---END---
---START---
-- As owner, we now bypass RLS
-- verify records in r2 updated
TABLE r2;
---END---
---START---
DROP TABLE r2;
---END---
---START---
DROP TABLE r1;
---END---
---START---
--
-- Test INSERT+RETURNING applies SELECT policies as
-- WithCheckOptions (meaning an error is thrown)
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security = on;
---END---
---START---
CREATE TABLE r1 (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE POLICY p1 ON r1 FOR SELECT USING (false);
---END---
---START---
CREATE POLICY p2 ON r1 FOR INSERT WITH CHECK (true);
---END---
---START---
ALTER TABLE r1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r1 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- Works fine
INSERT INTO r1 VALUES (10), (20);
---END---
---START---
-- No error, but no rows
TABLE r1;
---END---
---START---
SET row_security = off;
---END---
---START---
-- fail, would be affected by RLS
TABLE r1;
---END---
---START---
SET row_security = on;
---END---
---START---
-- Error
INSERT INTO r1 VALUES (10), (20) RETURNING *;
---END---
---START---
DROP TABLE r1;
---END---
---START---
--
-- Test UPDATE+RETURNING applies SELECT policies as
-- WithCheckOptions (meaning an error is thrown)
--
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SET row_security = on;
---END---
---START---
CREATE TABLE r1 (a int PRIMARY KEY);
---END---
---START---
CREATE POLICY p1 ON r1 FOR SELECT USING (a < 20);
---END---
---START---
CREATE POLICY p2 ON r1 FOR UPDATE USING (a < 20) WITH CHECK (true);
---END---
---START---
CREATE POLICY p3 ON r1 FOR INSERT WITH CHECK (true);
---END---
---START---
INSERT INTO r1 VALUES (10);
---END---
---START---
ALTER TABLE r1 ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE r1 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- Works fine
UPDATE r1 SET a = 30;
---END---
---START---
-- Show updated rows
ALTER TABLE r1 NO FORCE ROW LEVEL SECURITY;
---END---
---START---
TABLE r1;
---END---
---START---
-- reset value in r1 for test with RETURNING
UPDATE r1 SET a = 10;
---END---
---START---
-- Verify row reset
TABLE r1;
---END---
---START---
ALTER TABLE r1 FORCE ROW LEVEL SECURITY;
---END---
---START---
-- Error
UPDATE r1 SET a = 30 RETURNING *;
---END---
---START---
-- UPDATE path of INSERT ... ON CONFLICT DO UPDATE should also error out
INSERT INTO r1 VALUES (10)
    ON CONFLICT (a) DO UPDATE SET a = 30 RETURNING *;
---END---
---START---
-- Should still error out without RETURNING (use of arbiter always requires
-- SELECT permissions)
INSERT INTO r1 VALUES (10)
    ON CONFLICT (a) DO UPDATE SET a = 30;
---END---
---START---
INSERT INTO r1 VALUES (10)
    ON CONFLICT ON CONSTRAINT r1_pkey DO UPDATE SET a = 30;
---END---
---START---
DROP TABLE r1;
---END---
---START---
-- Check dependency handling
RESET SESSION AUTHORIZATION;
---END---
---START---
CREATE TABLE dep1 (_gemini_pk serial PRIMARY KEY, c1 integer);
---END---
---START---
CREATE TABLE dep2 (_gemini_pk serial PRIMARY KEY, c1 integer);
---END---
---START---
CREATE POLICY dep_p1 ON dep1 TO regress_rls_bob USING (c1 > (select max(dep2.c1) from dep2));
---END---
---START---
ALTER POLICY dep_p1 ON dep1 TO regress_rls_bob,regress_rls_carol;
---END---
---START---
-- Should return one
SELECT count(*) = 1 FROM pg_depend
				   WHERE objid = (SELECT oid FROM pg_policy WHERE polname = 'dep_p1')
					 AND refobjid = (SELECT oid FROM pg_class WHERE relname = 'dep2');
---END---
---START---
ALTER POLICY dep_p1 ON dep1 USING (true);
---END---
---START---
-- Should return one
SELECT count(*) = 1 FROM pg_shdepend
				   WHERE objid = (SELECT oid FROM pg_policy WHERE polname = 'dep_p1')
					 AND refobjid = (SELECT oid FROM pg_authid WHERE rolname = 'regress_rls_bob');
---END---
---START---
-- Should return one
SELECT count(*) = 1 FROM pg_shdepend
				   WHERE objid = (SELECT oid FROM pg_policy WHERE polname = 'dep_p1')
					 AND refobjid = (SELECT oid FROM pg_authid WHERE rolname = 'regress_rls_carol');
---END---
---START---
-- Should return zero
SELECT count(*) = 0 FROM pg_depend
				   WHERE objid = (SELECT oid FROM pg_policy WHERE polname = 'dep_p1')
					 AND refobjid = (SELECT oid FROM pg_class WHERE relname = 'dep2');
---END---
---START---
-- DROP OWNED BY testing
RESET SESSION AUTHORIZATION;
---END---
---START---
CREATE ROLE regress_rls_dob_role1;
---END---
---START---
CREATE ROLE regress_rls_dob_role2;
---END---
---START---
CREATE TABLE dob_t1 (_gemini_pk serial PRIMARY KEY, c1 integer);
---END---
---START---
CREATE TABLE dob_t2 (_gemini_pk serial PRIMARY KEY, c1 integer) PARTITION BY range (c1);
---END---
---START---
CREATE POLICY p1 ON dob_t1 TO regress_rls_dob_role1 USING (true);
---END---
---START---
DROP OWNED BY regress_rls_dob_role1;
---END---
---START---
DROP POLICY p1 ON dob_t1;
---END---
---START---
-- should fail, already gone

CREATE POLICY p1 ON dob_t1 TO regress_rls_dob_role1,regress_rls_dob_role2 USING (true);
---END---
---START---
DROP OWNED BY regress_rls_dob_role1;
---END---
---START---
DROP POLICY p1 ON dob_t1;
---END---
---START---
-- should succeed

-- same cases with duplicate polroles entries
CREATE POLICY p1 ON dob_t1 TO regress_rls_dob_role1,regress_rls_dob_role1 USING (true);
---END---
---START---
DROP OWNED BY regress_rls_dob_role1;
---END---
---START---
DROP POLICY p1 ON dob_t1;
---END---
---START---
-- should fail, already gone

CREATE POLICY p1 ON dob_t1 TO regress_rls_dob_role1,regress_rls_dob_role1,regress_rls_dob_role2 USING (true);
---END---
---START---
DROP OWNED BY regress_rls_dob_role1;
---END---
---START---
DROP POLICY p1 ON dob_t1;
---END---
---START---
-- should succeed

-- partitioned target
CREATE POLICY p1 ON dob_t2 TO regress_rls_dob_role1,regress_rls_dob_role2 USING (true);
---END---
---START---
DROP OWNED BY regress_rls_dob_role1;
---END---
---START---
DROP POLICY p1 ON dob_t2;
---END---
---START---
-- should succeed

DROP USER regress_rls_dob_role1;
---END---
---START---
DROP USER regress_rls_dob_role2;
---END---
---START---
CREATE TABLE ref_tbl (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO ref_tbl VALUES (1);
---END---
---START---
CREATE TABLE rls_tbl (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO rls_tbl VALUES (10);
---END---
---START---
ALTER TABLE rls_tbl ENABLE ROW LEVEL SECURITY;
---END---
---START---
CREATE POLICY p1 ON rls_tbl USING (EXISTS (SELECT 1 FROM ref_tbl));
---END---
---START---
GRANT SELECT ON ref_tbl TO regress_rls_bob;
---END---
---START---
GRANT SELECT ON rls_tbl TO regress_rls_bob;
---END---
---START---
CREATE VIEW rls_view AS SELECT * FROM rls_tbl;
---END---
---START---
ALTER VIEW rls_view OWNER TO regress_rls_bob;
---END---
---START---
GRANT SELECT ON rls_view TO regress_rls_alice;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
SELECT * FROM ref_tbl;
---END---
---START---
-- Permission denied
SELECT * FROM rls_tbl;
---END---
---START---
-- Permission denied
SELECT * FROM rls_view;
---END---
---START---
-- OK
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP VIEW rls_view;
---END---
---START---
DROP TABLE rls_tbl;
---END---
---START---
DROP TABLE ref_tbl;
---END---
---START---
CREATE TABLE rls_tbl (_gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO rls_tbl SELECT x/10 FROM generate_series(1, 100) x;
---END---
---START---
ANALYZE rls_tbl;
---END---
---START---
ALTER TABLE rls_tbl ENABLE ROW LEVEL SECURITY;
---END---
---START---
GRANT SELECT ON rls_tbl TO regress_rls_alice;
---END---
---START---
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE FUNCTION op_leak(int, int) RETURNS bool
    AS 'BEGIN RAISE NOTICE ''op_leak => %, %'', $1, $2; RETURN $1 < $2; END'
    LANGUAGE plpgsql;
---END---
---START---
CREATE OPERATOR <<< (procedure = op_leak, leftarg = int, rightarg = int,
                     restrict = scalarltsel);
---END---
---START---
SELECT * FROM rls_tbl WHERE a <<< 1000;
---END---
---START---
DROP OPERATOR <<< (int, int);
---END---
---START---
DROP FUNCTION op_leak(int, int);
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE rls_tbl;
---END---
---START---
-- Bug #16006: whole-row Vars in a policy don't play nice with sub-selects
SET SESSION AUTHORIZATION regress_rls_alice;
---END---
---START---
CREATE TABLE rls_tbl (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer);
---END---
---START---
CREATE POLICY p1 ON rls_tbl USING (rls_tbl >= ROW(1,1,1));
---END---
---START---
ALTER TABLE rls_tbl ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE rls_tbl FORCE ROW LEVEL SECURITY;
---END---
---START---
INSERT INTO rls_tbl SELECT 10, 20, 30;
---END---
---START---
EXPLAIN (VERBOSE, COSTS OFF)
INSERT INTO rls_tbl
  SELECT * FROM (SELECT b, c FROM rls_tbl ORDER BY a) ss;
---END---
---START---
INSERT INTO rls_tbl
  SELECT * FROM (SELECT b, c FROM rls_tbl ORDER BY a) ss;
---END---
---START---
SELECT * FROM rls_tbl;
---END---
---START---
DROP TABLE rls_tbl;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
CREATE TABLE rls_t (_gemini_pk serial PRIMARY KEY, c text);
---END---
---START---
insert into rls_t values ('invisible to bob');
---END---
---START---
alter table rls_t enable row level security;
---END---
---START---
grant select on rls_t to regress_rls_alice, regress_rls_bob;
---END---
---START---
create policy p1 on rls_t for select to regress_rls_alice using (true);
---END---
---START---
create policy p2 on rls_t for select to regress_rls_bob using (false);
---END---
---START---
create function rls_f () returns setof rls_t
  stable language sql
  as $$ select * from rls_t $$;
---END---
---START---
prepare q as select current_user, * from rls_f();
---END---
---START---
set role regress_rls_alice;
---END---
---START---
execute q;
---END---
---START---
set role regress_rls_bob;
---END---
---START---
execute q;
---END---
---START---
RESET ROLE;
---END---
---START---
DROP FUNCTION rls_f();
---END---
---START---
DROP TABLE rls_t;
---END---
---START---
--
-- Clean up objects
--
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP SCHEMA regress_rls_schema CASCADE;
---END---
---START---
DROP USER regress_rls_alice;
---END---
---START---
DROP USER regress_rls_bob;
---END---
---START---
DROP USER regress_rls_carol;
---END---
---START---
DROP USER regress_rls_dave;
---END---
---START---
DROP USER regress_rls_exempt_user;
---END---
---START---
DROP ROLE regress_rls_group1;
---END---
---START---
DROP ROLE regress_rls_group2;
---END---
---START---
-- Arrange to have a few policies left over, for testing
-- pg_dump/pg_restore
CREATE SCHEMA regress_rls_schema;
---END---
---START---
CREATE TABLE rls_tbl (_gemini_pk serial PRIMARY KEY, c1 integer);
---END---
---START---
ALTER TABLE rls_tbl ENABLE ROW LEVEL SECURITY;
---END---
---START---
CREATE POLICY p1 ON rls_tbl USING (c1 > 5);
---END---
---START---
CREATE POLICY p2 ON rls_tbl FOR SELECT USING (c1 <= 3);
---END---
---START---
CREATE POLICY p3 ON rls_tbl FOR UPDATE USING (c1 <= 3) WITH CHECK (c1 > 5);
---END---
---START---
CREATE POLICY p4 ON rls_tbl FOR DELETE USING (c1 <= 3);
---END---
---START---
CREATE TABLE rls_tbl_force (_gemini_pk serial PRIMARY KEY, c1 integer);
---END---
---START---
ALTER TABLE rls_tbl_force ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE rls_tbl_force FORCE ROW LEVEL SECURITY;
---END---
---START---
CREATE POLICY p1 ON rls_tbl_force USING (c1 = 5) WITH CHECK (c1 < 5);
---END---
---START---
CREATE POLICY p2 ON rls_tbl_force FOR SELECT USING (c1 = 8);
---END---
---START---
CREATE POLICY p3 ON rls_tbl_force FOR UPDATE USING (c1 = 8) WITH CHECK (c1 >= 5);
---END---
---START---
CREATE POLICY p4 ON rls_tbl_force FOR DELETE USING (c1 = 8);
---END---
