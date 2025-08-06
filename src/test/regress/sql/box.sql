---START---
--
-- BOX
--

--
-- box logic
--	     o
-- 3	  o--|X
--	  |  o|
-- 2	+-+-+ |
--	| | | |
-- 1	| o-+-o
--	|   |
-- 0	+---+
--
--	0 1 2 3
--

-- boxes are specified by two points, given by four floats x1,y1,x2,y2


CREATE TABLE BOX_TBL (f1 box);
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('(2.0,2.0,0.0,0.0)');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('(1.0,1.0,3.0,3.0)');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('((-8, 2), (-2, -10))');
---END---
---START---


-- degenerate cases where the box is a line or a point
-- note that lines and points boxes all have zero area
INSERT INTO BOX_TBL (f1) VALUES ('(2.5, 2.5, 2.5,3.5)');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('(3.0, 3.0,3.0,3.0)');
---END---
---START---

-- badly formatted box inputs
INSERT INTO BOX_TBL (f1) VALUES ('(2.3, 4.5)');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('[1, 2, 3, 4)');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('(1, 2, 3, 4]');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('(1, 2, 3, 4) x');
---END---
---START---

INSERT INTO BOX_TBL (f1) VALUES ('asdfasdf(ad');
---END---
---START---


SELECT * FROM BOX_TBL;
---END---
---START---

SELECT b.*, area(b.f1) as barea
   FROM BOX_TBL b;
---END---
---START---

-- overlap
SELECT b.f1
   FROM BOX_TBL b
   WHERE b.f1 && box '(2.5,2.5,1.0,1.0)';
---END---
---START---

-- left-or-overlap (x only)
SELECT b1.*
   FROM BOX_TBL b1
   WHERE b1.f1 &< box '(2.0,2.0,2.5,2.5)';
---END---
---START---

-- right-or-overlap (x only)
SELECT b1.*
   FROM BOX_TBL b1
   WHERE b1.f1 &> box '(2.0,2.0,2.5,2.5)';
---END---
---START---

-- left of
SELECT b.f1
   FROM BOX_TBL b
   WHERE b.f1 << box '(3.0,3.0,5.0,5.0)';
---END---
---START---

-- area <=
SELECT b.f1
   FROM BOX_TBL b
   WHERE b.f1 <= box '(3.0,3.0,5.0,5.0)';
---END---
---START---

-- area <
SELECT b.f1
   FROM BOX_TBL b
   WHERE b.f1 < box '(3.0,3.0,5.0,5.0)';
---END---
---START---

-- area =
SELECT b.f1
   FROM BOX_TBL b
   WHERE b.f1 = box '(3.0,3.0,5.0,5.0)';
---END---
---START---

-- area >
SELECT b.f1
   FROM BOX_TBL b				-- zero area
   WHERE b.f1 > box '(3.5,3.0,4.5,3.0)';
---END---
---START---

-- area >=
SELECT b.f1
   FROM BOX_TBL b				-- zero area
   WHERE b.f1 >= box '(3.5,3.0,4.5,3.0)';
---END---
---START---

-- right of
SELECT b.f1
   FROM BOX_TBL b
   WHERE box '(3.0,3.0,5.0,5.0)' >> b.f1;
---END---
---START---

-- contained in
SELECT b.f1
   FROM BOX_TBL b
   WHERE b.f1 <@ box '(0,0,3,3)';
---END---
---START---

-- contains
SELECT b.f1
   FROM BOX_TBL b
   WHERE box '(0,0,3,3)' @> b.f1;
---END---
---START---

-- box equality
SELECT b.f1
   FROM BOX_TBL b
   WHERE box '(1,1,3,3)' ~= b.f1;
---END---
---START---

-- center of box, left unary operator
SELECT @@(b1.f1) AS p
   FROM BOX_TBL b1;
---END---
---START---

-- wholly-contained
SELECT b1.*, b2.*
   FROM BOX_TBL b1, BOX_TBL b2
   WHERE b1.f1 @> b2.f1 and not b1.f1 ~= b2.f1;
---END---
---START---

SELECT height(f1), width(f1) FROM BOX_TBL;
---END---
---START---

--
-- Test the SP-GiST index
--

CREATE TABLE box_temp (f1 box);
---END---
---START---

INSERT INTO box_temp
	SELECT box(point(i, i), point(i * 2, i * 2))
	FROM generate_series(1, 50) AS i;
---END---
---START---

CREATE INDEX box_spgist ON box_temp USING spgist (f1);
---END---
---START---

INSERT INTO box_temp
	VALUES (NULL),
		   ('(0,0)(0,100)'),
		   ('(-3,4.3333333333)(40,1)'),
		   ('(0,100)(0,infinity)'),
		   ('(-infinity,0)(0,infinity)'),
		   ('(-infinity,-infinity)(infinity,infinity)');
---END---
---START---

SET enable_seqscan = false;
---END---
---START---

SELECT * FROM box_temp WHERE f1 << '(10,20),(30,40)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 << '(10,20),(30,40)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 &< '(10,4.333334),(5,100)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 &< '(10,4.333334),(5,100)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 && '(15,20),(25,30)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 && '(15,20),(25,30)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 &> '(40,30),(45,50)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 &> '(40,30),(45,50)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 >> '(30,40),(40,30)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 >> '(30,40),(40,30)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 <<| '(10,4.33334),(5,100)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 <<| '(10,4.33334),(5,100)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 &<| '(10,4.3333334),(5,1)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 &<| '(10,4.3333334),(5,1)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 |&> '(49.99,49.99),(49.99,49.99)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 |&> '(49.99,49.99),(49.99,49.99)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 |>> '(37,38),(39,40)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 |>> '(37,38),(39,40)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 @> '(10,11),(15,16)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 @> '(10,11),(15,15)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 <@ '(10,15),(30,35)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 <@ '(10,15),(30,35)';
---END---
---START---

SELECT * FROM box_temp WHERE f1 ~= '(20,20),(40,40)';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM box_temp WHERE f1 ~= '(20,20),(40,40)';
---END---
---START---

RESET enable_seqscan;
---END---
---START---

DROP INDEX box_spgist;
---END---
---START---

--
-- Test the SP-GiST index on the larger volume of data
--
CREATE TABLE quad_box_tbl (id int, b box);
---END---
---START---

INSERT INTO quad_box_tbl
  SELECT (x - 1) * 100 + y, box(point(x * 10, y * 10), point(x * 10 + 5, y * 10 + 5))
  FROM generate_series(1, 100) x,
       generate_series(1, 100) y;
---END---
---START---

-- insert repeating data to test allTheSame
INSERT INTO quad_box_tbl
  SELECT i, '((200, 300),(210, 310))'
  FROM generate_series(10001, 11000) AS i;
---END---
---START---

INSERT INTO quad_box_tbl
VALUES
  (11001, NULL),
  (11002, NULL),
  (11003, '((-infinity,-infinity),(infinity,infinity))'),
  (11004, '((-infinity,100),(-infinity,500))'),
  (11005, '((-infinity,-infinity),(700,infinity))');
---END---
---START---

CREATE INDEX quad_box_tbl_idx ON quad_box_tbl USING spgist(b);
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

CREATE TABLE quad_box_tbl_ord_seq1 AS
SELECT rank() OVER (ORDER BY b <-> point '123,456') n, b <-> point '123,456' dist, id
FROM quad_box_tbl;
---END---
---START---

CREATE TABLE quad_box_tbl_ord_seq2 AS
SELECT rank() OVER (ORDER BY b <-> point '123,456') n, b <-> point '123,456' dist, id
FROM quad_box_tbl WHERE b <@ box '((200,300),(500,600))';
---END---
---START---

SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = ON;
---END---
---START---
SET enable_bitmapscan = ON;
---END---
---START---

SELECT count(*) FROM quad_box_tbl WHERE b <<  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b &<  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b &&  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b &>  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b >>  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b >>  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b <<| box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b &<| box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b |&> box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b |>> box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b @>  box '((201,301),(202,303))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b <@  box '((100,200),(300,500))';
---END---
---START---
SELECT count(*) FROM quad_box_tbl WHERE b ~=  box '((200,300),(205,305))';
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
SELECT rank() OVER (ORDER BY b <-> point '123,456') n, b <-> point '123,456' dist, id
FROM quad_box_tbl;
---END---
---START---

CREATE TABLE quad_box_tbl_ord_idx1 AS
SELECT rank() OVER (ORDER BY b <-> point '123,456') n, b <-> point '123,456' dist, id
FROM quad_box_tbl;
---END---
---START---

SELECT *
FROM quad_box_tbl_ord_seq1 seq FULL JOIN quad_box_tbl_ord_idx1 idx
	ON seq.n = idx.n AND seq.id = idx.id AND
		(seq.dist = idx.dist OR seq.dist IS NULL AND idx.dist IS NULL)
WHERE seq.id IS NULL OR idx.id IS NULL;
---END---
---START---


EXPLAIN (COSTS OFF)
SELECT rank() OVER (ORDER BY b <-> point '123,456') n, b <-> point '123,456' dist, id
FROM quad_box_tbl WHERE b <@ box '((200,300),(500,600))';
---END---
---START---

CREATE TABLE quad_box_tbl_ord_idx2 AS
SELECT rank() OVER (ORDER BY b <-> point '123,456') n, b <-> point '123,456' dist, id
FROM quad_box_tbl WHERE b <@ box '((200,300),(500,600))';
---END---
---START---

SELECT *
FROM quad_box_tbl_ord_seq2 seq FULL JOIN quad_box_tbl_ord_idx2 idx
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
SELECT pg_input_is_valid('200', 'box');
---END---
---START---
SELECT * FROM pg_input_error_info('200', 'box');
---END---
---START---
SELECT pg_input_is_valid('((200,300),(500, xyz))', 'box');
---END---
---START---
SELECT * FROM pg_input_error_info('((200,300),(500, xyz))', 'box');
---END---
---START---
drop table box_temp;
drop table quad_box_tbl_ord_idx1;
drop table quad_box_tbl_ord_idx2;
---END---
