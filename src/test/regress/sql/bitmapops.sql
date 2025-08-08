---START---
CREATE TABLE bmscantest (gemini_pk serial PRIMARY KEY, a integer, b integer, t text);
---END---
---START---
INSERT INTO bmscantest
  SELECT (r%53), (r%59), 'foooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo'
  FROM generate_series(1,70000) r;
---END---
---START---
CREATE INDEX i_bmtest_a ON bmscantest(a);
---END---
---START---
CREATE INDEX i_bmtest_b ON bmscantest(b);
---END---
---START---
-- We want to use bitmapscans. With default settings, the planner currently
-- chooses a bitmap scan for the queries below anyway, but let's make sure.
set enable_indexscan=false;
---END---
---START---
set enable_seqscan=false;
---END---
---START---
-- Lower work_mem to trigger use of lossy bitmaps
set work_mem = 64;
---END---
---START---
-- Test bitmap-and.
SELECT count(*) FROM bmscantest WHERE a = 1 AND b = 1;
---END---
---START---
-- Test bitmap-or.
SELECT count(*) FROM bmscantest WHERE a = 1 OR b = 1;
---END---
---START---
-- clean up
DROP TABLE bmscantest;
---END---
