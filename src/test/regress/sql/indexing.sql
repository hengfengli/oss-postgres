---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY range (a);
---END---
---START---
-- relhassubclass of a partitioned index is false before creating any partition.
-- It will be set after the first partition is created.
create index idxpart_idx on idxpart (a);
---END---
---START---
select relhassubclass from pg_class where relname = 'idxpart_idx';
---END---
---START---
-- Check that partitioned indexes are present in pg_indexes.
select indexdef from pg_indexes where indexname like 'idxpart_idx%';
---END---
---START---
drop index idxpart_idx;
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (10);
---END---
---START---
create table idxpart2 partition of idxpart for values from (10) to (100)
	partition by range (b);
---END---
---START---
create table idxpart21 partition of idxpart2 for values from (0) to (100);
---END---
---START---
-- Even with partitions, relhassubclass should not be set if a partitioned
-- index is created only on the parent.
create index idxpart_idx on only idxpart(a);
---END---
---START---
select relhassubclass from pg_class where relname = 'idxpart_idx';
---END---
---START---
drop index idxpart_idx;
---END---
---START---
create index on idxpart (a);
---END---
---START---
select relname, relkind, relhassubclass, inhparent::regclass
    from pg_class left join pg_index ix on (indexrelid = oid)
	left join pg_inherits on (ix.indexrelid = inhrelid)
	where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY range (a);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (10);
---END---
---START---
create index concurrently on idxpart (a);
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, col1 integer) PARTITION BY range (col1);
---END---
---START---
CREATE INDEX ON idxpart (col1);
---END---
---START---
CREATE TABLE idxpart_two (_gemini_pk serial PRIMARY KEY, col2 integer);
---END---
---START---
SELECT col2 FROM idxpart_two fk LEFT OUTER JOIN idxpart pk ON (col1 = col2);
---END---
---START---
DROP table idxpart, idxpart_two;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b text, c integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 PARTITION OF idxpart FOR VALUES FROM (MINVALUE) TO (MAXVALUE);
---END---
---START---
CREATE INDEX partidx_abc_idx ON idxpart (a, b, c);
---END---
---START---
INSERT INTO idxpart (a, b, c) SELECT i, i, i FROM generate_series(1, 50) i;
---END---
---START---
ALTER TABLE idxpart ALTER COLUMN c TYPE numeric;
---END---
---START---
DROP TABLE idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY range (a);
---END---
---START---
create index idxparti on idxpart (a);
---END---
---START---
create index idxparti2 on idxpart (b, c);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
\d idxpart1
alter table idxpart attach partition idxpart1 for values from (0) to (10);
---END---
---START---
\d idxpart1
\d+ idxpart1_a_idx
\d+ idxpart1_b_c_idx

-- Forbid ALTER TABLE when attaching or detaching an index to a partition.
create index idxpart_c on only idxpart (c);
---END---
---START---
create index idxpart1_c on idxpart1 (c);
---END---
---START---
alter table idxpart_c attach partition idxpart1_c for values from (10) to (20);
---END---
---START---
alter index idxpart_c attach partition idxpart1_c;
---END---
---START---
select relname, relpartbound from pg_class
  where relname in ('idxpart_c', 'idxpart1_c')
  order by relname;
---END---
---START---
alter table idxpart_c detach partition idxpart1_c;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a, b);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0, 0) to (10, 10);
---END---
---START---
create index on idxpart1 (a, b);
---END---
---START---
create index on idxpart (a, b);
---END---
---START---
\d idxpart1
select relname, relkind, relhassubclass, inhparent::regclass
    from pg_class left join pg_index ix on (indexrelid = oid)
	left join pg_inherits on (ix.indexrelid = inhrelid)
	where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create index on idxpart (a);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (10);
---END---
---START---
drop index idxpart1_a_idx;
---END---
---START---
-- no way
drop index concurrently idxpart_a_idx;
---END---
---START---
-- unsupported
drop index idxpart_a_idx;
---END---
---START---
-- both indexes go away
select relname, relkind from pg_class
  where relname like 'idxpart%' order by relname;
---END---
---START---
create index on idxpart (a);
---END---
---START---
drop table idxpart1;
---END---
---START---
-- the index on partition goes away too
select relname, relkind from pg_class
  where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
-- DROP behavior with temporary partitioned indexes
DROP TABLE IF EXISTS idxpart_temp;

CREATE TABLE idxpart_temp (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create index on idxpart_temp(a);
---END---
---START---
DROP TABLE IF EXISTS idxpart1_temp;

create table idxpart1_temp partition of idxpart_temp
  for values from (0) to (10);
---END---
---START---
drop index idxpart1_temp_a_idx;
---END---
---START---
-- error
-- non-concurrent drop is enforced here, so it is a valid case.
drop index concurrently idxpart_temp_a_idx;
---END---
---START---
select relname, relkind from pg_class
  where relname like 'idxpart_temp%' order by relname;
---END---
---START---
drop table idxpart_temp;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a, b);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0, 0) to (10, 10);
---END---
---START---
create index idxpart_a_b_idx on only idxpart (a, b);
---END---
---START---
create index idxpart1_a_b_idx on idxpart1 (a, b);
---END---
---START---
create index idxpart1_tst1 on idxpart1 (b, a);
---END---
---START---
create index idxpart1_tst2 on idxpart1 using hash (a);
---END---
---START---
create index idxpart1_tst3 on idxpart1 (a, b) where a > 10;
---END---
---START---
alter index idxpart attach partition idxpart1;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart_a_b_idx;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1_b_idx;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1_tst1;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1_tst2;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1_tst3;
---END---
---START---
-- OK
alter index idxpart_a_b_idx attach partition idxpart1_a_b_idx;
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1_a_b_idx;
---END---
---START---
-- quiet

-- reject dupe
create index idxpart1_2_a_b on idxpart1 (a, b);
---END---
---START---
alter index idxpart_a_b_idx attach partition idxpart1_2_a_b;
---END---
---START---
drop table idxpart;
---END---
---START---
-- make sure everything's gone
select indexrelid::regclass, indrelid::regclass
  from pg_index where indexrelid::regclass::text like 'idxpart%';
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
create index on idxpart1 using hash (a);
---END---
---START---
create index on idxpart1 (a) where b > 1;
---END---
---START---
create index on idxpart1 ((a + 0));
---END---
---START---
create index on idxpart1 (a, a);
---END---
---START---
create index on idxpart (a);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (1000);
---END---
---START---
\d idxpart1
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (100);
---END---
---START---
create table idxpart2 partition of idxpart for values from (100) to (1000)
  partition by range (a);
---END---
---START---
create table idxpart21 partition of idxpart2 for values from (100) to (200);
---END---
---START---
create table idxpart22 partition of idxpart2 for values from (200) to (300);
---END---
---START---
create index on idxpart22 (a);
---END---
---START---
create index on only idxpart2 (a);
---END---
---START---
create index on idxpart (a);
---END---
---START---
-- Here we expect that idxpart1 and idxpart2 have a new index, but idxpart21
-- does not; also, idxpart22 is not attached.
\d idxpart1
\d idxpart2
\d idxpart21
select indexrelid::regclass, indrelid::regclass, inhparent::regclass
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
where indexrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
alter index idxpart2_a_idx attach partition idxpart22_a_idx;
---END---
---START---
select indexrelid::regclass, indrelid::regclass, inhparent::regclass
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
where indexrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
-- attaching idxpart22 is not enough to set idxpart22_a_idx valid ...
alter index idxpart2_a_idx attach partition idxpart22_a_idx;
---END---
---START---
\d idxpart2
-- ... but this one is.
create index on idxpart21 (a);
---END---
---START---
alter index idxpart2_a_idx attach partition idxpart21_a_idx;
---END---
---START---
\d idxpart2
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text, d bool) PARTITION BY range (a);
---END---
---START---
create index idxparti on idxpart (a);
---END---
---START---
create index idxparti2 on idxpart (b, c);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart INCLUDING INDEXES);
---END---
---START---
\d idxpart1
select relname, relkind, inhparent::regclass
    from pg_class left join pg_index ix on (indexrelid = oid)
	left join pg_inherits on (ix.indexrelid = inhrelid)
	where relname like 'idxpart%' order by relname;
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (10);
---END---
---START---
\d idxpart1
select relname, relkind, inhparent::regclass
    from pg_class left join pg_index ix on (indexrelid = oid)
	left join pg_inherits on (ix.indexrelid = inhrelid)
	where relname like 'idxpart%' order by relname;
---END---
---START---
-- While here, also check matching when creating an index after the fact.
create index on idxpart1 ((a+b)) where d = true;
---END---
---START---
\d idxpart1
select relname, relkind, inhparent::regclass
    from pg_class left join pg_index ix on (indexrelid = oid)
	left join pg_inherits on (ix.indexrelid = inhrelid)
	where relname like 'idxpart%' order by relname;
---END---
---START---
create index idxparti3 on idxpart ((a+b)) where d = true;
---END---
---START---
\d idxpart1
select relname, relkind, inhparent::regclass
    from pg_class left join pg_index ix on (indexrelid = oid)
	left join pg_inherits on (ix.indexrelid = inhrelid)
	where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
create table idxpart1 partition of idxpart for values from (1) to (1000) partition by range (a);
---END---
---START---
create table idxpart11 partition of idxpart1 for values from (1) to (100);
---END---
---START---
create index on only idxpart1 (a);
---END---
---START---
create index on only idxpart (a);
---END---
---START---
-- this results in two invalid indexes:
select relname, indisvalid from pg_class join pg_index on indexrelid = oid
   where relname like 'idxpart%' order by relname;
---END---
---START---
-- idxpart1_a_idx is not valid, so idxpart_a_idx should not become valid:
alter index idxpart_a_idx attach partition idxpart1_a_idx;
---END---
---START---
select relname, indisvalid from pg_class join pg_index on indexrelid = oid
   where relname like 'idxpart%' order by relname;
---END---
---START---
-- after creating and attaching this, both idxpart1_a_idx and idxpart_a_idx
-- should become valid
create index on idxpart11 (a);
---END---
---START---
alter index idxpart1_a_idx attach partition idxpart11_a_idx;
---END---
---START---
select relname, indisvalid from pg_class join pg_index on indexrelid = oid
   where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
create index on idxpart1 (a);
---END---
---START---
create index on idxpart (a);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0000) to (1000);
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (1000) to (2000);
---END---
---START---
create table idxpart3 partition of idxpart for values from (2000) to (3000);
---END---
---START---
select relname, relkind from pg_class where relname like 'idxpart%' order by relname;
---END---
---START---
-- a) after detaching partitions, the indexes can be dropped independently
alter table idxpart detach partition idxpart1;
---END---
---START---
alter table idxpart detach partition idxpart2;
---END---
---START---
alter table idxpart detach partition idxpart3;
---END---
---START---
drop index idxpart1_a_idx;
---END---
---START---
drop index idxpart2_a_idx;
---END---
---START---
drop index idxpart3_a_idx;
---END---
---START---
select relname, relkind from pg_class where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart, idxpart1, idxpart2, idxpart3;
---END---
---START---
select relname, relkind from pg_class where relname like 'idxpart%' order by relname;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
create index on idxpart1 (a);
---END---
---START---
create index on idxpart (a);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0000) to (1000);
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (1000) to (2000);
---END---
---START---
create table idxpart3 partition of idxpart for values from (2000) to (3000);
---END---
---START---
-- b) after detaching, dropping the index on parent does not remove the others
select relname, relkind from pg_class where relname like 'idxpart%' order by relname;
---END---
---START---
alter table idxpart detach partition idxpart1;
---END---
---START---
alter table idxpart detach partition idxpart2;
---END---
---START---
alter table idxpart detach partition idxpart3;
---END---
---START---
drop index idxpart_a_idx;
---END---
---START---
select relname, relkind from pg_class where relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart, idxpart1, idxpart2, idxpart3;
---END---
---START---
select relname, relkind from pg_class where relname like 'idxpart%' order by relname;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (a);
---END---
---START---
create index on idxpart(c);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (250);
---END---
---START---
create table idxpart2 partition of idxpart for values from (250) to (500);
---END---
---START---
alter table idxpart detach partition idxpart2;
---END---
---START---
\d idxpart2
alter table idxpart2 drop column c;
---END---
---START---
\d idxpart2
drop table idxpart, idxpart2;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
create index on idxpart1 ((a + b));
---END---
---START---
create index on idxpart ((a + b));
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0000) to (1000);
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (1000) to (2000);
---END---
---START---
create table idxpart3 partition of idxpart for values from (2000) to (3000);
---END---
---START---
select relname as child, inhparent::regclass as parent, pg_get_indexdef as childdef
  from pg_class join pg_inherits on inhrelid = oid,
  lateral pg_get_indexdef(pg_class.oid)
  where relkind in ('i', 'I') and relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a text) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
create index on idxpart2 (a collate "POSIX");
---END---
---START---
create index on idxpart2 (a);
---END---
---START---
create index on idxpart2 (a collate "C");
---END---
---START---
alter table idxpart attach partition idxpart1 for values from ('aaa') to ('bbb');
---END---
---START---
alter table idxpart attach partition idxpart2 for values from ('bbb') to ('ccc');
---END---
---START---
create table idxpart3 partition of idxpart for values from ('ccc') to ('ddd');
---END---
---START---
create index on idxpart (a collate "C");
---END---
---START---
create table idxpart4 partition of idxpart for values from ('ddd') to ('eee');
---END---
---START---
select relname as child, inhparent::regclass as parent, pg_get_indexdef as childdef
  from pg_class left join pg_inherits on inhrelid = oid,
  lateral pg_get_indexdef(pg_class.oid)
  where relkind in ('i', 'I') and relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a text) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
create index on idxpart2 (a);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from ('aaa') to ('bbb');
---END---
---START---
alter table idxpart attach partition idxpart2 for values from ('bbb') to ('ccc');
---END---
---START---
create table idxpart3 partition of idxpart for values from ('ccc') to ('ddd');
---END---
---START---
create index on idxpart (a text_pattern_ops);
---END---
---START---
create table idxpart4 partition of idxpart for values from ('ddd') to ('eee');
---END---
---START---
-- must *not* have attached the index we created on idxpart2
select relname as child, inhparent::regclass as parent, pg_get_indexdef as childdef
  from pg_class left join pg_inherits on inhrelid = oid,
  lateral pg_get_indexdef(pg_class.oid)
  where relkind in ('i', 'I') and relname like 'idxpart%' order by relname;
---END---
---START---
drop index idxpart_a_idx;
---END---
---START---
create index on only idxpart (a text_pattern_ops);
---END---
---START---
-- must reject
alter index idxpart_a_idx attach partition idxpart2_a_idx;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, col1 integer, a integer, col2 integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, b integer, col1 integer, col2 integer, col3 integer, a integer);
---END---
---START---
alter table idxpart drop column col1, drop column col2;
---END---
---START---
alter table idxpart1 drop column col1, drop column col2, drop column col3;
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (1000);
---END---
---START---
create index idxpart_1_idx on only idxpart (b, a);
---END---
---START---
create index idxpart1_1_idx on idxpart1 (b, a);
---END---
---START---
create index idxpart1_1b_idx on idxpart1 (b);
---END---
---START---
-- test expressions and partial-index predicate, too
create index idxpart_2_idx on only idxpart ((b + a)) where a > 1;
---END---
---START---
create index idxpart1_2_idx on idxpart1 ((b + a)) where a > 1;
---END---
---START---
create index idxpart1_2b_idx on idxpart1 ((a + b)) where a > 1;
---END---
---START---
create index idxpart1_2c_idx on idxpart1 ((b + a)) where b > 1;
---END---
---START---
alter index idxpart_1_idx attach partition idxpart1_1b_idx;
---END---
---START---
-- fail
alter index idxpart_1_idx attach partition idxpart1_1_idx;
---END---
---START---
alter index idxpart_2_idx attach partition idxpart1_2b_idx;
---END---
---START---
-- fail
alter index idxpart_2_idx attach partition idxpart1_2c_idx;
---END---
---START---
-- fail
alter index idxpart_2_idx attach partition idxpart1_2_idx;
---END---
---START---
-- ok
select relname as child, inhparent::regclass as parent, pg_get_indexdef as childdef
  from pg_class left join pg_inherits on inhrelid = oid,
  lateral pg_get_indexdef(pg_class.oid)
  where relkind in ('i', 'I') and relname like 'idxpart%' order by relname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY range (a);
---END---
---START---
create index idxparti on idxpart (a);
---END---
---START---
create index idxparti2 on idxpart (c, b);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, c text, a integer, b integer);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (10);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, c text, a integer, b integer);
---END---
---START---
create index on idxpart2 (a);
---END---
---START---
create index on idxpart2 (c, b);
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (10) to (20);
---END---
---START---
select c.relname, pg_get_indexdef(indexrelid)
  from pg_class c join pg_index i on c.oid = i.indexrelid
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, col1 integer, col2 integer, a integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, col2 integer, b integer, col1 integer, a integer);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, col1 integer, col2 integer, b integer, a integer);
---END---
---START---
alter table idxpart drop column col1, drop column col2;
---END---
---START---
alter table idxpart1 drop column col1, drop column col2;
---END---
---START---
alter table idxpart2 drop column col1, drop column col2;
---END---
---START---
create index on idxpart2 (abs(b));
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (0) to (1);
---END---
---START---
create index on idxpart (abs(b));
---END---
---START---
create index on idxpart ((b + 1));
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (1) to (2);
---END---
---START---
select c.relname, pg_get_indexdef(indexrelid)
  from pg_class c join pg_index i on c.oid = i.indexrelid
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, col1 integer, a integer, col3 integer, b integer) PARTITION BY range (a);
---END---
---START---
alter table idxpart drop column col1, drop column col3;
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, col1 integer, col2 integer, col3 integer, col4 integer, b integer, a integer);
---END---
---START---
alter table idxpart1 drop column col1, drop column col2, drop column col3, drop column col4;
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (1000);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, col1 integer, col2 integer, b integer, a integer);
---END---
---START---
create index on idxpart2 (a) where b > 1000;
---END---
---START---
alter table idxpart2 drop column col1, drop column col2;
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (1000) to (2000);
---END---
---START---
create index on idxpart (a) where b > 1000;
---END---
---START---
select c.relname, pg_get_indexdef(indexrelid)
  from pg_class c join pg_index i on c.oid = i.indexrelid
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, drop_1 integer, drop_2 integer, col_keep integer, drop_3 integer);
---END---
---START---
alter table idxpart1 drop column drop_1;
---END---
---START---
alter table idxpart1 drop column drop_2;
---END---
---START---
alter table idxpart1 drop column drop_3;
---END---
---START---
create index on idxpart1 (col_keep);
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, col_keep integer) PARTITION BY range (col_keep);
---END---
---START---
create index on idxpart (col_keep);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (1000);
---END---
---START---
\d idxpart
\d idxpart1
select attrelid::regclass, attname, attnum from pg_attribute
  where attrelid::regclass::text like 'idxpart%' and attnum > 0
  order by attrelid::regclass, attnum;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, drop_1 integer, drop_2 integer, col_keep integer, drop_3 integer) PARTITION BY range (col_keep);
---END---
---START---
alter table idxpart drop column drop_1;
---END---
---START---
alter table idxpart drop column drop_2;
---END---
---START---
alter table idxpart drop column drop_3;
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, col_keep integer);
---END---
---START---
create index on idxpart1 (col_keep);
---END---
---START---
create index on idxpart (col_keep);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (1000);
---END---
---START---
\d idxpart
\d idxpart1
select attrelid::regclass, attname, attnum from pg_attribute
  where attrelid::regclass::text like 'idxpart%' and attnum > 0
  order by attrelid::regclass, attnum;
---END---
---START---
drop table idxpart;
---END---
---START---
--
-- Constraint-related indexes
--

-- Verify that it works to add primary key / unique to partitioned tables
create table idxpart (a int primary key, b int) partition by range (a);
---END---
---START---
\d idxpart
-- multiple primary key on child should fail
create table failpart partition of idxpart (b primary key) for values from (0) to (100);
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create table idxpart1pk partition of idxpart (a primary key) for values from (0) to (100);
---END---
---START---
\d idxpart1pk
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer UNIQUE, b integer) PARTITION BY range (a, b);
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer UNIQUE) PARTITION BY range (a, b);
---END---
---START---
create table idxpart (a int primary key, b int) partition by range (b, a);
---END---
---START---
create table idxpart (a int, b int primary key) partition by range (b, a);
---END---
---START---
-- OK if you use them in some other order
create table idxpart (a int, b int, c text, primary key  (a, b, c)) partition by range (b, c, a);
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, EXCLUDE USING btree (a WITH OPERATOR(=))) PARTITION BY range (a);
---END---
---START---
-- no expressions in partition key for PK/UNIQUE
create table idxpart (a int primary key, b int) partition by range ((b + a));
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer UNIQUE, b integer) PARTITION BY range ((b + a));
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY range (a, b);
---END---
---START---
alter table idxpart add primary key (a);
---END---
---START---
-- not an incomplete one though
alter table idxpart add primary key (a, b);
---END---
---START---
-- this works
\d idxpart
create table idxpart1 partition of idxpart for values from (0, 0) to (1000, 1000);
---END---
---START---
\d idxpart1
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a, b);
---END---
---START---
alter table idxpart add unique (a);
---END---
---START---
-- not an incomplete one though
alter table idxpart add unique (b, a);
---END---
---START---
-- this works
\d idxpart
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
alter table idxpart add exclude (a with =);
---END---
---START---
drop table idxpart;
---END---
---START---
-- When (sub)partitions are created, they also contain the constraint
create table idxpart (a int, b int, primary key (a, b)) partition by range (a, b);
---END---
---START---
create table idxpart1 partition of idxpart for values from (1, 1) to (10, 10);
---END---
---START---
create table idxpart2 partition of idxpart for values from (10, 10) to (20, 20)
  partition by range (b);
---END---
---START---
create table idxpart21 partition of idxpart2 for values from (10) to (15);
---END---
---START---
create table idxpart22 partition of idxpart2 for values from (15) to (20);
---END---
---START---
CREATE TABLE idxpart3 (_gemini_pk serial PRIMARY KEY, b integer NOT NULL, a integer NOT NULL);
---END---
---START---
alter table idxpart attach partition idxpart3 for values from (20, 20) to (30, 30);
---END---
---START---
select conname, contype, conrelid::regclass, conindid::regclass, conkey
  from pg_constraint where conrelid::regclass::text like 'idxpart%'
  order by conname;
---END---
---START---
drop table idxpart;
---END---
---START---
-- Verify that multi-layer partitioning honors the requirement that all
-- columns in the partition key must appear in primary/unique key
create table idxpart (a int, b int, primary key (a)) partition by range (a);
---END---
---START---
create table idxpart2 partition of idxpart
for values from (0) to (1000) partition by range (b);
---END---
---START---
-- fail
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer UNIQUE, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, a integer NOT NULL, b integer, UNIQUE (a, b)) PARTITION BY range (a, b);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (1) to (1000);
---END---
---START---
DROP TABLE idxpart, idxpart1;
---END---
---START---
-- Multi-layer partitioning works correctly in this case:
create table idxpart (a int, b int, primary key (a, b)) partition by range (a);
---END---
---START---
create table idxpart2 partition of idxpart for values from (0) to (1000) partition by range (b);
---END---
---START---
create table idxpart21 partition of idxpart2 for values from (0) to (1000);
---END---
---START---
select conname, contype, conrelid::regclass, conindid::regclass, conkey
  from pg_constraint where conrelid::regclass::text like 'idxpart%'
  order by conname;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, i integer) PARTITION BY hash (i);
---END---
---START---
create table idxpart0 partition of idxpart (i) for values with (modulus 2, remainder 0);
---END---
---START---
create table idxpart1 partition of idxpart (i) for values with (modulus 2, remainder 1);
---END---
---START---
alter table idxpart0 add primary key(i);
---END---
---START---
alter table idxpart add primary key(i);
---END---
---START---
select indrelid::regclass, indexrelid::regclass, inhparent::regclass, indisvalid,
  conname, conislocal, coninhcount, connoinherit, convalidated
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  left join pg_constraint con on (idx.indexrelid = con.conindid)
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop index idxpart0_pkey;
---END---
---START---
-- fail
drop index idxpart1_pkey;
---END---
---START---
-- fail
alter table idxpart0 drop constraint idxpart0_pkey;
---END---
---START---
-- fail
alter table idxpart1 drop constraint idxpart1_pkey;
---END---
---START---
-- fail
alter table idxpart drop constraint idxpart_pkey;
---END---
---START---
-- ok
select indrelid::regclass, indexrelid::regclass, inhparent::regclass, indisvalid,
  conname, conislocal, coninhcount, connoinherit, convalidated
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  left join pg_constraint con on (idx.indexrelid = con.conindid)
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table idxpart;
---END---
---START---
-- If the partition to be attached already has a primary key, fail if
-- it doesn't match the parent's PK.
CREATE TABLE idxpart (c1 INT PRIMARY KEY, c2 INT, c3 VARCHAR(10)) PARTITION BY RANGE(c1);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
ALTER TABLE idxpart1 ADD PRIMARY KEY (c1, c2);
---END---
---START---
ALTER TABLE idxpart ATTACH PARTITION idxpart1 FOR VALUES FROM (100) TO (200);
---END---
---START---
DROP TABLE idxpart, idxpart1;
---END---
---START---
-- Ditto if there is some distance between the PKs (subpartitioning)
create table idxpart (a int, b int, primary key (a)) partition by range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, a integer NOT NULL, b integer) PARTITION BY range (a);
---END---
---START---
create table idxpart11 (a int not null, b int primary key);
---END---
---START---
alter table idxpart1 attach partition idxpart11 for values from (0) to (1000);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (0) to (10000);
---END---
---START---
drop table idxpart, idxpart1, idxpart11;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart0 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
alter table idxpart0 add primary key (a);
---END---
---START---
alter table idxpart attach partition idxpart0 for values from (0) to (1000);
---END---
---START---
alter table only idxpart add primary key (a);
---END---
---START---
select indrelid::regclass, indexrelid::regclass, inhparent::regclass, indisvalid,
  conname, conislocal, coninhcount, connoinherit, convalidated
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  left join pg_constraint con on (idx.indexrelid = con.conindid)
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
alter index idxpart_pkey attach partition idxpart0_pkey;
---END---
---START---
select indrelid::regclass, indexrelid::regclass, inhparent::regclass, indisvalid,
  conname, conislocal, coninhcount, connoinherit, convalidated
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  left join pg_constraint con on (idx.indexrelid = con.conindid)
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart0 (_gemini_pk serial PRIMARY KEY, LIKE idxpart);
---END---
---START---
alter table idxpart0 add unique (a);
---END---
---START---
alter table idxpart attach partition idxpart0 default;
---END---
---START---
alter table only idxpart add primary key (a);
---END---
---START---
-- fail, no NOT NULL constraint
alter table idxpart0 alter column a set not null;
---END---
---START---
alter table only idxpart add primary key (a);
---END---
---START---
-- now it works
alter table idxpart0 alter column a drop not null;
---END---
---START---
-- fail, pkey needs it
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, a integer NOT NULL, b integer);
---END---
---START---
create unique index on idxpart1 (a);
---END---
---START---
alter table idxpart add primary key (a);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (1) to (1000);
---END---
---START---
select indrelid::regclass, indexrelid::regclass, inhparent::regclass, indisvalid,
  conname, conislocal, coninhcount, connoinherit, convalidated
  from pg_index idx left join pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  left join pg_constraint con on (idx.indexrelid = con.conindid)
  where indrelid::regclass::text like 'idxpart%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
CREATE TABLE idxpart1 (_gemini_pk serial PRIMARY KEY, a integer NOT NULL, b integer);
---END---
---START---
create unique index on idxpart1 (a);
---END---
---START---
alter table idxpart attach partition idxpart1 for values from (1) to (1000);
---END---
---START---
alter table only idxpart add primary key (a);
---END---
---START---
alter index idxpart_pkey attach partition idxpart1_a_idx;
---END---
---START---
-- fail
drop table idxpart;
---END---
---START---
-- Test that unique constraints are working
create table idxpart (a int, b text, primary key (a, b)) partition by range (a);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (100000);
---END---
---START---
CREATE TABLE idxpart2 (_gemini_pk serial PRIMARY KEY, c integer, LIKE idxpart);
---END---
---START---
insert into idxpart2 (c, a, b) values (42, 572814, 'inserted first');
---END---
---START---
alter table idxpart2 drop column c;
---END---
---START---
create unique index on idxpart (a);
---END---
---START---
alter table idxpart attach partition idxpart2 for values from (100000) to (1000000);
---END---
---START---
insert into idxpart values (0, 'zero'), (42, 'life'), (2^16, 'sixteen');
---END---
---START---
insert into idxpart select 2^g, format('two to power of %s', g) from generate_series(15, 17) g;
---END---
---START---
insert into idxpart values (16, 'sixteen');
---END---
---START---
insert into idxpart (b, a) values ('one', 142857), ('two', 285714);
---END---
---START---
insert into idxpart select a * 2, b || b from idxpart where a between 2^16 and 2^19;
---END---
---START---
insert into idxpart values (572814, 'five');
---END---
---START---
insert into idxpart values (857142, 'six');
---END---
---START---
select tableoid::regclass, * from idxpart order by a;
---END---
---START---
drop table idxpart;
---END---
---START---
CREATE TABLE idxpart (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create table idxpart1 partition of idxpart for values from (0) to (100);
---END---
---START---
create table idxpart2 partition of idxpart for values from (100) to (1000)
  partition by range (a);
---END---
---START---
create table idxpart21 partition of idxpart2 for values from (100) to (200);
---END---
---START---
create table idxpart22 partition of idxpart2 for values from (200) to (300);
---END---
---START---
create index on idxpart22 (a);
---END---
---START---
create index on only idxpart2 (a);
---END---
---START---
alter index idxpart2_a_idx attach partition idxpart22_a_idx;
---END---
---START---
create index on idxpart (a);
---END---
---START---
create table idxpart_another (a int, b int, primary key (a, b)) partition by range (a);
---END---
---START---
create table idxpart_another_1 partition of idxpart_another for values from (0) to (100);
---END---
---START---
CREATE TABLE idxpart3 (_gemini_pk serial PRIMARY KEY, c integer, b integer, a integer) PARTITION BY range (a);
---END---
---START---
alter table idxpart3 drop column b, drop column c;
---END---
---START---
create table idxpart31 partition of idxpart3 for values from (1000) to (1200);
---END---
---START---
create table idxpart32 partition of idxpart3 for values from (1200) to (1400);
---END---
---START---
alter table idxpart attach partition idxpart3 for values from (1000) to (2000);
---END---
---START---
-- More objects intentionally left behind, to verify some pg_dump/pg_upgrade
-- behavior; see https://postgr.es/m/20190321204928.GA17535@alvherre.pgsql
create schema regress_indexing;
---END---
---START---
set search_path to regress_indexing;
---END---
---START---
create table pk (a int primary key) partition by range (a);
---END---
---START---
create table pk1 partition of pk for values from (0) to (1000);
---END---
---START---
CREATE TABLE pk2 (_gemini_pk serial PRIMARY KEY, b integer, a integer);
---END---
---START---
alter table pk2 drop column b;
---END---
---START---
alter table pk2 alter a set not null;
---END---
---START---
alter table pk attach partition pk2 for values from (1000) to (2000);
---END---
---START---
create table pk3 partition of pk for values from (2000) to (3000);
---END---
---START---
CREATE TABLE pk4 (_gemini_pk serial PRIMARY KEY, LIKE pk);
---END---
---START---
alter table pk attach partition pk4 for values from (3000) to (4000);
---END---
---START---
CREATE TABLE pk5 (_gemini_pk serial PRIMARY KEY, LIKE pk) PARTITION BY range (a);
---END---
---START---
create table pk51 partition of pk5 for values from (4000) to (4500);
---END---
---START---
create table pk52 partition of pk5 for values from (4500) to (5000);
---END---
---START---
alter table pk attach partition pk5 for values from (4000) to (5000);
---END---
---START---
reset search_path;
---END---
---START---
CREATE TABLE covidxpart (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY list (a);
---END---
---START---
create unique index on covidxpart (a) include (b);
---END---
---START---
create table covidxpart1 partition of covidxpart for values in (1);
---END---
---START---
create table covidxpart2 partition of covidxpart for values in (2);
---END---
---START---
insert into covidxpart values (1, 1);
---END---
---START---
insert into covidxpart values (1, 1);
---END---
---START---
CREATE TABLE covidxpart3 (_gemini_pk serial PRIMARY KEY, b integer, c integer, a integer);
---END---
---START---
alter table covidxpart3 drop c;
---END---
---START---
alter table covidxpart attach partition covidxpart3 for values in (3);
---END---
---START---
insert into covidxpart values (3, 1);
---END---
---START---
insert into covidxpart values (3, 1);
---END---
---START---
CREATE TABLE covidxpart4 (_gemini_pk serial PRIMARY KEY, b integer, a integer);
---END---
---START---
create unique index on covidxpart4 (a) include (b);
---END---
---START---
create unique index on covidxpart4 (a);
---END---
---START---
alter table covidxpart attach partition covidxpart4 for values in (4);
---END---
---START---
insert into covidxpart values (4, 1);
---END---
---START---
insert into covidxpart values (4, 1);
---END---
---START---
create unique index on covidxpart (b) include (a);
---END---
---START---
-- should fail

-- check that detaching a partition also detaches the primary key constraint
create table parted_pk_detach_test (a int primary key) partition by list (a);
---END---
---START---
create table parted_pk_detach_test1 partition of parted_pk_detach_test for values in (1);
---END---
---START---
alter table parted_pk_detach_test1 drop constraint parted_pk_detach_test1_pkey;
---END---
---START---
-- should fail
alter table parted_pk_detach_test detach partition parted_pk_detach_test1;
---END---
---START---
alter table parted_pk_detach_test1 drop constraint parted_pk_detach_test1_pkey;
---END---
---START---
drop table parted_pk_detach_test, parted_pk_detach_test1;
---END---
---START---
CREATE TABLE parted_uniq_detach_test (_gemini_pk serial PRIMARY KEY, a integer UNIQUE) PARTITION BY list (a);
---END---
---START---
create table parted_uniq_detach_test1 partition of parted_uniq_detach_test for values in (1);
---END---
---START---
alter table parted_uniq_detach_test1 drop constraint parted_uniq_detach_test1_a_key;
---END---
---START---
-- should fail
alter table parted_uniq_detach_test detach partition parted_uniq_detach_test1;
---END---
---START---
alter table parted_uniq_detach_test1 drop constraint parted_uniq_detach_test1_a_key;
---END---
---START---
drop table parted_uniq_detach_test, parted_uniq_detach_test1;
---END---
---START---
CREATE TABLE parted_index_col_drop (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY list (a);
---END---
---START---
create table parted_index_col_drop1 partition of parted_index_col_drop
  for values in (1) partition by list (a);
---END---
---START---
-- leave this partition without children.
create table parted_index_col_drop2 partition of parted_index_col_drop
  for values in (2) partition by list (a);
---END---
---START---
create table parted_index_col_drop11 partition of parted_index_col_drop1
  for values in (1);
---END---
---START---
create index on parted_index_col_drop (b);
---END---
---START---
create index on parted_index_col_drop (c);
---END---
---START---
create index on parted_index_col_drop (b, c);
---END---
---START---
alter table parted_index_col_drop drop column c;
---END---
---START---
\d parted_index_col_drop
\d parted_index_col_drop1
\d parted_index_col_drop2
\d parted_index_col_drop11
drop table parted_index_col_drop;
---END---
---START---
CREATE TABLE parted_inval_tab (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create index parted_inval_idx on parted_inval_tab (a);
---END---
---START---
CREATE TABLE parted_inval_tab_1 (_gemini_pk serial PRIMARY KEY, a integer) PARTITION BY range (a);
---END---
---START---
create table parted_inval_tab_1_1 partition of parted_inval_tab_1
  for values from (0) to (10);
---END---
---START---
create table parted_inval_tab_1_2 partition of parted_inval_tab_1
  for values from (10) to (20);
---END---
---START---
-- this creates an invalid index.
create index parted_inval_ixd_1 on only parted_inval_tab_1 (a);
---END---
---START---
-- this creates new indexes for all the partitions of parted_inval_tab_1,
-- discarding the invalid index created previously as what is chosen.
alter table parted_inval_tab attach partition parted_inval_tab_1
  for values from (1) to (100);
---END---
---START---
select indexrelid::regclass, indisvalid,
       indrelid::regclass, inhparent::regclass
  from pg_index idx left join
       pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  where indexrelid::regclass::text like 'parted_inval%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table parted_inval_tab;
---END---
---START---
CREATE TABLE parted_isvalid_tab (_gemini_pk serial PRIMARY KEY, a integer, b integer) PARTITION BY range (a);
---END---
---START---
create table parted_isvalid_tab_1 partition of parted_isvalid_tab
  for values from (1) to (10) partition by range (a);
---END---
---START---
create table parted_isvalid_tab_2 partition of parted_isvalid_tab
  for values from (10) to (20) partition by range (a);
---END---
---START---
create table parted_isvalid_tab_11 partition of parted_isvalid_tab_1
  for values from (1) to (5);
---END---
---START---
create table parted_isvalid_tab_12 partition of parted_isvalid_tab_1
  for values from (5) to (10);
---END---
---START---
-- create an invalid index on one of the partitions.
insert into parted_isvalid_tab_11 values (1, 0);
---END---
---START---
create index concurrently parted_isvalid_idx_11 on parted_isvalid_tab_11 ((a/b));
---END---
---START---
-- The previous invalid index is selected, invalidating all the indexes up to
-- the top-most parent.
create index parted_isvalid_idx on parted_isvalid_tab ((a/b));
---END---
---START---
select indexrelid::regclass, indisvalid,
       indrelid::regclass, inhparent::regclass
  from pg_index idx left join
       pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  where indexrelid::regclass::text like 'parted_isvalid%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table parted_isvalid_tab;
---END---
---START---
-- Check state of replica indexes when attaching a partition.
begin;
---END---
---START---
CREATE TABLE parted_replica_tab (_gemini_pk serial PRIMARY KEY, id integer NOT NULL) PARTITION BY range (id);
---END---
---START---
create table parted_replica_tab_1 partition of parted_replica_tab
  for values from (1) to (10) partition by range (id);
---END---
---START---
create table parted_replica_tab_11 partition of parted_replica_tab_1
  for values from (1) to (5);
---END---
---START---
create unique index parted_replica_idx
  on only parted_replica_tab using btree (id);
---END---
---START---
create unique index parted_replica_idx_1
  on only parted_replica_tab_1 using btree (id);
---END---
---START---
-- This triggers an update of pg_index.indisreplident for parted_replica_idx.
alter table only parted_replica_tab_1 replica identity
  using index parted_replica_idx_1;
---END---
---START---
create unique index parted_replica_idx_11 on parted_replica_tab_11 USING btree (id);
---END---
---START---
select indexrelid::regclass, indisvalid, indisreplident,
       indrelid::regclass, inhparent::regclass
  from pg_index idx left join
       pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  where indexrelid::regclass::text like 'parted_replica%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
-- parted_replica_idx is not valid yet here, because parted_replica_idx_1
-- is not valid.
alter index parted_replica_idx ATTACH PARTITION parted_replica_idx_1;
---END---
---START---
select indexrelid::regclass, indisvalid, indisreplident,
       indrelid::regclass, inhparent::regclass
  from pg_index idx left join
       pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  where indexrelid::regclass::text like 'parted_replica%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
-- parted_replica_idx becomes valid here.
alter index parted_replica_idx_1 ATTACH PARTITION parted_replica_idx_11;
---END---
---START---
alter table only parted_replica_tab_1 replica identity
  using index parted_replica_idx_1;
---END---
---START---
commit;
---END---
---START---
select indexrelid::regclass, indisvalid, indisreplident,
       indrelid::regclass, inhparent::regclass
  from pg_index idx left join
       pg_inherits inh on (idx.indexrelid = inh.inhrelid)
  where indexrelid::regclass::text like 'parted_replica%'
  order by indexrelid::regclass::text collate "C";
---END---
---START---
drop table parted_replica_tab;
---END---
