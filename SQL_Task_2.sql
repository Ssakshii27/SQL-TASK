create table customers(customer_id serial primary key,	customer_name varchar,	city varchar,	phone_number bigint,	email varchar,	registration_date date);
copy customers from 'D:\ARC\SQL\SQL Task-2\Table.1--customers.csv' delimiter ',' csv header;
select * from customers;

create table orders(order_id int primary key,	customer_id serial references customers(customer_id),	order_date	date, order_amount int,	delivery_city varchar,	payment_mode varchar);
copy orders from 'D:\ARC\SQL\SQL Task-2\Table.2--orders.csv' delimiter ',' csv header;
select * from orders;

create table products(product_id int primary key,product_name varchar, category varchar,price	int, stock_quantity	int,supplier_name varchar,supplier_city varchar,supply_date date);
copy products from 'D:\ARC\SQL\SQL Task-2\Table.3--products.csv' delimiter ',' csv header;
select * from products;

create table order_items(order_item_id int primary key,order_id int references orders(order_id),product_id int references products(product_id),quantity int, total_price int);
copy order_items from 'D:\ARC\SQL\SQL Task-2\Table.4--order_items.csv' delimiter ',' csv header;
select * from order_items;

--JOINS
select c.customer_name,c.city,o.order_date from customers c join orders o on c.customer_id=o.customer_id where o.order_date>='2023-01-01' and o.order_date<='2023-12-31' ;

select p.product_name,p.category,ot.total_price,c.city from products p join order_items ot on p.product_id=ot.product_id
join orders o on o.order_id=ot.order_id join customers c on c.customer_id=o.customer_id where c.city='Mumbai';

select c.customer_name,o.order_date,ot.total_price,o.payment_mode from customers c join orders o on c.customer_id=o.customer_id
join order_items ot on ot.order_id=o.order_id where o.payment_mode='Credit Card';

select p.product_name,p.category,ot.total_price,o.order_date from products p join order_items ot on p.product_id=ot.product_id 
join orders o on o.order_id=ot.order_id where o.order_date>='2023-01-01' and o.order_date<='2023-06-30' ;

select c.customer_name,sum(ot.quantity) as total_products_ordered from customers c join orders o on c.customer_id=o.customer_id
join order_items ot on ot.order_id=o.order_id group by c.customer_name;

--DISTINCT
select distinct city from customers;

select distinct supplier_name from products;

select distinct payment_mode from orders;

select distinct category from products;

select distinct supplier_city from products;

--ORDER BY
select customer_name from customers order by customer_name;

select order_id from order_items order by total_price desc;

select product_id,product_name from products order by category desc,price asc;

select order_id,customer_id,order_date from orders order by order_date desc;

select c.city,count(o.order_id) as total_order_placed from customers c join orders o on c.customer_id=o.customer_id group by c.city order by c.city;

--LIMIT AND OFFSET
select * from customers order by customer_name limit 10;

select * from products order by price desc limit 5;

select * from orders order by customer_id limit 10 offset 10;

select order_id,order_date,customer_id from orders where order_date between '2023-01-01' and '2023-12-31' limit 5;

select distinct city from customers limit 10 offset 10;

--AGGREGATE FUNCTIONS
select count(order_id) from orders;

select sum(order_amount) as total_revenue from orders where payment_mode='UPI';

select avg(price) from products;

select max(order_amount),min(order_amount) from orders where order_date between '2023-01-01' and '2023-12-31';

select sum(quantity) from order_items group by product_id;

--SET OPERATIONS
select customer_id from customers intersect select customer_id from orders where order_date between '2022-01-01' and '2023-12-31';

select order_id from order_items except select order_id from orders where order_date between '2022-01-01' and '2022-12-31';

select city from customers except select supplier_city from products;

select city from customers union select supplier_city from products;

select product_name from products intersect
select p.product_name from products p join order_items ot on p.product_id = ot.product_id  
join orders o on ot.order_id = o.order_id where o.order_date between '2023-01-01' and '2023-12-31';

--SUBQUERIES

--Find the names of customers who placed orders with a total price greater than the average total price of all orders
select customer_name from customers where customer_id in (select o.customer_id from orders o join order_items ot on o.order_id=ot.order_id 
group by o.order_id having sum(ot.total_price)>(select avg(ot.total_price) from order_items ot));


--Get a list of products that have been ordered more than once by any customer
select p.product_id,p.product_name from products p join order_items ot on p.product_id=ot.product_id
join orders o on o.order_id=ot.order_id group by p.product_id,p.product_name having count(p.product_id)>1 order by p.product_id;
--OR
select product_id,product_name from products where product_id in (select product_id from order_items ot group by product_id having count(distinct order_id)>1);


--Retrieve the product names that were ordered by customers from Pune using a subquery.
select product_name from products p join order_items ot on p.product_id=ot.product_id
join orders o on o.order_id=ot.order_id 
join customers c on c.customer_id=o.customer_id 
where c.customer_id=(select customer_id from customers where city='Pune');
--OR
select product_name from products where product_id in (
select product_id from order_items where order_id in (
select order_id from orders where customer_id in(
select customer_id from customers where city='Pune')));


--Find the top 3 most expensive orders using a subquery.
select order_id,sum(total_price) from order_items where total_price in (select max(total_price) from order_items
group by total_price order by max(total_price) desc limit 3) group by order_id order by sum(total_price) desc;

--OR
select * from orders where order_id in (select order_id from orders order by order_amount desc limit 3);


--Get the customer names who placed orders for a product that costs more than ₹30,000 using a subquery
select customer_name from customers c join orders o on o.customer_id=c.customer_id
join order_items ot on ot.order_id=o.order_id
join products p on p.product_id=ot.product_id where ot.product_id in (select product_id from products where price>30000);

--OR
select customer_name from customers where customer_id in (
select customer_id from orders where order_id in (
select order_id from order_items where product_id in (
select product_id from products where price >= 30000 )));












