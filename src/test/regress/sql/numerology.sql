---START---
--
-- NUMEROLOGY
-- Test various combinations of numeric types and functions.
--


--
-- numeric literals
--

SELECT 0b100101;
---END---
---START---
SELECT 0o273;
---END---
---START---
SELECT 0x42F;
---END---
---START---
-- cases near int4 overflow
SELECT 0b1111111111111111111111111111111;
---END---
---START---
SELECT 0b10000000000000000000000000000000;
---END---
---START---
SELECT 0o17777777777;
---END---
---START---
SELECT 0o20000000000;
---END---
---START---
SELECT 0x7FFFFFFF;
---END---
---START---
SELECT 0x80000000;
---END---
---START---
SELECT -0b10000000000000000000000000000000;
---END---
---START---
SELECT -0b10000000000000000000000000000001;
---END---
---START---
SELECT -0o20000000000;
---END---
---START---
SELECT -0o20000000001;
---END---
---START---
SELECT -0x80000000;
---END---
---START---
SELECT -0x80000001;
---END---
---START---
-- cases near int8 overflow
SELECT 0b111111111111111111111111111111111111111111111111111111111111111;
---END---
---START---
SELECT 0b1000000000000000000000000000000000000000000000000000000000000000;
---END---
---START---
SELECT 0o777777777777777777777;
---END---
---START---
SELECT 0o1000000000000000000000;
---END---
---START---
SELECT 0x7FFFFFFFFFFFFFFF;
---END---
---START---
SELECT 0x8000000000000000;
---END---
---START---
SELECT -0b1000000000000000000000000000000000000000000000000000000000000000;
---END---
---START---
SELECT -0b1000000000000000000000000000000000000000000000000000000000000001;
---END---
---START---
SELECT -0o1000000000000000000000;
---END---
---START---
SELECT -0o1000000000000000000001;
---END---
---START---
SELECT -0x8000000000000000;
---END---
---START---
SELECT -0x8000000000000001;
---END---
---START---
-- error cases
SELECT 123abc;
---END---
---START---
SELECT 0x0o;
---END---
---START---
SELECT 0.a;
---END---
---START---
SELECT 0.0a;
---END---
---START---
SELECT .0a;
---END---
---START---
SELECT 0.0e1a;
---END---
---START---
SELECT 0.0e;
---END---
---START---
SELECT 0.0e+a;
---END---
---START---
PREPARE p1 AS SELECT $1a;
---END---
---START---
SELECT 0b;
---END---
---START---
SELECT 1b;
---END---
---START---
SELECT 0b0x;
---END---
---START---
SELECT 0o;
---END---
---START---
SELECT 1o;
---END---
---START---
SELECT 0o0x;
---END---
---START---
SELECT 0x;
---END---
---START---
SELECT 1x;
---END---
---START---
SELECT 0x0y;
---END---
---START---
-- underscores
SELECT 1_000_000;
---END---
---START---
SELECT 1_2_3;
---END---
---START---
SELECT 0x1EEE_FFFF;
---END---
---START---
SELECT 0o2_73;
---END---
---START---
SELECT 0b_10_0101;
---END---
---START---
SELECT 1_000.000_005;
---END---
---START---
SELECT 1_000.;
---END---
---START---
SELECT .000_005;
---END---
---START---
SELECT 1_000.5e0_1;
---END---
---START---
-- error cases
SELECT _100;
---END---
---START---
SELECT 100_;
---END---
---START---
SELECT 100__000;
---END---
---START---
SELECT _1_000.5;
---END---
---START---
SELECT 1_000_.5;
---END---
---START---
SELECT 1_000._5;
---END---
---START---
SELECT 1_000.5_;
---END---
---START---
SELECT 1_000.5e_1;
---END---
---START---
CREATE TABLE temp_float (_gemini_pk serial PRIMARY KEY, f1 float8);
---END---
---START---
INSERT INTO TEMP_FLOAT (f1)
  SELECT float8(f1) FROM INT4_TBL;
---END---
---START---
INSERT INTO TEMP_FLOAT (f1)
  SELECT float8(f1) FROM INT2_TBL;
---END---
---START---
SELECT f1 FROM TEMP_FLOAT
  ORDER BY f1;
---END---
---START---
CREATE TABLE temp_int4 (_gemini_pk serial PRIMARY KEY, f1 int4);
---END---
---START---
INSERT INTO TEMP_INT4 (f1)
  SELECT int4(f1) FROM FLOAT8_TBL
  WHERE (f1 > -2147483647) AND (f1 < 2147483647);
---END---
---START---
INSERT INTO TEMP_INT4 (f1)
  SELECT int4(f1) FROM INT2_TBL;
---END---
---START---
SELECT f1 FROM TEMP_INT4
  ORDER BY f1;
---END---
---START---
CREATE TABLE temp_int2 (_gemini_pk serial PRIMARY KEY, f1 int2);
---END---
---START---
INSERT INTO TEMP_INT2 (f1)
  SELECT int2(f1) FROM FLOAT8_TBL
  WHERE (f1 >= -32767) AND (f1 <= 32767);
---END---
---START---
INSERT INTO TEMP_INT2 (f1)
  SELECT int2(f1) FROM INT4_TBL
  WHERE (f1 >= -32767) AND (f1 <= 32767);
---END---
---START---
SELECT f1 FROM TEMP_INT2
  ORDER BY f1;
---END---
---START---
CREATE TABLE temp_group (_gemini_pk serial PRIMARY KEY, f1 int4, f2 int4, f3 float8);
---END---
---START---
INSERT INTO TEMP_GROUP
  SELECT 1, (- i.f1), (- f.f1)
  FROM INT4_TBL i, FLOAT8_TBL f;
---END---
---START---
INSERT INTO TEMP_GROUP
  SELECT 2, i.f1, f.f1
  FROM INT4_TBL i, FLOAT8_TBL f;
---END---
---START---
SELECT DISTINCT f1 AS two FROM TEMP_GROUP ORDER BY 1;
---END---
---START---
SELECT f1 AS two, max(f3) AS max_float, min(f3) as min_float
  FROM TEMP_GROUP
  GROUP BY f1
  ORDER BY two, max_float, min_float;
---END---
---START---
-- GROUP BY a result column name is not legal per SQL92, but we accept it
-- anyway (if the name is not the name of any column exposed by FROM).
SELECT f1 AS two, max(f3) AS max_float, min(f3) AS min_float
  FROM TEMP_GROUP
  GROUP BY two
  ORDER BY two, max_float, min_float;
---END---
---START---
SELECT f1 AS two, (max(f3) + 1) AS max_plus_1, (min(f3) - 1) AS min_minus_1
  FROM TEMP_GROUP
  GROUP BY f1
  ORDER BY two, min_minus_1;
---END---
---START---
SELECT f1 AS two,
       max(f2) + min(f2) AS max_plus_min,
       min(f3) - 1 AS min_minus_1
  FROM TEMP_GROUP
  GROUP BY f1
  ORDER BY two, min_minus_1;
---END---
---START---
DROP TABLE TEMP_INT2;
---END---
---START---
DROP TABLE TEMP_INT4;
---END---
---START---
DROP TABLE TEMP_FLOAT;
---END---
---START---
DROP TABLE TEMP_GROUP;
---END---
