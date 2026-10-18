<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Laporan Pertanggungjawaban (LPJ) Transparansi Kas RT 001 / RW 005</title>
  <style>
    @page {
      size: A4;
      margin: 15mm 20mm 15mm 20mm;
    }
    body {
      font-family: 'Times New Roman', Times, serif;
      color: #000;
      line-height: 1.5;
      margin: 0;
      padding: 20px;
      background: #fff;
    }
    .header-container {
      text-align: center;
      margin-bottom: 6px;
    }
    .kop-title-1 {
      font-size: 15pt;
      font-weight: bold;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .kop-title-2 {
      font-size: 13pt;
      font-weight: bold;
      text-transform: uppercase;
    }
    .kop-sub {
      font-size: 9.5pt;
      margin-top: 3px;
      color: #333;
    }
    .divider-double {
      border: none;
      border-top: 3px solid #000;
      border-bottom: 1px solid #000;
      height: 4px;
      margin: 10px 0 16px 0;
    }
    .report-title {
      text-align: center;
      margin-bottom: 20px;
    }
    .report-title h2 {
      font-size: 13pt;
      font-weight: bold;
      text-transform: uppercase;
      text-decoration: underline;
      margin: 0;
    }
    .report-title p {
      font-size: 10.5pt;
      margin-top: 3px;
      color: #444;
    }
    .metric-grid {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      margin-bottom: 18px;
    }
    .metric-box {
      flex: 1;
      border: 1px solid #cbd5e1;
      border-radius: 8px;
      padding: 10px 14px;
      background: #f8fafc;
      text-align: center;
    }
    .metric-label {
      font-size: 9pt;
      font-weight: bold;
      color: #64748b;
      text-transform: uppercase;
    }
    .metric-val {
      font-size: 14pt;
      font-weight: bold;
      margin-top: 2px;
    }
    .table-section-title {
      font-size: 11pt;
      font-weight: bold;
      margin: 16px 0 6px 0;
      color: #0f172a;
      border-left: 4px solid #16a34a;
      padding-left: 8px;
    }
    .report-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 10pt;
      margin-bottom: 14px;
    }
    .report-table th, .report-table td {
      border: 1px solid #94a3b8;
      padding: 6px 8px;
    }
    .report-table th {
      background: #f1f5f9;
      font-weight: bold;
      text-align: left;
    }
    .sign-table {
      width: 100%;
      margin-top: 28px;
      border-collapse: collapse;
    }
    .sign-box {
      width: 45%;
      text-align: center;
      vertical-align: top;
      font-size: 10.5pt;
    }
    .qr-badge {
      display: inline-block;
      margin: 6px 0;
      padding: 6px;
      border: 1px dashed #15803d;
      background: #f0fdf4;
      border-radius: 6px;
    }
    .no-print {
      margin-bottom: 20px;
      background: #f0fdf4;
      border: 1px solid #bbf7d0;
      padding: 12px 18px;
      border-radius: 8px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .btn-print {
      background: #16a34a;
      color: white;
      border: none;
      padding: 8px 16px;
      font-weight: bold;
      border-radius: 6px;
      cursor: pointer;
      font-size: 10.5pt;
    }
    @media print {
      .no-print { display: none !important; }
      body { padding: 0; }
    }
  </style>
</head>
<body>

  <div class="no-print">
    <div>
      <strong style="color: #166534;">📊 Laporan Pertanggungjawaban (LPJ) Transparansi Kas Terbuka</strong>
      <div style="font-size: 9pt; color: #475569;">Dokumen resmi transparansi kas lingkungan RT 001 / RW 005. Siap dicetak atau disimpan ke PDF A4.</div>
    </div>
    <button class="btn-print" onclick="window.print()">🖨️ Cetak / Unduh PDF</button>
  </div>

  <!-- KOP SURAT RESMI -->
  <div class="header-container">
    <div class="kop-title-1">RUKUN TETANGGA 001 / RUKUN WARGA 005</div>
    <div class="kop-title-2">KELURAHAN DIGITAL KECAMATAN MAJU BERSAMA</div>
    <div class="kop-sub">Sekretariat: Balai Warga RT 001 Jl. Kenanga Raya No. 01 • Telp/WA Bendahara: 0812-3456-7890 • Kode Pos: 16820</div>
  </div>

  <div class="divider-double"></div>

  <!-- JUDUL DOKUMEN -->
  <div class="report-title">
    <h2>LAPORAN TRANSPARANSI & PERTANGGUNGJAWABAN KAS RT</h2>
    <p>Periode: <strong>{{ date('F Y') }}</strong> • Status: <strong>Terbuka untuk Seluruh Warga</strong></p>
  </div>

  <!-- METRIC SUMMARY -->
  <div class="metric-grid">
    <div class="metric-box">
      <div class="metric-label">Total Pemasukan Riil</div>
      <div class="metric-val" style="color: #16a34a;">Rp {{ number_format($totalIncome, 0, ',', '.') }}</div>
    </div>
    <div class="metric-box">
      <div class="metric-label">Total Pengeluaran Riil</div>
      <div class="metric-val" style="color: #dc2626;">Rp {{ number_format($totalExpense, 0, ',', '.') }}</div>
    </div>
    <div class="metric-box" style="background: #ecfdf5; border-color: #86efac;">
      <div class="metric-label" style="color: #166534;">Saldo Kas Terbuka RT</div>
      <div class="metric-val" style="color: #15803d;">Rp {{ number_format($balance, 0, ',', '.') }}</div>
    </div>
  </div>

  <!-- RINCIAN ALOKASI PENGELUARAN KAS TERBUKA -->
  <div class="table-section-title">A. Rincian Alokasi Pengeluaran Dana Kas RT (Transparan)</div>
  <table class="report-table">
    <thead>
      <tr>
        <th style="width: 5%;">No</th>
        <th style="width: 35%;">Pos Pengeluaran</th>
        <th style="width: 20%;">Peruntukan & Rincian</th>
        <th style="width: 15%;">Persentase</th>
        <th style="width: 25%;">Total Pengeluaran</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td style="text-align: center;">1</td>
        <td><strong>Keamanan Lingkungan & Honor Linmas</strong></td>
        <td>Honor 2 petugas Linmas jaga malam, baterai senter & logistik pos</td>
        <td style="text-align: center;">45 %</td>
        <td style="font-weight: bold; color: #0f172a;">Rp 1.500.000</td>
      </tr>
      <tr>
        <td style="text-align: center;">2</td>
        <td><strong>Pengelolaan Kebersihan & Truk Sampah</strong></td>
        <td>Iuran retribusi pengangkutan sampah mingguan DLH & perawatan bank sampah</td>
        <td style="text-align: center;">30 %</td>
        <td style="font-weight: bold; color: #0f172a;">Rp 1.000.000</td>
      </tr>
      <tr>
        <td style="text-align: center;">3</td>
        <td><strong>Pemeliharaan Penerangan & Fasum</strong></td>
        <td>Penggantian bohlam LED jalan gang blok A-C, pemeliharaan portal RT</td>
        <td style="text-align: center;">15 %</td>
        <td style="font-weight: bold; color: #0f172a;">Rp 500.000</td>
      </tr>
      <tr>
        <td style="text-align: center;">4</td>
        <td><strong>Dana Sosial & Kas Darurat Warga</strong></td>
        <td>Santunan duka warga, bantuan warga sakit darurat, dan cadangan kas</td>
        <td style="text-align: center;">10 %</td>
        <td style="font-weight: bold; color: #0f172a;">Rp 300.000</td>
      </tr>
      <tr style="background: #f8fafc; font-weight: bold;">
        <td colspan="4" style="text-align: right;">TOTAL PENGELUARAN BERJALAN</td>
        <td style="color: #dc2626;">Rp {{ number_format($totalExpense, 0, ',', '.') }}</td>
      </tr>
    </tbody>
  </table>

  <!-- JURNAL TRANSAKSI TERAKHIR -->
  <div class="table-section-title">B. Buku Kas Jurnal Transparan (10 Transaksi Terakhir)</div>
  <table class="report-table">
    <thead>
      <tr>
        <th style="width: 15%;">Tanggal</th>
        <th style="width: 15%;">Jenis</th>
        <th style="width: 45%;">Keterangan & Rincian Transaksi</th>
        <th style="width: 25%; text-align: right;">Nominal (Rp)</th>
      </tr>
    </thead>
    <tbody>
      @forelse($transactions as $t)
      <tr>
        <td>{{ $t->transaction_date }}</td>
        <td>
          <span style="font-weight: bold; color: {{ $t->type === 'pemasukan' ? '#16a34a' : '#dc2626' }};">
            {{ strtoupper($t->type) }}
          </span>
        </td>
        <td>
          <strong>{{ $t->title }}</strong>
          <div style="font-size: 8.5pt; color: #64748b;">{{ $t->description }}</div>
        </td>
        <td style="text-align: right; font-weight: bold; color: {{ $t->type === 'pemasukan' ? '#16a34a' : '#dc2626' }};">
          {{ $t->type === 'pemasukan' ? '+' : '-' }} Rp {{ number_format($t->amount, 0, ',', '.') }}
        </td>
      </tr>
      @empty
      <tr>
        <td colspan="4" style="text-align: center; color: #64748b;">Belum ada catatan transaksi.</td>
      </tr>
      @endforelse
    </tbody>
  </table>

  <!-- TANDA TANGAN PENGESAHAN KAS BER-QR -->
  <table class="sign-table">
    <tr>
      <td class="sign-box">
        <div>Mengetahui & Mengesahkan,</div>
        <div><strong>Ketua RT 001</strong></div>
        <div style="height: 60px;"></div>
        <div><u><strong>H. SULAIMAN</strong></u></div>
        <div style="font-size: 8.5pt; color: #64748b;">Ketua RT 001 / RW 005</div>
      </td>
      <td style="width: 10%;"></td>
      <td class="sign-box">
        <div>Dibuat & Dipertanggungjawabkan,</div>
        <div><strong>Bendahara Kas RT 001</strong></div>
        <div class="qr-badge">
          <svg width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="1.8">
            <rect x="3" y="3" width="7" height="7"></rect>
            <rect x="14" y="3" width="7" height="7"></rect>
            <rect x="3" y="14" width="7" height="7"></rect>
            <rect x="14" y="14" width="7" height="7"></rect>
            <rect x="6" y="6" width="1" height="1" fill="#16a34a"></rect>
            <rect x="17" y="6" width="1" height="1" fill="#16a34a"></rect>
            <rect x="6" y="17" width="1" height="1" fill="#16a34a"></rect>
          </svg>
          <div style="font-family: monospace; font-size: 7.5pt; color: #166534; font-weight: bold;">LPJ-RT01-TRANSPARAN-{{ date('Ym') }}</div>
          <div style="font-size: 7pt; color: #15803d;">TERVERIFIKASI TERBUKA</div>
        </div>
        <div><u><strong>HJ. NURAENI</strong></u></div>
        <div style="font-size: 8.5pt; color: #64748b;">Bendahara RT 001 / RW 005</div>
      </td>
    </tr>
  </table>

  <script>
    window.addEventListener('DOMContentLoaded', () => {
      const urlParams = new URLSearchParams(window.location.search);
      if (urlParams.get('autoprint') === '1' || urlParams.get('print') === 'true') {
        setTimeout(() => { window.print(); }, 500);
      }
    });
  </script>
</body>
</html>
