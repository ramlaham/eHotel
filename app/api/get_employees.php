<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo      = getDB();
    $hotel_id = $_GET['hotel_id'] ?? '';

    if ($hotel_id) {
        $stmt = $pdo->prepare("
            SELECT e.*, h.address AS hotel_address
            FROM employee e
            LEFT JOIN hotel h ON e.hotel_id = h.hotel_id
            WHERE e.hotel_id = :hotel_id
            ORDER BY e.full_name
        ");
        $stmt->execute([':hotel_id' => (int)$hotel_id]);
    } else {
        $stmt = $pdo->query("
            SELECT e.*, h.address AS hotel_address
            FROM employee e
            LEFT JOIN hotel h ON e.hotel_id = h.hotel_id
            ORDER BY e.full_name
        ");
    }

    $employees = $stmt->fetchAll();
    echo json_encode(['success' => true, 'data' => $employees]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
