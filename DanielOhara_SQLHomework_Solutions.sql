-- Daniel Seiji Ohara Kondo, Homework (SQL Statements)

USE sakila;

-- 1a) Display the first and last name of all actors from the table actor

SELECT actor.first_name, actor.last_name FROM sakila.actor;

-- 1b) Display the first and last name of each actor in a single column in upper case letters. name the colum Actor Name
SELECT UPPER(CONCAT(actor.first_name, ' ' , actor.last_name)) AS "Actor Name" FROM sakila.actor;

-- 2a) You need to find the ID number, first name, and lastname  of an actor, of whome you know only the first name,
-- "Joe." What is one query you could use to obtain this information?
SELECT actor.actor_id, actor.first_name, actor.last_name FROM sakila.actor WHERE actor.first_name = "joe";

-- 2b) Find all actors whose lastname contain letter GEN:
SELECT actor.first_name, actor.last_name FROM sakila.actor WHERE actor.last_name LIKE "%gen%";

-- 2c) Find all actors whose last names contain the letters LI. This time. order the rows by lastnmae and fisrtname in that order
SELECT actor.first_name, actor.last_name FROM sakila.actor WHERE actor.last_name LIKE "%li%" ORDER BY actor.last_name, actor.first_name;


-- 2d) Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country.country_id, country.country FROM sakila.country WHERE country.country IN ("Afghanistan", "Bangladesh", "China");

-- 3a) You want to keep a description of each actor. You don't think you will be performing queries on a description, so create
-- a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the
-- difference bewteen it and VARCHAR are significant)
ALTER TABLE sakila.actor ADD description BLOB;

-- 3b) Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column;
ALTER TABLE sakila.actor DROP COLUMN description;

-- 4a) List the last names of actors, as well as how many actors have that last name.
SELECT actor.last_name, COUNT(actor.last_name) AS "Lastname Usage" FROM sakila.actor GROUP BY actor.last_name;

-- 4b) List last names of actors and the number of actors who have that last name, but only for names that are shared
-- by atleast two actors
SELECT *
FROM
  (SELECT actor.last_name, COUNT(actor.last_name) AS "Popularity" FROM sakila.actor GROUP BY actor.last_name) AS T1
WHERE
T1.Popularity > 1;

-- 4c) The actor Harpo Williams was accidentally entered in the actor table as Groucho Williams, write a query
-- to fix the record

-- Select * from sakila.actor where actor.first_name = "groucho" and actor.last_name = "williams";<
UPDATE sakila.actor SET actor.first_name = "HARPO", actor.last_name = "WILLIAMS" WHERE actor.first_name = "Groucho" AND actor.last_name = "Williams";
-- Select * from sakila.actor where actor.first_name = "harpo" and actor.last_name = "williams";

-- 4d) Perhaps we were too hasty in changing groucho to harpo. it turns out that groucho was the correct name after all!
-- In a single query, if the firstname of the actor is currently harpo change it to groucho.

-- SELECT  * from sakila.actor WHERE actor.first_name = "Harpo";
UPDATE sakila.actor SET actor.first_name = "GROUCHO" WHERE actor.first_name = "HARPO";
-- SELECT  * from sakila.actor WHERE actor.first_name = "groucho";

-- 5a) You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.actor;

-- 6a) Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address

-- DESCRIBE sakila.staff;
-- DESCRIBE sakila.address;
SELECT staff.first_name, staff.last_name, address.address FROM sakila.staff LEFT JOIN sakila.address ON staff.address_id = address.address_id;

-- 6b) Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment

-- DESCRIBE sakila.staff;
-- DESCRIBE sakila.payment;
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(T1.amount) AS "Total Amount", COUNT(T1.amount) AS "Num of payments rung"
FROM
  (SELECT payment.staff_id, payment.amount, payment.payment_id FROM sakila.payment WHERE payment.payment_date > "2005-01-01" AND payment.payment_date < "2005-12-31") AS T1
RIGHT JOIN sakila.staff ON T1.staff_id = staff.staff_id
GROUP BY staff.staff_id;


-- 6c) List each film and the number of actors who are listed for that film. Use tables Film_actor and film. Use inner joins.
-- SELECT film.film_id, film.title, COUNT(film_actor.actor_id)
SELECT film.film_id, film.title, film.film_id AS "FILM ID", T1.film_id AS "FILM_ACTOR ID", T1.`Num of actors`
FROM
  (SELECT film_actor.film_id, COUNT(film_actor.actor_id) AS "Num of actors" FROM film_actor GROUP BY film_actor.film_id) AS T1
INNER JOIN sakila.film on T1.film_id = film.film_id;

-- 6d) How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory.film_id) AS "NUM OF COPIES" FROM sakila.inventory WHERE inventory.film_id = (SELECT film.film_id FROM sakila.film WHERE film.title = "Hunchback Impossible");

-- 6e) Using the tables payment and customer and the join command. List the total paid by each customer.
-- List the customers alphabetically by lastname.
SELECT customer.first_name, customer.last_name, T1.`Total Paid`
FROM sakila.customer
left join
  (SELECT payment.customer_id, SUM(payment.amount) AS "Total Paid" FROM sakila.payment GROUP BY payment.customer_id) AS T1
ON T1.customer_id = customer.customer_id
ORDER BY customer.last_name;

-- 7a) The music of Queen and Kris Kristofferson have seen an unliekly resurgance. As an unintended consequence,
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies
-- starting with the letters K and Q whose language is English

SELECT film.film_id, film.title
FROM sakila.film
WHERE (film.title LIKE "K%" OR film.title LIKE "Q%") AND film.language_id = (SELECT language.language_id FROM sakila.language WHERE language.name LIKE "%English%");

-- 7b) Use subqueries to display all actors who appear in the film Alone Trip
SELECT film_actor.actor_id, actor.first_name, actor.last_name
FROM sakila.film_actor
  LEFT JOIN sakila.actor ON film_actor.actor_id = actor.actor_id
WHERE film_actor.film_id = (SELECT film.film_id FROM sakila.film WHERE film.title = "Alone Trip")

-- 7c) You want to run an email marketing campaign in canada, for which you will need the names
-- and email addresses of all Canadian customers. Use Joins to retrieve this information.
SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email FROM sakila.customer WHERE customer.address_id IN
                                                                                                                (SELECT address.address_id FROM sakila.address WHERE address.city_id IN
                                                                                                                                                                     (SELECT city.city_id FROM sakila.city WHERE city.country_id IN
                                                                                                                                                                                                                 (SELECT country.country_id FROM sakila.country WHERE country.country LIKE "%CANADA%")))

-- 7d) Sales have been laggin among young families and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT film.film_id, film.title
FROM sakila.film
WHERE film.film_id IN
      (SELECT film_category.film_id FROM sakila.film_category WHERE film_category.category_id in
                                                                    (SELECT category.category_id FROM sakila.category WHERE category.name LIKE "Family%"))

-- 7e) Display the most frequently rented movies in descending order
SELECT film.film_id, film.title, COUNT(T1.T1_ID) AS "Frequency"
FROM sakila.film RIGHT JOIN
  (SELECT inventory.film_id AS "T1_ID" FROM sakila.rental LEFT JOIN sakila.inventory ON rental.inventory_id = inventory.inventory_id) AS T1
ON T1.T1_ID = film.film_id
GROUP BY T1_ID
ORDER BY Frequency DESC;


-- 7f) Write a query to display how much business, in dollars, each store brought in
SELECT store.store_id, SUM(payment.amount) FROM sakila.payment LEFT JOIN sakila.staff ON payment.staff_id = staff.staff_id LEFT JOIN sakila.store on staff.store_id = store.store_id GROUP BY store.store_id;

-- 7g) Write a query to display for each store, its store ID, city and country

SELECT store.store_id, c.city, c2.country FROM sakila.store LEFT JOIN sakila.address a ON store.address_id = a.address_id LEFT JOIN city c ON a.city_id = c.city_id LEFT JOIN country c2 ON c.country_id = c2.country_id;


-- 7h) List the top five genres in gross revenue in descending order (HINT. you may need to use the following tables:
-- category, film_category, inventory, payment and rental)
SELECT T2.name, SUM(T1.amount) AS "Revenue" FROM
              (SELECT payment.amount, rental.inventory_id, inventory.film_id FROM sakila.payment RIGHT JOIN sakila.rental ON payment.rental_id = rental.rental_id LEFT JOIN sakila.inventory on rental.inventory_id = inventory.inventory_id) AS T1
                LEFT JOIN
                (SELECT film_category.film_id, film_category.category_id, category.name FROM film_category INNER JOIN sakila.category on film_category.category_id = category.category_id) AS T2
                ON T1.film_id = T2.film_id
GROUP BY T2.category_id
ORDER BY Revenue DESC
LIMIT 5;

-- 8a) In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross
-- revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
Create VIEW top_five_genres AS
SELECT T2.name, SUM(T1.amount) AS "Revenue" FROM
              (SELECT payment.amount, rental.inventory_id, inventory.film_id FROM sakila.payment RIGHT JOIN sakila.rental ON payment.rental_id = rental.rental_id LEFT JOIN sakila.inventory on rental.inventory_id = inventory.inventory_id) AS T1
                LEFT JOIN
                (SELECT film_category.film_id, film_category.category_id, category.name FROM film_category INNER JOIN sakila.category on film_category.category_id = category.category_id) AS T2
                ON T1.film_id = T2.film_id
GROUP BY T2.category_id
ORDER BY Revenue DESC;

-- 8b) How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;


-- 8c) You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;



