# 🚀 PANDUAN DEPLOY CLOUD GRATIS 24 JAM NONSTOP (Rp 0)
## "WARGA DIGITAL" - Web Admin & Mobile Web

> Panduan ini menggunakan kombinasi **Vercel** (Frontend Web & Mobile) + **Render.com** (Backend Laravel API).
> **100% GRATIS, AKTIF 24 JAM NONSTOP, TANPA PERLU LAPTOP MENYALA, TANPA KARTU KREDIT.**

---

### 📋 Ringkasan Arsitektur Hosting Gratis:
| Komponen | Platform Cloud | Biaya | Domain Yang Didapat |
| :--- | :--- | :--- | :--- |
| **Backend API (Laravel)** | **Render.com** | **Rp 0 / Gratis** | `https://warga-digital-backend.onrender.com` |
| **Web Pengurus RT** | **Vercel.com** | **Rp 0 / Gratis** | `https://warga-digital-admin.vercel.app` |
| **Aplikasi Warga (Mobile)** | **Vercel.com** | **Rp 0 / Gratis** | `https://warga-digital-mobile.vercel.app` |

---

## 🛠️ LANGKAH 1: Unggah Kode ke GitHub (Sekali Saja)

1. Buka browser dan login ke akun GitHub Anda di [https://github.com](https://github.com) *(daftar gratis jika belum punya)*.
2. Buat repository baru:
   - Klik tombol **New** (atau tanda `+` di kanan atas).
   - Beri nama repository, misalnya: `warga-digital`.
   - Pilih **Private** atau **Public** (bebas).
   - Klik **Create repository**.
3. Di laptop Anda, buka terminal di folder proyek (`c:\Users\moham\Downloads\rt\`), lalu jalankan perintah:
   ```bash
   git init
   git add .
   git commit -m "Deploy Warga Digital 24 Jam"
   git branch -M main
   git remote add origin https://github.com/USERNAME_ANDA/warga-digital.git
   git push -u origin main
   ```
   *(Ganti `USERNAME_ANDA` dengan username akun GitHub Anda)*.

---

## ⚡ LANGKAH 2: Deploy Backend ke Render.com (2 Menit)

Backend Laravel sudah kami lengkapi dengan `Dockerfile` dan `render.yaml` siap pakai.

1. Buka [https://render.com](https://render.com) dan klik **Sign Up** -> Pilih **Sign up with GitHub**.
2. Di halaman Dashboard Render:
   - Klik tombol **New +** di pojok kanan atas.
   - Pilih **Web Service**.
3. Hubungkan repository GitHub Anda:
   - Pilih repository `warga-digital` yang baru Anda buat.
4. Pengaturan Web Service:
   - **Name**: `warga-digital-backend`
   - **Region**: `Singapore` *(paling cepat untuk warga Indonesia)*
   - **Root Directory**: `backend`
   - **Environment**: `Docker`
   - **Instance Type**: Pilih **Free ($0/month)**
5. Klik tombol **Deploy Web Service** di bagian bawah.
6. Tunggu proses build 1-2 menit hingga status berubah menjadi **Live** (Hijau).
7. Salin URL Backend Anda yang muncul di bagian atas, contohnya:
   ```
   https://warga-digital-backend.onrender.com
   ```

---

## 🌐 LANGKAH 3: Deploy Web Pengurus ke Vercel (1 Menit)

1. Buka [https://vercel.com](https://vercel.com) dan klik **Sign Up** -> Pilih **Continue with GitHub**.
2. Di Dashboard Vercel, klik tombol **Add New...** -> Pilih **Project**.
3. Cari repository `warga-digital`, lalu klik **Import**.
4. Di bagian konfigurasi project:
   - **Project Name**: `warga-digital-admin`
   - **Framework Preset**: Pilih **Vite**
   - **Root Directory**: Klik *Edit*, pilih folder `web`
   - Di bagian **Environment Variables**:
     - Name: `VITE_API_URL`
     - Value: `https://warga-digital-backend.onrender.com` *(URL Render dari Langkah 2)*
5. Klik **Deploy**.
6. Selesai! Web Dashboard Pengurus langsung aktif 24 jam di:
   ```
   https://warga-digital-admin.vercel.app
   ```

---

## 📱 LANGKAH 4: Deploy Aplikasi Mobile Warga ke Vercel (1 Menit)

1. Di Dashboard Vercel Anda, klik kembali **Add New...** -> **Project**.
2. Pilih repository `warga-digital` yang sama, lalu klik **Import**.
3. Di bagian konfigurasi:
   - **Project Name**: `warga-digital-mobile`
   - **Framework Preset**: Pilih **Other**
   - **Root Directory**: Klik *Edit*, pilih folder `mobile`
   - **Output Directory**: Ketik `build/web`
4. Klik **Deploy**.
5. Selesai! Aplikasi Warga untuk HP langsung aktif 24 jam di:
   ```
   https://warga-digital-mobile.vercel.app
   ```

---

## 🎉 HASIL AKHIR: SISTEM ANDA RESMI ONLINE 24 JAM!

- **Laptop bisa dimatikan kapan saja**: Aplikasi tetap hidup 100% di cloud.
- **Warga bisa buka kapan saja**: Lewat browser HP Android / iPhone.
- **Bisa dipasang domain sendiri**: Jika RT nanti ingin pakai domain seperti `rt01-warga.my.id` (harga Rp 12.000/tahun), cukup hubungkan di menu *Settings -> Domains* di Vercel secara gratis!
