-- Customer journey
select 
	s.customer_id,
	p.plan_name,
	s.start_date
from foodie_fi.subscriptions s 
join foodie_fi.plans p 
on s.plan_id = p.plan_id

--Summary of customer journey:
--All customers are given one week trial without any cost. 
--After that, they may decide whether or not to subscribe to a plan 
--Out of 8 customers, customer with id #11 didnot subscribe to any plan after one-week trial
--Customer #15 subscribed to pro monthly but canceled after first month. 
--The other customers subscribe to either a monthly plan or an annual plan. Customer #16 and #19 upgraded
--from monthly plans to annual plans after 4 months and 2 months, respectively. 