---START---
--
-- NAME
-- all inputs are silently truncated at NAMEDATALEN-1 (63) characters
--

-- fixed-length by reference
SELECT name 'name string' = name 'name string' AS "True";
---END---
---START---

SELECT name 'name string' = name 'name string ' AS "False";
---END---
---START---

--
--
--

CREATE TABLE NAME_TBL(f1 name);
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR');
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqr');
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('asdfghjkl;');
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('343f%2a');
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('d34aaasdf');
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('');
---END---
---START---

INSERT INTO NAME_TBL(f1) VALUES ('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ');
---END---
---START---


SELECT * FROM NAME_TBL;
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 <> '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 < '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 <= '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 > '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 >= '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ABCDEFGHIJKLMNOPQR';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 ~ '.*';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 !~ '.*';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 ~ '[0-9]';
---END---
---START---

SELECT c.f1 FROM NAME_TBL c WHERE c.f1 ~ '.*asdf.*';
---END---
---START---

DROP TABLE NAME_TBL;
---END---
---START---

DO $$
DECLARE r text[];
---END---
---START---
BEGIN
  r := parse_ident('Schemax.Tabley');
---END---
---START---
  RAISE NOTICE '%', format('%I.%I', r[1], r[2]);
---END---
---START---
  r := parse_ident('"SchemaX"."TableY"');
---END---
---START---
  RAISE NOTICE '%', format('%I.%I', r[1], r[2]);
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

SELECT parse_ident('foo.boo');
---END---
---START---
SELECT parse_ident('foo.boo[]'); -- should fail
SELECT parse_ident('foo.boo[]', strict => false); -- ok

-- should fail
SELECT parse_ident(' ');
---END---
---START---
SELECT parse_ident(' .aaa');
---END---
---START---
SELECT parse_ident(' aaa . ');
---END---
---START---
SELECT parse_ident('aaa.a%b');
---END---
---START---
SELECT parse_ident(E'X\rXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
---END---
---START---

SELECT length(a[1]), length(a[2]) from parse_ident('"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx".yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy') as a ;
---END---
---START---

SELECT parse_ident(' first . "  second  " ."   third   ". "  ' || repeat('x',66) || '"');
---END---
---START---
SELECT parse_ident(' first . "  second  " ."   third   ". "  ' || repeat('x',66) || '"')::name[];
---END---
---START---

SELECT parse_ident(E'"c".X XXXX\002XXXXXX');
---END---
---START---
SELECT parse_ident('1020');
---END---
---START---
SELECT parse_ident('10.20');
---END---
---START---
SELECT parse_ident('.');
---END---
---START---
SELECT parse_ident('.1020');
---END---
---START---
SELECT parse_ident('xxx.1020');
---END---
