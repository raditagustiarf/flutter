<?php
require_once 'connection.php';

$sql = "SELECT * FROM items ORDER BY id DESC";
$result = $conn->query($sql);

$items = [];
while ($row = $result->fetch_assoc()) {
    $items[] = $row;
}

echo json_encode($items);
?>