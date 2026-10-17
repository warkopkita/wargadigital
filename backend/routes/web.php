<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('portal_hub');
});

Route::get('/app', function () {
    return redirect('/app/');
});

Route::get('/web', function () {
    return redirect('/web/');
});

Route::get('/app/{any?}', function ($any = null) {
    if (!empty($any)) {
        $file = public_path('app/' . $any);
        if (!file_exists($file) || is_dir($file)) {
            $file = public_path($any);
        }
        if (file_exists($file) && !is_dir($file)) {
            $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
            $mime = match($ext) {
                'js', 'mjs' => 'application/javascript',
                'css' => 'text/css',
                'json' => 'application/json',
                'wasm' => 'application/wasm',
                'png' => 'image/png',
                'jpg', 'jpeg' => 'image/jpeg',
                'svg' => 'image/svg+xml',
                'ttf' => 'font/ttf',
                'otf' => 'font/otf',
                'woff' => 'font/woff',
                'woff2' => 'font/woff2',
                default => mime_content_type($file) ?: 'application/octet-stream'
            };
            return response()->file($file, ['Content-Type' => $mime]);
        }
    }
    return response()->file(public_path('app/index.html'), ['Content-Type' => 'text/html']);
})->where('any', '.*');

Route::get('/images/{filename}', function ($filename) {
    $file = public_path('images/' . $filename);
    if (file_exists($file) && !is_dir($file)) {
        $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
        $mime = ($ext === 'png') ? 'image/png' : 'image/jpeg';
        return response()->file($file, ['Content-Type' => $mime]);
    }
    abort(404);
});

Route::get('/web/{any?}', function ($any = null) {
    if (!empty($any)) {
        $file = public_path('web/' . $any);
        if (file_exists($file) && !is_dir($file)) {
            $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
            $mime = match($ext) {
                'js', 'mjs' => 'application/javascript',
                'css' => 'text/css',
                'json' => 'application/json',
                'svg' => 'image/svg+xml',
                default => mime_content_type($file) ?: 'application/octet-stream'
            };
            return response()->file($file, ['Content-Type' => $mime]);
        }
    }
    return response()->file(public_path('web/index.html'), ['Content-Type' => 'text/html']);
})->where('any', '.*');

// Fallback direct routes if root requests are made by Flutter
Route::get('/flutter_bootstrap.js', function () {
    return response()->file(public_path('app/flutter_bootstrap.js'), ['Content-Type' => 'application/javascript']);
});
Route::get('/main.dart.js', function () {
    return response()->file(public_path('app/main.dart.js'), ['Content-Type' => 'application/javascript']);
});
Route::get('/flutter.js', function () {
    return response()->file(public_path('app/flutter.js'), ['Content-Type' => 'application/javascript']);
});
Route::get('/manifest.json', function () {
    return response()->file(public_path('app/manifest.json'), ['Content-Type' => 'application/json']);
});
Route::get('/flutter_service_worker.js', function () {
    return response()->file(public_path('app/flutter_service_worker.js'), ['Content-Type' => 'application/javascript']);
});
Route::get('/version.json', function () {
    return response()->file(public_path('app/version.json'), ['Content-Type' => 'application/json']);
});
Route::get('/canvaskit/{any}', function ($any) {
    $file = public_path('app/canvaskit/' . $any);
    if (file_exists($file)) {
        $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
        $mime = match($ext) {
            'wasm' => 'application/wasm',
            'js' => 'application/javascript',
            default => mime_content_type($file) ?: 'application/octet-stream'
        };
        return response()->file($file, ['Content-Type' => $mime]);
    }
    abort(404);
})->where('any', '.*');
Route::get('/assets/{any}', function ($any) {
    // Check in app/assets or web/assets
    $appFile = public_path('app/assets/' . $any);
    if (file_exists($appFile)) {
        return response()->file($appFile);
    }
    $webFile = public_path('web/assets/' . $any);
    if (file_exists($webFile)) {
        return response()->file($webFile);
    }
    abort(404);
})->where('any', '.*');

// Endpoint Pratinjau & Cetak Surat Resmi (Kop Surat + QR Code + PDF Print Ready)
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
})->name('letters.print');

// Endpoint Cetak Kuitansi Digital Resmi Pembayaran Kas RT (E-Receipt + QR Validasi)
Route::get('/receipts/{receiptNumber}/print', function ($receiptNumber) {
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
        abort(404, 'Kuitansi pembayaran tidak ditemukan.');
    }

    return view('receipt_print', compact('payment'));
})->name('receipts.print');

// Endpoint Cetak Jadwal Resmi Siskamling / Ronda Malam Format A4 Kop Surat
Route::get('/patrols/print-schedule', function () {
    $schedules = DB::table('patrol_schedules')
        ->orderBy('patrol_date', 'asc')
        ->get();

    foreach ($schedules as $schedule) {
        $schedule->members = DB::table('patrol_members')
            ->join('users', 'patrol_members.user_id', '=', 'users.id')
            ->where('patrol_members.patrol_schedule_id', $schedule->id)
            ->select('patrol_members.*', 'users.name', 'users.phone')
            ->get();
    }

    return view('patrol_schedule_print', compact('schedules'));
})->name('patrols.print');

// Endpoint Cetak Lembar Stiker QR Code Checkpoint Pos Ronda & Portal
Route::get('/patrols/qr-stickers/print', function () {
    return view('patrol_qr_stickers_print');
})->name('patrols.qr_stickers');


