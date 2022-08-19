--What are the standard ingredients for each pizza?
select 
	pr1.pizza_id,
	t.topping_name
from pizza_runner.pizza_recipes1 pr1
join pizza_runner.pizza_toppings t 
on pr1.toppings = t.topping_id
group by pr1.pizza_id, t.topping_name
order by pr1.pizza_id;

--What was the most commonly added extra?
select 
	count(theextras), theextras
from 
	(select unnest(string_to_array(extras, ',')) as theextras
	from pizza_runner.customer_orders) as theextras
group by theextras
order by count(theextras) desc;
--the most common extra is number 1, bacon

--What was the most common exclusion?
select 
	count(theexclusion), theexclusion
from 
 (select unnest(string_to_array(exclusions, ',')) as theexclusion
 from pizza_runner.customer_orders) theexclusion
group by theexclusion
order by count(theexclusion) desc;
--the most common exclusion is number 4, cheese

--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

select 
	c.order_id, c.pizza_id, n.pizza_name, c.exclusions, c.extras, 
	case 
	when c.pizza_id = 1 and (c.exclusions = '') and (c.extras = '') then 'Meat Lovers'
	when c.pizza_id = 2 and (c.exclusions = '') and (c.extras = ''or c.extras = 'Nan') then 'Vegetarian Lovers'
	when c.pizza_id = 1 and (c.exclusions like '4') and (c.extras = '') then 'Meat Lovers - Exclude Cheese'
	when c.pizza_id = 2 and (c.exclusions like '4') and (c.extras = '') then 'Meat Lovers - Exclude Cheese'						 
	when c.pizza_id = 1 and (c.exclusions like '4') and (c.extras like '1, 5') then 'Meat Lovers - Exclude Cheese - Add Bacon and Chicken'
	WHEN c.pizza_id = 1 and (c.exclusions like '2, 6') and (c.extras like '1, 4') then 'ML-Exclude BBQ, mushroom-Add bacon, cheese'
	WHEN c.pizza_id = 1 and (c.exclusions = '')	and (c.extras = '1') then 'Meat Lovers - Add bacon'
	when c.pizza_id = 2 and (c.exclusions = '')	and (c.extras = '1') then 'Meat Lovers - Add bacon'
end as order_summary						

from pizza_runner.customer_orders c
join pizza_runner.pizza_names n 
on c.pizza_id = n.pizza_id; 

-- Generate an alphabetically ordered comma separated ingredient list for each pizza 
--order from the customer_orders table 
--and add a 2x in front of any relevant ingredients
select
	order_id, pizza_id,
	case 
	when pizza_id = 1 and extras = '' then 'Meat Lovers: Bacon, BBQ sauce, Beef, Cheese,...Salami'
	when pizza_id = 2 and (extras = '' or extras like 'Nan') then 'Vegetarian Lovers: Cheese, Mushroom, Onions...Tomatoes'
	when pizza_id = 2 and extras like '1' then 'Vegetarian Lovers: Bacon, Cheese, Mushroom... Tomatoes'
	when pizza_id = 1 and extras like '1, 5' then 'Meat Lovers: 2xBacon, BBQ sauce, Beef, Cheese. 2xChicken...Salami'
	when pizza_id = 1 and extras like '1, 4' then 'Meat Lovers: 2xBacon, BBQ sause, Beef, 2xCheese,...Salami'
	when pizza_id = 1 and extras like '1' then 'Meat Lovers: 2xBacon,...Salami'
	end as ordered_items 
from pizza_runner.customer_orders; 

--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
with cte as (
SELECT 
	c.order_id,
	count(distinct pr1.toppings) as numbers_ordered,
	t.topping_name
from pizza_runner.customer_orders c 
join pizza_runner.pizza_recipes1 pr1 
on c.pizza_id = pr1.pizza_id 
join pizza_runner.pizza_toppings t 
on pr1.toppings = t.topping_id 
group by c.order_id, t.topping_name  
)  

select 
	order_id,
	sum(numbers_ordered) as total_items_ordered
from cte
group by order_id 
order by total_items_ordered desc;
