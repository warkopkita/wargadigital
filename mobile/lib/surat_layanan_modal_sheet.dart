import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart' show getServerBase;

// ============================================================================
// SURAT & DOKUMEN MODAL SHEET (INTERAKTIF & TERHUBUNG API RT)
// ============================================================================
class SuratLayananModalSheet extends StatefulWidget {
  final Map<String, dynamic>? user;
  const SuratLayananModalSheet({super.key, this.user});

  @override
  State<SuratLayananModalSheet> createState() => _SuratLayananModalSheetState();
}

class _SuratLayananModalSheetState extends State<SuratLayananModalSheet> {
  int _activeTab = 0; // 0: Layanan & Buat Surat, 1: Riwayat & Status
  bool _isLoading = false;
  List<Map<String, dynamic>> _letters = [];

  final List<Map<String, dynamic>> _availableTypes = [
    {
      'title': 'Surat Keterangan Domisili',
      'subtitle': 'Untuk pembuatan KTP, KK baru, atau pembukaan bank',
      'icon': Icons.home_work_outlined,
      'color': Color(0xFF16A34A),
      'defaultPurpose': 'Syarat pembuatan e-KTP dan pembaharuan Kartu Keluarga',
    },
    {
      'title': 'Surat Pengantar Nikah / NA',
      'subtitle': 'Berkas pengantar persyaratan KUA / pernikahan',
      'icon': Icons.favorite_border_rounded,
      'color': Color(0xFFE11D48),
      'defaultPurpose': 'Pendaftaran berkas pernikahan di Kantor Urusan Agama (KUA)',
    },
    {
      'title': 'Surat Keterangan Usaha (SKU)',
      'subtitle': 'Untuk pengajuan KUR BRI, izin usaha mikro, & UMKM',
      'icon': Icons.storefront_outlined,
      'color': Color(0xFFD97706),
      'defaultPurpose': 'Pengajuan permodalan Kredit Usaha Rakyat (KUR) BRI Unit Melati',
    },
    {
      'title': 'Surat Keterangan Tidak Mampu (SKTM)',
      'subtitle': 'Syarat beasiswa KIP Kuliah, BPJS PBI, & sekolah',
      'icon': Icons.volunteer_activism_outlined,
      'color': Color(0xFF2563EB),
      'defaultPurpose': 'Pengajuan beasiswa KIP Kuliah dan keringanan biaya pendidikan',
    },
    {
      'title': 'Surat Pengantar SKCK Polsek',
      'subtitle': 'Syarat berkas melamar pekerjaan atau CPNS',
      'icon': Icons.badge_outlined,
      'color': Color(0xFF7C3AED),
      'defaultPurpose': 'Penerbitan Surat Keterangan Catatan Kepolisian (SKCK) di Polsek',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    setState(() => _isLoading = true);
    try {
      final base = getServerBase();
      final res = await http.get(Uri.parse('$base/api/letters')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            _letters = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _letters = [
          {
            'id': 1,
            'letter_type': 'Surat Keterangan Domisili',
            'purpose': 'Syarat pembuatan e-KTP dan Kartu Keluarga Baru',
            'status': 'diproses_rt',
            'created_at': '2026-10-16 10:30',
            'nomor_surat': '470/01/RT.01/X/2026',
            'user_name': widget.user?['name'] ?? 'Ahmad Fauzi',
          },
          {
            'id': 2,
            'letter_type': 'Surat Keterangan Usaha (SKU)',
            'purpose': 'Pengajuan permodalan KUR Mikro BRI Unit Melati',
            'status': 'selesai',
            'created_at': '2026-10-10 14:15',
            'nomor_surat': '503/04/RT.01/RW.05/2026',
            'user_name': widget.user?['name'] ?? 'Ahmad Fauzi',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _openFormPengajuanDialog([String? preselectedType, String? initialPurpose]) {
    final typeController = TextEditingController(text: preselectedType ?? _availableTypes[0]['title']);
    final purposeController = TextEditingController(text: initialPurpose ?? 'Keperluan pengurusan berkas administrasi kependudukan');
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_document, color: Color(0xFF16A34A), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Form Pengajuan Surat RT',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 14),

              // Pilihan Jenis Surat Dropdown
              const Text('Jenis Surat Pengantar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: typeController.text,
                    isExpanded: true,
                    items: _availableTypes.map<DropdownMenuItem<String>>((t) {
                      return DropdownMenuItem<String>(
                        value: t['title'] as String,
                        child: Text(t['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          typeController.text = val;
                          final match = _availableTypes.firstWhere((e) => e['title'] == val, orElse: () => {});
                          if (match['defaultPurpose'] != null) {
                            purposeController.text = match['defaultPurpose'];
                          }
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),
              const Text('Keperluan Permohonan Surat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: purposeController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Syarat pembuatan KTP / KUR Bank / KUA',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              const SizedBox(height: 14),
              const Text('Catatan Tambahan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Misal: Berkas KK & KTP asli sudah disiapkan.',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (purposeController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harap isi keperluan surat terlebih dahulu.')),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);
                          final newLetter = {
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'letter_type': typeController.text,
                            'purpose': purposeController.text.trim(),
                            'status': 'diproses_rt',
                            'created_at': 'Baru Saja',
                            'nomor_surat': '470/RT.01/X/2026 (Menunggu Pengesahan)',
                            'user_name': widget.user?['name'] ?? 'Ahmad Fauzi',
                          };

                          // Call backend API in background
                          try {
                            final base = getServerBase();
                            await http.post(
                              Uri.parse('$base/api/letters'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'user_id': widget.user?['id'] ?? 1,
                                'letter_type': typeController.text,
                                'purpose': purposeController.text.trim(),
                                'additional_data': {'notes': notesController.text.trim()},
                              }),
                            );
                          } catch (_) {}

                          if (mounted) {
                            setState(() {
                              _letters.insert(0, newLetter);
                              _activeTab = 1; // Pindah ke tab riwayat
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Permohonan ${typeController.text} berhasil dikirim ke Pak RT!'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                          }
                        },
                  icon: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    isSubmitting ? 'Mengirim ke Ketua RT...' : 'Kirim Pengajuan ke Ketua RT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSurat(Map<String, dynamic> item) {
    final isDone = item['status'] == 'selesai';
    final isPending = item['status'] == 'diproses_rt' || item['status'] == 'diajukan';
    final userRole = widget.user?['role'] ?? 'warga';
    final isStaffOrAdmin = ['rt', 'rw', 'staff', 'admin'].contains(userRole);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDone ? Icons.verified_rounded : Icons.pending_actions_rounded,
                        color: isDone ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Detail Status Surat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            // Card Ringkasan Surat
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['letter_type'] ?? 'Surat Pengantar', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text('No: ${item['nomor_surat'] ?? '470/RT.01/X/2026'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'monospace')),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pemohon:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Text(item['user_name'] ?? 'Ahmad Fauzi', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Keperluan:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item['purpose'] ?? '-', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Tracking Alur Pengesahan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF334155))),
            const SizedBox(height: 10),

            // Step 1: Diajukan
            _buildTimelineStep(
              title: '1. Pengajuan Surat oleh Warga',
              subtitle: 'Data permohonan telah terkirim ke sistem RT',
              isCompleted: true,
              isCurrent: false,
            ),
            // Step 2: Verifikasi RT
            _buildTimelineStep(
              title: '2. Verifikasi & Tanda Tangan Ketua RT',
              subtitle: isDone ? 'Telah ditandatangani digital oleh Ketua RT 001' : 'Sedang ditinjau oleh Ketua RT 001',
              isCompleted: isDone,
              isCurrent: isPending,
            ),
            // Step 3: Pengesahan RW
            _buildTimelineStep(
              title: '3. Pengesahan & Penerbitan Surat QR',
              subtitle: isDone ? 'Surat resmi sah dan siap digunakan' : 'Menunggu verifikasi selesai',
              isCompleted: isDone,
              isCurrent: false,
              isLast: true,
            ),

            const SizedBox(height: 18),

            // Jika role RT/RW sedang meninjau surat yang belum selesai
            if (isStaffOrAdmin && !isDone) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          item['status'] = 'selesai';
                          item['nomor_surat'] = '470/RT.01/RW.05/2026';
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Surat berhasil disetujui & ditandatangani digital QR!'),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Setujui & TTD QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        item['status'] = 'ditolak';
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Permohonan surat ditolak.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ] else if (isDone) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF16A34A)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanda Tangan Digital Sah Ber-QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF166534))),
                          Text('Terverifikasi oleh Ketua RT 001 & Ketua RW 005', style: TextStyle(fontSize: 10, color: Color(0xFF15803D))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('File PDF Surat Resmi ber-QR siap dicetak!'),
                      backgroundColor: Color(0xFF0284C7),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Unduh / Cetak Surat PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    Color iconColor = isCompleted
        ? const Color(0xFF16A34A)
        : (isCurrent ? const Color(0xFFEA580C) : const Color(0xFF94A3B8));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              color: iconColor,
              size: 20,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: isCompleted || isCurrent ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description_rounded, color: Color(0xFF16A34A), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Layanan Surat & Dokumen',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Color(0xFF64748B)), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTab == 0
                            ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Text(
                        'Ajukan Surat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _activeTab == 0 ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTab == 1
                            ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Riwayat & Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _activeTab == 1 ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                            ),
                          ),
                          if (_letters.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _activeTab == 1 ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_letters.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Content Tab
          Expanded(
            child: _activeTab == 0 ? _buildTabAjukanSurat() : _buildTabRiwayatSurat(),
          ),

          // Bottom Action Button in Tab 0
          if (_activeTab == 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openFormPengajuanDialog(),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Buat Pengajuan Surat Baru',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabAjukanSurat() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Kartu Status Surat yang Sedang Diproses (jika ada)
        if (_letters.any((l) => l['status'] == 'diproses_rt' || l['status'] == 'diajukan')) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Surat Anda Sedang Diproses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E))),
                      Text('Surat Keterangan Domisili sedang diverifikasi oleh Ketua RT.', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _activeTab = 1),
                  child: const Text('Lacak', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'PILIH JENIS SURAT (KLIK UNTUK MENGAJUKAN):',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 6),

        // List Jenis Surat - SEMUA BISA DIKLIK!
        ..._availableTypes.map((item) {
          final title = item['title'] as String;
          final subtitle = item['subtitle'] as String;
          final icon = item['icon'] as IconData;
          final color = item['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openFormPengajuanDialog(title, item['defaultPurpose']),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabRiwayatSurat() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)));
    }

    if (_letters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_rounded, size: 48, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 12),
              const Text('Belum Ada Pengajuan Surat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              const Text('Klik tombol "Ajukan Surat" untuk membuat permohonan surat baru ke Ketua RT.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _activeTab = 0),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                child: const Text('Pilih Surat Sekarang'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _letters.length,
      itemBuilder: (ctx, i) {
        final item = _letters[i];
        final status = item['status'] ?? 'diajukan';
        final isDone = status == 'selesai';
        final isPending = status == 'diproses_rt' || status == 'diajukan';

        Color badgeBg = isDone
            ? const Color(0xFFF0FDF4)
            : (isPending ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2));
        Color badgeText = isDone
            ? const Color(0xFF16A34A)
            : (isPending ? const Color(0xFFEA580C) : const Color(0xFFDC2626));
        String statusLabel = isDone
            ? 'Disetujui (Ber-QR Sah)'
            : (isPending ? 'Diproses RT' : 'Ditolak');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDetailSurat(item),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['letter_type'] ?? 'Surat Pengantar',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: badgeText, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['purpose'] ?? '-',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['created_at'] ?? 'Hari ini',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const Row(
                          children: [
                            Text('Detail & Tracking', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF16A34A)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
