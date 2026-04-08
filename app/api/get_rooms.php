<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo      = getDB();
    $hotel_id = $_GET['hotel_id'] ?? '';

    if ($hotel_id) {
        $stmt = $pdo->prepare("
            SELECT r.*, h.address AS hotel_address
            FROM room r
            JOIN hotel h ON r.hotel_id = h.hotel_id
            WHERE r.hotel_id = :hotel_id
            ORDER BY r.room_id
        ");
        $stmt->execute([':hotel_id' => (int)$hotel_id]);
    } else {
        $stmt = $pdo->query("
            SELECT r.*, h.address AS hotel_address
            FROM room r
            JOIN hotel h ON r.hotel_id = h.hotel_id
            ORDER BY r.hotel_id, r.room_id
        ");
    }

    $rooms = $stmt->fetchAll();
    echo json_encode(['success' => true, 'data' => $rooms]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
