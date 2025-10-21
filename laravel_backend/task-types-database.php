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

// Get category_id from query parameter
$category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : 1;

try {
    // Query database for task types
    $stmt = $pdo->prepare("SELECT tt.*, c.name as category_name FROM task_types tt 
                          LEFT JOIN categories c ON tt.category_id = c.id 
                          WHERE tt.category_id = ? AND tt.status = 'active' 
                          ORDER BY tt.created_at ASC");
    $stmt->execute([$category_id]);
    $task_types = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format the response
    $formatted_task_types = [];
    foreach ($task_types as $task) {
        $formatted_task_types[] = [
            'id' => $task['id'],
            'name' => $task['name'],
            'name_en' => $task['name_en'],
            'category_id' => $task['category_id'],
            'category_name' => $task['category_name'],
            'description' => $task['description'],
            'icon' => $task['icon'],
            'color' => $task['color'],
            'price_range' => $task['price_range'],
            'duration' => $task['duration'],
            'difficulty' => $task['difficulty'],
            'status' => $task['status'],
            'created_at' => $task['created_at'],
            'image' => 'https://via.placeholder.com/300x200/' . ltrim($task['color'], '#') . '/000000?text=' . urlencode($task['name'])
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $formatted_task_types,
        'message' => 'Task types retrieved successfully'
    ]);
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
        'error_code' => 'DATABASE_ERROR'
    ]);
}
?>
