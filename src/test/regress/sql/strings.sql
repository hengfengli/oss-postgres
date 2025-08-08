---START---
--
-- STRINGS
-- Test various data entry syntaxes.
--

-- SQL string continuation syntax
-- E021-03 character string literals
SELECT 'first line'
' - next line'
	' - third line'
	AS "Three lines to one";
---END---
---START---
-- illegal string continuation syntax
SELECT 'first line'
' - next line' /* this comment is not allowed here */
' - third line'
	AS "Illegal comment within continuation";
---END---
---START---
-- Unicode escapes
SET standard_conforming_strings TO on;
---END---
---START---
SELECT U&'d\0061t\+000061' AS U&"d\0061t\+000061";
---END---
---START---
SELECT U&'d!0061t\+000061' UESCAPE '!' AS U&"d*0061t\+000061" UESCAPE '*';
---END---
---START---
SELECT U&'a\\b' AS "a\b";
---END---
---START---
SELECT U&' \' UESCAPE '!' AS "tricky";
---END---
---START---
SELECT 'tricky' AS U&"\" UESCAPE '!';
---END---
---START---
SELECT U&'wrong: \061';
---END---
---START---
SELECT U&'wrong: \+0061';
---END---
---START---
SELECT U&'wrong: +0061' UESCAPE +;
---END---
---START---
SELECT U&'wrong: +0061' UESCAPE '+';
---END---
---START---
SELECT U&'wrong: \db99';
---END---
---START---
SELECT U&'wrong: \db99xy';
---END---
---START---
SELECT U&'wrong: \db99\\';
---END---
---START---
SELECT U&'wrong: \db99\0061';
---END---
---START---
SELECT U&'wrong: \+00db99\+000061';
---END---
---START---
SELECT U&'wrong: \+2FFFFF';
---END---
---START---
-- while we're here, check the same cases in E-style literals
SELECT E'd\u0061t\U00000061' AS "data";
---END---
---START---
SELECT E'a\\b' AS "a\b";
---END---
---START---
SELECT E'wrong: \u061';
---END---
---START---
SELECT E'wrong: \U0061';
---END---
---START---
SELECT E'wrong: \udb99';
---END---
---START---
SELECT E'wrong: \udb99xy';
---END---
---START---
SELECT E'wrong: \udb99\\';
---END---
---START---
SELECT E'wrong: \udb99\u0061';
---END---
---START---
SELECT E'wrong: \U0000db99\U00000061';
---END---
---START---
SELECT E'wrong: \U002FFFFF';
---END---
---START---
SET standard_conforming_strings TO off;
---END---
---START---
SELECT U&'d\0061t\+000061' AS U&"d\0061t\+000061";
---END---
---START---
SELECT U&'d!0061t\+000061' UESCAPE '!' AS U&"d*0061t\+000061" UESCAPE '*';
---END---
---START---
SELECT U&' \' UESCAPE '!' AS "tricky";
---END---
---START---
SELECT 'tricky' AS U&"\" UESCAPE '!';
---END---
---START---
SELECT U&'wrong: \061';
---END---
---START---
SELECT U&'wrong: \+0061';
---END---
---START---
SELECT U&'wrong: +0061' UESCAPE '+';
---END---
---START---
RESET standard_conforming_strings;
---END---
---START---
-- bytea
SET bytea_output TO hex;
---END---
---START---
SELECT E'\\xDeAdBeEf'::bytea;
---END---
---START---
SELECT E'\\x De Ad Be Ef '::bytea;
---END---
---START---
SELECT E'\\xDeAdBeE'::bytea;
---END---
---START---
SELECT E'\\xDeAdBeEx'::bytea;
---END---
---START---
SELECT E'\\xDe00BeEf'::bytea;
---END---
---START---
SELECT E'DeAdBeEf'::bytea;
---END---
---START---
SELECT E'De\\000dBeEf'::bytea;
---END---
---START---
SELECT E'De\123dBeEf'::bytea;
---END---
---START---
SELECT E'De\\123dBeEf'::bytea;
---END---
---START---
SELECT E'De\\678dBeEf'::bytea;
---END---
---START---
SET bytea_output TO escape;
---END---
---START---
SELECT E'\\xDeAdBeEf'::bytea;
---END---
---START---
SELECT E'\\x De Ad Be Ef '::bytea;
---END---
---START---
SELECT E'\\xDe00BeEf'::bytea;
---END---
---START---
SELECT E'DeAdBeEf'::bytea;
---END---
---START---
SELECT E'De\\000dBeEf'::bytea;
---END---
---START---
SELECT E'De\\123dBeEf'::bytea;
---END---
---START---
-- Test non-error-throwing API too
SELECT pg_input_is_valid(E'\\xDeAdBeE', 'bytea');
---END---
---START---
SELECT * FROM pg_input_error_info(E'\\xDeAdBeE', 'bytea');
---END---
---START---
SELECT * FROM pg_input_error_info(E'\\xDeAdBeEx', 'bytea');
---END---
---START---
SELECT * FROM pg_input_error_info(E'foo\\99bar', 'bytea');
---END---
---START---
--
-- test conversions between various string types
-- E021-10 implicit casting among the character data types
--

SELECT CAST(f1 AS text) AS "text(char)" FROM CHAR_TBL;
---END---
---START---
SELECT CAST(f1 AS text) AS "text(varchar)" FROM VARCHAR_TBL;
---END---
---START---
SELECT CAST(name 'namefield' AS text) AS "text(name)";
---END---
---START---
-- since this is an explicit cast, it should truncate w/o error:
SELECT CAST(f1 AS char(10)) AS "char(text)" FROM TEXT_TBL;
---END---
---START---
-- note: implicit-cast case is tested in char.sql

SELECT CAST(f1 AS char(20)) AS "char(text)" FROM TEXT_TBL;
---END---
---START---
SELECT CAST(f1 AS char(10)) AS "char(varchar)" FROM VARCHAR_TBL;
---END---
---START---
SELECT CAST(name 'namefield' AS char(10)) AS "char(name)";
---END---
---START---
SELECT CAST(f1 AS varchar) AS "varchar(text)" FROM TEXT_TBL;
---END---
---START---
SELECT CAST(f1 AS varchar) AS "varchar(char)" FROM CHAR_TBL;
---END---
---START---
SELECT CAST(name 'namefield' AS varchar) AS "varchar(name)";
---END---
---START---
--
-- test SQL string functions
-- E### and T### are feature reference numbers from SQL99
--

-- E021-09 trim function
SELECT TRIM(BOTH FROM '  bunch o blanks  ') = 'bunch o blanks' AS "bunch o blanks";
---END---
---START---
SELECT TRIM(LEADING FROM '  bunch o blanks  ') = 'bunch o blanks  ' AS "bunch o blanks  ";
---END---
---START---
SELECT TRIM(TRAILING FROM '  bunch o blanks  ') = '  bunch o blanks' AS "  bunch o blanks";
---END---
---START---
SELECT TRIM(BOTH 'x' FROM 'xxxxxsome Xsxxxxx') = 'some Xs' AS "some Xs";
---END---
---START---
-- E021-06 substring expression
SELECT SUBSTRING('1234567890' FROM 3) = '34567890' AS "34567890";
---END---
---START---
SELECT SUBSTRING('1234567890' FROM 4 FOR 3) = '456' AS "456";
---END---
---START---
-- test overflow cases
SELECT SUBSTRING('string' FROM 2 FOR 2147483646) AS "tring";
---END---
---START---
SELECT SUBSTRING('string' FROM -10 FOR 2147483646) AS "string";
---END---
---START---
SELECT SUBSTRING('string' FROM -10 FOR -2147483646) AS "error";
---END---
---START---
-- T581 regular expression substring (with SQL's bizarre regexp syntax)
SELECT SUBSTRING('abcdefg' SIMILAR 'a#"(b_d)#"%' ESCAPE '#') AS "bcd";
---END---
---START---
-- obsolete SQL99 syntax
SELECT SUBSTRING('abcdefg' FROM 'a#"(b_d)#"%' FOR '#') AS "bcd";
---END---
---START---
-- No match should return NULL
SELECT SUBSTRING('abcdefg' SIMILAR '#"(b_d)#"%' ESCAPE '#') IS NULL AS "True";
---END---
---START---
-- Null inputs should return NULL
SELECT SUBSTRING('abcdefg' SIMILAR '%' ESCAPE NULL) IS NULL AS "True";
---END---
---START---
SELECT SUBSTRING(NULL SIMILAR '%' ESCAPE '#') IS NULL AS "True";
---END---
---START---
SELECT SUBSTRING('abcdefg' SIMILAR NULL ESCAPE '#') IS NULL AS "True";
---END---
---START---
-- The first and last parts should act non-greedy
SELECT SUBSTRING('abcdefg' SIMILAR 'a#"%#"g' ESCAPE '#') AS "bcdef";
---END---
---START---
SELECT SUBSTRING('abcdefg' SIMILAR 'a*#"%#"g*' ESCAPE '#') AS "abcdefg";
---END---
---START---
-- Vertical bar in any part affects only that part
SELECT SUBSTRING('abcdefg' SIMILAR 'a|b#"%#"g' ESCAPE '#') AS "bcdef";
---END---
---START---
SELECT SUBSTRING('abcdefg' SIMILAR 'a#"%#"x|g' ESCAPE '#') AS "bcdef";
---END---
---START---
SELECT SUBSTRING('abcdefg' SIMILAR 'a#"%|ab#"g' ESCAPE '#') AS "bcdef";
---END---
---START---
-- Can't have more than two part separators
SELECT SUBSTRING('abcdefg' SIMILAR 'a*#"%#"g*#"x' ESCAPE '#') AS "error";
---END---
---START---
-- Postgres extension: with 0 or 1 separator, assume parts 1 and 3 are empty
SELECT SUBSTRING('abcdefg' SIMILAR 'a#"%g' ESCAPE '#') AS "bcdefg";
---END---
---START---
SELECT SUBSTRING('abcdefg' SIMILAR 'a%g' ESCAPE '#') AS "abcdefg";
---END---
---START---
-- substring() with just two arguments is not allowed by SQL spec;
-- we accept it, but we interpret the pattern as a POSIX regexp not SQL
SELECT SUBSTRING('abcdefg' FROM 'c.e') AS "cde";
---END---
---START---
-- With a parenthesized subexpression, return only what matches the subexpr
SELECT SUBSTRING('abcdefg' FROM 'b(.*)f') AS "cde";
---END---
---START---
-- Check case where we have a match, but not a subexpression match
SELECT SUBSTRING('foo' FROM 'foo(bar)?') IS NULL AS t;
---END---
---START---
-- Check behavior of SIMILAR TO, which uses largely the same regexp variant
SELECT 'abcdefg' SIMILAR TO '_bcd%' AS true;
---END---
---START---
SELECT 'abcdefg' SIMILAR TO 'bcd%' AS false;
---END---
---START---
SELECT 'abcdefg' SIMILAR TO '_bcd#%' ESCAPE '#' AS false;
---END---
---START---
SELECT 'abcd%' SIMILAR TO '_bcd#%' ESCAPE '#' AS true;
---END---
---START---
-- Postgres uses '\' as the default escape character, which is not per spec
SELECT 'abcdefg' SIMILAR TO '_bcd\%' AS false;
---END---
---START---
-- and an empty string to mean "no escape", which is also not per spec
SELECT 'abcd\efg' SIMILAR TO '_bcd\%' ESCAPE '' AS true;
---END---
---START---
-- these behaviors are per spec, though:
SELECT 'abcdefg' SIMILAR TO '_bcd%' ESCAPE NULL AS null;
---END---
---START---
SELECT 'abcdefg' SIMILAR TO '_bcd#%' ESCAPE '##' AS error;
---END---
---START---
-- Test backslash escapes in regexp_replace's replacement string
SELECT regexp_replace('1112223333', E'(\\d{3})(\\d{3})(\\d{4})', E'(\\1) \\2-\\3');
---END---
---START---
SELECT regexp_replace('foobarrbazz', E'(.)\\1', E'X\\&Y', 'g');
---END---
---START---
SELECT regexp_replace('foobarrbazz', E'(.)\\1', E'X\\\\Y', 'g');
---END---
---START---
-- not an error, though perhaps it should be:
SELECT regexp_replace('foobarrbazz', E'(.)\\1', E'X\\Y\\1Z\\');
---END---
---START---
SELECT regexp_replace('AAA   BBB   CCC   ', E'\\s+', ' ', 'g');
---END---
---START---
SELECT regexp_replace('AAA', '^|$', 'Z', 'g');
---END---
---START---
SELECT regexp_replace('AAA aaa', 'A+', 'Z', 'gi');
---END---
---START---
-- invalid regexp option
SELECT regexp_replace('AAA aaa', 'A+', 'Z', 'z');
---END---
---START---
-- extended regexp_replace tests
SELECT regexp_replace('A PostgreSQL function', 'A|e|i|o|u', 'X', 1);
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'A|e|i|o|u', 'X', 1, 2);
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 0, 'i');
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 1, 'i');
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 2, 'i');
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 3, 'i');
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 9, 'i');
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'A|e|i|o|u', 'X', 7, 0, 'i');
---END---
---START---
-- 'g' flag should be ignored when N is specified
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 1, 'g');
---END---
---START---
-- errors
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', -1, 0, 'i');
---END---
---START---
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, -1, 'i');
---END---
---START---
-- erroneous invocation of non-extended form
SELECT regexp_replace('A PostgreSQL function', 'a|e|i|o|u', 'X', '1');
---END---
---START---
--  regexp_count tests
SELECT regexp_count('123123123123123', '(12)3');
---END---
---START---
SELECT regexp_count('123123123123', '123', 1);
---END---
---START---
SELECT regexp_count('123123123123', '123', 3);
---END---
---START---
SELECT regexp_count('123123123123', '123', 33);
---END---
---START---
SELECT regexp_count('ABCABCABCABC', 'Abc', 1, '');
---END---
---START---
SELECT regexp_count('ABCABCABCABC', 'Abc', 1, 'i');
---END---
---START---
-- errors
SELECT regexp_count('123123123123', '123', 0);
---END---
---START---
SELECT regexp_count('123123123123', '123', -3);
---END---
---START---
-- regexp_like tests
SELECT regexp_like('Steven', '^Ste(v|ph)en$');
---END---
---START---
SELECT regexp_like('a'||CHR(10)||'d', 'a.d', 'n');
---END---
---START---
SELECT regexp_like('a'||CHR(10)||'d', 'a.d', 's');
---END---
---START---
SELECT regexp_like('abc', ' a . c ', 'x');
---END---
---START---
SELECT regexp_like('abc', 'a.c', 'g');
---END---
---START---
-- error

-- regexp_instr tests
SELECT regexp_instr('abcdefghi', 'd.f');
---END---
---START---
SELECT regexp_instr('abcdefghi', 'd.q');
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c');
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 2);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 3);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 4);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'A.C', 1, 2, 0, 'i');
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 0);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 1);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 2);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 3);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 4);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 5);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 1, 'i', 0);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 1, 'i', 1);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 1, 'i', 2);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 1, 'i', 3);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 1, 'i', 4);
---END---
---START---
SELECT regexp_instr('1234567890', '(123)(4(56)(78))', 1, 1, 1, 'i', 5);
---END---
---START---
-- Check case where we have a match, but not a subexpression match
SELECT regexp_instr('foo', 'foo(bar)?', 1, 1, 0, '', 1);
---END---
---START---
-- errors
SELECT regexp_instr('abcabcabc', 'a.c', 0, 1);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 0);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 1, -1);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 1, 2);
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 1, 0, 'g');
---END---
---START---
SELECT regexp_instr('abcabcabc', 'a.c', 1, 1, 0, '', -1);
---END---
---START---
-- regexp_substr tests
SELECT regexp_substr('abcdefghi', 'd.f');
---END---
---START---
SELECT regexp_substr('abcdefghi', 'd.q') IS NULL AS t;
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c');
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c', 2);
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c', 1, 3);
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c', 1, 4) IS NULL AS t;
---END---
---START---
SELECT regexp_substr('abcabcabc', 'A.C', 1, 2, 'i');
---END---
---START---
SELECT regexp_substr('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 0);
---END---
---START---
SELECT regexp_substr('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 1);
---END---
---START---
SELECT regexp_substr('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 2);
---END---
---START---
SELECT regexp_substr('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 3);
---END---
---START---
SELECT regexp_substr('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 4);
---END---
---START---
SELECT regexp_substr('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 5) IS NULL AS t;
---END---
---START---
-- Check case where we have a match, but not a subexpression match
SELECT regexp_substr('foo', 'foo(bar)?', 1, 1, '', 1) IS NULL AS t;
---END---
---START---
-- errors
SELECT regexp_substr('abcabcabc', 'a.c', 0, 1);
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c', 1, 0);
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c', 1, 1, 'g');
---END---
---START---
SELECT regexp_substr('abcabcabc', 'a.c', 1, 1, '', -1);
---END---
---START---
-- set so we can tell NULL from empty string
\pset null '\\N'

-- return all matches from regexp
SELECT regexp_matches('foobarbequebaz', $re$(bar)(beque)$re$);
---END---
---START---
-- test case insensitive
SELECT regexp_matches('foObARbEqUEbAz', $re$(bar)(beque)$re$, 'i');
---END---
---START---
-- global option - more than one match
SELECT regexp_matches('foobarbequebazilbarfbonk', $re$(b[^b]+)(b[^b]+)$re$, 'g');
---END---
---START---
-- empty capture group (matched empty string)
SELECT regexp_matches('foobarbequebaz', $re$(bar)(.*)(beque)$re$);
---END---
---START---
-- no match
SELECT regexp_matches('foobarbequebaz', $re$(bar)(.+)(beque)$re$);
---END---
---START---
-- optional capture group did not match, null entry in array
SELECT regexp_matches('foobarbequebaz', $re$(bar)(.+)?(beque)$re$);
---END---
---START---
-- no capture groups
SELECT regexp_matches('foobarbequebaz', $re$barbeque$re$);
---END---
---START---
-- start/end-of-line matches are of zero length
SELECT regexp_matches('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^', 'mg');
---END---
---START---
SELECT regexp_matches('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '$', 'mg');
---END---
---START---
SELECT regexp_matches('1' || chr(10) || '2' || chr(10) || '3' || chr(10) || '4' || chr(10), '^.?', 'mg');
---END---
---START---
SELECT regexp_matches(chr(10) || '1' || chr(10) || '2' || chr(10) || '3' || chr(10) || '4' || chr(10), '.?$', 'mg');
---END---
---START---
SELECT regexp_matches(chr(10) || '1' || chr(10) || '2' || chr(10) || '3' || chr(10) || '4', '.?$', 'mg');
---END---
---START---
-- give me errors
SELECT regexp_matches('foobarbequebaz', $re$(bar)(beque)$re$, 'gz');
---END---
---START---
SELECT regexp_matches('foobarbequebaz', $re$(barbeque$re$);
---END---
---START---
SELECT regexp_matches('foobarbequebaz', $re$(bar)(beque){2,1}$re$);
---END---
---START---
-- split string on regexp
SELECT foo, length(foo) FROM regexp_split_to_table('the quick brown fox jumps over the lazy dog', $re$\s+$re$) AS foo;
---END---
---START---
SELECT regexp_split_to_array('the quick brown fox jumps over the lazy dog', $re$\s+$re$);
---END---
---START---
SELECT foo, length(foo) FROM regexp_split_to_table('the quick brown fox jumps over the lazy dog', $re$\s*$re$) AS foo;
---END---
---START---
SELECT regexp_split_to_array('the quick brown fox jumps over the lazy dog', $re$\s*$re$);
---END---
---START---
SELECT foo, length(foo) FROM regexp_split_to_table('the quick brown fox jumps over the lazy dog', '') AS foo;
---END---
---START---
SELECT regexp_split_to_array('the quick brown fox jumps over the lazy dog', '');
---END---
---START---
-- case insensitive
SELECT foo, length(foo) FROM regexp_split_to_table('thE QUick bROWn FOx jUMPs ovEr The lazy dOG', 'e', 'i') AS foo;
---END---
---START---
SELECT regexp_split_to_array('thE QUick bROWn FOx jUMPs ovEr The lazy dOG', 'e', 'i');
---END---
---START---
-- no match of pattern
SELECT foo, length(foo) FROM regexp_split_to_table('the quick brown fox jumps over the lazy dog', 'nomatch') AS foo;
---END---
---START---
SELECT regexp_split_to_array('the quick brown fox jumps over the lazy dog', 'nomatch');
---END---
---START---
-- some corner cases
SELECT regexp_split_to_array('123456','1');
---END---
---START---
SELECT regexp_split_to_array('123456','6');
---END---
---START---
SELECT regexp_split_to_array('123456','.');
---END---
---START---
SELECT regexp_split_to_array('123456','');
---END---
---START---
SELECT regexp_split_to_array('123456','(?:)');
---END---
---START---
SELECT regexp_split_to_array('1','');
---END---
---START---
-- errors
SELECT foo, length(foo) FROM regexp_split_to_table('thE QUick bROWn FOx jUMPs ovEr The lazy dOG', 'e', 'zippy') AS foo;
---END---
---START---
SELECT regexp_split_to_array('thE QUick bROWn FOx jUMPs ovEr The lazy dOG', 'e', 'iz');
---END---
---START---
-- global option meaningless for regexp_split
SELECT foo, length(foo) FROM regexp_split_to_table('thE QUick bROWn FOx jUMPs ovEr The lazy dOG', 'e', 'g') AS foo;
---END---
---START---
SELECT regexp_split_to_array('thE QUick bROWn FOx jUMPs ovEr The lazy dOG', 'e', 'g');
---END---
---START---
-- change NULL-display back
\pset null ''

-- E021-11 position expression
SELECT POSITION('4' IN '1234567890') = '4' AS "4";
---END---
---START---
SELECT POSITION('5' IN '1234567890') = '5' AS "5";
---END---
---START---
-- T312 character overlay function
SELECT OVERLAY('abcdef' PLACING '45' FROM 4) AS "abc45f";
---END---
---START---
SELECT OVERLAY('yabadoo' PLACING 'daba' FROM 5) AS "yabadaba";
---END---
---START---
SELECT OVERLAY('yabadoo' PLACING 'daba' FROM 5 FOR 0) AS "yabadabadoo";
---END---
---START---
SELECT OVERLAY('babosa' PLACING 'ubb' FROM 2 FOR 4) AS "bubba";
---END---
---START---
--
-- test LIKE
-- Be sure to form every test as a LIKE/NOT LIKE pair.
--

-- simplest examples
-- E061-04 like predicate
SELECT 'hawkeye' LIKE 'h%' AS "true";
---END---
---START---
SELECT 'hawkeye' NOT LIKE 'h%' AS "false";
---END---
---START---
SELECT 'hawkeye' LIKE 'H%' AS "false";
---END---
---START---
SELECT 'hawkeye' NOT LIKE 'H%' AS "true";
---END---
---START---
SELECT 'hawkeye' LIKE 'indio%' AS "false";
---END---
---START---
SELECT 'hawkeye' NOT LIKE 'indio%' AS "true";
---END---
---START---
SELECT 'hawkeye' LIKE 'h%eye' AS "true";
---END---
---START---
SELECT 'hawkeye' NOT LIKE 'h%eye' AS "false";
---END---
---START---
SELECT 'indio' LIKE '_ndio' AS "true";
---END---
---START---
SELECT 'indio' NOT LIKE '_ndio' AS "false";
---END---
---START---
SELECT 'indio' LIKE 'in__o' AS "true";
---END---
---START---
SELECT 'indio' NOT LIKE 'in__o' AS "false";
---END---
---START---
SELECT 'indio' LIKE 'in_o' AS "false";
---END---
---START---
SELECT 'indio' NOT LIKE 'in_o' AS "true";
---END---
---START---
SELECT 'abc'::name LIKE '_b_' AS "true";
---END---
---START---
SELECT 'abc'::name NOT LIKE '_b_' AS "false";
---END---
---START---
SELECT 'abc'::bytea LIKE '_b_'::bytea AS "true";
---END---
---START---
SELECT 'abc'::bytea NOT LIKE '_b_'::bytea AS "false";
---END---
---START---
-- unused escape character
SELECT 'hawkeye' LIKE 'h%' ESCAPE '#' AS "true";
---END---
---START---
SELECT 'hawkeye' NOT LIKE 'h%' ESCAPE '#' AS "false";
---END---
---START---
SELECT 'indio' LIKE 'ind_o' ESCAPE '$' AS "true";
---END---
---START---
SELECT 'indio' NOT LIKE 'ind_o' ESCAPE '$' AS "false";
---END---
---START---
-- escape character
-- E061-05 like predicate with escape clause
SELECT 'h%' LIKE 'h#%' ESCAPE '#' AS "true";
---END---
---START---
SELECT 'h%' NOT LIKE 'h#%' ESCAPE '#' AS "false";
---END---
---START---
SELECT 'h%wkeye' LIKE 'h#%' ESCAPE '#' AS "false";
---END---
---START---
SELECT 'h%wkeye' NOT LIKE 'h#%' ESCAPE '#' AS "true";
---END---
---START---
SELECT 'h%wkeye' LIKE 'h#%%' ESCAPE '#' AS "true";
---END---
---START---
SELECT 'h%wkeye' NOT LIKE 'h#%%' ESCAPE '#' AS "false";
---END---
---START---
SELECT 'h%awkeye' LIKE 'h#%a%k%e' ESCAPE '#' AS "true";
---END---
---START---
SELECT 'h%awkeye' NOT LIKE 'h#%a%k%e' ESCAPE '#' AS "false";
---END---
---START---
SELECT 'indio' LIKE '_ndio' ESCAPE '$' AS "true";
---END---
---START---
SELECT 'indio' NOT LIKE '_ndio' ESCAPE '$' AS "false";
---END---
---START---
SELECT 'i_dio' LIKE 'i$_d_o' ESCAPE '$' AS "true";
---END---
---START---
SELECT 'i_dio' NOT LIKE 'i$_d_o' ESCAPE '$' AS "false";
---END---
---START---
SELECT 'i_dio' LIKE 'i$_nd_o' ESCAPE '$' AS "false";
---END---
---START---
SELECT 'i_dio' NOT LIKE 'i$_nd_o' ESCAPE '$' AS "true";
---END---
---START---
SELECT 'i_dio' LIKE 'i$_d%o' ESCAPE '$' AS "true";
---END---
---START---
SELECT 'i_dio' NOT LIKE 'i$_d%o' ESCAPE '$' AS "false";
---END---
---START---
SELECT 'a_c'::bytea LIKE 'a$__'::bytea ESCAPE '$'::bytea AS "true";
---END---
---START---
SELECT 'a_c'::bytea NOT LIKE 'a$__'::bytea ESCAPE '$'::bytea AS "false";
---END---
---START---
-- escape character same as pattern character
SELECT 'maca' LIKE 'm%aca' ESCAPE '%' AS "true";
---END---
---START---
SELECT 'maca' NOT LIKE 'm%aca' ESCAPE '%' AS "false";
---END---
---START---
SELECT 'ma%a' LIKE 'm%a%%a' ESCAPE '%' AS "true";
---END---
---START---
SELECT 'ma%a' NOT LIKE 'm%a%%a' ESCAPE '%' AS "false";
---END---
---START---
SELECT 'bear' LIKE 'b_ear' ESCAPE '_' AS "true";
---END---
---START---
SELECT 'bear' NOT LIKE 'b_ear' ESCAPE '_' AS "false";
---END---
---START---
SELECT 'be_r' LIKE 'b_e__r' ESCAPE '_' AS "true";
---END---
---START---
SELECT 'be_r' NOT LIKE 'b_e__r' ESCAPE '_' AS "false";
---END---
---START---
SELECT 'be_r' LIKE '__e__r' ESCAPE '_' AS "false";
---END---
---START---
SELECT 'be_r' NOT LIKE '__e__r' ESCAPE '_' AS "true";
---END---
---START---
--
-- test ILIKE (case-insensitive LIKE)
-- Be sure to form every test as an ILIKE/NOT ILIKE pair.
--

SELECT 'hawkeye' ILIKE 'h%' AS "true";
---END---
---START---
SELECT 'hawkeye' NOT ILIKE 'h%' AS "false";
---END---
---START---
SELECT 'hawkeye' ILIKE 'H%' AS "true";
---END---
---START---
SELECT 'hawkeye' NOT ILIKE 'H%' AS "false";
---END---
---START---
SELECT 'hawkeye' ILIKE 'H%Eye' AS "true";
---END---
---START---
SELECT 'hawkeye' NOT ILIKE 'H%Eye' AS "false";
---END---
---START---
SELECT 'Hawkeye' ILIKE 'h%' AS "true";
---END---
---START---
SELECT 'Hawkeye' NOT ILIKE 'h%' AS "false";
---END---
---START---
SELECT 'ABC'::name ILIKE '_b_' AS "true";
---END---
---START---
SELECT 'ABC'::name NOT ILIKE '_b_' AS "false";
---END---
---START---
--
-- test %/_ combination cases, cf bugs #4821 and #5478
--

SELECT 'foo' LIKE '_%' as t, 'f' LIKE '_%' as t, '' LIKE '_%' as f;
---END---
---START---
SELECT 'foo' LIKE '%_' as t, 'f' LIKE '%_' as t, '' LIKE '%_' as f;
---END---
---START---
SELECT 'foo' LIKE '__%' as t, 'foo' LIKE '___%' as t, 'foo' LIKE '____%' as f;
---END---
---START---
SELECT 'foo' LIKE '%__' as t, 'foo' LIKE '%___' as t, 'foo' LIKE '%____' as f;
---END---
---START---
SELECT 'jack' LIKE '%____%' AS t;
---END---
---START---
--
-- basic tests of LIKE with indexes
--

CREATE TABLE texttest (a text PRIMARY KEY, b int);
---END---
---START---
SELECT * FROM texttest WHERE a LIKE '%1%';
---END---
---START---
CREATE TABLE byteatest (a bytea PRIMARY KEY, b int);
---END---
---START---
SELECT * FROM byteatest WHERE a LIKE '%1%';
---END---
---START---
DROP TABLE texttest, byteatest;
---END---
---START---
--
-- test implicit type conversion
--

-- E021-07 character concatenation
SELECT 'unknown' || ' and unknown' AS "Concat unknown types";
---END---
---START---
SELECT text 'text' || ' and unknown' AS "Concat text to unknown type";
---END---
---START---
SELECT char(20) 'characters' || ' and text' AS "Concat char to unknown type";
---END---
---START---
SELECT text 'text' || char(20) ' and characters' AS "Concat text to char";
---END---
---START---
SELECT text 'text' || varchar ' and varchar' AS "Concat text to varchar";
---END---
---START---
CREATE TABLE toasttest (gemini_pk serial PRIMARY KEY, f1 text);
---END---
---START---
insert into toasttest values(repeat('1234567890',10000));
---END---
---START---
insert into toasttest values(repeat('1234567890',10000));
---END---
---START---
--
-- Ensure that some values are uncompressed, to test the faster substring
-- operation used in that case
--
alter table toasttest alter column f1 set storage external;
---END---
---START---
insert into toasttest values(repeat('1234567890',10000));
---END---
---START---
insert into toasttest values(repeat('1234567890',10000));
---END---
---START---
-- If the starting position is zero or less, then return from the start of the string
-- adjusting the length to be consistent with the "negative start" per SQL.
SELECT substr(f1, -1, 5) from toasttest;
---END---
---START---
-- If the length is less than zero, an ERROR is thrown.
SELECT substr(f1, 5, -1) from toasttest;
---END---
---START---
-- If no third argument (length) is provided, the length to the end of the
-- string is assumed.
SELECT substr(f1, 99995) from toasttest;
---END---
---START---
-- If start plus length is > string length, the result is truncated to
-- string length
SELECT substr(f1, 99995, 10) from toasttest;
---END---
---START---
TRUNCATE TABLE toasttest;
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
-- expect >0 blocks
SELECT pg_relation_size(reltoastrelid) = 0 AS is_empty
  FROM pg_class where relname = 'toasttest';
---END---
---START---
TRUNCATE TABLE toasttest;
---END---
---START---
ALTER TABLE toasttest set (toast_tuple_target = 4080);
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
INSERT INTO toasttest values (repeat('1234567890',300));
---END---
---START---
-- expect 0 blocks
SELECT pg_relation_size(reltoastrelid) = 0 AS is_empty
  FROM pg_class where relname = 'toasttest';
---END---
---START---
DROP TABLE toasttest;
---END---
---START---
CREATE TABLE toasttest (gemini_pk serial PRIMARY KEY, f1 bytea);
---END---
---START---
insert into toasttest values(decode(repeat('1234567890',10000),'escape'));
---END---
---START---
insert into toasttest values(decode(repeat('1234567890',10000),'escape'));
---END---
---START---
--
-- Ensure that some values are uncompressed, to test the faster substring
-- operation used in that case
--
alter table toasttest alter column f1 set storage external;
---END---
---START---
insert into toasttest values(decode(repeat('1234567890',10000),'escape'));
---END---
---START---
insert into toasttest values(decode(repeat('1234567890',10000),'escape'));
---END---
---START---
-- If the starting position is zero or less, then return from the start of the string
-- adjusting the length to be consistent with the "negative start" per SQL.
SELECT substr(f1, -1, 5) from toasttest;
---END---
---START---
-- If the length is less than zero, an ERROR is thrown.
SELECT substr(f1, 5, -1) from toasttest;
---END---
---START---
-- If no third argument (length) is provided, the length to the end of the
-- string is assumed.
SELECT substr(f1, 99995) from toasttest;
---END---
---START---
-- If start plus length is > string length, the result is truncated to
-- string length
SELECT substr(f1, 99995, 10) from toasttest;
---END---
---START---
DROP TABLE toasttest;
---END---
---START---
CREATE TABLE toasttest (gemini_pk serial PRIMARY KEY, c char(4096));
---END---
---START---
INSERT INTO toasttest VALUES('x');
---END---
---START---
SELECT length(c), c::text FROM toasttest;
---END---
---START---
SELECT c FROM toasttest;
---END---
---START---
DROP TABLE toasttest;
---END---
---START---
--
-- test length
--

SELECT length('abcdef') AS "length_6";
---END---
---START---
--
-- test strpos
--

SELECT strpos('abcdef', 'cd') AS "pos_3";
---END---
---START---
SELECT strpos('abcdef', 'xy') AS "pos_0";
---END---
---START---
SELECT strpos('abcdef', '') AS "pos_1";
---END---
---START---
SELECT strpos('', 'xy') AS "pos_0";
---END---
---START---
SELECT strpos('', '') AS "pos_1";
---END---
---START---
--
-- test replace
--
SELECT replace('abcdef', 'de', '45') AS "abc45f";
---END---
---START---
SELECT replace('yabadabadoo', 'ba', '123') AS "ya123da123doo";
---END---
---START---
SELECT replace('yabadoo', 'bad', '') AS "yaoo";
---END---
---START---
--
-- test split_part
--
select split_part('','@',1) AS "empty string";
---END---
---START---
select split_part('','@',-1) AS "empty string";
---END---
---START---
select split_part('joeuser@mydatabase','',1) AS "joeuser@mydatabase";
---END---
---START---
select split_part('joeuser@mydatabase','',2) AS "empty string";
---END---
---START---
select split_part('joeuser@mydatabase','',-1) AS "joeuser@mydatabase";
---END---
---START---
select split_part('joeuser@mydatabase','',-2) AS "empty string";
---END---
---START---
select split_part('joeuser@mydatabase','@',0) AS "an error";
---END---
---START---
select split_part('joeuser@mydatabase','@@',1) AS "joeuser@mydatabase";
---END---
---START---
select split_part('joeuser@mydatabase','@@',2) AS "empty string";
---END---
---START---
select split_part('joeuser@mydatabase','@',1) AS "joeuser";
---END---
---START---
select split_part('joeuser@mydatabase','@',2) AS "mydatabase";
---END---
---START---
select split_part('joeuser@mydatabase','@',3) AS "empty string";
---END---
---START---
select split_part('@joeuser@mydatabase@','@',2) AS "joeuser";
---END---
---START---
select split_part('joeuser@mydatabase','@',-1) AS "mydatabase";
---END---
---START---
select split_part('joeuser@mydatabase','@',-2) AS "joeuser";
---END---
---START---
select split_part('joeuser@mydatabase','@',-3) AS "empty string";
---END---
---START---
select split_part('@joeuser@mydatabase@','@',-2) AS "mydatabase";
---END---
---START---
--
-- test to_hex
--
select to_hex(256*256*256 - 1) AS "ffffff";
---END---
---START---
select to_hex(256::bigint*256::bigint*256::bigint*256::bigint - 1) AS "ffffffff";
---END---
---START---
--
-- SHA-2
--
SET bytea_output TO hex;
---END---
---START---
SELECT sha224('');
---END---
---START---
SELECT sha224('The quick brown fox jumps over the lazy dog.');
---END---
---START---
SELECT sha256('');
---END---
---START---
SELECT sha256('The quick brown fox jumps over the lazy dog.');
---END---
---START---
SELECT sha384('');
---END---
---START---
SELECT sha384('The quick brown fox jumps over the lazy dog.');
---END---
---START---
SELECT sha512('');
---END---
---START---
SELECT sha512('The quick brown fox jumps over the lazy dog.');
---END---
---START---
--
-- encode/decode
--
SELECT encode('\x1234567890abcdef00', 'hex');
---END---
---START---
SELECT decode('1234567890abcdef00', 'hex');
---END---
---START---
SELECT encode(('\x' || repeat('1234567890abcdef0001', 7))::bytea, 'base64');
---END---
---START---
SELECT decode(encode(('\x' || repeat('1234567890abcdef0001', 7))::bytea,
                     'base64'), 'base64');
---END---
---START---
SELECT encode('\x1234567890abcdef00', 'escape');
---END---
---START---
SELECT decode(encode('\x1234567890abcdef00', 'escape'), 'escape');
---END---
---START---
--
-- get_bit/set_bit etc
--
SELECT get_bit('\x1234567890abcdef00'::bytea, 43);
---END---
---START---
SELECT get_bit('\x1234567890abcdef00'::bytea, 99);
---END---
---START---
-- error
SELECT set_bit('\x1234567890abcdef00'::bytea, 43, 0);
---END---
---START---
SELECT set_bit('\x1234567890abcdef00'::bytea, 99, 0);
---END---
---START---
-- error
SELECT get_byte('\x1234567890abcdef00'::bytea, 3);
---END---
---START---
SELECT get_byte('\x1234567890abcdef00'::bytea, 99);
---END---
---START---
-- error
SELECT set_byte('\x1234567890abcdef00'::bytea, 7, 11);
---END---
---START---
SELECT set_byte('\x1234567890abcdef00'::bytea, 99, 11);
---END---
---START---
-- error

--
-- test behavior of escape_string_warning and standard_conforming_strings options
--
set escape_string_warning = off;
---END---
---START---
set standard_conforming_strings = off;
---END---
---START---
show escape_string_warning;
---END---
---START---
show standard_conforming_strings;
---END---
---START---
set escape_string_warning = on;
---END---
---START---
set standard_conforming_strings = on;
---END---
---START---
show escape_string_warning;
---END---
---START---
show standard_conforming_strings;
---END---
---START---
select 'a\bcd' as f1, 'a\b''cd' as f2, 'a\b''''cd' as f3, 'abcd\'   as f4, 'ab\''cd' as f5, '\\' as f6;
---END---
---START---
set standard_conforming_strings = off;
---END---
---START---
select 'a\\bcd' as f1, 'a\\b\'cd' as f2, 'a\\b\'''cd' as f3, 'abcd\\'   as f4, 'ab\\\'cd' as f5, '\\\\' as f6;

set escape_string_warning = off;
set standard_conforming_strings = on;

select 'a\bcd' as f1, 'a\b''cd' as f2, 'a\b''''cd' as f3, 'abcd\'   as f4, 'ab\''cd' as f5, '\\' as f6;

set standard_conforming_strings = off;

select 'a\\bcd' as f1, 'a\\b\'cd' as f2, 'a\\b\'''cd' as f3, 'abcd\\'   as f4, 'ab\\\'cd' as f5, '\\\\' as f6;
---END---
---START---
reset standard_conforming_strings;
---END---
---START---
--
-- Additional string functions
--
SET bytea_output TO escape;
---END---
---START---
SELECT initcap('hi THOMAS');
---END---
---START---
SELECT lpad('hi', 5, 'xy');
---END---
---START---
SELECT lpad('hi', 5);
---END---
---START---
SELECT lpad('hi', -5, 'xy');
---END---
---START---
SELECT lpad('hello', 2);
---END---
---START---
SELECT lpad('hi', 5, '');
---END---
---START---
SELECT rpad('hi', 5, 'xy');
---END---
---START---
SELECT rpad('hi', 5);
---END---
---START---
SELECT rpad('hi', -5, 'xy');
---END---
---START---
SELECT rpad('hello', 2);
---END---
---START---
SELECT rpad('hi', 5, '');
---END---
---START---
SELECT ltrim('zzzytrim', 'xyz');
---END---
---START---
SELECT translate('', '14', 'ax');
---END---
---START---
SELECT translate('12345', '14', 'ax');
---END---
---START---
SELECT translate('12345', '134', 'a');
---END---
---START---
SELECT ascii('x');
---END---
---START---
SELECT ascii('');
---END---
---START---
SELECT chr(65);
---END---
---START---
SELECT chr(0);
---END---
---START---
SELECT repeat('Pg', 4);
---END---
---START---
SELECT repeat('Pg', -4);
---END---
---START---
SELECT SUBSTRING('1234567890'::bytea FROM 3) "34567890";
---END---
---START---
SELECT SUBSTRING('1234567890'::bytea FROM 4 FOR 3) AS "456";
---END---
---START---
SELECT SUBSTRING('string'::bytea FROM 2 FOR 2147483646) AS "tring";
---END---
---START---
SELECT SUBSTRING('string'::bytea FROM -10 FOR 2147483646) AS "string";
---END---
---START---
SELECT SUBSTRING('string'::bytea FROM -10 FOR -2147483646) AS "error";
---END---
---START---
SELECT trim(E'\\000'::bytea from E'\\000Tom\\000'::bytea);
---END---
---START---
SELECT trim(leading E'\\000'::bytea from E'\\000Tom\\000'::bytea);
---END---
---START---
SELECT trim(trailing E'\\000'::bytea from E'\\000Tom\\000'::bytea);
---END---
---START---
SELECT btrim(E'\\000trim\\000'::bytea, E'\\000'::bytea);
---END---
---START---
SELECT btrim(''::bytea, E'\\000'::bytea);
---END---
---START---
SELECT btrim(E'\\000trim\\000'::bytea, ''::bytea);
---END---
---START---
SELECT encode(overlay(E'Th\\000omas'::bytea placing E'Th\\001omas'::bytea from 2),'escape');
---END---
---START---
SELECT encode(overlay(E'Th\\000omas'::bytea placing E'\\002\\003'::bytea from 8),'escape');
---END---
---START---
SELECT encode(overlay(E'Th\\000omas'::bytea placing E'\\002\\003'::bytea from 5 for 3),'escape');
---END---
---START---
SELECT bit_count('\x1234567890'::bytea);
---END---
---START---
SELECT unistr('\0064at\+0000610');
---END---
---START---
SELECT unistr('d\u0061t\U000000610');
---END---
---START---
SELECT unistr('a\\b');
---END---
---START---
-- errors:
SELECT unistr('wrong: \db99');
---END---
---START---
SELECT unistr('wrong: \db99\0061');
---END---
---START---
SELECT unistr('wrong: \+00db99\+000061');
---END---
---START---
SELECT unistr('wrong: \+2FFFFF');
---END---
---START---
SELECT unistr('wrong: \udb99\u0061');
---END---
---START---
SELECT unistr('wrong: \U0000db99\U00000061');
---END---
---START---
SELECT unistr('wrong: \U002FFFFF');
---END---
---START---
SELECT unistr('wrong: \xyz');
---END---
