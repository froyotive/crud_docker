# 🐳 Docker Deployment Guide

Panduan lengkap untuk deploy Laravel CRUD application dengan Docker dan MySQL.

---

## 📋 Prerequisites

- ✅ **Docker Desktop** installed (Windows/Mac/Linux)
- ✅ **Docker Compose** v2.0+ (or docker-compose v1.x)
- ✅ **Git** (untuk clone repository)
- ✅ Minimal 4GB RAM untuk containers
- ✅ Port 8000 dan 3306 harus tersedia

> **Note:** Scripts automatically detect whether you're using Docker Compose V1 (`docker-compose`) or V2 (`docker compose`) and use the appropriate command.

### Install Docker Desktop

**Windows:**
1. Download dari: https://www.docker.com/products/docker-desktop
2. Install dan restart
3. Enable WSL 2 jika diminta

**Mac:**
1. Download dari: https://www.docker.com/products/docker-desktop
2. Install Docker.app
3. Jalankan Docker Desktop

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
sudo systemctl start docker
```

---

## 🚀 Quick Start - Production

### Windows PowerShell

```powershell
# 1. Clone repository (jika belum)
git clone <your-repo-url>
cd crud

# 2. Jalankan deployment script
.\docker\scripts\deploy.ps1
```

### Linux/Mac Bash

```bash
# 1. Clone repository
git clone <your-repo-url>
cd crud

# 2. Make scripts executable
chmod +x docker/scripts/deploy.sh
chmod +x docker/scripts/dev.sh

# 3. Run deployment
./docker/scripts/deploy.sh
```

### Manual Deployment (All Platforms)

```powershell
# 1. Copy environment file
copy .env.docker .env  # Windows
# cp .env.docker .env  # Linux/Mac

# 2. Edit .env untuk production settings (opsional)
notepad .env  # Windows
# nano .env   # Linux/Mac

# 3. Build dan start containers
docker-compose up -d --build

# 4. Tunggu MySQL ready (20-30 detik)
timeout /t 20  # Windows
# sleep 20     # Linux/Mac

# 5. Run migrations
docker-compose exec app php artisan migrate --force

# 6. Seed database
docker-compose exec app php artisan db:seed --class=AdminUserSeeder --force

# 7. Optimize untuk production
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# 8. Set permissions
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chown -R www-data:www-data /var/www/html/bootstrap/cache
```

### 🎉 Access Application

Setelah deployment selesai:

- **🌐 Application**: http://localhost:8000
- **🔐 Admin Panel (Filament)**: http://localhost:8000/admin
- **📊 Default Admin**: admin@example.com / password
- **👤 Default User**: user@example.com / password

---

## 🛠️ Development Mode

### Start Development Environment

**Windows:**
```powershell
.\docker\scripts\dev.ps1
```

**Linux/Mac:**
```bash
chmod +x docker/scripts/dev.sh
./docker/scripts/dev.sh
```

### Watch for Asset Changes

```powershell
# Dalam terminal terpisah
docker-compose run --rm node npm run dev
```

---

## 📁 Docker Structure

```
crud/
├── docker/
│   ├── nginx/
│   │   └── nginx.conf              # Nginx web server config
│   ├── php/
│   │   └── local.ini               # PHP settings
│   ├── mysql/
│   │   └── init/
│   │       └── 01-init.sql         # MySQL initialization
│   └── scripts/
│       ├── deploy.ps1              # Windows deployment
│       ├── deploy.sh               # Linux/Mac deployment
│       └── dev.ps1                 # Development setup
├── Dockerfile                      # Laravel app image
├── docker-compose.yml              # Services orchestration
├── .dockerignore                   # Files to exclude
└── .env.docker                     # Environment template
```

---

## 🔧 Configuration

### Environment Variables (.env)

Key variables untuk Docker deployment:

```env
# Application
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8000
APP_PORT=8000                    # Port untuk Nginx

# Database
DB_CONNECTION=mysql
DB_HOST=mysql                    # ← Container name (jangan ubah)
DB_PORT=3306
DB_DATABASE=crud
DB_USERNAME=root
DB_PASSWORD=secret_password      # ⚠️ CHANGE THIS!

# Admin Registration
ADMIN_REGISTRATION_CODE=AdminNihBro  # ⚠️ CHANGE THIS!
```

### Custom Ports

Jika port 8000 sudah digunakan, edit di `.env`:

```env
APP_PORT=9000  # Ubah ke port yang tersedia
```

Atau langsung di `docker-compose.yml`:

```yaml
nginx:
  ports:
    - "9000:80"  # Change 8000 to 9000
```

---

## 🐳 Docker Commands

### Service Management

```powershell
# Check status semua services
docker-compose ps

# View logs (semua services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f app
docker-compose logs -f nginx
docker-compose logs -f mysql

# Restart services
docker-compose restart

# Restart specific service
docker-compose restart app

# Stop services
docker-compose stop

# Stop & remove containers
docker-compose down

# Stop & remove containers + volumes (⚠️ hapus database)
docker-compose down -v

# Rebuild containers
docker-compose up -d --build --force-recreate
```

### Container Shell Access

```powershell
# Access Laravel app container
docker-compose exec app bash

# Access MySQL container
docker-compose exec mysql bash

# Access MySQL CLI
docker-compose exec mysql mysql -u root -p
# Password: secret_password (atau sesuai .env)
```

### Laravel Artisan Commands

```powershell
# Run any artisan command
docker-compose exec app php artisan <command>

# Examples:
docker-compose exec app php artisan migrate
docker-compose exec app php artisan db:seed
docker-compose exec app php artisan tinker
docker-compose exec app php artisan route:list
docker-compose exec app php artisan cache:clear
```

### Composer & NPM

```powershell
# Install Composer packages
docker-compose exec app composer install
docker-compose exec app composer require <package>

# Install NPM packages
docker-compose run --rm node npm install
docker-compose run --rm node npm run build
```

---

## 🗄️ Database Management

### Backup Database

**Windows:**
```powershell
# Export database
docker-compose exec mysql mysqldump -u root -psecret_password crud > backup.sql

# Dengan timestamp
$date = Get-Date -Format "yyyyMMdd_HHmmss"
docker-compose exec mysql mysqldump -u root -psecret_password crud > "backup_$date.sql"
```

**Linux/Mac:**
```bash
# Export database
docker-compose exec mysql mysqldump -u root -psecret_password crud > backup.sql

# Dengan timestamp
docker-compose exec mysql mysqldump -u root -psecret_password crud > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore Database

```powershell
# Import database
Get-Content backup.sql | docker-compose exec -T mysql mysql -u root -psecret_password crud

# Linux/Mac
# docker-compose exec -T mysql mysql -u root -psecret_password crud < backup.sql
```

### Access MySQL CLI

```powershell
# Connect to MySQL
docker-compose exec mysql mysql -u root -p
# Enter password: secret_password

# Useful MySQL commands:
mysql> SHOW DATABASES;
mysql> USE crud;
mysql> SHOW TABLES;
mysql> SELECT * FROM users;
mysql> DESCRIBE users;
mysql> exit
```

### Reset Database

```powershell
# ⚠️ WARNING: This will delete all data!

# Method 1: Drop & recreate via artisan
docker-compose exec app php artisan migrate:fresh --seed

# Method 2: Remove volume & recreate
docker-compose down -v
docker-compose up -d
docker-compose exec app php artisan migrate --seed
```

---

## 🔐 Security Best Practices

### Production Checklist

- [ ] **Change DB_PASSWORD** di .env
- [ ] **Set APP_DEBUG=false**
- [ ] **Generate new APP_KEY**:
  ```powershell
  docker-compose exec app php artisan key:generate
  ```
- [ ] **Update ADMIN_REGISTRATION_CODE**
- [ ] **Remove atau ubah password default accounts**:
  ```powershell
  docker-compose exec app php artisan tinker
  >>> $admin = \App\Models\User::where('email', 'admin@example.com')->first();
  >>> $admin->password = bcrypt('new_secure_password');
  >>> $admin->save();
  ```
- [ ] **Enable HTTPS** (gunakan reverse proxy seperti Nginx Proxy Manager atau Traefik)
- [ ] **Set proper file permissions**
- [ ] **Regular database backups**
- [ ] **Monitor logs**: `docker-compose logs -f`
- [ ] **Update dependencies regularly**

### Firewall Configuration

```powershell
# Windows Firewall
# Pastikan port 8000 terbuka untuk web access
# Port 3306 sebaiknya tidak exposed ke public

# Linux iptables
sudo ufw allow 8000/tcp    # Web access
# Don't expose 3306 to public
```

---

## 🐛 Troubleshooting

### Container Tidak Start

```powershell
# Check logs untuk error
docker-compose logs

# Check specific service
docker-compose logs app
docker-compose logs mysql

# Rebuild dari awal
docker-compose down
docker-compose up -d --build
```

### Permission Errors

```powershell
# Fix storage permissions
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Database Connection Failed

```powershell
# 1. Check MySQL is running
docker-compose ps mysql

# 2. Check MySQL logs
docker-compose logs mysql

# 3. Check .env configuration
# DB_HOST harus "mysql" (nama container)

# 4. Test connection
docker-compose exec app php artisan tinker
>>> DB::connection()->getPdo();

# 5. Recreate database
docker-compose down -v
docker-compose up -d --build
docker-compose exec app php artisan migrate --seed
```

### Assets Not Loading (404 Errors)

```powershell
# Rebuild assets
docker-compose run --rm node npm install --legacy-peer-deps
docker-compose run --rm node npm run build

# Check if files exist
docker-compose exec app ls -la public/build

# Clear cache
docker-compose exec app php artisan view:clear
```

### Port Already in Use

```powershell
# Check apa yang menggunakan port 8000
netstat -ano | findstr :8000  # Windows
# lsof -i :8000  # Linux/Mac

# Option 1: Stop service yang menggunakan port
# Option 2: Ubah port di .env
APP_PORT=9000

# Restart containers
docker-compose down
docker-compose up -d
```

### MySQL Container Keeps Restarting

```powershell
# Check logs
docker-compose logs mysql

# Common issues:
# 1. Not enough memory → Increase Docker memory limit
# 2. Corrupted data → Remove volume and recreate
docker-compose down -v
docker-compose up -d

# 3. Wrong password format → Check .env
```

### Clear All Caches

```powershell
# Application caches
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

---

## 📊 Monitoring & Maintenance

### Check Services Health

```powershell
# Status semua services
docker-compose ps

# Detailed info
docker inspect crud_app
docker inspect crud_mysql
docker inspect crud_nginx
```

### Resource Usage

```powershell
# Real-time stats
docker stats

# Specific container
docker stats crud_app
```

### Disk Usage

```powershell
# Check Docker disk usage
docker system df

# Detailed view
docker system df -v

# Clean up unused resources
docker system prune
docker volume prune
docker image prune
```

### Logs Management

```powershell
# Follow logs real-time
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Specific service
docker-compose logs -f app

# Save logs to file
docker-compose logs > docker-logs.txt
```

---

## 🔄 Updates & Maintenance

### Update Application Code

```powershell
# 1. Pull latest code
git pull origin main

# 2. Rebuild containers
docker-compose up -d --build

# 3. Run new migrations
docker-compose exec app php artisan migrate --force

# 4. Clear & rebuild caches
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# 5. Rebuild assets
docker-compose run --rm node npm install --legacy-peer-deps
docker-compose run --rm node npm run build
```

### Update Dependencies

```powershell
# Update Composer dependencies
docker-compose exec app composer update

# Update NPM dependencies
docker-compose run --rm node npm update

# Rebuild assets
docker-compose run --rm node npm run build
```

### Update Docker Images

```powershell
# Pull latest base images
docker-compose pull

# Rebuild with new images
docker-compose up -d --build
```

---

## ☁️ Deploy to Cloud

### Deploy to VPS (DigitalOcean, AWS, etc.)

```bash
# 1. SSH ke server
ssh user@your-server-ip

# 2. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Clone repository
git clone <your-repo-url>
cd crud

# 5. Setup environment
cp .env.docker .env
nano .env  # Edit untuk production

# 6. Run deployment
chmod +x docker/scripts/deploy.sh
./docker/scripts/deploy.sh

# 7. Setup reverse proxy (Nginx) untuk HTTPS
# Install certbot untuk SSL certificate
```

### Docker Hub Deployment

```bash
# 1. Build image
docker build -t your-username/crud-app:latest .

# 2. Push to Docker Hub
docker login
docker push your-username/crud-app:latest

# 3. On target server
docker pull your-username/crud-app:latest
docker-compose up -d
```

---

## 📱 Access Points

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Web Application** | http://localhost:8000 | - |
| **Admin Panel (Filament)** | http://localhost:8000/admin | admin@example.com / password |
| **User Dashboard** | http://localhost:8000/dashboard | user@example.com / password |
| **MySQL Database** | localhost:3306 | root / secret_password |

---

## 🆘 Common Issues & Solutions

### Issue: "Port 8000 already in use"
**Solution:** Ubah APP_PORT di .env atau stop service lain yang menggunakan port tersebut

### Issue: "MySQL connection refused"
**Solution:** Tunggu beberapa detik untuk MySQL startup, atau check logs: `docker-compose logs mysql`

### Issue: "Permission denied" di storage
**Solution:** `docker-compose exec app chmod -R 775 storage bootstrap/cache`

### Issue: Assets 404 (CSS/JS tidak load)
**Solution:** `docker-compose run --rm node npm run build`

### Issue: Container terus restart
**Solution:** Check logs dan increase Docker memory limit di Docker Desktop settings

---

## 📞 Support & Resources

- **Laravel Documentation**: https://laravel.com/docs
- **Docker Documentation**: https://docs.docker.com
- **Filament Documentation**: https://filamentphp.com/docs

---

## 🎉 Quick Reference

### Start Everything
```powershell
docker-compose up -d
```

### Stop Everything
```powershell
docker-compose down
```

### View Logs
```powershell
docker-compose logs -f
```

### Restart Service
```powershell
docker-compose restart app
```

### Run Artisan Command
```powershell
docker-compose exec app php artisan <command>
```

### Access Database
```powershell
docker-compose exec mysql mysql -u root -p
```

### Rebuild Everything
```powershell
docker-compose down
docker-compose up -d --build
```

---

**Happy Deploying! 🚀**

**Last Updated**: November 20, 2025
