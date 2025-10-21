<?php
// CORS Headers - محسنة
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['name', 'phone', 'email', 'password', 'user_type', 'governorate', 'city', 'district'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode([
            'success' => false, 
            'message' => "Missing required field: $field",
            'error_code' => 'MISSING_FIELD'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

// Validate phone number format
if (!preg_match('/^01[0-9]{9}$/', $input['phone'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid phone number format',
        'error_code' => 'INVALID_PHONE'
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Validate email format
if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email format',
        'error_code' => 'INVALID_EMAIL'
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Simulate user registration
$user_id = rand(1000, 9999);
$membership_code = 'WED' . rand(100000, 999999);
$access_token = 'token_' . uniqid() . '_' . time();
$refresh_token = 'refresh_' . uniqid() . '_' . time();

// Simulate successful registration
$user_data = [
    'id' => $user_id,
    'name' => $input['name'],
    'phone' => $input['phone'],
    'email' => $input['email'],
    'user_type' => $input['user_type'],
    'governorate' => $input['governorate'],
    'city' => $input['city'],
    'district' => $input['district'],
    'membership_code' => $membership_code,
    'access_token' => $access_token,
    'refresh_token' => $refresh_token,
    'created_at' => date('Y-m-d H:i:s'),
    'status' => 'active'
];

echo json_encode([
    'success' => true,
    'data' => $user_data,
    'message' => 'User registered successfully',
    'timestamp' => time()
], JSON_UNESCAPED_UNICODE);
?>
