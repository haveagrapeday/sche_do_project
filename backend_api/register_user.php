<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Missing fields']);
    $conn->close();
    exit;
}

// sanitize input
$username = $conn->real_escape_string($username);
// hash password before storing
$password_hash = password_hash($password, PASSWORD_DEFAULT);

$sql = "INSERT INTO users (username, password) VALUES ('$username', '$password_hash')";

if ($conn->query($sql)) {
    echo json_encode(['success' => true, 'message' => 'User registered']);
} else {
    // if duplicate key or other error
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
}

$conn->close();
?>
