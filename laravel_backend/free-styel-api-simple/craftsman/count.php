<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get category_id from query parameter
$category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : 1;

// Sample data for different categories (no database needed)
$sampleCounts = [
    1 => 15, // خدمات صيانة المنازل
    2 => 12, // خدمات التنظيف
    3 => 8,  // النقل والخدمات اللوجستية
    4 => 6,  // خدمات السيارات
    5 => 20, // خدمات طارئة (عاجلة)
    6 => 10, // خدمات الأسر والعائلات
    7 => 5,  // خدمات تقنية
    8 => 7,  // خدمات الحديقة
];

$count = $sampleCounts[$category_id] ?? 5;

echo json_encode([
    'success' => true,
    'data' => [
        'category_id' => $category_id,
        'count' => $count
    ],
    'message' => 'Craftsman count retrieved successfully'
]);
?>