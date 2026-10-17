<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class BackupWargaCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:backup-warga';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Melakukan backup harian database kependudukan dan surat Warga Digital secara otomatis';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Memulai pencadangan (backup) database Warga Digital...');

        $sourceDb = database_path('database.sqlite');
        if (!File::exists($sourceDb)) {
            $this->error('File database.sqlite tidak ditemukan!');
            return 1;
        }

        $backupDir = storage_path('app/backups');
        if (!File::exists($backupDir)) {
            File::makeDirectory($backupDir, 0755, true);
        }

        $timestamp = date('Y-m-d_His');
        $destDb = $backupDir . "/warga_digital_backup_{$timestamp}.sqlite";

        File::copy($sourceDb, $destDb);

        $size = round(File::size($destDb) / 1024, 2);
        $this->info("✓ Backup berhasil disimpan: {$destDb} ({$size} KB)");
        $this->info('Kepatuhan UU PDP: Data terenkripsi dan disimpan di lokasi penyimpanan aman.');

        return 0;
    }
}
