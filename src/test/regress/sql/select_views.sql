---START---
--
-- SELECT_VIEWS
-- test the views defined in CREATE_VIEWS
--

SELECT * FROM street;
---END---
---START---
SELECT name, #thepath FROM iexit ORDER BY name COLLATE "C", 2;
---END---
---START---
SELECT * FROM toyemp WHERE name = 'sharon';
---END---
---START---
--
-- Test for Leaky view scenario
--
CREATE ROLE regress_alice;
---END---
---START---
CREATE FUNCTION f_leak (text)
       RETURNS bool LANGUAGE 'plpgsql' COST 0.0000001
       AS 'BEGIN RAISE NOTICE ''f_leak => %'', $1; RETURN true; END';
---END---
---START---
CREATE TABLE customer (
       cid      int primary key,
       name     text not null,
       tel      text,
       passwd	text
);
---END---
---START---
CREATE TABLE credit_card (gemini_pk serial PRIMARY KEY, cid integer REFERENCES customer (cid), cnum text, climit integer);
---END---
---START---
CREATE TABLE credit_usage (gemini_pk serial PRIMARY KEY, cid integer REFERENCES customer (cid), ymd date, usage integer);
---END---
---START---
INSERT INTO customer
       VALUES (101, 'regress_alice', '+81-12-3456-7890', 'passwd123'),
              (102, 'regress_bob',   '+01-234-567-8901', 'beafsteak'),
              (103, 'regress_eve',   '+49-8765-43210',   'hamburger');
---END---
---START---
INSERT INTO credit_card
       VALUES (101, '1111-2222-3333-4444', 4000),
              (102, '5555-6666-7777-8888', 3000),
              (103, '9801-2345-6789-0123', 2000);
---END---
---START---
INSERT INTO credit_usage
       VALUES (101, '2011-09-15', 120),
	      (101, '2011-10-05',  90),
	      (101, '2011-10-18', 110),
	      (101, '2011-10-21', 200),
	      (101, '2011-11-10',  80),
	      (102, '2011-09-22', 300),
	      (102, '2011-10-12', 120),
	      (102, '2011-10-28', 200),
	      (103, '2011-10-15', 480);
---END---
---START---
CREATE VIEW my_property_normal AS
       SELECT * FROM customer WHERE name = current_user;
---END---
---START---
CREATE VIEW my_property_secure WITH (security_barrier) AS
       SELECT * FROM customer WHERE name = current_user;
---END---
---START---
CREATE VIEW my_credit_card_normal AS
       SELECT * FROM customer l NATURAL JOIN credit_card r
       WHERE l.name = current_user;
---END---
---START---
CREATE VIEW my_credit_card_secure WITH (security_barrier) AS
       SELECT * FROM customer l NATURAL JOIN credit_card r
       WHERE l.name = current_user;
---END---
---START---
CREATE VIEW my_credit_card_usage_normal AS
       SELECT * FROM my_credit_card_secure l NATURAL JOIN credit_usage r;
---END---
---START---
CREATE VIEW my_credit_card_usage_secure WITH (security_barrier) AS
       SELECT * FROM my_credit_card_secure l NATURAL JOIN credit_usage r;
---END---
---START---
GRANT SELECT ON my_property_normal TO public;
---END---
---START---
GRANT SELECT ON my_property_secure TO public;
---END---
---START---
GRANT SELECT ON my_credit_card_normal TO public;
---END---
---START---
GRANT SELECT ON my_credit_card_secure TO public;
---END---
---START---
GRANT SELECT ON my_credit_card_usage_normal TO public;
---END---
---START---
GRANT SELECT ON my_credit_card_usage_secure TO public;
---END---
---START---
--
-- Run leaky view scenarios
--
SET SESSION AUTHORIZATION regress_alice;
---END---
---START---
--
-- scenario: if a qualifier with tiny-cost is given, it shall be launched
--           prior to the security policy of the view.
--
SELECT * FROM my_property_normal WHERE f_leak(passwd);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_property_normal WHERE f_leak(passwd);
---END---
---START---
SELECT * FROM my_property_secure WHERE f_leak(passwd);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_property_secure WHERE f_leak(passwd);
---END---
---START---
--
-- scenario: qualifiers can be pushed down if they contain leaky functions,
--           provided they aren't passed data from inside the view.
--
SELECT * FROM my_property_normal v
		WHERE f_leak('passwd') AND f_leak(passwd);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_property_normal v
		WHERE f_leak('passwd') AND f_leak(passwd);
---END---
---START---
SELECT * FROM my_property_secure v
		WHERE f_leak('passwd') AND f_leak(passwd);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_property_secure v
		WHERE f_leak('passwd') AND f_leak(passwd);
---END---
---START---
--
-- scenario: if a qualifier references only one-side of a particular join-
--           tree, it shall be distributed to the most deep scan plan as
--           possible as we can.
--
SELECT * FROM my_credit_card_normal WHERE f_leak(cnum);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_credit_card_normal WHERE f_leak(cnum);
---END---
---START---
SELECT * FROM my_credit_card_secure WHERE f_leak(cnum);
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_credit_card_secure WHERE f_leak(cnum);
---END---
---START---
--
-- scenario: an external qualifier can be pushed-down by in-front-of the
--           views with "security_barrier" attribute, except for operators
--           implemented with leakproof functions.
--
SELECT * FROM my_credit_card_usage_normal
       WHERE f_leak(cnum) AND ymd >= '2011-10-01' AND ymd < '2011-11-01';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_credit_card_usage_normal
       WHERE f_leak(cnum) AND ymd >= '2011-10-01' AND ymd < '2011-11-01';
---END---
---START---
SELECT * FROM my_credit_card_usage_secure
       WHERE f_leak(cnum) AND ymd >= '2011-10-01' AND ymd < '2011-11-01';
---END---
---START---
EXPLAIN (COSTS OFF) SELECT * FROM my_credit_card_usage_secure
       WHERE f_leak(cnum) AND ymd >= '2011-10-01' AND ymd < '2011-11-01';
---END---
---START---
--
-- Test for the case when security_barrier gets changed between rewriter
-- and planner stage.
--
PREPARE p1 AS SELECT * FROM my_property_normal WHERE f_leak(passwd);
---END---
---START---
PREPARE p2 AS SELECT * FROM my_property_secure WHERE f_leak(passwd);
---END---
---START---
EXECUTE p1;
---END---
---START---
EXECUTE p2;
---END---
---START---
RESET SESSION AUTHORIZATION;
---END---
---START---
ALTER VIEW my_property_normal SET (security_barrier=true);
---END---
---START---
ALTER VIEW my_property_secure SET (security_barrier=false);
---END---
---START---
SET SESSION AUTHORIZATION regress_alice;
---END---
---START---
EXECUTE p1;
---END---
---START---
-- To be perform as a view with security-barrier
EXECUTE p2;
---END---
---START---
-- To be perform as a view without security-barrier

-- Cleanup.
RESET SESSION AUTHORIZATION;
---END---
---START---
DROP ROLE regress_alice;
---END---
