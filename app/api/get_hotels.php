<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo      = getDB();
    $chain_id = $_GET['chain_id'] ?? '';

    if ($chain_id) {
        $stmt = $pdo->prepare("
            SELECT h.*, hc.name AS chain_name
            FROM hotel h
            JOIN hotel_chain hc ON h.chain_id = hc.chain_id
            WHERE h.chain_id = :chain_id
            ORDER BY h.address
        ");
        $stmt->execute([':chain_id' => (int)$chain_id]);
    } else {
        $stmt = $pdo->query("
            SELECT h.*, hc.name AS chain_name
            FROM hotel h
            JOIN hotel_chain hc ON h.chain_id = hc.chain_id
            ORDER BY hc.name, h.address
        ");
    }

    $hotels = $stmt->fetchAll();
    echo json_encode(['success' => true, 'data' => $hotels]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
