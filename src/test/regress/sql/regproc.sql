---START---
--
-- regproc
--

/* If objects exist, return oids */

CREATE ROLE regress_regrole_test;
---END---
---START---

-- without schemaname

SELECT regoper('||/');
---END---
---START---
SELECT regoperator('+(int4,int4)');
---END---
---START---
SELECT regproc('now');
---END---
---START---
SELECT regprocedure('abs(numeric)');
---END---
---START---
SELECT regclass('pg_class');
---END---
---START---
SELECT regtype('int4');
---END---
---START---
SELECT regcollation('"POSIX"');
---END---
---START---

SELECT to_regoper('||/');
---END---
---START---
SELECT to_regoperator('+(int4,int4)');
---END---
---START---
SELECT to_regproc('now');
---END---
---START---
SELECT to_regprocedure('abs(numeric)');
---END---
---START---
SELECT to_regclass('pg_class');
---END---
---START---
SELECT to_regtype('int4');
---END---
---START---
SELECT to_regcollation('"POSIX"');
---END---
---START---

-- with schemaname

SELECT regoper('pg_catalog.||/');
---END---
---START---
SELECT regoperator('pg_catalog.+(int4,int4)');
---END---
---START---
SELECT regproc('pg_catalog.now');
---END---
---START---
SELECT regprocedure('pg_catalog.abs(numeric)');
---END---
---START---
SELECT regclass('pg_catalog.pg_class');
---END---
---START---
SELECT regtype('pg_catalog.int4');
---END---
---START---
SELECT regcollation('pg_catalog."POSIX"');
---END---
---START---

SELECT to_regoper('pg_catalog.||/');
---END---
---START---
SELECT to_regproc('pg_catalog.now');
---END---
---START---
SELECT to_regprocedure('pg_catalog.abs(numeric)');
---END---
---START---
SELECT to_regclass('pg_catalog.pg_class');
---END---
---START---
SELECT to_regtype('pg_catalog.int4');
---END---
---START---
SELECT to_regcollation('pg_catalog."POSIX"');
---END---
---START---

-- schemaname not applicable

SELECT regrole('regress_regrole_test');
---END---
---START---
SELECT regrole('"regress_regrole_test"');
---END---
---START---
SELECT regnamespace('pg_catalog');
---END---
---START---
SELECT regnamespace('"pg_catalog"');
---END---
---START---

SELECT to_regrole('regress_regrole_test');
---END---
---START---
SELECT to_regrole('"regress_regrole_test"');
---END---
---START---
SELECT to_regnamespace('pg_catalog');
---END---
---START---
SELECT to_regnamespace('"pg_catalog"');
---END---
---START---

/* If objects don't exist, raise errors. */

DROP ROLE regress_regrole_test;
---END---
---START---

-- without schemaname

SELECT regoper('||//');
---END---
---START---
SELECT regoperator('++(int4,int4)');
---END---
---START---
SELECT regproc('know');
---END---
---START---
SELECT regprocedure('absinthe(numeric)');
---END---
---START---
SELECT regclass('pg_classes');
---END---
---START---
SELECT regtype('int3');
---END---
---START---

-- with schemaname

SELECT regoper('ng_catalog.||/');
---END---
---START---
SELECT regoperator('ng_catalog.+(int4,int4)');
---END---
---START---
SELECT regproc('ng_catalog.now');
---END---
---START---
SELECT regprocedure('ng_catalog.abs(numeric)');
---END---
---START---
SELECT regclass('ng_catalog.pg_class');
---END---
---START---
SELECT regtype('ng_catalog.int4');
---END---
---START---
\set VERBOSITY sqlstate \\ -- error message is encoding-dependent
SELECT regcollation('ng_catalog."POSIX"');
---END---
---START---
\set VERBOSITY default

-- schemaname not applicable

SELECT regrole('regress_regrole_test');
---END---
---START---
SELECT regrole('"regress_regrole_test"');
---END---
---START---
SELECT regrole('Nonexistent');
---END---
---START---
SELECT regrole('"Nonexistent"');
---END---
---START---
SELECT regrole('foo.bar');
---END---
---START---
SELECT regnamespace('Nonexistent');
---END---
---START---
SELECT regnamespace('"Nonexistent"');
---END---
---START---
SELECT regnamespace('foo.bar');
---END---
---START---

/* If objects don't exist, return NULL with no error. */

-- without schemaname

SELECT to_regoper('||//');
---END---
---START---
SELECT to_regoperator('++(int4,int4)');
---END---
---START---
SELECT to_regproc('know');
---END---
---START---
SELECT to_regprocedure('absinthe(numeric)');
---END---
---START---
SELECT to_regclass('pg_classes');
---END---
---START---
SELECT to_regtype('int3');
---END---
---START---
SELECT to_regcollation('notacollation');
---END---
---START---

-- with schemaname

SELECT to_regoper('ng_catalog.||/');
---END---
---START---
SELECT to_regoperator('ng_catalog.+(int4,int4)');
---END---
---START---
SELECT to_regproc('ng_catalog.now');
---END---
---START---
SELECT to_regprocedure('ng_catalog.abs(numeric)');
---END---
---START---
SELECT to_regclass('ng_catalog.pg_class');
---END---
---START---
SELECT to_regtype('ng_catalog.int4');
---END---
---START---
SELECT to_regcollation('ng_catalog."POSIX"');
---END---
---START---

-- schemaname not applicable

SELECT to_regrole('regress_regrole_test');
---END---
---START---
SELECT to_regrole('"regress_regrole_test"');
---END---
---START---
SELECT to_regrole('foo.bar');
---END---
---START---
SELECT to_regrole('Nonexistent');
---END---
---START---
SELECT to_regrole('"Nonexistent"');
---END---
---START---
SELECT to_regrole('foo.bar');
---END---
---START---
SELECT to_regnamespace('Nonexistent');
---END---
---START---
SELECT to_regnamespace('"Nonexistent"');
---END---
---START---
SELECT to_regnamespace('foo.bar');
---END---
---START---

-- Test soft-error API

SELECT * FROM pg_input_error_info('ng_catalog.pg_class', 'regclass');
---END---
---START---
SELECT pg_input_is_valid('ng_catalog."POSIX"', 'regcollation');
---END---
---START---
SELECT * FROM pg_input_error_info('no_such_config', 'regconfig');
---END---
---START---
SELECT * FROM pg_input_error_info('no_such_dictionary', 'regdictionary');
---END---
---START---
SELECT * FROM pg_input_error_info('Nonexistent', 'regnamespace');
---END---
---START---
SELECT * FROM pg_input_error_info('ng_catalog.||/', 'regoper');
---END---
---START---
SELECT * FROM pg_input_error_info('-', 'regoper');
---END---
---START---
SELECT * FROM pg_input_error_info('ng_catalog.+(int4,int4)', 'regoperator');
---END---
---START---
SELECT * FROM pg_input_error_info('-', 'regoperator');
---END---
---START---
SELECT * FROM pg_input_error_info('ng_catalog.now', 'regproc');
---END---
---START---
SELECT * FROM pg_input_error_info('ng_catalog.abs(numeric)', 'regprocedure');
---END---
---START---
SELECT * FROM pg_input_error_info('ng_catalog.abs(numeric', 'regprocedure');
---END---
---START---
SELECT * FROM pg_input_error_info('regress_regrole_test', 'regrole');
---END---
---START---
SELECT * FROM pg_input_error_info('no_such_type', 'regtype');
---END---
---START---

-- Some cases that should be soft errors, but are not yet
SELECT * FROM pg_input_error_info('incorrect type name syntax', 'regtype');
---END---
---START---
SELECT * FROM pg_input_error_info('numeric(1,2,3)', 'regtype');  -- bogus typmod
SELECT * FROM pg_input_error_info('way.too.many.names', 'regtype');
---END---
---START---
SELECT * FROM pg_input_error_info('no_such_catalog.schema.name', 'regtype');
---END---
