---START---
-- deal with numeric instability of ts_rank
SET extra_float_digits = 0;
---END---
---START---
--Base tsvector test

SELECT '1'::tsvector;
---END---
---START---
SELECT '1 '::tsvector;
---END---
---START---
SELECT ' 1'::tsvector;
---END---
---START---
SELECT ' 1 '::tsvector;
---END---
---START---
SELECT '1 2'::tsvector;
---END---
---START---
SELECT '''1 2'''::tsvector;
---END---
---START---
SELECT E'''1 \\''2'''::tsvector;
---END---
---START---
SELECT E'''1 \\''2''3'::tsvector;
---END---
---START---
SELECT E'''1 \\''2'' 3'::tsvector;
---END---
---START---
SELECT E'''1 \\''2'' '' 3'' 4 '::tsvector;
---END---
---START---
SELECT $$'\\as' ab\c ab\\c AB\\\c ab\\\\c$$::tsvector;
---END---
---START---
SELECT tsvectorin(tsvectorout($$'\\as' ab\c ab\\c AB\\\c ab\\\\c$$::tsvector));
---END---
---START---
SELECT '''w'':4A,3B,2C,1D,5 a:8';
---END---
---START---
SELECT 'a:3A b:2a'::tsvector || 'ba:1234 a:1B';
---END---
---START---
SELECT $$'' '1' '2'$$::tsvector;
---END---
---START---
-- error, empty lexeme is not allowed

-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('foo', 'tsvector');
---END---
---START---
SELECT pg_input_is_valid($$''$$, 'tsvector');
---END---
---START---
SELECT * FROM pg_input_error_info($$''$$, 'tsvector');
---END---
---START---
--Base tsquery test
SELECT '1'::tsquery;
---END---
---START---
SELECT '1 '::tsquery;
---END---
---START---
SELECT ' 1'::tsquery;
---END---
---START---
SELECT ' 1 '::tsquery;
---END---
---START---
SELECT '''1 2'''::tsquery;
---END---
---START---
SELECT E'''1 \\''2'''::tsquery;
---END---
---START---
SELECT '!1'::tsquery;
---END---
---START---
SELECT '1|2'::tsquery;
---END---
---START---
SELECT '1|!2'::tsquery;
---END---
---START---
SELECT '!1|2'::tsquery;
---END---
---START---
SELECT '!1|!2'::tsquery;
---END---
---START---
SELECT '!(!1|!2)'::tsquery;
---END---
---START---
SELECT '!(!1|2)'::tsquery;
---END---
---START---
SELECT '!(1|!2)'::tsquery;
---END---
---START---
SELECT '!(1|2)'::tsquery;
---END---
---START---
SELECT '1&2'::tsquery;
---END---
---START---
SELECT '!1&2'::tsquery;
---END---
---START---
SELECT '1&!2'::tsquery;
---END---
---START---
SELECT '!1&!2'::tsquery;
---END---
---START---
SELECT '(1&2)'::tsquery;
---END---
---START---
SELECT '1&(2)'::tsquery;
---END---
---START---
SELECT '!(1)&2'::tsquery;
---END---
---START---
SELECT '!(1&2)'::tsquery;
---END---
---START---
SELECT '1|2&3'::tsquery;
---END---
---START---
SELECT '1|(2&3)'::tsquery;
---END---
---START---
SELECT '(1|2)&3'::tsquery;
---END---
---START---
SELECT '1|2&!3'::tsquery;
---END---
---START---
SELECT '1|!2&3'::tsquery;
---END---
---START---
SELECT '!1|2&3'::tsquery;
---END---
---START---
SELECT '!1|(2&3)'::tsquery;
---END---
---START---
SELECT '!(1|2)&3'::tsquery;
---END---
---START---
SELECT '(!1|2)&3'::tsquery;
---END---
---START---
SELECT '1|(2|(4|(5|6)))'::tsquery;
---END---
---START---
SELECT '1|2|4|5|6'::tsquery;
---END---
---START---
SELECT '1&(2&(4&(5&6)))'::tsquery;
---END---
---START---
SELECT '1&2&4&5&6'::tsquery;
---END---
---START---
SELECT '1&(2&(4&(5|6)))'::tsquery;
---END---
---START---
SELECT '1&(2&(4&(5|!6)))'::tsquery;
---END---
---START---
SELECT E'1&(''2''&('' 4''&(\\|5 | ''6 \\'' !|&'')))'::tsquery;
---END---
---START---
SELECT $$'\\as'$$::tsquery;
---END---
---START---
SELECT 'a:* & nbb:*ac | doo:a* | goo'::tsquery;
---END---
---START---
SELECT '!!b'::tsquery;
---END---
---START---
SELECT '!!!b'::tsquery;
---END---
---START---
SELECT '!(!b)'::tsquery;
---END---
---START---
SELECT 'a & !!b'::tsquery;
---END---
---START---
SELECT '!!a & b'::tsquery;
---END---
---START---
SELECT '!!a & !!b'::tsquery;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('foo', 'tsquery');
---END---
---START---
SELECT pg_input_is_valid('foo!', 'tsquery');
---END---
---START---
SELECT * FROM pg_input_error_info('foo!', 'tsquery');
---END---
---START---
SELECT * FROM pg_input_error_info('a <100000> b', 'tsquery');
---END---
---START---
--comparisons
SELECT 'a' < 'b & c'::tsquery as "true";
---END---
---START---
SELECT 'a' > 'b & c'::tsquery as "false";
---END---
---START---
SELECT 'a | f' < 'b & c'::tsquery as "false";
---END---
---START---
SELECT 'a | ff' < 'b & c'::tsquery as "false";
---END---
---START---
SELECT 'a | f | g' < 'b & c'::tsquery as "false";
---END---
---START---
--concatenation
SELECT numnode( 'new'::tsquery );
---END---
---START---
SELECT numnode( 'new & york'::tsquery );
---END---
---START---
SELECT numnode( 'new & york | qwery'::tsquery );
---END---
---START---
SELECT 'foo & bar'::tsquery && 'asd';
---END---
---START---
SELECT 'foo & bar'::tsquery || 'asd & fg';
---END---
---START---
SELECT 'foo & bar'::tsquery || !!'asd & fg'::tsquery;
---END---
---START---
SELECT 'foo & bar'::tsquery && 'asd | fg';
---END---
---START---
SELECT 'a' <-> 'b & d'::tsquery;
---END---
---START---
SELECT 'a & g' <-> 'b & d'::tsquery;
---END---
---START---
SELECT 'a & g' <-> 'b | d'::tsquery;
---END---
---START---
SELECT 'a & g' <-> 'b <-> d'::tsquery;
---END---
---START---
SELECT tsquery_phrase('a <3> g', 'b & d', 10);
---END---
---START---
-- tsvector-tsquery operations

SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & ca' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & ca:B' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & ca:A' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & ca:C' as "false";
---END---
---START---
SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & ca:CB' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & c:*C' as "false";
---END---
---START---
SELECT 'a b:89  ca:23A,64b d:34c'::tsvector @@ 'd:AC & c:*CB' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64b cb:80c d:34c'::tsvector @@ 'd:AC & c:*C' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64c cb:80b d:34c'::tsvector @@ 'd:AC & c:*C' as "true";
---END---
---START---
SELECT 'a b:89  ca:23A,64c cb:80b d:34c'::tsvector @@ 'd:AC & c:*B' as "true";
---END---
---START---
SELECT 'wa:1D wb:2A'::tsvector @@ 'w:*D & w:*A'::tsquery as "true";
---END---
---START---
SELECT 'wa:1D wb:2A'::tsvector @@ 'w:*D <-> w:*A'::tsquery as "true";
---END---
---START---
SELECT 'wa:1A wb:2D'::tsvector @@ 'w:*D <-> w:*A'::tsquery as "false";
---END---
---START---
SELECT 'wa:1A'::tsvector @@ 'w:*A'::tsquery as "true";
---END---
---START---
SELECT 'wa:1A'::tsvector @@ 'w:*D'::tsquery as "false";
---END---
---START---
SELECT 'wa:1A'::tsvector @@ '!w:*A'::tsquery as "false";
---END---
---START---
SELECT 'wa:1A'::tsvector @@ '!w:*D'::tsquery as "true";
---END---
---START---
-- historically, a stripped tsvector matches queries ignoring weights:
SELECT strip('wa:1A'::tsvector) @@ 'w:*A'::tsquery as "true";
---END---
---START---
SELECT strip('wa:1A'::tsvector) @@ 'w:*D'::tsquery as "true";
---END---
---START---
SELECT strip('wa:1A'::tsvector) @@ '!w:*A'::tsquery as "false";
---END---
---START---
SELECT strip('wa:1A'::tsvector) @@ '!w:*D'::tsquery as "false";
---END---
---START---
SELECT 'supernova'::tsvector @@ 'super'::tsquery AS "false";
---END---
---START---
SELECT 'supeanova supernova'::tsvector @@ 'super'::tsquery AS "false";
---END---
---START---
SELECT 'supeznova supernova'::tsvector @@ 'super'::tsquery AS "false";
---END---
---START---
SELECT 'supernova'::tsvector @@ 'super:*'::tsquery AS "true";
---END---
---START---
SELECT 'supeanova supernova'::tsvector @@ 'super:*'::tsquery AS "true";
---END---
---START---
SELECT 'supeznova supernova'::tsvector @@ 'super:*'::tsquery AS "true";
---END---
---START---
--phrase search
SELECT to_tsvector('simple', '1 2 3 1') @@ '1 <-> 2' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 1') @@ '1 <2> 2' AS "false";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 1') @@ '1 <-> 3' AS "false";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 1') @@ '1 <2> 3' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 1 2') @@ '1 <3> 2' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 11 3') @@ '1 <-> 3' AS "false";
---END---
---START---
SELECT to_tsvector('simple', '1 2 11 3') @@ '1:* <-> 3' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 4') @@ '1 <-> 2 <-> 3' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 4') @@ '(1 <-> 2) <-> 3' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 4') @@ '1 <-> (2 <-> 3)' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 3 4') @@ '1 <2> (2 <-> 3)' AS "false";
---END---
---START---
SELECT to_tsvector('simple', '1 2 1 2 3 4') @@ '(1 <-> 2) <-> 3' AS "true";
---END---
---START---
SELECT to_tsvector('simple', '1 2 1 2 3 4') @@ '1 <-> 2 <-> 3' AS "true";
---END---
---START---
-- without position data, phrase search does not match
SELECT strip(to_tsvector('simple', '1 2 3 4')) @@ '1 <-> 2 <-> 3' AS "false";
---END---
---START---
select to_tsvector('simple', 'q x q y') @@ 'q <-> (x & y)' AS "false";
---END---
---START---
select to_tsvector('simple', 'q x') @@ 'q <-> (x | y <-> z)' AS "true";
---END---
---START---
select to_tsvector('simple', 'q y') @@ 'q <-> (x | y <-> z)' AS "false";
---END---
---START---
select to_tsvector('simple', 'q y z') @@ 'q <-> (x | y <-> z)' AS "true";
---END---
---START---
select to_tsvector('simple', 'q y x') @@ 'q <-> (x | y <-> z)' AS "false";
---END---
---START---
select to_tsvector('simple', 'q x y') @@ 'q <-> (x | y <-> z)' AS "true";
---END---
---START---
select to_tsvector('simple', 'q x') @@ '(x | y <-> z) <-> q' AS "false";
---END---
---START---
select to_tsvector('simple', 'x q') @@ '(x | y <-> z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q') @@ '(x | y <-> z) <-> q' AS "false";
---END---
---START---
select to_tsvector('simple', 'x y z') @@ '(x | y <-> z) <-> q' AS "false";
---END---
---START---
select to_tsvector('simple', 'x y z q') @@ '(x | y <-> z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'y z q') @@ '(x | y <-> z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'y y q') @@ '(x | y <-> z) <-> q' AS "false";
---END---
---START---
select to_tsvector('simple', 'y y q') @@ '(!x | y <-> z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q') @@ '(!x | y <-> z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'y y q') @@ '(x | y <-> !z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x q') @@ '(x | y <-> !z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x q') @@ '(!x | y <-> z) <-> q' AS "false";
---END---
---START---
select to_tsvector('simple', 'z q') @@ '(!x | y <-> z) <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q') @@ '(!x | y) <-> y <-> q' AS "false";
---END---
---START---
select to_tsvector('simple', 'x y q') @@ '(!x | !y) <-> y <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q') @@ '(x | !y) <-> y <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q') @@ '(x | !!z) <-> y <-> q' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q y') @@ '!x <-> y' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q y') @@ '!x <-> !y' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q y') @@ '!x <-> !!y' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q y') @@ '!(x <-> y)' AS "false";
---END---
---START---
select to_tsvector('simple', 'x y q y') @@ '!(x <2> y)' AS "true";
---END---
---START---
select strip(to_tsvector('simple', 'x y q y')) @@ '!x <-> y' AS "false";
---END---
---START---
select strip(to_tsvector('simple', 'x y q y')) @@ '!x <-> !y' AS "false";
---END---
---START---
select strip(to_tsvector('simple', 'x y q y')) @@ '!x <-> !!y' AS "false";
---END---
---START---
select strip(to_tsvector('simple', 'x y q y')) @@ '!(x <-> y)' AS "true";
---END---
---START---
select strip(to_tsvector('simple', 'x y q y')) @@ '!(x <2> y)' AS "true";
---END---
---START---
select to_tsvector('simple', 'x y q y') @@ '!foo' AS "true";
---END---
---START---
select to_tsvector('simple', '') @@ '!foo' AS "true";
---END---
---START---
--ranking
SELECT ts_rank(' a:1 s:2C d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank(' a:1 sa:2C d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank(' a:1 sa:2C d g'::tsvector, 'a | s:*');
---END---
---START---
SELECT ts_rank(' a:1 sa:2C d g'::tsvector, 'a | sa:*');
---END---
---START---
SELECT ts_rank(' a:1 s:2B d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank(' a:1 s:2 d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank(' a:1 s:2C d g'::tsvector, 'a & s');
---END---
---START---
SELECT ts_rank(' a:1 s:2B d g'::tsvector, 'a & s');
---END---
---START---
SELECT ts_rank(' a:1 s:2 d g'::tsvector, 'a & s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2C d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2C d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2C d g'::tsvector, 'a | s:*');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2C d g'::tsvector, 'a | sa:*');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:3C sab:2c d g'::tsvector, 'a | sa:*');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2B d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2 d g'::tsvector, 'a | s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2C d g'::tsvector, 'a & s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2B d g'::tsvector, 'a & s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2 d g'::tsvector, 'a & s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2A d g'::tsvector, 'a <-> s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2C d g'::tsvector, 'a <-> s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2 d g'::tsvector, 'a <-> s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2 d:2A g'::tsvector, 'a <-> s');
---END---
---START---
SELECT ts_rank_cd(' a:1 s:2,3A d:2A g'::tsvector, 'a <2> s:A');
---END---
---START---
SELECT ts_rank_cd(' a:1 b:2 s:3A d:2A g'::tsvector, 'a <2> s:A');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2D sb:2A g'::tsvector, 'a <-> s:*');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2A sb:2D g'::tsvector, 'a <-> s:*');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2A sb:2D g'::tsvector, 'a <-> s:* <-> sa:A');
---END---
---START---
SELECT ts_rank_cd(' a:1 sa:2A sb:2D g'::tsvector, 'a <-> s:* <-> sa:B');
---END---
---START---
SELECT 'a:1 b:2'::tsvector @@ 'a <-> b'::tsquery AS "true";
---END---
---START---
SELECT 'a:1 b:2'::tsvector @@ 'a <0> b'::tsquery AS "false";
---END---
---START---
SELECT 'a:1 b:2'::tsvector @@ 'a <1> b'::tsquery AS "true";
---END---
---START---
SELECT 'a:1 b:2'::tsvector @@ 'a <2> b'::tsquery AS "false";
---END---
---START---
SELECT 'a:1 b:3'::tsvector @@ 'a <-> b'::tsquery AS "false";
---END---
---START---
SELECT 'a:1 b:3'::tsvector @@ 'a <0> b'::tsquery AS "false";
---END---
---START---
SELECT 'a:1 b:3'::tsvector @@ 'a <1> b'::tsquery AS "false";
---END---
---START---
SELECT 'a:1 b:3'::tsvector @@ 'a <2> b'::tsquery AS "true";
---END---
---START---
SELECT 'a:1 b:3'::tsvector @@ 'a <3> b'::tsquery AS "false";
---END---
---START---
SELECT 'a:1 b:3'::tsvector @@ 'a <0> a:*'::tsquery AS "true";
---END---
---START---
-- tsvector editing operations

SELECT strip('w:12B w:13* w:12,5,6 a:1,3* a:3 w asd:1dc asd'::tsvector);
---END---
---START---
SELECT strip('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector);
---END---
---START---
SELECT strip('base hidden rebel spaceship strike'::tsvector);
---END---
---START---
SELECT ts_delete(to_tsvector('english', 'Rebel spaceships, striking from a hidden base'), 'spaceship');
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, 'base');
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, 'bas');
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, 'bases');
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, 'spaceship');
---END---
---START---
SELECT ts_delete('base hidden rebel spaceship strike'::tsvector, 'spaceship');
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, ARRAY['spaceship','rebel']);
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, ARRAY['spaceships','rebel']);
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, ARRAY['spaceshi','rebel']);
---END---
---START---
SELECT ts_delete('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector, ARRAY['spaceship','leya','rebel']);
---END---
---START---
SELECT ts_delete('base hidden rebel spaceship strike'::tsvector, ARRAY['spaceship','leya','rebel']);
---END---
---START---
SELECT ts_delete('base hidden rebel spaceship strike'::tsvector, ARRAY['spaceship','leya','rebel','rebel']);
---END---
---START---
SELECT ts_delete('base hidden rebel spaceship strike'::tsvector, ARRAY['spaceship','leya','rebel', '', NULL]);
---END---
---START---
SELECT unnest('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector);
---END---
---START---
SELECT unnest('base hidden rebel spaceship strike'::tsvector);
---END---
---START---
SELECT * FROM unnest('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector);
---END---
---START---
SELECT * FROM unnest('base hidden rebel spaceship strike'::tsvector);
---END---
---START---
SELECT lexeme, positions[1] from unnest('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector);
---END---
---START---
SELECT tsvector_to_array('base:7 hidden:6 rebel:1 spaceship:2,33A,34B,35C,36D strike:3'::tsvector);
---END---
---START---
SELECT tsvector_to_array('base hidden rebel spaceship strike'::tsvector);
---END---
---START---
SELECT array_to_tsvector(ARRAY['base','hidden','rebel','spaceship','strike']);
---END---
---START---
-- null and empty string are disallowed, since we mustn't make an empty lexeme
SELECT array_to_tsvector(ARRAY['base','hidden','rebel','spaceship', NULL]);
---END---
---START---
SELECT array_to_tsvector(ARRAY['base','hidden','rebel','spaceship', '']);
---END---
---START---
-- array_to_tsvector must sort and de-dup
SELECT array_to_tsvector(ARRAY['foo','bar','baz','bar']);
---END---
---START---
SELECT setweight('w:12B w:13* w:12,5,6 a:1,3* a:3 w asd:1dc asd zxc:81,567,222A'::tsvector, 'c');
---END---
---START---
SELECT setweight('a:1,3A asd:1C w:5,6,12B,13A zxc:81,222A,567'::tsvector, 'c');
---END---
---START---
SELECT setweight('a:1,3A asd:1C w:5,6,12B,13A zxc:81,222A,567'::tsvector, 'c', '{a}');
---END---
---START---
SELECT setweight('a:1,3A asd:1C w:5,6,12B,13A zxc:81,222A,567'::tsvector, 'c', '{a}');
---END---
---START---
SELECT setweight('a:1,3A asd:1C w:5,6,12B,13A zxc:81,222A,567'::tsvector, 'c', '{a,zxc}');
---END---
---START---
SELECT setweight('a asd w:5,6,12B,13A zxc'::tsvector, 'c', ARRAY['a', 'zxc', '', NULL]);
---END---
---START---
SELECT ts_filter('base:7A empir:17 evil:15 first:11 galact:16 hidden:6A rebel:1A spaceship:2A strike:3A victori:12 won:9'::tsvector, '{a}');
---END---
---START---
SELECT ts_filter('base hidden rebel spaceship strike'::tsvector, '{a}');
---END---
---START---
SELECT ts_filter('base hidden rebel spaceship strike'::tsvector, '{a,b,NULL}');
---END---
