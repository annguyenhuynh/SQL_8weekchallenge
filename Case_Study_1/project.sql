--What is the total amount each customer spent at the restaurant?
select sum(m.price),s.customer_id
from danny_dinner.menu m
join danny_dinner.sales s
on m.product_id = s.product_id
group by s.customer_id;

--How many days each customer has spent at the restaurant?
select count(order_date), customer_id
from danny_dinner.sales
group by customer_id;

--What was the first item from the menu purchased by each customer?
select s.customer_id, s.product_id, m.product_name,
	rank() over (order by s.order_date) as first_item
from danny_dinner.sales s
join danny_dinner.menu m
on s.product_id = m.product_id
where s.order_date = '2021-01-01';

-- What is the most purchashed item on the menu and how many times it was purchased by all customers?
select count(s.*) times_ordered, s.product_id, m.product_name
from danny_dinner.sales s
join danny_dinner.menu m
on s.product_id = m.product_id
group by s.product_id, m.product_name
order by count(s.*) desc
limit 1;
 
-- What is the most popular item for each customer?
select 	s.customer_id, m.product_name,
		count(s.*) as num_item_ordered
from danny_dinner.sales s
join danny_dinner.menu m
on s.product_id = m.product_id
group by customer_id, m.product_name
order by customer_id asc, num_item_ordered desc

-- Which item was purchased first by the customer after they became member?
-- The order can be on the same date or the nearest date after the join date
with cte as (
	select 
		s.customer_id, 
		c.join_date,
		s.order_date,
		s.product_id,
		dense_rank() over(partition by s.customer_id order by s.order_date) as first_order
	from danny_dinner.sales s
	join danny_dinner.customer c
	on s.customer_id = c.customer_id
	where s.order_date >= c.join_date
)

select 
	cte.customer_id,
	cte.order_date,
	m.product_name
from cte
join danny_dinner.menu m
on cte.product_id = m.product_id
where first_order = 1

-- Which item was purchased just before the customer became a member?
with cte as (
	select 
		s.customer_id, 
		c.join_date,
		s.order_date,
		s.product_id,
		dense_rank() over(partition by s.customer_id order by s.order_date desc) as first_order
	from danny_dinner.sales s
	join danny_dinner.customer c
	on s.customer_id = c.customer_id
	where s.order_date < c.join_date
)

select 
	cte.customer_id,
	cte.order_date,
	m.product_name
from cte
join danny_dinner.menu m
on cte.product_id = m.product_id
where first_order = 1

--What is the total items and amount spent for each member before they became a member?
with cte_1 as (
select 
	s.customer_id, 
	c.join_date, 
	s.order_date,
	count(m.product_id) over (partition by s.customer_id) as total_item
from danny_dinner.sales s
join danny_dinner.menu m
on s.product_id = m.product_id
join danny_dinner.customer c
on s.customer_id = c.customer_id
where s.order_date < c.join_date
group by s.customer_id, s.order_date, c.join_date, m.product_id, m.price
	),
	
cte_2 as (
select 
	s.customer_id,
	sum(m.price) over (partition by s.customer_id order by c.join_date) as total_amt_spent,
	c.join_date
from danny_dinner.sales s
join danny_dinner.menu m
on s.product_id = m.product_id
join danny_dinner.customer c
on s.customer_id = c.customer_id
where s.order_date < c.join_date
	)

select 
	distinct cte_2.total_amt_spent,
	cte_1.customer_id,
	cte_1.total_item
from cte_1
join cte_2
on cte_1.customer_id = cte_2.customer_id
group by cte_1.customer_id, cte_2.total_amt_spent, cte_1.total_item;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as (
select 
	s.customer_id, 
	s.order_date,
	case when m.product_name = 'sushi'
	then m.price * 20
	else m.price * 10
	end as points_earned
from danny_dinner.sales s
join danny_dinner.menu m
on s.product_id = m.product_id
	)
	
select 
	customer_id,
	sum (points_earned) as total_points
from points
group by customer_id

--In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi 
--how many points do customer A and B have at the end of January?
with total_points as (
select 
	s.customer_id,
	case when s.order_date between c.join_date and c.join_date + interval '6 day'
	then m.price * 20
	else 
		case when s.order_date < '2021-02-01'
	 	then case when m.product_id = '1'
			then m.price * 20
			else m.price * 10
			end
		end
	end as points
from danny_dinner.sales s
join danny_dinner.customer c
using (customer_id)
join danny_dinner.menu m
using (product_id)
	)

select customer_id,
		sum(points) as points_earned
from total_points
group by customer_id;
