-- Creating Database & importing the data

CREATE DATABASE coffee_shop;

SELECT * FROM coffee_shop_sales;

DESCRIBE coffee_shop_sales;

-- Data Cleaning & Transformation

-- Formatting the 'transaction_date' column and then changing the data type to date

SET SQL_SAFE_UPDATES = 0;

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- Formatting the 'transaction_time' column and then changing the data type to time

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

DESCRIBE coffee_shop_sales;

-- Changing column name 'ï»¿transaction_id' to 'transaction_id'

ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

DESCRIBE coffee_shop_sales;

SET SQL_SAFE_UPDATES = 1;

-- Coffee Shop analysis - Extracting Key insights from the data

-- Month-wise Total Sales

SELECT MONTHNAME(transaction_date), SUM(transaction_qty * unit_price) AS total_sales
FROM coffee_shop_sales
GROUP BY MONTHNAME(transaction_date);

-- Month on Month increase/decrease in sales (%)

DELIMITER //
CREATE FUNCTION get_salesdiff_from_previous_month(month_number INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE sales_diff DECIMAL(10,2);
    WITH monthly_sales AS(
	SELECT MONTH(transaction_date) AS month_no, SUM(transaction_qty * unit_price) AS total_sales
	FROM coffee_shop_sales
	GROUP BY MONTH(transaction_date))

	SELECT ((SELECT total_sales
			FROM monthly_sales
			WHERE month_no = month_number) - 
		   (SELECT total_sales
			FROM monthly_sales
			WHERE month_no = (month_number-1))) / 
           (SELECT total_sales
			FROM monthly_sales
			WHERE month_no = (month_number-1)) * 100 
            INTO sales_diff;
    RETURN sales_diff;
END;
//
DELIMITER ;

SELECT get_salesdiff_from_previous_month(2) AS feb_d;
SELECT get_salesdiff_from_previous_month(3) AS mar_d;
SELECT get_salesdiff_from_previous_month(4) AS apr_d;
SELECT get_salesdiff_from_previous_month(6) AS june_d;

-- Number of orders per month

SELECT MONTHNAME(transaction_date) AS month_name, COUNT(transaction_id)
FROM coffee_shop_sales
GROUP BY MONTHNAME(transaction_date);

-- Month on Month increase/decrease in the numbers of orders

SELECT MONTH(transaction_date) AS month_no, 
	   COUNT(transaction_id) AS orders, 																			-- Number of Orders
       COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) OVER(ORDER BY MONTH(transaction_date)) AS orders_diff, -- increase/decrease in orders from the previous month
       (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) OVER(ORDER BY MONTH(transaction_date))) /
       LAG(COUNT(transaction_id), 1) OVER(ORDER BY MONTH(transaction_date)) * 100 AS orders_diff_perc 				-- increase/decrease percentage in orders
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date);

-- Total Quantity Sold per month

SELECT MONTHNAME(transaction_date) AS month_name, SUM(transaction_qty) AS total_quantities_sold
FROM coffee_shop_sales
GROUP BY MONTHNAME(transaction_date);

-- Month on Month increase/decrease in the Total Quantities Sold

SELECT MONTH(transaction_date) AS month_no, 
	   SUM(transaction_qty) AS Total_Quantities_Sold, 																	   -- Total Quantities Sold
       SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) OVER(ORDER BY MONTH(transaction_date)) AS Quantities_Sold_diff, -- increase/decrease in Quantities Sold from the previous month
       (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) OVER(ORDER BY MONTH(transaction_date))) /
       LAG(SUM(transaction_qty), 1) OVER(ORDER BY MONTH(transaction_date)) * 100 AS Quantities_Sold_diff_perc 			   -- increase/decrease percentage in Quantities Sold
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date);

-- Hours and Months Pivot table for Total Sales

WITH month_hour_sales AS(
SELECT MONTHNAME(transaction_date) AS month_name ,HOUR(transaction_time) AS hour, SUM(transaction_qty * unit_price) AS sales
FROM coffee_shop_sales
GROUP BY MONTHNAME(transaction_date) ,HOUR(transaction_time))

SELECT hour,
	SUM(CASE WHEN month_name = 'January' THEN sales ELSE 0 END) AS January,
    SUM(CASE WHEN month_name = 'February' THEN sales ELSE 0 END) AS February,
    SUM(CASE WHEN month_name = 'March' THEN sales ELSE 0 END) AS March,
    SUM(CASE WHEN month_name = 'April' THEN sales ELSE 0 END) AS April,
    SUM(CASE WHEN month_name = 'May' THEN sales ELSE 0 END) AS May,
    SUM(CASE WHEN month_name = 'June' THEN sales ELSE 0 END) AS June
FROM month_hour_sales
GROUP BY hour
ORDER BY hour;

-- Date wise Sales, Orders and Total Quantity Sold

SELECT transaction_date,
	   CONCAT(ROUND(SUM(transaction_qty * unit_price)/1000, 1), "k") AS sales,
       CONCAT(ROUND(COUNT(transaction_id)/1000, 1), "k") AS orders,
       CONCAT(ROUND(SUM(transaction_qty)/1000, 1), "k") AS Total_Quantities_Sold
FROM coffee_shop_sales
GROUP BY transaction_date
ORDER BY transaction_date;

-- Sales on weekdays and weekends

WITH date_sales AS (
SELECT DISTINCT(transaction_date), WEEKDAY(transaction_date),
	   CASE
		WHEN WEEKDAY(transaction_date) < 5 THEN 'Weekday'
        ELSE 'Weekend'
       END AS week_day,
       SUM(transaction_qty * unit_price) AS sales
FROM coffee_shop_sales
GROUP BY transaction_date
ORDER BY transaction_date)

SELECT MONTHNAME(transaction_date) AS t_date, 
	   SUM(CASE WHEN week_day='Weekday' THEN sales ELSE 0 END) AS Weekday_sales,
       SUM(CASE WHEN week_day='Weekend' THEN sales ELSE 0 END) AS Weekend_sales
FROM date_sales
GROUP BY MONTHNAME(transaction_date);

-- Location wise sales

SELECT MONTH(transaction_date) AS month_no, store_location, CONCAT(ROUND(SUM(transaction_qty * unit_price)/1000, 1), "K") AS sales
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date), store_location
ORDER BY MONTH(transaction_date), SUM(transaction_qty * unit_price) DESC;

-- Date wise Sales

SELECT transaction_date, SUM(transaction_qty * unit_price) AS total_sales
FROM coffee_shop_sales
GROUP BY transaction_date
ORDER BY transaction_date;

-- Monthly Average Sales

WITH date_sales AS(
SELECT transaction_date, SUM(transaction_qty * unit_price) AS total_sales
FROM coffee_shop_sales
GROUP BY transaction_date)

SELECT MONTH(transaction_date) AS month_no, CONCAT(ROUND(AVG(total_sales)/1000, 1), 'K') AS avg_sales
FROM date_sales
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

-- Comparing everyday sales to monthly average

WITH date_sales AS(
SELECT MONTH(transaction_date) AS month_number,
	   transaction_date, 
	   SUM(transaction_qty * unit_price) AS day_sales
FROM coffee_shop_sales
GROUP BY transaction_date)

SELECT *,
	   AVG(day_sales) OVER(PARTITION BY month_number) AS avg_monthly_sales,
       CASE
		WHEN day_sales > AVG(day_sales) OVER(PARTITION BY month_number) THEN 'Above Average'
        WHEN day_sales < AVG(day_sales) OVER(PARTITION BY month_number) THEN 'Below Average'
        ELSE 'Average'
       END AS sales_status
FROM date_sales
ORDER BY transaction_date;

-- Sales by product category

SELECT product_category, SUM(transaction_qty * unit_price) AS sales
FROM coffee_shop_sales
GROUP BY product_category
ORDER BY SUM(transaction_qty * unit_price) DESC;

-- Date and Hour wise sales, number of orders and quantity sold

SELECT transaction_date, 
	   HOUR(transaction_time) AS hour, 
	   SUM(transaction_qty * unit_price) AS sales,
       COUNT(transaction_id) AS orders,
       SUM(transaction_qty) AS quantity_sold
FROM coffee_shop_sales
GROUP BY transaction_date, HOUR(transaction_time)
ORDER BY transaction_date, HOUR(transaction_time); -- (you can where clause to navigate to a particular day and hour)

-- Hour wise total sales

SELECT HOUR(transaction_time) AS hour, SUM(transaction_qty * unit_price) AS sales
FROM coffee_shop_sales
GROUP BY HOUR(transaction_time)
ORDER BY SUM(transaction_qty * unit_price) DESC;

-- Day wise Sales

SELECT DISTINCT(DAYNAME(transaction_date)) AS weekday, 
	   ROUND(SUM(transaction_qty * unit_price) OVER(PARTITION BY DAYNAME(transaction_date)) /
       SUM(transaction_qty * unit_price) OVER() * 100, 2) AS week_sales_percentage
FROM coffee_shop_sales;