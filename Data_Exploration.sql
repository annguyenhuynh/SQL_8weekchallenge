#What day of the week is used for each week_date value?
select 
week_date,
dayname(week_date) as day_name
from data_mart.new_weekly_sales;

#What range of week numbers are missing from the dataset?
select 
	week_date,
	case when day(week_date) >= 1 and day(week_date) < 8 then 1
		when day(week_date) >= 8 and day(week_date) < 15 then 2
        when day(week_date) >=15 and day(week_date) < 22 then 3
        when day(week_date) >=22 and day(week_date) < 29 then 4
        else 5 end as week_number
from data_mart.new_weekly_sales;

#How many total transactions each year are there in the data set?
select 
	year(week_date) as years,
	count(transactions) as number_of_transactions
from data_mart.new_weekly_sales
group by year(week_date);

#What is the total sales for each region for each month
select 
	region,
    month(week_date) as months,
    sum(sales) as total_sales
from data_mart.new_weekly_sales
group by region, month(week_date);

#What is the total count of transaction for each platform/
select 
	platform,
    count(transactions) number_of_transactions
from data_mart.new_weekly_sales
group by platform;

#What is the percentage of sales for retail and shopify for each month?
with cte_1 as
(select month_number,sum(sales) as sales_by_month
from data_mart.new_weekly_sales
group by month_number)

select 
	new_weekly_sales.platform,
    new_weekly_sales.month_number,
   (sum(sales)/sales_by_month * 100) as percentage
from data_mart.new_weekly_sales
join cte_1
using(month_number)
group by new_weekly_sales.platform, new_weekly_sales.month_number
order by new_weekly_sales.month_number;

#What is the percentage of sales by demographic for each year in the data set?
with cte_2 as
(select 
	calendar_year,
    sum(sales) as sales_by_year
from data_mart.new_weekly_sales
group by calendar_year
)

select 
	new_weekly_sales.calendar_year,
    new_weekly_sales.demographic,
    (sum(sales)/sales_by_year) * 100 as percentage
from cte_2
join data_mart.new_weekly_sales
using(calendar_year)
group by new_weekly_sales.demographic, new_weekly_sales.calendar_year;

#Which age_band and demographic contribute the most to retail sales?
select 
	demographic,
    age_band,
    sales
from data_mart.new_weekly_sales
where platform = 'Retail'
order by sales desc
limit 10;
# --> There is no information about the age band or demographic of those contribute the most to retail sales

#Can we use the avg_transaction col to find the average transaction size for each year for retail v. shopity? If not, how would you calculate it instead?
select 
	calendar_year,
    platform,
    avg_transactions,
(sum(sales)/sum(transactions)) as avg_transaction_modified
from data_mart.new_weekly_sales
group by calendar_year, platform;





