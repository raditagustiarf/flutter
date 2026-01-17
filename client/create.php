<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include_once 'connection.php';

$json = file_get_contents("php://input");
$data = json_decode($json);

if(isset($data->name) && isset($data->qty)) {
    $name = $data->name;
    $qty = $data->qty;
    $desc = $data->description;

    $query = "INSERT INTO items (name, qty, description) VALUES ('$name', '$qty', '$desc')";
    
    if(mysqli_query($conn, $query)){
        echo json_encode(["message" => "Sukses"]);
    } else {
        echo json_encode(["message" => "Gagal SQL"]);
    }
} else {
    echo json_encode(["message" => "Data Kosong"]);
}
?>