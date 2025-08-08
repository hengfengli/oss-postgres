---START---
--
-- Tests for password types
--

-- Tests for GUC password_encryption
SET password_encryption = 'novalue';
---END---
---START---
-- error
SET password_encryption = true;
---END---
---START---
-- error
SET password_encryption = 'md5';
---END---
---START---
-- ok
SET password_encryption = 'scram-sha-256';
---END---
---START---
-- ok

-- consistency of password entries
SET password_encryption = 'md5';
---END---
---START---
CREATE ROLE regress_passwd1 PASSWORD 'role_pwd1';
---END---
---START---
CREATE ROLE regress_passwd2 PASSWORD 'role_pwd2';
---END---
---START---
SET password_encryption = 'scram-sha-256';
---END---
---START---
CREATE ROLE regress_passwd3 PASSWORD 'role_pwd3';
---END---
---START---
CREATE ROLE regress_passwd4 PASSWORD NULL;
---END---
---START---
-- check list of created entries
--
-- The scram secret will look something like:
-- SCRAM-SHA-256$4096:E4HxLGtnRzsYwg==$6YtlR4t69SguDiwFvbVgVZtuz6gpJQQqUMZ7IQJK5yI=:ps75jrHeYU4lXCcXI4O8oIdJ3eO8o2jirjruw9phBTo=
--
-- Since the salt is random, the exact value stored will be different on every test
-- run. Use a regular expression to mask the changing parts.
SELECT rolname, regexp_replace(rolpassword, '(SCRAM-SHA-256)\$(\d+):([a-zA-Z0-9+/=]+)\$([a-zA-Z0-9+=/]+):([a-zA-Z0-9+/=]+)', '\1$\2:<salt>$<storedkey>:<serverkey>') as rolpassword_masked
    FROM pg_authid
    WHERE rolname LIKE 'regress_passwd%'
    ORDER BY rolname, rolpassword;
---END---
---START---
-- Rename a role
ALTER ROLE regress_passwd2 RENAME TO regress_passwd2_new;
---END---
---START---
-- md5 entry should have been removed
SELECT rolname, rolpassword
    FROM pg_authid
    WHERE rolname LIKE 'regress_passwd2_new'
    ORDER BY rolname, rolpassword;
---END---
---START---
ALTER ROLE regress_passwd2_new RENAME TO regress_passwd2;
---END---
---START---
-- Change passwords with ALTER USER. With plaintext or already-encrypted
-- passwords.
SET password_encryption = 'md5';
---END---
---START---
-- encrypt with MD5
ALTER ROLE regress_passwd2 PASSWORD 'foo';
---END---
---START---
-- already encrypted, use as they are
ALTER ROLE regress_passwd1 PASSWORD 'md5cd3578025fe2c3d7ed1b9a9b26238b70';
---END---
---START---
ALTER ROLE regress_passwd3 PASSWORD 'SCRAM-SHA-256$4096:VLK4RMaQLCvNtQ==$6YtlR4t69SguDiwFvbVgVZtuz6gpJQQqUMZ7IQJK5yI=:ps75jrHeYU4lXCcXI4O8oIdJ3eO8o2jirjruw9phBTo=';
---END---
---START---
SET password_encryption = 'scram-sha-256';
---END---
---START---
-- create SCRAM secret
ALTER ROLE  regress_passwd4 PASSWORD 'foo';
---END---
---START---
-- already encrypted with MD5, use as it is
CREATE ROLE regress_passwd5 PASSWORD 'md5e73a4b11df52a6068f8b39f90be36023';
---END---
---START---
-- This looks like a valid SCRAM-SHA-256 secret, but it is not
-- so it should be hashed with SCRAM-SHA-256.
CREATE ROLE regress_passwd6 PASSWORD 'SCRAM-SHA-256$1234';
---END---
---START---
-- These may look like valid MD5 secrets, but they are not, so they
-- should be hashed with SCRAM-SHA-256.
-- trailing garbage at the end
CREATE ROLE regress_passwd7 PASSWORD 'md5012345678901234567890123456789zz';
---END---
---START---
-- invalid length
CREATE ROLE regress_passwd8 PASSWORD 'md501234567890123456789012345678901zz';
---END---
---START---
-- Changing the SCRAM iteration count
SET scram_iterations = 1024;
---END---
---START---
CREATE ROLE regress_passwd9 PASSWORD 'alterediterationcount';
---END---
---START---
SELECT rolname, regexp_replace(rolpassword, '(SCRAM-SHA-256)\$(\d+):([a-zA-Z0-9+/=]+)\$([a-zA-Z0-9+=/]+):([a-zA-Z0-9+/=]+)', '\1$\2:<salt>$<storedkey>:<serverkey>') as rolpassword_masked
    FROM pg_authid
    WHERE rolname LIKE 'regress_passwd%'
    ORDER BY rolname, rolpassword;
---END---
---START---
-- An empty password is not allowed, in any form
CREATE ROLE regress_passwd_empty PASSWORD '';
---END---
---START---
ALTER ROLE regress_passwd_empty PASSWORD 'md585939a5ce845f1a1b620742e3c659e0a';
---END---
---START---
ALTER ROLE regress_passwd_empty PASSWORD 'SCRAM-SHA-256$4096:hpFyHTUsSWcR7O9P$LgZFIt6Oqdo27ZFKbZ2nV+vtnYM995pDh9ca6WSi120=:qVV5NeluNfUPkwm7Vqat25RjSPLkGeoZBQs6wVv+um4=';
---END---
---START---
SELECT rolpassword FROM pg_authid WHERE rolname='regress_passwd_empty';
---END---
---START---
-- Test with invalid stored and server keys.
--
-- The first is valid, to act as a control. The others have too long
-- stored/server keys. They will be re-hashed.
CREATE ROLE regress_passwd_sha_len0 PASSWORD 'SCRAM-SHA-256$4096:A6xHKoH/494E941doaPOYg==$Ky+A30sewHIH3VHQLRN9vYsuzlgNyGNKCh37dy96Rqw=:COPdlNiIkrsacU5QoxydEuOH6e/KfiipeETb/bPw8ZI=';
---END---
---START---
CREATE ROLE regress_passwd_sha_len1 PASSWORD 'SCRAM-SHA-256$4096:A6xHKoH/494E941doaPOYg==$Ky+A30sewHIH3VHQLRN9vYsuzlgNyGNKCh37dy96RqwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=:COPdlNiIkrsacU5QoxydEuOH6e/KfiipeETb/bPw8ZI=';
---END---
---START---
CREATE ROLE regress_passwd_sha_len2 PASSWORD 'SCRAM-SHA-256$4096:A6xHKoH/494E941doaPOYg==$Ky+A30sewHIH3VHQLRN9vYsuzlgNyGNKCh37dy96Rqw=:COPdlNiIkrsacU5QoxydEuOH6e/KfiipeETb/bPw8ZIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
---END---
---START---
-- Check that the invalid secrets were re-hashed. A re-hashed secret
-- should not contain the original salt.
SELECT rolname, rolpassword not like '%A6xHKoH/494E941doaPOYg==%' as is_rolpassword_rehashed
    FROM pg_authid
    WHERE rolname LIKE 'regress_passwd_sha_len%'
    ORDER BY rolname;
---END---
---START---
DROP ROLE regress_passwd1;
---END---
---START---
DROP ROLE regress_passwd2;
---END---
---START---
DROP ROLE regress_passwd3;
---END---
---START---
DROP ROLE regress_passwd4;
---END---
---START---
DROP ROLE regress_passwd5;
---END---
---START---
DROP ROLE regress_passwd6;
---END---
---START---
DROP ROLE regress_passwd7;
---END---
---START---
DROP ROLE regress_passwd8;
---END---
---START---
DROP ROLE regress_passwd9;
---END---
---START---
DROP ROLE regress_passwd_empty;
---END---
---START---
DROP ROLE regress_passwd_sha_len0;
---END---
---START---
DROP ROLE regress_passwd_sha_len1;
---END---
---START---
DROP ROLE regress_passwd_sha_len2;
---END---
---START---
-- all entries should have been removed
SELECT rolname, rolpassword
    FROM pg_authid
    WHERE rolname LIKE 'regress_passwd%'
    ORDER BY rolname, rolpassword;
---END---
