---START---
--
-- encoding-sensitive tests for jsonpath
--

-- We provide expected-results files for UTF8 (jsonpath_encoding.out)
-- and for SQL_ASCII (jsonpath_encoding_1.out).  Skip otherwise.
SELECT getdatabaseencoding() NOT IN ('UTF8', 'SQL_ASCII')
       AS skip_test \gset
\if :skip_test
\quit
\endif

SELECT getdatabaseencoding();
---END---
---START---
-- just to label the results files

-- checks for double-quoted values

-- basic unicode input
SELECT '"\u"'::jsonpath;
---END---
---START---
-- ERROR, incomplete escape
SELECT '"\u00"'::jsonpath;
---END---
---START---
-- ERROR, incomplete escape
SELECT '"\u000g"'::jsonpath;
---END---
---START---
-- ERROR, g is not a hex digit
SELECT '"\u0000"'::jsonpath;
---END---
---START---
-- OK, legal escape
SELECT '"\uaBcD"'::jsonpath;
---END---
---START---
-- OK, uppercase and lower case both OK

-- handling of unicode surrogate pairs
select '"\ud83d\ude04\ud83d\udc36"'::jsonpath as correct_in_utf8;
---END---
---START---
select '"\ud83d\ud83d"'::jsonpath;
---END---
---START---
-- 2 high surrogates in a row
select '"\ude04\ud83d"'::jsonpath;
---END---
---START---
-- surrogates in wrong order
select '"\ud83dX"'::jsonpath;
---END---
---START---
-- orphan high surrogate
select '"\ude04X"'::jsonpath;
---END---
---START---
-- orphan low surrogate

--handling of simple unicode escapes
select '"the Copyright \u00a9 sign"'::jsonpath as correct_in_utf8;
---END---
---START---
select '"dollar \u0024 character"'::jsonpath as correct_everywhere;
---END---
---START---
select '"dollar \\u0024 character"'::jsonpath as not_an_escape;
---END---
---START---
select '"null \u0000 escape"'::jsonpath as not_unescaped;
---END---
---START---
select '"null \\u0000 escape"'::jsonpath as not_an_escape;
---END---
---START---
-- checks for quoted key names

-- basic unicode input
SELECT '$."\u"'::jsonpath;
---END---
---START---
-- ERROR, incomplete escape
SELECT '$."\u00"'::jsonpath;
---END---
---START---
-- ERROR, incomplete escape
SELECT '$."\u000g"'::jsonpath;
---END---
---START---
-- ERROR, g is not a hex digit
SELECT '$."\u0000"'::jsonpath;
---END---
---START---
-- OK, legal escape
SELECT '$."\uaBcD"'::jsonpath;
---END---
---START---
-- OK, uppercase and lower case both OK

-- handling of unicode surrogate pairs
select '$."\ud83d\ude04\ud83d\udc36"'::jsonpath as correct_in_utf8;
---END---
---START---
select '$."\ud83d\ud83d"'::jsonpath;
---END---
---START---
-- 2 high surrogates in a row
select '$."\ude04\ud83d"'::jsonpath;
---END---
---START---
-- surrogates in wrong order
select '$."\ud83dX"'::jsonpath;
---END---
---START---
-- orphan high surrogate
select '$."\ude04X"'::jsonpath;
---END---
---START---
-- orphan low surrogate

--handling of simple unicode escapes
select '$."the Copyright \u00a9 sign"'::jsonpath as correct_in_utf8;
---END---
---START---
select '$."dollar \u0024 character"'::jsonpath as correct_everywhere;
---END---
---START---
select '$."dollar \\u0024 character"'::jsonpath as not_an_escape;
---END---
---START---
select '$."null \u0000 escape"'::jsonpath as not_unescaped;
---END---
---START---
select '$."null \\u0000 escape"'::jsonpath as not_an_escape;
---END---
