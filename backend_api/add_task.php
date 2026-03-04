<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$subject = $_POST['subject'] ?? '';
$description = $_POST['description'] ?? '';
$app_date = $_POST['app_date'] ?? '';
$app_time = $_POST['app_time'] ?? '';

if (empty($subject) || empty($app_date) || empty($app_time)) {
    echo json_encode(['success' => false, 'message' => 'Required fields missing']);
    $conn->close();
    exit;
}

// sanitize inputs
$subject = $conn->real_escape_string($subject);
$app_date = $conn->real_escape_string($app_date);
$app_time = $conn->real_escape_string($app_time);
$description = $conn->real_escape_string($description);

$sql = "INSERT INTO tasks (subject, app_date, app_time, description) VALUES ('$subject', '$app_date', '$app_time', '$description')";

if ($conn->query($sql)) {
    echo json_encode(['success' => true, 'message' => 'Task added']);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
}

$conn->close();
?>