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
        // Check if table exists, if not create it
        if (!Schema::hasTable('password_reset_tokens')) {
            Schema::create('password_reset_tokens', function (Blueprint $table) {
                $table->id();
                $table->string('email')->index();
                $table->string('token', 6); // 6-digit code
                $table->timestamp('expires_at');
                $table->timestamps();
                
                // Add index for faster lookups
                $table->index(['email', 'token']);
            });
        }
        // If table already exists, skip creation (it was created by default Laravel migration)
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('password_reset_tokens');
    }
};
