SELECT 
	u.user_id,
	e.visit_id,
	min(e.event_time) as visit_start_time,
	sum(case when e.event_type = 1 then 1 else 0 end) as page_views,
	sum(case when e.event_type = 2 then 1 else 0 end) as cart_adds,
	case when e.event_type = 3 then '1' else '0' end as purchase,
	c.campaign_name,
	sum(case when e.event_type = 4 then 1 else 0 end) as ad_impression,
	sum(case when e.event_type = 5 then 1 else 0 end) as clicks 
from click_bait.users u 
left join click_bait.events e on e.cookie_id = u.cookie_id 
left join click_bait.campaign_identifier c on e.event_time between c.start_date and c.end_date 
group by u.user_id, e.visit_id, e.event_type, c.campaign_name