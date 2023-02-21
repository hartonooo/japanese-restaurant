--1. What is the total amount each customer spent at the restaurant?

select s.customer_id, SUM(m.price) as total_spend
from sales_dannys s
join menu_dannys m
on s.product_id = m.product_id
group by s.customer_id;


--2. How many days has each customer visited the restaurant?

select customer_id, COUNT(order_date) as cnt_visit
from sales_dannys 
group by customer_id;


--3. What was the first item from the menu purchased by each customer?

with satu as (select s.customer_id, 
		s.order_date, 
		m.product_name, 
		DENSE_RANK() over(partition by customer_id order by order_date) as rn
from sales_dannys s
join menu_dannys m
on s.product_id = m.product_id), 

dua as (select distinct customer_id, product_name
from satu
where rn = 1)

select customer_id, STRING_AGG(product_name, ', ') as first_item_purchased
from dua
group by customer_id;


--4.What is the most purchased item on the menu and how many times was it purchased by all customers?

with satu as (select m.product_name, 
		COUNT(m.product_name) as cnt_prod_name, 
		RANK() over(order by COUNT(product_name) desc) as rn
from sales_dannys s
join menu_dannys m
on s.product_id = m.product_id
group by m.product_name)

select product_name, cnt_prod_name
from satu
where rn = 1;


--5. Which item was the most popular for each customer?

with satu as (select s.customer_id, 
m.product_name, 
COUNT(m.product_name) as cnt_item, 
RANK() over(partition by s.customer_id order by COUNT(m.product_name) desc) as rn
from sales_dannys s
join menu_dannys m
on s.product_id = m.product_id
group by s.customer_id, m.product_name)

select customer_id, STRING_AGG(product_name, ', ') as cust_fav_item
from satu
where rn = 1
group by customer_id;


--6. Which item was purchased first by the customer after they became a member?

with satu as (select s.customer_id,
		s.order_date,
		m.join_date,
		me.product_name,
		RANK() over(partition by s.customer_id order by s.order_date) as rn
from sales_dannys s
join members_dannys m
on s.customer_id = m.customer_id
join menu_dannys me
on s.product_id = me.product_id
where s.order_date >= m.join_date)

select customer_id, order_date, join_date, product_name
from satu
where rn = 1;


--7. Which item was purchased just before the customer became a member?

with satu as (select s.customer_id,
		s.order_date,
		m.join_date,
		me.product_name,
		dense_rank() over(partition by s.customer_id order by s.order_date) as rn
from sales_dannys s
join members_dannys m
on s.customer_id = m.customer_id
join menu_dannys me
on s.product_id = me.product_id
where s.order_date < m.join_date),

dua as (select customer_id, MAX(rn) as rn_just_before
from satu
group by customer_id)

select satu.customer_id, 
		satu.order_date, 
		satu.join_date, 
		satu.product_name
from satu
join dua
on satu.customer_id = dua.customer_id
where satu.rn = dua.rn_just_before;


--8. What is the total items and amount spent for each member before they became a member?

with satu as (select s.customer_id,
		s.order_date,
		m.join_date,
		me.product_name,
		me.price
from sales_dannys s
join members_dannys m
on s.customer_id = m.customer_id
join menu_dannys me
on s.product_id = me.product_id
where s.order_date < m.join_date)

select customer_id, COUNT(product_name) as total_item, SUM(price) as total_spent
from satu
group by customer_id;


--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- first scenario: all trx will be calculated, regardless of member or not

with satu as (select s.customer_id, m.product_name, m.price, 
case
	when m.product_name = 'sushi' then 20 else 10
end as point
from sales_dannys s
join menu_dannys m
on s.product_id = m.product_id)

select customer_id, SUM(price*point) as total_point
from satu
group by customer_id;


-- second scenario: trx for member only that'll be calculated (only member A & B, and trx after join membership)

with satu as (select s.customer_id,
		s.order_date,
		m.join_date,
		me.product_name,
		me.price,
		case
			when me.product_name = 'sushi' then 20 else 10
		end as point
from sales_dannys s
join members_dannys m
on s.customer_id = m.customer_id
join menu_dannys me
on s.product_id = me.product_id
where s.order_date >= m.join_date)

select customer_id, SUM(price*point) as total_point
from satu
group by customer_id;



--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?

--continue second scenario

with satu as (select s.customer_id,
		s.order_date,
		m.join_date,
		me.product_name,
		me.price,
		case
			when me.product_name = 'sushi' then 20 else 10
		end as point,
		DATEADD(day, 7, m.join_date) as week_after,
		case
			when s.order_date >= m.join_date and s.order_date < DATEADD(day, 7, m.join_date) then 20 else 10
		end as week_after_point
from sales_dannys s
join members_dannys m
on s.customer_id = m.customer_id
join menu_dannys me
on s.product_id = me.product_id
where s.order_date >= m.join_date)

select customer_id, SUM(price*week_after_point) as total_point_end_of_Jan
from satu
where order_date < '2021-01-31'
group by customer_id;




--Bonus Questions

--1. Join All The Things

select s.customer_id, 
		s.order_date, 
		me.product_name, 
		me.price, 
		case
			when ((s.order_date < m.join_date) or (m.customer_id is null)) then 'N' else 'Y'
		end as member
from sales_dannys s
join menu_dannys me
on s.product_id = me.product_id
left join members_dannys m
on s.customer_id = m.customer_id
order by s.customer_id, s.order_date, me.product_name, me.price desc;



--2. Rank All The Things

with satu as (select s.customer_id, 
		s.order_date, 
		me.product_name, 
		me.price, 
		case
			when ((s.order_date < m.join_date) or (m.customer_id is null)) then 'N' else 'Y'
		end as member
from sales_dannys s
join menu_dannys me
on s.product_id = me.product_id
left join members_dannys m
on s.customer_id = m.customer_id)

select *, 
case
	when member = 'N' then null else RANK() over(partition by customer_id, member order by order_date)
end as ranking
from satu
order by customer_id, order_date, product_name, price desc;




