<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo         = getDB();
    $employee_id = $_POST['employee_id'] ?? '';
    $full_name   = trim($_POST['full_name'] ?? '');
    $ssn         = trim($_POST['ssn']       ?? '');
    $address     = trim($_POST['address']   ?? '');
    $role        = trim($_POST['role']      ?? '');
    $hotel_id    = $_POST['hotel_id']       ?? null;

    if (!$full_name || !$ssn) {
        echo json_encode(['success' => false, 'error' => 'full_name and ssn are required']);
        exit;
    }

    if ($employee_id) {
        $stmt = $pdo->prepare("
            UPDATE employee SET full_name = :full_name, ssn = :ssn, address = :address,
                                role = :role, hotel_id = :hotel_id
            WHERE employee_id = :employee_id
        ");
        $stmt->execute([
            ':full_name'   => $full_name,
            ':ssn'         => $ssn,
            ':address'     => $address,
            ':role'        => $role,
            ':hotel_id'    => $hotel_id ? (int)$hotel_id : null,
            ':employee_id' => (int)$employee_id,
        ]);
        echo json_encode(['success' => true, 'employee_id' => (int)$employee_id]);
    } else {
        $stmt = $pdo->prepare("
            INSERT INTO employee (full_name, ssn, address, role, hotel_id)
            VALUES (:full_name, :ssn, :address, :role, :hotel_id)
            RETURNING employee_id
        ");
        $stmt->execute([
            ':full_name' => $full_name,
            ':ssn'       => $ssn,
            ':address'   => $address,
            ':role'      => $role,
            ':hotel_id'  => $hotel_id ? (int)$hotel_id : null,
        ]);
        $new_id = $stmt->fetchColumn();
        echo json_encode(['success' => true, 'employee_id' => $new_id]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
