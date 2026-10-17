@echo off
chcp 65001 >nul
title WARGA DIGITAL - MENYALAKAN SEMUA SERVER
echo ================================================================
echo   🚀 MENYALAKAN SELURUH LAYANAN SISTEM WARGA DIGITAL
echo ================================================================
echo.
echo 1. Menyalakan Backend Laravel API (Port 8000)...
start "Backend API (Laravel)" cmd /k "cd /d %~dp0backend && php artisan serve --host=0.0.0.0 --port=8000"

echo 2. Menyalakan Web Dashboard Pengurus (Port 5173)...
start "Web Dashboard (Vue)" cmd /k "cd /d %~dp0web && npx vite --host 0.0.0.0 --port 5173"

echo 3. Menyalakan Aplikasi Mobile Warga (Port 8080)...
start "Aplikasi Mobile Warga" cmd /k "cd /d %~dp0 && node serve_mobile.js"

echo.
echo ================================================================
echo ✅ SELURUH SERVER LOKAL TELAH DIAKTIFKAN!
echo.
echo Akses Komputer Lokal:
echo - Web Dashboard Pengurus : http://localhost:5173
echo - Aplikasi Mobile Warga  : http://localhost:8080
echo - Backend REST API       : http://localhost:8000
echo.
echo Untuk meng-onlinekan ke internet (Cloudflare HTTPS gratis):
echo - Klik ganda: jalankan_online_web.bat    (Untuk Web Dashboard)
echo - Klik ganda: jalankan_online_mobile.bat (Untuk Aplikasi Warga)
echo ================================================================
pause
