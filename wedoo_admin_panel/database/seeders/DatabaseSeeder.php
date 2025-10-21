<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            CategoriesSeeder::class,
            UsersSeeder::class,
            OrdersSeeder::class,
            ChatsSeeder::class,
            ChatMessagesSeeder::class,
            ServicesSeeder::class,
            ReviewsSeeder::class,
            NotificationsSeeder::class,
            SettingsSeeder::class,
        ]);
    }
}
