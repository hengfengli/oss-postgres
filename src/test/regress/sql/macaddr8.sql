---START---
--
-- macaddr8
--

-- test various cases of valid and invalid input
-- valid
SELECT '08:00:2b:01:02:03     '::macaddr8;
---END---
---START---
SELECT '    08:00:2b:01:02:03     '::macaddr8;
---END---
---START---
SELECT '    08:00:2b:01:02:03'::macaddr8;
---END---
---START---
SELECT '08:00:2b:01:02:03:04:05     '::macaddr8;
---END---
---START---
SELECT '    08:00:2b:01:02:03:04:05     '::macaddr8;
---END---
---START---
SELECT '    08:00:2b:01:02:03:04:05'::macaddr8;
---END---
---START---
SELECT '123    08:00:2b:01:02:03'::macaddr8;
---END---
---START---
-- invalid
SELECT '08:00:2b:01:02:03  123'::macaddr8;
---END---
---START---
-- invalid
SELECT '123    08:00:2b:01:02:03:04:05'::macaddr8;
---END---
---START---
-- invalid
SELECT '08:00:2b:01:02:03:04:05  123'::macaddr8;
---END---
---START---
-- invalid
SELECT '08:00:2b:01:02:03:04:05:06:07'::macaddr8;
---END---
---START---
-- invalid
SELECT '08-00-2b-01-02-03-04-05-06-07'::macaddr8;
---END---
---START---
-- invalid
SELECT '08002b:01020304050607'::macaddr8;
---END---
---START---
-- invalid
SELECT '08002b01020304050607'::macaddr8;
---END---
---START---
-- invalid
SELECT '0z002b0102030405'::macaddr8;
---END---
---START---
-- invalid
SELECT '08002b010203xyza'::macaddr8;
---END---
---START---
-- invalid

SELECT '08:00-2b:01:02:03:04:05'::macaddr8;
---END---
---START---
-- invalid
SELECT '08:00-2b:01:02:03:04:05'::macaddr8;
---END---
---START---
-- invalid
SELECT '08:00:2b:01.02:03:04:05'::macaddr8;
---END---
---START---
-- invalid
SELECT '08:00:2b:01.02:03:04:05'::macaddr8;
---END---
---START---
-- invalid

-- test converting a MAC address to modified EUI-64 for inclusion
-- in an ipv6 address
SELECT macaddr8_set7bit('00:08:2b:01:02:03'::macaddr8);
---END---
---START---
CREATE TABLE macaddr8_data (_gemini_pk serial PRIMARY KEY, a integer, b macaddr8);
---END---
---START---
INSERT INTO macaddr8_data VALUES (1, '08:00:2b:01:02:03');
---END---
---START---
INSERT INTO macaddr8_data VALUES (2, '08-00-2b-01-02-03');
---END---
---START---
INSERT INTO macaddr8_data VALUES (3, '08002b:010203');
---END---
---START---
INSERT INTO macaddr8_data VALUES (4, '08002b-010203');
---END---
---START---
INSERT INTO macaddr8_data VALUES (5, '0800.2b01.0203');
---END---
---START---
INSERT INTO macaddr8_data VALUES (6, '0800-2b01-0203');
---END---
---START---
INSERT INTO macaddr8_data VALUES (7, '08002b010203');
---END---
---START---
INSERT INTO macaddr8_data VALUES (8, '0800:2b01:0203');
---END---
---START---
INSERT INTO macaddr8_data VALUES (9, 'not even close');
---END---
---START---
-- invalid

INSERT INTO macaddr8_data VALUES (10, '08:00:2b:01:02:04');
---END---
---START---
INSERT INTO macaddr8_data VALUES (11, '08:00:2b:01:02:02');
---END---
---START---
INSERT INTO macaddr8_data VALUES (12, '08:00:2a:01:02:03');
---END---
---START---
INSERT INTO macaddr8_data VALUES (13, '08:00:2c:01:02:03');
---END---
---START---
INSERT INTO macaddr8_data VALUES (14, '08:00:2a:01:02:04');
---END---
---START---
INSERT INTO macaddr8_data VALUES (15, '08:00:2b:01:02:03:04:05');
---END---
---START---
INSERT INTO macaddr8_data VALUES (16, '08-00-2b-01-02-03-04-05');
---END---
---START---
INSERT INTO macaddr8_data VALUES (17, '08002b:0102030405');
---END---
---START---
INSERT INTO macaddr8_data VALUES (18, '08002b-0102030405');
---END---
---START---
INSERT INTO macaddr8_data VALUES (19, '0800.2b01.0203.0405');
---END---
---START---
INSERT INTO macaddr8_data VALUES (20, '08002b01:02030405');
---END---
---START---
INSERT INTO macaddr8_data VALUES (21, '08002b0102030405');
---END---
---START---
SELECT * FROM macaddr8_data ORDER BY 1;
---END---
---START---
CREATE INDEX macaddr8_data_btree ON macaddr8_data USING btree (b);
---END---
---START---
CREATE INDEX macaddr8_data_hash ON macaddr8_data USING hash (b);
---END---
---START---
SELECT a, b, trunc(b) FROM macaddr8_data ORDER BY 2, 1;
---END---
---START---
SELECT b <  '08:00:2b:01:02:04' FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- true
SELECT b >  '08:00:2b:ff:fe:01:02:04' FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- false
SELECT b >  '08:00:2b:ff:fe:01:02:03' FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- false
SELECT b::macaddr <= '08:00:2b:01:02:04' FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- true
SELECT b::macaddr >= '08:00:2b:01:02:04' FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- false
SELECT b =  '08:00:2b:ff:fe:01:02:03' FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- true
SELECT b::macaddr <> '08:00:2b:01:02:04'::macaddr FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- true
SELECT b::macaddr <> '08:00:2b:01:02:03'::macaddr FROM macaddr8_data WHERE a = 1;
---END---
---START---
-- false

SELECT b <  '08:00:2b:01:02:03:04:06' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- true
SELECT b >  '08:00:2b:01:02:03:04:06' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- false
SELECT b >  '08:00:2b:01:02:03:04:05' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- false
SELECT b <= '08:00:2b:01:02:03:04:06' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- true
SELECT b >= '08:00:2b:01:02:03:04:06' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- false
SELECT b =  '08:00:2b:01:02:03:04:05' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- true
SELECT b <> '08:00:2b:01:02:03:04:06' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- true
SELECT b <> '08:00:2b:01:02:03:04:05' FROM macaddr8_data WHERE a = 15;
---END---
---START---
-- false

SELECT ~b                       FROM macaddr8_data;
---END---
---START---
SELECT  b & '00:00:00:ff:ff:ff' FROM macaddr8_data;
---END---
---START---
SELECT  b | '01:02:03:04:05:06' FROM macaddr8_data;
---END---
---START---
DROP TABLE macaddr8_data;
---END---
---START---
-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('08:00:2b:01:02:03:04:ZZ', 'macaddr8');
---END---
---START---
SELECT * FROM pg_input_error_info('08:00:2b:01:02:03:04:ZZ', 'macaddr8');
---END---
---START---
SELECT pg_input_is_valid('08:00:2b:01:02:03:04:', 'macaddr8');
---END---
---START---
SELECT * FROM pg_input_error_info('08:00:2b:01:02:03:04:', 'macaddr8');
---END---
