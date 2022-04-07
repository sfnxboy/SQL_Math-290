# HW06
## Amir ElTabakh
## March 24, 2022

 1. Exercise
Make sure you can log in to [app.powerbi.com/](http://app.powerbi.com/). 

- Answer:

I have access to PowerBI using my personal information. I have all Microsoft applications, I pay annually to Microsoft.

 2. Exercise

In this exercise, you will download and import the TSV files into pre-created tables in Postgres. After you imported the tables, you will export them into CSV.

Step 1: Download the [IMDB database](https://datasets.imdbws.com/) files and unzip them.

- Answer: I have unzipped the folder and downloaded the files as `.gz` files. I then downloaded a software called "7-zip" which allows me to convert the file into a `.tsv`. I then had to change the security settings for these files by right-clicking, clocking "Edit..." under the "Security" tab, clicking "Add", typing "Everyone" in the text box, pressing "OK" and then applying all permissions. Changing these security settings grants databases the permission to read the files.

Step 2: Create a database called *IMDb* in your Postgre instance.
Use the `CREATE DATABASE` command to do this.

Step 3: Create your target tables in the public schema by consulting the [IMDB database documentation](https://www.imdb.com/interfaces/) page to obtain the column names. Only use the column names, *ignore* the corresponding datatypes. When building your target schema, use the **varchar** datatype. I have provided an example of how to do this for the **title.akas.tsv.gz** file in the **create_titile_akas.sql** file.  Complete and run the create table scripts for the other six tables.  

Step 4: Use the `COPY FROM` command to import **title.akas.tsv** into the `title_akas` table in the `imdb` database. Below is my example:

    copy  imdb.public.title_akas from 'C:\Users\balaz\Documents\Teaching\Spring 2021\MATH 2902\Lecture 7\imdb\title_akas.tsv\data.tsv' delimiter E'\t';

Build your own example for the rest of the `imdb` tables.
This step is completed once every table is populated with values.

Step 5: Take a look at your tables with a select statement and see if you notice something strange. Use the `DELETE` statement to correct the unintended row in each table. 
Hint: compare the column names and the values of the first row. 

Step 6: Use the `COPY TO` to export all your tables into CSV. Here is how to do it for the `title_akas` table.

    COPY title_akas(titleId, ordering, title, region, language, types, attributes, isOriginalTitle) 
    TO 'C:\Users\balaz\Documents\Teaching\Spring 2021\MATH 2902\Lecture 7\imdb\title.akas.tsv\title_akas.csv' DELIMITER ',' CSV HEADER;


- Answer: On step 5 we noticed that the first row of the Table on PostgreSQL was the table header in CSV format, so we had to delete the first row of each table. First I used the following code to delete the first row:

    `DELETE FROM imdb.public.akas where "ordering"  = "ordering";`

But this runs a conditional on all rows of the table, which is quite inefficient. So, we use the following code instead:

    `delete from imdb.public.akas where "titleId" in (select "titleId" from imdb.public.akas limit 1);`

For step 6 I wanted to save the csv files to a different folder than the folder that contains the `.tsv` files, so I changed the code accordingly. However, the folder did not actually exist on my computer, so I recieved an error. Only when I created the folder, would the code run properly.

3. Exercise

In this exercise, you will check the cardinality of each column, and based on this analysis and the IMDB database documentation; you will assign primary key constraints to each table. 

Step 1: Calculate the cardinality of each column in each table. 

Step 2: Pick a candidate primary key in each table based on your analysis (remember, you may have a composite primary key). Check your analysis against the [IMDB database documentation](https://www.imdb.com/interfaces/).

Step 3: Using the `ALTER TABLE` statement to add a primary key constraint to each table. Here is an example of how the `title_akas` table's composite primary key should be added.

    ALTER TABLE imdb.public.title_akas ADD PRIMARY KEY (titleId, ordering);

This step is completed once you added a primary key for every table.

- Answer: I used the `information_schema.tables` and `information_schema.columns` schemas with a common table texpression to filtered for the appropriate table schemas and table names to get the row counts of the tables and the distinct value counts of each column per those tables. We were not suprised when we found the columns names `tconst` or `nconst` to be the suitable candidates. We also looked at a few examples to see how would could use the Alter Table method to modify a table. After reading the [documentation](https://www.postgresql.org/docs/9.1/sql-altertable.html) and read up on the many attributes of the Alter Table query.

4. Exercise

In this exercise, you will learn how to detect foreign key relationships between two tables, and you will attempt to assign foreign key constraint to one of your tables.

Recall that to establish a primary key - foreign key relationship between two tables, all values of the child table's foreign key columns need to be represented in the parent table's primary key columns.

Example: Think about the student and the student interest tables in the class Google sheet. The student sheet is the parent table, and the student interest sheet is the child table. There shouldn't be a student interest that isn't associated with a particular student. If there were any, it would be a violation of the foreign key constraint.

Step 1: Use the `EXCEPT` set operation and count how many `tconst` values are presented in `imdb.public.title_ratings`
that aren't present in `imdb.public.title_basic`. 

Step 2: Calculate the same count but this time return the values of `tconst` column that are present in `imdb.public.title_basic`
but not in  `imdb.public.title_ratings`. 

Step 3: Use the `INTERSECT` operation to count how many records of `tconst` column show op in both `imdb.public.title_ratings` and `imdb.public.title_ratings` tables.

Step 4: Based on your analysis, which table should be the parent table and which table should be the child table?

Step 5: Attempt to use the `ALTER TABLE` statement to add a foreign key relationship between the two tables. 

Step 6: Did it work? Explain why or why not. 

- Answer: Regarding steps 5 and 6 we found that it did not work initially because there were three values in the `ratings` table that were not present in `title_basics`. So one could either add the values to the table where the values aren't present, or you could remove the values from the table where the values are present. Either way worked, we chose to add the values to the table where the values were not present because this method we are not losing data. Of course what is most important is that we are stating our assumptions.
