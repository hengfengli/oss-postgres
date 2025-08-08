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
CREATE TABLE defaultexpr_tbl (gemini_pk serial PRIMARY KEY, i1 integer DEFAULT 100 + ((200 - 199) * 2), i2 integer DEFAULT nextval('default_seq'));
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
CREATE TABLE error_tbl (gemini_pk serial PRIMARY KEY, b1 bool DEFAULT (1 IN (1, 2)));
---END---
---START---
DROP TABLE error_tbl;
---END---
---START---
CREATE TABLE check_tbl (gemini_pk serial PRIMARY KEY, x integer, CONSTRAINT check_con CHECK (x > 3));
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
CREATE TABLE check2_tbl (gemini_pk serial PRIMARY KEY, x integer, y text, z integer, CONSTRAINT sequence_con CHECK (x > 3 AND y <> 'check failed' AND z < 8));
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
-- @hengfeng: the emulator get stuck
-- CREATE TABLE insert_tbl (gemini_pk serial PRIMARY KEY, x integer DEFAULT nextval('insert_seq'), y text DEFAULT '-NULL-', z integer DEFAULT -1 * currval('insert_seq'), CONSTRAINT insert_tbl_con CHECK (x >= 3 AND y <> 'check failed' AND x < 8), CHECK ((x + z) = 0));
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
CREATE TABLE sys_col_check_tbl (gemini_pk serial PRIMARY KEY, city text, state text, is_capital bool, altitude integer, CHECK (NOT(is_capital AND CAST(CAST(tableoid AS regclass) AS text) = 'sys_col_check_tbl')));
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
CREATE TABLE sys_col_check_tbl (gemini_pk serial PRIMARY KEY, city text, state text, is_capital bool, altitude integer, CHECK (NOT(is_capital AND CAST(ctid AS text) = 'sys_col_check_tbl')));
---END---
---START---
CREATE TABLE insert_child (gemini_pk serial PRIMARY KEY, cx integer DEFAULT 42, cy integer CHECK (cy > x)) INHERITS (insert_tbl);
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
CREATE TABLE atacc1 (gemini_pk serial PRIMARY KEY, test integer CHECK (test > 0) NO INHERIT);
---END---
---START---
CREATE TABLE atacc2 (gemini_pk serial PRIMARY KEY, test2 integer) INHERITS (atacc1);
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
CREATE TABLE atacc1 (gemini_pk serial PRIMARY KEY, test integer, test2 integer CHECK (test > 0), CHECK (test2 > 10) NO INHERIT);
---END---
---START---
CREATE TABLE atacc2 (gemini_pk serial PRIMARY KEY) INHERITS (atacc1);
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
DROP TABLE IF EXISTS tmp;

CREATE TABLE tmp (gemini_pk serial PRIMARY KEY, xd integer, yd text, zd integer);
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
CREATE TABLE copy_tbl (gemini_pk serial PRIMARY KEY, x integer, y text, z integer, CONSTRAINT copy_con CHECK (x > 3 AND y <> 'check failed' AND x < 7));
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
CREATE TABLE unique_tbl (gemini_pk serial PRIMARY KEY, i integer UNIQUE, t text);
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
CREATE TABLE unique_tbl (gemini_pk serial PRIMARY KEY, i integer UNIQUE NULLS NOT DISTINCT, t text);
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
-- fail
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
-- fail
INSERT INTO UNIQUE_TBL (t) VALUES ('eight') ON CONFLICT DO NOTHING;
---END---
---START---
-- no-op

SELECT * FROM UNIQUE_TBL;
---END---
---START---
DROP TABLE UNIQUE_TBL;
---END---
---START---
CREATE TABLE unique_tbl (gemini_pk serial PRIMARY KEY, i integer, t text, UNIQUE (i, t));
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
CREATE TABLE unique_tbl (gemini_pk serial PRIMARY KEY, i integer UNIQUE DEFERRABLE, t text);
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
DELETE FROM unique_tbl WHERE t = 'tree';
---END---
---START---
-- makes constraint valid again

COMMIT;
---END---
---START---
-- should succeed

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
INSERT INTO unique_tbl VALUES (3, 'Three');
---END---
---START---
-- should succeed for now
COMMIT;
---END---
---START---
-- should fail

-- make constraint check immediate
BEGIN;
---END---
---START---
SET CONSTRAINTS ALL IMMEDIATE;
---END---
---START---
INSERT INTO unique_tbl VALUES (3, 'Three');
---END---
---START---
-- should fail

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
INSERT INTO unique_tbl VALUES (3, 'Three');
---END---
---START---
-- should succeed for now

SET CONSTRAINTS ALL IMMEDIATE;
---END---
---START---
-- should fail

COMMIT;
---END---
---START---
CREATE TABLE parted_uniq_tbl (gemini_pk serial PRIMARY KEY, i integer UNIQUE DEFERRABLE) PARTITION BY range (i);
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
INSERT INTO parted_uniq_tbl VALUES (1);
---END---
---START---
-- unique violation
ROLLBACK TO f;
---END---
---START---
SET CONSTRAINTS parted_uniq_tbl_i_key DEFERRED;
---END---
---START---
INSERT INTO parted_uniq_tbl VALUES (1);
---END---
---START---
-- OK now, fail at commit
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
INSERT INTO unique_tbl VALUES (3, 'Three');
---END---
---START---
-- should succeed for now
UPDATE unique_tbl SET t = 'THREE' WHERE i = 3 AND t = 'Three';
---END---
---START---
COMMIT;
---END---
---START---
-- should fail

SELECT * FROM unique_tbl;
---END---
---START---
-- test a HOT update that modifies the newly inserted tuple,
-- but should succeed because we then remove the other conflicting tuple.

BEGIN;
---END---
---START---
INSERT INTO unique_tbl VALUES(3, 'tree');
---END---
---START---
-- should succeed for now
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
CREATE TABLE circles (gemini_pk serial PRIMARY KEY, c1 circle, c2 text, EXCLUDE USING gist (c1 WITH OPERATOR(&&), (CAST(c2 AS circle)) WITH OPERATOR(&&)) WHERE (circle_center(c1) <> '(0,0)'));
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
CREATE TABLE deferred_excl (gemini_pk serial PRIMARY KEY, f1 integer, f2 integer, CONSTRAINT deferred_excl_con EXCLUDE USING btree (f1 WITH OPERATOR(=)) DEFERRABLE INITIALLY DEFERRED);
---END---
---START---
INSERT INTO deferred_excl VALUES(1);
---END---
---START---
INSERT INTO deferred_excl VALUES(2);
---END---
---START---
INSERT INTO deferred_excl VALUES(1);
---END---
---START---
-- fail
INSERT INTO deferred_excl VALUES(1) ON CONFLICT ON CONSTRAINT deferred_excl_con DO NOTHING;
---END---
---START---
-- fail
BEGIN;
---END---
---START---
INSERT INTO deferred_excl VALUES(2);
---END---
---START---
-- no fail here
COMMIT;
---END---
---START---
-- should fail here
BEGIN;
---END---
---START---
INSERT INTO deferred_excl VALUES(3);
---END---
---START---
INSERT INTO deferred_excl VALUES(3);
---END---
---START---
-- no fail here
COMMIT;
---END---
---START---
-- should fail here

-- bug #13148: deferred constraint versus HOT update
BEGIN;
---END---
---START---
INSERT INTO deferred_excl VALUES(2, 1);
---END---
---START---
-- no fail here
DELETE FROM deferred_excl WHERE f1 = 2 AND f2 IS NULL;
---END---
---START---
-- remove old row
UPDATE deferred_excl SET f2 = 2 WHERE f1 = 2;
---END---
---START---
COMMIT;
---END---
---START---
-- should not fail

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
CREATE TABLE constraint_comments_tbl (gemini_pk serial PRIMARY KEY, a integer CONSTRAINT the_constraint CHECK (a > 0));
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
