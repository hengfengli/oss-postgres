---START---
--
-- COPY
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR
\getenv abs_builddir PG_ABS_BUILDDIR

--- test copying in CSV mode with various styles
--- of embedded line ending characters

DROP TABLE IF EXISTS copytest;
create table copytest (
	style	text,
	test 	text,
	filler	int);
---END---
---START---
insert into copytest values('DOS',E'abc\r\ndef',1);
---END---
---START---
insert into copytest values('Unix',E'abc\ndef',2);
---END---
---START---
insert into copytest values('Mac',E'abc\rdef',3);
---END---
---START---
insert into copytest values(E'esc\\ape',E'a\\r\\\r\\\n\\nb',4);
---END---
---START---
\set filename :abs_builddir '/results/copytest.csv';
---END---
---START---
copy copytest to :'filename' csv;

DROP TABLE IF EXISTS copytest2;
create table copytest2 (like copytest);

copy copytest2 from :'filename' csv;
---END---
---START---
select * from copytest except select * from copytest2;
---END---
---START---
truncate copytest2;
---END---
---START---
--- same test but with an escape char different from quote char

copy copytest to :'filename' csv quote '''' escape E'\\';
---END---
---START---
copy copytest2 from :'filename' csv quote '''' escape E'\\';
---END---
---START---
select * from copytest except select * from copytest2;
---END---
---START---

-- test header line feature

DROP TABLE IF EXISTS copytest3;
create table copytest3 (
	c1 int,
	"col with , comma" text,
	"col with "" quote"  int);
---END---
---START---
copy copytest3 from stdin csv header;
this is just a line full of junk that would error out if parsed
1,a,1
2,b,2
\.
---END---
---START---
copy copytest3 to stdout csv header;

DROP TABLE IF EXISTS copytest4;
create table copytest4 (
	c1 int,
	"colname with tab: 	" text);
---END---
---START---
copy copytest4 from stdin (header);
this is just a line full of junk that would error out if parsed
1	a
2	b
\.
---END---
---START---
copy copytest4 to stdout (header);
---END---
---START---
-- test copy from with a partitioned table
create table parted_copytest (
	a int,
	b int,
	c text
) partition by list (b);
---END---
---START---
create table parted_copytest_a1 (c text, b int, a int);
---END---
---START---
create table parted_copytest_a2 (a int, c text, b int);
---END---
---START---
alter table parted_copytest attach partition parted_copytest_a1 for values in(1);
---END---
---START---
alter table parted_copytest attach partition parted_copytest_a2 for values in(2);
---END---
---START---
-- We must insert enough rows to trigger multi-inserts.  These are only
-- enabled adaptively when there are few enough partition changes.
insert into parted_copytest select x,1,'One' from generate_series(1,1000) x;
---END---
---START---
insert into parted_copytest select x,2,'Two' from generate_series(1001,1010) x;
---END---
---START---
insert into parted_copytest select x,1,'One' from generate_series(1011,1020) x;
---END---
---START---
\set filename :abs_builddir '/results/parted_copytest.csv'
---END---
---START---
copy (select * from parted_copytest order by a) to :'filename';
---END---
---START---
truncate parted_copytest;
---END---
---START---
copy parted_copytest from :'filename';
---END---
---START---
-- Ensure COPY FREEZE errors for partitioned tables.
begin;
truncate parted_copytest;
copy parted_copytest from :'filename' (freeze);
rollback;
---END---
---START---
select tableoid::regclass,count(*),sum(a) from parted_copytest
group by tableoid order by tableoid::regclass::name;
---END---
---START---
truncate parted_copytest;
---END---
---START---
-- create before insert row trigger on parted_copytest_a2
create function part_ins_func() returns trigger language plpgsql as $$
begin
  return new;
end;
$$;
---END---
---START---
create trigger part_ins_trig
	before insert on parted_copytest_a2
	for each row
	execute procedure part_ins_func();
---END---
---START---
copy parted_copytest from :'filename';
---END---
---START---
select tableoid::regclass,count(*),sum(a) from parted_copytest
group by tableoid order by tableoid::regclass::name;
---END---
---START---
truncate table parted_copytest;
---END---
---START---
create index on parted_copytest (b);
---END---
---START---
drop trigger part_ins_trig on parted_copytest_a2;
---END---
---START---
copy parted_copytest from stdin;
1	1	str1
2	2	str2
\.
---END---
---START---
-- Ensure index entries were properly added during the copy.
select * from parted_copytest where b = 1;
---END---
---START---
select * from parted_copytest where b = 2;
---END---
---START---
drop table parted_copytest;
---END---
---START---
CREATE TABLE tab_progress_reporting (_gemini_pk serial PRIMARY KEY, name text, age int4, location point, salary int4, manager name);
---END---
---START---
-- Add a trigger to catch and print the contents of the catalog view
-- pg_stat_progress_copy during data insertion.  This allows to test
-- the validation of some progress reports for COPY FROM where the trigger
-- would fire.
create function notice_after_tab_progress_reporting() returns trigger AS
$$
declare report record;
begin
  -- The fields ignored here are the ones that may not remain
  -- consistent across multiple runs.  The sizes reported may differ
  -- across platforms, so just check if these are strictly positive.
  with progress_data as (
    select
       relid::regclass::text as relname,
       command,
       type,
       bytes_processed > 0 as has_bytes_processed,
       bytes_total > 0 as has_bytes_total,
       tuples_processed,
       tuples_excluded
      from pg_stat_progress_copy
      where pid = pg_backend_pid())
  select into report (to_jsonb(r)) as value
    from progress_data r;

  raise info 'progress: %', report.value::text;
  return new;
end;
$$ language plpgsql;
---END---
---START---
create trigger check_after_tab_progress_reporting
	after insert on tab_progress_reporting
	for each statement
	execute function notice_after_tab_progress_reporting();
---END---
---START---
-- Generate COPY FROM report with PIPE.
copy tab_progress_reporting from stdin;
sharon	25	(15,12)	1000	sam
sam	30	(10,5)	2000	bill
bill	20	(11,10)	1000	sharon
\.
---END---
---START---
-- Generate COPY FROM report with FILE, with some excluded tuples.
truncate tab_progress_reporting;
---END---
---START---
\set filename :abs_srcdir '/data/emp.data'
---END---
---START---
copy tab_progress_reporting from :'filename'
	where (salary < 2000);
---END---
---START---
drop trigger check_after_tab_progress_reporting on tab_progress_reporting;
---END---
---START---
drop function notice_after_tab_progress_reporting();
---END---
---START---
drop table tab_progress_reporting;
---END---
---START---
-- Test header matching feature
create table header_copytest (
	a int,
	b int,
	c text
);
---END---
---START---
-- Make sure it works with dropped columns
alter table header_copytest drop column c;
---END---
---START---
alter table header_copytest add column c text;
---END---
---START---
copy header_copytest to stdout with (header match);
---END---
---START---
copy header_copytest from stdin with (header wrong_choice);
---END---
---START---
-- works
copy header_copytest from stdin with (header match);
a	b	c
1	2	foo
\.
---END---
---START---
copy header_copytest (c, a, b) from stdin with (header match);
c	a	b
bar	3	4
\.
---END---
---START---
copy header_copytest from stdin with (header match, format csv);
a,b,c
5,6,baz
\.
---END---
---START---
copy header_copytest (c, b, a) from stdin with (header match);
a	b	c
1	2	foo
\.
---END---
---START---
copy header_copytest from stdin with (header match);
a	b	\N
1	2	foo
\.
---END---
---START---
copy header_copytest from stdin with (header match);
a	b
1	2
\.
---END---
---START---
copy header_copytest from stdin with (header match);
a	b	c	d
1	2	foo	bar
\.
---END---
---START---
copy header_copytest from stdin with (header match);
a	b	d
1	2	foo
\.
---END---
---START---
SELECT * FROM header_copytest ORDER BY a;
---END---
---START---
-- Drop an extra column, in the middle of the existing set.
alter table header_copytest drop column b;
---END---
---START---
copy header_copytest (c, a) from stdin with (header match);
c	a
foo	7
\.
---END---
---START---
copy header_copytest (a, c) from stdin with (header match);
a	c
8	foo
\.
---END---
---START---
copy header_copytest from stdin with (header match);
a	........pg.dropped.2........	c
1	2	foo
\.
---END---
---START---
copy header_copytest (a, c) from stdin with (header match);
a	c	b
1	foo	2
\.
---END---
---START---
SELECT * FROM header_copytest ORDER BY a;
---END---
---START---
drop table header_copytest;
---END---
