---
name: php-setup
description: Setup PHP environment on server with PHP-FPM and Composer. Use when preparing a server for PHP deployment.
---

# PHP Server Setup

Install and configure PHP environment on Ubuntu server.

## Installation Steps

### 1. Install PHP and Extensions
```bash
apt update
apt install -y php8.2-fpm php8.2-mysql php8.2-pgsql \
  php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip \
  php8.2-gd php8.2-redis php8.2-intl php8.2-bcmath
```

### 2. Install Composer
```bash
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
```

### 3. Configure PHP-FPM
Edit `/etc/php/8.2/fpm/pool.d/www.conf`:
```ini
user = www-data
group = www-data
listen = /var/run/php/php8.2-fpm.sock
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
```

### 4. PHP Settings
Edit `/etc/php/8.2/fpm/php.ini`:
```ini
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 256M
max_execution_time = 300
```

## Verify Installation
```bash
php -v
composer -V
systemctl status php8.2-fpm
```

## Laravel Setup
```bash
cd /var/www/app-name
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
chown -R www-data:www-data storage bootstrap/cache
```

## Restart PHP-FPM
```bash
systemctl restart php8.2-fpm
```
