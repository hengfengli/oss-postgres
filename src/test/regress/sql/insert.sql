---START---
CREATE TABLE inserttest (gemini_pk serial PRIMARY KEY, col1 int4, col2 int4 NOT NULL, col3 text DEFAULT 'testing');
---END---
---START---
insert into inserttest (col1, col2, col3) values (DEFAULT, DEFAULT, DEFAULT);
---END---
---START---
insert into inserttest (col2, col3) values (3, DEFAULT);
---END---
---START---
insert into inserttest (col1, col2, col3) values (DEFAULT, 5, DEFAULT);
---END---
---START---
insert into inserttest values (DEFAULT, 5, 'test');
---END---
---START---
insert into inserttest values (DEFAULT, 7);
---END---
---START---
select * from inserttest;
---END---
---START---
--
-- insert with similar expression / target_list values (all fail)
--
insert into inserttest (col1, col2, col3) values (DEFAULT, DEFAULT);
---END---
---START---
insert into inserttest (col1, col2, col3) values (1, 2);
---END---
---START---
insert into inserttest (col1) values (1, 2);
---END---
---START---
insert into inserttest (col1) values (DEFAULT, DEFAULT);
---END---
---START---
select * from inserttest;
---END---
---START---
--
-- VALUES test
--
insert into inserttest values(10, 20, '40'), (-1, 2, DEFAULT),
    ((select 2), (select i from (values(3)) as foo (i)), 'values are fun!');
---END---
---START---
select * from inserttest;
---END---
---START---
--
-- TOASTed value test
--
insert into inserttest values(30, 50, repeat('x', 10000));
---END---
---START---
select col1, col2, char_length(col3) from inserttest;
---END---
---START---
drop table inserttest;
---END---
---START---
CREATE TABLE large_tuple_test (gemini_pk serial PRIMARY KEY, a integer, b text) WITH (fillfactor = 10);
---END---
---START---
ALTER TABLE large_tuple_test ALTER COLUMN b SET STORAGE plain;
---END---
---START---
-- create page w/ free space in range [nearlyEmptyFreeSpace, MaxHeapTupleSize)
INSERT INTO large_tuple_test (select 1, NULL);
---END---
---START---
-- should still fit on the page
INSERT INTO large_tuple_test (select 2, repeat('a', 1000));
---END---
---START---
SELECT pg_size_pretty(pg_relation_size('large_tuple_test'::regclass, 'main'));
---END---
---START---
-- add small record to the second page
INSERT INTO large_tuple_test (select 3, NULL);
---END---
---START---
-- now this tuple won't fit on the second page, but the insert should
-- still succeed by extending the relation
INSERT INTO large_tuple_test (select 4, repeat('a', 8126));
---END---
---START---
DROP TABLE large_tuple_test;
---END---
---START---
--
-- check indirection (field/array assignment), cf bug #14265
--
-- these tests are aware that transformInsertStmt has 3 separate code paths
--

create type insert_test_type as (if1 int, if2 text[]);
---END---
---START---
CREATE TABLE inserttest (gemini_pk serial PRIMARY KEY, f1 integer, f2 integer[], f3 insert_test_type, f4 insert_test_type[]);
---END---
---START---
insert into inserttest (f2[1], f2[2]) values (1,2);
---END---
---START---
insert into inserttest (f2[1], f2[2]) values (3,4), (5,6);
---END---
---START---
insert into inserttest (f2[1], f2[2]) select 7,8;
---END---
---START---
insert into inserttest (f2[1], f2[2]) values (1,default);
---END---
---START---
-- not supported

insert into inserttest (f3.if1, f3.if2) values (1,array['foo']);
---END---
---START---
insert into inserttest (f3.if1, f3.if2) values (1,'{foo}'), (2,'{bar}');
---END---
---START---
insert into inserttest (f3.if1, f3.if2) select 3, '{baz,quux}';
---END---
---START---
insert into inserttest (f3.if1, f3.if2) values (1,default);
---END---
---START---
-- not supported

insert into inserttest (f3.if2[1], f3.if2[2]) values ('foo', 'bar');
---END---
---START---
insert into inserttest (f3.if2[1], f3.if2[2]) values ('foo', 'bar'), ('baz', 'quux');
---END---
---START---
insert into inserttest (f3.if2[1], f3.if2[2]) select 'bear', 'beer';
---END---
---START---
insert into inserttest (f4[1].if2[1], f4[1].if2[2]) values ('foo', 'bar');
---END---
---START---
insert into inserttest (f4[1].if2[1], f4[1].if2[2]) values ('foo', 'bar'), ('baz', 'quux');
---END---
---START---
insert into inserttest (f4[1].if2[1], f4[1].if2[2]) select 'bear', 'beer';
---END---
---START---
select * from inserttest;
---END---
---START---
CREATE TABLE inserttest2 (gemini_pk serial PRIMARY KEY, f1 bigint, f2 text);
---END---
---START---
create rule irule1 as on insert to inserttest2 do also
  insert into inserttest (f3.if2[1], f3.if2[2])
  values (new.f1,new.f2);
---END---
---START---
create rule irule2 as on insert to inserttest2 do also
  insert into inserttest (f4[1].if1, f4[1].if2[2])
  values (1,'fool'),(new.f1,new.f2);
---END---
---START---
create rule irule3 as on insert to inserttest2 do also
  insert into inserttest (f4[1].if1, f4[1].if2[2])
  select new.f1, new.f2;
---END---
---START---
\d+ inserttest2

drop table inserttest2;
---END---
---START---
drop table inserttest;
---END---
---START---
drop type insert_test_type;
---END---
---START---
CREATE TABLE range_parted (gemini_pk serial PRIMARY KEY, a text, b integer) PARTITION BY range (a, (b + 0));
---END---
---START---
-- no partitions, so fail
insert into range_parted values ('a', 11);
---END---
---START---
create table part1 partition of range_parted for values from ('a', 1) to ('a', 10);
---END---
---START---
create table part2 partition of range_parted for values from ('a', 10) to ('a', 20);
---END---
---START---
create table part3 partition of range_parted for values from ('b', 1) to ('b', 10);
---END---
---START---
create table part4 partition of range_parted for values from ('b', 10) to ('b', 20);
---END---
---START---
-- fail
insert into part1 values ('a', 11);
---END---
---START---
insert into part1 values ('b', 1);
---END---
---START---
-- ok
insert into part1 values ('a', 1);
---END---
---START---
-- fail
insert into part4 values ('b', 21);
---END---
---START---
insert into part4 values ('a', 10);
---END---
---START---
-- ok
insert into part4 values ('b', 10);
---END---
---START---
-- fail (partition key a has a NOT NULL constraint)
insert into part1 values (null);
---END---
---START---
-- fail (expression key (b+0) cannot be null either)
insert into part1 values (1);
---END---
---START---
CREATE TABLE list_parted (gemini_pk serial PRIMARY KEY, a text, b integer) PARTITION BY list ((lower(a)));
---END---
---START---
create table part_aa_bb partition of list_parted FOR VALUES IN ('aa', 'bb');
---END---
---START---
create table part_cc_dd partition of list_parted FOR VALUES IN ('cc', 'dd');
---END---
---START---
create table part_null partition of list_parted FOR VALUES IN (null);
---END---
---START---
-- fail
insert into part_aa_bb values ('cc', 1);
---END---
---START---
insert into part_aa_bb values ('AAa', 1);
---END---
---START---
insert into part_aa_bb values (null);
---END---
---START---
-- ok
insert into part_cc_dd values ('cC', 1);
---END---
---START---
insert into part_null values (null, 0);
---END---
---START---
-- check in case of multi-level partitioned table
create table part_ee_ff partition of list_parted for values in ('ee', 'ff') partition by range (b);
---END---
---START---
create table part_ee_ff1 partition of part_ee_ff for values from (1) to (10);
---END---
---START---
create table part_ee_ff2 partition of part_ee_ff for values from (10) to (20);
---END---
---START---
-- test default partition
create table part_default partition of list_parted default;
---END---
---START---
-- Negative test: a row, which would fit in other partition, does not fit
-- default partition, even when inserted directly
insert into part_default values ('aa', 2);
---END---
---START---
insert into part_default values (null, 2);
---END---
---START---
-- ok
insert into part_default values ('Zz', 2);
---END---
---START---
-- test if default partition works as expected for multi-level partitioned
-- table as well as when default partition itself is further partitioned
drop table part_default;
---END---
---START---
create table part_xx_yy partition of list_parted for values in ('xx', 'yy') partition by list (a);
---END---
---START---
create table part_xx_yy_p1 partition of part_xx_yy for values in ('xx');
---END---
---START---
create table part_xx_yy_defpart partition of part_xx_yy default;
---END---
---START---
create table part_default partition of list_parted default partition by range(b);
---END---
---START---
create table part_default_p1 partition of part_default for values from (20) to (30);
---END---
---START---
create table part_default_p2 partition of part_default for values from (30) to (40);
---END---
---START---
-- fail
insert into part_ee_ff1 values ('EE', 11);
---END---
---START---
insert into part_default_p2 values ('gg', 43);
---END---
---START---
-- fail (even the parent's, ie, part_ee_ff's partition constraint applies)
insert into part_ee_ff1 values ('cc', 1);
---END---
---START---
insert into part_default values ('gg', 43);
---END---
---START---
-- ok
insert into part_ee_ff1 values ('ff', 1);
---END---
---START---
insert into part_ee_ff2 values ('ff', 11);
---END---
---START---
insert into part_default_p1 values ('cd', 25);
---END---
---START---
insert into part_default_p2 values ('de', 35);
---END---
---START---
insert into list_parted values ('ab', 21);
---END---
---START---
insert into list_parted values ('xx', 1);
---END---
---START---
insert into list_parted values ('yy', 2);
---END---
---START---
select tableoid::regclass, * from list_parted;
---END---
---START---
-- Check tuple routing for partitioned tables

-- fail
insert into range_parted values ('a', 0);
---END---
---START---
-- ok
insert into range_parted values ('a', 1);
---END---
---START---
insert into range_parted values ('a', 10);
---END---
---START---
-- fail
insert into range_parted values ('a', 20);
---END---
---START---
-- ok
insert into range_parted values ('b', 1);
---END---
---START---
insert into range_parted values ('b', 10);
---END---
---START---
-- fail (partition key (b+0) is null)
insert into range_parted values ('a');
---END---
---START---
-- Check default partition
create table part_def partition of range_parted default;
---END---
---START---
-- fail
insert into part_def values ('b', 10);
---END---
---START---
-- ok
insert into part_def values ('c', 10);
---END---
---START---
insert into range_parted values (null, null);
---END---
---START---
insert into range_parted values ('a', null);
---END---
---START---
insert into range_parted values (null, 19);
---END---
---START---
insert into range_parted values ('b', 20);
---END---
---START---
select tableoid::regclass, * from range_parted;
---END---
---START---
-- ok
insert into list_parted values (null, 1);
---END---
---START---
insert into list_parted (a) values ('aA');
---END---
---START---
-- fail (partition of part_ee_ff not found in both cases)
insert into list_parted values ('EE', 0);
---END---
---START---
insert into part_ee_ff values ('EE', 0);
---END---
---START---
-- ok
insert into list_parted values ('EE', 1);
---END---
---START---
insert into part_ee_ff values ('EE', 10);
---END---
---START---
select tableoid::regclass, * from list_parted;
---END---
---START---
-- some more tests to exercise tuple-routing with multi-level partitioning
create table part_gg partition of list_parted for values in ('gg') partition by range (b);
---END---
---START---
create table part_gg1 partition of part_gg for values from (minvalue) to (1);
---END---
---START---
create table part_gg2 partition of part_gg for values from (1) to (10) partition by range (b);
---END---
---START---
create table part_gg2_1 partition of part_gg2 for values from (1) to (5);
---END---
---START---
create table part_gg2_2 partition of part_gg2 for values from (5) to (10);
---END---
---START---
create table part_ee_ff3 partition of part_ee_ff for values from (20) to (30) partition by range (b);
---END---
---START---
create table part_ee_ff3_1 partition of part_ee_ff3 for values from (20) to (25);
---END---
---START---
create table part_ee_ff3_2 partition of part_ee_ff3 for values from (25) to (30);
---END---
---START---
truncate list_parted;
---END---
---START---
insert into list_parted values ('aa'), ('cc');
---END---
---START---
insert into list_parted select 'Ff', s.a from generate_series(1, 29) s(a);
---END---
---START---
insert into list_parted select 'gg', s.a from generate_series(1, 9) s(a);
---END---
---START---
insert into list_parted (b) values (1);
---END---
---START---
select tableoid::regclass::text, a, min(b) as min_b, max(b) as max_b from list_parted group by 1, 2 order by 1;
---END---
---START---
CREATE TABLE hash_parted (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY hash (a part_test_int4_ops);
---END---
---START---
create table hpart0 partition of hash_parted for values with (modulus 4, remainder 0);
---END---
---START---
create table hpart1 partition of hash_parted for values with (modulus 4, remainder 1);
---END---
---START---
create table hpart2 partition of hash_parted for values with (modulus 4, remainder 2);
---END---
---START---
create table hpart3 partition of hash_parted for values with (modulus 4, remainder 3);
---END---
---START---
insert into hash_parted values(generate_series(1,10));
---END---
---START---
-- direct insert of values divisible by 4 - ok;
insert into hpart0 values(12),(16);
---END---
---START---
-- fail;
insert into hpart0 values(11);
---END---
---START---
-- 11 % 4 -> 3 remainder i.e. valid data for hpart3 partition
insert into hpart3 values(11);
---END---
---START---
-- view data
select tableoid::regclass as part, a, a%4 as "remainder = a % 4"
from hash_parted order by part;
---END---
---START---
-- test \d+ output on a table which has both partitioned and unpartitioned
-- partitions
\d+ list_parted

-- cleanup
drop table range_parted, list_parted;
---END---
---START---
drop table hash_parted;
---END---
---START---
CREATE TABLE list_parted (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY list (a);
---END---
---START---
create table part_default partition of list_parted default;
---END---
---START---
\d+ part_default
insert into part_default values (null);
---END---
---START---
insert into part_default values (1);
---END---
---START---
insert into part_default values (-1);
---END---
---START---
select tableoid::regclass, a from list_parted;
---END---
---START---
-- cleanup
drop table list_parted;
---END---
---START---
CREATE TABLE mlparted (gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a, b);
---END---
---START---
CREATE TABLE mlparted1 (gemini_pk serial PRIMARY KEY, b integer NOT NULL, a integer NOT NULL) PARTITION BY range ((b + 0));
---END---
---START---
CREATE TABLE mlparted11 (gemini_pk serial PRIMARY KEY, LIKE mlparted1);
---END---
---START---
alter table mlparted11 drop a;
---END---
---START---
alter table mlparted11 add a int;
---END---
---START---
alter table mlparted11 drop a;
---END---
---START---
alter table mlparted11 add a int not null;
---END---
---START---
-- attnum for key attribute 'a' is different in mlparted, mlparted1, and mlparted11
select attrelid::regclass, attname, attnum
from pg_attribute
where attname = 'a'
 and (attrelid = 'mlparted'::regclass
   or attrelid = 'mlparted1'::regclass
   or attrelid = 'mlparted11'::regclass)
order by attrelid::regclass::text;
---END---
---START---
alter table mlparted1 attach partition mlparted11 for values from (2) to (5);
---END---
---START---
alter table mlparted attach partition mlparted1 for values from (1, 2) to (1, 10);
---END---
---START---
-- check that "(1, 2)" is correctly routed to mlparted11.
insert into mlparted values (1, 2);
---END---
---START---
select tableoid::regclass, * from mlparted;
---END---
---START---
-- check that proper message is shown after failure to route through mlparted1
insert into mlparted (a, b) values (1, 5);
---END---
---START---
truncate mlparted;
---END---
---START---
alter table mlparted add constraint check_b check (b = 3);
---END---
---START---
-- have a BR trigger modify the row such that the check_b is violated
create function mlparted11_trig_fn()
returns trigger AS
$$
begin
  NEW.b := 4;
  return NEW;
end;
$$
language plpgsql;
---END---
---START---
create trigger mlparted11_trig before insert ON mlparted11
  for each row execute procedure mlparted11_trig_fn();
---END---
---START---
-- check that the correct row is shown when constraint check_b fails after
-- "(1, 2)" is routed to mlparted11 (actually "(1, 4)" would be shown due
-- to the BR trigger mlparted11_trig_fn)
insert into mlparted values (1, 2);
---END---
---START---
drop trigger mlparted11_trig on mlparted11;
---END---
---START---
drop function mlparted11_trig_fn();
---END---
---START---
-- check that inserting into an internal partition successfully results in
-- checking its partition constraint before inserting into the leaf partition
-- selected by tuple-routing
insert into mlparted1 (a, b) values (2, 3);
---END---
---START---
CREATE TABLE lparted_nonullpart (gemini_pk serial PRIMARY KEY, a integer, b char) PARTITION BY list (b);
---END---
---START---
create table lparted_nonullpart_a partition of lparted_nonullpart for values in ('a');
---END---
---START---
insert into lparted_nonullpart values (1);
---END---
---START---
drop table lparted_nonullpart;
---END---
---START---
-- check that RETURNING works correctly with tuple-routing
alter table mlparted drop constraint check_b;
---END---
---START---
create table mlparted12 partition of mlparted1 for values from (5) to (10);
---END---
---START---
CREATE TABLE mlparted2 (gemini_pk serial PRIMARY KEY, b integer NOT NULL, a integer NOT NULL);
---END---
---START---
alter table mlparted attach partition mlparted2 for values from (1, 10) to (1, 20);
---END---
---START---
create table mlparted3 partition of mlparted for values from (1, 20) to (1, 30);
---END---
---START---
CREATE TABLE mlparted4 (gemini_pk serial PRIMARY KEY, LIKE mlparted);
---END---
---START---
alter table mlparted4 drop a;
---END---
---START---
alter table mlparted4 add a int not null;
---END---
---START---
alter table mlparted attach partition mlparted4 for values from (1, 30) to (1, 40);
---END---
---START---
with ins (a, b, c) as
  (insert into mlparted (b, a) select s.a, 1 from generate_series(2, 39) s(a) returning tableoid::regclass, *)
  select a, b, min(c), max(c) from ins group by a, b order by 1;
---END---
---START---
alter table mlparted add c text;
---END---
---START---
CREATE TABLE mlparted5 (gemini_pk serial PRIMARY KEY, c text, a integer NOT NULL, b integer NOT NULL) PARTITION BY list (c);
---END---
---START---
CREATE TABLE mlparted5a (gemini_pk serial PRIMARY KEY, a integer NOT NULL, c text, b integer NOT NULL);
---END---
---START---
alter table mlparted5 attach partition mlparted5a for values in ('a');
---END---
---START---
alter table mlparted attach partition mlparted5 for values from (1, 40) to (1, 50);
---END---
---START---
alter table mlparted add constraint check_b check (a = 1 and b < 45);
---END---
---START---
insert into mlparted values (1, 45, 'a');
---END---
---START---
create function mlparted5abrtrig_func() returns trigger as $$ begin new.c = 'b'; return new; end; $$ language plpgsql;
---END---
---START---
create trigger mlparted5abrtrig before insert on mlparted5a for each row execute procedure mlparted5abrtrig_func();
---END---
---START---
insert into mlparted5 (a, b, c) values (1, 40, 'a');
---END---
---START---
drop table mlparted5;
---END---
---START---
alter table mlparted drop constraint check_b;
---END---
---START---
-- Check multi-level default partition
create table mlparted_def partition of mlparted default partition by range(a);
---END---
---START---
create table mlparted_def1 partition of mlparted_def for values from (40) to (50);
---END---
---START---
create table mlparted_def2 partition of mlparted_def for values from (50) to (60);
---END---
---START---
insert into mlparted values (40, 100);
---END---
---START---
insert into mlparted_def1 values (42, 100);
---END---
---START---
insert into mlparted_def2 values (54, 50);
---END---
---START---
-- fail
insert into mlparted values (70, 100);
---END---
---START---
insert into mlparted_def1 values (52, 50);
---END---
---START---
insert into mlparted_def2 values (34, 50);
---END---
---START---
-- ok
create table mlparted_defd partition of mlparted_def default;
---END---
---START---
insert into mlparted values (70, 100);
---END---
---START---
select tableoid::regclass, * from mlparted_def;
---END---
---START---
-- Check multi-level tuple routing with attributes dropped from the
-- top-most parent.  First remove the last attribute.
alter table mlparted add d int, add e int;
---END---
---START---
alter table mlparted drop e;
---END---
---START---
create table mlparted5 partition of mlparted
  for values from (1, 40) to (1, 50) partition by range (c);
---END---
---START---
create table mlparted5_ab partition of mlparted5
  for values from ('a') to ('c') partition by list (c);
---END---
---START---
-- This partitioned table should remain with no partitions.
create table mlparted5_cd partition of mlparted5
  for values from ('c') to ('e') partition by list (c);
---END---
---START---
create table mlparted5_a partition of mlparted5_ab for values in ('a');
---END---
---START---
CREATE TABLE mlparted5_b (gemini_pk serial PRIMARY KEY, d integer, b integer, c text, a integer);
---END---
---START---
alter table mlparted5_ab attach partition mlparted5_b for values in ('b');
---END---
---START---
truncate mlparted;
---END---
---START---
insert into mlparted values (1, 2, 'a', 1);
---END---
---START---
insert into mlparted values (1, 40, 'a', 1);
---END---
---START---
-- goes to mlparted5_a
insert into mlparted values (1, 45, 'b', 1);
---END---
---START---
-- goes to mlparted5_b
insert into mlparted values (1, 45, 'c', 1);
---END---
---START---
-- goes to mlparted5_cd, fails
insert into mlparted values (1, 45, 'f', 1);
---END---
---START---
-- goes to mlparted5, fails
select tableoid::regclass, * from mlparted order by a, b, c, d;
---END---
---START---
alter table mlparted drop d;
---END---
---START---
truncate mlparted;
---END---
---START---
-- Remove the before last attribute.
alter table mlparted add e int, add d int;
---END---
---START---
alter table mlparted drop e;
---END---
---START---
insert into mlparted values (1, 2, 'a', 1);
---END---
---START---
insert into mlparted values (1, 40, 'a', 1);
---END---
---START---
-- goes to mlparted5_a
insert into mlparted values (1, 45, 'b', 1);
---END---
---START---
-- goes to mlparted5_b
insert into mlparted values (1, 45, 'c', 1);
---END---
---START---
-- goes to mlparted5_cd, fails
insert into mlparted values (1, 45, 'f', 1);
---END---
---START---
-- goes to mlparted5, fails
select tableoid::regclass, * from mlparted order by a, b, c, d;
---END---
---START---
alter table mlparted drop d;
---END---
---START---
drop table mlparted5;
---END---
---START---
CREATE TABLE key_desc (gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY list ((a + 0));
---END---
---START---
create table key_desc_1 partition of key_desc for values in (1) partition by range (b);
---END---
---START---
create user regress_insert_other_user;
---END---
---START---
grant select (a) on key_desc_1 to regress_insert_other_user;
---END---
---START---
grant insert on key_desc to regress_insert_other_user;
---END---
---START---
set role regress_insert_other_user;
---END---
---START---
-- no key description is shown
insert into key_desc values (1, 1);
---END---
---START---
reset role;
---END---
---START---
grant select (b) on key_desc_1 to regress_insert_other_user;
---END---
---START---
set role regress_insert_other_user;
---END---
---START---
-- key description (b)=(1) is now shown
insert into key_desc values (1, 1);
---END---
---START---
-- key description is not shown if key contains expression
insert into key_desc values (2, 1);
---END---
---START---
reset role;
---END---
---START---
revoke all on key_desc from regress_insert_other_user;
---END---
---START---
revoke all on key_desc_1 from regress_insert_other_user;
---END---
---START---
drop role regress_insert_other_user;
---END---
---START---
drop table key_desc, key_desc_1;
---END---
---START---
CREATE TABLE mcrparted (gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (a, (abs(b)), c);
---END---
---START---
create table mcrparted0 partition of mcrparted for values from (minvalue, 0, 0) to (1, maxvalue, maxvalue);
---END---
---START---
create table mcrparted2 partition of mcrparted for values from (10, 6, minvalue) to (10, maxvalue, minvalue);
---END---
---START---
create table mcrparted4 partition of mcrparted for values from (21, minvalue, 0) to (30, 20, minvalue);
---END---
---START---
-- check multi-column range partitioning expression enforces the same
-- constraint as what tuple-routing would determine it to be
create table mcrparted0 partition of mcrparted for values from (minvalue, minvalue, minvalue) to (1, maxvalue, maxvalue);
---END---
---START---
create table mcrparted1 partition of mcrparted for values from (2, 1, minvalue) to (10, 5, 10);
---END---
---START---
create table mcrparted2 partition of mcrparted for values from (10, 6, minvalue) to (10, maxvalue, maxvalue);
---END---
---START---
create table mcrparted3 partition of mcrparted for values from (11, 1, 1) to (20, 10, 10);
---END---
---START---
create table mcrparted4 partition of mcrparted for values from (21, minvalue, minvalue) to (30, 20, maxvalue);
---END---
---START---
create table mcrparted5 partition of mcrparted for values from (30, 21, 20) to (maxvalue, maxvalue, maxvalue);
---END---
---START---
-- null not allowed in range partition
insert into mcrparted values (null, null, null);
---END---
---START---
-- routed to mcrparted0
insert into mcrparted values (0, 1, 1);
---END---
---START---
insert into mcrparted0 values (0, 1, 1);
---END---
---START---
-- routed to mcparted1
insert into mcrparted values (9, 1000, 1);
---END---
---START---
insert into mcrparted1 values (9, 1000, 1);
---END---
---START---
insert into mcrparted values (10, 5, -1);
---END---
---START---
insert into mcrparted1 values (10, 5, -1);
---END---
---START---
insert into mcrparted values (2, 1, 0);
---END---
---START---
insert into mcrparted1 values (2, 1, 0);
---END---
---START---
-- routed to mcparted2
insert into mcrparted values (10, 6, 1000);
---END---
---START---
insert into mcrparted2 values (10, 6, 1000);
---END---
---START---
insert into mcrparted values (10, 1000, 1000);
---END---
---START---
insert into mcrparted2 values (10, 1000, 1000);
---END---
---START---
-- no partition exists, nor does mcrparted3 accept it
insert into mcrparted values (11, 1, -1);
---END---
---START---
insert into mcrparted3 values (11, 1, -1);
---END---
---START---
-- routed to mcrparted5
insert into mcrparted values (30, 21, 20);
---END---
---START---
insert into mcrparted5 values (30, 21, 20);
---END---
---START---
insert into mcrparted4 values (30, 21, 20);
---END---
---START---
-- error

-- check rows
select tableoid::regclass::text, * from mcrparted order by 1;
---END---
---START---
-- cleanup
drop table mcrparted;
---END---
---START---
CREATE TABLE brtrigpartcon (gemini_pk serial PRIMARY KEY, a integer, b text) PARTITION BY list (a);
---END---
---START---
create table brtrigpartcon1 partition of brtrigpartcon for values in (1);
---END---
---START---
create or replace function brtrigpartcon1trigf() returns trigger as $$begin new.a := 2; return new; end$$ language plpgsql;
---END---
---START---
create trigger brtrigpartcon1trig before insert on brtrigpartcon1 for each row execute procedure brtrigpartcon1trigf();
---END---
---START---
insert into brtrigpartcon values (1, 'hi there');
---END---
---START---
insert into brtrigpartcon1 values (1, 'hi there');
---END---
---START---
CREATE TABLE inserttest3 (gemini_pk serial PRIMARY KEY, f1 text DEFAULT 'foo', f2 text DEFAULT 'bar', f3 integer);
---END---
---START---
create role regress_coldesc_role;
---END---
---START---
grant insert on inserttest3 to regress_coldesc_role;
---END---
---START---
grant insert on brtrigpartcon to regress_coldesc_role;
---END---
---START---
revoke select on brtrigpartcon from regress_coldesc_role;
---END---
---START---
set role regress_coldesc_role;
---END---
---START---
with result as (insert into brtrigpartcon values (1, 'hi there') returning 1)
  insert into inserttest3 (f3) select * from result;
---END---
---START---
reset role;
---END---
---START---
-- cleanup
revoke all on inserttest3 from regress_coldesc_role;
---END---
---START---
revoke all on brtrigpartcon from regress_coldesc_role;
---END---
---START---
drop role regress_coldesc_role;
---END---
---START---
drop table inserttest3;
---END---
---START---
drop table brtrigpartcon;
---END---
---START---
drop function brtrigpartcon1trigf();
---END---
---START---
CREATE TABLE donothingbrtrig_test (gemini_pk serial PRIMARY KEY, a integer, b text) PARTITION BY list (a);
---END---
---START---
CREATE TABLE donothingbrtrig_test1 (gemini_pk serial PRIMARY KEY, b text, a integer);
---END---
---START---
CREATE TABLE donothingbrtrig_test2 (gemini_pk serial PRIMARY KEY, c text, b text, a integer);
---END---
---START---
alter table donothingbrtrig_test2 drop column c;
---END---
---START---
create or replace function donothingbrtrig_func() returns trigger as $$begin raise notice 'b: %', new.b; return NULL; end$$ language plpgsql;
---END---
---START---
create trigger donothingbrtrig1 before insert on donothingbrtrig_test1 for each row execute procedure donothingbrtrig_func();
---END---
---START---
create trigger donothingbrtrig2 before insert on donothingbrtrig_test2 for each row execute procedure donothingbrtrig_func();
---END---
---START---
alter table donothingbrtrig_test attach partition donothingbrtrig_test1 for values in (1);
---END---
---START---
alter table donothingbrtrig_test attach partition donothingbrtrig_test2 for values in (2);
---END---
---START---
insert into donothingbrtrig_test values (1, 'foo'), (2, 'bar');
---END---
---START---
copy donothingbrtrig_test from stdout;
---END---
---START---
1	baz
2	qux
\.
select tableoid::regclass, * from donothingbrtrig_test;
---END---
---START---
-- cleanup
drop table donothingbrtrig_test;
---END---
---START---
drop function donothingbrtrig_func();
---END---
---START---
CREATE TABLE mcrparted (gemini_pk serial PRIMARY KEY, a text, b integer) PARTITION BY range (a, b);
---END---
---START---
create table mcrparted1_lt_b partition of mcrparted for values from (minvalue, minvalue) to ('b', minvalue);
---END---
---START---
create table mcrparted2_b partition of mcrparted for values from ('b', minvalue) to ('c', minvalue);
---END---
---START---
create table mcrparted3_c_to_common partition of mcrparted for values from ('c', minvalue) to ('common', minvalue);
---END---
---START---
create table mcrparted4_common_lt_0 partition of mcrparted for values from ('common', minvalue) to ('common', 0);
---END---
---START---
create table mcrparted5_common_0_to_10 partition of mcrparted for values from ('common', 0) to ('common', 10);
---END---
---START---
create table mcrparted6_common_ge_10 partition of mcrparted for values from ('common', 10) to ('common', maxvalue);
---END---
---START---
create table mcrparted7_gt_common_lt_d partition of mcrparted for values from ('common', maxvalue) to ('d', minvalue);
---END---
---START---
create table mcrparted8_ge_d partition of mcrparted for values from ('d', minvalue) to (maxvalue, maxvalue);
---END---
---START---
\d+ mcrparted
\d+ mcrparted1_lt_b
\d+ mcrparted2_b
\d+ mcrparted3_c_to_common
\d+ mcrparted4_common_lt_0
\d+ mcrparted5_common_0_to_10
\d+ mcrparted6_common_ge_10
\d+ mcrparted7_gt_common_lt_d
\d+ mcrparted8_ge_d

insert into mcrparted values ('aaa', 0), ('b', 0), ('bz', 10), ('c', -10),
    ('comm', -10), ('common', -10), ('common', 0), ('common', 10),
    ('commons', 0), ('d', -10), ('e', 0);
---END---
---START---
select tableoid::regclass, * from mcrparted order by a, b;
---END---
---START---
drop table mcrparted;
---END---
---START---
CREATE TABLE returningwrtest (gemini_pk serial PRIMARY KEY, a integer) PARTITION BY list (a);
---END---
---START---
create table returningwrtest1 partition of returningwrtest for values in (1);
---END---
---START---
insert into returningwrtest values (1) returning returningwrtest;
---END---
---START---
-- check also that the wholerow vars in RETURNING list are converted as needed
alter table returningwrtest add b text;
---END---
---START---
CREATE TABLE returningwrtest2 (gemini_pk serial PRIMARY KEY, b text, c integer, a integer);
---END---
---START---
alter table returningwrtest2 drop c;
---END---
---START---
alter table returningwrtest attach partition returningwrtest2 for values in (2);
---END---
---START---
insert into returningwrtest values (2, 'foo') returning returningwrtest;
---END---
---START---
drop table returningwrtest;
---END---
