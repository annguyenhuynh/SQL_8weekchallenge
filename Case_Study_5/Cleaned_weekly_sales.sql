create table new_weekly_sales as
(select 
	str_to_date(week_date, '%d/%m/%y') as week_date,
    week(str_to_date(week_date, '%d/%m/%y')) as week_number,
    month(str_to_date(week_date, '%d/%m/%y')) as month_number,
    year(str_to_date(week_date, '%d/%m/%y')) as calendar_year,
    region,
    platform,
    segment,
    case when right(segment,1) = '1' then "Young Adults"
		when right(segment, 1) = '2' then "Middle Aged"
        when right(segment,1) = '3' or right(segment, 1) = '4' then "Retirees"
        else "unkwon" end as age_band,
	case when left(segment,1) = 'C' then "Couples"
		when left(segment, 1) = 'F' then "Families"
        else "unkown" end as demographic,
	customer_type,
    transactions,
    sales,
    round(cast(sales as float)/cast(transactions as float),2) as avg_transactions
    
from data_mart.weekly_sales)
