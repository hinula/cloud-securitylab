#!/bin/bash
# =============================================================
# Cloud Security Lab - Otomatik Kurulum ve Onarım Scripti
# =============================================================

set -e


if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  echo "[*] Windows ortam tespiti. Dosya biçimleri (LF) formatına dönüştürülüyor..."
  sed -i 's/\r$//' setup.sh
  sed -i 's/\r$//' attack/*.sh 2>/dev/null || true
fi

echo "╔══════════════════════════════════════════╗"
echo "║    Cloud Security Lab - Kurulum Başlıyor ║"
echo "╚══════════════════════════════════════════╝"
echo ""

check_requirement() {
  if ! command -v $1 &> /dev/null; then
    echo "[!] $1 sistemde bulunamadı. Lütfen kurun: $2"
    exit 1
  fi
  echo "[✓] Bağımlılık doğrulandı: $1"
}

echo "[*] Sistem gereksinimleri kontrol ediliyor..."
check_requirement docker "https://docs.docker.com/get-docker/"
check_requirement docker-compose "https://docs.docker.com/compose/install/"
check_requirement terraform "https://developer.hashicorp.com/terraform/install"
check_requirement aws "https://aws.amazon.com/cli/"
echo ""

echo "[*] LocalStack Docker konteyneri ayağa kaldırılıyor..."
docker-compose up -d localstack

echo "[*] Bulut API servislerinin hazır olması bekleniyor..."
until curl -s http://localhost:4566/_localstack/health | grep -q '"s3": "running"'; do
  echo "    Hizmetler kontrol ediliyor, bekleniyor..."
  sleep 3
done
echo "[✓] LocalStack emülasyon motoru aktif!"
echo ""

echo "[*] Terraform IaC altyapısı tetikleniyor..."
cd terraform
terraform init -upgrade
echo ""
echo "[*] Bulut topolojisi oluşturuluyor (terraform apply)..."
terraform apply -auto-approve
echo ""

cd ..
echo "[*] Zafiyetli test konteyneri entegre ediliyor..."
docker-compose up -d vulnerable-app
echo ""

chmod +x attack/*.sh

echo "╔══════════════════════════════════════════╗"
echo "║        Laboratuvar Ortamı Hazır!         ║"
echo "╠══════════════════════════════════════════╣"
echo "║  Oyun Paneli / Arayüz: http://localhost:8080║"
echo "║  LocalStack API Hattı: http://localhost:4566║"
