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
        // First, handle duplicate phone numbers
        // Set duplicate phone numbers (except the first occurrence) to null
        $duplicates = \DB::table('users')
            ->select('phone', \DB::raw('MIN(id) as first_id'))
            ->whereNotNull('phone')
            ->groupBy('phone')
            ->havingRaw('COUNT(*) > 1')
            ->get();

        foreach ($duplicates as $duplicate) {
            \DB::table('users')
                ->where('phone', $duplicate->phone)
                ->where('id', '!=', $duplicate->first_id)
                ->update(['phone' => null]);
        }

        Schema::table('users', function (Blueprint $table) {
            // Add unique constraint on phone
            // MySQL allows multiple NULL values in a unique column
            $table->unique('phone', 'users_phone_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique('users_phone_unique');
        });
    }
};
