<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

// รับ id ของ task ที่จะลบ
$task_id = $_POST['task_id'] ?? '';

if ($task_id === '') {
    echo json_encode(["success" => false, "error" => "missing task_id"]);
    exit;
}

// ป้องกัน SQL injection
$task_id = $conn->real_escape_string($task_id);

// ตรวจสอบให้มั่นใจว่าชื่อคอลัมน์ใน DB คือ 'id' (หรือชื่อที่คุณตั้งไว้)
$sql = "DELETE FROM tasks WHERE id = '$task_id'";

if ($conn->query($sql)) {
    echo json_encode(["success" => true]);
} else {
    // ถ้าลบไม่สำเร็จ ให้ส่ง error กลับมาดู
    echo json_encode(["success" => false, "error" => $conn->error]);
}

$conn->close();
?>