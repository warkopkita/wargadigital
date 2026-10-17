#!/bin/bash
# ==============================================================================
# SKRIP OTOMATISASI DEPLOY SERVER VPS (Ubuntu 20.04 / 22.04 / 24.04 LTS)
# Aplikasi Warga Digital (Backend Laravel + Web Admin Vue + Mobile Flutter Web)
# ==============================================================================

set -e

echo "🚀 Memulai instalasi sistem Warga Digital di VPS..."

# 1. Update paket OS & install dependencies
sudo apt-get update -y
sudo apt-get install -y curl git ufw docker.io docker-compose

# 2. Aktifkan dan jalankan Docker
sudo systemctl enable docker
sudo systemctl start docker

# 3. Konfigurasi Firewall dasar
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8000/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 5173/tcp
sudo ufw --force enable

# 4. Siapkan direktori backend storage dan permissions
if [ -d "backend" ]; then
    echo "📁 Menyiapkan folder backend storage..."
    mkdir -p backend/storage/framework/sessions
    mkdir -p backend/storage/framework/views
    mkdir -p backend/storage/framework/cache
    mkdir -p backend/storage/logs
    chmod -R 777 backend/storage backend/bootstrap/cache
fi

# 5. Jalankan Docker Compose
echo "🐳 Menjalankan seluruh container Docker..."
docker-compose down || true
docker-compose up -d --build

echo "=========================================================="
echo "✅ DEPLOYMENT BERHASIL!"
echo "Semua kontainer aktif berjalan di latar belakang:"
docker-compose ps
echo "=========================================================="
echo "Akses sistem:"
echo "1. Web Dashboard Pengurus: http://IP_VPS_ANDA:5173 atau http://IP_VPS_ANDA"
echo "2. Aplikasi Mobile Warga : http://IP_VPS_ANDA:8080"
echo "3. Backend API           : http://IP_VPS_ANDA:8000"
echo "=========================================================="
