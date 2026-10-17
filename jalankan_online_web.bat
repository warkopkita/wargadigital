@echo off
chcp 65001 >nul
title ONLINE WEB DASHBOARD PENGURUS - WARGA DIGITAL
echo ================================================================
echo   🌐 ONLINE-KAN WEB DASHBOARD PENGURUS (RT/RW) VIA CLOUDFLARE
echo ================================================================
echo.
echo Menghubungkan Web Dashboard ke jaringan Cloudflare Tunnel...
echo.
echo Tunggu beberapa detik sampai muncul tautan HTTPS resmi di bawah:
echo   https://xxxx.trycloudflare.com
echo.
echo Tautan tersebut bisa langsung Anda buka di browser HP / Laptop dari
echo mana saja lewat jaringan internet (tanpa harus 1 Wi-Fi)!
echo.
echo Tekan Ctrl + C jika ingin menghentikan online demo.
echo ================================================================
echo.

cloudflared tunnel --url http://localhost:5173
pause
