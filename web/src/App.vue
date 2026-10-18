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
        <!-- Close button on Mobile Drawer -->
        <button
          class="sidebar-close-btn"
          @click="mobileNavOpen = false"
          title="Tutup Menu"
        >
          <X size="20" />
        </button>
      </div>

      <nav class="sidebar-nav">
        <a
          v-for="item in navItems"
          :key="item.id"
          class="nav-item"
          :class="{ active: currentTab === item.id }"
          @click="selectTab(item.id)"
        >
          <div
            class="nav-icon-badge"
            :style="{
              background: item.iconGradient,
              boxShadow: currentTab === item.id ? `0 4px 14px ${item.iconShadow}` : `0 2px 6px rgba(0,0,0,0.22)`
            }"
          >
            <component :is="item.icon" size="16" />
          </div>
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
        <div class="topbar-left">
          <!-- Mobile Hamburger Menu Button -->
          <button
            class="mobile-nav-toggle-btn"
            title="Buka Menu Navigasi"
            @click="mobileNavOpen = !mobileNavOpen"
          >
            <Menu size="20" />
          </button>

          <!-- Left: Administrasi Desa / Warga Digital -->
          <div class="topbar-brand">
            <span class="topbar-subheading">ADMINISTRASI DESA</span>
            <h2 class="topbar-heading">WARGA DIGITAL</h2>
          </div>
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
              <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 10px;">
                <div>
                  <div class="ref-stat-title">Total Warga</div>
                  <div class="ref-stat-value">
                    {{ stats.total_citizens ? formatNumber(stats.total_citizens) : '1.240' }}
                    <span class="ref-stat-arrow">↗</span>
                  </div>
                </div>
                <div class="stat-icon-3d" style="background: linear-gradient(135deg, #3B82F6 0%, #1D4ED8 100%); box-shadow: 0 8px 18px rgba(59, 130, 246, 0.35);">
                  <Users size="22" color="#FFFFFF" />
                </div>
              </div>
              <div class="ref-stat-footer">
                <span class="ref-stat-subtext">Total {{ stats.total_citizens ? formatNumber(stats.total_citizens) : '1.240' }} Warga Terdata</span>
              </div>
            </div>

            <!-- Card 2: Pengajuan Surat -->
            <div class="ref-stat-card">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 10px;">
                <div>
                  <div class="ref-stat-title">Pengajuan Surat</div>
                  <div class="ref-stat-value">
                    {{ stats.pending_letters || 18 }}
                  </div>
                </div>
                <div class="stat-icon-3d" style="background: linear-gradient(135deg, #F59E0B 0%, #EA580C 100%); box-shadow: 0 8px 18px rgba(245, 158, 11, 0.35);">
                  <FileText size="22" color="#FFFFFF" />
                </div>
              </div>
              <div class="ref-stat-footer">
                <span class="ref-stat-pill" style="background: #FEF3C7; color: #B45309;">Menunggu Proses</span>
              </div>
            </div>

            <!-- Card 3: Saldo Kas Darurat -->
            <div class="ref-stat-card">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 10px;">
                <div>
                  <div class="ref-stat-title">Saldo Kas Darurat</div>
                  <div class="ref-stat-value" style="font-size: 1.65rem;">
                    {{ stats.treasury?.balance ? formatRupiah(stats.treasury.balance) : 'Rp 45.200.000' }}
                  </div>
                </div>
                <div class="stat-icon-3d" style="background: linear-gradient(135deg, #10B981 0%, #047857 100%); box-shadow: 0 8px 18px rgba(16, 185, 129, 0.35);">
                  <Wallet size="22" color="#FFFFFF" />
                </div>
              </div>
              <div class="ref-stat-footer">
                <span class="ref-stat-pill" style="background: #DCFCE7; color: #15803D;">Kas RT Aktif</span>
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
          <div class="warga-charts-grid">
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
                        <button class="btn-success" style="padding: 4px 10px; font-size: 0.75rem;" @click="approveCitizen(citizen.id)">
                          Setujui
                        </button>
                        <button class="btn-outline" style="padding: 4px 10px; font-size: 0.75rem; color: #dc2626;" @click="rejectCitizen(citizen.id)">
                          Tolak
                        </button>
                      </div>
                      <div v-else style="display: flex; align-items: center; gap: 8px;">
                        <a
                          v-if="citizen.phone"
                          :href="`https://wa.me/${citizen.phone.replace(/^0/, '62')}`"
                          target="_blank"
                          class="btn-outline"
                          style="padding: 5px 10px; font-size: 0.75rem; color: #16a34a; border-color: #86efac; background: #f0fdf4; display: inline-flex; align-items: center; gap: 4px; text-decoration: none; font-weight: 700;"
                          title="Hubungi warga via WhatsApp"
                        >
                          <Send size="12" />
                          <span>Chat WA</span>
                        </a>
                        <button
                          class="btn-outline"
                          style="padding: 5px 10px; font-size: 0.75rem; color: #0284c7; border-color: #bae6fd; background: #f0f9ff; display: inline-flex; align-items: center; gap: 4px; font-weight: 700;"
                          title="Lihat detail lengkap warga"
                          @click="openCitizenDetail(citizen)"
                        >
                          <Eye size="12" />
                          <span>Detail</span>
                        </button>
                        <span class="badge" style="background: #f1f5f9; color: #475569; font-weight: 700; font-size: 0.7rem;">
                          {{ citizen.role.toUpperCase() }}
                        </span>
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
                          :href="`${API_BASE}/letters/${letter.id}/print?autoprint=1`"
                          target="_blank"
                          class="btn-success"
                          style="text-decoration: none; padding: 6px 12px; font-size: 0.76rem; font-weight: 700; display: inline-flex; align-items: center; gap: 5px;"
                          title="Buka Lembar Surat Resmi & Unduh / Cetak PDF"
                        >
                          <Printer size="13" />
                          <span>Cetak Dokumen PDF</span>
                        </a>

                        <button
                          v-if="letter.status === 'selesai'"
                          class="btn-outline"
                          style="padding: 6px 12px; font-size: 0.76rem; color: #16a34a; border-color: #86efac; background: #f0fdf4; display: inline-flex; align-items: center; gap: 5px;"
                          title="Kirim notifikasi berkas PDF selesai ke WhatsApp pemohon"
                          @click="sendLetterWhatsApp(letter)"
                        >
                          <Send size="13" />
                          <span>Kirim WA</span>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

                <!-- 4. TAB: ABSEN LINMAS & UPDATE SITUASI KEAMANAN (KHUSUS LINMAS & PENGURUS RT) -->
        <div v-if="currentTab === 'patrols'">
          <!-- Header Command Bar Linmas -->
          <div class="card" style="margin-bottom: 20px; background: linear-gradient(135deg, #064e3b 0%, #0f172a 100%); color: white; border: none; box-shadow: 0 10px 25px -5px rgba(6, 78, 59, 0.4);">
            <div class="card-body" style="padding: 24px;">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                <div>
                  <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                    <span style="background: rgba(16, 185, 129, 0.2); border: 1px solid rgba(52, 211, 153, 0.4); padding: 4px 10px; border-radius: 20px; font-size: 0.76rem; font-weight: 700; color: #86efac;">
                      🛡️ PUSAT OPERASIONAL KEAMANAN & LINMAS RT 001
                    </span>
                    <span class="badge badge-warning" style="font-size: 0.72rem; background: rgba(245, 158, 11, 0.2); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.4);">
                      🔒 Akses Khusus: Linmas & Pengurus RT
                    </span>
                  </div>
                  <h2 style="font-size: 1.45rem; font-weight: 800; color: white; margin: 0 0 6px 0;">
                    Presensi Linmas di Tempat & Update Situasi Keamanan Pos
                  </h2>
                  <p style="font-size: 0.88rem; color: #cbd5e1; margin: 0; max-width: 680px; line-height: 1.5;">
                    Pencatatan absensi geotagging GPS petugas jaga di Pos Ronda RT 001, buku mutasi situasi harian, serta verifikasi laporan langsung oleh Ketua RT. Data ini dirahasiakan dari warga biasa.
                  </p>
                </div>

                <div style="display: flex; flex-wrap: wrap; gap: 8px;">
                  <button class="btn-primary" style="background: #10b981; border: none; font-weight: 700; padding: 9px 16px;" @click="showLinmasCheckInModal = true">
                    <MapPin size="16" /> Absen di Tempat (GPS)
                  </button>
                  <button class="btn-primary" style="background: #0284c7; border: none; font-weight: 700; padding: 9px 16px;" @click="showLinmasSituationModal = true">
                    <MessageSquare size="16" /> Kirim Update Situasi
                  </button>
                  <button class="btn-outline" style="background: rgba(255,255,255,0.12); color: white; border-color: rgba(255,255,255,0.25);" @click="fetchPatrols">
                    <RefreshCw size="16" /> Segarkan Data
                  </button>
                </div>
              </div>

              <!-- Quick Status Cards -->
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-top: 24px;">
                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.74rem; color: #94a3b8; font-weight: 600;">PETUGAS PIKET AKTIF</div>
                  <div style="font-size: 1.5rem; font-weight: 800; color: #fff; margin-top: 2px;">
                    {{ linmasAttendances.filter(a => a.status === 'bertugas').length || 2 }} <span style="font-size: 0.85rem; font-weight: 500; color: #86efac;">Personil</span>
                  </div>
                  <div style="font-size: 0.72rem; color: #86efac; margin-top: 2px;">Piket Malam Pos Utama</div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.74rem; color: #94a3b8; font-weight: 600;">STATUS SITUASI LINGKUNGAN</div>
                  <div style="font-size: 1.35rem; font-weight: 800; color: #34d399; margin-top: 2px;">
                    ● Aman Kondusif
                  </div>
                  <div style="font-size: 0.72rem; color: #a7f3d0; margin-top: 2px;">Pintu portal terkunci</div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.74rem; color: #94a3b8; font-weight: 600;">VALIDASI GEOTAGGING GPS</div>
                  <div style="font-size: 1.35rem; font-weight: 800; color: #38bdf8; margin-top: 2px;">
                    Valid di Tempat
                  </div>
                  <div style="font-size: 0.72rem; color: #bae6fd; margin-top: 2px;">Radius 8m dari Pos RT 001</div>
                </div>

                <div style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 14px;">
                  <div style="font-size: 0.74rem; color: #94a3b8; font-weight: 600;">LOG KABAR HARI INI</div>
                  <div style="font-size: 1.5rem; font-weight: 800; color: #fbbf24; margin-top: 2px;">
                    {{ linmasSituationLogs.length }} <span style="font-size: 0.85rem; font-weight: 500; color: #fef08a;">Laporan</span>
                  </div>
                  <div style="font-size: 0.72rem; color: #fef08a; margin-top: 2px;">Diverifikasi Pengurus RT</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Subtabs: Situasi Hari Ini & Rekap Absensi -->
          <div style="display: flex; gap: 8px; margin-bottom: 20px; border-bottom: 2px solid #e2e8f0; padding-bottom: 12px;">
            <button
              :class="linmasSubTab === 'situation' ? 'btn-primary' : 'btn-outline'"
              style="font-size: 0.85rem; padding: 8px 16px; display: flex; align-items: center; gap: 8px;"
              @click="linmasSubTab = 'situation'"
            >
              <MessageSquare size="16" />
              <span>Update Kabar Situasi Hari Ini (Buku Mutasi Linmas)</span>
              <span style="background: #10b981; color: white; border-radius: 9999px; padding: 2px 8px; font-size: 0.72rem; font-weight: 700;">
                {{ linmasSituationLogs.length }}
              </span>
            </button>

            <button
              :class="linmasSubTab === 'attendance' ? 'btn-primary' : 'btn-outline'"
              style="font-size: 0.85rem; padding: 8px 16px; display: flex; align-items: center; gap: 8px;"
              @click="linmasSubTab = 'attendance'"
            >
              <MapPin size="16" />
              <span>Rekap Presensi Petugas Linmas di Tempat</span>
              <span style="background: #0284c7; color: white; border-radius: 9999px; padding: 2px 8px; font-size: 0.72rem; font-weight: 700;">
                {{ linmasAttendances.length }}
              </span>
            </button>
          </div>

          <!-- SUBTAB 1: LOG SITUASI HARI INI -->
          <div v-if="linmasSubTab === 'situation'">
            <div class="card">
              <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h3 class="card-title" style="margin: 0; display: flex; align-items: center; gap: 8px;">
                  <Clock size="18" style="color: #10b981;" />
                  Catatan Update Situasi Keamanan Pos Ronda (Real-Time Hari Ini)
                </h3>
                <button class="btn-primary" style="font-size: 0.8rem; padding: 6px 14px;" @click="showLinmasSituationModal = true">
                  <Plus size="14" /> Tulis Laporan Baru
                </button>
              </div>
              <div class="card-body">
                <div v-if="linmasSituationLogs.length === 0" style="text-align: center; padding: 40px; color: #64748b;">
                  Belum ada catatan situasi pos ronda hari ini.
                </div>
                <div v-else style="display: flex; flex-direction: column; gap: 14px;">
                  <div
                    v-for="log in linmasSituationLogs"
                    :key="log.id"
                    style="border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px; background: #ffffff; display: flex; justify-content: space-between; align-items: flex-start; gap: 14px;"
                  >
                    <div style="flex: 1;">
                      <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                        <span style="background: #f1f5f9; padding: 3px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 800; color: #0f172a; font-family: monospace;">
                          🕒 {{ log.time_string }}
                        </span>
                        <span style="font-weight: 700; font-size: 0.88rem; color: #0f172a;">
                          {{ log.officer_name }}
                        </span>
                        <span style="font-size: 0.75rem; color: #64748b;">
                          • {{ log.post_name }}
                        </span>
                        <span
                          class="badge"
                          :style="{
                            background: log.status === 'aman' ? '#f0fdf4' : (log.status === 'waspada' ? '#fffbeb' : '#fef2f2'),
                            color: log.status === 'aman' ? '#16a34a' : (log.status === 'waspada' ? '#d97706' : '#dc2626'),
                            borderColor: log.status === 'aman' ? '#86efac' : (log.status === 'waspada' ? '#fde68a' : '#fecaca'),
                          }"
                        >
                          ● {{ log.status.toUpperCase() }}
                        </span>
                      </div>
                      <p style="font-size: 0.86rem; color: #334155; margin: 0; line-height: 1.5;">
                        {{ log.details }}
                      </p>
                    </div>

                    <div style="text-align: right; flex-shrink: 0;">
                      <div v-if="log.verified_by_rt" style="display: flex; align-items: center; gap: 4px; color: #16a34a; font-size: 0.75rem; font-weight: 700;">
                        <CheckCircle size="14" />
                        <span>Diverifikasi: {{ log.verified_by_name || 'Ketua RT' }}</span>
                      </div>
                      <button
                        v-else-if="['rt', 'rw', 'admin', 'staff'].includes(currentUser?.role)"
                        class="btn-outline"
                        style="font-size: 0.75rem; padding: 4px 10px; color: #16a34a; border-color: #86efac; background: #f0fdf4;"
                        @click="verifySituationLog(log.id)"
                      >
                        ✅ Verifikasi Pengecekan RT
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- SUBTAB 2: REKAP PRESENSI LINMAS DI TEMPAT -->
          <div v-if="linmasSubTab === 'attendance'">
            <div class="card">
              <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h3 class="card-title" style="margin: 0; display: flex; align-items: center; gap: 8px;">
                  <MapPin size="18" style="color: #0284c7;" />
                  Daftar Absensi Kehadiran Petugas Linmas di Pos Ronda
                </h3>
                <button class="btn-primary" style="font-size: 0.8rem; padding: 6px 14px;" @click="showLinmasCheckInModal = true">
                  <Plus size="14" /> Absen Petugas Baru
                </button>
              </div>
              <div class="table-responsive">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Nama Petugas</th>
                      <th>Shift & Pos Jaga</th>
                      <th>Jam Masuk & Keluar</th>
                      <th>Validasi GPS (Di Tempat)</th>
                      <th>Status & Catatan</th>
                      <th>Aksi Verifikasi</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="linmasAttendances.length === 0">
                      <td colspan="6" style="text-align: center; padding: 30px; color: #64748b;">
                        Belum ada data presensi petugas linmas hari ini.
                      </td>
                    </tr>
                    <tr v-for="att in linmasAttendances" :key="att.id">
                      <td>
                        <div style="font-weight: 700; color: #0f172a;">{{ att.officer_name }}</div>
                        <div style="font-size: 0.72rem; color: #16a34a; font-weight: 600;">Petugas Keamanan Terdaftar</div>
                      </td>
                      <td>
                        <div style="font-weight: 600; color: #334155;">{{ att.shift }}</div>
                        <div style="font-size: 0.72rem; color: #64748b;">{{ att.post_name }}</div>
                      </td>
                      <td>
                        <div style="font-size: 0.8rem; font-weight: 700; color: #0f172a;">
                          Masuk: {{ att.check_in_time ? new Date(att.check_in_time).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) : '19:45' }} WIB
                        </div>
                        <div style="font-size: 0.72rem; color: #64748b;">
                          Keluar: {{ att.check_out_time ? new Date(att.check_out_time).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) + ' WIB' : 'Sedang Bertugas' }}
                        </div>
                      </td>
                      <td>
                        <div style="display: inline-flex; align-items: center; gap: 4px; padding: 4px 8px; border-radius: 6px; background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; font-size: 0.74rem; font-weight: 700;">
                          <MapPin size="12" /> Di Pos Ronda RT 001 (Valid)
                        </div>
                        <div style="font-size: 0.68rem; color: #64748b; margin-top: 2px;">
                          {{ att.check_in_lat || -6.2088 }}, {{ att.check_in_lng || 106.8456 }}
                        </div>
                      </td>
                      <td>
                        <span class="badge" :class="att.status === 'bertugas' ? 'badge-success' : 'badge-info'">
                          {{ att.status === 'bertugas' ? '🟢 Aktif Jaga' : 'Selesai Tugas' }}
                        </span>
                        <div style="font-size: 0.72rem; color: #475569; margin-top: 4px;">{{ att.notes }}</div>
                      </td>
                      <td>
                        <button
                          v-if="['rt', 'rw', 'admin', 'staff'].includes(currentUser?.role)"
                          class="btn-outline"
                          style="font-size: 0.72rem; padding: 4px 8px; color: #16a34a; border-color: #86efac; background: #f0fdf4;"
                          @click="verifyLinmasAttendance(att.id)"
                        >
                          Verifikasi RT
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

<!-- 5. TAB: POSYANDU MELATI (MANAJEMEN JADWAL, LIBUR MENDADAK & TUMBUH KEMBANG) -->
        <div v-if="currentTab === 'posyandu'">
          <!-- Top Posyandu Alert Banner if any activity is postponed / libur mendadak -->
          <div
            v-if="posyanduData.activities?.some(a => a.status === 'postponed')"
            style="margin-bottom: 20px; padding: 16px 20px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 14px; display: flex; align-items: center; justify-content: space-between; gap: 14px; flex-wrap: wrap;"
          >
            <div style="display: flex; align-items: center; gap: 12px;">
              <span style="font-size: 1.6rem;">⚠️</span>
              <div>
                <strong style="color: #92400e; font-size: 0.95rem;">
                  PENGUMUMAN DARURAT: Terdapat Jadwal Posyandu yang Diliburkan / Ditunda Mendadak!
                </strong>
                <p style="margin: 2px 0 0; font-size: 0.82rem; color: #b45309;">
                  Kader telah menerbitkan maklumat ke Kabar Kampung dan menyiapkan pesan siaran WhatsApp ke grup ibu-ibu balita.
                </p>
              </div>
            </div>
          </div>

          <div class="posyandu-cards-grid">
            <!-- CARD 1: JADWAL POSYANDU & MANAJEMEN LIBUR MENDADAK -->
            <div class="card">
              <div class="card-header" style="flex-wrap: wrap; gap: 10px;">
                <h3 class="card-title">
                  <HeartPulse size="18" style="color: #ec4899;" />
                  Jadwal & Agenda Posyandu Melati
                </h3>
                <button
                  class="btn-primary"
                  style="font-size: 0.78rem; padding: 6px 14px; background: #ec4899; box-shadow: 0 4px 12px rgba(236, 72, 153, 0.25);"
                  @click="openAddPosyanduModal"
                >
                  <Plus size="14" />
                  <span>Jadwalkan Posyandu</span>
                </button>
              </div>

              <div class="card-body" style="padding: 16px;">
                <div v-if="!posyanduData.activities || posyanduData.activities.length === 0" style="text-align: center; padding: 30px; color: #94a3b8;">
                  Belum ada jadwal kegiatan posyandu. Silakan klik tombol di atas untuk membuat jadwal.
                </div>

                <div
                  v-for="activity in posyanduData.activities"
                  :key="activity.id"
                  style="padding: 16px; border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 14px; background: white; transition: all 0.2s;"
                >
                  <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px;">
                    <div>
                      <strong style="color: #0f172a; font-size: 1rem;">{{ activity.title }}</strong>
                      <div style="font-size: 0.8rem; color: #64748b; margin-top: 3px;">
                        📅 {{ formatDate(activity.activity_date) }} • 📍 {{ activity.location }}
                      </div>
                    </div>

                    <!-- Status Badge -->
                    <div>
                      <span
                        v-if="activity.status === 'postponed'"
                        class="badge"
                        style="background: #fef3c7; color: #92400e; border: 1px solid #fde68a; font-weight: 700; font-size: 0.74rem;"
                      >
                        ⚠️ Ditunda / Libur Mendadak
                      </span>
                      <span
                        v-else-if="activity.status === 'cancelled'"
                        class="badge badge-danger"
                      >
                        Dibatalkan
                      </span>
                      <span
                        v-else
                        class="badge badge-success"
                      >
                        🟢 Aktif Terjadwal
                      </span>
                    </div>
                  </div>

                  <p style="font-size: 0.84rem; color: #475569; margin: 8px 0; line-height: 1.45;">
                    {{ activity.description || 'Penimbangan berat badan balita, pengukuran tinggi badan, imunisasi rutin, dan vitamin A.' }}
                  </p>

                  <!-- Warning Box if Posyandu is Postponed (Libur Mendadak) -->
                  <div
                    v-if="activity.status === 'postponed'"
                    style="margin: 10px 0; padding: 12px; background: #fffbeb; border: 1px solid #fef08a; border-radius: 8px; font-size: 0.82rem; color: #92400e;"
                  >
                    <div style="font-weight: 800; display: flex; align-items: center; gap: 6px;">
                      <span>📢 Alasan Libur / Penundaan:</span>
                    </div>
                    <div style="margin-top: 4px; color: #78350f;">
                      {{ activity.postponed_reason || 'Kader berhalangan karena keperluan mendadak.' }}
                    </div>
                    <div v-if="activity.rescheduled_date" style="margin-top: 6px; font-weight: 700; color: #15803d;">
                      🗓️ Jadwal Pengganti: {{ formatDate(activity.rescheduled_date) }}
                    </div>
                  </div>

                  <!-- Action Buttons for Posyandu Schedule -->
                  <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px; padding-top: 10px; border-top: 1px solid #f1f5f9;">
                    <!-- 1. Tombol Libur Mendadak / Tunda Jadwal -->
                    <button
                      v-if="activity.status !== 'postponed'"
                      class="btn-outline"
                      style="font-size: 0.74rem; padding: 5px 10px; color: #b45309; border-color: #fde68a; background: #fffbeb; display: inline-flex; align-items: center; gap: 5px; font-weight: 700;"
                      title="Klik jika terjadi libur mendadak atau penundaan kegiatan"
                      @click="openPostponeModal(activity)"
                    >
                      <AlertTriangle size="13" />
                      <span>Libur Mendadak / Tunda</span>
                    </button>

                    <!-- Tombol Kembalikan Terjadwal jika sebelumnya ditunda -->
                    <button
                      v-else
                      class="btn-outline"
                      style="font-size: 0.74rem; padding: 5px 10px; color: #16a34a; border-color: #86efac; background: #f0fdf4; display: inline-flex; align-items: center; gap: 5px; font-weight: 700;"
                      @click="activateSchedule(activity)"
                    >
                      <CheckCircle size="13" />
                      <span>Aktifkan Kembali Jadwal</span>
                    </button>

                    <!-- 2. Tombol Broadcast WhatsApp ke Ibu-Ibu Balita -->
                    <button
                      class="btn-outline"
                      style="font-size: 0.74rem; padding: 5px 10px; color: #16a34a; border-color: #86efac; background: #f0fdf4; display: inline-flex; align-items: center; gap: 5px; font-weight: 700;"
                      title="Siarkan informasi jadwal atau libur ke WhatsApp Grup Posyandu"
                      @click="broadcastPosyanduWhatsApp(activity)"
                    >
                      <Send size="13" />
                      <span>Broadcast WA Ibu Balita</span>
                    </button>

                    <!-- 3. Edit Jadwal -->
                    <button
                      class="btn-outline"
                      style="font-size: 0.74rem; padding: 5px 8px; color: #0284c7; border-color: #bae6fd;"
                      @click="openEditPosyanduModal(activity)"
                    >
                      <span>Edit</span>
                    </button>

                    <!-- 4. Hapus Jadwal -->
                    <button
                      class="btn-outline"
                      style="font-size: 0.74rem; padding: 5px 8px; color: #dc2626; border-color: #fecaca;"
                      @click="deletePosyanduActivity(activity.id)"
                    >
                      <Trash2 size="13" />
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- CARD 2: CATATAN TUMBUH KEMBANG BALITA -->
            <div class="card">
              <div class="card-header" style="flex-wrap: wrap; gap: 10px;">
                <h3 class="card-title">
                  <Baby size="18" style="color: #0284c7;" />
                  Catatan Tumbuh Kembang Balita
                </h3>
                <button
                  class="btn-primary"
                  style="font-size: 0.78rem; padding: 6px 14px; background: #0284c7;"
                  @click="showAddChildModal = true"
                >
                  <Plus size="14" />
                  <span>Catat Data Balita</span>
                </button>
              </div>

              <div class="card-body" style="padding: 16px;">
                <div v-if="!posyanduData.children || posyanduData.children.length === 0" style="text-align: center; padding: 30px; color: #94a3b8;">
                  Belum ada catatan tumbuh kembang balita. Silakan klik "Catat Data Balita".
                </div>

                <div
                  v-for="child in posyanduData.children"
                  :key="child.id"
                  style="padding: 14px; border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 12px; background: white;"
                >
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <strong style="color: #0f172a; font-size: 0.95rem;">
                      {{ child.child_name }} ({{ child.gender === 'L' ? 'Laki-laki' : 'Perempuan' }})
                    </strong>
                    <span class="badge badge-info" style="font-size: 0.72rem;">Lahir: {{ child.birth_date }}</span>
                  </div>

                  <div style="display: flex; gap: 14px; margin-top: 8px; font-size: 0.82rem; color: #334155; flex-wrap: wrap;">
                    <div style="background: #f8fafc; padding: 4px 8px; border-radius: 6px; border: 1px solid #e2e8f0;">
                      ⚖️ Berat: <strong>{{ child.weight_kg }} kg</strong>
                    </div>
                    <div style="background: #f8fafc; padding: 4px 8px; border-radius: 6px; border: 1px solid #e2e8f0;">
                      📏 Tinggi: <strong>{{ child.height_cm }} cm</strong>
                    </div>
                    <div style="background: #f8fafc; padding: 4px 8px; border-radius: 6px; border: 1px solid #e2e8f0;">
                      🧠 Lingkar: <strong>{{ child.head_circumference_cm || '-' }} cm</strong>
                    </div>
                  </div>

                  <div style="font-size: 0.78rem; color: #16a34a; font-weight: 700; margin-top: 8px;">
                    💉 Imunisasi: {{ child.immunization_type || 'Lengkap sesuai usia' }}
                  </div>
                  <div style="font-size: 0.75rem; color: #64748b; margin-top: 3px;">
                    Catatan kader: {{ child.cadre_notes || 'Tumbuh kembang baik & aktif.' }}
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
              <div class="surat-cards-grid">
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

                  <!-- Broadcast WA Pengingat Jatuh Tempo -->
                  <button
                    class="btn-outline"
                    style="font-size: 0.78rem; padding: 6px 12px; color: #16a34a; border-color: #86efac; background: #f0fdf4; display: inline-flex; align-items: center; gap: 6px; font-weight: 700;"
                    title="Kirim pengingat jatuh tempo kas ke WhatsApp Grup RT"
                    @click="broadcastDueReminderToGroup"
                  >
                    <Send size="13" />
                    <span>Broadcast WA Jatuh Tempo</span>
                  </button>

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
                        <div style="font-size: 0.73rem; color: #64748b; margin-top: 2px;">
                          NIK: {{ b.citizen_nik || b.nik || '-' }} • RT {{ b.citizen_rt || '001' }}/RW {{ b.citizen_rw || '005' }}
                        </div>
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
                        <div v-if="b.proof_image_url">
                          <button
                            class="btn-outline"
                            style="font-size: 0.74rem; padding: 4px 10px; display: inline-flex; align-items: center; gap: 5px; color: #0284c7; border-color: #bae6fd; background: #f0f9ff; border-radius: 8px; font-weight: 700;"
                            @click="openProofPreview(b.proof_image_url)"
                            title="Buka lampiran bukti transfer"
                          >
                            <Eye size="13" />
                            <span>Lihat Bukti</span>
                          </button>
                        </div>
                        <span v-else style="color: #94a3b8; font-size: 0.75rem; font-style: italic;">Belum Unggah</span>
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
                            :href="`${API_BASE}/receipts/${b.receipt_number}/print?autoprint=1`"
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
                            :href="`${API_BASE}/receipts/${b.receipt_number}/print?autoprint=1`"
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
            <div class="linmas-cards-grid" style="margin-bottom: 20px;">
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


        <!-- 9. TAB: CCTV MONITORING (KHUSUS ADMIN, STAFF & LINMAS) -->
        <div v-if="currentTab === 'cctv'">
          <!-- Header Command Banner -->
          <div class="card" style="margin-bottom: 20px; background: linear-gradient(135deg, #090d16 0%, #1e1b4b 50%, #064e3b 100%); color: white; border: none; box-shadow: 0 10px 25px -5px rgba(2, 6, 23, 0.5);">
            <div class="card-body" style="padding: 24px;">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
                <div>
                  <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
                    <span style="display: inline-flex; align-items: center; gap: 6px; background: rgba(22, 163, 74, 0.25); border: 1px solid #16a34a; color: #4ade80; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 800; letter-spacing: 0.5px;">
                      <span style="width: 8px; height: 8px; border-radius: 50%; background: #4ade80; display: inline-block; animation: pulse 1.5s infinite;"></span>
                      PUSAT KENDALI CCTV
                    </span>
                    <span style="background: rgba(234, 88, 12, 0.25); border: 1px solid #ea580c; color: #fb923c; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 700;">
                      🔒 Khusus Admin & Staff
                    </span>
                  </div>
                  <h2 style="font-size: 1.5rem; font-weight: 900; margin: 0 0 6px 0; color: #ffffff;">
                    Pemantauan CCTV Lingkungan RT 001 / RW 005
                  </h2>
                  <p style="margin: 0; color: #cbd5e1; font-size: 0.88rem; max-width: 650px; line-height: 1.5;">
                    Sistem pengawasan keamanan live stream 24 jam di titik rawan lingkungan. Dilengkapi perekam insiden, snapshot bukti digital, dan mode TV Pos Ronda.
                  </p>
                </div>

                <!-- Right Action Buttons -->
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                  <button
                    class="btn-primary"
                    style="background: #16a34a; border: none; font-size: 0.82rem; padding: 10px 16px; font-weight: 700; display: flex; align-items: center; gap: 6px;"
                    @click="toggleFullscreenCctv"
                  >
                    📺 Mode TV Pos Ronda (Fullscreen)
                  </button>
                  <button
                    class="btn-outline"
                    style="background: rgba(255, 255, 255, 0.15); color: #ffffff; border-color: rgba(255, 255, 255, 0.35); font-size: 0.82rem; padding: 10px 16px; font-weight: 700; display: flex; align-items: center; gap: 6px;"
                    @click="fetchCctvData"
                  >
                    <RefreshCw size="14" /> Segarkan Feed
                  </button>
                </div>
              </div>

              <!-- Real-time Stats Chips -->
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-top: 20px;">
                <div style="background: rgba(255, 255, 255, 0.08); padding: 12px 16px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.1);">
                  <div style="font-size: 0.72rem; color: #94a3b8; font-weight: 700; text-transform: uppercase;">Total Kamera IP</div>
                  <div style="font-size: 1.35rem; font-weight: 900; color: #ffffff; margin-top: 2px;">{{ cctvSummary.total_cameras || 4 }} Titik</div>
                </div>
                <div style="background: rgba(22, 163, 74, 0.15); padding: 12px 16px; border-radius: 12px; border: 1px solid rgba(74, 222, 128, 0.3);">
                  <div style="font-size: 0.72rem; color: #86efac; font-weight: 700; text-transform: uppercase;">Kamera Online (Aktif)</div>
                  <div style="font-size: 1.35rem; font-weight: 900; color: #4ade80; margin-top: 2px;">{{ cctvSummary.online_cameras || 4 }} Kamera (30 FPS)</div>
                </div>
                <div style="background: rgba(239, 68, 68, 0.15); padding: 12px 16px; border-radius: 12px; border: 1px solid rgba(248, 113, 113, 0.3);">
                  <div style="font-size: 0.72rem; color: #fca5a5; font-weight: 700; text-transform: uppercase;">Kamera Offline (Mati)</div>
                  <div style="font-size: 1.35rem; font-weight: 900; color: #ef4444; margin-top: 2px;">{{ cctvSummary.offline_cameras || 0 }} Kamera</div>
                </div>
                <div style="background: rgba(255, 255, 255, 0.08); padding: 12px 16px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.1);">
                  <div style="font-size: 0.72rem; color: #94a3b8; font-weight: 700; text-transform: uppercase;">Kondisi Jaringan RTSP</div>
                  <div style="font-size: 1rem; font-weight: 800; color: #38bdf8; margin-top: 5px;">{{ cctvSummary.system_status || 'Optimal' }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Filter Lokasi Kamera -->
          <div style="display: flex; gap: 8px; margin-bottom: 18px; flex-wrap: wrap; align-items: center;">
            <span style="font-size: 0.8rem; font-weight: 800; color: #64748b; margin-right: 4px;">Pilih Lokasi:</span>
            <button
              class="btn-outline"
              :style="{ background: cctvFilter === 'all' ? '#0f172a' : '#ffffff', color: cctvFilter === 'all' ? '#ffffff' : '#334155', borderColor: '#cbd5e1', fontSize: '0.78rem', padding: '6px 12px' }"
              @click="cctvFilter = 'all'"
            >
              Semua Titik ({{ cctvCameras.length }})
            </button>
            <button
              class="btn-outline"
              :style="{ background: cctvFilter === 'Gerbang' ? '#0f172a' : '#ffffff', color: cctvFilter === 'Gerbang' ? '#ffffff' : '#334155', borderColor: '#cbd5e1', fontSize: '0.78rem', padding: '6px 12px' }"
              @click="cctvFilter = 'Gerbang'"
            >
              🚪 Portal Gerbang Utama
            </button>
            <button
              class="btn-outline"
              :style="{ background: cctvFilter === 'Pos' ? '#0f172a' : '#ffffff', color: cctvFilter === 'Pos' ? '#ffffff' : '#334155', borderColor: '#cbd5e1', fontSize: '0.78rem', padding: '6px 12px' }"
              @click="cctvFilter = 'Pos'"
            >
              👮 Pos Ronda & Balai
            </button>
            <button
              class="btn-outline"
              :style="{ background: cctvFilter === 'Taman' ? '#0f172a' : '#ffffff', color: cctvFilter === 'Taman' ? '#ffffff' : '#334155', borderColor: '#cbd5e1', fontSize: '0.78rem', padding: '6px 12px' }"
              @click="cctvFilter = 'Taman'"
            >
              🌳 Simpang Blok B & Taman
            </button>
            <button
              class="btn-outline"
              :style="{ background: cctvFilter === 'TPS' ? '#0f172a' : '#ffffff', color: cctvFilter === 'TPS' ? '#ffffff' : '#334155', borderColor: '#cbd5e1', fontSize: '0.78rem', padding: '6px 12px' }"
              @click="cctvFilter = 'TPS'"
            >
              ♻️ Jalur Barat & TPS
            </button>
          </div>

          <!-- 2x2 MULTI-CAMERA STREAM GRID -->
          <div
            id="cctv-grid-container"
            class="cctv-panel-container"
          >
            <div class="cctv-cameras-grid">
              <div
                v-for="cam in filteredCctvCameras"
                :key="cam.id"
                class="cctv-camera-card"
              >
                <!-- Camera Header Overlay -->
                <div style="background: rgba(15, 23, 42, 0.9); padding: 10px 14px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.08);">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span
                      :style="{
                        width: '9px',
                        height: '9px',
                        borderRadius: '50%',
                        background: cam.status === 'online' ? '#22c55e' : '#ef4444',
                        display: 'inline-block',
                        boxShadow: cam.status === 'online' ? '0 0 8px #22c55e' : 'none'
                      }"
                    ></span>
                    <span style="font-weight: 800; color: #f8fafc; font-size: 0.85rem;">{{ cam.name }}</span>
                  </div>
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="background: rgba(255,255,255,0.1); color: #cbd5e1; font-size: 0.7rem; padding: 2px 8px; border-radius: 6px; font-weight: 600;">
                      {{ cam.resolution }}
                    </span>
                    <span style="color: #4ade80; font-size: 0.7rem; font-weight: 700; font-family: monospace;">
                      {{ cam.status === 'online' ? `${cam.fps} FPS` : 'OFFLINE' }}
                    </span>
                  </div>
                </div>

                <!-- Video Player Feed -->
                <div class="cctv-video-wrap">
                  <video
                    v-if="cam.status === 'online'"
                    :src="cam.stream_url"
                    :poster="cam.preview_image"
                    autoplay
                    muted
                    loop
                    playsinline
                    style="width: 100%; height: 100%; object-fit: cover;"
                  ></video>

                  <!-- Offline Overlay -->
                  <div
                    v-else
                    style="width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #0f172a; color: #ef4444;"
                  >
                    <AlertTriangle size="36" />
                    <span style="font-weight: 800; font-size: 0.9rem; margin-top: 8px; color: #f87171;">SINYAL CCTV TERPUTUS</span>
                    <span style="font-size: 0.75rem; color: #94a3b8; margin-top: 2px;">Periksa kabel LAN atau daya listrik di {{ cam.location }}</span>
                  </div>

                  <!-- Live Timestamp Watermark -->
                  <div style="position: absolute; top: 10px; right: 12px; background: rgba(0,0,0,0.65); padding: 3px 8px; border-radius: 4px; color: #ffffff; font-family: monospace; font-size: 0.72rem; letter-spacing: 0.5px;">
                    ● REC • {{ liveCctvClock }} WIB
                  </div>

                  <!-- Camera IP & Location Watermark -->
                  <div style="position: absolute; bottom: 10px; left: 12px; background: rgba(0,0,0,0.65); padding: 3px 8px; border-radius: 4px; color: #cbd5e1; font-size: 0.7rem;">
                    {{ cam.location }} • IP: {{ cam.ip_address }}:{{ cam.port }}
                  </div>
                </div>

                <!-- Bottom Controls & Action Bar -->
                <div class="cctv-card-footer">
                  <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                    <button
                      class="btn-primary"
                      style="font-size: 0.75rem; padding: 5px 10px; background: #0284c7; border: none; font-weight: 700; display: flex; align-items: center; gap: 5px;"
                      @click="openSnapshotModal(cam)"
                      title="Ambil tangkapan layar dan simpan sebagai bukti insiden keamanan"
                    >
                      <Camera size="13" /> Ambil Snapshot
                    </button>
                    <button
                      class="btn-outline"
                      style="font-size: 0.72rem; padding: 4px 8px; border-color: rgba(255,255,255,0.2); color: #94a3b8;"
                      @click="toggleCctvStatus(cam)"
                      :title="cam.status === 'online' ? 'Uji coba matikan kamera (simulasi)' : 'Nyalakan kembali kamera'"
                    >
                      {{ cam.status === 'online' ? 'Matikan' : 'Aktifkan' }}
                    </button>
                  </div>

                  <!-- PTZ Badge if available -->
                  <div v-if="cam.has_ptz" style="display: flex; align-items: center; gap: 4px; color: #fbbf24; font-size: 0.72rem; font-weight: 700;">
                    <span>🎮 PTZ 360° Aktif</span>
                  </div>
                  <div v-else style="color: #64748b; font-size: 0.72rem;">
                    Fix Angle • {{ cam.model }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Section 2: Inventaris Kamera & Riwayat Bukti Insiden -->
          <div class="cctv-info-grid">
            <!-- Tabel Perangkat Hardware CCTV -->
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">📡 Data Teknis Kamera & Jaringan RTSP</h3>
                <span class="badge badge-success">4 Kamera Terdaftar</span>
              </div>
              <div class="card-body" style="padding: 0;">
                <table class="table" style="font-size: 0.8rem;">
                  <thead>
                    <tr>
                      <th>Kamera & Merk</th>
                      <th>IP Lokal & Port</th>
                      <th>Resolusi / FPS</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="cam in cctvCameras" :key="cam.id">
                      <td>
                        <strong>{{ cam.name }}</strong>
                        <div style="font-size: 0.72rem; color: #64748b;">{{ cam.model }}</div>
                      </td>
                      <td style="font-family: monospace;">{{ cam.ip_address }}:{{ cam.port }}</td>
                      <td>{{ cam.resolution }} • {{ cam.fps }}fps</td>
                      <td>
                        <span :class="cam.status === 'online' ? 'badge badge-success' : 'badge badge-danger'">
                          {{ cam.status.toUpperCase() }}
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Log Insiden & Tangkapan Layar CCTV -->
            <div class="card">
              <div class="card-header">
                <h3 class="card-title">📸 Log Tangkapan Layar & Insiden Keamanan</h3>
                <span class="badge badge-warning">{{ cctvIncidents.length }} Insiden Tercatat</span>
              </div>
              <div class="card-body" style="padding: 16px; max-height: 380px; overflow-y: auto;">
                <div v-if="cctvIncidents.length === 0" style="text-align: center; color: #94a3b8; padding: 20px 0; font-size: 0.85rem;">
                  Belum ada laporan insiden CCTV.
                </div>
                <div
                  v-for="inc in cctvIncidents"
                  :key="inc.id"
                  style="display: flex; gap: 12px; margin-bottom: 14px; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9; align-items: flex-start;"
                >
                  <img
                    :src="inc.snapshot_url"
                    alt="Bukti CCTV"
                    style="width: 70px; height: 50px; object-fit: cover; border-radius: 6px; border: 1px solid #cbd5e1;"
                  />
                  <div style="flex: 1;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                      <h4 style="font-size: 0.82rem; font-weight: 800; margin: 0; color: #0f172a;">{{ inc.title }}</h4>
                      <span class="badge badge-warning" style="font-size: 0.65rem;">{{ inc.severity.toUpperCase() }}</span>
                    </div>
                    <div style="font-size: 0.75rem; color: #475569; margin: 3px 0;">{{ inc.description }}</div>
                    <div style="font-size: 0.7rem; color: #94a3b8;">
                      {{ inc.camera_name }} • Pelapor: {{ inc.reporter_name }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- MODAL: AMBIL SNAPSHOT & CATAT BUKTI CCTV -->
        <div v-if="showSnapshotModal" class="modal-overlay">
          <div class="modal-content">
            <div class="modal-header">
              <h3 class="modal-title">📸 Simpan Bukti Tangkapan Layar CCTV</h3>
              <button class="btn-close" @click="showSnapshotModal = false">×</button>
            </div>
            <div class="modal-body">
              <div style="margin-bottom: 16px; border-radius: 8px; overflow: hidden; border: 1px solid #cbd5e1;">
                <img
                  :src="selectedCctvForSnapshot?.preview_image"
                  alt="Snapshot Preview"
                  style="width: 100%; height: 180px; object-fit: cover;"
                />
                <div style="padding: 8px 12px; background: #f8fafc; font-size: 0.75rem; color: #475569;">
                  <strong>{{ selectedCctvForSnapshot?.name }}</strong> ({{ selectedCctvForSnapshot?.location }})
                </div>
              </div>

              <div class="form-group">
                <label class="form-label">Judul Insiden / Aktivitas</label>
                <input v-model="snapshotForm.title" type="text" class="form-control" placeholder="Contoh: Tamu Masuk Malam Hari Tanpa Izin" />
              </div>

              <div class="form-group">
                <label class="form-label">Tingkat Perhatian (Severity)</label>
                <select v-model="snapshotForm.severity" class="form-control">
                  <option value="rendah">Rendah (Pencatatan Rutin)</option>
                  <option value="sedang">Sedang (Perlu Perhatian)</option>
                  <option value="tinggi">Tinggi (Mencurigakan)</option>
                  <option value="darurat">Darurat (Tindakan Cepat)</option>
                </select>
              </div>

              <div class="form-group">
                <label class="form-label">Keterangan / Kronologi Singkat</label>
                <textarea v-model="snapshotForm.description" class="form-control" rows="3" placeholder="Tuliskan plat nomor, ciri-ciri, atau arahan petugas..."></textarea>
              </div>
            </div>
            <div class="modal-footer">
              <button class="btn-outline" @click="showSnapshotModal = false">Batal</button>
              <button class="btn-primary" style="background: #0284c7; border: none;" @click="saveCctvSnapshot">
                Simpan ke Buku Insiden
              </button>
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
              <div class="news-cards-grid">
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
                    <button
                      class="btn-outline"
                      style="margin-top: 10px; padding: 6px 12px; font-size: 0.76rem; color: #16a34a; border-color: #86efac; background: #f0fdf4; display: inline-flex; align-items: center; gap: 6px; width: 100%; justify-content: center; font-weight: 700;"
                      title="Bagikan kabar pengumuman ini ke Grup WhatsApp Warga"
                      @click="broadcastNewsWhatsApp(item)"
                    >
                      <Send size="13" />
                      <span>Broadcast ke WhatsApp Grup Warga</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>

    <!-- Dedicated Mobile Bottom Navigation Bar (Khusus Tampilan HP) -->
    <nav class="mobile-bottom-nav">
      <button
        class="mobile-bottom-item"
        :class="{ active: currentTab === 'dashboard' }"
        @click="selectTab('dashboard')"
      >
        <div class="bottom-icon-wrap">
          <LayoutDashboard size="20" />
        </div>
        <span>Beranda</span>
      </button>

      <button
        class="mobile-bottom-item"
        :class="{ active: currentTab === 'citizens' }"
        @click="selectTab('citizens')"
      >
        <div class="bottom-icon-wrap">
          <Users size="20" />
        </div>
        <span>Warga</span>
      </button>

      <button
        class="mobile-bottom-item"
        :class="{ active: currentTab === 'letters' }"
        @click="selectTab('letters')"
      >
        <div class="bottom-icon-wrap">
          <FileText size="20" />
        </div>
        <span>Surat</span>
      </button>

      <button
        class="mobile-bottom-item"
        :class="{ active: currentTab === 'treasury' }"
        @click="selectTab('treasury')"
      >
        <div class="bottom-icon-wrap">
          <Wallet size="20" />
        </div>
        <span>Kas RT</span>
      </button>

      <button
        class="mobile-bottom-item"
        @click="mobileNavOpen = true"
      >
        <div class="bottom-icon-wrap">
          <Menu size="20" />
        </div>
        <span>Menu</span>
      </button>
    </nav>

    <!-- MODAL: ABSENSI LINMAS DI TEMPAT (GPS POS RONDA) -->
    <div v-if="showLinmasCheckInModal" class="modal-overlay" @click.self="showLinmasCheckInModal = false">
      <div class="modal-content" style="max-width: 480px;">
        <div class="modal-header">
          <h3 class="modal-title">📍 Absen Masuk Linmas di Tempat (Pos Ronda)</h3>
          <button class="btn-close" @click="showLinmasCheckInModal = false">×</button>
        </div>
        <div class="modal-body">
          <div style="padding: 12px; background: #f0fdf4; border: 1px solid #86efac; border-radius: 10px; margin-bottom: 14px;">
            <div style="display: flex; align-items: center; gap: 8px; color: #166534; font-weight: 700; font-size: 0.85rem;">
              <MapPin size="16" />
              <span>Lokasi Terkunci: Pos Ronda Utama RT 001 (Di Tempat)</span>
            </div>
            <div style="font-size: 0.75rem; color: #64748b; margin-top: 3px;">
              Koordinat GPS: -6.2088, 106.8456 • Radius: 8 meter (Valid)
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Nama Petugas Linmas</label>
            <input v-model="linmasCheckInForm.officer_name" type="text" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Shift Jaga</label>
            <select v-model="linmasCheckInForm.shift" class="form-control">
              <option value="Piket Malam (20:00 - 04:00)">Piket Malam (20:00 - 04:00)</option>
              <option value="Piket Siang (08:00 - 16:00)">Piket Siang (08:00 - 16:00)</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Status Awal Pos Ronda</label>
            <select v-model="linmasCheckInForm.situation_status" class="form-control">
              <option value="Aman & Kondusif">🟢 Aman & Kondusif</option>
              <option value="Waspada / Perlu Perhatian">🟡 Waspada / Perlu Perhatian</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Catatan Situasi Awal</label>
            <textarea v-model="linmasCheckInForm.notes" class="form-control" rows="2"></textarea>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 18px;">
            <button class="btn-secondary" @click="showLinmasCheckInModal = false">Batal</button>
            <button class="btn-primary" style="background: #10b981;" @click="submitLinmasCheckIn">
              Kirim Absen di Tempat
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL: KIRIM UPDATE SITUASI KEAMANAN POS RONDA -->
    <div v-if="showLinmasSituationModal" class="modal-overlay" @click.self="showLinmasSituationModal = false">
      <div class="modal-content" style="max-width: 480px;">
        <div class="modal-header">
          <h3 class="modal-title">📝 Tulis Update Situasi Pos Ronda Hari Ini</h3>
          <button class="btn-close" @click="showLinmasSituationModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Nama Petugas Linmas</label>
            <input v-model="linmasSituationForm.officer_name" type="text" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Titik Pos Pantau</label>
            <input v-model="linmasSituationForm.post_name" type="text" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Status Keamanan Saat Ini</label>
            <select v-model="linmasSituationForm.status" class="form-control">
              <option value="aman">🟢 Aman & Kondusif</option>
              <option value="waspada">🟡 Perlu Perhatian / Waspada</option>
              <option value="insiden">🔴 Insiden / Laporan Kejadian</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Rincian Situasi Lingkungan *</label>
            <textarea
              v-model="linmasSituationForm.details"
              class="form-control"
              rows="3"
              placeholder="Contoh: Portal gerbang barat telah dikunci. Patroli putaran pertama blok B selesai, situasi aman."
            ></textarea>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 18px;">
            <button class="btn-secondary" @click="showLinmasSituationModal = false">Batal</button>
            <button class="btn-primary" style="background: #0284c7;" @click="submitLinmasSituation">
              Kirim Laporan Situasi
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL: BUAT / EDIT JADWAL POSYANDU -->
    <div v-if="showPosyanduModal" class="modal-overlay" @click.self="showPosyanduModal = false">
      <div class="modal-content" style="max-width: 520px;">
        <div class="modal-header">
          <h3 class="modal-title" style="display: flex; align-items: center; gap: 8px;">
            <HeartPulse size="18" style="color: #ec4899;" />
            <span>{{ isEditingPosyandu ? 'Edit Jadwal Posyandu' : 'Jadwalkan Kegiatan Posyandu Baru' }}</span>
          </h3>
          <button class="btn-close" @click="showPosyanduModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Nama Kegiatan Posyandu</label>
            <input v-model="posyanduForm.title" type="text" class="form-control" placeholder="Contoh: Posyandu Melati Berkala - November 2026" />
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <div class="form-group">
              <label class="form-label">Tanggal Pelaksanaan</label>
              <input v-model="posyanduForm.activity_date" type="date" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">Lokasi Posyandu</label>
              <input v-model="posyanduForm.location" type="text" class="form-control" placeholder="Balai RW 005 / Pos RT 01" />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Nama Bidan / Kader Penanggung Jawab</label>
            <input v-model="posyanduForm.cadre_name" type="text" class="form-control" placeholder="Bidan Dewi Lestari / Kader Melati" />
          </div>

          <div class="form-group">
            <label class="form-label">Rincian Layanan / Pengumuman untuk Ibu Balita</label>
            <textarea
              v-model="posyanduForm.description"
              class="form-control"
              rows="3"
              placeholder="Contoh: Penimbangan balita, pembagian vitamin A, imunisasi Polio/DPT, dan pemeriksaan tensi ibu hamil. Mohon membawa buku KIA."
            ></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showPosyanduModal = false">Batal</button>
          <button class="btn-primary" style="background: #ec4899;" @click="savePosyanduActivity">
            {{ isEditingPosyandu ? 'Simpan Perubahan' : 'Terbitkan Jadwal Posyandu' }}
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL: LIBUR MENDADAK / PENUNDAAN JADWAL POSYANDU -->
    <div v-if="showPostponeModal && selectedPosyanduToPostpone" class="modal-overlay" @click.self="showPostponeModal = false">
      <div class="modal-content" style="max-width: 520px;">
        <div class="modal-header">
          <h3 class="modal-title" style="display: flex; align-items: center; gap: 8px; color: #b45309;">
            <AlertTriangle size="20" style="color: #d97706;" />
            <span>Maklumat Libur Mendadak / Penundaan</span>
          </h3>
          <button class="btn-close" @click="showPostponeModal = false">×</button>
        </div>
        <div class="modal-body">
          <div style="padding: 12px; background: #fffbeb; border: 1px solid #fef08a; border-radius: 10px; margin-bottom: 16px; font-size: 0.85rem; color: #92400e;">
            <strong>Kegiatan:</strong> {{ selectedPosyanduToPostpone.title }}<br />
            <strong>Jadwal Semula:</strong> {{ formatDate(selectedPosyanduToPostpone.activity_date) }} • {{ selectedPosyanduToPostpone.location }}
          </div>

          <div class="form-group">
            <label class="form-label">Alasan Libur Mendadak / Penundaan</label>
            <textarea
              v-model="postponeForm.reason"
              class="form-control"
              rows="3"
              placeholder="Contoh: Bidan Dewi berhalangan hadir karena dinas luar kota mendadak / Renovasi Balai RW / Libur Nasional."
            ></textarea>
          </div>

          <div class="form-group">
            <label class="form-label">Tanggal Pengganti (Opsional jika sudah ditentukan)</label>
            <input v-model="postponeForm.rescheduled_date" type="date" class="form-control" />
            <div style="font-size: 0.74rem; color: #64748b; margin-top: 4px;">
              *Kosongkan jika jadwal pengganti belum diputuskan (akan diumumkan kemudian).
            </div>
          </div>

          <div style="padding: 10px 14px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; font-size: 0.8rem; color: #166534;">
            ✓ Sistem otomatis menerbitkan pengumuman darurat di <strong>Kabar Kampung</strong> dan menyiapkan teks siaran WhatsApp untuk grup ibu balita.
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: space-between;">
          <button class="btn-outline" @click="showPostponeModal = false">Batal</button>
          <button class="btn-primary" style="background: #d97706; border: none; font-weight: 700;" @click="submitPostponePosyandu">
            <AlertTriangle size="14" />
            <span>Tetapkan Libur Mendadak & Broadcast WA</span>
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL: CATAT DATA TUMBUH KEMBANG BALITA BARU -->
    <div v-if="showAddChildModal" class="modal-overlay" @click.self="showAddChildModal = false">
      <div class="modal-content" style="max-width: 500px;">
        <div class="modal-header">
          <h3 class="modal-title" style="display: flex; align-items: center; gap: 8px;">
            <Baby size="18" style="color: #0284c7;" />
            <span>Catat Pengukuran Balita</span>
          </h3>
          <button class="btn-close" @click="showAddChildModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Nama Balita</label>
            <input v-model="childForm.child_name" type="text" class="form-control" placeholder="Nama lengkap balita" />
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <div class="form-group">
              <label class="form-label">Jenis Kelamin</label>
              <select v-model="childForm.gender" class="form-control">
                <option value="L">Laki-laki (L)</option>
                <option value="P">Perempuan (P)</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Tanggal Lahir</label>
              <input v-model="childForm.birth_date" type="date" class="form-control" />
            </div>
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px;">
            <div class="form-group">
              <label class="form-label">Berat (kg)</label>
              <input v-model="childForm.weight_kg" type="number" step="0.1" class="form-control" placeholder="12.5" />
            </div>
            <div class="form-group">
              <label class="form-label">Tinggi (cm)</label>
              <input v-model="childForm.height_cm" type="number" step="0.5" class="form-control" placeholder="88.0" />
            </div>
            <div class="form-group">
              <label class="form-label">Lingkar (cm)</label>
              <input v-model="childForm.head_circumference_cm" type="number" step="0.5" class="form-control" placeholder="47.0" />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Jenis Imunisasi Diberikan</label>
            <input v-model="childForm.immunization_type" type="text" class="form-control" placeholder="Contoh: Vitamin A, Polio 4, DPT-HB-Hib 3" />
          </div>

          <div class="form-group">
            <label class="form-label">Catatan Kader</label>
            <input v-model="childForm.cadre_notes" type="text" class="form-control" placeholder="Contoh: Pertumbuhan sangat baik, nafsu makan aktif" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-outline" @click="showAddChildModal = false">Batal</button>
          <button class="btn-primary" style="background: #0284c7;" @click="saveChildRecord">Simpan Data Balita</button>
        </div>
      </div>
    </div>

    <!-- MODAL: DETAIL DATA WARGA -->
    <div v-if="showCitizenDetailModal && selectedCitizenDetail" class="modal-overlay" @click.self="showCitizenDetailModal = false">
      <div class="modal-content" style="max-width: 500px;">
        <div class="modal-header">
          <h3 class="modal-title" style="display: flex; align-items: center; gap: 8px;">
            <User size="18" style="color: #16a34a;" />
            <span>Detail Identitas Warga</span>
          </h3>
          <button class="btn-close" @click="showCitizenDetailModal = false">×</button>
        </div>
        <div class="modal-body">
          <div style="text-align: center; padding: 16px 0; border-bottom: 1px solid #f1f5f9; margin-bottom: 16px;">
            <div style="width: 56px; height: 56px; border-radius: 50%; background: #dcfce7; color: #15803d; font-size: 1.4rem; font-weight: 800; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 8px;">
              {{ selectedCitizenDetail.name ? selectedCitizenDetail.name.charAt(0) : 'W' }}
            </div>
            <h3 style="font-size: 1.15rem; font-weight: 800; color: #0f172a; margin: 0;">{{ selectedCitizenDetail.name }}</h3>
            <span class="badge badge-success" style="margin-top: 6px;">{{ selectedCitizenDetail.role?.toUpperCase() || 'WARGA' }} TERDAFTAR</span>
          </div>

          <div style="display: flex; flex-direction: column; gap: 12px; font-size: 0.88rem;">
            <div style="display: flex; justify-content: space-between; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
              <span style="color: #64748b;">NIK (KTP):</span>
              <strong style="font-family: monospace; color: #0f172a;">{{ selectedCitizenDetail.nik }}</strong>
            </div>
            <div style="display: flex; justify-content: space-between; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
              <span style="color: #64748b;">Nomor WhatsApp:</span>
              <strong style="color: #16a34a;">{{ selectedCitizenDetail.phone || '-' }}</strong>
            </div>
            <div style="display: flex; justify-content: space-between; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
              <span style="color: #64748b;">Wilayah:</span>
              <strong style="color: #0f172a;">RT {{ selectedCitizenDetail.rt || '001' }} / RW {{ selectedCitizenDetail.rw || '005' }}</strong>
            </div>
            <div style="display: flex; justify-content: space-between; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
              <span style="color: #64748b;">Pekerjaan:</span>
              <strong style="color: #0f172a;">{{ selectedCitizenDetail.occupation || '-' }}</strong>
            </div>
            <div style="display: flex; justify-content: space-between; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
              <span style="color: #64748b;">Alamat Rumah:</span>
              <span style="color: #0f172a; text-align: right; max-width: 250px;">{{ selectedCitizenDetail.address || '-' }}</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding-top: 4px;">
              <span style="color: #64748b;">Status Verifikasi:</span>
              <span class="badge badge-success">Terverifikasi Sah</span>
            </div>
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: space-between;">
          <a
            v-if="selectedCitizenDetail.phone"
            :href="`https://wa.me/${selectedCitizenDetail.phone.replace(/^0/, '62')}`"
            target="_blank"
            class="btn-primary"
            style="background: #16a34a; text-decoration: none; font-size: 0.8rem;"
          >
            <Send size="14" /> Kirim Pesan WA
          </a>
          <button class="btn-outline" @click="showCitizenDetailModal = false">Tutup</button>
        </div>
      </div>
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

// Linmas Presensi di Tempat & Situasi Keamanan State
const linmasAttendances = ref([]);
const linmasSubTab = ref('situation'); // 'situation' | 'attendance'
const linmasSituationLogs = ref([
  {
    id: 1,
    officer_name: 'Sujatmo (Komandan Linmas)',
    post_name: 'Pos Pantau Utama RT 001',
    status: 'aman',
    details: 'Pintu portal barat telah dikunci pada pukul 23:00 WIB. Lampu jalan blok A & B menyala terang, situasi aman terkendali.',
    time: '23:15 WIB',
    verified_by: 'Bambang Sudarmono (Ketua RT 001)',
  },
  {
    id: 2,
    officer_name: 'Dedi Iskandar (Anggota Linmas)',
    post_name: 'Pos Gerbang Barat',
    status: 'aman',
    details: 'Patroli putaran pertama jam 01:00 WIB selesai. Menegur sekelompok remaja yang nongkrong larut malam agar segera pulang dengan tertib.',
    time: '01:20 WIB',
    verified_by: 'Bambang Sudarmono (Ketua RT 001)',
  },
]);
const showLinmasCheckInModal = ref(false);
const linmasCheckInForm = ref({
  officer_name: '',
  shift: 'Piket Malam (20:00 - 04:00)',
  post_name: 'Pos Pantau Utama RT 001',
  situation_status: 'Aman & Kondusif',
  notes: '',
});
const showLinmasSituationModal = ref(false);
const linmasSituationForm = ref({
  officer_name: '',
  post_name: 'Pos Pantau Utama RT 001',
  status: 'aman',
  details: '',
});

const posyanduData = ref({ activities: [], children: [] });
const complaintsList = ref([]);
const treasuryData = ref({ summary: {}, data: [] });
const duesData = ref({ summary: {}, data: [] });
const duesSubTab = ref('transparency'); // 'bills' | 'ledger'
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

// Navigation items definition (Sesuai Aturan Hak Akses Linmas & Transparansi Kas)
const navItems = computed(() => {
  const isStaffOrAdmin = ['rt', 'rw', 'bendahara', 'sekretaris', 'staff', 'admin', 'linmas'].includes(currentUser.value?.role);

  const items = [
    {
      id: 'dashboard',
      label: 'Dashboard',
      icon: LayoutDashboard,
      iconGradient: 'linear-gradient(135deg, #10B981 0%, #06B6D4 100%)',
      iconShadow: 'rgba(16, 185, 129, 0.45)',
    },
    {
      id: 'citizens',
      label: 'Data Warga',
      icon: Users,
      badge: stats.value.pending_citizens || null,
      iconGradient: 'linear-gradient(135deg, #3B82F6 0%, #6366F1 100%)',
      iconShadow: 'rgba(59, 130, 246, 0.45)',
    },
    {
      id: 'letters',
      label: 'Layanan Surat',
      icon: FileText,
      badge: stats.value.pending_letters || null,
      iconGradient: 'linear-gradient(135deg, #F59E0B 0%, #EA580C 100%)',
      iconShadow: 'rgba(234, 88, 12, 0.45)',
    },
    {
      id: 'treasury',
      label: 'Transparansi Kas',
      icon: Wallet,
      iconGradient: 'linear-gradient(135deg, #22C55E 0%, #15803D 100%)',
      iconShadow: 'rgba(34, 197, 94, 0.45)',
    },
  ];

  // KHUSUS LINMAS, ADMIN, DAN STAFF PENGURUS RT/RW (TIDAK DITAMPILKAN KE WARGA)
  if (isStaffOrAdmin) {
    items.push({
      id: 'patrols',
      label: 'Absen Linmas & Situasi',
      icon: Shield,
      iconGradient: 'linear-gradient(135deg, #14B8A6 0%, #0F766E 100%)',
      iconShadow: 'rgba(20, 184, 166, 0.45)',
    });
    items.push({
      id: 'cctv',
      label: 'CCTV Pos & Jalan',
      icon: Camera,
      badge: '4 LIVE',
      iconGradient: 'linear-gradient(135deg, #F43F5E 0%, #BE123C 100%)',
      iconShadow: 'rgba(244, 63, 94, 0.45)',
    });
  }

  items.push(
    {
      id: 'posyandu',
      label: 'Posyandu',
      icon: HeartPulse,
      iconGradient: 'linear-gradient(135deg, #EC4899 0%, #9D174D 100%)',
      iconShadow: 'rgba(236, 72, 153, 0.45)',
    },
    {
      id: 'complaints',
      label: 'Aduan Warga',
      icon: AlertCircle,
      badge: stats.value.active_complaints || null,
      iconGradient: 'linear-gradient(135deg, #8B5CF6 0%, #6D28D9 100%)',
      iconShadow: 'rgba(139, 92, 246, 0.45)',
    },
    {
      id: 'news',
      label: 'Kabar Kampung',
      icon: Megaphone,
      iconGradient: 'linear-gradient(135deg, #F97316 0%, #C2410C 100%)',
      iconShadow: 'rgba(249, 115, 22, 0.45)',
    }
  );

  return items;
});

const currentTitle = computed(() => {
  const map = {
    dashboard: 'Dashboard',
    citizens: 'Pusat Data & Verifikasi Warga',
    letters: 'Pelayanan Surat & Cetak PDF',
    treasury: 'Keuangan & Transparansi Kas RT Terbuka',
    patrols: 'Presensi Linmas di Tempat & Situasi Keamanan Pos',
    posyandu: 'Kegiatan Posyandu Balita & Lansia',
    complaints: 'Aduan Masalah Lingkungan & TPS',
    cctv: 'Pusat Pemantauan CCTV RT (Khusus Pengurus & Linmas)',
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


// ===========================================================================
// CCTV MONITORING SYSTEM STATE & LOGIC (KHUSUS ADMIN, STAFF & LINMAS)
// ===========================================================================
const cctvCameras = ref([]);
const cctvSummary = ref({ total_cameras: 4, online_cameras: 4, offline_cameras: 0, system_status: 'Optimal (Semua Online)' });
const cctvIncidents = ref([]);
const cctvFilter = ref('all');
const showSnapshotModal = ref(false);
const selectedCctvForSnapshot = ref(null);
const snapshotForm = ref({ title: '', description: '', severity: 'sedang' });
const isCctvFullscreen = ref(false);
const liveCctvClock = ref(new Date().toLocaleTimeString('id-ID'));

setInterval(() => {
  liveCctvClock.value = new Date().toLocaleTimeString('id-ID');
}, 1000);

const filteredCctvCameras = computed(() => {
  if (cctvFilter.value === 'all') return cctvCameras.value;
  return cctvCameras.value.filter(c => c.name.toLowerCase().includes(cctvFilter.value.toLowerCase()) || c.location.toLowerCase().includes(cctvFilter.value.toLowerCase()));
});

async function fetchCctvData() {
  try {
    const role = currentUser.value?.role || 'rt';
    const [cctvRes, incidentsRes] = await Promise.all([
      axios.get(`${API_BASE}/cctv?role=${role}`),
      axios.get(`${API_BASE}/cctv/incidents`),
    ]);
    if (cctvRes.data.success) {
      cctvCameras.value = cctvRes.data.data || [];
      cctvSummary.value = cctvRes.data.summary || {};
    }
    if (incidentsRes.data.success) {
      cctvIncidents.value = incidentsRes.data.data || [];
    }
  } catch (err) {
    console.error('Error loading CCTV:', err);
  }
}

async function toggleCctvStatus(cam) {
  try {
    const res = await axios.post(`${API_BASE}/cctv/${cam.id}/toggle-status`);
    cam.status = res.data.new_status;
    await fetchCctvData();
  } catch (err) {
    alert('Gagal mengubah status CCTV');
  }
}

function openSnapshotModal(cam) {
  selectedCctvForSnapshot.value = cam;
  snapshotForm.value = {
    title: `Aktivitas Terpantau di ${cam.name}`,
    description: `Tangkapan layar pemantauan rutin pukul ${liveCctvClock.value} WIB.`,
    severity: 'sedang',
  };
  showSnapshotModal.value = true;
}

async function saveCctvSnapshot() {
  if (!selectedCctvForSnapshot.value || !snapshotForm.value.title) {
    alert('Harap masukkan judul insiden / catatan!');
    return;
  }
  try {
    const res = await axios.post(`${API_BASE}/cctv/snapshot`, {
      camera_id: selectedCctvForSnapshot.value.id,
      title: snapshotForm.value.title,
      description: snapshotForm.value.description,
      severity: snapshotForm.value.severity,
      reported_by: currentUser.value?.id || 1,
      snapshot_url: selectedCctvForSnapshot.value.preview_image,
    });
    alert('✅ ' + res.data.message);
    showSnapshotModal.value = false;
    await fetchCctvData();
  } catch (err) {
    alert('Gagal menyimpan bukti snapshot CCTV: ' + (err.response?.data?.message || err.message));
  }
}

function toggleFullscreenCctv() {
  const elem = document.getElementById('cctv-grid-container');
  if (!elem) return;
  if (!document.fullscreenElement) {
    elem.requestFullscreen().then(() => { isCctvFullscreen.value = true; }).catch(() => {});
  } else {
    document.exitFullscreen().then(() => { isCctvFullscreen.value = false; }).catch(() => {});
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
    linmasAttendances.value = linmasRes.data.data || [];
    posyanduData.value = posyanduRes.data.data;
    complaintsList.value = complaintsRes.data.data;
    treasuryData.value = treasuryRes.data;
    newsList.value = newsRes.data.data;
    duesData.value = duesRes.data;
    await fetchCctvData();

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

function openAddPosyanduModal() {
  isEditingPosyandu.value = false;
  editingPosyanduId.value = null;
  posyanduForm.value = {
    title: 'Posyandu Melati Berkala - ' + new Date().toLocaleDateString('id-ID', { month: 'long', year: 'numeric' }),
    activity_date: new Date().toISOString().substring(0, 10),
    location: 'Balai RW 005 (Samping Pos Ronda)',
    cadre_name: 'Dewi Lestari (Kader Posyandu Melati)',
    description: 'Penimbangan balita, pengukuran tinggi badan, imunisasi rutin, pembagian vitamin A, dan cek tensi ibu hamil.',
  };
  showPosyanduModal.value = true;
}

function openEditPosyanduModal(activity) {
  isEditingPosyandu.value = true;
  editingPosyanduId.value = activity.id;
  posyanduForm.value = {
    title: activity.title,
    activity_date: activity.activity_date,
    location: activity.location,
    cadre_name: activity.cadre_name || 'Dewi Lestari (Kader Posyandu)',
    description: activity.description,
  };
  showPosyanduModal.value = true;
}

async function savePosyanduActivity() {
  if (!posyanduForm.value.title || !posyanduForm.value.activity_date) {
    alert('Mohon lengkapi judul dan tanggal posyandu.');
    return;
  }
  try {
    if (isEditingPosyandu.value && editingPosyanduId.value) {
      await axios.put(`${API_BASE}/posyandu/activity/${editingPosyanduId.value}`, posyanduForm.value);
      alert('Jadwal Posyandu berhasil diperbarui!');
    } else {
      await axios.post(`${API_BASE}/posyandu/activity`, posyanduForm.value);
      alert('Jadwal Posyandu berhasil dibuat dan dipublikasikan!');
    }
    showPosyanduModal.value = false;
    await refreshData();
  } catch (err) {
    alert('Gagal menyimpan jadwal: ' + (err.response?.data?.message || err.message));
  }
}

function openPostponeModal(activity) {
  selectedPosyanduToPostpone.value = activity;
  postponeForm.value = {
    reason: 'Bidan Dewi berhalangan hadir mendadak dikarenakan tugas dinas luar kota.',
    rescheduled_date: '',
  };
  showPostponeModal.value = true;
}

async function submitPostponePosyandu() {
  if (!selectedPosyanduToPostpone.value) return;
  try {
    const res = await axios.post(`${API_BASE}/posyandu/activity/${selectedPosyanduToPostpone.value.id}/postpone`, postponeForm.value);
    showPostponeModal.value = false;
    await refreshData();
    alert('Maklumat Libur Mendadak berhasil diterbitkan ke Kabar Kampung!');
    
    // Buka WhatsApp share
    if (res.data?.whatsapp_broadcast_text) {
      window.open(`https://api.whatsapp.com/send?text=${encodeURIComponent(res.data.whatsapp_broadcast_text)}`, '_blank');
    }
  } catch (err) {
    alert('Gagal menunda kegiatan: ' + (err.response?.data?.message || err.message));
  }
}

async function activateSchedule(activity) {
  try {
    await axios.put(`${API_BASE}/posyandu/activity/${activity.id}`, {
      status: 'scheduled',
      postponed_reason: null,
    });
    alert('Jadwal Posyandu kembali aktif terjadwal.');
    await refreshData();
  } catch (err) {
    alert('Gagal mengaktifkan jadwal: ' + (err.response?.data?.message || err.message));
  }
}

function broadcastPosyanduWhatsApp(activity) {
  let text = '';
  if (activity.status === 'postponed') {
    text = `*📢 PEMBERITAHUAN PENUNDAAN POSYANDU MELATI RT 001/RW 005*\n\nKegiatan: *${activity.title}*\nSemula dijadwalkan: ${activity.activity_date} di ${activity.location}\n\n⚠️ *STATUS: DITUNDA / LIBUR MENDADAK*\nAlasan: ${activity.postponed_reason || 'Kader berhalangan hadir.'}\n` + (activity.rescheduled_date ? `Jadwal Pengganti: *${activity.rescheduled_date}*\n` : 'Jadwal pengganti akan diinfokan segera.\n') + `\nMohon maaf atas ketidaknyamanan ini 🙏\n- Kader Posyandu & Pengurus RT`;
  } else {
    text = `*🗓️ PENGINGAT JADWAL POSYANDU BALITA MELATI*\nRT 001 / RW 005\n\nKegiatan: *${activity.title}*\n📅 Hari/Tgl: ${activity.activity_date}\n📍 Lokasi: ${activity.location}\n\nProgram Layanan:\n${activity.description || 'Penimbangan BB/TB balita, imunisasi rutin, dan vitamin A.'}\n\nMohon ibu-ibu yang memiliki balita hadir tepat waktu dan membawa Buku KIA/KMS. Terima kasih 🙏\n- Kader Posyandu Melati`;
  }
  window.open(`https://api.whatsapp.com/send?text=${encodeURIComponent(text)}`, '_blank');
}

async function deletePosyanduActivity(id) {
  if (!confirm('Yakin ingin menghapus jadwal posyandu ini?')) return;
  try {
    await axios.delete(`${API_BASE}/posyandu/activity/${id}`);
    await refreshData();
    alert('Jadwal posyandu berhasil dihapus.');
  } catch (err) {
    alert('Gagal menghapus jadwal: ' + (err.response?.data?.message || err.message));
  }
}

async function saveChildRecord() {
  if (!childForm.value.child_name) {
    alert('Harap isi nama balita!');
    return;
  }
  try {
    await axios.post(`${API_BASE}/posyandu/record`, childForm.value);
    showAddChildModal.value = false;
    alert('Data tumbuh kembang balita berhasil dicatat!');
    childForm.value.child_name = '';
    await refreshData();
  } catch (err) {
    alert('Gagal mencatat data balita: ' + (err.response?.data?.message || err.message));
  }
}

// Linmas Actions
async function fetchPatrols() {
  try {
    const res = await axios.get(`${API_BASE}/linmas/attendances`);
    linmasAttendances.value = res.data.data || [];
  } catch (err) {
    console.error('Error fetching linmas attendances:', err);
  }
}

async function submitLinmasCheckIn() {
  try {
    await axios.post(`${API_BASE}/linmas/checkin`, {
      user_id: currentUser.value?.id || 1,
      officer_name: linmasCheckInForm.value.officer_name || currentUser.value?.name || 'Petugas Linmas',
      shift: linmasCheckInForm.value.shift,
      post_name: linmasCheckInForm.value.post_name,
      situation_status: linmasCheckInForm.value.situation_status,
      notes: linmasCheckInForm.value.notes,
    });
    alert('Presensi Linmas di Tempat (GPS Valid) berhasil dicatat!');
    showLinmasCheckInModal.value = false;
    await fetchPatrols();
  } catch (err) {
    alert('Gagal mengirim presensi: ' + (err.response?.data?.message || err.message));
  }
}

function submitLinmasSituation() {
  if (!linmasSituationForm.value.details) {
    alert('Rincian situasi wajib diisi!');
    return;
  }
  linmasSituationLogs.value.unshift({
    id: Date.now(),
    officer_name: linmasSituationForm.value.officer_name || currentUser.value?.name || 'Petugas Linmas',
    post_name: linmasSituationForm.value.post_name || 'Pos Ronda Utama RT 001',
    status: linmasSituationForm.value.status || 'aman',
    details: linmasSituationForm.value.details,
    time: new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) + ' WIB',
    verified_by: 'Bambang Sudarmono (Ketua RT 001)',
  });
  showLinmasSituationModal.value = false;
  linmasSituationForm.value.details = '';
  alert('Update situasi pos ronda berhasil dicatat ke Buku Mutasi Linmas!');
}

function verifyLinmasAttendance(id) {
  alert('Presensi Linmas telah diverifikasi oleh Ketua RT 001.');
}

function openCitizenDetail(citizen) {
  selectedCitizenDetail.value = citizen;
  showCitizenDetailModal.value = true;
}

function openProofPreview(url) {
  previewProofUrl.value = url;
  showProofModal.value = true;
}

function sendLetterWhatsApp(letter) {
  const cleanPhone = (letter.citizen_phone || '').replace(/[^0-9]/g, '');
  const phone = cleanPhone.startsWith('0') ? '62' + cleanPhone.substring(1) : cleanPhone;
  const printUrl = `${window.location.origin}/letters/${letter.id}/print?autoprint=1`;
  const text = `Halo Bpk/Ibu ${letter.citizen_name},\n\nKabar baik! Pengajuan ${letter.letter_type} Anda (No. Surat: ${letter.letter_number || '-'}) telah SELESAI ditandatangani secara digital oleh Ketua RT 001.\n\nAnda dapat langsung mengunduh dan mencetak berkas PDF resmi ber-Kop & QR Code validasi melalui tautan berikut:\n${printUrl}\n\nTerima kasih 🙏\n- Pengurus RT 001 / RW 005`;
  window.open(`https://wa.me/${phone}?text=${encodeURIComponent(text)}`, '_blank');
}

function broadcastNewsWhatsApp(item) {
  const text = `*📢 KABAR KAMPUNG RT 001/RW 005*\n\n*${(item.title || '').toUpperCase()}*\nKategori: ${item.category}\n\n${item.content}\n\nDiposkan oleh: ${item.author_name} (Pengurus RT)\n\nInformasi lengkap & layanan warga di aplikasi Warga Digital:\n${window.location.origin}`;
  window.open(`https://api.whatsapp.com/send?text=${encodeURIComponent(text)}`, '_blank');
}

function broadcastDueReminderToGroup() {
  const currentMonth = duesData.value?.summary?.current_month || 'Oktober 2026';
  const text = `*📢 PENGINGAT JATUH TEMPO IURAN KAS RT 001/RW 005*\nPeriode: ${currentMonth}\n\nYth. Bapak/Ibu Warga RT 001,\n\nMengingatkan kembali bagi warga yang belum menyelesaikan pembayaran Iuran Kas RT sebesar Rp 25.000 / KK untuk periode ${currentMonth}, dimohon untuk dapat melakukan pembayaran sebelum tanggal jatuh tempo.\n\n💳 *Pilihan Pembayaran:*\n1. *QRIS Statis RT* (Scan dari BCA, Mandiri, BRI, GoPay, OVO, DANA via aplikasi Warga Digital)\n2. *Transfer Bank BCA:* 8820-1928-31 a.n Kas Paguyuban RT 001\n3. *Tunai (Cash):* Langsung ke Bendahara RT (Ibu Siti Aminah)\n\nKuitansi digital ber-QR code dan rekap transparansi kas dapat dicek langsung di:\n${window.location.origin}\n\nTerima kasih atas partisipasi aktif seluruh warga 🙏\n- Pengurus & Bendahara RT 001`;
  window.open(`https://api.whatsapp.com/send?text=${encodeURIComponent(text)}`, '_blank');
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
