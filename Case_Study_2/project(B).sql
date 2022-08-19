--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select
	count (*) as num_runners_registered,
	r.week_num
from (
		select 
			to_char(registration_date, 'W') as week_num
		from pizza_runner.runners) r
group by r.week_num
order by r.week_num asc;

--What was the average time in minutes it took 
--for each runner to arrive at the Pizza Runner HQ to pickup the order?
with average_mins as (
	SELECT
	c.customer_id,
	o.order_id,
	r.runner_id,
	o.pickup_time -  c.order_time as mins_diff
from pizza_runner.customer_orders c
join pizza_runner.runner_orders o 
on c.order_id = o.order_id
join pizza_runner.runners r
on o.runner_id = r.runner_id
where o.pickup_time is not null 
group by c.customer_id, o.order_id, o.pickup_time,c.order_time, r.runner_id
order by c.customer_id) 

select 
	runner_id,
	avg(mins_diff) as avg_mins_diff
from average_mins
group by runner_id;


--Is there any relationship between the number of pizzas and how long the order takes to prepare?
with time_diff AS
(select 
 	c.order_id,
 	count(c.order_id) as num_pizzas,
 	o.pickup_time - c.order_time as mins_diff
from pizza_runner.customer_orders c 
join pizza_runner.runner_orders o 
on o.order_id = c.order_id
where o.distance is not null
group by c.order_id, o.pickup_time, c.order_time
 )

select 
num_pizzas, 
avg(mins_diff) as avg_mins_prep
from time_diff
group by num_pizzas;

--What was the average distance travelled for each customer?
select
	c.customer_id,
	round(avg(o.distance),2) as avg_distance
from pizza_runner.customer_orders c
join pizza_runner.runner_orders o
on c.order_id = o.order_id
GROUP by c.customer_id
order by c.customer_id;

--What was the difference between the longest and shortest delivery times for all orders?
select 
	max(duration) - min(duration) as diff_delivery_min
from pizza_runner.runner_orders;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
with cte as( 
select 
	runner_id,
	(distance*60/duration) as km_hr_speed
from pizza_runner.runner_orders
) 

select 
	runner_id,
	round(sum(km_hr_speed)) as avg_speed
from cte
group by runner_id;

--What is the successful delivery percentage for each runner?
with cte_1 as (
select 
runner_id,
count(order_id) as y
from pizza_runner.runner_orders
group by runner_id),

cte_2 as (
select 
runner_id,
count(order_id) as x
from pizza_runner.runner_orders
where distance is not null and duration is not null
group by runner_id)

select 
	cte_2.runner_id,
	round((cte_2.x::numeric/cte_1.y * 100),2)  as succesfull_delivery_percentage
from cte_1
join cte_2
on cte_1.runner_id = cte_2.runner_id
group by cte_2.runner_id, cte_2.x, cte_1.y
order by cte_2.runner_id
