<?php
// Enhanced CORS headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400');
header('Access-Control-Allow-Credentials: true');

// Handle OPTIONS preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo json_encode(['status' => 'OK', 'message' => 'CORS preflight successful']);
    exit();
}

// Only allow POST requests for login
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['phone', 'password'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
        exit();
    }
}

// Sample users data
$users = [
    [
        'id' => 1,
        'name' => 'مستخدم تجريبي',
        'phone' => '01000690805',
        'password' => 'askary20',
        'email' => 'demo@example.com',
        'user_type' => 'customer',
        'governorate' => 'تونس',
        'city' => 'تونس العاصمة',
        'district' => 'المركز',
        'membership_code' => '558206',
        'status' => 'active'
    ],
    [
        'id' => 2,
        'name' => 'أحمد محمد',
        'phone' => '01234567890',
        'password' => 'password123',
        'email' => 'ahmed@example.com',
        'user_type' => 'customer',
        'governorate' => 'تونس',
        'city' => 'تونس العاصمة',
        'district' => 'الحي الإداري',
        'membership_code' => 'WED123456',
        'status' => 'active'
    ]
];

// Find user by phone and password
$user = null;
foreach ($users as $u) {
    if ($u['phone'] === $input['phone'] && $u['password'] === $input['password']) {
        $user = $u;
        break;
    }
}

if ($user) {
    // Generate tokens
    $access_token = 'token_' . uniqid() . '_' . time();
    $refresh_token = 'refresh_' . uniqid() . '_' . time();
    
    // Remove password from response
    unset($user['password']);
    
    // Add tokens and login time
    $user['access_token'] = $access_token;
    $user['refresh_token'] = $refresh_token;
    $user['login_time'] = date('Y-m-d H:i:s');
    
    echo json_encode([
        'success' => true,
        'data' => $user,
        'message' => 'Login successful',
        'timestamp' => time()
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid phone number or password'
    ]);
}
?>
