<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo  = getDB();
    $stmt = $pdo->query("SELECT * FROM hotel_chain ORDER BY name");
    $chains = $stmt->fetchAll();
    echo json_encode(['success' => true, 'data' => $chains]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
