#Generate date of four weeks before and after 2020-06-15
select 
	week_date - interval 4 week as previous_four_weeks,
    week_date + interval 4 week as four_week_after
from data_mart.new_weekly_sales
where week_date = '2020-06-15';

#Sales 4 weeks before and after 2020-06-15
select 
	sum(sales) as sales_previous_4_weeks,
(select sum(sales) as sales_following_four_weeks from data_mart.new_weekly_sales where week_date between '2020-06-15' and '2020-07-13') as sales_following_4_weeks
from data_mart.new_weekly_sales
where week_date between '2020-05-18' and '2020-06-15';

#Changes in sales stats

with total_sales as (
	select 
	sum(sales) as sales_previous_4_weeks,
(select sum(sales) as sales_following_four_weeks from data_mart.new_weekly_sales where week_date between '2020-06-15' and '2020-07-13') as sales_following_4_weeks
from data_mart.new_weekly_sales
where week_date between '2020-05-18' and '2020-06-15')

select 
	sales_previous_4_weeks,
    sales_following_4_weeks,
    sales_following_4_weeks - sales_previous_4_weeks as reduction,
    ((sales_following_4_weeks - sales_previous_4_weeks)/sales_previous_4_weeks)*100 as percentage_change
    from total_sales;
    
#For 12 weeks before and after
	select 
		week_date - interval 3 month as before_sales,
        week_date + interval 3 month as after_sales
	from data_mart.new_weekly_sales
    where week_date = '2020=06-15';

#Sales in 3 months before and after
select sum(sales) as sales_before,
(select sum(sales) from data_mart.new_weekly_sales where week_date between '2020-06-15' and '2020-09-15') as sales_after
from data_mart.new_weekly_sales
where week_date between '2020-03-15' and '2020-06-15';
#Changes during the 6-month period
with total_sales as 
(select sum(sales) as sales_before,
(select sum(sales) from data_mart.new_weekly_sales where week_date between '2020-06-15' and '2020-09-15') as sales_after
from data_mart.new_weekly_sales
where week_date between '2020-03-15' and '2020-06-15')

select 
	sales_before,
    sales_after,
    sales_after - sales_before as changes,
    ((sales_after - sales_before)/(sales_before)*100) as percentage_change
from total_sales;

#Compare half-year performance between 3 years
select
	dayofyear(date_format('2018-01-1', '%Y-12-31')) as day_in_2018,
    dayofyear(date_format('2019-01-1', '%Y-12-31')) as day_in_2019,
	dayofyear(date_format('2020-01-1', '%Y-12-31')) as day_in_2020;
    
with half_year as
(select 
	sales,
    year(week_date) as years,
	floor(quarter(week_date)/3) as half_year
    from data_mart.new_weekly_sales)

select 
	sum(case when half_year = 0 and years = '2018' then sales end) as first_half_2018,
    sum(case when half_year = 1 and years = '2018' then sales end) as second_half_2018,
	sum(case when half_year = 0 and years = '2019' then sales end) as first_half_2019,
    sum(case when half_year = 1 and years = '2019' then sales end) as second_half_2019,
	sum(case when half_year = 0 and years = '2020' then sales end) as first_half_2020,
    sum(case when half_year = 1 and years = '2020' then sales end) as second_half_2020
from half_year

#Conclusion: The first half-year sales is always higher than the second-half sales throughout 3 years. 
#Also, the sales in 3 first-half increase while sales in the 3 second-half decreases. 






