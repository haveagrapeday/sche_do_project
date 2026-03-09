<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

// Allow filtering tasks by user_id (sent from the Flutter app)
$user_id = $_GET['user_id'] ?? $_POST['user_id'] ?? '';

if (!empty($user_id)) {
    $user_id = $conn->real_escape_string($user_id);
    $sql = "SELECT * FROM tasks WHERE user_id = '$user_id'";
} else {
    $sql = "SELECT * FROM tasks";
}

$result = $conn->query($sql);

$tasks = array();
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $tasks[] = $row;
    }
}

echo json_encode($tasks, JSON_UNESCAPED_UNICODE);
$conn->close();
?>