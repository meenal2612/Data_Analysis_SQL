use global_superstore_project;
-- Q1. Find out the total profit, sales, discount and shipping cost according to segment.

CREATE VIEW Q1 AS
    (SELECT 
        segment,
        ROUND(SUM(profit), 2) total_profit,
        ROUND(SUM(sales), 2) total_sales,
        ROUND(SUM(ShippingCost), 2) total_shippingcost,
        ROUND(SUM(discount), 2) total_discount
    FROM
        orders
    GROUP BY segment);
SELECT 
    *
FROM
    Q1;

-- Q2. Top 10 corporate customer who gave best sale.
CREATE VIEW Q2 AS
    (SELECT 
        customername, ROUND(SUM(sales), 2) Total_sales
    FROM
        orders
    WHERE
        segment = 'corporate'
    GROUP BY customername
    ORDER BY total_sales DESC
    LIMIT 10);
SELECT 
    *
FROM
    Q2;

-- Q3. How many order received in India on each segment?
CREATE VIEW Q3 AS
    (SELECT 
        segment, COUNT(orderid)
    FROM
        orders
    WHERE
        country = 'INDia'
    GROUP BY segment);
SELECT 
    *
FROM
    Q3;

-- Q4 What would be the % of profit with respect to sales for santiago state by each order priority. 

CREATE VIEW Q4 AS
    (SELECT 
        OrderPriority,
        ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS Profit_Percentage
    FROM
        orders
    WHERE
        state = 'santiago'
    GROUP BY OrderPriority);
SELECT 
    *
FROM
    Q4;

-- Q5 What is the avg shipping cost of 1st class for top 15 customers in south-east asia for home office site?

CREATE VIEW Q5 AS
    (SELECT 
        CustomerName, AVG(ShippingCost) AvgShippingCost
    FROM
        orders
    WHERE
        region = 'Southeast Asia'
            AND segment = 'Home Office'
            AND shipmode = 'First class'
    GROUP BY CustomerName);

SELECT 
    *
FROM
    Q5
ORDER BY AvgShippingCost DESC
LIMIT 15;

-- Q6 What are the total no of orders for each catagory by each segment order date wise?
CREATE VIEW Q6 AS
    (SELECT 
        category, segment, YEAR(orderdate), COUNT(orderid)
    FROM
        orders
    GROUP BY category , segment , YEAR(orderdate));
SELECT 
    *
FROM
    Q6;

-- Q7 How many product shipped by first class in each priority.
CREATE VIEW Q7 AS
    (SELECT 
        OrderPriority, COUNT(productid)
    FROM
        orders
    WHERE
        shipmode = 'First Class'
    GROUP BY OrderPriority);
SELECT 
    *
FROM
    Q7;

-- Q8  Find out total sales and profit for each category with low order priority and zero discount.
CREATE VIEW Q8 AS
    (SELECT 
        category, SUM(sales) total_sales, SUM(profit) total_profit
    FROM
        orders
    WHERE
        Discount = 0
            AND OrderPriority RLIKE 'low'
    GROUP BY category);
SELECT 
    *
FROM
    Q8;

-- Q9. Name the cities of Australia with % of sales?

CREATE VIEW Q9 AS
    (SELECT 
        city,
        CONCAT(ROUND((SUM(sales) / (SELECT 
                                SUM(Sales)
                            FROM
                                orders
                            WHERE
                                country = 'Australia')) * 100,
                        2),
                '%') AS Sales_Percentage
    FROM
        orders
    WHERE
        country = 'Australia'
    GROUP BY city);

SELECT 
    *
FROM
    Q9;

-- Q10. What is the total sales and quantity for top 5  samsung products in APAC Market for the year 2014?

CREATE VIEW Q10 AS
    (SELECT 
        ProductName,
        SUM(Sales) total_sales,
        SUM(quantity) total_quantity
    FROM
        orders
    WHERE
        ProductName LIKE '%Samsung%'
            AND market = 'apac'
            AND YEAR(orderdate) = 2014
    GROUP BY ProductName);

SELECT 
    *
FROM
    Q10
ORDER BY total_sales
LIMIT 5;


-- Q11. What % of shipping cost contribute in sales for Nokia Products in NEW ZEALAND country ?
CREATE VIEW Q11 AS
    (SELECT 
        ProductName,
        ROUND((SUM(shippingcost) / SUM(sales)) * 100,
                2) shippingCost_Percent_outOfSales
    FROM
        orders
    WHERE
        ProductName LIKE '%nokia%'
            AND country = 'New Zealand'
    GROUP BY ProductName , country
    ORDER BY shippingCost_Percent_outOfSales DESC);

SELECT 
    *
FROM
    Q11;

SELECT 
    *
FROM
    orders;

-- Q12.Write a query to find the top 10 products by total sales

CREATE VIEW Q12 AS
    (SELECT 
        productname, ROUND(SUM(sales), 2) AS Total_sales
    FROM
        orders
    GROUP BY productname);

SELECT 
    *
FROM
    Q12
ORDER BY total_sales DESC
LIMIT 10;

-- Q13. Show yearly sales trends for all years.
create view Q13 as(with cte as (select extract(year from orderdate) as Yr,round(sum(Sales),0) as Current_total_sales
from orders
group by 1
order by 1),
cte2 as (select Yr,Current_total_sales,coalesce(lag(Current_total_sales,1) over(),"NA") as prev_total_sales
from cte)
select Yr,Current_total_sales,prev_total_sales,coalesce(concat(round(((Current_total_sales-prev_total_sales)/prev_total_sales)*100,2),"%"),"NA") as growth_percent
from cte2);

SELECT 
    *
FROM
    Q13;


-- Q14 Show yearly sales trends for all months.
create view Q14 as (
with cte as (select extract(year from orderdate) as yr,extract(month from orderdate) as mnth,
round(sum(sales),2) as current_mnth_total_sales from orders
group by extract(year from orderdate),extract(month from orderdate) order by 1,2),
cte2 as (select yr,mnth,current_mnth_total_sales,coalesce(lag(current_mnth_total_sales,1)over(partition by yr),"NA") as prev_month_sales 
from cte)
select yr,mnth,current_mnth_total_sales,prev_month_sales,coalesce(concat(round(((current_mnth_total_sales-prev_month_sales)/prev_month_sales)*100,2),"%"),"NA") as growth_percent
from cte2);

SELECT 
    *
FROM
    Q14;
desc orders;


-- Q15.Find customers who placed more than 30 orders in a single year.

CREATE VIEW Q15 AS
    (SELECT 
        *
    FROM
        (SELECT 
            EXTRACT(YEAR FROM orderdate) yr,
                customerid,
                COUNT(orderid) total_orders
        FROM
            orders
        GROUP BY 1 , customerid
        ORDER BY 1 , 2) AS t1
    WHERE
        total_orders > 30);

SELECT 
    *
FROM
    Q15;

-- Q16. Compare sales vs. profit across different regions.
CREATE VIEW Q16 AS
    (SELECT 
        region,
        ROUND(SUM(sales), 2) AS total_Sales,
        ROUND(SUM(profit), 0) AS total_profit
    FROM
        orders
    GROUP BY region);

SELECT 
    *
FROM
    Q16;

-- Q17. Show monthly sales trends for the last 4 years.
create view Q17 as (with cte as (select extract(month from orderdate) as mnth,extract(year from orderdate) as yr,
round(sum(sales),2) as current_mnth_total_sales from orders
group by 1,2 order by 1,2),
cte2 as (select yr,mnth,current_mnth_total_sales,coalesce(lag(current_mnth_total_sales,1)over(partition by mnth),"NA") as prev_month_sales 
from cte)
select mnth,yr,current_mnth_total_sales,prev_month_sales,coalesce(concat(round(((current_mnth_total_sales-prev_month_sales)/prev_month_sales)*100,2),"%"),"NA") as growth_percent
from cte2 order by 1,2);

SELECT 
    *
FROM
    Q17;
