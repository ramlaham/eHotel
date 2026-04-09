-- e-Hotels Project queries

-- Query 1
-- Searches for available rooms using multiple filters
SELECT
    h.hotel_id,
    h.hotel_name,
    hc.chain_name,
    h.category,
    h.area,
    r.room_number,
    r.price,
    r.capacity,
    r.surface_area,
    r.view_type,
    r.extra_bed_possible
FROM hotel h
JOIN hotel_chain hc
    ON h.chain_id = hc.chain_id
JOIN room r
    ON h.hotel_id = r.hotel_id
WHERE h.area = 'Centretown'
  AND hc.chain_name = 'Northern Stay'
  AND h.category >= 3
  AND r.capacity >= 2
  AND r.surface_area >= 25
  AND r.price <= 220
  AND NOT EXISTS (
      SELECT 1
      FROM reservation res
      WHERE res.hotel_id = r.hotel_id
        AND res.room_number = r.room_number
        AND res.status IN ('pending', 'confirmed')
        AND DATE '2026-07-01' < res.check_out_date
        AND DATE '2026-07-05' > res.check_in_date
  )
  AND NOT EXISTS (
      SELECT 1
      FROM rental rt
      WHERE rt.hotel_id = r.hotel_id
        AND rt.room_number = r.room_number
        AND rt.status = 'active'
        AND DATE '2026-07-01' < rt.rental_end_date
        AND DATE '2026-07-05' > rt.rental_start_date
  )
ORDER BY h.hotel_name, r.price;

-- Query 2
-- Shows all reservations with the client and hotel details
SELECT
    res.reservation_id,
    c.first_name || ' ' || c.last_name AS client_name,
    h.hotel_name,
    h.area,
    res.room_number,
    res.check_in_date,
    res.check_out_date,
    res.status
FROM reservation res
JOIN client c
    ON res.client_id = c.client_id
JOIN hotel h
    ON res.hotel_id = h.hotel_id
ORDER BY res.check_in_date, res.reservation_id;

-- Query 3
-- Shows all rentals with client and employee info
SELECT
    rt.rental_id,
    c.first_name || ' ' || c.last_name AS client_name,
    h.hotel_name,
    rt.room_number,
    rt.rental_start_date,
    rt.rental_end_date,
    rt.status,
    e.first_name || ' ' || e.last_name AS processed_by
FROM rental rt
JOIN client c
    ON rt.client_id = c.client_id
JOIN hotel h
    ON rt.hotel_id = h.hotel_id
LEFT JOIN employee e
    ON rt.processed_by_employee_id = e.employee_id
ORDER BY rt.rental_start_date, rt.rental_id;

-- Query 4
-- Counts how many rooms are currently available in each hotel
SELECT
    h.hotel_id,
    h.hotel_name,
    h.area,
    COUNT(r.room_number) AS available_rooms
FROM hotel h
JOIN room r
    ON h.hotel_id = r.hotel_id
WHERE NOT EXISTS (
    SELECT 1
    FROM reservation res
    WHERE res.hotel_id = r.hotel_id
      AND res.room_number = r.room_number
      AND res.status IN ('pending', 'confirmed')
)
AND NOT EXISTS (
    SELECT 1
    FROM rental rt
    WHERE rt.hotel_id = r.hotel_id
      AND rt.room_number = r.room_number
      AND rt.status = 'active'
)
GROUP BY h.hotel_id, h.hotel_name, h.area
ORDER BY available_rooms DESC, h.hotel_name;