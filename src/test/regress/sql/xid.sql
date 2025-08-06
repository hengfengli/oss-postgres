---START---
-- xid and xid8

-- values in range, in octal, decimal, hex
select '010'::xid,
       '42'::xid,
       '0xffffffff'::xid,
       '-1'::xid,
	   '010'::xid8,
	   '42'::xid8,
	   '0xffffffffffffffff'::xid8,
	   '-1'::xid8;
---END---
---START---

-- garbage values
select ''::xid;
---END---
---START---
select 'asdf'::xid;
---END---
---START---
select ''::xid8;
---END---
---START---
select 'asdf'::xid8;
---END---
---START---

-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('42', 'xid');
---END---
---START---
SELECT pg_input_is_valid('asdf', 'xid');
---END---
---START---
SELECT * FROM pg_input_error_info('0xffffffffff', 'xid');
---END---
---START---
SELECT pg_input_is_valid('42', 'xid8');
---END---
---START---
SELECT pg_input_is_valid('asdf', 'xid8');
---END---
---START---
SELECT * FROM pg_input_error_info('0xffffffffffffffffffff', 'xid8');
---END---
---START---

-- equality
select '1'::xid = '1'::xid;
---END---
---START---
select '1'::xid != '1'::xid;
---END---
---START---
select '1'::xid8 = '1'::xid8;
---END---
---START---
select '1'::xid8 != '1'::xid8;
---END---
---START---

-- conversion
select '1'::xid = '1'::xid8::xid;
---END---
---START---
select '1'::xid != '1'::xid8::xid;
---END---
---START---

-- we don't want relational operators for xid, due to use of modular arithmetic
select '1'::xid < '2'::xid;
---END---
---START---
select '1'::xid <= '2'::xid;
---END---
---START---
select '1'::xid > '2'::xid;
---END---
---START---
select '1'::xid >= '2'::xid;
---END---
---START---

-- we want them for xid8 though
select '1'::xid8 < '2'::xid8, '2'::xid8 < '2'::xid8, '2'::xid8 < '1'::xid8;
---END---
---START---
select '1'::xid8 <= '2'::xid8, '2'::xid8 <= '2'::xid8, '2'::xid8 <= '1'::xid8;
---END---
---START---
select '1'::xid8 > '2'::xid8, '2'::xid8 > '2'::xid8, '2'::xid8 > '1'::xid8;
---END---
---START---
select '1'::xid8 >= '2'::xid8, '2'::xid8 >= '2'::xid8, '2'::xid8 >= '1'::xid8;
---END---
---START---

-- we also have a 3way compare for btrees
select xid8cmp('1', '2'), xid8cmp('2', '2'), xid8cmp('2', '1');
---END---
---START---

-- min() and max() for xid8
create table xid8_t1 (x xid8);
---END---
---START---
insert into xid8_t1 values ('0'), ('010'), ('42'), ('0xffffffffffffffff'), ('-1');
---END---
---START---
select min(x), max(x) from xid8_t1;
---END---
---START---

-- xid8 has btree and hash opclasses
create index on xid8_t1 using btree(x);
---END---
---START---
create index on xid8_t1 using hash(x);
---END---
---START---
drop table xid8_t1;
---END---
---START---


-- pg_snapshot data type and related functions

-- Note: another set of tests similar to this exists in txid.sql, for a limited
-- time (the relevant functions share C code)

-- i/o
select '12:13:'::pg_snapshot;
---END---
---START---
select '12:18:14,16'::pg_snapshot;
---END---
---START---
select '12:16:14,14'::pg_snapshot;
---END---
---START---

-- errors
select '31:12:'::pg_snapshot;
---END---
---START---
select '0:1:'::pg_snapshot;
---END---
---START---
select '12:13:0'::pg_snapshot;
---END---
---START---
select '12:16:14,13'::pg_snapshot;
---END---
---START---

-- also try it with non-error-throwing API
select pg_input_is_valid('12:13:', 'pg_snapshot');
---END---
---START---
select pg_input_is_valid('31:12:', 'pg_snapshot');
---END---
---START---
select * from pg_input_error_info('31:12:', 'pg_snapshot');
---END---
---START---
select pg_input_is_valid('12:16:14,13', 'pg_snapshot');
---END---
---START---
select * from pg_input_error_info('12:16:14,13', 'pg_snapshot');
---END---
---START---

create table snapshot_test (
	nr	integer,
	snap	pg_snapshot
);
---END---
---START---

insert into snapshot_test values (1, '12:13:');
---END---
---START---
insert into snapshot_test values (2, '12:20:13,15,18');
---END---
---START---
insert into snapshot_test values (3, '100001:100009:100005,100007,100008');
---END---
---START---
insert into snapshot_test values (4, '100:150:101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131');
---END---
---START---
select snap from snapshot_test order by nr;
---END---
---START---

select  pg_snapshot_xmin(snap),
	pg_snapshot_xmax(snap),
	pg_snapshot_xip(snap)
from snapshot_test order by nr;
---END---
---START---

select id, pg_visible_in_snapshot(id::text::xid8, snap)
from snapshot_test, generate_series(11, 21) id
where nr = 2;
---END---
---START---

-- test bsearch
select id, pg_visible_in_snapshot(id::text::xid8, snap)
from snapshot_test, generate_series(90, 160) id
where nr = 4;
---END---
---START---

-- test current values also
select pg_current_xact_id() >= pg_snapshot_xmin(pg_current_snapshot());
---END---
---START---

-- we can't assume current is always less than xmax, however

select pg_visible_in_snapshot(pg_current_xact_id(), pg_current_snapshot());
---END---
---START---

-- test 64bitness

select pg_snapshot '1000100010001000:1000100010001100:1000100010001012,1000100010001013';
---END---
---START---
select pg_visible_in_snapshot('1000100010001012', '1000100010001000:1000100010001100:1000100010001012,1000100010001013');
---END---
---START---
select pg_visible_in_snapshot('1000100010001015', '1000100010001000:1000100010001100:1000100010001012,1000100010001013');
---END---
---START---

-- test 64bit overflow
SELECT pg_snapshot '1:9223372036854775807:3';
---END---
---START---
SELECT pg_snapshot '1:9223372036854775808:3';
---END---
---START---

-- test pg_current_xact_id_if_assigned
BEGIN;
---END---
---START---
SELECT pg_current_xact_id_if_assigned() IS NULL;
---END---
---START---
SELECT pg_current_xact_id() \gset
SELECT pg_current_xact_id_if_assigned() IS NOT DISTINCT FROM xid8 :'pg_current_xact_id';
---END---
---START---
COMMIT;
---END---
---START---

-- test xid status functions
BEGIN;
---END---
---START---
SELECT pg_current_xact_id() AS committed \gset
COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
SELECT pg_current_xact_id() AS rolledback \gset
ROLLBACK;
---END---
---START---

BEGIN;
---END---
---START---
SELECT pg_current_xact_id() AS inprogress \gset

SELECT pg_xact_status(:committed::text::xid8) AS committed;
---END---
---START---
SELECT pg_xact_status(:rolledback::text::xid8) AS rolledback;
---END---
---START---
SELECT pg_xact_status(:inprogress::text::xid8) AS inprogress;
---END---
---START---
SELECT pg_xact_status('1'::xid8); -- BootstrapTransactionId is always committed
SELECT pg_xact_status('2'::xid8); -- FrozenTransactionId is always committed
SELECT pg_xact_status('3'::xid8); -- in regress testing FirstNormalTransactionId will always be behind oldestXmin

COMMIT;
---END---
---START---

BEGIN;
---END---
---START---
CREATE FUNCTION test_future_xid_status(xid8)
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
  PERFORM pg_xact_status($1);
---END---
---START---
  RAISE EXCEPTION 'didn''t ERROR at xid in the future as expected';
---END---
---START---
EXCEPTION
  WHEN invalid_parameter_value THEN
    RAISE NOTICE 'Got expected error for xid in the future';
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---
SELECT test_future_xid_status((:inprogress + 10000)::text::xid8);
---END---
---START---
ROLLBACK;
---END---
---START---
drop table snapshot_test;
---END---
