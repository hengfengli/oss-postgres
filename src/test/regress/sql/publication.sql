---START---
--
-- PUBLICATION
--
CREATE ROLE regress_publication_user LOGIN SUPERUSER;
---END---
---START---
CREATE ROLE regress_publication_user2;
---END---
---START---
CREATE ROLE regress_publication_user_dummy LOGIN NOSUPERUSER;
---END---
---START---
SET SESSION AUTHORIZATION 'regress_publication_user';
---END---
---START---

-- suppress warning that depends on wal_level
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_default;
---END---
---START---
RESET client_min_messages;
---END---
---START---

COMMENT ON PUBLICATION testpub_default IS 'test publication';
---END---
---START---
SELECT obj_description(p.oid, 'pg_publication') FROM pg_publication p;
---END---
---START---

SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpib_ins_trunct WITH (publish = insert);
---END---
---START---
RESET client_min_messages;
---END---
---START---

ALTER PUBLICATION testpub_default SET (publish = update);
---END---
---START---

-- error cases
CREATE PUBLICATION testpub_xxx WITH (foo);
---END---
---START---
CREATE PUBLICATION testpub_xxx WITH (publish = 'cluster, vacuum');
---END---
---START---
CREATE PUBLICATION testpub_xxx WITH (publish_via_partition_root = 'true', publish_via_partition_root = '0');
---END---
---START---

\dRp

ALTER PUBLICATION testpub_default SET (publish = 'insert, update, delete');
---END---
---START---

\dRp

--- adding tables
CREATE SCHEMA pub_test;
---END---
---START---
CREATE TABLE testpub_tbl1 (id serial primary key, data text);
---END---
---START---
CREATE TABLE pub_test.testpub_nopk (foo int, bar int);
---END---
---START---
CREATE VIEW testpub_view AS SELECT 1;
---END---
---START---
CREATE TABLE testpub_parted (a int) PARTITION BY LIST (a);
---END---
---START---

SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_foralltables FOR ALL TABLES WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---
ALTER PUBLICATION testpub_foralltables SET (publish = 'insert, update');
---END---
---START---

CREATE TABLE testpub_tbl2 (id serial primary key, data text);
---END---
---START---
-- fail - can't add to for all tables publication
ALTER PUBLICATION testpub_foralltables ADD TABLE testpub_tbl2;
---END---
---START---
-- fail - can't drop from all tables publication
ALTER PUBLICATION testpub_foralltables DROP TABLE testpub_tbl2;
---END---
---START---
-- fail - can't add to for all tables publication
ALTER PUBLICATION testpub_foralltables SET TABLE pub_test.testpub_nopk;
---END---
---START---

-- fail - can't add schema to 'FOR ALL TABLES' publication
ALTER PUBLICATION testpub_foralltables ADD TABLES IN SCHEMA pub_test;
---END---
---START---
-- fail - can't drop schema from 'FOR ALL TABLES' publication
ALTER PUBLICATION testpub_foralltables DROP TABLES IN SCHEMA pub_test;
---END---
---START---
-- fail - can't set schema to 'FOR ALL TABLES' publication
ALTER PUBLICATION testpub_foralltables SET TABLES IN SCHEMA pub_test;
---END---
---START---

SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_fortable FOR TABLE testpub_tbl1;
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- should be able to add schema to 'FOR TABLE' publication
ALTER PUBLICATION testpub_fortable ADD TABLES IN SCHEMA pub_test;
---END---
---START---
\dRp+ testpub_fortable
-- should be able to drop schema from 'FOR TABLE' publication
ALTER PUBLICATION testpub_fortable DROP TABLES IN SCHEMA pub_test;
---END---
---START---
\dRp+ testpub_fortable
-- should be able to set schema to 'FOR TABLE' publication
ALTER PUBLICATION testpub_fortable SET TABLES IN SCHEMA pub_test;
---END---
---START---
\dRp+ testpub_fortable

SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_forschema FOR TABLES IN SCHEMA pub_test;
---END---
---START---
-- should be able to create publication with schema and table of the same
-- schema
CREATE PUBLICATION testpub_for_tbl_schema FOR TABLES IN SCHEMA pub_test, TABLE pub_test.testpub_nopk;
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub_for_tbl_schema

-- weird parser corner case
CREATE PUBLICATION testpub_parsertst FOR TABLE pub_test.testpub_nopk, CURRENT_SCHEMA;
---END---
---START---
CREATE PUBLICATION testpub_parsertst FOR TABLES IN SCHEMA foo, test.foo;
---END---
---START---

-- should be able to add a table of the same schema to the schema publication
ALTER PUBLICATION testpub_forschema ADD TABLE pub_test.testpub_nopk;
---END---
---START---
\dRp+ testpub_forschema

-- should be able to drop the table
ALTER PUBLICATION testpub_forschema DROP TABLE pub_test.testpub_nopk;
---END---
---START---
\dRp+ testpub_forschema

-- fail - can't drop a table from the schema publication which isn't in the
-- publication
ALTER PUBLICATION testpub_forschema DROP TABLE pub_test.testpub_nopk;
---END---
---START---
-- should be able to set table to schema publication
ALTER PUBLICATION testpub_forschema SET TABLE pub_test.testpub_nopk;
---END---
---START---
\dRp+ testpub_forschema

SELECT pubname, puballtables FROM pg_publication WHERE pubname = 'testpub_foralltables';
---END---
---START---
\d+ testpub_tbl2
\dRp+ testpub_foralltables

DROP TABLE testpub_tbl2;
---END---
---START---
DROP PUBLICATION testpub_foralltables, testpub_fortable, testpub_forschema, testpub_for_tbl_schema;
---END---
---START---

CREATE TABLE testpub_tbl3 (a int);
---END---
---START---
CREATE TABLE testpub_tbl3a (b text) INHERITS (testpub_tbl3);
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub3 FOR TABLE testpub_tbl3;
---END---
---START---
CREATE PUBLICATION testpub4 FOR TABLE ONLY testpub_tbl3;
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub3
\dRp+ testpub4

DROP TABLE testpub_tbl3, testpub_tbl3a;
---END---
---START---
DROP PUBLICATION testpub3, testpub4;
---END---
---START---

-- Tests for partitioned tables
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_forparted;
---END---
---START---
CREATE PUBLICATION testpub_forparted1;
---END---
---START---
RESET client_min_messages;
---END---
---START---
CREATE TABLE testpub_parted1 (LIKE testpub_parted);
---END---
---START---
CREATE TABLE testpub_parted2 (LIKE testpub_parted);
---END---
---START---
ALTER PUBLICATION testpub_forparted1 SET (publish='insert');
---END---
---START---
ALTER TABLE testpub_parted ATTACH PARTITION testpub_parted1 FOR VALUES IN (1);
---END---
---START---
ALTER TABLE testpub_parted ATTACH PARTITION testpub_parted2 FOR VALUES IN (2);
---END---
---START---
-- works despite missing REPLICA IDENTITY, because updates are not replicated
UPDATE testpub_parted1 SET a = 1;
---END---
---START---
-- only parent is listed as being in publication, not the partition
ALTER PUBLICATION testpub_forparted ADD TABLE testpub_parted;
---END---
---START---
\dRp+ testpub_forparted
-- works despite missing REPLICA IDENTITY, because no actual update happened
UPDATE testpub_parted SET a = 1 WHERE false;
---END---
---START---
-- should now fail, because parent's publication replicates updates
UPDATE testpub_parted1 SET a = 1;
---END---
---START---
ALTER TABLE testpub_parted DETACH PARTITION testpub_parted1;
---END---
---START---
-- works again, because parent's publication is no longer considered
UPDATE testpub_parted1 SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub_forparted SET (publish_via_partition_root = true);
---END---
---START---
\dRp+ testpub_forparted
-- still fail, because parent's publication replicates updates
UPDATE testpub_parted2 SET a = 2;
---END---
---START---
ALTER PUBLICATION testpub_forparted DROP TABLE testpub_parted;
---END---
---START---
-- works again, because update is no longer replicated
UPDATE testpub_parted2 SET a = 2;
---END---
---START---
DROP TABLE testpub_parted1, testpub_parted2;
---END---
---START---
DROP PUBLICATION testpub_forparted, testpub_forparted1;
---END---
---START---

-- Tests for row filters
CREATE TABLE testpub_rf_tbl1 (a integer, b text);
---END---
---START---
CREATE TABLE testpub_rf_tbl2 (c text, d integer);
---END---
---START---
CREATE TABLE testpub_rf_tbl3 (e integer);
---END---
---START---
CREATE TABLE testpub_rf_tbl4 (g text);
---END---
---START---
CREATE TABLE testpub_rf_tbl5 (a xml);
---END---
---START---
CREATE SCHEMA testpub_rf_schema1;
---END---
---START---
CREATE TABLE testpub_rf_schema1.testpub_rf_tbl5 (h integer);
---END---
---START---
CREATE SCHEMA testpub_rf_schema2;
---END---
---START---
CREATE TABLE testpub_rf_schema2.testpub_rf_tbl6 (i integer);
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
-- Firstly, test using the option publish='insert' because the row filter
-- validation of referenced columns is less strict than for delete/update.
CREATE PUBLICATION testpub5 FOR TABLE testpub_rf_tbl1, testpub_rf_tbl2 WHERE (c <> 'test' AND d < 5) WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub5
\d testpub_rf_tbl3
ALTER PUBLICATION testpub5 ADD TABLE testpub_rf_tbl3 WHERE (e > 1000 AND e < 2000);
---END---
---START---
\dRp+ testpub5
\d testpub_rf_tbl3
ALTER PUBLICATION testpub5 DROP TABLE testpub_rf_tbl2;
---END---
---START---
\dRp+ testpub5
-- remove testpub_rf_tbl1 and add testpub_rf_tbl3 again (another WHERE expression)
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl3 WHERE (e > 300 AND e < 500);
---END---
---START---
\dRp+ testpub5
\d testpub_rf_tbl3
-- test \d <tablename> (now it displays filter information)
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_rf_yes FOR TABLE testpub_rf_tbl1 WHERE (a > 1) WITH (publish = 'insert');
---END---
---START---
CREATE PUBLICATION testpub_rf_no FOR TABLE testpub_rf_tbl1;
---END---
---START---
RESET client_min_messages;
---END---
---START---
\d testpub_rf_tbl1
DROP PUBLICATION testpub_rf_yes, testpub_rf_no;
---END---
---START---
-- some more syntax tests to exercise other parser pathways
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_syntax1 FOR TABLE testpub_rf_tbl1, ONLY testpub_rf_tbl3 WHERE (e < 999) WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub_syntax1
DROP PUBLICATION testpub_syntax1;
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_syntax2 FOR TABLE testpub_rf_tbl1, testpub_rf_schema1.testpub_rf_tbl5 WHERE (h < 999) WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub_syntax2
DROP PUBLICATION testpub_syntax2;
---END---
---START---
-- fail - schemas don't allow WHERE clause
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_syntax3 FOR TABLES IN SCHEMA testpub_rf_schema1 WHERE (a = 123);
---END---
---START---
CREATE PUBLICATION testpub_syntax3 FOR TABLES IN SCHEMA testpub_rf_schema1, testpub_rf_schema1 WHERE (a = 123);
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- fail - duplicate tables are not allowed if that table has any WHERE clause
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_dups FOR TABLE testpub_rf_tbl1 WHERE (a = 1), testpub_rf_tbl1 WITH (publish = 'insert');
---END---
---START---
CREATE PUBLICATION testpub_dups FOR TABLE testpub_rf_tbl1, testpub_rf_tbl1 WHERE (a = 2) WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- fail - publication WHERE clause must be boolean
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl3 WHERE (1234);
---END---
---START---
-- fail - aggregate functions not allowed in WHERE clause
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl3 WHERE (e < AVG(e));
---END---
---START---
-- fail - user-defined operators are not allowed
CREATE FUNCTION testpub_rf_func1(integer, integer) RETURNS boolean AS $$ SELECT hashint4($1) > $2 $$ LANGUAGE SQL;
---END---
---START---
CREATE OPERATOR =#> (PROCEDURE = testpub_rf_func1, LEFTARG = integer, RIGHTARG = integer);
---END---
---START---
CREATE PUBLICATION testpub6 FOR TABLE testpub_rf_tbl3 WHERE (e =#> 27);
---END---
---START---
-- fail - user-defined functions are not allowed
CREATE FUNCTION testpub_rf_func2() RETURNS integer AS $$ BEGIN RETURN 123; END; $$ LANGUAGE plpgsql;
---END---
---START---
ALTER PUBLICATION testpub5 ADD TABLE testpub_rf_tbl1 WHERE (a >= testpub_rf_func2());
---END---
---START---
-- fail - non-immutable functions are not allowed. random() is volatile.
ALTER PUBLICATION testpub5 ADD TABLE testpub_rf_tbl1 WHERE (a < random());
---END---
---START---
-- fail - user-defined collations are not allowed
CREATE COLLATION user_collation FROM "C";
---END---
---START---
ALTER PUBLICATION testpub5 ADD TABLE testpub_rf_tbl1 WHERE (b < '2' COLLATE user_collation);
---END---
---START---
-- ok - NULLIF is allowed
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (NULLIF(1,2) = a);
---END---
---START---
-- ok - built-in operators are allowed
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (a IS NULL);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE ((a > 5) IS FALSE);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (a IS DISTINCT FROM 5);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE ((a, a + 1) < (2, 3));
---END---
---START---
-- ok - built-in type coercions between two binary compatible datatypes are allowed
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (b::varchar < '2');
---END---
---START---
-- ok - immutable built-in functions are allowed
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl4 WHERE (length(g) < 6);
---END---
---START---
-- fail - user-defined types are not allowed
CREATE TYPE rf_bug_status AS ENUM ('new', 'open', 'closed');
---END---
---START---
CREATE TABLE rf_bug (id serial, description text, status rf_bug_status);
---END---
---START---
CREATE PUBLICATION testpub6 FOR TABLE rf_bug WHERE (status = 'open') WITH (publish = 'insert');
---END---
---START---
DROP TABLE rf_bug;
---END---
---START---
DROP TYPE rf_bug_status;
---END---
---START---
-- fail - row filter expression is not simple
CREATE PUBLICATION testpub6 FOR TABLE testpub_rf_tbl1 WHERE (a IN (SELECT generate_series(1,5)));
---END---
---START---
-- fail - system columns are not allowed
CREATE PUBLICATION testpub6 FOR TABLE testpub_rf_tbl1 WHERE ('(0,1)'::tid = ctid);
---END---
---START---
-- ok - conditional expressions are allowed
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl5 WHERE (a IS DOCUMENT);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl5 WHERE (xmlexists('//foo[text() = ''bar'']' PASSING BY VALUE a));
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (NULLIF(1, 2) = a);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (CASE a WHEN 5 THEN true ELSE false END);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (COALESCE(b, 'foo') = 'foo');
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (GREATEST(a, 10) > 10);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (a IN (2, 4, 6));
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (ARRAY[a] <@ ARRAY[2, 4, 6]);
---END---
---START---
ALTER PUBLICATION testpub5 SET TABLE testpub_rf_tbl1 WHERE (ROW(a, 2) IS NULL);
---END---
---START---
-- fail - WHERE not allowed in DROP
ALTER PUBLICATION testpub5 DROP TABLE testpub_rf_tbl1 WHERE (e < 27);
---END---
---START---
-- fail - cannot ALTER SET table which is a member of a pre-existing schema
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub6 FOR TABLES IN SCHEMA testpub_rf_schema2;
---END---
---START---
-- should be able to set publication with schema and table of the same schema
ALTER PUBLICATION testpub6 SET TABLES IN SCHEMA testpub_rf_schema2, TABLE testpub_rf_schema2.testpub_rf_tbl6 WHERE (i < 99);
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub6

DROP TABLE testpub_rf_tbl1;
---END---
---START---
DROP TABLE testpub_rf_tbl2;
---END---
---START---
DROP TABLE testpub_rf_tbl3;
---END---
---START---
DROP TABLE testpub_rf_tbl4;
---END---
---START---
DROP TABLE testpub_rf_tbl5;
---END---
---START---
DROP TABLE testpub_rf_schema1.testpub_rf_tbl5;
---END---
---START---
DROP TABLE testpub_rf_schema2.testpub_rf_tbl6;
---END---
---START---
DROP SCHEMA testpub_rf_schema1;
---END---
---START---
DROP SCHEMA testpub_rf_schema2;
---END---
---START---
DROP PUBLICATION testpub5;
---END---
---START---
DROP PUBLICATION testpub6;
---END---
---START---
DROP OPERATOR =#>(integer, integer);
---END---
---START---
DROP FUNCTION testpub_rf_func1(integer, integer);
---END---
---START---
DROP FUNCTION testpub_rf_func2();
---END---
---START---
DROP COLLATION user_collation;
---END---
---START---

-- ======================================================
-- More row filter tests for validating column references
CREATE TABLE rf_tbl_abcd_nopk(a int, b int, c int, d int);
---END---
---START---
CREATE TABLE rf_tbl_abcd_pk(a int, b int, c int, d int, PRIMARY KEY(a,b));
---END---
---START---
CREATE TABLE rf_tbl_abcd_part_pk (a int PRIMARY KEY, b int) PARTITION by RANGE (a);
---END---
---START---
CREATE TABLE rf_tbl_abcd_part_pk_1 (b int, a int PRIMARY KEY);
---END---
---START---
ALTER TABLE rf_tbl_abcd_part_pk ATTACH PARTITION rf_tbl_abcd_part_pk_1 FOR VALUES FROM (1) TO (10);
---END---
---START---

-- Case 1. REPLICA IDENTITY DEFAULT (means use primary key or nothing)
-- 1a. REPLICA IDENTITY is DEFAULT and table has a PK.
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub6 FOR TABLE rf_tbl_abcd_pk WHERE (a > 99);
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- ok - "a" is a PK col
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (b > 99);
---END---
---START---
-- ok - "b" is a PK col
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (c > 99);
---END---
---START---
-- fail - "c" is not part of the PK
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (d > 99);
---END---
---START---
-- fail - "d" is not part of the PK
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
-- 1b. REPLICA IDENTITY is DEFAULT and table has no PK
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk WHERE (a > 99);
---END---
---START---
-- fail - "a" is not part of REPLICA IDENTITY
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Case 2. REPLICA IDENTITY FULL
ALTER TABLE rf_tbl_abcd_pk REPLICA IDENTITY FULL;
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk REPLICA IDENTITY FULL;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (c > 99);
---END---
---START---
-- ok - "c" is in REPLICA IDENTITY now even though not in PK
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk WHERE (a > 99);
---END---
---START---
-- ok - "a" is in REPLICA IDENTITY now
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Case 3. REPLICA IDENTITY NOTHING
ALTER TABLE rf_tbl_abcd_pk REPLICA IDENTITY NOTHING;
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk REPLICA IDENTITY NOTHING;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (a > 99);
---END---
---START---
-- fail - "a" is in PK but it is not part of REPLICA IDENTITY NOTHING
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (c > 99);
---END---
---START---
-- fail - "c" is not in PK and not in REPLICA IDENTITY NOTHING
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk WHERE (a > 99);
---END---
---START---
-- fail - "a" is not in REPLICA IDENTITY NOTHING
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Case 4. REPLICA IDENTITY INDEX
ALTER TABLE rf_tbl_abcd_pk ALTER COLUMN c SET NOT NULL;
---END---
---START---
CREATE UNIQUE INDEX idx_abcd_pk_c ON rf_tbl_abcd_pk(c);
---END---
---START---
ALTER TABLE rf_tbl_abcd_pk REPLICA IDENTITY USING INDEX idx_abcd_pk_c;
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk ALTER COLUMN c SET NOT NULL;
---END---
---START---
CREATE UNIQUE INDEX idx_abcd_nopk_c ON rf_tbl_abcd_nopk(c);
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk REPLICA IDENTITY USING INDEX idx_abcd_nopk_c;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (a > 99);
---END---
---START---
-- fail - "a" is in PK but it is not part of REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk WHERE (c > 99);
---END---
---START---
-- ok - "c" is not in PK but it is part of REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk WHERE (a > 99);
---END---
---START---
-- fail - "a" is not in REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk WHERE (c > 99);
---END---
---START---
-- ok - "c" is part of REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Tests for partitioned table

-- set PUBLISH_VIA_PARTITION_ROOT to false and test row filter for partitioned
-- table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- fail - cannot use row filter for partitioned table
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk WHERE (a > 99);
---END---
---START---
-- ok - can use row filter for partition
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk_1 WHERE (a > 99);
---END---
---START---
-- ok - "a" is a PK col
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---
-- set PUBLISH_VIA_PARTITION_ROOT to true and test row filter for partitioned
-- table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
-- ok - can use row filter for partitioned table
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk WHERE (a > 99);
---END---
---START---
-- ok - "a" is a PK col
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---
-- fail - cannot set PUBLISH_VIA_PARTITION_ROOT to false if any row filter is
-- used for partitioned table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- remove partitioned table's row filter
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk;
---END---
---START---
-- ok - we don't have row filter for partitioned table.
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- Now change the root filter to use a column "b"
-- (which is not in the replica identity)
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk_1 WHERE (b > 99);
---END---
---START---
-- ok - we don't have row filter for partitioned table.
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- fail - "b" is not in REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---
-- set PUBLISH_VIA_PARTITION_ROOT to true
-- can use row filter for partitioned table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
-- ok - can use row filter for partitioned table
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk WHERE (b > 99);
---END---
---START---
-- fail - "b" is not in REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---

DROP PUBLICATION testpub6;
---END---
---START---
DROP TABLE rf_tbl_abcd_pk;
---END---
---START---
DROP TABLE rf_tbl_abcd_nopk;
---END---
---START---
DROP TABLE rf_tbl_abcd_part_pk;
---END---
---START---
-- ======================================================

-- fail - duplicate tables are not allowed if that table has any column lists
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_dups FOR TABLE testpub_tbl1 (a), testpub_tbl1 WITH (publish = 'insert');
---END---
---START---
CREATE PUBLICATION testpub_dups FOR TABLE testpub_tbl1, testpub_tbl1 (a) WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---

-- test for column lists
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_fortable FOR TABLE testpub_tbl1;
---END---
---START---
CREATE PUBLICATION testpub_fortable_insert WITH (publish = 'insert');
---END---
---START---
RESET client_min_messages;
---END---
---START---
CREATE TABLE testpub_tbl5 (a int PRIMARY KEY, b text, c text,
	d int generated always as (a + length(b)) stored);
---END---
---START---
-- error: column "x" does not exist
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl5 (a, x);
---END---
---START---
-- error: replica identity "a" not included in the column list
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl5 (b, c);
---END---
---START---
UPDATE testpub_tbl5 SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub_fortable DROP TABLE testpub_tbl5;
---END---
---START---
-- error: generated column "d" can't be in list
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl5 (a, d);
---END---
---START---
-- error: system attributes "ctid" not allowed in column list
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl5 (a, ctid);
---END---
---START---
-- ok
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl5 (a, c);
---END---
---START---
ALTER TABLE testpub_tbl5 DROP COLUMN c;		-- no dice
-- ok: for insert-only publication, any column list is acceptable
ALTER PUBLICATION testpub_fortable_insert ADD TABLE testpub_tbl5 (b, c);
---END---
---START---

/* not all replica identities are good enough */
CREATE UNIQUE INDEX testpub_tbl5_b_key ON testpub_tbl5 (b, c);
---END---
---START---
ALTER TABLE testpub_tbl5 ALTER b SET NOT NULL, ALTER c SET NOT NULL;
---END---
---START---
ALTER TABLE testpub_tbl5 REPLICA IDENTITY USING INDEX testpub_tbl5_b_key;
---END---
---START---
-- error: replica identity (b,c) is not covered by column list (a, c)
UPDATE testpub_tbl5 SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub_fortable DROP TABLE testpub_tbl5;
---END---
---START---

-- error: change the replica identity to "b", and column list to (a, c)
-- then update fails, because (a, c) does not cover replica identity
ALTER TABLE testpub_tbl5 REPLICA IDENTITY USING INDEX testpub_tbl5_b_key;
---END---
---START---
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl5 (a, c);
---END---
---START---
UPDATE testpub_tbl5 SET a = 1;
---END---
---START---

/* But if upd/del are not published, it works OK */
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_table_ins WITH (publish = 'insert, truncate');
---END---
---START---
RESET client_min_messages;
---END---
---START---
ALTER PUBLICATION testpub_table_ins ADD TABLE testpub_tbl5 (a);		-- ok
\dRp+ testpub_table_ins

-- tests with REPLICA IDENTITY FULL
CREATE TABLE testpub_tbl6 (a int, b text, c text);
---END---
---START---
ALTER TABLE testpub_tbl6 REPLICA IDENTITY FULL;
---END---
---START---

ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl6 (a, b, c);
---END---
---START---
UPDATE testpub_tbl6 SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub_fortable DROP TABLE testpub_tbl6;
---END---
---START---

ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl6; -- ok
UPDATE testpub_tbl6 SET a = 1;
---END---
---START---

-- make sure changing the column list is propagated to the catalog
CREATE TABLE testpub_tbl7 (a int primary key, b text, c text);
---END---
---START---
ALTER PUBLICATION testpub_fortable ADD TABLE testpub_tbl7 (a, b);
---END---
---START---
\d+ testpub_tbl7
-- ok: the column list is the same, we should skip this table (or at least not fail)
ALTER PUBLICATION testpub_fortable SET TABLE testpub_tbl7 (a, b);
---END---
---START---
\d+ testpub_tbl7
-- ok: the column list changes, make sure the catalog gets updated
ALTER PUBLICATION testpub_fortable SET TABLE testpub_tbl7 (a, c);
---END---
---START---
\d+ testpub_tbl7

-- column list for partitioned tables has to cover replica identities for
-- all child relations
CREATE TABLE testpub_tbl8 (a int, b text, c text) PARTITION BY HASH (a);
---END---
---START---
-- first partition has replica identity "a"
CREATE TABLE testpub_tbl8_0 PARTITION OF testpub_tbl8 FOR VALUES WITH (modulus 2, remainder 0);
---END---
---START---
ALTER TABLE testpub_tbl8_0 ADD PRIMARY KEY (a);
---END---
---START---
ALTER TABLE testpub_tbl8_0 REPLICA IDENTITY USING INDEX testpub_tbl8_0_pkey;
---END---
---START---
-- second partition has replica identity "b"
CREATE TABLE testpub_tbl8_1 PARTITION OF testpub_tbl8 FOR VALUES WITH (modulus 2, remainder 1);
---END---
---START---
ALTER TABLE testpub_tbl8_1 ADD PRIMARY KEY (b);
---END---
---START---
ALTER TABLE testpub_tbl8_1 REPLICA IDENTITY USING INDEX testpub_tbl8_1_pkey;
---END---
---START---

-- ok: column list covers both "a" and "b"
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_col_list FOR TABLE testpub_tbl8 (a, b) WITH (publish_via_partition_root = 'true');
---END---
---START---
RESET client_min_messages;
---END---
---START---

-- ok: the same thing, but try plain ADD TABLE
ALTER PUBLICATION testpub_col_list DROP TABLE testpub_tbl8;
---END---
---START---
ALTER PUBLICATION testpub_col_list ADD TABLE testpub_tbl8 (a, b);
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---

-- failure: column list does not cover replica identity for the second partition
ALTER PUBLICATION testpub_col_list DROP TABLE testpub_tbl8;
---END---
---START---
ALTER PUBLICATION testpub_col_list ADD TABLE testpub_tbl8 (a, c);
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub_col_list DROP TABLE testpub_tbl8;
---END---
---START---

-- failure: one of the partitions has REPLICA IDENTITY FULL
ALTER TABLE testpub_tbl8_1 REPLICA IDENTITY FULL;
---END---
---START---
ALTER PUBLICATION testpub_col_list ADD TABLE testpub_tbl8 (a, c);
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub_col_list DROP TABLE testpub_tbl8;
---END---
---START---

-- add table and then try changing replica identity
ALTER TABLE testpub_tbl8_1 REPLICA IDENTITY USING INDEX testpub_tbl8_1_pkey;
---END---
---START---
ALTER PUBLICATION testpub_col_list ADD TABLE testpub_tbl8 (a, b);
---END---
---START---

-- failure: replica identity full can't be used with a column list
ALTER TABLE testpub_tbl8_1 REPLICA IDENTITY FULL;
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---

-- failure: replica identity has to be covered by the column list
ALTER TABLE testpub_tbl8_1 DROP CONSTRAINT testpub_tbl8_1_pkey;
---END---
---START---
ALTER TABLE testpub_tbl8_1 ADD PRIMARY KEY (c);
---END---
---START---
ALTER TABLE testpub_tbl8_1 REPLICA IDENTITY USING INDEX testpub_tbl8_1_pkey;
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---

DROP TABLE testpub_tbl8;
---END---
---START---

-- column list for partitioned tables has to cover replica identities for
-- all child relations
CREATE TABLE testpub_tbl8 (a int, b text, c text) PARTITION BY HASH (a);
---END---
---START---
ALTER PUBLICATION testpub_col_list ADD TABLE testpub_tbl8 (a, b);
---END---
---START---
-- first partition has replica identity "a"
CREATE TABLE testpub_tbl8_0 (a int, b text, c text);
---END---
---START---
ALTER TABLE testpub_tbl8_0 ADD PRIMARY KEY (a);
---END---
---START---
ALTER TABLE testpub_tbl8_0 REPLICA IDENTITY USING INDEX testpub_tbl8_0_pkey;
---END---
---START---
-- second partition has replica identity "b"
CREATE TABLE testpub_tbl8_1 (a int, b text, c text);
---END---
---START---
ALTER TABLE testpub_tbl8_1 ADD PRIMARY KEY (c);
---END---
---START---
ALTER TABLE testpub_tbl8_1 REPLICA IDENTITY USING INDEX testpub_tbl8_1_pkey;
---END---
---START---

-- ok: attaching first partition works, because (a) is in column list
ALTER TABLE testpub_tbl8 ATTACH PARTITION testpub_tbl8_0 FOR VALUES WITH (modulus 2, remainder 0);
---END---
---START---
-- failure: second partition has replica identity (c), which si not in column list
ALTER TABLE testpub_tbl8 ATTACH PARTITION testpub_tbl8_1 FOR VALUES WITH (modulus 2, remainder 1);
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---

-- failure: changing replica identity to FULL for partition fails, because
-- of the column list on the parent
ALTER TABLE testpub_tbl8_0 REPLICA IDENTITY FULL;
---END---
---START---
UPDATE testpub_tbl8 SET a = 1;
---END---
---START---

-- test that using column list for table is disallowed if any schemas are
-- part of the publication
SET client_min_messages = 'ERROR';
---END---
---START---
-- failure - cannot use column list and schema together
CREATE PUBLICATION testpub_tbl9 FOR TABLES IN SCHEMA public, TABLE public.testpub_tbl7(a);
---END---
---START---
-- ok - only publish schema
CREATE PUBLICATION testpub_tbl9 FOR TABLES IN SCHEMA public;
---END---
---START---
-- failure - add a table with column list when there is already a schema in the
-- publication
ALTER PUBLICATION testpub_tbl9 ADD TABLE public.testpub_tbl7(a);
---END---
---START---
-- ok - only publish table with column list
ALTER PUBLICATION testpub_tbl9 SET TABLE public.testpub_tbl7(a);
---END---
---START---
-- failure - specify a schema when there is already a column list in the
-- publication
ALTER PUBLICATION testpub_tbl9 ADD TABLES IN SCHEMA public;
---END---
---START---
-- failure - cannot SET column list and schema together
ALTER PUBLICATION testpub_tbl9 SET TABLES IN SCHEMA public, TABLE public.testpub_tbl7(a);
---END---
---START---
-- ok - drop table
ALTER PUBLICATION testpub_tbl9 DROP TABLE public.testpub_tbl7;
---END---
---START---
-- failure - cannot ADD column list and schema together
ALTER PUBLICATION testpub_tbl9 ADD TABLES IN SCHEMA public, TABLE public.testpub_tbl7(a);
---END---
---START---
RESET client_min_messages;
---END---
---START---

DROP TABLE testpub_tbl5, testpub_tbl6, testpub_tbl7, testpub_tbl8, testpub_tbl8_1;
---END---
---START---
DROP PUBLICATION testpub_table_ins, testpub_fortable, testpub_fortable_insert, testpub_col_list, testpub_tbl9;
---END---
---START---
-- ======================================================

-- Test combination of column list and row filter
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_both_filters;
---END---
---START---
RESET client_min_messages;
---END---
---START---
CREATE TABLE testpub_tbl_both_filters (a int, b int, c int, PRIMARY KEY (a,c));
---END---
---START---
ALTER TABLE testpub_tbl_both_filters REPLICA IDENTITY USING INDEX testpub_tbl_both_filters_pkey;
---END---
---START---
ALTER PUBLICATION testpub_both_filters ADD TABLE testpub_tbl_both_filters (a,c) WHERE (c != 1);
---END---
---START---
\dRp+ testpub_both_filters
\d+ testpub_tbl_both_filters

DROP TABLE testpub_tbl_both_filters;
---END---
---START---
DROP PUBLICATION testpub_both_filters;
---END---
---START---
-- ======================================================

-- More column list tests for validating column references
CREATE TABLE rf_tbl_abcd_nopk(a int, b int, c int, d int);
---END---
---START---
CREATE TABLE rf_tbl_abcd_pk(a int, b int, c int, d int, PRIMARY KEY(a,b));
---END---
---START---
CREATE TABLE rf_tbl_abcd_part_pk (a int PRIMARY KEY, b int) PARTITION by RANGE (a);
---END---
---START---
CREATE TABLE rf_tbl_abcd_part_pk_1 (b int, a int PRIMARY KEY);
---END---
---START---
ALTER TABLE rf_tbl_abcd_part_pk ATTACH PARTITION rf_tbl_abcd_part_pk_1 FOR VALUES FROM (1) TO (10);
---END---
---START---

-- Case 1. REPLICA IDENTITY DEFAULT (means use primary key or nothing)

-- 1a. REPLICA IDENTITY is DEFAULT and table has a PK.
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub6 FOR TABLE rf_tbl_abcd_pk (a, b);
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- ok - (a,b) coverts all PK cols
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (a, b, c);
---END---
---START---
-- ok - (a,b,c) coverts all PK cols
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (a);
---END---
---START---
-- fail - "b" is missing from the column list
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (b);
---END---
---START---
-- fail - "a" is missing from the column list
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---

-- 1b. REPLICA IDENTITY is DEFAULT and table has no PK
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk (a);
---END---
---START---
-- ok - there's no replica identity, so any column list works
-- note: it fails anyway, just a bit later because UPDATE requires RI
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Case 2. REPLICA IDENTITY FULL
ALTER TABLE rf_tbl_abcd_pk REPLICA IDENTITY FULL;
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk REPLICA IDENTITY FULL;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (c);
---END---
---START---
-- fail - with REPLICA IDENTITY FULL no column list is allowed
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk (a, b, c, d);
---END---
---START---
-- fail - with REPLICA IDENTITY FULL no column list is allowed
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Case 3. REPLICA IDENTITY NOTHING
ALTER TABLE rf_tbl_abcd_pk REPLICA IDENTITY NOTHING;
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk REPLICA IDENTITY NOTHING;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (a);
---END---
---START---
-- ok - REPLICA IDENTITY NOTHING means all column lists are valid
-- it still fails later because without RI we can't replicate updates
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (a, b, c, d);
---END---
---START---
-- ok - REPLICA IDENTITY NOTHING means all column lists are valid
-- it still fails later because without RI we can't replicate updates
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk (d);
---END---
---START---
-- ok - REPLICA IDENTITY NOTHING means all column lists are valid
-- it still fails later because without RI we can't replicate updates
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Case 4. REPLICA IDENTITY INDEX
ALTER TABLE rf_tbl_abcd_pk ALTER COLUMN c SET NOT NULL;
---END---
---START---
CREATE UNIQUE INDEX idx_abcd_pk_c ON rf_tbl_abcd_pk(c);
---END---
---START---
ALTER TABLE rf_tbl_abcd_pk REPLICA IDENTITY USING INDEX idx_abcd_pk_c;
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk ALTER COLUMN c SET NOT NULL;
---END---
---START---
CREATE UNIQUE INDEX idx_abcd_nopk_c ON rf_tbl_abcd_nopk(c);
---END---
---START---
ALTER TABLE rf_tbl_abcd_nopk REPLICA IDENTITY USING INDEX idx_abcd_nopk_c;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (a);
---END---
---START---
-- fail - column list "a" does not cover the REPLICA IDENTITY INDEX on "c"
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_pk (c);
---END---
---START---
-- ok - column list "c" does cover the REPLICA IDENTITY INDEX on "c"
UPDATE rf_tbl_abcd_pk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk (a);
---END---
---START---
-- fail - column list "a" does not cover the REPLICA IDENTITY INDEX on "c"
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_nopk (c);
---END---
---START---
-- ok - column list "c" does cover the REPLICA IDENTITY INDEX on "c"
UPDATE rf_tbl_abcd_nopk SET a = 1;
---END---
---START---

-- Tests for partitioned table

-- set PUBLISH_VIA_PARTITION_ROOT to false and test column list for partitioned
-- table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- fail - cannot use column list for partitioned table
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk (a);
---END---
---START---
-- ok - can use column list for partition
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk_1 (a);
---END---
---START---
-- ok - "a" is a PK col
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---
-- set PUBLISH_VIA_PARTITION_ROOT to true and test column list for partitioned
-- table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
-- ok - can use column list for partitioned table
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk (a);
---END---
---START---
-- ok - "a" is a PK col
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---
-- fail - cannot set PUBLISH_VIA_PARTITION_ROOT to false if any column list is
-- used for partitioned table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- remove partitioned table's column list
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk;
---END---
---START---
-- ok - we don't have column list for partitioned table.
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- Now change the root column list to use a column "b"
-- (which is not in the replica identity)
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk_1 (b);
---END---
---START---
-- ok - we don't have column list for partitioned table.
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
-- fail - "b" is not in REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---
-- set PUBLISH_VIA_PARTITION_ROOT to true
-- can use column list for partitioned table
ALTER PUBLICATION testpub6 SET (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
-- ok - can use column list for partitioned table
ALTER PUBLICATION testpub6 SET TABLE rf_tbl_abcd_part_pk (b);
---END---
---START---
-- fail - "b" is not in REPLICA IDENTITY INDEX
UPDATE rf_tbl_abcd_part_pk SET a = 1;
---END---
---START---

DROP PUBLICATION testpub6;
---END---
---START---
DROP TABLE rf_tbl_abcd_pk;
---END---
---START---
DROP TABLE rf_tbl_abcd_nopk;
---END---
---START---
DROP TABLE rf_tbl_abcd_part_pk;
---END---
---START---
-- ======================================================

-- Test cache invalidation FOR ALL TABLES publication
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE TABLE testpub_tbl4(a int);
---END---
---START---
INSERT INTO testpub_tbl4 values(1);
---END---
---START---
UPDATE testpub_tbl4 set a = 2;
---END---
---START---
CREATE PUBLICATION testpub_foralltables FOR ALL TABLES;
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- fail missing REPLICA IDENTITY
UPDATE testpub_tbl4 set a = 3;
---END---
---START---
DROP PUBLICATION testpub_foralltables;
---END---
---START---
-- should pass after dropping the publication
UPDATE testpub_tbl4 set a = 3;
---END---
---START---
DROP TABLE testpub_tbl4;
---END---
---START---

-- fail - view
CREATE PUBLICATION testpub_fortbl FOR TABLE testpub_view;
---END---
---START---

CREATE TEMPORARY TABLE testpub_temptbl(a int);
---END---
---START---
-- fail - temporary table
CREATE PUBLICATION testpub_fortemptbl FOR TABLE testpub_temptbl;
---END---
---START---
DROP TABLE testpub_temptbl;
---END---
---START---

CREATE UNLOGGED TABLE testpub_unloggedtbl(a int);
---END---
---START---
-- fail - unlogged table
CREATE PUBLICATION testpub_forunloggedtbl FOR TABLE testpub_unloggedtbl;
---END---
---START---
DROP TABLE testpub_unloggedtbl;
---END---
---START---

-- fail - system table
CREATE PUBLICATION testpub_forsystemtbl FOR TABLE pg_publication;
---END---
---START---

SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_fortbl FOR TABLE testpub_tbl1, pub_test.testpub_nopk;
---END---
---START---
RESET client_min_messages;
---END---
---START---
-- fail - already added
ALTER PUBLICATION testpub_fortbl ADD TABLE testpub_tbl1;
---END---
---START---
-- fail - already added
CREATE PUBLICATION testpub_fortbl FOR TABLE testpub_tbl1;
---END---
---START---

\dRp+ testpub_fortbl

-- fail - view
ALTER PUBLICATION testpub_default ADD TABLE testpub_view;
---END---
---START---

ALTER PUBLICATION testpub_default ADD TABLE testpub_tbl1;
---END---
---START---
ALTER PUBLICATION testpub_default SET TABLE testpub_tbl1;
---END---
---START---
ALTER PUBLICATION testpub_default ADD TABLE pub_test.testpub_nopk;
---END---
---START---

ALTER PUBLICATION testpib_ins_trunct ADD TABLE pub_test.testpub_nopk, testpub_tbl1;
---END---
---START---

\d+ pub_test.testpub_nopk
\d+ testpub_tbl1
\dRp+ testpub_default

ALTER PUBLICATION testpub_default DROP TABLE testpub_tbl1, pub_test.testpub_nopk;
---END---
---START---
-- fail - nonexistent
ALTER PUBLICATION testpub_default DROP TABLE pub_test.testpub_nopk;
---END---
---START---

\d+ testpub_tbl1

-- verify relation cache invalidation when a primary key is added using
-- an existing index
CREATE TABLE pub_test.testpub_addpk (id int not null, data int);
---END---
---START---
ALTER PUBLICATION testpub_default ADD TABLE pub_test.testpub_addpk;
---END---
---START---
INSERT INTO pub_test.testpub_addpk VALUES(1, 11);
---END---
---START---
CREATE UNIQUE INDEX testpub_addpk_id_idx ON pub_test.testpub_addpk(id);
---END---
---START---
-- fail:
UPDATE pub_test.testpub_addpk SET id = 2;
---END---
---START---
ALTER TABLE pub_test.testpub_addpk ADD PRIMARY KEY USING INDEX testpub_addpk_id_idx;
---END---
---START---
-- now it should work:
UPDATE pub_test.testpub_addpk SET id = 2;
---END---
---START---
DROP TABLE pub_test.testpub_addpk;
---END---
---START---

-- permissions
SET ROLE regress_publication_user2;
---END---
---START---
CREATE PUBLICATION testpub2;  -- fail

SET ROLE regress_publication_user;
---END---
---START---
GRANT CREATE ON DATABASE regression TO regress_publication_user2;
---END---
---START---
SET ROLE regress_publication_user2;
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub2;  -- ok
CREATE PUBLICATION testpub3 FOR TABLES IN SCHEMA pub_test;  -- fail
CREATE PUBLICATION testpub3;  -- ok
RESET client_min_messages;
---END---
---START---

ALTER PUBLICATION testpub2 ADD TABLE testpub_tbl1;  -- fail
ALTER PUBLICATION testpub3 ADD TABLES IN SCHEMA pub_test;  -- fail

SET ROLE regress_publication_user;
---END---
---START---
GRANT regress_publication_user TO regress_publication_user2;
---END---
---START---
SET ROLE regress_publication_user2;
---END---
---START---
ALTER PUBLICATION testpub2 ADD TABLE testpub_tbl1;  -- ok

DROP PUBLICATION testpub2;
---END---
---START---
DROP PUBLICATION testpub3;
---END---
---START---

SET ROLE regress_publication_user;
---END---
---START---
CREATE ROLE regress_publication_user3;
---END---
---START---
GRANT regress_publication_user2 TO regress_publication_user3;
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub4 FOR TABLES IN SCHEMA pub_test;
---END---
---START---
RESET client_min_messages;
---END---
---START---
ALTER PUBLICATION testpub4 OWNER TO regress_publication_user3;
---END---
---START---
SET ROLE regress_publication_user3;
---END---
---START---
-- fail - new owner must be superuser
ALTER PUBLICATION testpub4 owner to regress_publication_user2; -- fail
ALTER PUBLICATION testpub4 owner to regress_publication_user; -- ok

SET ROLE regress_publication_user;
---END---
---START---
DROP PUBLICATION testpub4;
---END---
---START---
DROP ROLE regress_publication_user3;
---END---
---START---

REVOKE CREATE ON DATABASE regression FROM regress_publication_user2;
---END---
---START---

DROP TABLE testpub_parted;
---END---
---START---
DROP TABLE testpub_tbl1;
---END---
---START---

\dRp+ testpub_default

-- fail - must be owner of publication
SET ROLE regress_publication_user_dummy;
---END---
---START---
ALTER PUBLICATION testpub_default RENAME TO testpub_dummy;
---END---
---START---
RESET ROLE;
---END---
---START---

ALTER PUBLICATION testpub_default RENAME TO testpub_foo;
---END---
---START---

\dRp testpub_foo

-- rename back to keep the rest simple
ALTER PUBLICATION testpub_foo RENAME TO testpub_default;
---END---
---START---

ALTER PUBLICATION testpub_default OWNER TO regress_publication_user2;
---END---
---START---

\dRp testpub_default

-- adding schemas and tables
CREATE SCHEMA pub_test1;
---END---
---START---
CREATE SCHEMA pub_test2;
---END---
---START---
CREATE SCHEMA pub_test3;
---END---
---START---
CREATE SCHEMA "CURRENT_SCHEMA";
---END---
---START---
CREATE TABLE pub_test1.tbl (id int, data text);
---END---
---START---
CREATE TABLE pub_test1.tbl1 (id serial primary key, data text);
---END---
---START---
CREATE TABLE pub_test2.tbl1 (id serial primary key, data text);
---END---
---START---
CREATE TABLE "CURRENT_SCHEMA"."CURRENT_SCHEMA"(id int);
---END---
---START---

-- suppress warning that depends on wal_level
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub1_forschema FOR TABLES IN SCHEMA pub_test1;
---END---
---START---
\dRp+ testpub1_forschema

CREATE PUBLICATION testpub2_forschema FOR TABLES IN SCHEMA pub_test1, pub_test2, pub_test3;
---END---
---START---
\dRp+ testpub2_forschema

-- check create publication on CURRENT_SCHEMA
CREATE PUBLICATION testpub3_forschema FOR TABLES IN SCHEMA CURRENT_SCHEMA;
---END---
---START---
CREATE PUBLICATION testpub4_forschema FOR TABLES IN SCHEMA "CURRENT_SCHEMA";
---END---
---START---
CREATE PUBLICATION testpub5_forschema FOR TABLES IN SCHEMA CURRENT_SCHEMA, "CURRENT_SCHEMA";
---END---
---START---
CREATE PUBLICATION testpub6_forschema FOR TABLES IN SCHEMA "CURRENT_SCHEMA", CURRENT_SCHEMA;
---END---
---START---
CREATE PUBLICATION testpub_fortable FOR TABLE "CURRENT_SCHEMA"."CURRENT_SCHEMA";
---END---
---START---

RESET client_min_messages;
---END---
---START---

\dRp+ testpub3_forschema
\dRp+ testpub4_forschema
\dRp+ testpub5_forschema
\dRp+ testpub6_forschema
\dRp+ testpub_fortable

-- check create publication on CURRENT_SCHEMA where search_path is not set
SET SEARCH_PATH='';
---END---
---START---
CREATE PUBLICATION testpub_forschema FOR TABLES IN SCHEMA CURRENT_SCHEMA;
---END---
---START---
RESET SEARCH_PATH;
---END---
---START---

-- check create publication on CURRENT_SCHEMA where TABLE/TABLES in SCHEMA
-- is not specified
CREATE PUBLICATION testpub_forschema1 FOR CURRENT_SCHEMA;
---END---
---START---

-- check create publication on CURRENT_SCHEMA along with FOR TABLE
CREATE PUBLICATION testpub_forschema1 FOR TABLE CURRENT_SCHEMA;
---END---
---START---

-- check create publication on a schema that does not exist
CREATE PUBLICATION testpub_forschema FOR TABLES IN SCHEMA non_existent_schema;
---END---
---START---

-- check create publication on a system schema
CREATE PUBLICATION testpub_forschema FOR TABLES IN SCHEMA pg_catalog;
---END---
---START---

-- check create publication on an object which is not schema
CREATE PUBLICATION testpub1_forschema1 FOR TABLES IN SCHEMA testpub_view;
---END---
---START---

-- dropping the schema should reflect the change in publication
DROP SCHEMA pub_test3;
---END---
---START---
\dRp+ testpub2_forschema

-- renaming the schema should reflect the change in publication
ALTER SCHEMA pub_test1 RENAME to pub_test1_renamed;
---END---
---START---
\dRp+ testpub2_forschema

ALTER SCHEMA pub_test1_renamed RENAME to pub_test1;
---END---
---START---
\dRp+ testpub2_forschema

-- alter publication add schema
ALTER PUBLICATION testpub1_forschema ADD TABLES IN SCHEMA pub_test2;
---END---
---START---
\dRp+ testpub1_forschema

-- add non existent schema
ALTER PUBLICATION testpub1_forschema ADD TABLES IN SCHEMA non_existent_schema;
---END---
---START---
\dRp+ testpub1_forschema

-- add a schema which is already added to the publication
ALTER PUBLICATION testpub1_forschema ADD TABLES IN SCHEMA pub_test1;
---END---
---START---
\dRp+ testpub1_forschema

-- alter publication drop schema
ALTER PUBLICATION testpub1_forschema DROP TABLES IN SCHEMA pub_test2;
---END---
---START---
\dRp+ testpub1_forschema

-- drop schema that is not present in the publication
ALTER PUBLICATION testpub1_forschema DROP TABLES IN SCHEMA pub_test2;
---END---
---START---
\dRp+ testpub1_forschema

-- drop a schema that does not exist in the system
ALTER PUBLICATION testpub1_forschema DROP TABLES IN SCHEMA non_existent_schema;
---END---
---START---
\dRp+ testpub1_forschema

-- drop all schemas
ALTER PUBLICATION testpub1_forschema DROP TABLES IN SCHEMA pub_test1;
---END---
---START---
\dRp+ testpub1_forschema

-- alter publication set multiple schema
ALTER PUBLICATION testpub1_forschema SET TABLES IN SCHEMA pub_test1, pub_test2;
---END---
---START---
\dRp+ testpub1_forschema

-- alter publication set non-existent schema
ALTER PUBLICATION testpub1_forschema SET TABLES IN SCHEMA non_existent_schema;
---END---
---START---
\dRp+ testpub1_forschema

-- alter publication set it duplicate schemas should set the schemas after
-- removing the duplicate schemas
ALTER PUBLICATION testpub1_forschema SET TABLES IN SCHEMA pub_test1, pub_test1;
---END---
---START---
\dRp+ testpub1_forschema

-- Verify that it fails to add a schema with a column specification
ALTER PUBLICATION testpub1_forschema ADD TABLES IN SCHEMA foo (a, b);
---END---
---START---
ALTER PUBLICATION testpub1_forschema ADD TABLES IN SCHEMA foo, bar (a, b);
---END---
---START---

-- cleanup pub_test1 schema for invalidation tests
ALTER PUBLICATION testpub2_forschema DROP TABLES IN SCHEMA pub_test1;
---END---
---START---
DROP PUBLICATION testpub3_forschema, testpub4_forschema, testpub5_forschema, testpub6_forschema, testpub_fortable;
---END---
---START---
DROP SCHEMA "CURRENT_SCHEMA" CASCADE;
---END---
---START---

-- verify relation cache invalidations through update statement for the
-- default REPLICA IDENTITY on the relation, if schema is part of the
-- publication then update will fail because relation's relreplident
-- option will be set, if schema is not part of the publication then update
-- will be successful.
INSERT INTO pub_test1.tbl VALUES(1, 'test');
---END---
---START---

-- fail
UPDATE pub_test1.tbl SET id = 2;
---END---
---START---
ALTER PUBLICATION testpub1_forschema DROP TABLES IN SCHEMA pub_test1;
---END---
---START---

-- success
UPDATE pub_test1.tbl SET id = 2;
---END---
---START---
ALTER PUBLICATION testpub1_forschema SET TABLES IN SCHEMA pub_test1;
---END---
---START---

-- fail
UPDATE pub_test1.tbl SET id = 2;
---END---
---START---

-- verify invalidation of partition table having parent and child tables in
-- different schema
CREATE SCHEMA pub_testpart1;
---END---
---START---
CREATE SCHEMA pub_testpart2;
---END---
---START---

CREATE TABLE pub_testpart1.parent1 (a int) partition by list (a);
---END---
---START---
CREATE TABLE pub_testpart2.child_parent1 partition of pub_testpart1.parent1 for values in (1);
---END---
---START---
INSERT INTO pub_testpart2.child_parent1 values(1);
---END---
---START---
UPDATE pub_testpart2.child_parent1 set a = 1;
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpubpart_forschema FOR TABLES IN SCHEMA pub_testpart1;
---END---
---START---
RESET client_min_messages;
---END---
---START---

-- fail
UPDATE pub_testpart1.parent1 set a = 1;
---END---
---START---
UPDATE pub_testpart2.child_parent1 set a = 1;
---END---
---START---

DROP PUBLICATION testpubpart_forschema;
---END---
---START---

-- verify invalidation of partition tables for schema publication that has
-- parent and child tables of different partition hierarchies
CREATE TABLE pub_testpart2.parent2 (a int) partition by list (a);
---END---
---START---
CREATE TABLE pub_testpart1.child_parent2 partition of pub_testpart2.parent2 for values in (1);
---END---
---START---
INSERT INTO pub_testpart1.child_parent2 values(1);
---END---
---START---
UPDATE pub_testpart1.child_parent2 set a = 1;
---END---
---START---
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpubpart_forschema FOR TABLES IN SCHEMA pub_testpart2;
---END---
---START---
RESET client_min_messages;
---END---
---START---

-- fail
UPDATE pub_testpart2.child_parent1 set a = 1;
---END---
---START---
UPDATE pub_testpart2.parent2 set a = 1;
---END---
---START---
UPDATE pub_testpart1.child_parent2 set a = 1;
---END---
---START---

-- alter publication set 'TABLES IN SCHEMA' on an empty publication.
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub3_forschema;
---END---
---START---
RESET client_min_messages;
---END---
---START---
\dRp+ testpub3_forschema
ALTER PUBLICATION testpub3_forschema SET TABLES IN SCHEMA pub_test1;
---END---
---START---
\dRp+ testpub3_forschema

-- create publication including both 'FOR TABLE' and 'FOR TABLES IN SCHEMA'
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE PUBLICATION testpub_forschema_fortable FOR TABLES IN SCHEMA pub_test1, TABLE pub_test2.tbl1;
---END---
---START---
CREATE PUBLICATION testpub_fortable_forschema FOR TABLE pub_test2.tbl1, TABLES IN SCHEMA pub_test1;
---END---
---START---
RESET client_min_messages;
---END---
---START---

\dRp+ testpub_forschema_fortable
\dRp+ testpub_fortable_forschema

-- fail specifying table without any of 'FOR TABLES IN SCHEMA' or
--'FOR TABLE' or 'FOR ALL TABLES'
CREATE PUBLICATION testpub_error FOR pub_test2.tbl1;
---END---
---START---

DROP VIEW testpub_view;
---END---
---START---

DROP PUBLICATION testpub_default;
---END---
---START---
DROP PUBLICATION testpib_ins_trunct;
---END---
---START---
DROP PUBLICATION testpub_fortbl;
---END---
---START---
DROP PUBLICATION testpub1_forschema;
---END---
---START---
DROP PUBLICATION testpub2_forschema;
---END---
---START---
DROP PUBLICATION testpub3_forschema;
---END---
---START---
DROP PUBLICATION testpub_forschema_fortable;
---END---
---START---
DROP PUBLICATION testpub_fortable_forschema;
---END---
---START---
DROP PUBLICATION testpubpart_forschema;
---END---
---START---

DROP SCHEMA pub_test CASCADE;
---END---
---START---
DROP SCHEMA pub_test1 CASCADE;
---END---
---START---
DROP SCHEMA pub_test2 CASCADE;
---END---
---START---
DROP SCHEMA pub_testpart1 CASCADE;
---END---
---START---
DROP SCHEMA pub_testpart2 CASCADE;
---END---
---START---

-- Test the list of partitions published with or without
-- 'PUBLISH_VIA_PARTITION_ROOT' parameter
SET client_min_messages = 'ERROR';
---END---
---START---
CREATE SCHEMA sch1;
---END---
---START---
CREATE SCHEMA sch2;
---END---
---START---
CREATE TABLE sch1.tbl1 (a int) PARTITION BY RANGE(a);
---END---
---START---
CREATE TABLE sch2.tbl1_part1 PARTITION OF sch1.tbl1 FOR VALUES FROM (1) to (10);
---END---
---START---
-- Schema publication that does not include the schema that has the parent table
CREATE PUBLICATION pub FOR TABLES IN SCHEMA sch2 WITH (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

DROP PUBLICATION pub;
---END---
---START---
-- Table publication that does not include the parent table
CREATE PUBLICATION pub FOR TABLE sch2.tbl1_part1 WITH (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

-- Table publication that includes both the parent table and the child table
ALTER PUBLICATION pub ADD TABLE sch1.tbl1;
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

DROP PUBLICATION pub;
---END---
---START---
-- Schema publication that does not include the schema that has the parent table
CREATE PUBLICATION pub FOR TABLES IN SCHEMA sch2 WITH (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

DROP PUBLICATION pub;
---END---
---START---
-- Table publication that does not include the parent table
CREATE PUBLICATION pub FOR TABLE sch2.tbl1_part1 WITH (PUBLISH_VIA_PARTITION_ROOT=0);
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

-- Table publication that includes both the parent table and the child table
ALTER PUBLICATION pub ADD TABLE sch1.tbl1;
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

DROP PUBLICATION pub;
---END---
---START---
DROP TABLE sch2.tbl1_part1;
---END---
---START---
DROP TABLE sch1.tbl1;
---END---
---START---

CREATE TABLE sch1.tbl1 (a int) PARTITION BY RANGE(a);
---END---
---START---
CREATE TABLE sch1.tbl1_part1 PARTITION OF sch1.tbl1 FOR VALUES FROM (1) to (10);
---END---
---START---
CREATE TABLE sch1.tbl1_part2 PARTITION OF sch1.tbl1 FOR VALUES FROM (10) to (20);
---END---
---START---
CREATE TABLE sch1.tbl1_part3 (a int) PARTITION BY RANGE(a);
---END---
---START---
ALTER TABLE sch1.tbl1 ATTACH PARTITION sch1.tbl1_part3 FOR VALUES FROM (20) to (30);
---END---
---START---
CREATE PUBLICATION pub FOR TABLES IN SCHEMA sch1 WITH (PUBLISH_VIA_PARTITION_ROOT=1);
---END---
---START---
SELECT * FROM pg_publication_tables;
---END---
---START---

RESET client_min_messages;
---END---
---START---
DROP PUBLICATION pub;
---END---
---START---
DROP TABLE sch1.tbl1;
---END---
---START---
DROP SCHEMA sch1 cascade;
---END---
---START---
DROP SCHEMA sch2 cascade;
---END---
---START---

RESET SESSION AUTHORIZATION;
---END---
---START---
DROP ROLE regress_publication_user, regress_publication_user2;
---END---
---START---
DROP ROLE regress_publication_user_dummy;
---END---
