<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$notifications = [
    [
        'id' => 1,
        'title' => 'مرحباً بك في Wedoo',
        'message' => 'شكراً لانضمامك إلى منصة Wedoo للخدمات المنزلية',
        'type' => 'welcome',
        'read' => false,
        'created_at' => '2024-01-20 10:00:00'
    ],
    [
        'id' => 2,
        'title' => 'طلب خدمة جديد',
        'message' => 'تم استلام طلبك لإصلاح كهربائي وسيتم الرد عليك قريباً',
        'type' => 'order',
        'read' => true,
        'created_at' => '2024-01-20 09:30:00'
    ]
];

echo json_encode([
    'success' => true,
    'data' => $notifications,
    'message' => 'Notifications retrieved successfully'
]);
?>
