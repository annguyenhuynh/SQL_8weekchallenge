--Unique transactions
select
	count(DISTINCT txn_id) as unique_transaction
from balanced_tree.sales

--Average unique products purchased in each transaction
SELECT 
	DISTINCT txn_id,
	count(prod_id) as products_purchased
from balanced_tree.sales
group by txn_id;

--25th, 50th, and 75th percentile values for the revenue per transaction
with rev as ( 
SELECT 
	DISTINCT s.txn_id,
	round((sum(pp.price * s.qty) - sum(s.discount::numeric/100 * pp.price * s.qty)),2) as total_revenue
FROM 
	balanced_tree.sales s
JOIN balanced_tree.product_prices pp 
on pp.product_id = s.prod_id
group by s.txn_id) 

select
	percentile_cont(0.25) within group (order by total_revenue) as Q1,
	percentile_cont(0.50) within group (order by total_revenue) as Q2,
	percentile_cont(0.75) within group (order by total_revenue) as Q3
from rev

--Average discount value per transaction
SELECT 
	txn_id, 
	round(avg(discount * qty),2) as avg_discount
FROM balanced_tree.sales
GROUP BY txn_id;

--Percentage split of all transactions for members and non-member
SELECT
	round((sum(case when member='true' then 1 end))::numeric/ count(txn_id)*100,2) as member_percentage,
	round((sum(case when member='false' then 1 end))::numeric/ count(txn_id)*100,2) as nonmember_percentage
from balanced_tree.sales

--Revenue for member transaction and non-member transaction
with rev as ( 
SELECT 
	DISTINCT s.txn_id,
	round((sum(pp.price * s.qty) - sum(s.discount::numeric/100 * pp.price * s.qty)),2) as total_revenue
FROM 
	balanced_tree.sales s
JOIN balanced_tree.product_prices pp 
on pp.product_id = s.prod_id
group by s.txn_id) 

SELECT 
	sum(case when s.member = 'true' then total_revenue end) as revenue_by_members,
	sum(case when s.member = 'false' then total_revenue end) as revenue_by_non_members
from rev 
join balanced_tree.sales s
using(txn_id)

