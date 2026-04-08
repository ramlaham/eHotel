-- =========================================================
-- e-Hotels Project - indexes.sql
-- CSI2532 Deliverable 2
-- PostgreSQL
-- =========================================================

-- Optional cleanup for reruns
DROP INDEX IF EXISTS idx_hotel_area;
DROP INDEX IF EXISTS idx_hotel_chain_category;
DROP INDEX IF EXISTS idx_room_search_filters;
DROP INDEX IF EXISTS idx_reservation_room_dates;
DROP INDEX IF EXISTS idx_rental_room_dates;

-- =========================================================
-- 1) Helps find hotels by area/zone
-- Useful for:
-- - available rooms by zone
-- - room search filtered by area
-- =========================================================
CREATE INDEX idx_hotel_area
ON hotel(area);

-- =========================================================
-- 2) Helps filter hotels by chain and category
-- Useful for:
-- - room search by hotel chain
-- - room search by hotel category
-- =========================================================
CREATE INDEX idx_hotel_chain_category
ON hotel(chain_id, category);

-- =========================================================
-- 3) Helps search rooms within a hotel by capacity and price
-- Useful for:
-- - room search with capacity / price / surface filters
-- - joins from hotel -> room
-- =========================================================
CREATE INDEX idx_room_search_filters
ON room(hotel_id, capacity, price, surface_area);

-- =========================================================
-- 4) Helps availability checks against reservations
-- Useful for:
-- - checking if a room is reserved
-- - overlap checks in reservation-related queries
-- =========================================================
CREATE INDEX idx_reservation_room_dates
ON reservation(hotel_id, room_number, check_in_date, check_out_date, status);

-- =========================================================
-- 5) Helps availability checks against rentals
-- Useful for:
-- - checking if a room is currently rented
-- - overlap checks in rental-related queries
-- =========================================================
CREATE INDEX idx_rental_room_dates
ON rental(hotel_id, room_number, rental_start_date, rental_end_date, status);