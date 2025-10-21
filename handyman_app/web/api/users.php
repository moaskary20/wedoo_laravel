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
    // Handle user registration/login
    $input = json_decode(file_get_contents('php://input'), true);
    
    $user = [
        'id' => rand(100, 999),
        'name' => $input['name'] ?? 'مستخدم جديد',
        'email' => $input['email'] ?? 'user@example.com',
        'phone' => $input['phone'] ?? '+216 12345678',
        'type' => $input['type'] ?? 'customer',
        'membership_code' => 'WED' . rand(1000, 9999),
        'created_at' => date('Y-m-d H:i:s')
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $user,
        'message' => 'تم تسجيل المستخدم بنجاح'
    ]);
} else {
    // Handle user retrieval
    $user = [
        'id' => 123,
        'name' => 'أحمد محمد',
        'email' => 'ahmed@example.com',
        'phone' => '+216 12345678',
        'type' => 'customer',
        'membership_code' => 'WED1234',
        'created_at' => '2024-01-01 00:00:00'
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $user,
        'message' => 'User retrieved successfully'
    ]);
}
?>
