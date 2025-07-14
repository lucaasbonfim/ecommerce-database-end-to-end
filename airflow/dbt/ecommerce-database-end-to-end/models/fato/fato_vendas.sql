SELECT
    o.order_purchase_timestamp::DATE AS data_compra,
    o.customer_id AS id_cliente,
    i.product_id AS id_produto,
    p.product_category_name AS id_categoria,
    i.seller_id AS id_vendedor,
    c.customer_zip_code_prefix AS id_local_cliente,
    s.seller_zip_code_prefix AS id_local_vendedor,
    o.order_purchase_timestamp::DATE AS id_tempo_compra,
    pay.payment_type_id AS id_pagamento_tipo,
    i.total_price AS valor_total,
    i.qtd_compra AS qtd,
    f.freight_value AS frete,
    r.review_score AS score_avaliacao
FROM staging.order_items i
JOIN staging.orders o ON o.order_id = i.order_id
JOIN staging.products p ON p.product_id = i.product_id
JOIN staging.customers c ON o.customer_id = c.customer_id
JOIN staging.sellers s ON s.seller_id = i.seller_id
LEFT JOIN staging.freight_value f ON f.order_id = o.order_id
LEFT JOIN staging.order_reviews r ON r.order_id = o.order_id
LEFT JOIN staging.order_payments pay ON pay.order_id = o.order_id AND pay.payment_sequential = 1;
