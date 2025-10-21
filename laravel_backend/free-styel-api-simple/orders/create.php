<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['user_id', 'task_type_id', 'description', 'location', 'phone'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
        exit();
    }
}

// Simulate order creation
$order_id = 'ORD' . date('Ymd') . uniqid();
$status = 'pending';
$created_at = date('Y-m-d H:i:s');

echo json_encode([
    'success' => true,
    'data' => [
        'order_id' => $order_id,
        'user_id' => $input['user_id'],
        'task_type_id' => $input['task_type_id'],
        'description' => $input['description'],
        'location' => $input['location'],
        'phone' => $input['phone'],
        'status' => $status,
        'created_at' => $created_at
    ],
    'message' => 'Order created successfully'
]);
?>