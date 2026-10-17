<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Tambah kolom pendukung di tabel patrol_members jika belum ada
        Schema::table('patrol_members', function (Blueprint $table) {
            if (!Schema::hasColumn('patrol_members', 'status')) {
                $table->string('status', 20)->default('terjadwal'); // terjadwal, hadir, izin, tukar, alpha
            }
            if (!Schema::hasColumn('patrol_members', 'fine_amount')) {
                $table->decimal('fine_amount', 12, 2)->default(0);
            }
            if (!Schema::hasColumn('patrol_members', 'fine_paid')) {
                $table->boolean('fine_paid')->default(false);
            }
            if (!Schema::hasColumn('patrol_members', 'notes')) {
                $table->text('notes')->nullable();
            }
        });

        // 2. Tabel Permohonan Tukar Jadwal & Izin Ronda Warga
        Schema::create('patrol_swaps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patrol_schedule_id')->constrained()->cascadeOnDelete();
            $table->foreignId('requester_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('target_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('type', ['tukar_jadwal', 'izin_tidak_hadir'])->default('izin_tidak_hadir');
            $table->text('reason');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('admin_notes')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();
        });

        // 3. Tabel Checkpoint Patroli & Laporan Foto Situasi Lapangan (Smart Siskamling)
        Schema::create('patrol_checkpoints', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patrol_schedule_id')->nullable()->constrained('patrol_schedules')->nullOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('checkpoint_code', 50); // POS-RONDA-01, PORTAL-BARAT, dll
            $table->string('checkpoint_name', 100);
            $table->timestamp('scanned_at');
            $table->string('situation_status', 50)->default('Aman Kondusif');
            $table->text('notes')->nullable();
            $table->string('photo_url')->nullable();
            $table->decimal('location_lat', 10, 7)->nullable();
            $table->decimal('location_lng', 10, 7)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('patrol_checkpoints');
        Schema::dropIfExists('patrol_swaps');

        Schema::table('patrol_members', function (Blueprint $table) {
            if (Schema::hasColumn('patrol_members', 'status')) {
                $table->dropColumn('status');
            }
            if (Schema::hasColumn('patrol_members', 'fine_amount')) {
                $table->dropColumn('fine_amount');
            }
            if (Schema::hasColumn('patrol_members', 'fine_paid')) {
                $table->dropColumn('fine_paid');
            }
            if (Schema::hasColumn('patrol_members', 'notes')) {
                $table->dropColumn('notes');
            }
        });
    }
};
