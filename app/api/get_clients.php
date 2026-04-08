<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo    = getDB();
    $search = $_GET['search'] ?? '';

    if ($search !== '') {
        $stmt = $pdo->prepare("
            SELECT * FROM client
            WHERE LOWER(full_name) LIKE :s OR ssn LIKE :s2
            ORDER BY full_name
        ");
        $like = '%' . strtolower($search) . '%';
        $stmt->execute([':s' => $like, ':s2' => $like]);
    } else {
        $stmt = $pdo->query("SELECT * FROM client ORDER BY full_name");
    }

    $clients = $stmt->fetchAll();
    echo json_encode(['success' => true, 'data' => $clients]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
