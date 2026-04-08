<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo = getDB();

    $room_id     = $_POST['room_id']     ?? '';
    $start_date  = $_POST['start_date']  ?? '';
    $end_date    = $_POST['end_date']    ?? '';
    $client_type = $_POST['client_type'] ?? 'existing';
    $client_id   = $_POST['client_id']  ?? '';

    if (!$room_id || !$start_date || !$end_date) {
        echo json_encode(['success' => false, 'error' => 'room_id, start_date, and end_date are required']);
        exit;
    }

    $pdo->beginTransaction();

    if ($client_type === 'new') {
        $full_name = trim($_POST['full_name'] ?? '');
        $ssn       = trim($_POST['ssn']       ?? '');
        $address   = trim($_POST['address']   ?? '');

        if (!$full_name || !$ssn) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'error' => 'full_name and ssn are required for new clients']);
            exit;
        }

        $stmt = $pdo->prepare("INSERT INTO client (full_name, ssn, address) VALUES (:full_name, :ssn, :address) RETURNING client_id");
        $stmt->execute([':full_name' => $full_name, ':ssn' => $ssn, ':address' => $address]);
        $client_id = $stmt->fetchColumn();
    }

    if (!$client_id) {
        $pdo->rollBack();
        echo json_encode(['success' => false, 'error' => 'A valid client is required']);
        exit;
    }

    $stmt = $pdo->prepare("
        INSERT INTO reservation (client_id, room_id, start_date, end_date)
        VALUES (:client_id, :room_id, :start_date, :end_date)
        RETURNING reservation_id
    ");
    $stmt->execute([
        ':client_id'  => (int)$client_id,
        ':room_id'    => (int)$room_id,
        ':start_date' => $start_date,
        ':end_date'   => $end_date,
    ]);
    $reservation_id = $stmt->fetchColumn();

    $pdo->commit();
    echo json_encode(['success' => true, 'reservation_id' => $reservation_id]);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
