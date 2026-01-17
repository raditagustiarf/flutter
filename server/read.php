<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'connection.php';

$query = "SELECT * FROM items ORDER BY id DESC";
$result = mysqli_query($conn, $query);

$response = array();

if (mysqli_num_rows($result) > 0) {
    while ($row = mysqli_fetch_assoc($result)) {
        $row['qty'] = (int)$row['qty']; 
        $row['id'] = (int)$row['id']; 
        
        $response[] = $row;
    }
}

echo json_encode($response);
?>