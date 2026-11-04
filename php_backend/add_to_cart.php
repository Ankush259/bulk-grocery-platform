<?php
// add_to_cart.php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require 'db_connect.php';

// Get the raw POST data from Flutter
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['pool_id']) || !isset($data['user_id']) || !isset($data['cart'])) {
    echo json_encode(["status" => "error", "message" => "Missing required data."]);
    exit();
}

$pool_id = $data['pool_id'];
$user_id = $data['user_id'];
$cart = $data['cart'];

$insertedCount = 0;

// Prepare the SQL statement to prevent SQL injection
$stmt = $conn->prepare("INSERT INTO pool_orders (pool_id, user_id, product_id, quantity, payment_status) VALUES (?, ?, ?, ?, 'pending')");

foreach ($cart as $item) {
    $product_id = $item['product_id'];
    $quantity = $item['quantity'];
    
    $stmt->bind_param("iiii", $pool_id, $user_id, $product_id, $quantity);
    if ($stmt->execute()) {
        $insertedCount++;
    }
}

$stmt->close();
$conn->close();

echo json_encode([
    "status" => "success", 
    "message" => "$insertedCount items successfully added to the group pool."
]);
?>