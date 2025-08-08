---START---
CREATE OPERATOR === (
        PROCEDURE = int8eq,
        LEFTARG = bigint,
        RIGHTARG = bigint,
        COMMUTATOR = ===
);
---END---
---START---
CREATE OPERATOR !== (
        PROCEDURE = int8ne,
        LEFTARG = bigint,
        RIGHTARG = bigint,
        NEGATOR = ===,
        COMMUTATOR = !==
);
---END---
---START---
DROP OPERATOR !==(bigint, bigint);
---END---
---START---
SELECT  ctid, oprcom
FROM    pg_catalog.pg_operator fk
WHERE   oprcom != 0 AND
        NOT EXISTS(SELECT 1 FROM pg_catalog.pg_operator pk WHERE pk.oid = fk.oprcom);
---END---
---START---
SELECT  ctid, oprnegate
FROM    pg_catalog.pg_operator fk
WHERE   oprnegate != 0 AND
        NOT EXISTS(SELECT 1 FROM pg_catalog.pg_operator pk WHERE pk.oid = fk.oprnegate);
---END---
---START---
DROP OPERATOR ===(bigint, bigint);
---END---
---START---
CREATE OPERATOR <| (
        PROCEDURE = int8lt,
        LEFTARG = bigint,
        RIGHTARG = bigint
);
---END---
---START---
CREATE OPERATOR |> (
        PROCEDURE = int8gt,
        LEFTARG = bigint,
        RIGHTARG = bigint,
        NEGATOR = <|,
        COMMUTATOR = <|
);
---END---
---START---
DROP OPERATOR |>(bigint, bigint);
---END---
---START---
SELECT  ctid, oprcom
FROM    pg_catalog.pg_operator fk
WHERE   oprcom != 0 AND
        NOT EXISTS(SELECT 1 FROM pg_catalog.pg_operator pk WHERE pk.oid = fk.oprcom);
---END---
---START---
SELECT  ctid, oprnegate
FROM    pg_catalog.pg_operator fk
WHERE   oprnegate != 0 AND
        NOT EXISTS(SELECT 1 FROM pg_catalog.pg_operator pk WHERE pk.oid = fk.oprnegate);
---END---
---START---
DROP OPERATOR <|(bigint, bigint);
---END---
