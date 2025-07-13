-- product_category_name_translation
CREATE UNIQUE INDEX idx_product_category_name_translation_pk
ON product_category_name_translation(product_category_name);

-- products
CREATE UNIQUE INDEX idx_products_pk ON products(product_id);
CREATE INDEX idx_products_category_name ON products(product_category_name);

-- customers_location
CREATE UNIQUE INDEX idx_customers_location_pk ON customers_location(customer_zip_code_prefix);

-- customers
CREATE UNIQUE INDEX idx_customers_pk ON customers(customer_id);
CREATE INDEX idx_customers_zip_code_prefix ON customers(customer_zip_code_prefix);

-- sellers_location
CREATE UNIQUE INDEX idx_sellers_location_pk ON sellers_location(seller_zip_code_prefix);

-- sellers
CREATE UNIQUE INDEX idx_sellers_pk ON sellers(seller_id);
CREATE INDEX idx_sellers_zip_code_prefix ON sellers(seller_zip_code_prefix);

-- orders
CREATE UNIQUE INDEX idx_orders_pk ON orders(order_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- order_reviews
CREATE UNIQUE INDEX idx_order_reviews_pk ON order_reviews(review_id);
CREATE INDEX idx_order_reviews_order_id ON order_reviews(order_id);

-- freight_value
CREATE UNIQUE INDEX idx_freight_value_pk ON freight_value(order_id);

-- payment_types
CREATE UNIQUE INDEX idx_payment_types_pk ON payment_types(payment_type_id);

-- order_payments
CREATE UNIQUE INDEX idx_order_payments_pk ON order_payments(order_id, payment_sequential);
CREATE INDEX idx_order_payments_payment_type_id ON order_payments(payment_type_id);

-- order_items
CREATE UNIQUE INDEX idx_order_items_pk ON order_items(order_item_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_seller_id ON order_items(seller_id);

-- geolocation
CREATE INDEX idx_geolocation_zip_code_prefix ON geolocation(geolocation_zip_code_prefix);
