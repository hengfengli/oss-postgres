---START---
--
-- FOREIGN KEY
--

-- MATCH FULL
--
-- First test, check and cascade
--
CREATE TABLE PKTABLE ( ptest1 int PRIMARY KEY, ptest2 text );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int REFERENCES PKTABLE MATCH FULL ON DELETE CASCADE ON UPDATE CASCADE, ftest2 int );
---END---
---START---

-- Insert test data into PKTABLE
INSERT INTO PKTABLE VALUES (1, 'Test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 'Test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (3, 'Test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (4, 'Test4');
---END---
---START---
INSERT INTO PKTABLE VALUES (5, 'Test5');
---END---
---START---

-- Insert successful rows into FK TABLE
INSERT INTO FKTABLE VALUES (1, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 3);
---END---
---START---
INSERT INTO FKTABLE VALUES (3, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 1);
---END---
---START---

-- Insert a failed row into FK TABLE
INSERT INTO FKTABLE VALUES (100, 2);
---END---
---START---

-- Check FKTABLE
SELECT * FROM FKTABLE;
---END---
---START---

-- Delete a row from PK TABLE
DELETE FROM PKTABLE WHERE ptest1=1;
---END---
---START---

-- Check FKTABLE for removal of matched row
SELECT * FROM FKTABLE;
---END---
---START---

-- Update a row from PK TABLE
UPDATE PKTABLE SET ptest1=1 WHERE ptest1=2;
---END---
---START---

-- Check FKTABLE for update of matched row
SELECT * FROM FKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

--
-- check set NULL and table constraint on multiple columns
--
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 text, PRIMARY KEY(ptest1, ptest2) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int, ftest2 int, ftest3 int, CONSTRAINT constrname FOREIGN KEY(ftest1, ftest2)
                       REFERENCES PKTABLE MATCH FULL ON DELETE SET NULL ON UPDATE SET NULL);
---END---
---START---

-- Test comments
COMMENT ON CONSTRAINT constrname_wrong ON FKTABLE IS 'fk constraint comment';
---END---
---START---
COMMENT ON CONSTRAINT constrname ON FKTABLE IS 'fk constraint comment';
---END---
---START---
COMMENT ON CONSTRAINT constrname ON FKTABLE IS NULL;
---END---
---START---

-- Insert test data into PKTABLE
INSERT INTO PKTABLE VALUES (1, 2, 'Test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, 'Test1-2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 4, 'Test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (3, 6, 'Test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (4, 8, 'Test4');
---END---
---START---
INSERT INTO PKTABLE VALUES (5, 10, 'Test5');
---END---
---START---

-- Insert successful rows into FK TABLE
INSERT INTO FKTABLE VALUES (1, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (1, 3, 5);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 4, 8);
---END---
---START---
INSERT INTO FKTABLE VALUES (3, 6, 12);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, NULL, 0);
---END---
---START---

-- Insert failed rows into FK TABLE
INSERT INTO FKTABLE VALUES (100, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (1, NULL, 4);
---END---
---START---

-- Check FKTABLE
SELECT * FROM FKTABLE;
---END---
---START---

-- Delete a row from PK TABLE
DELETE FROM PKTABLE WHERE ptest1=1 and ptest2=2;
---END---
---START---

-- Check FKTABLE for removal of matched row
SELECT * FROM FKTABLE;
---END---
---START---

-- Delete another row from PK TABLE
DELETE FROM PKTABLE WHERE ptest1=5 and ptest2=10;
---END---
---START---

-- Check FKTABLE (should be no change)
SELECT * FROM FKTABLE;
---END---
---START---

-- Update a row from PK TABLE
UPDATE PKTABLE SET ptest1=1 WHERE ptest1=2;
---END---
---START---

-- Check FKTABLE for update of matched row
SELECT * FROM FKTABLE;
---END---
---START---

-- Check update with part of key null
UPDATE FKTABLE SET ftest1 = NULL WHERE ftest1 = 1;
---END---
---START---

-- Check update with old and new key values equal
UPDATE FKTABLE SET ftest1 = 1 WHERE ftest1 = 1;
---END---
---START---

-- Try altering the column type where foreign keys are involved
ALTER TABLE PKTABLE ALTER COLUMN ptest1 TYPE bigint;
---END---
---START---
ALTER TABLE FKTABLE ALTER COLUMN ftest1 TYPE bigint;
---END---
---START---
SELECT * FROM PKTABLE;
---END---
---START---
SELECT * FROM FKTABLE;
---END---
---START---

DROP TABLE PKTABLE CASCADE;
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---

--
-- check set default and table constraint on multiple columns
--
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 text, PRIMARY KEY(ptest1, ptest2) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int DEFAULT -1, ftest2 int DEFAULT -2, ftest3 int, CONSTRAINT constrname2 FOREIGN KEY(ftest1, ftest2)
                       REFERENCES PKTABLE MATCH FULL ON DELETE SET DEFAULT ON UPDATE SET DEFAULT);
---END---
---START---

-- Insert a value in PKTABLE for default
INSERT INTO PKTABLE VALUES (-1, -2, 'The Default!');
---END---
---START---

-- Insert test data into PKTABLE
INSERT INTO PKTABLE VALUES (1, 2, 'Test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, 'Test1-2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 4, 'Test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (3, 6, 'Test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (4, 8, 'Test4');
---END---
---START---
INSERT INTO PKTABLE VALUES (5, 10, 'Test5');
---END---
---START---

-- Insert successful rows into FK TABLE
INSERT INTO FKTABLE VALUES (1, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (1, 3, 5);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 4, 8);
---END---
---START---
INSERT INTO FKTABLE VALUES (3, 6, 12);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, NULL, 0);
---END---
---START---

-- Insert failed rows into FK TABLE
INSERT INTO FKTABLE VALUES (100, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (1, NULL, 4);
---END---
---START---

-- Check FKTABLE
SELECT * FROM FKTABLE;
---END---
---START---

-- Delete a row from PK TABLE
DELETE FROM PKTABLE WHERE ptest1=1 and ptest2=2;
---END---
---START---

-- Check FKTABLE to check for removal
SELECT * FROM FKTABLE;
---END---
---START---

-- Delete another row from PK TABLE
DELETE FROM PKTABLE WHERE ptest1=5 and ptest2=10;
---END---
---START---

-- Check FKTABLE (should be no change)
SELECT * FROM FKTABLE;
---END---
---START---

-- Update a row from PK TABLE
UPDATE PKTABLE SET ptest1=1 WHERE ptest1=2;
---END---
---START---

-- Check FKTABLE for update of matched row
SELECT * FROM FKTABLE;
---END---
---START---

-- this should fail for lack of CASCADE
DROP TABLE PKTABLE;
---END---
---START---
DROP TABLE PKTABLE CASCADE;
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---


--
-- First test, check with no on delete or on update
--
CREATE TABLE PKTABLE ( ptest1 int PRIMARY KEY, ptest2 text );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int REFERENCES PKTABLE MATCH FULL, ftest2 int );
---END---
---START---

-- Insert test data into PKTABLE
INSERT INTO PKTABLE VALUES (1, 'Test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 'Test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (3, 'Test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (4, 'Test4');
---END---
---START---
INSERT INTO PKTABLE VALUES (5, 'Test5');
---END---
---START---

-- Insert successful rows into FK TABLE
INSERT INTO FKTABLE VALUES (1, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 3);
---END---
---START---
INSERT INTO FKTABLE VALUES (3, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 1);
---END---
---START---

-- Insert a failed row into FK TABLE
INSERT INTO FKTABLE VALUES (100, 2);
---END---
---START---

-- Check FKTABLE
SELECT * FROM FKTABLE;
---END---
---START---

-- Check PKTABLE
SELECT * FROM PKTABLE;
---END---
---START---

-- Delete a row from PK TABLE (should fail)
DELETE FROM PKTABLE WHERE ptest1=1;
---END---
---START---

-- Delete a row from PK TABLE (should succeed)
DELETE FROM PKTABLE WHERE ptest1=5;
---END---
---START---

-- Check PKTABLE for deletes
SELECT * FROM PKTABLE;
---END---
---START---

-- Update a row from PK TABLE (should fail)
UPDATE PKTABLE SET ptest1=0 WHERE ptest1=2;
---END---
---START---

-- Update a row from PK TABLE (should succeed)
UPDATE PKTABLE SET ptest1=0 WHERE ptest1=4;
---END---
---START---

-- Check PKTABLE for updates
SELECT * FROM PKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

--
-- Check initial check upon ALTER TABLE
--
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, PRIMARY KEY(ptest1, ptest2) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int, ftest2 int );
---END---
---START---

INSERT INTO PKTABLE VALUES (1, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (1, NULL);
---END---
---START---

ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1, ftest2) REFERENCES PKTABLE MATCH FULL;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---


-- MATCH SIMPLE

-- Base test restricting update/delete
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 int, ptest4 text, PRIMARY KEY(ptest1, ptest2, ptest3) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int, ftest2 int, ftest3 int, ftest4 int,  CONSTRAINT constrname3
			FOREIGN KEY(ftest1, ftest2, ftest3) REFERENCES PKTABLE);
---END---
---START---

-- Insert Primary Key values
INSERT INTO PKTABLE VALUES (1, 2, 3, 'test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, 3, 'test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 3, 4, 'test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 4, 5, 'test4');
---END---
---START---

-- Insert Foreign Key values
INSERT INTO FKTABLE VALUES (1, 2, 3, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 3, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, NULL, 3, 3);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 7, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 3, 4, 5);
---END---
---START---

-- Insert a failed values
INSERT INTO FKTABLE VALUES (1, 2, 7, 6);
---END---
---START---

-- Show FKTABLE
SELECT * from FKTABLE;
---END---
---START---

-- Try to update something that should fail
UPDATE PKTABLE set ptest2=5 where ptest2=2;
---END---
---START---

-- Try to update something that should succeed
UPDATE PKTABLE set ptest1=1 WHERE ptest2=3;
---END---
---START---

-- Try to delete something that should fail
DELETE FROM PKTABLE where ptest1=1 and ptest2=2 and ptest3=3;
---END---
---START---

-- Try to delete something that should work
DELETE FROM PKTABLE where ptest1=2;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---

SELECT * from FKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- restrict with null values
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 int, ptest4 text, UNIQUE(ptest1, ptest2, ptest3) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int, ftest2 int, ftest3 int, ftest4 int,  CONSTRAINT constrname3
			FOREIGN KEY(ftest1, ftest2, ftest3) REFERENCES PKTABLE (ptest1, ptest2, ptest3));
---END---
---START---

INSERT INTO PKTABLE VALUES (1, 2, 3, 'test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, NULL, 'test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, NULL, 4, 'test3');
---END---
---START---

INSERT INTO FKTABLE VALUES (1, 2, 3, 1);
---END---
---START---

DELETE FROM PKTABLE WHERE ptest1 = 2;
---END---
---START---

SELECT * FROM PKTABLE;
---END---
---START---
SELECT * FROM FKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- cascade update/delete
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 int, ptest4 text, PRIMARY KEY(ptest1, ptest2, ptest3) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int, ftest2 int, ftest3 int, ftest4 int,  CONSTRAINT constrname3
			FOREIGN KEY(ftest1, ftest2, ftest3) REFERENCES PKTABLE
			ON DELETE CASCADE ON UPDATE CASCADE);
---END---
---START---

-- Insert Primary Key values
INSERT INTO PKTABLE VALUES (1, 2, 3, 'test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, 3, 'test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 3, 4, 'test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 4, 5, 'test4');
---END---
---START---

-- Insert Foreign Key values
INSERT INTO FKTABLE VALUES (1, 2, 3, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 3, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, NULL, 3, 3);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 7, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 3, 4, 5);
---END---
---START---

-- Insert a failed values
INSERT INTO FKTABLE VALUES (1, 2, 7, 6);
---END---
---START---

-- Show FKTABLE
SELECT * from FKTABLE;
---END---
---START---

-- Try to update something that will cascade
UPDATE PKTABLE set ptest2=5 where ptest2=2;
---END---
---START---

-- Try to update something that should not cascade
UPDATE PKTABLE set ptest1=1 WHERE ptest2=3;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

-- Try to delete something that should cascade
DELETE FROM PKTABLE where ptest1=1 and ptest2=5 and ptest3=3;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

-- Try to delete something that should not have a cascade
DELETE FROM PKTABLE where ptest1=2;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- set null update / set default delete
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 int, ptest4 text, PRIMARY KEY(ptest1, ptest2, ptest3) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int DEFAULT 0, ftest2 int, ftest3 int, ftest4 int,  CONSTRAINT constrname3
			FOREIGN KEY(ftest1, ftest2, ftest3) REFERENCES PKTABLE
			ON DELETE SET DEFAULT ON UPDATE SET NULL);
---END---
---START---

-- Insert Primary Key values
INSERT INTO PKTABLE VALUES (1, 2, 3, 'test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, 3, 'test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 3, 4, 'test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 4, 5, 'test4');
---END---
---START---

-- Insert Foreign Key values
INSERT INTO FKTABLE VALUES (1, 2, 3, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 3, 4, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 3, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, NULL, 3, 3);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 7, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 3, 4, 5);
---END---
---START---

-- Insert a failed values
INSERT INTO FKTABLE VALUES (1, 2, 7, 6);
---END---
---START---

-- Show FKTABLE
SELECT * from FKTABLE;
---END---
---START---

-- Try to update something that will set null
UPDATE PKTABLE set ptest2=5 where ptest2=2;
---END---
---START---

-- Try to update something that should not set null
UPDATE PKTABLE set ptest2=2 WHERE ptest2=3 and ptest1=1;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

-- Try to delete something that should set default
DELETE FROM PKTABLE where ptest1=2 and ptest2=3 and ptest3=4;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

-- Try to delete something that should not set default
DELETE FROM PKTABLE where ptest2=5;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- set default update / set null delete
CREATE TABLE PKTABLE ( ptest1 int, ptest2 int, ptest3 int, ptest4 text, PRIMARY KEY(ptest1, ptest2, ptest3) );
---END---
---START---
CREATE TABLE FKTABLE ( ftest1 int DEFAULT 0, ftest2 int DEFAULT -1, ftest3 int DEFAULT -2, ftest4 int, CONSTRAINT constrname3
			FOREIGN KEY(ftest1, ftest2, ftest3) REFERENCES PKTABLE
			ON DELETE SET NULL ON UPDATE SET DEFAULT);
---END---
---START---

-- Insert Primary Key values
INSERT INTO PKTABLE VALUES (1, 2, 3, 'test1');
---END---
---START---
INSERT INTO PKTABLE VALUES (1, 3, 3, 'test2');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 3, 4, 'test3');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, 4, 5, 'test4');
---END---
---START---
INSERT INTO PKTABLE VALUES (2, -1, 5, 'test5');
---END---
---START---

-- Insert Foreign Key values
INSERT INTO FKTABLE VALUES (1, 2, 3, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 3, 4, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, 4, 5, 1);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 3, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES (2, NULL, 3, 3);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 2, 7, 4);
---END---
---START---
INSERT INTO FKTABLE VALUES (NULL, 3, 4, 5);
---END---
---START---

-- Insert a failed values
INSERT INTO FKTABLE VALUES (1, 2, 7, 6);
---END---
---START---

-- Show FKTABLE
SELECT * from FKTABLE;
---END---
---START---

-- Try to update something that will fail
UPDATE PKTABLE set ptest2=5 where ptest2=2;
---END---
---START---

-- Try to update something that will set default
UPDATE PKTABLE set ptest1=0, ptest2=-1, ptest3=-2 where ptest2=2;
---END---
---START---
UPDATE PKTABLE set ptest2=10 where ptest2=4;
---END---
---START---

-- Try to update something that should not set default
UPDATE PKTABLE set ptest2=2 WHERE ptest2=3 and ptest1=1;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

-- Try to delete something that should set null
DELETE FROM PKTABLE where ptest1=2 and ptest2=3 and ptest3=4;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

-- Try to delete something that should not set null
DELETE FROM PKTABLE where ptest2=-1 and ptest3=5;
---END---
---START---

-- Show PKTABLE and FKTABLE
SELECT * from PKTABLE;
---END---
---START---
SELECT * from FKTABLE;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- Test for ON DELETE SET NULL/DEFAULT (column_list);
---END---
---START---
CREATE TABLE PKTABLE (tid int, id int, PRIMARY KEY (tid, id));
---END---
---START---
CREATE TABLE FKTABLE (tid int, id int, foo int, FOREIGN KEY (tid, id) REFERENCES PKTABLE ON DELETE SET NULL (bar));
---END---
---START---
CREATE TABLE FKTABLE (tid int, id int, foo int, FOREIGN KEY (tid, id) REFERENCES PKTABLE ON DELETE SET NULL (foo));
---END---
---START---
CREATE TABLE FKTABLE (tid int, id int, foo int, FOREIGN KEY (tid, foo) REFERENCES PKTABLE ON UPDATE SET NULL (foo));
---END---
---START---
CREATE TABLE FKTABLE (
  tid int, id int,
  fk_id_del_set_null int,
  fk_id_del_set_default int DEFAULT 0,
  FOREIGN KEY (tid, fk_id_del_set_null) REFERENCES PKTABLE ON DELETE SET NULL (fk_id_del_set_null),
  FOREIGN KEY (tid, fk_id_del_set_default) REFERENCES PKTABLE ON DELETE SET DEFAULT (fk_id_del_set_default)
);
---END---
---START---

SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'fktable'::regclass::oid ORDER BY oid;
---END---
---START---

INSERT INTO PKTABLE VALUES (1, 0), (1, 1), (1, 2);
---END---
---START---
INSERT INTO FKTABLE VALUES
  (1, 1, 1, NULL),
  (1, 2, NULL, 2);
---END---
---START---

DELETE FROM PKTABLE WHERE id = 1 OR id = 2;
---END---
---START---

SELECT * FROM FKTABLE ORDER BY id;
---END---
---START---

DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- Test some invalid FK definitions
CREATE TABLE PKTABLE (ptest1 int PRIMARY KEY, someoid oid);
---END---
---START---
CREATE TABLE FKTABLE_FAIL1 ( ftest1 int, CONSTRAINT fkfail1 FOREIGN KEY (ftest2) REFERENCES PKTABLE);
---END---
---START---
CREATE TABLE FKTABLE_FAIL2 ( ftest1 int, CONSTRAINT fkfail1 FOREIGN KEY (ftest1) REFERENCES PKTABLE(ptest2));
---END---
---START---
CREATE TABLE FKTABLE_FAIL3 ( ftest1 int, CONSTRAINT fkfail1 FOREIGN KEY (tableoid) REFERENCES PKTABLE(someoid));
---END---
---START---
CREATE TABLE FKTABLE_FAIL4 ( ftest1 oid, CONSTRAINT fkfail1 FOREIGN KEY (ftest1) REFERENCES PKTABLE(tableoid));
---END---
---START---

DROP TABLE PKTABLE;
---END---
---START---

-- Test for referencing column number smaller than referenced constraint
CREATE TABLE PKTABLE (ptest1 int, ptest2 int, UNIQUE(ptest1, ptest2));
---END---
---START---
CREATE TABLE FKTABLE_FAIL1 (ftest1 int REFERENCES pktable(ptest1));
---END---
---START---

DROP TABLE FKTABLE_FAIL1;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

--
-- Tests for mismatched types
--
-- Basic one column, two table setup
CREATE TABLE PKTABLE (ptest1 int PRIMARY KEY);
---END---
---START---
INSERT INTO PKTABLE VALUES(42);
---END---
---START---
-- This next should fail, because int=inet does not exist
CREATE TABLE FKTABLE (ftest1 inet REFERENCES pktable);
---END---
---START---
-- This should also fail for the same reason, but here we
-- give the column name
CREATE TABLE FKTABLE (ftest1 inet REFERENCES pktable(ptest1));
---END---
---START---
-- This should succeed, even though they are different types,
-- because int=int8 exists and is a member of the integer opfamily
CREATE TABLE FKTABLE (ftest1 int8 REFERENCES pktable);
---END---
---START---
-- Check it actually works
INSERT INTO FKTABLE VALUES(42);		-- should succeed
INSERT INTO FKTABLE VALUES(43);		-- should fail
UPDATE FKTABLE SET ftest1 = ftest1;	-- should succeed
UPDATE FKTABLE SET ftest1 = ftest1 + 1;	-- should fail
DROP TABLE FKTABLE;
---END---
---START---
-- This should fail, because we'd have to cast numeric to int which is
-- not an implicit coercion (or use numeric=numeric, but that's not part
-- of the integer opfamily)
CREATE TABLE FKTABLE (ftest1 numeric REFERENCES pktable);
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---
-- On the other hand, this should work because int implicitly promotes to
-- numeric, and we allow promotion on the FK side
CREATE TABLE PKTABLE (ptest1 numeric PRIMARY KEY);
---END---
---START---
INSERT INTO PKTABLE VALUES(42);
---END---
---START---
CREATE TABLE FKTABLE (ftest1 int REFERENCES pktable);
---END---
---START---
-- Check it actually works
INSERT INTO FKTABLE VALUES(42);		-- should succeed
INSERT INTO FKTABLE VALUES(43);		-- should fail
UPDATE FKTABLE SET ftest1 = ftest1;	-- should succeed
UPDATE FKTABLE SET ftest1 = ftest1 + 1;	-- should fail
DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- Two columns, two tables
CREATE TABLE PKTABLE (ptest1 int, ptest2 inet, PRIMARY KEY(ptest1, ptest2));
---END---
---START---
-- This should fail, because we just chose really odd types
CREATE TABLE FKTABLE (ftest1 cidr, ftest2 timestamp, FOREIGN KEY(ftest1, ftest2) REFERENCES pktable);
---END---
---START---
-- Again, so should this...
CREATE TABLE FKTABLE (ftest1 cidr, ftest2 timestamp, FOREIGN KEY(ftest1, ftest2) REFERENCES pktable(ptest1, ptest2));
---END---
---START---
-- This fails because we mixed up the column ordering
CREATE TABLE FKTABLE (ftest1 int, ftest2 inet, FOREIGN KEY(ftest2, ftest1) REFERENCES pktable);
---END---
---START---
-- As does this...
CREATE TABLE FKTABLE (ftest1 int, ftest2 inet, FOREIGN KEY(ftest2, ftest1) REFERENCES pktable(ptest1, ptest2));
---END---
---START---
-- And again..
CREATE TABLE FKTABLE (ftest1 int, ftest2 inet, FOREIGN KEY(ftest1, ftest2) REFERENCES pktable(ptest2, ptest1));
---END---
---START---
-- This works...
CREATE TABLE FKTABLE (ftest1 int, ftest2 inet, FOREIGN KEY(ftest2, ftest1) REFERENCES pktable(ptest2, ptest1));
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
-- As does this
CREATE TABLE FKTABLE (ftest1 int, ftest2 inet, FOREIGN KEY(ftest1, ftest2) REFERENCES pktable(ptest1, ptest2));
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- Two columns, same table
-- Make sure this still works...
CREATE TABLE PKTABLE (ptest1 int, ptest2 inet, ptest3 int, ptest4 inet, PRIMARY KEY(ptest1, ptest2), FOREIGN KEY(ptest3,
ptest4) REFERENCES pktable(ptest1, ptest2));
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---
-- And this,
CREATE TABLE PKTABLE (ptest1 int, ptest2 inet, ptest3 int, ptest4 inet, PRIMARY KEY(ptest1, ptest2), FOREIGN KEY(ptest3,
ptest4) REFERENCES pktable);
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---
-- This shouldn't (mixed up columns)
CREATE TABLE PKTABLE (ptest1 int, ptest2 inet, ptest3 int, ptest4 inet, PRIMARY KEY(ptest1, ptest2), FOREIGN KEY(ptest3,
ptest4) REFERENCES pktable(ptest2, ptest1));
---END---
---START---
-- Nor should this... (same reason, we have 4,3 referencing 1,2 which mismatches types
CREATE TABLE PKTABLE (ptest1 int, ptest2 inet, ptest3 int, ptest4 inet, PRIMARY KEY(ptest1, ptest2), FOREIGN KEY(ptest4,
ptest3) REFERENCES pktable(ptest1, ptest2));
---END---
---START---
-- Not this one either... Same as the last one except we didn't defined the columns being referenced.
CREATE TABLE PKTABLE (ptest1 int, ptest2 inet, ptest3 int, ptest4 inet, PRIMARY KEY(ptest1, ptest2), FOREIGN KEY(ptest4,
ptest3) REFERENCES pktable);
---END---
---START---

--
-- Now some cases with inheritance
-- Basic 2 table case: 1 column of matching types.
create table pktable_base (base1 int not null);
---END---
---START---
create table pktable (ptest1 int, primary key(base1), unique(base1, ptest1)) inherits (pktable_base);
---END---
---START---
create table fktable (ftest1 int references pktable(base1));
---END---
---START---
-- now some ins, upd, del
insert into pktable(base1) values (1);
---END---
---START---
insert into pktable(base1) values (2);
---END---
---START---
--  let's insert a non-existent fktable value
insert into fktable(ftest1) values (3);
---END---
---START---
--  let's make a valid row for that
insert into pktable(base1) values (3);
---END---
---START---
insert into fktable(ftest1) values (3);
---END---
---START---
-- let's try removing a row that should fail from pktable
delete from pktable where base1>2;
---END---
---START---
-- okay, let's try updating all of the base1 values to *4
-- which should fail.
update pktable set base1=base1*4;
---END---
---START---
-- okay, let's try an update that should work.
update pktable set base1=base1*4 where base1<3;
---END---
---START---
-- and a delete that should work
delete from pktable where base1>3;
---END---
---START---
-- cleanup
drop table fktable;
---END---
---START---
delete from pktable;
---END---
---START---

-- Now 2 columns 2 tables, matching types
create table fktable (ftest1 int, ftest2 int, foreign key(ftest1, ftest2) references pktable(base1, ptest1));
---END---
---START---
-- now some ins, upd, del
insert into pktable(base1, ptest1) values (1, 1);
---END---
---START---
insert into pktable(base1, ptest1) values (2, 2);
---END---
---START---
--  let's insert a non-existent fktable value
insert into fktable(ftest1, ftest2) values (3, 1);
---END---
---START---
--  let's make a valid row for that
insert into pktable(base1,ptest1) values (3, 1);
---END---
---START---
insert into fktable(ftest1, ftest2) values (3, 1);
---END---
---START---
-- let's try removing a row that should fail from pktable
delete from pktable where base1>2;
---END---
---START---
-- okay, let's try updating all of the base1 values to *4
-- which should fail.
update pktable set base1=base1*4;
---END---
---START---
-- okay, let's try an update that should work.
update pktable set base1=base1*4 where base1<3;
---END---
---START---
-- and a delete that should work
delete from pktable where base1>3;
---END---
---START---
-- cleanup
drop table fktable;
---END---
---START---
drop table pktable;
---END---
---START---
drop table pktable_base;
---END---
---START---

-- Now we'll do one all in 1 table with 2 columns of matching types
create table pktable_base(base1 int not null, base2 int);
---END---
---START---
create table pktable(ptest1 int, ptest2 int, primary key(base1, ptest1), foreign key(base2, ptest2) references
                                             pktable(base1, ptest1)) inherits (pktable_base);
---END---
---START---
insert into pktable (base1, ptest1, base2, ptest2) values (1, 1, 1, 1);
---END---
---START---
insert into pktable (base1, ptest1, base2, ptest2) values (2, 1, 1, 1);
---END---
---START---
insert into pktable (base1, ptest1, base2, ptest2) values (2, 2, 2, 1);
---END---
---START---
insert into pktable (base1, ptest1, base2, ptest2) values (1, 3, 2, 2);
---END---
---START---
-- fails (3,2) isn't in base1, ptest1
insert into pktable (base1, ptest1, base2, ptest2) values (2, 3, 3, 2);
---END---
---START---
-- fails (2,2) is being referenced
delete from pktable where base1=2;
---END---
---START---
-- fails (1,1) is being referenced (twice)
update pktable set base1=3 where base1=1;
---END---
---START---
-- this sequence of two deletes will work, since after the first there will be no (2,*) references
delete from pktable where base2=2;
---END---
---START---
delete from pktable where base1=2;
---END---
---START---
drop table pktable;
---END---
---START---
drop table pktable_base;
---END---
---START---

-- 2 columns (2 tables), mismatched types
create table pktable_base(base1 int not null);
---END---
---START---
create table pktable(ptest1 inet, primary key(base1, ptest1)) inherits (pktable_base);
---END---
---START---
-- just generally bad types (with and without column references on the referenced table)
create table fktable(ftest1 cidr, ftest2 int[], foreign key (ftest1, ftest2) references pktable);
---END---
---START---
create table fktable(ftest1 cidr, ftest2 int[], foreign key (ftest1, ftest2) references pktable(base1, ptest1));
---END---
---START---
-- let's mix up which columns reference which
create table fktable(ftest1 int, ftest2 inet, foreign key(ftest2, ftest1) references pktable);
---END---
---START---
create table fktable(ftest1 int, ftest2 inet, foreign key(ftest2, ftest1) references pktable(base1, ptest1));
---END---
---START---
create table fktable(ftest1 int, ftest2 inet, foreign key(ftest1, ftest2) references pktable(ptest1, base1));
---END---
---START---
drop table pktable;
---END---
---START---
drop table pktable_base;
---END---
---START---

-- 2 columns (1 table), mismatched types
create table pktable_base(base1 int not null, base2 int);
---END---
---START---
create table pktable(ptest1 inet, ptest2 inet[], primary key(base1, ptest1), foreign key(base2, ptest2) references
                                             pktable(base1, ptest1)) inherits (pktable_base);
---END---
---START---
create table pktable(ptest1 inet, ptest2 inet, primary key(base1, ptest1), foreign key(base2, ptest2) references
                                             pktable(ptest1, base1)) inherits (pktable_base);
---END---
---START---
create table pktable(ptest1 inet, ptest2 inet, primary key(base1, ptest1), foreign key(ptest2, base2) references
                                             pktable(base1, ptest1)) inherits (pktable_base);
---END---
---START---
create table pktable(ptest1 inet, ptest2 inet, primary key(base1, ptest1), foreign key(ptest2, base2) references
                                             pktable(base1, ptest1)) inherits (pktable_base);
---END---
---START---
drop table pktable;
---END---
---START---
drop table pktable_base;
---END---
---START---

--
-- Deferrable constraints
--

-- deferrable, explicitly deferred
CREATE TABLE pktable (
	id		INT4 PRIMARY KEY,
	other	INT4
);
---END---
---START---

CREATE TABLE fktable (
	id		INT4 PRIMARY KEY,
	fk		INT4 REFERENCES pktable DEFERRABLE
);
---END---
---START---

-- default to immediate: should fail
INSERT INTO fktable VALUES (5, 10);
---END---
---START---

-- explicitly defer the constraint
BEGIN;
---END---
---START---

SET CONSTRAINTS ALL DEFERRED;
---END---
---START---

INSERT INTO fktable VALUES (10, 15);
---END---
---START---
INSERT INTO pktable VALUES (15, 0); -- make the FK insert valid

COMMIT;
---END---
---START---

DROP TABLE fktable, pktable;
---END---
---START---

-- deferrable, initially deferred
CREATE TABLE pktable (
	id		INT4 PRIMARY KEY,
	other	INT4
);
---END---
---START---

CREATE TABLE fktable (
	id		INT4 PRIMARY KEY,
	fk		INT4 REFERENCES pktable DEFERRABLE INITIALLY DEFERRED
);
---END---
---START---

-- default to deferred, should succeed
BEGIN;
---END---
---START---

INSERT INTO fktable VALUES (100, 200);
---END---
---START---
INSERT INTO pktable VALUES (200, 500); -- make the FK insert valid

COMMIT;
---END---
---START---

-- default to deferred, explicitly make immediate
BEGIN;
---END---
---START---

SET CONSTRAINTS ALL IMMEDIATE;
---END---
---START---

-- should fail
INSERT INTO fktable VALUES (500, 1000);
---END---
---START---

COMMIT;
---END---
---START---

DROP TABLE fktable, pktable;
---END---
---START---

-- tricky behavior: according to SQL99, if a deferred constraint is set
-- to 'immediate' mode, it should be checked for validity *immediately*,
-- not when the current transaction commits (i.e. the mode change applies
-- retroactively)
CREATE TABLE pktable (
	id		INT4 PRIMARY KEY,
	other	INT4
);
---END---
---START---

CREATE TABLE fktable (
	id		INT4 PRIMARY KEY,
	fk		INT4 REFERENCES pktable DEFERRABLE
);
---END---
---START---

BEGIN;
---END---
---START---

SET CONSTRAINTS ALL DEFERRED;
---END---
---START---

-- should succeed, for now
INSERT INTO fktable VALUES (1000, 2000);
---END---
---START---

-- should cause transaction abort, due to preceding error
SET CONSTRAINTS ALL IMMEDIATE;
---END---
---START---

INSERT INTO pktable VALUES (2000, 3); -- too late

COMMIT;
---END---
---START---

DROP TABLE fktable, pktable;
---END---
---START---

-- deferrable, initially deferred
CREATE TABLE pktable (
	id		INT4 PRIMARY KEY,
	other	INT4
);
---END---
---START---

CREATE TABLE fktable (
	id		INT4 PRIMARY KEY,
	fk		INT4 REFERENCES pktable DEFERRABLE INITIALLY DEFERRED
);
---END---
---START---

BEGIN;
---END---
---START---

-- no error here
INSERT INTO fktable VALUES (100, 200);
---END---
---START---

-- error here on commit
COMMIT;
---END---
---START---

DROP TABLE pktable, fktable;
---END---
---START---

-- test notice about expensive referential integrity checks,
-- where the index cannot be used because of type incompatibilities.

CREATE TABLE pktable (
        id1     INT4 PRIMARY KEY,
        id2     VARCHAR(4) UNIQUE,
        id3     REAL UNIQUE,
        UNIQUE(id1, id2, id3)
);
---END---
---START---

CREATE TABLE fktable (
        x1      INT4 REFERENCES pktable(id1),
        x2      VARCHAR(4) REFERENCES pktable(id2),
        x3      REAL REFERENCES pktable(id3),
        x4      TEXT,
        x5      INT2
);
---END---
---START---

-- check individual constraints with alter table.

-- should fail

-- varchar does not promote to real
ALTER TABLE fktable ADD CONSTRAINT fk_2_3
FOREIGN KEY (x2) REFERENCES pktable(id3);
---END---
---START---

-- nor to int4
ALTER TABLE fktable ADD CONSTRAINT fk_2_1
FOREIGN KEY (x2) REFERENCES pktable(id1);
---END---
---START---

-- real does not promote to int4
ALTER TABLE fktable ADD CONSTRAINT fk_3_1
FOREIGN KEY (x3) REFERENCES pktable(id1);
---END---
---START---

-- int4 does not promote to text
ALTER TABLE fktable ADD CONSTRAINT fk_1_2
FOREIGN KEY (x1) REFERENCES pktable(id2);
---END---
---START---

-- should succeed

-- int4 promotes to real
ALTER TABLE fktable ADD CONSTRAINT fk_1_3
FOREIGN KEY (x1) REFERENCES pktable(id3);
---END---
---START---

-- text is compatible with varchar
ALTER TABLE fktable ADD CONSTRAINT fk_4_2
FOREIGN KEY (x4) REFERENCES pktable(id2);
---END---
---START---

-- int2 is part of integer opfamily as of 8.0
ALTER TABLE fktable ADD CONSTRAINT fk_5_1
FOREIGN KEY (x5) REFERENCES pktable(id1);
---END---
---START---

-- check multikey cases, especially out-of-order column lists

-- these should work

ALTER TABLE fktable ADD CONSTRAINT fk_123_123
FOREIGN KEY (x1,x2,x3) REFERENCES pktable(id1,id2,id3);
---END---
---START---

ALTER TABLE fktable ADD CONSTRAINT fk_213_213
FOREIGN KEY (x2,x1,x3) REFERENCES pktable(id2,id1,id3);
---END---
---START---

ALTER TABLE fktable ADD CONSTRAINT fk_253_213
FOREIGN KEY (x2,x5,x3) REFERENCES pktable(id2,id1,id3);
---END---
---START---

-- these should fail

ALTER TABLE fktable ADD CONSTRAINT fk_123_231
FOREIGN KEY (x1,x2,x3) REFERENCES pktable(id2,id3,id1);
---END---
---START---

ALTER TABLE fktable ADD CONSTRAINT fk_241_132
FOREIGN KEY (x2,x4,x1) REFERENCES pktable(id1,id3,id2);
---END---
---START---

DROP TABLE pktable, fktable;
---END---
---START---

-- test a tricky case: we can elide firing the FK check trigger during
-- an UPDATE if the UPDATE did not change the foreign key
-- field. However, we can't do this if our transaction was the one that
-- created the updated row and the trigger is deferred, since our UPDATE
-- will have invalidated the original newly-inserted tuple, and therefore
-- cause the on-INSERT RI trigger not to be fired.

CREATE TABLE pktable (
    id int primary key,
    other int
);
---END---
---START---

CREATE TABLE fktable (
    id int primary key,
    fk int references pktable deferrable initially deferred
);
---END---
---START---

INSERT INTO pktable VALUES (5, 10);
---END---
---START---

BEGIN;
---END---
---START---

-- doesn't match PK, but no error yet
INSERT INTO fktable VALUES (0, 20);
---END---
---START---

-- don't change FK
UPDATE fktable SET id = id + 1;
---END---
---START---

-- should catch error from initial INSERT
COMMIT;
---END---
---START---

-- check same case when insert is in a different subtransaction than update

BEGIN;
---END---
---START---

-- doesn't match PK, but no error yet
INSERT INTO fktable VALUES (0, 20);
---END---
---START---

-- UPDATE will be in a subxact
SAVEPOINT savept1;
---END---
---START---

-- don't change FK
UPDATE fktable SET id = id + 1;
---END---
---START---

-- should catch error from initial INSERT
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---

-- INSERT will be in a subxact
SAVEPOINT savept1;
---END---
---START---

-- doesn't match PK, but no error yet
INSERT INTO fktable VALUES (0, 20);
---END---
---START---

RELEASE SAVEPOINT savept1;
---END---
---START---

-- don't change FK
UPDATE fktable SET id = id + 1;
---END---
---START---

-- should catch error from initial INSERT
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---

-- doesn't match PK, but no error yet
INSERT INTO fktable VALUES (0, 20);
---END---
---START---

-- UPDATE will be in a subxact
SAVEPOINT savept1;
---END---
---START---

-- don't change FK
UPDATE fktable SET id = id + 1;
---END---
---START---

-- Roll back the UPDATE
ROLLBACK TO savept1;
---END---
---START---

-- should catch error from initial INSERT
COMMIT;
---END---
---START---

--
-- check ALTER CONSTRAINT
--

INSERT INTO fktable VALUES (1, 5);
---END---
---START---

ALTER TABLE fktable ALTER CONSTRAINT fktable_fk_fkey DEFERRABLE INITIALLY IMMEDIATE;
---END---
---START---

BEGIN;
---END---
---START---

-- doesn't match FK, should throw error now
UPDATE pktable SET id = 10 WHERE id = 5;
---END---
---START---

COMMIT;
---END---
---START---

BEGIN;
---END---
---START---

-- doesn't match PK, should throw error now
INSERT INTO fktable VALUES (0, 20);
---END---
---START---

COMMIT;
---END---
---START---

-- try additional syntax
ALTER TABLE fktable ALTER CONSTRAINT fktable_fk_fkey NOT DEFERRABLE;
---END---
---START---
-- illegal option
ALTER TABLE fktable ALTER CONSTRAINT fktable_fk_fkey NOT DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
drop table pktable, fktable;
---END---
---START---

-- test order of firing of FK triggers when several RI-induced changes need to
-- be made to the same row.  This was broken by subtransaction-related
-- changes in 8.0.

CREATE TABLE users (
  id INT PRIMARY KEY,
  name VARCHAR NOT NULL
);
---END---
---START---

INSERT INTO users VALUES (1, 'Jozko');
---END---
---START---
INSERT INTO users VALUES (2, 'Ferko');
---END---
---START---
INSERT INTO users VALUES (3, 'Samko');
---END---
---START---

CREATE TABLE tasks (
  id INT PRIMARY KEY,
  owner INT REFERENCES users ON UPDATE CASCADE ON DELETE SET NULL,
  worker INT REFERENCES users ON UPDATE CASCADE ON DELETE SET NULL,
  checked_by INT REFERENCES users ON UPDATE CASCADE ON DELETE SET NULL
);
---END---
---START---

INSERT INTO tasks VALUES (1,1,NULL,NULL);
---END---
---START---
INSERT INTO tasks VALUES (2,2,2,NULL);
---END---
---START---
INSERT INTO tasks VALUES (3,3,3,3);
---END---
---START---

SELECT * FROM tasks;
---END---
---START---

UPDATE users SET id = 4 WHERE id = 3;
---END---
---START---

SELECT * FROM tasks;
---END---
---START---

DELETE FROM users WHERE id = 4;
---END---
---START---

SELECT * FROM tasks;
---END---
---START---

-- could fail with only 2 changes to make, if row was already updated
BEGIN;
---END---
---START---
UPDATE tasks set id=id WHERE id=2;
---END---
---START---
SELECT * FROM tasks;
---END---
---START---
DELETE FROM users WHERE id = 2;
---END---
---START---
SELECT * FROM tasks;
---END---
---START---
COMMIT;
---END---
---START---
drop table users, tasks;
---END---
---START---

--
-- Test self-referential FK with CASCADE (bug #6268)
--
create table selfref (
    a int primary key,
    b int,
    foreign key (b) references selfref (a)
        on update cascade on delete cascade
);
---END---
---START---

insert into selfref (a, b)
values
    (0, 0),
    (1, 1);
---END---
---START---

begin;
---END---
---START---
    update selfref set a = 123 where a = 0;
---END---
---START---
    select a, b from selfref;
---END---
---START---
    update selfref set a = 456 where a = 123;
---END---
---START---
    select a, b from selfref;
---END---
---START---
commit;
---END---
---START---
drop table selfref;
---END---
---START---

--
-- Test that SET DEFAULT actions recognize updates to default values
--
create table defp (f1 int primary key);
---END---
---START---
create table defc (f1 int default 0
                        references defp on delete set default);
---END---
---START---
insert into defp values (0), (1), (2);
---END---
---START---
insert into defc values (2);
---END---
---START---
select * from defc;
---END---
---START---
delete from defp where f1 = 2;
---END---
---START---
select * from defc;
---END---
---START---
delete from defp where f1 = 0; -- fail
alter table defc alter column f1 set default 1;
---END---
---START---
delete from defp where f1 = 0;
---END---
---START---
select * from defc;
---END---
---START---
delete from defp where f1 = 1; -- fail
---END---
---START---
drop table defp, defc;
---END---
---START---

--
-- Test the difference between NO ACTION and RESTRICT
--
create table pp (f1 int primary key);
---END---
---START---
create table cc (f1 int references pp on update no action on delete no action);
---END---
---START---
insert into pp values(12);
---END---
---START---
insert into pp values(11);
---END---
---START---
update pp set f1=f1+1;
---END---
---START---
insert into cc values(13);
---END---
---START---
update pp set f1=f1+1;
---END---
---START---
update pp set f1=f1+1; -- fail
delete from pp where f1 = 13; -- fail
drop table pp, cc;
---END---
---START---

create table pp (f1 int primary key);
---END---
---START---
create table cc (f1 int references pp on update restrict on delete restrict);
---END---
---START---
insert into pp values(12);
---END---
---START---
insert into pp values(11);
---END---
---START---
update pp set f1=f1+1;
---END---
---START---
insert into cc values(13);
---END---
---START---
update pp set f1=f1+1; -- fail
delete from pp where f1 = 13; -- fail
drop table pp, cc;
---END---
---START---

--
-- Test interaction of foreign-key optimization with rules (bug #14219)
--
create table t1 (a integer primary key, b text);
---END---
---START---
create table t2 (a integer primary key, b integer references t1);
---END---
---START---
create rule r1 as on delete to t1 do delete from t2 where t2.b = old.a;
---END---
---START---

explain (costs off) delete from t1 where a = 1;
---END---
---START---
delete from t1 where a = 1;
---END---
---START---
drop table t1, t2;
---END---
---START---

-- Test a primary key with attributes located in later attnum positions
-- compared to the fk attributes.
create table pktable2 (a int, b int, c int, d int, e int, primary key (d, e));
---END---
---START---
create table fktable2 (d int, e int, foreign key (d, e) references pktable2);
---END---
---START---
insert into pktable2 values (1, 2, 3, 4, 5);
---END---
---START---
insert into fktable2 values (4, 5);
---END---
---START---
delete from pktable2;
---END---
---START---
update pktable2 set d = 5;
---END---
---START---
drop table pktable2, fktable2;
---END---
---START---

-- Test truncation of long foreign key names
create table pktable1 (a int primary key);
---END---
---START---
create table pktable2 (a int, b int, primary key (a, b));
---END---
---START---
create table fktable2 (
  a int,
  b int,
  very_very_long_column_name_to_exceed_63_characters int,
  foreign key (very_very_long_column_name_to_exceed_63_characters) references pktable1,
  foreign key (a, very_very_long_column_name_to_exceed_63_characters) references pktable2,
  foreign key (a, very_very_long_column_name_to_exceed_63_characters) references pktable2
);
---END---
---START---
select conname from pg_constraint where conrelid = 'fktable2'::regclass order by conname;
---END---
---START---
drop table pktable1, pktable2, fktable2;
---END---
---START---

--
-- Test deferred FK check on a tuple deleted by a rolled-back subtransaction
--
create table pktable2(f1 int primary key);
---END---
---START---
create table fktable2(f1 int references pktable2 deferrable initially deferred);
---END---
---START---
insert into pktable2 values(1);
---END---
---START---

begin;
---END---
---START---
insert into fktable2 values(1);
---END---
---START---
savepoint x;
---END---
---START---
delete from fktable2;
---END---
---START---
rollback to x;
---END---
---START---
commit;
---END---
---START---

begin;
---END---
---START---
insert into fktable2 values(2);
---END---
---START---
savepoint x;
---END---
---START---
delete from fktable2;
---END---
---START---
rollback to x;
---END---
---START---
commit; -- fail

--
-- Test that we prevent dropping FK constraint with pending trigger events
--
begin;
---END---
---START---
insert into fktable2 values(2);
---END---
---START---
alter table fktable2 drop constraint fktable2_f1_fkey;
---END---
---START---
commit;
---END---
---START---

begin;
---END---
---START---
delete from pktable2 where f1 = 1;
---END---
---START---
alter table fktable2 drop constraint fktable2_f1_fkey;
---END---
---START---
commit;
---END---
---START---

drop table pktable2, fktable2;
---END---
---START---

--
-- Test keys that "look" different but compare as equal
--
create table pktable2 (a float8, b float8, primary key (a, b));
---END---
---START---
create table fktable2 (x float8, y float8, foreign key (x, y) references pktable2 (a, b) on update cascade);
---END---
---START---

insert into pktable2 values ('-0', '-0');
---END---
---START---
insert into fktable2 values ('-0', '-0');
---END---
---START---

select * from pktable2;
---END---
---START---
select * from fktable2;
---END---
---START---

update pktable2 set a = '0' where a = '-0';
---END---
---START---

select * from pktable2;
---END---
---START---
-- should have updated fktable2.x
select * from fktable2;
---END---
---START---

drop table pktable2, fktable2;
---END---
---START---


--
-- Foreign keys and partitioned tables
--

-- Creation of a partitioned hierarchy with irregular definitions
CREATE TABLE fk_notpartitioned_pk (fdrop1 int, a int, fdrop2 int, b int,
  PRIMARY KEY (a, b));
---END---
---START---
ALTER TABLE fk_notpartitioned_pk DROP COLUMN fdrop1, DROP COLUMN fdrop2;
---END---
---START---
CREATE TABLE fk_partitioned_fk (b int, fdrop1 int, a int) PARTITION BY RANGE (a, b);
---END---
---START---
ALTER TABLE fk_partitioned_fk DROP COLUMN fdrop1;
---END---
---START---
CREATE TABLE fk_partitioned_fk_1 (fdrop1 int, fdrop2 int, a int, fdrop3 int, b int);
---END---
---START---
ALTER TABLE fk_partitioned_fk_1 DROP COLUMN fdrop1, DROP COLUMN fdrop2, DROP COLUMN fdrop3;
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_1 FOR VALUES FROM (0,0) TO (1000,1000);
---END---
---START---
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk;
---END---
---START---
CREATE TABLE fk_partitioned_fk_2 (b int, fdrop1 int, fdrop2 int, a int);
---END---
---START---
ALTER TABLE fk_partitioned_fk_2 DROP COLUMN fdrop1, DROP COLUMN fdrop2;
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_2 FOR VALUES FROM (1000,1000) TO (2000,2000);
---END---
---START---

CREATE TABLE fk_partitioned_fk_3 (fdrop1 int, fdrop2 int, fdrop3 int, fdrop4 int, b int, a int)
  PARTITION BY HASH (a);
---END---
---START---
ALTER TABLE fk_partitioned_fk_3 DROP COLUMN fdrop1, DROP COLUMN fdrop2,
	DROP COLUMN fdrop3, DROP COLUMN fdrop4;
---END---
---START---
CREATE TABLE fk_partitioned_fk_3_0 PARTITION OF fk_partitioned_fk_3 FOR VALUES WITH (MODULUS 5, REMAINDER 0);
---END---
---START---
CREATE TABLE fk_partitioned_fk_3_1 PARTITION OF fk_partitioned_fk_3 FOR VALUES WITH (MODULUS 5, REMAINDER 1);
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_3
  FOR VALUES FROM (2000,2000) TO (3000,3000);
---END---
---START---

-- Creating a foreign key with ONLY on a partitioned table referencing
-- a non-partitioned table fails.
ALTER TABLE ONLY fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk;
---END---
---START---
-- Adding a NOT VALID foreign key on a partitioned table referencing
-- a non-partitioned table fails.
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk NOT VALID;
---END---
---START---

-- these inserts, targeting both the partition directly as well as the
-- partitioned table, should all fail
INSERT INTO fk_partitioned_fk (a,b) VALUES (500, 501);
---END---
---START---
INSERT INTO fk_partitioned_fk_1 (a,b) VALUES (500, 501);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (1500, 1501);
---END---
---START---
INSERT INTO fk_partitioned_fk_2 (a,b) VALUES (1500, 1501);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (2500, 2502);
---END---
---START---
INSERT INTO fk_partitioned_fk_3 (a,b) VALUES (2500, 2502);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (2501, 2503);
---END---
---START---
INSERT INTO fk_partitioned_fk_3 (a,b) VALUES (2501, 2503);
---END---
---START---

-- but if we insert the values that make them valid, then they work
INSERT INTO fk_notpartitioned_pk VALUES (500, 501), (1500, 1501),
  (2500, 2502), (2501, 2503);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (500, 501);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (1500, 1501);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (2500, 2502);
---END---
---START---
INSERT INTO fk_partitioned_fk (a,b) VALUES (2501, 2503);
---END---
---START---

-- this update fails because there is no referenced row
UPDATE fk_partitioned_fk SET a = a + 1 WHERE a = 2501;
---END---
---START---
-- but we can fix it thusly:
INSERT INTO fk_notpartitioned_pk (a,b) VALUES (2502, 2503);
---END---
---START---
UPDATE fk_partitioned_fk SET a = a + 1 WHERE a = 2501;
---END---
---START---

-- these updates would leave lingering rows in the referencing table; disallow
UPDATE fk_notpartitioned_pk SET b = 502 WHERE a = 500;
---END---
---START---
UPDATE fk_notpartitioned_pk SET b = 1502 WHERE a = 1500;
---END---
---START---
UPDATE fk_notpartitioned_pk SET b = 2504 WHERE a = 2500;
---END---
---START---
-- check psql behavior
\d fk_notpartitioned_pk
ALTER TABLE fk_partitioned_fk DROP CONSTRAINT fk_partitioned_fk_a_b_fkey;
---END---
---START---
-- done.
DROP TABLE fk_notpartitioned_pk, fk_partitioned_fk;
---END---
---START---

-- Altering a type referenced by a foreign key needs to drop/recreate the FK.
-- Ensure that works.
CREATE TABLE fk_notpartitioned_pk (a INT, PRIMARY KEY(a), CHECK (a > 0));
---END---
---START---
CREATE TABLE fk_partitioned_fk (a INT REFERENCES fk_notpartitioned_pk(a) PRIMARY KEY) PARTITION BY RANGE(a);
---END---
---START---
CREATE TABLE fk_partitioned_fk_1 PARTITION OF fk_partitioned_fk FOR VALUES FROM (MINVALUE) TO (MAXVALUE);
---END---
---START---
INSERT INTO fk_notpartitioned_pk VALUES (1);
---END---
---START---
INSERT INTO fk_partitioned_fk VALUES (1);
---END---
---START---
ALTER TABLE fk_notpartitioned_pk ALTER COLUMN a TYPE bigint;
---END---
---START---
DELETE FROM fk_notpartitioned_pk WHERE a = 1;
---END---
---START---
DROP TABLE fk_notpartitioned_pk, fk_partitioned_fk;
---END---
---START---

-- Test some other exotic foreign key features: MATCH SIMPLE, ON UPDATE/DELETE
-- actions
CREATE TABLE fk_notpartitioned_pk (a int, b int, primary key (a, b));
---END---
---START---
CREATE TABLE fk_partitioned_fk (a int default 2501, b int default 142857) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE fk_partitioned_fk_1 PARTITION OF fk_partitioned_fk FOR VALUES IN (NULL,500,501,502);
---END---
---START---
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk MATCH SIMPLE
  ON DELETE SET NULL ON UPDATE SET NULL;
---END---
---START---
CREATE TABLE fk_partitioned_fk_2 PARTITION OF fk_partitioned_fk FOR VALUES IN (1500,1502);
---END---
---START---
CREATE TABLE fk_partitioned_fk_3 (a int, b int);
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_3 FOR VALUES IN (2500,2501,2502,2503);
---END---
---START---

-- this insert fails
INSERT INTO fk_partitioned_fk (a, b) VALUES (2502, 2503);
---END---
---START---
INSERT INTO fk_partitioned_fk_3 (a, b) VALUES (2502, 2503);
---END---
---START---
-- but since the FK is MATCH SIMPLE, this one doesn't
INSERT INTO fk_partitioned_fk_3 (a, b) VALUES (2502, NULL);
---END---
---START---
-- now create the referenced row ...
INSERT INTO fk_notpartitioned_pk VALUES (2502, 2503);
---END---
---START---
--- and now the same insert work
INSERT INTO fk_partitioned_fk_3 (a, b) VALUES (2502, 2503);
---END---
---START---
-- this always works
INSERT INTO fk_partitioned_fk (a,b) VALUES (NULL, NULL);
---END---
---START---

-- MATCH FULL
INSERT INTO fk_notpartitioned_pk VALUES (1, 2);
---END---
---START---
CREATE TABLE fk_partitioned_fk_full (x int, y int) PARTITION BY RANGE (x);
---END---
---START---
CREATE TABLE fk_partitioned_fk_full_1 PARTITION OF fk_partitioned_fk_full DEFAULT;
---END---
---START---
INSERT INTO fk_partitioned_fk_full VALUES (1, NULL);
---END---
---START---
ALTER TABLE fk_partitioned_fk_full ADD FOREIGN KEY (x, y) REFERENCES fk_notpartitioned_pk MATCH FULL;  -- fails
TRUNCATE fk_partitioned_fk_full;
---END---
---START---
ALTER TABLE fk_partitioned_fk_full ADD FOREIGN KEY (x, y) REFERENCES fk_notpartitioned_pk MATCH FULL;
---END---
---START---
INSERT INTO fk_partitioned_fk_full VALUES (1, NULL);  -- fails
DROP TABLE fk_partitioned_fk_full;
---END---
---START---

-- ON UPDATE SET NULL
SELECT tableoid::regclass, a, b FROM fk_partitioned_fk WHERE b IS NULL ORDER BY a;
---END---
---START---
UPDATE fk_notpartitioned_pk SET a = a + 1 WHERE a = 2502;
---END---
---START---
SELECT tableoid::regclass, a, b FROM fk_partitioned_fk WHERE b IS NULL ORDER BY a;
---END---
---START---

-- ON DELETE SET NULL
INSERT INTO fk_partitioned_fk VALUES (2503, 2503);
---END---
---START---
SELECT count(*) FROM fk_partitioned_fk WHERE a IS NULL;
---END---
---START---
DELETE FROM fk_notpartitioned_pk;
---END---
---START---
SELECT count(*) FROM fk_partitioned_fk WHERE a IS NULL;
---END---
---START---

-- ON UPDATE/DELETE SET DEFAULT
ALTER TABLE fk_partitioned_fk DROP CONSTRAINT fk_partitioned_fk_a_b_fkey;
---END---
---START---
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk
  ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;
---END---
---START---
INSERT INTO fk_notpartitioned_pk VALUES (2502, 2503);
---END---
---START---
INSERT INTO fk_partitioned_fk_3 (a, b) VALUES (2502, 2503);
---END---
---START---
-- this fails, because the defaults for the referencing table are not present
-- in the referenced table:
UPDATE fk_notpartitioned_pk SET a = 1500 WHERE a = 2502;
---END---
---START---
-- but inserting the row we can make it work:
INSERT INTO fk_notpartitioned_pk VALUES (2501, 142857);
---END---
---START---
UPDATE fk_notpartitioned_pk SET a = 1500 WHERE a = 2502;
---END---
---START---
SELECT * FROM fk_partitioned_fk WHERE b = 142857;
---END---
---START---

-- ON DELETE SET NULL column_list
ALTER TABLE fk_partitioned_fk DROP CONSTRAINT fk_partitioned_fk_a_b_fkey;
---END---
---START---
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk
  ON DELETE SET NULL (a);
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM fk_notpartitioned_pk WHERE b = 142857;
---END---
---START---
SELECT * FROM fk_partitioned_fk WHERE a IS NOT NULL OR b IS NOT NULL ORDER BY a NULLS LAST;
---END---
---START---
ROLLBACK;
---END---
---START---

-- ON DELETE SET DEFAULT column_list
ALTER TABLE fk_partitioned_fk DROP CONSTRAINT fk_partitioned_fk_a_b_fkey;
---END---
---START---
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk
  ON DELETE SET DEFAULT (a);
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM fk_partitioned_fk;
---END---
---START---
DELETE FROM fk_notpartitioned_pk;
---END---
---START---
INSERT INTO fk_notpartitioned_pk VALUES (500, 100000), (2501, 100000);
---END---
---START---
INSERT INTO fk_partitioned_fk VALUES (500, 100000);
---END---
---START---
DELETE FROM fk_notpartitioned_pk WHERE a = 500;
---END---
---START---
SELECT * FROM fk_partitioned_fk ORDER BY a;
---END---
---START---
ROLLBACK;
---END---
---START---

-- ON UPDATE/DELETE CASCADE
ALTER TABLE fk_partitioned_fk DROP CONSTRAINT fk_partitioned_fk_a_b_fkey;
---END---
---START---
ALTER TABLE fk_partitioned_fk ADD FOREIGN KEY (a, b)
  REFERENCES fk_notpartitioned_pk
  ON DELETE CASCADE ON UPDATE CASCADE;
---END---
---START---
UPDATE fk_notpartitioned_pk SET a = 2502 WHERE a = 2501;
---END---
---START---
SELECT * FROM fk_partitioned_fk WHERE b = 142857;
---END---
---START---

-- Now you see it ...
SELECT * FROM fk_partitioned_fk WHERE b = 142857;
---END---
---START---
DELETE FROM fk_notpartitioned_pk WHERE b = 142857;
---END---
---START---
-- now you don't.
SELECT * FROM fk_partitioned_fk WHERE a = 142857;
---END---
---START---

-- verify that DROP works
DROP TABLE fk_partitioned_fk_2;
---END---
---START---

-- Test behavior of the constraint together with attaching and detaching
-- partitions.
CREATE TABLE fk_partitioned_fk_2 PARTITION OF fk_partitioned_fk FOR VALUES IN (1500,1502);
---END---
---START---
ALTER TABLE fk_partitioned_fk DETACH PARTITION fk_partitioned_fk_2;
---END---
---START---
BEGIN;
---END---
---START---
DROP TABLE fk_partitioned_fk;
---END---
---START---
-- constraint should still be there
\d fk_partitioned_fk_2;
---END---
---START---
ROLLBACK;
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_2 FOR VALUES IN (1500,1502);
---END---
---START---
DROP TABLE fk_partitioned_fk_2;
---END---
---START---
CREATE TABLE fk_partitioned_fk_2 (b int, c text, a int,
	FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk ON UPDATE CASCADE ON DELETE CASCADE);
---END---
---START---
ALTER TABLE fk_partitioned_fk_2 DROP COLUMN c;
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_2 FOR VALUES IN (1500,1502);
---END---
---START---
-- should have only one constraint
\d fk_partitioned_fk_2
DROP TABLE fk_partitioned_fk_2;
---END---
---START---

CREATE TABLE fk_partitioned_fk_4 (a int, b int, FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk(a, b) ON UPDATE CASCADE ON DELETE CASCADE) PARTITION BY RANGE (b, a);
---END---
---START---
CREATE TABLE fk_partitioned_fk_4_1 PARTITION OF fk_partitioned_fk_4 FOR VALUES FROM (1,1) TO (100,100);
---END---
---START---
CREATE TABLE fk_partitioned_fk_4_2 (a int, b int, FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk(a, b) ON UPDATE SET NULL);
---END---
---START---
ALTER TABLE fk_partitioned_fk_4 ATTACH PARTITION fk_partitioned_fk_4_2 FOR VALUES FROM (100,100) TO (1000,1000);
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_4 FOR VALUES IN (3500,3502);
---END---
---START---
ALTER TABLE fk_partitioned_fk DETACH PARTITION fk_partitioned_fk_4;
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_4 FOR VALUES IN (3500,3502);
---END---
---START---
-- should only have one constraint
\d fk_partitioned_fk_4
\d fk_partitioned_fk_4_1
-- this one has an FK with mismatched properties
\d fk_partitioned_fk_4_2

CREATE TABLE fk_partitioned_fk_5 (a int, b int,
	FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk(a, b) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE,
	FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk(a, b) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE)
  PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk_partitioned_fk_5_1 (a int, b int, FOREIGN KEY (a, b) REFERENCES fk_notpartitioned_pk);
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_5 FOR VALUES IN (4500);
---END---
---START---
ALTER TABLE fk_partitioned_fk_5 ATTACH PARTITION fk_partitioned_fk_5_1 FOR VALUES FROM (0) TO (10);
---END---
---START---
ALTER TABLE fk_partitioned_fk DETACH PARTITION fk_partitioned_fk_5;
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_5 FOR VALUES IN (4500);
---END---
---START---
-- this one has two constraints, similar but not quite the one in the parent,
-- so it gets a new one
\d fk_partitioned_fk_5
-- verify that it works to reattaching a child with multiple candidate
-- constraints
ALTER TABLE fk_partitioned_fk_5 DETACH PARTITION fk_partitioned_fk_5_1;
---END---
---START---
ALTER TABLE fk_partitioned_fk_5 ATTACH PARTITION fk_partitioned_fk_5_1 FOR VALUES FROM (0) TO (10);
---END---
---START---
\d fk_partitioned_fk_5_1

-- verify that attaching a table checks that the existing data satisfies the
-- constraint
CREATE TABLE fk_partitioned_fk_2 (a int, b int) PARTITION BY RANGE (b);
---END---
---START---
CREATE TABLE fk_partitioned_fk_2_1 PARTITION OF fk_partitioned_fk_2 FOR VALUES FROM (0) TO (1000);
---END---
---START---
CREATE TABLE fk_partitioned_fk_2_2 PARTITION OF fk_partitioned_fk_2 FOR VALUES FROM (1000) TO (2000);
---END---
---START---
INSERT INTO fk_partitioned_fk_2 VALUES (1600, 601), (1600, 1601);
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_2
  FOR VALUES IN (1600);
---END---
---START---
INSERT INTO fk_notpartitioned_pk VALUES (1600, 601), (1600, 1601);
---END---
---START---
ALTER TABLE fk_partitioned_fk ATTACH PARTITION fk_partitioned_fk_2
  FOR VALUES IN (1600);
---END---
---START---

-- leave these tables around intentionally

-- test the case when the referenced table is owned by a different user
create role regress_other_partitioned_fk_owner;
---END---
---START---
grant references on fk_notpartitioned_pk to regress_other_partitioned_fk_owner;
---END---
---START---
set role regress_other_partitioned_fk_owner;
---END---
---START---
create table other_partitioned_fk(a int, b int) partition by list (a);
---END---
---START---
create table other_partitioned_fk_1 partition of other_partitioned_fk
  for values in (2048);
---END---
---START---
insert into other_partitioned_fk
  select 2048, x from generate_series(1,10) x;
---END---
---START---
-- this should fail
alter table other_partitioned_fk add foreign key (a, b)
  references fk_notpartitioned_pk(a, b);
---END---
---START---
-- add the missing keys and retry
reset role;
---END---
---START---
insert into fk_notpartitioned_pk (a, b)
  select 2048, x from generate_series(1,10) x;
---END---
---START---
set role regress_other_partitioned_fk_owner;
---END---
---START---
alter table other_partitioned_fk add foreign key (a, b)
  references fk_notpartitioned_pk(a, b);
---END---
---START---
-- clean up
drop table other_partitioned_fk;
---END---
---START---
reset role;
---END---
---START---
revoke all on fk_notpartitioned_pk from regress_other_partitioned_fk_owner;
---END---
---START---
drop role regress_other_partitioned_fk_owner;
---END---
---START---

--
-- Test self-referencing foreign key with partition.
-- This should create only one fk constraint per partition
--
CREATE TABLE parted_self_fk (
    id bigint NOT NULL PRIMARY KEY,
    id_abc bigint,
    FOREIGN KEY (id_abc) REFERENCES parted_self_fk(id)
)
PARTITION BY RANGE (id);
---END---
---START---
CREATE TABLE part1_self_fk (
    id bigint NOT NULL PRIMARY KEY,
    id_abc bigint
);
---END---
---START---
ALTER TABLE parted_self_fk ATTACH PARTITION part1_self_fk FOR VALUES FROM (0) TO (10);
---END---
---START---
CREATE TABLE part2_self_fk PARTITION OF parted_self_fk FOR VALUES FROM (10) TO (20);
---END---
---START---
CREATE TABLE part3_self_fk (	-- a partitioned partition
	id bigint NOT NULL PRIMARY KEY,
	id_abc bigint
) PARTITION BY RANGE (id);
---END---
---START---
CREATE TABLE part32_self_fk PARTITION OF part3_self_fk FOR VALUES FROM (20) TO (30);
---END---
---START---
ALTER TABLE parted_self_fk ATTACH PARTITION part3_self_fk FOR VALUES FROM (20) TO (40);
---END---
---START---
CREATE TABLE part33_self_fk (
	id bigint NOT NULL PRIMARY KEY,
	id_abc bigint
);
---END---
---START---
ALTER TABLE part3_self_fk ATTACH PARTITION part33_self_fk FOR VALUES FROM (30) TO (40);
---END---
---START---

SELECT cr.relname, co.conname, co.contype, co.convalidated,
       p.conname AS conparent, p.convalidated, cf.relname AS foreignrel
FROM pg_constraint co
JOIN pg_class cr ON cr.oid = co.conrelid
LEFT JOIN pg_class cf ON cf.oid = co.confrelid
LEFT JOIN pg_constraint p ON p.oid = co.conparentid
WHERE cr.oid IN (SELECT relid FROM pg_partition_tree('parted_self_fk'))
ORDER BY co.contype, cr.relname, co.conname, p.conname;
---END---
---START---

-- detach and re-attach multiple times just to ensure everything is kosher
ALTER TABLE parted_self_fk DETACH PARTITION part2_self_fk;
---END---
---START---
ALTER TABLE parted_self_fk ATTACH PARTITION part2_self_fk FOR VALUES FROM (10) TO (20);
---END---
---START---
ALTER TABLE parted_self_fk DETACH PARTITION part2_self_fk;
---END---
---START---
ALTER TABLE parted_self_fk ATTACH PARTITION part2_self_fk FOR VALUES FROM (10) TO (20);
---END---
---START---

SELECT cr.relname, co.conname, co.contype, co.convalidated,
       p.conname AS conparent, p.convalidated, cf.relname AS foreignrel
FROM pg_constraint co
JOIN pg_class cr ON cr.oid = co.conrelid
LEFT JOIN pg_class cf ON cf.oid = co.confrelid
LEFT JOIN pg_constraint p ON p.oid = co.conparentid
WHERE cr.oid IN (SELECT relid FROM pg_partition_tree('parted_self_fk'))
ORDER BY co.contype, cr.relname, co.conname, p.conname;
---END---
---START---

-- Leave this table around, for pg_upgrade/pg_dump tests


-- Test creating a constraint at the parent that already exists in partitions.
-- There should be no duplicated constraints, and attempts to drop the
-- constraint in partitions should raise appropriate errors.
create schema fkpart0
  create table pkey (a int primary key)
  create table fk_part (a int) partition by list (a)
  create table fk_part_1 partition of fk_part
      (foreign key (a) references fkpart0.pkey) for values in (1)
  create table fk_part_23 partition of fk_part
      (foreign key (a) references fkpart0.pkey) for values in (2, 3)
      partition by list (a)
  create table fk_part_23_2 partition of fk_part_23 for values in (2);
---END---
---START---

alter table fkpart0.fk_part add foreign key (a) references fkpart0.pkey;
---END---
---START---
\d fkpart0.fk_part_1	\\ -- should have only one FK
alter table fkpart0.fk_part_1 drop constraint fk_part_1_a_fkey;
---END---
---START---

\d fkpart0.fk_part_23	\\ -- should have only one FK
\d fkpart0.fk_part_23_2	\\ -- should have only one FK
alter table fkpart0.fk_part_23 drop constraint fk_part_23_a_fkey;
---END---
---START---
alter table fkpart0.fk_part_23_2 drop constraint fk_part_23_a_fkey;
---END---
---START---

create table fkpart0.fk_part_4 partition of fkpart0.fk_part for values in (4);
---END---
---START---
\d fkpart0.fk_part_4
alter table fkpart0.fk_part_4 drop constraint fk_part_a_fkey;
---END---
---START---

create table fkpart0.fk_part_56 partition of fkpart0.fk_part
    for values in (5,6) partition by list (a);
---END---
---START---
create table fkpart0.fk_part_56_5 partition of fkpart0.fk_part_56
    for values in (5);
---END---
---START---
\d fkpart0.fk_part_56
alter table fkpart0.fk_part_56 drop constraint fk_part_a_fkey;
---END---
---START---
alter table fkpart0.fk_part_56_5 drop constraint fk_part_a_fkey;
---END---
---START---

-- verify that attaching and detaching partitions maintains the right set of
-- triggers
create schema fkpart1
  create table pkey (a int primary key)
  create table fk_part (a int) partition by list (a)
  create table fk_part_1 partition of fk_part for values in (1) partition by list (a)
  create table fk_part_1_1 partition of fk_part_1 for values in (1);
---END---
---START---
alter table fkpart1.fk_part add foreign key (a) references fkpart1.pkey;
---END---
---START---
insert into fkpart1.fk_part values (1);		-- should fail
insert into fkpart1.pkey values (1);
---END---
---START---
insert into fkpart1.fk_part values (1);
---END---
---START---
delete from fkpart1.pkey where a = 1;		-- should fail
alter table fkpart1.fk_part detach partition fkpart1.fk_part_1;
---END---
---START---
create table fkpart1.fk_part_1_2 partition of fkpart1.fk_part_1 for values in (2);
---END---
---START---
insert into fkpart1.fk_part_1 values (2);	-- should fail
delete from fkpart1.pkey where a = 1;
---END---
---START---

-- verify that attaching and detaching partitions manipulates the inheritance
-- properties of their FK constraints correctly
create schema fkpart2
  create table pkey (a int primary key)
  create table fk_part (a int, constraint fkey foreign key (a) references fkpart2.pkey) partition by list (a)
  create table fk_part_1 partition of fkpart2.fk_part for values in (1) partition by list (a)
  create table fk_part_1_1 (a int, constraint my_fkey foreign key (a) references fkpart2.pkey);
---END---
---START---
alter table fkpart2.fk_part_1 attach partition fkpart2.fk_part_1_1 for values in (1);
---END---
---START---
alter table fkpart2.fk_part_1 drop constraint fkey;	-- should fail
alter table fkpart2.fk_part_1_1 drop constraint my_fkey;	-- should fail
alter table fkpart2.fk_part detach partition fkpart2.fk_part_1;
---END---
---START---
alter table fkpart2.fk_part_1 drop constraint fkey;	-- ok
alter table fkpart2.fk_part_1_1 drop constraint my_fkey;	-- doesn't exist

-- verify constraint deferrability
create schema fkpart3
  create table pkey (a int primary key)
  create table fk_part (a int, constraint fkey foreign key (a) references fkpart3.pkey deferrable initially immediate) partition by list (a)
  create table fk_part_1 partition of fkpart3.fk_part for values in (1) partition by list (a)
  create table fk_part_1_1 partition of fkpart3.fk_part_1 for values in (1)
  create table fk_part_2 partition of fkpart3.fk_part for values in (2);
---END---
---START---
begin;
---END---
---START---
set constraints fkpart3.fkey deferred;
---END---
---START---
insert into fkpart3.fk_part values (1);
---END---
---START---
insert into fkpart3.pkey values (1);
---END---
---START---
commit;
---END---
---START---
begin;
---END---
---START---
set constraints fkpart3.fkey deferred;
---END---
---START---
delete from fkpart3.pkey;
---END---
---START---
delete from fkpart3.fk_part;
---END---
---START---
commit;
---END---
---START---

drop schema fkpart0, fkpart1, fkpart2, fkpart3 cascade;
---END---
---START---

-- Test a partitioned table as referenced table.

-- Verify basic functionality with a regular partition creation and a partition
-- with a different column layout, as well as partitions added (created and
-- attached) after creating the foreign key.
CREATE SCHEMA fkpart3;
---END---
---START---
SET search_path TO fkpart3;
---END---
---START---

CREATE TABLE pk (a int PRIMARY KEY) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE pk1 PARTITION OF pk FOR VALUES FROM (0) TO (1000);
---END---
---START---
CREATE TABLE pk2 (b int, a int);
---END---
---START---
ALTER TABLE pk2 DROP COLUMN b;
---END---
---START---
ALTER TABLE pk2 ALTER a SET NOT NULL;
---END---
---START---
ALTER TABLE pk ATTACH PARTITION pk2 FOR VALUES FROM (1000) TO (2000);
---END---
---START---

CREATE TABLE fk (a int) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk1 PARTITION OF fk FOR VALUES FROM (0) TO (750);
---END---
---START---
ALTER TABLE fk ADD FOREIGN KEY (a) REFERENCES pk;
---END---
---START---
CREATE TABLE fk2 (b int, a int) ;
---END---
---START---
ALTER TABLE fk2 DROP COLUMN b;
---END---
---START---
ALTER TABLE fk ATTACH PARTITION fk2 FOR VALUES FROM (750) TO (3500);
---END---
---START---

CREATE TABLE pk3 PARTITION OF pk FOR VALUES FROM (2000) TO (3000);
---END---
---START---
CREATE TABLE pk4 (LIKE pk);
---END---
---START---
ALTER TABLE pk ATTACH PARTITION pk4 FOR VALUES FROM (3000) TO (4000);
---END---
---START---

CREATE TABLE pk5 (c int, b int, a int NOT NULL) PARTITION BY RANGE (a);
---END---
---START---
ALTER TABLE pk5 DROP COLUMN b, DROP COLUMN c;
---END---
---START---
CREATE TABLE pk51 PARTITION OF pk5 FOR VALUES FROM (4000) TO (4500);
---END---
---START---
CREATE TABLE pk52 PARTITION OF pk5 FOR VALUES FROM (4500) TO (5000);
---END---
---START---
ALTER TABLE pk ATTACH PARTITION pk5 FOR VALUES FROM (4000) TO (5000);
---END---
---START---

CREATE TABLE fk3 PARTITION OF fk FOR VALUES FROM (3500) TO (5000);
---END---
---START---

-- these should fail: referenced value not present
INSERT into fk VALUES (1);
---END---
---START---
INSERT into fk VALUES (1000);
---END---
---START---
INSERT into fk VALUES (2000);
---END---
---START---
INSERT into fk VALUES (3000);
---END---
---START---
INSERT into fk VALUES (4000);
---END---
---START---
INSERT into fk VALUES (4500);
---END---
---START---
-- insert into the referenced table, now they should work
INSERT into pk VALUES (1), (1000), (2000), (3000), (4000), (4500);
---END---
---START---
INSERT into fk VALUES (1), (1000), (2000), (3000), (4000), (4500);
---END---
---START---

-- should fail: referencing value present
DELETE FROM pk WHERE a = 1;
---END---
---START---
DELETE FROM pk WHERE a = 1000;
---END---
---START---
DELETE FROM pk WHERE a = 2000;
---END---
---START---
DELETE FROM pk WHERE a = 3000;
---END---
---START---
DELETE FROM pk WHERE a = 4000;
---END---
---START---
DELETE FROM pk WHERE a = 4500;
---END---
---START---
UPDATE pk SET a = 2 WHERE a = 1;
---END---
---START---
UPDATE pk SET a = 1002 WHERE a = 1000;
---END---
---START---
UPDATE pk SET a = 2002 WHERE a = 2000;
---END---
---START---
UPDATE pk SET a = 3002 WHERE a = 3000;
---END---
---START---
UPDATE pk SET a = 4002 WHERE a = 4000;
---END---
---START---
UPDATE pk SET a = 4502 WHERE a = 4500;
---END---
---START---
-- now they should work
DELETE FROM fk;
---END---
---START---
UPDATE pk SET a = 2 WHERE a = 1;
---END---
---START---
DELETE FROM pk WHERE a = 2;
---END---
---START---
UPDATE pk SET a = 1002 WHERE a = 1000;
---END---
---START---
DELETE FROM pk WHERE a = 1002;
---END---
---START---
UPDATE pk SET a = 2002 WHERE a = 2000;
---END---
---START---
DELETE FROM pk WHERE a = 2002;
---END---
---START---
UPDATE pk SET a = 3002 WHERE a = 3000;
---END---
---START---
DELETE FROM pk WHERE a = 3002;
---END---
---START---
UPDATE pk SET a = 4002 WHERE a = 4000;
---END---
---START---
DELETE FROM pk WHERE a = 4002;
---END---
---START---
UPDATE pk SET a = 4502 WHERE a = 4500;
---END---
---START---
DELETE FROM pk WHERE a = 4502;
---END---
---START---

CREATE SCHEMA fkpart4;
---END---
---START---
SET search_path TO fkpart4;
---END---
---START---
-- dropping/detaching PARTITIONs is prevented if that would break
-- a foreign key's existing data
CREATE TABLE droppk (a int PRIMARY KEY) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE droppk1 PARTITION OF droppk FOR VALUES FROM (0) TO (1000);
---END---
---START---
CREATE TABLE droppk_d PARTITION OF droppk DEFAULT;
---END---
---START---
CREATE TABLE droppk2 PARTITION OF droppk FOR VALUES FROM (1000) TO (2000)
  PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE droppk21 PARTITION OF droppk2 FOR VALUES FROM (1000) TO (1400);
---END---
---START---
CREATE TABLE droppk2_d PARTITION OF droppk2 DEFAULT;
---END---
---START---
INSERT into droppk VALUES (1), (1000), (1500), (2000);
---END---
---START---
CREATE TABLE dropfk (a int REFERENCES droppk);
---END---
---START---
INSERT into dropfk VALUES (1), (1000), (1500), (2000);
---END---
---START---
-- these should all fail
ALTER TABLE droppk DETACH PARTITION droppk_d;
---END---
---START---
ALTER TABLE droppk2 DETACH PARTITION droppk2_d;
---END---
---START---
ALTER TABLE droppk DETACH PARTITION droppk1;
---END---
---START---
ALTER TABLE droppk DETACH PARTITION droppk2;
---END---
---START---
ALTER TABLE droppk2 DETACH PARTITION droppk21;
---END---
---START---
-- dropping partitions is disallowed
DROP TABLE droppk_d;
---END---
---START---
DROP TABLE droppk2_d;
---END---
---START---
DROP TABLE droppk1;
---END---
---START---
DROP TABLE droppk2;
---END---
---START---
DROP TABLE droppk21;
---END---
---START---
DELETE FROM dropfk;
---END---
---START---
-- dropping partitions is disallowed, even when no referencing values
DROP TABLE droppk_d;
---END---
---START---
DROP TABLE droppk2_d;
---END---
---START---
DROP TABLE droppk1;
---END---
---START---
-- but DETACH is allowed, and DROP afterwards works
ALTER TABLE droppk2 DETACH PARTITION droppk21;
---END---
---START---
DROP TABLE droppk2;
---END---
---START---

-- Verify that initial constraint creation and cloning behave correctly
CREATE SCHEMA fkpart5;
---END---
---START---
SET search_path TO fkpart5;
---END---
---START---
CREATE TABLE pk (a int PRIMARY KEY) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE pk1 PARTITION OF pk FOR VALUES IN (1) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE pk11 PARTITION OF pk1 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE fk (a int) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE fk1 PARTITION OF fk FOR VALUES IN (1) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE fk11 PARTITION OF fk1 FOR VALUES IN (1);
---END---
---START---
ALTER TABLE fk ADD FOREIGN KEY (a) REFERENCES pk;
---END---
---START---
CREATE TABLE pk2 PARTITION OF pk FOR VALUES IN (2);
---END---
---START---
CREATE TABLE pk3 (a int NOT NULL) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE pk31 PARTITION OF pk3 FOR VALUES IN (31);
---END---
---START---
CREATE TABLE pk32 (b int, a int NOT NULL);
---END---
---START---
ALTER TABLE pk32 DROP COLUMN b;
---END---
---START---
ALTER TABLE pk3 ATTACH PARTITION pk32 FOR VALUES IN (32);
---END---
---START---
ALTER TABLE pk ATTACH PARTITION pk3 FOR VALUES IN (31, 32);
---END---
---START---
CREATE TABLE fk2 PARTITION OF fk FOR VALUES IN (2);
---END---
---START---
CREATE TABLE fk3 (b int, a int);
---END---
---START---
ALTER TABLE fk3 DROP COLUMN b;
---END---
---START---
ALTER TABLE fk ATTACH PARTITION fk3 FOR VALUES IN (3);
---END---
---START---
SELECT pg_describe_object('pg_constraint'::regclass, oid, 0), confrelid::regclass,
       CASE WHEN conparentid <> 0 THEN pg_describe_object('pg_constraint'::regclass, conparentid, 0) ELSE 'TOP' END
FROM pg_catalog.pg_constraint
WHERE conrelid IN (SELECT relid FROM pg_partition_tree('fk'))
ORDER BY conrelid::regclass::text, conname;
---END---
---START---
CREATE TABLE fk4 (LIKE fk);
---END---
---START---
INSERT INTO fk4 VALUES (50);
---END---
---START---
ALTER TABLE fk ATTACH PARTITION fk4 FOR VALUES IN (50);
---END---
---START---

-- Verify constraint deferrability
CREATE SCHEMA fkpart9;
---END---
---START---
SET search_path TO fkpart9;
---END---
---START---
CREATE TABLE pk (a int PRIMARY KEY) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE pk1 PARTITION OF pk FOR VALUES IN (1, 2) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE pk11 PARTITION OF pk1 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE pk3 PARTITION OF pk FOR VALUES IN (3);
---END---
---START---
CREATE TABLE fk (a int REFERENCES pk DEFERRABLE INITIALLY IMMEDIATE);
---END---
---START---
INSERT INTO fk VALUES (1);		-- should fail
BEGIN;
---END---
---START---
SET CONSTRAINTS fk_a_fkey DEFERRED;
---END---
---START---
INSERT INTO fk VALUES (1);
---END---
---START---
COMMIT;							-- should fail
BEGIN;
---END---
---START---
SET CONSTRAINTS fk_a_fkey DEFERRED;
---END---
---START---
INSERT INTO fk VALUES (1);
---END---
---START---
INSERT INTO pk VALUES (1);
---END---
---START---
COMMIT;							-- OK
BEGIN;
---END---
---START---
SET CONSTRAINTS fk_a_fkey DEFERRED;
---END---
---START---
DELETE FROM pk WHERE a = 1;
---END---
---START---
DELETE FROM fk WHERE a = 1;
---END---
---START---
COMMIT;							-- OK

-- Verify constraint deferrability when changed by ALTER
-- Partitioned table at referencing end
CREATE TABLE pt(f1 int, f2 int, f3 int, PRIMARY KEY(f1,f2));
---END---
---START---
CREATE TABLE ref(f1 int, f2 int, f3 int)
  PARTITION BY list(f1);
---END---
---START---
CREATE TABLE ref1 PARTITION OF ref FOR VALUES IN (1);
---END---
---START---
CREATE TABLE ref2 PARTITION OF ref FOR VALUES in (2);
---END---
---START---
ALTER TABLE ref ADD FOREIGN KEY(f1,f2) REFERENCES pt;
---END---
---START---
ALTER TABLE ref ALTER CONSTRAINT ref_f1_f2_fkey
  DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
INSERT INTO pt VALUES(1,2,3);
---END---
---START---
INSERT INTO ref VALUES(1,2,3);
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM pt;
---END---
---START---
DELETE FROM ref;
---END---
---START---
ABORT;
---END---
---START---
DROP TABLE pt, ref;
---END---
---START---
-- Multi-level partitioning at referencing end
CREATE TABLE pt(f1 int, f2 int, f3 int, PRIMARY KEY(f1,f2));
---END---
---START---
CREATE TABLE ref(f1 int, f2 int, f3 int)
  PARTITION BY list(f1);
---END---
---START---
CREATE TABLE ref1_2 PARTITION OF ref FOR VALUES IN (1, 2) PARTITION BY list (f2);
---END---
---START---
CREATE TABLE ref1 PARTITION OF ref1_2 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE ref2 PARTITION OF ref1_2 FOR VALUES IN (2) PARTITION BY list (f2);
---END---
---START---
CREATE TABLE ref22 PARTITION OF ref2 FOR VALUES IN (2);
---END---
---START---
ALTER TABLE ref ADD FOREIGN KEY(f1,f2) REFERENCES pt;
---END---
---START---
INSERT INTO pt VALUES(1,2,3);
---END---
---START---
INSERT INTO ref VALUES(1,2,3);
---END---
---START---
ALTER TABLE ref22 ALTER CONSTRAINT ref_f1_f2_fkey
  DEFERRABLE INITIALLY IMMEDIATE;	-- fails
ALTER TABLE ref ALTER CONSTRAINT ref_f1_f2_fkey
  DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM pt;
---END---
---START---
DELETE FROM ref;
---END---
---START---
ABORT;
---END---
---START---
DROP TABLE pt, ref;
---END---
---START---

-- Partitioned table at referenced end
CREATE TABLE pt(f1 int, f2 int, f3 int, PRIMARY KEY(f1,f2))
  PARTITION BY LIST(f1);
---END---
---START---
CREATE TABLE pt1 PARTITION OF pt FOR VALUES IN (1);
---END---
---START---
CREATE TABLE pt2 PARTITION OF pt FOR VALUES IN (2);
---END---
---START---
CREATE TABLE ref(f1 int, f2 int, f3 int);
---END---
---START---
ALTER TABLE ref ADD FOREIGN KEY(f1,f2) REFERENCES pt;
---END---
---START---
ALTER TABLE ref ALTER CONSTRAINT ref_f1_f2_fkey
  DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
INSERT INTO pt VALUES(1,2,3);
---END---
---START---
INSERT INTO ref VALUES(1,2,3);
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM pt;
---END---
---START---
DELETE FROM ref;
---END---
---START---
ABORT;
---END---
---START---
DROP TABLE pt, ref;
---END---
---START---
-- Multi-level partitioning at referenced end
CREATE TABLE pt(f1 int, f2 int, f3 int, PRIMARY KEY(f1,f2))
  PARTITION BY LIST(f1);
---END---
---START---
CREATE TABLE pt1_2 PARTITION OF pt FOR VALUES IN (1, 2) PARTITION BY LIST (f1);
---END---
---START---
CREATE TABLE pt1 PARTITION OF pt1_2 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE pt2 PARTITION OF pt1_2 FOR VALUES IN (2);
---END---
---START---
CREATE TABLE ref(f1 int, f2 int, f3 int);
---END---
---START---
ALTER TABLE ref ADD FOREIGN KEY(f1,f2) REFERENCES pt;
---END---
---START---
ALTER TABLE ref ALTER CONSTRAINT ref_f1_f2_fkey1
  DEFERRABLE INITIALLY DEFERRED;	-- fails
ALTER TABLE ref ALTER CONSTRAINT ref_f1_f2_fkey
  DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
INSERT INTO pt VALUES(1,2,3);
---END---
---START---
INSERT INTO ref VALUES(1,2,3);
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM pt;
---END---
---START---
DELETE FROM ref;
---END---
---START---
ABORT;
---END---
---START---
DROP TABLE pt, ref;
---END---
---START---

DROP SCHEMA fkpart9 CASCADE;
---END---
---START---

-- Verify ON UPDATE/DELETE behavior
CREATE SCHEMA fkpart6;
---END---
---START---
SET search_path TO fkpart6;
---END---
---START---
CREATE TABLE pk (a int PRIMARY KEY) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE pk1 PARTITION OF pk FOR VALUES FROM (1) TO (100) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE pk11 PARTITION OF pk1 FOR VALUES FROM (1) TO (50);
---END---
---START---
CREATE TABLE pk12 PARTITION OF pk1 FOR VALUES FROM (50) TO (100);
---END---
---START---
CREATE TABLE fk (a int) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk1 PARTITION OF fk FOR VALUES FROM (1) TO (100) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk11 PARTITION OF fk1 FOR VALUES FROM (1) TO (10);
---END---
---START---
CREATE TABLE fk12 PARTITION OF fk1 FOR VALUES FROM (10) TO (100);
---END---
---START---
ALTER TABLE fk ADD FOREIGN KEY (a) REFERENCES pk ON UPDATE CASCADE ON DELETE CASCADE;
---END---
---START---
CREATE TABLE fk_d PARTITION OF fk DEFAULT;
---END---
---START---
INSERT INTO pk VALUES (1);
---END---
---START---
INSERT INTO fk VALUES (1);
---END---
---START---
UPDATE pk SET a = 20;
---END---
---START---
SELECT tableoid::regclass, * FROM fk;
---END---
---START---
DELETE FROM pk WHERE a = 20;
---END---
---START---
SELECT tableoid::regclass, * FROM fk;
---END---
---START---
DROP TABLE fk;
---END---
---START---

TRUNCATE TABLE pk;
---END---
---START---
INSERT INTO pk VALUES (20), (50);
---END---
---START---
CREATE TABLE fk (a int) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk1 PARTITION OF fk FOR VALUES FROM (1) TO (100) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk11 PARTITION OF fk1 FOR VALUES FROM (1) TO (10);
---END---
---START---
CREATE TABLE fk12 PARTITION OF fk1 FOR VALUES FROM (10) TO (100);
---END---
---START---
ALTER TABLE fk ADD FOREIGN KEY (a) REFERENCES pk ON UPDATE SET NULL ON DELETE SET NULL;
---END---
---START---
CREATE TABLE fk_d PARTITION OF fk DEFAULT;
---END---
---START---
INSERT INTO fk VALUES (20), (50);
---END---
---START---
UPDATE pk SET a = 21 WHERE a = 20;
---END---
---START---
DELETE FROM pk WHERE a = 50;
---END---
---START---
SELECT tableoid::regclass, * FROM fk;
---END---
---START---
DROP TABLE fk;
---END---
---START---

TRUNCATE TABLE pk;
---END---
---START---
INSERT INTO pk VALUES (20), (30), (50);
---END---
---START---
CREATE TABLE fk (id int, a int DEFAULT 50) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk1 PARTITION OF fk FOR VALUES FROM (1) TO (100) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk11 PARTITION OF fk1 FOR VALUES FROM (1) TO (10);
---END---
---START---
CREATE TABLE fk12 PARTITION OF fk1 FOR VALUES FROM (10) TO (100);
---END---
---START---
ALTER TABLE fk ADD FOREIGN KEY (a) REFERENCES pk ON UPDATE SET DEFAULT ON DELETE SET DEFAULT;
---END---
---START---
CREATE TABLE fk_d PARTITION OF fk DEFAULT;
---END---
---START---
INSERT INTO fk VALUES (1, 20), (2, 30);
---END---
---START---
DELETE FROM pk WHERE a = 20 RETURNING *;
---END---
---START---
UPDATE pk SET a = 90 WHERE a = 30 RETURNING *;
---END---
---START---
SELECT tableoid::regclass, * FROM fk;
---END---
---START---
DROP TABLE fk;
---END---
---START---

TRUNCATE TABLE pk;
---END---
---START---
INSERT INTO pk VALUES (20), (30);
---END---
---START---
CREATE TABLE fk (a int DEFAULT 50) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk1 PARTITION OF fk FOR VALUES FROM (1) TO (100) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE fk11 PARTITION OF fk1 FOR VALUES FROM (1) TO (10);
---END---
---START---
CREATE TABLE fk12 PARTITION OF fk1 FOR VALUES FROM (10) TO (100);
---END---
---START---
ALTER TABLE fk ADD FOREIGN KEY (a) REFERENCES pk ON UPDATE RESTRICT ON DELETE RESTRICT;
---END---
---START---
CREATE TABLE fk_d PARTITION OF fk DEFAULT;
---END---
---START---
INSERT INTO fk VALUES (20), (30);
---END---
---START---
DELETE FROM pk WHERE a = 20;
---END---
---START---
UPDATE pk SET a = 90 WHERE a = 30;
---END---
---START---
SELECT tableoid::regclass, * FROM fk;
---END---
---START---
DROP TABLE fk;
---END---
---START---

-- test for reported bug: relispartition not set
-- https://postgr.es/m/CA+HiwqHMsRtRYRWYTWavKJ8x14AFsv7bmAV46mYwnfD3vy8goQ@mail.gmail.com
CREATE SCHEMA fkpart7
  CREATE TABLE pkpart (a int) PARTITION BY LIST (a)
  CREATE TABLE pkpart1 PARTITION OF pkpart FOR VALUES IN (1);
---END---
---START---
ALTER TABLE fkpart7.pkpart1 ADD PRIMARY KEY (a);
---END---
---START---
ALTER TABLE fkpart7.pkpart ADD PRIMARY KEY (a);
---END---
---START---
CREATE TABLE fkpart7.fk (a int REFERENCES fkpart7.pkpart);
---END---
---START---
DROP SCHEMA fkpart7 CASCADE;
---END---
---START---

-- ensure we check partitions are "not used" when dropping constraints
CREATE SCHEMA fkpart8
  CREATE TABLE tbl1(f1 int PRIMARY KEY)
  CREATE TABLE tbl2(f1 int REFERENCES tbl1 DEFERRABLE INITIALLY DEFERRED) PARTITION BY RANGE(f1)
  CREATE TABLE tbl2_p1 PARTITION OF tbl2 FOR VALUES FROM (minvalue) TO (maxvalue);
---END---
---START---
INSERT INTO fkpart8.tbl1 VALUES(1);
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO fkpart8.tbl2 VALUES(1);
---END---
---START---
ALTER TABLE fkpart8.tbl2 DROP CONSTRAINT tbl2_f1_fkey;
---END---
---START---
COMMIT;
---END---
---START---
DROP SCHEMA fkpart8 CASCADE;
---END---
---START---

-- ensure FK referencing a multi-level partitioned table are
-- enforce reference to sub-children.
CREATE SCHEMA fkpart9
  CREATE TABLE pk (a INT PRIMARY KEY) PARTITION BY RANGE (a)
  CREATE TABLE fk (
    fk_a INT REFERENCES pk(a) ON DELETE CASCADE
  )
  CREATE TABLE pk1 PARTITION OF pk FOR VALUES FROM (30) TO (50) PARTITION BY RANGE (a)
  CREATE TABLE pk11 PARTITION OF pk1 FOR VALUES FROM (30) TO (40);
---END---
---START---
INSERT INTO fkpart9.pk VALUES (35);
---END---
---START---
INSERT INTO fkpart9.fk VALUES (35);
---END---
---START---
DELETE FROM fkpart9.pk WHERE a=35;
---END---
---START---
SELECT * FROM fkpart9.pk;
---END---
---START---
SELECT * FROM fkpart9.fk;
---END---
---START---
DROP SCHEMA fkpart9 CASCADE;
---END---
---START---

-- test that ri_Check_Pk_Match() scans the correct partition for a deferred
-- ON DELETE/UPDATE NO ACTION constraint
CREATE SCHEMA fkpart10
  CREATE TABLE tbl1(f1 int PRIMARY KEY) PARTITION BY RANGE(f1)
  CREATE TABLE tbl1_p1 PARTITION OF tbl1 FOR VALUES FROM (minvalue) TO (1)
  CREATE TABLE tbl1_p2 PARTITION OF tbl1 FOR VALUES FROM (1) TO (maxvalue)
  CREATE TABLE tbl2(f1 int REFERENCES tbl1 DEFERRABLE INITIALLY DEFERRED)
  CREATE TABLE tbl3(f1 int PRIMARY KEY) PARTITION BY RANGE(f1)
  CREATE TABLE tbl3_p1 PARTITION OF tbl3 FOR VALUES FROM (minvalue) TO (1)
  CREATE TABLE tbl3_p2 PARTITION OF tbl3 FOR VALUES FROM (1) TO (maxvalue)
  CREATE TABLE tbl4(f1 int REFERENCES tbl3 DEFERRABLE INITIALLY DEFERRED);
---END---
---START---
INSERT INTO fkpart10.tbl1 VALUES (0), (1);
---END---
---START---
INSERT INTO fkpart10.tbl2 VALUES (0), (1);
---END---
---START---
INSERT INTO fkpart10.tbl3 VALUES (-2), (-1), (0);
---END---
---START---
INSERT INTO fkpart10.tbl4 VALUES (-2), (-1);
---END---
---START---
BEGIN;
---END---
---START---
DELETE FROM fkpart10.tbl1 WHERE f1 = 0;
---END---
---START---
UPDATE fkpart10.tbl1 SET f1 = 2 WHERE f1 = 1;
---END---
---START---
INSERT INTO fkpart10.tbl1 VALUES (0), (1);
---END---
---START---
COMMIT;
---END---
---START---

-- test that cross-partition updates correctly enforces the foreign key
-- restriction (specifically testing INITIAILLY DEFERRED)
BEGIN;
---END---
---START---
UPDATE fkpart10.tbl1 SET f1 = 3 WHERE f1 = 0;
---END---
---START---
UPDATE fkpart10.tbl3 SET f1 = f1 * -1;
---END---
---START---
INSERT INTO fkpart10.tbl1 VALUES (4);
---END---
---START---
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
UPDATE fkpart10.tbl3 SET f1 = f1 * -1;
---END---
---START---
UPDATE fkpart10.tbl3 SET f1 = f1 + 3;
---END---
---START---
UPDATE fkpart10.tbl1 SET f1 = 3 WHERE f1 = 0;
---END---
---START---
INSERT INTO fkpart10.tbl1 VALUES (0);
---END---
---START---
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
UPDATE fkpart10.tbl3 SET f1 = f1 * -1;
---END---
---START---
UPDATE fkpart10.tbl1 SET f1 = 3 WHERE f1 = 0;
---END---
---START---
INSERT INTO fkpart10.tbl1 VALUES (0);
---END---
---START---
INSERT INTO fkpart10.tbl3 VALUES (-2), (-1);
---END---
---START---
COMMIT;
---END---
---START---

-- test where the updated table now has both an IMMEDIATE and a DEFERRED
-- constraint pointing into it
CREATE TABLE fkpart10.tbl5(f1 int REFERENCES fkpart10.tbl3);
---END---
---START---
INSERT INTO fkpart10.tbl5 VALUES (-2), (-1);
---END---
---START---
BEGIN;
---END---
---START---
UPDATE fkpart10.tbl3 SET f1 = f1 * -3;
---END---
---START---
COMMIT;
---END---
---START---

-- Now test where the row referenced from the table with an IMMEDIATE
-- constraint stays in place, while those referenced from the table with a
-- DEFERRED constraint don't.
DELETE FROM fkpart10.tbl5;
---END---
---START---
INSERT INTO fkpart10.tbl5 VALUES (0);
---END---
---START---
BEGIN;
---END---
---START---
UPDATE fkpart10.tbl3 SET f1 = f1 * -3;
---END---
---START---
COMMIT;
---END---
---START---

DROP SCHEMA fkpart10 CASCADE;
---END---
---START---

-- verify foreign keys are enforced during cross-partition updates,
-- especially on the PK side
CREATE SCHEMA fkpart11
  CREATE TABLE pk (a INT PRIMARY KEY, b text) PARTITION BY LIST (a)
  CREATE TABLE fk (
    a INT,
    CONSTRAINT fkey FOREIGN KEY (a) REFERENCES pk(a) ON UPDATE CASCADE ON DELETE CASCADE
  )
  CREATE TABLE fk_parted (
    a INT PRIMARY KEY,
    CONSTRAINT fkey FOREIGN KEY (a) REFERENCES pk(a) ON UPDATE CASCADE ON DELETE CASCADE
  ) PARTITION BY LIST (a)
  CREATE TABLE fk_another (
    a INT,
    CONSTRAINT fkey FOREIGN KEY (a) REFERENCES fk_parted (a) ON UPDATE CASCADE ON DELETE CASCADE
  )
  CREATE TABLE pk1 PARTITION OF pk FOR VALUES IN (1, 2) PARTITION BY LIST (a)
  CREATE TABLE pk2 PARTITION OF pk FOR VALUES IN (3)
  CREATE TABLE pk3 PARTITION OF pk FOR VALUES IN (4)
  CREATE TABLE fk1 PARTITION OF fk_parted FOR VALUES IN (1, 2)
  CREATE TABLE fk2 PARTITION OF fk_parted FOR VALUES IN (3)
  CREATE TABLE fk3 PARTITION OF fk_parted FOR VALUES IN (4);
---END---
---START---
CREATE TABLE fkpart11.pk11 (b text, a int NOT NULL);
---END---
---START---
ALTER TABLE fkpart11.pk1 ATTACH PARTITION fkpart11.pk11 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE fkpart11.pk12 (b text, c int, a int NOT NULL);
---END---
---START---
ALTER TABLE fkpart11.pk12 DROP c;
---END---
---START---
ALTER TABLE fkpart11.pk1 ATTACH PARTITION fkpart11.pk12 FOR VALUES IN (2);
---END---
---START---
INSERT INTO fkpart11.pk VALUES (1, 'xxx'), (3, 'yyy');
---END---
---START---
INSERT INTO fkpart11.fk VALUES (1), (3);
---END---
---START---
INSERT INTO fkpart11.fk_parted VALUES (1), (3);
---END---
---START---
INSERT INTO fkpart11.fk_another VALUES (1), (3);
---END---
---START---
-- moves 2 rows from one leaf partition to another, with both updates being
-- cascaded to fk and fk_parted.  Updates of fk_parted, of which one is
-- cross-partition (3 -> 4), are further cascaded to fk_another.
UPDATE fkpart11.pk SET a = a + 1 RETURNING tableoid::pg_catalog.regclass, *;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk_parted;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk_another;
---END---
---START---

-- let's try with the foreign key pointing at tables in the partition tree
-- that are not the same as the query's target table

-- 1. foreign key pointing into a non-root ancestor
--
-- A cross-partition update on the root table will fail, because we currently
-- can't enforce the foreign keys pointing into a non-leaf partition
ALTER TABLE fkpart11.fk DROP CONSTRAINT fkey;
---END---
---START---
DELETE FROM fkpart11.fk WHERE a = 4;
---END---
---START---
ALTER TABLE fkpart11.fk ADD CONSTRAINT fkey FOREIGN KEY (a) REFERENCES fkpart11.pk1 (a) ON UPDATE CASCADE ON DELETE CASCADE;
---END---
---START---
UPDATE fkpart11.pk SET a = a - 1;
---END---
---START---
-- it's okay though if the non-leaf partition is updated directly
UPDATE fkpart11.pk1 SET a = a - 1;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.pk;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk_parted;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk_another;
---END---
---START---

-- 2. foreign key pointing into a single leaf partition
--
-- A cross-partition update that deletes from the pointed-to leaf partition
-- is allowed to succeed
ALTER TABLE fkpart11.fk DROP CONSTRAINT fkey;
---END---
---START---
ALTER TABLE fkpart11.fk ADD CONSTRAINT fkey FOREIGN KEY (a) REFERENCES fkpart11.pk11 (a) ON UPDATE CASCADE ON DELETE CASCADE;
---END---
---START---
-- will delete (1) from p11 which is cascaded to fk
UPDATE fkpart11.pk SET a = a + 1 WHERE a = 1;
---END---
---START---
SELECT tableoid::pg_catalog.regclass, * FROM fkpart11.fk;
---END---
---START---
DROP TABLE fkpart11.fk;
---END---
---START---

-- check that regular and deferrable AR triggers on the PK tables
-- still work as expected
CREATE FUNCTION fkpart11.print_row () RETURNS TRIGGER LANGUAGE plpgsql AS $$
  BEGIN
    RAISE NOTICE 'TABLE: %, OP: %, OLD: %, NEW: %', TG_RELNAME, TG_OP, OLD, NEW;
---END---
---START---
    RETURN NULL;
---END---
---START---
  END;
---END---
---START---
$$;
---END---
---START---
CREATE TRIGGER trig_upd_pk AFTER UPDATE ON fkpart11.pk FOR EACH ROW EXECUTE FUNCTION fkpart11.print_row();
---END---
---START---
CREATE TRIGGER trig_del_pk AFTER DELETE ON fkpart11.pk FOR EACH ROW EXECUTE FUNCTION fkpart11.print_row();
---END---
---START---
CREATE TRIGGER trig_ins_pk AFTER INSERT ON fkpart11.pk FOR EACH ROW EXECUTE FUNCTION fkpart11.print_row();
---END---
---START---
CREATE CONSTRAINT TRIGGER trig_upd_fk_parted AFTER UPDATE ON fkpart11.fk_parted INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION fkpart11.print_row();
---END---
---START---
CREATE CONSTRAINT TRIGGER trig_del_fk_parted AFTER DELETE ON fkpart11.fk_parted INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION fkpart11.print_row();
---END---
---START---
CREATE CONSTRAINT TRIGGER trig_ins_fk_parted AFTER INSERT ON fkpart11.fk_parted INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION fkpart11.print_row();
---END---
---START---
UPDATE fkpart11.pk SET a = 3 WHERE a = 4;
---END---
---START---
UPDATE fkpart11.pk SET a = 1 WHERE a = 2;
---END---
---START---

DROP SCHEMA fkpart11 CASCADE;
---END---
