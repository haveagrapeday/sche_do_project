<?php
include "db_connect.php";
$task_id = $_POST['task_id'];
$status = $_POST['status'];
$sql = "UPDATE tasks SET status = '$status' WHERE id = '$task_id'";
if($conn->query($sql)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false]);
}
?>
