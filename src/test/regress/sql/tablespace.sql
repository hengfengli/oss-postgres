---START---
-- relative tablespace locations are not allowed
CREATE TABLESPACE regress_tblspace LOCATION 'relative'; -- fail

-- empty tablespace locations are not usually allowed
CREATE TABLESPACE regress_tblspace LOCATION ''; -- fail

-- as a special developer-only option to allow us to use tablespaces
-- with streaming replication on the same server, an empty location
-- can be allowed as a way to say that the tablespace should be created
-- as a directory in pg_tblspc, rather than being a symlink
SET allow_in_place_tablespaces = true;
---END---
---START---

-- create a tablespace using WITH clause
CREATE TABLESPACE regress_tblspacewith LOCATION '' WITH (some_nonexistent_parameter = true); -- fail
CREATE TABLESPACE regress_tblspacewith LOCATION '' WITH (random_page_cost = 3.0); -- ok

-- check to see the parameter was used
SELECT spcoptions FROM pg_tablespace WHERE spcname = 'regress_tblspacewith';
---END---
---START---

-- drop the tablespace so we can re-use the location
DROP TABLESPACE regress_tblspacewith;
---END---
---START---

-- This returns a relative path as of an effect of allow_in_place_tablespaces,
-- masking the tablespace OID used in the path name.
SELECT regexp_replace(pg_tablespace_location(oid), '(pg_tblspc)/(\d+)', '\1/NNN')
  FROM pg_tablespace  WHERE spcname = 'regress_tblspace';
---END---
---START---

-- try setting and resetting some properties for the new tablespace
ALTER TABLESPACE regress_tblspace SET (random_page_cost = 1.0, seq_page_cost = 1.1);
---END---
---START---
ALTER TABLESPACE regress_tblspace SET (some_nonexistent_parameter = true);  -- fail
ALTER TABLESPACE regress_tblspace RESET (random_page_cost = 2.0); -- fail
ALTER TABLESPACE regress_tblspace RESET (random_page_cost, effective_io_concurrency); -- ok

-- REINDEX (TABLESPACE)
-- catalogs and system tablespaces
-- system catalog, fail
REINDEX (TABLESPACE regress_tblspace) TABLE pg_am;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) TABLE CONCURRENTLY pg_am;
---END---
---START---
-- shared catalog, fail
REINDEX (TABLESPACE regress_tblspace) TABLE pg_authid;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) TABLE CONCURRENTLY pg_authid;
---END---
---START---
-- toast relations, fail
REINDEX (TABLESPACE regress_tblspace) INDEX pg_toast.pg_toast_1260_index;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) INDEX CONCURRENTLY pg_toast.pg_toast_1260_index;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) TABLE pg_toast.pg_toast_1260;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) TABLE CONCURRENTLY pg_toast.pg_toast_1260;
---END---
---START---
-- system catalog, fail
REINDEX (TABLESPACE pg_global) TABLE pg_authid;
---END---
---START---
REINDEX (TABLESPACE pg_global) TABLE CONCURRENTLY pg_authid;
---END---
---START---

-- table with toast relation
CREATE TABLE regress_tblspace_test_tbl (num1 bigint, num2 double precision, t text);
---END---
---START---
INSERT INTO regress_tblspace_test_tbl (num1, num2, t)
  SELECT round(random()*100), random(), 'text'
  FROM generate_series(1, 10) s(i);
---END---
---START---
CREATE INDEX regress_tblspace_test_tbl_idx ON regress_tblspace_test_tbl (num1);
---END---
---START---
-- move to global tablespace, fail
REINDEX (TABLESPACE pg_global) INDEX regress_tblspace_test_tbl_idx;
---END---
---START---
REINDEX (TABLESPACE pg_global) INDEX CONCURRENTLY regress_tblspace_test_tbl_idx;
---END---
---START---

-- check transactional behavior of REINDEX (TABLESPACE)
BEGIN;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) INDEX regress_tblspace_test_tbl_idx;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) TABLE regress_tblspace_test_tbl;
---END---
---START---
ROLLBACK;
---END---
---START---
-- no relation moved to the new tablespace
SELECT c.relname FROM pg_class c, pg_tablespace s
  WHERE c.reltablespace = s.oid AND s.spcname = 'regress_tblspace';
---END---
---START---

-- check that all indexes are moved to a new tablespace with different
-- relfilenode.
-- Save first the existing relfilenode for the toast and main relations.
SELECT relfilenode as main_filenode FROM pg_class
  WHERE relname = 'regress_tblspace_test_tbl_idx' \gset
SELECT relfilenode as toast_filenode FROM pg_class
  WHERE oid =
    (SELECT i.indexrelid
       FROM pg_class c,
            pg_index i
       WHERE i.indrelid = c.reltoastrelid AND
             c.relname = 'regress_tblspace_test_tbl') \gset
REINDEX (TABLESPACE regress_tblspace) TABLE regress_tblspace_test_tbl;
---END---
---START---
SELECT c.relname FROM pg_class c, pg_tablespace s
  WHERE c.reltablespace = s.oid AND s.spcname = 'regress_tblspace'
  ORDER BY c.relname;
---END---
---START---
ALTER TABLE regress_tblspace_test_tbl SET TABLESPACE regress_tblspace;
---END---
---START---
ALTER TABLE regress_tblspace_test_tbl SET TABLESPACE pg_default;
---END---
---START---
SELECT c.relname FROM pg_class c, pg_tablespace s
  WHERE c.reltablespace = s.oid AND s.spcname = 'regress_tblspace'
  ORDER BY c.relname;
---END---
---START---
-- Move back to the default tablespace.
ALTER INDEX regress_tblspace_test_tbl_idx SET TABLESPACE pg_default;
---END---
---START---
SELECT c.relname FROM pg_class c, pg_tablespace s
  WHERE c.reltablespace = s.oid AND s.spcname = 'regress_tblspace'
  ORDER BY c.relname;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace, CONCURRENTLY) TABLE regress_tblspace_test_tbl;
---END---
---START---
SELECT c.relname FROM pg_class c, pg_tablespace s
  WHERE c.reltablespace = s.oid AND s.spcname = 'regress_tblspace'
  ORDER BY c.relname;
---END---
---START---
SELECT relfilenode = :main_filenode AS main_same FROM pg_class
  WHERE relname = 'regress_tblspace_test_tbl_idx';
---END---
---START---
SELECT relfilenode = :toast_filenode as toast_same FROM pg_class
  WHERE oid =
    (SELECT i.indexrelid
       FROM pg_class c,
            pg_index i
       WHERE i.indrelid = c.reltoastrelid AND
             c.relname = 'regress_tblspace_test_tbl');
---END---
---START---
DROP TABLE regress_tblspace_test_tbl;
---END---
---START---

-- REINDEX (TABLESPACE) with partitions
-- Create a partition tree and check the set of relations reindexed
-- with their new tablespace.
CREATE TABLE tbspace_reindex_part (c1 int, c2 int) PARTITION BY RANGE (c1);
---END---
---START---
CREATE TABLE tbspace_reindex_part_0 PARTITION OF tbspace_reindex_part
  FOR VALUES FROM (0) TO (10) PARTITION BY list (c2);
---END---
---START---
CREATE TABLE tbspace_reindex_part_0_1 PARTITION OF tbspace_reindex_part_0
  FOR VALUES IN (1);
---END---
---START---
CREATE TABLE tbspace_reindex_part_0_2 PARTITION OF tbspace_reindex_part_0
  FOR VALUES IN (2);
---END---
---START---
-- This partitioned table will have no partitions.
CREATE TABLE tbspace_reindex_part_10 PARTITION OF tbspace_reindex_part
   FOR VALUES FROM (10) TO (20) PARTITION BY list (c2);
---END---
---START---
-- Create some partitioned indexes
CREATE INDEX tbspace_reindex_part_index ON ONLY tbspace_reindex_part (c1);
---END---
---START---
CREATE INDEX tbspace_reindex_part_index_0 ON ONLY tbspace_reindex_part_0 (c1);
---END---
---START---
ALTER INDEX tbspace_reindex_part_index ATTACH PARTITION tbspace_reindex_part_index_0;
---END---
---START---
-- This partitioned index will have no partitions.
CREATE INDEX tbspace_reindex_part_index_10 ON ONLY tbspace_reindex_part_10 (c1);
---END---
---START---
ALTER INDEX tbspace_reindex_part_index ATTACH PARTITION tbspace_reindex_part_index_10;
---END---
---START---
CREATE INDEX tbspace_reindex_part_index_0_1 ON ONLY tbspace_reindex_part_0_1 (c1);
---END---
---START---
ALTER INDEX tbspace_reindex_part_index_0 ATTACH PARTITION tbspace_reindex_part_index_0_1;
---END---
---START---
CREATE INDEX tbspace_reindex_part_index_0_2 ON ONLY tbspace_reindex_part_0_2 (c1);
---END---
---START---
ALTER INDEX tbspace_reindex_part_index_0 ATTACH PARTITION tbspace_reindex_part_index_0_2;
---END---
---START---
SELECT relid, parentrelid, level FROM pg_partition_tree('tbspace_reindex_part_index')
  ORDER BY relid, level;
---END---
---START---
-- Track the original tablespace, relfilenode and OID of each index
-- in the tree.
CREATE TABLE reindex_temp_before AS
  SELECT oid, relname, relfilenode, reltablespace
  FROM pg_class
    WHERE relname ~ 'tbspace_reindex_part_index';
---END---
---START---
REINDEX (TABLESPACE regress_tblspace, CONCURRENTLY) TABLE tbspace_reindex_part;
---END---
---START---
-- REINDEX CONCURRENTLY changes the OID of the old relation, hence a check
-- based on the relation name below.
SELECT b.relname,
       CASE WHEN a.relfilenode = b.relfilenode THEN 'relfilenode is unchanged'
       ELSE 'relfilenode has changed' END AS filenode,
       CASE WHEN a.reltablespace = b.reltablespace THEN 'reltablespace is unchanged'
       ELSE 'reltablespace has changed' END AS tbspace
  FROM reindex_temp_before b JOIN pg_class a ON b.relname = a.relname
  ORDER BY 1;
---END---
---START---
DROP TABLE tbspace_reindex_part;
---END---
---START---

-- create a schema we can use
CREATE SCHEMA testschema;
---END---
---START---

-- try a table
CREATE TABLE testschema.foo (i int) TABLESPACE regress_tblspace;
---END---
---START---
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'foo';
---END---
---START---

INSERT INTO testschema.foo VALUES(1);
---END---
---START---
INSERT INTO testschema.foo VALUES(2);
---END---
---START---

-- tables from dynamic sources
CREATE TABLE testschema.asselect TABLESPACE regress_tblspace AS SELECT 1;
---END---
---START---
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'asselect';
---END---
---START---

PREPARE selectsource(int) AS SELECT $1;
---END---
---START---
CREATE TABLE testschema.asexecute TABLESPACE regress_tblspace
    AS EXECUTE selectsource(2);
---END---
---START---
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'asexecute';
---END---
---START---

-- index
CREATE INDEX foo_idx on testschema.foo(i) TABLESPACE regress_tblspace;
---END---
---START---
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'foo_idx';
---END---
---START---

-- check \d output
\d testschema.foo
\d testschema.foo_idx

--
-- partitioned table
--
CREATE TABLE testschema.part (a int) PARTITION BY LIST (a);
---END---
---START---
SET default_tablespace TO pg_global;
---END---
---START---
CREATE TABLE testschema.part_1 PARTITION OF testschema.part FOR VALUES IN (1);
---END---
---START---
RESET default_tablespace;
---END---
---START---
CREATE TABLE testschema.part_1 PARTITION OF testschema.part FOR VALUES IN (1);
---END---
---START---
SET default_tablespace TO regress_tblspace;
---END---
---START---
CREATE TABLE testschema.part_2 PARTITION OF testschema.part FOR VALUES IN (2);
---END---
---START---
SET default_tablespace TO pg_global;
---END---
---START---
CREATE TABLE testschema.part_3 PARTITION OF testschema.part FOR VALUES IN (3);
---END---
---START---
ALTER TABLE testschema.part SET TABLESPACE regress_tblspace;
---END---
---START---
CREATE TABLE testschema.part_3 PARTITION OF testschema.part FOR VALUES IN (3);
---END---
---START---
CREATE TABLE testschema.part_4 PARTITION OF testschema.part FOR VALUES IN (4)
  TABLESPACE pg_default;
---END---
---START---
CREATE TABLE testschema.part_56 PARTITION OF testschema.part FOR VALUES IN (5, 6)
  PARTITION BY LIST (a);
---END---
---START---
ALTER TABLE testschema.part SET TABLESPACE pg_default;
---END---
---START---
CREATE TABLE testschema.part_78 PARTITION OF testschema.part FOR VALUES IN (7, 8)
  PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE testschema.part_910 PARTITION OF testschema.part FOR VALUES IN (9, 10)
  PARTITION BY LIST (a) TABLESPACE regress_tblspace;
---END---
---START---
RESET default_tablespace;
---END---
---START---
CREATE TABLE testschema.part_78 PARTITION OF testschema.part FOR VALUES IN (7, 8)
  PARTITION BY LIST (a);
---END---
---START---

SELECT relname, spcname FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid)
    LEFT JOIN pg_catalog.pg_tablespace t ON c.reltablespace = t.oid
    where c.relname LIKE 'part%' AND n.nspname = 'testschema' order by relname;
---END---
---START---
RESET default_tablespace;
---END---
---START---
DROP TABLE testschema.part;
---END---
---START---

-- partitioned index
CREATE TABLE testschema.part (a int) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE testschema.part1 PARTITION OF testschema.part FOR VALUES IN (1);
---END---
---START---
CREATE INDEX part_a_idx ON testschema.part (a) TABLESPACE regress_tblspace;
---END---
---START---
CREATE TABLE testschema.part2 PARTITION OF testschema.part FOR VALUES IN (2);
---END---
---START---
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname LIKE 'part%_idx' ORDER BY relname;
---END---
---START---
\d testschema.part
\d+ testschema.part
\d testschema.part1
\d+ testschema.part1
\d testschema.part_a_idx
\d+ testschema.part_a_idx

-- partitioned rels cannot specify the default tablespace.  These fail:
CREATE TABLE testschema.dflt (a int PRIMARY KEY) PARTITION BY LIST (a) TABLESPACE pg_default;
---END---
---START---
CREATE TABLE testschema.dflt (a int PRIMARY KEY USING INDEX TABLESPACE pg_default) PARTITION BY LIST (a);
---END---
---START---
SET default_tablespace TO 'pg_default';
---END---
---START---
CREATE TABLE testschema.dflt (a int PRIMARY KEY) PARTITION BY LIST (a) TABLESPACE regress_tblspace;
---END---
---START---
CREATE TABLE testschema.dflt (a int PRIMARY KEY USING INDEX TABLESPACE regress_tblspace) PARTITION BY LIST (a);
---END---
---START---
-- but these work:
CREATE TABLE testschema.dflt (a int PRIMARY KEY USING INDEX TABLESPACE regress_tblspace) PARTITION BY LIST (a) TABLESPACE regress_tblspace;
---END---
---START---
SET default_tablespace TO '';
---END---
---START---
CREATE TABLE testschema.dflt2 (a int PRIMARY KEY) PARTITION BY LIST (a);
---END---
---START---
DROP TABLE testschema.dflt, testschema.dflt2;
---END---
---START---

-- check that default_tablespace doesn't affect ALTER TABLE index rebuilds
CREATE TABLE testschema.test_default_tab(id bigint) TABLESPACE regress_tblspace;
---END---
---START---
INSERT INTO testschema.test_default_tab VALUES (1);
---END---
---START---
CREATE INDEX test_index1 on testschema.test_default_tab (id);
---END---
---START---
CREATE INDEX test_index2 on testschema.test_default_tab (id) TABLESPACE regress_tblspace;
---END---
---START---
ALTER TABLE testschema.test_default_tab ADD CONSTRAINT test_index3 PRIMARY KEY (id);
---END---
---START---
ALTER TABLE testschema.test_default_tab ADD CONSTRAINT test_index4 UNIQUE (id) USING INDEX TABLESPACE regress_tblspace;
---END---
---START---

\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
-- use a custom tablespace for default_tablespace
SET default_tablespace TO regress_tblspace;
---END---
---START---
-- tablespace should not change if no rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE bigint;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
SELECT * FROM testschema.test_default_tab;
---END---
---START---
-- tablespace should not change even if there is an index rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE int;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
SELECT * FROM testschema.test_default_tab;
---END---
---START---
-- now use the default tablespace for default_tablespace
SET default_tablespace TO '';
---END---
---START---
-- tablespace should not change if no rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE int;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
-- tablespace should not change even if there is an index rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE bigint;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
DROP TABLE testschema.test_default_tab;
---END---
---START---

-- check that default_tablespace doesn't affect ALTER TABLE index rebuilds
-- (this time with a partitioned table)
CREATE TABLE testschema.test_default_tab_p(id bigint, val bigint)
    PARTITION BY LIST (id) TABLESPACE regress_tblspace;
---END---
---START---
CREATE TABLE testschema.test_default_tab_p1 PARTITION OF testschema.test_default_tab_p
    FOR VALUES IN (1);
---END---
---START---
INSERT INTO testschema.test_default_tab_p VALUES (1);
---END---
---START---
CREATE INDEX test_index1 on testschema.test_default_tab_p (val);
---END---
---START---
CREATE INDEX test_index2 on testschema.test_default_tab_p (val) TABLESPACE regress_tblspace;
---END---
---START---
ALTER TABLE testschema.test_default_tab_p ADD CONSTRAINT test_index3 PRIMARY KEY (id);
---END---
---START---
ALTER TABLE testschema.test_default_tab_p ADD CONSTRAINT test_index4 UNIQUE (id) USING INDEX TABLESPACE regress_tblspace;
---END---
---START---

\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
-- use a custom tablespace for default_tablespace
SET default_tablespace TO regress_tblspace;
---END---
---START---
-- tablespace should not change if no rewrite
ALTER TABLE testschema.test_default_tab_p ALTER val TYPE bigint;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
SELECT * FROM testschema.test_default_tab_p;
---END---
---START---
-- tablespace should not change even if there is an index rewrite
ALTER TABLE testschema.test_default_tab_p ALTER val TYPE int;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
SELECT * FROM testschema.test_default_tab_p;
---END---
---START---
-- now use the default tablespace for default_tablespace
SET default_tablespace TO '';
---END---
---START---
-- tablespace should not change if no rewrite
ALTER TABLE testschema.test_default_tab_p ALTER val TYPE int;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
-- tablespace should not change even if there is an index rewrite
ALTER TABLE testschema.test_default_tab_p ALTER val TYPE bigint;
---END---
---START---
\d testschema.test_index1
\d testschema.test_index2
\d testschema.test_index3
\d testschema.test_index4
DROP TABLE testschema.test_default_tab_p;
---END---
---START---

-- check that default_tablespace affects index additions in ALTER TABLE
CREATE TABLE testschema.test_tab(id int) TABLESPACE regress_tblspace;
---END---
---START---
INSERT INTO testschema.test_tab VALUES (1);
---END---
---START---
SET default_tablespace TO regress_tblspace;
---END---
---START---
ALTER TABLE testschema.test_tab ADD CONSTRAINT test_tab_unique UNIQUE (id);
---END---
---START---
SET default_tablespace TO '';
---END---
---START---
ALTER TABLE testschema.test_tab ADD CONSTRAINT test_tab_pkey PRIMARY KEY (id);
---END---
---START---
\d testschema.test_tab_unique
\d testschema.test_tab_pkey
SELECT * FROM testschema.test_tab;
---END---
---START---
DROP TABLE testschema.test_tab;
---END---
---START---

-- check that default_tablespace is handled correctly by multi-command
-- ALTER TABLE that includes a tablespace-preserving rewrite
CREATE TABLE testschema.test_tab(a int, b int, c int);
---END---
---START---
SET default_tablespace TO regress_tblspace;
---END---
---START---
ALTER TABLE testschema.test_tab ADD CONSTRAINT test_tab_unique UNIQUE (a);
---END---
---START---
CREATE INDEX test_tab_a_idx ON testschema.test_tab (a);
---END---
---START---
SET default_tablespace TO '';
---END---
---START---
CREATE INDEX test_tab_b_idx ON testschema.test_tab (b);
---END---
---START---
\d testschema.test_tab_unique
\d testschema.test_tab_a_idx
\d testschema.test_tab_b_idx
ALTER TABLE testschema.test_tab ALTER b TYPE bigint, ADD UNIQUE (c);
---END---
---START---
\d testschema.test_tab_unique
\d testschema.test_tab_a_idx
\d testschema.test_tab_b_idx
DROP TABLE testschema.test_tab;
---END---
---START---

-- let's try moving a table from one place to another
CREATE TABLE testschema.atable AS VALUES (1), (2);
---END---
---START---
CREATE UNIQUE INDEX anindex ON testschema.atable(column1);
---END---
---START---

ALTER TABLE testschema.atable SET TABLESPACE regress_tblspace;
---END---
---START---
ALTER INDEX testschema.anindex SET TABLESPACE regress_tblspace;
---END---
---START---
ALTER INDEX testschema.part_a_idx SET TABLESPACE pg_global;
---END---
---START---
ALTER INDEX testschema.part_a_idx SET TABLESPACE pg_default;
---END---
---START---
ALTER INDEX testschema.part_a_idx SET TABLESPACE regress_tblspace;
---END---
---START---

INSERT INTO testschema.atable VALUES(3);	-- ok
INSERT INTO testschema.atable VALUES(1);	-- fail (checks index)
SELECT COUNT(*) FROM testschema.atable;		-- checks heap

-- let's try moving a materialized view from one place to another
CREATE MATERIALIZED VIEW testschema.amv AS SELECT * FROM testschema.atable;
---END---
---START---
ALTER MATERIALIZED VIEW testschema.amv SET TABLESPACE regress_tblspace;
---END---
---START---
REFRESH MATERIALIZED VIEW testschema.amv;
---END---
---START---
SELECT COUNT(*) FROM testschema.amv;
---END---
---START---

-- Will fail with bad path
CREATE TABLESPACE regress_badspace LOCATION '/no/such/location';
---END---
---START---

-- No such tablespace
CREATE TABLE bar (i int) TABLESPACE regress_nosuchspace;
---END---
---START---

-- Fail, in use for some partitioned object
DROP TABLESPACE regress_tblspace;
---END---
---START---
ALTER INDEX testschema.part_a_idx SET TABLESPACE pg_default;
---END---
---START---
-- Fail, not empty
DROP TABLESPACE regress_tblspace;
---END---
---START---

CREATE ROLE regress_tablespace_user1 login;
---END---
---START---
CREATE ROLE regress_tablespace_user2 login;
---END---
---START---
GRANT USAGE ON SCHEMA testschema TO regress_tablespace_user2;
---END---
---START---

ALTER TABLESPACE regress_tblspace OWNER TO regress_tablespace_user1;
---END---
---START---

CREATE TABLE testschema.tablespace_acl (c int);
---END---
---START---
-- new owner lacks permission to create this index from scratch
CREATE INDEX k ON testschema.tablespace_acl (c) TABLESPACE regress_tblspace;
---END---
---START---
ALTER TABLE testschema.tablespace_acl OWNER TO regress_tablespace_user2;
---END---
---START---

SET SESSION ROLE regress_tablespace_user2;
---END---
---START---
CREATE TABLE tablespace_table (i int) TABLESPACE regress_tblspace; -- fail
ALTER TABLE testschema.tablespace_acl ALTER c TYPE bigint;
---END---
---START---
REINDEX (TABLESPACE regress_tblspace) TABLE tablespace_table; -- fail
REINDEX (TABLESPACE regress_tblspace, CONCURRENTLY) TABLE tablespace_table; -- fail
RESET ROLE;
---END---
---START---

ALTER TABLESPACE regress_tblspace RENAME TO regress_tblspace_renamed;
---END---
---START---

ALTER TABLE ALL IN TABLESPACE regress_tblspace_renamed SET TABLESPACE pg_default;
---END---
---START---
ALTER INDEX ALL IN TABLESPACE regress_tblspace_renamed SET TABLESPACE pg_default;
---END---
---START---
ALTER MATERIALIZED VIEW ALL IN TABLESPACE regress_tblspace_renamed SET TABLESPACE pg_default;
---END---
---START---

-- Should show notice that nothing was done
ALTER TABLE ALL IN TABLESPACE regress_tblspace_renamed SET TABLESPACE pg_default;
---END---
---START---
ALTER MATERIALIZED VIEW ALL IN TABLESPACE regress_tblspace_renamed SET TABLESPACE pg_default;
---END---
---START---

-- Should succeed
DROP TABLESPACE regress_tblspace_renamed;
---END---
---START---

DROP SCHEMA testschema CASCADE;
---END---
---START---

DROP ROLE regress_tablespace_user1;
---END---
---START---
DROP ROLE regress_tablespace_user2;
---END---
---START---
drop table reindex_temp_before;
---END---