<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$password = $_GET['pw'] ?? '';
if ($password === '') {
    echo json_encode(['success' => false, 'message' => 'Missing pw parameter']);
    exit;
}

$hash = password_hash($password, PASSWORD_DEFAULT);

echo json_encode(['success' => true, 'hash' => $hash]);
