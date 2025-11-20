#!/bin/bash

# Bash Development Setup Script for Linux/Mac
# Make executable: chmod +x docker/scripts/dev.sh
# Run with: ./docker/scripts/dev.sh

echo "🚀 Starting development environment setup..."
echo ""

# Check if Docker is running
echo "📦 Checking Docker..."
if ! docker --version &> /dev/null; then
    echo "❌ Docker is not installed or not running."
    exit 1
fi

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

# Copy .env.docker to .env if not exists
echo ""
echo "📝 Setting up environment..."
if [ ! -f ".env" ]; then
    if [ -f ".env.docker" ]; then
        cp .env.docker .env
        echo "✅ Environment file created from .env.docker"
    else
        echo "❌ .env.docker not found!"
        exit 1
    fi
else
    echo "✅ .env already exists"
fi

# Update .env for development
echo "🔧 Configuring for development..."
sed -i 's/APP_ENV=production/APP_ENV=local/' .env 2>/dev/null || sed -i '' 's/APP_ENV=production/APP_ENV=local/' .env
sed -i 's/APP_DEBUG=false/APP_DEBUG=true/' .env 2>/dev/null || sed -i '' 's/APP_DEBUG=false/APP_DEBUG=true/' .env
echo "✅ Development configuration set"

# Stop existing containers
echo ""
echo "🛑 Stopping existing containers..."
$DOCKER_COMPOSE down

# Build and start containers
echo ""
echo "🐳 Building Docker containers..."
$DOCKER_COMPOSE up -d --build

if [ $? -ne 0 ]; then
    echo "❌ Failed to build containers"
    exit 1
fi

# Wait for MySQL to be ready
echo ""
echo "⏳ Waiting for MySQL to be ready..."
sleep 20

# Check if MySQL is healthy
echo "🔍 Checking MySQL health..."
MAX_RETRIES=10
RETRY_COUNT=0
MYSQL_READY=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if $DOCKER_COMPOSE exec -T mysql mysqladmin ping -h localhost -u root -psecret_password --silent; then
        MYSQL_READY=true
        break
    fi
    echo "Retry $((RETRY_COUNT + 1))/$MAX_RETRIES..."
    sleep 3
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ "$MYSQL_READY" = false ]; then
    echo "❌ MySQL failed to become healthy"
    $DOCKER_COMPOSE logs mysql
    exit 1
fi

echo "✅ MySQL is ready"

# Run migrations
echo ""
echo "🗄️  Running migrations..."
$DOCKER_COMPOSE exec -T app php artisan migrate

if [ $? -ne 0 ]; then
    echo "❌ Migration failed"
    exit 1
fi
echo "✅ Migrations completed"

# Seed database
echo ""
echo "🌱 Seeding database..."
$DOCKER_COMPOSE exec -T app php artisan db:seed --class=AdminUserSeeder

if [ $? -eq 0 ]; then
    echo "✅ Database seeded"
else
    echo "⚠️  Seeding failed (may already exist)"
fi

# Clear caches
echo ""
echo "🧹 Clearing caches..."
$DOCKER_COMPOSE exec -T app php artisan config:clear
$DOCKER_COMPOSE exec -T app php artisan cache:clear
$DOCKER_COMPOSE exec -T app php artisan route:clear
$DOCKER_COMPOSE exec -T app php artisan view:clear

echo "✅ Caches cleared"

# Set permissions
echo ""
echo "🔐 Setting permissions..."
$DOCKER_COMPOSE exec -T app chown -R www-data:www-data /var/www/html/storage
$DOCKER_COMPOSE exec -T app chown -R www-data:www-data /var/www/html/bootstrap/cache
echo "✅ Permissions set"

# Display status
echo ""
echo "============================================================"
echo "✅ Development environment ready!"
echo "============================================================"
echo ""
echo "🌐 Application: http://localhost:8000"
echo "🔐 Admin Panel: http://localhost:8000/admin"
echo ""
echo "📊 Default accounts:"
echo "   👤 Admin: admin@example.com / password"
echo "   👤 User:  user@example.com / password"
echo ""
echo "📝 Development commands:"
echo "   $DOCKER_COMPOSE logs -f app          # Watch application logs"
echo "   $DOCKER_COMPOSE exec app php artisan tinker  # Laravel REPL"
echo "   $DOCKER_COMPOSE exec app bash        # Access container shell"
echo ""
echo "🔄 To rebuild assets:"
echo "   $DOCKER_COMPOSE run --rm node npm run dev"
echo ""
echo "🛑 To stop:"
echo "   $DOCKER_COMPOSE down"
echo ""
