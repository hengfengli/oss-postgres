---START---
CALL nonexistent();
---END---
---START---
-- error
CALL random();
---END---
---START---
-- error

CREATE FUNCTION cp_testfunc1(a int) RETURNS int LANGUAGE SQL AS $$ SELECT a $$;
---END---
---START---
CREATE TABLE cp_test (a int, b text);
---END---
---START---
CREATE PROCEDURE ptest1(x text)
LANGUAGE SQL
AS $$
INSERT INTO cp_test VALUES (1, x);
$$;
---END---
---START---
\df ptest1
SELECT pg_get_functiondef('ptest1'::regproc);
---END---
---START---
-- show only normal functions
\dfn public.*test*1

-- show only procedures
\dfp public.*test*1

SELECT ptest1('x');
---END---
---START---
-- error
CALL ptest1('a');
---END---
---START---
-- ok
CALL ptest1('xy' || 'zzy');
---END---
---START---
-- ok, constant-folded arg
CALL ptest1(substring(random()::numeric(20,15)::text, 1, 1));
---END---
---START---
-- ok, volatile arg

SELECT * FROM cp_test ORDER BY b COLLATE "C";
---END---
---START---
-- SQL-standard body
CREATE PROCEDURE ptest1s(x text)
LANGUAGE SQL
BEGIN ATOMIC
  INSERT INTO cp_test VALUES (1, x);
---END---
---START---
END;
---END---
---START---
\df ptest1s
SELECT pg_get_functiondef('ptest1s'::regproc);
---END---
---START---
CALL ptest1s('b');
---END---
---START---
SELECT * FROM cp_test ORDER BY b COLLATE "C";
---END---
---START---
-- utility functions currently not supported here
CREATE PROCEDURE ptestx()
LANGUAGE SQL
BEGIN ATOMIC
  CREATE TABLE x (a int);
---END---
---START---
END;
---END---
---START---
CREATE PROCEDURE ptest2()
LANGUAGE SQL
AS $$
SELECT 5;
$$;
---END---
---START---
CALL ptest2();
---END---
---START---
-- nested CALL
TRUNCATE cp_test;
---END---
---START---
CREATE PROCEDURE ptest3(y text)
LANGUAGE SQL
AS $$
CALL ptest1(y);
CALL ptest1($1);
$$;
---END---
---START---
CALL ptest3('b');
---END---
---START---
SELECT * FROM cp_test;
---END---
---START---
-- output arguments

CREATE PROCEDURE ptest4a(INOUT a int, INOUT b int)
LANGUAGE SQL
AS $$
SELECT 1, 2;
$$;
---END---
---START---
CALL ptest4a(NULL, NULL);
---END---
---START---
CREATE PROCEDURE ptest4b(INOUT b int, INOUT a int)
LANGUAGE SQL
AS $$
CALL ptest4a(a, b);  -- error, not supported
$$;
---END---
---START---
DROP PROCEDURE ptest4a;
---END---
---START---
-- named and default parameters

CREATE OR REPLACE PROCEDURE ptest5(a int, b text, c int default 100)
LANGUAGE SQL
AS $$
INSERT INTO cp_test VALUES(a, b);
INSERT INTO cp_test VALUES(c, b);
$$;
---END---
---START---
TRUNCATE cp_test;
---END---
---START---
CALL ptest5(10, 'Hello', 20);
---END---
---START---
CALL ptest5(10, 'Hello');
---END---
---START---
CALL ptest5(10, b => 'Hello');
---END---
---START---
CALL ptest5(b => 'Hello', a => 10);
---END---
---START---
SELECT * FROM cp_test;
---END---
---START---
-- polymorphic types

CREATE PROCEDURE ptest6(a int, b anyelement)
LANGUAGE SQL
AS $$
SELECT NULL::int;
$$;
---END---
---START---
CALL ptest6(1, 2);
---END---
---START---
-- collation assignment

CREATE PROCEDURE ptest7(a text, b text)
LANGUAGE SQL
AS $$
SELECT a = b;
$$;
---END---
---START---
CALL ptest7(least('a', 'b'), 'a');
---END---
---START---
-- empty body
CREATE PROCEDURE ptest8(x text)
BEGIN ATOMIC
END;
---END---
---START---
\df ptest8
SELECT pg_get_functiondef('ptest8'::regproc);
---END---
---START---
CALL ptest8('');
---END---
---START---
-- OUT parameters

CREATE PROCEDURE ptest9(OUT a int)
LANGUAGE SQL
AS $$
INSERT INTO cp_test VALUES (1, 'a');
SELECT 1;
$$;
---END---
---START---
-- standard way to do a call:
CALL ptest9(NULL);
---END---
---START---
-- you can write an expression, but it's not evaluated
CALL ptest9(1/0);
---END---
---START---
-- no error
-- ... and it had better match the type of the parameter
CALL ptest9(1./0.);
---END---
---START---
-- error

-- check named-parameter matching
CREATE PROCEDURE ptest10(OUT a int, IN b int, IN c int)
LANGUAGE SQL AS $$ SELECT b - c $$;
---END---
---START---
CALL ptest10(null, 7, 4);
---END---
---START---
CALL ptest10(a => null, b => 8, c => 2);
---END---
---START---
CALL ptest10(null, 7, c => 2);
---END---
---START---
CALL ptest10(null, c => 4, b => 11);
---END---
---START---
CALL ptest10(b => 8, c => 2, a => 0);
---END---
---START---
CREATE PROCEDURE ptest11(a OUT int, VARIADIC b int[]) LANGUAGE SQL
  AS $$ SELECT b[1] + b[2] $$;
---END---
---START---
CALL ptest11(null, 11, 12, 13);
---END---
---START---
-- check resolution of ambiguous DROP commands

CREATE PROCEDURE ptest10(IN a int, IN b int, IN c int)
LANGUAGE SQL AS $$ SELECT a + b - c $$;
---END---
---START---
\df ptest10

drop procedure ptest10;
---END---
---START---
-- fail
drop procedure ptest10(int, int, int);
---END---
---START---
-- fail
begin;
---END---
---START---
drop procedure ptest10(out int, int, int);
---END---
---START---
\df ptest10
drop procedure ptest10(int, int, int);
---END---
---START---
-- now this would work
rollback;
---END---
---START---
begin;
---END---
---START---
drop procedure ptest10(in int, int, int);
---END---
---START---
\df ptest10
drop procedure ptest10(int, int, int);
---END---
---START---
-- now this would work
rollback;
---END---
---START---
-- various error cases

CALL version();
---END---
---START---
-- error: not a procedure
CALL sum(1);
---END---
---START---
-- error: not a procedure

CREATE PROCEDURE ptestx() LANGUAGE SQL WINDOW AS $$ INSERT INTO cp_test VALUES (1, 'a') $$;
---END---
---START---
CREATE PROCEDURE ptestx() LANGUAGE SQL STRICT AS $$ INSERT INTO cp_test VALUES (1, 'a') $$;
---END---
---START---
CREATE PROCEDURE ptestx(a VARIADIC int[], b OUT int) LANGUAGE SQL
  AS $$ SELECT a[1] $$;
---END---
---START---
CREATE PROCEDURE ptestx(a int DEFAULT 42, b OUT int) LANGUAGE SQL
  AS $$ SELECT a $$;
---END---
---START---
ALTER PROCEDURE ptest1(text) STRICT;
---END---
---START---
ALTER FUNCTION ptest1(text) VOLATILE;
---END---
---START---
-- error: not a function
ALTER PROCEDURE cp_testfunc1(int) VOLATILE;
---END---
---START---
-- error: not a procedure
ALTER PROCEDURE nonexistent() VOLATILE;
---END---
---START---
DROP FUNCTION ptest1(text);
---END---
---START---
-- error: not a function
DROP PROCEDURE cp_testfunc1(int);
---END---
---START---
-- error: not a procedure
DROP PROCEDURE nonexistent();
---END---
---START---
-- privileges

CREATE USER regress_cp_user1;
---END---
---START---
GRANT INSERT ON cp_test TO regress_cp_user1;
---END---
---START---
REVOKE EXECUTE ON PROCEDURE ptest1(text) FROM PUBLIC;
---END---
---START---
SET ROLE regress_cp_user1;
---END---
---START---
CALL ptest1('a');
---END---
---START---
-- error
RESET ROLE;
---END---
---START---
GRANT EXECUTE ON PROCEDURE ptest1(text) TO regress_cp_user1;
---END---
---START---
SET ROLE regress_cp_user1;
---END---
---START---
CALL ptest1('a');
---END---
---START---
-- ok
RESET ROLE;
---END---
---START---
-- ROUTINE syntax

ALTER ROUTINE cp_testfunc1(int) RENAME TO cp_testfunc1a;
---END---
---START---
ALTER ROUTINE cp_testfunc1a RENAME TO cp_testfunc1;
---END---
---START---
ALTER ROUTINE ptest1(text) RENAME TO ptest1a;
---END---
---START---
ALTER ROUTINE ptest1a RENAME TO ptest1;
---END---
---START---
DROP ROUTINE cp_testfunc1(int);
---END---
---START---
-- cleanup

DROP PROCEDURE ptest1;
---END---
---START---
DROP PROCEDURE ptest1s;
---END---
---START---
DROP PROCEDURE ptest2;
---END---
---START---
DROP TABLE cp_test;
---END---
---START---
DROP USER regress_cp_user1;
---END---
