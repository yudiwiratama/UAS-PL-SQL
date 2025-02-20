-- Function 1: Menghitung total harga pesanan (sudah diperbaiki)
CREATE OR REPLACE FUNCTION calculate_total_price(p_order_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC(10,2);
BEGIN
    SELECT SUM(subtotal) INTO total
    FROM order_details
    WHERE order_id = p_order_id;
    
    UPDATE orders
    SET total_price = total
    WHERE order_id = p_order_id;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Mendapatkan pesanan pelanggan
CREATE OR REPLACE FUNCTION get_customer_orders(customer_id INT)
RETURNS TABLE (
    order_id INT,
    order_date DATE,
    total_price NUMERIC(10,2),
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.order_id, o.order_date, o.total_price, o.status
    FROM orders o
    WHERE o.customer_id = get_customer_orders.customer_id;
END;
$$ LANGUAGE plpgsql;

-- Function 3: Update stok produk
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE product_id = NEW.product_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE product_id = OLD.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk update stok
CREATE TRIGGER update_stock_trigger
AFTER INSERT OR DELETE ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

-- Trigger untuk menghitung subtotal
CREATE OR REPLACE FUNCTION calculate_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    NEW.subtotal = (SELECT price FROM products WHERE product_id = NEW.product_id) * NEW.quantity;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_subtotal_trigger
BEFORE INSERT OR UPDATE ON order_details
FOR EACH ROW
EXECUTE FUNCTION calculate_subtotal();

-- Insert Order
BEGIN;
INSERT INTO orders (customer_id) VALUES (1);
INSERT INTO order_details (order_id, product_id, quantity) VALUES
(currval('orders_order_id_seq'), 1, 2),
(currval('orders_order_id_seq'), 2, 1);
COMMIT;


-- View untuk laporan penjualan per produk
CREATE VIEW sales_report_by_product AS
SELECT
    p.product_name,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.subtotal) AS total_revenue
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name;

-- View untuk laporan penjualan per pelanggan
CREATE VIEW sales_report_by_customer AS
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_price) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.name;

-- View untuk laporan penjualan per bulan
CREATE VIEW sales_report_by_month AS
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.subtotal) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DATE_TRUNC('month', o.order_date);
