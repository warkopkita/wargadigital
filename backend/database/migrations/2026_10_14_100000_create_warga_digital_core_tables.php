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
        // 1. Surat & Dokumen
        Schema::create('letters', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('letter_type'); // pengantar_ktp, pengantar_kk, domisili, sktm, usaha, dll
            $table->string('letter_number')->nullable()->unique();
            $table->text('purpose'); // keperluan surat
            $table->json('additional_data')->nullable(); // data pelengkap
            $table->enum('status', ['diajukan', 'diproses_rt', 'diproses_rw', 'selesai', 'ditolak'])->default('diajukan');
            $table->text('admin_notes')->nullable();
            $table->string('qr_code_hash')->nullable();
            $table->string('pdf_file_path')->nullable();
            $table->foreignId('signed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('signed_at')->nullable();
            $table->timestamps();
        });

        // 2. Jadwal Ronda Malam & Absensi GPS
        Schema::create('patrol_schedules', function (Blueprint $table) {
            $table->id();
            $table->date('patrol_date');
            $table->string('day_name', 20); // Senin, Selasa, dll
            $table->string('shift_name')->default('Malam (22:00 - 04:00)');
            $table->string('rt', 5)->default('001');
            $table->string('rw', 5)->default('001');
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('patrol_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patrol_schedule_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->boolean('has_checked_in')->default(false);
            $table->timestamp('checked_in_at')->nullable();
            $table->decimal('check_in_lat', 10, 7)->nullable();
            $table->decimal('check_in_lng', 10, 7)->nullable();
            $table->string('check_in_note')->nullable();
            $table->timestamps();
        });

        // 3. Posyandu & Tumbuh Kembang
        Schema::create('posyandu_activities', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->date('activity_date');
            $table->string('location');
            $table->string('rt', 5)->default('001');
            $table->text('description')->nullable();
            $table->timestamps();
        });

        Schema::create('child_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('child_name');
            $table->string('gender', 1); // L / P
            $table->date('birth_date');
            $table->decimal('weight_kg', 5, 2)->nullable();
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->decimal('head_circumference_cm', 5, 2)->nullable();
            $table->string('immunization_type')->nullable();
            $table->text('cadre_notes')->nullable();
            $table->date('recorded_date');
            $table->timestamps();
        });

        // 4. Aduan Warga & Lingkungan (TPS, Jalan Rusak, dll)
        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('category', 50); // jalan, sampah_tps, lampu_penerangan, saluran_air, keamanan, lain-lain
            $table->text('description');
            $table->string('photo_url')->nullable();
            $table->decimal('location_lat', 10, 7)->nullable();
            $table->decimal('location_lng', 10, 7)->nullable();
            $table->string('location_address')->nullable();
            $table->enum('status', ['dilaporkan', 'ditindak', 'selesai'])->default('dilaporkan');
            $table->text('feedback_notes')->nullable();
            $table->timestamps();
        });

        // 5. Dana & Transparansi Kas
        Schema::create('treasury_transactions', function (Blueprint $table) {
            $table->id();
            $table->date('transaction_date');
            $table->enum('type', ['pemasukan', 'pengeluaran']);
            $table->string('category', 50); // iuran_bulanan, donasi, kerja_bakti, operasional, darurat
            $table->string('title');
            $table->text('description')->nullable();
            $table->decimal('amount', 12, 2);
            $table->string('proof_receipt_url')->nullable();
            $table->foreignId('recorded_by')->constrained('users');
            $table->timestamps();
        });

        // 6. Tombol Darurat (Panic Button)
        Schema::create('emergency_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('emergency_type', 50); // medis, kebakaran, bencana, kriminal, lain-lain
            $table->text('details')->nullable();
            $table->decimal('location_lat', 10, 7)->nullable();
            $table->decimal('location_lng', 10, 7)->nullable();
            $table->enum('status', ['aktif', 'ditangani', 'selesai'])->default('aktif');
            $table->timestamps();
        });

        // 7. Berita & Pengumuman Kampung
        Schema::create('news_posts', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('slug')->unique();
            $table->string('category', 50)->default('Pengumuman'); // Kegiatan, Ronda, Pengumuman, Posyandu
            $table->text('content');
            $table->string('thumbnail_url')->nullable();
            $table->boolean('is_pinned')->default(false);
            $table->foreignId('author_id')->constrained('users');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('news_posts');
        Schema::dropIfExists('emergency_alerts');
        Schema::dropIfExists('treasury_transactions');
        Schema::dropIfExists('complaints');
        Schema::dropIfExists('child_records');
        Schema::dropIfExists('posyandu_activities');
        Schema::dropIfExists('patrol_members');
        Schema::dropIfExists('patrol_schedules');
        Schema::dropIfExists('letters');
    }
};
