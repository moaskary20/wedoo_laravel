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
$required_fields = ['phone', 'password'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field"]);
        exit();
    }
}

// Sample users data (in real app, this would come from database)
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
    ],
    [
        'id' => 3,
        'name' => 'فاطمة علي',
        'phone' => '01987654321',
        'password' => 'password456',
        'email' => 'fatima@example.com',
        'user_type' => 'customer',
        'governorate' => 'تونس',
        'city' => 'المرسى',
        'district' => 'المرسى',
        'membership_code' => 'WED789012',
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
    $access_token = 'token_' . uniqid();
    $refresh_token = 'refresh_' . uniqid();
    
    // Remove password from response
    unset($user['password']);
    
    // Add tokens
    $user['access_token'] = $access_token;
    $user['refresh_token'] = $refresh_token;
    
    echo json_encode([
        'success' => true,
        'data' => $user,
        'message' => 'Login successful'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid phone number or password'
    ]);
}
?>
