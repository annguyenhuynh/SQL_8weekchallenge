--Number of customers
select 
	count(distinct user_id) as num_users
from click_bait.users;

--Cookies each users have
select 
	user_id,
	count(distinct cookie_id) as cookies
from click_bait.users
group by user_id;

--Unique number of visits by all users per month
select
	u.user_id,
	extract(month from e.event_time) as months,
	count(distinct e.visit_id) as num_visits
from click_bait.users u 
join click_bait.events e 
on u.cookie_id = e.cookie_id
group by u.user_id, extract(month from e.event_time);

--Number of events for each event type
select 
	i.event_name,
	count(e.event_type) as num_events
from click_bait.event_identifier i
join click_bait.events e
on i.event_type = e.event_type
group by i.event_name;

--Percentage of visit that has purchase event
with cte as (
	select 
		count(visit_id) as total_visits,
		sum(case when event_type = 3 then 1 end) as purchase_event
	from click_bait.events
)

select 
	total_visits,
	purchase_event,
	(select round((purchase_event::numeric/total_visits::numeric *100),2) from cte)
from cte;

--Percentage of visits that view the checkout page but do not have a purchase event?
with purchase as (
	select 
		distinct e.visit_id
	from click_bait.events e
	join click_bait.event_identifier i
	using (event_type)
	where i.event_type = 3),
checkout as(
select 
		distinct e.visit_id,
		sum(event_type) as checkout_only
from click_bait.events e
join click_bait.page_hierarchy h
on e.page_id = h.page_id
where h.page_id = 12
	and e.visit_id not in (select visit_id
						  from purchase)
group by e.visit_id
),

total_purchase as (
select
	count(*) as total_purchase
from click_bait.events
)

select 
round(sum((checkout_only)::numeric / (select count(*) from click_bait.events)*100),2) as view_not_purchase_percentage
from checkout
join click_bait.events
on checkout.visit_id = events.visit_id;

--Top three pages by number of views
select 
	h.page_name,
	count(*) as num_views
from click_bait.page_hierarchy h
join click_bait.events e
using (page_id)
where e.event_type = 1
group by h.page_name
order by count(*) desc
limit 3;

--Number of views and cart adds for each product category
with views as (
select 
	h.page_name,
	count(case when e.event_type = 1 then 1 end) as total_views
from click_bait.page_hierarchy h
join click_bait.events e
on h.page_id = e.page_id
group by h.page_name
),

 add_cart as(
select 
	h.page_name,
	count(case when e.event_type = 2 then 1 end) as total_cart_adds
from click_bait.page_hierarchy h
join click_bait.events e
on h.page_id = e.page_id
group by h.page_name
)

select 
	views.page_name as product,
	total_views,
	total_cart_adds
from views 
join add_cart 
using (page_name)
group by views.page_name, total_views, total_cart_adds;

--What are top 3 products by purchase?
--The idea here is that: add cart is considered purchase. 
--Therefore,we need to count the toal orders add to cart by each product. 
--Since the dataset has both add cart and purchase id, we want to match them. 
with cte as (
select 
	visit_id
from click_bait.events
where event_type = 3
group by visit_id
)

select 
	page_name as product,
	sum(case when event_type = 2 then 1 end ) as purchase_count
from click_bait.events e
join click_bait.page_hierarchy h
on e.page_id = h.page_id
where h.page_id not in (1,2,12,13)
	and e.visit_id in (select visit_id from cte)
group by 1
order by 2 desc
limit 3

	