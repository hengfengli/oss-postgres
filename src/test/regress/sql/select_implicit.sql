---START---
CREATE TABLE test_missing_target (gemini_pk serial PRIMARY KEY, a integer, b integer, c varchar, d varchar);
---END---
---START---
INSERT INTO test_missing_target VALUES (0, 1, 'XXXX', 'A');
---END---
---START---
INSERT INTO test_missing_target VALUES (1, 2, 'ABAB', 'b');
---END---
---START---
INSERT INTO test_missing_target VALUES (2, 2, 'ABAB', 'c');
---END---
---START---
INSERT INTO test_missing_target VALUES (3, 3, 'BBBB', 'D');
---END---
---START---
INSERT INTO test_missing_target VALUES (4, 3, 'BBBB', 'e');
---END---
---START---
INSERT INTO test_missing_target VALUES (5, 3, 'bbbb', 'F');
---END---
---START---
INSERT INTO test_missing_target VALUES (6, 4, 'cccc', 'g');
---END---
---START---
INSERT INTO test_missing_target VALUES (7, 4, 'cccc', 'h');
---END---
---START---
INSERT INTO test_missing_target VALUES (8, 4, 'CCCC', 'I');
---END---
---START---
INSERT INTO test_missing_target VALUES (9, 4, 'CCCC', 'j');
---END---
---START---
--   w/ existing GROUP BY target
SELECT c, count(*) FROM test_missing_target GROUP BY test_missing_target.c ORDER BY c;
---END---
---START---
--   w/o existing GROUP BY target using a relation name in GROUP BY clause
SELECT count(*) FROM test_missing_target GROUP BY test_missing_target.c ORDER BY c;
---END---
---START---
--   w/o existing GROUP BY target and w/o existing a different ORDER BY target
--   failure expected
SELECT count(*) FROM test_missing_target GROUP BY a ORDER BY b;
---END---
---START---
--   w/o existing GROUP BY target and w/o existing same ORDER BY target
SELECT count(*) FROM test_missing_target GROUP BY b ORDER BY b;
---END---
---START---
--   w/ existing GROUP BY target using a relation name in target
SELECT test_missing_target.b, count(*)
  FROM test_missing_target GROUP BY b ORDER BY b;
---END---
---START---
--   w/o existing GROUP BY target
SELECT c FROM test_missing_target ORDER BY a;
---END---
---START---
--   w/o existing ORDER BY target
SELECT count(*) FROM test_missing_target GROUP BY b ORDER BY b desc;
---END---
---START---
--   group using reference number
SELECT count(*) FROM test_missing_target ORDER BY 1 desc;
---END---
---START---
--   order using reference number
SELECT c, count(*) FROM test_missing_target GROUP BY 1 ORDER BY 1;
---END---
---START---
--   group using reference number out of range
--   failure expected
SELECT c, count(*) FROM test_missing_target GROUP BY 3;
---END---
---START---
--   group w/o existing GROUP BY and ORDER BY target under ambiguous condition
--   failure expected
SELECT count(*) FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY b ORDER BY b;
---END---
---START---
--   order w/ target under ambiguous condition
--   failure NOT expected
SELECT a, a FROM test_missing_target
	ORDER BY a;
---END---
---START---
--   order expression w/ target under ambiguous condition
--   failure NOT expected
SELECT a/2, a/2 FROM test_missing_target
	ORDER BY a/2;
---END---
---START---
--   group expression w/ target under ambiguous condition
--   failure NOT expected
SELECT a/2, a/2 FROM test_missing_target
	GROUP BY a/2 ORDER BY a/2;
---END---
---START---
--   group w/ existing GROUP BY target under ambiguous condition
SELECT x.b, count(*) FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY x.b ORDER BY x.b;
---END---
---START---
--   group w/o existing GROUP BY target under ambiguous condition
SELECT count(*) FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY x.b ORDER BY x.b;
---END---
---START---
--   group w/o existing GROUP BY target under ambiguous condition
--   into a table
CREATE TABLE test_missing_target2 AS
SELECT count(*)
FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY x.b ORDER BY x.b;
---END---
---START---
SELECT * FROM test_missing_target2;
---END---
---START---
--  Functions and expressions

--   w/ existing GROUP BY target
SELECT a%2, count(b) FROM test_missing_target
GROUP BY test_missing_target.a%2
ORDER BY test_missing_target.a%2;
---END---
---START---
--   w/o existing GROUP BY target using a relation name in GROUP BY clause
SELECT count(c) FROM test_missing_target
GROUP BY lower(test_missing_target.c)
ORDER BY lower(test_missing_target.c);
---END---
---START---
--   w/o existing GROUP BY target and w/o existing a different ORDER BY target
--   failure expected
SELECT count(a) FROM test_missing_target GROUP BY a ORDER BY b;
---END---
---START---
--   w/o existing GROUP BY target and w/o existing same ORDER BY target
SELECT count(b) FROM test_missing_target GROUP BY b/2 ORDER BY b/2;
---END---
---START---
--   w/ existing GROUP BY target using a relation name in target
SELECT lower(test_missing_target.c), count(c)
  FROM test_missing_target GROUP BY lower(c) ORDER BY lower(c);
---END---
---START---
--   w/o existing GROUP BY target
SELECT a FROM test_missing_target ORDER BY upper(d);
---END---
---START---
--   w/o existing ORDER BY target
SELECT count(b) FROM test_missing_target
	GROUP BY (b + 1) / 2 ORDER BY (b + 1) / 2 desc;
---END---
---START---
--   group w/o existing GROUP BY and ORDER BY target under ambiguous condition
--   failure expected
SELECT count(x.a) FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY b/2 ORDER BY b/2;
---END---
---START---
--   group w/ existing GROUP BY target under ambiguous condition
SELECT x.b/2, count(x.b) FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY x.b/2 ORDER BY x.b/2;
---END---
---START---
--   group w/o existing GROUP BY target under ambiguous condition
--   failure expected due to ambiguous b in count(b)
SELECT count(b) FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY x.b/2;
---END---
---START---
--   group w/o existing GROUP BY target under ambiguous condition
--   into a table
CREATE TABLE test_missing_target3 AS
SELECT count(x.b)
FROM test_missing_target x, test_missing_target y
	WHERE x.a = y.a
	GROUP BY x.b/2 ORDER BY x.b/2;
---END---
---START---
SELECT * FROM test_missing_target3;
---END---
---START---
--   Cleanup
DROP TABLE test_missing_target;
---END---
---START---
DROP TABLE test_missing_target2;
---END---
---START---
DROP TABLE test_missing_target3;
---END---
