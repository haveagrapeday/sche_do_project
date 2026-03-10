<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php'; 

// Retrieve POST data safely
$task_id     = $_POST['task_id']     ?? '';
$subject     = $_POST['subject']     ?? '';
$description = $_POST['description'] ?? '';
$category    = $_POST['category']    ?? '';
$priority    = $_POST['priority']    ?? '';
$status      = $_POST['status']      ?? ''; // เพิ่มการรับค่า status
$app_date    = $_POST['app_date']    ?? '';
$app_time    = $_POST['app_time']    ?? '';

if ($task_id === '') {
    echo json_encode(["success" => false, "error" => "missing task_id"]);
    exit;
}

// Escape values
$task_id     = $conn->real_escape_string($task_id);
$subject     = $conn->real_escape_string($subject);
$description = $conn->real_escape_string($description);
$category    = $conn->real_escape_string($category);
$priority    = $conn->real_escape_string($priority);
$status      = $conn->real_escape_string($status); // escape status
$app_date    = $conn->real_escape_string($app_date);
$app_time    = $conn->real_escape_string($app_time);

// เพิ่ม status ในคำสั่ง SQL UPDATE
$sql = "UPDATE tasks SET 
            subject     = '$subject', 
            description = '$description', 
            category    = '$category', 
            priority    = '$priority',
            status      = '$status', 
            app_date    = '$app_date',
            app_time    = '$app_time'
         WHERE id = '$task_id'";

if ($conn->query($sql)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => $conn->error]);
}

$conn->close();
?>