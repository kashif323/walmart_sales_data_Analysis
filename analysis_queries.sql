--Bussiness Problems
--1.Find different payment method and number of transactions, number of qty sold
select 
    payment_method,
	count(*) as total_transaction,
	sum(quantity) as quantity_sold
from walmart
group by payment_method


--2. Identify the highest-rated category in each branch, displaying the branch,category avg rating
select * from(
select branch,category,
	avg(rating) as average_rated,
	 RANK() OVER (
            PARTITION BY branch
            ORDER BY AVG(rating) DESC
        ) AS rnk
	from walmart
	group by branch,category
	order by branch,category DESC)

where rnk =1;






--3. Identify the busiest day for each branch based on the number of transactions


SELECT * FROM
	(select
		branch,
		to_char(TO_DATE(date,'DD/MM/YY'),'day') as day_name,
		count(*) as no_transaction,
		RANK() OVER(PARTITION BY branch order by count(*) DESC) as rank
	from walmart
	group by branch,day_name
	order by branch,no_transaction DESC)

 where rank=1








--4 determine the average ,minimum,and maximum rating of products for each city .
--List the city , average_rating,min_rating,and max_rating.
	
	
select * from walmart

select city,category,
	max(rating) as max_rating,
	min(rating) as min_rating,
	avg(rating) as avg_rating
from walmart
group  by city,category








--5.calculate the total profit for each categpry by considering total_profit as(unit_price*quantity*profit_margin)
-- list category and total_profit, ordered from highest to lowest profit


select category,
	sum(unit_price*quantity*profit_margin) as total_profit
from walmart
group by category
order by total_profit DESC









--6. 
    -- Categorize sales into 3 groups MORNING , AFTERNOON, EVENING
	--Find out which of the shift and number invoices


select 
	case 
		when extract (hour from(time::time)) <12 then 'Morning'
		when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	END day_time,
	count(*)
	from walmart
	group by 
		case 
		when extract (hour from(time::time)) <12 then 'Morning'
		when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	END 
	








    

--7. identify 5 branch with highest ratio in revenue comapre to last year (current year 2023 and last year 2022)


--rdr==last_rev-cr_rev/last_rev*100



select *,
extract(year from to_date(date,'dd/mm/yy')) as formated_date
from walmart

--2022 sales
with revenue_2022
as
(select 
	branch,
	sum(total) as revenue
	from walmart
	where extract(year from to_date(date,'dd/mm/yy')) =2022
	
group by branch),

revenue_2023
as
(select 
	branch,
	sum(total) as revenue
	from walmart
	where extract(year from to_date(date,'dd/mm/yy')) =2023
	
group by branch)

select 
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as cr_year_revenue,
round
	((ls.revenue-cs.revenue)::numeric/ls.revenue::numeric*100,2) as revenue_decrese_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue >cs.revenue
order by revenue_decrese_ratio desc
limit  5
