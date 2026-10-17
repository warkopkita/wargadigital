# 🚀 Panduan Rilis Warga Digital ke Google Play Store

## 📋 Daftar Isi
1. [Prasyarat](#-1-prasyarat)
2. [Buat Akun Google Play Console](#-2-buat-akun-google-play-console)
3. [Buat Upload Key (Keystore)](#-3-buat-upload-key-keystore)
4. [Konfigurasi Signing](#-4-konfigurasi-signing)
5. [Buat App Icon Profesional](#-5-buat-app-icon-profesional)
6. [Build App Bundle (.aab)](#-6-build-app-bundle-aab)
7. [Siapkan Store Listing](#-7-siapkan-store-listing)
8. [Upload dan Rilis](#-8-upload-dan-rilis)
9. [Update App di Masa Depan](#-9-update-app-di-masa-depan)

---

## ✅ 1. Prasyarat

| Item | Status |
|------|--------|
| Flutter SDK terinstall | ✅ Sudah |
| Android SDK terinstall | ✅ Sudah |
| Project Flutter siap | ✅ Sudah |
| Akun Google Play Console | ❌ Perlu dibuat |
| Upload Keystore (.jks) | ❌ Perlu dibuat |
| App Icon | ❌ Perlu dibuat |

---

## 🏪 2. Buat Akun Google Play Console

### Langkah-langkah:

1. **Buka** [Google Play Console](https://play.google.com/console/signup)
2. **Login** dengan akun Google kamu
3. **Bayar biaya pendaftaran** sebesar **$25 (sekali bayar, seumur hidup)**
   - Bisa bayar dengan kartu kredit/debit internasional (Visa/Mastercard)
   - Bisa juga menggunakan GoPay/OVO/Dana yang terhubung ke Google Pay
4. **Lengkapi profil developer**:
   - **Nama Developer**: `Warga Digital` atau nama organisasi kamu
   - **Email kontak**: email yang bisa dihubungi pengguna
   - **Nomor telepon**: nomor yang aktif
   - **Website** (opsional): URL website RT jika ada
5. **Verifikasi identitas** — Google akan meminta scan KTP/Passport

> [!IMPORTANT]
> Proses verifikasi akun memakan waktu **2-7 hari kerja**. Buat akun sekarang agar tidak menunggu lama.

---

## 🔑 3. Buat Upload Key (Keystore)

Keystore adalah file kunci digital untuk menandatangani app kamu. **Jangan sampai hilang!**

### Buka PowerShell/CMD dan jalankan:

```powershell
keytool -genkey -v -keystore C:\Users\moham\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias wargadigital
```

### Isi informasi berikut saat diminta:

| Pertanyaan | Contoh Jawaban |
|------------|----------------|
| Enter keystore password | `password_rahasia_123` |
| Re-enter new password | `password_rahasia_123` |
| What is your first and last name? | `Mohammad` |
| What is the name of your organizational unit? | `RT Digital` |
| What is the name of your organization? | `Warga Digital` |
| What is the name of your City or Locality? | `Jakarta` |
| What is the name of your State or Province? | `DKI Jakarta` |
| What is the two-letter country code? | `ID` |

> [!CAUTION]
> **SIMPAN keystore dan password dengan AMAN!** Jika hilang, kamu tidak bisa update app yang sudah dipublish. Backup ke tempat yang aman (Google Drive, USB drive).

---

## ⚙️ 4. Konfigurasi Signing

### Buat file `key.properties`:

```powershell
copy C:\Users\moham\Downloads\rt\mobile\android\key.properties.example C:\Users\moham\Downloads\rt\mobile\android\key.properties
```

### Edit file `key.properties` dengan Notepad:

```properties
storePassword=password_rahasia_123
keyPassword=password_rahasia_123
keyAlias=wargadigital
storeFile=C:/Users/moham/upload-keystore.jks
```

> [!NOTE]
> File `key.properties` sudah ada di `.gitignore` sehingga tidak akan ter-commit ke repository.

**✅ File `build.gradle.kts` sudah dikonfigurasi otomatis** untuk membaca `key.properties`.

---

## 🎨 5. Buat App Icon Profesional

### Opsi A: Menggunakan flutter_launcher_icons (Rekomendasi)

1. Siapkan gambar icon berukuran **1024x1024 pixel** (PNG, tanpa transparansi)
2. Taruh di `mobile/assets/icon/app_icon.png`
3. Tambahkan ke `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_foreground: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A73E8"
```

4. Jalankan:
```powershell
cd C:\Users\moham\Downloads\rt\mobile
flutter pub get
dart run flutter_launcher_icons
```

### Opsi B: Manual
- Buat icon di [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html)
- Download dan replace semua file di folder `mipmap-*`

---

## 📦 6. Build App Bundle (.aab)

### Pastikan API URL sudah mengarah ke server production:

> [!WARNING]
> Sebelum build, pastikan `baseUrl` di code Flutter sudah mengarah ke **URL production** (bukan `localhost` atau `10.0.2.2`).

### Build App Bundle:

```powershell
cd C:\Users\moham\Downloads\rt\mobile

# Clean dulu
flutter clean

# Get dependencies
flutter pub get

# Build release App Bundle
flutter build appbundle --release
```

### Output file:
```
mobile\build\app\outputs\bundle\release\app-release.aab
```

> [!TIP]
> **App Bundle (.aab)** adalah format yang **wajib** digunakan untuk upload ke Play Store (bukan APK). Google Play akan otomatis mengoptimasi ukuran download per device.

### Tes APK Release di HP (opsional):
```powershell
flutter build apk --release
flutter install --release
```

---

## 📝 7. Siapkan Store Listing

### A. Informasi App

| Item | Contoh |
|------|--------|
| **Nama App** | Warga Digital - Manajemen RT/RW |
| **Deskripsi Singkat** (80 karakter) | Aplikasi pintar untuk kelola iuran, surat, & keamanan RT/RW Anda |
| **Kategori** | Social / Productivity |
| **Email Kontak** | email@wargadigital.id |

### B. Screenshot (WAJIB, minimal 2, rekomendasi 4-8)

Ukuran: **1080 x 1920 pixel** — ambil dari HP atau emulator:

```powershell
# Ambil screenshot dari device yang terhubung
adb exec-out screencap -p > screenshot_dashboard.png
```

Screenshot yang direkomendasikan:
1. Halaman Login
2. Dashboard utama
3. Manajemen Kas/Iuran
4. Jadwal Ronda/Siskamling
5. Data Warga
6. Surat Digital

### C. Feature Graphic (WAJIB)
- Ukuran: **1024 x 500 pixel**
- Bisa dibuat gratis di [Canva](https://canva.com)

### D. App Icon untuk Play Store
- Ukuran: **512 x 512 pixel** (PNG, 32-bit, tanpa transparansi)

---

## 🚀 8. Upload dan Rilis

### Langkah di Google Play Console:

1. **Login** ke [Google Play Console](https://play.google.com/console)

2. **Buat App Baru**:
   - Klik **"Create app"**
   - Nama: `Warga Digital`
   - Default language: `Indonesian - id`
   - App type: **App** → Free
   - Klik **"Create app"**

3. **Isi Store Listing**: Deskripsi, screenshot, icon, feature graphic

4. **Content Rating**: Isi kuesioner → biasanya rating **"Everyone"**

5. **Target Audience**: 18+ tahun, negara Indonesia

6. **Data Safety**: Isi formulir sesuai data yang dikumpulkan

7. **Privacy Policy** (WAJIB): Upload kebijakan privasi ke website/GitHub Pages

8. **Upload AAB**:
   - Menu **"Production"** → **"Create new release"**
   - Upload file `app-release.aab`
   - Release name: `1.0.0`
   - Klik **"Review release"** → **"Start rollout to Production"**

> [!NOTE]
> Review pertama biasanya memakan waktu **3-7 hari kerja**.

---

## 🔄 9. Update App di Masa Depan

1. **Naikkan versi** di `pubspec.yaml`:
```yaml
version: 1.0.1+2    # Dari 1.0.0+1
```

2. **Build ulang**:
```powershell
flutter clean && flutter pub get && flutter build appbundle --release
```

3. **Upload AAB baru** ke Play Console → Production → Create new release

---

## 🔧 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `keytool not found` | Tambahkan Java ke PATH: `$env:PATH += ";C:\Program Files\Android\Android Studio\jbr\bin"` |
| Error saat build | `flutter clean` lalu `cd android && .\gradlew clean && cd .. && flutter build appbundle --release` |
| APK terlalu besar | `flutter build apk --split-per-abi --release` |

---

## 📊 Estimasi Timeline

| Langkah | Waktu |
|---------|-------|
| Buat akun Play Console + verifikasi | 2-7 hari |
| Buat keystore + konfigurasi | 30 menit |
| Buat app icon | 1-2 jam |
| Build AAB | 10-15 menit |
| Siapkan store listing | 2-3 jam |
| Upload + review Google | 3-7 hari |
| **Total sampai live** | **~1-2 minggu** |

---

## 💡 Tips untuk iOS (Nanti)

Karena kamu hanya punya Windows, untuk rilis ke **App Store** bisa pakai:
1. **Codemagic CI/CD** — Build iOS di cloud tanpa Mac (gratis 500 menit/bulan)
2. **GitHub Actions** — macOS runner gratis untuk repo publik
3. **MacInCloud** — Sewa Mac virtual mulai $1/jam

> [!IMPORTANT]
> App Store memerlukan Apple Developer Account ($99/tahun) dan Mac untuk build.

---

## ✅ Checklist Sebelum Rilis

- [ ] Buat akun Google Play Console ($25)
- [ ] Buat Upload Keystore (.jks)
- [ ] Buat file key.properties
- [ ] Buat app icon 1024x1024 dan 512x512
- [ ] Ganti base URL ke production server
- [ ] Build `flutter build appbundle --release`
- [ ] Ambil 4-8 screenshot app
- [ ] Buat feature graphic 1024x500
- [ ] Tulis deskripsi app
- [ ] Host kebijakan privasi
- [ ] Upload AAB ke Play Console
- [ ] Isi content rating & data safety
- [ ] Submit for review
