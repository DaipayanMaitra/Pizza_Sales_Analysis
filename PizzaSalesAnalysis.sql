CREATE DATABASE pizzasales;
USE pizzasales;

SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM pizzas;

/*Changing datatype of order date to DATE type*/
ALTER TABLE orders
MODIFY COLUMN date DATE;

-- Q1: The total number of orders placed
SELECT COUNT(DISTINCT order_id) AS Total_orders_placed
FROM order_details;

-- Q2: The total revenue generated from pizza sales
SELECT ROUND(SUM(p.price * o.quantity),0) AS Total_revenue
FROM order_details o 
JOIN pizzas p ON o.pizza_id = p.pizza_id;

-- Q3: The highest priced pizza
SELECT pt.name, pt.category, p.price
FROM pizza_type pt 
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Q4: The most common pizza size ordered
SELECT p.size, COUNT(*) AS total_pizza_ordered
FROM order_details o 
JOIN pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_pizza_ordered DESC;

-- Q5: The top 5 most ordered pizza types along with their quantities
SELECT pt.name, SUM(quantity) AS total_quantity, COUNT(*) AS total_orders
FROM pizza_type pt 
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id  
JOIN order_details o ON p.pizza_id = o.pizza_id
GROUP BY pt.name
ORDER BY total_orders DESC
LIMIT 5;

-- Q6: The quantity of each pizza category ordered
SELECT pt.category, SUM(quantity) AS total_quantity
FROM pizza_type pt 
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id  
JOIN order_details o ON p.pizza_id = o.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Q7: The distribution of orders by hours of the day
SELECT LEFT(o.time, 2) AS hour_of_day, COUNT(*) AS total_orders
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
GROUP BY LEFT(o.time, 2);

-- Q8: The category-wise distribution of pizzas
SELECT pt.category, COUNT(*) AS pizza_count
FROM pizzas p
JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY pizza_count DESC;

-- Q9: The average number of pizzas ordered per day
WITH day_names AS (
    SELECT 1 AS day_num, 'Sunday' AS day_name
    UNION SELECT 2, 'Monday'
    UNION SELECT 3, 'Tuesday'
    UNION SELECT 4, 'Wednesday'
    UNION SELECT 5, 'Thursday'
    UNION SELECT 6, 'Friday'
    UNION SELECT 7, 'Saturday'
)
SELECT 
    dn.day_num,
    dn.day_name,
    AVG(daily_orders.orders_per_day) AS avg_orders_per_day
FROM (
    SELECT 
        DAYOFWEEK(date) AS day_of_week,
        COUNT(*) AS orders_per_day
    FROM orders
    GROUP BY date
) daily_orders
JOIN day_names dn ON daily_orders.day_of_week = dn.day_num
GROUP BY dn.day_num, dn.day_name
ORDER BY dn.day_num;

-- Q10: Top 3 most ordered pizza types based on revenue
SELECT pt.name, SUM(p.price * o.quantity) AS Total_revenue
FROM order_details o 
JOIN pizzas p ON o.pizza_id = p.pizza_id 
JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY Total_revenue DESC
LIMIT 3;

-- Q11: The percentage contribution of each pizza type to revenue
WITH pizza_revenues AS (
    SELECT 
        pt.name, 
        SUM(p.price * o.quantity) AS revenue
    FROM order_details o 
    JOIN pizzas p ON o.pizza_id = p.pizza_id 
    JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
),
total_revenue AS (
    SELECT SUM(revenue) AS total
    FROM pizza_revenues
)
SELECT 
    pr.name,
    pr.revenue,
    (pr.revenue / tr.total) * 100 AS revenue_percentage
FROM pizza_revenues pr, total_revenue tr
ORDER BY pr.revenue DESC;

-- Q12: The cumulative revenue generated over time
SELECT 
    o.date,
    SUM(p.price * od.quantity) AS daily_revenue,
    SUM(SUM(p.price * od.quantity)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
JOIN 
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY 
    o.date
ORDER BY 
    o.date;

-- Q13: The top 3 most ordered pizza types based on revenue for each pizza category
WITH ranked_pizzas AS (
    SELECT 
        pt.category,
        pt.name,
        SUM(p.price * o.quantity) AS Total_revenue,
        ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(p.price * o.quantity) DESC) AS rank1
    FROM 
        order_details o 
        JOIN pizzas p ON o.pizza_id = p.pizza_id 
        JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY 
        pt.category, pt.name
)
SELECT 
    category,
    name AS pizza_type,
    Total_revenue
FROM 
    ranked_pizzas
WHERE 
    rank1 <= 3
ORDER BY 
    category, Total_revenue DESC;
    

