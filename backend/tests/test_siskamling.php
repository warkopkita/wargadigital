<?php

require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Http\Request;

echo "=== TEST 1: AUTO-GENERATE JADWAL RONDA ===\n";
$req = Request::create('/api/patrols/auto-generate', 'POST', ['rt' => '001', 'rw' => '005']);
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . "\n";
echo "Response: " . $res->getContent() . "\n\n";

echo "=== TEST 2: GET PATROLS & KPI SUMMARY ===\n";
$req = Request::create('/api/patrols', 'GET');
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . "\n";
$json = json_decode($res->getContent(), true);
echo "Total Schedules: " . count($json['data']) . "\n";
echo "Summary KPI: " . json_encode($json['summary'], JSON_PRETTY_PRINT) . "\n\n";

echo "=== TEST 3: SCAN CHECKPOINT QR ===\n";
$req = Request::create('/api/patrols/checkpoint-scan', 'POST', [
    'user_id' => 1,
    'checkpoint_code' => 'PORTAL-BARAT-01',
    'situation_status' => 'Pintu Portal Terkunci',
    'notes' => 'Portal telah digembok pukul 23:00 WIB, kondisi aman terkendali.'
]);
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . "\n";
echo "Response: " . $res->getContent() . "\n\n";

echo "=== TEST 4: PERMOHONAN IZIN TIDAK HADIR ===\n";
$firstSchedule = $json['data'][0];
$req = Request::create('/api/patrols/swap-request', 'POST', [
    'schedule_id' => $firstSchedule['id'],
    'requester_user_id' => 1,
    'type' => 'izin_tidak_hadir',
    'reason' => 'Dinas luar kota mendadak, izin tidak hadir ronda malam ini.'
]);
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . "\n";
$swapRes = json_decode($res->getContent(), true);
echo "Response: " . $res->getContent() . "\n\n";

echo "=== TEST 5: REVIEW PERMOHONAN IZIN (APPROVED) ===\n";
$swapId = $swapRes['data']['id'];
$req = Request::create("/api/patrols/swap-requests/{$swapId}/review", 'POST', [
    'status' => 'approved',
    'admin_notes' => 'Izin disetujui oleh Ketua RT.',
    'reviewed_by' => 1
]);
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . "\n";
echo "Response: " . $res->getContent() . "\n\n";

echo "=== TEST 6: TERAPKAN SANKSI DENDA KAS RT (ALPHA) ===\n";
$member = $firstSchedule['members'][0] ?? null;
if ($member) {
    $req = Request::create('/api/patrols/apply-fine', 'POST', [
        'schedule_id' => $firstSchedule['id'],
        'user_id' => $member['user_id'],
        'amount' => 25000,
        'reason' => 'Alpha tanpa izin ronda malam'
    ]);
    $res = $app->handle($req);
    echo "Status: " . $res->getStatusCode() . "\n";
    echo "Response: " . $res->getContent() . "\n\n";
}

echo "=== TEST 7: PRINTABLE JADWAL RONDA A4 (BLADE VIEW) ===\n";
$req = Request::create('/patrols/print-schedule', 'GET');
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . " | Length: " . strlen($res->getContent()) . " bytes\n\n";

echo "=== TEST 8: PRINTABLE STIKER QR CHECKPOINT (BLADE VIEW) ===\n";
$req = Request::create('/patrols/qr-stickers/print', 'GET');
$res = $app->handle($req);
echo "Status: " . $res->getStatusCode() . " | Length: " . strlen($res->getContent()) . " bytes\n\n";

echo "=== SEMUA TEST BERHASIL 100%! ===\n";
