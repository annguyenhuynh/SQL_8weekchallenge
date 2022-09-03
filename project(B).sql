--How many customers has Foodie-Fi ever had? 
SELECT 
	count(DISTINCT customer_id) as num_customers
from foodie_fi.subscriptions;

--What is the monthly distribution of trial plan start_date values for our dataset 
-- use the start of the month as the group by value
select 
	count(*) as count_trials,
	date_part('month', s.start_date) as month_number,
	to_char(s.start_date, 'Month') as month_name
from foodie_fi.plans p 
join foodie_fi.subscriptions s 
on s.plan_id = p.plan_id 
where s.plan_id = 0
group by date_part('month', s.start_date), to_char(s.start_date, 'Month')
order by month_number;

--What plan start_date values occur after the year 2020 for our dataset? 
--Show the breakdown by count of events for each plan_name
select 
	p.plan_name,
	count(p.plan_id) as num_of_plans
from foodie_fi.subscriptions s
join foodie_fi.plans p
on s.plan_id = p.plan_id
where date_part('year', s.start_date)!='2020'
group by p.plan_name;



--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select 
	count(*) as total_churned,
	round((100*count(*))::numeric/(select count(distinct customer_id) from foodie_fi.subscriptions s),1) as percent_churned
from foodie_fi.subscriptions s
join foodie_fi.plans p
on s.plan_id = p.plan_id
where s.plan_id =4; 

--How many customers have churned straight after their initial free trial
--What percentage is this rounded to the nearest whole number?
with cte_1 as
(select
	customer_id, plan_id,
	extract('week' from start_date) as week
	from foodie_fi.subscriptions
),
cte_2 as (
	select 
		customer_id,
	count(week) as number_of_weeks
	from cte_1
	group by customer_id
	order by customer_id asc
)

select 
	sum(case when number_of_weeks = 2 and s.plan_id = 4 then 1
	else 0
	end) as churned_after_1_week,
	round((100*sum(case when number_of_weeks = 2 and s.plan_id = 4 then 1
	else 0
	end))::numeric/count(distinct s.customer_id),1) as percent_churned

from cte_2
join foodie_fi.subscriptions s
on cte_2.customer_id = s.customer_id;

--What is the number and percentage of customer plans after their initial free trial?
select 
	p.plan_name,
	count(p.plan_id) as total,
	round((100*count(p.plan_id))::numeric/(select count(distinct customer_id)from foodie_fi.subscriptions),1) as percent_total
from foodie_fi.subscriptions s
join foodie_fi.plans p
on s.plan_id = p.plan_id
where p.plan_id !=0
group by p.plan_name;

--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
--start_date needs be in 2020-12-31 but not the next upgrade date
with cte as
(select 
	customer_id,
	plan_id,
	start_date,
	lead(start_date,1) over (partition by customer_id order by start_date) as next_plan
from foodie_fi.subscriptions
where start_date <= '2020-12-31'),

customer_count as (
select 
	plan_id,
	count (distinct customer_id) as customers
from cte
where (next_plan IS NOT NULL AND (start_date < '2020-12-31' 
      AND next_plan > '2020-12-31'))
    OR (next_plan IS NULL AND start_date < '2020-12-31')
group by plan_id
	)

select customer_count.plan_id, customers, round((100*customers)::numeric/(select count(distinct customer_id) from foodie_fi.subscriptions),1) as percentage
from customer_count
join foodie_fi.subscriptions s
on customer_count.plan_id = s.plan_id
group by customers, customer_count.plan_id
order by customer_count.plan_id;

--How many customers have upgraded to an annual plan in 2020?
select 
	count(distinct s.customer_id) as num_cust
from foodie_fi.subscriptions s
join foodie_fi.plans p
on s.plan_id = p.plan_id
where p.plan_id = 3 and s.start_date < '2020-12-31';

--Find average days customers upgrade to annual plan from the dates they join Fodie Fi
with count_days as (
select 
	s1.customer_id,
	s2.start_date - s1.start_date as date_diff
from foodie_fi.subscriptions s1
join foodie_fi.subscriptions s2
on s1.customer_id = s2.customer_id
where s2.start_date > s1.start_date
and s1.plan_id = 0 and s2.plan_id =3
order by s1.customer_id)

select avg(extract ('days' from date_diff)) as days
from count_days;

--Further break down the average into 30-day periods
--On average, how many customers upgrade within 30 days?
--still working on this. 
with trial_count as (
	select 
		customer_id,
		to_char(start_date, 'MM')::integer as trials
	from foodie_fi.subscriptions
	where plan_id = 0),

annual_count as (
	select
		customer_id,
		to_char(start_date, 'MM')::integer as annuals
	from foodie_fi.subscriptions
	where plan_id = 3
)

--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with cte as (
	select 
	customer_id,
	plan_id,
	start_date,
	lead(plan_id, 1) over (partition by customer_id order by plan_id) as next_plan
	from foodie_fi.subscriptions
	)
select count(*)
from cte
where start_date <= '2020-12-31' and plan_id = 2 and next_plan =1