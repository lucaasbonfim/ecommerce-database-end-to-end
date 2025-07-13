-- Tabela para tradução de categorias de produtos
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(50)
);

-- Tabela de produtos
CREATE TABLE products (
    product_id UUID PRIMARY KEY,
    product_category_name VARCHAR(50),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER NOT NULL CHECK (product_weight_g > 0),
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,
    CONSTRAINT fk_products_category FOREIGN KEY (product_category_name)
        REFERENCES product_category_name_translation(product_category_name)
);

-- Tabela de localização dos clientes
CREATE TABLE customers_location (
    customer_zip_code_prefix INTEGER PRIMARY KEY,
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
);

-- Tabela de clientes
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    customer_unique_id UUID,
    customer_zip_code_prefix INTEGER,
    CONSTRAINT fk_customers_location FOREIGN KEY (customer_zip_code_prefix)
        REFERENCES customers_location(customer_zip_code_prefix)
);

-- Tabela de vendedores (sellers)
CREATE TABLE sellers (
    seller_id UUID PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    CONSTRAINT fk_sellers_location FOREIGN KEY (seller_zip_code_prefix)
        REFERENCES sellers_location(seller_zip_code_prefix)
);

-- Tabela de localização dos vendedores
CREATE TABLE sellers_location (
    seller_zip_code_prefix INTEGER PRIMARY KEY,
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
);

-- Tabela de pedidos
CREATE TABLE orders (
    order_id UUID PRIMARY KEY,
    customer_id UUID,
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- Tabela de avaliações dos pedidos
CREATE TABLE order_reviews (
    review_id UUID PRIMARY KEY,
    order_id UUID,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATE,
    review_answer_timestamp TIMESTAMP,
    CONSTRAINT fk_order_reviews_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

-- Tabela de valor do frete por pedido
CREATE TABLE freight_value (
    order_id UUID PRIMARY KEY,
    freight_value NUMERIC(10,2),
    CONSTRAINT fk_freight_value_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

-- Tabela de tipos de pagamento
CREATE TABLE payment_types (
    payment_type_id INT PRIMARY KEY,
    payment_type VARCHAR(20)
);

-- Tabela de pagamentos dos pedidos
CREATE TABLE order_payments (
    order_id UUID,
    payment_sequential INTEGER,
    payment_type_id INT,
    payment_installments INTEGER,
    payment_value NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_order_payments_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_order_payments_payment_type FOREIGN KEY (payment_type_id)
        REFERENCES payment_types(payment_type_id)
);

-- Tabela de itens dos pedidos
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id UUID,
    product_id UUID,
    seller_id UUID,
    shipping_limit_date DATE,
    total_price NUMERIC(10,2),
    qtd_compra INTEGER,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id),
    CONSTRAINT fk_order_items_seller FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);

-- Tabela de geolocalização
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat TEXT,
    geolocation_lng TEXT,
    geolocation_city TEXT,
    geolocation_state TEXT
);
