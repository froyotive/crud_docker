# PowerShell Deployment Script for Windows
# Run with: .\docker\scripts\deploy.ps1

Write-Host "🚀 Starting deployment..." -ForegroundColor Green
Write-Host ""

# Check if Docker is running
Write-Host "📦 Checking Docker..." -ForegroundColor Yellow
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Copy .env.docker to .env
Write-Host ""
Write-Host "📝 Setting up environment..." -ForegroundColor Yellow
if (Test-Path ".env.docker") {
    Copy-Item ".env.docker" -Destination ".env" -Force
    Write-Host "✅ Environment file created" -ForegroundColor Green
} else {
    Write-Host "❌ .env.docker not found!" -ForegroundColor Red
    exit 1
}

# Stop existing containers
Write-Host ""
Write-Host "🛑 Stopping existing containers..." -ForegroundColor Yellow
docker-compose down

# Build and start containers
Write-Host ""
Write-Host "🐳 Building Docker containers..." -ForegroundColor Yellow
docker-compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build containers" -ForegroundColor Red
    exit 1
}

# Wait for MySQL to be ready
Write-Host ""
Write-Host "⏳ Waiting for MySQL to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Check if MySQL is healthy
Write-Host "🔍 Checking MySQL health..." -ForegroundColor Yellow
$maxRetries = 10
$retryCount = 0
$mysqlReady = $false

while ($retryCount -lt $maxRetries) {
    $status = docker-compose ps mysql --format json | ConvertFrom-Json
    if ($status.Health -eq "healthy") {
        $mysqlReady = $true
        break
    }
    Write-Host "Retry $($retryCount + 1)/$maxRetries..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
    $retryCount++
}

if (-not $mysqlReady) {
    Write-Host "❌ MySQL failed to become healthy" -ForegroundColor Red
    docker-compose logs mysql
    exit 1
}

Write-Host "✅ MySQL is ready" -ForegroundColor Green

# Run migrations
Write-Host ""
Write-Host "🗄️  Running migrations..." -ForegroundColor Yellow
docker-compose exec -T app php artisan migrate --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Migration failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Migrations completed" -ForegroundColor Green

# Seed database
Write-Host ""
Write-Host "🌱 Seeding database..." -ForegroundColor Yellow
docker-compose exec -T app php artisan db:seed --class=AdminUserSeeder --force

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database seeded" -ForegroundColor Green
} else {
    Write-Host "⚠️  Seeding failed (may already exist)" -ForegroundColor Yellow
}

# Clear and cache configuration
Write-Host ""
Write-Host "🧹 Optimizing application..." -ForegroundColor Yellow
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache

Write-Host "✅ Optimization completed" -ForegroundColor Green

# Set permissions
Write-Host ""
Write-Host "🔐 Setting permissions..." -ForegroundColor Yellow
docker-compose exec -T app chown -R www-data:www-data /var/www/html/storage
docker-compose exec -T app chown -R www-data:www-data /var/www/html/bootstrap/cache
Write-Host "✅ Permissions set" -ForegroundColor Green

# Display status
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Application is running at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "🔐 Admin Panel: http://localhost:8000/admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Default accounts:" -ForegroundColor Yellow
Write-Host "   👤 Admin: admin@example.com / password" -ForegroundColor White
Write-Host "   👤 User:  user@example.com / password" -ForegroundColor White
Write-Host ""
Write-Host "📝 Useful commands:" -ForegroundColor Yellow
Write-Host "   docker-compose ps          # Check services status" -ForegroundColor Gray
Write-Host "   docker-compose logs -f     # View logs" -ForegroundColor Gray
Write-Host "   docker-compose down        # Stop services" -ForegroundColor Gray
Write-Host ""
