select * from pizza_sales$
---Before we start with our analysis, let's first clean the dataset. so we are going to standardize the date columns, pizza size check each row and column
---for errors and discrepancies and remove duplicates

select COUNT(distinct pizza_id) as Count_rows from pizza_sales$
select distinct(pizza_name_id) as Dist_pizzas_id from pizza_sales$
select distinct(pizza_category) from pizza_sales$
select distinct(pizza_name) from pizza_sales$

---Alright we can now start the formatting
select order_date, CONVERT(date, order_date) as order_dateConv from pizza_sales$
select order_time, CONVERT(time, order_time) as order_timeConv from pizza_sales$

---Now, we want to standardize pizza_size column
select distinct(pizza_size) from pizza_sales$
select pizza_size,
CASE
WHEN pizza_size = 'S' THEN 'Small'
WHEN pizza_size = 'L' THEN 'Large'
WHEN pizza_size = 'XL' THEN 'Extra Large'
WHEN pizza_size = 'XXL' THEN 'Extra Extra Large'
WHEN pizza_size = 'M' THEN 'Medium'
ELSE pizza_size
END as Pizza_Sizes FROM pizza_sales$

---Now that we have these new tables, we need to replace the old columns with the new ones with ALTER AND UPDATE function after which we shall delete the old column. okay
ALTER TABLE pizza_sales$
ADD order_dateConv DATE

UPDATE pizza_sales$
SET order_dateConv = CONVERT(date, order_date)

ALTER TABLE pizza_sales$
ADD order_timeConv TIME

UPDATE pizza_sales$
SET order_timeConv = CONVERT(time, order_time)

ALTER TABLE pizza_sales$
ADD Pizza_Sizes VARCHAR(100)

UPDATE pizza_sales$
SET Pizza_Sizes = CASE
WHEN pizza_size = 'S' THEN 'Small'
WHEN pizza_size = 'L' THEN 'Large'
WHEN pizza_size = 'XL' THEN 'Extra Large'
WHEN pizza_size = 'XXL' THEN 'Extra Extra Large'
WHEN pizza_size = 'M' THEN 'Medium'
ELSE pizza_size
END


SELECT * from pizza_sales$
---Okay so this is our table but before we drop columns we wont be using, I'll like to make the calculation for total price myself to avoid any wrong figures in the dataset. who knows
select (quantity * unit_price) as revenue from pizza_sales$

---okay we shall ALTER TABLE and update this information as our revenue now
ALTER TABLE pizza_sales$
ADD revenue DECIMAL(10, 2)

UPDATE pizza_sales$
SET revenue = (quantity * unit_price)

SELECT * FROM pizza_sales$

---Okay now we can drop our unused columns or converted columns

ALTER TABLE pizza_sales$
DROP COLUMN order_date, order_time, pizza_size, total_price

---Let's create a view for this
CREATE VIEW Pizza as SELECT * FROM pizza_sales$

---Okay now we want to answer some business questions as requested by the manager
select * from Pizza


--- Retrieve the total number of orders placed.
--- Calculate the total revenue generated from pizza sales.
--- Identify the highest-priced pizza.
--- Identify the most common pizza size ordered.
--- List the top 5 most ordered pizza types along with their quantities.

---Total orders placed
select count(distinct order_id) as orders_placed from Pizza

---Total revenue generated
select sum(revenue) as Total_Revenue from Pizza

---Highest priced Pizza
select DISTINCT(pizza_name), CAST(unit_price AS decimal(10, 2)) as highest_priced_pizza from Pizza
ORDER BY CAST(unit_price AS decimal(10, 2)) DESC

---Identify the most common pizza size ordered
select Pizza_Sizes, count(Pizza_Sizes) as Orders_pizza_sizes from Pizza group by Pizza_Sizes


---List the top 5 most ordered pizza types along with their quantities
select top 5 pizza_name, count(quantity) as top_5_ordered_pizza from Pizza
GROUP BY pizza_name
ORDER BY top_5_ordered_pizza DESC

---Again management is looking to see us answer these additional questions. Management seems to really like what we have done
---find the total quantity of each pizza category ordered.
---Determine the distribution of orders by hour of the day.
---find the category-wise distribution of pizzas.
---Group the orders by date and calculate the average number of pizzas ordered per day.
---Determine the top 3 most ordered pizza types based on revenue.

select * from Pizza
---Total quantity of each pizza category ordered
select distinct(pizza_category), count(quantity) as total_qauntity from Pizza
GROUP BY pizza_category
ORDER BY total_qauntity DESC

---The distribution of orders by hour
select datepart(hour, order_timeConv) as Order_hour, count(order_id) as no_of_orders from Pizza
GROUP BY datepart(hour, order_timeConv)
ORDER BY no_of_orders DESC

---Find the category-wise distribution of pizzas
select distinct(pizza_category), count(order_id) no_of_orders from Pizza
GROUP BY pizza_category
ORDER BY no_of_orders

---Group the orders by date and calculate the average number of pizzas ordered per day.

select  distinct(order_dateConv), AVG(order_id) AS Avg_orders_by_day from Pizza
group by order_dateConv
ORDER BY AVG(order_id) DESC

---Determine the top 3 most ordered pizza types based on revenue
select top 3 pizza_name, sum(revenue) AS REVENUE from Pizza
group by pizza_name
order by sum(revenue) DESC

select * from Pizza
---Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select top 3 pizza_name, pizza_category, SUM(revenue) AS REV from Pizza
group by pizza_name, pizza_category
ORDER BY pizza_name, pizza_category, REV DESC


--Manager now wants to see
--- Average order Value
--- Total Pizzas sold
--- Find the daily trend for total orders
--- Find the monthly trend for total orders
--- % of sales by pizza category
--- % of sales by pizza size
--- total pizzas sold per pizza category
--- Find the bottom 5 pizzas by revenue
--- find top 5 pizzas by quantity
--- bottom 5 pizzas by qantity
--- Top 5 pizzas by total orders
--- bottom 5 pizzas by total orders

select * from Pizza

--Average order Value
select (sum(revenue) / count(distinct order_id)) as Avg_order_value from pizza

--Tot pizza sold
select sum(quantity) as sum_qty from pizza

--Find the daily trend for total orders
select DATENAME(DW, order_dateConv) as day, count(distinct order_id) as Daily_order_trends from Pizza
GROUP BY DATENAME(DW, order_dateConv)
ORDER BY Daily_order_trends DESC

--Find the monthly trend for total orders
SELECT DATENAME(month, order_dateConv) as month, count(distinct order_id) as Monthly_order_trends from Pizza
GROUP BY DATENAME(month, order_dateConv)
ORDER BY Monthly_order_trends DESC

--% of revenue by pizza category
SELECT pizza_category, CAST(SUM(revenue) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(revenue) * 100 / (SELECT SUM(revenue) from pizza) AS DECIMAL(10,2)) AS Rev_Perc
FROM pizza
GROUP BY pizza_category
ORDER BY Rev_Perc DESC

--% of Rev by pizza size
select Pizza_Sizes, cast(sum(revenue) as decimal(10, 2)) as total_revenue, cast(sum(revenue) * 100 / (select sum(revenue) from pizza) AS DECIMAL(10, 2)) as Rev_Percentage from pizza
GROUP BY Pizza_Sizes
ORDER BY Rev_Percentage DESC

---total pizzas sold per pizza category
select distinct(pizza_category), sum(quantity) as qty_by_category from Pizza
GROUP BY pizza_category
ORDER BY qty_by_category


SELECT * FROM Pizza
--Find the bottom 5 pizzas by revenue
SELECT pizza_name, SUM(revenue) AS REV from Pizza
GROUP BY pizza_name
ORDER BY SUM(revenue) ASC


--find top 5 pizzas by quantity
SELECT TOP 5 pizza_name, sum(quantity) as highest_qty
from pizza
GROUP BY pizza_name
ORDER BY sum(quantity) DESC


--bottom 5 pizzas by qantity
SELECT distinct(pizza_name), sum(quantity) as Bottom_5 from Pizza
GROUP BY pizza_name
ORDER BY sum(quantity)

--Top 5 pizzas by total orders
select TOP 5 pizza_name, COUNT(DISTINCT order_id) as tot_orders from Pizza
GROUP BY pizza_name
ORDER BY  COUNT(DISTINCT order_id) DESC

--BOTTOM 5 pizzas by total orders

SELECT TOP 5 pizza_name, count(distinct order_id) as counts from pizza
GROUP BY pizza_name
ORDER BY count(distinct order_id) ASC

---Now I will transfer this sql project into power bi and then create some visuals and yhh


