---START---
--
-- INT2
--

-- int2_tbl was already created and filled in test_setup.sql.
-- Here we just try to insert bad values.

INSERT INTO INT2_TBL(f1) VALUES ('34.5');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('100000');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('asdf');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('    ');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('- 1234');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('4 444');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('123 dt');
---END---
---START---
INSERT INTO INT2_TBL(f1) VALUES ('');
---END---
---START---


SELECT * FROM INT2_TBL;
---END---
---START---

-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('34', 'int2');
---END---
---START---
SELECT pg_input_is_valid('asdf', 'int2');
---END---
---START---
SELECT pg_input_is_valid('50000', 'int2');
---END---
---START---
SELECT * FROM pg_input_error_info('50000', 'int2');
---END---
---START---

-- While we're here, check int2vector as well
SELECT pg_input_is_valid(' 1 3  5 ', 'int2vector');
---END---
---START---
SELECT * FROM pg_input_error_info('1 asdf', 'int2vector');
---END---
---START---
SELECT * FROM pg_input_error_info('50000', 'int2vector');
---END---
---START---

SELECT * FROM INT2_TBL AS f(a, b);
---END---
---START---

SELECT * FROM (TABLE int2_tbl) AS s (a, b);
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 <> int2 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 <> int4 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 = int2 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 = int4 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 < int2 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 < int4 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 <= int2 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 <= int4 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 > int2 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 > int4 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 >= int2 '0';
---END---
---START---

SELECT i.* FROM INT2_TBL i WHERE i.f1 >= int4 '0';
---END---
---START---

-- positive odds
SELECT i.* FROM INT2_TBL i WHERE (i.f1 % int2 '2') = int2 '1';
---END---
---START---

-- any evens
SELECT i.* FROM INT2_TBL i WHERE (i.f1 % int4 '2') = int2 '0';
---END---
---START---

SELECT i.f1, i.f1 * int2 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 * int2 '2' AS x FROM INT2_TBL i
WHERE abs(f1) < 16384;
---END---
---START---

SELECT i.f1, i.f1 * int4 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 + int2 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 + int2 '2' AS x FROM INT2_TBL i
WHERE f1 < 32766;
---END---
---START---

SELECT i.f1, i.f1 + int4 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 - int2 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 - int2 '2' AS x FROM INT2_TBL i
WHERE f1 > -32767;
---END---
---START---

SELECT i.f1, i.f1 - int4 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 / int2 '2' AS x FROM INT2_TBL i;
---END---
---START---

SELECT i.f1, i.f1 / int4 '2' AS x FROM INT2_TBL i;
---END---
---START---

-- corner cases
SELECT (-1::int2<<15)::text;
---END---
---START---
SELECT ((-1::int2<<15)+1::int2)::text;
---END---
---START---

-- check sane handling of INT16_MIN overflow cases
SELECT (-32768)::int2 * (-1)::int2;
---END---
---START---
SELECT (-32768)::int2 / (-1)::int2;
---END---
---START---
SELECT (-32768)::int2 % (-1)::int2;
---END---
---START---

-- check rounding when casting from float
SELECT x, x::int2 AS int2_value
FROM (VALUES (-2.5::float8),
             (-1.5::float8),
             (-0.5::float8),
             (0.0::float8),
             (0.5::float8),
             (1.5::float8),
             (2.5::float8)) t(x);
---END---
---START---

-- check rounding when casting from numeric
SELECT x, x::int2 AS int2_value
FROM (VALUES (-2.5::numeric),
             (-1.5::numeric),
             (-0.5::numeric),
             (0.0::numeric),
             (0.5::numeric),
             (1.5::numeric),
             (2.5::numeric)) t(x);
---END---
---START---


-- non-decimal literals

SELECT int2 '0b100101';
---END---
---START---
SELECT int2 '0o273';
---END---
---START---
SELECT int2 '0x42F';
---END---
---START---

SELECT int2 '0b';
---END---
---START---
SELECT int2 '0o';
---END---
---START---
SELECT int2 '0x';
---END---
---START---

-- cases near overflow
SELECT int2 '0b111111111111111';
---END---
---START---
SELECT int2 '0b1000000000000000';
---END---
---START---
SELECT int2 '0o77777';
---END---
---START---
SELECT int2 '0o100000';
---END---
---START---
SELECT int2 '0x7FFF';
---END---
---START---
SELECT int2 '0x8000';
---END---
---START---

SELECT int2 '-0b1000000000000000';
---END---
---START---
SELECT int2 '-0b1000000000000001';
---END---
---START---
SELECT int2 '-0o100000';
---END---
---START---
SELECT int2 '-0o100001';
---END---
---START---
SELECT int2 '-0x8000';
---END---
---START---
SELECT int2 '-0x8001';
---END---
---START---


-- underscores

SELECT int2 '1_000';
---END---
---START---
SELECT int2 '1_2_3';
---END---
---START---
SELECT int2 '0xE_FF';
---END---
---START---
SELECT int2 '0o2_73';
---END---
---START---
SELECT int2 '0b_10_0101';
---END---
---START---

-- error cases
SELECT int2 '_100';
---END---
---START---
SELECT int2 '100_';
---END---
---START---
SELECT int2 '10__000';
---END---
