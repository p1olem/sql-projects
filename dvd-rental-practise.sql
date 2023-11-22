--Dataset: https://www.kaggle.com/datasets/atanaskanev/sqlite-sakila-sample-database
--Queried using sqlite3 library in Python

--1. Retrieve First name and Last name of all actors.

SELECT 
	first_name || ' ' || last_name AS 'Actor name'
FROM actor
ORDER BY first_name;

--2. Retrieve id and last name of customers who made payment at store 2 and which is at least 6.99.

SELECT 
	c.customer_id AS 'Customer ID',
	c.last_name AS 'Last Name'
FROM customer c  
JOIN payment p
ON c.customer_id = p.customer_id
WHERE p.amount >= 6.99 
AND staff_id IN (
                SELECT staff_id
                FROM staff
                WHERE store_id=2)
GROUP BY c.customer_id;

--3. Make changes to the database: rental_rate of film with id=360 has changed and now is equal to 4.99.
  
UPDATE film
SET rental_rate = 4.99
WHERE film_id = 360;

--4. Retrieve the id of the payment and a month in which it was realized.

SELECT 
	payment_id AS 'Payment ID' , 
	strftime('%m', payment_date) AS 'Month'
FROM payment;

--5. Display id, title, category, length, release year and id of films that belong to one of these film categories: Drama, Horror, Sci-Fi. Group by film categories and order by length in ascending mode.

SELECT 
	f.title AS 'title',
	a.name AS 'category',
	f.length AS 'length',
	f.release_year AS 'year',
	f.film_id AS 'id'
FROM film_category c
JOIN film f 
ON f.film_id = c.film_id
JOIN category a
ON c.category_id = a.category_id
WHERE a.name IN ('Drama', 'Horror', 'Sci-Fi')
ORDER BY a.name, f.length;

--6. Display title and description of films that start with letter 'B' and have word 'kill' in description

SELECT 
	title,
	description   
FROM film 
WHERE title LIKE 'B%' AND description like '%kill%';

--7. Retrieve the id of customers who rented film excluding period between 2005-06-21 and 2005-08-01 and weren't serviced by staff with id=1.

SELECT 
	customer_id, 
	rental_date
FROM rental 
WHERE rental_date NOT BETWEEN '2005-06-21' AND '2005-08-01'
AND staff_id <> 1;

--8. Show how many copies of each film is in each store's inventory.

SELECT
	film_id,
	COUNT(CASE WHEN store_id=1 THEN 1 END) AS 'store 1 copies',
	COUNT(CASE WHEN store_id=2 THEN 1 END) AS 'store 2 copies'
FROM inventory
GROUP BY film_id;
    
--9. For each month, display the total payments and average payment value per customer. Round values to 0 and 2 decimal places for total and average payments value, respectively.

SELECT  
  strftime('%Y-%m', payment_date) AS 'Date',
  ROUND(SUM(amount), 0) AS 'Total Sales',
  ROUND(ROUND(SUM(amount), 0)/COUNT(payment_id),2) AS 'Average Sale'
FROM payment
GROUP BY Date
ORDER BY Date ASC;

--10. Display id and email of those customers that have made at least 30 payments.

SELECT 
	p.customer_id AS 'id',
	c.email AS 'email',
	count(*) AS 'number of payments'
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
group by p.customer_id
HAVING COUNT(*) >= 30; 

--11. Display id of customers whose value of total payments is more than the average payment per customer.

SELECT
	id,
	total_payments
FROM (SELECT 
	customer_id AS 'id',
	SUM(amount) AS 'total_payments'
      FROM payment
      GROUP BY customer_id) AS p
WHERE total_payments > (
    SELECT 
        SUM(amount)/COUNT(DISTINCT customer_id) 
    FROM payment); 

--12. Find the 2nd lowest payment amount.

SELECT 
	MIN(amount) AS '2nd lowest payment amount'
FROM payment 
WHERE amount NOT IN ( 
	SELECT 
		MIN(amount) 
	FROM payment);
