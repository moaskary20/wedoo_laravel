<?php

namespace Database\Seeders;

use App\Models\TaskType;
use App\Models\Category;
use Illuminate\Database\Seeder;

class TaskTypesSeeder extends Seeder
{
    public function run(): void
    {
        $categories = Category::all();

        $taskTypes = [
            [
                'category_id' => $categories->where('name', 'خدمات صيانة المنازل')->first()->id,
                'name' => 'إصلاح صنابير المياه',
                'name_en' => 'Water Tap Repair',
                'description' => 'إصلاح جميع أنواع صنابير المياه والسباكة',
                'icon' => 'faucet',
                'color' => '#3498db',
                'price_range' => '50-200 جنيه',
                'duration' => '1-2 ساعة',
                'difficulty' => 'easy',
                'status' => 'active',
            ],
            [
                'category_id' => $categories->where('name', 'خدمات صيانة المنازل')->first()->id,
                'name' => 'تركيب مكيفات الهواء',
                'name_en' => 'Air Conditioning Installation',
                'description' => 'تركيب وصيانة مكيفات الهواء',
                'icon' => 'air-conditioner',
                'color' => '#2ecc71',
                'price_range' => '300-800 جنيه',
                'duration' => '3-4 ساعات',
                'difficulty' => 'medium',
                'status' => 'active',
            ],
            [
                'category_id' => $categories->where('name', 'خدمات صيانة المنازل')->first()->id,
                'name' => 'دهان المنازل',
                'name_en' => 'House Painting',
                'description' => 'دهان داخلي وخارجي للمنازل',
                'icon' => 'paint-brush',
                'color' => '#e74c3c',
                'price_range' => '500-1500 جنيه',
                'duration' => '2-3 أيام',
                'difficulty' => 'medium',
                'status' => 'active',
            ],
            [
                'category_id' => $categories->where('name', 'خدمات صيانة المنازل')->first()->id,
                'name' => 'إصلاح الكهرباء',
                'name_en' => 'Electrical Repair',
                'description' => 'إصلاح جميع مشاكل الكهرباء المنزلية',
                'icon' => 'lightning',
                'color' => '#f39c12',
                'price_range' => '100-500 جنيه',
                'duration' => '2-4 ساعات',
                'difficulty' => 'hard',
                'status' => 'active',
            ],
            [
                'category_id' => $categories->where('name', 'حرف وخدمات متنوعة')->first()->id,
                'name' => 'تركيب الأثاث',
                'name_en' => 'Furniture Assembly',
                'description' => 'تركيب وتجميع الأثاث المنزلي',
                'icon' => 'furniture',
                'color' => '#8e44ad',
                'price_range' => '100-300 جنيه',
                'duration' => '1-3 ساعات',
                'difficulty' => 'easy',
                'status' => 'active',
            ],
            [
                'category_id' => $categories->where('name', 'خدمات صيانة المنازل')->first()->id,
                'name' => 'صيانة الأجهزة المنزلية',
                'name_en' => 'Home Appliance Maintenance',
                'description' => 'صيانة وإصلاح الأجهزة المنزلية',
                'icon' => 'wrench',
                'color' => '#16a085',
                'price_range' => '50-200 جنيه',
                'duration' => '1-2 ساعة',
                'difficulty' => 'medium',
                'status' => 'active',
            ],
        ];

        foreach ($taskTypes as $taskType) {
            TaskType::create($taskType);
        }

        $this->command->info('تم إنشاء أنواع المهام بنجاح');
    }
}
