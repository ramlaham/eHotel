<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo         = getDB();
    $employee_id = $_POST['employee_id'] ?? '';

    if (!$employee_id) {
        echo json_encode(['success' => false, 'error' => 'employee_id is required']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM employee WHERE employee_id = :employee_id");
    $stmt->execute([':employee_id' => (int)$employee_id]);
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    $msg = $e->getMessage();
    if (strpos($msg, 'foreign key') !== false || strpos($msg, 'violates') !== false) {
        echo json_encode(['success' => false, 'error' => 'Cannot delete: employee has associated rentals']);
    } else {
        echo json_encode(['success' => false, 'error' => $msg]);
    }
}
