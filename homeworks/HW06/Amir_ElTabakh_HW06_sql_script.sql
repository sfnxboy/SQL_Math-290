/* Exercise 2 */
create database imdb;

create table imdb.public.akas (
	"titleId" varchar,
	"ordering" varchar,
	"title" varchar,
	"region" varchar,
	"language" varchar,
	"types" varchar,
	"attributes" varchar,
	"isOriginalTitle" varchar
);

create table imdb.public.basics (
	"tconst" varchar,
	"titleType" varchar,
	"primaryTitle" varchar,
	"originalTitle" varchar,
	"isAdult" varchar,
	"startYear" varchar,
	"endYear" varchar,
	"runtimeMinues" varchar,
	"genres" varchar
);

create table imdb.public.crew (
	"tconst" varchar,
	"directors" varchar,
	"writers" varchar
);

create table imdb.public.episode (
	"tconst" varchar,
	"parentTconst" varchar,
	"seasonNumber" varchar,
	"episodeNumber" varchar
);

create table imdb.public.principals (
	"tconst" varchar,
	"ordering" varchar,
	"nconst" varchar,
	"category" varchar,
	"job" varchar,
	"characters" varchar
);

create table imdb.public.ratings (
	"tconst" varchar,
	"averageRating" varchar,
	"numVotes" varchar
)

create table imdb.public.name_basics (
	"nconst" varchar,
	"primaryName" varchar,
	"birthYear" varchar,
	"deathYear" varchar,
	"primaryProfession" varchar,
	"knownForTitles" varchar
);

/* Copy Statements*/
copy  imdb.public.akas from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\title.akas.tsv' delimiter E'\t';

copy  imdb.public.basics from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\title.basics.tsv' delimiter E'\t';

copy  imdb.public.crew from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\title.crew.tsv' delimiter E'\t';

copy  imdb.public.episode from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\title.episode.tsv' delimiter E'\t';

/* I had to data transfer for the principals table below because the file was too large */
copy imdb.public.principals from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\title.principals.tsv' delimiter E'\t';

copy imdb.public.ratings from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\title.ratings.tsv' delimiter E'\t';

copy imdb.public.name_basics from 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\gz_files\name.basics.tsv' delimiter E'\t';


/* Select Statements */

select * from imdb.public.basics td;
select * from imdb.public.crew td;
select * from imdb.public.episode td;
select * from imdb.public.principals td;
select * from imdb.public.ratings td;
select * from imdb.public.name_basics td;

/* Deleting first row for each table */
/* Alternative
DELETE FROM imdb.public.akas where "ordering"  = "ordering";
DELETE FROM imdb.public.basics where "tconst"  = "tconst";
DELETE FROM imdb.public.crew where "tconst"  = "tconst";
DELETE FROM imdb.public.episode where "tconst"  = "tconst";
DELETE FROM imdb.public.name_basics where "nconst"  = "nconst";
DELETE FROM imdb.public.ratings where "tconst"  = "tconst"; 
*/

/* Deleting first row for each table */
delete from imdb.public.akas where "titleId" in (select "titleId" from imdb.public.akas limit 1);
delete from imdb.public.basics where tconst in (select tconst from imdb.public.basics limit 1);
delete from imdb.public.crew where tconst in (select tconst from imdb.public.crew limit 1);
delete from imdb.public.episode where tconst in (select tconst from imdb.public.episode limit 1);
delete from imdb.public.principals where tconst in (select tconst from imdb.public.principals limit 1);
delete from imdb.public.ratings where tconst in (select tconst from imdb.public.ratings limit 1);
delete from imdb.public.name_basics where nconst in (select nconst from imdb.public.name_basics limit 1);

/* Converting database objects to .csv files*/
COPY akas("titleId", ordering, title, region, language, types, attributes, "isOriginalTitle") 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\title_akas.csv' DELIMITER ',' CSV HEADER;

COPY basics(tconst, "titleType", "primaryTitle", "originalTitle", "isAdult", "startYear", "endYear", "runtimeMinues", genres) 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\title_basics.csv' DELIMITER ',' CSV HEADER;

COPY crew(tconst, directors, writers) 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\title_crew.csv' DELIMITER ',' CSV HEADER;

COPY episode(tconst, "parentTconst", "seasonNumber", "episodeNumber") 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\title_episode.csv' DELIMITER ',' CSV HEADER;

/* Error when importing TSV table into PostrgeSQL, skipping this table
COPY principals(tconst, ordering, nconst, category, job, characters) 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\title_principals.csv' DELIMITER ',' CSV HEADER;
*/

COPY ratings(tconst, "averageRating", "numVotes") 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\title_ratings.csv' DELIMITER ',' CSV HEADER;

COPY name_basics (nconst, "primaryName", "birthYear", "deathYear", "primaryProfession", "knownForTitles") 
TO 'C:\Users\amira\OneDrive\Documents\QC\Spring 22\SQL class\HW06\csv_files\name_basics.csv' DELIMITER ',' CSV HEADER;

/* Exercise 3.1 */

WITH tbl AS
  (SELECT table_schema,
          TABLE_NAME
   FROM information_schema.tables
   WHERE TABLE_NAME not like 'pg_%'
     AND table_schema in ('public'))
SELECT table_schema,
       TABLE_NAME,
       (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', table_schema, TABLE_NAME), FALSE, TRUE, '')))[1]::text::int AS rows_n
FROM tbl
ORDER BY rows_n DESC;

/* Exercise 3.2 */

WITH tbl AS
  (SELECT table_catalog,
          table_schema,
          TABLE_NAME,
          column_name
   FROM information_schema.columns
   WHERE TABLE_NAME not like 'pg_%'
     AND table_schema in ('public'))
SELECT table_schema,
       TABLE_NAME,
       (xpath('/row/c/text()', query_to_xml(format('select count(distinct %I) as distinct_column_name from %I.%I.%I', column_name, table_catalog, table_schema, TABLE_NAME), FALSE, TRUE, '')))[1]::text::int AS rows_n
FROM tbl
ORDER BY rows_n DESC;

/* Exercise 3.3 */

ALTER TABLE imdb.public.akas ADD PRIMARY KEY ("titleid", ordering);
ALTER TABLE imdb.public.basics ADD PRIMARY KEY (tconst);
ALTER TABLE imdb.public.crew ADD PRIMARY KEY (tconst);
ALTER TABLE imdb.public.episode ADD PRIMARY KEY (tconst);
ALTER TABLE imdb.public.principals ADD PRIMARY KEY (tconst, ordering);
ALTER TABLE imdb.public.ratings ADD PRIMARY KEY (tconst);
ALTER TABLE imdb.public.name_basics ADD PRIMARY KEY (nconst);

/* Exercise 4.1 and 4.2 */
select count(*) from (select "tconst" from title_ratings except select "tconst" from title_basics) as result;
--4


select "tconst" from (select "tconst" from title_ratings except select "tconst" from title_basics) as result;


select count(*) from (select "tconst" from title_basics  except select "tconst" from title_ratings) as result;
--7,557,282

--- insert the values of tconst that are in title_ratings and are not present in title_basics
insert into basics select * from ratings where tconst = 'tt10028954';
insert into basics select * from ratings where tconst = 'tt12021560';
insert into basics select * from ratings where tconst = 'tt12079134';


-- or delete them from title_ratings
DELETE FROM imdb.public.ratings WHERE tconst = 'tt10028954';
DELETE FROM imdb.public.ratings WHERE tconst = 'tt12021560';
DELETE FROM imdb.public.ratings WHERE tconst = 'tt12079134';
DELETE FROM imdb.public.ratings WHERE tconst = 'tt0000950';

select count(*) from (select "tconst" from title_ratings except select "tconst" from title_basics) as result;
--0

/* Exercise 4.3 */
select count(*) from (select "tconst" from title_basics  intersect select "tconst" from title_ratings) as result;


/* Exercise 4.1 and 4.5 */

alter table title_ratings 
add constraint fk_title_basics_ratings
foreign key (tconst)
references title_basics (tconst);
