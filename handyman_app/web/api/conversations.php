<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$conversations = [
    [
        'id' => 1,
        'craftsman_name' => 'محمد الحرفي',
        'service_type' => 'إصلاح كهربائي',
        'last_message' => 'سأكون عندك خلال ساعة',
        'timestamp' => '2024-01-20 10:30:00',
        'unread_count' => 2
    ],
    [
        'id' => 2,
        'craftsman_name' => 'فاطمة النظافة',
        'service_type' => 'تنظيف عام',
        'last_message' => 'تم الانتهاء من التنظيف',
        'timestamp' => '2024-01-20 09:15:00',
        'unread_count' => 0
    ]
];

echo json_encode([
    'success' => true,
    'data' => $conversations,
    'message' => 'Conversations retrieved successfully'
]);
?>
