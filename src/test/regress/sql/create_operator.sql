---START---
--
-- CREATE_OPERATOR
--

CREATE OPERATOR ## (
   leftarg = path,
   rightarg = path,
   function = path_inter,
   commutator = ##
);
---END---
---START---
CREATE OPERATOR @#@ (
   rightarg = int8,		-- prefix
   procedure = factorial
);
---END---
---START---
CREATE OPERATOR #%# (
   leftarg = int8,		-- fail, postfix is no longer supported
   procedure = factorial
);
---END---
---START---
-- Test operator created above
SELECT @#@ 24;
---END---
---START---
-- Test comments
COMMENT ON OPERATOR ###### (NONE, int4) IS 'bad prefix';
---END---
---START---
COMMENT ON OPERATOR ###### (int4, NONE) IS 'bad postfix';
---END---
---START---
COMMENT ON OPERATOR ###### (int4, int8) IS 'bad infix';
---END---
---START---
-- Check that DROP on a nonexistent op behaves sanely, too
DROP OPERATOR ###### (NONE, int4);
---END---
---START---
DROP OPERATOR ###### (int4, NONE);
---END---
---START---
DROP OPERATOR ###### (int4, int8);
---END---
---START---
-- => is disallowed as an operator name now
CREATE OPERATOR => (
   rightarg = int8,
   procedure = factorial
);
---END---
---START---
-- lexing of <=, >=, <>, != has a number of edge cases
-- (=> is tested elsewhere)

-- this is legal because ! is not allowed in sql ops
CREATE OPERATOR !=- (
   rightarg = int8,
   procedure = factorial
);
---END---
---START---
SELECT !=- 10;
---END---
---START---
-- postfix operators don't work anymore
SELECT 10 !=-;
---END---
---START---
-- make sure lexer returns != as <> even in edge cases
SELECT 2 !=/**/ 1, 2 !=/**/ 2;
---END---
---START---
SELECT 2 !=-- comment to be removed by psql
  1;
---END---
---START---
DO $$ -- use DO to protect -- from psql
  declare r boolean;
  begin
    execute $e$ select 2 !=-- comment
      1 $e$ into r;
    raise info 'r = %', r;
  end;
$$;
---END---
---START---
-- check that <= etc. followed by more operator characters are returned
-- as the correct token with correct precedence
SELECT true<>-1 BETWEEN 1 AND 1;
---END---
---START---
-- BETWEEN has prec. above <> but below Op
SELECT false<>/**/1 BETWEEN 1 AND 1;
---END---
---START---
SELECT false<=-1 BETWEEN 1 AND 1;
---END---
---START---
SELECT false>=-1 BETWEEN 1 AND 1;
---END---
---START---
SELECT 2<=/**/3, 3>=/**/2, 2<>/**/3;
---END---
---START---
SELECT 3<=/**/2, 2>=/**/3, 2<>/**/2;
---END---
---START---
-- Should fail. CREATE OPERATOR requires USAGE on SCHEMA
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_rol_op1;
---END---
---START---
CREATE SCHEMA schema_op1;
---END---
---START---
GRANT USAGE ON SCHEMA schema_op1 TO PUBLIC;
---END---
---START---
REVOKE USAGE ON SCHEMA schema_op1 FROM regress_rol_op1;
---END---
---START---
SET ROLE regress_rol_op1;
---END---
---START---
CREATE OPERATOR schema_op1.#*# (
   rightarg = int8,
   procedure = factorial
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should fail. SETOF type functions not allowed as argument (testing leftarg)
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR #*# (
   leftarg = SETOF int8,
   procedure = factorial
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should fail. SETOF type functions not allowed as argument (testing rightarg)
BEGIN TRANSACTION;
---END---
---START---
CREATE OPERATOR #*# (
   rightarg = SETOF int8,
   procedure = factorial
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should work. Sample text-book case
BEGIN TRANSACTION;
---END---
---START---
CREATE OR REPLACE FUNCTION fn_op2(boolean, boolean)
RETURNS boolean AS $$
    SELECT NULL::BOOLEAN;
$$ LANGUAGE sql IMMUTABLE;
---END---
---START---
CREATE OPERATOR === (
    LEFTARG = boolean,
    RIGHTARG = boolean,
    PROCEDURE = fn_op2,
    COMMUTATOR = ===,
    NEGATOR = !==,
    RESTRICT = contsel,
    JOIN = contjoinsel,
    SORT1, SORT2, LTCMP, GTCMP, HASHES, MERGES
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should fail. Invalid attribute
CREATE OPERATOR #@%# (
   rightarg = int8,
   procedure = factorial,
   invalid_att = int8
);
---END---
---START---
-- Should fail. At least rightarg should be mandatorily specified
CREATE OPERATOR #@%# (
   procedure = factorial
);
---END---
---START---
-- Should fail. Procedure should be mandatorily specified
CREATE OPERATOR #@%# (
   rightarg = int8
);
---END---
---START---
-- Should fail. CREATE OPERATOR requires USAGE on TYPE
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_rol_op3;
---END---
---START---
CREATE TYPE type_op3 AS ENUM ('new', 'open', 'closed');
---END---
---START---
CREATE FUNCTION fn_op3(type_op3, int8)
RETURNS int8 AS $$
    SELECT NULL::int8;
$$ LANGUAGE sql IMMUTABLE;
---END---
---START---
REVOKE USAGE ON TYPE type_op3 FROM regress_rol_op3;
---END---
---START---
REVOKE USAGE ON TYPE type_op3 FROM PUBLIC;
---END---
---START---
-- Need to do this so that regress_rol_op3 is not allowed USAGE via PUBLIC
SET ROLE regress_rol_op3;
---END---
---START---
CREATE OPERATOR #*# (
   leftarg = type_op3,
   rightarg = int8,
   procedure = fn_op3
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should fail. CREATE OPERATOR requires USAGE on TYPE (need to check separately for rightarg)
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_rol_op4;
---END---
---START---
CREATE TYPE type_op4 AS ENUM ('new', 'open', 'closed');
---END---
---START---
CREATE FUNCTION fn_op4(int8, type_op4)
RETURNS int8 AS $$
    SELECT NULL::int8;
$$ LANGUAGE sql IMMUTABLE;
---END---
---START---
REVOKE USAGE ON TYPE type_op4 FROM regress_rol_op4;
---END---
---START---
REVOKE USAGE ON TYPE type_op4 FROM PUBLIC;
---END---
---START---
-- Need to do this so that regress_rol_op3 is not allowed USAGE via PUBLIC
SET ROLE regress_rol_op4;
---END---
---START---
CREATE OPERATOR #*# (
   leftarg = int8,
   rightarg = type_op4,
   procedure = fn_op4
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should fail. CREATE OPERATOR requires EXECUTE on function
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_rol_op5;
---END---
---START---
CREATE TYPE type_op5 AS ENUM ('new', 'open', 'closed');
---END---
---START---
CREATE FUNCTION fn_op5(int8, int8)
RETURNS int8 AS $$
    SELECT NULL::int8;
$$ LANGUAGE sql IMMUTABLE;
---END---
---START---
REVOKE EXECUTE ON FUNCTION fn_op5(int8, int8) FROM regress_rol_op5;
---END---
---START---
REVOKE EXECUTE ON FUNCTION fn_op5(int8, int8) FROM PUBLIC;
---END---
---START---
-- Need to do this so that regress_rol_op3 is not allowed EXECUTE via PUBLIC
SET ROLE regress_rol_op5;
---END---
---START---
CREATE OPERATOR #*# (
   leftarg = int8,
   rightarg = int8,
   procedure = fn_op5
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- Should fail. CREATE OPERATOR requires USAGE on return TYPE
BEGIN TRANSACTION;
---END---
---START---
CREATE ROLE regress_rol_op6;
---END---
---START---
CREATE TYPE type_op6 AS ENUM ('new', 'open', 'closed');
---END---
---START---
CREATE FUNCTION fn_op6(int8, int8)
RETURNS type_op6 AS $$
    SELECT NULL::type_op6;
$$ LANGUAGE sql IMMUTABLE;
---END---
---START---
REVOKE USAGE ON TYPE type_op6 FROM regress_rol_op6;
---END---
---START---
REVOKE USAGE ON TYPE type_op6 FROM PUBLIC;
---END---
---START---
-- Need to do this so that regress_rol_op3 is not allowed USAGE via PUBLIC
SET ROLE regress_rol_op6;
---END---
---START---
CREATE OPERATOR #*# (
   leftarg = int8,
   rightarg = int8,
   procedure = fn_op6
);
---END---
---START---
ROLLBACK;
---END---
---START---
-- invalid: non-lowercase quoted identifiers
CREATE OPERATOR ===
(
	"Leftarg" = box,
	"Rightarg" = box,
	"Procedure" = area_equal_function,
	"Commutator" = ===,
	"Negator" = !==,
	"Restrict" = area_restriction_function,
	"Join" = area_join_function,
	"Hashes",
	"Merges"
);
---END---
