<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// เชื่อมต่อ Database
$conn = new mysqli("localhost", "root", "", "sche_do_db");

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed"]));
}

$username = isset($_GET['username']) ? $_GET['username'] : '';

// ดึงข้อมูลจากตาราง users
$sql = "SELECT username, full_name, email FROM users WHERE username = '$username'";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    echo json_encode($result->fetch_assoc());
} else {
    // กรณีไม่พบข้อมูล ให้คืนค่าเริ่มต้น
    echo json_encode([
        "username" => $username,
        "full_name" => "Guest User",
        "email" => "not_set@mail.com"
    ]);
}

$conn->close();
?>