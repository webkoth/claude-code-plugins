---
name: database-setup
description: Setup PostgreSQL or MySQL database on server. Use when applications need database backend.
---

# Database Setup

Install and configure PostgreSQL or MySQL.

## PostgreSQL

### Installation
```bash
apt install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql
```

### Create User and Database
```bash
sudo -u postgres psql -c "CREATE USER appuser WITH PASSWORD 'secure_password';"
sudo -u postgres psql -c "CREATE DATABASE appdb OWNER appuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;"
```

### Allow Password Authentication
Edit `/etc/postgresql/16/main/pg_hba.conf`:
```
# Add before "local all all peer"
local   all   appuser   md5
host    all   appuser   127.0.0.1/32   md5
```

Restart:
```bash
systemctl restart postgresql
```

### Connection String
```
postgresql://appuser:secure_password@localhost:5432/appdb
```

## MySQL

### Installation
```bash
apt install -y mysql-server
systemctl enable mysql
systemctl start mysql
mysql_secure_installation
```

### Create User and Database
```bash
mysql -u root -p <<EOF
CREATE DATABASE appdb;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
EOF
```

### Connection String
```
mysql://appuser:secure_password@localhost:3306/appdb
```

## Backup Commands

### PostgreSQL
```bash
pg_dump -U appuser appdb > backup.sql
psql -U appuser appdb < backup.sql
```

### MySQL
```bash
mysqldump -u appuser -p appdb > backup.sql
mysql -u appuser -p appdb < backup.sql
```

## Check Status
```bash
# PostgreSQL
systemctl status postgresql
psql -U appuser -d appdb -c "SELECT version();"

# MySQL
systemctl status mysql
mysql -u appuser -p -e "SELECT VERSION();"
```
