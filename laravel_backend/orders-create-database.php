<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database connection
require_once 'database.php';

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['user_id', 'task_type_id', 'description', 'location', 'phone'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Missing required field: $field", 'error_code' => 'MISSING_FIELD']);
        exit();
    }
}

try {
    // Insert new order
    $stmt = $pdo->prepare("INSERT INTO orders (user_id, task_type_id, description, location, phone) VALUES (?, ?, ?, ?, ?)");
    $result = $stmt->execute([
        $input['user_id'],
        $input['task_type_id'],
        $input['description'],
        $input['location'],
        $input['phone']
    ]);
    
    if ($result) {
        $order_id = $pdo->lastInsertId();
        
        // Get order details
        $stmt = $pdo->prepare("SELECT o.*, tt.name as task_name, tt.price_range, tt.duration 
                              FROM orders o 
                              LEFT JOIN task_types tt ON o.task_type_id = tt.id 
                              WHERE o.id = ?");
        $stmt->execute([$order_id]);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => $order['id'],
                'user_id' => $order['user_id'],
                'task_type_id' => $order['task_type_id'],
                'task_name' => $order['task_name'],
                'description' => $order['description'],
                'location' => $order['location'],
                'phone' => $order['phone'],
                'status' => $order['status'],
                'created_at' => $order['created_at'],
                'estimated_price' => $order['price_range'],
                'estimated_duration' => $order['duration']
            ],
            'message' => 'Order created successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to create order',
            'error_code' => 'ORDER_CREATION_FAILED'
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
