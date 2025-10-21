<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Category;

class CategoriesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'خدمات صيانة المنازل',
                'name_en' => 'Home Maintenance',
                'description' => 'جميع خدمات صيانة وإصلاح المنازل',
                'icon' => 'home_repair',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات التنظيف',
                'name_en' => 'Cleaning Services',
                'description' => 'خدمات التنظيف المنزلي والمكتبي',
                'icon' => 'cleaning_services',
                'status' => 'active',
            ],
            [
                'name' => 'النقل والخدمات اللوجستية',
                'name_en' => 'Transportation',
                'description' => 'خدمات النقل والشحن اللوجستي',
                'icon' => 'local_shipping',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات السيارات',
                'name_en' => 'Car Services',
                'description' => 'صيانة وإصلاح السيارات',
                'icon' => 'directions_car',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات طارئة (عاجلة)',
                'name_en' => 'Emergency Services',
                'description' => 'الخدمات الطارئة والعاجلة',
                'icon' => 'emergency',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات الأسر والعائلات',
                'name_en' => 'Family Services',
                'description' => 'خدمات خاصة بالأسر والعائلات',
                'icon' => 'family_restroom',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات تقنية',
                'name_en' => 'Technical Services',
                'description' => 'الخدمات التقنية والحاسوبية',
                'icon' => 'computer',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات الحديقة',
                'name_en' => 'Garden Services',
                'description' => 'خدمات البستنة والعناية بالحدائق',
                'icon' => 'yard',
                'status' => 'active',
            ],
            [
                'name' => 'حرف وخدمات متنوعة',
                'name_en' => 'Various Crafts',
                'description' => 'حرف وخدمات متنوعة ومتخصصة',
                'icon' => 'handyman',
                'status' => 'active',
            ],
            [
                'name' => 'المصاعد والألواح الشمسية',
                'name_en' => 'Elevators & Solar',
                'description' => 'خدمات المصاعد والألواح الشمسية',
                'icon' => 'solar_power',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات التعليم والدروس الخصوصية',
                'name_en' => 'Education Services',
                'description' => 'خدمات التعليم والدروس الخصوصية',
                'icon' => 'school',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات المناسبات والإحتفالات',
                'name_en' => 'Events & Celebrations',
                'description' => 'خدمات تنظيم المناسبات والإحتفالات',
                'icon' => 'celebration',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات السفر والسياحة',
                'name_en' => 'Travel & Tourism',
                'description' => 'خدمات السفر والسياحة',
                'icon' => 'flight',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات المكاتب والمستندات',
                'name_en' => 'Office Services',
                'description' => 'خدمات المكاتب والمستندات',
                'icon' => 'business',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات التسوق',
                'name_en' => 'Shopping Services',
                'description' => 'خدمات التسوق والشراء',
                'icon' => 'shopping_cart',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات للمؤسسات والشركات',
                'name_en' => 'Corporate Services',
                'description' => 'خدمات خاصة بالمؤسسات والشركات',
                'icon' => 'business_center',
                'status' => 'active',
            ],
            [
                'name' => 'خدمات ذوي الإحتياجات الخاصة',
                'name_en' => 'Special Needs',
                'description' => 'خدمات خاصة بذوي الإحتياجات الخاصة',
                'icon' => 'accessibility',
                'status' => 'active',
            ],
        ];

        foreach ($categories as $categoryData) {
            Category::updateOrCreate(
                ['name' => $categoryData['name']],
                $categoryData
            );
        }

        $this->command->info('تم إنشاء ' . count($categories) . ' كاتيجري بنجاح');
    }
}
