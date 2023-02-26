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
		3. What was the first item from the menu purchased by each customer?
		4. What is the most purchased item on the menu and how many times was it purchased by all customers?
		5. Which item was the most popular for each customer?
		6. Which item was purchased first by the customer after they became a member?
		7. Which item was purchased just before the customer became a member?
		8. What is the total items and amount spent for each member before they became a member?
		9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
		10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
		

