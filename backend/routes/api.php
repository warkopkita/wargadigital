<?php

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Str;

/*
|--------------------------------------------------------------------------
| Warga Digital API Routes
|--------------------------------------------------------------------------
*/

// --- 1. Autentikasi & Registrasi ---
Route::post('/register', function (Request $request) {
    $validated = $request->validate([
        'nik' => 'required|string|size:16|unique:users,nik',
        'name' => 'required|string|max:100',
        'phone' => 'required|string|max:20|unique:users,phone',
        'email' => 'nullable|string|email|max:100|unique:users,email',
        'password' => 'required|string|min:6',
        'rt' => 'nullable|string|max:5',
        'rw' => 'nullable|string|max:5',
        'address' => 'nullable|string',
        'occupation' => 'nullable|string',
    ]);

    $user = User::create([
        'nik' => $validated['nik'],
        'name' => $validated['name'],
        'phone' => $validated['phone'],
        'email' => $request->input('email') ?? null,
        'password' => Hash::make($validated['password']),
        'role' => 'warga',
        'rt' => $validated['rt'] ?? '001',
        'rw' => $validated['rw'] ?? '005',
        'address' => $validated['address'] ?? null,
        'occupation' => $validated['occupation'] ?? null,
        'status' => 'pending', // Menunggu persetujuan RT/RW
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Pendaftaran berhasil! Akun Anda sedang menunggu verifikasi dan persetujuan Ketua RT/RW.',
        'data' => [
            'id' => $user->id,
            'nik' => $user->nik,
            'name' => $user->name,
            'status' => $user->status,
        ],
    ], 201);
});

Route::get('/demo-accounts', function () {
    return response()->json([
        'success' => true,
        'data' => [
            [
                'role' => 'warga',
                'label' => 'Warga (Budi Santoso)',
                'description' => 'Layanan surat, bayar kas QRIS, laporan & aduan',
                'nik' => '3201010202950003',
                'password' => 'password123',
                'badge_color' => '#16a34a',
                'icon' => 'person',
            ],
            [
                'role' => 'rt',
                'label' => 'Ketua RT 001 (Bambang Sudarmono)',
                'description' => 'Persetujuan warga, ttd surat digital, rekap desa',
                'nik' => '3201010101900001',
                'password' => 'password123',
                'badge_color' => '#0b4626',
                'icon' => 'shield',
            ],
            [
                'role' => 'bendahara',
                'label' => 'Bendahara Kas (Siti Rahmawati)',
                'description' => 'Verifikasi transfer QRIS, buku kas RT, ekspor kuitansi',
                'nik' => 'bendahara',
                'password' => 'password123',
                'badge_color' => '#ea580c',
                'icon' => 'account_balance_wallet',
            ],
            [
                'role' => 'linmas',
                'label' => 'Linmas / Keamanan (Pak Sutrisno)',
                'description' => 'Absensi pos ronda GPS, pantau sinyal darurat',
                'nik' => 'linmas',
                'password' => 'password123',
                'badge_color' => '#2563eb',
                'icon' => 'security',
            ],
            [
                'role' => 'posyandu',
                'label' => 'Kader Posyandu (Bidan Dewi)',
                'description' => 'Jadwal penimbangan & imunisasi balita',
                'nik' => 'posyandu',
                'password' => 'password123',
                'badge_color' => '#db2777',
                'icon' => 'favorite',
            ],
        ],
    ]);
});

Route::post('/login', function (Request $request) {
    // Terima berbagai format parameter: nik, identifier, email, phone, whatsapp, username
    $rawIdentifier = $request->input('nik') 
        ?? $request->input('identifier') 
        ?? $request->input('login') 
        ?? $request->input('email') 
        ?? $request->input('phone') 
        ?? $request->input('whatsapp') 
        ?? $request->input('username');

    if (empty($rawIdentifier)) {
        return response()->json([
            'success' => false,
            'message' => 'NIK, No. WhatsApp, atau Gmail wajib diisi.',
        ], 422);
    }

    if (empty($request->password)) {
        return response()->json([
            'success' => false,
            'message' => 'Kata sandi wajib diisi.',
        ], 422);
    }

    $loginIdentifier = strtolower(trim((string)$rawIdentifier));

    // Siapkan kemungkinan variasi format nomor WhatsApp / HP
    $digitsOnly = preg_replace('/[^0-9]/', '', $loginIdentifier);
    $phoneVariants = array_unique(array_filter([
        $rawIdentifier,
        $loginIdentifier,
        $digitsOnly,
        preg_replace('/^62/', '0', $digitsOnly),
        preg_replace('/^0/', '62', $digitsOnly),
        preg_replace('/^\+?62/', '0', $loginIdentifier),
    ]));

    // Cari berdasarkan NIK, Phone/WhatsApp, Email/Gmail, atau Role
    $query = User::where(function ($q) use ($rawIdentifier, $loginIdentifier, $phoneVariants) {
        $q->where('nik', $rawIdentifier)
          ->orWhereRaw('LOWER(email) = ?', [$loginIdentifier]);

        foreach ($phoneVariants as $pv) {
            if (!empty($pv) && strlen($pv) >= 8) {
                $q->orWhere('phone', $pv);
            }
        }

        if (in_array($loginIdentifier, ['warga', 'rt', 'rw', 'bendahara', 'linmas', 'posyandu'])) {
            $q->orWhere('role', $loginIdentifier);
        }
    });

    $user = $query->first();

    // Auto-create jika akun role demo belum ada di DB
    if (!$user && in_array($loginIdentifier, ['bendahara', 'linmas', 'posyandu', 'rt', 'warga'])) {
        $roleNames = [
            'bendahara' => 'Siti Rahmawati (Bendahara RT 001)',
            'linmas' => 'Sutrisno (Komandan Linmas RT)',
            'posyandu' => 'Dewi Lestari (Kader Posyandu Melati)',
            'rt' => 'Bambang Sudarmono (Ketua RT 001)',
            'warga' => 'Budi Santoso',
        ];
        $user = User::create([
            'nik' => '320101' . rand(1000000000, 9999999999),
            'name' => $roleNames[$loginIdentifier] ?? ucfirst($loginIdentifier),
            'phone' => '0812' . rand(10000000, 99999999),
            'email' => $loginIdentifier . '@wargadigital.id',
            'password' => Hash::make('password123'),
            'role' => $loginIdentifier,
            'rt' => '001',
            'rw' => '005',
            'address' => 'RT 001 / RW 005',
            'occupation' => ucfirst($loginIdentifier),
            'status' => 'approved',
            'approved_at' => now(),
        ]);
    }

    // Bypass check untuk kemudahan demo jika password sama dengan 'password123' atau role name
    $isPasswordValid = false;
    if ($user) {
        $isPasswordValid = Hash::check($request->password, $user->password) ||
                           $request->password === 'password123' ||
                           $request->password === $user->role;
    }

    if (!$user || !$isPasswordValid) {
        return response()->json([
            'success' => false,
            'message' => 'NIK, No. WhatsApp, Gmail, atau kata sandi tidak sesuai.',
        ], 401);
    }

    if ($user->status === 'pending') {
        return response()->json([
            'success' => false,
            'is_pending' => true,
            'message' => 'Akun Anda masih dalam status Menunggu Persetujuan Ketua RT/RW setempat.',
            'user' => [
                'name' => $user->name,
                'nik' => $user->nik,
                'status' => $user->status,
            ],
        ], 403);
    }

    if ($user->status === 'rejected') {
        return response()->json([
            'success' => false,
            'message' => 'Pendaftaran akun Anda ditolak oleh pengurus RT. Silakan hubungi RT setempat.',
        ], 403);
    }

    // Token sederhana untuk autentikasi stateful/bearer
    $token = base64_encode($user->id . ':' . Str::random(32));

    return response()->json([
        'success' => true,
        'message' => 'Login berhasil.',
        'token' => $token,
        'user' => [
            'id' => $user->id,
            'nik' => $user->nik,
            'name' => $user->name,
            'phone' => $user->phone,
            'email' => $user->email,
            'role' => $user->role,
            'rt' => $user->rt,
            'rw' => $user->rw,
            'address' => $user->address,
            'occupation' => $user->occupation,
            'status' => $user->status,
        ],
    ]);
});

// --- 2. Statistik Dashboard ---
Route::get('/stats', function () {
    $totalCitizens = User::where('role', 'warga')->where('status', 'approved')->count();
    $pendingCitizens = User::where('status', 'pending')->count();
    $totalLetters = DB::table('letters')->count();
    $pendingLetters = DB::table('letters')->whereIn('status', ['diajukan', 'diproses_rt', 'diproses_rw'])->count();
    $activeComplaints = DB::table('complaints')->whereIn('status', ['dilaporkan', 'ditindak'])->count();
    
    $pemasukan = DB::table('treasury_transactions')->where('type', 'pemasukan')->sum('amount');
    $pengeluaran = DB::table('treasury_transactions')->where('type', 'pengeluaran')->sum('amount');
    $kasBalance = $pemasukan - $pengeluaran;

    return response()->json([
        'success' => true,
        'data' => [
            'total_citizens' => $totalCitizens,
            'pending_citizens' => $pendingCitizens,
            'total_letters' => $totalLetters,
            'pending_letters' => $pendingLetters,
            'active_complaints' => $activeComplaints,
            'treasury' => [
                'total_income' => (float)$pemasukan,
                'total_expense' => (float)$pengeluaran,
                'balance' => (float)$kasBalance,
            ],
        ],
    ]);
});

// --- 3. Manajemen Warga (Citizens) ---
Route::get('/citizens', function (Request $request) {
    $query = User::query()->orderBy('created_at', 'desc');

    if ($request->has('status')) {
        $query->where('status', $request->status);
    }
    if ($request->has('role')) {
        $query->where('role', $request->role);
    }
    if ($request->has('search')) {
        $search = $request->search;
        $query->where(function ($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('nik', 'like', "%{$search}%")
              ->orWhere('phone', 'like', "%{$search}%");
        });
    }

    $citizens = $query->get()->makeVisible(['address', 'occupation', 'status', 'approved_at']);

    return response()->json([
        'success' => true,
        'data' => $citizens,
    ]);
});

Route::get('/citizens/export', function () {
    $citizens = User::where('role', 'warga')->get();
    $csv = "NIK,Nama Lengkap,No WhatsApp,RT,RW,Pekerjaan,Alamat,Status\n";
    foreach ($citizens as $c) {
        $csv .= "\"{$c->nik}\",\"{$c->name}\",\"{$c->phone}\",\"{$c->rt}\",\"{$c->rw}\",\"{$c->occupation}\",\"{$c->address}\",\"{$c->status}\"\n";
    }
    return response($csv, 200, [
        'Content-Type' => 'text/csv; charset=utf-8',
        'Content-Disposition' => 'attachment; filename="data_warga_' . date('Y-m-d') . '.csv"',
    ]);
});

Route::post('/citizens/{id}/approve', function ($id, Request $request) {
    $user = User::findOrFail($id);
    $user->update([
        'status' => 'approved',
        'approved_by' => $request->admin_id ?? 1,
        'approved_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => "Akun warga {$user->name} berhasil disetujui.",
        'data' => $user,
    ]);
});

Route::post('/citizens/{id}/reject', function ($id) {
    $user = User::findOrFail($id);
    $user->update([
        'status' => 'rejected',
    ]);

    return response()->json([
        'success' => true,
        'message' => "Pendaftaran akun warga {$user->name} ditolak.",
        'data' => $user,
    ]);
});

// --- 4. Surat & Dokumen ---
Route::get('/letters', function (Request $request) {
    $query = DB::table('letters')
        ->join('users', 'letters.user_id', '=', 'users.id')
        ->select(
            'letters.*',
            'users.name as citizen_name',
            'users.nik as citizen_nik',
            'users.phone as citizen_phone',
            'users.rt as citizen_rt',
            'users.rw as citizen_rw',
            'users.address as citizen_address'
        )
        ->orderBy('letters.created_at', 'desc');

    if ($request->has('user_id')) {
        $query->where('letters.user_id', $request->user_id);
    }
    if ($request->has('status')) {
        $query->where('letters.status', $request->status);
    }

    $letters = $query->get()->map(function ($item) {
        $item->additional_data = json_decode($item->additional_data, true);
        return $item;
    });

    return response()->json([
        'success' => true,
        'data' => $letters,
    ]);
});

Route::post('/letters', function (Request $request) {
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
        'letter_type' => 'required|string',
        'purpose' => 'required|string',
        'additional_data' => 'nullable|array',
    ]);

    $id = DB::table('letters')->insertGetId([
        'user_id' => $validated['user_id'],
        'letter_type' => $validated['letter_type'],
        'purpose' => $validated['purpose'],
        'additional_data' => json_encode($validated['additional_data'] ?? []),
        'status' => 'diajukan',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    $letter = DB::table('letters')->where('id', $id)->first();

    return response()->json([
        'success' => true,
        'message' => 'Pengajuan surat berhasil dikirim ke pengurus RT.',
        'data' => $letter,
    ], 201);
});

Route::put('/letters/{id}/status', function ($id, Request $request) {
    $request->validate([
        'status' => 'required|in:diajukan,diproses_rt,diproses_rw,selesai,ditolak',
        'admin_notes' => 'nullable|string',
    ]);

    $updateData = [
        'status' => $request->status,
        'admin_notes' => $request->admin_notes,
        'updated_at' => now(),
    ];

    if ($request->status === 'selesai') {
        $hash = 'WD-VERIFIED-' . strtoupper(Str::random(12));
        $updateData['letter_number'] = '470/' . str_pad($id, 3, '0', STR_PAD_LEFT) . '/RT.01/' . date('Y');
        $updateData['qr_code_hash'] = $hash;
        $updateData['signed_by'] = $request->admin_id ?? 1;
        $updateData['signed_at'] = now();
    }

    DB::table('letters')->where('id', $id)->update($updateData);

    return response()->json([
        'success' => true,
        'message' => 'Status surat berhasil diperbarui.',
        'data' => DB::table('letters')->where('id', $id)->first(),
    ]);
});

// --- 5. SMART SISKAMLING: Jadwal Ronda, Tukar Shift, QR Checkpoint & Denda Kas ---
Route::get('/patrols', function () {
    $schedules = DB::table('patrol_schedules')
        ->orderBy('patrol_date', 'desc')
        ->get();

    $today = now()->toDateString();
    $totalHadir = 0;
    $totalIzin = 0;
    $totalAlpha = 0;
    $totalFines = 0;

    foreach ($schedules as $schedule) {
        $schedule->members = DB::table('patrol_members')
            ->join('users', 'patrol_members.user_id', '=', 'users.id')
            ->where('patrol_members.patrol_schedule_id', $schedule->id)
            ->select(
                'patrol_members.*',
                'users.name',
                'users.phone',
                'users.avatar_url',
                'users.address'
            )
            ->get();

        $schedule->checkpoints_count = DB::table('patrol_checkpoints')
            ->where('patrol_schedule_id', $schedule->id)
            ->count();

        foreach ($schedule->members as $m) {
            if ($m->has_checked_in || $m->status === 'hadir') $totalHadir++;
            if ($m->status === 'izin') $totalIzin++;
            if ($m->status === 'alpha') {
                $totalAlpha++;
                $totalFines += ($m->fine_amount ?? 0);
            }
        }
    }

    $recentCheckpoints = DB::table('patrol_checkpoints')
        ->join('users', 'patrol_checkpoints.user_id', '=', 'users.id')
        ->select('patrol_checkpoints.*', 'users.name as officer_name', 'users.phone as officer_phone')
        ->orderBy('scanned_at', 'desc')
        ->limit(15)
        ->get();

    $pendingSwaps = DB::table('patrol_swaps')
        ->join('users as req_user', 'patrol_swaps.requester_user_id', '=', 'req_user.id')
        ->leftJoin('users as tgt_user', 'patrol_swaps.target_user_id', '=', 'tgt_user.id')
        ->join('patrol_schedules', 'patrol_swaps.patrol_schedule_id', '=', 'patrol_schedules.id')
        ->select(
            'patrol_swaps.*',
            'req_user.name as requester_name',
            'req_user.phone as requester_phone',
            'tgt_user.name as target_name',
            'patrol_schedules.day_name',
            'patrol_schedules.patrol_date',
            'patrol_schedules.shift_name'
        )
        ->orderBy('patrol_swaps.created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $schedules,
        'recent_checkpoints' => $recentCheckpoints,
        'swap_requests' => $pendingSwaps,
        'summary' => [
            'total_schedules' => count($schedules),
            'total_hadir' => $totalHadir,
            'total_izin' => $totalIzin,
            'total_alpha' => $totalAlpha,
            'total_fines' => $totalFines,
            'total_checkpoints_scanned' => DB::table('patrol_checkpoints')->count(),
        ]
    ]);
});

// Admin Tambah Jadwal Ronda Baru
Route::post('/patrols/schedule', function (Request $request) {
    $validated = $request->validate([
        'patrol_date' => 'required|date',
        'day_name' => 'required|string',
        'shift_name' => 'required|string',
        'rt' => 'nullable|string|max:5',
        'rw' => 'nullable|string|max:5',
        'notes' => 'nullable|string',
        'member_ids' => 'required|array',
        'member_ids.*' => 'exists:users,id',
    ]);

    $scheduleId = DB::table('patrol_schedules')->insertGetId([
        'patrol_date' => $validated['patrol_date'],
        'day_name' => $validated['day_name'],
        'shift_name' => $validated['shift_name'],
        'rt' => $validated['rt'] ?? '001',
        'rw' => $validated['rw'] ?? '005',
        'notes' => $validated['notes'] ?? 'Patroli gang lingkungan & portal barat/timur',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    foreach ($validated['member_ids'] as $userId) {
        DB::table('patrol_members')->insert([
            'patrol_schedule_id' => $scheduleId,
            'user_id' => $userId,
            'status' => 'terjadwal',
            'has_checked_in' => false,
            'fine_amount' => 0,
            'fine_paid' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    return response()->json([
        'success' => true,
        'message' => 'Jadwal ronda baru berhasil diterbitkan!',
        'schedule_id' => $scheduleId,
    ]);
});

// Hapus Jadwal Ronda
Route::delete('/patrols/schedule/{id}', function ($id) {
    DB::table('patrol_members')->where('patrol_schedule_id', $id)->delete();
    DB::table('patrol_checkpoints')->where('patrol_schedule_id', $id)->delete();
    DB::table('patrol_swaps')->where('patrol_schedule_id', $id)->delete();
    DB::table('patrol_schedules')->where('id', $id)->delete();

    return response()->json([
        'success' => true,
        'message' => 'Jadwal ronda berhasil dihapus.',
    ]);
});

// Auto-Generate Jadwal Ronda Mingguan Otomatis
Route::post('/patrols/auto-generate', function (Request $request) {
    $rt = $request->input('rt', '001');
    $rw = $request->input('rw', '005');

    // Ambil warga berstatus aktif
    $citizens = User::where('status', 'active')
        ->where('role', 'warga')
        ->get();

    if ($citizens->count() < 3) {
        $citizens = User::where('status', 'active')->get();
    }

    $days = [
        ['day' => 'Senin', 'offset' => 0],
        ['day' => 'Selasa', 'offset' => 1],
        ['day' => 'Rabu', 'offset' => 2],
        ['day' => 'Kamis', 'offset' => 3],
        ['day' => 'Jumat', 'offset' => 4],
        ['day' => 'Sabtu', 'offset' => 5],
        ['day' => 'Minggu', 'offset' => 6],
    ];

    $createdCount = 0;
    $chunkSize = max(2, (int) ceil($citizens->count() / 7));
    $shuffledCitizens = $citizens->shuffle();
    $today = now();

    foreach ($days as $i => $item) {
        $date = $today->copy()->addDays($item['offset'])->toDateString();
        $sliceStart = ($i * 2) % max(1, $shuffledCitizens->count());
        $assignedMembers = $shuffledCitizens->slice($sliceStart, $chunkSize);
        if ($assignedMembers->isEmpty()) {
            $assignedMembers = $shuffledCitizens->take(2);
        }

        $scheduleId = DB::table('patrol_schedules')->insertGetId([
            'patrol_date' => $date,
            'day_name' => $item['day'],
            'shift_name' => 'Malam Regu ' . ($i + 1) . ' (22:00 - 04:00)',
            'rt' => $rt,
            'rw' => $rw,
            'notes' => 'Patroli keliling gang 1-4 & scan QR pos ronda',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        foreach ($assignedMembers as $c) {
            DB::table('patrol_members')->insert([
                'patrol_schedule_id' => $scheduleId,
                'user_id' => $c->id,
                'status' => 'terjadwal',
                'has_checked_in' => false,
                'fine_amount' => 0,
                'fine_paid' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
        $createdCount++;
    }

    return response()->json([
        'success' => true,
        'message' => "Berhasil menghasilkan {$createdCount} jadwal ronda mingguan otomatis!",
    ]);
});

// Check-in GPS Petugas Ronda
Route::post('/patrols/check-in', function (Request $request) {
    $request->validate([
        'schedule_id' => 'required|exists:patrol_schedules,id',
        'user_id' => 'required|exists:users,id',
        'lat' => 'required|numeric',
        'lng' => 'required|numeric',
        'note' => 'nullable|string',
    ]);

    $member = DB::table('patrol_members')
        ->where('patrol_schedule_id', $request->schedule_id)
        ->where('user_id', $request->user_id)
        ->first();

    if ($member) {
        DB::table('patrol_members')->where('id', $member->id)->update([
            'has_checked_in' => true,
            'status' => 'hadir',
            'checked_in_at' => now(),
            'check_in_lat' => $request->lat,
            'check_in_lng' => $request->lng,
            'check_in_note' => $request->note ?? 'Hadir tepat waktu di pos siskamling',
            'updated_at' => now(),
        ]);
    } else {
        DB::table('patrol_members')->insert([
            'patrol_schedule_id' => $request->schedule_id,
            'user_id' => $request->user_id,
            'has_checked_in' => true,
            'status' => 'hadir',
            'checked_in_at' => now(),
            'check_in_lat' => $request->lat,
            'check_in_lng' => $request->lng,
            'check_in_note' => $request->note ?? 'Hadir ronda siskamling',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    return response()->json([
        'success' => true,
        'message' => 'Presensi ronda GPS berhasil diverifikasi! Lokasi Anda telah tercatat di dashboard RT.',
    ]);
});

// Pengajuan Tukar Jadwal / Izin Tidak Hadir (Dari Aplikasi Warga Mobile)
Route::post('/patrols/swap-request', function (Request $request) {
    $validated = $request->validate([
        'schedule_id' => 'required|exists:patrol_schedules,id',
        'requester_user_id' => 'required|exists:users,id',
        'target_user_id' => 'nullable|exists:users,id',
        'type' => 'required|in:tukar_jadwal,izin_tidak_hadir',
        'reason' => 'required|string|min:5',
    ]);

    $swapId = DB::table('patrol_swaps')->insertGetId([
        'patrol_schedule_id' => $validated['schedule_id'],
        'requester_user_id' => $validated['requester_user_id'],
        'target_user_id' => $validated['target_user_id'] ?? null,
        'type' => $validated['type'],
        'reason' => $validated['reason'],
        'status' => 'pending',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => ($validated['type'] === 'izin_tidak_hadir')
            ? 'Permohonan izin tidak hadir ronda berhasil dikirim ke pengurus RT.'
            : 'Permohonan tukar jadwal ronda berhasil dikirim, menunggu verifikasi pengurus.',
        'data' => ['id' => $swapId]
    ]);
});

// Daftar Pengajuan Tukar Jadwal & Izin
Route::get('/patrols/swap-requests', function () {
    $swaps = DB::table('patrol_swaps')
        ->join('users as req_user', 'patrol_swaps.requester_user_id', '=', 'req_user.id')
        ->leftJoin('users as tgt_user', 'patrol_swaps.target_user_id', '=', 'tgt_user.id')
        ->join('patrol_schedules', 'patrol_swaps.patrol_schedule_id', '=', 'patrol_schedules.id')
        ->select(
            'patrol_swaps.*',
            'req_user.name as requester_name',
            'req_user.phone as requester_phone',
            'tgt_user.name as target_name',
            'patrol_schedules.day_name',
            'patrol_schedules.patrol_date',
            'patrol_schedules.shift_name'
        )
        ->orderBy('patrol_swaps.created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $swaps,
    ]);
});

// Admin Review Permohonan Tukar Jadwal / Izin (Setujui / Tolak)
Route::post('/patrols/swap-requests/{id}/review', function ($id, Request $request) {
    $validated = $request->validate([
        'status' => 'required|in:approved,rejected',
        'admin_notes' => 'nullable|string',
        'reviewed_by' => 'nullable|exists:users,id',
    ]);

    $swap = DB::table('patrol_swaps')->where('id', $id)->first();
    if (!$swap) {
        return response()->json(['success' => false, 'message' => 'Pengajuan tidak ditemukan.'], 404);
    }

    DB::table('patrol_swaps')->where('id', $id)->update([
        'status' => $validated['status'],
        'admin_notes' => $validated['admin_notes'] ?? null,
        'reviewed_by' => $validated['reviewed_by'] ?? null,
        'reviewed_at' => now(),
        'updated_at' => now(),
    ]);

    if ($validated['status'] === 'approved') {
        if ($swap->type === 'izin_tidak_hadir') {
            DB::table('patrol_members')
                ->where('patrol_schedule_id', $swap->patrol_schedule_id)
                ->where('user_id', $swap->requester_user_id)
                ->update([
                    'status' => 'izin',
                    'notes' => 'Izin disetujui: ' . $swap->reason,
                    'updated_at' => now(),
                ]);
        } elseif ($swap->type === 'tukar_jadwal' && $swap->target_user_id) {
            DB::table('patrol_members')
                ->where('patrol_schedule_id', $swap->patrol_schedule_id)
                ->where('user_id', $swap->requester_user_id)
                ->update([
                    'user_id' => $swap->target_user_id,
                    'status' => 'tukar',
                    'notes' => 'Pengganti tukar jadwal',
                    'updated_at' => now(),
                ]);
        }
    }

    return response()->json([
        'success' => true,
        'message' => ($validated['status'] === 'approved')
            ? 'Pengajuan berhasil disetujui dan jadwal telah diperbarui.'
            : 'Pengajuan telah ditolak.',
    ]);
});

// Master Data Titik Checkpoint Patroli
Route::get('/patrols/master-checkpoints', function () {
    $checkpoints = [
        [
            'code' => 'POS-RONDA-01',
            'name' => 'Pos Ronda Utama RT 001',
            'type' => 'Pos Induk',
            'lat' => -6.2087634,
            'lng' => 106.8455990,
            'description' => 'Posko pusat linmas dan koordinasi keamanan lingkungan.',
            'qr_token' => 'CHECKPOINT:POS-RONDA-01'
        ],
        [
            'code' => 'PORTAL-BARAT-01',
            'name' => 'Portal Barat Gang Kenanga',
            'type' => 'Portal Pembatas',
            'lat' => -6.2091200,
            'lng' => 106.8449000,
            'description' => 'Akses keluar masuk kendaraan gang barat. Wajib digembok pukul 23:00 WIB.',
            'qr_token' => 'CHECKPOINT:PORTAL-BARAT-01'
        ],
        [
            'code' => 'GARDU-TIMUR-01',
            'name' => 'Gardu Timur Jalur Hijau',
            'type' => 'Gardu Pantau',
            'lat' => -6.2084500,
            'lng' => 106.8462000,
            'description' => 'Pemantauan lampu penerangan jalan dan area parkir motor warga.',
            'qr_token' => 'CHECKPOINT:GARDU-TIMUR-01'
        ]
    ];

    return response()->json([
        'success' => true,
        'data' => $checkpoints,
    ]);
});

// Scan QR Checkpoint & Laporan Situasi Lapangan (Mobile / Web)
Route::post('/patrols/checkpoint-scan', function (Request $request) {
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
        'checkpoint_code' => 'required|string',
        'checkpoint_name' => 'nullable|string',
        'situation_status' => 'required|string',
        'notes' => 'nullable|string',
        'photo_url' => 'nullable|string',
        'location_lat' => 'nullable|numeric',
        'location_lng' => 'nullable|numeric',
        'schedule_id' => 'nullable|exists:patrol_schedules,id',
    ]);

    $checkpointNames = [
        'POS-RONDA-01' => 'Pos Ronda Utama RT 001',
        'PORTAL-BARAT-01' => 'Portal Barat Gang Kenanga',
        'GARDU-TIMUR-01' => 'Gardu Timur Jalur Hijau',
    ];

    $name = $validated['checkpoint_name']
        ?? ($checkpointNames[$validated['checkpoint_code']] ?? 'Pos Ronda Lingkungan');

    $id = DB::table('patrol_checkpoints')->insertGetId([
        'patrol_schedule_id' => $validated['schedule_id'] ?? null,
        'user_id' => $validated['user_id'],
        'checkpoint_code' => $validated['checkpoint_code'],
        'checkpoint_name' => $name,
        'scanned_at' => now(),
        'situation_status' => $validated['situation_status'],
        'notes' => $validated['notes'] ?? 'Kondisi lingkungan dipantau aman.',
        'photo_url' => $validated['photo_url'] ?? 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500',
        'location_lat' => $validated['location_lat'] ?? -6.2087634,
        'location_lng' => $validated['location_lng'] ?? 106.8455990,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => "Checkpoint {$name} berhasil diverifikasi! Laporan situasi tersimpan di dashboard RT.",
        'checkpoint_id' => $id,
    ]);
});

// Log Checkpoint Patroli
Route::get('/patrols/checkpoints', function () {
    $logs = DB::table('patrol_checkpoints')
        ->join('users', 'patrol_checkpoints.user_id', '=', 'users.id')
        ->select('patrol_checkpoints.*', 'users.name as officer_name', 'users.phone as officer_phone')
        ->orderBy('scanned_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $logs,
    ]);
});

// Sanksi Denda Ronda Masuk Kas RT
Route::post('/patrols/apply-fine', function (Request $request) {
    $validated = $request->validate([
        'schedule_id' => 'required|exists:patrol_schedules,id',
        'user_id' => 'required|exists:users,id',
        'amount' => 'required|numeric|min:1000',
        'reason' => 'nullable|string',
    ]);

    $schedule = DB::table('patrol_schedules')->where('id', $validated['schedule_id'])->first();
    $user = User::find($validated['user_id']);

    if (!$schedule || !$user) {
        return response()->json(['success' => false, 'message' => 'Data jadwal atau warga tidak valid.'], 404);
    }

    // Update status anggota ronda menjadi alpha dengan denda
    DB::table('patrol_members')
        ->where('patrol_schedule_id', $schedule->id)
        ->where('user_id', $user->id)
        ->update([
            'status' => 'alpha',
            'fine_amount' => $validated['amount'],
            'fine_paid' => false,
            'notes' => 'Sanksi denda ketidakhadiran: ' . ($validated['reason'] ?? 'Alpha tanpa keterangan'),
            'updated_at' => now(),
        ]);

    // Terbitkan tagihan kas RT otomatis
    $billId = DB::table('dues_bills')->insertGetId([
        'user_id' => $user->id,
        'title' => "Denda Ronda Malam ({$schedule->day_name}, {$schedule->patrol_date})",
        'month' => now()->translatedFormat('F'),
        'year' => now()->year,
        'amount' => $validated['amount'],
        'status' => 'menunggu_bayar',
        'notes' => 'Sanksi ketidakhadiran ronda malam siskamling tanpa izin resmi. ' . ($validated['reason'] ?? ''),
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => "Sanksi denda Rp " . number_format($validated['amount'], 0, ',', '.') . " untuk {$user->name} berhasil diterapkan dan masuk ke tagihan Kas RT!",
        'bill_id' => $billId,
    ]);
});

// Pembayaran Denda Ronda Langsung Disetor ke Kas RT
Route::post('/patrols/pay-fine', function (Request $request) {
    $validated = $request->validate([
        'schedule_id' => 'required|exists:patrol_schedules,id',
        'user_id' => 'required|exists:users,id',
        'amount' => 'required|numeric',
        'admin_id' => 'nullable|exists:users,id',
    ]);

    $user = User::find($validated['user_id']);
    $schedule = DB::table('patrol_schedules')->where('id', $validated['schedule_id'])->first();

    DB::table('patrol_members')
        ->where('patrol_schedule_id', $validated['schedule_id'])
        ->where('user_id', $validated['user_id'])
        ->update([
            'fine_paid' => true,
            'notes' => 'Denda lunas disetor ke Kas RT pada ' . now()->format('d/m/Y H:i'),
            'updated_at' => now(),
        ]);

    // Catat ke transaksi pembukuan kas RT
    $adminId = $validated['admin_id'] ?? User::where('role', 'admin')->value('id') ?? $validated['user_id'];
    DB::table('treasury_transactions')->insert([
        'transaction_date' => now()->toDateString(),
        'type' => 'pemasukan',
        'category' => 'operasional',
        'title' => "Penerimaan Denda Ronda — {$user->name} ({$schedule->day_name})",
        'description' => "Uang kompensasi/denda ketidakhadiran ronda siskamling RT 001.",
        'amount' => $validated['amount'],
        'proof_receipt_url' => null,
        'recorded_by' => $adminId,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => "Pembayaran denda {$user->name} sebesar Rp " . number_format($validated['amount'], 0, ',', '.') . " berhasil dicatat masuk ke Kas RT!",
    ]);
});


// --- 6. Posyandu & Tumbuh Kembang ---
if (!Schema::hasColumn('posyandu_activities', 'status')) {
    Schema::table('posyandu_activities', function ($table) {
        $table->string('status', 30)->default('scheduled');
        $table->text('postponed_reason')->nullable();
        $table->date('rescheduled_date')->nullable();
        $table->string('cadre_name')->nullable();
    });
}

Route::get('/posyandu', function () {
    $activities = DB::table('posyandu_activities')->orderBy('activity_date', 'asc')->get();
    $children = DB::table('child_records')->orderBy('created_at', 'desc')->get();

    return response()->json([
        'success' => true,
        'data' => [
            'activities' => $activities,
            'children' => $children,
        ],
    ]);
});

Route::post('/posyandu/activity', function (Request $request) {
    $validated = $request->validate([
        'title' => 'required|string|max:255',
        'activity_date' => 'required|date',
        'location' => 'required|string|max:255',
        'description' => 'nullable|string',
        'cadre_name' => 'nullable|string',
    ]);

    $id = DB::table('posyandu_activities')->insertGetId([
        'title' => $validated['title'],
        'activity_date' => $validated['activity_date'],
        'location' => $validated['location'],
        'rt' => '001',
        'description' => $validated['description'] ?? '',
        'status' => 'scheduled',
        'cadre_name' => $validated['cadre_name'] ?? 'Dewi Lestari (Kader Posyandu)',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Jadwal kegiatan Posyandu berhasil dibuat dan dipublikasikan.',
        'data' => DB::table('posyandu_activities')->where('id', $id)->first(),
    ], 201);
});

Route::put('/posyandu/activity/{id}', function (Request $request, $id) {
    $validated = $request->validate([
        'title' => 'sometimes|required|string|max:255',
        'activity_date' => 'sometimes|required|date',
        'location' => 'sometimes|required|string|max:255',
        'description' => 'nullable|string',
        'status' => 'nullable|string',
        'postponed_reason' => 'nullable|string',
        'rescheduled_date' => 'nullable|date',
    ]);

    $validated['updated_at'] = now();
    DB::table('posyandu_activities')->where('id', $id)->update($validated);

    return response()->json([
        'success' => true,
        'message' => 'Jadwal Posyandu berhasil diperbarui.',
        'data' => DB::table('posyandu_activities')->where('id', $id)->first(),
    ]);
});

// Penundaan / Libur Mendadak Posyandu + Otomatis Terbitkan Kabar Kampung + Siapkan Format WA
Route::post('/posyandu/activity/{id}/postpone', function (Request $request, $id) {
    $activity = DB::table('posyandu_activities')->where('id', $id)->first();
    if (!$activity) {
        return response()->json(['success' => false, 'message' => 'Kegiatan tidak ditemukan'], 404);
    }

    $reason = $request->input('reason', 'Libur mendadak dikarenakan kondisi darurat / dinas luar kader.');
    $rescheduledDate = $request->input('rescheduled_date', null);

    DB::table('posyandu_activities')->where('id', $id)->update([
        'status' => 'postponed',
        'postponed_reason' => $reason,
        'rescheduled_date' => $rescheduledDate,
        'updated_at' => now(),
    ]);

    // Otomatis terbitkan pengumuman darurat di Kabar Kampung
    $announcementTitle = "⚠️ PEMBERITAHUAN: " . $activity->title . " DITUNDA / LIBUR";
    $announcementContent = "Diberitahukan kepada seluruh warga RT 001/RW 005 khususnya ibu-ibu balita, kegiatan Posyandu yang semula dijadwalkan pada {$activity->activity_date} di {$activity->location} DITUNDA / DILIBURKAN.\n\nAlasan: {$reason}" . ($rescheduledDate ? "\nJadwal Pengganti: {$rescheduledDate}" : "\nJadwal baru akan diumumkan kembali.") . "\n\nMohon maaf atas ketidaknyamanannya. Terima kasih atas pengertiannya 🙏\n- Kader Posyandu Melati & Pengurus RT";

    DB::table('news_posts')->insert([
        'title' => $announcementTitle,
        'slug' => 'posyandu-ditunda-' . time() . '-' . \Illuminate\Support\Str::random(4),
        'category' => 'Posyandu',
        'content' => $announcementContent,
        'author_id' => 1,
        'is_pinned' => true,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Kegiatan Posyandu berhasil ditandai Libur Mendadak dan pengumuman otomatis diterbitkan ke Kabar Kampung!',
        'whatsapp_broadcast_text' => "*📢 PEMBERITAHUAN PENUNDAAN POSYANDU MELATI RT 001*\n\nKegiatan: *{$activity->title}*\nSemula: {$activity->activity_date} di {$activity->location}\n\n⚠️ *STATUS: DITUNDA / LIBUR MENDADAK*\nAlasan: {$reason}\n" . ($rescheduledDate ? "Jadwal Pengganti: *{$rescheduledDate}*\n" : "Jadwal pengganti akan diinfokan segera.\n") . "\nMohon maaf atas ketidaknyamanan ini 🙏\n- Kader Posyandu & Pengurus RT",
    ]);
});

Route::delete('/posyandu/activity/{id}', function ($id) {
    DB::table('posyandu_activities')->where('id', $id)->delete();
    return response()->json([
        'success' => true,
        'message' => 'Jadwal Posyandu berhasil dihapus.',
    ]);
});

Route::post('/posyandu/record', function (Request $request) {
    $validated = $request->validate([
        'child_name' => 'required|string',
        'gender' => 'required|in:L,P',
        'birth_date' => 'required|date',
        'weight_kg' => 'required|numeric',
        'height_cm' => 'required|numeric',
        'head_circumference_cm' => 'nullable|numeric',
        'immunization_type' => 'nullable|string',
        'cadre_notes' => 'nullable|string',
    ]);

    $id = DB::table('child_records')->insertGetId(array_merge($validated, [
        'recorded_date' => now()->toDateString(),
        'created_at' => now(),
        'updated_at' => now(),
    ]));

    return response()->json([
        'success' => true,
        'message' => 'Data catatan tumbuh kembang anak berhasil disimpan.',
        'data' => DB::table('child_records')->where('id', $id)->first(),
    ], 201);
});

// --- 7. Aduan Warga & TPS Lingkungan ---
Route::get('/complaints', function () {
    $complaints = DB::table('complaints')
        ->join('users', 'complaints.user_id', '=', 'users.id')
        ->select('complaints.*', 'users.name as reporter_name', 'users.phone as reporter_phone')
        ->orderBy('complaints.created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $complaints,
    ]);
});

Route::post('/complaints', function (Request $request) {
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
        'title' => 'required|string|max:150',
        'category' => 'required|string',
        'description' => 'required|string',
        'photo_url' => 'nullable|string',
        'location_lat' => 'nullable|numeric',
        'location_lng' => 'nullable|numeric',
        'location_address' => 'nullable|string',
    ]);

    $id = DB::table('complaints')->insertGetId(array_merge($validated, [
        'status' => 'dilaporkan',
        'created_at' => now(),
        'updated_at' => now(),
    ]));

    return response()->json([
        'success' => true,
        'message' => 'Laporan aduan warga berhasil diterima dan segera ditinjau oleh pengurus.',
        'data' => DB::table('complaints')->where('id', $id)->first(),
    ], 201);
});

Route::put('/complaints/{id}/status', function ($id, Request $request) {
    $request->validate([
        'status' => 'required|in:dilaporkan,ditindak,selesai',
        'feedback_notes' => 'nullable|string',
    ]);

    DB::table('complaints')->where('id', $id)->update([
        'status' => $request->status,
        'feedback_notes' => $request->feedback_notes,
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Status aduan berhasil diperbarui.',
        'data' => DB::table('complaints')->where('id', $id)->first(),
    ]);
});

// --- 8. Dana & Transparansi Kas ---
Route::get('/treasury', function () {
    $transactions = DB::table('treasury_transactions')
        ->join('users', 'treasury_transactions.recorded_by', '=', 'users.id')
        ->select('treasury_transactions.*', 'users.name as recorder_name')
        ->orderBy('transaction_date', 'desc')
        ->get();

    $totalPemasukan = (float)DB::table('treasury_transactions')->where('type', 'pemasukan')->sum('amount');
    $totalPengeluaran = (float)DB::table('treasury_transactions')->where('type', 'pengeluaran')->sum('amount');

    // Category labels and colors
    $catLabels = [
        'iuran_bulanan' => ['label' => 'Iuran Kas Bulanan', 'color' => '#16a34a', 'icon' => 'Coins'],
        'donasi' => ['label' => 'Sumbangan / Donasi Warga', 'color' => '#0284c7', 'icon' => 'HeartHandshake'],
        'denda_ronda' => ['label' => 'Denda Siskamling / Ronda', 'color' => '#ea580c', 'icon' => 'ShieldAlert'],
        'operasional' => ['label' => 'Operasional & Perlengkapan', 'color' => '#64748b', 'icon' => 'Wrench'],
        'kebersihan' => ['label' => 'Kebersihan & Sampah', 'color' => '#059669', 'icon' => 'Trash2'],
        'keamanan' => ['label' => 'Keamanan & Pos Ronda', 'color' => '#2563eb', 'icon' => 'Shield'],
        'penerangan' => ['label' => 'Penerangan Jalan & Fasum', 'color' => '#d97706', 'icon' => 'Lightbulb'],
        'kegiatan_warga' => ['label' => 'Kegiatan Warga / Agustusan', 'color' => '#db2777', 'icon' => 'Users'],
        'sosial' => ['label' => 'Santunan Sosial & Takziyah', 'color' => '#7c3aed', 'icon' => 'Heart'],
    ];

    $incomeBreakdown = DB::table('treasury_transactions')
        ->where('type', 'pemasukan')
        ->select('category', DB::raw('SUM(amount) as total'), DB::raw('COUNT(*) as count'))
        ->groupBy('category')
        ->get()
        ->map(function ($item) use ($totalPemasukan, $catLabels) {
            $cat = $item->category;
            $meta = $catLabels[$cat] ?? ['label' => ucfirst(str_replace('_', ' ', $cat)), 'color' => '#16a34a', 'icon' => 'Coins'];
            $total = (float)$item->total;
            return [
                'category' => $cat,
                'label' => $meta['label'],
                'color' => $meta['color'],
                'icon' => $meta['icon'],
                'total' => $total,
                'count' => $item->count,
                'percentage' => $totalPemasukan > 0 ? round(($total / $totalPemasukan) * 100, 1) : 0,
            ];
        });

    $expenseBreakdown = DB::table('treasury_transactions')
        ->where('type', 'pengeluaran')
        ->select('category', DB::raw('SUM(amount) as total'), DB::raw('COUNT(*) as count'))
        ->groupBy('category')
        ->get()
        ->map(function ($item) use ($totalPengeluaran, $catLabels) {
            $cat = $item->category;
            $meta = $catLabels[$cat] ?? ['label' => ucfirst(str_replace('_', ' ', $cat)), 'color' => '#dc2626', 'icon' => 'Coins'];
            $total = (float)$item->total;
            return [
                'category' => $cat,
                'label' => $meta['label'],
                'color' => $meta['color'],
                'icon' => $meta['icon'],
                'total' => $total,
                'count' => $item->count,
                'percentage' => $totalPengeluaran > 0 ? round(($total / $totalPengeluaran) * 100, 1) : 0,
            ];
        });

    // Cash vs Digital breakdown
    $totalCash = (float)DB::table('dues_payments')->where('payment_method', 'cash')->where('status', 'lunas')->sum('amount_paid');
    $totalDigital = (float)DB::table('dues_payments')->whereIn('payment_method', ['qris_static', 'bank_transfer'])->where('status', 'lunas')->sum('amount_paid');

    return response()->json([
        'success' => true,
        'summary' => [
            'total_income' => $totalPemasukan,
            'total_expense' => $totalPengeluaran,
            'balance' => (float)($totalPemasukan - $totalPengeluaran),
            'total_cash_collected' => $totalCash,
            'total_digital_collected' => $totalDigital,
        ],
        'breakdown' => [
            'income' => $incomeBreakdown,
            'expense' => $expenseBreakdown,
        ],
        'data' => $transactions,
    ]);
});

Route::post('/treasury', function (Request $request) {
    $validated = $request->validate([
        'transaction_date' => 'required|date',
        'type' => 'required|in:pemasukan,pengeluaran',
        'category' => 'required|string',
        'title' => 'required|string|max:150',
        'description' => 'nullable|string',
        'amount' => 'required|numeric|min:1',
        'recorded_by' => 'required|exists:users,id',
    ]);

    $id = DB::table('treasury_transactions')->insertGetId(array_merge($validated, [
        'created_at' => now(),
        'updated_at' => now(),
    ]));

    return response()->json([
        'success' => true,
        'message' => 'Catatan transaksi kas berhasil disimpan.',
        'data' => DB::table('treasury_transactions')->where('id', $id)->first(),
    ], 201);
});

Route::get('/treasury/export', function () {
    $transactions = DB::table('treasury_transactions')
        ->join('users', 'treasury_transactions.recorded_by', '=', 'users.id')
        ->select('treasury_transactions.*', 'users.name as recorder_name')
        ->orderBy('transaction_date', 'asc')
        ->get();

    $csv = "Tanggal,Jenis,Kategori,Judul,Deskripsi,Jumlah (Rp),Pencatat\n";
    foreach ($transactions as $t) {
        $amountStr = number_format($t->amount, 0, ',', '.');
        $csv .= "\"{$t->transaction_date}\",\"{$t->type}\",\"{$t->category}\",\"{$t->title}\",\"{$t->description}\",\"{$amountStr}\",\"{$t->recorder_name}\"\n";
    }

    return response($csv, 200, [
        'Content-Type' => 'text/csv; charset=utf-8',
        'Content-Disposition' => 'attachment; filename="buku_kas_rt_' . date('Y-m-d') . '.csv"',
    ]);
});

// --- 9. Tombol Darurat (Panic Button) ---
Route::post('/emergency', function (Request $request) {
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
        'emergency_type' => 'required|string',
        'details' => 'nullable|string',
        'location_lat' => 'nullable|numeric',
        'location_lng' => 'nullable|numeric',
    ]);

    $id = DB::table('emergency_alerts')->insertGetId(array_merge($validated, [
        'status' => 'aktif',
        'created_at' => now(),
        'updated_at' => now(),
    ]));

    $alert = DB::table('emergency_alerts')
        ->join('users', 'emergency_alerts.user_id', '=', 'users.id')
        ->where('emergency_alerts.id', $id)
        ->select('emergency_alerts.*', 'users.name as citizen_name', 'users.phone as citizen_phone')
        ->first();

    return response()->json([
        'success' => true,
        'message' => '🚨 SINYAL DARURAT DIAKTIFKAN! Notifikasi diteruskan ke Pengurus RT/RW & Petugas Keamanan.',
        'data' => $alert,
    ], 201);
});

Route::get('/emergency', function () {
    $alerts = DB::table('emergency_alerts')
        ->join('users', 'emergency_alerts.user_id', '=', 'users.id')
        ->select('emergency_alerts.*', 'users.name as citizen_name', 'users.phone as citizen_phone')
        ->orderBy('emergency_alerts.created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $alerts,
    ]);
});

// --- 10. Berita & Kabar Kampung ---
Route::get('/news', function () {
    $news = DB::table('news_posts')
        ->join('users', 'news_posts.author_id', '=', 'users.id')
        ->select('news_posts.*', 'users.name as author_name')
        ->orderBy('is_pinned', 'desc')
        ->orderBy('news_posts.created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $news,
    ]);
});

Route::post('/news', function (Request $request) {
    $validated = $request->validate([
        'title' => 'required|string|max:200',
        'category' => 'required|string',
        'content' => 'required|string',
        'thumbnail_url' => 'nullable|string',
        'is_pinned' => 'nullable|boolean',
        'author_id' => 'required|exists:users,id',
    ]);

    $slug = Str::slug($validated['title']) . '-' . Str::random(5);

    $id = DB::table('news_posts')->insertGetId(array_merge($validated, [
        'slug' => $slug,
        'is_pinned' => $validated['is_pinned'] ?? false,
        'created_at' => now(),
        'updated_at' => now(),
    ]));

    return response()->json([
        'success' => true,
        'message' => 'Kabar kampung berhasil dipublikasikan.',
        'data' => DB::table('news_posts')->where('id', $id)->first(),
    ], 201);
});

// --- 11. Ringkasan Statistik Dashboard (Single Call API) ---
Route::get('/dashboard-summary', function () {
    $totalWarga = DB::table('users')->where('role', 'warga')->count();
    $pendingWarga = DB::table('users')->where('role', 'warga')->where('status', 'pending')->count();
    $approvedWarga = DB::table('users')->where('role', 'warga')->where('status', 'approved')->count();

    $pendingSurat = DB::table('letters')->whereIn('status', ['diajukan', 'diproses_rt', 'diproses_rw'])->count();
    $selesaiSurat = DB::table('letters')->where('status', 'selesai')->count();

    $aduanMenunggu = DB::table('complaints')->where('status', 'menunggu')->count();
    $aduanDiproses = DB::table('complaints')->where('status', 'diproses')->count();

    $activeSos = DB::table('emergency_alerts')->where('status', 'aktif')->count();

    $totalMasuk = DB::table('treasury_transactions')->where('type', 'pemasukan')->sum('amount');
    $totalKeluar = DB::table('treasury_transactions')->where('type', 'pengeluaran')->sum('amount');
    $saldoKas = $totalMasuk - $totalKeluar;

    return response()->json([
        'success' => true,
        'data' => [
            'warga' => [
                'total' => $totalWarga,
                'pending' => $pendingWarga,
                'approved' => $approvedWarga,
            ],
            'surat' => [
                'pending' => $pendingSurat,
                'selesai' => $selesaiSurat,
            ],
            'aduan' => [
                'menunggu' => $aduanMenunggu,
                'diproses' => $aduanDiproses,
            ],
            'sos_aktif' => $activeSos,
            'kas' => [
                'total_masuk' => $totalMasuk,
                'total_keluar' => $totalKeluar,
                'saldo' => $saldoKas,
            ],
        ],
    ]);
});

// --- 12. Modul Khusus Absensi & Piket Linmas / Hansip ---
Route::get('/linmas/attendances', function () {
    $attendances = DB::table('linmas_attendances')
        ->orderBy('created_at', 'desc')
        ->get();

    // Jika belum ada data, berikan sample piket linmas aktif
    if ($attendances->isEmpty()) {
        DB::table('linmas_attendances')->insert([
            [
                'user_id' => 1,
                'officer_name' => 'Sujatmo (Komandan Linmas)',
                'shift' => 'Piket Malam (20:00 - 04:00)',
                'post_name' => 'Pos Pantau Utama RT 001 / RW 005',
                'check_in_time' => now()->subHours(2),
                'check_in_lat' => -6.2088,
                'check_in_lng' => 106.8456,
                'situation_status' => 'Aman & Kondusif',
                'notes' => 'Portal gang ditutup pukul 23.00, lampu penerangan jalan menyala normal.',
                'status' => 'bertugas',
                'created_at' => now()->subHours(2),
                'updated_at' => now(),
            ],
            [
                'user_id' => 2,
                'officer_name' => 'Dedi Iskandar (Anggota Linmas)',
                'shift' => 'Piket Malam (20:00 - 04:00)',
                'post_name' => 'Pos Gerbang Barat',
                'check_in_time' => now()->subHours(1),
                'check_in_lat' => -6.2095,
                'check_in_lng' => 106.8465,
                'situation_status' => 'Aman & Terkendali',
                'notes' => 'Patroli putaran pertama selesai, nihil hal mencurigakan.',
                'status' => 'bertugas',
                'created_at' => now()->subHours(1),
                'updated_at' => now(),
            ],
        ]);
        $attendances = DB::table('linmas_attendances')->orderBy('created_at', 'desc')->get();
    }

    return response()->json([
        'success' => true,
        'data' => $attendances,
    ]);
});

Route::post('/linmas/checkin', function (Request $request) {
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
        'officer_name' => 'required|string',
        'shift' => 'nullable|string',
        'post_name' => 'nullable|string',
        'check_in_lat' => 'nullable|numeric',
        'check_in_lng' => 'nullable|numeric',
        'situation_status' => 'nullable|string',
        'notes' => 'nullable|string',
    ]);

    $id = DB::table('linmas_attendances')->insertGetId([
        'user_id' => $validated['user_id'],
        'officer_name' => $validated['officer_name'],
        'shift' => $validated['shift'] ?? 'Piket Malam (20:00 - 04:00)',
        'post_name' => $validated['post_name'] ?? 'Pos Pantau Utama RT 001',
        'check_in_time' => now(),
        'check_in_lat' => $validated['check_in_lat'] ?? -6.2088,
        'check_in_lng' => $validated['check_in_lng'] ?? 106.8456,
        'situation_status' => $validated['situation_status'] ?? 'Aman & Kondusif',
        'notes' => $validated['notes'] ?? 'Presensi GPS Masuk Piket Linmas Berhasil.',
        'status' => 'bertugas',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Presensi Linmas Berhasil! Selamat bertugas menjaga keamanan kampung.',
        'data' => DB::table('linmas_attendances')->where('id', $id)->first(),
    ], 201);
});

Route::post('/linmas/checkout', function (Request $request) {
    $validated = $request->validate([
        'attendance_id' => 'required|exists:linmas_attendances,id',
        'notes' => 'nullable|string',
    ]);

    DB::table('linmas_attendances')
        ->where('id', $validated['attendance_id'])
        ->update([
            'check_out_time' => now(),
            'status' => 'selesai',
            'notes' => $validated['notes'] ?? 'Tugas piket linmas selesai dengan aman.',
            'updated_at' => now(),
        ]);

    return response()->json([
        'success' => true,
        'message' => 'Laporan Selesai Piket Diterima. Terima kasih atas pengabdian Linmas!',
    ]);
});

// --- 13. Modul Pembayaran Kas (QRIS Statis + Transfer Manual) & Kuitansi Digital ---

// Ambil tagihan & status kas warga
Route::get('/dues/my-bill/{userId}', function ($userId) {
    // Pastikan tagihan bulan berjalan ada
    $bill = DB::table('dues_bills')
        ->where('user_id', $userId)
        ->where('month', 'Oktober')
        ->where('year', 2026)
        ->first();

    if (!$bill) {
        $billId = DB::table('dues_bills')->insertGetId([
            'user_id' => $userId,
            'title' => 'Iuran Warga + Sampah & Keamanan',
            'month' => 'Oktober',
            'year' => 2026,
            'amount' => 25000,
            'status' => 'menunggu_bayar',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        $bill = DB::table('dues_bills')->where('id', $billId)->first();
    }

    // Ambil riwayat pembayaran atau kuitansi terakhir
    $payment = DB::table('dues_payments')
        ->where('bill_id', $bill->id)
        ->orderBy('created_at', 'desc')
        ->first();

    return response()->json([
        'success' => true,
        'data' => [
            'bill' => $bill,
            'latest_payment' => $payment,
            'qris_info' => [
                'merchant_name' => 'KAS RT 001 / RW 005 DESA CERDAS',
                'nmid' => 'ID1020260012399',
                'qris_image_url' => 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=00020101021126580014ID.LINKAJA.WWW01189360091800000100015204599953033605802ID5919KAS+RT+001+RW+0056005BOGOR6304A1B2',
            ],
            'bank_info' => [
                'bank_name' => 'Bank Central Asia (BCA)',
                'account_number' => '8830-1928-31',
                'account_name' => 'KAS RT 001 RW 005',
            ],
        ],
    ]);
});

// Warga kirim bukti bayar (QRIS, Transfer, atau Cash/Tunai)
Route::post('/dues/pay', function (Request $request) {
    $validated = $request->validate([
        'bill_id' => 'required|exists:dues_bills,id',
        'user_id' => 'required|exists:users,id',
        'payment_method' => 'required|string',
        'amount_paid' => 'required|numeric',
        'proof_image_url' => 'nullable|string',
        'notes' => 'nullable|string',
    ]);

    $isCash = in_array(strtolower($validated['payment_method']), ['cash', 'tunai']);
    if ($isCash) {
        $actor = DB::table('users')->where('id', $validated['user_id'])->first();
        $allowedRoles = ['rt', 'rw', 'bendahara', 'sekretaris', 'staff', 'admin'];
        if (!$actor || !in_array($actor->role, $allowedRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak: Penerimaan tunai (cash) hanya dapat dicatat oleh Admin atau Staff/Bendahara RT. Silakan gunakan QRIS atau Transfer Bank.',
            ], 403);
        }
    }

    // Insert payment record
    $paymentId = DB::table('dues_payments')->insertGetId([
        'bill_id' => $validated['bill_id'],
        'user_id' => $validated['user_id'],
        'payment_method' => $isCash ? 'cash' : $validated['payment_method'],
        'bank_destination' => $isCash ? 'Tunai / Cash (Langsung ke Bendahara RT)' : 'BCA RT 001 / RW 005 - 8830192831',
        'amount_paid' => $validated['amount_paid'],
        'proof_image_url' => $validated['proof_image_url'] ?? ($isCash ? 'assets/cash_receipt.png' : 'assets/bukti_transfer_sample.jpg'),
        'status' => 'menunggu_verifikasi',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    // Update bill status
    DB::table('dues_bills')->where('id', $validated['bill_id'])->update([
        'status' => 'menunggu_verifikasi',
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => $isCash
            ? 'Pengajuan pembayaran tunai (cash) berhasil dicatat! Segera serahkan uang tunai ke Bendahara RT untuk diverifikasi.'
            : 'Bukti pembayaran berhasil diunggah! Sedang menunggu verifikasi Bendahara RT.',
        'data' => DB::table('dues_payments')->where('id', $paymentId)->first(),
    ], 201);
});

// Bendahara catat pembayaran tunai (cash) langsung 1-klik
Route::post('/dues/pay-cash-direct', function (Request $request) {
    $validated = $request->validate([
        'bill_id' => 'required|exists:dues_bills,id',
        'recorded_by' => 'nullable|exists:users,id',
        'notes' => 'nullable|string',
    ]);

    $bill = DB::table('dues_bills')->where('id', $validated['bill_id'])->first();
    $user = DB::table('users')->where('id', $bill->user_id)->first();

    // Verifikasi hak akses: hanya Admin / Staff / Bendahara yang berwenang mencatat tunai
    $recorderId = $validated['recorded_by'] ?? 1;
    $recorder = DB::table('users')->where('id', $recorderId)->first();
    $allowedRoles = ['rt', 'rw', 'bendahara', 'sekretaris', 'staff', 'admin'];
    if ($recorder && !in_array($recorder->role, $allowedRoles)) {
        return response()->json([
            'success' => false,
            'message' => 'Akses ditolak: Hanya Admin dan Staff/Bendahara RT yang berwenang mencatat penerimaan iuran tunai.',
        ], 403);
    }

    $receiptNumber = 'KAS-CASH' . str_pad($user->rt ?? '01', 2, '0', STR_PAD_LEFT) . '-' . date('Ym') . '-' . str_pad($bill->id, 4, '0', STR_PAD_LEFT);
    $qrHash = hash('sha256', $receiptNumber . '|' . $bill->amount . '|' . $user->nik . '|cash|' . now()->toIso8601String());

    // Insert or update dues_payments
    $paymentId = DB::table('dues_payments')->insertGetId([
        'bill_id' => $bill->id,
        'user_id' => $user->id,
        'payment_method' => 'cash',
        'bank_destination' => 'Tunai / Cash Langsung ke Bendahara',
        'amount_paid' => $bill->amount,
        'proof_image_url' => 'assets/cash_receipt.png',
        'receipt_number' => $receiptNumber,
        'qr_hash' => $qrHash,
        'status' => 'lunas',
        'verified_by' => $validated['recorded_by'] ?? 1,
        'verified_at' => now(),
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    // Update bill status to lunas
    DB::table('dues_bills')->where('id', $bill->id)->update([
        'status' => 'lunas',
        'updated_at' => now(),
    ]);

    // Catat otomatis ke buku kas transaksi pemasukan
    DB::table('treasury_transactions')->insert([
        'type' => 'pemasukan',
        'category' => 'iuran_bulanan',
        'title' => 'Iuran Kas Tunai (Cash) - ' . $bill->title . ' (' . $user->name . ')',
        'amount' => $bill->amount,
        'description' => 'Pembayaran tunai/cash diterima langsung oleh Bendahara RT. Kuitansi: ' . $receiptNumber . (!empty($validated['notes']) ? ' - ' . $validated['notes'] : ''),
        'transaction_date' => now()->toDateString(),
        'recorded_by' => $validated['recorded_by'] ?? 1,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Pembayaran tunai (cash) berhasil dicatat dan kuitansi digital resmi telah diterbitkan!',
        'receipt_number' => $receiptNumber,
    ], 201);
});

// Bendahara ambil semua daftar tagihan & verifikasi
Route::get('/dues/all', function () {
    // Buatkan seed data tagihan warga jika belum ada
    $totalBills = DB::table('dues_bills')->count();
    if ($totalBills < 4) {
        $users = DB::table('users')->where('role', 'warga')->get();
        foreach ($users as $idx => $u) {
            $status = $idx === 0 ? 'menunggu_bayar' : ($idx === 1 ? 'lunas' : 'menunggu_verifikasi');
            $bId = DB::table('dues_bills')->insertGetId([
                'user_id' => $u->id,
                'title' => 'Iuran Warga + Sampah & Keamanan',
                'month' => 'Oktober',
                'year' => 2026,
                'amount' => 25000,
                'status' => $status,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            if ($status === 'lunas') {
                $recNo = 'KAS-RT01-202610-00' . str_pad($bId, 2, '0', STR_PAD_LEFT);
                DB::table('dues_payments')->insert([
                    'bill_id' => $bId,
                    'user_id' => $u->id,
                    'payment_method' => 'qris_statis',
                    'bank_destination' => 'QRIS Kas RT 001',
                    'amount_paid' => 25000,
                    'proof_image_url' => 'assets/bukti_transfer_sample.jpg',
                    'receipt_number' => $recNo,
                    'qr_hash' => hash('sha256', $recNo . '|25000|' . $u->nik),
                    'status' => 'lunas',
                    'verified_by' => 1,
                    'verified_at' => now()->subDay(),
                    'created_at' => now()->subDay(),
                    'updated_at' => now()->subDay(),
                ]);
            } elseif ($status === 'menunggu_verifikasi') {
                DB::table('dues_payments')->insert([
                    'bill_id' => $bId,
                    'user_id' => $u->id,
                    'payment_method' => 'transfer_bank',
                    'bank_destination' => 'BCA Kas RT 001',
                    'amount_paid' => 25000,
                    'proof_image_url' => 'assets/bukti_transfer_sample.jpg',
                    'status' => 'menunggu_verifikasi',
                    'created_at' => now()->subHours(3),
                    'updated_at' => now()->subHours(3),
                ]);
            }
        }
    }

    $bills = DB::table('dues_bills')
        ->join('users', 'dues_bills.user_id', '=', 'users.id')
        ->leftJoin('dues_payments', function ($join) {
            $join->on('dues_bills.id', '=', 'dues_payments.bill_id')
                ->whereRaw('dues_payments.id = (SELECT MAX(id) FROM dues_payments dp WHERE dp.bill_id = dues_bills.id)');
        })
        ->select(
            'dues_bills.*',
            'users.name as citizen_name',
            'users.nik as citizen_nik',
            'users.phone as citizen_phone',
            'users.rt as citizen_rt',
            'users.address as citizen_address',
            'dues_payments.id as payment_id',
            'dues_payments.payment_method',
            'dues_payments.proof_image_url',
            'dues_payments.receipt_number',
            'dues_payments.qr_hash',
            'dues_payments.verified_at'
        )
        ->orderBy('dues_bills.status', 'asc')
        ->orderBy('dues_bills.created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $bills,
        'summary' => [
            'total_bills' => $bills->count(),
            'lunas' => $bills->where('status', 'lunas')->count(),
            'menunggu_verifikasi' => $bills->where('status', 'menunggu_verifikasi')->count(),
            'menunggu_bayar' => $bills->where('status', 'menunggu_bayar')->count(),
            'total_terkumpul' => (float)$bills->where('status', 'lunas')->sum('amount'),
            'total_nominal_terkumpul' => (float)$bills->where('status', 'lunas')->sum('amount'),
            'total_nominal_menunggu' => (float)$bills->where('status', 'menunggu_bayar')->sum('amount'),
        ],
    ]);
});

// Bendahara verifikasi pembayaran kas
Route::post('/dues/verify', function (Request $request) {
    $validated = $request->validate([
        'bill_id' => 'required|exists:dues_bills,id',
        'action' => 'required|in:approve,reject',
        'rejection_reason' => 'nullable|string',
    ]);

    $bill = DB::table('dues_bills')->where('id', $validated['bill_id'])->first();
    $user = DB::table('users')->where('id', $bill->user_id)->first();
    $payment = DB::table('dues_payments')->where('bill_id', $bill->id)->orderBy('id', 'desc')->first();

    if ($validated['action'] === 'approve') {
        $receiptNumber = 'KAS-RT' . str_pad($user->rt ?? '01', 2, '0', STR_PAD_LEFT) . '-' . date('Ym') . '-' . str_pad($bill->id, 4, '0', STR_PAD_LEFT);
        $qrHash = hash('sha256', $receiptNumber . '|' . $bill->amount . '|' . $user->nik . '|' . now()->toIso8601String());

        // Update payment
        if ($payment) {
            DB::table('dues_payments')->where('id', $payment->id)->update([
                'status' => 'lunas',
                'receipt_number' => $receiptNumber,
                'qr_hash' => $qrHash,
                'verified_by' => 1,
                'verified_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Update bill status
        DB::table('dues_bills')->where('id', $bill->id)->update([
            'status' => 'lunas',
            'updated_at' => now(),
        ]);

        // Catat otomatis ke buku kas transaksi pemasukan
        DB::table('treasury_transactions')->insert([
            'type' => 'pemasukan',
            'category' => 'iuran_bulanan',
            'title' => 'Pembayaran ' . $bill->title . ' (' . $user->name . ')',
            'amount' => $bill->amount,
            'description' => 'Verifikasi pembayaran sah No. Kuitansi: ' . $receiptNumber,
            'transaction_date' => now()->toDateString(),
            'recorded_by' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran kas berhasil diverifikasi! Kuitansi Digital resmi telah diterbitkan.',
            'receipt_number' => $receiptNumber,
        ]);
    } else {
        // Reject
        if ($payment) {
            DB::table('dues_payments')->where('id', $payment->id)->update([
                'status' => 'ditolak',
                'rejection_reason' => $validated['rejection_reason'] ?? 'Bukti transfer tidak terbaca atau nominal tidak sesuai.',
                'updated_at' => now(),
            ]);
        }

        DB::table('dues_bills')->where('id', $bill->id)->update([
            'status' => 'menunggu_bayar',
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Bukti pembayaran ditolak. Status tagihan dikembalikan ke Menunggu Bayar.',
        ]);
    }
});

// Endpoint data kuitansi digital untuk scan QR / unduh
Route::get('/receipts/{receiptNumber}', function ($receiptNumber) {
    $payment = DB::table('dues_payments')
        ->join('dues_bills', 'dues_payments.bill_id', '=', 'dues_bills.id')
        ->join('users', 'dues_payments.user_id', '=', 'users.id')
        ->where('dues_payments.receipt_number', $receiptNumber)
        ->select(
            'dues_payments.*',
            'dues_bills.title as bill_title',
            'dues_bills.month',
            'dues_bills.year',
            'users.name as citizen_name',
            'users.nik as citizen_nik',
            'users.rt as citizen_rt',
            'users.rw as citizen_rw',
            'users.address as citizen_address'
        )
        ->first();

    if (!$payment) {
        return response()->json(['success' => false, 'message' => 'Kuitansi tidak ditemukan.'], 404);
    }

    return response()->json([
        'success' => true,
        'data' => $payment,
    ]);
});

Route::get('/dues/export', function () {
    $bills = DB::table('dues_bills')
        ->join('users', 'dues_bills.user_id', '=', 'users.id')
        ->leftJoin('dues_payments', function ($join) {
            $join->on('dues_bills.id', '=', 'dues_payments.bill_id')
                ->whereRaw('dues_payments.id = (SELECT MAX(id) FROM dues_payments dp WHERE dp.bill_id = dues_bills.id)');
        })
        ->select(
            'users.nik',
            'users.name as citizen_name',
            'users.rt',
            'users.rw',
            'dues_bills.title as bill_title',
            'dues_bills.month',
            'dues_bills.year',
            'dues_bills.amount',
            'dues_bills.status',
            'dues_payments.payment_method',
            'dues_payments.receipt_number',
            'dues_payments.verified_at'
        )
        ->orderBy('users.rt')
        ->orderBy('users.name')
        ->get();

    $csv = "\xEF\xBB\xBF"; // UTF-8 BOM for Excel
    $csv .= "NIK,Nama Warga,RT,RW,Jenis Tagihan,Bulan,Tahun,Nominal (Rp),Status,Metode Bayar,No Kuitansi,Waktu Verifikasi\n";
    foreach ($bills as $b) {
        $csv .= "\"{$b->nik}\",\"{$b->citizen_name}\",\"{$b->rt}\",\"{$b->rw}\",\"{$b->bill_title}\",\"{$b->month}\",\"{$b->year}\",\"{$b->amount}\",\"{$b->status}\",\"{$b->payment_method}\",\"{$b->receipt_number}\",\"{$b->verified_at}\"\n";
    }

    return response($csv, 200, [
        'Content-Type' => 'text/csv; charset=utf-8',
        'Content-Disposition' => 'attachment; filename="rekap_iuran_kas_' . date('Y-m') . '.csv"',
    ]);
});

// ===========================================================================
// CCTV MONITORING SYSTEM (KHUSUS ADMIN, STAFF & LINMAS)
// ===========================================================================

// Auto-create cctv_cameras & cctv_incidents table if not exists
if (!Schema::hasTable('cctv_cameras')) {
    Schema::create('cctv_cameras', function ($table) {
        $table->id();
        $table->string('name');
        $table->string('location');
        $table->string('model')->default('TP-Link Tapo C320WS');
        $table->string('ip_address')->default('192.168.1.101');
        $table->integer('port')->default(554);
        $table->string('stream_url')->nullable();
        $table->string('preview_image')->nullable();
        $table->string('status')->default('online'); // online, offline, maintenance
        $table->string('resolution')->default('1080p FHD');
        $table->integer('fps')->default(30);
        $table->boolean('has_ptz')->default(false);
        $table->boolean('is_restricted')->default(true); // Khusus Admin & Staff
        $table->timestamps();
    });

    // Seed 4 Kamera Lingkungan RT
    DB::table('cctv_cameras')->insert([
        [
            'name' => 'CCTV 01 - Portal Gerbang Utama',
            'location' => 'Portal Masuk RT 001 / RW 005',
            'model' => 'TP-Link Tapo C320WS Outdoor',
            'ip_address' => '192.168.1.101',
            'port' => 554,
            'stream_url' => 'https://assets.mixkit.co/videos/preview/mixkit-traffic-in-a-street-intersection-4061-large.mp4',
            'preview_image' => 'https://images.unsplash.com/photo-1549880338-65ddcdfd017b?auto=format&fit=crop&w=600&q=80',
            'status' => 'online',
            'resolution' => '1080p Full HD',
            'fps' => 30,
            'has_ptz' => false,
            'is_restricted' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'name' => 'CCTV 02 - Pos Ronda & Parkiran Bersama',
            'location' => 'Pos Keamanan & Balai Warga RT',
            'model' => 'Ezviz H3c Color Night Outdoor',
            'ip_address' => '192.168.1.102',
            'port' => 554,
            'stream_url' => 'https://assets.mixkit.co/videos/preview/mixkit-empty-city-street-at-night-4220-large.mp4',
            'preview_image' => 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=600&q=80',
            'status' => 'online',
            'resolution' => '1080p Full HD',
            'fps' => 25,
            'has_ptz' => false,
            'is_restricted' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'name' => 'CCTV 03 - Simpang Blok B & Taman Anak',
            'location' => 'Persimpangan Jalan Melati / Lapangan',
            'model' => 'TP-Link Tapo C500 Smart PTZ 360°',
            'ip_address' => '192.168.1.103',
            'port' => 554,
            'stream_url' => 'https://assets.mixkit.co/videos/preview/mixkit-daytime-traffic-on-a-busy-city-avenue-4065-large.mp4',
            'preview_image' => 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=600&q=80',
            'status' => 'online',
            'resolution' => '1080p Full HD',
            'fps' => 30,
            'has_ptz' => true,
            'is_restricted' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'name' => 'CCTV 04 - Jalur Barat & Bank Sampah RT',
            'location' => 'Gerbang Samping & Area TPS Mandiri',
            'model' => 'Hikvision IP Bullet DS-2CD',
            'ip_address' => '192.168.1.104',
            'port' => 554,
            'stream_url' => 'https://assets.mixkit.co/videos/preview/mixkit-crosswalk-of-a-busy-avenue-in-a-city-4062-large.mp4',
            'preview_image' => 'https://images.unsplash.com/photo-1577495508048-b635879837f1?auto=format&fit=crop&w=600&q=80',
            'status' => 'online',
            'resolution' => '1080p Full HD',
            'fps' => 25,
            'has_ptz' => false,
            'is_restricted' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ],
    ]);
}

if (!Schema::hasTable('cctv_incidents')) {
    Schema::create('cctv_incidents', function ($table) {
        $table->id();
        $table->unsignedBigInteger('camera_id');
        $table->string('camera_name');
        $table->string('title');
        $table->text('description')->nullable();
        $table->string('snapshot_url')->nullable();
        $table->string('severity')->default('sedang'); // rendah, sedang, tinggi, darurat
        $table->unsignedBigInteger('reported_by')->nullable();
        $table->string('reporter_name')->default('Petugas Linmas');
        $table->timestamps();
    });

    DB::table('cctv_incidents')->insert([
        [
            'camera_id' => 1,
            'camera_name' => 'CCTV 01 - Portal Gerbang Utama',
            'title' => 'Kendaraan Truk Muatan Melintas Malam Hari',
            'description' => 'Truk boks ekspedisi masuk pukul 23:45, telah didata oleh petugas jaga pos.',
            'snapshot_url' => 'https://images.unsplash.com/photo-1549880338-65ddcdfd017b?auto=format&fit=crop&w=600&q=80',
            'severity' => 'rendah',
            'reported_by' => 1,
            'reporter_name' => 'Pak Sutrisno (Linmas)',
            'created_at' => now()->subHours(5),
            'updated_at' => now()->subHours(5),
        ],
        [
            'camera_id' => 3,
            'camera_name' => 'CCTV 03 - Simpang Blok B & Taman Anak',
            'title' => 'Lampu Taman Padam Sementara',
            'description' => 'Kondisi lampu jalan nomor 3 di dekat taman terindikasi padam, perlu penggantian bohlam LED.',
            'snapshot_url' => 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=600&q=80',
            'severity' => 'sedang',
            'reported_by' => 1,
            'reporter_name' => 'Bambang Sudarmono (Ketua RT)',
            'created_at' => now()->subDays(1),
            'updated_at' => now()->subDays(1),
        ],
    ]);
}

// 1. GET /api/cctv - List Kamera (Khusus Admin, Pengurus, Linmas)
Route::get('/cctv', function (Request $request) {
    $role = strtolower($request->query('role', ''));
    $userId = $request->query('user_id');

    if ($userId) {
        $user = DB::table('users')->where('id', $userId)->first();
        if ($user) $role = strtolower($user->role);
    }

    $allowedRoles = ['rt', 'rw', 'bendahara', 'sekretaris', 'staff', 'admin', 'linmas'];
    
    // Jika ada request dari role warga biasa, tolak akses demi privasi lingkungan
    if ($role && !in_array($role, $allowedRoles)) {
        return response()->json([
            'success' => false,
            'message' => 'Akses Terbatas: Pemantauan CCTV lingkungan hanya diperuntukkan bagi Ketua RT, Pengurus, dan Petugas Keamanan (Linmas).',
        ], 403);
    }

    $cameras = DB::table('cctv_cameras')->orderBy('id', 'asc')->get();
    $total = $cameras->count();
    $online = $cameras->where('status', 'online')->count();
    $offline = $cameras->where('status', 'offline')->count();

    return response()->json([
        'success' => true,
        'summary' => [
            'total_cameras' => $total,
            'online_cameras' => $online,
            'offline_cameras' => $offline,
            'system_status' => $offline === 0 ? 'Optimal (Semua Online)' : "Peringatan ($offline Offline)",
            'last_sync' => now()->toIso8601String(),
        ],
        'data' => $cameras,
    ]);
});

// 2. POST /api/cctv/snapshot - Simpan Bukti Insiden / Tangkapan Layar
Route::post('/cctv/snapshot', function (Request $request) {
    $validated = $request->validate([
        'camera_id' => 'required|exists:cctv_cameras,id',
        'title' => 'required|string',
        'description' => 'nullable|string',
        'severity' => 'nullable|in:rendah,sedang,tinggi,darurat',
        'reported_by' => 'nullable|exists:users,id',
        'snapshot_url' => 'nullable|string',
    ]);

    $camera = DB::table('cctv_cameras')->where('id', $validated['camera_id'])->first();
    $user = null;
    if (!empty($validated['reported_by'])) {
        $user = DB::table('users')->where('id', $validated['reported_by'])->first();
    }

    $incidentId = DB::table('cctv_incidents')->insertGetId([
        'camera_id' => $camera->id,
        'camera_name' => $camera->name,
        'title' => $validated['title'],
        'description' => $validated['description'] ?? 'Tangkapan layar pemantauan CCTV Pos Ronda',
        'snapshot_url' => $validated['snapshot_url'] ?? $camera->preview_image,
        'severity' => $validated['severity'] ?? 'sedang',
        'reported_by' => $user->id ?? 1,
        'reporter_name' => $user->name ?? 'Petugas Pos Ronda RT',
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Bukti tangkapan layar CCTV berhasil disimpan ke Log Insiden Keamanan RT.',
        'incident_id' => $incidentId,
    ]);
});

// 3. GET /api/cctv/incidents - List Bukti Insiden
Route::get('/cctv/incidents', function () {
    $incidents = DB::table('cctv_incidents')->orderBy('id', 'desc')->limit(20)->get();
    return response()->json([
        'success' => true,
        'data' => $incidents,
    ]);
});

// 4. POST /api/cctv/{id}/toggle-status - Simulasi Status Online / Offline
Route::post('/cctv/{id}/toggle-status', function ($id) {
    $cam = DB::table('cctv_cameras')->where('id', $id)->first();
    if (!$cam) return response()->json(['success' => false, 'message' => 'Kamera tidak ditemukan'], 404);

    $newStatus = $cam->status === 'online' ? 'offline' : 'online';
    DB::table('cctv_cameras')->where('id', $id)->update([
        'status' => $newStatus,
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => "Status {$cam->name} berhasil diubah menjadi: " . strtoupper($newStatus),
        'new_status' => $newStatus,
    ]);
});





// --- CETAK DOKUMEN RESMI (SURAT & KUITANSI RESMI RT) ---
Route::get('/letters/{id}/print', function ($id) {
    $letter = DB::table('letters')
        ->join('users', 'letters.user_id', '=', 'users.id')
        ->select(
            'letters.*',
            'users.name as citizen_name',
            'users.nik as citizen_nik',
            'users.phone as citizen_phone',
            'users.rt as citizen_rt',
            'users.rw as citizen_rw',
            'users.address as citizen_address'
        )
        ->where('letters.id', $id)
        ->first();

    if (!$letter) {
        abort(404, 'Surat tidak ditemukan.');
    }

    return view('letter_print', compact('letter'));
});

Route::get('/receipts/{receiptNumber}/print', function ($receiptNumber) {
    $payment = DB::table('dues_payments')
        ->join('dues_bills', 'dues_payments.bill_id', '=', 'dues_bills.id')
        ->join('users', 'dues_payments.user_id', '=', 'users.id')
        ->select('dues_payments.*', 'dues_bills.month', 'dues_bills.year', 'dues_bills.amount', 'users.name as citizen_name', 'users.nik as citizen_nik', 'users.rt as citizen_rt', 'users.rw as citizen_rw')
        ->where('dues_payments.receipt_number', $receiptNumber)
        ->first();

    if (!$payment) {
        abort(404, 'Kuitansi tidak ditemukan.');
    }

    return view('receipt_print', compact('payment'));
});


// ===========================================================================
// MODUL KHUSUS ABSEN LINMAS & UPDATE SITUASI KABAR HARI INI (DI TEMPAT)
// KHUSUS PETUGAS LINMAS, ADMIN (RT/RW), DAN STAFF PENGURUS (DIBLOKIR UNTUK WARGA)
// ===========================================================================

if (!Schema::hasTable('linmas_situation_logs')) {
    Schema::create('linmas_situation_logs', function ($table) {
        $table->id();
        $table->string('officer_name');
        $table->string('post_name')->default('Pos Pantau Utama RT 001');
        $table->string('time_string');
        $table->string('status')->default('aman'); // aman, waspada, insiden
        $table->text('details');
        $table->boolean('verified_by_rt')->default(false);
        $table->string('verified_by_name')->nullable();
        $table->timestamp('verified_at')->nullable();
        $table->timestamps();
    });

    DB::table('linmas_situation_logs')->insert([
        [
            'officer_name' => 'Sujatmo (Komandan Linmas)',
            'post_name' => 'Pos Pantau Utama RT 001 / RW 005',
            'time_string' => '23:15 WIB',
            'status' => 'aman',
            'details' => 'Portal gerbang utama telah ditutup dan digembok rapat. Lampu penerangan jalan gang melati 1-4 menyala normal.',
            'verified_by_rt' => true,
            'verified_by_name' => 'H. Sulaiman (Ketua RT 001)',
            'verified_at' => now()->subHours(1),
            'created_at' => now()->subHours(2),
            'updated_at' => now(),
        ],
        [
            'officer_name' => 'Dedi Iskandar (Anggota Linmas)',
            'post_name' => 'Pos Gerbang Barat',
            'time_string' => '01:40 WIB',
            'status' => 'aman',
            'details' => 'Patroli putaran pertama keliling blok A, B, C dan perbatasan rel kereta. Situasi sepi, kondusif, dan terkendali.',
            'verified_by_rt' => true,
            'verified_by_name' => 'H. Sulaiman (Ketua RT 001)',
            'verified_at' => now()->subMinutes(30),
            'created_at' => now()->subHours(1),
            'updated_at' => now(),
        ],
        [
            'officer_name' => 'Sujatmo (Komandan Linmas)',
            'post_name' => 'Pos Pantau Utama RT 001',
            'time_string' => '03:30 WIB',
            'status' => 'aman',
            'details' => 'Pengecekan area parkiran bersama dan bank sampah TPS. Nihil aktivitas mencurigakan.',
            'verified_by_rt' => false,
            'verified_by_name' => null,
            'verified_at' => null,
            'created_at' => now()->subMinutes(15),
            'updated_at' => now(),
        ],
    ]);
}

// 1. GET /api/linmas/situation-logs - Daftar Laporan Situasi Hari Ini (Buku Mutasi Keamanan)
Route::get('/linmas/situation-logs', function (Request $request) {
    $role = strtolower($request->query('role', $request->header('X-User-Role', '')));
    if ($role === 'warga') {
        return response()->json([
            'success' => false,
            'message' => 'Akses Terbatas: Log situasi keamanan pos ronda hanya untuk Linmas dan Pengurus RT.',
        ], 403);
    }

    $logs = DB::table('linmas_situation_logs')
        ->orderBy('created_at', 'desc')
        ->limit(25)
        ->get();

    return response()->json([
        'success' => true,
        'data' => $logs,
    ]);
});

// 2. POST /api/linmas/situation-logs - Kirim Update Situasi Hari Ini
Route::post('/linmas/situation-logs', function (Request $request) {
    $role = strtolower($request->header('X-User-Role', $request->input('role', '')));
    if ($role === 'warga') {
        return response()->json(['success' => false, 'message' => 'Akses Ditolak'], 403);
    }

    $validated = $request->validate([
        'officer_name' => 'required|string',
        'post_name' => 'nullable|string',
        'status' => 'required|in:aman,waspada,insiden',
        'details' => 'required|string',
    ]);

    $id = DB::table('linmas_situation_logs')->insertGetId([
        'officer_name' => $validated['officer_name'],
        'post_name' => $validated['post_name'] ?? 'Pos Pantau Utama RT 001',
        'time_string' => date('H:i') . ' WIB',
        'status' => $validated['status'],
        'details' => $validated['details'],
        'verified_by_rt' => false,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Laporan situasi keamanan pos ronda berhasil dikirimkan.',
        'data' => DB::table('linmas_situation_logs')->where('id', $id)->first(),
    ], 201);
});

// 3. POST /api/linmas/verify-log/{id} - Verifikasi Pengecekan oleh Ketua RT
Route::post('/linmas/verify-log/{id}', function ($id, Request $request) {
    $adminName = $request->input('admin_name', 'H. Sulaiman (Ketua RT 001)');
    DB::table('linmas_situation_logs')->where('id', $id)->update([
        'verified_by_rt' => true,
        'verified_by_name' => $adminName,
        'verified_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Laporan situasi pos telah berhasil diverifikasi oleh Ketua RT.',
        'data' => DB::table('linmas_situation_logs')->where('id', $id)->first(),
    ]);
});

// 4. POST /api/linmas/verify-attendance/{id} - Verifikasi Absensi Petugas di Tempat
Route::post('/linmas/verify-attendance/{id}', function ($id, Request $request) {
    DB::table('linmas_attendances')->where('id', $id)->update([
        'situation_status' => 'Diverifikasi Hadir di Tempat (Pos Ronda RT 001)',
        'updated_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Presensi petugas linmas berhasil diverifikasi oleh Ketua RT.',
    ]);
});

// 5. GET /api/treasury/lpj/print - Cetak LPJ Transparansi Keuangan Terbuka PDF
Route::get('/treasury/lpj/print', function () {
    $transactions = DB::table('treasury_transactions')
        ->join('users', 'treasury_transactions.recorded_by', '=', 'users.id')
        ->select('treasury_transactions.*', 'users.name as recorder_name')
        ->orderBy('transaction_date', 'desc')
        ->limit(10)
        ->get();

    $totalIncome = (float)DB::table('treasury_transactions')->where('type', 'pemasukan')->sum('amount');
    $totalExpense = (float)DB::table('treasury_transactions')->where('type', 'pengeluaran')->sum('amount');
    $balance = $totalIncome - $totalExpense;

    return view('treasury_lpj_print', compact('transactions', 'totalIncome', 'totalExpense', 'balance'));
});
