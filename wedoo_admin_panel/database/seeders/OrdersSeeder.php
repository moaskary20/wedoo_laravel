<?php

namespace Database\Seeders;

use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Seeder;

class OrdersSeeder extends Seeder
{
    public function run(): void
    {
        $customers = User::where('user_type', 'customer')->get();
        $craftsmen = User::where('user_type', 'craftsman')->get();

        $orders = [
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'title' => 'إصلاح صنبور المطبخ',
                'description' => 'الصنبور يسيل ماء باستمرار ويحتاج إصلاح فوري',
                'address' => 'شارع التحرير، مدينة نصر، القاهرة',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'مدينة نصر',
                'status' => 'pending',
                'priority' => 'high',
                'estimated_cost' => 150.00,
                'actual_cost' => null,
                'scheduled_date' => now()->addDays(1),
                'completed_at' => null,
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'title' => 'تركيب مكيف هواء',
                'description' => 'تركيب مكيف هواء جديد في غرفة النوم',
                'address' => 'شارع الهرم، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'الهرم',
                'status' => 'in_progress',
                'priority' => 'medium',
                'estimated_cost' => 500.00,
                'actual_cost' => 450.00,
                'scheduled_date' => now()->addDays(2),
                'completed_at' => null,
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'title' => 'دهان غرفة المعيشة',
                'description' => 'دهان غرفة المعيشة بالكامل مع إصلاح الشقوق',
                'address' => 'شارع الزمالك، القاهرة',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'الزمالك',
                'status' => 'completed',
                'priority' => 'low',
                'estimated_cost' => 800.00,
                'actual_cost' => 750.00,
                'scheduled_date' => now()->subDays(1),
                'completed_at' => now()->subHours(2),
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'title' => 'إصلاح كهرباء المنزل',
                'description' => 'مشكلة في الكهرباء في عدة غرف',
                'address' => 'شارع الدقي، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'الدقي',
                'status' => 'pending',
                'priority' => 'high',
                'estimated_cost' => 300.00,
                'actual_cost' => null,
                'scheduled_date' => now()->addDays(3),
                'completed_at' => null,
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'title' => 'تركيب أثاث جديد',
                'description' => 'تركيب خزانة ملابس جديدة في غرفة النوم',
                'address' => 'شارع سيدي جابر، الإسكندرية',
                'governorate' => 'الإسكندرية',
                'city' => 'الإسكندرية',
                'district' => 'سيدي جابر',
                'status' => 'cancelled',
                'priority' => 'medium',
                'estimated_cost' => 200.00,
                'actual_cost' => null,
                'scheduled_date' => now()->addDays(5),
                'completed_at' => null,
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'title' => 'صيانة مكيف الهواء',
                'description' => 'صيانة دورية لمكيف الهواء',
                'address' => 'شارع المهندسين، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'المهندسين',
                'status' => 'in_progress',
                'priority' => 'medium',
                'estimated_cost' => 100.00,
                'actual_cost' => 120.00,
                'scheduled_date' => now()->addDays(1),
                'completed_at' => null,
            ],
        ];

        foreach ($orders as $order) {
            Order::create($order);
        }

        $this->command->info('تم إنشاء الطلبات بنجاح');
    }
}
