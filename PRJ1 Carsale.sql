/*
Project Title: Car Sales Data Analysis using SQL
Author: Meena Sathiya
Tools Used: MySQL

Description:
This project analyzes car sales data to identify revenue trends, dealer performance,
customer segmentation, and financial insights. Data cleaning, transformation,
and business analysis were performed using SQL.

Dataset: car_sales
*/

/* =====================================================
SECTION 1: DATABASE SELECTION
===================================================== */
USE data_analytics; 

SHOW TABLES;

show full tables;

desc `car sales`;

/* =====================================================
SECTION 2: DATA EXPLORATION
===================================================== */
-- Total number of sales records
select COUNT(*) as total_sales from `car sales`;
select sum(price)as total_sale_amount from`car sales`;
select max(price)as max_sale_amount from`car sales`;
select min(price)as min_sale_amount from`car sales`;

-- Unique Companies
select distinct company from `car sales`;
-- Unique Model 
select distinct model from `car sales`;

/* =====================================================
SECTION 3: DATA CLEANING
===================================================== */
-- Check NULL values
select sum(`Annual Income` is null) as missing_income, 
Sum(price is null) as missing_price,
sum(`Date` is null)as missing_date from `car sales`;

-- Create proper DATE column
Alter table `car sales` add column sale_date date;
desc `car sales`;

-- Standardize date format
update `car sales` 
set `Date` = replace(`Date`,'/','-');

-- Convert text date to DATE format
update `car sales` 
set sale_date=str_to_date(`Date`,'%m-%d-%Y')
where `Date` is not null;

/* =====================================================
SECTION 4: DATA TRANSFORMATION
===================================================== */
-- Create Financial Year column
alter table `car sales` add column fin_yr varchar(9);
update `car sales` set fin_yr= 
case when month(sale_date)>=4 
    then concat(year(sale_date),'-',year(sale_date)+1) 
    else concat(year(sale_date)-1,'-',year(sale_date))
end;

/* =====================================================
SECTION 5: BUSINESS ANALYSIS
===================================================== */
-- Total revenue
select sum(price)as total_revenue
from`car sales`;

-- Revenue by financial year
select fin_yr, 
sum(price) as Yearly_revenue 
from `car sales` 
group by fin_yr 
order by fin_yr; 

-- Total sales count by financial year
SELECT fin_yr, 
count(*) as total_sales 
from `car sales` 
group by fin_yr 
order by total_sales desc; 

-- Top 10 dealers by revenue
SELECT Dealer_Name,
       SUM(price) AS total_revenue
FROM `car sales`
GROUP BY Dealer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Sale count and revenue based on Company in each finacial Year
select fin_yr,Company, count(*)as totalsale_count, sum(price) as revenue 
from `car sales` 
group by fin_yr,company 
order by fin_yr,revenue desc;

-- sale year more than 400
select fin_yr,count(*) as totalsale 
from `car sales` 
group by fin_yr 
having count(*)>400 
order by totalsale asc;

/* =====================================================
SECTION 6: CUSTOMER ANALYSIS
===================================================== */
-- Spending PERCENTAGE by each family
select price, `Annual Income`, round((price / `Annual Income`)*100,2) as spending_percentage from `car sales` where `Annual Income` >0;

-- Highest spending customor and how much % they spend
select price, `Annual Income`, round((price/`Annual Income`)*100,2) spender_percentage, 
case when((price /`Annual Income`)*100)>100 then "high spender" else "fine" end as spender_category from`car sales`where `Annual Income`>0;

-- Customer segmentation by income
select 
case 
when `Annual Income`<=100000 then 'SILVER' 
when `Annual Income`>100000 and `Annual Income`<=1000000 then 'gold'
when `Annual Income`>1000000 and `Annual Income`<=2500000 then 'platinum' 
else 'Diamond' end as family_category,
count(*)as total_customer from `car sales` 
group by family_category;

-- Average income and spending by gender
select avg(`Annual Income`)as avg_income,avg(`price`)as avg_price,Gender 
from `car sales` 
group by Gender
order by avg_income,avg_price;

/* =====================================================
SECTION 7: JOIN ANALYSIS (RELATIONAL DATABASE ANALYSIS)
===================================================== */
-- Create customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO customers VALUES
(1, 'Meena', 'London'),
(2, 'John', 'Manchester'),
(3, 'Ravi', 'Birmingham'),
(4, 'Anita', 'Leeds'),
(5, 'David', 'Liverpool');
 
-- ORDER TABLE
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders VALUES
(101, 1, 1001, '2024-01-10', 500),
(102, 2, 1002, '2024-01-11', 700),
(103, 1, 1003, '2024-01-15', 300),
(104, 3, 1001, '2024-02-01', 900),
(105, 5, 1004, '2024-02-10', 400);

-- PRODUCT TABLE
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50)
);

INSERT INTO products VALUES
(1001, 'Laptop', 'Electronics'),
(1002, 'Phone', 'Electronics'),
(1003, 'Table', 'Furniture'),
(1004, 'Chair', 'Furniture'),
(1005, 'Watch', 'Accessories');

-- INNER JOIN: Get customer orders with product details
SELECT c.customer_name,p.product_name,o.amount,o.order_date
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN products p 
    ON o.product_id = p.product_id;
    
-- Revenue by product category using JOIN
SELECT 
    p.category,
    SUM(o.amount) AS total_revenue
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- LEFT JOIN: Show all customers including those without orders
    SELECT c.customer_name,o.amount,o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;
    
-- RIGHT JOIN: Show all products including those not ordered
SELECT 
    p.product_name,
    o.amount
FROM products p
RIGHT JOIN orders o
    ON p.product_id = o.product_id;
    
-- SELF JOIN: Find customers from same city without duplicate
select * from customers as a join customers as b on a.city=b.city
and a.customer_id>b.customer_id; 

/* =====================================================
SECTION 8: UNION ANALYSIS
Combining data from multiple tables for unified reporting
===================================================== */
select product_name as col1 , category as col2 , 'categ' as label from products where product_name='Laptop' or category='Electronics'
union
select customer_name as col1, city as col2 , 'from_where' as label from customers where city='London'
union
select order_date as col1 , amount as col2 ,'spending' as label from orders where amount >500 and order_date> '2024-01-10'
order by col1;

/* =====================================================
SECTION 9: STRING FUNCTION ANALYSIS
Data cleaning and text transformation
===================================================== */
-- Convert product names to uppercase
select product_name,upper(product_name) from products;

-- Extract first 3 characters of city
select city,left(city,3) from customers ;

-- Combine product and category
select product_name,category, concat(product_name,' - ',category) from products;

/* =====================================================
SECTION 10: SUBQUERY ANALYSIS
Filtering data using nested queries
===================================================== */
-- Customers who placed orders
select customer_name from customers where customer_id in(select customer_id from orders);

/* =====================================================
SECTION 11: WINDOW FUNCTION ANALYSIS
Ranking and analytical functions
===================================================== */
-- Rank products within category
select product_name,category,rank() over(partition by category order by product_name)as crt_rank, 
row_number() over(partition by category order by product_name)as rank_no from products;

/* =====================================================
SECTION 12: CTE ANALYSIS
Improving query readability using Common Table Expressions
===================================================== */
with order_summary as
(
select o.amount,p.category,cus.customer_name, row_number() over(partition by p.category order by o.amount desc)as chkrank
from products p join orders o on p.product_id=o.product_id join customers cus on cus.customer_id=o.customer_id 
) 
select amount,category,customer_name from order_summary
where amount>500;


/* =====================================================
PROJECT END
===================================================== */









