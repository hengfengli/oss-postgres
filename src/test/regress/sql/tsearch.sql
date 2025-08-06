---START---
-- directory paths are passed to us in environment variables
\getenv abs_srcdir PG_ABS_SRCDIR

--
-- Sanity checks for text search catalogs
--
-- NB: we assume the oidjoins test will have caught any dangling links,
-- that is OID or REGPROC fields that are not zero and do not match some
-- row in the linked-to table.  However, if we want to enforce that a link
-- field can't be 0, we have to check it here.

-- Find unexpected zero link entries

SELECT oid, prsname
FROM pg_ts_parser
WHERE prsnamespace = 0 OR prsstart = 0 OR prstoken = 0 OR prsend = 0 OR
      -- prsheadline is optional
      prslextype = 0;
---END---
---START---

SELECT oid, dictname
FROM pg_ts_dict
WHERE dictnamespace = 0 OR dictowner = 0 OR dicttemplate = 0;
---END---
---START---

SELECT oid, tmplname
FROM pg_ts_template
WHERE tmplnamespace = 0 OR tmpllexize = 0;  -- tmplinit is optional

SELECT oid, cfgname
FROM pg_ts_config
WHERE cfgnamespace = 0 OR cfgowner = 0 OR cfgparser = 0;
---END---
---START---

SELECT mapcfg, maptokentype, mapseqno
FROM pg_ts_config_map
WHERE mapcfg = 0 OR mapdict = 0;
---END---
---START---

-- Look for pg_ts_config_map entries that aren't one of parser's token types
SELECT * FROM
  ( SELECT oid AS cfgid, (ts_token_type(cfgparser)).tokid AS tokid
    FROM pg_ts_config ) AS tt
RIGHT JOIN pg_ts_config_map AS m
    ON (tt.cfgid=m.mapcfg AND tt.tokid=m.maptokentype)
WHERE
    tt.cfgid IS NULL OR tt.tokid IS NULL;
---END---
---START---

-- Load some test data
CREATE TABLE test_tsvector(
	t text,
	a tsvector
);
---END---
---START---

\set filename :abs_srcdir '/data/tsearch.data'
COPY test_tsvector FROM :'filename';
---END---
---START---

ANALYZE test_tsvector;
---END---
---START---

-- test basic text search behavior without indexes, then with

SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr&qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq&yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq|yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq&yt)|(wr&qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq|yt)&(wr|qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'w:*|q:*';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ any ('{wr,qh}');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> !yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(pl <-> yh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(yh <-> pl)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(qe <2> qt)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:D';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:D';
---END---
---START---

create index wowidx on test_tsvector using gist (a);
---END---
---START---

SET enable_seqscan=OFF;
---END---
---START---
SET enable_indexscan=ON;
---END---
---START---
SET enable_bitmapscan=OFF;
---END---
---START---

explain (costs off) SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr&qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq&yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq|yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq&yt)|(wr&qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq|yt)&(wr|qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'w:*|q:*';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ any ('{wr,qh}');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> !yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(pl <-> yh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(yh <-> pl)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(qe <2> qt)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:D';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:D';
---END---
---START---

SET enable_indexscan=OFF;
---END---
---START---
SET enable_bitmapscan=ON;
---END---
---START---

explain (costs off) SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr&qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq&yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq|yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq&yt)|(wr&qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq|yt)&(wr|qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'w:*|q:*';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ any ('{wr,qh}');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> !yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(pl <-> yh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(yh <-> pl)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(qe <2> qt)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:D';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:D';
---END---
---START---

-- Test siglen parameter of GiST tsvector_ops
CREATE INDEX wowidx1 ON test_tsvector USING gist (a tsvector_ops(foo=1));
---END---
---START---
CREATE INDEX wowidx1 ON test_tsvector USING gist (a tsvector_ops(siglen=0));
---END---
---START---
CREATE INDEX wowidx1 ON test_tsvector USING gist (a tsvector_ops(siglen=2048));
---END---
---START---
CREATE INDEX wowidx1 ON test_tsvector USING gist (a tsvector_ops(siglen=100,foo='bar'));
---END---
---START---
CREATE INDEX wowidx1 ON test_tsvector USING gist (a tsvector_ops(siglen=100, siglen = 200));
---END---
---START---

CREATE INDEX wowidx2 ON test_tsvector USING gist (a tsvector_ops(siglen=1));
---END---
---START---

\d test_tsvector

DROP INDEX wowidx;
---END---
---START---

EXPLAIN (costs off) SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr&qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq&yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq|yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq&yt)|(wr&qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq|yt)&(wr|qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'w:*|q:*';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ any ('{wr,qh}');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> !yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(pl <-> yh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(yh <-> pl)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(qe <2> qt)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:D';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:D';
---END---
---START---

DROP INDEX wowidx2;
---END---
---START---

CREATE INDEX wowidx ON test_tsvector USING gist (a tsvector_ops(siglen=484));
---END---
---START---

\d test_tsvector

EXPLAIN (costs off) SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr&qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq&yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq|yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq&yt)|(wr&qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq|yt)&(wr|qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'w:*|q:*';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ any ('{wr,qh}');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> !yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(pl <-> yh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(yh <-> pl)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(qe <2> qt)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:D';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:D';
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

DROP INDEX wowidx;
---END---
---START---

CREATE INDEX wowidx ON test_tsvector USING gin (a);
---END---
---START---

SET enable_seqscan=OFF;
---END---
---START---
-- GIN only supports bitmapscan, so no need to test plain indexscan

explain (costs off) SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ 'wr|qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr&qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq&yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'eq|yt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq&yt)|(wr&qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '(eq|yt)&(wr|qh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'w:*|q:*';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ any ('{wr,qh}');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!no_such_lexeme';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!pl <-> !yh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!yh <-> pl';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qe <2> qt';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(pl <-> yh)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(yh <-> pl)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!(qe <2> qt)';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wd:D';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:A';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!wd:D';
---END---
---START---

-- Test optimization of non-empty GIN_SEARCH_MODE_ALL queries
EXPLAIN (COSTS OFF)
SELECT count(*) FROM test_tsvector WHERE a @@ '!qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ '!qh';
---END---
---START---

EXPLAIN (COSTS OFF)
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr' AND a @@ '!qh';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ 'wr' AND a @@ '!qh';
---END---
---START---

RESET enable_seqscan;
---END---
---START---

INSERT INTO test_tsvector VALUES ('???', 'DFG:1A,2B,6C,10 FGH');
---END---
---START---
SELECT * FROM ts_stat('SELECT a FROM test_tsvector') ORDER BY ndoc DESC, nentry DESC, word LIMIT 10;
---END---
---START---
SELECT * FROM ts_stat('SELECT a FROM test_tsvector', 'AB') ORDER BY ndoc DESC, nentry DESC, word;
---END---
---START---

--dictionaries and to_tsvector

SELECT ts_lexize('english_stem', 'skies');
---END---
---START---
SELECT ts_lexize('english_stem', 'identity');
---END---
---START---

SELECT * FROM ts_token_type('default');
---END---
---START---

SELECT * FROM ts_parse('default', '345 qwe@efd.r '' http://www.com/ http://aew.werc.ewr/?ad=qwe&dw 1aew.werc.ewr/?ad=qwe&dw 2aew.werc.ewr http://3aew.werc.ewr/?ad=qwe&dw http://4aew.werc.ewr http://5aew.werc.ewr:8100/?  ad=qwe&dw 6aew.werc.ewr:8100/?ad=qwe&dw 7aew.werc.ewr:8100/?ad=qwe&dw=%20%32 +4.0e-10 qwe qwe qwqwe 234.435 455 5.005 teodor@stack.net teodor@123-stack.net 123_teodor@stack.net 123-teodor@stack.net qwe-wer asdf <fr>qwer jf sdjk<we hjwer <werrwe> ewr1> ewri2 <a href="qwe<qwe>">
/usr/local/fff /awdf/dwqe/4325 rewt/ewr wefjn /wqe-324/ewr gist.h gist.h.c gist.c. readline 4.2 4.2. 4.2, readline-4.2 readline-4.2. 234
<i <b> wow  < jqw <> qwerty');
---END---
---START---

SELECT to_tsvector('english', '345 qwe@efd.r '' http://www.com/ http://aew.werc.ewr/?ad=qwe&dw 1aew.werc.ewr/?ad=qwe&dw 2aew.werc.ewr http://3aew.werc.ewr/?ad=qwe&dw http://4aew.werc.ewr http://5aew.werc.ewr:8100/?  ad=qwe&dw 6aew.werc.ewr:8100/?ad=qwe&dw 7aew.werc.ewr:8100/?ad=qwe&dw=%20%32 +4.0e-10 qwe qwe qwqwe 234.435 455 5.005 teodor@stack.net teodor@123-stack.net 123_teodor@stack.net 123-teodor@stack.net qwe-wer asdf <fr>qwer jf sdjk<we hjwer <werrwe> ewr1> ewri2 <a href="qwe<qwe>">
/usr/local/fff /awdf/dwqe/4325 rewt/ewr wefjn /wqe-324/ewr gist.h gist.h.c gist.c. readline 4.2 4.2. 4.2, readline-4.2 readline-4.2. 234
<i <b> wow  < jqw <> qwerty');
---END---
---START---

SELECT length(to_tsvector('english', '345 qwe@efd.r '' http://www.com/ http://aew.werc.ewr/?ad=qwe&dw 1aew.werc.ewr/?ad=qwe&dw 2aew.werc.ewr http://3aew.werc.ewr/?ad=qwe&dw http://4aew.werc.ewr http://5aew.werc.ewr:8100/?  ad=qwe&dw 6aew.werc.ewr:8100/?ad=qwe&dw 7aew.werc.ewr:8100/?ad=qwe&dw=%20%32 +4.0e-10 qwe qwe qwqwe 234.435 455 5.005 teodor@stack.net teodor@123-stack.net 123_teodor@stack.net 123-teodor@stack.net qwe-wer asdf <fr>qwer jf sdjk<we hjwer <werrwe> ewr1> ewri2 <a href="qwe<qwe>">
/usr/local/fff /awdf/dwqe/4325 rewt/ewr wefjn /wqe-324/ewr gist.h gist.h.c gist.c. readline 4.2 4.2. 4.2, readline-4.2 readline-4.2. 234
<i <b> wow  < jqw <> qwerty'));
---END---
---START---

-- ts_debug

SELECT * from ts_debug('english', '<myns:foo-bar_baz.blurfl>abc&nm1;def&#xa9;ghi&#245;jkl</myns:foo-bar_baz.blurfl>');
---END---
---START---

-- check parsing of URLs
SELECT * from ts_debug('english', 'http://www.harewoodsolutions.co.uk/press.aspx</span>');
---END---
---START---
SELECT * from ts_debug('english', 'http://aew.wer0c.ewr/id?ad=qwe&dw<span>');
---END---
---START---
SELECT * from ts_debug('english', 'http://5aew.werc.ewr:8100/?');
---END---
---START---
SELECT * from ts_debug('english', '5aew.werc.ewr:8100/?xx');
---END---
---START---
SELECT token, alias,
  dictionaries, dictionaries is null as dnull, array_dims(dictionaries) as ddims,
  lexemes, lexemes is null as lnull, array_dims(lexemes) as ldims
from ts_debug('english', 'a title');
---END---
---START---

-- to_tsquery

SELECT to_tsquery('english', 'qwe & sKies ');
---END---
---START---
SELECT to_tsquery('simple', 'qwe & sKies ');
---END---
---START---
SELECT to_tsquery('english', '''the wether'':dc & ''           sKies '':BC ');
---END---
---START---
SELECT to_tsquery('english', 'asd&(and|fghj)');
---END---
---START---
SELECT to_tsquery('english', '(asd&and)|fghj');
---END---
---START---
SELECT to_tsquery('english', '(asd&!and)|fghj');
---END---
---START---
SELECT to_tsquery('english', '(the|and&(i&1))&fghj');
---END---
---START---

SELECT plainto_tsquery('english', 'the and z 1))& fghj');
---END---
---START---
SELECT plainto_tsquery('english', 'foo bar') && plainto_tsquery('english', 'asd');
---END---
---START---
SELECT plainto_tsquery('english', 'foo bar') || plainto_tsquery('english', 'asd fg');
---END---
---START---
SELECT plainto_tsquery('english', 'foo bar') || !!plainto_tsquery('english', 'asd fg');
---END---
---START---
SELECT plainto_tsquery('english', 'foo bar') && 'asd | fg';
---END---
---START---

-- Check stop word deletion, a and s are stop-words
SELECT to_tsquery('english', '!(a & !b) & c');
---END---
---START---
SELECT to_tsquery('english', '!(a & !b)');
---END---
---START---

SELECT to_tsquery('english', '(1 <-> 2) <-> a');
---END---
---START---
SELECT to_tsquery('english', '(1 <-> a) <-> 2');
---END---
---START---
SELECT to_tsquery('english', '(a <-> 1) <-> 2');
---END---
---START---
SELECT to_tsquery('english', 'a <-> (1 <-> 2)');
---END---
---START---
SELECT to_tsquery('english', '1 <-> (a <-> 2)');
---END---
---START---
SELECT to_tsquery('english', '1 <-> (2 <-> a)');
---END---
---START---

SELECT to_tsquery('english', '(1 <-> 2) <3> a');
---END---
---START---
SELECT to_tsquery('english', '(1 <-> a) <3> 2');
---END---
---START---
SELECT to_tsquery('english', '(a <-> 1) <3> 2');
---END---
---START---
SELECT to_tsquery('english', 'a <3> (1 <-> 2)');
---END---
---START---
SELECT to_tsquery('english', '1 <3> (a <-> 2)');
---END---
---START---
SELECT to_tsquery('english', '1 <3> (2 <-> a)');
---END---
---START---

SELECT to_tsquery('english', '(1 <3> 2) <-> a');
---END---
---START---
SELECT to_tsquery('english', '(1 <3> a) <-> 2');
---END---
---START---
SELECT to_tsquery('english', '(a <3> 1) <-> 2');
---END---
---START---
SELECT to_tsquery('english', 'a <-> (1 <3> 2)');
---END---
---START---
SELECT to_tsquery('english', '1 <-> (a <3> 2)');
---END---
---START---
SELECT to_tsquery('english', '1 <-> (2 <3> a)');
---END---
---START---

SELECT to_tsquery('english', '((a <-> 1) <-> 2) <-> s');
---END---
---START---
SELECT to_tsquery('english', '(2 <-> (a <-> 1)) <-> s');
---END---
---START---
SELECT to_tsquery('english', '((1 <-> a) <-> 2) <-> s');
---END---
---START---
SELECT to_tsquery('english', '(2 <-> (1 <-> a)) <-> s');
---END---
---START---
SELECT to_tsquery('english', 's <-> ((a <-> 1) <-> 2)');
---END---
---START---
SELECT to_tsquery('english', 's <-> (2 <-> (a <-> 1))');
---END---
---START---
SELECT to_tsquery('english', 's <-> ((1 <-> a) <-> 2)');
---END---
---START---
SELECT to_tsquery('english', 's <-> (2 <-> (1 <-> a))');
---END---
---START---

SELECT to_tsquery('english', '((a <-> 1) <-> s) <-> 2');
---END---
---START---
SELECT to_tsquery('english', '(s <-> (a <-> 1)) <-> 2');
---END---
---START---
SELECT to_tsquery('english', '((1 <-> a) <-> s) <-> 2');
---END---
---START---
SELECT to_tsquery('english', '(s <-> (1 <-> a)) <-> 2');
---END---
---START---
SELECT to_tsquery('english', '2 <-> ((a <-> 1) <-> s)');
---END---
---START---
SELECT to_tsquery('english', '2 <-> (s <-> (a <-> 1))');
---END---
---START---
SELECT to_tsquery('english', '2 <-> ((1 <-> a) <-> s)');
---END---
---START---
SELECT to_tsquery('english', '2 <-> (s <-> (1 <-> a))');
---END---
---START---

SELECT to_tsquery('english', 'foo <-> (a <-> (the <-> bar))');
---END---
---START---
SELECT to_tsquery('english', '((foo <-> a) <-> the) <-> bar');
---END---
---START---
SELECT to_tsquery('english', 'foo <-> a <-> the <-> bar');
---END---
---START---
SELECT phraseto_tsquery('english', 'PostgreSQL can be extended by the user in many ways');
---END---
---START---


SELECT ts_rank_cd(to_tsvector('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
'), to_tsquery('english', 'paint&water'));
---END---
---START---

SELECT ts_rank_cd(to_tsvector('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
'), to_tsquery('english', 'breath&motion&water'));
---END---
---START---

SELECT ts_rank_cd(to_tsvector('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
'), to_tsquery('english', 'ocean'));
---END---
---START---

SELECT ts_rank_cd(to_tsvector('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
'), to_tsquery('english', 'painted <-> Ship'));
---END---
---START---

SELECT ts_rank_cd(strip(to_tsvector('both stripped')),
                  to_tsquery('both & stripped'));
---END---
---START---

SELECT ts_rank_cd(to_tsvector('unstripped') || strip(to_tsvector('stripped')),
                  to_tsquery('unstripped & stripped'));
---END---
---START---

--headline tests
SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'paint&water'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'breath&motion&water'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'ocean'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'day & drink'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'day | drink'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'day | !drink'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'painted <-> Ship & drink'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'painted <-> Ship | drink'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'painted <-> Ship | !drink'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', phraseto_tsquery('english', 'painted Ocean'));
---END---
---START---

SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', phraseto_tsquery('english', 'idle as a painted Ship'));
---END---
---START---

SELECT ts_headline('english',
'Lorem ipsum urna.  Nullam nullam ullamcorper urna.',
to_tsquery('english','Lorem') && phraseto_tsquery('english','ullamcorper urna'),
'MaxWords=100, MinWords=1');
---END---
---START---

SELECT ts_headline('english',
'Lorem ipsum urna.  Nullam nullam ullamcorper urna.',
phraseto_tsquery('english','ullamcorper urna'),
'MaxWords=100, MinWords=5');
---END---
---START---

SELECT ts_headline('english', '
<html>
<!-- some comment -->
<body>
Sea view wow <u>foo bar</u> <i>qq</i>
<a href="http://www.google.com/foo.bar.html" target="_blank">YES &nbsp;</a>
ff-bg
<script>
       document.write(15);
---END---
---START---
</script>
</body>
</html>',
to_tsquery('english', 'sea&foo'), 'HighlightAll=true');
---END---
---START---

SELECT ts_headline('simple', '1 2 3 1 3'::text, '1 <-> 3', 'MaxWords=2, MinWords=1');
---END---
---START---
SELECT ts_headline('simple', '1 2 3 1 3'::text, '1 & 3', 'MaxWords=4, MinWords=1');
---END---
---START---
SELECT ts_headline('simple', '1 2 3 1 3'::text, '1 <-> 3', 'MaxWords=4, MinWords=1');
---END---
---START---

--Check if headline fragments work
SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'ocean'), 'MaxFragments=1');
---END---
---START---

--Check if more than one fragments are displayed
SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'Coleridge & stuck'), 'MaxFragments=2');
---END---
---START---

--Fragments when there all query words are not in the document
SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'ocean & seahorse'), 'MaxFragments=1');
---END---
---START---

--FragmentDelimiter option
SELECT ts_headline('english', '
Day after day, day after day,
  We stuck, nor breath nor motion,
As idle as a painted Ship
  Upon a painted Ocean.
Water, water, every where
  And all the boards did shrink;
---END---
---START---
Water, water, every where,
  Nor any drop to drink.
S. T. Coleridge (1772-1834)
', to_tsquery('english', 'Coleridge & stuck'), 'MaxFragments=2,FragmentDelimiter=***');
---END---
---START---

--Fragments with phrase search
SELECT ts_headline('english',
'Lorem ipsum urna.  Nullam nullam ullamcorper urna.',
to_tsquery('english','Lorem') && phraseto_tsquery('english','ullamcorper urna'),
'MaxFragments=100, MaxWords=100, MinWords=1');
---END---
---START---

-- Edge cases with empty query
SELECT ts_headline('english',
'', to_tsquery('english', ''));
---END---
---START---
SELECT ts_headline('english',
'foo bar', to_tsquery('english', ''));
---END---
---START---

--Rewrite sub system

CREATE TABLE test_tsquery (txtkeyword TEXT, txtsample TEXT);
---END---
---START---
\set ECHO none
\copy test_tsquery from stdin
'New York'	new <-> york | big <-> apple | nyc
Moscow	moskva | moscow
'Sanct Peter'	Peterburg | peter | 'Sanct Peterburg'
foo & bar & qq	foo & (bar | qq) & city
1 & (2 <-> 3)	2 <-> 4
5 <-> 6	5 <-> 7
\.
\set ECHO all

ALTER TABLE test_tsquery ADD COLUMN keyword tsquery;
---END---
---START---
UPDATE test_tsquery SET keyword = to_tsquery('english', txtkeyword);
---END---
---START---
ALTER TABLE test_tsquery ADD COLUMN sample tsquery;
---END---
---START---
UPDATE test_tsquery SET sample = to_tsquery('english', txtsample::text);
---END---
---START---


SELECT COUNT(*) FROM test_tsquery WHERE keyword <  'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword <= 'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword = 'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword >= 'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword >  'new <-> york';
---END---
---START---

CREATE UNIQUE INDEX bt_tsq ON test_tsquery (keyword);
---END---
---START---

SET enable_seqscan=OFF;
---END---
---START---

SELECT COUNT(*) FROM test_tsquery WHERE keyword <  'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword <= 'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword = 'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword >= 'new <-> york';
---END---
---START---
SELECT COUNT(*) FROM test_tsquery WHERE keyword >  'new <-> york';
---END---
---START---

RESET enable_seqscan;
---END---
---START---

SELECT ts_rewrite('foo & bar & qq & new & york',  'new & york'::tsquery, 'big & apple | nyc | new & york & city');
---END---
---START---
SELECT ts_rewrite(ts_rewrite('new & !york ', 'york', '!jersey'),
                  'jersey', 'mexico');
---END---
---START---

SELECT ts_rewrite('moscow', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---
SELECT ts_rewrite('moscow & hotel', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---
SELECT ts_rewrite('bar & qq & foo & (new <-> york)', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---

SELECT ts_rewrite( 'moscow', 'SELECT keyword, sample FROM test_tsquery');
---END---
---START---
SELECT ts_rewrite( 'moscow & hotel', 'SELECT keyword, sample FROM test_tsquery');
---END---
---START---
SELECT ts_rewrite( 'bar & qq & foo & (new <-> york)', 'SELECT keyword, sample FROM test_tsquery');
---END---
---START---

SELECT ts_rewrite('1 & (2 <-> 3)', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---
SELECT ts_rewrite('1 & (2 <2> 3)', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---
SELECT ts_rewrite('5 <-> (1 & (2 <-> 3))', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---
SELECT ts_rewrite('5 <-> (6 | 8)', 'SELECT keyword, sample FROM test_tsquery'::text );
---END---
---START---

-- Check empty substitution
SELECT ts_rewrite(to_tsquery('5 & (6 | 5)'), to_tsquery('5'), to_tsquery(''));
---END---
---START---
SELECT ts_rewrite(to_tsquery('!5'), to_tsquery('5'), to_tsquery(''));
---END---
---START---

SELECT keyword FROM test_tsquery WHERE keyword @> 'new';
---END---
---START---
SELECT keyword FROM test_tsquery WHERE keyword @> 'moscow';
---END---
---START---
SELECT keyword FROM test_tsquery WHERE keyword <@ 'new';
---END---
---START---
SELECT keyword FROM test_tsquery WHERE keyword <@ 'moscow';
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow & hotel') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'bar & qq & foo & (new <-> york)') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow & hotel') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'bar & qq & foo & (new <-> york)') AS query;
---END---
---START---

CREATE INDEX qq ON test_tsquery USING gist (keyword tsquery_ops);
---END---
---START---
SET enable_seqscan=OFF;
---END---
---START---

SELECT keyword FROM test_tsquery WHERE keyword @> 'new';
---END---
---START---
SELECT keyword FROM test_tsquery WHERE keyword @> 'moscow';
---END---
---START---
SELECT keyword FROM test_tsquery WHERE keyword <@ 'new';
---END---
---START---
SELECT keyword FROM test_tsquery WHERE keyword <@ 'moscow';
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow & hotel') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'bar & qq & foo & (new <-> york)') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'moscow & hotel') AS query;
---END---
---START---
SELECT ts_rewrite( query, 'SELECT keyword, sample FROM test_tsquery' ) FROM to_tsquery('english', 'bar & qq & foo & (new <-> york)') AS query;
---END---
---START---

SELECT ts_rewrite(tsquery_phrase('foo', 'foo'), 'foo', 'bar | baz');
---END---
---START---
SELECT to_tsvector('foo bar') @@
  ts_rewrite(tsquery_phrase('foo', 'foo'), 'foo', 'bar | baz');
---END---
---START---
SELECT to_tsvector('bar baz') @@
  ts_rewrite(tsquery_phrase('foo', 'foo'), 'foo', 'bar | baz');
---END---
---START---

RESET enable_seqscan;
---END---
---START---

--test GUC
SET default_text_search_config=simple;
---END---
---START---

SELECT to_tsvector('SKIES My booKs');
---END---
---START---
SELECT plainto_tsquery('SKIES My booKs');
---END---
---START---
SELECT to_tsquery('SKIES & My | booKs');
---END---
---START---

SET default_text_search_config=english;
---END---
---START---

SELECT to_tsvector('SKIES My booKs');
---END---
---START---
SELECT plainto_tsquery('SKIES My booKs');
---END---
---START---
SELECT to_tsquery('SKIES & My | booKs');
---END---
---START---

--trigger
CREATE TRIGGER tsvectorupdate
BEFORE UPDATE OR INSERT ON test_tsvector
FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger(a, 'pg_catalog.english', t);
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ to_tsquery('345&qwerty');
---END---
---START---
INSERT INTO test_tsvector (t) VALUES ('345 qwerty');
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ to_tsquery('345&qwerty');
---END---
---START---
UPDATE test_tsvector SET t = null WHERE t = '345 qwerty';
---END---
---START---
SELECT count(*) FROM test_tsvector WHERE a @@ to_tsquery('345&qwerty');
---END---
---START---

INSERT INTO test_tsvector (t) VALUES ('345 qwerty');
---END---
---START---

SELECT count(*) FROM test_tsvector WHERE a @@ to_tsquery('345&qwerty');
---END---
---START---

-- Test inlining of immutable constant functions

-- to_tsquery(text) is not immutable, so it won't be inlined
explain (costs off)
select * from test_tsquery, to_tsquery('new') q where txtsample @@ q;
---END---
---START---

-- to_tsquery(regconfig, text) is an immutable function.
-- That allows us to get rid of using function scan and join at all.
explain (costs off)
select * from test_tsquery, to_tsquery('english', 'new') q where txtsample @@ q;
---END---
---START---

-- test finding items in GIN's pending list
create table pendtest (ts tsvector);
---END---
---START---
create index pendtest_idx on pendtest using gin(ts);
---END---
---START---
insert into pendtest values (to_tsvector('Lore ipsam'));
---END---
---START---
insert into pendtest values (to_tsvector('Lore ipsum'));
---END---
---START---
select * from pendtest where 'ipsu:*'::tsquery @@ ts;
---END---
---START---
select * from pendtest where 'ipsa:*'::tsquery @@ ts;
---END---
---START---
select * from pendtest where 'ips:*'::tsquery @@ ts;
---END---
---START---
select * from pendtest where 'ipt:*'::tsquery @@ ts;
---END---
---START---
select * from pendtest where 'ipi:*'::tsquery @@ ts;
---END---
---START---
drop table pendtest;
---END---
---START---

--check OP_PHRASE on index
create table phrase_index_test(fts tsvector);
---END---
---START---
insert into phrase_index_test values ('A fat cat has just eaten a rat.');
---END---
---START---
insert into phrase_index_test values (to_tsvector('english', 'A fat cat has just eaten a rat.'));
---END---
---START---
create index phrase_index_test_idx on phrase_index_test using gin(fts);
---END---
---START---
set enable_seqscan = off;
---END---
---START---
select * from phrase_index_test where fts @@ phraseto_tsquery('english', 'fat cat');
---END---
---START---
drop table phrase_index_test;
---END---
---START---
set enable_seqscan = on;
---END---
---START---

-- test websearch_to_tsquery function
select websearch_to_tsquery('simple', 'I have a fat:*ABCD cat');
---END---
---START---
select websearch_to_tsquery('simple', 'orange:**AABBCCDD');
---END---
---START---
select websearch_to_tsquery('simple', 'fat:A!cat:B|rat:C<');
---END---
---START---
select websearch_to_tsquery('simple', 'fat:A : cat:B');
---END---
---START---

select websearch_to_tsquery('simple', 'fat*rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat-rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat_rat');
---END---
---START---

-- weights are completely ignored
select websearch_to_tsquery('simple', 'abc : def');
---END---
---START---
select websearch_to_tsquery('simple', 'abc:def');
---END---
---START---
select websearch_to_tsquery('simple', 'a:::b');
---END---
---START---
select websearch_to_tsquery('simple', 'abc:d');
---END---
---START---
select websearch_to_tsquery('simple', ':');
---END---
---START---

-- these operators are ignored
select websearch_to_tsquery('simple', 'abc & def');
---END---
---START---
select websearch_to_tsquery('simple', 'abc | def');
---END---
---START---
select websearch_to_tsquery('simple', 'abc <-> def');
---END---
---START---
select websearch_to_tsquery('simple', 'abc (pg or class)');
---END---
---START---

-- NOT is ignored in quotes
select websearch_to_tsquery('english', 'My brand new smartphone');
---END---
---START---
select websearch_to_tsquery('english', 'My brand "new smartphone"');
---END---
---START---
select websearch_to_tsquery('english', 'My brand "new -smartphone"');
---END---
---START---

-- test OR operator
select websearch_to_tsquery('simple', 'cat or rat');
---END---
---START---
select websearch_to_tsquery('simple', 'cat OR rat');
---END---
---START---
select websearch_to_tsquery('simple', 'cat "OR" rat');
---END---
---START---
select websearch_to_tsquery('simple', 'cat OR');
---END---
---START---
select websearch_to_tsquery('simple', 'OR rat');
---END---
---START---
select websearch_to_tsquery('simple', '"fat cat OR rat"');
---END---
---START---
select websearch_to_tsquery('simple', 'fat (cat OR rat');
---END---
---START---
select websearch_to_tsquery('simple', 'or OR or');
---END---
---START---

-- OR is an operator here ...
select websearch_to_tsquery('simple', '"fat cat"or"fat rat"');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or(rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or)rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or&rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or|rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or!rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or<rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or>rat');
---END---
---START---
select websearch_to_tsquery('simple', 'fat or ');
---END---
---START---

-- ... but not here
select websearch_to_tsquery('simple', 'abc orange');
---END---
---START---
select websearch_to_tsquery('simple', 'abc OR1234');
---END---
---START---
select websearch_to_tsquery('simple', 'abc or-abc');
---END---
---START---
select websearch_to_tsquery('simple', 'abc OR_abc');
---END---
---START---

-- test quotes
select websearch_to_tsquery('english', '"pg_class pg');
---END---
---START---
select websearch_to_tsquery('english', 'pg_class pg"');
---END---
---START---
select websearch_to_tsquery('english', '"pg_class pg"');
---END---
---START---
select websearch_to_tsquery('english', '"pg_class : pg"');
---END---
---START---
select websearch_to_tsquery('english', 'abc "pg_class pg"');
---END---
---START---
select websearch_to_tsquery('english', '"pg_class pg" def');
---END---
---START---
select websearch_to_tsquery('english', 'abc "pg pg_class pg" def');
---END---
---START---
select websearch_to_tsquery('english', ' or "pg pg_class pg" or ');
---END---
---START---
select websearch_to_tsquery('english', '""pg pg_class pg""');
---END---
---START---
select websearch_to_tsquery('english', 'abc """"" def');
---END---
---START---
select websearch_to_tsquery('english', 'cat -"fat rat"');
---END---
---START---
select websearch_to_tsquery('english', 'cat -"fat rat" cheese');
---END---
---START---
select websearch_to_tsquery('english', 'abc "def -"');
---END---
---START---
select websearch_to_tsquery('english', 'abc "def :"');
---END---
---START---

select websearch_to_tsquery('english', '"A fat cat" has just eaten a -rat.');
---END---
---START---
select websearch_to_tsquery('english', '"A fat cat" has just eaten OR !rat.');
---END---
---START---
select websearch_to_tsquery('english', '"A fat cat" has just (+eaten OR -rat)');
---END---
---START---

select websearch_to_tsquery('english', 'this is ----fine');
---END---
---START---
select websearch_to_tsquery('english', '(()) )))) this ||| is && -fine, "dear friend" OR good');
---END---
---START---
select websearch_to_tsquery('english', 'an old <-> cat " is fine &&& too');
---END---
---START---

select websearch_to_tsquery('english', '"A the" OR just on');
---END---
---START---
select websearch_to_tsquery('english', '"a fat cat" ate a rat');
---END---
---START---

select to_tsvector('english', 'A fat cat ate a rat') @@
	websearch_to_tsquery('english', '"a fat cat" ate a rat');
---END---
---START---

select to_tsvector('english', 'A fat grey cat ate a rat') @@
	websearch_to_tsquery('english', '"a fat cat" ate a rat');
---END---
---START---

-- cases handled by gettoken_tsvector()
select websearch_to_tsquery('''');
---END---
---START---
select websearch_to_tsquery('''abc''''def''');
---END---
---START---
select websearch_to_tsquery('\abc');
---END---
---START---
select websearch_to_tsquery('\');
---END---
