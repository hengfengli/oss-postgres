---START---
CREATE TABLE date_tbl (gemini_pk serial PRIMARY KEY, f1 date);
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1957-04-09');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1957-06-13');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1996-02-28');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1996-02-29');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1996-03-01');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1996-03-02');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1997-02-28');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1997-02-29');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1997-03-01');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('1997-03-02');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2000-04-01');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2000-04-02');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2000-04-03');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2038-04-08');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2039-04-09');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2040-04-10');
---END---
---START---
INSERT INTO DATE_TBL VALUES ('2040-04-10 BC');
---END---
---START---
SELECT f1 FROM DATE_TBL;
---END---
---START---
SELECT f1 FROM DATE_TBL WHERE f1 < '2000-01-01';
---END---
---START---
SELECT f1 FROM DATE_TBL
  WHERE f1 BETWEEN '2000-01-01' AND '2001-01-01';
---END---
---START---
--
-- Check all the documented input formats
--
SET datestyle TO iso;
---END---
---START---
-- display results in ISO

SET datestyle TO ymd;
---END---
---START---
SELECT date 'January 8, 1999';
---END---
---START---
SELECT date '1999-01-08';
---END---
---START---
SELECT date '1999-01-18';
---END---
---START---
SELECT date '1/8/1999';
---END---
---START---
SELECT date '1/18/1999';
---END---
---START---
SELECT date '18/1/1999';
---END---
---START---
SELECT date '01/02/03';
---END---
---START---
SELECT date '19990108';
---END---
---START---
SELECT date '990108';
---END---
---START---
SELECT date '1999.008';
---END---
---START---
SELECT date 'J2451187';
---END---
---START---
SELECT date 'January 8, 99 BC';
---END---
---START---
SELECT date '99-Jan-08';
---END---
---START---
SELECT date '1999-Jan-08';
---END---
---START---
SELECT date '08-Jan-99';
---END---
---START---
SELECT date '08-Jan-1999';
---END---
---START---
SELECT date 'Jan-08-99';
---END---
---START---
SELECT date 'Jan-08-1999';
---END---
---START---
SELECT date '99-08-Jan';
---END---
---START---
SELECT date '1999-08-Jan';
---END---
---START---
SELECT date '99 Jan 08';
---END---
---START---
SELECT date '1999 Jan 08';
---END---
---START---
SELECT date '08 Jan 99';
---END---
---START---
SELECT date '08 Jan 1999';
---END---
---START---
SELECT date 'Jan 08 99';
---END---
---START---
SELECT date 'Jan 08 1999';
---END---
---START---
SELECT date '99 08 Jan';
---END---
---START---
SELECT date '1999 08 Jan';
---END---
---START---
SELECT date '99-01-08';
---END---
---START---
SELECT date '1999-01-08';
---END---
---START---
SELECT date '08-01-99';
---END---
---START---
SELECT date '08-01-1999';
---END---
---START---
SELECT date '01-08-99';
---END---
---START---
SELECT date '01-08-1999';
---END---
---START---
SELECT date '99-08-01';
---END---
---START---
SELECT date '1999-08-01';
---END---
---START---
SELECT date '99 01 08';
---END---
---START---
SELECT date '1999 01 08';
---END---
---START---
SELECT date '08 01 99';
---END---
---START---
SELECT date '08 01 1999';
---END---
---START---
SELECT date '01 08 99';
---END---
---START---
SELECT date '01 08 1999';
---END---
---START---
SELECT date '99 08 01';
---END---
---START---
SELECT date '1999 08 01';
---END---
---START---
SET datestyle TO dmy;
---END---
---START---
SELECT date 'January 8, 1999';
---END---
---START---
SELECT date '1999-01-08';
---END---
---START---
SELECT date '1999-01-18';
---END---
---START---
SELECT date '1/8/1999';
---END---
---START---
SELECT date '1/18/1999';
---END---
---START---
SELECT date '18/1/1999';
---END---
---START---
SELECT date '01/02/03';
---END---
---START---
SELECT date '19990108';
---END---
---START---
SELECT date '990108';
---END---
---START---
SELECT date '1999.008';
---END---
---START---
SELECT date 'J2451187';
---END---
---START---
SELECT date 'January 8, 99 BC';
---END---
---START---
SELECT date '99-Jan-08';
---END---
---START---
SELECT date '1999-Jan-08';
---END---
---START---
SELECT date '08-Jan-99';
---END---
---START---
SELECT date '08-Jan-1999';
---END---
---START---
SELECT date 'Jan-08-99';
---END---
---START---
SELECT date 'Jan-08-1999';
---END---
---START---
SELECT date '99-08-Jan';
---END---
---START---
SELECT date '1999-08-Jan';
---END---
---START---
SELECT date '99 Jan 08';
---END---
---START---
SELECT date '1999 Jan 08';
---END---
---START---
SELECT date '08 Jan 99';
---END---
---START---
SELECT date '08 Jan 1999';
---END---
---START---
SELECT date 'Jan 08 99';
---END---
---START---
SELECT date 'Jan 08 1999';
---END---
---START---
SELECT date '99 08 Jan';
---END---
---START---
SELECT date '1999 08 Jan';
---END---
---START---
SELECT date '99-01-08';
---END---
---START---
SELECT date '1999-01-08';
---END---
---START---
SELECT date '08-01-99';
---END---
---START---
SELECT date '08-01-1999';
---END---
---START---
SELECT date '01-08-99';
---END---
---START---
SELECT date '01-08-1999';
---END---
---START---
SELECT date '99-08-01';
---END---
---START---
SELECT date '1999-08-01';
---END---
---START---
SELECT date '99 01 08';
---END---
---START---
SELECT date '1999 01 08';
---END---
---START---
SELECT date '08 01 99';
---END---
---START---
SELECT date '08 01 1999';
---END---
---START---
SELECT date '01 08 99';
---END---
---START---
SELECT date '01 08 1999';
---END---
---START---
SELECT date '99 08 01';
---END---
---START---
SELECT date '1999 08 01';
---END---
---START---
SET datestyle TO mdy;
---END---
---START---
SELECT date 'January 8, 1999';
---END---
---START---
SELECT date '1999-01-08';
---END---
---START---
SELECT date '1999-01-18';
---END---
---START---
SELECT date '1/8/1999';
---END---
---START---
SELECT date '1/18/1999';
---END---
---START---
SELECT date '18/1/1999';
---END---
---START---
SELECT date '01/02/03';
---END---
---START---
SELECT date '19990108';
---END---
---START---
SELECT date '990108';
---END---
---START---
SELECT date '1999.008';
---END---
---START---
SELECT date 'J2451187';
---END---
---START---
SELECT date 'January 8, 99 BC';
---END---
---START---
SELECT date '99-Jan-08';
---END---
---START---
SELECT date '1999-Jan-08';
---END---
---START---
SELECT date '08-Jan-99';
---END---
---START---
SELECT date '08-Jan-1999';
---END---
---START---
SELECT date 'Jan-08-99';
---END---
---START---
SELECT date 'Jan-08-1999';
---END---
---START---
SELECT date '99-08-Jan';
---END---
---START---
SELECT date '1999-08-Jan';
---END---
---START---
SELECT date '99 Jan 08';
---END---
---START---
SELECT date '1999 Jan 08';
---END---
---START---
SELECT date '08 Jan 99';
---END---
---START---
SELECT date '08 Jan 1999';
---END---
---START---
SELECT date 'Jan 08 99';
---END---
---START---
SELECT date 'Jan 08 1999';
---END---
---START---
SELECT date '99 08 Jan';
---END---
---START---
SELECT date '1999 08 Jan';
---END---
---START---
SELECT date '99-01-08';
---END---
---START---
SELECT date '1999-01-08';
---END---
---START---
SELECT date '08-01-99';
---END---
---START---
SELECT date '08-01-1999';
---END---
---START---
SELECT date '01-08-99';
---END---
---START---
SELECT date '01-08-1999';
---END---
---START---
SELECT date '99-08-01';
---END---
---START---
SELECT date '1999-08-01';
---END---
---START---
SELECT date '99 01 08';
---END---
---START---
SELECT date '1999 01 08';
---END---
---START---
SELECT date '08 01 99';
---END---
---START---
SELECT date '08 01 1999';
---END---
---START---
SELECT date '01 08 99';
---END---
---START---
SELECT date '01 08 1999';
---END---
---START---
SELECT date '99 08 01';
---END---
---START---
SELECT date '1999 08 01';
---END---
---START---
-- Check upper and lower limits of date range
SELECT date '4714-11-24 BC';
---END---
---START---
SELECT date '4714-11-23 BC';
---END---
---START---
-- out of range
SELECT date '5874897-12-31';
---END---
---START---
SELECT date '5874898-01-01';
---END---
---START---
-- out of range

-- Test non-error-throwing API
SELECT pg_input_is_valid('now', 'date');
---END---
---START---
SELECT pg_input_is_valid('garbage', 'date');
---END---
---START---
SELECT pg_input_is_valid('6874898-01-01', 'date');
---END---
---START---
SELECT * FROM pg_input_error_info('garbage', 'date');
---END---
---START---
SELECT * FROM pg_input_error_info('6874898-01-01', 'date');
---END---
---START---
RESET datestyle;
---END---
---START---
--
-- Simple math
-- Leave most of it for the horology tests
--

SELECT f1 - date '2000-01-01' AS "Days From 2K" FROM DATE_TBL;
---END---
---START---
SELECT f1 - date 'epoch' AS "Days From Epoch" FROM DATE_TBL;
---END---
---START---
SELECT date 'yesterday' - date 'today' AS "One day";
---END---
---START---
SELECT date 'today' - date 'tomorrow' AS "One day";
---END---
---START---
SELECT date 'yesterday' - date 'tomorrow' AS "Two days";
---END---
---START---
SELECT date 'tomorrow' - date 'today' AS "One day";
---END---
---START---
SELECT date 'today' - date 'yesterday' AS "One day";
---END---
---START---
SELECT date 'tomorrow' - date 'yesterday' AS "Two days";
---END---
---START---
--
-- test extract!
--
SELECT f1 as "date",
    date_part('year', f1) AS year,
    date_part('month', f1) AS month,
    date_part('day', f1) AS day,
    date_part('quarter', f1) AS quarter,
    date_part('decade', f1) AS decade,
    date_part('century', f1) AS century,
    date_part('millennium', f1) AS millennium,
    date_part('isoyear', f1) AS isoyear,
    date_part('week', f1) AS week,
    date_part('dow', f1) AS dow,
    date_part('isodow', f1) AS isodow,
    date_part('doy', f1) AS doy,
    date_part('julian', f1) AS julian,
    date_part('epoch', f1) AS epoch
    FROM date_tbl;
---END---
---START---
--
-- epoch
--
SELECT EXTRACT(EPOCH FROM DATE        '1970-01-01');
---END---
---START---
--  0
--
-- century
--
SELECT EXTRACT(CENTURY FROM DATE '0101-12-31 BC');
---END---
---START---
-- -2
SELECT EXTRACT(CENTURY FROM DATE '0100-12-31 BC');
---END---
---START---
-- -1
SELECT EXTRACT(CENTURY FROM DATE '0001-12-31 BC');
---END---
---START---
-- -1
SELECT EXTRACT(CENTURY FROM DATE '0001-01-01');
---END---
---START---
--  1
SELECT EXTRACT(CENTURY FROM DATE '0001-01-01 AD');
---END---
---START---
--  1
SELECT EXTRACT(CENTURY FROM DATE '1900-12-31');
---END---
---START---
-- 19
SELECT EXTRACT(CENTURY FROM DATE '1901-01-01');
---END---
---START---
-- 20
SELECT EXTRACT(CENTURY FROM DATE '2000-12-31');
---END---
---START---
-- 20
SELECT EXTRACT(CENTURY FROM DATE '2001-01-01');
---END---
---START---
-- 21
SELECT EXTRACT(CENTURY FROM CURRENT_DATE)>=21 AS True;
---END---
---START---
-- true
--
-- millennium
--
SELECT EXTRACT(MILLENNIUM FROM DATE '0001-12-31 BC');
---END---
---START---
-- -1
SELECT EXTRACT(MILLENNIUM FROM DATE '0001-01-01 AD');
---END---
---START---
--  1
SELECT EXTRACT(MILLENNIUM FROM DATE '1000-12-31');
---END---
---START---
--  1
SELECT EXTRACT(MILLENNIUM FROM DATE '1001-01-01');
---END---
---START---
--  2
SELECT EXTRACT(MILLENNIUM FROM DATE '2000-12-31');
---END---
---START---
--  2
SELECT EXTRACT(MILLENNIUM FROM DATE '2001-01-01');
---END---
---START---
--  3
-- next test to be fixed on the turn of the next millennium;-)
SELECT EXTRACT(MILLENNIUM FROM CURRENT_DATE);
---END---
---START---
--  3
--
-- decade
--
SELECT EXTRACT(DECADE FROM DATE '1994-12-25');
---END---
---START---
-- 199
SELECT EXTRACT(DECADE FROM DATE '0010-01-01');
---END---
---START---
--   1
SELECT EXTRACT(DECADE FROM DATE '0009-12-31');
---END---
---START---
--   0
SELECT EXTRACT(DECADE FROM DATE '0001-01-01 BC');
---END---
---START---
--   0
SELECT EXTRACT(DECADE FROM DATE '0002-12-31 BC');
---END---
---START---
--  -1
SELECT EXTRACT(DECADE FROM DATE '0011-01-01 BC');
---END---
---START---
--  -1
SELECT EXTRACT(DECADE FROM DATE '0012-12-31 BC');
---END---
---START---
--  -2
--
-- all possible fields
--
SELECT EXTRACT(MICROSECONDS  FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(MILLISECONDS  FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(SECOND        FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(MINUTE        FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(HOUR          FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(DAY           FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(MONTH         FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(YEAR          FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(YEAR          FROM DATE '2020-08-11 BC');
---END---
---START---
SELECT EXTRACT(DECADE        FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(CENTURY       FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(MILLENNIUM    FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(ISOYEAR       FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(ISOYEAR       FROM DATE '2020-08-11 BC');
---END---
---START---
SELECT EXTRACT(QUARTER       FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(WEEK          FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(DOW           FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(DOW           FROM DATE '2020-08-16');
---END---
---START---
SELECT EXTRACT(ISODOW        FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(ISODOW        FROM DATE '2020-08-16');
---END---
---START---
SELECT EXTRACT(DOY           FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(TIMEZONE      FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(TIMEZONE_M    FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(TIMEZONE_H    FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(EPOCH         FROM DATE '2020-08-11');
---END---
---START---
SELECT EXTRACT(JULIAN        FROM DATE '2020-08-11');
---END---
---START---
--
-- test trunc function!
--
SELECT DATE_TRUNC('MILLENNIUM', TIMESTAMP '1970-03-20 04:30:00.00000');
---END---
---START---
-- 1001
SELECT DATE_TRUNC('MILLENNIUM', DATE '1970-03-20');
---END---
---START---
-- 1001-01-01
SELECT DATE_TRUNC('CENTURY', TIMESTAMP '1970-03-20 04:30:00.00000');
---END---
---START---
-- 1901
SELECT DATE_TRUNC('CENTURY', DATE '1970-03-20');
---END---
---START---
-- 1901
SELECT DATE_TRUNC('CENTURY', DATE '2004-08-10');
---END---
---START---
-- 2001-01-01
SELECT DATE_TRUNC('CENTURY', DATE '0002-02-04');
---END---
---START---
-- 0001-01-01
SELECT DATE_TRUNC('CENTURY', DATE '0055-08-10 BC');
---END---
---START---
-- 0100-01-01 BC
SELECT DATE_TRUNC('DECADE', DATE '1993-12-25');
---END---
---START---
-- 1990-01-01
SELECT DATE_TRUNC('DECADE', DATE '0004-12-25');
---END---
---START---
-- 0001-01-01 BC
SELECT DATE_TRUNC('DECADE', DATE '0002-12-31 BC');
---END---
---START---
-- 0011-01-01 BC
--
-- test infinity
--
select 'infinity'::date, '-infinity'::date;
---END---
---START---
select 'infinity'::date > 'today'::date as t;
---END---
---START---
select '-infinity'::date < 'today'::date as t;
---END---
---START---
select isfinite('infinity'::date), isfinite('-infinity'::date), isfinite('today'::date);
---END---
---START---
select 'infinity'::date = '+infinity'::date as t;
---END---
---START---
--
-- oscillating fields from non-finite date:
--
SELECT EXTRACT(DAY FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(DAY FROM DATE '-infinity');
---END---
---START---
-- NULL
-- all supported fields
SELECT EXTRACT(DAY           FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(MONTH         FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(QUARTER       FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(WEEK          FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(DOW           FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(ISODOW        FROM DATE 'infinity');
---END---
---START---
-- NULL
SELECT EXTRACT(DOY           FROM DATE 'infinity');
---END---
---START---
-- NULL
--
-- monotonic fields from non-finite date:
--
SELECT EXTRACT(EPOCH FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(EPOCH FROM DATE '-infinity');
---END---
---START---
-- -Infinity
-- all supported fields
SELECT EXTRACT(YEAR       FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(DECADE     FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(CENTURY    FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(MILLENNIUM FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(JULIAN     FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(ISOYEAR    FROM DATE 'infinity');
---END---
---START---
--  Infinity
SELECT EXTRACT(EPOCH      FROM DATE 'infinity');
---END---
---START---
--  Infinity
--
-- wrong fields from non-finite date:
--
SELECT EXTRACT(MICROSEC  FROM DATE 'infinity');
---END---
---START---
-- error

-- test constructors
select make_date(2013, 7, 15);
---END---
---START---
select make_date(-44, 3, 15);
---END---
---START---
select make_time(8, 20, 0.0);
---END---
---START---
-- should fail
select make_date(0, 7, 15);
---END---
---START---
select make_date(2013, 2, 30);
---END---
---START---
select make_date(2013, 13, 1);
---END---
---START---
select make_date(2013, 11, -1);
---END---
---START---
select make_time(10, 55, 100.1);
---END---
---START---
select make_time(24, 0, 2.1);
---END---
