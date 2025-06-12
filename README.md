# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner, intermediate and advanced
**Database**: `p1_retail_db`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT * FROM retail_sales
	WHERE category = 'Clothing' 
	AND quantiy > 4 
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT category, SUM(total_sale) as total_sales FROM retail_sales
	GROUP BY category;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT ROUND(AVG(age),0) FROM retail_sales
	WHERE category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
	WHERE total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT gender, COUNT(transactions_id) FROM retail_sales
	GROUP BY gender;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT customer_id, ROUND(SUM(total_sale)::numeric,3)
FROM retail_sales
GROUP BY customer_id
ORDER BY ROUND(SUM(total_sale)::numeric,3) DESC
LIMIT 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT category, COUNT( DISTINCT customer_id) 
FROM retail_sales
GROUP BY category;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

11. **Find the total revenue generated per day.**
```sql
SELECT sale_date, SUM(total_sale) as daily_sale 
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;
```

12. **Which category had the highest average sale per transaction?**
```sql
SELECT category, AVG(total_sale) as avg_sale
FROM retail_sales
GROUP BY category
ORDER BY AVG(total_sale) DESC
LIMIT 1;
```

13. **Find the number of transactions by age group (e.g., 18–25, 26–35, etc.).**
```sql
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
-- or this question can be answered as follows
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
```

14. **What is the average quantity sold per category and gender?**
```sql
SELECT category, gender, ROUND(AVG(quantiy),4) AS avg_quant
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

15. **Which customer made the most purchases in a single day?**
```sql
SELECT customer_id, sale_date, COUNT(*) AS num_pur 
FROM retail_sales
GROUP BY customer_id, sale_date
ORDER BY num_pur DESC
LIMIT 1;
```

16. **Which day of the week generates the most revenue on average?**
```sql
SELECT TO_CHAR(sale_date, 'Day') AS weekday, AVG(total_sale) AS avg_rev
FROM retail_sales
GROUP BY sale_date
ORDER BY avg_rev DESC
LIMIT 1;
```

17. Find the monthly sales growth rate.
```sql
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
```

18. **Identify the top product category for each gender.**
```sql
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
SELECT gender, category, sales
FROM prod_cut
WHERE rank=1;
```

19. Determine the average time between repeat purchases per customer.
```sql
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
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with a near-equal gender distribution.
- **Category Insights**: Popular categories like Clothing and Beauty had the highest number of purchases. Beauty buyers had a slightly lower average age.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons. The best-selling month in each year was identified by analyzing average monthly sales. Sales distribution across shifts showed that most purchases occurred in the Afternoon and Evening.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories. The average time between repeat purchases per customer was calculated, helping to understand engagement frequency.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance. Top-selling months and products by revenue.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category. Repeat purchase behavior and average gap between visits.
- **Time-Based Analytics**: Revenue trends by date and month. Average sales by day of the week. Monthly sales growth rates.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Asanda Mafuleka
