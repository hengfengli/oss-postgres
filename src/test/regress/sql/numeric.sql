---START---
CREATE TABLE num_data (gemini_pk serial PRIMARY KEY, id int8, val numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_add (gemini_pk serial PRIMARY KEY, id1 int8, id2 int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_sub (gemini_pk serial PRIMARY KEY, id1 int8, id2 int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_div (gemini_pk serial PRIMARY KEY, id1 int8, id2 int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_mul (gemini_pk serial PRIMARY KEY, id1 int8, id2 int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_sqrt (gemini_pk serial PRIMARY KEY, id int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_ln (gemini_pk serial PRIMARY KEY, id int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_log10 (gemini_pk serial PRIMARY KEY, id int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_exp_power_10_ln (gemini_pk serial PRIMARY KEY, id int8, expected numeric(210, 10));
---END---
---START---
CREATE TABLE num_result (gemini_pk serial PRIMARY KEY, id1 int8, id2 int8, result numeric(210, 10));
---END---
---START---
-- ******************************
-- * The following EXPECTED results are computed by bc(1)
-- * with a scale of 200
-- ******************************

BEGIN TRANSACTION;
---END---
---START---
INSERT INTO num_exp_add VALUES (0,0,'0');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,0,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,1,'0');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,1,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,2,'-34338492.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,2,'34338492.215397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,2,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,2,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,3,'4.31');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,3,'-4.31');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,3,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,3,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,4,'7799461.4119');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,4,'-7799461.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,4,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,4,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,5,'16397.038491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,5,'-16397.038491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,5,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,5,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,6,'93901.57763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,6,'-93901.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,6,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,6,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,7,'-83028485');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,7,'83028485');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,7,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,7,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,8,'74881');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,8,'-74881');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,8,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,8,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (0,9,'-24926804.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (0,9,'24926804.045047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (0,9,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (0,9,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,0,'0');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,0,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,1,'0');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,1,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,2,'-34338492.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,2,'34338492.215397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,2,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,2,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,3,'4.31');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,3,'-4.31');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,3,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,3,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,4,'7799461.4119');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,4,'-7799461.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,4,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,4,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,5,'16397.038491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,5,'-16397.038491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,5,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,5,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,6,'93901.57763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,6,'-93901.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,6,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,6,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,7,'-83028485');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,7,'83028485');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,7,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,7,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,8,'74881');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,8,'-74881');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,8,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,8,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (1,9,'-24926804.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (1,9,'24926804.045047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (1,9,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (1,9,'0');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,0,'-34338492.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,0,'-34338492.215397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,1,'-34338492.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,1,'-34338492.215397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,2,'-68676984.430794094');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,2,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,2,'1179132047626883.596862135856320209');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,2,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,3,'-34338487.905397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,3,'-34338496.525397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,3,'-147998901.44836127257');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,3,'-7967167.56737750510440835266');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,4,'-26539030.803497047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,4,'-42137953.627297047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,4,'-267821744976817.8111137106593');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,4,'-4.40267480046830116685');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,5,'-34322095.176906047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,5,'-34354889.253888047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,5,'-563049578578.769242506736077');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,5,'-2094.18866914563535496429');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,6,'-34244590.637766787');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,6,'-34432393.793027307');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,6,'-3224438592470.18449811926184222');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,6,'-365.68599891479766440940');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,7,'-117366977.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,7,'48689992.784602953');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,7,'2851072985828710.485883795');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,7,'.41357483778485235518');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,8,'-34263611.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,8,'-34413373.215397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,8,'-2571300635581.146276407');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,8,'-458.57416721727870888476');
---END---
---START---
INSERT INTO num_exp_add VALUES (2,9,'-59265296.260444467');
---END---
---START---
INSERT INTO num_exp_sub VALUES (2,9,'-9411688.170349627');
---END---
---START---
INSERT INTO num_exp_mul VALUES (2,9,'855948866655588.453741509242968740');
---END---
---START---
INSERT INTO num_exp_div VALUES (2,9,'1.37757299946438931811');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,0,'4.31');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,0,'4.31');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,1,'4.31');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,1,'4.31');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,2,'-34338487.905397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,2,'34338496.525397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,2,'-147998901.44836127257');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,2,'-.00000012551512084352');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,3,'8.62');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,3,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,3,'18.5761');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,3,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,4,'7799465.7219');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,4,'-7799457.1019');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,4,'33615678.685289');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,4,'.00000055260225961552');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,5,'16401.348491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,5,'-16392.728491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,5,'70671.23589621');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,5,'.00026285234387695504');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,6,'93905.88763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,6,'-93897.26763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,6,'404715.7995864206');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,6,'.00004589912234457595');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,7,'-83028480.69');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,7,'83028489.31');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,7,'-357852770.35');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,7,'-.00000005190989574240');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,8,'74885.31');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,8,'-74876.69');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,8,'322737.11');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,8,'.00005755799201399553');
---END---
---START---
INSERT INTO num_exp_add VALUES (3,9,'-24926799.735047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (3,9,'24926808.355047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (3,9,'-107434525.43415438020');
---END---
---START---
INSERT INTO num_exp_div VALUES (3,9,'-.00000017290624149854');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,0,'7799461.4119');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,0,'7799461.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,1,'7799461.4119');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,1,'7799461.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,2,'-26539030.803497047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,2,'42137953.627297047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,2,'-267821744976817.8111137106593');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,2,'-.22713465002993920385');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,3,'7799465.7219');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,3,'7799457.1019');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,3,'33615678.685289');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,3,'1809619.81714617169373549883');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,4,'15598922.8238');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,4,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,4,'60831598315717.14146161');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,4,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,5,'7815858.450391');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,5,'7783064.373409');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,5,'127888068979.9935054429');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,5,'475.66281046305802686061');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,6,'7893362.98953026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,6,'7705559.83426974');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,6,'732381731243.745115764094');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,6,'83.05996138436129499606');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,7,'-75229023.5881');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,7,'90827946.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,7,'-647577464846017.9715');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,7,'-.09393717604145131637');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,8,'7874342.4119');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,8,'7724580.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,8,'584031469984.4839');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,8,'104.15808298366741897143');
---END---
---START---
INSERT INTO num_exp_add VALUES (4,9,'-17127342.633147420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (4,9,'32726265.456947420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (4,9,'-194415646271340.1815956522980');
---END---
---START---
INSERT INTO num_exp_div VALUES (4,9,'-.31289456112403769409');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,0,'16397.038491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,0,'16397.038491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,1,'16397.038491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,1,'16397.038491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,2,'-34322095.176906047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,2,'34354889.253888047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,2,'-563049578578.769242506736077');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,2,'-.00047751189505192446');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,3,'16401.348491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,3,'16392.728491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,3,'70671.23589621');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,3,'3804.41728329466357308584');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,4,'7815858.450391');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,4,'-7783064.373409');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,4,'127888068979.9935054429');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,4,'.00210232958726897192');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,5,'32794.076982');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,5,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,5,'268862871.275335557081');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,5,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,6,'110298.61612126');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,6,'-77504.53913926');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,6,'1539707782.76899778633766');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,6,'.17461941433576102689');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,7,'-83012087.961509');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,7,'83044882.038491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,7,'-1361421264394.416135');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,7,'-.00019748690453643710');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,8,'91278.038491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,8,'-58483.961509');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,8,'1227826639.244571');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,8,'.21897461960978085228');
---END---
---START---
INSERT INTO num_exp_add VALUES (5,9,'-24910407.006556420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (5,9,'24943201.083538420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (5,9,'-408725765384.257043660243220');
---END---
---START---
INSERT INTO num_exp_div VALUES (5,9,'-.00065780749354660427');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,0,'93901.57763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,0,'93901.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,1,'93901.57763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,1,'93901.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,2,'-34244590.637766787');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,2,'34432393.793027307');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,2,'-3224438592470.18449811926184222');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,2,'-.00273458651128995823');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,3,'93905.88763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,3,'93897.26763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,3,'404715.7995864206');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,3,'21786.90896293735498839907');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,4,'7893362.98953026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,4,'-7705559.83426974');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,4,'732381731243.745115764094');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,4,'.01203949512295682469');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,5,'110298.61612126');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,5,'77504.53913926');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,5,'1539707782.76899778633766');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,5,'5.72674008674192359679');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,6,'187803.15526052');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,6,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,6,'8817506281.4517452372676676');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,6,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,7,'-82934583.42236974');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,7,'83122386.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,7,'-7796505729750.37795610');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,7,'-.00113095617281538980');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,8,'168782.57763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,8,'19020.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,8,'7031444034.53149906');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,8,'1.25401073209839612184');
---END---
---START---
INSERT INTO num_exp_add VALUES (6,9,'-24832902.467417160');
---END---
---START---
INSERT INTO num_exp_sub VALUES (6,9,'25020705.622677680');
---END---
---START---
INSERT INTO num_exp_mul VALUES (6,9,'-2340666225110.29929521292692920');
---END---
---START---
INSERT INTO num_exp_div VALUES (6,9,'-.00376709254265256789');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,0,'-83028485');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,0,'-83028485');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,1,'-83028485');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,1,'-83028485');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,2,'-117366977.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,2,'-48689992.784602953');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,2,'2851072985828710.485883795');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,2,'2.41794207151503385700');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,3,'-83028480.69');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,3,'-83028489.31');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,3,'-357852770.35');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,3,'-19264149.65197215777262180974');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,4,'-75229023.5881');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,4,'-90827946.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,4,'-647577464846017.9715');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,4,'-10.64541262725136247686');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,5,'-83012087.961509');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,5,'-83044882.038491');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,5,'-1361421264394.416135');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,5,'-5063.62688881730941836574');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,6,'-82934583.42236974');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,6,'-83122386.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,6,'-7796505729750.37795610');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,6,'-884.20756174009028770294');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,7,'-166056970');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,7,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,7,'6893729321395225');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,7,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,8,'-82953604');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,8,'-83103366');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,8,'-6217255985285');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,8,'-1108.80577182462841041118');
---END---
---START---
INSERT INTO num_exp_add VALUES (7,9,'-107955289.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (7,9,'-58101680.954952580');
---END---
---START---
INSERT INTO num_exp_mul VALUES (7,9,'2069634775752159.035758700');
---END---
---START---
INSERT INTO num_exp_div VALUES (7,9,'3.33089171198810413382');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,0,'74881');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,0,'74881');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,1,'74881');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,1,'74881');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,2,'-34263611.215397047');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,2,'34413373.215397047');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,2,'-2571300635581.146276407');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,2,'-.00218067233500788615');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,3,'74885.31');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,3,'74876.69');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,3,'322737.11');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,3,'17373.78190255220417633410');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,4,'7874342.4119');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,4,'-7724580.4119');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,4,'584031469984.4839');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,4,'.00960079113741758956');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,5,'91278.038491');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,5,'58483.961509');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,5,'1227826639.244571');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,5,'4.56673929509287019456');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,6,'168782.57763026');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,6,'-19020.57763026');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,6,'7031444034.53149906');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,6,'.79744134113322314424');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,7,'-82953604');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,7,'83103366');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,7,'-6217255985285');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,7,'-.00090187120721280172');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,8,'149762');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,8,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,8,'5607164161');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,8,'1.00000000000000000000');
---END---
---START---
INSERT INTO num_exp_add VALUES (8,9,'-24851923.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (8,9,'25001685.045047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (8,9,'-1866544013697.195857020');
---END---
---START---
INSERT INTO num_exp_div VALUES (8,9,'-.00300403532938582735');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,0,'-24926804.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,0,'-24926804.045047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,0,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,0,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,1,'-24926804.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,1,'-24926804.045047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,1,'0');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,1,'NaN');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,2,'-59265296.260444467');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,2,'9411688.170349627');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,2,'855948866655588.453741509242968740');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,2,'.72591434384152961526');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,3,'-24926799.735047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,3,'-24926808.355047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,3,'-107434525.43415438020');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,3,'-5783481.21694835730858468677');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,4,'-17127342.633147420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,4,'-32726265.456947420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,4,'-194415646271340.1815956522980');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,4,'-3.19596478892958416484');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,5,'-24910407.006556420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,5,'-24943201.083538420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,5,'-408725765384.257043660243220');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,5,'-1520.20159364322004505807');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,6,'-24832902.467417160');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,6,'-25020705.622677680');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,6,'-2340666225110.29929521292692920');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,6,'-265.45671195426965751280');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,7,'-107955289.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,7,'58101680.954952580');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,7,'2069634775752159.035758700');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,7,'.30021990699995814689');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,8,'-24851923.045047420');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,8,'-25001685.045047420');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,8,'-1866544013697.195857020');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,8,'-332.88556569820675471748');
---END---
---START---
INSERT INTO num_exp_add VALUES (9,9,'-49853608.090094840');
---END---
---START---
INSERT INTO num_exp_sub VALUES (9,9,'0');
---END---
---START---
INSERT INTO num_exp_mul VALUES (9,9,'621345559900192.420120630048656400');
---END---
---START---
INSERT INTO num_exp_div VALUES (9,9,'1.00000000000000000000');
---END---
---START---
COMMIT TRANSACTION;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (0,'0');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (1,'0');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (2,'5859.90547836712524903505');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (3,'2.07605394920266944396');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (4,'2792.75158435189147418923');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (5,'128.05092147657509145473');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (6,'306.43364311096782703406');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (7,'9111.99676251039939975230');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (8,'273.64392922189960397542');
---END---
---START---
INSERT INTO num_exp_sqrt VALUES (9,'4992.67503899937593364766');
---END---
---START---
COMMIT TRANSACTION;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
INSERT INTO num_exp_ln VALUES (0,'NaN');
---END---
---START---
INSERT INTO num_exp_ln VALUES (1,'NaN');
---END---
---START---
INSERT INTO num_exp_ln VALUES (2,'17.35177750493897715514');
---END---
---START---
INSERT INTO num_exp_ln VALUES (3,'1.46093790411565641971');
---END---
---START---
INSERT INTO num_exp_ln VALUES (4,'15.86956523951936572464');
---END---
---START---
INSERT INTO num_exp_ln VALUES (5,'9.70485601768871834038');
---END---
---START---
INSERT INTO num_exp_ln VALUES (6,'11.45000246622944403127');
---END---
---START---
INSERT INTO num_exp_ln VALUES (7,'18.23469429965478772991');
---END---
---START---
INSERT INTO num_exp_ln VALUES (8,'11.22365546576315513668');
---END---
---START---
INSERT INTO num_exp_ln VALUES (9,'17.03145425013166006962');
---END---
---START---
COMMIT TRANSACTION;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
INSERT INTO num_exp_log10 VALUES (0,'NaN');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (1,'NaN');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (2,'7.53578122160797276459');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (3,'.63447727016073160075');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (4,'6.89206461372691743345');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (5,'4.21476541614777768626');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (6,'4.97267288886207207671');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (7,'7.91922711353275546914');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (8,'4.87437163556421004138');
---END---
---START---
INSERT INTO num_exp_log10 VALUES (9,'7.39666659961986567059');
---END---
---START---
COMMIT TRANSACTION;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (0,'NaN');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (1,'NaN');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (2,'224790267919917955.13261618583642653184');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (3,'28.90266599445155957393');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (4,'7405685069594999.07733999469386277636');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (5,'5068226527.32127265408584640098');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (6,'281839893606.99372343357047819067');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (7,'1716699575118597095.42330819910640247627');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (8,'167361463828.07491320069016125952');
---END---
---START---
INSERT INTO num_exp_power_10_ln VALUES (9,'107511333880052007.04141124673540337457');
---END---
---START---
COMMIT TRANSACTION;
---END---
---START---
BEGIN TRANSACTION;
---END---
---START---
INSERT INTO num_data VALUES (0, '0');
---END---
---START---
INSERT INTO num_data VALUES (1, '0');
---END---
---START---
INSERT INTO num_data VALUES (2, '-34338492.215397047');
---END---
---START---
INSERT INTO num_data VALUES (3, '4.31');
---END---
---START---
INSERT INTO num_data VALUES (4, '7799461.4119');
---END---
---START---
INSERT INTO num_data VALUES (5, '16397.038491');
---END---
---START---
INSERT INTO num_data VALUES (6, '93901.57763026');
---END---
---START---
INSERT INTO num_data VALUES (7, '-83028485');
---END---
---START---
INSERT INTO num_data VALUES (8, '74881');
---END---
---START---
INSERT INTO num_data VALUES (9, '-24926804.045047420');
---END---
---START---
COMMIT TRANSACTION;
---END---
---START---
-- ******************************
-- * Create indices for faster checks
-- ******************************

CREATE UNIQUE INDEX num_exp_add_idx ON num_exp_add (id1, id2);
---END---
---START---
CREATE UNIQUE INDEX num_exp_sub_idx ON num_exp_sub (id1, id2);
---END---
---START---
CREATE UNIQUE INDEX num_exp_div_idx ON num_exp_div (id1, id2);
---END---
---START---
CREATE UNIQUE INDEX num_exp_mul_idx ON num_exp_mul (id1, id2);
---END---
---START---
CREATE UNIQUE INDEX num_exp_sqrt_idx ON num_exp_sqrt (id);
---END---
---START---
CREATE UNIQUE INDEX num_exp_ln_idx ON num_exp_ln (id);
---END---
---START---
CREATE UNIQUE INDEX num_exp_log10_idx ON num_exp_log10 (id);
---END---
---START---
CREATE UNIQUE INDEX num_exp_power_10_ln_idx ON num_exp_power_10_ln (id);
---END---
---START---
VACUUM ANALYZE num_exp_add;
---END---
---START---
VACUUM ANALYZE num_exp_sub;
---END---
---START---
VACUUM ANALYZE num_exp_div;
---END---
---START---
VACUUM ANALYZE num_exp_mul;
---END---
---START---
VACUUM ANALYZE num_exp_sqrt;
---END---
---START---
VACUUM ANALYZE num_exp_ln;
---END---
---START---
VACUUM ANALYZE num_exp_log10;
---END---
---START---
VACUUM ANALYZE num_exp_power_10_ln;
---END---
---START---
-- ******************************
-- * Now check the behaviour of the NUMERIC type
-- ******************************

-- ******************************
-- * Addition check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, t1.val + t2.val
    FROM num_data t1, num_data t2;
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, t2.expected
    FROM num_result t1, num_exp_add t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != t2.expected;
---END---
---START---
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, round(t1.val + t2.val, 10)
    FROM num_data t1, num_data t2;
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, round(t2.expected, 10) as expected
    FROM num_result t1, num_exp_add t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != round(t2.expected, 10);
---END---
---START---
-- ******************************
-- * Subtraction check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, t1.val - t2.val
    FROM num_data t1, num_data t2;
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, t2.expected
    FROM num_result t1, num_exp_sub t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != t2.expected;
---END---
---START---
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, round(t1.val - t2.val, 40)
    FROM num_data t1, num_data t2;
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, round(t2.expected, 40)
    FROM num_result t1, num_exp_sub t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != round(t2.expected, 40);
---END---
---START---
-- ******************************
-- * Multiply check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, t1.val * t2.val
    FROM num_data t1, num_data t2;
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, t2.expected
    FROM num_result t1, num_exp_mul t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != t2.expected;
---END---
---START---
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, round(t1.val * t2.val, 30)
    FROM num_data t1, num_data t2;
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, round(t2.expected, 30) as expected
    FROM num_result t1, num_exp_mul t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != round(t2.expected, 30);
---END---
---START---
-- ******************************
-- * Division check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, t1.val / t2.val
    FROM num_data t1, num_data t2
    WHERE t2.val != '0.0';
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, t2.expected
    FROM num_result t1, num_exp_div t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != t2.expected;
---END---
---START---
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT t1.id, t2.id, round(t1.val / t2.val, 80)
    FROM num_data t1, num_data t2
    WHERE t2.val != '0.0';
---END---
---START---
SELECT t1.id1, t1.id2, t1.result, round(t2.expected, 80) as expected
    FROM num_result t1, num_exp_div t2
    WHERE t1.id1 = t2.id1 AND t1.id2 = t2.id2
    AND t1.result != round(t2.expected, 80);
---END---
---START---
-- ******************************
-- * Square root check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT id, 0, SQRT(ABS(val))
    FROM num_data;
---END---
---START---
SELECT t1.id1, t1.result, t2.expected
    FROM num_result t1, num_exp_sqrt t2
    WHERE t1.id1 = t2.id
    AND t1.result != t2.expected;
---END---
---START---
-- ******************************
-- * Natural logarithm check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT id, 0, LN(ABS(val))
    FROM num_data
    WHERE val != '0.0';
---END---
---START---
SELECT t1.id1, t1.result, t2.expected
    FROM num_result t1, num_exp_ln t2
    WHERE t1.id1 = t2.id
    AND t1.result != t2.expected;
---END---
---START---
-- ******************************
-- * Logarithm base 10 check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT id, 0, LOG(numeric '10', ABS(val))
    FROM num_data
    WHERE val != '0.0';
---END---
---START---
SELECT t1.id1, t1.result, t2.expected
    FROM num_result t1, num_exp_log10 t2
    WHERE t1.id1 = t2.id
    AND t1.result != t2.expected;
---END---
---START---
-- ******************************
-- * POWER(10, LN(value)) check
-- ******************************
DELETE FROM num_result;
---END---
---START---
INSERT INTO num_result SELECT id, 0, POWER(numeric '10', LN(ABS(round(val,200))))
    FROM num_data
    WHERE val != '0.0';
---END---
---START---
SELECT t1.id1, t1.result, t2.expected
    FROM num_result t1, num_exp_power_10_ln t2
    WHERE t1.id1 = t2.id
    AND t1.result != t2.expected;
---END---
---START---
-- ******************************
-- * Check behavior with Inf and NaN inputs.  It's easiest to handle these
-- * separately from the num_data framework used above, because some input
-- * combinations will throw errors.
-- ******************************

WITH v(x) AS
  (VALUES('0'::numeric),('1'),('-1'),('4.2'),('inf'),('-inf'),('nan'))
SELECT x1, x2,
  x1 + x2 AS sum,
  x1 - x2 AS diff,
  x1 * x2 AS prod
FROM v AS v1(x1), v AS v2(x2);
---END---
---START---
WITH v(x) AS
  (VALUES('0'::numeric),('1'),('-1'),('4.2'),('inf'),('-inf'),('nan'))
SELECT x1, x2,
  x1 / x2 AS quot,
  x1 % x2 AS mod,
  div(x1, x2) AS div
FROM v AS v1(x1), v AS v2(x2) WHERE x2 != 0;
---END---
---START---
SELECT 'inf'::numeric / '0';
---END---
---START---
SELECT '-inf'::numeric / '0';
---END---
---START---
SELECT 'nan'::numeric / '0';
---END---
---START---
SELECT '0'::numeric / '0';
---END---
---START---
SELECT 'inf'::numeric % '0';
---END---
---START---
SELECT '-inf'::numeric % '0';
---END---
---START---
SELECT 'nan'::numeric % '0';
---END---
---START---
SELECT '0'::numeric % '0';
---END---
---START---
SELECT div('inf'::numeric, '0');
---END---
---START---
SELECT div('-inf'::numeric, '0');
---END---
---START---
SELECT div('nan'::numeric, '0');
---END---
---START---
SELECT div('0'::numeric, '0');
---END---
---START---
WITH v(x) AS
  (VALUES('0'::numeric),('1'),('-1'),('4.2'),('-7.777'),('inf'),('-inf'),('nan'))
SELECT x, -x as minusx, abs(x), floor(x), ceil(x), sign(x), numeric_inc(x) as inc
FROM v;
---END---
---START---
WITH v(x) AS
  (VALUES('0'::numeric),('1'),('-1'),('4.2'),('-7.777'),('inf'),('-inf'),('nan'))
SELECT x, round(x), round(x,1) as round1, trunc(x), trunc(x,1) as trunc1
FROM v;
---END---
---START---
-- the large values fall into the numeric abbreviation code's maximal classes
WITH v(x) AS
  (VALUES('0'::numeric),('1'),('-1'),('4.2'),('-7.777'),('1e340'),('-1e340'),
         ('inf'),('-inf'),('nan'),
         ('inf'),('-inf'),('nan'))
SELECT substring(x::text, 1, 32)
FROM v ORDER BY x;
---END---
---START---
WITH v(x) AS
  (VALUES('0'::numeric),('1'),('4.2'),('inf'),('nan'))
SELECT x, sqrt(x)
FROM v;
---END---
---START---
SELECT sqrt('-1'::numeric);
---END---
---START---
SELECT sqrt('-inf'::numeric);
---END---
---START---
WITH v(x) AS
  (VALUES('1'::numeric),('4.2'),('inf'),('nan'))
SELECT x,
  log(x),
  log10(x),
  ln(x)
FROM v;
---END---
---START---
SELECT ln('0'::numeric);
---END---
---START---
SELECT ln('-1'::numeric);
---END---
---START---
SELECT ln('-inf'::numeric);
---END---
---START---
WITH v(x) AS
  (VALUES('2'::numeric),('4.2'),('inf'),('nan'))
SELECT x1, x2,
  log(x1, x2)
FROM v AS v1(x1), v AS v2(x2);
---END---
---START---
SELECT log('0'::numeric, '10');
---END---
---START---
SELECT log('10'::numeric, '0');
---END---
---START---
SELECT log('-inf'::numeric, '10');
---END---
---START---
SELECT log('10'::numeric, '-inf');
---END---
---START---
SELECT log('inf'::numeric, '0');
---END---
---START---
SELECT log('inf'::numeric, '-inf');
---END---
---START---
SELECT log('-inf'::numeric, 'inf');
---END---
---START---
WITH v(x) AS
  (VALUES('0'::numeric),('1'),('2'),('4.2'),('inf'),('nan'))
SELECT x1, x2,
  power(x1, x2)
FROM v AS v1(x1), v AS v2(x2) WHERE x1 != 0 OR x2 >= 0;
---END---
---START---
SELECT power('0'::numeric, '-1');
---END---
---START---
SELECT power('0'::numeric, '-inf');
---END---
---START---
SELECT power('-1'::numeric, 'inf');
---END---
---START---
SELECT power('-2'::numeric, '3');
---END---
---START---
SELECT power('-2'::numeric, '3.3');
---END---
---START---
SELECT power('-2'::numeric, '-1');
---END---
---START---
SELECT power('-2'::numeric, '-1.5');
---END---
---START---
SELECT power('-2'::numeric, 'inf');
---END---
---START---
SELECT power('-2'::numeric, '-inf');
---END---
---START---
SELECT power('inf'::numeric, '-2');
---END---
---START---
SELECT power('inf'::numeric, '-inf');
---END---
---START---
SELECT power('-inf'::numeric, '2');
---END---
---START---
SELECT power('-inf'::numeric, '3');
---END---
---START---
SELECT power('-inf'::numeric, '4.5');
---END---
---START---
SELECT power('-inf'::numeric, '-2');
---END---
---START---
SELECT power('-inf'::numeric, '-3');
---END---
---START---
SELECT power('-inf'::numeric, '0');
---END---
---START---
SELECT power('-inf'::numeric, 'inf');
---END---
---START---
SELECT power('-inf'::numeric, '-inf');
---END---
---START---
-- ******************************
-- * miscellaneous checks for things that have been broken in the past...
-- ******************************
-- numeric AVG used to fail on some platforms
SELECT AVG(val) FROM num_data;
---END---
---START---
SELECT MAX(val) FROM num_data;
---END---
---START---
SELECT MIN(val) FROM num_data;
---END---
---START---
SELECT STDDEV(val) FROM num_data;
---END---
---START---
SELECT VARIANCE(val) FROM num_data;
---END---
---START---
CREATE TABLE fract_only (gemini_pk serial PRIMARY KEY, id integer, val numeric(4, 4));
---END---
---START---
INSERT INTO fract_only VALUES (1, '0.0');
---END---
---START---
INSERT INTO fract_only VALUES (2, '0.1');
---END---
---START---
INSERT INTO fract_only VALUES (3, '1.0');
---END---
---START---
-- should fail
INSERT INTO fract_only VALUES (4, '-0.9999');
---END---
---START---
INSERT INTO fract_only VALUES (5, '0.99994');
---END---
---START---
INSERT INTO fract_only VALUES (6, '0.99995');
---END---
---START---
-- should fail
INSERT INTO fract_only VALUES (7, '0.00001');
---END---
---START---
INSERT INTO fract_only VALUES (8, '0.00017');
---END---
---START---
INSERT INTO fract_only VALUES (9, 'NaN');
---END---
---START---
INSERT INTO fract_only VALUES (10, 'Inf');
---END---
---START---
-- should fail
INSERT INTO fract_only VALUES (11, '-Inf');
---END---
---START---
-- should fail
SELECT * FROM fract_only;
---END---
---START---
DROP TABLE fract_only;
---END---
---START---
-- Check conversion to integers
SELECT (-9223372036854775808.5)::int8;
---END---
---START---
-- should fail
SELECT (-9223372036854775808.4)::int8;
---END---
---START---
-- ok
SELECT 9223372036854775807.4::int8;
---END---
---START---
-- ok
SELECT 9223372036854775807.5::int8;
---END---
---START---
-- should fail
SELECT (-2147483648.5)::int4;
---END---
---START---
-- should fail
SELECT (-2147483648.4)::int4;
---END---
---START---
-- ok
SELECT 2147483647.4::int4;
---END---
---START---
-- ok
SELECT 2147483647.5::int4;
---END---
---START---
-- should fail
SELECT (-32768.5)::int2;
---END---
---START---
-- should fail
SELECT (-32768.4)::int2;
---END---
---START---
-- ok
SELECT 32767.4::int2;
---END---
---START---
-- ok
SELECT 32767.5::int2;
---END---
---START---
-- should fail

-- Check inf/nan conversion behavior
SELECT 'NaN'::float8::numeric;
---END---
---START---
SELECT 'Infinity'::float8::numeric;
---END---
---START---
SELECT '-Infinity'::float8::numeric;
---END---
---START---
SELECT 'NaN'::numeric::float8;
---END---
---START---
SELECT 'Infinity'::numeric::float8;
---END---
---START---
SELECT '-Infinity'::numeric::float8;
---END---
---START---
SELECT 'NaN'::float4::numeric;
---END---
---START---
SELECT 'Infinity'::float4::numeric;
---END---
---START---
SELECT '-Infinity'::float4::numeric;
---END---
---START---
SELECT 'NaN'::numeric::float4;
---END---
---START---
SELECT 'Infinity'::numeric::float4;
---END---
---START---
SELECT '-Infinity'::numeric::float4;
---END---
---START---
SELECT '42'::int2::numeric;
---END---
---START---
SELECT 'NaN'::numeric::int2;
---END---
---START---
SELECT 'Infinity'::numeric::int2;
---END---
---START---
SELECT '-Infinity'::numeric::int2;
---END---
---START---
SELECT 'NaN'::numeric::int4;
---END---
---START---
SELECT 'Infinity'::numeric::int4;
---END---
---START---
SELECT '-Infinity'::numeric::int4;
---END---
---START---
SELECT 'NaN'::numeric::int8;
---END---
---START---
SELECT 'Infinity'::numeric::int8;
---END---
---START---
SELECT '-Infinity'::numeric::int8;
---END---
---START---
CREATE TABLE ceil_floor_round (gemini_pk serial PRIMARY KEY, a numeric);
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('-5.5');
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('-5.499999');
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('9.5');
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('9.4999999');
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('0.0');
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('0.0000001');
---END---
---START---
INSERT INTO ceil_floor_round VALUES ('-0.000001');
---END---
---START---
SELECT a, ceil(a), ceiling(a), floor(a), round(a) FROM ceil_floor_round;
---END---
---START---
DROP TABLE ceil_floor_round;
---END---
---START---
-- Check rounding, it should round ties away from zero.
SELECT i as pow,
	round((-2.5 * 10 ^ i)::numeric, -i),
	round((-1.5 * 10 ^ i)::numeric, -i),
	round((-0.5 * 10 ^ i)::numeric, -i),
	round((0.5 * 10 ^ i)::numeric, -i),
	round((1.5 * 10 ^ i)::numeric, -i),
	round((2.5 * 10 ^ i)::numeric, -i)
FROM generate_series(-5,5) AS t(i);
---END---
---START---
-- Testing for width_bucket(). For convenience, we test both the
-- numeric and float8 versions of the function in this file.

-- errors
SELECT width_bucket(5.0, 3.0, 4.0, 0);
---END---
---START---
SELECT width_bucket(5.0, 3.0, 4.0, -5);
---END---
---START---
SELECT width_bucket(3.5, 3.0, 3.0, 888);
---END---
---START---
SELECT width_bucket(5.0::float8, 3.0::float8, 4.0::float8, 0);
---END---
---START---
SELECT width_bucket(5.0::float8, 3.0::float8, 4.0::float8, -5);
---END---
---START---
SELECT width_bucket(3.5::float8, 3.0::float8, 3.0::float8, 888);
---END---
---START---
SELECT width_bucket('NaN', 3.0, 4.0, 888);
---END---
---START---
SELECT width_bucket(0::float8, 'NaN', 4.0::float8, 888);
---END---
---START---
SELECT width_bucket(2.0, 3.0, '-inf', 888);
---END---
---START---
SELECT width_bucket(0::float8, '-inf', 4.0::float8, 888);
---END---
---START---
CREATE TABLE width_bucket_test (gemini_pk serial PRIMARY KEY, operand_num numeric, operand_f8 float8);
---END---
---START---
COPY width_bucket_test (operand_num) FROM stdin;
-5.2
-0.0000000001
0.000000000001
1
1.99999999999999
2
2.00000000000001
3
4
4.5
5
5.5
6
7
8
9
9.99999999999999
10
10.0000000000001
\.
---END---
---START---
UPDATE width_bucket_test SET operand_f8 = operand_num::float8;
---END---
---START---
SELECT
    operand_num,
    width_bucket(operand_num, 0, 10, 5) AS wb_1,
    width_bucket(operand_f8, 0, 10, 5) AS wb_1f,
    width_bucket(operand_num, 10, 0, 5) AS wb_2,
    width_bucket(operand_f8, 10, 0, 5) AS wb_2f,
    width_bucket(operand_num, 2, 8, 4) AS wb_3,
    width_bucket(operand_f8, 2, 8, 4) AS wb_3f,
    width_bucket(operand_num, 5.0, 5.5, 20) AS wb_4,
    width_bucket(operand_f8, 5.0, 5.5, 20) AS wb_4f,
    width_bucket(operand_num, -25, 25, 10) AS wb_5,
    width_bucket(operand_f8, -25, 25, 10) AS wb_5f
    FROM width_bucket_test;
---END---
---START---
-- Check positive and negative infinity: we require
-- finite bucket bounds, but allow an infinite operand
SELECT width_bucket(0.0::numeric, 'Infinity'::numeric, 5, 10);
---END---
---START---
-- error
SELECT width_bucket(0.0::numeric, 5, '-Infinity'::numeric, 20);
---END---
---START---
-- error
SELECT width_bucket('Infinity'::numeric, 1, 10, 10),
       width_bucket('-Infinity'::numeric, 1, 10, 10);
---END---
---START---
SELECT width_bucket(0.0::float8, 'Infinity'::float8, 5, 10);
---END---
---START---
-- error
SELECT width_bucket(0.0::float8, 5, '-Infinity'::float8, 20);
---END---
---START---
-- error
SELECT width_bucket('Infinity'::float8, 1, 10, 10),
       width_bucket('-Infinity'::float8, 1, 10, 10);
---END---
---START---
DROP TABLE width_bucket_test;
---END---
---START---
-- Simple test for roundoff error when results should be exact
SELECT x, width_bucket(x::float8, 10, 100, 9) as flt,
       width_bucket(x::numeric, 10, 100, 9) as num
FROM generate_series(0, 110, 10) x;
---END---
---START---
SELECT x, width_bucket(x::float8, 100, 10, 9) as flt,
       width_bucket(x::numeric, 100, 10, 9) as num
FROM generate_series(0, 110, 10) x;
---END---
---START---
-- Another roundoff-error hazard
SELECT width_bucket(0, -1e100::numeric, 1, 10);
---END---
---START---
SELECT width_bucket(0, -1e100::float8, 1, 10);
---END---
---START---
SELECT width_bucket(1, 1e100::numeric, 0, 10);
---END---
---START---
SELECT width_bucket(1, 1e100::float8, 0, 10);
---END---
---START---
-- Check cases that could trigger overflow or underflow within the calculation
SELECT oper, low, high, cnt, width_bucket(oper, low, high, cnt)
FROM
  (SELECT 1.797e+308::float8 AS big, 5e-324::float8 AS tiny) as v,
  LATERAL (VALUES
    (10.5::float8, -big, big, 1),
    (10.5::float8, -big, big, 2),
    (10.5::float8, -big, big, 3),
    (big / 4, -big / 2, big / 2, 10),
    (10.5::float8, big, -big, 1),
    (10.5::float8, big, -big, 2),
    (10.5::float8, big, -big, 3),
    (big / 4, big / 2, -big / 2, 10),
    (0, 0, tiny, 4),
    (tiny, 0, tiny, 4),
    (0, 0, 1, 2147483647),
    (1, 1, 0, 2147483647)
  ) as sample(oper, low, high, cnt);
---END---
---START---
-- These fail because the result would be out of int32 range:
SELECT width_bucket(1::float8, 0, 1, 2147483647);
---END---
---START---
SELECT width_bucket(0::float8, 1, 0, 2147483647);
---END---
---START---
--
-- TO_CHAR()
--
SELECT to_char(val, '9G999G999G999G999G999')
	FROM num_data;
---END---
---START---
SELECT to_char(val, '9G999G999G999G999G999D999G999G999G999G999')
	FROM num_data;
---END---
---START---
SELECT to_char(val, '9999999999999999.999999999999999PR')
	FROM num_data;
---END---
---START---
SELECT to_char(val, '9999999999999999.999999999999999S')
	FROM num_data;
---END---
---START---
SELECT to_char(val, 'MI9999999999999999.999999999999999')     FROM num_data;
---END---
---START---
SELECT to_char(val, 'FMS9999999999999999.999999999999999')    FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM9999999999999999.999999999999999THPR') FROM num_data;
---END---
---START---
SELECT to_char(val, 'SG9999999999999999.999999999999999th')   FROM num_data;
---END---
---START---
SELECT to_char(val, '0999999999999999.999999999999999')       FROM num_data;
---END---
---START---
SELECT to_char(val, 'S0999999999999999.999999999999999')      FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM0999999999999999.999999999999999')     FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM9999999999999999.099999999999999') 	FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM9999999999990999.990999999999999') 	FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM0999999999999999.999909999999999') 	FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM9999999990999999.099999999999999') 	FROM num_data;
---END---
---START---
SELECT to_char(val, 'L9999999999999999.099999999999999')	FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM9999999999999999.99999999999999')	FROM num_data;
---END---
---START---
SELECT to_char(val, 'S 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 . 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9') FROM num_data;
---END---
---START---
SELECT to_char(val, 'FMS 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 . 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9 9') FROM num_data;
---END---
---START---
SELECT to_char(val, E'99999 "text" 9999 "9999" 999 "\\"text between quote marks\\"" 9999') FROM num_data;
---END---
---START---
SELECT to_char(val, '999999SG9999999999')			FROM num_data;
---END---
---START---
SELECT to_char(val, 'FM9999999999999999.999999999999999')	FROM num_data;
---END---
---START---
SELECT to_char(val, '9.999EEEE')				FROM num_data;
---END---
---START---
WITH v(val) AS
  (VALUES('0'::numeric),('-4.2'),('4.2e9'),('1.2e-5'),('inf'),('-inf'),('nan'))
SELECT val,
  to_char(val, '9.999EEEE') as numeric,
  to_char(val::float8, '9.999EEEE') as float8,
  to_char(val::float4, '9.999EEEE') as float4
FROM v;
---END---
---START---
WITH v(exp) AS
  (VALUES(-16379),(-16378),(-1234),(-789),(-45),(-5),(-4),(-3),(-2),(-1),(0),
         (1),(2),(3),(4),(5),(38),(275),(2345),(45678),(131070),(131071))
SELECT exp,
  to_char(('1.2345e'||exp)::numeric, '9.999EEEE') as numeric
FROM v;
---END---
---START---
WITH v(val) AS
  (VALUES('0'::numeric),('-4.2'),('4.2e9'),('1.2e-5'),('inf'),('-inf'),('nan'))
SELECT val,
  to_char(val, 'MI9999999999.99') as numeric,
  to_char(val::float8, 'MI9999999999.99') as float8,
  to_char(val::float4, 'MI9999999999.99') as float4
FROM v;
---END---
---START---
WITH v(val) AS
  (VALUES('0'::numeric),('-4.2'),('4.2e9'),('1.2e-5'),('inf'),('-inf'),('nan'))
SELECT val,
  to_char(val, 'MI99.99') as numeric,
  to_char(val::float8, 'MI99.99') as float8,
  to_char(val::float4, 'MI99.99') as float4
FROM v;
---END---
---START---
SELECT to_char('100'::numeric, 'FM999.9');
---END---
---START---
SELECT to_char('100'::numeric, 'FM999.');
---END---
---START---
SELECT to_char('100'::numeric, 'FM999');
---END---
---START---
SELECT to_char('12345678901'::float8, 'FM9999999999D9999900000000000000000');
---END---
---START---
-- Check parsing of literal text in a format string
SELECT to_char('100'::numeric, 'foo999');
---END---
---START---
SELECT to_char('100'::numeric, 'f\oo999');
---END---
---START---
SELECT to_char('100'::numeric, 'f\\oo999');
---END---
---START---
SELECT to_char('100'::numeric, 'f\"oo999');
---END---
---START---
SELECT to_char('100'::numeric, 'f\\"oo999');
---END---
---START---
SELECT to_char('100'::numeric, 'f"ool"999');
---END---
---START---
SELECT to_char('100'::numeric, 'f"\ool"999');
---END---
---START---
SELECT to_char('100'::numeric, 'f"\\ool"999');
---END---
---START---
SELECT to_char('100'::numeric, 'f"ool\"999');
---END---
---START---
SELECT to_char('100'::numeric, 'f"ool\\"999');
---END---
---START---
-- TO_NUMBER()
--
SET lc_numeric = 'C';
---END---
---START---
SELECT to_number('-34,338,492', '99G999G999');
---END---
---START---
SELECT to_number('-34,338,492.654,878', '99G999G999D999G999');
---END---
---START---
SELECT to_number('<564646.654564>', '999999.999999PR');
---END---
---START---
SELECT to_number('0.00001-', '9.999999S');
---END---
---START---
SELECT to_number('5.01-', 'FM9.999999S');
---END---
---START---
SELECT to_number('5.01-', 'FM9.999999MI');
---END---
---START---
SELECT to_number('5 4 4 4 4 8 . 7 8', '9 9 9 9 9 9 . 9 9');
---END---
---START---
SELECT to_number('.01', 'FM9.99');
---END---
---START---
SELECT to_number('.0', '99999999.99999999');
---END---
---START---
SELECT to_number('0', '99.99');
---END---
---START---
SELECT to_number('.-01', 'S99.99');
---END---
---START---
SELECT to_number('.01-', '99.99S');
---END---
---START---
SELECT to_number(' . 0 1-', ' 9 9 . 9 9 S');
---END---
---START---
SELECT to_number('34,50','999,99');
---END---
---START---
SELECT to_number('123,000','999G');
---END---
---START---
SELECT to_number('123456','999G999');
---END---
---START---
SELECT to_number('$1234.56','L9,999.99');
---END---
---START---
SELECT to_number('$1234.56','L99,999.99');
---END---
---START---
SELECT to_number('$1,234.56','L99,999.99');
---END---
---START---
SELECT to_number('1234.56','L99,999.99');
---END---
---START---
SELECT to_number('1,234.56','L99,999.99');
---END---
---START---
SELECT to_number('42nd', '99th');
---END---
---START---
RESET lc_numeric;
---END---
---START---
CREATE TABLE num_input_test (gemini_pk serial PRIMARY KEY, n1 numeric);
---END---
---START---
-- good inputs
INSERT INTO num_input_test(n1) VALUES (' 123');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('   3245874    ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('  -93853');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('555.50');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('-555.50');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('NaN ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('        nan');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' inf ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' +inf ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' -inf ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' Infinity ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' +inFinity ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' -INFINITY ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('12_000_000_000');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('12_000.123_456');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('23_000_000_000e-1_0');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('.000_000_000_123e1_0');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('.000_000_000_123e+1_1');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0b10001110111100111100001001010');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('  -0B_1010_1011_0101_0100_1010_1001_1000_1100_1110_1011_0001_1111_0000_1010_1101_0010  ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('  +0o112402761777 ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('-0O0012_5524_5230_6334_3167_0261');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('-0x0000000000000000000000000deadbeef');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' 0X_30b1_F33a_6DF0_bD4E_64DF_9BdA_7D15 ');
---END---
---START---
-- bad inputs
INSERT INTO num_input_test(n1) VALUES ('     ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('   1234   %');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('xyz');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('- 1234');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('5 . 0');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('5. 0   ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES (' N aN ');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('+NaN');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('-NaN');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('+ infinity');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('_123');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('123_');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('12__34');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('123_.456');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('123._456');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('1.2e_34');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('1.2e34_');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('1.2e3__4');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0b1112');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0c1112');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0o12345678');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0x1eg');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0x12.34');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0x__1234');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0x1234_');
---END---
---START---
INSERT INTO num_input_test(n1) VALUES ('0x12__34');
---END---
---START---
SELECT * FROM num_input_test;
---END---
---START---
-- Also try it with non-error-throwing API
SELECT pg_input_is_valid('34.5', 'numeric');
---END---
---START---
SELECT pg_input_is_valid('34xyz', 'numeric');
---END---
---START---
SELECT pg_input_is_valid('1e400000', 'numeric');
---END---
---START---
SELECT * FROM pg_input_error_info('1e400000', 'numeric');
---END---
---START---
SELECT pg_input_is_valid('1234.567', 'numeric(8,4)');
---END---
---START---
SELECT pg_input_is_valid('1234.567', 'numeric(7,4)');
---END---
---START---
SELECT * FROM pg_input_error_info('1234.567', 'numeric(7,4)');
---END---
---START---
SELECT * FROM pg_input_error_info('0x1234.567', 'numeric');
---END---
---START---
CREATE TABLE num_typemod_test (gemini_pk serial PRIMARY KEY, millions numeric(3, -6), thousands numeric(3, -3), units numeric(3, 0), thousandths numeric(3, 3), millionths numeric(3, 6));
---END---
---START---
\d num_typemod_test

-- rounding of valid inputs
INSERT INTO num_typemod_test VALUES (123456, 123, 0.123, 0.000123, 0.000000123);
---END---
---START---
INSERT INTO num_typemod_test VALUES (654321, 654, 0.654, 0.000654, 0.000000654);
---END---
---START---
INSERT INTO num_typemod_test VALUES (2345678, 2345, 2.345, 0.002345, 0.000002345);
---END---
---START---
INSERT INTO num_typemod_test VALUES (7654321, 7654, 7.654, 0.007654, 0.000007654);
---END---
---START---
INSERT INTO num_typemod_test VALUES (12345678, 12345, 12.345, 0.012345, 0.000012345);
---END---
---START---
INSERT INTO num_typemod_test VALUES (87654321, 87654, 87.654, 0.087654, 0.000087654);
---END---
---START---
INSERT INTO num_typemod_test VALUES (123456789, 123456, 123.456, 0.123456, 0.000123456);
---END---
---START---
INSERT INTO num_typemod_test VALUES (987654321, 987654, 987.654, 0.987654, 0.000987654);
---END---
---START---
INSERT INTO num_typemod_test VALUES ('NaN', 'NaN', 'NaN', 'NaN', 'NaN');
---END---
---START---
SELECT scale(millions), * FROM num_typemod_test ORDER BY millions;
---END---
---START---
-- invalid inputs
INSERT INTO num_typemod_test (millions) VALUES ('inf');
---END---
---START---
INSERT INTO num_typemod_test (millions) VALUES (999500000);
---END---
---START---
INSERT INTO num_typemod_test (thousands) VALUES (999500);
---END---
---START---
INSERT INTO num_typemod_test (units) VALUES (999.5);
---END---
---START---
INSERT INTO num_typemod_test (thousandths) VALUES (0.9995);
---END---
---START---
INSERT INTO num_typemod_test (millionths) VALUES (0.0009995);
---END---
---START---
--
-- Test some corner cases for multiplication
--

select 4790999999999999999999999999999999999999999999999999999999999999999999999999999999999999 * 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999;
---END---
---START---
select 4789999999999999999999999999999999999999999999999999999999999999999999999999999999999999 * 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999;
---END---
---START---
select 4770999999999999999999999999999999999999999999999999999999999999999999999999999999999999 * 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999;
---END---
---START---
select 4769999999999999999999999999999999999999999999999999999999999999999999999999999999999999 * 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999;
---END---
---START---
select trim_scale((0.1 - 2e-16383) * (0.1 - 3e-16383));
---END---
---START---
--
-- Test some corner cases for division
--

select 999999999999999999999::numeric/1000000000000000000000;
---END---
---START---
select div(999999999999999999999::numeric,1000000000000000000000);
---END---
---START---
select mod(999999999999999999999::numeric,1000000000000000000000);
---END---
---START---
select div(-9999999999999999999999::numeric,1000000000000000000000);
---END---
---START---
select mod(-9999999999999999999999::numeric,1000000000000000000000);
---END---
---START---
select div(-9999999999999999999999::numeric,1000000000000000000000)*1000000000000000000000 + mod(-9999999999999999999999::numeric,1000000000000000000000);
---END---
---START---
select mod (70.0,70);
---END---
---START---
select div (70.0,70);
---END---
---START---
select 70.0 / 70;
---END---
---START---
select 12345678901234567890 % 123;
---END---
---START---
select 12345678901234567890 / 123;
---END---
---START---
select div(12345678901234567890, 123);
---END---
---START---
select div(12345678901234567890, 123) * 123 + 12345678901234567890 % 123;
---END---
---START---
--
-- Test some corner cases for square root
--

select sqrt(1.000000000000003::numeric);
---END---
---START---
select sqrt(1.000000000000004::numeric);
---END---
---START---
select sqrt(96627521408608.56340355805::numeric);
---END---
---START---
select sqrt(96627521408608.56340355806::numeric);
---END---
---START---
select sqrt(515549506212297735.073688290367::numeric);
---END---
---START---
select sqrt(515549506212297735.073688290368::numeric);
---END---
---START---
select sqrt(8015491789940783531003294973900306::numeric);
---END---
---START---
select sqrt(8015491789940783531003294973900307::numeric);
---END---
---START---
--
-- Test code path for raising to integer powers
--

select 10.0 ^ -2147483648 as rounds_to_zero;
---END---
---START---
select 10.0 ^ -2147483647 as rounds_to_zero;
---END---
---START---
select 10.0 ^ 2147483647 as overflows;
---END---
---START---
select 117743296169.0 ^ 1000000000 as overflows;
---END---
---START---
-- cases that used to return inaccurate results
select 3.789 ^ 21.0000000000000000;
---END---
---START---
select 3.789 ^ 35.0000000000000000;
---END---
---START---
select 1.2 ^ 345;
---END---
---START---
select 0.12 ^ (-20);
---END---
---START---
select 1.000000000123 ^ (-2147483648);
---END---
---START---
select coalesce(nullif(0.9999999999 ^ 23300000000000, 0), 0) as rounds_to_zero;
---END---
---START---
select round(((1 - 1.500012345678e-1000) ^ 1.45e1003) * 1e1000);
---END---
---START---
-- cases that used to error out
select 0.12 ^ (-25);
---END---
---START---
select 0.5678 ^ (-85);
---END---
---START---
select coalesce(nullif(0.9999999999 ^ 70000000000000, 0), 0) as underflows;
---END---
---START---
-- negative base to integer powers
select (-1.0) ^ 2147483646;
---END---
---START---
select (-1.0) ^ 2147483647;
---END---
---START---
select (-1.0) ^ 2147483648;
---END---
---START---
select (-1.0) ^ 1000000000000000;
---END---
---START---
select (-1.0) ^ 1000000000000001;
---END---
---START---
-- integer powers of 10
select n, 10.0 ^ n as "10^n", (10.0 ^ n) * (10.0 ^ (-n)) = 1 as ok
from generate_series(-20, 20) n;
---END---
---START---
--
-- Tests for raising to non-integer powers
--

-- special cases
select 0.0 ^ 0.0;
---END---
---START---
select (-12.34) ^ 0.0;
---END---
---START---
select 12.34 ^ 0.0;
---END---
---START---
select 0.0 ^ 12.34;
---END---
---START---
-- NaNs
select 'NaN'::numeric ^ 'NaN'::numeric;
---END---
---START---
select 'NaN'::numeric ^ 0;
---END---
---START---
select 'NaN'::numeric ^ 1;
---END---
---START---
select 0 ^ 'NaN'::numeric;
---END---
---START---
select 1 ^ 'NaN'::numeric;
---END---
---START---
-- invalid inputs
select 0.0 ^ (-12.34);
---END---
---START---
select (-12.34) ^ 1.2;
---END---
---START---
-- cases that used to generate inaccurate results
select 32.1 ^ 9.8;
---END---
---START---
select 32.1 ^ (-9.8);
---END---
---START---
select 12.3 ^ 45.6;
---END---
---START---
select 12.3 ^ (-45.6);
---END---
---START---
-- big test
select 1.234 ^ 5678;
---END---
---START---
--
-- Tests for EXP()
--

-- special cases
select exp(0.0);
---END---
---START---
select exp(1.0);
---END---
---START---
select exp(1.0::numeric(71,70));
---END---
---START---
select exp('nan'::numeric);
---END---
---START---
select exp('inf'::numeric);
---END---
---START---
select exp('-inf'::numeric);
---END---
---START---
select coalesce(nullif(exp(-5000::numeric), 0), 0) as rounds_to_zero;
---END---
---START---
select coalesce(nullif(exp(-10000::numeric), 0), 0) as underflows;
---END---
---START---
-- cases that used to generate inaccurate results
select exp(32.999);
---END---
---START---
select exp(-32.999);
---END---
---START---
select exp(123.456);
---END---
---START---
select exp(-123.456);
---END---
---START---
-- big test
select exp(1234.5678);
---END---
---START---
--
-- Tests for generate_series
--
select * from generate_series(0.0::numeric, 4.0::numeric);
---END---
---START---
select * from generate_series(0.1::numeric, 4.0::numeric, 1.3::numeric);
---END---
---START---
select * from generate_series(4.0::numeric, -1.5::numeric, -2.2::numeric);
---END---
---START---
-- Trigger errors
select * from generate_series(-100::numeric, 100::numeric, 0::numeric);
---END---
---START---
select * from generate_series(-100::numeric, 100::numeric, 'nan'::numeric);
---END---
---START---
select * from generate_series('nan'::numeric, 100::numeric, 10::numeric);
---END---
---START---
select * from generate_series(0::numeric, 'nan'::numeric, 10::numeric);
---END---
---START---
select * from generate_series('inf'::numeric, 'inf'::numeric, 10::numeric);
---END---
---START---
select * from generate_series(0::numeric, 'inf'::numeric, 10::numeric);
---END---
---START---
select * from generate_series(0::numeric, '42'::numeric, '-inf'::numeric);
---END---
---START---
-- Checks maximum, output is truncated
select (i / (10::numeric ^ 131071))::numeric(1,0)
	from generate_series(6 * (10::numeric ^ 131071),
			     9 * (10::numeric ^ 131071),
			     10::numeric ^ 131071) as a(i);
---END---
---START---
-- Check usage with variables
select * from generate_series(1::numeric, 3::numeric) i, generate_series(i,3) j;
---END---
---START---
select * from generate_series(1::numeric, 3::numeric) i, generate_series(1,i) j;
---END---
---START---
select * from generate_series(1::numeric, 3::numeric) i, generate_series(1,5,i) j;
---END---
---START---
--
-- Tests for LN()
--

-- Invalid inputs
select ln(-12.34);
---END---
---START---
select ln(0.0);
---END---
---START---
-- Some random tests
select ln(1.2345678e-28);
---END---
---START---
select ln(0.0456789);
---END---
---START---
select ln(0.349873948359354029493948309745709580730482050975);
---END---
---START---
select ln(0.99949452);
---END---
---START---
select ln(1.00049687395);
---END---
---START---
select ln(1234.567890123456789);
---END---
---START---
select ln(5.80397490724e5);
---END---
---START---
select ln(9.342536355e34);
---END---
---START---
--
-- Tests for LOG() (base 10)
--

-- invalid inputs
select log(-12.34);
---END---
---START---
select log(0.0);
---END---
---START---
-- some random tests
select log(1.234567e-89);
---END---
---START---
select log(3.4634998359873254962349856073435545);
---END---
---START---
select log(9.999999999999999999);
---END---
---START---
select log(10.00000000000000000);
---END---
---START---
select log(10.00000000000000001);
---END---
---START---
select log(590489.45235237);
---END---
---START---
--
-- Tests for LOG() (arbitrary base)
--

-- invalid inputs
select log(-12.34, 56.78);
---END---
---START---
select log(-12.34, -56.78);
---END---
---START---
select log(12.34, -56.78);
---END---
---START---
select log(0.0, 12.34);
---END---
---START---
select log(12.34, 0.0);
---END---
---START---
select log(1.0, 12.34);
---END---
---START---
-- some random tests
select log(1.23e-89, 6.4689e45);
---END---
---START---
select log(0.99923, 4.58934e34);
---END---
---START---
select log(1.000016, 8.452010e18);
---END---
---START---
select log(3.1954752e47, 9.4792021e-73);
---END---
---START---
--
-- Tests for scale()
--

select scale(numeric 'NaN');
---END---
---START---
select scale(numeric 'inf');
---END---
---START---
select scale(NULL::numeric);
---END---
---START---
select scale(1.12);
---END---
---START---
select scale(0);
---END---
---START---
select scale(0.00);
---END---
---START---
select scale(1.12345);
---END---
---START---
select scale(110123.12475871856128);
---END---
---START---
select scale(-1123.12471856128);
---END---
---START---
select scale(-13.000000000000000);
---END---
---START---
--
-- Tests for min_scale()
--

select min_scale(numeric 'NaN') is NULL;
---END---
---START---
-- should be true
select min_scale(numeric 'inf') is NULL;
---END---
---START---
-- should be true
select min_scale(0);
---END---
---START---
-- no digits
select min_scale(0.00);
---END---
---START---
-- no digits again
select min_scale(1.0);
---END---
---START---
-- no scale
select min_scale(1.1);
---END---
---START---
-- scale 1
select min_scale(1.12);
---END---
---START---
-- scale 2
select min_scale(1.123);
---END---
---START---
-- scale 3
select min_scale(1.1234);
---END---
---START---
-- scale 4, filled digit
select min_scale(1.12345);
---END---
---START---
-- scale 5, 2 NDIGITS
select min_scale(1.1000);
---END---
---START---
-- 1 pos in NDIGITS
select min_scale(1e100);
---END---
---START---
-- very big number

--
-- Tests for trim_scale()
--

select trim_scale(numeric 'NaN');
---END---
---START---
select trim_scale(numeric 'inf');
---END---
---START---
select trim_scale(1.120);
---END---
---START---
select trim_scale(0);
---END---
---START---
select trim_scale(0.00);
---END---
---START---
select trim_scale(1.1234500);
---END---
---START---
select trim_scale(110123.12475871856128000);
---END---
---START---
select trim_scale(-1123.124718561280000000);
---END---
---START---
select trim_scale(-13.00000000000000000000);
---END---
---START---
select trim_scale(1e100);
---END---
---START---
--
-- Tests for SUM()
--

-- cases that need carry propagation
SELECT SUM(9999::numeric) FROM generate_series(1, 100000);
---END---
---START---
SELECT SUM((-9999)::numeric) FROM generate_series(1, 100000);
---END---
---START---
CREATE TABLE num_variance (gemini_pk serial PRIMARY KEY, a numeric);
---END---
---START---
INSERT INTO num_variance VALUES (0);
---END---
---START---
INSERT INTO num_variance VALUES (3e-500);
---END---
---START---
INSERT INTO num_variance VALUES (-3e-500);
---END---
---START---
INSERT INTO num_variance VALUES (4e-500 - 1e-16383);
---END---
---START---
INSERT INTO num_variance VALUES (-4e-500 + 1e-16383);
---END---
---START---
-- variance is just under 12.5e-1000 and so should round down to 12e-1000
SELECT trim_scale(variance(a) * 1e1000) FROM num_variance;
---END---
---START---
-- check that parallel execution produces the same result
BEGIN;
---END---
---START---
ALTER TABLE num_variance SET (parallel_workers = 4);
---END---
---START---
SET LOCAL parallel_setup_cost = 0;
---END---
---START---
SET LOCAL max_parallel_workers_per_gather = 4;
---END---
---START---
SELECT trim_scale(variance(a) * 1e1000) FROM num_variance;
---END---
---START---
ROLLBACK;
---END---
---START---
-- case where sum of squares would overflow but variance does not
DELETE FROM num_variance;
---END---
---START---
INSERT INTO num_variance SELECT 9e131071 + x FROM generate_series(1, 5) x;
---END---
---START---
SELECT variance(a) FROM num_variance;
---END---
---START---
-- check that parallel execution produces the same result
BEGIN;
---END---
---START---
ALTER TABLE num_variance SET (parallel_workers = 4);
---END---
---START---
SET LOCAL parallel_setup_cost = 0;
---END---
---START---
SET LOCAL max_parallel_workers_per_gather = 4;
---END---
---START---
SELECT variance(a) FROM num_variance;
---END---
---START---
ROLLBACK;
---END---
---START---
DROP TABLE num_variance;
---END---
---START---
--
-- Tests for GCD()
--
SELECT a, b, gcd(a, b), gcd(a, -b), gcd(-b, a), gcd(-b, -a)
FROM (VALUES (0::numeric, 0::numeric),
             (0::numeric, numeric 'NaN'),
             (0::numeric, 46375::numeric),
             (433125::numeric, 46375::numeric),
             (43312.5::numeric, 4637.5::numeric),
             (4331.250::numeric, 463.75000::numeric),
             ('inf', '0'),
             ('inf', '42'),
             ('inf', 'inf')
     ) AS v(a, b);
---END---
---START---
--
-- Tests for LCM()
--
SELECT a,b, lcm(a, b), lcm(a, -b), lcm(-b, a), lcm(-b, -a)
FROM (VALUES (0::numeric, 0::numeric),
             (0::numeric, numeric 'NaN'),
             (0::numeric, 13272::numeric),
             (13272::numeric, 13272::numeric),
             (423282::numeric, 13272::numeric),
             (42328.2::numeric, 1327.2::numeric),
             (4232.820::numeric, 132.72000::numeric),
             ('inf', '0'),
             ('inf', '42'),
             ('inf', 'inf')
     ) AS v(a, b);
---END---
---START---
SELECT lcm(9999 * (10::numeric)^131068 + (10::numeric^131068 - 1), 2);
---END---
---START---
-- overflow

--
-- Tests for factorial
--
SELECT factorial(4);
---END---
---START---
SELECT factorial(15);
---END---
---START---
SELECT factorial(100000);
---END---
---START---
SELECT factorial(0);
---END---
---START---
SELECT factorial(-4);
---END---
---START---
--
-- Tests for pg_lsn()
--
SELECT pg_lsn(23783416::numeric);
---END---
---START---
SELECT pg_lsn(0::numeric);
---END---
---START---
SELECT pg_lsn(18446744073709551615::numeric);
---END---
---START---
SELECT pg_lsn(-1::numeric);
---END---
---START---
SELECT pg_lsn(18446744073709551616::numeric);
---END---
---START---
SELECT pg_lsn('NaN'::numeric);
---END---
