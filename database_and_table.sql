-- Buat database
CREATE DATABASE ecommerce;

-- Connect ke database ecommerce
\c ecommerce

-- Buat tabel
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    stock INT NOT NULL,
    description TEXT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE DEFAULT CURRENT_DATE,
    total_price NUMERIC(10,2),
    status VARCHAR(20) DEFAULT 'PENDING'
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    subtotal NUMERIC(10,2)
);

-- Insert data contoh
INSERT INTO customers (name, email, phone) VALUES
('Angga Wijaya', 'angga.wijaya@gmail.com', '08123456789'),
('Juan Sunarti', 'juan227@gmail.com', '08234567890');

INSERT INTO products (product_name, price, stock, description) VALUES
('Laptop', 10000000, 10, 'Macbook Air M1'),
('Smartphone', 5000000, 20, 'Samsung S21 Ultra'),
('Tablet', 3000000, 15, 'IPad Apple V33 Pro');
