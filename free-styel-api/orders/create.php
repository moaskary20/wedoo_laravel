<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get POST data
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    echo json_encode(['success' => false, 'message' => 'Invalid JSON data']);
    exit();
}

// Validate required fields
$required_fields = ['user_id', 'task_type_id', 'description', 'location', 'phone'];
foreach ($required_fields as $field) {
    if (!isset($input[$field]) || empty($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
        exit();
    }
}

// Generate order ID
$order_id = 'ORD' . date('YmdHis') . rand(1000, 9999);

// Simulate order creation
$order = [
    'id' => $order_id,
    'user_id' => $input['user_id'],
    'task_type_id' => $input['task_type_id'],
    'description' => $input['description'],
    'location' => $input['location'],
    'phone' => $input['phone'],
    'status' => 'pending',
    'created_at' => date('Y-m-d H:i:s'),
    'estimated_price' => '50-200 دينار تونسي',
    'estimated_duration' => '2-4 ساعات'
];

echo json_encode([
    'success' => true,
    'data' => $order,
    'message' => 'Order created successfully'
]);
?>
