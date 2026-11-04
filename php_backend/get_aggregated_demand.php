<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

require 'db_connect.php';

// Get the active pool
$poolQuery = $conn->query("SELECT pool_id, closes_at FROM order_pools ORDER BY pool_id DESC LIMIT 1");

if ($poolQuery->num_rows == 0) {
    echo json_encode(["status" => "error", "message" => "No active pool found."]);
    exit();
}

$pool = $poolQuery->fetch_assoc();
$pool_id = $pool['pool_id'];

// Aggregate the total demand from all users in this pool
$sql = "SELECT p.name, p.unit_size, SUM(o.quantity) as total_quantity 
        FROM pool_orders o 
        JOIN products p ON o.product_id = p.product_id 
        WHERE o.pool_id = ? 
        GROUP BY p.product_id";
        
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $pool_id);
$stmt->execute();
$result = $stmt->get_result();

$demand = [];
while ($row = $result->fetch_assoc()) {
    $demand[] = $row;
}

echo json_encode([
    "status" => "success",
    "pool_id" => $pool_id,
    "closes_at" => $pool['closes_at'],
    "items" => $demand
]);

$stmt->close();
$conn->close();
?>