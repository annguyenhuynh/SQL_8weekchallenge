--Top 3 products by revenue before discount 
SELECT 
	pd.product_name, 
	sum(pd.price * s.qty)
from balanced_tree.product_details pd
join balanced_tree.sales s 
on s.prod_id = pd.product_id
group by pd.product_name  
order by sum(pd.price * s.qty) DESC 
limit 3;

--Total quantity, revenue, discount for each segment
SELECT 
	pd.segment_id,
	pd.segment_name,
	count(s.qty) as total_quanity,
	round(sum(s.discount::numeric/100 * pd.price * s.qty),2)  as total_discount,
	round((sum(pd.price * s.qty) - sum(s.discount::numeric/100 * pd.price * s.qty)),2) as total_revnue
from balanced_tree.sales s 
join balanced_tree.product_details pd 
on s.prod_id = pd.product_id 
group by 1,2

--Top selling product for each segment
select segment_name, product_name, qty_sold
from (
select 
	pd.segment_name,
	pd.product_name, 
	count(s.qty) as qty_sold,
	row_number() over(PARTITION by pd.segment_name order by count(s.qty) desc) as quantity
from balanced_tree.product_details pd 
join balanced_tree.sales s 
on pd.product_id = s.prod_id
group by 1,2 
) as a 
where a.quantity=1; 

--Total quantity, revenue, and discount for each category
SELECT
	pd.category_name,
	count(s.qty) as total_qty,
	round(sum(s.discount::numeric/100 * pd.price * s.qty),2)  as total_discount,
	round((sum(pd.price * s.qty) - sum(s.discount::numeric/100 * pd.price * s.qty)),2) as total_revnue
	
FROM balanced_tree.product_details pd 
JOIN balanced_tree.sales s 
ON s.prod_id = pd.product_id
GROUP by pd.category_name;

--Top selling product for each category
select * from (
select
	pd.category_name,
	pd.product_name,
	count(s.qty) as quantity_sold
from balanced_tree.product_details pd 
join balanced_tree.sales s 
on pd.product_id = s.prod_id 
group by pd.category_name, pd.product_name 
order by count(s.qty) desc 
) a fetch first 2 rows only;

--Percentage split of revenue by product for each segment
with seg_rev as ( 
select
	pd.segment_name,
	round((sum(pd.price * s.qty) - sum(s.discount::numeric/100 * pd.price * s.qty)),2) as seg_rev
from balanced_tree.product_details pd 
join balanced_tree.sales s 
on pd.product_id = s.prod_id
group by pd.segment_name
),

category_rev as (
select 
	pd.segment_name,
	pd.product_name,
	round((sum(pd.price * s.qty) - sum(s.discount::numeric/100 * pd.price * s.qty)),2) as cate_rev
from balanced_tree.product_details pd 
join balanced_tree.sales s 
on pd.product_id = s.prod_id
group by pd.segment_name, pd.product_name
) 

select 
	sv.segment_name,
	cr.product_name,
	round((100*cr.cate_rev/sv.seg_rev),2) as percentage 
FROM seg_rev sv 
join category_rev as cr 
on sv.segment_name = cr.segment_name
GROUP by sv.segment_name, cr.product_name, cr.cate_rev, sv.seg_rev

--Percentage split of revenue by segment for each category
with cte1 as (
select 
	pd.category_name,
	round((sum(pd.price * s.qty) - sum(s.discount::numeric/100 * pd.price * s.qty)),2) rev_by_cate
from balanced_tree.sales s 
inner join balanced_tree.product_details pd 
on s.prod_id = pd.product_id
group by pd.category_name 
),

cte2 as (
select 
	pd.category_name,
	pd.segment_name,
	round((sum(pd.price * s.qty) - sum(s.discount::numeric/100 * pd.price * s.qty)),2) rev_by_seg
from balanced_tree.sales s 
inner join balanced_tree.product_details pd 
on s.prod_id = pd.product_id
group by pd.category_name, pd.segment_name
)

select 
	cte1.category_name,
	cte2.segment_name,
	round(100*rev_by_seg/rev_by_cate,2) as percentage
from cte1
join cte2
on cte1.category_name = cte2.category_name
GROUP by cte1.category_name, cte2.segment_name, rev_by_seg, rev_by_cate


--Percentage split of total revenue by category
select 
	pd.category_name,
	round(100*sum((s.qty*s.price)*(1-discount * 0.01))/(select sum((qty*price)*(1-discount *0.01)) from balanced_tree.sales),2)
from balanced_tree.product_details pd 
join balanced_tree.sales s 
on s.prod_id = pd.product_id
group by pd.category_name;

--Total transaction penetration for each product
with cte as (
	select 
		pd.product_name,
		pd.product_id,
		cast(count(pd.product_name) as float) as cnt
	from balanced_tree.product_details pd
	join balanced_tree.sales s 
	on pd.product_id = s.prod_id
	group by pd.product_name, pd.product_id
)
select 
 	
	product_name,
 	100*cnt/(select count(distinct txn_id) from balanced_tree.sales)
from cte
group by cnt,product_name,cte.product_id
order by product_id

--What is the most common combination of at least 1 quantity of any 3 products 
--in a 1 single transaction?
with product as (
select 
	s.txn_id,
	pd.product_id,
	pd.product_name
from balanced_tree.product_details pd 
join balanced_tree.sales s 
on pd.product_id = s.prod_id), 

combination as (
select 
	p1.product_name as product_1,
	p2.product_name as product_2,
	p3.product_name as product_3,
	count(*) as tranx_cnt
from product p1 
join product p2
	on p1.txn_id = p2.txn_id
	and p2.product_id != p1.product_id
join product p3
	on p2.txn_id = p3.txn_id
	and p3.product_id != p2.product_id and p3.product_id != p1.product_id
group by 1,2,3
), 

ranking as (
select 
	row_number() over (order by tranx_cnt desc) as rn, * 
from combination)  

select * from ranking where rn=1

--This is a combinatoric question where we need to test all possible combinations from 12 items.
--Then, we need to choose the combination that occurs most frequently.
--The idea is to do self-join so that the items are in same transaction but the product_id is different. 