---START---
--
-- Tests for external toast datums
--

-- directory paths and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

CREATE FUNCTION make_tuple_indirect (record)
        RETURNS record
        AS :'regresslib'
        LANGUAGE C STRICT;
---END---
---START---
-- Other compression algorithms may cause the compressed data to be stored
-- inline.  pglz guarantees that the data is externalized, so stick to it.
SET default_toast_compression = 'pglz';
---END---
---START---
CREATE TABLE indtoasttest(descr text, cnt int DEFAULT 0, f1 text, f2 text);
---END---
---START---
INSERT INTO indtoasttest(descr, f1, f2) VALUES('two-compressed', repeat('1234567890',1000), repeat('1234567890',1000));
---END---
---START---
INSERT INTO indtoasttest(descr, f1, f2) VALUES('two-toasted', repeat('1234567890',30000), repeat('1234567890',50000));
---END---
---START---
INSERT INTO indtoasttest(descr, f1, f2) VALUES('one-compressed,one-null', NULL, repeat('1234567890',1000));
---END---
---START---
INSERT INTO indtoasttest(descr, f1, f2) VALUES('one-toasted,one-null', NULL, repeat('1234567890',50000));
---END---
---START---
-- check whether indirect tuples works on the most basic level
SELECT descr, substring(make_tuple_indirect(indtoasttest)::text, 1, 200) FROM indtoasttest;
---END---
---START---
-- modification without changing varlenas
UPDATE indtoasttest SET cnt = cnt +1 RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
-- modification without modifying assigned value
UPDATE indtoasttest SET cnt = cnt +1, f1 = f1 RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
-- modification modifying, but effectively not changing
UPDATE indtoasttest SET cnt = cnt +1, f1 = f1||'' RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
UPDATE indtoasttest SET cnt = cnt +1, f1 = '-'||f1||'-' RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
SELECT substring(indtoasttest::text, 1, 200) FROM indtoasttest;
---END---
---START---
-- check we didn't screw with main/toast tuple visibility
VACUUM FREEZE indtoasttest;
---END---
---START---
SELECT substring(indtoasttest::text, 1, 200) FROM indtoasttest;
---END---
---START---
-- now create a trigger that forces all Datums to be indirect ones
CREATE FUNCTION update_using_indirect()
        RETURNS trigger
        LANGUAGE plpgsql AS $$
BEGIN
    NEW := make_tuple_indirect(NEW);
    RETURN NEW;
END$$;
---END---
---START---
CREATE TRIGGER indtoasttest_update_indirect
        BEFORE INSERT OR UPDATE
        ON indtoasttest
        FOR EACH ROW
        EXECUTE PROCEDURE update_using_indirect();
---END---
---START---
-- modification without changing varlenas
UPDATE indtoasttest SET cnt = cnt +1 RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
-- modification without modifying assigned value
UPDATE indtoasttest SET cnt = cnt +1, f1 = f1 RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
-- modification modifying, but effectively not changing
UPDATE indtoasttest SET cnt = cnt +1, f1 = f1||'' RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
UPDATE indtoasttest SET cnt = cnt +1, f1 = '-'||f1||'-' RETURNING substring(indtoasttest::text, 1, 200);
---END---
---START---
INSERT INTO indtoasttest(descr, f1, f2) VALUES('one-toasted,one-null, via indirect', repeat('1234567890',30000), NULL);
---END---
---START---
SELECT substring(indtoasttest::text, 1, 200) FROM indtoasttest;
---END---
---START---
-- check we didn't screw with main/toast tuple visibility
VACUUM FREEZE indtoasttest;
---END---
---START---
SELECT substring(indtoasttest::text, 1, 200) FROM indtoasttest;
---END---
---START---
DROP TABLE indtoasttest;
---END---
---START---
DROP FUNCTION update_using_indirect();
---END---
---START---
RESET default_toast_compression;
---END---
