---START---
-- Test basic TRUNCATE functionality.
CREATE TABLE truncate_a (col1 integer primary key);
---END---
---START---
INSERT INTO truncate_a VALUES (1);
---END---
---START---
INSERT INTO truncate_a VALUES (2);
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
-- Roll truncate back
BEGIN;
---END---
---START---
TRUNCATE truncate_a;
---END---
---START---
ROLLBACK;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
-- Commit the truncate this time
BEGIN;
---END---
---START---
TRUNCATE truncate_a;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
CREATE TABLE trunc_b (_gemini_pk serial PRIMARY KEY, a integer REFERENCES truncate_a);
---END---
---START---
CREATE TABLE trunc_c (a serial PRIMARY KEY);
---END---
---START---
CREATE TABLE trunc_d (_gemini_pk serial PRIMARY KEY, a integer REFERENCES trunc_c);
---END---
---START---
CREATE TABLE trunc_e (_gemini_pk serial PRIMARY KEY, a integer REFERENCES truncate_a, b integer REFERENCES trunc_c);
---END---
---START---
TRUNCATE TABLE truncate_a;
---END---
---START---
-- fail
TRUNCATE TABLE truncate_a,trunc_b;
---END---
---START---
-- fail
TRUNCATE TABLE truncate_a,trunc_b,trunc_e;
---END---
---START---
-- ok
TRUNCATE TABLE truncate_a,trunc_e;
---END---
---START---
-- fail
TRUNCATE TABLE trunc_c;
---END---
---START---
-- fail
TRUNCATE TABLE trunc_c,trunc_d;
---END---
---START---
-- fail
TRUNCATE TABLE trunc_c,trunc_d,trunc_e;
---END---
---START---
-- ok
TRUNCATE TABLE trunc_c,trunc_d,trunc_e,truncate_a;
---END---
---START---
-- fail
TRUNCATE TABLE trunc_c,trunc_d,trunc_e,truncate_a,trunc_b;
---END---
---START---
-- ok

TRUNCATE TABLE truncate_a RESTRICT;
---END---
---START---
-- fail
TRUNCATE TABLE truncate_a CASCADE;
---END---
---START---
-- ok

-- circular references
ALTER TABLE truncate_a ADD FOREIGN KEY (col1) REFERENCES trunc_c;
---END---
---START---
-- Add some data to verify that truncating actually works ...
INSERT INTO trunc_c VALUES (1);
---END---
---START---
INSERT INTO truncate_a VALUES (1);
---END---
---START---
INSERT INTO trunc_b VALUES (1);
---END---
---START---
INSERT INTO trunc_d VALUES (1);
---END---
---START---
INSERT INTO trunc_e VALUES (1,1);
---END---
---START---
TRUNCATE TABLE trunc_c;
---END---
---START---
TRUNCATE TABLE trunc_c,truncate_a;
---END---
---START---
TRUNCATE TABLE trunc_c,truncate_a,trunc_d;
---END---
---START---
TRUNCATE TABLE trunc_c,truncate_a,trunc_d,trunc_e;
---END---
---START---
TRUNCATE TABLE trunc_c,truncate_a,trunc_d,trunc_e,trunc_b;
---END---
---START---
-- Verify that truncating did actually work
SELECT * FROM truncate_a
   UNION ALL
 SELECT * FROM trunc_c
   UNION ALL
 SELECT * FROM trunc_b
   UNION ALL
 SELECT * FROM trunc_d;
---END---
---START---
SELECT * FROM trunc_e;
---END---
---START---
-- Add data again to test TRUNCATE ... CASCADE
INSERT INTO trunc_c VALUES (1);
---END---
---START---
INSERT INTO truncate_a VALUES (1);
---END---
---START---
INSERT INTO trunc_b VALUES (1);
---END---
---START---
INSERT INTO trunc_d VALUES (1);
---END---
---START---
INSERT INTO trunc_e VALUES (1,1);
---END---
---START---
TRUNCATE TABLE trunc_c CASCADE;
---END---
---START---
-- ok

SELECT * FROM truncate_a
   UNION ALL
 SELECT * FROM trunc_c
   UNION ALL
 SELECT * FROM trunc_b
   UNION ALL
 SELECT * FROM trunc_d;
---END---
---START---
SELECT * FROM trunc_e;
---END---
---START---
DROP TABLE truncate_a,trunc_c,trunc_b,trunc_d,trunc_e CASCADE;
---END---
---START---
-- Test TRUNCATE with inheritance

CREATE TABLE trunc_f (col1 integer primary key);
---END---
---START---
INSERT INTO trunc_f VALUES (1);
---END---
---START---
INSERT INTO trunc_f VALUES (2);
---END---
---START---
CREATE TABLE trunc_fa (_gemini_pk serial PRIMARY KEY, col2a text) INHERITS (trunc_f);
---END---
---START---
INSERT INTO trunc_fa VALUES (3, 'three');
---END---
---START---
CREATE TABLE trunc_fb (_gemini_pk serial PRIMARY KEY, col2b integer) INHERITS (trunc_f);
---END---
---START---
INSERT INTO trunc_fb VALUES (4, 444);
---END---
---START---
CREATE TABLE trunc_faa (_gemini_pk serial PRIMARY KEY, col3 text) INHERITS (trunc_fa);
---END---
---START---
INSERT INTO trunc_faa VALUES (5, 'five', 'FIVE');
---END---
---START---
BEGIN;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
TRUNCATE trunc_f;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
TRUNCATE ONLY trunc_f;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
SELECT * FROM trunc_fa;
---END---
---START---
SELECT * FROM trunc_faa;
---END---
---START---
TRUNCATE ONLY trunc_fb, ONLY trunc_fa;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
SELECT * FROM trunc_fa;
---END---
---START---
SELECT * FROM trunc_faa;
---END---
---START---
ROLLBACK;
---END---
---START---
BEGIN;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
SELECT * FROM trunc_fa;
---END---
---START---
SELECT * FROM trunc_faa;
---END---
---START---
TRUNCATE ONLY trunc_fb, trunc_fa;
---END---
---START---
SELECT * FROM trunc_f;
---END---
---START---
SELECT * FROM trunc_fa;
---END---
---START---
SELECT * FROM trunc_faa;
---END---
---START---
ROLLBACK;
---END---
---START---
DROP TABLE trunc_f CASCADE;
---END---
---START---
CREATE TABLE trunc_trigger_test (_gemini_pk serial PRIMARY KEY, f1 integer, f2 text, f3 text);
---END---
---START---
CREATE TABLE trunc_trigger_log (_gemini_pk serial PRIMARY KEY, tgop text, tglevel text, tgwhen text, tgargv text, tgtable name, rowcount bigint);
---END---
---START---
CREATE FUNCTION trunctrigger() RETURNS trigger as $$
declare c bigint;
begin
    execute 'select count(*) from ' || quote_ident(tg_table_name) into c;
    insert into trunc_trigger_log values
      (TG_OP, TG_LEVEL, TG_WHEN, TG_ARGV[0], tg_table_name, c);
    return null;
end;
$$ LANGUAGE plpgsql;
---END---
---START---
-- basic before trigger
INSERT INTO trunc_trigger_test VALUES(1, 'foo', 'bar'), (2, 'baz', 'quux');
---END---
---START---
CREATE TRIGGER t
BEFORE TRUNCATE ON trunc_trigger_test
FOR EACH STATEMENT
EXECUTE PROCEDURE trunctrigger('before trigger truncate');
---END---
---START---
SELECT count(*) as "Row count in test table" FROM trunc_trigger_test;
---END---
---START---
SELECT * FROM trunc_trigger_log;
---END---
---START---
TRUNCATE trunc_trigger_test;
---END---
---START---
SELECT count(*) as "Row count in test table" FROM trunc_trigger_test;
---END---
---START---
SELECT * FROM trunc_trigger_log;
---END---
---START---
DROP TRIGGER t ON trunc_trigger_test;
---END---
---START---
truncate trunc_trigger_log;
---END---
---START---
-- same test with an after trigger
INSERT INTO trunc_trigger_test VALUES(1, 'foo', 'bar'), (2, 'baz', 'quux');
---END---
---START---
CREATE TRIGGER tt
AFTER TRUNCATE ON trunc_trigger_test
FOR EACH STATEMENT
EXECUTE PROCEDURE trunctrigger('after trigger truncate');
---END---
---START---
SELECT count(*) as "Row count in test table" FROM trunc_trigger_test;
---END---
---START---
SELECT * FROM trunc_trigger_log;
---END---
---START---
TRUNCATE trunc_trigger_test;
---END---
---START---
SELECT count(*) as "Row count in test table" FROM trunc_trigger_test;
---END---
---START---
SELECT * FROM trunc_trigger_log;
---END---
---START---
DROP TABLE trunc_trigger_test;
---END---
---START---
DROP TABLE trunc_trigger_log;
---END---
---START---
DROP FUNCTION trunctrigger();
---END---
---START---
-- test TRUNCATE ... RESTART IDENTITY
CREATE SEQUENCE truncate_a_id1 START WITH 33;
---END---
---START---
CREATE TABLE truncate_a (_gemini_pk serial PRIMARY KEY, id serial, id1 integer DEFAULT nextval('truncate_a_id1'));
---END---
---START---
ALTER SEQUENCE truncate_a_id1 OWNED BY truncate_a.id1;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
TRUNCATE truncate_a;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
TRUNCATE truncate_a RESTART IDENTITY;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
CREATE TABLE truncate_b (_gemini_pk serial PRIMARY KEY, id integer GENERATED ALWAYS AS IDENTITY(START WITH 44));
---END---
---START---
INSERT INTO truncate_b DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_b DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_b;
---END---
---START---
TRUNCATE truncate_b;
---END---
---START---
INSERT INTO truncate_b DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_b DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_b;
---END---
---START---
TRUNCATE truncate_b RESTART IDENTITY;
---END---
---START---
INSERT INTO truncate_b DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_b DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_b;
---END---
---START---
-- check rollback of a RESTART IDENTITY operation
BEGIN;
---END---
---START---
TRUNCATE truncate_a RESTART IDENTITY;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
ROLLBACK;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
INSERT INTO truncate_a DEFAULT VALUES;
---END---
---START---
SELECT * FROM truncate_a;
---END---
---START---
DROP TABLE truncate_a;
---END---
---START---
SELECT nextval('truncate_a_id1');
---END---
---START---
CREATE TABLE truncparted (_gemini_pk serial PRIMARY KEY, a integer, b char) PARTITION BY list (a);
---END---
---START---
-- error, can't truncate a partitioned table
TRUNCATE ONLY truncparted;
---END---
---START---
CREATE TABLE truncparted1 PARTITION OF truncparted FOR VALUES IN (1);
---END---
---START---
INSERT INTO truncparted VALUES (1, 'a');
---END---
---START---
-- error, must truncate partitions
TRUNCATE ONLY truncparted;
---END---
---START---
TRUNCATE truncparted;
---END---
---START---
DROP TABLE truncparted;
---END---
---START---
-- foreign key on partitioned table: partition key is referencing column.
-- Make sure truncate did execute on all tables
CREATE FUNCTION tp_ins_data() RETURNS void LANGUAGE plpgsql AS $$
  BEGIN
	INSERT INTO truncprim VALUES (1), (100), (150);
	INSERT INTO truncpart VALUES (1), (100), (150);
  END
$$;
---END---
---START---
CREATE FUNCTION tp_chk_data(OUT pktb regclass, OUT pkval int, OUT fktb regclass, OUT fkval int)
  RETURNS SETOF record LANGUAGE plpgsql AS $$
  BEGIN
    RETURN QUERY SELECT
      pk.tableoid::regclass, pk.a, fk.tableoid::regclass, fk.a
    FROM truncprim pk FULL JOIN truncpart fk USING (a)
    ORDER BY 2, 4;
  END
$$;
---END---
---START---
CREATE TABLE truncprim (a int PRIMARY KEY);
---END---
---START---
CREATE TABLE truncpart (_gemini_pk serial PRIMARY KEY, a integer REFERENCES truncprim) PARTITION BY range (a);
---END---
---START---
CREATE TABLE truncpart_1 PARTITION OF truncpart FOR VALUES FROM (0) TO (100);
---END---
---START---
CREATE TABLE truncpart_2 PARTITION OF truncpart FOR VALUES FROM (100) TO (200)
  PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE truncpart_2_1 PARTITION OF truncpart_2 FOR VALUES FROM (100) TO (150);
---END---
---START---
CREATE TABLE truncpart_2_d PARTITION OF truncpart_2 DEFAULT;
---END---
---START---
TRUNCATE TABLE truncprim;
---END---
---START---
-- should fail

select tp_ins_data();
---END---
---START---
-- should truncate everything
TRUNCATE TABLE truncprim, truncpart;
---END---
---START---
select * from tp_chk_data();
---END---
---START---
select tp_ins_data();
---END---
---START---
-- should truncate everything
TRUNCATE TABLE truncprim CASCADE;
---END---
---START---
SELECT * FROM tp_chk_data();
---END---
---START---
SELECT tp_ins_data();
---END---
---START---
-- should truncate all partitions
TRUNCATE TABLE truncpart;
---END---
---START---
SELECT * FROM tp_chk_data();
---END---
---START---
DROP TABLE truncprim, truncpart;
---END---
---START---
DROP FUNCTION tp_ins_data(), tp_chk_data();
---END---
---START---
-- test cascade when referencing a partitioned table
CREATE TABLE trunc_a (a INT PRIMARY KEY) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE trunc_a1 PARTITION OF trunc_a FOR VALUES FROM (0) TO (10);
---END---
---START---
CREATE TABLE trunc_a2 PARTITION OF trunc_a FOR VALUES FROM (10) TO (20)
  PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE trunc_a21 PARTITION OF trunc_a2 FOR VALUES FROM (10) TO (12);
---END---
---START---
CREATE TABLE trunc_a22 PARTITION OF trunc_a2 FOR VALUES FROM (12) TO (16);
---END---
---START---
CREATE TABLE trunc_a2d PARTITION OF trunc_a2 DEFAULT;
---END---
---START---
CREATE TABLE trunc_a3 PARTITION OF trunc_a FOR VALUES FROM (20) TO (30);
---END---
---START---
INSERT INTO trunc_a VALUES (0), (5), (10), (15), (20), (25);
---END---
---START---
-- truncate a partition cascading to a table
CREATE TABLE ref_b (
    b INT PRIMARY KEY,
    a INT REFERENCES trunc_a(a) ON DELETE CASCADE
);
---END---
---START---
INSERT INTO ref_b VALUES (10, 0), (50, 5), (100, 10), (150, 15);
---END---
---START---
TRUNCATE TABLE trunc_a1 CASCADE;
---END---
---START---
SELECT a FROM ref_b;
---END---
---START---
DROP TABLE ref_b;
---END---
---START---
-- truncate a partition cascading to a partitioned table
CREATE TABLE ref_c (
    c INT PRIMARY KEY,
    a INT REFERENCES trunc_a(a) ON DELETE CASCADE
) PARTITION BY RANGE (c);
---END---
---START---
CREATE TABLE ref_c1 PARTITION OF ref_c FOR VALUES FROM (100) TO (200);
---END---
---START---
CREATE TABLE ref_c2 PARTITION OF ref_c FOR VALUES FROM (200) TO (300);
---END---
---START---
INSERT INTO ref_c VALUES (100, 10), (150, 15), (200, 20), (250, 25);
---END---
---START---
TRUNCATE TABLE trunc_a21 CASCADE;
---END---
---START---
SELECT a as "from table ref_c" FROM ref_c;
---END---
---START---
SELECT a as "from table trunc_a" FROM trunc_a ORDER BY a;
---END---
---START---
DROP TABLE trunc_a, ref_c;
---END---
