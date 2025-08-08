---START---
--
-- UPDATABLE VIEWS
--

-- avoid bit-exact output here because operations may not be bit-exact.
SET extra_float_digits = 0;
---END---
---START---
-- check that non-updatable views and columns are rejected with useful error
-- messages

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl SELECT i, 'Row ' || i FROM generate_series(-2, 2) g(i);
---END---
---START---
CREATE VIEW ro_view1 AS SELECT DISTINCT a, b FROM base_tbl;
---END---
---START---
-- DISTINCT not supported
CREATE VIEW ro_view2 AS SELECT a, b FROM base_tbl GROUP BY a, b;
---END---
---START---
-- GROUP BY not supported
CREATE VIEW ro_view3 AS SELECT 1 FROM base_tbl HAVING max(a) > 0;
---END---
---START---
-- HAVING not supported
CREATE VIEW ro_view4 AS SELECT count(*) FROM base_tbl;
---END---
---START---
-- Aggregate functions not supported
CREATE VIEW ro_view5 AS SELECT a, rank() OVER() FROM base_tbl;
---END---
---START---
-- Window functions not supported
CREATE VIEW ro_view6 AS SELECT a, b FROM base_tbl UNION SELECT -a, b FROM base_tbl;
---END---
---START---
-- Set ops not supported
CREATE VIEW ro_view7 AS WITH t AS (SELECT a, b FROM base_tbl) SELECT * FROM t;
---END---
---START---
-- WITH not supported
CREATE VIEW ro_view8 AS SELECT a, b FROM base_tbl ORDER BY a OFFSET 1;
---END---
---START---
-- OFFSET not supported
CREATE VIEW ro_view9 AS SELECT a, b FROM base_tbl ORDER BY a LIMIT 1;
---END---
---START---
-- LIMIT not supported
CREATE VIEW ro_view10 AS SELECT 1 AS a;
---END---
---START---
-- No base relations
CREATE VIEW ro_view11 AS SELECT b1.a, b2.b FROM base_tbl b1, base_tbl b2;
---END---
---START---
-- Multiple base relations
CREATE VIEW ro_view12 AS SELECT * FROM generate_series(1, 10) AS g(a);
---END---
---START---
-- SRF in rangetable
CREATE VIEW ro_view13 AS SELECT a, b FROM (SELECT * FROM base_tbl) AS t;
---END---
---START---
-- Subselect in rangetable
CREATE VIEW rw_view14 AS SELECT ctid, a, b FROM base_tbl;
---END---
---START---
-- System columns may be part of an updatable view
CREATE VIEW rw_view15 AS SELECT a, upper(b) FROM base_tbl;
---END---
---START---
-- Expression/function may be part of an updatable view
CREATE VIEW rw_view16 AS SELECT a, b, a AS aa FROM base_tbl;
---END---
---START---
-- Repeated column may be part of an updatable view
CREATE VIEW ro_view17 AS SELECT * FROM ro_view1;
---END---
---START---
-- Base relation not updatable
CREATE VIEW ro_view18 AS SELECT * FROM (VALUES(1)) AS tmp(a);
---END---
---START---
-- VALUES in rangetable
CREATE SEQUENCE uv_seq;
---END---
---START---
CREATE VIEW ro_view19 AS SELECT * FROM uv_seq;
---END---
---START---
-- View based on a sequence
CREATE VIEW ro_view20 AS SELECT a, b, generate_series(1, a) g FROM base_tbl;
---END---
---START---
-- SRF in targetlist not supported

SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE E'r_\\_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE E'r_\\_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE E'r_\\_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
-- Read-only views
DELETE FROM ro_view1;
---END---
---START---
DELETE FROM ro_view2;
---END---
---START---
DELETE FROM ro_view3;
---END---
---START---
DELETE FROM ro_view4;
---END---
---START---
DELETE FROM ro_view5;
---END---
---START---
DELETE FROM ro_view6;
---END---
---START---
UPDATE ro_view7 SET a=a+1;
---END---
---START---
UPDATE ro_view8 SET a=a+1;
---END---
---START---
UPDATE ro_view9 SET a=a+1;
---END---
---START---
UPDATE ro_view10 SET a=a+1;
---END---
---START---
UPDATE ro_view11 SET a=a+1;
---END---
---START---
UPDATE ro_view12 SET a=a+1;
---END---
---START---
INSERT INTO ro_view13 VALUES (3, 'Row 3');
---END---
---START---
-- Partially updatable view
INSERT INTO rw_view14 VALUES (null, 3, 'Row 3');
---END---
---START---
-- should fail
INSERT INTO rw_view14 (a, b) VALUES (3, 'Row 3');
---END---
---START---
-- should be OK
UPDATE rw_view14 SET ctid=null WHERE a=3;
---END---
---START---
-- should fail
UPDATE rw_view14 SET b='ROW 3' WHERE a=3;
---END---
---START---
-- should be OK
SELECT * FROM base_tbl;
---END---
---START---
DELETE FROM rw_view14 WHERE a=3;
---END---
---START---
-- should be OK
-- Partially updatable view
INSERT INTO rw_view15 VALUES (3, 'ROW 3');
---END---
---START---
-- should fail
INSERT INTO rw_view15 (a) VALUES (3);
---END---
---START---
-- should be OK
INSERT INTO rw_view15 (a) VALUES (3) ON CONFLICT DO NOTHING;
---END---
---START---
-- succeeds
SELECT * FROM rw_view15;
---END---
---START---
INSERT INTO rw_view15 (a) VALUES (3) ON CONFLICT (a) DO NOTHING;
---END---
---START---
-- succeeds
SELECT * FROM rw_view15;
---END---
---START---
INSERT INTO rw_view15 (a) VALUES (3) ON CONFLICT (a) DO UPDATE set a = excluded.a;
---END---
---START---
-- succeeds
SELECT * FROM rw_view15;
---END---
---START---
INSERT INTO rw_view15 (a) VALUES (3) ON CONFLICT (a) DO UPDATE set upper = 'blarg';
---END---
---START---
-- fails
SELECT * FROM rw_view15;
---END---
---START---
SELECT * FROM rw_view15;
---END---
---START---
ALTER VIEW rw_view15 ALTER COLUMN upper SET DEFAULT 'NOT SET';
---END---
---START---
INSERT INTO rw_view15 (a) VALUES (4);
---END---
---START---
-- should fail
UPDATE rw_view15 SET upper='ROW 3' WHERE a=3;
---END---
---START---
-- should fail
UPDATE rw_view15 SET upper=DEFAULT WHERE a=3;
---END---
---START---
-- should fail
UPDATE rw_view15 SET a=4 WHERE a=3;
---END---
---START---
-- should be OK
SELECT * FROM base_tbl;
---END---
---START---
DELETE FROM rw_view15 WHERE a=4;
---END---
---START---
-- should be OK
-- Partially updatable view
INSERT INTO rw_view16 VALUES (3, 'Row 3', 3);
---END---
---START---
-- should fail
INSERT INTO rw_view16 (a, b) VALUES (3, 'Row 3');
---END---
---START---
-- should be OK
UPDATE rw_view16 SET a=3, aa=-3 WHERE a=3;
---END---
---START---
-- should fail
UPDATE rw_view16 SET aa=-3 WHERE a=3;
---END---
---START---
-- should be OK
SELECT * FROM base_tbl;
---END---
---START---
DELETE FROM rw_view16 WHERE a=-3;
---END---
---START---
-- should be OK
-- Read-only views
INSERT INTO ro_view17 VALUES (3, 'ROW 3');
---END---
---START---
DELETE FROM ro_view18;
---END---
---START---
UPDATE ro_view19 SET last_value=1000;
---END---
---START---
UPDATE ro_view20 SET b=upper(b);
---END---
---START---
-- A view with a conditional INSTEAD rule but no unconditional INSTEAD rules
-- or INSTEAD OF triggers should be non-updatable and generate useful error
-- messages with appropriate detail
CREATE RULE rw_view16_ins_rule AS ON INSERT TO rw_view16
  WHERE NEW.a > 0 DO INSTEAD INSERT INTO base_tbl VALUES (NEW.a, NEW.b);
---END---
---START---
CREATE RULE rw_view16_upd_rule AS ON UPDATE TO rw_view16
  WHERE OLD.a > 0 DO INSTEAD UPDATE base_tbl SET b=NEW.b WHERE a=OLD.a;
---END---
---START---
CREATE RULE rw_view16_del_rule AS ON DELETE TO rw_view16
  WHERE OLD.a > 0 DO INSTEAD DELETE FROM base_tbl WHERE a=OLD.a;
---END---
---START---
INSERT INTO rw_view16 (a, b) VALUES (3, 'Row 3');
---END---
---START---
-- should fail
UPDATE rw_view16 SET b='ROW 2' WHERE a=2;
---END---
---START---
-- should fail
DELETE FROM rw_view16 WHERE a=2;
---END---
---START---
-- should fail

DROP TABLE base_tbl CASCADE;
---END---
---START---
DROP VIEW ro_view10, ro_view12, ro_view18;
---END---
---START---
DROP SEQUENCE uv_seq CASCADE;
---END---
---START---
-- simple updatable view

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl SELECT i, 'Row ' || i FROM generate_series(-2, 2) g(i);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a>0;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name = 'rw_view1';
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name = 'rw_view1';
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name = 'rw_view1'
 ORDER BY ordinal_position;
---END---
---START---
INSERT INTO rw_view1 VALUES (3, 'Row 3');
---END---
---START---
INSERT INTO rw_view1 (a) VALUES (4);
---END---
---START---
UPDATE rw_view1 SET a=5 WHERE a=4;
---END---
---START---
DELETE FROM rw_view1 WHERE b='Row 2';
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view1 SET a=6 WHERE a=5;
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view1 WHERE a=5;
---END---
---START---
CREATE TABLE base_tbl_hist (gemini_pk serial PRIMARY KEY, ts timestamptz DEFAULT now(), a integer, b text);
---END---
---START---
CREATE RULE base_tbl_log AS ON INSERT TO rw_view1 DO ALSO
  INSERT INTO base_tbl_hist(a,b) VALUES(new.a, new.b);
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name = 'rw_view1';
---END---
---START---
-- Check behavior with DEFAULTs (bug #17633)

INSERT INTO rw_view1 VALUES (9, DEFAULT), (10, DEFAULT);
---END---
---START---
SELECT a, b FROM base_tbl_hist;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
DROP TABLE base_tbl_hist;
---END---
---START---
-- view on top of view

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl SELECT i, 'Row ' || i FROM generate_series(-2, 2) g(i);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT b AS bb, a AS aa FROM base_tbl WHERE a>0;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT aa AS aaa, bb AS bbb FROM rw_view1 WHERE aa<10;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name = 'rw_view2';
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name = 'rw_view2';
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name = 'rw_view2'
 ORDER BY ordinal_position;
---END---
---START---
INSERT INTO rw_view2 VALUES (3, 'Row 3');
---END---
---START---
INSERT INTO rw_view2 (aaa) VALUES (4);
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
UPDATE rw_view2 SET bbb='Row 4' WHERE aaa=4;
---END---
---START---
DELETE FROM rw_view2 WHERE aaa=2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view2 SET aaa=5 WHERE aaa=4;
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view2 WHERE aaa=4;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
-- view on top of view with rules

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl SELECT i, 'Row ' || i FROM generate_series(-2, 2) g(i);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a>0 OFFSET 0;
---END---
---START---
-- not updatable without rules/triggers
CREATE VIEW rw_view2 AS SELECT * FROM rw_view1 WHERE a<10;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
CREATE RULE rw_view1_ins_rule AS ON INSERT TO rw_view1
  DO INSTEAD INSERT INTO base_tbl VALUES (NEW.a, NEW.b) RETURNING *;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
CREATE RULE rw_view1_upd_rule AS ON UPDATE TO rw_view1
  DO INSTEAD UPDATE base_tbl SET b=NEW.b WHERE a=OLD.a RETURNING NEW.*;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
CREATE RULE rw_view1_del_rule AS ON DELETE TO rw_view1
  DO INSTEAD DELETE FROM base_tbl WHERE a=OLD.a RETURNING OLD.*;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
INSERT INTO rw_view2 VALUES (3, 'Row 3') RETURNING *;
---END---
---START---
UPDATE rw_view2 SET b='Row three' WHERE a=3 RETURNING *;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
DELETE FROM rw_view2 WHERE a=3 RETURNING *;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view2 SET a=3 WHERE a=2;
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view2 WHERE a=2;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
-- view on top of view with triggers

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl SELECT i, 'Row ' || i FROM generate_series(-2, 2) g(i);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a>0 OFFSET 0;
---END---
---START---
-- not updatable without rules/triggers
CREATE VIEW rw_view2 AS SELECT * FROM rw_view1 WHERE a<10;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into,
       is_trigger_updatable, is_trigger_deletable,
       is_trigger_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
CREATE FUNCTION rw_view1_trig_fn()
RETURNS trigger AS
$$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO base_tbl VALUES (NEW.a, NEW.b);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE base_tbl SET b=NEW.b WHERE a=OLD.a;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM base_tbl WHERE a=OLD.a;
    RETURN OLD;
  END IF;
END;
$$
LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER rw_view1_ins_trig INSTEAD OF INSERT ON rw_view1
  FOR EACH ROW EXECUTE PROCEDURE rw_view1_trig_fn();
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into,
       is_trigger_updatable, is_trigger_deletable,
       is_trigger_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
CREATE TRIGGER rw_view1_upd_trig INSTEAD OF UPDATE ON rw_view1
  FOR EACH ROW EXECUTE PROCEDURE rw_view1_trig_fn();
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into,
       is_trigger_updatable, is_trigger_deletable,
       is_trigger_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
CREATE TRIGGER rw_view1_del_trig INSTEAD OF DELETE ON rw_view1
  FOR EACH ROW EXECUTE PROCEDURE rw_view1_trig_fn();
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into,
       is_trigger_updatable, is_trigger_deletable,
       is_trigger_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE 'rw_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
INSERT INTO rw_view2 VALUES (3, 'Row 3') RETURNING *;
---END---
---START---
UPDATE rw_view2 SET b='Row three' WHERE a=3 RETURNING *;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
DELETE FROM rw_view2 WHERE a=3 RETURNING *;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view2 SET a=3 WHERE a=2;
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view2 WHERE a=2;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
DROP FUNCTION rw_view1_trig_fn();
---END---
---START---
-- update using whole row from view

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl SELECT i, 'Row ' || i FROM generate_series(-2, 2) g(i);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT b AS bb, a AS aa FROM base_tbl;
---END---
---START---
CREATE FUNCTION rw_view1_aa(x rw_view1)
  RETURNS int AS $$ SELECT x.aa $$ LANGUAGE sql;
---END---
---START---
UPDATE rw_view1 v SET bb='Updated row 2' WHERE rw_view1_aa(v)=2
  RETURNING rw_view1_aa(v), v.bb;
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
EXPLAIN (costs off)
UPDATE rw_view1 v SET bb='Updated row 2' WHERE rw_view1_aa(v)=2
  RETURNING rw_view1_aa(v), v.bb;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
-- permissions checks

CREATE USER regress_view_user1;
---END---
---START---
CREATE USER regress_view_user2;
---END---
---START---
CREATE USER regress_view_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b text, c double precision);
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1', 1.0);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT b AS bb, c AS cc, a AS aa FROM base_tbl;
---END---
---START---
INSERT INTO rw_view1 VALUES ('Row 2', 2.0, 2);
---END---
---START---
GRANT SELECT ON base_tbl TO regress_view_user2;
---END---
---START---
GRANT SELECT ON rw_view1 TO regress_view_user2;
---END---
---START---
GRANT UPDATE (a,c) ON base_tbl TO regress_view_user2;
---END---
---START---
GRANT UPDATE (bb,cc) ON rw_view1 TO regress_view_user2;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT b AS bb, c AS cc, a AS aa FROM base_tbl;
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
-- ok
SELECT * FROM rw_view1;
---END---
---START---
-- ok
SELECT * FROM rw_view2;
---END---
---START---
-- ok

INSERT INTO base_tbl VALUES (3, 'Row 3', 3.0);
---END---
---START---
-- not allowed
INSERT INTO rw_view1 VALUES ('Row 3', 3.0, 3);
---END---
---START---
-- not allowed
INSERT INTO rw_view2 VALUES ('Row 3', 3.0, 3);
---END---
---START---
-- not allowed

UPDATE base_tbl SET a=a, c=c;
---END---
---START---
-- ok
UPDATE base_tbl SET b=b;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET bb=bb, cc=cc;
---END---
---START---
-- ok
UPDATE rw_view1 SET aa=aa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET aa=aa, cc=cc;
---END---
---START---
-- ok
UPDATE rw_view2 SET bb=bb;
---END---
---START---
-- not allowed

DELETE FROM base_tbl;
---END---
---START---
-- not allowed
DELETE FROM rw_view1;
---END---
---START---
-- not allowed
DELETE FROM rw_view2;
---END---
---START---
-- not allowed
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT INSERT, DELETE ON base_tbl TO regress_view_user2;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
INSERT INTO base_tbl VALUES (3, 'Row 3', 3.0);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES ('Row 4', 4.0, 4);
---END---
---START---
-- not allowed
INSERT INTO rw_view2 VALUES ('Row 4', 4.0, 4);
---END---
---START---
-- ok
DELETE FROM base_tbl WHERE a=1;
---END---
---START---
-- ok
DELETE FROM rw_view1 WHERE aa=2;
---END---
---START---
-- not allowed
DELETE FROM rw_view2 WHERE aa=2;
---END---
---START---
-- ok
SELECT * FROM base_tbl;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
REVOKE INSERT, DELETE ON base_tbl FROM regress_view_user2;
---END---
---START---
GRANT INSERT, DELETE ON rw_view1 TO regress_view_user2;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
INSERT INTO base_tbl VALUES (5, 'Row 5', 5.0);
---END---
---START---
-- not allowed
INSERT INTO rw_view1 VALUES ('Row 5', 5.0, 5);
---END---
---START---
-- ok
INSERT INTO rw_view2 VALUES ('Row 6', 6.0, 6);
---END---
---START---
-- not allowed
DELETE FROM base_tbl WHERE a=3;
---END---
---START---
-- not allowed
DELETE FROM rw_view1 WHERE aa=3;
---END---
---START---
-- ok
DELETE FROM rw_view2 WHERE aa=4;
---END---
---START---
-- not allowed
SELECT * FROM base_tbl;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b text, c double precision);
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1', 1.0);
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
-- not allowed
SELECT * FROM rw_view1 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET b = 'foo' WHERE a = 1;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT * FROM rw_view1;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
SELECT * FROM rw_view2 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET b = 'bar' WHERE a = 1;
---END---
---START---
-- not allowed

RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT SELECT ON base_tbl TO regress_view_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
SELECT * FROM rw_view1 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET b = 'foo' WHERE a = 1;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
SELECT * FROM rw_view2 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET b = 'bar' WHERE a = 1;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT SELECT ON rw_view1 TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
SELECT * FROM rw_view2 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET b = 'bar' WHERE a = 1;
---END---
---START---
-- not allowed

RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT UPDATE ON base_tbl TO regress_view_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
SELECT * FROM rw_view1 FOR UPDATE;
---END---
---START---
UPDATE rw_view1 SET b = 'foo' WHERE a = 1;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
SELECT * FROM rw_view2 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET b = 'bar' WHERE a = 1;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT UPDATE ON rw_view1 TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
SELECT * FROM rw_view2 FOR UPDATE;
---END---
---START---
UPDATE rw_view2 SET b = 'bar' WHERE a = 1;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE UPDATE ON base_tbl FROM regress_view_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
SELECT * FROM rw_view1 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET b = 'foo' WHERE a = 1;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
SELECT * FROM rw_view2 FOR UPDATE;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET b = 'bar' WHERE a = 1;
---END---
---START---
-- not allowed

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
-- security invoker view permissions

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b text, c double precision);
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1', 1.0);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT b AS bb, c AS cc, a AS aa FROM base_tbl;
---END---
---START---
ALTER VIEW rw_view1 SET (security_invoker = true);
---END---
---START---
INSERT INTO rw_view1 VALUES ('Row 2', 2.0, 2);
---END---
---START---
GRANT SELECT ON rw_view1 TO regress_view_user2;
---END---
---START---
GRANT UPDATE (bb,cc) ON rw_view1 TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
-- not allowed
SELECT * FROM rw_view1;
---END---
---START---
-- not allowed
INSERT INTO base_tbl VALUES (3, 'Row 3', 3.0);
---END---
---START---
-- not allowed
INSERT INTO rw_view1 VALUES ('Row 3', 3.0, 3);
---END---
---START---
-- not allowed
UPDATE base_tbl SET a=a;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET bb=bb, cc=cc;
---END---
---START---
-- not allowed
DELETE FROM base_tbl;
---END---
---START---
-- not allowed
DELETE FROM rw_view1;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT SELECT ON base_tbl TO regress_view_user2;
---END---
---START---
GRANT UPDATE (a,c) ON base_tbl TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
-- ok
SELECT * FROM rw_view1;
---END---
---START---
-- ok
UPDATE base_tbl SET a=a, c=c;
---END---
---START---
-- ok
UPDATE base_tbl SET b=b;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET cc=cc;
---END---
---START---
-- ok
UPDATE rw_view1 SET aa=aa;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET bb=bb;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT INSERT, DELETE ON base_tbl TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
INSERT INTO base_tbl VALUES (3, 'Row 3', 3.0);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES ('Row 4', 4.0, 4);
---END---
---START---
-- not allowed
DELETE FROM base_tbl WHERE a=1;
---END---
---START---
-- ok
DELETE FROM rw_view1 WHERE aa=2;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
REVOKE INSERT, DELETE ON base_tbl FROM regress_view_user2;
---END---
---START---
GRANT INSERT, DELETE ON rw_view1 TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
INSERT INTO rw_view1 VALUES ('Row 4', 4.0, 4);
---END---
---START---
-- not allowed
DELETE FROM rw_view1 WHERE aa=2;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT INSERT, DELETE ON base_tbl TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
INSERT INTO rw_view1 VALUES ('Row 4', 4.0, 4);
---END---
---START---
-- ok
DELETE FROM rw_view1 WHERE aa=2;
---END---
---START---
-- ok
SELECT * FROM base_tbl;
---END---
---START---
-- ok

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b text, c double precision);
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1', 1.0);
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
CREATE VIEW rw_view1 AS SELECT b AS bb, c AS cc, a AS aa FROM base_tbl;
---END---
---START---
ALTER VIEW rw_view1 SET (security_invoker = true);
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET aa=aa;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT cc AS ccc, aa AS aaa, bb AS bbb FROM rw_view1;
---END---
---START---
GRANT SELECT, UPDATE ON rw_view2 TO regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed

RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT SELECT ON base_tbl TO regress_view_user1;
---END---
---START---
GRANT UPDATE (a, b) ON base_tbl TO regress_view_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
-- ok
UPDATE rw_view1 SET aa=aa, bb=bb;
---END---
---START---
-- ok
UPDATE rw_view1 SET cc=cc;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
GRANT SELECT ON rw_view1 TO regress_view_user2;
---END---
---START---
GRANT UPDATE (bb, cc) ON rw_view1 TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed

RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT SELECT ON base_tbl TO regress_view_user2;
---END---
---START---
GRANT UPDATE (a, c) ON base_tbl TO regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- ok
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- not allowed

RESET SESSION AUTHORIZATION;
---END---
---START---
GRANT SELECT ON base_tbl TO regress_view_user3;
---END---
---START---
GRANT UPDATE (a, c) ON base_tbl TO regress_view_user3;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- ok
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- ok

RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE SELECT, UPDATE ON base_tbl FROM regress_view_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user1;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
-- not allowed
UPDATE rw_view1 SET aa=aa;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- ok
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- ok

SET SESSION AUTHORIZATION regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- ok
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- ok

RESET SESSION AUTHORIZATION;
---END---
---START---
REVOKE SELECT, UPDATE ON base_tbl FROM regress_view_user2;
---END---
---START---
SET SESSION AUTHORIZATION regress_view_user2;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- not allowed

SET SESSION AUTHORIZATION regress_view_user3;
---END---
---START---
SELECT * FROM rw_view2;
---END---
---START---
-- ok
UPDATE rw_view2 SET aaa=aaa;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET bbb=bbb;
---END---
---START---
-- not allowed
UPDATE rw_view2 SET ccc=ccc;
---END---
---START---
-- ok

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
DROP USER regress_view_user1;
---END---
---START---
DROP USER regress_view_user2;
---END---
---START---
DROP USER regress_view_user3;
---END---
---START---
-- column defaults

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified', c serial);
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1');
---END---
---START---
INSERT INTO base_tbl VALUES (2, 'Row 2');
---END---
---START---
INSERT INTO base_tbl VALUES (3);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT a AS aa, b AS bb FROM base_tbl;
---END---
---START---
ALTER VIEW rw_view1 ALTER COLUMN bb SET DEFAULT 'View default';
---END---
---START---
INSERT INTO rw_view1 VALUES (4, 'Row 4');
---END---
---START---
INSERT INTO rw_view1 (aa) VALUES (5);
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
-- Table having triggers

CREATE TABLE base_tbl (a int PRIMARY KEY, b text DEFAULT 'Unspecified');
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1');
---END---
---START---
INSERT INTO base_tbl VALUES (2, 'Row 2');
---END---
---START---
CREATE FUNCTION rw_view1_trig_fn()
RETURNS trigger AS
$$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE base_tbl SET b=NEW.b WHERE a=1;
    RETURN NULL;
  END IF;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER rw_view1_ins_trig AFTER INSERT ON base_tbl
  FOR EACH ROW EXECUTE PROCEDURE rw_view1_trig_fn();
---END---
---START---
CREATE VIEW rw_view1 AS SELECT a AS aa, b AS bb FROM base_tbl;
---END---
---START---
INSERT INTO rw_view1 VALUES (3, 'Row 3');
---END---
---START---
select * from base_tbl;
---END---
---START---
DROP VIEW rw_view1;
---END---
---START---
DROP TRIGGER rw_view1_ins_trig on base_tbl;
---END---
---START---
DROP FUNCTION rw_view1_trig_fn();
---END---
---START---
DROP TABLE base_tbl;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
INSERT INTO base_tbl VALUES (1,2), (4,5), (3,-3);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl ORDER BY a+b;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
INSERT INTO rw_view1 VALUES (7,-8);
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
EXPLAIN (verbose, costs off) UPDATE rw_view1 SET b = b + 1 RETURNING *;
---END---
---START---
UPDATE rw_view1 SET b = b + 1 RETURNING *;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, arr integer[]);
---END---
---START---
INSERT INTO base_tbl VALUES (1,ARRAY[2]), (3,ARRAY[4]);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl;
---END---
---START---
UPDATE rw_view1 SET arr[1] = 42, arr[2] = 77 WHERE a = 3;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a double precision);
---END---
---START---
INSERT INTO base_tbl SELECT i/10.0 FROM generate_series(1,10) g(i);
---END---
---START---
CREATE VIEW rw_view1 AS
  SELECT ctid, sin(a) s, a, cos(a) c
  FROM base_tbl
  WHERE a != 0
  ORDER BY abs(a);
---END---
---START---
INSERT INTO rw_view1 VALUES (null, null, 1.1, null);
---END---
---START---
-- should fail
INSERT INTO rw_view1 (s, c, a) VALUES (null, null, 1.1);
---END---
---START---
-- should fail
INSERT INTO rw_view1 (a) VALUES (1.1) RETURNING a, s, c;
---END---
---START---
-- OK
UPDATE rw_view1 SET s = s WHERE a = 1.1;
---END---
---START---
-- should fail
UPDATE rw_view1 SET a = 1.05 WHERE a = 1.1 RETURNING s;
---END---
---START---
-- OK
DELETE FROM rw_view1 WHERE a = 1.05;
---END---
---START---
-- OK

CREATE VIEW rw_view2 AS
  SELECT s, c, s/c t, a base_a, ctid
  FROM rw_view1;
---END---
---START---
INSERT INTO rw_view2 VALUES (null, null, null, 1.1, null);
---END---
---START---
-- should fail
INSERT INTO rw_view2(s, c, base_a) VALUES (null, null, 1.1);
---END---
---START---
-- should fail
INSERT INTO rw_view2(base_a) VALUES (1.1) RETURNING t;
---END---
---START---
-- OK
UPDATE rw_view2 SET s = s WHERE base_a = 1.1;
---END---
---START---
-- should fail
UPDATE rw_view2 SET t = t WHERE base_a = 1.1;
---END---
---START---
-- should fail
UPDATE rw_view2 SET base_a = 1.05 WHERE base_a = 1.1;
---END---
---START---
-- OK
DELETE FROM rw_view2 WHERE base_a = 1.05 RETURNING base_a, s, c, t;
---END---
---START---
-- OK

CREATE VIEW rw_view3 AS
  SELECT s, c, s/c t, ctid
  FROM rw_view1;
---END---
---START---
INSERT INTO rw_view3 VALUES (null, null, null, null);
---END---
---START---
-- should fail
INSERT INTO rw_view3(s) VALUES (null);
---END---
---START---
-- should fail
UPDATE rw_view3 SET s = s;
---END---
---START---
-- should fail
DELETE FROM rw_view3 WHERE s = sin(0.1);
---END---
---START---
-- should be OK
SELECT * FROM base_tbl ORDER BY a;
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name LIKE E'r_\\_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name LIKE E'r_\\_view%'
 ORDER BY table_name;
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name LIKE E'r_\\_view%'
 ORDER BY table_name, ordinal_position;
---END---
---START---
SELECT events & 4 != 0 AS upd,
       events & 8 != 0 AS ins,
       events & 16 != 0 AS del
  FROM pg_catalog.pg_relation_is_updatable('rw_view3'::regclass, false) t(events);
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, id integer, idplus1 integer GENERATED ALWAYS AS (id + 1) STORED);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl;
---END---
---START---
INSERT INTO base_tbl (id) VALUES (1);
---END---
---START---
INSERT INTO rw_view1 (id) VALUES (2);
---END---
---START---
INSERT INTO base_tbl (id, idplus1) VALUES (3, DEFAULT);
---END---
---START---
INSERT INTO rw_view1 (id, idplus1) VALUES (4, DEFAULT);
---END---
---START---
INSERT INTO base_tbl (id, idplus1) VALUES (5, 6);
---END---
---START---
-- error
INSERT INTO rw_view1 (id, idplus1) VALUES (6, 7);
---END---
---START---
-- error

SELECT * FROM base_tbl;
---END---
---START---
UPDATE base_tbl SET id = 2000 WHERE id = 2;
---END---
---START---
UPDATE rw_view1 SET id = 3000 WHERE id = 3;
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl_parent (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE TABLE base_tbl_child (gemini_pk serial PRIMARY KEY, CHECK (a > 0)) INHERITS (base_tbl_parent);
---END---
---START---
INSERT INTO base_tbl_parent SELECT * FROM generate_series(-8, -1);
---END---
---START---
INSERT INTO base_tbl_child SELECT * FROM generate_series(1, 8);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl_parent;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT * FROM ONLY base_tbl_parent;
---END---
---START---
SELECT * FROM rw_view1 ORDER BY a;
---END---
---START---
SELECT * FROM ONLY rw_view1 ORDER BY a;
---END---
---START---
SELECT * FROM rw_view2 ORDER BY a;
---END---
---START---
INSERT INTO rw_view1 VALUES (-100), (100);
---END---
---START---
INSERT INTO rw_view2 VALUES (-200), (200);
---END---
---START---
UPDATE rw_view1 SET a = a*10 WHERE a IN (-1, 1);
---END---
---START---
-- Should produce -10 and 10
UPDATE ONLY rw_view1 SET a = a*10 WHERE a IN (-2, 2);
---END---
---START---
-- Should produce -20 and 20
UPDATE rw_view2 SET a = a*10 WHERE a IN (-3, 3);
---END---
---START---
-- Should produce -30 only
UPDATE ONLY rw_view2 SET a = a*10 WHERE a IN (-4, 4);
---END---
---START---
-- Should produce -40 only

DELETE FROM rw_view1 WHERE a IN (-5, 5);
---END---
---START---
-- Should delete -5 and 5
DELETE FROM ONLY rw_view1 WHERE a IN (-6, 6);
---END---
---START---
-- Should delete -6 and 6
DELETE FROM rw_view2 WHERE a IN (-7, 7);
---END---
---START---
-- Should delete -7 only
DELETE FROM ONLY rw_view2 WHERE a IN (-8, 8);
---END---
---START---
-- Should delete -8 only

SELECT * FROM ONLY base_tbl_parent ORDER BY a;
---END---
---START---
SELECT * FROM base_tbl_child ORDER BY a;
---END---
---START---
CREATE TABLE other_tbl_parent (gemini_pk serial PRIMARY KEY, id integer);
---END---
---START---
CREATE TABLE other_tbl_child (gemini_pk serial PRIMARY KEY) INHERITS (other_tbl_parent);
---END---
---START---
INSERT INTO other_tbl_parent VALUES (7),(200);
---END---
---START---
INSERT INTO other_tbl_child VALUES (8),(100);
---END---
---START---
EXPLAIN (costs off)
UPDATE rw_view1 SET a = a + 1000 FROM other_tbl_parent WHERE a = id;
---END---
---START---
UPDATE rw_view1 SET a = a + 1000 FROM other_tbl_parent WHERE a = id;
---END---
---START---
SELECT * FROM ONLY base_tbl_parent ORDER BY a;
---END---
---START---
SELECT * FROM base_tbl_child ORDER BY a;
---END---
---START---
DROP TABLE base_tbl_parent, base_tbl_child CASCADE;
---END---
---START---
DROP TABLE other_tbl_parent CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b integer DEFAULT 10);
---END---
---START---
INSERT INTO base_tbl VALUES (1,2), (2,3), (1,-1);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a < b
  WITH LOCAL CHECK OPTION;
---END---
---START---
\d+ rw_view1
SELECT * FROM information_schema.views WHERE table_name = 'rw_view1';
---END---
---START---
INSERT INTO rw_view1 VALUES(3,4);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES(4,3);
---END---
---START---
-- should fail
INSERT INTO rw_view1 VALUES(5,null);
---END---
---START---
-- should fail
UPDATE rw_view1 SET b = 5 WHERE a = 3;
---END---
---START---
-- ok
UPDATE rw_view1 SET b = -5 WHERE a = 3;
---END---
---START---
-- should fail
INSERT INTO rw_view1(a) VALUES (9);
---END---
---START---
-- ok
INSERT INTO rw_view1(a) VALUES (10);
---END---
---START---
-- should fail
SELECT * FROM base_tbl;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a > 0;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT * FROM rw_view1 WHERE a < 10
  WITH CHECK OPTION;
---END---
---START---
-- implicitly cascaded
\d+ rw_view2
SELECT * FROM information_schema.views WHERE table_name = 'rw_view2';
---END---
---START---
INSERT INTO rw_view2 VALUES (-5);
---END---
---START---
-- should fail
INSERT INTO rw_view2 VALUES (5);
---END---
---START---
-- ok
INSERT INTO rw_view2 VALUES (15);
---END---
---START---
-- should fail
SELECT * FROM base_tbl;
---END---
---START---
UPDATE rw_view2 SET a = a - 10;
---END---
---START---
-- should fail
UPDATE rw_view2 SET a = a + 10;
---END---
---START---
-- should fail

CREATE OR REPLACE VIEW rw_view2 AS SELECT * FROM rw_view1 WHERE a < 10
  WITH LOCAL CHECK OPTION;
---END---
---START---
\d+ rw_view2
SELECT * FROM information_schema.views WHERE table_name = 'rw_view2';
---END---
---START---
INSERT INTO rw_view2 VALUES (-10);
---END---
---START---
-- ok, but not in view
INSERT INTO rw_view2 VALUES (20);
---END---
---START---
-- should fail
SELECT * FROM base_tbl;
---END---
---START---
ALTER VIEW rw_view1 SET (check_option=here);
---END---
---START---
-- invalid
ALTER VIEW rw_view1 SET (check_option=local);
---END---
---START---
INSERT INTO rw_view2 VALUES (-20);
---END---
---START---
-- should fail
INSERT INTO rw_view2 VALUES (30);
---END---
---START---
-- should fail

ALTER VIEW rw_view2 RESET (check_option);
---END---
---START---
\d+ rw_view2
SELECT * FROM information_schema.views WHERE table_name = 'rw_view2';
---END---
---START---
INSERT INTO rw_view2 VALUES (30);
---END---
---START---
-- ok, but not in view
SELECT * FROM base_tbl;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WITH CHECK OPTION;
---END---
---START---
CREATE VIEW rw_view2 AS SELECT * FROM rw_view1 WHERE a > 0;
---END---
---START---
CREATE VIEW rw_view3 AS SELECT * FROM rw_view2 WITH CHECK OPTION;
---END---
---START---
SELECT * FROM information_schema.views WHERE table_name LIKE E'rw\\_view_' ORDER BY table_name;
---END---
---START---
INSERT INTO rw_view1 VALUES (-1);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES (1);
---END---
---START---
-- ok
INSERT INTO rw_view2 VALUES (-2);
---END---
---START---
-- ok, but not in view
INSERT INTO rw_view2 VALUES (2);
---END---
---START---
-- ok
INSERT INTO rw_view3 VALUES (-3);
---END---
---START---
-- should fail
INSERT INTO rw_view3 VALUES (3);
---END---
---START---
-- ok

DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b integer[]);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a = ANY (b)
  WITH CHECK OPTION;
---END---
---START---
INSERT INTO rw_view1 VALUES (1, ARRAY[1,2,3]);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES (10, ARRAY[4,5]);
---END---
---START---
-- should fail

UPDATE rw_view1 SET b[2] = -b[2] WHERE a = 1;
---END---
---START---
-- ok
UPDATE rw_view1 SET b[1] = -b[1] WHERE a = 1;
---END---
---START---
-- should fail

PREPARE ins(int, int[]) AS INSERT INTO rw_view1 VALUES($1, $2);
---END---
---START---
EXECUTE ins(2, ARRAY[1,2,3]);
---END---
---START---
-- ok
EXECUTE ins(10, ARRAY[4,5]);
---END---
---START---
-- should fail
DEALLOCATE PREPARE ins;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE TABLE ref_tbl (a int PRIMARY KEY);
---END---
---START---
INSERT INTO ref_tbl SELECT * FROM generate_series(1,10);
---END---
---START---
CREATE VIEW rw_view1 AS
  SELECT * FROM base_tbl b
  WHERE EXISTS(SELECT 1 FROM ref_tbl r WHERE r.a = b.a)
  WITH CHECK OPTION;
---END---
---START---
INSERT INTO rw_view1 VALUES (5);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES (15);
---END---
---START---
-- should fail

UPDATE rw_view1 SET a = a + 5;
---END---
---START---
-- ok
UPDATE rw_view1 SET a = a + 5;
---END---
---START---
-- should fail

EXPLAIN (costs off) INSERT INTO rw_view1 VALUES (5);
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view1 SET a = a + 5;
---END---
---START---
DROP TABLE base_tbl, ref_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
CREATE FUNCTION base_tbl_trig_fn()
RETURNS trigger AS
$$
BEGIN
  NEW.b := 10;
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER base_tbl_trig BEFORE INSERT OR UPDATE ON base_tbl
  FOR EACH ROW EXECUTE PROCEDURE base_tbl_trig_fn();
---END---
---START---
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl WHERE a < b WITH CHECK OPTION;
---END---
---START---
INSERT INTO rw_view1 VALUES (5,0);
---END---
---START---
-- ok
INSERT INTO rw_view1 VALUES (15, 20);
---END---
---START---
-- should fail
UPDATE rw_view1 SET a = 20, b = 30;
---END---
---START---
-- should fail

DROP TABLE base_tbl CASCADE;
---END---
---START---
DROP FUNCTION base_tbl_trig_fn();
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT a FROM base_tbl WHERE a < b;
---END---
---START---
CREATE FUNCTION rw_view1_trig_fn()
RETURNS trigger AS
$$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO base_tbl VALUES (NEW.a, 10);
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE base_tbl SET a=NEW.a WHERE a=OLD.a;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM base_tbl WHERE a=OLD.a;
    RETURN OLD;
  END IF;
END;
$$
LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER rw_view1_trig
  INSTEAD OF INSERT OR UPDATE OR DELETE ON rw_view1
  FOR EACH ROW EXECUTE PROCEDURE rw_view1_trig_fn();
---END---
---START---
CREATE VIEW rw_view2 AS
  SELECT * FROM rw_view1 WHERE a > 0 WITH LOCAL CHECK OPTION;
---END---
---START---
INSERT INTO rw_view2 VALUES (-5);
---END---
---START---
-- should fail
INSERT INTO rw_view2 VALUES (5);
---END---
---START---
-- ok
INSERT INTO rw_view2 VALUES (50);
---END---
---START---
-- ok, but not in view
UPDATE rw_view2 SET a = a - 10;
---END---
---START---
-- should fail
SELECT * FROM base_tbl;
---END---
---START---
-- Check option won't cascade down to base view with INSTEAD OF triggers

ALTER VIEW rw_view2 SET (check_option=cascaded);
---END---
---START---
INSERT INTO rw_view2 VALUES (100);
---END---
---START---
-- ok, but not in view (doesn't fail rw_view1's check)
UPDATE rw_view2 SET a = 200 WHERE a = 5;
---END---
---START---
-- ok, but not in view (doesn't fail rw_view1's check)
SELECT * FROM base_tbl;
---END---
---START---
-- Neither local nor cascaded check options work with INSTEAD rules

DROP TRIGGER rw_view1_trig ON rw_view1;
---END---
---START---
CREATE RULE rw_view1_ins_rule AS ON INSERT TO rw_view1
  DO INSTEAD INSERT INTO base_tbl VALUES (NEW.a, 10);
---END---
---START---
CREATE RULE rw_view1_upd_rule AS ON UPDATE TO rw_view1
  DO INSTEAD UPDATE base_tbl SET a=NEW.a WHERE a=OLD.a;
---END---
---START---
INSERT INTO rw_view2 VALUES (-10);
---END---
---START---
-- ok, but not in view (doesn't fail rw_view2's check)
INSERT INTO rw_view2 VALUES (5);
---END---
---START---
-- ok
INSERT INTO rw_view2 VALUES (20);
---END---
---START---
-- ok, but not in view (doesn't fail rw_view1's check)
UPDATE rw_view2 SET a = 30 WHERE a = 5;
---END---
---START---
-- ok, but not in view (doesn't fail rw_view1's check)
INSERT INTO rw_view2 VALUES (5);
---END---
---START---
-- ok
UPDATE rw_view2 SET a = -5 WHERE a = 5;
---END---
---START---
-- ok, but not in view (doesn't fail rw_view2's check)
SELECT * FROM base_tbl;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
DROP FUNCTION rw_view1_trig_fn();
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE VIEW rw_view1 AS SELECT a,10 AS b FROM base_tbl;
---END---
---START---
CREATE RULE rw_view1_ins_rule AS ON INSERT TO rw_view1
  DO INSTEAD INSERT INTO base_tbl VALUES (NEW.a);
---END---
---START---
CREATE VIEW rw_view2 AS
  SELECT * FROM rw_view1 WHERE a > b WITH LOCAL CHECK OPTION;
---END---
---START---
INSERT INTO rw_view2 VALUES (2,3);
---END---
---START---
-- ok, but not in view (doesn't fail rw_view2's check)
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, person text, visibility text);
---END---
---START---
INSERT INTO base_tbl VALUES ('Tom', 'public'),
                            ('Dick', 'private'),
                            ('Harry', 'public');
---END---
---START---
CREATE VIEW rw_view1 AS
  SELECT person FROM base_tbl WHERE visibility = 'public';
---END---
---START---
CREATE FUNCTION snoop(anyelement)
RETURNS boolean AS
$$
BEGIN
  RAISE NOTICE 'snooped value: %', $1;
  RETURN true;
END;
$$
LANGUAGE plpgsql COST 0.000001;
---END---
---START---
CREATE OR REPLACE FUNCTION leakproof(anyelement)
RETURNS boolean AS
$$
BEGIN
  RETURN true;
END;
$$
LANGUAGE plpgsql STRICT IMMUTABLE LEAKPROOF;
---END---
---START---
SELECT * FROM rw_view1 WHERE snoop(person);
---END---
---START---
UPDATE rw_view1 SET person=person WHERE snoop(person);
---END---
---START---
DELETE FROM rw_view1 WHERE NOT snoop(person);
---END---
---START---
ALTER VIEW rw_view1 SET (security_barrier = true);
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name = 'rw_view1';
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name = 'rw_view1';
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name = 'rw_view1'
 ORDER BY ordinal_position;
---END---
---START---
SELECT * FROM rw_view1 WHERE snoop(person);
---END---
---START---
UPDATE rw_view1 SET person=person WHERE snoop(person);
---END---
---START---
DELETE FROM rw_view1 WHERE NOT snoop(person);
---END---
---START---
EXPLAIN (costs off) SELECT * FROM rw_view1 WHERE snoop(person);
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view1 SET person=person WHERE snoop(person);
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view1 WHERE NOT snoop(person);
---END---
---START---
-- security barrier view on top of security barrier view

CREATE VIEW rw_view2 WITH (security_barrier = true) AS
  SELECT * FROM rw_view1 WHERE snoop(person);
---END---
---START---
SELECT table_name, is_insertable_into
  FROM information_schema.tables
 WHERE table_name = 'rw_view2';
---END---
---START---
SELECT table_name, is_updatable, is_insertable_into
  FROM information_schema.views
 WHERE table_name = 'rw_view2';
---END---
---START---
SELECT table_name, column_name, is_updatable
  FROM information_schema.columns
 WHERE table_name = 'rw_view2'
 ORDER BY ordinal_position;
---END---
---START---
SELECT * FROM rw_view2 WHERE snoop(person);
---END---
---START---
UPDATE rw_view2 SET person=person WHERE snoop(person);
---END---
---START---
DELETE FROM rw_view2 WHERE NOT snoop(person);
---END---
---START---
EXPLAIN (costs off) SELECT * FROM rw_view2 WHERE snoop(person);
---END---
---START---
EXPLAIN (costs off) UPDATE rw_view2 SET person=person WHERE snoop(person);
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view2 WHERE NOT snoop(person);
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
-- security barrier view on top of table with rules

CREATE TABLE base_tbl(id int PRIMARY KEY, data text, deleted boolean);
---END---
---START---
INSERT INTO base_tbl VALUES (1, 'Row 1', false), (2, 'Row 2', true);
---END---
---START---
CREATE RULE base_tbl_ins_rule AS ON INSERT TO base_tbl
  WHERE EXISTS (SELECT 1 FROM base_tbl t WHERE t.id = new.id)
  DO INSTEAD
    UPDATE base_tbl SET data = new.data, deleted = false WHERE id = new.id;
---END---
---START---
CREATE RULE base_tbl_del_rule AS ON DELETE TO base_tbl
  DO INSTEAD
    UPDATE base_tbl SET deleted = true WHERE id = old.id;
---END---
---START---
CREATE VIEW rw_view1 WITH (security_barrier=true) AS
  SELECT id, data FROM base_tbl WHERE NOT deleted;
---END---
---START---
SELECT * FROM rw_view1;
---END---
---START---
EXPLAIN (costs off) DELETE FROM rw_view1 WHERE id = 1 AND snoop(data);
---END---
---START---
DELETE FROM rw_view1 WHERE id = 1 AND snoop(data);
---END---
---START---
EXPLAIN (costs off) INSERT INTO rw_view1 VALUES (2, 'New row 2');
---END---
---START---
INSERT INTO rw_view1 VALUES (2, 'New row 2');
---END---
---START---
SELECT * FROM base_tbl;
---END---
---START---
DROP TABLE base_tbl CASCADE;
---END---
---START---
CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, a integer, b double precision, c text);
---END---
---START---
CREATE INDEX t1_a_idx ON t1(a);
---END---
---START---
INSERT INTO t1
SELECT i,i,'t1' FROM generate_series(1,10) g(i);
---END---
---START---
ANALYZE t1;
---END---
---START---
CREATE TABLE t11 (gemini_pk serial PRIMARY KEY, d text) INHERITS (t1);
---END---
---START---
CREATE INDEX t11_a_idx ON t11(a);
---END---
---START---
INSERT INTO t11
SELECT i,i,'t11','t11d' FROM generate_series(1,10) g(i);
---END---
---START---
ANALYZE t11;
---END---
---START---
CREATE TABLE t12 (gemini_pk serial PRIMARY KEY, e integer[]) INHERITS (t1);
---END---
---START---
CREATE INDEX t12_a_idx ON t12(a);
---END---
---START---
INSERT INTO t12
SELECT i,i,'t12','{1,2}'::int[] FROM generate_series(1,10) g(i);
---END---
---START---
ANALYZE t12;
---END---
---START---
CREATE TABLE t111 (gemini_pk serial PRIMARY KEY) INHERITS (t11, t12);
---END---
---START---
CREATE INDEX t111_a_idx ON t111(a);
---END---
---START---
INSERT INTO t111
SELECT i,i,'t111','t111d','{1,1,1}'::int[] FROM generate_series(1,10) g(i);
---END---
---START---
ANALYZE t111;
---END---
---START---
CREATE VIEW v1 WITH (security_barrier=true) AS
SELECT *, (SELECT d FROM t11 WHERE t11.a = t1.a LIMIT 1) AS d
FROM t1
WHERE a > 5 AND EXISTS(SELECT 1 FROM t12 WHERE t12.a = t1.a);
---END---
---START---
SELECT * FROM v1 WHERE a=3;
---END---
---START---
-- should not see anything
SELECT * FROM v1 WHERE a=8;
---END---
---START---
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE v1 SET a=100 WHERE snoop(a) AND leakproof(a) AND a < 7 AND a != 6;
---END---
---START---
UPDATE v1 SET a=100 WHERE snoop(a) AND leakproof(a) AND a < 7 AND a != 6;
---END---
---START---
SELECT * FROM v1 WHERE a=100;
---END---
---START---
-- Nothing should have been changed to 100
SELECT * FROM t1 WHERE a=100;
---END---
---START---
-- Nothing should have been changed to 100

EXPLAIN (VERBOSE, COSTS OFF)
UPDATE v1 SET a=a+1 WHERE snoop(a) AND leakproof(a) AND a = 8;
---END---
---START---
UPDATE v1 SET a=a+1 WHERE snoop(a) AND leakproof(a) AND a = 8;
---END---
---START---
SELECT * FROM v1 WHERE b=8;
---END---
---START---
DELETE FROM v1 WHERE snoop(a) AND leakproof(a);
---END---
---START---
-- should not delete everything, just where a>5

TABLE t1;
---END---
---START---
-- verify all a<=5 are intact

DROP TABLE t1, t11, t12, t111 CASCADE;
---END---
---START---
DROP FUNCTION snoop(anyelement);
---END---
---START---
DROP FUNCTION leakproof(anyelement);
---END---
---START---
CREATE TABLE tx1 (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE TABLE tx2 (gemini_pk serial PRIMARY KEY, b integer);
---END---
---START---
CREATE TABLE tx3 (gemini_pk serial PRIMARY KEY, c integer);
---END---
---START---
CREATE VIEW vx1 AS SELECT a FROM tx1 WHERE EXISTS(SELECT 1 FROM tx2 JOIN tx3 ON b=c);
---END---
---START---
INSERT INTO vx1 values (1);
---END---
---START---
SELECT * FROM tx1;
---END---
---START---
SELECT * FROM vx1;
---END---
---START---
DROP VIEW vx1;
---END---
---START---
DROP TABLE tx1;
---END---
---START---
DROP TABLE tx2;
---END---
---START---
DROP TABLE tx3;
---END---
---START---
CREATE TABLE tx1 (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE TABLE tx2 (gemini_pk serial PRIMARY KEY, b integer);
---END---
---START---
CREATE TABLE tx3 (gemini_pk serial PRIMARY KEY, c integer);
---END---
---START---
CREATE VIEW vx1 AS SELECT a FROM tx1 WHERE EXISTS(SELECT 1 FROM tx2 JOIN tx3 ON b=c);
---END---
---START---
INSERT INTO vx1 VALUES (1);
---END---
---START---
INSERT INTO vx1 VALUES (1);
---END---
---START---
SELECT * FROM tx1;
---END---
---START---
SELECT * FROM vx1;
---END---
---START---
DROP VIEW vx1;
---END---
---START---
DROP TABLE tx1;
---END---
---START---
DROP TABLE tx2;
---END---
---START---
DROP TABLE tx3;
---END---
---START---
CREATE TABLE tx1 (gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
CREATE TABLE tx2 (gemini_pk serial PRIMARY KEY, b integer, c integer);
---END---
---START---
CREATE TABLE tx3 (gemini_pk serial PRIMARY KEY, c integer, d integer);
---END---
---START---
ALTER TABLE tx1 DROP COLUMN b;
---END---
---START---
ALTER TABLE tx2 DROP COLUMN c;
---END---
---START---
ALTER TABLE tx3 DROP COLUMN d;
---END---
---START---
CREATE VIEW vx1 AS SELECT a FROM tx1 WHERE EXISTS(SELECT 1 FROM tx2 JOIN tx3 ON b=c);
---END---
---START---
INSERT INTO vx1 VALUES (1);
---END---
---START---
INSERT INTO vx1 VALUES (1);
---END---
---START---
SELECT * FROM tx1;
---END---
---START---
SELECT * FROM vx1;
---END---
---START---
DROP VIEW vx1;
---END---
---START---
DROP TABLE tx1;
---END---
---START---
DROP TABLE tx2;
---END---
---START---
DROP TABLE tx3;
---END---
---START---
CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, a integer, b text, c integer);
---END---
---START---
INSERT INTO t1 VALUES (1, 'one', 10);
---END---
---START---
CREATE TABLE t2 (gemini_pk serial PRIMARY KEY, cc integer);
---END---
---START---
INSERT INTO t2 VALUES (10), (20);
---END---
---START---
CREATE VIEW v1 WITH (security_barrier = true) AS
  SELECT * FROM t1 WHERE (a > 0)
  WITH CHECK OPTION;
---END---
---START---
CREATE VIEW v2 WITH (security_barrier = true) AS
  SELECT * FROM v1 WHERE EXISTS (SELECT 1 FROM t2 WHERE t2.cc = v1.c)
  WITH CHECK OPTION;
---END---
---START---
INSERT INTO v2 VALUES (2, 'two', 20);
---END---
---START---
-- ok
INSERT INTO v2 VALUES (-2, 'minus two', 20);
---END---
---START---
-- not allowed
INSERT INTO v2 VALUES (3, 'three', 30);
---END---
---START---
-- not allowed

UPDATE v2 SET b = 'ONE' WHERE a = 1;
---END---
---START---
-- ok
UPDATE v2 SET a = -1 WHERE a = 1;
---END---
---START---
-- not allowed
UPDATE v2 SET c = 30 WHERE a = 1;
---END---
---START---
-- not allowed

DELETE FROM v2 WHERE a = 2;
---END---
---START---
-- ok
SELECT * FROM v2;
---END---
---START---
DROP VIEW v2;
---END---
---START---
DROP VIEW v1;
---END---
---START---
DROP TABLE t2;
---END---
---START---
DROP TABLE t1;
---END---
---START---
CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
CREATE VIEW v1 WITH (security_barrier = true) AS
  SELECT * FROM t1;
---END---
---START---
CREATE RULE v1_upd_rule AS ON UPDATE TO v1 DO INSTEAD
  UPDATE t1 SET a = NEW.a WHERE a = OLD.a;
---END---
---START---
CREATE VIEW v2 WITH (security_barrier = true) AS
  SELECT * FROM v1 WHERE EXISTS (SELECT 1);
---END---
---START---
EXPLAIN (COSTS OFF) UPDATE v2 SET a = 1;
---END---
---START---
DROP VIEW v2;
---END---
---START---
DROP VIEW v1;
---END---
---START---
DROP TABLE t1;
---END---
---START---
CREATE TABLE t1 (gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
CREATE VIEW v1 AS SELECT null::int AS a;
---END---
---START---
CREATE OR REPLACE VIEW v1 AS SELECT * FROM t1 WHERE a > 0 WITH CHECK OPTION;
---END---
---START---
INSERT INTO v1 VALUES (1, 'ok');
---END---
---START---
-- ok
INSERT INTO v1 VALUES (-1, 'invalid');
---END---
---START---
-- should fail

DROP VIEW v1;
---END---
---START---
DROP TABLE t1;
---END---
---START---
CREATE TABLE uv_pt (gemini_pk serial PRIMARY KEY, a integer, b integer, v varchar) PARTITION BY range (a, b);
---END---
---START---
CREATE TABLE uv_pt1 (gemini_pk serial PRIMARY KEY, b integer NOT NULL, v varchar, a integer NOT NULL) PARTITION BY range (b);
---END---
---START---
CREATE TABLE uv_pt11 (gemini_pk serial PRIMARY KEY, LIKE uv_pt1);
---END---
---START---
alter table uv_pt11 drop a;
---END---
---START---
alter table uv_pt11 add a int;
---END---
---START---
alter table uv_pt11 drop a;
---END---
---START---
alter table uv_pt11 add a int not null;
---END---
---START---
alter table uv_pt1 attach partition uv_pt11 for values from (2) to (5);
---END---
---START---
alter table uv_pt attach partition uv_pt1 for values from (1, 2) to (1, 10);
---END---
---START---
create view uv_ptv as select * from uv_pt;
---END---
---START---
select events & 4 != 0 AS upd,
       events & 8 != 0 AS ins,
       events & 16 != 0 AS del
  from pg_catalog.pg_relation_is_updatable('uv_pt'::regclass, false) t(events);
---END---
---START---
select pg_catalog.pg_column_is_updatable('uv_pt'::regclass, 1::smallint, false);
---END---
---START---
select pg_catalog.pg_column_is_updatable('uv_pt'::regclass, 2::smallint, false);
---END---
---START---
select table_name, is_updatable, is_insertable_into
  from information_schema.views where table_name = 'uv_ptv';
---END---
---START---
select table_name, column_name, is_updatable
  from information_schema.columns where table_name = 'uv_ptv' order by column_name;
---END---
---START---
insert into uv_ptv values (1, 2);
---END---
---START---
select tableoid::regclass, * from uv_pt;
---END---
---START---
create view uv_ptv_wco as select * from uv_pt where a = 0 with check option;
---END---
---START---
insert into uv_ptv_wco values (1, 2);
---END---
---START---
drop view uv_ptv, uv_ptv_wco;
---END---
---START---
drop table uv_pt, uv_pt1, uv_pt11;
---END---
---START---
CREATE TABLE wcowrtest (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY list (a);
---END---
---START---
create table wcowrtest1 partition of wcowrtest for values in (1);
---END---
---START---
create view wcowrtest_v as select * from wcowrtest where wcowrtest = '(2)'::wcowrtest with check option;
---END---
---START---
insert into wcowrtest_v values (1);
---END---
---START---
alter table wcowrtest add b text;
---END---
---START---
CREATE TABLE wcowrtest2 (gemini_pk serial PRIMARY KEY, b text, c integer, a integer);
---END---
---START---
alter table wcowrtest2 drop c;
---END---
---START---
alter table wcowrtest attach partition wcowrtest2 for values in (2);
---END---
---START---
CREATE TABLE sometable (gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
insert into sometable values (1, 'a'), (2, 'b');
---END---
---START---
create view wcowrtest_v2 as
    select *
      from wcowrtest r
      where r in (select s from sometable s where r.a = s.a)
with check option;
---END---
---START---
-- WITH CHECK qual will be processed with wcowrtest2's
-- rowtype after tuple-routing
insert into wcowrtest_v2 values (2, 'no such row in sometable');
---END---
---START---
drop view wcowrtest_v, wcowrtest_v2;
---END---
---START---
drop table wcowrtest, sometable;
---END---
---START---
CREATE TABLE uv_iocu_tab (gemini_pk serial PRIMARY KEY, a text UNIQUE, b double precision);
---END---
---START---
insert into uv_iocu_tab values ('xyxyxy', 0);
---END---
---START---
create view uv_iocu_view as
   select b, b+1 as c, a, '2.0'::text as two from uv_iocu_tab;
---END---
---START---
insert into uv_iocu_view (a, b) values ('xyxyxy', 1)
   on conflict (a) do update set b = uv_iocu_view.b;
---END---
---START---
select * from uv_iocu_tab;
---END---
---START---
insert into uv_iocu_view (a, b) values ('xyxyxy', 1)
   on conflict (a) do update set b = excluded.b;
---END---
---START---
select * from uv_iocu_tab;
---END---
---START---
-- OK to access view columns that are not present in underlying base
-- relation in the ON CONFLICT portion of the query
insert into uv_iocu_view (a, b) values ('xyxyxy', 3)
   on conflict (a) do update set b = cast(excluded.two as float);
---END---
---START---
select * from uv_iocu_tab;
---END---
---START---
explain (costs off)
insert into uv_iocu_view (a, b) values ('xyxyxy', 3)
   on conflict (a) do update set b = excluded.b where excluded.c > 0;
---END---
---START---
insert into uv_iocu_view (a, b) values ('xyxyxy', 3)
   on conflict (a) do update set b = excluded.b where excluded.c > 0;
---END---
---START---
select * from uv_iocu_tab;
---END---
---START---
drop view uv_iocu_view;
---END---
---START---
drop table uv_iocu_tab;
---END---
---START---
CREATE TABLE uv_iocu_tab (gemini_pk serial PRIMARY KEY, a integer UNIQUE, b text);
---END---
---START---
create view uv_iocu_view as
    select b as bb, a as aa, uv_iocu_tab::text as cc from uv_iocu_tab;
---END---
---START---
insert into uv_iocu_view (aa,bb) values (1,'x');
---END---
---START---
explain (costs off)
insert into uv_iocu_view (aa,bb) values (1,'y')
   on conflict (aa) do update set bb = 'Rejected: '||excluded.*
   where excluded.aa > 0
   and excluded.bb != ''
   and excluded.cc is not null;
---END---
---START---
insert into uv_iocu_view (aa,bb) values (1,'y')
   on conflict (aa) do update set bb = 'Rejected: '||excluded.*
   where excluded.aa > 0
   and excluded.bb != ''
   and excluded.cc is not null;
---END---
---START---
select * from uv_iocu_view;
---END---
---START---
-- Test omitting a column of the base relation
delete from uv_iocu_view;
---END---
---START---
insert into uv_iocu_view (aa,bb) values (1,'x');
---END---
---START---
insert into uv_iocu_view (aa) values (1)
   on conflict (aa) do update set bb = 'Rejected: '||excluded.*;
---END---
---START---
select * from uv_iocu_view;
---END---
---START---
alter table uv_iocu_tab alter column b set default 'table default';
---END---
---START---
insert into uv_iocu_view (aa) values (1)
   on conflict (aa) do update set bb = 'Rejected: '||excluded.*;
---END---
---START---
select * from uv_iocu_view;
---END---
---START---
alter view uv_iocu_view alter column bb set default 'view default';
---END---
---START---
insert into uv_iocu_view (aa) values (1)
   on conflict (aa) do update set bb = 'Rejected: '||excluded.*;
---END---
---START---
select * from uv_iocu_view;
---END---
---START---
-- Should fail to update non-updatable columns
insert into uv_iocu_view (aa) values (1)
   on conflict (aa) do update set cc = 'XXX';
---END---
---START---
drop view uv_iocu_view;
---END---
---START---
drop table uv_iocu_tab;
---END---
---START---
-- ON CONFLICT DO UPDATE permissions checks
create user regress_view_user1;
---END---
---START---
create user regress_view_user2;
---END---
---START---
set session authorization regress_view_user1;
---END---
---START---
CREATE TABLE base_tbl (gemini_pk serial PRIMARY KEY, a integer UNIQUE, b text, c double precision);
---END---
---START---
insert into base_tbl values (1,'xxx',1.0);
---END---
---START---
create view rw_view1 as select b as bb, c as cc, a as aa from base_tbl;
---END---
---START---
grant select (aa,bb) on rw_view1 to regress_view_user2;
---END---
---START---
grant insert on rw_view1 to regress_view_user2;
---END---
---START---
grant update (bb) on rw_view1 to regress_view_user2;
---END---
---START---
set session authorization regress_view_user2;
---END---
---START---
insert into rw_view1 values ('yyy',2.0,1)
  on conflict (aa) do update set bb = excluded.cc;
---END---
---START---
-- Not allowed
insert into rw_view1 values ('yyy',2.0,1)
  on conflict (aa) do update set bb = rw_view1.cc;
---END---
---START---
-- Not allowed
insert into rw_view1 values ('yyy',2.0,1)
  on conflict (aa) do update set bb = excluded.bb;
---END---
---START---
-- OK
insert into rw_view1 values ('zzz',2.0,1)
  on conflict (aa) do update set bb = rw_view1.bb||'xxx';
---END---
---START---
-- OK
insert into rw_view1 values ('zzz',2.0,1)
  on conflict (aa) do update set cc = 3.0;
---END---
---START---
-- Not allowed
reset session authorization;
---END---
---START---
select * from base_tbl;
---END---
---START---
set session authorization regress_view_user1;
---END---
---START---
grant select (a,b) on base_tbl to regress_view_user2;
---END---
---START---
grant insert (a,b) on base_tbl to regress_view_user2;
---END---
---START---
grant update (a,b) on base_tbl to regress_view_user2;
---END---
---START---
set session authorization regress_view_user2;
---END---
---START---
create view rw_view2 as select b as bb, c as cc, a as aa from base_tbl;
---END---
---START---
insert into rw_view2 (aa,bb) values (1,'xxx')
  on conflict (aa) do update set bb = excluded.bb;
---END---
---START---
-- Not allowed
create view rw_view3 as select b as bb, a as aa from base_tbl;
---END---
---START---
insert into rw_view3 (aa,bb) values (1,'xxx')
  on conflict (aa) do update set bb = excluded.bb;
---END---
---START---
-- OK
reset session authorization;
---END---
---START---
select * from base_tbl;
---END---
---START---
set session authorization regress_view_user2;
---END---
---START---
create view rw_view4 as select aa, bb, cc FROM rw_view1;
---END---
---START---
insert into rw_view4 (aa,bb) values (1,'yyy')
  on conflict (aa) do update set bb = excluded.bb;
---END---
---START---
-- Not allowed
create view rw_view5 as select aa, bb FROM rw_view1;
---END---
---START---
insert into rw_view5 (aa,bb) values (1,'yyy')
  on conflict (aa) do update set bb = excluded.bb;
---END---
---START---
-- OK
reset session authorization;
---END---
---START---
select * from base_tbl;
---END---
---START---
drop view rw_view5;
---END---
---START---
drop view rw_view4;
---END---
---START---
drop view rw_view3;
---END---
---START---
drop view rw_view2;
---END---
---START---
drop view rw_view1;
---END---
---START---
drop table base_tbl;
---END---
---START---
drop user regress_view_user1;
---END---
---START---
drop user regress_view_user2;
---END---
---START---
CREATE TABLE base_tab_def (gemini_pk serial PRIMARY KEY, a integer, b text DEFAULT 'Table default', c text DEFAULT 'Table default', d text, e text);
---END---
---START---
create view base_tab_def_view as select * from base_tab_def;
---END---
---START---
alter view base_tab_def_view alter b set default 'View default';
---END---
---START---
alter view base_tab_def_view alter d set default 'View default';
---END---
---START---
insert into base_tab_def values (1);
---END---
---START---
insert into base_tab_def values (2), (3);
---END---
---START---
insert into base_tab_def values (4, default, default, default, default);
---END---
---START---
insert into base_tab_def values (5, default, default, default, default),
                                (6, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (11);
---END---
---START---
insert into base_tab_def_view values (12), (13);
---END---
---START---
insert into base_tab_def_view values (14, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (15, default, default, default, default),
                                     (16, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (17), (default);
---END---
---START---
select * from base_tab_def order by a;
---END---
---START---
-- Adding an INSTEAD OF trigger should cause NULLs to be inserted instead of
-- table defaults, where there are no view defaults.
create function base_tab_def_view_instrig_func() returns trigger
as
$$
begin
  insert into base_tab_def values (new.a, new.b, new.c, new.d, new.e);
  return new;
end;
$$
language plpgsql;
---END---
---START---
create trigger base_tab_def_view_instrig instead of insert on base_tab_def_view
  for each row execute function base_tab_def_view_instrig_func();
---END---
---START---
truncate base_tab_def;
---END---
---START---
insert into base_tab_def values (1);
---END---
---START---
insert into base_tab_def values (2), (3);
---END---
---START---
insert into base_tab_def values (4, default, default, default, default);
---END---
---START---
insert into base_tab_def values (5, default, default, default, default),
                                (6, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (11);
---END---
---START---
insert into base_tab_def_view values (12), (13);
---END---
---START---
insert into base_tab_def_view values (14, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (15, default, default, default, default),
                                     (16, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (17), (default);
---END---
---START---
select * from base_tab_def order by a;
---END---
---START---
-- Using an unconditional DO INSTEAD rule should also cause NULLs to be
-- inserted where there are no view defaults.
drop trigger base_tab_def_view_instrig on base_tab_def_view;
---END---
---START---
drop function base_tab_def_view_instrig_func;
---END---
---START---
create rule base_tab_def_view_ins_rule as on insert to base_tab_def_view
  do instead insert into base_tab_def values (new.a, new.b, new.c, new.d, new.e);
---END---
---START---
truncate base_tab_def;
---END---
---START---
insert into base_tab_def values (1);
---END---
---START---
insert into base_tab_def values (2), (3);
---END---
---START---
insert into base_tab_def values (4, default, default, default, default);
---END---
---START---
insert into base_tab_def values (5, default, default, default, default),
                                (6, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (11);
---END---
---START---
insert into base_tab_def_view values (12), (13);
---END---
---START---
insert into base_tab_def_view values (14, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (15, default, default, default, default),
                                     (16, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (17), (default);
---END---
---START---
select * from base_tab_def order by a;
---END---
---START---
-- A DO ALSO rule should cause each row to be inserted twice. The first
-- insert should behave the same as an auto-updatable view (using table
-- defaults, unless overridden by view defaults). The second insert should
-- behave the same as a rule-updatable view (inserting NULLs where there are
-- no view defaults).
drop rule base_tab_def_view_ins_rule on base_tab_def_view;
---END---
---START---
create rule base_tab_def_view_ins_rule as on insert to base_tab_def_view
  do also insert into base_tab_def values (new.a, new.b, new.c, new.d, new.e);
---END---
---START---
truncate base_tab_def;
---END---
---START---
insert into base_tab_def values (1);
---END---
---START---
insert into base_tab_def values (2), (3);
---END---
---START---
insert into base_tab_def values (4, default, default, default, default);
---END---
---START---
insert into base_tab_def values (5, default, default, default, default),
                                (6, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (11);
---END---
---START---
insert into base_tab_def_view values (12), (13);
---END---
---START---
insert into base_tab_def_view values (14, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (15, default, default, default, default),
                                     (16, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (17), (default);
---END---
---START---
select * from base_tab_def order by a, c NULLS LAST;
---END---
---START---
-- Test a DO ALSO INSERT ... SELECT rule
drop rule base_tab_def_view_ins_rule on base_tab_def_view;
---END---
---START---
create rule base_tab_def_view_ins_rule as on insert to base_tab_def_view
  do also insert into base_tab_def (a, b, e) select new.a, new.b, 'xxx';
---END---
---START---
truncate base_tab_def;
---END---
---START---
insert into base_tab_def_view values (1, default, default, default, default);
---END---
---START---
insert into base_tab_def_view values (2, default, default, default, default),
                                     (3, default, default, default, default);
---END---
---START---
select * from base_tab_def order by a, e nulls first;
---END---
---START---
drop view base_tab_def_view;
---END---
---START---
drop table base_tab_def;
---END---
---START---
CREATE TABLE base_tab (gemini_pk serial PRIMARY KEY, a serial, b integer[], c text, d text DEFAULT 'Table default');
---END---
---START---
create view base_tab_view as select c, a, b from base_tab;
---END---
---START---
alter view base_tab_view alter column c set default 'View default';
---END---
---START---
insert into base_tab_view (b[1], b[2], c, b[5], b[4], a, b[3])
values (1, 2, default, 5, 4, default, 3), (10, 11, 'C value', 14, 13, 100, 12);
---END---
---START---
select * from base_tab order by a;
---END---
---START---
drop view base_tab_view;
---END---
---START---
drop table base_tab;
---END---
