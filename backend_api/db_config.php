<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "appointment_db";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
// ตั้งค่าให้รองรับภาษาไทย
$conn->set_charset("utf8");
?>