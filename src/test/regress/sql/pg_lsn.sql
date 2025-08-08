---START---
CREATE TABLE pg_lsn_tbl (_gemini_pk serial PRIMARY KEY, f1 pg_lsn);
---END---
---START---
-- Largest and smallest input
INSERT INTO PG_LSN_TBL VALUES ('0/0');
---END---
---START---
INSERT INTO PG_LSN_TBL VALUES ('FFFFFFFF/FFFFFFFF');
---END---
---START---
-- Incorrect input
INSERT INTO PG_LSN_TBL VALUES ('G/0');
---END---
---START---
INSERT INTO PG_LSN_TBL VALUES ('-1/0');
---END---
---START---
INSERT INTO PG_LSN_TBL VALUES (' 0/12345678');
---END---
---START---
INSERT INTO PG_LSN_TBL VALUES ('ABCD/');
---END---
---START---
INSERT INTO PG_LSN_TBL VALUES ('/ABCD');
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('16AE7F7', 'pg_lsn');
---END---
---START---
SELECT * FROM pg_input_error_info('16AE7F7', 'pg_lsn');
---END---
---START---
-- Min/Max aggregation
SELECT MIN(f1), MAX(f1) FROM PG_LSN_TBL;
---END---
---START---
DROP TABLE PG_LSN_TBL;
---END---
---START---
-- Operators
SELECT '0/16AE7F8' = '0/16AE7F8'::pg_lsn;
---END---
---START---
SELECT '0/16AE7F8'::pg_lsn != '0/16AE7F7';
---END---
---START---
SELECT '0/16AE7F7' < '0/16AE7F8'::pg_lsn;
---END---
---START---
SELECT '0/16AE7F8' > pg_lsn '0/16AE7F7';
---END---
---START---
SELECT '0/16AE7F7'::pg_lsn - '0/16AE7F8'::pg_lsn;
---END---
---START---
SELECT '0/16AE7F8'::pg_lsn - '0/16AE7F7'::pg_lsn;
---END---
---START---
SELECT '0/16AE7F7'::pg_lsn + 16::numeric;
---END---
---START---
SELECT 16::numeric + '0/16AE7F7'::pg_lsn;
---END---
---START---
SELECT '0/16AE7F7'::pg_lsn - 16::numeric;
---END---
---START---
SELECT 'FFFFFFFF/FFFFFFFE'::pg_lsn + 1::numeric;
---END---
---START---
SELECT 'FFFFFFFF/FFFFFFFE'::pg_lsn + 2::numeric;
---END---
---START---
-- out of range error
SELECT '0/1'::pg_lsn - 1::numeric;
---END---
---START---
SELECT '0/1'::pg_lsn - 2::numeric;
---END---
---START---
-- out of range error
SELECT '0/0'::pg_lsn + ('FFFFFFFF/FFFFFFFF'::pg_lsn - '0/0'::pg_lsn);
---END---
---START---
SELECT 'FFFFFFFF/FFFFFFFF'::pg_lsn - ('FFFFFFFF/FFFFFFFF'::pg_lsn - '0/0'::pg_lsn);
---END---
---START---
SELECT '0/16AE7F7'::pg_lsn + 'NaN'::numeric;
---END---
---START---
SELECT '0/16AE7F7'::pg_lsn - 'NaN'::numeric;
---END---
---START---
-- Check btree and hash opclasses
EXPLAIN (COSTS OFF)
SELECT DISTINCT (i || '/' || j)::pg_lsn f
  FROM generate_series(1, 10) i,
       generate_series(1, 10) j,
       generate_series(1, 5) k
  WHERE i <= 10 AND j > 0 AND j <= 10
  ORDER BY f;
---END---
---START---
SELECT DISTINCT (i || '/' || j)::pg_lsn f
  FROM generate_series(1, 10) i,
       generate_series(1, 10) j,
       generate_series(1, 5) k
  WHERE i <= 10 AND j > 0 AND j <= 10
  ORDER BY f;
---END---
