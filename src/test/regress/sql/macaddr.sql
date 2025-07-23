---START---
--
-- macaddr
--

CREATE TABLE macaddr_data (a int, b macaddr);
---END---
---START---

INSERT INTO macaddr_data VALUES (1, '08:00:2b:01:02:03');
---END---
---START---
INSERT INTO macaddr_data VALUES (2, '08-00-2b-01-02-03');
---END---
---START---
INSERT INTO macaddr_data VALUES (3, '08002b:010203');
---END---
---START---
INSERT INTO macaddr_data VALUES (4, '08002b-010203');
---END---
---START---
INSERT INTO macaddr_data VALUES (5, '0800.2b01.0203');
---END---
---START---
INSERT INTO macaddr_data VALUES (6, '0800-2b01-0203');
---END---
---START---
INSERT INTO macaddr_data VALUES (7, '08002b010203');
---END---
---START---
INSERT INTO macaddr_data VALUES (8, '0800:2b01:0203'); -- invalid
INSERT INTO macaddr_data VALUES (9, 'not even close'); -- invalid

INSERT INTO macaddr_data VALUES (10, '08:00:2b:01:02:04');
---END---
---START---
INSERT INTO macaddr_data VALUES (11, '08:00:2b:01:02:02');
---END---
---START---
INSERT INTO macaddr_data VALUES (12, '08:00:2a:01:02:03');
---END---
---START---
INSERT INTO macaddr_data VALUES (13, '08:00:2c:01:02:03');
---END---
---START---
INSERT INTO macaddr_data VALUES (14, '08:00:2a:01:02:04');
---END---
---START---

SELECT * FROM macaddr_data;
---END---
---START---

CREATE INDEX macaddr_data_btree ON macaddr_data USING btree (b);
---END---
---START---
CREATE INDEX macaddr_data_hash ON macaddr_data USING hash (b);
---END---
---START---

SELECT a, b, trunc(b) FROM macaddr_data ORDER BY 2, 1;
---END---
---START---

SELECT b <  '08:00:2b:01:02:04' FROM macaddr_data WHERE a = 1; -- true
SELECT b >  '08:00:2b:01:02:04' FROM macaddr_data WHERE a = 1; -- false
SELECT b >  '08:00:2b:01:02:03' FROM macaddr_data WHERE a = 1; -- false
SELECT b <= '08:00:2b:01:02:04' FROM macaddr_data WHERE a = 1; -- true
SELECT b >= '08:00:2b:01:02:04' FROM macaddr_data WHERE a = 1; -- false
SELECT b =  '08:00:2b:01:02:03' FROM macaddr_data WHERE a = 1; -- true
SELECT b <> '08:00:2b:01:02:04' FROM macaddr_data WHERE a = 1; -- true
SELECT b <> '08:00:2b:01:02:03' FROM macaddr_data WHERE a = 1; -- false

SELECT ~b                       FROM macaddr_data;
---END---
---START---
SELECT  b & '00:00:00:ff:ff:ff' FROM macaddr_data;
---END---
---START---
SELECT  b | '01:02:03:04:05:06' FROM macaddr_data;
---END---
---START---

DROP TABLE macaddr_data;
---END---
---START---

-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('08:00:2b:01:02:ZZ', 'macaddr');
---END---
---START---
SELECT * FROM pg_input_error_info('08:00:2b:01:02:ZZ', 'macaddr');
---END---
---START---
SELECT pg_input_is_valid('08:00:2b:01:02:', 'macaddr');
---END---
---START---
SELECT * FROM pg_input_error_info('08:00:2b:01:02:', 'macaddr');
---END---
