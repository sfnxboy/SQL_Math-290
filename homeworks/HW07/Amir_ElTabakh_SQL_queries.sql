/* Exercise 1 */
/* Steps 2, 3, 4 */

/* Title Basic */
create view imdb.public.etl_title_basic_v
as
select 
 "tconst"
,"titleType"
,"primaryTitle"
,"originalTitle"
,cast("isAdult" as boolean) as "isAdult"
,cast("startYear" as integer) as "startYear"
,cast("endYear" as integer) as "endYear"
,cast("runtimeMinues" as integer) as "runtimeMinutes"
,regexp_split_to_array("genres",',')::varchar[] as "genres"       
from imdb.public.basics;

create table imdb.public.xf_title_basic
as
select * from imdb.public.etl_title_basic_v;

alter table imdb.public.xf_title_basic add primary key (tconst);


/* Title Episode */
create view imdb.public.etl_title_episode_v
as
select 
 "tconst"
,"parentTconst"
,cast("seasonNumber" as integer) as "seasonNumber"
,cast("episodeNumber" as integer) as "episodeNumber"     
from imdb.public.episode;

create table imdb.public.xf_title_episode
as
select * from imdb.public.etl_title_episode_v;

alter table imdb.public.xf_title_episode add primary key (tconst);


/* Title Crew */
create view imdb.public.etl_title_crew_v
as
select 
 "tconst"
,regexp_split_to_array("directors",',')::varchar[] as "directors"  
,regexp_split_to_array("writers",',')::varchar[] as "writers"      
from imdb.public.crew;

create table imdb.public.xf_title_crew
as
select * from imdb.public.etl_title_crew_v;

alter table imdb.public.xf_title_crew add primary key (tconst);


/* Title Ratings */
create view imdb.public.etl_title_ratings_v
as
select 
 "tconst"
,cast("averageRating" as decimal) as "averageRating"
,cast("numVotes" as integer) as "numVotes"    
from imdb.public.ratings;

create table imdb.public.xf_title_ratings
as
select * from imdb.public.etl_title_ratings_v;

alter table imdb.public.xf_title_ratings add primary key (tconst);


/* Title name_basics */
UPDATE imdb.public.name_basics SET "deathYear"=NULL where "deathYear"='';
UPDATE imdb.public.name_basics SET "birthYear"=NULL where "birthYear"='';

create view imdb.public.etl_name_basics_v
as
select 
 "nconst"
,"primaryName"
,cast("birthYear" as integer) as "birthYear" 
,cast("deathYear" as integer) as "deathYear" 
,regexp_split_to_array("primaryProfession",',')::varchar[] as primaryProfession  
,regexp_split_to_array("knownForTitles",',')::varchar[] as knownForTitles       
from imdb.public.name_basics;

create table imdb.public.xf_name_basics
as
select * from imdb.public.etl_name_basics_v;

ALTER TABLE imdb.public.xf_name_basics ADD PRIMARY KEY (nconst);


/* Title Akas */
create view imdb.public.etl_title_akas_v
as
select 
 "titleId"
,cast("ordering" as integer) as "ordering" 
,"title"
,"region"
,"language"
,regexp_split_to_array("types",',')::varchar[] as "types"  
,regexp_split_to_array("attributes",',')::varchar[] as "attributes" 
,cast("isOriginalTitle" as boolean) as "isOriginalTitle"
from imdb.public.akas;

create table imdb.public.xf_title_akas
as
select * from imdb.public.etl_title_akas_v;

ALTER TABLE imdb.public.xf_title_akas ADD PRIMARY KEY ("titleId", ordering);


/* Title Principles */
create view imdb.public.etl_title_principals_v
as
select 
 "tconst"
,cast("ordering" as integer) as "ordering"
,"nconst"
,"category"
,"job"
,"characters"       
from imdb.public.principals;

create table imdb.public.xf_title_principals
as
select * from imdb.public.etl_title_principals_v;

alter table imdb.public.xf_title_principals ADD PRIMARY KEY (tconst, ordering);

/* I know delete all of the original tables*/
vacuum full;

/* Step 4 Foreign Keys */

alter table xf_title_ratings 
add constraint fk_xf_title_basic_ratings
foreign key(tconst)
references xf_title_basic(tconst);

/* I get errors for all others */


/* Exercise 2 */

/* Question 1 */
select
	avg("runtimeMinutes") as avgruntime
from
	imdb.public.xf_title_basic xtb
where
	"isAdult" = true;

/* Question 2 */
select
	count(tconst) as total
from
	imdb.public.xf_title_basic xtb
where
	"runtimeMinutes" >= 42
	and "runtimeMinutes" <= 77;

/* Question 4 */
select
	count(*)
from
	imdb.public.xf_title_basic
where
	"runtimeMinutes" = (
	select
		round (avg("runtimeMinutes"),
		0) 
as avgruntime
	from
		imdb.public.xf_title_basic
	where
		genres[1] = 'Action');

/* Question 5 */
WITH total_count AS(
  SELECT count(genres) AS cnt
  FROM xf_title_basic 
), individual_count AS (
  SELECT genres AS genre, count(genres) AS cnt
  FROM xf_title_basic 
  GROUP BY genres
)
SELECT ic.genre AS genre, ic.cnt/cast(tc.cnt AS real) AS freq
FROM individual_count AS ic CROSS JOIN total_count AS tc;

/* Exercise 3 */

/* step 1 */

select
	*
from 
	xf_title_basic xtb
full outer join xf_title_crew xtc 
on
	xtb.tconst = xtc.tconst ;

/* Step 2 */

select title_basics.tconst, count(title_crew.tconst) from imdb.public.xf_title_basics as title_basics
full outer join imdb.public.xf_title_crew as title_crew 
on title_basics.tconst = title_crew.tconst
group by title_basics.tconst


/* Step 3 */
select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_crew.tconst) as cardinal_total from imdb.public.xf_title_basics full outer join
imdb.public.xf_title_crew on imdb.public.xf_title_basics.tconst = imdb.public.xf_title_crew.tconst
group by imdb.public.xf_title_basics.tconst) as ct;

--max is 1 and min is 0, thus the cardinality is 1 to many


/* Step 4 */

select title_crew.tconst, count(title_basics.tconst) from imdb.public.xf_title_crew as title_crew
full outer join imdb.public.xf_title_basics as title_basics 
on title_crew.tconst = title_basics.tconst
group by title_crew.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_basics.tconst) as cardinal_total from imdb.public.xf_title_crew full outer join
imdb.public.xf_title_basics on imdb.public.xf_title_crew.tconst = imdb.public.xf_title_basics.tconst
group by imdb.public.xf_title_crew.tconst) as ct;
-- max is 3 and min is 1, cardinality is 1 to many


/* repeat with title_episode */
select * from imdb.public.xf_title_basics as title_basics full outer join imdb.public.xf_title_episode as title_episode
on title_basics.tconst = title_episode.tconst

select title_basics.tconst, count(title_episode.tconst) from imdb.public.xf_title_basics as title_basics
full outer join imdb.public.xf_title_episode as title_episode 
on title_basics.tconst = title_episode.tconst
group by title_basics.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_episode.tconst) as cardinal_total from imdb.public.xf_title_basics full outer join
imdb.public.xf_title_episode on imdb.public.xf_title_basics.tconst = imdb.public.xf_title_episode.tconst
group by imdb.public.xf_title_basics.tconst) as ct;
--max is 1 and min is 0, thus the cardinality is 1 to many

select title_episode.tconst, count(title_basics.tconst) from imdb.public.xf_title_episode as title_episode
full outer join imdb.public.xf_title_basics as title_basics 
on title_episode.tconst = title_basics.tconst
group by title_episode.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_basics.tconst) as cardinal_total from imdb.public.xf_title_episode full outer join
imdb.public.xf_title_basics on imdb.public.xf_title_episode.tconst = imdb.public.xf_title_basics.tconst
group by imdb.public.xf_title_episode.tconst) as ct;
-- max is 2,202,781 and min is 1, cardinality is 1 to many



/* repeat with title_principals */
select * from imdb.public.xf_title_basics as title_basics full outer join imdb.public.xf_title_principals as title_principals
on title_basics.tconst = title_principals.tconst

select title_basics.tconst, count(title_principals.tconst) from imdb.public.xf_title_basics as title_basics
full outer join imdb.public.xf_title_principals as title_principals 
on title_basics.tconst = title_principals.tconst
group by title_basics.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_principals.tconst) as cardinal_total from imdb.public.xf_title_basics full outer join
imdb.public.xf_title_principals on imdb.public.xf_title_basics.tconst = imdb.public.xf_title_principals.tconst
group by imdb.public.xf_title_basics.tconst) as ct;
-- max is 828 and min is 0, thus cardinality is 828 to many

select title_principals.tconst, count(title_basics.tconst) from imdb.public.xf_title_principals as title_principals
full outer join imdb.public.xf_title_basics as title_basics 
on title_principals.tconst = title_basics.tconst
group by title_principals.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_basics.tconst) as cardinal_total from imdb.public.xf_title_principals full outer join
imdb.public.xf_title_basics on imdb.public.xf_title_principals.tconst = imdb.public.xf_title_basics.tconst
group by imdb.public.xf_title_principals.tconst) as ct;

-- max is 871,717 and min is 1, cardinality is many to 1


/* repeat with title_ratings */
select * from imdb.public.xf_title_basics as title_basics full outer join imdb.public.xf_title_ratings as title_ratings
on title_basics.tconst = title_ratings.tconst

select title_basics.tconst, count(title_ratings.tconst) from imdb.public.xf_title_basics as title_basics
full outer join imdb.public.xf_title_ratings as title_ratings 
on title_basics.tconst = title_ratings.tconst
group by title_basics.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_ratings.tconst) as cardinal_total from imdb.public.xf_title_basics full outer join
imdb.public.xf_title_ratings on imdb.public.xf_title_basics.tconst = imdb.public.xf_title_ratings.tconst
group by imdb.public.xf_title_basics.tconst) as ct;


select title_ratings.tconst, count(title_basics.tconst) from imdb.public.xf_title_ratings as title_ratings
full outer join imdb.public.xf_title_basics as title_basics 
on title_ratings.tconst = title_basics.tconst
group by title_ratings.tconst

select min(cardinal_total) as minimum, max(cardinal_total) as maximum from (select count(imdb.public.xf_title_basics.tconst) as cardinal_total from imdb.public.xf_title_ratings full outer join
imdb.public.xf_title_basics on imdb.public.xf_title_ratings.tconst = imdb.public.xf_title_basics.tconst
group by imdb.public.xf_title_ratings.tconst) as ct;

-- max is 7,557,282 and min is 1, cardinality is many to 1