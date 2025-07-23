---START---
--
-- POLYGON
--
-- polygon logic
--

CREATE TABLE POLYGON_TBL(f1 polygon);
---END---
---START---


INSERT INTO POLYGON_TBL(f1) VALUES ('(2.0,0.0),(2.0,4.0),(0.0,0.0)');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('(3.0,1.0),(3.0,3.0),(1.0,0.0)');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('(1,2),(3,4),(5,6),(7,8)');
---END---
---START---
INSERT INTO POLYGON_TBL(f1) VALUES ('(7,8),(5,6),(3,4),(1,2)'); -- Reverse
INSERT INTO POLYGON_TBL(f1) VALUES ('(1,2),(7,8),(5,6),(3,-4)');
---END---
---START---

-- degenerate polygons
INSERT INTO POLYGON_TBL(f1) VALUES ('(0.0,0.0)');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('(0.0,1.0),(0.0,1.0)');
---END---
---START---

-- bad polygon input strings
INSERT INTO POLYGON_TBL(f1) VALUES ('0.0');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('(0.0 0.0');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('(0,1,2)');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('(0,1,2,3');
---END---
---START---

INSERT INTO POLYGON_TBL(f1) VALUES ('asdf');
---END---
---START---


SELECT * FROM POLYGON_TBL;
---END---
---START---

--
-- Test the SP-GiST index
--

CREATE TABLE quad_poly_tbl (id int, p polygon);
---END---
---START---

INSERT INTO quad_poly_tbl
	SELECT (x - 1) * 100 + y, polygon(circle(point(x * 10, y * 10), 1 + (x + y) % 10))
	FROM generate_series(1, 100) x,
		 generate_series(1, 100) y;
---END---
---START---

INSERT INTO quad_poly_tbl
	SELECT i, polygon '((200, 300),(210, 310),(230, 290))'
	FROM generate_series(10001, 11000) AS i;
---END---
---START---

INSERT INTO quad_poly_tbl
	VALUES
		(11001, NULL),
		(11002, NULL),
		(11003, NULL);
---END---
---START---

CREATE INDEX quad_poly_tbl_idx ON quad_poly_tbl USING spgist(p);
---END---
---START---

-- get reference results for ORDER BY distance from seq scan
SET enable_seqscan = ON;
---END---
---START---
SET enable_indexscan = OFF;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---

CREATE TEMP TABLE quad_poly_tbl_ord_seq2 AS
SELECT rank() OVER (ORDER BY p <-> point '123,456') n, p <-> point '123,456' dist, id
FROM quad_poly_tbl WHERE p <@ polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

-- check results from index scan
SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = OFF;
---END---
---START---
SET enable_bitmapscan = ON;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p << polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p << polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p &< polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p &< polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p && polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p && polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p &> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p &> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p >> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p >> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p <<| polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p <<| polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p &<| polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p &<| polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p |&> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p |&> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p |>> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p |>> polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p <@ polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p <@ polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p @> polygon '((340,550),(343,552),(341,553))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p @> polygon '((340,550),(343,552),(341,553))';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_poly_tbl WHERE p ~= polygon '((200, 300),(210, 310),(230, 290))';
---END---
---START---
SELECT count(*) FROM quad_poly_tbl WHERE p ~= polygon '((200, 300),(210, 310),(230, 290))';
---END---
---START---

-- test ORDER BY distance
SET enable_indexscan = ON;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT rank() OVER (ORDER BY p <-> point '123,456') n, p <-> point '123,456' dist, id
FROM quad_poly_tbl WHERE p <@ polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

CREATE TEMP TABLE quad_poly_tbl_ord_idx2 AS
SELECT rank() OVER (ORDER BY p <-> point '123,456') n, p <-> point '123,456' dist, id
FROM quad_poly_tbl WHERE p <@ polygon '((300,300),(400,600),(600,500),(700,200))';
---END---
---START---

SELECT *
FROM quad_poly_tbl_ord_seq2 seq FULL JOIN quad_poly_tbl_ord_idx2 idx
	ON seq.n = idx.n AND seq.id = idx.id AND
		(seq.dist = idx.dist OR seq.dist IS NULL AND idx.dist IS NULL)
WHERE seq.id IS NULL OR idx.id IS NULL;
---END---
---START---

RESET enable_seqscan;
---END---
---START---
RESET enable_indexscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---

-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('(2.0,0.8,0.1)', 'polygon');
---END---
---START---
SELECT * FROM pg_input_error_info('(2.0,0.8,0.1)', 'polygon');
---END---
---START---
SELECT pg_input_is_valid('(2.0,xyz)', 'polygon');
---END---
---START---
SELECT * FROM pg_input_error_info('(2.0,xyz)', 'polygon');
---END---
