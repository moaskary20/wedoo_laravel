<?php

namespace Database\Seeders;

use App\Models\Service;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Seeder;

class ServicesSeeder extends Seeder
{
    public function run(): void
    {
        $categories = Category::all();
        $craftsmen = User::where('user_type', 'craftsman')->get();

        $services = [
            [
                'name' => 'إصلاح صنابير المياه',
                'description' => 'إصلاح جميع أنواع صنابير المياه والسباكة',
                'price' => 150.00,
                'duration' => 2,
                'category_id' => $categories->where('name', 'خدمات السباكة')->first()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'status' => 'active',
            ],
            [
                'name' => 'تركيب مكيفات الهواء',
                'description' => 'تركيب وصيانة مكيفات الهواء',
                'price' => 500.00,
                'duration' => 4,
                'category_id' => $categories->where('name', 'خدمات التكييف')->first()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'status' => 'active',
            ],
            [
                'name' => 'دهان المنازل',
                'description' => 'دهان داخلي وخارجي للمنازل',
                'price' => 800.00,
                'duration' => 3,
                'category_id' => $categories->where('name', 'خدمات الدهان')->first()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'status' => 'active',
            ],
            [
                'name' => 'إصلاح الكهرباء',
                'description' => 'إصلاح جميع مشاكل الكهرباء المنزلية',
                'price' => 300.00,
                'duration' => 2,
                'category_id' => $categories->where('name', 'خدمات الكهرباء')->first()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'status' => 'active',
            ],
            [
                'name' => 'تركيب الأثاث',
                'description' => 'تركيب وتجميع الأثاث المنزلي',
                'price' => 200.00,
                'duration' => 2,
                'category_id' => $categories->where('name', 'خدمات النجارة')->first()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'status' => 'active',
            ],
            [
                'name' => 'صيانة الأجهزة المنزلية',
                'description' => 'صيانة وإصلاح الأجهزة المنزلية',
                'price' => 100.00,
                'duration' => 1,
                'category_id' => $categories->where('name', 'خدمات صيانة الأجهزة')->first()->id,
                'craftsman_id' => $craftsmen->random()->id,
                'status' => 'active',
            ],
        ];

        foreach ($services as $service) {
            Service::create($service);
        }

        $this->command->info('تم إنشاء الخدمات بنجاح');
    }
}
