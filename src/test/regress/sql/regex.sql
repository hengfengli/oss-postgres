---START---
--
-- Regular expression tests
--

-- Don't want to have to double backslashes in regexes
set standard_conforming_strings = on;
---END---
---START---

-- Test simple quantified backrefs
select 'bbbbb' ~ '^([bc])\1*$' as t;
---END---
---START---
select 'ccc' ~ '^([bc])\1*$' as t;
---END---
---START---
select 'xxx' ~ '^([bc])\1*$' as f;
---END---
---START---
select 'bbc' ~ '^([bc])\1*$' as f;
---END---
---START---
select 'b' ~ '^([bc])\1*$' as t;
---END---
---START---

-- Test quantified backref within a larger expression
select 'abc abc abc' ~ '^(\w+)( \1)+$' as t;
---END---
---START---
select 'abc abd abc' ~ '^(\w+)( \1)+$' as f;
---END---
---START---
select 'abc abc abd' ~ '^(\w+)( \1)+$' as f;
---END---
---START---
select 'abc abc abc' ~ '^(.+)( \1)+$' as t;
---END---
---START---
select 'abc abd abc' ~ '^(.+)( \1)+$' as f;
---END---
---START---
select 'abc abc abd' ~ '^(.+)( \1)+$' as f;
---END---
---START---

-- Test some cases that crashed in 9.2beta1 due to pmatch[] array overrun
select substring('asd TO foo' from ' TO (([a-z0-9._]+|"([^"]+|"")+")+)');
---END---
---START---
select substring('a' from '((a))+');
---END---
---START---
select substring('a' from '((a)+)');
---END---
---START---

-- Test regexp_match()
select regexp_match('abc', '');
---END---
---START---
select regexp_match('abc', 'bc');
---END---
---START---
select regexp_match('abc', 'd') is null;
---END---
---START---
select regexp_match('abc', '(B)(c)', 'i');
---END---
---START---
select regexp_match('abc', 'Bd', 'ig'); -- error

-- Test lookahead constraints
select regexp_matches('ab', 'a(?=b)b*');
---END---
---START---
select regexp_matches('a', 'a(?=b)b*');
---END---
---START---
select regexp_matches('abc', 'a(?=b)b*(?=c)c*');
---END---
---START---
select regexp_matches('ab', 'a(?=b)b*(?=c)c*');
---END---
---START---
select regexp_matches('ab', 'a(?!b)b*');
---END---
---START---
select regexp_matches('a', 'a(?!b)b*');
---END---
---START---
select regexp_matches('b', '(?=b)b');
---END---
---START---
select regexp_matches('a', '(?=b)b');
---END---
---START---

-- Test lookbehind constraints
select regexp_matches('abb', '(?<=a)b*');
---END---
---START---
select regexp_matches('a', 'a(?<=a)b*');
---END---
---START---
select regexp_matches('abc', 'a(?<=a)b*(?<=b)c*');
---END---
---START---
select regexp_matches('ab', 'a(?<=a)b*(?<=b)c*');
---END---
---START---
select regexp_matches('ab', 'a*(?<!a)b*');
---END---
---START---
select regexp_matches('ab', 'a*(?<!a)b+');
---END---
---START---
select regexp_matches('b', 'a*(?<!a)b+');
---END---
---START---
select regexp_matches('a', 'a(?<!a)b*');
---END---
---START---
select regexp_matches('b', '(?<=b)b');
---END---
---START---
select regexp_matches('foobar', '(?<=f)b+');
---END---
---START---
select regexp_matches('foobar', '(?<=foo)b+');
---END---
---START---
select regexp_matches('foobar', '(?<=oo)b+');
---END---
---START---

-- Test optimization of single-chr-or-bracket-expression lookaround constraints
select 'xz' ~ 'x(?=[xy])';
---END---
---START---
select 'xy' ~ 'x(?=[xy])';
---END---
---START---
select 'xz' ~ 'x(?![xy])';
---END---
---START---
select 'xy' ~ 'x(?![xy])';
---END---
---START---
select 'x'  ~ 'x(?![xy])';
---END---
---START---
select 'xyy' ~ '(?<=[xy])yy+';
---END---
---START---
select 'zyy' ~ '(?<=[xy])yy+';
---END---
---START---
select 'xyy' ~ '(?<![xy])yy+';
---END---
---START---
select 'zyy' ~ '(?<![xy])yy+';
---END---
---START---

-- Test conversion of regex patterns to indexable conditions
explain (costs off) select * from pg_proc where proname ~ 'abc';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^abc';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^abc$';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^abcd*e';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^abc+d';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^(abc)(def)';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^(abc)$';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^(abc)?d';
---END---
---START---
explain (costs off) select * from pg_proc where proname ~ '^abcd(x|(?=\w\w)q)';
---END---
---START---

-- Test for infinite loop in pullback() (CVE-2007-4772)
select 'a' ~ '($|^)*';
---END---
---START---

-- These cases expose a bug in the original fix for CVE-2007-4772
select 'a' ~ '(^)+^';
---END---
---START---
select 'a' ~ '$($$)+';
---END---
---START---

-- More cases of infinite loop in pullback(), not fixed by CVE-2007-4772 fix
select 'a' ~ '($^)+';
---END---
---START---
select 'a' ~ '(^$)*';
---END---
---START---
select 'aa bb cc' ~ '(^(?!aa))+';
---END---
---START---
select 'aa x' ~ '(^(?!aa)(?!bb)(?!cc))+';
---END---
---START---
select 'bb x' ~ '(^(?!aa)(?!bb)(?!cc))+';
---END---
---START---
select 'cc x' ~ '(^(?!aa)(?!bb)(?!cc))+';
---END---
---START---
select 'dd x' ~ '(^(?!aa)(?!bb)(?!cc))+';
---END---
---START---

-- Test for infinite loop in fixempties() (Tcl bugs 3604074, 3606683)
select 'a' ~ '((((((a)*)*)*)*)*)*';
---END---
---START---
select 'a' ~ '((((((a+|)+|)+|)+|)+|)+|)';
---END---
---START---

-- These cases used to give too-many-states failures
select 'x' ~ 'abcd(\m)+xyz';
---END---
---START---
select 'a' ~ '^abcd*(((((^(a c(e?d)a+|)+|)+|)+|)+|a)+|)';
---END---
---START---
select 'x' ~ 'a^(^)bcd*xy(((((($a+|)+|)+|)+$|)+|)+|)^$';
---END---
---START---
select 'x' ~ 'xyz(\Y\Y)+';
---END---
---START---
select 'x' ~ 'x|(?:\M)+';
---END---
---START---

-- This generates O(N) states but O(N^2) arcs, so it causes problems
-- if arc count is not constrained
select 'x' ~ repeat('x*y*z*', 1000);
---END---
---START---

-- Test backref in combination with non-greedy quantifier
-- https://core.tcl.tk/tcl/tktview/6585b21ca8fa6f3678d442b97241fdd43dba2ec0
select 'Programmer' ~ '(\w).*?\1' as t;
---END---
---START---
select regexp_matches('Programmer', '(\w)(.*?\1)', 'g');
---END---
---START---

-- Test for proper matching of non-greedy iteration (bug #11478)
select regexp_matches('foo/bar/baz',
                      '^([^/]+?)(?:/([^/]+?))(?:/([^/]+?))?$', '');
---END---
---START---

-- Test that greediness can be overridden by outer quantifier
select regexp_matches('llmmmfff', '^(l*)(.*)(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*){1,1}(.*)(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*){1,1}?(.*)(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*){1,1}?(.*){1,1}?(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*?)(.*)(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*?){1,1}(.*)(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*?){1,1}?(.*)(f*)$');
---END---
---START---
select regexp_matches('llmmmfff', '^(l*?){1,1}?(.*){1,1}?(f*)$');
---END---
---START---

-- Test for infinite loop in cfindloop with zero-length possible match
-- but no actual match (can only happen in the presence of backrefs)
select 'a' ~ '$()|^\1';
---END---
---START---
select 'a' ~ '.. ()|\1';
---END---
---START---
select 'a' ~ '()*\1';
---END---
---START---
select 'a' ~ '()+\1';
---END---
---START---

-- Test incorrect removal of capture groups within {0}
select 'xxx' ~ '(.){0}(\1)' as f;
---END---
---START---
select 'xxx' ~ '((.)){0}(\2)' as f;
---END---
---START---
select 'xyz' ~ '((.)){0}(\2){0}' as t;
---END---
---START---

-- Test ancient oversight in when to apply zaptreesubs
select 'abcdef' ~ '^(.)\1|\1.' as f;
---END---
---START---
select 'abadef' ~ '^((.)\2|..)\2' as f;
---END---
---START---

-- Add coverage for some cases in checkmatchall
select regexp_match('xy', '.|...');
---END---
---START---
select regexp_match('xyz', '.|...');
---END---
---START---
select regexp_match('xy', '.*');
---END---
---START---
select regexp_match('fooba', '(?:..)*');
---END---
---START---
select regexp_match('xyz', repeat('.', 260));
---END---
---START---
select regexp_match('foo', '(?:.|){99}');
---END---
---START---

-- Error conditions
select 'xyz' ~ 'x(\w)(?=\1)';  -- no backrefs in LACONs
select 'xyz' ~ 'x(\w)(?=(\1))';
---END---
