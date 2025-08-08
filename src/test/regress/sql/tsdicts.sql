---START---
--Test text search dictionaries and configurations

-- Test ISpell dictionary with ispell affix file
CREATE TEXT SEARCH DICTIONARY ispell (
                        Template=ispell,
                        DictFile=ispell_sample,
                        AffFile=ispell_sample
);
---END---
---START---
SELECT ts_lexize('ispell', 'skies');
---END---
---START---
SELECT ts_lexize('ispell', 'bookings');
---END---
---START---
SELECT ts_lexize('ispell', 'booking');
---END---
---START---
SELECT ts_lexize('ispell', 'foot');
---END---
---START---
SELECT ts_lexize('ispell', 'foots');
---END---
---START---
SELECT ts_lexize('ispell', 'rebookings');
---END---
---START---
SELECT ts_lexize('ispell', 'rebooking');
---END---
---START---
SELECT ts_lexize('ispell', 'rebook');
---END---
---START---
SELECT ts_lexize('ispell', 'unbookings');
---END---
---START---
SELECT ts_lexize('ispell', 'unbooking');
---END---
---START---
SELECT ts_lexize('ispell', 'unbook');
---END---
---START---
SELECT ts_lexize('ispell', 'footklubber');
---END---
---START---
SELECT ts_lexize('ispell', 'footballklubber');
---END---
---START---
SELECT ts_lexize('ispell', 'ballyklubber');
---END---
---START---
SELECT ts_lexize('ispell', 'footballyklubber');
---END---
---START---
-- Test ISpell dictionary with hunspell affix file
CREATE TEXT SEARCH DICTIONARY hunspell (
                        Template=ispell,
                        DictFile=ispell_sample,
                        AffFile=hunspell_sample
);
---END---
---START---
SELECT ts_lexize('hunspell', 'skies');
---END---
---START---
SELECT ts_lexize('hunspell', 'bookings');
---END---
---START---
SELECT ts_lexize('hunspell', 'booking');
---END---
---START---
SELECT ts_lexize('hunspell', 'foot');
---END---
---START---
SELECT ts_lexize('hunspell', 'foots');
---END---
---START---
SELECT ts_lexize('hunspell', 'rebookings');
---END---
---START---
SELECT ts_lexize('hunspell', 'rebooking');
---END---
---START---
SELECT ts_lexize('hunspell', 'rebook');
---END---
---START---
SELECT ts_lexize('hunspell', 'unbookings');
---END---
---START---
SELECT ts_lexize('hunspell', 'unbooking');
---END---
---START---
SELECT ts_lexize('hunspell', 'unbook');
---END---
---START---
SELECT ts_lexize('hunspell', 'footklubber');
---END---
---START---
SELECT ts_lexize('hunspell', 'footballklubber');
---END---
---START---
SELECT ts_lexize('hunspell', 'ballyklubber');
---END---
---START---
SELECT ts_lexize('hunspell', 'footballyklubber');
---END---
---START---
-- Test ISpell dictionary with hunspell affix file with FLAG long parameter
CREATE TEXT SEARCH DICTIONARY hunspell_long (
                        Template=ispell,
                        DictFile=hunspell_sample_long,
                        AffFile=hunspell_sample_long
);
---END---
---START---
SELECT ts_lexize('hunspell_long', 'skies');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'bookings');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'booking');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'foot');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'foots');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'rebookings');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'rebooking');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'rebook');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'unbookings');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'unbooking');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'unbook');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'booked');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'footklubber');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'footballklubber');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'ballyklubber');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'ballsklubber');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'footballyklubber');
---END---
---START---
SELECT ts_lexize('hunspell_long', 'ex-machina');
---END---
---START---
-- Test ISpell dictionary with hunspell affix file with FLAG num parameter
CREATE TEXT SEARCH DICTIONARY hunspell_num (
                        Template=ispell,
                        DictFile=hunspell_sample_num,
                        AffFile=hunspell_sample_num
);
---END---
---START---
SELECT ts_lexize('hunspell_num', 'skies');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'sk');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'bookings');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'booking');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'foot');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'foots');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'rebookings');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'rebooking');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'rebook');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'unbookings');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'unbooking');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'unbook');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'booked');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'footklubber');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'footballklubber');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'ballyklubber');
---END---
---START---
SELECT ts_lexize('hunspell_num', 'footballyklubber');
---END---
---START---
-- Test suitability of affix and dict files
CREATE TEXT SEARCH DICTIONARY hunspell_err (
						Template=ispell,
						DictFile=ispell_sample,
						AffFile=hunspell_sample_long
);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY hunspell_err (
						Template=ispell,
						DictFile=ispell_sample,
						AffFile=hunspell_sample_num
);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY hunspell_invalid_1 (
						Template=ispell,
						DictFile=hunspell_sample_long,
						AffFile=ispell_sample
);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY hunspell_invalid_2 (
						Template=ispell,
						DictFile=hunspell_sample_long,
						AffFile=hunspell_sample_num
);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY hunspell_invalid_3 (
						Template=ispell,
						DictFile=hunspell_sample_num,
						AffFile=ispell_sample
);
---END---
---START---
CREATE TEXT SEARCH DICTIONARY hunspell_err (
						Template=ispell,
						DictFile=hunspell_sample_num,
						AffFile=hunspell_sample_long
);
---END---
---START---
-- Synonym dictionary
CREATE TEXT SEARCH DICTIONARY synonym (
						Template=synonym,
						Synonyms=synonym_sample
);
---END---
---START---
SELECT ts_lexize('synonym', 'PoStGrEs');
---END---
---START---
SELECT ts_lexize('synonym', 'Gogle');
---END---
---START---
SELECT ts_lexize('synonym', 'indices');
---END---
---START---
-- test altering boolean parameters
SELECT dictinitoption FROM pg_ts_dict WHERE dictname = 'synonym';
---END---
---START---
ALTER TEXT SEARCH DICTIONARY synonym (CaseSensitive = 1);
---END---
---START---
SELECT ts_lexize('synonym', 'PoStGrEs');
---END---
---START---
SELECT dictinitoption FROM pg_ts_dict WHERE dictname = 'synonym';
---END---
---START---
ALTER TEXT SEARCH DICTIONARY synonym (CaseSensitive = 2);
---END---
---START---
-- fail

ALTER TEXT SEARCH DICTIONARY synonym (CaseSensitive = off);
---END---
---START---
SELECT ts_lexize('synonym', 'PoStGrEs');
---END---
---START---
SELECT dictinitoption FROM pg_ts_dict WHERE dictname = 'synonym';
---END---
---START---
-- Create and simple test thesaurus dictionary
-- More tests in configuration checks because ts_lexize()
-- cannot pass more than one word to thesaurus.
CREATE TEXT SEARCH DICTIONARY thesaurus (
                        Template=thesaurus,
						DictFile=thesaurus_sample,
						Dictionary=english_stem
);
---END---
---START---
SELECT ts_lexize('thesaurus', 'one');
---END---
---START---
-- Test ispell dictionary in configuration
CREATE TEXT SEARCH CONFIGURATION ispell_tst (
						COPY=english
);
---END---
---START---
ALTER TEXT SEARCH CONFIGURATION ispell_tst ALTER MAPPING FOR
	word, numword, asciiword, hword, numhword, asciihword, hword_part, hword_numpart, hword_asciipart
	WITH ispell, english_stem;
---END---
---START---
SELECT to_tsvector('ispell_tst', 'Booking the skies after rebookings for footballklubber from a foot');
---END---
---START---
SELECT to_tsquery('ispell_tst', 'footballklubber');
---END---
---START---
SELECT to_tsquery('ispell_tst', 'footballyklubber:b & rebookings:A & sky');
---END---
---START---
-- Test ispell dictionary with hunspell affix in configuration
CREATE TEXT SEARCH CONFIGURATION hunspell_tst (
						COPY=ispell_tst
);
---END---
---START---
ALTER TEXT SEARCH CONFIGURATION hunspell_tst ALTER MAPPING
	REPLACE ispell WITH hunspell;
---END---
---START---
SELECT to_tsvector('hunspell_tst', 'Booking the skies after rebookings for footballklubber from a foot');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballklubber');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballyklubber:b & rebookings:A & sky');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballyklubber:b <-> sky');
---END---
---START---
SELECT phraseto_tsquery('hunspell_tst', 'footballyklubber sky');
---END---
---START---
-- Test ispell dictionary with hunspell affix with FLAG long in configuration
ALTER TEXT SEARCH CONFIGURATION hunspell_tst ALTER MAPPING
	REPLACE hunspell WITH hunspell_long;
---END---
---START---
SELECT to_tsvector('hunspell_tst', 'Booking the skies after rebookings for footballklubber from a foot');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballklubber');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballyklubber:b & rebookings:A & sky');
---END---
---START---
-- Test ispell dictionary with hunspell affix with FLAG num in configuration
ALTER TEXT SEARCH CONFIGURATION hunspell_tst ALTER MAPPING
	REPLACE hunspell_long WITH hunspell_num;
---END---
---START---
SELECT to_tsvector('hunspell_tst', 'Booking the skies after rebookings for footballklubber from a foot');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballklubber');
---END---
---START---
SELECT to_tsquery('hunspell_tst', 'footballyklubber:b & rebookings:A & sky');
---END---
---START---
-- Test synonym dictionary in configuration
CREATE TEXT SEARCH CONFIGURATION synonym_tst (
						COPY=english
);
---END---
---START---
ALTER TEXT SEARCH CONFIGURATION synonym_tst ALTER MAPPING FOR
	asciiword, hword_asciipart, asciihword
	WITH synonym, english_stem;
---END---
---START---
SELECT to_tsvector('synonym_tst', 'Postgresql is often called as postgres or pgsql and pronounced as postgre');
---END---
---START---
SELECT to_tsvector('synonym_tst', 'Most common mistake is to write Gogle instead of Google');
---END---
---START---
SELECT to_tsvector('synonym_tst', 'Indexes or indices - Which is right plural form of index?');
---END---
---START---
SELECT to_tsquery('synonym_tst', 'Index & indices');
---END---
---START---
-- test thesaurus in configuration
-- see thesaurus_sample.ths to understand 'odd' resulting tsvector
CREATE TEXT SEARCH CONFIGURATION thesaurus_tst (
						COPY=synonym_tst
);
---END---
---START---
ALTER TEXT SEARCH CONFIGURATION thesaurus_tst ALTER MAPPING FOR
	asciiword, hword_asciipart, asciihword
	WITH synonym, thesaurus, english_stem;
---END---
---START---
SELECT to_tsvector('thesaurus_tst', 'one postgres one two one two three one');
---END---
---START---
SELECT to_tsvector('thesaurus_tst', 'Supernovae star is very new star and usually called supernovae (abbreviation SN)');
---END---
---START---
SELECT to_tsvector('thesaurus_tst', 'Booking tickets is looking like a booking a tickets');
---END---
---START---
-- invalid: non-lowercase quoted identifiers
CREATE TEXT SEARCH DICTIONARY tsdict_case
(
	Template = ispell,
	"DictFile" = ispell_sample,
	"AffFile" = ispell_sample
);
---END---
