# Projeto Completo de Banco de Dados para E-commerce

Este repositório contém um projeto completo de banco de dados simulado para um ambiente de e-commerce. O projeto aborda desde a modelagem relacional até backup, monitoramento, criação de Data Warehouse (DW) e processos de ETL, utilizando infraestrutura em Docker.

---

## ✅ Visão Geral

O projeto contempla:

- 🗂 **Modelagem Relacional (OLTP)** – Banco normalizado com integridade referencial  
- 🔐 **Backup e Restauração com pgBackRest** (configurado entre duas máquinas Docker)  
- 📊 **Monitoramento com Prometheus + Grafana**  
- 🧱 **Criação de Data Warehouse (modelo dimensional)**  
- 🔁 **ETL: Extração, Transformação e Carga de dados**  
- 🔍 **Consultas analíticas e geração de insights**  

---

## 🐳 Infraestrutura com Docker

A infraestrutura foi containerizada com Docker, simulando três ambientes distintos:

### 📦 `maquina1` – Banco de Dados (PostgreSQL)
- Contém a base OLTP e o Data Warehouse
- Servidor de origem para o pgBackRest

### 📦 `maquina2` – Servidor de Backup
- Repositório configurado como destino do `pgBackRest`
- Comunicação via SSH com `maquina1`

### 📦 `monitoramento` – Prometheus + Grafana
- Monitoramento de métricas do PostgreSQL
- Dashboards customizados em Grafana
- Inclui exemplo de query pesada para teste de carga

---

## 📁 Estrutura do Repositório

```text
bd-ecommerce-completo/
├── README.md
│
├── 01-normalizacao/
│   ├── banco_normalizado.sql
│   ├── dicionario_dados.xlsx
│   ├── explicacao_normalizacao.xlsx
│   ├── index_banco.sql
│   ├── objetos_dados.sql
│   ├── script_normalizacao.pdf
│   └── import_olist.load
│
├── 02-backup/
│   ├── comandos_backup.sh
│   └── pgbackrest-config.md
│
├── 03-monitoramento/
│   └── monitoramento_queries.sql
│
├── 04-data-warehouse/
│   ├── dw_schema.sql
│   └── dw_population.sql
│
├── 05-etl/
│   └── airflow/
│       ├── dags/
│       ├── dbt/
│       ├── Dockerfile
│       └── requirements.txt
│
└── 06-docker/
    ├── docker-compose.yml
    ├── run.sh
    ├── README.md
    ├── maquina1/
    ├── maquina2/
    └── maquina3/
```

---

## 🛠 Tecnologias Utilizadas

- **PostgreSQL** – Banco de dados relacional
- **pgBackRest** – Ferramenta de backup/restauração
- **Docker** – Contêineres para serviços (Prometheus, Grafana)
- **Prometheus + Grafana** – Stack de monitoramento
- **SQL (PostgreSQL)** – Consultas, DDL e ETL
---

## 📈 Exemplos de Análises no DW

- Total de vendas por estado, cidade ou categoria de produto
- Score médio de avaliação por vendedor ou período
- Comparação de vendas por trimestre/ano
- Relação entre peso do produto e valor do frete
- Participação dos métodos de pagamento

---

## 👨‍🎓 Autores

**Lucas Bonfim, Yan Ribeiro, Lian Mendes, Julia Vita**  
Projeto desenvolvido em grupo para a disciplina de Banco de Dados II.

---
