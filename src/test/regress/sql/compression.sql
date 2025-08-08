---START---
\set HIDE_TOAST_COMPRESSION false

-- ensure we get stable results regardless of installation's default
SET default_toast_compression = 'pglz';
---END---
---START---
-- test creating table with compression method
CREATE TABLE cmdata(f1 text COMPRESSION pglz);
---END---
---START---
CREATE INDEX idx ON cmdata(f1);
---END---
---START---
INSERT INTO cmdata VALUES(repeat('1234567890', 1000));
---END---
---START---
\d+ cmdata
CREATE TABLE cmdata1(f1 TEXT COMPRESSION lz4);
---END---
---START---
INSERT INTO cmdata1 VALUES(repeat('1234567890', 1004));
---END---
---START---
\d+ cmdata1

-- verify stored compression method in the data
SELECT pg_column_compression(f1) FROM cmdata;
---END---
---START---
SELECT pg_column_compression(f1) FROM cmdata1;
---END---
---START---
-- decompress data slice
SELECT SUBSTR(f1, 200, 5) FROM cmdata;
---END---
---START---
SELECT SUBSTR(f1, 2000, 50) FROM cmdata1;
---END---
---START---
-- copy with table creation
SELECT * INTO cmmove1 FROM cmdata;
---END---
---START---
\d+ cmmove1
SELECT pg_column_compression(f1) FROM cmmove1;
---END---
---START---
-- copy to existing table
CREATE TABLE cmmove3(f1 text COMPRESSION pglz);
---END---
---START---
INSERT INTO cmmove3 SELECT * FROM cmdata;
---END---
---START---
INSERT INTO cmmove3 SELECT * FROM cmdata1;
---END---
---START---
SELECT pg_column_compression(f1) FROM cmmove3;
---END---
---START---
-- test LIKE INCLUDING COMPRESSION
CREATE TABLE cmdata2 (LIKE cmdata1 INCLUDING COMPRESSION);
---END---
---START---
\d+ cmdata2
DROP TABLE cmdata2;
---END---
---START---
-- try setting compression for incompressible data type
CREATE TABLE cmdata2 (f1 int COMPRESSION pglz);
---END---
---START---
-- update using datum from different table
CREATE TABLE cmmove2(f1 text COMPRESSION pglz);
---END---
---START---
INSERT INTO cmmove2 VALUES (repeat('1234567890', 1004));
---END---
---START---
SELECT pg_column_compression(f1) FROM cmmove2;
---END---
---START---
UPDATE cmmove2 SET f1 = cmdata1.f1 FROM cmdata1;
---END---
---START---
SELECT pg_column_compression(f1) FROM cmmove2;
---END---
---START---
-- test externally stored compressed data
CREATE OR REPLACE FUNCTION large_val() RETURNS TEXT LANGUAGE SQL AS
'select array_agg(fipshash(g::text))::text from generate_series(1, 256) g';
---END---
---START---
CREATE TABLE cmdata2 (f1 text COMPRESSION pglz);
---END---
---START---
INSERT INTO cmdata2 SELECT large_val() || repeat('a', 4000);
---END---
---START---
SELECT pg_column_compression(f1) FROM cmdata2;
---END---
---START---
INSERT INTO cmdata1 SELECT large_val() || repeat('a', 4000);
---END---
---START---
SELECT pg_column_compression(f1) FROM cmdata1;
---END---
---START---
SELECT SUBSTR(f1, 200, 5) FROM cmdata1;
---END---
---START---
SELECT SUBSTR(f1, 200, 5) FROM cmdata2;
---END---
---START---
DROP TABLE cmdata2;
---END---
---START---
--test column type update varlena/non-varlena
CREATE TABLE cmdata2 (f1 int);
---END---
---START---
\d+ cmdata2
ALTER TABLE cmdata2 ALTER COLUMN f1 TYPE varchar;
---END---
---START---
\d+ cmdata2
ALTER TABLE cmdata2 ALTER COLUMN f1 TYPE int USING f1::integer;
---END---
---START---
\d+ cmdata2

--changing column storage should not impact the compression method
--but the data should not be compressed
ALTER TABLE cmdata2 ALTER COLUMN f1 TYPE varchar;
---END---
---START---
ALTER TABLE cmdata2 ALTER COLUMN f1 SET COMPRESSION pglz;
---END---
---START---
\d+ cmdata2
ALTER TABLE cmdata2 ALTER COLUMN f1 SET STORAGE plain;
---END---
---START---
\d+ cmdata2
INSERT INTO cmdata2 VALUES (repeat('123456789', 800));
---END---
---START---
SELECT pg_column_compression(f1) FROM cmdata2;
---END---
---START---
-- test compression with materialized view
CREATE MATERIALIZED VIEW compressmv(x) AS SELECT * FROM cmdata1;
---END---
---START---
\d+ compressmv
SELECT pg_column_compression(f1) FROM cmdata1;
---END---
---START---
SELECT pg_column_compression(x) FROM compressmv;
---END---
---START---
-- test compression with partition
CREATE TABLE cmpart(f1 text COMPRESSION lz4) PARTITION BY HASH(f1);
---END---
---START---
CREATE TABLE cmpart1 PARTITION OF cmpart FOR VALUES WITH (MODULUS 2, REMAINDER 0);
---END---
---START---
CREATE TABLE cmpart2(f1 text COMPRESSION pglz);
---END---
---START---
ALTER TABLE cmpart ATTACH PARTITION cmpart2 FOR VALUES WITH (MODULUS 2, REMAINDER 1);
---END---
---START---
INSERT INTO cmpart VALUES (repeat('123456789', 1004));
---END---
---START---
INSERT INTO cmpart VALUES (repeat('123456789', 4004));
---END---
---START---
SELECT pg_column_compression(f1) FROM cmpart1;
---END---
---START---
SELECT pg_column_compression(f1) FROM cmpart2;
---END---
---START---
-- test compression with inheritance, error
CREATE TABLE cminh() INHERITS(cmdata, cmdata1);
---END---
---START---
CREATE TABLE cminh(f1 TEXT COMPRESSION lz4) INHERITS(cmdata);
---END---
---START---
-- test default_toast_compression GUC
SET default_toast_compression = '';
---END---
---START---
SET default_toast_compression = 'I do not exist compression';
---END---
---START---
SET default_toast_compression = 'lz4';
---END---
---START---
SET default_toast_compression = 'pglz';
---END---
---START---
-- test alter compression method
ALTER TABLE cmdata ALTER COLUMN f1 SET COMPRESSION lz4;
---END---
---START---
INSERT INTO cmdata VALUES (repeat('123456789', 4004));
---END---
---START---
\d+ cmdata
SELECT pg_column_compression(f1) FROM cmdata;
---END---
---START---
ALTER TABLE cmdata2 ALTER COLUMN f1 SET COMPRESSION default;
---END---
---START---
\d+ cmdata2

-- test alter compression method for materialized views
ALTER MATERIALIZED VIEW compressmv ALTER COLUMN x SET COMPRESSION lz4;
---END---
---START---
\d+ compressmv

-- test alter compression method for partitioned tables
ALTER TABLE cmpart1 ALTER COLUMN f1 SET COMPRESSION pglz;
---END---
---START---
ALTER TABLE cmpart2 ALTER COLUMN f1 SET COMPRESSION lz4;
---END---
---START---
-- new data should be compressed with the current compression method
INSERT INTO cmpart VALUES (repeat('123456789', 1004));
---END---
---START---
INSERT INTO cmpart VALUES (repeat('123456789', 4004));
---END---
---START---
SELECT pg_column_compression(f1) FROM cmpart1;
---END---
---START---
SELECT pg_column_compression(f1) FROM cmpart2;
---END---
---START---
-- VACUUM FULL does not recompress
SELECT pg_column_compression(f1) FROM cmdata;
---END---
---START---
VACUUM FULL cmdata;
---END---
---START---
SELECT pg_column_compression(f1) FROM cmdata;
---END---
---START---
-- test expression index
DROP TABLE cmdata2;
---END---
---START---
CREATE TABLE cmdata2 (f1 TEXT COMPRESSION pglz, f2 TEXT COMPRESSION lz4);
---END---
---START---
CREATE UNIQUE INDEX idx1 ON cmdata2 ((f1 || f2));
---END---
---START---
INSERT INTO cmdata2 VALUES((SELECT array_agg(fipshash(g::TEXT))::TEXT FROM
generate_series(1, 50) g), VERSION());
---END---
---START---
-- check data is ok
SELECT length(f1) FROM cmdata;
---END---
---START---
SELECT length(f1) FROM cmdata1;
---END---
---START---
SELECT length(f1) FROM cmmove1;
---END---
---START---
SELECT length(f1) FROM cmmove2;
---END---
---START---
SELECT length(f1) FROM cmmove3;
---END---
---START---
CREATE TABLE badcompresstbl (a text COMPRESSION I_Do_Not_Exist_Compression);
---END---
---START---
-- fails
CREATE TABLE badcompresstbl (a text);
---END---
---START---
ALTER TABLE badcompresstbl ALTER a SET COMPRESSION I_Do_Not_Exist_Compression;
---END---
---START---
-- fails
DROP TABLE badcompresstbl;
---END---
---START---
\set HIDE_TOAST_COMPRESSION true;
---END---
