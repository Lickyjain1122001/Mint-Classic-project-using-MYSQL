/*
Data Analysis Project on Mint Classics Company Data.
Helping to analyze data in a relational database with the goal of supporting inventory-related business decisions that lead to the closure of a storage facility.

Note : This is a Fictional dataset of company from coursera
*/

-- Q1- what is the time period of data set ?

select
	min(orderDate),
    max(orderDate)
from `orders`;

---------------------------------------------------------------------------------------------------------------------
-- Q2- Number 0f warehouse ?

select*
from `warehouses`;

---------------------------------------------------------------------------------------------------------------------
-- Q3- list the unique product line.

select
	productLine,
    textDescription
from `productlines`;

---------------------------------------------------------------------------------------------------------------------
-- Q4- stock of product of each product line in each warehouse ?

select
	warehouseCode,
    productLine,
    sum(quantityInStock) as total_quantity
from `products`
group by warehouseCode, productLine
order by warehouseCode;


----------------------------------------------------------------------------------------------------------------------
-- Q5- Number of customer per city ?

select
    country,
    count(customerNumber) as total_customer
from `customers`
group by country
order by total_customer desc;

--------------------------------------------------------------------------------------------------------------------
-- Q6- Total number of employe per city ?

select
    e.officeCode,
    o.country,
    count(e.employeeNumber) 
from `employees` as e join `offices` as o on e.officeCode = o.officeCode
group by o.country, e.officeCode;

-------------------------------------------------------------------------------------------------------------------
-- Q7- What is the quantity of sales we get from each customer yearly ?  

with t1 as(
	select
		year(o.orderDate) as "Year",
		monthname(o.orderDate) as 'Month',
		o.customerNumber,
		sum(sum(od.quantityOrdered))over(partition by customerNumber,year(o.orderDate)) as Yearly_orders
	from `orders` as o join `orderdetails` as od on o.orderNumber = od.orderNumber
	group by year(o.orderDate),month(o.orderDate),monthname(o.orderDate), o.customerNumber, od.productCode
	order by Year, month(o.orderDate),Yearly_orders desc) 
select distinct *
from t1;
-------------------------------------------------------------------------------------------------------------------
-- Q8- Monthly sales of each product line

select
	p.productLine,
    year(o.orderDate) as 'Year' ,
    monthname(o.orderDate) as 'Month',
    sum(od.quantityOrdered) as num_of_order
from `orders` as o 
join `orderdetails` as od on o.orderNumber = od.orderNumber
join `products` as p on od.productCode = p.productCode
group by year(o.orderDate),month(o.orderDate), monthname(o.orderDate),  p.productLine
order by productLine, Year,  num_of_order desc;

----------------------------------------------------------------------------------------------------------------------
-- Q9- Yearly sales of product Line ?

select
	p.productLine,
    year(o.orderDate) as 'Year',
    sum(od.quantityOrdered) as num_of_order
from `orders` as o 
join `orderdetails` as od on o.orderNumber = od.orderNumber
join `products` as p on od.productCode = p.productCode
group by year(o.orderDate), p.productLine
order by p.productLine, Year, num_of_order desc;

-------------------------------------------------------------------------------------------------------------------
/*Q10- What is the average sales of each product line ? */

with t1 as(
	select
		p.productLine,
		year(o.orderDate) as 'Year',
		sum(od.quantityOrdered) as num_of_order
	from `orders` as o 
	join `orderdetails` as od on o.orderNumber = od.orderNumber
	join `products` as p on od.productCode = p.productCode
	group by year(o.orderDate), p.productLine
	order by p.productLine, Year, num_of_order desc)
select
	productLine,
    round(avg(num_of_order)) as avg_num_orders
from t1
group by productLine;

-------------------------------------------------------------------------------------------------------------------
-- Q11- Yearly sales of product line in each city ?

select
    year(o.orderDate) as 'Year',
    c.country,
    c.city,
    p.warehouseCode,
    p.productLine,
    sum(od.quantityOrdered) as sales
from `customers` as c join `orders` as o on c.customerNumber = o.customerNumber
join `orderdetails` as od on o.orderNumber = od.orderNumber
join `products` as p on od.productCode = p.productCode
group by c.country, c.city, p.productLine, year(o.orderDate), p.warehouseCode
order by  year,p.productLine, sales desc;


-----------------------------------------------------------------------------------------------------------------
-- Q12- country where maximum sales happen of each product line ? 

with t as (select
	year(o.orderDate) as 'Year',
	c.country,
	p.productLine,
	sum(od.quantityOrdered) as sales
from `customers` as c join `orders` as o on c.customerNumber = o.customerNumber
join `orderdetails` as od on o.orderNumber = od.orderNumber
join `products` as p on od.productCode = p.productCode
group by c.country, p.productLine, year(o.orderDate)
order by  year,p.productLine, sales desc)

select distinct
	Year,
    productLine,
    first_value(country)over(partition by Year, productLine order by sales) as max_sales_in_country
from t;
