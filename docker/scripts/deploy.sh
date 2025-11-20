#!/bin/bash

# Bash Deployment Script for Linux/Mac
# Make executable: chmod +x docker/scripts/deploy.sh
# Run with: ./docker/scripts/deploy.sh

echo "🚀 Starting deployment..."
echo ""

# Check if Docker is running
echo "📦 Checking Docker..."
if ! docker --version &> /dev/null; then
    echo "❌ Docker is not installed or not running."
    exit 1
fi

# Copy .env.docker to .env
echo ""
echo "📝 Setting up environment..."
if [ -f ".env.docker" ]; then
    cp .env.docker .env
    echo "✅ Environment file created"
else
    echo "❌ .env.docker not found!"
    exit 1
fi

# Stop existing containers
echo ""
echo "🛑 Stopping existing containers..."
docker-compose down

# Build and start containers
echo ""
echo "🐳 Building Docker containers..."
docker-compose up -d --build

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
    if docker-compose exec -T mysql mysqladmin ping -h localhost -u root -psecret_password --silent; then
        MYSQL_READY=true
        break
    fi
    echo "Retry $((RETRY_COUNT + 1))/$MAX_RETRIES..."
    sleep 3
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ "$MYSQL_READY" = false ]; then
    echo "❌ MySQL failed to become healthy"
    docker-compose logs mysql
    exit 1
fi

echo "✅ MySQL is ready"

# Run migrations
echo ""
echo "🗄️  Running migrations..."
docker-compose exec -T app php artisan migrate --force

if [ $? -ne 0 ]; then
    echo "❌ Migration failed"
    exit 1
fi
echo "✅ Migrations completed"

# Seed database
echo ""
echo "🌱 Seeding database..."
docker-compose exec -T app php artisan db:seed --class=AdminUserSeeder --force

if [ $? -eq 0 ]; then
    echo "✅ Database seeded"
else
    echo "⚠️  Seeding failed (may already exist)"
fi

# Clear and cache configuration
echo ""
echo "🧹 Optimizing application..."
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache

echo "✅ Optimization completed"

# Set permissions
echo ""
echo "🔐 Setting permissions..."
docker-compose exec -T app chown -R www-data:www-data /var/www/html/storage
docker-compose exec -T app chown -R www-data:www-data /var/www/html/bootstrap/cache
echo "✅ Permissions set"

# Display status
echo ""
echo "============================================================"
echo "✅ Deployment completed successfully!"
echo "============================================================"
echo ""
echo "🌐 Application is running at: http://localhost:8000"
echo "🔐 Admin Panel: http://localhost:8000/admin"
echo ""
echo "📊 Default accounts:"
echo "   👤 Admin: admin@example.com / password"
echo "   👤 User:  user@example.com / password"
echo ""
echo "📝 Useful commands:"
echo "   docker-compose ps          # Check services status"
echo "   docker-compose logs -f     # View logs"
echo "   docker-compose down        # Stop services"
echo ""
