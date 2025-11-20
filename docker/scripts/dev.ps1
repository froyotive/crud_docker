# PowerShell Development Script for Windows
# Run with: .\docker\scripts\dev.ps1

Write-Host "🛠️  Starting development environment..." -ForegroundColor Green
Write-Host ""

# Copy .env.docker to .env if not exists
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file..." -ForegroundColor Yellow
    Copy-Item ".env.docker" -Destination ".env" -Force
    Write-Host "✅ Environment file created" -ForegroundColor Green
}

# Start containers
Write-Host ""
Write-Host "🐳 Starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d

# Wait for MySQL
Write-Host ""
Write-Host "⏳ Waiting for MySQL..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Install dependencies if vendor doesn't exist
if (-not (Test-Path "vendor")) {
    Write-Host ""
    Write-Host "📦 Installing Composer dependencies..." -ForegroundColor Yellow
    docker-compose exec app composer install
}

# Install node_modules if doesn't exist
if (-not (Test-Path "node_modules")) {
    Write-Host ""
    Write-Host "📦 Installing NPM dependencies..." -ForegroundColor Yellow
    docker-compose run --rm node npm install --legacy-peer-deps
}

# Run migrations
Write-Host ""
Write-Host "🗄️  Running migrations..." -ForegroundColor Yellow
docker-compose exec app php artisan migrate

# Seed database
Write-Host ""
Write-Host "🌱 Seeding database..." -ForegroundColor Yellow
docker-compose exec app php artisan db:seed --class=AdminUserSeeder

# Build assets
Write-Host ""
Write-Host "🎨 Building assets..." -ForegroundColor Yellow
docker-compose run --rm node npm run build

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "✅ Development environment ready!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Application: http://localhost:8000" -ForegroundColor Cyan
Write-Host "🔐 Admin Panel: http://localhost:8000/admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Default accounts:" -ForegroundColor Yellow
Write-Host "   👤 Admin: admin@example.com / password" -ForegroundColor White
Write-Host "   👤 User:  user@example.com / password" -ForegroundColor White
Write-Host ""
Write-Host "🔥 To watch for asset changes, run:" -ForegroundColor Yellow
Write-Host "   docker-compose run --rm node npm run dev" -ForegroundColor Gray
Write-Host ""
