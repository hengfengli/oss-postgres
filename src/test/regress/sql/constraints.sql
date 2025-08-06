---START---
--
-- CONSTRAINTS
-- Constraints can be specified with:
--  - DEFAULT clause
--  - CHECK clauses
--  - PRIMARY KEY clauses
--  - UNIQUE clauses
--  - EXCLUDE clauses
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

--
-- DEFAULT syntax
--

CREATE TABLE DEFAULT_TBL (i int DEFAULT 100,
	x text DEFAULT 'vadim', f float8 DEFAULT 123.456);
---END---
---START---

INSERT INTO DEFAULT_TBL VALUES (1, 'thomas', 57.0613);
---END---
---START---
INSERT INTO DEFAULT_TBL VALUES (1, 'bruce');
---END---
---START---
INSERT INTO DEFAULT_TBL (i, f) VALUES (2, 987.654);
---END---
---START---
INSERT INTO DEFAULT_TBL (x) VALUES ('marc');
---END---
---START---
INSERT INTO DEFAULT_TBL VALUES (3, null, 1.0);
---END---
---START---

SELECT * FROM DEFAULT_TBL;
---END---
---START---

CREATE SEQUENCE DEFAULT_SEQ;
---END---
---START---

CREATE TABLE DEFAULTEXPR_TBL (i1 int DEFAULT 100 + (200-199) * 2,
	i2 int DEFAULT nextval('default_seq'));
---END---
---START---

INSERT INTO DEFAULTEXPR_TBL VALUES (-1, -2);
---END---
---START---
INSERT INTO DEFAULTEXPR_TBL (i1) VALUES (-3);
---END---
---START---
INSERT INTO DEFAULTEXPR_TBL (i2) VALUES (-4);
---END---
---START---
INSERT INTO DEFAULTEXPR_TBL (i2) VALUES (NULL);
---END---
---START---

SELECT * FROM DEFAULTEXPR_TBL;
---END---
---START---

-- syntax errors
--  test for extraneous comma
CREATE TABLE error_tbl (i int DEFAULT (100, ));
---END---
---START---
--  this will fail because gram.y uses b_expr not a_expr for defaults,
--  to avoid a shift/reduce conflict that arises from NOT NULL being
--  part of the column definition syntax:
CREATE TABLE error_tbl (b1 bool DEFAULT 1 IN (1, 2));
---END---
---START---
--  this should work, however:
CREATE TABLE error_tbl (b1 bool DEFAULT (1 IN (1, 2)));
---END---
---START---

DROP TABLE error_tbl;
---END---
---START---

--
-- CHECK syntax
--

CREATE TABLE CHECK_TBL (x int,
	CONSTRAINT CHECK_CON CHECK (x > 3));
---END---
---START---

INSERT INTO CHECK_TBL VALUES (5);
---END---
---START---
INSERT INTO CHECK_TBL VALUES (4);
---END---
---START---
INSERT INTO CHECK_TBL VALUES (3);
---END---
---START---
INSERT INTO CHECK_TBL VALUES (2);
---END---
---START---
INSERT INTO CHECK_TBL VALUES (6);
---END---
---START---
INSERT INTO CHECK_TBL VALUES (1);
---END---
---START---

SELECT * FROM CHECK_TBL;
---END---
---START---

CREATE SEQUENCE CHECK_SEQ;
---END---
---START---

CREATE TABLE CHECK2_TBL (x int, y text, z int,
	CONSTRAINT SEQUENCE_CON
	CHECK (x > 3 and y <> 'check failed' and z < 8));
---END---
---START---

INSERT INTO CHECK2_TBL VALUES (4, 'check ok', -2);
---END---
---START---
INSERT INTO CHECK2_TBL VALUES (1, 'x check failed', -2);
---END---
---START---
INSERT INTO CHECK2_TBL VALUES (5, 'z check failed', 10);
---END---
---START---
INSERT INTO CHECK2_TBL VALUES (0, 'check failed', -2);
---END---
---START---
INSERT INTO CHECK2_TBL VALUES (6, 'check failed', 11);
---END---
---START---
INSERT INTO CHECK2_TBL VALUES (7, 'check ok', 7);
---END---
---START---

SELECT * from CHECK2_TBL;
---END---
---START---

--
-- Check constraints on INSERT
--

CREATE SEQUENCE INSERT_SEQ;
---END---
---START---

CREATE TABLE INSERT_TBL (x INT DEFAULT nextval('insert_seq'),
	y TEXT DEFAULT '-NULL-',
	z INT DEFAULT -1 * currval('insert_seq'),
	CONSTRAINT INSERT_TBL_CON CHECK (x >= 3 AND y <> 'check failed' AND x < 8),
	CHECK (x + z = 0));
---END---
---START---

INSERT INTO INSERT_TBL(x,z) VALUES (2, -2);
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

SELECT 'one' AS one, nextval('insert_seq');
---END---
---START---

INSERT INTO INSERT_TBL(y) VALUES ('Y');
---END---
---START---
INSERT INTO INSERT_TBL(y) VALUES ('Y');
---END---
---START---
INSERT INTO INSERT_TBL(x,z) VALUES (1, -2);
---END---
---START---
INSERT INTO INSERT_TBL(z,x) VALUES (-7,  7);
---END---
---START---
INSERT INTO INSERT_TBL VALUES (5, 'check failed', -5);
---END---
---START---
INSERT INTO INSERT_TBL VALUES (7, '!check failed', -7);
---END---
---START---
INSERT INTO INSERT_TBL(y) VALUES ('-!NULL-');
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

INSERT INTO INSERT_TBL(y,z) VALUES ('check failed', 4);
---END---
---START---
INSERT INTO INSERT_TBL(x,y) VALUES (5, 'check failed');
---END---
---START---
INSERT INTO INSERT_TBL(x,y) VALUES (5, '!check failed');
---END---
---START---
INSERT INTO INSERT_TBL(y) VALUES ('-!NULL-');
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

SELECT 'seven' AS one, nextval('insert_seq');
---END---
---START---

INSERT INTO INSERT_TBL(y) VALUES ('Y');
---END---
---START---

SELECT 'eight' AS one, currval('insert_seq');
---END---
---START---

-- According to SQL, it is OK to insert a record that gives rise to NULL
-- constraint-condition results.  Postgres used to reject this, but it
-- was wrong:
INSERT INTO INSERT_TBL VALUES (null, null, null);
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

--
-- Check constraints on system columns
--

CREATE TABLE SYS_COL_CHECK_TBL (city text, state text, is_capital bool,
                  altitude int,
                  CHECK (NOT (is_capital AND tableoid::regclass::text = 'sys_col_check_tbl')));
---END---
---START---

INSERT INTO SYS_COL_CHECK_TBL VALUES ('Seattle', 'Washington', false, 100);
---END---
---START---
INSERT INTO SYS_COL_CHECK_TBL VALUES ('Olympia', 'Washington', true, 100);
---END---
---START---

SELECT *, tableoid::regclass::text FROM SYS_COL_CHECK_TBL;
---END---
---START---

DROP TABLE SYS_COL_CHECK_TBL;
---END---
---START---

--
-- Check constraints on system columns other then TableOid should return error
--
CREATE TABLE SYS_COL_CHECK_TBL (city text, state text, is_capital bool,
                  altitude int,
				  CHECK (NOT (is_capital AND ctid::text = 'sys_col_check_tbl')));
---END---
---START---

--
-- Check inheritance of defaults and constraints
--

CREATE TABLE INSERT_CHILD (cx INT default 42,
	cy INT CHECK (cy > x))
	INHERITS (INSERT_TBL);
---END---
---START---

INSERT INTO INSERT_CHILD(x,z,cy) VALUES (7,-7,11);
---END---
---START---
INSERT INTO INSERT_CHILD(x,z,cy) VALUES (7,-7,6);
---END---
---START---
INSERT INTO INSERT_CHILD(x,z,cy) VALUES (6,-7,7);
---END---
---START---
INSERT INTO INSERT_CHILD(x,y,z,cy) VALUES (6,'check failed',-6,7);
---END---
---START---

SELECT * FROM INSERT_CHILD;
---END---
---START---

DROP TABLE INSERT_CHILD;
---END---
---START---

--
-- Check NO INHERIT type of constraints and inheritance
--

CREATE TABLE ATACC1 (TEST INT
	CHECK (TEST > 0) NO INHERIT);
---END---
---START---

CREATE TABLE ATACC2 (TEST2 INT) INHERITS (ATACC1);
---END---
---START---
-- check constraint is not there on child
INSERT INTO ATACC2 (TEST) VALUES (-3);
---END---
---START---
-- check constraint is there on parent
INSERT INTO ATACC1 (TEST) VALUES (-3);
---END---
---START---
DROP TABLE ATACC1 CASCADE;
---END---
---START---

CREATE TABLE ATACC1 (TEST INT, TEST2 INT
	CHECK (TEST > 0), CHECK (TEST2 > 10) NO INHERIT);
---END---
---START---

CREATE TABLE ATACC2 () INHERITS (ATACC1);
---END---
---START---
-- check constraint is there on child
INSERT INTO ATACC2 (TEST) VALUES (-3);
---END---
---START---
-- check constraint is there on parent
INSERT INTO ATACC1 (TEST) VALUES (-3);
---END---
---START---
-- check constraint is not there on child
INSERT INTO ATACC2 (TEST2) VALUES (3);
---END---
---START---
-- check constraint is there on parent
INSERT INTO ATACC1 (TEST2) VALUES (3);
---END---
---START---
DROP TABLE ATACC1 CASCADE;
---END---
---START---

--
-- Check constraints on INSERT INTO
--

DELETE FROM INSERT_TBL;
---END---
---START---

ALTER SEQUENCE INSERT_SEQ RESTART WITH 4;
---END---
---START---

CREATE TABLE tmp (xd INT, yd TEXT, zd INT);
---END---
---START---

INSERT INTO tmp VALUES (null, 'Y', null);
---END---
---START---
INSERT INTO tmp VALUES (5, '!check failed', null);
---END---
---START---
INSERT INTO tmp VALUES (null, 'try again', null);
---END---
---START---
INSERT INTO INSERT_TBL(y) select yd from tmp;
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

INSERT INTO INSERT_TBL SELECT * FROM tmp WHERE yd = 'try again';
---END---
---START---
INSERT INTO INSERT_TBL(y,z) SELECT yd, -7 FROM tmp WHERE yd = 'try again';
---END---
---START---
INSERT INTO INSERT_TBL(y,z) SELECT yd, -8 FROM tmp WHERE yd = 'try again';
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

DROP TABLE tmp;
---END---
---START---

--
-- Check constraints on UPDATE
--

UPDATE INSERT_TBL SET x = NULL WHERE x = 5;
---END---
---START---
UPDATE INSERT_TBL SET x = 6 WHERE x = 6;
---END---
---START---
UPDATE INSERT_TBL SET x = -z, z = -x;
---END---
---START---
UPDATE INSERT_TBL SET x = z, z = x;
---END---
---START---

SELECT * FROM INSERT_TBL;
---END---
---START---

-- DROP TABLE INSERT_TBL;
---END---
---START---

--
-- Check constraints on COPY FROM
--

CREATE TABLE COPY_TBL (x INT, y TEXT, z INT,
	CONSTRAINT COPY_CON
	CHECK (x > 3 AND y <> 'check failed' AND x < 7 ));
---END---
---START---

\set filename :abs_srcdir '/data/constro.data'
COPY COPY_TBL FROM :'filename';
---END---
---START---

SELECT * FROM COPY_TBL;
---END---
---START---

\set filename :abs_srcdir '/data/constrf.data'
COPY COPY_TBL FROM :'filename';
---END---
---START---

SELECT * FROM COPY_TBL;
---END---
---START---

--
-- Primary keys
--

CREATE TABLE PRIMARY_TBL (i int PRIMARY KEY, t text);
---END---
---START---

INSERT INTO PRIMARY_TBL VALUES (1, 'one');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (2, 'two');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (1, 'three');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (4, 'three');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (5, 'one');
---END---
---START---
INSERT INTO PRIMARY_TBL (t) VALUES ('six');
---END---
---START---

SELECT * FROM PRIMARY_TBL;
---END---
---START---

DROP TABLE PRIMARY_TBL;
---END---
---START---

CREATE TABLE PRIMARY_TBL (i int, t text,
	PRIMARY KEY(i,t));
---END---
---START---

INSERT INTO PRIMARY_TBL VALUES (1, 'one');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (2, 'two');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (1, 'three');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (4, 'three');
---END---
---START---
INSERT INTO PRIMARY_TBL VALUES (5, 'one');
---END---
---START---
INSERT INTO PRIMARY_TBL (t) VALUES ('six');
---END---
---START---

SELECT * FROM PRIMARY_TBL;
---END---
---START---

DROP TABLE PRIMARY_TBL;
---END---
---START---

--
-- Unique keys
--

CREATE TABLE UNIQUE_TBL (i int UNIQUE, t text);
---END---
---START---

INSERT INTO UNIQUE_TBL VALUES (1, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (2, 'two');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (1, 'three');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (4, 'four');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (5, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL (t) VALUES ('six');
---END---
---START---
INSERT INTO UNIQUE_TBL (t) VALUES ('seven');
---END---
---START---

INSERT INTO UNIQUE_TBL VALUES (5, 'five-upsert-insert') ON CONFLICT (i) DO UPDATE SET t = 'five-upsert-update';
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (6, 'six-upsert-insert') ON CONFLICT (i) DO UPDATE SET t = 'six-upsert-update';
---END---
---START---
-- should fail
INSERT INTO UNIQUE_TBL VALUES (1, 'a'), (2, 'b'), (2, 'b') ON CONFLICT (i) DO UPDATE SET t = 'fails';
---END---
---START---

SELECT * FROM UNIQUE_TBL;
---END---
---START---

DROP TABLE UNIQUE_TBL;
---END---
---START---

CREATE TABLE UNIQUE_TBL (i int UNIQUE NULLS NOT DISTINCT, t text);
---END---
---START---

INSERT INTO UNIQUE_TBL VALUES (1, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (2, 'two');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (1, 'three');  -- fail
INSERT INTO UNIQUE_TBL VALUES (4, 'four');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (5, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL (t) VALUES ('six');
---END---
---START---
INSERT INTO UNIQUE_TBL (t) VALUES ('seven');  -- fail
INSERT INTO UNIQUE_TBL (t) VALUES ('eight') ON CONFLICT DO NOTHING;  -- no-op

SELECT * FROM UNIQUE_TBL;
---END---
---START---

DROP TABLE UNIQUE_TBL;
---END---
---START---

CREATE TABLE UNIQUE_TBL (i int, t text,
	UNIQUE(i,t));
---END---
---START---

INSERT INTO UNIQUE_TBL VALUES (1, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (2, 'two');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (1, 'three');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (1, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL VALUES (5, 'one');
---END---
---START---
INSERT INTO UNIQUE_TBL (t) VALUES ('six');
---END---
---START---

SELECT * FROM UNIQUE_TBL;
---END---
---START---

DROP TABLE UNIQUE_TBL;
---END---
---START---

--
-- Deferrable unique constraints
--

CREATE TABLE unique_tbl (i int UNIQUE DEFERRABLE, t text);
---END---
---START---

INSERT INTO unique_tbl VALUES (0, 'one');
---END---
---START---
INSERT INTO unique_tbl VALUES (1, 'two');
---END---
---START---
INSERT INTO unique_tbl VALUES (2, 'tree');
---END---
---START---
INSERT INTO unique_tbl VALUES (3, 'four');
---END---
---START---
INSERT INTO unique_tbl VALUES (4, 'five');
---END---
---START---

BEGIN;
---END---
---START---

-- default is immediate so this should fail right away
UPDATE unique_tbl SET i = 1 WHERE i = 0;
---END---
---START---

ROLLBACK;
---END---
---START---

-- check is done at end of statement, so this should succeed
UPDATE unique_tbl SET i = i+1;
---END---
---START---

SELECT * FROM unique_tbl;
---END---
---START---

-- explicitly defer the constraint
BEGIN;
---END---
---START---

SET CONSTRAINTS unique_tbl_i_key DEFERRED;
---END---
---START---

INSERT INTO unique_tbl VALUES (3, 'three');
---END---
---START---
DELETE FROM unique_tbl WHERE t = 'tree'; -- makes constraint valid again

COMMIT; -- should succeed

SELECT * FROM unique_tbl;
---END---
---START---

-- try adding an initially deferred constraint
ALTER TABLE unique_tbl DROP CONSTRAINT unique_tbl_i_key;
---END---
---START---
ALTER TABLE unique_tbl ADD CONSTRAINT unique_tbl_i_key
	UNIQUE (i) DEFERRABLE INITIALLY DEFERRED;
---END---
---START---

BEGIN;
---END---
---START---

INSERT INTO unique_tbl VALUES (1, 'five');
---END---
---START---
INSERT INTO unique_tbl VALUES (5, 'one');
---END---
---START---
UPDATE unique_tbl SET i = 4 WHERE i = 2;
---END---
---START---
UPDATE unique_tbl SET i = 2 WHERE i = 4 AND t = 'four';
---END---
---START---
DELETE FROM unique_tbl WHERE i = 1 AND t = 'one';
---END---
---START---
DELETE FROM unique_tbl WHERE i = 5 AND t = 'five';
---END---
---START---

COMMIT;
---END---
---START---

SELECT * FROM unique_tbl;
---END---
---START---

-- should fail at commit-time
BEGIN;
---END---
---START---
INSERT INTO unique_tbl VALUES (3, 'Three'); -- should succeed for now
COMMIT; -- should fail

-- make constraint check immediate
BEGIN;
---END---
---START---

SET CONSTRAINTS ALL IMMEDIATE;
---END---
---START---

INSERT INTO unique_tbl VALUES (3, 'Three'); -- should fail

COMMIT;
---END---
---START---

-- forced check when SET CONSTRAINTS is called
BEGIN;
---END---
---START---

SET CONSTRAINTS ALL DEFERRED;
---END---
---START---

INSERT INTO unique_tbl VALUES (3, 'Three'); -- should succeed for now

SET CONSTRAINTS ALL IMMEDIATE; -- should fail

COMMIT;
---END---
---START---

-- test deferrable UNIQUE with a partitioned table
CREATE TABLE parted_uniq_tbl (i int UNIQUE DEFERRABLE) partition by range (i);
---END---
---START---
CREATE TABLE parted_uniq_tbl_1 PARTITION OF parted_uniq_tbl FOR VALUES FROM (0) TO (10);
---END---
---START---
CREATE TABLE parted_uniq_tbl_2 PARTITION OF parted_uniq_tbl FOR VALUES FROM (20) TO (30);
---END---
---START---
SELECT conname, conrelid::regclass FROM pg_constraint
  WHERE conname LIKE 'parted_uniq%' ORDER BY conname;
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO parted_uniq_tbl VALUES (1);
---END---
---START---
SAVEPOINT f;
---END---
---START---
INSERT INTO parted_uniq_tbl VALUES (1);	-- unique violation
ROLLBACK TO f;
---END---
---START---
SET CONSTRAINTS parted_uniq_tbl_i_key DEFERRED;
---END---
---START---
INSERT INTO parted_uniq_tbl VALUES (1);	-- OK now, fail at commit
COMMIT;
---END---
---START---
DROP TABLE parted_uniq_tbl;
---END---
---START---

-- test naming a constraint in a partition when a conflict exists
CREATE TABLE parted_fk_naming (
    id bigint NOT NULL default 1,
    id_abc bigint,
    CONSTRAINT dummy_constr FOREIGN KEY (id_abc)
        REFERENCES parted_fk_naming (id),
    PRIMARY KEY (id)
)
PARTITION BY LIST (id);
---END---
---START---
CREATE TABLE parted_fk_naming_1 (
    id bigint NOT NULL default 1,
    id_abc bigint,
    PRIMARY KEY (id),
    CONSTRAINT dummy_constr CHECK (true)
);
---END---
---START---
ALTER TABLE parted_fk_naming ATTACH PARTITION parted_fk_naming_1 FOR VALUES IN ('1');
---END---
---START---
SELECT conname FROM pg_constraint WHERE conrelid = 'parted_fk_naming_1'::regclass AND contype = 'f';
---END---
---START---
DROP TABLE parted_fk_naming;
---END---
---START---

-- test a HOT update that invalidates the conflicting tuple.
-- the trigger should still fire and catch the violation

BEGIN;
---END---
---START---

INSERT INTO unique_tbl VALUES (3, 'Three'); -- should succeed for now
UPDATE unique_tbl SET t = 'THREE' WHERE i = 3 AND t = 'Three';
---END---
---START---

COMMIT; -- should fail

SELECT * FROM unique_tbl;
---END---
---START---

-- test a HOT update that modifies the newly inserted tuple,
-- but should succeed because we then remove the other conflicting tuple.

BEGIN;
---END---
---START---

INSERT INTO unique_tbl VALUES(3, 'tree'); -- should succeed for now
UPDATE unique_tbl SET t = 'threex' WHERE t = 'tree';
---END---
---START---
DELETE FROM unique_tbl WHERE t = 'three';
---END---
---START---

SELECT * FROM unique_tbl;
---END---
---START---

COMMIT;
---END---
---START---

SELECT * FROM unique_tbl;
---END---
---START---

DROP TABLE unique_tbl;
---END---
---START---

--
-- EXCLUDE constraints
--

CREATE TABLE circles (
  c1 CIRCLE,
  c2 TEXT,
  EXCLUDE USING gist
    (c1 WITH &&, (c2::circle) WITH &&)
    WHERE (circle_center(c1) <> '(0,0)')
);
---END---
---START---

-- these should succeed because they don't match the index predicate
INSERT INTO circles VALUES('<(0,0), 5>', '<(0,0), 5>');
---END---
---START---
INSERT INTO circles VALUES('<(0,0), 5>', '<(0,0), 4>');
---END---
---START---

-- succeed
INSERT INTO circles VALUES('<(10,10), 10>', '<(0,0), 5>');
---END---
---START---
-- fail, overlaps
INSERT INTO circles VALUES('<(20,20), 10>', '<(0,0), 4>');
---END---
---START---
-- succeed, because violation is ignored
INSERT INTO circles VALUES('<(20,20), 10>', '<(0,0), 4>')
  ON CONFLICT ON CONSTRAINT circles_c1_c2_excl DO NOTHING;
---END---
---START---
-- fail, because DO UPDATE variant requires unique index
INSERT INTO circles VALUES('<(20,20), 10>', '<(0,0), 4>')
  ON CONFLICT ON CONSTRAINT circles_c1_c2_excl DO UPDATE SET c2 = EXCLUDED.c2;
---END---
---START---
-- succeed because c1 doesn't overlap
INSERT INTO circles VALUES('<(20,20), 1>', '<(0,0), 5>');
---END---
---START---
-- succeed because c2 doesn't overlap
INSERT INTO circles VALUES('<(20,20), 10>', '<(10,10), 5>');
---END---
---START---

-- should fail on existing data without the WHERE clause
ALTER TABLE circles ADD EXCLUDE USING gist
  (c1 WITH &&, (c2::circle) WITH &&);
---END---
---START---

-- try reindexing an existing constraint
REINDEX INDEX circles_c1_c2_excl;
---END---
---START---

DROP TABLE circles;
---END---
---START---

-- Check deferred exclusion constraint

CREATE TABLE deferred_excl (
  f1 int,
  f2 int,
  CONSTRAINT deferred_excl_con EXCLUDE (f1 WITH =) INITIALLY DEFERRED
);
---END---
---START---

INSERT INTO deferred_excl VALUES(1);
---END---
---START---
INSERT INTO deferred_excl VALUES(2);
---END---
---START---
INSERT INTO deferred_excl VALUES(1); -- fail
INSERT INTO deferred_excl VALUES(1) ON CONFLICT ON CONSTRAINT deferred_excl_con DO NOTHING; -- fail
BEGIN;
---END---
---START---
INSERT INTO deferred_excl VALUES(2); -- no fail here
COMMIT; -- should fail here
BEGIN;
---END---
---START---
INSERT INTO deferred_excl VALUES(3);
---END---
---START---
INSERT INTO deferred_excl VALUES(3); -- no fail here
COMMIT; -- should fail here

-- bug #13148: deferred constraint versus HOT update
BEGIN;
---END---
---START---
INSERT INTO deferred_excl VALUES(2, 1); -- no fail here
DELETE FROM deferred_excl WHERE f1 = 2 AND f2 IS NULL; -- remove old row
UPDATE deferred_excl SET f2 = 2 WHERE f1 = 2;
---END---
---START---
COMMIT; -- should not fail

SELECT * FROM deferred_excl;
---END---
---START---

ALTER TABLE deferred_excl DROP CONSTRAINT deferred_excl_con;
---END---
---START---

-- This should fail, but worth testing because of HOT updates
UPDATE deferred_excl SET f1 = 3;
---END---
---START---

ALTER TABLE deferred_excl ADD EXCLUDE (f1 WITH =);
---END---
---START---

DROP TABLE deferred_excl;
---END---
---START---

-- Comments
-- Setup a low-level role to enforce non-superuser checks.
CREATE ROLE regress_constraint_comments;
---END---
---START---
SET SESSION AUTHORIZATION regress_constraint_comments;
---END---
---START---

CREATE TABLE constraint_comments_tbl (a int CONSTRAINT the_constraint CHECK (a > 0));
---END---
---START---
CREATE DOMAIN constraint_comments_dom AS int CONSTRAINT the_constraint CHECK (value > 0);
---END---
---START---

COMMENT ON CONSTRAINT the_constraint ON constraint_comments_tbl IS 'yes, the comment';
---END---
---START---
COMMENT ON CONSTRAINT the_constraint ON DOMAIN constraint_comments_dom IS 'yes, another comment';
---END---
---START---

-- no such constraint
COMMENT ON CONSTRAINT no_constraint ON constraint_comments_tbl IS 'yes, the comment';
---END---
---START---
COMMENT ON CONSTRAINT no_constraint ON DOMAIN constraint_comments_dom IS 'yes, another comment';
---END---
---START---

-- no such table/domain
COMMENT ON CONSTRAINT the_constraint ON no_comments_tbl IS 'bad comment';
---END---
---START---
COMMENT ON CONSTRAINT the_constraint ON DOMAIN no_comments_dom IS 'another bad comment';
---END---
---START---

COMMENT ON CONSTRAINT the_constraint ON constraint_comments_tbl IS NULL;
---END---
---START---
COMMENT ON CONSTRAINT the_constraint ON DOMAIN constraint_comments_dom IS NULL;
---END---
---START---

-- unauthorized user
RESET SESSION AUTHORIZATION;
---END---
---START---
CREATE ROLE regress_constraint_comments_noaccess;
---END---
---START---
SET SESSION AUTHORIZATION regress_constraint_comments_noaccess;
---END---
---START---
COMMENT ON CONSTRAINT the_constraint ON constraint_comments_tbl IS 'no, the comment';
---END---
---START---
COMMENT ON CONSTRAINT the_constraint ON DOMAIN constraint_comments_dom IS 'no, another comment';
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---

DROP TABLE constraint_comments_tbl;
---END---
---START---
DROP DOMAIN constraint_comments_dom;
---END---
---START---

DROP ROLE regress_constraint_comments;
---END---
---START---
DROP ROLE regress_constraint_comments_noaccess;
---END---
