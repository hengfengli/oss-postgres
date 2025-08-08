---START---
--
-- INTERVAL
--

SET DATESTYLE = 'ISO';
---END---
---START---
SET IntervalStyle to postgres;
---END---
---START---
-- check acceptance of "time zone style"
SELECT INTERVAL '01:00' AS "One hour";
---END---
---START---
SELECT INTERVAL '+02:00' AS "Two hours";
---END---
---START---
SELECT INTERVAL '-08:00' AS "Eight hours";
---END---
---START---
SELECT INTERVAL '-1 +02:03' AS "22 hours ago...";
---END---
---START---
SELECT INTERVAL '-1 days +02:03' AS "22 hours ago...";
---END---
---START---
SELECT INTERVAL '1.5 weeks' AS "Ten days twelve hours";
---END---
---START---
SELECT INTERVAL '1.5 months' AS "One month 15 days";
---END---
---START---
SELECT INTERVAL '10 years -11 month -12 days +13:14' AS "9 years...";
---END---
---START---
CREATE TABLE interval_tbl (gemini_pk serial PRIMARY KEY, f1 interval);
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 1 minute');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 5 hour');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 10 day');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 34 year');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 3 months');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 14 seconds ago');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('1 day 2 hours 3 minutes 4 seconds');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('6 years');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('5 months');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('5 months 12 hours');
---END---
---START---
-- badly formatted interval
INSERT INTO INTERVAL_TBL (f1) VALUES ('badly formatted interval');
---END---
---START---
INSERT INTO INTERVAL_TBL (f1) VALUES ('@ 30 eons ago');
---END---
---START---
-- Test non-error-throwing API
SELECT pg_input_is_valid('1.5 weeks', 'interval');
---END---
---START---
SELECT pg_input_is_valid('garbage', 'interval');
---END---
---START---
SELECT pg_input_is_valid('@ 30 eons ago', 'interval');
---END---
---START---
SELECT * FROM pg_input_error_info('garbage', 'interval');
---END---
---START---
SELECT * FROM pg_input_error_info('@ 30 eons ago', 'interval');
---END---
---START---
-- test interval operators

SELECT * FROM INTERVAL_TBL;
---END---
---START---
SELECT * FROM INTERVAL_TBL
   WHERE INTERVAL_TBL.f1 <> interval '@ 10 days';
---END---
---START---
SELECT * FROM INTERVAL_TBL
   WHERE INTERVAL_TBL.f1 <= interval '@ 5 hours';
---END---
---START---
SELECT * FROM INTERVAL_TBL
   WHERE INTERVAL_TBL.f1 < interval '@ 1 day';
---END---
---START---
SELECT * FROM INTERVAL_TBL
   WHERE INTERVAL_TBL.f1 = interval '@ 34 years';
---END---
---START---
SELECT * FROM INTERVAL_TBL
   WHERE INTERVAL_TBL.f1 >= interval '@ 1 month';
---END---
---START---
SELECT * FROM INTERVAL_TBL
   WHERE INTERVAL_TBL.f1 > interval '@ 3 seconds ago';
---END---
---START---
SELECT r1.*, r2.*
   FROM INTERVAL_TBL r1, INTERVAL_TBL r2
   WHERE r1.f1 > r2.f1
   ORDER BY r1.f1, r2.f1;
---END---
---START---
-- Test intervals that are large enough to overflow 64 bits in comparisons
DROP TABLE IF EXISTS INTERVAL_TBL_OF;

CREATE TABLE interval_tbl_of (gemini_pk serial PRIMARY KEY, f1 interval);
---END---
---START---
INSERT INTO INTERVAL_TBL_OF (f1) VALUES
  ('2147483647 days 2147483647 months'),
  ('2147483647 days -2147483648 months'),
  ('1 year'),
  ('-2147483648 days 2147483647 months'),
  ('-2147483648 days -2147483648 months');
---END---
---START---
-- these should fail as out-of-range
INSERT INTO INTERVAL_TBL_OF (f1) VALUES ('2147483648 days');
---END---
---START---
INSERT INTO INTERVAL_TBL_OF (f1) VALUES ('-2147483649 days');
---END---
---START---
INSERT INTO INTERVAL_TBL_OF (f1) VALUES ('2147483647 years');
---END---
---START---
INSERT INTO INTERVAL_TBL_OF (f1) VALUES ('-2147483648 years');
---END---
---START---
-- Test edge-case overflow detection in interval multiplication
select extract(epoch from '256 microseconds'::interval * (2^55)::float8);
---END---
---START---
SELECT r1.*, r2.*
   FROM INTERVAL_TBL_OF r1, INTERVAL_TBL_OF r2
   WHERE r1.f1 > r2.f1
   ORDER BY r1.f1, r2.f1;
---END---
---START---
CREATE INDEX ON INTERVAL_TBL_OF USING btree (f1);
---END---
---START---
SET enable_seqscan TO false;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT f1 FROM INTERVAL_TBL_OF r1 ORDER BY f1;
---END---
---START---
SELECT f1 FROM INTERVAL_TBL_OF r1 ORDER BY f1;
---END---
---START---
RESET enable_seqscan;
---END---
---START---
DROP TABLE INTERVAL_TBL_OF;
---END---
---START---
CREATE TABLE interval_muldiv_tbl (gemini_pk serial PRIMARY KEY, span interval);
---END---
---START---
COPY INTERVAL_MULDIV_TBL FROM STDIN;
41 mon 12 days 360:00
-41 mon -12 days +360:00
-12 days
9 mon -27 days 12:34:56
-3 years 482 days 76:54:32.189
4 mon
14 mon
999 mon 999 days
\.
---END---
---START---
SELECT span * 0.3 AS product
FROM INTERVAL_MULDIV_TBL;
---END---
---START---
SELECT span * 8.2 AS product
FROM INTERVAL_MULDIV_TBL;
---END---
---START---
SELECT span / 10 AS quotient
FROM INTERVAL_MULDIV_TBL;
---END---
---START---
SELECT span / 100 AS quotient
FROM INTERVAL_MULDIV_TBL;
---END---
---START---
DROP TABLE INTERVAL_MULDIV_TBL;
---END---
---START---
SET DATESTYLE = 'postgres';
---END---
---START---
SET IntervalStyle to postgres_verbose;
---END---
---START---
SELECT * FROM INTERVAL_TBL;
---END---
---START---
-- test avg(interval), which is somewhat fragile since people have been
-- known to change the allowed input syntax for type interval without
-- updating pg_aggregate.agginitval

select avg(f1) from interval_tbl;
---END---
---START---
-- test long interval input
select '4 millenniums 5 centuries 4 decades 1 year 4 months 4 days 17 minutes 31 seconds'::interval;
---END---
---START---
-- test long interval output
-- Note: the actual maximum length of the interval output is longer,
-- but we need the test to work for both integer and floating-point
-- timestamps.
select '100000000y 10mon -1000000000d -100000h -10min -10.000001s ago'::interval;
---END---
---START---
-- test justify_hours() and justify_days()

SELECT justify_hours(interval '6 months 3 days 52 hours 3 minutes 2 seconds') as "6 mons 5 days 4 hours 3 mins 2 seconds";
---END---
---START---
SELECT justify_days(interval '6 months 36 days 5 hours 4 minutes 3 seconds') as "7 mons 6 days 5 hours 4 mins 3 seconds";
---END---
---START---
SELECT justify_hours(interval '2147483647 days 24 hrs');
---END---
---START---
SELECT justify_days(interval '2147483647 months 30 days');
---END---
---START---
-- test justify_interval()

SELECT justify_interval(interval '1 month -1 hour') as "1 month -1 hour";
---END---
---START---
SELECT justify_interval(interval '2147483647 days 24 hrs');
---END---
---START---
SELECT justify_interval(interval '-2147483648 days -24 hrs');
---END---
---START---
SELECT justify_interval(interval '2147483647 months 30 days');
---END---
---START---
SELECT justify_interval(interval '-2147483648 months -30 days');
---END---
---START---
SELECT justify_interval(interval '2147483647 months 30 days -24 hrs');
---END---
---START---
SELECT justify_interval(interval '-2147483648 months -30 days 24 hrs');
---END---
---START---
SELECT justify_interval(interval '2147483647 months -30 days 1440 hrs');
---END---
---START---
SELECT justify_interval(interval '-2147483648 months 30 days -1440 hrs');
---END---
---START---
-- test fractional second input, and detection of duplicate units
SET DATESTYLE = 'ISO';
---END---
---START---
SET IntervalStyle TO postgres;
---END---
---START---
SELECT '1 millisecond'::interval, '1 microsecond'::interval,
       '500 seconds 99 milliseconds 51 microseconds'::interval;
---END---
---START---
SELECT '3 days 5 milliseconds'::interval;
---END---
---START---
SELECT '1 second 2 seconds'::interval;
---END---
---START---
-- error
SELECT '10 milliseconds 20 milliseconds'::interval;
---END---
---START---
-- error
SELECT '5.5 seconds 3 milliseconds'::interval;
---END---
---START---
-- error
SELECT '1:20:05 5 microseconds'::interval;
---END---
---START---
-- error
SELECT '1 day 1 day'::interval;
---END---
---START---
-- error
SELECT interval '1-2';
---END---
---START---
-- SQL year-month literal
SELECT interval '999' second;
---END---
---START---
-- oversize leading field is ok
SELECT interval '999' minute;
---END---
---START---
SELECT interval '999' hour;
---END---
---START---
SELECT interval '999' day;
---END---
---START---
SELECT interval '999' month;
---END---
---START---
-- test SQL-spec syntaxes for restricted field sets
SELECT interval '1' year;
---END---
---START---
SELECT interval '2' month;
---END---
---START---
SELECT interval '3' day;
---END---
---START---
SELECT interval '4' hour;
---END---
---START---
SELECT interval '5' minute;
---END---
---START---
SELECT interval '6' second;
---END---
---START---
SELECT interval '1' year to month;
---END---
---START---
SELECT interval '1-2' year to month;
---END---
---START---
SELECT interval '1 2' day to hour;
---END---
---START---
SELECT interval '1 2:03' day to hour;
---END---
---START---
SELECT interval '1 2:03:04' day to hour;
---END---
---START---
SELECT interval '1 2' day to minute;
---END---
---START---
SELECT interval '1 2:03' day to minute;
---END---
---START---
SELECT interval '1 2:03:04' day to minute;
---END---
---START---
SELECT interval '1 2' day to second;
---END---
---START---
SELECT interval '1 2:03' day to second;
---END---
---START---
SELECT interval '1 2:03:04' day to second;
---END---
---START---
SELECT interval '1 2' hour to minute;
---END---
---START---
SELECT interval '1 2:03' hour to minute;
---END---
---START---
SELECT interval '1 2:03:04' hour to minute;
---END---
---START---
SELECT interval '1 2' hour to second;
---END---
---START---
SELECT interval '1 2:03' hour to second;
---END---
---START---
SELECT interval '1 2:03:04' hour to second;
---END---
---START---
SELECT interval '1 2' minute to second;
---END---
---START---
SELECT interval '1 2:03' minute to second;
---END---
---START---
SELECT interval '1 2:03:04' minute to second;
---END---
---START---
SELECT interval '1 +2:03' minute to second;
---END---
---START---
SELECT interval '1 +2:03:04' minute to second;
---END---
---START---
SELECT interval '1 -2:03' minute to second;
---END---
---START---
SELECT interval '1 -2:03:04' minute to second;
---END---
---START---
SELECT interval '123 11' day to hour;
---END---
---START---
-- ok
SELECT interval '123 11' day;
---END---
---START---
-- not ok
SELECT interval '123 11';
---END---
---START---
-- not ok, too ambiguous
SELECT interval '123 2:03 -2:04';
---END---
---START---
-- not ok, redundant hh:mm fields

-- test syntaxes for restricted precision
SELECT interval(0) '1 day 01:23:45.6789';
---END---
---START---
SELECT interval(2) '1 day 01:23:45.6789';
---END---
---START---
SELECT interval '12:34.5678' minute to second(2);
---END---
---START---
-- per SQL spec
SELECT interval '1.234' second;
---END---
---START---
SELECT interval '1.234' second(2);
---END---
---START---
SELECT interval '1 2.345' day to second(2);
---END---
---START---
SELECT interval '1 2:03' day to second(2);
---END---
---START---
SELECT interval '1 2:03.4567' day to second(2);
---END---
---START---
SELECT interval '1 2:03:04.5678' day to second(2);
---END---
---START---
SELECT interval '1 2.345' hour to second(2);
---END---
---START---
SELECT interval '1 2:03.45678' hour to second(2);
---END---
---START---
SELECT interval '1 2:03:04.5678' hour to second(2);
---END---
---START---
SELECT interval '1 2.3456' minute to second(2);
---END---
---START---
SELECT interval '1 2:03.5678' minute to second(2);
---END---
---START---
SELECT interval '1 2:03:04.5678' minute to second(2);
---END---
---START---
-- test casting to restricted precision (bug #14479)
SELECT f1, f1::INTERVAL DAY TO MINUTE AS "minutes",
  (f1 + INTERVAL '1 month')::INTERVAL MONTH::INTERVAL YEAR AS "years"
  FROM interval_tbl;
---END---
---START---
-- test inputting and outputting SQL standard interval literals
SET IntervalStyle TO sql_standard;
---END---
---START---
SELECT  interval '0'                       AS "zero",
        interval '1-2' year to month       AS "year-month",
        interval '1 2:03:04' day to second AS "day-time",
        - interval '1-2'                   AS "negative year-month",
        - interval '1 2:03:04'             AS "negative day-time";
---END---
---START---
-- test input of some not-quite-standard interval values in the sql style
SET IntervalStyle TO postgres;
---END---
---START---
SELECT  interval '+1 -1:00:00',
        interval '-1 +1:00:00',
        interval '+1-2 -3 +4:05:06.789',
        interval '-1-2 +3 -4:05:06.789';
---END---
---START---
-- cases that trigger sign-matching rules in the sql style
SELECT  interval '-23 hours 45 min 12.34 sec',
        interval '-1 day 23 hours 45 min 12.34 sec',
        interval '-1 year 2 months 1 day 23 hours 45 min 12.34 sec',
        interval '-1 year 2 months 1 day 23 hours 45 min +12.34 sec';
---END---
---START---
-- test output of couple non-standard interval values in the sql style
SET IntervalStyle TO sql_standard;
---END---
---START---
SELECT  interval '1 day -1 hours',
        interval '-1 days +1 hours',
        interval '1 years 2 months -3 days 4 hours 5 minutes 6.789 seconds',
        - interval '1 years 2 months -3 days 4 hours 5 minutes 6.789 seconds';
---END---
---START---
-- cases that trigger sign-matching rules in the sql style
SELECT  interval '-23 hours 45 min 12.34 sec',
        interval '-1 day 23 hours 45 min 12.34 sec',
        interval '-1 year 2 months 1 day 23 hours 45 min 12.34 sec',
        interval '-1 year 2 months 1 day 23 hours 45 min +12.34 sec';
---END---
---START---
-- edge case for sign-matching rules
SELECT  interval '';
---END---
---START---
-- error

-- test outputting iso8601 intervals
SET IntervalStyle to iso_8601;
---END---
---START---
select  interval '0'                                AS "zero",
        interval '1-2'                              AS "a year 2 months",
        interval '1 2:03:04'                        AS "a bit over a day",
        interval '2:03:04.45679'                    AS "a bit over 2 hours",
        (interval '1-2' + interval '3 4:05:06.7')   AS "all fields",
        (interval '1-2' - interval '3 4:05:06.7')   AS "mixed sign",
        (- interval '1-2' + interval '3 4:05:06.7') AS "negative";
---END---
---START---
-- test inputting ISO 8601 4.4.2.1 "Format With Time Unit Designators"
SET IntervalStyle to sql_standard;
---END---
---START---
select  interval 'P0Y'                    AS "zero",
        interval 'P1Y2M'                  AS "a year 2 months",
        interval 'P1W'                    AS "a week",
        interval 'P1DT2H3M4S'             AS "a bit over a day",
        interval 'P1Y2M3DT4H5M6.7S'       AS "all fields",
        interval 'P-1Y-2M-3DT-4H-5M-6.7S' AS "negative",
        interval 'PT-0.1S'                AS "fractional second";
---END---
---START---
-- test inputting ISO 8601 4.4.2.2 "Alternative Format"
SET IntervalStyle to postgres;
---END---
---START---
select  interval 'P00021015T103020'       AS "ISO8601 Basic Format",
        interval 'P0002-10-15T10:30:20'   AS "ISO8601 Extended Format";
---END---
---START---
-- Make sure optional ISO8601 alternative format fields are optional.
select  interval 'P0002'                  AS "year only",
        interval 'P0002-10'               AS "year month",
        interval 'P0002-10-15'            AS "year month day",
        interval 'P0002T1S'               AS "year only plus time",
        interval 'P0002-10T1S'            AS "year month plus time",
        interval 'P0002-10-15T1S'         AS "year month day plus time",
        interval 'PT10'                   AS "hour only",
        interval 'PT10:30'                AS "hour minute";
---END---
---START---
-- Check handling of fractional fields in ISO8601 format.
select interval 'P1Y0M3DT4H5M6S';
---END---
---START---
select interval 'P1.0Y0M3DT4H5M6S';
---END---
---START---
select interval 'P1.1Y0M3DT4H5M6S';
---END---
---START---
select interval 'P1.Y0M3DT4H5M6S';
---END---
---START---
select interval 'P.1Y0M3DT4H5M6S';
---END---
---START---
select interval 'P10.5e4Y';
---END---
---START---
-- not per spec, but we've historically taken it
select interval 'P.Y0M3DT4H5M6S';
---END---
---START---
-- error

-- test a couple rounding cases that changed since 8.3 w/ HAVE_INT64_TIMESTAMP.
SET IntervalStyle to postgres_verbose;
---END---
---START---
select interval '-10 mons -3 days +03:55:06.70';
---END---
---START---
select interval '1 year 2 mons 3 days 04:05:06.699999';
---END---
---START---
select interval '0:0:0.7', interval '@ 0.70 secs', interval '0.7 seconds';
---END---
---START---
-- test time fields using entire 64 bit microseconds range
select interval '2562047788.01521550194 hours';
---END---
---START---
select interval '-2562047788.01521550222 hours';
---END---
---START---
select interval '153722867280.912930117 minutes';
---END---
---START---
select interval '-153722867280.912930133 minutes';
---END---
---START---
select interval '9223372036854.775807 seconds';
---END---
---START---
select interval '-9223372036854.775808 seconds';
---END---
---START---
select interval '9223372036854775.807 milliseconds';
---END---
---START---
select interval '-9223372036854775.808 milliseconds';
---END---
---START---
select interval '9223372036854775807 microseconds';
---END---
---START---
select interval '-9223372036854775808 microseconds';
---END---
---START---
select interval 'PT2562047788H54.775807S';
---END---
---START---
select interval 'PT-2562047788H-54.775808S';
---END---
---START---
select interval 'PT2562047788:00:54.775807';
---END---
---START---
select interval 'PT2562047788.0152155019444';
---END---
---START---
select interval 'PT-2562047788.0152155022222';
---END---
---START---
-- overflow each date/time field
select interval '2147483648 years';
---END---
---START---
select interval '-2147483649 years';
---END---
---START---
select interval '2147483648 months';
---END---
---START---
select interval '-2147483649 months';
---END---
---START---
select interval '2147483648 days';
---END---
---START---
select interval '-2147483649 days';
---END---
---START---
select interval '2562047789 hours';
---END---
---START---
select interval '-2562047789 hours';
---END---
---START---
select interval '153722867281 minutes';
---END---
---START---
select interval '-153722867281 minutes';
---END---
---START---
select interval '9223372036855 seconds';
---END---
---START---
select interval '-9223372036855 seconds';
---END---
---START---
select interval '9223372036854777 millisecond';
---END---
---START---
select interval '-9223372036854777 millisecond';
---END---
---START---
select interval '9223372036854775808 microsecond';
---END---
---START---
select interval '-9223372036854775809 microsecond';
---END---
---START---
select interval 'P2147483648';
---END---
---START---
select interval 'P-2147483649';
---END---
---START---
select interval 'P1-2147483647-2147483647';
---END---
---START---
select interval 'PT2562047789';
---END---
---START---
select interval 'PT-2562047789';
---END---
---START---
-- overflow with date/time unit aliases
select interval '2147483647 weeks';
---END---
---START---
select interval '-2147483648 weeks';
---END---
---START---
select interval '2147483647 decades';
---END---
---START---
select interval '-2147483648 decades';
---END---
---START---
select interval '2147483647 centuries';
---END---
---START---
select interval '-2147483648 centuries';
---END---
---START---
select interval '2147483647 millennium';
---END---
---START---
select interval '-2147483648 millennium';
---END---
---START---
select interval '1 week 2147483647 days';
---END---
---START---
select interval '-1 week -2147483648 days';
---END---
---START---
select interval '2147483647 days 1 week';
---END---
---START---
select interval '-2147483648 days -1 week';
---END---
---START---
select interval 'P1W2147483647D';
---END---
---START---
select interval 'P-1W-2147483648D';
---END---
---START---
select interval 'P2147483647D1W';
---END---
---START---
select interval 'P-2147483648D-1W';
---END---
---START---
select interval '1 decade 2147483647 years';
---END---
---START---
select interval '1 century 2147483647 years';
---END---
---START---
select interval '1 millennium 2147483647 years';
---END---
---START---
select interval '-1 decade -2147483648 years';
---END---
---START---
select interval '-1 century -2147483648 years';
---END---
---START---
select interval '-1 millennium -2147483648 years';
---END---
---START---
select interval '2147483647 years 1 decade';
---END---
---START---
select interval '2147483647 years 1 century';
---END---
---START---
select interval '2147483647 years 1 millennium';
---END---
---START---
select interval '-2147483648 years -1 decade';
---END---
---START---
select interval '-2147483648 years -1 century';
---END---
---START---
select interval '-2147483648 years -1 millennium';
---END---
---START---
-- overflowing with fractional fields - postgres format
select interval '0.1 millennium 2147483647 months';
---END---
---START---
select interval '0.1 centuries 2147483647 months';
---END---
---START---
select interval '0.1 decades 2147483647 months';
---END---
---START---
select interval '0.1 yrs 2147483647 months';
---END---
---START---
select interval '-0.1 millennium -2147483648 months';
---END---
---START---
select interval '-0.1 centuries -2147483648 months';
---END---
---START---
select interval '-0.1 decades -2147483648 months';
---END---
---START---
select interval '-0.1 yrs -2147483648 months';
---END---
---START---
select interval '2147483647 months 0.1 millennium';
---END---
---START---
select interval '2147483647 months 0.1 centuries';
---END---
---START---
select interval '2147483647 months 0.1 decades';
---END---
---START---
select interval '2147483647 months 0.1 yrs';
---END---
---START---
select interval '-2147483648 months -0.1 millennium';
---END---
---START---
select interval '-2147483648 months -0.1 centuries';
---END---
---START---
select interval '-2147483648 months -0.1 decades';
---END---
---START---
select interval '-2147483648 months -0.1 yrs';
---END---
---START---
select interval '0.1 months 2147483647 days';
---END---
---START---
select interval '-0.1 months -2147483648 days';
---END---
---START---
select interval '2147483647 days 0.1 months';
---END---
---START---
select interval '-2147483648 days -0.1 months';
---END---
---START---
select interval '0.5 weeks 2147483647 days';
---END---
---START---
select interval '-0.5 weeks -2147483648 days';
---END---
---START---
select interval '2147483647 days 0.5 weeks';
---END---
---START---
select interval '-2147483648 days -0.5 weeks';
---END---
---START---
select interval '0.01 months 9223372036854775807 microseconds';
---END---
---START---
select interval '-0.01 months -9223372036854775808 microseconds';
---END---
---START---
select interval '9223372036854775807 microseconds 0.01 months';
---END---
---START---
select interval '-9223372036854775808 microseconds -0.01 months';
---END---
---START---
select interval '0.1 weeks 9223372036854775807 microseconds';
---END---
---START---
select interval '-0.1 weeks -9223372036854775808 microseconds';
---END---
---START---
select interval '9223372036854775807 microseconds 0.1 weeks';
---END---
---START---
select interval '-9223372036854775808 microseconds -0.1 weeks';
---END---
---START---
select interval '0.1 days 9223372036854775807 microseconds';
---END---
---START---
select interval '-0.1 days -9223372036854775808 microseconds';
---END---
---START---
select interval '9223372036854775807 microseconds 0.1 days';
---END---
---START---
select interval '-9223372036854775808 microseconds -0.1 days';
---END---
---START---
-- overflowing with fractional fields - ISO8601 format
select interval 'P0.1Y2147483647M';
---END---
---START---
select interval 'P-0.1Y-2147483648M';
---END---
---START---
select interval 'P2147483647M0.1Y';
---END---
---START---
select interval 'P-2147483648M-0.1Y';
---END---
---START---
select interval 'P0.1M2147483647D';
---END---
---START---
select interval 'P-0.1M-2147483648D';
---END---
---START---
select interval 'P2147483647D0.1M';
---END---
---START---
select interval 'P-2147483648D-0.1M';
---END---
---START---
select interval 'P0.5W2147483647D';
---END---
---START---
select interval 'P-0.5W-2147483648D';
---END---
---START---
select interval 'P2147483647D0.5W';
---END---
---START---
select interval 'P-2147483648D-0.5W';
---END---
---START---
select interval 'P0.01MT2562047788H54.775807S';
---END---
---START---
select interval 'P-0.01MT-2562047788H-54.775808S';
---END---
---START---
select interval 'P0.1DT2562047788H54.775807S';
---END---
---START---
select interval 'P-0.1DT-2562047788H-54.775808S';
---END---
---START---
select interval 'PT2562047788.1H54.775807S';
---END---
---START---
select interval 'PT-2562047788.1H-54.775808S';
---END---
---START---
select interval 'PT2562047788H0.1M54.775807S';
---END---
---START---
select interval 'PT-2562047788H-0.1M-54.775808S';
---END---
---START---
-- overflowing with fractional fields - ISO8601 alternative format
select interval 'P0.1-2147483647-00';
---END---
---START---
select interval 'P00-0.1-2147483647';
---END---
---START---
select interval 'P00-0.01-00T2562047788:00:54.775807';
---END---
---START---
select interval 'P00-00-0.1T2562047788:00:54.775807';
---END---
---START---
select interval 'PT2562047788.1:00:54.775807';
---END---
---START---
select interval 'PT2562047788:01.:54.775807';
---END---
---START---
-- overflowing with fractional fields - SQL standard format
select interval '0.1 2562047788:0:54.775807';
---END---
---START---
select interval '0.1 2562047788:0:54.775808 ago';
---END---
---START---
select interval '2562047788.1:0:54.775807';
---END---
---START---
select interval '2562047788.1:0:54.775808 ago';
---END---
---START---
select interval '2562047788:0.1:54.775807';
---END---
---START---
select interval '2562047788:0.1:54.775808 ago';
---END---
---START---
-- overflowing using AGO with INT_MIN
select interval '-2147483648 months ago';
---END---
---START---
select interval '-2147483648 days ago';
---END---
---START---
select interval '-9223372036854775808 microseconds ago';
---END---
---START---
select interval '-2147483648 months -2147483648 days -9223372036854775808 microseconds ago';
---END---
---START---
-- test that INT_MIN number is formatted properly
SET IntervalStyle to postgres;
---END---
---START---
select interval '-2147483648 months -2147483648 days -9223372036854775808 us';
---END---
---START---
SET IntervalStyle to sql_standard;
---END---
---START---
select interval '-2147483648 months -2147483648 days -9223372036854775808 us';
---END---
---START---
SET IntervalStyle to iso_8601;
---END---
---START---
select interval '-2147483648 months -2147483648 days -9223372036854775808 us';
---END---
---START---
SET IntervalStyle to postgres_verbose;
---END---
---START---
select interval '-2147483648 months -2147483648 days -9223372036854775808 us';
---END---
---START---
-- check that '30 days' equals '1 month' according to the hash function
select '30 days'::interval = '1 month'::interval as t;
---END---
---START---
select interval_hash('30 days'::interval) = interval_hash('1 month'::interval) as t;
---END---
---START---
-- numeric constructor
select make_interval(years := 2);
---END---
---START---
select make_interval(years := 1, months := 6);
---END---
---START---
select make_interval(years := 1, months := -1, weeks := 5, days := -7, hours := 25, mins := -180);
---END---
---START---
select make_interval() = make_interval(years := 0, months := 0, weeks := 0, days := 0, mins := 0, secs := 0.0);
---END---
---START---
select make_interval(hours := -2, mins := -10, secs := -25.3);
---END---
---START---
select make_interval(years := 'inf'::float::int);
---END---
---START---
select make_interval(months := 'NaN'::float::int);
---END---
---START---
select make_interval(secs := 'inf');
---END---
---START---
select make_interval(secs := 'NaN');
---END---
---START---
select make_interval(secs := 7e12);
---END---
---START---
--
-- test EXTRACT
--
SELECT f1,
    EXTRACT(MICROSECOND FROM f1) AS MICROSECOND,
    EXTRACT(MILLISECOND FROM f1) AS MILLISECOND,
    EXTRACT(SECOND FROM f1) AS SECOND,
    EXTRACT(MINUTE FROM f1) AS MINUTE,
    EXTRACT(HOUR FROM f1) AS HOUR,
    EXTRACT(DAY FROM f1) AS DAY,
    EXTRACT(MONTH FROM f1) AS MONTH,
    EXTRACT(QUARTER FROM f1) AS QUARTER,
    EXTRACT(YEAR FROM f1) AS YEAR,
    EXTRACT(DECADE FROM f1) AS DECADE,
    EXTRACT(CENTURY FROM f1) AS CENTURY,
    EXTRACT(MILLENNIUM FROM f1) AS MILLENNIUM,
    EXTRACT(EPOCH FROM f1) AS EPOCH
    FROM INTERVAL_TBL;
---END---
---START---
SELECT EXTRACT(FORTNIGHT FROM INTERVAL '2 days');
---END---
---START---
-- error
SELECT EXTRACT(TIMEZONE FROM INTERVAL '2 days');
---END---
---START---
-- error

SELECT EXTRACT(DECADE FROM INTERVAL '100 y');
---END---
---START---
SELECT EXTRACT(DECADE FROM INTERVAL '99 y');
---END---
---START---
SELECT EXTRACT(DECADE FROM INTERVAL '-99 y');
---END---
---START---
SELECT EXTRACT(DECADE FROM INTERVAL '-100 y');
---END---
---START---
SELECT EXTRACT(CENTURY FROM INTERVAL '100 y');
---END---
---START---
SELECT EXTRACT(CENTURY FROM INTERVAL '99 y');
---END---
---START---
SELECT EXTRACT(CENTURY FROM INTERVAL '-99 y');
---END---
---START---
SELECT EXTRACT(CENTURY FROM INTERVAL '-100 y');
---END---
---START---
-- date_part implementation is mostly the same as extract, so only
-- test a few cases for additional coverage.
SELECT f1,
    date_part('microsecond', f1) AS microsecond,
    date_part('millisecond', f1) AS millisecond,
    date_part('second', f1) AS second,
    date_part('epoch', f1) AS epoch
    FROM INTERVAL_TBL;
---END---
---START---
-- internal overflow test case
SELECT extract(epoch from interval '1000000000 days');
---END---
