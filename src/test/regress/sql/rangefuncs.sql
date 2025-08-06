---START---
CREATE TABLE rngfunc2(rngfuncid int, f2 int);
---END---
---START---
INSERT INTO rngfunc2 VALUES(1, 11);
---END---
---START---
INSERT INTO rngfunc2 VALUES(2, 22);
---END---
---START---
INSERT INTO rngfunc2 VALUES(1, 111);
---END---
---START---

CREATE FUNCTION rngfunct(int) returns setof rngfunc2 as 'SELECT * FROM rngfunc2 WHERE rngfuncid = $1 ORDER BY f2;' LANGUAGE SQL;
---END---
---START---

-- function with ORDINALITY
select * from rngfunct(1) with ordinality as z(a,b,ord);
---END---
---START---
select * from rngfunct(1) with ordinality as z(a,b,ord) where b > 100;   -- ordinal 2, not 1
-- ordinality vs. column names and types
select a,b,ord from rngfunct(1) with ordinality as z(a,b,ord);
---END---
---START---
select a,ord from unnest(array['a','b']) with ordinality as z(a,ord);
---END---
---START---
select * from unnest(array['a','b']) with ordinality as z(a,ord);
---END---
---START---
select a,ord from unnest(array[1.0::float8]) with ordinality as z(a,ord);
---END---
---START---
select * from unnest(array[1.0::float8]) with ordinality as z(a,ord);
---END---
---START---
select row_to_json(s.*) from generate_series(11,14) with ordinality s;
---END---
---START---
-- ordinality vs. views
create temporary view vw_ord as select * from (values (1)) v(n) join rngfunct(1) with ordinality as z(a,b,ord) on (n=ord);
---END---
---START---
select * from vw_ord;
---END---
---START---
select definition from pg_views where viewname='vw_ord';
---END---
---START---
drop view vw_ord;
---END---
---START---

-- multiple functions
select * from rows from(rngfunct(1),rngfunct(2)) with ordinality as z(a,b,c,d,ord);
---END---
---START---
create temporary view vw_ord as select * from (values (1)) v(n) join rows from(rngfunct(1),rngfunct(2)) with ordinality as z(a,b,c,d,ord) on (n=ord);
---END---
---START---
select * from vw_ord;
---END---
---START---
select definition from pg_views where viewname='vw_ord';
---END---
---START---
drop view vw_ord;
---END---
---START---

-- expansions of unnest()
select * from unnest(array[10,20],array['foo','bar'],array[1.0]);
---END---
---START---
select * from unnest(array[10,20],array['foo','bar'],array[1.0]) with ordinality as z(a,b,c,ord);
---END---
---START---
select * from rows from(unnest(array[10,20],array['foo','bar'],array[1.0])) with ordinality as z(a,b,c,ord);
---END---
---START---
select * from rows from(unnest(array[10,20],array['foo','bar']), generate_series(101,102)) with ordinality as z(a,b,c,ord);
---END---
---START---
create temporary view vw_ord as select * from unnest(array[10,20],array['foo','bar'],array[1.0]) as z(a,b,c);
---END---
---START---
select * from vw_ord;
---END---
---START---
select definition from pg_views where viewname='vw_ord';
---END---
---START---
drop view vw_ord;
---END---
---START---
create temporary view vw_ord as select * from rows from(unnest(array[10,20],array['foo','bar'],array[1.0])) as z(a,b,c);
---END---
---START---
select * from vw_ord;
---END---
---START---
select definition from pg_views where viewname='vw_ord';
---END---
---START---
drop view vw_ord;
---END---
---START---
create temporary view vw_ord as select * from rows from(unnest(array[10,20],array['foo','bar']), generate_series(1,2)) as z(a,b,c);
---END---
---START---
select * from vw_ord;
---END---
---START---
select definition from pg_views where viewname='vw_ord';
---END---
---START---
drop view vw_ord;
---END---
---START---

-- ordinality and multiple functions vs. rewind and reverse scan
begin;
---END---
---START---
declare rf_cur scroll cursor for select * from rows from(generate_series(1,5),generate_series(1,2)) with ordinality as g(i,j,o);
---END---
---START---
fetch all from rf_cur;
---END---
---START---
fetch backward all from rf_cur;
---END---
---START---
fetch all from rf_cur;
---END---
---START---
fetch next from rf_cur;
---END---
---START---
fetch next from rf_cur;
---END---
---START---
fetch prior from rf_cur;
---END---
---START---
fetch absolute 1 from rf_cur;
---END---
---START---
fetch next from rf_cur;
---END---
---START---
fetch next from rf_cur;
---END---
---START---
fetch next from rf_cur;
---END---
---START---
fetch prior from rf_cur;
---END---
---START---
fetch prior from rf_cur;
---END---
---START---
fetch prior from rf_cur;
---END---
---START---
commit;
---END---
---START---

-- function with implicit LATERAL
select * from rngfunc2, rngfunct(rngfunc2.rngfuncid) z where rngfunc2.f2 = z.f2;
---END---
---START---

-- function with implicit LATERAL and explicit ORDINALITY
select * from rngfunc2, rngfunct(rngfunc2.rngfuncid) with ordinality as z(rngfuncid,f2,ord) where rngfunc2.f2 = z.f2;
---END---
---START---

-- function in subselect
select * from rngfunc2 where f2 in (select f2 from rngfunct(rngfunc2.rngfuncid) z where z.rngfuncid = rngfunc2.rngfuncid) ORDER BY 1,2;
---END---
---START---

-- function in subselect
select * from rngfunc2 where f2 in (select f2 from rngfunct(1) z where z.rngfuncid = rngfunc2.rngfuncid) ORDER BY 1,2;
---END---
---START---

-- function in subselect
select * from rngfunc2 where f2 in (select f2 from rngfunct(rngfunc2.rngfuncid) z where z.rngfuncid = 1) ORDER BY 1,2;
---END---
---START---

-- nested functions
select rngfunct.rngfuncid, rngfunct.f2 from rngfunct(sin(pi()/2)::int) ORDER BY 1,2;
---END---
---START---

CREATE TABLE rngfunc (rngfuncid int, rngfuncsubid int, rngfuncname text, primary key(rngfuncid,rngfuncsubid));
---END---
---START---
INSERT INTO rngfunc VALUES(1,1,'Joe');
---END---
---START---
INSERT INTO rngfunc VALUES(1,2,'Ed');
---END---
---START---
INSERT INTO rngfunc VALUES(2,1,'Mary');
---END---
---START---

-- sql, proretset = f, prorettype = b
CREATE FUNCTION getrngfunc1(int) RETURNS int AS 'SELECT $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc1(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc1(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc1(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc1(1) WITH ORDINALITY as t1(v,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- sql, proretset = t, prorettype = b
CREATE FUNCTION getrngfunc2(int) RETURNS setof int AS 'SELECT rngfuncid FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc2(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc2(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc2(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc2(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- sql, proretset = t, prorettype = b
CREATE FUNCTION getrngfunc3(int) RETURNS setof text AS 'SELECT rngfuncname FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc3(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc3(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc3(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc3(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- sql, proretset = f, prorettype = c
CREATE FUNCTION getrngfunc4(int) RETURNS rngfunc AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc4(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc4(1) WITH ORDINALITY AS t1(a,b,c,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc4(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc4(1) WITH ORDINALITY AS t1(a,b,c,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- sql, proretset = t, prorettype = c
CREATE FUNCTION getrngfunc5(int) RETURNS setof rngfunc AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc5(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc5(1) WITH ORDINALITY AS t1(a,b,c,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc5(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc5(1) WITH ORDINALITY AS t1(a,b,c,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- sql, proretset = f, prorettype = record
CREATE FUNCTION getrngfunc6(int) RETURNS RECORD AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc6(1) AS t1(rngfuncid int, rngfuncsubid int, rngfuncname text);
---END---
---START---
SELECT * FROM ROWS FROM( getrngfunc6(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text) ) WITH ORDINALITY;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc6(1) AS
(rngfuncid int, rngfuncsubid int, rngfuncname text);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS
  SELECT * FROM ROWS FROM( getrngfunc6(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text) )
                WITH ORDINALITY;
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- sql, proretset = t, prorettype = record
CREATE FUNCTION getrngfunc7(int) RETURNS setof record AS 'SELECT * FROM rngfunc WHERE rngfuncid = $1;' LANGUAGE SQL;
---END---
---START---
SELECT * FROM getrngfunc7(1) AS t1(rngfuncid int, rngfuncsubid int, rngfuncname text);
---END---
---START---
SELECT * FROM ROWS FROM( getrngfunc7(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text) ) WITH ORDINALITY;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc7(1) AS
(rngfuncid int, rngfuncsubid int, rngfuncname text);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS
  SELECT * FROM ROWS FROM( getrngfunc7(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text) )
                WITH ORDINALITY;
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- plpgsql, proretset = f, prorettype = b
CREATE FUNCTION getrngfunc8(int) RETURNS int AS 'DECLARE rngfuncint int; BEGIN SELECT rngfuncid into rngfuncint FROM rngfunc WHERE rngfuncid = $1; RETURN rngfuncint; END;' LANGUAGE plpgsql;
---END---
---START---
SELECT * FROM getrngfunc8(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc8(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc8(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc8(1) WITH ORDINALITY AS t1(v,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- plpgsql, proretset = f, prorettype = c
CREATE FUNCTION getrngfunc9(int) RETURNS rngfunc AS 'DECLARE rngfunctup rngfunc%ROWTYPE; BEGIN SELECT * into rngfunctup FROM rngfunc WHERE rngfuncid = $1; RETURN rngfunctup; END;' LANGUAGE plpgsql;
---END---
---START---
SELECT * FROM getrngfunc9(1) AS t1;
---END---
---START---
SELECT * FROM getrngfunc9(1) WITH ORDINALITY AS t1(a,b,c,o);
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc9(1);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---
CREATE VIEW vw_getrngfunc AS SELECT * FROM getrngfunc9(1) WITH ORDINALITY AS t1(a,b,c,o);
---END---
---START---
SELECT * FROM vw_getrngfunc;
---END---
---START---
DROP VIEW vw_getrngfunc;
---END---
---START---

-- mix 'n match kinds, to exercise expandRTE and related logic

select * from rows from(getrngfunc1(1),getrngfunc2(1),getrngfunc3(1),getrngfunc4(1),getrngfunc5(1),
                    getrngfunc6(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
                    getrngfunc7(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
                    getrngfunc8(1),getrngfunc9(1))
              with ordinality as t1(a,b,c,d,e,f,g,h,i,j,k,l,m,o,p,q,r,s,t,u);
---END---
---START---
select * from rows from(getrngfunc9(1),getrngfunc8(1),
                    getrngfunc7(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
                    getrngfunc6(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
                    getrngfunc5(1),getrngfunc4(1),getrngfunc3(1),getrngfunc2(1),getrngfunc1(1))
              with ordinality as t1(a,b,c,d,e,f,g,h,i,j,k,l,m,o,p,q,r,s,t,u);
---END---
---START---

create temporary view vw_rngfunc as
  select * from rows from(getrngfunc9(1),
                      getrngfunc7(1) AS (rngfuncid int, rngfuncsubid int, rngfuncname text),
                      getrngfunc1(1))
                with ordinality as t1(a,b,c,d,e,f,g,n);
---END---
---START---
select * from vw_rngfunc;
---END---
---START---
select pg_get_viewdef('vw_rngfunc');
---END---
---START---
drop view vw_rngfunc;
---END---
---START---

DROP FUNCTION getrngfunc1(int);
---END---
---START---
DROP FUNCTION getrngfunc2(int);
---END---
---START---
DROP FUNCTION getrngfunc3(int);
---END---
---START---
DROP FUNCTION getrngfunc4(int);
---END---
---START---
DROP FUNCTION getrngfunc5(int);
---END---
---START---
DROP FUNCTION getrngfunc6(int);
---END---
---START---
DROP FUNCTION getrngfunc7(int);
---END---
---START---
DROP FUNCTION getrngfunc8(int);
---END---
---START---
DROP FUNCTION getrngfunc9(int);
---END---
---START---
DROP FUNCTION rngfunct(int);
---END---
---START---
DROP TABLE rngfunc2;
---END---
---START---
DROP TABLE rngfunc;
---END---
---START---

-- Rescan tests --
CREATE TEMPORARY SEQUENCE rngfunc_rescan_seq1;
---END---
---START---
CREATE TEMPORARY SEQUENCE rngfunc_rescan_seq2;
---END---
---START---
CREATE TYPE rngfunc_rescan_t AS (i integer, s bigint);
---END---
---START---

CREATE FUNCTION rngfunc_sql(int,int) RETURNS setof rngfunc_rescan_t AS 'SELECT i, nextval(''rngfunc_rescan_seq1'') FROM generate_series($1,$2) i;' LANGUAGE SQL;
---END---
---START---
-- plpgsql functions use materialize mode
CREATE FUNCTION rngfunc_mat(int,int) RETURNS setof rngfunc_rescan_t AS 'begin for i in $1..$2 loop return next (i, nextval(''rngfunc_rescan_seq2'')); end loop; end;' LANGUAGE plpgsql;
---END---
---START---

--invokes ExecReScanFunctionScan - all these cases should materialize the function only once
-- LEFT JOIN on a condition that the planner can't prove to be true is used to ensure the function
-- is on the inner path of a nestloop join

SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN rngfunc_sql(11,13) ON (r+i)<100;
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN rngfunc_sql(11,13) WITH ORDINALITY AS f(i,s,o) ON (r+i)<100;
---END---
---START---

SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN rngfunc_mat(11,13) ON (r+i)<100;
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN rngfunc_mat(11,13) WITH ORDINALITY AS f(i,s,o) ON (r+i)<100;
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN ROWS FROM( rngfunc_sql(11,13), rngfunc_mat(11,13) ) WITH ORDINALITY AS f(i1,s1,i2,s2,o) ON (r+i1+i2)<100;
---END---
---START---

SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN generate_series(11,13) f(i) ON (r+i)<100;
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN generate_series(11,13) WITH ORDINALITY AS f(i,o) ON (r+i)<100;
---END---
---START---

SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN unnest(array[10,20,30]) f(i) ON (r+i)<100;
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r) LEFT JOIN unnest(array[10,20,30]) WITH ORDINALITY AS f(i,o) ON (r+i)<100;
---END---
---START---

--invokes ExecReScanFunctionScan with chgParam != NULL (using implied LATERAL)

SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_sql(10+r,13);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_sql(10+r,13) WITH ORDINALITY AS f(i,s,o);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_sql(11,10+r);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_sql(11,10+r) WITH ORDINALITY AS f(i,s,o);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (11,12),(13,15),(16,20)) v(r1,r2), rngfunc_sql(r1,r2);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (11,12),(13,15),(16,20)) v(r1,r2), rngfunc_sql(r1,r2) WITH ORDINALITY AS f(i,s,o);
---END---
---START---

SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_mat(10+r,13);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_mat(10+r,13) WITH ORDINALITY AS f(i,s,o);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_mat(11,10+r);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), rngfunc_mat(11,10+r) WITH ORDINALITY AS f(i,s,o);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (11,12),(13,15),(16,20)) v(r1,r2), rngfunc_mat(r1,r2);
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (11,12),(13,15),(16,20)) v(r1,r2), rngfunc_mat(r1,r2) WITH ORDINALITY AS f(i,s,o);
---END---
---START---

-- selective rescan of multiple functions:

SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), ROWS FROM( rngfunc_sql(11,11), rngfunc_mat(10+r,13) );
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), ROWS FROM( rngfunc_sql(10+r,13), rngfunc_mat(11,11) );
---END---
---START---
SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), ROWS FROM( rngfunc_sql(10+r,13), rngfunc_mat(10+r,13) );
---END---
---START---

SELECT setval('rngfunc_rescan_seq1',1,false),setval('rngfunc_rescan_seq2',1,false);
---END---
---START---
SELECT * FROM generate_series(1,2) r1, generate_series(r1,3) r2, ROWS FROM( rngfunc_sql(10+r1,13), rngfunc_mat(10+r2,13) );
---END---
---START---

SELECT * FROM (VALUES (1),(2),(3)) v(r), generate_series(10+r,20-r) f(i);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), generate_series(10+r,20-r) WITH ORDINALITY AS f(i,o);
---END---
---START---

SELECT * FROM (VALUES (1),(2),(3)) v(r), unnest(array[r*10,r*20,r*30]) f(i);
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v(r), unnest(array[r*10,r*20,r*30]) WITH ORDINALITY AS f(i,o);
---END---
---START---

-- deep nesting

SELECT * FROM (VALUES (1),(2),(3)) v1(r1),
              LATERAL (SELECT r1, * FROM (VALUES (10),(20),(30)) v2(r2)
                                         LEFT JOIN generate_series(21,23) f(i) ON ((r2+i)<100) OFFSET 0) s1;
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v1(r1),
              LATERAL (SELECT r1, * FROM (VALUES (10),(20),(30)) v2(r2)
                                         LEFT JOIN generate_series(20+r1,23) f(i) ON ((r2+i)<100) OFFSET 0) s1;
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v1(r1),
              LATERAL (SELECT r1, * FROM (VALUES (10),(20),(30)) v2(r2)
                                         LEFT JOIN generate_series(r2,r2+3) f(i) ON ((r2+i)<100) OFFSET 0) s1;
---END---
---START---
SELECT * FROM (VALUES (1),(2),(3)) v1(r1),
              LATERAL (SELECT r1, * FROM (VALUES (10),(20),(30)) v2(r2)
                                         LEFT JOIN generate_series(r1,2+r2/5) f(i) ON ((r2+i)<100) OFFSET 0) s1;
---END---
---START---

-- check handling of FULL JOIN with multiple lateral references (bug #15741)

SELECT *
FROM (VALUES (1),(2)) v1(r1)
    LEFT JOIN LATERAL (
        SELECT *
        FROM generate_series(1, v1.r1) AS gs1
        LEFT JOIN LATERAL (
            SELECT *
            FROM generate_series(1, gs1) AS gs2
            LEFT JOIN generate_series(1, gs2) AS gs3 ON TRUE
        ) AS ss1 ON TRUE
        FULL JOIN generate_series(1, v1.r1) AS gs4 ON FALSE
    ) AS ss0 ON TRUE;
---END---
---START---

DROP FUNCTION rngfunc_sql(int,int);
---END---
---START---
DROP FUNCTION rngfunc_mat(int,int);
---END---
---START---
DROP SEQUENCE rngfunc_rescan_seq1;
---END---
---START---
DROP SEQUENCE rngfunc_rescan_seq2;
---END---
---START---

--
-- Test cases involving OUT parameters
--

CREATE FUNCTION rngfunc(in f1 int, out f2 int)
AS 'select $1+1' LANGUAGE sql;
---END---
---START---
SELECT rngfunc(42);
---END---
---START---
SELECT * FROM rngfunc(42);
---END---
---START---
SELECT * FROM rngfunc(42) AS p(x);
---END---
---START---

-- explicit spec of return type is OK
CREATE OR REPLACE FUNCTION rngfunc(in f1 int, out f2 int) RETURNS int
AS 'select $1+1' LANGUAGE sql;
---END---
---START---
-- error, wrong result type
CREATE OR REPLACE FUNCTION rngfunc(in f1 int, out f2 int) RETURNS float
AS 'select $1+1' LANGUAGE sql;
---END---
---START---
-- with multiple OUT params you must get a RECORD result
CREATE OR REPLACE FUNCTION rngfunc(in f1 int, out f2 int, out f3 text) RETURNS int
AS 'select $1+1' LANGUAGE sql;
---END---
---START---
CREATE OR REPLACE FUNCTION rngfunc(in f1 int, out f2 int, out f3 text)
RETURNS record
AS 'select $1+1' LANGUAGE sql;
---END---
---START---

CREATE OR REPLACE FUNCTION rngfuncr(in f1 int, out f2 int, out text)
AS $$select $1-1, $1::text || 'z'$$ LANGUAGE sql;
---END---
---START---
SELECT f1, rngfuncr(f1) FROM int4_tbl;
---END---
---START---
SELECT * FROM rngfuncr(42);
---END---
---START---
SELECT * FROM rngfuncr(42) AS p(a,b);
---END---
---START---

CREATE OR REPLACE FUNCTION rngfuncb(in f1 int, inout f2 int, out text)
AS $$select $2-1, $1::text || 'z'$$ LANGUAGE sql;
---END---
---START---
SELECT f1, rngfuncb(f1, f1/2) FROM int4_tbl;
---END---
---START---
SELECT * FROM rngfuncb(42, 99);
---END---
---START---
SELECT * FROM rngfuncb(42, 99) AS p(a,b);
---END---
---START---

-- Can reference function with or without OUT params for DROP, etc
DROP FUNCTION rngfunc(int);
---END---
---START---
DROP FUNCTION rngfuncr(in f2 int, out f1 int, out text);
---END---
---START---
DROP FUNCTION rngfuncb(in f1 int, inout f2 int);
---END---
---START---

--
-- For my next trick, polymorphic OUT parameters
--

CREATE FUNCTION dup (f1 anyelement, f2 out anyelement, f3 out anyarray)
AS 'select $1, array[$1,$1]' LANGUAGE sql;
---END---
---START---
SELECT dup(22);
---END---
---START---
SELECT dup('xyz');	-- fails
SELECT dup('xyz'::text);
---END---
---START---
SELECT * FROM dup('xyz'::text);
---END---
---START---

-- fails, as we are attempting to rename first argument
CREATE OR REPLACE FUNCTION dup (inout f2 anyelement, out f3 anyarray)
AS 'select $1, array[$1,$1]' LANGUAGE sql;
---END---
---START---

DROP FUNCTION dup(anyelement);
---END---
---START---

-- equivalent behavior, though different name exposed for input arg
CREATE OR REPLACE FUNCTION dup (inout f2 anyelement, out f3 anyarray)
AS 'select $1, array[$1,$1]' LANGUAGE sql;
---END---
---START---
SELECT dup(22);
---END---
---START---

DROP FUNCTION dup(anyelement);
---END---
---START---

-- fails, no way to deduce outputs
CREATE FUNCTION bad (f1 int, out f2 anyelement, out f3 anyarray)
AS 'select $1, array[$1,$1]' LANGUAGE sql;
---END---
---START---

CREATE FUNCTION dup (f1 anycompatible, f2 anycompatiblearray, f3 out anycompatible, f4 out anycompatiblearray)
AS 'select $1, $2' LANGUAGE sql;
---END---
---START---
SELECT dup(22, array[44]);
---END---
---START---
SELECT dup(4.5, array[44]);
---END---
---START---
SELECT dup(22, array[44::bigint]);
---END---
---START---
SELECT *, pg_typeof(f3), pg_typeof(f4) FROM dup(22, array[44::bigint]);
---END---
---START---

DROP FUNCTION dup(f1 anycompatible, f2 anycompatiblearray);
---END---
---START---

CREATE FUNCTION dup (f1 anycompatiblerange, f2 out anycompatible, f3 out anycompatiblearray, f4 out anycompatiblerange)
AS 'select lower($1), array[lower($1), upper($1)], $1' LANGUAGE sql;
---END---
---START---
SELECT dup(int4range(4,7));
---END---
---START---
SELECT dup(numrange(4,7));
---END---
---START---
SELECT dup(textrange('aaa', 'bbb'));
---END---
---START---

DROP FUNCTION dup(f1 anycompatiblerange);
---END---
---START---

-- fails, no way to deduce outputs
CREATE FUNCTION bad (f1 anyarray, out f2 anycompatible, out f3 anycompatiblearray)
AS 'select $1, array[$1,$1]' LANGUAGE sql;
---END---
---START---

--
-- table functions
--

CREATE OR REPLACE FUNCTION rngfunc()
RETURNS TABLE(a int)
AS $$ SELECT a FROM generate_series(1,5) a(a) $$ LANGUAGE sql;
---END---
---START---
SELECT * FROM rngfunc();
---END---
---START---
DROP FUNCTION rngfunc();
---END---
---START---

CREATE OR REPLACE FUNCTION rngfunc(int)
RETURNS TABLE(a int, b int)
AS $$ SELECT a, b
         FROM generate_series(1,$1) a(a),
              generate_series(1,$1) b(b) $$ LANGUAGE sql;
---END---
---START---
SELECT * FROM rngfunc(3);
---END---
---START---
DROP FUNCTION rngfunc(int);
---END---
---START---

-- case that causes change of typmod knowledge during inlining
CREATE OR REPLACE FUNCTION rngfunc()
RETURNS TABLE(a varchar(5))
AS $$ SELECT 'hello'::varchar(5) $$ LANGUAGE sql STABLE;
---END---
---START---
SELECT * FROM rngfunc() GROUP BY 1;
---END---
---START---
DROP FUNCTION rngfunc();
---END---
---START---

--
-- some tests on SQL functions with RETURNING
--

create table tt(f1 serial, data text);
---END---
---START---

create function insert_tt(text) returns int as
$$ insert into tt(data) values($1) returning f1 $$
language sql;
---END---
---START---

select insert_tt('foo');
---END---
---START---
select insert_tt('bar');
---END---
---START---
select * from tt;
---END---
---START---

-- insert will execute to completion even if function needs just 1 row
create or replace function insert_tt(text) returns int as
$$ insert into tt(data) values($1),($1||$1) returning f1 $$
language sql;
---END---
---START---

select insert_tt('fool');
---END---
---START---
select * from tt;
---END---
---START---

-- setof does what's expected
create or replace function insert_tt2(text,text) returns setof int as
$$ insert into tt(data) values($1),($2) returning f1 $$
language sql;
---END---
---START---

select insert_tt2('foolish','barrish');
---END---
---START---
select * from insert_tt2('baz','quux');
---END---
---START---
select * from tt;
---END---
---START---

-- limit doesn't prevent execution to completion
select insert_tt2('foolish','barrish') limit 1;
---END---
---START---
select * from tt;
---END---
---START---

-- triggers will fire, too
create function noticetrigger() returns trigger as $$
begin
  raise notice 'noticetrigger % %', new.f1, new.data;
---END---
---START---
  return null;
---END---
---START---
end $$ language plpgsql;
---END---
---START---
create trigger tnoticetrigger after insert on tt for each row
execute procedure noticetrigger();
---END---
---START---

select insert_tt2('foolme','barme') limit 1;
---END---
---START---
select * from tt;
---END---
---START---

-- and rules work
create table tt_log(f1 int, data text);
---END---
---START---

create rule insert_tt_rule as on insert to tt do also
  insert into tt_log values(new.*);
---END---
---START---

select insert_tt2('foollog','barlog') limit 1;
---END---
---START---
select * from tt;
---END---
---START---
-- note that nextval() gets executed a second time in the rule expansion,
-- which is expected.
select * from tt_log;
---END---
---START---

-- test case for a whole-row-variable bug
create function rngfunc1(n integer, out a text, out b text)
  returns setof record
  language sql
  as $$ select 'foo ' || i, 'bar ' || i from generate_series(1,$1) i $$;
---END---
---START---

set work_mem='64kB';
---END---
---START---
select t.a, t, t.a from rngfunc1(10000) t limit 1;
---END---
---START---
reset work_mem;
---END---
---START---
select t.a, t, t.a from rngfunc1(10000) t limit 1;
---END---
---START---

drop function rngfunc1(n integer);
---END---
---START---

-- test use of SQL functions returning record
-- this is supported in some cases where the query doesn't specify
-- the actual record type ...

create function array_to_set(anyarray) returns setof record as $$
  select i AS "index", $1[i] AS "value" from generate_subscripts($1, 1) i
$$ language sql strict immutable;
---END---
---START---

select array_to_set(array['one', 'two']);
---END---
---START---
select * from array_to_set(array['one', 'two']) as t(f1 int,f2 text);
---END---
---START---
select * from array_to_set(array['one', 'two']); -- fail
-- after-the-fact coercion of the columns is now possible, too
select * from array_to_set(array['one', 'two']) as t(f1 numeric(4,2),f2 text);
---END---
---START---
-- and if it doesn't work, you get a compile-time not run-time error
select * from array_to_set(array['one', 'two']) as t(f1 point,f2 text);
---END---
---START---

-- with "strict", this function can't be inlined in FROM
explain (verbose, costs off)
  select * from array_to_set(array['one', 'two']) as t(f1 numeric(4,2),f2 text);
---END---
---START---

-- but without, it can be:

create or replace function array_to_set(anyarray) returns setof record as $$
  select i AS "index", $1[i] AS "value" from generate_subscripts($1, 1) i
$$ language sql immutable;
---END---
---START---

select array_to_set(array['one', 'two']);
---END---
---START---
select * from array_to_set(array['one', 'two']) as t(f1 int,f2 text);
---END---
---START---
select * from array_to_set(array['one', 'two']) as t(f1 numeric(4,2),f2 text);
---END---
---START---
select * from array_to_set(array['one', 'two']) as t(f1 point,f2 text);
---END---
---START---
explain (verbose, costs off)
  select * from array_to_set(array['one', 'two']) as t(f1 numeric(4,2),f2 text);
---END---
---START---

create table rngfunc(f1 int8, f2 int8);
---END---
---START---

create function testrngfunc() returns record as $$
  insert into rngfunc values (1,2) returning *;
---END---
---START---
$$ language sql;
---END---
---START---

select testrngfunc();
---END---
---START---
select * from testrngfunc() as t(f1 int8,f2 int8);
---END---
---START---
select * from testrngfunc(); -- fail

drop function testrngfunc();
---END---
---START---

create function testrngfunc() returns setof record as $$
  insert into rngfunc values (1,2), (3,4) returning *;
---END---
---START---
$$ language sql;
---END---
---START---

select testrngfunc();
---END---
---START---
select * from testrngfunc() as t(f1 int8,f2 int8);
---END---
---START---
select * from testrngfunc(); -- fail

drop function testrngfunc();
---END---
---START---

-- Check that typmod imposed by a composite type is honored
create type rngfunc_type as (f1 numeric(35,6), f2 numeric(35,2));
---END---
---START---

create function testrngfunc() returns rngfunc_type as $$
  select 7.136178319899999964, 7.136178319899999964;
---END---
---START---
$$ language sql immutable;
---END---
---START---

explain (verbose, costs off)
select testrngfunc();
---END---
---START---
select testrngfunc();
---END---
---START---
explain (verbose, costs off)
select * from testrngfunc();
---END---
---START---
select * from testrngfunc();
---END---
---START---

create or replace function testrngfunc() returns rngfunc_type as $$
  select 7.136178319899999964, 7.136178319899999964;
---END---
---START---
$$ language sql volatile;
---END---
---START---

explain (verbose, costs off)
select testrngfunc();
---END---
---START---
select testrngfunc();
---END---
---START---
explain (verbose, costs off)
select * from testrngfunc();
---END---
---START---
select * from testrngfunc();
---END---
---START---

drop function testrngfunc();
---END---
---START---

create function testrngfunc() returns setof rngfunc_type as $$
  select 7.136178319899999964, 7.136178319899999964;
---END---
---START---
$$ language sql immutable;
---END---
---START---

explain (verbose, costs off)
select testrngfunc();
---END---
---START---
select testrngfunc();
---END---
---START---
explain (verbose, costs off)
select * from testrngfunc();
---END---
---START---
select * from testrngfunc();
---END---
---START---

create or replace function testrngfunc() returns setof rngfunc_type as $$
  select 7.136178319899999964, 7.136178319899999964;
---END---
---START---
$$ language sql volatile;
---END---
---START---

explain (verbose, costs off)
select testrngfunc();
---END---
---START---
select testrngfunc();
---END---
---START---
explain (verbose, costs off)
select * from testrngfunc();
---END---
---START---
select * from testrngfunc();
---END---
---START---

create or replace function testrngfunc() returns setof rngfunc_type as $$
  select 1, 2 union select 3, 4 order by 1;
---END---
---START---
$$ language sql immutable;
---END---
---START---

explain (verbose, costs off)
select testrngfunc();
---END---
---START---
select testrngfunc();
---END---
---START---
explain (verbose, costs off)
select * from testrngfunc();
---END---
---START---
select * from testrngfunc();
---END---
---START---

-- Check a couple of error cases while we're here
select * from testrngfunc() as t(f1 int8,f2 int8);  -- fail, composite result
select * from pg_get_keywords() as t(f1 int8,f2 int8);  -- fail, OUT params
select * from sin(3) as t(f1 int8,f2 int8);  -- fail, scalar result type

drop type rngfunc_type cascade;
---END---
---START---

--
-- Check some cases involving added/dropped columns in a rowtype result
--

create table users (userid text, seq int, email text, todrop bool, moredrop int, enabled bool);
---END---
---START---
insert into users values ('id',1,'email',true,11,true);
---END---
---START---
insert into users values ('id2',2,'email2',true,12,true);
---END---
---START---
alter table users drop column todrop;
---END---
---START---

create or replace function get_first_user() returns users as
$$ SELECT * FROM users ORDER BY userid LIMIT 1; $$
language sql stable;
---END---
---START---

SELECT get_first_user();
---END---
---START---
SELECT * FROM get_first_user();
---END---
---START---

create or replace function get_users() returns setof users as
$$ SELECT * FROM users ORDER BY userid; $$
language sql stable;
---END---
---START---

SELECT get_users();
---END---
---START---
SELECT * FROM get_users();
---END---
---START---
SELECT * FROM get_users() WITH ORDINALITY;   -- make sure ordinality copes

-- multiple functions vs. dropped columns
SELECT * FROM ROWS FROM(generate_series(10,11), get_users()) WITH ORDINALITY;
---END---
---START---
SELECT * FROM ROWS FROM(get_users(), generate_series(10,11)) WITH ORDINALITY;
---END---
---START---

-- check that we can cope with post-parsing changes in rowtypes
create temp view usersview as
SELECT * FROM ROWS FROM(get_users(), generate_series(10,11)) WITH ORDINALITY;
---END---
---START---

select * from usersview;
---END---
---START---
alter table users add column junk text;
---END---
---START---
select * from usersview;
---END---
---START---

alter table users drop column moredrop;  -- fail, view has reference

-- We used to have a bug that would allow the above to succeed, posing
-- hazards for later execution of the view.  Check that the internal
-- defenses for those hazards haven't bit-rotted, in case some other
-- bug with similar symptoms emerges.
begin;
---END---
---START---

-- destroy the dependency entry that prevents the DROP:
delete from pg_depend where
  objid = (select oid from pg_rewrite
           where ev_class = 'usersview'::regclass and rulename = '_RETURN')
  and refobjsubid = 5
returning pg_describe_object(classid, objid, objsubid) as obj,
          pg_describe_object(refclassid, refobjid, refobjsubid) as ref,
          deptype;
---END---
---START---

alter table users drop column moredrop;
---END---
---START---
select * from usersview;  -- expect clean failure
rollback;
---END---
---START---

alter table users alter column seq type numeric;  -- fail, view has reference

-- likewise, check we don't crash if the dependency goes wrong
begin;
---END---
---START---

-- destroy the dependency entry that prevents the ALTER:
delete from pg_depend where
  objid = (select oid from pg_rewrite
           where ev_class = 'usersview'::regclass and rulename = '_RETURN')
  and refobjsubid = 2
returning pg_describe_object(classid, objid, objsubid) as obj,
          pg_describe_object(refclassid, refobjid, refobjsubid) as ref,
          deptype;
---END---
---START---

alter table users alter column seq type numeric;
---END---
---START---
select * from usersview;  -- expect clean failure
rollback;
---END---
---START---

drop view usersview;
---END---
---START---
drop function get_first_user();
---END---
---START---
drop function get_users();
---END---
---START---
drop table users;
---END---
---START---

-- check behavior with type coercion required for a set-op

create or replace function rngfuncbar() returns setof text as
$$ select 'foo'::varchar union all select 'bar'::varchar ; $$
language sql stable;
---END---
---START---

select rngfuncbar();
---END---
---START---
select * from rngfuncbar();
---END---
---START---
-- this function is now inlinable, too:
explain (verbose, costs off) select * from rngfuncbar();
---END---
---START---

drop function rngfuncbar();
---END---
---START---

-- check handling of a SQL function with multiple OUT params (bug #5777)

create or replace function rngfuncbar(out integer, out numeric) as
$$ select (1, 2.1) $$ language sql;
---END---
---START---

select * from rngfuncbar();
---END---
---START---

create or replace function rngfuncbar(out integer, out numeric) as
$$ select (1, 2) $$ language sql;
---END---
---START---

select * from rngfuncbar();  -- fail

create or replace function rngfuncbar(out integer, out numeric) as
$$ select (1, 2.1, 3) $$ language sql;
---END---
---START---

select * from rngfuncbar();  -- fail

drop function rngfuncbar();
---END---
---START---

-- check whole-row-Var handling in nested lateral functions (bug #11703)

create function extractq2(t int8_tbl) returns int8 as $$
  select t.q2
$$ language sql immutable;
---END---
---START---

explain (verbose, costs off)
select x from int8_tbl, extractq2(int8_tbl) f(x);
---END---
---START---

select x from int8_tbl, extractq2(int8_tbl) f(x);
---END---
---START---

create function extractq2_2(t int8_tbl) returns table(ret1 int8) as $$
  select extractq2(t) offset 0
$$ language sql immutable;
---END---
---START---

explain (verbose, costs off)
select x from int8_tbl, extractq2_2(int8_tbl) f(x);
---END---
---START---

select x from int8_tbl, extractq2_2(int8_tbl) f(x);
---END---
---START---

-- without the "offset 0", this function gets optimized quite differently

create function extractq2_2_opt(t int8_tbl) returns table(ret1 int8) as $$
  select extractq2(t)
$$ language sql immutable;
---END---
---START---

explain (verbose, costs off)
select x from int8_tbl, extractq2_2_opt(int8_tbl) f(x);
---END---
---START---

select x from int8_tbl, extractq2_2_opt(int8_tbl) f(x);
---END---
---START---

-- check handling of nulls in SRF results (bug #7808)

create type rngfunc2 as (a integer, b text);
---END---
---START---

select *, row_to_json(u) from unnest(array[(1,'foo')::rngfunc2, null::rngfunc2]) u;
---END---
---START---
select *, row_to_json(u) from unnest(array[null::rngfunc2, null::rngfunc2]) u;
---END---
---START---
select *, row_to_json(u) from unnest(array[null::rngfunc2, (1,'foo')::rngfunc2, null::rngfunc2]) u;
---END---
---START---
select *, row_to_json(u) from unnest(array[]::rngfunc2[]) u;
---END---
---START---

drop type rngfunc2;
---END---
---START---

-- check handling of functions pulled up into function RTEs (bug #17227)

explain (verbose, costs off)
select * from
  (select jsonb_path_query_array(module->'lectures', '$[*]') as lecture
   from unnest(array['{"lectures": [{"id": "1"}]}'::jsonb])
        as unnested_modules(module)) as ss,
  jsonb_to_recordset(ss.lecture) as j (id text);
---END---
---START---

select * from
  (select jsonb_path_query_array(module->'lectures', '$[*]') as lecture
   from unnest(array['{"lectures": [{"id": "1"}]}'::jsonb])
        as unnested_modules(module)) as ss,
  jsonb_to_recordset(ss.lecture) as j (id text);
---END---
---START---
drop table if exists tt;
drop table if exists tt_log;
drop table if exists rngfunc;
drop table if exists users;
---END---
