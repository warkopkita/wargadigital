<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Stiker QR Code Checkpoint Siskamling — RT 001 / RW 005</title>
  <style>
    @page {
      size: A4 portrait;
      margin: 10mm;
    }
    body {
      font-family: Arial, Helvetica, sans-serif;
      margin: 0;
      padding: 16px;
      background: #f1f5f9;
      color: #0f172a;
    }
    .no-print-bar {
      background: #0f172a;
      color: #fff;
      padding: 12px 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      border-radius: 8px;
    }
    .btn-print {
      background: #16a34a;
      color: #fff;
      border: none;
      padding: 8px 18px;
      font-weight: bold;
      border-radius: 6px;
      cursor: pointer;
    }
    .stickers-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
    }
    .sticker-card {
      background: #fff;
      border: 3px dashed #0284c7;
      border-radius: 16px;
      padding: 20px;
      text-align: center;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      page-break-inside: avoid;
    }
    .sticker-header {
      font-size: 11pt;
      font-weight: 800;
      color: #0369a1;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 4px;
    }
    .sticker-sub {
      font-size: 9pt;
      color: #64748b;
      margin-bottom: 12px;
    }
    .qr-frame {
      display: inline-block;
      padding: 12px;
      background: #f8fafc;
      border: 2px solid #0f172a;
      border-radius: 12px;
      margin-bottom: 12px;
    }
    .qr-frame img {
      width: 170px;
      height: 170px;
      display: block;
    }
    .point-name {
      font-size: 14pt;
      font-weight: 900;
      color: #0f172a;
      margin-bottom: 4px;
    }
    .point-code {
      display: inline-block;
      background: #0284c7;
      color: #fff;
      padding: 3px 12px;
      border-radius: 20px;
      font-size: 10pt;
      font-weight: bold;
      letter-spacing: 1px;
      margin-bottom: 10px;
    }
    .sticker-desc {
      font-size: 8.5pt;
      color: #334155;
      line-height: 1.4;
      background: #f0fdf4;
      border: 1px solid #bbf7d0;
      padding: 8px;
      border-radius: 8px;
    }
    @media print {
      body {
        background: #fff;
        padding: 0;
      }
      .no-print-bar {
        display: none !important;
      }
      .sticker-card {
        box-shadow: none;
        border: 2px solid #000;
      }
    }
  </style>
</head>
<body>

  <div class="no-print-bar">
    <div>
      <strong>Stiker QR Checkpoint Patroli Siskamling (Siap Tempel di Pos & Tiang Portal)</strong>
    </div>
    <button class="btn-print" onclick="window.print()">🖨️ Cetak Lembar Stiker QR</button>
  </div>

  <div class="stickers-grid">
    <!-- Sticker 1 -->
    <div class="sticker-card">
      <div class="sticker-header">SISKAMLING DIGITAL • RT 001 / RW 005</div>
      <div class="sticker-sub">Titik Patroli Keamanan Warga Terintegrasi GPS</div>
      <div class="qr-frame">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=CHECKPOINT:POS-RONDA-01" alt="QR Pos Ronda Utama">
      </div>
      <div class="point-name">POS RONDA UTAMA RT 001</div>
      <div class="point-code">KODE: POS-RONDA-01</div>
      <div class="sticker-desc">
        📲 <strong>Petugas Wajib Scan:</strong> Buka Aplikasi Warga Digital ➔ Menu Ronda ➔ Scan QR Checkpoint saat jam patroli (22:00, 00:00, 02:00, 04:00 WIB).
      </div>
    </div>

    <!-- Sticker 2 -->
    <div class="sticker-card">
      <div class="sticker-header">SISKAMLING DIGITAL • RT 001 / RW 005</div>
      <div class="sticker-sub">Titik Patroli Keamanan Warga Terintegrasi GPS</div>
      <div class="qr-frame">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=CHECKPOINT:PORTAL-BARAT-01" alt="QR Portal Barat">
      </div>
      <div class="point-name">PORTAL BARAT GANG KENANGA</div>
      <div class="point-code">KODE: PORTAL-BARAT-01</div>
      <div class="sticker-desc">
        📲 <strong>Pemeriksaan Khusus:</strong> Pastikan gembok portal terkunci mulai pukul 23:00 WIB dan laporkan jika ada tamu mencurigakan.
      </div>
    </div>

    <!-- Sticker 3 -->
    <div class="sticker-card">
      <div class="sticker-header">SISKAMLING DIGITAL • RT 001 / RW 005</div>
      <div class="sticker-sub">Titik Patroli Keamanan Warga Terintegrasi GPS</div>
      <div class="qr-frame">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=CHECKPOINT:GARDU-TIMUR-01" alt="QR Gardu Timur">
      </div>
      <div class="point-name">GARDU TIMUR JALUR HIJAU</div>
      <div class="point-code">KODE: GARDU-TIMUR-01</div>
      <div class="sticker-desc">
        📲 <strong>Pemeriksaan Khusus:</strong> Pantau penerangan jalan umum gang timur dan area parkir warga sekitar balai RT.
      </div>
    </div>

    <!-- Sticker 4 (Ketentuan Darurat) -->
    <div class="sticker-card" style="border-color: #dc2626; background: #fff5f5;">
      <div class="sticker-header" style="color: #b91c1c;">HOTLINE KEAMANAN DARURAT SISKAMLING</div>
      <div class="sticker-sub">Posko Satgas Lingkungan RT 001 / RW 005</div>
      <div class="qr-frame" style="border-color: #dc2626;">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=EMERGENCY:HOTLINE-RT001" alt="QR Darurat">
      </div>
      <div class="point-name" style="color: #991b1b;">PANIC BUTTON & BANTUAN CEPAT</div>
      <div class="point-code" style="background: #dc2626;">DARURAT: 0812-9988-7766</div>
      <div class="sticker-desc" style="background: #fef2f2; border-color: #fecaca;">
        🚨 <strong>Darurat:</strong> Jika terjadi pencurian, kebakaran, atau gangguan keamanan, tekan tombol darurat di aplikasi untuk membunyikan sirine di pos ronda!
      </div>
    </div>
  </div>

</body>
</html>
