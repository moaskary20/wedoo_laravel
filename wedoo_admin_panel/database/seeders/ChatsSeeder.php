<?php

namespace Database\Seeders;

use App\Models\Chat;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Seeder;

class ChatsSeeder extends Seeder
{
    public function run(): void
    {
        $orders = Order::all();

        $chats = [
            [
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'order_id' => $orders->random()->id,
                'last_message' => 'مرحباً، متى يمكنك الحضور لإصلاح الصنبور؟',
                'last_message_at' => now()->subHours(2),
                'customer_read' => true,
                'craftsman_read' => false,
                'status' => 'active',
            ],
            [
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'order_id' => $orders->random()->id,
                'last_message' => 'شكراً لك، العمل تم بنجاح',
                'last_message_at' => now()->subHours(5),
                'customer_read' => true,
                'craftsman_read' => true,
                'status' => 'active',
            ],
            [
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'order_id' => $orders->random()->id,
                'last_message' => 'هل يمكنك تأجيل الموعد ليوم آخر؟',
                'last_message_at' => now()->subDays(1),
                'customer_read' => false,
                'craftsman_read' => true,
                'status' => 'active',
            ],
            [
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'order_id' => $orders->random()->id,
                'last_message' => 'تم إلغاء الطلب',
                'last_message_at' => now()->subDays(2),
                'customer_read' => true,
                'craftsman_read' => true,
                'status' => 'closed',
            ],
            [
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'order_id' => $orders->random()->id,
                'last_message' => 'شكراً لك على الخدمة الممتازة',
                'last_message_at' => now()->subDays(3),
                'customer_read' => true,
                'craftsman_read' => true,
                'status' => 'closed',
            ],
        ];

        foreach ($chats as $chat) {
            Chat::create($chat);
        }

        $this->command->info('تم إنشاء المحادثات بنجاح');
    }
}
