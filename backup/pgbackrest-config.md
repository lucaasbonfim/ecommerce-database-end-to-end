# Configuração do pgBackRest entre maquina1 e maquina2

Este documento descreve passo a passo a configuração do pgBackRest para realizar backups do PostgreSQL na `maquina1` e armazená-los na `maquina2`.

---

## 🖥️ Estrutura

- **maquina1**: servidor PostgreSQL
- **maquina2**: servidor repositório de backup
- Comunicação via SSH com chave sem senha

---

## 1. Instalar o pgBackRest (em ambas as máquinas)

```bash
sudo apt update
sudo apt install -y pgbackrest
```

---

## 2. Criar usuário e diretórios

### Em ambas as máquinas:

```bash
sudo adduser --system --group pgbackrest
sudo mkdir -p /var/lib/pgbackrest
sudo chown -R pgbackrest:pgbackrest /var/lib/pgbackrest
sudo chmod 750 /var/lib/pgbackrest
```

### Na `maquina1` também:

```bash
sudo mkdir -p /etc/pgbackrest
sudo chown -R postgres:postgres /etc/pgbackrest
sudo chmod 750 /etc/pgbackrest
```

---

## 3. Gerar chave SSH na maquina1

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_pgbackrest -N ""
```

Copiar a chave para `maquina2`:

```bash
ssh-copy-id -i ~/.ssh/id_rsa_pgbackrest.pub pgbackrest@maquina2
```

Permissões:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa_pgbackrest
```

---

## 4. Verificar conexão

```bash
ssh -i ~/.ssh/id_rsa_pgbackrest pgbackrest@maquina2
```

---

## 5. Configuração do pgBackRest

### Em `/etc/pgbackrest/pgbackrest.conf` da `maquina1`:

```ini
[global]
repo1-path=/var/lib/pgbackrest
repo1-retention-full=2
repo1-retention-diff=7
log-level-console=info

[maquina1]
pg1-path=/var/lib/postgresql/data
repo1-host=maquina2
repo1-host-user=pgbackrest
```

### Em `/etc/pgbackrest/pgbackrest.conf` da `maquina2`:

```ini
[global]
repo1-path=/var/lib/pgbackrest
log-level-console=info

[maquina1]
repo1-host=maquina2
repo1-host-user=pgbackrest

[maquina2]
pg1-path=/var/lib/postgresql/data
repo1-path=/var/lib/pgbackrest
```

---

## 6. Permissões no `.ssh` da maquina2

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## 7. Execução de comandos pgBackRest

### Backup manual full

```bash
pgbackrest --stanza=maquina1 --type=full --log-level-console=info backup
```

### Listar backups disponíveis

```bash
pgbackrest --stanza=maquina1 info
```

---

## 8. Restauração de backup

### Parar o PostgreSQL

```bash
/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/data/pgdata stop
```

### Limpar diretório de dados

```bash
rm -rf /var/lib/postgresql/data/pgdata/*
```

### Restaurar backup

```bash
pgbackrest --stanza=maquina1 --log-level-console=info restore
```

### Iniciar o PostgreSQL

```bash
/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/data/pgdata start
```

---

## ✔️ Testes e verificações

- Conexão SSH sem senha entre as máquinas
- Execução dos comandos `pgbackrest info`, `backup`, `restore`
- Permissões corretas nos diretórios e chaves

---

## 📝 Observações

- O `pgbackrest` sempre deve ser executado como o usuário `postgres`.
- As chaves SSH devem estar com permissões restritas para evitar erros de segurança.
- Use o comando `sudo -u postgres pgbackrest` se necessário.