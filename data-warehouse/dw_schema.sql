
-- ========================================================
-- Data Warehouse - Modelagem Estrela para Análise de Vendas
-- Este script cria a estrutura dimensional do DW
-- Cada dimensão é acompanhada de uma explicação sobre sua função
-- ========================================================

-- TABELA DE DIMENSÃO: Produto
-- Permite analisar vendas por categoria de produto, atributos físicos e quantidade de fotos
CREATE TABLE dim_produto (
    id_produto UUID PRIMARY KEY,
    nome_categoria VARCHAR(50),
    nome_categoria_ingles VARCHAR(50),
    nome_comprimento INTEGER,
    descricao_comprimento INTEGER,
    fotos_qtd INTEGER,
    peso_g INTEGER,
    comprimento_cm INTEGER,
    altura_cm INTEGER,
    largura_cm INTEGER
);

-- TABELA DE DIMENSÃO: Cliente
-- Usada para visualizar as vendas por localização do cliente
CREATE TABLE dim_cliente (
    id_cliente UUID PRIMARY KEY,
    id_cliente_unico UUID,
    cep_prefixo INTEGER,
    cidade VARCHAR(50),
    estado VARCHAR(2)
);

-- TABELA DE DIMENSÃO: Vendedor
-- Usada para análise de vendas por região dos vendedores
CREATE TABLE dim_vendedor (
    id_vendedor UUID PRIMARY KEY,
    cep_prefixo INTEGER,
    cidade VARCHAR(50),
    estado VARCHAR(2)
);

-- TABELA DE DIMENSÃO: Tempo
-- Permite realizar análises temporais como vendas por mês ou dia da semana
CREATE TABLE dim_tempo (
    data DATE PRIMARY KEY,
    ano INT,
    mes INT,
    dia INT,
    dia_semana VARCHAR(10),
    trimestre INT
);

-- TABELA DE DIMENSÃO: Tipo de Pagamento
-- Ajuda a entender os métodos de pagamento mais utilizados
CREATE TABLE dim_pagamento (
    id_pagamento_tipo INT PRIMARY KEY,
    tipo_pagamento VARCHAR(20)
);

-- TABELA FATO: Vendas
-- Esta é a tabela central do DW, usada para análises de métricas como valor de venda, quantidade, frete e score
CREATE TABLE fato_vendas (
    id SERIAL PRIMARY KEY,
    data_compra DATE,
    id_cliente UUID,
    id_produto UUID,
    id_categoria VARCHAR(50),
    id_vendedor UUID,
    id_local_cliente INTEGER,
    id_local_vendedor INTEGER,
    id_tempo_compra DATE,
    id_pagamento_tipo INT,
    valor_total NUMERIC(10,2),
    qtd INTEGER,
    frete NUMERIC(10,2),
    score_avaliacao INTEGER
);
