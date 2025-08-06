---START---
--
-- ALTER_TABLE
--

-- Clean up in case a prior regression run failed
SET client_min_messages TO 'warning';
---END---
---START---
DROP ROLE IF EXISTS regress_alter_table_user1;
---END---
---START---
RESET client_min_messages;
---END---
---START---

CREATE USER regress_alter_table_user1;
---END---
---START---

--
-- add attribute
--

CREATE TABLE attmp (initial int4);
---END---
---START---

COMMENT ON TABLE attmp_wrong IS 'table comment';
---END---
---START---
COMMENT ON TABLE attmp IS 'table comment';
---END---
---START---
COMMENT ON TABLE attmp IS NULL;
---END---
---START---

ALTER TABLE attmp ADD COLUMN xmin integer; -- fails

ALTER TABLE attmp ADD COLUMN a int4 default 3;
---END---
---START---

ALTER TABLE attmp ADD COLUMN b name;
---END---
---START---

ALTER TABLE attmp ADD COLUMN c text;
---END---
---START---

ALTER TABLE attmp ADD COLUMN d float8;
---END---
---START---

ALTER TABLE attmp ADD COLUMN e float4;
---END---
---START---

ALTER TABLE attmp ADD COLUMN f int2;
---END---
---START---

ALTER TABLE attmp ADD COLUMN g polygon;
---END---
---START---

ALTER TABLE attmp ADD COLUMN i char;
---END---
---START---

ALTER TABLE attmp ADD COLUMN k int4;
---END---
---START---

ALTER TABLE attmp ADD COLUMN l tid;
---END---
---START---

ALTER TABLE attmp ADD COLUMN m xid;
---END---
---START---

ALTER TABLE attmp ADD COLUMN n oidvector;
---END---
---START---

--ALTER TABLE attmp ADD COLUMN o lock;
---END---
---START---
ALTER TABLE attmp ADD COLUMN p boolean;
---END---
---START---

ALTER TABLE attmp ADD COLUMN q point;
---END---
---START---

ALTER TABLE attmp ADD COLUMN r lseg;
---END---
---START---

ALTER TABLE attmp ADD COLUMN s path;
---END---
---START---

ALTER TABLE attmp ADD COLUMN t box;
---END---
---START---

ALTER TABLE attmp ADD COLUMN v timestamp;
---END---
---START---

ALTER TABLE attmp ADD COLUMN w interval;
---END---
---START---

ALTER TABLE attmp ADD COLUMN x float8[];
---END---
---START---

ALTER TABLE attmp ADD COLUMN y float4[];
---END---
---START---

ALTER TABLE attmp ADD COLUMN z int2[];
---END---
---START---

INSERT INTO attmp (a, b, c, d, e, f, g,    i,    k, l, m, n, p, q, r, s, t,
	v, w, x, y, z)
   VALUES (4, 'name', 'text', 4.1, 4.1, 2, '(4.1,4.1,3.1,3.1)',
	'c',
	314159, '(1,1)', '512',
	'1 2 3 4 5 6 7 8', true, '(1.1,1.1)', '(4.1,4.1,3.1,3.1)',
	'(0,2,4.1,4.1,3.1,3.1)', '(4.1,4.1,3.1,3.1)',
	'epoch', '01:00:10', '{1.0,2.0,3.0,4.0}', '{1.0,2.0,3.0,4.0}', '{1,2,3,4}');
---END---
---START---

SELECT * FROM attmp;
---END---
---START---

DROP TABLE attmp;
---END---
---START---

-- the wolf bug - schema mods caused inconsistent row descriptors
CREATE TABLE attmp (
	initial 	int4
);
---END---
---START---

ALTER TABLE attmp ADD COLUMN a int4;
---END---
---START---

ALTER TABLE attmp ADD COLUMN b name;
---END---
---START---

ALTER TABLE attmp ADD COLUMN c text;
---END---
---START---

ALTER TABLE attmp ADD COLUMN d float8;
---END---
---START---

ALTER TABLE attmp ADD COLUMN e float4;
---END---
---START---

ALTER TABLE attmp ADD COLUMN f int2;
---END---
---START---

ALTER TABLE attmp ADD COLUMN g polygon;
---END---
---START---

ALTER TABLE attmp ADD COLUMN i char;
---END---
---START---

ALTER TABLE attmp ADD COLUMN k int4;
---END---
---START---

ALTER TABLE attmp ADD COLUMN l tid;
---END---
---START---

ALTER TABLE attmp ADD COLUMN m xid;
---END---
---START---

ALTER TABLE attmp ADD COLUMN n oidvector;
---END---
---START---

--ALTER TABLE attmp ADD COLUMN o lock;
---END---
---START---
ALTER TABLE attmp ADD COLUMN p boolean;
---END---
---START---

ALTER TABLE attmp ADD COLUMN q point;
---END---
---START---

ALTER TABLE attmp ADD COLUMN r lseg;
---END---
---START---

ALTER TABLE attmp ADD COLUMN s path;
---END---
---START---

ALTER TABLE attmp ADD COLUMN t box;
---END---
---START---

ALTER TABLE attmp ADD COLUMN v timestamp;
---END---
---START---

ALTER TABLE attmp ADD COLUMN w interval;
---END---
---START---

ALTER TABLE attmp ADD COLUMN x float8[];
---END---
---START---

ALTER TABLE attmp ADD COLUMN y float4[];
---END---
---START---

ALTER TABLE attmp ADD COLUMN z int2[];
---END---
---START---

INSERT INTO attmp (a, b, c, d, e, f, g,    i,   k, l, m, n, p, q, r, s, t,
	v, w, x, y, z)
   VALUES (4, 'name', 'text', 4.1, 4.1, 2, '(4.1,4.1,3.1,3.1)',
        'c',
	314159, '(1,1)', '512',
	'1 2 3 4 5 6 7 8', true, '(1.1,1.1)', '(4.1,4.1,3.1,3.1)',
	'(0,2,4.1,4.1,3.1,3.1)', '(4.1,4.1,3.1,3.1)',
	'epoch', '01:00:10', '{1.0,2.0,3.0,4.0}', '{1.0,2.0,3.0,4.0}', '{1,2,3,4}');
---END---
---START---

SELECT * FROM attmp;
---END---
---START---

CREATE INDEX attmp_idx ON attmp (a, (d + e), b);
---END---
---START---

ALTER INDEX attmp_idx ALTER COLUMN 0 SET STATISTICS 1000;
---END---
---START---

ALTER INDEX attmp_idx ALTER COLUMN 1 SET STATISTICS 1000;
---END---
---START---

ALTER INDEX attmp_idx ALTER COLUMN 2 SET STATISTICS 1000;
---END---
---START---

\d+ attmp_idx

ALTER INDEX attmp_idx ALTER COLUMN 3 SET STATISTICS 1000;
---END---
---START---

ALTER INDEX attmp_idx ALTER COLUMN 4 SET STATISTICS 1000;
---END---
---START---

ALTER INDEX attmp_idx ALTER COLUMN 2 SET STATISTICS -1;
---END---
---START---

DROP TABLE attmp;
---END---
---START---


--
-- rename - check on both non-temp and temp tables
--
CREATE TABLE attmp (regtable int);
---END---
---START---
CREATE TEMP TABLE attmp (attmptable int);
---END---
---START---

ALTER TABLE attmp RENAME TO attmp_new;
---END---
---START---

SELECT * FROM attmp;
---END---
---START---
SELECT * FROM attmp_new;
---END---
---START---

ALTER TABLE attmp RENAME TO attmp_new2;
---END---
---START---

SELECT * FROM attmp;		-- should fail
SELECT * FROM attmp_new;
---END---
---START---
SELECT * FROM attmp_new2;
---END---
---START---

DROP TABLE attmp_new;
---END---
---START---
DROP TABLE attmp_new2;
---END---
---START---

-- check rename of partitioned tables and indexes also
CREATE TABLE part_attmp (a int primary key) partition by range (a);
---END---
---START---
CREATE TABLE part_attmp1 PARTITION OF part_attmp FOR VALUES FROM (0) TO (100);
---END---
---START---
ALTER INDEX part_attmp_pkey RENAME TO part_attmp_index;
---END---
---START---
ALTER INDEX part_attmp1_pkey RENAME TO part_attmp1_index;
---END---
---START---
ALTER TABLE part_attmp RENAME TO part_at2tmp;
---END---
---START---
ALTER TABLE part_attmp1 RENAME TO part_at2tmp1;
---END---
---START---
SET ROLE regress_alter_table_user1;
---END---
---START---
ALTER INDEX part_attmp_index RENAME TO fail;
---END---
---START---
ALTER INDEX part_attmp1_index RENAME TO fail;
---END---
---START---
ALTER TABLE part_at2tmp RENAME TO fail;
---END---
---START---
ALTER TABLE part_at2tmp1 RENAME TO fail;
---END---
---START---
RESET ROLE;
---END---
---START---
DROP TABLE part_at2tmp;
---END---
---START---

--
-- check renaming to a table's array type's autogenerated name
-- (the array type's name should get out of the way)
--
CREATE TABLE attmp_array (id int);
---END---
---START---
CREATE TABLE attmp_array2 (id int);
---END---
---START---
SELECT typname FROM pg_type WHERE oid = 'attmp_array[]'::regtype;
---END---
---START---
SELECT typname FROM pg_type WHERE oid = 'attmp_array2[]'::regtype;
---END---
---START---
ALTER TABLE attmp_array2 RENAME TO _attmp_array;
---END---
---START---
SELECT typname FROM pg_type WHERE oid = 'attmp_array[]'::regtype;
---END---
---START---
SELECT typname FROM pg_type WHERE oid = '_attmp_array[]'::regtype;
---END---
---START---
DROP TABLE _attmp_array;
---END---
---START---
DROP TABLE attmp_array;
---END---
---START---

-- renaming to table's own array type's name is an interesting corner case
CREATE TABLE attmp_array (id int);
---END---
---START---
SELECT typname FROM pg_type WHERE oid = 'attmp_array[]'::regtype;
---END---
---START---
ALTER TABLE attmp_array RENAME TO _attmp_array;
---END---
---START---
SELECT typname FROM pg_type WHERE oid = '_attmp_array[]'::regtype;
---END---
---START---
DROP TABLE _attmp_array;
---END---
---START---

-- ALTER TABLE ... RENAME on non-table relations
-- renaming indexes (FIXME: this should probably test the index's functionality)
ALTER INDEX IF EXISTS __onek_unique1 RENAME TO attmp_onek_unique1;
---END---
---START---
ALTER INDEX IF EXISTS __attmp_onek_unique1 RENAME TO onek_unique1;
---END---
---START---

ALTER INDEX onek_unique1 RENAME TO attmp_onek_unique1;
---END---
---START---
ALTER INDEX attmp_onek_unique1 RENAME TO onek_unique1;
---END---
---START---

SET ROLE regress_alter_table_user1;
---END---
---START---
ALTER INDEX onek_unique1 RENAME TO fail;  -- permission denied
RESET ROLE;
---END---
---START---

-- rename statements with mismatching statement and object types
CREATE TABLE alter_idx_rename_test (a INT);
---END---
---START---
CREATE INDEX alter_idx_rename_test_idx ON alter_idx_rename_test (a);
---END---
---START---
CREATE TABLE alter_idx_rename_test_parted (a INT) PARTITION BY LIST (a);
---END---
---START---
CREATE INDEX alter_idx_rename_test_parted_idx ON alter_idx_rename_test_parted (a);
---END---
---START---
BEGIN;
---END---
---START---
ALTER INDEX alter_idx_rename_test RENAME TO alter_idx_rename_test_2;
---END---
---START---
ALTER INDEX alter_idx_rename_test_parted RENAME TO alter_idx_rename_test_parted_2;
---END---
---START---
SELECT relation::regclass, mode FROM pg_locks
WHERE pid = pg_backend_pid() AND locktype = 'relation'
  AND relation::regclass::text LIKE 'alter\_idx%'
ORDER BY relation::regclass::text COLLATE "C";
---END---
---START---
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
ALTER INDEX alter_idx_rename_test_idx RENAME TO alter_idx_rename_test_idx_2;
---END---
---START---
ALTER INDEX alter_idx_rename_test_parted_idx RENAME TO alter_idx_rename_test_parted_idx_2;
---END---
---START---
SELECT relation::regclass, mode FROM pg_locks
WHERE pid = pg_backend_pid() AND locktype = 'relation'
  AND relation::regclass::text LIKE 'alter\_idx%'
ORDER BY relation::regclass::text COLLATE "C";
---END---
---START---
COMMIT;
---END---
---START---
BEGIN;
---END---
---START---
ALTER TABLE alter_idx_rename_test_idx_2 RENAME TO alter_idx_rename_test_idx_3;
---END---
---START---
ALTER TABLE alter_idx_rename_test_parted_idx_2 RENAME TO alter_idx_rename_test_parted_idx_3;
---END---
---START---
SELECT relation::regclass, mode FROM pg_locks
WHERE pid = pg_backend_pid() AND locktype = 'relation'
  AND relation::regclass::text LIKE 'alter\_idx%'
ORDER BY relation::regclass::text COLLATE "C";
---END---
---START---
COMMIT;
---END---
---START---
DROP TABLE alter_idx_rename_test_2;
---END---
---START---

-- renaming views
CREATE VIEW attmp_view (unique1) AS SELECT unique1 FROM tenk1;
---END---
---START---
ALTER TABLE attmp_view RENAME TO attmp_view_new;
---END---
---START---

SET ROLE regress_alter_table_user1;
---END---
---START---
ALTER VIEW attmp_view_new RENAME TO fail;  -- permission denied
RESET ROLE;
---END---
---START---

-- hack to ensure we get an indexscan here
set enable_seqscan to off;
---END---
---START---
set enable_bitmapscan to off;
---END---
---START---
-- 5 values, sorted
SELECT unique1 FROM tenk1 WHERE unique1 < 5;
---END---
---START---
reset enable_seqscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---

DROP VIEW attmp_view_new;
---END---
---START---
-- toast-like relation name
alter table stud_emp rename to pg_toast_stud_emp;
---END---
---START---
alter table pg_toast_stud_emp rename to stud_emp;
---END---
---START---

-- renaming index should rename constraint as well
ALTER TABLE onek ADD CONSTRAINT onek_unique1_constraint UNIQUE (unique1);
---END---
---START---
ALTER INDEX onek_unique1_constraint RENAME TO onek_unique1_constraint_foo;
---END---
---START---
ALTER TABLE onek DROP CONSTRAINT onek_unique1_constraint_foo;
---END---
---START---

-- renaming constraint
ALTER TABLE onek ADD CONSTRAINT onek_check_constraint CHECK (unique1 >= 0);
---END---
---START---
ALTER TABLE onek RENAME CONSTRAINT onek_check_constraint TO onek_check_constraint_foo;
---END---
---START---
ALTER TABLE onek DROP CONSTRAINT onek_check_constraint_foo;
---END---
---START---

-- renaming constraint should rename index as well
ALTER TABLE onek ADD CONSTRAINT onek_unique1_constraint UNIQUE (unique1);
---END---
---START---
DROP INDEX onek_unique1_constraint;  -- to see whether it's there
ALTER TABLE onek RENAME CONSTRAINT onek_unique1_constraint TO onek_unique1_constraint_foo;
---END---
---START---
DROP INDEX onek_unique1_constraint_foo;  -- to see whether it's there
ALTER TABLE onek DROP CONSTRAINT onek_unique1_constraint_foo;
---END---
---START---

-- renaming constraints vs. inheritance
CREATE TABLE constraint_rename_test (a int CONSTRAINT con1 CHECK (a > 0), b int, c int);
---END---
---START---
\d constraint_rename_test
CREATE TABLE constraint_rename_test2 (a int CONSTRAINT con1 CHECK (a > 0), d int) INHERITS (constraint_rename_test);
---END---
---START---
\d constraint_rename_test2
ALTER TABLE constraint_rename_test2 RENAME CONSTRAINT con1 TO con1foo; -- fail
ALTER TABLE ONLY constraint_rename_test RENAME CONSTRAINT con1 TO con1foo; -- fail
ALTER TABLE constraint_rename_test RENAME CONSTRAINT con1 TO con1foo; -- ok
\d constraint_rename_test
\d constraint_rename_test2
ALTER TABLE constraint_rename_test ADD CONSTRAINT con2 CHECK (b > 0) NO INHERIT;
---END---
---START---
ALTER TABLE ONLY constraint_rename_test RENAME CONSTRAINT con2 TO con2foo; -- ok
ALTER TABLE constraint_rename_test RENAME CONSTRAINT con2foo TO con2bar; -- ok
\d constraint_rename_test
\d constraint_rename_test2
ALTER TABLE constraint_rename_test ADD CONSTRAINT con3 PRIMARY KEY (a);
---END---
---START---
ALTER TABLE constraint_rename_test RENAME CONSTRAINT con3 TO con3foo; -- ok
\d constraint_rename_test
\d constraint_rename_test2
DROP TABLE constraint_rename_test2;
---END---
---START---
DROP TABLE constraint_rename_test;
---END---
---START---
ALTER TABLE IF EXISTS constraint_not_exist RENAME CONSTRAINT con3 TO con3foo; -- ok
ALTER TABLE IF EXISTS constraint_rename_test ADD CONSTRAINT con4 UNIQUE (a);
---END---
---START---

-- renaming constraints with cache reset of target relation
CREATE TABLE constraint_rename_cache (a int,
  CONSTRAINT chk_a CHECK (a > 0),
  PRIMARY KEY (a));
---END---
---START---
ALTER TABLE constraint_rename_cache
  RENAME CONSTRAINT chk_a TO chk_a_new;
---END---
---START---
ALTER TABLE constraint_rename_cache
  RENAME CONSTRAINT constraint_rename_cache_pkey TO constraint_rename_pkey_new;
---END---
---START---
CREATE TABLE like_constraint_rename_cache
  (LIKE constraint_rename_cache INCLUDING ALL);
---END---
---START---
\d like_constraint_rename_cache
DROP TABLE constraint_rename_cache;
---END---
---START---
DROP TABLE like_constraint_rename_cache;
---END---
---START---

-- FOREIGN KEY CONSTRAINT adding TEST

CREATE TABLE attmp2 (a int primary key);
---END---
---START---

CREATE TABLE attmp3 (a int, b int);
---END---
---START---

CREATE TABLE attmp4 (a int, b int, unique(a,b));
---END---
---START---

CREATE TABLE attmp5 (a int, b int);
---END---
---START---

-- Insert rows into attmp2 (pktable)
INSERT INTO attmp2 values (1);
---END---
---START---
INSERT INTO attmp2 values (2);
---END---
---START---
INSERT INTO attmp2 values (3);
---END---
---START---
INSERT INTO attmp2 values (4);
---END---
---START---

-- Insert rows into attmp3
INSERT INTO attmp3 values (1,10);
---END---
---START---
INSERT INTO attmp3 values (1,20);
---END---
---START---
INSERT INTO attmp3 values (5,50);
---END---
---START---

-- Try (and fail) to add constraint due to invalid source columns
ALTER TABLE attmp3 add constraint attmpconstr foreign key(c) references attmp2 match full;
---END---
---START---

-- Try (and fail) to add constraint due to invalid destination columns explicitly given
ALTER TABLE attmp3 add constraint attmpconstr foreign key(a) references attmp2(b) match full;
---END---
---START---

-- Try (and fail) to add constraint due to invalid data
ALTER TABLE attmp3 add constraint attmpconstr foreign key (a) references attmp2 match full;
---END---
---START---

-- Delete failing row
DELETE FROM attmp3 where a=5;
---END---
---START---

-- Try (and succeed)
ALTER TABLE attmp3 add constraint attmpconstr foreign key (a) references attmp2 match full;
---END---
---START---
ALTER TABLE attmp3 drop constraint attmpconstr;
---END---
---START---

INSERT INTO attmp3 values (5,50);
---END---
---START---

-- Try NOT VALID and then VALIDATE CONSTRAINT, but fails. Delete failure then re-validate
ALTER TABLE attmp3 add constraint attmpconstr foreign key (a) references attmp2 match full NOT VALID;
---END---
---START---
ALTER TABLE attmp3 validate constraint attmpconstr;
---END---
---START---

-- Delete failing row
DELETE FROM attmp3 where a=5;
---END---
---START---

-- Try (and succeed) and repeat to show it works on already valid constraint
ALTER TABLE attmp3 validate constraint attmpconstr;
---END---
---START---
ALTER TABLE attmp3 validate constraint attmpconstr;
---END---
---START---

-- Try a non-verified CHECK constraint
ALTER TABLE attmp3 ADD CONSTRAINT b_greater_than_ten CHECK (b > 10); -- fail
ALTER TABLE attmp3 ADD CONSTRAINT b_greater_than_ten CHECK (b > 10) NOT VALID; -- succeeds
ALTER TABLE attmp3 VALIDATE CONSTRAINT b_greater_than_ten; -- fails
DELETE FROM attmp3 WHERE NOT b > 10;
---END---
---START---
ALTER TABLE attmp3 VALIDATE CONSTRAINT b_greater_than_ten; -- succeeds
ALTER TABLE attmp3 VALIDATE CONSTRAINT b_greater_than_ten; -- succeeds

-- Test inherited NOT VALID CHECK constraints
select * from attmp3;
---END---
---START---
CREATE TABLE attmp6 () INHERITS (attmp3);
---END---
---START---
CREATE TABLE attmp7 () INHERITS (attmp3);
---END---
---START---

INSERT INTO attmp6 VALUES (6, 30), (7, 16);
---END---
---START---
ALTER TABLE attmp3 ADD CONSTRAINT b_le_20 CHECK (b <= 20) NOT VALID;
---END---
---START---
ALTER TABLE attmp3 VALIDATE CONSTRAINT b_le_20;	-- fails
DELETE FROM attmp6 WHERE b > 20;
---END---
---START---
ALTER TABLE attmp3 VALIDATE CONSTRAINT b_le_20;	-- succeeds

-- An already validated constraint must not be revalidated
CREATE FUNCTION boo(int) RETURNS int IMMUTABLE STRICT LANGUAGE plpgsql AS $$ BEGIN RAISE NOTICE 'boo: %', $1; RETURN $1; END; $$;
---END---
---START---
INSERT INTO attmp7 VALUES (8, 18);
---END---
---START---
ALTER TABLE attmp7 ADD CONSTRAINT identity CHECK (b = boo(b));
---END---
---START---
ALTER TABLE attmp3 ADD CONSTRAINT IDENTITY check (b = boo(b)) NOT VALID;
---END---
---START---
ALTER TABLE attmp3 VALIDATE CONSTRAINT identity;
---END---
---START---

-- A NO INHERIT constraint should not be looked for in children during VALIDATE CONSTRAINT
create table parent_noinh_convalid (a int);
---END---
---START---
create table child_noinh_convalid () inherits (parent_noinh_convalid);
---END---
---START---
insert into parent_noinh_convalid values (1);
---END---
---START---
insert into child_noinh_convalid values (1);
---END---
---START---
alter table parent_noinh_convalid add constraint check_a_is_2 check (a = 2) no inherit not valid;
---END---
---START---
-- fail, because of the row in parent
alter table parent_noinh_convalid validate constraint check_a_is_2;
---END---
---START---
delete from only parent_noinh_convalid;
---END---
---START---
-- ok (parent itself contains no violating rows)
alter table parent_noinh_convalid validate constraint check_a_is_2;
---END---
---START---
select convalidated from pg_constraint where conrelid = 'parent_noinh_convalid'::regclass and conname = 'check_a_is_2';
---END---
---START---
-- cleanup
drop table parent_noinh_convalid, child_noinh_convalid;
---END---
---START---

-- Try (and fail) to create constraint from attmp5(a) to attmp4(a) - unique constraint on
-- attmp4 is a,b

ALTER TABLE attmp5 add constraint attmpconstr foreign key(a) references attmp4(a) match full;
---END---
---START---

DROP TABLE attmp7;
---END---
---START---

DROP TABLE attmp6;
---END---
---START---

DROP TABLE attmp5;
---END---
---START---

DROP TABLE attmp4;
---END---
---START---

DROP TABLE attmp3;
---END---
---START---

DROP TABLE attmp2;
---END---
---START---

-- NOT VALID with plan invalidation -- ensure we don't use a constraint for
-- exclusion until validated
set constraint_exclusion TO 'partition';
---END---
---START---
create table nv_parent (d date, check (false) no inherit not valid);
---END---
---START---
-- not valid constraint added at creation time should automatically become valid
\d nv_parent

create table nv_child_2010 () inherits (nv_parent);
---END---
---START---
create table nv_child_2011 () inherits (nv_parent);
---END---
---START---
alter table nv_child_2010 add check (d between '2010-01-01'::date and '2010-12-31'::date) not valid;
---END---
---START---
alter table nv_child_2011 add check (d between '2011-01-01'::date and '2011-12-31'::date) not valid;
---END---
---START---
explain (costs off) select * from nv_parent where d between '2011-08-01' and '2011-08-31';
---END---
---START---
create table nv_child_2009 (check (d between '2009-01-01'::date and '2009-12-31'::date)) inherits (nv_parent);
---END---
---START---
explain (costs off) select * from nv_parent where d between '2011-08-01'::date and '2011-08-31'::date;
---END---
---START---
explain (costs off) select * from nv_parent where d between '2009-08-01'::date and '2009-08-31'::date;
---END---
---START---
-- after validation, the constraint should be used
alter table nv_child_2011 VALIDATE CONSTRAINT nv_child_2011_d_check;
---END---
---START---
explain (costs off) select * from nv_parent where d between '2009-08-01'::date and '2009-08-31'::date;
---END---
---START---

-- add an inherited NOT VALID constraint
alter table nv_parent add check (d between '2001-01-01'::date and '2099-12-31'::date) not valid;
---END---
---START---
\d nv_child_2009
-- we leave nv_parent and children around to help test pg_dump logic

-- Foreign key adding test with mixed types

-- Note: these tables are TEMP to avoid name conflicts when this test
-- is run in parallel with foreign_key.sql.

CREATE TABLE PKTABLE (ptest1 int PRIMARY KEY);
---END---
---START---
INSERT INTO PKTABLE VALUES(42);
---END---
---START---
CREATE TABLE FKTABLE (ftest1 inet);
---END---
---START---
-- This next should fail, because int=inet does not exist
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1) references pktable;
---END---
---START---
-- This should also fail for the same reason, but here we
-- give the column name
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1) references pktable(ptest1);
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
-- This should succeed, even though they are different types,
-- because int=int8 exists and is a member of the integer opfamily
CREATE TABLE FKTABLE (ftest1 int8);
---END---
---START---
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1) references pktable;
---END---
---START---
-- Check it actually works
INSERT INTO FKTABLE VALUES(42);		-- should succeed
INSERT INTO FKTABLE VALUES(43);		-- should fail
DROP TABLE FKTABLE;
---END---
---START---
-- This should fail, because we'd have to cast numeric to int which is
-- not an implicit coercion (or use numeric=numeric, but that's not part
-- of the integer opfamily)
CREATE TABLE FKTABLE (ftest1 numeric);
---END---
---START---
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1) references pktable;
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---
-- On the other hand, this should work because int implicitly promotes to
-- numeric, and we allow promotion on the FK side
CREATE TABLE PKTABLE (ptest1 numeric PRIMARY KEY);
---END---
---START---
INSERT INTO PKTABLE VALUES(42);
---END---
---START---
CREATE TABLE FKTABLE (ftest1 int);
---END---
---START---
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1) references pktable;
---END---
---START---
-- Check it actually works
INSERT INTO FKTABLE VALUES(42);		-- should succeed
INSERT INTO FKTABLE VALUES(43);		-- should fail
DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

CREATE TABLE PKTABLE (ptest1 int, ptest2 inet,
                           PRIMARY KEY(ptest1, ptest2));
---END---
---START---
-- This should fail, because we just chose really odd types
CREATE TABLE FKTABLE (ftest1 cidr, ftest2 timestamp);
---END---
---START---
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1, ftest2) references pktable;
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
-- Again, so should this...
CREATE TABLE FKTABLE (ftest1 cidr, ftest2 timestamp);
---END---
---START---
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1, ftest2)
     references pktable(ptest1, ptest2);
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
-- This fails because we mixed up the column ordering
CREATE TABLE FKTABLE (ftest1 int, ftest2 inet);
---END---
---START---
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest1, ftest2)
     references pktable(ptest2, ptest1);
---END---
---START---
-- As does this...
ALTER TABLE FKTABLE ADD FOREIGN KEY(ftest2, ftest1)
     references pktable(ptest1, ptest2);
---END---
---START---
DROP TABLE FKTABLE;
---END---
---START---
DROP TABLE PKTABLE;
---END---
---START---

-- Test that ALTER CONSTRAINT updates trigger deferrability properly

CREATE TABLE PKTABLE (ptest1 int primary key);
---END---
---START---
CREATE TABLE FKTABLE (ftest1 int);
---END---
---START---

ALTER TABLE FKTABLE ADD CONSTRAINT fknd FOREIGN KEY(ftest1) REFERENCES pktable
  ON DELETE CASCADE ON UPDATE NO ACTION NOT DEFERRABLE;
---END---
---START---
ALTER TABLE FKTABLE ADD CONSTRAINT fkdd FOREIGN KEY(ftest1) REFERENCES pktable
  ON DELETE CASCADE ON UPDATE NO ACTION DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
ALTER TABLE FKTABLE ADD CONSTRAINT fkdi FOREIGN KEY(ftest1) REFERENCES pktable
  ON DELETE CASCADE ON UPDATE NO ACTION DEFERRABLE INITIALLY IMMEDIATE;
---END---
---START---

ALTER TABLE FKTABLE ADD CONSTRAINT fknd2 FOREIGN KEY(ftest1) REFERENCES pktable
  ON DELETE CASCADE ON UPDATE NO ACTION DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
ALTER TABLE FKTABLE ALTER CONSTRAINT fknd2 NOT DEFERRABLE;
---END---
---START---
ALTER TABLE FKTABLE ADD CONSTRAINT fkdd2 FOREIGN KEY(ftest1) REFERENCES pktable
  ON DELETE CASCADE ON UPDATE NO ACTION NOT DEFERRABLE;
---END---
---START---
ALTER TABLE FKTABLE ALTER CONSTRAINT fkdd2 DEFERRABLE INITIALLY DEFERRED;
---END---
---START---
ALTER TABLE FKTABLE ADD CONSTRAINT fkdi2 FOREIGN KEY(ftest1) REFERENCES pktable
  ON DELETE CASCADE ON UPDATE NO ACTION NOT DEFERRABLE;
---END---
---START---
ALTER TABLE FKTABLE ALTER CONSTRAINT fkdi2 DEFERRABLE INITIALLY IMMEDIATE;
---END---
---START---

SELECT conname, tgfoid::regproc, tgtype, tgdeferrable, tginitdeferred
FROM pg_trigger JOIN pg_constraint con ON con.oid = tgconstraint
WHERE tgrelid = 'pktable'::regclass
ORDER BY 1,2,3;
---END---
---START---
SELECT conname, tgfoid::regproc, tgtype, tgdeferrable, tginitdeferred
FROM pg_trigger JOIN pg_constraint con ON con.oid = tgconstraint
WHERE tgrelid = 'fktable'::regclass
ORDER BY 1,2,3;
---END---
---START---

-- temp tables should go away by themselves, need not drop them.

-- test check constraint adding

create table atacc1 ( test int );
---END---
---START---
-- add a check constraint
alter table atacc1 add constraint atacc_test1 check (test>3);
---END---
---START---
-- should fail
insert into atacc1 (test) values (2);
---END---
---START---
-- should succeed
insert into atacc1 (test) values (4);
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do one where the check fails when added
create table atacc1 ( test int );
---END---
---START---
-- insert a soon to be failing row
insert into atacc1 (test) values (2);
---END---
---START---
-- add a check constraint (fails)
alter table atacc1 add constraint atacc_test1 check (test>3);
---END---
---START---
insert into atacc1 (test) values (4);
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do one where the check fails because the column doesn't exist
create table atacc1 ( test int );
---END---
---START---
-- add a check constraint (fails)
alter table atacc1 add constraint atacc_test1 check (test1>3);
---END---
---START---
drop table atacc1;
---END---
---START---

-- something a little more complicated
create table atacc1 ( test int, test2 int, test3 int);
---END---
---START---
-- add a check constraint (fails)
alter table atacc1 add constraint atacc_test1 check (test+test2<test3*4);
---END---
---START---
-- should fail
insert into atacc1 (test,test2,test3) values (4,4,2);
---END---
---START---
-- should succeed
insert into atacc1 (test,test2,test3) values (4,4,5);
---END---
---START---
drop table atacc1;
---END---
---START---

-- lets do some naming tests
create table atacc1 (test int check (test>3), test2 int);
---END---
---START---
alter table atacc1 add check (test2>test);
---END---
---START---
-- should fail for $2
insert into atacc1 (test2, test) values (3, 4);
---END---
---START---
drop table atacc1;
---END---
---START---

-- inheritance related tests
create table atacc1 (test int);
---END---
---START---
create table atacc2 (test2 int);
---END---
---START---
create table atacc3 (test3 int) inherits (atacc1, atacc2);
---END---
---START---
alter table atacc2 add constraint foo check (test2>0);
---END---
---START---
-- fail and then succeed on atacc2
insert into atacc2 (test2) values (-3);
---END---
---START---
insert into atacc2 (test2) values (3);
---END---
---START---
-- fail and then succeed on atacc3
insert into atacc3 (test2) values (-3);
---END---
---START---
insert into atacc3 (test2) values (3);
---END---
---START---
drop table atacc3;
---END---
---START---
drop table atacc2;
---END---
---START---
drop table atacc1;
---END---
---START---

-- same things with one created with INHERIT
create table atacc1 (test int);
---END---
---START---
create table atacc2 (test2 int);
---END---
---START---
create table atacc3 (test3 int) inherits (atacc1, atacc2);
---END---
---START---
alter table atacc3 no inherit atacc2;
---END---
---START---
-- fail
alter table atacc3 no inherit atacc2;
---END---
---START---
-- make sure it really isn't a child
insert into atacc3 (test2) values (3);
---END---
---START---
select test2 from atacc2;
---END---
---START---
-- fail due to missing constraint
alter table atacc2 add constraint foo check (test2>0);
---END---
---START---
alter table atacc3 inherit atacc2;
---END---
---START---
-- fail due to missing column
alter table atacc3 rename test2 to testx;
---END---
---START---
alter table atacc3 inherit atacc2;
---END---
---START---
-- fail due to mismatched data type
alter table atacc3 add test2 bool;
---END---
---START---
alter table atacc3 inherit atacc2;
---END---
---START---
alter table atacc3 drop test2;
---END---
---START---
-- succeed
alter table atacc3 add test2 int;
---END---
---START---
update atacc3 set test2 = 4 where test2 is null;
---END---
---START---
alter table atacc3 add constraint foo check (test2>0);
---END---
---START---
alter table atacc3 inherit atacc2;
---END---
---START---
-- fail due to duplicates and circular inheritance
alter table atacc3 inherit atacc2;
---END---
---START---
alter table atacc2 inherit atacc3;
---END---
---START---
alter table atacc2 inherit atacc2;
---END---
---START---
-- test that we really are a child now (should see 4 not 3 and cascade should go through)
select test2 from atacc2;
---END---
---START---
drop table atacc2 cascade;
---END---
---START---
drop table atacc1;
---END---
---START---

-- adding only to a parent is allowed as of 9.2

create table atacc1 (test int);
---END---
---START---
create table atacc2 (test2 int) inherits (atacc1);
---END---
---START---
-- ok:
alter table atacc1 add constraint foo check (test>0) no inherit;
---END---
---START---
-- check constraint is not there on child
insert into atacc2 (test) values (-3);
---END---
---START---
-- check constraint is there on parent
insert into atacc1 (test) values (-3);
---END---
---START---
insert into atacc1 (test) values (3);
---END---
---START---
-- fail, violating row:
alter table atacc2 add constraint foo check (test>0) no inherit;
---END---
---START---
drop table atacc2;
---END---
---START---
drop table atacc1;
---END---
---START---

-- test unique constraint adding

create table atacc1 ( test int ) ;
---END---
---START---
-- add a unique constraint
alter table atacc1 add constraint atacc_test1 unique (test);
---END---
---START---
-- insert first value
insert into atacc1 (test) values (2);
---END---
---START---
-- should fail
insert into atacc1 (test) values (2);
---END---
---START---
-- should succeed
insert into atacc1 (test) values (4);
---END---
---START---
-- try to create duplicates via alter table using - should fail
alter table atacc1 alter column test type integer using 0;
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do one where the unique constraint fails when added
create table atacc1 ( test int );
---END---
---START---
-- insert soon to be failing rows
insert into atacc1 (test) values (2);
---END---
---START---
insert into atacc1 (test) values (2);
---END---
---START---
-- add a unique constraint (fails)
alter table atacc1 add constraint atacc_test1 unique (test);
---END---
---START---
insert into atacc1 (test) values (3);
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do one where the unique constraint fails
-- because the column doesn't exist
create table atacc1 ( test int );
---END---
---START---
-- add a unique constraint (fails)
alter table atacc1 add constraint atacc_test1 unique (test1);
---END---
---START---
drop table atacc1;
---END---
---START---

-- something a little more complicated
create table atacc1 ( test int, test2 int);
---END---
---START---
-- add a unique constraint
alter table atacc1 add constraint atacc_test1 unique (test, test2);
---END---
---START---
-- insert initial value
insert into atacc1 (test,test2) values (4,4);
---END---
---START---
-- should fail
insert into atacc1 (test,test2) values (4,4);
---END---
---START---
-- should all succeed
insert into atacc1 (test,test2) values (4,5);
---END---
---START---
insert into atacc1 (test,test2) values (5,4);
---END---
---START---
insert into atacc1 (test,test2) values (5,5);
---END---
---START---
drop table atacc1;
---END---
---START---

-- lets do some naming tests
create table atacc1 (test int, test2 int, unique(test));
---END---
---START---
alter table atacc1 add unique (test2);
---END---
---START---
-- should fail for @@ second one @@
insert into atacc1 (test2, test) values (3, 3);
---END---
---START---
insert into atacc1 (test2, test) values (2, 3);
---END---
---START---
drop table atacc1;
---END---
---START---

-- test primary key constraint adding

create table atacc1 ( id serial, test int) ;
---END---
---START---
-- add a primary key constraint
alter table atacc1 add constraint atacc_test1 primary key (test);
---END---
---START---
-- insert first value
insert into atacc1 (test) values (2);
---END---
---START---
-- should fail
insert into atacc1 (test) values (2);
---END---
---START---
-- should succeed
insert into atacc1 (test) values (4);
---END---
---START---
-- inserting NULL should fail
insert into atacc1 (test) values(NULL);
---END---
---START---
-- try adding a second primary key (should fail)
alter table atacc1 add constraint atacc_oid1 primary key(id);
---END---
---START---
-- drop first primary key constraint
alter table atacc1 drop constraint atacc_test1 restrict;
---END---
---START---
-- try adding a primary key on oid (should succeed)
alter table atacc1 add constraint atacc_oid1 primary key(id);
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do one where the primary key constraint fails when added
create table atacc1 ( test int );
---END---
---START---
-- insert soon to be failing rows
insert into atacc1 (test) values (2);
---END---
---START---
insert into atacc1 (test) values (2);
---END---
---START---
-- add a primary key (fails)
alter table atacc1 add constraint atacc_test1 primary key (test);
---END---
---START---
insert into atacc1 (test) values (3);
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do another one where the primary key constraint fails when added
create table atacc1 ( test int );
---END---
---START---
-- insert soon to be failing row
insert into atacc1 (test) values (NULL);
---END---
---START---
-- add a primary key (fails)
alter table atacc1 add constraint atacc_test1 primary key (test);
---END---
---START---
insert into atacc1 (test) values (3);
---END---
---START---
drop table atacc1;
---END---
---START---

-- let's do one where the primary key constraint fails
-- because the column doesn't exist
create table atacc1 ( test int );
---END---
---START---
-- add a primary key constraint (fails)
alter table atacc1 add constraint atacc_test1 primary key (test1);
---END---
---START---
drop table atacc1;
---END---
---START---

-- adding a new column as primary key to a non-empty table.
-- should fail unless the column has a non-null default value.
create table atacc1 ( test int );
---END---
---START---
insert into atacc1 (test) values (0);
---END---
---START---
-- add a primary key column without a default (fails).
alter table atacc1 add column test2 int primary key;
---END---
---START---
-- now add a primary key column with a default (succeeds).
alter table atacc1 add column test2 int default 0 primary key;
---END---
---START---
drop table atacc1;
---END---
---START---

-- this combination used to have order-of-execution problems (bug #15580)
create table atacc1 (a int);
---END---
---START---
insert into atacc1 values(1);
---END---
---START---
alter table atacc1
  add column b float8 not null default random(),
  add primary key(a);
---END---
---START---
drop table atacc1;
---END---
---START---

-- additionally, we've seen issues with foreign key validation not being
-- properly delayed until after a table rewrite.  Check that works ok.
create table atacc1 (a int primary key);
---END---
---START---
alter table atacc1 add constraint atacc1_fkey foreign key (a) references atacc1 (a) not valid;
---END---
---START---
alter table atacc1 validate constraint atacc1_fkey, alter a type bigint;
---END---
---START---
drop table atacc1;
---END---
---START---

-- we've also seen issues with check constraints being validated at the wrong
-- time when there's a pending table rewrite.
create table atacc1 (a bigint, b int);
---END---
---START---
insert into atacc1 values(1,1);
---END---
---START---
alter table atacc1 add constraint atacc1_chk check(b = 1) not valid;
---END---
---START---
alter table atacc1 validate constraint atacc1_chk, alter a type int;
---END---
---START---
drop table atacc1;
---END---
---START---

-- same as above, but ensure the constraint violation is detected
create table atacc1 (a bigint, b int);
---END---
---START---
insert into atacc1 values(1,2);
---END---
---START---
alter table atacc1 add constraint atacc1_chk check(b = 1) not valid;
---END---
---START---
alter table atacc1 validate constraint atacc1_chk, alter a type int;
---END---
---START---
drop table atacc1;
---END---
---START---

-- something a little more complicated
create table atacc1 ( test int, test2 int);
---END---
---START---
-- add a primary key constraint
alter table atacc1 add constraint atacc_test1 primary key (test, test2);
---END---
---START---
-- try adding a second primary key - should fail
alter table atacc1 add constraint atacc_test2 primary key (test);
---END---
---START---
-- insert initial value
insert into atacc1 (test,test2) values (4,4);
---END---
---START---
-- should fail
insert into atacc1 (test,test2) values (4,4);
---END---
---START---
insert into atacc1 (test,test2) values (NULL,3);
---END---
---START---
insert into atacc1 (test,test2) values (3, NULL);
---END---
---START---
insert into atacc1 (test,test2) values (NULL,NULL);
---END---
---START---
-- should all succeed
insert into atacc1 (test,test2) values (4,5);
---END---
---START---
insert into atacc1 (test,test2) values (5,4);
---END---
---START---
insert into atacc1 (test,test2) values (5,5);
---END---
---START---
drop table atacc1;
---END---
---START---

-- lets do some naming tests
create table atacc1 (test int, test2 int, primary key(test));
---END---
---START---
-- only first should succeed
insert into atacc1 (test2, test) values (3, 3);
---END---
---START---
insert into atacc1 (test2, test) values (2, 3);
---END---
---START---
insert into atacc1 (test2, test) values (1, NULL);
---END---
---START---
drop table atacc1;
---END---
---START---

-- alter table / alter column [set/drop] not null tests
-- try altering system catalogs, should fail
alter table pg_class alter column relname drop not null;
---END---
---START---
alter table pg_class alter relname set not null;
---END---
---START---

-- try altering non-existent table, should fail
alter table non_existent alter column bar set not null;
---END---
---START---
alter table non_existent alter column bar drop not null;
---END---
---START---

-- test setting columns to null and not null and vice versa
-- test checking for null values and primary key
create table atacc1 (test int not null);
---END---
---START---
alter table atacc1 add constraint "atacc1_pkey" primary key (test);
---END---
---START---
alter table atacc1 alter column test drop not null;
---END---
---START---
alter table atacc1 drop constraint "atacc1_pkey";
---END---
---START---
alter table atacc1 alter column test drop not null;
---END---
---START---
insert into atacc1 values (null);
---END---
---START---
alter table atacc1 alter test set not null;
---END---
---START---
delete from atacc1;
---END---
---START---
alter table atacc1 alter test set not null;
---END---
---START---

-- try altering a non-existent column, should fail
alter table atacc1 alter bar set not null;
---END---
---START---
alter table atacc1 alter bar drop not null;
---END---
---START---

-- try creating a view and altering that, should fail
create view myview as select * from atacc1;
---END---
---START---
alter table myview alter column test drop not null;
---END---
---START---
alter table myview alter column test set not null;
---END---
---START---
drop view myview;
---END---
---START---

drop table atacc1;
---END---
---START---

-- set not null verified by constraints
create table atacc1 (test_a int, test_b int);
---END---
---START---
insert into atacc1 values (null, 1);
---END---
---START---
-- constraint not cover all values, should fail
alter table atacc1 add constraint atacc1_constr_or check(test_a is not null or test_b < 10);
---END---
---START---
alter table atacc1 alter test_a set not null;
---END---
---START---
alter table atacc1 drop constraint atacc1_constr_or;
---END---
---START---
-- not valid constraint, should fail
alter table atacc1 add constraint atacc1_constr_invalid check(test_a is not null) not valid;
---END---
---START---
alter table atacc1 alter test_a set not null;
---END---
---START---
alter table atacc1 drop constraint atacc1_constr_invalid;
---END---
---START---
-- with valid constraint
update atacc1 set test_a = 1;
---END---
---START---
alter table atacc1 add constraint atacc1_constr_a_valid check(test_a is not null);
---END---
---START---
alter table atacc1 alter test_a set not null;
---END---
---START---
delete from atacc1;
---END---
---START---

insert into atacc1 values (2, null);
---END---
---START---
alter table atacc1 alter test_a drop not null;
---END---
---START---
-- test multiple set not null at same time
-- test_a checked by atacc1_constr_a_valid, test_b should fail by table scan
alter table atacc1 alter test_a set not null, alter test_b set not null;
---END---
---START---
-- commands order has no importance
alter table atacc1 alter test_b set not null, alter test_a set not null;
---END---
---START---

-- valid one by table scan, one by check constraints
update atacc1 set test_b = 1;
---END---
---START---
alter table atacc1 alter test_b set not null, alter test_a set not null;
---END---
---START---

alter table atacc1 alter test_a drop not null, alter test_b drop not null;
---END---
---START---
-- both column has check constraints
alter table atacc1 add constraint atacc1_constr_b_valid check(test_b is not null);
---END---
---START---
alter table atacc1 alter test_b set not null, alter test_a set not null;
---END---
---START---
drop table atacc1;
---END---
---START---

-- test inheritance
create table parent (a int);
---END---
---START---
create table child (b varchar(255)) inherits (parent);
---END---
---START---

alter table parent alter a set not null;
---END---
---START---
insert into parent values (NULL);
---END---
---START---
insert into child (a, b) values (NULL, 'foo');
---END---
---START---
alter table parent alter a drop not null;
---END---
---START---
insert into parent values (NULL);
---END---
---START---
insert into child (a, b) values (NULL, 'foo');
---END---
---START---
alter table only parent alter a set not null;
---END---
---START---
alter table child alter a set not null;
---END---
---START---
delete from parent;
---END---
---START---
alter table only parent alter a set not null;
---END---
---START---
insert into parent values (NULL);
---END---
---START---
alter table child alter a set not null;
---END---
---START---
insert into child (a, b) values (NULL, 'foo');
---END---
---START---
delete from child;
---END---
---START---
alter table child alter a set not null;
---END---
---START---
insert into child (a, b) values (NULL, 'foo');
---END---
---START---
drop table child;
---END---
---START---
drop table parent;
---END---
---START---

-- test setting and removing default values
create table def_test (
	c1	int4 default 5,
	c2	text default 'initial_default'
);
---END---
---START---
insert into def_test default values;
---END---
---START---
alter table def_test alter column c1 drop default;
---END---
---START---
insert into def_test default values;
---END---
---START---
alter table def_test alter column c2 drop default;
---END---
---START---
insert into def_test default values;
---END---
---START---
alter table def_test alter column c1 set default 10;
---END---
---START---
alter table def_test alter column c2 set default 'new_default';
---END---
---START---
insert into def_test default values;
---END---
---START---
select * from def_test;
---END---
---START---

-- set defaults to an incorrect type: this should fail
alter table def_test alter column c1 set default 'wrong_datatype';
---END---
---START---
alter table def_test alter column c2 set default 20;
---END---
---START---

-- set defaults on a non-existent column: this should fail
alter table def_test alter column c3 set default 30;
---END---
---START---

-- set defaults on views: we need to create a view, add a rule
-- to allow insertions into it, and then alter the view to add
-- a default
create view def_view_test as select * from def_test;
---END---
---START---
create rule def_view_test_ins as
	on insert to def_view_test
	do instead insert into def_test select new.*;
---END---
---START---
insert into def_view_test default values;
---END---
---START---
alter table def_view_test alter column c1 set default 45;
---END---
---START---
insert into def_view_test default values;
---END---
---START---
alter table def_view_test alter column c2 set default 'view_default';
---END---
---START---
insert into def_view_test default values;
---END---
---START---
select * from def_view_test;
---END---
---START---

drop rule def_view_test_ins on def_view_test;
---END---
---START---
drop view def_view_test;
---END---
---START---
drop table def_test;
---END---
---START---

-- alter table / drop column tests
-- try altering system catalogs, should fail
alter table pg_class drop column relname;
---END---
---START---

-- try altering non-existent table, should fail
alter table nosuchtable drop column bar;
---END---
---START---

-- test dropping columns
create table atacc1 (a int4 not null, b int4, c int4 not null, d int4);
---END---
---START---
insert into atacc1 values (1, 2, 3, 4);
---END---
---START---
alter table atacc1 drop a;
---END---
---START---
alter table atacc1 drop a;
---END---
---START---

-- SELECTs
select * from atacc1;
---END---
---START---
select * from atacc1 order by a;
---END---
---START---
select * from atacc1 order by "........pg.dropped.1........";
---END---
---START---
select * from atacc1 group by a;
---END---
---START---
select * from atacc1 group by "........pg.dropped.1........";
---END---
---START---
select atacc1.* from atacc1;
---END---
---START---
select a from atacc1;
---END---
---START---
select atacc1.a from atacc1;
---END---
---START---
select b,c,d from atacc1;
---END---
---START---
select a,b,c,d from atacc1;
---END---
---START---
select * from atacc1 where a = 1;
---END---
---START---
select "........pg.dropped.1........" from atacc1;
---END---
---START---
select atacc1."........pg.dropped.1........" from atacc1;
---END---
---START---
select "........pg.dropped.1........",b,c,d from atacc1;
---END---
---START---
select * from atacc1 where "........pg.dropped.1........" = 1;
---END---
---START---

-- UPDATEs
update atacc1 set a = 3;
---END---
---START---
update atacc1 set b = 2 where a = 3;
---END---
---START---
update atacc1 set "........pg.dropped.1........" = 3;
---END---
---START---
update atacc1 set b = 2 where "........pg.dropped.1........" = 3;
---END---
---START---

-- INSERTs
insert into atacc1 values (10, 11, 12, 13);
---END---
---START---
insert into atacc1 values (default, 11, 12, 13);
---END---
---START---
insert into atacc1 values (11, 12, 13);
---END---
---START---
insert into atacc1 (a) values (10);
---END---
---START---
insert into atacc1 (a) values (default);
---END---
---START---
insert into atacc1 (a,b,c,d) values (10,11,12,13);
---END---
---START---
insert into atacc1 (a,b,c,d) values (default,11,12,13);
---END---
---START---
insert into atacc1 (b,c,d) values (11,12,13);
---END---
---START---
insert into atacc1 ("........pg.dropped.1........") values (10);
---END---
---START---
insert into atacc1 ("........pg.dropped.1........") values (default);
---END---
---START---
insert into atacc1 ("........pg.dropped.1........",b,c,d) values (10,11,12,13);
---END---
---START---
insert into atacc1 ("........pg.dropped.1........",b,c,d) values (default,11,12,13);
---END---
---START---

-- DELETEs
delete from atacc1 where a = 3;
---END---
---START---
delete from atacc1 where "........pg.dropped.1........" = 3;
---END---
---START---
delete from atacc1;
---END---
---START---

-- try dropping a non-existent column, should fail
alter table atacc1 drop bar;
---END---
---START---

-- try removing an oid column, should succeed (as it's nonexistent)
alter table atacc1 SET WITHOUT OIDS;
---END---
---START---

-- try adding an oid column, should fail (not supported)
alter table atacc1 SET WITH OIDS;
---END---
---START---

-- try dropping the xmin column, should fail
alter table atacc1 drop xmin;
---END---
---START---

-- try creating a view and altering that, should fail
create view myview as select * from atacc1;
---END---
---START---
select * from myview;
---END---
---START---
alter table myview drop d;
---END---
---START---
drop view myview;
---END---
---START---

-- test some commands to make sure they fail on the dropped column
analyze atacc1(a);
---END---
---START---
analyze atacc1("........pg.dropped.1........");
---END---
---START---
vacuum analyze atacc1(a);
---END---
---START---
vacuum analyze atacc1("........pg.dropped.1........");
---END---
---START---
comment on column atacc1.a is 'testing';
---END---
---START---
comment on column atacc1."........pg.dropped.1........" is 'testing';
---END---
---START---
alter table atacc1 alter a set storage plain;
---END---
---START---
alter table atacc1 alter "........pg.dropped.1........" set storage plain;
---END---
---START---
alter table atacc1 alter a set statistics 0;
---END---
---START---
alter table atacc1 alter "........pg.dropped.1........" set statistics 0;
---END---
---START---
alter table atacc1 alter a set default 3;
---END---
---START---
alter table atacc1 alter "........pg.dropped.1........" set default 3;
---END---
---START---
alter table atacc1 alter a drop default;
---END---
---START---
alter table atacc1 alter "........pg.dropped.1........" drop default;
---END---
---START---
alter table atacc1 alter a set not null;
---END---
---START---
alter table atacc1 alter "........pg.dropped.1........" set not null;
---END---
---START---
alter table atacc1 alter a drop not null;
---END---
---START---
alter table atacc1 alter "........pg.dropped.1........" drop not null;
---END---
---START---
alter table atacc1 rename a to x;
---END---
---START---
alter table atacc1 rename "........pg.dropped.1........" to x;
---END---
---START---
alter table atacc1 add primary key(a);
---END---
---START---
alter table atacc1 add primary key("........pg.dropped.1........");
---END---
---START---
alter table atacc1 add unique(a);
---END---
---START---
alter table atacc1 add unique("........pg.dropped.1........");
---END---
---START---
alter table atacc1 add check (a > 3);
---END---
---START---
alter table atacc1 add check ("........pg.dropped.1........" > 3);
---END---
---START---
create table atacc2 (id int4 unique);
---END---
---START---
alter table atacc1 add foreign key (a) references atacc2(id);
---END---
---START---
alter table atacc1 add foreign key ("........pg.dropped.1........") references atacc2(id);
---END---
---START---
alter table atacc2 add foreign key (id) references atacc1(a);
---END---
---START---
alter table atacc2 add foreign key (id) references atacc1("........pg.dropped.1........");
---END---
---START---
drop table atacc2;
---END---
---START---
create index "testing_idx" on atacc1(a);
---END---
---START---
create index "testing_idx" on atacc1("........pg.dropped.1........");
---END---
---START---

-- test create as and select into
insert into atacc1 values (21, 22, 23);
---END---
---START---
create table attest1 as select * from atacc1;
---END---
---START---
select * from attest1;
---END---
---START---
drop table attest1;
---END---
---START---
select * into attest2 from atacc1;
---END---
---START---
select * from attest2;
---END---
---START---
drop table attest2;
---END---
---START---

-- try dropping all columns
alter table atacc1 drop c;
---END---
---START---
alter table atacc1 drop d;
---END---
---START---
alter table atacc1 drop b;
---END---
---START---
select * from atacc1;
---END---
---START---

drop table atacc1;
---END---
---START---

-- test constraint error reporting in presence of dropped columns
create table atacc1 (id serial primary key, value int check (value < 10));
---END---
---START---
insert into atacc1(value) values (100);
---END---
---START---
alter table atacc1 drop column value;
---END---
---START---
alter table atacc1 add column value int check (value < 10);
---END---
---START---
insert into atacc1(value) values (100);
---END---
---START---
insert into atacc1(id, value) values (null, 0);
---END---
---START---
drop table atacc1;
---END---
---START---

-- test inheritance
create table parent (a int, b int, c int);
---END---
---START---
insert into parent values (1, 2, 3);
---END---
---START---
alter table parent drop a;
---END---
---START---
create table child (d varchar(255)) inherits (parent);
---END---
---START---
insert into child values (12, 13, 'testing');
---END---
---START---

select * from parent;
---END---
---START---
select * from child;
---END---
---START---
alter table parent drop c;
---END---
---START---
select * from parent;
---END---
---START---
select * from child;
---END---
---START---

drop table child;
---END---
---START---
drop table parent;
---END---
---START---

-- check error cases for inheritance column merging
create table parent (a float8, b numeric(10,4), c text collate "C");
---END---
---START---

create table child (a float4) inherits (parent); -- fail
create table child (b decimal(10,7)) inherits (parent); -- fail
create table child (c text collate "POSIX") inherits (parent); -- fail
create table child (a double precision, b decimal(10,4)) inherits (parent);
---END---
---START---

drop table child;
---END---
---START---
drop table parent;
---END---
---START---

-- test copy in/out
create table attest (a int4, b int4, c int4);
---END---
---START---
insert into attest values (1,2,3);
---END---
---START---
alter table attest drop a;
---END---
---START---
copy attest to stdout;
---END---
---START---
copy attest(a) to stdout;
---END---
---START---
copy attest("........pg.dropped.1........") to stdout;
---END---
---START---
copy attest from stdin;
---END---
---START---
10	11	12
\.
select * from attest;
---END---
---START---
copy attest from stdin;
---END---
---START---
21	22
\.
select * from attest;
---END---
---START---
copy attest(a) from stdin;
---END---
---START---
copy attest("........pg.dropped.1........") from stdin;
---END---
---START---
copy attest(b,c) from stdin;
---END---
---START---
31	32
\.
select * from attest;
---END---
---START---
drop table attest;
---END---
---START---

-- test inheritance

create table dropColumn (a int, b int, e int);
---END---
---START---
create table dropColumnChild (c int) inherits (dropColumn);
---END---
---START---
create table dropColumnAnother (d int) inherits (dropColumnChild);
---END---
---START---

-- these two should fail
alter table dropColumnchild drop column a;
---END---
---START---
alter table only dropColumnChild drop column b;
---END---
---START---



-- these three should work
alter table only dropColumn drop column e;
---END---
---START---
alter table dropColumnChild drop column c;
---END---
---START---
alter table dropColumn drop column a;
---END---
---START---

create table renameColumn (a int);
---END---
---START---
create table renameColumnChild (b int) inherits (renameColumn);
---END---
---START---
create table renameColumnAnother (c int) inherits (renameColumnChild);
---END---
---START---

-- these three should fail
alter table renameColumnChild rename column a to d;
---END---
---START---
alter table only renameColumnChild rename column a to d;
---END---
---START---
alter table only renameColumn rename column a to d;
---END---
---START---

-- these should work
alter table renameColumn rename column a to d;
---END---
---START---
alter table renameColumnChild rename column b to a;
---END---
---START---

-- these should work
alter table if exists doesnt_exist_tab rename column a to d;
---END---
---START---
alter table if exists doesnt_exist_tab rename column b to a;
---END---
---START---

-- this should work
alter table renameColumn add column w int;
---END---
---START---

-- this should fail
alter table only renameColumn add column x int;
---END---
---START---


-- Test corner cases in dropping of inherited columns

create table p1 (f1 int, f2 int);
---END---
---START---
create table c1 (f1 int not null) inherits(p1);
---END---
---START---

-- should be rejected since c1.f1 is inherited
alter table c1 drop column f1;
---END---
---START---
-- should work
alter table p1 drop column f1;
---END---
---START---
-- c1.f1 is still there, but no longer inherited
select f1 from c1;
---END---
---START---
alter table c1 drop column f1;
---END---
---START---
select f1 from c1;
---END---
---START---

drop table p1 cascade;
---END---
---START---

create table p1 (f1 int, f2 int);
---END---
---START---
create table c1 () inherits(p1);
---END---
---START---

-- should be rejected since c1.f1 is inherited
alter table c1 drop column f1;
---END---
---START---
alter table p1 drop column f1;
---END---
---START---
-- c1.f1 is dropped now, since there is no local definition for it
select f1 from c1;
---END---
---START---

drop table p1 cascade;
---END---
---START---

create table p1 (f1 int, f2 int);
---END---
---START---
create table c1 () inherits(p1);
---END---
---START---

-- should be rejected since c1.f1 is inherited
alter table c1 drop column f1;
---END---
---START---
alter table only p1 drop column f1;
---END---
---START---
-- c1.f1 is NOT dropped, but must now be considered non-inherited
alter table c1 drop column f1;
---END---
---START---

drop table p1 cascade;
---END---
---START---

create table p1 (f1 int, f2 int);
---END---
---START---
create table c1 (f1 int not null) inherits(p1);
---END---
---START---

-- should be rejected since c1.f1 is inherited
alter table c1 drop column f1;
---END---
---START---
alter table only p1 drop column f1;
---END---
---START---
-- c1.f1 is still there, but no longer inherited
alter table c1 drop column f1;
---END---
---START---

drop table p1 cascade;
---END---
---START---

create table p1(id int, name text);
---END---
---START---
create table p2(id2 int, name text, height int);
---END---
---START---
create table c1(age int) inherits(p1,p2);
---END---
---START---
create table gc1() inherits (c1);
---END---
---START---

select relname, attname, attinhcount, attislocal
from pg_class join pg_attribute on (pg_class.oid = pg_attribute.attrelid)
where relname in ('p1','p2','c1','gc1') and attnum > 0 and not attisdropped
order by relname, attnum;
---END---
---START---

-- should work
alter table only p1 drop column name;
---END---
---START---
-- should work. Now c1.name is local and inhcount is 0.
alter table p2 drop column name;
---END---
---START---
-- should be rejected since its inherited
alter table gc1 drop column name;
---END---
---START---
-- should work, and drop gc1.name along
alter table c1 drop column name;
---END---
---START---
-- should fail: column does not exist
alter table gc1 drop column name;
---END---
---START---
-- should work and drop the attribute in all tables
alter table p2 drop column height;
---END---
---START---

-- IF EXISTS test
create table dropColumnExists ();
---END---
---START---
alter table dropColumnExists drop column non_existing; --fail
alter table dropColumnExists drop column if exists non_existing; --succeed

select relname, attname, attinhcount, attislocal
from pg_class join pg_attribute on (pg_class.oid = pg_attribute.attrelid)
where relname in ('p1','p2','c1','gc1') and attnum > 0 and not attisdropped
order by relname, attnum;
---END---
---START---

drop table p1, p2 cascade;
---END---
---START---

-- test attinhcount tracking with merged columns

create table depth0();
---END---
---START---
create table depth1(c text) inherits (depth0);
---END---
---START---
create table depth2() inherits (depth1);
---END---
---START---
alter table depth0 add c text;
---END---
---START---

select attrelid::regclass, attname, attinhcount, attislocal
from pg_attribute
where attnum > 0 and attrelid::regclass in ('depth0', 'depth1', 'depth2')
order by attrelid::regclass::text, attnum;
---END---
---START---

-- test renumbering of child-table columns in inherited operations

create table p1 (f1 int);
---END---
---START---
create table c1 (f2 text, f3 int) inherits (p1);
---END---
---START---

alter table p1 add column a1 int check (a1 > 0);
---END---
---START---
alter table p1 add column f2 text;
---END---
---START---

insert into p1 values (1,2,'abc');
---END---
---START---
insert into c1 values(11,'xyz',33,0); -- should fail
insert into c1 values(11,'xyz',33,22);
---END---
---START---

select * from p1;
---END---
---START---
update p1 set a1 = a1 + 1, f2 = upper(f2);
---END---
---START---
select * from p1;
---END---
---START---

drop table p1 cascade;
---END---
---START---

-- test that operations with a dropped column do not try to reference
-- its datatype

create domain mytype as text;
---END---
---START---
create table foo (f1 text, f2 mytype, f3 text);
---END---
---START---

insert into foo values('bb','cc','dd');
---END---
---START---
select * from foo;
---END---
---START---

drop domain mytype cascade;
---END---
---START---

select * from foo;
---END---
---START---
insert into foo values('qq','rr');
---END---
---START---
select * from foo;
---END---
---START---
update foo set f3 = 'zz';
---END---
---START---
select * from foo;
---END---
---START---
select f3,max(f1) from foo group by f3;
---END---
---START---

-- Simple tests for alter table column type
alter table foo alter f1 TYPE integer; -- fails
alter table foo alter f1 TYPE varchar(10);
---END---
---START---

create table anothertab (atcol1 serial8, atcol2 boolean,
	constraint anothertab_chk check (atcol1 <= 3));
---END---
---START---

insert into anothertab (atcol1, atcol2) values (default, true);
---END---
---START---
insert into anothertab (atcol1, atcol2) values (default, false);
---END---
---START---
select * from anothertab;
---END---
---START---

alter table anothertab alter column atcol1 type boolean; -- fails
alter table anothertab alter column atcol1 type boolean using atcol1::int; -- fails
alter table anothertab alter column atcol1 type integer;
---END---
---START---

select * from anothertab;
---END---
---START---

insert into anothertab (atcol1, atcol2) values (45, null); -- fails
insert into anothertab (atcol1, atcol2) values (default, null);
---END---
---START---

select * from anothertab;
---END---
---START---

alter table anothertab alter column atcol2 type text
      using case when atcol2 is true then 'IT WAS TRUE'
                 when atcol2 is false then 'IT WAS FALSE'
                 else 'IT WAS NULL!' end;
---END---
---START---

select * from anothertab;
---END---
---START---
alter table anothertab alter column atcol1 type boolean
        using case when atcol1 % 2 = 0 then true else false end; -- fails
alter table anothertab alter column atcol1 drop default;
---END---
---START---
alter table anothertab alter column atcol1 type boolean
        using case when atcol1 % 2 = 0 then true else false end; -- fails
alter table anothertab drop constraint anothertab_chk;
---END---
---START---
alter table anothertab drop constraint anothertab_chk; -- fails
alter table anothertab drop constraint IF EXISTS anothertab_chk; -- succeeds

alter table anothertab alter column atcol1 type boolean
        using case when atcol1 % 2 = 0 then true else false end;
---END---
---START---

select * from anothertab;
---END---
---START---

drop table anothertab;
---END---
---START---

-- Test index handling in alter table column type (cf. bugs #15835, #15865)
create table anothertab(f1 int primary key, f2 int unique,
                        f3 int, f4 int, f5 int);
---END---
---START---
alter table anothertab
  add exclude using btree (f3 with =);
---END---
---START---
alter table anothertab
  add exclude using btree (f4 with =) where (f4 is not null);
---END---
---START---
alter table anothertab
  add exclude using btree (f4 with =) where (f5 > 0);
---END---
---START---
alter table anothertab
  add unique(f1,f4);
---END---
---START---
create index on anothertab(f2,f3);
---END---
---START---
create unique index on anothertab(f4);
---END---
---START---

\d anothertab
alter table anothertab alter column f1 type bigint;
---END---
---START---
alter table anothertab
  alter column f2 type bigint,
  alter column f3 type bigint,
  alter column f4 type bigint;
---END---
---START---
alter table anothertab alter column f5 type bigint;
---END---
---START---
\d anothertab

drop table anothertab;
---END---
---START---

-- test that USING expressions are parsed before column alter type / drop steps
create table another (f1 int, f2 text, f3 text);
---END---
---START---

insert into another values(1, 'one', 'uno');
---END---
---START---
insert into another values(2, 'two', 'due');
---END---
---START---
insert into another values(3, 'three', 'tre');
---END---
---START---

select * from another;
---END---
---START---

alter table another
  alter f1 type text using f2 || ' and ' || f3 || ' more',
  alter f2 type bigint using f1 * 10,
  drop column f3;
---END---
---START---

select * from another;
---END---
---START---

drop table another;
---END---
---START---

-- Create an index that skips WAL, then perform a SET DATA TYPE that skips
-- rewriting the index.
begin;
---END---
---START---
create table skip_wal_skip_rewrite_index (c varchar(10) primary key);
---END---
---START---
alter table skip_wal_skip_rewrite_index alter c type varchar(20);
---END---
---START---
commit;
---END---
---START---

-- We disallow changing table's row type if it's used for storage
create table at_tab1 (a int, b text);
---END---
---START---
create table at_tab2 (x int, y at_tab1);
---END---
---START---
alter table at_tab1 alter column b type varchar; -- fails
drop table at_tab2;
---END---
---START---
-- Use of row type in an expression is defended differently
create table at_tab2 (x int, y text, check((x,y)::at_tab1 = (1,'42')::at_tab1));
---END---
---START---
alter table at_tab1 alter column b type varchar; -- allowed, but ...
insert into at_tab2 values(1,'42'); -- ... this will fail
drop table at_tab1, at_tab2;
---END---
---START---
-- Check it for a partitioned table, too
create table at_tab1 (a int, b text) partition by list(a);
---END---
---START---
create table at_tab2 (x int, y at_tab1);
---END---
---START---
alter table at_tab1 alter column b type varchar; -- fails
drop table at_tab1, at_tab2;
---END---
---START---

-- Alter column type that's part of a partitioned index
create table at_partitioned (a int, b text) partition by range (a);
---END---
---START---
create table at_part_1 partition of at_partitioned for values from (0) to (1000);
---END---
---START---
insert into at_partitioned values (512, '0.123');
---END---
---START---
create table at_part_2 (b text, a int);
---END---
---START---
insert into at_part_2 values ('1.234', 1024);
---END---
---START---
create index on at_partitioned (b);
---END---
---START---
create index on at_partitioned (a);
---END---
---START---
\d at_part_1
\d at_part_2
alter table at_partitioned attach partition at_part_2 for values from (1000) to (2000);
---END---
---START---
\d at_part_2
alter table at_partitioned alter column b type numeric using b::numeric;
---END---
---START---
\d at_part_1
\d at_part_2
drop table at_partitioned;
---END---
---START---

-- Alter column type when no table rewrite is required
-- Also check that comments are preserved
create table at_partitioned(id int, name varchar(64), unique (id, name))
  partition by hash(id);
---END---
---START---
comment on constraint at_partitioned_id_name_key on at_partitioned is 'parent constraint';
---END---
---START---
comment on index at_partitioned_id_name_key is 'parent index';
---END---
---START---
create table at_partitioned_0 partition of at_partitioned
  for values with (modulus 2, remainder 0);
---END---
---START---
comment on constraint at_partitioned_0_id_name_key on at_partitioned_0 is 'child 0 constraint';
---END---
---START---
comment on index at_partitioned_0_id_name_key is 'child 0 index';
---END---
---START---
create table at_partitioned_1 partition of at_partitioned
  for values with (modulus 2, remainder 1);
---END---
---START---
comment on constraint at_partitioned_1_id_name_key on at_partitioned_1 is 'child 1 constraint';
---END---
---START---
comment on index at_partitioned_1_id_name_key is 'child 1 index';
---END---
---START---
insert into at_partitioned values(1, 'foo');
---END---
---START---
insert into at_partitioned values(3, 'bar');
---END---
---START---

create table old_oids as
  select relname, oid as oldoid, relfilenode as oldfilenode
  from pg_class where relname like 'at_partitioned%';
---END---
---START---

select relname,
  c.oid = oldoid as orig_oid,
  case relfilenode
    when 0 then 'none'
    when c.oid then 'own'
    when oldfilenode then 'orig'
    else 'OTHER'
    end as storage,
  obj_description(c.oid, 'pg_class') as desc
  from pg_class c left join old_oids using (relname)
  where relname like 'at_partitioned%'
  order by relname;
---END---
---START---

select conname, obj_description(oid, 'pg_constraint') as desc
  from pg_constraint where conname like 'at_partitioned%'
  order by conname;
---END---
---START---

alter table at_partitioned alter column name type varchar(127);
---END---
---START---

-- Note: these tests currently show the wrong behavior for comments :-(

select relname,
  c.oid = oldoid as orig_oid,
  case relfilenode
    when 0 then 'none'
    when c.oid then 'own'
    when oldfilenode then 'orig'
    else 'OTHER'
    end as storage,
  obj_description(c.oid, 'pg_class') as desc
  from pg_class c left join old_oids using (relname)
  where relname like 'at_partitioned%'
  order by relname;
---END---
---START---

select conname, obj_description(oid, 'pg_constraint') as desc
  from pg_constraint where conname like 'at_partitioned%'
  order by conname;
---END---
---START---

-- Don't remove this DROP, it exposes bug #15672
drop table at_partitioned;
---END---
---START---

-- disallow recursive containment of row types
create table recur1 (f1 int);
---END---
---START---
alter table recur1 add column f2 recur1; -- fails
alter table recur1 add column f2 recur1[]; -- fails
create domain array_of_recur1 as recur1[];
---END---
---START---
alter table recur1 add column f2 array_of_recur1; -- fails
create table recur2 (f1 int, f2 recur1);
---END---
---START---
alter table recur1 add column f2 recur2; -- fails
alter table recur1 add column f2 int;
---END---
---START---
alter table recur1 alter column f2 type recur2; -- fails

-- SET STORAGE may need to add a TOAST table
create table test_storage (a text, c text storage plain);
---END---
---START---
select reltoastrelid <> 0 as has_toast_table
  from pg_class where oid = 'test_storage'::regclass;
---END---
---START---
alter table test_storage alter a set storage plain;
---END---
---START---
-- rewrite table to remove its TOAST table; need a non-constant column default
alter table test_storage add b int default random()::int;
---END---
---START---
select reltoastrelid <> 0 as has_toast_table
  from pg_class where oid = 'test_storage'::regclass;
---END---
---START---
alter table test_storage alter a set storage default; -- re-add TOAST table
select reltoastrelid <> 0 as has_toast_table
  from pg_class where oid = 'test_storage'::regclass;
---END---
---START---

-- check STORAGE correctness
create table test_storage_failed (a text, b int storage extended);
---END---
---START---

-- test that SET STORAGE propagates to index correctly
create index test_storage_idx on test_storage (b, a);
---END---
---START---
alter table test_storage alter column a set storage external;
---END---
---START---
\d+ test_storage
\d+ test_storage_idx

-- ALTER COLUMN TYPE with a check constraint and a child table (bug #13779)
CREATE TABLE test_inh_check (a float check (a > 10.2), b float);
---END---
---START---
CREATE TABLE test_inh_check_child() INHERITS(test_inh_check);
---END---
---START---
\d test_inh_check
\d test_inh_check_child
select relname, conname, coninhcount, conislocal, connoinherit
  from pg_constraint c, pg_class r
  where relname like 'test_inh_check%' and c.conrelid = r.oid
  order by 1, 2;
---END---
---START---
ALTER TABLE test_inh_check ALTER COLUMN a TYPE numeric;
---END---
---START---
\d test_inh_check
\d test_inh_check_child
select relname, conname, coninhcount, conislocal, connoinherit
  from pg_constraint c, pg_class r
  where relname like 'test_inh_check%' and c.conrelid = r.oid
  order by 1, 2;
---END---
---START---
-- also try noinherit, local, and local+inherited cases
ALTER TABLE test_inh_check ADD CONSTRAINT bnoinherit CHECK (b > 100) NO INHERIT;
---END---
---START---
ALTER TABLE test_inh_check_child ADD CONSTRAINT blocal CHECK (b < 1000);
---END---
---START---
ALTER TABLE test_inh_check_child ADD CONSTRAINT bmerged CHECK (b > 1);
---END---
---START---
ALTER TABLE test_inh_check ADD CONSTRAINT bmerged CHECK (b > 1);
---END---
---START---
\d test_inh_check
\d test_inh_check_child
select relname, conname, coninhcount, conislocal, connoinherit
  from pg_constraint c, pg_class r
  where relname like 'test_inh_check%' and c.conrelid = r.oid
  order by 1, 2;
---END---
---START---
ALTER TABLE test_inh_check ALTER COLUMN b TYPE numeric;
---END---
---START---
\d test_inh_check
\d test_inh_check_child
select relname, conname, coninhcount, conislocal, connoinherit
  from pg_constraint c, pg_class r
  where relname like 'test_inh_check%' and c.conrelid = r.oid
  order by 1, 2;
---END---
---START---

-- ALTER COLUMN TYPE with different schema in children
-- Bug at https://postgr.es/m/20170102225618.GA10071@telsasoft.com
CREATE TABLE test_type_diff (f1 int);
---END---
---START---
CREATE TABLE test_type_diff_c (extra smallint) INHERITS (test_type_diff);
---END---
---START---
ALTER TABLE test_type_diff ADD COLUMN f2 int;
---END---
---START---
INSERT INTO test_type_diff_c VALUES (1, 2, 3);
---END---
---START---
ALTER TABLE test_type_diff ALTER COLUMN f2 TYPE bigint USING f2::bigint;
---END---
---START---

CREATE TABLE test_type_diff2 (int_two int2, int_four int4, int_eight int8);
---END---
---START---
CREATE TABLE test_type_diff2_c1 (int_four int4, int_eight int8, int_two int2);
---END---
---START---
CREATE TABLE test_type_diff2_c2 (int_eight int8, int_two int2, int_four int4);
---END---
---START---
CREATE TABLE test_type_diff2_c3 (int_two int2, int_four int4, int_eight int8);
---END---
---START---
ALTER TABLE test_type_diff2_c1 INHERIT test_type_diff2;
---END---
---START---
ALTER TABLE test_type_diff2_c2 INHERIT test_type_diff2;
---END---
---START---
ALTER TABLE test_type_diff2_c3 INHERIT test_type_diff2;
---END---
---START---
INSERT INTO test_type_diff2_c1 VALUES (1, 2, 3);
---END---
---START---
INSERT INTO test_type_diff2_c2 VALUES (4, 5, 6);
---END---
---START---
INSERT INTO test_type_diff2_c3 VALUES (7, 8, 9);
---END---
---START---
ALTER TABLE test_type_diff2 ALTER COLUMN int_four TYPE int8 USING int_four::int8;
---END---
---START---
-- whole-row references are disallowed
ALTER TABLE test_type_diff2 ALTER COLUMN int_four TYPE int4 USING (pg_column_size(test_type_diff2));
---END---
---START---

-- check for rollback of ANALYZE corrupting table property flags (bug #11638)
CREATE TABLE check_fk_presence_1 (id int PRIMARY KEY, t text);
---END---
---START---
CREATE TABLE check_fk_presence_2 (id int REFERENCES check_fk_presence_1, t text);
---END---
---START---
BEGIN;
---END---
---START---
ALTER TABLE check_fk_presence_2 DROP CONSTRAINT check_fk_presence_2_id_fkey;
---END---
---START---
ANALYZE check_fk_presence_2;
---END---
---START---
ROLLBACK;
---END---
---START---
\d check_fk_presence_2
DROP TABLE check_fk_presence_1, check_fk_presence_2;
---END---
---START---

-- check column addition within a view (bug #14876)
create table at_base_table(id int, stuff text);
---END---
---START---
insert into at_base_table values (23, 'skidoo');
---END---
---START---
create view at_view_1 as select * from at_base_table bt;
---END---
---START---
create view at_view_2 as select *, to_json(v1) as j from at_view_1 v1;
---END---
---START---
\d+ at_view_1
\d+ at_view_2
explain (verbose, costs off) select * from at_view_2;
---END---
---START---
select * from at_view_2;
---END---
---START---

create or replace view at_view_1 as select *, 2+2 as more from at_base_table bt;
---END---
---START---
\d+ at_view_1
\d+ at_view_2
explain (verbose, costs off) select * from at_view_2;
---END---
---START---
select * from at_view_2;
---END---
---START---

drop view at_view_2;
---END---
---START---
drop view at_view_1;
---END---
---START---
drop table at_base_table;
---END---
---START---

-- related case (bug #17811)
begin;
---END---
---START---
create table t1 as select * from int8_tbl;
---END---
---START---
create temp view v1 as select 1::int8 as q1;
---END---
---START---
create temp view v2 as select * from v1;
---END---
---START---
create or replace temp view v1 with (security_barrier = true)
  as select * from t1;
---END---
---START---

create table log (q1 int8, q2 int8);
---END---
---START---
create rule v1_upd_rule as on update to v1
  do also insert into log values (new.*);
---END---
---START---

update v2 set q1 = q1 + 1 where q1 = 123;
---END---
---START---

select * from t1;
---END---
---START---
select * from log;
---END---
---START---
rollback;
---END---
---START---

-- check adding a column not itself requiring a rewrite, together with
-- a column requiring a default (bug #16038)

-- ensure that rewrites aren't silently optimized away, removing the
-- value of the test
CREATE FUNCTION check_ddl_rewrite(p_tablename regclass, p_ddl text)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
    v_relfilenode oid;
---END---
---START---
BEGIN
    v_relfilenode := relfilenode FROM pg_class WHERE oid = p_tablename;
---END---
---START---

    EXECUTE p_ddl;
---END---
---START---

    RETURN v_relfilenode <> (SELECT relfilenode FROM pg_class WHERE oid = p_tablename);
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

CREATE TABLE rewrite_test(col text);
---END---
---START---
INSERT INTO rewrite_test VALUES ('something');
---END---
---START---
INSERT INTO rewrite_test VALUES (NULL);
---END---
---START---

-- empty[12] don't need rewrite, but notempty[12]_rewrite will force one
SELECT check_ddl_rewrite('rewrite_test', $$
  ALTER TABLE rewrite_test
      ADD COLUMN empty1 text,
      ADD COLUMN notempty1_rewrite serial;
---END---
---START---
$$);
---END---
---START---
SELECT check_ddl_rewrite('rewrite_test', $$
    ALTER TABLE rewrite_test
        ADD COLUMN notempty2_rewrite serial,
        ADD COLUMN empty2 text;
---END---
---START---
$$);
---END---
---START---
-- also check that fast defaults cause no problem, first without rewrite
SELECT check_ddl_rewrite('rewrite_test', $$
    ALTER TABLE rewrite_test
        ADD COLUMN empty3 text,
        ADD COLUMN notempty3_norewrite int default 42;
---END---
---START---
$$);
---END---
---START---
SELECT check_ddl_rewrite('rewrite_test', $$
    ALTER TABLE rewrite_test
        ADD COLUMN notempty4_norewrite int default 42,
        ADD COLUMN empty4 text;
---END---
---START---
$$);
---END---
---START---
-- then with rewrite
SELECT check_ddl_rewrite('rewrite_test', $$
    ALTER TABLE rewrite_test
        ADD COLUMN empty5 text,
        ADD COLUMN notempty5_norewrite int default 42,
        ADD COLUMN notempty5_rewrite serial;
---END---
---START---
$$);
---END---
---START---
SELECT check_ddl_rewrite('rewrite_test', $$
    ALTER TABLE rewrite_test
        ADD COLUMN notempty6_rewrite serial,
        ADD COLUMN empty6 text,
        ADD COLUMN notempty6_norewrite int default 42;
---END---
---START---
$$);
---END---
---START---

-- cleanup
DROP FUNCTION check_ddl_rewrite(regclass, text);
---END---
---START---
DROP TABLE rewrite_test;
---END---
---START---

--
-- lock levels
--
drop type lockmodes;
---END---
---START---
create type lockmodes as enum (
 'SIReadLock'
,'AccessShareLock'
,'RowShareLock'
,'RowExclusiveLock'
,'ShareUpdateExclusiveLock'
,'ShareLock'
,'ShareRowExclusiveLock'
,'ExclusiveLock'
,'AccessExclusiveLock'
);
---END---
---START---

drop view my_locks;
---END---
---START---
create or replace view my_locks as
select case when c.relname like 'pg_toast%' then 'pg_toast' else c.relname end, max(mode::lockmodes) as max_lockmode
from pg_locks l join pg_class c on l.relation = c.oid
where virtualtransaction = (
        select virtualtransaction
        from pg_locks
        where transactionid = pg_current_xact_id()::xid)
and locktype = 'relation'
and relnamespace != (select oid from pg_namespace where nspname = 'pg_catalog')
and c.relname != 'my_locks'
group by c.relname;
---END---
---START---

create table alterlock (f1 int primary key, f2 text);
---END---
---START---
insert into alterlock values (1, 'foo');
---END---
---START---
create table alterlock2 (f3 int primary key, f1 int);
---END---
---START---
insert into alterlock2 values (1, 1);
---END---
---START---

begin; alter table alterlock alter column f2 set statistics 150;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

begin; alter table alterlock cluster on alterlock_pkey;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock set without cluster;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock set (fillfactor = 100);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock reset (fillfactor);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock set (toast.autovacuum_enabled = off);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock set (autovacuum_enabled = off);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock alter column f2 set (n_distinct = 1);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

-- test that mixing options with different lock levels works as expected
begin; alter table alterlock set (autovacuum_enabled = off, fillfactor = 80);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---

begin; alter table alterlock alter column f2 set storage extended;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

begin; alter table alterlock alter column f2 set default 'x';
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

begin;
---END---
---START---
create trigger ttdummy
	before delete or update on alterlock
	for each row
	execute procedure
	ttdummy (1, 1);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

begin;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
alter table alterlock2 add foreign key (f1) references alterlock (f1);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

begin;
---END---
---START---
alter table alterlock2
add constraint alterlock2nv foreign key (f1) references alterlock (f1) NOT VALID;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
commit;
---END---
---START---
begin;
---END---
---START---
alter table alterlock2 validate constraint alterlock2nv;
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
rollback;
---END---
---START---

create or replace view my_locks as
select case when c.relname like 'pg_toast%' then 'pg_toast' else c.relname end, max(mode::lockmodes) as max_lockmode
from pg_locks l join pg_class c on l.relation = c.oid
where virtualtransaction = (
        select virtualtransaction
        from pg_locks
        where transactionid = pg_current_xact_id()::xid)
and locktype = 'relation'
and relnamespace != (select oid from pg_namespace where nspname = 'pg_catalog')
and c.relname = 'my_locks'
group by c.relname;
---END---
---START---

-- raise exception
alter table my_locks set (autovacuum_enabled = false);
---END---
---START---
alter view my_locks set (autovacuum_enabled = false);
---END---
---START---
alter table my_locks reset (autovacuum_enabled);
---END---
---START---
alter view my_locks reset (autovacuum_enabled);
---END---
---START---

begin;
---END---
---START---
alter view my_locks set (security_barrier=off);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
alter view my_locks reset (security_barrier);
---END---
---START---
rollback;
---END---
---START---

-- this test intentionally applies the ALTER TABLE command against a view, but
-- uses a view option so we expect this to succeed. This form of SQL is
-- accepted for historical reasons, as shown in the docs for ALTER VIEW
begin;
---END---
---START---
alter table my_locks set (security_barrier=off);
---END---
---START---
select * from my_locks order by 1;
---END---
---START---
alter table my_locks reset (security_barrier);
---END---
---START---
rollback;
---END---
---START---

-- cleanup
drop table alterlock2;
---END---
---START---
drop table alterlock;
---END---
---START---
drop view my_locks;
---END---
---START---
drop type lockmodes;
---END---
---START---

--
-- alter function
--
create function test_strict(text) returns text as
    'select coalesce($1, ''got passed a null'');'
    language sql returns null on null input;
---END---
---START---
select test_strict(NULL);
---END---
---START---
alter function test_strict(text) called on null input;
---END---
---START---
select test_strict(NULL);
---END---
---START---

create function non_strict(text) returns text as
    'select coalesce($1, ''got passed a null'');'
    language sql called on null input;
---END---
---START---
select non_strict(NULL);
---END---
---START---
alter function non_strict(text) returns null on null input;
---END---
---START---
select non_strict(NULL);
---END---
---START---

--
-- alter object set schema
--

create schema alter1;
---END---
---START---
create schema alter2;
---END---
---START---

create table alter1.t1(f1 serial primary key, f2 int check (f2 > 0));
---END---
---START---

create view alter1.v1 as select * from alter1.t1;
---END---
---START---

create function alter1.plus1(int) returns int as 'select $1+1' language sql;
---END---
---START---

create domain alter1.posint integer check (value > 0);
---END---
---START---

create type alter1.ctype as (f1 int, f2 text);
---END---
---START---

create function alter1.same(alter1.ctype, alter1.ctype) returns boolean language sql
as 'select $1.f1 is not distinct from $2.f1 and $1.f2 is not distinct from $2.f2';
---END---
---START---

create operator alter1.=(procedure = alter1.same, leftarg  = alter1.ctype, rightarg = alter1.ctype);
---END---
---START---

create operator class alter1.ctype_hash_ops default for type alter1.ctype using hash as
  operator 1 alter1.=(alter1.ctype, alter1.ctype);
---END---
---START---

create conversion alter1.latin1_to_utf8 for 'latin1' to 'utf8' from iso8859_1_to_utf8;
---END---
---START---

create text search parser alter1.prs(start = prsd_start, gettoken = prsd_nexttoken, end = prsd_end, lextypes = prsd_lextype);
---END---
---START---
create text search configuration alter1.cfg(parser = alter1.prs);
---END---
---START---
create text search template alter1.tmpl(init = dsimple_init, lexize = dsimple_lexize);
---END---
---START---
create text search dictionary alter1.dict(template = alter1.tmpl);
---END---
---START---

insert into alter1.t1(f2) values(11);
---END---
---START---
insert into alter1.t1(f2) values(12);
---END---
---START---

alter table alter1.t1 set schema alter1; -- no-op, same schema
alter table alter1.t1 set schema alter2;
---END---
---START---
alter table alter1.v1 set schema alter2;
---END---
---START---
alter function alter1.plus1(int) set schema alter2;
---END---
---START---
alter domain alter1.posint set schema alter2;
---END---
---START---
alter operator class alter1.ctype_hash_ops using hash set schema alter2;
---END---
---START---
alter operator family alter1.ctype_hash_ops using hash set schema alter2;
---END---
---START---
alter operator alter1.=(alter1.ctype, alter1.ctype) set schema alter2;
---END---
---START---
alter function alter1.same(alter1.ctype, alter1.ctype) set schema alter2;
---END---
---START---
alter type alter1.ctype set schema alter1; -- no-op, same schema
alter type alter1.ctype set schema alter2;
---END---
---START---
alter conversion alter1.latin1_to_utf8 set schema alter2;
---END---
---START---
alter text search parser alter1.prs set schema alter2;
---END---
---START---
alter text search configuration alter1.cfg set schema alter2;
---END---
---START---
alter text search template alter1.tmpl set schema alter2;
---END---
---START---
alter text search dictionary alter1.dict set schema alter2;
---END---
---START---

-- this should succeed because nothing is left in alter1
drop schema alter1;
---END---
---START---

insert into alter2.t1(f2) values(13);
---END---
---START---
insert into alter2.t1(f2) values(14);
---END---
---START---

select * from alter2.t1;
---END---
---START---

select * from alter2.v1;
---END---
---START---

select alter2.plus1(41);
---END---
---START---

-- clean up
drop schema alter2 cascade;
---END---
---START---

--
-- composite types
--

CREATE TYPE test_type AS (a int);
---END---
---START---
\d test_type

ALTER TYPE nosuchtype ADD ATTRIBUTE b text; -- fails

ALTER TYPE test_type ADD ATTRIBUTE b text;
---END---
---START---
\d test_type

ALTER TYPE test_type ADD ATTRIBUTE b text; -- fails

ALTER TYPE test_type ALTER ATTRIBUTE b SET DATA TYPE varchar;
---END---
---START---
\d test_type

ALTER TYPE test_type ALTER ATTRIBUTE b SET DATA TYPE integer;
---END---
---START---
\d test_type

ALTER TYPE test_type DROP ATTRIBUTE b;
---END---
---START---
\d test_type

ALTER TYPE test_type DROP ATTRIBUTE c; -- fails

ALTER TYPE test_type DROP ATTRIBUTE IF EXISTS c;
---END---
---START---

ALTER TYPE test_type DROP ATTRIBUTE a, ADD ATTRIBUTE d boolean;
---END---
---START---
\d test_type

ALTER TYPE test_type RENAME ATTRIBUTE a TO aa;
---END---
---START---
ALTER TYPE test_type RENAME ATTRIBUTE d TO dd;
---END---
---START---
\d test_type

DROP TYPE test_type;
---END---
---START---

CREATE TYPE test_type1 AS (a int, b text);
---END---
---START---
CREATE TABLE test_tbl1 (x int, y test_type1);
---END---
---START---
ALTER TYPE test_type1 ALTER ATTRIBUTE b TYPE varchar; -- fails

DROP TABLE test_tbl1;
---END---
---START---
CREATE TABLE test_tbl1 (x int, y text);
---END---
---START---
CREATE INDEX test_tbl1_idx ON test_tbl1((row(x,y)::test_type1));
---END---
---START---
ALTER TYPE test_type1 ALTER ATTRIBUTE b TYPE varchar; -- fails

DROP TABLE test_tbl1;
---END---
---START---
DROP TYPE test_type1;
---END---
---START---

CREATE TYPE test_type2 AS (a int, b text);
---END---
---START---
CREATE TABLE test_tbl2 OF test_type2;
---END---
---START---
CREATE TABLE test_tbl2_subclass () INHERITS (test_tbl2);
---END---
---START---
\d test_type2
\d test_tbl2

ALTER TYPE test_type2 ADD ATTRIBUTE c text; -- fails
ALTER TYPE test_type2 ADD ATTRIBUTE c text CASCADE;
---END---
---START---
\d test_type2
\d test_tbl2

ALTER TYPE test_type2 ALTER ATTRIBUTE b TYPE varchar; -- fails
ALTER TYPE test_type2 ALTER ATTRIBUTE b TYPE varchar CASCADE;
---END---
---START---
\d test_type2
\d test_tbl2

ALTER TYPE test_type2 DROP ATTRIBUTE b; -- fails
ALTER TYPE test_type2 DROP ATTRIBUTE b CASCADE;
---END---
---START---
\d test_type2
\d test_tbl2

ALTER TYPE test_type2 RENAME ATTRIBUTE a TO aa; -- fails
ALTER TYPE test_type2 RENAME ATTRIBUTE a TO aa CASCADE;
---END---
---START---
\d test_type2
\d test_tbl2
\d test_tbl2_subclass

DROP TABLE test_tbl2_subclass, test_tbl2;
---END---
---START---
DROP TYPE test_type2;
---END---
---START---

CREATE TYPE test_typex AS (a int, b text);
---END---
---START---
CREATE TABLE test_tblx (x int, y test_typex check ((y).a > 0));
---END---
---START---
ALTER TYPE test_typex DROP ATTRIBUTE a; -- fails
ALTER TYPE test_typex DROP ATTRIBUTE a CASCADE;
---END---
---START---
\d test_tblx
DROP TABLE test_tblx;
---END---
---START---
DROP TYPE test_typex;
---END---
---START---

-- This test isn't that interesting on its own, but the purpose is to leave
-- behind a table to test pg_upgrade with. The table has a composite type
-- column in it, and the composite type has a dropped attribute.
CREATE TYPE test_type3 AS (a int);
---END---
---START---
CREATE TABLE test_tbl3 (c) AS SELECT '(1)'::test_type3;
---END---
---START---
ALTER TYPE test_type3 DROP ATTRIBUTE a, ADD ATTRIBUTE b int;
---END---
---START---

CREATE TYPE test_type_empty AS ();
---END---
---START---
DROP TYPE test_type_empty;
---END---
---START---

--
-- typed tables: OF / NOT OF
--

CREATE TYPE tt_t0 AS (z inet, x int, y numeric(8,2));
---END---
---START---
ALTER TYPE tt_t0 DROP ATTRIBUTE z;
---END---
---START---
CREATE TABLE tt0 (x int NOT NULL, y numeric(8,2));	-- OK
CREATE TABLE tt1 (x int, y bigint);					-- wrong base type
CREATE TABLE tt2 (x int, y numeric(9,2));			-- wrong typmod
CREATE TABLE tt3 (y numeric(8,2), x int);			-- wrong column order
CREATE TABLE tt4 (x int);							-- too few columns
CREATE TABLE tt5 (x int, y numeric(8,2), z int);	-- too few columns
CREATE TABLE tt6 () INHERITS (tt0);					-- can't have a parent
CREATE TABLE tt7 (x int, q text, y numeric(8,2));
---END---
---START---
ALTER TABLE tt7 DROP q;								-- OK

ALTER TABLE tt0 OF tt_t0;
---END---
---START---
ALTER TABLE tt1 OF tt_t0;
---END---
---START---
ALTER TABLE tt2 OF tt_t0;
---END---
---START---
ALTER TABLE tt3 OF tt_t0;
---END---
---START---
ALTER TABLE tt4 OF tt_t0;
---END---
---START---
ALTER TABLE tt5 OF tt_t0;
---END---
---START---
ALTER TABLE tt6 OF tt_t0;
---END---
---START---
ALTER TABLE tt7 OF tt_t0;
---END---
---START---

CREATE TYPE tt_t1 AS (x int, y numeric(8,2));
---END---
---START---
ALTER TABLE tt7 OF tt_t1;			-- reassign an already-typed table
ALTER TABLE tt7 NOT OF;
---END---
---START---
\d tt7

-- make sure we can drop a constraint on the parent but it remains on the child
CREATE TABLE test_drop_constr_parent (c text CHECK (c IS NOT NULL));
---END---
---START---
CREATE TABLE test_drop_constr_child () INHERITS (test_drop_constr_parent);
---END---
---START---
ALTER TABLE ONLY test_drop_constr_parent DROP CONSTRAINT "test_drop_constr_parent_c_check";
---END---
---START---
-- should fail
INSERT INTO test_drop_constr_child (c) VALUES (NULL);
---END---
---START---
DROP TABLE test_drop_constr_parent CASCADE;
---END---
---START---

--
-- IF EXISTS test
--
ALTER TABLE IF EXISTS tt8 ADD COLUMN f int;
---END---
---START---
ALTER TABLE IF EXISTS tt8 ADD CONSTRAINT xxx PRIMARY KEY(f);
---END---
---START---
ALTER TABLE IF EXISTS tt8 ADD CHECK (f BETWEEN 0 AND 10);
---END---
---START---
ALTER TABLE IF EXISTS tt8 ALTER COLUMN f SET DEFAULT 0;
---END---
---START---
ALTER TABLE IF EXISTS tt8 RENAME COLUMN f TO f1;
---END---
---START---
ALTER TABLE IF EXISTS tt8 SET SCHEMA alter2;
---END---
---START---

CREATE TABLE tt8(a int);
---END---
---START---
CREATE SCHEMA alter2;
---END---
---START---

ALTER TABLE IF EXISTS tt8 ADD COLUMN f int;
---END---
---START---
ALTER TABLE IF EXISTS tt8 ADD CONSTRAINT xxx PRIMARY KEY(f);
---END---
---START---
ALTER TABLE IF EXISTS tt8 ADD CHECK (f BETWEEN 0 AND 10);
---END---
---START---
ALTER TABLE IF EXISTS tt8 ALTER COLUMN f SET DEFAULT 0;
---END---
---START---
ALTER TABLE IF EXISTS tt8 RENAME COLUMN f TO f1;
---END---
---START---
ALTER TABLE IF EXISTS tt8 SET SCHEMA alter2;
---END---
---START---

\d alter2.tt8

DROP TABLE alter2.tt8;
---END---
---START---
DROP SCHEMA alter2;
---END---
---START---

--
-- Check conflicts between index and CHECK constraint names
--
CREATE TABLE tt9(c integer);
---END---
---START---
ALTER TABLE tt9 ADD CHECK(c > 1);
---END---
---START---
ALTER TABLE tt9 ADD CHECK(c > 2);  -- picks nonconflicting name
ALTER TABLE tt9 ADD CONSTRAINT foo CHECK(c > 3);
---END---
---START---
ALTER TABLE tt9 ADD CONSTRAINT foo CHECK(c > 4);  -- fail, dup name
ALTER TABLE tt9 ADD UNIQUE(c);
---END---
---START---
ALTER TABLE tt9 ADD UNIQUE(c);  -- picks nonconflicting name
ALTER TABLE tt9 ADD CONSTRAINT tt9_c_key UNIQUE(c);  -- fail, dup name
ALTER TABLE tt9 ADD CONSTRAINT foo UNIQUE(c);  -- fail, dup name
ALTER TABLE tt9 ADD CONSTRAINT tt9_c_key CHECK(c > 5);  -- fail, dup name
ALTER TABLE tt9 ADD CONSTRAINT tt9_c_key2 CHECK(c > 6);
---END---
---START---
ALTER TABLE tt9 ADD UNIQUE(c);  -- picks nonconflicting name
\d tt9
DROP TABLE tt9;
---END---
---START---


-- Check that comments on constraints and indexes are not lost at ALTER TABLE.
CREATE TABLE comment_test (
  id int,
  positive_col int CHECK (positive_col > 0),
  indexed_col int,
  CONSTRAINT comment_test_pk PRIMARY KEY (id));
---END---
---START---
CREATE INDEX comment_test_index ON comment_test(indexed_col);
---END---
---START---

COMMENT ON COLUMN comment_test.id IS 'Column ''id'' on comment_test';
---END---
---START---
COMMENT ON INDEX comment_test_index IS 'Simple index on comment_test';
---END---
---START---
COMMENT ON CONSTRAINT comment_test_positive_col_check ON comment_test IS 'CHECK constraint on comment_test.positive_col';
---END---
---START---
COMMENT ON CONSTRAINT comment_test_pk ON comment_test IS 'PRIMARY KEY constraint of comment_test';
---END---
---START---
COMMENT ON INDEX comment_test_pk IS 'Index backing the PRIMARY KEY of comment_test';
---END---
---START---

SELECT col_description('comment_test'::regclass, 1) as comment;
---END---
---START---
SELECT indexrelid::regclass::text as index, obj_description(indexrelid, 'pg_class') as comment FROM pg_index where indrelid = 'comment_test'::regclass ORDER BY 1, 2;
---END---
---START---
SELECT conname as constraint, obj_description(oid, 'pg_constraint') as comment FROM pg_constraint where conrelid = 'comment_test'::regclass ORDER BY 1, 2;
---END---
---START---

-- Change the datatype of all the columns. ALTER TABLE is optimized to not
-- rebuild an index if the new data type is binary compatible with the old
-- one. Check do a dummy ALTER TABLE that doesn't change the datatype
-- first, to test that no-op codepath, and another one that does.
ALTER TABLE comment_test ALTER COLUMN indexed_col SET DATA TYPE int;
---END---
---START---
ALTER TABLE comment_test ALTER COLUMN indexed_col SET DATA TYPE text;
---END---
---START---
ALTER TABLE comment_test ALTER COLUMN id SET DATA TYPE int;
---END---
---START---
ALTER TABLE comment_test ALTER COLUMN id SET DATA TYPE text;
---END---
---START---
ALTER TABLE comment_test ALTER COLUMN positive_col SET DATA TYPE int;
---END---
---START---
ALTER TABLE comment_test ALTER COLUMN positive_col SET DATA TYPE bigint;
---END---
---START---

-- Check that the comments are intact.
SELECT col_description('comment_test'::regclass, 1) as comment;
---END---
---START---
SELECT indexrelid::regclass::text as index, obj_description(indexrelid, 'pg_class') as comment FROM pg_index where indrelid = 'comment_test'::regclass ORDER BY 1, 2;
---END---
---START---
SELECT conname as constraint, obj_description(oid, 'pg_constraint') as comment FROM pg_constraint where conrelid = 'comment_test'::regclass ORDER BY 1, 2;
---END---
---START---

-- Check compatibility for foreign keys and comments. This is done
-- separately as rebuilding the column type of the parent leads
-- to an error and would reduce the test scope.
CREATE TABLE comment_test_child (
  id text CONSTRAINT comment_test_child_fk REFERENCES comment_test);
---END---
---START---
CREATE INDEX comment_test_child_fk ON comment_test_child(id);
---END---
---START---
COMMENT ON COLUMN comment_test_child.id IS 'Column ''id'' on comment_test_child';
---END---
---START---
COMMENT ON INDEX comment_test_child_fk IS 'Index backing the FOREIGN KEY of comment_test_child';
---END---
---START---
COMMENT ON CONSTRAINT comment_test_child_fk ON comment_test_child IS 'FOREIGN KEY constraint of comment_test_child';
---END---
---START---

-- Change column type of parent
ALTER TABLE comment_test ALTER COLUMN id SET DATA TYPE text;
---END---
---START---
ALTER TABLE comment_test ALTER COLUMN id SET DATA TYPE int USING id::integer;
---END---
---START---

-- Comments should be intact
SELECT col_description('comment_test_child'::regclass, 1) as comment;
---END---
---START---
SELECT indexrelid::regclass::text as index, obj_description(indexrelid, 'pg_class') as comment FROM pg_index where indrelid = 'comment_test_child'::regclass ORDER BY 1, 2;
---END---
---START---
SELECT conname as constraint, obj_description(oid, 'pg_constraint') as comment FROM pg_constraint where conrelid = 'comment_test_child'::regclass ORDER BY 1, 2;
---END---
---START---

-- Check that we map relation oids to filenodes and back correctly.  Only
-- display bad mappings so the test output doesn't change all the time.  A
-- filenode function call can return NULL for a relation dropped concurrently
-- with the call's surrounding query, so ignore a NULL mapped_oid for
-- relations that no longer exist after all calls finish.
CREATE TABLE filenode_mapping AS
SELECT
    oid, mapped_oid, reltablespace, relfilenode, relname
FROM pg_class,
    pg_filenode_relation(reltablespace, pg_relation_filenode(oid)) AS mapped_oid
WHERE relkind IN ('r', 'i', 'S', 't', 'm') AND mapped_oid IS DISTINCT FROM oid;
---END---
---START---

SELECT m.* FROM filenode_mapping m LEFT JOIN pg_class c ON c.oid = m.oid
WHERE c.oid IS NOT NULL OR m.mapped_oid IS NOT NULL;
---END---
---START---

-- Checks on creating and manipulation of user defined relations in
-- pg_catalog.

SHOW allow_system_table_mods;
---END---
---START---
-- disallowed because of search_path issues with pg_dump
CREATE TABLE pg_catalog.new_system_table();
---END---
---START---
-- instead create in public first, move to catalog
CREATE TABLE new_system_table(id serial primary key, othercol text);
---END---
---START---
ALTER TABLE new_system_table SET SCHEMA pg_catalog;
---END---
---START---
ALTER TABLE new_system_table SET SCHEMA public;
---END---
---START---
ALTER TABLE new_system_table SET SCHEMA pg_catalog;
---END---
---START---
-- will be ignored -- already there:
ALTER TABLE new_system_table SET SCHEMA pg_catalog;
---END---
---START---
ALTER TABLE new_system_table RENAME TO old_system_table;
---END---
---START---
CREATE INDEX old_system_table__othercol ON old_system_table (othercol);
---END---
---START---
INSERT INTO old_system_table(othercol) VALUES ('somedata'), ('otherdata');
---END---
---START---
UPDATE old_system_table SET id = -id;
---END---
---START---
DELETE FROM old_system_table WHERE othercol = 'somedata';
---END---
---START---
TRUNCATE old_system_table;
---END---
---START---
ALTER TABLE old_system_table DROP CONSTRAINT new_system_table_pkey;
---END---
---START---
ALTER TABLE old_system_table DROP COLUMN othercol;
---END---
---START---
DROP TABLE old_system_table;
---END---
---START---

-- set logged
CREATE UNLOGGED TABLE unlogged1(f1 SERIAL PRIMARY KEY, f2 TEXT); -- has sequence, toast
-- check relpersistence of an unlogged table
SELECT relname, relkind, relpersistence FROM pg_class WHERE relname ~ '^unlogged1'
UNION ALL
SELECT r.relname || ' toast table', t.relkind, t.relpersistence FROM pg_class r JOIN pg_class t ON t.oid = r.reltoastrelid WHERE r.relname ~ '^unlogged1'
UNION ALL
SELECT r.relname || ' toast index', ri.relkind, ri.relpersistence FROM pg_class r join pg_class t ON t.oid = r.reltoastrelid JOIN pg_index i ON i.indrelid = t.oid JOIN pg_class ri ON ri.oid = i.indexrelid WHERE r.relname ~ '^unlogged1'
ORDER BY relname;
---END---
---START---
CREATE UNLOGGED TABLE unlogged2(f1 SERIAL PRIMARY KEY, f2 INTEGER REFERENCES unlogged1); -- foreign key
CREATE UNLOGGED TABLE unlogged3(f1 SERIAL PRIMARY KEY, f2 INTEGER REFERENCES unlogged3); -- self-referencing foreign key
ALTER TABLE unlogged3 SET LOGGED; -- skip self-referencing foreign key
ALTER TABLE unlogged2 SET LOGGED; -- fails because a foreign key to an unlogged table exists
ALTER TABLE unlogged1 SET LOGGED;
---END---
---START---
-- check relpersistence of an unlogged table after changing to permanent
SELECT relname, relkind, relpersistence FROM pg_class WHERE relname ~ '^unlogged1'
UNION ALL
SELECT r.relname || ' toast table', t.relkind, t.relpersistence FROM pg_class r JOIN pg_class t ON t.oid = r.reltoastrelid WHERE r.relname ~ '^unlogged1'
UNION ALL
SELECT r.relname || ' toast index', ri.relkind, ri.relpersistence FROM pg_class r join pg_class t ON t.oid = r.reltoastrelid JOIN pg_index i ON i.indrelid = t.oid JOIN pg_class ri ON ri.oid = i.indexrelid WHERE r.relname ~ '^unlogged1'
ORDER BY relname;
---END---
---START---
ALTER TABLE unlogged1 SET LOGGED; -- silently do nothing
DROP TABLE unlogged3;
---END---
---START---
DROP TABLE unlogged2;
---END---
---START---
DROP TABLE unlogged1;
---END---
---START---

-- set unlogged
CREATE TABLE logged1(f1 SERIAL PRIMARY KEY, f2 TEXT); -- has sequence, toast
-- check relpersistence of a permanent table
SELECT relname, relkind, relpersistence FROM pg_class WHERE relname ~ '^logged1'
UNION ALL
SELECT r.relname || ' toast table', t.relkind, t.relpersistence FROM pg_class r JOIN pg_class t ON t.oid = r.reltoastrelid WHERE r.relname ~ '^logged1'
UNION ALL
SELECT r.relname ||' toast index', ri.relkind, ri.relpersistence FROM pg_class r join pg_class t ON t.oid = r.reltoastrelid JOIN pg_index i ON i.indrelid = t.oid JOIN pg_class ri ON ri.oid = i.indexrelid WHERE r.relname ~ '^logged1'
ORDER BY relname;
---END---
---START---
CREATE TABLE logged2(f1 SERIAL PRIMARY KEY, f2 INTEGER REFERENCES logged1); -- foreign key
CREATE TABLE logged3(f1 SERIAL PRIMARY KEY, f2 INTEGER REFERENCES logged3); -- self-referencing foreign key
ALTER TABLE logged1 SET UNLOGGED; -- fails because a foreign key from a permanent table exists
ALTER TABLE logged3 SET UNLOGGED; -- skip self-referencing foreign key
ALTER TABLE logged2 SET UNLOGGED;
---END---
---START---
ALTER TABLE logged1 SET UNLOGGED;
---END---
---START---
-- check relpersistence of a permanent table after changing to unlogged
SELECT relname, relkind, relpersistence FROM pg_class WHERE relname ~ '^logged1'
UNION ALL
SELECT r.relname || ' toast table', t.relkind, t.relpersistence FROM pg_class r JOIN pg_class t ON t.oid = r.reltoastrelid WHERE r.relname ~ '^logged1'
UNION ALL
SELECT r.relname || ' toast index', ri.relkind, ri.relpersistence FROM pg_class r join pg_class t ON t.oid = r.reltoastrelid JOIN pg_index i ON i.indrelid = t.oid JOIN pg_class ri ON ri.oid = i.indexrelid WHERE r.relname ~ '^logged1'
ORDER BY relname;
---END---
---START---
ALTER TABLE logged1 SET UNLOGGED; -- silently do nothing
DROP TABLE logged3;
---END---
---START---
DROP TABLE logged2;
---END---
---START---
DROP TABLE logged1;
---END---
---START---

-- test ADD COLUMN IF NOT EXISTS
CREATE TABLE test_add_column(c1 integer);
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN c2 integer;
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN c2 integer; -- fail because c2 already exists
ALTER TABLE ONLY test_add_column
	ADD COLUMN c2 integer; -- fail because c2 already exists
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c2 integer; -- skipping because c2 already exists
ALTER TABLE ONLY test_add_column
	ADD COLUMN IF NOT EXISTS c2 integer; -- skipping because c2 already exists
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN c2 integer, -- fail because c2 already exists
	ADD COLUMN c3 integer primary key;
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c2 integer, -- skipping because c2 already exists
	ADD COLUMN c3 integer primary key;
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c2 integer, -- skipping because c2 already exists
	ADD COLUMN IF NOT EXISTS c3 integer primary key; -- skipping because c3 already exists
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c2 integer, -- skipping because c2 already exists
	ADD COLUMN IF NOT EXISTS c3 integer, -- skipping because c3 already exists
	ADD COLUMN c4 integer REFERENCES test_add_column;
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c4 integer REFERENCES test_add_column;
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c5 SERIAL CHECK (c5 > 8);
---END---
---START---
\d test_add_column
ALTER TABLE test_add_column
	ADD COLUMN IF NOT EXISTS c5 SERIAL CHECK (c5 > 10);
---END---
---START---
\d test_add_column*
DROP TABLE test_add_column;
---END---
---START---
\d test_add_column*

-- assorted cases with multiple ALTER TABLE steps
CREATE TABLE ataddindex(f1 INT);
---END---
---START---
INSERT INTO ataddindex VALUES (42), (43);
---END---
---START---
CREATE UNIQUE INDEX ataddindexi0 ON ataddindex(f1);
---END---
---START---
ALTER TABLE ataddindex
  ADD PRIMARY KEY USING INDEX ataddindexi0,
  ALTER f1 TYPE BIGINT;
---END---
---START---
\d ataddindex
DROP TABLE ataddindex;
---END---
---START---

CREATE TABLE ataddindex(f1 VARCHAR(10));
---END---
---START---
INSERT INTO ataddindex(f1) VALUES ('foo'), ('a');
---END---
---START---
ALTER TABLE ataddindex
  ALTER f1 SET DATA TYPE TEXT,
  ADD EXCLUDE ((f1 LIKE 'a') WITH =);
---END---
---START---
\d ataddindex
DROP TABLE ataddindex;
---END---
---START---

CREATE TABLE ataddindex(id int, ref_id int);
---END---
---START---
ALTER TABLE ataddindex
  ADD PRIMARY KEY (id),
  ADD FOREIGN KEY (ref_id) REFERENCES ataddindex;
---END---
---START---
\d ataddindex
DROP TABLE ataddindex;
---END---
---START---

CREATE TABLE ataddindex(id int, ref_id int);
---END---
---START---
ALTER TABLE ataddindex
  ADD UNIQUE (id),
  ADD FOREIGN KEY (ref_id) REFERENCES ataddindex (id);
---END---
---START---
\d ataddindex
DROP TABLE ataddindex;
---END---
---START---

-- unsupported constraint types for partitioned tables
CREATE TABLE partitioned (
	a int,
	b int
) PARTITION BY RANGE (a, (a+b+1));
---END---
---START---
ALTER TABLE partitioned ADD EXCLUDE USING gist (a WITH &&);
---END---
---START---

-- cannot drop column that is part of the partition key
ALTER TABLE partitioned DROP COLUMN a;
---END---
---START---
ALTER TABLE partitioned ALTER COLUMN a TYPE char(5);
---END---
---START---
ALTER TABLE partitioned DROP COLUMN b;
---END---
---START---
ALTER TABLE partitioned ALTER COLUMN b TYPE char(5);
---END---
---START---

-- specifying storage parameters for partitioned tables is not supported
ALTER TABLE partitioned SET (fillfactor=100);
---END---
---START---

-- partitioned table cannot participate in regular inheritance
CREATE TABLE nonpartitioned (
	a int,
	b int
);
---END---
---START---
ALTER TABLE partitioned INHERIT nonpartitioned;
---END---
---START---
ALTER TABLE nonpartitioned INHERIT partitioned;
---END---
---START---

-- cannot add NO INHERIT constraint to partitioned tables
ALTER TABLE partitioned ADD CONSTRAINT chk_a CHECK (a > 0) NO INHERIT;
---END---
---START---

DROP TABLE partitioned, nonpartitioned;
---END---
---START---

--
-- ATTACH PARTITION
--

-- check that target table is partitioned
CREATE TABLE unparted (
	a int
);
---END---
---START---
CREATE TABLE fail_part (like unparted);
---END---
---START---
ALTER TABLE unparted ATTACH PARTITION fail_part FOR VALUES IN ('a');
---END---
---START---
DROP TABLE unparted, fail_part;
---END---
---START---

-- check that partition bound is compatible
CREATE TABLE list_parted (
	a int NOT NULL,
	b char(2) COLLATE "C",
	CONSTRAINT check_a CHECK (a > 0)
) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE fail_part (LIKE list_parted);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES FROM (1) TO (10);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

-- check that the table being attached exists
ALTER TABLE list_parted ATTACH PARTITION nonexistent FOR VALUES IN (1);
---END---
---START---

-- check ownership of the source table
CREATE ROLE regress_test_me;
---END---
---START---
CREATE ROLE regress_test_not_me;
---END---
---START---
CREATE TABLE not_owned_by_me (LIKE list_parted);
---END---
---START---
ALTER TABLE not_owned_by_me OWNER TO regress_test_not_me;
---END---
---START---
SET SESSION AUTHORIZATION regress_test_me;
---END---
---START---
CREATE TABLE owned_by_me (
	a int
) PARTITION BY LIST (a);
---END---
---START---
ALTER TABLE owned_by_me ATTACH PARTITION not_owned_by_me FOR VALUES IN (1);
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP TABLE owned_by_me, not_owned_by_me;
---END---
---START---
DROP ROLE regress_test_not_me;
---END---
---START---
DROP ROLE regress_test_me;
---END---
---START---

-- check that the table being attached is not part of regular inheritance
CREATE TABLE parent (LIKE list_parted);
---END---
---START---
CREATE TABLE child () INHERITS (parent);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION child FOR VALUES IN (1);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION parent FOR VALUES IN (1);
---END---
---START---
DROP TABLE parent CASCADE;
---END---
---START---

-- check any TEMP-ness
CREATE TABLE temp_parted (a int) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE perm_part (a int);
---END---
---START---
ALTER TABLE temp_parted ATTACH PARTITION perm_part FOR VALUES IN (1);
---END---
---START---
DROP TABLE temp_parted, perm_part;
---END---
---START---

-- check that the table being attached is not a typed table
CREATE TYPE mytype AS (a int);
---END---
---START---
CREATE TABLE fail_part OF mytype;
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
DROP TYPE mytype CASCADE;
---END---
---START---

-- check that the table being attached has only columns present in the parent
CREATE TABLE fail_part (like list_parted, c int);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

-- check that the table being attached has every column of the parent
CREATE TABLE fail_part (a int NOT NULL);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

-- check that columns match in type, collation and NOT NULL status
CREATE TABLE fail_part (
	b char(3),
	a int NOT NULL
);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
ALTER TABLE fail_part ALTER b TYPE char (2) COLLATE "POSIX";
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

-- check that the table being attached has all constraints of the parent
CREATE TABLE fail_part (
	b char(2) COLLATE "C",
	a int NOT NULL
);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---

-- check that the constraint matches in definition with parent's constraint
ALTER TABLE fail_part ADD CONSTRAINT check_a CHECK (a >= 0);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

-- check the attributes and constraints after partition is attached
CREATE TABLE part_1 (
	a int NOT NULL,
	b char(2) COLLATE "C",
	CONSTRAINT check_a CHECK (a > 0)
);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION part_1 FOR VALUES IN (1);
---END---
---START---
-- attislocal and conislocal are always false for merged attributes and constraints respectively.
SELECT attislocal, attinhcount FROM pg_attribute WHERE attrelid = 'part_1'::regclass AND attnum > 0;
---END---
---START---
SELECT conislocal, coninhcount FROM pg_constraint WHERE conrelid = 'part_1'::regclass AND conname = 'check_a';
---END---
---START---

-- check that the new partition won't overlap with an existing partition
CREATE TABLE fail_part (LIKE part_1 INCLUDING CONSTRAINTS);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_part FOR VALUES IN (1);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---
-- check that an existing table can be attached as a default partition
CREATE TABLE def_part (LIKE list_parted INCLUDING CONSTRAINTS);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION def_part DEFAULT;
---END---
---START---
-- check attaching default partition fails if a default partition already
-- exists
CREATE TABLE fail_def_part (LIKE part_1 INCLUDING CONSTRAINTS);
---END---
---START---
ALTER TABLE list_parted ATTACH PARTITION fail_def_part DEFAULT;
---END---
---START---

-- check validation when attaching list partitions
CREATE TABLE list_parted2 (
	a int,
	b char
) PARTITION BY LIST (a);
---END---
---START---

-- check that violating rows are correctly reported
CREATE TABLE part_2 (LIKE list_parted2);
---END---
---START---
INSERT INTO part_2 VALUES (3, 'a');
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_2 FOR VALUES IN (2);
---END---
---START---

-- should be ok after deleting the bad row
DELETE FROM part_2;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_2 FOR VALUES IN (2);
---END---
---START---

-- check partition cannot be attached if default has some row for its values
CREATE TABLE list_parted2_def PARTITION OF list_parted2 DEFAULT;
---END---
---START---
INSERT INTO list_parted2_def VALUES (11, 'z');
---END---
---START---
CREATE TABLE part_3 (LIKE list_parted2);
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_3 FOR VALUES IN (11);
---END---
---START---
-- should be ok after deleting the bad row
DELETE FROM list_parted2_def WHERE a = 11;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_3 FOR VALUES IN (11);
---END---
---START---

-- adding constraints that describe the desired partition constraint
-- (or more restrictive) will help skip the validation scan
CREATE TABLE part_3_4 (
	LIKE list_parted2,
	CONSTRAINT check_a CHECK (a IN (3))
);
---END---
---START---

-- however, if a list partition does not accept nulls, there should be
-- an explicit NOT NULL constraint on the partition key column for the
-- validation scan to be skipped;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_3_4 FOR VALUES IN (3, 4);
---END---
---START---

-- adding a NOT NULL constraint will cause the scan to be skipped
ALTER TABLE list_parted2 DETACH PARTITION part_3_4;
---END---
---START---
ALTER TABLE part_3_4 ALTER a SET NOT NULL;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_3_4 FOR VALUES IN (3, 4);
---END---
---START---

-- check if default partition scan skipped
ALTER TABLE list_parted2_def ADD CONSTRAINT check_a CHECK (a IN (5, 6));
---END---
---START---
CREATE TABLE part_55_66 PARTITION OF list_parted2 FOR VALUES IN (55, 66);
---END---
---START---

-- check validation when attaching range partitions
CREATE TABLE range_parted (
	a int,
	b int
) PARTITION BY RANGE (a, b);
---END---
---START---

-- check that violating rows are correctly reported
CREATE TABLE part1 (
	a int NOT NULL CHECK (a = 1),
	b int NOT NULL CHECK (b >= 1 AND b <= 10)
);
---END---
---START---
INSERT INTO part1 VALUES (1, 10);
---END---
---START---
-- Remember the TO bound is exclusive
ALTER TABLE range_parted ATTACH PARTITION part1 FOR VALUES FROM (1, 1) TO (1, 10);
---END---
---START---

-- should be ok after deleting the bad row
DELETE FROM part1;
---END---
---START---
ALTER TABLE range_parted ATTACH PARTITION part1 FOR VALUES FROM (1, 1) TO (1, 10);
---END---
---START---

-- adding constraints that describe the desired partition constraint
-- (or more restrictive) will help skip the validation scan
CREATE TABLE part2 (
	a int NOT NULL CHECK (a = 1),
	b int NOT NULL CHECK (b >= 10 AND b < 18)
);
---END---
---START---
ALTER TABLE range_parted ATTACH PARTITION part2 FOR VALUES FROM (1, 10) TO (1, 20);
---END---
---START---

-- Create default partition
CREATE TABLE partr_def1 PARTITION OF range_parted DEFAULT;
---END---
---START---

-- Only one default partition is allowed, hence, following should give error
CREATE TABLE partr_def2 (LIKE part1 INCLUDING CONSTRAINTS);
---END---
---START---
ALTER TABLE range_parted ATTACH PARTITION partr_def2 DEFAULT;
---END---
---START---

-- Overlapping partitions cannot be attached, hence, following should give error
INSERT INTO partr_def1 VALUES (2, 10);
---END---
---START---
CREATE TABLE part3 (LIKE range_parted);
---END---
---START---
ALTER TABLE range_parted ATTACH partition part3 FOR VALUES FROM (2, 10) TO (2, 20);
---END---
---START---

-- Attaching partitions should be successful when there are no overlapping rows
ALTER TABLE range_parted ATTACH partition part3 FOR VALUES FROM (3, 10) TO (3, 20);
---END---
---START---

-- check that leaf partitions are scanned when attaching a partitioned
-- table
CREATE TABLE part_5 (
	LIKE list_parted2
) PARTITION BY LIST (b);
---END---
---START---

-- check that violating rows are correctly reported
CREATE TABLE part_5_a PARTITION OF part_5 FOR VALUES IN ('a');
---END---
---START---
INSERT INTO part_5_a (a, b) VALUES (6, 'a');
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_5 FOR VALUES IN (5);
---END---
---START---

-- delete the faulting row and also add a constraint to skip the scan
DELETE FROM part_5_a WHERE a NOT IN (3);
---END---
---START---
ALTER TABLE part_5 ADD CONSTRAINT check_a CHECK (a IS NOT NULL AND a = 5);
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_5 FOR VALUES IN (5);
---END---
---START---
ALTER TABLE list_parted2 DETACH PARTITION part_5;
---END---
---START---
ALTER TABLE part_5 DROP CONSTRAINT check_a;
---END---
---START---

-- scan should again be skipped, even though NOT NULL is now a column property
ALTER TABLE part_5 ADD CONSTRAINT check_a CHECK (a IN (5)), ALTER a SET NOT NULL;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_5 FOR VALUES IN (5);
---END---
---START---

-- Check the case where attnos of the partitioning columns in the table being
-- attached differs from the parent.  It should not affect the constraint-
-- checking logic that allows to skip the scan.
CREATE TABLE part_6 (
	c int,
	LIKE list_parted2,
	CONSTRAINT check_a CHECK (a IS NOT NULL AND a = 6)
);
---END---
---START---
ALTER TABLE part_6 DROP c;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_6 FOR VALUES IN (6);
---END---
---START---

-- Similar to above, but the table being attached is a partitioned table
-- whose partition has still different attnos for the root partitioning
-- columns.
CREATE TABLE part_7 (
	LIKE list_parted2,
	CONSTRAINT check_a CHECK (a IS NOT NULL AND a = 7)
) PARTITION BY LIST (b);
---END---
---START---
CREATE TABLE part_7_a_null (
	c int,
	d int,
	e int,
	LIKE list_parted2,  -- 'a' will have attnum = 4
	CONSTRAINT check_b CHECK (b IS NULL OR b = 'a'),
	CONSTRAINT check_a CHECK (a IS NOT NULL AND a = 7)
);
---END---
---START---
ALTER TABLE part_7_a_null DROP c, DROP d, DROP e;
---END---
---START---
ALTER TABLE part_7 ATTACH PARTITION part_7_a_null FOR VALUES IN ('a', null);
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_7 FOR VALUES IN (7);
---END---
---START---

-- Same example, but check this time that the constraint correctly detects
-- violating rows
ALTER TABLE list_parted2 DETACH PARTITION part_7;
---END---
---START---
ALTER TABLE part_7 DROP CONSTRAINT check_a; -- thusly, scan won't be skipped
INSERT INTO part_7 (a, b) VALUES (8, null), (9, 'a');
---END---
---START---
SELECT tableoid::regclass, a, b FROM part_7 order by a;
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION part_7 FOR VALUES IN (7);
---END---
---START---

-- check that leaf partitions of default partition are scanned when
-- attaching a partitioned table.
ALTER TABLE part_5 DROP CONSTRAINT check_a;
---END---
---START---
CREATE TABLE part5_def PARTITION OF part_5 DEFAULT PARTITION BY LIST(a);
---END---
---START---
CREATE TABLE part5_def_p1 PARTITION OF part5_def FOR VALUES IN (5);
---END---
---START---
INSERT INTO part5_def_p1 VALUES (5, 'y');
---END---
---START---
CREATE TABLE part5_p1 (LIKE part_5);
---END---
---START---
ALTER TABLE part_5 ATTACH PARTITION part5_p1 FOR VALUES IN ('y');
---END---
---START---
-- should be ok after deleting the bad row
DELETE FROM part5_def_p1 WHERE b = 'y';
---END---
---START---
ALTER TABLE part_5 ATTACH PARTITION part5_p1 FOR VALUES IN ('y');
---END---
---START---

-- check that the table being attached is not already a partition
ALTER TABLE list_parted2 ATTACH PARTITION part_2 FOR VALUES IN (2);
---END---
---START---

-- check that circular inheritance is not allowed
ALTER TABLE part_5 ATTACH PARTITION list_parted2 FOR VALUES IN ('b');
---END---
---START---
ALTER TABLE list_parted2 ATTACH PARTITION list_parted2 FOR VALUES IN (0);
---END---
---START---

-- If a partitioned table being created or an existing table being attached
-- as a partition does not have a constraint that would allow validation scan
-- to be skipped, but an individual partition does, then the partition's
-- validation scan is skipped.
CREATE TABLE quuux (a int, b text) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE quuux_default PARTITION OF quuux DEFAULT PARTITION BY LIST (b);
---END---
---START---
CREATE TABLE quuux_default1 PARTITION OF quuux_default (
	CONSTRAINT check_1 CHECK (a IS NOT NULL AND a = 1)
) FOR VALUES IN ('b');
---END---
---START---
CREATE TABLE quuux1 (a int, b text);
---END---
---START---
ALTER TABLE quuux ATTACH PARTITION quuux1 FOR VALUES IN (1); -- validate!
CREATE TABLE quuux2 (a int, b text);
---END---
---START---
ALTER TABLE quuux ATTACH PARTITION quuux2 FOR VALUES IN (2); -- skip validation
DROP TABLE quuux1, quuux2;
---END---
---START---
-- should validate for quuux1, but not for quuux2
CREATE TABLE quuux1 PARTITION OF quuux FOR VALUES IN (1);
---END---
---START---
CREATE TABLE quuux2 PARTITION OF quuux FOR VALUES IN (2);
---END---
---START---
DROP TABLE quuux;
---END---
---START---

-- check validation when attaching hash partitions

-- Use hand-rolled hash functions and operator class to get predictable result
-- on different machines. part_test_int4_ops is defined in insert.sql.

-- check that the new partition won't overlap with an existing partition
CREATE TABLE hash_parted (
	a int,
	b int
) PARTITION BY HASH (a part_test_int4_ops);
---END---
---START---
CREATE TABLE hpart_1 PARTITION OF hash_parted FOR VALUES WITH (MODULUS 4, REMAINDER 0);
---END---
---START---
CREATE TABLE fail_part (LIKE hpart_1);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION fail_part FOR VALUES WITH (MODULUS 8, REMAINDER 4);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION fail_part FOR VALUES WITH (MODULUS 8, REMAINDER 0);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

-- check validation when attaching hash partitions

-- check that violating rows are correctly reported
CREATE TABLE hpart_2 (LIKE hash_parted);
---END---
---START---
INSERT INTO hpart_2 VALUES (3, 0);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION hpart_2 FOR VALUES WITH (MODULUS 4, REMAINDER 1);
---END---
---START---

-- should be ok after deleting the bad row
DELETE FROM hpart_2;
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION hpart_2 FOR VALUES WITH (MODULUS 4, REMAINDER 1);
---END---
---START---

-- check that leaf partitions are scanned when attaching a partitioned
-- table
CREATE TABLE hpart_5 (
	LIKE hash_parted
) PARTITION BY LIST (b);
---END---
---START---

-- check that violating rows are correctly reported
CREATE TABLE hpart_5_a PARTITION OF hpart_5 FOR VALUES IN ('1', '2', '3');
---END---
---START---
INSERT INTO hpart_5_a (a, b) VALUES (7, 1);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION hpart_5 FOR VALUES WITH (MODULUS 4, REMAINDER 2);
---END---
---START---

-- should be ok after deleting the bad row
DELETE FROM hpart_5_a;
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION hpart_5 FOR VALUES WITH (MODULUS 4, REMAINDER 2);
---END---
---START---

-- check that the table being attach is with valid modulus and remainder value
CREATE TABLE fail_part(LIKE hash_parted);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION fail_part FOR VALUES WITH (MODULUS 0, REMAINDER 1);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION fail_part FOR VALUES WITH (MODULUS 8, REMAINDER 8);
---END---
---START---
ALTER TABLE hash_parted ATTACH PARTITION fail_part FOR VALUES WITH (MODULUS 3, REMAINDER 2);
---END---
---START---
DROP TABLE fail_part;
---END---
---START---

--
-- DETACH PARTITION
--

-- check that the table is partitioned at all
CREATE TABLE regular_table (a int);
---END---
---START---
ALTER TABLE regular_table DETACH PARTITION any_name;
---END---
---START---
DROP TABLE regular_table;
---END---
---START---

-- check that the partition being detached exists at all
ALTER TABLE list_parted2 DETACH PARTITION part_4;
---END---
---START---
ALTER TABLE hash_parted DETACH PARTITION hpart_4;
---END---
---START---

-- check that the partition being detached is actually a partition of the parent
CREATE TABLE not_a_part (a int);
---END---
---START---
ALTER TABLE list_parted2 DETACH PARTITION not_a_part;
---END---
---START---
ALTER TABLE list_parted2 DETACH PARTITION part_1;
---END---
---START---

ALTER TABLE hash_parted DETACH PARTITION not_a_part;
---END---
---START---
DROP TABLE not_a_part;
---END---
---START---

-- check that, after being detached, attinhcount/coninhcount is dropped to 0 and
-- attislocal/conislocal is set to true
ALTER TABLE list_parted2 DETACH PARTITION part_3_4;
---END---
---START---
SELECT attinhcount, attislocal FROM pg_attribute WHERE attrelid = 'part_3_4'::regclass AND attnum > 0;
---END---
---START---
SELECT coninhcount, conislocal FROM pg_constraint WHERE conrelid = 'part_3_4'::regclass AND conname = 'check_a';
---END---
---START---
DROP TABLE part_3_4;
---END---
---START---

-- check that a detached partition is not dropped on dropping a partitioned table
CREATE TABLE range_parted2 (
    a int
) PARTITION BY RANGE(a);
---END---
---START---
CREATE TABLE part_rp PARTITION OF range_parted2 FOR VALUES FROM (0) to (100);
---END---
---START---
ALTER TABLE range_parted2 DETACH PARTITION part_rp;
---END---
---START---
DROP TABLE range_parted2;
---END---
---START---
SELECT * from part_rp;
---END---
---START---
DROP TABLE part_rp;
---END---
---START---

-- concurrent detach
CREATE TABLE range_parted2 (
	a int
) PARTITION BY RANGE(a);
---END---
---START---
CREATE TABLE part_rp PARTITION OF range_parted2 FOR VALUES FROM (0) to (100);
---END---
---START---
BEGIN;
---END---
---START---
-- doesn't work in a partition block
ALTER TABLE range_parted2 DETACH PARTITION part_rp CONCURRENTLY;
---END---
---START---
COMMIT;
---END---
---START---
CREATE TABLE part_rpd PARTITION OF range_parted2 DEFAULT;
---END---
---START---
-- doesn't work if there's a default partition
ALTER TABLE range_parted2 DETACH PARTITION part_rp CONCURRENTLY;
---END---
---START---
-- doesn't work for the default partition
ALTER TABLE range_parted2 DETACH PARTITION part_rpd CONCURRENTLY;
---END---
---START---
DROP TABLE part_rpd;
---END---
---START---
-- works fine
ALTER TABLE range_parted2 DETACH PARTITION part_rp CONCURRENTLY;
---END---
---START---
\d+ range_parted2
-- constraint should be created
\d part_rp
CREATE TABLE part_rp100 PARTITION OF range_parted2 (CHECK (a>=123 AND a<133 AND a IS NOT NULL)) FOR VALUES FROM (100) to (200);
---END---
---START---
ALTER TABLE range_parted2 DETACH PARTITION part_rp100 CONCURRENTLY;
---END---
---START---
-- redundant constraint should not be created
\d part_rp100
DROP TABLE range_parted2;
---END---
---START---

-- Check ALTER TABLE commands for partitioned tables and partitions

-- cannot add/drop column to/from *only* the parent
ALTER TABLE ONLY list_parted2 ADD COLUMN c int;
---END---
---START---
ALTER TABLE ONLY list_parted2 DROP COLUMN b;
---END---
---START---

-- cannot add a column to partition or drop an inherited one
ALTER TABLE part_2 ADD COLUMN c text;
---END---
---START---
ALTER TABLE part_2 DROP COLUMN b;
---END---
---START---

-- Nor rename, alter type
ALTER TABLE part_2 RENAME COLUMN b to c;
---END---
---START---
ALTER TABLE part_2 ALTER COLUMN b TYPE text;
---END---
---START---

-- cannot add/drop NOT NULL or check constraints to *only* the parent, when
-- partitions exist
ALTER TABLE ONLY list_parted2 ALTER b SET NOT NULL;
---END---
---START---
ALTER TABLE ONLY list_parted2 ADD CONSTRAINT check_b CHECK (b <> 'zz');
---END---
---START---

ALTER TABLE list_parted2 ALTER b SET NOT NULL;
---END---
---START---
ALTER TABLE ONLY list_parted2 ALTER b DROP NOT NULL;
---END---
---START---
ALTER TABLE list_parted2 ADD CONSTRAINT check_b CHECK (b <> 'zz');
---END---
---START---
ALTER TABLE ONLY list_parted2 DROP CONSTRAINT check_b;
---END---
---START---

-- It's alright though, if no partitions are yet created
CREATE TABLE parted_no_parts (a int) PARTITION BY LIST (a);
---END---
---START---
ALTER TABLE ONLY parted_no_parts ALTER a SET NOT NULL;
---END---
---START---
ALTER TABLE ONLY parted_no_parts ADD CONSTRAINT check_a CHECK (a > 0);
---END---
---START---
ALTER TABLE ONLY parted_no_parts ALTER a DROP NOT NULL;
---END---
---START---
ALTER TABLE ONLY parted_no_parts DROP CONSTRAINT check_a;
---END---
---START---
DROP TABLE parted_no_parts;
---END---
---START---

-- cannot drop inherited NOT NULL or check constraints from partition
ALTER TABLE list_parted2 ALTER b SET NOT NULL, ADD CONSTRAINT check_a2 CHECK (a > 0);
---END---
---START---
ALTER TABLE part_2 ALTER b DROP NOT NULL;
---END---
---START---
ALTER TABLE part_2 DROP CONSTRAINT check_a2;
---END---
---START---

-- Doesn't make sense to add NO INHERIT constraints on partitioned tables
ALTER TABLE list_parted2 add constraint check_b2 check (b <> 'zz') NO INHERIT;
---END---
---START---

-- check that a partition cannot participate in regular inheritance
CREATE TABLE inh_test () INHERITS (part_2);
---END---
---START---
CREATE TABLE inh_test (LIKE part_2);
---END---
---START---
ALTER TABLE inh_test INHERIT part_2;
---END---
---START---
ALTER TABLE part_2 INHERIT inh_test;
---END---
---START---

-- cannot drop or alter type of partition key columns of lower level
-- partitioned tables; for example, part_5, which is list_parted2's
-- partition, is partitioned on b;
---END---
---START---
ALTER TABLE list_parted2 DROP COLUMN b;
---END---
---START---
ALTER TABLE list_parted2 ALTER COLUMN b TYPE text;
---END---
---START---

-- dropping non-partition key columns should be allowed on the parent table.
ALTER TABLE list_parted DROP COLUMN b;
---END---
---START---
SELECT * FROM list_parted;
---END---
---START---

-- cleanup
DROP TABLE list_parted, list_parted2, range_parted;
---END---
---START---
DROP TABLE fail_def_part;
---END---
---START---
DROP TABLE hash_parted;
---END---
---START---

-- more tests for certain multi-level partitioning scenarios
create table p (a int, b int) partition by range (a, b);
---END---
---START---
create table p1 (b int, a int not null) partition by range (b);
---END---
---START---
create table p11 (like p1);
---END---
---START---
alter table p11 drop a;
---END---
---START---
alter table p11 add a int;
---END---
---START---
alter table p11 drop a;
---END---
---START---
alter table p11 add a int not null;
---END---
---START---
-- attnum for key attribute 'a' is different in p, p1, and p11
select attrelid::regclass, attname, attnum
from pg_attribute
where attname = 'a'
 and (attrelid = 'p'::regclass
   or attrelid = 'p1'::regclass
   or attrelid = 'p11'::regclass)
order by attrelid::regclass::text;
---END---
---START---

alter table p1 attach partition p11 for values from (2) to (5);
---END---
---START---

insert into p1 (a, b) values (2, 3);
---END---
---START---
-- check that partition validation scan correctly detects violating rows
alter table p attach partition p1 for values from (1, 2) to (1, 10);
---END---
---START---

-- cleanup
drop table p;
---END---
---START---
drop table p1;
---END---
---START---

-- validate constraint on partitioned tables should only scan leaf partitions
create table parted_validate_test (a int) partition by list (a);
---END---
---START---
create table parted_validate_test_1 partition of parted_validate_test for values in (0, 1);
---END---
---START---
alter table parted_validate_test add constraint parted_validate_test_chka check (a > 0) not valid;
---END---
---START---
alter table parted_validate_test validate constraint parted_validate_test_chka;
---END---
---START---
drop table parted_validate_test;
---END---
---START---
-- test alter column options
CREATE TABLE attmp(i integer);
---END---
---START---
INSERT INTO attmp VALUES (1);
---END---
---START---
ALTER TABLE attmp ALTER COLUMN i SET (n_distinct = 1, n_distinct_inherited = 2);
---END---
---START---
ALTER TABLE attmp ALTER COLUMN i RESET (n_distinct_inherited);
---END---
---START---
ANALYZE attmp;
---END---
---START---
DROP TABLE attmp;
---END---
---START---

DROP USER regress_alter_table_user1;
---END---
---START---

-- check that violating rows are correctly reported when attaching as the
-- default partition
create table defpart_attach_test (a int) partition by list (a);
---END---
---START---
create table defpart_attach_test1 partition of defpart_attach_test for values in (1);
---END---
---START---
create table defpart_attach_test_d (b int, a int);
---END---
---START---
alter table defpart_attach_test_d drop b;
---END---
---START---
insert into defpart_attach_test_d values (1), (2);
---END---
---START---

-- error because its constraint as the default partition would be violated
-- by the row containing 1
alter table defpart_attach_test attach partition defpart_attach_test_d default;
---END---
---START---
delete from defpart_attach_test_d where a = 1;
---END---
---START---
alter table defpart_attach_test_d add check (a > 1);
---END---
---START---

-- should be attached successfully and without needing to be scanned
alter table defpart_attach_test attach partition defpart_attach_test_d default;
---END---
---START---

-- check that attaching a partition correctly reports any rows in the default
-- partition that should not be there for the new partition to be attached
-- successfully
create table defpart_attach_test_2 (like defpart_attach_test_d);
---END---
---START---
alter table defpart_attach_test attach partition defpart_attach_test_2 for values in (2);
---END---
---START---

drop table defpart_attach_test;
---END---
---START---

-- check combinations of temporary and permanent relations when attaching
-- partitions.
create table perm_part_parent (a int) partition by list (a);
---END---
---START---
create table temp_part_parent (a int) partition by list (a);
---END---
---START---
create table perm_part_child (a int);
---END---
---START---
create table temp_part_child (a int);
---END---
---START---
alter table temp_part_parent attach partition perm_part_child default; -- error
alter table perm_part_parent attach partition temp_part_child default; -- error
alter table temp_part_parent attach partition temp_part_child default; -- ok
drop table perm_part_parent cascade;
---END---
---START---
drop table temp_part_parent cascade;
---END---
---START---

-- check that attaching partitions to a table while it is being used is
-- prevented
create table tab_part_attach (a int) partition by list (a);
---END---
---START---
create or replace function func_part_attach() returns trigger
  language plpgsql as $$
  begin
    execute 'create table tab_part_attach_1 (a int)';
---END---
---START---
    execute 'alter table tab_part_attach attach partition tab_part_attach_1 for values in (1)';
---END---
---START---
    return null;
---END---
---START---
  end $$;
---END---
---START---
create trigger trig_part_attach before insert on tab_part_attach
  for each statement execute procedure func_part_attach();
---END---
---START---
insert into tab_part_attach values (1);
---END---
---START---
drop table tab_part_attach;
---END---
---START---
drop function func_part_attach();
---END---
---START---

-- test case where the partitioning operator is a SQL function whose
-- evaluation results in the table's relcache being rebuilt partway through
-- the execution of an ATTACH PARTITION command
create function at_test_sql_partop (int4, int4) returns int language sql
as $$ select case when $1 = $2 then 0 when $1 > $2 then 1 else -1 end; $$;
---END---
---START---
create operator class at_test_sql_partop for type int4 using btree as
    operator 1 < (int4, int4), operator 2 <= (int4, int4),
    operator 3 = (int4, int4), operator 4 >= (int4, int4),
    operator 5 > (int4, int4), function 1 at_test_sql_partop(int4, int4);
---END---
---START---
create table at_test_sql_partop (a int) partition by range (a at_test_sql_partop);
---END---
---START---
create table at_test_sql_partop_1 (a int);
---END---
---START---
alter table at_test_sql_partop attach partition at_test_sql_partop_1 for values from (0) to (10);
---END---
---START---
drop table at_test_sql_partop;
---END---
---START---
drop operator class at_test_sql_partop using btree;
---END---
---START---
drop function at_test_sql_partop;
---END---
---START---


/* Test case for bug #16242 */

-- We create a parent and child where the child has missing
-- non-null attribute values, and arrange to pass them through
-- tuple conversion from the child to the parent tupdesc
create table bar1 (a integer, b integer not null default 1)
  partition by range (a);
---END---
---START---
create table bar2 (a integer);
---END---
---START---
insert into bar2 values (1);
---END---
---START---
alter table bar2 add column b integer not null default 1;
---END---
---START---
-- (at this point bar2 contains tuple with natts=1)
alter table bar1 attach partition bar2 default;
---END---
---START---

-- this works:
select * from bar1;
---END---
---START---

-- this exercises tuple conversion:
create function xtrig()
  returns trigger language plpgsql
as $$
  declare
    r record;
---END---
---START---
  begin
    for r in select * from old loop
      raise info 'a=%, b=%', r.a, r.b;
---END---
---START---
    end loop;
---END---
---START---
    return NULL;
---END---
---START---
  end;
---END---
---START---
$$;
---END---
---START---
create trigger xtrig
  after update on bar1
  referencing old table as old
  for each statement execute procedure xtrig();
---END---
---START---

update bar1 set a = a + 1;
---END---
---START---

/* End test case for bug #16242 */

/* Test case for bug #17409 */

create table attbl (p1 int constraint pk_attbl primary key);
---END---
---START---
create table atref (c1 int references attbl(p1));
---END---
---START---
cluster attbl using pk_attbl;
---END---
---START---
alter table attbl alter column p1 set data type bigint;
---END---
---START---
alter table atref alter column c1 set data type bigint;
---END---
---START---
drop table attbl, atref;
---END---
---START---

create table attbl (p1 int constraint pk_attbl primary key);
---END---
---START---
alter table attbl replica identity using index pk_attbl;
---END---
---START---
create table atref (c1 int references attbl(p1));
---END---
---START---
alter table attbl alter column p1 set data type bigint;
---END---
---START---
alter table atref alter column c1 set data type bigint;
---END---
---START---
drop table attbl, atref;
---END---
---START---

/* End test case for bug #17409 */

-- Test that ALTER TABLE rewrite preserves a clustered index
-- for normal indexes and indexes on constraints.
create table alttype_cluster (a int);
---END---
---START---
alter table alttype_cluster add primary key (a);
---END---
---START---
create index alttype_cluster_ind on alttype_cluster (a);
---END---
---START---
alter table alttype_cluster cluster on alttype_cluster_ind;
---END---
---START---
-- Normal index remains clustered.
select indexrelid::regclass, indisclustered from pg_index
  where indrelid = 'alttype_cluster'::regclass
  order by indexrelid::regclass::text;
---END---
---START---
alter table alttype_cluster alter a type bigint;
---END---
---START---
select indexrelid::regclass, indisclustered from pg_index
  where indrelid = 'alttype_cluster'::regclass
  order by indexrelid::regclass::text;
---END---
---START---
-- Constraint index remains clustered.
alter table alttype_cluster cluster on alttype_cluster_pkey;
---END---
---START---
select indexrelid::regclass, indisclustered from pg_index
  where indrelid = 'alttype_cluster'::regclass
  order by indexrelid::regclass::text;
---END---
---START---
alter table alttype_cluster alter a type int;
---END---
---START---
select indexrelid::regclass, indisclustered from pg_index
  where indrelid = 'alttype_cluster'::regclass
  order by indexrelid::regclass::text;
---END---
---START---
drop table alttype_cluster;
---END---
---START---

--
-- Check that attaching or detaching a partitioned partition correctly leads
-- to its partitions' constraint being updated to reflect the parent's
-- newly added/removed constraint
create table target_parted (a int, b int) partition by list (a);
---END---
---START---
create table attach_parted (a int, b int) partition by list (b);
---END---
---START---
create table attach_parted_part1 partition of attach_parted for values in (1);
---END---
---START---
-- insert a row directly into the leaf partition so that its partition
-- constraint is built and stored in the relcache
insert into attach_parted_part1 values (1, 1);
---END---
---START---
-- the following better invalidate the partition constraint of the leaf
-- partition too...
alter table target_parted attach partition attach_parted for values in (1);
---END---
---START---
-- ...such that the following insert fails
insert into attach_parted_part1 values (2, 1);
---END---
---START---
-- ...and doesn't when the partition is detached along with its own partition
alter table target_parted detach partition attach_parted;
---END---
---START---
insert into attach_parted_part1 values (2, 1);
---END---
---START---

-- Test altering table having publication
create schema alter1;
---END---
---START---
create schema alter2;
---END---
---START---
create table alter1.t1 (a int);
---END---
---START---
set client_min_messages = 'ERROR';
---END---
---START---
create publication pub1 for table alter1.t1, tables in schema alter2;
---END---
---START---
reset client_min_messages;
---END---
---START---
alter table alter1.t1 set schema alter2;
---END---
---START---
\d+ alter2.t1
drop publication pub1;
---END---
---START---
drop schema alter1 cascade;
---END---
---START---
drop schema alter2 cascade;
---END---
---START---
drop table if exists foo;
drop table if exists old_oids;
drop table if exists recur1;
drop table if exists recur2;
drop table if exists t1;
drop table if exists log;
drop table if exists filenode_mapping;
drop table if exists temp_parted;
drop table if exists temp_part_parent;
drop table if exists temp_part_child;
---END---
