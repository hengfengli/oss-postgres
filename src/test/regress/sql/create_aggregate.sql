---START---
--
-- CREATE_AGGREGATE
--

-- all functions CREATEd
CREATE AGGREGATE newavg (
   sfunc = int4_avg_accum, basetype = int4, stype = _int8,
   finalfunc = int8_avg,
   initcond1 = '{0,0}'
);
---END---
---START---

-- test comments
COMMENT ON AGGREGATE newavg_wrong (int4) IS 'an agg comment';
---END---
---START---
COMMENT ON AGGREGATE newavg (int4) IS 'an agg comment';
---END---
---START---
COMMENT ON AGGREGATE newavg (int4) IS NULL;
---END---
---START---

-- without finalfunc; test obsolete spellings 'sfunc1' etc
CREATE AGGREGATE newsum (
   sfunc1 = int4pl, basetype = int4, stype1 = int4,
   initcond1 = '0'
);
---END---
---START---

-- zero-argument aggregate
CREATE AGGREGATE newcnt (*) (
   sfunc = int8inc, stype = int8,
   initcond = '0', parallel = safe
);
---END---
---START---

-- old-style spelling of same (except without parallel-safe; that's too new)
CREATE AGGREGATE oldcnt (
   sfunc = int8inc, basetype = 'ANY', stype = int8,
   initcond = '0'
);
---END---
---START---

-- aggregate that only cares about null/nonnull input
CREATE AGGREGATE newcnt ("any") (
   sfunc = int8inc_any, stype = int8,
   initcond = '0'
);
---END---
---START---

COMMENT ON AGGREGATE nosuchagg (*) IS 'should fail';
---END---
---START---
COMMENT ON AGGREGATE newcnt (*) IS 'an agg(*) comment';
---END---
---START---
COMMENT ON AGGREGATE newcnt ("any") IS 'an agg(any) comment';
---END---
---START---

-- multi-argument aggregate
create function sum3(int8,int8,int8) returns int8 as
'select $1 + $2 + $3' language sql strict immutable;
---END---
---START---

create aggregate sum2(int8,int8) (
   sfunc = sum3, stype = int8,
   initcond = '0'
);
---END---
---START---

-- multi-argument aggregates sensitive to distinct/order, strict/nonstrict
create type aggtype as (a integer, b integer, c text);
---END---
---START---

create function aggf_trans(aggtype[],integer,integer,text) returns aggtype[]
as 'select array_append($1,ROW($2,$3,$4)::aggtype)'
language sql strict immutable;
---END---
---START---

create function aggfns_trans(aggtype[],integer,integer,text) returns aggtype[]
as 'select array_append($1,ROW($2,$3,$4)::aggtype)'
language sql immutable;
---END---
---START---

create aggregate aggfstr(integer,integer,text) (
   sfunc = aggf_trans, stype = aggtype[],
   initcond = '{}'
);
---END---
---START---

create aggregate aggfns(integer,integer,text) (
   sfunc = aggfns_trans, stype = aggtype[], sspace = 10000,
   initcond = '{}'
);
---END---
---START---

-- check error cases that would require run-time type coercion
create function least_accum(int8, int8) returns int8 language sql as
  'select least($1, $2)';
---END---
---START---

create aggregate least_agg(int4) (
  stype = int8, sfunc = least_accum
);  -- fails

drop function least_accum(int8, int8);
---END---
---START---

create function least_accum(anycompatible, anycompatible)
returns anycompatible language sql as
  'select least($1, $2)';
---END---
---START---

create aggregate least_agg(int4) (
  stype = int8, sfunc = least_accum
);  -- fails

create aggregate least_agg(int8) (
  stype = int8, sfunc = least_accum
);
---END---
---START---

drop function least_accum(anycompatible, anycompatible) cascade;
---END---
---START---

-- variadic aggregates
create function least_accum(anyelement, variadic anyarray)
returns anyelement language sql as
  'select least($1, min($2[i])) from generate_subscripts($2,1) g(i)';
---END---
---START---

create aggregate least_agg(variadic items anyarray) (
  stype = anyelement, sfunc = least_accum
);
---END---
---START---

create function cleast_accum(anycompatible, variadic anycompatiblearray)
returns anycompatible language sql as
  'select least($1, min($2[i])) from generate_subscripts($2,1) g(i)';
---END---
---START---

create aggregate cleast_agg(variadic items anycompatiblearray) (
  stype = anycompatible, sfunc = cleast_accum
);
---END---
---START---

-- test ordered-set aggs using built-in support functions
create aggregate my_percentile_disc(float8 ORDER BY anyelement) (
  stype = internal,
  sfunc = ordered_set_transition,
  finalfunc = percentile_disc_final,
  finalfunc_extra = true,
  finalfunc_modify = read_write
);
---END---
---START---

create aggregate my_rank(VARIADIC "any" ORDER BY VARIADIC "any") (
  stype = internal,
  sfunc = ordered_set_transition_multi,
  finalfunc = rank_final,
  finalfunc_extra = true,
  hypothetical
);
---END---
---START---

alter aggregate my_percentile_disc(float8 ORDER BY anyelement)
  rename to test_percentile_disc;
---END---
---START---
alter aggregate my_rank(VARIADIC "any" ORDER BY VARIADIC "any")
  rename to test_rank;
---END---
---START---

\da test_*

-- moving-aggregate options

CREATE AGGREGATE sumdouble (float8)
(
    stype = float8,
    sfunc = float8pl,
    mstype = float8,
    msfunc = float8pl,
    minvfunc = float8mi
);
---END---
---START---

-- aggregate combine and serialization functions

-- can't specify just one of serialfunc and deserialfunc
CREATE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	serialfunc = numeric_avg_serialize
);
---END---
---START---

-- serialfunc must have correct parameters
CREATE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	serialfunc = numeric_avg_deserialize,
	deserialfunc = numeric_avg_deserialize
);
---END---
---START---

-- deserialfunc must have correct parameters
CREATE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	serialfunc = numeric_avg_serialize,
	deserialfunc = numeric_avg_serialize
);
---END---
---START---

-- ensure combine function parameters are checked
CREATE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	serialfunc = numeric_avg_serialize,
	deserialfunc = numeric_avg_deserialize,
	combinefunc = int4larger
);
---END---
---START---

-- ensure create aggregate works.
CREATE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	finalfunc = numeric_avg,
	serialfunc = numeric_avg_serialize,
	deserialfunc = numeric_avg_deserialize,
	combinefunc = numeric_avg_combine,
	finalfunc_modify = shareable  -- just to test a non-default setting
);
---END---
---START---

-- Ensure all these functions made it into the catalog
SELECT aggfnoid, aggtransfn, aggcombinefn, aggtranstype::regtype,
       aggserialfn, aggdeserialfn, aggfinalmodify
FROM pg_aggregate
WHERE aggfnoid = 'myavg'::REGPROC;
---END---
---START---

DROP AGGREGATE myavg (numeric);
---END---
---START---

-- create or replace aggregate
CREATE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	finalfunc = numeric_avg
);
---END---
---START---

CREATE OR REPLACE AGGREGATE myavg (numeric)
(
	stype = internal,
	sfunc = numeric_avg_accum,
	finalfunc = numeric_avg,
	serialfunc = numeric_avg_serialize,
	deserialfunc = numeric_avg_deserialize,
	combinefunc = numeric_avg_combine,
	finalfunc_modify = shareable  -- just to test a non-default setting
);
---END---
---START---

-- Ensure all these functions made it into the catalog again
SELECT aggfnoid, aggtransfn, aggcombinefn, aggtranstype::regtype,
       aggserialfn, aggdeserialfn, aggfinalmodify
FROM pg_aggregate
WHERE aggfnoid = 'myavg'::REGPROC;
---END---
---START---

-- can change stype:
CREATE OR REPLACE AGGREGATE myavg (numeric)
(
	stype = numeric,
	sfunc = numeric_add
);
---END---
---START---
SELECT aggfnoid, aggtransfn, aggcombinefn, aggtranstype::regtype,
       aggserialfn, aggdeserialfn, aggfinalmodify
FROM pg_aggregate
WHERE aggfnoid = 'myavg'::REGPROC;
---END---
---START---

-- can't change return type:
CREATE OR REPLACE AGGREGATE myavg (numeric)
(
	stype = numeric,
	sfunc = numeric_add,
	finalfunc = numeric_out
);
---END---
---START---

-- can't change to a different kind:
CREATE OR REPLACE AGGREGATE myavg (order by numeric)
(
	stype = numeric,
	sfunc = numeric_add
);
---END---
---START---

-- can't change plain function to aggregate:
create function sum4(int8,int8,int8,int8) returns int8 as
'select $1 + $2 + $3 + $4' language sql strict immutable;
---END---
---START---

CREATE OR REPLACE AGGREGATE sum3 (int8,int8,int8)
(
	stype = int8,
	sfunc = sum4
);
---END---
---START---

drop function sum4(int8,int8,int8,int8);
---END---
---START---

DROP AGGREGATE myavg (numeric);
---END---
---START---

-- invalid: bad parallel-safety marking
CREATE AGGREGATE mysum (int)
(
	stype = int,
	sfunc = int4pl,
	parallel = pear
);
---END---
---START---

-- invalid: nonstrict inverse with strict forward function

CREATE FUNCTION float8mi_n(float8, float8) RETURNS float8 AS
$$ SELECT $1 - $2; $$
LANGUAGE SQL;
---END---
---START---

CREATE AGGREGATE invalidsumdouble (float8)
(
    stype = float8,
    sfunc = float8pl,
    mstype = float8,
    msfunc = float8pl,
    minvfunc = float8mi_n
);
---END---
---START---

-- invalid: non-matching result types

CREATE FUNCTION float8mi_int(float8, float8) RETURNS int AS
$$ SELECT CAST($1 - $2 AS INT); $$
LANGUAGE SQL;
---END---
---START---

CREATE AGGREGATE wrongreturntype (float8)
(
    stype = float8,
    sfunc = float8pl,
    mstype = float8,
    msfunc = float8pl,
    minvfunc = float8mi_int
);
---END---
---START---

-- invalid: non-lowercase quoted identifiers

CREATE AGGREGATE case_agg ( -- old syntax
	"Sfunc1" = int4pl,
	"Basetype" = int4,
	"Stype1" = int4,
	"Initcond1" = '0',
	"Parallel" = safe
);
---END---
---START---

CREATE AGGREGATE case_agg(float8)
(
	"Stype" = internal,
	"Sfunc" = ordered_set_transition,
	"Finalfunc" = percentile_disc_final,
	"Finalfunc_extra" = true,
	"Finalfunc_modify" = read_write,
	"Parallel" = safe
);
---END---
