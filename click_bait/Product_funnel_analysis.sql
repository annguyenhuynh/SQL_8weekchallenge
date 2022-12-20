--Product Analysis
with joined_table as (
select 
	visit_id,
	page_name, 
	event_name
from click_bait.events e
join click_bait.page_hierarchy ph on ph.page_id = e.page_id 
join click_bait.event_identifier ei on ei.event_type = e.event_type 
group by 1,2,3)

SELECT 
	jt.page_name,
	count(event_name) as views,  
	add_to_cart,
	abandoned,
	purchase
into click_bait.product_analysis 
from joined_table jt 
JOIN 
	(SELECT 
		page_name,
		count(event_name) as add_to_cart
	FROM joined_table
	where event_name = 'Add to Cart'
	group by 1) jt1 on jt.page_name = jt1.page_name
JOIN (
	SELECT 
		page_name,
		count(event_name) as abandoned
	FROM joined_table
	where event_name = 'Add to Cart'
		and visit_id NOT IN (
								SELECT distinct visit_id
								FROM click_bait.events e
								where event_type = 3)
	GROUP by 1) jt2 on jt.page_name = jt2.page_name
JOIN 
	(SELECT	
		page_name,
		count(event_name) as purchase
	from joined_table
	where event_name = 'Add to Cart'
	and visit_id in (select distinct visit_id
					from click_bait.events e
					where event_type = 3)
	GROUP BY 1) jt3 on jt.page_name = jt3.page_name
WHERE event_name = 'Page View'

GROUP BY 
	jt.page_name, 
	add_to_cart,
	abandoned,
	purchase
ORDER BY 1;

SELECT * FROM click_bait.product_analysis


--Product Category Analysis
SELECT 
	pc.product_category,
	sum(views) as total_views,
	sum(add_to_cart) as total_add_cart,
	sum(abandoned) as total_abandoned,
	sum(purchase) as total_purchased
from click_bait.page_hierarchy pc
join click_bait.product_analysis ps
on pc.page_name = ps.page_name
group by 1
order by 1;
	
--Product with most views, cart adds, and purchase
with top_view as
(select 
	page_name,
 	views,
	row_number() OVER(order by views desc) as top_view
from click_bait.product_analysis
),

top_add_cart as 
(select 
	page_name,
 	add_to_cart,
	row_number() over(order by add_to_cart desc) as top_cart_add
 from click_bait.product_analysis
),

top_purchase as (
select 
	page_name,
	purchase,
	row_number() OVER(order by purchase DESC) as top_purchased
from click_bait.product_analysis
)

select 
	top_view.page_name,
	views,
	add_to_cart,
	purchase
from top_view
join top_add_cart on top_view.page_name = top_add_cart.page_name
join top_purchase on top_add_cart.page_name = top_purchase.page_name
WHERE top_view=1 or top_cart_add=1 or top_purchased=1
group by 1,2,3,4;

--Product most likely to be abandoned
select 
	page_name,
	max(abandoned) as top_abandoned
from click_bait.product_analysis
group by page_name
order by max(abandoned) DESC
limit 1;

--Product with highest view to purchase percentage
select
	page_name,
	concat(ROUND(
		100* purchase/views::numeric, 2),'%') as view_to_purchase
from click_bait.product_analysis
order by (ROUND(
		100* purchase/views::numeric, 2)) DESC 
LIMIT 1

-- What is the average conversion rate from view to add cart?
select 
	concat(round(avg(100* add_to_cart/views),2), '%')  as avg_view_to_addcart
from click_bait.product_analysis;

-- What is the average conversion rate from add cart to purchase
select 
	concat(round(avg(100* purchase/add_to_cart),2), '%') as avg_addcart_to_purchase
from click_bait.product_analysis;
