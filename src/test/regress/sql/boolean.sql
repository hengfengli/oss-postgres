---START---
--
-- BOOLEAN
--

--
-- sanity check - if this fails go insane!
--
SELECT 1 AS one;
---END---
---START---
-- ******************testing built-in type bool********************

-- check bool input syntax

SELECT true AS true;
---END---
---START---
SELECT false AS false;
---END---
---START---
SELECT bool 't' AS true;
---END---
---START---
SELECT bool '   f           ' AS false;
---END---
---START---
SELECT bool 'true' AS true;
---END---
---START---
SELECT bool 'test' AS error;
---END---
---START---
SELECT bool 'false' AS false;
---END---
---START---
SELECT bool 'foo' AS error;
---END---
---START---
SELECT bool 'y' AS true;
---END---
---START---
SELECT bool 'yes' AS true;
---END---
---START---
SELECT bool 'yeah' AS error;
---END---
---START---
SELECT bool 'n' AS false;
---END---
---START---
SELECT bool 'no' AS false;
---END---
---START---
SELECT bool 'nay' AS error;
---END---
---START---
SELECT bool 'on' AS true;
---END---
---START---
SELECT bool 'off' AS false;
---END---
---START---
SELECT bool 'of' AS false;
---END---
---START---
SELECT bool 'o' AS error;
---END---
---START---
SELECT bool 'on_' AS error;
---END---
---START---
SELECT bool 'off_' AS error;
---END---
---START---
SELECT bool '1' AS true;
---END---
---START---
SELECT bool '11' AS error;
---END---
---START---
SELECT bool '0' AS false;
---END---
---START---
SELECT bool '000' AS error;
---END---
---START---
SELECT bool '' AS error;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('true', 'bool');
---END---
---START---
SELECT pg_input_is_valid('asdf', 'bool');
---END---
---START---
SELECT * FROM pg_input_error_info('junk', 'bool');
---END---
---START---
-- and, or, not in qualifications

SELECT bool 't' or bool 'f' AS true;
---END---
---START---
SELECT bool 't' and bool 'f' AS false;
---END---
---START---
SELECT not bool 'f' AS true;
---END---
---START---
SELECT bool 't' = bool 'f' AS false;
---END---
---START---
SELECT bool 't' <> bool 'f' AS true;
---END---
---START---
SELECT bool 't' > bool 'f' AS true;
---END---
---START---
SELECT bool 't' >= bool 'f' AS true;
---END---
---START---
SELECT bool 'f' < bool 't' AS true;
---END---
---START---
SELECT bool 'f' <= bool 't' AS true;
---END---
---START---
-- explicit casts to/from text
SELECT 'TrUe'::text::boolean AS true, 'fAlse'::text::boolean AS false;
---END---
---START---
SELECT '    true   '::text::boolean AS true,
       '     FALSE'::text::boolean AS false;
---END---
---START---
SELECT true::boolean::text AS true, false::boolean::text AS false;
---END---
---START---
SELECT '  tru e '::text::boolean AS invalid;
---END---
---START---
-- error
SELECT ''::text::boolean AS invalid;
---END---
---START---
CREATE TABLE booltbl1 (_gemini_pk serial PRIMARY KEY, f1 bool);
---END---
---START---
INSERT INTO BOOLTBL1 (f1) VALUES (bool 't');
---END---
---START---
INSERT INTO BOOLTBL1 (f1) VALUES (bool 'True');
---END---
---START---
INSERT INTO BOOLTBL1 (f1) VALUES (bool 'true');
---END---
---START---
-- BOOLTBL1 should be full of true's at this point
SELECT BOOLTBL1.* FROM BOOLTBL1;
---END---
---START---
SELECT BOOLTBL1.*
   FROM BOOLTBL1
   WHERE f1 = bool 'true';
---END---
---START---
SELECT BOOLTBL1.*
   FROM BOOLTBL1
   WHERE f1 <> bool 'false';
---END---
---START---
SELECT BOOLTBL1.*
   FROM BOOLTBL1
   WHERE booleq(bool 'false', f1);
---END---
---START---
INSERT INTO BOOLTBL1 (f1) VALUES (bool 'f');
---END---
---START---
SELECT BOOLTBL1.*
   FROM BOOLTBL1
   WHERE f1 = bool 'false';
---END---
---START---
CREATE TABLE booltbl2 (_gemini_pk serial PRIMARY KEY, f1 bool);
---END---
---START---
INSERT INTO BOOLTBL2 (f1) VALUES (bool 'f');
---END---
---START---
INSERT INTO BOOLTBL2 (f1) VALUES (bool 'false');
---END---
---START---
INSERT INTO BOOLTBL2 (f1) VALUES (bool 'False');
---END---
---START---
INSERT INTO BOOLTBL2 (f1) VALUES (bool 'FALSE');
---END---
---START---
-- This is now an invalid expression
-- For pre-v6.3 this evaluated to false - thomas 1997-10-23
INSERT INTO BOOLTBL2 (f1)
   VALUES (bool 'XXX');
---END---
---START---
-- BOOLTBL2 should be full of false's at this point
SELECT BOOLTBL2.* FROM BOOLTBL2;
---END---
---START---
SELECT BOOLTBL1.*, BOOLTBL2.*
   FROM BOOLTBL1, BOOLTBL2
   WHERE BOOLTBL2.f1 <> BOOLTBL1.f1;
---END---
---START---
SELECT BOOLTBL1.*, BOOLTBL2.*
   FROM BOOLTBL1, BOOLTBL2
   WHERE boolne(BOOLTBL2.f1,BOOLTBL1.f1);
---END---
---START---
SELECT BOOLTBL1.*, BOOLTBL2.*
   FROM BOOLTBL1, BOOLTBL2
   WHERE BOOLTBL2.f1 = BOOLTBL1.f1 and BOOLTBL1.f1 = bool 'false';
---END---
---START---
SELECT BOOLTBL1.*, BOOLTBL2.*
   FROM BOOLTBL1, BOOLTBL2
   WHERE BOOLTBL2.f1 = BOOLTBL1.f1 or BOOLTBL1.f1 = bool 'true'
   ORDER BY BOOLTBL1.f1, BOOLTBL2.f1;
---END---
---START---
--
-- SQL syntax
-- Try all combinations to ensure that we get nothing when we expect nothing
-- - thomas 2000-01-04
--

SELECT f1
   FROM BOOLTBL1
   WHERE f1 IS TRUE;
---END---
---START---
SELECT f1
   FROM BOOLTBL1
   WHERE f1 IS NOT FALSE;
---END---
---START---
SELECT f1
   FROM BOOLTBL1
   WHERE f1 IS FALSE;
---END---
---START---
SELECT f1
   FROM BOOLTBL1
   WHERE f1 IS NOT TRUE;
---END---
---START---
SELECT f1
   FROM BOOLTBL2
   WHERE f1 IS TRUE;
---END---
---START---
SELECT f1
   FROM BOOLTBL2
   WHERE f1 IS NOT FALSE;
---END---
---START---
SELECT f1
   FROM BOOLTBL2
   WHERE f1 IS FALSE;
---END---
---START---
SELECT f1
   FROM BOOLTBL2
   WHERE f1 IS NOT TRUE;
---END---
---START---
CREATE TABLE booltbl3 (_gemini_pk serial PRIMARY KEY, d text, b bool, o integer);
---END---
---START---
INSERT INTO BOOLTBL3 (d, b, o) VALUES ('true', true, 1);
---END---
---START---
INSERT INTO BOOLTBL3 (d, b, o) VALUES ('false', false, 2);
---END---
---START---
INSERT INTO BOOLTBL3 (d, b, o) VALUES ('null', null, 3);
---END---
---START---
SELECT
    d,
    b IS TRUE AS istrue,
    b IS NOT TRUE AS isnottrue,
    b IS FALSE AS isfalse,
    b IS NOT FALSE AS isnotfalse,
    b IS UNKNOWN AS isunknown,
    b IS NOT UNKNOWN AS isnotunknown
FROM booltbl3 ORDER BY o;
---END---
---START---
CREATE TABLE booltbl4 (_gemini_pk serial PRIMARY KEY, isfalse bool, istrue bool, isnul bool);
---END---
---START---
INSERT INTO booltbl4 VALUES (false, true, null);
---END---
---START---
\pset null '(null)'

-- AND expression need to return null if there's any nulls and not all
-- of the value are true
SELECT istrue AND isnul AND istrue FROM booltbl4;
---END---
---START---
SELECT istrue AND istrue AND isnul FROM booltbl4;
---END---
---START---
SELECT isnul AND istrue AND istrue FROM booltbl4;
---END---
---START---
SELECT isfalse AND isnul AND istrue FROM booltbl4;
---END---
---START---
SELECT istrue AND isfalse AND isnul FROM booltbl4;
---END---
---START---
SELECT isnul AND istrue AND isfalse FROM booltbl4;
---END---
---START---
-- OR expression need to return null if there's any nulls and none
-- of the value is true
SELECT isfalse OR isnul OR isfalse FROM booltbl4;
---END---
---START---
SELECT isfalse OR isfalse OR isnul FROM booltbl4;
---END---
---START---
SELECT isnul OR isfalse OR isfalse FROM booltbl4;
---END---
---START---
SELECT isfalse OR isnul OR istrue FROM booltbl4;
---END---
---START---
SELECT istrue OR isfalse OR isnul FROM booltbl4;
---END---
---START---
SELECT isnul OR istrue OR isfalse FROM booltbl4;
---END---
---START---
--
-- Clean up
-- Many tables are retained by the regression test, but these do not seem
--  particularly useful so just get rid of them for now.
--  - thomas 1997-11-30
--

DROP TABLE  BOOLTBL1;
---END---
---START---
DROP TABLE  BOOLTBL2;
---END---
---START---
DROP TABLE  BOOLTBL3;
---END---
---START---
DROP TABLE  BOOLTBL4;
---END---
