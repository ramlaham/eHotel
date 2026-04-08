<?php
header('Content-Type: application/json');
require_once '../config.php';

try {
    $pdo = getDB();

    $check_in  = $_GET['check_in']  ?? '';
    $check_out = $_GET['check_out'] ?? '';
    $capacity  = $_GET['capacity']  ?? '';
    $zone      = $_GET['zone']      ?? '';
    $chain_id  = $_GET['chain_id']  ?? '';
    $category  = $_GET['category']  ?? '';
    $max_price = $_GET['max_price'] ?? '';
    $extendable = $_GET['extendable'] ?? '';

    if (!$check_in || !$check_out) {
        echo json_encode(['success' => false, 'error' => 'check_in and check_out are required']);
        exit;
    }

    $sql = "
        SELECT r.room_id, r.hotel_id, r.price, r.amenities, r.capacity, r.view,
               r.extendable, r.damages,
               h.address, h.category,
               hc.name AS chain_name, hc.chain_id,
               SPLIT_PART(h.address, ', ', 2) AS city
        FROM room r
        JOIN hotel h ON r.hotel_id = h.hotel_id
        JOIN hotel_chain hc ON h.chain_id = hc.chain_id
        WHERE r.room_id NOT IN (
            SELECT room_id FROM reservation
            WHERE status = 'active'
              AND start_date < :check_out1
              AND end_date   > :check_in1
            UNION
            SELECT room_id FROM rental
            WHERE start_date < :check_out2
              AND end_date   > :check_in2
        )
    ";

    $params = [
        ':check_in1'  => $check_in,
        ':check_out1' => $check_out,
        ':check_in2'  => $check_in,
        ':check_out2' => $check_out,
    ];

    if (!empty($capacity) && $capacity !== 'all') {
        $sql .= " AND r.capacity = :capacity";
        $params[':capacity'] = $capacity;
    }
    if (!empty($zone)) {
        $sql .= " AND LOWER(SPLIT_PART(h.address, ', ', 2)) LIKE :zone";
        $params[':zone'] = '%' . strtolower($zone) . '%';
    }
    if (!empty($chain_id) && $chain_id !== 'all') {
        $sql .= " AND hc.chain_id = :chain_id";
        $params[':chain_id'] = (int)$chain_id;
    }
    if (!empty($category) && $category !== 'all' && $category !== 'any') {
        $sql .= " AND h.category = :category";
        $params[':category'] = (int)$category;
    }
    if (!empty($max_price) && is_numeric($max_price)) {
        $sql .= " AND r.price <= :max_price";
        $params[':max_price'] = (float)$max_price;
    }
    if ($extendable === '1' || $extendable === 'true') {
        $sql .= " AND r.extendable = TRUE";
    }

    $sql .= " ORDER BY r.price ASC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rooms = $stmt->fetchAll();

    echo json_encode(['success' => true, 'data' => $rooms]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
