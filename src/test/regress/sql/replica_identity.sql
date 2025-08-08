---START---
CREATE TABLE test_replica_identity (
       id serial primary key,
       keya text not null,
       keyb text not null,
       nonkey text,
       CONSTRAINT test_replica_identity_unique_defer UNIQUE (keya, keyb) DEFERRABLE,
       CONSTRAINT test_replica_identity_unique_nondefer UNIQUE (keya, keyb)
);
---END---
---START---
CREATE TABLE test_replica_identity_othertable (id serial primary key);
---END---
---START---
CREATE INDEX test_replica_identity_keyab ON test_replica_identity (keya, keyb);
---END---
---START---
CREATE UNIQUE INDEX test_replica_identity_keyab_key ON test_replica_identity (keya, keyb);
---END---
---START---
CREATE UNIQUE INDEX test_replica_identity_nonkey ON test_replica_identity (keya, nonkey);
---END---
---START---
CREATE INDEX test_replica_identity_hash ON test_replica_identity USING hash (nonkey);
---END---
---START---
CREATE UNIQUE INDEX test_replica_identity_expr ON test_replica_identity (keya, keyb, (3));
---END---
---START---
CREATE UNIQUE INDEX test_replica_identity_partial ON test_replica_identity (keya, keyb) WHERE keyb != '3';
---END---
---START---
-- default is 'd'/DEFAULT for user created tables
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
-- but 'none' for system tables
SELECT relreplident FROM pg_class WHERE oid = 'pg_class'::regclass;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'pg_constraint'::regclass;
---END---
---START---
----
-- Make sure we detect ineligible indexes
----

-- fail, not unique
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_keyab;
---END---
---START---
-- fail, not a candidate key, nullable column
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_nonkey;
---END---
---START---
-- fail, hash indexes cannot do uniqueness
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_hash;
---END---
---START---
-- fail, expression index
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_expr;
---END---
---START---
-- fail, partial index
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_partial;
---END---
---START---
-- fail, not our index
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_othertable_pkey;
---END---
---START---
-- fail, deferrable
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_unique_defer;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
----
-- Make sure index cases succeed
----

-- succeed, primary key
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_pkey;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
\d test_replica_identity

-- succeed, nondeferrable unique constraint over nonnullable cols
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_unique_nondefer;
---END---
---START---
-- succeed unique index over nonnullable cols
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_keyab_key;
---END---
---START---
ALTER TABLE test_replica_identity REPLICA IDENTITY USING INDEX test_replica_identity_keyab_key;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
\d test_replica_identity
SELECT count(*) FROM pg_index WHERE indrelid = 'test_replica_identity'::regclass AND indisreplident;
---END---
---START---
----
-- Make sure non index cases work
----
ALTER TABLE test_replica_identity REPLICA IDENTITY DEFAULT;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
SELECT count(*) FROM pg_index WHERE indrelid = 'test_replica_identity'::regclass AND indisreplident;
---END---
---START---
ALTER TABLE test_replica_identity REPLICA IDENTITY FULL;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
\d+ test_replica_identity
ALTER TABLE test_replica_identity REPLICA IDENTITY NOTHING;
---END---
---START---
SELECT relreplident FROM pg_class WHERE oid = 'test_replica_identity'::regclass;
---END---
---START---
CREATE TABLE test_replica_identity2 (_gemini_pk serial PRIMARY KEY, id integer UNIQUE NOT NULL);
---END---
---START---
ALTER TABLE test_replica_identity2 REPLICA IDENTITY USING INDEX test_replica_identity2_id_key;
---END---
---START---
\d test_replica_identity2
ALTER TABLE test_replica_identity2 ALTER COLUMN id TYPE bigint;
---END---
---START---
\d test_replica_identity2

-- straight index variant
CREATE TABLE test_replica_identity3 (id int NOT NULL);
---END---
---START---
CREATE UNIQUE INDEX test_replica_identity3_id_key ON test_replica_identity3 (id);
---END---
---START---
ALTER TABLE test_replica_identity3 REPLICA IDENTITY USING INDEX test_replica_identity3_id_key;
---END---
---START---
\d test_replica_identity3
ALTER TABLE test_replica_identity3 ALTER COLUMN id TYPE bigint;
---END---
---START---
\d test_replica_identity3

-- ALTER TABLE DROP NOT NULL is not allowed for columns part of an index
-- used as replica identity.
ALTER TABLE test_replica_identity3 ALTER COLUMN id DROP NOT NULL;
---END---
---START---
CREATE TABLE test_replica_identity4 (_gemini_pk serial PRIMARY KEY, id integer NOT NULL) PARTITION BY list (id);
---END---
---START---
CREATE TABLE test_replica_identity4_1 (_gemini_pk serial PRIMARY KEY, id integer NOT NULL);
---END---
---START---
ALTER TABLE ONLY test_replica_identity4
  ATTACH PARTITION test_replica_identity4_1 FOR VALUES IN (1);
---END---
---START---
ALTER TABLE ONLY test_replica_identity4
  ADD CONSTRAINT test_replica_identity4_pkey PRIMARY KEY (id);
---END---
---START---
ALTER TABLE ONLY test_replica_identity4
  REPLICA IDENTITY USING INDEX test_replica_identity4_pkey;
---END---
---START---
ALTER TABLE ONLY test_replica_identity4_1
  ADD CONSTRAINT test_replica_identity4_1_pkey PRIMARY KEY (id);
---END---
---START---
\d+ test_replica_identity4
ALTER INDEX test_replica_identity4_pkey
  ATTACH PARTITION test_replica_identity4_1_pkey;
---END---
---START---
\d+ test_replica_identity4

DROP TABLE test_replica_identity;
---END---
---START---
DROP TABLE test_replica_identity2;
---END---
---START---
DROP TABLE test_replica_identity3;
---END---
---START---
DROP TABLE test_replica_identity4;
---END---
---START---
DROP TABLE test_replica_identity_othertable;
---END---
