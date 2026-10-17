# 📢 PANDUAN PELUNCURAN & SOSIALISASI APLIKASI "WARGA DIGITAL"

> Dokumen panduan resmi untuk Pengurus RT/RW/Desa dalam mengoperasikan, meluncurkan ke server gratis, dan menyosialisasikan aplikasi kepada seluruh warga kampung.

---

## 🚀 1. Ringkasan Status Sistem (Semua Fase Selesai 100%)

Aplikasi "Warga Digital" telah dibangun secara lengkap mencakup:
1. **Aplikasi Mobile Warga (Flutter)**: Pendaftaran langsung dengan NIK, Pengajuan Surat, Panic Button Darurat, Absensi Ronda GPS, Transparansi Kas, dan Kabar Kampung.
2. **Web Dashboard Pengurus (Vue 3)**: Panel persetujuan akun warga baru (*one-click approve/reject*), tanda tangan digital QR Code otomatis, peta sebaran titik aduan, dan pembukuan kas.
3. **Backend REST API (Laravel 11)**: 22 Endpoint API, Database SQLite aman, dan sistem backup otomatis harian (`php artisan app:backup-warga`).
4. **Dokumen Surat Resmi**: Siap cetak / download PDF A4 dengan Kop Surat RT/RW resmi dan QR Code otentikasi.

---

## 💻 2. Cara Menjalankan Sistem di Komputer Lokal

Jika ingin menjalankan kembali seluruh sistem di komputer desa:

1. **Jalankan Backend (Terminal 1)**:
   ```powershell
   cd c:\Users\moham\Downloads\rt\backend
   php artisan serve --host=127.0.0.1 --port=8000
   ```
2. **Jalankan Web Dashboard (Terminal 2)**:
   ```powershell
   cd c:\Users\moham\Downloads\rt\web
   npm run dev -- --host
   ```
   *Buka di browser*: `http://localhost:5173/`
3. **Jalankan Aplikasi Mobile (Terminal 3)**:
   ```powershell
   cd c:\Users\moham\Downloads\rt\mobile
   php -S localhost:8080 -t build\web
   ```
   *Buka di browser*: `http://localhost:8080/`

---

## ☁️ 3. Panduan Deploy Server Gratis Selamanya (Oracle Cloud Free Tier)

Untuk meng-online-kan aplikasi agar warga bisa mengakses dari mana saja dengan biaya **Rp 0 / bulan**:

1. **Daftar Akun**: Kunjungi [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/) dan buat instance VM gratis selamanya (Always Free Ubuntu 22.04).
2. **Install Docker**:
   ```bash
   sudo apt update && sudo apt install docker.io docker-compose -y
   ```
3. **Upload Folder Proyek**: Salin folder `rt` ke server.
4. **Jalankan 1 Perintah**:
   ```bash
   docker-compose up -d
   ```
5. **Selesai**: Web Dashboard dan Backend otomatis hidup 24 jam nonstop tanpa perlu bayar sewa bulanan!

---

## 📱 4. Template Pesan WhatsApp Sosialisasi ke Warga

*(Silakan salin teks di bawah ini dan bagikan ke grup WhatsApp RT/RW warga)*

```
Assalamu’alaikum Wr. Wb. & Selamat Sejahtera Bapak/Ibu Warga RT 01 / RW 05,

Kini pelayanan administrasi dan informasi lingkungan kita menjadi lebih mudah, cepat, dan transparan melalui aplikasi:

🌟 "WARGA DIGITAL" — RT 01 / RW 05 🌟
Layanan Pintar Mandiri dari Rumah

Dengan aplikasi ini, Bapak/Ibu dapat:
✅ Mengajukan Surat Pengantar (KTP, Domisili, SKCK, SKTM) langsung dari HP tanpa perlu datang mengantre.
✅ Surat otomatis ditandatangani digital & ber-QR Code resmi.
✅ Memantau jadwal ronda malam mingguan & check-in GPS.
✅ Melihat keterbukaan Buku Kas RT secara transparan.
✅ Tombol Darurat (Panic Button SOS) untuk musibah/kebakaran/medis.
✅ Membaca pengumuman dan kabar kegiatan kampung terkini.

📲 CARA MENDAFTAR & MASUK:
1. Buka tautan aplikasi di HP Anda: http://[ALAMAT-SERVER-DESA]:8080
2. Klik menu "Daftar Warga"
3. Masukkan 16 Digit Nomor NIK KTP Anda, Nama Lengkap, Nomor WhatsApp, dan Kata Sandi.
4. Setelah mendaftar, Ketua RT setempat akan memverifikasi dan menyetujui akun Anda agar aktif.

🔒 KEAMANAN & PRIVASI DATA:
Data NIK dan nomor kontak Anda terenkripsi aman dan hanya digunakan untuk keperluan administrasi kependudukan RT/RW setempat sesuai ketentuan UU Perlindungan Data Pribadi (UU PDP No. 27/2022).

Mari bersama-sama mewujudkan lingkungan yang rukun, aman, transparan, dan melek digital! 🇮🇩

Salam hangat,
Pengurus RT 001 / RW 005
Desa Sukamaju
```

---

## 🛡️ 5. Jadwal Pencadangan (Backup) Otomatis

Untuk memastikan data warga tidak hilang, sistem telah dibekali perintah otomatis:
```powershell
php artisan app:backup-warga
```
Setiap kali dijalankan, sistem akan menyimpan salinan database lengkap ke folder `backend/storage/app/backups/`.

---

## 🛡️ 6. Panduan Operasional Smart Siskamling & Keamanan Warga

Sistem telah dilengkapi modul **Smart Siskamling** untuk pengelolaan ronda malam cerdas:

1. **Auto-Generate Jadwal 7 Hari**:
   - Pengurus cukup menekan tombol `⚡ Auto-Generate 7 Hari` di Web Dashboard. Sistem secara otomatis membagi seluruh warga aktif ke Regu 1 sampai 7 secara merata.
2. **Cetak Jadwal Resmi Format A4 Kop Surat**:
   - Kunjungi atau klik tombol cetak di Web Dashboard (`/patrols/print-schedule`) untuk mengunduh dokumen resmi siap tempel di pos ronda.
3. **Stiker QR Checkpoint Patroli**:
   - Kunjungi `/patrols/qr-stickers/print` untuk mencetak lembar stiker QR Code resmi (`POS-RONDA-01`, `PORTAL-BARAT-01`, `GARDU-TIMUR-01`) yang ditempel di tiang pos ronda dan portal gang.
4. **Pengingat WhatsApp 1-Klik**:
   - Di dashboard pengurus terdapat tombol `📲 Pengingat WA Malam Ini` dan tombol chat per anggota untuk mengirim broadcast pesan resmi WhatsApp otomatis ke regu yang bertugas malam itu.
5. **Pengajuan Izin & Tukar Shift (Aplikasi Warga)**:
   - Warga dapat mengajukan izin tidak hadir atau tukar jadwal ronda dengan tetangga melalui menu Agenda Kegiatan di aplikasi HP.
6. **Sanksi Denda Masuk Kas RT**:
   - Anggota yang tidak hadir tanpa izin (*Alpha*) dapat dikenakan sanksi denda (standar Rp 25.000,-) yang otomatis masuk ke tagihan Kas RT warga bersangkutan.

