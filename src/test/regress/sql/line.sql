---START---
CREATE TABLE line_tbl (_gemini_pk serial PRIMARY KEY, s line);
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{0,-1,5}');
---END---
---START---
-- A == 0
INSERT INTO LINE_TBL VALUES ('{1,0,5}');
---END---
---START---
-- B == 0
INSERT INTO LINE_TBL VALUES ('{0,3,0}');
---END---
---START---
-- A == C == 0
INSERT INTO LINE_TBL VALUES (' (0,0), (6,6)');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('10,-10 ,-5,-4');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('[-1e6,2e2,3e5, -4e1]');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{3,NaN,5}');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{NaN,NaN,NaN}');
---END---
---START---
-- horizontal
INSERT INTO LINE_TBL VALUES ('[(1,3),(2,3)]');
---END---
---START---
-- vertical
INSERT INTO LINE_TBL VALUES (line(point '(3,1)', point '(3,2)'));
---END---
---START---
-- bad values for parser testing
INSERT INTO LINE_TBL VALUES ('{}');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{0');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{0,0}');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{0,0,1');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{0,0,1}');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('{0,0,1} x');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('(3asdf,2 ,3,4r2)');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('[1,2,3, 4');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('[(,2),(3,4)]');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('[(1,2),(3,4)');
---END---
---START---
INSERT INTO LINE_TBL VALUES ('[(1,2),(1,2)]');
---END---
---START---
INSERT INTO LINE_TBL VALUES (line(point '(1,0)', point '(1,0)'));
---END---
---START---
select * from LINE_TBL;
---END---
---START---
select '{nan, 1, nan}'::line = '{nan, 1, nan}'::line as true,
	   '{nan, 1, nan}'::line = '{nan, 2, nan}'::line as false;
---END---
---START---
-- test non-error-throwing API for some core types
SELECT pg_input_is_valid('{1, 1}', 'line');
---END---
---START---
SELECT * FROM pg_input_error_info('{1, 1}', 'line');
---END---
---START---
SELECT pg_input_is_valid('{0, 0, 0}', 'line');
---END---
---START---
SELECT * FROM pg_input_error_info('{0, 0, 0}', 'line');
---END---
---START---
SELECT pg_input_is_valid('{1, 1, a}', 'line');
---END---
---START---
SELECT * FROM pg_input_error_info('{1, 1, a}', 'line');
---END---
---START---
SELECT pg_input_is_valid('{1, 1, 1e400}', 'line');
---END---
---START---
SELECT * FROM pg_input_error_info('{1, 1, 1e400}', 'line');
---END---
---START---
SELECT pg_input_is_valid('(1, 1), (1, 1e400)', 'line');
---END---
---START---
SELECT * FROM pg_input_error_info('(1, 1), (1, 1e400)', 'line');
---END---
