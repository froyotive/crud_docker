# 🔧 MySQL Health Check Fix

**Date**: November 20, 2025  
**Issue**: MySQL container marked as unhealthy, preventing app container from starting

---

## Problem

After successfully building the Docker image with PHP 8.3, deployment failed with:

```bash
dependency failed to start: container crud_mysql is unhealthy
```

### Root Causes

1. **MySQL health check with password authentication**: The healthcheck command was trying to use password authentication which can be problematic
2. **Insufficient startup time**: MySQL needs more time to initialize on first run
3. **Obsolete version attribute**: Docker Compose V2 warned about deprecated `version: '3.8'` attribute

---

## Solution

### 1. Simplified MySQL Health Check

**Before:**
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${DB_PASSWORD:-secret_password}"]
  timeout: 20s
  retries: 10
  interval: 10s
```

**After:**
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  timeout: 20s
  retries: 10
  interval: 10s
  start_period: 30s  # Added: Give MySQL 30 seconds to start
```

**Changes:**
- ✅ Removed password authentication from health check (not needed for ping)
- ✅ Added `start_period: 30s` to give MySQL sufficient initialization time
- ✅ Kept retries and intervals for robust health checking

### 2. Removed Obsolete Version Attribute

**Before:**
```yaml
version: '3.8'

services:
  mysql:
    ...
```

**After:**
```yaml
services:
  mysql:
    ...
```

The `version` attribute is no longer needed in Docker Compose V2 and was causing warnings.

---

## Files Modified

- ✅ `docker-compose.yml` - Updated MySQL health check and removed version attribute

---

## How MySQL Health Check Works

### What is `mysqladmin ping`?

`mysqladmin ping` is a lightweight command that checks if MySQL server is alive and responding. It doesn't require authentication for basic connectivity check.

### Health Check Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `test` | `mysqladmin ping` | Command to test if MySQL is ready |
| `interval` | 10s | Check every 10 seconds |
| `timeout` | 20s | Wait max 20 seconds per check |
| `retries` | 10 | Retry up to 10 times before marking unhealthy |
| `start_period` | 30s | Grace period for MySQL initialization |

### Total Startup Allowance

- **Minimum**: 30 seconds (start_period)
- **Maximum**: 30s + (10 retries × 10s interval) = **130 seconds**

This ensures MySQL has enough time to:
1. Initialize the data directory
2. Create default databases
3. Set up users and permissions
4. Start accepting connections

---

## Testing

### Check MySQL Health Status

```bash
# Check all container statuses
docker compose ps

# Expected output:
# NAME           STATUS
# crud_mysql     Up (healthy)
# crud_app       Up
# crud_nginx     Up
```

### Monitor MySQL Logs

```bash
# Watch MySQL startup in real-time
docker compose logs -f mysql

# Look for:
# [Note] mysqld: ready for connections
```

### Manual Health Check

```bash
# Test the health check command manually
docker compose exec mysql mysqladmin ping -h localhost

# Expected output:
# mysqld is alive
```

---

## Deployment Instructions

Since the `docker-compose.yml` file is updated, you need to apply changes on your server:

### Option 1: Pull from Git (Recommended)

```bash
# On your Linux server
cd /home/azureuser/crud_docker

# Pull latest changes
git pull origin main

# Restart deployment
docker compose down
./docker/scripts/deploy.sh
```

### Option 2: Manual Update

```bash
# On your Linux server
cd /home/azureuser/crud_docker

# Edit docker-compose.yml
nano docker-compose.yml

# Make these changes:
# 1. Remove line: version: '3.8'
# 2. Update MySQL healthcheck to:
#    healthcheck:
#      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
#      timeout: 20s
#      retries: 10
#      interval: 10s
#      start_period: 30s

# Save and run deployment
docker compose down
./docker/scripts/deploy.sh
```

---

## Expected Successful Deployment

```bash
🚀 Starting deployment...

📦 Checking Docker...
✅ Using Docker Compose V2

📝 Setting up environment...
✅ Environment file created

🛑 Stopping existing containers...

🐳 Building Docker containers...
[+] Building 0.5s (22/22) FINISHED  # Fast because image is cached

[+] Running 4/4
 ✔ Network crud_docker_crud_network  Created
 ✔ Container crud_mysql              Healthy    # ← Should show Healthy
 ✔ Container crud_app                Started
 ✔ Container crud_nginx              Started

⏳ Waiting for MySQL to be ready...
✅ MySQL is ready

🗄️  Running migrations...
✅ Migrations completed

🌱 Seeding database...
✅ Database seeded

🧹 Optimizing application...
✅ Optimization completed

🔐 Setting permissions...
✅ Permissions set

============================================================
✅ Deployment completed successfully!
============================================================

🌐 Application is running at: http://localhost:8000
🔐 Admin Panel: http://localhost:8000/admin
```

---

## Troubleshooting

### MySQL Still Unhealthy?

**Check logs:**
```bash
docker compose logs mysql
```

**Common issues:**

1. **Port already in use:**
   ```bash
   # Check if something is using port 3306
   sudo lsof -i :3306
   # Kill the process or change port in .env
   ```

2. **Insufficient memory:**
   ```bash
   # Check available memory
   free -h
   # MySQL needs at least 1GB RAM
   ```

3. **Corrupted data volume:**
   ```bash
   # Remove and recreate volume
   docker compose down -v
   docker compose up -d
   ```

### Container Starts but Exits Immediately

```bash
# Check MySQL error logs
docker compose logs mysql | grep ERROR

# Common: InnoDB initialization failed
# Solution: Remove volume and start fresh
docker compose down -v
docker volume rm crud_docker_mysql_data
docker compose up -d
```

---

## Summary of All Fixes

Throughout this deployment journey, we've fixed:

1. ✅ **Docker Compose V2 compatibility** - Auto-detection in scripts
2. ✅ **Missing PHP extensions** - Added intl and zip
3. ✅ **PHP version** - Upgraded from 8.2 to 8.3
4. ✅ **MySQL health check** - Simplified and added start_period
5. ✅ **Obsolete version attribute** - Removed from docker-compose.yml

---

**Status**: 🟢 READY TO DEPLOY

Run on your server:
```bash
cd /home/azureuser/crud_docker
git pull  # If using Git
./docker/scripts/deploy.sh
```
