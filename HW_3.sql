--1
select job_industry_category, count(*) cnt
from customer c 
group by job_industry_category
order by cnt desc;

--2
select date_part('month', t.transaction_date) as month, c.job_industry_category, sum(list_price)
from "transaction" t
inner join customer c on 
	c.customer_id = t.customer_id
group by date_part('month', t.transaction_date), c.job_industry_category
order by month, c.job_industry_category;

--3
select t.brand, count(*) cnt
from "transaction" t
inner join customer c on 
	c.customer_id = t.customer_id
where 
	t.online_order = true 
	and c.job_industry_category = 'IT'
group by t.brand;

--4
select t.customer_id
	, sum(list_price)
	, max(list_price)
	, min(list_price)
	, count(transaction_id)  
from "transaction" t
group by t.customer_id
order by sum(list_price) desc, count(transaction_id) desc;

select t.customer_id
	, sum(t.list_price) over(partition by t.customer_id) as sum_price
	, max(t.list_price) over(partition by t.customer_id) as max_price
	, min(t.list_price) over(partition by t.customer_id) as min_price
	, count(t.transaction_id) over(partition by t.customer_id) as cnt
from "transaction" t
order by sum_price desc, cnt desc;

--5.1
with min_transaction_sum as(
	select min(transaction_sum) 
	from (select sum(t.list_price) as transaction_sum 
	from "transaction" t
	group by t.customer_id)
)
select c.first_name, c.last_name, sum(t.list_price) as s
from "transaction" t
inner join customer c on c.customer_id = t.customer_id
group by c.first_name, c.last_name
having sum(t.list_price) = (select * from min_transaction_sum);

--5.2
with max_transaction_sum as(
	select max(transaction_sum) 
	from (select sum(t.list_price) as transaction_sum 
	from "transaction" t
	group by t.customer_id)
)
select c.first_name, c.last_name, sum(t.list_price) as s
from "transaction" t
inner join customer c on c.customer_id = t.customer_id
group by c.first_name, c.last_name
having sum(t.list_price) = (select * from max_transaction_sum);


--6
select t.customer_id
	,FIRST_VALUE(t.transaction_id) over(partition by customer_id)
from "transaction" t;



--7
--WITH TransactionGaps AS (
--    SELECT 
--        customer_id,
--        transaction_date,
--        LAG(transaction_date::date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS previous_transaction_date,
--        DATEDIFF(transaction_date::date, LAG(transaction_date::date) OVER (PARTITION BY customer_id ORDER BY transaction_date)) AS gap_days
--    FROM 
--        transaction
--),
--MaxGap AS (
--    SELECT 
--        customer_id,
--        MAX(gap_days) AS max_gap_days
--    FROM 
--        TransactionGaps
--    GROUP BY 
--        customer_id
--)
--SELECT 
--    c.first_name,
--    c.last_name,
--    c.job_title
--FROM 
--    customer c
--JOIN 
--    MaxGap mg ON c.customer_id = mg.customer_id
--JOIN 
--    TransactionGaps tg ON c.customer_id = tg.customer_id
--WHERE 
--    tg.gap_days = mg.max_gap_days;



 