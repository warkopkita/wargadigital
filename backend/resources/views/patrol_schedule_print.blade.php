<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Jadwal Resmi Siskamling & Patroli Ronda RT 001 / RW 005</title>
  <style>
    @page {
      size: A4 portrait;
      margin: 15mm 15mm 15mm 15mm;
    }
    body {
      font-family: 'Times New Roman', Times, serif;
      color: #0f172a;
      line-height: 1.5;
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
      font-size: 14pt;
      font-weight: bold;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    .kop-title-2 {
      font-size: 16pt;
      font-weight: bold;
      text-transform: uppercase;
    }
    .kop-sub {
      font-size: 9.5pt;
      margin-top: 2px;
      color: #334155;
    }
    .divider-double {
      border: none;
      border-top: 3px solid #000;
      border-bottom: 1px solid #000;
      height: 4px;
      margin: 10px 0 16px 0;
    }
    .doc-title {
      text-align: center;
      margin-bottom: 18px;
    }
    .doc-title h2 {
      font-size: 13pt;
      font-weight: bold;
      text-transform: uppercase;
      text-decoration: underline;
      margin: 0;
    }
    .doc-title p {
      font-size: 10pt;
      margin-top: 4px;
      color: #475569;
    }
    .info-box {
      background: #f8fafc;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      padding: 10px 14px;
      margin-bottom: 16px;
      font-size: 9.5pt;
      display: flex;
      justify-content: space-between;
    }
    table.data-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 18px;
      font-size: 9.5pt;
    }
    table.data-table th, table.data-table td {
      border: 1px solid #334155;
      padding: 6px 8px;
      vertical-align: top;
    }
    table.data-table th {
      background-color: #f1f5f9;
      font-weight: bold;
      text-align: center;
      text-transform: uppercase;
      font-size: 9pt;
    }
    .badge-hadir {
      display: inline-block;
      padding: 2px 6px;
      background: #dcfce7;
      color: #166534;
      border-radius: 4px;
      font-weight: bold;
      font-size: 8pt;
    }
    .badge-terjadwal {
      display: inline-block;
      padding: 2px 6px;
      background: #fef3c7;
      color: #92400e;
      border-radius: 4px;
      font-weight: bold;
      font-size: 8pt;
    }
    .rules-box {
      border: 1px solid #cbd5e1;
      background: #fafafa;
      padding: 10px 14px;
      border-radius: 6px;
      font-size: 8.5pt;
      margin-bottom: 20px;
    }
    .rules-box h4 {
      margin: 0 0 6px 0;
      font-size: 9pt;
      text-transform: uppercase;
    }
    .rules-box ol {
      margin: 0;
      padding-left: 18px;
    }
    .rules-box li {
      margin-bottom: 3px;
    }
    .signature-grid {
      display: flex;
      justify-content: space-between;
      margin-top: 20px;
      page-break-inside: avoid;
    }
    .sig-col {
      text-align: center;
      width: 30%;
      font-size: 9.5pt;
    }
    .sig-space {
      height: 55px;
    }
    .sig-name {
      font-weight: bold;
      text-decoration: underline;
    }
    .no-print-bar {
      background: #0f172a;
      color: #fff;
      padding: 12px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin: -24px -24px 24px -24px;
    }
    .btn-print {
      background: #16a34a;
      color: #fff;
      border: none;
      padding: 8px 18px;
      font-weight: bold;
      border-radius: 6px;
      cursor: pointer;
      font-size: 13px;
    }
    @media print {
      .no-print-bar {
        display: none !important;
      }
      body {
        padding: 0;
      }
    }
  </style>
</head>
<body>

  <!-- Top Action Bar (Hidden when printed) -->
  <div class="no-print-bar">
    <div>
      <strong>Sistem Manajemen Siskamling Digital RT 001 / RW 005</strong>
      <span style="font-size: 12px; color: #94a3b8; margin-left: 10px;">Siap Cetak Format A4</span>
    </div>
    <button class="btn-print" onclick="window.print()">🖨️ Cetak / Simpan PDF Jadwal</button>
  </div>

  <!-- KOP SURAT RESMI -->
  <div class="header-container">
    <div class="kop-title-1">RUKUN TETANGGA 001 / RUKUN WARGA 005</div>
    <div class="kop-title-2">KORPS SISTEM KEAMANAN LINGKUNGAN (SISKAMLING)</div>
    <div class="kop-sub">Kelurahan Sukamaju, Kecamatan Cilandak, Kota Jakarta Selatan, DKI Jakarta 12430</div>
    <div class="kop-sub">Hotline Keamanan & Pos Ronda: 0812-9988-7766 • Email: keamanan.rt001rw005@gmail.com</div>
  </div>

  <div class="divider-double"></div>

  <!-- JUDUL DOKUMEN -->
  <div class="doc-title">
    <h2>JADWAL TUGAS RONDA MALAM & PATROLI SISKAMLING</h2>
    <p>Periode: <strong>Bulan {{ \Carbon\Carbon::now()->translatedFormat('F Y') }}</strong> • Zona Wilayah: RT 001 / RW 005</p>
  </div>

  <div class="info-box">
    <div><strong>Jam Tugas:</strong> 22:00 WIB s/d 04:00 WIB</div>
    <div><strong>Pos Induk:</strong> Pos Ronda Utama RT 001 (Portal Barat)</div>
    <div><strong>Titik Checkpoint QR:</strong> Pos Utama, Portal Barat, Gardu Timur</div>
  </div>

  <!-- TABEL JADWAL -->
  <table class="data-table">
    <thead>
      <tr>
        <th style="width: 5%;">No</th>
        <th style="width: 18%;">Hari & Tanggal</th>
        <th style="width: 18%;">Shift & Pos Jaga</th>
        <th>Daftar Anggota Regu Ronda (Warga / Linmas)</th>
        <th style="width: 15%;">Catatan Wilayah</th>
      </tr>
    </thead>
    <tbody>
      @forelse($schedules as $idx => $sched)
      <tr>
        <td style="text-align: center; font-weight: bold;">{{ $idx + 1 }}</td>
        <td>
          <strong>{{ $sched->day_name }}</strong><br>
          <span style="color: #475569; font-size: 8.5pt;">{{ \Carbon\Carbon::parse($sched->patrol_date)->translatedFormat('d F Y') }}</span>
        </td>
        <td>
          <span style="font-weight: 600;">{{ $sched->shift_name }}</span><br>
          <span style="font-size: 8pt; color: #64748b;">RT {{ $sched->rt }} / RW {{ $sched->rw }}</span>
        </td>
        <td>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 4px;">
            @forelse($sched->members as $m)
              <div>
                • <strong>{{ $m->name }}</strong>
                <span style="font-size: 8pt; color: #475569;">({{ $m->phone }})</span>
                @if($m->has_checked_in)
                  <span class="badge-hadir">Hadir</span>
                @else
                  <span class="badge-terjadwal">Piket</span>
                @endif
              </div>
            @empty
              <span style="font-style: italic; color: #94a3b8;">Belum ada regu ditugaskan</span>
            @endforelse
          </div>
        </td>
        <td style="font-size: 8.5pt;">
          {{ $sched->notes ?: 'Patroli keliling gang 1-4 dan portal gerbang utama.' }}
        </td>
      </tr>
      @empty
      <tr>
        <td colspan="5" style="text-align: center; padding: 20px;">Belum ada data jadwal ronda untuk periode ini.</td>
      </tr>
      @endforelse
    </tbody>
  </table>

  <!-- KETENTUAN DAN TATA TERTIB -->
  <div class="rules-box">
    <h4>Ketentuan & Tata Tertib Siskamling RT 001 / RW 005:</h4>
    <ol>
      <li>Petugas ronda wajib hadir tepat waktu di Pos Ronda Utama pukul 22:00 WIB dan melakukan presensi / scan QR Checkpoint melalui aplikasi <strong>Warga Digital</strong>.</li>
      <li>Patroli keliling lingkungan dilakukan bertahap sekurang-kurangnya 3 (tiga) kali: Pukul 23:30 WIB, 01:30 WIB, dan 03:30 WIB dengan memantau portal pembatas jalan.</li>
      <li>Warga yang berhalangan hadir wajib mengajukan permohonan <strong>Tukar Jadwal</strong> atau <strong>Izin Tidak Hadir</strong> melalui aplikasi selambat-lambatnya H-1.</li>
      <li>Bagi warga yang tidak hadir tanpa keterangan (*Alpha*), diberlakukan uang kompensasi jimpitan/denda ronda sebesar <strong>Rp 25.000,-</strong> yang disetorkan langsung ke Kas RT 001.</li>
      <li>Dalam keadaan darurat / mencurigakan, segera bunyikan kentongan bahaya atau tekan <strong>Tombol Panic Button</strong> di aplikasi Warga Digital.</li>
    </ol>
  </div>

  <!-- TANDA TANGAN PENGURUS -->
  <div class="signature-grid">
    <div class="sig-col">
      <div>Mengetahui,</div>
      <div><strong>Ketua RW 005</strong></div>
      <div class="sig-space"></div>
      <div class="sig-name">H. Bambang Pamungkas</div>
      <div style="font-size: 8pt; color: #475569;">RW 005 Kel. Sukamaju</div>
    </div>

    <div class="sig-col">
      <div>Koordinator Keamanan,</div>
      <div><strong>Komandan Linmas / Hansip</strong></div>
      <div class="sig-space"></div>
      <div class="sig-name">Sutrisno Wibowo</div>
      <div style="font-size: 8pt; color: #475569;">Linmas Inti RT 001</div>
    </div>

    <div class="sig-col">
      <div>Jakarta Selatan, {{ \Carbon\Carbon::now()->translatedFormat('d F Y') }}</div>
      <div><strong>Ketua RT 001</strong></div>
      <div class="sig-space"></div>
      <div class="sig-name">Hendra Gunawan</div>
      <div style="font-size: 8pt; color: #475569;">Pengurus RT 001 / RW 005</div>
    </div>
  </div>

</body>
</html>
