---START---
CREATE TABLE xmltest (
    id int,
    data xml
);
---END---
---START---

INSERT INTO xmltest VALUES (1, '<value>one</value>');
---END---
---START---
INSERT INTO xmltest VALUES (2, '<value>two</value>');
---END---
---START---
INSERT INTO xmltest VALUES (3, '<wrong');
---END---
---START---

SELECT * FROM xmltest;
---END---
---START---

-- test non-throwing API, too
SELECT pg_input_is_valid('<value>one</value>', 'xml');
---END---
---START---
SELECT pg_input_is_valid('<value>one</', 'xml');
---END---
---START---
SELECT message FROM pg_input_error_info('<value>one</', 'xml');
---END---
---START---
SELECT pg_input_is_valid('<?xml version="1.0" standalone="y"?><foo/>', 'xml');
---END---
---START---
SELECT message FROM pg_input_error_info('<?xml version="1.0" standalone="y"?><foo/>', 'xml');
---END---
---START---


SELECT xmlcomment('test');
---END---
---START---
SELECT xmlcomment('-test');
---END---
---START---
SELECT xmlcomment('test-');
---END---
---START---
SELECT xmlcomment('--test');
---END---
---START---
SELECT xmlcomment('te st');
---END---
---START---


SELECT xmlconcat(xmlcomment('hello'),
                 xmlelement(NAME qux, 'foo'),
                 xmlcomment('world'));
---END---
---START---

SELECT xmlconcat('hello', 'you');
---END---
---START---
SELECT xmlconcat(1, 2);
---END---
---START---
SELECT xmlconcat('bad', '<syntax');
---END---
---START---
SELECT xmlconcat('<foo/>', NULL, '<?xml version="1.1" standalone="no"?><bar/>');
---END---
---START---
SELECT xmlconcat('<?xml version="1.1"?><foo/>', NULL, '<?xml version="1.1" standalone="no"?><bar/>');
---END---
---START---
SELECT xmlconcat(NULL);
---END---
---START---
SELECT xmlconcat(NULL, NULL);
---END---
---START---


SELECT xmlelement(name element,
                  xmlattributes (1 as one, 'deuce' as two),
                  'content');
---END---
---START---

SELECT xmlelement(name element,
                  xmlattributes ('unnamed and wrong'));
---END---
---START---

SELECT xmlelement(name element, xmlelement(name nested, 'stuff'));
---END---
---START---

SELECT xmlelement(name employee, xmlforest(name, age, salary as pay)) FROM emp;
---END---
---START---

SELECT xmlelement(name duplicate, xmlattributes(1 as a, 2 as b, 3 as a));
---END---
---START---

SELECT xmlelement(name num, 37);
---END---
---START---
SELECT xmlelement(name foo, text 'bar');
---END---
---START---
SELECT xmlelement(name foo, xml 'bar');
---END---
---START---
SELECT xmlelement(name foo, text 'b<a/>r');
---END---
---START---
SELECT xmlelement(name foo, xml 'b<a/>r');
---END---
---START---
SELECT xmlelement(name foo, array[1, 2, 3]);
---END---
---START---
SET xmlbinary TO base64;
---END---
---START---
SELECT xmlelement(name foo, bytea 'bar');
---END---
---START---
SET xmlbinary TO hex;
---END---
---START---
SELECT xmlelement(name foo, bytea 'bar');
---END---
---START---

SELECT xmlelement(name foo, xmlattributes(true as bar));
---END---
---START---
SELECT xmlelement(name foo, xmlattributes('2009-04-09 00:24:37'::timestamp as bar));
---END---
---START---
SELECT xmlelement(name foo, xmlattributes('infinity'::timestamp as bar));
---END---
---START---
SELECT xmlelement(name foo, xmlattributes('<>&"''' as funny, xml 'b<a/>r' as funnier));
---END---
---START---


SELECT xmlparse(content '');
---END---
---START---
SELECT xmlparse(content '  ');
---END---
---START---
SELECT xmlparse(content 'abc');
---END---
---START---
SELECT xmlparse(content '<abc>x</abc>');
---END---
---START---
SELECT xmlparse(content '<invalidentity>&</invalidentity>');
---END---
---START---
SELECT xmlparse(content '<undefinedentity>&idontexist;</undefinedentity>');
---END---
---START---
SELECT xmlparse(content '<invalidns xmlns=''&lt;''/>');
---END---
---START---
SELECT xmlparse(content '<relativens xmlns=''relative''/>');
---END---
---START---
SELECT xmlparse(content '<twoerrors>&idontexist;</unbalanced>');
---END---
---START---
SELECT xmlparse(content '<nosuchprefix:tag/>');
---END---
---START---

SELECT xmlparse(document '   ');
---END---
---START---
SELECT xmlparse(document 'abc');
---END---
---START---
SELECT xmlparse(document '<abc>x</abc>');
---END---
---START---
SELECT xmlparse(document '<invalidentity>&</abc>');
---END---
---START---
SELECT xmlparse(document '<undefinedentity>&idontexist;</abc>');
---END---
---START---
SELECT xmlparse(document '<invalidns xmlns=''&lt;''/>');
---END---
---START---
SELECT xmlparse(document '<relativens xmlns=''relative''/>');
---END---
---START---
SELECT xmlparse(document '<twoerrors>&idontexist;</unbalanced>');
---END---
---START---
SELECT xmlparse(document '<nosuchprefix:tag/>');
---END---
---START---


SELECT xmlpi(name foo);
---END---
---START---
SELECT xmlpi(name xml);
---END---
---START---
SELECT xmlpi(name xmlstuff);
---END---
---START---
SELECT xmlpi(name foo, 'bar');
---END---
---START---
SELECT xmlpi(name foo, 'in?>valid');
---END---
---START---
SELECT xmlpi(name foo, null);
---END---
---START---
SELECT xmlpi(name xml, null);
---END---
---START---
SELECT xmlpi(name xmlstuff, null);
---END---
---START---
SELECT xmlpi(name "xml-stylesheet", 'href="mystyle.css" type="text/css"');
---END---
---START---
SELECT xmlpi(name foo, '   bar');
---END---
---START---


SELECT xmlroot(xml '<foo/>', version no value, standalone no value);
---END---
---START---
SELECT xmlroot(xml '<foo/>', version '2.0');
---END---
---START---
SELECT xmlroot(xml '<foo/>', version no value, standalone yes);
---END---
---START---
SELECT xmlroot(xml '<?xml version="1.1"?><foo/>', version no value, standalone yes);
---END---
---START---
SELECT xmlroot(xmlroot(xml '<foo/>', version '1.0'), version '1.1', standalone no);
---END---
---START---
SELECT xmlroot('<?xml version="1.1" standalone="yes"?><foo/>', version no value, standalone no);
---END---
---START---
SELECT xmlroot('<?xml version="1.1" standalone="yes"?><foo/>', version no value, standalone no value);
---END---
---START---
SELECT xmlroot('<?xml version="1.1" standalone="yes"?><foo/>', version no value);
---END---
---START---


SELECT xmlroot (
  xmlelement (
    name gazonk,
    xmlattributes (
      'val' AS name,
      1 + 1 AS num
    ),
    xmlelement (
      NAME qux,
      'foo'
    )
  ),
  version '1.0',
  standalone yes
);
---END---
---START---


SELECT xmlserialize(content data as character varying(20)) FROM xmltest;
---END---
---START---
SELECT xmlserialize(content 'good' as char(10));
---END---
---START---
SELECT xmlserialize(document 'bad' as text);
---END---
---START---

-- indent
SELECT xmlserialize(DOCUMENT '<foo><bar><val x="y">42</val></bar></foo>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<foo><bar><val x="y">42</val></bar></foo>' AS text INDENT);
---END---
---START---
-- no indent
SELECT xmlserialize(DOCUMENT '<foo><bar><val x="y">42</val></bar></foo>' AS text NO INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<foo><bar><val x="y">42</val></bar></foo>' AS text NO INDENT);
---END---
---START---
-- indent non singly-rooted xml
SELECT xmlserialize(DOCUMENT '<foo>73</foo><bar><val x="y">42</val></bar>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<foo>73</foo><bar><val x="y">42</val></bar>' AS text INDENT);
---END---
---START---
-- indent non singly-rooted xml with mixed contents
SELECT xmlserialize(DOCUMENT 'text node<foo>73</foo>text node<bar><val x="y">42</val></bar>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  'text node<foo>73</foo>text node<bar><val x="y">42</val></bar>' AS text INDENT);
---END---
---START---
-- indent singly-rooted xml with mixed contents
SELECT xmlserialize(DOCUMENT '<foo><bar><val x="y">42</val><val x="y">text node<val>73</val></val></bar></foo>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<foo><bar><val x="y">42</val><val x="y">text node<val>73</val></val></bar></foo>' AS text INDENT);
---END---
---START---
-- indent empty string
SELECT xmlserialize(DOCUMENT '' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '' AS text INDENT);
---END---
---START---
-- whitespaces
SELECT xmlserialize(DOCUMENT '  ' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '  ' AS text INDENT);
---END---
---START---
-- indent null
SELECT xmlserialize(DOCUMENT NULL AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  NULL AS text INDENT);
---END---
---START---
-- indent with XML declaration
SELECT xmlserialize(DOCUMENT '<?xml version="1.0" encoding="UTF-8"?><foo><bar><val>73</val></bar></foo>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<?xml version="1.0" encoding="UTF-8"?><foo><bar><val>73</val></bar></foo>' AS text INDENT);
---END---
---START---
-- indent containing DOCTYPE declaration
SELECT xmlserialize(DOCUMENT '<!DOCTYPE a><a/>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<!DOCTYPE a><a/>' AS text INDENT);
---END---
---START---
-- indent xml with empty element
SELECT xmlserialize(DOCUMENT '<foo><bar></bar></foo>' AS text INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<foo><bar></bar></foo>' AS text INDENT);
---END---
---START---
-- 'no indent' = not using 'no indent'
SELECT xmlserialize(DOCUMENT '<foo><bar><val x="y">42</val></bar></foo>' AS text) = xmlserialize(DOCUMENT '<foo><bar><val x="y">42</val></bar></foo>' AS text NO INDENT);
---END---
---START---
SELECT xmlserialize(CONTENT  '<foo><bar><val x="y">42</val></bar></foo>' AS text) = xmlserialize(CONTENT '<foo><bar><val x="y">42</val></bar></foo>' AS text NO INDENT);
---END---
---START---

SELECT xml '<foo>bar</foo>' IS DOCUMENT;
---END---
---START---
SELECT xml '<foo>bar</foo><bar>foo</bar>' IS DOCUMENT;
---END---
---START---
SELECT xml '<abc/>' IS NOT DOCUMENT;
---END---
---START---
SELECT xml 'abc' IS NOT DOCUMENT;
---END---
---START---
SELECT '<>' IS NOT DOCUMENT;
---END---
---START---


SELECT xmlagg(data) FROM xmltest;
---END---
---START---
SELECT xmlagg(data) FROM xmltest WHERE id > 10;
---END---
---START---
SELECT xmlelement(name employees, xmlagg(xmlelement(name name, name))) FROM emp;
---END---
---START---


-- Check mapping SQL identifier to XML name

SELECT xmlpi(name ":::_xml_abc135.%-&_");
---END---
---START---
SELECT xmlpi(name "123");
---END---
---START---


PREPARE foo (xml) AS SELECT xmlconcat('<foo/>', $1);
---END---
---START---

SET XML OPTION DOCUMENT;
---END---
---START---
EXECUTE foo ('<bar/>');
---END---
---START---
EXECUTE foo ('bad');
---END---
---START---
SELECT xml '<!DOCTYPE a><a/><b/>';
---END---
---START---

SET XML OPTION CONTENT;
---END---
---START---
EXECUTE foo ('<bar/>');
---END---
---START---
EXECUTE foo ('good');
---END---
---START---
SELECT xml '<!-- in SQL:2006+ a doc is content too--> <?y z?> <!DOCTYPE a><a/>';
---END---
---START---
SELECT xml '<?xml version="1.0"?> <!-- hi--> <!DOCTYPE a><a/>';
---END---
---START---
SELECT xml '<!DOCTYPE a><a/>';
---END---
---START---
SELECT xml '<!-- hi--> oops <!DOCTYPE a><a/>';
---END---
---START---
SELECT xml '<!-- hi--> <oops/> <!DOCTYPE a><a/>';
---END---
---START---
SELECT xml '<!DOCTYPE a><a/><b/>';
---END---
---START---


-- Test backwards parsing

CREATE VIEW xmlview1 AS SELECT xmlcomment('test');
---END---
---START---
CREATE VIEW xmlview2 AS SELECT xmlconcat('hello', 'you');
---END---
---START---
CREATE VIEW xmlview3 AS SELECT xmlelement(name element, xmlattributes (1 as ":one:", 'deuce' as two), 'content&');
---END---
---START---
CREATE VIEW xmlview4 AS SELECT xmlelement(name employee, xmlforest(name, age, salary as pay)) FROM emp;
---END---
---START---
CREATE VIEW xmlview5 AS SELECT xmlparse(content '<abc>x</abc>');
---END---
---START---
CREATE VIEW xmlview6 AS SELECT xmlpi(name foo, 'bar');
---END---
---START---
CREATE VIEW xmlview7 AS SELECT xmlroot(xml '<foo/>', version no value, standalone yes);
---END---
---START---
CREATE VIEW xmlview8 AS SELECT xmlserialize(content 'good' as char(10));
---END---
---START---
CREATE VIEW xmlview9 AS SELECT xmlserialize(content 'good' as text);
---END---
---START---

SELECT table_name, view_definition FROM information_schema.views
  WHERE table_name LIKE 'xmlview%' ORDER BY 1;
---END---
---START---

-- Text XPath expressions evaluation

SELECT xpath('/value', data) FROM xmltest;
---END---
---START---
SELECT xpath(NULL, NULL) IS NULL FROM xmltest;
---END---
---START---
SELECT xpath('', '<!-- error -->');
---END---
---START---
SELECT xpath('//text()', '<local:data xmlns:local="http://127.0.0.1"><local:piece id="1">number one</local:piece><local:piece id="2" /></local:data>');
---END---
---START---
SELECT xpath('//loc:piece/@id', '<local:data xmlns:local="http://127.0.0.1"><local:piece id="1">number one</local:piece><local:piece id="2" /></local:data>', ARRAY[ARRAY['loc', 'http://127.0.0.1']]);
---END---
---START---
SELECT xpath('//loc:piece', '<local:data xmlns:local="http://127.0.0.1"><local:piece id="1">number one</local:piece><local:piece id="2" /></local:data>', ARRAY[ARRAY['loc', 'http://127.0.0.1']]);
---END---
---START---
SELECT xpath('//loc:piece', '<local:data xmlns:local="http://127.0.0.1" xmlns="http://127.0.0.2"><local:piece id="1"><internal>number one</internal><internal2/></local:piece><local:piece id="2" /></local:data>', ARRAY[ARRAY['loc', 'http://127.0.0.1']]);
---END---
---START---
SELECT xpath('//b', '<a>one <b>two</b> three <b>etc</b></a>');
---END---
---START---
SELECT xpath('//text()', '<root>&lt;</root>');
---END---
---START---
SELECT xpath('//@value', '<root value="&lt;"/>');
---END---
---START---
SELECT xpath('''<<invalid>>''', '<root/>');
---END---
---START---
SELECT xpath('count(//*)', '<root><sub/><sub/></root>');
---END---
---START---
SELECT xpath('count(//*)=0', '<root><sub/><sub/></root>');
---END---
---START---
SELECT xpath('count(//*)=3', '<root><sub/><sub/></root>');
---END---
---START---
SELECT xpath('name(/*)', '<root><sub/><sub/></root>');
---END---
---START---
SELECT xpath('/nosuchtag', '<root/>');
---END---
---START---
SELECT xpath('root', '<root/>');
---END---
---START---

-- Round-trip non-ASCII data through xpath().
DO $$
DECLARE
  xml_declaration text := '<?xml version="1.0" encoding="ISO-8859-1"?>';
---END---
---START---
  degree_symbol text;
---END---
---START---
  res xml[];
---END---
---START---
BEGIN
  -- Per the documentation, except when the server encoding is UTF8, xpath()
  -- may not work on non-ASCII data.  The untranslatable_character and
  -- undefined_function traps below, currently dead code, will become relevant
  -- if we remove this limitation.
  IF current_setting('server_encoding') <> 'UTF8' THEN
    RAISE LOG 'skip: encoding % unsupported for xpath',
      current_setting('server_encoding');
---END---
---START---
    RETURN;
---END---
---START---
  END IF;
---END---
---START---

  degree_symbol := convert_from('\xc2b0', 'UTF8');
---END---
---START---
  res := xpath('text()', (xml_declaration ||
    '<x>' || degree_symbol || '</x>')::xml);
---END---
---START---
  IF degree_symbol <> res[1]::text THEN
    RAISE 'expected % (%), got % (%)',
      degree_symbol, convert_to(degree_symbol, 'UTF8'),
      res[1], convert_to(res[1]::text, 'UTF8');
---END---
---START---
  END IF;
---END---
---START---
EXCEPTION
  -- character with byte sequence 0xc2 0xb0 in encoding "UTF8" has no equivalent in encoding "LATIN8"
  WHEN untranslatable_character
  -- default conversion function for encoding "UTF8" to "MULE_INTERNAL" does not exist
  OR undefined_function
  -- unsupported XML feature
  OR feature_not_supported THEN
    RAISE LOG 'skip: %', SQLERRM;
---END---
---START---
END
$$;
---END---
---START---

-- Test xmlexists and xpath_exists
SELECT xmlexists('//town[text() = ''Toronto'']' PASSING BY REF '<towns><town>Bidford-on-Avon</town><town>Cwmbran</town><town>Bristol</town></towns>');
---END---
---START---
SELECT xmlexists('//town[text() = ''Cwmbran'']' PASSING BY REF '<towns><town>Bidford-on-Avon</town><town>Cwmbran</town><town>Bristol</town></towns>');
---END---
---START---
SELECT xmlexists('count(/nosuchtag)' PASSING BY REF '<root/>');
---END---
---START---
SELECT xpath_exists('//town[text() = ''Toronto'']','<towns><town>Bidford-on-Avon</town><town>Cwmbran</town><town>Bristol</town></towns>'::xml);
---END---
---START---
SELECT xpath_exists('//town[text() = ''Cwmbran'']','<towns><town>Bidford-on-Avon</town><town>Cwmbran</town><town>Bristol</town></towns>'::xml);
---END---
---START---
SELECT xpath_exists('count(/nosuchtag)', '<root/>'::xml);
---END---
---START---

INSERT INTO xmltest VALUES (4, '<menu><beers><name>Budvar</name><cost>free</cost><name>Carling</name><cost>lots</cost></beers></menu>'::xml);
---END---
---START---
INSERT INTO xmltest VALUES (5, '<menu><beers><name>Molson</name><cost>free</cost><name>Carling</name><cost>lots</cost></beers></menu>'::xml);
---END---
---START---
INSERT INTO xmltest VALUES (6, '<myns:menu xmlns:myns="http://myns.com"><myns:beers><myns:name>Budvar</myns:name><myns:cost>free</myns:cost><myns:name>Carling</myns:name><myns:cost>lots</myns:cost></myns:beers></myns:menu>'::xml);
---END---
---START---
INSERT INTO xmltest VALUES (7, '<myns:menu xmlns:myns="http://myns.com"><myns:beers><myns:name>Molson</myns:name><myns:cost>free</myns:cost><myns:name>Carling</myns:name><myns:cost>lots</myns:cost></myns:beers></myns:menu>'::xml);
---END---
---START---

SELECT COUNT(id) FROM xmltest WHERE xmlexists('/menu/beer' PASSING data);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xmlexists('/menu/beer' PASSING BY REF data BY REF);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xmlexists('/menu/beers' PASSING BY REF data);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xmlexists('/menu/beers/name[text() = ''Molson'']' PASSING BY REF data);
---END---
---START---

SELECT COUNT(id) FROM xmltest WHERE xpath_exists('/menu/beer',data);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xpath_exists('/menu/beers',data);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xpath_exists('/menu/beers/name[text() = ''Molson'']',data);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xpath_exists('/myns:menu/myns:beer',data,ARRAY[ARRAY['myns','http://myns.com']]);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xpath_exists('/myns:menu/myns:beers',data,ARRAY[ARRAY['myns','http://myns.com']]);
---END---
---START---
SELECT COUNT(id) FROM xmltest WHERE xpath_exists('/myns:menu/myns:beers/myns:name[text() = ''Molson'']',data,ARRAY[ARRAY['myns','http://myns.com']]);
---END---
---START---

CREATE TABLE query ( expr TEXT );
---END---
---START---
INSERT INTO query VALUES ('/menu/beers/cost[text() = ''lots'']');
---END---
---START---
SELECT COUNT(id) FROM xmltest, query WHERE xmlexists(expr PASSING BY REF data);
---END---
---START---

-- Test xml_is_well_formed and variants

SELECT xml_is_well_formed_document('<foo>bar</foo>');
---END---
---START---
SELECT xml_is_well_formed_document('abc');
---END---
---START---
SELECT xml_is_well_formed_content('<foo>bar</foo>');
---END---
---START---
SELECT xml_is_well_formed_content('abc');
---END---
---START---

SET xmloption TO DOCUMENT;
---END---
---START---
SELECT xml_is_well_formed('abc');
---END---
---START---
SELECT xml_is_well_formed('<>');
---END---
---START---
SELECT xml_is_well_formed('<abc/>');
---END---
---START---
SELECT xml_is_well_formed('<foo>bar</foo>');
---END---
---START---
SELECT xml_is_well_formed('<foo>bar</foo');
---END---
---START---
SELECT xml_is_well_formed('<foo><bar>baz</foo>');
---END---
---START---
SELECT xml_is_well_formed('<local:data xmlns:local="http://127.0.0.1"><local:piece id="1">number one</local:piece><local:piece id="2" /></local:data>');
---END---
---START---
SELECT xml_is_well_formed('<pg:foo xmlns:pg="http://postgresql.org/stuff">bar</my:foo>');
---END---
---START---
SELECT xml_is_well_formed('<pg:foo xmlns:pg="http://postgresql.org/stuff">bar</pg:foo>');
---END---
---START---
SELECT xml_is_well_formed('<invalidentity>&</abc>');
---END---
---START---
SELECT xml_is_well_formed('<undefinedentity>&idontexist;</abc>');
---END---
---START---
SELECT xml_is_well_formed('<invalidns xmlns=''&lt;''/>');
---END---
---START---
SELECT xml_is_well_formed('<relativens xmlns=''relative''/>');
---END---
---START---
SELECT xml_is_well_formed('<twoerrors>&idontexist;</unbalanced>');
---END---
---START---

SET xmloption TO CONTENT;
---END---
---START---
SELECT xml_is_well_formed('abc');
---END---
---START---

-- Since xpath() deals with namespaces, it's a bit stricter about
-- what's well-formed and what's not. If we don't obey these rules
-- (i.e. ignore namespace-related errors from libxml), xpath()
-- fails in subtle ways. The following would for example produce
-- the xml value
--   <invalidns xmlns='<'/>
-- which is invalid because '<' may not appear un-escaped in
-- attribute values.
-- Since different libxml versions emit slightly different
-- error messages, we suppress the DETAIL in this test.
\set VERBOSITY terse
SELECT xpath('/*', '<invalidns xmlns=''&lt;''/>');
---END---
---START---
\set VERBOSITY default

-- Again, the XML isn't well-formed for namespace purposes
SELECT xpath('/*', '<nosuchprefix:tag/>');
---END---
---START---

-- XPath deprecates relative namespaces, but they're not supposed to
-- throw an error, only a warning.
SELECT xpath('/*', '<relativens xmlns=''relative''/>');
---END---
---START---

-- External entity references should not leak filesystem information.
SELECT XMLPARSE(DOCUMENT '<!DOCTYPE foo [<!ENTITY c SYSTEM "/etc/passwd">]><foo>&c;</foo>');
---END---
---START---
SELECT XMLPARSE(DOCUMENT '<!DOCTYPE foo [<!ENTITY c SYSTEM "/etc/no.such.file">]><foo>&c;</foo>');
---END---
---START---
-- This might or might not load the requested DTD, but it mustn't throw error.
SELECT XMLPARSE(DOCUMENT '<!DOCTYPE chapter PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN" "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd"><chapter>&nbsp;</chapter>');
---END---
---START---

-- XMLPATH tests
CREATE TABLE xmldata(data xml);
---END---
---START---
INSERT INTO xmldata VALUES('<ROWS>
<ROW id="1">
  <COUNTRY_ID>AU</COUNTRY_ID>
  <COUNTRY_NAME>Australia</COUNTRY_NAME>
  <REGION_ID>3</REGION_ID>
</ROW>
<ROW id="2">
  <COUNTRY_ID>CN</COUNTRY_ID>
  <COUNTRY_NAME>China</COUNTRY_NAME>
  <REGION_ID>3</REGION_ID>
</ROW>
<ROW id="3">
  <COUNTRY_ID>HK</COUNTRY_ID>
  <COUNTRY_NAME>HongKong</COUNTRY_NAME>
  <REGION_ID>3</REGION_ID>
</ROW>
<ROW id="4">
  <COUNTRY_ID>IN</COUNTRY_ID>
  <COUNTRY_NAME>India</COUNTRY_NAME>
  <REGION_ID>3</REGION_ID>
</ROW>
<ROW id="5">
  <COUNTRY_ID>JP</COUNTRY_ID>
  <COUNTRY_NAME>Japan</COUNTRY_NAME>
  <REGION_ID>3</REGION_ID><PREMIER_NAME>Sinzo Abe</PREMIER_NAME>
</ROW>
<ROW id="6">
  <COUNTRY_ID>SG</COUNTRY_ID>
  <COUNTRY_NAME>Singapore</COUNTRY_NAME>
  <REGION_ID>3</REGION_ID><SIZE unit="km">791</SIZE>
</ROW>
</ROWS>');
---END---
---START---

-- XMLTABLE with columns
SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME/text()' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
---END---
---START---

CREATE VIEW xmltableview1 AS SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME/text()' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
---END---
---START---

SELECT * FROM xmltableview1;
---END---
---START---

\sv xmltableview1

EXPLAIN (COSTS OFF) SELECT * FROM xmltableview1;
---END---
---START---
EXPLAIN (COSTS OFF, VERBOSE) SELECT * FROM xmltableview1;
---END---
---START---

-- errors
SELECT * FROM XMLTABLE (ROW () PASSING null COLUMNS v1 timestamp) AS f (v1, v2);
---END---
---START---

-- XMLNAMESPACES tests
SELECT * FROM XMLTABLE(XMLNAMESPACES('http://x.y' AS zz),
                      '/zz:rows/zz:row'
                      PASSING '<rows xmlns="http://x.y"><row><a>10</a></row></rows>'
                      COLUMNS a int PATH 'zz:a');
---END---
---START---

CREATE VIEW xmltableview2 AS SELECT * FROM XMLTABLE(XMLNAMESPACES('http://x.y' AS zz),
                      '/zz:rows/zz:row'
                      PASSING '<rows xmlns="http://x.y"><row><a>10</a></row></rows>'
                      COLUMNS a int PATH 'zz:a');
---END---
---START---

SELECT * FROM xmltableview2;
---END---
---START---

SELECT * FROM XMLTABLE(XMLNAMESPACES(DEFAULT 'http://x.y'),
                      '/rows/row'
                      PASSING '<rows xmlns="http://x.y"><row><a>10</a></row></rows>'
                      COLUMNS a int PATH 'a');
---END---
---START---

SELECT * FROM XMLTABLE('.'
                       PASSING '<foo/>'
                       COLUMNS a text PATH 'foo/namespace::node()');
---END---
---START---

-- used in prepare statements
PREPARE pp AS
SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
---END---
---START---

EXECUTE pp;
---END---
---START---

SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS "COUNTRY_NAME" text, "REGION_ID" int);
---END---
---START---
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS id FOR ORDINALITY, "COUNTRY_NAME" text, "REGION_ID" int);
---END---
---START---
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS id int PATH '@id', "COUNTRY_NAME" text, "REGION_ID" int);
---END---
---START---
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS id int PATH '@id');
---END---
---START---
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS id FOR ORDINALITY);
---END---
---START---
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS id int PATH '@id', "COUNTRY_NAME" text, "REGION_ID" int, rawdata xml PATH '.');
---END---
---START---
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS id int PATH '@id', "COUNTRY_NAME" text, "REGION_ID" int, rawdata xml PATH './*');
---END---
---START---

SELECT * FROM xmltable('/root' passing '<root><element>a1a<!-- aaaa -->a2a<?aaaaa?> <!--z-->  bbbb<x>xxx</x>cccc</element></root>' COLUMNS element text);
---END---
---START---
SELECT * FROM xmltable('/root' passing '<root><element>a1a<!-- aaaa -->a2a<?aaaaa?> <!--z-->  bbbb<x>xxx</x>cccc</element></root>' COLUMNS element text PATH 'element/text()'); -- should fail

-- CDATA test
select * from xmltable('d/r' passing '<d><r><c><![CDATA[<hello> &"<>!<a>foo</a>]]></c></r><r><c>2</c></r></d>' columns c text);
---END---
---START---

-- XML builtin entities
SELECT * FROM xmltable('/x/a' PASSING '<x><a><ent>&apos;</ent></a><a><ent>&quot;</ent></a><a><ent>&amp;</ent></a><a><ent>&lt;</ent></a><a><ent>&gt;</ent></a></x>' COLUMNS ent text);
---END---
---START---
SELECT * FROM xmltable('/x/a' PASSING '<x><a><ent>&apos;</ent></a><a><ent>&quot;</ent></a><a><ent>&amp;</ent></a><a><ent>&lt;</ent></a><a><ent>&gt;</ent></a></x>' COLUMNS ent xml);
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
---END---
---START---

-- test qual
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS "COUNTRY_NAME" text, "REGION_ID" int) WHERE "COUNTRY_NAME" = 'Japan';
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
SELECT xmltable.* FROM xmldata, LATERAL xmltable('/ROWS/ROW[COUNTRY_NAME="Japan" or COUNTRY_NAME="India"]' PASSING data COLUMNS "COUNTRY_NAME" text, "REGION_ID" int) WHERE "COUNTRY_NAME" = 'Japan';
---END---
---START---

-- should to work with more data
INSERT INTO xmldata VALUES('<ROWS>
<ROW id="10">
  <COUNTRY_ID>CZ</COUNTRY_ID>
  <COUNTRY_NAME>Czech Republic</COUNTRY_NAME>
  <REGION_ID>2</REGION_ID><PREMIER_NAME>Milos Zeman</PREMIER_NAME>
</ROW>
<ROW id="11">
  <COUNTRY_ID>DE</COUNTRY_ID>
  <COUNTRY_NAME>Germany</COUNTRY_NAME>
  <REGION_ID>2</REGION_ID>
</ROW>
<ROW id="12">
  <COUNTRY_ID>FR</COUNTRY_ID>
  <COUNTRY_NAME>France</COUNTRY_NAME>
  <REGION_ID>2</REGION_ID>
</ROW>
</ROWS>');
---END---
---START---

INSERT INTO xmldata VALUES('<ROWS>
<ROW id="20">
  <COUNTRY_ID>EG</COUNTRY_ID>
  <COUNTRY_NAME>Egypt</COUNTRY_NAME>
  <REGION_ID>1</REGION_ID>
</ROW>
<ROW id="21">
  <COUNTRY_ID>SD</COUNTRY_ID>
  <COUNTRY_NAME>Sudan</COUNTRY_NAME>
  <REGION_ID>1</REGION_ID>
</ROW>
</ROWS>');
---END---
---START---

SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
---END---
---START---

SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified')
  WHERE region_id = 2;
---END---
---START---

EXPLAIN (VERBOSE, COSTS OFF)
SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE',
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified')
  WHERE region_id = 2;
---END---
---START---

-- should fail, NULL value
SELECT  xmltable.*
   FROM (SELECT data FROM xmldata) x,
        LATERAL XMLTABLE('/ROWS/ROW'
                         PASSING data
                         COLUMNS id int PATH '@id',
                                  _id FOR ORDINALITY,
                                  country_name text PATH 'COUNTRY_NAME' NOT NULL,
                                  country_id text PATH 'COUNTRY_ID',
                                  region_id int PATH 'REGION_ID',
                                  size float PATH 'SIZE' NOT NULL,
                                  unit text PATH 'SIZE/@unit',
                                  premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
---END---
---START---

-- if all is ok, then result is empty
-- one line xml test
WITH
   x AS (SELECT proname, proowner, procost::numeric, pronargs,
                array_to_string(proargnames,',') as proargnames,
                case when proargtypes <> '' then array_to_string(proargtypes::oid[],',') end as proargtypes
           FROM pg_proc WHERE proname = 'f_leak'),
   y AS (SELECT xmlelement(name proc,
                           xmlforest(proname, proowner,
                                     procost, pronargs,
                                     proargnames, proargtypes)) as proc
           FROM x),
   z AS (SELECT xmltable.*
           FROM y,
                LATERAL xmltable('/proc' PASSING proc
                                 COLUMNS proname name,
                                         proowner oid,
                                         procost float,
                                         pronargs int,
                                         proargnames text,
                                         proargtypes text))
   SELECT * FROM z
   EXCEPT SELECT * FROM x;
---END---
---START---

-- multi line xml test, result should be empty too
WITH
   x AS (SELECT proname, proowner, procost::numeric, pronargs,
                array_to_string(proargnames,',') as proargnames,
                case when proargtypes <> '' then array_to_string(proargtypes::oid[],',') end as proargtypes
           FROM pg_proc),
   y AS (SELECT xmlelement(name data,
                           xmlagg(xmlelement(name proc,
                                             xmlforest(proname, proowner, procost,
                                                       pronargs, proargnames, proargtypes)))) as doc
           FROM x),
   z AS (SELECT xmltable.*
           FROM y,
                LATERAL xmltable('/data/proc' PASSING doc
                                 COLUMNS proname name,
                                         proowner oid,
                                         procost float,
                                         pronargs int,
                                         proargnames text,
                                         proargtypes text))
   SELECT * FROM z
   EXCEPT SELECT * FROM x;
---END---
---START---

CREATE TABLE xmltest2(x xml, _path text);
---END---
---START---

INSERT INTO xmltest2 VALUES('<d><r><ac>1</ac></r></d>', 'A');
---END---
---START---
INSERT INTO xmltest2 VALUES('<d><r><bc>2</bc></r></d>', 'B');
---END---
---START---
INSERT INTO xmltest2 VALUES('<d><r><cc>3</cc></r></d>', 'C');
---END---
---START---
INSERT INTO xmltest2 VALUES('<d><r><dc>2</dc></r></d>', 'D');
---END---
---START---

SELECT xmltable.* FROM xmltest2, LATERAL xmltable('/d/r' PASSING x COLUMNS a int PATH '' || lower(_path) || 'c');
---END---
---START---
SELECT xmltable.* FROM xmltest2, LATERAL xmltable(('/d/r/' || lower(_path) || 'c') PASSING x COLUMNS a int PATH '.');
---END---
---START---
SELECT xmltable.* FROM xmltest2, LATERAL xmltable(('/d/r/' || lower(_path) || 'c') PASSING x COLUMNS a int PATH 'x' DEFAULT ascii(_path) - 54);
---END---
---START---

-- XPath result can be boolean or number too
SELECT * FROM XMLTABLE('*' PASSING '<a>a</a>' COLUMNS a xml PATH '.', b text PATH '.', c text PATH '"hi"', d boolean PATH '. = "a"', e integer PATH 'string-length(.)');
---END---
---START---
\x
SELECT * FROM XMLTABLE('*' PASSING '<e>pre<!--c1--><?pi arg?><![CDATA[&ent1]]><n2>&amp;deep</n2>post</e>' COLUMNS x xml PATH '/e/n2', y xml PATH '/');
---END---
---START---
\x

SELECT * FROM XMLTABLE('.' PASSING XMLELEMENT(NAME a) columns a varchar(20) PATH '"<foo/>"', b xml PATH '"<foo/>"');
---END---
