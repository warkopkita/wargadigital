@echo off
chcp 65001 >nul
title ONLINE APLIKASI WARGA - WARGA DIGITAL
echo ================================================================
echo   📱 ONLINE-KAN APLIKASI MOBILE WARGA VIA CLOUDFLARE
echo ================================================================
echo.
echo Menghubungkan Aplikasi Warga ke jaringan Cloudflare Tunnel...
echo.
echo Tunggu beberapa detik sampai muncul tautan HTTPS resmi di bawah:
echo   https://xxxx.trycloudflare.com
echo.
echo Tautan tersebut bisa langsung Anda buka di HP warga dari mana saja!
echo.
echo Tekan Ctrl + C jika ingin menghentikan online demo.
echo ================================================================
echo.

cloudflared tunnel --url http://localhost:8080
pause
