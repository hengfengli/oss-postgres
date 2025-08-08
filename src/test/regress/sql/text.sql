---START---
--
-- TEXT
--

SELECT text 'this is a text string' = text 'this is a text string' AS true;
---END---
---START---
SELECT text 'this is a text string' = text 'this is a text strin' AS false;
---END---
---START---
-- text_tbl was already created and filled in test_setup.sql.
SELECT * FROM TEXT_TBL;
---END---
---START---
-- As of 8.3 we have removed most implicit casts to text, so that for example
-- this no longer works:

select length(42);
---END---
---START---
-- But as a special exception for usability's sake, we still allow implicit
-- casting to text in concatenations, so long as the other input is text or
-- an unknown literal.  So these work:

select 'four: '::text || 2+2;
---END---
---START---
select 'four: ' || 2+2;
---END---
---START---
-- but not this:

select 3 || 4.0;
---END---
---START---
/*
 * various string functions
 */
select concat('one');
---END---
---START---
select concat(1,2,3,'hello',true, false, to_date('20100309','YYYYMMDD'));
---END---
---START---
select concat_ws('#','one');
---END---
---START---
select concat_ws('#',1,2,3,'hello',true, false, to_date('20100309','YYYYMMDD'));
---END---
---START---
select concat_ws(',',10,20,null,30);
---END---
---START---
select concat_ws('',10,20,null,30);
---END---
---START---
select concat_ws(NULL,10,20,null,30) is null;
---END---
---START---
select reverse('abcde');
---END---
---START---
select i, left('ahoj', i), right('ahoj', i) from generate_series(-5, 5) t(i) order by i;
---END---
---START---
select quote_literal('');
---END---
---START---
select quote_literal('abc''');
---END---
---START---
select quote_literal(e'\\');
---END---
---START---
-- check variadic labeled argument
select concat(variadic array[1,2,3]);
---END---
---START---
select concat_ws(',', variadic array[1,2,3]);
---END---
---START---
select concat_ws(',', variadic NULL::int[]);
---END---
---START---
select concat(variadic NULL::int[]) is NULL;
---END---
---START---
select concat(variadic '{}'::int[]) = '';
---END---
---START---
--should fail
select concat_ws(',', variadic 10);
---END---
---START---
/*
 * format
 */
select format(NULL);
---END---
---START---
select format('Hello');
---END---
---START---
select format('Hello %s', 'World');
---END---
---START---
select format('Hello %%');
---END---
---START---
select format('Hello %%%%');
---END---
---START---
-- should fail
select format('Hello %s %s', 'World');
---END---
---START---
select format('Hello %s');
---END---
---START---
select format('Hello %x', 20);
---END---
---START---
-- check literal and sql identifiers
select format('INSERT INTO %I VALUES(%L,%L)', 'mytab', 10, 'Hello');
---END---
---START---
select format('%s%s%s','Hello', NULL,'World');
---END---
---START---
select format('INSERT INTO %I VALUES(%L,%L)', 'mytab', 10, NULL);
---END---
---START---
select format('INSERT INTO %I VALUES(%L,%L)', 'mytab', NULL, 'Hello');
---END---
---START---
-- should fail, sql identifier cannot be NULL
select format('INSERT INTO %I VALUES(%L,%L)', NULL, 10, 'Hello');
---END---
---START---
-- check positional placeholders
select format('%1$s %3$s', 1, 2, 3);
---END---
---START---
select format('%1$s %12$s', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
---END---
---START---
-- should fail
select format('%1$s %4$s', 1, 2, 3);
---END---
---START---
select format('%1$s %13$s', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
---END---
---START---
select format('%0$s', 'Hello');
---END---
---START---
select format('%*0$s', 'Hello');
---END---
---START---
select format('%1$', 1);
---END---
---START---
select format('%1$1', 1);
---END---
---START---
-- check mix of positional and ordered placeholders
select format('Hello %s %1$s %s', 'World', 'Hello again');
---END---
---START---
select format('Hello %s %s, %2$s %2$s', 'World', 'Hello again');
---END---
---START---
-- check variadic labeled arguments
select format('%s, %s', variadic array['Hello','World']);
---END---
---START---
select format('%s, %s', variadic array[1, 2]);
---END---
---START---
select format('%s, %s', variadic array[true, false]);
---END---
---START---
select format('%s, %s', variadic array[true, false]::text[]);
---END---
---START---
-- check variadic with positional placeholders
select format('%2$s, %1$s', variadic array['first', 'second']);
---END---
---START---
select format('%2$s, %1$s', variadic array[1, 2]);
---END---
---START---
-- variadic argument can be array type NULL, but should not be referenced
select format('Hello', variadic NULL::int[]);
---END---
---START---
-- variadic argument allows simulating more than FUNC_MAX_ARGS parameters
select format(string_agg('%s',','), variadic array_agg(i))
from generate_series(1,200) g(i);
---END---
---START---
-- check field widths and left, right alignment
select format('>>%10s<<', 'Hello');
---END---
---START---
select format('>>%10s<<', NULL);
---END---
---START---
select format('>>%10s<<', '');
---END---
---START---
select format('>>%-10s<<', '');
---END---
---START---
select format('>>%-10s<<', 'Hello');
---END---
---START---
select format('>>%-10s<<', NULL);
---END---
---START---
select format('>>%1$10s<<', 'Hello');
---END---
---START---
select format('>>%1$-10I<<', 'Hello');
---END---
---START---
select format('>>%2$*1$L<<', 10, 'Hello');
---END---
---START---
select format('>>%2$*1$L<<', 10, NULL);
---END---
---START---
select format('>>%2$*1$L<<', -10, NULL);
---END---
---START---
select format('>>%*s<<', 10, 'Hello');
---END---
---START---
select format('>>%*1$s<<', 10, 'Hello');
---END---
---START---
select format('>>%-s<<', 'Hello');
---END---
---START---
select format('>>%10L<<', NULL);
---END---
---START---
select format('>>%2$*1$L<<', NULL, 'Hello');
---END---
---START---
select format('>>%2$*1$L<<', 0, 'Hello');
---END---
