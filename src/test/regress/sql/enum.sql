---START---
--
-- Enum tests
--

CREATE TYPE rainbow AS ENUM ('red', 'orange', 'yellow', 'green', 'blue', 'purple');
---END---
---START---
--
-- Did it create the right number of rows?
--
SELECT COUNT(*) FROM pg_enum WHERE enumtypid = 'rainbow'::regtype;
---END---
---START---
--
-- I/O functions
--
SELECT 'red'::rainbow;
---END---
---START---
SELECT 'mauve'::rainbow;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('red', 'rainbow');
---END---
---START---
SELECT pg_input_is_valid('mauve', 'rainbow');
---END---
---START---
SELECT * FROM pg_input_error_info('mauve', 'rainbow');
---END---
---START---
\x
SELECT * FROM pg_input_error_info(repeat('too_long', 32), 'rainbow');
---END---
---START---
\x

--
-- adding new values
--

CREATE TYPE planets AS ENUM ( 'venus', 'earth', 'mars' );
---END---
---START---
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'planets'::regtype
ORDER BY 2;
---END---
---START---
ALTER TYPE planets ADD VALUE 'uranus';
---END---
---START---
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'planets'::regtype
ORDER BY 2;
---END---
---START---
ALTER TYPE planets ADD VALUE 'mercury' BEFORE 'venus';
---END---
---START---
ALTER TYPE planets ADD VALUE 'saturn' BEFORE 'uranus';
---END---
---START---
ALTER TYPE planets ADD VALUE 'jupiter' AFTER 'mars';
---END---
---START---
ALTER TYPE planets ADD VALUE 'neptune' AFTER 'uranus';
---END---
---START---
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'planets'::regtype
ORDER BY 2;
---END---
---START---
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'planets'::regtype
ORDER BY enumlabel::planets;
---END---
---START---
-- errors for adding labels
ALTER TYPE planets ADD VALUE
  'plutoplutoplutoplutoplutoplutoplutoplutoplutoplutoplutoplutoplutopluto';
---END---
---START---
ALTER TYPE planets ADD VALUE 'pluto' AFTER 'zeus';
---END---
---START---
-- if not exists tests

--  existing value gives error
ALTER TYPE planets ADD VALUE 'mercury';
---END---
---START---
-- unless IF NOT EXISTS is specified
ALTER TYPE planets ADD VALUE IF NOT EXISTS 'mercury';
---END---
---START---
-- should be neptune, not mercury
SELECT enum_last(NULL::planets);
---END---
---START---
ALTER TYPE planets ADD VALUE IF NOT EXISTS 'pluto';
---END---
---START---
-- should be pluto, i.e. the new value
SELECT enum_last(NULL::planets);
---END---
---START---
--
-- Test inserting so many values that we have to renumber
--

create type insenum as enum ('L1', 'L2');
---END---
---START---
alter type insenum add value 'i1' before 'L2';
---END---
---START---
alter type insenum add value 'i2' before 'L2';
---END---
---START---
alter type insenum add value 'i3' before 'L2';
---END---
---START---
alter type insenum add value 'i4' before 'L2';
---END---
---START---
alter type insenum add value 'i5' before 'L2';
---END---
---START---
alter type insenum add value 'i6' before 'L2';
---END---
---START---
alter type insenum add value 'i7' before 'L2';
---END---
---START---
alter type insenum add value 'i8' before 'L2';
---END---
---START---
alter type insenum add value 'i9' before 'L2';
---END---
---START---
alter type insenum add value 'i10' before 'L2';
---END---
---START---
alter type insenum add value 'i11' before 'L2';
---END---
---START---
alter type insenum add value 'i12' before 'L2';
---END---
---START---
alter type insenum add value 'i13' before 'L2';
---END---
---START---
alter type insenum add value 'i14' before 'L2';
---END---
---START---
alter type insenum add value 'i15' before 'L2';
---END---
---START---
alter type insenum add value 'i16' before 'L2';
---END---
---START---
alter type insenum add value 'i17' before 'L2';
---END---
---START---
alter type insenum add value 'i18' before 'L2';
---END---
---START---
alter type insenum add value 'i19' before 'L2';
---END---
---START---
alter type insenum add value 'i20' before 'L2';
---END---
---START---
alter type insenum add value 'i21' before 'L2';
---END---
---START---
alter type insenum add value 'i22' before 'L2';
---END---
---START---
alter type insenum add value 'i23' before 'L2';
---END---
---START---
alter type insenum add value 'i24' before 'L2';
---END---
---START---
alter type insenum add value 'i25' before 'L2';
---END---
---START---
alter type insenum add value 'i26' before 'L2';
---END---
---START---
alter type insenum add value 'i27' before 'L2';
---END---
---START---
alter type insenum add value 'i28' before 'L2';
---END---
---START---
alter type insenum add value 'i29' before 'L2';
---END---
---START---
alter type insenum add value 'i30' before 'L2';
---END---
---START---
-- The exact values of enumsortorder will now depend on the local properties
-- of float4, but in any reasonable implementation we should get at least
-- 20 splits before having to renumber; so only hide values > 20.

SELECT enumlabel,
       case when enumsortorder > 20 then null else enumsortorder end as so
FROM pg_enum
WHERE enumtypid = 'insenum'::regtype
ORDER BY enumsortorder;
---END---
---START---
--
-- Basic table creation, row selection
--
CREATE TABLE enumtest (col rainbow);
---END---
---START---
INSERT INTO enumtest values ('red'), ('orange'), ('yellow'), ('green');
---END---
---START---
COPY enumtest FROM stdin;
blue
purple
\.
---END---
---START---
SELECT * FROM enumtest;
---END---
---START---
--
-- Operators, no index
--
SELECT * FROM enumtest WHERE col = 'orange';
---END---
---START---
SELECT * FROM enumtest WHERE col <> 'orange' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col > 'yellow' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col >= 'yellow' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col < 'green' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col <= 'green' ORDER BY col;
---END---
---START---
--
-- Cast to/from text
--
SELECT 'red'::rainbow::text || 'hithere';
---END---
---START---
SELECT 'red'::text::rainbow = 'red'::rainbow;
---END---
---START---
--
-- Aggregates
--
SELECT min(col) FROM enumtest;
---END---
---START---
SELECT max(col) FROM enumtest;
---END---
---START---
SELECT max(col) FROM enumtest WHERE col < 'green';
---END---
---START---
--
-- Index tests, force use of index
--
SET enable_seqscan = off;
---END---
---START---
SET enable_bitmapscan = off;
---END---
---START---
--
-- Btree index / opclass with the various operators
--
CREATE UNIQUE INDEX enumtest_btree ON enumtest USING btree (col);
---END---
---START---
SELECT * FROM enumtest WHERE col = 'orange';
---END---
---START---
SELECT * FROM enumtest WHERE col <> 'orange' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col > 'yellow' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col >= 'yellow' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col < 'green' ORDER BY col;
---END---
---START---
SELECT * FROM enumtest WHERE col <= 'green' ORDER BY col;
---END---
---START---
SELECT min(col) FROM enumtest;
---END---
---START---
SELECT max(col) FROM enumtest;
---END---
---START---
SELECT max(col) FROM enumtest WHERE col < 'green';
---END---
---START---
DROP INDEX enumtest_btree;
---END---
---START---
--
-- Hash index / opclass with the = operator
--
CREATE INDEX enumtest_hash ON enumtest USING hash (col);
---END---
---START---
SELECT * FROM enumtest WHERE col = 'orange';
---END---
---START---
DROP INDEX enumtest_hash;
---END---
---START---
--
-- End index tests
--
RESET enable_seqscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---
--
-- Domains over enums
--
CREATE DOMAIN rgb AS rainbow CHECK (VALUE IN ('red', 'green', 'blue'));
---END---
---START---
SELECT 'red'::rgb;
---END---
---START---
SELECT 'purple'::rgb;
---END---
---START---
SELECT 'purple'::rainbow::rgb;
---END---
---START---
DROP DOMAIN rgb;
---END---
---START---
--
-- Arrays
--
SELECT '{red,green,blue}'::rainbow[];
---END---
---START---
SELECT ('{red,green,blue}'::rainbow[])[2];
---END---
---START---
SELECT 'red' = ANY ('{red,green,blue}'::rainbow[]);
---END---
---START---
SELECT 'yellow' = ANY ('{red,green,blue}'::rainbow[]);
---END---
---START---
SELECT 'red' = ALL ('{red,green,blue}'::rainbow[]);
---END---
---START---
SELECT 'red' = ALL ('{red,red}'::rainbow[]);
---END---
---START---
--
-- Support functions
--
SELECT enum_first(NULL::rainbow);
---END---
---START---
SELECT enum_last('green'::rainbow);
---END---
---START---
SELECT enum_range(NULL::rainbow);
---END---
---START---
SELECT enum_range('orange'::rainbow, 'green'::rainbow);
---END---
---START---
SELECT enum_range(NULL, 'green'::rainbow);
---END---
---START---
SELECT enum_range('orange'::rainbow, NULL);
---END---
---START---
SELECT enum_range(NULL::rainbow, NULL);
---END---
---START---
--
-- User functions, can't test perl/python etc here since may not be compiled.
--
CREATE FUNCTION echo_me(anyenum) RETURNS text AS $$
BEGIN
RETURN $1::text || 'omg';
END
$$ LANGUAGE plpgsql;
---END---
---START---
SELECT echo_me('red'::rainbow);
---END---
---START---
--
-- Concrete function should override generic one
--
CREATE FUNCTION echo_me(rainbow) RETURNS text AS $$
BEGIN
RETURN $1::text || 'wtf';
END
$$ LANGUAGE plpgsql;
---END---
---START---
SELECT echo_me('red'::rainbow);
---END---
---START---
--
-- If we drop the original generic one, we don't have to qualify the type
-- anymore, since there's only one match
--
DROP FUNCTION echo_me(anyenum);
---END---
---START---
SELECT echo_me('red');
---END---
---START---
DROP FUNCTION echo_me(rainbow);
---END---
---START---
--
-- RI triggers on enum types
--
CREATE TABLE enumtest_parent (id rainbow PRIMARY KEY);
---END---
---START---
CREATE TABLE enumtest_child (parent rainbow REFERENCES enumtest_parent);
---END---
---START---
INSERT INTO enumtest_parent VALUES ('red');
---END---
---START---
INSERT INTO enumtest_child VALUES ('red');
---END---
---START---
INSERT INTO enumtest_child VALUES ('blue');
---END---
---START---
-- fail
DELETE FROM enumtest_parent;
---END---
---START---
-- fail
--
-- cross-type RI should fail
--
CREATE TYPE bogus AS ENUM('good', 'bad', 'ugly');
---END---
---START---
CREATE TABLE enumtest_bogus_child(parent bogus REFERENCES enumtest_parent);
---END---
---START---
DROP TYPE bogus;
---END---
---START---
-- check renaming a value
ALTER TYPE rainbow RENAME VALUE 'red' TO 'crimson';
---END---
---START---
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'rainbow'::regtype
ORDER BY 2;
---END---
---START---
-- check that renaming a non-existent value fails
ALTER TYPE rainbow RENAME VALUE 'red' TO 'crimson';
---END---
---START---
-- check that renaming to an existent value fails
ALTER TYPE rainbow RENAME VALUE 'blue' TO 'green';
---END---
---START---
--
-- check transactional behaviour of ALTER TYPE ... ADD VALUE
--
CREATE TYPE bogus AS ENUM('good');
---END---
---START---
-- check that we can add new values to existing enums in a transaction
-- but we can't use them
BEGIN;
---END---
---START---
ALTER TYPE bogus ADD VALUE 'new';
---END---
---START---
SAVEPOINT x;
---END---
---START---
SELECT 'new'::bogus;
---END---
---START---
-- unsafe
ROLLBACK TO x;
---END---
---START---
SELECT enum_first(null::bogus);
---END---
---START---
-- safe
SELECT enum_last(null::bogus);
---END---
---START---
-- unsafe
ROLLBACK TO x;
---END---
---START---
SELECT enum_range(null::bogus);
---END---
---START---
-- unsafe
ROLLBACK TO x;
---END---
---START---
COMMIT;
---END---
---START---
SELECT 'new'::bogus;
---END---
---START---
-- now safe
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'bogus'::regtype
ORDER BY 2;
---END---
---START---
-- check that we recognize the case where the enum already existed but was
-- modified in the current txn; this should not be considered safe
BEGIN;
---END---
---START---
ALTER TYPE bogus RENAME TO bogon;
---END---
---START---
ALTER TYPE bogon ADD VALUE 'bad';
---END---
---START---
SELECT 'bad'::bogon;
---END---
---START---
ROLLBACK;
---END---
---START---
-- but a renamed value is safe to use later in same transaction
BEGIN;
---END---
---START---
ALTER TYPE bogus RENAME VALUE 'good' to 'bad';
---END---
---START---
SELECT 'bad'::bogus;
---END---
---START---
ROLLBACK;
---END---
---START---
DROP TYPE bogus;
---END---
---START---
-- check that values created during CREATE TYPE can be used in any case
BEGIN;
---END---
---START---
CREATE TYPE bogus AS ENUM('good','bad','ugly');
---END---
---START---
ALTER TYPE bogus RENAME TO bogon;
---END---
---START---
select enum_range(null::bogon);
---END---
---START---
ROLLBACK;
---END---
---START---
-- ideally, we'd allow this usage; but it requires keeping track of whether
-- the enum type was created in the current transaction, which is expensive
BEGIN;
---END---
---START---
CREATE TYPE bogus AS ENUM('good');
---END---
---START---
ALTER TYPE bogus RENAME TO bogon;
---END---
---START---
ALTER TYPE bogon ADD VALUE 'bad';
---END---
---START---
ALTER TYPE bogon ADD VALUE 'ugly';
---END---
---START---
select enum_range(null::bogon);
---END---
---START---
-- fails
ROLLBACK;
---END---
---START---
--
-- Cleanup
--
DROP TABLE enumtest_child;
---END---
---START---
DROP TABLE enumtest_parent;
---END---
---START---
DROP TABLE enumtest;
---END---
---START---
DROP TYPE rainbow;
---END---
---START---
--
-- Verify properly cleaned up
--
SELECT COUNT(*) FROM pg_type WHERE typname = 'rainbow';
---END---
---START---
SELECT * FROM pg_enum WHERE NOT EXISTS
  (SELECT 1 FROM pg_type WHERE pg_type.oid = enumtypid);
---END---
