---START---
--
-- CIRCLE
--

-- Back off displayed precision a little bit to reduce platform-to-platform
-- variation in results.
SET extra_float_digits = -1;
---END---
---START---
CREATE TABLE circle_tbl (gemini_pk serial PRIMARY KEY, f1 circle);
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('<(5,1),3>');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('((1,2),100)');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES (' 1 , 3 , 5 ');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES (' ( ( 1 , 2 ) , 3 ) ');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES (' ( 100 , 200 ) , 10 ');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES (' < ( 100 , 1 ) , 115 > ');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('<(3,5),0>');
---END---
---START---
-- Zero radius

INSERT INTO CIRCLE_TBL VALUES ('<(3,5),NaN>');
---END---
---START---
-- NaN radius

-- bad values

INSERT INTO CIRCLE_TBL VALUES ('<(-100,0),-100>');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('<(100,200),10');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('<(100,200),10> x');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('1abc,3,5');
---END---
---START---
INSERT INTO CIRCLE_TBL VALUES ('(3,(1,2),3)');
---END---
---START---
SELECT * FROM CIRCLE_TBL;
---END---
---START---
SELECT center(f1) AS center
  FROM CIRCLE_TBL;
---END---
---START---
SELECT radius(f1) AS radius
  FROM CIRCLE_TBL;
---END---
---START---
SELECT diameter(f1) AS diameter
  FROM CIRCLE_TBL;
---END---
---START---
SELECT f1 FROM CIRCLE_TBL WHERE radius(f1) < 5;
---END---
---START---
SELECT f1 FROM CIRCLE_TBL WHERE diameter(f1) >= 10;
---END---
---START---
SELECT c1.f1 AS one, c2.f1 AS two, (c1.f1 <-> c2.f1) AS distance
  FROM CIRCLE_TBL c1, CIRCLE_TBL c2
  WHERE (c1.f1 < c2.f1) AND ((c1.f1 <-> c2.f1) > 0)
  ORDER BY distance, area(c1.f1), area(c2.f1);
---END---
