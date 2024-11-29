create DATABASE portfolio;
USE portfolio;

SELECT top 1000 *
FROM dbo.udemy_courses_dataset;

-- Changing is_paid values from 1 and 0 to Y and N
ALTER TABLE dbo.udemy_courses_dataset
ADD paid VARCHAR(5);

UPDATE dbo.udemy_courses_dataset
SET paid = CASE WHEN is_paid = 1 then 'Y'
                WHEN is_paid = 0 then 'N'
                END;

ALTER TABLE dbo.udemy_courses_dataset
DROP COLUMN is_paid;

-- Splitting the published_timestamp column into two different columns with date and time.
SELECT STUFF(published_timestamp,11,0,' ') AS new_date
FROM dbo.udemy_courses_dataset;

ALTER TABLE dbo.udemy_courses_dataset
ADD new_date NVARCHAR(50),
    new_time NVARCHAR(50);

UPDATE dbo.udemy_courses_dataset
SET new_date = LEFT(published_timestamp, 10),
    new_time = SUBSTRING(published_timestamp, 12, LEN(published_timestamp));

SELECT top 10 *
FROM dbo.udemy_courses_dataset;

-- I still found out that the new_time column had 'Z' at the end. 
UPDATE dbo.udemy_courses_dataset
SET new_time = RTRIM(REPLACE(new_time,'Z', ''));

SELECT Top 10 *
FROM dbo.udemy_courses_dataset;

-- Now the issue is solved. Time to change new_date to date format
UPDATE dbo.udemy_courses_dataset
SET new_date = CONVERT(DATE, new_date, 120);

-- Checking the level of courses in the udemy dataset
SELECT distinct(level), count(level) as number_of_courses
FROM dbo.udemy_courses_dataset
Group by level
Order By count(level) desc;

-- Identifying top 10 courses based on number of reviews
SELECT top 10 course_title,
num_reviews
FROM dbo.udemy_courses_dataset
Order By num_reviews desc;

-- Top 5 highest priced courses
SELECT top 5 course_title,
price
FROM dbo.udemy_courses_dataset
Order By price desc;

-- Calculating average and standard deviation of course durations
SELECT avg(content_duration) as average,
       STDEV(content_duration) AS standard_deviation
FROM dbo.udemy_courses_dataset;

-- Calculating median duration using common table expression
With CTE AS (
    Select content_duration,
    ROW_NUMBER() over(Order by content_duration) as rn,
    count(*) Over() as total_rows
    FROM dbo.udemy_courses_dataset
)

SELECT AVG(content_duration) as median
FROM CTE
WHERE rn IN (
    FLOOR(total_rows/2),
    CEILING(total_rows/3)
);

-- Checking different course count based on subjects
SELECT subject, count(*) as course_count
FROM dbo.udemy_courses_dataset
Group by subject
Order by count(*) desc; 

-- Checking average price of courses in each subject
SELECT subject, avg(price) as average_price
FROM dbo.udemy_courses_dataset
Group by subject;

-- Calculating number of paid and free courses
SELECT paid, count(*) as count
FROM dbo.udemy_courses_dataset
Group by paid;

-- Checking popularity of paid and free courses based on number of subscribers
SELECT paid, avg(num_subscribers) as average_subscribers
FROM dbo.udemy_courses_dataset
Group By paid;

-- Checking course popularity (based on reviews) changes over time
SELECT YEAR(new_date) as year, 
sum(num_reviews) as total_reviews
FROM dbo.udemy_courses_dataset
Group By year(new_date)
Order By year(new_date);

-- Most popular year for publication of courses
SELECT YEAR(new_date) as year,
COUNT(course_title) as number_of_courses
FROM dbo.udemy_courses_dataset
Group By year(new_date)
Order By count(course_title) desc;

-- Relationship between the number of lectures and course duration
SELECT
SUM(CASE WHEN content_duration < 3 THEN num_subscribers ELSE 0 END) AS short_duration_lectures,
SUM(CASE WHEN content_duration BETWEEN 3 and 8 THEN num_subscribers ELSE 0 END) AS medium_duration_lectures,
SUM(CASE WHEN content_duration >8 THEN num_subscribers ELSE 0 END) AS long_duration_lectures
FROM dbo.udemy_courses_dataset;

-- Relationship between number of subscribers and course duration
SELECT
SUM(CASE WHEN content_duration < 3 THEN num_subscribers ELSE 0 END) AS short_duration_subscribers,
SUM(CASE WHEN content_duration BETWEEN 3 and 8 THEN num_subscribers ELSE 0 END) AS medium_duration_subscribers,
SUM(CASE WHEN content_duration >8 THEN num_subscribers ELSE 0 END) AS long_duration_subscribers
FROM dbo.udemy_courses_dataset;

