-- ============================================================
-- 01: Setup environment, create tables, and load sample data
-- ============================================================

-- Create a database and schema for practice
CREATE DATABASE IF NOT EXISTS TRAINING_DB;
CREATE SCHEMA IF NOT EXISTS TRAINING_DB.SALES_SCHEMA;

USE DATABASE TRAINING_DB;
USE SCHEMA SALES_SCHEMA;

-- Create a warehouse for compute
CREATE WAREHOUSE IF NOT EXISTS TRAINING_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

USE WAREHOUSE TRAINING_WH;

-- ============================================================
-- Create tables
-- ============================================================

CREATE OR REPLACE TABLE customers (
    customer_id     INT AUTOINCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    email           VARCHAR(100),
    city            VARCHAR(50),
    state           VARCHAR(2),
    signup_date     DATE          DEFAULT CURRENT_DATE()
);

CREATE OR REPLACE TABLE products (
    product_id      INT AUTOINCREMENT PRIMARY KEY,
    product_name    VARCHAR(100)  NOT NULL,
    category        VARCHAR(50),
    price           DECIMAL(10,2) NOT NULL,
    stock_qty       INT           DEFAULT 0
);

CREATE OR REPLACE TABLE orders (
    order_id        INT AUTOINCREMENT PRIMARY KEY,
    customer_id     INT           NOT NULL,
    order_date      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP(), -- CDC
    status          VARCHAR(20)   DEFAULT 'PENDING',
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE OR REPLACE TABLE order_items (
    item_id         INT AUTOINCREMENT PRIMARY KEY,
    order_id        INT           NOT NULL,
    product_id      INT           NOT NULL,
    quantity        INT           NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- Insert sample data
-- ============================================================

INSERT INTO customers (first_name, last_name, email, city, state, signup_date)
VALUES
    ('Alice',   'Johnson',  'alice@example.com',    'Denver',       'CO', '2024-01-15'),
    ('Bob',     'Smith',    'bob@example.com',      'Austin',       'TX', '2024-02-20'),
    ('Carol',   'Williams', 'carol@example.com',    'Seattle',      'WA', '2024-03-10'),
    ('David',   'Brown',    'david@example.com',    'Denver',       'CO', '2024-04-05'),
    ('Eve',     'Davis',    'eve@example.com',      'Portland',     'OR', '2024-05-12'),
    ('Frank',   'Miller',   'frank@example.com',    'Austin',       'TX', '2024-06-01'),
    ('Grace',   'Wilson',   'grace@example.com',    'San Francisco','CA', '2024-07-22'),
    ('Hank',    'Moore',    'hank@example.com',     'Seattle',      'WA', '2024-08-30');

INSERT INTO products (product_name, category, price, stock_qty)
VALUES
    ('Laptop Pro 15',       'Electronics',  1299.99, 50),
    ('Wireless Mouse',      'Electronics',  29.99,   200),
    ('Standing Desk',       'Furniture',    549.00,  30),
    ('Mechanical Keyboard', 'Electronics',  89.99,   150),
    ('Monitor 27"',         'Electronics',  399.99,  75),
    ('Desk Lamp',           'Furniture',    45.00,   100),
    ('USB-C Hub',           'Electronics',  59.99,   120),
    ('Office Chair',        'Furniture',    699.00,  25);

INSERT INTO orders (customer_id, order_date, status)
VALUES
    (1, '2024-06-01 10:30:00', 'COMPLETED'),
    (2, '2024-06-05 14:15:00', 'COMPLETED'),
    (1, '2024-06-10 09:00:00', 'COMPLETED'),
    (3, '2024-07-01 11:45:00', 'COMPLETED'),
    (4, '2024-07-15 16:20:00', 'SHIPPED'),
    (5, '2024-08-02 08:30:00', 'SHIPPED'),
    (2, '2024-08-20 13:00:00', 'PENDING'),
    (6, '2024-09-01 10:00:00', 'PENDING'),
    (7, '2024-09-10 15:30:00', 'PENDING'),
    (3, '2024-09-15 12:00:00', 'COMPLETED');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 1, 1299.99),
    (1, 2, 2, 29.99),
    (2, 3, 1, 549.00),
    (2, 4, 1, 89.99),
    (3, 5, 2, 399.99),
    (3, 7, 1, 59.99),
    (4, 1, 1, 1299.99),
    (4, 6, 3, 45.00),
    (5, 8, 1, 699.00),
    (5, 2, 1, 29.99),
    (6, 4, 2, 89.99),
    (6, 7, 1, 59.99),
    (7, 3, 1, 549.00),
    (8, 1, 1, 1299.99),
    (8, 5, 1, 399.99),
    (9, 6, 2, 45.00),
    (9, 2, 3, 29.99),
    (10, 8, 1, 699.00),
    (10, 4, 1, 89.99);

-- Quick verification
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products',  COUNT(*) FROM products
UNION ALL
SELECT 'orders',    COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
