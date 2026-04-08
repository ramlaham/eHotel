<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo    = getDB();
    $status = $_GET['status'] ?? 'active';

    $stmt = $pdo->prepare("
        SELECT res.reservation_id, res.start_date, res.end_date, res.status,
               c.full_name AS client_name, c.client_id,
               r.room_id, r.capacity, r.price,
               h.address AS hotel_address, h.hotel_id
        FROM reservation res
        JOIN client c ON res.client_id = c.client_id
        JOIN room r ON res.room_id = r.room_id
        JOIN hotel h ON r.hotel_id = h.hotel_id
        WHERE res.status = :status
        ORDER BY res.start_date ASC
    ");
    $stmt->execute([':status' => $status]);
    $reservations = $stmt->fetchAll();

    echo json_encode(['success' => true, 'data' => $reservations]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
