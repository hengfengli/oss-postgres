---START---
--
-- INT4
--

-- int4_tbl was already created and filled in test_setup.sql.
-- Here we just try to insert bad values.

INSERT INTO INT4_TBL(f1) VALUES ('34.5');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('1000000000000');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('asdf');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('     ');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('   asdf   ');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('- 1234');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('123       5');
---END---
---START---
INSERT INTO INT4_TBL(f1) VALUES ('');
---END---
---START---
SELECT * FROM INT4_TBL;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('34', 'int4');
---END---
---START---
SELECT pg_input_is_valid('asdf', 'int4');
---END---
---START---
SELECT pg_input_is_valid('1000000000000', 'int4');
---END---
---START---
SELECT * FROM pg_input_error_info('1000000000000', 'int4');
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 <> int2 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 <> int4 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 = int2 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 = int4 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 < int2 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 < int4 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 <= int2 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 <= int4 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 > int2 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 > int4 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 >= int2 '0';
---END---
---START---
SELECT i.* FROM INT4_TBL i WHERE i.f1 >= int4 '0';
---END---
---START---
-- positive odds
SELECT i.* FROM INT4_TBL i WHERE (i.f1 % int2 '2') = int2 '1';
---END---
---START---
-- any evens
SELECT i.* FROM INT4_TBL i WHERE (i.f1 % int4 '2') = int2 '0';
---END---
---START---
SELECT i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 * int2 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;
---END---
---START---
SELECT i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 * int4 '2' AS x FROM INT4_TBL i
WHERE abs(f1) < 1073741824;
---END---
---START---
SELECT i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 + int2 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;
---END---
---START---
SELECT i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 + int4 '2' AS x FROM INT4_TBL i
WHERE f1 < 2147483646;
---END---
---START---
SELECT i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 - int2 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;
---END---
---START---
SELECT i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 - int4 '2' AS x FROM INT4_TBL i
WHERE f1 > -2147483647;
---END---
---START---
SELECT i.f1, i.f1 / int2 '2' AS x FROM INT4_TBL i;
---END---
---START---
SELECT i.f1, i.f1 / int4 '2' AS x FROM INT4_TBL i;
---END---
---START---
--
-- more complex expressions
--

-- variations on unary minus parsing
SELECT -2+3 AS one;
---END---
---START---
SELECT 4-2 AS two;
---END---
---START---
SELECT 2- -1 AS three;
---END---
---START---
SELECT 2 - -2 AS four;
---END---
---START---
SELECT int2 '2' * int2 '2' = int2 '16' / int2 '4' AS true;
---END---
---START---
SELECT int4 '2' * int2 '2' = int2 '16' / int4 '4' AS true;
---END---
---START---
SELECT int2 '2' * int4 '2' = int4 '16' / int2 '4' AS true;
---END---
---START---
SELECT int4 '1000' < int4 '999' AS false;
---END---
---START---
SELECT 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 AS ten;
---END---
---START---
SELECT 2 + 2 / 2 AS three;
---END---
---START---
SELECT (2 + 2) / 2 AS two;
---END---
---START---
-- corner case
SELECT (-1::int4<<31)::text;
---END---
---START---
SELECT ((-1::int4<<31)+1)::text;
---END---
---START---
-- check sane handling of INT_MIN overflow cases
SELECT (-2147483648)::int4 * (-1)::int4;
---END---
---START---
SELECT (-2147483648)::int4 / (-1)::int4;
---END---
---START---
SELECT (-2147483648)::int4 % (-1)::int4;
---END---
---START---
SELECT (-2147483648)::int4 * (-1)::int2;
---END---
---START---
SELECT (-2147483648)::int4 / (-1)::int2;
---END---
---START---
SELECT (-2147483648)::int4 % (-1)::int2;
---END---
---START---
-- check rounding when casting from float
SELECT x, x::int4 AS int4_value
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
SELECT x, x::int4 AS int4_value
FROM (VALUES (-2.5::numeric),
             (-1.5::numeric),
             (-0.5::numeric),
             (0.0::numeric),
             (0.5::numeric),
             (1.5::numeric),
             (2.5::numeric)) t(x);
---END---
---START---
-- test gcd()
SELECT a, b, gcd(a, b), gcd(a, -b), gcd(b, a), gcd(-b, a)
FROM (VALUES (0::int4, 0::int4),
             (0::int4, 6410818::int4),
             (61866666::int4, 6410818::int4),
             (-61866666::int4, 6410818::int4),
             ((-2147483648)::int4, 1::int4),
             ((-2147483648)::int4, 2147483647::int4),
             ((-2147483648)::int4, 1073741824::int4)) AS v(a, b);
---END---
---START---
SELECT gcd((-2147483648)::int4, 0::int4);
---END---
---START---
-- overflow
SELECT gcd((-2147483648)::int4, (-2147483648)::int4);
---END---
---START---
-- overflow

-- test lcm()
SELECT a, b, lcm(a, b), lcm(a, -b), lcm(b, a), lcm(-b, a)
FROM (VALUES (0::int4, 0::int4),
             (0::int4, 42::int4),
             (42::int4, 42::int4),
             (330::int4, 462::int4),
             (-330::int4, 462::int4),
             ((-2147483648)::int4, 0::int4)) AS v(a, b);
---END---
---START---
SELECT lcm((-2147483648)::int4, 1::int4);
---END---
---START---
-- overflow
SELECT lcm(2147483647::int4, 2147483646::int4);
---END---
---START---
-- overflow


-- non-decimal literals

SELECT int4 '0b100101';
---END---
---START---
SELECT int4 '0o273';
---END---
---START---
SELECT int4 '0x42F';
---END---
---START---
SELECT int4 '0b';
---END---
---START---
SELECT int4 '0o';
---END---
---START---
SELECT int4 '0x';
---END---
---START---
-- cases near overflow
SELECT int4 '0b1111111111111111111111111111111';
---END---
---START---
SELECT int4 '0b10000000000000000000000000000000';
---END---
---START---
SELECT int4 '0o17777777777';
---END---
---START---
SELECT int4 '0o20000000000';
---END---
---START---
SELECT int4 '0x7FFFFFFF';
---END---
---START---
SELECT int4 '0x80000000';
---END---
---START---
SELECT int4 '-0b10000000000000000000000000000000';
---END---
---START---
SELECT int4 '-0b10000000000000000000000000000001';
---END---
---START---
SELECT int4 '-0o20000000000';
---END---
---START---
SELECT int4 '-0o20000000001';
---END---
---START---
SELECT int4 '-0x80000000';
---END---
---START---
SELECT int4 '-0x80000001';
---END---
---START---
-- underscores

SELECT int4 '1_000_000';
---END---
---START---
SELECT int4 '1_2_3';
---END---
---START---
SELECT int4 '0x1EEE_FFFF';
---END---
---START---
SELECT int4 '0o2_73';
---END---
---START---
SELECT int4 '0b_10_0101';
---END---
---START---
-- error cases
SELECT int4 '_100';
---END---
---START---
SELECT int4 '100_';
---END---
---START---
SELECT int4 '100__000';
---END---
