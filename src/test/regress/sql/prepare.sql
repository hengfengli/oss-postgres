---START---
-- Regression tests for prepareable statements. We query the content
-- of the pg_prepared_statements view as prepared statements are
-- created and removed.

SELECT name, statement, parameter_types, result_types FROM pg_prepared_statements;
---END---
---START---
PREPARE q1 AS SELECT 1 AS a;
---END---
---START---
EXECUTE q1;
---END---
---START---
SELECT name, statement, parameter_types, result_types FROM pg_prepared_statements;
---END---
---START---
-- should fail
PREPARE q1 AS SELECT 2;
---END---
---START---
-- should succeed
DEALLOCATE q1;
---END---
---START---
PREPARE q1 AS SELECT 2;
---END---
---START---
EXECUTE q1;
---END---
---START---
PREPARE q2 AS SELECT 2 AS b;
---END---
---START---
SELECT name, statement, parameter_types, result_types FROM pg_prepared_statements;
---END---
---START---
-- sql92 syntax
DEALLOCATE PREPARE q1;
---END---
---START---
SELECT name, statement, parameter_types, result_types FROM pg_prepared_statements;
---END---
---START---
DEALLOCATE PREPARE q2;
---END---
---START---
-- the view should return the empty set again
SELECT name, statement, parameter_types, result_types FROM pg_prepared_statements;
---END---
---START---
-- parameterized queries
PREPARE q2(text) AS
	SELECT datname, datistemplate, datallowconn
	FROM pg_database WHERE datname = $1;
---END---
---START---
EXECUTE q2('postgres');
---END---
---START---
PREPARE q3(text, int, float, boolean, smallint) AS
	SELECT * FROM tenk1 WHERE string4 = $1 AND (four = $2 OR
	ten = $3::bigint OR true = $4 OR odd = $5::int)
	ORDER BY unique1;
---END---
---START---
EXECUTE q3('AAAAxx', 5::smallint, 10.5::float, false, 4::bigint);
---END---
---START---
-- too few params
EXECUTE q3('bool');
---END---
---START---
-- too many params
EXECUTE q3('bytea', 5::smallint, 10.5::float, false, 4::bigint, true);
---END---
---START---
-- wrong param types
EXECUTE q3(5::smallint, 10.5::float, false, 4::bigint, 'bytea');
---END---
---START---
-- invalid type
PREPARE q4(nonexistenttype) AS SELECT $1;
---END---
---START---
-- create table as execute
PREPARE q5(int, text) AS
	SELECT * FROM tenk1 WHERE unique1 = $1 OR stringu1 = $2
	ORDER BY unique1;
---END---
---START---
CREATE TEMPORARY TABLE q5_prep_results AS EXECUTE q5(200, 'DTAAAA');
---END---
---START---
SELECT * FROM q5_prep_results;
---END---
---START---
CREATE TEMPORARY TABLE q5_prep_nodata AS EXECUTE q5(200, 'DTAAAA')
    WITH NO DATA;
---END---
---START---
SELECT * FROM q5_prep_nodata;
---END---
---START---
-- unknown or unspecified parameter types: should succeed
PREPARE q6 AS
    SELECT * FROM tenk1 WHERE unique1 = $1 AND stringu1 = $2;
---END---
---START---
PREPARE q7(unknown) AS
    SELECT * FROM road WHERE thepath = $1;
---END---
---START---
-- DML statements
PREPARE q8 AS
    UPDATE tenk1 SET stringu1 = $2 WHERE unique1 = $1;
---END---
---START---
SELECT name, statement, parameter_types, result_types FROM pg_prepared_statements
    ORDER BY name;
---END---
---START---
-- test DEALLOCATE ALL;
DEALLOCATE ALL;
---END---
---START---
SELECT name, statement, parameter_types FROM pg_prepared_statements
    ORDER BY name;
---END---
