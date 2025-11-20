# 🚀 Final Deployment Guide - Ready for Production

## ✅ PRE-DEPLOYMENT CHECKLIST

Semua issue telah diperbaiki:
- ✅ PHP 8.3 upgraded
- ✅ Missing PHP extensions (zip, intl) installed
- ✅ Docker Compose V2 compatibility
- ✅ MySQL configuration fixed (removed conflicting MYSQL_USER)
- ✅ Health check issues resolved
- ✅ All environment variables configured

## 📋 QUICK DEPLOYMENT STEPS

### Option 1: Deploy dari Windows ke Server (RECOMMENDED)

```powershell
# 1. Transfer files ke server
scp docker-compose.yml Dockerfile final-deploy.sh azureuser@<SERVER_IP>:/home/azureuser/crud_docker/

# 2. SSH ke server
ssh azureuser@<SERVER_IP>

# 3. Navigate to project directory
cd /home/azureuser/crud_docker

# 4. Make script executable
chmod +x final-deploy.sh

# 5. Set environment variables (if not in .env)
export DB_PASSWORD="your_secure_password"
export APP_PORT=8000

# 6. Run deployment
./final-deploy.sh
```

### Option 2: Deploy Langsung di Server

```bash
# 1. SSH ke server
ssh azureuser@<SERVER_IP>

# 2. Navigate to project
cd /home/azureuser/crud_docker

# 3. Pull latest changes (if using Git)
git pull origin main

# 4. Run deployment script
chmod +x final-deploy.sh
./final-deploy.sh
```

## 🔧 DEPLOYMENT SCRIPT FEATURES

Script `final-deploy.sh` akan otomatis:
1. ✅ Detect Docker Compose V1 or V2
2. ✅ Stop dan remove existing containers
3. ✅ Clean old Docker images
4. ✅ Build fresh images with `--no-cache`
5. ✅ Start all services
6. ✅ Wait 40 seconds for MySQL initialization
7. ✅ Verify MySQL connection (10 retries)
8. ✅ Run Laravel migrations
9. ✅ Cache Laravel configs (config, route, view)
10. ✅ Set proper file permissions
11. ✅ Health check application
12. ✅ Show container status and logs

## 📝 ENVIRONMENT VARIABLES

Pastikan variabel berikut sudah diset di `.env` atau export di terminal:

```bash
# Required
DB_PASSWORD=your_secure_password
APP_KEY=base64:Ag72T2W8a/09K0gO+wrGHcwp+CFkKsGsHWlpWM+X9H4=

# Optional (with defaults)
APP_PORT=8000
DB_DATABASE=crud
DB_PORT=3306
APP_ENV=production
APP_DEBUG=false
```

## 🔍 POST-DEPLOYMENT VERIFICATION

### 1. Check Container Status
```bash
docker ps --filter "name=crud_"
```

Expected output:
```
CONTAINER ID   IMAGE         STATUS    PORTS                    NAMES
xxxx           crud_app      Up        9000/tcp                crud_app
xxxx           nginx:alpine  Up        0.0.0.0:8000->80/tcp    crud_nginx
xxxx           mysql:8.0     Up        0.0.0.0:3306->3306/tcp  crud_mysql
```

### 2. Check Application Logs
```bash
docker logs crud_app --tail=50
```

### 3. Check MySQL Connection
```bash
docker exec crud_mysql mysql -uroot -p${DB_PASSWORD} -e "SHOW DATABASES;"
```

### 4. Test Application
```bash
# From server
curl -I http://localhost:8000

# From browser
http://<SERVER_IP>:8000
```

## 🐛 TROUBLESHOOTING

### Container tidak start
```bash
# Check logs
docker compose logs

# Check specific container
docker logs crud_app
docker logs crud_mysql
docker logs crud_nginx
```

### MySQL connection error
```bash
# Enter app container
docker exec -it crud_app bash

# Test MySQL connection
php artisan tinker
> DB::connection()->getPdo();
```

### Permission errors
```bash
docker exec crud_app chown -R www-data:www-data /var/www/html/storage
docker exec crud_app chmod -R 775 /var/www/html/storage
```

### Rebuild from scratch
```bash
docker compose down -v
docker rmi crud_app:latest
./final-deploy.sh
```

## 🎯 USEFUL COMMANDS

```bash
# View live logs
docker compose logs -f

# Restart services
docker compose restart

# Stop all services
docker compose down

# Enter app container
docker exec -it crud_app bash

# Run artisan commands
docker exec crud_app php artisan migrate
docker exec crud_app php artisan cache:clear

# Database backup
docker exec crud_mysql mysqldump -uroot -p${DB_PASSWORD} crud > backup.sql

# Database restore
docker exec -i crud_mysql mysql -uroot -p${DB_PASSWORD} crud < backup.sql
```

## 🔐 SECURITY RECOMMENDATIONS

1. **Change default passwords**
   ```bash
   # In .env file
   DB_PASSWORD=<use_strong_password>
   APP_KEY=<generate_new_key>
   ```

2. **Configure firewall**
   ```bash
   sudo ufw allow 8000/tcp
   sudo ufw allow 22/tcp
   sudo ufw enable
   ```

3. **Use HTTPS** (production)
   - Setup nginx reverse proxy with SSL
   - Use Let's Encrypt for free SSL certificates

4. **Disable debug mode**
   ```bash
   APP_DEBUG=false
   APP_ENV=production
   ```

## 📊 MONITORING

### Check resource usage
```bash
docker stats
```

### Check disk usage
```bash
docker system df
```

### Clean unused resources
```bash
docker system prune -a
```

## ✅ SUCCESS INDICATORS

Deployment berhasil jika:
- ✅ Semua 3 containers running (app, nginx, mysql)
- ✅ Application accessible via http://localhost:8000
- ✅ MySQL connection working
- ✅ Migrations completed successfully
- ✅ No error logs in `docker logs crud_app`

## 🎉 NEXT STEPS

1. Test login functionality
2. Test role-based permissions
3. Test Filament admin panel
4. Setup automated backups
5. Configure monitoring/alerting
6. Setup CI/CD pipeline (optional)

---

**🚀 Ready to deploy!** Follow the steps above and your Laravel application will be live in minutes.

**📞 Need help?** Check logs with `docker compose logs -f` and troubleshoot using the commands above.
