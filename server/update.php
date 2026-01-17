<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once 'connection.php';

$json = file_get_contents("php://input");
$data = json_decode($json);

if (isset($data->id) && isset($data->name) && isset($data->qty)) {
    
    $id = $data->id;
    $name = $data->name;
    $qty = $data->qty;
    $desc = $data->description;

    $query = "UPDATE items SET name='$name', qty='$qty', description='$desc' WHERE id='$id'";

    if (mysqli_query($conn, $query)) {
        echo json_encode(["message" => "Sukses Update"]);
    } else {
        echo json_encode(["message" => "Gagal SQL"]);
    }
} else {
    echo json_encode(["message" => "Data Tidak Lengkap"]);
}
?>