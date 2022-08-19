--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 
--and there were no charges for changes 
--How much money has Pizza Runner made so far if there are no delivery fees?
with cte as (
select 
	order_id,
	case 
	when pizza_id = 1 then 12
	else 10
	end as pizza_price 
from pizza_runner.customer_orders 
order by order_id
	) 
select o.runner_id,
		sum(pizza_price) as total_earning
from pizza_runner.runner_orders o 
join cte 
on cte.order_id = o.order_id 
group by o.runner_id 
order by o.runner_id;

--What if there was an additional $1 charge for any pizza extras?
with cte_1 as ( 
	select 
	pizza_id,
	order_id,
	unnest(string_to_array(extras, ',')) as theextras
from pizza_runner.customer_orders 
where extras != 'Nan'
), 
cte_2 as (
select 
	distinct (cte_1.order_id), pr1.toppings,
	case 
		when c.pizza_id = 1 and c.extras = '' then 12
		when c.pizza_id = 2 and c.extras = '' then 10
        when c.pizza_id = 1 and cte_1.theextras is not null then 1+12
		when c.pizza_id = 2 and cte_1.theextras is not null then 1+10
	end as total_price 

from cte_1 
join pizza_runner.pizza_recipes1 pr1
on cte_1.theextras::integer = pr1.toppings
join pizza_runner.customer_orders c
on pr1.pizza_id = c.pizza_id

	) 

select o.runner_id, 
		sum(total_price) as modified_earning
from pizza_runner.runner_orders o 
join cte_2 
on cte_2.order_id = o.order_id 
group by o.runner_id
order by o.runner_id;

--Create a new table that record ratings for each successful customer order between 1 to 5.
drop table if exists pizza_runner.ratings;
create table pizza_runner.ratings (
	order_id integer, 
	ratings integer) 
insert into pizza_runner.ratings(order_id, ratings) 
values 
	('1', '3'),
	('2', '1'),
	('3', '4'),
	('4', '2'),
	('5', '3'),
	('7', '5'),
	('8', '4'),
	('10', '3');

--Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	--customer_id
	--order_id
	--runner_id
	--rating
	--order_time
	--pickup_time
 	--Time between order and pickup
	--Delivery duration
	--Average speed
	--Total number of pizzas
	
select 
	c.customer_id,
	c.order_id,
	o.runner_id,
	ra.ratings,
	c.order_time,
	o.pickup_time, 
	o.pickup_time - c.order_time as difference_in_time,
	o.duration,
	round(avg(o.distance * 60/o.duration),2) as average_speed,
	count(c.order_id) as total_pizzas_ordered
from pizza_runner.customer_orders c
inner join pizza_runner.runner_orders o 
on c.order_id = o.order_id 
inner join pizza_runner.ratings ra 
on ra.order_id = o.order_id 
group by c.customer_id,c.order_id,o.runner_id,ra.ratings,c.order_time,o.pickup_time,o.duration
order by c.customer_id;

