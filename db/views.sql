-- e-Hotels Project views
-- Drop old views in case this file is run again
DROP VIEW IF EXISTS available_rooms_per_area CASCADE;
DROP VIEW IF EXISTS hotel_room_capacity CASCADE;

-- Counts how many rooms are currently available in each area
-- A room is available if it is not in a pending/confirmed reservation
-- and not in an active rental
CREATE VIEW available_rooms_per_area AS
SELECT
    h.area,
    COUNT(*) AS available_room_count
FROM hotel h
JOIN room rm
    ON h.hotel_id = rm.hotel_id
WHERE NOT EXISTS (
    SELECT 1
    FROM reservation r
    WHERE r.hotel_id = rm.hotel_id
      AND r.room_number = rm.room_number
      AND r.status IN ('pending', 'confirmed')
)
AND NOT EXISTS (
    SELECT 1
    FROM rental rt
    WHERE rt.hotel_id = rm.hotel_id
      AND rt.room_number = rm.room_number
      AND rt.status = 'active'
)
GROUP BY h.area;

-- Adds up the total room capacity for each hotel
CREATE VIEW hotel_room_capacity AS
SELECT
    h.hotel_id,
    h.hotel_name,
    h.area,
    SUM(rm.capacity) AS total_room_capacity
FROM hotel h
JOIN room rm
    ON h.hotel_id = rm.hotel_id
GROUP BY h.hotel_id, h.hotel_name, h.area;
