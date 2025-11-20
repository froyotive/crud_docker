# Quick Deploy to Server Script
# Usage: .\quick-deploy-to-server.ps1

param(
    [string]$ServerIP = "your_server_ip",
    [string]$ServerUser = "azureuser",
    [string]$ProjectPath = "/home/azureuser/crud_docker"
)

Write-Host "🚀 Quick Deploy to Server" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if required files exist
$requiredFiles = @(
    "docker-compose.yml",
    "Dockerfile",
    "final-deploy.sh"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "❌ Required file not found: $file" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ All required files found" -ForegroundColor Green
Write-Host ""

# Prompt for server IP if not provided
if ($ServerIP -eq "your_server_ip") {
    $ServerIP = Read-Host "Enter server IP address"
}

$ServerAddress = "${ServerUser}@${ServerIP}"

Write-Host "📡 Deploying to: $ServerAddress" -ForegroundColor Yellow
Write-Host "📂 Project path: $ProjectPath" -ForegroundColor Yellow
Write-Host ""

# Upload files to server
Write-Host "📤 Uploading files to server..." -ForegroundColor Cyan
try {
    scp docker-compose.yml Dockerfile final-deploy.sh "${ServerAddress}:${ProjectPath}/"
    Write-Host "✅ Files uploaded successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to upload files: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Connecting to server and deploying..." -ForegroundColor Cyan
Write-Host ""

# SSH commands to execute on server
$sshCommands = @"
cd $ProjectPath && \
chmod +x final-deploy.sh && \
echo '🚀 Starting deployment...' && \
./final-deploy.sh
"@

# Execute deployment on server
try {
    ssh $ServerAddress $sshCommands
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "✅ Deployment Complete!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access your application at: http://${ServerIP}:8000" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Deployment failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 Check server logs with:" -ForegroundColor Yellow
    Write-Host "   ssh $ServerAddress 'cd $ProjectPath && docker compose logs'" -ForegroundColor Gray
    exit 1
}

Write-Host "💡 Useful commands:" -ForegroundColor Yellow
Write-Host "   Connect to server:  ssh $ServerAddress" -ForegroundColor Gray
Write-Host "   View logs:          ssh $ServerAddress 'cd $ProjectPath && docker compose logs -f'" -ForegroundColor Gray
Write-Host "   Restart:            ssh $ServerAddress 'cd $ProjectPath && docker compose restart'" -ForegroundColor Gray
Write-Host ""
