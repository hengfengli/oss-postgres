---START---
--
-- Test for facilities of security label
--

-- initial setups
SET client_min_messages TO 'warning';
---END---
---START---

DROP ROLE IF EXISTS regress_seclabel_user1;
---END---
---START---
DROP ROLE IF EXISTS regress_seclabel_user2;
---END---
---START---

RESET client_min_messages;
---END---
---START---

CREATE USER regress_seclabel_user1 WITH CREATEROLE;
---END---
---START---
CREATE USER regress_seclabel_user2;
---END---
---START---

CREATE TABLE seclabel_tbl1 (a int, b text);
---END---
---START---
CREATE TABLE seclabel_tbl2 (x int, y text);
---END---
---START---
CREATE VIEW seclabel_view1 AS SELECT * FROM seclabel_tbl2;
---END---
---START---
CREATE FUNCTION seclabel_four() RETURNS integer AS $$SELECT 4$$ language sql;
---END---
---START---
CREATE DOMAIN seclabel_domain AS text;
---END---
---START---

ALTER TABLE seclabel_tbl1 OWNER TO regress_seclabel_user1;
---END---
---START---
ALTER TABLE seclabel_tbl2 OWNER TO regress_seclabel_user2;
---END---
---START---

--
-- Test of SECURITY LABEL statement without a plugin
--
SECURITY LABEL ON TABLE seclabel_tbl1 IS 'classified';			-- fail
SECURITY LABEL FOR 'dummy' ON TABLE seclabel_tbl1 IS 'classified';		-- fail
SECURITY LABEL ON TABLE seclabel_tbl1 IS '...invalid label...';		-- fail
SECURITY LABEL ON TABLE seclabel_tbl3 IS 'unclassified';			-- fail

SECURITY LABEL ON ROLE regress_seclabel_user1 IS 'classified';			-- fail
SECURITY LABEL FOR 'dummy' ON ROLE regress_seclabel_user1 IS 'classified';		-- fail
SECURITY LABEL ON ROLE regress_seclabel_user1 IS '...invalid label...';		-- fail
SECURITY LABEL ON ROLE regress_seclabel_user3 IS 'unclassified';			-- fail

-- clean up objects
DROP FUNCTION seclabel_four();
---END---
---START---
DROP DOMAIN seclabel_domain;
---END---
---START---
DROP VIEW seclabel_view1;
---END---
---START---
DROP TABLE seclabel_tbl1;
---END---
---START---
DROP TABLE seclabel_tbl2;
---END---
---START---
DROP USER regress_seclabel_user1;
---END---
---START---
DROP USER regress_seclabel_user2;
---END---
