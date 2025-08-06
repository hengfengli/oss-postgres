---START---
--
-- SP-GiST index tests
--

CREATE TABLE quad_point_tbl AS
    SELECT point(unique1,unique2) AS p FROM tenk1;
---END---
---START---

INSERT INTO quad_point_tbl
    SELECT '(333.0,400.0)'::point FROM generate_series(1,1000);
---END---
---START---

INSERT INTO quad_point_tbl VALUES (NULL), (NULL), (NULL);
---END---
---START---

CREATE INDEX sp_quad_ind ON quad_point_tbl USING spgist (p);
---END---
---START---

CREATE TABLE kd_point_tbl AS SELECT * FROM quad_point_tbl;
---END---
---START---

CREATE INDEX sp_kd_ind ON kd_point_tbl USING spgist (p kd_point_ops);
---END---
---START---

CREATE TABLE radix_text_tbl AS
    SELECT name AS t FROM road WHERE name !~ '^[0-9]';
---END---
---START---

INSERT INTO radix_text_tbl
    SELECT 'P0123456789abcdef' FROM generate_series(1,1000);
---END---
---START---
INSERT INTO radix_text_tbl VALUES ('P0123456789abcde');
---END---
---START---
INSERT INTO radix_text_tbl VALUES ('P0123456789abcdefF');
---END---
---START---

CREATE INDEX sp_radix_ind ON radix_text_tbl USING spgist (t);
---END---
---START---

-- get non-indexed results for comparison purposes

SET enable_seqscan = ON;
---END---
---START---
SET enable_indexscan = OFF;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p IS NULL;
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---

SELECT count(*) FROM quad_point_tbl;
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---

SELECT count(*) FROM quad_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---

CREATE TABLE quad_point_tbl_ord_seq1 AS
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM quad_point_tbl;
---END---
---START---

CREATE TABLE quad_point_tbl_ord_seq2 AS
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---

CREATE TABLE quad_point_tbl_ord_seq3 AS
SELECT row_number() OVER (ORDER BY p <-> '333,400') n, p <-> '333,400' dist, p
FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdef';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcde';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdefF';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t <    'Aztec                         Ct  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t <=   'Aztec                         Ct  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t =    'Aztec                         Ct  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t =    'Worth                         St  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t >=   'Worth                         St  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t ~>=~ 'Worth                         St  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t >    'Worth                         St  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t ~>~  'Worth                         St  ';
---END---
---START---

SELECT count(*) FROM radix_text_tbl WHERE t ^@  'Worth';
---END---
---START---

-- Now check the results from plain indexscan
SET enable_seqscan = OFF;
---END---
---START---
SET enable_indexscan = ON;
---END---
---START---
SET enable_bitmapscan = OFF;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p IS NULL;
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p IS NULL;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl;
---END---
---START---
SELECT count(*) FROM quad_point_tbl;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM quad_point_tbl;
---END---
---START---
CREATE TABLE quad_point_tbl_ord_idx1 AS
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM quad_point_tbl;
---END---
---START---
SELECT * FROM quad_point_tbl_ord_seq1 seq FULL JOIN quad_point_tbl_ord_idx1 idx
ON seq.n = idx.n
WHERE seq.dist IS DISTINCT FROM idx.dist;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
CREATE TABLE quad_point_tbl_ord_idx2 AS
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
SELECT * FROM quad_point_tbl_ord_seq2 seq FULL JOIN quad_point_tbl_ord_idx2 idx
ON seq.n = idx.n
WHERE seq.dist IS DISTINCT FROM idx.dist;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT row_number() OVER (ORDER BY p <-> '333,400') n, p <-> '333,400' dist, p
FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---
CREATE TABLE quad_point_tbl_ord_idx3 AS
SELECT row_number() OVER (ORDER BY p <-> '333,400') n, p <-> '333,400' dist, p
FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---
SELECT * FROM quad_point_tbl_ord_seq3 seq FULL JOIN quad_point_tbl_ord_idx3 idx
ON seq.n = idx.n
WHERE seq.dist IS DISTINCT FROM idx.dist;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM kd_point_tbl;
---END---
---START---
CREATE TABLE kd_point_tbl_ord_idx1 AS
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM kd_point_tbl;
---END---
---START---
SELECT * FROM quad_point_tbl_ord_seq1 seq FULL JOIN kd_point_tbl_ord_idx1 idx
ON seq.n = idx.n
WHERE seq.dist IS DISTINCT FROM idx.dist;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM kd_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
CREATE TABLE kd_point_tbl_ord_idx2 AS
SELECT row_number() OVER (ORDER BY p <-> '0,0') n, p <-> '0,0' dist, p
FROM kd_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
SELECT * FROM quad_point_tbl_ord_seq2 seq FULL JOIN kd_point_tbl_ord_idx2 idx
ON seq.n = idx.n
WHERE seq.dist IS DISTINCT FROM idx.dist;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT row_number() OVER (ORDER BY p <-> '333,400') n, p <-> '333,400' dist, p
FROM kd_point_tbl WHERE p IS NOT NULL;
---END---
---START---
CREATE TABLE kd_point_tbl_ord_idx3 AS
SELECT row_number() OVER (ORDER BY p <-> '333,400') n, p <-> '333,400' dist, p
FROM kd_point_tbl WHERE p IS NOT NULL;
---END---
---START---
SELECT * FROM quad_point_tbl_ord_seq3 seq FULL JOIN kd_point_tbl_ord_idx3 idx
ON seq.n = idx.n
WHERE seq.dist IS DISTINCT FROM idx.dist;
---END---
---START---

-- test KNN scan with included columns
-- the distance numbers are not exactly the same across platforms
SET extra_float_digits = 0;
---END---
---START---
CREATE INDEX ON quad_point_tbl_ord_seq1 USING spgist(p) INCLUDE(dist);
---END---
---START---
EXPLAIN (COSTS OFF)
SELECT p, dist FROM quad_point_tbl_ord_seq1 ORDER BY p <-> '0,0' LIMIT 10;
---END---
---START---
SELECT p, dist FROM quad_point_tbl_ord_seq1 ORDER BY p <-> '0,0' LIMIT 10;
---END---
---START---
RESET extra_float_digits;
---END---
---START---

-- check ORDER BY distance to NULL
SELECT (SELECT p FROM kd_point_tbl ORDER BY p <-> pt, p <-> '0,0' LIMIT 1)
FROM (VALUES (point '1,2'), (NULL), ('1234,5678')) pts(pt);
---END---
---START---


EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdef';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdef';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcde';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcde';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdefF';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdefF';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t <    'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t <    'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t <=   'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t <=   'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t =    'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t =    'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t =    'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t =    'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t >=   'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t >=   'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~>=~ 'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~>=~ 'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t >    'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t >    'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~>~  'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~>~  'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ^@	 'Worth';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ^@	 'Worth';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE starts_with(t, 'Worth');
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE starts_with(t, 'Worth');
---END---
---START---

-- Now check the results from bitmap indexscan
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
SELECT count(*) FROM quad_point_tbl WHERE p IS NULL;
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p IS NULL;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p IS NOT NULL;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl;
---END---
---START---
SELECT count(*) FROM quad_point_tbl;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM quad_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---
SELECT count(*) FROM quad_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p <@ box '(200,200,1000,1000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE box '(200,200,1000,1000)' @> p;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p << '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p >> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p <<| '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p |>> '(5000, 4000)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM kd_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---
SELECT count(*) FROM kd_point_tbl WHERE p ~= '(4585, 365)';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdef';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdef';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcde';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcde';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdefF';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t = 'P0123456789abcdefF';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t <    'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t <    'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t <=   'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t <=   'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t =    'Aztec                         Ct  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t =    'Aztec                         Ct  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t =    'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t =    'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t >=   'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t >=   'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~>=~ 'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~>=~ 'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t >    'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t >    'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ~>~  'Worth                         St  ';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ~>~  'Worth                         St  ';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE t ^@	 'Worth';
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE t ^@	 'Worth';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM radix_text_tbl WHERE starts_with(t, 'Worth');
---END---
---START---
SELECT count(*) FROM radix_text_tbl WHERE starts_with(t, 'Worth');
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
drop table if exists quad_point_tbl_ord_seq1, quad_point_tbl_ord_seq2, quad_point_tbl_ord_seq3;
drop table if exists quad_point_tbl_ord_idx1, quad_point_tbl_ord_idx2, quad_point_tbl_ord_idx3;
drop table if exists kd_point_tbl_ord_idx1, kd_point_tbl_ord_idx2, kd_point_tbl_ord_idx3;
---END---
