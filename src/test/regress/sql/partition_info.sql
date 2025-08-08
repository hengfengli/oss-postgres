---START---
--
-- Tests for functions providing information about partitions
--
SELECT * FROM pg_partition_tree(NULL);
---END---
---START---
SELECT * FROM pg_partition_tree(0);
---END---
---START---
SELECT * FROM pg_partition_ancestors(NULL);
---END---
---START---
SELECT * FROM pg_partition_ancestors(0);
---END---
---START---
SELECT pg_partition_root(NULL);
---END---
---START---
SELECT pg_partition_root(0);
---END---
---START---
CREATE TABLE ptif_test (gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE ptif_test0 PARTITION OF ptif_test
  FOR VALUES FROM (minvalue) TO (0) PARTITION BY list (b);
---END---
---START---
CREATE TABLE ptif_test01 PARTITION OF ptif_test0 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE ptif_test1 PARTITION OF ptif_test
  FOR VALUES FROM (0) TO (100) PARTITION BY list (b);
---END---
---START---
CREATE TABLE ptif_test11 PARTITION OF ptif_test1 FOR VALUES IN (1);
---END---
---START---
CREATE TABLE ptif_test2 PARTITION OF ptif_test
  FOR VALUES FROM (100) TO (200);
---END---
---START---
-- This partitioned table should remain with no partitions.
CREATE TABLE ptif_test3 PARTITION OF ptif_test
  FOR VALUES FROM (200) TO (maxvalue) PARTITION BY list (b);
---END---
---START---
-- Test pg_partition_root for tables
SELECT pg_partition_root('ptif_test');
---END---
---START---
SELECT pg_partition_root('ptif_test0');
---END---
---START---
SELECT pg_partition_root('ptif_test01');
---END---
---START---
SELECT pg_partition_root('ptif_test3');
---END---
---START---
-- Test index partition tree
CREATE INDEX ptif_test_index ON ONLY ptif_test (a);
---END---
---START---
CREATE INDEX ptif_test0_index ON ONLY ptif_test0 (a);
---END---
---START---
ALTER INDEX ptif_test_index ATTACH PARTITION ptif_test0_index;
---END---
---START---
CREATE INDEX ptif_test01_index ON ptif_test01 (a);
---END---
---START---
ALTER INDEX ptif_test0_index ATTACH PARTITION ptif_test01_index;
---END---
---START---
CREATE INDEX ptif_test1_index ON ONLY ptif_test1 (a);
---END---
---START---
ALTER INDEX ptif_test_index ATTACH PARTITION ptif_test1_index;
---END---
---START---
CREATE INDEX ptif_test11_index ON ptif_test11 (a);
---END---
---START---
ALTER INDEX ptif_test1_index ATTACH PARTITION ptif_test11_index;
---END---
---START---
CREATE INDEX ptif_test2_index ON ptif_test2 (a);
---END---
---START---
ALTER INDEX ptif_test_index ATTACH PARTITION ptif_test2_index;
---END---
---START---
CREATE INDEX ptif_test3_index ON ptif_test3 (a);
---END---
---START---
ALTER INDEX ptif_test_index ATTACH PARTITION ptif_test3_index;
---END---
---START---
-- Test pg_partition_root for indexes
SELECT pg_partition_root('ptif_test_index');
---END---
---START---
SELECT pg_partition_root('ptif_test0_index');
---END---
---START---
SELECT pg_partition_root('ptif_test01_index');
---END---
---START---
SELECT pg_partition_root('ptif_test3_index');
---END---
---START---
-- List all tables members of the tree
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test');
---END---
---START---
-- List tables from an intermediate level
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test0') p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List from leaf table
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test01') p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List from partitioned table with no partitions
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test3') p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List all ancestors of root and leaf tables
SELECT * FROM pg_partition_ancestors('ptif_test01');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_test');
---END---
---START---
-- List all members using pg_partition_root with leaf table reference
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree(pg_partition_root('ptif_test01')) p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List all indexes members of the tree
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test_index');
---END---
---START---
-- List indexes from an intermediate level
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test0_index') p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List from leaf index
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test01_index') p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List from partitioned index with no partitions
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_test3_index') p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List all members using pg_partition_root with leaf index reference
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree(pg_partition_root('ptif_test01_index')) p
  JOIN pg_class c ON (p.relid = c.oid);
---END---
---START---
-- List all ancestors of root and leaf indexes
SELECT * FROM pg_partition_ancestors('ptif_test01_index');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_test_index');
---END---
---START---
DROP TABLE ptif_test;
---END---
---START---
CREATE TABLE ptif_normal_table (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
SELECT relid, parentrelid, level, isleaf
  FROM pg_partition_tree('ptif_normal_table');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_normal_table');
---END---
---START---
SELECT pg_partition_root('ptif_normal_table');
---END---
---START---
DROP TABLE ptif_normal_table;
---END---
---START---
-- Various partitioning-related functions return empty/NULL if passed relations
-- of types that cannot be part of a partition tree; for example, views,
-- materialized views, legacy inheritance children or parents, etc.
CREATE VIEW ptif_test_view AS SELECT 1;
---END---
---START---
CREATE MATERIALIZED VIEW ptif_test_matview AS SELECT 1;
---END---
---START---
CREATE TABLE ptif_li_parent (gemini_pk serial PRIMARY KEY);
---END---
---START---
CREATE TABLE ptif_li_child (gemini_pk serial PRIMARY KEY) INHERITS (ptif_li_parent);
---END---
---START---
SELECT * FROM pg_partition_tree('ptif_test_view');
---END---
---START---
SELECT * FROM pg_partition_tree('ptif_test_matview');
---END---
---START---
SELECT * FROM pg_partition_tree('ptif_li_parent');
---END---
---START---
SELECT * FROM pg_partition_tree('ptif_li_child');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_test_view');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_test_matview');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_li_parent');
---END---
---START---
SELECT * FROM pg_partition_ancestors('ptif_li_child');
---END---
---START---
SELECT pg_partition_root('ptif_test_view');
---END---
---START---
SELECT pg_partition_root('ptif_test_matview');
---END---
---START---
SELECT pg_partition_root('ptif_li_parent');
---END---
---START---
SELECT pg_partition_root('ptif_li_child');
---END---
---START---
DROP VIEW ptif_test_view;
---END---
---START---
DROP MATERIALIZED VIEW ptif_test_matview;
---END---
---START---
DROP TABLE ptif_li_parent, ptif_li_child;
---END---
