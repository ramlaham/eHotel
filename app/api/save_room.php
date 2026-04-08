<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo        = getDB();
    $room_id    = $_POST['room_id']    ?? '';
    $hotel_id   = $_POST['hotel_id']   ?? '';
    $price      = $_POST['price']      ?? '';
    $amenities  = trim($_POST['amenities']  ?? '');
    $capacity   = $_POST['capacity']   ?? '';
    $view       = $_POST['view']       ?? '';
    $extendable = isset($_POST['extendable']) && ($_POST['extendable'] === '1' || $_POST['extendable'] === 'true') ? true : false;
    $damages    = trim($_POST['damages'] ?? '');

    if (!$hotel_id || !$price || !$capacity || !$view) {
        echo json_encode(['success' => false, 'error' => 'hotel_id, price, capacity, and view are required']);
        exit;
    }

    if ($room_id) {
        $stmt = $pdo->prepare("
            UPDATE room SET hotel_id = :hotel_id, price = :price, amenities = :amenities,
                            capacity = :capacity, view = :view, extendable = :extendable, damages = :damages
            WHERE room_id = :room_id
        ");
        $stmt->execute([
            ':hotel_id'   => (int)$hotel_id,
            ':price'      => (float)$price,
            ':amenities'  => $amenities ?: null,
            ':capacity'   => $capacity,
            ':view'       => $view,
            ':extendable' => $extendable,
            ':damages'    => $damages ?: null,
            ':room_id'    => (int)$room_id,
        ]);
        echo json_encode(['success' => true, 'room_id' => (int)$room_id]);
    } else {
        $stmt = $pdo->prepare("
            INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages)
            VALUES (:hotel_id, :price, :amenities, :capacity, :view, :extendable, :damages)
            RETURNING room_id
        ");
        $stmt->execute([
            ':hotel_id'   => (int)$hotel_id,
            ':price'      => (float)$price,
            ':amenities'  => $amenities ?: null,
            ':capacity'   => $capacity,
            ':view'       => $view,
            ':extendable' => $extendable,
            ':damages'    => $damages ?: null,
        ]);
        $new_id = $stmt->fetchColumn();
        echo json_encode(['success' => true, 'room_id' => $new_id]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
