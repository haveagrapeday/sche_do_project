<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$username = $_GET['username'] ?? '';
if ($username === '') {
    echo json_encode(['success' => false, 'message' => 'Missing username']);
    exit;
}

$username = $conn->real_escape_string($username);
$sql = "SELECT * FROM users WHERE username = '$username' LIMIT 1";
$result = $conn->query($sql);

if (!$result) {
    echo json_encode(['success' => false, 'message' => 'Query error', 'error' => $conn->error]);
    $conn->close();
    exit;
}

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'User not found']);
    $conn->close();
    exit;
}

$row = $result->fetch_assoc();
// Return password hash too (for debugging only)
// In production you should never expose password hashes.

$row['password_length'] = strlen($row['password']);
$row['password_hex'] = bin2hex($row['password']);

echo json_encode(['success' => true, 'user' => $row]);

$conn->close();
