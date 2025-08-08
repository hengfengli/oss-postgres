---START---
--
-- CHAR
--

-- Per SQL standard, CHAR means character(1), that is a varlena type
-- with a constraint restricting it to one character (not byte)

SELECT char 'c' = char 'c' AS true;
---END---
---START---
--
-- Build a table for testing
-- (This temporarily hides the table created in test_setup.sql)
--

CREATE TEMP TABLE CHAR_TBL(f1 char);
---END---
---START---
INSERT INTO CHAR_TBL (f1) VALUES ('a');
---END---
---START---
INSERT INTO CHAR_TBL (f1) VALUES ('A');
---END---
---START---
-- any of the following three input formats are acceptable
INSERT INTO CHAR_TBL (f1) VALUES ('1');
---END---
---START---
INSERT INTO CHAR_TBL (f1) VALUES (2);
---END---
---START---
INSERT INTO CHAR_TBL (f1) VALUES ('3');
---END---
---START---
-- zero-length char
INSERT INTO CHAR_TBL (f1) VALUES ('');
---END---
---START---
-- try char's of greater than 1 length
INSERT INTO CHAR_TBL (f1) VALUES ('cd');
---END---
---START---
INSERT INTO CHAR_TBL (f1) VALUES ('c     ');
---END---
---START---
SELECT * FROM CHAR_TBL;
---END---
---START---
SELECT c.*
   FROM CHAR_TBL c
   WHERE c.f1 <> 'a';
---END---
---START---
SELECT c.*
   FROM CHAR_TBL c
   WHERE c.f1 = 'a';
---END---
---START---
SELECT c.*
   FROM CHAR_TBL c
   WHERE c.f1 < 'a';
---END---
---START---
SELECT c.*
   FROM CHAR_TBL c
   WHERE c.f1 <= 'a';
---END---
---START---
SELECT c.*
   FROM CHAR_TBL c
   WHERE c.f1 > 'a';
---END---
---START---
SELECT c.*
   FROM CHAR_TBL c
   WHERE c.f1 >= 'a';
---END---
---START---
DROP TABLE CHAR_TBL;
---END---
---START---
--
-- Now test longer arrays of char
--
-- This char_tbl was already created and filled in test_setup.sql.
-- Here we just try to insert bad values.
--

INSERT INTO CHAR_TBL (f1) VALUES ('abcde');
---END---
---START---
SELECT * FROM CHAR_TBL;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('abcd  ', 'char(4)');
---END---
---START---
SELECT pg_input_is_valid('abcde', 'char(4)');
---END---
---START---
SELECT * FROM pg_input_error_info('abcde', 'char(4)');
---END---
---START---
--
-- Also test "char", which is an ad-hoc one-byte type.  It can only
-- really store ASCII characters, but we allow high-bit-set characters
-- to be accessed via bytea-like escapes.
--

SELECT 'a'::"char";
---END---
---START---
SELECT '\101'::"char";
---END---
---START---
SELECT '\377'::"char";
---END---
---START---
SELECT 'a'::"char"::text;
---END---
---START---
SELECT '\377'::"char"::text;
---END---
---START---
SELECT '\000'::"char"::text;
---END---
---START---
SELECT 'a'::text::"char";
---END---
---START---
SELECT '\377'::text::"char";
---END---
---START---
SELECT ''::text::"char";
---END---
