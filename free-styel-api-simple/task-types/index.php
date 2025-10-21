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

// Sample task types data
$taskTypes = [
    1 => [ // خدمات صيانة المنازل
        ['id' => 1, 'name' => 'صيانة السباكة', 'name_en' => 'Plumbing Maintenance', 'category_id' => 1, 'category_name' => 'خدمات صيانة المنازل', 'description' => 'إصلاح وصيانة أنظمة السباكة', 'icon' => 'fas fa-wrench', 'color' => '#e3f2fd', 'price_range' => '50-200 دينار تونسي', 'duration' => '1-3 ساعات', 'difficulty' => 'medium', 'status' => 'active', 'created_at' => '2024-01-01', 'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=صيانة+سباكة'],
        ['id' => 2, 'name' => 'صيانة الكهرباء', 'name_en' => 'Electrical Maintenance', 'category_id' => 1, 'category_name' => 'خدمات صيانة المنازل', 'description' => 'إصلاح وصيانة الأنظمة الكهربائية', 'icon' => 'fas fa-bolt', 'color' => '#fff3e0', 'price_range' => '80-300 دينار تونسي', 'duration' => '2-4 ساعات', 'difficulty' => 'hard', 'status' => 'active', 'created_at' => '2024-01-02', 'image' => 'https://via.placeholder.com/300x200/fff3e0/000000?text=صيانة+كهرباء'],
        ['id' => 3, 'name' => 'صيانة التكييف', 'name_en' => 'AC Maintenance', 'category_id' => 1, 'category_name' => 'خدمات صيانة المنازل', 'description' => 'صيانة أجهزة التكييف والتبريد', 'icon' => 'fas fa-snowflake', 'color' => '#e0f7fa', 'price_range' => '100-400 دينار تونسي', 'duration' => '2-3 ساعات', 'difficulty' => 'medium', 'status' => 'active', 'created_at' => '2024-01-03', 'image' => 'https://via.placeholder.com/300x200/e0f7fa/000000?text=صيانة+تكييف'],
    ],
    2 => [ // خدمات التنظيف
        ['id' => 4, 'name' => 'تنظيف عام للمنزل', 'name_en' => 'General House Cleaning', 'category_id' => 2, 'category_name' => 'خدمات التنظيف', 'description' => 'تنظيف شامل للمنزل', 'icon' => 'fas fa-broom', 'color' => '#fce4ec', 'price_range' => '80-120 دينار تونسي', 'duration' => '3-4 ساعات', 'difficulty' => 'easy', 'status' => 'active', 'created_at' => '2024-01-04', 'image' => 'https://via.placeholder.com/300x200/fce4ec/000000?text=تنظيف+منزل'],
        ['id' => 5, 'name' => 'تنظيف السجاد', 'name_en' => 'Carpet Cleaning', 'category_id' => 2, 'category_name' => 'خدمات التنظيف', 'description' => 'تنظيف وغسيل السجاد والموكيت', 'icon' => 'fas fa-brush', 'color' => '#f3e5f5', 'price_range' => '50-100 دينار تونسي', 'duration' => '1-2 ساعة', 'difficulty' => 'medium', 'status' => 'active', 'created_at' => '2024-01-05', 'image' => 'https://via.placeholder.com/300x200/f3e5f5/000000?text=تنظيف+سجاد'],
    ],
    5 => [ // خدمات طارئة (عاجلة)
        ['id' => 21, 'name' => 'صيانة مكيف هواء', 'name_en' => 'Air Conditioner Maintenance', 'category_id' => 5, 'category_name' => 'تكييف وتبريد', 'description' => 'صيانة وتنظيف أجهزة التكييف', 'icon' => 'fas fa-snowflake', 'color' => '#e3f2fd', 'price_range' => '100-300 دينار تونسي', 'duration' => '2-3 ساعات', 'difficulty' => 'medium', 'status' => 'active', 'created_at' => '2024-01-12', 'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=صيانة+تكييف'],
        ['id' => 22, 'name' => 'تنظيف مكيف هواء', 'name_en' => 'Clean Air Conditioner', 'category_id' => 5, 'category_name' => 'تكييف وتبريد', 'description' => 'تنظيف أجهزة التكييف والفلاتر', 'icon' => 'fas fa-broom', 'color' => '#e3f2fd', 'price_range' => '60-150 دينار تونسي', 'duration' => '1-2 ساعة', 'difficulty' => 'easy', 'status' => 'active', 'created_at' => '2024-01-13', 'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=تنظيف+تكييف'],
        ['id' => 23, 'name' => 'إصلاح مكيف هواء', 'name_en' => 'Repair Air Conditioner', 'category_id' => 5, 'category_name' => 'تكييف وتبريد', 'description' => 'إصلاح أعطال أجهزة التكييف', 'icon' => 'fas fa-wrench', 'color' => '#e3f2fd', 'price_range' => '150-500 دينار تونسي', 'duration' => '2-4 ساعات', 'difficulty' => 'hard', 'status' => 'active', 'created_at' => '2024-01-14', 'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=إصلاح+تكييف'],
        ['id' => 24, 'name' => 'تركيب مكيف هواء', 'name_en' => 'Install Air Conditioner', 'category_id' => 5, 'category_name' => 'تكييف وتبريد', 'description' => 'تركيب أجهزة التكييف الجديدة', 'icon' => 'fas fa-plus-circle', 'color' => '#e3f2fd', 'price_range' => '300-800 دينار تونسي', 'duration' => '4-8 ساعات', 'difficulty' => 'hard', 'status' => 'active', 'created_at' => '2024-01-15', 'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=تركيب+تكييف'],
        ['id' => 25, 'name' => 'إصلاح ثلاجة', 'name_en' => 'Repair Refrigerator', 'category_id' => 5, 'category_name' => 'تكييف وتبريد', 'description' => 'إصلاح أعطال الثلاجات وأجهزة التبريد', 'icon' => 'fas fa-ice-cream', 'color' => '#e3f2fd', 'price_range' => '100-400 دينار تونسي', 'duration' => '2-4 ساعات', 'difficulty' => 'hard', 'status' => 'active', 'created_at' => '2024-01-16', 'image' => 'https://via.placeholder.com/300x200/e3f2fd/000000?text=إصلاح+ثلاجة'],
    ],
];

$data = $taskTypes[$category_id] ?? [];

echo json_encode([
    'success' => true,
    'data' => $data,
    'message' => 'Task types retrieved successfully'
]);
?>