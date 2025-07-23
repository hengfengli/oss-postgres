---START---
--
-- ADVISORY LOCKS
--

SELECT oid AS datoid FROM pg_database WHERE datname = current_database() \gset

BEGIN;
---END---
---START---

SELECT
	pg_advisory_xact_lock(1), pg_advisory_xact_lock_shared(2),
	pg_advisory_xact_lock(1, 1), pg_advisory_xact_lock_shared(2, 2);
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---


-- pg_advisory_unlock_all() shouldn't release xact locks
SELECT pg_advisory_unlock_all();
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
---START---


-- can't unlock xact locks
SELECT
	pg_advisory_unlock(1), pg_advisory_unlock_shared(2),
	pg_advisory_unlock(1, 1), pg_advisory_unlock_shared(2, 2);
---END---
---START---


-- automatically release xact locks at commit
COMMIT;
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
---START---


BEGIN;
---END---
---START---

-- holding both session and xact locks on the same objects, xact first
SELECT
	pg_advisory_xact_lock(1), pg_advisory_xact_lock_shared(2),
	pg_advisory_xact_lock(1, 1), pg_advisory_xact_lock_shared(2, 2);
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---

SELECT
	pg_advisory_lock(1), pg_advisory_lock_shared(2),
	pg_advisory_lock(1, 1), pg_advisory_lock_shared(2, 2);
---END---
---START---

ROLLBACK;
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---


-- unlocking session locks
SELECT
	pg_advisory_unlock(1), pg_advisory_unlock(1),
	pg_advisory_unlock_shared(2), pg_advisory_unlock_shared(2),
	pg_advisory_unlock(1, 1), pg_advisory_unlock(1, 1),
	pg_advisory_unlock_shared(2, 2), pg_advisory_unlock_shared(2, 2);
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
---START---


BEGIN;
---END---
---START---

-- holding both session and xact locks on the same objects, session first
SELECT
	pg_advisory_lock(1), pg_advisory_lock_shared(2),
	pg_advisory_lock(1, 1), pg_advisory_lock_shared(2, 2);
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---

SELECT
	pg_advisory_xact_lock(1), pg_advisory_xact_lock_shared(2),
	pg_advisory_xact_lock(1, 1), pg_advisory_xact_lock_shared(2, 2);
---END---
---START---

ROLLBACK;
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---


-- releasing all session locks
SELECT pg_advisory_unlock_all();
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
---START---


BEGIN;
---END---
---START---

-- grabbing txn locks multiple times

SELECT
	pg_advisory_xact_lock(1), pg_advisory_xact_lock(1),
	pg_advisory_xact_lock_shared(2), pg_advisory_xact_lock_shared(2),
	pg_advisory_xact_lock(1, 1), pg_advisory_xact_lock(1, 1),
	pg_advisory_xact_lock_shared(2, 2), pg_advisory_xact_lock_shared(2, 2);
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---

COMMIT;
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
---START---

-- grabbing session locks multiple times

SELECT
	pg_advisory_lock(1), pg_advisory_lock(1),
	pg_advisory_lock_shared(2), pg_advisory_lock_shared(2),
	pg_advisory_lock(1, 1), pg_advisory_lock(1, 1),
	pg_advisory_lock_shared(2, 2), pg_advisory_lock_shared(2, 2);
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---

SELECT
	pg_advisory_unlock(1), pg_advisory_unlock(1),
	pg_advisory_unlock_shared(2), pg_advisory_unlock_shared(2),
	pg_advisory_unlock(1, 1), pg_advisory_unlock(1, 1),
	pg_advisory_unlock_shared(2, 2), pg_advisory_unlock_shared(2, 2);
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
---START---

-- .. and releasing them all at once

SELECT
	pg_advisory_lock(1), pg_advisory_lock(1),
	pg_advisory_lock_shared(2), pg_advisory_lock_shared(2),
	pg_advisory_lock(1, 1), pg_advisory_lock(1, 1),
	pg_advisory_lock_shared(2, 2), pg_advisory_lock_shared(2, 2);
---END---
---START---

SELECT locktype, classid, objid, objsubid, mode, granted
	FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid
	ORDER BY classid, objid, objsubid;
---END---
---START---

SELECT pg_advisory_unlock_all();
---END---
---START---

SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND database = :datoid;
---END---
