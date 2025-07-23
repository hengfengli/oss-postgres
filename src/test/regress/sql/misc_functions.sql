---START---
-- directory paths and dlsuffix are passed to us in environment variables
\getenv libdir PG_LIBDIR
\getenv dlsuffix PG_DLSUFFIX

\set regresslib :libdir '/regress' :dlsuffix

--
-- num_nulls()
--

SELECT num_nonnulls(NULL);
---END---
---START---
SELECT num_nonnulls('1');
---END---
---START---
SELECT num_nonnulls(NULL::text);
---END---
---START---
SELECT num_nonnulls(NULL::text, NULL::int);
---END---
---START---
SELECT num_nonnulls(1, 2, NULL::text, NULL::point, '', int8 '9', 1.0 / NULL);
---END---
---START---
SELECT num_nonnulls(VARIADIC '{1,2,NULL,3}'::int[]);
---END---
---START---
SELECT num_nonnulls(VARIADIC '{"1","2","3","4"}'::text[]);
---END---
---START---
SELECT num_nonnulls(VARIADIC ARRAY(SELECT CASE WHEN i <> 40 THEN i END FROM generate_series(1, 100) i));
---END---
---START---

SELECT num_nulls(NULL);
---END---
---START---
SELECT num_nulls('1');
---END---
---START---
SELECT num_nulls(NULL::text);
---END---
---START---
SELECT num_nulls(NULL::text, NULL::int);
---END---
---START---
SELECT num_nulls(1, 2, NULL::text, NULL::point, '', int8 '9', 1.0 / NULL);
---END---
---START---
SELECT num_nulls(VARIADIC '{1,2,NULL,3}'::int[]);
---END---
---START---
SELECT num_nulls(VARIADIC '{"1","2","3","4"}'::text[]);
---END---
---START---
SELECT num_nulls(VARIADIC ARRAY(SELECT CASE WHEN i <> 40 THEN i END FROM generate_series(1, 100) i));
---END---
---START---

-- special cases
SELECT num_nonnulls(VARIADIC NULL::text[]);
---END---
---START---
SELECT num_nonnulls(VARIADIC '{}'::int[]);
---END---
---START---
SELECT num_nulls(VARIADIC NULL::text[]);
---END---
---START---
SELECT num_nulls(VARIADIC '{}'::int[]);
---END---
---START---

-- should fail, one or more arguments is required
SELECT num_nonnulls();
---END---
---START---
SELECT num_nulls();
---END---
---START---

--
-- canonicalize_path()
--

CREATE FUNCTION test_canonicalize_path(text)
   RETURNS text
   AS :'regresslib'
   LANGUAGE C STRICT IMMUTABLE;
---END---
---START---

SELECT test_canonicalize_path('/');
---END---
---START---
SELECT test_canonicalize_path('/./abc/def/');
---END---
---START---
SELECT test_canonicalize_path('/./../abc/def');
---END---
---START---
SELECT test_canonicalize_path('/./../../abc/def/');
---END---
---START---
SELECT test_canonicalize_path('/abc/.././def/ghi');
---END---
---START---
SELECT test_canonicalize_path('/abc/./../def/ghi//');
---END---
---START---
SELECT test_canonicalize_path('/abc/def/../..');
---END---
---START---
SELECT test_canonicalize_path('/abc/def/../../..');
---END---
---START---
SELECT test_canonicalize_path('/abc/def/../../../../ghi/jkl');
---END---
---START---
SELECT test_canonicalize_path('.');
---END---
---START---
SELECT test_canonicalize_path('./');
---END---
---START---
SELECT test_canonicalize_path('./abc/..');
---END---
---START---
SELECT test_canonicalize_path('abc/../');
---END---
---START---
SELECT test_canonicalize_path('abc/../def');
---END---
---START---
SELECT test_canonicalize_path('..');
---END---
---START---
SELECT test_canonicalize_path('../abc/def');
---END---
---START---
SELECT test_canonicalize_path('../abc/..');
---END---
---START---
SELECT test_canonicalize_path('../abc/../def');
---END---
---START---
SELECT test_canonicalize_path('../abc/../../def/ghi');
---END---
---START---
SELECT test_canonicalize_path('./abc/./def/.');
---END---
---START---
SELECT test_canonicalize_path('./abc/././def/.');
---END---
---START---
SELECT test_canonicalize_path('./abc/./def/.././ghi/../../../jkl/mno');
---END---
---START---

--
-- pg_log_backend_memory_contexts()
--
-- Memory contexts are logged and they are not returned to the function.
-- Furthermore, their contents can vary depending on the timing. However,
-- we can at least verify that the code doesn't fail, and that the
-- permissions are set properly.
--

SELECT pg_log_backend_memory_contexts(pg_backend_pid());
---END---
---START---

SELECT pg_log_backend_memory_contexts(pid) FROM pg_stat_activity
  WHERE backend_type = 'checkpointer';
---END---
---START---

CREATE ROLE regress_log_memory;
---END---
---START---

SELECT has_function_privilege('regress_log_memory',
  'pg_log_backend_memory_contexts(integer)', 'EXECUTE'); -- no

GRANT EXECUTE ON FUNCTION pg_log_backend_memory_contexts(integer)
  TO regress_log_memory;
---END---
---START---

SELECT has_function_privilege('regress_log_memory',
  'pg_log_backend_memory_contexts(integer)', 'EXECUTE'); -- yes

SET ROLE regress_log_memory;
---END---
---START---
SELECT pg_log_backend_memory_contexts(pg_backend_pid());
---END---
---START---
RESET ROLE;
---END---
---START---

REVOKE EXECUTE ON FUNCTION pg_log_backend_memory_contexts(integer)
  FROM regress_log_memory;
---END---
---START---

DROP ROLE regress_log_memory;
---END---
---START---

--
-- Test some built-in SRFs
--
-- The outputs of these are variable, so we can't just print their results
-- directly, but we can at least verify that the code doesn't fail.
--
select setting as segsize
from pg_settings where name = 'wal_segment_size'
\gset

select count(*) > 0 as ok from pg_ls_waldir();
---END---
---START---
-- Test ProjectSet as well as FunctionScan
select count(*) > 0 as ok from (select pg_ls_waldir()) ss;
---END---
---START---
-- Test not-run-to-completion cases.
select * from pg_ls_waldir() limit 0;
---END---
---START---
select count(*) > 0 as ok from (select * from pg_ls_waldir() limit 1) ss;
---END---
---START---
select (w).size = :segsize as ok
from (select pg_ls_waldir() w) ss where length((w).name) = 24 limit 1;
---END---
---START---

select count(*) >= 0 as ok from pg_ls_archive_statusdir();
---END---
---START---

-- pg_read_file()
select length(pg_read_file('postmaster.pid')) > 20;
---END---
---START---
select length(pg_read_file('postmaster.pid', 1, 20));
---END---
---START---
-- Test missing_ok
select pg_read_file('does not exist'); -- error
select pg_read_file('does not exist', true) IS NULL; -- ok
-- Test invalid argument
select pg_read_file('does not exist', 0, -1); -- error
select pg_read_file('does not exist', 0, -1, true); -- error

-- pg_read_binary_file()
select length(pg_read_binary_file('postmaster.pid')) > 20;
---END---
---START---
select length(pg_read_binary_file('postmaster.pid', 1, 20));
---END---
---START---
-- Test missing_ok
select pg_read_binary_file('does not exist'); -- error
select pg_read_binary_file('does not exist', true) IS NULL; -- ok
-- Test invalid argument
select pg_read_binary_file('does not exist', 0, -1); -- error
select pg_read_binary_file('does not exist', 0, -1, true); -- error

-- pg_stat_file()
select size > 20, isdir from pg_stat_file('postmaster.pid');
---END---
---START---

-- pg_ls_dir()
select * from (select pg_ls_dir('.') a) a where a = 'base' limit 1;
---END---
---START---
-- Test missing_ok (second argument)
select pg_ls_dir('does not exist', false, false); -- error
select pg_ls_dir('does not exist', true, false); -- ok
-- Test include_dot_dirs (third argument)
select count(*) = 1 as dot_found
  from pg_ls_dir('.', false, true) as ls where ls = '.';
---END---
---START---
select count(*) = 1 as dot_found
  from pg_ls_dir('.', false, false) as ls where ls = '.';
---END---
---START---

-- pg_timezone_names()
select * from (select (pg_timezone_names()).name) ptn where name='UTC' limit 1;
---END---
---START---

-- pg_tablespace_databases()
select count(*) > 0 from
  (select pg_tablespace_databases(oid) as pts from pg_tablespace
   where spcname = 'pg_default') pts
  join pg_database db on pts.pts = db.oid;
---END---
---START---

--
-- Test replication slot directory functions
--
CREATE ROLE regress_slot_dir_funcs;
---END---
---START---
-- Not available by default.
SELECT has_function_privilege('regress_slot_dir_funcs',
  'pg_ls_logicalsnapdir()', 'EXECUTE');
---END---
---START---
SELECT has_function_privilege('regress_slot_dir_funcs',
  'pg_ls_logicalmapdir()', 'EXECUTE');
---END---
---START---
SELECT has_function_privilege('regress_slot_dir_funcs',
  'pg_ls_replslotdir(text)', 'EXECUTE');
---END---
---START---
GRANT pg_monitor TO regress_slot_dir_funcs;
---END---
---START---
-- Role is now part of pg_monitor, so these are available.
SELECT has_function_privilege('regress_slot_dir_funcs',
  'pg_ls_logicalsnapdir()', 'EXECUTE');
---END---
---START---
SELECT has_function_privilege('regress_slot_dir_funcs',
  'pg_ls_logicalmapdir()', 'EXECUTE');
---END---
---START---
SELECT has_function_privilege('regress_slot_dir_funcs',
  'pg_ls_replslotdir(text)', 'EXECUTE');
---END---
---START---
DROP ROLE regress_slot_dir_funcs;
---END---
---START---

--
-- Test adding a support function to a subject function
--

CREATE FUNCTION my_int_eq(int, int) RETURNS bool
  LANGUAGE internal STRICT IMMUTABLE PARALLEL SAFE
  AS $$int4eq$$;
---END---
---START---

-- By default, planner does not think that's selective
EXPLAIN (COSTS OFF)
SELECT * FROM tenk1 a JOIN tenk1 b ON a.unique1 = b.unique1
WHERE my_int_eq(a.unique2, 42);
---END---
---START---

-- With support function that knows it's int4eq, we get a different plan
CREATE FUNCTION test_support_func(internal)
    RETURNS internal
    AS :'regresslib', 'test_support_func'
    LANGUAGE C STRICT;
---END---
---START---

ALTER FUNCTION my_int_eq(int, int) SUPPORT test_support_func;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT * FROM tenk1 a JOIN tenk1 b ON a.unique1 = b.unique1
WHERE my_int_eq(a.unique2, 42);
---END---
---START---

-- Also test non-default rowcount estimate
CREATE FUNCTION my_gen_series(int, int) RETURNS SETOF integer
  LANGUAGE internal STRICT IMMUTABLE PARALLEL SAFE
  AS $$generate_series_int4$$
  SUPPORT test_support_func;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT * FROM tenk1 a JOIN my_gen_series(1,1000) g ON a.unique1 = g;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT * FROM tenk1 a JOIN my_gen_series(1,10) g ON a.unique1 = g;
---END---
---START---

-- Test functions for control data
SELECT count(*) > 0 AS ok FROM pg_control_checkpoint();
---END---
---START---
SELECT count(*) > 0 AS ok FROM pg_control_init();
---END---
---START---
SELECT count(*) > 0 AS ok FROM pg_control_recovery();
---END---
---START---
SELECT count(*) > 0 AS ok FROM pg_control_system();
---END---
---START---

-- pg_split_walfile_name
SELECT * FROM pg_split_walfile_name(NULL);
---END---
---START---
SELECT * FROM pg_split_walfile_name('invalid');
---END---
---START---
SELECT segment_number > 0 AS ok_segment_number, timeline_id
  FROM pg_split_walfile_name('000000010000000100000000');
---END---
---START---
SELECT segment_number > 0 AS ok_segment_number, timeline_id
  FROM pg_split_walfile_name('ffffffFF00000001000000af');
---END---
