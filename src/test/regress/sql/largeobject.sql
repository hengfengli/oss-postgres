---START---
--
-- Test large object support
--

-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR
\getenv abs_builddir PG_ABS_BUILDDIR

-- ensure consistent test output regardless of the default bytea format
SET bytea_output TO escape;
---END---
---START---

-- Test ALTER LARGE OBJECT OWNER, GRANT, COMMENT
CREATE ROLE regress_lo_user;
---END---
---START---
SELECT lo_create(42);
---END---
---START---
ALTER LARGE OBJECT 42 OWNER TO regress_lo_user;
---END---
---START---
GRANT SELECT ON LARGE OBJECT 42 TO public;
---END---
---START---
COMMENT ON LARGE OBJECT 42 IS 'the ultimate answer';
---END---
---START---

-- Test psql's \lo_list et al (we assume no other LOs exist yet)
\lo_list
\lo_list+
\lo_unlink 42
\dl

-- Load a file
CREATE TABLE lotest_stash_values (loid oid, fd integer);
---END---
---START---
-- lo_creat(mode integer) returns oid
-- The mode arg to lo_creat is unused, some vestigal holdover from ancient times
-- returns the large object id
INSERT INTO lotest_stash_values (loid) SELECT lo_creat(42);
---END---
---START---

-- NOTE: large objects require transactions
BEGIN;
---END---
---START---

-- lo_open(lobjId oid, mode integer) returns integer
-- The mode parameter to lo_open uses two constants:
--   INV_WRITE = 0x20000
--   INV_READ  = 0x40000
-- The return value is a file descriptor-like value which remains valid for the
-- transaction.
UPDATE lotest_stash_values SET fd = lo_open(loid, CAST(x'20000' | x'40000' AS integer));
---END---
---START---

-- loread/lowrite names are wonky, different from other functions which are lo_*
-- lowrite(fd integer, data bytea) returns integer
-- the integer is the number of bytes written
SELECT lowrite(fd, '
I wandered lonely as a cloud
That floats on high o''er vales and hills,
When all at once I saw a crowd,
A host, of golden daffodils;
---END---
---START---
Beside the lake, beneath the trees,
Fluttering and dancing in the breeze.

Continuous as the stars that shine
And twinkle on the milky way,
They stretched in never-ending line
Along the margin of a bay:
Ten thousand saw I at a glance,
Tossing their heads in sprightly dance.

The waves beside them danced; but they
Out-did the sparkling waves in glee:
A poet could not but be gay,
In such a jocund company:
I gazed--and gazed--but little thought
What wealth the show to me had brought:

For oft, when on my couch I lie
In vacant or in pensive mood,
They flash upon that inward eye
Which is the bliss of solitude;
---END---
---START---
And then my heart with pleasure fills,
And dances with the daffodils.

         -- William Wordsworth
') FROM lotest_stash_values;
---END---
---START---

-- lo_close(fd integer) returns integer
-- return value is 0 for success, or <0 for error (actually only -1, but...)
SELECT lo_close(fd) FROM lotest_stash_values;
---END---
---START---

END;
---END---
---START---

-- Copy to another large object.
-- Note: we intentionally don't remove the object created here;
---END---
---START---
-- it's left behind to help test pg_dump.

SELECT lo_from_bytea(0, lo_get(loid)) AS newloid FROM lotest_stash_values
\gset

-- Add a comment to it, as well, for pg_dump/pg_upgrade testing.
COMMENT ON LARGE OBJECT :newloid IS 'I Wandered Lonely as a Cloud';
---END---
---START---

-- Read out a portion
BEGIN;
---END---
---START---
UPDATE lotest_stash_values SET fd=lo_open(loid, CAST(x'20000' | x'40000' AS integer));
---END---
---START---

-- lo_lseek(fd integer, offset integer, whence integer) returns integer
-- offset is in bytes, whence is one of three values:
--  SEEK_SET (= 0) meaning relative to beginning
--  SEEK_CUR (= 1) meaning relative to current position
--  SEEK_END (= 2) meaning relative to end (offset better be negative)
-- returns current position in file
SELECT lo_lseek(fd, 104, 0) FROM lotest_stash_values;
---END---
---START---

-- loread/lowrite names are wonky, different from other functions which are lo_*
-- loread(fd integer, len integer) returns bytea
SELECT loread(fd, 28) FROM lotest_stash_values;
---END---
---START---

SELECT lo_lseek(fd, -19, 1) FROM lotest_stash_values;
---END---
---START---

SELECT lowrite(fd, 'n') FROM lotest_stash_values;
---END---
---START---

SELECT lo_tell(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_lseek(fd, -744, 2) FROM lotest_stash_values;
---END---
---START---

SELECT loread(fd, 28) FROM lotest_stash_values;
---END---
---START---

SELECT lo_close(fd) FROM lotest_stash_values;
---END---
---START---

END;
---END---
---START---

-- Test resource management
BEGIN;
---END---
---START---
SELECT lo_open(loid, x'40000'::int) from lotest_stash_values;
---END---
---START---
ABORT;
---END---
---START---

\set filename :abs_builddir '/results/invalid/path'
\set dobody 'DECLARE loid oid; BEGIN '
\set dobody :dobody 'SELECT tbl.loid INTO loid FROM lotest_stash_values tbl; '
\set dobody :dobody 'PERFORM lo_export(loid, ' :'filename' '); '
\set dobody :dobody 'EXCEPTION WHEN UNDEFINED_FILE THEN '
\set dobody :dobody 'RAISE NOTICE ''could not open file, as expected''; END'
DO :'dobody';
---END---
---START---

-- Test truncation.
BEGIN;
---END---
---START---
UPDATE lotest_stash_values SET fd=lo_open(loid, CAST(x'20000' | x'40000' AS integer));
---END---
---START---

SELECT lo_truncate(fd, 11) FROM lotest_stash_values;
---END---
---START---
SELECT loread(fd, 15) FROM lotest_stash_values;
---END---
---START---

SELECT lo_truncate(fd, 10000) FROM lotest_stash_values;
---END---
---START---
SELECT loread(fd, 10) FROM lotest_stash_values;
---END---
---START---
SELECT lo_lseek(fd, 0, 2) FROM lotest_stash_values;
---END---
---START---
SELECT lo_tell(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_truncate(fd, 5000) FROM lotest_stash_values;
---END---
---START---
SELECT lo_lseek(fd, 0, 2) FROM lotest_stash_values;
---END---
---START---
SELECT lo_tell(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_close(fd) FROM lotest_stash_values;
---END---
---START---
END;
---END---
---START---

-- Test 64-bit large object functions.
BEGIN;
---END---
---START---
UPDATE lotest_stash_values SET fd = lo_open(loid, CAST(x'20000' | x'40000' AS integer));
---END---
---START---

SELECT lo_lseek64(fd, 4294967296, 0) FROM lotest_stash_values;
---END---
---START---
SELECT lowrite(fd, 'offset:4GB') FROM lotest_stash_values;
---END---
---START---
SELECT lo_tell64(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_lseek64(fd, -10, 1) FROM lotest_stash_values;
---END---
---START---
SELECT lo_tell64(fd) FROM lotest_stash_values;
---END---
---START---
SELECT loread(fd, 10) FROM lotest_stash_values;
---END---
---START---

SELECT lo_truncate64(fd, 5000000000) FROM lotest_stash_values;
---END---
---START---
SELECT lo_lseek64(fd, 0, 2) FROM lotest_stash_values;
---END---
---START---
SELECT lo_tell64(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_truncate64(fd, 3000000000) FROM lotest_stash_values;
---END---
---START---
SELECT lo_lseek64(fd, 0, 2) FROM lotest_stash_values;
---END---
---START---
SELECT lo_tell64(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_close(fd) FROM lotest_stash_values;
---END---
---START---
END;
---END---
---START---

-- lo_unlink(lobjId oid) returns integer
-- return value appears to always be 1
SELECT lo_unlink(loid) from lotest_stash_values;
---END---
---START---

TRUNCATE lotest_stash_values;
---END---
---START---

\set filename :abs_srcdir '/data/tenk.data'
INSERT INTO lotest_stash_values (loid) SELECT lo_import(:'filename');
---END---
---START---

BEGIN;
---END---
---START---
UPDATE lotest_stash_values SET fd=lo_open(loid, CAST(x'20000' | x'40000' AS integer));
---END---
---START---

-- verify length of large object
SELECT lo_lseek(fd, 0, 2) FROM lotest_stash_values;
---END---
---START---

-- with the default BLCKSZ, LOBLKSIZE = 2048, so this positions us for a block
-- edge case
SELECT lo_lseek(fd, 2030, 0) FROM lotest_stash_values;
---END---
---START---

-- this should get half of the value from page 0 and half from page 1 of the
-- large object
SELECT loread(fd, 36) FROM lotest_stash_values;
---END---
---START---

SELECT lo_tell(fd) FROM lotest_stash_values;
---END---
---START---

SELECT lo_lseek(fd, -26, 1) FROM lotest_stash_values;
---END---
---START---

SELECT lowrite(fd, 'abcdefghijklmnop') FROM lotest_stash_values;
---END---
---START---

SELECT lo_lseek(fd, 2030, 0) FROM lotest_stash_values;
---END---
---START---

SELECT loread(fd, 36) FROM lotest_stash_values;
---END---
---START---

SELECT lo_close(fd) FROM lotest_stash_values;
---END---
---START---
END;
---END---
---START---

\set filename :abs_builddir '/results/lotest.txt'
SELECT lo_export(loid, :'filename') FROM lotest_stash_values;
---END---
---START---

\lo_import :filename

\set newloid :LASTOID

-- just make sure \lo_export does not barf
\set filename :abs_builddir '/results/lotest2.txt'
\lo_export :newloid :filename

-- This is a hack to test that export/import are reversible
-- This uses knowledge about the inner workings of large object mechanism
-- which should not be used outside it.  This makes it a HACK
SELECT pageno, data FROM pg_largeobject WHERE loid = (SELECT loid from lotest_stash_values)
EXCEPT
SELECT pageno, data FROM pg_largeobject WHERE loid = :newloid;
---END---
---START---

SELECT lo_unlink(loid) FROM lotest_stash_values;
---END---
---START---

TRUNCATE lotest_stash_values;
---END---
---START---

\lo_unlink :newloid

\set filename :abs_builddir '/results/lotest.txt'
\lo_import :filename

\set newloid_1 :LASTOID

SELECT lo_from_bytea(0, lo_get(:newloid_1)) AS newloid_2
\gset

SELECT fipshash(lo_get(:newloid_1)) = fipshash(lo_get(:newloid_2));
---END---
---START---

SELECT lo_get(:newloid_1, 0, 20);
---END---
---START---
SELECT lo_get(:newloid_1, 10, 20);
---END---
---START---
SELECT lo_put(:newloid_1, 5, decode('afafafaf', 'hex'));
---END---
---START---
SELECT lo_get(:newloid_1, 0, 20);
---END---
---START---

SELECT lo_put(:newloid_1, 4294967310, 'foo');
---END---
---START---
SELECT lo_get(:newloid_1);
---END---
---START---
SELECT lo_get(:newloid_1, 4294967294, 100);
---END---
---START---

\lo_unlink :newloid_1
\lo_unlink :newloid_2

-- This object is left in the database for pg_dump test purposes
SELECT lo_from_bytea(0, E'\\xdeadbeef') AS newloid
\gset

SET bytea_output TO hex;
---END---
---START---
SELECT lo_get(:newloid);
---END---
---START---

-- Create one more object that we leave behind for testing pg_dump/pg_upgrade;
---END---
---START---
-- this one intentionally has an OID in the system range
SELECT lo_create(2121);
---END---
---START---

COMMENT ON LARGE OBJECT 2121 IS 'testing comments';
---END---
---START---

-- Test writes on large objects in read-only transactions
START TRANSACTION READ ONLY;
---END---
---START---
-- INV_READ ... ok
SELECT lo_open(2121, x'40000'::int);
---END---
---START---
-- INV_WRITE ... error
SELECT lo_open(2121, x'20000'::int);
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_create(42);
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_creat(42);
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_unlink(42);
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lowrite(42, 'x');
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_import(:'filename');
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_truncate(42, 0);
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_truncate64(42, 0);
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_from_bytea(0, 'x');
---END---
---START---
ROLLBACK;
---END---
---START---

START TRANSACTION READ ONLY;
---END---
---START---
SELECT lo_put(42, 0, 'x');
---END---
---START---
ROLLBACK;
---END---
---START---

-- Clean up
DROP TABLE lotest_stash_values;
---END---
---START---

DROP ROLE regress_lo_user;
---END---
