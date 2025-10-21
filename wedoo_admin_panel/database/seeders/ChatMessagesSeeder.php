<?php

namespace Database\Seeders;

use App\Models\Chat;
use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Database\Seeder;

class ChatMessagesSeeder extends Seeder
{
    public function run(): void
    {
        $chats = Chat::all();

        $messages = [
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->customer_id,
                'message' => 'مرحباً، أريد إصلاح صنبور المطبخ',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(1),
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->craftsman_id,
                'message' => 'مرحباً، يمكنني الحضور غداً في الصباح',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(2),
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->customer_id,
                'message' => 'ممتاز، ما هو السعر المتوقع؟',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => false,
                'read_at' => null,
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->craftsman_id,
                'message' => 'السعر حوالي 150 جنيه',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(3),
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->customer_id,
                'message' => 'موافق، شكراً لك',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(4),
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->craftsman_id,
                'message' => 'تم إصلاح الصنبور بنجاح',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(5),
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->customer_id,
                'message' => 'شكراً لك على العمل الممتاز',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(6),
            ],
            [
                'chat_id' => $chats->random()->id,
                'sender_id' => $chats->random()->craftsman_id,
                'message' => 'العفو، في أي وقت تحتاج مساعدة',
                'message_type' => 'text',
                'file_path' => null,
                'is_read' => true,
                'read_at' => now()->subHours(7),
            ],
        ];

        foreach ($messages as $message) {
            ChatMessage::create($message);
        }

        $this->command->info('تم إنشاء رسائل المحادثات بنجاح');
    }
}
