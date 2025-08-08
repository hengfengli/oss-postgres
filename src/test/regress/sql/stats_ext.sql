---START---
-- Generic extended statistics support

--
-- Note: tables for which we check estimated row counts should be created
-- with autovacuum_enabled = off, so that we don't have unstable results
-- from auto-analyze happening when we didn't expect it.
--

-- check the number of estimated/actual rows in the top node
create function check_estimated_rows(text) returns table (estimated int, actual int)
language plpgsql as
$$
declare
    ln text;
    tmp text[];
    first_row bool := true;
begin
    for ln in
        execute format('explain analyze %s', $1)
    loop
        if first_row then
            first_row := false;
            tmp := regexp_match(ln, 'rows=(\d*) .* rows=(\d*)');
            return query select tmp[1]::int, tmp[2]::int;
        end if;
    end loop;
end;
$$;
---END---
---START---
-- Verify failures
CREATE TABLE ext_stats_test (x text, y int, z int);
---END---
---START---
CREATE STATISTICS tst;
---END---
---START---
CREATE STATISTICS tst ON a, b;
---END---
---START---
CREATE STATISTICS tst FROM sometab;
---END---
---START---
CREATE STATISTICS tst ON a, b FROM nonexistent;
---END---
---START---
CREATE STATISTICS tst ON a, b FROM ext_stats_test;
---END---
---START---
CREATE STATISTICS tst ON x, x, y FROM ext_stats_test;
---END---
---START---
CREATE STATISTICS tst ON x, x, y, x, x, y, x, x, y FROM ext_stats_test;
---END---
---START---
CREATE STATISTICS tst ON x, x, y, x, x, (x || 'x'), (y + 1), (x || 'x'), (x || 'x'), (y + 1) FROM ext_stats_test;
---END---
---START---
CREATE STATISTICS tst ON (x || 'x'), (x || 'x'), (y + 1), (x || 'x'), (x || 'x'), (y + 1), (x || 'x'), (x || 'x'), (y + 1) FROM ext_stats_test;
---END---
---START---
CREATE STATISTICS tst ON (x || 'x'), (x || 'x'), y FROM ext_stats_test;
---END---
---START---
CREATE STATISTICS tst (unrecognized) ON x, y FROM ext_stats_test;
---END---
---START---
-- incorrect expressions
CREATE STATISTICS tst ON (y) FROM ext_stats_test;
---END---
---START---
-- single column reference
CREATE STATISTICS tst ON y + z FROM ext_stats_test;
---END---
---START---
-- missing parentheses
CREATE STATISTICS tst ON (x, y) FROM ext_stats_test;
---END---
---START---
-- tuple expression
DROP TABLE ext_stats_test;
---END---
---START---
-- Ensure stats are dropped sanely, and test IF NOT EXISTS while at it
CREATE TABLE ab1 (a INTEGER, b INTEGER, c INTEGER);
---END---
---START---
CREATE STATISTICS IF NOT EXISTS ab1_a_b_stats ON a, b FROM ab1;
---END---
---START---
COMMENT ON STATISTICS ab1_a_b_stats IS 'new comment';
---END---
---START---
CREATE ROLE regress_stats_ext;
---END---
---START---
SET SESSION AUTHORIZATION regress_stats_ext;
---END---
---START---
COMMENT ON STATISTICS ab1_a_b_stats IS 'changed comment';
---END---
---START---
DROP STATISTICS ab1_a_b_stats;
---END---
---START---
ALTER STATISTICS ab1_a_b_stats RENAME TO ab1_a_b_stats_new;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP ROLE regress_stats_ext;
---END---
---START---
CREATE STATISTICS IF NOT EXISTS ab1_a_b_stats ON a, b FROM ab1;
---END---
---START---
DROP STATISTICS ab1_a_b_stats;
---END---
---START---
CREATE SCHEMA regress_schema_2;
---END---
---START---
CREATE STATISTICS regress_schema_2.ab1_a_b_stats ON a, b FROM ab1;
---END---
---START---
-- Let's also verify the pg_get_statisticsobjdef output looks sane.
SELECT pg_get_statisticsobjdef(oid) FROM pg_statistic_ext WHERE stxname = 'ab1_a_b_stats';
---END---
---START---
DROP STATISTICS regress_schema_2.ab1_a_b_stats;
---END---
---START---
-- Ensure statistics are dropped when columns are
CREATE STATISTICS ab1_b_c_stats ON b, c FROM ab1;
---END---
---START---
CREATE STATISTICS ab1_a_b_c_stats ON a, b, c FROM ab1;
---END---
---START---
CREATE STATISTICS ab1_b_a_stats ON b, a FROM ab1;
---END---
---START---
ALTER TABLE ab1 DROP COLUMN a;
---END---
---START---
\d ab1
-- Ensure statistics are dropped when table is
SELECT stxname FROM pg_statistic_ext WHERE stxname LIKE 'ab1%';
---END---
---START---
DROP TABLE ab1;
---END---
---START---
SELECT stxname FROM pg_statistic_ext WHERE stxname LIKE 'ab1%';
---END---
---START---
-- Ensure things work sanely with SET STATISTICS 0
CREATE TABLE ab1 (a INTEGER, b INTEGER);
---END---
---START---
ALTER TABLE ab1 ALTER a SET STATISTICS 0;
---END---
---START---
INSERT INTO ab1 SELECT a, a%23 FROM generate_series(1, 1000) a;
---END---
---START---
CREATE STATISTICS ab1_a_b_stats ON a, b FROM ab1;
---END---
---START---
ANALYZE ab1;
---END---
---START---
ALTER TABLE ab1 ALTER a SET STATISTICS -1;
---END---
---START---
-- setting statistics target 0 skips the statistics, without printing any message, so check catalog
ALTER STATISTICS ab1_a_b_stats SET STATISTICS 0;
---END---
---START---
\d ab1
ANALYZE ab1;
---END---
---START---
SELECT stxname, stxdndistinct, stxddependencies, stxdmcv, stxdinherit
  FROM pg_statistic_ext s LEFT JOIN pg_statistic_ext_data d ON (d.stxoid = s.oid)
 WHERE s.stxname = 'ab1_a_b_stats';
---END---
---START---
ALTER STATISTICS ab1_a_b_stats SET STATISTICS -1;
---END---
---START---
\d+ ab1
-- partial analyze doesn't build stats either
ANALYZE ab1 (a);
---END---
---START---
ANALYZE ab1;
---END---
---START---
DROP TABLE ab1;
---END---
---START---
ALTER STATISTICS ab1_a_b_stats SET STATISTICS 0;
---END---
---START---
ALTER STATISTICS IF EXISTS ab1_a_b_stats SET STATISTICS 0;
---END---
---START---
-- Ensure we can build statistics for tables with inheritance.
CREATE TABLE ab1 (a INTEGER, b INTEGER);
---END---
---START---
CREATE TABLE ab1c () INHERITS (ab1);
---END---
---START---
INSERT INTO ab1 VALUES (1,1);
---END---
---START---
CREATE STATISTICS ab1_a_b_stats ON a, b FROM ab1;
---END---
---START---
ANALYZE ab1;
---END---
---START---
DROP TABLE ab1 CASCADE;
---END---
---START---
-- Tests for stats with inheritance
CREATE TABLE stxdinh(a int, b int);
---END---
---START---
CREATE TABLE stxdinh1() INHERITS(stxdinh);
---END---
---START---
CREATE TABLE stxdinh2() INHERITS(stxdinh);
---END---
---START---
INSERT INTO stxdinh SELECT mod(a,50), mod(a,100) FROM generate_series(0, 1999) a;
---END---
---START---
INSERT INTO stxdinh1 SELECT mod(a,100), mod(a,100) FROM generate_series(0, 999) a;
---END---
---START---
INSERT INTO stxdinh2 SELECT mod(a,100), mod(a,100) FROM generate_series(0, 999) a;
---END---
---START---
VACUUM ANALYZE stxdinh, stxdinh1, stxdinh2;
---END---
---START---
-- Ensure non-inherited stats are not applied to inherited query
-- Without stats object, it looks like this
SELECT * FROM check_estimated_rows('SELECT a, b FROM stxdinh* GROUP BY 1, 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT a, b FROM stxdinh* WHERE a = 0 AND b = 0');
---END---
---START---
CREATE STATISTICS stxdinh ON a, b FROM stxdinh;
---END---
---START---
VACUUM ANALYZE stxdinh, stxdinh1, stxdinh2;
---END---
---START---
-- See if the extended stats affect the estimates
SELECT * FROM check_estimated_rows('SELECT a, b FROM stxdinh* GROUP BY 1, 2');
---END---
---START---
-- Dependencies are applied at individual relations (within append), so
-- this estimate changes a bit because we improve estimates for the parent
SELECT * FROM check_estimated_rows('SELECT a, b FROM stxdinh* WHERE a = 0 AND b = 0');
---END---
---START---
-- Ensure correct (non-inherited) stats are applied to inherited query
SELECT * FROM check_estimated_rows('SELECT a, b FROM ONLY stxdinh GROUP BY 1, 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT a, b FROM ONLY stxdinh WHERE a = 0 AND b = 0');
---END---
---START---
DROP TABLE stxdinh, stxdinh1, stxdinh2;
---END---
---START---
-- Ensure inherited stats ARE applied to inherited query in partitioned table
CREATE TABLE stxdinp(i int, a int, b int) PARTITION BY RANGE (i);
---END---
---START---
CREATE TABLE stxdinp1 PARTITION OF stxdinp FOR VALUES FROM (1) TO (100);
---END---
---START---
INSERT INTO stxdinp SELECT 1, a/100, a/100 FROM generate_series(1, 999) a;
---END---
---START---
CREATE STATISTICS stxdinp ON (a + 1), a, b FROM stxdinp;
---END---
---START---
VACUUM ANALYZE stxdinp;
---END---
---START---
-- partitions are processed recursively
SELECT 1 FROM pg_statistic_ext WHERE stxrelid = 'stxdinp'::regclass;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT a, b FROM stxdinp GROUP BY 1, 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT a + 1, b FROM ONLY stxdinp GROUP BY 1, 2');
---END---
---START---
DROP TABLE stxdinp;
---END---
---START---
-- basic test for statistics on expressions
CREATE TABLE ab1 (a INTEGER, b INTEGER, c TIMESTAMP, d TIMESTAMPTZ);
---END---
---START---
-- expression stats may be built on a single expression column
CREATE STATISTICS ab1_exprstat_1 ON (a+b) FROM ab1;
---END---
---START---
-- with a single expression, we only enable expression statistics
CREATE STATISTICS ab1_exprstat_2 ON (a+b) FROM ab1;
---END---
---START---
SELECT stxkind FROM pg_statistic_ext WHERE stxname = 'ab1_exprstat_2';
---END---
---START---
-- adding anything to the expression builds all statistics kinds
CREATE STATISTICS ab1_exprstat_3 ON (a+b), a FROM ab1;
---END---
---START---
SELECT stxkind FROM pg_statistic_ext WHERE stxname = 'ab1_exprstat_3';
---END---
---START---
-- date_trunc on timestamptz is not immutable, but that should not matter
CREATE STATISTICS ab1_exprstat_4 ON date_trunc('day', d) FROM ab1;
---END---
---START---
-- date_trunc on timestamp is immutable
CREATE STATISTICS ab1_exprstat_5 ON date_trunc('day', c) FROM ab1;
---END---
---START---
-- check use of a boolean-returning expression
CREATE STATISTICS ab1_exprstat_6 ON
  (case a when 1 then true else false end), b FROM ab1;
---END---
---START---
-- insert some data and run analyze, to test that these cases build properly
INSERT INTO ab1
SELECT x / 10, x / 3,
    '2020-10-01'::timestamp + x * interval '1 day',
    '2020-10-01'::timestamptz + x * interval '1 day'
FROM generate_series(1, 100) x;
---END---
---START---
ANALYZE ab1;
---END---
---START---
-- apply some stats
SELECT * FROM check_estimated_rows('SELECT * FROM ab1 WHERE (case a when 1 then true else false end) AND b=2');
---END---
---START---
DROP TABLE ab1;
---END---
---START---
-- Verify supported object types for extended statistics
CREATE schema tststats;
---END---
---START---
CREATE TABLE tststats.t (a int, b int, c text);
---END---
---START---
CREATE INDEX ti ON tststats.t (a, b);
---END---
---START---
CREATE SEQUENCE tststats.s;
---END---
---START---
CREATE VIEW tststats.v AS SELECT * FROM tststats.t;
---END---
---START---
CREATE MATERIALIZED VIEW tststats.mv AS SELECT * FROM tststats.t;
---END---
---START---
CREATE TYPE tststats.ty AS (a int, b int, c text);
---END---
---START---
CREATE FOREIGN DATA WRAPPER extstats_dummy_fdw;
---END---
---START---
CREATE SERVER extstats_dummy_srv FOREIGN DATA WRAPPER extstats_dummy_fdw;
---END---
---START---
CREATE FOREIGN TABLE tststats.f (a int, b int, c text) SERVER extstats_dummy_srv;
---END---
---START---
CREATE TABLE tststats.pt (a int, b int, c text) PARTITION BY RANGE (a, b);
---END---
---START---
CREATE TABLE tststats.pt1 PARTITION OF tststats.pt FOR VALUES FROM (-10, -10) TO (10, 10);
---END---
---START---
CREATE STATISTICS tststats.s1 ON a, b FROM tststats.t;
---END---
---START---
CREATE STATISTICS tststats.s2 ON a, b FROM tststats.ti;
---END---
---START---
CREATE STATISTICS tststats.s3 ON a, b FROM tststats.s;
---END---
---START---
CREATE STATISTICS tststats.s4 ON a, b FROM tststats.v;
---END---
---START---
CREATE STATISTICS tststats.s5 ON a, b FROM tststats.mv;
---END---
---START---
CREATE STATISTICS tststats.s6 ON a, b FROM tststats.ty;
---END---
---START---
CREATE STATISTICS tststats.s7 ON a, b FROM tststats.f;
---END---
---START---
CREATE STATISTICS tststats.s8 ON a, b FROM tststats.pt;
---END---
---START---
CREATE STATISTICS tststats.s9 ON a, b FROM tststats.pt1;
---END---
---START---
DO $$
DECLARE
	relname text := reltoastrelid::regclass FROM pg_class WHERE oid = 'tststats.t'::regclass;
BEGIN
	EXECUTE 'CREATE STATISTICS tststats.s10 ON a, b FROM ' || relname;
EXCEPTION WHEN wrong_object_type THEN
	RAISE NOTICE 'stats on toast table not created';
END;
$$;
---END---
---START---
DROP SCHEMA tststats CASCADE;
---END---
---START---
DROP FOREIGN DATA WRAPPER extstats_dummy_fdw CASCADE;
---END---
---START---
-- n-distinct tests
CREATE TABLE ndistinct (
    filler1 TEXT,
    filler2 NUMERIC,
    a INT,
    b INT,
    filler3 DATE,
    c INT,
    d INT
)
WITH (autovacuum_enabled = off);
---END---
---START---
-- over-estimates when using only per-column statistics
INSERT INTO ndistinct (a, b, c, filler1)
     SELECT i/100, i/100, i/100, cash_words((i/100)::money)
       FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
-- Group Aggregate, due to over-estimate of the number of groups
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY b, c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (a+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100), (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (a+1), (b+100)');
---END---
---START---
-- correct command
CREATE STATISTICS s10 ON a, b, c FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT s.stxkind, d.stxdndistinct
  FROM pg_statistic_ext s, pg_statistic_ext_data d
 WHERE s.stxrelid = 'ndistinct'::regclass
   AND d.stxoid = s.oid;
---END---
---START---
-- minor improvement, make sure the ctid does not break the matching
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY ctid, a, b');
---END---
---START---
-- Hash Aggregate, thanks to estimates improved by the statistic
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY b, c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c');
---END---
---START---
-- partial improvement (match on attributes)
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (a+1)');
---END---
---START---
-- expressions - no improvement
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100), (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (a+1), (b+100)');
---END---
---START---
-- last two plans keep using Group Aggregate, because 'd' is not covered
-- by the statistic and while it's NULL-only we assume 200 values for it
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY b, c, d');
---END---
---START---
TRUNCATE TABLE ndistinct;
---END---
---START---
-- under-estimates when using only per-column statistics
INSERT INTO ndistinct (a, b, c, filler1)
     SELECT mod(i,13), mod(i,17), mod(i,19),
            cash_words(mod(i,23)::int::money)
       FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT s.stxkind, d.stxdndistinct
  FROM pg_statistic_ext s, pg_statistic_ext_data d
 WHERE s.stxrelid = 'ndistinct'::regclass
   AND d.stxoid = s.oid;
---END---
---START---
-- correct estimates
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (a+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100), (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (a+1), (b+100)');
---END---
---START---
DROP STATISTICS s10;
---END---
---START---
SELECT s.stxkind, d.stxdndistinct
  FROM pg_statistic_ext s, pg_statistic_ext_data d
 WHERE s.stxrelid = 'ndistinct'::regclass
   AND d.stxoid = s.oid;
---END---
---START---
-- dropping the statistics results in under-estimates
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY b, c, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, d');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (a+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100), (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (a+1), (b+100)');
---END---
---START---
-- ndistinct estimates with statistics on expressions
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100), (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (a+1), (b+100)');
---END---
---START---
CREATE STATISTICS s10 (ndistinct) ON (a+1), (b+100), (2*c) FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT s.stxkind, d.stxdndistinct
  FROM pg_statistic_ext s, pg_statistic_ext_data d
 WHERE s.stxrelid = 'ndistinct'::regclass
   AND d.stxoid = s.oid;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a+1), (b+100), (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (a+1), (b+100)');
---END---
---START---
DROP STATISTICS s10;
---END---
---START---
-- a mix of attributes and expressions
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (2*c)');
---END---
---START---
CREATE STATISTICS s10 (ndistinct) ON a, b, (2*c) FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT s.stxkind, d.stxdndistinct
  FROM pg_statistic_ext s, pg_statistic_ext_data d
 WHERE s.stxrelid = 'ndistinct'::regclass
   AND d.stxoid = s.oid;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (2*c)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (2*c)');
---END---
---START---
DROP STATISTICS s10;
---END---
---START---
-- combination of multiple ndistinct statistics, with/without expressions
TRUNCATE ndistinct;
---END---
---START---
-- two mostly independent groups of columns
INSERT INTO ndistinct (a, b, c, d)
     SELECT mod(i,3), mod(i,9), mod(i,5), mod(i,20)
       FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1), c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (c*10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1), c, (d - 1)');
---END---
---START---
-- basic statistics on both attributes (no expressions)
CREATE STATISTICS s11 (ndistinct) ON a, b FROM ndistinct;
---END---
---START---
CREATE STATISTICS s12 (ndistinct) ON c, d FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1), c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (c*10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1), c, (d - 1)');
---END---
---START---
-- replace the second statistics by statistics on expressions

DROP STATISTICS s12;
---END---
---START---
CREATE STATISTICS s12 (ndistinct) ON (c * 10), (d - 1) FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1), c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (c*10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1), c, (d - 1)');
---END---
---START---
-- replace the second statistics by statistics on both attributes and expressions

DROP STATISTICS s12;
---END---
---START---
CREATE STATISTICS s12 (ndistinct) ON c, d, (c * 10), (d - 1) FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1), c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (c*10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1), c, (d - 1)');
---END---
---START---
-- replace the other statistics by statistics on both attributes and expressions

DROP STATISTICS s11;
---END---
---START---
CREATE STATISTICS s11 (ndistinct) ON a, b, (a*5), (b+1) FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1), c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (c*10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1), c, (d - 1)');
---END---
---START---
-- replace statistics by somewhat overlapping ones (this expected to get worse estimate
-- because the first statistics shall be applied to 3 columns, and the second one can't
-- be really applied)

DROP STATISTICS s11;
---END---
---START---
DROP STATISTICS s12;
---END---
---START---
CREATE STATISTICS s11 (ndistinct) ON a, b, (a*5), (b+1) FROM ndistinct;
---END---
---START---
CREATE STATISTICS s12 (ndistinct) ON a, (b+1), (c * 10) FROM ndistinct;
---END---
---START---
ANALYZE ndistinct;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY (a*5), (b+1), c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, b, (c*10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT COUNT(*) FROM ndistinct GROUP BY a, (b+1), c, (d - 1)');
---END---
---START---
DROP STATISTICS s11;
---END---
---START---
DROP STATISTICS s12;
---END---
---START---
-- functional dependencies tests
CREATE TABLE functional_dependencies (
    filler1 TEXT,
    filler2 NUMERIC,
    a INT,
    b TEXT,
    filler3 DATE,
    c INT,
    d TEXT
)
WITH (autovacuum_enabled = off);
---END---
---START---
CREATE INDEX fdeps_ab_idx ON functional_dependencies (a, b);
---END---
---START---
CREATE INDEX fdeps_abc_idx ON functional_dependencies (a, b, c);
---END---
---START---
-- random data (no functional dependencies)
INSERT INTO functional_dependencies (a, b, c, filler1)
     SELECT mod(i, 5), mod(i, 7), mod(i, 11), i FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
-- create statistics
CREATE STATISTICS func_deps_stat (dependencies) ON a, b, c FROM functional_dependencies;
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
-- a => b, a => c, b => c
TRUNCATE functional_dependencies;
---END---
---START---
DROP STATISTICS func_deps_stat;
---END---
---START---
-- now do the same thing, but with expressions
INSERT INTO functional_dependencies (a, b, c, filler1)
     SELECT i, i, i, i FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE mod(a, 11) = 1 AND mod(b::int, 13) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE mod(a, 11) = 1 AND mod(b::int, 13) = 1 AND mod(c, 7) = 1');
---END---
---START---
-- create statistics
CREATE STATISTICS func_deps_stat (dependencies) ON (mod(a,11)), (mod(b::int, 13)), (mod(c, 7)) FROM functional_dependencies;
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE mod(a, 11) = 1 AND mod(b::int, 13) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE mod(a, 11) = 1 AND mod(b::int, 13) = 1 AND mod(c, 7) = 1');
---END---
---START---
-- a => b, a => c, b => c
TRUNCATE functional_dependencies;
---END---
---START---
DROP STATISTICS func_deps_stat;
---END---
---START---
INSERT INTO functional_dependencies (a, b, c, filler1)
     SELECT mod(i,100), mod(i,50), mod(i,25), i FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
-- IN
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 51, 52) AND b IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 51, 52) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 26, 51, 76) AND b IN (''1'', ''26'') AND c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 26, 51, 76) AND b IN (''1'', ''26'') AND c IN (1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 26, 27, 51, 52, 76, 77) AND b IN (''1'', ''2'', ''26'', ''27'') AND c IN (1, 2)');
---END---
---START---
-- OR clauses referencing the same attribute
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR a = 51) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR a = 51) AND (b = ''1'' OR b = ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR a = 2 OR a = 51 OR a = 52) AND (b = ''1'' OR b = ''2'')');
---END---
---START---
-- OR clauses referencing different attributes
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR b = ''1'') AND b = ''1''');
---END---
---START---
-- ANY
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 51]) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 51]) AND b = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 2, 51, 52]) AND b = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 26, 51, 76]) AND b = ANY (ARRAY[''1'', ''26'']) AND c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 26, 51, 76]) AND b = ANY (ARRAY[''1'', ''26'']) AND c = ANY (ARRAY[1])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 2, 26, 27, 51, 52, 76, 77]) AND b = ANY (ARRAY[''1'', ''2'', ''26'', ''27'']) AND c = ANY (ARRAY[1, 2])');
---END---
---START---
-- ANY with inequalities should not benefit from functional dependencies
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a < ANY (ARRAY[1, 51]) AND b > ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a >= ANY (ARRAY[1, 51]) AND b <= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a <= ANY (ARRAY[1, 2, 51, 52]) AND b >= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
-- ALL (should not benefit from functional dependencies)
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b = ALL (ARRAY[''1''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 51, 52) AND b = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
-- create statistics
CREATE STATISTICS func_deps_stat (dependencies) ON a, b, c FROM functional_dependencies;
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
-- print the detected dependencies
SELECT dependencies FROM pg_stats_ext WHERE statistics_name = 'func_deps_stat';
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
-- IN
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 51, 52) AND b IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 51, 52) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 26, 51, 76) AND b IN (''1'', ''26'') AND c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 26, 51, 76) AND b IN (''1'', ''26'') AND c IN (1)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 26, 27, 51, 52, 76, 77) AND b IN (''1'', ''2'', ''26'', ''27'') AND c IN (1, 2)');
---END---
---START---
-- OR clauses referencing the same attribute
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR a = 51) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR a = 51) AND (b = ''1'' OR b = ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR a = 2 OR a = 51 OR a = 52) AND (b = ''1'' OR b = ''2'')');
---END---
---START---
-- OR clauses referencing different attributes are incompatible
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a = 1 OR b = ''1'') AND b = ''1''');
---END---
---START---
-- ANY
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 51]) AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 51]) AND b = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 2, 51, 52]) AND b = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 26, 51, 76]) AND b = ANY (ARRAY[''1'', ''26'']) AND c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 26, 51, 76]) AND b = ANY (ARRAY[''1'', ''26'']) AND c = ANY (ARRAY[1])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = ANY (ARRAY[1, 2, 26, 27, 51, 52, 76, 77]) AND b = ANY (ARRAY[''1'', ''2'', ''26'', ''27'']) AND c = ANY (ARRAY[1, 2])');
---END---
---START---
-- ANY with inequalities should not benefit from functional dependencies
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a < ANY (ARRAY[1, 51]) AND b > ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a >= ANY (ARRAY[1, 51]) AND b <= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a <= ANY (ARRAY[1, 2, 51, 52]) AND b >= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
-- ALL (should not benefit from functional dependencies)
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b = ALL (ARRAY[''1''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 51) AND b = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a IN (1, 2, 51, 52) AND b = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
-- changing the type of column c causes all its stats to be dropped, reverting
-- to default estimates without any statistics, i.e. 0.5% selectivity for each
-- condition
ALTER TABLE functional_dependencies ALTER COLUMN c TYPE numeric;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
DROP STATISTICS func_deps_stat;
---END---
---START---
-- now try functional dependencies with expressions

SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = 2 AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = 2 AND upper(b) = ''1'' AND (c + 1) = 2');
---END---
---START---
-- IN
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 102, 104) AND upper(b) IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 102, 104) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 52, 102, 152) AND upper(b) IN (''1'', ''26'') AND (c + 1) = 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 52, 102, 152) AND upper(b) IN (''1'', ''26'') AND (c + 1) IN (2)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 52, 54, 102, 104, 152, 154) AND upper(b) IN (''1'', ''2'', ''26'', ''27'') AND (c + 1) IN (2, 3)');
---END---
---START---
-- OR clauses referencing the same attribute
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR (a * 2) = 102) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR (a * 2) = 102) AND (upper(b) = ''1'' OR upper(b) = ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR (a * 2) = 4 OR (a * 2) = 102 OR (a * 2) = 104) AND (upper(b) = ''1'' OR upper(b) = ''2'')');
---END---
---START---
-- OR clauses referencing different attributes
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR upper(b) = ''1'') AND upper(b) = ''1''');
---END---
---START---
-- ANY
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 102]) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 102]) AND upper(b) = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 4, 102, 104]) AND upper(b) = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 52, 102, 152]) AND upper(b) = ANY (ARRAY[''1'', ''26'']) AND (c + 1) = 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 52, 102, 152]) AND upper(b) = ANY (ARRAY[''1'', ''26'']) AND (c + 1) = ANY (ARRAY[2])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 4, 52, 54, 102, 104, 152, 154]) AND upper(b) = ANY (ARRAY[''1'', ''2'', ''26'', ''27'']) AND (c + 1) = ANY (ARRAY[2, 3])');
---END---
---START---
-- ANY with inequalities should not benefit from functional dependencies
-- the estimates however improve thanks to having expression statistics
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) < ANY (ARRAY[2, 102]) AND upper(b) > ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) >= ANY (ARRAY[2, 102]) AND upper(b) <= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) <= ANY (ARRAY[2, 4, 102, 104]) AND upper(b) >= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
-- ALL (should not benefit from functional dependencies)
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) = ALL (ARRAY[''1''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 102, 104) AND upper(b) = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
-- create statistics on expressions
CREATE STATISTICS func_deps_stat (dependencies) ON (a * 2), upper(b), (c + 1) FROM functional_dependencies;
---END---
---START---
ANALYZE functional_dependencies;
---END---
---START---
-- print the detected dependencies
SELECT dependencies FROM pg_stats_ext WHERE statistics_name = 'func_deps_stat';
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = 2 AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = 2 AND upper(b) = ''1'' AND (c + 1) = 2');
---END---
---START---
-- IN
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 102, 104) AND upper(b) IN (''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 102, 104) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 52, 102, 152) AND upper(b) IN (''1'', ''26'') AND (c + 1) = 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 52, 102, 152) AND upper(b) IN (''1'', ''26'') AND (c + 1) IN (2)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 52, 54, 102, 104, 152, 154) AND upper(b) IN (''1'', ''2'', ''26'', ''27'') AND (c + 1) IN (2, 3)');
---END---
---START---
-- OR clauses referencing the same attribute
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR (a * 2) = 102) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR (a * 2) = 102) AND (upper(b) = ''1'' OR upper(b) = ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR (a * 2) = 4 OR (a * 2) = 102 OR (a * 2) = 104) AND (upper(b) = ''1'' OR upper(b) = ''2'')');
---END---
---START---
-- OR clauses referencing different attributes
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE ((a * 2) = 2 OR upper(b) = ''1'') AND upper(b) = ''1''');
---END---
---START---
-- ANY
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 102]) AND upper(b) = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 102]) AND upper(b) = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 4, 102, 104]) AND upper(b) = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 52, 102, 152]) AND upper(b) = ANY (ARRAY[''1'', ''26'']) AND (c + 1) = 2');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 52, 102, 152]) AND upper(b) = ANY (ARRAY[''1'', ''26'']) AND (c + 1) = ANY (ARRAY[2])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) = ANY (ARRAY[2, 4, 52, 54, 102, 104, 152, 154]) AND upper(b) = ANY (ARRAY[''1'', ''2'', ''26'', ''27'']) AND (c + 1) = ANY (ARRAY[2, 3])');
---END---
---START---
-- ANY with inequalities should not benefit from functional dependencies
-- the estimates however improve thanks to having expression statistics
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) < ANY (ARRAY[2, 102]) AND upper(b) > ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) >= ANY (ARRAY[2, 102]) AND upper(b) <= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) <= ANY (ARRAY[2, 4, 102, 104]) AND upper(b) >= ANY (ARRAY[''1'', ''2''])');
---END---
---START---
-- ALL (should not benefit from functional dependencies)
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) = ALL (ARRAY[''1''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 102) AND upper(b) = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies WHERE (a * 2) IN (2, 4, 102, 104) AND upper(b) = ALL (ARRAY[''1'', ''2''])');
---END---
---START---
-- check the ability to use multiple functional dependencies
CREATE TABLE functional_dependencies_multi (
	a INTEGER,
	b INTEGER,
	c INTEGER,
	d INTEGER
)
WITH (autovacuum_enabled = off);
---END---
---START---
INSERT INTO functional_dependencies_multi (a, b, c, d)
    SELECT
         mod(i,7),
         mod(i,7),
         mod(i,11),
         mod(i,11)
    FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE functional_dependencies_multi;
---END---
---START---
-- estimates without any functional dependencies
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE a = 0 AND b = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE 0 = a AND 0 = b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE a = 0 AND b = 0 AND c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE 0 = a AND b = 0 AND 0 = c AND d = 0');
---END---
---START---
-- create separate functional dependencies
CREATE STATISTICS functional_dependencies_multi_1 (dependencies) ON a, b FROM functional_dependencies_multi;
---END---
---START---
CREATE STATISTICS functional_dependencies_multi_2 (dependencies) ON c, d FROM functional_dependencies_multi;
---END---
---START---
ANALYZE functional_dependencies_multi;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE a = 0 AND b = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE 0 = a AND 0 = b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE a = 0 AND b = 0 AND c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM functional_dependencies_multi WHERE 0 = a AND b = 0 AND 0 = c AND d = 0');
---END---
---START---
DROP TABLE functional_dependencies_multi;
---END---
---START---
-- MCV lists
CREATE TABLE mcv_lists (
    filler1 TEXT,
    filler2 NUMERIC,
    a INT,
    b VARCHAR,
    filler3 DATE,
    c INT,
    d TEXT,
    ia INT[]
)
WITH (autovacuum_enabled = off);
---END---
---START---
-- random data (no MCV list)
INSERT INTO mcv_lists (a, b, c, filler1)
     SELECT mod(i,37), mod(i,41), mod(i,43), mod(i,47) FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
-- create statistics
CREATE STATISTICS mcv_lists_stats (mcv) ON a, b, c FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
TRUNCATE mcv_lists;
---END---
---START---
DROP STATISTICS mcv_lists_stats;
---END---
---START---
-- random data (no MCV list), but with expression
INSERT INTO mcv_lists (a, b, c, filler1)
     SELECT i, i, i, i FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,7) = 1 AND mod(b::int,11) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,7) = 1 AND mod(b::int,11) = 1 AND mod(c,13) = 1');
---END---
---START---
-- create statistics
CREATE STATISTICS mcv_lists_stats (mcv) ON (mod(a,7)), (mod(b::int,11)), (mod(c,13)) FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,7) = 1 AND mod(b::int,11) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,7) = 1 AND mod(b::int,11) = 1 AND mod(c,13) = 1');
---END---
---START---
-- 100 distinct combinations, all in the MCV list
TRUNCATE mcv_lists;
---END---
---START---
DROP STATISTICS mcv_lists_stats;
---END---
---START---
INSERT INTO mcv_lists (a, b, c, ia, filler1)
     SELECT mod(i,100), mod(i,50), mod(i,25), array[mod(i,25)], i
       FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 = a AND ''1'' = b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < 1 AND b < ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 > a AND ''1'' > b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= 0 AND b <= ''0''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 0 >= a AND ''0'' >= b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < 5 AND b < ''1'' AND c < 5');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < 5 AND ''1'' > b AND 5 > c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= 4 AND b <= ''0'' AND c <= 4');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 4 >= a AND ''0'' >= b AND 4 >= c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''1'' OR c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''1'' OR c = 1 OR d IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IN (1, 2, 51, 52) AND b IN ( ''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IN (1, 2, 51, 52, NULL) AND b IN ( ''1'', ''2'', NULL)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = ANY (ARRAY[1, 2, 51, 52]) AND b = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = ANY (ARRAY[NULL, 1, 2, 51, 52]) AND b = ANY (ARRAY[''1'', ''2'', NULL])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= ANY (ARRAY[1, 2, 3]) AND b IN (''1'', ''2'', ''3'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= ANY (ARRAY[1, NULL, 2, 3]) AND b IN (''1'', ''2'', NULL, ''3'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND c > ANY (ARRAY[1, 2, 3])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND c > ANY (ARRAY[1, 2, 3, NULL])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND b IN (''1'', ''2'', ''3'') AND c > ANY (ARRAY[1, 2, 3])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND b IN (''1'', ''2'', NULL, ''3'') AND c > ANY (ARRAY[1, 2, NULL, 3])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = ANY (ARRAY[4,5]) AND 4 = ANY(ia)');
---END---
---START---
-- create statistics
CREATE STATISTICS mcv_lists_stats (mcv) ON a, b, c, ia FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 = a AND ''1'' = b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < 1 AND b < ''1''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 > a AND ''1'' > b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= 0 AND b <= ''0''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 0 >= a AND ''0'' >= b');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1'' AND c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < 5 AND b < ''1'' AND c < 5');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < 5 AND ''1'' > b AND 5 > c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= 4 AND b <= ''0'' AND c <= 4');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 4 >= a AND ''0'' >= b AND 4 >= c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''1'' OR c = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''1'' OR c = 1 OR d IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''1'' OR c = 1 OR d IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IN (1, 2, 51, 52) AND b IN ( ''1'', ''2'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IN (1, 2, 51, 52, NULL) AND b IN ( ''1'', ''2'', NULL)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = ANY (ARRAY[1, 2, 51, 52]) AND b = ANY (ARRAY[''1'', ''2''])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = ANY (ARRAY[NULL, 1, 2, 51, 52]) AND b = ANY (ARRAY[''1'', ''2'', NULL])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= ANY (ARRAY[1, 2, 3]) AND b IN (''1'', ''2'', ''3'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a <= ANY (ARRAY[1, NULL, 2, 3]) AND b IN (''1'', ''2'', NULL, ''3'')');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND c > ANY (ARRAY[1, 2, 3])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND c > ANY (ARRAY[1, 2, 3, NULL])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND b IN (''1'', ''2'', ''3'') AND c > ANY (ARRAY[1, 2, 3])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a < ALL (ARRAY[4, 5]) AND b IN (''1'', ''2'', NULL, ''3'') AND c > ANY (ARRAY[1, 2, NULL, 3])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = ANY (ARRAY[4,5]) AND 4 = ANY(ia)');
---END---
---START---
-- check change of unrelated column type does not reset the MCV statistics
ALTER TABLE mcv_lists ALTER COLUMN d TYPE VARCHAR(64);
---END---
---START---
SELECT d.stxdmcv IS NOT NULL
  FROM pg_statistic_ext s, pg_statistic_ext_data d
 WHERE s.stxname = 'mcv_lists_stats'
   AND d.stxoid = s.oid;
---END---
---START---
-- check change of column type resets the MCV statistics
ALTER TABLE mcv_lists ALTER COLUMN c TYPE numeric;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1''');
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 AND b = ''1''');
---END---
---START---
-- 100 distinct combinations, all in the MCV list, but with expressions
TRUNCATE mcv_lists;
---END---
---START---
DROP STATISTICS mcv_lists_stats;
---END---
---START---
INSERT INTO mcv_lists (a, b, c, filler1)
     SELECT i, i, i, i FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
-- without any stats on the expressions, we have to use default selectivities, which
-- is why the estimates here are different from the pre-computed case above

SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 AND mod(b::int,10) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 = mod(a,20) AND 1 = mod(b::int,10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) < 1 AND mod(b::int,10) < 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 > mod(a,20) AND 1 > mod(b::int,10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 AND mod(b::int,10) = 1 AND mod(c,5) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 OR mod(b::int,10) = 1 OR mod(c,25) = 1 OR d IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) IN (1, 2, 51, 52, NULL) AND mod(b::int,10) IN ( 1, 2, NULL)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = ANY (ARRAY[1, 2, 51, 52]) AND mod(b::int,10) = ANY (ARRAY[1, 2])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) <= ANY (ARRAY[1, NULL, 2, 3]) AND mod(b::int,10) IN (1, 2, NULL, 3)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) < ALL (ARRAY[4, 5]) AND mod(b::int,10) IN (1, 2, 3) AND mod(c,5) > ANY (ARRAY[1, 2, 3])');
---END---
---START---
-- create statistics with expressions only (we create three separate stats, in order not to build more complex extended stats)
CREATE STATISTICS mcv_lists_stats_1 ON (mod(a,20)) FROM mcv_lists;
---END---
---START---
CREATE STATISTICS mcv_lists_stats_2 ON (mod(b::int,10)) FROM mcv_lists;
---END---
---START---
CREATE STATISTICS mcv_lists_stats_3 ON (mod(c,5)) FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 AND mod(b::int,10) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 = mod(a,20) AND 1 = mod(b::int,10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) < 1 AND mod(b::int,10) < 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 > mod(a,20) AND 1 > mod(b::int,10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 AND mod(b::int,10) = 1 AND mod(c,5) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 OR mod(b::int,10) = 1 OR mod(c,25) = 1 OR d IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) IN (1, 2, 51, 52, NULL) AND mod(b::int,10) IN ( 1, 2, NULL)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = ANY (ARRAY[1, 2, 51, 52]) AND mod(b::int,10) = ANY (ARRAY[1, 2])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) <= ANY (ARRAY[1, NULL, 2, 3]) AND mod(b::int,10) IN (1, 2, NULL, 3)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) < ALL (ARRAY[4, 5]) AND mod(b::int,10) IN (1, 2, 3) AND mod(c,5) > ANY (ARRAY[1, 2, 3])');
---END---
---START---
DROP STATISTICS mcv_lists_stats_1;
---END---
---START---
DROP STATISTICS mcv_lists_stats_2;
---END---
---START---
DROP STATISTICS mcv_lists_stats_3;
---END---
---START---
-- create statistics with both MCV and expressions
CREATE STATISTICS mcv_lists_stats (mcv) ON (mod(a,20)), (mod(b::int,10)), (mod(c,5)) FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 AND mod(b::int,10) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 = mod(a,20) AND 1 = mod(b::int,10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) < 1 AND mod(b::int,10) < 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE 1 > mod(a,20) AND 1 > mod(b::int,10)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 AND mod(b::int,10) = 1 AND mod(c,5) = 1');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 OR mod(b::int,10) = 1 OR mod(c,25) = 1 OR d IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) IN (1, 2, 51, 52, NULL) AND mod(b::int,10) IN ( 1, 2, NULL)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = ANY (ARRAY[1, 2, 51, 52]) AND mod(b::int,10) = ANY (ARRAY[1, 2])');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) <= ANY (ARRAY[1, NULL, 2, 3]) AND mod(b::int,10) IN (1, 2, NULL, 3)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) < ALL (ARRAY[4, 5]) AND mod(b::int,10) IN (1, 2, 3) AND mod(c,5) > ANY (ARRAY[1, 2, 3])');
---END---
---START---
-- we can't use the statistic for OR clauses that are not fully covered (missing 'd' attribute)
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE mod(a,20) = 1 OR mod(b::int,10) = 1 OR mod(c,5) = 1 OR d IS NOT NULL');
---END---
---START---
-- 100 distinct combinations with NULL values, all in the MCV list
TRUNCATE mcv_lists;
---END---
---START---
DROP STATISTICS mcv_lists_stats;
---END---
---START---
INSERT INTO mcv_lists (a, b, c, filler1)
     SELECT
         (CASE WHEN mod(i,100) = 1 THEN NULL ELSE mod(i,100) END),
         (CASE WHEN mod(i,50) = 1  THEN NULL ELSE mod(i,50) END),
         (CASE WHEN mod(i,25) = 1  THEN NULL ELSE mod(i,25) END),
         i
     FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND b IS NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND b IS NULL AND c IS NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND b IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NOT NULL AND b IS NULL AND c IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IN (0, 1) AND b IN (''0'', ''1'')');
---END---
---START---
-- create statistics
CREATE STATISTICS mcv_lists_stats (mcv) ON a, b, c FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND b IS NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND b IS NULL AND c IS NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND b IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NOT NULL AND b IS NULL AND c IS NOT NULL');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IN (0, 1) AND b IN (''0'', ''1'')');
---END---
---START---
-- test pg_mcv_list_items with a very simple (single item) MCV list
TRUNCATE mcv_lists;
---END---
---START---
INSERT INTO mcv_lists (a, b, c) SELECT 1, 2, 3 FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT m.*
  FROM pg_statistic_ext s, pg_statistic_ext_data d,
       pg_mcv_list_items(d.stxdmcv) m
 WHERE s.stxname = 'mcv_lists_stats'
   AND d.stxoid = s.oid;
---END---
---START---
-- 2 distinct combinations with NULL values, all in the MCV list
TRUNCATE mcv_lists;
---END---
---START---
DROP STATISTICS mcv_lists_stats;
---END---
---START---
INSERT INTO mcv_lists (a, b, c, d)
     SELECT
         NULL, -- always NULL
         (CASE WHEN mod(i,2) = 0 THEN NULL ELSE 'x' END),
         (CASE WHEN mod(i,2) = 0 THEN NULL ELSE 0 END),
         (CASE WHEN mod(i,2) = 0 THEN NULL ELSE 'x' END)
     FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE b = ''x'' OR d = ''x''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''x'' OR d = ''x''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND (b = ''x'' OR d = ''x'')');
---END---
---START---
-- create statistics
CREATE STATISTICS mcv_lists_stats (mcv) ON a, b, d FROM mcv_lists;
---END---
---START---
ANALYZE mcv_lists;
---END---
---START---
-- test pg_mcv_list_items with MCV list containing variable-length data and NULLs
SELECT m.*
  FROM pg_statistic_ext s, pg_statistic_ext_data d,
       pg_mcv_list_items(d.stxdmcv) m
 WHERE s.stxname = 'mcv_lists_stats'
   AND d.stxoid = s.oid;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE b = ''x'' OR d = ''x''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a = 1 OR b = ''x'' OR d = ''x''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists WHERE a IS NULL AND (b = ''x'' OR d = ''x'')');
---END---
---START---
-- mcv with pass-by-ref fixlen types, e.g. uuid
CREATE TABLE mcv_lists_uuid (
    a UUID,
    b UUID,
    c UUID
)
WITH (autovacuum_enabled = off);
---END---
---START---
INSERT INTO mcv_lists_uuid (a, b, c)
     SELECT
         fipshash(mod(i,100)::text)::uuid,
         fipshash(mod(i,50)::text)::uuid,
         fipshash(mod(i,25)::text)::uuid
     FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE mcv_lists_uuid;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_uuid WHERE a = ''e7f6c011-776e-8db7-cd33-0b54174fd76f'' AND b = ''e7f6c011-776e-8db7-cd33-0b54174fd76f''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_uuid WHERE a = ''e7f6c011-776e-8db7-cd33-0b54174fd76f'' AND b = ''e7f6c011-776e-8db7-cd33-0b54174fd76f'' AND c = ''e7f6c011-776e-8db7-cd33-0b54174fd76f''');
---END---
---START---
CREATE STATISTICS mcv_lists_uuid_stats (mcv) ON a, b, c
  FROM mcv_lists_uuid;
---END---
---START---
ANALYZE mcv_lists_uuid;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_uuid WHERE a = ''e7f6c011-776e-8db7-cd33-0b54174fd76f'' AND b = ''e7f6c011-776e-8db7-cd33-0b54174fd76f''');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_uuid WHERE a = ''e7f6c011-776e-8db7-cd33-0b54174fd76f'' AND b = ''e7f6c011-776e-8db7-cd33-0b54174fd76f'' AND c = ''e7f6c011-776e-8db7-cd33-0b54174fd76f''');
---END---
---START---
DROP TABLE mcv_lists_uuid;
---END---
---START---
-- mcv with arrays
CREATE TABLE mcv_lists_arrays (
    a TEXT[],
    b NUMERIC[],
    c INT[]
)
WITH (autovacuum_enabled = off);
---END---
---START---
INSERT INTO mcv_lists_arrays (a, b, c)
     SELECT
         ARRAY[fipshash((i/100)::text), fipshash((i/100-1)::text), fipshash((i/100+1)::text)],
         ARRAY[(i/100-1)::numeric/1000, (i/100)::numeric/1000, (i/100+1)::numeric/1000],
         ARRAY[(i/100-1), i/100, (i/100+1)]
     FROM generate_series(1,5000) s(i);
---END---
---START---
CREATE STATISTICS mcv_lists_arrays_stats (mcv) ON a, b, c
  FROM mcv_lists_arrays;
---END---
---START---
ANALYZE mcv_lists_arrays;
---END---
---START---
-- mcv with bool
CREATE TABLE mcv_lists_bool (
    a BOOL,
    b BOOL,
    c BOOL
)
WITH (autovacuum_enabled = off);
---END---
---START---
INSERT INTO mcv_lists_bool (a, b, c)
     SELECT
         (mod(i,2) = 0), (mod(i,4) = 0), (mod(i,8) = 0)
     FROM generate_series(1,10000) s(i);
---END---
---START---
ANALYZE mcv_lists_bool;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE a AND b AND c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE NOT a AND b AND c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE NOT a AND NOT b AND c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE NOT a AND b AND NOT c');
---END---
---START---
CREATE STATISTICS mcv_lists_bool_stats (mcv) ON a, b, c
  FROM mcv_lists_bool;
---END---
---START---
ANALYZE mcv_lists_bool;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE a AND b AND c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE NOT a AND b AND c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE NOT a AND NOT b AND c');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_bool WHERE NOT a AND b AND NOT c');
---END---
---START---
-- mcv covering just a small fraction of data
CREATE TABLE mcv_lists_partial (
    a INT,
    b INT,
    c INT
);
---END---
---START---
-- 10 frequent groups, each with 100 elements
INSERT INTO mcv_lists_partial (a, b, c)
     SELECT
         mod(i,10),
         mod(i,10),
         mod(i,10)
     FROM generate_series(0,999) s(i);
---END---
---START---
-- 100 groups that will make it to the MCV list (includes the 10 frequent ones)
INSERT INTO mcv_lists_partial (a, b, c)
     SELECT
         i,
         i,
         i
     FROM generate_series(0,99) s(i);
---END---
---START---
-- 4000 groups in total, most of which won't make it (just a single item)
INSERT INTO mcv_lists_partial (a, b, c)
     SELECT
         i,
         i,
         i
     FROM generate_series(0,3999) s(i);
---END---
---START---
ANALYZE mcv_lists_partial;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 AND b = 0 AND c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 OR b = 0 OR c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 10 AND b = 10 AND c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 10 OR b = 10 OR c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 AND b = 0 AND c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 OR b = 0 OR c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE (a = 0 AND b = 0 AND c = 0) OR (a = 1 AND b = 1 AND c = 1) OR (a = 2 AND b = 2 AND c = 2)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE (a = 0 AND b = 0) OR (a = 0 AND c = 0) OR (b = 0 AND c = 0)');
---END---
---START---
CREATE STATISTICS mcv_lists_partial_stats (mcv) ON a, b, c
  FROM mcv_lists_partial;
---END---
---START---
ANALYZE mcv_lists_partial;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 AND b = 0 AND c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 OR b = 0 OR c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 10 AND b = 10 AND c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 10 OR b = 10 OR c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 AND b = 0 AND c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE a = 0 OR b = 0 OR c = 10');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE (a = 0 AND b = 0 AND c = 0) OR (a = 1 AND b = 1 AND c = 1) OR (a = 2 AND b = 2 AND c = 2)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_partial WHERE (a = 0 AND b = 0) OR (a = 0 AND c = 0) OR (b = 0 AND c = 0)');
---END---
---START---
DROP TABLE mcv_lists_partial;
---END---
---START---
-- check the ability to use multiple MCV lists
CREATE TABLE mcv_lists_multi (
	a INTEGER,
	b INTEGER,
	c INTEGER,
	d INTEGER
)
WITH (autovacuum_enabled = off);
---END---
---START---
INSERT INTO mcv_lists_multi (a, b, c, d)
    SELECT
         mod(i,5),
         mod(i,5),
         mod(i,7),
         mod(i,7)
    FROM generate_series(1,5000) s(i);
---END---
---START---
ANALYZE mcv_lists_multi;
---END---
---START---
-- estimates without any mcv statistics
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE a = 0 AND b = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE b = 0 AND c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE b = 0 OR c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE a = 0 AND b = 0 AND c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE (a = 0 AND b = 0) OR (c = 0 AND d = 0)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE a = 0 OR b = 0 OR c = 0 OR d = 0');
---END---
---START---
-- create separate MCV statistics
CREATE STATISTICS mcv_lists_multi_1 (mcv) ON a, b FROM mcv_lists_multi;
---END---
---START---
CREATE STATISTICS mcv_lists_multi_2 (mcv) ON c, d FROM mcv_lists_multi;
---END---
---START---
ANALYZE mcv_lists_multi;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE a = 0 AND b = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE b = 0 AND c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE b = 0 OR c = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE a = 0 AND b = 0 AND c = 0 AND d = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE (a = 0 AND b = 0) OR (c = 0 AND d = 0)');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM mcv_lists_multi WHERE a = 0 OR b = 0 OR c = 0 OR d = 0');
---END---
---START---
DROP TABLE mcv_lists_multi;
---END---
---START---
-- statistics on integer expressions
CREATE TABLE expr_stats (a int, b int, c int);
---END---
---START---
INSERT INTO expr_stats SELECT mod(i,10), mod(i,10), mod(i,10) FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE expr_stats;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE (2*a) = 0 AND (3*b) = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE (a+b) = 0 AND (a-b) = 0');
---END---
---START---
CREATE STATISTICS expr_stats_1 (mcv) ON (a+b), (a-b), (2*a), (3*b) FROM expr_stats;
---END---
---START---
ANALYZE expr_stats;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE (2*a) = 0 AND (3*b) = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE (a+b) = 0 AND (a-b) = 0');
---END---
---START---
DROP STATISTICS expr_stats_1;
---END---
---START---
DROP TABLE expr_stats;
---END---
---START---
-- statistics on a mix columns and expressions
CREATE TABLE expr_stats (a int, b int, c int);
---END---
---START---
INSERT INTO expr_stats SELECT mod(i,10), mod(i,10), mod(i,10) FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE expr_stats;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 0 AND (2*a) = 0 AND (3*b) = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 3 AND b = 3 AND (a-b) = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 0 AND b = 1 AND (a-b) = 0');
---END---
---START---
CREATE STATISTICS expr_stats_1 (mcv) ON a, b, (2*a), (3*b), (a+b), (a-b) FROM expr_stats;
---END---
---START---
ANALYZE expr_stats;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 0 AND (2*a) = 0 AND (3*b) = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 3 AND b = 3 AND (a-b) = 0');
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 0 AND b = 1 AND (a-b) = 0');
---END---
---START---
DROP TABLE expr_stats;
---END---
---START---
-- statistics on expressions with different data types
CREATE TABLE expr_stats (a int, b name, c text);
---END---
---START---
INSERT INTO expr_stats SELECT mod(i,10), fipshash(mod(i,10)::text), fipshash(mod(i,10)::text) FROM generate_series(1,1000) s(i);
---END---
---START---
ANALYZE expr_stats;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 0 AND (b || c) <= ''z'' AND (c || b) >= ''0''');
---END---
---START---
CREATE STATISTICS expr_stats_1 (mcv) ON a, b, (b || c), (c || b) FROM expr_stats;
---END---
---START---
ANALYZE expr_stats;
---END---
---START---
SELECT * FROM check_estimated_rows('SELECT * FROM expr_stats WHERE a = 0 AND (b || c) <= ''z'' AND (c || b) >= ''0''');
---END---
---START---
DROP TABLE expr_stats;
---END---
---START---
-- test handling of a mix of compatible and incompatible expressions
CREATE TABLE expr_stats_incompatible_test (
    c0 double precision,
    c1 boolean NOT NULL
);
---END---
---START---
CREATE STATISTICS expr_stat_comp_1 ON c0, c1 FROM expr_stats_incompatible_test;
---END---
---START---
INSERT INTO expr_stats_incompatible_test VALUES (1234,false), (5678,true);
---END---
---START---
ANALYZE expr_stats_incompatible_test;
---END---
---START---
SELECT c0 FROM ONLY expr_stats_incompatible_test WHERE
(
  upper('x') LIKE ('x'||('[0,1]'::int4range))
  AND
  (c0 IN (0, 1) OR c1)
);
---END---
---START---
DROP TABLE expr_stats_incompatible_test;
---END---
---START---
-- Permission tests. Users should not be able to see specific data values in
-- the extended statistics, if they lack permission to see those values in
-- the underlying table.
--
-- Currently this is only relevant for MCV stats.
CREATE SCHEMA tststats;
---END---
---START---
CREATE TABLE tststats.priv_test_tbl (
    a int,
    b int
);
---END---
---START---
INSERT INTO tststats.priv_test_tbl
     SELECT mod(i,5), mod(i,10) FROM generate_series(1,100) s(i);
---END---
---START---
CREATE STATISTICS tststats.priv_test_stats (mcv) ON a, b
  FROM tststats.priv_test_tbl;
---END---
---START---
ANALYZE tststats.priv_test_tbl;
---END---
---START---
-- Check printing info about extended statistics by \dX
create table stts_t1 (a int, b int);
---END---
---START---
create statistics (ndistinct) on a, b from stts_t1;
---END---
---START---
create statistics (ndistinct, dependencies) on a, b from stts_t1;
---END---
---START---
create statistics (ndistinct, dependencies, mcv) on a, b from stts_t1;
---END---
---START---
create table stts_t2 (a int, b int, c int);
---END---
---START---
create statistics on b, c from stts_t2;
---END---
---START---
create table stts_t3 (col1 int, col2 int, col3 int);
---END---
---START---
create statistics stts_hoge on col1, col2, col3 from stts_t3;
---END---
---START---
create schema stts_s1;
---END---
---START---
create schema stts_s2;
---END---
---START---
create statistics stts_s1.stts_foo on col1, col2 from stts_t3;
---END---
---START---
create statistics stts_s2.stts_yama (dependencies, mcv) on col1, col3 from stts_t3;
---END---
---START---
insert into stts_t1 select i,i from generate_series(1,100) i;
---END---
---START---
analyze stts_t1;
---END---
---START---
set search_path to public, stts_s1, stts_s2, tststats;
---END---
---START---
\dX
\dX stts_t*
\dX *stts_hoge
\dX+
\dX+ stts_t*
\dX+ *stts_hoge
\dX+ stts_s2.stts_yama

create statistics (mcv) ON a, b, (a+b), (a-b) FROM stts_t1;
---END---
---START---
create statistics (mcv) ON a, b, (a+b), (a-b) FROM stts_t1;
---END---
---START---
create statistics (mcv) ON (a+b), (a-b) FROM stts_t1;
---END---
---START---
\dX stts_t*expr*
drop statistics stts_t1_a_b_expr_expr_stat;
---END---
---START---
drop statistics stts_t1_a_b_expr_expr_stat1;
---END---
---START---
drop statistics stts_t1_expr_expr_stat;
---END---
---START---
set search_path to public, stts_s1;
---END---
---START---
\dX

create role regress_stats_ext nosuperuser;
---END---
---START---
set role regress_stats_ext;
---END---
---START---
\dX
reset role;
---END---
---START---
drop table stts_t1, stts_t2, stts_t3;
---END---
---START---
drop schema stts_s1, stts_s2 cascade;
---END---
---START---
drop user regress_stats_ext;
---END---
---START---
reset search_path;
---END---
---START---
-- User with no access
CREATE USER regress_stats_user1;
---END---
---START---
GRANT USAGE ON SCHEMA tststats TO regress_stats_user1;
---END---
---START---
SET SESSION AUTHORIZATION regress_stats_user1;
---END---
---START---
SELECT * FROM tststats.priv_test_tbl;
---END---
---START---
-- Permission denied

-- Check individual columns if we don't have table privilege
SELECT * FROM tststats.priv_test_tbl
  WHERE a = 1 and tststats.priv_test_tbl.* > (1, 1) is not null;
---END---
---START---
-- Attempt to gain access using a leaky operator
CREATE FUNCTION op_leak(int, int) RETURNS bool
    AS 'BEGIN RAISE NOTICE ''op_leak => %, %'', $1, $2; RETURN $1 < $2; END'
    LANGUAGE plpgsql;
---END---
---START---
CREATE OPERATOR <<< (procedure = op_leak, leftarg = int, rightarg = int,
                     restrict = scalarltsel);
---END---
---START---
SELECT * FROM tststats.priv_test_tbl WHERE a <<< 0 AND b <<< 0;
---END---
---START---
-- Permission denied
DELETE FROM tststats.priv_test_tbl WHERE a <<< 0 AND b <<< 0;
---END---
---START---
-- Permission denied

-- Grant access via a security barrier view, but hide all data
RESET SESSION AUTHORIZATION;
---END---
---START---
CREATE VIEW tststats.priv_test_view WITH (security_barrier=true)
    AS SELECT * FROM tststats.priv_test_tbl WHERE false;
---END---
---START---
GRANT SELECT, DELETE ON tststats.priv_test_view TO regress_stats_user1;
---END---
---START---
-- Should now have access via the view, but see nothing and leak nothing
SET SESSION AUTHORIZATION regress_stats_user1;
---END---
---START---
SELECT * FROM tststats.priv_test_view WHERE a <<< 0 AND b <<< 0;
---END---
---START---
-- Should not leak
DELETE FROM tststats.priv_test_view WHERE a <<< 0 AND b <<< 0;
---END---
---START---
-- Should not leak

-- Grant table access, but hide all data with RLS
RESET SESSION AUTHORIZATION;
---END---
---START---
ALTER TABLE tststats.priv_test_tbl ENABLE ROW LEVEL SECURITY;
---END---
---START---
GRANT SELECT, DELETE ON tststats.priv_test_tbl TO regress_stats_user1;
---END---
---START---
-- Should now have direct table access, but see nothing and leak nothing
SET SESSION AUTHORIZATION regress_stats_user1;
---END---
---START---
SELECT * FROM tststats.priv_test_tbl WHERE a <<< 0 AND b <<< 0;
---END---
---START---
-- Should not leak
DELETE FROM tststats.priv_test_tbl WHERE a <<< 0 AND b <<< 0;
---END---
---START---
-- Should not leak

-- Tidy up
DROP OPERATOR <<< (int, int);
---END---
---START---
DROP FUNCTION op_leak(int, int);
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP SCHEMA tststats CASCADE;
---END---
---START---
DROP USER regress_stats_user1;
---END---
