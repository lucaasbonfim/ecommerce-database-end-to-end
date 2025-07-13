#!/bin/bash

# === CONFIGURAÇÃO GERAL DO SISTEMA ===
# Rodar em ambas as máquinas
echo "==> Atualizando pacotes e instalando pgBackRest..."
sudo apt update
sudo apt install -y pgbackrest

echo "==> Criando usuário do sistema pgbackrest..."
sudo adduser --system --group pgbackrest

# === CONFIGURAÇÃO MÁQUINA 1: Servidor PostgreSQL ===
echo "==> Configurando máquina1 (servidor PostgreSQL)..."
sudo mkdir -p /etc/pgbackrest
sudo chown -R postgres:postgres /etc/pgbackrest
sudo chmod 750 /etc/pgbackrest

# Criar diretório local para armazenamento temporário de backups (se necessário)
sudo mkdir -p /var/lib/pgbackrest
sudo chown -R pgbackrest:pgbackrest /var/lib/pgbackrest
sudo chmod 750 /var/lib/pgbackrest

# === CONFIGURANDO CHAVE SSH PARA CONEXÃO SEM SENHA ===
echo "==> Gerando chave SSH para comunicação com máquina2..."
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_pgbackrest -N ""

echo "==> Copiando chave pública para máquina2 (repositório)..."
# Substitua "maquina2" pelo IP ou nome correto
ssh-copy-id -i ~/.ssh/id_rsa_pgbackrest.pub pgbackrest@maquina2

# Definindo permissões corretas
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa_pgbackrest

# Teste de conexão
echo "==> Testando conexão SSH sem senha com máquina2..."
ssh -i ~/.ssh/id_rsa_pgbackrest pgbackrest@maquina2 "echo Conexão SSH OK"

# === CONFIGURAR ARQUIVO pgbackrest.conf (Exemplo) ===
echo "==> Criando configuração do pgBackRest (/etc/pgbackrest/pgbackrest.conf)..."

sudo tee /etc/pgbackrest/pgbackrest.conf > /dev/null <<EOF
[global]
repo1-path=/var/lib/pgbackrest
repo1-retention-full=2
repo1-retention-diff=7
log-level-console=info

[maquina1]
pg1-path=/var/lib/postgresql/data
repo1-host=maquina2
repo1-host-user=pgbackrest
EOF

# === CONFIGURAÇÃO MÁQUINA 2: Repositório de Backup ===
echo "==> Configurando máquina2 (repositório de backup)..."
ssh -i ~/.ssh/id_rsa_pgbackrest pgbackrest@maquina2 << 'EOF2'
sudo mkdir -p /var/lib/pgbackrest
sudo chown -R pgbackrest:pgbackrest /var/lib/pgbackrest
sudo chmod 750 /var/lib/pgbackrest

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Configuração de exemplo do pgbackrest.conf
sudo tee /etc/pgbackrest/pgbackrest.conf > /dev/null <<EOC
[global]
repo1-path=/var/lib/pgbackrest
log-level-console=info

[maquina1]
repo1-host=maquina2
repo1-host-user=pgbackrest

[maquina2]
pg1-path=/var/lib/postgresql/data
repo1-path=/var/lib/pgbackrest
EOC
EOF2

# === COMANDOS PARA USO DO pgBACKREST ===

echo "==> Inicializar o backup completo..."
pgbackrest --stanza=maquina1 --type=full --log-level-console=info backup

echo "==> Listar backups disponíveis..."
pgbackrest --stanza=maquina1 info

# === COMANDOS PARA RESTAURAÇÃO (QUANDO NECESSÁRIO) ===
# Parar PostgreSQL antes de restaurar
echo "==> Parando PostgreSQL para restauração..."
/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/data/pgdata stop

echo "==> Limpando diretório de dados PostgreSQL..."
rm -rf /var/lib/postgresql/data/pgdata/*

echo "==> Restaurando backup..."
pgbackrest --stanza=maquina1 --log-level-console=info restore

echo "==> Iniciando PostgreSQL novamente..."
/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/data/pgdata start

echo "==> Processo concluído com sucesso!"
