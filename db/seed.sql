-- =========================================================
-- e-Hotels Project - seed.sql
-- CSI2532 Deliverable 2
-- PostgreSQL
-- =========================================================

/*
Optional reset before reseeding
TRUNCATE TABLE
    archive_rental,
    archive_reservation,
    rental,
    reservation,
    room_amenity,
    room,
    hotel_manager,
    employee,
    client,
    hotel_phone,
    hotel_email,
    hotel,
    hotel_chain_phone,
    hotel_chain_email,
    hotel_chain
RESTART IDENTITY CASCADE;
*/

-- =========================================================
-- 1) HOTEL CHAINS
-- =========================================================
INSERT INTO hotel_chain (chain_id, chain_name, central_office_address, number_of_hotels)
VALUES
(1, 'Northern Stay',   '100 Sparks St, Ottawa, ON',   8),
(2, 'Maple Luxe',      '200 Elgin St, Ottawa, ON',    8),
(3, 'Aurora Suites',   '300 Bank St, Ottawa, ON',     8),
(4, 'Cedar Grand',     '400 Rideau St, Ottawa, ON',   8),
(5, 'BlueWave Hotels', '500 Carling Ave, Ottawa, ON', 8);

INSERT INTO hotel_chain_email (chain_id, email_address)
VALUES
(1, 'contact@northernstay.ca'),
(2, 'contact@mapleluxe.ca'),
(3, 'contact@aurorasuites.ca'),
(4, 'contact@cedargrand.ca'),
(5, 'contact@bluewavehotels.ca');

INSERT INTO hotel_chain_phone (chain_id, phone_number)
VALUES
(1, '613-555-1001'),
(2, '613-555-1002'),
(3, '613-555-1003'),
(4, '613-555-1004'),
(5, '613-555-1005');

-- =========================================================
-- 2) HOTELS
-- 40 hotels total = 8 per chain
-- =========================================================
INSERT INTO hotel (hotel_id, chain_id, hotel_name, category, address, area, room_count)
VALUES
(1,  1, 'Parliament Grand Ottawa',      3, '101 Wellington St, Ottawa, ON',         'Nepean',    5),
(2,  1, 'Rideau View Suites',           4, '55 Rideau St, Ottawa, ON',               'Kanata',    5),
(3,  1, 'ByWard Market Inn',            5, '78 York St, Ottawa, ON',                 'Barrhaven', 5),
(4,  1, 'Canal Crest Hotel',            2, '120 Preston St, Ottawa, ON',             'Orleans',   5),
(5,  1, 'Lansdowne Stay',               1, '35 Bank St, Ottawa, ON',                 'Vanier',    5),
(6,  1, 'Glebe Garden Hotel',           3, '88 Holmwood Ave, Ottawa, ON',            'Nepean',    5),
(7,  1, 'Capital Crown Suites',         4, '150 Elgin St, Ottawa, ON',               'Kanata',    5),
(8,  1, 'Elgin Plaza Hotel',            5, '210 Elgin St, Ottawa, ON',               'Barrhaven', 5),

(9,  2, 'Maple Leaf Executive Hotel',   2, '400 Terry Fox Dr, Ottawa, ON',           'Orleans',   5),
(10, 2, 'Ottawa River Retreat',         1, '500 St Joseph Blvd, Ottawa, ON',         'Vanier',    5),
(11, 2, 'Confederation Square Lodge',   3, '250 Baseline Rd, Ottawa, ON',            'Nepean',    5),
(12, 2, 'Somerset Sky Hotel',           4, '300 Somerset St W, Ottawa, ON',          'Kanata',    5),
(13, 2, 'Beacon Hill Suites',           5, '650 Montreal Rd, Ottawa, ON',            'Barrhaven', 5),
(14, 2, 'Westboro Urban Stay',          2, '320 Richmond Rd, Ottawa, ON',            'Orleans',   5),
(15, 2, 'Rockcliffe Manor Hotel',       1, '45 Springfield Rd, Ottawa, ON',          'Vanier',    5),
(16, 2, 'Carleton Heights Inn',         3, '180 Heron Rd, Ottawa, ON',               'Nepean',    5),

(17, 3, 'Aurora Parliament Suites',     4, '90 Sparks St, Ottawa, ON',               'Kanata',    5),
(18, 3, 'Downtown Crescent Hotel',      5, '140 Laurier Ave W, Ottawa, ON',          'Barrhaven', 5),
(19, 3, 'Rideau Royale Inn',            2, '60 George St, Ottawa, ON',               'Orleans',   5),
(20, 3, 'Canal Bridge Hotel',           1, '75 Queen Elizabeth Dr, Ottawa, ON',      'Vanier',    5),
(21, 3, 'The Ottawa Regent',            3, '222 Slater St, Ottawa, ON',              'Nepean',    5),
(22, 3, 'Market Street Suites',         4, '110 Clarence St, Ottawa, ON',            'Kanata',    5),
(23, 3, 'Merivale Comfort Hotel',       5, '188 Merivale Rd, Ottawa, ON',            'Barrhaven', 5),
(24, 3, 'Preston House Hotel',          2, '130 Preston St, Ottawa, ON',             'Orleans',   5),

(25, 4, 'Cedar Crown Ottawa',           1, '500 River Rd, Ottawa, ON',               'Vanier',    5),
(26, 4, 'Embassy Row Hotel',            3, '1 Sussex Dr, Ottawa, ON',                'Nepean',    5),
(27, 4, 'Blue Heron Lodge',             4, '700 Innes Rd, Ottawa, ON',               'Kanata',    5),
(28, 4, 'Golden Maple Inn',             5, '350 March Rd, Ottawa, ON',               'Barrhaven', 5),
(29, 4, 'Wellington Court Hotel',       2, '420 Wellington St W, Ottawa, ON',        'Orleans',   5),
(30, 4, 'Centretown Signature Suites',  1, '170 Metcalfe St, Ottawa, ON',            'Vanier',    5),
(31, 4, 'Riverside Grand Hotel',        3, '60 Riverside Dr, Ottawa, ON',            'Nepean',    5),
(32, 4, 'Airport Beacon Hotel',         4, '1000 Airport Pkwy Private, Ottawa, ON',  'Kanata',    5),

(33, 5, 'BlueWave Capital Hotel',       5, '99 Albert St, Ottawa, ON',               'Barrhaven', 5),
(34, 5, 'Ottawa Horizon Suites',        2, '250 O''Connor St, Ottawa, ON',           'Orleans',   5),
(35, 5, 'Victoria Park Inn',            1, '40 Sunnyside Ave, Ottawa, ON',           'Vanier',    5),
(36, 5, 'King Edward Hotel',            3, '24 Crichton St, Ottawa, ON',             'Nepean',    5),
(37, 5, 'Chateau Laurier View',         4, '1 Rideau St, Ottawa, ON',                'Kanata',    5),
(38, 5, 'Capital Harbour Suites',       5, '85 Nicholas St, Ottawa, ON',             'Barrhaven', 5),
(39, 5, 'Stonebridge Hotel Ottawa',     2, '900 Greenbank Rd, Ottawa, ON',           'Orleans',   5),
(40, 5, 'Northern Lights Plaza',        1, '525 Legget Dr, Ottawa, ON',              'Vanier',    5);

INSERT INTO hotel_email (hotel_id, email_address)
SELECT hotel_id, 'hotel' || hotel_id || '@ehotels.ca'
FROM hotel;

INSERT INTO hotel_phone (hotel_id, phone_number)
SELECT hotel_id, '613-600-' || LPAD(hotel_id::text, 4, '0')
FROM hotel;

-- =========================================================
-- 3) CLIENTS
-- =========================================================
INSERT INTO client (client_id, first_name, last_name, address, ssn, registration_date)
VALUES
(1,  'John',    'Doe',       '145 Bank St, Ottawa, ON',       '381-524-907', DATE '2026-01-10'),
(2,  'Jane',    'Smith',     '212 Elgin St, Ottawa, ON',      '614-832-751', DATE '2026-01-11'),
(3,  'Michael', 'Brown',     '98 Rideau St, Ottawa, ON',      '927-146-380', DATE '2026-01-12'),
(4,  'Sarah',   'Johnson',   '77 Bronson Ave, Ottawa, ON',    '205-764-918', DATE '2026-01-13'),
(5,  'David',   'Wilson',    '310 Carling Ave, Ottawa, ON',   '748-391-526', DATE '2026-01-14'),
(6,  'Emily',   'Taylor',    '55 Montreal Rd, Ottawa, ON',    '563-287-401', DATE '2026-01-15'),
(7,  'Daniel',  'Anderson',  '420 Merivale Rd, Ottawa, ON',   '894-613-275', DATE '2026-01-16'),
(8,  'Olivia',  'Thomas',    '18 Clarence St, Ottawa, ON',    '132-975-804', DATE '2026-01-17'),
(9,  'James',   'Martinez',  '265 Somerset St W, Ottawa, ON', '476-058-139', DATE '2026-01-18'),
(10, 'Sophia',  'Jackson',   '90 Preston St, Ottawa, ON',     '659-421-708', DATE '2026-01-19'),
(11, 'Noah',    'White',     '134 Richmond Rd, Ottawa, ON',   '283-749-561', DATE '2026-01-20'),
(12, 'Ava',     'Harris',    '201 Metcalfe St, Ottawa, ON',   '715-304-628', DATE '2026-01-21');

-- =========================================================
-- 4) EMPLOYEES
-- =========================================================
INSERT INTO employee (employee_id, hotel_id, first_name, last_name, address, ssn, role)
SELECT
    ((h.hotel_id - 1) * 3) + e.n AS employee_id,
    h.hotel_id,
    CASE e.n
        WHEN 1 THEN 'Manager'
        WHEN 2 THEN 'Reception'
        ELSE 'Support'
    END || h.hotel_id AS first_name,
    CASE e.n
        WHEN 1 THEN 'Lead'
        WHEN 2 THEN 'Desk'
        ELSE 'Staff'
    END AS last_name,
    h.hotel_id || ' Gladstone Ave, Ottawa, ON' AS address,
    LPAD((floor(random() * 900)::int + 100)::text, 3, '0') || '-' ||
    LPAD((floor(random() * 900)::int + 100)::text, 3, '0') || '-' ||
    LPAD((floor(random() * 900)::int + 100)::text, 3, '0') AS ssn,
    CASE e.n
        WHEN 1 THEN 'Manager'
        WHEN 2 THEN 'Receptionist'
        ELSE 'Clerk'
    END AS role
FROM hotel h
CROSS JOIN (VALUES (1), (2), (3)) AS e(n);

-- =========================================================
-- 5) HOTEL MANAGERS
-- =========================================================
INSERT INTO hotel_manager (hotel_id, manager_employee_id)
SELECT hotel_id, ((hotel_id - 1) * 3) + 1
FROM hotel;

-- =========================================================
-- 6) ROOMS
-- =========================================================
INSERT INTO room (
    hotel_id,
    room_number,
    price,
    capacity,
    surface_area,
    view_type,
    extra_bed_possible,
    condition_state
)
SELECT
    h.hotel_id,
    (100 + r.n)::text AS room_number,
    CASE r.n
        WHEN 1 THEN 109.99
        WHEN 2 THEN 129.99
        WHEN 3 THEN 159.99
        WHEN 4 THEN 219.99
        ELSE 189.99
    END + (h.category * 10) AS price,
    CASE r.n
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        WHEN 3 THEN 2
        WHEN 4 THEN 4
        ELSE 3
    END AS capacity,
    CASE r.n
        WHEN 1 THEN 20.0
        WHEN 2 THEN 28.5
        WHEN 3 THEN 32.0
        WHEN 4 THEN 45.0
        ELSE 38.0
    END AS surface_area,
    CASE (r.n % 4)
        WHEN 1 THEN 'City'
        WHEN 2 THEN 'Mountain'
        WHEN 3 THEN 'Sea'
        ELSE 'Garden'
    END AS view_type,
    CASE WHEN r.n IN (2, 4, 5) THEN TRUE ELSE FALSE END AS extra_bed_possible,
    'No damages' AS condition_state
FROM hotel h
CROSS JOIN (VALUES (1), (2), (3), (4), (5)) AS r(n);

-- =========================================================
-- 7) ROOM AMENITIES
-- =========================================================
INSERT INTO room_amenity (hotel_id, room_number, amenity)
SELECT hotel_id, room_number, 'WiFi' FROM room;

INSERT INTO room_amenity (hotel_id, room_number, amenity)
SELECT hotel_id, room_number, 'TV' FROM room;

INSERT INTO room_amenity (hotel_id, room_number, amenity)
SELECT hotel_id, room_number, 'Air Conditioning'
FROM room
WHERE capacity >= 2;

INSERT INTO room_amenity (hotel_id, room_number, amenity)
SELECT hotel_id, room_number, 'Mini Fridge'
FROM room
WHERE room_number IN ('104', '105');

INSERT INTO room_amenity (hotel_id, room_number, amenity)
SELECT hotel_id, room_number, 'Ocean Balcony'
FROM room
WHERE view_type = 'Sea';

-- =========================================================
-- 8) RESERVATIONS
-- =========================================================
INSERT INTO reservation (
    reservation_id,
    client_id,
    hotel_id,
    room_number,
    reservation_date,
    check_in_date,
    check_out_date,
    status
)
VALUES
(1,  1,  1,  '101', DATE '2026-04-01', DATE '2026-06-10', DATE '2026-06-12', 'confirmed'),
(2,  2,  1,  '102', DATE '2026-04-02', DATE '2026-06-15', DATE '2026-06-17', 'pending'),
(3,  3,  5,  '103', DATE '2026-04-03', DATE '2026-07-01', DATE '2026-07-05', 'completed'),
(4,  4, 10,  '104', DATE '2026-04-04', DATE '2026-07-08', DATE '2026-07-10', 'cancelled'),
(5,  5, 15,  '105', DATE '2026-04-05', DATE '2026-08-01', DATE '2026-08-04', 'confirmed'),
(6,  6, 20,  '101', DATE '2026-04-06', DATE '2026-08-10', DATE '2026-08-13', 'pending'),
(7,  7, 25,  '102', DATE '2026-04-07', DATE '2026-08-15', DATE '2026-08-18', 'completed'),
(8,  8, 30,  '103', DATE '2026-04-08', DATE '2026-09-01', DATE '2026-09-03', 'confirmed');

-- =========================================================
-- 9) RENTALS
-- =========================================================
INSERT INTO rental (
    rental_id,
    client_id,
    hotel_id,
    room_number,
    reservation_id,
    processed_by_employee_id,
    rental_start_date,
    rental_end_date,
    status
)
VALUES
(1,  1,  1,  '101', 1,    2, DATE '2026-06-10', DATE '2026-06-12', 'active'),
(2,  5,  2,  '102', NULL, 5, DATE '2026-06-20', DATE '2026-06-25', 'active'),
(3,  6,  3,  '103', NULL, 8, DATE '2026-05-01', DATE '2026-05-03', 'completed'),
(4,  7,  4,  '104', NULL, 11, DATE '2026-05-10', DATE '2026-05-15', 'cancelled'),
(5,  9,  6,  '105', NULL, 17, DATE '2026-07-20', DATE '2026-07-24', 'active'),
(6, 10,  8,  '101', NULL, 23, DATE '2026-07-01', DATE '2026-07-05', 'completed');