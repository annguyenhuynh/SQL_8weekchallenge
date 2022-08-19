--How many pizzas were ordered?
select 
	count (*) as total_pizzas_ordered
from pizza_runner.customer_orders;

--How many unique customer orders were made?
select 
	count(distinct order_id) as num_orders
from pizza_runner.customer_orders;

--How many successful orders were delivered by each runner?
--Successful deliveries are those where duration is NOT NULL
select
	runner_id,
	count(distinct order_id) as successful_orders
from pizza_runner.runner_orders 
where duration is not null
group by runner_id;

--How many times each type of pizza were delivered?
select 
	n.pizza_id,
	count(c.order_id) as pizza_delivered
from pizza_runner.pizza_names n
join pizza_runner.customer_orders c
on n.pizza_id = c.pizza_id
join pizza_runner.runner_orders o
on c.order_id = o.order_id
where o.duration is not null
group by n.pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	c.customer_id,
	n.pizza_name,
	count (c.pizza_id)  as num_ordered
FROM pizza_runner.customer_orders c
join pizza_runner.pizza_names n 
on c.pizza_id = n.pizza_id
group by c.customer_id, c.pizza_id, n.pizza_name
order by c.customer_id asc;

--What was the maximum number of pizzas delivered in a single order?
with num_orders as (
SELECT
	customer_id,
	order_id,
	count(*)  as pizzas_per_order
from pizza_runner.customer_orders 
group by customer_id, order_id, pizza_id
order by customer_id, pizzas_per_order DESC
	)

select order_id,
		sum(pizzas_per_order) as max_pizza_ordered
from num_orders
group by order_id
order by max_pizza_ordered DESC
limit 1;

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select 
	c.customer_id,
	sum (
		case when c.exclusions = '' and c.extras = ''
		then 1
		else 0
		end )as no_change,
	sum ( 
		case when c.exclusions != '' or c.extras!= ''
		then 1
		else 0
		end) as at_least_1_change
from pizza_runner.customer_orders c 
join pizza_runner.runner_orders o 
on c.order_id = o.order_id
where o.duration is not NULL
group by c.customer_id 
order by c.customer_id asc;

--How many pizzas were delivered that had both exclusions and extras?
select 
	count(n.pizza_id) as num_pizzas
from pizza_runner.pizza_names n
join pizza_runner.customer_orders c
on n.pizza_id = c.pizza_id
where c.exclusions != '' and c.extras!= ''

--What was the total volume of pizzas ordered for each hour of the day?
select 
	count(pizza_id) as pizza_orders,
	date_part('hour',  order_time) as hour
from pizza_runner.customer_orders
GROUP by hour
order by hour asc;

--What was the volume of orders for each day of the week?
SELECT
	to_char(order_time, 'DAY') as day_in_week,
	count(order_id) as pizzas_ordered	
from pizza_runner.customer_orders
group by day_in_week
order by day_in_week desc;

		
