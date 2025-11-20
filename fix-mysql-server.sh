#!/bin/bash
# Quick fix script for MySQL health check issue
# Run this on your Linux server

echo "🔧 Fixing docker-compose.yml..."

# Backup existing file
cp docker-compose.yml docker-compose.yml.backup
echo "✅ Backup created: docker-compose.yml.backup"

# Create new docker-compose.yml with correct configuration
cat > docker-compose.yml << 'EOF'
services:
  # MySQL Database
  mysql:
    image: mysql:8.0
    container_name: crud_mysql
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_DATABASE:-crud}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD:-secret_password}
      MYSQL_PASSWORD: ${DB_PASSWORD:-secret_password}
      MYSQL_USER: ${DB_USERNAME:-crud_user}
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/init:/docker-entrypoint-initdb.d
    ports:
      - "${DB_PORT:-3306}:3306"
    networks:
      - crud_network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10
      interval: 10s
      start_period: 30s

  # PHP-FPM Service
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: crud_app
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./:/var/www/html
      - ./docker/php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - crud_network
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      - DB_HOST=mysql
      - DB_DATABASE=${DB_DATABASE:-crud}
      - DB_USERNAME=${DB_USERNAME:-root}
      - DB_PASSWORD=${DB_PASSWORD:-secret_password}
      - APP_ENV=${APP_ENV:-production}
      - APP_DEBUG=${APP_DEBUG:-false}

  # Nginx Service
  nginx:
    image: nginx:alpine
    container_name: crud_nginx
    restart: unless-stopped
    ports:
      - "${APP_PORT:-8000}:80"
    volumes:
      - ./:/var/www/html
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
    networks:
      - crud_network
    depends_on:
      - app

networks:
  crud_network:
    driver: bridge

volumes:
  mysql_data:
    driver: local
EOF

echo "✅ docker-compose.yml updated!"
echo ""
echo "🚀 Now deploying..."
echo ""

# Stop containers and remove volumes
docker compose down -v

# Run deployment
./docker/scripts/deploy.sh
