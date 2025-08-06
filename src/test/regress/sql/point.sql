---START---
--
-- POINT
--

-- avoid bit-exact output here because operations may not be bit-exact.
SET extra_float_digits = 0;
---END---
---START---

-- point_tbl was already created and filled in test_setup.sql.
-- Here we just try to insert bad values.

INSERT INTO POINT_TBL(f1) VALUES ('asdfasdf');
---END---
---START---

INSERT INTO POINT_TBL(f1) VALUES ('(10.0 10.0)');
---END---
---START---

INSERT INTO POINT_TBL(f1) VALUES ('(10.0, 10.0) x');
---END---
---START---

INSERT INTO POINT_TBL(f1) VALUES ('(10.0,10.0');
---END---
---START---

INSERT INTO POINT_TBL(f1) VALUES ('(10.0, 1e+500)');	-- Out of range


SELECT * FROM POINT_TBL;
---END---
---START---

-- left of
SELECT p.* FROM POINT_TBL p WHERE p.f1 << '(0.0, 0.0)';
---END---
---START---

-- right of
SELECT p.* FROM POINT_TBL p WHERE '(0.0,0.0)' >> p.f1;
---END---
---START---

-- above
SELECT p.* FROM POINT_TBL p WHERE '(0.0,0.0)' |>> p.f1;
---END---
---START---

-- below
SELECT p.* FROM POINT_TBL p WHERE p.f1 <<| '(0.0, 0.0)';
---END---
---START---

-- equal
SELECT p.* FROM POINT_TBL p WHERE p.f1 ~= '(5.1, 34.5)';
---END---
---START---

-- point in box
SELECT p.* FROM POINT_TBL p
   WHERE p.f1 <@ box '(0,0,100,100)';
---END---
---START---

SELECT p.* FROM POINT_TBL p
   WHERE box '(0,0,100,100)' @> p.f1;
---END---
---START---

SELECT p.* FROM POINT_TBL p
   WHERE not p.f1 <@ box '(0,0,100,100)';
---END---
---START---

SELECT p.* FROM POINT_TBL p
   WHERE p.f1 <@ path '[(0,0),(-10,0),(-10,10)]';
---END---
---START---

SELECT p.* FROM POINT_TBL p
   WHERE not box '(0,0,100,100)' @> p.f1;
---END---
---START---

SELECT p.f1, p.f1 <-> point '(0,0)' AS dist
   FROM POINT_TBL p
   ORDER BY dist;
---END---
---START---

SELECT p1.f1 AS point1, p2.f1 AS point2, p1.f1 <-> p2.f1 AS dist
   FROM POINT_TBL p1, POINT_TBL p2
   ORDER BY dist, p1.f1[0], p2.f1[0];
---END---
---START---

SELECT p1.f1 AS point1, p2.f1 AS point2
   FROM POINT_TBL p1, POINT_TBL p2
   WHERE (p1.f1 <-> p2.f1) > 3;
---END---
---START---

-- put distance result into output to allow sorting with GEQ optimizer - tgl 97/05/10
SELECT p1.f1 AS point1, p2.f1 AS point2, (p1.f1 <-> p2.f1) AS distance
   FROM POINT_TBL p1, POINT_TBL p2
   WHERE (p1.f1 <-> p2.f1) > 3 and p1.f1 << p2.f1
   ORDER BY distance, p1.f1[0], p2.f1[0];
---END---
---START---

-- put distance result into output to allow sorting with GEQ optimizer - tgl 97/05/10
SELECT p1.f1 AS point1, p2.f1 AS point2, (p1.f1 <-> p2.f1) AS distance
   FROM POINT_TBL p1, POINT_TBL p2
   WHERE (p1.f1 <-> p2.f1) > 3 and p1.f1 << p2.f1 and p1.f1 |>> p2.f1
   ORDER BY distance;
---END---
---START---

-- Test that GiST indexes provide same behavior as sequential scan
CREATE TABLE point_gist_tbl(f1 point);
---END---
---START---
INSERT INTO point_gist_tbl SELECT '(0,0)' FROM generate_series(0,1000);
---END---
---START---
CREATE INDEX point_gist_tbl_index ON point_gist_tbl USING gist (f1);
---END---
---START---
INSERT INTO point_gist_tbl VALUES ('(0.0000009,0.0000009)');
---END---
---START---
SET enable_seqscan TO true;
---END---
---START---
SET enable_indexscan TO false;
---END---
---START---
SET enable_bitmapscan TO false;
---END---
---START---
SELECT COUNT(*) FROM point_gist_tbl WHERE f1 ~= '(0.0000009,0.0000009)'::point;
---END---
---START---
SELECT COUNT(*) FROM point_gist_tbl WHERE f1 <@ '(0.0000009,0.0000009),(0.0000009,0.0000009)'::box;
---END---
---START---
SELECT COUNT(*) FROM point_gist_tbl WHERE f1 ~= '(0.0000018,0.0000018)'::point;
---END---
---START---
SET enable_seqscan TO false;
---END---
---START---
SET enable_indexscan TO true;
---END---
---START---
SET enable_bitmapscan TO true;
---END---
---START---
SELECT COUNT(*) FROM point_gist_tbl WHERE f1 ~= '(0.0000009,0.0000009)'::point;
---END---
---START---
SELECT COUNT(*) FROM point_gist_tbl WHERE f1 <@ '(0.0000009,0.0000009),(0.0000009,0.0000009)'::box;
---END---
---START---
SELECT COUNT(*) FROM point_gist_tbl WHERE f1 ~= '(0.0000018,0.0000018)'::point;
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
SELECT pg_input_is_valid('1,y', 'point');
---END---
---START---
SELECT * FROM pg_input_error_info('1,y', 'point');
---END---
---START---
drop table point_gist_tbl;
---END---