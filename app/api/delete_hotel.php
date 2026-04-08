<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo      = getDB();
    $hotel_id = $_POST['hotel_id'] ?? '';

    if (!$hotel_id) {
        echo json_encode(['success' => false, 'error' => 'hotel_id is required']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT chain_id FROM hotel WHERE hotel_id = :hotel_id");
    $stmt->execute([':hotel_id' => (int)$hotel_id]);
    $hotel = $stmt->fetch();

    if (!$hotel) {
        echo json_encode(['success' => false, 'error' => 'Hotel not found']);
        exit;
    }

    $pdo->beginTransaction();

    $pdo->prepare("DELETE FROM hotel WHERE hotel_id = :hotel_id")
        ->execute([':hotel_id' => (int)$hotel_id]);

    $pdo->prepare("UPDATE hotel_chain SET num_hotels = num_hotels - 1 WHERE chain_id = :chain_id")
        ->execute([':chain_id' => (int)$hotel['chain_id']]);

    $pdo->commit();
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    $msg = $e->getMessage();
    if (strpos($msg, 'foreign key') !== false || strpos($msg, 'violates') !== false) {
        echo json_encode(['success' => false, 'error' => 'Cannot delete: hotel has associated rooms or employees']);
    } else {
        echo json_encode(['success' => false, 'error' => $msg]);
    }
}
