@echo off
chcp 65001 >nul
echo ========================================================
echo   WARGA DIGITAL - CLOUDFLARE HTTPS TUNNEL (ONLINE)
echo ========================================================
echo.
echo Membuka koneksi HTTPS publik gratis melalui Cloudflare...
echo Link publik akan muncul di bawah (contoh: https://xxxx.trycloudflare.com)
echo Link tersebut dapat dibuka langsung dari HP atau dibagikan ke warga!
echo.
echo Tekan Ctrl+C jika ingin menghentikan tunnel.
echo ========================================================
echo.

cloudflared tunnel --url http://localhost:8080
pause
