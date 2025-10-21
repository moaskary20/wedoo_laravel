<?php

namespace Database\Seeders;

use App\Models\Review;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Seeder;

class ReviewsSeeder extends Seeder
{
    public function run(): void
    {
        $orders = Order::where('status', 'completed')->get();

        $reviews = [
            [
                'order_id' => $orders->random()->id,
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'rating' => 5,
                'comment' => 'خدمة ممتازة، العمل تم بجودة عالية',
                'status' => 'approved',
            ],
            [
                'order_id' => $orders->random()->id,
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'rating' => 4,
                'comment' => 'عمل جيد، لكن تأخر قليلاً في الموعد',
                'status' => 'approved',
            ],
            [
                'order_id' => $orders->random()->id,
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'rating' => 5,
                'comment' => 'شكراً لك على الخدمة الممتازة',
                'status' => 'approved',
            ],
            [
                'order_id' => $orders->random()->id,
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'rating' => 3,
                'comment' => 'الخدمة مقبولة، لكن يمكن تحسينها',
                'status' => 'pending',
            ],
            [
                'order_id' => $orders->random()->id,
                'customer_id' => $orders->random()->customer_id,
                'craftsman_id' => $orders->random()->craftsman_id,
                'rating' => 5,
                'comment' => 'أفضل خدمة حصلت عليها، أنصح به بشدة',
                'status' => 'approved',
            ],
        ];

        foreach ($reviews as $review) {
            Review::create($review);
        }

        $this->command->info('تم إنشاء التقييمات بنجاح');
    }
}
