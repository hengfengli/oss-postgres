---START---
--
-- encoding-sensitive tests for json and jsonb
--

-- We provide expected-results files for UTF8 (json_encoding.out)
-- and for SQL_ASCII (json_encoding_1.out).  Skip otherwise.
SELECT getdatabaseencoding() NOT IN ('UTF8', 'SQL_ASCII')
       AS skip_test \gset
\if :skip_test
\quit
\endif

SELECT getdatabaseencoding();
---END---
---START---
-- just to label the results files

-- first json

-- basic unicode input
SELECT '"\u"'::json;
---END---
---START---
-- ERROR, incomplete escape
SELECT '"\u00"'::json;
---END---
---START---
-- ERROR, incomplete escape
SELECT '"\u000g"'::json;
---END---
---START---
-- ERROR, g is not a hex digit
SELECT '"\u0000"'::json;
---END---
---START---
-- OK, legal escape
SELECT '"\uaBcD"'::json;
---END---
---START---
-- OK, uppercase and lower case both OK

-- handling of unicode surrogate pairs

select json '{ "a":  "\ud83d\ude04\ud83d\udc36" }' -> 'a' as correct_in_utf8;
---END---
---START---
select json '{ "a":  "\ud83d\ud83d" }' -> 'a';
---END---
---START---
-- 2 high surrogates in a row
select json '{ "a":  "\ude04\ud83d" }' -> 'a';
---END---
---START---
-- surrogates in wrong order
select json '{ "a":  "\ud83dX" }' -> 'a';
---END---
---START---
-- orphan high surrogate
select json '{ "a":  "\ude04X" }' -> 'a';
---END---
---START---
-- orphan low surrogate

--handling of simple unicode escapes

select json '{ "a":  "the Copyright \u00a9 sign" }' as correct_in_utf8;
---END---
---START---
select json '{ "a":  "dollar \u0024 character" }' as correct_everywhere;
---END---
---START---
select json '{ "a":  "dollar \\u0024 character" }' as not_an_escape;
---END---
---START---
select json '{ "a":  "null \u0000 escape" }' as not_unescaped;
---END---
---START---
select json '{ "a":  "null \\u0000 escape" }' as not_an_escape;
---END---
---START---
select json '{ "a":  "the Copyright \u00a9 sign" }' ->> 'a' as correct_in_utf8;
---END---
---START---
select json '{ "a":  "dollar \u0024 character" }' ->> 'a' as correct_everywhere;
---END---
---START---
select json '{ "a":  "dollar \\u0024 character" }' ->> 'a' as not_an_escape;
---END---
---START---
select json '{ "a":  "null \u0000 escape" }' ->> 'a' as fails;
---END---
---START---
select json '{ "a":  "null \\u0000 escape" }' ->> 'a' as not_an_escape;
---END---
---START---
-- then jsonb

-- basic unicode input
SELECT '"\u"'::jsonb;
---END---
---START---
-- ERROR, incomplete escape
SELECT '"\u00"'::jsonb;
---END---
---START---
-- ERROR, incomplete escape
SELECT '"\u000g"'::jsonb;
---END---
---START---
-- ERROR, g is not a hex digit
SELECT '"\u0045"'::jsonb;
---END---
---START---
-- OK, legal escape
SELECT '"\u0000"'::jsonb;
---END---
---START---
-- ERROR, we don't support U+0000
-- use octet_length here so we don't get an odd unicode char in the
-- output
SELECT octet_length('"\uaBcD"'::jsonb::text);
---END---
---START---
-- OK, uppercase and lower case both OK

-- handling of unicode surrogate pairs

SELECT octet_length((jsonb '{ "a":  "\ud83d\ude04\ud83d\udc36" }' -> 'a')::text) AS correct_in_utf8;
---END---
---START---
SELECT jsonb '{ "a":  "\ud83d\ud83d" }' -> 'a';
---END---
---START---
-- 2 high surrogates in a row
SELECT jsonb '{ "a":  "\ude04\ud83d" }' -> 'a';
---END---
---START---
-- surrogates in wrong order
SELECT jsonb '{ "a":  "\ud83dX" }' -> 'a';
---END---
---START---
-- orphan high surrogate
SELECT jsonb '{ "a":  "\ude04X" }' -> 'a';
---END---
---START---
-- orphan low surrogate

-- handling of simple unicode escapes

SELECT jsonb '{ "a":  "the Copyright \u00a9 sign" }' as correct_in_utf8;
---END---
---START---
SELECT jsonb '{ "a":  "dollar \u0024 character" }' as correct_everywhere;
---END---
---START---
SELECT jsonb '{ "a":  "dollar \\u0024 character" }' as not_an_escape;
---END---
---START---
SELECT jsonb '{ "a":  "null \u0000 escape" }' as fails;
---END---
---START---
SELECT jsonb '{ "a":  "null \\u0000 escape" }' as not_an_escape;
---END---
---START---
SELECT jsonb '{ "a":  "the Copyright \u00a9 sign" }' ->> 'a' as correct_in_utf8;
---END---
---START---
SELECT jsonb '{ "a":  "dollar \u0024 character" }' ->> 'a' as correct_everywhere;
---END---
---START---
SELECT jsonb '{ "a":  "dollar \\u0024 character" }' ->> 'a' as not_an_escape;
---END---
---START---
SELECT jsonb '{ "a":  "null \u0000 escape" }' ->> 'a' as fails;
---END---
---START---
SELECT jsonb '{ "a":  "null \\u0000 escape" }' ->> 'a' as not_an_escape;
---END---
---START---
-- soft error for input-time failure

select * from pg_input_error_info('{ "a":  "\ud83d\ude04\ud83d\udc36" }', 'jsonb');
---END---
