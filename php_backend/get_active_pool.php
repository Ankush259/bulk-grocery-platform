<?php
// get_active_pool.php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

require 'db_connect.php';

// 1. Fetch the active pool for Tohana Central Hub (colony_id = 1)
$poolQuery = "SELECT pool_id, closes_at FROM order_pools WHERE colony_id = 1 AND status = 'aggregating' LIMIT 1";
$poolResult = $conn->query($poolQuery);

if ($poolResult->num_rows > 0) {
    $poolData = $poolResult->fetch_assoc();
    
    // 2. Fetch the standard product catalog
    $productsQuery = "SELECT product_id, name, brand, unit_size, base_price FROM products";
    $productsResult = $conn->query($productsQuery);
    
    $products = [];
    while($row = $productsResult->fetch_assoc()) {
        $products[] = $row;
    }
    
    // Return both the timer data and the products
    echo json_encode([
        "status" => "success",
        "pool_id" => $poolData['pool_id'],
        "closes_at" => $poolData['closes_at'],
        "products" => $products
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "No active order pool found for this colony."]);
}

$conn->close();
?>