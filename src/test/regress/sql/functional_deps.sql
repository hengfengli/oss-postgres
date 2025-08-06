---START---
-- from http://www.depesz.com/index.php/2010/04/19/getting-unique-elements/

CREATE TABLE articles (
    id int CONSTRAINT articles_pkey PRIMARY KEY,
    keywords text,
    title text UNIQUE NOT NULL,
    body text UNIQUE,
    created date
);
---END---
---START---

CREATE TABLE articles_in_category (
    article_id int,
    category_id int,
    changed date,
    PRIMARY KEY (article_id, category_id)
);
---END---
---START---

-- test functional dependencies based on primary keys/unique constraints

-- base tables

-- group by primary key (OK)
SELECT id, keywords, title, body, created
FROM articles
GROUP BY id;
---END---
---START---

-- group by unique not null (fail/todo)
SELECT id, keywords, title, body, created
FROM articles
GROUP BY title;
---END---
---START---

-- group by unique nullable (fail)
SELECT id, keywords, title, body, created
FROM articles
GROUP BY body;
---END---
---START---

-- group by something else (fail)
SELECT id, keywords, title, body, created
FROM articles
GROUP BY keywords;
---END---
---START---

-- multiple tables

-- group by primary key (OK)
SELECT a.id, a.keywords, a.title, a.body, a.created
FROM articles AS a, articles_in_category AS aic
WHERE a.id = aic.article_id AND aic.category_id in (14,62,70,53,138)
GROUP BY a.id;
---END---
---START---

-- group by something else (fail)
SELECT a.id, a.keywords, a.title, a.body, a.created
FROM articles AS a, articles_in_category AS aic
WHERE a.id = aic.article_id AND aic.category_id in (14,62,70,53,138)
GROUP BY aic.article_id, aic.category_id;
---END---
---START---

-- JOIN syntax

-- group by left table's primary key (OK)
SELECT a.id, a.keywords, a.title, a.body, a.created
FROM articles AS a JOIN articles_in_category AS aic ON a.id = aic.article_id
WHERE aic.category_id in (14,62,70,53,138)
GROUP BY a.id;
---END---
---START---

-- group by something else (fail)
SELECT a.id, a.keywords, a.title, a.body, a.created
FROM articles AS a JOIN articles_in_category AS aic ON a.id = aic.article_id
WHERE aic.category_id in (14,62,70,53,138)
GROUP BY aic.article_id, aic.category_id;
---END---
---START---

-- group by right table's (composite) primary key (OK)
SELECT aic.changed
FROM articles AS a JOIN articles_in_category AS aic ON a.id = aic.article_id
WHERE aic.category_id in (14,62,70,53,138)
GROUP BY aic.category_id, aic.article_id;
---END---
---START---

-- group by right table's partial primary key (fail)
SELECT aic.changed
FROM articles AS a JOIN articles_in_category AS aic ON a.id = aic.article_id
WHERE aic.category_id in (14,62,70,53,138)
GROUP BY aic.article_id;
---END---
---START---


-- example from documentation

CREATE TABLE products (product_id int, name text, price numeric);
---END---
---START---
CREATE TABLE sales (product_id int, units int);
---END---
---START---

-- OK
SELECT product_id, p.name, (sum(s.units) * p.price) AS sales
    FROM products p LEFT JOIN sales s USING (product_id)
    GROUP BY product_id, p.name, p.price;
---END---
---START---

-- fail
SELECT product_id, p.name, (sum(s.units) * p.price) AS sales
    FROM products p LEFT JOIN sales s USING (product_id)
    GROUP BY product_id;
---END---
---START---

ALTER TABLE products ADD PRIMARY KEY (product_id);
---END---
---START---

-- OK now
SELECT product_id, p.name, (sum(s.units) * p.price) AS sales
    FROM products p LEFT JOIN sales s USING (product_id)
    GROUP BY product_id;
---END---
---START---


-- Drupal example, http://drupal.org/node/555530

CREATE TABLE node (
    nid SERIAL,
    vid integer NOT NULL default '0',
    type varchar(32) NOT NULL default '',
    title varchar(128) NOT NULL default '',
    uid integer NOT NULL default '0',
    status integer NOT NULL default '1',
    created integer NOT NULL default '0',
    -- snip
    PRIMARY KEY (nid, vid)
);
---END---
---START---

CREATE TABLE users (
    uid integer NOT NULL default '0',
    name varchar(60) NOT NULL default '',
    pass varchar(32) NOT NULL default '',
    -- snip
    PRIMARY KEY (uid),
    UNIQUE (name)
);
---END---
---START---

-- OK
SELECT u.uid, u.name FROM node n
INNER JOIN users u ON u.uid = n.uid
WHERE n.type = 'blog' AND n.status = 1
GROUP BY u.uid, u.name;
---END---
---START---

-- OK
SELECT u.uid, u.name FROM node n
INNER JOIN users u ON u.uid = n.uid
WHERE n.type = 'blog' AND n.status = 1
GROUP BY u.uid;
---END---
---START---


-- Check views and dependencies

-- fail
CREATE TEMP VIEW fdv1 AS
SELECT id, keywords, title, body, created
FROM articles
GROUP BY body;
---END---
---START---

-- OK
CREATE TEMP VIEW fdv1 AS
SELECT id, keywords, title, body, created
FROM articles
GROUP BY id;
---END---
---START---

-- fail
ALTER TABLE articles DROP CONSTRAINT articles_pkey RESTRICT;
---END---
---START---

DROP VIEW fdv1;
---END---
---START---


-- multiple dependencies
CREATE TEMP VIEW fdv2 AS
SELECT a.id, a.keywords, a.title, aic.category_id, aic.changed
FROM articles AS a JOIN articles_in_category AS aic ON a.id = aic.article_id
WHERE aic.category_id in (14,62,70,53,138)
GROUP BY a.id, aic.category_id, aic.article_id;
---END---
---START---

ALTER TABLE articles DROP CONSTRAINT articles_pkey RESTRICT; -- fail
ALTER TABLE articles_in_category DROP CONSTRAINT articles_in_category_pkey RESTRICT; --fail

DROP VIEW fdv2;
---END---
---START---


-- nested queries

CREATE TEMP VIEW fdv3 AS
SELECT id, keywords, title, body, created
FROM articles
GROUP BY id
UNION
SELECT id, keywords, title, body, created
FROM articles
GROUP BY id;
---END---
---START---

ALTER TABLE articles DROP CONSTRAINT articles_pkey RESTRICT; -- fail

DROP VIEW fdv3;
---END---
---START---


CREATE TEMP VIEW fdv4 AS
SELECT * FROM articles WHERE title IN (SELECT title FROM articles GROUP BY id);
---END---
---START---

ALTER TABLE articles DROP CONSTRAINT articles_pkey RESTRICT; -- fail

DROP VIEW fdv4;
---END---
---START---


-- prepared query plans: this results in failure on reuse

PREPARE foo AS
  SELECT id, keywords, title, body, created
  FROM articles
  GROUP BY id;
---END---
---START---

EXECUTE foo;
---END---
---START---

ALTER TABLE articles DROP CONSTRAINT articles_pkey RESTRICT;
---END---
---START---
drop table if exists articles;
drop table if exists articles_in_category;
drop table if exists products;
drop table if exists sales;
drop table if exists node;
drop table if exists users;
---END---
