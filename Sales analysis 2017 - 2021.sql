

SELECT *
  FROM [Project].[dbo].[Orders_data]

  SELECT *
  FROM Suppliers_table 
------------------------------------------------------------------------------------------------------------------------------------
                                                                  
																-- OVERVIEW OF ORDERS TABLE --

select sum(Total_retail_price_for_order) as total_profit, 
count ( distinct Customer_ID) as total_customers,
sum(Quantity_ordered) as total_quantity_sold,
count(Order_ID) as total_number_of_purchases
from Orders_data



                                                              -- OVERVIEW OF SUPPLIERS TABLE --

select count ( distinct Product_ID ) as total_number_of_products,
count (distinct Supplier_Country ) as number_of_supply_countries,
count (distinct Supplier_ID ) as total_number_of_suppliers  
from Suppliers_table
------------------------------------------------------------------------------------------------------------------------------------


                                                                      -- OVERVIEW OF SALES  --

select year(Order_date) as year ,sum(Total_retail_price_for_order) as total_sales
from Orders_data
group by year(Order_date)
order by year(Order_date) asc


-- comparison of avg price by product, total profit by product, total quantity sold by product
select Product_ID , avg(Cost_price_per_unit) as avg_product_price, count (Order_ID )  as total_purchases ,
sum(Total_retail_price_for_order) / 12023091.3198686 * 100 as percent_of_total_sales ,
sum(Quantity_ordered) as total_quantity_sold
from Orders_data
group by Product_ID


-- % of yearly sales by quarter  ( shows most ans least profitable quarters ) 
select Quarter,
sum( case when  year(Order_date) = 2017 then (Total_retail_price_for_order)  / 1894498.72976977 * 100 else  0 end ) as percent_of_2017_total_sales,
sum( case when  year(Order_date) = 2018 then (Total_retail_price_for_order)  / 2264955.76022507 * 100 else  0 end ) as percent_of_2018_total_sales,
sum( case when  year(Order_date) = 2019 then (Total_retail_price_for_order)  / 2744015.96938013 * 100 else  0 end ) as percent_of_2019_total_sales,
sum( case when  year(Order_date) = 2020 then (Total_retail_price_for_order)  / 2334113.61997594 * 100 else  0 end ) as percent_of_2020_total_sales,
sum( case when  year(Order_date) = 2021 then (Total_retail_price_for_order)  / 2785507.24051774 * 100 else 0 end )  as percent_of_2021_total_sales
from Orders_data
group by Quarter


-- calculating % change in quarterly profit across years using same table 
with Sales_by_quarter
( Quarter, percent_of_2017_total_sales, percent_of_2018_total_sales, percent_of_2019_total_sales, percent_of_2020_total_sales, percent_of_2021_total_sales )
as 
(
select Quarter,
sum( case when  year(Order_date) = 2017 then (Total_retail_price_for_order)  / 1894498.72976977 * 100 else  0 end ) as percent_of_2017_total_sales,
sum( case when  year(Order_date) = 2018 then (Total_retail_price_for_order)  / 2264955.76022507 * 100 else  0 end ) as percent_of_2018_total_sales,
sum( case when  year(Order_date) = 2019 then (Total_retail_price_for_order)  / 2744015.96938013 * 100 else  0 end ) as percent_of_2019_total_sales,
sum( case when  year(Order_date) = 2020 then (Total_retail_price_for_order)  / 2334113.61997594 * 100 else  0 end ) as percent_of_2020_total_sales,
sum( case when  year(Order_date) = 2021 then (Total_retail_price_for_order)  / 2785507.24051774 * 100 else 0 end )  as percent_of_2021_total_sales
from Orders_data
group by Quarter
) 
select quarter, (percent_of_2018_total_sales / percent_of_2017_total_sales) - 1 as percent_change_2017_to_2018,
( percent_of_2019_total_sales / percent_of_2018_total_sales ) -1 as percent_change_2018_to_2019,
( percent_of_2020_total_sales / percent_of_2019_total_sales ) -1 as percent_change_2019_to_2020,
( percent_of_2021_total_sales / percent_of_2020_total_sales ) -1 as percent_change_2020_to_2021
from Sales_by_quarter
order by Quarter asc





-- calculating fluctuation of total profit by quarter  ( standart deviation STDEV,  measure  the amount of variation ) 

-- relatively high STDEV shows high fluctuation in total profit across quarters
-- relatively low shows opposite to high
select Quarter, stdev(Total_retail_price_for_order) as fluctuation_
from Orders_data
group by Quarter



-- % total sales by month across years ( shows most and least profitable months across years ) 
select  month(Order_date)  ,Month , sum(Total_retail_price_for_order) / 12023091.3198686 * 100 as  percent_of_total_pofit
from Orders_data
group by month(Order_date), Month
order by month(Order_date) asc



-- % total sales by day of the week across years ( shows most and least profitable days of the week across years) 
select Day_of_the_week ,sum(Total_retail_price_for_order) /  12023091.3198686 * 100  as percent_of_total_pofit
from Orders_data
group by  Day_of_the_week
order by percent_of_total_pofit desc
------------------------------------------------------------------------------------------------------------------------------------





                                                    --ANALYSING EFFECT OF PRODUCT PRICE ON PROFIT BY PRODUCT --




select Product_ID, stdev(Cost_price_per_unit) product_price_fluctuation
from Orders_data
group by Product_ID


-- calculating price change across products during 2017 - 2019 years of sales, 
with Product_price
( Product_ID, avg_product_price_2017, avg_product_price_2018, avg_product_price_2019, avg_product_price_2020, avg_product_price_2021 )
as
(
select Product_ID,
avg( case when  year(Order_date) = 2017 then Cost_price_per_unit  else  0 end ) as avg_product_price_2017,
avg( case when  year(Order_date) = 2018 then Cost_price_per_unit  else  0 end ) as avg_product_price_2018,
avg( case when  year(Order_date) = 2019 then Cost_price_per_unit  else  0 end ) as avg_product_price_2019,
avg( case when  year(Order_date) = 2020 then Cost_price_per_unit  else  0 end ) as avg_product_price_2020,
avg( case when  year(Order_date) = 2021 then Cost_price_per_unit  else  0 end ) as avg_product_price_2021
from Orders_data
group by Product_ID
)
select Product_ID, 
( avg_product_price_2018 / avg_product_price_2017 ) -1 as percent_change_price_2017_to_2018,
( avg_product_price_2019 / avg_product_price_2018 ) -1 as percent_change_price_2018_to_2019,
( avg_product_price_2019 / avg_product_price_2020 ) -1 as percent_change_price_2019_to_2020,
( avg_product_price_2020 / avg_product_price_2021 ) -1 as percent_change_price_2020_to_2021
from Product_price




--calculating yearly profit by product and % change in yearly profit between years ( to compare with product price table, if change in product price affect total sales by 
-- product )
with Yearly_profit_by_product
( Product_ID, profit_by_product_2017, profit_by_product_2018, profit_by_product_2019, profit_by_product_2020, profit_by_product_2021 )
as
(
select Product_ID, 
sum( case when year (Order_date)  = 2017 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2017,
sum( case when year (Order_date)  = 2018 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2018,
sum( case when year (Order_date)  = 2019 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2019,
sum( case when year (Order_date)  = 2020 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2020,
sum( case when year (Order_date)  = 2021 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2021
from Orders_data
group by Product_ID
)
select Product_ID,
( profit_by_product_2018 / profit_by_product_2017 ) -1 as percent_change_in_profit_2017_to_2018,
( profit_by_product_2019 / profit_by_product_2018 ) -1 as percent_change_in_profit_2018_to_2019,
( profit_by_product_2020 / profit_by_product_2019 ) -1 as percent_change_in_profit_2019_to_2020,
( profit_by_product_2021 / profit_by_product_2020 ) -1 as percent_change_in_profit_2020_to_2021
from Yearly_profit_by_product




-- comparing % change in price and % change in profit 2017 to 2018
with Product_price
( Product_ID, avg_product_price_2017, avg_product_price_2018, profit_by_product_2017, profit_by_product_2018 )
as
(
select Product_ID,
avg( case when  year(Order_date) = 2017 then Cost_price_per_unit  else  0 end ) as avg_product_price_2017,
avg( case when  year(Order_date) = 2018 then Cost_price_per_unit  else  0 end ) as avg_product_price_2018,
sum( case when year (Order_date)  = 2017 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2017,
sum( case when year (Order_date)  = 2018 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2018
from Orders_data
group by Product_ID
)
select Product_ID, 
( avg_product_price_2018 / avg_product_price_2017 ) -1 as percent_change_price_2017_to_2018,
( profit_by_product_2018 / profit_by_product_2017 ) -1 as percent_change_in_profit_2017_to_2018
from Product_price



-- comparing % change in price and % change in profit 2018 to 2019
with Product_price
( Product_ID, avg_product_price_2018, avg_product_price_2019, profit_by_product_2018, profit_by_product_2019 )
as
(
select Product_ID,
avg( case when  year(Order_date) = 2018 then Cost_price_per_unit  else  0 end ) as avg_product_price_2018,
avg( case when  year(Order_date) = 2019 then Cost_price_per_unit  else  0 end ) as avg_product_price_2019,
sum( case when year (Order_date)  = 2018 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2018,
sum( case when year (Order_date)  = 2019 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2019
from Orders_data
group by Product_ID
)
select Product_ID, 
( avg_product_price_2019 / avg_product_price_2018 ) -1 as percent_change_price_2018_to_2019,
( profit_by_product_2019 / profit_by_product_2018 ) -1 as percent_change_in_profit_2018_to_2019
from Product_price


-- comparing % change in price and % change in profit 2019 to 2020
with Product_price
( Product_ID, avg_product_price_2019, avg_product_price_2020, profit_by_product_2019, profit_by_product_2020 )
as
(
select Product_ID,
avg( case when  year(Order_date) = 2019 then Cost_price_per_unit  else  0 end ) as avg_product_price_2019,
avg( case when  year(Order_date) = 2020 then Cost_price_per_unit  else  0 end ) as avg_product_price_2020,
sum( case when year (Order_date)  = 2019 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2019,
sum( case when year (Order_date)  = 2020 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2020
from Orders_data
group by Product_ID
)
select Product_ID, 
( avg_product_price_2020 / avg_product_price_2019 ) -1 as percent_change_price_2019_to_2020,
( profit_by_product_2020 / profit_by_product_2019 ) -1 as percent_change_in_profit_2019_to_2020
from Product_price


-- comparing % change in price and % change in profit 2020 to 2021
with Product_price
( Product_ID, avg_product_price_2020, avg_product_price_2021, profit_by_product_2020, profit_by_product_2021 )
as
(
select Product_ID,
avg( case when  year(Order_date) = 2020 then Cost_price_per_unit  else  0 end ) as avg_product_price_2020,
avg( case when  year(Order_date) = 2021 then Cost_price_per_unit  else  0 end ) as avg_product_price_2021,
sum( case when year (Order_date)  = 2020 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2020,
sum( case when year (Order_date)  = 2021 then  Total_retail_price_for_order else 0 end ) as profit_by_product_2021
from Orders_data
group by Product_ID
)
select Product_ID, 
( avg_product_price_2021 / avg_product_price_2020 ) -1 as percent_change_price_2020_to_2021,
( profit_by_product_2021 / profit_by_product_2020 ) -1 as percent_change_in_profit_2020_to_2021
from Product_price
where Product_ID = 220199993344
------------------------------------------------------------------------------------------------------------------------------------

                                                                 -- ANALYSIS OF SALES BY CUSTOMER STATUS --



-- percent of total sales by Customer Status
select Customer_status, sum(Total_retail_price_for_order) / 12023091.3198686 * 100 as percent_of_total_sales
from Orders_data
group by Customer_status


-- Detailed view on percent of total sales by Customer Status and year
select Customer_Status,
sum(case when year(Order_date ) = 2017 then Total_retail_price_for_order /  1894498.72976977 * 100 else 0 end ) as percent_of_total_sales_2017,
sum(case when year(Order_date ) = 2018 then Total_retail_price_for_order /  2264955.76022507 * 100 else 0 end ) as percent_of_total_sales_2018,
sum(case when year(Order_date ) = 2019 then Total_retail_price_for_order / 2744015.96938013 * 100 else 0 end ) as percent_of_total_sales_2019,
sum(case when year(Order_date ) = 2020 then Total_retail_price_for_order /  2334113.61997594 * 100 else 0 end ) as percent_of_total_sales_2020,
sum(case when year(Order_date ) = 2021 then Total_retail_price_for_order /  2785507.24051774 * 100 else 0 end ) as percent_of_total_sales_2021
from Orders_data
group by Customer_status


-- Total sales fluctuation  by Customer Status and Year ( using STDEV ) 
Select Customer_status,
STDEV( case when year ( Order_date ) = 2017 then  Total_retail_price_for_order else 0 end ) as Sales_fluctuation_2017  ,
STDEV( case when year ( Order_date ) = 2018 then  Total_retail_price_for_order else 0 end ) as Sales_fluctuation_2018 ,  
STDEV( case when year ( Order_date ) = 2019 then  Total_retail_price_for_order else 0 end ) as Sales_fluctuation_2019 , 
STDEV( case when year ( Order_date ) = 2020 then  Total_retail_price_for_order else 0 end ) as Sales_fluctuation_2020 ,
STDEV( case when year ( Order_date ) = 2021 then  Total_retail_price_for_order else 0 end )  as Sales_fluctuation_2021
from Orders_data
group by Customer_status

------------------------------------------------------------------------------------------------------------------------------------


                                                                 -- ANALYSIS OF SALES BY PRODUCT LINE --

-- calculating total sales by year in joined tables ( Orders Data + Suppliers_table ) total value will be used to find percent of total sales by Product line 
-- and year
select  
 sum ( case when  year(o.Order_date) = 2017 then o.Total_retail_price_for_order else 0 end ) as total_sales_by_2017,
 sum ( case when  year(o.Order_date) = 2018 then o.Total_retail_price_for_order else 0 end ) as total_sales_by_2018,
 sum ( case when  year(o.Order_date) = 2019 then o.Total_retail_price_for_order else 0 end ) as total_sales_by_2019,
 sum ( case when  year(o.Order_date) = 2020 then o.Total_retail_price_for_order else 0 end ) as total_sales_by_2020,
 sum ( case when  year(o.Order_date) = 2021 then o.Total_retail_price_for_order else 0 end ) as total_sales_by_2021
from Orders_data as o
join Suppliers_table as s on o.Product_ID = s.Product_ID

-- percent of total sales by Product line and year

select s.Product_line, 
 sum ( case when  year(o.Order_date) = 2017 then o.Total_retail_price_for_order / 892764161.393738 * 100 else 0 end ) as percent_of_total_sales_2017,
  sum ( case when  year(o.Order_date) = 2018 then o.Total_retail_price_for_order / 1073501120.44616 * 100 else 0 end ) as percent_of_total_sales_2018,
   sum ( case when  year(o.Order_date) = 2019 then o.Total_retail_price_for_order / 1299771414.05312 * 100 else 0 end ) as percent_of_total_sales_2019,
    sum ( case when  year(o.Order_date) = 2020 then o.Total_retail_price_for_order / 1097937179.74399 * 100 else 0 end ) as percent_of_total_sales_2020,
	 sum ( case when  year(o.Order_date) = 2021 then o.Total_retail_price_for_order / 1284338336.45562 * 100 else 0 end ) as percent_of_total_sales_2021
from Orders_data as o
join Suppliers_table as s on o.Product_ID = s.Product_ID
group by s.Product_line
------------------------------------------------------------------------------------------------------------------------------------
                                                                   --  ANALYSIS OF SALES BY PRODUCT CATEGORY --



-- percent of total sales by Product category and year
select s.Product_Category, 
 sum ( case when  year(o.Order_date) = 2017 then o.Total_retail_price_for_order / 892764161.393738 * 100 else 0 end ) as percent_of_total_sales_2017,
  sum ( case when  year(o.Order_date) = 2018 then o.Total_retail_price_for_order / 1073501120.44616 * 100 else 0 end ) as percent_of_total_sales_2018,
   sum ( case when  year(o.Order_date) = 2019 then o.Total_retail_price_for_order / 1299771414.05312 * 100 else 0 end ) as percent_of_total_sales_2019,
    sum ( case when  year(o.Order_date) = 2020 then o.Total_retail_price_for_order / 1097937179.74399 * 100 else 0 end ) as percent_of_total_sales_2020,
	 sum ( case when  year(o.Order_date) = 2021 then o.Total_retail_price_for_order / 1284338336.45562 * 100 else 0 end ) as percent_of_total_sales_2021
from Orders_data as o
join Suppliers_table as s on o.Product_ID = s.Product_ID
group by s.Product_Category
------------------------------------------------------------------------------------------------------------------------------------

														--	ANALYSIS OF QUANTITY SOLD, COUNT OF TRANSACTION, SHIPPING, CUSTOMERS --


														                     --  SHIPMENT  -- 


-- adding new column with shipment days count for Shipment analysis
Alter table Orders_data
add Shipping_days_count float

update Orders_data
set Shipping_days_count = DATEDIFF(day,Order_date, Delivery_date ) 

select * 
from Orders_data



-- Distribution of Shipment days count ( frequency of shipment lenght in days ) 
select 
' 0 - 4 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 0 and Shipping_days_count < 4 then 1 else null end ) as number_of_transaction 
from Orders_data 
UNION
select 
' 4 - 8 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 4 and Shipping_days_count < 8 then 1 else null end ) as number_of_transaction 
from Orders_data 
UNION
select 
' 8 - 12 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 8 and Shipping_days_count < 12 then 1 else null end ) as number_of_transaction 
from Orders_data 
UNION
select 
' 12 - 16 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 12 and Shipping_days_count < 16 then 1 else null end ) as number_of_transaction 
from Orders_data 
UNION
select 
' 16 - 20 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 16 and Shipping_days_count < 20 then 1 else null end ) as number_of_transaction 
from Orders_data 
UNION
select 
' 20 - 24 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 20 and Shipping_days_count < 24 then 1 else null end ) as number_of_transaction 
from Orders_data 
UNION
select 
' 24 - 28 days' as Shipping_days_count,
count ( case when Shipping_days_count > = 24 and Shipping_days_count <  28 then 1 else null end ) as number_of_transaction 
from Orders_data 
------------------------------------------------------------------------------------------------------------------------------------


                                                                          --ANALYSIS OF QUANTITY SOLD--

--distribution of quantity sold ( frequency of purchases by quantity )
select 
' 1 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 1 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 2 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 2 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 3 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 3 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 4 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 4 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 5 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 5 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 6 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 6 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 7 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 7 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 8 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 8 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 9 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 9 then 1 else null end ) as number_of_purchases 
from Orders_data 
UNION
select 
' 10 ' as Quantity_purchased,
count ( case when Quantity_ordered  = 10 then 1 else null end ) as number_of_purchases 
from Orders_data




-- analysis of quantity sold by Product line ( to get an idea of demand on certain Product Category )
select sum(o.Quantity_ordered)  -- 1702255104
from Orders_data o
join Suppliers_table as S on o.Product_ID = o.Product_ID

select  s.Product_Category  , Sum(cast(o.Quantity_ordered as decimal(10,0)) / 1702255104 * 100)  as percent_of_total_quantity_sold
from Orders_data as O
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by s.Product_Category
order by percent_of_total_quantity_sold desc



Select  year(o.Order_date), s.Product_Category    ,sum(o.Quantity_ordered)
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by    year(o.Order_date)  ,s.Product_Category
--order by percent_of_total_quantity_sold desc



--detailed view on how demand on certain Product Category has changes over the Years ( using quantity column ) 
select year(o.Order_date) , sum(o.Quantity_ordered)  as total_quantity_ordered -- 1702255104
from Orders_data o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by year(o.Order_date)
order by  year(o.Order_date)  asc

Select s.Product_Category ,
sum(case when year(o.Order_date) = 2017 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 271969152 * 100 else 0 end)  as percent_of_total_quantity_sold_2017,
sum(case when year(o.Order_date) = 2018 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 319765888 * 100 else 0 end)  as percent_of_total_quantity_sold_2018,
sum(case when year(o.Order_date) = 2019 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 387960448 * 100 else 0 end)  as percent_of_total_quantity_sold_2019,
sum(case when year(o.Order_date) = 2019 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 329166720 * 100 else 0 end)  as percent_of_total_quantity_sold_2020,
sum(case when year(o.Order_date) = 2019 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 393392896 * 100 else 0 end)  as percent_of_total_quantity_sold_2021
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by  s.Product_Category


--detailed view on how demand on certain Product Category has changes over the Months ( Analysing Quantity sold by Product Category during months ) 
select o.Month , sum(o.Quantity_ordered)  as total_quantity_ordered
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by  o.Month 

Select s.Product_Category ,
sum(case when  o.Month = 'January' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 114956544 * 100 else 0 end)  as percent_of_total_quantity_sold_January,
sum(case when  o.Month = 'February' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 91702144 * 100 else 0 end)  as percent_of_total_quantity_sold_February,
sum(case when  o.Month = 'March' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 88443776 * 100 else 0 end)  as percent_of_total_quantity_sold_March,
sum(case when  o.Month = 'April' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 132894080 * 100 else 0 end)  as percent_of_total_quantity_sold_April,
sum(case when  o.Month = 'May' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 157469440 * 100 else 0 end)  as percent_of_total_quantity_sold_May,
sum(case when  o.Month = 'June' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 199542016 * 100 else 0 end)  as percent_of_total_quantity_sold_June,
sum(case when  o.Month = 'July' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 201930752 * 100 else 0 end)  as percent_of_total_quantity_sold_July,
sum(case when  o.Month = 'August' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 201193216 * 100 else 0 end)  as percent_of_total_quantity_sold_August,
sum(case when  o.Month = 'September' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 87612672 * 100 else 0 end)  as percent_of_total_quantity_sold_September,
sum(case when  o.Month = 'October' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 87865856 * 100 else 0 end)  as percent_of_total_quantity_sold_October,
sum(case when  o.Month = 'November' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 105880448 * 100 else 0 end)  as percent_of_total_quantity_sold_November,
sum(case when  o.Month = 'December' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 232764160 * 100 else 0 end)  as percent_of_total_quantity_sold_December
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by  s.Product_Category
------------------------------------------------------------------------------------------------------------------------------------

                                                                   -- ANALYSYS OF PURCHASES --

-- Analysing Number of Purchases by Product Category and demand change over the months 
select o.Month , Count(o.Order_ID)  as total_purchases
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by  o.Month 


SELECT
    s.Product_Category,
    COUNT(CASE WHEN o.Month = 'January' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
	 COUNT(CASE WHEN o.Month = 'February' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
	  COUNT(CASE WHEN o.Month = 'March' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
	   COUNT(CASE WHEN o.Month = 'April' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
	    COUNT(CASE WHEN o.Month = 'May' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
		 COUNT(CASE WHEN o.Month = 'June' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
		  COUNT(CASE WHEN o.Month = 'July' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
		   COUNT(CASE WHEN o.Month = 'August' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
		    COUNT(CASE WHEN o.Month = 'September' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
			 COUNT(CASE WHEN o.Month = 'October' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
			  COUNT(CASE WHEN o.Month = 'November' THEN o.Order_ID  ELSE null END) AS January_Order_Count,
			   COUNT(CASE WHEN o.Month = 'December' THEN o.Order_ID  ELSE null END) AS January_Order_Count
FROM
    Orders_data o
JOIN
    Suppliers_table s ON o.Product_ID = s.Product_ID
GROUP BY
    s.Product_Category



--detailed view on how demand on certain Product Line has changes over the Years ( using quantity column ) 
Select s.Product_Line ,
sum(case when year(o.Order_date) = 2017 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 271969152 * 100 else 0 end)  as percent_of_total_quantity_sold_2017,
sum(case when year(o.Order_date) = 2018 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 319765888 * 100 else 0 end)  as percent_of_total_quantity_sold_2018,
sum(case when year(o.Order_date) = 2019 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 387960448 * 100 else 0 end)  as percent_of_total_quantity_sold_2019,
sum(case when year(o.Order_date) = 2019 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 329166720 * 100 else 0 end)  as percent_of_total_quantity_sold_2020,
sum(case when year(o.Order_date) = 2019 then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 393392896 * 100 else 0 end)  as percent_of_total_quantity_sold_2021
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by  s.Product_Line

-- detailed view on how demand on Product_line changing over the months ( Analysing Quantity sold by Product Line during months  )
Select s.Product_Line ,
sum(case when  o.Month = 'January' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 114956544 * 100 else 0 end)  as percent_of_total_quantity_sold_January,
sum(case when  o.Month = 'February' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 91702144 * 100 else 0 end)  as percent_of_total_quantity_sold_February,
sum(case when  o.Month = 'March' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 88443776 * 100 else 0 end)  as percent_of_total_quantity_sold_March,
sum(case when  o.Month = 'April' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 132894080 * 100 else 0 end)  as percent_of_total_quantity_sold_April,
sum(case when  o.Month = 'May' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 157469440 * 100 else 0 end)  as percent_of_total_quantity_sold_May,
sum(case when  o.Month = 'June' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 199542016 * 100 else 0 end)  as percent_of_total_quantity_sold_June,
sum(case when  o.Month = 'July' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 201930752 * 100 else 0 end)  as percent_of_total_quantity_sold_July,
sum(case when  o.Month = 'August' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 201193216 * 100 else 0 end)  as percent_of_total_quantity_sold_August,
sum(case when  o.Month = 'September' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 87612672 * 100 else 0 end)  as percent_of_total_quantity_sold_September,
sum(case when  o.Month = 'October' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 87865856 * 100 else 0 end)  as percent_of_total_quantity_sold_October,
sum(case when  o.Month = 'November' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 105880448 * 100 else 0 end)  as percent_of_total_quantity_sold_November,
sum(case when  o.Month = 'December' then o.Quantity_ordered / cast(o.Quantity_ordered as decimal(10,0))/ 232764160 * 100 else 0 end)  as percent_of_total_quantity_sold_December
from Orders_data as o
join Suppliers_table as S on o.Product_ID = o.Product_ID
group by  s.Product_Line
------------------------------------------------------------------------------------------------------------------------------------


                                                                 -- SUPPLIERS OVERVIEW

-- count of  suppliers by country 
select 
count( case when Supplier_Country = 'Netherlands' then Supplier_ID else null end) Suppliers_by_Netherlands,
count( case when Supplier_Country = 'Germany' then Supplier_ID else null end) Suppliers_by_Germany,
count( case when Supplier_Country = 'United States' then Supplier_ID else null end) Suppliers_by_United_States,
count( case when Supplier_Country = 'Australia' then Supplier_ID else null end) Suppliers_by_Australia,
count( case when Supplier_Country = 'Sweden' then Supplier_ID else null end) Suppliers_by_Sweden,
count( case when Supplier_Country = 'Great Britain' then Supplier_ID else null end) Suppliers_by_Great_Britain,
count( case when Supplier_Country = 'Canada' then Supplier_ID else null end) Suppliers_by_Canada,
count( case when Supplier_Country = 'Norway' then Supplier_ID else null end) Suppliers_by_Norway,
count( case when Supplier_Country = 'France' then Supplier_ID else null end) Suppliers_by_France,
count( case when Supplier_Country = 'Belgium' then Supplier_ID else null end) Suppliers_by_Belgium,
count( case when Supplier_Country = 'Spain' then Supplier_ID else null end) Suppliers_by_Spain,
count( case when Supplier_Country = 'Denmark' then Supplier_ID else null end) Suppliers_by_Denmark,
count( case when Supplier_Country = 'Portugal' then Supplier_ID else null end) Suppliers_by_Portugal
from Suppliers_table








-- count of product supply by country and year
select s.Supplier_Country,
count(case when year(o.Order_date) = 2017 then o.Product_ID else null end ) as Count_of_product_supply_2017,
count(case when year(o.Order_date) = 2018 then o.Product_ID else null end ) as Count_of_product_supply_2018,
count(case when year(o.Order_date) = 2019 then o.Product_ID else null end ) as Count_of_product_supply_2019,
count(case when year(o.Order_date) = 2020 then o.Product_ID else null end ) as Count_of_product_supply_2020,
count(case when year(o.Order_date) = 2021 then o.Product_ID else null end ) as Count_of_product_supply_2021
from Orders_data o
join Suppliers_table s on o.Product_ID = s.Product_ID
group by s.Supplier_Country



-- count of products by country and supplier 
select s.Supplier_Country , s.Supplier_Name,count( o.Product_ID) as number_of_products
from Orders_data o
join Suppliers_table s on o.Product_ID = s.Product_ID
group by  s.Supplier_Country ,s.Supplier_Name
order by number_of_products desc








                             -- ANALYSIS OF CUSTOMER AND SEGMENT ( TOTAL CUSTOMERS, SALES, PURCHASES, PURCHASE BAHAVIOUR etc. )

select count( distinct o.Customer_ID)
from Orders_data o
inner join Suppliers_table s on o.Product_ID = s.Product_ID


select o.Customer_status ,count (distinct o.Customer_ID ) 
from Orders_data o
inner join Suppliers_table s on o.Product_ID = s.Product_ID -- total count of customers
group by o.Customer_status


-- sales by customer status
select sum(o.Total_retail_price_for_order) as total_sales
from Orders_data o
inner join Suppliers_table s on o.Product_ID = s.Product_ID

select o.Customer_status, sum(o.Total_retail_price_for_order) / 5648312212.09257 * 100 as percent_of_total_sales
from Orders_data o
inner join Suppliers_table s on o.Product_ID = s.Product_ID
group by o.Customer_status


-- count of purchases by customer status
select count(o.Order_ID) 
from Orders_data o
inner join Suppliers_table s on o.Product_ID = s.Product_ID

select o.Customer_status, count(o.Order_ID) as count_of_purchases
from Orders_data o
inner join Suppliers_table s on o.Product_ID = s.Product_ID
group by o.Customer_status


-- detailted view on purchase trends by customer status and year 
select Customer_status,
count( case when year(Order_date) = 2017 then Order_ID  else null end ) as Count_of_purchases_2017,
count( case when year(Order_date) = 2018 then Order_ID  else null end ) as Count_of_purchases_2018,
count( case when year(Order_date) = 2019 then Order_ID  else null end ) as Count_of_purchases_2019,
count( case when year(Order_date) = 2020 then Order_ID  else null end ) as Count_of_purchases_2020,
count( case when year(Order_date) = 2021 then Order_ID  else null end ) as Count_of_purchases_2021
from Orders_data
group by Customer_status

-- view on purchase behavior by customer status and month
select Customer_status,
count( case when Month = 'January' then Order_ID  else null end ) as Count_of_purchases_January,
count( case when Month = 'February' then Order_ID  else null end ) as Count_of_purchases_February,
count( case when Month = 'March' then Order_ID  else null end ) as Count_of_purchases_March,
count( case when Month = 'April' then Order_ID  else null end ) as Count_of_purchases_April,
count( case when Month = 'May' then Order_ID  else null end ) as Count_of_purchases_May,
count( case when Month = 'June' then Order_ID  else null end ) as Count_of_purchases_June,
count( case when Month = 'July' then Order_ID  else null end ) as Count_of_purchases_July,
count( case when Month = 'August' then Order_ID  else null end ) as Count_of_purchases_August,
count( case when Month = 'September' then Order_ID  else null end ) as Count_of_purchases_September,
count( case when Month = 'October' then Order_ID  else null end ) as Count_of_purchases_October,
count( case when Month = 'November' then Order_ID  else null end ) as Count_of_purchases_November,
count( case when Month = 'December' then Order_ID  else null end ) as Count_of_purchases_December
from Orders_data
group by Customer_status

















	

















































