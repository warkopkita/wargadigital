<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Users / Pengurus & Warga
        $admin = User::create([
            'nik' => '3201010101900001',
            'name' => 'Bambang Sudarmono (Ketua RT 001)',
            'phone' => '081234567890',
            'email' => 'rt01@wargadigital.id',
            'password' => Hash::make('password123'),
            'role' => 'rt',
            'rt' => '001',
            'rw' => '005',
            'address' => 'Jl. Kenanga No. 12, RT 01 / RW 05',
            'occupation' => 'Wiraswasta',
            'status' => 'approved',
            'approved_at' => now(),
        ]);

        $rw = User::create([
            'nik' => '3201010101850002',
            'name' => 'H. Suryanto (Ketua RW 005)',
            'phone' => '081234567891',
            'email' => 'rw05@wargadigital.id',
            'password' => Hash::make('password123'),
            'role' => 'rw',
            'rt' => '002',
            'rw' => '005',
            'address' => 'Jl. Mawar No. 01, RT 02 / RW 05',
            'occupation' => 'Pensiunan PNS',
            'status' => 'approved',
            'approved_at' => now(),
        ]);

        $warga1 = User::create([
            'nik' => '3201010202950003',
            'name' => 'Ahmad Fauzi',
            'phone' => '082199887766',
            'email' => 'ahmad@example.com',
            'password' => Hash::make('password123'),
            'role' => 'warga',
            'rt' => '001',
            'rw' => '005',
            'address' => 'Jl. Kenanga No. 45, RT 01 / RW 05',
            'occupation' => 'Karyawan Swasta',
            'status' => 'approved',
            'approved_by' => $admin->id,
            'approved_at' => now(),
        ]);

        $warga2 = User::create([
            'nik' => '3201010303980004',
            'name' => 'Siti Nurhaliza',
            'phone' => '085711223344',
            'email' => 'siti@example.com',
            'password' => Hash::make('password123'),
            'role' => 'warga',
            'rt' => '001',
            'rw' => '005',
            'address' => 'Jl. Melati No. 8, RT 01 / RW 05',
            'occupation' => 'Ibu Rumah Tangga',
            'status' => 'approved',
            'approved_by' => $admin->id,
            'approved_at' => now(),
        ]);

        $wargaPending = User::create([
            'nik' => '3201010404010005',
            'name' => 'Rian Hidayat (Warga Baru)',
            'phone' => '089877665544',
            'email' => 'rian@example.com',
            'password' => Hash::make('password123'),
            'role' => 'warga',
            'rt' => '001',
            'rw' => '005',
            'address' => 'Jl. Kenanga Blok C No. 2, RT 01 / RW 05',
            'occupation' => 'Mahasiswa',
            'status' => 'pending',
        ]);

        // 2. Berita & Pengumuman Kampung
        DB::table('news_posts')->insert([
            [
                'title' => 'Kerja Bakti Bersama Menyambut Musim Hujan',
                'slug' => 'kerja-bakti-bersama-musim-hujan',
                'category' => 'Kegiatan',
                'content' => 'Diberitahukan kepada seluruh warga RT 01 dan RT 02 RW 05 untuk mengikuti kerja bakti pembersihan saluran air dan pemangkasan dahan pohon pada hari Minggu pukul 07.00 WIB di pos ronda utama.',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=600',
                'is_pinned' => true,
                'author_id' => $admin->id,
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
            [
                'title' => 'Jadwal Imunisasi Balita Posyandu Melati Bulan Ini',
                'slug' => 'jadwal-imunisasi-posyandu-melati',
                'category' => 'Posyandu',
                'content' => 'Kegiatan Posyandu Melati akan dilaksanakan pada hari Kamis depan tanggal 20. Diharapkan para ibu yang memiliki balita usia 0-5 tahun untuk hadir membawa buku KIA.',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=600',
                'is_pinned' => false,
                'author_id' => $admin->id,
                'created_at' => now()->subDay(),
                'updated_at' => now()->subDay(),
            ],
            [
                'title' => 'Laporan Rekap Ronda Malam Minggu Ke-2',
                'slug' => 'rekap-ronda-malam-minggu-2',
                'category' => 'Ronda',
                'content' => 'Situasi lingkungan selama sepekan terakhir aman dan kondusif. Terima kasih kepada seluruh tim ronda regu 1 sampai regu 4 yang telah bertugas tepat waktu.',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
                'is_pinned' => false,
                'author_id' => $admin->id,
                'created_at' => now()->subHours(8),
                'updated_at' => now()->subHours(8),
            ],
        ]);

        // 3. Surat & Dokumen
        DB::table('letters')->insert([
            [
                'user_id' => $warga1->id,
                'letter_type' => 'Surat Pengantar Pembuatan KTP Baru',
                'letter_number' => '470/012/RT.01/X/2026',
                'purpose' => 'Persyaratan pengurusan KTP elektronik di Kantor Kelurahan / Kecamatan',
                'additional_data' => json_encode(['nik' => $warga1->nik, 'nama' => $warga1->name, 'status_kawin' => 'Belum Menikah']),
                'status' => 'selesai',
                'admin_notes' => 'Surat sudah ditandatangani secara digital oleh Ketua RT 001 dan RW 005.',
                'qr_code_hash' => 'QR-WD-'.bin2hex(random_bytes(8)),
                'pdf_file_path' => '/storage/surat/surat_ktp_470_012.pdf',
                'signed_by' => $admin->id,
                'signed_at' => now()->subDays(1),
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(1),
            ],
            [
                'user_id' => $warga2->id,
                'letter_type' => 'Surat Keterangan Domisili Tempat Tinggal',
                'letter_number' => null,
                'purpose' => 'Keperluan pendaftaran anak masuk sekolah PAUD',
                'additional_data' => json_encode(['nik' => $warga2->nik, 'nama' => $warga2->name]),
                'status' => 'diproses_rt',
                'admin_notes' => 'Sedang diverifikasi oleh Ketua RT 001.',
                'qr_code_hash' => null,
                'pdf_file_path' => null,
                'signed_by' => null,
                'signed_at' => null,
                'created_at' => now()->subHours(5),
                'updated_at' => now()->subHours(2),
            ],
            [
                'user_id' => $warga1->id,
                'letter_type' => 'Surat Pengantar SKCK',
                'letter_number' => null,
                'purpose' => 'Melamar pekerjaan di instansi BUMN',
                'additional_data' => json_encode(['keperluan' => 'Lamaran Kerja']),
                'status' => 'diajukan',
                'admin_notes' => null,
                'qr_code_hash' => null,
                'pdf_file_path' => null,
                'signed_by' => null,
                'signed_at' => null,
                'created_at' => now()->subMinutes(30),
                'updated_at' => now()->subMinutes(30),
            ],
        ]);

        // 4. Jadwal Ronda Malam
        $patrol1 = DB::table('patrol_schedules')->insertGetId([
            'patrol_date' => now()->toDateString(),
            'day_name' => 'Hari Ini',
            'shift_name' => 'Malam Regu A (22:00 - 04:00)',
            'rt' => '001',
            'rw' => '005',
            'notes' => 'Fokus patroli portal barat dan gang melati',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('patrol_members')->insert([
            [
                'patrol_schedule_id' => $patrol1,
                'user_id' => $warga1->id,
                'has_checked_in' => true,
                'checked_in_at' => now()->subMinutes(20),
                'check_in_lat' => -6.2087634,
                'check_in_lng' => 106.8455990,
                'check_in_note' => 'Pos ronda depan portal barat, cuaca cerah',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'patrol_schedule_id' => $patrol1,
                'user_id' => $admin->id,
                'has_checked_in' => false,
                'checked_in_at' => null,
                'check_in_lat' => null,
                'check_in_lng' => null,
                'check_in_note' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        // 5. Posyandu & Data Balita
        $posyanduId = DB::table('posyandu_activities')->insertGetId([
            'title' => 'Posyandu Melati Berkala - Oktober 2026',
            'activity_date' => now()->addDays(5)->toDateString(),
            'location' => 'Balai Warga RT 01 / RW 05',
            'rt' => '001',
            'description' => 'Penimbangan berat badan, pengukuran tinggi badan, dan pemberian vitamin A',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('child_records')->insert([
            [
                'parent_user_id' => $warga2->id,
                'child_name' => 'Kenzo Alfarizi',
                'gender' => 'L',
                'birth_date' => '2024-04-10',
                'weight_kg' => 12.4,
                'height_cm' => 88.5,
                'head_circumference_cm' => 47.0,
                'immunization_type' => 'Polio 4 & DPT-HB-Hib 3',
                'cadre_notes' => 'Pertumbuhan sangat baik dan aktif',
                'recorded_date' => now()->subMonth()->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        // 6. Aduan Warga & Lingkungan
        DB::table('complaints')->insert([
            [
                'user_id' => $warga1->id,
                'title' => 'Lampu Penerangan Jalan Mati di Gang Kenanga 3',
                'category' => 'lampu_penerangan',
                'description' => 'Lampu jalan dekat tiang listrik no 4 padam sejak 2 hari lalu, kondisi jalan cukup gelap saat malam hari.',
                'photo_url' => 'https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?w=600',
                'location_lat' => -6.2091000,
                'location_lng' => 106.8462000,
                'location_address' => 'Gang Kenanga 3, RT 01 / RW 05',
                'status' => 'ditindak',
                'feedback_notes' => 'Petugas keamanan dan teknisi RT sudah membeli bohlam pengganti, akan dipasang sore ini.',
                'created_at' => now()->subDay(),
                'updated_at' => now()->subHours(3),
            ],
            [
                'user_id' => $warga2->id,
                'title' => 'Penumpukan Sampah Dekat TPS Sementara',
                'category' => 'sampah_tps',
                'description' => 'Sampah daun dan ranting bekas kerja bakti belum terangkut oleh truk kebersihan.',
                'photo_url' => 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600',
                'location_lat' => -6.2085000,
                'location_lng' => 106.8470000,
                'location_address' => 'Samping Pos Ronda RT 01',
                'status' => 'dilaporkan',
                'feedback_notes' => null,
                'created_at' => now()->subHours(4),
                'updated_at' => now()->subHours(4),
            ],
        ]);

        // 7. Kas & Transparansi Keuangan
        DB::table('treasury_transactions')->insert([
            [
                'transaction_date' => now()->subDays(10)->toDateString(),
                'type' => 'pemasukan',
                'category' => 'iuran_bulanan',
                'title' => 'Iuran Warga RT 01 Bulan Oktober (35 KK)',
                'description' => 'Penerimaan iuran bulanan kebersihan & keamanan warga',
                'amount' => 1750000.00,
                'proof_receipt_url' => null,
                'recorded_by' => $admin->id,
                'created_at' => now()->subDays(10),
                'updated_at' => now()->subDays(10),
            ],
            [
                'transaction_date' => now()->subDays(5)->toDateString(),
                'type' => 'pengeluaran',
                'category' => 'operasional',
                'title' => 'Honor Petugas Kebersihan & Sampah',
                'description' => 'Pembayaran gaji 2 orang petugas pengangkut sampah lingkungan',
                'amount' => 700000.00,
                'proof_receipt_url' => null,
                'recorded_by' => $admin->id,
                'created_at' => now()->subDays(5),
                'updated_at' => now()->subDays(5),
            ],
            [
                'transaction_date' => now()->subDays(2)->toDateString(),
                'type' => 'pengeluaran',
                'category' => 'operasional',
                'title' => 'Pembelian Lampu LED & Konsumsi Kerja Bakti',
                'description' => 'Beli 3 unit lampu LED jalan dan snack kerja bakti warga',
                'amount' => 285000.00,
                'proof_receipt_url' => null,
                'recorded_by' => $admin->id,
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ],
            [
                'transaction_date' => now()->subDay()->toDateString(),
                'type' => 'pemasukan',
                'category' => 'donasi',
                'title' => 'Donasi Warga untuk Perbaikan Pos Ronda',
                'description' => 'Sumbangan sukarela hamba Allah untuk cat & perlengkapan pos ronda',
                'amount' => 500000.00,
                'proof_receipt_url' => null,
                'recorded_by' => $admin->id,
                'created_at' => now()->subDay(),
                'updated_at' => now()->subDay(),
            ],
        ]);
    }
}
