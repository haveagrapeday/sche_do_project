<?php
include "db_connect.php";

$task_id = $_POST['task_id'];
$subject = $_POST['subject'];
$description = $_POST['description'];
$category = $_POST['category'];
$priority = $_POST['priority'];

$sql = "UPDATE tasks SET 
        subject = '$subject', 
        description = '$description', 
        category = '$category', 
        priority = '$priority' 
        WHERE id = '$task_id'";

if($conn->query($sql)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false]);
}
?>