-- High Level Sales Analysis
with cte as (
select 
	EXTRACT(MONTH from s.start_txn_time) as month,
	count(s.qty) as total_sales,
	sum(pp.price * s.qty) as total_revenue,
	round(sum(s.discount::numeric/100 * pp.price * s.qty),2) as total_discount
from balanced_tree.sales s 
join balanced_tree.product_prices pp on pp.product_id = s.prod_id
group by EXTRACT(MONTH from s.start_txn_time)
) 

SELECT 
	month, 
	total_sales,
	total_revenue,
	total_discount
INTO balanced_tree.sales_analysis
from cte
group by 1,2,3,4
order by 1 asc;

