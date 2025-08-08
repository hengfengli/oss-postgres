---START---
CREATE TABLE timestamptz_tbl (_gemini_pk serial PRIMARY KEY, d1 timestamp(2) with time zone);
---END---
---START---
-- Test shorthand input values
-- We can't just "select" the results since they aren't constants; test for
-- equality instead.  We can do that by running the test inside a transaction
-- block, within which the value of 'now' shouldn't change, and so these
-- related values shouldn't either.

BEGIN;
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('today');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('yesterday');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('tomorrow');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('tomorrow EST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('tomorrow zulu');
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMPTZ_TBL WHERE d1 = timestamp with time zone 'today';
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMPTZ_TBL WHERE d1 = timestamp with time zone 'tomorrow';
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMPTZ_TBL WHERE d1 = timestamp with time zone 'yesterday';
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMPTZ_TBL WHERE d1 = timestamp with time zone 'tomorrow EST';
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMPTZ_TBL WHERE d1 = timestamp with time zone 'tomorrow zulu';
---END---
---START---
COMMIT;
---END---
---START---
DELETE FROM TIMESTAMPTZ_TBL;
---END---
---START---
-- Verify that 'now' *does* change over a reasonable interval such as 100 msec,
-- and that it doesn't change over the same interval within a transaction block

INSERT INTO TIMESTAMPTZ_TBL VALUES ('now');
---END---
---START---
SELECT pg_sleep(0.1);
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('now');
---END---
---START---
SELECT pg_sleep(0.1);
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('now');
---END---
---START---
SELECT pg_sleep(0.1);
---END---
---START---
SELECT count(*) AS two FROM TIMESTAMPTZ_TBL WHERE d1 = timestamp(2) with time zone 'now';
---END---
---START---
SELECT count(d1) AS three, count(DISTINCT d1) AS two FROM TIMESTAMPTZ_TBL;
---END---
---START---
COMMIT;
---END---
---START---
TRUNCATE TIMESTAMPTZ_TBL;
---END---
---START---
-- Special values
INSERT INTO TIMESTAMPTZ_TBL VALUES ('-infinity');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('infinity');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('epoch');
---END---
---START---
SELECT timestamptz 'infinity' = timestamptz '+infinity' AS t;
---END---
---START---
-- Postgres v6.0 standard output format
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mon Feb 10 17:32:01 1997 PST');
---END---
---START---
-- Variations on Postgres v6.1 standard output format
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mon Feb 10 17:32:01.000001 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mon Feb 10 17:32:01.999999 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mon Feb 10 17:32:01.4 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mon Feb 10 17:32:01.5 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mon Feb 10 17:32:01.6 1997 PST');
---END---
---START---
-- ISO 8601 format
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-01-02');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-01-02 03:04:05');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-02-10 17:32:01-08');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-02-10 17:32:01-0800');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-02-10 17:32:01 -08:00');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('19970210 173201 -0800');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-06-10 17:32:01 -07:00');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('2001-09-22T18:19:20');
---END---
---START---
-- POSIX format (note that the timezone abbrev is just decoration here)
INSERT INTO TIMESTAMPTZ_TBL VALUES ('2000-03-15 08:14:01 GMT+8');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('2000-03-15 13:14:02 GMT-1');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('2000-03-15 12:14:03 GMT-2');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('2000-03-15 03:14:04 PST+8');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('2000-03-15 02:14:05 MST+7:00');
---END---
---START---
-- Variations for acceptable input formats
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 10 17:32:01 1997 -0800');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 10 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 10 5:32PM 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997/02/10 17:32:01-0800');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-02-10 17:32:01 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb-10-1997 17:32:01 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('02-10-1997 17:32:01 PST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('19970210 173201 PST');
---END---
---START---
set datestyle to ymd;
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('97FEB10 5:32:01PM UTC');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('97/02/10 17:32:01 UTC');
---END---
---START---
reset datestyle;
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997.041 17:32:01 UTC');
---END---
---START---
-- timestamps at different timezones
INSERT INTO TIMESTAMPTZ_TBL VALUES ('19970210 173201 America/New_York');
---END---
---START---
SELECT '19970210 173201' AT TIME ZONE 'America/New_York';
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('19970710 173201 America/New_York');
---END---
---START---
SELECT '19970710 173201' AT TIME ZONE 'America/New_York';
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('19970710 173201 America/Does_not_exist');
---END---
---START---
SELECT '19970710 173201' AT TIME ZONE 'America/Does_not_exist';
---END---
---START---
-- Daylight saving time for timestamps beyond 32-bit time_t range.
SELECT '20500710 173201 Europe/Helsinki'::timestamptz;
---END---
---START---
-- DST
SELECT '20500110 173201 Europe/Helsinki'::timestamptz;
---END---
---START---
-- non-DST

SELECT '205000-07-10 17:32:01 Europe/Helsinki'::timestamptz;
---END---
---START---
-- DST
SELECT '205000-01-10 17:32:01 Europe/Helsinki'::timestamptz;
---END---
---START---
-- non-DST

-- Test non-error-throwing API
SELECT pg_input_is_valid('now', 'timestamptz');
---END---
---START---
SELECT pg_input_is_valid('garbage', 'timestamptz');
---END---
---START---
SELECT pg_input_is_valid('2001-01-01 00:00 Nehwon/Lankhmar', 'timestamptz');
---END---
---START---
SELECT * FROM pg_input_error_info('garbage', 'timestamptz');
---END---
---START---
SELECT * FROM pg_input_error_info('2001-01-01 00:00 Nehwon/Lankhmar', 'timestamptz');
---END---
---START---
-- Check date conversion and date arithmetic
INSERT INTO TIMESTAMPTZ_TBL VALUES ('1997-06-10 18:32:01 PDT');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 10 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 11 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 12 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 13 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 14 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 15 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 0097 BC');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 0097');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 0597');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 1097');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 1697');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 1797');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 1897');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 2097');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 28 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 29 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mar 01 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Dec 30 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Dec 31 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Jan 01 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 28 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 29 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Mar 01 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Dec 30 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Dec 31 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Dec 31 17:32:01 1999');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Jan 01 17:32:01 2000');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Dec 31 17:32:01 2000');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Jan 01 17:32:01 2001');
---END---
---START---
-- Currently unsupported syntax and ranges
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 -0097');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TBL VALUES ('Feb 16 17:32:01 5097 BC');
---END---
---START---
-- Alternative field order that we've historically supported (sort of)
-- with regular and POSIXy timezone specs
SELECT 'Wed Jul 11 10:51:14 America/New_York 2001'::timestamptz;
---END---
---START---
SELECT 'Wed Jul 11 10:51:14 GMT-4 2001'::timestamptz;
---END---
---START---
SELECT 'Wed Jul 11 10:51:14 GMT+4 2001'::timestamptz;
---END---
---START---
SELECT 'Wed Jul 11 10:51:14 PST-03:00 2001'::timestamptz;
---END---
---START---
SELECT 'Wed Jul 11 10:51:14 PST+03:00 2001'::timestamptz;
---END---
---START---
SELECT d1 FROM TIMESTAMPTZ_TBL;
---END---
---START---
-- Check behavior at the boundaries of the timestamp range
SELECT '4714-11-24 00:00:00+00 BC'::timestamptz;
---END---
---START---
SELECT '4714-11-23 16:00:00-08 BC'::timestamptz;
---END---
---START---
SELECT 'Sun Nov 23 16:00:00 4714 PST BC'::timestamptz;
---END---
---START---
SELECT '4714-11-23 23:59:59+00 BC'::timestamptz;
---END---
---START---
-- out of range
SELECT '294276-12-31 23:59:59+00'::timestamptz;
---END---
---START---
SELECT '294276-12-31 15:59:59-08'::timestamptz;
---END---
---START---
SELECT '294277-01-01 00:00:00+00'::timestamptz;
---END---
---START---
-- out of range
SELECT '294277-12-31 16:00:00-08'::timestamptz;
---END---
---START---
-- out of range

-- Demonstrate functions and operators
SELECT d1 FROM TIMESTAMPTZ_TBL
   WHERE d1 > timestamp with time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMPTZ_TBL
   WHERE d1 < timestamp with time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMPTZ_TBL
   WHERE d1 = timestamp with time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMPTZ_TBL
   WHERE d1 != timestamp with time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMPTZ_TBL
   WHERE d1 <= timestamp with time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMPTZ_TBL
   WHERE d1 >= timestamp with time zone '1997-01-02';
---END---
---START---
SELECT d1 - timestamp with time zone '1997-01-02' AS diff
   FROM TIMESTAMPTZ_TBL WHERE d1 BETWEEN '1902-01-01' AND '2038-01-01';
---END---
---START---
SELECT date_trunc( 'week', timestamp with time zone '2004-02-29 15:44:17.71393' ) AS week_trunc;
---END---
---START---
SELECT date_trunc('day', timestamp with time zone '2001-02-16 20:38:40+00', 'Australia/Sydney') as sydney_trunc;
---END---
---START---
-- zone name
SELECT date_trunc('day', timestamp with time zone '2001-02-16 20:38:40+00', 'GMT') as gmt_trunc;
---END---
---START---
-- fixed-offset abbreviation
SELECT date_trunc('day', timestamp with time zone '2001-02-16 20:38:40+00', 'VET') as vet_trunc;
---END---
---START---
-- variable-offset abbreviation

-- verify date_bin behaves the same as date_trunc for relevant intervals
SELECT
  str,
  interval,
  date_trunc(str, ts, 'Australia/Sydney') = date_bin(interval::interval, ts, timestamp with time zone '2001-01-01+11') AS equal
FROM (
  VALUES
  ('day', '1 d'),
  ('hour', '1 h'),
  ('minute', '1 m'),
  ('second', '1 s'),
  ('millisecond', '1 ms'),
  ('microsecond', '1 us')
) intervals (str, interval),
(VALUES (timestamptz '2020-02-29 15:44:17.71393+00')) ts (ts);
---END---
---START---
-- bin timestamps into arbitrary intervals
SELECT
  interval,
  ts,
  origin,
  date_bin(interval::interval, ts, origin)
FROM (
  VALUES
  ('15 days'),
  ('2 hours'),
  ('1 hour 30 minutes'),
  ('15 minutes'),
  ('10 seconds'),
  ('100 milliseconds'),
  ('250 microseconds')
) intervals (interval),
(VALUES (timestamptz '2020-02-11 15:44:17.71393')) ts (ts),
(VALUES (timestamptz '2001-01-01')) origin (origin);
---END---
---START---
-- shift bins using the origin parameter:
SELECT date_bin('5 min'::interval, timestamptz '2020-02-01 01:01:01+00', timestamptz '2020-02-01 00:02:30+00');
---END---
---START---
-- disallow intervals with months or years
SELECT date_bin('5 months'::interval, timestamp with time zone '2020-02-01 01:01:01+00', timestamp with time zone '2001-01-01+00');
---END---
---START---
SELECT date_bin('5 years'::interval,  timestamp with time zone '2020-02-01 01:01:01+00', timestamp with time zone '2001-01-01+00');
---END---
---START---
-- disallow zero intervals
SELECT date_bin('0 days'::interval, timestamp with time zone '1970-01-01 01:00:00+00' , timestamp with time zone '1970-01-01 00:00:00+00');
---END---
---START---
-- disallow negative intervals
SELECT date_bin('-2 days'::interval, timestamp with time zone '1970-01-01 01:00:00+00' , timestamp with time zone '1970-01-01 00:00:00+00');
---END---
---START---
-- Test casting within a BETWEEN qualifier
SELECT d1 - timestamp with time zone '1997-01-02' AS diff
  FROM TIMESTAMPTZ_TBL
  WHERE d1 BETWEEN timestamp with time zone '1902-01-01' AND timestamp with time zone '2038-01-01';
---END---
---START---
-- DATE_PART (timestamptz_part)
SELECT d1 as timestamptz,
   date_part( 'year', d1) AS year, date_part( 'month', d1) AS month,
   date_part( 'day', d1) AS day, date_part( 'hour', d1) AS hour,
   date_part( 'minute', d1) AS minute, date_part( 'second', d1) AS second
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT d1 as timestamptz,
   date_part( 'quarter', d1) AS quarter, date_part( 'msec', d1) AS msec,
   date_part( 'usec', d1) AS usec
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT d1 as timestamptz,
   date_part( 'isoyear', d1) AS isoyear, date_part( 'week', d1) AS week,
   date_part( 'isodow', d1) AS isodow, date_part( 'dow', d1) AS dow,
   date_part( 'doy', d1) AS doy
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT d1 as timestamptz,
   date_part( 'decade', d1) AS decade,
   date_part( 'century', d1) AS century,
   date_part( 'millennium', d1) AS millennium,
   round(date_part( 'julian', d1)) AS julian,
   date_part( 'epoch', d1) AS epoch
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT d1 as timestamptz,
   date_part( 'timezone', d1) AS timezone,
   date_part( 'timezone_hour', d1) AS timezone_hour,
   date_part( 'timezone_minute', d1) AS timezone_minute
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
-- extract implementation is mostly the same as date_part, so only
-- test a few cases for additional coverage.
SELECT d1 as "timestamp",
   extract(microseconds from d1) AS microseconds,
   extract(milliseconds from d1) AS milliseconds,
   extract(seconds from d1) AS seconds,
   round(extract(julian from d1)) AS julian,
   extract(epoch from d1) AS epoch
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
-- value near upper bound uses special case in code
SELECT date_part('epoch', '294270-01-01 00:00:00+00'::timestamptz);
---END---
---START---
SELECT extract(epoch from '294270-01-01 00:00:00+00'::timestamptz);
---END---
---START---
-- another internal overflow test case
SELECT extract(epoch from '5000-01-01 00:00:00+00'::timestamptz);
---END---
---START---
-- test edge-case overflow in timestamp subtraction
SELECT timestamptz '294276-12-31 23:59:59 UTC' - timestamptz '1999-12-23 19:59:04.224193 UTC' AS ok;
---END---
---START---
SELECT timestamptz '294276-12-31 23:59:59 UTC' - timestamptz '1999-12-23 19:59:04.224192 UTC' AS overflows;
---END---
---START---
-- TO_CHAR()
SELECT to_char(d1, 'DAY Day day DY Dy dy MONTH Month month RM MON Mon mon')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'FMDAY FMDay FMday FMMONTH FMMonth FMmonth FMRM')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'Y,YYY YYYY YYY YY Y CC Q MM WW DDD DD D J')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'FMY,YYY FMYYYY FMYYY FMYY FMY FMCC FMQ FMMM FMWW FMDDD FMDD FMD FMJ')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'HH HH12 HH24 MI SS SSSS')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, E'"HH:MI:SS is" HH:MI:SS "\\"text between quote marks\\""')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'HH24--text--MI--text--SS')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'YYYYTH YYYYth Jth')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'YYYY A.D. YYYY a.d. YYYY bc HH:MI:SS P.M. HH:MI:SS p.m. HH:MI:SS pm')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'IYYY IYY IY I IW IDDD ID')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d1, 'FMIYYY FMIYY FMIY FMI FMIW FMIDDD FMID')
   FROM TIMESTAMPTZ_TBL;
---END---
---START---
SELECT to_char(d, 'FF1 FF2 FF3 FF4 FF5 FF6  ff1 ff2 ff3 ff4 ff5 ff6  MS US')
   FROM (VALUES
       ('2018-11-02 12:34:56'::timestamptz),
       ('2018-11-02 12:34:56.78'),
       ('2018-11-02 12:34:56.78901'),
       ('2018-11-02 12:34:56.78901234')
   ) d(d);
---END---
---START---
-- Check OF, TZH, TZM with various zone offsets, particularly fractional hours
SET timezone = '00:00';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '+02:00';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '-13:00';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '-00:30';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '00:30';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '-04:30';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '04:30';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '-04:15';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
SET timezone = '04:15';
---END---
---START---
SELECT to_char(now(), 'OF') as "OF", to_char(now(), 'TZH:TZM') as "TZH:TZM";
---END---
---START---
RESET timezone;
---END---
---START---
-- Check of, tzh, tzm with various zone offsets.
SET timezone = '00:00';
---END---
---START---
SELECT to_char(now(), 'of') as "Of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '+02:00';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '-13:00';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '-00:30';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '00:30';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '-04:30';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '04:30';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '-04:15';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
SET timezone = '04:15';
---END---
---START---
SELECT to_char(now(), 'of') as "of", to_char(now(), 'tzh:tzm') as "tzh:tzm";
---END---
---START---
RESET timezone;
---END---
---START---
CREATE TABLE timestamptz_tst (_gemini_pk serial PRIMARY KEY, a integer, b timestamptz);
---END---
---START---
-- Test year field value with len > 4
INSERT INTO TIMESTAMPTZ_TST VALUES(1, 'Sat Mar 12 23:58:48 1000 IST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TST VALUES(2, 'Sat Mar 12 23:58:48 10000 IST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TST VALUES(3, 'Sat Mar 12 23:58:48 100000 IST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TST VALUES(3, '10000 Mar 12 23:58:48 IST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TST VALUES(4, '100000312 23:58:48 IST');
---END---
---START---
INSERT INTO TIMESTAMPTZ_TST VALUES(4, '1000000312 23:58:48 IST');
---END---
---START---
--Verify data
SELECT * FROM TIMESTAMPTZ_TST ORDER BY a;
---END---
---START---
--Cleanup
DROP TABLE TIMESTAMPTZ_TST;
---END---
---START---
-- test timestamptz constructors
set TimeZone to 'America/New_York';
---END---
---START---
-- numeric timezone
SELECT make_timestamptz(1973, 07, 15, 08, 15, 55.33);
---END---
---START---
SELECT make_timestamptz(1973, 07, 15, 08, 15, 55.33, '+2');
---END---
---START---
SELECT make_timestamptz(1973, 07, 15, 08, 15, 55.33, '-2');
---END---
---START---
WITH tzs (tz) AS (VALUES
    ('+1'), ('+1:'), ('+1:0'), ('+100'), ('+1:00'), ('+01:00'),
    ('+10'), ('+1000'), ('+10:'), ('+10:0'), ('+10:00'), ('+10:00:'),
    ('+10:00:1'), ('+10:00:01'),
    ('+10:00:10'))
     SELECT make_timestamptz(2010, 2, 27, 3, 45, 00, tz), tz FROM tzs;
---END---
---START---
-- these should fail
SELECT make_timestamptz(1973, 07, 15, 08, 15, 55.33, '2');
---END---
---START---
SELECT make_timestamptz(2014, 12, 10, 10, 10, 10, '+16');
---END---
---START---
SELECT make_timestamptz(2014, 12, 10, 10, 10, 10, '-16');
---END---
---START---
-- should be true
SELECT make_timestamptz(1973, 07, 15, 08, 15, 55.33, '+2') = '1973-07-15 08:15:55.33+02'::timestamptz;
---END---
---START---
-- full timezone names
SELECT make_timestamptz(2014, 12, 10, 0, 0, 0, 'Europe/Prague') = timestamptz '2014-12-10 00:00:00 Europe/Prague';
---END---
---START---
SELECT make_timestamptz(2014, 12, 10, 0, 0, 0, 'Europe/Prague') AT TIME ZONE 'UTC';
---END---
---START---
SELECT make_timestamptz(1846, 12, 10, 0, 0, 0, 'Asia/Manila') AT TIME ZONE 'UTC';
---END---
---START---
SELECT make_timestamptz(1881, 12, 10, 0, 0, 0, 'Europe/Paris') AT TIME ZONE 'UTC';
---END---
---START---
SELECT make_timestamptz(1910, 12, 24, 0, 0, 0, 'Nehwon/Lankhmar');
---END---
---START---
-- abbreviations
SELECT make_timestamptz(2008, 12, 10, 10, 10, 10, 'EST');
---END---
---START---
SELECT make_timestamptz(2008, 12, 10, 10, 10, 10, 'EDT');
---END---
---START---
SELECT make_timestamptz(2014, 12, 10, 10, 10, 10, 'PST8PDT');
---END---
---START---
RESET TimeZone;
---END---
---START---
-- generate_series for timestamptz
select * from generate_series('2020-01-01 00:00'::timestamptz,
                              '2020-01-02 03:00'::timestamptz,
                              '1 hour'::interval);
---END---
---START---
-- the LIMIT should allow this to terminate in a reasonable amount of time
-- (but that unfortunately doesn't work yet for SELECT * FROM ...)
select generate_series('2022-01-01 00:00'::timestamptz,
                       'infinity'::timestamptz,
                       '1 month'::interval) limit 10;
---END---
---START---
-- errors
select * from generate_series('2020-01-01 00:00'::timestamptz,
                              '2020-01-02 03:00'::timestamptz,
                              '0 hour'::interval);
---END---
---START---
-- Interval crossing time shift for Europe/Warsaw timezone (with DST)
SET TimeZone to 'UTC';
---END---
---START---
SELECT date_add('2022-10-30 00:00:00+01'::timestamptz,
                '1 day'::interval);
---END---
---START---
SELECT date_add('2021-10-31 00:00:00+02'::timestamptz,
                '1 day'::interval,
                'Europe/Warsaw');
---END---
---START---
SELECT date_subtract('2022-10-30 00:00:00+01'::timestamptz,
                     '1 day'::interval);
---END---
---START---
SELECT date_subtract('2021-10-31 00:00:00+02'::timestamptz,
                     '1 day'::interval,
                     'Europe/Warsaw');
---END---
---START---
SELECT * FROM generate_series('2021-12-31 23:00:00+00'::timestamptz,
                              '2020-12-31 23:00:00+00'::timestamptz,
                              '-1 month'::interval,
                              'Europe/Warsaw');
---END---
---START---
RESET TimeZone;
---END---
---START---
--
-- Test behavior with a dynamic (time-varying) timezone abbreviation.
-- These tests rely on the knowledge that MSK (Europe/Moscow standard time)
-- moved forwards in Mar 2011 and backwards again in Oct 2014.
--

SET TimeZone to 'UTC';
---END---
---START---
SELECT '2011-03-27 00:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 01:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 01:59:59 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 02:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 02:00:01 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 02:59:59 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 03:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 03:00:01 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 04:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2011-03-27 00:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 01:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 01:59:59 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 02:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 02:00:01 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 02:59:59 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 03:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 03:00:01 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 04:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2014-10-26 00:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2014-10-26 00:59:59 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2014-10-26 01:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2014-10-26 01:00:01 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2014-10-26 02:00:00 Europe/Moscow'::timestamptz;
---END---
---START---
SELECT '2014-10-26 00:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2014-10-26 00:59:59 MSK'::timestamptz;
---END---
---START---
SELECT '2014-10-26 01:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2014-10-26 01:00:01 MSK'::timestamptz;
---END---
---START---
SELECT '2014-10-26 02:00:00 MSK'::timestamptz;
---END---
---START---
SELECT '2011-03-27 00:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 01:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 01:59:59'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 02:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 02:00:01'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 02:59:59'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 03:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 03:00:01'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 04:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 00:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 01:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 01:59:59'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 02:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 02:00:01'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 02:59:59'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 03:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 03:00:01'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 04:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-26 00:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-26 00:59:59'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-26 01:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-26 01:00:01'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-26 02:00:00'::timestamp AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-26 00:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-26 00:59:59'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-26 01:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-26 01:00:01'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-26 02:00:00'::timestamp AT TIME ZONE 'MSK';
---END---
---START---
SELECT make_timestamptz(2014, 10, 26, 0, 0, 0, 'MSK');
---END---
---START---
SELECT make_timestamptz(2014, 10, 26, 1, 0, 0, 'MSK');
---END---
---START---
SELECT to_timestamp(         0);
---END---
---START---
-- 1970-01-01 00:00:00+00
SELECT to_timestamp( 946684800);
---END---
---START---
-- 2000-01-01 00:00:00+00
SELECT to_timestamp(1262349296.7890123);
---END---
---START---
-- 2010-01-01 12:34:56.789012+00
-- edge cases
SELECT to_timestamp(-210866803200);
---END---
---START---
--   4714-11-24 00:00:00+00 BC
-- upper limit varies between integer and float timestamps, so hard to test
-- nonfinite values
SELECT to_timestamp(' Infinity'::float);
---END---
---START---
SELECT to_timestamp('-Infinity'::float);
---END---
---START---
SELECT to_timestamp('NaN'::float);
---END---
---START---
SET TimeZone to 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 21:00:00 UTC'::timestamptz;
---END---
---START---
SELECT '2011-03-26 22:00:00 UTC'::timestamptz;
---END---
---START---
SELECT '2011-03-26 22:59:59 UTC'::timestamptz;
---END---
---START---
SELECT '2011-03-26 23:00:00 UTC'::timestamptz;
---END---
---START---
SELECT '2011-03-26 23:00:01 UTC'::timestamptz;
---END---
---START---
SELECT '2011-03-26 23:59:59 UTC'::timestamptz;
---END---
---START---
SELECT '2011-03-27 00:00:00 UTC'::timestamptz;
---END---
---START---
SELECT '2014-10-25 21:00:00 UTC'::timestamptz;
---END---
---START---
SELECT '2014-10-25 21:59:59 UTC'::timestamptz;
---END---
---START---
SELECT '2014-10-25 22:00:00 UTC'::timestamptz;
---END---
---START---
SELECT '2014-10-25 22:00:01 UTC'::timestamptz;
---END---
---START---
SELECT '2014-10-25 23:00:00 UTC'::timestamptz;
---END---
---START---
RESET TimeZone;
---END---
---START---
SELECT '2011-03-26 21:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 22:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 22:59:59 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 23:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 23:00:01 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 23:59:59 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-27 00:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-25 21:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-25 21:59:59 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-25 22:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-25 22:00:01 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2014-10-25 23:00:00 UTC'::timestamptz AT TIME ZONE 'Europe/Moscow';
---END---
---START---
SELECT '2011-03-26 21:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-26 22:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-26 22:59:59 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-26 23:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-26 23:00:01 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-26 23:59:59 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2011-03-27 00:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-25 21:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-25 21:59:59 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-25 22:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-25 22:00:01 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
SELECT '2014-10-25 23:00:00 UTC'::timestamptz AT TIME ZONE 'MSK';
---END---
---START---
--
-- Test that AT TIME ZONE isn't misoptimized when using an index (bug #14504)
--
DROP TABLE IF EXISTS tmptz;

create table tmptz (f1 timestamptz primary key);
---END---
---START---
insert into tmptz values ('2017-01-18 00:00+00');
---END---
---START---
explain (costs off)
select * from tmptz where f1 at time zone 'utc' = '2017-01-18 00:00';
---END---
---START---
select * from tmptz where f1 at time zone 'utc' = '2017-01-18 00:00';
---END---
