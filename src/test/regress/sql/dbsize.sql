---START---
SELECT size, pg_size_pretty(size), pg_size_pretty(-1 * size) FROM
    (VALUES (10::bigint), (1000::bigint), (1000000::bigint),
            (1000000000::bigint), (1000000000000::bigint),
            (1000000000000000::bigint)) x(size);
---END---
---START---
SELECT size, pg_size_pretty(size), pg_size_pretty(-1 * size) FROM
    (VALUES (10::numeric), (1000::numeric), (1000000::numeric),
            (1000000000::numeric), (1000000000000::numeric),
            (1000000000000000::numeric),
            (10.5::numeric), (1000.5::numeric), (1000000.5::numeric),
            (1000000000.5::numeric), (1000000000000.5::numeric),
            (1000000000000000.5::numeric)) x(size);
---END---
---START---
-- test where units change up
SELECT size, pg_size_pretty(size), pg_size_pretty(-1 * size) FROM
    (VALUES (10239::bigint), (10240::bigint),
            (10485247::bigint), (10485248::bigint),
            (10736893951::bigint), (10736893952::bigint),
            (10994579406847::bigint), (10994579406848::bigint),
            (11258449312612351::bigint), (11258449312612352::bigint)) x(size);
---END---
---START---
SELECT size, pg_size_pretty(size), pg_size_pretty(-1 * size) FROM
    (VALUES (10239::numeric), (10240::numeric),
            (10485247::numeric), (10485248::numeric),
            (10736893951::numeric), (10736893952::numeric),
            (10994579406847::numeric), (10994579406848::numeric),
            (11258449312612351::numeric), (11258449312612352::numeric),
            (11528652096115048447::numeric), (11528652096115048448::numeric)) x(size);
---END---
---START---
-- pg_size_bytes() tests
SELECT size, pg_size_bytes(size) FROM
    (VALUES ('1'), ('123bytes'), ('256 B'), ('1kB'), ('1MB'), (' 1 GB'), ('1.5 GB '),
            ('1TB'), ('3000 TB'), ('1e6 MB'), ('99 PB')) x(size);
---END---
---START---
-- case-insensitive units are supported
SELECT size, pg_size_bytes(size) FROM
    (VALUES ('1'), ('123bYteS'), ('1kb'), ('1mb'), (' 1 Gb'), ('1.5 gB '),
            ('1tb'), ('3000 tb'), ('1e6 mb'), ('99 pb')) x(size);
---END---
---START---
-- negative numbers are supported
SELECT size, pg_size_bytes(size) FROM
    (VALUES ('-1'), ('-123bytes'), ('-1kb'), ('-1mb'), (' -1 Gb'), ('-1.5 gB '),
            ('-1tb'), ('-3000 TB'), ('-10e-1 MB'), ('-99 PB')) x(size);
---END---
---START---
-- different cases with allowed points
SELECT size, pg_size_bytes(size) FROM
     (VALUES ('-1.'), ('-1.kb'), ('-1. kb'), ('-0. gb'),
             ('-.1'), ('-.1kb'), ('-.1 kb'), ('-.0 gb')) x(size);
---END---
---START---
-- invalid inputs
SELECT pg_size_bytes('1 AB');
---END---
---START---
SELECT pg_size_bytes('1 AB A');
---END---
---START---
SELECT pg_size_bytes('1 AB A    ');
---END---
---START---
SELECT pg_size_bytes('9223372036854775807.9');
---END---
---START---
SELECT pg_size_bytes('1e100');
---END---
---START---
SELECT pg_size_bytes('1e1000000000000000000');
---END---
---START---
SELECT pg_size_bytes('1 byte');
---END---
---START---
-- the singular "byte" is not supported
SELECT pg_size_bytes('');
---END---
---START---
SELECT pg_size_bytes('kb');
---END---
---START---
SELECT pg_size_bytes('..');
---END---
---START---
SELECT pg_size_bytes('-.');
---END---
---START---
SELECT pg_size_bytes('-.kb');
---END---
---START---
SELECT pg_size_bytes('-. kb');
---END---
---START---
SELECT pg_size_bytes('.+912');
---END---
---START---
SELECT pg_size_bytes('+912+ kB');
---END---
---START---
SELECT pg_size_bytes('++123 kB');
---END---
