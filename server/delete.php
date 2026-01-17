<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once 'connection.php';

$json = file_get_contents("php://input");
$data = json_decode($json);

if (isset($data->id)) {
    $id = $data->id;

    $query = "DELETE FROM items WHERE id='$id'";

    if (mysqli_query($conn, $query)) {
        echo json_encode(["message" => "Sukses Hapus"]);
    } else {
        echo json_encode(["message" => "Gagal SQL"]);
    }
} else {
    echo json_encode(["message" => "ID Tidak Ditemukan"]);
}
?>