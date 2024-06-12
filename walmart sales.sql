-- ------------------------------------Data wrangling------------------------------------------------
create database if not exists walmartsales;
use walmartsales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
-- ---------- --------------------------------------------------------------------------------------------
-- ---------- ---------------------(Feature engineering)----------------------------------------------------
-- ----------------------------Time_of _day from time----------------------------------------------------
 select time,
 (CASE
    WHEN time BETWEEN '00:00:00' AND '05:59:59' THEN 'Early Morning'
    WHEN time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
    WHEN time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    WHEN time BETWEEN '17:00:00' AND '20:59:59' THEN 'Evening'
    WHEN time BETWEEN '21:00:00' AND '23:59:59' THEN 'Night'
    ELSE 'Invalid Time'
END )
 as time_of_day
 from sales;
 
 alter table sales add column time_of_day varchar(20);
 update sales
 set time_of_day = (CASE
    WHEN time BETWEEN '00:00:00' AND '05:59:59' THEN 'Early Morning'
    WHEN time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
    WHEN time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    WHEN time BETWEEN '17:00:00' AND '20:59:59' THEN 'Evening'
    WHEN time BETWEEN '21:00:00' AND '23:59:59' THEN 'Night'
    ELSE 'Invalid Time'
END );
-- -----------------------------------------------------------------------------------------------
-- ----------------------Specifying the day based on date ----------------------------------------
select date,dayname(date) from sales;
 alter table sales add column day_name varchar(30);
 update sales 
 set day_name= dayname(date) ;
 -- --------------------------------------------------------------------------------------------------
 -- ------------------------Specifying the month based on date----------------------------------------
 select date, monthname(date) from sales;
 alter table sales add column month_name varchar(20);
 update sales
 set month_name = monthname(date);
 -- ----------------------------------------------------------------------------------------------------
 -- ----------------------Exploratory data analysis---------------------------------------------------
 -- ----------------------------Generic questions------------------------------------------------------
 -- -How many unique cities does the data have?
 select distinct city from sales;
 -- -In which city is each branch?
 select distinct city, branch from sales;
 -- ----------------------------Product questions---------------------------------------------------
 -- -How many unique product lines does the data have?
 select  count(distinct product_line) from sales;
 -- -What is the most common payment method?
 select payment,count(payment) from sales
 group by payment
 order by count(payment) desc;
 -- -What is the most selling product line?
 select product_line,count(product_line) from sales
 group by product_line
 order by count(product_line) desc;
 -- -What is the total revenue by month?
 select  month_name,sum(total) from sales
 group by month_name
 order by sum(total) desc;
 -- -What month had the largest COGS?
 select sum(cogs), month_name from sales
 group by month_name
 order by sum(cogs) desc;
 -- -What product line had the largest revenue?
select product_line , sum(total) from sales
group by product_line
order by sum(total) desc;
-- -What is the city with the largest revenue?
select city, sum(total) from sales
group by city
order by sum(total) desc;
 -- -What product line had the largest VAT?
 select product_line , avg(tax_pct) from sales
 group by product_line
 order by avg(tax_pct) desc;
 -- -Fetch each product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
    product_line,
    SUM(total) AS total_sales,
    CASE
        WHEN SUM(total) > (SELECT AVG(total_sales) FROM (
                               SELECT SUM(total) AS total_sales 
                               FROM sales 
                               GROUP BY product_line
                           ) AS avg_sales) THEN 'Good'
        ELSE 'Bad'
    END AS sales_status
FROM 
    sales
GROUP BY 
    product_line;



-- --Which branch sold more products than average product sold?
select branch, sum(quantity) from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales)
order by sum(quantity) desc;
 -- -What is the most common product line by gender?
 select gender, count(gender) , product_line from sales
 group by gender, product_line
 order by count(gender) desc ;
 -- -What is the average rating of each product line?
 select product_line , avg(rating) from sales
 group by product_line
order by avg(rating) desc;
-- --------------------------------------------------------------------------------------
-- -------------------------Sales questions-------------------------------------------
-- -Number of sales made in each time of the day per weekday
select day_name,time_of_day , count(*) from sales
group by time_of_day, day_name
order by count(*) desc;
-- -Which of the customer types brings the most revenue?
select customer_type, sum(total) from sales
group by customer_type 
order by sum(total) desc;
-- -Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(tax_pct) from sales
group by city
order by avg(tax_pct) desc;
-- -Which customer type pays the most in VAT?
select customer_type, avg(tax_pct) from sales
group by customer_type
order by avg(tax_pct) desc;
-- ---------------------------------------------------------------------------------------------------
-- ----------------------------------Customer questions-----------------------------------------------------------
-- -How many unique customer types does the data have?
select customer_type, count(distinct customer_type) from sales
group by customer_type;
-- -How many unique payment methods does the data have?
select distinct payment from sales;
-- -What is the most common customer type?
select customer_type, count(customer_type) from sales
group by customer_type
order by count(customer_type) desc;
-- -Which customer type buys the most?
select customer_type , sum(total) from sales
group by customer_type
order by sum(total) desc;
-- -What is the gender of most of the customers?
select gender, count(gender) from sales 
group  by gender
order by count(gender) desc;
-- -What is the gender distribution per branch?
select gender, count(gender), branch from sales 
group  by gender, branch 
order by branch,count(gender) desc;
-- -Which time of the day do customers give most ratings?
select time_of_day,time, count(rating) from sales
group by time, time_of_day
order by count(rating) desc;
-- -Which time of the day do customers give most ratings per branch?
select time_of_day, count(rating) from sales where branch = 'A'
group by time_of_day 
order by count(rating) desc;
-- -Which day fo the week has the best avg ratings?
select day_name, avg(rating) from sales 
group by day_name 
order by avg(rating) desc;
-- -Which day of the week has the best average ratings per branch?
select day_name, avg(rating), branch from sales where branch='A'
group by day_name 
order by avg(rating) desc;

-- --------------------------------------------------------------------------------------------