

/*
Introduction

-	You can benefit from the ERD diagram given to you during your work.
-	You have to create a database and import into the given csv files. 
-	During the import process, you will need to adjust the date columns. You need to carefully observe the data types and how they should be.In our database, a star model will be created with one fact table and four dimention tables.
-	The data are not very clean and fully normalized. However, they don't prevent you from performing the given tasks. In some cases you may need to use the string, window, system or date functions.
-	There may be situations where you need to update the tables.
-	Manually verify the accuracy of your analysis.



Analyze the data by finding the answers to the questions below:

1.	Join all the tables and create a new table with all of the columns, called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
2.	Find the top 3 customers who have the maximum count of orders.
3.	Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
4.	Find the customer whose order took the maximum time to get delivered.
5.	Retrieve total sales made by each product from the data (use Window function)
6.	Retrieve total profit made from each product from the data (use windows function)
7.	Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

*/




-- DATA ANALYSIS

--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


select * 
INTO combined_table
FROM
(
select 
cd.Cust_id, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment, mf.Ord_id, 
mf.Prod_id, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Profit, mf.Shipping_Cost, mf.Product_Base_Margin,
od.Order_Date, od.Order_Priority,
pd.Product_Category, pd.Product_Sub_Category,
sd.Ship_id, sd.Ship_Mode, sd.Ship_Date
from market_fact mf 
inner join cust_dimen cd on mf.Cust_id = cd.Cust_id
inner join orders_dimen od on od.Ord_id = mf.Ord_id
inner join prod_dimen pd on pd.Prod_id = mf.Prod_id
inner join shipping_dimen sd on sd.Ship_id = mf.Ship_id
) a









select * from [dbo].[cust_dimen];


select * from [dbo].[shipping_dimen];



select * from [dbo].[orders_dimen];


select * from [dbo].[prod_dimen]




update  [dbo].[prod_dimen]
set prod_id='Prod_16' where Prod_id= ' RULERS AND TRIMMERS,Prod_16'



--2. Find the top 3 customers who have the maximum count of orders.

select top(3) c.cust_id, c.customer_name, count(distinct Ord_id) as number_of_orders 
from 
cust_dimen c 
inner join market_fact mf 
on c.cust_id = mf.cust_id
group by c.cust_id, c.customer_name 
order by number_of_orders desc; 



select top(3) cust_id, customer_name, count (distinct ord_id) num
from
combined_table 
group by
cust_id, customer_name
order by num desc



--3.3.	Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

alter table combined_table 
add  DaysTakenForDelivery int;

update combined_table
set DaysTakenForDelivery =  datediff(day,  order_date,  ship_date)  ;


SELECT *
FROM
combined_table



--4. Find the customer whose order took the maximum time to get delivered.

select Cust_id, Customer_Name, Order_Date, Ship_Date, DaysTakenForDelivery 
from combined_table 
where DaysTakenForDelivery in
							(
							select max(DaysTakenForDelivery) 
							from combined_table
							);




--5. Retrieve total sales made by each product from the data (use Window function)


select distinct Prod_id,  sum(Sales) over (partition by prod_id)
from
market_fact;


select distinct Prod_id,  sum(Sales) over (partition by prod_id)
from
combined_table;
	




--6. Retrieve total profit made from each product from the data (use windows function)

select distinct Prod_id, sum(Profit) over (partition by Prod_id) as total_profit 
from market_fact
order by
total_profit desc







--7. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select count(distinct Cust_id) as unique_customers from combined_table where year(Order_Date) = 2011 AND month(Order_Date) = 01;


SELECT DISTINCT 
Year(Order_date) AS [YEAR], 
Month(Order_date) AS [MONTH], 
count(cust_id) OVER (PARTITION BY month(Order_date) order by month(Order_date)) ASTotal_Unique_Customers 
FROM combined_table 
WHERE year(Order_Date)=2011 
AND cust_id IN 
			(
			SELECT DISTINCT cust_id 
			FROM combined_table 
			WHERE year(Order_Date) = 2011 AND month(Order_Date) = 01
			);



--CUSTOMER RETENTION ANALYSIS



/*
Find month-by-month customer retention rate  since the start of the business (using views).

1.	Create a view where each user’s visits are logged by month, allowing for the possibility that these will have occurred over multiple years since whenever business started operations.
2.	Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.
3.	Calculate the time gaps between visits.
4.	Categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned.
5.	Calculate the retention month wise
*/




--1. Create a view where each user’s visits are logged by month, 
--	allowing for the possibility that these will have occurred over multiple years since whenever business started operations.


create view user_visit as
select cust_id, Count_in_month, convert (date , month + '-01') Month_date
from
(
select  cust_id, SUBSTRING(cast(order_date as varchar), 1,7) as [Month], COUNT(*) as Count_in_month 
from combined_table 
group by cust_id, SUBSTRING(cast(order_date as varchar), 1,7)
) a;



select *
from user_visit ;




--2. Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.


create view Time_lapse_vw as 
select  *, lead(Month_date) over (partition by cust_id order by Month_date) as Next_month_Visit
from user_visit; 



select * from time_lapse_vw;
    



--3. Calculate the time gaps between visits.

create view  time_gap_vw as 
select *, datediff ( month, Month_date, Next_month_Visit) as Time_gap 
from time_lapse_vw;







--4. Categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned.

create view Customer_value_vw as 

select distinct cust_id, Average_time_gap,
case 
	when Average_time_gap<=1 then 'Retained'
    when Average_time_gap>1 then 'Irregular'
    when Average_time_gap is null then 'Churned'
    else 'Unknown data'
end  as  Customer_Value
from 
(
select cust_id, avg(time_gap) over(partition by cust_id) as Average_time_gap,
from 
time_lapse_vw
);


select * from customer_value_vw;



select * from time_gap_vw
where
cust_id='Cust_1288';


select * from time_gap_vw

--5. Calculate the retention month wise.


create view retention_vw as 

select distinct next_month_visit as Retention_month,

sum(time_gap) over (partition by next_month_visit) as Retention_Sum_monthly

from time_gap_vw 
where time_gap<=1
order by Retention_Sum_monthly desc;






select * from retention_vw;