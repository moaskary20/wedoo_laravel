<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get category_id from query parameter
$category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : 1;

// Sample task types data based on category
$task_types = [];

switch ($category_id) {
    case 1: // خدمات صيانة المنازل
        $task_types = [
            [
                'id' => 1,
                'name' => 'إصلاح الأجهزة الكهربائية',
                'name_en' => 'Electrical Appliance Repair',
                'category_id' => 1,
                'category_name' => 'خدمات صيانة المنازل',
                'description' => 'إصلاح وصيانة جميع الأجهزة الكهربائية المنزلية',
                'icon' => 'fas fa-bolt',
                'color' => '#ffeb3b',
                'price_range' => '50-200 دينار تونسي',
                'duration' => '1-3 ساعات',
                'difficulty' => 'medium',
                'status' => 'active',
                'created_at' => '2024-01-01',
                'image' => 'https://via.placeholder.com/300x200/ffeb3b/000000?text=إصلاح+كهربائي'
            ],
            [
                'id' => 2,
                'name' => 'تركيب الإضاءة',
                'name_en' => 'Light Installation',
                'category_id' => 1,
                'category_name' => 'خدمات صيانة المنازل',
                'description' => 'تركيب وصيانة أنظمة الإضاءة المختلفة',
                'icon' => 'fas fa-lightbulb',
                'color' => '#ffeb3b',
                'price_range' => '30-150 دينار تونسي',
                'duration' => '1-2 ساعة',
                'difficulty' => 'easy',
                'status' => 'active',
                'created_at' => '2024-01-02',
                'image' => 'https://via.placeholder.com/300x200/ffeb3b/000000?text=تركيب+إضاءة'
            ]
        ];
        break;
        
    case 2: // خدمات التنظيف
        $task_types = [
            [
                'id' => 3,
                'name' => 'تنظيف عام للمنزل',
                'name_en' => 'General House Cleaning',
                'category_id' => 2,
                'category_name' => 'خدمات التنظيف',
                'description' => 'تنظيف شامل لجميع أجزاء المنزل',
                'icon' => 'fas fa-broom',
                'color' => '#4caf50',
                'price_range' => '40-120 دينار تونسي',
                'duration' => '2-4 ساعات',
                'difficulty' => 'easy',
                'status' => 'active',
                'created_at' => '2024-01-03',
                'image' => 'https://via.placeholder.com/300x200/4caf50/000000?text=تنظيف+عام'
            ],
            [
                'id' => 4,
                'name' => 'تنظيف النوافذ',
                'name_en' => 'Window Cleaning',
                'category_id' => 2,
                'category_name' => 'خدمات التنظيف',
                'description' => 'تنظيف وتلميع النوافذ والمرايا',
                'icon' => 'fas fa-window-maximize',
                'color' => '#4caf50',
                'price_range' => '20-80 دينار تونسي',
                'duration' => '1-2 ساعة',
                'difficulty' => 'easy',
                'status' => 'active',
                'created_at' => '2024-01-04',
                'image' => 'https://via.placeholder.com/300x200/4caf50/000000?text=تنظيف+نوافذ'
            ]
        ];
        break;
        
    case 5: // خدمات طارئة (عاجلة)
        $task_types = [
            [
                'id' => 21,
                'name' => 'صيانة مكيف هواء',
                'name_en' => 'Air Conditioner Maintenance',
                'category_id' => 5,
                'category_name' => 'خدمات طارئة (عاجلة)',
                'description' => 'صيانة وتنظيف أجهزة التكييف',
                'icon' => 'fas fa-snowflake',
                'color' => '#e3f2fd',
                'price_range' => '100-300 دينار تونسي',
                'duration' => '2-3 ساعات',
                'difficulty' => 'medium',
                'status' => 'active',
                'created_at' => '2024-01-12',
                'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=صيانة+تكييف'
            ],
            [
                'id' => 22,
                'name' => 'تنظيف مكيف هواء',
                'name_en' => 'Clean Air Conditioner',
                'category_id' => 5,
                'category_name' => 'خدمات طارئة (عاجلة)',
                'description' => 'تنظيف أجهزة التكييف والفلاتر',
                'icon' => 'fas fa-broom',
                'color' => '#e3f2fd',
                'price_range' => '60-150 دينار تونسي',
                'duration' => '1-2 ساعة',
                'difficulty' => 'easy',
                'status' => 'active',
                'created_at' => '2024-01-13',
                'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=تنظيف+تكييف'
            ],
            [
                'id' => 23,
                'name' => 'إصلاح مكيف هواء',
                'name_en' => 'Repair Air Conditioner',
                'category_id' => 5,
                'category_name' => 'خدمات طارئة (عاجلة)',
                'description' => 'إصلاح أعطال أجهزة التكييف',
                'icon' => 'fas fa-wrench',
                'color' => '#e3f2fd',
                'price_range' => '150-500 دينار تونسي',
                'duration' => '2-4 ساعات',
                'difficulty' => 'hard',
                'status' => 'active',
                'created_at' => '2024-01-14',
                'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=إصلاح+تكييف'
            ]
        ];
        break;
        
    case 8: // خدمات الحديقة
        $task_types = [
            [
                'id' => 31,
                'name' => 'قص العشب',
                'name_en' => 'Grass Cutting',
                'category_id' => 8,
                'category_name' => 'خدمات الحديقة',
                'description' => 'قص وتنظيف العشب في الحديقة',
                'icon' => 'fas fa-seedling',
                'color' => '#8bc34a',
                'price_range' => '30-100 دينار تونسي',
                'duration' => '1-2 ساعة',
                'difficulty' => 'easy',
                'status' => 'active',
                'created_at' => '2024-01-21',
                'image' => 'https://via.placeholder.com/300x200/8bc34a/000000?text=قص+عشب'
            ],
            [
                'id' => 32,
                'name' => 'ري النباتات',
                'name_en' => 'Plant Watering',
                'category_id' => 8,
                'category_name' => 'خدمات الحديقة',
                'description' => 'ري ورعاية النباتات والحديقة',
                'icon' => 'fas fa-tint',
                'color' => '#8bc34a',
                'price_range' => '20-60 دينار تونسي',
                'duration' => '30-60 دقيقة',
                'difficulty' => 'easy',
                'status' => 'active',
                'created_at' => '2024-01-22',
                'image' => 'https://via.placeholder.com/300x200/8bc34a/000000?text=ري+نباتات'
            ]
        ];
        break;
        
    default:
        $task_types = [
            [
                'id' => 1,
                'name' => 'خدمة عامة',
                'name_en' => 'General Service',
                'category_id' => $category_id,
                'category_name' => 'خدمة عامة',
                'description' => 'خدمة عامة لهذه الفئة',
                'icon' => 'fas fa-tools',
                'color' => '#fec901',
                'price_range' => '50-200 دينار تونسي',
                'duration' => '1-3 ساعات',
                'difficulty' => 'medium',
                'status' => 'active',
                'created_at' => '2024-01-01',
                'image' => 'https://via.placeholder.com/300x200/fec901/000000?text=خدمة+عامة'
            ]
        ];
        break;
}

// Return JSON response
echo json_encode([
    'success' => true,
    'data' => $task_types,
    'message' => 'Task types retrieved successfully'
]);
?>
