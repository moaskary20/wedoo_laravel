<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    echo json_encode([
        'status' => 'OK', 
        'message' => 'CORS preflight successful',
        'method' => 'OPTIONS',
        'timestamp' => time()
    ]);
    http_response_code(200);
    exit();
}

// Include database connection
require_once 'database.php';

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['name', 'phone', 'email', 'password', 'user_type', 'governorate', 'city', 'district'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field", 'error_code' => 'MISSING_FIELD']);
        exit();
    }
}

try {
    // Check if user already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE phone = ? OR email = ?");
    $stmt->execute([$input['phone'], $input['email']]);
    $existing_user = $stmt->fetch();
    
    if ($existing_user) {
        echo json_encode([
            'success' => false,
            'message' => 'User with this phone number or email already exists',
            'error_code' => 'USER_EXISTS'
        ]);
        exit();
    }
    
    // Generate unique membership code
    $membership_code = 'WED' . rand(100000, 999999);
    
    // Check if membership code already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE membership_code = ?");
    $stmt->execute([$membership_code]);
    while ($stmt->fetch()) {
        $membership_code = 'WED' . rand(100000, 999999);
        $stmt = $pdo->prepare("SELECT id FROM users WHERE membership_code = ?");
        $stmt->execute([$membership_code]);
    }
    
    // Insert new user
    $stmt = $pdo->prepare("INSERT INTO users (name, phone, email, password, user_type, governorate, city, district, membership_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $result = $stmt->execute([
        $input['name'],
        $input['phone'],
        $input['email'],
        $input['password'],
        $input['user_type'],
        $input['governorate'],
        $input['city'],
        $input['district'],
        $membership_code
    ]);
    
    if ($result) {
        // Get the inserted user data
        $user_id = $pdo->lastInsertId();
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Generate tokens
        $access_token = 'token_' . uniqid() . '_' . time();
        $refresh_token = 'refresh_' . uniqid() . '_' . time();
        
        // Remove password from response
        unset($user['password']);
        
        // Add tokens
        $user['access_token'] = $access_token;
        $user['refresh_token'] = $refresh_token;
        
        echo json_encode([
            'success' => true,
            'data' => $user,
            'message' => 'User registered successfully',
            'timestamp' => time()
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to register user',
            'error_code' => 'REGISTRATION_FAILED'
        ]);
    }
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
        'error_code' => 'DATABASE_ERROR'
    ]);
}
?>
