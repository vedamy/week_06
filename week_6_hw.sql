-- 1.Show all customers whose last names start with T.
-- Order them by first name from A-Z.
CREATE TABLE HW_1 AS
SELECT *
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name ASC;

-- 2.Show all rentals returned from 5/28/2005 to 6/1/2005
CREATE TABLE HW_2 AS
SELECT *
FROM rental
WHERE return_date BETWEEN '2005-05-28' AND '2005-06-01';

--3.How would you determine which movies are rented the most? 

CREATE TABLE HW_3 as	
SELECT COUNT(DISTINCT r.rental_id) AS rental_freq, m.title
FROM inventory AS i
  INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
  INNER JOIN film as f	
    ON i.film_id = f.film_id
	INNER JOIN movies as m
	ON f.title = m.title
	GROUP BY m.title
	ORDER BY m.title, rental_freq DESC;
	
--4.Show how much each customer spent on movies (for all time) . Order them from least to most.	

CREATE TABLE HW_4 AS
SELECT concat(c.first_name, ' ', c.last_name) AS customer_name, c.customer_id, SUM(p.amount) AS Amt_spent_on_movies
FROM customer AS c
  INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
  GROUP BY c.customer_id
    ORDER BY Amt_spent_on_movies ASC;
	
--5.Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count 
--as a more descriptive name. Order the results from most to least.

CREATE TABLE HW_5 AS
SELECT concat(a.first_name, ' ', a.last_name) AS actor_name, actor_id, release_year, COUNT(DISTINCT film_id) AS movie_count
FROM film AS f
INNER JOIN film_actor AS fa
USING(film_id)
INNER JOIN actor AS a
USING(actor_id)
WHERE f.release_year = '2006'
GROUP BY actor_name, actor_id, release_year
ORDER BY movie_count DESC;
	
--6.Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. 
-- ***To create Table HW_4:
-- STEP-1. To identify the tables we need to get how much amount each customer spent on movies.
--         so, i have choose to take customer Table and payment Table, and found the key to join both the 
--         tables as customer_id.
-- STEP-2. using concat function i have put together both first and last names as a customer_name
-- STEP-3. To get the Amount spent on movies, i used aggregate function SUM to amount field in payment table as 
--         Amt_spent_on_movies.
-- STEP-4. Finally, group by customer_id and order by Amt_spent_on_movies in Ascending order to get least to highest 
--         amount, spent on movies by each customer.
--Below is the query I used to extract to answer for the question-4:


EXPLAIN (FORMAT JSON)
SELECT
    concat(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_id,
    SUM(p.amount) AS Amt_spent_on_movies
FROM
    customer AS c
    INNER JOIN payment AS p 
        ON c.customer_id = p.customer_id
GROUP BY 
    c.customer_id
ORDER BY
    Amt_spent_on_movies ASC;

	
-- ***To create Table HW_5:
-- STEP-1. we need to identify the tables that we want to get Which actor was in the most movies in 2006 .
--         so, i have choose to take film table, film_actor table and actor table, and found the key to join the 
--         film, film_actor is using film_id and the key to join film_actor and actor is using actor_id,
-- STEP-2. using concat function i have put together both first and last names as a actor_name,
-- STEP-3. To get the count for movies, i put COUNT and DISTINCT for the film_id and alis as  movie_count,
-- STEP-4. to get the most movies in 2006 i use release_year in SELECT statment, then using where set the satement
--         WHERE release_year = 2006,
-- STEP-5. GROUP BY actor_name, actor_id, release_yearand then order by movie_count in descending order to get most
--         movies in the year 2006.

--Below is the query I used to extract to answer for the question-5:


EXPLAIN (FORMAT JSON)
SELECT
    concat(a.first_name, ' ', a.last_name) AS actor_name,
    a.actor_id,
    f.release_year,
	COUNT(DISTINCT f.film_id) AS movie_count
FROM
    film AS f
    INNER JOIN film_actor AS fa 
        ON fa.film_id = f.film_id
    INNER JOIN actor AS a 
        ON a.actor_id = fa.actor_id
WHERE 
    f.release_year = 2006
GROUP BY 
    actor_name, 
	a.actor_id, 
	f.release_year
ORDER BY
    movie_count DESC;

	
--7.What is the average rental rate per genre?
--STEP-1. To identify the tables we need to get the average rental rate.so, i picked category>film_category>film>
CREATE TABLE HW_7 AS
SELECT c.name AS category_name, AVG(rental_rate) AS Avg_rental_rate
FROM category AS c
INNER JOIN film_category AS fc
USING (category_id)
INNER JOIN film AS f
USING (film_id)
GROUP BY category_name
ORDER BY Avg_rental_rate DESC;

--8.How many films were returned late? Early? On time?

CREATE TABLE HW_8 AS
SELECT 
	CASE WHEN DATE_PART('day', return_date - rental_date) < rental_duration THEN 'Early Return' 
		 WHEN DATE_PART('day', return_date - rental_date) = rental_duration THEN 'On time'
		 ELSE 'Late Return' END
	AS return_class,
	COUNT(title) AS film_count
	FROM film AS f
	INNER JOIN inventory AS i
	USING (film_id)
	INNER JOIN rental as r
	USING (inventory_id)
	GROUP BY return_class
	ORDER BY return_class;


--9.What categories are the most rented and what are their total sales? 
--category >film_category >inventory>rental >payment
CREATE TABLE HW_9 AS
SELECT c.name AS genre, SUM(amount) AS total_sales
FROM category AS c
INNER JOIN film_category AS fc
USING (category_id)
INNER JOIN inventory AS i
USING (film_id)
INNER JOIN rental AS r
USING (inventory_id)
INNER JOIN payment AS p
USING (rental_id)
GROUP BY genre
ORDER BY total_sales DESC;



-- 10.Create a view for 8 and a view for 9. Be sure to name them appropriately. 


CREATE VIEW films_returned AS
SELECT 
	CASE WHEN DATE_PART('day', return_date - rental_date) < rental_duration THEN 'Early Return' 
		 WHEN DATE_PART('day', return_date - rental_date) = rental_duration THEN 'On time'
		 ELSE 'Late Return' END
	AS return_class,
	COUNT(title) AS film_count
	FROM film AS f
	INNER JOIN inventory AS i
	USING (film_id)
	INNER JOIN rental as r
	USING (inventory_id)
	GROUP BY return_class
	ORDER BY return_class;
	
	
CREATE VIEW most_rented_and_total_sales AS	
SELECT c.name AS genre, SUM(amount) AS total_sales
FROM category AS c
INNER JOIN film_category AS fc
USING (category_id)
INNER JOIN inventory AS i
USING (film_id)
INNER JOIN rental AS r
USING (inventory_id)
INNER JOIN payment AS p
USING (rental_id)
GROUP BY genre
ORDER BY total_sales DESC;

--11.Write a query that shows how many films were rented each month. Group them by category and month. 







