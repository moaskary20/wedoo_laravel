<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle order creation
    $input = json_decode(file_get_contents('php://input'), true);
    
    $order = [
        'id' => rand(1000, 9999),
        'customer_name' => $input['customer_name'] ?? 'عميل',
        'service_type' => $input['service_type'] ?? 'خدمة عامة',
        'description' => $input['description'] ?? '',
        'location' => $input['location'] ?? 'تونس',
        'status' => 'pending',
        'created_at' => date('Y-m-d H:i:s'),
        'price' => $input['price'] ?? '50-200 دينار تونسي'
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $order,
        'message' => 'تم إنشاء الطلب بنجاح'
    ]);
} else {
    // Handle order retrieval
    $orders = [
        [
            'id' => 1001,
            'customer_name' => 'أحمد محمد',
            'service_type' => 'إصلاح كهربائي',
            'description' => 'إصلاح مفتاح كهربائي في المطبخ',
            'location' => 'تونس، المنزه',
            'status' => 'pending',
            'created_at' => '2024-01-20 10:30:00',
            'price' => '80 دينار تونسي'
        ],
        [
            'id' => 1002,
            'customer_name' => 'فاطمة علي',
            'service_type' => 'تنظيف عام',
            'description' => 'تنظيف شقة 3 غرف',
            'location' => 'تونس، سيدي حسين',
            'status' => 'in_progress',
            'created_at' => '2024-01-20 09:15:00',
            'price' => '120 دينار تونسي'
        ]
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $orders,
        'message' => 'Orders retrieved successfully'
    ]);
}
?>
