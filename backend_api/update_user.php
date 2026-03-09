<?php
// Hide warnings/notices so the response is valid JSON (Flutter expects strict JSON)
error_reporting(0);
ini_set('display_errors', '0');

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$user_id = $_POST['user_id'] ?? '';
$email = $_POST['email'] ?? '';

if (empty($user_id) || empty($email)) {
    echo json_encode(['success' => false, 'message' => 'Missing fields']);
    $conn->close();
    exit;
}

$user_id = $conn->real_escape_string($user_id);
$email = $conn->real_escape_string($email);

$sql = "UPDATE users SET email = '$email' WHERE user_id = '$user_id'";

if ($conn->query($sql)) {
    echo json_encode(['success' => true, 'message' => 'Profile updated']);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
}

$conn->close();
