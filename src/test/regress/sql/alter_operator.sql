---START---
CREATE FUNCTION alter_op_test_fn(boolean, boolean)
RETURNS boolean AS $$ SELECT NULL::BOOLEAN; $$ LANGUAGE sql IMMUTABLE;
---END---
---START---

CREATE FUNCTION customcontsel(internal, oid, internal, integer)
RETURNS float8 AS 'contsel' LANGUAGE internal STABLE STRICT;
---END---
---START---

CREATE OPERATOR === (
    LEFTARG = boolean,
    RIGHTARG = boolean,
    PROCEDURE = alter_op_test_fn,
    COMMUTATOR = ===,
    NEGATOR = !==,
    RESTRICT = customcontsel,
    JOIN = contjoinsel,
    HASHES, MERGES
);
---END---
---START---

SELECT pg_describe_object(refclassid,refobjid,refobjsubid) as ref, deptype
FROM pg_depend
WHERE classid = 'pg_operator'::regclass AND
      objid = '===(bool,bool)'::regoperator
ORDER BY 1;
---END---
---START---

--
-- Reset and set params
--

ALTER OPERATOR === (boolean, boolean) SET (RESTRICT = NONE);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (JOIN = NONE);
---END---
---START---

SELECT oprrest, oprjoin FROM pg_operator WHERE oprname = '==='
  AND oprleft = 'boolean'::regtype AND oprright = 'boolean'::regtype;
---END---
---START---

SELECT pg_describe_object(refclassid,refobjid,refobjsubid) as ref, deptype
FROM pg_depend
WHERE classid = 'pg_operator'::regclass AND
      objid = '===(bool,bool)'::regoperator
ORDER BY 1;
---END---
---START---

ALTER OPERATOR === (boolean, boolean) SET (RESTRICT = contsel);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (JOIN = contjoinsel);
---END---
---START---

SELECT oprrest, oprjoin FROM pg_operator WHERE oprname = '==='
  AND oprleft = 'boolean'::regtype AND oprright = 'boolean'::regtype;
---END---
---START---

SELECT pg_describe_object(refclassid,refobjid,refobjsubid) as ref, deptype
FROM pg_depend
WHERE classid = 'pg_operator'::regclass AND
      objid = '===(bool,bool)'::regoperator
ORDER BY 1;
---END---
---START---

ALTER OPERATOR === (boolean, boolean) SET (RESTRICT = NONE, JOIN = NONE);
---END---
---START---

SELECT oprrest, oprjoin FROM pg_operator WHERE oprname = '==='
  AND oprleft = 'boolean'::regtype AND oprright = 'boolean'::regtype;
---END---
---START---

SELECT pg_describe_object(refclassid,refobjid,refobjsubid) as ref, deptype
FROM pg_depend
WHERE classid = 'pg_operator'::regclass AND
      objid = '===(bool,bool)'::regoperator
ORDER BY 1;
---END---
---START---

ALTER OPERATOR === (boolean, boolean) SET (RESTRICT = customcontsel, JOIN = contjoinsel);
---END---
---START---

SELECT oprrest, oprjoin FROM pg_operator WHERE oprname = '==='
  AND oprleft = 'boolean'::regtype AND oprright = 'boolean'::regtype;
---END---
---START---

SELECT pg_describe_object(refclassid,refobjid,refobjsubid) as ref, deptype
FROM pg_depend
WHERE classid = 'pg_operator'::regclass AND
      objid = '===(bool,bool)'::regoperator
ORDER BY 1;
---END---
---START---

--
-- Test invalid options.
--
ALTER OPERATOR === (boolean, boolean) SET (COMMUTATOR = ====);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (NEGATOR = ====);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (RESTRICT = non_existent_func);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (JOIN = non_existent_func);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (COMMUTATOR = !==);
---END---
---START---
ALTER OPERATOR === (boolean, boolean) SET (NEGATOR = !==);
---END---
---START---

-- invalid: non-lowercase quoted identifiers
ALTER OPERATOR & (bit, bit) SET ("Restrict" = _int_contsel, "Join" = _int_contjoinsel);
---END---
---START---

--
-- Test permission check. Must be owner to ALTER OPERATOR.
--
CREATE USER regress_alter_op_user;
---END---
---START---
SET SESSION AUTHORIZATION regress_alter_op_user;
---END---
---START---

ALTER OPERATOR === (boolean, boolean) SET (RESTRICT = NONE);
---END---
---START---

-- Clean up
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP USER regress_alter_op_user;
---END---
---START---
DROP OPERATOR === (boolean, boolean);
---END---
---START---
DROP FUNCTION customcontsel(internal, oid, internal, integer);
---END---
---START---
DROP FUNCTION alter_op_test_fn(boolean, boolean);
---END---
