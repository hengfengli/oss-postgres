---START---
CREATE TABLE delete_test (
    id SERIAL PRIMARY KEY,
    a INT,
    b text
);
---END---
---START---
INSERT INTO delete_test (a) VALUES (10);
---END---
---START---
INSERT INTO delete_test (a, b) VALUES (50, repeat('x', 10000));
---END---
---START---
INSERT INTO delete_test (a) VALUES (100);
---END---
---START---
-- allow an alias to be specified for DELETE's target table
DELETE FROM delete_test AS dt WHERE dt.a > 75;
---END---
---START---
-- if an alias is specified, don't allow the original table name
-- to be referenced
DELETE FROM delete_test dt WHERE delete_test.a > 25;
---END---
---START---
SELECT id, a, char_length(b) FROM delete_test;
---END---
---START---
-- delete a row with a TOASTed value
DELETE FROM delete_test WHERE a > 25;
---END---
---START---
SELECT id, a, char_length(b) FROM delete_test;
---END---
---START---
DROP TABLE delete_test;
---END---
