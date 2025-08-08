---START---
CREATE SCHEMA testxmlschema;
---END---
---START---
CREATE TABLE testxmlschema.test1 (gemini_pk serial PRIMARY KEY, a integer, b text);
---END---
---START---
INSERT INTO testxmlschema.test1 VALUES (1, 'one'), (2, 'two'), (-1, null);
---END---
---START---
CREATE DOMAIN testxmldomain AS varchar;
---END---
---START---
CREATE TABLE testxmlschema.test2 (gemini_pk serial PRIMARY KEY, z integer, y varchar(500), x char(6), w numeric(9, 2), v smallint, u bigint, t real, s time, stz timetz, r timestamp, rtz timestamptz, q date, p xml, o testxmldomain, n bool, m bytea, aaa text);
---END---
---START---
ALTER TABLE testxmlschema.test2 DROP COLUMN aaa;
---END---
---START---
INSERT INTO testxmlschema.test2 VALUES (55, 'abc', 'def',
    98.6, 2, 999, 0,
    '21:07', '21:11 +05', '2009-06-08 21:07:30', '2009-06-08 21:07:30 -07', '2009-06-08',
    NULL, 'ABC', true, 'XYZ');
---END---
---START---
SELECT table_to_xml('testxmlschema.test1', false, false, '');
---END---
---START---
SELECT table_to_xml('testxmlschema.test1', true, false, 'foo');
---END---
---START---
SELECT table_to_xml('testxmlschema.test1', false, true, '');
---END---
---START---
SELECT table_to_xml('testxmlschema.test1', true, true, '');
---END---
---START---
SELECT table_to_xml('testxmlschema.test2', false, false, '');
---END---
---START---
SELECT table_to_xmlschema('testxmlschema.test1', false, false, '');
---END---
---START---
SELECT table_to_xmlschema('testxmlschema.test1', true, false, '');
---END---
---START---
SELECT table_to_xmlschema('testxmlschema.test1', false, true, 'foo');
---END---
---START---
SELECT table_to_xmlschema('testxmlschema.test1', true, true, '');
---END---
---START---
SELECT table_to_xmlschema('testxmlschema.test2', false, false, '');
---END---
---START---
SELECT table_to_xml_and_xmlschema('testxmlschema.test1', false, false, '');
---END---
---START---
SELECT table_to_xml_and_xmlschema('testxmlschema.test1', true, false, '');
---END---
---START---
SELECT table_to_xml_and_xmlschema('testxmlschema.test1', false, true, '');
---END---
---START---
SELECT table_to_xml_and_xmlschema('testxmlschema.test1', true, true, 'foo');
---END---
---START---
SELECT query_to_xml('SELECT * FROM testxmlschema.test1', false, false, '');
---END---
---START---
SELECT query_to_xmlschema('SELECT * FROM testxmlschema.test1', false, false, '');
---END---
---START---
SELECT query_to_xml_and_xmlschema('SELECT * FROM testxmlschema.test1', true, true, '');
---END---
---START---
DECLARE xc CURSOR WITH HOLD FOR SELECT * FROM testxmlschema.test1 ORDER BY 1, 2;
---END---
---START---
SELECT cursor_to_xml('xc'::refcursor, 5, false, true, '');
---END---
---START---
SELECT cursor_to_xmlschema('xc'::refcursor, false, true, '');
---END---
---START---
MOVE BACKWARD ALL IN xc;
---END---
---START---
SELECT cursor_to_xml('xc'::refcursor, 5, true, false, '');
---END---
---START---
SELECT cursor_to_xmlschema('xc'::refcursor, true, false, '');
---END---
---START---
SELECT schema_to_xml('testxmlschema', false, true, '');
---END---
---START---
SELECT schema_to_xml('testxmlschema', true, false, '');
---END---
---START---
SELECT schema_to_xmlschema('testxmlschema', false, true, '');
---END---
---START---
SELECT schema_to_xmlschema('testxmlschema', true, false, '');
---END---
---START---
SELECT schema_to_xml_and_xmlschema('testxmlschema', true, true, 'foo');
---END---
---START---
-- test that domains are transformed like their base types

CREATE DOMAIN testboolxmldomain AS bool;
---END---
---START---
CREATE DOMAIN testdatexmldomain AS date;
---END---
---START---
CREATE TABLE testxmlschema.test3
    AS SELECT true c1,
              true::testboolxmldomain c2,
              '2013-02-21'::date c3,
              '2013-02-21'::testdatexmldomain c4;
---END---
---START---
SELECT xmlforest(c1, c2, c3, c4) FROM testxmlschema.test3;
---END---
---START---
SELECT table_to_xml('testxmlschema.test3', true, true, '');
---END---
