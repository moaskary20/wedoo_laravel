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
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable();
            $table->enum('user_type', ['customer', 'craftsman', 'admin'])->default('customer');
            $table->string('governorate')->nullable();
            $table->string('city')->nullable();
            $table->string('district')->nullable();
            $table->string('membership_code')->nullable();
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'user_type', 'governorate', 'city', 'district', 'membership_code', 'status']);
        });
    }
};
