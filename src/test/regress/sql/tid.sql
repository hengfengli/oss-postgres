---START---
-- basic tests for the TID data type

SELECT
  '(0,0)'::tid as tid00,
  '(0,1)'::tid as tid01,
  '(-1,0)'::tid as tidm10,
  '(4294967295,65535)'::tid as tidmax;
---END---
---START---
SELECT '(4294967296,1)'::tid;
---END---
---START---
-- error
SELECT '(1,65536)'::tid;
---END---
---START---
-- error

-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('(0)', 'tid');
---END---
---START---
SELECT * FROM pg_input_error_info('(0)', 'tid');
---END---
---START---
SELECT pg_input_is_valid('(0,-1)', 'tid');
---END---
---START---
SELECT * FROM pg_input_error_info('(0,-1)', 'tid');
---END---
---START---
CREATE TABLE tid_tab (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
-- min() and max() for TIDs
INSERT INTO tid_tab VALUES (1), (2);
---END---
---START---
SELECT min(ctid) FROM tid_tab;
---END---
---START---
SELECT max(ctid) FROM tid_tab;
---END---
---START---
TRUNCATE tid_tab;
---END---
---START---
-- Tests for currtid2() with various relation kinds

-- Materialized view
CREATE MATERIALIZED VIEW tid_matview AS SELECT a FROM tid_tab;
---END---
---START---
SELECT currtid2('tid_matview'::text, '(0,1)'::tid);
---END---
---START---
-- fails
INSERT INTO tid_tab VALUES (1);
---END---
---START---
REFRESH MATERIALIZED VIEW tid_matview;
---END---
---START---
SELECT currtid2('tid_matview'::text, '(0,1)'::tid);
---END---
---START---
-- ok
DROP MATERIALIZED VIEW tid_matview;
---END---
---START---
TRUNCATE tid_tab;
---END---
---START---
-- Sequence
CREATE SEQUENCE tid_seq;
---END---
---START---
SELECT currtid2('tid_seq'::text, '(0,1)'::tid);
---END---
---START---
-- ok
DROP SEQUENCE tid_seq;
---END---
---START---
-- Index, fails with incorrect relation type
CREATE INDEX tid_ind ON tid_tab(a);
---END---
---START---
SELECT currtid2('tid_ind'::text, '(0,1)'::tid);
---END---
---START---
-- fails
DROP INDEX tid_ind;
---END---
---START---
CREATE TABLE tid_part (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
SELECT currtid2('tid_part'::text, '(0,1)'::tid);
---END---
---START---
-- fails
DROP TABLE tid_part;
---END---
---START---
-- Views
-- ctid not defined in the view
CREATE VIEW tid_view_no_ctid AS SELECT a FROM tid_tab;
---END---
---START---
SELECT currtid2('tid_view_no_ctid'::text, '(0,1)'::tid);
---END---
---START---
-- fails
DROP VIEW tid_view_no_ctid;
---END---
---START---
-- ctid fetched directly from the source table.
CREATE VIEW tid_view_with_ctid AS SELECT ctid, a FROM tid_tab;
---END---
---START---
SELECT currtid2('tid_view_with_ctid'::text, '(0,1)'::tid);
---END---
---START---
-- fails
INSERT INTO tid_tab VALUES (1);
---END---
---START---
SELECT currtid2('tid_view_with_ctid'::text, '(0,1)'::tid);
---END---
---START---
-- ok
DROP VIEW tid_view_with_ctid;
---END---
---START---
TRUNCATE tid_tab;
---END---
---START---
-- ctid attribute with incorrect data type
CREATE VIEW tid_view_fake_ctid AS SELECT 1 AS ctid, 2 AS a;
---END---
---START---
SELECT currtid2('tid_view_fake_ctid'::text, '(0,1)'::tid);
---END---
---START---
-- fails
DROP VIEW tid_view_fake_ctid;
---END---
---START---
DROP TABLE tid_tab CASCADE;
---END---
