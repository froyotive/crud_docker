# 🐳 Docker Quick Reference Card

Cheat sheet untuk perintah Docker yang sering digunakan.

---

## 🚀 Deployment Commands

### Production Deployment (Automated)
```powershell
# Windows
.\docker\scripts\deploy.ps1

# Linux/Mac
chmod +x docker/scripts/deploy.sh
./docker/scripts/deploy.sh
```

### Development Setup (Automated)
```powershell
# Windows
.\docker\scripts\dev.ps1
```

---

## 🐳 Docker Compose Commands

### Start & Stop
```powershell
docker-compose up -d              # Start all services in background
docker-compose up -d --build      # Build and start
docker-compose down               # Stop and remove containers
docker-compose down -v            # Stop and remove containers + volumes
docker-compose stop               # Stop services (keep containers)
docker-compose start              # Start stopped services
docker-compose restart            # Restart all services
docker-compose restart app        # Restart specific service
```

### Status & Logs
```powershell
docker-compose ps                 # Show running services
docker-compose logs               # Show all logs
docker-compose logs -f            # Follow logs (real-time)
docker-compose logs -f app        # Follow specific service logs
docker-compose logs --tail=100    # Show last 100 lines
docker-compose logs app --tail=50 # Specific service, last 50 lines
```

### Execute Commands
```powershell
docker-compose exec app bash              # Access app container shell
docker-compose exec mysql bash            # Access MySQL container
docker-compose exec app php artisan list  # Run artisan command
docker-compose run --rm node npm install  # Run one-off command
```

---

## 🎨 Laravel Commands

### Artisan
```powershell
docker-compose exec app php artisan migrate              # Run migrations
docker-compose exec app php artisan migrate:fresh        # Fresh migrations
docker-compose exec app php artisan migrate:rollback     # Rollback migration
docker-compose exec app php artisan db:seed              # Seed database
docker-compose exec app php artisan migrate --seed       # Migrate & seed
docker-compose exec app php artisan tinker               # Laravel REPL
docker-compose exec app php artisan route:list           # List routes
docker-compose exec app php artisan queue:work           # Run queue worker
```

### Cache Management
```powershell
# Clear caches
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

# Build caches (production)
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
docker-compose exec app php artisan optimize
```

### User Management
```powershell
# Create admin user
docker-compose exec app php artisan tinker
>>> \App\Models\User::create(['name' => 'Admin', 'email' => 'admin@test.com', 'password' => bcrypt('password'), 'role' => 'admin']);
>>> exit

# Change password
docker-compose exec app php artisan tinker
>>> $user = \App\Models\User::where('email', 'admin@example.com')->first();
>>> $user->password = bcrypt('new_password');
>>> $user->save();
>>> exit
```

---

## 📦 Dependencies

### Composer
```powershell
docker-compose exec app composer install            # Install dependencies
docker-compose exec app composer update             # Update dependencies
docker-compose exec app composer require package    # Add package
docker-compose exec app composer remove package     # Remove package
docker-compose exec app composer dump-autoload      # Regenerate autoload
```

### NPM/Node
```powershell
docker-compose run --rm node npm install            # Install dependencies
docker-compose run --rm node npm install --legacy-peer-deps
docker-compose run --rm node npm update             # Update dependencies
docker-compose run --rm node npm run build          # Build for production
docker-compose run --rm node npm run dev            # Build for development
```

---

## 🗄️ Database Commands

### MySQL Access
```powershell
# Connect to MySQL
docker-compose exec mysql mysql -u root -p
# Password: secret_password (atau sesuai .env)

# Direct command
docker-compose exec mysql mysql -u root -psecret_password -e "SHOW DATABASES;"
```

### Backup & Restore
```powershell
# Backup database
docker-compose exec mysql mysqldump -u root -psecret_password crud > backup.sql

# Backup dengan timestamp (Windows)
$date = Get-Date -Format "yyyyMMdd_HHmmss"
docker-compose exec mysql mysqldump -u root -psecret_password crud > "backup_$date.sql"

# Restore database
Get-Content backup.sql | docker-compose exec -T mysql mysql -u root -psecret_password crud
```

### MySQL Queries
```sql
-- Dalam MySQL CLI
SHOW DATABASES;
USE crud;
SHOW TABLES;
SELECT * FROM users;
DESCRIBE users;

-- Check users dan roles
SELECT id, name, email, role, created_at FROM users;

-- Find admins
SELECT * FROM users WHERE role = 'admin';

-- Count by role
SELECT role, COUNT(*) as total FROM users GROUP BY role;
```

---

## 🔧 Maintenance

### Rebuild Everything
```powershell
# Full rebuild
docker-compose down
docker-compose up -d --build --force-recreate

# With fresh database
docker-compose down -v
docker-compose up -d --build
docker-compose exec app php artisan migrate --seed
```

### Fix Permissions
```powershell
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Clean Up Docker
```powershell
# Remove unused containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a
```

---

## 📊 Monitoring

### Resource Usage
```powershell
docker stats                      # All containers
docker stats crud_app             # Specific container
docker stats --no-stream          # One-time snapshot
```

### Disk Usage
```powershell
docker system df                  # Overview
docker system df -v               # Detailed
```

### Container Inspection
```powershell
docker inspect crud_app           # Full container info
docker inspect crud_mysql         # MySQL container info
docker port crud_nginx            # Port mappings
```

---

## 🐛 Troubleshooting

### Check Container Status
```powershell
docker-compose ps                 # All services
docker ps -a                      # All containers
docker-compose logs app           # App logs
docker-compose logs mysql         # MySQL logs
```

### Restart Services
```powershell
docker-compose restart app        # Restart app
docker-compose restart mysql      # Restart MySQL
docker-compose restart nginx      # Restart Nginx
```

### Debug Mode
```powershell
# Run command in debug mode
docker-compose exec app php -v    # PHP version
docker-compose exec app php -m    # PHP modules

# Check connectivity
docker-compose exec app ping mysql
docker-compose exec app nc -zv mysql 3306
```

### Fix Common Issues
```powershell
# Port already in use
netstat -ano | findstr :8000
# Kill process atau ubah port di .env

# Permission denied
docker-compose exec app chmod -R 775 storage bootstrap/cache

# Assets not loading
docker-compose run --rm node npm run build

# Database connection failed
docker-compose restart mysql
docker-compose exec app php artisan config:clear
```

---

## 🔐 Security

### Generate New Keys
```powershell
# Generate APP_KEY
docker-compose exec app php artisan key:generate

# Generate JWT secret (if using)
docker-compose exec app php artisan jwt:secret
```

### Change Passwords
```powershell
# Update .env
# DB_PASSWORD=new_secure_password
# ADMIN_REGISTRATION_CODE=NewSecureCode

# Restart containers
docker-compose down
docker-compose up -d
```

---

## 🌐 URLs & Access

### Application URLs
- **Web**: http://localhost:8000
- **Admin Panel**: http://localhost:8000/admin
- **Dashboard**: http://localhost:8000/dashboard
- **Register**: http://localhost:8000/register
- **Login**: http://localhost:8000/login

### Default Credentials
- **Admin**: admin@example.com / password
- **User**: user@example.com / password

### MySQL Connection
- **Host**: localhost
- **Port**: 3306
- **Database**: crud
- **Username**: root
- **Password**: secret_password

---

## 📝 Common Workflows

### Deploy New Version
```powershell
# 1. Pull latest code
git pull origin main

# 2. Rebuild
docker-compose down
docker-compose up -d --build

# 3. Migrate
docker-compose exec app php artisan migrate --force

# 4. Cache
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# 5. Build assets
docker-compose run --rm node npm run build
```

### Fresh Install
```powershell
# 1. Setup
copy .env.docker .env

# 2. Start
docker-compose up -d --build

# 3. Wait for MySQL
timeout /t 20

# 4. Setup database
docker-compose exec app php artisan migrate --seed

# 5. Done!
start http://localhost:8000
```

### Development Workflow
```powershell
# 1. Start services
docker-compose up -d

# 2. Watch assets (separate terminal)
docker-compose run --rm node npm run dev

# 3. Code changes...

# 4. Run tests
docker-compose exec app php artisan test

# 5. Check logs
docker-compose logs -f app
```

---

## 🎯 One-Liner Commands

```powershell
# Quick restart
docker-compose restart app; docker-compose logs -f app

# Migrate & seed
docker-compose exec app php artisan migrate:fresh --seed

# Clear all caches
docker-compose exec app php artisan optimize:clear

# Build assets
docker-compose run --rm node npm run build

# Backup DB with timestamp
$d=Get-Date -F "yyyyMMdd_HHmmss"; docker-compose exec mysql mysqldump -u root -psecret_password crud > "backup_$d.sql"

# Check app status
docker-compose ps; docker stats --no-stream
```

---

## 💡 Pro Tips

1. **Always check logs first**: `docker-compose logs -f`
2. **Use `-d` flag** untuk background mode: `docker-compose up -d`
3. **Clear cache** setelah perubahan config: `php artisan config:clear`
4. **Backup database** sebelum major changes
5. **Use `--rm` flag** untuk one-off commands: `docker-compose run --rm`
6. **Monitor resources**: `docker stats` untuk cek memory usage
7. **Version control .env.docker** tapi jangan .env

---

## 🆘 Emergency Commands

### App Completely Broken
```powershell
# Nuclear option - rebuild everything
docker-compose down -v
docker system prune -a
docker-compose up -d --build
docker-compose exec app php artisan migrate:fresh --seed
docker-compose run --rm node npm install --legacy-peer-deps
docker-compose run --rm node npm run build
```

### Database Corrupted
```powershell
# Restore from backup
docker-compose down -v
docker-compose up -d
timeout /t 15
Get-Content backup.sql | docker-compose exec -T mysql mysql -u root -psecret_password crud
```

### Disk Space Full
```powershell
# Clean everything
docker system prune -a --volumes
# Then rebuild
docker-compose up -d --build
```

---

**Print this card and keep it handy! 📋**

**Last Updated**: November 20, 2025
