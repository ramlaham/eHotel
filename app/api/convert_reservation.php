<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo = getDB();

    $reservation_id = $_POST['reservation_id'] ?? '';
    $employee_id    = $_POST['employee_id']    ?? '';

    if (!$reservation_id || !$employee_id) {
        echo json_encode(['success' => false, 'error' => 'reservation_id and employee_id are required']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT * FROM reservation WHERE reservation_id = :id AND status = 'active'");
    $stmt->execute([':id' => (int)$reservation_id]);
    $res = $stmt->fetch();

    if (!$res) {
        echo json_encode(['success' => false, 'error' => 'Reservation not found or not active']);
        exit;
    }

    $pdo->beginTransaction();

    $stmt = $pdo->prepare("
        INSERT INTO rental (reservation_id, client_id, room_id, employee_id, start_date, end_date)
        VALUES (:reservation_id, :client_id, :room_id, :employee_id, :start_date, :end_date)
        RETURNING rental_id
    ");
    $stmt->execute([
        ':reservation_id' => (int)$reservation_id,
        ':client_id'      => (int)$res['client_id'],
        ':room_id'        => (int)$res['room_id'],
        ':employee_id'    => (int)$employee_id,
        ':start_date'     => $res['start_date'],
        ':end_date'       => $res['end_date'],
    ]);
    $rental_id = $stmt->fetchColumn();

    $pdo->commit();
    echo json_encode(['success' => true, 'rental_id' => $rental_id]);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
