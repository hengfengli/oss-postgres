---START---
CREATE TABLE guid1 (gemini_pk serial PRIMARY KEY, guid_field uuid, text_field text DEFAULT now());
---END---
---START---
CREATE TABLE guid2 (gemini_pk serial PRIMARY KEY, guid_field uuid, text_field text DEFAULT now());
---END---
---START---
-- inserting invalid data tests
-- too long
INSERT INTO guid1(guid_field) VALUES('11111111-1111-1111-1111-111111111111F');
---END---
---START---
-- too short
INSERT INTO guid1(guid_field) VALUES('{11111111-1111-1111-1111-11111111111}');
---END---
---START---
-- valid data but invalid format
INSERT INTO guid1(guid_field) VALUES('111-11111-1111-1111-1111-111111111111');
---END---
---START---
INSERT INTO guid1(guid_field) VALUES('{22222222-2222-2222-2222-222222222222 ');
---END---
---START---
-- invalid data
INSERT INTO guid1(guid_field) VALUES('11111111-1111-1111-G111-111111111111');
---END---
---START---
INSERT INTO guid1(guid_field) VALUES('11+11111-1111-1111-1111-111111111111');
---END---
---START---
-- test non-error-throwing API
SELECT pg_input_is_valid('11', 'uuid');
---END---
---START---
SELECT * FROM pg_input_error_info('11', 'uuid');
---END---
---START---
--inserting three input formats
INSERT INTO guid1(guid_field) VALUES('11111111-1111-1111-1111-111111111111');
---END---
---START---
INSERT INTO guid1(guid_field) VALUES('{22222222-2222-2222-2222-222222222222}');
---END---
---START---
INSERT INTO guid1(guid_field) VALUES('3f3e3c3b3a3039383736353433a2313e');
---END---
---START---
-- retrieving the inserted data
SELECT guid_field FROM guid1;
---END---
---START---
-- ordering test
SELECT guid_field FROM guid1 ORDER BY guid_field ASC;
---END---
---START---
SELECT guid_field FROM guid1 ORDER BY guid_field DESC;
---END---
---START---
-- = operator test
SELECT COUNT(*) FROM guid1 WHERE guid_field = '3f3e3c3b-3a30-3938-3736-353433a2313e';
---END---
---START---
-- <> operator test
SELECT COUNT(*) FROM guid1 WHERE guid_field <> '11111111111111111111111111111111';
---END---
---START---
-- < operator test
SELECT COUNT(*) FROM guid1 WHERE guid_field < '22222222-2222-2222-2222-222222222222';
---END---
---START---
-- <= operator test
SELECT COUNT(*) FROM guid1 WHERE guid_field <= '22222222-2222-2222-2222-222222222222';
---END---
---START---
-- > operator test
SELECT COUNT(*) FROM guid1 WHERE guid_field > '22222222-2222-2222-2222-222222222222';
---END---
---START---
-- >= operator test
SELECT COUNT(*) FROM guid1 WHERE guid_field >= '22222222-2222-2222-2222-222222222222';
---END---
---START---
-- btree and hash index creation test
CREATE INDEX guid1_btree ON guid1 USING BTREE (guid_field);
---END---
---START---
CREATE INDEX guid1_hash  ON guid1 USING HASH  (guid_field);
---END---
---START---
-- unique index test
CREATE UNIQUE INDEX guid1_unique_BTREE ON guid1 USING BTREE (guid_field);
---END---
---START---
-- should fail
INSERT INTO guid1(guid_field) VALUES('11111111-1111-1111-1111-111111111111');
---END---
---START---
-- check to see whether the new indexes are actually there
SELECT count(*) FROM pg_class WHERE relkind='i' AND relname LIKE 'guid%';
---END---
---START---
-- populating the test tables with additional records
INSERT INTO guid1(guid_field) VALUES('44444444-4444-4444-4444-444444444444');
---END---
---START---
INSERT INTO guid2(guid_field) VALUES('11111111-1111-1111-1111-111111111111');
---END---
---START---
INSERT INTO guid2(guid_field) VALUES('{22222222-2222-2222-2222-222222222222}');
---END---
---START---
INSERT INTO guid2(guid_field) VALUES('3f3e3c3b3a3039383736353433a2313e');
---END---
---START---
-- join test
SELECT COUNT(*) FROM guid1 g1 INNER JOIN guid2 g2 ON g1.guid_field = g2.guid_field;
---END---
---START---
SELECT COUNT(*) FROM guid1 g1 LEFT JOIN guid2 g2 ON g1.guid_field = g2.guid_field WHERE g2.guid_field IS NULL;
---END---
---START---
-- generation test
TRUNCATE guid1;
---END---
---START---
INSERT INTO guid1 (guid_field) VALUES (gen_random_uuid());
---END---
---START---
INSERT INTO guid1 (guid_field) VALUES (gen_random_uuid());
---END---
---START---
SELECT count(DISTINCT guid_field) FROM guid1;
---END---
---START---
-- clean up
DROP TABLE guid1, guid2 CASCADE;
---END---
