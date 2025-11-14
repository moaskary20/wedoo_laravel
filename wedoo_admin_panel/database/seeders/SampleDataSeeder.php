<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Category;
use App\Models\TaskType;
use App\Models\Shop;
use App\Models\PromoCode;
use App\Models\Notification;
use App\Models\Rating;
use App\Models\Order;

class SampleDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // إنشاء الفئات الأساسية
        $categories = [
            [
                'name' => 'السباكة',
                'name_en' => 'Plumbing',
                'description' => 'جميع خدمات السباكة وإصلاح الأنابيب',
                'icon' => '🔧',
                'status' => 'active'
            ],
            [
                'name' => 'الكهرباء',
                'name_en' => 'Electrical',
                'description' => 'خدمات الكهرباء والإضاءة',
                'icon' => '⚡',
                'status' => 'active'
            ],
            [
                'name' => 'النجارة',
                'name_en' => 'Carpentry',
                'description' => 'أعمال النجارة والأثاث',
                'icon' => '🪚',
                'status' => 'active'
            ],
            [
                'name' => 'الدهان',
                'name_en' => 'Painting',
                'description' => 'خدمات الدهان والديكور',
                'icon' => '🎨',
                'status' => 'active'
            ],
            [
                'name' => 'التكييف',
                'name_en' => 'Air Conditioning',
                'description' => 'صيانة وتركيب أجهزة التكييف',
                'icon' => '❄️',
                'status' => 'active'
            ],
            [
                'name' => 'النظافة',
                'name_en' => 'Cleaning',
                'description' => 'خدمات التنظيف والصيانة',
                'icon' => '🧹',
                'status' => 'active'
            ]
        ];

        foreach ($categories as $categoryData) {
            Category::create($categoryData);
        }

        // إنشاء أنواع المهام
        $plumbingCategory = Category::where('name', 'السباكة')->first();
        $electricalCategory = Category::where('name', 'الكهرباء')->first();
        $carpentryCategory = Category::where('name', 'النجارة')->first();
        $paintingCategory = Category::where('name', 'الدهان')->first();
        $acCategory = Category::where('name', 'التكييف')->first();
        $cleaningCategory = Category::where('name', 'النظافة')->first();

        $taskTypes = [
            // السباكة
            [
                'category_id' => $plumbingCategory->id,
                'name' => 'إصلاح تسريب المياه',
                'name_en' => 'Water Leak Repair',
                'description' => 'إصلاح تسريبات المياه في الأنابيب والحنفيات',
                'icon' => '💧',
                'color' => '#3B82F6',
                'price_range' => '50-200 ج.م',
                'duration' => '1-3 ساعات',
                'difficulty' => 'medium',
                'status' => 'active'
            ],
            [
                'category_id' => $plumbingCategory->id,
                'name' => 'تركيب حنفية جديدة',
                'name_en' => 'Install New Faucet',
                'description' => 'تركيب حنفيات جديدة في المطبخ أو الحمام',
                'icon' => '🚰',
                'color' => '#3B82F6',
                'price_range' => '100-300 ج.م',
                'duration' => '2-4 ساعات',
                'difficulty' => 'easy',
                'status' => 'active'
            ],
            // الكهرباء
            [
                'category_id' => $electricalCategory->id,
                'name' => 'إصلاح ماس كهربائي',
                'name_en' => 'Electrical Short Circuit Repair',
                'description' => 'إصلاح الماس الكهربائي وإعادة التيار',
                'icon' => '⚡',
                'color' => '#F59E0B',
                'price_range' => '100-500 ج.م',
                'duration' => '2-6 ساعات',
                'difficulty' => 'hard',
                'status' => 'active'
            ],
            [
                'category_id' => $electricalCategory->id,
                'name' => 'تركيب مروحة سقف',
                'name_en' => 'Install Ceiling Fan',
                'description' => 'تركيب مراوح السقف والإضاءة',
                'icon' => '🌀',
                'color' => '#F59E0B',
                'price_range' => '200-600 ج.م',
                'duration' => '3-5 ساعات',
                'difficulty' => 'medium',
                'status' => 'active'
            ],
            // النجارة
            [
                'category_id' => $carpentryCategory->id,
                'name' => 'إصلاح باب',
                'name_en' => 'Door Repair',
                'description' => 'إصلاح الأبواب والتركيبات الخشبية',
                'icon' => '🚪',
                'color' => '#8B4513',
                'price_range' => '150-400 ج.م',
                'duration' => '2-4 ساعات',
                'difficulty' => 'medium',
                'status' => 'active'
            ],
            [
                'category_id' => $carpentryCategory->id,
                'name' => 'صنع رف خشبي',
                'name_en' => 'Wooden Shelf Making',
                'description' => 'صنع رفوف خشبية مخصصة',
                'icon' => '📚',
                'color' => '#8B4513',
                'price_range' => '300-800 ج.م',
                'duration' => '4-8 ساعات',
                'difficulty' => 'hard',
                'status' => 'active'
            ],
            // الدهان
            [
                'category_id' => $paintingCategory->id,
                'name' => 'دهان غرفة',
                'name_en' => 'Room Painting',
                'description' => 'دهان الغرف والأسقف',
                'icon' => '🎨',
                'color' => '#EF4444',
                'price_range' => '500-1500 ج.م',
                'duration' => '1-2 أيام',
                'difficulty' => 'easy',
                'status' => 'active'
            ],
            // التكييف
            [
                'category_id' => $acCategory->id,
                'name' => 'صيانة مكيف',
                'name_en' => 'AC Maintenance',
                'description' => 'صيانة وتنظيف أجهزة التكييف',
                'icon' => '❄️',
                'color' => '#06B6D4',
                'price_range' => '200-500 ج.م',
                'duration' => '2-4 ساعات',
                'difficulty' => 'medium',
                'status' => 'active'
            ],
            // النظافة
            [
                'category_id' => $cleaningCategory->id,
                'name' => 'تنظيف عميق',
                'name_en' => 'Deep Cleaning',
                'description' => 'تنظيف عميق للشقق والمنازل',
                'icon' => '🧹',
                'color' => '#10B981',
                'price_range' => '300-800 ج.م',
                'duration' => '4-8 ساعات',
                'difficulty' => 'easy',
                'status' => 'active'
            ]
        ];

        foreach ($taskTypes as $taskTypeData) {
            TaskType::create($taskTypeData);
        }

        // إنشاء مستخدمين تجريبيين
        $users = [
            [
                'name' => 'أحمد محمد',
                'email' => 'ahmed@example.com',
                'password' => bcrypt('password123'),
                'phone' => '01234567890',
                'user_type' => 'customer',
                'governorate' => 'القاهرة',
                'city' => 'مدينة نصر',
                'district' => 'الحي السابع',
                'status' => 'active'
            ],
            [
                'name' => 'محمد علي',
                'email' => 'mohamed@example.com',
                'password' => bcrypt('password123'),
                'phone' => '01234567891',
                'user_type' => 'craftsman',
                'governorate' => 'القاهرة',
                'city' => 'المعادي',
                'district' => 'المعادي',
                'status' => 'active'
            ],
            [
                'name' => 'سارة أحمد',
                'email' => 'sara@example.com',
                'password' => bcrypt('password123'),
                'phone' => '01234567892',
                'user_type' => 'customer',
                'governorate' => 'الجيزة',
                'city' => 'الهرم',
                'district' => 'الهرم',
                'status' => 'active'
            ],
            [
                'name' => 'علي حسن',
                'email' => 'ali@example.com',
                'password' => bcrypt('password123'),
                'phone' => '01234567893',
                'user_type' => 'craftsman',
                'governorate' => 'القاهرة',
                'city' => 'الزمالك',
                'district' => 'الزمالك',
                'status' => 'active'
            ]
        ];

        foreach ($users as $userData) {
            User::create($userData);
        }

        // إنشاء محلات تجريبية
        $shops = [
            [
                'name' => 'محل السباكة الذكي',
                'name_en' => 'Smart Plumbing Store',
                'description' => 'متخصصون في جميع أعمال السباكة والإصلاحات',
                'owner_name' => 'محمود أحمد',
                'phone' => '01234567894',
                'email' => 'smart.plumbing@example.com',
                'address' => 'شارع التحرير، مدينة نصر',
                'governorate' => 'القاهرة',
                'city' => 'مدينة نصر',
                'district' => 'الحي السابع',
                'website' => 'https://smart-plumbing.com',
                'facebook' => 'https://facebook.com/smartplumbing',
                'whatsapp' => '01234567894',
                'rating' => 4.5,
                'rating_count' => 25,
                'status' => 'active'
            ],
            [
                'name' => 'ورشة الكهرباء المتقدمة',
                'name_en' => 'Advanced Electrical Workshop',
                'description' => 'خدمات كهربائية متخصصة وتركيبات حديثة',
                'owner_name' => 'أحمد محمود',
                'phone' => '01234567895',
                'email' => 'advanced.electrical@example.com',
                'address' => 'شارع الهرم، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الهرم',
                'district' => 'الهرم',
                'website' => 'https://advanced-electrical.com',
                'instagram' => 'https://instagram.com/advancedelectrical',
                'whatsapp' => '01234567895',
                'rating' => 4.8,
                'rating_count' => 42,
                'status' => 'active'
            ],
            [
                'name' => 'مؤسسة النجارة الفنية',
                'name_en' => 'Artistic Carpentry Foundation',
                'description' => 'أعمال نجارة فنية ومفروشات مخصصة',
                'owner_name' => 'حسن علي',
                'phone' => '01234567896',
                'email' => 'artistic.carpentry@example.com',
                'address' => 'شارع الزمالك، الزمالك',
                'governorate' => 'القاهرة',
                'city' => 'الزمالك',
                'district' => 'الزمالك',
                'facebook' => 'https://facebook.com/artisticcarpentry',
                'whatsapp' => '01234567896',
                'rating' => 4.3,
                'rating_count' => 18,
                'status' => 'active'
            ]
        ];

        foreach ($shops as $shopData) {
            Shop::create($shopData);
        }

        // إنشاء أكواد خصم تجريبية
        $promoCodes = [
            [
                'code' => 'WELCOME20',
                'name' => 'خصم الترحيب',
                'description' => 'خصم 20% للعملاء الجدد',
                'type' => 'percentage',
                'value' => 20,
                'minimum_amount' => 100,
                'usage_limit' => 100,
                'starts_at' => now(),
                'expires_at' => now()->addMonths(3),
                'is_active' => true
            ],
            [
                'code' => 'SAVE50',
                'name' => 'وفر 50 جنيه',
                'description' => 'خصم ثابت 50 جنيه على الطلبات',
                'type' => 'fixed',
                'value' => 50,
                'minimum_amount' => 200,
                'usage_limit' => 50,
                'starts_at' => now(),
                'expires_at' => now()->addMonths(1),
                'is_active' => true
            ],
            [
                'code' => 'SUMMER30',
                'name' => 'خصم الصيف',
                'description' => 'خصم 30% على خدمات التكييف',
                'type' => 'percentage',
                'value' => 30,
                'minimum_amount' => 300,
                'usage_limit' => 200,
                'starts_at' => now(),
                'expires_at' => now()->addMonths(2),
                'is_active' => true
            ]
        ];

        foreach ($promoCodes as $promoData) {
            PromoCode::create($promoData);
        }

        // إنشاء إشعارات تجريبية
        $notifications = [
            [
                'user_id' => User::where('email', 'ahmed@example.com')->first()->id,
                'title' => 'مرحباً بك في تطبيق ودو',
                'message' => 'نرحب بك في تطبيق ودو! يمكنك الآن طلب الخدمات بسهولة.',
                'type' => 'general',
                'is_read' => false
            ],
            [
                'user_id' => User::where('email', 'sara@example.com')->first()->id,
                'title' => 'عرض خاص',
                'message' => 'احصل على خصم 20% على أول طلب لك باستخدام كود WELCOME20',
                'type' => 'promotion',
                'is_read' => false
            ]
        ];

        foreach ($notifications as $notificationData) {
            Notification::create($notificationData);
        }

        // إنشاء تقييمات تجريبية
        $ratings = [
            [
                'user_id' => User::where('email', 'ahmed@example.com')->first()->id,
                'shop_id' => Shop::where('name', 'محل السباكة الذكي')->first()->id,
                'rating' => 5,
                'comment' => 'خدمة ممتازة وسرعة في التنفيذ'
            ],
            [
                'user_id' => User::where('email', 'sara@example.com')->first()->id,
                'shop_id' => Shop::where('name', 'ورشة الكهرباء المتقدمة')->first()->id,
                'rating' => 4,
                'comment' => 'عمل جيد ولكن كان هناك تأخير بسيط'
            ]
        ];

        foreach ($ratings as $ratingData) {
            Rating::create($ratingData);
        }

        // إنشاء طلبات تجريبية
        $orders = [
            [
                'customer_id' => User::where('email', 'ahmed@example.com')->first()->id,
                'craftsman_id' => User::where('email', 'mohamed@example.com')->first()->id,
                'task_type_id' => TaskType::where('name', 'إصلاح تسريب المياه')->first()->id,
                'title' => 'إصلاح تسريب في الحمام',
                'description' => 'يوجد تسريب في حنفية الحمام الرئيسي ويحتاج إصلاح فوري',
                'location' => 'مدينة نصر، الحي السابع',
                'governorate' => 'القاهرة',
                'city' => 'مدينة نصر',
                'district' => 'الحي السابع',
                'budget' => 150,
                'preferred_date' => now()->addDays(1),
                'status' => 'accepted',
                'notes' => 'الحريف يفضل العمل في الصباح'
            ],
            [
                'customer_id' => User::where('email', 'sara@example.com')->first()->id,
                'task_type_id' => TaskType::where('name', 'تركيب مروحة سقف')->first()->id,
                'title' => 'تركيب مروحة سقف في غرفة النوم',
                'description' => 'أريد تركيب مروحة سقف حديثة في غرفة النوم الرئيسية',
                'location' => 'الهرم، الجيزة',
                'governorate' => 'الجيزة',
                'city' => 'الهرم',
                'district' => 'الهرم',
                'budget' => 400,
                'preferred_date' => now()->addDays(3),
                'status' => 'pending',
                'notes' => 'يجب أن تكون المروحة صامتة'
            ]
        ];

        foreach ($orders as $orderData) {
            Order::create($orderData);
        }

        $this->command->info('تم إنشاء البيانات التجريبية بنجاح!');
    }
}
