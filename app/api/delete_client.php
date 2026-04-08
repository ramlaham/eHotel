<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo       = getDB();
    $client_id = $_POST['client_id'] ?? '';

    if (!$client_id) {
        echo json_encode(['success' => false, 'error' => 'client_id is required']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM client WHERE client_id = :client_id");
    $stmt->execute([':client_id' => (int)$client_id]);
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    $msg = $e->getMessage();
    if (strpos($msg, 'foreign key') !== false || strpos($msg, 'violates') !== false) {
        echo json_encode(['success' => false, 'error' => 'Cannot delete: client has associated reservations or rentals']);
    } else {
        echo json_encode(['success' => false, 'error' => $msg]);
    }
}
