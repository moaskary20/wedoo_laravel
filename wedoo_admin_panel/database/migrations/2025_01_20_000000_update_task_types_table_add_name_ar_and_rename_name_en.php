<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('task_types', function (Blueprint $table) {
            // Add name_ar column for Arabic name
            $table->string('name_ar')->nullable()->after('name');
            
            // Add name_fr column for French name
            $table->string('name_fr')->nullable()->after('name_ar');
        });
        
        // Copy data from name_en to name_fr if name_en exists
        if (Schema::hasColumn('task_types', 'name_en')) {
            DB::statement('UPDATE task_types SET name_fr = name_en WHERE name_en IS NOT NULL');
        }
        
        // Optionally drop name_en column after migration (uncomment if needed)
        // Schema::table('task_types', function (Blueprint $table) {
        //     $table->dropColumn('name_en');
        // });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('task_types', function (Blueprint $table) {
            // Drop name_fr and name_ar columns
            $table->dropColumn(['name_fr', 'name_ar']);
        });
    }
};

