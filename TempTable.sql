
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS name,
    cu.email,
    COUNT(re.rental_id) AS rental_count
FROM customer cu
JOIN rental re ON cu.customer_id = re.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, cu.email;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 
-- to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    crs.name,
    crs.email,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id, crs.name, crs.email;

SELECT * FROM customer_payment_summary;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table 
-- created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH Customer_Summary_Report AS (
  SELECT 
    crs.name,
    crs.email,
    crs.rental_count,
    cps.total_paid
  FROM customer_rental_summary crs
  JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT *
FROM Customer_Summary_Report;

-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.

WITH Customer_Summary_Report AS (
  SELECT 
    crs.name,
    crs.email,
    crs.rental_count,
    cps.total_paid
  FROM customer_rental_summary crs
  JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT 
    name,
    email,
    rental_count,
    total_paid,
    total_paid / NULLIF(rental_count, 0) AS average_payment_per_rental
FROM Customer_Summary_Report;
