<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Test API endpoint
echo json_encode([
    'success' => true,
    'data' => [
        'category_id' => 5,
        'count' => 20
    ],
    'message' => 'Craftsman count retrieved successfully'
]);
?>
