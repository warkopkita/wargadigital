<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <title>Warga Digital — Portal Desa Cerdas RT 001 / RW 005</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800;900&display=swap" rel="stylesheet">
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
    }
    body {
      min-height: 100vh;
      background: linear-gradient(135deg, #062c17 0%, #0B4626 50%, #047857 100%);
      color: #0f172a;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px 16px;
      position: relative;
      overflow-x: hidden;
    }
    .bg-circle-1 {
      position: absolute;
      top: -120px;
      right: -120px;
      width: 480px;
      height: 480px;
      background: radial-gradient(circle, rgba(52, 211, 153, 0.22) 0%, rgba(0,0,0,0) 70%);
      border-radius: 50%;
      pointer-events: none;
    }
    .bg-circle-2 {
      position: absolute;
      bottom: -150px;
      left: -150px;
      width: 500px;
      height: 500px;
      background: radial-gradient(circle, rgba(249, 115, 22, 0.15) 0%, rgba(0,0,0,0) 70%);
      border-radius: 50%;
      pointer-events: none;
    }
    .hub-container {
      width: 100%;
      max-width: 720px;
      z-index: 10;
    }
    .hub-header {
      text-align: center;
      margin-bottom: 28px;
    }
    .logo-badge {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 60px;
      height: 60px;
      background: rgba(255, 255, 255, 0.12);
      border: 1px solid rgba(255, 255, 255, 0.25);
      border-radius: 18px;
      margin-bottom: 14px;
      box-shadow: 0 10px 25px rgba(0,0,0,0.25);
      backdrop-filter: blur(10px);
    }
    .hub-title {
      color: #ffffff;
      font-size: 1.85rem;
      font-weight: 900;
      letter-spacing: -0.02em;
      margin-bottom: 6px;
    }
    .hub-subtitle {
      color: #a7f3d0;
      font-size: 0.95rem;
      font-weight: 600;
    }
    .hub-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 18px;
      margin-bottom: 22px;
    }
    @media (max-width: 640px) {
      .hub-grid {
        grid-template-columns: 1fr;
        gap: 14px;
      }
    }
    .portal-card {
      background: #ffffff;
      border-radius: 20px;
      padding: 24px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      text-decoration: none;
      color: inherit;
      box-shadow: 0 20px 35px rgba(0, 0, 0, 0.2);
      transition: all 0.24s cubic-bezier(0.4, 0, 0.2, 1);
      border: 2px solid transparent;
      position: relative;
      overflow: hidden;
    }
    .portal-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 25px 45px rgba(0, 0, 0, 0.28);
    }
    .card-mobile:hover {
      border-color: #10B981;
    }
    .card-web:hover {
      border-color: #F97316;
    }
    .card-tag {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 0.72rem;
      font-weight: 800;
      letter-spacing: 0.04em;
      margin-bottom: 16px;
      width: fit-content;
    }
    .tag-mobile {
      background: #ecfdf5;
      color: #047857;
    }
    .tag-web {
      background: #fff7ed;
      color: #c2410c;
    }
    .card-icon {
      font-size: 2.2rem;
      margin-bottom: 12px;
    }
    .card-title {
      font-size: 1.25rem;
      font-weight: 800;
      color: #0f172a;
      margin-bottom: 6px;
    }
    .card-desc {
      font-size: 0.85rem;
      color: #475569;
      line-height: 1.45;
      margin-bottom: 20px;
    }
    .card-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 12px;
      border-radius: 12px;
      font-size: 0.88rem;
      font-weight: 800;
      transition: background 0.2s;
    }
    .btn-mobile {
      background: #047857;
      color: #ffffff;
    }
    .card-mobile:hover .btn-mobile {
      background: #065f46;
    }
    .btn-web {
      background: #ea580c;
      color: #ffffff;
    }
    .card-web:hover .btn-web {
      background: #c2410c;
    }
    .info-card {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(255, 255, 255, 0.2);
      border-radius: 16px;
      padding: 16px 20px;
      color: #ffffff;
    }
    .info-title {
      font-size: 0.82rem;
      font-weight: 800;
      color: #fde047;
      margin-bottom: 6px;
    }
    .info-text {
      font-size: 0.78rem;
      color: #e2e8f0;
      line-height: 1.45;
    }
    .hub-footer {
      text-align: center;
      margin-top: 20px;
      color: #a7f3d0;
      font-size: 0.78rem;
    }
  </style>
</head>
<body>
  <div class="bg-circle-1"></div>
  <div class="bg-circle-2"></div>

  <div class="hub-container">
    <div class="hub-header">
      <div class="logo-badge">
        <svg width="34" height="34" viewBox="0 0 40 40" fill="none">
          <rect width="40" height="40" rx="10" fill="#10B981" />
          <circle cx="15" cy="14" r="5" fill="#F97316" />
          <circle cx="26" cy="14" r="5" fill="#FFFFFF" />
          <path d="M10 28 C 12 21, 28 21, 30 28" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" />
        </svg>
      </div>
      <h1 class="hub-title">WARGA DIGITAL</h1>
      <p class="hub-subtitle">Portal Pelayanan Cerdas RT 001 / RW 005 • Desa Sukamaju</p>
    </div>

    <div class="hub-grid">
      <!-- Portal 1: Aplikasi Mobile Warga -->
      <a href="/app/" class="portal-card card-mobile">
        <div>
          <span class="card-tag tag-mobile">📱 REKOMENDASI UNTUK HP</span>
          <div class="card-icon">📱</div>
          <h2 class="card-title">Aplikasi Warga & Linmas</h2>
          <p class="card-desc">
            Layanan pengaduan lingkungan, bayar iuran kas via QRIS/transfer, unduh kuitansi digital sah, jadwal ronda GPS, dan pantau posyandu balita.
          </p>
        </div>
        <div class="card-btn btn-mobile">
          <span>Buka Aplikasi Mobile</span>
          <span>→</span>
        </div>
      </a>

      <!-- Portal 2: Dashboard Web Pengurus -->
      <a href="/web/" class="portal-card card-web">
        <div>
          <span class="card-tag tag-web">💻 DESKTOP & PENGURUS RT</span>
          <div class="card-icon">💻</div>
          <h2 class="card-title">Dashboard Pengurus Web</h2>
          <p class="card-desc">
            Panel manajemen Ketua RT & Bendahara: verifikasi bukti transfer kas warga, persetujuan surat bertanda tangan QR digital, dan buku kas umum.
          </p>
        </div>
        <div class="card-btn btn-web">
          <span>Buka Dashboard Web</span>
          <span>→</span>
        </div>
      </a>
    </div>

    <div class="info-card">
      <div class="info-title">⚡ Login Bebas (NIK / No. WhatsApp / Gmail) • Kata Sandi: password123</div>
      <div class="info-text" style="line-height: 1.6;">
        👤 <strong>Warga:</strong> <code>3201010202950003</code> / <code>082199887766</code> / <code>warga.digital@gmail.com</code><br>
        🎖️ <strong>Ketua RT:</strong> <code>081234567890</code> / <code>ketua.rt01@gmail.com</code> / <code>rt</code><br>
        💰 <strong>Bendahara:</strong> <code>bendahara.rt@gmail.com</code> / <code>bendahara</code> • 👮 <strong>Linmas:</strong> <code>linmas</code> • 👶 <strong>Posyandu:</strong> <code>posyandu</code>
      </div>
    </div>

    <div class="hub-footer">
      © 2026 Warga Digital • Sistem Informasi Desa Mandiri Berbasis Cloud
    </div>
  </div>
</body>
</html>
