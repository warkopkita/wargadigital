<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('linmas_attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('officer_name');
            $table->string('shift')->default('Piket Malam (20:00 - 04:00)');
            $table->string('post_name')->default('Pos Pantau Utama RT 001');
            $table->timestamp('check_in_time')->nullable();
            $table->timestamp('check_out_time')->nullable();
            $table->decimal('check_in_lat', 10, 7)->nullable();
            $table->decimal('check_in_lng', 10, 7)->nullable();
            $table->string('situation_status')->default('Aman & Kondusif');
            $table->text('notes')->nullable();
            $table->string('photo_url')->nullable();
            $table->enum('status', ['bertugas', 'selesai', 'izin'])->default('bertugas');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('linmas_attendances');
    }
};
