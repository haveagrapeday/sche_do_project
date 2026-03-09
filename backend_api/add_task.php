<?php
// Hide warnings/notices so the response is valid JSON (Flutter expects strict JSON)
error_reporting(0);
ini_set('display_errors', '0');

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$user_id     = $_POST['user_id'] ?? ''; // รับค่าจาก Flutter
$subject     = $_POST['subject'] ?? '';
$description = $_POST['description'] ?? '';
$app_date    = $_POST['app_date'] ?? '';
$app_time    = $_POST['app_time'] ?? '';

// เพิ่มการตรวจสอบว่ามี user_id ส่งมาหรือไม่
if (empty($user_id) || empty($subject) || empty($app_date) || empty($app_time)) {
    echo json_encode(['success' => false, 'message' => 'Required fields missing']);
    $conn->close();
    exit;
}

// sanitize inputs
$user_id     = $conn->real_escape_string($user_id);
$subject     = $conn->real_escape_string($subject);
$app_date    = $conn->real_escape_string($app_date);
$app_time    = $conn->real_escape_string($app_time);
$description = $conn->real_escape_string($description);

// ใส่ $user_id ลงใน SQL Query
$sql = "INSERT INTO tasks (user_id, subject, app_date, app_time, description) 
        VALUES ('$user_id', '$subject', '$app_date', '$app_time', '$description')";

if ($conn->query($sql)) {
    echo json_encode(['success' => true, 'message' => 'Task added']);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
}

$conn->close();
?>