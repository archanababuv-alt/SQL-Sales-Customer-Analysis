show databases;

create database archana_project;

use archana_project;

select * from sales;

# 1. list  customers who are senior citizens

select customerID,gender,seniorCitizen,Monthlycharges 
from customer where seniorCitizen = 1;

# 2 find customers who have a partner and dependents

select customerID,gender,partner,dependents
from customer where partner = 'yes'
and dependents = 'yes';

#3.find the 10 customers with the highest monthly charges

select customerid,monthlycharges from customer order by monthlycharges desc limit 10;

#4.list customers who use fiber optics internet service

select customerid,contract,monthlycharges from customer
where internetservice = 'fiber optics';

#5.find customers who have a month to month contract

select customerid,contract,monthlycharges from customer
where contract = 'month-to-month';

#6.display all customer who are from united states
select * from sales where country= 'united states';

#7. find the total sales amount  from the sales table

select sum(sales)as total_sales from sales;

#8 find the total profit generated from all sales

select sum(profit)as total_profit from sales;

#9. Find total sales for each category.
SELECT
    Category,
    SUM(Sales) AS total_sales
FROM sales
GROUP BY Category
ORDER BY total_sales DESC;

#10. Find the average sales for each region.
SELECT
    Region,
    AVG(Sales) AS average_sales
FROM sales
GROUP BY Region
ORDER BY average_sales DESC;

#11.Find categories where total profit is greater than 10,000.
SELECT
    Category,
    SUM(Profit) AS total_profit
FROM sales
GROUP BY Category
HAVING SUM(Profit) > 10000;

#12 Find the total quantity sold for each category.
SELECT
    Category,
    SUM(Quantity) AS total_quantity
FROM sales
GROUP BY Category
ORDER BY total_quantity DESC;

#13. Rank products by total sales within each category.
WITH product_sales AS (
    SELECT
        Category,
        `Product Name`,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY Category, `Product Name`
)
SELECT
    Category,
    `Product Name`,
    total_sales,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM product_sales;

#14.Find customers whose total sales are greater than the average customer sales.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales
FROM sales
GROUP BY
    `Customer ID`,
    `Customer Name`
HAVING SUM(Sales) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            `Customer ID`,
            SUM(Sales) AS customer_total
        FROM sales
        GROUP BY `Customer ID`
    ) AS customer_sales
)
ORDER BY total_sales DESC;

#15.Find the top 3 customers in each region based on total sales.

WITH customer_sales AS (
    SELECT
        Region,
        `Customer ID`,
        `Customer Name`,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY
        Region,
        `Customer ID`,
        `Customer Name`
),
ranked_customers AS (
    SELECT
        Region,
        `Customer ID`,
        `Customer Name`,
        total_sales,
        RANK() OVER (
            PARTITION BY Region
            ORDER BY total_sales DESC
        ) AS customer_rank
    FROM customer_sales
)
SELECT *
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY Region, customer_rank;

#16.Calculate yearly sales and compare them with the previous year.

WITH yearly_sales AS (
    SELECT
        YEAR(`Order Date`) AS sales_year,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY YEAR(`Order Date`)
)
SELECT
    sales_year,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY sales_year
    ) AS previous_year_sales
FROM yearly_sales;

#17. Create a monthly sales summary view.

CREATE VIEW monthly_sales_summary AS
SELECT
    YEAR(`Order Date`) AS sales_year,
    MONTH(`Order Date`) AS sales_month,
    SUM(Sales) AS total_sales,
    SUM(Quantity) AS total_quantity,
    SUM(Profit) AS total_profit
FROM sales
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`);
    
#18.Create a procedure to get a customer's complete order history.

DELIMITER //

CREATE PROCEDURE get_customer_history(
    IN p_customer_id VARCHAR(20)
)
BEGIN

    SELECT
        `Order ID`,
        `Order Date`,
        `Ship Date`,
        `Ship Mode`,
        `Customer ID`,
        `Customer Name`,
        `Product ID`,
        `Product Name`,
        Category,
        `Sub-Category`,
        Sales,
        Quantity,
        Discount,
        Profit
    FROM sales
    WHERE `Customer ID` = p_customer_id
    ORDER BY `Order Date`;

END //

DELIMITER ;

#17.Find the top 2 products by total sales in each category.

WITH product_sales AS (
    SELECT
        Category,
        `Product Name`,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY
        Category,
        `Product Name`
),
ranked_products AS (
    SELECT
        Category,
        `Product Name`,
        total_sales,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY total_sales DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    Category,
    `Product Name`,
    total_sales,
    product_rank
FROM ranked_products
WHERE product_rank <= 2
ORDER BY Category, product_rank;

#18.Find customers whose total profit is greater than the average customer profit.

SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Profit) AS total_profit
FROM sales
GROUP BY
    `Customer ID`,
    `Customer Name`
HAVING SUM(Profit) > (
    SELECT AVG(customer_profit)
    FROM (
        SELECT
            `Customer ID`,
            SUM(Profit) AS customer_profit
        FROM sales
        GROUP BY `Customer ID`
    ) AS customer_summary
)
ORDER BY total_profit DESC;

#19.  Find the highest-selling product in each category.

WITH product_sales AS (
    SELECT
        Category,
        `Product Name`,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY Category, `Product Name`
),
ranked_products AS (
    SELECT
        Category,
        `Product Name`,
        total_sales,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM product_sales
)
SELECT
    Category,
    `Product Name`,
    total_sales
FROM ranked_products
WHERE sales_rank = 1;

#20. Find products whose total profit is negative.

SELECT
    `Product ID`,
    `Product Name`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM sales
GROUP BY
    `Product ID`,
    `Product Name`
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC;

#21.Calculate the profit margin for each category.

WITH category_summary AS (
    SELECT
        Category,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit
    FROM sales
    GROUP BY Category
)
SELECT
    Category,
    total_sales,
    total_profit,
    ROUND(
        (total_profit / total_sales) * 100,
        2
    ) AS profit_margin_percentage
FROM category_summary
ORDER BY profit_margin_percentage DESC;

#22.Find customers who purchased products from more than 3 different categories.

SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT Category) AS category_count,
    SUM(Sales) AS total_sales
FROM sales
GROUP BY
    `Customer ID`,
    `Customer Name`
HAVING COUNT(DISTINCT Category) > 3
ORDER BY category_count DESC, total_sales DESC;

#23.Calculate the cumulative sales for each customer based on order date.

SELECT
    `Customer ID`,
    `Customer Name`,
    `Order Date`,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY `Customer ID`
        ORDER BY `Order Date`
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales
FROM sales
ORDER BY `Customer ID`, `Order Date`;
