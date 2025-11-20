# 🚀 DOCKER QUICK START - Deploy in 2 Minutes

## ⚡ ONE-CLICK DEPLOYMENT

### From Windows (Recommended):

```powershell
# Edit server IP first, then run:
.\quick-deploy-to-server.ps1
```

That's it! Script will:
- ✅ Upload all files to server
- ✅ Build Docker images
- ✅ Start all containers
- ✅ Run migrations
- ✅ Configure everything

**Done!** Access at `http://YOUR_SERVER_IP:8000`

---

### From Linux Server:

```bash
# 1. Transfer files (from Windows)
scp docker-compose.yml Dockerfile final-deploy.sh azureuser@SERVER_IP:/home/azureuser/crud_docker/

# 2. SSH to server
ssh azureuser@SERVER_IP

# 3. Deploy
cd /home/azureuser/crud_docker
chmod +x final-deploy.sh
./final-deploy.sh
```

**Done!** Access at `http://localhost:8000`

---

## 🎯 WHAT YOU GET

- ✅ Laravel 11 with Jetstream
- ✅ Filament Admin Panel
- ✅ Role-based Authentication
- ✅ MySQL 8.0 Database
- ✅ Nginx Web Server
- ✅ PHP 8.3-FPM
- ✅ All dependencies installed
- ✅ Migrations applied
- ✅ Production ready

---

## 📝 ENVIRONMENT VARIABLES

Create `.env` file or export these:

```bash
DB_PASSWORD=secret_password
APP_KEY=base64:Ag72T2W8a/09K0gO+wrGHcwp+CFkKsGsHWlpWM+X9H4=
APP_PORT=8000
```

---

## ✅ VERIFY DEPLOYMENT

```bash
# Check containers
docker ps --filter "name=crud_"

# Check logs
docker compose logs -f

# Test connection
curl http://localhost:8000
```

Expected: 3 containers running (mysql, app, nginx)

---

## 🔧 USEFUL COMMANDS

```bash
# View logs
docker compose logs -f app

# Restart
docker compose restart

# Stop
docker compose down

# Shell access
docker exec -it crud_app bash

# Run artisan
docker exec crud_app php artisan migrate
```

---

## 🐛 TROUBLESHOOTING

### Containers not starting?
```bash
docker compose logs
```

### MySQL connection error?
```bash
docker logs crud_mysql
# Wait 40 seconds after start
```

### Permission errors?
```bash
docker exec crud_app chown -R www-data:www-data storage bootstrap/cache
```

### Full reset?
```bash
docker compose down -v
./final-deploy.sh
```

---

## 📚 DOCUMENTATION

- **Full Guide**: See `FINAL_DEPLOYMENT.md`
- **Summary**: See `DEPLOYMENT_READY_SUMMARY.txt`
- **Fixes Applied**: See conversation summary

---

## 🎉 SUCCESS!

If you see this, deployment succeeded:
- ✅ 3 containers running
- ✅ HTTP 200 or 302 response
- ✅ Login page accessible
- ✅ No errors in logs

**Happy coding!** 🚀

---

## 📞 NEED HELP?

1. Check logs: `docker compose logs -f`
2. Read full guide: `FINAL_DEPLOYMENT.md`
3. Review fixes: Check conversation summary
4. Reset and retry: `docker compose down -v && ./final-deploy.sh`
