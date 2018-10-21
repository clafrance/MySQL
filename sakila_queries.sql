
USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name 
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT UPPER(CONCAT(first_name, '  ', last_name)) AS 'Actor Name'
FROM actor;


/*
2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?
*/

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT actor_id, first_name, last_name
FROM actor
WHERE UPPER(last_name) LIKE "%GEN%";


-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT actor_id,  last_name,  first_name
FROM actor
WHERE UPPER(last_name) LIKE "%LI%"
ORDER BY last_name, first_name;


-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


/*
3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, 
as the difference between it and `VARCHAR` are significant).
*/

ALTER TABLE actor
    ADD COLUMN description BLOB;
    
describe actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor
    DROP COLUMN description;

describe actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(first_name) 
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT last_name, COUNT(first_name) AS number_of_people_with_the_last_name
FROM actor
GROUP BY last_name
HAVING number_of_people_with_the_last_name > 1;


-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

-- Verify that the record exists

SELECT first_name, last_name 
FROM actor
WHERE first_name = "GROUCHO"
    AND last_name = "WILLIAMS";

-- Update the name to the correct one

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO"
    AND last_name = "WILLIAMS";

-- Verify the name was changed successfully
    
SELECT first_name, last_name 
FROM actor
WHERE last_name = "WILLIAMS";


/*
 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query,
 if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
 */

UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO"
    AND last_name = "WILLIAMS";
    

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW SCHEMAS;

SELECT `table_schema` 
FROM `information_schema`.`tables` 
WHERE `table_name` = 'address';

CREATE DATABASE IF NOT EXISTS sakila;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address
FROM staff 
	JOIN address
	USING (address_id);


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
    
SELECT staff.first_name, staff.last_name, J.total_amount AS "Total Amount"
FROM staff
	JOIN 
		(SELECT payment.staff_id, SUM(payment.amount) AS total_amount
		 FROM payment 
		 WHERE EXTRACT(YEAR_MONTH FROM payment.payment_date) = '200508'
		 GROUP BY payment.staff_id) as J
	USING (staff_id);


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT film.title, A.number_of_actors
FROM film
	JOIN
		(SELECT film_id, COUNT(actor_id) AS number_of_actors
		 FROM film_actor
		 GROUP BY film_id) AS A
	USING (film_id);
    
    
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
    
SELECT film.film_id, film.title, COUNT(*) AS  "Number of Copies"
FROM inventory
	JOIN film
    USING(film_id)
WHERE UPPER(film.title) = 'HUNCHBACK IMPOSSIBLE' 
GROUP BY film.film_id, film.title;


/*
6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
List the customers alphabetically by last name: [Total amount paid](Images/total_payment.png) 
*/

SELECT C.first_name, C.last_name, SUM(C.amount) as 'Total Amount Paid'
FROM
		(SELECT customer_id, first_name, last_name, amount
		 FROM customer
			JOIN payment
			USING (customer_id)) AS C
GROUP BY C.customer_id
ORDER BY C.last_name, C.first_name;

    
/*
7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters `K` and `Q` whose language is English.
*/

SELECT title
FROM film
WHERE (title LIKE "K%" 
	OR title LIKE "Q%")
    AND language_id =
		(SELECT language_id 
         FROM language
         WHERE UPPER(name) = 'ENGLISH');


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id
	 FROM film_actor
	 WHERE film_id = 
		(SELECT film_id
	 	 FROM film
		 WHERE UPPER(title) = "ALONE TRIP"
		)
	);


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

-- Using join

SELECT first_name, last_name, email, CTRY.city
FROM customer
	JOIN
	((SELECT address.*, C.city
	  FROM address
		  JOIN
			  (SELECT city.*, country.country
			   FROM city 
				  JOIN country
				  USING (country_id)
			   WHERE country.country = "Canada") AS C
		   USING (city_id))) AS CTRY
	USING (address_id);


-- Using subquery

SELECT first_name, last_name, email, address_id
FROM customer
WHERE address_id IN
	(SELECT address_id
	FROM address
	WHERE city_id IN
		(SELECT city_id 
		FROM city
		WHERE country_id =
			(SELECT country_id 
			FROM country
			WHERE country = "Canada"
            )
		)
	);


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT film.title, J.name AS 'Category Name', film.rating 
FROM 
		film
	RIGHT JOIN
		(SELECT DISTINCT film_category.film_id, category.name, film_category.category_id 
		FROM category
			JOIN film_category
			USING (category_id)
		WHERE category.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music', 'New')) AS J
	USING (film_id)
WHERE film.rating IN ("G", "PG", "PG-13")
ORDER BY film.title;


-- Using subquery

SELECT F.title, F.rating
FROM film AS F
WHERE 
	(F.rating IN ("PG", "G", "PG-13"))
	AND 
	(F.film_id IN 
		(SELECT FC.film_id
		FROM film_category AS FC
		WHERE FC.category_id IN 
			(SELECT C.category_id
			FROM category AS C
			WHERE C.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music', 'New'))))
ORDER BY F.title;


-- 7e. Display the most frequently rented movies in descending order.

SELECT film.title, J.rental_counts 
FROM film
	JOIN
		(SELECT film_id, COUNT(rental_id) AS rental_counts
		 FROM inventory, rental
		 WHERE inventory.inventory_id = rental.inventory_id
		 GROUP BY film_id) AS J
	USING (film_id)
ORDER BY rental_counts DESC, title;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT inventory.store_id, CONCAT('$', CONVERT(SUM(J.amount), CHAR)) AS "Total Rental Amount"
FROM inventory
	RIGHT JOIN
		(SELECT payment.rental_id, rental.inventory_id, amount
		 FROM payment, rental
		 WHERE payment.rental_id = rental.rental_id) AS J
	USING (inventory_id)
GROUP BY inventory.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store, city, country
WHERE store.store_id = city.city_id
	  AND city.country_id = country.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

-- First, find revenue per film

SELECT inventory.film_id, SUM(J.amount) AS gorss_revenue_per_film
FROM inventory
	RIGHT JOIN 
		(SELECT payment.amount, payment.rental_id, rental.inventory_id
		FROM payment, rental
		WHERE payment.rental_id = rental.rental_id) AS J
	USING (inventory_id)
GROUP BY inventory.film_id;

-- Second, find list of films with category

SELECT film.film_id, title, film_category.category_id, category.name
FROM film, film_category, category
WHERE film.film_id = film_category.film_id
	AND film_category.category_id = category.category_id
order by title;
    
-- Join above ttwo queries to get the top 5 category in gross revenue

SELECT C.name, SUM(R.gorss_revenue_per_film) AS gross_revenue
FROM 
		(SELECT inventory.film_id, SUM(J.amount) AS gorss_revenue_per_film
		 FROM inventory
			RIGHT JOIN 
				(SELECT payment.amount, payment.rental_id, rental.inventory_id
				FROM payment, rental
				WHERE payment.rental_id = rental.rental_id) AS J
			USING (inventory_id)
		GROUP BY inventory.film_id) AS R
	LEFT JOIN
		(SELECT film.film_id, title, film_category.category_id, category.name
		FROM film, film_category, category
		WHERE film.film_id = film_category.film_id
			AND film_category.category_id = category.category_id) AS C
	USING (film_id)
GROUP BY C.name
ORDER BY gross_revenue DESC;


-- The following queries are for verify the query result is correct for Sports category

select film_id from film_category where category_id = 15  order by film_id;

select inventory_id 
from inventory
	join 
		(select film_id from film_category where category_id = 15  order by film_id) AS F
	using (film_id);

select rental_id 
from rental 
	join
		(select inventory_id 
		from inventory
			join 
				(select film_id from film_category where category_id = 15  order by film_id) AS F
		using (film_id)) as R
	using(inventory_id);

select sum(amount)
from payment
	join
		(select rental_id 
			from rental 
				join
					(select inventory_id
						from inventory
							join 
								(select film_id 
									from film_category 
								where category_id = 15  
                                order by film_id) AS F
							using (film_id)) as R
				using(inventory_id)) as P
	using (rental_id);


/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
*/

CREATE VIEW view_top_five_genres AS
	SELECT C.name, SUM(R.gorss_revenue_per_film) AS gross_revenue
	FROM 
			(SELECT inventory.film_id, SUM(J.amount) AS gorss_revenue_per_film
			FROM inventory
				RIGHT JOIN 
					(SELECT payment.amount, payment.rental_id, rental.inventory_id
					FROM payment, rental
					WHERE payment.rental_id = rental.rental_id) AS J
				USING (inventory_id)
			GROUP BY inventory.film_id) AS R
		LEFT JOIN
			(SELECT film.film_id, title, film_category.category_id, category.name
			FROM film, film_category, category
			WHERE film.film_id = film_category.film_id
				AND film_category.category_id = category.category_id) AS C
		USING (film_id)
	GROUP BY C.name
	ORDER BY gross_revenue DESC; 


-- 8b. How would you display the view that you created in 8a?

SELECT * from view_top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW view_top_five_genres;