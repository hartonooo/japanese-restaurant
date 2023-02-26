# japanese-restaurant
analyzing japanese restaurant business performance

using MS. SQL SERVER STUDIO

SQL project/case study from: https://8weeksqlchallenge.com/case-study-1/

steps:
  1. import all csv files into SQL SERVER
  2. data checking
  3. analysis:
	
	
		1. What is the total amount each customer spent at the restaurant?
			<details>
			<summary>total amount each customer spent</summary>
			<pre>		
			select s.customer_id, SUM(m.price) as total_spend
			from sales_dannys s
			join menu_dannys m
			on s.product_id = m.product_id
			group by s.customer_id;		
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/1.%20total%20amount%20each%20customer%20spent.jpg">
			</details>

		
		2. How many days has each customer visited the restaurant?
			<details>
			<summary>amount of each customer visit</summary>
			<pre>		
			select customer_id, COUNT(order_date) as cnt_visit
			from sales_dannys 
			group by customer_id;	
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/2.%20amount%20of%20each%20customer%20visit.jpg">
			</details>

				
		3. What was the first item from the menu purchased by each customer?
			<details>
			<summary>first item purchased of each customer</summary>
			<pre>		
			with satu as (select s.customer_id, 
				s.order_date, 
				m.product_name, 
				DENSE_RANK() over(partition by customer_id order by order_date) as rn
			from sales_dannys s
			join menu_dannys m
			on s.product_id = m.product_id),</br>
			dua as (select distinct customer_id, product_name
			from satu
			where rn = 1)</br>
			select customer_id, STRING_AGG(product_name, ', ') as first_item_purchased
			from dua
			group by customer_id;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/3.%20first%20item%20purchased%20of%20each%20customer.jpg">
			</details>
		
		
		4. What is the most purchased item on the menu and how many times was it purchased by all customers?
			<details>
			<summary>most purchased item and purchasing amount</summary>
			<pre>		
			with satu as (select m.product_name, 
					COUNT(m.product_name) as cnt_prod_name, 
					RANK() over(order by COUNT(product_name) desc) as rn
			from sales_dannys s
			join menu_dannys m
			on s.product_id = m.product_id
			group by m.product_name)</br>
			select product_name, cnt_prod_name
			from satu
			where rn = 1;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/4.%20most%20purchased%20item%20and%20purchasing%20amount.jpg">
			</details>
		
		
		5. Which item was the most popular for each customer?
			<details>
			<summary>most popular item for each customer</summary>
			<pre>		
			with satu as (select s.customer_id, 
				m.product_name, 
				COUNT(m.product_name) as cnt_item, 
				RANK() over(partition by s.customer_id order by COUNT(m.product_name) desc) as rn
			from sales_dannys s
			join menu_dannys m
			on s.product_id = m.product_id
			group by s.customer_id, m.product_name)</br>
			select customer_id, STRING_AGG(product_name, ', ') as cust_fav_item
			from satu
			where rn = 1
			group by customer_id;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/5.%20most%20popular%20item%20for%20each%20customer.jpg">
			</details>
		
		
		6. Which item was purchased first by the customer after they became a member?
			<details>
			<summary>first purchasing after became member</summary>
			<pre>		
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
			where s.order_date >= m.join_date)</br>
			select customer_id, order_date, join_date, product_name
			from satu
			where rn = 1;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/6.%20first%20purchasing%20after%20became%20member.jpg">
			</details>
		
		
		7. Which item was purchased just before the customer became a member?
			<details>
			<summary>item purchased just before the customer became a member</summary>
			<pre>		
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
			where s.order_date < m.join_date),</br>
			dua as (select customer_id, MAX(rn) as rn_just_before
			from satu
			group by customer_id)</br>
			select satu.customer_id, 
				satu.order_date, 
				satu.join_date, 
				satu.product_name
			from satu
			join dua
			on satu.customer_id = dua.customer_id
			where satu.rn = dua.rn_just_before;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/7.%20item%20purchased%20just%20before%20the%20customer%20became%20a%20member.jpg">
			</details>
		
		
		8. What is the total items and amount spent for each member before they became a member?
			<details>
			<summary>total items and amount spent for each member before they became a member</summary>
			<pre>		
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
			where s.order_date < m.join_date)</br>
			select customer_id, COUNT(product_name) as total_item, SUM(price) as total_spent
			from satu
			group by customer_id;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/8.%20total%20items%20and%20amount%20spent%20for%20each%20member%20before%20they%20became%20a%20member.jpg">
			</details>
		
		
		9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
			<details>
			<summary>total items and amount spent for each member before they became a member</summary>
			</br>
			<p>transaction for member only that'll be calculated (only member A & B, and transaction after join membership)</p>
			<pre>		
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
			where s.order_date >= m.join_date)</br>
			select customer_id, SUM(price*point) as total_point
			from satu
			group by customer_id;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/9.%20total%20items%20and%20amount%20spent%20for%20each%20member%20before%20they%20became%20a%20member.jpg">
			</details>
		
		
		10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
			<details>
			<summary>points customer A and B have at the end of January</summary>
			<pre>		
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
			where s.order_date >= m.join_date)</br>
			select customer_id, SUM(price*week_after_point) as total_point_end_of_Jan
			from satu
			where order_date < '2021-01-31'
			group by customer_id;
			</pre>
			<img src="https://github.com/mas-tono/japanese-restaurant/blob/main/image/10.%20points%20customer%20A%20and%20B%20have%20at%20the%20end%20of%20January.jpg">
			</details>

