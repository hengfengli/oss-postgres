---START---
--jsonpath io

select ''::jsonpath;
---END---
---START---
select '$'::jsonpath;
---END---
---START---
select 'strict $'::jsonpath;
---END---
---START---
select 'lax $'::jsonpath;
---END---
---START---
select '$.a'::jsonpath;
---END---
---START---
select '$.a.v'::jsonpath;
---END---
---START---
select '$.a.*'::jsonpath;
---END---
---START---
select '$.*[*]'::jsonpath;
---END---
---START---
select '$.a[*]'::jsonpath;
---END---
---START---
select '$.a[*][*]'::jsonpath;
---END---
---START---
select '$[*]'::jsonpath;
---END---
---START---
select '$[0]'::jsonpath;
---END---
---START---
select '$[*][0]'::jsonpath;
---END---
---START---
select '$[*].a'::jsonpath;
---END---
---START---
select '$[*][0].a.b'::jsonpath;
---END---
---START---
select '$.a.**.b'::jsonpath;
---END---
---START---
select '$.a.**{2}.b'::jsonpath;
---END---
---START---
select '$.a.**{2 to 2}.b'::jsonpath;
---END---
---START---
select '$.a.**{2 to 5}.b'::jsonpath;
---END---
---START---
select '$.a.**{0 to 5}.b'::jsonpath;
---END---
---START---
select '$.a.**{5 to last}.b'::jsonpath;
---END---
---START---
select '$.a.**{last}.b'::jsonpath;
---END---
---START---
select '$.a.**{last to 5}.b'::jsonpath;
---END---
---START---
select '$+1'::jsonpath;
---END---
---START---
select '$-1'::jsonpath;
---END---
---START---
select '$--+1'::jsonpath;
---END---
---START---
select '$.a/+-1'::jsonpath;
---END---
---START---
select '1 * 2 + 4 % -3 != false'::jsonpath;
---END---
---START---
select '"\b\f\r\n\t\v\"\''\\"'::jsonpath;
---END---
---START---
select '"\x50\u0067\u{53}\u{051}\u{00004C}"'::jsonpath;
---END---
---START---
select '$.foo\x50\u0067\u{53}\u{051}\u{00004C}\t\"bar'::jsonpath;
---END---
---START---
select '"\z"'::jsonpath;
---END---
---START---
-- unrecognized escape is just the literal char

select '$.g ? ($.a == 1)'::jsonpath;
---END---
---START---
select '$.g ? (@ == 1)'::jsonpath;
---END---
---START---
select '$.g ? (@.a == 1)'::jsonpath;
---END---
---START---
select '$.g ? (@.a == 1 || @.a == 4)'::jsonpath;
---END---
---START---
select '$.g ? (@.a == 1 && @.a == 4)'::jsonpath;
---END---
---START---
select '$.g ? (@.a == 1 || @.a == 4 && @.b == 7)'::jsonpath;
---END---
---START---
select '$.g ? (@.a == 1 || !(@.a == 4) && @.b == 7)'::jsonpath;
---END---
---START---
select '$.g ? (@.a == 1 || !(@.x >= 123 || @.a == 4) && @.b == 7)'::jsonpath;
---END---
---START---
select '$.g ? (@.x >= @[*]?(@.a > "abc"))'::jsonpath;
---END---
---START---
select '$.g ? ((@.x >= 123 || @.a == 4) is unknown)'::jsonpath;
---END---
---START---
select '$.g ? (exists (@.x))'::jsonpath;
---END---
---START---
select '$.g ? (exists (@.x ? (@ == 14)))'::jsonpath;
---END---
---START---
select '$.g ? ((@.x >= 123 || @.a == 4) && exists (@.x ? (@ == 14)))'::jsonpath;
---END---
---START---
select '$.g ? (+@.x >= +-(+@.a + 2))'::jsonpath;
---END---
---START---
select '$a'::jsonpath;
---END---
---START---
select '$a.b'::jsonpath;
---END---
---START---
select '$a[*]'::jsonpath;
---END---
---START---
select '$.g ? (@.zip == $zip)'::jsonpath;
---END---
---START---
select '$.a[1,2, 3 to 16]'::jsonpath;
---END---
---START---
select '$.a[$a + 1, ($b[*]) to -($[0] * 2)]'::jsonpath;
---END---
---START---
select '$.a[$.a.size() - 3]'::jsonpath;
---END---
---START---
select 'last'::jsonpath;
---END---
---START---
select '"last"'::jsonpath;
---END---
---START---
select '$.last'::jsonpath;
---END---
---START---
select '$ ? (last > 0)'::jsonpath;
---END---
---START---
select '$[last]'::jsonpath;
---END---
---START---
select '$[$[0] ? (last > 0)]'::jsonpath;
---END---
---START---
select 'null.type()'::jsonpath;
---END---
---START---
select '1.type()'::jsonpath;
---END---
---START---
select '(1).type()'::jsonpath;
---END---
---START---
select '1.2.type()'::jsonpath;
---END---
---START---
select '"aaa".type()'::jsonpath;
---END---
---START---
select 'true.type()'::jsonpath;
---END---
---START---
select '$.double().floor().ceiling().abs()'::jsonpath;
---END---
---START---
select '$.keyvalue().key'::jsonpath;
---END---
---START---
select '$.datetime()'::jsonpath;
---END---
---START---
select '$.datetime("datetime template")'::jsonpath;
---END---
---START---
select '$ ? (@ starts with "abc")'::jsonpath;
---END---
---START---
select '$ ? (@ starts with $var)'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "(invalid pattern")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "i")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "is")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "isim")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "xsms")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "q")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "iq")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "smixq")'::jsonpath;
---END---
---START---
select '$ ? (@ like_regex "pattern" flag "a")'::jsonpath;
---END---
---START---
select '$ < 1'::jsonpath;
---END---
---START---
select '($ < 1) || $.a.b <= $x'::jsonpath;
---END---
---START---
select '@ + 1'::jsonpath;
---END---
---START---
select '($).a.b'::jsonpath;
---END---
---START---
select '($.a.b).c.d'::jsonpath;
---END---
---START---
select '($.a.b + -$.x.y).c.d'::jsonpath;
---END---
---START---
select '(-+$.a.b).c.d'::jsonpath;
---END---
---START---
select '1 + ($.a.b + 2).c.d'::jsonpath;
---END---
---START---
select '1 + ($.a.b > 2).c.d'::jsonpath;
---END---
---START---
select '($)'::jsonpath;
---END---
---START---
select '(($))'::jsonpath;
---END---
---START---
select '((($ + 1)).a + ((2)).b ? ((((@ > 1)) || (exists(@.c)))))'::jsonpath;
---END---
---START---
select '$ ? (@.a < 1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < .1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 0.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -0.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +0.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 10.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -10.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +10.1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < .1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 0.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -0.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +0.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 10.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -10.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +10.1e1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < .1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 0.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -0.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +0.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 10.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -10.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +10.1e-1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < .1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 0.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -0.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +0.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < 10.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < -10.1e+1)'::jsonpath;
---END---
---START---
select '$ ? (@.a < +10.1e+1)'::jsonpath;
---END---
---START---
-- numeric literals

select '0'::jsonpath;
---END---
---START---
select '00'::jsonpath;
---END---
---START---
select '0755'::jsonpath;
---END---
---START---
select '0.0'::jsonpath;
---END---
---START---
select '0.000'::jsonpath;
---END---
---START---
select '0.000e1'::jsonpath;
---END---
---START---
select '0.000e2'::jsonpath;
---END---
---START---
select '0.000e3'::jsonpath;
---END---
---START---
select '0.0010'::jsonpath;
---END---
---START---
select '0.0010e-1'::jsonpath;
---END---
---START---
select '0.0010e+1'::jsonpath;
---END---
---START---
select '0.0010e+2'::jsonpath;
---END---
---START---
select '.001'::jsonpath;
---END---
---START---
select '.001e1'::jsonpath;
---END---
---START---
select '1.'::jsonpath;
---END---
---START---
select '1.e1'::jsonpath;
---END---
---START---
select '1a'::jsonpath;
---END---
---START---
select '1e'::jsonpath;
---END---
---START---
select '1.e'::jsonpath;
---END---
---START---
select '1.2a'::jsonpath;
---END---
---START---
select '1.2e'::jsonpath;
---END---
---START---
select '1.2.e'::jsonpath;
---END---
---START---
select '(1.2).e'::jsonpath;
---END---
---START---
select '1e3'::jsonpath;
---END---
---START---
select '1.e3'::jsonpath;
---END---
---START---
select '1.e3.e'::jsonpath;
---END---
---START---
select '1.e3.e4'::jsonpath;
---END---
---START---
select '1.2e3'::jsonpath;
---END---
---START---
select '1.2e3a'::jsonpath;
---END---
---START---
select '1.2.e3'::jsonpath;
---END---
---START---
select '(1.2).e3'::jsonpath;
---END---
---START---
select '1..e'::jsonpath;
---END---
---START---
select '1..e3'::jsonpath;
---END---
---START---
select '(1.).e'::jsonpath;
---END---
---START---
select '(1.).e3'::jsonpath;
---END---
---START---
select '1?(2>3)'::jsonpath;
---END---
---START---
-- nondecimal
select '0b100101'::jsonpath;
---END---
---START---
select '0o273'::jsonpath;
---END---
---START---
select '0x42F'::jsonpath;
---END---
---START---
-- error cases
select '0b'::jsonpath;
---END---
---START---
select '1b'::jsonpath;
---END---
---START---
select '0b0x'::jsonpath;
---END---
---START---
select '0o'::jsonpath;
---END---
---START---
select '1o'::jsonpath;
---END---
---START---
select '0o0x'::jsonpath;
---END---
---START---
select '0x'::jsonpath;
---END---
---START---
select '1x'::jsonpath;
---END---
---START---
select '0x0y'::jsonpath;
---END---
---START---
-- underscores
select '1_000_000'::jsonpath;
---END---
---START---
select '1_2_3'::jsonpath;
---END---
---START---
select '0x1EEE_FFFF'::jsonpath;
---END---
---START---
select '0o2_73'::jsonpath;
---END---
---START---
select '0b10_0101'::jsonpath;
---END---
---START---
select '1_000.000_005'::jsonpath;
---END---
---START---
select '1_000.'::jsonpath;
---END---
---START---
select '.000_005'::jsonpath;
---END---
---START---
select '1_000.5e0_1'::jsonpath;
---END---
---START---
-- error cases
select '_100'::jsonpath;
---END---
---START---
select '100_'::jsonpath;
---END---
---START---
select '100__000'::jsonpath;
---END---
---START---
select '_1_000.5'::jsonpath;
---END---
---START---
select '1_000_.5'::jsonpath;
---END---
---START---
select '1_000._5'::jsonpath;
---END---
---START---
select '1_000.5_'::jsonpath;
---END---
---START---
select '1_000.5e_1'::jsonpath;
---END---
---START---
-- underscore after prefix not allowed in JavaScript (but allowed in SQL)
select '0b_10_0101'::jsonpath;
---END---
---START---
select '0o_273'::jsonpath;
---END---
---START---
select '0x_42F'::jsonpath;
---END---
---START---
-- test non-error-throwing API

SELECT str as jsonpath,
       pg_input_is_valid(str,'jsonpath') as ok,
       errinfo.sql_error_code,
       errinfo.message,
       errinfo.detail,
       errinfo.hint
FROM unnest(ARRAY['$ ? (@ like_regex "pattern" flag "smixq")'::text,
                  '$ ? (@ like_regex "pattern" flag "a")',
                  '@ + 1',
                  '00',
                  '1a']) str,
     LATERAL pg_input_error_info(str, 'jsonpath') as errinfo;
---END---
