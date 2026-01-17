<?php
$host = 'localhost';
$user = 'root';
$pass = '';
$db   = 'db_inventory';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["message" => "Connection failed: " . $conn->connect_error]));
}

header('Content-Type: application/json');
?>