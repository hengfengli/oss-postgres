---START---
--
--  CLUSTER
--

CREATE TABLE clstr_tst_s (rf_a SERIAL PRIMARY KEY,
	b INT);
---END---
---START---
CREATE TABLE clstr_tst (a SERIAL PRIMARY KEY,
	b INT,
	c TEXT,
	d TEXT,
	CONSTRAINT clstr_tst_con FOREIGN KEY (b) REFERENCES clstr_tst_s);
---END---
---START---
CREATE INDEX clstr_tst_b ON clstr_tst (b);
---END---
---START---
CREATE INDEX clstr_tst_c ON clstr_tst (c);
---END---
---START---
CREATE INDEX clstr_tst_c_b ON clstr_tst (c,b);
---END---
---START---
CREATE INDEX clstr_tst_b_c ON clstr_tst (b,c);
---END---
---START---
INSERT INTO clstr_tst_s (b) VALUES (0);
---END---
---START---
INSERT INTO clstr_tst_s (b) SELECT b FROM clstr_tst_s;
---END---
---START---
INSERT INTO clstr_tst_s (b) SELECT b FROM clstr_tst_s;
---END---
---START---
INSERT INTO clstr_tst_s (b) SELECT b FROM clstr_tst_s;
---END---
---START---
INSERT INTO clstr_tst_s (b) SELECT b FROM clstr_tst_s;
---END---
---START---
INSERT INTO clstr_tst_s (b) SELECT b FROM clstr_tst_s;
---END---
---START---
CREATE TABLE clstr_tst_inh () INHERITS (clstr_tst);
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (11, 'once');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (10, 'diez');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (31, 'treinta y uno');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (22, 'veintidos');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (3, 'tres');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (20, 'veinte');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (23, 'veintitres');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (21, 'veintiuno');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (4, 'cuatro');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (14, 'catorce');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (2, 'dos');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (18, 'dieciocho');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (27, 'veintisiete');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (25, 'veinticinco');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (13, 'trece');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (28, 'veintiocho');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (32, 'treinta y dos');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (5, 'cinco');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (29, 'veintinueve');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (1, 'uno');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (24, 'veinticuatro');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (30, 'treinta');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (12, 'doce');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (17, 'diecisiete');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (9, 'nueve');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (19, 'diecinueve');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (26, 'veintiseis');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (15, 'quince');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (7, 'siete');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (16, 'dieciseis');
---END---
---START---
INSERT INTO clstr_tst (b, c) VALUES (8, 'ocho');
---END---
---START---
-- This entry is needed to test that TOASTED values are copied correctly.
INSERT INTO clstr_tst (b, c, d) VALUES (6, 'seis', repeat('xyzzy', 100000));
---END---
---START---
CLUSTER clstr_tst_c ON clstr_tst;
---END---
---START---
SELECT a,b,c,substring(d for 30), length(d) from clstr_tst;
---END---
---START---
SELECT a,b,c,substring(d for 30), length(d) from clstr_tst ORDER BY a;
---END---
---START---
SELECT a,b,c,substring(d for 30), length(d) from clstr_tst ORDER BY b;
---END---
---START---
SELECT a,b,c,substring(d for 30), length(d) from clstr_tst ORDER BY c;
---END---
---START---
-- Verify that inheritance link still works
INSERT INTO clstr_tst_inh VALUES (0, 100, 'in child table');
---END---
---START---
SELECT a,b,c,substring(d for 30), length(d) from clstr_tst;
---END---
---START---
-- Verify that foreign key link still works
INSERT INTO clstr_tst (b, c) VALUES (1111, 'this should fail');
---END---
---START---
SELECT conname FROM pg_constraint WHERE conrelid = 'clstr_tst'::regclass
ORDER BY 1;
---END---
---START---
SELECT relname, relkind,
    EXISTS(SELECT 1 FROM pg_class WHERE oid = c.reltoastrelid) AS hastoast
FROM pg_class c WHERE relname LIKE 'clstr_tst%' ORDER BY relname;
---END---
---START---
-- Verify that indisclustered is correctly set
SELECT pg_class.relname FROM pg_index, pg_class, pg_class AS pg_class_2
WHERE pg_class.oid=indexrelid
	AND indrelid=pg_class_2.oid
	AND pg_class_2.relname = 'clstr_tst'
	AND indisclustered;
---END---
---START---
-- Try changing indisclustered
ALTER TABLE clstr_tst CLUSTER ON clstr_tst_b_c;
---END---
---START---
SELECT pg_class.relname FROM pg_index, pg_class, pg_class AS pg_class_2
WHERE pg_class.oid=indexrelid
	AND indrelid=pg_class_2.oid
	AND pg_class_2.relname = 'clstr_tst'
	AND indisclustered;
---END---
---START---
-- Try turning off all clustering
ALTER TABLE clstr_tst SET WITHOUT CLUSTER;
---END---
---START---
SELECT pg_class.relname FROM pg_index, pg_class, pg_class AS pg_class_2
WHERE pg_class.oid=indexrelid
	AND indrelid=pg_class_2.oid
	AND pg_class_2.relname = 'clstr_tst'
	AND indisclustered;
---END---
---START---
-- Verify that toast tables are clusterable
CLUSTER pg_toast.pg_toast_826 USING pg_toast_826_index;
---END---
---START---
-- Verify that clustering all tables does in fact cluster the right ones
CREATE USER regress_clstr_user;
---END---
---START---
CREATE TABLE clstr_1 (a INT PRIMARY KEY);
---END---
---START---
CREATE TABLE clstr_2 (a INT PRIMARY KEY);
---END---
---START---
CREATE TABLE clstr_3 (a INT PRIMARY KEY);
---END---
---START---
ALTER TABLE clstr_1 OWNER TO regress_clstr_user;
---END---
---START---
ALTER TABLE clstr_3 OWNER TO regress_clstr_user;
---END---
---START---
GRANT SELECT ON clstr_2 TO regress_clstr_user;
---END---
---START---
INSERT INTO clstr_1 VALUES (2);
---END---
---START---
INSERT INTO clstr_1 VALUES (1);
---END---
---START---
INSERT INTO clstr_2 VALUES (2);
---END---
---START---
INSERT INTO clstr_2 VALUES (1);
---END---
---START---
INSERT INTO clstr_3 VALUES (2);
---END---
---START---
INSERT INTO clstr_3 VALUES (1);
---END---
---START---
-- "CLUSTER <tablename>" on a table that hasn't been clustered
CLUSTER clstr_2;
---END---
---START---
CLUSTER clstr_1_pkey ON clstr_1;
---END---
---START---
CLUSTER clstr_2 USING clstr_2_pkey;
---END---
---START---
SELECT * FROM clstr_1 UNION ALL
  SELECT * FROM clstr_2 UNION ALL
  SELECT * FROM clstr_3;
---END---
---START---
-- revert to the original state
DELETE FROM clstr_1;
---END---
---START---
DELETE FROM clstr_2;
---END---
---START---
DELETE FROM clstr_3;
---END---
---START---
INSERT INTO clstr_1 VALUES (2);
---END---
---START---
INSERT INTO clstr_1 VALUES (1);
---END---
---START---
INSERT INTO clstr_2 VALUES (2);
---END---
---START---
INSERT INTO clstr_2 VALUES (1);
---END---
---START---
INSERT INTO clstr_3 VALUES (2);
---END---
---START---
INSERT INTO clstr_3 VALUES (1);
---END---
---START---
-- this user can only cluster clstr_1 and clstr_3, but the latter
-- has not been clustered
SET SESSION AUTHORIZATION regress_clstr_user;
---END---
---START---
CLUSTER;
---END---
---START---
SELECT * FROM clstr_1 UNION ALL
  SELECT * FROM clstr_2 UNION ALL
  SELECT * FROM clstr_3;
---END---
---START---
-- cluster a single table using the indisclustered bit previously set
DELETE FROM clstr_1;
---END---
---START---
INSERT INTO clstr_1 VALUES (2);
---END---
---START---
INSERT INTO clstr_1 VALUES (1);
---END---
---START---
CLUSTER clstr_1;
---END---
---START---
SELECT * FROM clstr_1;
---END---
---START---
-- Test MVCC-safety of cluster. There isn't much we can do to verify the
-- results with a single backend...

CREATE TABLE clustertest (key int PRIMARY KEY);
---END---
---START---
INSERT INTO clustertest VALUES (10);
---END---
---START---
INSERT INTO clustertest VALUES (20);
---END---
---START---
INSERT INTO clustertest VALUES (30);
---END---
---START---
INSERT INTO clustertest VALUES (40);
---END---
---START---
INSERT INTO clustertest VALUES (50);
---END---
---START---
-- Use a transaction so that updates are not committed when CLUSTER sees 'em
BEGIN;
---END---
---START---
-- Test update where the old row version is found first in the scan
UPDATE clustertest SET key = 100 WHERE key = 10;
---END---
---START---
-- Test update where the new row version is found first in the scan
UPDATE clustertest SET key = 35 WHERE key = 40;
---END---
---START---
-- Test longer update chain
UPDATE clustertest SET key = 60 WHERE key = 50;
---END---
---START---
UPDATE clustertest SET key = 70 WHERE key = 60;
---END---
---START---
UPDATE clustertest SET key = 80 WHERE key = 70;
---END---
---START---
SELECT * FROM clustertest;
---END---
---START---
CLUSTER clustertest_pkey ON clustertest;
---END---
---START---
SELECT * FROM clustertest;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM clustertest;
---END---
---START---
-- check that temp tables can be clustered
create temp table clstr_temp (col1 int primary key, col2 text);
---END---
---START---
insert into clstr_temp values (2, 'two'), (1, 'one');
---END---
---START---
cluster clstr_temp using clstr_temp_pkey;
---END---
---START---
select * from clstr_temp;
---END---
---START---
drop table clstr_temp;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
-- check clustering an empty table
DROP TABLE clustertest;
---END---
---START---
CREATE TABLE clustertest (f1 int PRIMARY KEY);
---END---
---START---
CLUSTER clustertest USING clustertest_pkey;
---END---
---START---
CLUSTER clustertest;
---END---
---START---
-- Check that partitioned tables can be clustered
CREATE TABLE clstrpart (a int) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE clstrpart1 PARTITION OF clstrpart FOR VALUES FROM (1) TO (10) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE clstrpart11 PARTITION OF clstrpart1 FOR VALUES FROM (1) TO (5);
---END---
---START---
CREATE TABLE clstrpart12 PARTITION OF clstrpart1 FOR VALUES FROM (5) TO (10) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE clstrpart2 PARTITION OF clstrpart FOR VALUES FROM (10) TO (20);
---END---
---START---
CREATE TABLE clstrpart3 PARTITION OF clstrpart DEFAULT PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE clstrpart33 PARTITION OF clstrpart3 DEFAULT;
---END---
---START---
CREATE INDEX clstrpart_only_idx ON ONLY clstrpart (a);
---END---
---START---
CLUSTER clstrpart USING clstrpart_only_idx;
---END---
---START---
-- fails
DROP INDEX clstrpart_only_idx;
---END---
---START---
CREATE INDEX clstrpart_idx ON clstrpart (a);
---END---
---START---
-- Check that clustering sets new relfilenodes:
CREATE TEMP TABLE old_cluster_info AS SELECT relname, level, relfilenode, relkind FROM pg_partition_tree('clstrpart'::regclass) AS tree JOIN pg_class c ON c.oid=tree.relid;
---END---
---START---
CLUSTER clstrpart USING clstrpart_idx;
---END---
---START---
CREATE TEMP TABLE new_cluster_info AS SELECT relname, level, relfilenode, relkind FROM pg_partition_tree('clstrpart'::regclass) AS tree JOIN pg_class c ON c.oid=tree.relid;
---END---
---START---
SELECT relname, old.level, old.relkind, old.relfilenode = new.relfilenode FROM old_cluster_info AS old JOIN new_cluster_info AS new USING (relname) ORDER BY relname COLLATE "C";
---END---
---START---
-- Partitioned indexes aren't and can't be marked un/clustered:
\d clstrpart
CLUSTER clstrpart;
---END---
---START---
ALTER TABLE clstrpart SET WITHOUT CLUSTER;
---END---
---START---
ALTER TABLE clstrpart CLUSTER ON clstrpart_idx;
---END---
---START---
DROP TABLE clstrpart;
---END---
---START---
-- Ownership of partitions is checked
CREATE TABLE ptnowner(i int unique) PARTITION BY LIST (i);
---END---
---START---
CREATE INDEX ptnowner_i_idx ON ptnowner(i);
---END---
---START---
CREATE TABLE ptnowner1 PARTITION OF ptnowner FOR VALUES IN (1);
---END---
---START---
CREATE ROLE regress_ptnowner;
---END---
---START---
CREATE TABLE ptnowner2 PARTITION OF ptnowner FOR VALUES IN (2);
---END---
---START---
ALTER TABLE ptnowner1 OWNER TO regress_ptnowner;
---END---
---START---
ALTER TABLE ptnowner OWNER TO regress_ptnowner;
---END---
---START---
CREATE TEMP TABLE ptnowner_oldnodes AS
  SELECT oid, relname, relfilenode FROM pg_partition_tree('ptnowner') AS tree
  JOIN pg_class AS c ON c.oid=tree.relid;
---END---
---START---
SET SESSION AUTHORIZATION regress_ptnowner;
---END---
---START---
CLUSTER ptnowner USING ptnowner_i_idx;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
SELECT a.relname, a.relfilenode=b.relfilenode FROM pg_class a
  JOIN ptnowner_oldnodes b USING (oid) ORDER BY a.relname COLLATE "C";
---END---
---START---
DROP TABLE ptnowner;
---END---
---START---
DROP ROLE regress_ptnowner;
---END---
---START---
-- Test CLUSTER with external tuplesorting

create table clstr_4 as select * from tenk1;
---END---
---START---
create index cluster_sort on clstr_4 (hundred, thousand, tenthous);
---END---
---START---
-- ensure we don't use the index in CLUSTER nor the checking SELECTs
set enable_indexscan = off;
---END---
---START---
-- Use external sort:
set maintenance_work_mem = '1MB';
---END---
---START---
cluster clstr_4 using cluster_sort;
---END---
---START---
select * from
(select hundred, lag(hundred) over () as lhundred,
        thousand, lag(thousand) over () as lthousand,
        tenthous, lag(tenthous) over () as ltenthous from clstr_4) ss
where row(hundred, thousand, tenthous) <= row(lhundred, lthousand, ltenthous);
---END---
---START---
reset enable_indexscan;
---END---
---START---
reset maintenance_work_mem;
---END---
---START---
-- test CLUSTER on expression index
CREATE TABLE clstr_expression(id serial primary key, a int, b text COLLATE "C");
---END---
---START---
INSERT INTO clstr_expression(a, b) SELECT g.i % 42, 'prefix'||g.i FROM generate_series(1, 133) g(i);
---END---
---START---
CREATE INDEX clstr_expression_minus_a ON clstr_expression ((-a), b);
---END---
---START---
CREATE INDEX clstr_expression_upper_b ON clstr_expression ((upper(b)));
---END---
---START---
-- verify indexes work before cluster
BEGIN;
---END---
---START---
SET LOCAL enable_seqscan = false;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM clstr_expression WHERE upper(b) = 'PREFIX3';
---END---
---START---
SELECT * FROM clstr_expression WHERE upper(b) = 'PREFIX3';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM clstr_expression WHERE -a = -3 ORDER BY -a, b;
---END---
---START---
SELECT * FROM clstr_expression WHERE -a = -3 ORDER BY -a, b;
---END---
---START---
COMMIT;
---END---
---START---
-- and after clustering on clstr_expression_minus_a
CLUSTER clstr_expression USING clstr_expression_minus_a;
---END---
---START---
WITH rows AS
  (SELECT ctid, lag(a) OVER (ORDER BY ctid) AS la, a FROM clstr_expression)
SELECT * FROM rows WHERE la < a;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL enable_seqscan = false;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM clstr_expression WHERE upper(b) = 'PREFIX3';
---END---
---START---
SELECT * FROM clstr_expression WHERE upper(b) = 'PREFIX3';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM clstr_expression WHERE -a = -3 ORDER BY -a, b;
---END---
---START---
SELECT * FROM clstr_expression WHERE -a = -3 ORDER BY -a, b;
---END---
---START---
COMMIT;
---END---
---START---
-- and after clustering on clstr_expression_upper_b
CLUSTER clstr_expression USING clstr_expression_upper_b;
---END---
---START---
WITH rows AS
  (SELECT ctid, lag(b) OVER (ORDER BY ctid) AS lb, b FROM clstr_expression)
SELECT * FROM rows WHERE upper(lb) > upper(b);
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL enable_seqscan = false;
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM clstr_expression WHERE upper(b) = 'PREFIX3';
---END---
---START---
SELECT * FROM clstr_expression WHERE upper(b) = 'PREFIX3';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM clstr_expression WHERE -a = -3 ORDER BY -a, b;
---END---
---START---
SELECT * FROM clstr_expression WHERE -a = -3 ORDER BY -a, b;
---END---
---START---
COMMIT;
---END---
---START---
-- clean up
DROP TABLE clustertest;
---END---
---START---
DROP TABLE clstr_1;
---END---
---START---
DROP TABLE clstr_2;
---END---
---START---
DROP TABLE clstr_3;
---END---
---START---
DROP TABLE clstr_4;
---END---
---START---
DROP TABLE clstr_expression;
---END---
---START---
DROP USER regress_clstr_user;
---END---
