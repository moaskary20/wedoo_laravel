<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400'); // Cache preflight requests for 24 hours
header('Access-Control-Allow-Credentials: true'); // Allow credentials

// Handle OPTIONS preflight requests FIRST
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Return success response for preflight
    echo json_encode([
        'status' => 'OK', 
        'message' => 'CORS preflight successful',
        'method' => 'OPTIONS',
        'timestamp' => time()
    ]);
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
        ]);
        exit();
    }
}

// Simulate user registration (replace with actual database interaction)
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
]);
?>
