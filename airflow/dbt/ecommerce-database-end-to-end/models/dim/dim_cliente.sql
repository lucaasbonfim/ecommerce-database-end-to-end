SELECT
    c.customer_id AS id_cliente,
    c.customer_unique_id,
    c.customer_zip_code_prefix AS cep_prefixo,
    cl.customer_city AS cidade,
    cl.customer_state AS estado
FROM staging.customers c
JOIN staging.customers_location cl ON c.customer_zip_code_prefix = cl.customer_zip_code_prefix;
