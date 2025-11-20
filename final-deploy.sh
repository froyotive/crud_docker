#!/bin/bash
#######################################
# Final Deployment Script
# Ready for Production on Linux Server
#######################################

set -e

echo "🚀 Starting Final Deployment..."
echo "================================"

# Detect Docker Compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
    echo "✅ Using Docker Compose V2 (docker compose)"
elif docker-compose --version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
    echo "✅ Using Docker Compose V1 (docker-compose)"
else
    echo "❌ Docker Compose is not installed."
    exit 1
fi

# Stop and remove existing containers
echo ""
echo "🛑 Stopping existing containers..."
$DOCKER_COMPOSE down -v

# Remove old images to force rebuild
echo ""
echo "🧹 Cleaning up old images..."
docker rmi crud_app:latest 2>/dev/null || true

# Build fresh images
echo ""
echo "🔨 Building Docker images..."
$DOCKER_COMPOSE build --no-cache

# Start services
echo ""
echo "⏳ Starting services (this may take a while)..."
$DOCKER_COMPOSE up -d

# Wait for MySQL to be ready
echo ""
echo "⏰ Waiting for MySQL to initialize (40 seconds)..."
sleep 40

# Check if MySQL is ready
echo ""
echo "🔍 Checking MySQL connection..."
for i in {1..10}; do
    if docker exec crud_mysql mysql -uroot -p${DB_PASSWORD:-secret_password} -e "SELECT 1;" &> /dev/null; then
        echo "✅ MySQL is ready!"
        break
    else
        echo "   Attempt $i/10 - MySQL not ready yet, waiting..."
        sleep 5
    fi
    
    if [ $i -eq 10 ]; then
        echo "❌ MySQL failed to start after 10 attempts"
        exit 1
    fi
done

# Run Laravel migrations
echo ""
echo "📊 Running database migrations..."
docker exec crud_app php artisan migrate --force

# Clear and cache Laravel configs
echo ""
echo "🔧 Optimizing Laravel..."
docker exec crud_app php artisan config:cache
docker exec crud_app php artisan route:cache
docker exec crud_app php artisan view:cache

# Set proper permissions
echo ""
echo "🔐 Setting file permissions..."
docker exec crud_app chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker exec crud_app chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Show running containers
echo ""
echo "📋 Running containers:"
echo "====================="
docker ps --filter "name=crud_"

# Show logs from app container
echo ""
echo "📝 Application logs (last 20 lines):"
echo "====================================="
docker logs crud_app --tail=20

# Check application health
echo ""
echo "🏥 Checking application health..."
sleep 5

APP_PORT=${APP_PORT:-8000}
if curl -f -s -o /dev/null -w "%{http_code}" http://localhost:$APP_PORT > /dev/null 2>&1; then
    HTTP_CODE=$(curl -f -s -o /dev/null -w "%{http_code}" http://localhost:$APP_PORT)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        echo "✅ Application is responding (HTTP $HTTP_CODE)"
    else
        echo "⚠️  Application responded with HTTP $HTTP_CODE"
    fi
else
    echo "⚠️  Could not check application health (curl might not be installed)"
fi

echo ""
echo "================================"
echo "✅ Deployment Complete!"
echo "================================"
echo ""
echo "📍 Application URL: http://localhost:$APP_PORT"
echo ""
echo "🔍 Useful commands:"
echo "   View logs:        $DOCKER_COMPOSE logs -f"
echo "   Restart:          $DOCKER_COMPOSE restart"
echo "   Stop:             $DOCKER_COMPOSE down"
echo "   Enter container:  docker exec -it crud_app bash"
echo ""
echo "🎉 Happy coding!"
