USE sakila;

CREATE OR REPLACE VIEW customer_rental_summary AS 
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r
    ON  c.customer_id = r.customer_id
GROUP BY c.customer_id, customer_name, c.email;
    
 


SHOW FULL TABLES LIKE 'customer_payment_summary';

DROP TABLE IF EXISTS customer_payment_summary;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary AS crs
LEFT JOIN payment AS p
    ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;


WITH customer_summary AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid,
        ROUND(cps.total_paid / NULLIF(crs.rental_count, 0), 2) AS average_payment_per_rental
    FROM customer_rental_summary AS crs
    JOIN customer_payment_summary AS cps
        ON crs.customer_id = cps.customer_id
)
SELECT * 
FROM customer_summary
ORDER BY total_paid DESC
LIMIT 20;
