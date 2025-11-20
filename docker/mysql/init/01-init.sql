-- MySQL initialization script
-- This script runs when the database is first created

-- Ensure utf8mb4 charset
ALTER DATABASE crud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Optional: Create additional database users if needed
-- CREATE USER 'app_user'@'%' IDENTIFIED BY 'password';
-- GRANT ALL PRIVILEGES ON crud.* TO 'app_user'@'%';
-- FLUSH PRIVILEGES;
