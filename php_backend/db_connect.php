<?php
// db_connect.php
$servername = "localhost";
$username = "root"; // Default XAMPP/MySQL username
$password = ""; // Default XAMPP/MySQL password (usually blank)
$dbname = "bulk_grocery";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}
?>