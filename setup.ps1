$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================"
Write-Host "       CLOUD SECURITY LAB v2"
Write-Host "       Windows Setup"
Write-Host "============================================"
Write-Host ""

function Test-Command($Command) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Write-Host "[X] $Command bulunamadi." -ForegroundColor Red
        return $false
    }

    Write-Host "[✓] $Command bulundu." -ForegroundColor Green
    return $true
}

Write-Host "[1/5] Gereksinimler kontrol ediliyor..."
Write-Host ""

if (-not (Test-Command "docker")) {
    Write-Host ""
    Write-Host "Docker Desktop gerekli." -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop/"
    exit 1
}

if (-not (Test-Command "terraform")) {
    Write-Host ""
    Write-Host "Terraform gerekli." -ForegroundColor Yellow
    Write-Host "https://developer.hashicorp.com/terraform/install"
    exit 1
}

Write-Host ""
Write-Host "[2/5] Docker kontrol ediliyor..."

try {
    docker info | Out-Null
}
catch {
    Write-Host ""
    Write-Host "[X] Docker Desktop calismiyor!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Docker Desktop'i ac ve tekrar dene."
    exit 1
}

Write-Host "[✓] Docker Desktop aktif." -ForegroundColor Green

Write-Host ""
Write-Host "[3/5] Docker Compose kontrol ediliyor..."

docker compose version

Write-Host ""
Write-Host "[4/5] Cloud Security Lab baslatiliyor..."

docker compose up -d

Write-Host ""
Write-Host "[5/5] Servisler kontrol ediliyor..."

$ready = $false

for ($i = 0; $i -lt 30; $i++) {

    try {
        $response = Invoke-WebRequest `
            -Uri "http://localhost:4566/_localstack/health" `
            -UseBasicParsing `
            -TimeoutSec 2

        if ($response.StatusCode -eq 200) {
            $ready = $true
            break
        }
    }
    catch {}

    Start-Sleep -Seconds 2
}

if (-not $ready) {
    Write-Host "[X] LocalStack baslatilamadi." -ForegroundColor Red
    docker compose logs localstack
    exit 1
}

Write-Host ""
Write-Host "============================================"
Write-Host "       LAB HAZIR!"
Write-Host "============================================"
Write-Host ""
Write-Host "CTF Interface:"
Write-Host "http://localhost:8090"
Write-Host ""
Write-Host "LocalStack:"
Write-Host "http://localhost:4566"
Write-Host ""
Write-Host "============================================"
