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
            Schema::table('password_reset_tokens', function (Blueprint $table) {
                // Check if column doesn't exist before adding
                if (!Schema::hasColumn('password_reset_tokens', 'expires_at')) {
                    // Try to add after token, if token column exists
                    if (Schema::hasColumn('password_reset_tokens', 'token')) {
                        $table->timestamp('expires_at')->nullable()->after('token');
                    } else {
                        $table->timestamp('expires_at')->nullable();
                    }
                }
            });
            
            // Also add id column if it doesn't exist (for Eloquent to work properly)
            if (!Schema::hasColumn('password_reset_tokens', 'id')) {
                Schema::table('password_reset_tokens', function (Blueprint $table) {
                    $table->id()->first();
                });
            }
            
            // Add updated_at if it doesn't exist
            if (!Schema::hasColumn('password_reset_tokens', 'updated_at')) {
                Schema::table('password_reset_tokens', function (Blueprint $table) {
                    $table->timestamp('updated_at')->nullable()->after('created_at');
                });
            }
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

