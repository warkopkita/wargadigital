<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Tagihan Iuran Bulanan Warga
        Schema::create('dues_bills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title')->default('Iuran Kas Bulanan & Kebersihan');
            $table->string('month', 20)->default('Oktober');
            $table->integer('year')->default(2026);
            $table->decimal('amount', 12, 2)->default(25000);
            $table->enum('status', ['menunggu_bayar', 'menunggu_verifikasi', 'lunas', 'menunggak'])->default('menunggu_bayar');
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        // 2. Transaksi Pembayaran & Kuitansi Digital (E-Receipt)
        Schema::create('dues_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bill_id')->constrained('dues_bills')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('payment_method')->default('qris_statis'); // qris_statis, transfer_bank, tunai
            $table->string('bank_destination')->default('BCA RT 001 / RW 005 - Rek. 8830192831');
            $table->decimal('amount_paid', 12, 2);
            $table->string('proof_image_url')->nullable();
            $table->string('receipt_number')->nullable()->unique();
            $table->string('qr_hash')->nullable();
            $table->enum('status', ['menunggu_verifikasi', 'lunas', 'ditolak'])->default('menunggu_verifikasi');
            $table->text('rejection_reason')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dues_payments');
        Schema::dropIfExists('dues_bills');
    }
};
