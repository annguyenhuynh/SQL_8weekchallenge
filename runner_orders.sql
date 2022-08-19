create table pizza_runner.runner_orders (
	order_id integer,
 	runner_id integer,
	pickup_time timestamp,
	distance integer,
	duration integer,
	cancellation varchar);

insert into pizza_runner.runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
values 
	('1', '1', '2021-01-01 18:15:34', '20', '32', ''),
	('2','1', '2021-01-01 19:10:54', '20', '27', ''),
	('3', '1', '2021-01-03 00:12:37', '13.4', '20', 'NaN'),
	('4', '2', '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
	('5', '3', '2021-01-08 21:10:57', '10', '15', 'NaN'),
	('6', '3', null, null, null, 'Restaurant Cancellation'),
	('7', '2', '2020-01-08 21:30:45', '25', '25', ''),
	('8', '2', '2020-01-10 00:15:02', '23.4', '15', ''),
	('9', '2', null, null, null, 'Customer Cancellation'),
	('10', '1', '2020-01-11 18:50:20', '10', '10', '')