---START---
--
-- PORTALS_P2
--

BEGIN;
---END---
---START---

DECLARE foo13 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 50;
---END---
---START---

DECLARE foo14 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 51;
---END---
---START---

DECLARE foo15 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 52;
---END---
---START---

DECLARE foo16 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 53;
---END---
---START---

DECLARE foo17 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 54;
---END---
---START---

DECLARE foo18 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 55;
---END---
---START---

DECLARE foo19 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 56;
---END---
---START---

DECLARE foo20 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 57;
---END---
---START---

DECLARE foo21 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 58;
---END---
---START---

DECLARE foo22 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 59;
---END---
---START---

DECLARE foo23 CURSOR FOR
   SELECT * FROM onek WHERE unique1 = 60;
---END---
---START---

DECLARE foo24 CURSOR FOR
   SELECT * FROM onek2 WHERE unique1 = 50;
---END---
---START---

DECLARE foo25 CURSOR FOR
   SELECT * FROM onek2 WHERE unique1 = 60;
---END---
---START---

FETCH all in foo13;
---END---
---START---

FETCH all in foo14;
---END---
---START---

FETCH all in foo15;
---END---
---START---

FETCH all in foo16;
---END---
---START---

FETCH all in foo17;
---END---
---START---

FETCH all in foo18;
---END---
---START---

FETCH all in foo19;
---END---
---START---

FETCH all in foo20;
---END---
---START---

FETCH all in foo21;
---END---
---START---

FETCH all in foo22;
---END---
---START---

FETCH all in foo23;
---END---
---START---

FETCH all in foo24;
---END---
---START---

FETCH all in foo25;
---END---
---START---

CLOSE foo13;
---END---
---START---

CLOSE foo14;
---END---
---START---

CLOSE foo15;
---END---
---START---

CLOSE foo16;
---END---
---START---

CLOSE foo17;
---END---
---START---

CLOSE foo18;
---END---
---START---

CLOSE foo19;
---END---
---START---

CLOSE foo20;
---END---
---START---

CLOSE foo21;
---END---
---START---

CLOSE foo22;
---END---
---START---

CLOSE foo23;
---END---
---START---

CLOSE foo24;
---END---
---START---

CLOSE foo25;
---END---
---START---

END;
---END---
