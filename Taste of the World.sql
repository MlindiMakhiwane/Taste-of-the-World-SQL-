--------------------------------------------------------------------
-- DATA PROJECT 
-- DATA SOURCE: RESTAURANT ORDERS - MAVEN ANALYTICS - https://mavenanalytics.io/data-playground?pageSize=10

-- SERVER NAME: D*****P*E******

-- DATABASE NAME: Maven_Analytics_Data_Analyst_Portfolio_Project_Restaurant_Orders

-- DATA LAST EDITED: 29 DECEMBER 2025 

/*
OBJECTIVE: Taste of the world Café is a 3-month-old small family-owned restaurant that is looking to 
streamline the menu options. The company is trying to reduce the number of menu items and as ask for your 
analysis of the data to determine what products they could potentially drop from the menu.
*/

-- COMMNETS:

----------------------------------------------------------------------------
USE Maven_Analytics_Data_Analyst_Portfolio_Project_Restaurant_Orders
GO 
-----------------------------------------------------------------------------
ALTER TABLE menu_items
ALTER COLUMN price float
GO

-- Rows Affected 32
-- COMMENT: Changing the price into floating type as data was imported as a varchar(max)
--------------------------------------------------------------------------------

EXEC sp_rename 'menu_items.price',  'gross_profit_per_item', 'COLUMN';
GO

-- COMMENT: Correcting the name of the column with in the table.
--------------------------------------------------------------------------------

SELECT * 
FROM menu_items
GO

-- Rows Affected 32 
--------------------------------------------------------------------------------

SELECT * 
FROM order_details
GO

-- Rows Affected 12 234
---------------------------------------------------------------------------------

SELECT * 
FROM order_details
WHERE item_id IS NULL
GO

-- Rows Affected 137
-- Understanding the NULL values. 137 sales can not be liked to an item id.  
---------------------------------------------------------------------------------

SELECT ROUND( (CONVERT(float,COUNT(item_id)) / COUNT(*))* 100 ,2) persentage_of_correct_data
FROM order_details
GO

-- Rows Affected 1
-- Confriming that 98.88 of the data is not null therefore complete and will be used for analysis.  
---------------------------------------------------------------------------------

SELECT MIN(order_date), MAX(order_date)
FROM order_details
GO

-- Rows Affected 1
-- Confirming that there are 3 months of data. 
--------------------------------------------------------------------------------

SELECT MONTH(order_date) AS 'month', COUNT(DISTINCT(DAY(order_date))) AS number_of_days
FROM order_details
GROUP BY MONTH(order_date)
GO

-- Rows Affected 3
-- Confirming the number of days is correct per month. 
------------------------------------------------------------------------------------

SELECT *
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GO

-- Rows Affected 12 234
-------------------------------------------------------------------------------

SELECT order_date, COUNT(DISTINCT order_id) as no_orders
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GROUP BY order_date
ORDER BY COUNT(DISTINCT order_id) DESC
GO

-- Rows Affected 90
-- Number of sales per day 
---------------------------------------------------------------------------------

SELECT 
	CASE 
	WHEN MONTH(order_date) = 1 THEN 'Jan'
	WHEN MONTH(order_date) = 2 THEN 'Feb'
	WHEN MONTH(order_date) = 3 THEN 'Mar'
	END AS 'Month'
	, COUNT(DISTINCT order_id) as no_orders
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date) 
GO 

-- Rows Affected 3
-- Number of sales per Month 
---------------------------------------------------------------------------------

SELECT *
FROM
(
SELECT item_name, category, COUNT(item_id) AS number_of_orders, DENSE_RANK() OVER (ORDER BY COUNT(item_id) DESC) AS  order_ranking
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GROUP BY item_id, item_name, category
) As ranked_table
WHERE order_ranking <= 10
GO

-- Rows Affected 10
-- Top selling items over the past 3 months 
---------------------------------------------------------------------------------

SELECT *
FROM
(
SELECT CASE 
	   WHEN MONTH(order_date) = 1 THEN 'Jan'
	   WHEN MONTH(order_date) = 2 THEN 'Feb'
       WHEN MONTH(order_date) = 3 THEN 'Mar'
       END AS 'Month' , item_name, category
	   , COUNT(item_id) AS number_of_orders
	   , DENSE_RANK() OVER (ORDER BY COUNT(item_id) DESC) AS  order_ranking
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GROUP BY item_id, item_name, MONTH(order_date), category
) As ranked_table
WHERE order_ranking <= 20
GO

-- Rows Affected 35
-- Top selling from different months
---------------------------------------------------------------------------------

SELECT *
FROM
(
SELECT  'Jan Sales' As 'Month' , item_name, category, COUNT(item_id) AS number_of_orders, DENSE_RANK() OVER (ORDER BY COUNT(item_id) DESC) AS  order_ranking
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE MONTH(order_date) = 1
GROUP BY item_id, item_name, category
) As ranked_table
WHERE order_ranking <= 10
GO
 
-- Rows Affected 11 
-- Top selling from Jan
---------------------------------------------------------------------------------

SELECT *
FROM
(
SELECT  'Feb Sales' As 'Month' , item_name, category, COUNT(item_id) AS number_of_orders, DENSE_RANK() OVER (ORDER BY COUNT(item_id) DESC) AS  order_ranking
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE MONTH(order_date) = 2
GROUP BY item_id, item_name, category
) As ranked_table
WHERE order_ranking <= 10
GO
 
-- Rows Affected 11 
-- Top selling from Feb
---------------------------------------------------------------------------------

SELECT *
FROM
(
SELECT  'Mar Sales' As 'Month' , item_name, category, COUNT(item_id) AS number_of_orders, DENSE_RANK() OVER (ORDER BY COUNT(item_id) DESC) AS  order_ranking
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE MONTH(order_date) = 3
GROUP BY item_id, item_name, category
) As ranked_table
WHERE order_ranking <= 10
GO
 
-- Rows Affected 10 
-- Top selling from Mar
---------------------------------------------------------------------------------

SELECT category, COUNT(item_id) AS number_items_sold_per_category
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GROUP BY category 
ORDER BY COUNT(item_id) DESC
GO

-- Rows Affected 5
-- Top number of items sold per category 
---------------------------------------------------------------------------------

SELECT *
FROM(
SELECT item_name, category, COUNT(item_id) number_items_sold 
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
GROUP BY item_name, category
) count_table
WHERE number_items_sold < 327
GO

-- Rows Affected 13
-- items underpeforming the lowest average items sold per category. 
---------------------------------------------------------------------------------

SELECT *
FROM (
SELECT item_name, category
		, ROUND(SUM(gross_profit_per_item),2) sum_of_gross_proift
		, DENSE_RANK() OVER (ORDER BY SUM(gross_profit_per_item) DESC) gross_proift_ranking
FROM order_details od
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE item_name IS NOT NULL
GROUP BY item_name, category
) ranked_table
WHERE gross_proift_ranking <= 10
ORDER BY gross_proift_ranking
GO

-- Rows Affected 10
-- 10 highest items per marginal profit.  
---------------------------------------------------------------------------------

SELECT *
FROM (
SELECT item_name, category
		, ROUND(SUM(gross_profit_per_item),2) AS sum_of_gross_proift
		, DENSE_RANK() OVER (ORDER BY SUM(gross_profit_per_item)) AS gross_profit_ranking
FROM order_details od  
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE category IS NOT NULL
GROUP BY item_name, category
) AS Ranked_table
ORDER BY gross_profit_ranking
GO

-- Rows Affected 10
-- lowest selling items per gross profit.  

-----------------------------------------------------------------------------

SELECT category, ROUND(SUM(gross_profit_per_item),2) AS sum_gross_profit
FROM order_details od  
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE item_name IS NOT NULL
GROUP BY category
ORDER BY ROUND(SUM(gross_profit_per_item),2) DESC

-- Rows Affected 4
-- Determining the gross profit per category  
---------------------------------------------------------------------------------

SELECT *
FROM(
SELECT item_name, category 
		, ROUND(SUM(gross_profit_per_item),2) AS sum_of_gross_profit
		, DENSE_RANK() OVER (ORDER BY SUM(gross_profit_per_item) DESC) AS gross_profit_ranking
		, COUNT (menu_item_id) AS number_of_orders
		, DENSE_RANK() OVER (ORDER BY COUNT(menu_item_id) DESC) AS number_of_orders_ranking
FROM order_details od  
LEFT JOIN menu_items mi 
ON od.item_id = menu_item_id
WHERE item_name IS NOT NULL
GROUP BY item_name, category
) ranked_table
ORDER BY gross_profit_ranking , number_of_orders_ranking 

-- Rows Affected 32
-- Ranking items based on the sum of gross profit and number of items sold.
---------------------------------------------------------------------------------
