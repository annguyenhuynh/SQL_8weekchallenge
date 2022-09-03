drop table if exists foodie_fi.plans;
create table foodie_fi.plans (
	plan_id integer primary KEY,
	plan_name VARCHAR,
	price NUMERIC);
	
insert into foodie_fi.plans (plan_id,plan_name,price)
values 
	('0', 'trial', '0'),
	('1', 'basic monthly', '9.90'),
	('2', 'pro monthly', '19.90'),
	('3', 'pro annual', '199'),
	('4', 'churn', null)