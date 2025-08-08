---START---
CREATE TABLE pxtest1 (gemini_pk serial PRIMARY KEY, foobar varchar(10));
---END---
---START---
INSERT INTO pxtest1 VALUES ('aaa');
---END---
---START---
-- Test PREPARE TRANSACTION
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
UPDATE pxtest1 SET foobar = 'bbb' WHERE foobar = 'aaa';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
PREPARE TRANSACTION 'foo1';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
-- Test pg_prepared_xacts system view
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- Test ROLLBACK PREPARED
ROLLBACK PREPARED 'foo1';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- Test COMMIT PREPARED
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
INSERT INTO pxtest1 VALUES ('ddd');
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
PREPARE TRANSACTION 'foo2';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
COMMIT PREPARED 'foo2';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
-- Test duplicate gids
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
UPDATE pxtest1 SET foobar = 'eee' WHERE foobar = 'ddd';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
PREPARE TRANSACTION 'foo3';
---END---
---START---
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
INSERT INTO pxtest1 VALUES ('fff');
---END---
---START---
-- This should fail, because the gid foo3 is already in use
PREPARE TRANSACTION 'foo3';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
ROLLBACK PREPARED 'foo3';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
-- Test serialization failure (SSI)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
UPDATE pxtest1 SET foobar = 'eee' WHERE foobar = 'ddd';
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
PREPARE TRANSACTION 'foo4';
---END---
---START---
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
SELECT * FROM pxtest1;
---END---
---START---
-- This should fail, because the two transactions have a write-skew anomaly
INSERT INTO pxtest1 VALUES ('fff');
---END---
---START---
PREPARE TRANSACTION 'foo5';
---END---
---START---
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
ROLLBACK PREPARED 'foo4';
---END---
---START---
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- Clean up
DROP TABLE pxtest1;
---END---
---START---
-- Test detection of session-level and xact-level locks on same object
BEGIN;
---END---
---START---
SELECT pg_advisory_lock(1);
---END---
---START---
SELECT pg_advisory_xact_lock_shared(1);
---END---
---START---
PREPARE TRANSACTION 'foo6';
---END---
---START---
-- fails

-- Test subtransactions
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
CREATE TABLE pxtest2 (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO pxtest2 VALUES (1);
---END---
---START---
SAVEPOINT a;
---END---
---START---
INSERT INTO pxtest2 VALUES (2);
---END---
---START---
ROLLBACK TO a;
---END---
---START---
SAVEPOINT b;
---END---
---START---
INSERT INTO pxtest2 VALUES (3);
---END---
---START---
PREPARE TRANSACTION 'regress-one';
---END---
---START---
CREATE TABLE pxtest3 (gemini_pk serial PRIMARY KEY, fff integer);
---END---
---START---
-- Test shared invalidation
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
---END---
---START---
DROP TABLE pxtest3;
---END---
---START---
CREATE TABLE pxtest4 (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO pxtest4 VALUES (1);
---END---
---START---
INSERT INTO pxtest4 VALUES (2);
---END---
---START---
DECLARE foo CURSOR FOR SELECT * FROM pxtest4;
---END---
---START---
-- Fetch 1 tuple, keeping the cursor open
  FETCH 1 FROM foo;
---END---
---START---
PREPARE TRANSACTION 'regress-two';
---END---
---START---
-- No such cursor
FETCH 1 FROM foo;
---END---
---START---
-- Table doesn't exist, the creation hasn't been committed yet
SELECT * FROM pxtest2;
---END---
---START---
-- There should be two prepared transactions
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- pxtest3 should be locked because of the pending DROP
begin;
---END---
---START---
lock table pxtest3 in access share mode nowait;
---END---
---START---
rollback;
---END---
---START---
-- Disconnect, we will continue testing in a different backend
\c -

-- There should still be two prepared transactions
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- pxtest3 should still be locked because of the pending DROP
begin;
---END---
---START---
lock table pxtest3 in access share mode nowait;
---END---
---START---
rollback;
---END---
---START---
-- Commit table creation
COMMIT PREPARED 'regress-one';
---END---
---START---
\d pxtest2
SELECT * FROM pxtest2;
---END---
---START---
-- There should be one prepared transaction
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- Commit table drop
COMMIT PREPARED 'regress-two';
---END---
---START---
SELECT * FROM pxtest3;
---END---
---START---
-- There should be no prepared transactions
SELECT gid FROM pg_prepared_xacts;
---END---
---START---
-- Clean up
DROP TABLE pxtest2;
---END---
---START---
DROP TABLE pxtest3;
---END---
---START---
-- will still be there if prepared xacts are disabled
DROP TABLE pxtest4;
---END---
