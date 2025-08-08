---START---
--
-- LSEG
-- Line segments
--

--DROP TABLE LSEG_TBL;
CREATE TABLE LSEG_TBL (s lseg);
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('[(1,2),(3,4)]');
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('(0,0),(6,6)');
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('10,-10 ,-3,-4');
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('[-1e6,2e2,3e5, -4e1]');
---END---
---START---
INSERT INTO LSEG_TBL VALUES (lseg(point(11, 22), point(33,44)));
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('[(-10,2),(-10,3)]');
---END---
---START---
-- vertical
INSERT INTO LSEG_TBL VALUES ('[(0,-20),(30,-20)]');
---END---
---START---
-- horizontal
INSERT INTO LSEG_TBL VALUES ('[(NaN,1),(NaN,90)]');
---END---
---START---
-- NaN

-- bad values for parser testing
INSERT INTO LSEG_TBL VALUES ('(3asdf,2 ,3,4r2)');
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('[1,2,3, 4');
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('[(,2),(3,4)]');
---END---
---START---
INSERT INTO LSEG_TBL VALUES ('[(1,2),(3,4)');
---END---
---START---
select * from LSEG_TBL;
---END---
---START---
-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('[(1,2),(3)]', 'lseg');
---END---
---START---
SELECT * FROM pg_input_error_info('[(1,2),(3)]', 'lseg');
---END---
