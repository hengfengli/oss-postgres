---START---
CREATE TABLE oid_tbl (gemini_pk serial PRIMARY KEY, f1 oid);
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('1234');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('1235');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('987');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('-1040');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('99999999');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('5     ');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('   10  ');
---END---
---START---
-- leading/trailing hard tab is also allowed
INSERT INTO OID_TBL(f1) VALUES ('	  15 	  ');
---END---
---START---
-- bad inputs
INSERT INTO OID_TBL(f1) VALUES ('');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('    ');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('asdfasd');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('99asdfasd');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('5    d');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('    5d');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('5    5');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES (' - 500');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('32958209582039852935');
---END---
---START---
INSERT INTO OID_TBL(f1) VALUES ('-23582358720398502385');
---END---
---START---
SELECT * FROM OID_TBL;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('1234', 'oid');
---END---
---START---
SELECT pg_input_is_valid('01XYZ', 'oid');
---END---
---START---
SELECT * FROM pg_input_error_info('01XYZ', 'oid');
---END---
---START---
SELECT pg_input_is_valid('9999999999', 'oid');
---END---
---START---
SELECT * FROM pg_input_error_info('9999999999', 'oid');
---END---
---START---
-- While we're here, check oidvector as well
SELECT pg_input_is_valid(' 1 2  4 ', 'oidvector');
---END---
---START---
SELECT pg_input_is_valid('01 01XYZ', 'oidvector');
---END---
---START---
SELECT * FROM pg_input_error_info('01 01XYZ', 'oidvector');
---END---
---START---
SELECT pg_input_is_valid('01 9999999999', 'oidvector');
---END---
---START---
SELECT * FROM pg_input_error_info('01 9999999999', 'oidvector');
---END---
---START---
SELECT o.* FROM OID_TBL o WHERE o.f1 = 1234;
---END---
---START---
SELECT o.* FROM OID_TBL o WHERE o.f1 <> '1234';
---END---
---START---
SELECT o.* FROM OID_TBL o WHERE o.f1 <= '1234';
---END---
---START---
SELECT o.* FROM OID_TBL o WHERE o.f1 < '1234';
---END---
---START---
SELECT o.* FROM OID_TBL o WHERE o.f1 >= '1234';
---END---
---START---
SELECT o.* FROM OID_TBL o WHERE o.f1 > '1234';
---END---
---START---
DROP TABLE OID_TBL;
---END---
