<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include_once 'connection.php';

$json = file_get_contents("php://input");
$data = json_decode($json);

if (isset($data->username) && isset($data->password)) {
    $username = $data->username;
    $password = $data->password;

    $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        echo json_encode([
            "success" => true,
            "message" => "Login Berhasil sebagai " . $row['role'],
            "user_data" => [
                "id" => $row['id'],
                "username" => $row['username'],
                "full_name" => $row['full_name'],
                "role" => $row['role']
            ]
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Username atau Password salah"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
}
?>