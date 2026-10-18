<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Surat Resmi — {{ $letter->letter_type }}</title>
  <style>
    @page {
      size: A4;
      margin: 20mm 20mm 20mm 20mm;
    }
    body {
      font-family: 'Times New Roman', Times, serif;
      color: #000;
      line-height: 1.6;
      margin: 0;
      padding: 24px;
      background: #fff;
    }
    .header-container {
      text-align: center;
      position: relative;
      margin-bottom: 8px;
    }
    .kop-title-1 {
      font-size: 16pt;
      font-weight: bold;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    .kop-title-2 {
      font-size: 14pt;
      font-weight: bold;
      text-transform: uppercase;
    }
    .kop-sub {
      font-size: 10pt;
      margin-top: 4px;
    }
    .divider-double {
      border: none;
      border-top: 3px solid #000;
      border-bottom: 1px solid #000;
      height: 4px;
      margin: 12px 0 20px 0;
    }
    .letter-title {
      text-align: center;
      margin-bottom: 24px;
    }
    .letter-title h2 {
      font-size: 13pt;
      font-weight: bold;
      text-transform: uppercase;
      text-decoration: underline;
      margin: 0;
    }
    .letter-title p {
      font-size: 11pt;
      margin-top: 2px;
    }
    .content-body {
      font-size: 12pt;
      text-align: justify;
    }
    .data-table {
      width: 100%;
      margin: 14px 0;
      border-collapse: collapse;
      font-size: 12pt;
    }
    .data-table td {
      padding: 3px 0;
      vertical-align: top;
    }
    .data-table td.label {
      width: 220px;
    }
    .data-table td.colon {
      width: 20px;
      text-align: center;
    }
    .sign-section {
      width: 100%;
      margin-top: 40px;
    }
    .sign-table {
      width: 100%;
      border-collapse: collapse;
    }
    .sign-box {
      width: 45%;
      text-align: center;
      vertical-align: top;
    }
    .qr-badge {
      display: inline-block;
      margin: 8px 0;
      padding: 6px;
      border: 1px dashed #15803d;
      background: #f0fdf4;
      border-radius: 6px;
    }
    .qr-text {
      font-family: monospace;
      font-size: 8pt;
      color: #166534;
      margin-top: 4px;
      font-weight: bold;
    }
    .no-print {
      margin-bottom: 20px;
      background: #f1f5f9;
      padding: 12px 20px;
      border-radius: 8px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .btn-print {
      background: #16a34a;
      color: white;
      border: none;
      padding: 8px 18px;
      font-weight: bold;
      border-radius: 6px;
      cursor: pointer;
      font-size: 11pt;
    }
    @media print {
      .no-print {
        display: none !important;
      }
      body {
        padding: 0;
      }
    }
  </style>
</head>
<body>

  <!-- Tombol Aksi di Layar Browser -->
  <div class="no-print">
    <div>
      <strong>📄 Pratinjau Dokumen Surat Resmi</strong>
      <div style="font-size: 9pt; color: #64748b;">Gunakan tombol di samping untuk mencetak ke printer fisik atau menyimpan sebagai file PDF A4.</div>
    </div>
    <button class="btn-print" onclick="window.print()">🖨️ Cetak / Unduh PDF</button>
  </div>

  <!-- KOP SURAT RESMI -->
  <div class="header-container">
    <div class="kop-title-1">RUKUN TETANGGA 001 / RUKUN WARGA 005</div>
    <div class="kop-title-2">DESA SUKAMAJU KECAMATAN MEKARSARI</div>
    <div class="kop-sub">Sekretariat: Balai Warga RT 001 Jl. Kenanga Raya No. 01 • Telp/WA: 0812-3456-7890 • Kode Pos: 16820</div>
  </div>

  <div class="divider-double"></div>

  <!-- JUDUL & NOMOR SURAT -->
  <div class="letter-title">
    <h2>{{ strtoupper($letter->letter_type) }}</h2>
    <p>Nomor: {{ $letter->letter_number ?? '470/012/RT.01/X/2026' }}</p>
  </div>

  <!-- ISI SURAT -->
  <div class="content-body">
    <p>
      Yang bertanda tangan di bawah ini, Ketua Rukun Tetangga (RT) 001 Rukun Warga (RW) 005 Desa Sukamaju Kecamatan Mekarsari, dengan ini menerangkan bahwa:
    </p>

    <table class="data-table">
      <tr>
        <td class="label">Nama Lengkap</td>
        <td class="colon">:</td>
        <td><strong>{{ strtoupper($letter->citizen_name) }}</strong></td>
      </tr>
      <tr>
        <td class="label">Nomor Induk Kependudukan (NIK)</td>
        <td class="colon">:</td>
        <td>{{ $letter->citizen_nik }}</td>
      </tr>
      <tr>
        <td class="label">Alamat / Tempat Tinggal</td>
        <td class="colon">:</td>
        <td>{{ $letter->citizen_address ?? 'Jl. Kenanga RT 01 / RW 05 Desa Sukamaju' }}</td>
      </tr>
      <tr>
        <td class="label">Nomor Telepon / WhatsApp</td>
        <td class="colon">:</td>
        <td>{{ $letter->citizen_phone }}</td>
      </tr>
      <tr>
        <td class="label">Maksud / Keperluan Surat</td>
        <td class="colon">:</td>
        <td><strong>{{ $letter->purpose }}</strong></td>
      </tr>
    </table>

    <p>
      Orang tersebut di atas adalah benar-benar warga yang berdomisili dan bertempat tinggal sah di lingkungan RT 001 / RW 05 Desa Sukamaju. Berdasarkan catatan administrasi kami, yang bersangkutan berkelakuan baik dan bermasyarakat secara rukun.
    </p>

    <p>
      Surat keterangan pengantar ini dibuat dengan sebenarnya untuk dapat dipergunakan sebagaimana mestinya dan sesuai dengan maksud peruntukannya.
    </p>
  </div>

  <!-- TANDA TANGAN & PENGESAHAN QR CODE -->
  <div class="sign-section">
    <table class="sign-table">
      <tr>
        <td class="sign-box">
          <div>Mengetahui,</div>
          <div><strong>Ketua RW 005</strong></div>
          <div style="height: 70px;"></div>
          <div><u><strong>H. SURYANTO</strong></u></div>
        </td>
        <td style="width: 10%;"></td>
        <td class="sign-box">
          <div>Sukamaju, {{ \Carbon\Carbon::parse($letter->signed_at ?? now())->isoFormat('D MMMM Y') }}</div>
          <div><strong>Ketua RT 001</strong></div>
          
          <div class="qr-badge">
            <svg width="65" height="65" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="1.8">
              <rect x="3" y="3" width="7" height="7"></rect>
              <rect x="14" y="3" width="7" height="7"></rect>
              <rect x="3" y="14" width="7" height="7"></rect>
              <rect x="14" y="14" width="7" height="7"></rect>
              <rect x="6" y="6" width="1" height="1" fill="#16a34a"></rect>
              <rect x="17" y="6" width="1" height="1" fill="#16a34a"></rect>
              <rect x="6" y="17" width="1" height="1" fill="#16a34a"></rect>
            </svg>
            <div class="qr-text">{{ $letter->qr_code_hash ?? 'WD-VERIFIED-7X8A9B2C' }}</div>
            <div style="font-size: 7pt; color: #15803d;">TERVERIFIKASI DIGITAL</div>
          </div>

          <div><u><strong>BAMBANG SUDARMONO</strong></u></div>
        </td>
      </tr>
    </table>
  </div>


  <script>
    window.addEventListener('DOMContentLoaded', () => {
      const urlParams = new URLSearchParams(window.location.search);
      if (urlParams.get('autoprint') === '1' || urlParams.get('print') === 'true') {
        setTimeout(() => {
          window.print();
        }, 500);
      }
    });
  </script>
</body>
</html>
