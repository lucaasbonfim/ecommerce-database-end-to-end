
-- ========================================================
-- População do Data Warehouse a partir do banco normalizado
-- Este script insere dados nas tabelas dimensão e fato
-- ========================================================

-- Popula a dimensão de produtos
INSERT INTO dim_produto (
    id_produto, nome_categoria, nome_categoria_ingles,
    nome_comprimento, descricao_comprimento, fotos_qtd,
    peso_g, comprimento_cm, altura_cm, largura_cm
)
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

-- Popula a dimensão de clientes
INSERT INTO dim_cliente (
    id_cliente, id_cliente_unico, cep_prefixo, cidade, estado
)
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    cl.customer_city,
    cl.customer_state
FROM customers c
JOIN customers_location cl
    ON c.customer_zip_code_prefix = cl.customer_zip_code_prefix;

-- Popula a dimensão de vendedores
INSERT INTO dim_vendedor (
    id_vendedor, cep_prefixo, cidade, estado
)
SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    sl.seller_city,
    sl.seller_state
FROM sellers s
JOIN sellers_location sl
    ON s.seller_zip_code_prefix = sl.seller_zip_code_prefix;

-- Popula a dimensão de tempo
INSERT INTO dim_tempo (
    data, ano, mes, dia, dia_semana, trimestre
)
SELECT DISTINCT
    o.order_purchase_timestamp::DATE AS data,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)::INT,
    EXTRACT(MONTH FROM o.order_purchase_timestamp)::INT,
    EXTRACT(DAY FROM o.order_purchase_timestamp)::INT,
    TO_CHAR(o.order_purchase_timestamp, 'Day'),
    EXTRACT(QUARTER FROM o.order_purchase_timestamp)::INT
FROM orders o;

-- Popula a dimensão de tipo de pagamento
INSERT INTO dim_pagamento (
    id_pagamento_tipo, tipo_pagamento
)
SELECT payment_type_id, payment_type
FROM payment_types;

-- Popula a tabela fato de vendas
INSERT INTO fato_vendas (
    data_compra, id_cliente, id_produto, id_categoria,
    id_vendedor, id_local_cliente, id_local_vendedor,
    id_tempo_compra, id_pagamento_tipo, valor_total, qtd, frete, score_avaliacao
)
SELECT
    o.order_purchase_timestamp::DATE,
    o.customer_id,
    i.product_id,
    p.product_category_name,
    i.seller_id,
    c.customer_zip_code_prefix,
    s.seller_zip_code_prefix,
    o.order_purchase_timestamp::DATE,
    pay.payment_type_id,
    i.total_price,
    i.qtd_compra,
    f.freight_value,
    r.review_score
FROM order_items i
JOIN orders o ON o.order_id = i.order_id
JOIN products p ON p.product_id = i.product_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN sellers s ON s.seller_id = i.seller_id
LEFT JOIN freight_value f ON f.order_id = o.order_id
LEFT JOIN order_reviews r ON r.order_id = o.order_id
LEFT JOIN order_payments pay ON pay.order_id = o.order_id AND pay.payment_sequential = 1;
