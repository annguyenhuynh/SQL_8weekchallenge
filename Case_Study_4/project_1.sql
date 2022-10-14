--How many unique nodes are there on the Data Bank system?
select count(distinct node_id) as num_nodes
from data_bank.customer_nodes;

--What is the number of nodes per region?
select 
	r.region_name,
	count(n.node_id) as num_nodes
from data_bank.regions r
join data_bank.customer_nodes n
on r.region_id = n.region_id
group by r.region_name;

--How many customers are allocated to each region?
select 
	r.region_name,
	count(distinct n.customer_id) as num_customers
from data_bank.regions r
join data_bank.customer_nodes n
on r.region_id = n.region_id
group by r.region_name;

--How many days on average are customers reallocated to a different node?
with cte as (select 
	customer_id,
	start_date, 
	end_date,
	end_date-start_date as date_diff,
	node_id,
	lag(node_id,1) over (partition by customer_id) as reallocation
from data_bank.customer_nodes
where end_date !='9999-12-31')

select 
	round(avg(date_diff),2)
from cte;
--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
with cte as (select 
	r.region_name as regions,
	n.end_date-n.start_date as date_diff,
	n.node_id,
	lag(n.node_id,1) over (partition by n.customer_id) as reallocation
from data_bank.customer_nodes n
join data_bank.regions r
on n.region_id = r.region_id
where end_date !='9999-12-31'
group by r.region_name, n.start_date, n.end_date, n.node_id, n.customer_id)

select 
	regions,
	percentile_cont(0.5) within group(order by date_diff) as median,
	percentile_disc(0.80) within group(order by date_diff) as eighty_percentile,
	percentile_disc(0.95) within group (order by date_diff) as ninety_five_percentile
from cte
group by regions
order by regions;
