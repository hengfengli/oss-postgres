---START---
CREATE TABLE brintest (byteacol bytea,
	charcol "char",
	namecol name,
	int8col bigint,
	int2col smallint,
	int4col integer,
	textcol text,
	oidcol oid,
	tidcol tid,
	float4col real,
	float8col double precision,
	macaddrcol macaddr,
	inetcol inet,
	cidrcol cidr,
	bpcharcol character,
	datecol date,
	timecol time without time zone,
	timestampcol timestamp without time zone,
	timestamptzcol timestamp with time zone,
	intervalcol interval,
	timetzcol time with time zone,
	bitcol bit(10),
	varbitcol bit varying(16),
	numericcol numeric,
	uuidcol uuid,
	int4rangecol int4range,
	lsncol pg_lsn,
	boxcol box
) WITH (fillfactor=10, autovacuum_enabled=off);
---END---
---START---

INSERT INTO brintest SELECT
	repeat(stringu1, 8)::bytea,
	substr(stringu1, 1, 1)::"char",
	stringu1::name, 142857 * tenthous,
	thousand,
	twothousand,
	repeat(stringu1, 8),
	unique1::oid,
	format('(%s,%s)', tenthous, twenty)::tid,
	(four + 1.0)/(hundred+1),
	odd::float8 / (tenthous + 1),
	format('%s:00:%s:00:%s:00', to_hex(odd), to_hex(even), to_hex(hundred))::macaddr,
	inet '10.2.3.4/24' + tenthous,
	cidr '10.2.3/24' + tenthous,
	substr(stringu1, 1, 1)::bpchar,
	date '1995-08-15' + tenthous,
	time '01:20:30' + thousand * interval '18.5 second',
	timestamp '1942-07-23 03:05:09' + tenthous * interval '36.38 hours',
	timestamptz '1972-10-10 03:00' + thousand * interval '1 hour',
	justify_days(justify_hours(tenthous * interval '12 minutes')),
	timetz '01:30:20+02' + hundred * interval '15 seconds',
	thousand::bit(10),
	tenthous::bit(16)::varbit,
	tenthous::numeric(36,30) * fivethous * even / (hundred + 1),
	format('%s%s-%s-%s-%s-%s%s%s', to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'))::uuid,
	int4range(thousand, twothousand),
	format('%s/%s%s', odd, even, tenthous)::pg_lsn,
	box(point(odd, even), point(thousand, twothousand))
FROM tenk1 ORDER BY unique2 LIMIT 100;
---END---
---START---

-- throw in some NULL's and different values
INSERT INTO brintest (inetcol, cidrcol, int4rangecol) SELECT
	inet 'fe80::6e40:8ff:fea9:8c46' + tenthous,
	cidr 'fe80::6e40:8ff:fea9:8c46' + tenthous,
	'empty'::int4range
FROM tenk1 ORDER BY thousand, tenthous LIMIT 25;
---END---
---START---

CREATE INDEX brinidx ON brintest USING brin (
	byteacol,
	charcol,
	namecol,
	int8col,
	int2col,
	int4col,
	textcol,
	oidcol,
	tidcol,
	float4col,
	float8col,
	macaddrcol,
	inetcol inet_inclusion_ops,
	inetcol inet_minmax_ops,
	cidrcol inet_inclusion_ops,
	cidrcol inet_minmax_ops,
	bpcharcol,
	datecol,
	timecol,
	timestampcol,
	timestamptzcol,
	intervalcol,
	timetzcol,
	bitcol,
	varbitcol,
	numericcol,
	uuidcol,
	int4rangecol,
	lsncol,
	boxcol
) with (pages_per_range = 1);
---END---
---START---

CREATE TABLE brinopers (colname name, typ text,
	op text[], value text[], matches int[],
	check (cardinality(op) = cardinality(value)),
	check (cardinality(op) = cardinality(matches)));
---END---
---START---

INSERT INTO brinopers VALUES
	('byteacol', 'bytea',
	 '{>, >=, =, <=, <}',
	 '{AAAAAA, AAAAAA, BNAAAABNAAAABNAAAABNAAAABNAAAABNAAAABNAAAABNAAAA, ZZZZZZ, ZZZZZZ}',
	 '{100, 100, 1, 100, 100}'),
	('charcol', '"char"',
	 '{>, >=, =, <=, <}',
	 '{A, A, M, Z, Z}',
	 '{97, 100, 6, 100, 98}'),
	('namecol', 'name',
	 '{>, >=, =, <=, <}',
	 '{AAAAAA, AAAAAA, MAAAAA, ZZAAAA, ZZAAAA}',
	 '{100, 100, 2, 100, 100}'),
	('int2col', 'int2',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 999, 999}',
	 '{100, 100, 1, 100, 100}'),
	('int2col', 'int4',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 999, 1999}',
	 '{100, 100, 1, 100, 100}'),
	('int2col', 'int8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 999, 1428427143}',
	 '{100, 100, 1, 100, 100}'),
	('int4col', 'int2',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 1999, 1999}',
	 '{100, 100, 1, 100, 100}'),
	('int4col', 'int4',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 1999, 1999}',
	 '{100, 100, 1, 100, 100}'),
	('int4col', 'int8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 800, 1999, 1428427143}',
	 '{100, 100, 1, 100, 100}'),
	('int8col', 'int2',
	 '{>, >=}',
	 '{0, 0}',
	 '{100, 100}'),
	('int8col', 'int4',
	 '{>, >=}',
	 '{0, 0}',
	 '{100, 100}'),
	('int8col', 'int8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 1257141600, 1428427143, 1428427143}',
	 '{100, 100, 1, 100, 100}'),
	('textcol', 'text',
	 '{>, >=, =, <=, <}',
	 '{ABABAB, ABABAB, BNAAAABNAAAABNAAAABNAAAABNAAAABNAAAABNAAAABNAAAA, ZZAAAA, ZZAAAA}',
	 '{100, 100, 1, 100, 100}'),
	('oidcol', 'oid',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 8800, 9999, 9999}',
	 '{100, 100, 1, 100, 100}'),
	('tidcol', 'tid',
	 '{>, >=, =, <=, <}',
	 '{"(0,0)", "(0,0)", "(8800,0)", "(9999,19)", "(9999,19)"}',
	 '{100, 100, 1, 100, 100}'),
	('float4col', 'float4',
	 '{>, >=, =, <=, <}',
	 '{0.0103093, 0.0103093, 1, 1, 1}',
	 '{100, 100, 4, 100, 96}'),
	('float4col', 'float8',
	 '{>, >=, =, <=, <}',
	 '{0.0103093, 0.0103093, 1, 1, 1}',
	 '{100, 100, 4, 100, 96}'),
	('float8col', 'float4',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 0, 1.98, 1.98}',
	 '{99, 100, 1, 100, 100}'),
	('float8col', 'float8',
	 '{>, >=, =, <=, <}',
	 '{0, 0, 0, 1.98, 1.98}',
	 '{99, 100, 1, 100, 100}'),
	('macaddrcol', 'macaddr',
	 '{>, >=, =, <=, <}',
	 '{00:00:01:00:00:00, 00:00:01:00:00:00, 2c:00:2d:00:16:00, ff:fe:00:00:00:00, ff:fe:00:00:00:00}',
	 '{99, 100, 2, 100, 100}'),
	('inetcol', 'inet',
	 '{&&, =, <, <=, >, >=, >>=, >>, <<=, <<}',
	 '{10/8, 10.2.14.231/24, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0, 10.2.14.231/24, 10.2.14.231/25, 10.2.14.231/8, 0/0}',
	 '{100, 1, 100, 100, 125, 125, 2, 2, 100, 100}'),
	('inetcol', 'inet',
	 '{&&, >>=, <<=, =}',
	 '{fe80::6e40:8ff:fea9:a673/32, fe80::6e40:8ff:fea9:8c46, fe80::6e40:8ff:fea9:a673/32, fe80::6e40:8ff:fea9:8c46}',
	 '{25, 1, 25, 1}'),
	('inetcol', 'cidr',
	 '{&&, <, <=, >, >=, >>=, >>, <<=, <<}',
	 '{10/8, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0, 10.2.14/24, 10.2.14/25, 10/8, 0/0}',
	 '{100, 100, 100, 125, 125, 2, 2, 100, 100}'),
	('inetcol', 'cidr',
	 '{&&, >>=, <<=, =}',
	 '{fe80::/32, fe80::6e40:8ff:fea9:8c46, fe80::/32, fe80::6e40:8ff:fea9:8c46}',
	 '{25, 1, 25, 1}'),
	('cidrcol', 'inet',
	 '{&&, =, <, <=, >, >=, >>=, >>, <<=, <<}',
	 '{10/8, 10.2.14/24, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0, 10.2.14.231/24, 10.2.14.231/25, 10.2.14.231/8, 0/0}',
	 '{100, 2, 100, 100, 125, 125, 2, 2, 100, 100}'),
	('cidrcol', 'inet',
	 '{&&, >>=, <<=, =}',
	 '{fe80::6e40:8ff:fea9:a673/32, fe80::6e40:8ff:fea9:8c46, fe80::6e40:8ff:fea9:a673/32, fe80::6e40:8ff:fea9:8c46}',
	 '{25, 1, 25, 1}'),
	('cidrcol', 'cidr',
	 '{&&, =, <, <=, >, >=, >>=, >>, <<=, <<}',
	 '{10/8, 10.2.14/24, 255.255.255.255, 255.255.255.255, 0.0.0.0, 0.0.0.0, 10.2.14/24, 10.2.14/25, 10/8, 0/0}',
	 '{100, 2, 100, 100, 125, 125, 2, 2, 100, 100}'),
	('cidrcol', 'cidr',
	 '{&&, >>=, <<=, =}',
	 '{fe80::/32, fe80::6e40:8ff:fea9:8c46, fe80::/32, fe80::6e40:8ff:fea9:8c46}',
	 '{25, 1, 25, 1}'),
	('bpcharcol', 'bpchar',
	 '{>, >=, =, <=, <}',
	 '{A, A, W, Z, Z}',
	 '{97, 100, 6, 100, 98}'),
	('datecol', 'date',
	 '{>, >=, =, <=, <}',
	 '{1995-08-15, 1995-08-15, 2009-12-01, 2022-12-30, 2022-12-30}',
	 '{100, 100, 1, 100, 100}'),
	('timecol', 'time',
	 '{>, >=, =, <=, <}',
	 '{01:20:30, 01:20:30, 02:28:57, 06:28:31.5, 06:28:31.5}',
	 '{100, 100, 1, 100, 100}'),
	('timestampcol', 'timestamp',
	 '{>, >=, =, <=, <}',
	 '{1942-07-23 03:05:09, 1942-07-23 03:05:09, 1964-03-24 19:26:45, 1984-01-20 22:42:21, 1984-01-20 22:42:21}',
	 '{100, 100, 1, 100, 100}'),
	('timestampcol', 'timestamptz',
	 '{>, >=, =, <=, <}',
	 '{1942-07-23 03:05:09, 1942-07-23 03:05:09, 1964-03-24 19:26:45, 1984-01-20 22:42:21, 1984-01-20 22:42:21}',
	 '{100, 100, 1, 100, 100}'),
	('timestamptzcol', 'timestamptz',
	 '{>, >=, =, <=, <}',
	 '{1972-10-10 03:00:00-04, 1972-10-10 03:00:00-04, 1972-10-19 09:00:00-07, 1972-11-20 19:00:00-03, 1972-11-20 19:00:00-03}',
	 '{100, 100, 1, 100, 100}'),
	('intervalcol', 'interval',
	 '{>, >=, =, <=, <}',
	 '{00:00:00, 00:00:00, 1 mons 13 days 12:24, 2 mons 23 days 07:48:00, 1 year}',
	 '{100, 100, 1, 100, 100}'),
	('timetzcol', 'timetz',
	 '{>, >=, =, <=, <}',
	 '{01:30:20+02, 01:30:20+02, 01:35:50+02, 23:55:05+02, 23:55:05+02}',
	 '{99, 100, 2, 100, 100}'),
	('bitcol', 'bit(10)',
	 '{>, >=, =, <=, <}',
	 '{0000000010, 0000000010, 0011011110, 1111111000, 1111111000}',
	 '{100, 100, 1, 100, 100}'),
	('varbitcol', 'varbit(16)',
	 '{>, >=, =, <=, <}',
	 '{0000000000000100, 0000000000000100, 0001010001100110, 1111111111111000, 1111111111111000}',
	 '{100, 100, 1, 100, 100}'),
	('numericcol', 'numeric',
	 '{>, >=, =, <=, <}',
	 '{0.00, 0.01, 2268164.347826086956521739130434782609, 99470151.9, 99470151.9}',
	 '{100, 100, 1, 100, 100}'),
	('uuidcol', 'uuid',
	 '{>, >=, =, <=, <}',
	 '{00040004-0004-0004-0004-000400040004, 00040004-0004-0004-0004-000400040004, 52225222-5222-5222-5222-522252225222, 99989998-9998-9998-9998-999899989998, 99989998-9998-9998-9998-999899989998}',
	 '{100, 100, 1, 100, 100}'),
	('int4rangecol', 'int4range',
	 '{<<, &<, &&, &>, >>, @>, <@, =, <, <=, >, >=}',
	 '{"[10000,)","[10000,)","(,]","[3,4)","[36,44)","(1500,1501]","[3,4)","[222,1222)","[36,44)","[43,1043)","[367,4466)","[519,)"}',
	 '{53, 53, 53, 53, 50, 22, 72, 1, 74, 75, 34, 21}'),
	('int4rangecol', 'int4range',
	 '{@>, <@, =, <=, >, >=}',
	 '{empty, empty, empty, empty, empty, empty}',
	 '{125, 72, 72, 72, 53, 125}'),
	('int4rangecol', 'int4',
	 '{@>}',
	 '{1500}',
	 '{22}'),
	('lsncol', 'pg_lsn',
	 '{>, >=, =, <=, <, IS, IS NOT}',
	 '{0/1200, 0/1200, 44/455222, 198/1999799, 198/1999799, NULL, NULL}',
	 '{100, 100, 1, 100, 100, 25, 100}'),
	('boxcol', 'point',
	 '{@>}',
	 '{"(500,43)"}',
	 '{11}'),
	('boxcol', 'box',
	 '{<<, &<, &&, &>, >>, <<|, &<|, |&>, |>>, @>, <@, ~=}',
	 '{"((1000,2000),(3000,4000))","((1,2),(3000,4000))","((1,2),(3000,4000))","((1,2),(3000,4000))","((1,2),(3,4))","((1000,2000),(3000,4000))","((1,2000),(3,4000))","((1000,2),(3000,4))","((1,2),(3,4))","((1,2),(300,400))","((1,2),(3000,4000))","((222,1222),(44,45))"}',
	 '{100, 100, 100, 99, 96, 100, 100, 99, 96, 1, 99, 1}');
---END---
---START---

DO $x$
DECLARE
	r record;
---END---
---START---
	r2 record;
---END---
---START---
	cond text;
---END---
---START---
	idx_ctids tid[];
---END---
---START---
	ss_ctids tid[];
---END---
---START---
	count int;
---END---
---START---
	plan_ok bool;
---END---
---START---
	plan_line text;
---END---
---START---
BEGIN
	FOR r IN SELECT colname, oper, typ, value[ordinality], matches[ordinality] FROM brinopers, unnest(op) WITH ORDINALITY AS oper LOOP

		-- prepare the condition
		IF r.value IS NULL THEN
			cond := format('%I %s %L', r.colname, r.oper, r.value);
---END---
---START---
		ELSE
			cond := format('%I %s %L::%s', r.colname, r.oper, r.value, r.typ);
---END---
---START---
		END IF;
---END---
---START---

		-- run the query using the brin index
		SET enable_seqscan = 0;
---END---
---START---
		SET enable_bitmapscan = 1;
---END---
---START---

		plan_ok := false;
---END---
---START---
		FOR plan_line IN EXECUTE format($y$EXPLAIN SELECT array_agg(ctid) FROM brintest WHERE %s $y$, cond) LOOP
			IF plan_line LIKE '%Bitmap Heap Scan on brintest%' THEN
				plan_ok := true;
---END---
---START---
			END IF;
---END---
---START---
		END LOOP;
---END---
---START---
		IF NOT plan_ok THEN
			RAISE WARNING 'did not get bitmap indexscan plan for %', r;
---END---
---START---
		END IF;
---END---
---START---

		EXECUTE format($y$SELECT array_agg(ctid) FROM brintest WHERE %s $y$, cond)
			INTO idx_ctids;
---END---
---START---

		-- run the query using a seqscan
		SET enable_seqscan = 1;
---END---
---START---
		SET enable_bitmapscan = 0;
---END---
---START---

		plan_ok := false;
---END---
---START---
		FOR plan_line IN EXECUTE format($y$EXPLAIN SELECT array_agg(ctid) FROM brintest WHERE %s $y$, cond) LOOP
			IF plan_line LIKE '%Seq Scan on brintest%' THEN
				plan_ok := true;
---END---
---START---
			END IF;
---END---
---START---
		END LOOP;
---END---
---START---
		IF NOT plan_ok THEN
			RAISE WARNING 'did not get seqscan plan for %', r;
---END---
---START---
		END IF;
---END---
---START---

		EXECUTE format($y$SELECT array_agg(ctid) FROM brintest WHERE %s $y$, cond)
			INTO ss_ctids;
---END---
---START---

		-- make sure both return the same results
		count := array_length(idx_ctids, 1);
---END---
---START---

		IF NOT (count = array_length(ss_ctids, 1) AND
				idx_ctids @> ss_ctids AND
				idx_ctids <@ ss_ctids) THEN
			-- report the results of each scan to make the differences obvious
			RAISE WARNING 'something not right in %: count %', r, count;
---END---
---START---
			SET enable_seqscan = 1;
---END---
---START---
			SET enable_bitmapscan = 0;
---END---
---START---
			FOR r2 IN EXECUTE 'SELECT ' || r.colname || ' FROM brintest WHERE ' || cond LOOP
				RAISE NOTICE 'seqscan: %', r2;
---END---
---START---
			END LOOP;
---END---
---START---

			SET enable_seqscan = 0;
---END---
---START---
			SET enable_bitmapscan = 1;
---END---
---START---
			FOR r2 IN EXECUTE 'SELECT ' || r.colname || ' FROM brintest WHERE ' || cond LOOP
				RAISE NOTICE 'bitmapscan: %', r2;
---END---
---START---
			END LOOP;
---END---
---START---
		END IF;
---END---
---START---

		-- make sure we found expected number of matches
		IF count != r.matches THEN RAISE WARNING 'unexpected number of results % for %', count, r; END IF;
---END---
---START---
	END LOOP;
---END---
---START---
END;
---END---
---START---
$x$;
---END---
---START---

RESET enable_seqscan;
---END---
---START---
RESET enable_bitmapscan;
---END---
---START---

INSERT INTO brintest SELECT
	repeat(stringu1, 42)::bytea,
	substr(stringu1, 1, 1)::"char",
	stringu1::name, 142857 * tenthous,
	thousand,
	twothousand,
	repeat(stringu1, 42),
	unique1::oid,
	format('(%s,%s)', tenthous, twenty)::tid,
	(four + 1.0)/(hundred+1),
	odd::float8 / (tenthous + 1),
	format('%s:00:%s:00:%s:00', to_hex(odd), to_hex(even), to_hex(hundred))::macaddr,
	inet '10.2.3.4' + tenthous,
	cidr '10.2.3/24' + tenthous,
	substr(stringu1, 1, 1)::bpchar,
	date '1995-08-15' + tenthous,
	time '01:20:30' + thousand * interval '18.5 second',
	timestamp '1942-07-23 03:05:09' + tenthous * interval '36.38 hours',
	timestamptz '1972-10-10 03:00' + thousand * interval '1 hour',
	justify_days(justify_hours(tenthous * interval '12 minutes')),
	timetz '01:30:20' + hundred * interval '15 seconds',
	thousand::bit(10),
	tenthous::bit(16)::varbit,
	tenthous::numeric(36,30) * fivethous * even / (hundred + 1),
	format('%s%s-%s-%s-%s-%s%s%s', to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'), to_char(tenthous, 'FM0000'))::uuid,
	int4range(thousand, twothousand),
	format('%s/%s%s', odd, even, tenthous)::pg_lsn,
	box(point(odd, even), point(thousand, twothousand))
FROM tenk1 ORDER BY unique2 LIMIT 5 OFFSET 5;
---END---
---START---

SELECT brin_desummarize_range('brinidx', 0);
---END---
---START---
VACUUM brintest;  -- force a summarization cycle in brinidx

UPDATE brintest SET int8col = int8col * int4col;
---END---
---START---
UPDATE brintest SET textcol = '' WHERE textcol IS NOT NULL;
---END---
---START---

-- Tests for brin_summarize_new_values
SELECT brin_summarize_new_values('brintest'); -- error, not an index
SELECT brin_summarize_new_values('tenk1_unique1'); -- error, not a BRIN index
SELECT brin_summarize_new_values('brinidx'); -- ok, no change expected

-- Tests for brin_desummarize_range
SELECT brin_desummarize_range('brinidx', -1); -- error, invalid range
SELECT brin_desummarize_range('brinidx', 0);
---END---
---START---
SELECT brin_desummarize_range('brinidx', 0);
---END---
---START---
SELECT brin_desummarize_range('brinidx', 100000000);
---END---
---START---

-- Test brin_summarize_range
CREATE TABLE brin_summarize (
    value int
) WITH (fillfactor=10, autovacuum_enabled=false);
---END---
---START---
CREATE INDEX brin_summarize_idx ON brin_summarize USING brin (value) WITH (pages_per_range=2);
---END---
---START---
-- Fill a few pages
DO $$
DECLARE curtid tid;
---END---
---START---
BEGIN
  LOOP
    INSERT INTO brin_summarize VALUES (1) RETURNING ctid INTO curtid;
---END---
---START---
    EXIT WHEN curtid > tid '(2, 0)';
---END---
---START---
  END LOOP;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

-- summarize one range
SELECT brin_summarize_range('brin_summarize_idx', 0);
---END---
---START---
-- nothing: already summarized
SELECT brin_summarize_range('brin_summarize_idx', 1);
---END---
---START---
-- summarize one range
SELECT brin_summarize_range('brin_summarize_idx', 2);
---END---
---START---
-- nothing: page doesn't exist in table
SELECT brin_summarize_range('brin_summarize_idx', 4294967295);
---END---
---START---
-- invalid block number values
SELECT brin_summarize_range('brin_summarize_idx', -1);
---END---
---START---
SELECT brin_summarize_range('brin_summarize_idx', 4294967296);
---END---
---START---

-- test value merging in add_value
CREATE TABLE brintest_2 (n numrange);
---END---
---START---
CREATE INDEX brinidx_2 ON brintest_2 USING brin (n);
---END---
---START---
INSERT INTO brintest_2 VALUES ('empty');
---END---
---START---
INSERT INTO brintest_2 VALUES (numrange(0, 2^1000::numeric));
---END---
---START---
INSERT INTO brintest_2 VALUES ('(-1, 0)');
---END---
---START---

SELECT brin_desummarize_range('brinidx', 0);
---END---
---START---
SELECT brin_summarize_range('brinidx', 0);
---END---
---START---
DROP TABLE brintest_2;
---END---
---START---

-- test brin cost estimates behave sanely based on correlation of values
CREATE TABLE brin_test (a INT, b INT);
---END---
---START---
INSERT INTO brin_test SELECT x/100,x%100 FROM generate_series(1,10000) x(x);
---END---
---START---
CREATE INDEX brin_test_a_idx ON brin_test USING brin (a) WITH (pages_per_range = 2);
---END---
---START---
CREATE INDEX brin_test_b_idx ON brin_test USING brin (b) WITH (pages_per_range = 2);
---END---
---START---
VACUUM ANALYZE brin_test;
---END---
---START---

-- Ensure brin index is used when columns are perfectly correlated
EXPLAIN (COSTS OFF) SELECT * FROM brin_test WHERE a = 1;
---END---
---START---
-- Ensure brin index is not used when values are not correlated
EXPLAIN (COSTS OFF) SELECT * FROM brin_test WHERE b = 1;
---END---
---START---

-- make sure data are properly de-toasted in BRIN index
CREATE TABLE brintest_3 (a text, b text, c text, d text);
---END---
---START---

-- long random strings (~2000 chars each, so ~6kB for min/max on two
-- columns) to trigger toasting
WITH rand_value AS (SELECT string_agg(fipshash(i::text),'') AS val FROM generate_series(1,60) s(i))
INSERT INTO brintest_3
SELECT val, val, val, val FROM rand_value;
---END---
---START---

CREATE INDEX brin_test_toast_idx ON brintest_3 USING brin (b, c);
---END---
---START---
DELETE FROM brintest_3;
---END---
---START---

-- We need to wait a bit for all transactions to complete, so that the
-- vacuum actually removes the TOAST rows. Creating an index concurrently
-- is a one way to achieve that, because it does exactly such wait.
CREATE INDEX CONCURRENTLY brin_test_temp_idx ON brintest_3(a);
---END---
---START---
DROP INDEX brin_test_temp_idx;
---END---
---START---

-- vacuum the table, to discard TOAST data
VACUUM brintest_3;
---END---
---START---

-- retry insert with a different random-looking (but deterministic) value
-- the value is different, and so should replace either min or max in the
-- brin summary
WITH rand_value AS (SELECT string_agg(fipshash((-i)::text),'') AS val FROM generate_series(1,60) s(i))
INSERT INTO brintest_3
SELECT val, val, val, val FROM rand_value;
---END---
---START---

-- now try some queries, accessing the brin index
SET enable_seqscan = off;
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT * FROM brintest_3 WHERE b < '0';
---END---
---START---

SELECT * FROM brintest_3 WHERE b < '0';
---END---
---START---

DROP TABLE brintest_3;
---END---
---START---
RESET enable_seqscan;
---END---
---START---

-- test an unlogged table, mostly to get coverage of brinbuildempty
CREATE UNLOGGED TABLE brintest_unlogged (n numrange);
---END---
---START---
CREATE INDEX brinidx_unlogged ON brintest_unlogged USING brin (n);
---END---
---START---
INSERT INTO brintest_unlogged VALUES (numrange(0, 2^1000::numeric));
---END---
---START---
DROP TABLE brintest_unlogged;
---END---
