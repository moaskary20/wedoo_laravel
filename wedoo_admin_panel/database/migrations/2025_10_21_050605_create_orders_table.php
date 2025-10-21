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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('craftsman_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('task_type_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description');
            $table->string('location');
            $table->string('governorate')->nullable();
            $table->string('city')->nullable();
            $table->string('district')->nullable();
            $table->decimal('budget', 10, 2)->nullable();
            $table->timestamp('preferred_date')->nullable();
            $table->enum('status', ['pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'rejected'])->default('pending');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
