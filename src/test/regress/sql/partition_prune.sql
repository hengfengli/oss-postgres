---START---
--
-- Test partitioning planner code
--

-- Force generic plans to be used for all prepared statements in this file.
set plan_cache_mode = force_generic_plan;
---END---
---START---

create table lp (a char) partition by list (a);
---END---
---START---
create table lp_default partition of lp default;
---END---
---START---
create table lp_ef partition of lp for values in ('e', 'f');
---END---
---START---
create table lp_ad partition of lp for values in ('a', 'd');
---END---
---START---
create table lp_bc partition of lp for values in ('b', 'c');
---END---
---START---
create table lp_g partition of lp for values in ('g');
---END---
---START---
create table lp_null partition of lp for values in (null);
---END---
---START---
explain (costs off) select * from lp;
---END---
---START---
explain (costs off) select * from lp where a > 'a' and a < 'd';
---END---
---START---
explain (costs off) select * from lp where a > 'a' and a <= 'd';
---END---
---START---
explain (costs off) select * from lp where a = 'a';
---END---
---START---
explain (costs off) select * from lp where 'a' = a;	/* commuted */
explain (costs off) select * from lp where a is not null;
---END---
---START---
explain (costs off) select * from lp where a is null;
---END---
---START---
explain (costs off) select * from lp where a = 'a' or a = 'c';
---END---
---START---
explain (costs off) select * from lp where a is not null and (a = 'a' or a = 'c');
---END---
---START---
explain (costs off) select * from lp where a <> 'g';
---END---
---START---
explain (costs off) select * from lp where a <> 'a' and a <> 'd';
---END---
---START---
explain (costs off) select * from lp where a not in ('a', 'd');
---END---
---START---

-- collation matches the partitioning collation, pruning works
create table coll_pruning (a text collate "C") partition by list (a);
---END---
---START---
create table coll_pruning_a partition of coll_pruning for values in ('a');
---END---
---START---
create table coll_pruning_b partition of coll_pruning for values in ('b');
---END---
---START---
create table coll_pruning_def partition of coll_pruning default;
---END---
---START---
explain (costs off) select * from coll_pruning where a collate "C" = 'a' collate "C";
---END---
---START---
-- collation doesn't match the partitioning collation, no pruning occurs
explain (costs off) select * from coll_pruning where a collate "POSIX" = 'a' collate "POSIX";
---END---
---START---

create table rlp (a int, b varchar) partition by range (a);
---END---
---START---
create table rlp_default partition of rlp default partition by list (a);
---END---
---START---
create table rlp_default_default partition of rlp_default default;
---END---
---START---
create table rlp_default_10 partition of rlp_default for values in (10);
---END---
---START---
create table rlp_default_30 partition of rlp_default for values in (30);
---END---
---START---
create table rlp_default_null partition of rlp_default for values in (null);
---END---
---START---
create table rlp1 partition of rlp for values from (minvalue) to (1);
---END---
---START---
create table rlp2 partition of rlp for values from (1) to (10);
---END---
---START---

create table rlp3 (b varchar, a int) partition by list (b varchar_ops);
---END---
---START---
create table rlp3_default partition of rlp3 default;
---END---
---START---
create table rlp3abcd partition of rlp3 for values in ('ab', 'cd');
---END---
---START---
create table rlp3efgh partition of rlp3 for values in ('ef', 'gh');
---END---
---START---
create table rlp3nullxy partition of rlp3 for values in (null, 'xy');
---END---
---START---
alter table rlp attach partition rlp3 for values from (15) to (20);
---END---
---START---

create table rlp4 partition of rlp for values from (20) to (30) partition by range (a);
---END---
---START---
create table rlp4_default partition of rlp4 default;
---END---
---START---
create table rlp4_1 partition of rlp4 for values from (20) to (25);
---END---
---START---
create table rlp4_2 partition of rlp4 for values from (25) to (29);
---END---
---START---

create table rlp5 partition of rlp for values from (31) to (maxvalue) partition by range (a);
---END---
---START---
create table rlp5_default partition of rlp5 default;
---END---
---START---
create table rlp5_1 partition of rlp5 for values from (31) to (40);
---END---
---START---

explain (costs off) select * from rlp where a < 1;
---END---
---START---
explain (costs off) select * from rlp where 1 > a;	/* commuted */
explain (costs off) select * from rlp where a <= 1;
---END---
---START---
explain (costs off) select * from rlp where a = 1;
---END---
---START---
explain (costs off) select * from rlp where a = 1::bigint;		/* same as above */
explain (costs off) select * from rlp where a = 1::numeric;		/* no pruning */
explain (costs off) select * from rlp where a <= 10;
---END---
---START---
explain (costs off) select * from rlp where a > 10;
---END---
---START---
explain (costs off) select * from rlp where a < 15;
---END---
---START---
explain (costs off) select * from rlp where a <= 15;
---END---
---START---
explain (costs off) select * from rlp where a > 15 and b = 'ab';
---END---
---START---
explain (costs off) select * from rlp where a = 16;
---END---
---START---
explain (costs off) select * from rlp where a = 16 and b in ('not', 'in', 'here');
---END---
---START---
explain (costs off) select * from rlp where a = 16 and b < 'ab';
---END---
---START---
explain (costs off) select * from rlp where a = 16 and b <= 'ab';
---END---
---START---
explain (costs off) select * from rlp where a = 16 and b is null;
---END---
---START---
explain (costs off) select * from rlp where a = 16 and b is not null;
---END---
---START---
explain (costs off) select * from rlp where a is null;
---END---
---START---
explain (costs off) select * from rlp where a is not null;
---END---
---START---
explain (costs off) select * from rlp where a > 30;
---END---
---START---
explain (costs off) select * from rlp where a = 30;	/* only default is scanned */
explain (costs off) select * from rlp where a <= 31;
---END---
---START---
explain (costs off) select * from rlp where a = 1 or a = 7;
---END---
---START---
explain (costs off) select * from rlp where a = 1 or b = 'ab';
---END---
---START---

explain (costs off) select * from rlp where a > 20 and a < 27;
---END---
---START---
explain (costs off) select * from rlp where a = 29;
---END---
---START---
explain (costs off) select * from rlp where a >= 29;
---END---
---START---
explain (costs off) select * from rlp where a < 1 or (a > 20 and a < 25);
---END---
---START---

-- where clause contradicts sub-partition's constraint
explain (costs off) select * from rlp where a = 20 or a = 40;
---END---
---START---
explain (costs off) select * from rlp3 where a = 20;   /* empty */

-- redundant clauses are eliminated
explain (costs off) select * from rlp where a > 1 and a = 10;	/* only default */
explain (costs off) select * from rlp where a > 1 and a >=15;	/* rlp3 onwards, including default */
explain (costs off) select * from rlp where a = 1 and a = 3;	/* empty */
explain (costs off) select * from rlp where (a = 1 and a = 3) or (a > 1 and a = 15);
---END---
---START---

-- multi-column keys
create table mc3p (a int, b int, c int) partition by range (a, abs(b), c);
---END---
---START---
create table mc3p_default partition of mc3p default;
---END---
---START---
create table mc3p0 partition of mc3p for values from (minvalue, minvalue, minvalue) to (1, 1, 1);
---END---
---START---
create table mc3p1 partition of mc3p for values from (1, 1, 1) to (10, 5, 10);
---END---
---START---
create table mc3p2 partition of mc3p for values from (10, 5, 10) to (10, 10, 10);
---END---
---START---
create table mc3p3 partition of mc3p for values from (10, 10, 10) to (10, 10, 20);
---END---
---START---
create table mc3p4 partition of mc3p for values from (10, 10, 20) to (10, maxvalue, maxvalue);
---END---
---START---
create table mc3p5 partition of mc3p for values from (11, 1, 1) to (20, 10, 10);
---END---
---START---
create table mc3p6 partition of mc3p for values from (20, 10, 10) to (20, 20, 20);
---END---
---START---
create table mc3p7 partition of mc3p for values from (20, 20, 20) to (maxvalue, maxvalue, maxvalue);
---END---
---START---

explain (costs off) select * from mc3p where a = 1;
---END---
---START---
explain (costs off) select * from mc3p where a = 1 and abs(b) < 1;
---END---
---START---
explain (costs off) select * from mc3p where a = 1 and abs(b) = 1;
---END---
---START---
explain (costs off) select * from mc3p where a = 1 and abs(b) = 1 and c < 8;
---END---
---START---
explain (costs off) select * from mc3p where a = 10 and abs(b) between 5 and 35;
---END---
---START---
explain (costs off) select * from mc3p where a > 10;
---END---
---START---
explain (costs off) select * from mc3p where a >= 10;
---END---
---START---
explain (costs off) select * from mc3p where a < 10;
---END---
---START---
explain (costs off) select * from mc3p where a <= 10 and abs(b) < 10;
---END---
---START---
explain (costs off) select * from mc3p where a = 11 and abs(b) = 0;
---END---
---START---
explain (costs off) select * from mc3p where a = 20 and abs(b) = 10 and c = 100;
---END---
---START---
explain (costs off) select * from mc3p where a > 20;
---END---
---START---
explain (costs off) select * from mc3p where a >= 20;
---END---
---START---
explain (costs off) select * from mc3p where (a = 1 and abs(b) = 1 and c = 1) or (a = 10 and abs(b) = 5 and c = 10) or (a > 11 and a < 20);
---END---
---START---
explain (costs off) select * from mc3p where (a = 1 and abs(b) = 1 and c = 1) or (a = 10 and abs(b) = 5 and c = 10) or (a > 11 and a < 20) or a < 1;
---END---
---START---
explain (costs off) select * from mc3p where (a = 1 and abs(b) = 1 and c = 1) or (a = 10 and abs(b) = 5 and c = 10) or (a > 11 and a < 20) or a < 1 or a = 1;
---END---
---START---
explain (costs off) select * from mc3p where a = 1 or abs(b) = 1 or c = 1;
---END---
---START---
explain (costs off) select * from mc3p where (a = 1 and abs(b) = 1) or (a = 10 and abs(b) = 10);
---END---
---START---
explain (costs off) select * from mc3p where (a = 1 and abs(b) = 1) or (a = 10 and abs(b) = 9);
---END---
---START---

-- a simpler multi-column keys case
create table mc2p (a int, b int) partition by range (a, b);
---END---
---START---
create table mc2p_default partition of mc2p default;
---END---
---START---
create table mc2p0 partition of mc2p for values from (minvalue, minvalue) to (1, minvalue);
---END---
---START---
create table mc2p1 partition of mc2p for values from (1, minvalue) to (1, 1);
---END---
---START---
create table mc2p2 partition of mc2p for values from (1, 1) to (2, minvalue);
---END---
---START---
create table mc2p3 partition of mc2p for values from (2, minvalue) to (2, 1);
---END---
---START---
create table mc2p4 partition of mc2p for values from (2, 1) to (2, maxvalue);
---END---
---START---
create table mc2p5 partition of mc2p for values from (2, maxvalue) to (maxvalue, maxvalue);
---END---
---START---

explain (costs off) select * from mc2p where a < 2;
---END---
---START---
explain (costs off) select * from mc2p where a = 2 and b < 1;
---END---
---START---
explain (costs off) select * from mc2p where a > 1;
---END---
---START---
explain (costs off) select * from mc2p where a = 1 and b > 1;
---END---
---START---

-- all partitions but the default one should be pruned
explain (costs off) select * from mc2p where a = 1 and b is null;
---END---
---START---
explain (costs off) select * from mc2p where a is null and b is null;
---END---
---START---
explain (costs off) select * from mc2p where a is null and b = 1;
---END---
---START---
explain (costs off) select * from mc2p where a is null;
---END---
---START---
explain (costs off) select * from mc2p where b is null;
---END---
---START---

-- boolean partitioning
create table boolpart (a bool) partition by list (a);
---END---
---START---
create table boolpart_default partition of boolpart default;
---END---
---START---
create table boolpart_t partition of boolpart for values in ('true');
---END---
---START---
create table boolpart_f partition of boolpart for values in ('false');
---END---
---START---
insert into boolpart values (true), (false), (null);
---END---
---START---

explain (costs off) select * from boolpart where a in (true, false);
---END---
---START---
explain (costs off) select * from boolpart where a = false;
---END---
---START---
explain (costs off) select * from boolpart where not a = false;
---END---
---START---
explain (costs off) select * from boolpart where a is true or a is not true;
---END---
---START---
explain (costs off) select * from boolpart where a is not true;
---END---
---START---
explain (costs off) select * from boolpart where a is not true and a is not false;
---END---
---START---
explain (costs off) select * from boolpart where a is unknown;
---END---
---START---
explain (costs off) select * from boolpart where a is not unknown;
---END---
---START---

select * from boolpart where a in (true, false);
---END---
---START---
select * from boolpart where a = false;
---END---
---START---
select * from boolpart where not a = false;
---END---
---START---
select * from boolpart where a is true or a is not true;
---END---
---START---
select * from boolpart where a is not true;
---END---
---START---
select * from boolpart where a is not true and a is not false;
---END---
---START---
select * from boolpart where a is unknown;
---END---
---START---
select * from boolpart where a is not unknown;
---END---
---START---

-- inverse boolean partitioning - a seemingly unlikely design, but we've got
-- code for it, so we'd better test it.
create table iboolpart (a bool) partition by list ((not a));
---END---
---START---
create table iboolpart_default partition of iboolpart default;
---END---
---START---
create table iboolpart_f partition of iboolpart for values in ('true');
---END---
---START---
create table iboolpart_t partition of iboolpart for values in ('false');
---END---
---START---
insert into iboolpart values (true), (false), (null);
---END---
---START---

explain (costs off) select * from iboolpart where a in (true, false);
---END---
---START---
explain (costs off) select * from iboolpart where a = false;
---END---
---START---
explain (costs off) select * from iboolpart where not a = false;
---END---
---START---
explain (costs off) select * from iboolpart where a is true or a is not true;
---END---
---START---
explain (costs off) select * from iboolpart where a is not true;
---END---
---START---
explain (costs off) select * from iboolpart where a is not true and a is not false;
---END---
---START---
explain (costs off) select * from iboolpart where a is unknown;
---END---
---START---
explain (costs off) select * from iboolpart where a is not unknown;
---END---
---START---

select * from iboolpart where a in (true, false);
---END---
---START---
select * from iboolpart where a = false;
---END---
---START---
select * from iboolpart where not a = false;
---END---
---START---
select * from iboolpart where a is true or a is not true;
---END---
---START---
select * from iboolpart where a is not true;
---END---
---START---
select * from iboolpart where a is not true and a is not false;
---END---
---START---
select * from iboolpart where a is unknown;
---END---
---START---
select * from iboolpart where a is not unknown;
---END---
---START---

create table boolrangep (a bool, b bool, c int) partition by range (a,b,c);
---END---
---START---
create table boolrangep_tf partition of boolrangep for values from ('true', 'false', 0) to ('true', 'false', 100);
---END---
---START---
create table boolrangep_ft partition of boolrangep for values from ('false', 'true', 0) to ('false', 'true', 100);
---END---
---START---
create table boolrangep_ff1 partition of boolrangep for values from ('false', 'false', 0) to ('false', 'false', 50);
---END---
---START---
create table boolrangep_ff2 partition of boolrangep for values from ('false', 'false', 50) to ('false', 'false', 100);
---END---
---START---

-- try a more complex case that's been known to trip up pruning in the past
explain (costs off)  select * from boolrangep where not a and not b and c = 25;
---END---
---START---

-- test scalar-to-array operators
create table coercepart (a varchar) partition by list (a);
---END---
---START---
create table coercepart_ab partition of coercepart for values in ('ab');
---END---
---START---
create table coercepart_bc partition of coercepart for values in ('bc');
---END---
---START---
create table coercepart_cd partition of coercepart for values in ('cd');
---END---
---START---

explain (costs off) select * from coercepart where a in ('ab', to_char(125, '999'));
---END---
---START---
explain (costs off) select * from coercepart where a ~ any ('{ab}');
---END---
---START---
explain (costs off) select * from coercepart where a !~ all ('{ab}');
---END---
---START---
explain (costs off) select * from coercepart where a ~ any ('{ab,bc}');
---END---
---START---
explain (costs off) select * from coercepart where a !~ all ('{ab,bc}');
---END---
---START---
explain (costs off) select * from coercepart where a = any ('{ab,bc}');
---END---
---START---
explain (costs off) select * from coercepart where a = any ('{ab,null}');
---END---
---START---
explain (costs off) select * from coercepart where a = any (null::text[]);
---END---
---START---
explain (costs off) select * from coercepart where a = all ('{ab}');
---END---
---START---
explain (costs off) select * from coercepart where a = all ('{ab,bc}');
---END---
---START---
explain (costs off) select * from coercepart where a = all ('{ab,null}');
---END---
---START---
explain (costs off) select * from coercepart where a = all (null::text[]);
---END---
---START---

drop table coercepart;
---END---
---START---

CREATE TABLE part (a INT, b INT) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE part_p1 PARTITION OF part FOR VALUES IN (-2,-1,0,1,2);
---END---
---START---
CREATE TABLE part_p2 PARTITION OF part DEFAULT PARTITION BY RANGE(a);
---END---
---START---
CREATE TABLE part_p2_p1 PARTITION OF part_p2 DEFAULT;
---END---
---START---
CREATE TABLE part_rev (b INT, c INT, a INT);
---END---
---START---
ALTER TABLE part ATTACH PARTITION part_rev FOR VALUES IN (3);  -- fail
ALTER TABLE part_rev DROP COLUMN c;
---END---
---START---
ALTER TABLE part ATTACH PARTITION part_rev FOR VALUES IN (3);  -- now it's ok
INSERT INTO part VALUES (-1,-1), (1,1), (2,NULL), (NULL,-2),(NULL,NULL);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT tableoid::regclass as part, a, b FROM part WHERE a IS NULL ORDER BY 1, 2, 3;
---END---
---START---
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM part p(x) ORDER BY x;
---END---
---START---

--
-- some more cases
--

--
-- pruning for partitioned table appearing inside a sub-query
--
-- pruning won't work for mc3p, because some keys are Params
explain (costs off) select * from mc2p t1, lateral (select count(*) from mc3p t2 where t2.a = t1.b and abs(t2.b) = 1 and t2.c = 1) s where t1.a = 1;
---END---
---START---

-- pruning should work fine, because values for a prefix of keys (a, b) are
-- available
explain (costs off) select * from mc2p t1, lateral (select count(*) from mc3p t2 where t2.c = t1.b and abs(t2.b) = 1 and t2.a = 1) s where t1.a = 1;
---END---
---START---

-- also here, because values for all keys are provided
explain (costs off) select * from mc2p t1, lateral (select count(*) from mc3p t2 where t2.a = 1 and abs(t2.b) = 1 and t2.c = 1) s where t1.a = 1;
---END---
---START---

--
-- pruning with clauses containing <> operator
--

-- doesn't prune range partitions
create table rp (a int) partition by range (a);
---END---
---START---
create table rp0 partition of rp for values from (minvalue) to (1);
---END---
---START---
create table rp1 partition of rp for values from (1) to (2);
---END---
---START---
create table rp2 partition of rp for values from (2) to (maxvalue);
---END---
---START---

explain (costs off) select * from rp where a <> 1;
---END---
---START---
explain (costs off) select * from rp where a <> 1 and a <> 2;
---END---
---START---

-- null partition should be eliminated due to strict <> clause.
explain (costs off) select * from lp where a <> 'a';
---END---
---START---

-- ensure we detect contradictions in clauses; a can't be NULL and NOT NULL.
explain (costs off) select * from lp where a <> 'a' and a is null;
---END---
---START---
explain (costs off) select * from lp where (a <> 'a' and a <> 'd') or a is null;
---END---
---START---

-- check that it also works for a partitioned table that's not root,
-- which in this case are partitions of rlp that are themselves
-- list-partitioned on b
explain (costs off) select * from rlp where a = 15 and b <> 'ab' and b <> 'cd' and b <> 'xy' and b is not null;
---END---
---START---

--
-- different collations for different keys with same expression
--
create table coll_pruning_multi (a text) partition by range (substr(a, 1) collate "POSIX", substr(a, 1) collate "C");
---END---
---START---
create table coll_pruning_multi1 partition of coll_pruning_multi for values from ('a', 'a') to ('a', 'e');
---END---
---START---
create table coll_pruning_multi2 partition of coll_pruning_multi for values from ('a', 'e') to ('a', 'z');
---END---
---START---
create table coll_pruning_multi3 partition of coll_pruning_multi for values from ('b', 'a') to ('b', 'e');
---END---
---START---

-- no pruning, because no value for the leading key
explain (costs off) select * from coll_pruning_multi where substr(a, 1) = 'e' collate "C";
---END---
---START---

-- pruning, with a value provided for the leading key
explain (costs off) select * from coll_pruning_multi where substr(a, 1) = 'a' collate "POSIX";
---END---
---START---

-- pruning, with values provided for both keys
explain (costs off) select * from coll_pruning_multi where substr(a, 1) = 'e' collate "C" and substr(a, 1) = 'a' collate "POSIX";
---END---
---START---

--
-- LIKE operators don't prune
--
create table like_op_noprune (a text) partition by list (a);
---END---
---START---
create table like_op_noprune1 partition of like_op_noprune for values in ('ABC');
---END---
---START---
create table like_op_noprune2 partition of like_op_noprune for values in ('BCD');
---END---
---START---
explain (costs off) select * from like_op_noprune where a like '%BC';
---END---
---START---

--
-- tests wherein clause value requires a cross-type comparison function
--
create table lparted_by_int2 (a smallint) partition by list (a);
---END---
---START---
create table lparted_by_int2_1 partition of lparted_by_int2 for values in (1);
---END---
---START---
create table lparted_by_int2_16384 partition of lparted_by_int2 for values in (16384);
---END---
---START---
explain (costs off) select * from lparted_by_int2 where a = 100_000_000_000_000;
---END---
---START---

create table rparted_by_int2 (a smallint) partition by range (a);
---END---
---START---
create table rparted_by_int2_1 partition of rparted_by_int2 for values from (1) to (10);
---END---
---START---
create table rparted_by_int2_16384 partition of rparted_by_int2 for values from (10) to (16384);
---END---
---START---
-- all partitions pruned
explain (costs off) select * from rparted_by_int2 where a > 100_000_000_000_000;
---END---
---START---
create table rparted_by_int2_maxvalue partition of rparted_by_int2 for values from (16384) to (maxvalue);
---END---
---START---
-- all partitions but rparted_by_int2_maxvalue pruned
explain (costs off) select * from rparted_by_int2 where a > 100_000_000_000_000;
---END---
---START---

drop table lp, coll_pruning, rlp, mc3p, mc2p, boolpart, iboolpart, boolrangep, rp, coll_pruning_multi, like_op_noprune, lparted_by_int2, rparted_by_int2;
---END---
---START---

--
-- Test Partition pruning for HASH partitioning
--
-- Use hand-rolled hash functions and operator classes to get predictable
-- result on different machines.  See the definitions of
-- part_part_test_int4_ops and part_test_text_ops in insert.sql.
--

create table hp (a int, b text, c int)
  partition by hash (a part_test_int4_ops, b part_test_text_ops);
---END---
---START---
create table hp0 partition of hp for values with (modulus 4, remainder 0);
---END---
---START---
create table hp3 partition of hp for values with (modulus 4, remainder 3);
---END---
---START---
create table hp1 partition of hp for values with (modulus 4, remainder 1);
---END---
---START---
create table hp2 partition of hp for values with (modulus 4, remainder 2);
---END---
---START---

insert into hp values (null, null, 0);
---END---
---START---
insert into hp values (1, null, 1);
---END---
---START---
insert into hp values (1, 'xxx', 2);
---END---
---START---
insert into hp values (null, 'xxx', 3);
---END---
---START---
insert into hp values (2, 'xxx', 4);
---END---
---START---
insert into hp values (1, 'abcde', 5);
---END---
---START---
select tableoid::regclass, * from hp order by c;
---END---
---START---

-- partial keys won't prune, nor would non-equality conditions
explain (costs off) select * from hp where a = 1;
---END---
---START---
explain (costs off) select * from hp where b = 'xxx';
---END---
---START---
explain (costs off) select * from hp where a is null;
---END---
---START---
explain (costs off) select * from hp where b is null;
---END---
---START---
explain (costs off) select * from hp where a < 1 and b = 'xxx';
---END---
---START---
explain (costs off) select * from hp where a <> 1 and b = 'yyy';
---END---
---START---
explain (costs off) select * from hp where a <> 1 and b <> 'xxx';
---END---
---START---

-- pruning should work if either a value or a IS NULL clause is provided for
-- each of the keys
explain (costs off) select * from hp where a is null and b is null;
---END---
---START---
explain (costs off) select * from hp where a = 1 and b is null;
---END---
---START---
explain (costs off) select * from hp where a = 1 and b = 'xxx';
---END---
---START---
explain (costs off) select * from hp where a is null and b = 'xxx';
---END---
---START---
explain (costs off) select * from hp where a = 2 and b = 'xxx';
---END---
---START---
explain (costs off) select * from hp where a = 1 and b = 'abcde';
---END---
---START---
explain (costs off) select * from hp where (a = 1 and b = 'abcde') or (a = 2 and b = 'xxx') or (a is null and b is null);
---END---
---START---

-- test pruning when not all the partitions exist
drop table hp1;
---END---
---START---
drop table hp3;
---END---
---START---
explain (costs off) select * from hp where a = 1 and b = 'abcde';
---END---
---START---
explain (costs off) select * from hp where a = 1 and b = 'abcde' and
  (c = 2 or c = 3);
---END---
---START---
drop table hp2;
---END---
---START---
explain (costs off) select * from hp where a = 1 and b = 'abcde' and
  (c = 2 or c = 3);
---END---
---START---

drop table hp;
---END---
---START---

--
-- Test runtime partition pruning
--
create table ab (a int not null, b int not null) partition by list (a);
---END---
---START---
create table ab_a2 partition of ab for values in(2) partition by list (b);
---END---
---START---
create table ab_a2_b1 partition of ab_a2 for values in (1);
---END---
---START---
create table ab_a2_b2 partition of ab_a2 for values in (2);
---END---
---START---
create table ab_a2_b3 partition of ab_a2 for values in (3);
---END---
---START---
create table ab_a1 partition of ab for values in(1) partition by list (b);
---END---
---START---
create table ab_a1_b1 partition of ab_a1 for values in (1);
---END---
---START---
create table ab_a1_b2 partition of ab_a1 for values in (2);
---END---
---START---
create table ab_a1_b3 partition of ab_a1 for values in (3);
---END---
---START---
create table ab_a3 partition of ab for values in(3) partition by list (b);
---END---
---START---
create table ab_a3_b1 partition of ab_a3 for values in (1);
---END---
---START---
create table ab_a3_b2 partition of ab_a3 for values in (2);
---END---
---START---
create table ab_a3_b3 partition of ab_a3 for values in (3);
---END---
---START---

-- Disallow index only scans as concurrent transactions may stop visibility
-- bits being set causing "Heap Fetches" to be unstable in the EXPLAIN ANALYZE
-- output.
set enable_indexonlyscan = off;
---END---
---START---

prepare ab_q1 (int, int, int) as
select * from ab where a between $1 and $2 and b <= $3;
---END---
---START---

explain (analyze, costs off, summary off, timing off) execute ab_q1 (2, 2, 3);
---END---
---START---
explain (analyze, costs off, summary off, timing off) execute ab_q1 (1, 2, 3);
---END---
---START---

deallocate ab_q1;
---END---
---START---

-- Runtime pruning after optimizer pruning
prepare ab_q1 (int, int) as
select a from ab where a between $1 and $2 and b < 3;
---END---
---START---

explain (analyze, costs off, summary off, timing off) execute ab_q1 (2, 2);
---END---
---START---
explain (analyze, costs off, summary off, timing off) execute ab_q1 (2, 4);
---END---
---START---

-- Ensure a mix of PARAM_EXTERN and PARAM_EXEC Params work together at
-- different levels of partitioning.
prepare ab_q2 (int, int) as
select a from ab where a between $1 and $2 and b < (select 3);
---END---
---START---

explain (analyze, costs off, summary off, timing off) execute ab_q2 (2, 2);
---END---
---START---

-- As above, but swap the PARAM_EXEC Param to the first partition level
prepare ab_q3 (int, int) as
select a from ab where b between $1 and $2 and a < (select 3);
---END---
---START---

explain (analyze, costs off, summary off, timing off) execute ab_q3 (2, 2);
---END---
---START---

-- Test a backwards Append scan
create table list_part (a int) partition by list (a);
---END---
---START---
create table list_part1 partition of list_part for values in (1);
---END---
---START---
create table list_part2 partition of list_part for values in (2);
---END---
---START---
create table list_part3 partition of list_part for values in (3);
---END---
---START---
create table list_part4 partition of list_part for values in (4);
---END---
---START---

insert into list_part select generate_series(1,4);
---END---
---START---

begin;
---END---
---START---

-- Don't select an actual value out of the table as the order of the Append's
-- subnodes may not be stable.
declare cur SCROLL CURSOR for select 1 from list_part where a > (select 1) and a < (select 4);
---END---
---START---

-- move beyond the final row
move 3 from cur;
---END---
---START---

-- Ensure we get two rows.
fetch backward all from cur;
---END---
---START---

commit;
---END---
---START---

begin;
---END---
---START---

-- Test run-time pruning using stable functions
create function list_part_fn(int) returns int as $$ begin return $1; end;$$ language plpgsql stable;
---END---
---START---

-- Ensure pruning works using a stable function containing no Vars
explain (analyze, costs off, summary off, timing off) select * from list_part where a = list_part_fn(1);
---END---
---START---

-- Ensure pruning does not take place when the function has a Var parameter
explain (analyze, costs off, summary off, timing off) select * from list_part where a = list_part_fn(a);
---END---
---START---

-- Ensure pruning does not take place when the expression contains a Var.
explain (analyze, costs off, summary off, timing off) select * from list_part where a = list_part_fn(1) + a;
---END---
---START---

rollback;
---END---
---START---

drop table list_part;
---END---
---START---

-- Parallel append

-- Parallel queries won't necessarily get as many workers as the planner
-- asked for.  This affects not only the "Workers Launched:" field of EXPLAIN
-- results, but also row counts and loop counts for parallel scans, Gathers,
-- and everything in between.  This function filters out the values we can't
-- rely on to be stable.
-- This removes enough info that you might wonder why bother with EXPLAIN
-- ANALYZE at all.  The answer is that we need to see '(never executed)'
-- notations because that's the only way to verify runtime pruning.
create function explain_parallel_append(text) returns setof text
language plpgsql as
$$
declare
    ln text;
---END---
---START---
begin
    for ln in
        execute format('explain (analyze, costs off, summary off, timing off) %s',
            $1)
    loop
        ln := regexp_replace(ln, 'Workers Launched: \d+', 'Workers Launched: N');
---END---
---START---
        ln := regexp_replace(ln, 'actual rows=\d+ loops=\d+', 'actual rows=N loops=N');
---END---
---START---
        ln := regexp_replace(ln, 'Rows Removed by Filter: \d+', 'Rows Removed by Filter: N');
---END---
---START---
        return next ln;
---END---
---START---
    end loop;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

prepare ab_q4 (int, int) as
select avg(a) from ab where a between $1 and $2 and b < 4;
---END---
---START---

-- Encourage use of parallel plans
set parallel_setup_cost = 0;
---END---
---START---
set parallel_tuple_cost = 0;
---END---
---START---
set min_parallel_table_scan_size = 0;
---END---
---START---
set max_parallel_workers_per_gather = 2;
---END---
---START---

select explain_parallel_append('execute ab_q4 (2, 2)');
---END---
---START---

-- Test run-time pruning with IN lists.
prepare ab_q5 (int, int, int) as
select avg(a) from ab where a in($1,$2,$3) and b < 4;
---END---
---START---

select explain_parallel_append('execute ab_q5 (1, 1, 1)');
---END---
---START---
select explain_parallel_append('execute ab_q5 (2, 3, 3)');
---END---
---START---

-- Try some params whose values do not belong to any partition.
select explain_parallel_append('execute ab_q5 (33, 44, 55)');
---END---
---START---

-- Test Parallel Append with PARAM_EXEC Params
select explain_parallel_append('select count(*) from ab where (a = (select 1) or a = (select 3)) and b = 2');
---END---
---START---

-- Test pruning during parallel nested loop query
create table lprt_a (a int not null);
---END---
---START---
-- Insert some values we won't find in ab
insert into lprt_a select 0 from generate_series(1,100);
---END---
---START---

-- and insert some values that we should find.
insert into lprt_a values(1),(1);
---END---
---START---

analyze lprt_a;
---END---
---START---

create index ab_a2_b1_a_idx on ab_a2_b1 (a);
---END---
---START---
create index ab_a2_b2_a_idx on ab_a2_b2 (a);
---END---
---START---
create index ab_a2_b3_a_idx on ab_a2_b3 (a);
---END---
---START---
create index ab_a1_b1_a_idx on ab_a1_b1 (a);
---END---
---START---
create index ab_a1_b2_a_idx on ab_a1_b2 (a);
---END---
---START---
create index ab_a1_b3_a_idx on ab_a1_b3 (a);
---END---
---START---
create index ab_a3_b1_a_idx on ab_a3_b1 (a);
---END---
---START---
create index ab_a3_b2_a_idx on ab_a3_b2 (a);
---END---
---START---
create index ab_a3_b3_a_idx on ab_a3_b3 (a);
---END---
---START---

set enable_hashjoin = 0;
---END---
---START---
set enable_mergejoin = 0;
---END---
---START---
set enable_memoize = 0;
---END---
---START---

select explain_parallel_append('select avg(ab.a) from ab inner join lprt_a a on ab.a = a.a where a.a in(0, 0, 1)');
---END---
---START---

-- Ensure the same partitions are pruned when we make the nested loop
-- parameter an Expr rather than a plain Param.
select explain_parallel_append('select avg(ab.a) from ab inner join lprt_a a on ab.a = a.a + 0 where a.a in(0, 0, 1)');
---END---
---START---

insert into lprt_a values(3),(3);
---END---
---START---

select explain_parallel_append('select avg(ab.a) from ab inner join lprt_a a on ab.a = a.a where a.a in(1, 0, 3)');
---END---
---START---
select explain_parallel_append('select avg(ab.a) from ab inner join lprt_a a on ab.a = a.a where a.a in(1, 0, 0)');
---END---
---START---

delete from lprt_a where a = 1;
---END---
---START---

select explain_parallel_append('select avg(ab.a) from ab inner join lprt_a a on ab.a = a.a where a.a in(1, 0, 0)');
---END---
---START---

reset enable_hashjoin;
---END---
---START---
reset enable_mergejoin;
---END---
---START---
reset enable_memoize;
---END---
---START---
reset parallel_setup_cost;
---END---
---START---
reset parallel_tuple_cost;
---END---
---START---
reset min_parallel_table_scan_size;
---END---
---START---
reset max_parallel_workers_per_gather;
---END---
---START---

-- Test run-time partition pruning with an initplan
explain (analyze, costs off, summary off, timing off)
select * from ab where a = (select max(a) from lprt_a) and b = (select max(a)-1 from lprt_a);
---END---
---START---

-- Test run-time partition pruning with UNION ALL parents
explain (analyze, costs off, summary off, timing off)
select * from (select * from ab where a = 1 union all select * from ab) ab where b = (select 1);
---END---
---START---

-- A case containing a UNION ALL with a non-partitioned child.
explain (analyze, costs off, summary off, timing off)
select * from (select * from ab where a = 1 union all (values(10,5)) union all select * from ab) ab where b = (select 1);
---END---
---START---

-- Another UNION ALL test, but containing a mix of exec init and exec run-time pruning.
create table xy_1 (x int, y int);
---END---
---START---
insert into xy_1 values(100,-10);
---END---
---START---

set enable_bitmapscan = 0;
---END---
---START---
set enable_indexscan = 0;
---END---
---START---

prepare ab_q6 as
select * from (
	select tableoid::regclass,a,b from ab
union all
	select tableoid::regclass,x,y from xy_1
union all
	select tableoid::regclass,a,b from ab
) ab where a = $1 and b = (select -10);
---END---
---START---

-- Ensure the xy_1 subplan is not pruned.
explain (analyze, costs off, summary off, timing off) execute ab_q6(1);
---END---
---START---

-- Ensure we see just the xy_1 row.
execute ab_q6(100);
---END---
---START---

reset enable_bitmapscan;
---END---
---START---
reset enable_indexscan;
---END---
---START---

deallocate ab_q1;
---END---
---START---
deallocate ab_q2;
---END---
---START---
deallocate ab_q3;
---END---
---START---
deallocate ab_q4;
---END---
---START---
deallocate ab_q5;
---END---
---START---
deallocate ab_q6;
---END---
---START---

-- UPDATE on a partition subtree has been seen to have problems.
insert into ab values (1,2);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
update ab_a1 set b = 3 from ab where ab.a = 1 and ab.a = ab_a1.a;
---END---
---START---
table ab;
---END---
---START---

-- Test UPDATE where source relation has run-time pruning enabled
truncate ab;
---END---
---START---
insert into ab values (1, 1), (1, 2), (1, 3), (2, 1);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
update ab_a1 set b = 3 from ab_a2 where ab_a2.b = (select 1);
---END---
---START---
select tableoid::regclass, * from ab;
---END---
---START---

drop table ab, lprt_a;
---END---
---START---

-- Join
create table tbl1(col1 int);
---END---
---START---
insert into tbl1 values (501), (505);
---END---
---START---

-- Basic table
create table tprt (col1 int) partition by range (col1);
---END---
---START---
create table tprt_1 partition of tprt for values from (1) to (501);
---END---
---START---
create table tprt_2 partition of tprt for values from (501) to (1001);
---END---
---START---
create table tprt_3 partition of tprt for values from (1001) to (2001);
---END---
---START---
create table tprt_4 partition of tprt for values from (2001) to (3001);
---END---
---START---
create table tprt_5 partition of tprt for values from (3001) to (4001);
---END---
---START---
create table tprt_6 partition of tprt for values from (4001) to (5001);
---END---
---START---

create index tprt1_idx on tprt_1 (col1);
---END---
---START---
create index tprt2_idx on tprt_2 (col1);
---END---
---START---
create index tprt3_idx on tprt_3 (col1);
---END---
---START---
create index tprt4_idx on tprt_4 (col1);
---END---
---START---
create index tprt5_idx on tprt_5 (col1);
---END---
---START---
create index tprt6_idx on tprt_6 (col1);
---END---
---START---

insert into tprt values (10), (20), (501), (502), (505), (1001), (4500);
---END---
---START---

set enable_hashjoin = off;
---END---
---START---
set enable_mergejoin = off;
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from tbl1 join tprt on tbl1.col1 > tprt.col1;
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from tbl1 join tprt on tbl1.col1 = tprt.col1;
---END---
---START---

select tbl1.col1, tprt.col1 from tbl1
inner join tprt on tbl1.col1 > tprt.col1
order by tbl1.col1, tprt.col1;
---END---
---START---

select tbl1.col1, tprt.col1 from tbl1
inner join tprt on tbl1.col1 = tprt.col1
order by tbl1.col1, tprt.col1;
---END---
---START---

-- Multiple partitions
insert into tbl1 values (1001), (1010), (1011);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from tbl1 inner join tprt on tbl1.col1 > tprt.col1;
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from tbl1 inner join tprt on tbl1.col1 = tprt.col1;
---END---
---START---

select tbl1.col1, tprt.col1 from tbl1
inner join tprt on tbl1.col1 > tprt.col1
order by tbl1.col1, tprt.col1;
---END---
---START---

select tbl1.col1, tprt.col1 from tbl1
inner join tprt on tbl1.col1 = tprt.col1
order by tbl1.col1, tprt.col1;
---END---
---START---

-- Last partition
delete from tbl1;
---END---
---START---
insert into tbl1 values (4400);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from tbl1 join tprt on tbl1.col1 < tprt.col1;
---END---
---START---

select tbl1.col1, tprt.col1 from tbl1
inner join tprt on tbl1.col1 < tprt.col1
order by tbl1.col1, tprt.col1;
---END---
---START---

-- No matching partition
delete from tbl1;
---END---
---START---
insert into tbl1 values (10000);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from tbl1 join tprt on tbl1.col1 = tprt.col1;
---END---
---START---

select tbl1.col1, tprt.col1 from tbl1
inner join tprt on tbl1.col1 = tprt.col1
order by tbl1.col1, tprt.col1;
---END---
---START---

drop table tbl1, tprt;
---END---
---START---

-- Test with columns defined in varying orders between each level
create table part_abc (a int not null, b int not null, c int not null) partition by list (a);
---END---
---START---
create table part_bac (b int not null, a int not null, c int not null) partition by list (b);
---END---
---START---
create table part_cab (c int not null, a int not null, b int not null) partition by list (c);
---END---
---START---
create table part_abc_p1 (a int not null, b int not null, c int not null);
---END---
---START---

alter table part_abc attach partition part_bac for values in(1);
---END---
---START---
alter table part_bac attach partition part_cab for values in(2);
---END---
---START---
alter table part_cab attach partition part_abc_p1 for values in(3);
---END---
---START---

prepare part_abc_q1 (int, int, int) as
select * from part_abc where a = $1 and b = $2 and c = $3;
---END---
---START---

-- Single partition should be scanned.
explain (analyze, costs off, summary off, timing off) execute part_abc_q1 (1, 2, 3);
---END---
---START---

deallocate part_abc_q1;
---END---
---START---

drop table part_abc;
---END---
---START---

-- Ensure that an Append node properly handles a sub-partitioned table
-- matching without any of its leaf partitions matching the clause.
create table listp (a int, b int) partition by list (a);
---END---
---START---
create table listp_1 partition of listp for values in(1) partition by list (b);
---END---
---START---
create table listp_1_1 partition of listp_1 for values in(1);
---END---
---START---
create table listp_2 partition of listp for values in(2) partition by list (b);
---END---
---START---
create table listp_2_1 partition of listp_2 for values in(2);
---END---
---START---
select * from listp where b = 1;
---END---
---START---

-- Ensure that an Append node properly can handle selection of all first level
-- partitions before finally detecting the correct set of 2nd level partitions
-- which match the given parameter.
prepare q1 (int,int) as select * from listp where b in ($1,$2);
---END---
---START---

explain (analyze, costs off, summary off, timing off)  execute q1 (1,1);
---END---
---START---

explain (analyze, costs off, summary off, timing off)  execute q1 (2,2);
---END---
---START---

-- Try with no matching partitions.
explain (analyze, costs off, summary off, timing off)  execute q1 (0,0);
---END---
---START---

deallocate q1;
---END---
---START---

-- Test more complex cases where a not-equal condition further eliminates partitions.
prepare q1 (int,int,int,int) as select * from listp where b in($1,$2) and $3 <> b and $4 <> b;
---END---
---START---

-- Both partitions allowed by IN clause, but one disallowed by <> clause
explain (analyze, costs off, summary off, timing off)  execute q1 (1,2,2,0);
---END---
---START---

-- Both partitions allowed by IN clause, then both excluded again by <> clauses.
explain (analyze, costs off, summary off, timing off)  execute q1 (1,2,2,1);
---END---
---START---

-- Ensure Params that evaluate to NULL properly prune away all partitions
explain (analyze, costs off, summary off, timing off)
select * from listp where a = (select null::int);
---END---
---START---

drop table listp;
---END---
---START---

--
-- check that stable query clauses are only used in run-time pruning
--
create table stable_qual_pruning (a timestamp) partition by range (a);
---END---
---START---
create table stable_qual_pruning1 partition of stable_qual_pruning
  for values from ('2000-01-01') to ('2000-02-01');
---END---
---START---
create table stable_qual_pruning2 partition of stable_qual_pruning
  for values from ('2000-02-01') to ('2000-03-01');
---END---
---START---
create table stable_qual_pruning3 partition of stable_qual_pruning
  for values from ('3000-02-01') to ('3000-03-01');
---END---
---START---

-- comparison against a stable value requires run-time pruning
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning where a < localtimestamp;
---END---
---START---

-- timestamp < timestamptz comparison is only stable, not immutable
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning where a < '2000-02-01'::timestamptz;
---END---
---START---

-- check ScalarArrayOp cases
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning
  where a = any(array['2010-02-01', '2020-01-01']::timestamp[]);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning
  where a = any(array['2000-02-01', '2010-01-01']::timestamp[]);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning
  where a = any(array['2000-02-01', localtimestamp]::timestamp[]);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning
  where a = any(array['2010-02-01', '2020-01-01']::timestamptz[]);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning
  where a = any(array['2000-02-01', '2010-01-01']::timestamptz[]);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
select * from stable_qual_pruning
  where a = any(null::timestamptz[]);
---END---
---START---

drop table stable_qual_pruning;
---END---
---START---

--
-- Check that pruning with composite range partitioning works correctly when
-- it must ignore clauses for trailing keys once it has seen a clause with
-- non-inclusive operator for an earlier key
--
create table mc3p (a int, b int, c int) partition by range (a, abs(b), c);
---END---
---START---
create table mc3p0 partition of mc3p
  for values from (0, 0, 0) to (0, maxvalue, maxvalue);
---END---
---START---
create table mc3p1 partition of mc3p
  for values from (1, 1, 1) to (2, minvalue, minvalue);
---END---
---START---
create table mc3p2 partition of mc3p
  for values from (2, minvalue, minvalue) to (3, maxvalue, maxvalue);
---END---
---START---
insert into mc3p values (0, 1, 1), (1, 1, 1), (2, 1, 1);
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from mc3p where a < 3 and abs(b) = 1;
---END---
---START---

--
-- Check that pruning with composite range partitioning works correctly when
-- a combination of runtime parameters is specified, not all of whose values
-- are available at the same time
--
prepare ps1 as
  select * from mc3p where a = $1 and abs(b) < (select 3);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
execute ps1(1);
---END---
---START---
deallocate ps1;
---END---
---START---
prepare ps2 as
  select * from mc3p where a <= $1 and abs(b) < (select 3);
---END---
---START---
explain (analyze, costs off, summary off, timing off)
execute ps2(1);
---END---
---START---
deallocate ps2;
---END---
---START---

drop table mc3p;
---END---
---START---

-- Ensure runtime pruning works with initplans params with boolean types
create table boolvalues (value bool not null);
---END---
---START---
insert into boolvalues values('t'),('f');
---END---
---START---

create table boolp (a bool) partition by list (a);
---END---
---START---
create table boolp_t partition of boolp for values in('t');
---END---
---START---
create table boolp_f partition of boolp for values in('f');
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from boolp where a = (select value from boolvalues where value);
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from boolp where a = (select value from boolvalues where not value);
---END---
---START---

drop table boolp;
---END---
---START---

--
-- Test run-time pruning of MergeAppend subnodes
--
set enable_seqscan = off;
---END---
---START---
set enable_sort = off;
---END---
---START---
create table ma_test (a int, b int) partition by range (a);
---END---
---START---
create table ma_test_p1 partition of ma_test for values from (0) to (10);
---END---
---START---
create table ma_test_p2 partition of ma_test for values from (10) to (20);
---END---
---START---
create table ma_test_p3 partition of ma_test for values from (20) to (30);
---END---
---START---
insert into ma_test select x,x from generate_series(0,29) t(x);
---END---
---START---
create index on ma_test (b);
---END---
---START---

analyze ma_test;
---END---
---START---
prepare mt_q1 (int) as select a from ma_test where a >= $1 and a % 10 = 5 order by b;
---END---
---START---

explain (analyze, costs off, summary off, timing off) execute mt_q1(15);
---END---
---START---
execute mt_q1(15);
---END---
---START---
explain (analyze, costs off, summary off, timing off) execute mt_q1(25);
---END---
---START---
execute mt_q1(25);
---END---
---START---
-- Ensure MergeAppend behaves correctly when no subplans match
explain (analyze, costs off, summary off, timing off) execute mt_q1(35);
---END---
---START---
execute mt_q1(35);
---END---
---START---

deallocate mt_q1;
---END---
---START---

prepare mt_q2 (int) as select * from ma_test where a >= $1 order by b limit 1;
---END---
---START---

-- Ensure output list looks sane when the MergeAppend has no subplans.
explain (analyze, verbose, costs off, summary off, timing off) execute mt_q2 (35);
---END---
---START---

deallocate mt_q2;
---END---
---START---

-- ensure initplan params properly prune partitions
explain (analyze, costs off, summary off, timing off) select * from ma_test where a >= (select min(b) from ma_test_p2) order by b;
---END---
---START---

reset enable_seqscan;
---END---
---START---
reset enable_sort;
---END---
---START---

drop table ma_test;
---END---
---START---

reset enable_indexonlyscan;
---END---
---START---

--
-- check that pruning works properly when the partition key is of a
-- pseudotype
--

-- array type list partition key
create table pp_arrpart (a int[]) partition by list (a);
---END---
---START---
create table pp_arrpart1 partition of pp_arrpart for values in ('{1}');
---END---
---START---
create table pp_arrpart2 partition of pp_arrpart for values in ('{2, 3}', '{4, 5}');
---END---
---START---
explain (costs off) select * from pp_arrpart where a = '{1}';
---END---
---START---
explain (costs off) select * from pp_arrpart where a = '{1, 2}';
---END---
---START---
explain (costs off) select * from pp_arrpart where a in ('{4, 5}', '{1}');
---END---
---START---
explain (costs off) update pp_arrpart set a = a where a = '{1}';
---END---
---START---
explain (costs off) delete from pp_arrpart where a = '{1}';
---END---
---START---
drop table pp_arrpart;
---END---
---START---

-- array type hash partition key
create table pph_arrpart (a int[]) partition by hash (a);
---END---
---START---
create table pph_arrpart1 partition of pph_arrpart for values with (modulus 2, remainder 0);
---END---
---START---
create table pph_arrpart2 partition of pph_arrpart for values with (modulus 2, remainder 1);
---END---
---START---
insert into pph_arrpart values ('{1}'), ('{1, 2}'), ('{4, 5}');
---END---
---START---
select tableoid::regclass, * from pph_arrpart order by 1;
---END---
---START---
explain (costs off) select * from pph_arrpart where a = '{1}';
---END---
---START---
explain (costs off) select * from pph_arrpart where a = '{1, 2}';
---END---
---START---
explain (costs off) select * from pph_arrpart where a in ('{4, 5}', '{1}');
---END---
---START---
drop table pph_arrpart;
---END---
---START---

-- enum type list partition key
create type pp_colors as enum ('green', 'blue', 'black');
---END---
---START---
create table pp_enumpart (a pp_colors) partition by list (a);
---END---
---START---
create table pp_enumpart_green partition of pp_enumpart for values in ('green');
---END---
---START---
create table pp_enumpart_blue partition of pp_enumpart for values in ('blue');
---END---
---START---
explain (costs off) select * from pp_enumpart where a = 'blue';
---END---
---START---
explain (costs off) select * from pp_enumpart where a = 'black';
---END---
---START---
drop table pp_enumpart;
---END---
---START---
drop type pp_colors;
---END---
---START---

-- record type as partition key
create type pp_rectype as (a int, b int);
---END---
---START---
create table pp_recpart (a pp_rectype) partition by list (a);
---END---
---START---
create table pp_recpart_11 partition of pp_recpart for values in ('(1,1)');
---END---
---START---
create table pp_recpart_23 partition of pp_recpart for values in ('(2,3)');
---END---
---START---
explain (costs off) select * from pp_recpart where a = '(1,1)'::pp_rectype;
---END---
---START---
explain (costs off) select * from pp_recpart where a = '(1,2)'::pp_rectype;
---END---
---START---
drop table pp_recpart;
---END---
---START---
drop type pp_rectype;
---END---
---START---

-- range type partition key
create table pp_intrangepart (a int4range) partition by list (a);
---END---
---START---
create table pp_intrangepart12 partition of pp_intrangepart for values in ('[1,2]');
---END---
---START---
create table pp_intrangepart2inf partition of pp_intrangepart for values in ('[2,)');
---END---
---START---
explain (costs off) select * from pp_intrangepart where a = '[1,2]'::int4range;
---END---
---START---
explain (costs off) select * from pp_intrangepart where a = '(1,2)'::int4range;
---END---
---START---
drop table pp_intrangepart;
---END---
---START---

--
-- Ensure the enable_partition_prune GUC properly disables partition pruning.
--

create table pp_lp (a int, value int) partition by list (a);
---END---
---START---
create table pp_lp1 partition of pp_lp for values in(1);
---END---
---START---
create table pp_lp2 partition of pp_lp for values in(2);
---END---
---START---

explain (costs off) select * from pp_lp where a = 1;
---END---
---START---
explain (costs off) update pp_lp set value = 10 where a = 1;
---END---
---START---
explain (costs off) delete from pp_lp where a = 1;
---END---
---START---

set enable_partition_pruning = off;
---END---
---START---

set constraint_exclusion = 'partition'; -- this should not affect the result.

explain (costs off) select * from pp_lp where a = 1;
---END---
---START---
explain (costs off) update pp_lp set value = 10 where a = 1;
---END---
---START---
explain (costs off) delete from pp_lp where a = 1;
---END---
---START---

set constraint_exclusion = 'off'; -- this should not affect the result.

explain (costs off) select * from pp_lp where a = 1;
---END---
---START---
explain (costs off) update pp_lp set value = 10 where a = 1;
---END---
---START---
explain (costs off) delete from pp_lp where a = 1;
---END---
---START---

drop table pp_lp;
---END---
---START---

-- Ensure enable_partition_prune does not affect non-partitioned tables.

create table inh_lp (a int, value int);
---END---
---START---
create table inh_lp1 (a int, value int, check(a = 1)) inherits (inh_lp);
---END---
---START---
create table inh_lp2 (a int, value int, check(a = 2)) inherits (inh_lp);
---END---
---START---

set constraint_exclusion = 'partition';
---END---
---START---

-- inh_lp2 should be removed in the following 3 cases.
explain (costs off) select * from inh_lp where a = 1;
---END---
---START---
explain (costs off) update inh_lp set value = 10 where a = 1;
---END---
---START---
explain (costs off) delete from inh_lp where a = 1;
---END---
---START---

-- Ensure we don't exclude normal relations when we only expect to exclude
-- inheritance children
explain (costs off) update inh_lp1 set value = 10 where a = 2;
---END---
---START---

drop table inh_lp cascade;
---END---
---START---

reset enable_partition_pruning;
---END---
---START---
reset constraint_exclusion;
---END---
---START---

-- Check pruning for a partition tree containing only temporary relations
create temp table pp_temp_parent (a int) partition by list (a);
---END---
---START---
create temp table pp_temp_part_1 partition of pp_temp_parent for values in (1);
---END---
---START---
create temp table pp_temp_part_def partition of pp_temp_parent default;
---END---
---START---
explain (costs off) select * from pp_temp_parent where true;
---END---
---START---
explain (costs off) select * from pp_temp_parent where a = 2;
---END---
---START---
drop table pp_temp_parent;
---END---
---START---

-- Stress run-time partition pruning a bit more, per bug reports
create temp table p (a int, b int, c int) partition by list (a);
---END---
---START---
create temp table p1 partition of p for values in (1);
---END---
---START---
create temp table p2 partition of p for values in (2);
---END---
---START---
create temp table q (a int, b int, c int) partition by list (a);
---END---
---START---
create temp table q1 partition of q for values in (1) partition by list (b);
---END---
---START---
create temp table q11 partition of q1 for values in (1) partition by list (c);
---END---
---START---
create temp table q111 partition of q11 for values in (1);
---END---
---START---
create temp table q2 partition of q for values in (2) partition by list (b);
---END---
---START---
create temp table q21 partition of q2 for values in (1);
---END---
---START---
create temp table q22 partition of q2 for values in (2);
---END---
---START---

insert into q22 values (2, 2, 3);
---END---
---START---

explain (costs off)
select *
from (
      select * from p
      union all
      select * from q1
      union all
      select 1, 1, 1
     ) s(a, b, c)
where s.a = 1 and s.b = 1 and s.c = (select 1);
---END---
---START---

select *
from (
      select * from p
      union all
      select * from q1
      union all
      select 1, 1, 1
     ) s(a, b, c)
where s.a = 1 and s.b = 1 and s.c = (select 1);
---END---
---START---

prepare q (int, int) as
select *
from (
      select * from p
      union all
      select * from q1
      union all
      select 1, 1, 1
     ) s(a, b, c)
where s.a = $1 and s.b = $2 and s.c = (select 1);
---END---
---START---

explain (costs off) execute q (1, 1);
---END---
---START---
execute q (1, 1);
---END---
---START---

drop table p, q;
---END---
---START---

-- Ensure run-time pruning works correctly when we match a partitioned table
-- on the first level but find no matching partitions on the second level.
create table listp (a int, b int) partition by list (a);
---END---
---START---
create table listp1 partition of listp for values in(1);
---END---
---START---
create table listp2 partition of listp for values in(2) partition by list(b);
---END---
---START---
create table listp2_10 partition of listp2 for values in (10);
---END---
---START---

explain (analyze, costs off, summary off, timing off)
select * from listp where a = (select 2) and b <> 10;
---END---
---START---

--
-- check that a partition directly accessed in a query is excluded with
-- constraint_exclusion = on
--

-- turn off partition pruning, so that it doesn't interfere
set enable_partition_pruning to off;
---END---
---START---

-- setting constraint_exclusion to 'partition' disables exclusion
set constraint_exclusion to 'partition';
---END---
---START---
explain (costs off) select * from listp1 where a = 2;
---END---
---START---
explain (costs off) update listp1 set a = 1 where a = 2;
---END---
---START---
-- constraint exclusion enabled
set constraint_exclusion to 'on';
---END---
---START---
explain (costs off) select * from listp1 where a = 2;
---END---
---START---
explain (costs off) update listp1 set a = 1 where a = 2;
---END---
---START---

reset constraint_exclusion;
---END---
---START---
reset enable_partition_pruning;
---END---
---START---

drop table listp;
---END---
---START---

-- Ensure run-time pruning works correctly for nested Append nodes
set parallel_setup_cost to 0;
---END---
---START---
set parallel_tuple_cost to 0;
---END---
---START---

create table listp (a int) partition by list(a);
---END---
---START---
create table listp_12 partition of listp for values in(1,2) partition by list(a);
---END---
---START---
create table listp_12_1 partition of listp_12 for values in(1);
---END---
---START---
create table listp_12_2 partition of listp_12 for values in(2);
---END---
---START---

-- Force the 2nd subnode of the Append to be non-parallel.  This results in
-- a nested Append node because the mixed parallel / non-parallel paths cannot
-- be pulled into the top-level Append.
alter table listp_12_1 set (parallel_workers = 0);
---END---
---START---

-- Ensure that listp_12_2 is not scanned.  (The nested Append is not seen in
-- the plan as it's pulled in setref.c due to having just a single subnode).
select explain_parallel_append('select * from listp where a = (select 1);');
---END---
---START---

-- Like the above but throw some more complexity at the planner by adding
-- a UNION ALL.  We expect both sides of the union not to scan the
-- non-required partitions.
select explain_parallel_append(
'select * from listp where a = (select 1)
  union all
select * from listp where a = (select 2);');
---END---
---START---

drop table listp;
---END---
---START---
reset parallel_tuple_cost;
---END---
---START---
reset parallel_setup_cost;
---END---
---START---

-- Test case for run-time pruning with a nested Merge Append
set enable_sort to 0;
---END---
---START---
create table rangep (a int, b int) partition by range (a);
---END---
---START---
create table rangep_0_to_100 partition of rangep for values from (0) to (100) partition by list (b);
---END---
---START---
-- We need 3 sub-partitions. 1 to validate pruning worked and another two
-- because a single remaining partition would be pulled up to the main Append.
create table rangep_0_to_100_1 partition of rangep_0_to_100 for values in(1);
---END---
---START---
create table rangep_0_to_100_2 partition of rangep_0_to_100 for values in(2);
---END---
---START---
create table rangep_0_to_100_3 partition of rangep_0_to_100 for values in(3);
---END---
---START---
create table rangep_100_to_200 partition of rangep for values from (100) to (200);
---END---
---START---
create index on rangep (a);
---END---
---START---

-- Ensure run-time pruning works on the nested Merge Append
explain (analyze on, costs off, timing off, summary off)
select * from rangep where b IN((select 1),(select 2)) order by a;
---END---
---START---
reset enable_sort;
---END---
---START---
drop table rangep;
---END---
---START---

--
-- Check that gen_prune_steps_from_opexps() works well for various cases of
-- clauses for different partition keys
--

create table rp_prefix_test1 (a int, b varchar) partition by range(a, b);
---END---
---START---
create table rp_prefix_test1_p1 partition of rp_prefix_test1 for values from (1, 'a') to (1, 'b');
---END---
---START---
create table rp_prefix_test1_p2 partition of rp_prefix_test1 for values from (2, 'a') to (2, 'b');
---END---
---START---

-- Don't call get_steps_using_prefix() with the last partition key b plus
-- an empty prefix
explain (costs off) select * from rp_prefix_test1 where a <= 1 and b = 'a';
---END---
---START---

create table rp_prefix_test2 (a int, b int, c int) partition by range(a, b, c);
---END---
---START---
create table rp_prefix_test2_p1 partition of rp_prefix_test2 for values from (1, 1, 0) to (1, 1, 10);
---END---
---START---
create table rp_prefix_test2_p2 partition of rp_prefix_test2 for values from (2, 2, 0) to (2, 2, 10);
---END---
---START---

-- Don't call get_steps_using_prefix() with the last partition key c plus
-- an invalid prefix (ie, b = 1)
explain (costs off) select * from rp_prefix_test2 where a <= 1 and b = 1 and c >= 0;
---END---
---START---

create table rp_prefix_test3 (a int, b int, c int, d int) partition by range(a, b, c, d);
---END---
---START---
create table rp_prefix_test3_p1 partition of rp_prefix_test3 for values from (1, 1, 1, 0) to (1, 1, 1, 10);
---END---
---START---
create table rp_prefix_test3_p2 partition of rp_prefix_test3 for values from (2, 2, 2, 0) to (2, 2, 2, 10);
---END---
---START---

-- Test that get_steps_using_prefix() handles a prefix that contains multiple
-- clauses for the partition key b (ie, b >= 1 and b >= 2)
explain (costs off) select * from rp_prefix_test3 where a >= 1 and b >= 1 and b >= 2 and c >= 2 and d >= 0;
---END---
---START---

-- Test that get_steps_using_prefix() handles a prefix that contains multiple
-- clauses for the partition key b (ie, b >= 1 and b = 2)  (This also tests
-- that the caller arranges clauses in that prefix in the required order)
explain (costs off) select * from rp_prefix_test3 where a >= 1 and b >= 1 and b = 2 and c = 2 and d >= 0;
---END---
---START---

create table hp_prefix_test (a int, b int, c int, d int) partition by hash (a part_test_int4_ops, b part_test_int4_ops, c part_test_int4_ops, d part_test_int4_ops);
---END---
---START---
create table hp_prefix_test_p1 partition of hp_prefix_test for values with (modulus 2, remainder 0);
---END---
---START---
create table hp_prefix_test_p2 partition of hp_prefix_test for values with (modulus 2, remainder 1);
---END---
---START---

-- Test that get_steps_using_prefix() handles non-NULL step_nullkeys
explain (costs off) select * from hp_prefix_test where a = 1 and b is null and c = 1 and d = 1;
---END---
---START---

drop table rp_prefix_test1;
---END---
---START---
drop table rp_prefix_test2;
---END---
---START---
drop table rp_prefix_test3;
---END---
---START---
drop table hp_prefix_test;
---END---
---START---

--
-- Check that gen_partprune_steps() detects self-contradiction from clauses
-- regardless of the order of the clauses (Here we use a custom operator to
-- prevent the equivclass.c machinery from reordering the clauses)
--

create operator === (
   leftarg = int4,
   rightarg = int4,
   procedure = int4eq,
   commutator = ===,
   hashes
);
---END---
---START---
create operator class part_test_int4_ops2
for type int4
using hash as
operator 1 ===,
function 2 part_hashint4_noop(int4, int8);
---END---
---START---

create table hp_contradict_test (a int, b int) partition by hash (a part_test_int4_ops2, b part_test_int4_ops2);
---END---
---START---
create table hp_contradict_test_p1 partition of hp_contradict_test for values with (modulus 2, remainder 0);
---END---
---START---
create table hp_contradict_test_p2 partition of hp_contradict_test for values with (modulus 2, remainder 1);
---END---
---START---

explain (costs off) select * from hp_contradict_test where a is null and a === 1 and b === 1;
---END---
---START---
explain (costs off) select * from hp_contradict_test where a === 1 and b === 1 and a is null;
---END---
---START---

drop table hp_contradict_test;
---END---
---START---
drop operator class part_test_int4_ops2 using hash;
---END---
---START---
drop operator ===(int4, int4);
---END---
