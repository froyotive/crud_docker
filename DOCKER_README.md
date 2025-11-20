# 🐳 Docker Setup for Laravel CRUD App

Containerized Laravel application with MySQL database, Nginx web server, and Node.js for asset compilation.

## 📦 What's Included

- **PHP 8.2-FPM** - Laravel application server
- **MySQL 8.0** - Database server
- **Nginx Alpine** - Web server
- **Node 18** - Asset compilation

## 🚀 Quick Start

### Windows PowerShell

```powershell
# 1. Copy environment file
copy .env.docker .env

# 2. Deploy (automated)
.\docker\scripts\deploy.ps1
```

### Linux/Mac

```bash
# 1. Copy environment file
cp .env.docker .env

# 2. Make executable
chmod +x docker/scripts/deploy.sh

# 3. Deploy
./docker/scripts/deploy.sh
```

### Manual Deployment

```powershell
# Build and start
docker-compose up -d --build

# Wait for MySQL
timeout /t 20

# Run migrations
docker-compose exec app php artisan migrate --force

# Seed database
docker-compose exec app php artisan db:seed --class=AdminUserSeeder --force

# Cache config
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
```

## 🌐 Access

After deployment:

- **Application**: http://localhost:8000
- **Admin Panel**: http://localhost:8000/admin
- **Admin Login**: admin@example.com / password
- **User Login**: user@example.com / password

## 📁 Structure

```
docker/
├── nginx/
│   └── nginx.conf          # Nginx configuration
├── php/
│   └── local.ini           # PHP settings
├── mysql/
│   └── init/
│       └── 01-init.sql     # MySQL init script
└── scripts/
    ├── deploy.ps1          # Windows deployment
    ├── deploy.sh           # Linux/Mac deployment
    └── dev.ps1             # Development setup
```

## 🔧 Configuration

### Ports

Edit in `.env`:
```env
APP_PORT=8000      # Nginx port
DB_PORT=3306       # MySQL port
```

### Database

```env
DB_HOST=mysql              # Container name (don't change)
DB_DATABASE=crud
DB_USERNAME=root
DB_PASSWORD=secret_password   # ⚠️ Change this!
```

## 📝 Common Commands

```powershell
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart service
docker-compose restart app

# Access container
docker-compose exec app bash

# Run artisan
docker-compose exec app php artisan <command>

# Run composer
docker-compose exec app composer install

# Build assets
docker-compose run --rm node npm run build
```

## 🗄️ Database

### Backup
```powershell
docker-compose exec mysql mysqldump -u root -psecret_password crud > backup.sql
```

### Restore
```powershell
Get-Content backup.sql | docker-compose exec -T mysql mysql -u root -psecret_password crud
```

### Access MySQL
```powershell
docker-compose exec mysql mysql -u root -p
# Password: secret_password
```

## 🐛 Troubleshooting

### Logs
```powershell
docker-compose logs app
docker-compose logs mysql
docker-compose logs nginx
```

### Rebuild
```powershell
docker-compose down
docker-compose up -d --build
```

### Reset Database
```powershell
docker-compose down -v
docker-compose up -d
docker-compose exec app php artisan migrate --seed
```

### Fix Permissions
```powershell
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
```

## 📚 Documentation

- **[Full Deployment Guide](DOCKER_DEPLOYMENT.md)** - Complete documentation
- **[Quick Reference](DOCKER_QUICK_REFERENCE.md)** - Cheat sheet

## 🔐 Security

Before production:

- [ ] Change `DB_PASSWORD` in .env
- [ ] Change `ADMIN_REGISTRATION_CODE` in .env
- [ ] Set `APP_DEBUG=false`
- [ ] Generate new `APP_KEY`
- [ ] Update default user passwords
- [ ] Enable HTTPS

## 🆘 Support

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Restart: `docker-compose restart`
3. Rebuild: `docker-compose down && docker-compose up -d --build`

## 📞 Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com)
- [Filament Documentation](https://filamentphp.com/docs)

---

**Happy Coding! 🎉**
