-- Data Wrangling, Analysis and AB Testing with SQL 

-- WEEK 1 DATA OF UNKNOWN QUANTITY

-- To create trustworthy analysis from a new set of data. 
-- You'll be able to coalesce some nulls and identify unreliable data and discover reasons why the data might be missing. 
-- You'll also be able to answer ambiguous questions by defining new metrics

-- ERROR CODES 

Exercise 1:
-- Goal: Here we use users table to pull a list of user email addresses. Edit the query to pull email
-- addresses, but only for non-deleted users.

Starter Code:
select id, email_address
from dsv1069.users
where deleted_at IS NULL;

Exercise 2:
-- Goal: Use the items table to count the number of items for sale in each category
select category, count(category)
from dsv1069.items
group by category;

Exercise 3:
-- Goal: Select all of the columns from the result when you JOIN the users table to the orders
select *
from dsv1069.users 
inner join dsv1069.orders
on users.id = orders.user_id;


Exercise 4:
-- Goal: Check out the query below. This is not the right way to count the number of viewed_item
-- events. Determine what is wrong and correct the error.

-- Starter Code:
SELECT
COUNT(event_id) AS events
FROM dsv1069.events
WHERE event_name = ‘view_item’

-- error says column "‘view_item’" does not exist because of the incorrect speach marks

SELECT
COUNT(event_id) AS events
FROM dsv1069.events
WHERE event_name = 'view_item';

Exercise 5:
-- Goal:Compute the number of items in the items table which have been ordered. 
-- The query below runs, but it isn’t right. Determine what is wrong and correct the error or start from scratch.
-- Starter Code:
SELECT
COUNT(item_id) as item_count
FROM dsv1069.orders
INNER JOIN dsv1069.items
ON orders.item_id = items.id 

47402
-- Error: This query runs but the number isn’t right
-- code is getting matching items id in order table to id in items table both are float data type inner join is correct join.
-- Code seems correct; only thing I can think of is using Distinct number of items not duplicate items
SELECT
COUNT(DISTINCT item_id) as item_count
FROM dsv1069.orders
INNER JOIN dsv1069.items
ON orders.item_id = items.id 
2198

Exercise 6:
-- Goal: For each user figure out IF a user has ordered something, and when their first purchase
-- was. The query below doesn’t return info for any of the users who haven’t ordered anything.
-- Starter Code:

SELECT
	users.id AS user_id,
	MIN(orders.paid_at) AS min_paid_at
FROM 
	dsv1069.orders
INNER JOIN 
	dsv1069.users
ON
	orders.user_id = users.id
GROUP BY 
	users.id

-- add in item_ordered and put this in the group by section
SELECT
	users.id AS user_id,
	MIN(orders.paid_at) AS min_paid_at,
	orders.item_name AS item_ordered
FROM dsv1069.orders
INNER JOIN dsv1069.users
ON orders.user_id = users.id
GROUP BY users.id, orders.item_name

Exercise 7:
-- Goal: Figure out what percent of users have ever viewed the user profile page, but this query
-- isn’t right. Check to make sure the number of users adds up, and if not, fix the query.
-- Starter Code:

SELECT
(CASE WHEN first_view IS NULL THEN false
		ELSE true END) AS has_viewed_profile_page,
COUNT(user_id) AS users
FROM
(SELECT
  USERS.ID AS user_id,
  MIN(event_time) AS first_view
FROM
	dsv1069.users
LEFT OUTER JOIN
	dsv1069.events
ON
	events.user_id = users.id
WHERE
	event_name = 'view_user_profile'
GROUP BY 
	users.id
	) first_profile_views
GROUP BY 
	(CASE WHEN first_view IS NULL THEN false
		ELSE true END)

-- subquery and case statement saying add extra column in output table called has_viewed_profile_page which shows
-- false if first view is null, otherwise true if populated

select 
   100*( SELECT  count(distinct user_id) 
           FROM dsv1069.events e 
          WHERE e.event_name = 'view_user_profile')
   / ( SELECT count(*) FROM dsv1069.users) percentage

------------------------------------------------------------------------------------------------------------------------------------------
 -- SOLUTIONS

Q1
-- Goal: Here we use users table to pull a list of user email addresses. Edit the query to pull email
-- addresses, but only for non-deleted users.
select 
id AS user_id 
,email_address
from dsv1069.users
where deleted_at IS NULL;

Q2
-- Goal: Use the items table to count the number of items for sale in each category
select category, 
count(category)
from dsv1069.items
group by category;

Q3
-- Goal: Select all of the columns from the result when you JOIN the users table to the orders
select *
from dsv1069.users 
inner join dsv1069.orders
on users.id = orders.user_id;

Q4
-- Goal: Check out the query below. This is not the right way to count the number of viewed_item
-- events. Determine what is wrong and correct the error.
select 
event_id,
count (*)
from dsv1069.events
group by event_id;
-- we can see there is sometimes multiple rows for every event_id as count is >1
-- we need to account the number of distinct event_ids

SELECT
COUNT(DISTINCT event_id) AS events
FROM dsv1069.events
WHERE event_name = 'view_item';

Q5
-- Goal:Compute the number of items in the items table which have been ordered. 
-- The query below runs, but it isn’t right. Determine what is wrong and correct the error or start from scratch.

-- if we run the following code
select count(*) 
from dsv1069.items; 
-- answer is just over 2000 and the code we used before which is 

SELECT
COUNT(event_id) AS events
FROM dsv1069.events
WHERE event_name = 'view_item';
--reports over 500,000 items, this is too big

--use distinct to get correct number 
SELECT
COUNT(DISTINCT item_id) as item_count
FROM dsv1069.orders
INNER JOIN dsv1069.items
ON orders.item_id = items.id 

-- or just need to query from orders table as all item_id in the order table should be in item table and vice versa

select count(distinct item_id)
from dsv1069.orders;

Q6
-- Goal: For each user figure out IF a user has ordered something, and when their first purchase
-- was. The query below doesn’t return info for any of the users who haven’t ordered anything.

-- should get some users who don't order anything (window shoppers) so use LEFT OUTER JOIN but this only
-- gets a few thousand rows returned

SELECT
	users.id AS user_id,
	MIN(orders.paid_at) AS min_paid_at
FROM 
	dsv1069.orders
LEFT OUTER JOIN 
	dsv1069.users
ON
	orders.user_id = users.id
GROUP BY 
	users.id

-- orders is the smaller table in comparison to users so we need to use user table and then join orders table
-- we use LEFT OUTER JOIN which takes everything from left table even unmatched pairs as well as inner join i.e. matched pairs
 SELECT
	users.id AS user_id,
	MIN(orders.paid_at) AS min_paid_at
FROM 
	dsv1069.users
LEFT OUTER JOIN 
	dsv1069.orders
ON
	orders.user_id = users.id
GROUP BY 
	users.id

-- note right outer join would also work in the below query where we have from orders as the left table
 SELECT
	users.id AS user_id,
	MIN(orders.paid_at) AS min_paid_at
FROM 
	dsv1069.orders
RIGHT OUTER JOIN 
	dsv1069.users
ON
	orders.user_id = users.id
GROUP BY 
	users.id

Q7
Exercise 7:
-- Goal: Figure out what percent of users have ever viewed the user profile page, but this query
-- isn’t right. Check to make sure the number of users adds up, and if not, fix the query.
-- Starter Code:

SELECT
(CASE WHEN first_view IS NULL THEN false
		ELSE true END) AS has_viewed_profile_page,
COUNT(user_id) AS users
FROM
(SELECT
  USERS.ID AS user_id,
  MIN(event_time) AS first_view
FROM
	dsv1069.users
LEFT OUTER JOIN
	dsv1069.events
ON
	events.user_id = users.id
WHERE
	event_name = 'view_user_profile'
GROUP BY 
	users.id
	) first_profile_views
GROUP BY 
	(CASE WHEN first_view IS NULL THEN false
		ELSE true END)

-- only get True and number of users
-- LEFT OUTER JOIN is correct given we are using user table first so we need everything from that table
-- problem is in the WHERE clause after left outer join you are essentially making an inner join
-- on a table where all event names are view user profile
-- simply change WHERE clause to AND cocndition i.e. included in the join and not after

SELECT
(CASE WHEN first_view IS NULL THEN false
		ELSE true END) AS has_viewed_profile_page,
COUNT(user_id) AS users
FROM
(SELECT
  USERS.ID AS user_id,
  MIN(event_time) AS first_view
FROM
	dsv1069.users
LEFT OUTER JOIN
	dsv1069.events
ON
	events.user_id = users.id
AND
	event_name = 'view_user_profile'
GROUP BY 
	users.id
	) first_profile_views
GROUP BY 
	(CASE WHEN first_view IS NULL THEN false
		ELSE true END)

-------------------------------------------------------------------------------------------------------------------------------------

Exercise 1:
-- Goal: Write a query to format the view_item event into a table with the appropriate columns
-- Starter Code

--SELECT *
--FROM dsv1069.events
--WHERE event_name = 'view_item'

SELECT
	event_id,
	event_time,
	--event_name,
	user_id
	platform,
	--parameter_name,
	parameter_value as view_item
FROM
	dsv1069.events
WHERE
	event_name = 'view_item';

Exercise 2:
--Goal: Write a query to format the view_item event into a table with the appropriate columns
--(This replicates what we had in the slides, but it is missing a column)

SELECT
	event_id,
	event_time,
	user_id,
	platform,
	(CASE WHEN parameter_name = 'item_id' /*column where parameter_name = item_id then format parameter_value for item_id as integer*/
	THEN CAST(parameter_value AS INT)
	ELSE NULL 
	END) AS item_id
FROM
	dsv1069.events
WHERE
	event_name = 'view_item'
ORDER BY event_id;
--i.e. parameter_name = item_id, parameter_value is 5673 whihc is the item that the customer looked at

Exercise 3
-- add in referrer as a parameter name
SELECT
	event_id,
	event_time,
	user_id,
	platform,
	(CASE WHEN parameter_name = 'item_id'
	THEN CAST(parameter_value AS INT)
	ELSE NULL 
	END) AS item_id,
	(CASE WHEN parameter_name = 'referrer'
	THEN parameter_value
	ELSE NULL 
	END) AS referrer
FROM
	dsv1069.events
WHERE
	event_name = 'view_item'
ORDER BY event_id;

--create column referrer which shows paramater value for rows that have parameter name as referrer
-- i.e. the referrer name is the parameter name associated with referrer i.e. (paramter name = referrer, parametr value = home)
------------------------------------------------------------------------------------------------------------------------------------------------
IDENTIFYING UNRELIABLE DATA 

Exercise 1: 
--Using any methods you like determine if you can you trust this events table.

-- using any methods determine if you can trust this events table
select *
from dsv1069.events_201701

--table has a date so won't be useful if searching for other periods

select EXTRACT(YEAR FROM event_time) as event_YEAR
from dsv1069.events_201701
WHERE EXTRACT(YEAR FROM event_time) != 2017;

-- no resutls selected so all data is in 2017

select 
SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS event_id,
SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END) AS event_name,
SUM(CASE WHEN event_time IS NULL THEN 1 ELSE 0 END) AS event_time,
SUM(CASE WHEN parameter_name IS NULL THEN 1 ELSE 0 END) AS parameter_name,
SUM(CASE WHEN parameter_value IS NULL THEN 1 ELSE 0 END) AS parameter_value,
SUM(CASE WHEN platform IS NULL THEN 1 ELSE 0 END) AS platform,
SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS user_id
from dsv1069.events_201701

-- no missing data

Exercise 2:
--Using any methods you like, determine if you can you trust this events table. (HINT: When did
--we start recording events on mobile)

select *
from dsv1069.events_ex2
order by event_time asc;

-- started recording event_time in Nov 2012 on mobile it was much later in 2016 shown by IOS and Android
-- would suggest you may need to aggregate for plaform in a specific timespan to answer platform count to compare

select platform,
count(*),
min(event_time)
from dsv1069.events_ex2
group BY platform

Exercise 3: 
--Imagine that you need to count item views by day. You found this table
--item_views_by_category_temp - should you use it to answer your question?

SELECT * 
FROM 
dsv1069.item_views_by_category_temp

-- dosen't have a timestamp field its just a summary but don't knwo when these items were viewed and by who, so no

Exercise 4: 
--sing any methods you like, decide if this table is ready to be used as a source of truth.

select * 
from dsv1069.raw_events
limit 100

-- this table does not exist?

Exercise 5: 
--Is this the right way to join orders to users? Is this the right way this join

select *
from dsv1069.orders
join dsv1069.users
on orders.user_id = users.parent_user_id

--parent_user_id
--parent_user_id missing 
-- parent_user_id is NULL when user has no other associated user id
-- should be joined on id first?

select *
from dsv1069.orders
    INNER JOIN dsv1069.users
    ON orders.user_id = (
    CASE WHEN users.id IS NULL
    THEN users.parent_user_id
    ELSE users.id
    END);


------------------------------------------------------------------------------------------------------------------------------------------------

IDENTIFYING UNRELIABLE DATA 
solutions

Q1)

-- using any methods determine if you can trust this events table
--select *
--from dsv1069.events_201701

SELECT
date(event_time) as date,
count(*) as rows
from dsv1069.events_201701
group by date(event_time);

-- 31 rows returned

Q2)

--Using any methods you like, determine if you can you trust this events table. (HINT: When did
-- we start recording events on mobile)

--select *
--from dsv1069.events_ex2
--order by event_time asc;


SELECT
date(event_time) as date,
platform,
count(*) 
from dsv1069.events_ex2
group by date(event_time), platform

--my solution is better 

Q3)

--Imagine that you need to count item views by day. You found this table
--item_views_by_category_temp - should you use it to answer your question?

select 
sum(view_events) as event_counts
from dsv1069.item_views_by_category_temp
--14481

--select 
--count(distinct event_id) as event_counts
--from dsv1069.events
--where event_name = 'view_item'

--262786 is > than temp table, we don't know when this table was created, temp suggests temp table

Q4)

--no table so no point in answering

Q5)
--Is this the right way to join orders to users? Is this the right way this join

 select count(*)
 from dsv1069.orders
 join dsv1069.users
 on orders.user_id = COALESCE(users.parent_user_id, users.id)
 --also include  cases where a user dosen't have a parent user id


------------------------------------------------------------------------------------------------------------------------------------------------

COUNTING USERS

Q1)
-- We’ll be using the users table to answer the question “How many new users are
-- added each day?“. Start by making sure you understand the columns in the table.

select * 
from dsv1069.users

-- created_at = user created date time
-- deleted_at - - user deleted datetime
-- email_address = user email address
-- first and last name = user name
-- id = user id
-- merged at = users who have a parent user id
-- parent_user_id = parent_user_id

Q2)
-- Without worrying about deleted user or merged users, count the number of users
-- added each day.

select 
date(created_at) as day,
count(*) as users
from dsv1069.users
group by date(created_at)

Q3)
-- Consider the following query. Is this the right way to count merged or deleted
--users? If all of our users were deleted tomorrow what would the result look like?

SELECT
date(created_at) as day,
count(*) as users
from dsv1069.users
where deleted_at IS NULL
and (id<>parent_user_id OR parent_user_id IS NULL)
group by date(created_at)

-- no to account for deleted users as we need deleted_at not null
-- merged data deleted we should have used merged variable

Q4)
--  Count the number of users deleted each day. Then count the number of users
-- removed due to merging in a similar way (Use the result from #2 as a guide)

select 
date(created_at) as day,
COUNT(deleted_at) AS deleted_users,
SUM(CASE WHEN deleted_At IS NOT NULL and merged_at IS NOT NULL THEN 1 ELSE 0 END) as delete_merge
from dsv1069.users
group by date(created_at)

Q5)
-- Use the pieces you’ve built as subtables and create a table that has a column for
--the date, the number of users created, the number of users deleted and the number of users
--merged that day.

select 
date(created_at) as date,
COUNT(*) as users_created,
SUM(CASE WHEN deleted_at IS NOT NULL then 1 ELSE 0 END) as deleted_users,
SUM(CASE WHEN parent_user_id IS NOT NULL then 1 ELSE 0 END) as merged
from dsv1069.users
group by date(created_at)
order by date(created_at) desc

Q6)
--Refine your query from #5 to have informative column names and so that null
--columns return 0.
--same code as precious query
select 
date(created_at) as date,
COUNT(*) as users_created,
SUM(CASE WHEN deleted_at IS NOT NULL then 1 ELSE 0 END) as deleted_users,
SUM(CASE WHEN parent_user_id IS NOT NULL then 1 ELSE 0 END) as merged
from dsv1069.users
group by date(created_at)
order by date(created_at) desc

Q7)
-- What if there were days where no users were created, but some users were deleted or merged.
--Does the previous query still work? No, it doesn’t. Use the dates_rollup as a backbone for this
--query, so that we won’t miss any dates.

--select 
--date(created_at) as date,
--COUNT(*) as users_created,
--SUM(CASE WHEN deleted_at IS NOT NULL then 1 ELSE 0 END) as deleted_users,
--SUM(CASE WHEN parent_user_id IS NOT NULL then 1 ELSE 0 END) as merged
--from dsv1069.users
--group by date(created_at)
--having COUNT(*) = 0

-- returned no results

select 
date(created_at) as date,
COUNT(*) as users_created,
SUM(CASE WHEN deleted_at IS NOT NULL then 1 ELSE 0 END) as deleted_users,
SUM(CASE WHEN parent_user_id IS NOT NULL then 1 ELSE 0 END) as merged
from dsv1069.users
FULL OUTER JOIN dsv1069.dates_rollup
ON dsv1069.users.created_at = dsv1069.dates_rollup.date
group by date(created_at)

------------------------------------------------------------------------------------------------------------------------------------------------
COUNTING USERS - SOLUTIONS

Q1)
SELECT 
id,
parent_user_id,
merged_at
from dsv1069.users
order by parent_user_id asc

-- can see user205 was merged into id 88435 happens in a bunch of pairs
-- need to subtract a user to count correctly as these are the same users (duplicate data)

Q2)
select 
date(created_at) as day,
count(*) as users
from dsv1069.users
group by date(created_at)

Q3)
SELECT
date(created_at) as day,
count(*) as users
from dsv1069.users
where deleted_at IS NULL
AND (id <> parent_user_id OR parent_user_id IS NULL)
group by date(created_at)

-- AND id <> parent_user_id as highlighted in Q1 solution to not double count users and count merged users as their parent_id will be different from id

Q4)
SELECT
date(created_at) as day,
count(*) as users
from dsv1069.users
where deleted_at IS NOT NULL
AND (id <> parent_user_id OR parent_user_id IS NULL)
group by date(created_at)

Q5)

select 
  new.day,
  new.new_users_added,
  deleted.deleted_users,
  merged.merged_users
from 
	(select 
		date(created_at) as day,
		count(*)         as new_users_added
	from dsv1069.users	
	group by date(created_at)
		) new
 LEFT JOIN 
	(select 
		date(created_at)  as day,
		count(*)          as deleted_users
	from dsv1069.users
	WHERE deleted_at IS NOT NULL
	group by date(created_at)
		) deleted
	ON deleted.day = new.day
	LEFT JOIN
		(select 
		date(created_at)  as day,
		count(*)          as merged_users
	from dsv1069.users
	WHERE parent_user_id <> id
	AND parent_user_id IS NOT NULL
	group by date(created_at)
		) merged
	ON merged.day = new.day
	
Q6 and Q7)

select 
  new.day,
  new.new_users_added,
  coalesce(deleted.deleted_users,0) AS deleted_users, /* coalesce ensures null value = 0 */
  coalesce(merged.merged_users,0) AS merged_users,
  (new.new_users_added - coalesce(deleted.deleted_users,0) - coalesce(merged.merged_users,0)) as new_added_users
from 
	(select 
		date(created_at) as day,
		count(*)         as new_users_added
	from dsv1069.users	
	group by date(created_at)
		) new
 LEFT JOIN 
	(select 
		date(created_at)  as day,
		count(*)          as deleted_users
	from dsv1069.users
	WHERE deleted_at IS NOT NULL
	group by date(created_at)
		) deleted
	ON deleted.day = new.day
	LEFT JOIN
		(select 
		date(created_at)  as day,
		count(*)          as merged_users
	from dsv1069.users
	WHERE parent_user_id <> id
	AND parent_user_id IS NOT NULL
	group by date(created_at)
		) merged
	ON merged.day = new.day


------------------------------------------------------------------------------------------------------------------------------------------------
--MODULE 1 END OF UNIT QUIZ

Q1)
 --what does this query count?
 SELECT
 COUNT(*)
 FROM dsv1069.users
 JOIN dsv1069.orders ON users.id = orders.user_id

 --A)Counts the number of rows in the orders table

Q2)
--Assume you have no information about the data in the example table.
--When I run the query below,  no rows are returned, but there are no error messages. What are possible reasons for this? (Select all that apply.)
SELECT *
FROM example_table
WHERE id IS NULL

-- A) There are no rows in the example_table - it's empty | There are no rows with a null id 

Q3)
--In the events table, (dsv1069.events) for this class, how many rows exist per event_id?
--A)One per parameter_name
select 
event_id,
count(*)
from dsv1069.events
group by event_id

Q4)
--When you encounter a new dataset, which of the following can you assume? (Select all that apply.)
--A)There are duplicate rows | The data is out-of-date | Test usage is unfiltered | The table is empty

Q5
--Based on your exploration of the tables in the course dataset. Why are the results to this specific query empty?
SELECT * 
FROM dsv1069.users
JOIN dsv1069.events
ON users.parent_user_id = evens.user_id
WHERE event_name = 'view_item'
AND merged_at IS NULL

--A)There are no parent_user_ids that satisfy the WHERE clause

Q6)
--Why are the results for this specific query empty? 

SELECT *
FROM dsv1069.events
WHERE event_name = 'item_view'
--A) There are no events with this event_name

Q7)
--What does this query do? Select all true statements.
SELECT COUNT(*)
FROM dsv1069.events
WHERE event_name = 'view_item'

--A) The query counts the number of rows corresponding to view_item events.

Q8)
--Consider the following query:

SELECT * 
FROM table_alpha
JOIN table_beta
ON table_alpha.key = table_beta.column

--What happens when some rows have a NULL value in the column table_alpha.key?

--A)Each row with a null value is joined to every row in table_beta where table_beta.column is null.

Q9)
-- Which of the following are problems with the query below?

SELECT
count(*)
FROM dsv1069.users
JOIN dsv1069.orders ON users.parent_user_id = orders.user_id

--A)Count(*) counts rows not unique users

Q10)
--In the users table, the column parent_user_id is __________________.
--A)Sometimes NULL

------------------------------------------------------------------------------------------------------------------------------------------------

-- WEEK 2 - Creating Clean Datasets Introduction

--BULK EDITING
--HOLD DOWN OPTION KEY AND DRAG DOWN TO DO BULK EDIT LIKE ADDING SUM FOR ALL OF THE QUERIES

SELECT
SUM(thing_1) AS thing_1
SUM(thing_2) AS thing_2
SUM(thing_3) AS thing_3
SUM(thing_4) AS thing_4
FROM example_table

Q1)
--Which of the following is easier to read?
--A)
SELECT 

  column_1, 

  column_2, 

  count(*)

FROM 

  example_table 

WHERE

 column_3 is not null 

GROUP BY

  column_1, 

  column_2 

Q2)
--Suppose in a table you find a column called username, which contains the value kat123. What is the correct data type category for this column?
--A) STRINT

Q3)
-- Suppose in a table you find a column called price, which contains the value $9.99. What is the best data type category for this column?
--A) NUMBER

Q4)
--Suppose in a table you find a column called created_at, which contains the value 2019-01-01. What is the best data type category for this column?
--A) date

Q5)
--Suppose in a table you find a column called price, which contains the value $9.99. Of the following options, which is the best data type for this column?
--A) FLOAT

------------------------------------------------------------------------------------------------------------------------------------------------

--make view_item table

CREATE TABLE 'view_item_events' (
event_id 		VARCHAR(32) NOT NULL PRIMARY KEY,
event_time 	VARCHAR(26), 
user_id 		VARCHAR(10), 
platform 		VARCHAR(10), 
item_id 		VARCHAR(10), 
referrer 		VARCHAR(17) 
);

INSERT INTO 'view_item_events'

select 
	event_id,
	TIMESTAMP(event_time) AS event_time,
	user_id,
	platform,
MAX(CASE WHEN parameter_name = 'item_id' THEN parameter_value ELSE NLL END) AS item_id
MAX(CASE WHEN parameter_name = 'referrer' THEN parameter_value ELSE NLL END) AS referrer
FROM events
WHERE event_name = 'view_item'
GROUP BY 
	event_id,
	event_time,
	user_id,
	platform,
ORDER BY event_id

------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE USER SNAPSHOT TABLE
{% assign ds = '2018-01-01 %'} /*day in question so we assignining the ds variable a date*/

SELECT users.id 																									AS user_id,
IF(users.created_at 								= 						'{{ds}}', 1, 0)	AS created_today,
IF(users.deleted_at 								<=						'{{ds}}', 1, 0)	AS is_deleted,
IF(users.deleted_at 								=							'{{ds}}', 1, 0)	AS is_deleted_today,
IF(users_with_orders.user_id  			IS NOT NULL	, 					1, 0)	AS has_ever_ordered, /* user_id is not null then 1 otherwise 0 */
IF(users_with_orders_today.user_id 	IS NOT NULL , 					1, 0)	AS ordered_today,
'{{ds}} '																													AS ds
FROM users

LEFT OUTER JOIN(
	SELECT DISTINCT user_id /* take all distinct user_id from orders where orders created at date before date so it gives cusotmers whoever has ordered */
	FROM orders
WHERE
	created_at <= '{{ds}}'
) users_with_orders
ON users_with_orders.user_id = users.id 

LEFT OUTER JOIN (
	SELECT
		DISTINCT user_id
	FROM  orders
	WHERE created_at = '{{ds}}'
	) users_with_orders_today
ON users_with_orders_today.user_id = users.id
WHERE users_created <= '{{ds}}'

-- CREATE TABLE
-- no PK for this table because users are going to show up once for every day they've existed
CREATE TABLE IF NOT EXISTS user_info(
	user_id 					INT(10) NOT NULL,
	created_today			INT(1)  NOT NULL,
	is_deleted 				INT(1)  NOT NULL,
	is_deleted_today	INT(1)  NOT NULL,
	has_ever_ordered	INT(1)  NOT NULL,
	ordered_today			INT(1)  NOT NULL,
	ds 								DATE 		NOT NULL
);

describe user_info


--INSERT INTO THE TABLE
{% assign ds = '2018-01-01 %'} /*day in question so we assignining the ds variable a date*/

INSERT INTO
	user_info

SELECT users.id 																									AS user_id,
IF(users.created_at 								= 						'{{ds}}', 1, 0)	AS created_today,
IF(users.deleted_at 								<=						'{{ds}}', 1, 0)	AS is_deleted,
IF(users.deleted_at 								=							'{{ds}}', 1, 0)	AS is_deleted_today,
IF(users_with_orders.user_id  			IS NOT NULL	, 					1, 0)	AS has_ever_ordered, /* user_id is not null then 1 otherwise 0 */
IF(users_with_orders_today.user_id 	IS NOT NULL , 					1, 0)	AS ordered_today,
'{{ds}} '																													AS ds
FROM users

LEFT OUTER JOIN(
	SELECT DISTINCT user_id /* take all distinct user_id from orders where orders created at date before date so it gives cusotmers whoever has ordered */
	FROM orders
WHERE
	created_at <= '{{ds}}'
) users_with_orders
ON users_with_orders.user_id = users.id 

LEFT OUTER JOIN (
	SELECT
		DISTINCT user_id
	FROM  orders
	WHERE created_at = '{{ds}}'
	) users_with_orders_today
ON users_with_orders_today.user_id = users.id
WHERE users_created <= '{{ds}}'

------------------------------------------------------------------------------------------------------------------------------------------------
--END OF UNIT QUIZ

Q1)
--Which step should happen first in data analysis?

--A)Collecting Data

Q2)
--Kat ran 9 lines of MySQL (finished in 112ms):

--------------

CREATE TABLE 

example_table

(

column1  DATE, 

column2  VARCHAR(30),

column3  INT

)

--------------

ERROR 1050 (42S01) at line 1: Table 'example_table' already exists

Bye

mysql> 

--A) Run DESCRIBE TABLE example_table to see if the existing example_table is structured appropriately

Q3)
--Based on the code snippet below, which statements are definitely true (select all that apply): 
CREATE TABLE table_x AS

SELECT 

  dates_rollup.date, 

  COUNT(*)

FROM 

  Dates_rollup

JOIN 

  Table_y

ON 

 dates_rollup.date = table_y.date

GROUP BY 

  date

--A) table_x is dependent on table_y and dates_rollup | table_x is dependent on table_y

Q4)
--Based on what you know about the orders table for this class, which of the following columns have a suitable datatype?

--user_id | invoice_id | item_name

Q5)
--For this class, we are using Mode on a dataset specifically created for this course. Which of these circumstances could be different in a real world situation? (Select all that apply.)

-- The specific dialect of SQL | How frequently the data is updated

Q6)
-- Based on what you know about the items table for this class, which of the following columns have a suitable datatype? (Select all that apply.)
--CATEGORY | NAME

Q7)
-- Which of the following table methods allows you to specify data types?
CREATE TABLE    

  example_table 

  (column_name1 ….)

Q8)
--When creating a user info table we used a variable in place of which column?
--A) THE DATE

Q9)
--Suppose in a table, you find a column called email which contains the value user@domain.com. What is the correct data type category for this column?
--A) STRING

Q10)
--In this module, we created a table specifically of item view events. What level of the hierarchy of data does this belong on?
--A) EXPLORE AND TRANSFORM

Q11)
--Suppose in a table you find a column called event_id, which contains the value z87df6ab4waoa756b3. What is the correct data type category for this column?
--A) STRING

------------------------------------------------------------------------------------------------------------------------------------------------

-- WEEK 3 - SQL PROBLEM SOLVING

-- goal of this section is to map out your joins and highlight the level of detail needed for different kinds of questions

--reorder and ocnnect tables quiz

Q1) 
--Question 1
--Let’s suppose we want to write a query to answer both of these questions: How many items have been purchased?,How many items do we have?
--Please choose the best set of columns for a final query that would answer these questions:

Item_count

Items_ever_purchased_count

Q2)
--Please select all tables that will be necessary answer both of these questions:How many items have been purchased? How many items do we have?
--orders 
--items

Q3)
--We’ve decided to only use the items and orders tables to answer the following questions:How many items have been purchased?How many items do we have?
--Can we compute the columns Items_count, items_ever_purchased_count without a subquery?
--YES

Q4)
--How many items have been purchased? How many items do we have?
--Which of the following queries will answer both those questions without further computation?

SELECT 

  COUNT(DISTINCT items.id)       

AS items_count,

  COUNT(DISTINCT orders.item_id) 

AS items_ever_purchased_count

FROM  

  dsv1069.items

LEFT OUTER JOIN

  dsv1069.orders

ON 

  items.id = orders.item

Q5)
--In the previous question we decided that the query below could answer the questions :
--How many items have been purchased? How many items do we have?

SELECT 

  COUNT(DISTINCT items.id)       AS items_count,

  COUNT(DISTINCT orders.item_id) AS items_ever_purchased_count

FROM  

  dsv1069.items

LEFT OUTER JOIN

  dsv1069.orders

ON 

  items.id = orders.item

--Is this the only possible way to answer the question? Justify your answer.
--No we can use a subquery , where we can do the filtering by distinct for each of the columns that we need in teh subquery and do the LEFT OUTER JOIN to connect the tables


------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE A ROLLUP TABLE

Q1)

-- Create a subtable of orders per day. Make sure you decide whether you are counting invoices or line items.
-- we can see that line_item_id is nested in invice_id i.e. user_id 50878 corresponding to invoice_id 20 bought 3 different items
--create table to count ordered items
select date(paid_at)          AS date_paid, 
count(distinct invoice_id)    AS orders_count,
count(distinct line_item_id)  AS item_count
from dsv1069.orders
group by date(paid_at) 


Q2)
--“Check your joins”. We are still trying to count orders per day. In this step join the
--sub table from the previous exercise to the dates rollup table so we can get a row for every
--date. Check that the join works by just running a “select *” query

--join on rollup table

select *
from dsv1069.dates_rollup 
LEFT OUTER JOIN
(
select date(paid_at)          AS date_paid, 
count(distinct invoice_id)    AS orders_count,
count(distinct line_item_id)  AS item_count
from dsv1069.orders
group by date(paid_at) 
) daily_orders
ON daily_orders.date_paid = dates_rollup.date

Q3)
--“Clean up your Columns” In this step be sure to specify the columns you actually
--want to return, and if necessary do any aggregation needed to get a count of the orders made
--per day.

--add in extra columns that we want to see anf clean up query

select 
dates_rollup.date,
COALESCE(sum(orders_count))   AS orders,
COALESCE(sum(item_count))     AS items_ordered
from dsv1069.dates_rollup 
LEFT OUTER JOIN
(
select 
date(paid_at)                 AS date_paid, 
count(distinct invoice_id)    AS orders_count,
count(distinct line_item_id)  AS item_count
from dsv1069.orders
group by date(paid_at) 
) daily_orders
ON daily_orders.date_paid = dates_rollup.date
group by dates_rollup.date

Q4)
--Figure out which parts of the JOIN condition need to be edited
--create 7 day rolling orders table.

--take date column which is the last date of the 7 day rolling period 
--date paid should fit between date and 7 days ago

select 
  *
FROM 
  dsv1069.dates_rollup 
LEFT OUTER JOIN(
select 
  date(orders.paid_at)                AS date_paid, 
  count(distinct invoice_id)          AS orders_count,
  count(distinct line_item_id)        AS item_count
FROM 
  dsv1069.orders
GROUP BY 
  date(orders.paid_at) 
) daily_orders
ON 
  dates_rollup.date >= daily_orders.date_paid 
AND 
  dates_rollup.d7_ago < daily_orders.date_paid  

Q5)
--Finish creating the weekly rolling orders table, by performing
--any aggregation steps and naming your columns appropriately.

select 
  dates_rollup.date, 
  COALESCE(SUM(orders_count),0)   AS orders_count,
  COALESCE(SUM(item_count),0)     AS item_count,
  count(*)                        AS orders_a_week
FROM 
  dsv1069.dates_rollup 
LEFT OUTER JOIN(
select 
  date(paid_at)                 AS date_paid, 
  count(distinct invoice_id)    AS orders_count,
  count(distinct line_item_id)  AS item_count
FROM 
  dsv1069.orders
GROUP BY 
  date(orders.paid_at) 
) daily_orders
ON 
  dates_rollup.date >= daily_orders.date_paid 
AND 
  dates_rollup.d7_ago < daily_orders.date_paid  
GROUP BY 
  dates_rollup.date

------------------------------------------------------------------------------------------------------------------------------------------------

--PROMO EMAIL
Q1)
--Create the right subtable for recently viewed events using the view_item_events table.
--item_views happen at distinct timestamps so row_number() makes sense 
SELECT 
	user_id,
	item_id,
	event_time,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY event_time DESC)
	AS view_number 
FROM 
	dsv1069.view_item_events

Q2)
--Join your tables together recent_views, users, items
SELECT * 
FROM (
	SELECT 
	user_id,
	item_id,
	event_time,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY event_time DESC)
	AS view_number 
FROM 
	dsv1069.view_item_events
) recent_views
INNER JOIN 
	dsv1069.users
ON users.id = recent_views.user_id 
INNER JOIN 
	dsv1069.items 
ON items.id = recent_views.item_id 

Q3)
--The goal of all this is to return all of the information we’ll
--need to send users an email about the item they viewed more recently. Clean up this query
--outline from the outline in EX2 and pull only the columns you need. Make sure they are named
--appropriately so that another human can read and understand their contents.

SELECT 
	users.id 									AS user_id,
	users.email_address,
	items.id 									AS item_id,
	items.name 								AS item_name,
	items.category 						AS item_category 
FROM (
	SELECT 
	user_id,
	item_id,
	event_time,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY event_time DESC)
	AS view_number 
FROM 
	dsv1069.view_item_events
) recent_views
INNER JOIN 
	dsv1069.users
ON users.id = recent_views.user_id 
INNER JOIN 
	dsv1069.items 
ON items.id = recent_views.item_id 

Q4)
--The goal of all this is to return all of the information we’ll
--need to send users an email about the item they viewed more recently. Clean up this query
--outline from the outline in EX2 and pull only the columns you need. Make sure they are named
--appropriately so that another human can read and understand their contents.

--what if a user has been deleted or merged, you wouldn;t want them to receive an email as they're off your books
--also no point sending perosn email if they viewed the item 6+ years ago
SELECT 
	COALESCE(users.parent_user_id, users.id) 	AS user_id,
	users.email_address,
	items.id 																	AS item_id,
	items.name 																AS item_name,
	items.category 														AS item_category 
FROM (
	SELECT 
	user_id,
	item_id,
	event_time,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY event_time DESC)
	AS view_number 
FROM 
	dsv1069.view_item_events
WHERE 
	event_time >= '2017-01-01'
) recent_views
INNER JOIN 
	dsv1069.users
ON users.id = recent_views.user_id 
INNER JOIN 
	dsv1069.items 
ON items.id = recent_views.item_id 
WHERE 
	users.deleted_at IS NOT NULL AND view_number = 1

--also no point sending email for an item which was already bought by the person

SELECT 
	COALESCE(users.parent_user_id, users.id) 	AS user_id,
	users.email_address,
	items.id 																	AS item_id,
	items.name 																AS item_name,
	items.category 														AS item_category 
FROM (
	SELECT 
	user_id,
	item_id,
	event_time,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY event_time DESC)
	AS view_number 
FROM 
	dsv1069.view_item_events
WHERE 
	event_time >= '2017-01-01'
) recent_views
INNER JOIN 
	dsv1069.users
ON users.id = recent_views.user_id 
INNER JOIN 
	dsv1069.items 
ON items.id = recent_views.item_id 
LEFT OUTER JOIN
	dsv1069.orders 
ON orders.item_id = recent_views.item_id
	AND 
  	orders.user_id = recent_views.user_id
  AND	
  	orders.item_id IS NULL
WHERE 
	users.deleted_at IS NOT NULL AND view_number = 1

------------------------------------------------------------------------------------------------------------------------------------------------

PRODUCT ANALYSIS
--Exercise 0: Count how many users we have 
select 
count (distinct id) as user_id 
from dsv1069.users 
--117178

--Exercise 1: Find out how many users have ever ordered

-- how many users have ordered
--select 
--count(distinct id) as user_id 
--from dsv1069.users 
--inner join dsv1069.orders 
--on users.id = orders.user_id
--17463 

--or 
select 
count(distinct user_id)
from dsv1069.orders
--17463

--Exercise 2 Goal find how many users have reordered the same item

-- users who have reordered same item
select 
count(distinct user_id) as users_who_ordered
from 
(select 
user_id,
item_id,
count(distinct line_item_id) as times_user_ordered
from dsv1069.orders 
group by user_id, item_id
) user_order_level
where times_user_ordered

--Exercise 3:
--Do users even order more than once?
select 
count(distinct user_id)
from
(select 
user_id,
count(distinct invoice_id) as order_count
from dsv1069.orders 
group by 
user_id) user_level 
where order_count > 1

--Exercise 4:
--Orders per item

select 
item_id, 
count(line_item_id) as times_ordered
from dsv1069.orders 
group by item_id

--Exercise 5:
--Orders per category
select 
item_category, 
count(line_item_id) as times_ordered
from dsv1069.orders 
group by item_category

--Exercise 6:
--Goal: Do user order multiple things from the same category?
select 
user_id, 
item_category, 
count(distinct line_item_id) as time_catgeory_ordered 
from dsv1069.orders 
group by user_id, item_category 

--then we can work out average
select 
user_level.item_category,
avg(time_catgeory_ordered) as avg_time_catgeory_ordered
from
(select 
user_id, 
item_category, 
count(distinct line_item_id) as time_catgeory_ordered 
from dsv1069.orders 
group by user_id, item_category 
) user_level
group by item_category

--Exercise 7:
--Goal: Find the average time between orders --Decide if this analysis is necessary

SELECT 
  date(first_orders.paid_at) as first_order_date,
  date(second_orders.paid_at) as second_order_date,
  date(second_orders.paid_at) - date(first_orders.paid_at) as date_diff
from
  (select 
  user_id,
  invoice_id,
  paid_at,
  dense_rank() over (partition by user_id order by paid_at asc) as order_num 
  from dsv1069.orders 
  ) first_orders
inner join 
  (select 
  user_id,
  invoice_id,
  paid_at,
  dense_rank() over (partition by user_id order by paid_at asc) as order_num 
  from dsv1069.orders 
  ) second_orders
on first_orders.user_id = second_orders.user_id
where first_orders.order_num = 1 and second_orders.order_num = 2 

------------------------------------------------------------------------------------------------------------------------------------------------

--Q1
--Figure out how many tests we have running right now

--SELECT
--count(distinct parameter_value) as tests
--from dsv1069.events 
--where event_name = 'test_assignment' and 
--parameter_name = 'test_id'

--4 running

SELECT
distinct parameter_value as tests_id
from dsv1069.events 
where event_name = 'test_assignment' and 
parameter_name = 'test_id'

--Q2
--Check for potential problems with test assignments. For example Make sure there
--is no data obviously missing (This is an open ended question)

SELECT
parameter_value   as test_id,
date(event_time)  as day,
count(*)          as event_rows
from dsv1069.events 
where event_name = 'test_assignment' and 
parameter_name = 'test_id'
group by 
parameter_value, date(event_time)

--Q3
--Write a query that returns a table of assignment events.Please include all of the
--relevant parameters as columns (Hint: A previous exercise as a template)

select 
event_id,
event_time,
user_id,
platform,
max(case when parameter_name = 'test_id' then cast(parameter_value as INT)
ELSE NULL end) as test_id,
max(case when parameter_name = 'test_assignment' then parameter_value
ELSE NULL end) as test_assignment
from 
dsv1069.events 
where event_name = 'test_assignment'
group by 
event_id,
event_time,
user_id,
platform

--Q4
--Check for potential assignment problems with test_id 5. 
--Specifically, make sure users are assigned only one treatment group.
select
test_id,
user_id,
count(distinct test_assignment) as assignments
from
(select 
event_id,
event_time,
user_id,
platform,
max(case when parameter_name = 'test_id' then cast(parameter_value as INT)
ELSE NULL end) as test_id,
max(case when parameter_name = 'test_assignment' then parameter_value
ELSE NULL end) as test_assignment
from 
dsv1069.events 
where event_name = 'test_assignment'
group by 
event_id,
event_time,
user_id,
platform
order by 
event_id
) test_events
where test_id = 5
group by test_id, user_id 
order by assignments desc


------------------------------------------------------------------------------------------------------------------------------------------------
--Q1
--Using the table from Exercise 4.3 and compute a metric that measures --Whether a user created an order after their test assignment
--Requirements: Even if a user had zero orders, we should have a row that counts -- their number of orders as zero
--If the user is not in the experiment they should not be included
SELECT 
  test_events.test_id, 
  test_events.test_assignments,
  test_events.user_id,
  max(case when orders.created_at > test_events.event_time then 1 else 0 end) as orders_after_assignment
from
  (select 
  event_id,
  event_time,
  user_id,
  --platform
  max(case when parameter_name = 'test_id' then cast(parameter_value as int) 
  else null end) as test_id,
  max(case when parameter_name = 'test_assignment' then cast(parameter_value as int) 
  else null end) as test_assignments
  from 
  dsv1069.events 
  where event_name = 'test_assignment' 
  group by 
  event_id,
  event_time,
  user_id) test_events
left join 
dsv1069.orders 
on orders.user_id = test_events.user_id
group by 
  test_events.test_id, 
  test_events.test_assignments,
  test_events.user_id


--Q2
--Using the table from the previous exercise, add the following metrics --1) the number of orders/invoices
--2) the number of items/line-items ordered
--3) the total revenue from the order after treatment

SELECT 
  test_events.test_id, 
  test_events.test_assignments,
  test_events.user_id,
  count(distinct(case when orders.created_at > test_events.event_time then invoice_id else null end)) as orders_after_assignment,
  count(distinct(case when orders.created_at > test_events.event_time then line_item_id else null end)) as items_after_assignment,
  sum(case when orders.created_at > test_events.event_time then price else 0 end) as total_revenue
from
  (select 
  event_id,
  event_time,
  user_id,
  --platform
  max(case when parameter_name = 'test_id' then cast(parameter_value as int) 
  else null end) as test_id,
  max(case when parameter_name = 'test_assignment' then cast(parameter_value as int) 
  else null end) as test_assignments
  from 
  dsv1069.events 
  where event_name = 'test_assignment' 
  group by 
  event_id,
  event_time,
  user_id) test_events
left join 
dsv1069.orders 
on orders.user_id = test_events.user_id
group by 
  test_events.test_id, 
  test_events.test_assignments,
  test_events.user_id


------------------------------------------------------------------------------------------------------------------------------------------------
Analysing Results
Q1
--Use the order_binary metric from the previous exercise, 
--count the number of users per treatment group for test_id = 7, 
--and count the number of users with orders (for test_id 7)
select 
test_assignments,
count(user_id) as users, 
sum(order_binary) as users_with_orders
FROM 
(
SELECT 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments,
  max(case when orders.created_at > assignments.event_time then 1 else 0 end) as order_binary
from
  (select 
  event_id,
  event_time,
  user_id,
  --platform
  max(case when parameter_name = 'test_id' then cast(parameter_value as int) 
  else null end) as test_id,
  max(case when parameter_name = 'test_assignment' then cast(parameter_value as int) 
  else null end) as test_assignments
  from 
  dsv1069.events 
  where event_name = 'test_assignment' 
  group by 
  event_id,
  event_time,
  user_id) assignments
left outer join 
dsv1069.orders 
on orders.user_id = assignments.user_id
group by 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments
) order_binary
where test_id = 7
group by test_assignments


Q2
--Create a new tem view binary metric. 
--Count the number of users per treatment group, 
--and count the number of users with views (for test_id 7)

select 
test_assignments,
count(user_id) as users, 
sum(views_binary) as views_binary
FROM 
(
SELECT 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments,
 -- max(case when orders.created_at > assignments.event_time then 1 else 0 end) as order_binary
  max(case when views.event_time > assignments.event_time then 1 else 0 end) as views_binary
from
  (select 
  event_id,
  event_time,
  user_id,
  --platform
  max(case when parameter_name = 'test_id' then cast(parameter_value as int) 
  else null end) as test_id,
  max(case when parameter_name = 'test_assignment' then cast(parameter_value as int) 
  else null end) as test_assignments
  from 
  dsv1069.events 
  where event_name = 'test_assignment' 
  group by 
  event_id,
  event_time,
  user_id) assignments
left outer join 
(
select *
from 
dsv1069.events 
where 
event_name = 'view_item'
) views
on views.user_id = assignments.user_id
group by 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments
) order_binary
where test_id = 7
group by test_assignments

Q3
--Alter the result from EX 2, 
--to compute the users who viewed an item WITHIN 30 days of their treatment event

select 
test_assignments,
count(user_id) as users, 
sum(views_binary) as views_binary,
sum(views_binary_30_days) as views_binary_30_days
FROM 
(
SELECT 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments,
  max(case when views.event_time > assignments.event_time then 1 else 0 end) as views_binary,
  max(case when views.event_time > assignments.event_time and 
                date_part('day',views.event_time - assignments.event_time) <= 30 
      then 1 else 0 end) as views_binary_30_days
from
  (select 
  event_id,
  event_time,
  user_id,
  --platform
  max(case when parameter_name = 'test_id' then cast(parameter_value as int) 
  else null end) as test_id,
  max(case when parameter_name = 'test_assignment' then cast(parameter_value as int) 
  else null end) as test_assignments
  from 
  dsv1069.events 
  where event_name = 'test_assignment' 
  group by 
  event_id,
  event_time,
  user_id) assignments
left outer join 
(
select *
from 
dsv1069.events 
where 
event_name = 'view_item'
) views
on views.user_id = assignments.user_id
group by 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments
) order_binary
where test_id = 7
group by test_assignments

Q4
--Create the metric invoices (this is a mean metric, not a binary metric) and for test_id = 7 
----The count of users per treatment group
----The average value of the metric per treatment group
----The standard deviation of the metric per treatment group

select 
test_id,
test_assignments,
count(user_id) as users,
avg(invoices) as avg_invoices,
stddev(invoices) as stdev_invoices
from
(SELECT 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments,
  count(distinct case when orders.created_at > assignments.event_time then orders.invoice_id else null end) as invoices,
  count(distinct case when orders.created_at > assignments.event_time then orders.line_item_id else null end) as line_items,
  COALESCE(sum( case when orders.created_at > assignments.event_time then orders.price else null end), 0) as total_revenue
from
  (select 
  event_id,
  event_time,
  user_id,
  --platform
  max(case when parameter_name = 'test_id' then cast(parameter_value as int) 
  else null end) as test_id,
  max(case when parameter_name = 'test_assignment' then cast(parameter_value as int) 
  else null end) as test_assignments
  from 
  dsv1069.events 
  where event_name = 'test_assignment' 
  group by 
  event_id,
  event_time,
  user_id) assignments
left outer join 
dsv1069.orders 
on orders.user_id = assignments.user_id
group by 
  assignments.user_id,
  assignments.test_id, 
  assignments.test_assignments
  ) mean_metrics
group by 
test_id, 
test_assignments
order by test_id





