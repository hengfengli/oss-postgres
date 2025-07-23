---START---
CREATE TABLE test_tablesample (id int, name text) WITH (fillfactor=10);
---END---
---START---
-- use fillfactor so we don't have to load too much data to get multiple pages

INSERT INTO test_tablesample
  SELECT i, repeat(i::text, 200) FROM generate_series(0, 9) s(i);
---END---
---START---

SELECT t.id FROM test_tablesample AS t TABLESAMPLE SYSTEM (50) REPEATABLE (0);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (100.0/11) REPEATABLE (0);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (50) REPEATABLE (0);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE BERNOULLI (50) REPEATABLE (0);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE BERNOULLI (5.5) REPEATABLE (0);
---END---
---START---

-- 100% should give repeatable count results (ie, all rows) in any case
SELECT count(*) FROM test_tablesample TABLESAMPLE SYSTEM (100);
---END---
---START---
SELECT count(*) FROM test_tablesample TABLESAMPLE SYSTEM (100) REPEATABLE (1+2);
---END---
---START---
SELECT count(*) FROM test_tablesample TABLESAMPLE SYSTEM (100) REPEATABLE (0.4);
---END---
---START---

CREATE VIEW test_tablesample_v1 AS
  SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (10*2) REPEATABLE (2);
---END---
---START---
CREATE VIEW test_tablesample_v2 AS
  SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (99);
---END---
---START---
\d+ test_tablesample_v1
\d+ test_tablesample_v2

-- check a sampled query doesn't affect cursor in progress
BEGIN;
---END---
---START---
DECLARE tablesample_cur SCROLL CURSOR FOR
  SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (50) REPEATABLE (0);
---END---
---START---

FETCH FIRST FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---

SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (50) REPEATABLE (0);
---END---
---START---

FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---

FETCH FIRST FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---
FETCH NEXT FROM tablesample_cur;
---END---
---START---

CLOSE tablesample_cur;
---END---
---START---
END;
---END---
---START---

EXPLAIN (COSTS OFF)
  SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (50) REPEATABLE (2);
---END---
---START---
EXPLAIN (COSTS OFF)
  SELECT * FROM test_tablesample_v1;
---END---
---START---

-- check inheritance behavior
explain (costs off)
  select count(*) from person tablesample bernoulli (100);
---END---
---START---
select count(*) from person tablesample bernoulli (100);
---END---
---START---
select count(*) from person;
---END---
---START---

-- check that collations get assigned within the tablesample arguments
SELECT count(*) FROM test_tablesample TABLESAMPLE bernoulli (('1'::text < '0'::text)::int);
---END---
---START---

-- check behavior during rescans, as well as correct handling of min/max pct
select * from
  (values (0),(100)) v(pct),
  lateral (select count(*) from tenk1 tablesample bernoulli (pct)) ss;
---END---
---START---
select * from
  (values (0),(100)) v(pct),
  lateral (select count(*) from tenk1 tablesample system (pct)) ss;
---END---
---START---
explain (costs off)
select pct, count(unique1) from
  (values (0),(100)) v(pct),
  lateral (select * from tenk1 tablesample bernoulli (pct)) ss
  group by pct;
---END---
---START---
select pct, count(unique1) from
  (values (0),(100)) v(pct),
  lateral (select * from tenk1 tablesample bernoulli (pct)) ss
  group by pct;
---END---
---START---
select pct, count(unique1) from
  (values (0),(100)) v(pct),
  lateral (select * from tenk1 tablesample system (pct)) ss
  group by pct;
---END---
---START---

-- errors
SELECT id FROM test_tablesample TABLESAMPLE FOOBAR (1);
---END---
---START---

SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (NULL);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (50) REPEATABLE (NULL);
---END---
---START---

SELECT id FROM test_tablesample TABLESAMPLE BERNOULLI (-1);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE BERNOULLI (200);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (-1);
---END---
---START---
SELECT id FROM test_tablesample TABLESAMPLE SYSTEM (200);
---END---
---START---

SELECT id FROM test_tablesample_v1 TABLESAMPLE BERNOULLI (1);
---END---
---START---
INSERT INTO test_tablesample_v1 VALUES(1);
---END---
---START---

WITH query_select AS (SELECT * FROM test_tablesample)
SELECT * FROM query_select TABLESAMPLE BERNOULLI (5.5) REPEATABLE (1);
---END---
---START---

SELECT q.* FROM (SELECT * FROM test_tablesample) as q TABLESAMPLE BERNOULLI (5);
---END---
---START---

-- check partitioned tables support tablesample
create table parted_sample (a int) partition by list (a);
---END---
---START---
create table parted_sample_1 partition of parted_sample for values in (1);
---END---
---START---
create table parted_sample_2 partition of parted_sample for values in (2);
---END---
---START---
explain (costs off)
  select * from parted_sample tablesample bernoulli (100);
---END---
---START---
drop table parted_sample, parted_sample_1, parted_sample_2;
---END---
