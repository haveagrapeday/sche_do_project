<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$password = $_GET['pw'] ?? '';
$hash = $_GET['hash'] ?? '';

if ($password === '' || $hash === '') {
    echo json_encode(['success' => false, 'message' => 'Missing pw or hash']);
    exit;
}

$result = password_verify($password, $hash);

echo json_encode(['success' => true, 'match' => $result]);
