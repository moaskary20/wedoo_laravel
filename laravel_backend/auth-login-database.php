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
$required_fields = ['phone', 'password'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field", 'error_code' => 'MISSING_FIELD']);
        exit();
    }
}

try {
    // Query database for user
    $stmt = $pdo->prepare("SELECT * FROM users WHERE phone = ? AND password = ? AND status = 'active'");
    $stmt->execute([$input['phone'], $input['password']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
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
            'message' => 'Invalid phone number or password',
            'error_code' => 'INVALID_CREDENTIALS'
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
