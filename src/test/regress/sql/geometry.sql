---START---
--
-- GEOMETRY
--

-- Back off displayed precision a little bit to reduce platform-to-platform
-- variation in results.
SET extra_float_digits TO -3;
---END---
---START---
--
-- Points
--

SELECT center(f1) AS center
   FROM BOX_TBL;
---END---
---START---
SELECT (@@ f1) AS center
   FROM BOX_TBL;
---END---
---START---
SELECT point(f1) AS center
   FROM CIRCLE_TBL;
---END---
---START---
SELECT (@@ f1) AS center
   FROM CIRCLE_TBL;
---END---
---START---
SELECT (@@ f1) AS center
   FROM POLYGON_TBL
   WHERE (# f1) > 2;
---END---
---START---
-- "is horizontal" function
SELECT p1.f1
   FROM POINT_TBL p1
   WHERE ishorizontal(p1.f1, point '(0,0)');
---END---
---START---
-- "is horizontal" operator
SELECT p1.f1
   FROM POINT_TBL p1
   WHERE p1.f1 ?- point '(0,0)';
---END---
---START---
-- "is vertical" function
SELECT p1.f1
   FROM POINT_TBL p1
   WHERE isvertical(p1.f1, point '(5.1,34.5)');
---END---
---START---
-- "is vertical" operator
SELECT p1.f1
   FROM POINT_TBL p1
   WHERE p1.f1 ?| point '(5.1,34.5)';
---END---
---START---
-- Slope
SELECT p1.f1, p2.f1, slope(p1.f1, p2.f1) FROM POINT_TBL p1, POINT_TBL p2;
---END---
---START---
-- Add point
SELECT p1.f1, p2.f1, p1.f1 + p2.f1 FROM POINT_TBL p1, POINT_TBL p2;
---END---
---START---
-- Subtract point
SELECT p1.f1, p2.f1, p1.f1 - p2.f1 FROM POINT_TBL p1, POINT_TBL p2;
---END---
---START---
-- Multiply with point
SELECT p1.f1, p2.f1, p1.f1 * p2.f1 FROM POINT_TBL p1, POINT_TBL p2 WHERE p1.f1[0] BETWEEN 1 AND 1000;
---END---
---START---
-- Underflow error
SELECT p1.f1, p2.f1, p1.f1 * p2.f1 FROM POINT_TBL p1, POINT_TBL p2 WHERE p1.f1[0] < 1;
---END---
---START---
-- Divide by point
SELECT p1.f1, p2.f1, p1.f1 / p2.f1 FROM POINT_TBL p1, POINT_TBL p2 WHERE p2.f1[0] BETWEEN 1 AND 1000;
---END---
---START---
-- Overflow error
SELECT p1.f1, p2.f1, p1.f1 / p2.f1 FROM POINT_TBL p1, POINT_TBL p2 WHERE p2.f1[0] > 1000;
---END---
---START---
-- Division by 0 error
SELECT p1.f1, p2.f1, p1.f1 / p2.f1 FROM POINT_TBL p1, POINT_TBL p2 WHERE p2.f1 ~= '(0,0)'::point;
---END---
---START---
-- Distance to line
SELECT p.f1, l.s, p.f1 <-> l.s AS dist_pl, l.s <-> p.f1 AS dist_lp FROM POINT_TBL p, LINE_TBL l;
---END---
---START---
-- Distance to line segment
SELECT p.f1, l.s, p.f1 <-> l.s AS dist_ps, l.s <-> p.f1 AS dist_sp FROM POINT_TBL p, LSEG_TBL l;
---END---
---START---
-- Distance to box
SELECT p.f1, b.f1, p.f1 <-> b.f1 AS dist_pb, b.f1 <-> p.f1 AS dist_bp FROM POINT_TBL p, BOX_TBL b;
---END---
---START---
-- Distance to path
SELECT p.f1, p1.f1, p.f1 <-> p1.f1 AS dist_ppath, p1.f1 <-> p.f1 AS dist_pathp FROM POINT_TBL p, PATH_TBL p1;
---END---
---START---
-- Distance to polygon
SELECT p.f1, p1.f1, p.f1 <-> p1.f1 AS dist_ppoly, p1.f1 <-> p.f1 AS dist_polyp FROM POINT_TBL p, POLYGON_TBL p1;
---END---
---START---
-- Construct line through two points
SELECT p1.f1, p2.f1, line(p1.f1, p2.f1)
  FROM POINT_TBL p1, POINT_TBL p2 WHERE p1.f1 <> p2.f1;
---END---
---START---
-- Closest point to line
SELECT p.f1, l.s, p.f1 ## l.s FROM POINT_TBL p, LINE_TBL l;
---END---
---START---
-- Closest point to line segment
SELECT p.f1, l.s, p.f1 ## l.s FROM POINT_TBL p, LSEG_TBL l;
---END---
---START---
-- Closest point to box
SELECT p.f1, b.f1, p.f1 ## b.f1 FROM POINT_TBL p, BOX_TBL b;
---END---
---START---
-- On line
SELECT p.f1, l.s FROM POINT_TBL p, LINE_TBL l WHERE p.f1 <@ l.s;
---END---
---START---
-- On line segment
SELECT p.f1, l.s FROM POINT_TBL p, LSEG_TBL l WHERE p.f1 <@ l.s;
---END---
---START---
-- On path
SELECT p.f1, p1.f1 FROM POINT_TBL p, PATH_TBL p1 WHERE p.f1 <@ p1.f1;
---END---
---START---
--
-- Lines
--

-- Vertical
SELECT s FROM LINE_TBL WHERE ?| s;
---END---
---START---
-- Horizontal
SELECT s FROM LINE_TBL WHERE ?- s;
---END---
---START---
-- Same as line
SELECT l1.s, l2.s FROM LINE_TBL l1, LINE_TBL l2 WHERE l1.s = l2.s;
---END---
---START---
-- Parallel to line
SELECT l1.s, l2.s FROM LINE_TBL l1, LINE_TBL l2 WHERE l1.s ?|| l2.s;
---END---
---START---
-- Perpendicular to line
SELECT l1.s, l2.s FROM LINE_TBL l1, LINE_TBL l2 WHERE l1.s ?-| l2.s;
---END---
---START---
-- Distance to line
SELECT l1.s, l2.s, l1.s <-> l2.s FROM LINE_TBL l1, LINE_TBL l2;
---END---
---START---
-- Intersect with line
SELECT l1.s, l2.s FROM LINE_TBL l1, LINE_TBL l2 WHERE l1.s ?# l2.s;
---END---
---START---
-- Intersect with box
SELECT l.s, b.f1 FROM LINE_TBL l, BOX_TBL b WHERE l.s ?# b.f1;
---END---
---START---
-- Intersection point with line
SELECT l1.s, l2.s, l1.s # l2.s FROM LINE_TBL l1, LINE_TBL l2;
---END---
---START---
-- Closest point to line segment
SELECT l.s, l1.s, l.s ## l1.s FROM LINE_TBL l, LSEG_TBL l1;
---END---
---START---
--
-- Line segments
--

-- intersection
SELECT p.f1, l.s, l.s # p.f1 AS intersection
   FROM LSEG_TBL l, POINT_TBL p;
---END---
---START---
-- Length
SELECT s, @-@ s FROM LSEG_TBL;
---END---
---START---
-- Vertical
SELECT s FROM LSEG_TBL WHERE ?| s;
---END---
---START---
-- Horizontal
SELECT s FROM LSEG_TBL WHERE ?- s;
---END---
---START---
-- Center
SELECT s, @@ s FROM LSEG_TBL;
---END---
---START---
-- To point
SELECT s, s::point FROM LSEG_TBL;
---END---
---START---
-- Has points less than line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s < l2.s;
---END---
---START---
-- Has points less than or equal to line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s <= l2.s;
---END---
---START---
-- Has points equal to line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s = l2.s;
---END---
---START---
-- Has points greater than or equal to line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s >= l2.s;
---END---
---START---
-- Has points greater than line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s > l2.s;
---END---
---START---
-- Has points not equal to line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s != l2.s;
---END---
---START---
-- Parallel with line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s ?|| l2.s;
---END---
---START---
-- Perpendicular with line segment
SELECT l1.s, l2.s FROM LSEG_TBL l1, LSEG_TBL l2 WHERE l1.s ?-| l2.s;
---END---
---START---
-- Distance to line
SELECT l.s, l1.s, l.s <-> l1.s AS dist_sl, l1.s <-> l.s AS dist_ls FROM LSEG_TBL l, LINE_TBL l1;
---END---
---START---
-- Distance to line segment
SELECT l1.s, l2.s, l1.s <-> l2.s FROM LSEG_TBL l1, LSEG_TBL l2;
---END---
---START---
-- Distance to box
SELECT l.s, b.f1, l.s <-> b.f1 AS dist_sb, b.f1 <-> l.s AS dist_bs FROM LSEG_TBL l, BOX_TBL b;
---END---
---START---
-- Intersect with line segment
SELECT l.s, l1.s FROM LSEG_TBL l, LINE_TBL l1 WHERE l.s ?# l1.s;
---END---
---START---
-- Intersect with box
SELECT l.s, b.f1 FROM LSEG_TBL l, BOX_TBL b WHERE l.s ?# b.f1;
---END---
---START---
-- Intersection point with line segment
SELECT l1.s, l2.s, l1.s # l2.s FROM LSEG_TBL l1, LSEG_TBL l2;
---END---
---START---
-- Closest point to line segment
SELECT l1.s, l2.s, l1.s ## l2.s FROM LSEG_TBL l1, LSEG_TBL l2;
---END---
---START---
-- Closest point to box
SELECT l.s, b.f1, l.s ## b.f1 FROM LSEG_TBL l, BOX_TBL b;
---END---
---START---
-- On line
SELECT l.s, l1.s FROM LSEG_TBL l, LINE_TBL l1 WHERE l.s <@ l1.s;
---END---
---START---
-- On box
SELECT l.s, b.f1 FROM LSEG_TBL l, BOX_TBL b WHERE l.s <@ b.f1;
---END---
---START---
--
-- Boxes
--

SELECT box(f1) AS box FROM CIRCLE_TBL;
---END---
---START---
-- translation
SELECT b.f1 + p.f1 AS translation
   FROM BOX_TBL b, POINT_TBL p;
---END---
---START---
SELECT b.f1 - p.f1 AS translation
   FROM BOX_TBL b, POINT_TBL p;
---END---
---START---
-- Multiply with point
SELECT b.f1, p.f1, b.f1 * p.f1 FROM BOX_TBL b, POINT_TBL p WHERE p.f1[0] BETWEEN 1 AND 1000;
---END---
---START---
-- Overflow error
SELECT b.f1, p.f1, b.f1 * p.f1 FROM BOX_TBL b, POINT_TBL p WHERE p.f1[0] > 1000;
---END---
---START---
-- Divide by point
SELECT b.f1, p.f1, b.f1 / p.f1 FROM BOX_TBL b, POINT_TBL p WHERE p.f1[0] BETWEEN 1 AND 1000;
---END---
---START---
-- To box
SELECT f1::box
	FROM POINT_TBL;
---END---
---START---
SELECT bound_box(a.f1, b.f1)
	FROM BOX_TBL a, BOX_TBL b;
---END---
---START---
-- Below box
SELECT b1.f1, b2.f1, b1.f1 <^ b2.f1 FROM BOX_TBL b1, BOX_TBL b2;
---END---
---START---
-- Above box
SELECT b1.f1, b2.f1, b1.f1 >^ b2.f1 FROM BOX_TBL b1, BOX_TBL b2;
---END---
---START---
-- Intersection point with box
SELECT b1.f1, b2.f1, b1.f1 # b2.f1 FROM BOX_TBL b1, BOX_TBL b2;
---END---
---START---
-- Diagonal
SELECT f1, diagonal(f1) FROM BOX_TBL;
---END---
---START---
-- Distance to box
SELECT b1.f1, b2.f1, b1.f1 <-> b2.f1 FROM BOX_TBL b1, BOX_TBL b2;
---END---
---START---
--
-- Paths
--

-- Points
SELECT f1, npoints(f1) FROM PATH_TBL;
---END---
---START---
-- Area
SELECT f1, area(f1) FROM PATH_TBL;
---END---
---START---
-- Length
SELECT f1, @-@ f1 FROM PATH_TBL;
---END---
---START---
-- To polygon
SELECT f1, f1::polygon FROM PATH_TBL WHERE isclosed(f1);
---END---
---START---
-- Open path cannot be converted to polygon error
SELECT f1, f1::polygon FROM PATH_TBL WHERE isopen(f1);
---END---
---START---
-- Has points less than path
SELECT p1.f1, p2.f1 FROM PATH_TBL p1, PATH_TBL p2 WHERE p1.f1 < p2.f1;
---END---
---START---
-- Has points less than or equal to path
SELECT p1.f1, p2.f1 FROM PATH_TBL p1, PATH_TBL p2 WHERE p1.f1 <= p2.f1;
---END---
---START---
-- Has points equal to path
SELECT p1.f1, p2.f1 FROM PATH_TBL p1, PATH_TBL p2 WHERE p1.f1 = p2.f1;
---END---
---START---
-- Has points greater than or equal to path
SELECT p1.f1, p2.f1 FROM PATH_TBL p1, PATH_TBL p2 WHERE p1.f1 >= p2.f1;
---END---
---START---
-- Has points greater than path
SELECT p1.f1, p2.f1 FROM PATH_TBL p1, PATH_TBL p2 WHERE p1.f1 > p2.f1;
---END---
---START---
-- Add path
SELECT p1.f1, p2.f1, p1.f1 + p2.f1 FROM PATH_TBL p1, PATH_TBL p2;
---END---
---START---
-- Add point
SELECT p.f1, p1.f1, p.f1 + p1.f1 FROM PATH_TBL p, POINT_TBL p1;
---END---
---START---
-- Subtract point
SELECT p.f1, p1.f1, p.f1 - p1.f1 FROM PATH_TBL p, POINT_TBL p1;
---END---
---START---
-- Multiply with point
SELECT p.f1, p1.f1, p.f1 * p1.f1 FROM PATH_TBL p, POINT_TBL p1;
---END---
---START---
-- Divide by point
SELECT p.f1, p1.f1, p.f1 / p1.f1 FROM PATH_TBL p, POINT_TBL p1 WHERE p1.f1[0] BETWEEN 1 AND 1000;
---END---
---START---
-- Division by 0 error
SELECT p.f1, p1.f1, p.f1 / p1.f1 FROM PATH_TBL p, POINT_TBL p1 WHERE p1.f1 ~= '(0,0)'::point;
---END---
---START---
-- Distance to path
SELECT p1.f1, p2.f1, p1.f1 <-> p2.f1 FROM PATH_TBL p1, PATH_TBL p2;
---END---
---START---
--
-- Polygons
--

-- containment
SELECT p.f1, poly.f1, poly.f1 @> p.f1 AS contains
   FROM POLYGON_TBL poly, POINT_TBL p;
---END---
---START---
SELECT p.f1, poly.f1, p.f1 <@ poly.f1 AS contained
   FROM POLYGON_TBL poly, POINT_TBL p;
---END---
---START---
SELECT npoints(f1) AS npoints, f1 AS polygon
   FROM POLYGON_TBL;
---END---
---START---
SELECT polygon(f1)
   FROM BOX_TBL;
---END---
---START---
SELECT polygon(f1)
   FROM PATH_TBL WHERE isclosed(f1);
---END---
---START---
SELECT f1 AS open_path, polygon( pclose(f1)) AS polygon
   FROM PATH_TBL
   WHERE isopen(f1);
---END---
---START---
-- To box
SELECT f1, f1::box FROM POLYGON_TBL;
---END---
---START---
-- To path
SELECT f1, f1::path FROM POLYGON_TBL;
---END---
---START---
-- Same as polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 ~= p2.f1;
---END---
---START---
-- Contained by polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 <@ p2.f1;
---END---
---START---
-- Contains polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 @> p2.f1;
---END---
---START---
-- Overlap with polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 && p2.f1;
---END---
---START---
-- Left of polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 << p2.f1;
---END---
---START---
-- Overlap of left of polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 &< p2.f1;
---END---
---START---
-- Right of polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 >> p2.f1;
---END---
---START---
-- Overlap of right of polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 &> p2.f1;
---END---
---START---
-- Below polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 <<| p2.f1;
---END---
---START---
-- Overlap or below polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 &<| p2.f1;
---END---
---START---
-- Above polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 |>> p2.f1;
---END---
---START---
-- Overlap or above polygon
SELECT p1.f1, p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2 WHERE p1.f1 |&> p2.f1;
---END---
---START---
-- Distance to polygon
SELECT p1.f1, p2.f1, p1.f1 <-> p2.f1 FROM POLYGON_TBL p1, POLYGON_TBL p2;
---END---
---START---
--
-- Circles
--

SELECT circle(f1, 50.0)
   FROM POINT_TBL;
---END---
---START---
SELECT circle(f1)
   FROM BOX_TBL;
---END---
---START---
SELECT circle(f1)
   FROM POLYGON_TBL
   WHERE (# f1) >= 3;
---END---
---START---
SELECT c1.f1 AS circle, p1.f1 AS point, (p1.f1 <-> c1.f1) AS distance
   FROM CIRCLE_TBL c1, POINT_TBL p1
   WHERE (p1.f1 <-> c1.f1) > 0
   ORDER BY distance, area(c1.f1), p1.f1[0];
---END---
---START---
-- To polygon
SELECT f1, f1::polygon FROM CIRCLE_TBL WHERE f1 >= '<(0,0),1>';
---END---
---START---
-- To polygon with less points
SELECT f1, polygon(8, f1) FROM CIRCLE_TBL WHERE f1 >= '<(0,0),1>';
---END---
---START---
-- Error for insufficient number of points
SELECT f1, polygon(1, f1) FROM CIRCLE_TBL WHERE f1 >= '<(0,0),1>';
---END---
---START---
-- Zero radius error
SELECT f1, polygon(10, f1) FROM CIRCLE_TBL WHERE f1 < '<(0,0),1>';
---END---
---START---
-- Same as circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 ~= c2.f1;
---END---
---START---
-- Overlap with circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 && c2.f1;
---END---
---START---
-- Overlap or left of circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 &< c2.f1;
---END---
---START---
-- Left of circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 << c2.f1;
---END---
---START---
-- Right of circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 >> c2.f1;
---END---
---START---
-- Overlap or right of circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 &> c2.f1;
---END---
---START---
-- Contained by circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 <@ c2.f1;
---END---
---START---
-- Contain by circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 @> c2.f1;
---END---
---START---
-- Below circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 <<| c2.f1;
---END---
---START---
-- Above circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 |>> c2.f1;
---END---
---START---
-- Overlap or below circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 &<| c2.f1;
---END---
---START---
-- Overlap or above circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 |&> c2.f1;
---END---
---START---
-- Area equal with circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 = c2.f1;
---END---
---START---
-- Area not equal with circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 != c2.f1;
---END---
---START---
-- Area less than circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 < c2.f1;
---END---
---START---
-- Area greater than circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 > c2.f1;
---END---
---START---
-- Area less than or equal circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 <= c2.f1;
---END---
---START---
-- Area greater than or equal circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 >= c2.f1;
---END---
---START---
-- Area less than circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 < c2.f1;
---END---
---START---
-- Area greater than circle
SELECT c1.f1, c2.f1 FROM CIRCLE_TBL c1, CIRCLE_TBL c2 WHERE c1.f1 < c2.f1;
---END---
---START---
-- Add point
SELECT c.f1, p.f1, c.f1 + p.f1 FROM CIRCLE_TBL c, POINT_TBL p;
---END---
---START---
-- Subtract point
SELECT c.f1, p.f1, c.f1 - p.f1 FROM CIRCLE_TBL c, POINT_TBL p;
---END---
---START---
-- Multiply with point
SELECT c.f1, p.f1, c.f1 * p.f1 FROM CIRCLE_TBL c, POINT_TBL p;
---END---
---START---
-- Divide by point
SELECT c.f1, p.f1, c.f1 / p.f1 FROM CIRCLE_TBL c, POINT_TBL p WHERE p.f1[0] BETWEEN 1 AND 1000;
---END---
---START---
-- Overflow error
SELECT c.f1, p.f1, c.f1 / p.f1 FROM CIRCLE_TBL c, POINT_TBL p WHERE p.f1[0] > 1000;
---END---
---START---
-- Division by 0 error
SELECT c.f1, p.f1, c.f1 / p.f1 FROM CIRCLE_TBL c, POINT_TBL p WHERE p.f1 ~= '(0,0)'::point;
---END---
---START---
-- Distance to polygon
SELECT c.f1, p.f1, c.f1 <-> p.f1 FROM CIRCLE_TBL c, POLYGON_TBL p;
---END---
---START---
-- Check index behavior for circles

CREATE INDEX gcircleind ON circle_tbl USING gist (f1);
---END---
---START---
SELECT * FROM circle_tbl WHERE f1 && circle(point(1,-2), 1)
    ORDER BY area(f1);
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM circle_tbl WHERE f1 && circle(point(1,-2), 1)
    ORDER BY area(f1);
---END---
---START---
SELECT * FROM circle_tbl WHERE f1 && circle(point(1,-2), 1)
    ORDER BY area(f1);
---END---
---START---
-- Check index behavior for polygons

CREATE INDEX gpolygonind ON polygon_tbl USING gist (f1);
---END---
---START---
SELECT * FROM polygon_tbl WHERE f1 @> '((1,1),(2,2),(2,1))'::polygon
    ORDER BY (poly_center(f1))[0];
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT * FROM polygon_tbl WHERE f1 @> '((1,1),(2,2),(2,1))'::polygon
    ORDER BY (poly_center(f1))[0];
---END---
---START---
SELECT * FROM polygon_tbl WHERE f1 @> '((1,1),(2,2),(2,1))'::polygon
    ORDER BY (poly_center(f1))[0];
---END---
---START---
-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('(1', 'circle');
---END---
---START---
SELECT * FROM pg_input_error_info('1,', 'circle');
---END---
---START---
SELECT pg_input_is_valid('(1,2),-1', 'circle');
---END---
---START---
SELECT * FROM pg_input_error_info('(1,2),-1', 'circle');
---END---
