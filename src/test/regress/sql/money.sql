---START---
CREATE TABLE money_data (_gemini_pk serial PRIMARY KEY, m money);
---END---
---START---
INSERT INTO money_data VALUES ('123');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
SELECT m + '123' FROM money_data;
---END---
---START---
SELECT m + '123.45' FROM money_data;
---END---
---START---
SELECT m - '123.45' FROM money_data;
---END---
---START---
SELECT m / '2'::money FROM money_data;
---END---
---START---
SELECT m * 2 FROM money_data;
---END---
---START---
SELECT 2 * m FROM money_data;
---END---
---START---
SELECT m / 2 FROM money_data;
---END---
---START---
SELECT m * 2::int2 FROM money_data;
---END---
---START---
SELECT 2::int2 * m FROM money_data;
---END---
---START---
SELECT m / 2::int2 FROM money_data;
---END---
---START---
SELECT m * 2::int8 FROM money_data;
---END---
---START---
SELECT 2::int8 * m FROM money_data;
---END---
---START---
SELECT m / 2::int8 FROM money_data;
---END---
---START---
SELECT m * 2::float8 FROM money_data;
---END---
---START---
SELECT 2::float8 * m FROM money_data;
---END---
---START---
SELECT m / 2::float8 FROM money_data;
---END---
---START---
SELECT m * 2::float4 FROM money_data;
---END---
---START---
SELECT 2::float4 * m FROM money_data;
---END---
---START---
SELECT m / 2::float4 FROM money_data;
---END---
---START---
-- All true
SELECT m = '$123.00' FROM money_data;
---END---
---START---
SELECT m != '$124.00' FROM money_data;
---END---
---START---
SELECT m <= '$123.00' FROM money_data;
---END---
---START---
SELECT m >= '$123.00' FROM money_data;
---END---
---START---
SELECT m < '$124.00' FROM money_data;
---END---
---START---
SELECT m > '$122.00' FROM money_data;
---END---
---START---
-- All false
SELECT m = '$123.01' FROM money_data;
---END---
---START---
SELECT m != '$123.00' FROM money_data;
---END---
---START---
SELECT m <= '$122.99' FROM money_data;
---END---
---START---
SELECT m >= '$123.01' FROM money_data;
---END---
---START---
SELECT m > '$124.00' FROM money_data;
---END---
---START---
SELECT m < '$122.00' FROM money_data;
---END---
---START---
SELECT cashlarger(m, '$124.00') FROM money_data;
---END---
---START---
SELECT cashsmaller(m, '$124.00') FROM money_data;
---END---
---START---
SELECT cash_words(m) FROM money_data;
---END---
---START---
SELECT cash_words(m + '1.23') FROM money_data;
---END---
---START---
DELETE FROM money_data;
---END---
---START---
INSERT INTO money_data VALUES ('$123.45');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
DELETE FROM money_data;
---END---
---START---
INSERT INTO money_data VALUES ('$123.451');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
DELETE FROM money_data;
---END---
---START---
INSERT INTO money_data VALUES ('$123.454');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
DELETE FROM money_data;
---END---
---START---
INSERT INTO money_data VALUES ('$123.455');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
DELETE FROM money_data;
---END---
---START---
INSERT INTO money_data VALUES ('$123.456');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
DELETE FROM money_data;
---END---
---START---
INSERT INTO money_data VALUES ('$123.459');
---END---
---START---
SELECT * FROM money_data;
---END---
---START---
-- input checks
SELECT '1234567890'::money;
---END---
---START---
SELECT '12345678901234567'::money;
---END---
---START---
SELECT '123456789012345678'::money;
---END---
---START---
SELECT '9223372036854775807'::money;
---END---
---START---
SELECT '-12345'::money;
---END---
---START---
SELECT '-1234567890'::money;
---END---
---START---
SELECT '-12345678901234567'::money;
---END---
---START---
SELECT '-123456789012345678'::money;
---END---
---START---
SELECT '-9223372036854775808'::money;
---END---
---START---
-- special characters
SELECT '(1)'::money;
---END---
---START---
SELECT '($123,456.78)'::money;
---END---
---START---
-- test non-error-throwing API
SELECT pg_input_is_valid('\x0001', 'money');
---END---
---START---
SELECT * FROM pg_input_error_info('\x0001', 'money');
---END---
---START---
SELECT pg_input_is_valid('192233720368547758.07', 'money');
---END---
---START---
SELECT * FROM pg_input_error_info('192233720368547758.07', 'money');
---END---
---START---
-- documented minimums and maximums
SELECT '-92233720368547758.08'::money;
---END---
---START---
SELECT '92233720368547758.07'::money;
---END---
---START---
SELECT '-92233720368547758.09'::money;
---END---
---START---
SELECT '92233720368547758.08'::money;
---END---
---START---
-- rounding
SELECT '-92233720368547758.085'::money;
---END---
---START---
SELECT '92233720368547758.075'::money;
---END---
---START---
-- rounding vs. truncation in division
SELECT '878.08'::money / 11::float8;
---END---
---START---
SELECT '878.08'::money / 11::float4;
---END---
---START---
SELECT '878.08'::money / 11::bigint;
---END---
---START---
SELECT '878.08'::money / 11::int;
---END---
---START---
SELECT '878.08'::money / 11::smallint;
---END---
---START---
-- check for precision loss in division
SELECT '90000000000000099.00'::money / 10::bigint;
---END---
---START---
SELECT '90000000000000099.00'::money / 10::int;
---END---
---START---
SELECT '90000000000000099.00'::money / 10::smallint;
---END---
---START---
-- Cast int4/int8/numeric to money
SELECT 1234567890::money;
---END---
---START---
SELECT 12345678901234567::money;
---END---
---START---
SELECT (-12345)::money;
---END---
---START---
SELECT (-1234567890)::money;
---END---
---START---
SELECT (-12345678901234567)::money;
---END---
---START---
SELECT 1234567890::int4::money;
---END---
---START---
SELECT 12345678901234567::int8::money;
---END---
---START---
SELECT 12345678901234567::numeric::money;
---END---
---START---
SELECT (-1234567890)::int4::money;
---END---
---START---
SELECT (-12345678901234567)::int8::money;
---END---
---START---
SELECT (-12345678901234567)::numeric::money;
---END---
---START---
-- Cast from money to numeric
SELECT '12345678901234567'::money::numeric;
---END---
---START---
SELECT '-12345678901234567'::money::numeric;
---END---
---START---
SELECT '92233720368547758.07'::money::numeric;
---END---
---START---
SELECT '-92233720368547758.08'::money::numeric;
---END---
