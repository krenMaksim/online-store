-- Views for the online-store database (SQLite)
-- Provides helpful joins and summaries for customers and orders

BEGIN TRANSACTION;

-- 1) Orders joined with customer details
DROP VIEW IF EXISTS orders_with_customer;
CREATE VIEW orders_with_customer AS
SELECT
  o.id AS order_id,
  o.order_number,
  o.total_cents,
  ROUND(o.total_cents / 100.0, 2) AS total_dollars,
  o.status,
  o.created_at AS order_created_at,
  c.id AS customer_id,
  c.first_name,
  c.last_name,
  c.email,
  c.created_at AS customer_created_at
FROM orders o
JOIN customers c ON c.id = o.customer_id;

-- 2) Per-customer order summary (counts, spend, last order)
DROP VIEW IF EXISTS customer_order_summary;
CREATE VIEW customer_order_summary AS
SELECT
  c.id AS customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.email,
  COUNT(o.id) AS order_count,
  COALESCE(SUM(o.total_cents), 0) AS total_cents,
  ROUND(COALESCE(SUM(o.total_cents), 0) / 100.0, 2) AS total_dollars,
  MAX(o.created_at) AS last_order_at
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.first_name, c.last_name, c.email;

-- 3) Latest order per customer
DROP VIEW IF EXISTS customer_latest_order;
CREATE VIEW customer_latest_order AS
SELECT
  o.id AS order_id,
  o.order_number,
  o.total_cents,
  ROUND(o.total_cents / 100.0, 2) AS total_dollars,
  o.status,
  o.created_at AS order_created_at,
  o.customer_id,
  c.first_name,
  c.last_name,
  c.email
FROM orders o
JOIN (
  SELECT customer_id, MAX(created_at) AS last_order_at
  FROM orders
  GROUP BY customer_id
) latest ON latest.customer_id = o.customer_id AND latest.last_order_at = o.created_at
JOIN customers c ON c.id = o.customer_id;

COMMIT;
