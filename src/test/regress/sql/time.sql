---START---
--
-- TIME
--

CREATE TABLE TIME_TBL (f1 time(2));
---END---
---START---

INSERT INTO TIME_TBL VALUES ('00:00');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('01:00');
---END---
---START---
-- as of 7.4, timezone spec should be accepted and ignored
INSERT INTO TIME_TBL VALUES ('02:03 PST');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('11:59 EDT');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('12:00');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('12:01');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('23:59');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('11:59:59.99 PM');
---END---
---START---

INSERT INTO TIME_TBL VALUES ('2003-03-07 15:36:39 America/New_York');
---END---
---START---
INSERT INTO TIME_TBL VALUES ('2003-07-07 15:36:39 America/New_York');
---END---
---START---
-- this should fail (the timezone offset is not known)
INSERT INTO TIME_TBL VALUES ('15:36:39 America/New_York');
---END---
---START---


SELECT f1 AS "Time" FROM TIME_TBL;
---END---
---START---

SELECT f1 AS "Three" FROM TIME_TBL WHERE f1 < '05:06:07';
---END---
---START---

SELECT f1 AS "Five" FROM TIME_TBL WHERE f1 > '05:06:07';
---END---
---START---

SELECT f1 AS "None" FROM TIME_TBL WHERE f1 < '00:00';
---END---
---START---

SELECT f1 AS "Eight" FROM TIME_TBL WHERE f1 >= '00:00';
---END---
---START---

-- Check edge cases
SELECT '23:59:59.999999'::time;
---END---
---START---
SELECT '23:59:59.9999999'::time;  -- rounds up
SELECT '23:59:60'::time;  -- rounds up
SELECT '24:00:00'::time;  -- allowed
SELECT '24:00:00.01'::time;  -- not allowed
SELECT '23:59:60.01'::time;  -- not allowed
SELECT '24:01:00'::time;  -- not allowed
SELECT '25:00:00'::time;  -- not allowed

-- Test non-error-throwing API
SELECT pg_input_is_valid('12:00:00', 'time');
---END---
---START---
SELECT pg_input_is_valid('25:00:00', 'time');
---END---
---START---
SELECT pg_input_is_valid('15:36:39 America/New_York', 'time');
---END---
---START---
SELECT * FROM pg_input_error_info('25:00:00', 'time');
---END---
---START---
SELECT * FROM pg_input_error_info('15:36:39 America/New_York', 'time');
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

SELECT f1 + time '00:01' AS "Illegal" FROM TIME_TBL;
---END---
---START---

--
-- test EXTRACT
--
SELECT EXTRACT(MICROSECOND FROM TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT EXTRACT(MILLISECOND FROM TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT EXTRACT(SECOND      FROM TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT EXTRACT(MINUTE      FROM TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT EXTRACT(HOUR        FROM TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT EXTRACT(DAY         FROM TIME '2020-05-26 13:30:25.575401');  -- error
SELECT EXTRACT(FORTNIGHT   FROM TIME '2020-05-26 13:30:25.575401');  -- error
SELECT EXTRACT(TIMEZONE    FROM TIME '2020-05-26 13:30:25.575401');  -- error
SELECT EXTRACT(EPOCH       FROM TIME '2020-05-26 13:30:25.575401');
---END---
---START---

-- date_part implementation is mostly the same as extract, so only
-- test a few cases for additional coverage.
SELECT date_part('microsecond', TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT date_part('millisecond', TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT date_part('second',      TIME '2020-05-26 13:30:25.575401');
---END---
---START---
SELECT date_part('epoch',       TIME '2020-05-26 13:30:25.575401');
---END---
