<?php
// Hide warnings/notices so the response is valid JSON (Flutter expects strict JSON)
error_reporting(0);
ini_set('display_errors', '0');

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

// sanitize input (trim เพิ่มความแน่ใจว่าไม่มีช่องว่างแปลกๆ)
$username = trim($conn->real_escape_string($username));

$sql = "SELECT user_id, password, profile_image, email FROM users WHERE username = '$username' LIMIT 1";
$result = $conn->query($sql);

if ($result && $result->num_rows === 1) {
    $row = $result->fetch_assoc();
    $storedPassword = $row['password'];

    // ใช้ password_verify อย่างเดียว (เพื่อความปลอดภัยและเป็นมาตรฐาน)
    if (password_verify($password, $storedPassword)) {
        // Generate a token safely based on available PHP functions.
    if (function_exists('random_bytes')) {
        $token = bin2hex(random_bytes(16));
    } elseif (function_exists('openssl_random_pseudo_bytes')) {
        $token = bin2hex(openssl_random_pseudo_bytes(16));
    } else {
        // Fallback for very old PHP versions (not cryptographically secure).
        $token = bin2hex(mt_rand(0, PHP_INT_MAX) . uniqid('', true));
    }

    echo json_encode([
        'success' => true,
        'message' => 'Login successful',
        'token' => $token,
        'user_id' => $row['user_id'],
        'username' => $username,
        'email' => $row['email'] ?? '',
        'profile_image' => $row['profile_image'] ?? null,
    ]);
    $conn->close();
    exit;
    }  
}

echo json_encode(['success' => false, 'message' => 'Invalid username or password']);

$conn->close();
?>