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
        if (Schema::hasTable('password_reset_tokens')) {
            // Add expires_at column if it doesn't exist
            if (!Schema::hasColumn('password_reset_tokens', 'expires_at')) {
                Schema::table('password_reset_tokens', function (Blueprint $table) {
                    // Try to add after token, if token column exists
                    if (Schema::hasColumn('password_reset_tokens', 'token')) {
                        $table->timestamp('expires_at')->nullable()->after('token');
                    } else {
                        $table->timestamp('expires_at')->nullable();
                    }
                });
            }
            
            // Add updated_at if it doesn't exist
            if (!Schema::hasColumn('password_reset_tokens', 'updated_at')) {
                Schema::table('password_reset_tokens', function (Blueprint $table) {
                    if (Schema::hasColumn('password_reset_tokens', 'created_at')) {
                        $table->timestamp('updated_at')->nullable()->after('created_at');
                    } else {
                        $table->timestamp('updated_at')->nullable();
                    }
                });
            }
            
            // Note: We don't add 'id' column because the table already has 'email' as primary key
            // This is the Laravel default structure and works fine with Eloquent
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('password_reset_tokens')) {
            Schema::table('password_reset_tokens', function (Blueprint $table) {
                if (Schema::hasColumn('password_reset_tokens', 'expires_at')) {
                    $table->dropColumn('expires_at');
                }
            });
        }
    }
};

