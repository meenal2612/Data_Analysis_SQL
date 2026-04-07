use global_superstore_project;

describe orders;
select count(*) from orders;
show tables;
-- Q1. Find out the total profit, sales, discount and shipping cost according to segment.
-- select sales,discount,shippingcost,profit from orders;
select segment,round(sum(profit),2) total_profit,round(sum(sales),2) total_sales,round(sum(ShippingCost),2) 
total_shippingcost,round(sum(discount),2) total_discount from orders group by segment;

create view Q1 as (select segment,round(sum(profit),2) total_profit,round(sum(sales),2) total_sales,round(sum(ShippingCost),2) 
total_shippingcost,round(sum(discount),2) total_discount from orders group by segment);
select * from Q1;

-- Q2. Top 10 corporate customer who gave best sale.
select 
	customername,round(sum(sales),2) AS Total_sales 
from 
	orders
where 
	segment='corporate' 
group by 
	customername 
order by 
	total_sales desc 
limit 10; 

create view Q2 as (select customername,round(sum(sales),2) Total_sales from orders where segment='corporate'  
group by customername order by total_sales desc limit 10);
select * from Q2;

-- Q3. How many order received in India on each segment?
-- select distinct country from orders where country like "I%" and country like "%a";
select 
	segment,count(orderid) AS ordercount
from 
	orders 
where 
	country="India" 
group by 
	segment;

create view Q3 as (select segment,count(orderid) from orders where country="INDia" group by segment);
select * from Q3;

-- Q4 What would be the % of profit with respect to sales for santiago state by each order priority. 
select OrderPriority,round((sum(profit)/sum(sales))*100,2) as Profit_Percentage
from orders where state='santiago' group by OrderPriority;

create view Q4 as (select OrderPriority,round((sum(profit)/sum(sales))*100,2) as Profit_Percentage
from orders where state='santiago' group by OrderPriority);
select * from Q4;

-- Q5 What is the avg shipping cost of 1st class for top 15 customers in south-east asia for home office site?
select CustomerName,avg(ShippingCost) AvgShippingCost from orders
where region = 'Southeast Asia' and segment='Home Office' and shipmode='First class'
group by CustomerName order by avg(ShippingCost) desc limit 15;

create view Q5 as(select CustomerName,avg(ShippingCost) AvgShippingCost from orders
where region='Southeast Asia' and segment='Home Office' and shipmode='First class' group by CustomerName);
-- drop view q5;
SELECT * FROM Q5 ORDER BY AvgShippingCost DESC LIMIT 15;

-- Q6 What are the total no of orders for each catagory by each segment order date wise?
select category,segment,year(orderdate),count(orderid) 
from orders
group by category,segment,year(orderdate);

create view Q6 as (select category,segment,year(orderdate),count(orderid) from orders
group by category,segment,year(orderdate));
select * from Q6;

-- Q7 How many product shipped by first class in each priority.
SELECT 
    OrderPriority, COUNT(productid)
FROM
    orders
WHERE
    shipmode = 'First Class'
GROUP BY OrderPriority;

CREATE VIEW Q7 AS
    (SELECT 
        OrderPriority, COUNT(productid)
    FROM
        orders
    WHERE
        shipmode = 'First Class'
    GROUP BY OrderPriority);
select * from Q7;

-- Q8  Find out total sales and profit for each category with low order priority and zero discount.
SELECT 
    category,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM
    orders
WHERE
    Discount = 0
        AND OrderPriority RLIKE 'low'
GROUP BY category;

create view Q8 as (select category,sum(sales) total_sales,sum(profit) total_profit from orders
where Discount=0 and OrderPriority rlike 'low'
group by category);
select * from Q8;

-- Q9. Name the cities of Australia with % of sales?
select city,concat(round((sum(sales)/(select sum(Sales) from orders where country='Australia'))*100,0),"%")
as Sales_Percentage
from orders where country='Australia' group by city;

create view Q9 as (select city,concat(round((sum(sales)/(select sum(Sales) from orders where 
country='Australia'))*100,2),"%") as Sales_Percentage
from orders where country='Australia' group by city);

select * from Q9;

-- Q10. What is the total sales and quantity for top 5  samsung products in APAC Market for the year 2014?
SELECT 
    ProductName,
    SUM(Sales) AS total_sales,
    SUM(quantity) AS total_quantity
FROM
    orders
WHERE
    ProductName LIKE '%Samsung%'
        AND market = 'apac'
        AND YEAR(orderdate) = 2014
GROUP BY ProductName
ORDER BY total_sales
LIMIT 5;

create view Q10 as(select ProductName,sum(Sales) total_sales,sum(quantity) total_quantity
from orders
where ProductName like "%Samsung%" and market='apac' and year(orderdate)=2014
group by ProductName);

select * from Q10 order by total_sales limit 5;


-- Q11. What % of shipping cost contribute in sales for Nokia Products in NEW ZEALAND country ?
select 
	ProductName,concat(round((sum(shippingcost)/sum(sales))*100,2),"%") AS shippingCost_Percent_outOfSales
from 
	orders
where 
	ProductName rlike "nokia" and country="New Zealand"
group by 
	ProductName,country
order by 
	shippingCost_Percent_outOfSales desc;

create view Q11 as(select ProductName,round((sum(shippingcost)/sum(sales))*100,2) shippingCost_Percent_outOfSales
from orders
where ProductName like "%nokia%" and country="New Zealand"
group by ProductName,country
order by shippingCost_Percent_outOfSales desc);

select * from Q11;

select * from orders;

-- TOP 10 CITY BY PROFIT
select 
	city,sum(profit) as total_profit
from 
	orders
group by 
	city
order by 
	total_profit desc
limit 10;

select * from orders limit 5;

-- Q12.Write a query to find the top 10 products by total sales
select 
	productname,round(sum(sales),2) AS Total_sales 
from 
	orders
group by 
	productname 
order by 
	total_sales desc 
limit 10; 

create view Q12 as (
select productname,round(sum(sales),2) AS Total_sales 
from orders group by productname);

select * from Q12 order by total_sales desc limit 10 ;

-- Q13. Show yearly sales trends for all years.

with cte as (select extract(year from orderdate) as Yr,round(sum(Sales),0) as Current_total_sales
from orders
group by 1
order by 1),
cte2 as (select Yr,Current_total_sales,coalesce(lag(Current_total_sales,1) over(),"NA") as prev_total_sales
from cte)
select Yr,Current_total_sales,prev_total_sales,coalesce(concat(round(((Current_total_sales-prev_total_sales)/prev_total_sales)*100,2),"%"),"NA") as growth_percent
from cte2;

create view Q13 as(with cte as (select extract(year from orderdate) as Yr,round(sum(Sales),0) as Current_total_sales
from orders
group by 1
order by 1),
cte2 as (select Yr,Current_total_sales,coalesce(lag(Current_total_sales,1) over(),"NA") as prev_total_sales
from cte)
select Yr,Current_total_sales,prev_total_sales,coalesce(concat(round(((Current_total_sales-prev_total_sales)/prev_total_sales)*100,2),"%"),"NA") as growth_percent
from cte2);

select * from Q13;

select * from orders limit 4;

-- Q14 Show yearly sales trends for all months.
with cte as (select extract(year from orderdate) as yr,extract(month from orderdate) as mnth,
round(sum(sales),2) as current_mnth_total_sales from orders
group by extract(year from orderdate),extract(month from orderdate) order by 1,2),
cte2 as (select yr,mnth,current_mnth_total_sales,coalesce(lag(current_mnth_total_sales,1)over(partition by yr),"NA") as prev_month_sales 
from cte)
select yr,mnth,current_mnth_total_sales,prev_month_sales,coalesce(concat(round(((current_mnth_total_sales-prev_month_sales)/prev_month_sales)*100,2),"%"),"NA") as growth_percent
from cte2;

create view Q14 as (
with cte as (select extract(year from orderdate) as yr,extract(month from orderdate) as mnth,
round(sum(sales),2) as current_mnth_total_sales from orders
group by extract(year from orderdate),extract(month from orderdate) order by 1,2),
cte2 as (select yr,mnth,current_mnth_total_sales,coalesce(lag(current_mnth_total_sales,1)over(partition by yr),"NA") as prev_month_sales 
from cte)
select yr,mnth,current_mnth_total_sales,prev_month_sales,coalesce(concat(round(((current_mnth_total_sales-prev_month_sales)/prev_month_sales)*100,2),"%"),"NA") as growth_percent
from cte2);

select * from Q14;
desc orders;


-- Q15.Find customers who placed more than 30 orders in a single year.
select * from 
(select extract(year from orderdate) yr,customerid,count(orderid) total_orders from orders group by 1,customerid order by 1,2) as t1
where total_orders>30;

create view Q15 as(select * from 
(select extract(year from orderdate) yr,customerid,count(orderid) total_orders from orders group by 1,customerid order by 1,2) as t1
where total_orders>30);

select * from Q15;

-- Q16. Compare sales vs. profit across different regions.
desc orders;
select distinct region from orders;
select region,round(sum(sales),2) as total_Sales,round(sum(profit),0) as total_profit
from orders group by region;

create view Q16 as(
select region,round(sum(sales),2) as total_Sales,round(sum(profit),0) as total_profit
from orders group by region);

select * from Q16;

-- Q17. Show monthly sales trends for the last 4 years.
create view Q17 as (with cte as (select extract(month from orderdate) as mnth,extract(year from orderdate) as yr,
round(sum(sales),2) as current_mnth_total_sales from orders
group by 1,2 order by 1,2),
cte2 as (select yr,mnth,current_mnth_total_sales,coalesce(lag(current_mnth_total_sales,1)over(partition by mnth),"NA") as prev_month_sales 
from cte)
select mnth,yr,current_mnth_total_sales,prev_month_sales,coalesce(concat(round(((current_mnth_total_sales-prev_month_sales)/prev_month_sales)*100,2),"%"),"NA") as growth_percent
from cte2 order by 1,2);

select * from Q17;