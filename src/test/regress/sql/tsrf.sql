---START---
--
-- tsrf - targetlist set returning function tests
--

-- simple srf
SELECT generate_series(1, 3);
---END---
---START---
-- parallel iteration
SELECT generate_series(1, 3), generate_series(3,5);
---END---
---START---
-- parallel iteration, different number of rows
SELECT generate_series(1, 2), generate_series(1,4);
---END---
---START---
-- srf, with SRF argument
SELECT generate_series(1, generate_series(1, 3));
---END---
---START---
-- but we've traditionally rejected the same in FROM
SELECT * FROM generate_series(1, generate_series(1, 3));
---END---
---START---
-- srf, with two SRF arguments
SELECT generate_series(generate_series(1,3), generate_series(2, 4));
---END---
---START---
-- check proper nesting of SRFs in different expressions
explain (verbose, costs off)
SELECT generate_series(1, generate_series(1, 3)), generate_series(2, 4);
---END---
---START---
SELECT generate_series(1, generate_series(1, 3)), generate_series(2, 4);
---END---
---START---
CREATE TABLE few (_gemini_pk serial PRIMARY KEY, id integer, dataa text, datab text);
---END---
---START---
INSERT INTO few VALUES(1, 'a', 'foo'),(2, 'a', 'bar'),(3, 'b', 'bar');
---END---
---START---
-- SRF with a provably-dummy relation
explain (verbose, costs off)
SELECT unnest(ARRAY[1, 2]) FROM few WHERE false;
---END---
---START---
SELECT unnest(ARRAY[1, 2]) FROM few WHERE false;
---END---
---START---
-- SRF shouldn't prevent upper query from recognizing lower as dummy
explain (verbose, costs off)
SELECT * FROM few f1,
  (SELECT unnest(ARRAY[1,2]) FROM few f2 WHERE false OFFSET 0) ss;
---END---
---START---
SELECT * FROM few f1,
  (SELECT unnest(ARRAY[1,2]) FROM few f2 WHERE false OFFSET 0) ss;
---END---
---START---
-- SRF output order of sorting is maintained, if SRF is not referenced
SELECT few.id, generate_series(1,3) g FROM few ORDER BY id DESC;
---END---
---START---
-- but SRFs can be referenced in sort
SELECT few.id, generate_series(1,3) g FROM few ORDER BY id, g DESC;
---END---
---START---
SELECT few.id, generate_series(1,3) g FROM few ORDER BY id, generate_series(1,3) DESC;
---END---
---START---
-- it's weird to have ORDER BYs that increase the number of results
SELECT few.id FROM few ORDER BY id, generate_series(1,3) DESC;
---END---
---START---
-- SRFs are computed after aggregation
SET enable_hashagg TO 0;
---END---
---START---
-- stable output order
SELECT few.dataa, count(*), min(id), max(id), unnest('{1,1,3}'::int[]) FROM few WHERE few.id = 1 GROUP BY few.dataa;
---END---
---START---
-- unless referenced in GROUP BY clause
SELECT few.dataa, count(*), min(id), max(id), unnest('{1,1,3}'::int[]) FROM few WHERE few.id = 1 GROUP BY few.dataa, unnest('{1,1,3}'::int[]);
---END---
---START---
SELECT few.dataa, count(*), min(id), max(id), unnest('{1,1,3}'::int[]) FROM few WHERE few.id = 1 GROUP BY few.dataa, 5;
---END---
---START---
RESET enable_hashagg;
---END---
---START---
-- check HAVING works when GROUP BY does [not] reference SRF output
SELECT dataa, generate_series(1,1), count(*) FROM few GROUP BY 1 HAVING count(*) > 1;
---END---
---START---
SELECT dataa, generate_series(1,1), count(*) FROM few GROUP BY 1, 2 HAVING count(*) > 1;
---END---
---START---
-- it's weird to have GROUP BYs that increase the number of results
SELECT few.dataa, count(*) FROM few WHERE dataa = 'a' GROUP BY few.dataa ORDER BY 2;
---END---
---START---
SELECT few.dataa, count(*) FROM few WHERE dataa = 'a' GROUP BY few.dataa, unnest('{1,1,3}'::int[]) ORDER BY 2;
---END---
---START---
-- SRFs are not allowed if they'd need to be conditionally executed
SELECT q1, case when q1 > 0 then generate_series(1,3) else 0 end FROM int8_tbl;
---END---
---START---
SELECT q1, coalesce(generate_series(1,3), 0) FROM int8_tbl;
---END---
---START---
-- SRFs are not allowed in aggregate arguments
SELECT min(generate_series(1, 3)) FROM few;
---END---
---START---
-- ... unless they're within a sub-select
SELECT sum((3 = ANY(SELECT generate_series(1,4)))::int);
---END---
---START---
SELECT sum((3 = ANY(SELECT lag(x) over(order by x)
                    FROM generate_series(1,4) x))::int);
---END---
---START---
-- SRFs are not allowed in window function arguments, either
SELECT min(generate_series(1, 3)) OVER() FROM few;
---END---
---START---
-- SRFs are normally computed after window functions
SELECT id,lag(id) OVER(), count(*) OVER(), generate_series(1,3) FROM few;
---END---
---START---
-- unless referencing SRFs
SELECT SUM(count(*)) OVER(PARTITION BY generate_series(1,3) ORDER BY generate_series(1,3)), generate_series(1,3) g FROM few GROUP BY g;
---END---
---START---
-- sorting + grouping
SELECT few.dataa, count(*), min(id), max(id), generate_series(1,3) FROM few GROUP BY few.dataa ORDER BY 5, 1;
---END---
---START---
-- grouping sets are a bit special, they produce NULLs in columns not actually NULL
set enable_hashagg = false;
---END---
---START---
SELECT dataa, datab b, generate_series(1,2) g, count(*) FROM few GROUP BY CUBE(dataa, datab);
---END---
---START---
SELECT dataa, datab b, generate_series(1,2) g, count(*) FROM few GROUP BY CUBE(dataa, datab) ORDER BY dataa;
---END---
---START---
SELECT dataa, datab b, generate_series(1,2) g, count(*) FROM few GROUP BY CUBE(dataa, datab) ORDER BY g;
---END---
---START---
SELECT dataa, datab b, generate_series(1,2) g, count(*) FROM few GROUP BY CUBE(dataa, datab, g);
---END---
---START---
SELECT dataa, datab b, generate_series(1,2) g, count(*) FROM few GROUP BY CUBE(dataa, datab, g) ORDER BY dataa;
---END---
---START---
SELECT dataa, datab b, generate_series(1,2) g, count(*) FROM few GROUP BY CUBE(dataa, datab, g) ORDER BY g;
---END---
---START---
reset enable_hashagg;
---END---
---START---
-- case with degenerate ORDER BY
explain (verbose, costs off)
select 'foo' as f, generate_series(1,2) as g from few order by 1;
---END---
---START---
select 'foo' as f, generate_series(1,2) as g from few order by 1;
---END---
---START---
-- data modification
CREATE TABLE fewmore AS SELECT generate_series(1,3) AS data;
---END---
---START---
INSERT INTO fewmore VALUES(generate_series(4,5));
---END---
---START---
SELECT * FROM fewmore;
---END---
---START---
-- SRFs are not allowed in UPDATE (they once were, but it was nonsense)
UPDATE fewmore SET data = generate_series(4,9);
---END---
---START---
-- SRFs are not allowed in RETURNING
INSERT INTO fewmore VALUES(1) RETURNING generate_series(1,3);
---END---
---START---
-- nor standalone VALUES (but surely this is a bug?)
VALUES(1, generate_series(1,2));
---END---
---START---
-- We allow tSRFs that are not at top level
SELECT int4mul(generate_series(1,2), 10);
---END---
---START---
SELECT generate_series(1,3) IS DISTINCT FROM 2;
---END---
---START---
-- but SRFs in function RTEs must be at top level (annoying restriction)
SELECT * FROM int4mul(generate_series(1,2), 10);
---END---
---START---
-- DISTINCT ON is evaluated before tSRF evaluation if SRF is not
-- referenced either in ORDER BY or in the DISTINCT ON list. The ORDER
-- BY reference can be implicitly generated, if there's no other ORDER BY.

-- implicit reference (via implicit ORDER) to all columns
SELECT DISTINCT ON (a) a, b, generate_series(1,3) g
FROM (VALUES (3, 2), (3,1), (1,1), (1,4), (5,3), (5,1)) AS t(a, b);
---END---
---START---
-- unreferenced in DISTINCT ON or ORDER BY
SELECT DISTINCT ON (a) a, b, generate_series(1,3) g
FROM (VALUES (3, 2), (3,1), (1,1), (1,4), (5,3), (5,1)) AS t(a, b)
ORDER BY a, b DESC;
---END---
---START---
-- referenced in ORDER BY
SELECT DISTINCT ON (a) a, b, generate_series(1,3) g
FROM (VALUES (3, 2), (3,1), (1,1), (1,4), (5,3), (5,1)) AS t(a, b)
ORDER BY a, b DESC, g DESC;
---END---
---START---
-- referenced in ORDER BY and DISTINCT ON
SELECT DISTINCT ON (a, b, g) a, b, generate_series(1,3) g
FROM (VALUES (3, 2), (3,1), (1,1), (1,4), (5,3), (5,1)) AS t(a, b)
ORDER BY a, b DESC, g DESC;
---END---
---START---
-- only SRF mentioned in DISTINCT ON
SELECT DISTINCT ON (g) a, b, generate_series(1,3) g
FROM (VALUES (3, 2), (3,1), (1,1), (1,4), (5,3), (5,1)) AS t(a, b);
---END---
---START---
-- LIMIT / OFFSET is evaluated after SRF evaluation
SELECT a, generate_series(1,2) FROM (VALUES(1),(2),(3)) r(a) LIMIT 2 OFFSET 2;
---END---
---START---
-- SRFs are not allowed in LIMIT.
SELECT 1 LIMIT generate_series(1,3);
---END---
---START---
-- tSRF in correlated subquery, referencing table outside
SELECT (SELECT generate_series(1,3) LIMIT 1 OFFSET few.id) FROM few;
---END---
---START---
-- tSRF in correlated subquery, referencing SRF outside
SELECT (SELECT generate_series(1,3) LIMIT 1 OFFSET g.i) FROM generate_series(0,3) g(i);
---END---
---START---
-- Operators can return sets too
CREATE OPERATOR |@| (PROCEDURE = unnest, RIGHTARG = ANYARRAY);
---END---
---START---
SELECT |@|ARRAY[1,2,3];
---END---
---START---
-- Some fun cases involving duplicate SRF calls
explain (verbose, costs off)
select generate_series(1,3) as x, generate_series(1,3) + 1 as xp1;
---END---
---START---
select generate_series(1,3) as x, generate_series(1,3) + 1 as xp1;
---END---
---START---
explain (verbose, costs off)
select generate_series(1,3)+1 order by generate_series(1,3);
---END---
---START---
select generate_series(1,3)+1 order by generate_series(1,3);
---END---
---START---
-- Check that SRFs of same nesting level run in lockstep
explain (verbose, costs off)
select generate_series(1,3) as x, generate_series(3,6) + 1 as y;
---END---
---START---
select generate_series(1,3) as x, generate_series(3,6) + 1 as y;
---END---
---START---
-- Clean up
DROP TABLE few;
---END---
---START---
DROP TABLE fewmore;
---END---
