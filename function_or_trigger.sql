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
