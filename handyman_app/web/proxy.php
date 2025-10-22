<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Extract the API path from REQUEST_URI, removing /proxy.php prefix
$requestUri = $_SERVER['REQUEST_URI'];
$apiPath = str_replace('/proxy.php', '', $requestUri);

// If no API path, default to root
if (empty($apiPath) || $apiPath === '/') {
    $apiPath = '/';
}

// Build the target URL
$url = 'https://free-styel.store' . $apiPath;
$queryString = $_SERVER['QUERY_STRING'];

if ($queryString) {
    $url .= '?' . $queryString;
}

// Debug logging
error_log("Proxy Debug - Request URI: " . $requestUri);
error_log("Proxy Debug - API Path: " . $apiPath);
error_log("Proxy Debug - Final URL: " . $url);
error_log("Proxy Debug - Method: " . $_SERVER['REQUEST_METHOD']);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $_SERVER['REQUEST_METHOD']);

// Handle POST data
if ($_SERVER['REQUEST_METHOD'] === 'POST' || $_SERVER['REQUEST_METHOD'] === 'PUT') {
    $input = file_get_contents('php://input');
    curl_setopt($ch, CURLOPT_POSTFIELDS, $input);
    error_log("Proxy Debug - POST Data: " . $input);
}

curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json',
    'User-Agent: WedooApp/1.0 (Flutter Web)',
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
curl_close($ch);

// Debug logging
error_log("Proxy Debug - Response Code: " . $httpCode);
error_log("Proxy Debug - Response: " . substr($response, 0, 200));
error_log("Proxy Debug - cURL Error: " . $curlError);

// Handle cURL errors
if ($response === false) {
    error_log("Proxy Debug - cURL failed: " . $curlError);
    http_response_code(500);
    echo json_encode(['error' => 'Proxy error: ' . $curlError]);
    exit();
}

http_response_code($httpCode);
echo $response;
?>