<?php
// Simple helper to generate a bcrypt hash for a given password.
// Usage (development only):
//   http://localhost/sche_do_project/backend_api/hash_password.php?pw=yourpassword
// This will output JSON like {"hash":"$2y$..."} which you can then copy into your users table.

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$password = $_GET['pw'] ?? '';
if ($password === '') {
    echo json_encode(['success' => false, 'message' => 'Missing pw parameter']);
    exit;
}

$hash = password_hash($password, PASSWORD_DEFAULT);

echo json_encode(['success' => true, 'hash' => $hash]);
