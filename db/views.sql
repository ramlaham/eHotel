-- =========================================================
-- e-Hotels Project - views.sql
-- CSI2532 Deliverable 2
-- PostgreSQL
-- =========================================================

-- Optional cleanup for reruns
DROP VIEW IF EXISTS available_rooms_per_area CASCADE;
DROP VIEW IF EXISTS hotel_room_capacity CASCADE;

-- =========================================================
-- 1) Number of available rooms by area
--
-- A room is considered available if:
-- - it is not in a reservation with status 'pending' or 'confirmed'
-- - it is not in a rental with status 'active'
--
-- This view shows, for each hotel area/zone, how many rooms are
-- currently available.
-- =========================================================
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

-- =========================================================
-- 2) Total room capacity per hotel
--
-- Sums the capacity of all rooms belonging to each hotel.
-- =========================================================
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