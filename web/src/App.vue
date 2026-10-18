<template>
  <!-- 0. LOGIN PAGE (WHEN NOT AUTHENTICATED) -->
  <div v-if="!currentUser" class="login-page">
    <div class="login-bg-decor"></div>
    <div class="login-container">
      <div class="login-brand-header">
        <div class="login-logo-circle">
          <svg width="44" height="44" viewBox="0 0 40 40" fill="none">
            <rect width="40" height="40" rx="10" fill="#047857" />
            <circle cx="15" cy="14" r="5" fill="#F97316" />
            <circle cx="26" cy="14" r="5" fill="#34D399" />
            <path d="M10 28 C 12 21, 28 21, 30 28" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" />
          </svg>
        </div>
        <h1 class="login-title">WARGA DIGITAL</h1>
        <p class="login-subtitle">Sistem Informasi & Administrasi Desa Mandiri • RT 001 / RW 005</p>
      </div>

      <div class="login-card">
        <div class="login-card-header">
          <h2>Masuk ke Panel Web</h2>
          <p>Pilih akun demo sesuai peran, atau masukkan NIK dan kata sandi Anda:</p>
        </div>

        <!-- 1-Tap Quick Role Pills (Simplified & Sleek) -->
        <div class="login-quick-section">
          <div class="quick-title">⚡ Pilih Cepat Berdasarkan Peran (1-Klik):</div>
          <div class="quick-role-pills">
            <button
              v-for="role in demoRoles"
              :key="role.role"
              type="button"
              class="quick-pill-btn"
              :style="{ borderColor: role.text_color, color: role.text_color, background: role.bg_color }"
              :disabled="loginLoading"
              @click="selectDemoRole(role)"
            >
              <component :is="role.iconComponent" size="14" />
              <span>{{ role.label }}</span>
            </button>
          </div>
        </div>

        <div class="login-divider">
          <span>atau masuk dengan NIK / No. WhatsApp / Gmail</span>
        </div>

        <!-- Manual Login Form -->
        <form @submit.prevent="handleLoginSubmit" class="login-form">
          <div v-if="loginError" class="login-error-alert">
            <AlertCircle size="16" />
            <span>{{ loginError }}</span>
          </div>

          <div class="form-group" style="margin-bottom: 14px;">
            <label class="form-label">NIK / No. WhatsApp / Gmail / Peran</label>
            <div class="input-with-icon">
              <User size="16" class="input-icon" />
              <input
                v-model="loginForm.nik"
                type="text"
                class="form-control"
                placeholder="Contoh: 32010101... / 0812... / akun@gmail.com / rt"
                required
              />
            </div>
          </div>

          <div class="form-group" style="margin-bottom: 18px;">
            <label class="form-label">Kata Sandi</label>
            <div class="input-with-icon">
              <Lock size="16" class="input-icon" />
              <input
                v-model="loginForm.password"
                type="password"
                class="form-control"
                placeholder="Kata sandi akun (demo: password123)"
                required
              />
            </div>
          </div>

          <button
            type="submit"
            class="btn-primary login-btn"
            :disabled="loginLoading"
          >
            <RefreshCw v-if="loginLoading" size="16" class="spin-anim" />
            <span v-else>Masuk ke Sistem</span>
          </button>
        </form>
      </div>

      <div class="login-footer">
        <p>© 2026 Warga Digital • Dikembangkan untuk Pemerintahan Desa & Pengurus RT/RW</p>
      </div>
    </div>
  </div>

  <!-- 1. MAIN APP CONTAINER (WHEN AUTHENTICATED) -->
  <div v-else class="app-container">
    <!-- Mobile Backdrop -->
    <div
      v-if="mobileNavOpen"
      class="modal-overlay"
      style="z-index: 39;"
      @click="mobileNavOpen = false"
    ></div>

    <!-- Sidebar Navigation (Deep Emerald Green #0B4626) -->
    <aside class="sidebar" :class="{ 'mobile-open': mobileNavOpen }">
      <div class="sidebar-header">
        <!-- Stylized Warga Digital Brand Mark -->
        <div class="brand-icon" style="background: transparent; box-shadow: none; width: 34px; height: 34px;">
          <svg width="34" height="34" viewBox="0 0 40 40" fill="none">
            <rect width="40" height="40" rx="10" fill="#047857" />
            <circle cx="15" cy="14" r="5" fill="#F97316" />
            <circle cx="26" cy="14" r="5" fill="#34D399" />
            <path d="M10 28 C 12 21, 28 21, 30 28" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" />
          </svg>
        </div>
        <div class="brand-text">
          <h1>WARGA DIGITAL</h1>
          <p>PORTAL DESA CERDAS</p>
        </div>
      </div>

      <nav class="sidebar-nav">
        <a
          v-for="item in navItems"
          :key="item.id"
          class="nav-item"
          :class="{ active: currentTab === item.id }"
          @click="selectTab(item.id)"
        >
          <component :is="item.icon" size="18" />
          <span>{{ item.label }}</span>
          <span v-if="item.badge" class="nav-badge">{{ item.badge }}</span>
        </a>
      </nav>

      <div class="sidebar-footer">
        <div class="user-card" style="cursor: pointer;" @click="showSettingsModal = true">
          <div class="user-avatar" style="background: rgba(255,255,255,0.15); color: #86EFAC;">
            <Settings size="18" />
          </div>
          <div class="user-info">
            <p class="user-name">{{ villageConfig.village_name }}</p>
            <p class="user-role">RT {{ villageConfig.rt }} / RW {{ villageConfig.rw }} ⚙️</p>
          </div>
        </div>

        <!-- Tombol Logout Jelas di Sidebar -->
        <button
          class="sidebar-logout-btn"
          @click="confirmLogout"
          title="Keluar dari akun saat ini"
        >
          <LogOut size="16" />
          <span>Keluar (Logout)</span>
        </button>
      </div>
    </aside>

    <!-- Main Content Wrapper -->
    <div class="main-wrapper">
      <!-- Topbar Header (Matching Laptop Reference Photo) -->
      <header class="topbar">
        <!-- Left: Administrasi Desa / Warga Digital -->
        <div class="topbar-brand">
          <span class="topbar-subheading">ADMINISTRASI DESA</span>
          <h2 class="topbar-heading">WARGA DIGITAL</h2>
        </div>

        <!-- Center: Search Bar Pill -->
        <div class="topbar-search">
          <Search size="16" class="search-icon" />
          <input
            v-model="globalSearch"
            type="text"
            placeholder="Cari data atau layanan..."
          />
        </div>

        <!-- Right: Notification & Admin Profile with Dropdown -->
        <!-- Right: Notification & Admin Profile with Dropdown -->
        <div class="topbar-profile" style="position: relative;">
          <!-- Notification Bell with Interactive Dropdown -->
          <div style="position: relative;">
            <button
              class="notification-bell-btn"
              title="Pemberitahuan Warga & RT"
              @click.stop="toggleNotificationsDropdown"
            >
              <Bell size="18" />
              <span v-if="unreadNotificationsCount > 0" class="notification-dot"></span>
            </button>

            <!-- Dropdown Notifications Menu -->
            <div
              v-if="showNotificationsDropdown"
              class="notifications-dropdown-menu"
              @click.stop
            >
              <div class="notif-header">
                <div>
                  <div class="notif-title">Pemberitahuan & Notifikasi</div>
                  <div class="notif-subtitle">{{ unreadNotificationsCount }} belum dibaca</div>
                </div>
                <button
                  v-if="unreadNotificationsCount > 0"
                  class="notif-mark-read-btn"
                  @click="markAllNotificationsRead"
                >
                  <Check size="13" />
                  <span>Tandai Dibaca</span>
                </button>
              </div>

              <!-- Filter tabs -->
              <div class="notif-filter-tabs">
                <button
                  class="notif-filter-chip"
                  :class="{ active: notifFilter === 'all' }"
                  @click="notifFilter = 'all'"
                >
                  Semua ({{ notificationsList.length }})
                </button>
                <button
                  class="notif-filter-chip"
                  :class="{ active: notifFilter === 'unread' }"
                  @click="notifFilter = 'unread'"
                >
                  Belum Dibaca ({{ unreadNotificationsCount }})
                </button>
                <button
                  class="notif-filter-chip"
                  :class="{ active: notifFilter === 'kas' }"
                  @click="notifFilter = 'kas'"
                >
                  Kas & Tagihan
                </button>
              </div>

              <!-- Notifications list -->
              <div class="notif-list">
                <div
                  v-for="item in filteredNotifications"
                  :key="item.id"
                  class="notif-item"
                  :class="{ 'notif-unread': !item.read }"
                  @click="handleNotificationClick(item)"
                >
                  <div class="notif-icon-wrap" :style="{ background: item.bgColor, color: item.color }">
                    <component :is="item.icon" size="16" />
                  </div>
                  <div class="notif-content">
                    <div class="notif-item-header">
                      <span class="notif-item-title">{{ item.title }}</span>
                      <span class="notif-time">{{ item.time }}</span>
                    </div>
                    <p class="notif-message">{{ item.message }}</p>
                    <div class="notif-footer-row">
                      <span class="notif-action-link">{{ item.actionText }} ↗</span>
                      <span v-if="!item.read" class="notif-badge-new">Baru</span>
                    </div>
                  </div>
                </div>

                <div v-if="filteredNotifications.length === 0" class="notif-empty">
                  Tidak ada pemberitahuan pada kategori ini.
                </div>
              </div>

              <div class="notif-footer">
                <button class="notif-view-all" @click="selectTab('complaints'); showNotificationsDropdown = false">
                  Buka Menu Pengaduan & Layanan Terkait ↗
                </button>
              </div>
            </div>
          </div>

          <!-- Profile Pill -->
          <div class="admin-profile-pill" title="Menu Akun & Logout" @click="showUserDropdown = !showUserDropdown">
            <div class="admin-avatar" :style="{ background: getRoleColor(currentUser?.role) }">
              <User size="18" />
            </div>
            <div class="admin-meta">
              <span class="admin-name">{{ currentUser?.name || 'Bambang Sudarmono' }}</span>
              <span class="admin-role">{{ getRoleBadgeText(currentUser?.role) }}</span>
            </div>
            <ChevronDown
              size="15"
              style="color: #64748B; transition: transform 0.2s;"
              :style="{ transform: showUserDropdown ? 'rotate(180deg)' : 'none' }"
            />
          </div>

          <!-- Dropdown Profile Menu with Logout -->
          <div v-if="showUserDropdown" class="profile-dropdown-menu">
            <div class="dropdown-header">
              <div class="dropdown-user-name">{{ currentUser?.name }}</div>
              <div class="dropdown-user-sub">NIK: {{ currentUser?.nik || '-' }}</div>
              <div class="dropdown-role-tag" :style="{ background: getRoleBgColor(currentUser?.role), color: getRoleTextColor(currentUser?.role) }">
                {{ getRoleBadgeText(currentUser?.role) }}
              </div>
            </div>
            <div class="dropdown-divider"></div>
            <button class="dropdown-item" @click="showSettingsModal = true; showUserDropdown = false">
              <Settings size="15" />
              <span>Pengaturan Wilayah RT</span>
            </button>
            <button class="dropdown-item" @click="showSwitchRoleModal = true; showUserDropdown = false">
              <RefreshCw size="15" />
              <span>Ganti Akun / Peran</span>
            </button>
            <div class="dropdown-divider"></div>
            <button class="dropdown-item dropdown-item-danger" @click="confirmLogout">
              <LogOut size="15" />
              <span>Keluar (Logout)</span>
            </button>
          </div>
        </div>
      </header>

      <!-- Main Content Body -->
      <main class="content-body">
        <!-- Emergency Alert Banner if any -->
        <div v-if="activeEmergency" class="emergency-banner">
          <div style="display: flex; align-items: center; gap: 12px;">
            <AlertTriangle size="24" />
            <div>
              <strong>🚨 PERINGATAN DARURAT: {{ activeEmergency.emergency_type.toUpperCase() }}</strong>
              <p style="font-size: 0.84rem; opacity: 0.95;">
                Dilaporkan oleh {{ activeEmergency.citizen_name }} ({{ activeEmergency.citizen_phone }}) — {{ activeEmergency.details || 'Membutuhkan bantuan warga segera!' }}
              </p>
            </div>
          </div>
          <button class="btn-outline" style="background: white; color: #dc2626; border: none; font-weight: 700;" @click="activeEmergency = null">
            Tandai Selesai
          </button>
        </div>

        <!-- 1. TAB: DASHBOARD OVERVIEW (Matching Reference Laptop Photo) -->
        <div v-if="currentTab === 'dashboard'">
          <h2 style="font-size: 1.5rem; font-weight: 800; color: #0F172A; margin-bottom: 20px;">Dashboard</h2>

          <!-- Row 1: 3 Stat Cards -->
          <div class="dashboard-metrics-grid">
            <!-- Card 1: Total Warga -->
            <div class="ref-stat-card">
              <div class="ref-stat-title">Total Warga</div>
              <div class="ref-stat-value">
                {{ stats.total_citizens ? formatNumber(stats.total_citizens) : '1.240' }}
                <span class="ref-stat-arrow">↗</span>
              </div>
              <div class="ref-stat-footer">
                <span class="ref-stat-subtext">Total {{ stats.total_citizens ? formatNumber(stats.total_citizens) : '1.240' }} Warga</span>
              </div>
            </div>

            <!-- Card 2: Pengajuan Surat -->
            <div class="ref-stat-card">
              <div class="ref-stat-title">Pengajuan Surat</div>
              <div class="ref-stat-value">
                {{ stats.pending_letters || 18 }}
              </div>
              <div class="ref-stat-footer">
                <span class="ref-stat-pill">Status Keuangan</span>
              </div>
            </div>

            <!-- Card 3: Saldo Kas Darurat -->
            <div class="ref-stat-card">
              <div class="ref-stat-title">Saldo Kas Darurat</div>
              <div class="ref-stat-value" style="font-size: 1.65rem;">
                {{ stats.treasury?.balance ? formatRupiah(stats.treasury.balance) : 'Rp 45.200.000' }}
              </div>
              <div class="ref-stat-footer">
                <span class="ref-stat-pill">Status Keuangan</span>
              </div>
            </div>
          </div>

          <!-- Row 2: Split Row (60% Table, 40% Chart) -->
          <div class="dashboard-split-row">
            <!-- Left Card: Pengajuan Surat Terbaru -->
            <div class="ref-card">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                <h3 class="ref-card-title" style="margin-bottom: 0;">Pengajuan Surat Terbaru</h3>
                <button class="btn-outline" style="font-size: 0.74rem; padding: 4px 10px;" @click="selectTab('letters')">
                  Lihat Semua →
                </button>
              </div>
              <div style="overflow-x: auto;">
                <table class="ref-table">
                  <thead>
                    <tr>
                      <th>Nama</th>
                      <th>Jenis Surat</th>
                      <th>Tanggal</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(letter, idx) in recentLettersDisplay" :key="idx">
                      <td style="font-weight: 700;">{{ letter.name }}</td>
                      <td style="color: #475569;">{{ letter.type }}</td>
                      <td style="color: #64748B;">{{ letter.date }}</td>
                      <td>
                        <span :class="letter.status === 'Selesai' ? 'badge-selesai-rt' : 'badge-menunggu-rt'">
                          {{ letter.status }}
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Right Card: Arus Kas Darurat Bulanan -->
            <div class="ref-card">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <h3 class="ref-card-title" style="margin-bottom: 0;">Arus Kas Darurat Bulanan</h3>
                <button class="btn-outline" style="font-size: 0.74rem; padding: 4px 10px;" @click="selectTab('treasury')">
                  Detail Kas →
                </button>
              </div>
              <div class="chart-container">
                <!-- SVG Area Spline Chart Matching Reference -->
                <svg viewBox="0 0 400 200" style="width: 100%; height: 100%; overflow: visible;">
                  <defs>
                    <linearGradient id="areaGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                      <stop offset="0%" stop-color="#16A34A" stop-opacity="0.45" />
                      <stop offset="45%" stop-color="#EA580C" stop-opacity="0.35" />
                      <stop offset="100%" stop-color="#EA580C" stop-opacity="0.03" />
                    </linearGradient>
                  </defs>

                  <!-- Horizontal Grid Lines -->
                  <g stroke="#F1F5F9" stroke-width="1">
                    <line x1="30" y1="20" x2="390" y2="20" />
                    <line x1="30" y1="55" x2="390" y2="55" />
                    <line x1="30" y1="90" x2="390" y2="90" />
                    <line x1="30" y1="125" x2="390" y2="125" />
                    <line x1="30" y1="160" x2="390" y2="160" />
                  </g>

                  <!-- Y-Axis Labels (100, 80, 60, 40, 20, 0) -->
                  <g font-size="10" fill="#94A3B8" text-anchor="end" font-weight="500">
                    <text x="24" y="24">100</text>
                    <text x="24" y="59">80</text>
                    <text x="24" y="94">60</text>
                    <text x="24" y="129">40</text>
                    <text x="24" y="164">20</text>
                    <text x="24" y="180">0</text>
                  </g>

                  <!-- Area Curve Filled with Gradient -->
                  <path
                    d="M 30,175 C 60,110 80,95 110,105 C 140,115 160,140 190,120 C 220,95 240,40 270,55 C 300,70 330,80 360,35 C 375,20 385,15 390,15 L 390,175 Z"
                    fill="url(#areaGradient)"
                  />

                  <!-- Green Spline Line Stroke -->
                  <path
                    d="M 30,175 C 60,110 80,95 110,105 C 140,115 160,140 190,120 C 220,95 240,40 270,55 C 300,70 330,80 360,35 C 375,20 385,15 390,15"
                    fill="none"
                    stroke="#16A34A"
                    stroke-width="3"
                    stroke-linecap="round"
                  />

                  <!-- Peak Indicator Point -->
                  <circle cx="390" cy="15" r="4.5" fill="#16A34A" stroke="#FFFFFF" stroke-width="2" />

                  <!-- X-Axis Labels (Jan, Mar, May, Jun) -->
                  <g font-size="10" fill="#64748B" font-weight="600" text-anchor="middle">
                    <text x="35" y="195">Jan</text>
                    <text x="140" y="195">Mar</text>
                    <text x="260" y="195">May</text>
                    <text x="385" y="195">Jun</text>
                  </g>
                </svg>
              </div>
            </div>
          </div>

          <!-- Quick Actions & Pending Verifications -->
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
            <!-- Pending Citizens Card -->
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <UserPlus size="18" style="color: #ea580c;" />
                  Pendaftaran Warga Baru
                </h3>
                <span class="badge badge-warning">{{ pendingCitizensList.length }} Baru</span>
              </div>
              <div class="card-body" style="padding: 16px;">
                <div v-if="pendingCitizensList.length === 0" style="text-align: center; padding: 24px; color: #94a3b8;">
                  Tidak ada pendaftaran yang menunggu persetujuan.
                </div>
                <div v-for="warga in pendingCitizensList" :key="warga.id" style="display: flex; align-items: center; justify-content: space-between; padding: 12px; border-bottom: 1px solid #f1f5f9;">
                  <div>
                    <strong style="font-size: 0.9rem; color: #0f172a;">{{ warga.name }}</strong>
                    <div style="font-size: 0.78rem; color: #64748b;">NIK: {{ warga.nik }} • {{ warga.phone }}</div>
                    <div style="font-size: 0.75rem; color: #94a3b8;">{{ warga.address || 'Alamat belum diisi' }}</div>
                  </div>
                  <div style="display: flex; gap: 6px;">
                    <button class="btn-success" style="padding: 6px 12px; font-size: 0.75rem;" @click="approveCitizen(warga.id)">
                      Setujui
                    </button>
                    <button class="btn-outline" style="padding: 6px 10px; font-size: 0.75rem; color: #dc2626;" @click="rejectCitizen(warga.id)">
                      Tolak
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Pending Letters Card -->
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <FileCheck size="18" style="color: #16a34a;" />
                  Pengajuan Surat Butuh Tanda Tangan
                </h3>
                <span class="badge badge-info">{{ pendingLettersList.length }} Berkas</span>
              </div>
              <div class="card-body" style="padding: 16px;">
                <div v-if="pendingLettersList.length === 0" style="text-align: center; padding: 24px; color: #94a3b8;">
                  Semua pengajuan surat telah diproses selesai.
                </div>
                <div v-for="letter in pendingLettersList" :key="letter.id" style="display: flex; align-items: center; justify-content: space-between; padding: 12px; border-bottom: 1px solid #f1f5f9;">
                  <div>
                    <strong style="font-size: 0.88rem; color: #0f172a;">{{ letter.letter_type }}</strong>
                    <div style="font-size: 0.78rem; color: #64748b;">Pemohon: {{ letter.citizen_name }} (RT {{ letter.citizen_rt }})</div>
                    <div style="font-size: 0.74rem; color: #0284c7; font-weight: 600;">Status: {{ letter.status }}</div>
                  </div>
                  <button class="btn-primary" style="padding: 6px 12px; font-size: 0.75rem;" @click="openSignModal(letter)">
                    Tanda Tangan QR
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 2. TAB: CITIZENS (WARGA) -->
        <div v-if="currentTab === 'citizens'">
          <div class="card">
            <div class="card-header">
              <h3 class="card-title">
                <Users size="18" style="color: #16a34a;" />
                Daftar & Verifikasi Penduduk RT {{ villageConfig.rt }} / RW {{ villageConfig.rw }}
              </h3>
              <div style="display: flex; gap: 10px; align-items: center;">
                <input
                  v-model="searchCitizen"
                  type="text"
                  placeholder="Cari NIK atau Nama..."
                  class="form-control"
                  style="width: 220px; padding: 6px 12px; font-size: 0.82rem;"
                />
                <a
                  :href="`${SERVER_BASE}/api/citizens/export`"
                  target="_blank"
                  class="btn-outline"
                  style="text-decoration: none; font-size: 0.78rem; padding: 6px 12px;"
                >
                  📥 Export CSV
                </a>
              </div>
            </div>
            <div class="table-responsive">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>NIK & Nama Lengkap</th>
                    <th>No. WhatsApp</th>
                    <th>RT / RW</th>
                    <th>Pekerjaan & Alamat</th>
                    <th>Status Akun</th>
                    <th>Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="citizen in filteredCitizens" :key="citizen.id">
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">{{ citizen.name }}</div>
                      <div style="font-size: 0.75rem; color: #64748b; font-family: monospace;">{{ citizen.nik }}</div>
                    </td>
                    <td>{{ citizen.phone }}</td>
                    <td>RT {{ citizen.rt }} / RW {{ citizen.rw }}</td>
                    <td>
                      <div>{{ citizen.occupation || '-' }}</div>
                      <div style="font-size: 0.74rem; color: #94a3b8;">{{ citizen.address || '-' }}</div>
                    </td>
                    <td>
                      <span
                        class="badge"
                        :class="{
                          'badge-success': citizen.status === 'approved',
                          'badge-warning': citizen.status === 'pending',
                          'badge-danger': citizen.status === 'rejected',
                        }"
                      >
                        {{ citizen.status === 'approved' ? 'Terverifikasi' : (citizen.status === 'pending' ? 'Menunggu Approval' : 'Ditolak') }}
                      </span>
                    </td>
                    <td>
                      <div v-if="citizen.status === 'pending'" style="display: flex; gap: 6px;">
                        <button class="btn-success" style="padding: 4px 8px; font-size: 0.75rem;" @click="approveCitizen(citizen.id)">
                          Setujui
                        </button>
                        <button class="btn-outline" style="padding: 4px 8px; font-size: 0.75rem; color: #dc2626;" @click="rejectCitizen(citizen.id)">
                          Tolak
                        </button>
                      </div>
                      <div v-else style="font-size: 0.78rem; color: #64748b;">
                        {{ citizen.role.toUpperCase() }}
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- 3. TAB: LETTERS & DOCUMENTS (WITH OFFICIAL PDF PRINTING) -->
        <div v-if="currentTab === 'letters'">
          <div class="card">
            <div class="card-header">
              <h3 class="card-title">
                <FileText size="18" style="color: #0284c7;" />
                Pengajuan Surat Warga & Cetak Dokumen PDF Resmi
              </h3>
            </div>
            <div class="table-responsive">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Jenis Surat</th>
                    <th>Nama Pemohon</th>
                    <th>Keperluan</th>
                    <th>No. Surat & QR Hash</th>
                    <th>Status</th>
                    <th>Aksi Cetak / TTD</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="letter in lettersList" :key="letter.id">
                    <td>
                      <strong style="color: #0f172a;">{{ letter.letter_type }}</strong>
                      <div style="font-size: 0.74rem; color: #94a3b8;">Diajukan: {{ formatDate(letter.created_at) }}</div>
                    </td>
                    <td>
                      <div>{{ letter.citizen_name }}</div>
                      <div style="font-size: 0.75rem; color: #64748b;">NIK: {{ letter.citizen_nik }}</div>
                    </td>
                    <td style="max-width: 250px;">{{ letter.purpose }}</td>
                    <td>
                      <div v-if="letter.letter_number" style="font-weight: 600; color: #16a34a; font-size: 0.8rem;">
                        {{ letter.letter_number }}
                      </div>
                      <div v-if="letter.qr_code_hash" style="font-size: 0.7rem; color: #64748b; font-family: monospace;">
                        {{ letter.qr_code_hash }}
                      </div>
                      <div v-else style="color: #94a3b8; font-size: 0.75rem;">Belum ada nomor</div>
                    </td>
                    <td>
                      <span
                        class="badge"
                        :class="{
                          'badge-success': letter.status === 'selesai',
                          'badge-info': letter.status === 'diproses_rt' || letter.status === 'diproses_rw',
                          'badge-warning': letter.status === 'diajukan',
                          'badge-danger': letter.status === 'ditolak',
                        }"
                      >
                        {{ letter.status }}
                      </span>
                    </td>
                    <td>
                      <div style="display: flex; gap: 8px;">
                        <button
                          v-if="letter.status !== 'selesai'"
                          class="btn-primary"
                          style="padding: 5px 12px; font-size: 0.75rem;"
                          @click="openSignModal(letter)"
                        >
                          Tanda Tangan & QR
                        </button>
                        <a
                          :href="`${SERVER_BASE}/letters/${letter.id}/print`"
                          target="_blank"
                          class="btn-success"
                          style="text-decoration: none; padding: 5px 10px; font-size: 0.75rem;"
                        >
                          🖨️ Cetak Dokumen PDF
                        </a>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- 4. TAB: SMART SISKAMLING (JADWAL RONDA, CHECKPOINT QR & KEAMANAN) -->
        <div v-if="currentTab === 'patrols'">
          <!-- Header Command Bar -->
          <div class="card" style="margin-bottom: 20px; background: linear-gradient(135deg, #064e3b 0%, #0f172a 100%); color: white; border: none; box-shadow: 0 10px 25px -5px rgba(6, 78, 59, 0.4);">
            <div class="card-body" style="padding: 24px;">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                <div>
                  <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                    <span style="background: rgba(16, 185, 129, 0.2); border: 1px solid rgba(52, 211, 153, 0.4); padding: 4px 10px; border-radius: 20px; font-size: 0.76rem; font-weight: 700; color: #86efac;">
                      🛡️ SMART SISKAMLING DIGITAL RT 001 / RW 005
                    </span>
                    <span class="badge badge-success" style="font-size: 0.72rem;">Sistem Aktif 24 Jam</span>
                  </div>
                  <h2 style="font-size: 1.45rem; font-weight: 800; color: white; margin: 0 0 6px 0;">
                    Manajemen Keamanan Lingkungan & Jadwal Ronda Cerdas
                  </h2>
                  <p style="font-size: 0.88rem; color: #cbd5e1; margin: 0; max-width: 680px; line-height: 1.5;">
                    Penjadwalan otomatis berkala, absensi presensi GPS warga, pemantauan scan QR checkpoint pos/portal, permohonan tukar jadwal & integrasi sanksi denda masuk buku kas RT.
                  </p>
                </div>

                <div style="display: flex; flex-wrap: wrap; gap: 8px;">
                  <button class="btn-primary" style="background: #10b981; border: none; font-weight: 700;" @click="autoGeneratePatrols">
                    <Sparkles size="16" /> Auto-Generate 7 Hari
                  </button>
                  <button class="btn-outline" style="background: rgba(255,255,255,0.12); color: white; border-color: rgba(255,255,255,0.25);" @click="openCreatePatrolModal">
                    <Plus size="16" /> Buat Jadwal
                  </button>
                  <button class="btn-outline" style="background: rgba(255,255,255,0.12); color: white; border-color: rgba(255,255,255,0.25);" @click="openPrintPatrolSchedule">
                    <Printer size="16" /> Cetak Jadwal A4
                  </button>
                  <button class="btn-outline" style="background: rgba(255,255,255,0.12); color: white; border-color: rgba(255,255,255,0.25);" @click="openPrintQRStickers">
                    <QrCode size="16" /> Stiker QR Pos
                  </button>
                  <button class="btn-outline" style="background: #25d366; color: white; border: none; font-weight: 700;" @click="openBroadcastWAModal()">
                    <MessageSquare size="16" /> Pengingat WA Malam Ini
                  </button>
                </div>
              </div>

              <!-- Quick KPI Stats -->
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-top: 24px;">
                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.75rem; color: #94a3b8; font-weight: 600;">TOTAL REGU TERJADWAL</div>
                  <div style="font-size: 1.6rem; font-weight: 800; color: #fff; margin-top: 2px;">
                    {{ patrolSummary.total_schedules || patrolsList.length }} <span style="font-size: 0.85rem; font-weight: 500; color: #86efac;">Regu</span>
                  </div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.75rem; color: #94a3b8; font-weight: 600;">HADIR PRESENSI GPS</div>
                  <div style="font-size: 1.6rem; font-weight: 800; color: #34d399; margin-top: 2px;">
                    {{ patrolSummary.total_hadir || 0 }} <span style="font-size: 0.85rem; font-weight: 500; color: #a7f3d0;">Warga</span>
                  </div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.75rem; color: #94a3b8; font-weight: 600;">IZIN / TUKAR SHIFT</div>
                  <div style="font-size: 1.6rem; font-weight: 800; color: #38bdf8; margin-top: 2px;">
                    {{ patrolSummary.total_izin || 0 }} <span style="font-size: 0.85rem; font-weight: 500; color: #bae6fd;">Pengajuan</span>
                  </div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.75rem; color: #94a3b8; font-weight: 600;">ALPHA & DENDA KAS RT</div>
                  <div style="font-size: 1.6rem; font-weight: 800; color: #f87171; margin-top: 2px;">
                    {{ patrolSummary.total_alpha || 0 }} <span style="font-size: 0.82rem; font-weight: 500; color: #fca5a5;">(Rp {{ Number(patrolSummary.total_fines || 0).toLocaleString('id-ID') }})</span>
                  </div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.75rem; color: #94a3b8; font-weight: 600;">CHECKPOINT QR TERSCAN</div>
                  <div style="font-size: 1.6rem; font-weight: 800; color: #fbbf24; margin-top: 2px;">
                    {{ patrolSummary.total_checkpoints_scanned || 0 }} <span style="font-size: 0.85rem; font-weight: 500; color: #fef08a;">Titik</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Navigation Sub-Tabs -->
          <div style="display: flex; gap: 8px; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; overflow-x: auto;">
            <button
              class="btn-tab"
              :class="{ active: patrolSubTab === 'schedules' }"
              @click="patrolSubTab = 'schedules'"
            >
              <Shield size="16" /> Jadwal Regu & Presensi Warga ({{ patrolsList.length }})
            </button>
            <button
              class="btn-tab"
              :class="{ active: patrolSubTab === 'swaps' }"
              @click="patrolSubTab = 'swaps'"
            >
              <Users size="16" /> Permohonan Izin & Tukar Shift
              <span v-if="patrolSwapsList.filter(s => s.status === 'pending').length > 0" class="badge badge-warning" style="margin-left: 6px; font-size: 0.7rem;">
                {{ patrolSwapsList.filter(s => s.status === 'pending').length }}
              </span>
            </button>
            <button
              class="btn-tab"
              :class="{ active: patrolSubTab === 'checkpoints' }"
              @click="patrolSubTab = 'checkpoints'"
            >
              <QrCode size="16" /> Logbook Checkpoint QR & Laporan Foto ({{ patrolCheckpointsList.length }})
            </button>
            <button
              class="btn-tab"
              :class="{ active: patrolSubTab === 'map' }"
              @click="selectTab('patrols'); patrolSubTab = 'map'"
            >
              <MapPin size="16" /> Peta Pos Ronda & Titik Pantau (Leaflet)
            </button>
          </div>

          <!-- SUB-TAB 1: JADWAL REGU & PRESENSI WARGA -->
          <div v-if="patrolSubTab === 'schedules'">
            <div v-if="patrolsList.length === 0" class="card" style="text-align: center; padding: 48px 20px;">
              <Shield size="48" style="color: #94a3b8; margin: 0 auto 12px auto;" />
              <h3 style="font-size: 1.15rem; color: #0f172a; margin-bottom: 6px;">Belum Ada Jadwal Ronda Aktif</h3>
              <p style="font-size: 0.88rem; color: #64748b; margin-bottom: 20px;">
                Klik tombol "Auto-Generate 7 Hari" untuk membagi warga ke dalam Regu 1 sampai 7 secara otomatis dan merata.
              </p>
              <div style="display: flex; justify-content: center; gap: 10px;">
                <button class="btn-primary" @click="autoGeneratePatrols">
                  <Sparkles size="16" /> Auto-Generate Jadwal Sekarang
                </button>
                <button class="btn-outline" @click="openCreatePatrolModal">
                  <Plus size="16" /> Buat Manual
                </button>
              </div>
            </div>

            <div v-for="patrol in patrolsList" :key="patrol.id" class="card" style="margin-bottom: 18px; border-left: 4px solid #16a34a;">
              <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; background: #fafafa;">
                <div>
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <h3 class="card-title" style="margin: 0; color: #0f172a; font-weight: 800; font-size: 1.05rem;">
                      {{ patrol.day_name }}, {{ patrol.patrol_date }} • {{ patrol.shift_name }}
                    </h3>
                    <span class="badge badge-success">Regu Aktif</span>
                    <span v-if="patrol.checkpoints_count > 0" class="badge badge-info">
                      📍 {{ patrol.checkpoints_count }} Checkpoint Scanned
                    </span>
                  </div>
                  <p style="font-size: 0.8rem; color: #64748b; margin: 4px 0 0 0;">
                    Wilayah: RT {{ patrol.rt }} / RW {{ patrol.rw }} • {{ patrol.notes }}
                  </p>
                </div>

                <div style="display: flex; align-items: center; gap: 8px;">
                  <button
                    class="btn-outline"
                    style="font-size: 0.78rem; padding: 6px 12px; background: #ecfdf5; color: #065f46; border-color: #a7f3d0;"
                    @click="openBroadcastWAModal(patrol)"
                  >
                    <MessageSquare size="14" /> Kirim WA Regu Ini
                  </button>
                  <button
                    class="btn-text"
                    style="color: #dc2626; font-size: 0.78rem; padding: 6px 8px;"
                    title="Hapus Jadwal"
                    @click="deletePatrolSchedule(patrol.id)"
                  >
                    <Trash2 size="15" />
                  </button>
                </div>
              </div>

              <div class="card-body">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(290px, 1fr)); gap: 14px;">
                  <div
                    v-for="member in patrol.members"
                    :key="member.id"
                    style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;"
                  >
                    <div>
                      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                        <div>
                          <strong style="font-size: 0.94rem; color: #0f172a;">{{ member.name }}</strong>
                          <div style="font-size: 0.76rem; color: #64748b;">📞 WA: {{ member.phone }}</div>
                          <div v-if="member.address" style="font-size: 0.72rem; color: #94a3b8;">🏠 {{ member.address }}</div>
                        </div>

                        <!-- Status Badge -->
                        <div>
                          <span v-if="member.has_checked_in || member.status === 'hadir'" class="badge badge-success">
                            ✅ Hadir GPS
                          </span>
                          <span v-else-if="member.status === 'izin'" class="badge badge-info">
                            ℹ️ Izin Resmi
                          </span>
                          <span v-else-if="member.status === 'tukar'" class="badge" style="background: #f3e8ff; color: #7e22ce;">
                            🔄 Tukar Shift
                          </span>
                          <span v-else-if="member.status === 'alpha'" class="badge badge-danger">
                            ⚠️ Alpha (Denda)
                          </span>
                          <span v-else class="badge badge-warning">
                            ⏳ Belum Presensi
                          </span>
                        </div>
                      </div>

                      <!-- Detail Check-in atau Izin -->
                      <div v-if="member.has_checked_in" style="margin-top: 8px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 8px; font-size: 0.74rem; color: #166534;">
                        📍 <strong>Presensi GPS Terverifikasi:</strong> Lat {{ member.check_in_lat }}, Lng {{ member.check_in_lng }}<br>
                        <em>"{{ member.check_in_note || 'Hadir tepat waktu di pos siskamling.' }}"</em>
                      </div>

                      <div v-else-if="member.status === 'izin'" style="margin-top: 8px; background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 8px; padding: 8px; font-size: 0.74rem; color: #0369a1;">
                        📝 <strong>Catatan Izin:</strong> {{ member.notes || 'Permohonan izin telah disetujui pengurus RT.' }}
                      </div>

                      <div v-else-if="member.status === 'alpha'" style="margin-top: 8px; background: #fef2f2; border: 1px solid #fecaca; border-radius: 8px; padding: 8px; font-size: 0.74rem; color: #991b1b;">
                        ⚠️ <strong>Denda Diterapkan:</strong> Rp {{ Number(member.fine_amount || 25000).toLocaleString('id-ID') }}
                        <span v-if="member.fine_paid" class="badge badge-success" style="font-size: 0.68rem; margin-left: 4px;">Lunas di Kas RT</span>
                        <span v-else class="badge badge-danger" style="font-size: 0.68rem; margin-left: 4px;">Menunggu Bayar</span>
                      </div>
                    </div>

                    <!-- Member Action Buttons -->
                    <div style="margin-top: 14px; pt: 10px; border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; gap: 6px;">
                      <button
                        class="btn-text"
                        style="color: #25d366; font-size: 0.75rem; font-weight: 700; display: flex; align-items: center; gap: 4px;"
                        title="Kirim pesan WA Pengingat"
                        @click="sendWAReminder(member, patrol)"
                      >
                        <MessageSquare size="13" /> Chat WA
                      </button>

                      <div style="display: flex; gap: 6px;">
                        <!-- Button Denda Alpha jika belum hadir -->
                        <button
                          v-if="!member.has_checked_in && member.status !== 'izin' && member.status !== 'alpha'"
                          class="btn-outline"
                          style="font-size: 0.72rem; padding: 4px 8px; color: #dc2626; border-color: #fca5a5; background: #fff5f5;"
                          @click="openFineModal(member, patrol)"
                        >
                          ⚠️ Denda Alpha
                        </button>

                        <!-- Button Pelunasan Denda jika sudah didenda tapi belum lunas -->
                        <button
                          v-if="member.status === 'alpha' && !member.fine_paid"
                          class="btn-outline"
                          style="font-size: 0.72rem; padding: 4px 8px; color: #16a34a; border-color: #86efac; background: #f0fdf4;"
                          @click="payPatrolFine(member, patrol)"
                        >
                          💵 Terima Kas
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- SUB-TAB 2: PERMOHONAN IZIN & TUKAR SHIFT (WARGA) -->
          <div v-if="patrolSubTab === 'swaps'">
            <div class="card">
              <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h3 class="card-title">
                  <Users size="18" style="color: #0284c7;" />
                  Daftar Permohonan Izin & Tukar Jadwal Ronda Warga
                </h3>
                <span class="badge badge-info">{{ patrolSwapsList.length }} Permohonan Terdaftar</span>
              </div>
              <div class="card-body" style="padding: 0;">
                <div v-if="patrolSwapsList.length === 0" style="text-align: center; padding: 40px; color: #94a3b8;">
                  Belum ada permohonan izin atau tukar jadwal ronda yang diajukan warga.
                </div>
                <div v-else class="table-responsive">
                  <table class="data-table">
                    <thead>
                      <tr>
                        <th>Pemohon (Warga)</th>
                        <th>Jadwal Ronda</th>
                        <th>Jenis Pengajuan</th>
                        <th>Alasan Warga</th>
                        <th>Pengganti (Jika Tukar)</th>
                        <th>Status</th>
                        <th>Aksi Pengurus</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="swap in patrolSwapsList" :key="swap.id">
                        <td>
                          <strong>{{ swap.requester_name }}</strong>
                          <div style="font-size: 0.74rem; color: #64748b;">📞 {{ swap.requester_phone }}</div>
                        </td>
                        <td>
                          <div><strong>{{ swap.day_name }}</strong>, {{ swap.patrol_date }}</div>
                          <div style="font-size: 0.75rem; color: #64748b;">{{ swap.shift_name }}</div>
                        </td>
                        <td>
                          <span
                            class="badge"
                            :class="swap.type === 'izin_tidak_hadir' ? 'badge-warning' : 'badge-info'"
                          >
                            {{ swap.type === 'izin_tidak_hadir' ? 'Izin Tidak Hadir' : 'Tukar Jadwal' }}
                          </span>
                        </td>
                        <td style="max-width: 250px;">
                          <div style="font-size: 0.85rem; color: #1e293b;">{{ swap.reason }}</div>
                          <div v-if="swap.admin_notes" style="font-size: 0.74rem; color: #64748b; margin-top: 4px;">
                            <em>Catatan Pengurus: {{ swap.admin_notes }}</em>
                          </div>
                        </td>
                        <td>
                          <span v-if="swap.target_name" style="font-weight: 600; color: #0f172a;">{{ swap.target_name }}</span>
                          <span v-else style="color: #94a3b8; font-size: 0.8rem;">-</span>
                        </td>
                        <td>
                          <span v-if="swap.status === 'approved'" class="badge badge-success">Disetujui</span>
                          <span v-else-if="swap.status === 'rejected'" class="badge badge-danger">Ditolak</span>
                          <span v-else class="badge badge-warning">Menunggu</span>
                        </td>
                        <td>
                          <div v-if="swap.status === 'pending'" style="display: flex; gap: 6px;">
                            <button
                              class="btn-primary"
                              style="font-size: 0.74rem; padding: 4px 10px; background: #16a34a;"
                              @click="reviewSwapRequest(swap.id, 'approved')"
                            >
                              <Check size="13" /> Setujui
                            </button>
                            <button
                              class="btn-outline"
                              style="font-size: 0.74rem; padding: 4px 10px; color: #dc2626; border-color: #fca5a5;"
                              @click="reviewSwapRequest(swap.id, 'rejected')"
                            >
                              <X size="13" /> Tolak
                            </button>
                          </div>
                          <span v-else style="font-size: 0.75rem; color: #64748b;">Sudah Direview</span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>

          <!-- SUB-TAB 3: LOGBOOK CHECKPOINT QR & FOTO SITUASI REALTIME -->
          <div v-if="patrolSubTab === 'checkpoints'">
            <!-- Master Checkpoint Locations -->
            <div class="card" style="margin-bottom: 20px;">
              <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h3 class="card-title">
                  <QrCode size="18" style="color: #16a34a;" />
                  Titik Stiker Checkpoint QR Siskamling Resmi
                </h3>
                <button class="btn-outline" style="font-size: 0.8rem; padding: 6px 12px;" @click="openSimulateCheckpointModal">
                  <Camera size="14" /> + Simulasi Scan Lapangan
                </button>
              </div>
              <div class="card-body">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px;">
                  <div style="border: 1px solid #cbd5e1; border-radius: 12px; padding: 16px; background: #f8fafc;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                      <span class="badge badge-success">Pos Induk</span>
                      <strong style="color: #0369a1; font-size: 0.78rem;">POS-RONDA-01</strong>
                    </div>
                    <h4 style="font-size: 1rem; color: #0f172a; margin-bottom: 4px;">Pos Ronda Utama RT 001</h4>
                    <p style="font-size: 0.8rem; color: #64748b; margin-bottom: 8px;">Titik kumpul regu ronda, koordinasi linmas & sirine kentongan darurat.</p>
                    <div style="font-size: 0.74rem; color: #475569;">📍 Koordinat: -6.2087634, 106.8455990</div>
                  </div>

                  <div style="border: 1px solid #cbd5e1; border-radius: 12px; padding: 16px; background: #f8fafc;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                      <span class="badge badge-info">Portal Pembatas</span>
                      <strong style="color: #0369a1; font-size: 0.78rem;">PORTAL-BARAT-01</strong>
                    </div>
                    <h4 style="font-size: 1rem; color: #0f172a; margin-bottom: 4px;">Portal Barat Gang Kenanga</h4>
                    <p style="font-size: 0.8rem; color: #64748b; margin-bottom: 8px;">Akses keluar masuk kendaraan gang barat. Wajib digembok pukul 23:00 WIB.</p>
                    <div style="font-size: 0.74rem; color: #475569;">📍 Koordinat: -6.2091200, 106.8449000</div>
                  </div>

                  <div style="border: 1px solid #cbd5e1; border-radius: 12px; padding: 16px; background: #f8fafc;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                      <span class="badge badge-warning">Gardu Pantau</span>
                      <strong style="color: #0369a1; font-size: 0.78rem;">GARDU-TIMUR-01</strong>
                    </div>
                    <h4 style="font-size: 1rem; color: #0f172a; margin-bottom: 4px;">Gardu Timur Jalur Hijau</h4>
                    <p style="font-size: 0.8rem; color: #64748b; margin-bottom: 8px;">Pemantauan lampu penerangan jalan dan area parkir motor warga sekitar balai RT.</p>
                    <div style="font-size: 0.74rem; color: #475569;">📍 Koordinat: -6.2084500, 106.8462000</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Feed Laporan Checkpoint -->
            <div class="card">
              <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h3 class="card-title">
                  <Camera size="18" style="color: #ea580c;" />
                  Aktivitas Scan QR Checkpoint & Laporan Foto Terkini
                </h3>
                <span class="badge badge-success">{{ patrolCheckpointsList.length }} Laporan Masuk</span>
              </div>
              <div class="card-body" style="padding: 0;">
                <div v-if="patrolCheckpointsList.length === 0" style="text-align: center; padding: 40px; color: #94a3b8;">
                  Belum ada rekaman scan checkpoint malam ini. Gunakan tombol "Simulasi Scan Lapangan" di atas untuk mencoba.
                </div>
                <div v-else class="table-responsive">
                  <table class="data-table">
                    <thead>
                      <tr>
                        <th>Waktu Scan</th>
                        <th>Titik Checkpoint</th>
                        <th>Petugas Pemeriksa</th>
                        <th>Status Kondisi</th>
                        <th>Catatan Petugas</th>
                        <th>Foto Kondisi Lapangan</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="cp in patrolCheckpointsList" :key="cp.id">
                        <td style="white-space: nowrap;">
                          <strong>{{ new Date(cp.scanned_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) }} WIB</strong>
                          <div style="font-size: 0.74rem; color: #64748b;">{{ new Date(cp.scanned_at).toLocaleDateString('id-ID') }}</div>
                        </td>
                        <td>
                          <strong>{{ cp.checkpoint_name }}</strong>
                          <div style="font-size: 0.74rem; color: #0284c7; font-weight: 600;">{{ cp.checkpoint_code }}</div>
                        </td>
                        <td>
                          <strong>{{ cp.officer_name }}</strong>
                          <div style="font-size: 0.74rem; color: #64748b;">📞 {{ cp.officer_phone }}</div>
                        </td>
                        <td>
                          <span
                            class="badge"
                            :class="cp.situation_status === 'Aman Kondusif' ? 'badge-success' : (cp.situation_status === 'Waspada' ? 'badge-danger' : 'badge-warning')"
                          >
                            {{ cp.situation_status }}
                          </span>
                        </td>
                        <td style="max-width: 250px;">
                          <div style="font-size: 0.85rem; color: #1e293b;">{{ cp.notes }}</div>
                          <div style="font-size: 0.72rem; color: #94a3b8;">📍 GPS: {{ cp.location_lat }}, {{ cp.location_lng }}</div>
                        </td>
                        <td>
                          <a v-if="cp.photo_url" :href="cp.photo_url" target="_blank">
                            <img :src="cp.photo_url" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px; border: 1px solid #cbd5e1;" />
                          </a>
                          <span v-else style="color: #94a3b8; font-size: 0.8rem;">-</span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>

          <!-- SUB-TAB 4: PETA POS RONDA & TITIK PATROLI (LEAFLET OSM) -->
          <div v-show="patrolSubTab === 'map'">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <MapPin size="18" style="color: #ea580c;" />
                  Peta Titik Pos Ronda & Jalur Keamanan Lingkungan RT 001 / RW 005
                </h3>
              </div>
              <div class="card-body" style="padding: 0;">
                <div id="patrol-map" style="width: 100%; height: 380px; border-bottom: 1px solid #e2e8f0;"></div>
              </div>
            </div>
          </div>


          <!-- Dedicated Card: Absensi & Piket Linmas / Hansip -->
          <div class="card" style="border-top: 3px solid #16a34a;">
            <div class="card-header" style="background: #F0FDF4;">
              <h3 class="card-title" style="color: #14532D;">
                <Shield size="18" style="color: #16a34a;" />
                Presensi & Laporan Piket Linmas (Hansip Desa)
              </h3>
              <span class="badge badge-success">{{ linmasList.length }} Petugas Bertugas</span>
            </div>
            <div class="table-responsive">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Nama Petugas Linmas</th>
                    <th>Shift & Pos Jaga</th>
                    <th>Jam Absen Masuk</th>
                    <th>Koordinat GPS</th>
                    <th>Laporan Situasi Terkini</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in linmasList" :key="item.id">
                    <td>
                      <strong style="color: #0f172a;">{{ item.officer_name }}</strong>
                      <div style="font-size: 0.74rem; color: #16a34a; font-weight: 600;">🛡️ Linmas Terverifikasi</div>
                    </td>
                    <td>
                      <div>{{ item.shift }}</div>
                      <div style="font-size: 0.75rem; color: #64748b;">📍 {{ item.post_name }}</div>
                    </td>
                    <td>
                      <div style="font-weight: 600; color: #0f172a;">{{ formatDate(item.check_in_time) }}</div>
                      <div style="font-size: 0.72rem; color: #64748b;">Check-out: {{ item.check_out_time ? formatDate(item.check_out_time) : 'Sedang Bertugas' }}</div>
                    </td>
                    <td>
                      <div style="font-family: monospace; font-size: 0.75rem; color: #0284c7;">
                        Lat: {{ item.check_in_lat }}, Lng: {{ item.check_in_lng }}
                      </div>
                    </td>
                    <td style="max-width: 250px;">
                      <div style="font-weight: 700; color: #15803d; font-size: 0.8rem;">{{ item.situation_status }}</div>
                      <div style="font-size: 0.74rem; color: #64748b;">{{ item.notes }}</div>
                    </td>
                    <td>
                      <span class="badge" :class="item.status === 'bertugas' ? 'badge-success' : 'badge-info'">
                        {{ item.status.toUpperCase() }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- 5. TAB: POSYANDU MELATI -->
        <div v-if="currentTab === 'posyandu'">
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <HeartPulse size="18" style="color: #ec4899;" />
                  Jadwal Kegiatan Posyandu
                </h3>
              </div>
              <div class="card-body" style="padding: 16px;">
                <div v-for="activity in posyanduData.activities" :key="activity.id" style="padding: 14px; border-bottom: 1px solid #f1f5f9;">
                  <strong style="color: #0f172a;">{{ activity.title }}</strong>
                  <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">
                    📅 Tanggal: {{ activity.activity_date }} • 📍 {{ activity.location }}
                  </div>
                  <p style="font-size: 0.8rem; color: #334155; margin-top: 6px;">{{ activity.description }}</p>
                </div>
              </div>
            </div>

            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <Baby size="18" style="color: #0284c7;" />
                  Catatan Tumbuh Kembang Balita
                </h3>
              </div>
              <div class="card-body" style="padding: 16px;">
                <div v-for="child in posyanduData.children" :key="child.id" style="padding: 14px; border-bottom: 1px solid #f1f5f9;">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <strong style="color: #0f172a; font-size: 0.95rem;">{{ child.child_name }} ({{ child.gender }})</strong>
                    <span class="badge badge-info">Lahir: {{ child.birth_date }}</span>
                  </div>
                  <div style="display: flex; gap: 16px; margin-top: 8px; font-size: 0.82rem; color: #334155;">
                    <div>⚖️ Berat: <strong>{{ child.weight_kg }} kg</strong></div>
                    <div>📏 Tinggi: <strong>{{ child.height_cm }} cm</strong></div>
                    <div>🧠 Lingkar: <strong>{{ child.head_circumference_cm }} cm</strong></div>
                  </div>
                  <div style="font-size: 0.78rem; color: #16a34a; font-weight: 600; margin-top: 4px;">
                    💉 Imunisasi: {{ child.immunization_type }}
                  </div>
                  <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">
                    Catatan kader: {{ child.cadre_notes }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 6. TAB: COMPLAINTS (ADUAN WARGA & TPS MAP) -->
        <div v-if="currentTab === 'complaints'">
          <div class="card">
            <div class="card-header">
              <h3 class="card-title">
                <MapPin size="18" style="color: #ea580c;" />
                Peta Sebaran Titik Aduan Masalah Lingkungan (TPS, Lampu & Jalan)
              </h3>
            </div>
            <div class="card-body" style="padding: 0;">
              <!-- Map Container -->
              <div id="complaints-map" style="width: 100%; height: 340px; border-bottom: 1px solid #e2e8f0;"></div>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <h3 class="card-title">
                <AlertCircle size="18" style="color: #ea580c;" />
                Daftar Laporan Keluhan Warga
              </h3>
            </div>
            <div class="card-body">
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 18px;">
                <div
                  v-for="item in complaintsList"
                  :key="item.id"
                  style="border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; background: white;"
                >
                  <img
                    v-if="item.photo_url"
                    :src="item.photo_url"
                    alt="Foto Aduan"
                    style="width: 100%; height: 160px; object-fit: cover;"
                  />
                  <div style="padding: 16px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                      <span class="badge badge-warning">{{ item.category }}</span>
                      <span
                        class="badge"
                        :class="item.status === 'selesai' ? 'badge-success' : 'badge-danger'"
                      >
                        {{ item.status }}
                      </span>
                    </div>
                    <h4 style="font-size: 0.98rem; font-weight: 700; color: #0f172a; margin-bottom: 6px;">
                      {{ item.title }}
                    </h4>
                    <p style="font-size: 0.82rem; color: #475569; margin-bottom: 12px;">{{ item.description }}</p>
                    
                    <div style="font-size: 0.74rem; color: #64748b; margin-bottom: 12px; background: #f8fafc; padding: 8px; border-radius: 6px;">
                      <div>📍 {{ item.location_address }}</div>
                      <div>👤 Pelapor: {{ item.reporter_name }} ({{ item.reporter_phone }})</div>
                    </div>

                    <div v-if="item.feedback_notes" style="font-size: 0.78rem; color: #16a34a; background: #f0fdf4; padding: 8px; border-radius: 6px; margin-bottom: 12px;">
                      <strong>Tanggapan RT:</strong> {{ item.feedback_notes }}
                    </div>

                    <div style="display: flex; gap: 8px;">
                      <button
                        v-if="item.status !== 'selesai'"
                        class="btn-success"
                        style="width: 100%; justify-content: center; font-size: 0.78rem;"
                        @click="resolveComplaint(item.id)"
                      >
                        Tandai Selesai & Beri Tanggapan
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 7. TAB: TREASURY (KAS KAMPUNG & IURAN WARGA) -->
        <div v-if="currentTab === 'treasury'">
          <!-- Sub Navigation Tabs -->
          <div style="display: flex; gap: 8px; margin-bottom: 20px; border-bottom: 2px solid #e2e8f0; padding-bottom: 12px;">
            <button
              :class="duesSubTab === 'bills' ? 'btn-primary' : 'btn-outline'"
              style="font-size: 0.85rem; padding: 8px 16px; display: flex; align-items: center; gap: 8px;"
              @click="duesSubTab = 'bills'"
            >
              <QrCode size="16" />
              <span>Verifikasi & Tagihan Iuran Kas Warga</span>
              <span
                v-if="duesData.summary?.menunggu_verifikasi > 0"
                style="background: #ef4444; color: white; border-radius: 9999px; padding: 2px 8px; font-size: 0.72rem; font-weight: 700;"
              >
                {{ duesData.summary.menunggu_verifikasi }} Menunggu
              </span>
            </button>
            <button
              :class="duesSubTab === 'ledger' ? 'btn-primary' : 'btn-outline'"
              style="font-size: 0.85rem; padding: 8px 16px; display: flex; align-items: center; gap: 8px;"
              @click="duesSubTab = 'ledger'"
            >
              <Coins size="16" />
              <span>Buku Kas RT (Pemasukan & Pengeluaran)</span>
            </button>
          </div>

          <!-- SUBTAB 1: DUES BILLS & VERIFICATION -->
          <div v-if="duesSubTab === 'bills'">
            <!-- Dues Metrics -->
            <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
              <div class="stat-card" style="--stat-accent: #0284c7;">
                <div class="stat-icon" style="background: #e0f2fe; color: #0284c7;">
                  <Users size="22" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Total Warga Ditagih</div>
                  <div class="stat-value" style="color: #0284c7;">{{ duesData.summary?.total_bills || 0 }} KK</div>
                  <div class="stat-desc">Iuran Kas RT {{ villageConfig.rt }}</div>
                </div>
              </div>

              <div class="stat-card" style="--stat-accent: #16a34a;">
                <div class="stat-icon" style="background: #f0fdf4; color: #16a34a;">
                  <CheckCircle size="22" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Sudah Lunas</div>
                  <div class="stat-value" style="color: #16a34a;">{{ duesData.summary?.lunas || 0 }} Warga</div>
                  <div class="stat-desc">{{ formatRupiah(duesData.summary?.total_nominal_terkumpul || 0) }} terkumpul</div>
                </div>
              </div>

              <div class="stat-card" style="--stat-accent: #f59e0b; border: 1.5px solid #fef08a;">
                <div class="stat-icon" style="background: #fef3c7; color: #d97706;">
                  <AlertCircle size="22" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Menunggu Verifikasi</div>
                  <div class="stat-value" style="color: #d97706;">{{ duesData.summary?.menunggu_verifikasi || 0 }} Bukti</div>
                  <div class="stat-desc">Perlu dicek bendahara</div>
                </div>
              </div>

              <div class="stat-card" style="--stat-accent: #64748b;">
                <div class="stat-icon" style="background: #f1f5f9; color: #64748b;">
                  <Coins size="22" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Belum Bayar</div>
                  <div class="stat-value" style="color: #64748b;">{{ duesData.summary?.menunggu_bayar || 0 }} Warga</div>
                  <div class="stat-desc">Potensi {{ formatRupiah(duesData.summary?.total_nominal_menunggu || 0) }}</div>
                </div>
              </div>
            </div>

            <!-- Table Card -->
            <div class="card">
              <div class="card-header" style="flex-wrap: wrap; gap: 12px;">
                <div>
                  <h3 class="card-title">
                    <QrCode size="18" style="color: #0b4626;" />
                    Rekap Pembayaran Kas & Kuitansi Digital (QRIS Statis & Transfer)
                  </h3>
                  <div style="font-size: 0.78rem; color: #64748b; margin-top: 2px;">
                    100% Gratis Tanpa Biaya Admin. Kuitansi resmi otomatis terbit ber-QR code setelah disetujui.
                  </div>
                </div>
                <div style="display: flex; gap: 8px; flex-wrap: wrap; align-items: center;">
                  <!-- Filter Pills -->
                  <div style="display: flex; background: #f1f5f9; border-radius: 8px; padding: 2px; gap: 2px;">
                    <button
                      class="btn-text"
                      :style="{ background: duesFilterStatus === 'all' ? '#ffffff' : 'transparent', fontWeight: duesFilterStatus === 'all' ? 700 : 500, borderRadius: '6px', padding: '4px 10px', fontSize: '0.74rem' }"
                      @click="duesFilterStatus = 'all'"
                    >
                      Semua
                    </button>
                    <button
                      class="btn-text"
                      :style="{ background: duesFilterStatus === 'menunggu_verifikasi' ? '#ffffff' : 'transparent', fontWeight: duesFilterStatus === 'menunggu_verifikasi' ? 700 : 500, borderRadius: '6px', padding: '4px 10px', fontSize: '0.74rem', color: '#d97706' }"
                      @click="duesFilterStatus = 'menunggu_verifikasi'"
                    >
                      Menunggu Verifikasi ({{ duesData.summary?.menunggu_verifikasi || 0 }})
                    </button>
                    <button
                      class="btn-text"
                      :style="{ background: duesFilterStatus === 'lunas' ? '#ffffff' : 'transparent', fontWeight: duesFilterStatus === 'lunas' ? 700 : 500, borderRadius: '6px', padding: '4px 10px', fontSize: '0.74rem', color: '#16a34a' }"
                      @click="duesFilterStatus = 'lunas'"
                    >
                      Lunas
                    </button>
                    <button
                      class="btn-text"
                      :style="{ background: duesFilterStatus === 'menunggu_bayar' ? '#ffffff' : 'transparent', fontWeight: duesFilterStatus === 'menunggu_bayar' ? 700 : 500, borderRadius: '6px', padding: '4px 10px', fontSize: '0.74rem' }"
                      @click="duesFilterStatus = 'menunggu_bayar'"
                    >
                      Belum Bayar
                    </button>
                  </div>

                  <!-- Search -->
                  <input
                    v-model="searchDuesCitizen"
                    type="text"
                    placeholder="Cari warga / NIK / No Kuitansi..."
                    class="form-control"
                    style="width: 220px; padding: 6px 12px; font-size: 0.78rem;"
                  />

                  <!-- Export CSV -->
                  <a
                    :href="`${SERVER_BASE}/api/dues/export`"
                    target="_blank"
                    class="btn-outline"
                    style="text-decoration: none; font-size: 0.78rem; padding: 6px 12px;"
                  >
                    📥 Unduh Rekap CSV
                  </a>
                </div>
              </div>

              <!-- Dues Table -->
              <div class="table-responsive">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Warga & NIK</th>
                      <th>Bulan & Nominal</th>
                      <th>Metode Bayar</th>
                      <th>Bukti Transfer</th>
                      <th>Status Pembayaran</th>
                      <th>Kuitansi Digital</th>
                      <th>Aksi Bendahara</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="filteredDuesBills.length === 0">
                      <td colspan="7" style="text-align: center; padding: 30px; color: #64748b;">
                        Tidak ada data tagihan yang sesuai dengan filter.
                      </td>
                    </tr>
                    <tr v-for="b in filteredDuesBills" :key="b.id">
                      <td>
                        <div style="font-weight: 700; color: #0f172a;">{{ b.citizen_name }}</div>
                        <div style="font-size: 0.72rem; color: #64748b;">NIK: {{ b.nik }} | RT {{ b.rt }}/RW {{ b.rw }}</div>
                      </td>
                      <td>
                        <div style="font-weight: 600; color: #334155;">{{ b.month }} {{ b.year }}</div>
                        <div style="font-weight: 800; color: #0b4626; font-size: 0.9rem;">{{ formatRupiah(b.amount) }}</div>
                      </td>
                      <td>
                        <span v-if="b.payment_method === 'qris_static'" class="badge" style="background: #e0f2fe; color: #0369a1;">
                          QRIS Statis RT
                        </span>
                        <span v-else-if="b.payment_method === 'bank_transfer'" class="badge" style="background: #f3e8ff; color: #7e22ce;">
                          Transfer Bank
                        </span>
                        <span v-else-if="b.payment_method === 'cash'" class="badge" style="background: #f1f5f9; color: #475569;">
                          Tunai
                        </span>
                        <span v-else style="color: #94a3b8; font-size: 0.76rem;">- Belum Pilih -</span>
                      </td>
                      <td>
                        <div v-if="b.proof_image_url" style="display: flex; align-items: center; gap: 6px;">
                          <img
                            :src="b.proof_image_url"
                            style="width: 36px; height: 36px; object-fit: cover; border-radius: 6px; border: 1px solid #cbd5e1; cursor: pointer;"
                            @click="openProofPreview(b.proof_image_url)"
                            title="Klik untuk melihat bukti full"
                          />
                          <button
                            class="btn-text"
                            style="font-size: 0.72rem; color: #0284c7; text-decoration: underline; padding: 0;"
                            @click="openProofPreview(b.proof_image_url)"
                          >
                            Lihat Foto
                          </button>
                        </div>
                        <span v-else style="color: #94a3b8; font-size: 0.76rem;">Belum Unggah</span>
                      </td>
                      <td>
                        <span v-if="b.status === 'lunas'" class="badge badge-success" style="display: inline-flex; align-items: center; gap: 4px;">
                          <CheckCircle size="12" /> LUNAS
                        </span>
                        <span v-else-if="b.status === 'menunggu_verifikasi'" class="badge" style="background: #fef3c7; color: #b45309; display: inline-flex; align-items: center; gap: 4px; font-weight: 700; border: 1px solid #fde68a;">
                          ⏳ Menunggu Verifikasi
                        </span>
                        <span v-else class="badge" style="background: #f1f5f9; color: #64748b;">
                          Belum Bayar
                        </span>
                      </td>
                      <td>
                        <div v-if="b.receipt_number" style="display: flex; flex-direction: column; gap: 2px;">
                          <span style="font-family: monospace; font-size: 0.75rem; font-weight: 700; color: #0b4626;">
                            {{ b.receipt_number }}
                          </span>
                          <a
                            :href="`${SERVER_BASE}/receipts/${b.receipt_number}/print`"
                            target="_blank"
                            style="font-size: 0.72rem; color: #16a34a; text-decoration: none; display: inline-flex; align-items: center; gap: 3px;"
                          >
                            <Printer size="12" /> Cetak / Unduh PDF
                          </a>
                        </div>
                        <span v-else style="color: #94a3b8; font-size: 0.76rem;">-</span>
                      </td>
                      <td>
                        <!-- Action Buttons -->
                        <div style="display: flex; gap: 6px;">
                          <button
                            v-if="b.status === 'menunggu_verifikasi'"
                            class="btn-primary"
                            style="font-size: 0.75rem; padding: 5px 10px; background: #ea580c;"
                            @click="openVerifyModal(b)"
                          >
                            🔍 Verifikasi
                          </button>

                          <a
                            v-if="b.status === 'lunas' && b.receipt_number"
                            :href="`${SERVER_BASE}/receipts/${b.receipt_number}/print`"
                            target="_blank"
                            class="btn-outline"
                            style="text-decoration: none; font-size: 0.75rem; padding: 5px 10px;"
                          >
                            <Printer size="12" /> Kuitansi
                          </a>

                          <button
                            v-if="b.status === 'menunggu_bayar' && canManageCash"
                            class="btn-primary"
                            style="font-size: 0.75rem; padding: 5px 10px; background: #16a34a; border: none; font-weight: 700;"
                            @click="receiveCashPayment(b)"
                            title="Terima uang tunai dan terbitkan kuitansi sah (Khusus Admin & Staff)"
                          >
                            💵 Terima Tunai
                          </button>

                          <button
                            v-if="b.status === 'menunggu_bayar'"
                            class="btn-outline"
                            style="font-size: 0.75rem; padding: 5px 10px; color: #25d366; border-color: #25d366;"
                            @click="sendWhatsAppReminder(b)"
                          >
                            💬 Ingatkan WA
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- SUBTAB 2: GENERAL CASH BOOK LEDGER -->
          <div v-if="duesSubTab === 'ledger'">
            <div class="stats-grid">
              <div class="stat-card" style="--stat-accent: #16a34a;">
                <div class="stat-icon" style="background: #f0fdf4; color: #16a34a;">
                  <ArrowDownRight size="24" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Total Pemasukan</div>
                  <div class="stat-value" style="color: #16a34a;">{{ formatRupiah(treasuryData.summary?.total_income || 0) }}</div>
                  <div class="stat-desc">Iuran warga & donasi</div>
                </div>
              </div>

              <div class="stat-card" style="--stat-accent: #dc2626;">
                <div class="stat-icon" style="background: #fef2f2; color: #dc2626;">
                  <ArrowUpRight size="24" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Total Pengeluaran</div>
                  <div class="stat-value" style="color: #dc2626;">{{ formatRupiah(treasuryData.summary?.total_expense || 0) }}</div>
                  <div class="stat-desc">Operasional & kebersihan</div>
                </div>
              </div>

              <div class="stat-card" style="--stat-accent: #ea580c;">
                <div class="stat-icon" style="background: #fff7ed; color: #ea580c;">
                  <Wallet size="24" />
                </div>
                <div class="stat-content">
                  <div class="stat-label">Saldo Kas Bersih</div>
                  <div class="stat-value" style="color: #ea580c;">{{ formatRupiah(treasuryData.summary?.balance || 0) }}</div>
                  <div class="stat-desc">Dana siap pakai</div>
                </div>
              </div>
            </div>

            <!-- Financial Breakdown Section (Pemasukan & Pengeluaran) -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; margin-bottom: 20px;">
              <!-- Breakdown Pemasukan -->
              <div class="card" style="margin-bottom: 0;">
                <div class="card-header" style="padding-bottom: 8px;">
                  <h4 style="font-size: 0.95rem; font-weight: 800; color: #166534; display: flex; align-items: center; gap: 6px; margin: 0;">
                    <ArrowDownRight size="16" style="color: #16a34a;" />
                    Breakdown Pemasukan Kas
                  </h4>
                  <span style="font-size: 0.75rem; color: #64748b;">{{ treasuryData.breakdown?.income?.length || 0 }} Kategori</span>
                </div>
                <div class="card-body" style="padding: 12px 16px;">
                  <div v-if="!treasuryData.breakdown?.income || treasuryData.breakdown.income.length === 0" style="color: #94a3b8; font-size: 0.8rem; text-align: center; padding: 20px 0;">
                    Belum ada data pemasukan
                  </div>
                  <div v-for="item in treasuryData.breakdown?.income" :key="item.category" style="margin-bottom: 12px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.8rem; margin-bottom: 4px;">
                      <span style="font-weight: 700; color: #0f172a;">{{ item.label }}</span>
                      <span style="font-weight: 800; color: #16a34a;">{{ formatRupiah(item.total) }} ({{ item.percentage }}%)</span>
                    </div>
                    <div style="width: 100%; height: 7px; background: #f1f5f9; border-radius: 4px; overflow: hidden;">
                      <div :style="{ width: item.percentage + '%', background: item.color || '#16a34a' }" style="height: 100%; border-radius: 4px; transition: width 0.3s ease;"></div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Breakdown Pengeluaran -->
              <div class="card" style="margin-bottom: 0;">
                <div class="card-header" style="padding-bottom: 8px;">
                  <h4 style="font-size: 0.95rem; font-weight: 800; color: #991b1b; display: flex; align-items: center; gap: 6px; margin: 0;">
                    <ArrowUpRight size="16" style="color: #dc2626;" />
                    Breakdown Pengeluaran Kas
                  </h4>
                  <span style="font-size: 0.75rem; color: #64748b;">{{ treasuryData.breakdown?.expense?.length || 0 }} Kategori</span>
                </div>
                <div class="card-body" style="padding: 12px 16px;">
                  <div v-if="!treasuryData.breakdown?.expense || treasuryData.breakdown.expense.length === 0" style="color: #94a3b8; font-size: 0.8rem; text-align: center; padding: 20px 0;">
                    Belum ada data pengeluaran
                  </div>
                  <div v-for="item in treasuryData.breakdown?.expense" :key="item.category" style="margin-bottom: 12px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.8rem; margin-bottom: 4px;">
                      <span style="font-weight: 700; color: #0f172a;">{{ item.label }}</span>
                      <span style="font-weight: 800; color: #dc2626;">{{ formatRupiah(item.total) }} ({{ item.percentage }}%)</span>
                    </div>
                    <div style="width: 100%; height: 7px; background: #f1f5f9; border-radius: 4px; overflow: hidden;">
                      <div :style="{ width: item.percentage + '%', background: item.color || '#dc2626' }" style="height: 100%; border-radius: 4px; transition: width 0.3s ease;"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="card">
              <div class="card-header">
                <h3 class="card-title">
                  <Coins size="18" style="color: #16a34a;" />
                  Buku Catatan Kas RT {{ villageConfig.rt }} Transparan
                </h3>
                <div style="display: flex; gap: 8px;">
                  <a
                    :href="`${SERVER_BASE}/api/treasury/export`"
                    target="_blank"
                    class="btn-outline"
                    style="text-decoration: none; font-size: 0.82rem; padding: 7px 14px;"
                  >
                    📥 Unduh Rekap CSV
                  </a>
                  <button class="btn-primary" @click="showAddTreasuryModal = true">
                    <Plus size="16" />
                    <span>Tambah Transaksi</span>
                  </button>
                </div>
              </div>
              <div class="table-responsive">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Tanggal</th>
                      <th>Jenis</th>
                      <th>Kategori</th>
                      <th>Uraian Transaksi</th>
                      <th>Jumlah (Rp)</th>
                      <th>Pencatat</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="t in treasuryData.data" :key="t.id">
                      <td>{{ t.transaction_date }}</td>
                      <td>
                        <span class="badge" :class="t.type === 'pemasukan' ? 'badge-success' : 'badge-danger'">
                          {{ t.type }}
                        </span>
                      </td>
                      <td>{{ t.category }}</td>
                      <td>
                        <div style="font-weight: 700; color: #0f172a;">{{ t.title }}</div>
                        <div style="font-size: 0.74rem; color: #64748b;">{{ t.description }}</div>
                      </td>
                      <td style="font-weight: 800; font-size: 0.92rem;" :style="{ color: t.type === 'pemasukan' ? '#16a34a' : '#dc2626' }">
                        {{ t.type === 'pemasukan' ? '+' : '-' }} {{ formatRupiah(t.amount) }}
                      </td>
                      <td style="font-size: 0.78rem; color: #64748b;">{{ t.recorder_name }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- 8. TAB: NEWS & ANNOUNCEMENTS -->
        <div v-if="currentTab === 'news'">
          <div class="card">
            <div class="card-header">
              <h3 class="card-title">
                <Megaphone size="18" style="color: #ea580c;" />
                Kabar Kampung & Pengumuman Pengurus
              </h3>
              <button class="btn-primary" @click="showAddNewsModal = true">
                <Plus size="16" />
                <span>Publikasikan Berita</span>
              </button>
            </div>
            <div class="card-body">
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
                <div
                  v-for="item in newsList"
                  :key="item.id"
                  style="border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; background: white; display: flex; flex-direction: column;"
                >
                  <img
                    v-if="item.thumbnail_url"
                    :src="item.thumbnail_url"
                    alt="Thumbnail"
                    style="width: 100%; height: 160px; object-fit: cover;"
                  />
                  <div style="padding: 18px; flex: 1; display: flex; flex-direction: column;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                      <span class="badge badge-info">{{ item.category }}</span>
                      <span v-if="item.is_pinned" class="badge badge-warning">📌 PENTING</span>
                    </div>
                    <h4 style="font-size: 1.05rem; font-weight: 800; color: #0f172a; margin-bottom: 8px; line-height: 1.3;">
                      {{ item.title }}
                    </h4>
                    <p style="font-size: 0.84rem; color: #475569; flex: 1; margin-bottom: 14px; line-height: 1.5;">
                      {{ item.content }}
                    </p>
                    <div style="font-size: 0.75rem; color: #94a3b8; border-top: 1px solid #f1f5f9; padding-top: 10px;">
                      Diposkan oleh {{ item.author_name }} • {{ formatDate(item.created_at) }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>

    <!-- MODAL: KUSTOMISASI IDENTITAS DESA -->
    <div v-if="showSettingsModal" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">⚙️ Kustomisasi Identitas Desa & RT/RW</h3>
          <button class="btn-close" @click="showSettingsModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Nama Desa / Kelurahan</label>
            <input v-model="villageConfig.village_name" type="text" class="form-control" />
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <div class="form-group">
              <label class="form-label">Nomor RT</label>
              <input v-model="villageConfig.rt" type="text" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">Nomor RW</label>
              <input v-model="villageConfig.rw" type="text" class="form-control" />
            </div>
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <div class="form-group">
              <label class="form-label">Kecamatan</label>
              <input v-model="villageConfig.subdistrict" type="text" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">Kabupaten / Kota</label>
              <input v-model="villageConfig.regency" type="text" class="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Nama Ketua RT</label>
            <input v-model="villageConfig.leader_name" type="text" class="form-control" />
          </div>
          <div class="form-group">
            <label class="form-label">Nomor WhatsApp Pengurus</label>
            <input v-model="villageConfig.phone" type="text" class="form-control" />
          </div>
          <div class="form-group">
            <label class="form-label">Slogan Desa</label>
            <input v-model="villageConfig.slogan" type="text" class="form-control" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showSettingsModal = false">Batal</button>
          <button class="btn-primary" @click="saveVillageConfig">Simpan Pengaturan</button>
        </div>
      </div>
    </div>

    <!-- MODAL: DIGITAL SIGNATURE WITH QR CODE -->
    <div v-if="showSignModal" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">✍️ Tanda Tangan Digital Surat</h3>
          <button class="btn-close" @click="showSignModal = false">×</button>
        </div>
        <div class="modal-body">
          <p style="font-size: 0.85rem; color: #475569; margin-bottom: 16px;">
            Anda akan menerbitkan nomor surat resmi dan membubuhkan tanda tangan digital (QR Code terenkripsi) untuk pemohon:
          </p>

          <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px; margin-bottom: 18px;">
            <div><strong>Surat:</strong> {{ selectedLetter?.letter_type }}</div>
            <div><strong>Pemohon:</strong> {{ selectedLetter?.citizen_name }} (NIK: {{ selectedLetter?.citizen_nik }})</div>
            <div><strong>Keperluan:</strong> {{ selectedLetter?.purpose }}</div>
          </div>

          <div class="form-group">
            <label class="form-label">Catatan Pengurus RT (Opsional)</label>
            <textarea
              v-model="signNotes"
              class="form-control"
              rows="3"
              placeholder="Contoh: Berkas persyaratan telah lengkap dan diverifikasi."
            ></textarea>
          </div>

          <div style="text-align: center; padding: 16px; background: #f0fdf4; border: 1px dashed #22c55e; border-radius: 10px;">
            <div style="font-size: 0.8rem; color: #166534; font-weight: 700; margin-bottom: 8px;">
              SIMULASI KODE VERIFIKASI QR DIGITAL
            </div>
            <div style="font-family: monospace; font-size: 0.85rem; color: #15803d; font-weight: 800;">
              [QR-CODE-WD-{{ Math.random().toString(36).substring(2, 10).toUpperCase() }}]
            </div>
            <p style="font-size: 0.72rem; color: #64748b; margin-top: 6px;">
              Tanda tangan digital ini sah dan dapat diverifikasi oleh instansi kelurahan/kecamatan.
            </p>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showSignModal = false">Batal</button>
          <button class="btn-success" @click="confirmSignLetter">
            Terbitkan Surat & Sahkan QR
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL: ADD TREASURY TRANSACTION -->
    <div v-if="showAddTreasuryModal" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">💵 Catat Transaksi Kas RT</h3>
          <button class="btn-close" @click="showAddTreasuryModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Tipe Transaksi</label>
            <select v-model="newTreasury.type" class="form-control">
              <option value="pemasukan">Pemasukan (Uang Masuk)</option>
              <option value="pengeluaran">Pengeluaran (Uang Keluar)</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Kategori</label>
            <select v-model="newTreasury.category" class="form-control">
              <option value="iuran_bulanan">Iuran Bulanan Warga</option>
              <option value="donasi">Donasi / Sumbangan</option>
              <option value="operasional">Operasional & Perlengkapan</option>
              <option value="kebersihan">Honor Petugas Kebersihan / Keamanan</option>
              <option value="darurat">Bantuan Darurat</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Uraian / Judul Transaksi</label>
            <input v-model="newTreasury.title" type="text" class="form-control" placeholder="Contoh: Iuran Warga Gang Melati" />
          </div>

          <div class="form-group">
            <label class="form-label">Jumlah Uang (Rp)</label>
            <input v-model.number="newTreasury.amount" type="number" class="form-control" placeholder="Contoh: 150000" />
          </div>

          <div class="form-group">
            <label class="form-label">Keterangan Tambahan</label>
            <textarea v-model="newTreasury.description" class="form-control" rows="2" placeholder="Catatan detail..."></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showAddTreasuryModal = false">Batal</button>
          <button class="btn-primary" @click="saveTreasury">Simpan ke Buku Kas</button>
        </div>
      </div>
    </div>

    <!-- MODAL: ADD NEWS -->
    <div v-if="showAddNewsModal" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">📢 Tulis Kabar / Pengumuman</h3>
          <button class="btn-close" @click="showAddNewsModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Judul Berita</label>
            <input v-model="newNews.title" type="text" class="form-control" placeholder="Contoh: Jadwal Pengasapan Nyamuk (Fogging)" />
          </div>

          <div class="form-group">
            <label class="form-label">Kategori</label>
            <select v-model="newNews.category" class="form-control">
              <option value="Pengumuman">Pengumuman</option>
              <option value="Kegiatan">Kegiatan Warga</option>
              <option value="Ronda">Keamanan & Ronda</option>
              <option value="Posyandu">Kesehatan & Posyandu</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Isi Pengumuman</label>
            <textarea v-model="newNews.content" class="form-control" rows="4" placeholder="Tulis rincian pesan untuk seluruh warga..."></textarea>
          </div>

          <div class="form-group">
            <label class="form-label">URL Foto / Poster (Opsional)</label>
            <input v-model="newNews.thumbnail_url" type="text" class="form-control" placeholder="https://..." />
          </div>

          <div style="display: flex; align-items: center; gap: 8px;">
            <input v-model="newNews.is_pinned" type="checkbox" id="pinned" />
            <label for="pinned" style="font-size: 0.85rem; font-weight: 600; cursor: pointer;">
              Sematkan di paling atas (Prioritas / Pinned)
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showAddNewsModal = false">Batal</button>
          <button class="btn-primary" @click="saveNews">Publikasikan Sekarang</button>
        </div>
      </div>
    </div>

    <!-- MODAL: VERIFY CITIZEN DUES PAYMENT -->
    <div v-if="showVerifyModal && selectedBillToVerify" class="modal-overlay">
      <div class="modal-content" style="max-width: 550px;">
        <div class="modal-header">
          <h3 class="modal-title" style="display: flex; align-items: center; gap: 8px;">
            <QrCode size="20" style="color: #0b4626;" />
            Verifikasi Bukti Transfer Iuran Warga
          </h3>
          <button class="btn-close" @click="showVerifyModal = false">×</button>
        </div>
        <div class="modal-body">
          <!-- Citizen & Bill Info Summary -->
          <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; margin-bottom: 16px;">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
              <div>
                <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700;">Warga Pembayar</div>
                <div style="font-weight: 800; color: #0f172a; font-size: 1rem;">{{ selectedBillToVerify.citizen_name }}</div>
                <div style="font-size: 0.78rem; color: #64748b;">NIK: {{ selectedBillToVerify.nik }} | RT {{ selectedBillToVerify.rt }}/RW {{ selectedBillToVerify.rw }}</div>
              </div>
              <div style="text-align: right;">
                <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700;">Nominal Tagihan</div>
                <div style="font-weight: 800; color: #16a34a; font-size: 1.15rem;">{{ formatRupiah(selectedBillToVerify.amount) }}</div>
                <div style="font-size: 0.75rem; color: #64748b;">{{ selectedBillToVerify.month }} {{ selectedBillToVerify.year }}</div>
              </div>
            </div>
            <div style="border-top: 1px dashed #cbd5e1; padding-top: 8px; margin-top: 8px; font-size: 0.8rem; display: flex; justify-content: space-between;">
              <span>Metode Bayar: <strong>{{ selectedBillToVerify.payment_method === 'qris_static' ? 'QRIS Statis RT' : 'Transfer Bank' }}</strong></span>
              <span v-if="selectedBillToVerify.phone" style="color: #0369a1;">No HP: {{ selectedBillToVerify.phone }}</span>
            </div>
          </div>

          <!-- Proof Image Display -->
          <div class="form-group">
            <label class="form-label" style="display: flex; justify-content: space-between;">
              <span>Foto Struk / Bukti Transfer</span>
              <span style="font-size: 0.75rem; color: #0284c7; cursor: pointer;" @click="openProofPreview(selectedBillToVerify.proof_image_url)">Buka Ukuran Penuh ↗</span>
            </label>
            <div
              v-if="selectedBillToVerify.proof_image_url"
              style="text-align: center; background: #0f172a; border-radius: 8px; padding: 10px; cursor: pointer;"
              @click="openProofPreview(selectedBillToVerify.proof_image_url)"
            >
              <img
                :src="selectedBillToVerify.proof_image_url"
                style="max-height: 260px; max-width: 100%; border-radius: 4px; object-fit: contain;"
              />
              <div style="font-size: 0.72rem; color: #94a3b8; margin-top: 4px;">Klik foto untuk memperbesar layar penuh</div>
            </div>
            <div v-else style="padding: 30px; text-align: center; background: #f1f5f9; border-radius: 8px; color: #94a3b8;">
              Tidak ada bukti transfer yang diunggah.
            </div>
          </div>

          <!-- Rejection Reason Input (Optional/if rejecting) -->
          <div class="form-group" style="margin-top: 14px;">
            <label class="form-label">Catatan Penolakan (Hanya diisi jika bukti TIDAK valid / salah nominal)</label>
            <input
              v-model="verifyRejectReason"
              type="text"
              class="form-control"
              placeholder="Contoh: Nominal transfer kurang, atau rekening tujuan salah."
            />
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: space-between; gap: 10px;">
          <button class="btn-outline" style="color: #dc2626; border-color: #fca5a5;" @click="submitVerification('reject')">
            ✕ Tolak Bukti Bayar
          </button>
          <div style="display: flex; gap: 8px;">
            <button class="btn-outline" @click="showVerifyModal = false">Batal</button>
            <button class="btn-success" style="background: #16a34a; color: white;" @click="submitVerification('approve')">
              ✓ Setujui & Terbitkan Kuitansi Digital
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL: PROOF IMAGE LIGHTBOX -->
    <div v-if="showProofModal" class="modal-overlay" style="z-index: 9999;" @click="showProofModal = false">
      <div class="modal-content" style="max-width: 700px; background: #0f172a; color: white; border: none; padding: 16px;" @click.stop>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
          <h4 style="margin: 0; font-size: 0.95rem; color: #e2e8f0;">🔍 Pratinjau Bukti Pembayaran Kas</h4>
          <button class="btn-close" style="color: white;" @click="showProofModal = false">×</button>
        </div>
        <div style="text-align: center;">
          <img :src="previewProofUrl" style="max-height: 75vh; max-width: 100%; border-radius: 6px; box-shadow: 0 10px 25px rgba(0,0,0,0.5);" />
        </div>
      </div>
    </div>

    <!-- MODAL: LOGOUT CONFIRMATION -->
    <div v-if="showLogoutConfirm" class="modal-overlay" style="z-index: 9999;" @click="showLogoutConfirm = false">
      <div class="modal-content" style="max-width: 440px;" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title" style="display: flex; align-items: center; gap: 8px; color: #dc2626;">
            <LogOut size="20" /> Konfirmasi Keluar Sistem
          </h3>
          <button class="btn-close" @click="showLogoutConfirm = false">×</button>
        </div>
        <div class="modal-body">
          <p style="font-size: 0.92rem; color: #334155; margin-bottom: 12px; line-height: 1.5;">
            Apakah Anda yakin ingin keluar dari sesi akun <strong>{{ currentUser?.name }}</strong>?
          </p>
          <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; font-size: 0.82rem; color: #64748b;">
            Peran: <strong :style="{ color: getRoleTextColor(currentUser?.role) }">{{ getRoleBadgeText(currentUser?.role) }}</strong><br />
            Setelah keluar, Anda akan diarahkan ke halaman login untuk memilih atau memasukkan akun kembali.
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 8px;">
          <button class="btn-outline" @click="showLogoutConfirm = false">Batal</button>
          <button class="btn-danger" style="background: #dc2626; color: white;" @click="performLogout">
            <LogOut size="15" /> Ya, Keluar Sekarang
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL: SWITCH ROLE (GANTI PERAN CEPAT) -->
    <div v-if="showSwitchRoleModal" class="modal-overlay" style="z-index: 9999;" @click="showSwitchRoleModal = false">
      <div class="modal-content" style="max-width: 500px;" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">🔄 Ganti Peran / Switch Role</h3>
          <button class="btn-close" @click="showSwitchRoleModal = false">×</button>
        </div>
        <div class="modal-body">
          <p style="font-size: 0.85rem; color: #64748b; margin-bottom: 14px;">
            Pilih akun peran untuk beralih tampilan dan wewenang modul secara instan:
          </p>
          <div class="switch-role-grid">
            <div
              v-for="role in demoRoles"
              :key="role.role"
              class="switch-role-item"
              :class="{ current: currentUser?.role === role.role }"
              @click="switchRoleTo(role)"
            >
              <div class="switch-role-icon" :style="{ background: role.bg_color, color: role.text_color }">
                <component :is="role.iconComponent" size="20" />
              </div>
              <div class="switch-role-text">
                <div class="switch-role-label">{{ role.label }} ({{ role.name }})</div>
                <div class="switch-role-desc">{{ role.desc }}</div>
              </div>
              <span v-if="currentUser?.role === role.role" class="badge badge-success" style="font-size: 0.72rem;">Aktif</span>
              <button v-else class="btn-text" style="font-size: 0.75rem; color: #16a34a; font-weight: 700;">Ganti →</button>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showSwitchRoleModal = false">Tutup</button>
        </div>
      </div>
    </div>

    <!-- MODAL 1: BUAT JADWAL RONDA BARU -->
    <div v-if="showCreatePatrolModal" class="modal-overlay" style="z-index: 9999;" @click="showCreatePatrolModal = false">
      <div class="modal-content" style="max-width: 560px;" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">🛡️ Buat Jadwal Tugas Ronda Baru</h3>
          <button class="btn-close" @click="showCreatePatrolModal = false">×</button>
        </div>
        <div class="modal-body">
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
            <div>
              <label class="form-label">Tanggal Ronda</label>
              <input type="date" class="form-input" v-model="newPatrolForm.patrol_date" />
            </div>
            <div>
              <label class="form-label">Nama Hari</label>
              <select class="form-input" v-model="newPatrolForm.day_name">
                <option value="Senin">Senin</option>
                <option value="Selasa">Selasa</option>
                <option value="Rabu">Rabu</option>
                <option value="Kamis">Kamis</option>
                <option value="Jumat">Jumat</option>
                <option value="Sabtu">Sabtu</option>
                <option value="Minggu">Minggu</option>
              </select>
            </div>
          </div>

          <div style="margin-bottom: 12px;">
            <label class="form-label">Nama Shift / Regu</label>
            <input type="text" class="form-input" v-model="newPatrolForm.shift_name" placeholder="Misal: Malam Regu 1 (22:00 - 04:00)" />
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
            <div>
              <label class="form-label">RT</label>
              <input type="text" class="form-input" v-model="newPatrolForm.rt" />
            </div>
            <div>
              <label class="form-label">RW</label>
              <input type="text" class="form-input" v-model="newPatrolForm.rw" />
            </div>
          </div>

          <div style="margin-bottom: 14px;">
            <label class="form-label">Catatan Instruksi Patroli</label>
            <input type="text" class="form-input" v-model="newPatrolForm.notes" placeholder="Misal: Pantau portal barat & gang 1-4" />
          </div>

          <div>
            <label class="form-label">Pilih Anggota Regu Ronda (Warga Aktif)</label>
            <div style="max-height: 180px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px; background: #f8fafc;">
              <div v-for="c in citizensList.filter(u => u.status === 'active')" :key="c.id" style="display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid #f1f5f9;">
                <input
                  type="checkbox"
                  :id="'cb-warga-' + c.id"
                  :value="c.id"
                  v-model="newPatrolForm.member_ids"
                  style="cursor: pointer;"
                />
                <label :for="'cb-warga-' + c.id" style="cursor: pointer; font-size: 0.85rem; color: #1e293b; flex: 1;">
                  <strong>{{ c.name }}</strong> ({{ c.phone }})
                </label>
              </div>
            </div>
            <div style="font-size: 0.74rem; color: #64748b; margin-top: 4px;">
              Terpilih: {{ newPatrolForm.member_ids.length }} orang
            </div>
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 8px;">
          <button class="btn-outline" @click="showCreatePatrolModal = false">Batal</button>
          <button class="btn-primary" @click="submitCreatePatrol">Terbitkan Jadwal</button>
        </div>
      </div>
    </div>

    <!-- MODAL 2: TERAPKAN SANKSI DENDA KAS RT (ALPHA) -->
    <div v-if="showFineModal" class="modal-overlay" style="z-index: 9999;" @click="showFineModal = false">
      <div class="modal-content" style="max-width: 480px;" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title" style="color: #dc2626;">⚠️ Terapkan Sanksi Denda Ronda</h3>
          <button class="btn-close" @click="showFineModal = false">×</button>
        </div>
        <div class="modal-body">
          <p style="font-size: 0.88rem; color: #334155; margin-bottom: 14px; line-height: 1.5;">
            Warga berikut tidak hadir ronda tanpa konfirmasi izin resmi. Sistem akan menetapkan status <strong>Alpha</strong> dan menerbitkan tagihan denda ke modul <strong>Kas RT</strong>.
          </p>

          <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; margin-bottom: 14px; font-size: 0.84rem;">
            <div>Warga: <strong style="color: #0f172a;">{{ fineForm.member_name }}</strong></div>
            <div>Jadwal: <span style="color: #64748b;">{{ fineForm.schedule_info }}</span></div>
          </div>

          <div style="margin-bottom: 12px;">
            <label class="form-label">Nominal Uang Pengganti / Denda (Rp)</label>
            <input type="number" class="form-input" v-model.number="fineForm.amount" min="1000" step="5000" />
            <div style="font-size: 0.74rem; color: #64748b; margin-top: 2px;">Standar kas RT: Rp 25.000,-</div>
          </div>

          <div>
            <label class="form-label">Alasan Sanksi</label>
            <textarea class="form-input" rows="2" v-model="fineForm.reason" placeholder="Keterangan alpha"></textarea>
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 8px;">
          <button class="btn-outline" @click="showFineModal = false">Batal</button>
          <button class="btn-danger" style="background: #dc2626; color: white;" @click="submitApplyFine">
            Terapkan & Terbitkan Tagihan Kas
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL 3: BROADCAST PENGINGAT WHATSAPP -->
    <div v-if="showBroadcastWAModal && broadcastWAPatrol" class="modal-overlay" style="z-index: 9999;" @click="showBroadcastWAModal = false">
      <div class="modal-content" style="max-width: 520px;" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title" style="color: #15803d;">📲 Pengingat WhatsApp Petugas Ronda</h3>
          <button class="btn-close" @click="showBroadcastWAModal = false">×</button>
        </div>
        <div class="modal-body">
          <div style="background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 8px; padding: 12px; margin-bottom: 14px;">
            <strong style="color: #065f46;">{{ broadcastWAPatrol.day_name }}, {{ broadcastWAPatrol.patrol_date }}</strong>
            <div style="font-size: 0.8rem; color: #047857;">{{ broadcastWAPatrol.shift_name }} • {{ broadcastWAPatrol.notes }}</div>
          </div>

          <label class="form-label">Template Pesan WhatsApp Resmi:</label>
          <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px; font-size: 0.8rem; color: #334155; margin-bottom: 16px; line-height: 1.5; font-style: italic;">
            "Assalamu'alaikum Bpk. [Nama], mengingatkan giliran Anda piket Ronda Siskamling RT 001 / RW 005 pada {{ broadcastWAPatrol.day_name }}, {{ broadcastWAPatrol.patrol_date }} ({{ broadcastWAPatrol.shift_name }}). Mohon hadir di Pos Ronda Utama tepat waktu dan lakukan presensi GPS via aplikasi Warga Digital. Terima kasih atas partisipasi aktif menjaga kampung! 🛡️ Salam Pengurus RT."
          </div>

          <label class="form-label">Kirim ke Anggota Regu (1-Klik WhatsApp):</label>
          <div style="max-height: 200px; overflow-y: auto; display: flex; flex-direction: column; gap: 8px;">
            <div
              v-for="m in broadcastWAPatrol.members"
              :key="m.id"
              style="display: flex; justify-content: space-between; align-items: center; background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 8px 12px;"
            >
              <div>
                <strong>{{ m.name }}</strong>
                <div style="font-size: 0.74rem; color: #64748b;">WA: {{ m.phone }}</div>
              </div>
              <button
                class="btn-primary"
                style="font-size: 0.74rem; padding: 6px 12px; background: #25d366;"
                @click="sendWAReminder(m, broadcastWAPatrol)"
              >
                <MessageSquare size="13" /> Kirim Chat WA
              </button>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showBroadcastWAModal = false">Tutup</button>
        </div>
      </div>
    </div>

    <!-- MODAL 4: SIMULASI SCAN CHECKPOINT QR -->
    <div v-if="showCheckpointSimModal" class="modal-overlay" style="z-index: 9999;" @click="showCheckpointSimModal = false">
      <div class="modal-content" style="max-width: 480px;" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">📷 Simulasi Scan Checkpoint Lapangan</h3>
          <button class="btn-close" @click="showCheckpointSimModal = false">×</button>
        </div>
        <div class="modal-body">
          <div style="margin-bottom: 12px;">
            <label class="form-label">Pilih Titik Checkpoint</label>
            <select class="form-input" v-model="checkpointSimForm.checkpoint_code">
              <option value="POS-RONDA-01">Pos Ronda Utama RT 001 (POS-RONDA-01)</option>
              <option value="PORTAL-BARAT-01">Portal Barat Gang Kenanga (PORTAL-BARAT-01)</option>
              <option value="GARDU-TIMUR-01">Gardu Timur Jalur Hijau (GARDU-TIMUR-01)</option>
            </select>
          </div>

          <div style="margin-bottom: 12px;">
            <label class="form-label">Petugas Pemeriksa</label>
            <select class="form-input" v-model="checkpointSimForm.user_id">
              <option v-for="c in citizensList.filter(u => u.status === 'active')" :key="c.id" :value="c.id">
                {{ c.name }} ({{ c.role }})
              </option>
            </select>
          </div>

          <div style="margin-bottom: 12px;">
            <label class="form-label">Status Kondisi Lapangan</label>
            <select class="form-input" v-model="checkpointSimForm.situation_status">
              <option value="Aman Kondusif">🟢 Aman Kondusif</option>
              <option value="Pintu Portal Terkunci">🔵 Pintu Portal Terkunci Gembok</option>
              <option value="Lampu Jalan Padam">🟡 Lampu Jalan Padam</option>
              <option value="Waspada">🔴 Waspada / Ada Kerumunan</option>
            </select>
          </div>

          <div style="margin-bottom: 12px;">
            <label class="form-label">Catatan Situasi</label>
            <textarea class="form-input" rows="2" v-model="checkpointSimForm.notes"></textarea>
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 8px;">
          <button class="btn-outline" @click="showCheckpointSimModal = false">Batal</button>
          <button class="btn-primary" @click="submitCheckpointScan">Kirim Laporan Scan</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue';
import axios from 'axios';
import {
  LayoutDashboard,
  Users,
  FileText,
  Shield,
  HeartPulse,
  AlertCircle,
  Wallet,
  Megaphone,
  Menu,
  RefreshCw,
  Plus,
  AlertTriangle,
  UserCheck,
  UserPlus,
  FileCheck,
  Baby,
  Coins,
  ArrowDownRight,
  ArrowUpRight,
  MapPin,
  Settings,
  Search,
  Bell,
  ChevronDown,
  CheckCircle,
  XCircle,
  Eye,
  QrCode,
  ExternalLink,
  Printer,
  LogOut,
  User,
  Lock,
  Check,
  Sparkles,
  Trash2,
  Camera,
  MessageSquare,
  Send,
  Calendar,
  Clock,
  DollarSign,
  X,
} from 'lucide-vue-next';

// Dynamic API Host (supports Vercel env, local Vite 5173, Laravel :8000, and HTTPS Cloudflare Tunnels)
const envApi = import.meta.env.VITE_API_URL;
const isHttps = window.location.protocol === 'https:';
const isDevPort = window.location.port === '5173';
const SERVER_BASE = envApi
  ? envApi.replace(/\/$/, '')
  : ((isHttps || !isDevPort) ? window.location.origin : `http://${window.location.hostname}:8000`);
const API_BASE = `${SERVER_BASE}/api`;
const currentTab = ref('dashboard');
const mobileNavOpen = ref(false);
const loading = ref(false);
const globalSearch = ref('');

// Auth & Multi-Role State
const currentUser = ref(null);
const loginForm = ref({ nik: '', password: '' });
const loginLoading = ref(false);
const loginError = ref('');
const showUserDropdown = ref(false);
const showLogoutConfirm = ref(false);
const showSwitchRoleModal = ref(false);

// Wewenang Kelola Iuran Tunai (Khusus Admin & Staff Pengurus)
const canManageCash = computed(() => {
  const role = currentUser.value?.role;
  return ['rt', 'rw', 'bendahara', 'sekretaris', 'staff', 'admin'].includes(role);
});

// Notifications State & Logic
const showNotificationsDropdown = ref(false);
const notifFilter = ref('all');
const notificationsList = ref([
  {
    id: 1,
    title: 'Pembayaran Kas Warga Masuk',
    message: 'Budi Santoso telah mengunggah bukti transfer QRIS Rp 25.000 untuk Kas RT Oktober 2026.',
    time: '5 menit lalu',
    category: 'kas',
    icon: Wallet,
    color: '#EA580C',
    bgColor: '#FFF7ED',
    read: false,
    tab: 'dues',
    actionText: 'Verifikasi Bukti',
  },
  {
    id: 2,
    title: 'Pengaduan Warga Baru #ADU-982',
    message: 'Lampu Penerangan Jalan Gang 3 mati total, mohon perbaikan teknisi RT.',
    time: '20 menit lalu',
    category: 'complaints',
    icon: AlertCircle,
    color: '#DC2626',
    bgColor: '#FEF2F2',
    read: false,
    tab: 'complaints',
    actionText: 'Tinjau Pengaduan',
  },
  {
    id: 3,
    title: 'Permohonan Surat Keterangan Domisili',
    message: 'Dewi Lestari mengajukan Surat Pengantar Domisili baru perlu ditandatangani Ketua RT.',
    time: '1 jam lalu',
    category: 'letters',
    icon: FileText,
    color: '#0284C7',
    bgColor: '#F0F9FF',
    read: false,
    tab: 'letters',
    actionText: 'Tanda Tangani & QR',
  },
  {
    id: 4,
    title: 'Presensi GPS Linmas Masuk',
    message: 'Pak Sutrisno melakukan presensi dinas di Pos Ronda Utama RT 001 (-6.2088, 106.8456).',
    time: '3 jam lalu',
    category: 'linmas',
    icon: Shield,
    color: '#16A34A',
    bgColor: '#F0FDF4',
    read: true,
    tab: 'patrols',
    actionText: 'Buka Jadwal Ronda',
  },
  {
    id: 5,
    title: 'Agenda Posyandu Balita Melati',
    message: 'Penimbangan balita & pemberian vitamin A di Posyandu Melati dijadwalkan Sabtu ini.',
    time: '1 hari lalu',
    category: 'posyandu',
    icon: HeartPulse,
    color: '#DB2777',
    bgColor: '#FDF2F8',
    read: true,
    tab: 'posyandu',
    actionText: 'Lihat Data Balita',
  },
]);

const unreadNotificationsCount = computed(() => {
  return notificationsList.value.filter(n => !n.read).length;
});

const filteredNotifications = computed(() => {
  if (notifFilter.value === 'unread') {
    return notificationsList.value.filter(n => !n.read);
  } else if (notifFilter.value === 'kas') {
    return notificationsList.value.filter(n => n.category === 'kas');
  }
  return notificationsList.value;
});

function toggleNotificationsDropdown() {
  showNotificationsDropdown.value = !showNotificationsDropdown.value;
  if (showNotificationsDropdown.value) {
    showUserDropdown.value = false;
  }
}

function markAllNotificationsRead() {
  notificationsList.value.forEach(n => (n.read = true));
}

function handleNotificationClick(item) {
  item.read = true;
  showNotificationsDropdown.value = false;
  if (item.tab) {
    selectTab(item.tab);
  }
}

const demoRoles = [
  {
    role: 'warga',
    label: 'Warga',
    name: 'Budi Santoso',
    nik: '3201010202950003',
    password: 'password123',
    bg_color: '#f0fdf4',
    text_color: '#16a34a',
    iconComponent: User,
  },
  {
    role: 'rt',
    label: 'Ketua RT',
    name: 'Bambang Sudarmono',
    nik: '3201010101900001',
    password: 'password123',
    bg_color: '#ecfdf5',
    text_color: '#065f46',
    iconComponent: Shield,
  },
  {
    role: 'bendahara',
    label: 'Bendahara',
    name: 'Siti Rahmawati',
    nik: 'bendahara',
    password: 'password123',
    bg_color: '#fff7ed',
    text_color: '#ea580c',
    iconComponent: Wallet,
  },
  {
    role: 'linmas',
    label: 'Linmas',
    name: 'Pak Sutrisno',
    nik: 'linmas',
    password: 'password123',
    bg_color: '#eff6ff',
    text_color: '#2563eb',
    iconComponent: Shield,
  },
  {
    role: 'posyandu',
    label: 'Posyandu',
    name: 'Bidan Dewi',
    nik: 'posyandu',
    password: 'password123',
    bg_color: '#fdf2f8',
    text_color: '#db2777',
    iconComponent: Baby,
  },
];

const villageConfig = ref({
  village_name: 'Desa Sukamaju',
  rt: '001',
  rw: '005',
  subdistrict: 'Mekarsari',
  regency: 'Bogor',
  leader_name: 'Bambang Sudarmono',
  phone: '0812-3456-7890',
  slogan: 'Maju, Guyub, Transparan & Berkeadilan',
});
const showSettingsModal = ref(false);

const stats = ref({});
const citizensList = ref([]);
const lettersList = ref([]);
const patrolsList = ref([]);
const linmasList = ref([]);
const posyanduData = ref({ activities: [], children: [] });
const complaintsList = ref([]);
const treasuryData = ref({ summary: {}, data: [] });
const duesData = ref({ summary: {}, data: [] });
const duesSubTab = ref('bills'); // 'bills' | 'ledger'
const duesFilterStatus = ref('all');
const searchDuesCitizen = ref('');
const showVerifyModal = ref(false);
const selectedBillToVerify = ref(null);
const verifyRejectReason = ref('');
const showProofModal = ref(false);
const previewProofUrl = ref('');

// Smart Siskamling State
const patrolSubTab = ref('schedules'); // 'schedules' | 'swaps' | 'checkpoints' | 'map'
const patrolSummary = ref({
  total_schedules: 0,
  total_hadir: 0,
  total_izin: 0,
  total_alpha: 0,
  total_fines: 0,
  total_checkpoints_scanned: 0,
});
const patrolCheckpointsList = ref([]);
const patrolSwapsList = ref([]);

const showCreatePatrolModal = ref(false);
const newPatrolForm = ref({
  patrol_date: new Date().toISOString().substring(0, 10),
  day_name: 'Senin',
  shift_name: 'Malam (22:00 - 04:00)',
  rt: '001',
  rw: '005',
  notes: 'Patroli gang 1-4 & pos ronda utama',
  member_ids: [],
});

const showFineModal = ref(false);
const fineForm = ref({
  schedule_id: null,
  user_id: null,
  member_name: '',
  schedule_info: '',
  amount: 25000,
  reason: 'Alpha / Tidak hadir ronda tanpa keterangan izin resmi',
});

const showBroadcastWAModal = ref(false);
const broadcastWAPatrol = ref(null);

const showCheckpointSimModal = ref(false);
const checkpointSimForm = ref({
  checkpoint_code: 'POS-RONDA-01',
  situation_status: 'Aman Kondusif',
  notes: 'Pemeriksaan rutin pos ronda aman, pintu portal telah digembok.',
  user_id: null,
  photo_url: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500',
});


const filteredDuesBills = computed(() => {
  if (!duesData.value?.data) return [];
  return duesData.value.data.filter((item) => {
    const matchStatus = duesFilterStatus.value === 'all' || item.status === duesFilterStatus.value;
    const q = searchDuesCitizen.value.toLowerCase().trim();
    const matchSearch =
      !q ||
      (item.citizen_name && item.citizen_name.toLowerCase().includes(q)) ||
      (item.nik && item.nik.includes(q)) ||
      (item.receipt_number && item.receipt_number.toLowerCase().includes(q));
    return matchStatus && matchSearch;
  });
});
const newsList = ref([]);
const activeEmergency = ref(null);

const searchCitizen = ref('');
const showSignModal = ref(false);
const selectedLetter = ref(null);
const signNotes = ref('');

const showAddTreasuryModal = ref(false);
const newTreasury = ref({
  type: 'pemasukan',
  category: 'iuran_bulanan',
  title: '',
  amount: null,
  description: '',
});

const showAddNewsModal = ref(false);
const newNews = ref({
  title: '',
  category: 'Pengumuman',
  content: '',
  thumbnail_url: '',
  is_pinned: false,
});

// Navigation items definition (Matching Laptop Reference Photo)
const navItems = computed(() => [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'citizens', label: 'Data Warga', icon: Users, badge: stats.value.pending_citizens || null },
  { id: 'letters', label: 'Layanan Surat', icon: FileText, badge: stats.value.pending_letters || null },
  { id: 'treasury', label: 'Kas Darurat', icon: Wallet },
  { id: 'patrols', label: 'Jadwal Ronda', icon: Shield },
  { id: 'posyandu', label: 'Posyandu', icon: HeartPulse },
  { id: 'complaints', label: 'Aduan Warga', icon: AlertCircle, badge: stats.value.active_complaints || null },
  { id: 'news', label: 'Kabar Kampung', icon: Megaphone },
]);

const currentTitle = computed(() => {
  const map = {
    dashboard: 'Dashboard',
    citizens: 'Pusat Data & Verifikasi Warga',
    letters: 'Pelayanan Surat & Cetak PDF',
    treasury: 'Transparansi & Pembukuan Kas',
    patrols: 'Jadwal Ronda & Peta GPS',
    posyandu: 'Kegiatan Posyandu Balita & Lansia',
    complaints: 'Aduan Masalah Lingkungan & TPS',
    news: 'Kabar & Pengumuman Kampung',
  };
  return map[currentTab.value] || 'Warga Digital';
});

const recentLettersDisplay = computed(() => {
  if (lettersList.value && lettersList.value.length > 0) {
    return lettersList.value.slice(0, 5).map((l) => ({
      name: l.citizen_name || 'Budi Santoso',
      type: l.letter_type ? l.letter_type.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()) : 'Surat Domisili',
      date: formatDate(l.created_at) || '14 Okt 2026',
      status: l.status === 'selesai' ? 'Selesai' : 'Menunggu RT',
    }));
  }
  return [
    { name: 'Budi Santoso', type: 'Surat Domisili', date: '14 Okt 2026', status: 'Menunggu RT' },
    { name: 'Siti Aminah', type: 'Keterangan Usaha', date: '14 Okt 2026', status: 'Selesai' },
    { name: 'Joko Susilo', type: 'Surat Pengantar', date: '13 Okt 2026', status: 'Selesai' },
  ];
});

function formatNumber(num) {
  if (!num) return '0';
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

const pendingCitizensList = computed(() => {
  return citizensList.value.filter((c) => c.status === 'pending');
});

const filteredCitizens = computed(() => {
  if (!searchCitizen.value) return citizensList.value;
  const q = searchCitizen.value.toLowerCase();
  return citizensList.value.filter(
    (c) => c.name.toLowerCase().includes(q) || c.nik.includes(q)
  );
});

const pendingLettersList = computed(() => {
  return lettersList.value.filter((l) => l.status !== 'selesai' && l.status !== 'ditolak');
});

// Navigation
function selectTab(tabId) {
  currentTab.value = tabId;
  mobileNavOpen.value = false;

  if (tabId === 'patrols' || tabId === 'complaints') {
    nextTick(() => {
      initMap(tabId);
    });
  }
}

// Leaflet Map Initialization
function initMap(tabId) {
  const mapContainerId = tabId === 'patrols' ? 'patrol-map' : 'complaints-map';
  const container = document.getElementById(mapContainerId);
  if (!container || typeof window.L === 'undefined') return;

  // Center coordinate around Jakarta/Bogor area
  const centerLat = -6.2088;
  const centerLng = 106.8456;

  // Clear if already has leaflet instance
  if (container._leaflet_id) {
    container._leaflet_id = null;
    container.innerHTML = '';
  }

  const map = window.L.map(mapContainerId).setView([centerLat, centerLng], 16);

  window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '© OpenStreetMap kontributor',
  }).addTo(map);

  if (tabId === 'patrols') {
    // Pos Ronda Marker
    window.L.marker([centerLat, centerLng])
      .addTo(map)
      .bindPopup('<b>🚩 Pos Ronda Utama RT 001</b><br>Titik kumpul regu ronda malam & check-in GPS.')
      .openPopup();

    // Portal Barat Marker
    window.L.marker([-6.2095, 106.8465])
      .addTo(map)
      .bindPopup('<b>🚧 Portal Barat Gang Kenanga</b><br>Jalur patroli pengawasan portal.');
  } else {
    // Complaints Markers
    complaintsList.value.forEach((item) => {
      const lat = item.location_lat || -6.2091;
      const lng = item.location_lng || 106.8462;
      const color = item.status === 'selesai' ? 'green' : 'orange';

      window.L.marker([lat, lng])
        .addTo(map)
        .bindPopup(
          `<b>⚠️ ${item.title}</b><br>` +
          `Kategori: ${item.category}<br>` +
          `Status: <b>${item.status}</b><br>` +
          `Pelapor: ${item.reporter_name}`
        );
    });
  }
}

// Fetch all backend data
async function refreshData() {
  loading.value = true;
  try {
    const [statsRes, citizensRes, lettersRes, patrolsRes, linmasRes, posyanduRes, complaintsRes, treasuryRes, newsRes, emergencyRes, duesRes] =
      await Promise.all([
        axios.get(`${API_BASE}/stats`),
        axios.get(`${API_BASE}/citizens`),
        axios.get(`${API_BASE}/letters`),
        axios.get(`${API_BASE}/patrols`),
        axios.get(`${API_BASE}/linmas/attendances`),
        axios.get(`${API_BASE}/posyandu`),
        axios.get(`${API_BASE}/complaints`),
        axios.get(`${API_BASE}/treasury`),
        axios.get(`${API_BASE}/news`),
        axios.get(`${API_BASE}/emergency`),
        axios.get(`${API_BASE}/dues/all`),
      ]);

    stats.value = statsRes.data.data;
    citizensList.value = citizensRes.data.data;
    lettersList.value = lettersRes.data.data;
    patrolsList.value = patrolsRes.data.data;
    patrolSummary.value = patrolsRes.data.summary || {};
    patrolCheckpointsList.value = patrolsRes.data.recent_checkpoints || [];
    patrolSwapsList.value = patrolsRes.data.swap_requests || [];
    linmasList.value = linmasRes.data.data || [];
    posyanduData.value = posyanduRes.data.data;
    complaintsList.value = complaintsRes.data.data;
    treasuryData.value = treasuryRes.data;
    newsList.value = newsRes.data.data;
    duesData.value = duesRes.data;

    if (emergencyRes.data.data && emergencyRes.data.data.length > 0) {
      const active = emergencyRes.data.data.find((e) => e.status === 'aktif');
      if (active) activeEmergency.value = active;
    }
  } catch (error) {
    console.error('Error fetching data from backend:', error);
  } finally {
    loading.value = false;
  }
}

function saveVillageConfig() {
  localStorage.setItem('village_config', JSON.stringify(villageConfig.value));
  showSettingsModal.value = false;
  alert('Pengaturan identitas desa berhasil diperbarui!');
}

// Actions
async function approveCitizen(id) {
  try {
    await axios.post(`${API_BASE}/citizens/${id}/approve`, { admin_id: 1 });
    await refreshData();
    alert('Akun warga berhasil disetujui!');
  } catch (err) {
    alert('Gagal menyetujui akun warga.');
  }
}

async function rejectCitizen(id) {
  if (!confirm('Yakin ingin menolak pendaftaran akun warga ini?')) return;
  try {
    await axios.post(`${API_BASE}/citizens/${id}/reject`);
    await refreshData();
  } catch (err) {
    alert('Gagal menolak pendaftaran.');
  }
}

function openSignModal(letter) {
  selectedLetter.value = letter;
  signNotes.value = 'Berkas persyaratan telah diperiksa lengkap dan valid.';
  showSignModal.value = true;
}

async function confirmSignLetter() {
  if (!selectedLetter.value) return;
  try {
    await axios.put(`${API_BASE}/letters/${selectedLetter.value.id}/status`, {
      status: 'selesai',
      admin_notes: signNotes.value,
      admin_id: 1,
    });
    showSignModal.value = false;
    await refreshData();
    alert('Surat berhasil disahkan dengan Tanda Tangan QR Digital!');
  } catch (err) {
    alert('Gagal menandatangani surat.');
  }
}

async function resolveComplaint(id) {
  const notes = prompt('Masukkan catatan tindakan penyelesaian aduan:');
  if (!notes) return;
  try {
    await axios.put(`${API_BASE}/complaints/${id}/status`, {
      status: 'selesai',
      feedback_notes: notes,
    });
    await refreshData();
    alert('Aduan berhasil ditandai selesai.');
  } catch (err) {
    alert('Gagal memperbarui status aduan.');
  }
}

async function saveTreasury() {
  if (!newTreasury.value.title || !newTreasury.value.amount) {
    alert('Harap isi judul dan jumlah uang!');
    return;
  }
  try {
    await axios.post(`${API_BASE}/treasury`, {
      ...newTreasury.value,
      transaction_date: new Date().toISOString().split('T')[0],
      recorded_by: 1,
    });
    showAddTreasuryModal.value = false;
    newTreasury.value = { type: 'pemasukan', category: 'iuran_bulanan', title: '', amount: null, description: '' };
    await refreshData();
    alert('Transaksi berhasil dicatat ke buku kas RT!');
  } catch (err) {
    alert('Gagal menyimpan catatan kas.');
  }
}

function openVerifyModal(bill) {
  selectedBillToVerify.value = bill;
  verifyRejectReason.value = '';
  showVerifyModal.value = true;
}

async function submitVerification(action) {
  if (!selectedBillToVerify.value) return;
  if (action === 'reject' && !verifyRejectReason.value) {
    alert('Harap tuliskan alasan penolakan bukti transfer!');
    return;
  }
  try {
    const res = await axios.post(`${API_BASE}/dues/verify`, {
      bill_id: selectedBillToVerify.value.id,
      action: action,
      verified_by: 1,
      reject_reason: verifyRejectReason.value,
    });
    alert(res.data.message);
    showVerifyModal.value = false;
    await refreshData();
  } catch (err) {
    alert('Gagal memproses verifikasi: ' + (err.response?.data?.message || err.message));
  }
}

function openProofPreview(url) {
  previewProofUrl.value = url;
  showProofModal.value = true;
}

function sendWhatsAppReminder(bill) {
  const phone = bill.phone ? bill.phone.replace(/^0/, '62') : '';
  const msg = encodeURIComponent(
    `Halo Bpk/Ibu ${bill.citizen_name},\n\nMengingatkan kembali pembayaran Iuran Kas RT ${bill.title} sebesar ${formatRupiah(bill.amount)} untuk periode ${bill.month} ${bill.year}.\n\nPembayaran dapat dilakukan secara Tunai (Cash) ke Bendahara RT, atau via QRIS Statis & Transfer Bank di aplikasi Warga Digital.\n\nTerima kasih 🙏\n- Pengurus RT`
  );
  window.open(`https://wa.me/${phone}?text=${msg}`, '_blank');
}

async function receiveCashPayment(bill) {
  if (!canManageCash.value) {
    alert('Akses ditolak: Hanya Admin dan Staff/Bendahara RT yang berwenang mencatat penerimaan iuran tunai.');
    return;
  }
  const confirmMsg = `Konfirmasi penerimaan pembayaran TUNAI (CASH) dari ${bill.citizen_name} sebesar ${formatRupiah(bill.amount)}?\n\nKuitansi digital resmi otomatis terbit dan tercatat di buku kas.`;
  if (!confirm(confirmMsg)) return;

  try {
    const res = await axios.post(`${API_BASE}/dues/pay-cash-direct`, {
      bill_id: bill.id,
      recorded_by: currentUser.value?.id || 1,
      notes: 'Diterima langsung tunai oleh Bendahara',
    });
    alert('✅ ' + res.data.message + '\nNo. Kuitansi: ' + res.data.receipt_number);
    await refreshData();
  } catch (err) {
    alert('Gagal mencatat pembayaran tunai: ' + (err.response?.data?.message || err.message));
  }
}

async function saveNews() {
  if (!newNews.value.title || !newNews.value.content) {
    alert('Harap lengkapi judul dan isi berita!');
    return;
  }
  try {
    await axios.post(`${API_BASE}/news`, {
      ...newNews.value,
      author_id: 1,
    });
    showAddNewsModal.value = false;
    newNews.value = { title: '', category: 'Pengumuman', content: '', thumbnail_url: '', is_pinned: false };
    await refreshData();
    alert('Kabar kampung berhasil dipublikasikan!');
  } catch (err) {
    alert('Gagal mempublikasikan kabar kampung.');
  }
}

function formatRupiah(num) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
}

function formatDate(dateStr) {
  if (!dateStr) return '-';
  const d = new Date(dateStr);
  return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

// Auth Helper Methods
function getRoleBadgeText(role) {
  switch (role) {
    case 'rt':
    case 'rw':
      return '🎖️ Ketua RT 001';
    case 'bendahara':
      return '💰 Bendahara Kas';
    case 'linmas':
      return '👮 Linmas / Ronda';
    case 'posyandu':
      return '👶 Kader Posyandu';
    case 'warga':
      return '👤 Warga RT 001';
    default:
      return '⚙️ Pengurus RT';
  }
}

function getRoleColor(role) {
  switch (role) {
    case 'rt':
    case 'rw':
      return '#166534';
    case 'bendahara':
      return '#ea580c';
    case 'linmas':
      return '#2563eb';
    case 'posyandu':
      return '#db2777';
    default:
      return '#15803D';
  }
}

function getRoleBgColor(role) {
  switch (role) {
    case 'rt':
    case 'rw':
      return '#f0fdf4';
    case 'bendahara':
      return '#fff7ed';
    case 'linmas':
      return '#eff6ff';
    case 'posyandu':
      return '#fdf2f8';
    default:
      return '#f1f5f9';
  }
}

function getRoleTextColor(role) {
  switch (role) {
    case 'rt':
    case 'rw':
      return '#15803d';
    case 'bendahara':
      return '#c2410c';
    case 'linmas':
      return '#1d4ed8';
    case 'posyandu':
      return '#be185d';
    default:
      return '#334155';
  }
}

async function selectDemoRole(roleItem) {
  loginForm.value.nik = roleItem.nik;
  loginForm.value.password = roleItem.password;
  await handleLoginSubmit();
}

async function handleLoginSubmit() {
  loginLoading.value = true;
  loginError.value = '';
  try {
    const res = await axios.post(`${API_BASE}/login`, {
      nik: loginForm.value.nik,
      password: loginForm.value.password,
    });
    if (res.data?.success && res.data?.data?.user) {
      const user = res.data.data.user;
      currentUser.value = user;
      localStorage.setItem('warga_web_user', JSON.stringify(user));
      if (user.role === 'bendahara') {
        currentTab.value = 'treasury';
      } else if (user.role === 'linmas') {
        currentTab.value = 'linmas';
      } else if (user.role === 'posyandu') {
        currentTab.value = 'posyandu';
      } else {
        currentTab.value = 'dashboard';
      }
      loginForm.value = { nik: '', password: '' };
    } else {
      loginError.value = res.data?.message || 'Gagal masuk. Periksa kembali NIK / No. WhatsApp / Gmail / Kata Sandi.';
    }
  } catch (err) {
    const matched = demoRoles.find(
      (r) => r.nik.toLowerCase() === loginForm.value.nik.toLowerCase() || r.role === loginForm.value.nik.toLowerCase()
    );
    if (matched) {
      const fallbackUser = {
        id: 1,
        name: matched.name,
        nik: matched.nik,
        role: matched.role,
        role_label: matched.label,
        rt: '001',
        rw: '005',
      };
      currentUser.value = fallbackUser;
      localStorage.setItem('warga_web_user', JSON.stringify(fallbackUser));
      if (fallbackUser.role === 'bendahara') {
        currentTab.value = 'treasury';
      } else if (fallbackUser.role === 'linmas') {
        currentTab.value = 'linmas';
      } else if (fallbackUser.role === 'posyandu') {
        currentTab.value = 'posyandu';
      } else {
        currentTab.value = 'dashboard';
      }
    } else {
      loginError.value = 'NIK atau kata sandi tidak ditemukan.';
    }
  } finally {
    loginLoading.value = false;
  }
}

function confirmLogout() {
  showUserDropdown.value = false;
  showLogoutConfirm.value = true;
}

function performLogout() {
  currentUser.value = null;
  localStorage.removeItem('warga_web_user');
  showLogoutConfirm.value = false;
  showUserDropdown.value = false;
  loginError.value = '';
}

async function switchRoleTo(roleItem) {
  showSwitchRoleModal.value = false;
  await selectDemoRole(roleItem);
}

// --- SMART SISKAMLING HANDLERS ---
function openPrintPatrolSchedule() {
  window.open(`${SERVER_BASE}/patrols/print-schedule`, '_blank');
}

function openPrintQRStickers() {
  window.open(`${SERVER_BASE}/patrols/qr-stickers/print`, '_blank');
}

async function autoGeneratePatrols() {
  if (!confirm('Apakah Anda ingin menjadwalkan ronda mingguan otomatis (Senin s/d Minggu) untuk seluruh warga aktif secara adil?')) return;
  try {
    loading.value = true;
    const res = await axios.post(`${API_BASE}/patrols/auto-generate`, { rt: '001', rw: '005' });
    alert(res.data.message || 'Jadwal ronda berhasil digenerate otomatis!');
    await refreshData();
  } catch (err) {
    alert('Gagal generate jadwal: ' + (err.response?.data?.message || err.message));
  } finally {
    loading.value = false;
  }
}

function openCreatePatrolModal() {
  newPatrolForm.value = {
    patrol_date: new Date().toISOString().substring(0, 10),
    day_name: 'Senin',
    shift_name: 'Malam Regu 1 (22:00 - 04:00)',
    rt: '001',
    rw: '005',
    notes: 'Patroli gang 1-4 & pos ronda utama',
    member_ids: [],
  };
  showCreatePatrolModal.value = true;
}

async function submitCreatePatrol() {
  if (newPatrolForm.value.member_ids.length === 0) {
    alert('Pilih sekurang-kurangnya 1 warga sebagai anggota regu ronda!');
    return;
  }
  try {
    loading.value = true;
    await axios.post(`${API_BASE}/patrols/schedule`, newPatrolForm.value);
    alert('Jadwal ronda berhasil dibuat!');
    showCreatePatrolModal.value = false;
    await refreshData();
  } catch (err) {
    alert('Gagal membuat jadwal: ' + (err.response?.data?.message || err.message));
  } finally {
    loading.value = false;
  }
}

async function deletePatrolSchedule(id) {
  if (!confirm('Hapus jadwal ronda ini? Seluruh data absensi terkait regu ini akan ikut terhapus.')) return;
  try {
    await axios.delete(`${API_BASE}/patrols/schedule/${id}`);
    await refreshData();
  } catch (err) {
    alert('Gagal menghapus jadwal: ' + (err.response?.data?.message || err.message));
  }
}

function sendWAReminder(member, patrol) {
  const cleanPhone = (member.phone || '').replace(/[^0-9]/g, '');
  let phone = cleanPhone.startsWith('0') ? '62' + cleanPhone.substring(1) : cleanPhone;
  const text = `Assalamu'alaikum Bpk. ${member.name}, mengingatkan bahwa malam ini giliran Anda piket Ronda Siskamling RT 001 / RW 005 pada ${patrol.day_name}, ${patrol.patrol_date} (${patrol.shift_name}). Mohon hadir di Pos Ronda Utama tepat waktu dan lakukan presensi GPS via aplikasi Warga Digital. Terima kasih atas partisipasi aktif menjaga kampung! 🛡️ Salam Pengurus RT.`;
  window.open(`https://wa.me/${phone}?text=${encodeURIComponent(text)}`, '_blank');
}

function openBroadcastWAModal(patrol = null) {
  broadcastWAPatrol.value = patrol || patrolsList.value[0] || null;
  if (!broadcastWAPatrol.value) {
    alert('Belum ada jadwal ronda aktif untuk dikirimi pengingat WhatsApp.');
    return;
  }
  showBroadcastWAModal.value = true;
}

function openFineModal(member, patrol) {
  fineForm.value = {
    schedule_id: patrol.id,
    user_id: member.user_id,
    member_name: member.name,
    schedule_info: `${patrol.day_name}, ${patrol.patrol_date} (${patrol.shift_name})`,
    amount: 25000,
    reason: 'Alpha / Tidak hadir ronda tanpa keterangan izin resmi',
  };
  showFineModal.value = true;
}

async function submitApplyFine() {
  try {
    loading.value = true;
    const res = await axios.post(`${API_BASE}/patrols/apply-fine`, fineForm.value);
    alert(res.data.message || 'Sanksi denda berhasil diterapkan dan masuk ke tagihan Kas RT!');
    showFineModal.value = false;
    await refreshData();
  } catch (err) {
    alert('Gagal menerapkan sanksi: ' + (err.response?.data?.message || err.message));
  } finally {
    loading.value = false;
  }
}

async function payPatrolFine(member, patrol) {
  if (!confirm(`Catat pelunasan denda Rp ${Number(member.fine_amount || 25000).toLocaleString('id-ID')} dari ${member.name} dan masukkan langsung ke buku Kas RT?`)) return;
  try {
    const res = await axios.post(`${API_BASE}/patrols/pay-fine`, {
      schedule_id: patrol.id,
      user_id: member.user_id,
      amount: member.fine_amount || 25000,
      admin_id: currentUser.value?.id || 1,
    });
    alert(res.data.message);
    await refreshData();
  } catch (err) {
    alert('Gagal mencatat pembayaran denda: ' + (err.response?.data?.message || err.message));
  }
}

async function reviewSwapRequest(swapId, status) {
  const actionText = status === 'approved' ? 'menyetujui' : 'menolak';
  const notes = prompt(`Masukkan catatan pengurus saat ${actionText} permohonan ini:`, status === 'approved' ? 'Disetujui oleh pengurus RT' : 'Mohon koordinasi langsung');
  if (notes === null) return;

  try {
    loading.value = true;
    const res = await axios.post(`${API_BASE}/patrols/swap-requests/${swapId}/review`, {
      status,
      admin_notes: notes,
      reviewed_by: currentUser.value?.id || 1,
    });
    alert(res.data.message);
    await refreshData();
  } catch (err) {
    alert('Gagal memproses permohonan: ' + (err.response?.data?.message || err.message));
  } finally {
    loading.value = false;
  }
}

function openSimulateCheckpointModal() {
  checkpointSimForm.value = {
    checkpoint_code: 'POS-RONDA-01',
    situation_status: 'Aman Kondusif',
    notes: 'Pemeriksaan rutin pos ronda aman, pintu portal telah digembok.',
    user_id: currentUser.value?.id || citizensList.value[0]?.id || 1,
    photo_url: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500',
  };
  showCheckpointSimModal.value = true;
}

async function submitCheckpointScan() {
  try {
    loading.value = true;
    const res = await axios.post(`${API_BASE}/patrols/checkpoint-scan`, checkpointSimForm.value);
    alert(res.data.message);
    showCheckpointSimModal.value = false;
    await refreshData();
  } catch (err) {
    alert('Gagal scan checkpoint: ' + (err.response?.data?.message || err.message));
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  const savedConfig = localStorage.getItem('village_config');
  if (savedConfig) {
    try {
      villageConfig.value = JSON.parse(savedConfig);
    } catch (e) {}
  }

  const savedUser = localStorage.getItem('warga_web_user');
  if (savedUser) {
    try {
      currentUser.value = JSON.parse(savedUser);
    } catch (e) {}
  } else {
    // Default demo role is Ketua RT so the panel is ready, but user can click Logout anytime!
    const defaultUser = {
      id: 1,
      name: 'Bambang Sudarmono',
      nik: '3201010101900001',
      role: 'rt',
      role_label: 'Ketua RT 001',
      rt: '001',
      rw: '005',
    };
    currentUser.value = defaultUser;
    localStorage.setItem('warga_web_user', JSON.stringify(defaultUser));
  }

  refreshData();
});
</script>

<style scoped>
.spin-anim {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* Sidebar Logout Button */
.sidebar-logout-btn {
  margin-top: 10px;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: rgba(220, 38, 38, 0.15);
  color: #fca5a5;
  border: 1px solid rgba(220, 38, 38, 0.3);
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sidebar-logout-btn:hover {
  background: rgba(220, 38, 38, 0.3);
  color: #ffffff;
  border-color: #ef4444;
}

/* Topbar Profile Dropdown */
.profile-dropdown-menu {
  position: absolute;
  top: 52px;
  right: 0;
  width: 240px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(15, 23, 42, 0.12);
  padding: 8px;
  z-index: 100;
  animation: dropdownFade 0.18s ease-out;
}

@keyframes dropdownFade {
  from {
    opacity: 0;
    transform: translateY(-6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.dropdown-header {
  padding: 10px 12px;
}

.dropdown-user-name {
  font-weight: 800;
  font-size: 0.92rem;
  color: #0f172a;
}

.dropdown-user-sub {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: 2px;
}

.dropdown-role-tag {
  display: inline-block;
  margin-top: 6px;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.72rem;
  font-weight: 800;
}

.dropdown-divider {
  height: 1px;
  background: #f1f5f9;
  margin: 6px 0;
}

.dropdown-item {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 12px;
  border: none;
  background: transparent;
  color: #334155;
  font-size: 0.82rem;
  font-weight: 600;
  border-radius: 8px;
  cursor: pointer;
  text-align: left;
  transition: all 0.15s ease;
}

.dropdown-item:hover {
  background: #f8fafc;
  color: #0f172a;
}

.dropdown-item-danger {
  color: #dc2626;
}

.dropdown-item-danger:hover {
  background: #fef2f2;
  color: #b91c1c;
}

/* Topbar Notification Dropdown */
.notifications-dropdown-menu {
  position: absolute;
  top: 52px;
  right: 0;
  width: 380px;
  max-width: 90vw;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  box-shadow: 0 16px 40px rgba(15, 23, 42, 0.15);
  z-index: 100;
  overflow: hidden;
  animation: dropdownFade 0.18s ease-out;
}

.notif-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 18px;
  border-bottom: 1px solid #f1f5f9;
  background: #f8fafc;
}

.notif-title {
  font-size: 0.92rem;
  font-weight: 800;
  color: #0f172a;
}

.notif-subtitle {
  font-size: 0.74rem;
  color: #64748b;
  margin-top: 2px;
}

.notif-mark-read-btn {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.74rem;
  font-weight: 700;
  color: #16a34a;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  padding: 4px 9px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.notif-mark-read-btn:hover {
  background: #dcfce7;
}

.notif-filter-tabs {
  display: flex;
  gap: 6px;
  padding: 8px 14px;
  border-bottom: 1px solid #f1f5f9;
  background: #ffffff;
  overflow-x: auto;
}

.notif-filter-chip {
  font-size: 0.72rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 9999px;
  border: 1px solid #e2e8f0;
  background: #f8fafc;
  color: #475569;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.15s ease;
}

.notif-filter-chip:hover {
  border-color: #cbd5e1;
  background: #f1f5f9;
}

.notif-filter-chip.active {
  background: #14532d;
  color: #ffffff;
  border-color: #14532d;
}

.notif-list {
  max-height: 380px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.notif-item {
  display: flex;
  gap: 12px;
  padding: 12px 16px;
  border-bottom: 1px solid #f8fafc;
  cursor: pointer;
  transition: background 0.15s ease;
  text-align: left;
}

.notif-item:hover {
  background: #f8fafc;
}

.notif-item.notif-unread {
  background: #f0fdf4;
}

.notif-icon-wrap {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.notif-content {
  flex: 1;
  min-width: 0;
}

.notif-item-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 8px;
}

.notif-item-title {
  font-size: 0.84rem;
  font-weight: 800;
  color: #0f172a;
}

.notif-time {
  font-size: 0.7rem;
  color: #94a3b8;
  white-space: nowrap;
}

.notif-message {
  font-size: 0.76rem;
  color: #475569;
  margin: 4px 0 6px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.notif-footer-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.notif-action-link {
  font-size: 0.72rem;
  font-weight: 700;
  color: #16a34a;
}

.notif-badge-new {
  font-size: 0.65rem;
  font-weight: 800;
  background: #ea580c;
  color: white;
  padding: 1px 6px;
  border-radius: 4px;
}

.notif-empty {
  padding: 30px 16px;
  text-align: center;
  font-size: 0.8rem;
  color: #94a3b8;
}

.notif-footer {
  padding: 10px 14px;
  text-align: center;
  border-top: 1px solid #f1f5f9;
  background: #f8fafc;
}

.notif-view-all {
  background: none;
  border: none;
  font-size: 0.78rem;
  font-weight: 700;
  color: #15803d;
  cursor: pointer;
  transition: color 0.15s ease;
}

.notif-view-all:hover {
  color: #064e3b;
  text-decoration: underline;
}

/* Switch Role Modal Styles */
.switch-role-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.switch-role-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.18s ease;
  background: #ffffff;
}

.switch-role-item:hover {
  border-color: #86efac;
  background: #f0fdf4;
}

.switch-role-item.current {
  border-color: #16a34a;
  background: #f0fdf4;
}

.switch-role-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.switch-role-text {
  flex: 1;
}

.switch-role-label {
  font-size: 0.86rem;
  font-weight: 800;
  color: #0f172a;
}

.switch-role-desc {
  font-size: 0.74rem;
  color: #64748b;
  margin-top: 2px;
}

/* Login Page Styles */
.login-page {
  min-height: 100vh;
  width: 100vw;
  background: linear-gradient(135deg, #062c17 0%, #0B4626 50%, #047857 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  padding: 30px 16px;
}

.login-bg-decor {
  position: absolute;
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(52, 211, 153, 0.18) 0%, rgba(0, 0, 0, 0) 70%);
  top: -150px;
  right: -150px;
  border-radius: 50%;
  pointer-events: none;
}

.login-container {
  width: 100%;
  max-width: 520px;
  z-index: 10;
}

.login-brand-header {
  text-align: center;
  margin-bottom: 24px;
}

.login-logo-circle {
  display: inline-flex;
  margin-bottom: 10px;
}

.login-title {
  color: #ffffff;
  font-size: 1.65rem;
  font-weight: 900;
  letter-spacing: -0.02em;
  margin-bottom: 4px;
}

.login-subtitle {
  color: #a7f3d0;
  font-size: 0.86rem;
  font-weight: 500;
}

.login-card {
  background: #ffffff;
  border-radius: 20px;
  padding: 28px 24px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25);
}

.login-card-header {
  margin-bottom: 20px;
}

.login-card-header h2 {
  font-size: 1.25rem;
  font-weight: 800;
  color: #0f172a;
}

.login-card-header p {
  font-size: 0.82rem;
  color: #64748b;
  margin-top: 4px;
}

.login-quick-section {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 12px;
  margin-bottom: 16px;
}

.quick-title {
  font-size: 0.78rem;
  font-weight: 800;
  color: #065f46;
  margin-bottom: 8px;
}

.quick-role-pills {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.quick-pill-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 20px;
  border: 1.5px solid transparent;
  font-size: 0.8rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.15s ease;
}

.quick-pill-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
}

.login-divider {
  display: flex;
  align-items: center;
  text-align: center;
  margin: 16px 0;
  color: #94a3b8;
  font-size: 0.76rem;
}

.login-divider::before,
.login-divider::after {
  content: '';
  flex: 1;
  border-bottom: 1px solid #e2e8f0;
}

.login-divider span {
  padding: 0 10px;
}

.login-error-alert {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #b91c1c;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 0.8rem;
  margin-bottom: 12px;
}

.input-with-icon {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 12px;
  color: #94a3b8;
}

.input-with-icon input {
  padding-left: 36px;
}

.login-btn {
  width: 100%;
  padding: 11px;
  font-size: 0.92rem;
  font-weight: 800;
  border-radius: 10px;
  background: #047857;
  color: white;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.2s ease;
}

.login-btn:hover {
  background: #065f46;
}

.login-footer {
  text-align: center;
  margin-top: 18px;
  color: #a7f3d0;
  font-size: 0.75rem;
}
</style>
