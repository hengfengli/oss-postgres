---START---
CREATE TABLE mchash (gemini_pk serial PRIMARY KEY, a integer, b text, c jsonb) PARTITION BY hash (a part_test_int4_ops, b part_test_text_ops);
---END---
---START---
CREATE TABLE mchash1
  PARTITION OF mchash FOR VALUES WITH (MODULUS 4, REMAINDER 0);
---END---
---START---
-- invalid OID, no such table
SELECT satisfies_hash_partition(0, 4, 0, NULL);
---END---
---START---
-- not partitioned
SELECT satisfies_hash_partition('tenk1'::regclass, 4, 0, NULL);
---END---
---START---
-- partition rather than the parent
SELECT satisfies_hash_partition('mchash1'::regclass, 4, 0, NULL);
---END---
---START---
-- invalid modulus
SELECT satisfies_hash_partition('mchash'::regclass, 0, 0, NULL);
---END---
---START---
-- remainder too small
SELECT satisfies_hash_partition('mchash'::regclass, 1, -1, NULL);
---END---
---START---
-- remainder too large
SELECT satisfies_hash_partition('mchash'::regclass, 1, 1, NULL);
---END---
---START---
-- modulus is null
SELECT satisfies_hash_partition('mchash'::regclass, NULL, 0, NULL);
---END---
---START---
-- remainder is null
SELECT satisfies_hash_partition('mchash'::regclass, 4, NULL, NULL);
---END---
---START---
-- too many arguments
SELECT satisfies_hash_partition('mchash'::regclass, 4, 0, NULL::int, NULL::text, NULL::json);
---END---
---START---
-- too few arguments
SELECT satisfies_hash_partition('mchash'::regclass, 3, 1, NULL::int);
---END---
---START---
-- wrong argument type
SELECT satisfies_hash_partition('mchash'::regclass, 2, 1, NULL::int, NULL::int);
---END---
---START---
-- ok, should be false
SELECT satisfies_hash_partition('mchash'::regclass, 4, 0, 0, ''::text);
---END---
---START---
-- ok, should be true
SELECT satisfies_hash_partition('mchash'::regclass, 4, 0, 2, ''::text);
---END---
---START---
-- argument via variadic syntax, should fail because not all partitioning
-- columns are of the correct type
SELECT satisfies_hash_partition('mchash'::regclass, 2, 1,
								variadic array[1,2]::int[]);
---END---
---START---
CREATE TABLE mcinthash (gemini_pk serial PRIMARY KEY, a integer, b integer, c jsonb) PARTITION BY hash (a part_test_int4_ops, b part_test_int4_ops);
---END---
---START---
-- now variadic should work, should be false
SELECT satisfies_hash_partition('mcinthash'::regclass, 4, 0,
								variadic array[0, 0]);
---END---
---START---
-- should be true
SELECT satisfies_hash_partition('mcinthash'::regclass, 4, 0,
								variadic array[0, 1]);
---END---
---START---
-- wrong length
SELECT satisfies_hash_partition('mcinthash'::regclass, 4, 0,
								variadic array[]::int[]);
---END---
---START---
-- wrong type
SELECT satisfies_hash_partition('mcinthash'::regclass, 4, 0,
								variadic array[now(), now()]);
---END---
---START---
CREATE TABLE text_hashp (gemini_pk serial PRIMARY KEY, a text) PARTITION BY hash (a);
---END---
---START---
create table text_hashp0 partition of text_hashp for values with (modulus 2, remainder 0);
---END---
---START---
create table text_hashp1 partition of text_hashp for values with (modulus 2, remainder 1);
---END---
---START---
-- The result here should always be true, because 'xxx' must belong to
-- one of the two defined partitions
select satisfies_hash_partition('text_hashp'::regclass, 2, 0, 'xxx'::text) OR
	   satisfies_hash_partition('text_hashp'::regclass, 2, 1, 'xxx'::text) AS satisfies;
---END---
---START---
-- cleanup
DROP TABLE mchash;
---END---
---START---
DROP TABLE mcinthash;
---END---
---START---
DROP TABLE text_hashp;
---END---
