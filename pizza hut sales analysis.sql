create database Pizzahut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE orders_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);


-- ------------Basic:----------------
-- QUERY_1: Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;


-- Query_2: Calculate the total revenue generated from pizza sales.? 

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.Price),
            2) AS Total_Sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.Pizza_Id = orders_details.Pizza_Id;


-- Query_3: Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.Pizza_type_id
ORDER BY pizzas.Price DESC
LIMIT 1;

-- Query_4: Identify the most common pizza size ordered.


SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.Pizza_Id = orders_details.pizza_id
GROUP BY pizzas.Size
ORDER BY order_count DESC;

-- Query_5: List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.Pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.Pizza_Id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- .---------------Intermediate:------------->
-- Query_1: Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.Pizza_Id
GROUP BY pizza_types.category
ORDER BY quantity DESC
LIMIT 5;

-- Query_2: Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Query_3: Join relevant tables to 
-- find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Query_4: Group the orders by date and calculate 
-- the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    -- Query_5: Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.Pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.Pizza_Id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- <----------------Advanced--------------------->
-- Query_1: Calculate the percentage contribution 
-- of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.Price),
                                2) AS Total_Sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100, 2) AS revenue
FROM  pizza_types JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.Pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.Pizza_Id
GROUP BY pizza_types.category ORDER BY revenue DESC;



-- Query_2: Analyze the cumulative revenue generated over time.

select order_date, 
sum(revenue) over ( order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(orders_details.quantity* pizzas.price) as revenue
from orders_details join pizzas 
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;



-- Query_3:Determine the top 3 most ordered pizza
--  types based on revenue for each pizza category.
select name, revenue from
(select category,name, revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category, pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_Id
group by pizza_types.category, pizza_types.name) as a) as b where rn<= 3;  









