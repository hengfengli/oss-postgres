---START---
--
-- Test inheritance features
--
CREATE TABLE a (aa TEXT);
---END---
---START---
CREATE TABLE b (bb TEXT) INHERITS (a);
---END---
---START---
CREATE TABLE c (cc TEXT) INHERITS (a);
---END---
---START---
CREATE TABLE d (dd TEXT) INHERITS (b,c,a);
---END---
---START---

INSERT INTO a(aa) VALUES('aaa');
---END---
---START---
INSERT INTO a(aa) VALUES('aaaa');
---END---
---START---
INSERT INTO a(aa) VALUES('aaaaa');
---END---
---START---
INSERT INTO a(aa) VALUES('aaaaaa');
---END---
---START---
INSERT INTO a(aa) VALUES('aaaaaaa');
---END---
---START---
INSERT INTO a(aa) VALUES('aaaaaaaa');
---END---
---START---

INSERT INTO b(aa) VALUES('bbb');
---END---
---START---
INSERT INTO b(aa) VALUES('bbbb');
---END---
---START---
INSERT INTO b(aa) VALUES('bbbbb');
---END---
---START---
INSERT INTO b(aa) VALUES('bbbbbb');
---END---
---START---
INSERT INTO b(aa) VALUES('bbbbbbb');
---END---
---START---
INSERT INTO b(aa) VALUES('bbbbbbbb');
---END---
---START---

INSERT INTO c(aa) VALUES('ccc');
---END---
---START---
INSERT INTO c(aa) VALUES('cccc');
---END---
---START---
INSERT INTO c(aa) VALUES('ccccc');
---END---
---START---
INSERT INTO c(aa) VALUES('cccccc');
---END---
---START---
INSERT INTO c(aa) VALUES('ccccccc');
---END---
---START---
INSERT INTO c(aa) VALUES('cccccccc');
---END---
---START---

INSERT INTO d(aa) VALUES('ddd');
---END---
---START---
INSERT INTO d(aa) VALUES('dddd');
---END---
---START---
INSERT INTO d(aa) VALUES('ddddd');
---END---
---START---
INSERT INTO d(aa) VALUES('dddddd');
---END---
---START---
INSERT INTO d(aa) VALUES('ddddddd');
---END---
---START---
INSERT INTO d(aa) VALUES('dddddddd');
---END---
---START---

SELECT relname, a.* FROM a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, a.* FROM ONLY a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM ONLY b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM ONLY c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM ONLY d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---

UPDATE a SET aa='zzzz' WHERE aa='aaaa';
---END---
---START---
UPDATE ONLY a SET aa='zzzzz' WHERE aa='aaaaa';
---END---
---START---
UPDATE b SET aa='zzz' WHERE aa='aaa';
---END---
---START---
UPDATE ONLY b SET aa='zzz' WHERE aa='aaa';
---END---
---START---
UPDATE a SET aa='zzzzzz' WHERE aa LIKE 'aaa%';
---END---
---START---

SELECT relname, a.* FROM a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, a.* FROM ONLY a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM ONLY b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM ONLY c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM ONLY d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---

UPDATE b SET aa='new';
---END---
---START---

SELECT relname, a.* FROM a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, a.* FROM ONLY a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM ONLY b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM ONLY c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM ONLY d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---

UPDATE a SET aa='new';
---END---
---START---

DELETE FROM ONLY c WHERE aa='new';
---END---
---START---

SELECT relname, a.* FROM a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, a.* FROM ONLY a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM ONLY b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM ONLY c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM ONLY d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---

DELETE FROM a;
---END---
---START---

SELECT relname, a.* FROM a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, a.* FROM ONLY a, pg_class where a.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, b.* FROM ONLY b, pg_class where b.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, c.* FROM ONLY c, pg_class where c.tableoid = pg_class.oid;
---END---
---START---
SELECT relname, d.* FROM ONLY d, pg_class where d.tableoid = pg_class.oid;
---END---
---START---

-- Confirm PRIMARY KEY adds NOT NULL constraint to child table
CREATE TABLE z (b TEXT, PRIMARY KEY(aa, b)) inherits (a);
---END---
---START---
INSERT INTO z VALUES (NULL, 'text'); -- should fail

-- Check inherited UPDATE with all children excluded
create table some_tab (a int, b int);
---END---
---START---
create table some_tab_child () inherits (some_tab);
---END---
---START---
insert into some_tab_child values(1,2);
---END---
---START---

explain (verbose, costs off)
update some_tab set a = a + 1 where false;
---END---
---START---
update some_tab set a = a + 1 where false;
---END---
---START---
explain (verbose, costs off)
update some_tab set a = a + 1 where false returning b, a;
---END---
---START---
update some_tab set a = a + 1 where false returning b, a;
---END---
---START---
table some_tab;
---END---
---START---

drop table some_tab cascade;
---END---
---START---

-- Check UPDATE with inherited target and an inherited source table
create table foo(f1 int, f2 int);
---END---
---START---
create table foo2(f3 int) inherits (foo);
---END---
---START---
create table bar(f1 int, f2 int);
---END---
---START---
create table bar2(f3 int) inherits (bar);
---END---
---START---

insert into foo values(1,1);
---END---
---START---
insert into foo values(3,3);
---END---
---START---
insert into foo2 values(2,2,2);
---END---
---START---
insert into foo2 values(3,3,3);
---END---
---START---
insert into bar values(1,1);
---END---
---START---
insert into bar values(2,2);
---END---
---START---
insert into bar values(3,3);
---END---
---START---
insert into bar values(4,4);
---END---
---START---
insert into bar2 values(1,1,1);
---END---
---START---
insert into bar2 values(2,2,2);
---END---
---START---
insert into bar2 values(3,3,3);
---END---
---START---
insert into bar2 values(4,4,4);
---END---
---START---

update bar set f2 = f2 + 100 where f1 in (select f1 from foo);
---END---
---START---

select tableoid::regclass::text as relname, bar.* from bar order by 1,2;
---END---
---START---

-- Check UPDATE with inherited target and an appendrel subquery
update bar set f2 = f2 + 100
from
  ( select f1 from foo union all select f1+3 from foo ) ss
where bar.f1 = ss.f1;
---END---
---START---

select tableoid::regclass::text as relname, bar.* from bar order by 1,2;
---END---
---START---

-- Check UPDATE with *partitioned* inherited target and an appendrel subquery
create table some_tab (a int);
---END---
---START---
insert into some_tab values (0);
---END---
---START---
create table some_tab_child () inherits (some_tab);
---END---
---START---
insert into some_tab_child values (1);
---END---
---START---
create table parted_tab (a int, b char) partition by list (a);
---END---
---START---
create table parted_tab_part1 partition of parted_tab for values in (1);
---END---
---START---
create table parted_tab_part2 partition of parted_tab for values in (2);
---END---
---START---
create table parted_tab_part3 partition of parted_tab for values in (3);
---END---
---START---
insert into parted_tab values (1, 'a'), (2, 'a'), (3, 'a');
---END---
---START---

update parted_tab set b = 'b'
from
  (select a from some_tab union all select a+1 from some_tab) ss (a)
where parted_tab.a = ss.a;
---END---
---START---
select tableoid::regclass::text as relname, parted_tab.* from parted_tab order by 1,2;
---END---
---START---

truncate parted_tab;
---END---
---START---
insert into parted_tab values (1, 'a'), (2, 'a'), (3, 'a');
---END---
---START---
update parted_tab set b = 'b'
from
  (select 0 from parted_tab union all select 1 from parted_tab) ss (a)
where parted_tab.a = ss.a;
---END---
---START---
select tableoid::regclass::text as relname, parted_tab.* from parted_tab order by 1,2;
---END---
---START---

-- modifies partition key, but no rows will actually be updated
explain update parted_tab set a = 2 where false;
---END---
---START---

drop table parted_tab;
---END---
---START---

-- Check UPDATE with multi-level partitioned inherited target
create table mlparted_tab (a int, b char, c text) partition by list (a);
---END---
---START---
create table mlparted_tab_part1 partition of mlparted_tab for values in (1);
---END---
---START---
create table mlparted_tab_part2 partition of mlparted_tab for values in (2) partition by list (b);
---END---
---START---
create table mlparted_tab_part3 partition of mlparted_tab for values in (3);
---END---
---START---
create table mlparted_tab_part2a partition of mlparted_tab_part2 for values in ('a');
---END---
---START---
create table mlparted_tab_part2b partition of mlparted_tab_part2 for values in ('b');
---END---
---START---
insert into mlparted_tab values (1, 'a'), (2, 'a'), (2, 'b'), (3, 'a');
---END---
---START---

update mlparted_tab mlp set c = 'xxx'
from
  (select a from some_tab union all select a+1 from some_tab) ss (a)
where (mlp.a = ss.a and mlp.b = 'b') or mlp.a = 3;
---END---
---START---
select tableoid::regclass::text as relname, mlparted_tab.* from mlparted_tab order by 1,2;
---END---
---START---

drop table mlparted_tab;
---END---
---START---
drop table some_tab cascade;
---END---
---START---

/* Test multiple inheritance of column defaults */

CREATE TABLE firstparent (tomorrow date default now()::date + 1);
---END---
---START---
CREATE TABLE secondparent (tomorrow date default  now() :: date  +  1);
---END---
---START---
CREATE TABLE jointchild () INHERITS (firstparent, secondparent);  -- ok
CREATE TABLE thirdparent (tomorrow date default now()::date - 1);
---END---
---START---
CREATE TABLE otherchild () INHERITS (firstparent, thirdparent);  -- not ok
CREATE TABLE otherchild (tomorrow date default now())
  INHERITS (firstparent, thirdparent);  -- ok, child resolves ambiguous default

DROP TABLE firstparent, secondparent, jointchild, thirdparent, otherchild;
---END---
---START---

-- Test changing the type of inherited columns
insert into d values('test','one','two','three');
---END---
---START---
alter table a alter column aa type integer using bit_length(aa);
---END---
---START---
select * from d;
---END---
---START---

-- The above verified that we can change the type of a multiply-inherited
-- column; but we should reject that if any definition was inherited from
-- an unrelated parent.
create table parent1(f1 int, f2 int);
---END---
---START---
create table parent2(f1 int, f3 bigint);
---END---
---START---
create table childtab(f4 int) inherits(parent1, parent2);
---END---
---START---
alter table parent1 alter column f1 type bigint;  -- fail, conflict w/parent2
alter table parent1 alter column f2 type bigint;  -- ok

-- Test non-inheritable parent constraints
create table p1(ff1 int);
---END---
---START---
alter table p1 add constraint p1chk check (ff1 > 0) no inherit;
---END---
---START---
alter table p1 add constraint p2chk check (ff1 > 10);
---END---
---START---
-- connoinherit should be true for NO INHERIT constraint
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pgc.connoinherit from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname = 'p1' order by 1,2;
---END---
---START---

-- Test that child does not inherit NO INHERIT constraints
create table c1 () inherits (p1);
---END---
---START---
\d p1
\d c1

-- Test that child does not override inheritable constraints of the parent
create table c2 (constraint p2chk check (ff1 > 10) no inherit) inherits (p1);	--fails

drop table p1 cascade;
---END---
---START---

-- Tests for casting between the rowtypes of parent and child
-- tables. See the pgsql-hackers thread beginning Dec. 4/04
create table base (i integer);
---END---
---START---
create table derived () inherits (base);
---END---
---START---
create table more_derived (like derived, b int) inherits (derived);
---END---
---START---
insert into derived (i) values (0);
---END---
---START---
select derived::base from derived;
---END---
---START---
select NULL::derived::base;
---END---
---START---
-- remove redundant conversions.
explain (verbose on, costs off) select row(i, b)::more_derived::derived::base from more_derived;
---END---
---START---
explain (verbose on, costs off) select (1, 2)::more_derived::derived::base;
---END---
---START---
drop table more_derived;
---END---
---START---
drop table derived;
---END---
---START---
drop table base;
---END---
---START---

create table p1(ff1 int);
---END---
---START---
create table p2(f1 text);
---END---
---START---
create function p2text(p2) returns text as 'select $1.f1' language sql;
---END---
---START---
create table c1(f3 int) inherits(p1,p2);
---END---
---START---
insert into c1 values(123456789, 'hi', 42);
---END---
---START---
select p2text(c1.*) from c1;
---END---
---START---
drop function p2text(p2);
---END---
---START---
drop table c1;
---END---
---START---
drop table p2;
---END---
---START---
drop table p1;
---END---
---START---

CREATE TABLE ac (aa TEXT);
---END---
---START---
alter table ac add constraint ac_check check (aa is not null);
---END---
---START---
CREATE TABLE bc (bb TEXT) INHERITS (ac);
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---

insert into ac (aa) values (NULL);
---END---
---START---
insert into bc (aa) values (NULL);
---END---
---START---

alter table bc drop constraint ac_check;  -- fail, disallowed
alter table ac drop constraint ac_check;
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---

-- try the unnamed-constraint case
alter table ac add check (aa is not null);
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---

insert into ac (aa) values (NULL);
---END---
---START---
insert into bc (aa) values (NULL);
---END---
---START---

alter table bc drop constraint ac_aa_check;  -- fail, disallowed
alter table ac drop constraint ac_aa_check;
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---

alter table ac add constraint ac_check check (aa is not null);
---END---
---START---
alter table bc no inherit ac;
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---
alter table bc drop constraint ac_check;
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---
alter table ac drop constraint ac_check;
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---

drop table bc;
---END---
---START---
drop table ac;
---END---
---START---

create table ac (a int constraint check_a check (a <> 0));
---END---
---START---
create table bc (a int constraint check_a check (a <> 0), b int constraint check_b check (b <> 0)) inherits (ac);
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc') order by 1,2;
---END---
---START---

drop table bc;
---END---
---START---
drop table ac;
---END---
---START---

create table ac (a int constraint check_a check (a <> 0));
---END---
---START---
create table bc (b int constraint check_b check (b <> 0));
---END---
---START---
create table cc (c int constraint check_c check (c <> 0)) inherits (ac, bc);
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc', 'cc') order by 1,2;
---END---
---START---

alter table cc no inherit bc;
---END---
---START---
select pc.relname, pgc.conname, pgc.contype, pgc.conislocal, pgc.coninhcount, pg_get_expr(pgc.conbin, pc.oid) as consrc from pg_class as pc inner join pg_constraint as pgc on (pgc.conrelid = pc.oid) where pc.relname in ('ac', 'bc', 'cc') order by 1,2;
---END---
---START---

drop table cc;
---END---
---START---
drop table bc;
---END---
---START---
drop table ac;
---END---
---START---

create table p1(f1 int);
---END---
---START---
create table p2(f2 int);
---END---
---START---
create table c1(f3 int) inherits(p1,p2);
---END---
---START---
insert into c1 values(1,-1,2);
---END---
---START---
alter table p2 add constraint cc check (f2>0);  -- fail
alter table p2 add check (f2>0);  -- check it without a name, too
delete from c1;
---END---
---START---
insert into c1 values(1,1,2);
---END---
---START---
alter table p2 add check (f2>0);
---END---
---START---
insert into c1 values(1,-1,2);  -- fail
create table c2(f3 int) inherits(p1,p2);
---END---
---START---
\d c2
create table c3 (f4 int) inherits(c1,c2);
---END---
---START---
\d c3
drop table p1 cascade;
---END---
---START---
drop table p2 cascade;
---END---
---START---

create table pp1 (f1 int);
---END---
---START---
create table cc1 (f2 text, f3 int) inherits (pp1);
---END---
---START---
alter table pp1 add column a1 int check (a1 > 0);
---END---
---START---
\d cc1
create table cc2(f4 float) inherits(pp1,cc1);
---END---
---START---
\d cc2
alter table pp1 add column a2 int check (a2 > 0);
---END---
---START---
\d cc2
drop table pp1 cascade;
---END---
---START---

-- Test for renaming in simple multiple inheritance
CREATE TABLE inht1 (a int, b int);
---END---
---START---
CREATE TABLE inhs1 (b int, c int);
---END---
---START---
CREATE TABLE inhts (d int) INHERITS (inht1, inhs1);
---END---
---START---

ALTER TABLE inht1 RENAME a TO aa;
---END---
---START---
ALTER TABLE inht1 RENAME b TO bb;                -- to be failed
ALTER TABLE inhts RENAME aa TO aaa;      -- to be failed
ALTER TABLE inhts RENAME d TO dd;
---END---
---START---
\d+ inhts

DROP TABLE inhts;
---END---
---START---

-- Test for renaming in diamond inheritance
CREATE TABLE inht2 (x int) INHERITS (inht1);
---END---
---START---
CREATE TABLE inht3 (y int) INHERITS (inht1);
---END---
---START---
CREATE TABLE inht4 (z int) INHERITS (inht2, inht3);
---END---
---START---

ALTER TABLE inht1 RENAME aa TO aaa;
---END---
---START---
\d+ inht4

CREATE TABLE inhts (d int) INHERITS (inht2, inhs1);
---END---
---START---
ALTER TABLE inht1 RENAME aaa TO aaaa;
---END---
---START---
ALTER TABLE inht1 RENAME b TO bb;                -- to be failed
\d+ inhts

WITH RECURSIVE r AS (
  SELECT 'inht1'::regclass AS inhrelid
UNION ALL
  SELECT c.inhrelid FROM pg_inherits c, r WHERE r.inhrelid = c.inhparent
)
SELECT a.attrelid::regclass, a.attname, a.attinhcount, e.expected
  FROM (SELECT inhrelid, count(*) AS expected FROM pg_inherits
        WHERE inhparent IN (SELECT inhrelid FROM r) GROUP BY inhrelid) e
  JOIN pg_attribute a ON e.inhrelid = a.attrelid WHERE NOT attislocal
  ORDER BY a.attrelid::regclass::name, a.attnum;
---END---
---START---

DROP TABLE inht1, inhs1 CASCADE;
---END---
---START---


-- Test non-inheritable indices [UNIQUE, EXCLUDE] constraints
CREATE TABLE test_constraints (id int, val1 varchar, val2 int, UNIQUE(val1, val2));
---END---
---START---
CREATE TABLE test_constraints_inh () INHERITS (test_constraints);
---END---
---START---
\d+ test_constraints
ALTER TABLE ONLY test_constraints DROP CONSTRAINT test_constraints_val1_val2_key;
---END---
---START---
\d+ test_constraints
\d+ test_constraints_inh
DROP TABLE test_constraints_inh;
---END---
---START---
DROP TABLE test_constraints;
---END---
---START---

CREATE TABLE test_ex_constraints (
    c circle,
    EXCLUDE USING gist (c WITH &&)
);
---END---
---START---
CREATE TABLE test_ex_constraints_inh () INHERITS (test_ex_constraints);
---END---
---START---
\d+ test_ex_constraints
ALTER TABLE test_ex_constraints DROP CONSTRAINT test_ex_constraints_c_excl;
---END---
---START---
\d+ test_ex_constraints
\d+ test_ex_constraints_inh
DROP TABLE test_ex_constraints_inh;
---END---
---START---
DROP TABLE test_ex_constraints;
---END---
---START---

-- Test non-inheritable foreign key constraints
CREATE TABLE test_primary_constraints(id int PRIMARY KEY);
---END---
---START---
CREATE TABLE test_foreign_constraints(id1 int REFERENCES test_primary_constraints(id));
---END---
---START---
CREATE TABLE test_foreign_constraints_inh () INHERITS (test_foreign_constraints);
---END---
---START---
\d+ test_primary_constraints
\d+ test_foreign_constraints
ALTER TABLE test_foreign_constraints DROP CONSTRAINT test_foreign_constraints_id1_fkey;
---END---
---START---
\d+ test_foreign_constraints
\d+ test_foreign_constraints_inh
DROP TABLE test_foreign_constraints_inh;
---END---
---START---
DROP TABLE test_foreign_constraints;
---END---
---START---
DROP TABLE test_primary_constraints;
---END---
---START---

-- Test foreign key behavior
create table inh_fk_1 (a int primary key);
---END---
---START---
insert into inh_fk_1 values (1), (2), (3);
---END---
---START---
create table inh_fk_2 (x int primary key, y int references inh_fk_1 on delete cascade);
---END---
---START---
insert into inh_fk_2 values (11, 1), (22, 2), (33, 3);
---END---
---START---
create table inh_fk_2_child () inherits (inh_fk_2);
---END---
---START---
insert into inh_fk_2_child values (111, 1), (222, 2);
---END---
---START---
delete from inh_fk_1 where a = 1;
---END---
---START---
select * from inh_fk_1 order by 1;
---END---
---START---
select * from inh_fk_2 order by 1, 2;
---END---
---START---
drop table inh_fk_1, inh_fk_2, inh_fk_2_child;
---END---
---START---

-- Test that parent and child CHECK constraints can be created in either order
create table p1(f1 int);
---END---
---START---
create table p1_c1() inherits(p1);
---END---
---START---

alter table p1 add constraint inh_check_constraint1 check (f1 > 0);
---END---
---START---
alter table p1_c1 add constraint inh_check_constraint1 check (f1 > 0);
---END---
---START---

alter table p1_c1 add constraint inh_check_constraint2 check (f1 < 10);
---END---
---START---
alter table p1 add constraint inh_check_constraint2 check (f1 < 10);
---END---
---START---

select conrelid::regclass::text as relname, conname, conislocal, coninhcount
from pg_constraint where conname like 'inh\_check\_constraint%'
order by 1, 2;
---END---
---START---

drop table p1 cascade;
---END---
---START---

-- Test that a valid child can have not-valid parent, but not vice versa
create table invalid_check_con(f1 int);
---END---
---START---
create table invalid_check_con_child() inherits(invalid_check_con);
---END---
---START---

alter table invalid_check_con_child add constraint inh_check_constraint check(f1 > 0) not valid;
---END---
---START---
alter table invalid_check_con add constraint inh_check_constraint check(f1 > 0); -- fail
alter table invalid_check_con_child drop constraint inh_check_constraint;
---END---
---START---

insert into invalid_check_con values(0);
---END---
---START---

alter table invalid_check_con_child add constraint inh_check_constraint check(f1 > 0);
---END---
---START---
alter table invalid_check_con add constraint inh_check_constraint check(f1 > 0) not valid;
---END---
---START---

insert into invalid_check_con values(0); -- fail
insert into invalid_check_con_child values(0); -- fail

select conrelid::regclass::text as relname, conname,
       convalidated, conislocal, coninhcount, connoinherit
from pg_constraint where conname like 'inh\_check\_constraint%'
order by 1, 2;
---END---
---START---

-- We don't drop the invalid_check_con* tables, to test dump/reload with

--
-- Test parameterized append plans for inheritance trees
--

create table patest0 (id, x) as
  select x, x from generate_series(0,1000) x;
---END---
---START---
create table patest1() inherits (patest0);
---END---
---START---
insert into patest1
  select x, x from generate_series(0,1000) x;
---END---
---START---
create table patest2() inherits (patest0);
---END---
---START---
insert into patest2
  select x, x from generate_series(0,1000) x;
---END---
---START---
create index patest0i on patest0(id);
---END---
---START---
create index patest1i on patest1(id);
---END---
---START---
create index patest2i on patest2(id);
---END---
---START---
analyze patest0;
---END---
---START---
analyze patest1;
---END---
---START---
analyze patest2;
---END---
---START---

explain (costs off)
select * from patest0 join (select f1 from int4_tbl limit 1) ss on id = f1;
---END---
---START---
select * from patest0 join (select f1 from int4_tbl limit 1) ss on id = f1;
---END---
---START---

drop index patest2i;
---END---
---START---

explain (costs off)
select * from patest0 join (select f1 from int4_tbl limit 1) ss on id = f1;
---END---
---START---
select * from patest0 join (select f1 from int4_tbl limit 1) ss on id = f1;
---END---
---START---

drop table patest0 cascade;
---END---
---START---

--
-- Test merge-append plans for inheritance trees
--

create table matest0 (id serial primary key, name text);
---END---
---START---
create table matest1 (id integer primary key) inherits (matest0);
---END---
---START---
create table matest2 (id integer primary key) inherits (matest0);
---END---
---START---
create table matest3 (id integer primary key) inherits (matest0);
---END---
---START---

create index matest0i on matest0 ((1-id));
---END---
---START---
create index matest1i on matest1 ((1-id));
---END---
---START---
-- create index matest2i on matest2 ((1-id));  -- intentionally missing
create index matest3i on matest3 ((1-id));
---END---
---START---

insert into matest1 (name) values ('Test 1');
---END---
---START---
insert into matest1 (name) values ('Test 2');
---END---
---START---
insert into matest2 (name) values ('Test 3');
---END---
---START---
insert into matest2 (name) values ('Test 4');
---END---
---START---
insert into matest3 (name) values ('Test 5');
---END---
---START---
insert into matest3 (name) values ('Test 6');
---END---
---START---

set enable_indexscan = off;  -- force use of seqscan/sort, so no merge
explain (verbose, costs off) select * from matest0 order by 1-id;
---END---
---START---
select * from matest0 order by 1-id;
---END---
---START---
explain (verbose, costs off) select min(1-id) from matest0;
---END---
---START---
select min(1-id) from matest0;
---END---
---START---
reset enable_indexscan;
---END---
---START---

set enable_seqscan = off;  -- plan with fewest seqscans should be merge
set enable_parallel_append = off; -- Don't let parallel-append interfere
explain (verbose, costs off) select * from matest0 order by 1-id;
---END---
---START---
select * from matest0 order by 1-id;
---END---
---START---
explain (verbose, costs off) select min(1-id) from matest0;
---END---
---START---
select min(1-id) from matest0;
---END---
---START---
reset enable_seqscan;
---END---
---START---
reset enable_parallel_append;
---END---
---START---

drop table matest0 cascade;
---END---
---START---

--
-- Check that use of an index with an extraneous column doesn't produce
-- a plan with extraneous sorting
--

create table matest0 (a int, b int, c int, d int);
---END---
---START---
create table matest1 () inherits(matest0);
---END---
---START---
create index matest0i on matest0 (b, c);
---END---
---START---
create index matest1i on matest1 (b, c);
---END---
---START---

set enable_nestloop = off;  -- we want a plan with two MergeAppends

explain (costs off)
select t1.* from matest0 t1, matest0 t2
where t1.b = t2.b and t2.c = t2.d
order by t1.b limit 10;
---END---
---START---

reset enable_nestloop;
---END---
---START---

drop table matest0 cascade;
---END---
---START---

--
-- Test merge-append for UNION ALL append relations
--

set enable_seqscan = off;
---END---
---START---
set enable_indexscan = on;
---END---
---START---
set enable_bitmapscan = off;
---END---
---START---

-- Check handling of duplicated, constant, or volatile targetlist items
explain (costs off)
SELECT thousand, tenthous FROM tenk1
UNION ALL
SELECT thousand, thousand FROM tenk1
ORDER BY thousand, tenthous;
---END---
---START---

explain (costs off)
SELECT thousand, tenthous, thousand+tenthous AS x FROM tenk1
UNION ALL
SELECT 42, 42, hundred FROM tenk1
ORDER BY thousand, tenthous;
---END---
---START---

explain (costs off)
SELECT thousand, tenthous FROM tenk1
UNION ALL
SELECT thousand, random()::integer FROM tenk1
ORDER BY thousand, tenthous;
---END---
---START---

-- Check min/max aggregate optimization
explain (costs off)
SELECT min(x) FROM
  (SELECT unique1 AS x FROM tenk1 a
   UNION ALL
   SELECT unique2 AS x FROM tenk1 b) s;
---END---
---START---

explain (costs off)
SELECT min(y) FROM
  (SELECT unique1 AS x, unique1 AS y FROM tenk1 a
   UNION ALL
   SELECT unique2 AS x, unique2 AS y FROM tenk1 b) s;
---END---
---START---

-- XXX planner doesn't recognize that index on unique2 is sufficiently sorted
explain (costs off)
SELECT x, y FROM
  (SELECT thousand AS x, tenthous AS y FROM tenk1 a
   UNION ALL
   SELECT unique2 AS x, unique2 AS y FROM tenk1 b) s
ORDER BY x, y;
---END---
---START---

-- exercise rescan code path via a repeatedly-evaluated subquery
explain (costs off)
SELECT
    ARRAY(SELECT f.i FROM (
        (SELECT d + g.i FROM generate_series(4, 30, 3) d ORDER BY 1)
        UNION ALL
        (SELECT d + g.i FROM generate_series(0, 30, 5) d ORDER BY 1)
    ) f(i)
    ORDER BY f.i LIMIT 10)
FROM generate_series(1, 3) g(i);
---END---
---START---

SELECT
    ARRAY(SELECT f.i FROM (
        (SELECT d + g.i FROM generate_series(4, 30, 3) d ORDER BY 1)
        UNION ALL
        (SELECT d + g.i FROM generate_series(0, 30, 5) d ORDER BY 1)
    ) f(i)
    ORDER BY f.i LIMIT 10)
FROM generate_series(1, 3) g(i);
---END---
---START---

reset enable_seqscan;
---END---
---START---
reset enable_indexscan;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---

--
-- Check handling of MULTIEXPR SubPlans in inherited updates
--
create table inhpar(f1 int, f2 name);
---END---
---START---
create table inhcld(f2 name, f1 int);
---END---
---START---
alter table inhcld inherit inhpar;
---END---
---START---
insert into inhpar select x, x::text from generate_series(1,5) x;
---END---
---START---
insert into inhcld select x::text, x from generate_series(6,10) x;
---END---
---START---

explain (verbose, costs off)
update inhpar i set (f1, f2) = (select i.f1, i.f2 || '-' from int4_tbl limit 1);
---END---
---START---
update inhpar i set (f1, f2) = (select i.f1, i.f2 || '-' from int4_tbl limit 1);
---END---
---START---
select * from inhpar;
---END---
---START---

drop table inhpar cascade;
---END---
---START---

--
-- And the same for partitioned cases
--
create table inhpar(f1 int primary key, f2 name) partition by range (f1);
---END---
---START---
create table inhcld1(f2 name, f1 int primary key);
---END---
---START---
create table inhcld2(f1 int primary key, f2 name);
---END---
---START---
alter table inhpar attach partition inhcld1 for values from (1) to (5);
---END---
---START---
alter table inhpar attach partition inhcld2 for values from (5) to (100);
---END---
---START---
insert into inhpar select x, x::text from generate_series(1,10) x;
---END---
---START---

explain (verbose, costs off)
update inhpar i set (f1, f2) = (select i.f1, i.f2 || '-' from int4_tbl limit 1);
---END---
---START---
update inhpar i set (f1, f2) = (select i.f1, i.f2 || '-' from int4_tbl limit 1);
---END---
---START---
select * from inhpar;
---END---
---START---

-- Also check ON CONFLICT
insert into inhpar as i values (3), (7) on conflict (f1)
  do update set (f1, f2) = (select i.f1, i.f2 || '+');
---END---
---START---
select * from inhpar order by f1;  -- tuple order might be unstable here

drop table inhpar cascade;
---END---
---START---

--
-- Check handling of a constant-null CHECK constraint
--
create table cnullparent (f1 int);
---END---
---START---
create table cnullchild (check (f1 = 1 or f1 = null)) inherits(cnullparent);
---END---
---START---
insert into cnullchild values(1);
---END---
---START---
insert into cnullchild values(2);
---END---
---START---
insert into cnullchild values(null);
---END---
---START---
select * from cnullparent;
---END---
---START---
select * from cnullparent where f1 = 2;
---END---
---START---
drop table cnullparent cascade;
---END---
---START---

--
-- Check use of temporary tables with inheritance trees
--
create table inh_perm_parent (a1 int);
---END---
---START---
create table inh_temp_parent (a1 int);
---END---
---START---
create table inh_temp_child () inherits (inh_perm_parent); -- ok
create table inh_perm_child () inherits (inh_temp_parent); -- error
create table inh_temp_child_2 () inherits (inh_temp_parent); -- ok
insert into inh_perm_parent values (1);
---END---
---START---
insert into inh_temp_parent values (2);
---END---
---START---
insert into inh_temp_child values (3);
---END---
---START---
insert into inh_temp_child_2 values (4);
---END---
---START---
select tableoid::regclass, a1 from inh_perm_parent;
---END---
---START---
select tableoid::regclass, a1 from inh_temp_parent;
---END---
---START---
drop table inh_perm_parent cascade;
---END---
---START---
drop table inh_temp_parent cascade;
---END---
---START---

--
-- Check that constraint exclusion works correctly with partitions using
-- implicit constraints generated from the partition bound information.
--
create table list_parted (
	a	varchar
) partition by list (a);
---END---
---START---
create table part_ab_cd partition of list_parted for values in ('ab', 'cd');
---END---
---START---
create table part_ef_gh partition of list_parted for values in ('ef', 'gh');
---END---
---START---
create table part_null_xy partition of list_parted for values in (null, 'xy');
---END---
---START---

explain (costs off) select * from list_parted;
---END---
---START---
explain (costs off) select * from list_parted where a is null;
---END---
---START---
explain (costs off) select * from list_parted where a is not null;
---END---
---START---
explain (costs off) select * from list_parted where a in ('ab', 'cd', 'ef');
---END---
---START---
explain (costs off) select * from list_parted where a = 'ab' or a in (null, 'cd');
---END---
---START---
explain (costs off) select * from list_parted where a = 'ab';
---END---
---START---

create table range_list_parted (
	a	int,
	b	char(2)
) partition by range (a);
---END---
---START---
create table part_1_10 partition of range_list_parted for values from (1) to (10) partition by list (b);
---END---
---START---
create table part_1_10_ab partition of part_1_10 for values in ('ab');
---END---
---START---
create table part_1_10_cd partition of part_1_10 for values in ('cd');
---END---
---START---
create table part_10_20 partition of range_list_parted for values from (10) to (20) partition by list (b);
---END---
---START---
create table part_10_20_ab partition of part_10_20 for values in ('ab');
---END---
---START---
create table part_10_20_cd partition of part_10_20 for values in ('cd');
---END---
---START---
create table part_21_30 partition of range_list_parted for values from (21) to (30) partition by list (b);
---END---
---START---
create table part_21_30_ab partition of part_21_30 for values in ('ab');
---END---
---START---
create table part_21_30_cd partition of part_21_30 for values in ('cd');
---END---
---START---
create table part_40_inf partition of range_list_parted for values from (40) to (maxvalue) partition by list (b);
---END---
---START---
create table part_40_inf_ab partition of part_40_inf for values in ('ab');
---END---
---START---
create table part_40_inf_cd partition of part_40_inf for values in ('cd');
---END---
---START---
create table part_40_inf_null partition of part_40_inf for values in (null);
---END---
---START---

explain (costs off) select * from range_list_parted;
---END---
---START---
explain (costs off) select * from range_list_parted where a = 5;
---END---
---START---
explain (costs off) select * from range_list_parted where b = 'ab';
---END---
---START---
explain (costs off) select * from range_list_parted where a between 3 and 23 and b in ('ab');
---END---
---START---

/* Should select no rows because range partition key cannot be null */
explain (costs off) select * from range_list_parted where a is null;
---END---
---START---

/* Should only select rows from the null-accepting partition */
explain (costs off) select * from range_list_parted where b is null;
---END---
---START---
explain (costs off) select * from range_list_parted where a is not null and a < 67;
---END---
---START---
explain (costs off) select * from range_list_parted where a >= 30;
---END---
---START---

drop table list_parted;
---END---
---START---
drop table range_list_parted;
---END---
---START---

-- check that constraint exclusion is able to cope with the partition
-- constraint emitted for multi-column range partitioned tables
create table mcrparted (a int, b int, c int) partition by range (a, abs(b), c);
---END---
---START---
create table mcrparted_def partition of mcrparted default;
---END---
---START---
create table mcrparted0 partition of mcrparted for values from (minvalue, minvalue, minvalue) to (1, 1, 1);
---END---
---START---
create table mcrparted1 partition of mcrparted for values from (1, 1, 1) to (10, 5, 10);
---END---
---START---
create table mcrparted2 partition of mcrparted for values from (10, 5, 10) to (10, 10, 10);
---END---
---START---
create table mcrparted3 partition of mcrparted for values from (11, 1, 1) to (20, 10, 10);
---END---
---START---
create table mcrparted4 partition of mcrparted for values from (20, 10, 10) to (20, 20, 20);
---END---
---START---
create table mcrparted5 partition of mcrparted for values from (20, 20, 20) to (maxvalue, maxvalue, maxvalue);
---END---
---START---
explain (costs off) select * from mcrparted where a = 0;	-- scans mcrparted0, mcrparted_def
explain (costs off) select * from mcrparted where a = 10 and abs(b) < 5;	-- scans mcrparted1, mcrparted_def
explain (costs off) select * from mcrparted where a = 10 and abs(b) = 5;	-- scans mcrparted1, mcrparted2, mcrparted_def
explain (costs off) select * from mcrparted where abs(b) = 5;	-- scans all partitions
explain (costs off) select * from mcrparted where a > -1;	-- scans all partitions
explain (costs off) select * from mcrparted where a = 20 and abs(b) = 10 and c > 10;	-- scans mcrparted4
explain (costs off) select * from mcrparted where a = 20 and c > 20; -- scans mcrparted3, mcrparte4, mcrparte5, mcrparted_def

-- check that partitioned table Appends cope with being referenced in
-- subplans
create table parted_minmax (a int, b varchar(16)) partition by range (a);
---END---
---START---
create table parted_minmax1 partition of parted_minmax for values from (1) to (10);
---END---
---START---
create index parted_minmax1i on parted_minmax1 (a, b);
---END---
---START---
insert into parted_minmax values (1,'12345');
---END---
---START---
explain (costs off) select min(a), max(a) from parted_minmax where b = '12345';
---END---
---START---
select min(a), max(a) from parted_minmax where b = '12345';
---END---
---START---
drop table parted_minmax;
---END---
---START---

-- Test code that uses Append nodes in place of MergeAppend when the
-- partition ordering matches the desired ordering.

create index mcrparted_a_abs_c_idx on mcrparted (a, abs(b), c);
---END---
---START---

-- MergeAppend must be used when a default partition exists
explain (costs off) select * from mcrparted order by a, abs(b), c;
---END---
---START---

drop table mcrparted_def;
---END---
---START---

-- Append is used for a RANGE partitioned table with no default
-- and no subpartitions
explain (costs off) select * from mcrparted order by a, abs(b), c;
---END---
---START---

-- Append is used with subpaths in reverse order with backwards index scans
explain (costs off) select * from mcrparted order by a desc, abs(b) desc, c desc;
---END---
---START---

-- check that Append plan is used containing a MergeAppend for sub-partitions
-- that are unordered.
drop table mcrparted5;
---END---
---START---
create table mcrparted5 partition of mcrparted for values from (20, 20, 20) to (maxvalue, maxvalue, maxvalue) partition by list (a);
---END---
---START---
create table mcrparted5a partition of mcrparted5 for values in(20);
---END---
---START---
create table mcrparted5_def partition of mcrparted5 default;
---END---
---START---

explain (costs off) select * from mcrparted order by a, abs(b), c;
---END---
---START---

drop table mcrparted5_def;
---END---
---START---

-- check that an Append plan is used and the sub-partitions are flattened
-- into the main Append when the sub-partition is unordered but contains
-- just a single sub-partition.
explain (costs off) select a, abs(b) from mcrparted order by a, abs(b), c;
---END---
---START---

-- check that Append is used when the sub-partitioned tables are pruned
-- during planning.
explain (costs off) select * from mcrparted where a < 20 order by a, abs(b), c;
---END---
---START---

set enable_bitmapscan to off;
---END---
---START---
set enable_sort to off;
---END---
---START---
create table mclparted (a int) partition by list(a);
---END---
---START---
create table mclparted1 partition of mclparted for values in(1);
---END---
---START---
create table mclparted2 partition of mclparted for values in(2);
---END---
---START---
create index on mclparted (a);
---END---
---START---

-- Ensure an Append is used for a list partition with an order by.
explain (costs off) select * from mclparted order by a;
---END---
---START---

-- Ensure a MergeAppend is used when a partition exists with interleaved
-- datums in the partition bound.
create table mclparted3_5 partition of mclparted for values in(3,5);
---END---
---START---
create table mclparted4 partition of mclparted for values in(4);
---END---
---START---

explain (costs off) select * from mclparted order by a;
---END---
---START---
explain (costs off) select * from mclparted where a in(3,4,5) order by a;
---END---
---START---

-- Introduce a NULL and DEFAULT partition so we can test more complex cases
create table mclparted_null partition of mclparted for values in(null);
---END---
---START---
create table mclparted_def partition of mclparted default;
---END---
---START---

-- Append can be used providing we don't scan the interleaved partition
explain (costs off) select * from mclparted where a in(1,2,4) order by a;
---END---
---START---
explain (costs off) select * from mclparted where a in(1,2,4) or a is null order by a;
---END---
---START---

-- Test a more complex case where the NULL partition allows some other value
drop table mclparted_null;
---END---
---START---
create table mclparted_0_null partition of mclparted for values in(0,null);
---END---
---START---

-- Ensure MergeAppend is used since 0 and NULLs are in the same partition.
explain (costs off) select * from mclparted where a in(1,2,4) or a is null order by a;
---END---
---START---
explain (costs off) select * from mclparted where a in(0,1,2,4) order by a;
---END---
---START---

-- Ensure Append is used when the null partition is pruned
explain (costs off) select * from mclparted where a in(1,2,4) order by a;
---END---
---START---

-- Ensure MergeAppend is used when the default partition is not pruned
explain (costs off) select * from mclparted where a in(1,2,4,100) order by a;
---END---
---START---

drop table mclparted;
---END---
---START---
reset enable_sort;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---

-- Ensure subplans which don't have a path with the correct pathkeys get
-- sorted correctly.
drop index mcrparted_a_abs_c_idx;
---END---
---START---
create index on mcrparted1 (a, abs(b), c);
---END---
---START---
create index on mcrparted2 (a, abs(b), c);
---END---
---START---
create index on mcrparted3 (a, abs(b), c);
---END---
---START---
create index on mcrparted4 (a, abs(b), c);
---END---
---START---

explain (costs off) select * from mcrparted where a < 20 order by a, abs(b), c limit 1;
---END---
---START---

set enable_bitmapscan = 0;
---END---
---START---
-- Ensure Append node can be used when the partition is ordered by some
-- pathkeys which were deemed redundant.
explain (costs off) select * from mcrparted where a = 10 order by a, abs(b), c;
---END---
---START---
reset enable_bitmapscan;
---END---
---START---

drop table mcrparted;
---END---
---START---

-- Ensure LIST partitions allow an Append to be used instead of a MergeAppend
create table bool_lp (b bool) partition by list(b);
---END---
---START---
create table bool_lp_true partition of bool_lp for values in(true);
---END---
---START---
create table bool_lp_false partition of bool_lp for values in(false);
---END---
---START---
create index on bool_lp (b);
---END---
---START---

explain (costs off) select * from bool_lp order by b;
---END---
---START---

drop table bool_lp;
---END---
---START---

-- Ensure const bool quals can be properly detected as redundant
create table bool_rp (b bool, a int) partition by range(b,a);
---END---
---START---
create table bool_rp_false_1k partition of bool_rp for values from (false,0) to (false,1000);
---END---
---START---
create table bool_rp_true_1k partition of bool_rp for values from (true,0) to (true,1000);
---END---
---START---
create table bool_rp_false_2k partition of bool_rp for values from (false,1000) to (false,2000);
---END---
---START---
create table bool_rp_true_2k partition of bool_rp for values from (true,1000) to (true,2000);
---END---
---START---
create index on bool_rp (b,a);
---END---
---START---
explain (costs off) select * from bool_rp where b = true order by b,a;
---END---
---START---
explain (costs off) select * from bool_rp where b = false order by b,a;
---END---
---START---
explain (costs off) select * from bool_rp where b = true order by a;
---END---
---START---
explain (costs off) select * from bool_rp where b = false order by a;
---END---
---START---

drop table bool_rp;
---END---
---START---

-- Ensure an Append scan is chosen when the partition order is a subset of
-- the required order.
create table range_parted (a int, b int, c int) partition by range(a, b);
---END---
---START---
create table range_parted1 partition of range_parted for values from (0,0) to (10,10);
---END---
---START---
create table range_parted2 partition of range_parted for values from (10,10) to (20,20);
---END---
---START---
create index on range_parted (a,b,c);
---END---
---START---

explain (costs off) select * from range_parted order by a,b,c;
---END---
---START---
explain (costs off) select * from range_parted order by a desc,b desc,c desc;
---END---
---START---

drop table range_parted;
---END---
---START---

-- Check that we allow access to a child table's statistics when the user
-- has permissions only for the parent table.
create table permtest_parent (a int, b text, c text) partition by list (a);
---END---
---START---
create table permtest_child (b text, c text, a int) partition by list (b);
---END---
---START---
create table permtest_grandchild (c text, b text, a int);
---END---
---START---
alter table permtest_child attach partition permtest_grandchild for values in ('a');
---END---
---START---
alter table permtest_parent attach partition permtest_child for values in (1);
---END---
---START---
create index on permtest_parent (left(c, 3));
---END---
---START---
insert into permtest_parent
  select 1, 'a', left(fipshash(i::text), 5) from generate_series(0, 100) i;
---END---
---START---
analyze permtest_parent;
---END---
---START---
create role regress_no_child_access;
---END---
---START---
revoke all on permtest_grandchild from regress_no_child_access;
---END---
---START---
grant select on permtest_parent to regress_no_child_access;
---END---
---START---
set session authorization regress_no_child_access;
---END---
---START---
-- without stats access, these queries would produce hash join plans:
explain (costs off)
  select * from permtest_parent p1 inner join permtest_parent p2
  on p1.a = p2.a and p1.c ~ 'a1$';
---END---
---START---
explain (costs off)
  select * from permtest_parent p1 inner join permtest_parent p2
  on p1.a = p2.a and left(p1.c, 3) ~ 'a1$';
---END---
---START---
reset session authorization;
---END---
---START---
revoke all on permtest_parent from regress_no_child_access;
---END---
---START---
grant select(a,c) on permtest_parent to regress_no_child_access;
---END---
---START---
set session authorization regress_no_child_access;
---END---
---START---
explain (costs off)
  select p2.a, p1.c from permtest_parent p1 inner join permtest_parent p2
  on p1.a = p2.a and p1.c ~ 'a1$';
---END---
---START---
-- we will not have access to the expression index's stats here:
explain (costs off)
  select p2.a, p1.c from permtest_parent p1 inner join permtest_parent p2
  on p1.a = p2.a and left(p1.c, 3) ~ 'a1$';
---END---
---START---
reset session authorization;
---END---
---START---
revoke all on permtest_parent from regress_no_child_access;
---END---
---START---
drop role regress_no_child_access;
---END---
---START---
drop table permtest_parent;
---END---
---START---

-- Verify that constraint errors across partition root / child are
-- handled correctly (Bug #16293)
CREATE TABLE errtst_parent (
    partid int not null,
    shdata int not null,
    data int NOT NULL DEFAULT 0,
    CONSTRAINT shdata_small CHECK(shdata < 3)
) PARTITION BY RANGE (partid);
---END---
---START---

-- fast defaults lead to attribute mapping being used in one
-- direction, but not the other
CREATE TABLE errtst_child_fastdef (
    partid int not null,
    shdata int not null,
    CONSTRAINT shdata_small CHECK(shdata < 3)
);
---END---
---START---

-- no remapping in either direction necessary
CREATE TABLE errtst_child_plaindef (
    partid int not null,
    shdata int not null,
    data int NOT NULL DEFAULT 0,
    CONSTRAINT shdata_small CHECK(shdata < 3),
    CHECK(data < 10)
);
---END---
---START---

-- remapping in both direction
CREATE TABLE errtst_child_reorder (
    data int NOT NULL DEFAULT 0,
    shdata int not null,
    partid int not null,
    CONSTRAINT shdata_small CHECK(shdata < 3),
    CHECK(data < 10)
);
---END---
---START---

ALTER TABLE errtst_child_fastdef ADD COLUMN data int NOT NULL DEFAULT 0;
---END---
---START---
ALTER TABLE errtst_child_fastdef ADD CONSTRAINT errtest_child_fastdef_data_check CHECK (data < 10);
---END---
---START---

ALTER TABLE errtst_parent ATTACH PARTITION errtst_child_fastdef FOR VALUES FROM (0) TO (10);
---END---
---START---
ALTER TABLE errtst_parent ATTACH PARTITION errtst_child_plaindef FOR VALUES FROM (10) TO (20);
---END---
---START---
ALTER TABLE errtst_parent ATTACH PARTITION errtst_child_reorder FOR VALUES FROM (20) TO (30);
---END---
---START---

-- insert without child check constraint error
INSERT INTO errtst_parent(partid, shdata, data) VALUES ( '0', '1', '5');
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('10', '1', '5');
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('20', '1', '5');
---END---
---START---

-- insert with child check constraint error
INSERT INTO errtst_parent(partid, shdata, data) VALUES ( '0', '1', '10');
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('10', '1', '10');
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('20', '1', '10');
---END---
---START---

-- insert with child not null constraint error
INSERT INTO errtst_parent(partid, shdata, data) VALUES ( '0', '1', NULL);
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('10', '1', NULL);
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('20', '1', NULL);
---END---
---START---

-- insert with shared check constraint error
INSERT INTO errtst_parent(partid, shdata, data) VALUES ( '0', '5', '5');
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('10', '5', '5');
---END---
---START---
INSERT INTO errtst_parent(partid, shdata, data) VALUES ('20', '5', '5');
---END---
---START---

-- within partition update without child check constraint violation
BEGIN;
---END---
---START---
UPDATE errtst_parent SET data = data + 1 WHERE partid = 0;
---END---
---START---
UPDATE errtst_parent SET data = data + 1 WHERE partid = 10;
---END---
---START---
UPDATE errtst_parent SET data = data + 1 WHERE partid = 20;
---END---
---START---
ROLLBACK;
---END---
---START---

-- within partition update with child check constraint violation
UPDATE errtst_parent SET data = data + 10 WHERE partid = 0;
---END---
---START---
UPDATE errtst_parent SET data = data + 10 WHERE partid = 10;
---END---
---START---
UPDATE errtst_parent SET data = data + 10 WHERE partid = 20;
---END---
---START---

-- direct leaf partition update, without partition id violation
BEGIN;
---END---
---START---
UPDATE errtst_child_fastdef SET partid = 1 WHERE partid = 0;
---END---
---START---
UPDATE errtst_child_plaindef SET partid = 11 WHERE partid = 10;
---END---
---START---
UPDATE errtst_child_reorder SET partid = 21 WHERE partid = 20;
---END---
---START---
ROLLBACK;
---END---
---START---

-- direct leaf partition update, with partition id violation
UPDATE errtst_child_fastdef SET partid = partid + 10 WHERE partid = 0;
---END---
---START---
UPDATE errtst_child_plaindef SET partid = partid + 10 WHERE partid = 10;
---END---
---START---
UPDATE errtst_child_reorder SET partid = partid + 10 WHERE partid = 20;
---END---
---START---

-- partition move, without child check constraint violation
BEGIN;
---END---
---START---
UPDATE errtst_parent SET partid = 10, data = data + 1 WHERE partid = 0;
---END---
---START---
UPDATE errtst_parent SET partid = 20, data = data + 1 WHERE partid = 10;
---END---
---START---
UPDATE errtst_parent SET partid = 0, data = data + 1 WHERE partid = 20;
---END---
---START---
ROLLBACK;
---END---
---START---

-- partition move, with child check constraint violation
UPDATE errtst_parent SET partid = 10, data = data + 10 WHERE partid = 0;
---END---
---START---
UPDATE errtst_parent SET partid = 20, data = data + 10 WHERE partid = 10;
---END---
---START---
UPDATE errtst_parent SET partid = 0, data = data + 10 WHERE partid = 20;
---END---
---START---

-- partition move, without target partition
UPDATE errtst_parent SET partid = 30, data = data + 10 WHERE partid = 20;
---END---
---START---

DROP TABLE errtst_parent;

drop table z, foo, foo2, bar, bar2;
drop table childtab;
drop table parent1;
drop table parent2;
drop table patest2;
drop table patest1;
drop table patest0;
drop table inh_temp_child_2;
drop table inh_temp_child;
drop table inh_temp_parent;
---END---
