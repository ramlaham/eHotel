<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo     = getDB();
    $room_id = $_POST['room_id'] ?? '';

    if (!$room_id) {
        echo json_encode(['success' => false, 'error' => 'room_id is required']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM room WHERE room_id = :room_id");
    $stmt->execute([':room_id' => (int)$room_id]);
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    $msg = $e->getMessage();
    if (strpos($msg, 'foreign key') !== false || strpos($msg, 'violates') !== false) {
        echo json_encode(['success' => false, 'error' => 'Cannot delete: room has associated reservations or rentals']);
    } else {
        echo json_encode(['success' => false, 'error' => $msg]);
    }
}
