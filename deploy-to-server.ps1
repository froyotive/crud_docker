# PowerShell script to copy updated files to server
# Run this from your local Windows machine

Write-Host "🚀 Deploying updated files to server..." -ForegroundColor Green
Write-Host ""

# Configuration - UPDATE THESE VALUES
$SERVER_USER = "azureuser"
$SERVER_IP = "YOUR_SERVER_IP"  # Replace with your actual server IP
$SERVER_PATH = "/home/azureuser/crud_docker"

# Check if server info is configured
if ($SERVER_IP -eq "YOUR_SERVER_IP") {
    Write-Host "❌ Please edit this script and set your SERVER_IP" -ForegroundColor Red
    Write-Host "   Open: deploy-to-server.ps1" -ForegroundColor Yellow
    Write-Host "   Change: `$SERVER_IP = `"YOUR_SERVER_IP`"" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Files to upload:" -ForegroundColor Yellow
Write-Host "   - docker-compose.yml" -ForegroundColor Gray
Write-Host "   - Dockerfile" -ForegroundColor Gray
Write-Host "   - docker/scripts/" -ForegroundColor Gray
Write-Host ""

# Check if SCP is available
$scpAvailable = Get-Command scp -ErrorAction SilentlyContinue
if (-not $scpAvailable) {
    Write-Host "❌ SCP not found. Please install OpenSSH Client:" -ForegroundColor Red
    Write-Host "   Settings → Apps → Optional Features → Add OpenSSH Client" -ForegroundColor Yellow
    exit 1
}

Write-Host "📤 Uploading files to server..." -ForegroundColor Yellow

# Upload docker-compose.yml
Write-Host "   → docker-compose.yml" -ForegroundColor Gray
scp docker-compose.yml "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/"

# Upload Dockerfile
Write-Host "   → Dockerfile" -ForegroundColor Gray
scp Dockerfile "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/"

# Upload deployment scripts
Write-Host "   → docker/scripts/" -ForegroundColor Gray
scp -r docker/scripts/* "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/docker/scripts/"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Files uploaded successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔧 Now run on your server:" -ForegroundColor Cyan
    Write-Host "   ssh ${SERVER_USER}@${SERVER_IP}" -ForegroundColor Yellow
    Write-Host "   cd ${SERVER_PATH}" -ForegroundColor Yellow
    Write-Host "   docker compose down -v" -ForegroundColor Yellow
    Write-Host "   ./docker/scripts/deploy.sh" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "❌ Upload failed. Check your connection and try again." -ForegroundColor Red
}
