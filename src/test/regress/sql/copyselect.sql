---START---
--
-- Test cases for COPY (select) TO
--
create sequence id_seq;
---END---
---START---
create table test1 (id int default nextval('id_seq'), t text);
---END---
---START---
insert into test1 (t) values ('a');
---END---
---START---
insert into test1 (t) values ('b');
---END---
---START---
insert into test1 (t) values ('c');
---END---
---START---
insert into test1 (t) values ('d');
---END---
---START---
insert into test1 (t) values ('e');
---END---
---START---

create table test2 (id serial, t text);
---END---
---START---
insert into test2 (t) values ('A');
---END---
---START---
insert into test2 (t) values ('B');
---END---
---START---
insert into test2 (t) values ('C');
---END---
---START---
insert into test2 (t) values ('D');
---END---
---START---
insert into test2 (t) values ('E');
---END---
---START---

create view v_test1
as select 'v_'||t from test1;
---END---
---START---

--
-- Test COPY table TO
--
copy test1 to stdout;
---END---
---START---
--
-- This should fail
--
copy v_test1 to stdout;
---END---
---START---
--
-- Test COPY (select) TO
--
copy (select t from test1 where id=1) to stdout;
---END---
---START---
--
-- Test COPY (select for update) TO
--
copy (select t from test1 where id=3 for update) to stdout;
---END---
---START---
--
-- This should fail
--
copy (select t into temp test3 from test1 where id=3) to stdout;
---END---
---START---
--
-- This should fail
--
copy (select * from test1) from stdin;
---END---
---START---
--
-- This should fail
--
copy (select * from test1) (t,id) to stdout;
---END---
---START---
--
-- Test JOIN
--
copy (select * from test1 join test2 using (id)) to stdout;
---END---
---START---
--
-- Test UNION SELECT
--
copy (select t from test1 where id = 1 UNION select * from v_test1 ORDER BY 1) to stdout;
---END---
---START---
--
-- Test subselect
--
copy (select * from (select t from test1 where id = 1 UNION select * from v_test1 ORDER BY 1) t1) to stdout;
---END---
---START---
--
-- Test headers, CSV and quotes
--
copy (select t from test1 where id = 1) to stdout csv header force quote t;
---END---
---START---
--
-- Test psql builtins, plain table
--
\copy test1 to stdout
--
-- This should fail
--
\copy v_test1 to stdout
--
-- Test \copy (select ...)
--
\copy (select "id",'id','id""'||t,(id + 1)*id,t,"test1"."t" from test1 where id=3) to stdout
--
-- Drop everything
--
drop table test2;
---END---
---START---
drop view v_test1;
---END---
---START---
drop table test1;
---END---
---START---

-- psql handling of COPY in multi-command strings
copy (select 1) to stdout\; select 1/0;	-- row, then error
select 1/0\; copy (select 1) to stdout; -- error only
copy (select 1) to stdout\; copy (select 2) to stdout\; select 3\; select 4; -- 1 2 3 4

create table test3 (c int);
---END---
---START---
select 0\; copy test3 from stdin\; copy test3 from stdin\; select 1; -- 0 1
1
\.
2
\.
select * from test3;
---END---
---START---
drop table test3;
---END---
