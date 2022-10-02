--What is the unique count and total amount for each transaction type?
select 
	distinct(txn_type) as transaction_type,
	sum(txn_amount) as total_amount
from data_bank.customer_transactions
group by txn_type;

--What is the average total historical deposit counts and amounts for all customers?
select 
	count(distinct customer_id) as deposits,
	round(avg(txn_amount),2) as average_deposit_amount
from data_bank.customer_transactions
where txn_type = 'deposit';

--For each month - how many Data Bank customers make more than 1 deposit 
--and either 1 purchase or 1 withdrawal in a single month?
with cte as (select 
	customer_id,
	to_char (txn_date, 'MM') as months,
	sum(case when txn_type = 'deposit' then 1 else 0 end ) as deposit_count,
	sum(case when txn_type = 'purchase' then 1 else 0 end) as purchase_count,
	sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal_count
from data_bank.customer_transactions
group by customer_id, months
order by customer_id)

select 
	months,
	count(distinct customer_id) as total_customers
from cte 
where 
deposit_count>= 2 and (purchase_count >= 1 or withdrawal_count >= 1)
group by months;
		
--What is the closing balance for each customer at the end of the month?
with net_change as (
select 
	customer_id,
	extract ('month' from txn_date) as months,
	sum (case when txn_type = 'deposit' then txn_amount
			else -txn_amount
		 	end) as net_change
from data_bank.customer_transactions
group by customer_id, months
order by customer_id
)

select 
	customer_id,
	months,
	net_change,
	sum(net_change) over (partition by customer_id
						 order by months rows between unbounded preceding and current row) as closing_balance
from net_change
group by customer_id, months, net_change;

-- What is the percentage of customers who increase their closing balance by more than 5%?
-- [still working on]

