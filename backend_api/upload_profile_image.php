<?php
// Hide warnings/notices so the response is valid JSON (Flutter expects strict JSON)
error_reporting(0);
ini_set('display_errors', '0');

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_config.php';

$user_id = $_POST['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(['success' => false, 'message' => 'Missing user_id']);
    $conn->close();
    exit;
}

// Validate and normalize user_id
$user_id = $conn->real_escape_string($user_id);

if (!isset($_FILES['profile_image']) || $_FILES['profile_image']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(['success' => false, 'message' => 'No image uploaded']);
    $conn->close();
    exit;
}

$file = $_FILES['profile_image'];
$allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];

if (!in_array($file['type'], $allowedTypes, true)) {
    echo json_encode(['success' => false, 'message' => 'Unsupported image type']);
    $conn->close();
    exit;
}

$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
if (empty($ext)) {
    $ext = $file['type'] === 'image/png' ? 'png' : 'jpg';
}

$uploadBase = __DIR__ . '/uploads/profile';
if (!is_dir($uploadBase)) {
    mkdir($uploadBase, 0755, true);
}

$filename = sprintf('profile_%s_%s.%s', $user_id, time(), $ext);
$destination = $uploadBase . '/' . $filename;

if (!move_uploaded_file($file['tmp_name'], $destination)) {
    echo json_encode(['success' => false, 'message' => 'Unable to save image']);
    $conn->close();
    exit;
}

// Build URL for client (assuming 10.0.2.2 for emulator)
$profileUrl = "http://10.0.2.2/sche_do_project/backend_api/uploads/profile/" . $filename;

$sql = "UPDATE users SET profile_image = '$profileUrl' WHERE user_id = '$user_id'";
if ($conn->query($sql)) {
    echo json_encode(['success' => true, 'message' => 'Profile image updated', 'profile_image' => $profileUrl]);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
}

$conn->close();
