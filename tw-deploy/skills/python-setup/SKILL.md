---
name: python-setup
description: Setup Python environment on server with venv and gunicorn/uvicorn. Use when preparing a server for Python deployment.
---

# Python Server Setup

Install and configure Python environment on Ubuntu server.

## Installation Steps

### 1. Install Python
```bash
apt update
apt install -y python3.11 python3.11-venv python3-pip
```

### 2. Create Virtual Environment
```bash
mkdir -p /var/www/app-name
python3.11 -m venv /var/www/app-name/venv
```

### 3. Activate and Install Dependencies
```bash
source /var/www/app-name/venv/bin/activate
pip install --upgrade pip
pip install gunicorn uvicorn
pip install -r requirements.txt
```

## Systemd Service

Create `/etc/systemd/system/app-name.service`:

### For Gunicorn (Django/Flask)
```ini
[Unit]
Description=Gunicorn App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/app-name
Environment="PATH=/var/www/app-name/venv/bin"
ExecStart=/var/www/app-name/venv/bin/gunicorn --workers 4 --bind 127.0.0.1:8000 app:app

[Install]
WantedBy=multi-user.target
```

### For Uvicorn (FastAPI)
```ini
[Unit]
Description=Uvicorn App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/app-name
Environment="PATH=/var/www/app-name/venv/bin"
ExecStart=/var/www/app-name/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000 --workers 4

[Install]
WantedBy=multi-user.target
```

## Enable and Start Service
```bash
systemctl daemon-reload
systemctl enable app-name
systemctl start app-name
systemctl status app-name
```

## Django Specific
```bash
python manage.py collectstatic --noinput
python manage.py migrate --noinput
```
