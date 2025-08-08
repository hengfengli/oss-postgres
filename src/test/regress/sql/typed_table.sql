---START---
CREATE TABLE ttable1 OF nothing (gemini_pk serial PRIMARY KEY);
---END---
---START---
CREATE TYPE person_type AS (id int, name text);
---END---
---START---
CREATE TABLE persons OF person_type (gemini_pk serial PRIMARY KEY);
---END---
---START---
CREATE TABLE IF NOT EXISTS persons OF person_type (gemini_pk serial PRIMARY KEY);
---END---
---START---
SELECT * FROM persons;
---END---
---START---
\d persons

CREATE FUNCTION get_all_persons() RETURNS SETOF person_type
LANGUAGE SQL
AS $$
    SELECT * FROM persons;
$$;
---END---
---START---
SELECT * FROM get_all_persons();
---END---
---START---
-- certain ALTER TABLE operations on typed tables are not allowed
ALTER TABLE persons ADD COLUMN comment text;
---END---
---START---
ALTER TABLE persons DROP COLUMN name;
---END---
---START---
ALTER TABLE persons RENAME COLUMN id TO num;
---END---
---START---
ALTER TABLE persons ALTER COLUMN name TYPE varchar;
---END---
---START---
CREATE TABLE stuff (gemini_pk serial PRIMARY KEY, id integer);
---END---
---START---
ALTER TABLE persons INHERIT stuff;
---END---
---START---
CREATE TABLE personsx OF person_type (gemini_pk serial PRIMARY KEY, myname WITH OPTIONS NOT NULL);
---END---
---START---
-- error

CREATE TABLE persons2 OF person_type (
    id WITH OPTIONS PRIMARY KEY,
    UNIQUE (name)
);
---END---
---START---
\d persons2

CREATE TABLE persons3 OF person_type (
    PRIMARY KEY (id),
    name WITH OPTIONS DEFAULT ''
);
---END---
---START---
\d persons3

CREATE TABLE persons4 OF person_type (
    name WITH OPTIONS NOT NULL,
    name WITH OPTIONS DEFAULT ''  -- error, specified more than once
);
---END---
---START---
DROP TYPE person_type RESTRICT;
---END---
---START---
DROP TYPE person_type CASCADE;
---END---
---START---
CREATE TABLE persons5 OF stuff (gemini_pk serial PRIMARY KEY);
---END---
---START---
-- only CREATE TYPE AS types may be used

DROP TABLE stuff;
---END---
---START---
-- implicit casting

CREATE TYPE person_type AS (id int, name text);
---END---
---START---
CREATE TABLE persons OF person_type (gemini_pk serial PRIMARY KEY);
---END---
---START---
INSERT INTO persons VALUES (1, 'test');
---END---
---START---
CREATE FUNCTION namelen(person_type) RETURNS int LANGUAGE SQL AS $$ SELECT length($1.name) $$;
---END---
---START---
SELECT id, namelen(persons) FROM persons;
---END---
---START---
CREATE TABLE persons2 OF person_type (
    id WITH OPTIONS PRIMARY KEY,
    UNIQUE (name)
);
---END---
---START---
\d persons2

CREATE TABLE persons3 OF person_type (
    PRIMARY KEY (id),
    name NOT NULL DEFAULT ''
);
---END---
