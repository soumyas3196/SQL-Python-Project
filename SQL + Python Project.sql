SELECT TOP (10) [order_id]
      ,[order_date]
      ,[ship_mode]
      ,[segment]
      ,[country]
      ,[city]
      ,[state]
      ,[postal_code]
      ,[region]
      ,[category]
      ,[sub_category]
      ,[product_id]
      ,[quantity]
      ,[discount]
      ,[sale]
      ,[profit]
  FROM [master].[dbo].[df_orders]


--find top 10 highest reveue generating products 
select top 10 product_id, sum(sale) as sales
from dbo.df_orders
group by product_id
order by sales desc


--find top 5 highest selling products in each region
with cte as
(select region,product_id, sum(quantity) as sales
from dbo.df_orders
group by region,product_id)
select * from
(select *, row_number() over(partition  by region order by sales) as rn
from cte) A
where rn <= 5


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as(
select year(order_date) as order_year,
month(order_date) as order_month,
sum(sale) as sales
from dbo.df_orders
group by year(order_date), month(order_date)
)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as Sales_2023
from cte
group by order_month
order by order_month

--for each category which month had highest sales 

with cte as (
select category,sum(sale) as sales,month(order_date) as order_month
from dbo.df_orders
group by category, month(order_date)
)
select * from
(select *, row_number() over(partition by category order by sales) as rn
from cte) A
where rn= 1

--which sub category had highest growth by profit in 2023 compare to 2022

with cte as
(
select sub_category, year(order_date) as order_year,sum(profit) as profit
from dbo.df_orders
group by sub_category, year(order_date)
)
,cte2 as
(
select sub_category,
sum(case when order_year = 2022 then profit else 0 end) as profit_2022,
sum(case when order_year = 2023 then profit else 0 end) as profit_2023
from cte
group by sub_category
)
select top 1 *
, profit_2023 - profit_2022
from cte2
order by (profit_2023 - profit_2022) desc


