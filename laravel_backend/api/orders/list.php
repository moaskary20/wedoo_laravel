<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get user_id from query parameter
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 1;

// Sample orders data
$orders = [
    [
        'id' => 'ORD20240120001',
        'user_id' => $user_id,
        'task_type_id' => 21,
        'task_name' => 'صيانة مكيف هواء',
        'description' => 'صيانة مكيف الهواء في غرفة النوم',
        'location' => 'تونس، تونس',
        'phone' => '+216 12345678',
        'status' => 'pending',
        'created_at' => '2024-01-20 10:30:00',
        'estimated_price' => '150-300 دينار تونسي',
        'estimated_duration' => '2-3 ساعات'
    ],
    [
        'id' => 'ORD20240119001',
        'user_id' => $user_id,
        'task_type_id' => 4,
        'task_name' => 'تنظيف عام للمنزل',
        'description' => 'تنظيف شامل للمنزل',
        'location' => 'تونس، تونس',
        'phone' => '+216 12345678',
        'status' => 'completed',
        'created_at' => '2024-01-19 14:20:00',
        'estimated_price' => '80-120 دينار تونسي',
        'estimated_duration' => '3-4 ساعات'
    ],
    [
        'id' => 'ORD20240118001',
        'user_id' => $user_id,
        'task_type_id' => 1,
        'task_name' => 'صيانة السباكة',
        'description' => 'إصلاح تسرب في الحمام',
        'location' => 'تونس، تونس',
        'phone' => '+216 12345678',
        'status' => 'in_progress',
        'created_at' => '2024-01-18 09:15:00',
        'estimated_price' => '100-200 دينار تونسي',
        'estimated_duration' => '2-3 ساعات'
    ]
];

echo json_encode([
    'success' => true,
    'data' => $orders,
    'message' => 'Orders retrieved successfully'
]);
?>
