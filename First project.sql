-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2;

-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
	(
		transactions_id INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT,
		gender VARCHAR(15),
		age INT,
		category VARCHAR(15),
		quantiy INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
	);
	
SELECT * FROM retail_sales 
LIMIT 10;

SELECT COUNT(*) FROM retail_sales;

-- Data cleaning
SELECT * FROM retail_sales 
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

-- Data Exploration

-- How many sales?
SELECT COUNT(*) FROM retail_sales;

-- How many customers we have?
SELECT COUNT(DISTINCT(customer_id)) FROM retail_sales;

-- How many categories we have?
SELECT COUNT(DISTINCT(category)) FROM retail_sales;

-- Data Analysis or Business Key Problems and Answers

-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT * FROM retail_sales
	WHERE category = 'Clothing' 
	AND quantiy > 4 
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category:
SELECT category, SUM(total_sale) as total_sales FROM retail_sales
	GROUP BY category;

-- 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category:
SELECT ROUND(AVG(age),0) FROM retail_sales
	WHERE category = 'Beauty';
	
-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000:
SELECT * FROM retail_sales
	WHERE total_sale > 1000;

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category:
SELECT gender, COUNT(transactions_id) FROM retail_sales
	GROUP BY gender;

-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
SELECT year, month, avg_sale
FROM (
  SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS avg_sale,
    RANK() OVER (
      PARTITION BY EXTRACT(YEAR FROM sale_date)
      ORDER BY AVG(total_sale) DESC
    ) AS rank
  FROM retail_sales
  GROUP BY year, month
) AS t1
WHERE rank = 1;

-- 8. Write a SQL query to find the top 5 customers based on the highest total sales:
SELECT customer_id, ROUND(SUM(total_sale)::numeric,3)
FROM retail_sales
GROUP BY customer_id
ORDER BY ROUND(SUM(total_sale)::numeric,3) DESC
LIMIT 5;

-- 9. Write a SQL query to find the number of unique customers who purchased items from each category:
SELECT category, COUNT( DISTINCT customer_id) 
FROM retail_sales
GROUP BY category;

-- 10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sales -- WITH table_name AS() 
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales)
SELECT shift, COUNT(*) as total_orders FROM hourly_sales
GROUP BY shift;

-- 11. Find the total revenue generated per day.
SELECT sale_date, SUM(total_sale) as daily_sale 
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;

-- 12. Which category had the highest average sale per transaction?
SELECT category, AVG(total_sale) as avg_sale
FROM retail_sales
GROUP BY category
ORDER BY AVG(total_sale) DESC
LIMIT 1;

-- 13. Find the number of transactions by age group (e.g., 18–25, 26–35, etc.).
WITH sales
AS
(
SELECT
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 47 THEN '36-47'
	 	ELSE '47+'
	END as age_group
FROM retail_sales)
SELECT age_group, COUNT(*) as num_trans
FROM sales
GROUP BY age_group
ORDER BY num_trans DESC;

-- or this question can be simply answered as follows
SELECT
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 47 THEN '36-47'
	 	ELSE '47+'
	END as age_group, COUNT(*) as num_trans
FROM retail_sales
GROUP BY age_group
ORDER BY num_trans DESC;

-- 14. What is the average quantity sold per category and gender?
SELECT category, gender, ROUND(AVG(quantiy),4) AS avg_quant
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- 15. Which customer made the most purchases in a single day?
SELECT customer_id, sale_date, COUNT(*) AS num_pur 
FROM retail_sales
GROUP BY customer_id, sale_date
ORDER BY num_pur DESC
LIMIT 1;

-- 16. Which day of the week generates the most revenue on average?
SELECT TO_CHAR(sale_date, 'Day') AS weekday, AVG(total_sale) AS avg_rev
FROM retail_sales
GROUP BY sale_date
ORDER BY avg_rev DESC
LIMIT 1;

-- 17. Find monthly sales growth rate.
WITH monthly_sales
AS(
SELECT 
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	SUM(total_sale) AS total
FROM retail_sales
GROUP BY year, month
ORDER BY year, month
),
growth 
AS(
SELECT month, total, LAG(total) OVER(ORDER BY month) AS prev_total
FROM monthly_sales
)
SELECT
	month, 
	ROUND(((total- prev_total)/NULLIF(prev_total, 0)* 100)::numeric,2) AS growth_rate
FROM growth;

-- 18. Identify the top product category for each gender.
WITH prod_cut
AS(
SELECT category, gender, SUM(total_sale) AS sales,
	RANK() OVER(
		PARTITION BY gender
		ORDER BY SUM(total_sale) DESC
	) AS rank
FROM retail_sales
GROUP BY gender, category
)
SELECT gender,category, sales
FROM prod_cut
WHERE rank=1;

-- 19. Determine the average time between repeat purchases per customer.
WITH cust_orders
AS(
SELECT customer_id, sale_date,
	LAG(sale_date) OVER(
	PARTITION BY customer_id
	ORDER BY sale_date
	) AS prev_pur_date
FROM retail_sales
),
time_diff
AS(
SELECT customer_id, sale_date, prev_pur_date,
	(sale_date - prev_pur_date) AS days_between
FROM cust_orders
WHERE prev_pur_date IS NOT NULL
)
SELECT 
	customer_id,
	ROUND(AVG(days_between),2) AS avg_days_between_pur
FROM time_diff
GROUP BY customer_id
ORDER BY avg_days_between_pur;
