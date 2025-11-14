<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Seeder;

class NotificationsSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::all();

        $notifications = [
            [
                'user_id' => $users->random()->id,
                'title' => 'طلب جديد',
                'message' => 'تم استلام طلب جديد من حريف',
                'type' => 'order',
                'data' => json_encode(['order_id' => 1]),
                'is_read' => false,
                'read_at' => null,
            ],
            [
                'user_id' => $users->random()->id,
                'title' => 'رسالة جديدة',
                'message' => 'لديك رسالة جديدة في المحادثة',
                'type' => 'message',
                'data' => json_encode(['chat_id' => 1]),
                'is_read' => true,
                'read_at' => now()->subHours(1),
            ],
            [
                'user_id' => $users->random()->id,
                'title' => 'تقييم جديد',
                'message' => 'تم تقييم خدمتك من قبل الحريف',
                'type' => 'review',
                'data' => json_encode(['review_id' => 1]),
                'is_read' => false,
                'read_at' => null,
            ],
            [
                'user_id' => $users->random()->id,
                'title' => 'تحديث حالة الطلب',
                'message' => 'تم تحديث حالة طلبك إلى "قيد التنفيذ"',
                'type' => 'status_update',
                'data' => json_encode(['order_id' => 2, 'status' => 'in_progress']),
                'is_read' => true,
                'read_at' => now()->subHours(2),
            ],
            [
                'user_id' => $users->random()->id,
                'title' => 'إشعار عام',
                'message' => 'مرحباً بك في منصة ويدو',
                'type' => 'general',
                'data' => json_encode([]),
                'is_read' => false,
                'read_at' => null,
            ],
        ];

        foreach ($notifications as $notification) {
            Notification::create($notification);
        }

        $this->command->info('تم إنشاء الإشعارات بنجاح');
    }
}
