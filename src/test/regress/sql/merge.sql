---START---
--
-- MERGE
--

CREATE USER regress_merge_privs;
---END---
---START---
CREATE USER regress_merge_no_privs;
---END---
---START---
DROP TABLE IF EXISTS target;
---END---
---START---
DROP TABLE IF EXISTS source;
---END---
---START---
CREATE TABLE target (tid integer, balance integer)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE source (sid integer, delta integer) -- no index
  WITH (autovacuum_enabled=off);
---END---
---START---
INSERT INTO target VALUES (1, 10);
---END---
---START---
INSERT INTO target VALUES (2, 20);
---END---
---START---
INSERT INTO target VALUES (3, 30);
---END---
---START---
SELECT t.ctid is not null as matched, t.*, s.* FROM source s FULL OUTER JOIN target t ON s.sid = t.tid ORDER BY t.tid, s.sid;
---END---
---START---

ALTER TABLE target OWNER TO regress_merge_privs;
---END---
---START---
ALTER TABLE source OWNER TO regress_merge_privs;
---END---
---START---

CREATE TABLE target2 (tid integer, balance integer)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE source2 (sid integer, delta integer)
  WITH (autovacuum_enabled=off);
---END---
---START---

ALTER TABLE target2 OWNER TO regress_merge_no_privs;
---END---
---START---
ALTER TABLE source2 OWNER TO regress_merge_no_privs;
---END---
---START---

GRANT INSERT ON target TO regress_merge_no_privs;
---END---
---START---

SET SESSION AUTHORIZATION regress_merge_privs;
---END---
---START---

EXPLAIN (COSTS OFF)
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---

--
-- Errors
--
MERGE INTO target t RANDOMWORD
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
-- MATCHED/INSERT error
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---
-- incorrectly specifying INTO target
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT INTO target DEFAULT VALUES;
---END---
---START---
-- Multiple VALUES clause
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT VALUES (1,1), (2,2);
---END---
---START---
-- SELECT query for INSERT
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT SELECT (1, 1);
---END---
---START---
-- NOT MATCHED/UPDATE
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
-- UPDATE tablename
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE target SET balance = 0;
---END---
---START---
-- source and target names the same
MERGE INTO target
USING target
ON tid = tid
WHEN MATCHED THEN DO NOTHING;
---END---
---START---
-- used in a CTE
WITH foo AS (
  MERGE INTO target USING source ON (true)
  WHEN MATCHED THEN DELETE
) SELECT * FROM foo;
---END---
---START---
-- used in COPY
COPY (
  MERGE INTO target USING source ON (true)
  WHEN MATCHED THEN DELETE
) TO stdout;
---END---
---START---

-- unsupported relation types
-- view
CREATE VIEW tv AS SELECT * FROM target;
---END---
---START---
MERGE INTO tv t
USING source s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---
DROP VIEW tv;
---END---
---START---

-- materialized view
CREATE MATERIALIZED VIEW mv AS SELECT * FROM target;
---END---
---START---
MERGE INTO mv t
USING source s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---
DROP MATERIALIZED VIEW mv;
---END---
---START---

-- permissions

MERGE INTO target
USING source2
ON target.tid = source2.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---

GRANT INSERT ON target TO regress_merge_no_privs;
---END---
---START---
SET SESSION AUTHORIZATION regress_merge_no_privs;
---END---
---START---

MERGE INTO target
USING source2
ON target.tid = source2.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---

GRANT UPDATE ON target2 TO regress_merge_privs;
---END---
---START---
SET SESSION AUTHORIZATION regress_merge_privs;
---END---
---START---

MERGE INTO target2
USING source
ON target2.tid = source.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---

MERGE INTO target2
USING source
ON target2.tid = source.sid
WHEN NOT MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---

-- check if the target can be accessed from source relation subquery; we should
-- not be able to do so
MERGE INTO target t
USING (SELECT * FROM source WHERE t.tid > sid) s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---

--
-- initial tests
--
-- zero rows in source has no effect
MERGE INTO target
USING source
ON target.tid = source.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---

MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---
ROLLBACK;
---END---
---START---

-- insert some non-matching source rows to work from
INSERT INTO source VALUES (4, 40);
---END---
---START---
SELECT * FROM source ORDER BY sid;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---

MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	DO NOTHING;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT DEFAULT VALUES;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- index plans
INSERT INTO target SELECT generate_series(1000,2500), 0;
---END---
---START---
ALTER TABLE target ADD PRIMARY KEY (tid);
---END---
---START---
ANALYZE target;
---END---
---START---

EXPLAIN (COSTS OFF)
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
EXPLAIN (COSTS OFF)
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---
EXPLAIN (COSTS OFF)
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT VALUES (4, NULL);
---END---
---START---
DELETE FROM target WHERE tid > 100;
---END---
---START---
ANALYZE target;
---END---
---START---

-- insert some matching source rows to work from
INSERT INTO source VALUES (2, 5);
---END---
---START---
INSERT INTO source VALUES (3, 20);
---END---
---START---
SELECT * FROM source ORDER BY sid;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---

-- equivalent of an UPDATE join
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- equivalent of a DELETE join
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DO NOTHING;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT VALUES (4, NULL);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- duplicate source row causes multiple target row update ERROR
INSERT INTO source VALUES (2, 5);
---END---
---START---
SELECT * FROM source ORDER BY sid;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	DELETE;
---END---
---START---
ROLLBACK;
---END---
---START---

-- remove duplicate MATCHED data from source data
DELETE FROM source WHERE sid = 2;
---END---
---START---
INSERT INTO source VALUES (2, 5);
---END---
---START---
SELECT * FROM source ORDER BY sid;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---

-- duplicate source row on INSERT should fail because of target_pkey
INSERT INTO source VALUES (4, 40);
---END---
---START---
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
  INSERT VALUES (4, NULL);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- remove duplicate NOT MATCHED data from source data
DELETE FROM source WHERE sid = 4;
---END---
---START---
INSERT INTO source VALUES (4, 40);
---END---
---START---
SELECT * FROM source ORDER BY sid;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---

-- remove constraints
alter table target drop CONSTRAINT target_pkey;
---END---
---START---
alter table target alter column tid drop not null;
---END---
---START---

-- multiple actions
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT VALUES (4, 4)
WHEN MATCHED THEN
	UPDATE SET balance = 0;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- should be equivalent
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = 0
WHEN NOT MATCHED THEN
	INSERT VALUES (4, 4);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- column references
-- do a simple equivalent of an UPDATE join
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = t.balance + s.delta;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- do a simple equivalent of an INSERT SELECT
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- and again with duplicate source rows
INSERT INTO source VALUES (5, 50);
---END---
---START---
INSERT INTO source VALUES (5, 50);
---END---
---START---

-- do a simple equivalent of an INSERT SELECT
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
  INSERT VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- removing duplicate source rows
DELETE FROM source WHERE sid = 5;
---END---
---START---

-- and again with explicitly identified column list
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- and again with a subtle error: referring to non-existent target row for NOT MATCHED
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (t.tid, s.delta);
---END---
---START---

-- and again with a constant ON clause
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON (SELECT true)
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (t.tid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- now the classic UPSERT
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = t.balance + s.delta
WHEN NOT MATCHED THEN
	INSERT VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- unreachable WHEN clause should ERROR
BEGIN;
---END---
---START---
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED THEN /* Terminal WHEN clause for MATCHED */
	DELETE
WHEN MATCHED THEN
	UPDATE SET balance = t.balance - s.delta;
---END---
---START---
ROLLBACK;
---END---
---START---

-- conditional WHEN clause
CREATE TABLE wq_target (tid integer not null, balance integer DEFAULT -1)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE wq_source (balance integer, sid integer)
  WITH (autovacuum_enabled=off);
---END---
---START---

INSERT INTO wq_source (sid, balance) VALUES (1, 100);
---END---
---START---

BEGIN;
---END---
---START---
-- try a simple INSERT with default values first
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid) VALUES (s.sid);
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

-- this time with a FALSE condition
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN NOT MATCHED AND FALSE THEN
	INSERT (tid) VALUES (s.sid);
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

-- this time with an actual condition which returns false
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN NOT MATCHED AND s.balance <> 100 THEN
	INSERT (tid) VALUES (s.sid);
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

BEGIN;
---END---
---START---
-- and now with a condition which returns true
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN NOT MATCHED AND s.balance = 100 THEN
	INSERT (tid) VALUES (s.sid);
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

-- conditions in the NOT MATCHED clause can only refer to source columns
BEGIN;
---END---
---START---
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN NOT MATCHED AND t.balance = 100 THEN
	INSERT (tid) VALUES (s.sid);
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN NOT MATCHED AND s.balance = 100 THEN
	INSERT (tid) VALUES (s.sid);
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

-- conditions in MATCHED clause can refer to both source and target
SELECT * FROM wq_source;
---END---
---START---
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND s.balance = 100 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.balance = 100 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

-- check if AND works
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.balance = 99 AND s.balance > 100 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.balance = 99 AND s.balance = 100 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

-- check if OR works
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.balance = 99 OR s.balance > 100 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.balance = 199 OR s.balance > 100 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

-- check source-side whole-row references
BEGIN;
---END---
---START---
MERGE INTO wq_target t
USING wq_source s ON (t.tid = s.sid)
WHEN matched and t = s or t.tid = s.sid THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

-- check if subqueries work in the conditions?
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.balance > (SELECT max(balance) FROM target) THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---

-- check if we can access system columns in the conditions
MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.xmin = t.xmax THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---

MERGE INTO wq_target t
USING wq_source s ON t.tid = s.sid
WHEN MATCHED AND t.tableoid >= 0 THEN
	UPDATE SET balance = t.balance + s.balance;
---END---
---START---
SELECT * FROM wq_target;
---END---
---START---

DROP TABLE wq_target, wq_source;
---END---
---START---

-- test triggers
create or replace function merge_trigfunc () returns trigger
language plpgsql as
$$
DECLARE
	line text;
---END---
---START---
BEGIN
	SELECT INTO line format('%s %s %s trigger%s',
		TG_WHEN, TG_OP, TG_LEVEL, CASE
		WHEN TG_OP = 'INSERT' AND TG_LEVEL = 'ROW'
			THEN format(' row: %s', NEW)
		WHEN TG_OP = 'UPDATE' AND TG_LEVEL = 'ROW'
			THEN format(' row: %s -> %s', OLD, NEW)
		WHEN TG_OP = 'DELETE' AND TG_LEVEL = 'ROW'
			THEN format(' row: %s', OLD)
		END);
---END---
---START---

	RAISE NOTICE '%', line;
---END---
---START---
	IF (TG_WHEN = 'BEFORE' AND TG_LEVEL = 'ROW') THEN
		IF (TG_OP = 'DELETE') THEN
			RETURN OLD;
---END---
---START---
		ELSE
			RETURN NEW;
---END---
---START---
		END IF;
---END---
---START---
	ELSE
		RETURN NULL;
---END---
---START---
	END IF;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
CREATE TRIGGER merge_bsi BEFORE INSERT ON target FOR EACH STATEMENT EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_bsu BEFORE UPDATE ON target FOR EACH STATEMENT EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_bsd BEFORE DELETE ON target FOR EACH STATEMENT EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_asi AFTER INSERT ON target FOR EACH STATEMENT EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_asu AFTER UPDATE ON target FOR EACH STATEMENT EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_asd AFTER DELETE ON target FOR EACH STATEMENT EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_bri BEFORE INSERT ON target FOR EACH ROW EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_bru BEFORE UPDATE ON target FOR EACH ROW EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_brd BEFORE DELETE ON target FOR EACH ROW EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_ari AFTER INSERT ON target FOR EACH ROW EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_aru AFTER UPDATE ON target FOR EACH ROW EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---
CREATE TRIGGER merge_ard AFTER DELETE ON target FOR EACH ROW EXECUTE PROCEDURE merge_trigfunc ();
---END---
---START---

-- now the classic UPSERT, with a DELETE
BEGIN;
---END---
---START---
UPDATE target SET balance = 0 WHERE tid = 3;
---END---
---START---
--EXPLAIN (ANALYZE ON, COSTS OFF, SUMMARY OFF, TIMING OFF)
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED AND t.balance > s.delta THEN
	UPDATE SET balance = t.balance - s.delta
WHEN MATCHED THEN
	DELETE
WHEN NOT MATCHED THEN
	INSERT VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- Test behavior of triggers that turn UPDATE/DELETE into no-ops
create or replace function skip_merge_op() returns trigger
language plpgsql as
$$
BEGIN
	RETURN NULL;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

SELECT * FROM target full outer join source on (sid = tid);
---END---
---START---
create trigger merge_skip BEFORE INSERT OR UPDATE or DELETE
  ON target FOR EACH ROW EXECUTE FUNCTION skip_merge_op();
---END---
---START---
DO $$
DECLARE
  result integer;
---END---
---START---
BEGIN
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED AND s.sid = 3 THEN UPDATE SET balance = t.balance + s.delta
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN INSERT VALUES (sid, delta);
---END---
---START---
IF FOUND THEN
  RAISE NOTICE 'Found';
---END---
---START---
ELSE
  RAISE NOTICE 'Not found';
---END---
---START---
END IF;
---END---
---START---
GET DIAGNOSTICS result := ROW_COUNT;
---END---
---START---
RAISE NOTICE 'ROW_COUNT = %', result;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
SELECT * FROM target FULL OUTER JOIN source ON (sid = tid);
---END---
---START---
DROP TRIGGER merge_skip ON target;
---END---
---START---
DROP FUNCTION skip_merge_op();
---END---
---START---

-- test from PL/pgSQL
-- make sure MERGE INTO isn't interpreted to mean returning variables like SELECT INTO
BEGIN;
---END---
---START---
DO LANGUAGE plpgsql $$
BEGIN
MERGE INTO target t
USING source AS s
ON t.tid = s.sid
WHEN MATCHED AND t.balance > s.delta THEN
	UPDATE SET balance = t.balance - s.delta;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
ROLLBACK;
---END---
---START---

--source constants
BEGIN;
---END---
---START---
MERGE INTO target t
USING (SELECT 9 AS sid, 57 AS delta) AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

--source query
BEGIN;
---END---
---START---
MERGE INTO target t
USING (SELECT sid, delta FROM source WHERE delta > 0) AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO target t
USING (SELECT sid, delta as newname FROM source WHERE delta > 0) AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (s.sid, s.newname);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

--self-merge
BEGIN;
---END---
---START---
MERGE INTO target t1
USING target t2
ON t1.tid = t2.tid
WHEN MATCHED THEN
	UPDATE SET balance = t1.balance + t2.balance
WHEN NOT MATCHED THEN
	INSERT VALUES (t2.tid, t2.balance);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO target t
USING (SELECT tid as sid, balance as delta FROM target WHERE balance > 0) AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO target t
USING
(SELECT sid, max(delta) AS delta
 FROM source
 GROUP BY sid
 HAVING count(*) = 1
 ORDER BY sid ASC) AS s
ON t.tid = s.sid
WHEN NOT MATCHED THEN
	INSERT (tid, balance) VALUES (s.sid, s.delta);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- plpgsql parameters and results
BEGIN;
---END---
---START---
CREATE FUNCTION merge_func (p_id integer, p_bal integer)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
 result integer;
---END---
---START---
BEGIN
MERGE INTO target t
USING (SELECT p_id AS sid) AS s
ON t.tid = s.sid
WHEN MATCHED THEN
	UPDATE SET balance = t.balance - p_bal;
---END---
---START---
IF FOUND THEN
	GET DIAGNOSTICS result := ROW_COUNT;
---END---
---START---
END IF;
---END---
---START---
RETURN result;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
SELECT merge_func(3, 4);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- PREPARE
BEGIN;
---END---
---START---
prepare foom as merge into target t using (select 1 as sid) s on (t.tid = s.sid) when matched then update set balance = 1;
---END---
---START---
execute foom;
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
PREPARE foom2 (integer, integer) AS
MERGE INTO target t
USING (SELECT 1) s
ON t.tid = $1
WHEN MATCHED THEN
UPDATE SET balance = $2;
---END---
---START---
--EXPLAIN (ANALYZE ON, COSTS OFF, SUMMARY OFF, TIMING OFF)
execute foom2 (1, 1);
---END---
---START---
SELECT * FROM target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- subqueries in source relation

CREATE TABLE sq_target (tid integer NOT NULL, balance integer)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE sq_source (delta integer, sid integer, balance integer DEFAULT 0)
  WITH (autovacuum_enabled=off);
---END---
---START---

INSERT INTO sq_target(tid, balance) VALUES (1,100), (2,200), (3,300);
---END---
---START---
INSERT INTO sq_source(sid, delta) VALUES (1,10), (2,20), (4,40);
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO sq_target t
USING (SELECT * FROM sq_source) s
ON tid = sid
WHEN MATCHED AND t.balance > delta THEN
	UPDATE SET balance = t.balance + delta;
---END---
---START---
SELECT * FROM sq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

-- try a view
CREATE VIEW v AS SELECT * FROM sq_source WHERE sid < 2;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO sq_target
USING v
ON tid = sid
WHEN MATCHED THEN
    UPDATE SET balance = v.balance + delta;
---END---
---START---
SELECT * FROM sq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

-- ambiguous reference to a column
BEGIN;
---END---
---START---
MERGE INTO sq_target
USING v
ON tid = sid
WHEN MATCHED AND tid > 2 THEN
    UPDATE SET balance = balance + delta
WHEN NOT MATCHED THEN
	INSERT (balance, tid) VALUES (balance + delta, sid)
WHEN MATCHED AND tid < 2 THEN
	DELETE;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
INSERT INTO sq_source (sid, balance, delta) VALUES (-1, -1, -10);
---END---
---START---
MERGE INTO sq_target t
USING v
ON tid = sid
WHEN MATCHED AND tid > 2 THEN
    UPDATE SET balance = t.balance + delta
WHEN NOT MATCHED THEN
	INSERT (balance, tid) VALUES (balance + delta, sid)
WHEN MATCHED AND tid < 2 THEN
	DELETE;
---END---
---START---
SELECT * FROM sq_target;
---END---
---START---
ROLLBACK;
---END---
---START---

-- CTEs
BEGIN;
---END---
---START---
INSERT INTO sq_source (sid, balance, delta) VALUES (-1, -1, -10);
---END---
---START---
WITH targq AS (
	SELECT * FROM v
)
MERGE INTO sq_target t
USING v
ON tid = sid
WHEN MATCHED AND tid > 2 THEN
    UPDATE SET balance = t.balance + delta
WHEN NOT MATCHED THEN
	INSERT (balance, tid) VALUES (balance + delta, sid)
WHEN MATCHED AND tid < 2 THEN
	DELETE;
---END---
---START---
ROLLBACK;
---END---
---START---

-- RETURNING
BEGIN;
---END---
---START---
INSERT INTO sq_source (sid, balance, delta) VALUES (-1, -1, -10);
---END---
---START---
MERGE INTO sq_target t
USING v
ON tid = sid
WHEN MATCHED AND tid > 2 THEN
    UPDATE SET balance = t.balance + delta
WHEN NOT MATCHED THEN
	INSERT (balance, tid) VALUES (balance + delta, sid)
WHEN MATCHED AND tid < 2 THEN
	DELETE
RETURNING *;
---END---
---START---
ROLLBACK;
---END---
---START---

-- EXPLAIN
CREATE TABLE ex_mtarget (a int, b int)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE ex_msource (a int, b int)
  WITH (autovacuum_enabled=off);
---END---
---START---
INSERT INTO ex_mtarget SELECT i, i*10 FROM generate_series(1,100,2) i;
---END---
---START---
INSERT INTO ex_msource SELECT i, i*10 FROM generate_series(1,100,1) i;
---END---
---START---

CREATE FUNCTION explain_merge(query text) RETURNS SETOF text
LANGUAGE plpgsql AS
$$
DECLARE ln text;
---END---
---START---
BEGIN
    FOR ln IN
        EXECUTE 'explain (analyze, timing off, summary off, costs off) ' ||
		  query
    LOOP
        ln := regexp_replace(ln, '(Memory( Usage)?|Buckets|Batches): \S*',  '\1: xxx', 'g');
---END---
---START---
        RETURN NEXT ln;
---END---
---START---
    END LOOP;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

-- only updates
SELECT explain_merge('
MERGE INTO ex_mtarget t USING ex_msource s ON t.a = s.a
WHEN MATCHED THEN
	UPDATE SET b = t.b + 1');
---END---
---START---

-- only updates to selected tuples
SELECT explain_merge('
MERGE INTO ex_mtarget t USING ex_msource s ON t.a = s.a
WHEN MATCHED AND t.a < 10 THEN
	UPDATE SET b = t.b + 1');
---END---
---START---

-- updates + deletes
SELECT explain_merge('
MERGE INTO ex_mtarget t USING ex_msource s ON t.a = s.a
WHEN MATCHED AND t.a < 10 THEN
	UPDATE SET b = t.b + 1
WHEN MATCHED AND t.a >= 10 AND t.a <= 20 THEN
	DELETE');
---END---
---START---

-- only inserts
SELECT explain_merge('
MERGE INTO ex_mtarget t USING ex_msource s ON t.a = s.a
WHEN NOT MATCHED AND s.a < 10 THEN
	INSERT VALUES (a, b)');
---END---
---START---

-- all three
SELECT explain_merge('
MERGE INTO ex_mtarget t USING ex_msource s ON t.a = s.a
WHEN MATCHED AND t.a < 10 THEN
	UPDATE SET b = t.b + 1
WHEN MATCHED AND t.a >= 30 AND t.a <= 40 THEN
	DELETE
WHEN NOT MATCHED AND s.a < 20 THEN
	INSERT VALUES (a, b)');
---END---
---START---

-- nothing
SELECT explain_merge('
MERGE INTO ex_mtarget t USING ex_msource s ON t.a = s.a AND t.a < -1000
WHEN MATCHED AND t.a < 10 THEN
	DO NOTHING');
---END---
---START---

DROP TABLE ex_msource, ex_mtarget;
---END---
---START---
DROP FUNCTION explain_merge(text);
---END---
---START---

-- Subqueries
BEGIN;
---END---
---START---
MERGE INTO sq_target t
USING v
ON tid = sid
WHEN MATCHED THEN
    UPDATE SET balance = (SELECT count(*) FROM sq_target);
---END---
---START---
SELECT * FROM sq_target WHERE tid = 1;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO sq_target t
USING v
ON tid = sid
WHEN MATCHED AND (SELECT count(*) > 0 FROM sq_target) THEN
    UPDATE SET balance = 42;
---END---
---START---
SELECT * FROM sq_target WHERE tid = 1;
---END---
---START---
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO sq_target t
USING v
ON tid = sid AND (SELECT count(*) > 0 FROM sq_target)
WHEN MATCHED THEN
    UPDATE SET balance = 42;
---END---
---START---
SELECT * FROM sq_target WHERE tid = 1;
---END---
---START---
ROLLBACK;
---END---
---START---

DROP TABLE sq_target, sq_source CASCADE;
---END---
---START---

CREATE TABLE pa_target (tid integer, balance float, val text)
	PARTITION BY LIST (tid);
---END---
---START---

CREATE TABLE part1 PARTITION OF pa_target FOR VALUES IN (1,4)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part2 PARTITION OF pa_target FOR VALUES IN (2,5,6)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part3 PARTITION OF pa_target FOR VALUES IN (3,8,9)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part4 PARTITION OF pa_target DEFAULT
  WITH (autovacuum_enabled=off);
---END---
---START---

CREATE TABLE pa_source (sid integer, delta float);
---END---
---START---
-- insert many rows to the source table
INSERT INTO pa_source SELECT id, id * 10  FROM generate_series(1,14) AS id;
---END---
---START---
-- insert a few rows in the target table (odd numbered tid)
INSERT INTO pa_target SELECT id, id * 100, 'initial' FROM generate_series(1,14,2) AS id;
---END---
---START---

-- try simple MERGE
BEGIN;
---END---
---START---
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid
  WHEN MATCHED THEN
    UPDATE SET balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (sid, delta, 'inserted by merge');
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- same with a constant qual
BEGIN;
---END---
---START---
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid AND tid = 1
  WHEN MATCHED THEN
    UPDATE SET balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (sid, delta, 'inserted by merge');
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- try updating the partition key column
BEGIN;
---END---
---START---
CREATE FUNCTION merge_func() RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
  result integer;
---END---
---START---
BEGIN
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid
  WHEN MATCHED THEN
    UPDATE SET tid = tid + 1, balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (sid, delta, 'inserted by merge');
---END---
---START---
IF FOUND THEN
  GET DIAGNOSTICS result := ROW_COUNT;
---END---
---START---
END IF;
---END---
---START---
RETURN result;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
SELECT merge_func();
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

DROP TABLE pa_target CASCADE;
---END---
---START---

-- The target table is partitioned in the same way, but this time by attaching
-- partitions which have columns in different order, dropped columns etc.
CREATE TABLE pa_target (tid integer, balance float, val text)
	PARTITION BY LIST (tid);
---END---
---START---

CREATE TABLE part1 (tid integer, balance float, val text)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part2 (balance float, tid integer, val text)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part3 (tid integer, balance float, val text)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part4 (extraid text, tid integer, balance float, val text)
  WITH (autovacuum_enabled=off);
---END---
---START---
ALTER TABLE part4 DROP COLUMN extraid;
---END---
---START---

ALTER TABLE pa_target ATTACH PARTITION part1 FOR VALUES IN (1,4);
---END---
---START---
ALTER TABLE pa_target ATTACH PARTITION part2 FOR VALUES IN (2,5,6);
---END---
---START---
ALTER TABLE pa_target ATTACH PARTITION part3 FOR VALUES IN (3,8,9);
---END---
---START---
ALTER TABLE pa_target ATTACH PARTITION part4 DEFAULT;
---END---
---START---

-- insert a few rows in the target table (odd numbered tid)
INSERT INTO pa_target SELECT id, id * 100, 'initial' FROM generate_series(1,14,2) AS id;
---END---
---START---

-- try simple MERGE
BEGIN;
---END---
---START---
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid
  WHEN MATCHED THEN
    UPDATE SET balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (sid, delta, 'inserted by merge');
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- same with a constant qual
BEGIN;
---END---
---START---
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid AND tid IN (1, 5)
  WHEN MATCHED AND tid % 5 = 0 THEN DELETE
  WHEN MATCHED THEN
    UPDATE SET balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (sid, delta, 'inserted by merge');
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- try updating the partition key column
BEGIN;
---END---
---START---
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid
  WHEN MATCHED THEN
    UPDATE SET tid = tid + 1, balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (sid, delta, 'inserted by merge');
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

-- test RLS enforcement
BEGIN;
---END---
---START---
ALTER TABLE pa_target ENABLE ROW LEVEL SECURITY;
---END---
---START---
ALTER TABLE pa_target FORCE ROW LEVEL SECURITY;
---END---
---START---
CREATE POLICY pa_target_pol ON pa_target USING (tid != 0);
---END---
---START---
MERGE INTO pa_target t
  USING pa_source s
  ON t.tid = s.sid AND t.tid IN (1,2,3,4)
  WHEN MATCHED THEN
    UPDATE SET tid = tid - 1;
---END---
---START---
ROLLBACK;
---END---
---START---

DROP TABLE pa_source;
---END---
---START---
DROP TABLE pa_target CASCADE;
---END---
---START---

-- Sub-partitioning
CREATE TABLE pa_target (logts timestamp, tid integer, balance float, val text)
	PARTITION BY RANGE (logts);
---END---
---START---

CREATE TABLE part_m01 PARTITION OF pa_target
	FOR VALUES FROM ('2017-01-01') TO ('2017-02-01')
	PARTITION BY LIST (tid);
---END---
---START---
CREATE TABLE part_m01_odd PARTITION OF part_m01
	FOR VALUES IN (1,3,5,7,9) WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part_m01_even PARTITION OF part_m01
	FOR VALUES IN (2,4,6,8) WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part_m02 PARTITION OF pa_target
	FOR VALUES FROM ('2017-02-01') TO ('2017-03-01')
	PARTITION BY LIST (tid);
---END---
---START---
CREATE TABLE part_m02_odd PARTITION OF part_m02
	FOR VALUES IN (1,3,5,7,9) WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE part_m02_even PARTITION OF part_m02
	FOR VALUES IN (2,4,6,8) WITH (autovacuum_enabled=off);
---END---
---START---

CREATE TABLE pa_source (sid integer, delta float)
  WITH (autovacuum_enabled=off);
---END---
---START---
-- insert many rows to the source table
INSERT INTO pa_source SELECT id, id * 10  FROM generate_series(1,14) AS id;
---END---
---START---
-- insert a few rows in the target table (odd numbered tid)
INSERT INTO pa_target SELECT '2017-01-31', id, id * 100, 'initial' FROM generate_series(1,9,3) AS id;
---END---
---START---
INSERT INTO pa_target SELECT '2017-02-28', id, id * 100, 'initial' FROM generate_series(2,9,3) AS id;
---END---
---START---

-- try simple MERGE
BEGIN;
---END---
---START---
MERGE INTO pa_target t
  USING (SELECT '2017-01-15' AS slogts, * FROM pa_source WHERE sid < 10) s
  ON t.tid = s.sid
  WHEN MATCHED THEN
    UPDATE SET balance = balance + delta, val = val || ' updated by merge'
  WHEN NOT MATCHED THEN
    INSERT VALUES (slogts::timestamp, sid, delta, 'inserted by merge');
---END---
---START---
SELECT * FROM pa_target ORDER BY tid;
---END---
---START---
ROLLBACK;
---END---
---START---

DROP TABLE pa_source;
---END---
---START---
DROP TABLE pa_target CASCADE;
---END---
---START---

-- Partitioned table with primary key

CREATE TABLE pa_target (tid integer PRIMARY KEY) PARTITION BY LIST (tid);
---END---
---START---
CREATE TABLE pa_targetp PARTITION OF pa_target DEFAULT;
---END---
---START---
CREATE TABLE pa_source (sid integer);
---END---
---START---

INSERT INTO pa_source VALUES (1), (2);
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
MERGE INTO pa_target t USING pa_source s ON t.tid = s.sid
  WHEN NOT MATCHED THEN INSERT VALUES (s.sid);
---END---
---START---

MERGE INTO pa_target t USING pa_source s ON t.tid = s.sid
  WHEN NOT MATCHED THEN INSERT VALUES (s.sid);
---END---
---START---

TABLE pa_target;
---END---
---START---

-- Partition-less partitioned table
-- (the bug we are checking for appeared only if table had partitions before)

DROP TABLE pa_targetp;
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
MERGE INTO pa_target t USING pa_source s ON t.tid = s.sid
  WHEN NOT MATCHED THEN INSERT VALUES (s.sid);
---END---
---START---

MERGE INTO pa_target t USING pa_source s ON t.tid = s.sid
  WHEN NOT MATCHED THEN INSERT VALUES (s.sid);
---END---
---START---

DROP TABLE pa_source;
---END---
---START---
DROP TABLE pa_target CASCADE;
---END---
---START---

-- some complex joins on the source side

CREATE TABLE cj_target (tid integer, balance float, val text)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE cj_source1 (sid1 integer, scat integer, delta integer)
  WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE cj_source2 (sid2 integer, sval text)
  WITH (autovacuum_enabled=off);
---END---
---START---
INSERT INTO cj_source1 VALUES (1, 10, 100);
---END---
---START---
INSERT INTO cj_source1 VALUES (1, 20, 200);
---END---
---START---
INSERT INTO cj_source1 VALUES (2, 20, 300);
---END---
---START---
INSERT INTO cj_source1 VALUES (3, 10, 400);
---END---
---START---
INSERT INTO cj_source2 VALUES (1, 'initial source2');
---END---
---START---
INSERT INTO cj_source2 VALUES (2, 'initial source2');
---END---
---START---
INSERT INTO cj_source2 VALUES (3, 'initial source2');
---END---
---START---

-- source relation is an unaliased join
MERGE INTO cj_target t
USING cj_source1 s1
	INNER JOIN cj_source2 s2 ON sid1 = sid2
ON t.tid = sid1
WHEN NOT MATCHED THEN
	INSERT VALUES (sid1, delta, sval);
---END---
---START---

-- try accessing columns from either side of the source join
MERGE INTO cj_target t
USING cj_source2 s2
	INNER JOIN cj_source1 s1 ON sid1 = sid2 AND scat = 20
ON t.tid = sid1
WHEN NOT MATCHED THEN
	INSERT VALUES (sid2, delta, sval)
WHEN MATCHED THEN
	DELETE;
---END---
---START---

-- some simple expressions in INSERT targetlist
MERGE INTO cj_target t
USING cj_source2 s2
	INNER JOIN cj_source1 s1 ON sid1 = sid2
ON t.tid = sid1
WHEN NOT MATCHED THEN
	INSERT VALUES (sid2, delta + scat, sval)
WHEN MATCHED THEN
	UPDATE SET val = val || ' updated by merge';
---END---
---START---

MERGE INTO cj_target t
USING cj_source2 s2
	INNER JOIN cj_source1 s1 ON sid1 = sid2 AND scat = 20
ON t.tid = sid1
WHEN MATCHED THEN
	UPDATE SET val = val || ' ' || delta::text;
---END---
---START---

SELECT * FROM cj_target;
---END---
---START---

-- try it with an outer join and PlaceHolderVar
MERGE INTO cj_target t
USING (SELECT *, 'join input'::text AS phv FROM cj_source1) fj
	FULL JOIN cj_source2 fj2 ON fj.scat = fj2.sid2 * 10
ON t.tid = fj.scat
WHEN NOT MATCHED THEN
	INSERT (tid, balance, val) VALUES (fj.scat, fj.delta, fj.phv);
---END---
---START---

SELECT * FROM cj_target;
---END---
---START---

ALTER TABLE cj_source1 RENAME COLUMN sid1 TO sid;
---END---
---START---
ALTER TABLE cj_source2 RENAME COLUMN sid2 TO sid;
---END---
---START---

TRUNCATE cj_target;
---END---
---START---

MERGE INTO cj_target t
USING cj_source1 s1
	INNER JOIN cj_source2 s2 ON s1.sid = s2.sid
ON t.tid = s1.sid
WHEN NOT MATCHED THEN
	INSERT VALUES (s2.sid, delta, sval);
---END---
---START---

DROP TABLE cj_source2, cj_source1, cj_target;
---END---
---START---

-- Function scans
CREATE TABLE fs_target (a int, b int, c text)
  WITH (autovacuum_enabled=off);
---END---
---START---
MERGE INTO fs_target t
USING generate_series(1,100,1) AS id
ON t.a = id
WHEN MATCHED THEN
	UPDATE SET b = b + id
WHEN NOT MATCHED THEN
	INSERT VALUES (id, -1);
---END---
---START---

MERGE INTO fs_target t
USING generate_series(1,100,2) AS id
ON t.a = id
WHEN MATCHED THEN
	UPDATE SET b = b + id, c = 'updated '|| id.*::text
WHEN NOT MATCHED THEN
	INSERT VALUES (id, -1, 'inserted ' || id.*::text);
---END---
---START---

SELECT count(*) FROM fs_target;
---END---
---START---
DROP TABLE fs_target;
---END---
---START---

-- SERIALIZABLE test
-- handled in isolation tests

-- Inheritance-based partitioning
CREATE TABLE measurement (
    city_id         int not null,
    logdate         date not null,
    peaktemp        int,
    unitsales       int
) WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE measurement_y2006m02 (
    CHECK ( logdate >= DATE '2006-02-01' AND logdate < DATE '2006-03-01' )
) INHERITS (measurement) WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE measurement_y2006m03 (
    CHECK ( logdate >= DATE '2006-03-01' AND logdate < DATE '2006-04-01' )
) INHERITS (measurement) WITH (autovacuum_enabled=off);
---END---
---START---
CREATE TABLE measurement_y2007m01 (
    filler          text,
    peaktemp        int,
    logdate         date not null,
    city_id         int not null,
    unitsales       int
    CHECK ( logdate >= DATE '2007-01-01' AND logdate < DATE '2007-02-01')
) WITH (autovacuum_enabled=off);
---END---
---START---
ALTER TABLE measurement_y2007m01 DROP COLUMN filler;
---END---
---START---
ALTER TABLE measurement_y2007m01 INHERIT measurement;
---END---
---START---
INSERT INTO measurement VALUES (0, '2005-07-21', 5, 15);
---END---
---START---

CREATE OR REPLACE FUNCTION measurement_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.logdate >= DATE '2006-02-01' AND
         NEW.logdate < DATE '2006-03-01' ) THEN
        INSERT INTO measurement_y2006m02 VALUES (NEW.*);
---END---
---START---
    ELSIF ( NEW.logdate >= DATE '2006-03-01' AND
            NEW.logdate < DATE '2006-04-01' ) THEN
        INSERT INTO measurement_y2006m03 VALUES (NEW.*);
---END---
---START---
    ELSIF ( NEW.logdate >= DATE '2007-01-01' AND
            NEW.logdate < DATE '2007-02-01' ) THEN
        INSERT INTO measurement_y2007m01 (city_id, logdate, peaktemp, unitsales)
            VALUES (NEW.*);
---END---
---START---
    ELSE
        RAISE EXCEPTION 'Date out of range.  Fix the measurement_insert_trigger() function!';
---END---
---START---
    END IF;
---END---
---START---
    RETURN NULL;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql ;
---END---
---START---
CREATE TRIGGER insert_measurement_trigger
    BEFORE INSERT ON measurement
    FOR EACH ROW EXECUTE PROCEDURE measurement_insert_trigger();
---END---
---START---
INSERT INTO measurement VALUES (1, '2006-02-10', 35, 10);
---END---
---START---
INSERT INTO measurement VALUES (1, '2006-02-16', 45, 20);
---END---
---START---
INSERT INTO measurement VALUES (1, '2006-03-17', 25, 10);
---END---
---START---
INSERT INTO measurement VALUES (1, '2006-03-27', 15, 40);
---END---
---START---
INSERT INTO measurement VALUES (1, '2007-01-15', 10, 10);
---END---
---START---
INSERT INTO measurement VALUES (1, '2007-01-17', 10, 10);
---END---
---START---

SELECT tableoid::regclass, * FROM measurement ORDER BY city_id, logdate;
---END---
---START---

CREATE TABLE new_measurement (LIKE measurement) WITH (autovacuum_enabled=off);
---END---
---START---
INSERT INTO new_measurement VALUES (0, '2005-07-21', 25, 20);
---END---
---START---
INSERT INTO new_measurement VALUES (1, '2006-03-01', 20, 10);
---END---
---START---
INSERT INTO new_measurement VALUES (1, '2006-02-16', 50, 10);
---END---
---START---
INSERT INTO new_measurement VALUES (2, '2006-02-10', 20, 20);
---END---
---START---
INSERT INTO new_measurement VALUES (1, '2006-03-27', NULL, NULL);
---END---
---START---
INSERT INTO new_measurement VALUES (1, '2007-01-17', NULL, NULL);
---END---
---START---
INSERT INTO new_measurement VALUES (1, '2007-01-15', 5, NULL);
---END---
---START---
INSERT INTO new_measurement VALUES (1, '2007-01-16', 10, 10);
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO ONLY measurement m
 USING new_measurement nm ON
      (m.city_id = nm.city_id and m.logdate=nm.logdate)
WHEN MATCHED AND nm.peaktemp IS NULL THEN DELETE
WHEN MATCHED THEN UPDATE
     SET peaktemp = greatest(m.peaktemp, nm.peaktemp),
        unitsales = m.unitsales + coalesce(nm.unitsales, 0)
WHEN NOT MATCHED THEN INSERT
     (city_id, logdate, peaktemp, unitsales)
   VALUES (city_id, logdate, peaktemp, unitsales);
---END---
---START---

SELECT tableoid::regclass, * FROM measurement ORDER BY city_id, logdate, peaktemp;
---END---
---START---
ROLLBACK;
---END---
---START---

MERGE into measurement m
 USING new_measurement nm ON
      (m.city_id = nm.city_id and m.logdate=nm.logdate)
WHEN MATCHED AND nm.peaktemp IS NULL THEN DELETE
WHEN MATCHED THEN UPDATE
     SET peaktemp = greatest(m.peaktemp, nm.peaktemp),
        unitsales = m.unitsales + coalesce(nm.unitsales, 0)
WHEN NOT MATCHED THEN INSERT
     (city_id, logdate, peaktemp, unitsales)
   VALUES (city_id, logdate, peaktemp, unitsales);
---END---
---START---

SELECT tableoid::regclass, * FROM measurement ORDER BY city_id, logdate;
---END---
---START---

BEGIN;
---END---
---START---
MERGE INTO new_measurement nm
 USING ONLY measurement m ON
      (nm.city_id = m.city_id and nm.logdate=m.logdate)
WHEN MATCHED THEN DELETE;
---END---
---START---

SELECT * FROM new_measurement ORDER BY city_id, logdate;
---END---
---START---
ROLLBACK;
---END---
---START---

MERGE INTO new_measurement nm
 USING measurement m ON
      (nm.city_id = m.city_id and nm.logdate=m.logdate)
WHEN MATCHED THEN DELETE;
---END---
---START---

SELECT * FROM new_measurement ORDER BY city_id, logdate;
---END---
---START---

DROP TABLE measurement, new_measurement CASCADE;
---END---
---START---
DROP FUNCTION measurement_insert_trigger();
---END---
---START---

-- prepare

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE target, target2;
---END---
---START---
DROP TABLE source, source2;
---END---
---START---
DROP FUNCTION merge_trigfunc();
---END---
---START---
DROP USER regress_merge_privs;
---END---
---START---
DROP USER regress_merge_no_privs;
---END---
