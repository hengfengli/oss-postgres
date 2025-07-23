---START---
SET max_parallel_maintenance_workers TO 4;
---END---
---START---
SET min_parallel_index_scan_size TO '128kB';
---END---
---START---

-- Bug #17245: Make sure that we don't totally fail to VACUUM individual indexes that
-- happen to be below min_parallel_index_scan_size during parallel VACUUM:
CREATE TABLE parallel_vacuum_table (a int) WITH (autovacuum_enabled = off);
---END---
---START---
INSERT INTO parallel_vacuum_table SELECT i from generate_series(1, 10000) i;
---END---
---START---

-- Parallel VACUUM will never be used unless there are at least two indexes
-- that exceed min_parallel_index_scan_size.  Create two such indexes, and
-- a third index that is smaller than min_parallel_index_scan_size.
CREATE INDEX regular_sized_index ON parallel_vacuum_table(a);
---END---
---START---
CREATE INDEX typically_sized_index ON parallel_vacuum_table(a);
---END---
---START---
-- Note: vacuum_in_leader_small_index can apply deduplication, making it ~3x
-- smaller than the other indexes
CREATE INDEX vacuum_in_leader_small_index ON parallel_vacuum_table((1));
---END---
---START---

-- Verify (as best we can) that the cost model for parallel VACUUM
-- will make our VACUUM run in parallel, while always leaving it up to the
-- parallel leader to handle the vacuum_in_leader_small_index index:
SELECT EXISTS (
SELECT 1
FROM pg_class
WHERE oid = 'vacuum_in_leader_small_index'::regclass AND
  pg_relation_size(oid) <
  pg_size_bytes(current_setting('min_parallel_index_scan_size'))
) as leader_will_handle_small_index;
---END---
---START---
SELECT count(*) as trigger_parallel_vacuum_nindexes
FROM pg_class
WHERE oid in ('regular_sized_index'::regclass, 'typically_sized_index'::regclass) AND
  pg_relation_size(oid) >=
  pg_size_bytes(current_setting('min_parallel_index_scan_size'));
---END---
---START---

-- Parallel VACUUM with B-Tree page deletions, ambulkdelete calls:
DELETE FROM parallel_vacuum_table;
---END---
---START---
VACUUM (PARALLEL 4, INDEX_CLEANUP ON) parallel_vacuum_table;
---END---
---START---

-- Since vacuum_in_leader_small_index uses deduplication, we expect an
-- assertion failure with bug #17245 (in the absence of bugfix):
INSERT INTO parallel_vacuum_table SELECT i FROM generate_series(1, 10000) i;
---END---
---START---

RESET max_parallel_maintenance_workers;
---END---
---START---
RESET min_parallel_index_scan_size;
---END---
