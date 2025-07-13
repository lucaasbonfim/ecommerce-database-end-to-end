-- QUERY ORIGINAL PESADA
-- Aqui eu queria simular uma carga bem pesada no banco, então usei vários CROSS JOINs entre tabelas pequenas,
-- e um generate_series enorme (até 100.000) só pra inflar o número de linhas de forma artificial.
-- Essa abordagem faz com que o número de combinações exploda, e o PostgreSQL tenha que processar milhões de linhas.
-- O objetivo era forçar o consumo de CPU e I/O, pra poder acompanhar o efeito disso no Grafana via Prometheus.

WITH seq AS (
    SELECT generate_series(1, 100000) AS n
),
expanded AS (
    SELECT
        v.nome AS vendedor,
        c.nome AS cliente,
        pr.categoria,
        s.n
    FROM
        vendedores v
    CROSS JOIN clientes c
    CROSS JOIN produtos pr
    CROSS JOIN seq s
)
SELECT
    vendedor,
    cliente,
    categoria,
    COUNT(*) AS total_rows,
    SUM(n) AS soma_n
FROM
    expanded
GROUP BY
    vendedor, cliente, categoria
ORDER BY
    total_rows DESC
LIMIT 100;


-- QUERY OTIMIZADA
-- Depois que eu já tinha mostrado o impacto da query pesada, mostrei essa versão aqui otimizada.
-- Ela é uma query real, mais parecida com algo que seria usado em um dashboard ou relatório.
-- Aqui estou agrupando por vendedor e categoria dos produtos, contando os itens e somando a receita.
-- Também filtrei a partir de uma data pra evitar varrer a tabela inteira.
-- É uma query muito mais leve e útil.

SELECT
    v.nome AS vendedor,
    pr.categoria,
    COUNT(ip.id) AS total_itens_pedidos,
    SUM(ip.quantidade * pr.preco) AS receita_total
FROM
    vendedores v
JOIN pedidos pe ON pe.vendedor_id = v.id
JOIN itens_pedido ip ON ip.pedido_id = pe.id
JOIN produtos pr ON pr.id = ip.produto_id
WHERE
    pe.data_pedido >= '2023-01-01'
GROUP BY
    v.nome, pr.categoria
ORDER BY
    receita_total DESC
LIMIT 100;