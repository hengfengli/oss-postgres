---START---
--
-- Test domains.
--

-- Test Comment / Drop
create domain domaindroptest int4;
---END---
---START---
comment on domain domaindroptest is 'About to drop this..';
---END---
---START---
create domain dependenttypetest domaindroptest;
---END---
---START---
-- fail because of dependent type
drop domain domaindroptest;
---END---
---START---
drop domain domaindroptest cascade;
---END---
---START---
-- this should fail because already gone
drop domain domaindroptest cascade;
---END---
---START---
COPY FROM is that INSERT
-- exercises CoerceToDomain while COPY exercises domain_in.

create domain domainvarchar varchar(5);
create domain domainnumeric numeric(8,2);
create domain domainint4 int4;
create domain domaintext text;

-- Test explicit coercions --- these should succeed (and truncate)
SELECT cast('123456' as domainvarchar);
SELECT cast('12345' as domainvarchar);

-- Test tables using domains
create table basictest
           ( testint4 domainint4
           , testtext domaintext
           , testvarchar domainvarchar
           , testnumeric domainnumeric
           );

INSERT INTO basictest values ('88', 'haha', 'short', '123.12');      -- Good
INSERT INTO basictest values ('88', 'haha', 'short text', '123.12'); -- Bad varchar
INSERT INTO basictest values ('88', 'haha', 'short', '123.1212');    -- Truncate numeric

-- Test copy
COPY basictest (testvarchar) FROM stdin; -- fail
notsoshorttext
\.
---END---
---START---
COPY basictest (testvarchar) FROM stdin;
short
\.
---END---
---START---
select * from basictest;
---END---
---START---
-- check that domains inherit operations from base types
select testtext || testvarchar as concat, testnumeric + 42 as sum
from basictest;
---END---
---START---
-- check that union/case/coalesce type resolution handles domains properly
select pg_typeof(coalesce(4::domainint4, 7));
---END---
---START---
select pg_typeof(coalesce(4::domainint4, 7::domainint4));
---END---
---START---
drop table basictest;
---END---
---START---
drop domain domainvarchar restrict;
---END---
---START---
drop domain domainnumeric restrict;
---END---
---START---
drop domain domainint4 restrict;
---END---
---START---
drop domain domaintext;
---END---
---START---
-- Test non-error-throwing input

create domain positiveint int4 check(value > 0);
---END---
---START---
create domain weirdfloat float8 check((1 / value) < 10);
---END---
---START---
select pg_input_is_valid('1', 'positiveint');
---END---
---START---
select pg_input_is_valid('junk', 'positiveint');
---END---
---START---
select pg_input_is_valid('-1', 'positiveint');
---END---
---START---
select * from pg_input_error_info('junk', 'positiveint');
---END---
---START---
select * from pg_input_error_info('-1', 'positiveint');
---END---
---START---
select * from pg_input_error_info('junk', 'weirdfloat');
---END---
---START---
select * from pg_input_error_info('0.01', 'weirdfloat');
---END---
---START---
-- We currently can't trap errors raised in the CHECK expression itself
select * from pg_input_error_info('0', 'weirdfloat');
---END---
---START---
drop domain positiveint;
---END---
---START---
drop domain weirdfloat;
---END---
---START---
-- Test domains over array types

create domain domainint4arr int4[1];
---END---
---START---
create domain domainchar4arr varchar(4)[2][3];
---END---
---START---
CREATE TABLE domarrtest (_gemini_pk serial PRIMARY KEY, testint4arr domainint4arr, testchar4arr domainchar4arr);
---END---
---START---
INSERT INTO domarrtest values ('{2,2}', '{{"a","b"},{"c","d"}}');
---END---
---START---
INSERT INTO domarrtest values ('{{2,2},{2,2}}', '{{"a","b"}}');
---END---
---START---
INSERT INTO domarrtest values ('{2,2}', '{{"a","b"},{"c","d"},{"e","f"}}');
---END---
---START---
INSERT INTO domarrtest values ('{2,2}', '{{"a"},{"c"}}');
---END---
---START---
INSERT INTO domarrtest values (NULL, '{{"a","b","c"},{"d","e","f"}}');
---END---
---START---
INSERT INTO domarrtest values (NULL, '{{"toolong","b","c"},{"d","e","f"}}');
---END---
---START---
INSERT INTO domarrtest (testint4arr[1], testint4arr[3]) values (11,22);
---END---
---START---
select * from domarrtest;
---END---
---START---
select testint4arr[1], testchar4arr[2:2] from domarrtest;
---END---
---START---
select array_dims(testint4arr), array_dims(testchar4arr) from domarrtest;
---END---
---START---
COPY domarrtest FROM stdin;
{3,4}	{q,w,e}
\N	\N
\.
---END---
---START---
COPY domarrtest FROM stdin;	-- fail
{3,4}	{qwerty,w,e}
\.
---END---
---START---
select * from domarrtest;
---END---
---START---
update domarrtest set
  testint4arr[1] = testint4arr[1] + 1,
  testint4arr[3] = testint4arr[3] - 1
where testchar4arr is null;
---END---
---START---
select * from domarrtest where testchar4arr is null;
---END---
---START---
drop table domarrtest;
---END---
---START---
drop domain domainint4arr restrict;
---END---
---START---
drop domain domainchar4arr restrict;
---END---
---START---
create domain dia as int[];
---END---
---START---
select '{1,2,3}'::dia;
---END---
---START---
select array_dims('{1,2,3}'::dia);
---END---
---START---
select pg_typeof('{1,2,3}'::dia);
---END---
---START---
select pg_typeof('{1,2,3}'::dia || 42);
---END---
---START---
-- should be int[] not dia
drop domain dia;
---END---
---START---
-- Test domains over composites

create type comptype as (r float8, i float8);
---END---
---START---
create domain dcomptype as comptype;
---END---
---START---
CREATE TABLE dcomptable (_gemini_pk serial PRIMARY KEY, d1 dcomptype UNIQUE);
---END---
---START---
insert into dcomptable values (row(1,2)::dcomptype);
---END---
---START---
insert into dcomptable values (row(3,4)::comptype);
---END---
---START---
insert into dcomptable values (row(1,2)::dcomptype);
---END---
---START---
-- fail on uniqueness
insert into dcomptable (d1.r) values(11);
---END---
---START---
select * from dcomptable;
---END---
---START---
select (d1).r, (d1).i, (d1).* from dcomptable;
---END---
---START---
update dcomptable set d1.r = (d1).r + 1 where (d1).i > 0;
---END---
---START---
select * from dcomptable;
---END---
---START---
alter domain dcomptype add constraint c1 check ((value).r <= (value).i);
---END---
---START---
alter domain dcomptype add constraint c2 check ((value).r > (value).i);
---END---
---START---
-- fail

select row(2,1)::dcomptype;
---END---
---START---
-- fail
insert into dcomptable values (row(1,2)::comptype);
---END---
---START---
insert into dcomptable values (row(2,1)::comptype);
---END---
---START---
-- fail
insert into dcomptable (d1.r) values(99);
---END---
---START---
insert into dcomptable (d1.r, d1.i) values(99, 100);
---END---
---START---
insert into dcomptable (d1.r, d1.i) values(100, 99);
---END---
---START---
-- fail
update dcomptable set d1.r = (d1).r + 1 where (d1).i > 0;
---END---
---START---
-- fail
update dcomptable set d1.r = (d1).r - 1, d1.i = (d1).i + 1 where (d1).i > 0;
---END---
---START---
select * from dcomptable;
---END---
---START---
explain (verbose, costs off)
  update dcomptable set d1.r = (d1).r - 1, d1.i = (d1).i + 1 where (d1).i > 0;
---END---
---START---
create rule silly as on delete to dcomptable do instead
  update dcomptable set d1.r = (d1).r - 1, d1.i = (d1).i + 1 where (d1).i > 0;
---END---
---START---
\d+ dcomptable

create function makedcomp(r float8, i float8) returns dcomptype
as 'select row(r, i)' language sql;
---END---
---START---
select makedcomp(1,2);
---END---
---START---
select makedcomp(2,1);
---END---
---START---
-- fail
select * from makedcomp(1,2) m;
---END---
---START---
select m, m is not null from makedcomp(1,2) m;
---END---
---START---
drop function makedcomp(float8, float8);
---END---
---START---
drop table dcomptable;
---END---
---START---
drop type comptype cascade;
---END---
---START---
-- check altering and dropping columns used by domain constraints
create type comptype as (r float8, i float8);
---END---
---START---
create domain dcomptype as comptype;
---END---
---START---
alter domain dcomptype add constraint c1 check ((value).r > 0);
---END---
---START---
comment on constraint c1 on domain dcomptype is 'random commentary';
---END---
---START---
select row(0,1)::dcomptype;
---END---
---START---
-- fail

alter type comptype alter attribute r type varchar;
---END---
---START---
-- fail
alter type comptype alter attribute r type bigint;
---END---
---START---
alter type comptype drop attribute r;
---END---
---START---
-- fail
alter type comptype drop attribute i;
---END---
---START---
select conname, obj_description(oid, 'pg_constraint') from pg_constraint
  where contypid = 'dcomptype'::regtype;
---END---
---START---
-- check comment is still there

drop type comptype cascade;
---END---
---START---
-- Test domains over arrays of composite

create type comptype as (r float8, i float8);
---END---
---START---
create domain dcomptypea as comptype[];
---END---
---START---
CREATE TABLE dcomptable (_gemini_pk serial PRIMARY KEY, d1 dcomptypea UNIQUE);
---END---
---START---
insert into dcomptable values (array[row(1,2)]::dcomptypea);
---END---
---START---
insert into dcomptable values (array[row(3,4), row(5,6)]::comptype[]);
---END---
---START---
insert into dcomptable values (array[row(7,8)::comptype, row(9,10)::comptype]);
---END---
---START---
insert into dcomptable values (array[row(1,2)]::dcomptypea);
---END---
---START---
-- fail on uniqueness
insert into dcomptable (d1[1]) values(row(9,10));
---END---
---START---
insert into dcomptable (d1[1].r) values(11);
---END---
---START---
select * from dcomptable;
---END---
---START---
select d1[2], d1[1].r, d1[1].i from dcomptable;
---END---
---START---
update dcomptable set d1[2] = row(d1[2].i, d1[2].r);
---END---
---START---
select * from dcomptable;
---END---
---START---
update dcomptable set d1[1].r = d1[1].r + 1 where d1[1].i > 0;
---END---
---START---
select * from dcomptable;
---END---
---START---
alter domain dcomptypea add constraint c1 check (value[1].r <= value[1].i);
---END---
---START---
alter domain dcomptypea add constraint c2 check (value[1].r > value[1].i);
---END---
---START---
-- fail

select array[row(2,1)]::dcomptypea;
---END---
---START---
-- fail
insert into dcomptable values (array[row(1,2)]::comptype[]);
---END---
---START---
insert into dcomptable values (array[row(2,1)]::comptype[]);
---END---
---START---
-- fail
insert into dcomptable (d1[1].r) values(99);
---END---
---START---
insert into dcomptable (d1[1].r, d1[1].i) values(99, 100);
---END---
---START---
insert into dcomptable (d1[1].r, d1[1].i) values(100, 99);
---END---
---START---
-- fail
update dcomptable set d1[1].r = d1[1].r + 1 where d1[1].i > 0;
---END---
---START---
-- fail
update dcomptable set d1[1].r = d1[1].r - 1, d1[1].i = d1[1].i + 1
  where d1[1].i > 0;
---END---
---START---
select * from dcomptable;
---END---
---START---
explain (verbose, costs off)
  update dcomptable set d1[1].r = d1[1].r - 1, d1[1].i = d1[1].i + 1
    where d1[1].i > 0;
---END---
---START---
create rule silly as on delete to dcomptable do instead
  update dcomptable set d1[1].r = d1[1].r - 1, d1[1].i = d1[1].i + 1
    where d1[1].i > 0;
---END---
---START---
\d+ dcomptable

drop table dcomptable;
---END---
---START---
drop type comptype cascade;
---END---
---START---
-- Test arrays over domains

create domain posint as int check (value > 0);
---END---
---START---
CREATE TABLE pitable (_gemini_pk serial PRIMARY KEY, f1 posint[]);
---END---
---START---
insert into pitable values(array[42]);
---END---
---START---
insert into pitable values(array[-1]);
---END---
---START---
-- fail
insert into pitable values('{0}');
---END---
---START---
-- fail
update pitable set f1[1] = f1[1] + 1;
---END---
---START---
update pitable set f1[1] = 0;
---END---
---START---
-- fail
select * from pitable;
---END---
---START---
drop table pitable;
---END---
---START---
create domain vc4 as varchar(4);
---END---
---START---
CREATE TABLE vc4table (_gemini_pk serial PRIMARY KEY, f1 vc4[]);
---END---
---START---
insert into vc4table values(array['too long']);
---END---
---START---
-- fail
insert into vc4table values(array['too long']::vc4[]);
---END---
---START---
-- cast truncates
select * from vc4table;
---END---
---START---
drop table vc4table;
---END---
---START---
drop type vc4;
---END---
---START---
-- You can sort of fake arrays-of-arrays by putting a domain in between
create domain dposinta as posint[];
---END---
---START---
CREATE TABLE dposintatable (_gemini_pk serial PRIMARY KEY, f1 dposinta[]);
---END---
---START---
insert into dposintatable values(array[array[42]]);
---END---
---START---
-- fail
insert into dposintatable values(array[array[42]::posint[]]);
---END---
---START---
-- still fail
insert into dposintatable values(array[array[42]::dposinta]);
---END---
---START---
-- but this works
select f1, f1[1], (f1[1])[1] from dposintatable;
---END---
---START---
select pg_typeof(f1) from dposintatable;
---END---
---START---
select pg_typeof(f1[1]) from dposintatable;
---END---
---START---
select pg_typeof(f1[1][1]) from dposintatable;
---END---
---START---
select pg_typeof((f1[1])[1]) from dposintatable;
---END---
---START---
update dposintatable set f1[2] = array[99];
---END---
---START---
select f1, f1[1], (f1[2])[1] from dposintatable;
---END---
---START---
-- it'd be nice if you could do something like this, but for now you can't:
update dposintatable set f1[2][1] = array[97];
---END---
---START---
-- maybe someday we can make this syntax work:
update dposintatable set (f1[2])[1] = array[98];
---END---
---START---
drop table dposintatable;
---END---
---START---
drop domain posint cascade;
---END---
---START---
-- Test arrays over domains of composite

create type comptype as (cf1 int, cf2 int);
---END---
---START---
create domain dcomptype as comptype check ((value).cf1 > 0);
---END---
---START---
CREATE TABLE dcomptable (_gemini_pk serial PRIMARY KEY, f1 dcomptype[]);
---END---
---START---
insert into dcomptable values (null);
---END---
---START---
update dcomptable set f1[1].cf2 = 5;
---END---
---START---
table dcomptable;
---END---
---START---
update dcomptable set f1[1].cf1 = -1;
---END---
---START---
-- fail
update dcomptable set f1[1].cf1 = 1;
---END---
---START---
table dcomptable;
---END---
---START---
-- if there's no constraints, a different code path is taken:
alter domain dcomptype drop constraint dcomptype_check;
---END---
---START---
update dcomptable set f1[1].cf1 = -1;
---END---
---START---
-- now ok
table dcomptable;
---END---
---START---
drop table dcomptable;
---END---
---START---
drop type comptype cascade;
---END---
---START---
-- Test not-null restrictions

create domain dnotnull varchar(15) NOT NULL;
---END---
---START---
create domain dnull    varchar(15);
---END---
---START---
create domain dcheck   varchar(15) NOT NULL CHECK (VALUE = 'a' OR VALUE = 'c' OR VALUE = 'd');
---END---
---START---
CREATE TABLE nulltest (_gemini_pk serial PRIMARY KEY, col1 dnotnull, col2 dnotnull NULL, col3 dnull NOT NULL, col4 dnull, col5 dcheck CHECK (col5 IN ('c', 'd')));
---END---
---START---
INSERT INTO nulltest DEFAULT VALUES;
---END---
---START---
INSERT INTO nulltest values ('a', 'b', 'c', 'd', 'c');
---END---
---START---
-- Good
insert into nulltest values ('a', 'b', 'c', 'd', NULL);
---END---
---START---
insert into nulltest values ('a', 'b', 'c', 'd', 'a');
---END---
---START---
INSERT INTO nulltest values (NULL, 'b', 'c', 'd', 'd');
---END---
---START---
INSERT INTO nulltest values ('a', NULL, 'c', 'd', 'c');
---END---
---START---
INSERT INTO nulltest values ('a', 'b', NULL, 'd', 'c');
---END---
---START---
INSERT INTO nulltest values ('a', 'b', 'c', NULL, 'd');
---END---
---START---
COPY nulltest FROM stdin; --fail
a	b	\N	d	d
\.
---END---
---START---
COPY nulltest FROM stdin; --fail
a	b	c	d	\N
\.
---END---
---START---
COPY nulltest FROM stdin;
a	b	c	\N	c
a	b	c	\N	d
a	b	c	\N	a
\.
---END---
---START---
select * from nulltest;
---END---
---START---
-- Test out coerced (casted) constraints
SELECT cast('1' as dnotnull);
---END---
---START---
SELECT cast(NULL as dnotnull);
---END---
---START---
-- fail
SELECT cast(cast(NULL as dnull) as dnotnull);
---END---
---START---
-- fail
SELECT cast(col4 as dnotnull) from nulltest;
---END---
---START---
-- fail

-- cleanup
drop table nulltest;
---END---
---START---
drop domain dnotnull restrict;
---END---
---START---
drop domain dnull restrict;
---END---
---START---
drop domain dcheck restrict;
---END---
---START---
create domain ddef1 int4 DEFAULT 3;
---END---
---START---
create domain ddef2 oid DEFAULT '12';
---END---
---START---
-- Type mixing, function returns int8
create domain ddef3 text DEFAULT 5;
---END---
---START---
create sequence ddef4_seq;
---END---
---START---
create domain ddef4 int4 DEFAULT nextval('ddef4_seq');
---END---
---START---
create domain ddef5 numeric(8,2) NOT NULL DEFAULT '12.12';
---END---
---START---
create table defaulttest
            ( col1 ddef1
            , col2 ddef2
            , col3 ddef3
            , col4 ddef4 PRIMARY KEY
            , col5 ddef1 NOT NULL DEFAULT NULL
            , col6 ddef2 DEFAULT '88'
            , col7 ddef4 DEFAULT 8000
            , col8 ddef5
            );
---END---
---START---
insert into defaulttest(col4) values(0);
---END---
---START---
-- fails, col5 defaults to null
alter table defaulttest alter column col5 drop default;
---END---
---START---
insert into defaulttest default values;
---END---
---START---
-- succeeds, inserts domain default
-- We used to treat SET DEFAULT NULL as equivalent to DROP DEFAULT; wrong
alter table defaulttest alter column col5 set default null;
---END---
---START---
insert into defaulttest(col4) values(0);
---END---
---START---
-- fails
alter table defaulttest alter column col5 drop default;
---END---
---START---
insert into defaulttest default values;
---END---
---START---
insert into defaulttest default values;
---END---
---START---
COPY defaulttest(col5) FROM stdin;
42
\.
---END---
---START---
select * from defaulttest;
---END---
---START---
drop table defaulttest cascade;
---END---
---START---
-- Test ALTER DOMAIN .. NOT NULL
create domain dnotnulltest integer;
---END---
---START---
CREATE TABLE domnotnull (_gemini_pk serial PRIMARY KEY, col1 dnotnulltest, col2 dnotnulltest);
---END---
---START---
insert into domnotnull default values;
---END---
---START---
alter domain dnotnulltest set not null;
---END---
---START---
-- fails

update domnotnull set col1 = 5;
---END---
---START---
alter domain dnotnulltest set not null;
---END---
---START---
-- fails

update domnotnull set col2 = 6;
---END---
---START---
alter domain dnotnulltest set not null;
---END---
---START---
update domnotnull set col1 = null;
---END---
---START---
-- fails

alter domain dnotnulltest drop not null;
---END---
---START---
update domnotnull set col1 = null;
---END---
---START---
drop domain dnotnulltest cascade;
---END---
---START---
CREATE TABLE domdeftest (_gemini_pk serial PRIMARY KEY, col1 ddef1);
---END---
---START---
insert into domdeftest default values;
---END---
---START---
select * from domdeftest;
---END---
---START---
alter domain ddef1 set default '42';
---END---
---START---
insert into domdeftest default values;
---END---
---START---
select * from domdeftest;
---END---
---START---
alter domain ddef1 drop default;
---END---
---START---
insert into domdeftest default values;
---END---
---START---
select * from domdeftest;
---END---
---START---
drop table domdeftest;
---END---
---START---
-- Test ALTER DOMAIN .. CONSTRAINT ..
create domain con as integer;
---END---
---START---
CREATE TABLE domcontest (_gemini_pk serial PRIMARY KEY, col1 con);
---END---
---START---
insert into domcontest values (1);
---END---
---START---
insert into domcontest values (2);
---END---
---START---
alter domain con add constraint t check (VALUE < 1);
---END---
---START---
-- fails

alter domain con add constraint t check (VALUE < 34);
---END---
---START---
alter domain con add check (VALUE > 0);
---END---
---START---
insert into domcontest values (-5);
---END---
---START---
-- fails
insert into domcontest values (42);
---END---
---START---
-- fails
insert into domcontest values (5);
---END---
---START---
alter domain con drop constraint t;
---END---
---START---
insert into domcontest values (-5);
---END---
---START---
--fails
insert into domcontest values (42);
---END---
---START---
alter domain con drop constraint nonexistent;
---END---
---START---
alter domain con drop constraint if exists nonexistent;
---END---
---START---
-- Test ALTER DOMAIN .. CONSTRAINT .. NOT VALID
create domain things AS INT;
---END---
---START---
CREATE TABLE thethings (_gemini_pk serial PRIMARY KEY, stuff things);
---END---
---START---
INSERT INTO thethings (stuff) VALUES (55);
---END---
---START---
ALTER DOMAIN things ADD CONSTRAINT meow CHECK (VALUE < 11);
---END---
---START---
ALTER DOMAIN things ADD CONSTRAINT meow CHECK (VALUE < 11) NOT VALID;
---END---
---START---
ALTER DOMAIN things VALIDATE CONSTRAINT meow;
---END---
---START---
UPDATE thethings SET stuff = 10;
---END---
---START---
ALTER DOMAIN things VALIDATE CONSTRAINT meow;
---END---
---START---
CREATE TABLE domtab (_gemini_pk serial PRIMARY KEY, col1 integer);
---END---
---START---
create domain dom as integer;
---END---
---START---
create view domview as select cast(col1 as dom) from domtab;
---END---
---START---
insert into domtab (col1) values (null);
---END---
---START---
insert into domtab (col1) values (5);
---END---
---START---
select * from domview;
---END---
---START---
alter domain dom set not null;
---END---
---START---
select * from domview;
---END---
---START---
-- fail

alter domain dom drop not null;
---END---
---START---
select * from domview;
---END---
---START---
alter domain dom add constraint domchkgt6 check(value > 6);
---END---
---START---
select * from domview;
---END---
---START---
--fail

alter domain dom drop constraint domchkgt6 restrict;
---END---
---START---
select * from domview;
---END---
---START---
-- cleanup
drop domain ddef1 restrict;
---END---
---START---
drop domain ddef2 restrict;
---END---
---START---
drop domain ddef3 restrict;
---END---
---START---
drop domain ddef4 restrict;
---END---
---START---
drop domain ddef5 restrict;
---END---
---START---
drop sequence ddef4_seq;
---END---
---START---
-- Test domains over domains
create domain vchar4 varchar(4);
---END---
---START---
create domain dinter vchar4 check (substring(VALUE, 1, 1) = 'x');
---END---
---START---
create domain dtop dinter check (substring(VALUE, 2, 1) = '1');
---END---
---START---
select 'x123'::dtop;
---END---
---START---
select 'x1234'::dtop;
---END---
---START---
-- explicit coercion should truncate
select 'y1234'::dtop;
---END---
---START---
-- fail
select 'y123'::dtop;
---END---
---START---
-- fail
select 'yz23'::dtop;
---END---
---START---
-- fail
select 'xz23'::dtop;
---END---
---START---
-- fail

DROP TABLE IF EXISTS dtest;

CREATE TABLE dtest (_gemini_pk serial PRIMARY KEY, f1 dtop);
---END---
---START---
insert into dtest values('x123');
---END---
---START---
insert into dtest values('x1234');
---END---
---START---
-- fail, implicit coercion
insert into dtest values('y1234');
---END---
---START---
-- fail, implicit coercion
insert into dtest values('y123');
---END---
---START---
-- fail
insert into dtest values('yz23');
---END---
---START---
-- fail
insert into dtest values('xz23');
---END---
---START---
-- fail

drop table dtest;
---END---
---START---
drop domain vchar4 cascade;
---END---
---START---
-- Make sure that constraints of newly-added domain columns are
-- enforced correctly, even if there's no default value for the new
-- column. Per bug #1433
create domain str_domain as text not null;
---END---
---START---
CREATE TABLE domain_test (_gemini_pk serial PRIMARY KEY, a integer, b integer);
---END---
---START---
insert into domain_test values (1, 2);
---END---
---START---
insert into domain_test values (1, 2);
---END---
---START---
-- should fail
alter table domain_test add column c str_domain;
---END---
---START---
create domain str_domain2 as text check (value <> 'foo') default 'foo';
---END---
---START---
-- should fail
alter table domain_test add column d str_domain2;
---END---
---START---
-- Check that domain constraints on prepared statement parameters of
-- unknown type are enforced correctly.
create domain pos_int as int4 check (value > 0) not null;
---END---
---START---
prepare s1 as select $1::pos_int = 10 as "is_ten";
---END---
---START---
execute s1(10);
---END---
---START---
execute s1(0);
---END---
---START---
-- should fail
execute s1(NULL);
---END---
---START---
-- should fail

-- Check that domain constraints on plpgsql function parameters, results,
-- and local variables are enforced correctly.

create function doubledecrement(p1 pos_int) returns pos_int as $$
declare v pos_int;
begin
    return p1;
end$$ language plpgsql;
---END---
---START---
select doubledecrement(3);
---END---
---START---
-- fail because of implicit null assignment

create or replace function doubledecrement(p1 pos_int) returns pos_int as $$
declare v pos_int := 0;
begin
    return p1;
end$$ language plpgsql;
---END---
---START---
select doubledecrement(3);
---END---
---START---
-- fail at initialization assignment

create or replace function doubledecrement(p1 pos_int) returns pos_int as $$
declare v pos_int := 1;
begin
    v := p1 - 1;
    return v - 1;
end$$ language plpgsql;
---END---
---START---
select doubledecrement(null);
---END---
---START---
-- fail before call
select doubledecrement(0);
---END---
---START---
-- fail before call
select doubledecrement(1);
---END---
---START---
-- fail at assignment to v
select doubledecrement(2);
---END---
---START---
-- fail at return
select doubledecrement(3);
---END---
---START---
-- good

-- Check that ALTER DOMAIN tests columns of derived types

create domain posint as int4;
---END---
---START---
-- Currently, this doesn't work for composite types, but verify it complains
create type ddtest1 as (f1 posint);
---END---
---START---
CREATE TABLE ddtest2 (_gemini_pk serial PRIMARY KEY, f1 ddtest1);
---END---
---START---
insert into ddtest2 values(row(-1));
---END---
---START---
alter domain posint add constraint c1 check(value >= 0);
---END---
---START---
drop table ddtest2;
---END---
---START---
CREATE TABLE ddtest2 (_gemini_pk serial PRIMARY KEY, f1 ddtest1[]);
---END---
---START---
insert into ddtest2 values('{(-1)}');
---END---
---START---
alter domain posint add constraint c1 check(value >= 0);
---END---
---START---
drop table ddtest2;
---END---
---START---
-- Likewise for domains within domains over composite
create domain ddtest1d as ddtest1;
---END---
---START---
CREATE TABLE ddtest2 (_gemini_pk serial PRIMARY KEY, f1 ddtest1d);
---END---
---START---
insert into ddtest2 values('(-1)');
---END---
---START---
alter domain posint add constraint c1 check(value >= 0);
---END---
---START---
drop table ddtest2;
---END---
---START---
drop domain ddtest1d;
---END---
---START---
-- Likewise for domains within domains over array of composite
create domain ddtest1d as ddtest1[];
---END---
---START---
CREATE TABLE ddtest2 (_gemini_pk serial PRIMARY KEY, f1 ddtest1d);
---END---
---START---
insert into ddtest2 values('{(-1)}');
---END---
---START---
alter domain posint add constraint c1 check(value >= 0);
---END---
---START---
drop table ddtest2;
---END---
---START---
drop domain ddtest1d;
---END---
---START---
-- Doesn't work for ranges, either
create type rposint as range (subtype = posint);
---END---
---START---
CREATE TABLE ddtest2 (_gemini_pk serial PRIMARY KEY, f1 rposint);
---END---
---START---
insert into ddtest2 values('(-1,3]');
---END---
---START---
alter domain posint add constraint c1 check(value >= 0);
---END---
---START---
drop table ddtest2;
---END---
---START---
drop type rposint;
---END---
---START---
alter domain posint add constraint c1 check(value >= 0);
---END---
---START---
create domain posint2 as posint check (value % 2 = 0);
---END---
---START---
CREATE TABLE ddtest2 (_gemini_pk serial PRIMARY KEY, f1 posint2);
---END---
---START---
insert into ddtest2 values(11);
---END---
---START---
-- fail
insert into ddtest2 values(-2);
---END---
---START---
-- fail
insert into ddtest2 values(2);
---END---
---START---
alter domain posint add constraint c2 check(value >= 10);
---END---
---START---
-- fail
alter domain posint add constraint c2 check(value > 0);
---END---
---START---
-- OK

drop table ddtest2;
---END---
---START---
drop type ddtest1;
---END---
---START---
drop domain posint cascade;
---END---
---START---
--
-- Check enforcement of domain-related typmod in plpgsql (bug #5717)
--

create or replace function array_elem_check(numeric) returns numeric as $$
declare
  x numeric(4,2)[1];
begin
  x[1] := $1;
  return x[1];
end$$ language plpgsql;
---END---
---START---
select array_elem_check(121.00);
---END---
---START---
select array_elem_check(1.23456);
---END---
---START---
create domain mynums as numeric(4,2)[1];
---END---
---START---
create or replace function array_elem_check(numeric) returns numeric as $$
declare
  x mynums;
begin
  x[1] := $1;
  return x[1];
end$$ language plpgsql;
---END---
---START---
select array_elem_check(121.00);
---END---
---START---
select array_elem_check(1.23456);
---END---
---START---
create domain mynums2 as mynums;
---END---
---START---
create or replace function array_elem_check(numeric) returns numeric as $$
declare
  x mynums2;
begin
  x[1] := $1;
  return x[1];
end$$ language plpgsql;
---END---
---START---
select array_elem_check(121.00);
---END---
---START---
select array_elem_check(1.23456);
---END---
---START---
drop function array_elem_check(numeric);
---END---
---START---
--
-- Check enforcement of array-level domain constraints
--

create domain orderedpair as int[2] check (value[1] < value[2]);
---END---
---START---
select array[1,2]::orderedpair;
---END---
---START---
select array[2,1]::orderedpair;
---END---
---START---
-- fail

DROP TABLE IF EXISTS op;

CREATE TABLE op (_gemini_pk serial PRIMARY KEY, f1 orderedpair);
---END---
---START---
insert into op values (array[1,2]);
---END---
---START---
insert into op values (array[2,1]);
---END---
---START---
-- fail

update op set f1[2] = 3;
---END---
---START---
update op set f1[2] = 0;
---END---
---START---
-- fail
select * from op;
---END---
---START---
create or replace function array_elem_check(int) returns int as $$
declare
  x orderedpair := '{1,2}';
begin
  x[2] := $1;
  return x[2];
end$$ language plpgsql;
---END---
---START---
select array_elem_check(3);
---END---
---START---
select array_elem_check(-1);
---END---
---START---
drop function array_elem_check(int);
---END---
---START---
--
-- Check enforcement of changing constraints in plpgsql
--

create domain di as int;
---END---
---START---
create function dom_check(int) returns di as $$
declare d di;
begin
  d := $1::di;
  return d;
end
$$ language plpgsql immutable;
---END---
---START---
select dom_check(0);
---END---
---START---
alter domain di add constraint pos check (value > 0);
---END---
---START---
select dom_check(0);
---END---
---START---
-- fail

alter domain di drop constraint pos;
---END---
---START---
select dom_check(0);
---END---
---START---
-- implicit cast during assignment is a separate code path, test that too

create or replace function dom_check(int) returns di as $$
declare d di;
begin
  d := $1;
  return d;
end
$$ language plpgsql immutable;
---END---
---START---
select dom_check(0);
---END---
---START---
alter domain di add constraint pos check (value > 0);
---END---
---START---
select dom_check(0);
---END---
---START---
-- fail

alter domain di drop constraint pos;
---END---
---START---
select dom_check(0);
---END---
---START---
drop function dom_check(int);
---END---
---START---
drop domain di;
---END---
---START---
--
-- Check use of a (non-inline-able) SQL function in a domain constraint;
-- this has caused issues in the past
--

create function sql_is_distinct_from(anyelement, anyelement)
returns boolean language sql
as 'select $1 is distinct from $2 limit 1';
---END---
---START---
create domain inotnull int
  check (sql_is_distinct_from(value, null));
---END---
---START---
select 1::inotnull;
---END---
---START---
select null::inotnull;
---END---
---START---
CREATE TABLE dom_table (_gemini_pk serial PRIMARY KEY, x inotnull);
---END---
---START---
insert into dom_table values ('1');
---END---
---START---
insert into dom_table values (1);
---END---
---START---
insert into dom_table values (null);
---END---
---START---
drop table dom_table;
---END---
---START---
drop domain inotnull;
---END---
---START---
drop function sql_is_distinct_from(anyelement, anyelement);
---END---
---START---
--
-- Renaming
--

create domain testdomain1 as int;
---END---
---START---
alter domain testdomain1 rename to testdomain2;
---END---
---START---
alter type testdomain2 rename to testdomain3;
---END---
---START---
-- alter type also works
drop domain testdomain3;
---END---
---START---
--
-- Renaming domain constraints
--

create domain testdomain1 as int constraint unsigned check (value > 0);
---END---
---START---
alter domain testdomain1 rename constraint unsigned to unsigned_foo;
---END---
---START---
alter domain testdomain1 drop constraint unsigned_foo;
---END---
---START---
drop domain testdomain1;
---END---
