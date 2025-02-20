-- Contoh transaksi
BEGIN;
INSERT INTO orders (customer_id) VALUES (1);
INSERT INTO order_details (order_id, product_id, quantity) VALUES
(currval('orders_order_id_seq'), 1, 2),
(currval('orders_order_id_seq'), 2, 1);
COMMIT;

-- Query contoh
SELECT * FROM get_customer_orders(1);
SELECT calculate_total_price(1);

-- View untuk Laporan Penjualan per Produk
SELECT * FROM sales_report_by_product;

-- View untuk Laporan Penjualan per Pelanggan
SELECT * FROM sales_report_by_customer;

-- Menambahkan Filter atau Sorting
SELECT * FROM sales_report_by_product
WHERE total_quantity_sold > 5; -- Hanya tampilkan produk yang terjual lebih dari 5 unit

-- Urutkan Laporan Penjualan per Pelanggan
SELECT * FROM sales_report_by_customer
ORDER BY total_spent DESC; -- Urutkan berdasarkan total pengeluaran tertinggi

-- View Laporan Penjualan Per Bulan
SELECT * FROM sales_report_by_month;
