import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WargaDigitalApp());
}

class WargaDigitalApp extends StatelessWidget {
  const WargaDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warga Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF166534), // Emerald Green
          primary: const Color(0xFF166534),
          secondary: const Color(0xFFEA580C), // Vivid Orange
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthGateScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// DYNAMIC HOST RESOLUTION (Ensures mobile phone on Wi-Fi connects to laptop)
// ---------------------------------------------------------------------------
String getAppHost() {
  if (Uri.base.host.isNotEmpty) {
    return Uri.base.host;
  }
  return '192.168.1.9';
}

String getServerBase() {
  if (Uri.base.scheme == 'https') {
    return 'https://${Uri.base.host}';
  }
  if (Uri.base.host.isNotEmpty && Uri.base.host != 'localhost') {
    return 'http://${Uri.base.host}:8000';
  }
  return 'http://localhost:8000';
}

String getApiBase() => '${getServerBase()}/api';

// ---------------------------------------------------------------------------
// BRAND LOGO WIDGET (Matching the reference design icon & text)
// ---------------------------------------------------------------------------
class WargaDigitalLogo extends StatelessWidget {
  final double iconSize;
  final bool showText;
  final bool isWhite;

  const WargaDigitalLogo({
    super.key,
    this.iconSize = 36,
    this.showText = true,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stylized geometric community logo
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(iconSize * 0.3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF047857).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: iconSize * 0.18,
                top: iconSize * 0.18,
                child: Container(
                  width: iconSize * 0.28,
                  height: iconSize * 0.28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316), // Orange figure
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: iconSize * 0.18,
                top: iconSize * 0.18,
                child: Container(
                  width: iconSize * 0.28,
                  height: iconSize * 0.28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: iconSize * 0.18,
                child: Container(
                  width: iconSize * 0.58,
                  height: iconSize * 0.26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WARGA',
                style: TextStyle(
                  fontSize: iconSize * 0.42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isWhite ? Colors.white : const Color(0xFF14532D),
                  height: 1.0,
                ),
              ),
              Text(
                'DIGITAL',
                style: TextStyle(
                  fontSize: iconSize * 0.42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isWhite ? const Color(0xFF86EFAC) : const Color(0xFF059669),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 1. AUTH SCREEN (Matching the Left Phone in Reference Image)
// ---------------------------------------------------------------------------
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool isLoginMode = true;
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  // Controllers
  final nikController = TextEditingController(text: '3201010202950003'); // Budi Santoso (sample)
  final passwordController = TextEditingController(text: 'password123');
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> quickLoginAs(String identifier, String role, String displayName) async {
    setState(() {
      nikController.text = identifier;
      passwordController.text = 'password123';
      isLoginMode = true;
    });
    await handleAuth();
  }

  Future<void> handleAuth() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    final url = isLoginMode ? '${getApiBase()}/login' : '${getApiBase()}/register';
    final body = isLoginMode
        ? {
            'nik': nikController.text.trim(),
            'password': passwordController.text.trim(),
          }
        : {
            'nik': nikController.text.trim(),
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
            'address': addressController.text.trim(),
            'rt': '001',
            'rw': '005',
          };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && isLoginMode) {
        final user = data['user'];
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainHomeScreen(user: user)),
        );
      } else if (response.statusCode == 201 && !isLoginMode) {
        setState(() {
          successMessage = data['message'];
          isLoginMode = true;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Periksa kembali NIK / No. WhatsApp / Gmail dan Kata Sandi Anda.';
        });
      }
    } catch (e) {
      // Offline fallback mock mode (for smooth demo experience per role)
      if (isLoginMode && nikController.text.isNotEmpty) {
        final idLower = nikController.text.toLowerCase().trim();
        String role = 'warga';
        String name = 'Budi Santoso';
        if (idLower == 'bendahara' || idLower.contains('bendahara')) {
          role = 'bendahara';
          name = 'Siti Rahmawati (Bendahara RT 001)';
        } else if (idLower == 'rt' || idLower.contains('900001')) {
          role = 'rt';
          name = 'Bambang Sudarmono (Ketua RT 001)';
        } else if (idLower == 'linmas' || idLower.contains('linmas')) {
          role = 'linmas';
          name = 'Sutrisno (Komandan Linmas RT)';
        } else if (idLower == 'posyandu' || idLower.contains('posyandu')) {
          role = 'posyandu';
          name = 'Dewi Lestari (Kader Posyandu Melati)';
        }

        final mockUser = {
          'id': 1,
          'nik': nikController.text,
          'name': name,
          'phone': '081298765432',
          'role': role,
          'rt': '001',
          'rw': '005',
          'status': 'approved',
        };
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainHomeScreen(user: mockUser)),
        );
      } else {
        setState(() {
          errorMessage = 'Tidak dapat menghubungi server lokal ($e).';
        });
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light slate bg matching web
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Brand Header (Matching Web login-brand-header)
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857), // Deep emerald
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF047857).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.home_work_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'WARGA DIGITAL',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sistem Informasi & Administrasi Desa Mandiri • RT 001 / RW 005',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Card Container (Matching Web login-card)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header
                        Text(
                          isLoginMode ? 'Masuk ke Aplikasi' : 'Pendaftaran Akun Warga Baru',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoginMode
                              ? 'Pilih akun demo sesuai peran, atau masukkan NIK dan kata sandi Anda:'
                              : 'Lengkapi formulir pendaftaran untuk verifikasi oleh Ketua RT:',
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),

                        // Error or Success Banner
                        if (successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    successMessage!,
                                    style: const TextStyle(color: Color(0xFF166534), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFF991B1B), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 1-TAP QUICK ROLE PILLS (SIMPLIFIED & SLEEK SEPERTI WEB)
                        if (isLoginMode) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.flash_on_rounded, size: 15, color: Color(0xFFD97706)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Pilih Cepat Berdasarkan Peran (1-Klik):',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildQuickRoleChip(
                                      'Warga',
                                      const Color(0xFF16A34A),
                                      Icons.person_rounded,
                                      () => quickLoginAs('3201010202950003', 'warga', 'Budi Santoso'),
                                    ),
                                    _buildQuickRoleChip(
                                      'Ketua RT',
                                      const Color(0xFF065F46),
                                      Icons.shield_rounded,
                                      () => quickLoginAs('3201010101900001', 'rt', 'Bambang Sudarmono (Ketua RT 001)'),
                                    ),
                                    _buildQuickRoleChip(
                                      'Bendahara',
                                      const Color(0xFFEA580C),
                                      Icons.account_balance_wallet_rounded,
                                      () => quickLoginAs('bendahara', 'bendahara', 'Siti Rahmawati (Bendahara RT 001)'),
                                    ),
                                    _buildQuickRoleChip(
                                      'Linmas',
                                      const Color(0xFF2563EB),
                                      Icons.security_rounded,
                                      () => quickLoginAs('linmas', 'linmas', 'Sutrisno (Komandan Linmas RT)'),
                                    ),
                                    _buildQuickRoleChip(
                                      'Posyandu',
                                      const Color(0xFFDB2777),
                                      Icons.favorite_rounded,
                                      () => quickLoginAs('posyandu', 'posyandu', 'Dewi Lestari (Kader Posyandu)'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Divider "atau masuk dengan NIK / No. WhatsApp / Gmail"
                          const Row(
                            children: [
                              Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'atau masuk dengan NIK / WhatsApp',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Registration Additional Fields
                        if (!isLoginMode) ...[
                          _buildInputField(
                            controller: nameController,
                            label: 'Nama Lengkap (Sesuai KTP)',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: phoneController,
                            label: 'Nomor WhatsApp Aktif',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: emailController,
                            label: 'Email / Gmail (Opsional)',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: addressController,
                            label: 'Alamat Rumah / No. Rumah',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Input NIK / WhatsApp
                        _buildInputField(
                          controller: nikController,
                          label: isLoginMode ? 'NIK / No. WhatsApp / Gmail' : 'Nomor NIK (16 Digit KTP)',
                          icon: isLoginMode ? Icons.account_circle_outlined : Icons.credit_card_outlined,
                          keyboardType: isLoginMode ? TextInputType.text : TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        // Input Kata Sandi
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Kata Sandi (demo: password123)',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Primary Action Button (MASUK / KIRIM)
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF047857), // Emerald Green matching Web
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                : Text(
                                    isLoginMode ? 'Masuk ke Sistem' : 'Kirim Formulir Pendaftaran',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Switch between Login and Register
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isLoginMode = !isLoginMode;
                                errorMessage = null;
                                successMessage = null;
                              });
                            },
                            child: Text(
                              isLoginMode
                                  ? 'Belum punya akun? Daftar Warga Baru'
                                  : 'Sudah punya akun? Masuk ke Sistem',
                              style: const TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer
                  const Center(
                    child: Text(
                      '© 2026 Warga Digital • Dikembangkan untuk Pemerintahan Desa & Pengurus RT/RW',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoleChip(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.35), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. MAIN HOME CONTAINER WITH 4 BOTTOM TABS
// ---------------------------------------------------------------------------
class MainHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const MainHomeScreen({super.key, required this.user});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboardPage(
        user: widget.user,
        onNavigateToTab: (index) => setState(() => currentTabIndex = index),
      ),
      LayananKatalogPage(user: widget.user),
      AgendaKegiatanPage(user: widget.user),
      ProfilWargaPage(user: widget.user),
    ];

    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Beranda'),
                _buildNavItem(1, Icons.grid_view_rounded, 'Layanan'),
                _buildNavItem(2, Icons.calendar_today_rounded, 'Agenda'),
                _buildNavItem(3, Icons.person_outline_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentTabIndex == index;
    final color = isSelected ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => setState(() => currentTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. HOME DASHBOARD PAGE (Matching Right Phone in Reference Image)
// ---------------------------------------------------------------------------
class HomeDashboardPage extends StatelessWidget {
  final Map<String, dynamic> user;
  final Function(int) onNavigateToTab;

  const HomeDashboardPage({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final String userName = user['name'] ?? 'Budi Santoso';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Deep Emerald Green Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF14532D), // Dark forest green from reference
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Top user profile info + notification bell
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Modern Warga Digital logo mark in white/green
                      const WargaDigitalLogo(iconSize: 34, showText: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halo,',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user['role']).withOpacity(0.22),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getRoleColor(user['role']).withOpacity(0.6)),
                              ),
                              child: Text(
                                _getRoleBadgeText(user['role']),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Bell with Orange Dot Badge (Interactive & Clickable)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openNotificationModal(context, user: user, onNavigateToTab: onNavigateToTab),
                          borderRadius: BorderRadius.circular(24),
                          splashColor: Colors.white.withOpacity(0.25),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                ),
                                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                              ),
                              Positioned(
                                top: 3,
                                right: 3,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEA580C),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF14532D), width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Pill Search Bar (Clickable & Interactive)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openSearchDialog(context),
                      borderRadius: BorderRadius.circular(24),
                      splashColor: const Color(0xFF166534).withOpacity(0.12),
                      highlightColor: const Color(0xFF166534).withOpacity(0.06),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Color(0xFF166534), size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Cari layanan kampung...',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _openSearchDialog(context),
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.mic_none_rounded, color: Color(0xFF166534), size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 6 Grid Menu Items (Matching Reference Image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: [
                  _buildServiceTile(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Surat &\nDokumen',
                    onTap: () => _openSuratDialog(context),
                  ),
                  _buildServiceTile(
                    context,
                    icon: Icons.calendar_month_outlined,
                    label: 'Jadwal\nRonda',
                    onTap: () => onNavigateToTab(2),
                  ),
                  _buildServiceTile(
                    context,
                    icon: Icons.groups_outlined,
                    label: 'Kegiatan\nPosyandu',
                    onTap: () => _openPosyanduDialog(context),
                  ),
                  _buildServiceTile(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Aduan\nWarga',
                    onTap: () => _openAduanDialog(context),
                  ),
                  _buildServiceTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Iuran Kas\n& QRIS',
                    onTap: () => _openKasDialog(context, user),
                  ),
                  _buildServiceTile(
                    context,
                    icon: Icons.newspaper_outlined,
                    label: 'Berita\nKampung',
                    onTap: () => _openBeritaDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CCTV Quick Access Banner (Khusus Admin & Staff Pengurus RT)
            if (['rt', 'rw', 'bendahara', 'sekretaris', 'staff', 'admin', 'linmas'].contains(user['role'])) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () => _openCctvDialog(context, user),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.videocam_rounded, color: Color(0xFF22C55E), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Pantau CCTV Lingkungan RT',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '● LIVE',
                                    style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Akses Khusus Pengurus: Gerbang, Pos, Simpang, TPS',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Role Priority Action Card (Menyesuaikan dengan role pengguna yang masuk)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildRolePriorityCard(context, user['role'] ?? 'warga'),
            ),

            const SizedBox(height: 14),

            // "Laporan Terbaru Anda" Card (Matching Reference Image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with Green Checkmark
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Laporan Terbaru Anda',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Detail items
                    _buildStatusRow('Jenis:', 'Pengajuan Surat Domisili'),
                    const SizedBox(height: 8),
                    _buildStatusRow('Tanggal:', '14 Okt 2026'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'Status:',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Diproses oleh RT',
                            style: TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Orange Action Button (Lacak Status Pengajuan)
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          _openSuratDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C), // Vivid Orange
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Lacak Status Pengajuan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Quick SOS Panic Button Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_share, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tombol Bantuan Darurat (SOS)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          Text(
                            'Tekan jika ada musibah, kebakaran, atau medis',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _confirmSos(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // DOKUMENTASI & VIDEO KEGIATAN DESA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.video_library_rounded, color: Color(0xFF16A34A), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Video & Dokumentasi Kegiatan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _openAllKegiatanModal(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Liputan video dan galeri foto kegiatan guyub rukun warga desa terkini.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),

                  // Card 1: Video Liputan Gotong Royong
                  _buildVideoActivityCard(
                    context,
                    title: 'Kerja Bakti Bersama & Perbaikan Saluran Air RT 01',
                    category: 'Kegiatan Warga • Video Liputan',
                    duration: '02:45',
                    views: '158x ditonton',
                    date: '12 Okt 2026',
                    location: 'Pos Ronda Barat RT 001',
                    imagePath: 'assets/kegiatan_kerja_bakti.jpg',
                    fallbackNetwork: '${getServerBase()}/images/kegiatan_kerja_bakti.jpg',
                    description: 'Dokumentasi video kerja bakti gotong royong seluruh warga RT 01 membersihkan saluran selokan menyambut musim hujan dan penataan tanaman gang.',
                  ),

                  const SizedBox(height: 14),

                  // Card 2: Galeri Foto Posyandu Balita
                  _buildPhotoActivityCard(
                    context,
                    title: 'Pelaksanaan Posyandu Balita Melati & Vitamin A',
                    category: 'Kesehatan • Galeri Foto',
                    photoCount: '14 Foto',
                    date: '10 Okt 2026',
                    location: 'Balai RW 005',
                    imagePath: 'assets/kegiatan_posyandu.jpg',
                    fallbackNetwork: '${getServerBase()}/images/kegiatan_posyandu.jpg',
                    description: 'Dokumentasi foto penimbangan berat badan balita, pengukuran tinggi badan, imunisasi rutin, dan pembagian vitamin A gratis oleh kader Posyandu Melati.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static Widget _buildServiceTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF166534), size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  static Color _getRoleColor(String? role) {
    switch (role) {
      case 'rt':
      case 'rw':
        return const Color(0xFF22C55E);
      case 'bendahara':
        return const Color(0xFFF97316);
      case 'linmas':
        return const Color(0xFF38BDF8);
      case 'posyandu':
        return const Color(0xFFF472B6);
      default:
        return const Color(0xFF4ADE80);
    }
  }

  static String _getRoleBadgeText(String? role) {
    switch (role) {
      case 'rt':
        return '🎖️ KETUA RT 001';
      case 'rw':
        return '🎖️ KETUA RW 005';
      case 'bendahara':
        return '💰 BENDAHARA KAS RT';
      case 'linmas':
        return '👮 PETUGAS LINMAS / RONDA';
      case 'posyandu':
        return '👶 KADER POSYANDU MELATI';
      default:
        return '👤 WARGA TERVERIFIKASI RT 001';
    }
  }

  static Widget _buildRolePriorityCard(BuildContext context, String role) {
    if (role == 'bendahara') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Color(0xFFEA580C), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Panel Bendahara Kas RT',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: const Text('Mode Bendahara', style: TextStyle(color: Color(0xFFEA580C), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Kelola verifikasi bukti transfer kas warga (QRIS & Bank), pantau saldo kas bersama, dan terbitkan kuitansi digital sah.',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openKasDialog(context, {'role': role}),
                      icon: const Icon(Icons.verified, size: 16),
                      label: const Text('Verifikasi Kas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCctvDialog(context, {'role': role}),
                      icon: const Icon(Icons.videocam_rounded, size: 16),
                      label: const Text('CCTV RT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (role == 'linmas') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Panel Linmas & Pos Ronda',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: const Text('Mode Linmas', style: TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Petugas Keamanan: Lakukan presensi kehadiran malam ini dengan geotagging GPS dan verifikasi foto selfie.',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openAbsenLinmasDialog(context),
                      icon: const Icon(Icons.location_on, size: 16),
                      label: const Text('Absen GPS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCctvDialog(context, {'role': role}),
                      icon: const Icon(Icons.videocam_rounded, size: 16),
                      label: const Text('CCTV RT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (role == 'rt' || role == 'rw') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield, color: Color(0xFF166534), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Panel Pimpinan RT 001',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Text('Mode Ketua RT', style: TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Tinjau permohonan surat pengantar warga, berikan tanda tangan digital ber-QR, dan kelola kependudukan RT.',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openSuratDialog(context),
                      icon: const Icon(Icons.assignment_turned_in, size: 16),
                      label: const Text('Persetujuan Surat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCctvDialog(context, {'role': role}),
                      icon: const Icon(Icons.videocam_rounded, size: 16),
                      label: const Text('CCTV RT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (role == 'posyandu') {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF9A8D4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite, color: Color(0xFFDB2777), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Panel Kader Posyandu',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF9A8D4)),
                  ),
                  child: const Text('Mode Posyandu', style: TextStyle(color: Color(0xFFDB2777), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Kelola agenda penimbangan balita bulanan, pencatatan KMS, vitamin A, dan pencegahan stunting wilayah RT.',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openPosyanduDialog(context),
                icon: const Icon(Icons.child_care, size: 18),
                label: const Text('Buka Data Balita & Imunisasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB2777),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Default warga
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF166534), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Tagihan Anda Bulan Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Text('Bebas Admin', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildStatusRow('Iuran:', 'Kas Bulanan + Kebersihan RT'),
            const SizedBox(height: 8),
            _buildStatusRow('Periode:', 'Oktober 2026'),
            const SizedBox(height: 8),
            _buildStatusRow('Nominal:', 'Rp 25.000'),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openKasDialog(context, {'role': role}),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text(
                  'Bayar Kas (QRIS / Transfer)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  static void _confirmSos(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🚨 Peringatan Darurat (SOS)'),
        content: const Text(
          'Apakah Anda ingin menyiarkan sinyal darurat beserta lokasi GPS Anda ke seluruh pengurus RT & pos ronda sekarang?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sinyal bahaya GPS berhasil disiarkan ke pengurus RT!')),
              );
            },
            child: const Text('Kirim Bantuan'),
          ),
        ],
      ),
    );
  }

  static void _openSuratDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📄 Layanan Surat & Dokumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _buildDialogItem('Surat Keterangan Domisili', 'Status: Diproses RT', isPending: true),
            _buildDialogItem('Surat Pengantar Nikah / NA', 'Klik untuk ajukan baru'),
            _buildDialogItem('Surat Keterangan Usaha (SKU)', 'Klik untuk ajukan baru'),
            _buildDialogItem('Surat Keterangan Tidak Mampu (SKTM)', 'Klik untuk ajukan baru'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form pengajuan surat dibuka.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Buat Pengajuan Surat Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openPosyanduDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👶 Jadwal Posyandu Balita Melati', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Agenda Berikutnya:'),
            const SizedBox(height: 4),
            const Text('🗓️ Sabtu, 17 Oktober 2026 • 08.30 - 11.30 WIB', style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('📍 Balai Posyandu RW 05'),
            const Text('📋 Kegiatan: Penimbangan berat badan, ukur tinggi badan, dan vitamin A.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  static void _openSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchLayananModalSheet(),
    );
  }

  static Widget _buildActivityImage(
    String imageName, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    final String serverUrl = '${getServerBase()}/images/$imageName';
    final String relativeUrl = 'images/$imageName';
    final String rootUrl = '/images/$imageName';

    return Image.network(
      serverUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Image.network(
        relativeUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => Image.network(
          rootUrl,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF14532D),
            width: width,
            height: height,
            child: const Center(
              child: Icon(Icons.image_rounded, size: 40, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  static void _openNotificationModal(BuildContext context, {Map<String, dynamic>? user, Function(int)? onNavigateToTab}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationCenterModal(
        user: user ?? const {'name': 'Budi Santoso', 'role': 'warga'},
        onNavigateToTab: onNavigateToTab,
      ),
    );
  }

  static void _openAduanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AduanWargaModalSheet(),
    );
  }

  static void _openCctvDialog(BuildContext context, [Map<String, dynamic>? user]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CctvModalSheet(user: user),
    );
  }

  static void _openKasDialog(BuildContext context, [Map<String, dynamic>? user]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KasPaymentModalSheet(user: user),
    );
  }

  static void _openBeritaDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📰 Kabar Berita Kampung', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _buildNewsItem('Kerja Bakti Bersama Menyambut Musim Hujan', '2 hari lalu'),
            _buildNewsItem('Jadwal Imunisasi Balita Posyandu Melati', 'Kemarin'),
            _buildNewsItem('Peremajaan Lampu Penerangan Gang RT 01', 'Hari ini'),
          ],
        ),
      ),
    );
  }

  static void _openAbsenLinmasDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👮 Presensi Petugas Ronda / Linmas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('Jadwal Jaga Malam • Pos Ronda Utama RT 001', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.my_location, size: 16, color: Color(0xFF16A34A)),
                      SizedBox(width: 8),
                      Text('Status GPS:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Spacer(),
                      Text('Terkunci (-6.2088, 106.8456)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined, size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('Titik Patroli:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Spacer(),
                      Text('Pos Ronda & Gang Melati 1-4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF16A34A),
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(child: Text('Presensi GPS Linmas Berhasil! Data tercatat di rekap jaga malam.')),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text('Kirim Presensi GPS & Selfie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _buildDialogItem(String title, String subtitle, {bool isPending = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: isPending ? const Color(0xFFEA580C) : const Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  static Widget _buildNewsItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.article_outlined, color: Color(0xFF16A34A), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildVideoActivityCard(
    BuildContext context, {
    required String title,
    required String category,
    required String duration,
    required String views,
    required String date,
    required String location,
    required String imagePath,
    required String fallbackNetwork,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _openVideoPlayerModal(
        context,
        title: title,
        category: category,
        duration: duration,
        date: date,
        location: location,
        imagePath: imagePath,
        fallbackNetwork: fallbackNetwork,
        description: description,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildActivityImage('kegiatan_kerja_bakti.jpg', fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.55)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C).withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEA580C).withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'VIDEO LIPUTAN',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 14),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '$location • $date',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        views,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPhotoActivityCard(
    BuildContext context, {
    required String title,
    required String category,
    required String photoCount,
    required String date,
    required String location,
    required String imagePath,
    required String fallbackNetwork,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _openPhotoGalleryModal(
        context,
        title: title,
        category: category,
        photoCount: photoCount,
        date: date,
        location: location,
        imagePath: imagePath,
        fallbackNetwork: fallbackNetwork,
        description: description,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildActivityImage('kegiatan_posyandu.jpg', fit: BoxFit.cover),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_camera_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'GALERI FOTO',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      photoCount,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 14),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '$location • $date',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'Ketuk lihat foto →',
                        style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openVideoPlayerModal(
    BuildContext context, {
    required String title,
    required String category,
    required String duration,
    required String date,
    required String location,
    required String imagePath,
    required String fallbackNetwork,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _buildActivityImage('kegiatan_kerja_bakti.jpg', fit: BoxFit.cover),
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.35),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA580C).withOpacity(0.95),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('HD 1080p', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text('01:15', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: const LinearProgressIndicator(
                                      value: 0.45,
                                      backgroundColor: Colors.white24,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(duration, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(width: 10),
                                const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 18),
                                const SizedBox(width: 10),
                                const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('🗓️ $date', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFEA580C), size: 16),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Deskripsi Kegiatan:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tautan video kegiatan berhasil disalin untuk dibagikan ke grup WhatsApp warga!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Bagikan ke WhatsApp Warga', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openPhotoGalleryModal(
    BuildContext context, {
    required String title,
    required String category,
    required String photoCount,
    required String date,
    required String location,
    required String imagePath,
    required String fallbackNetwork,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildActivityImage('kegiatan_posyandu.jpg', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: index == 0 ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                                width: index == 0 ? 2 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildActivityImage(
                              index % 2 == 0 ? 'kegiatan_posyandu.jpg' : 'kegiatan_kerja_bakti.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFEA580C), size: 16),
                        const SizedBox(width: 4),
                        Text('$location • $date', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openAllKegiatanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('📸 Galeri & Video Kegiatan Kampung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Seluruh arsip video dokumentasi dan foto gotong royong warga RT 001 / RW 005.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            _buildVideoActivityCard(
              context,
              title: 'Kerja Bakti Bersama & Perbaikan Saluran Air RT 01',
              category: 'Kegiatan Warga • Video Liputan',
              duration: '02:45',
              views: '158x ditonton',
              date: '12 Okt 2026',
              location: 'Pos Ronda Barat RT 001',
              imagePath: 'assets/kegiatan_kerja_bakti.jpg',
              fallbackNetwork: '${getServerBase()}/images/kegiatan_kerja_bakti.jpg',
              description: 'Dokumentasi video kerja bakti gotong royong seluruh warga RT 01 membersihkan saluran selokan.',
            ),
            const SizedBox(height: 14),
            _buildPhotoActivityCard(
              context,
              title: 'Pelaksanaan Posyandu Balita Melati & Vitamin A',
              category: 'Kesehatan • Galeri Foto',
              photoCount: '14 Foto',
              date: '10 Okt 2026',
              location: 'Balai RW 005',
              imagePath: 'assets/kegiatan_posyandu.jpg',
              fallbackNetwork: '${getServerBase()}/images/kegiatan_posyandu.jpg',
              description: 'Dokumentasi foto penimbangan balita dan vitamin A oleh kader Posyandu Melati.',
            ),
          ],
        ),
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// 4. TAB 2: KATALOG LAYANAN LENGKAP
// ---------------------------------------------------------------------------
class LayananKatalogPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const LayananKatalogPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Layanan Desa', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildCategoryCard('Administrasi Kependudukan', [
            'Surat Keterangan Domisili',
            'Surat Pengantar Pembuatan e-KTP',
            'Surat Pengantar Akta Kelahiran',
            'Surat Keterangan Kematian',
          ]),
          const SizedBox(height: 14),
          _buildCategoryCard('Sosial & Ekonomi', [
            'Surat Keterangan Usaha (SKU)',
            'Surat Keterangan Tidak Mampu (SKTM)',
            'Bantuan Dana Darurat Warga',
          ]),
          const SizedBox(height: 14),
          _buildCategoryCard('Keamanan & Kebersihan', [
            'Jadwal & Presensi GPS Ronda Malam',
            'Laporan Kerusakan Lampu & Fasilitas',
            'Aduan TPS Sampah Liar',
          ]),
        ],
      ),
    );
  }

  static Widget _buildCategoryCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. TAB 3: AGENDA KAMPUNG
// ---------------------------------------------------------------------------
class AgendaKegiatanPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const AgendaKegiatanPage({super.key, required this.user});

  void _absenRondaGPS(BuildContext context) async {
    try {
      await http.post(
        Uri.parse('${getApiBase()}/patrols/check-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schedule_id': 1,
          'user_id': user['id'] ?? 1,
          'lat': -6.2087634,
          'lng': 106.8455990,
          'note': 'Hadir tepat waktu di Pos Ronda Utama',
        }),
      );
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF15803D),
        content: Text('✅ Presensi Ronda GPS Berhasil! Lokasi koordinat Anda tercatat hadir di dashboard RT.'),
      ),
    );
  }

  void _openScanCheckpointDialog(BuildContext context) {
    String selectedCode = 'POS-RONDA-01';
    String selectedStatus = 'Aman Kondusif';
    final notesController = TextEditingController(text: 'Pintu portal terkunci gembok, lampu penerangan jalan menyala terang.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Color(0xFF16A34A)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scan QR Checkpoint Patroli',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arahkan kamera ke stiker QR atau pilih titik pemeriksaan yang dikunjungi:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                const Text('Titik Checkpoint:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCode,
                      items: const [
                        DropdownMenuItem(value: 'POS-RONDA-01', child: Text('Pos Ronda Utama RT 001')),
                        DropdownMenuItem(value: 'PORTAL-BARAT-01', child: Text('Portal Barat Gang Kenanga')),
                        DropdownMenuItem(value: 'GARDU-TIMUR-01', child: Text('Gardu Timur Jalur Hijau')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCode = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Status Kondisi Lapangan:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'Aman Kondusif', child: Text('🟢 Aman Kondusif')),
                        DropdownMenuItem(value: 'Pintu Portal Terkunci', child: Text('🔵 Pintu Portal Terkunci')),
                        DropdownMenuItem(value: 'Lampu Jalan Padam', child: Text('🟡 Lampu Jalan Padam')),
                        DropdownMenuItem(value: 'Waspada', child: Text('🔴 Waspada / Kerumunan')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedStatus = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Catatan Situasi Terkini:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Kondisi portal, lampu, atau tamu asing...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await http.post(
                    Uri.parse('${getApiBase()}/patrols/checkpoint-scan'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'user_id': user['id'] ?? 1,
                      'checkpoint_code': selectedCode,
                      'situation_status': selectedStatus,
                      'notes': notesController.text.trim(),
                      'location_lat': -6.2087634,
                      'location_lng': 106.8455990,
                    }),
                  );
                } catch (_) {}
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF15803D),
                    content: Text('✅ Checkpoint $selectedCode Berhasil Diverifikasi! Laporan kondisi telah tercatat di dashboard RT.'),
                  ),
                );
              },
              child: const Text('Kirim Laporan Scan'),
            ),
          ],
        ),
      ),
    );
  }

  void _openSwapRequestDialog(BuildContext context) {
    String selectedType = 'izin_tidak_hadir';
    final reasonController = TextEditingController(text: 'Dinas luar kota mendadak, mohon izin ronda.');
    final neighborController = TextEditingController(text: 'Hendra Gunawan (Ketua RT)');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.swap_horiz, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pengajuan Izin / Tukar Ronda',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajukan permohonan selambat-lambatnya H-1 agar tidak terkena denda kompensasi alpha.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                const Text('Jenis Permohonan:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: 'izin_tidak_hadir', child: Text('Izin Tidak Hadir (Sakit / Dinas)')),
                        DropdownMenuItem(value: 'tukar_jadwal', child: Text('Tukar Jadwal dengan Tetangga')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                  ),
                ),
                if (selectedType == 'tukar_jadwal') ...[
                  const SizedBox(height: 12),
                  const Text('Tetangga Pengganti:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: neighborController,
                    decoration: InputDecoration(
                      hintText: 'Nama tetangga pengganti...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text('Alasan Permohonan:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Alasan berhalangan hadir...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await http.post(
                    Uri.parse('${getApiBase()}/patrols/swap-request'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'schedule_id': 1,
                      'requester_user_id': user['id'] ?? 1,
                      'type': selectedType,
                      'reason': reasonController.text.trim(),
                    }),
                  );
                } catch (_) {}
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF0369A1),
                    content: Text('✅ Permohonan Berhasil Dikirim! Pengurus RT akan meninjau dan memperbarui jadwal.'),
                  ),
                );
              },
              child: const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Kegiatan Kampung', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Dedicated Linmas / Hansip Attendance Card
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14532D), Color(0xFF064E3B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF064E3B).withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: Color(0xFF86EFAC), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Piket Linmas & Hansip Desa',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.5)),
                      ),
                      child: const Text('Aktif Dinas', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Petugas: ${user['name'] ?? 'Budi Santoso'} (Linmas RW 05)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '📍 Pos Pantau Utama RT 001 • Shift Malam (20:00 - 04:00 WIB)',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF15803D),
                              content: Text('✅ Presensi Masuk Piket Linmas Berhasil (Koordinat GPS Tercatat di Dashboard RT)!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text('Absen Masuk GPS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Laporan situasi: Wilayah Aman Terkendali telah dikirimkan ke RT.'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Lapor Aman', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Smart Siskamling Ronda Malam Warga Card
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security, color: Color(0xFFEA580C), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Jadwal Ronda Malam Warga',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Malam Ini (22:00)', style: TextStyle(color: Color(0xFFEA580C), fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Regu A • Pos Ronda Utama RT 001',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Anggota Regu: Budi Santoso, Rian Hidayat, Sutrisno, Hendra',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),

                // Action Buttons for Warga
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _absenRondaGPS(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.location_on, size: 15),
                        label: const Text('Presensi GPS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openScanCheckpointDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, size: 15),
                        label: const Text('Scan Checkpoint', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openSwapRequestDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                      backgroundColor: const Color(0xFFF0F9FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Ajukan Izin / Tukar Shift Ronda', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ketidakhadiran ronda tanpa izin resmi (Alpha) dikenakan denda kompensasi Rp 25.000,- yang masuk tagihan Kas RT.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'Agenda Kegiatan Kampung Lainnya',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

          _buildAgendaCard(
            date: 'Sabtu, 17 Okt 2026 • 08:30 WIB',
            title: 'Posyandu Balita & Lansia Melati',
            location: 'Balai RW 005',
            badge: 'Kesehatan',
            badgeColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          _buildAgendaCard(
            date: 'Minggu, 25 Okt 2026 • 07:00 WIB',
            title: 'Kerja Bakti Saluran Selokan',
            location: 'Area RT 001 / RW 005',
            badge: 'Gotong Royong',
            badgeColor: const Color(0xFFEA580C),
          ),
        ],
      ),
    );
  }

  static Widget _buildAgendaCard({
    required String date,
    required String title,
    required String location,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. TAB 4: PROFIL WARGA
// ---------------------------------------------------------------------------
class ProfilWargaPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const ProfilWargaPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF16A34A).withOpacity(0.15),
                    child: Text(
                      (user['name'] ?? 'B')[0],
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                      child: const Icon(Icons.verified, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user['name'] ?? 'Budi Santoso',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ),
            const Center(
              child: Text(
                'Warga Terverifikasi RT 001 / RW 005',
                style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // Profile info cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildProfileRow('NIK (e-KTP)', user['nik'] ?? '3201010202950003'),
                  const Divider(height: 20),
                  _buildProfileRow('Nomor WhatsApp', user['phone'] ?? '081298765432'),
                  const Divider(height: 20),
                  _buildProfileRow('Alamat Domisili', 'Jl. Melati No. 12, RT 001 / RW 005'),
                  const Divider(height: 20),
                  _buildProfileRow('Status Akun', 'Aktif & Disetujui Pengurus RT', isGreen: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthGateScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              label: const Text('Keluar dari Akun', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProfileRow(String title, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// KAS PAYMENT & DIGITAL E-RECEIPT MODAL SHEET (Manual Transfer + QRIS Statis)
// ---------------------------------------------------------------------------
class KasPaymentModalSheet extends StatefulWidget {
  final Map<String, dynamic>? user;
  const KasPaymentModalSheet({super.key, this.user});

  @override
  State<KasPaymentModalSheet> createState() => _KasPaymentModalSheetState();
}

class _KasPaymentModalSheetState extends State<KasPaymentModalSheet> {
  int _activeKasTab = 0;
  bool get isStaffOrAdmin {
    final role = widget.user?['role']?.toString().toLowerCase();
    return role == 'rt' || role == 'bendahara' || role == 'sekretaris' || role == 'staff' || role == 'admin';
  } // 0: Iuran & Kuitansi, 1: Breakdown Keuangan Kas
  bool _isLoading = true;
  bool _isLoadingTreasury = false;
  Map<String, dynamic>? _bill;
  Map<String, dynamic>? _payment;
  Map<String, dynamic>? _paymentAccounts;
  Map<String, dynamic>? _treasuryData;
  String _paymentMethod = 'qris_static'; // 'qris_static', 'bank_transfer', 'cash'
  final TextEditingController _senderNameController = TextEditingController(text: 'Bambang Sudarmono');
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchBill();
    _fetchTreasury();
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchBill() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('${getApiBase()}/dues/my-bill/1'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'];
          setState(() {
            _bill = data['bill'];
            _payment = data['payment'] ?? data['latest_payment'];
            _paymentAccounts = data['payment_accounts'];
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTreasury() async {
    setState(() => _isLoadingTreasury = true);
    try {
      final res = await http.get(Uri.parse('${getApiBase()}/treasury'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true) {
          setState(() {
            _treasuryData = decoded;
            _isLoadingTreasury = false;
          });
          return;
        }
      }
      setState(() => _isLoadingTreasury = false);
    } catch (_) {
      setState(() => _isLoadingTreasury = false);
    }
  }

  Future<void> _submitPayment() async {
    if (_bill == null) return;
    setState(() => _isSubmitting = true);
    try {
      const sampleProof =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      final isCash = _paymentMethod == 'cash';

      // Jika Staff / Admin mencatat penerimaan tunai, gunakan pay-cash-direct agar langsung Lunas
      if (isCash && isStaffOrAdmin) {
        final res = await http.post(
          Uri.parse('${getApiBase()}/dues/pay-cash-direct'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'bill_id': _bill!['id'],
            'recorded_by': widget.user?['id'] ?? 1,
            'notes': _notesController.text.trim().isEmpty ? 'Diterima tunai oleh ${widget.user?['name'] ?? 'Pengurus'}' : _notesController.text.trim(),
          }),
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Pembayaran tunai diterima & Kuitansi resmi langsung terbit!'),
                backgroundColor: Color(0xFF16A34A),
              ),
            );
          }
          await _fetchBill();
          await _fetchTreasury();
          return;
        }
      }

      final res = await http.post(
        Uri.parse('${getApiBase()}/dues/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bill_id': _bill!['id'],
          'user_id': 1,
          'payment_method': _paymentMethod,
          'proof_image_base64': isCash ? '' : sampleProof,
          'sender_name': _senderNameController.text.trim().isEmpty ? 'Warga RT 001' : _senderNameController.text.trim(),
          'sender_bank': isCash
              ? 'Tunai (Cash)'
              : (_paymentMethod == 'qris_static' ? 'BCA Mobile / QRIS' : 'Bank BCA'),
          'notes': _notesController.text.trim().isEmpty
              ? (isCash ? 'Bayar Tunai ke Bendahara' : '')
              : _notesController.text.trim(),
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCash
                  ? '✓ Pembayaran Tunai dilaporkan! Segera serahkan uang tunai fisik ke Bendahara RT.'
                  : '✓ Bukti transfer berhasil diunggah! Status: Menunggu Verifikasi'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
        await _fetchBill();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengirim data pembayaran.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showReceiptDialog(String receiptNumber) {
    final printUrl = '${getServerBase()}/receipts/$receiptNumber/print';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF16A34A)),
            SizedBox(width: 8),
            Text('Kuitansi Sah Ber-QR', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanda terima digital ini diterbitkan secara resmi dengan hash verifikasi SHA-256.',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                printUrl,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF0369A1)),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buka alamat di atas di browser untuk melihat atau mencetak berkas PDF resmi ber-Kop Surat RT.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF166534), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Kas RT & Transparansi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Sub Tabs Selector (Tagihan & Bayar VS Breakdown Keuangan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeKasTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeKasTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeKasTab == 0
                              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 16, color: _activeKasTab == 0 ? const Color(0xFF166534) : const Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              'Tagihan & Bayar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _activeKasTab == 0 ? FontWeight.w800 : FontWeight.w600,
                                color: _activeKasTab == 0 ? const Color(0xFF166534) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeKasTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeKasTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeKasTab == 1
                              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pie_chart_outline_rounded, size: 16, color: _activeKasTab == 1 ? const Color(0xFF166534) : const Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              'Breakdown Kas RT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _activeKasTab == 1 ? FontWeight.w800 : FontWeight.w600,
                                color: _activeKasTab == 1 ? const Color(0xFF166534) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body Content
          Expanded(
            child: _activeKasTab == 0 ? _buildDuesPaymentView() : _buildBreakdownView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDuesPaymentView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF166534)));
    }
    if (_bill == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gagal memuat data tagihan.'),
            TextButton(onPressed: _fetchBill, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildBillStateContent(),
    );
  }

  Widget _buildBillStateContent() {
    final status = _bill!['status'] ?? 'menunggu_bayar';
    if (status == 'lunas') {
      return _buildLunasReceiptView();
    } else if (status == 'menunggu_verifikasi') {
      return _buildMenungguVerifikasiView();
    } else {
      return _buildMenungguBayarForm();
    }
  }

  // 1. STATE: LUNAS (DIGITAL E-RECEIPT)
  Widget _buildLunasReceiptView() {
    final receiptNum = _payment?['receipt_number'] ?? 'KAS-RT01-202610-0002';
    final amount = _bill!['amount'] ?? 25000;
    final paymentMethod = _payment?['payment_method'] ?? 'cash';
    final methodLabel = paymentMethod == 'cash'
        ? '💵 Tunai / Cash (Langsung ke Bendahara)'
        : (paymentMethod == 'qris_static' ? '📱 QRIS Statis RT (Rp 0 Admin)' : '🏦 Transfer Bank BCA');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'WARGA DIGITAL • RT 001 / RW 005',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534), letterSpacing: 1.2),
              ),
              const SizedBox(height: 4),
              const Text(
                'TANDA TERIMA KAS RESMI',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),

              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 38),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pembayaran Berhasil & Sah',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp $amount',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              _buildReceiptRow('No. Kuitansi:', receiptNum, isMono: true),
              const SizedBox(height: 8),
              _buildReceiptRow('Nama Warga:', 'Bambang Sudarmono'),
              const SizedBox(height: 8),
              _buildReceiptRow('Jenis Iuran:', '${_bill!['title']} (${_bill!['month']} ${_bill!['year']})'),
              const SizedBox(height: 8),
              _buildReceiptRow('Metode Bayar:', methodLabel),
              const SizedBox(height: 8),
              _buildReceiptRow('Status:', 'LUNAS TERVERIFIKASI', isGreen: true),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=70x70&data=${getServerBase()}/receipts/$receiptNum/print',
                      width: 54,
                      height: 54,
                      errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 54, color: Color(0xFF166534)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kode QR Validasi Resmi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text('Pindai untuk memvalidasi keaslian kuitansi di database kas RT.', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () => _showReceiptDialog(receiptNum),
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Lihat / Unduh Kuitansi PDF', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // 2. STATE: MENUNGGU VERIFIKASI
  Widget _buildMenungguVerifikasiView() {
    final paymentMethod = _payment?['payment_method'] ?? _paymentMethod;
    final isCash = paymentMethod == 'cash';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCash ? Icons.payments_rounded : Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isCash ? 'Menunggu Penyerahan Uang Tunai' : 'Bukti Transfer Sedang Diverifikasi',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isCash
                    ? 'Laporan pembayaran tunai telah dicatat. Serahkan uang tunai Rp ${_bill!['amount'] ?? 25000} ke Bendahara RT (Ibu Siti Aminah). Bendahara akan menekan tombol verifikasi dan kuitansi resmi Anda langsung terbit.'
                    : 'Bendahara RT sedang mengecek mutasi kas. Setelah diverifikasi di web pengurus, status otomatis LUNAS dan kuitansi resmi akan terbit.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('Rp ${_bill!['amount'] ?? 25000}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _fetchBill,
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF166534)),
            label: const Text('Perbarui Status', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF166534)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // 3. STATE: MENUNGGU BAYAR (PAYMENT FORM WITH CASH OPTION)
  Widget _buildMenungguBayarForm() {
    final amount = _bill!['amount'] ?? 25000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bill Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_bill!['title'] ?? 'Iuran Kas RT 01', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF14532D))),
                  Text('Periode: ${_bill!['month']} ${_bill!['year']}', style: const TextStyle(fontSize: 11, color: Color(0xFF166534))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rp $amount', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF166534))),
                  const Text('Bebas Biaya Admin', style: TextStyle(fontSize: 10, color: Color(0xFF15803D), fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Method Selector (QRIS, Bank, and CASH)
        const Text('Pilih Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Row(
          children: [
            // QRIS
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = 'qris_static'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'qris_static' ? const Color(0xFFDCFCE7) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _paymentMethod == 'qris_static' ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                      width: _paymentMethod == 'qris_static' ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '📱 QRIS',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _paymentMethod == 'qris_static' ? const Color(0xFF166534) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Bank Transfer
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = 'bank_transfer'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'bank_transfer' ? const Color(0xFFDCFCE7) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _paymentMethod == 'bank_transfer' ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                      width: _paymentMethod == 'bank_transfer' ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '🏦 Bank BCA',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _paymentMethod == 'bank_transfer' ? const Color(0xFF166534) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // CASH / Tunai (Khusus Admin & Staff Pengurus)
            if (isStaffOrAdmin) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'cash'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'cash' ? const Color(0xFFFEF3C7) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _paymentMethod == 'cash' ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                        width: _paymentMethod == 'cash' ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '💵 Terima Tunai',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: _paymentMethod == 'cash' ? const Color(0xFFB45309) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        if (!isStaffOrAdmin) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF16A34A), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 Ingin bayar tunai (cash)? Silakan serahkan uang tunai langsung ke Bendahara RT (Ibu Siti Aminah) di Pos RT / Rumah No. 12. Bendahara yang berwenang mencatat dan kuitansi resmi ber-QR Anda otomatis terbit.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF15803D), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Method Content
        if (_paymentMethod == 'qris_static') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Text('Pindai QRIS Resmi Kas RT 01', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 10),
                Image.network(
                  'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=00020101021126570014ID.LINKAJA.WWW01189360001100000000010208123456785204541153033605802ID5919KAS%20PAGUYUBAN%20RT016005BOGOR61051671062070703A016304E07B',
                  width: 170,
                  height: 170,
                  errorBuilder: (_, __, ___) => Container(
                    width: 170,
                    height: 170,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.qr_code_2, size: 100, color: Color(0xFF166534)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bisa dipindai dari m-Banking BCA, Mandiri, BRI, BNI, GoPay, OVO, ShopeePay, DANA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ] else if (_paymentMethod == 'bank_transfer') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rekening Kas Bersama RT:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                const Text('Bank BCA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('8820-1928-31', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF166534), letterSpacing: 1.1)),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20, color: Color(0xFF16A34A)),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: '8820192831'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nomor rekening BCA disalin!'), backgroundColor: Color(0xFF16A34A)),
                        );
                      },
                    ),
                  ],
                ),
                const Text('a.n Kas Paguyuban Warga RT 001', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              ],
            ),
          ),
        ] else ...[
          // CASH / TUNAI INSTRUCTIONS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.payments_rounded, color: Color(0xFFD97706), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bayar Tunai ke Bendahara RT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E))),
                          Text('Serahkan uang tunai fisik langsung tanpa perlu transfer.', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFFDE68A)),
                const SizedBox(height: 6),
                _buildReceiptRow('Penerima Kas:', 'Ibu Siti Aminah (Bendahara RT 001)'),
                const SizedBox(height: 6),
                _buildReceiptRow('Lokasi Penyerahan:', 'Rumah No. 12 / Pos Ronda RT'),
                const SizedBox(height: 6),
                _buildReceiptRow('Nominal Uang Pas:', 'Rp $amount', isGreen: true),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFD97706), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tidak memerlukan foto struk transfer. Cukup laporkan di bawah dan serahkan uang fisik ke Bendahara.',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF78350F)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Form Fields
        Text(
          _paymentMethod == 'cash' ? 'Data Pembayar Tunai:' : 'Konfirmasi Pembayaran:',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _senderNameController,
          decoration: InputDecoration(
            labelText: _paymentMethod == 'cash' ? 'Nama Penyetor Tunai' : 'Nama Pemilik Rekening / Akun',
            hintText: 'Contoh: Bambang Sudarmono',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: _paymentMethod == 'cash' ? 'Catatan / Waktu Penyerahan (Opsional)' : 'Catatan (Opsional)',
            hintText: _paymentMethod == 'cash' ? 'Contoh: Diserahkan di pos ronda malam ini' : 'Contoh: Iuran kas + titip kebersihan',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),

        // Proof Simulation (only for digital transfer, hidden for cash)
        if (_paymentMethod != 'cash') ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.image, color: Color(0xFF16A34A), size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Foto Struk Terpilih (Simulasi)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('struk_transfer_bca_25000.jpg (240 KB)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else ...[
          const SizedBox(height: 8),
        ],

        // Submit Button
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitPayment,
            icon: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(_paymentMethod == 'cash' ? Icons.check_circle_outline : Icons.send_rounded, size: 18),
            label: Text(
              _isSubmitting
                  ? 'Memproses...'
                  : (_paymentMethod == 'cash' ? 'Laporkan Pembayaran Tunai (Cash)' : 'Kirim Bukti Pembayaran'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _paymentMethod == 'cash' ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // 4. BREAKDOWN KEUANGAN KAS RT VIEW (TRANSPARANSI KAS)
  Widget _buildBreakdownView() {
    if (_isLoadingTreasury) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF166534)));
    }
    if (_treasuryData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gagal memuat transparansi kas RT.'),
            TextButton(onPressed: _fetchTreasury, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final summary = _treasuryData!['summary'] ?? {};
    final breakdown = _treasuryData!['breakdown'] ?? {};
    final List incomeBreakdown = breakdown['income'] ?? [];
    final List expenseBreakdown = breakdown['expense'] ?? [];
    final List transactions = _treasuryData!['data'] ?? [];

    final balance = summary['balance'] ?? 0;
    final totalIncome = summary['total_income'] ?? 0;
    final totalExpense = summary['total_expense'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Balance Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14532D), Color(0xFF166534)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF166534).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL SALDO KAS RT 001',
                      style: TextStyle(color: Color(0xFFBBF7D0), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Live Transparansi', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp $balance',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pemasukan', style: TextStyle(color: Color(0xFFDCFCE7), fontSize: 10, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('+Rp $totalIncome', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pengeluaran', style: TextStyle(color: Color(0xFFFED7AA), fontSize: 10, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('-Rp $totalExpense', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 1. BREAKDOWN PEMASUKAN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Breakdown Pemasukan Kas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                child: Text('${incomeBreakdown.length} Kategori', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (incomeBreakdown.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Belum ada data pemasukan.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))),
            )
          else
            ...incomeBreakdown.map((item) {
              final label = item['label'] ?? item['category'] ?? '-';
              final total = item['total'] ?? 0;
              final percentage = (item['percentage'] ?? 0).toDouble();
              final count = item['count'] ?? 0;
              final hexColor = item['color'] ?? '#16a34a';
              Color catColor = const Color(0xFF16A34A);
              try {
                catColor = Color(int.parse(hexColor.replaceAll('#', '0xFF')));
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                        ),
                        Text('Rp $total', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: catColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (percentage / 100).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$count transaksi penerimaan', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('$percentage%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: catColor)),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),

          // 2. BREAKDOWN PENGELUARAN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Breakdown Pengeluaran Kas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                child: Text('${expenseBreakdown.length} Kategori', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (expenseBreakdown.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Belum ada data pengeluaran.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))),
            )
          else
            ...expenseBreakdown.map((item) {
              final label = item['label'] ?? item['category'] ?? '-';
              final total = item['total'] ?? 0;
              final percentage = (item['percentage'] ?? 0).toDouble();
              final count = item['count'] ?? 0;
              final hexColor = item['color'] ?? '#dc2626';
              Color catColor = const Color(0xFFDC2626);
              try {
                catColor = Color(int.parse(hexColor.replaceAll('#', '0xFF')));
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                        ),
                        Text('Rp $total', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: catColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (percentage / 100).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$count pos anggaran', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('$percentage%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: catColor)),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),

          // 3. MUTASI TRANSAKSI TERAKHIR
          const Text('Catatan Buku Kas Terkini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          ...transactions.take(5).map((t) {
            final isIncome = t['type'] == 'pemasukan';
            final amount = t['amount'] ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(
                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['title'] ?? 'Transaksi Kas', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                        Text('${t['transaction_date']} • ${t['recorder_name'] ?? 'Pengurus'}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}Rp $amount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _fetchTreasury,
              icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF166534)),
              label: const Text('Segarkan Transparansi Kas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF166534)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReceiptRow(String label, String value, {bool isMono = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: isMono ? 'monospace' : null,
            color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class AduanWargaModalSheet extends StatefulWidget {
  const AduanWargaModalSheet({super.key});

  @override
  State<AduanWargaModalSheet> createState() => _AduanWargaModalSheetState();
}

class _AduanWargaModalSheetState extends State<AduanWargaModalSheet> {
  int _activeTab = 0; // 0: Buat Laporan, 1: Riwayat & Status
  String _selectedCategory = 'lampu_penerangan';
  final TextEditingController _titleController =
      TextEditingController(text: 'Lampu Penerangan Gang Melati 3 Padam Total');
  final TextEditingController _descController = TextEditingController(
      text: 'Lampu PJU sudah padam 3 malam berturut-turut, kondisi gang gelap dan rawan tindak kejahatan.');
  final TextEditingController _locationController =
      TextEditingController(text: 'Jl. Melati Gang 3 No. 14, RT 001/RW 005');

  bool _isAnonymous = false;
  bool _notifyWhatsapp = true;
  bool _hasPhotoAttached = true;
  bool _isSubmitting = false;
  String _statusFilter = 'all';

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'lampu_penerangan',
      'label': 'Lampu Jalan',
      'sublabel': 'PJU Padam/Rusak',
      'icon': Icons.lightbulb_outline_rounded,
      'color': Color(0xFFEAB308),
      'sampleTitle': 'Lampu Penerangan Gang Melati 3 Padam Total',
    },
    {
      'key': 'sampah_tps',
      'label': 'Kebersihan',
      'sublabel': 'Sampah Liar/Bau',
      'icon': Icons.delete_outline_rounded,
      'color': Color(0xFF16A34A),
      'sampleTitle': 'Tumpukan Sampah Liar di Sudut Lapangan',
    },
    {
      'key': 'jalan',
      'label': 'Jalan & Got',
      'sublabel': 'Jalan Rusak/Got',
      'icon': Icons.alt_route_rounded,
      'color': Color(0xFFEA580C),
      'sampleTitle': 'Saluran Drainase Mampet Pasca Hujan',
    },
    {
      'key': 'ketertiban',
      'label': 'Ketertiban',
      'sublabel': 'Bising/Gangguan',
      'icon': Icons.volume_up_outlined,
      'color': Color(0xFF9333EA),
      'sampleTitle': 'Laporan Kebisingan Melebihi Jam Malam RT',
    },
    {
      'key': 'keamanan',
      'label': 'Keamanan',
      'sublabel': 'Aktivitas Curiga',
      'icon': Icons.security_rounded,
      'color': Color(0xFF2563EB),
      'sampleTitle': 'Permohonan Peningkatan Patroli Ronda Malam',
    },
    {
      'key': 'lain-lain',
      'label': 'Aspirasi',
      'sublabel': 'Saran Fasilitas RT',
      'icon': Icons.maps_home_work_outlined,
      'color': Color(0xFF0D9488),
      'sampleTitle': 'Usulan Pengadaan Bak Sampah Terpilah Organik',
    },
  ];

  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'ADU-2026-088',
      'category': 'lampu_penerangan',
      'category_label': 'Lampu Jalan (PJU)',
      'title': 'Lampu Penerangan Jalan Gang Melati 3 Padam Total',
      'location': 'Jl. Melati Gang 3, Depan Pos Ronda Barat',
      'date': '14 Okt 2026 • 19:20 WIB',
      'reporter': 'Budi Santoso',
      'is_anonymous': false,
      'status': 'ditindak',
      'status_label': 'Sedang Dikerjakan',
      'status_color': Color(0xFFEA580C),
      'progress_step': 2,
      'admin_response': 'Petugas teknisi kelurahan sudah dihubungi, sedang penggantian bohlam LED hari ini.',
      'photo_name': 'lampu_pju_padam.jpg',
    },
    {
      'id': 'ADU-2026-085',
      'category': 'sampah_tps',
      'category_label': 'Sampah & Kebersihan',
      'title': 'Tumpukan Sampah Menumpuk di Sudut Lapangan Voli',
      'location': 'Area Pojok Barat Lapangan Voli RT 001',
      'date': '12 Okt 2026 • 08:15 WIB',
      'reporter': 'Warga Anonim',
      'is_anonymous': true,
      'status': 'selesai',
      'status_label': 'Selesai Ditangani',
      'status_color': Color(0xFF16A34A),
      'progress_step': 3,
      'admin_response': 'Tumpukan sampah telah diangkut oleh armada dinas kebersihan dan area sudah dipasangi plang bersih.',
      'photo_name': 'sampah_sudut_lapangan.jpg',
    },
    {
      'id': 'ADU-2026-082',
      'category': 'jalan',
      'category_label': 'Drainase & Got',
      'title': 'Saluran Air Gang Melati 1 Mampet Pasca Hujan Lebat',
      'location': 'Gang Melati 1 No. 04',
      'date': '13 Okt 2026 • 16:40 WIB',
      'reporter': 'Siti Aminah',
      'is_anonymous': false,
      'status': 'dilaporkan',
      'status_label': 'Menunggu Peninjauan RT',
      'status_color': Color(0xFF0284C7),
      'progress_step': 0,
      'admin_response': 'Laporan masuk antrean peninjauan Ketua RT untuk diagendakan kerja bakti massal Minggu ini.',
      'photo_name': 'got_mampet_gang1.jpg',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSelectCategory(Map<String, dynamic> cat) {
    setState(() {
      _selectedCategory = cat['key'];
      _titleController.text = cat['sampleTitle'];
    });
  }

  Future<void> _submitComplaint() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi judul dan deskripsi aduan!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await http.post(
        Uri.parse('${getApiBase()}/complaints'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1,
          'title': _titleController.text.trim(),
          'category': _selectedCategory,
          'description': _descController.text.trim(),
          'location_address': _locationController.text.trim(),
          'location_lat': -6.2088,
          'location_lng': 106.8456,
          'photo_url': '${getServerBase()}/images/kegiatan_kerja_bakti.jpg',
        }),
      );

      final catObj = _categories.firstWhere((c) => c['key'] == _selectedCategory, orElse: () => _categories[0]);
      final newTicketId = 'ADU-2026-0${89 + _complaints.length}';

      final newReport = {
        'id': newTicketId,
        'category': _selectedCategory,
        'category_label': catObj['label'],
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'date': 'Hari ini • Baru saja',
        'reporter': _isAnonymous ? 'Warga Anonim' : 'Budi Santoso',
        'is_anonymous': _isAnonymous,
        'status': 'dilaporkan',
        'status_label': 'Menunggu Peninjauan RT',
        'status_color': const Color(0xFF0284C7),
        'progress_step': 0,
        'admin_response': 'Laporan otomatis diterima sistem Warga Digital dan diteruskan ke Pengurus RT 001.',
        'photo_name': 'bukti_aduan_terbaru.jpg',
      };

      setState(() {
        _complaints.insert(0, newReport);
        _activeTab = 1; // Pindah ke tab status
        _isSubmitting = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Laporan Diterima!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terima kasih telah berkontribusi menjaga kenyamanan lingkungan. Nomor tiket pengaduan Anda:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nomor Tiket:', style: TextStyle(fontSize: 12, color: Color(0xFF166534))),
                      Text(
                        newTicketId,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF166534),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pengurus RT dan petugas terkait akan segera meninjau ke lokasi. Perkembangan penanganan dapat Anda pantau secara langsung.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Lihat Status Laporan'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA580C).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pusat Pengaduan & Aspirasi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Layanan Cepat Tanggap Lingkungan RT 001',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Segmented Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 16,
                            color: _activeTab == 0 ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Buat Laporan Baru',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _activeTab == 0 ? FontWeight.w800 : FontWeight.w600,
                              color: _activeTab == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 16,
                            color: _activeTab == 1 ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Status Aduan (${_complaints.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _activeTab == 1 ? FontWeight.w800 : FontWeight.w600,
                              color: _activeTab == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),

          // Body Content (Tab 0 vs Tab 1)
          Expanded(
            child: _activeTab == 0 ? _buildFormTab() : _buildHistoryTab(),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: FORM BUAT LAPORAN BARU ---
  Widget _buildFormTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        // Section: Pilih Kategori
        const Text(
          '1. Pilih Kategori Masalah',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final bool isSelected = _selectedCategory == cat['key'];
            final Color color = cat['color'];

            return InkWell(
              onTap: () => _onSelectCategory(cat),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(cat['icon'], size: 18, color: isSelected ? Colors.white : color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // Section: Judul Aduan
        const Text(
          '2. Judul Aduan / Kendala',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Contoh: Lampu jalan depan gang mati...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEA580C))),
          ),
        ),

        const SizedBox(height: 18),

        // Section: Lokasi Kejadian (GPS Auto)
        const Text(
          '3. Lokasi & Deteksi GPS',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.my_location_rounded, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GPS Terkunci: RT 001 (-6.2088, 106.8456) • Akurasi 3 meter',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _locationController,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 18),
            hintText: 'Patokan / Alamat detail (Gang / Blok / Rumah)',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEA580C))),
          ),
        ),

        const SizedBox(height: 18),

        // Section: Foto Bukti
        const Text(
          '4. Unggah Foto Bukti Kejadian',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              if (_hasPhotoAttached)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage('assets/kegiatan_kerja_bakti.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('foto_bukti_lampu_padam.jpg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('1.4 MB • Geotagged GPS Otomatis', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A))),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _hasPhotoAttached = false),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _hasPhotoAttached = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📸 Kamera dibuka: Foto bukti berhasil diambil!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEA580C),
                        side: const BorderSide(color: Color(0xFFEA580C)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text('Ambil Kamera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _hasPhotoAttached = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🖼️ Galeri dibuka: Foto bukti dipilih!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('Dari Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Section: Deskripsi Aduan
        const Text(
          '5. Deskripsi Detail Keluhan',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descController,
          maxLines: 3,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Jelaskan kronologi, dampak, atau perkiraan waktu kejadian...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEA580C))),
          ),
        ),

        const SizedBox(height: 18),

        // Section: Opsi Privasi & WA
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: Color(0xFF0369A1), size: 18),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kirim Sebagai Anonim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text('Nama disamarkan, hanya RT yang tahu', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAnonymous,
                    activeColor: const Color(0xFF0284C7),
                    onChanged: (val) => setState(() => _isAnonymous = val),
                  ),
                ],
              ),
              const Divider(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.chat_outlined, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifikasi WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text('Dapatkan update progres penanganan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _notifyWhatsapp,
                    activeColor: const Color(0xFF16A34A),
                    onChanged: (val) => setState(() => _notifyWhatsapp = val),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitComplaint,
            icon: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              _isSubmitting ? 'Mengirim Laporan...' : 'Kirim Pengaduan Sekarang',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: RIWAYAT & STATUS LIVE TRACKING ---
  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'Semua (${_complaints.length})'),
              const SizedBox(width: 6),
              _buildFilterChip('ditindak', '🔧 Diproses'),
              const SizedBox(width: 6),
              _buildFilterChip('dilaporkan', '⏳ Menunggu'),
              const SizedBox(width: 6),
              _buildFilterChip('selesai', '✅ Selesai'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Cards list
        ..._complaints
            .where((c) => _statusFilter == 'all' || c['status'] == _statusFilter)
            .map((item) => _buildComplaintCard(item))
            .toList(),

        const SizedBox(height: 16),

        // Quick add new complaint button
        OutlinedButton.icon(
          onPressed: () => setState(() => _activeTab = 0),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEA580C),
            side: const BorderSide(color: Color(0xFFEA580C)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: const Text('+ Buat Laporan Aduan Baru', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final bool isSelected = _statusFilter == key;
    return InkWell(
      onTap: () => setState(() => _statusFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> item) {
    final Color statusColor = item['status_color'] ?? const Color(0xFF16A34A);
    final int step = item['progress_step'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card: Category badge + Ticket ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDBA74)),
                ),
                child: Text(
                  item['category_label'] ?? 'Aduan Warga',
                  style: const TextStyle(color: Color(0xFFEA580C), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      item['status_label'] ?? 'Status',
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            item['title'] ?? '',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.3),
          ),

          const SizedBox(height: 6),

          // Meta info (Lokasi & Tanggal)
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 13),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  item['location'] ?? '',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Color(0xFF94A3B8), size: 13),
              const SizedBox(width: 3),
              Text(
                '${item['date']} • Pelapor: ${item['reporter']}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Stepper Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alur Progres Penanganan:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStepPoint('Diterima', isCompleted: step >= 0, isCurrent: step == 0),
                    _buildStepLine(isCompleted: step >= 1),
                    _buildStepPoint('Verifikasi', isCompleted: step >= 1, isCurrent: step == 1),
                    _buildStepLine(isCompleted: step >= 2),
                    _buildStepPoint('Tindakan', isCompleted: step >= 2, isCurrent: step == 2),
                    _buildStepLine(isCompleted: step >= 3),
                    _buildStepPoint('Selesai', isCompleted: step >= 3, isCurrent: step == 3),
                  ],
                ),
              ],
            ),
          ),

          if (item['admin_response'] != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_agent_rounded, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggapan Pengurus RT / Petugas:',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['admin_response'],
                          style: const TextStyle(fontSize: 11, color: Color(0xFF14532D), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepPoint(String title, {required bool isCompleted, required bool isCurrent}) {
    Color color;
    if (isCompleted) {
      color = const Color(0xFF16A34A);
    } else if (isCurrent) {
      color = const Color(0xFFEA580C);
    } else {
      color = const Color(0xFFCBD5E1);
    }

    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NOTIFICATION CENTER MODAL (PEMBERITAHUAN WARGA DIGITAL)
// ---------------------------------------------------------------------------
class NotificationCenterModal extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(int)? onNavigateToTab;

  const NotificationCenterModal({
    super.key,
    required this.user,
    this.onNavigateToTab,
  });

  @override
  State<NotificationCenterModal> createState() => _NotificationCenterModalState();
}

class _NotificationCenterModalState extends State<NotificationCenterModal> {
  String _selectedCategory = 'Semua';

  // List of active notifications for the village
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      {
        'id': 'notif-1',
        'type': 'kas',
        'category': 'Kas & Tagihan',
        'title': 'Tagihan Iuran Kas Oktober 2026',
        'message': 'Tagihan kas warga RT 001 sebesar Rp 25.000 telah terbit. Bayar gratis via QRIS Statis atau transfer bank tanpa biaya admin.',
        'time': '5 menit lalu',
        'icon': Icons.account_balance_wallet_rounded,
        'iconColor': const Color(0xFFEA580C),
        'bgColor': const Color(0xFFFFF7ED),
        'badge': 'Tagihan Kas',
        'actionText': 'Bayar via QRIS Statis',
        'isRead': false,
      },
      {
        'id': 'notif-2',
        'type': 'aduan',
        'category': 'Pengaduan',
        'title': 'Status Pengaduan #ADU-982 Diperbarui',
        'message': 'Laporan mengenai lampu penerangan jalan gang 3 yang mati telah ditugaskan ke Teknisi RT dan sedang dalam perbaikan.',
        'time': '20 menit lalu',
        'icon': Icons.build_circle_rounded,
        'iconColor': const Color(0xFF2563EB),
        'bgColor': const Color(0xFFEFF6FF),
        'badge': 'Sedang Ditangani',
        'actionText': 'Cek Progres Laporan',
        'isRead': false,
      },
      {
        'id': 'notif-3',
        'type': 'surat',
        'category': 'Surat Pengantar',
        'title': 'Surat Keterangan Domisili Siap Diunduh',
        'message': 'Permohonan surat domisili No. 470/12/RT.01/2026 telah ditandatangani secara digital oleh Ketua RT dan ber-QR code sah.',
        'time': '1 jam lalu',
        'icon': Icons.assignment_turned_in_rounded,
        'iconColor': const Color(0xFF16A34A),
        'bgColor': const Color(0xFFF0FDF4),
        'badge': 'Surat Selesai',
        'actionText': 'Lihat Detail Surat',
        'isRead': false,
      },
      {
        'id': 'notif-4',
        'type': 'linmas',
        'category': 'Kegiatan & Keamanan',
        'title': 'Jadwal Ronda Malam & Absensi Linmas',
        'message': 'Piket ronda malam Regu 2 dimulai pukul 22.00 WIB. Petugas Linmas standby di Pos Pantau Utama dengan geotagging GPS.',
        'time': '3 jam lalu',
        'icon': Icons.shield_rounded,
        'iconColor': const Color(0xFF0D9488),
        'bgColor': const Color(0xFFCCFBF1),
        'badge': 'Keamanan RT',
        'actionText': 'Buka Pos Ronda Linmas',
        'isRead': true,
      },
      {
        'id': 'notif-5',
        'type': 'posyandu',
        'category': 'Kegiatan & Keamanan',
        'title': 'Jadwal Posyandu Balita Melati',
        'message': 'Pelaksanaan penimbangan balita dan pembagian vitamin A hari Sabtu, 17 Oktober 2026 pukul 08.30 WIB di Balai RW 007.',
        'time': 'Kemarin',
        'icon': Icons.child_care_rounded,
        'iconColor': const Color(0xFFDB2777),
        'bgColor': const Color(0xFFFDF2F8),
        'badge': 'Kesehatan Balita',
        'actionText': 'Lihat Jadwal Posyandu',
        'isRead': true,
      },
    ];
  }

  int get _unreadCount => _notifications.where((n) => n['isRead'] == false).length;

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedCategory == 'Semua') {
      return _notifications;
    }
    return _notifications.where((n) => n['category'] == _selectedCategory).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF166534),
        content: Row(
          children: [
            Icon(Icons.done_all_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Semua pemberitahuan ditandai telah dibaca'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> item) {
    setState(() {
      item['isRead'] = true;
    });

    final String type = item['type'] ?? '';
    Navigator.pop(context); // close notification sheet first

    if (type == 'kas') {
      HomeDashboardPage._openKasDialog(context);
    } else if (type == 'aduan') {
      HomeDashboardPage._openAduanDialog(context);
    } else if (type == 'surat') {
      HomeDashboardPage._openSuratDialog(context);
    } else if (type == 'linmas') {
      HomeDashboardPage._openAbsenLinmasDialog(context);
    } else if (type == 'posyandu') {
      HomeDashboardPage._openPosyanduDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle pill
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF166534), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pemberitahuan Warga',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_unreadCount Baru',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Informasi tagihan kas, pengaduan & agenda desa',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (_unreadCount > 0)
                  TextButton.icon(
                    onPressed: _markAllAsRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    icon: const Icon(Icons.done_all, color: Color(0xFF166534), size: 15),
                    label: const Text(
                      'Tandai Dibaca',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                    ),
                  ),
              ],
            ),
          ),

          // Category Chips Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildCategoryChip('Semua'),
                _buildCategoryChip('Kas & Tagihan'),
                _buildCategoryChip('Pengaduan'),
                _buildCategoryChip('Surat Pengantar'),
                _buildCategoryChip('Kegiatan & Keamanan'),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada pemberitahuan pada kategori ini',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredNotifications[index];
                      final bool isRead = item['isRead'] ?? false;

                      return InkWell(
                        onTap: () => _handleNotificationTap(item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.white : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFF86EFAC),
                              width: isRead ? 1 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon container
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: item['bgColor'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['iconColor'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Content details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (item['iconColor'] as Color).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['badge'] ?? '',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: item['iconColor'] as Color,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              item['time'] ?? '',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                            ),
                                            if (!isRead) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFEA580C),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['message'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Action link button
                                    Row(
                                      children: [
                                        Text(
                                          item['actionText'] ?? 'Buka Rincian',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF166534),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: Color(0xFF166534),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title) {
    final bool isSelected = _selectedCategory == title;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF14532D),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF14532D) : const Color(0xFFE2E8F0),
          ),
        ),
        onSelected: (val) {
          if (val) {
            setState(() => _selectedCategory = title);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SEARCH LAYANAN MODAL SHEET (PENCARIAN LAYANAN & FITUR WARGA DIGITAL)
// ---------------------------------------------------------------------------
class SearchLayananModalSheet extends StatefulWidget {
  const SearchLayananModalSheet({super.key});

  @override
  State<SearchLayananModalSheet> createState() => _SearchLayananModalSheetState();
}

class _SearchLayananModalSheetState extends State<SearchLayananModalSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Surat',
    'Kas & Iuran',
    'Pengaduan',
    'Keamanan',
    'Posyandu',
    'Kegiatan',
  ];

  late final List<Map<String, dynamic>> _allServices;

  @override
  void initState() {
    super.initState();
    _allServices = [
      {
        'title': 'Surat Keterangan Domisili',
        'category': 'Surat',
        'desc': 'Pengajuan surat keterangan tempat tinggal resmi dari Ketua RT ber-QR code',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF0284C7),
        'bgColor': const Color(0xFFF0F9FF),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openSuratDialog(ctx);
        },
      },
      {
        'title': 'Surat Pengantar Pembuatan e-KTP / KK',
        'category': 'Surat',
        'desc': 'Pengantar pengurusan kartu identitas kependudukan RT 001 ke kelurahan',
        'icon': Icons.badge_rounded,
        'color': const Color(0xFF0284C7),
        'bgColor': const Color(0xFFF0F9FF),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openSuratDialog(ctx);
        },
      },
      {
        'title': 'Surat Keterangan Usaha (SKU)',
        'category': 'Surat',
        'desc': 'Surat keterangan izin domisili usaha warga untuk perbankan & UMKM',
        'icon': Icons.storefront_rounded,
        'color': const Color(0xFF0284C7),
        'bgColor': const Color(0xFFF0F9FF),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openSuratDialog(ctx);
        },
      },
      {
        'title': 'Bayar Iuran Kas Warga (QRIS)',
        'category': 'Kas & Iuran',
        'desc': 'Pembayaran iuran kas bulanan via scan QRIS atau transfer bank tanpa biaya admin',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFFEA580C),
        'bgColor': const Color(0xFFFFF7ED),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openKasDialog(ctx);
        },
      },
      {
        'title': 'Verifikasi & Kuitansi Kas Digital',
        'category': 'Kas & Iuran',
        'desc': 'Cek status verifikasi bukti transfer kas bersama dan unduh kuitansi sah',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFFEA580C),
        'bgColor': const Color(0xFFFFF7ED),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openKasDialog(ctx);
        },
      },
      {
        'title': 'Lapor Pengaduan Warga Lingkungan',
        'category': 'Pengaduan',
        'desc': 'Sampaikan keluhan fasilitas rusak, lampu mati, atau sampah liar secara cepat',
        'icon': Icons.campaign_rounded,
        'color': const Color(0xFFDC2626),
        'bgColor': const Color(0xFFFEF2F2),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openAduanDialog(ctx);
        },
      },
      {
        'title': 'Lacak Progres Aduan #ADU-982',
        'category': 'Pengaduan',
        'desc': 'Pantau perkembangan penanganan lampu penerangan gang yang sedang ditangani',
        'icon': Icons.track_changes_rounded,
        'color': const Color(0xFFDC2626),
        'bgColor': const Color(0xFFFEF2F2),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openAduanDialog(ctx);
        },
      },
      {
        'title': 'Presensi GPS Piket Linmas & Ronda',
        'category': 'Keamanan',
        'desc': 'Absensi kehadiran jaga malam dengan geotagging GPS pos ronda utama',
        'icon': Icons.shield_rounded,
        'color': const Color(0xFF16A34A),
        'bgColor': const Color(0xFFF0FDF4),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openAbsenLinmasDialog(ctx);
        },
      },
      {
        'title': 'Agenda Posyandu Balita Melati',
        'category': 'Posyandu',
        'desc': 'Jadwal penimbangan berat badan, imunisasi rutin, dan vitamin A balita',
        'icon': Icons.child_care_rounded,
        'color': const Color(0xFFDB2777),
        'bgColor': const Color(0xFFFDF2F8),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openPosyanduDialog(ctx);
        },
      },
      {
        'title': 'Video Dokumentasi Kerja Bakti Saluran Air',
        'category': 'Kegiatan',
        'desc': 'Liputan video gotong royong warga membersihkan selokan menyambut hujan',
        'icon': Icons.video_library_rounded,
        'color': const Color(0xFF166534),
        'bgColor': const Color(0xFFF0FDF4),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openVideoPlayerModal(
            ctx,
            title: 'Kerja Bakti Bersama & Perbaikan Saluran Air RT 01',
            category: 'Kegiatan Warga • Video Liputan',
            duration: '02:45',
            date: '12 Okt 2026',
            location: 'Pos Ronda Barat RT 001',
            imagePath: 'assets/kegiatan_kerja_bakti.jpg',
            fallbackNetwork: '${getServerBase()}/images/kegiatan_kerja_bakti.jpg',
            description: 'Dokumentasi video kerja bakti gotong royong seluruh warga RT 01 membersihkan saluran selokan.',
          );
        },
      },
      {
        'title': 'Galeri Foto Penimbangan Posyandu Melati',
        'category': 'Kegiatan',
        'desc': 'Album dokumentasi foto kegiatan posyandu balita dan vitamin A gratis',
        'icon': Icons.photo_camera_rounded,
        'color': const Color(0xFF0284C7),
        'bgColor': const Color(0xFFF0F9FF),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openPhotoGalleryModal(
            ctx,
            title: 'Pelaksanaan Posyandu Balita Melati & Vitamin A',
            category: 'Kesehatan • Galeri Foto',
            photoCount: '14 Foto',
            date: '10 Okt 2026',
            location: 'Balai RW 005',
            imagePath: 'assets/kegiatan_posyandu.jpg',
            fallbackNetwork: '${getServerBase()}/images/kegiatan_posyandu.jpg',
            description: 'Dokumentasi foto penimbangan berat badan balita dan vitamin A oleh kader Posyandu Melati.',
          );
        },
      },
      {
        'title': 'Kabar Berita & Pengumuman RT',
        'category': 'Kegiatan',
        'desc': 'Informasi pengumuman penting seputar lingkungan dari pengurus RT 001',
        'icon': Icons.newspaper_rounded,
        'color': const Color(0xFF0F172A),
        'bgColor': const Color(0xFFF1F5F9),
        'action': (BuildContext ctx) {
          Navigator.pop(ctx);
          HomeDashboardPage._openBeritaDialog(ctx);
        },
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredResults {
    final query = _searchController.text.trim().toLowerCase();
    return _allServices.where((item) {
      final matchesCategory = _selectedCategory == 'Semua' || item['category'] == _selectedCategory;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      final title = (item['title'] as String).toLowerCase();
      final desc = (item['desc'] as String).toLowerCase();
      final category = (item['category'] as String).toLowerCase();
      return title.contains(query) || desc.contains(query) || category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Search Input Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Cari surat, kas, aduan, linmas...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w400),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF16A34A), size: 22),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                                onPressed: () {
                                  setState(() => _searchController.clear());
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    foregroundColor: const Color(0xFF475569),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),

          // Categories Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF14532D),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: isSelected ? const Color(0xFF14532D) : const Color(0xFFE2E8F0)),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Results list
          Expanded(
            child: _filteredResults.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Layanan Tidak Ditemukan',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba cari dengan kata kunci lain seperti "surat", "kas", "aduan", "linmas", atau "posyandu".',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                    itemCount: _filteredResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredResults[index];
                      final color = item['color'] as Color;
                      final bgColor = item['bgColor'] as Color;

                      return InkWell(
                        onTap: () {
                          final action = item['action'] as Function(BuildContext);
                          action(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item['icon'] as IconData, color: color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['category'] as String,
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc'] as String,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}




// ---------------------------------------------------------------------------
// CCTV MONITORING MODAL SHEET (KHUSUS PENGURUS & LINMAS)
// ---------------------------------------------------------------------------
class CctvModalSheet extends StatefulWidget {
  final Map<String, dynamic>? user;
  const CctvModalSheet({super.key, this.user});

  @override
  State<CctvModalSheet> createState() => _CctvModalSheetState();
}

class _CctvModalSheetState extends State<CctvModalSheet> {
  bool _isLoading = true;
  List<dynamic> _cameras = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _fetchCctv();
  }

  Future<void> _fetchCctv() async {
    setState(() => _isLoading = true);
    try {
      final role = widget.user?['role'] ?? 'rt';
      final res = await http.get(Uri.parse('${getApiBase()}/cctv?role=$role'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true) {
          setState(() {
            _cameras = decoded['data'] ?? [];
            _summary = decoded['summary'] ?? {};
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _recordIncident(Map<String, dynamic> cam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Snapshot CCTV Disimpan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tangkapan layar dari ${cam['name']} telah disimpan secara otomatis ke Log Insiden Keamanan RT.', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(cam['preview_image'] ?? '', height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.videocam, size: 40)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 44, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.videocam_rounded, color: Color(0xFF22C55E), size: 24),
                    SizedBox(width: 8),
                    Text('CCTV Keamanan RT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Color(0xFF94A3B8)), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🔒 Akses Khusus: Pengurus RT & Linmas', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                Text('${_summary['online_cameras'] ?? 4} Online', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
                : _cameras.isEmpty
                    ? const Center(child: Text('Kamera tidak ditemukan.', style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cameras.length,
                        itemBuilder: (ctx, i) {
                          final cam = _cameras[i];
                          final isOnline = cam['status'] == 'online';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: isOnline ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(cam['name'] ?? 'CCTV', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(6)),
                                        child: Text(cam['resolution'] ?? '1080p', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    ClipRRect(
                                      child: Image.network(
                                        cam['preview_image'] ?? '',
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.black, child: const Center(child: Icon(Icons.videocam_off, color: Colors.white24, size: 40))),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('● LIVE', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w900)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                        child: Text(cam['location'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(cam['model'] ?? 'IP Camera', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                      ElevatedButton.icon(
                                        onPressed: () => _recordIncident(cam),
                                        icon: const Icon(Icons.camera_alt, size: 14),
                                        label: const Text('Snapshot Bukti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
