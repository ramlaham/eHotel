-- e-Hotels Project indexes

-- Drop old indexes first so the file can be run again
DROP INDEX IF EXISTS idx_hotel_area;
DROP INDEX IF EXISTS idx_hotel_chain_category;
DROP INDEX IF EXISTS idx_room_search_filters;
DROP INDEX IF EXISTS idx_reservation_room_dates;
DROP INDEX IF EXISTS idx_rental_room_dates;

-- Index for searching hotels by area
CREATE INDEX idx_hotel_area
ON hotel(area);

-- Index for filtering hotels by chain and category
CREATE INDEX idx_hotel_chain_category
ON hotel(chain_id, category);

-- Index for room searches by hotel, capacity, price, and surface area
CREATE INDEX idx_room_search_filters
ON room(hotel_id, capacity, price, surface_area);

-- Index for checking room availability against reservations
CREATE INDEX idx_reservation_room_dates
ON reservation(hotel_id, room_number, check_in_date, check_out_date, status);

-- Index for checking room availability against rentals
CREATE INDEX idx_rental_room_dates
ON rental(hotel_id, room_number, rental_start_date, rental_end_date, status);