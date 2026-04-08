<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo      = getDB();
    $hotel_id = $_POST['hotel_id'] ?? '';
    $chain_id = $_POST['chain_id'] ?? '';
    $category = $_POST['category'] ?? '';
    $address  = trim($_POST['address'] ?? '');
    $email    = trim($_POST['email']   ?? '');
    $phone    = trim($_POST['phone']   ?? '');

    if (!$chain_id || !$category || !$address) {
        echo json_encode(['success' => false, 'error' => 'chain_id, category, and address are required']);
        exit;
    }

    if ($hotel_id) {
        $stmt = $pdo->prepare("
            UPDATE hotel SET chain_id = :chain_id, category = :category,
                             address = :address, email = :email, phone = :phone
            WHERE hotel_id = :hotel_id
        ");
        $stmt->execute([
            ':chain_id' => (int)$chain_id,
            ':category' => (int)$category,
            ':address'  => $address,
            ':email'    => $email,
            ':phone'    => $phone,
            ':hotel_id' => (int)$hotel_id,
        ]);
        echo json_encode(['success' => true, 'hotel_id' => (int)$hotel_id]);
    } else {
        $stmt = $pdo->prepare("
            INSERT INTO hotel (chain_id, category, address, email, phone)
            VALUES (:chain_id, :category, :address, :email, :phone)
            RETURNING hotel_id
        ");
        $stmt->execute([
            ':chain_id' => (int)$chain_id,
            ':category' => (int)$category,
            ':address'  => $address,
            ':email'    => $email,
            ':phone'    => $phone,
        ]);
        $new_id = $stmt->fetchColumn();

        $pdo->prepare("UPDATE hotel_chain SET num_hotels = num_hotels + 1 WHERE chain_id = :chain_id")
            ->execute([':chain_id' => (int)$chain_id]);

        echo json_encode(['success' => true, 'hotel_id' => $new_id]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
