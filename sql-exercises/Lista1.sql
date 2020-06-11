1. SHOW tables; 

2. SELECT film.title FROM film WHERE film.length > 120;

3.
SELECT title, name FROM film JOIN language ON film.language_id = language.language_id WHERE film.description LIKE "%Documentary%";

4.
SELECT title,name FROM film JOIN film_category ON film.film_id = film_category.film_id
 JOIN category ON film_category.category_id = category.category_id
 WHERE category.name = "Documentary" AND film.description NOT LIKE "%Documentary%"; 

5.
SELECT DISTINCT first_name,last_name,special_features FROM film
 INNER JOIN film_actor ON film.film_id = film_actor.film_id JOIN actor ON film_actor.actor_id = actor.actor_id
 WHERE special_features LIKE "Deleted Scenes";

6.
SELECT rating,COUNT(rating) FROM film GROUP BY rating;

7. 
SELECT DISTINCT title FROM rental JOIN inventory ON rental.inventory_id = inventory.inventory_id
 JOIN film ON inventory.film_id = film.film_id
 WHERE rental.rental_date BETWEEN '2005-5-25 00:00:00' AND '2005-5-28 23:59:59' ORDER BY title;

8.
 SELECT title FROM film WHERE rating = 'R' ORDER BY length DESC LIMIT 5;

9.
 SELECT DISTINCT c.first_name, c.last_name FROM rental r1 JOIN rental r2 ON r1.customer_id = r2.customer_id
 JOIN customer c ON c.customer_id = r2.customer_id WHERE r1.staff_id > r2.staff_id;

10.
CREATE VIEW Widok AS SELECT country,COUNT(city) AS l_miast FROM country JOIN city ON country.country_id = city.country_id GROUP BY country;
 SELECT country,l_miast FROM widok WHERE l_miast > (SELECT l_miast FROM widok WHERE country = "Canada");

--[II] WITHOUT VIEW 

 SELECT B.country,B.l_miast FROM (SELECT country,COUNT(city) AS l_miast FROM country JOIN city ON country.country_id = city.country_id
 GROUP BY country)
 B WHERE B.l_miast > (SELECT A.l_miast FROM (SELECT country,COUNT(city) AS l_miast FROM country JOIN city ON country.country_id = city.country_id
 GROUP BY country) A WHERE A.country = "Canada");

11.
CREATE VIEW rentalCount AS SELECT customer.customer_id,COUNT(rental.rental_id) l_wypozyczne FROM customer 
 JOIN rental ON customer.customer_id = rental.customer_id GROUP BY customer.customer_id;

SELECT rentalCount.customer_id FROM rentalCount WHERE rentalCount.l_wypozyczne > (SELECT l_wypozyczne FROM rentalCount
 JOIN customer ON rentalCount.customer_id = customer.customer_id WHERE customer.email = "PETER.MENARD@sakilacustomer.org");

--[II] WITHOUT VIEW  

SELECT rentalCount.customer_id FROM (SELECT customer.customer_id,COUNT(rental.rental_id) l_wypozyczne FROM customer 
 JOIN rental ON customer.customer_id = rental.customer_id GROUP BY customer.customer_id) rentalCount WHERE rentalCount.l_wypozyczne > 
(SELECT l_wypozyczne FROM (SELECT customer.customer_id,COUNT(rental.rental_id) l_wypozyczne FROM customer 
 JOIN rental ON customer.customer_id = rental.customer_id GROUP BY customer.customer_id)A
 JOIN customer ON A.customer_id = customer.customer_id WHERE customer.email = "PETER.MENARD@sakilacustomer.org");

12.
 CREATE VIEW actor_pairs AS SELECT film.film_id,TAB.actor_id AS actor1_id,film_actor.actor_id AS actor2_id FROM film
 INNER JOIN film_actor ON film_actor.film_id = film.film_id INNER JOIN film_actor TAB on TAB.film_id = film_actor.film_id
 WHERE TAB.actor_id > film_actor.actor_id;
 
SELECT DISTINCT actor_pairs.actor1_id, actor_pairs.actor2_id FROM actor_pairs 
 JOIN actor_pairs AS actor_pairs2 ON actor_pairs.actor1_id = actor_pairs2.actor1_id AND actor_pairs.actor2_id = actor_pairs2.actor2_id 
 WHERE actor_pairs.film_id > actor_pairs2.film_id;

--[II] WITHOUT VIEW
	SELECT DISTINCT A.actor1_id, A.actor2_id
	
	FROM 
(SELECT film.film_id,TAB.actor_id AS actor1_id,film_actor.actor_id AS actor2_id FROM film
 INNER JOIN film_actor ON film_actor.film_id = film.film_id INNER JOIN film_actor TAB on TAB.film_id = film_actor.film_id
 WHERE TAB.actor_id > film_actor.actor_id )
 AS A 
 	JOIN 
 (SELECT film.film_id,TAB.actor_id AS actor1_id,film_actor.actor_id AS actor2_id FROM film
 INNER JOIN film_actor ON film_actor.film_id = film.film_id INNER JOIN film_actor TAB on TAB.film_id = film_actor.film_id
 WHERE TAB.actor_id > film_actor.actor_id)
 AS B
	ON A.actor1_id = B.actor1_id AND A.actor2_id = B.actor2_id 
	WHERE A.film_id > B.film_id;

13.
 SELECT DISTINCT last_name FROM film JOIN film_actor ON film.film_id = film_actor.film_id 
 JOIN actor ON film_actor.actor_id = actor.actor_id WHERE film.title NOT LIKE "B%";

14.
 CREATE VIEW actor_horror AS SELECT actor.actor_id, COUNT(actor.actor_id) AS l_wystapien FROM actor JOIN film_actor ON actor.actor_id = film_actor.actor_id
 JOIN film ON film_actor.film_id = film.film_id JOIN film_category ON film.film_id = film_category.film_id
 JOIN category ON film_category.category_id = category.category_id AND category.name = "Horror" GROUP BY actor.actor_id;

 CREATE VIEW actor_action AS SELECT actor.actor_id, COUNT(actor.actor_id) AS l_wystapien FROM actor JOIN film_actor ON actor.actor_id = film_actor.actor_id
 JOIN film ON film_actor.film_id = film.film_id JOIN film_category ON film.film_id = film_category.film_id
 JOIN category ON film_category.category_id = category.category_id AND category.name = "Action" GROUP BY actor.actor_id;

SELECT last_name FROM actor_action JOIN actor_horror ON actor_action.actor_id = actor_horror.actor_id
 JOIN actor on actor_action.actor_id = actor.actor_id
 WHERE actor_horror.l_wystapien > actor_action.l_wystapien;

15. 
 CREATE VIEW payments_2005_07_07 AS SELECT customer.customer_id,AVG(amount) AS srednia 
 FROM customer JOIN payment ON customer.customer_id = payment.customer_id AND payment.payment_date LIKE "%2005-07-07%"
 GROUP BY customer.customer_id 

 SELECT TAB.customer_id FROM
 (SELECT customer.customer_id,AVG(amount) AS srednia FROM customer JOIN payment ON customer.customer_id = payment.customer_id
 GROUP BY customer.customer_id) AS TAB JOIN payments_2005_07_07 ON TAB.customer_id = payments_2005_07_07.customer_id
 WHERE TAB.srednia > payments_2005_07_07.srednia;

-- [II] WITHOUT VIEW
 SELECT TAB.customer_id FROM
 (SELECT customer.customer_id,AVG(amount) AS srednia FROM customer JOIN payment ON customer.customer_id = payment.customer_id
 GROUP BY customer.customer_id) AS TAB JOIN (SELECT customer.customer_id,AVG(amount) AS srednia 
 FROM customer JOIN payment ON customer.customer_id = payment.customer_id AND payment.payment_date LIKE "%2005-07-07%"
 GROUP BY customer.customer_id )A ON TAB.customer_id = A.customer_id
 WHERE TAB.srednia > A.srednia;

16.
 ALTER TABLE language ADD films_no int AFTER name;

UPDATE language A INNER JOIN (SELECT l.language_id, COUNT(f.film_id) AS amount FROM film f
 INNER JOIN language l ON f.language_id = l.language_id GROUP BY l.language_id) AS B ON A.language_id = B.language_id
 SET A.films_no = B.amount;

17.
UPDATE film SET language_id = (SELECT language_id FROM language WHERE language.name = "Mandarin") WHERE film.title = "WON DARES";

UPDATE film f INNER JOIN film_actor fa on f.film_id = fa.film_id INNER JOIN actor a ON fa.actor_id = a.actor_id
 SET f.language_id = (SELECT language_id FROM language WHERE language.name = "German")
 WHERE a.first_name = "NICK" AND a.last_name = "WAHLBERG";

UPDATE language A INNER JOIN (SELECT l.language_id, COUNT(f.film_id) AS amount FROM film f
 INNER JOIN language l ON f.language_id = l.language_id GROUP BY l.language_id) AS B ON A.language_id = B.language_id
 SET A.films_no = B.amount;

18.
ALTER TABLE film DROP COLUMN release_year;
