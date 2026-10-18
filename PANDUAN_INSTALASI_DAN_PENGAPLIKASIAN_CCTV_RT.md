# 📹 PANDUAN LENGKAP INSTALASI & PENGAPLIKASIAN CCTV LINGKUNGAN RT/RW
**Sistem Keamanan Terintegrasi WargaDigital**

Panduan ini disusun secara praktis dan bertahap untuk Pengurus RT, Seksi Keamanan, dan Teknisi Lingkungan dalam merancang, memasang, dan menghubungkan kamera CCTV ke dalam sistem **WargaDigital** (Web Dashboard & Mobile App khusus Admin/Staff).

---

## 📑 DAFTAR ISI
1. [Rekomendasi Perangkat & Estimasi Anggaran (BOM)](#1-rekomendasi-perangkat--estimasi-anggaran)
2. [Topologi Jaringan & Titik Pemasangan](#2-topologi-jaringan--titik-pemasangan)
3. [Panduan Pemasangan Fisik (Hardware & Kabel)](#3-panduan-pemasangan-fisik)
4. [Konfigurasi Jaringan & Protokol RTSP/ONVIF](#4-konfigurasi-jaringan--protokol-rtsponvif)
5. [Integrasi Streaming ke Web Dashboard & Aplikasi HP](#5-integrasi-streaming-ke-web--aplikasi)
6. [Pengaplikasian Display TV 24 Jam di Pos Ronda](#6-pengaplikasian-display-tv-24-jam-di-pos-ronda)
7. [SOP Keamanan Data, Perawatan & Privasi Warga](#7-sop-keamanan-data-perawatan--privasi-warga)

---

## 1. Rekomendasi Perangkat & Estimasi Anggaran

Berikut adalah spesifikasi perangkat yang terbukti handal, tahan cuaca outdoor (hujan & panas), serta mendukung protokol terbuka (**RTSP/ONVIF**) tanpa biaya langganan bulanan:

| Perangkat | Rekomendasi Merk & Tipe | Fungsi & Penempatan | Estimasi Harga (Rp) |
| :--- | :--- | :--- | :--- |
| **Kamera 1 (Gerbang)** | **TP-Link Tapo C320WS** (2K QHD, Color Night) | Pantau plat nomor & tamu di Portal Masuk | Rp 500.000 - 580.000 |
| **Kamera 2 (Pos Ronda)** | **Ezviz H3c Color Night** (1080p IP67) | Pantau pos keamanan & parkiran kendaraan | Rp 420.000 - 480.000 |
| **Kamera 3 (Simpang)** | **TP-Link Tapo C500** (PTZ 360° Pan/Tilt) | Pantau simpang gang & area bermain anak | Rp 470.000 - 550.000 |
| **Kamera 4 (Jalur Rawan)** | **Hikvision IP Bullet DS-2CD** / Tapo C310 | Pantau jalur belakang & tempat sampah/TPS | Rp 400.000 - 650.000 |
| **Penyimpanan Lokal** | MicroSD SanDisk High Endurance 128GB (x4) | Rekam rekaman loop 24/7 (tahan 14-21 hari) | @ Rp 160.000 (Rp 640.000) |
| **Switch PoE** | Switch PoE 4/8 Port 100Mbps (Hikvision/TP-Link) | Alirkan listrik & data via kabel LAN ke kamera | Rp 350.000 - 450.000 |
| **Kabel Jaringan** | Kabel UTP Outdoor Cat6 (Double Jacket / PE) | Tarikan kabel antar tiang tahan panas & hujan | Rp 2.500 - 3.500 / meter |
| **Aksesoris Proteksi** | Box Duradus Anti Air 10x10cm (x4) + Konektor RJ45 | Melindungi sambungan kabel dari embun/hujan | Rp 150.000 |
| **Display Pos Ronda** | Android TV Box / Google TV Stick + TV LED 24-32" | Menampilkan 4 layar kamera non-stop di Pos | Rp 280.000 (TV Box) |

---

## 2. Topologi Jaringan & Titik Pemasangan

### A. Diagram Jaringan di Pos Ronda
```text
[ Modem Internet RT (IndiHome/Biznet) ]
                  │ (Kabel LAN)
                  ▼
         [ Router Utama RT ]
                  │ (IP: 192.168.1.1)
                  ▼
         [ Switch PoE 4-Port ]
       ┌──────────┼──────────┬──────────┐
       │ (PoE)    │ (PoE)    │ (PoE)    │ (PoE)
       ▼          ▼          ▼          ▼
   [CCTV 01]  [CCTV 02]  [CCTV 03]  [CCTV 04]
    Gerbang    Pos Jaga   Simpang    TPS Barat
```

> **Catatan Jarak Jauh**: Jika ada titik kamera yang berjarak lebih dari 80 meter dan sulit menarik kabel kabel tiang, gunakan sepasang **Wireless Outdoor Bridge** (contoh: *TP-Link CPE220* atau *Tenda O3*) untuk memancarkan sinyal Wi-Fi antar tiang hingga 500 meter tanpa kabel fisik.

### B. Posisi Ideal Penempatan Kamera
1. **Titik Portal Masuk**: Pasang di ketinggian **2,5 – 3 meter** dengan sudut condong 30° ke bawah menghadap arah datang kendaraan agar wajah pengendara dan plat nomor terbaca jelas tanpa silau lampu kendaraan.
2. **Titik Simpang Lapangan / Gang**: Gunakan tipe PTZ 360° di tiang tengah atau sudut dinding balai warga agar petugas linmas dapat menggeser sudut pandang kamera dari aplikasi HP saat ada kerumunan.
3. **Titik Pos Ronda**: Sorot area parkir motor warga dan meja piket untuk memastikan anggota linmas aktif berjaga.

---

## 3. Panduan Pemasangan Fisik

1. **Gunakan Box Duradus**: Selalu masukkan adaptor, konektor kabel LAN RJ45, dan sambungan daya ke dalam **Box Duradus IP65** di bawah masing-masing kamera. Beri lubang kabel di bagian **bawah** box (bukan di atas/samping) agar air hujan tidak masuk mengalir ke dalam.
2. **Kabel UTP Outdoor Tahan Cuaca**: Jangan gunakan kabel LAN indoor biasa (warna abu-abu/putih) untuk luar ruangan karena akan getas dalam 3 bulan akibat sinar matahari. Gunakan kabel **UTP Cat6 Outdoor Double Jacket** (warna hitam dengan kulit pelindung ganda).
3. **Pemasangan MicroSD**: Masukkan kartu MicroSD High Endurance sebelum kamera dipasang di tiang, lalu lakukan format kartu memori melalui aplikasi ponsel pertama kali.

---

## 4. Konfigurasi Jaringan & Protokol RTSP/ONVIF

Agar kamera dapat ditonton melalui Web Dashboard dan Aplikasi WargaDigital, kamera perlu diaktifkan fitur **RTSP (Real-Time Streaming Protocol)**:

### Langkah A: Setting IP Statis (DHCP Reservation)
Masuk ke menu router RT (`192.168.1.1`), buat reservasi IP untuk kamera:
- `192.168.1.101` -> CCTV 01 (Gerbang)
- `192.168.1.102` -> CCTV 02 (Pos Ronda)
- `192.168.1.103` -> CCTV 03 (Simpang)
- `192.168.1.104` -> CCTV 04 (TPS Barat)

### Langkah B: Pembuatan Akun Kamera Lokal
#### 1. Untuk TP-Link Tapo (C320WS & C500):
1. Buka aplikasi **Tapo** di ponsel pengurus.
2. Pilih kamera -> Masuk ke menu **Settings** (Ikon Roda Gigi di kanan atas).
3. Pilih **Advanced Settings (Pengaturan Lanjutan)** -> **Camera Account (Akun Kamera)**.
4. Buat Username & Password khusus RTSP, misal:
   - Username: `rt_security`
   - Password: `PasswordRT2026!`
5. Format URL Streaming RTSP lokal:
   - **Stream Utama (2K/1080p)**: `rtsp://rt_security:PasswordRT2026!@192.168.1.101:554/stream1`
   - **Sub Stream (Lancar untuk Web)**: `rtsp://rt_security:PasswordRT2026!@192.168.1.101:554/stream2`

#### 2. Untuk Ezviz (H3c):
1. Buka aplikasi **Ezviz** -> Pilih kamera -> Pengaturan.
2. Cari **Verification Code** (tertera di stiker barcode bawah kamera).
3. Format URL Streaming RTSP:
   - `rtsp://admin:KODE_VERIFIKASI@192.168.1.102:554/h264/ch1/main`

#### 3. Untuk Hikvision IP Camera:
1. Buka browser -> ketik IP `192.168.1.104`.
2. Masuk ke **Configuration** -> **Network** -> **Advanced Settings** -> **Integration Protocol**.
3. Centang **Enable ONVIF** -> Tambahkan user `admin` dan password.
4. Format URL: `rtsp://admin:password@192.168.1.104:554/Streaming/Channels/101`

---

## 5. Integrasi Streaming ke Web & Aplikasi

Browser modern (Chrome/Safari) dan Flutter Web tidak dapat memutar format mentah RTSP secara langsung, melainkan membutuhkan format web seperti **WebRTC**, **HLS**, atau **MP4 Stream**.

### Solusi Praktis: Menggunakan Media Gateway (MediaMTX / go2rtc)
Jalankan program gateway gratis dan ringan di Mini PC atau Router Pos Ronda:

1. Unduh **MediaMTX** (open source streaming server berukuran hanya 15 MB).
2. Edit file konfigurasi `mediamtx.yml`:
```yaml
paths:
  cctv-gerbang:
    source: rtsp://rt_security:PasswordRT2026!@192.168.1.101:554/stream2
  cctv-pos:
    source: rtsp://admin:KODE_VERIFIKASI@192.168.1.102:554/h264/ch1/main
  cctv-simpang:
    source: rtsp://rt_security:PasswordRT2026!@192.168.1.103:554/stream2
  cctv-tps:
    source: rtsp://admin:password@192.168.1.104:554/Streaming/Channels/101
```
3. MediaMTX otomatis menyediakan link streaming WebRTC/HLS yang langsung siap dipasang ke database `cctv_cameras` pada sistem WargaDigital:
   - `http://192.168.1.100:8889/cctv-gerbang/whep` (WebRTC delay di bawah 0.5 detik!)
   - Atau link HLS: `http://192.168.1.100:8888/cctv-gerbang/index.m3u8`

---

## 6. Pengaplikasian Display TV 24 Jam di Pos Ronda

Agar Linmas/Satpam yang berjaga malam bisa memantau lingkungan tanpa perlu memegang ponsel terus-menerus:

1. Siapkan **TV LED** (minimal 24 inch) di dinding pos ronda.
2. Pasang **Android TV Box** (misal Xiaomi Mi TV Box atau Google TV Stick) ke port HDMI TV.
3. Hubungkan TV Box ke jaringan Wi-Fi Pos Ronda.
4. Buka aplikasi browser (Chrome / Puffin TV Browser) pada TV Box.
5. Akses alamat Web Dashboard WargaDigital:
   `https://[domain-aplikasi-rt]/`
6. Login menggunakan akun Linmas:
   - Username: `linmas` / `satpam`
7. Masuk ke tab menu **CCTV Lingkungan**.
8. Klik tombol hijau **"Mode TV Pos Ronda"** di sudut kanan atas.
9. Layar akan beralih ke mode **Fullscreen 4 Layar Bersama**:
   - Menampilkan live video 4 sudut wilayah RT.
   - Jam digital dan tanggal real-time di sudut atas.
   - Indikator warna hijau (Online) / merah (Offline).

---

## 7. SOP Keamanan Data, Perawatan & Privasi Warga

### A. Hak Akses & Pembatasan Privasi
- **Hanya untuk Admin & Linmas**: Akses video live dan rekaman hanya diberikan kepada Ketua RT, RW, Sekretaris, Bendahara, dan Petugas Linmas terdaftar.
- **Etika Arah Lensa**: Dilarang mengarahkan kamera langsung ke teras privat atau jendela kamar rumah warga. Sudut kamera wajib fokus pada **jalan umum, pagar gerbang, atau fasilitas umum**.
- **Penyimpanan Rekaman**: Rekaman tersimpan otomatis di MicroSD lokal selama 14-30 hari secara berulang (*loop recording*). Jika memori penuh, rekaman paling lama akan ditimpa otomatis.

### B. Prosedur Permintaan Rekaman (Bila Ada Insiden)
1. Warga yang mengalami insiden (kehilangan paket, benturan kendaraan, orang mencurigakan) melapor kepada Ketua RT atau Pengurus.
2. Petugas Linmas/RT membuka menu **CCTV Lingkungan** -> Klik **Ambil Snapshot / Buat Tiket Insiden**.
3. Lampirkan tangkapan layar kejadian beserta waktu kejadian yang akurat sebagai lampiran resmi laporan ke pihak berwenang/Bhabinkamtibmas.

### C. Jadwal Pemeliharaan Berkala
- **1 Bulan Sekali**: Bersihkan kaca lensa kamera luar ruangan dari sarang laba-laba atau debu menggunakan kain microfiber basah.
- **3 Bulan Sekali**: Periksa konektor kabel di dalam box duradus untuk memastikan tidak ada tetesan air kondensasi.
- **6 Bulan Sekali**: Cek kesehatan memori MicroSD melalui aplikasi untuk memastikan status rekaman tetap aktif.

---
*Dokumen ini diterbitkan untuk operasional lingkungan Rukun Tetangga (RT) & Rukun Warga (RW) digital.*
