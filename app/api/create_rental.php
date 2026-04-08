<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo = getDB();

    $room_id     = $_POST['room_id']     ?? '';
    $start_date  = $_POST['start_date']  ?? '';
    $end_date    = $_POST['end_date']    ?? '';
    $employee_id = $_POST['employee_id'] ?? '';
    $client_type = $_POST['client_type'] ?? 'existing';
    $client_id   = $_POST['client_id']   ?? '';

    if (!$room_id || !$start_date || !$end_date || !$employee_id) {
        echo json_encode(['success' => false, 'error' => 'room_id, start_date, end_date, and employee_id are required']);
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
        INSERT INTO rental (reservation_id, client_id, room_id, employee_id, start_date, end_date)
        VALUES (NULL, :client_id, :room_id, :employee_id, :start_date, :end_date)
        RETURNING rental_id
    ");
    $stmt->execute([
        ':client_id'   => (int)$client_id,
        ':room_id'     => (int)$room_id,
        ':employee_id' => (int)$employee_id,
        ':start_date'  => $start_date,
        ':end_date'    => $end_date,
    ]);
    $rental_id = $stmt->fetchColumn();

    $pdo->commit();
    echo json_encode(['success' => true, 'rental_id' => $rental_id]);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
