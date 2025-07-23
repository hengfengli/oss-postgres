---START---
--
-- VARCHAR
--

--
-- Build a table for testing
-- (This temporarily hides the table created in test_setup.sql)
--

CREATE TEMP TABLE VARCHAR_TBL(f1 varchar(1));
---END---
---START---

INSERT INTO VARCHAR_TBL (f1) VALUES ('a');
---END---
---START---

INSERT INTO VARCHAR_TBL (f1) VALUES ('A');
---END---
---START---

-- any of the following three input formats are acceptable
INSERT INTO VARCHAR_TBL (f1) VALUES ('1');
---END---
---START---

INSERT INTO VARCHAR_TBL (f1) VALUES (2);
---END---
---START---

INSERT INTO VARCHAR_TBL (f1) VALUES ('3');
---END---
---START---

-- zero-length char
INSERT INTO VARCHAR_TBL (f1) VALUES ('');
---END---
---START---

-- try varchar's of greater than 1 length
INSERT INTO VARCHAR_TBL (f1) VALUES ('cd');
---END---
---START---
INSERT INTO VARCHAR_TBL (f1) VALUES ('c     ');
---END---
---START---


SELECT * FROM VARCHAR_TBL;
---END---
---START---

SELECT c.*
   FROM VARCHAR_TBL c
   WHERE c.f1 <> 'a';
---END---
---START---

SELECT c.*
   FROM VARCHAR_TBL c
   WHERE c.f1 = 'a';
---END---
---START---

SELECT c.*
   FROM VARCHAR_TBL c
   WHERE c.f1 < 'a';
---END---
---START---

SELECT c.*
   FROM VARCHAR_TBL c
   WHERE c.f1 <= 'a';
---END---
---START---

SELECT c.*
   FROM VARCHAR_TBL c
   WHERE c.f1 > 'a';
---END---
---START---

SELECT c.*
   FROM VARCHAR_TBL c
   WHERE c.f1 >= 'a';
---END---
---START---

DROP TABLE VARCHAR_TBL;
---END---
---START---

--
-- Now test longer arrays of char
--
-- This varchar_tbl was already created and filled in test_setup.sql.
-- Here we just try to insert bad values.
--

INSERT INTO VARCHAR_TBL (f1) VALUES ('abcde');
---END---
---START---

SELECT * FROM VARCHAR_TBL;
---END---
---START---

-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('abcd  ', 'varchar(4)');
---END---
---START---
SELECT pg_input_is_valid('abcde', 'varchar(4)');
---END---
---START---
SELECT * FROM pg_input_error_info('abcde', 'varchar(4)');
---END---
