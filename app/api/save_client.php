<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo       = getDB();
    $client_id = $_POST['client_id'] ?? '';
    $full_name = trim($_POST['full_name'] ?? '');
    $ssn       = trim($_POST['ssn']       ?? '');
    $address   = trim($_POST['address']   ?? '');

    if (!$full_name || !$ssn) {
        echo json_encode(['success' => false, 'error' => 'full_name and ssn are required']);
        exit;
    }

    if ($client_id) {
        $stmt = $pdo->prepare("
            UPDATE client SET full_name = :full_name, ssn = :ssn, address = :address
            WHERE client_id = :client_id
        ");
        $stmt->execute([
            ':full_name' => $full_name,
            ':ssn'       => $ssn,
            ':address'   => $address,
            ':client_id' => (int)$client_id,
        ]);
        echo json_encode(['success' => true, 'client_id' => (int)$client_id]);
    } else {
        $stmt = $pdo->prepare("
            INSERT INTO client (full_name, ssn, address) VALUES (:full_name, :ssn, :address)
            RETURNING client_id
        ");
        $stmt->execute([':full_name' => $full_name, ':ssn' => $ssn, ':address' => $address]);
        $new_id = $stmt->fetchColumn();
        echo json_encode(['success' => true, 'client_id' => $new_id]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
