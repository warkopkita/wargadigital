<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kuitansi Pembayaran - {{ $payment->receipt_number }}</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #F1F5F9;
      margin: 0;
      padding: 24px;
      color: #0F172A;
    }
    .receipt-card {
      max-width: 620px;
      margin: 0 auto;
      background: #FFFFFF;
      border-radius: 16px;
      padding: 32px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      border: 1px solid #E2E8F0;
      position: relative;
    }
    .header-kop {
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-bottom: 2px dashed #CBD5E1;
      padding-bottom: 20px;
      margin-bottom: 24px;
    }
    .kop-brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .kop-logo {
      width: 48px;
      height: 48px;
      background: #16A34A;
      color: white;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 900;
      font-size: 20px;
    }
    .kop-text h2 {
      margin: 0;
      font-size: 18px;
      font-weight: 800;
      color: #14532D;
      letter-spacing: -0.3px;
    }
    .kop-text p {
      margin: 2px 0 0;
      font-size: 12px;
      color: #64748B;
    }
    .status-stamp {
      background: #DCFCE7;
      color: #15803D;
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 800;
      border: 1px solid #86EFAC;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    .amount-box {
      text-align: center;
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 14px;
      padding: 20px;
      margin-bottom: 24px;
    }
    .amount-label {
      font-size: 12px;
      color: #64748B;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .amount-val {
      font-size: 32px;
      font-weight: 900;
      color: #0F172A;
      margin: 4px 0;
    }
    .amount-words {
      font-size: 12px;
      color: #16A34A;
      font-weight: 700;
      font-style: italic;
    }
    .details-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 24px;
    }
    .details-table td {
      padding: 10px 4px;
      font-size: 13px;
      border-bottom: 1px solid #F1F5F9;
    }
    .details-table td:first-child {
      color: #64748B;
      width: 40%;
    }
    .details-table td:last-child {
      font-weight: 700;
      color: #0F172A;
      text-align: right;
    }
    .qr-verification-section {
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-top: 2px dashed #CBD5E1;
      padding-top: 20px;
      margin-top: 10px;
    }
    .qr-box {
      display: flex;
      align-items: center;
      gap: 14px;
    }
    .qr-img {
      width: 74px;
      height: 74px;
      border: 1px solid #E2E8F0;
      border-radius: 8px;
      padding: 4px;
    }
    .qr-meta {
      font-size: 11px;
      color: #64748B;
      line-height: 1.4;
    }
    .qr-hash {
      font-family: monospace;
      font-size: 9px;
      color: #94A3B8;
      word-break: break-all;
      max-width: 250px;
      margin-top: 4px;
    }
    .signature-box {
      text-align: center;
      font-size: 12px;
    }
    .signature-title {
      color: #64748B;
      margin-bottom: 40px;
    }
    .signature-name {
      font-weight: 800;
      color: #0F172A;
      text-decoration: underline;
    }
    .action-bar {
      margin-top: 24px;
      display: flex;
      justify-content: center;
      gap: 12px;
    }
    .btn {
      padding: 10px 20px;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 700;
      cursor: pointer;
      border: none;
      text-decoration: none;
    }
    .btn-print {
      background: #16A34A;
      color: white;
    }
    .btn-close {
      background: #E2E8F0;
      color: #334155;
    }
    @media print {
      body { background: white; padding: 0; }
      .receipt-card { box-shadow: none; border: none; padding: 10px; max-width: 100%; }
      .action-bar { display: none; }
    }
  </style>
</head>
<body>

  <div class="receipt-card">
    <!-- Header Kop -->
    <div class="header-kop">
      <div class="kop-brand">
        <div class="kop-logo">WD</div>
        <div class="kop-text">
          <h2>WARGA DIGITAL</h2>
          <p>KAS RT {{ $payment->citizen_rt ?? '001' }} / RW {{ $payment->citizen_rw ?? '005' }} • BUKTI RESMI</p>
        </div>
      </div>
      <div class="status-stamp">
        <span>✔</span> LUNAS & SAH
      </div>
    </div>

    <!-- Amount Box -->
    <div class="amount-box">
      <div class="amount-label">Jumlah Pembayaran Diterima</div>
      <div class="amount-val">Rp {{ number_format($payment->amount_paid, 0, ',', '.') }}</div>
      <div class="amount-words">"Dua Puluh Lima Ribu Rupiah"</div>
    </div>

    <!-- Transaction Details -->
    <table class="details-table">
      <tr>
        <td>No. Kuitansi Digital</td>
        <td style="color: #16A34A; font-family: monospace;">{{ $payment->receipt_number }}</td>
      </tr>
      <tr>
        <td>Nama Pembayar</td>
        <td>{{ $payment->citizen_name }}</td>
      </tr>
      <tr>
        <td>NIK KTP</td>
        <td>{{ $payment->citizen_nik }}</td>
      </tr>
      <tr>
        <td>Alamat / No. Rumah</td>
        <td>{{ $payment->citizen_address ?? 'RT 001 / RW 005' }}</td>
      </tr>
      <tr>
        <td>Jenis Iuran</td>
        <td>{{ $payment->bill_title }}</td>
      </tr>
      <tr>
        <td>Periode Bulan</td>
        <td>{{ $payment->month }} {{ $payment->year }}</td>
      </tr>
      <tr>
        <td>Metode Pembayaran</td>
        <td>{{ strtoupper(str_replace('_', ' ', $payment->payment_method)) }}</td>
      </tr>
      <tr>
        <td>Tanggal & Waktu Verifikasi</td>
        <td>{{ date('d F Y, H:i', strtotime($payment->verified_at ?? $payment->created_at)) }} WIB</td>
      </tr>
    </table>

    <!-- QR Validation & Signature -->
    <div class="qr-verification-section">
      <div class="qr-box">
        <img
          class="qr-img"
          src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data={{ urlencode(url('/receipts/' . $payment->receipt_number)) }}"
          alt="QR Verifikasi"
        />
        <div class="qr-meta">
          <strong>Tanda Tangan Elektronik Sah</strong><br>
          Pindai QR untuk verifikasi keaslian di portal desa.<br>
          <div class="qr-hash">SHA256: {{ substr($payment->qr_hash ?? 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 0, 32) }}...</div>
        </div>
      </div>

      <div class="signature-box">
        <div class="signature-title">Bendahara RT 001,</div>
        <div class="signature-name">Bambang Sudarmono</div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="action-bar">
      <button class="btn btn-print" onclick="window.print()">🖨️ Cetak / Unduh PDF</button>
      <button class="btn btn-close" onclick="window.close()">Tutup Halaman</button>
    </div>
  </div>

</body>
</html>
