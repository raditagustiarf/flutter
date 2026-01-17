<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include_once 'connection.php';

$json = file_get_contents("php://input");
$data = json_decode($json);

if (isset($data->username) && isset($data->password)) {
    $username = $data->username;
    $password = $data->password;
    $fullname = isset($data->full_name) ? $data->full_name : '';

    $check = mysqli_query($conn, "SELECT * FROM users WHERE username='$username'");
    if(mysqli_num_rows($check) > 0){
        echo json_encode(["success" => false, "message" => "Username sudah terdaftar!"]);
        exit();
    }

    $query = "INSERT INTO users (username, password, full_name) VALUES ('$username', '$password', '$fullname')";

    if (mysqli_query($conn, $query)) {
        echo json_encode(["success" => true, "message" => "Register Berhasil"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal SQL"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
}
?>