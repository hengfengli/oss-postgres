---START---
--
-- Tests for polymorphic SQL functions and aggregates based on them.
-- Tests for other features related to function-calling have snuck in, too.
--

create function polyf(x anyelement) returns anyelement as $$
  select x + 1
$$ language sql;
---END---
---START---
select polyf(42) as int, polyf(4.5) as num;
---END---
---START---
select polyf(point(3,4));
---END---
---START---
-- fail for lack of + operator

drop function polyf(x anyelement);
---END---
---START---
create function polyf(x anyelement) returns anyarray as $$
  select array[x + 1, x + 2]
$$ language sql;
---END---
---START---
select polyf(42) as int, polyf(4.5) as num;
---END---
---START---
drop function polyf(x anyelement);
---END---
---START---
create function polyf(x anyarray) returns anyelement as $$
  select x[1]
$$ language sql;
---END---
---START---
select polyf(array[2,4]) as int, polyf(array[4.5, 7.7]) as num;
---END---
---START---
select polyf(stavalues1) from pg_statistic;
---END---
---START---
-- fail, can't infer element type

drop function polyf(x anyarray);
---END---
---START---
create function polyf(x anyarray) returns anyarray as $$
  select x
$$ language sql;
---END---
---START---
select polyf(array[2,4]) as int, polyf(array[4.5, 7.7]) as num;
---END---
---START---
select polyf(stavalues1) from pg_statistic;
---END---
---START---
-- fail, can't infer element type

drop function polyf(x anyarray);
---END---
---START---
-- fail, can't infer type:
create function polyf(x anyelement) returns anyrange as $$
  select array[x + 1, x + 2]
$$ language sql;
---END---
---START---
create function polyf(x anyrange) returns anyarray as $$
  select array[lower(x), upper(x)]
$$ language sql;
---END---
---START---
select polyf(int4range(42, 49)) as int, polyf(float8range(4.5, 7.8)) as num;
---END---
---START---
drop function polyf(x anyrange);
---END---
---START---
create function polyf(x anycompatible, y anycompatible) returns anycompatiblearray as $$
  select array[x, y]
$$ language sql;
---END---
---START---
select polyf(2, 4) as int, polyf(2, 4.5) as num;
---END---
---START---
drop function polyf(x anycompatible, y anycompatible);
---END---
---START---
create function polyf(x anycompatiblerange, y anycompatible, z anycompatible) returns anycompatiblearray as $$
  select array[lower(x), upper(x), y, z]
$$ language sql;
---END---
---START---
select polyf(int4range(42, 49), 11, 2::smallint) as int, polyf(float8range(4.5, 7.8), 7.8, 11::real) as num;
---END---
---START---
select polyf(int4range(42, 49), 11, 4.5) as fail;
---END---
---START---
-- range type doesn't fit

drop function polyf(x anycompatiblerange, y anycompatible, z anycompatible);
---END---
---START---
create function polyf(x anycompatiblemultirange, y anycompatible, z anycompatible) returns anycompatiblearray as $$
  select array[lower(x), upper(x), y, z]
$$ language sql;
---END---
---START---
select polyf(multirange(int4range(42, 49)), 11, 2::smallint) as int, polyf(multirange(float8range(4.5, 7.8)), 7.8, 11::real) as num;
---END---
---START---
select polyf(multirange(int4range(42, 49)), 11, 4.5) as fail;
---END---
---START---
-- range type doesn't fit

drop function polyf(x anycompatiblemultirange, y anycompatible, z anycompatible);
---END---
---START---
-- fail, can't infer type:
create function polyf(x anycompatible) returns anycompatiblerange as $$
  select array[x + 1, x + 2]
$$ language sql;
---END---
---START---
create function polyf(x anycompatiblerange, y anycompatiblearray) returns anycompatiblerange as $$
  select x
$$ language sql;
---END---
---START---
select polyf(int4range(42, 49), array[11]) as int, polyf(float8range(4.5, 7.8), array[7]) as num;
---END---
---START---
drop function polyf(x anycompatiblerange, y anycompatiblearray);
---END---
---START---
-- fail, can't infer type:
create function polyf(x anycompatible) returns anycompatiblemultirange as $$
  select array[x + 1, x + 2]
$$ language sql;
---END---
---START---
create function polyf(x anycompatiblemultirange, y anycompatiblearray) returns anycompatiblemultirange as $$
  select x
$$ language sql;
---END---
---START---
select polyf(multirange(int4range(42, 49)), array[11]) as int, polyf(multirange(float8range(4.5, 7.8)), array[7]) as num;
---END---
---START---
drop function polyf(x anycompatiblemultirange, y anycompatiblearray);
---END---
---START---
create function polyf(a anyelement, b anyarray,
                      c anycompatible, d anycompatible,
                      OUT x anyarray, OUT y anycompatiblearray)
as $$
  select a || b, array[c, d]
$$ language sql;
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from polyf(11, array[1, 2], 42, 34.5);
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from polyf(11, array[1, 2], point(1,2), point(3,4));
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from polyf(11, '{1,2}', point(1,2), '(3,4)');
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from polyf(11, array[1, 2.2], 42, 34.5);
---END---
---START---
-- fail

drop function polyf(a anyelement, b anyarray,
                    c anycompatible, d anycompatible);
---END---
---START---
create function polyf(anyrange) returns anymultirange
as 'select multirange($1);' language sql;
---END---
---START---
select polyf(int4range(1,10));
---END---
---START---
select polyf(null);
---END---
---START---
drop function polyf(anyrange);
---END---
---START---
create function polyf(anymultirange) returns anyelement
as 'select lower($1);' language sql;
---END---
---START---
select polyf(int4multirange(int4range(1,10), int4range(20,30)));
---END---
---START---
select polyf(null);
---END---
---START---
drop function polyf(anymultirange);
---END---
---START---
create function polyf(anycompatiblerange) returns anycompatiblemultirange
as 'select multirange($1);' language sql;
---END---
---START---
select polyf(int4range(1,10));
---END---
---START---
select polyf(null);
---END---
---START---
drop function polyf(anycompatiblerange);
---END---
---START---
create function polyf(anymultirange) returns anyrange
as 'select range_merge($1);' language sql;
---END---
---START---
select polyf(int4multirange(int4range(1,10), int4range(20,30)));
---END---
---START---
select polyf(null);
---END---
---START---
drop function polyf(anymultirange);
---END---
---START---
create function polyf(anycompatiblemultirange) returns anycompatiblerange
as 'select range_merge($1);' language sql;
---END---
---START---
select polyf(int4multirange(int4range(1,10), int4range(20,30)));
---END---
---START---
select polyf(null);
---END---
---START---
drop function polyf(anycompatiblemultirange);
---END---
---START---
create function polyf(anycompatiblemultirange) returns anycompatible
as 'select lower($1);' language sql;
---END---
---START---
select polyf(int4multirange(int4range(1,10), int4range(20,30)));
---END---
---START---
select polyf(null);
---END---
---START---
drop function polyf(anycompatiblemultirange);
---END---
---START---
--
-- Polymorphic aggregate tests
--
-- Legend:
-----------
-- A = type is ANY
-- P = type is polymorphic
-- N = type is non-polymorphic
-- B = aggregate base type
-- S = aggregate state type
-- R = aggregate return type
-- 1 = arg1 of a function
-- 2 = arg2 of a function
-- ag = aggregate
-- tf = trans (state) function
-- ff = final function
-- rt = return type of a function
-- -> = implies
-- => = allowed
-- !> = not allowed
-- E  = exists
-- NE = not-exists
--
-- Possible states:
-- ----------------
-- B = (A || P || N)
--   when (B = A) -> (tf2 = NE)
-- S = (P || N)
-- ff = (E || NE)
-- tf1 = (P || N)
-- tf2 = (NE || P || N)
-- R = (P || N)

-- create functions for use as tf and ff with the needed combinations of
-- argument polymorphism, but within the constraints of valid aggregate
-- functions, i.e. tf arg1 and tf return type must match

-- polymorphic single arg transfn
CREATE FUNCTION stfp(anyarray) RETURNS anyarray AS
'select $1' LANGUAGE SQL;
---END---
---START---
-- non-polymorphic single arg transfn
CREATE FUNCTION stfnp(int[]) RETURNS int[] AS
'select $1' LANGUAGE SQL;
---END---
---START---
-- dual polymorphic transfn
CREATE FUNCTION tfp(anyarray,anyelement) RETURNS anyarray AS
'select $1 || $2' LANGUAGE SQL;
---END---
---START---
-- dual non-polymorphic transfn
CREATE FUNCTION tfnp(int[],int) RETURNS int[] AS
'select $1 || $2' LANGUAGE SQL;
---END---
---START---
-- arg1 only polymorphic transfn
CREATE FUNCTION tf1p(anyarray,int) RETURNS anyarray AS
'select $1' LANGUAGE SQL;
---END---
---START---
-- arg2 only polymorphic transfn
CREATE FUNCTION tf2p(int[],anyelement) RETURNS int[] AS
'select $1' LANGUAGE SQL;
---END---
---START---
-- multi-arg polymorphic
CREATE FUNCTION sum3(anyelement,anyelement,anyelement) returns anyelement AS
'select $1+$2+$3' language sql strict;
---END---
---START---
-- finalfn polymorphic
CREATE FUNCTION ffp(anyarray) RETURNS anyarray AS
'select $1' LANGUAGE SQL;
---END---
---START---
-- finalfn non-polymorphic
CREATE FUNCTION ffnp(int[]) returns int[] as
'select $1' LANGUAGE SQL;
---END---
---START---
-- Try to cover all the possible states:
--
-- Note: in Cases 1 & 2, we are trying to return P. Therefore, if the transfn
-- is stfnp, tfnp, or tf2p, we must use ffp as finalfn, because stfnp, tfnp,
-- and tf2p do not return P. Conversely, in Cases 3 & 4, we are trying to
-- return N. Therefore, if the transfn is stfp, tfp, or tf1p, we must use ffnp
-- as finalfn, because stfp, tfp, and tf1p do not return N.
--
--     Case1 (R = P) && (B = A)
--     ------------------------
--     S    tf1
--     -------
--     N    N
-- should CREATE
CREATE AGGREGATE myaggp01a(*) (SFUNC = stfnp, STYPE = int4[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--     P    N
-- should ERROR: stfnp(anyarray) not matched by stfnp(int[])
CREATE AGGREGATE myaggp02a(*) (SFUNC = stfnp, STYPE = anyarray,
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--     N    P
-- should CREATE
CREATE AGGREGATE myaggp03a(*) (SFUNC = stfp, STYPE = int4[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp03b(*) (SFUNC = stfp, STYPE = int4[],
  INITCOND = '{}');
---END---
---START---
--     P    P
-- should ERROR: we have no way to resolve S
CREATE AGGREGATE myaggp04a(*) (SFUNC = stfp, STYPE = anyarray,
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp04b(*) (SFUNC = stfp, STYPE = anyarray,
  INITCOND = '{}');
---END---
---START---
--    Case2 (R = P) && ((B = P) || (B = N))
--    -------------------------------------
--    S    tf1      B    tf2
--    -----------------------
--    N    N        N    N
-- should CREATE
CREATE AGGREGATE myaggp05a(BASETYPE = int, SFUNC = tfnp, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    N    N        N    P
-- should CREATE
CREATE AGGREGATE myaggp06a(BASETYPE = int, SFUNC = tf2p, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    N    N        P    N
-- should ERROR: tfnp(int[], anyelement) not matched by tfnp(int[], int)
CREATE AGGREGATE myaggp07a(BASETYPE = anyelement, SFUNC = tfnp, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    N    N        P    P
-- should CREATE
CREATE AGGREGATE myaggp08a(BASETYPE = anyelement, SFUNC = tf2p, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    N    P        N    N
-- should CREATE
CREATE AGGREGATE myaggp09a(BASETYPE = int, SFUNC = tf1p, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp09b(BASETYPE = int, SFUNC = tf1p, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    P        N    P
-- should CREATE
CREATE AGGREGATE myaggp10a(BASETYPE = int, SFUNC = tfp, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp10b(BASETYPE = int, SFUNC = tfp, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    P        P    N
-- should ERROR: tf1p(int[],anyelement) not matched by tf1p(anyarray,int)
CREATE AGGREGATE myaggp11a(BASETYPE = anyelement, SFUNC = tf1p, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp11b(BASETYPE = anyelement, SFUNC = tf1p, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    P        P    P
-- should ERROR: tfp(int[],anyelement) not matched by tfp(anyarray,anyelement)
CREATE AGGREGATE myaggp12a(BASETYPE = anyelement, SFUNC = tfp, STYPE = int[],
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp12b(BASETYPE = anyelement, SFUNC = tfp, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    P    N        N    N
-- should ERROR: tfnp(anyarray, int) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggp13a(BASETYPE = int, SFUNC = tfnp, STYPE = anyarray,
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    P    N        N    P
-- should ERROR: tf2p(anyarray, int) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggp14a(BASETYPE = int, SFUNC = tf2p, STYPE = anyarray,
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    P    N        P    N
-- should ERROR: tfnp(anyarray, anyelement) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggp15a(BASETYPE = anyelement, SFUNC = tfnp,
  STYPE = anyarray, FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    P    N        P    P
-- should ERROR: tf2p(anyarray, anyelement) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggp16a(BASETYPE = anyelement, SFUNC = tf2p,
  STYPE = anyarray, FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
--    P    P        N    N
-- should ERROR: we have no way to resolve S
CREATE AGGREGATE myaggp17a(BASETYPE = int, SFUNC = tf1p, STYPE = anyarray,
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp17b(BASETYPE = int, SFUNC = tf1p, STYPE = anyarray,
  INITCOND = '{}');
---END---
---START---
--    P    P        N    P
-- should ERROR: tfp(anyarray, int) not matched by tfp(anyarray, anyelement)
CREATE AGGREGATE myaggp18a(BASETYPE = int, SFUNC = tfp, STYPE = anyarray,
  FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp18b(BASETYPE = int, SFUNC = tfp, STYPE = anyarray,
  INITCOND = '{}');
---END---
---START---
--    P    P        P    N
-- should ERROR: tf1p(anyarray, anyelement) not matched by tf1p(anyarray, int)
CREATE AGGREGATE myaggp19a(BASETYPE = anyelement, SFUNC = tf1p,
  STYPE = anyarray, FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp19b(BASETYPE = anyelement, SFUNC = tf1p,
  STYPE = anyarray, INITCOND = '{}');
---END---
---START---
--    P    P        P    P
-- should CREATE
CREATE AGGREGATE myaggp20a(BASETYPE = anyelement, SFUNC = tfp,
  STYPE = anyarray, FINALFUNC = ffp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggp20b(BASETYPE = anyelement, SFUNC = tfp,
  STYPE = anyarray, INITCOND = '{}');
---END---
---START---
--     Case3 (R = N) && (B = A)
--     ------------------------
--     S    tf1
--     -------
--     N    N
-- should CREATE
CREATE AGGREGATE myaggn01a(*) (SFUNC = stfnp, STYPE = int4[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn01b(*) (SFUNC = stfnp, STYPE = int4[],
  INITCOND = '{}');
---END---
---START---
--     P    N
-- should ERROR: stfnp(anyarray) not matched by stfnp(int[])
CREATE AGGREGATE myaggn02a(*) (SFUNC = stfnp, STYPE = anyarray,
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn02b(*) (SFUNC = stfnp, STYPE = anyarray,
  INITCOND = '{}');
---END---
---START---
--     N    P
-- should CREATE
CREATE AGGREGATE myaggn03a(*) (SFUNC = stfp, STYPE = int4[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--     P    P
-- should ERROR: ffnp(anyarray) not matched by ffnp(int[])
CREATE AGGREGATE myaggn04a(*) (SFUNC = stfp, STYPE = anyarray,
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    Case4 (R = N) && ((B = P) || (B = N))
--    -------------------------------------
--    S    tf1      B    tf2
--    -----------------------
--    N    N        N    N
-- should CREATE
CREATE AGGREGATE myaggn05a(BASETYPE = int, SFUNC = tfnp, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn05b(BASETYPE = int, SFUNC = tfnp, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    N        N    P
-- should CREATE
CREATE AGGREGATE myaggn06a(BASETYPE = int, SFUNC = tf2p, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn06b(BASETYPE = int, SFUNC = tf2p, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    N        P    N
-- should ERROR: tfnp(int[], anyelement) not matched by tfnp(int[], int)
CREATE AGGREGATE myaggn07a(BASETYPE = anyelement, SFUNC = tfnp, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn07b(BASETYPE = anyelement, SFUNC = tfnp, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    N        P    P
-- should CREATE
CREATE AGGREGATE myaggn08a(BASETYPE = anyelement, SFUNC = tf2p, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn08b(BASETYPE = anyelement, SFUNC = tf2p, STYPE = int[],
  INITCOND = '{}');
---END---
---START---
--    N    P        N    N
-- should CREATE
CREATE AGGREGATE myaggn09a(BASETYPE = int, SFUNC = tf1p, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    N    P        N    P
-- should CREATE
CREATE AGGREGATE myaggn10a(BASETYPE = int, SFUNC = tfp, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    N    P        P    N
-- should ERROR: tf1p(int[],anyelement) not matched by tf1p(anyarray,int)
CREATE AGGREGATE myaggn11a(BASETYPE = anyelement, SFUNC = tf1p, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    N    P        P    P
-- should ERROR: tfp(int[],anyelement) not matched by tfp(anyarray,anyelement)
CREATE AGGREGATE myaggn12a(BASETYPE = anyelement, SFUNC = tfp, STYPE = int[],
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    P    N        N    N
-- should ERROR: tfnp(anyarray, int) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggn13a(BASETYPE = int, SFUNC = tfnp, STYPE = anyarray,
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn13b(BASETYPE = int, SFUNC = tfnp, STYPE = anyarray,
  INITCOND = '{}');
---END---
---START---
--    P    N        N    P
-- should ERROR: tf2p(anyarray, int) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggn14a(BASETYPE = int, SFUNC = tf2p, STYPE = anyarray,
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn14b(BASETYPE = int, SFUNC = tf2p, STYPE = anyarray,
  INITCOND = '{}');
---END---
---START---
--    P    N        P    N
-- should ERROR: tfnp(anyarray, anyelement) not matched by tfnp(int[],int)
CREATE AGGREGATE myaggn15a(BASETYPE = anyelement, SFUNC = tfnp,
  STYPE = anyarray, FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn15b(BASETYPE = anyelement, SFUNC = tfnp,
  STYPE = anyarray, INITCOND = '{}');
---END---
---START---
--    P    N        P    P
-- should ERROR: tf2p(anyarray, anyelement) not matched by tf2p(int[],anyelement)
CREATE AGGREGATE myaggn16a(BASETYPE = anyelement, SFUNC = tf2p,
  STYPE = anyarray, FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
CREATE AGGREGATE myaggn16b(BASETYPE = anyelement, SFUNC = tf2p,
  STYPE = anyarray, INITCOND = '{}');
---END---
---START---
--    P    P        N    N
-- should ERROR: ffnp(anyarray) not matched by ffnp(int[])
CREATE AGGREGATE myaggn17a(BASETYPE = int, SFUNC = tf1p, STYPE = anyarray,
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    P    P        N    P
-- should ERROR: tfp(anyarray, int) not matched by tfp(anyarray, anyelement)
CREATE AGGREGATE myaggn18a(BASETYPE = int, SFUNC = tfp, STYPE = anyarray,
  FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    P    P        P    N
-- should ERROR: tf1p(anyarray, anyelement) not matched by tf1p(anyarray, int)
CREATE AGGREGATE myaggn19a(BASETYPE = anyelement, SFUNC = tf1p,
  STYPE = anyarray, FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
--    P    P        P    P
-- should ERROR: ffnp(anyarray) not matched by ffnp(int[])
CREATE AGGREGATE myaggn20a(BASETYPE = anyelement, SFUNC = tfp,
  STYPE = anyarray, FINALFUNC = ffnp, INITCOND = '{}');
---END---
---START---
-- multi-arg polymorphic
CREATE AGGREGATE mysum2(anyelement,anyelement) (SFUNC = sum3,
  STYPE = anyelement, INITCOND = '0');
---END---
---START---
-- create test data for polymorphic aggregates
DROP TABLE IF EXISTS t;

CREATE TABLE t (gemini_pk serial PRIMARY KEY, f1 integer, f2 integer[], f3 text);
---END---
---START---
insert into t values(1,array[1],'a');
---END---
---START---
insert into t values(1,array[11],'b');
---END---
---START---
insert into t values(1,array[111],'c');
---END---
---START---
insert into t values(2,array[2],'a');
---END---
---START---
insert into t values(2,array[22],'b');
---END---
---START---
insert into t values(2,array[222],'c');
---END---
---START---
insert into t values(3,array[3],'a');
---END---
---START---
insert into t values(3,array[3],'b');
---END---
---START---
-- test the successfully created polymorphic aggregates
select f3, myaggp01a(*) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp03a(*) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp03b(*) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp05a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp06a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp08a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp09a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp09b(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp10a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp10b(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp20a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggp20b(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn01a(*) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn01b(*) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn03a(*) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn05a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn05b(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn06a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn06b(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn08a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn08b(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn09a(f1) from t group by f3 order by f3;
---END---
---START---
select f3, myaggn10a(f1) from t group by f3 order by f3;
---END---
---START---
select mysum2(f1, f1 + 1) from t;
---END---
---START---
-- test inlining of polymorphic SQL functions
create function bleat(int) returns int as $$
begin
  raise notice 'bleat %', $1;
  return $1;
end$$ language plpgsql;
---END---
---START---
create function sql_if(bool, anyelement, anyelement) returns anyelement as $$
select case when $1 then $2 else $3 end $$ language sql;
---END---
---START---
-- Note this would fail with integer overflow, never mind wrong bleat() output,
-- if the CASE expression were not successfully inlined
select f1, sql_if(f1 > 0, bleat(f1), bleat(f1 + 1)) from int4_tbl;
---END---
---START---
select q2, sql_if(q2 > 0, q2, q2 + 1) from int8_tbl;
---END---
---START---
-- another sort of polymorphic aggregate

CREATE AGGREGATE array_larger_accum (anyarray)
(
    sfunc = array_larger,
    stype = anyarray,
    initcond = '{}'
);
---END---
---START---
SELECT array_larger_accum(i)
FROM (VALUES (ARRAY[1,2]), (ARRAY[3,4])) as t(i);
---END---
---START---
SELECT array_larger_accum(i)
FROM (VALUES (ARRAY[row(1,2),row(3,4)]), (ARRAY[row(5,6),row(7,8)])) as t(i);
---END---
---START---
-- another kind of polymorphic aggregate

create function add_group(grp anyarray, ad anyelement, size integer)
  returns anyarray
  as $$
begin
  if grp is null then
    return array[ad];
  end if;
  if array_upper(grp, 1) < size then
    return grp || ad;
  end if;
  return grp;
end;
$$
  language plpgsql immutable;
---END---
---START---
create aggregate build_group(anyelement, integer) (
  SFUNC = add_group,
  STYPE = anyarray
);
---END---
---START---
select build_group(q1,3) from int8_tbl;
---END---
---START---
-- this should fail because stype isn't compatible with arg
create aggregate build_group(int8, integer) (
  SFUNC = add_group,
  STYPE = int2[]
);
---END---
---START---
-- but we can make a non-poly agg from a poly sfunc if types are OK
create aggregate build_group(int8, integer) (
  SFUNC = add_group,
  STYPE = int8[]
);
---END---
---START---
-- check proper resolution of data types for polymorphic transfn/finalfn

create function first_el_transfn(anyarray, anyelement) returns anyarray as
'select $1 || $2' language sql immutable;
---END---
---START---
create function first_el(anyarray) returns anyelement as
'select $1[1]' language sql strict immutable;
---END---
---START---
create aggregate first_el_agg_f8(float8) (
  SFUNC = array_append,
  STYPE = float8[],
  FINALFUNC = first_el
);
---END---
---START---
create aggregate first_el_agg_any(anyelement) (
  SFUNC = first_el_transfn,
  STYPE = anyarray,
  FINALFUNC = first_el
);
---END---
---START---
select first_el_agg_f8(x::float8) from generate_series(1,10) x;
---END---
---START---
select first_el_agg_any(x) from generate_series(1,10) x;
---END---
---START---
select first_el_agg_f8(x::float8) over(order by x) from generate_series(1,10) x;
---END---
---START---
select first_el_agg_any(x) over(order by x) from generate_series(1,10) x;
---END---
---START---
-- check that we can apply functions taking ANYARRAY to pg_stats
select distinct array_ndims(histogram_bounds) from pg_stats
where histogram_bounds is not null;
---END---
---START---
-- such functions must protect themselves if varying element type isn't OK
-- (WHERE clause here is to avoid possibly getting a collation error instead)
select max(histogram_bounds) from pg_stats where tablename = 'pg_am';
---END---
---START---
-- another corner case is the input functions for polymorphic pseudotypes
select array_in('{1,2,3}','int4'::regtype,-1);
---END---
---START---
-- this has historically worked
select * from array_in('{1,2,3}','int4'::regtype,-1);
---END---
---START---
-- this not
select anyrange_in('[10,20)','int4range'::regtype,-1);
---END---
---START---
-- test variadic polymorphic functions

create function myleast(variadic anyarray) returns anyelement as $$
  select min($1[i]) from generate_subscripts($1,1) g(i)
$$ language sql immutable strict;
---END---
---START---
select myleast(10, 1, 20, 33);
---END---
---START---
select myleast(1.1, 0.22, 0.55);
---END---
---START---
select myleast('z'::text);
---END---
---START---
select myleast();
---END---
---START---
-- fail

-- test with variadic call parameter
select myleast(variadic array[1,2,3,4,-1]);
---END---
---START---
select myleast(variadic array[1.1, -5.5]);
---END---
---START---
--test with empty variadic call parameter
select myleast(variadic array[]::int[]);
---END---
---START---
-- an example with some ordinary arguments too
create function concat(text, variadic anyarray) returns text as $$
  select array_to_string($2, $1);
$$ language sql immutable strict;
---END---
---START---
select concat('%', 1, 2, 3, 4, 5);
---END---
---START---
select concat('|', 'a'::text, 'b', 'c');
---END---
---START---
select concat('|', variadic array[1,2,33]);
---END---
---START---
select concat('|', variadic array[]::int[]);
---END---
---START---
drop function concat(text, anyarray);
---END---
---START---
-- mix variadic with anyelement
create function formarray(anyelement, variadic anyarray) returns anyarray as $$
  select array_prepend($1, $2);
$$ language sql immutable strict;
---END---
---START---
select formarray(1,2,3,4,5);
---END---
---START---
select formarray(1.1, variadic array[1.2,55.5]);
---END---
---START---
select formarray(1.1, array[1.2,55.5]);
---END---
---START---
-- fail without variadic
select formarray(1, 'x'::text);
---END---
---START---
-- fail, type mismatch
select formarray(1, variadic array['x'::text]);
---END---
---START---
-- fail, type mismatch

drop function formarray(anyelement, variadic anyarray);
---END---
---START---
-- test pg_typeof() function
select pg_typeof(null);
---END---
---START---
-- unknown
select pg_typeof(0);
---END---
---START---
-- integer
select pg_typeof(0.0);
---END---
---START---
-- numeric
select pg_typeof(1+1 = 2);
---END---
---START---
-- boolean
select pg_typeof('x');
---END---
---START---
-- unknown
select pg_typeof('' || '');
---END---
---START---
-- text
select pg_typeof(pg_typeof(0));
---END---
---START---
-- regtype
select pg_typeof(array[1.2,55.5]);
---END---
---START---
-- numeric[]
select pg_typeof(myleast(10, 1, 20, 33));
---END---
---START---
-- polymorphic input

-- test functions with default parameters

-- test basic functionality
create function dfunc(a int = 1, int = 2) returns int as $$
  select $1 + $2;
$$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
select dfunc(10);
---END---
---START---
select dfunc(10, 20);
---END---
---START---
select dfunc(10, 20, 30);
---END---
---START---
-- fail

drop function dfunc();
---END---
---START---
-- fail
drop function dfunc(int);
---END---
---START---
-- fail
drop function dfunc(int, int);
---END---
---START---
-- ok

-- fail: defaults must be at end of argument list
create function dfunc(a int = 1, b int) returns int as $$
  select $1 + $2;
$$ language sql;
---END---
---START---
-- however, this should work:
create function dfunc(a int = 1, out sum int, b int = 2) as $$
  select $1 + $2;
$$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
-- verify it lists properly
\df dfunc

drop function dfunc(int, int);
---END---
---START---
-- check implicit coercion
create function dfunc(a int DEFAULT 1.0, int DEFAULT '-1') returns int as $$
  select $1 + $2;
$$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
create function dfunc(a text DEFAULT 'Hello', b text DEFAULT 'World') returns text as $$
  select $1 || ', ' || $2;
$$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
-- fail: which dfunc should be called? int or text
select dfunc('Hi');
---END---
---START---
-- ok
select dfunc('Hi', 'City');
---END---
---START---
-- ok
select dfunc(0);
---END---
---START---
-- ok
select dfunc(10, 20);
---END---
---START---
-- ok

drop function dfunc(int, int);
---END---
---START---
drop function dfunc(text, text);
---END---
---START---
create function dfunc(int = 1, int = 2) returns int as $$
  select 2;
$$ language sql;
---END---
---START---
create function dfunc(int = 1, int = 2, int = 3, int = 4) returns int as $$
  select 4;
$$ language sql;
---END---
---START---
-- Now, dfunc(nargs = 2) and dfunc(nargs = 4) are ambiguous when called
-- with 0 to 2 arguments.

select dfunc();
---END---
---START---
-- fail
select dfunc(1);
---END---
---START---
-- fail
select dfunc(1, 2);
---END---
---START---
-- fail
select dfunc(1, 2, 3);
---END---
---START---
-- ok
select dfunc(1, 2, 3, 4);
---END---
---START---
-- ok

drop function dfunc(int, int);
---END---
---START---
drop function dfunc(int, int, int, int);
---END---
---START---
-- default values are not allowed for output parameters
create function dfunc(out int = 20) returns int as $$
  select 1;
$$ language sql;
---END---
---START---
-- polymorphic parameter test
create function dfunc(anyelement = 'World'::text) returns text as $$
  select 'Hello, ' || $1::text;
$$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
select dfunc(0);
---END---
---START---
select dfunc(to_date('20081215','YYYYMMDD'));
---END---
---START---
select dfunc('City'::text);
---END---
---START---
drop function dfunc(anyelement);
---END---
---START---
-- check defaults for variadics

create function dfunc(a variadic int[]) returns int as
$$ select array_upper($1, 1) $$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
-- fail
select dfunc(10);
---END---
---START---
select dfunc(10,20);
---END---
---START---
create or replace function dfunc(a variadic int[] default array[]::int[]) returns int as
$$ select array_upper($1, 1) $$ language sql;
---END---
---START---
select dfunc();
---END---
---START---
-- now ok
select dfunc(10);
---END---
---START---
select dfunc(10,20);
---END---
---START---
-- can't remove the default once it exists
create or replace function dfunc(a variadic int[]) returns int as
$$ select array_upper($1, 1) $$ language sql;
---END---
---START---
\df dfunc

drop function dfunc(a variadic int[]);
---END---
---START---
-- Ambiguity should be reported only if there's not a better match available

create function dfunc(int = 1, int = 2, int = 3) returns int as $$
  select 3;
$$ language sql;
---END---
---START---
create function dfunc(int = 1, int = 2) returns int as $$
  select 2;
$$ language sql;
---END---
---START---
create function dfunc(text) returns text as $$
  select $1;
$$ language sql;
---END---
---START---
-- dfunc(narg=2) and dfunc(narg=3) are ambiguous
select dfunc(1);
---END---
---START---
-- fail

-- but this works since the ambiguous functions aren't preferred anyway
select dfunc('Hi');
---END---
---START---
drop function dfunc(int, int, int);
---END---
---START---
drop function dfunc(int, int);
---END---
---START---
drop function dfunc(text);
---END---
---START---
--
-- Tests for named- and mixed-notation function calling
--

create function dfunc(a int, b int, c int = 0, d int = 0)
  returns table (a int, b int, c int, d int) as $$
  select $1, $2, $3, $4;
$$ language sql;
---END---
---START---
select (dfunc(10,20,30)).*;
---END---
---START---
select (dfunc(a := 10, b := 20, c := 30)).*;
---END---
---START---
select * from dfunc(a := 10, b := 20);
---END---
---START---
select * from dfunc(b := 10, a := 20);
---END---
---START---
select * from dfunc(0);
---END---
---START---
-- fail
select * from dfunc(1,2);
---END---
---START---
select * from dfunc(1,2,c := 3);
---END---
---START---
select * from dfunc(1,2,d := 3);
---END---
---START---
select * from dfunc(x := 20, b := 10, x := 30);
---END---
---START---
-- fail, duplicate name
select * from dfunc(10, b := 20, 30);
---END---
---START---
-- fail, named args must be last
select * from dfunc(x := 10, b := 20, c := 30);
---END---
---START---
-- fail, unknown param
select * from dfunc(10, 10, a := 20);
---END---
---START---
-- fail, a overlaps positional parameter
select * from dfunc(1,c := 2,d := 3);
---END---
---START---
-- fail, no value for b

drop function dfunc(int, int, int, int);
---END---
---START---
-- test with different parameter types
create function dfunc(a varchar, b numeric, c date = current_date)
  returns table (a varchar, b numeric, c date) as $$
  select $1, $2, $3;
$$ language sql;
---END---
---START---
select (dfunc('Hello World', 20, '2009-07-25'::date)).*;
---END---
---START---
select * from dfunc('Hello World', 20, '2009-07-25'::date);
---END---
---START---
select * from dfunc(c := '2009-07-25'::date, a := 'Hello World', b := 20);
---END---
---START---
select * from dfunc('Hello World', b := 20, c := '2009-07-25'::date);
---END---
---START---
select * from dfunc('Hello World', c := '2009-07-25'::date, b := 20);
---END---
---START---
select * from dfunc('Hello World', c := 20, b := '2009-07-25'::date);
---END---
---START---
-- fail

drop function dfunc(varchar, numeric, date);
---END---
---START---
-- test out parameters with named params
create function dfunc(a varchar = 'def a', out _a varchar, c numeric = NULL, out _c numeric)
returns record as $$
  select $1, $2;
$$ language sql;
---END---
---START---
select (dfunc()).*;
---END---
---START---
select * from dfunc();
---END---
---START---
select * from dfunc('Hello', 100);
---END---
---START---
select * from dfunc(a := 'Hello', c := 100);
---END---
---START---
select * from dfunc(c := 100, a := 'Hello');
---END---
---START---
select * from dfunc('Hello');
---END---
---START---
select * from dfunc('Hello', c := 100);
---END---
---START---
select * from dfunc(c := 100);
---END---
---START---
-- fail, can no longer change an input parameter's name
create or replace function dfunc(a varchar = 'def a', out _a varchar, x numeric = NULL, out _c numeric)
returns record as $$
  select $1, $2;
$$ language sql;
---END---
---START---
create or replace function dfunc(a varchar = 'def a', out _a varchar, numeric = NULL, out _c numeric)
returns record as $$
  select $1, $2;
$$ language sql;
---END---
---START---
drop function dfunc(varchar, numeric);
---END---
---START---
--fail, named parameters are not unique
create function testpolym(a int, a int) returns int as $$ select 1;$$ language sql;
---END---
---START---
create function testpolym(int, out a int, out a int) returns int as $$ select 1;$$ language sql;
---END---
---START---
create function testpolym(out a int, inout a int) returns int as $$ select 1;$$ language sql;
---END---
---START---
create function testpolym(a int, inout a int) returns int as $$ select 1;$$ language sql;
---END---
---START---
-- valid
create function testpolym(a int, out a int) returns int as $$ select $1;$$ language sql;
---END---
---START---
select testpolym(37);
---END---
---START---
drop function testpolym(int);
---END---
---START---
create function testpolym(a int) returns table(a int) as $$ select $1;$$ language sql;
---END---
---START---
select * from testpolym(37);
---END---
---START---
drop function testpolym(int);
---END---
---START---
-- test polymorphic params and defaults
create function dfunc(a anyelement, b anyelement = null, flag bool = true)
returns anyelement as $$
  select case when $3 then $1 else $2 end;
$$ language sql;
---END---
---START---
select dfunc(1,2);
---END---
---START---
select dfunc('a'::text, 'b');
---END---
---START---
-- positional notation with default

select dfunc(a := 1, b := 2);
---END---
---START---
select dfunc(a := 'a'::text, b := 'b');
---END---
---START---
select dfunc(a := 'a'::text, b := 'b', flag := false);
---END---
---START---
-- named notation

select dfunc(b := 'b'::text, a := 'a');
---END---
---START---
-- named notation with default
select dfunc(a := 'a'::text, flag := true);
---END---
---START---
-- named notation with default
select dfunc(a := 'a'::text, flag := false);
---END---
---START---
-- named notation with default
select dfunc(b := 'b'::text, a := 'a', flag := true);
---END---
---START---
-- named notation

select dfunc('a'::text, 'b', false);
---END---
---START---
-- full positional notation
select dfunc('a'::text, 'b', flag := false);
---END---
---START---
-- mixed notation
select dfunc('a'::text, 'b', true);
---END---
---START---
-- full positional notation
select dfunc('a'::text, 'b', flag := true);
---END---
---START---
-- mixed notation

-- ansi/sql syntax
select dfunc(a => 1, b => 2);
---END---
---START---
select dfunc(a => 'a'::text, b => 'b');
---END---
---START---
select dfunc(a => 'a'::text, b => 'b', flag => false);
---END---
---START---
-- named notation

select dfunc(b => 'b'::text, a => 'a');
---END---
---START---
-- named notation with default
select dfunc(a => 'a'::text, flag => true);
---END---
---START---
-- named notation with default
select dfunc(a => 'a'::text, flag => false);
---END---
---START---
-- named notation with default
select dfunc(b => 'b'::text, a => 'a', flag => true);
---END---
---START---
-- named notation

select dfunc('a'::text, 'b', false);
---END---
---START---
-- full positional notation
select dfunc('a'::text, 'b', flag => false);
---END---
---START---
-- mixed notation
select dfunc('a'::text, 'b', true);
---END---
---START---
-- full positional notation
select dfunc('a'::text, 'b', flag => true);
---END---
---START---
-- mixed notation

-- this tests lexer edge cases around =>
select dfunc(a =>-1);
---END---
---START---
select dfunc(a =>+1);
---END---
---START---
select dfunc(a =>/**/1);
---END---
---START---
select dfunc(a =>--comment to be removed by psql
  1);
---END---
---START---
-- need DO to protect the -- from psql
do $$
  declare r integer;
  begin
    select dfunc(a=>-- comment
      1) into r;
    raise info 'r = %', r;
  end;
$$;
---END---
---START---
-- check reverse-listing of named-arg calls
CREATE VIEW dfview AS
   SELECT q1, q2,
     dfunc(q1,q2, flag := q1>q2) as c3,
     dfunc(q1, flag := q1<q2, b := q2) as c4
     FROM int8_tbl;
---END---
---START---
select * from dfview;
---END---
---START---
\d+ dfview

drop view dfview;
---END---
---START---
drop function dfunc(anyelement, anyelement, bool);
---END---
---START---
--
-- Tests for ANYCOMPATIBLE polymorphism family
--

create function anyctest(anycompatible, anycompatible)
returns anycompatible as $$
  select greatest($1, $2)
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12.3) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, point(1,2)) x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest('11', '12.3') x;
---END---
---START---
-- defaults to text

drop function anyctest(anycompatible, anycompatible);
---END---
---START---
create function anyctest(anycompatible, anycompatible)
returns anycompatiblearray as $$
  select array[$1, $2]
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12.3) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[1,2]) x;
---END---
---START---
-- fail

drop function anyctest(anycompatible, anycompatible);
---END---
---START---
create function anyctest(anycompatible, anycompatiblearray)
returns anycompatiblearray as $$
  select array[$1] || $2
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[12]) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[12.3]) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(12.3, array[13]) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(12.3, '{13,14.4}') x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[point(1,2)]) x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
-- fail

drop function anyctest(anycompatible, anycompatiblearray);
---END---
---START---
create function anyctest(anycompatible, anycompatiblerange)
returns anycompatiblerange as $$
  select $2
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, int4range(4,7)) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, numrange(4,7)) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest(11.2, int4range(4,7)) x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest(11.2, '[4,7)') x;
---END---
---START---
-- fail

drop function anyctest(anycompatible, anycompatiblerange);
---END---
---START---
create function anyctest(anycompatiblerange, anycompatiblerange)
returns anycompatible as $$
  select lower($1) + upper($2)
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(int4range(11,12), int4range(4,7)) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(int4range(11,12), numrange(4,7)) x;
---END---
---START---
-- fail

drop function anyctest(anycompatiblerange, anycompatiblerange);
---END---
---START---
-- fail, can't infer result type:
create function anyctest(anycompatible)
returns anycompatiblerange as $$
  select $1
$$ language sql;
---END---
---START---
create function anyctest(anycompatible, anycompatiblemultirange)
returns anycompatiblemultirange as $$
  select $2
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, multirange(int4range(4,7))) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, multirange(numrange(4,7))) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest(11.2, multirange(int4range(4,7))) x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest(11.2, '{[4,7)}') x;
---END---
---START---
-- fail

drop function anyctest(anycompatible, anycompatiblemultirange);
---END---
---START---
create function anyctest(anycompatiblemultirange, anycompatiblemultirange)
returns anycompatible as $$
  select lower($1) + upper($2)
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(multirange(int4range(11,12)), multirange(int4range(4,7))) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(multirange(int4range(11,12)), multirange(numrange(4,7))) x;
---END---
---START---
-- fail

drop function anyctest(anycompatiblemultirange, anycompatiblemultirange);
---END---
---START---
-- fail, can't infer result type:
create function anyctest(anycompatible)
returns anycompatiblemultirange as $$
  select $1
$$ language sql;
---END---
---START---
create function anyctest(anycompatiblenonarray, anycompatiblenonarray)
returns anycompatiblearray as $$
  select array[$1, $2]
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12.3) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(array[11], array[1,2]) x;
---END---
---START---
-- fail

drop function anyctest(anycompatiblenonarray, anycompatiblenonarray);
---END---
---START---
create function anyctest(a anyelement, b anyarray,
                         c anycompatible, d anycompatible)
returns anycompatiblearray as $$
  select array[c, d]
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[1, 2], 42, 34.5) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[1, 2], point(1,2), point(3,4)) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, '{1,2}', point(1,2), '(3,4)') x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, array[1, 2.2], 42, 34.5) x;
---END---
---START---
-- fail

drop function anyctest(a anyelement, b anyarray,
                       c anycompatible, d anycompatible);
---END---
---START---
create function anyctest(variadic anycompatiblearray)
returns anycompatiblearray as $$
  select $1
$$ language sql;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, 12.2) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, '12') x;
---END---
---START---
select x, pg_typeof(x) from anyctest(11, '12.2') x;
---END---
---START---
-- fail
select x, pg_typeof(x) from anyctest(variadic array[11, 12]) x;
---END---
---START---
select x, pg_typeof(x) from anyctest(variadic array[11, 12.2]) x;
---END---
---START---
drop function anyctest(variadic anycompatiblearray);
---END---
