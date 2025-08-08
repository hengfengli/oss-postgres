---START---
--
-- Tests for some likely failure cases with combo cmin/cmax mechanism
--
DROP TABLE IF EXISTS combocidtest;

CREATE TABLE combocidtest (_gemini_pk serial PRIMARY KEY, foobar integer);
---END---
---START---
BEGIN;
---END---
---START---
-- a few dummy ops to push up the CommandId counter
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest VALUES (1);
---END---
---START---
INSERT INTO combocidtest VALUES (2);
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
UPDATE combocidtest SET foobar = foobar + 10;
---END---
---START---
-- here we should see only updated tuples
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
ROLLBACK TO s1;
---END---
---START---
-- now we should see old tuples, but with combo CIDs starting at 0
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
COMMIT;
---END---
---START---
-- combo data is not there anymore, but should still see tuples
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
-- Test combo CIDs with portals
BEGIN;
---END---
---START---
INSERT INTO combocidtest VALUES (333);
---END---
---START---
DECLARE c CURSOR FOR SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
DELETE FROM combocidtest;
---END---
---START---
FETCH ALL FROM c;
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
-- check behavior with locked tuples
BEGIN;
---END---
---START---
-- a few dummy ops to push up the CommandId counter
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest SELECT 1 LIMIT 0;
---END---
---START---
INSERT INTO combocidtest VALUES (444);
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
SAVEPOINT s1;
---END---
---START---
-- this doesn't affect cmin
SELECT ctid,cmin,* FROM combocidtest FOR UPDATE;
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
-- but this does
UPDATE combocidtest SET foobar = foobar + 10;
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
ROLLBACK TO s1;
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT ctid,cmin,* FROM combocidtest;
---END---
---START---
-- test for bug reported in
-- CABRT9RC81YUf1=jsmWopcKJEro=VoeG2ou6sPwyOUTx_qteRsg@mail.gmail.com
CREATE TABLE IF NOT EXISTS testcase(
	id int PRIMARY KEY,
	balance numeric
);
---END---
---START---
INSERT INTO testcase VALUES (1, 0);
---END---
---START---
BEGIN;
---END---
---START---
SELECT * FROM testcase WHERE testcase.id = 1 FOR UPDATE;
---END---
---START---
UPDATE testcase SET balance = balance + 400 WHERE id=1;
---END---
---START---
SAVEPOINT subxact;
---END---
---START---
UPDATE testcase SET balance = balance - 100 WHERE id=1;
---END---
---START---
ROLLBACK TO SAVEPOINT subxact;
---END---
---START---
-- should return one tuple
SELECT * FROM testcase WHERE id = 1 FOR UPDATE;
---END---
---START---
ROLLBACK;
---END---
---START---
DROP TABLE testcase;
---END---
