<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$categories = [
    [
        'id' => 1,
        'name' => 'Home Maintenance',
        'nameAr' => 'خدمات صيانة المنازل',
        'icon' => 'home_repair',
        'color' => '#2196F3',
        'craftsman_count' => 15
    ],
    [
        'id' => 2,
        'name' => 'Cleaning Services',
        'nameAr' => 'خدمات التنظيف',
        'icon' => 'cleaning_services',
        'color' => '#4CAF50',
        'craftsman_count' => 12
    ],
    [
        'id' => 3,
        'name' => 'Transportation',
        'nameAr' => 'النقل والخدمات اللوجستية',
        'icon' => 'local_shipping',
        'color' => '#FF9800',
        'craftsman_count' => 8
    ],
    [
        'id' => 4,
        'name' => 'Car Services',
        'nameAr' => 'خدمات السيارات',
        'icon' => 'directions_car',
        'color' => '#F44336',
        'craftsman_count' => 10
    ],
    [
        'id' => 5,
        'name' => 'Emergency Services',
        'nameAr' => 'خدمات طارئة (عاجلة)',
        'icon' => 'emergency',
        'color' => '#E91E63',
        'craftsman_count' => 20
    ],
    [
        'id' => 6,
        'name' => 'Family Services',
        'nameAr' => 'خدمات الأسر والعائلات',
        'icon' => 'family_restroom',
        'color' => '#9C27B0',
        'craftsman_count' => 6
    ],
    [
        'id' => 7,
        'name' => 'Technical Services',
        'nameAr' => 'خدمات تقنية',
        'icon' => 'computer',
        'color' => '#607D8B',
        'craftsman_count' => 18
    ],
    [
        'id' => 8,
        'name' => 'Garden Services',
        'nameAr' => 'خدمات الحديقة',
        'icon' => 'yard',
        'color' => '#8BC34A',
        'craftsman_count' => 9
    ]
];

echo json_encode([
    'success' => true,
    'data' => $categories,
    'message' => 'Categories retrieved successfully'
]);
?>
