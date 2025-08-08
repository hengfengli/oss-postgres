---START---
--
-- TIMESTAMP
--

CREATE TABLE TIMESTAMP_TBL (d1 timestamp(2) without time zone);
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
INSERT INTO TIMESTAMP_TBL VALUES ('today');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('yesterday');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('tomorrow');
---END---
---START---
-- time zone should be ignored by this data type
INSERT INTO TIMESTAMP_TBL VALUES ('tomorrow EST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('tomorrow zulu');
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMP_TBL WHERE d1 = timestamp without time zone 'today';
---END---
---START---
SELECT count(*) AS Three FROM TIMESTAMP_TBL WHERE d1 = timestamp without time zone 'tomorrow';
---END---
---START---
SELECT count(*) AS One FROM TIMESTAMP_TBL WHERE d1 = timestamp without time zone 'yesterday';
---END---
---START---
COMMIT;
---END---
---START---
DELETE FROM TIMESTAMP_TBL;
---END---
---START---
-- Verify that 'now' *does* change over a reasonable interval such as 100 msec,
-- and that it doesn't change over the same interval within a transaction block

INSERT INTO TIMESTAMP_TBL VALUES ('now');
---END---
---START---
SELECT pg_sleep(0.1);
---END---
---START---
BEGIN;
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('now');
---END---
---START---
SELECT pg_sleep(0.1);
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('now');
---END---
---START---
SELECT pg_sleep(0.1);
---END---
---START---
SELECT count(*) AS two FROM TIMESTAMP_TBL WHERE d1 = timestamp(2) without time zone 'now';
---END---
---START---
SELECT count(d1) AS three, count(DISTINCT d1) AS two FROM TIMESTAMP_TBL;
---END---
---START---
COMMIT;
---END---
---START---
TRUNCATE TIMESTAMP_TBL;
---END---
---START---
-- Special values
INSERT INTO TIMESTAMP_TBL VALUES ('-infinity');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('infinity');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('epoch');
---END---
---START---
SELECT timestamp 'infinity' = timestamp '+infinity' AS t;
---END---
---START---
-- Postgres v6.0 standard output format
INSERT INTO TIMESTAMP_TBL VALUES ('Mon Feb 10 17:32:01 1997 PST');
---END---
---START---
-- Variations on Postgres v6.1 standard output format
INSERT INTO TIMESTAMP_TBL VALUES ('Mon Feb 10 17:32:01.000001 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Mon Feb 10 17:32:01.999999 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Mon Feb 10 17:32:01.4 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Mon Feb 10 17:32:01.5 1997 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Mon Feb 10 17:32:01.6 1997 PST');
---END---
---START---
-- ISO 8601 format
INSERT INTO TIMESTAMP_TBL VALUES ('1997-01-02');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997-01-02 03:04:05');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997-02-10 17:32:01-08');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997-02-10 17:32:01-0800');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997-02-10 17:32:01 -08:00');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('19970210 173201 -0800');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997-06-10 17:32:01 -07:00');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('2001-09-22T18:19:20');
---END---
---START---
-- POSIX format (note that the timezone abbrev is just decoration here)
INSERT INTO TIMESTAMP_TBL VALUES ('2000-03-15 08:14:01 GMT+8');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('2000-03-15 13:14:02 GMT-1');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('2000-03-15 12:14:03 GMT-2');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('2000-03-15 03:14:04 PST+8');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('2000-03-15 02:14:05 MST+7:00');
---END---
---START---
-- Variations for acceptable input formats
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 10 17:32:01 1997 -0800');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 10 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 10 5:32PM 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997/02/10 17:32:01-0800');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997-02-10 17:32:01 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb-10-1997 17:32:01 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('02-10-1997 17:32:01 PST');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('19970210 173201 PST');
---END---
---START---
set datestyle to ymd;
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('97FEB10 5:32:01PM UTC');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('97/02/10 17:32:01 UTC');
---END---
---START---
reset datestyle;
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('1997.041 17:32:01 UTC');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('19970210 173201 America/New_York');
---END---
---START---
-- this fails (even though TZ is a no-op, we still look it up)
INSERT INTO TIMESTAMP_TBL VALUES ('19970710 173201 America/Does_not_exist');
---END---
---START---
-- Test non-error-throwing API
SELECT pg_input_is_valid('now', 'timestamp');
---END---
---START---
SELECT pg_input_is_valid('garbage', 'timestamp');
---END---
---START---
SELECT pg_input_is_valid('2001-01-01 00:00 Nehwon/Lankhmar', 'timestamp');
---END---
---START---
SELECT * FROM pg_input_error_info('garbage', 'timestamp');
---END---
---START---
SELECT * FROM pg_input_error_info('2001-01-01 00:00 Nehwon/Lankhmar', 'timestamp');
---END---
---START---
-- Check date conversion and date arithmetic
INSERT INTO TIMESTAMP_TBL VALUES ('1997-06-10 18:32:01 PDT');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 10 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 11 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 12 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 13 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 14 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 15 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 0097 BC');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 0097');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 0597');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 1097');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 1697');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 1797');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 1897');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 2097');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 28 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 29 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Mar 01 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Dec 30 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Dec 31 17:32:01 1996');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Jan 01 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 28 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 29 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Mar 01 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Dec 30 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Dec 31 17:32:01 1997');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Dec 31 17:32:01 1999');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Jan 01 17:32:01 2000');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Dec 31 17:32:01 2000');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Jan 01 17:32:01 2001');
---END---
---START---
-- Currently unsupported syntax and ranges
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 -0097');
---END---
---START---
INSERT INTO TIMESTAMP_TBL VALUES ('Feb 16 17:32:01 5097 BC');
---END---
---START---
SELECT d1 FROM TIMESTAMP_TBL;
---END---
---START---
-- Check behavior at the boundaries of the timestamp range
SELECT '4714-11-24 00:00:00 BC'::timestamp;
---END---
---START---
SELECT '4714-11-23 23:59:59 BC'::timestamp;
---END---
---START---
-- out of range
SELECT '294276-12-31 23:59:59'::timestamp;
---END---
---START---
SELECT '294277-01-01 00:00:00'::timestamp;
---END---
---START---
-- out of range

-- Demonstrate functions and operators
SELECT d1 FROM TIMESTAMP_TBL
   WHERE d1 > timestamp without time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMP_TBL
   WHERE d1 < timestamp without time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMP_TBL
   WHERE d1 = timestamp without time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMP_TBL
   WHERE d1 != timestamp without time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMP_TBL
   WHERE d1 <= timestamp without time zone '1997-01-02';
---END---
---START---
SELECT d1 FROM TIMESTAMP_TBL
   WHERE d1 >= timestamp without time zone '1997-01-02';
---END---
---START---
SELECT d1 - timestamp without time zone '1997-01-02' AS diff
   FROM TIMESTAMP_TBL WHERE d1 BETWEEN '1902-01-01' AND '2038-01-01';
---END---
---START---
SELECT date_trunc( 'week', timestamp '2004-02-29 15:44:17.71393' ) AS week_trunc;
---END---
---START---
-- verify date_bin behaves the same as date_trunc for relevant intervals

-- case 1: AD dates, origin < input
SELECT
  str,
  interval,
  date_trunc(str, ts) = date_bin(interval::interval, ts, timestamp '2001-01-01') AS equal
FROM (
  VALUES
  ('week', '7 d'),
  ('day', '1 d'),
  ('hour', '1 h'),
  ('minute', '1 m'),
  ('second', '1 s'),
  ('millisecond', '1 ms'),
  ('microsecond', '1 us')
) intervals (str, interval),
(VALUES (timestamp '2020-02-29 15:44:17.71393')) ts (ts);
---END---
---START---
-- case 2: BC dates, origin < input
SELECT
  str,
  interval,
  date_trunc(str, ts) = date_bin(interval::interval, ts, timestamp '2000-01-01 BC') AS equal
FROM (
  VALUES
  ('week', '7 d'),
  ('day', '1 d'),
  ('hour', '1 h'),
  ('minute', '1 m'),
  ('second', '1 s'),
  ('millisecond', '1 ms'),
  ('microsecond', '1 us')
) intervals (str, interval),
(VALUES (timestamp '0055-6-10 15:44:17.71393 BC')) ts (ts);
---END---
---START---
-- case 3: AD dates, origin > input
SELECT
  str,
  interval,
  date_trunc(str, ts) = date_bin(interval::interval, ts, timestamp '2020-03-02') AS equal
FROM (
  VALUES
  ('week', '7 d'),
  ('day', '1 d'),
  ('hour', '1 h'),
  ('minute', '1 m'),
  ('second', '1 s'),
  ('millisecond', '1 ms'),
  ('microsecond', '1 us')
) intervals (str, interval),
(VALUES (timestamp '2020-02-29 15:44:17.71393')) ts (ts);
---END---
---START---
-- case 4: BC dates, origin > input
SELECT
  str,
  interval,
  date_trunc(str, ts) = date_bin(interval::interval, ts, timestamp '0055-06-17 BC') AS equal
FROM (
  VALUES
  ('week', '7 d'),
  ('day', '1 d'),
  ('hour', '1 h'),
  ('minute', '1 m'),
  ('second', '1 s'),
  ('millisecond', '1 ms'),
  ('microsecond', '1 us')
) intervals (str, interval),
(VALUES (timestamp '0055-6-10 15:44:17.71393 BC')) ts (ts);
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
(VALUES (timestamp '2020-02-11 15:44:17.71393')) ts (ts),
(VALUES (timestamp '2001-01-01')) origin (origin);
---END---
---START---
-- shift bins using the origin parameter:
SELECT date_bin('5 min'::interval, timestamp '2020-02-01 01:01:01', timestamp '2020-02-01 00:02:30');
---END---
---START---
-- disallow intervals with months or years
SELECT date_bin('5 months'::interval, timestamp '2020-02-01 01:01:01', timestamp '2001-01-01');
---END---
---START---
SELECT date_bin('5 years'::interval,  timestamp '2020-02-01 01:01:01', timestamp '2001-01-01');
---END---
---START---
-- disallow zero intervals
SELECT date_bin('0 days'::interval, timestamp '1970-01-01 01:00:00' , timestamp '1970-01-01 00:00:00');
---END---
---START---
-- disallow negative intervals
SELECT date_bin('-2 days'::interval, timestamp '1970-01-01 01:00:00' , timestamp '1970-01-01 00:00:00');
---END---
---START---
-- Test casting within a BETWEEN qualifier
SELECT d1 - timestamp without time zone '1997-01-02' AS diff
  FROM TIMESTAMP_TBL
  WHERE d1 BETWEEN timestamp without time zone '1902-01-01'
   AND timestamp without time zone '2038-01-01';
---END---
---START---
-- DATE_PART (timestamp_part)
SELECT d1 as "timestamp",
   date_part( 'year', d1) AS year, date_part( 'month', d1) AS month,
   date_part( 'day', d1) AS day, date_part( 'hour', d1) AS hour,
   date_part( 'minute', d1) AS minute, date_part( 'second', d1) AS second
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT d1 as "timestamp",
   date_part( 'quarter', d1) AS quarter, date_part( 'msec', d1) AS msec,
   date_part( 'usec', d1) AS usec
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT d1 as "timestamp",
   date_part( 'isoyear', d1) AS isoyear, date_part( 'week', d1) AS week,
   date_part( 'isodow', d1) AS isodow, date_part( 'dow', d1) AS dow,
   date_part( 'doy', d1) AS doy
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT d1 as "timestamp",
   date_part( 'decade', d1) AS decade,
   date_part( 'century', d1) AS century,
   date_part( 'millennium', d1) AS millennium,
   round(date_part( 'julian', d1)) AS julian,
   date_part( 'epoch', d1) AS epoch
   FROM TIMESTAMP_TBL;
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
   FROM TIMESTAMP_TBL;
---END---
---START---
-- value near upper bound uses special case in code
SELECT date_part('epoch', '294270-01-01 00:00:00'::timestamp);
---END---
---START---
SELECT extract(epoch from '294270-01-01 00:00:00'::timestamp);
---END---
---START---
-- another internal overflow test case
SELECT extract(epoch from '5000-01-01 00:00:00'::timestamp);
---END---
---START---
-- test edge-case overflow in timestamp subtraction
SELECT timestamp '294276-12-31 23:59:59' - timestamp '1999-12-23 19:59:04.224193' AS ok;
---END---
---START---
SELECT timestamp '294276-12-31 23:59:59' - timestamp '1999-12-23 19:59:04.224192' AS overflows;
---END---
---START---
-- TO_CHAR()
SELECT to_char(d1, 'DAY Day day DY Dy dy MONTH Month month RM MON Mon mon')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'FMDAY FMDay FMday FMMONTH FMMonth FMmonth FMRM')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'Y,YYY YYYY YYY YY Y CC Q MM WW DDD DD D J')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'FMY,YYY FMYYYY FMYYY FMYY FMY FMCC FMQ FMMM FMWW FMDDD FMDD FMD FMJ')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'HH HH12 HH24 MI SS SSSS')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, E'"HH:MI:SS is" HH:MI:SS "\\"text between quote marks\\""')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'HH24--text--MI--text--SS')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'YYYYTH YYYYth Jth')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'YYYY A.D. YYYY a.d. YYYY bc HH:MI:SS P.M. HH:MI:SS p.m. HH:MI:SS pm')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'IYYY IYY IY I IW IDDD ID')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d1, 'FMIYYY FMIYY FMIY FMI FMIW FMIDDD FMID')
   FROM TIMESTAMP_TBL;
---END---
---START---
SELECT to_char(d, 'FF1 FF2 FF3 FF4 FF5 FF6  ff1 ff2 ff3 ff4 ff5 ff6  MS US')
   FROM (VALUES
       ('2018-11-02 12:34:56'::timestamp),
       ('2018-11-02 12:34:56.78'),
       ('2018-11-02 12:34:56.78901'),
       ('2018-11-02 12:34:56.78901234')
   ) d(d);
---END---
---START---
-- Roman months, with upper and lower case.
SELECT i,
       to_char(i * interval '1mon', 'rm'),
       to_char(i * interval '1mon', 'RM')
    FROM generate_series(-13, 13) i;
---END---
---START---
-- timestamp numeric fields constructor
SELECT make_timestamp(2014, 12, 28, 6, 30, 45.887);
---END---
---START---
SELECT make_timestamp(-44, 3, 15, 12, 30, 15);
---END---
---START---
-- should fail
select make_timestamp(0, 7, 15, 12, 30, 15);
---END---
---START---
-- generate_series for timestamp
select * from generate_series('2020-01-01 00:00'::timestamp,
                              '2020-01-02 03:00'::timestamp,
                              '1 hour'::interval);
---END---
---START---
-- the LIMIT should allow this to terminate in a reasonable amount of time
-- (but that unfortunately doesn't work yet for SELECT * FROM ...)
select generate_series('2022-01-01 00:00'::timestamp,
                       'infinity'::timestamp,
                       '1 month'::interval) limit 10;
---END---
---START---
-- errors
select * from generate_series('2020-01-01 00:00'::timestamp,
                              '2020-01-02 03:00'::timestamp,
                              '0 hour'::interval);
---END---
