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
                'task_type_id' => 1, // Assuming task_type_id exists
                'title' => 'إصلاح صنبور المطبخ',
                'description' => 'الصنبور يسيل ماء باستمرار ويحتاج إصلاح فوري',
                'location' => 'شارع التحرير، مدينة نصر، القاهرة',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'مدينة نصر',
                'budget' => 150.00,
                'preferred_date' => now()->addDays(1),
                'status' => 'pending',
                'notes' => 'إصلاح فوري مطلوب',
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'task_type_id' => 2,
                'title' => 'تركيب مكيف هواء',
                'description' => 'تركيب مكيف هواء جديد في غرفة النوم',
                'location' => 'شارع الهرم، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'الهرم',
                'budget' => 500.00,
                'preferred_date' => now()->addDays(2),
                'status' => 'in_progress',
                'notes' => 'تركيب مكيف 1.5 حصان',
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'task_type_id' => 3,
                'title' => 'دهان غرفة المعيشة',
                'description' => 'دهان غرفة المعيشة بالكامل مع إصلاح الشقوق',
                'location' => 'شارع الزمالك، القاهرة',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'الزمالك',
                'budget' => 800.00,
                'preferred_date' => now()->subDays(1),
                'status' => 'completed',
                'notes' => 'تم الانتهاء من العمل بنجاح',
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'task_type_id' => 4,
                'title' => 'إصلاح كهرباء المنزل',
                'description' => 'مشكلة في الكهرباء في عدة غرف',
                'location' => 'شارع الدقي، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'الدقي',
                'budget' => 300.00,
                'preferred_date' => now()->addDays(3),
                'status' => 'pending',
                'notes' => 'فحص شامل للكهرباء مطلوب',
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'task_type_id' => 5,
                'title' => 'تركيب أثاث جديد',
                'description' => 'تركيب خزانة ملابس جديدة في غرفة النوم',
                'location' => 'شارع سيدي جابر، الإسكندرية',
                'governorate' => 'الإسكندرية',
                'city' => 'الإسكندرية',
                'district' => 'سيدي جابر',
                'budget' => 200.00,
                'preferred_date' => now()->addDays(5),
                'status' => 'cancelled',
                'notes' => 'تم إلغاء الطلب من قبل العميل',
            ],
            [
                'customer_id' => $customers->random()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'task_type_id' => 6,
                'title' => 'صيانة مكيف الهواء',
                'description' => 'صيانة دورية لمكيف الهواء',
                'location' => 'شارع المهندسين، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'المهندسين',
                'budget' => 100.00,
                'preferred_date' => now()->addDays(1),
                'status' => 'in_progress',
                'notes' => 'صيانة دورية شاملة',
            ],
        ];

        foreach ($orders as $order) {
            Order::create($order);
        }

        $this->command->info('تم إنشاء الطلبات بنجاح');
    }
}
