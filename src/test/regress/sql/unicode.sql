---START---
SELECT getdatabaseencoding() <> 'UTF8' AS skip_test \gset
\if :skip_test
\quit
\endif

SELECT U&'\0061\0308bc' <> U&'\00E4bc' COLLATE "C" AS sanity_check;
---END---
---START---
SELECT normalize('');
---END---
---START---
SELECT normalize(U&'\0061\0308\24D1c') = U&'\00E4\24D1c' COLLATE "C" AS test_default;
---END---
---START---
SELECT normalize(U&'\0061\0308\24D1c', NFC) = U&'\00E4\24D1c' COLLATE "C" AS test_nfc;
---END---
---START---
SELECT normalize(U&'\00E4bc', NFC) = U&'\00E4bc' COLLATE "C" AS test_nfc_idem;
---END---
---START---
SELECT normalize(U&'\00E4\24D1c', NFD) = U&'\0061\0308\24D1c' COLLATE "C" AS test_nfd;
---END---
---START---
SELECT normalize(U&'\0061\0308\24D1c', NFKC) = U&'\00E4bc' COLLATE "C" AS test_nfkc;
---END---
---START---
SELECT normalize(U&'\00E4\24D1c', NFKD) = U&'\0061\0308bc' COLLATE "C" AS test_nfkd;
---END---
---START---
SELECT "normalize"('abc', 'def');
---END---
---START---
-- run-time error

SELECT U&'\00E4\24D1c' IS NORMALIZED AS test_default;
---END---
---START---
SELECT U&'\00E4\24D1c' IS NFC NORMALIZED AS test_nfc;
---END---
---START---
SELECT num, val,
    val IS NFC NORMALIZED AS NFC,
    val IS NFD NORMALIZED AS NFD,
    val IS NFKC NORMALIZED AS NFKC,
    val IS NFKD NORMALIZED AS NFKD
FROM
  (VALUES (1, U&'\00E4bc'),
          (2, U&'\0061\0308bc'),
          (3, U&'\00E4\24D1c'),
          (4, U&'\0061\0308\24D1c'),
          (5, '')) vals (num, val)
ORDER BY num;
---END---
---START---
SELECT is_normalized('abc', 'def');
---END---
