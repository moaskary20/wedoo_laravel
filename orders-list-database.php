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

// Get user_id from query parameter
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 1;

try {
    // Query database for orders
    $stmt = $pdo->prepare("SELECT o.*, tt.name as task_name, tt.price_range, tt.duration 
                          FROM orders o 
                          LEFT JOIN task_types tt ON o.task_type_id = tt.id 
                          WHERE o.user_id = ? 
                          ORDER BY o.created_at DESC");
    $stmt->execute([$user_id]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format the response
    $formatted_orders = [];
    foreach ($orders as $order) {
        $formatted_orders[] = [
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
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $formatted_orders,
        'message' => 'Orders retrieved successfully'
    ]);
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
        'error_code' => 'DATABASE_ERROR'
    ]);
}
?>
