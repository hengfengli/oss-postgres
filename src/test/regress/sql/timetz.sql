---START---
--
-- TIMETZ
--

CREATE TABLE TIMETZ_TBL (f1 time(2) with time zone);
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('00:01 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('01:00 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('02:03 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('07:07 PST');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('08:08 EDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('11:59 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('12:00 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('12:01 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('23:59 PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('11:59:59.99 PM PDT');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('2003-03-07 15:36:39 America/New_York');
---END---
---START---
INSERT INTO TIMETZ_TBL VALUES ('2003-07-07 15:36:39 America/New_York');
---END---
---START---
-- this should fail (the timezone offset is not known)
INSERT INTO TIMETZ_TBL VALUES ('15:36:39 America/New_York');
---END---
---START---
-- this should fail (timezone not specified without a date)
INSERT INTO TIMETZ_TBL VALUES ('15:36:39 m2');
---END---
---START---
-- this should fail (dynamic timezone abbreviation without a date)
INSERT INTO TIMETZ_TBL VALUES ('15:36:39 MSK m2');
---END---
---START---
SELECT f1 AS "Time TZ" FROM TIMETZ_TBL;
---END---
---START---
SELECT f1 AS "Three" FROM TIMETZ_TBL WHERE f1 < '05:06:07-07';
---END---
---START---
SELECT f1 AS "Seven" FROM TIMETZ_TBL WHERE f1 > '05:06:07-07';
---END---
---START---
SELECT f1 AS "None" FROM TIMETZ_TBL WHERE f1 < '00:00-07';
---END---
---START---
SELECT f1 AS "Ten" FROM TIMETZ_TBL WHERE f1 >= '00:00-07';
---END---
---START---
-- Check edge cases
SELECT '23:59:59.999999 PDT'::timetz;
---END---
---START---
SELECT '23:59:59.9999999 PDT'::timetz;
---END---
---START---
-- rounds up
SELECT '23:59:60 PDT'::timetz;
---END---
---START---
-- rounds up
SELECT '24:00:00 PDT'::timetz;
---END---
---START---
-- allowed
SELECT '24:00:00.01 PDT'::timetz;
---END---
---START---
-- not allowed
SELECT '23:59:60.01 PDT'::timetz;
---END---
---START---
-- not allowed
SELECT '24:01:00 PDT'::timetz;
---END---
---START---
-- not allowed
SELECT '25:00:00 PDT'::timetz;
---END---
---START---
-- not allowed

-- Test non-error-throwing API
SELECT pg_input_is_valid('12:00:00 PDT', 'timetz');
---END---
---START---
SELECT pg_input_is_valid('25:00:00 PDT', 'timetz');
---END---
---START---
SELECT pg_input_is_valid('15:36:39 America/New_York', 'timetz');
---END---
---START---
SELECT * FROM pg_input_error_info('25:00:00 PDT', 'timetz');
---END---
---START---
SELECT * FROM pg_input_error_info('15:36:39 America/New_York', 'timetz');
---END---
---START---
--
-- TIME simple math
--
-- We now make a distinction between time and intervals,
-- and adding two times together makes no sense at all.
-- Leave in one query to show that it is rejected,
-- and do the rest of the testing in horology.sql
-- where we do mixed-type arithmetic. - thomas 2000-12-02

SELECT f1 + time with time zone '00:01' AS "Illegal" FROM TIMETZ_TBL;
---END---
---START---
--
-- test EXTRACT
--
SELECT EXTRACT(MICROSECOND FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT EXTRACT(MILLISECOND FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT EXTRACT(SECOND      FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT EXTRACT(MINUTE      FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT EXTRACT(HOUR        FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT EXTRACT(DAY         FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
-- error
SELECT EXTRACT(FORTNIGHT   FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
-- error
SELECT EXTRACT(TIMEZONE    FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04:30');
---END---
---START---
SELECT EXTRACT(TIMEZONE_HOUR   FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04:30');
---END---
---START---
SELECT EXTRACT(TIMEZONE_MINUTE FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04:30');
---END---
---START---
SELECT EXTRACT(EPOCH       FROM TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
-- date_part implementation is mostly the same as extract, so only
-- test a few cases for additional coverage.
SELECT date_part('microsecond', TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT date_part('millisecond', TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT date_part('second',      TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
---START---
SELECT date_part('epoch',       TIME WITH TIME ZONE '2020-05-26 13:30:25.575401-04');
---END---
