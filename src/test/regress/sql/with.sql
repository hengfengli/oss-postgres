---START---
--
-- Tests for common table expressions (WITH query, ... SELECT ...)
--

-- Basic WITH
WITH q1(x,y) AS (SELECT 1,2)
SELECT * FROM q1, q1 AS q2;
---END---
---START---
-- Multiple uses are evaluated only once
SELECT count(*) FROM (
  WITH q1(x) AS (SELECT random() FROM generate_series(1, 5))
    SELECT * FROM q1
  UNION
    SELECT * FROM q1
) ss;
---END---
---START---
-- WITH RECURSIVE

-- sum of 1..100
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;
---END---
---START---
WITH RECURSIVE t(n) AS (
    SELECT (VALUES(1))
UNION ALL
    SELECT n+1 FROM t WHERE n < 5
)
SELECT * FROM t;
---END---
---START---
-- UNION DISTINCT requires hashable type
WITH RECURSIVE t(n) AS (
    VALUES (1::money)
UNION
    SELECT n+1::money FROM t WHERE n < 100::money
)
SELECT sum(n) FROM t;
---END---
---START---
-- recursive view
CREATE RECURSIVE VIEW nums (n) AS
    VALUES (1)
UNION ALL
    SELECT n+1 FROM nums WHERE n < 5;
---END---
---START---
SELECT * FROM nums;
---END---
---START---
CREATE OR REPLACE RECURSIVE VIEW nums (n) AS
    VALUES (1)
UNION ALL
    SELECT n+1 FROM nums WHERE n < 6;
---END---
---START---
SELECT * FROM nums;
---END---
---START---
-- This is an infinite loop with UNION ALL, but not with UNION
WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT 10-n FROM t)
SELECT * FROM t;
---END---
---START---
-- This'd be an infinite loop, but outside query reads only as much as needed
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t)
SELECT * FROM t LIMIT 10;
---END---
---START---
-- UNION case should have same property
WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT n+1 FROM t)
SELECT * FROM t LIMIT 10;
---END---
---START---
-- Test behavior with an unknown-type literal in the WITH
WITH q AS (SELECT 'foo' AS x)
SELECT x, pg_typeof(x) FROM q;
---END---
---START---
WITH RECURSIVE t(n) AS (
    SELECT 'foo'
UNION ALL
    SELECT n || ' bar' FROM t WHERE length(n) < 20
)
SELECT n, pg_typeof(n) FROM t;
---END---
---START---
-- In a perfect world, this would work and resolve the literal as int ...
-- but for now, we have to be content with resolving to text too soon.
WITH RECURSIVE t(n) AS (
    SELECT '7'
UNION ALL
    SELECT n+1 FROM t WHERE n < 10
)
SELECT n, pg_typeof(n) FROM t;
---END---
---START---
-- Deeply nested WITH caused a list-munging problem in v13
-- Detection of cross-references and self-references
WITH RECURSIVE w1(c1) AS
 (WITH w2(c2) AS
  (WITH w3(c3) AS
   (WITH w4(c4) AS
    (WITH w5(c5) AS
     (WITH RECURSIVE w6(c6) AS
      (WITH w6(c6) AS
       (WITH w8(c8) AS
        (SELECT 1)
        SELECT * FROM w8)
       SELECT * FROM w6)
      SELECT * FROM w6)
     SELECT * FROM w5)
    SELECT * FROM w4)
   SELECT * FROM w3)
  SELECT * FROM w2)
SELECT * FROM w1;
---END---
---START---
-- Detection of invalid self-references
WITH RECURSIVE outermost(x) AS (
 SELECT 1
 UNION (WITH innermost1 AS (
  SELECT 2
  UNION (WITH innermost2 AS (
   SELECT 3
   UNION (WITH innermost3 AS (
    SELECT 4
    UNION (WITH innermost4 AS (
     SELECT 5
     UNION (WITH innermost5 AS (
      SELECT 6
      UNION (WITH innermost6 AS
       (SELECT 7)
       SELECT * FROM innermost6))
      SELECT * FROM innermost5))
     SELECT * FROM innermost4))
    SELECT * FROM innermost3))
   SELECT * FROM innermost2))
  SELECT * FROM outermost
  UNION SELECT * FROM innermost1)
 )
 SELECT * FROM outermost ORDER BY 1;
---END---
---START---
--
-- Some examples with a tree
--
-- department structure represented here is as follows:
--
-- ROOT-+->A-+->B-+->C
--      |         |
--      |         +->D-+->F
--      +->E-+->G

DROP TABLE IF EXISTS department;

CREATE TABLE department (
	id INTEGER PRIMARY KEY,  -- department ID
	parent_department INTEGER REFERENCES department, -- upper department ID
	name TEXT -- department name
);
---END---
---START---
INSERT INTO department VALUES (0, NULL, 'ROOT');
---END---
---START---
INSERT INTO department VALUES (1, 0, 'A');
---END---
---START---
INSERT INTO department VALUES (2, 1, 'B');
---END---
---START---
INSERT INTO department VALUES (3, 2, 'C');
---END---
---START---
INSERT INTO department VALUES (4, 2, 'D');
---END---
---START---
INSERT INTO department VALUES (5, 0, 'E');
---END---
---START---
INSERT INTO department VALUES (6, 4, 'F');
---END---
---START---
INSERT INTO department VALUES (7, 5, 'G');
---END---
---START---
-- extract all departments under 'A'. Result should be A, B, C, D and F
WITH RECURSIVE subdepartment AS
(
	-- non recursive term
	SELECT name as root_name, * FROM department WHERE name = 'A'

	UNION ALL

	-- recursive term
	SELECT sd.root_name, d.* FROM department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;
---END---
---START---
-- extract all departments under 'A' with "level" number
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS
(
	-- non recursive term
	SELECT 1, * FROM department WHERE name = 'A'

	UNION ALL

	-- recursive term
	SELECT sd.level + 1, d.* FROM department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;
---END---
---START---
-- extract all departments under 'A' with "level" number.
-- Only shows level 2 or more
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS
(
	-- non recursive term
	SELECT 1, * FROM department WHERE name = 'A'

	UNION ALL

	-- recursive term
	SELECT sd.level + 1, d.* FROM department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment WHERE level >= 2 ORDER BY name;
---END---
---START---
-- "RECURSIVE" is ignored if the query has no self-reference
WITH RECURSIVE subdepartment AS
(
	-- note lack of recursive UNION structure
	SELECT * FROM department WHERE name = 'A'
)
SELECT * FROM subdepartment ORDER BY name;
---END---
---START---
-- inside subqueries
SELECT count(*) FROM (
    WITH RECURSIVE t(n) AS (
        SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 500
    )
    SELECT * FROM t) AS t WHERE n < (
        SELECT count(*) FROM (
            WITH RECURSIVE t(n) AS (
                   SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 100
                )
            SELECT * FROM t WHERE n < 50000
         ) AS t WHERE n < 100);
---END---
---START---
-- use same CTE twice at different subquery levels
WITH q1(x,y) AS (
    SELECT hundred, sum(ten) FROM tenk1 GROUP BY hundred
  )
SELECT count(*) FROM q1 WHERE y > (SELECT sum(y)/100 FROM q1 qsub);
---END---
---START---
-- via a VIEW
CREATE TEMPORARY VIEW vsubdepartment AS
	WITH RECURSIVE subdepartment AS
	(
		 -- non recursive term
		SELECT * FROM department WHERE name = 'A'
		UNION ALL
		-- recursive term
		SELECT d.* FROM department AS d, subdepartment AS sd
			WHERE d.parent_department = sd.id
	)
	SELECT * FROM subdepartment;
---END---
---START---
SELECT * FROM vsubdepartment ORDER BY name;
---END---
---START---
-- Check reverse listing
SELECT pg_get_viewdef('vsubdepartment'::regclass);
---END---
---START---
SELECT pg_get_viewdef('vsubdepartment'::regclass, true);
---END---
---START---
-- Another reverse-listing example
CREATE VIEW sums_1_100 AS
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;
---END---
---START---
\d+ sums_1_100

-- corner case in which sub-WITH gets initialized first
with recursive q as (
      select * from department
    union all
      (with x as (select * from q)
       select * from x)
    )
select * from q limit 24;
---END---
---START---
-- @hengfeng: this query gets stuck for cockroachdb
--with recursive q as (
--      select * from department
--    union all
--      (with recursive x as (
--           select * from department
--         union all
--           (select * from q union all select * from x)
--        )
--       select * from x)
--    )
--select * from q limit 32;
---END---
---START---
-- recursive term has sub-UNION
WITH RECURSIVE t(i,j) AS (
	VALUES (1,2)
	UNION ALL
	SELECT t2.i, t.j+1 FROM
		(SELECT 2 AS i UNION ALL SELECT 3 AS i) AS t2
		JOIN t ON (t2.i = t.i+1))

	SELECT * FROM t;
---END---
---START---
--
-- different tree example
--
DROP TABLE IF EXISTS tree;

CREATE TABLE tree(
    id INTEGER PRIMARY KEY,
    parent_id INTEGER REFERENCES tree(id)
);
---END---
---START---
INSERT INTO tree
VALUES (1, NULL), (2, 1), (3,1), (4,2), (5,2), (6,2), (7,3), (8,3),
       (9,4), (10,4), (11,7), (12,7), (13,7), (14, 9), (15,11), (16,11);
---END---
---START---
--
-- get all paths from "second level" nodes to leaf nodes
--
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tree.id, t.path || tree.id
    FROM tree JOIN t ON (tree.parent_id = t.id)
)
SELECT t1.*, t2.* FROM t AS t1 JOIN t AS t2 ON
	(t1.path[1] = t2.path[1] AND
	array_upper(t1.path,1) = 1 AND
	array_upper(t2.path,1) > 1)
	ORDER BY t1.id, t2.id;
---END---
---START---
-- just count 'em
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tree.id, t.path || tree.id
    FROM tree JOIN t ON (tree.parent_id = t.id)
)
SELECT t1.id, count(t2.*) FROM t AS t1 JOIN t AS t2 ON
	(t1.path[1] = t2.path[1] AND
	array_upper(t1.path,1) = 1 AND
	array_upper(t2.path,1) > 1)
	GROUP BY t1.id
	ORDER BY t1.id;
---END---
---START---
-- this variant tickled a whole-row-variable bug in 8.4devel
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tree.id, t.path || tree.id
    FROM tree JOIN t ON (tree.parent_id = t.id)
)
SELECT t1.id, t2.path, t2 FROM t AS t1 JOIN t AS t2 ON
(t1.id=t2.id);
---END---
---START---
-- SEARCH clause

DROP TABLE IF EXISTS graph0;

CREATE TABLE graph0 (gemini_pk serial PRIMARY KEY, f integer, t integer, label text);
---END---
---START---
insert into graph0 values
	(1, 2, 'arc 1 -> 2'),
	(1, 3, 'arc 1 -> 3'),
	(2, 3, 'arc 2 -> 3'),
	(1, 4, 'arc 1 -> 4'),
	(4, 5, 'arc 4 -> 5');
---END---
---START---
explain (verbose, costs off)
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union distinct
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
explain (verbose, costs off)
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union distinct
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
-- a constant initial value causes issues for EXPLAIN
explain (verbose, costs off)
with recursive test as (
  select 1 as x
  union all
  select x + 1
  from test
) search depth first by x set y
select * from test limit 5;
---END---
---START---
with recursive test as (
  select 1 as x
  union all
  select x + 1
  from test
) search depth first by x set y
select * from test limit 5;
---END---
---START---
explain (verbose, costs off)
with recursive test as (
  select 1 as x
  union all
  select x + 1
  from test
) search breadth first by x set y
select * from test limit 5;
---END---
---START---
with recursive test as (
  select 1 as x
  union all
  select x + 1
  from test
) search breadth first by x set y
select * from test limit 5;
---END---
---START---
-- various syntax errors
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by foo, tar set seq
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set label
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t, f set seq
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	(select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t)
) search depth first by f, t set seq
select * from search_graph order by seq;
---END---
---START---
-- check that we distinguish same CTE name used at different levels
-- (this case could be supported, perhaps, but it isn't today)
with recursive x(col) as (
	select 1
	union
	(with x as (select * from x)
	 select * from x)
) search depth first by col set seq
select * from x;
---END---
---START---
-- test ruleutils and view expansion
create temp view v_search as
with recursive search_graph(f, t, label) as (
	select * from graph0 g
	union all
	select g.*
	from graph0 g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
select f, t, label from search_graph;
---END---
---START---
select pg_get_viewdef('v_search');
---END---
---START---
select * from v_search;
---END---
---START---
--
-- test cycle detection
--
DROP TABLE IF EXISTS graph;

CREATE TABLE graph (gemini_pk serial PRIMARY KEY, f integer, t integer, label text);
---END---
---START---
insert into graph values
	(1, 2, 'arc 1 -> 2'),
	(1, 3, 'arc 1 -> 3'),
	(2, 3, 'arc 2 -> 3'),
	(1, 4, 'arc 1 -> 4'),
	(4, 5, 'arc 4 -> 5'),
	(5, 1, 'arc 5 -> 1');
---END---
---START---
with recursive search_graph(f, t, label, is_cycle, path) as (
	select *, false, array[row(g.f, g.t)] from graph g
	union all
	select g.*, row(g.f, g.t) = any(path), path || row(g.f, g.t)
	from graph g, search_graph sg
	where g.f = sg.t and not is_cycle
)
select * from search_graph;
---END---
---START---
-- UNION DISTINCT exercises row type hashing support
with recursive search_graph(f, t, label, is_cycle, path) as (
	select *, false, array[row(g.f, g.t)] from graph g
	union distinct
	select g.*, row(g.f, g.t) = any(path), path || row(g.f, g.t)
	from graph g, search_graph sg
	where g.f = sg.t and not is_cycle
)
select * from search_graph;
---END---
---START---
-- ordering by the path column has same effect as SEARCH DEPTH FIRST
with recursive search_graph(f, t, label, is_cycle, path) as (
	select *, false, array[row(g.f, g.t)] from graph g
	union all
	select g.*, row(g.f, g.t) = any(path), path || row(g.f, g.t)
	from graph g, search_graph sg
	where g.f = sg.t and not is_cycle
)
select * from search_graph order by path;
---END---
---START---
-- CYCLE clause

explain (verbose, costs off)
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union distinct
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to 'Y' default 'N' using path
select * from search_graph;
---END---
---START---
explain (verbose, costs off)
with recursive test as (
  select 0 as x
  union all
  select (x + 1) % 10
  from test
) cycle x set is_cycle using path
select * from test;
---END---
---START---
with recursive test as (
  select 0 as x
  union all
  select (x + 1) % 10
  from test
) cycle x set is_cycle using path
select * from test;
---END---
---START---
with recursive test as (
  select 0 as x
  union all
  select (x + 1) % 10
  from test
    where not is_cycle  -- redundant, but legal
) cycle x set is_cycle using path
select * from test;
---END---
---START---
-- multiple CTEs
with recursive
graph(f, t, label) as (
  values (1, 2, 'arc 1 -> 2'),
         (1, 3, 'arc 1 -> 3'),
         (2, 3, 'arc 2 -> 3'),
         (1, 4, 'arc 1 -> 4'),
         (4, 5, 'arc 4 -> 5'),
         (5, 1, 'arc 5 -> 1')
),
search_graph(f, t, label) as (
        select * from graph g
        union all
        select g.*
        from graph g, search_graph sg
        where g.f = sg.t
) cycle f, t set is_cycle to true default false using path
select f, t, label from search_graph;
---END---
---START---
-- star expansion
with recursive a as (
	select 1 as b
	union all
	select * from a
) cycle b set c using p
select * from a;
---END---
---START---
-- search+cycle
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set seq
  cycle f, t set is_cycle using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) search breadth first by f, t set seq
  cycle f, t set is_cycle using path
select * from search_graph;
---END---
---START---
-- various syntax errors
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle foo, tar set is_cycle using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to true default 55 using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to point '(1,1)' default point '(0,0)' using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set label to true default false using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to true default false using label
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set foo to true default false using foo
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t, f set is_cycle to true default false using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set foo
  cycle f, t set foo to true default false using path
select * from search_graph;
---END---
---START---
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) search depth first by f, t set foo
  cycle f, t set is_cycle to true default false using foo
select * from search_graph;
---END---
---START---
-- test ruleutils and view expansion
create temp view v_cycle1 as
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle using path
select f, t, label from search_graph;
---END---
---START---
create temp view v_cycle2 as
with recursive search_graph(f, t, label) as (
	select * from graph g
	union all
	select g.*
	from graph g, search_graph sg
	where g.f = sg.t
) cycle f, t set is_cycle to 'Y' default 'N' using path
select f, t, label from search_graph;
---END---
---START---
select pg_get_viewdef('v_cycle1');
---END---
---START---
select pg_get_viewdef('v_cycle2');
---END---
---START---
select * from v_cycle1;
---END---
---START---
select * from v_cycle2;
---END---
---START---
--
-- test multiple WITH queries
--
WITH RECURSIVE
  y (id) AS (VALUES (1)),
  x (id) AS (SELECT * FROM y UNION ALL SELECT id+1 FROM x WHERE id < 5)
SELECT * FROM x;
---END---
---START---
-- forward reference OK
WITH RECURSIVE
    x(id) AS (SELECT * FROM y UNION ALL SELECT id+1 FROM x WHERE id < 5),
    y(id) AS (values (1))
 SELECT * FROM x;
---END---
---START---
WITH RECURSIVE
   x(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 5),
   y(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM y WHERE id < 10)
 SELECT y.*, x.* FROM y LEFT JOIN x USING (id);
---END---
---START---
WITH RECURSIVE
   x(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 5),
   y(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 10)
 SELECT y.*, x.* FROM y LEFT JOIN x USING (id);
---END---
---START---
WITH RECURSIVE
   x(id) AS
     (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 3 ),
   y(id) AS
     (SELECT * FROM x UNION ALL SELECT * FROM x),
   z(id) AS
     (SELECT * FROM x UNION ALL SELECT id+1 FROM z WHERE id < 10)
 SELECT * FROM z;
---END---
---START---
WITH RECURSIVE
   x(id) AS
     (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 3 ),
   y(id) AS
     (SELECT * FROM x UNION ALL SELECT * FROM x),
   z(id) AS
     (SELECT * FROM y UNION ALL SELECT id+1 FROM z WHERE id < 10)
 SELECT * FROM z;
---END---
---START---
--
-- Test WITH attached to a data-modifying statement
--

DROP TABLE IF EXISTS y;

CREATE TABLE y (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO y SELECT generate_series(1, 10);
---END---
---START---
WITH t AS (
	SELECT a FROM y
)
INSERT INTO y
SELECT a+20 FROM t RETURNING *;
---END---
---START---
SELECT * FROM y;
---END---
---START---
WITH t AS (
	SELECT a FROM y
)
UPDATE y SET a = y.a-10 FROM t WHERE y.a > 20 AND t.a = y.a RETURNING y.a;
---END---
---START---
SELECT * FROM y;
---END---
---START---
WITH RECURSIVE t(a) AS (
	SELECT 11
	UNION ALL
	SELECT a+1 FROM t WHERE a < 50
)
DELETE FROM y USING t WHERE t.a = y.a RETURNING y.a;
---END---
---START---
SELECT * FROM y;
---END---
---START---
DROP TABLE y;
---END---
---START---
--
-- error cases
--

WITH x(n, b) AS (SELECT 1)
SELECT * FROM x;
---END---
---START---
-- INTERSECT
WITH RECURSIVE x(n) AS (SELECT 1 INTERSECT SELECT n+1 FROM x)
	SELECT * FROM x;
---END---
---START---
WITH RECURSIVE x(n) AS (SELECT 1 INTERSECT ALL SELECT n+1 FROM x)
	SELECT * FROM x;
---END---
---START---
-- EXCEPT
WITH RECURSIVE x(n) AS (SELECT 1 EXCEPT SELECT n+1 FROM x)
	SELECT * FROM x;
---END---
---START---
WITH RECURSIVE x(n) AS (SELECT 1 EXCEPT ALL SELECT n+1 FROM x)
	SELECT * FROM x;
---END---
---START---
-- no non-recursive term
WITH RECURSIVE x(n) AS (SELECT n FROM x)
	SELECT * FROM x;
---END---
---START---
-- recursive term in the left hand side (strictly speaking, should allow this)
WITH RECURSIVE x(n) AS (SELECT n FROM x UNION ALL SELECT 1)
	SELECT * FROM x;
---END---
---START---
DROP TABLE IF EXISTS y;

CREATE TABLE y (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
INSERT INTO y SELECT generate_series(1, 10);
---END---
---START---
-- LEFT JOIN

WITH RECURSIVE x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM y LEFT JOIN x ON x.n = y.a WHERE n < 10)
SELECT * FROM x;
---END---
---START---
-- RIGHT JOIN
WITH RECURSIVE x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM x RIGHT JOIN y ON x.n = y.a WHERE n < 10)
SELECT * FROM x;
---END---
---START---
-- FULL JOIN
WITH RECURSIVE x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM x FULL JOIN y ON x.n = y.a WHERE n < 10)
SELECT * FROM x;
---END---
---START---
-- subquery
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x
                          WHERE n IN (SELECT * FROM x))
  SELECT * FROM x;
---END---
---START---
-- aggregate functions
-- @hengfeng: this query gets stuck in cockroachdb
--WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT count(*) FROM x)
--  SELECT * FROM x;
---END---
---START---
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT sum(n) FROM x)
  SELECT * FROM x;
---END---
---START---
-- ORDER BY
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x ORDER BY 1)
  SELECT * FROM x;
---END---
---START---
-- LIMIT/OFFSET
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x LIMIT 10 OFFSET 1)
  SELECT * FROM x;
---END---
---START---
-- FOR UPDATE
-- @hengfeng: not work for cockroachdb
--WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x FOR UPDATE)
--  SELECT * FROM x;
---END---
---START---
-- target list has a recursive query name
WITH RECURSIVE x(id) AS (values (1)
    UNION ALL
    SELECT (SELECT * FROM x) FROM x WHERE id < 5
) SELECT * FROM x;
---END---
---START---
-- mutual recursive query (not implemented)
WITH RECURSIVE
  x (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM y WHERE id < 5),
  y (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 5)
SELECT * FROM x;
---END---
---START---
-- non-linear recursion is not allowed
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM foo WHERE i < 10
          UNION ALL
       SELECT i+1 FROM foo WHERE i < 5)
) SELECT * FROM foo;
---END---
---START---
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
	   SELECT * FROM
       (SELECT i+1 FROM foo WHERE i < 10
          UNION ALL
       SELECT i+1 FROM foo WHERE i < 5) AS t
) SELECT * FROM foo;
---END---
---START---
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM foo WHERE i < 10
          EXCEPT
       SELECT i+1 FROM foo WHERE i < 5)
) SELECT * FROM foo;
---END---
---START---
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM foo WHERE i < 10
          INTERSECT
       SELECT i+1 FROM foo WHERE i < 5)
) SELECT * FROM foo;
---END---
---START---
-- Wrong type induced from non-recursive term
WITH RECURSIVE foo(i) AS
   (SELECT i FROM (VALUES(1),(2)) t(i)
   UNION ALL
   SELECT (i+1)::numeric(10,0) FROM foo WHERE i < 10)
SELECT * FROM foo;
---END---
---START---
-- rejects different typmod, too (should we allow this?)
WITH RECURSIVE foo(i) AS
   (SELECT i::numeric(3,0) FROM (VALUES(1),(2)) t(i)
   UNION ALL
   SELECT (i+1)::numeric(10,0) FROM foo WHERE i < 10)
SELECT * FROM foo;
---END---
---START---
-- disallow OLD/NEW reference in CTE
DROP TABLE IF EXISTS x;

CREATE TABLE x (gemini_pk serial PRIMARY KEY, n integer);
---END---
---START---
CREATE RULE r2 AS ON UPDATE TO x DO INSTEAD
    WITH t AS (SELECT OLD.*) UPDATE y SET a = t.n FROM t;
---END---
---START---
--
-- test for bug #4902
--
with cte(foo) as ( values(42) ) values((select foo from cte));
---END---
---START---
with cte(foo) as ( select 42 ) select * from ((select foo from cte)) q;
---END---
---START---
-- test CTE referencing an outer-level variable (to see that changed-parameter
-- signaling still works properly after fixing this bug)
select ( with cte(foo) as ( values(f1) )
         select (select foo from cte) )
from int4_tbl;
---END---
---START---
select ( with cte(foo) as ( values(f1) )
          values((select foo from cte)) )
from int4_tbl;
---END---
---START---
--
-- test for nested-recursive-WITH bug
--
WITH RECURSIVE t(j) AS (
    WITH RECURSIVE s(i) AS (
        VALUES (1)
        UNION ALL
        SELECT i+1 FROM s WHERE i < 10
    )
    SELECT i FROM s
    UNION ALL
    SELECT j+1 FROM t WHERE j < 10
)
SELECT * FROM t;
---END---
---START---
--
-- test WITH attached to intermediate-level set operation
--

WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM innermost
         UNION SELECT 3)
)
SELECT * FROM outermost ORDER BY 1;
---END---
---START---
WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost  -- fail
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost ORDER BY 1;
---END---
---START---
WITH RECURSIVE outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost ORDER BY 1;
---END---
---START---
WITH RECURSIVE outermost(x) AS (
  WITH innermost as (SELECT 2 FROM outermost) -- fail
    SELECT * FROM innermost
    UNION SELECT * from outermost
)
SELECT * FROM outermost ORDER BY 1;
---END---
---START---
--
-- This test will fail with the old implementation of PARAM_EXEC parameter
-- assignment, because the "q1" Var passed down to A's targetlist subselect
-- looks exactly like the "A.id" Var passed down to C's subselect, causing
-- the old code to give them the same runtime PARAM_EXEC slot.  But the
-- lifespans of the two parameters overlap, thanks to B also reading A.
--

with
A as ( select q2 as id, (select q1) as x from int8_tbl ),
B as ( select id, row_number() over (partition by id) as r from A ),
C as ( select A.id, array(select B.id from B where B.id = A.id) from A )
select * from C;
---END---
---START---
--
-- Test CTEs read in non-initialization orders
--

WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION ALL (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;
---END---
---START---
WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;
---END---
---START---
--
-- Data-modifying statements in WITH
--

-- INSERT ... RETURNING
WITH t AS (
    INSERT INTO y
    VALUES
        (11),
        (12),
        (13),
        (14),
        (15),
        (16),
        (17),
        (18),
        (19),
        (20)
    RETURNING *
)
SELECT * FROM t;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- UPDATE ... RETURNING
WITH t AS (
    UPDATE y
    SET a=a+1
    RETURNING *
)
SELECT * FROM t;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- DELETE ... RETURNING
WITH t AS (
    DELETE FROM y
    WHERE a <= 10
    RETURNING *
)
SELECT * FROM t;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- forward reference
WITH RECURSIVE t AS (
	INSERT INTO y
		SELECT a+5 FROM t2 WHERE a > 5
	RETURNING *
), t2 AS (
	UPDATE y SET a=a-11 RETURNING *
)
SELECT * FROM t
UNION ALL
SELECT * FROM t2;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- unconditional DO INSTEAD rule
CREATE RULE y_rule AS ON DELETE TO y DO INSTEAD
  INSERT INTO y VALUES(42) RETURNING *;
---END---
---START---
WITH t AS (
	DELETE FROM y RETURNING *
)
SELECT * FROM t;
---END---
---START---
SELECT * FROM y;
---END---
---START---
DROP RULE y_rule ON y;
---END---
---START---
-- check merging of outer CTE with CTE in a rule action
DROP TABLE IF EXISTS bug6051;

CREATE TABLE bug6051 AS
  select i from generate_series(1,3) as t(i);
---END---
---START---
SELECT * FROM bug6051;
---END---
---START---
WITH t1 AS ( DELETE FROM bug6051 RETURNING * )
INSERT INTO bug6051 SELECT * FROM t1;
---END---
---START---
SELECT * FROM bug6051;
---END---
---START---
DROP TABLE IF EXISTS bug6051_2;

CREATE TABLE bug6051_2 (gemini_pk serial PRIMARY KEY, i integer);
---END---
---START---
CREATE RULE bug6051_ins AS ON INSERT TO bug6051 DO INSTEAD
 INSERT INTO bug6051_2
 VALUES(NEW.i);
---END---
---START---
WITH t1 AS ( DELETE FROM bug6051 RETURNING * )
INSERT INTO bug6051 SELECT * FROM t1;
---END---
---START---
SELECT * FROM bug6051;
---END---
---START---
SELECT * FROM bug6051_2;
---END---
---START---
-- check INSERT ... SELECT rule actions are disallowed on commands
-- that have modifyingCTEs
CREATE OR REPLACE RULE bug6051_ins AS ON INSERT TO bug6051 DO INSTEAD
 INSERT INTO bug6051_2
 SELECT NEW.i;
---END---
---START---
WITH t1 AS ( DELETE FROM bug6051 RETURNING * )
INSERT INTO bug6051 SELECT * FROM t1;
---END---
---START---
-- silly example to verify that hasModifyingCTE flag is propagated
DROP TABLE IF EXISTS bug6051_3;

CREATE TABLE bug6051_3 AS
  SELECT a FROM generate_series(11,13) AS a;
---END---
---START---
CREATE RULE bug6051_3_ins AS ON INSERT TO bug6051_3 DO INSTEAD
  SELECT i FROM bug6051_2;
---END---
---START---
BEGIN;
---END---
---START---
SET LOCAL debug_parallel_query = on;
---END---
---START---
WITH t1 AS ( DELETE FROM bug6051_3 RETURNING * )
  INSERT INTO bug6051_3 SELECT * FROM t1;
---END---
---START---
COMMIT;
---END---
---START---
SELECT * FROM bug6051_3;
---END---
---START---
-- check case where CTE reference is removed due to optimization
EXPLAIN (VERBOSE, COSTS OFF)
SELECT q1 FROM
(
  WITH t_cte AS (SELECT * FROM int8_tbl t)
  SELECT q1, (SELECT q2 FROM t_cte WHERE t_cte.q1 = i8.q1) AS t_sub
  FROM int8_tbl i8
) ss;
---END---
---START---
SELECT q1 FROM
(
  WITH t_cte AS (SELECT * FROM int8_tbl t)
  SELECT q1, (SELECT q2 FROM t_cte WHERE t_cte.q1 = i8.q1) AS t_sub
  FROM int8_tbl i8
) ss;
---END---
---START---
EXPLAIN (VERBOSE, COSTS OFF)
SELECT q1 FROM
(
  WITH t_cte AS MATERIALIZED (SELECT * FROM int8_tbl t)
  SELECT q1, (SELECT q2 FROM t_cte WHERE t_cte.q1 = i8.q1) AS t_sub
  FROM int8_tbl i8
) ss;
---END---
---START---
SELECT q1 FROM
(
  WITH t_cte AS MATERIALIZED (SELECT * FROM int8_tbl t)
  SELECT q1, (SELECT q2 FROM t_cte WHERE t_cte.q1 = i8.q1) AS t_sub
  FROM int8_tbl i8
) ss;
---END---
---START---
-- a truly recursive CTE in the same list
WITH RECURSIVE t(a) AS (
	SELECT 0
		UNION ALL
	SELECT a+1 FROM t WHERE a+1 < 5
), t2 as (
	INSERT INTO y
		SELECT * FROM t RETURNING *
)
SELECT * FROM t2 JOIN y USING (a) ORDER BY a;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- data-modifying WITH in a modifying statement
WITH t AS (
    DELETE FROM y
    WHERE a <= 10
    RETURNING *
)
INSERT INTO y SELECT -a FROM t RETURNING *;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- check that WITH query is run to completion even if outer query isn't
WITH t AS (
    UPDATE y SET a = a * 100 RETURNING *
)
SELECT * FROM t LIMIT 10;
---END---
---START---
SELECT * FROM y;
---END---
---START---
-- data-modifying WITH containing INSERT...ON CONFLICT DO UPDATE
CREATE TABLE withz AS SELECT i AS k, (i || ' v')::text v FROM generate_series(1, 16, 3) i;
---END---
---START---
ALTER TABLE withz ADD UNIQUE (k);
---END---
---START---
WITH t AS (
    INSERT INTO withz SELECT i, 'insert'
    FROM generate_series(0, 16) i
    ON CONFLICT (k) DO UPDATE SET v = withz.v || ', now update'
    RETURNING *
)
SELECT * FROM t JOIN y ON t.k = y.a ORDER BY a, k;
---END---
---START---
-- Test EXCLUDED.* reference within CTE
WITH aa AS (
    INSERT INTO withz VALUES(1, 5) ON CONFLICT (k) DO UPDATE SET v = EXCLUDED.v
    WHERE withz.k != EXCLUDED.k
    RETURNING *
)
SELECT * FROM aa;
---END---
---START---
-- New query/snapshot demonstrates side-effects of previous query.
SELECT * FROM withz ORDER BY k;
---END---
---START---
--
-- Ensure subqueries within the update clause work, even if they
-- reference outside values
--
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 1 LIMIT 1);
---END---
---START---
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = ' update' WHERE withz.k = (SELECT a FROM aa);
---END---
---START---
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 1 LIMIT 1);
---END---
---START---
WITH aa AS (SELECT 'a' a, 'b' b UNION ALL SELECT 'a' a, 'b' b)
INSERT INTO withz VALUES(1, 'insert')
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 'a' LIMIT 1);
---END---
---START---
WITH aa AS (SELECT 1 a, 2 b)
INSERT INTO withz VALUES(1, (SELECT b || ' insert' FROM aa WHERE a = 1 ))
ON CONFLICT (k) DO UPDATE SET v = (SELECT b || ' update' FROM aa WHERE a = 1 LIMIT 1);
---END---
---START---
-- Update a row more than once, in different parts of a wCTE. That is
-- an allowed, presumably very rare, edge case, but since it was
-- broken in the past, having a test seems worthwhile.
WITH simpletup AS (
  SELECT 2 k, 'Green' v),
upsert_cte AS (
  INSERT INTO withz VALUES(2, 'Blue') ON CONFLICT (k) DO
    UPDATE SET (k, v) = (SELECT k, v FROM simpletup WHERE simpletup.k = withz.k)
    RETURNING k, v)
INSERT INTO withz VALUES(2, 'Red') ON CONFLICT (k) DO
UPDATE SET (k, v) = (SELECT k, v FROM upsert_cte WHERE upsert_cte.k = withz.k)
RETURNING k, v;
---END---
---START---
DROP TABLE withz;
---END---
---START---
-- WITH referenced by MERGE statement
CREATE TABLE m AS SELECT i AS k, (i || ' v')::text v FROM generate_series(1, 16, 3) i;
---END---
---START---
ALTER TABLE m ADD UNIQUE (k);
---END---
---START---
WITH RECURSIVE cte_basic AS (SELECT 1 a, 'cte_basic val' b)
MERGE INTO m USING (select 0 k, 'merge source SubPlan' v) o ON m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_basic WHERE cte_basic.a = m.k LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
---END---
---START---
-- Basic:
WITH cte_basic AS MATERIALIZED (SELECT 1 a, 'cte_basic val' b)
MERGE INTO m USING (select 0 k, 'merge source SubPlan' v offset 0) o ON m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_basic WHERE cte_basic.a = m.k LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
---END---
---START---
-- Examine
SELECT * FROM m where k = 0;
---END---
---START---
-- See EXPLAIN output for same query:
EXPLAIN (VERBOSE, COSTS OFF)
WITH cte_basic AS MATERIALIZED (SELECT 1 a, 'cte_basic val' b)
MERGE INTO m USING (select 0 k, 'merge source SubPlan' v offset 0) o ON m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_basic WHERE cte_basic.a = m.k LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
---END---
---START---
-- InitPlan
WITH cte_init AS MATERIALIZED (SELECT 1 a, 'cte_init val' b)
MERGE INTO m USING (select 1 k, 'merge source InitPlan' v offset 0) o ON m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_init WHERE a = 1 LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
---END---
---START---
-- Examine
SELECT * FROM m where k = 1;
---END---
---START---
-- See EXPLAIN output for same query:
EXPLAIN (VERBOSE, COSTS OFF)
WITH cte_init AS MATERIALIZED (SELECT 1 a, 'cte_init val' b)
MERGE INTO m USING (select 1 k, 'merge source InitPlan' v offset 0) o ON m.k=o.k
WHEN MATCHED THEN UPDATE SET v = (SELECT b || ' merge update' FROM cte_init WHERE a = 1 LIMIT 1)
WHEN NOT MATCHED THEN INSERT VALUES(o.k, o.v);
---END---
---START---
-- MERGE source comes from CTE:
WITH merge_source_cte AS MATERIALIZED (SELECT 15 a, 'merge_source_cte val' b)
MERGE INTO m USING (select * from merge_source_cte) o ON m.k=o.a
WHEN MATCHED THEN UPDATE SET v = (SELECT b || merge_source_cte.*::text || ' merge update' FROM merge_source_cte WHERE a = 15)
WHEN NOT MATCHED THEN INSERT VALUES(o.a, o.b || (SELECT merge_source_cte.*::text || ' merge insert' FROM merge_source_cte));
---END---
---START---
-- Examine
SELECT * FROM m where k = 15;
---END---
---START---
-- See EXPLAIN output for same query:
EXPLAIN (VERBOSE, COSTS OFF)
WITH merge_source_cte AS MATERIALIZED (SELECT 15 a, 'merge_source_cte val' b)
MERGE INTO m USING (select * from merge_source_cte) o ON m.k=o.a
WHEN MATCHED THEN UPDATE SET v = (SELECT b || merge_source_cte.*::text || ' merge update' FROM merge_source_cte WHERE a = 15)
WHEN NOT MATCHED THEN INSERT VALUES(o.a, o.b || (SELECT merge_source_cte.*::text || ' merge insert' FROM merge_source_cte));
---END---
---START---
DROP TABLE m;
---END---
---START---
-- check that run to completion happens in proper ordering

TRUNCATE TABLE y;
---END---
---START---
INSERT INTO y SELECT generate_series(1, 3);
---END---
---START---
DROP TABLE IF EXISTS yy;

CREATE TABLE yy (gemini_pk serial PRIMARY KEY, a integer);
---END---
---START---
WITH RECURSIVE t1 AS (
  INSERT INTO y SELECT * FROM y RETURNING *
), t2 AS (
  INSERT INTO yy SELECT * FROM t1 RETURNING *
)
SELECT 1;
---END---
---START---
SELECT * FROM y;
---END---
---START---
SELECT * FROM yy;
---END---
---START---
WITH RECURSIVE t1 AS (
  INSERT INTO yy SELECT * FROM t2 RETURNING *
), t2 AS (
  INSERT INTO y SELECT * FROM y RETURNING *
)
SELECT 1;
---END---
---START---
SELECT * FROM y;
---END---
---START---
SELECT * FROM yy;
---END---
---START---
-- triggers

TRUNCATE TABLE y;
---END---
---START---
INSERT INTO y SELECT generate_series(1, 10);
---END---
---START---
CREATE FUNCTION y_trigger() RETURNS trigger AS $$
begin
  raise notice 'y_trigger: a = %', new.a;
  return new;
end;
$$ LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER y_trig BEFORE INSERT ON y FOR EACH ROW
    EXECUTE PROCEDURE y_trigger();
---END---
---START---
WITH t AS (
    INSERT INTO y
    VALUES
        (21),
        (22),
        (23)
    RETURNING *
)
SELECT * FROM t;
---END---
---START---
SELECT * FROM y;
---END---
---START---
DROP TRIGGER y_trig ON y;
---END---
---START---
CREATE TRIGGER y_trig AFTER INSERT ON y FOR EACH ROW
    EXECUTE PROCEDURE y_trigger();
---END---
---START---
WITH t AS (
    INSERT INTO y
    VALUES
        (31),
        (32),
        (33)
    RETURNING *
)
SELECT * FROM t LIMIT 1;
---END---
---START---
SELECT * FROM y;
---END---
---START---
DROP TRIGGER y_trig ON y;
---END---
---START---
CREATE OR REPLACE FUNCTION y_trigger() RETURNS trigger AS $$
begin
  raise notice 'y_trigger';
  return null;
end;
$$ LANGUAGE plpgsql;
---END---
---START---
CREATE TRIGGER y_trig AFTER INSERT ON y FOR EACH STATEMENT
    EXECUTE PROCEDURE y_trigger();
---END---
---START---
WITH t AS (
    INSERT INTO y
    VALUES
        (41),
        (42),
        (43)
    RETURNING *
)
SELECT * FROM t;
---END---
---START---
SELECT * FROM y;
---END---
---START---
DROP TRIGGER y_trig ON y;
---END---
---START---
DROP FUNCTION y_trigger();
---END---
---START---
-- WITH attached to inherited UPDATE or DELETE

DROP TABLE IF EXISTS parent;

CREATE TABLE parent (gemini_pk serial PRIMARY KEY, id integer, val text);
---END---
---START---
DROP TABLE IF EXISTS child1;

CREATE TABLE child1 (gemini_pk serial PRIMARY KEY) INHERITS (parent);
---END---
---START---
DROP TABLE IF EXISTS child2;

CREATE TABLE child2 (gemini_pk serial PRIMARY KEY) INHERITS (parent);
---END---
---START---
INSERT INTO parent VALUES ( 1, 'p1' );
---END---
---START---
INSERT INTO child1 VALUES ( 11, 'c11' ),( 12, 'c12' );
---END---
---START---
INSERT INTO child2 VALUES ( 23, 'c21' ),( 24, 'c22' );
---END---
---START---
WITH rcte AS ( SELECT sum(id) AS totalid FROM parent )
UPDATE parent SET id = id + totalid FROM rcte;
---END---
---START---
SELECT * FROM parent;
---END---
---START---
WITH wcte AS ( INSERT INTO child1 VALUES ( 42, 'new' ) RETURNING id AS newid )
UPDATE parent SET id = id + newid FROM wcte;
---END---
---START---
SELECT * FROM parent;
---END---
---START---
WITH rcte AS ( SELECT max(id) AS maxid FROM parent )
DELETE FROM parent USING rcte WHERE id = maxid;
---END---
---START---
SELECT * FROM parent;
---END---
---START---
WITH wcte AS ( INSERT INTO child2 VALUES ( 42, 'new2' ) RETURNING id AS newid )
DELETE FROM parent USING wcte WHERE id = newid;
---END---
---START---
SELECT * FROM parent;
---END---
---START---
-- check EXPLAIN VERBOSE for a wCTE with RETURNING

EXPLAIN (VERBOSE, COSTS OFF)
WITH wcte AS ( INSERT INTO int8_tbl VALUES ( 42, 47 ) RETURNING q2 )
DELETE FROM a_star USING wcte WHERE aa = q2;
---END---
---START---
-- error cases

-- data-modifying WITH tries to use its own output
WITH RECURSIVE t AS (
	INSERT INTO y
		SELECT * FROM t
)
VALUES(FALSE);
---END---
---START---
-- no RETURNING in a referenced data-modifying WITH
WITH t AS (
	INSERT INTO y VALUES(0)
)
SELECT * FROM t;
---END---
---START---
-- data-modifying WITH allowed only at the top level
SELECT * FROM (
	WITH t AS (UPDATE y SET a=a+1 RETURNING *)
	SELECT * FROM t
) ss;
---END---
---START---
-- most variants of rules aren't allowed
CREATE RULE y_rule AS ON INSERT TO y WHERE a=0 DO INSTEAD DELETE FROM y;
---END---
---START---
WITH t AS (
	INSERT INTO y VALUES(0)
)
VALUES(FALSE);
---END---
---START---
CREATE OR REPLACE RULE y_rule AS ON INSERT TO y DO INSTEAD NOTHING;
---END---
---START---
WITH t AS (
	INSERT INTO y VALUES(0)
)
VALUES(FALSE);
---END---
---START---
CREATE OR REPLACE RULE y_rule AS ON INSERT TO y DO INSTEAD NOTIFY foo;
---END---
---START---
WITH t AS (
	INSERT INTO y VALUES(0)
)
VALUES(FALSE);
---END---
---START---
CREATE OR REPLACE RULE y_rule AS ON INSERT TO y DO ALSO NOTIFY foo;
---END---
---START---
WITH t AS (
	INSERT INTO y VALUES(0)
)
VALUES(FALSE);
---END---
---START---
CREATE OR REPLACE RULE y_rule AS ON INSERT TO y
  DO INSTEAD (NOTIFY foo; NOTIFY bar);
---END---
---START---
WITH t AS (
	INSERT INTO y VALUES(0)
)
VALUES(FALSE);
---END---
---START---
DROP RULE y_rule ON y;
---END---
---START---
-- check that parser lookahead for WITH doesn't cause any odd behavior
create table foo (with baz);
---END---
---START---
-- fail, WITH is a reserved word
create table foo (with ordinality);
---END---
---START---
-- fail, WITH is a reserved word
with ordinality as (select 1 as x) select * from ordinality;
---END---
---START---
-- check sane response to attempt to modify CTE relation
WITH with_test AS (SELECT 42) INSERT INTO with_test VALUES (1);
---END---
---START---
-- check response to attempt to modify table with same name as a CTE (perhaps
-- surprisingly it works, because CTEs don't hide tables from data-modifying
-- statements)
DROP TABLE IF EXISTS with_test;

CREATE TABLE with_test (gemini_pk serial PRIMARY KEY, i integer);
---END---
---START---
with with_test as (select 42) insert into with_test select * from with_test;
---END---
---START---
select * from with_test;
---END---
---START---
drop table with_test;
---END---
