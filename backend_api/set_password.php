<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$username = $_GET['username'] ?? '';
$password = $_GET['pw'] ?? '';

if ($username === '' || $password === '') {
    echo json_encode(['success' => false, 'message' => 'Missing username or pw']);
    exit;
}

$username = $conn->real_escape_string($username);
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

$sql = "UPDATE users SET password = '$passwordHash' WHERE username = '$username'";

if ($conn->query($sql)) {
    echo json_encode(['success' => true, 'message' => 'Password updated', 'hash' => $passwordHash]);
} else {
    echo json_encode(['success' => false, 'message' => 'Update failed', 'error' => $conn->error]);
}

$conn->close();
