---START---
--
-- PARTITION_JOIN
-- Test partitionwise join between partitioned tables
--

-- Enable partitionwise join, which by default is disabled.
SET enable_partitionwise_join to true;
---END---
---START---
CREATE TABLE prt1 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt1_p1 PARTITION OF prt1 FOR VALUES FROM (0) TO (250);
---END---
---START---
CREATE TABLE prt1_p3 PARTITION OF prt1 FOR VALUES FROM (500) TO (600);
---END---
---START---
CREATE TABLE prt1_p2 PARTITION OF prt1 FOR VALUES FROM (250) TO (500);
---END---
---START---
INSERT INTO prt1 SELECT i, i % 25, to_char(i, 'FM0000') FROM generate_series(0, 599) i WHERE i % 2 = 0;
---END---
---START---
CREATE INDEX iprt1_p1_a on prt1_p1(a);
---END---
---START---
CREATE INDEX iprt1_p2_a on prt1_p2(a);
---END---
---START---
CREATE INDEX iprt1_p3_a on prt1_p3(a);
---END---
---START---
ANALYZE prt1;
---END---
---START---
CREATE TABLE prt2 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (b);
---END---
---START---
CREATE TABLE prt2_p1 PARTITION OF prt2 FOR VALUES FROM (0) TO (250);
---END---
---START---
CREATE TABLE prt2_p2 PARTITION OF prt2 FOR VALUES FROM (250) TO (500);
---END---
---START---
CREATE TABLE prt2_p3 PARTITION OF prt2 FOR VALUES FROM (500) TO (600);
---END---
---START---
INSERT INTO prt2 SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(0, 599) i WHERE i % 3 = 0;
---END---
---START---
CREATE INDEX iprt2_p1_b on prt2_p1(b);
---END---
---START---
CREATE INDEX iprt2_p2_b on prt2_p2(b);
---END---
---START---
CREATE INDEX iprt2_p3_b on prt2_p3(b);
---END---
---START---
ANALYZE prt2;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt2 t2 WHERE t1.a = t2.b AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt2 t2 WHERE t1.a = t2.b AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- left outer join, 3-way
EXPLAIN (COSTS OFF)
SELECT COUNT(*) FROM prt1 t1
  LEFT JOIN prt1 t2 ON t1.a = t2.a
  LEFT JOIN prt1 t3 ON t2.a = t3.a;
---END---
---START---
SELECT COUNT(*) FROM prt1 t1
  LEFT JOIN prt1 t2 ON t1.a = t2.a
  LEFT JOIN prt1 t3 ON t2.a = t3.a;
---END---
---START---
-- left outer join, with whole-row reference; partitionwise join does not apply
EXPLAIN (COSTS OFF)
SELECT t1, t2 FROM prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1, t2 FROM prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- right outer join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1 RIGHT JOIN prt2 t2 ON t1.a = t2.b WHERE t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1 RIGHT JOIN prt2 t2 ON t1.a = t2.b WHERE t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- full outer join, with placeholder vars
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT 50 phv, * FROM prt1 WHERE prt1.b = 0) t1 FULL JOIN (SELECT 75 phv, * FROM prt2 WHERE prt2.a = 0) t2 ON (t1.a = t2.b) WHERE t1.phv = t1.a OR t2.phv = t2.b ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT 50 phv, * FROM prt1 WHERE prt1.b = 0) t1 FULL JOIN (SELECT 75 phv, * FROM prt2 WHERE prt2.a = 0) t2 ON (t1.a = t2.b) WHERE t1.phv = t1.a OR t2.phv = t2.b ORDER BY t1.a, t2.b;
---END---
---START---
-- Join with pruned partitions from joining relations
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt2 t2 WHERE t1.a = t2.b AND t1.a < 450 AND t2.b > 250 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt2 t2 WHERE t1.a = t2.b AND t1.a < 450 AND t2.b > 250 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- Currently we can't do partitioned join if nullable-side partitions are pruned
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a < 450) t1 LEFT JOIN (SELECT * FROM prt2 WHERE b > 250) t2 ON t1.a = t2.b WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a < 450) t1 LEFT JOIN (SELECT * FROM prt2 WHERE b > 250) t2 ON t1.a = t2.b WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- Currently we can't do partitioned join if nullable-side partitions are pruned
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a < 450) t1 FULL JOIN (SELECT * FROM prt2 WHERE b > 250) t2 ON t1.a = t2.b WHERE t1.b = 0 OR t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a < 450) t1 FULL JOIN (SELECT * FROM prt2 WHERE b > 250) t2 ON t1.a = t2.b WHERE t1.b = 0 OR t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- Semi-join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t2.b FROM prt2 t2 WHERE t2.a = 0) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t2.b FROM prt2 t2 WHERE t2.a = 0) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- Anti-join with aggregates
EXPLAIN (COSTS OFF)
SELECT sum(t1.a), avg(t1.a), sum(t1.b), avg(t1.b) FROM prt1 t1 WHERE NOT EXISTS (SELECT 1 FROM prt2 t2 WHERE t1.a = t2.b);
---END---
---START---
SELECT sum(t1.a), avg(t1.a), sum(t1.b), avg(t1.b) FROM prt1 t1 WHERE NOT EXISTS (SELECT 1 FROM prt2 t2 WHERE t1.a = t2.b);
---END---
---START---
-- lateral reference
EXPLAIN (COSTS OFF)
SELECT * FROM prt1 t1 LEFT JOIN LATERAL
			  (SELECT t2.a AS t2a, t3.a AS t3a, least(t1.a,t2.a,t3.b) FROM prt1 t2 JOIN prt2 t3 ON (t2.a = t3.b)) ss
			  ON t1.a = ss.t2a WHERE t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT * FROM prt1 t1 LEFT JOIN LATERAL
			  (SELECT t2.a AS t2a, t3.a AS t3a, least(t1.a,t2.a,t3.b) FROM prt1 t2 JOIN prt2 t3 ON (t2.a = t3.b)) ss
			  ON t1.a = ss.t2a WHERE t1.b = 0 ORDER BY t1.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, ss.t2a, ss.t2c FROM prt1 t1 LEFT JOIN LATERAL
			  (SELECT t2.a AS t2a, t3.a AS t3a, t2.b t2b, t2.c t2c, least(t1.a,t2.a,t3.b) FROM prt1 t2 JOIN prt2 t3 ON (t2.a = t3.b)) ss
			  ON t1.c = ss.t2c WHERE (t1.b + coalesce(ss.t2b, 0)) = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, ss.t2a, ss.t2c FROM prt1 t1 LEFT JOIN LATERAL
			  (SELECT t2.a AS t2a, t3.a AS t3a, t2.b t2b, t2.c t2c, least(t1.a,t2.a,t3.a) FROM prt1 t2 JOIN prt2 t3 ON (t2.a = t3.b)) ss
			  ON t1.c = ss.t2c WHERE (t1.b + coalesce(ss.t2b, 0)) = 0 ORDER BY t1.a;
---END---
---START---
-- bug with inadequate sort key representation
SET enable_partitionwise_aggregate TO true;
---END---
---START---
SET enable_hashjoin TO false;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT a, b FROM prt1 FULL JOIN prt2 p2(b,a,c) USING(a,b)
  WHERE a BETWEEN 490 AND 510
  GROUP BY 1, 2 ORDER BY 1, 2;
---END---
---START---
SELECT a, b FROM prt1 FULL JOIN prt2 p2(b,a,c) USING(a,b)
  WHERE a BETWEEN 490 AND 510
  GROUP BY 1, 2 ORDER BY 1, 2;
---END---
---START---
RESET enable_partitionwise_aggregate;
---END---
---START---
RESET enable_hashjoin;
---END---
---START---
CREATE TABLE prt1_e (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (((a + b) / 2));
---END---
---START---
CREATE TABLE prt1_e_p1 PARTITION OF prt1_e FOR VALUES FROM (0) TO (250);
---END---
---START---
CREATE TABLE prt1_e_p2 PARTITION OF prt1_e FOR VALUES FROM (250) TO (500);
---END---
---START---
CREATE TABLE prt1_e_p3 PARTITION OF prt1_e FOR VALUES FROM (500) TO (600);
---END---
---START---
INSERT INTO prt1_e SELECT i, i, i % 25 FROM generate_series(0, 599, 2) i;
---END---
---START---
CREATE INDEX iprt1_e_p1_ab2 on prt1_e_p1(((a+b)/2));
---END---
---START---
CREATE INDEX iprt1_e_p2_ab2 on prt1_e_p2(((a+b)/2));
---END---
---START---
CREATE INDEX iprt1_e_p3_ab2 on prt1_e_p3(((a+b)/2));
---END---
---START---
ANALYZE prt1_e;
---END---
---START---
CREATE TABLE prt2_e (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (((b + a) / 2));
---END---
---START---
CREATE TABLE prt2_e_p1 PARTITION OF prt2_e FOR VALUES FROM (0) TO (250);
---END---
---START---
CREATE TABLE prt2_e_p2 PARTITION OF prt2_e FOR VALUES FROM (250) TO (500);
---END---
---START---
CREATE TABLE prt2_e_p3 PARTITION OF prt2_e FOR VALUES FROM (500) TO (600);
---END---
---START---
INSERT INTO prt2_e SELECT i, i, i % 25 FROM generate_series(0, 599, 3) i;
---END---
---START---
ANALYZE prt2_e;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_e t1, prt2_e t2 WHERE (t1.a + t1.b)/2 = (t2.b + t2.a)/2 AND t1.c = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_e t1, prt2_e t2 WHERE (t1.a + t1.b)/2 = (t2.b + t2.a)/2 AND t1.c = 0 ORDER BY t1.a, t2.b;
---END---
---START---
--
-- N-way join
--
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM prt1 t1, prt2 t2, prt1_e t3 WHERE t1.a = t2.b AND t1.a = (t3.a + t3.b)/2 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM prt1 t1, prt2 t2, prt1_e t3 WHERE t1.a = t2.b AND t1.a = (t3.a + t3.b)/2 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM (prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b) LEFT JOIN prt1_e t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t1.b = 0 ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM (prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b) LEFT JOIN prt1_e t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t1.b = 0 ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM (prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b) RIGHT JOIN prt1_e t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t3.c = 0 ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM (prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b) RIGHT JOIN prt1_e t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t3.c = 0 ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
--
-- 3-way full join
--
EXPLAIN (COSTS OFF)
SELECT COUNT(*) FROM prt1 FULL JOIN prt2 p2(b,a,c) USING(a,b) FULL JOIN prt2 p3(b,a,c) USING (a, b)
  WHERE a BETWEEN 490 AND 510;
---END---
---START---
SELECT COUNT(*) FROM prt1 FULL JOIN prt2 p2(b,a,c) USING(a,b) FULL JOIN prt2 p3(b,a,c) USING (a, b)
  WHERE a BETWEEN 490 AND 510;
---END---
---START---
--
-- 4-way full join
--
EXPLAIN (COSTS OFF)
SELECT COUNT(*) FROM prt1 FULL JOIN prt2 p2(b,a,c) USING(a,b) FULL JOIN prt2 p3(b,a,c) USING (a, b) FULL JOIN prt1 p4 (a,b,c) USING (a, b)
  WHERE a BETWEEN 490 AND 510;
---END---
---START---
SELECT COUNT(*) FROM prt1 FULL JOIN prt2 p2(b,a,c) USING(a,b) FULL JOIN prt2 p3(b,a,c) USING (a, b) FULL JOIN prt1 p4 (a,b,c) USING (a, b)
  WHERE a BETWEEN 490 AND 510;
---END---
---START---
-- Cases with non-nullable expressions in subquery results;
-- make sure these go to null as expected
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.phv, t2.b, t2.phv, t3.a + t3.b, t3.phv FROM ((SELECT 50 phv, * FROM prt1 WHERE prt1.b = 0) t1 FULL JOIN (SELECT 75 phv, * FROM prt2 WHERE prt2.a = 0) t2 ON (t1.a = t2.b)) FULL JOIN (SELECT 50 phv, * FROM prt1_e WHERE prt1_e.c = 0) t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t1.a = t1.phv OR t2.b = t2.phv OR (t3.a + t3.b)/2 = t3.phv ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
SELECT t1.a, t1.phv, t2.b, t2.phv, t3.a + t3.b, t3.phv FROM ((SELECT 50 phv, * FROM prt1 WHERE prt1.b = 0) t1 FULL JOIN (SELECT 75 phv, * FROM prt2 WHERE prt2.a = 0) t2 ON (t1.a = t2.b)) FULL JOIN (SELECT 50 phv, * FROM prt1_e WHERE prt1_e.c = 0) t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t1.a = t1.phv OR t2.b = t2.phv OR (t3.a + t3.b)/2 = t3.phv ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
-- Semi-join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t1.b FROM prt2 t1, prt1_e t2 WHERE t1.a = 0 AND t1.b = (t2.a + t2.b)/2) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t1.b FROM prt2 t1, prt1_e t2 WHERE t1.a = 0 AND t1.b = (t2.a + t2.b)/2) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t1.b FROM prt2 t1 WHERE t1.b IN (SELECT (t1.a + t1.b)/2 FROM prt1_e t1 WHERE t1.c = 0)) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t1.b FROM prt2 t1 WHERE t1.b IN (SELECT (t1.a + t1.b)/2 FROM prt1_e t1 WHERE t1.c = 0)) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- test merge joins
SET enable_hashjoin TO off;
---END---
---START---
SET enable_nestloop TO off;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t1.b FROM prt2 t1 WHERE t1.b IN (SELECT (t1.a + t1.b)/2 FROM prt1_e t1 WHERE t1.c = 0)) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1 t1 WHERE t1.a IN (SELECT t1.b FROM prt2 t1 WHERE t1.b IN (SELECT (t1.a + t1.b)/2 FROM prt1_e t1 WHERE t1.c = 0)) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM (prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b) RIGHT JOIN prt1_e t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t3.c = 0 ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c, t3.a + t3.b, t3.c FROM (prt1 t1 LEFT JOIN prt2 t2 ON t1.a = t2.b) RIGHT JOIN prt1_e t3 ON (t1.a = (t3.a + t3.b)/2) WHERE t3.c = 0 ORDER BY t1.a, t2.b, t3.a + t3.b;
---END---
---START---
-- MergeAppend on nullable column
-- This should generate a partitionwise join, but currently fails to
EXPLAIN (COSTS OFF)
SELECT t1.a, t2.b FROM (SELECT * FROM prt1 WHERE a < 450) t1 LEFT JOIN (SELECT * FROM prt2 WHERE b > 250) t2 ON t1.a = t2.b WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t2.b FROM (SELECT * FROM prt1 WHERE a < 450) t1 LEFT JOIN (SELECT * FROM prt2 WHERE b > 250) t2 ON t1.a = t2.b WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- merge join when expression with whole-row reference needs to be sorted;
-- partitionwise join does not apply
EXPLAIN (COSTS OFF)
SELECT t1.a, t2.b FROM prt1 t1, prt2 t2 WHERE t1::text = t2::text AND t1.a = t2.b ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t2.b FROM prt1 t1, prt2 t2 WHERE t1::text = t2::text AND t1.a = t2.b ORDER BY t1.a;
---END---
---START---
RESET enable_hashjoin;
---END---
---START---
RESET enable_nestloop;
---END---
---START---
CREATE TABLE prt1_m (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (a, ((a + b) / 2));
---END---
---START---
CREATE TABLE prt1_m_p1 PARTITION OF prt1_m FOR VALUES FROM (0, 0) TO (250, 250);
---END---
---START---
CREATE TABLE prt1_m_p2 PARTITION OF prt1_m FOR VALUES FROM (250, 250) TO (500, 500);
---END---
---START---
CREATE TABLE prt1_m_p3 PARTITION OF prt1_m FOR VALUES FROM (500, 500) TO (600, 600);
---END---
---START---
INSERT INTO prt1_m SELECT i, i, i % 25 FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE prt1_m;
---END---
---START---
CREATE TABLE prt2_m (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (((b + a) / 2), b);
---END---
---START---
CREATE TABLE prt2_m_p1 PARTITION OF prt2_m FOR VALUES FROM (0, 0) TO (250, 250);
---END---
---START---
CREATE TABLE prt2_m_p2 PARTITION OF prt2_m FOR VALUES FROM (250, 250) TO (500, 500);
---END---
---START---
CREATE TABLE prt2_m_p3 PARTITION OF prt2_m FOR VALUES FROM (500, 500) TO (600, 600);
---END---
---START---
INSERT INTO prt2_m SELECT i, i, i % 25 FROM generate_series(0, 599, 3) i;
---END---
---START---
ANALYZE prt2_m;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1_m WHERE prt1_m.c = 0) t1 FULL JOIN (SELECT * FROM prt2_m WHERE prt2_m.c = 0) t2 ON (t1.a = (t2.b + t2.a)/2 AND t2.b = (t1.a + t1.b)/2) ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1_m WHERE prt1_m.c = 0) t1 FULL JOIN (SELECT * FROM prt2_m WHERE prt2_m.c = 0) t2 ON (t1.a = (t2.b + t2.a)/2 AND t2.b = (t1.a + t1.b)/2) ORDER BY t1.a, t2.b;
---END---
---START---
CREATE TABLE plt1 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt1_p1 PARTITION OF plt1 FOR VALUES IN ('0000', '0003', '0004', '0010');
---END---
---START---
CREATE TABLE plt1_p2 PARTITION OF plt1 FOR VALUES IN ('0001', '0005', '0002', '0009');
---END---
---START---
CREATE TABLE plt1_p3 PARTITION OF plt1 FOR VALUES IN ('0006', '0007', '0008', '0011');
---END---
---START---
INSERT INTO plt1 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE plt1;
---END---
---START---
CREATE TABLE plt2 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt2_p1 PARTITION OF plt2 FOR VALUES IN ('0000', '0003', '0004', '0010');
---END---
---START---
CREATE TABLE plt2_p2 PARTITION OF plt2 FOR VALUES IN ('0001', '0005', '0002', '0009');
---END---
---START---
CREATE TABLE plt2_p3 PARTITION OF plt2 FOR VALUES IN ('0006', '0007', '0008', '0011');
---END---
---START---
INSERT INTO plt2 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 599, 3) i;
---END---
---START---
ANALYZE plt2;
---END---
---START---
CREATE TABLE plt1_e (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list ((ltrim(c, 'A')));
---END---
---START---
CREATE TABLE plt1_e_p1 PARTITION OF plt1_e FOR VALUES IN ('0000', '0003', '0004', '0010');
---END---
---START---
CREATE TABLE plt1_e_p2 PARTITION OF plt1_e FOR VALUES IN ('0001', '0005', '0002', '0009');
---END---
---START---
CREATE TABLE plt1_e_p3 PARTITION OF plt1_e FOR VALUES IN ('0006', '0007', '0008', '0011');
---END---
---START---
INSERT INTO plt1_e SELECT i, i, 'A' || to_char(i/50, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE plt1_e;
---END---
---START---
-- test partition matching with N-way join
EXPLAIN (COSTS OFF)
SELECT avg(t1.a), avg(t2.b), avg(t3.a + t3.b), t1.c, t2.c, t3.c FROM plt1 t1, plt2 t2, plt1_e t3 WHERE t1.b = t2.b AND t1.c = t2.c AND ltrim(t3.c, 'A') = t1.c GROUP BY t1.c, t2.c, t3.c ORDER BY t1.c, t2.c, t3.c;
---END---
---START---
SELECT avg(t1.a), avg(t2.b), avg(t3.a + t3.b), t1.c, t2.c, t3.c FROM plt1 t1, plt2 t2, plt1_e t3 WHERE t1.b = t2.b AND t1.c = t2.c AND ltrim(t3.c, 'A') = t1.c GROUP BY t1.c, t2.c, t3.c ORDER BY t1.c, t2.c, t3.c;
---END---
---START---
-- joins where one of the relations is proven empty
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt2 t2 WHERE t1.a = t2.b AND t1.a = 1 AND t1.a = 2;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a = 1 AND a = 2) t1 LEFT JOIN prt2 t2 ON t1.a = t2.b;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a = 1 AND a = 2) t1 RIGHT JOIN prt2 t2 ON t1.a = t2.b, prt1 t3 WHERE t2.b = t3.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1 WHERE a = 1 AND a = 2) t1 FULL JOIN prt2 t2 ON t1.a = t2.b WHERE t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
CREATE TABLE pht1 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY hash (c);
---END---
---START---
CREATE TABLE pht1_p1 PARTITION OF pht1 FOR VALUES WITH (MODULUS 3, REMAINDER 0);
---END---
---START---
CREATE TABLE pht1_p2 PARTITION OF pht1 FOR VALUES WITH (MODULUS 3, REMAINDER 1);
---END---
---START---
CREATE TABLE pht1_p3 PARTITION OF pht1 FOR VALUES WITH (MODULUS 3, REMAINDER 2);
---END---
---START---
INSERT INTO pht1 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE pht1;
---END---
---START---
CREATE TABLE pht2 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY hash (c);
---END---
---START---
CREATE TABLE pht2_p1 PARTITION OF pht2 FOR VALUES WITH (MODULUS 3, REMAINDER 0);
---END---
---START---
CREATE TABLE pht2_p2 PARTITION OF pht2 FOR VALUES WITH (MODULUS 3, REMAINDER 1);
---END---
---START---
CREATE TABLE pht2_p3 PARTITION OF pht2 FOR VALUES WITH (MODULUS 3, REMAINDER 2);
---END---
---START---
INSERT INTO pht2 SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 599, 3) i;
---END---
---START---
ANALYZE pht2;
---END---
---START---
CREATE TABLE pht1_e (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY hash ((ltrim(c, 'A')));
---END---
---START---
CREATE TABLE pht1_e_p1 PARTITION OF pht1_e FOR VALUES WITH (MODULUS 3, REMAINDER 0);
---END---
---START---
CREATE TABLE pht1_e_p2 PARTITION OF pht1_e FOR VALUES WITH (MODULUS 3, REMAINDER 1);
---END---
---START---
CREATE TABLE pht1_e_p3 PARTITION OF pht1_e FOR VALUES WITH (MODULUS 3, REMAINDER 2);
---END---
---START---
INSERT INTO pht1_e SELECT i, i, 'A' || to_char(i/50, 'FM0000') FROM generate_series(0, 299, 2) i;
---END---
---START---
ANALYZE pht1_e;
---END---
---START---
-- test partition matching with N-way join
EXPLAIN (COSTS OFF)
SELECT avg(t1.a), avg(t2.b), avg(t3.a + t3.b), t1.c, t2.c, t3.c FROM pht1 t1, pht2 t2, pht1_e t3 WHERE t1.b = t2.b AND t1.c = t2.c AND ltrim(t3.c, 'A') = t1.c GROUP BY t1.c, t2.c, t3.c ORDER BY t1.c, t2.c, t3.c;
---END---
---START---
SELECT avg(t1.a), avg(t2.b), avg(t3.a + t3.b), t1.c, t2.c, t3.c FROM pht1 t1, pht2 t2, pht1_e t3 WHERE t1.b = t2.b AND t1.c = t2.c AND ltrim(t3.c, 'A') = t1.c GROUP BY t1.c, t2.c, t3.c ORDER BY t1.c, t2.c, t3.c;
---END---
---START---
-- test default partition behavior for range
ALTER TABLE prt1 DETACH PARTITION prt1_p3;
---END---
---START---
ALTER TABLE prt1 ATTACH PARTITION prt1_p3 DEFAULT;
---END---
---START---
ANALYZE prt1;
---END---
---START---
ALTER TABLE prt2 DETACH PARTITION prt2_p3;
---END---
---START---
ALTER TABLE prt2 ATTACH PARTITION prt2_p3 DEFAULT;
---END---
---START---
ANALYZE prt2;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt2 t2 WHERE t1.a = t2.b AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- test default partition behavior for list
ALTER TABLE plt1 DETACH PARTITION plt1_p3;
---END---
---START---
ALTER TABLE plt1 ATTACH PARTITION plt1_p3 DEFAULT;
---END---
---START---
ANALYZE plt1;
---END---
---START---
ALTER TABLE plt2 DETACH PARTITION plt2_p3;
---END---
---START---
ALTER TABLE plt2 ATTACH PARTITION plt2_p3 DEFAULT;
---END---
---START---
ANALYZE plt2;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT avg(t1.a), avg(t2.b), t1.c, t2.c FROM plt1 t1 RIGHT JOIN plt2 t2 ON t1.c = t2.c WHERE t1.a % 25 = 0 GROUP BY t1.c, t2.c ORDER BY t1.c, t2.c;
---END---
---START---
CREATE TABLE prt1_l (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt1_l_p1 PARTITION OF prt1_l FOR VALUES FROM (0) TO (250);
---END---
---START---
CREATE TABLE prt1_l_p2 PARTITION OF prt1_l FOR VALUES FROM (250) TO (500) PARTITION BY LIST (c);
---END---
---START---
CREATE TABLE prt1_l_p2_p1 PARTITION OF prt1_l_p2 FOR VALUES IN ('0000', '0001');
---END---
---START---
CREATE TABLE prt1_l_p2_p2 PARTITION OF prt1_l_p2 FOR VALUES IN ('0002', '0003');
---END---
---START---
CREATE TABLE prt1_l_p3 PARTITION OF prt1_l FOR VALUES FROM (500) TO (600) PARTITION BY RANGE (b);
---END---
---START---
CREATE TABLE prt1_l_p3_p1 PARTITION OF prt1_l_p3 FOR VALUES FROM (0) TO (13);
---END---
---START---
CREATE TABLE prt1_l_p3_p2 PARTITION OF prt1_l_p3 FOR VALUES FROM (13) TO (25);
---END---
---START---
INSERT INTO prt1_l SELECT i, i % 25, to_char(i % 4, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE prt1_l;
---END---
---START---
CREATE TABLE prt2_l (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (b);
---END---
---START---
CREATE TABLE prt2_l_p1 PARTITION OF prt2_l FOR VALUES FROM (0) TO (250);
---END---
---START---
CREATE TABLE prt2_l_p2 PARTITION OF prt2_l FOR VALUES FROM (250) TO (500) PARTITION BY LIST (c);
---END---
---START---
CREATE TABLE prt2_l_p2_p1 PARTITION OF prt2_l_p2 FOR VALUES IN ('0000', '0001');
---END---
---START---
CREATE TABLE prt2_l_p2_p2 PARTITION OF prt2_l_p2 FOR VALUES IN ('0002', '0003');
---END---
---START---
CREATE TABLE prt2_l_p3 PARTITION OF prt2_l FOR VALUES FROM (500) TO (600) PARTITION BY RANGE (a);
---END---
---START---
CREATE TABLE prt2_l_p3_p1 PARTITION OF prt2_l_p3 FOR VALUES FROM (0) TO (13);
---END---
---START---
CREATE TABLE prt2_l_p3_p2 PARTITION OF prt2_l_p3 FOR VALUES FROM (13) TO (25);
---END---
---START---
INSERT INTO prt2_l SELECT i % 25, i, to_char(i % 4, 'FM0000') FROM generate_series(0, 599, 3) i;
---END---
---START---
ANALYZE prt2_l;
---END---
---START---
-- inner join, qual covering only top-level partitions
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_l t1, prt2_l t2 WHERE t1.a = t2.b AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_l t1, prt2_l t2 WHERE t1.a = t2.b AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_l t1 LEFT JOIN prt2_l t2 ON t1.a = t2.b AND t1.c = t2.c WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_l t1 LEFT JOIN prt2_l t2 ON t1.a = t2.b AND t1.c = t2.c WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- right join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_l t1 RIGHT JOIN prt2_l t2 ON t1.a = t2.b AND t1.c = t2.c WHERE t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_l t1 RIGHT JOIN prt2_l t2 ON t1.a = t2.b AND t1.c = t2.c WHERE t2.a = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1_l WHERE prt1_l.b = 0) t1 FULL JOIN (SELECT * FROM prt2_l WHERE prt2_l.a = 0) t2 ON (t1.a = t2.b AND t1.c = t2.c) ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1_l WHERE prt1_l.b = 0) t1 FULL JOIN (SELECT * FROM prt2_l WHERE prt2_l.a = 0) t2 ON (t1.a = t2.b AND t1.c = t2.c) ORDER BY t1.a, t2.b;
---END---
---START---
-- lateral partitionwise join
EXPLAIN (COSTS OFF)
SELECT * FROM prt1_l t1 LEFT JOIN LATERAL
			  (SELECT t2.a AS t2a, t2.c AS t2c, t2.b AS t2b, t3.b AS t3b, least(t1.a,t2.a,t3.b) FROM prt1_l t2 JOIN prt2_l t3 ON (t2.a = t3.b AND t2.c = t3.c)) ss
			  ON t1.a = ss.t2a AND t1.c = ss.t2c WHERE t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT * FROM prt1_l t1 LEFT JOIN LATERAL
			  (SELECT t2.a AS t2a, t2.c AS t2c, t2.b AS t2b, t3.b AS t3b, least(t1.a,t2.a,t3.b) FROM prt1_l t2 JOIN prt2_l t3 ON (t2.a = t3.b AND t2.c = t3.c)) ss
			  ON t1.a = ss.t2a AND t1.c = ss.t2c WHERE t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- join with one side empty
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT * FROM prt1_l WHERE a = 1 AND a = 2) t1 RIGHT JOIN prt2_l t2 ON t1.a = t2.b AND t1.b = t2.a AND t1.c = t2.c;
---END---
---START---
-- Test case to verify proper handling of subqueries in a partitioned delete.
-- The weird-looking lateral join is just there to force creation of a
-- nestloop parameter within the subquery, which exposes the problem if the
-- planner fails to make multiple copies of the subquery as appropriate.
EXPLAIN (COSTS OFF)
DELETE FROM prt1_l
WHERE EXISTS (
  SELECT 1
    FROM int4_tbl,
         LATERAL (SELECT int4_tbl.f1 FROM int8_tbl LIMIT 2) ss
    WHERE prt1_l.c IS NULL);
---END---
---START---
CREATE TABLE prt1_n (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (c);
---END---
---START---
CREATE TABLE prt1_n_p1 PARTITION OF prt1_n FOR VALUES FROM ('0000') TO ('0250');
---END---
---START---
CREATE TABLE prt1_n_p2 PARTITION OF prt1_n FOR VALUES FROM ('0250') TO ('0500');
---END---
---START---
INSERT INTO prt1_n SELECT i, i, to_char(i, 'FM0000') FROM generate_series(0, 499, 2) i;
---END---
---START---
ANALYZE prt1_n;
---END---
---START---
CREATE TABLE prt2_n (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE prt2_n_p1 PARTITION OF prt2_n FOR VALUES IN ('0000', '0003', '0004', '0010', '0006', '0007');
---END---
---START---
CREATE TABLE prt2_n_p2 PARTITION OF prt2_n FOR VALUES IN ('0001', '0005', '0002', '0009', '0008', '0011');
---END---
---START---
INSERT INTO prt2_n SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE prt2_n;
---END---
---START---
CREATE TABLE prt3_n (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE prt3_n_p1 PARTITION OF prt3_n FOR VALUES IN ('0000', '0004', '0006', '0007');
---END---
---START---
CREATE TABLE prt3_n_p2 PARTITION OF prt3_n FOR VALUES IN ('0001', '0002', '0008', '0010');
---END---
---START---
CREATE TABLE prt3_n_p3 PARTITION OF prt3_n FOR VALUES IN ('0003', '0005', '0009', '0011');
---END---
---START---
INSERT INTO prt2_n SELECT i, i, to_char(i/50, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE prt3_n;
---END---
---START---
CREATE TABLE prt4_n (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt4_n_p1 PARTITION OF prt4_n FOR VALUES FROM (0) TO (300);
---END---
---START---
CREATE TABLE prt4_n_p2 PARTITION OF prt4_n FOR VALUES FROM (300) TO (500);
---END---
---START---
CREATE TABLE prt4_n_p3 PARTITION OF prt4_n FOR VALUES FROM (500) TO (600);
---END---
---START---
INSERT INTO prt4_n SELECT i, i, to_char(i, 'FM0000') FROM generate_series(0, 599, 2) i;
---END---
---START---
ANALYZE prt4_n;
---END---
---START---
-- partitionwise join can not be applied if the partition ranges differ
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt4_n t2 WHERE t1.a = t2.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1, prt4_n t2, prt2 t3 WHERE t1.a = t2.a and t1.a = t3.b;
---END---
---START---
-- partitionwise join can not be applied if there are no equi-join conditions
-- between partition keys
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1 t1 LEFT JOIN prt2 t2 ON (t1.a < t2.b);
---END---
---START---
-- equi-join with join condition on partial keys does not qualify for
-- partitionwise join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_m t1, prt2_m t2 WHERE t1.a = (t2.b + t2.a)/2;
---END---
---START---
-- equi-join between out-of-order partition key columns does not qualify for
-- partitionwise join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_m t1 LEFT JOIN prt2_m t2 ON t1.a = t2.b;
---END---
---START---
-- equi-join between non-key columns does not qualify for partitionwise join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_m t1 LEFT JOIN prt2_m t2 ON t1.c = t2.c;
---END---
---START---
-- partitionwise join can not be applied for a join between list and range
-- partitioned tables
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_n t1 LEFT JOIN prt2_n t2 ON (t1.c = t2.c);
---END---
---START---
-- partitionwise join can not be applied between tables with different
-- partition lists
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_n t1 JOIN prt2_n t2 ON (t1.c = t2.c) JOIN plt1 t3 ON (t1.c = t3.c);
---END---
---START---
-- partitionwise join can not be applied for a join between key column and
-- non-key column
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_n t1 FULL JOIN prt1 t2 ON (t1.c = t2.c);
---END---
---START---
--
-- Test some other plan types in a partitionwise join (unfortunately,
-- we need larger tables to get the planner to choose these plan types)
--
DROP TABLE IF EXISTS prtx1;

CREATE TABLE prtx1 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (a);
---END---
---START---
DROP TABLE IF EXISTS prtx1_1;

create table prtx1_1 partition of prtx1 for values from (1) to (11);
---END---
---START---
DROP TABLE IF EXISTS prtx1_2;

create table prtx1_2 partition of prtx1 for values from (11) to (21);
---END---
---START---
DROP TABLE IF EXISTS prtx1_3;

create table prtx1_3 partition of prtx1 for values from (21) to (31);
---END---
---START---
DROP TABLE IF EXISTS prtx2;

CREATE TABLE prtx2 (_gemini_pk serial PRIMARY KEY, a integer, b integer, c integer) PARTITION BY range (a);
---END---
---START---
DROP TABLE IF EXISTS prtx2_1;

create table prtx2_1 partition of prtx2 for values from (1) to (11);
---END---
---START---
DROP TABLE IF EXISTS prtx2_2;

create table prtx2_2 partition of prtx2 for values from (11) to (21);
---END---
---START---
DROP TABLE IF EXISTS prtx2_3;

create table prtx2_3 partition of prtx2 for values from (21) to (31);
---END---
---START---
insert into prtx1 select 1 + i%30, i, i
  from generate_series(1,1000) i;
---END---
---START---
insert into prtx2 select 1 + i%30, i, i
  from generate_series(1,500) i, generate_series(1,10) j;
---END---
---START---
create index on prtx2 (b);
---END---
---START---
create index on prtx2 (c);
---END---
---START---
analyze prtx1;
---END---
---START---
analyze prtx2;
---END---
---START---
explain (costs off)
select * from prtx1
where not exists (select 1 from prtx2
                  where prtx2.a=prtx1.a and prtx2.b=prtx1.b and prtx2.c=123)
  and a<20 and c=120;
---END---
---START---
select * from prtx1
where not exists (select 1 from prtx2
                  where prtx2.a=prtx1.a and prtx2.b=prtx1.b and prtx2.c=123)
  and a<20 and c=120;
---END---
---START---
explain (costs off)
select * from prtx1
where not exists (select 1 from prtx2
                  where prtx2.a=prtx1.a and (prtx2.b=prtx1.b+1 or prtx2.c=99))
  and a<20 and c=91;
---END---
---START---
select * from prtx1
where not exists (select 1 from prtx2
                  where prtx2.a=prtx1.a and (prtx2.b=prtx1.b+1 or prtx2.c=99))
  and a<20 and c=91;
---END---
---START---
CREATE TABLE prt1_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt1_adv_p1 PARTITION OF prt1_adv FOR VALUES FROM (100) TO (200);
---END---
---START---
CREATE TABLE prt1_adv_p2 PARTITION OF prt1_adv FOR VALUES FROM (200) TO (300);
---END---
---START---
CREATE TABLE prt1_adv_p3 PARTITION OF prt1_adv FOR VALUES FROM (300) TO (400);
---END---
---START---
CREATE INDEX prt1_adv_a_idx ON prt1_adv (a);
---END---
---START---
INSERT INTO prt1_adv SELECT i, i % 25, to_char(i, 'FM0000') FROM generate_series(100, 399) i;
---END---
---START---
ANALYZE prt1_adv;
---END---
---START---
CREATE TABLE prt2_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (b);
---END---
---START---
CREATE TABLE prt2_adv_p1 PARTITION OF prt2_adv FOR VALUES FROM (100) TO (150);
---END---
---START---
CREATE TABLE prt2_adv_p2 PARTITION OF prt2_adv FOR VALUES FROM (200) TO (300);
---END---
---START---
CREATE TABLE prt2_adv_p3 PARTITION OF prt2_adv FOR VALUES FROM (350) TO (500);
---END---
---START---
CREATE INDEX prt2_adv_b_idx ON prt2_adv (b);
---END---
---START---
INSERT INTO prt2_adv_p1 SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(100, 149) i;
---END---
---START---
INSERT INTO prt2_adv_p2 SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(200, 299) i;
---END---
---START---
INSERT INTO prt2_adv_p3 SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(350, 499) i;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1_adv t1 WHERE EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1_adv t1 WHERE EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT 175 phv, * FROM prt1_adv WHERE prt1_adv.b = 0) t1 FULL JOIN (SELECT 425 phv, * FROM prt2_adv WHERE prt2_adv.a = 0) t2 ON (t1.a = t2.b) WHERE t1.phv = t1.a OR t2.phv = t2.b ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT 175 phv, * FROM prt1_adv WHERE prt1_adv.b = 0) t1 FULL JOIN (SELECT 425 phv, * FROM prt2_adv WHERE prt2_adv.a = 0) t2 ON (t1.a = t2.b) WHERE t1.phv = t1.a OR t2.phv = t2.b ORDER BY t1.a, t2.b;
---END---
---START---
-- Test cases where one side has an extra partition
CREATE TABLE prt2_adv_extra PARTITION OF prt2_adv FOR VALUES FROM (500) TO (MAXVALUE);
---END---
---START---
INSERT INTO prt2_adv SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(500, 599) i;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1_adv t1 WHERE EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1_adv t1 WHERE EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- left join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.b, t1.c, t2.a, t2.c FROM prt2_adv t1 LEFT JOIN prt1_adv t2 ON (t1.b = t2.a) WHERE t1.a = 0 ORDER BY t1.b, t2.a;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM prt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- anti join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt2_adv t1 WHERE NOT EXISTS (SELECT 1 FROM prt1_adv t2 WHERE t1.b = t2.a) AND t1.a = 0 ORDER BY t1.b;
---END---
---START---
-- full join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT 175 phv, * FROM prt1_adv WHERE prt1_adv.b = 0) t1 FULL JOIN (SELECT 425 phv, * FROM prt2_adv WHERE prt2_adv.a = 0) t2 ON (t1.a = t2.b) WHERE t1.phv = t1.a OR t2.phv = t2.b ORDER BY t1.a, t2.b;
---END---
---START---
-- 3-way join where not every pair of relations can do partitioned join
EXPLAIN (COSTS OFF)
SELECT t1.b, t1.c, t2.a, t2.c, t3.a, t3.c FROM prt2_adv t1 LEFT JOIN prt1_adv t2 ON (t1.b = t2.a) INNER JOIN prt1_adv t3 ON (t1.b = t3.a) WHERE t1.a = 0 ORDER BY t1.b, t2.a, t3.a;
---END---
---START---
SELECT t1.b, t1.c, t2.a, t2.c, t3.a, t3.c FROM prt2_adv t1 LEFT JOIN prt1_adv t2 ON (t1.b = t2.a) INNER JOIN prt1_adv t3 ON (t1.b = t3.a) WHERE t1.a = 0 ORDER BY t1.b, t2.a, t3.a;
---END---
---START---
DROP TABLE prt2_adv_extra;
---END---
---START---
-- Test cases where a partition on one side matches multiple partitions on
-- the other side; we currently can't do partitioned join in such cases
ALTER TABLE prt2_adv DETACH PARTITION prt2_adv_p3;
---END---
---START---
-- Split prt2_adv_p3 into two partitions so that prt1_adv_p3 matches both
CREATE TABLE prt2_adv_p3_1 PARTITION OF prt2_adv FOR VALUES FROM (350) TO (375);
---END---
---START---
CREATE TABLE prt2_adv_p3_2 PARTITION OF prt2_adv FOR VALUES FROM (375) TO (500);
---END---
---START---
INSERT INTO prt2_adv SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(350, 499) i;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1_adv t1 WHERE EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM prt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM prt2_adv t2 WHERE t1.a = t2.b) AND t1.b = 0 ORDER BY t1.a;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM (SELECT 175 phv, * FROM prt1_adv WHERE prt1_adv.b = 0) t1 FULL JOIN (SELECT 425 phv, * FROM prt2_adv WHERE prt2_adv.a = 0) t2 ON (t1.a = t2.b) WHERE t1.phv = t1.a OR t2.phv = t2.b ORDER BY t1.a, t2.b;
---END---
---START---
DROP TABLE prt2_adv_p3_1;
---END---
---START---
DROP TABLE prt2_adv_p3_2;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
-- Test default partitions
ALTER TABLE prt1_adv DETACH PARTITION prt1_adv_p1;
---END---
---START---
-- Change prt1_adv_p1 to the default partition
ALTER TABLE prt1_adv ATTACH PARTITION prt1_adv_p1 DEFAULT;
---END---
---START---
ALTER TABLE prt1_adv DETACH PARTITION prt1_adv_p3;
---END---
---START---
ANALYZE prt1_adv;
---END---
---START---
-- We can do partitioned join even if only one of relations has the default
-- partition
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
-- Restore prt1_adv_p3
ALTER TABLE prt1_adv ATTACH PARTITION prt1_adv_p3 FOR VALUES FROM (300) TO (400);
---END---
---START---
ANALYZE prt1_adv;
---END---
---START---
-- Restore prt2_adv_p3
ALTER TABLE prt2_adv ATTACH PARTITION prt2_adv_p3 FOR VALUES FROM (350) TO (500);
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
-- Partitioned join can't be applied because the default partition of prt1_adv
-- matches prt2_adv_p1 and prt2_adv_p3
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
ALTER TABLE prt2_adv DETACH PARTITION prt2_adv_p3;
---END---
---START---
-- Change prt2_adv_p3 to the default partition
ALTER TABLE prt2_adv ATTACH PARTITION prt2_adv_p3 DEFAULT;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
-- Partitioned join can't be applied because the default partition of prt1_adv
-- matches prt2_adv_p1 and prt2_adv_p3
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
DROP TABLE prt1_adv_p3;
---END---
---START---
ANALYZE prt1_adv;
---END---
---START---
DROP TABLE prt2_adv_p3;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
CREATE TABLE prt3_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt3_adv_p1 PARTITION OF prt3_adv FOR VALUES FROM (200) TO (300);
---END---
---START---
CREATE TABLE prt3_adv_p2 PARTITION OF prt3_adv FOR VALUES FROM (300) TO (400);
---END---
---START---
CREATE INDEX prt3_adv_a_idx ON prt3_adv (a);
---END---
---START---
INSERT INTO prt3_adv SELECT i, i % 25, to_char(i, 'FM0000') FROM generate_series(200, 399) i;
---END---
---START---
ANALYZE prt3_adv;
---END---
---START---
-- 3-way join to test the default partition of a join relation
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c, t3.a, t3.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) LEFT JOIN prt3_adv t3 ON (t1.a = t3.a) WHERE t1.b = 0 ORDER BY t1.a, t2.b, t3.a;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c, t3.a, t3.c FROM prt1_adv t1 LEFT JOIN prt2_adv t2 ON (t1.a = t2.b) LEFT JOIN prt3_adv t3 ON (t1.a = t3.a) WHERE t1.b = 0 ORDER BY t1.a, t2.b, t3.a;
---END---
---START---
DROP TABLE prt1_adv;
---END---
---START---
DROP TABLE prt2_adv;
---END---
---START---
DROP TABLE prt3_adv;
---END---
---START---
CREATE TABLE prt1_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (a);
---END---
---START---
CREATE TABLE prt1_adv_p1 PARTITION OF prt1_adv FOR VALUES FROM (100) TO (200);
---END---
---START---
CREATE TABLE prt1_adv_p2 PARTITION OF prt1_adv FOR VALUES FROM (200) TO (300);
---END---
---START---
CREATE TABLE prt1_adv_p3 PARTITION OF prt1_adv FOR VALUES FROM (300) TO (400);
---END---
---START---
CREATE INDEX prt1_adv_a_idx ON prt1_adv (a);
---END---
---START---
INSERT INTO prt1_adv SELECT i, i % 25, to_char(i, 'FM0000') FROM generate_series(100, 399) i;
---END---
---START---
ANALYZE prt1_adv;
---END---
---START---
CREATE TABLE prt2_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar) PARTITION BY range (b);
---END---
---START---
CREATE TABLE prt2_adv_p1 PARTITION OF prt2_adv FOR VALUES FROM (100) TO (200);
---END---
---START---
CREATE TABLE prt2_adv_p2 PARTITION OF prt2_adv FOR VALUES FROM (200) TO (400);
---END---
---START---
CREATE INDEX prt2_adv_b_idx ON prt2_adv (b);
---END---
---START---
INSERT INTO prt2_adv SELECT i % 25, i, to_char(i, 'FM0000') FROM generate_series(100, 399) i;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.a < 300 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.a < 300 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
DROP TABLE prt1_adv_p3;
---END---
---START---
CREATE TABLE prt1_adv_default PARTITION OF prt1_adv DEFAULT;
---END---
---START---
ANALYZE prt1_adv;
---END---
---START---
CREATE TABLE prt2_adv_default PARTITION OF prt2_adv DEFAULT;
---END---
---START---
ANALYZE prt2_adv;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.a >= 100 AND t1.a < 300 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
SELECT t1.a, t1.c, t2.b, t2.c FROM prt1_adv t1 INNER JOIN prt2_adv t2 ON (t1.a = t2.b) WHERE t1.a >= 100 AND t1.a < 300 AND t1.b = 0 ORDER BY t1.a, t2.b;
---END---
---START---
DROP TABLE prt1_adv;
---END---
---START---
DROP TABLE prt2_adv;
---END---
---START---
CREATE TABLE plt1_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt1_adv_p1 PARTITION OF plt1_adv FOR VALUES IN ('0001', '0003');
---END---
---START---
CREATE TABLE plt1_adv_p2 PARTITION OF plt1_adv FOR VALUES IN ('0004', '0006');
---END---
---START---
CREATE TABLE plt1_adv_p3 PARTITION OF plt1_adv FOR VALUES IN ('0008', '0009');
---END---
---START---
INSERT INTO plt1_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (1, 3, 4, 6, 8, 9);
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
CREATE TABLE plt2_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt2_adv_p1 PARTITION OF plt2_adv FOR VALUES IN ('0002', '0003');
---END---
---START---
CREATE TABLE plt2_adv_p2 PARTITION OF plt2_adv FOR VALUES IN ('0004', '0006');
---END---
---START---
CREATE TABLE plt2_adv_p3 PARTITION OF plt2_adv FOR VALUES IN ('0007', '0009');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
-- Test cases where one side has an extra partition
CREATE TABLE plt2_adv_extra PARTITION OF plt2_adv FOR VALUES IN ('0000');
---END---
---START---
INSERT INTO plt2_adv_extra VALUES (0, 0, '0000');
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt2_adv t1 LEFT JOIN plt1_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- anti join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt2_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt1_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- full join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
DROP TABLE plt2_adv_extra;
---END---
---START---
-- Test cases where a partition on one side matches multiple partitions on
-- the other side; we currently can't do partitioned join in such cases
ALTER TABLE plt2_adv DETACH PARTITION plt2_adv_p2;
---END---
---START---
-- Split plt2_adv_p2 into two partitions so that plt1_adv_p2 matches both
CREATE TABLE plt2_adv_p2_1 PARTITION OF plt2_adv FOR VALUES IN ('0004');
---END---
---START---
CREATE TABLE plt2_adv_p2_2 PARTITION OF plt2_adv FOR VALUES IN ('0006');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (4, 6);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
DROP TABLE plt2_adv_p2_1;
---END---
---START---
DROP TABLE plt2_adv_p2_2;
---END---
---START---
-- Restore plt2_adv_p2
ALTER TABLE plt2_adv ATTACH PARTITION plt2_adv_p2 FOR VALUES IN ('0004', '0006');
---END---
---START---
-- Test NULL partitions
ALTER TABLE plt1_adv DETACH PARTITION plt1_adv_p1;
---END---
---START---
-- Change plt1_adv_p1 to the NULL partition
CREATE TABLE plt1_adv_p1_null PARTITION OF plt1_adv FOR VALUES IN (NULL, '0001', '0003');
---END---
---START---
INSERT INTO plt1_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (1, 3);
---END---
---START---
INSERT INTO plt1_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
ALTER TABLE plt2_adv DETACH PARTITION plt2_adv_p3;
---END---
---START---
-- Change plt2_adv_p3 to the NULL partition
CREATE TABLE plt2_adv_p3_null PARTITION OF plt2_adv FOR VALUES IN (NULL, '0007', '0009');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (7, 9);
---END---
---START---
INSERT INTO plt2_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- semi join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM plt1_adv t1 WHERE EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- anti join
EXPLAIN (COSTS OFF)
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.* FROM plt1_adv t1 WHERE NOT EXISTS (SELECT 1 FROM plt2_adv t2 WHERE t1.a = t2.a AND t1.c = t2.c) AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
DROP TABLE plt1_adv_p1_null;
---END---
---START---
-- Restore plt1_adv_p1
ALTER TABLE plt1_adv ATTACH PARTITION plt1_adv_p1 FOR VALUES IN ('0001', '0003');
---END---
---START---
-- Add to plt1_adv the extra NULL partition containing only NULL values as the
-- key values
CREATE TABLE plt1_adv_extra PARTITION OF plt1_adv FOR VALUES IN (NULL);
---END---
---START---
INSERT INTO plt1_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
DROP TABLE plt2_adv_p3_null;
---END---
---START---
-- Restore plt2_adv_p3
ALTER TABLE plt2_adv ATTACH PARTITION plt2_adv_p3 FOR VALUES IN ('0007', '0009');
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- full join; currently we can't do partitioned join if there are no matched
-- partitions on the nullable side
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
-- Add to plt2_adv the extra NULL partition containing only NULL values as the
-- key values
CREATE TABLE plt2_adv_extra PARTITION OF plt2_adv FOR VALUES IN (NULL);
---END---
---START---
INSERT INTO plt2_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- inner join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- left join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- full join
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 FULL JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE coalesce(t1.b, 0) < 10 AND coalesce(t2.b, 0) < 10 ORDER BY t1.a, t2.a;
---END---
---START---
-- 3-way join to test the NULL partition of a join relation
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c, t3.a, t3.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) LEFT JOIN plt1_adv t3 ON (t1.a = t3.a AND t1.c = t3.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c, t3.a, t3.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) LEFT JOIN plt1_adv t3 ON (t1.a = t3.a AND t1.c = t3.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
DROP TABLE plt1_adv_extra;
---END---
---START---
DROP TABLE plt2_adv_extra;
---END---
---START---
-- Test default partitions
ALTER TABLE plt1_adv DETACH PARTITION plt1_adv_p1;
---END---
---START---
-- Change plt1_adv_p1 to the default partition
ALTER TABLE plt1_adv ATTACH PARTITION plt1_adv_p1 DEFAULT;
---END---
---START---
DROP TABLE plt1_adv_p3;
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
DROP TABLE plt2_adv_p3;
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- We can do partitioned join even if only one of relations has the default
-- partition
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
ALTER TABLE plt2_adv DETACH PARTITION plt2_adv_p2;
---END---
---START---
-- Change plt2_adv_p2 to contain '0005' in addition to '0004' and '0006' as
-- the key values
CREATE TABLE plt2_adv_p2_ext PARTITION OF plt2_adv FOR VALUES IN ('0004', '0005', '0006');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (4, 5, 6);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- Partitioned join can't be applied because the default partition of plt1_adv
-- matches plt2_adv_p1 and plt2_adv_p2_ext
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
ALTER TABLE plt2_adv DETACH PARTITION plt2_adv_p2_ext;
---END---
---START---
-- Change plt2_adv_p2_ext to the default partition
ALTER TABLE plt2_adv ATTACH PARTITION plt2_adv_p2_ext DEFAULT;
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
-- Partitioned join can't be applied because the default partition of plt1_adv
-- matches plt2_adv_p1 and plt2_adv_p2_ext
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
DROP TABLE plt2_adv_p2_ext;
---END---
---START---
-- Restore plt2_adv_p2
ALTER TABLE plt2_adv ATTACH PARTITION plt2_adv_p2 FOR VALUES IN ('0004', '0006');
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
CREATE TABLE plt3_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt3_adv_p1 PARTITION OF plt3_adv FOR VALUES IN ('0004', '0006');
---END---
---START---
CREATE TABLE plt3_adv_p2 PARTITION OF plt3_adv FOR VALUES IN ('0007', '0009');
---END---
---START---
INSERT INTO plt3_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (4, 6, 7, 9);
---END---
---START---
ANALYZE plt3_adv;
---END---
---START---
-- 3-way join to test the default partition of a join relation
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c, t3.a, t3.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) LEFT JOIN plt3_adv t3 ON (t1.a = t3.a AND t1.c = t3.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c, t3.a, t3.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) LEFT JOIN plt3_adv t3 ON (t1.a = t3.a AND t1.c = t3.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
-- Test cases where one side has the default partition while the other side
-- has the NULL partition
DROP TABLE plt2_adv_p1;
---END---
---START---
-- Add the NULL partition to plt2_adv
CREATE TABLE plt2_adv_p1_null PARTITION OF plt2_adv FOR VALUES IN (NULL, '0001', '0003');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (1, 3);
---END---
---START---
INSERT INTO plt2_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
DROP TABLE plt2_adv_p1_null;
---END---
---START---
-- Add the NULL partition that contains only NULL values as the key values
CREATE TABLE plt2_adv_p1_null PARTITION OF plt2_adv FOR VALUES IN (NULL);
---END---
---START---
INSERT INTO plt2_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.b < 10 ORDER BY t1.a;
---END---
---START---
DROP TABLE plt1_adv;
---END---
---START---
DROP TABLE plt2_adv;
---END---
---START---
DROP TABLE plt3_adv;
---END---
---START---
CREATE TABLE plt1_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt1_adv_p1 PARTITION OF plt1_adv FOR VALUES IN ('0001');
---END---
---START---
CREATE TABLE plt1_adv_p2 PARTITION OF plt1_adv FOR VALUES IN ('0002');
---END---
---START---
CREATE TABLE plt1_adv_p3 PARTITION OF plt1_adv FOR VALUES IN ('0003');
---END---
---START---
CREATE TABLE plt1_adv_p4 PARTITION OF plt1_adv FOR VALUES IN (NULL, '0004', '0005');
---END---
---START---
INSERT INTO plt1_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (1, 2, 3, 4, 5);
---END---
---START---
INSERT INTO plt1_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
CREATE TABLE plt2_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt2_adv_p1 PARTITION OF plt2_adv FOR VALUES IN ('0001', '0002');
---END---
---START---
CREATE TABLE plt2_adv_p2 PARTITION OF plt2_adv FOR VALUES IN (NULL);
---END---
---START---
CREATE TABLE plt2_adv_p3 PARTITION OF plt2_adv FOR VALUES IN ('0003');
---END---
---START---
CREATE TABLE plt2_adv_p4 PARTITION OF plt2_adv FOR VALUES IN ('0004', '0005');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 10, 'FM0000') FROM generate_series(1, 299) i WHERE i % 10 IN (1, 2, 3, 4, 5);
---END---
---START---
INSERT INTO plt2_adv VALUES (-1, -1, NULL);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IN ('0003', '0004', '0005') AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IN ('0003', '0004', '0005') AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IS NULL AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IS NULL AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
CREATE TABLE plt1_adv_default PARTITION OF plt1_adv DEFAULT;
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
CREATE TABLE plt2_adv_default PARTITION OF plt2_adv DEFAULT;
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IN ('0003', '0004', '0005') AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 INNER JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IN ('0003', '0004', '0005') AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IS NULL AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c FROM plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE t1.c IS NULL AND t1.b < 10 ORDER BY t1.a;
---END---
---START---
DROP TABLE plt1_adv;
---END---
---START---
DROP TABLE plt2_adv;
---END---
---START---
CREATE TABLE plt1_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt1_adv_p1 PARTITION OF plt1_adv FOR VALUES IN ('0000', '0001', '0002');
---END---
---START---
CREATE TABLE plt1_adv_p2 PARTITION OF plt1_adv FOR VALUES IN ('0003', '0004');
---END---
---START---
INSERT INTO plt1_adv SELECT i, i, to_char(i % 5, 'FM0000') FROM generate_series(0, 24) i;
---END---
---START---
ANALYZE plt1_adv;
---END---
---START---
CREATE TABLE plt2_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt2_adv_p1 PARTITION OF plt2_adv FOR VALUES IN ('0002');
---END---
---START---
CREATE TABLE plt2_adv_p2 PARTITION OF plt2_adv FOR VALUES IN ('0003', '0004');
---END---
---START---
INSERT INTO plt2_adv SELECT i, i, to_char(i % 5, 'FM0000') FROM generate_series(0, 24) i WHERE i % 5 IN (2, 3, 4);
---END---
---START---
ANALYZE plt2_adv;
---END---
---START---
CREATE TABLE plt3_adv (_gemini_pk serial PRIMARY KEY, a integer, b integer, c text) PARTITION BY list (c);
---END---
---START---
CREATE TABLE plt3_adv_p1 PARTITION OF plt3_adv FOR VALUES IN ('0001');
---END---
---START---
CREATE TABLE plt3_adv_p2 PARTITION OF plt3_adv FOR VALUES IN ('0003', '0004');
---END---
---START---
INSERT INTO plt3_adv SELECT i, i, to_char(i % 5, 'FM0000') FROM generate_series(0, 24) i WHERE i % 5 IN (1, 3, 4);
---END---
---START---
ANALYZE plt3_adv;
---END---
---START---
-- This tests that when merging partitions from plt1_adv and plt2_adv in
-- merge_list_bounds(), process_outer_partition() returns an already-assigned
-- merged partition when re-called with plt1_adv_p1 for the second list value
-- '0001' of that partition
EXPLAIN (COSTS OFF)
SELECT t1.a, t1.c, t2.a, t2.c, t3.a, t3.c FROM (plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.c = t2.c)) FULL JOIN plt3_adv t3 ON (t1.c = t3.c) WHERE coalesce(t1.a, 0) % 5 != 3 AND coalesce(t1.a, 0) % 5 != 4 ORDER BY t1.c, t1.a, t2.a, t3.a;
---END---
---START---
SELECT t1.a, t1.c, t2.a, t2.c, t3.a, t3.c FROM (plt1_adv t1 LEFT JOIN plt2_adv t2 ON (t1.c = t2.c)) FULL JOIN plt3_adv t3 ON (t1.c = t3.c) WHERE coalesce(t1.a, 0) % 5 != 3 AND coalesce(t1.a, 0) % 5 != 4 ORDER BY t1.c, t1.a, t2.a, t3.a;
---END---
---START---
DROP TABLE plt1_adv;
---END---
---START---
DROP TABLE plt2_adv;
---END---
---START---
DROP TABLE plt3_adv;
---END---
---START---
CREATE TABLE alpha (_gemini_pk serial PRIMARY KEY, a double precision, b integer, c text) PARTITION BY range (a);
---END---
---START---
CREATE TABLE alpha_neg PARTITION OF alpha FOR VALUES FROM ('-Infinity') TO (0) PARTITION BY RANGE (b);
---END---
---START---
CREATE TABLE alpha_pos PARTITION OF alpha FOR VALUES FROM (0) TO (10.0) PARTITION BY LIST (c);
---END---
---START---
CREATE TABLE alpha_neg_p1 PARTITION OF alpha_neg FOR VALUES FROM (100) TO (200);
---END---
---START---
CREATE TABLE alpha_neg_p2 PARTITION OF alpha_neg FOR VALUES FROM (200) TO (300);
---END---
---START---
CREATE TABLE alpha_neg_p3 PARTITION OF alpha_neg FOR VALUES FROM (300) TO (400);
---END---
---START---
CREATE TABLE alpha_pos_p1 PARTITION OF alpha_pos FOR VALUES IN ('0001', '0003');
---END---
---START---
CREATE TABLE alpha_pos_p2 PARTITION OF alpha_pos FOR VALUES IN ('0004', '0006');
---END---
---START---
CREATE TABLE alpha_pos_p3 PARTITION OF alpha_pos FOR VALUES IN ('0008', '0009');
---END---
---START---
INSERT INTO alpha_neg SELECT -1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(100, 399) i WHERE i % 10 IN (1, 3, 4, 6, 8, 9);
---END---
---START---
INSERT INTO alpha_pos SELECT  1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(100, 399) i WHERE i % 10 IN (1, 3, 4, 6, 8, 9);
---END---
---START---
ANALYZE alpha;
---END---
---START---
CREATE TABLE beta (_gemini_pk serial PRIMARY KEY, a double precision, b integer, c text) PARTITION BY range (a);
---END---
---START---
CREATE TABLE beta_neg PARTITION OF beta FOR VALUES FROM (-10.0) TO (0) PARTITION BY RANGE (b);
---END---
---START---
CREATE TABLE beta_pos PARTITION OF beta FOR VALUES FROM (0) TO ('Infinity') PARTITION BY LIST (c);
---END---
---START---
CREATE TABLE beta_neg_p1 PARTITION OF beta_neg FOR VALUES FROM (100) TO (150);
---END---
---START---
CREATE TABLE beta_neg_p2 PARTITION OF beta_neg FOR VALUES FROM (200) TO (300);
---END---
---START---
CREATE TABLE beta_neg_p3 PARTITION OF beta_neg FOR VALUES FROM (350) TO (500);
---END---
---START---
CREATE TABLE beta_pos_p1 PARTITION OF beta_pos FOR VALUES IN ('0002', '0003');
---END---
---START---
CREATE TABLE beta_pos_p2 PARTITION OF beta_pos FOR VALUES IN ('0004', '0006');
---END---
---START---
CREATE TABLE beta_pos_p3 PARTITION OF beta_pos FOR VALUES IN ('0007', '0009');
---END---
---START---
INSERT INTO beta_neg SELECT -1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(100, 149) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
INSERT INTO beta_neg SELECT -1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(200, 299) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
INSERT INTO beta_neg SELECT -1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(350, 499) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
INSERT INTO beta_pos SELECT  1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(100, 149) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
INSERT INTO beta_pos SELECT  1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(200, 299) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
INSERT INTO beta_pos SELECT  1.0, i, to_char(i % 10, 'FM0000') FROM generate_series(350, 499) i WHERE i % 10 IN (2, 3, 4, 6, 7, 9);
---END---
---START---
ANALYZE beta;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.*, t2.* FROM alpha t1 INNER JOIN beta t2 ON (t1.a = t2.a AND t1.b = t2.b) WHERE t1.b >= 125 AND t1.b < 225 ORDER BY t1.a, t1.b;
---END---
---START---
SELECT t1.*, t2.* FROM alpha t1 INNER JOIN beta t2 ON (t1.a = t2.a AND t1.b = t2.b) WHERE t1.b >= 125 AND t1.b < 225 ORDER BY t1.a, t1.b;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.*, t2.* FROM alpha t1 INNER JOIN beta t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE ((t1.b >= 100 AND t1.b < 110) OR (t1.b >= 200 AND t1.b < 210)) AND ((t2.b >= 100 AND t2.b < 110) OR (t2.b >= 200 AND t2.b < 210)) AND t1.c IN ('0004', '0009') ORDER BY t1.a, t1.b, t2.b;
---END---
---START---
SELECT t1.*, t2.* FROM alpha t1 INNER JOIN beta t2 ON (t1.a = t2.a AND t1.c = t2.c) WHERE ((t1.b >= 100 AND t1.b < 110) OR (t1.b >= 200 AND t1.b < 210)) AND ((t2.b >= 100 AND t2.b < 110) OR (t2.b >= 200 AND t2.b < 210)) AND t1.c IN ('0004', '0009') ORDER BY t1.a, t1.b, t2.b;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT t1.*, t2.* FROM alpha t1 INNER JOIN beta t2 ON (t1.a = t2.a AND t1.b = t2.b AND t1.c = t2.c) WHERE ((t1.b >= 100 AND t1.b < 110) OR (t1.b >= 200 AND t1.b < 210)) AND ((t2.b >= 100 AND t2.b < 110) OR (t2.b >= 200 AND t2.b < 210)) AND t1.c IN ('0004', '0009') ORDER BY t1.a, t1.b;
---END---
---START---
SELECT t1.*, t2.* FROM alpha t1 INNER JOIN beta t2 ON (t1.a = t2.a AND t1.b = t2.b AND t1.c = t2.c) WHERE ((t1.b >= 100 AND t1.b < 110) OR (t1.b >= 200 AND t1.b < 210)) AND ((t2.b >= 100 AND t2.b < 110) OR (t2.b >= 200 AND t2.b < 210)) AND t1.c IN ('0004', '0009') ORDER BY t1.a, t1.b;
---END---
---START---
-- partitionwise join with fractional paths
CREATE TABLE fract_t (id BIGINT, PRIMARY KEY (id)) PARTITION BY RANGE (id);
---END---
---START---
CREATE TABLE fract_t0 PARTITION OF fract_t FOR VALUES FROM ('0') TO ('1000');
---END---
---START---
CREATE TABLE fract_t1 PARTITION OF fract_t FOR VALUES FROM ('1000') TO ('2000');
---END---
---START---
-- insert data
INSERT INTO fract_t (id) (SELECT generate_series(0, 1999));
---END---
---START---
ANALYZE fract_t;
---END---
---START---
-- verify plan; nested index only scans
SET max_parallel_workers_per_gather = 0;
---END---
---START---
SET enable_partitionwise_join = on;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT x.id, y.id FROM fract_t x LEFT JOIN fract_t y USING (id) ORDER BY x.id ASC LIMIT 10;
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT x.id, y.id FROM fract_t x LEFT JOIN fract_t y USING (id) ORDER BY x.id DESC LIMIT 10;
---END---
---START---
-- cleanup
DROP TABLE fract_t;
---END---
---START---
RESET max_parallel_workers_per_gather;
---END---
---START---
RESET enable_partitionwise_join;
---END---
