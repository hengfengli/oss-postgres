---START---
--
-- Test INSERT/UPDATE/DELETE RETURNING
--

-- Simple cases

CREATE SEQUENCE f1_seq;
---END---
---START---
CREATE TEMP TABLE foo (f1 int default nextval('f1_seq'), f2 text, f3 int default 42);
---END---
---START---

INSERT INTO foo (f2,f3)
  VALUES ('test', DEFAULT), ('More', 11), (upper('more'), 7+9)
  RETURNING *, f1+f3 AS sum;
---END---
---START---

SELECT * FROM foo;
---END---
---START---

UPDATE foo SET f2 = lower(f2), f3 = DEFAULT RETURNING foo.*, f1+f3 AS sum13;
---END---
---START---

SELECT * FROM foo;
---END---
---START---

DELETE FROM foo WHERE f1 > 2 RETURNING f3, f2, f1, least(f1,f3);
---END---
---START---

SELECT * FROM foo;
---END---
---START---

-- Subplans and initplans in the RETURNING list

INSERT INTO foo SELECT f1+10, f2, f3+99 FROM foo
  RETURNING *, f1+112 IN (SELECT q1 FROM int8_tbl) AS subplan,
    EXISTS(SELECT * FROM int4_tbl) AS initplan;
---END---
---START---

UPDATE foo SET f3 = f3 * 2
  WHERE f1 > 10
  RETURNING *, f1+112 IN (SELECT q1 FROM int8_tbl) AS subplan,
    EXISTS(SELECT * FROM int4_tbl) AS initplan;
---END---
---START---

DELETE FROM foo
  WHERE f1 > 10
  RETURNING *, f1+112 IN (SELECT q1 FROM int8_tbl) AS subplan,
    EXISTS(SELECT * FROM int4_tbl) AS initplan;
---END---
---START---

-- Joins

UPDATE foo SET f3 = f3*2
  FROM int4_tbl i
  WHERE foo.f1 + 123455 = i.f1
  RETURNING foo.*, i.f1 as "i.f1";
---END---
---START---

SELECT * FROM foo;
---END---
---START---

DELETE FROM foo
  USING int4_tbl i
  WHERE foo.f1 + 123455 = i.f1
  RETURNING foo.*, i.f1 as "i.f1";
---END---
---START---

SELECT * FROM foo;
---END---
---START---

-- Check inheritance cases

CREATE TEMP TABLE foochild (fc int) INHERITS (foo);
---END---
---START---

INSERT INTO foochild VALUES(123,'child',999,-123);
---END---
---START---

ALTER TABLE foo ADD COLUMN f4 int8 DEFAULT 99;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM foochild;
---END---
---START---

UPDATE foo SET f4 = f4 + f3 WHERE f4 = 99 RETURNING *;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM foochild;
---END---
---START---

UPDATE foo SET f3 = f3*2
  FROM int8_tbl i
  WHERE foo.f1 = i.q2
  RETURNING *;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM foochild;
---END---
---START---

DELETE FROM foo
  USING int8_tbl i
  WHERE foo.f1 = i.q2
  RETURNING *;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM foochild;
---END---
---START---

DROP TABLE foochild;
---END---
---START---

-- Rules and views

CREATE TEMP VIEW voo AS SELECT f1, f2 FROM foo;
---END---
---START---

CREATE RULE voo_i AS ON INSERT TO voo DO INSTEAD
  INSERT INTO foo VALUES(new.*, 57);
---END---
---START---

INSERT INTO voo VALUES(11,'zit');
---END---
---START---
-- fails:
INSERT INTO voo VALUES(12,'zoo') RETURNING *, f1*2;
---END---
---START---

-- fails, incompatible list:
CREATE OR REPLACE RULE voo_i AS ON INSERT TO voo DO INSTEAD
  INSERT INTO foo VALUES(new.*, 57) RETURNING *;
---END---
---START---

CREATE OR REPLACE RULE voo_i AS ON INSERT TO voo DO INSTEAD
  INSERT INTO foo VALUES(new.*, 57) RETURNING f1, f2;
---END---
---START---

-- should still work
INSERT INTO voo VALUES(13,'zit2');
---END---
---START---
-- works now
INSERT INTO voo VALUES(14,'zoo2') RETURNING *;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM voo;
---END---
---START---

CREATE OR REPLACE RULE voo_u AS ON UPDATE TO voo DO INSTEAD
  UPDATE foo SET f1 = new.f1, f2 = new.f2 WHERE f1 = old.f1
  RETURNING f1, f2;
---END---
---START---

update voo set f1 = f1 + 1 where f2 = 'zoo2';
---END---
---START---
update voo set f1 = f1 + 1 where f2 = 'zoo2' RETURNING *, f1*2;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM voo;
---END---
---START---

CREATE OR REPLACE RULE voo_d AS ON DELETE TO voo DO INSTEAD
  DELETE FROM foo WHERE f1 = old.f1
  RETURNING f1, f2;
---END---
---START---

DELETE FROM foo WHERE f1 = 13;
---END---
---START---
DELETE FROM foo WHERE f2 = 'zit' RETURNING *;
---END---
---START---

SELECT * FROM foo;
---END---
---START---
SELECT * FROM voo;
---END---
---START---

-- Try a join case

CREATE TEMP TABLE joinme (f2j text, other int);
---END---
---START---
INSERT INTO joinme VALUES('more', 12345);
---END---
---START---
INSERT INTO joinme VALUES('zoo2', 54321);
---END---
---START---
INSERT INTO joinme VALUES('other', 0);
---END---
---START---

CREATE TEMP VIEW joinview AS
  SELECT foo.*, other FROM foo JOIN joinme ON (f2 = f2j);
---END---
---START---

SELECT * FROM joinview;
---END---
---START---

CREATE RULE joinview_u AS ON UPDATE TO joinview DO INSTEAD
  UPDATE foo SET f1 = new.f1, f3 = new.f3
    FROM joinme WHERE f2 = f2j AND f2 = old.f2
    RETURNING foo.*, other;
---END---
---START---

UPDATE joinview SET f1 = f1 + 1 WHERE f3 = 57 RETURNING *, other + 1;
---END---
---START---

SELECT * FROM joinview;
---END---
---START---
SELECT * FROM foo;
---END---
---START---
SELECT * FROM voo;
---END---
