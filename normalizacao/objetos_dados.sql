-- Trigger 1: Atualizar data de última alteração na tabela de reviews
-- Toda vez que alguém editar o comentário do review, 
-- essa trigger atualiza automaticamente o campo review_answer_timestamp para a hora atual. 
-- Isso ajuda a saber quando foi a última alteração naquele comentário, importante pra acompanhar o histórico da avaliação.

CREATE OR REPLACE FUNCTION update_review_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.review_answer_timestamp := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_review_timestamp
BEFORE UPDATE ON order_reviews
FOR EACH ROW
WHEN (OLD.review_comment_message IS DISTINCT FROM NEW.review_comment_message)
EXECUTE FUNCTION update_review_last_modified();

-- Trigger 2: Prevenir que um produto com peso nulo seja inserido
-- Antes de inserir ou atualizar um produto, essa trigger verifica se o peso está preenchido e maior que zero. Se não estiver, bloqueia a operação. 
-- Isso evita problemas futuros em cálculos de frete, estoque, ou relatórios que dependem dessa informação.

CREATE OR REPLACE FUNCTION check_product_weight()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.product_weight_g IS NULL OR NEW.product_weight_g <= 0 THEN
        RAISE EXCEPTION 'Peso do produto não pode ser nulo ou menor que 0';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_product_weight
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION check_product_weight();

-- Trigger 3: Registrar log de pagamentos realizados
-- Sempre que um novo pagamento for registrado, essa trigger insere uma linha numa tabela de log com o pedido, valor e data do pagamento. 
-- Isso é útil pra auditoria, saber exatamente quando cada pagamento foi feito, e para análises de comportamento financeiro.

CREATE TABLE order_payments_log (
    log_id SERIAL PRIMARY KEY,
    order_id UUID,
    payment_value NUMERIC(10,2),
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_order_payment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_payments_log(order_id, payment_value)
    VALUES (NEW.order_id, NEW.payment_value);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_order_payment
AFTER INSERT ON order_payments
FOR EACH ROW
EXECUTE FUNCTION log_order_payment();


-- View 1: Pedidos com avaliação ruim (nota <= 2)
--Mostra só os pedidos que receberam nota baixa (2 ou menos). 
-- Serve pra gente focar nos clientes insatisfeitos, investigar problemas e melhorar o serviço.

CREATE OR REPLACE VIEW vw_bad_reviews AS
SELECT o.order_id, r.review_score, r.review_comment_message
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE r.review_score <= 2;

-- View 2: Valor total de pedidos por cliente
-- Aqui somamos tudo que cada cliente gastou, considerando todos os pedidos e produtos. 
-- É ótimo para entender quem são os clientes mais valiosos e planejar ações personalizadas.

CREATE OR REPLACE VIEW vw_total_gasto_por_cliente AS
SELECT o.customer_id, SUM(oi.total_price) AS total_gasto
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id;

-- View 3: Produtos mais vendidos
-- Essa view lista os produtos que mais saíram, em ordem decrescente. Ajuda no controle de estoque, marketing e planejamento de compras.

CREATE OR REPLACE VIEW vw_produtos_mais_vendidos AS
SELECT p.product_id, COUNT(*) AS total_vendas
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_vendas DESC;


-- Procedure 1: Atualizar status de pedido
-- Um jeito simples de mudar o status de um pedido, passando o ID do pedido e o novo status. 
-- Facilita atualizar a situação do pedido no sistema.

CREATE OR REPLACE PROCEDURE sp_atualizar_status_pedido(p_order_id UUID, p_status VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET order_status = p_status
    WHERE order_id = p_order_id;
END;
$$;

-- Procedure 2: Resetar peso de produtos inválidos
-- Quando tem produtos com peso zerado ou nulo, essa procedure define um peso padrão (100g). 
-- Isso evita erros em outras partes do sistema que precisam desse dado.

CREATE OR REPLACE PROCEDURE sp_resetar_peso_produtos_invalidos()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products
    SET product_weight_g = 100
    WHERE product_weight_g <= 0 OR product_weight_g IS NULL;
END;
$$;

-- Procedure 3: Deletar avaliações sem comentários
-- Apaga reviews que não possuem comentário escrito, deixando só as avaliações que realmente têm feedback. 
-- Isso ajuda a manter os dados mais limpos e relevantes.

CREATE OR REPLACE PROCEDURE sp_deletar_reviews_sem_comentario()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM order_reviews
    WHERE review_comment_message IS NULL;
END;
$$;


-- Function 1: Retornar o total de itens de um pedido
-- Retorna a quantidade total de produtos comprados em um pedido, somando as quantidades de cada item. 
-- Útil para relatórios e análises de vendas.

CREATE OR REPLACE FUNCTION fn_total_itens_pedido(p_order_id UUID)
RETURNS INTEGER AS $$
DECLARE
    total_itens INTEGER;
BEGIN
    SELECT SUM(qtd_compra)
    INTO total_itens
    FROM order_items
    WHERE order_id = p_order_id;
    RETURN total_itens;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Verificar se pedido foi entregue
-- Retorna true ou false se o pedido já foi entregue ou não, olhando a data de entrega. 
-- Serve pra saber rapidamente o status da entrega.

CREATE OR REPLACE FUNCTION fn_foi_entregue(p_order_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    entregue BOOLEAN := FALSE;
BEGIN
    SELECT (order_delivered_customer_date IS NOT NULL)
    INTO entregue
    FROM orders
    WHERE order_id = p_order_id;
    RETURN entregue;
END;
$$ LANGUAGE plpgsql;

-- Function 3: Calcular média de review de um cliente
-- Calcula a média das notas dadas pelo cliente em todas as suas avaliações. 
-- Dá uma ideia geral de como esse cliente costuma avaliar os pedidos.

CREATE OR REPLACE FUNCTION fn_media_reviews_cliente(p_customer_id UUID)
RETURNS NUMERIC(3,2) AS $$
DECLARE
    media NUMERIC(3,2);
BEGIN
    SELECT AVG(r.review_score)
    INTO media
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.customer_id = p_customer_id;
    RETURN media;
END;
$$ LANGUAGE plpgsql;
