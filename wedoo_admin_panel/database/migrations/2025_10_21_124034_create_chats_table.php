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
        Schema::create('chats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('craftsman_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('order_id')->nullable()->constrained('orders')->onDelete('set null');
            $table->text('last_message')->nullable();
            $table->timestamp('last_message_at')->nullable();
            $table->boolean('customer_read')->default(false);
            $table->boolean('craftsman_read')->default(false);
            $table->enum('status', ['active', 'closed', 'blocked'])->default('active');
            $table->timestamps();
            
            // Ensure unique chat between customer and craftsman
            $table->unique(['customer_id', 'craftsman_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chats');
    }
};
