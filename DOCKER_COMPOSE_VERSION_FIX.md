# Docker Compose Version Compatibility Fix

## Issues Fixed

### 1. Docker Compose Command Not Found

**Error:**
```bash
./docker/scripts/deploy.sh: line 31: docker-compose: command not found
```

**Root Cause:** The deployment scripts were using the older Docker Compose V1 command (`docker-compose`) which is not available on systems with Docker Compose V2 (which uses `docker compose` with a space).

### 2. Missing PHP Extensions

**Error:**
```bash
Problem 1
  - filament/support v3.3.45 requires ext-intl * -> it is missing from your system.
Problem 2
  - openspout/openspout v4.32.0 requires ext-zip * -> it is missing from your system.
```

**Root Cause:** The Dockerfile was missing `intl` and `zip` PHP extensions required by Filament and OpenSpout packages.

## Solution

All deployment scripts now automatically detect which version of Docker Compose is installed and use the appropriate command:

- **Docker Compose V1**: `docker-compose` (hyphenated)
- **Docker Compose V2**: `docker compose` (space-separated)

## Updated Files

### 1. `docker/scripts/deploy.sh` (Linux/Mac)
- Added automatic detection of Docker Compose version
- Uses `$DOCKER_COMPOSE` variable throughout the script
- Works with both V1 and V2

### 2. `docker/scripts/deploy.ps1` (Windows PowerShell)
- Added automatic detection of Docker Compose version
- Uses `$DOCKER_COMPOSE` variable throughout the script
- Works with both V1 and V2

### 3. `docker/scripts/dev.sh` (Linux/Mac Development)
- **NEW FILE** - Previously only Windows (dev.ps1) was available
- Same automatic detection feature
- Configured for development environment

### 4. `Dockerfile` (PHP Extensions)
- Added `libzip-dev` and `libicu-dev` system libraries
- Added `zip` and `intl` PHP extensions
- Extensions now include: pdo_mysql, mbstring, exif, pcntl, bcmath, gd, zip, intl

## How It Works

### Bash Script Detection (deploy.sh / dev.sh)
```bash
# Detect Docker Compose command (V1 vs V2)
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
    echo "✅ Using Docker Compose V2"
elif docker-compose --version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
    echo "✅ Using Docker Compose V1"
else
    echo "❌ Docker Compose is not installed."
    exit 1
fi

# Then use it like:
$DOCKER_COMPOSE up -d --build
$DOCKER_COMPOSE exec app php artisan migrate
```

### PowerShell Script Detection (deploy.ps1)
```powershell
# Detect Docker Compose command (V1 vs V2)
$DOCKER_COMPOSE = ""
docker compose version 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    $DOCKER_COMPOSE = "docker compose"
    Write-Host "✅ Using Docker Compose V2" -ForegroundColor Green
} else {
    docker-compose --version 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $DOCKER_COMPOSE = "docker-compose"
        Write-Host "✅ Using Docker Compose V1" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker Compose is not installed." -ForegroundColor Red
        exit 1
    }
}

# Then use it like:
Invoke-Expression "$DOCKER_COMPOSE up -d --build"
```

### Dockerfile PHP Extensions Fix

**Previous Version (Missing Extensions):**
```dockerfile
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
```

**Updated Version (With intl and zip):**
```dockerfile
# Install system dependencies including intl and zip libraries
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zip \
    unzip \
    nodejs \
    npm

# Install PHP extensions including intl and zip
RUN docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl
```

**Why These Extensions Are Required:**
- `ext-intl`: Required by Filament for internationalization (i18n) features
- `ext-zip`: Required by OpenSpout for reading/writing Excel and CSV files
- Without these extensions, `composer install` will fail during Docker build

## Testing

### Check Your Docker Compose Version

**Linux/Mac:**
```bash
# Try V2 first
docker compose version

# If that fails, try V1
docker-compose --version
```

**Windows PowerShell:**
```powershell
# Try V2 first
docker compose version

# If that fails, try V1
docker-compose --version
```

### Expected Output

**Docker Compose V2:**
```
Docker Compose version v2.23.0
```

**Docker Compose V1:**
```
docker-compose version 1.29.2, build 5becea4c
```

## Deployment Instructions

### For Production (Linux Server)

```bash
# 1. Upload your code to server
git clone <your-repo-url>
cd crud

# 2. Make scripts executable
chmod +x docker/scripts/deploy.sh
chmod +x docker/scripts/dev.sh

# 3. Run deployment
./docker/scripts/deploy.sh
```

The script will automatically:
1. Detect your Docker Compose version
2. Display which version is being used
3. Execute all commands with the correct syntax

### For Development (Local)

**Windows:**
```powershell
.\docker\scripts\dev.ps1
```

**Linux/Mac:**
```bash
chmod +x docker/scripts/dev.sh
./docker/scripts/dev.sh
```

## Manual Commands

If you need to run Docker Compose commands manually, you can check which version you have:

### If you have Docker Compose V2:
```bash
docker compose up -d
docker compose ps
docker compose logs -f
docker compose exec app bash
docker compose down
```

### If you have Docker Compose V1:
```bash
docker-compose up -d
docker-compose ps
docker-compose logs -f
docker-compose exec app bash
docker-compose down
```

## Migration from V1 to V2

Docker Compose V2 is now integrated directly into the Docker CLI. If you're still using V1 and want to upgrade:

### Install Docker Compose V2

**Linux:**
```bash
# Install Docker Compose plugin
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify installation
docker compose version
```

**Windows/Mac:**
Update Docker Desktop to the latest version, which includes Docker Compose V2.

### Uninstall Docker Compose V1 (Optional)

**Linux:**
```bash
# Remove old docker-compose
sudo rm /usr/local/bin/docker-compose

# Or if installed via package manager
sudo apt-get remove docker-compose
```

**Note:** You can keep both versions installed. The scripts will work with either.

## Benefits of This Fix

✅ **Universal Compatibility** - Works on any system with Docker Compose V1 or V2
✅ **Automatic Detection** - No manual configuration needed
✅ **Clear Feedback** - Shows which version is being used
✅ **Future-Proof** - Ready for Docker Compose V2 adoption
✅ **Backwards Compatible** - Still works with older V1 installations

## Troubleshooting

### Error: "docker-compose: command not found" AND "docker compose: command not found"

This means Docker Compose is not installed at all.

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Or download Docker Desktop which includes it
# https://www.docker.com/products/docker-desktop
```

### Scripts still fail after fix

1. Make sure scripts are executable:
   ```bash
   chmod +x docker/scripts/*.sh
   ```

2. Check if Docker daemon is running:
   ```bash
   docker ps
   ```

3. Re-pull the latest changes:
   ```bash
   git pull origin main
   ```

## Additional Resources

- [Docker Compose V2 Documentation](https://docs.docker.com/compose/cli-command/)
- [Migrate to Docker Compose V2](https://docs.docker.com/compose/migrate/)
- [Docker Compose V1 vs V2](https://www.docker.com/blog/announcing-compose-v2-general-availability/)

---

**Updated:** November 20, 2025  
**Issue:** Docker Compose command compatibility  
**Status:** ✅ RESOLVED
