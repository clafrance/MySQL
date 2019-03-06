
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
    ADD COLUMN description BLOB AFTER last_name;
    
describe actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor
    DROP COLUMN description;

describe actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name)  AS last_name_count
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


SHOW CREATE TABLE address;

SELECT `table_schema` 
FROM `information_schema`.`tables` 
WHERE `table_name` = 'address';


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address
FROM staff 
	INNER JOIN address
	USING (address_id);


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
    
SELECT s.first_name, s.last_name, sum(p.amount) AS "Total Amount"
FROM staff AS s
INNER JOIN payment AS p
    ON p.staff_id = s.staff_id
WHERE MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
-- WHERE EXTRACT(YEAR_MONTH FROM payment.payment_date) = '200508'
GROUP BY s.staff_id;
    
    
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT f.title, COUNT(a.actor_id)
FROM film AS f
INNER JOIN film_actor AS a
	ON f.film_id = a.film_id
GROUP BY f.title;
    
    
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
    
SELECT  f.title, COUNT(i.film_id) AS  "Number of Copies"
FROM inventory AS I
	INNER JOIN film AS f
    USING(film_id)
WHERE UPPER(f.title) = 'HUNCHBACK IMPOSSIBLE' 
GROUP BY f.title;

/*
6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
List the customers alphabetically by last name: [Total amount paid](Images/total_payment.png) 
*/
SELECT c.last_name, c.first_name, sum(p.amount) 
FROM customer AS c
INNER JOIN payment AS p
	USING(customer_id)
GROUP BY c.customer_id
ORDER by c.last_name;
    
/*
7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters `K` and `Q` whose language is English.
*/

SELECT title
FROM film
WHERE (title LIKE "K%" 
	OR title LIKE "Q%")
    AND language_id IN
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
    
SELECT c.first_name, c.last_name, c.email, country.country
FROM customer AS c
INNER JOIN address AS a
USING(address_id)
INNER JOIN city
USING (city_id)
INNER JOIN country 
USING (country_id)
WHERE country.country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT film.title, category.name 'Category Name', film.rating
FROM film
INNER JOIN film_category
USING(film_id)
INNER JOIN category
USING(category_id)
WHERE UPPER(category.name) = "FAMILY";


-- 7e. Display the most frequently rented movies in descending order.

SELECT film.title, COUNT(rental.rental_id) AS "Rentals"
FROM film
INNER JOIN inventory
USING(film_id)
INNER JOIN rental
USING(inventory_id)
GROUP BY film.title
ORDER BY Rentals DESC, film.title;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT inventory.store_id, SUM(payment.amount), CONCAT('$', CONVERT(SUM(payment.amount), CHAR)) AS "Total Rental Amount"
FROM inventory
INNER JOIN rental
USING(inventory_id)
INNER JOIN payment
USING (rental_id)
GROUP BY  inventory.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
      
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address
USING(address_id)
INNER JOIN city
USING(city_id)
INNER JOIN country
USING(country_id);

 
-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, SUM(payment.amount) AS "Revenue"
FROM category
INNER JOIN film_category
USING(category_id)
INNER JOIN inventory
USING(film_id)
INNER JOIN rental
USING(inventory_id)
INNER JOIN payment
USING(rental_id)
GROUP BY category.name
ORDER BY Revenue DESC
LIMIT 5;

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
*/

CREATE VIEW view_top_five_genres AS
SELECT category.name, SUM(payment.amount) AS "Revenue"
FROM category
INNER JOIN film_category
USING(category_id)
INNER JOIN inventory
USING(film_id)
INNER JOIN rental
USING(inventory_id)
INNER JOIN payment
USING(rental_id)
GROUP BY category.name
ORDER BY Revenue DESC
LIMIT 5;



-- 8b. How would you display the view that you created in 8a?

SELECT * from view_top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW view_top_five_genres;