# 🌐 PANDUAN LENGKAP HOSTING & DEPLOYMENT "WARGA DIGITAL"

> Dokumen panduan resmi untuk menaikkan sistem aplikasi **Warga Digital** ke internet sehingga dapat diakses oleh seluruh warga dan pengurus dari mana saja secara online 24 jam.

---

## 📑 Daftar Isi
1. [Metode 1: Online Demo Instan Gratis (Cloudflare Tunnel - 1 Menit)](#-metode-1-online-demo-instan-gratis-cloudflare-tunnel)
2. [Metode 2: Cloud VPS Linux dengan Docker (Paling Direkomendasikan)](#-metode-2-cloud-vps-linux-dengan-docker-rekomendasi-terbaik)
3. [Metode 3: Shared Hosting / cPanel (PHP 8.2+)](#-metode-3-shared-hosting--cpanel-biasa)
4. [Pengaturan Domain Desa & SSL HTTPS Gratis](#-pengaturan-domain-desa--ssl-https-gratis)
5. [Daftar Port & Firewall yang Harus Dibuka](#-daftar-port-sistem)

---

## ⚡ Metode 1: Online Demo Instan Gratis (Cloudflare Tunnel)

Jika Anda ingin langsung mencoba membuka aplikasi dari HP menggunakan internet publik tanpa perlu sewa VPS sekarang:

1. Pastikan server lokal sudah berjalan di laptop Anda (`php artisan serve`, web, dan mobile).
2. Klik ganda (double click) file:
   ```
   online_tunnel.bat
   ```
   *(File ini berada di folder utama `c:\Users\moham\Downloads\rt\`)*
3. Tunggu 5-10 detik, terminal akan memunculkan tautan HTTPS publik resmi Cloudflare:
   ```
   https://random-words-here.trycloudflare.com
   ```
4. Buka tautan tersebut di HP Anda. Aplikasi langsung terbuka online dan siap dites oleh warga!

---

## 🐳 Metode 2: Cloud VPS Linux dengan Docker (Rekomendasi Terbaik)

Metode ini adalah standar industri paling stabil, cepat, dan otomatis. Dapat dipasang di penyedia VPS mana pun:
- **Lokal Indonesia**: IDCloudHost, Niagahoster Cloud VPS, DomaiNesia, Biznet GIO.
- **Internasional**: DigitalOcean ($4-$6/bln), Linode, Hetzner, atau **Oracle Cloud Free Tier** (Gratis Rp 0 selamanya).

### Spesifikasi Minimum VPS:
- **OS**: Ubuntu 22.04 LTS / 24.04 LTS
- **RAM**: 1 GB - 2 GB
- **Storage**: 20 GB SSD

### Langkah-langkah Deploy:
1. **Login ke VPS melalui SSH (Terminal / PuTTY)**:
   ```bash
   ssh root@IP_VPS_ANDA
   ```

2. **Upload / Salin Folder Proyek `rt` ke VPS**:
   Anda bisa menggunakan WinSCP, FileZilla, atau Git clone. Letakkan di `/var/www/wargadigital`.

3. **Jalankan Skrip Otomatis**:
   ```bash
   cd /var/www/wargadigital
   chmod +x deploy_vps.sh
   ./deploy_vps.sh
   ```

4. **Selesai!**
   Skrip `deploy_vps.sh` otomatis:
   - Memperbarui sistem operasi Ubuntu
   - Menginstal Docker & Docker Compose
   - Mengatur firewall port 80, 443, 8000, 8080, 5173
   - Menyalakan seluruh container (Backend API, Web Pengurus, dan Mobile Web)
   - Sistem akan otomatis hidup kembali jika VPS di-restart (`restart: unless-stopped`).

---

## 🏢 Metode 3: Shared Hosting / cPanel Biasa

Jika Anda sudah memiliki hosting cPanel murah (misal paket pelajar/bisnis):

### Syarat Hosting:
- Versi PHP minimal **PHP 8.2** atau **PHP 8.3**
- Ekstensi PHP aktif: `pdo_sqlite` (atau `pdo_mysql`), `mbstring`, `openssl`, `tokenizer`, `xml`, `ctype`, `json`, `bcmath`, `fileinfo`.

### Langkah-langkah:
1. **Upload Backend**:
   - Kompres seluruh isi folder `backend/` menjadi file ZIP (kecuali folder `node_modules` dan `.git`).
   - Ekstrak di root cPanel (misalnya di folder `/home/username/wargadigital_backend`).
   - Ubah Document Root domain/subdomain Anda ke folder:
     `/home/username/wargadigital_backend/public`
2. **Upload Web Dashboard Pengurus**:
   - Buka folder `web/` di komputer Anda, lalu jalankan `npm run build`.
   - Buka folder hasil build `web/dist/`.
   - Upload seluruh file di dalam `web/dist/` ke `public_html/admin` atau subdomain `admin.desaku.id`.
3. **Upload Mobile Web**:
   - Upload isi folder `mobile/build/web/` ke `public_html/warga` atau subdomain `warga.desaku.id`.

---

## 🔒 Pengaturan Domain Desa & SSL HTTPS Gratis

Untuk menggunakan nama domain resmi desa (contoh: `wargadigital.desa.id` atau `rt01-sukamaju.com`):

1. **Arahkan DNS Record di Registrar Domain Anda**:
   - `A Record` | `@` | `IP_VPS_ANDA`
   - `A Record` | `admin` | `IP_VPS_ANDA`
   - `A Record` | `warga` | `IP_VPS_ANDA`
   - `A Record` | `api` | `IP_VPS_ANDA`

2. **Pasang SSL Gratis (Let's Encrypt Certbot)**:
   Jalankan perintah ini di VPS:
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   sudo certbot --nginx -d wargadigital.desa.id -d admin.desaku.id -d warga.desaku.id
   ```
   *Sertifikat SSL HTTPS gembok hijau otomatis aktif dan diperbarui otomatis.*

---

## 📶 Daftar Port Sistem

| Port | Komponen | Deskripsi |
| :--- | :--- | :--- |
| **80 / 443** | HTTP / HTTPS | Akses web utama melalui domain |
| **8000** | Backend API (Laravel) | Endpoint REST API kependudukan & kas |
| **5173** | Web Admin | Dashboard Ketua RT, Bendahara, Linmas, Posyandu |
| **8080** | Mobile Web App | Aplikasi warga (layanan surat, kas, aduan, panic button) |

---

> 💡 **Butuh Bantuan Langsung?**
> Beri tahu jika Anda memiliki akses VPS atau cPanel tertentu, sistem dapat langsung dikonfigurasikan sesuai server tujuan Anda.
