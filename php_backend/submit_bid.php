<?php
// 1. Force CORS headers immediately
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// 2. Intercept OPTIONS preflight instantly
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');
require 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['pool_id']) || !isset($data['vendor_id']) || !isset($data['bid_amount'])) {
    echo json_encode(["status" => "error", "message" => "Missing required data."]);
    exit();
}

// Safely extract only numbers from the pool_id (prevents 'p1' from crashing MySQL)
$pool_id = (int) filter_var($data['pool_id'], FILTER_SANITIZE_NUMBER_INT);
$vendor_id = (int) $data['vendor_id'];
$bid_amount = (float) $data['bid_amount'];

if ($pool_id === 0) {
     echo json_encode(["status" => "error", "message" => "Invalid numeric pool ID."]);
     exit();
}

$stmt = $conn->prepare("INSERT INTO reverse_bids (pool_id, vendor_id, bid_amount) VALUES (?, ?, ?)");
$stmt->bind_param("iid", $pool_id, $vendor_id, $bid_amount);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Bid successfully submitted."]);
} else {
    echo json_encode(["status" => "error", "message" => "Database error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>