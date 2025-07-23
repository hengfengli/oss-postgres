---START---
--
-- PATH
--

--DROP TABLE PATH_TBL;
---END---
---START---

CREATE TABLE PATH_TBL (f1 path);
---END---
---START---

INSERT INTO PATH_TBL VALUES ('[(1,2),(3,4)]');
---END---
---START---

INSERT INTO PATH_TBL VALUES (' ( ( 1 , 2 ) , ( 3 , 4 ) ) ');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('[ (0,0),(3,0),(4,5),(1,6) ]');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('((1,2) ,(3,4 ))');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('1,2 ,3,4 ');
---END---
---START---

INSERT INTO PATH_TBL VALUES (' [1,2,3, 4] ');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('((10,20))');	-- Only one point

INSERT INTO PATH_TBL VALUES ('[ 11,12,13,14 ]');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('( 11,12,13,14) ');
---END---
---START---

-- bad values for parser testing
INSERT INTO PATH_TBL VALUES ('[]');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('[(,2),(3,4)]');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('[(1,2),(3,4)');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('(1,2,3,4');
---END---
---START---

INSERT INTO PATH_TBL VALUES ('(1,2),(3,4)]');
---END---
---START---

SELECT f1 AS open_path FROM PATH_TBL WHERE isopen(f1);
---END---
---START---

SELECT f1 AS closed_path FROM PATH_TBL WHERE isclosed(f1);
---END---
---START---

SELECT pclose(f1) AS closed_path FROM PATH_TBL;
---END---
---START---

SELECT popen(f1) AS open_path FROM PATH_TBL;
---END---
---START---

-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('[(1,2),(3)]', 'path');
---END---
---START---
SELECT * FROM pg_input_error_info('[(1,2),(3)]', 'path');
---END---
---START---
SELECT pg_input_is_valid('[(1,2,6),(3,4,6)]', 'path');
---END---
---START---
SELECT * FROM pg_input_error_info('[(1,2,6),(3,4,6)]', 'path');
---END---
