-- =============================================================================
-- eHotel Database Schema
-- PostgreSQL
-- =============================================================================

-- =============================================================================
-- DDL: Table Definitions
-- =============================================================================

CREATE TABLE hotel_chain (
    chain_id   SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    headquarters_address TEXT,
    num_hotels INT DEFAULT 0,
    contact_emails TEXT[],
    contact_phones TEXT[]
);

CREATE TABLE hotel (
    hotel_id   SERIAL PRIMARY KEY,
    chain_id   INT REFERENCES hotel_chain(chain_id),
    category   INT CHECK (category BETWEEN 1 AND 5),
    address    TEXT,
    num_rooms  INT DEFAULT 0,
    email      VARCHAR(100),
    phone      VARCHAR(20)
);

CREATE TABLE room (
    room_id    SERIAL PRIMARY KEY,
    hotel_id   INT REFERENCES hotel(hotel_id),
    price      NUMERIC CHECK (price > 0),
    amenities  TEXT,
    capacity   VARCHAR(20) CHECK (capacity IN ('single','double','triple','quad','suite')),
    view       VARCHAR(20) CHECK (view IN ('sea','mountain','city','garden','none')),
    extendable BOOLEAN DEFAULT FALSE,
    damages    TEXT
);

CREATE TABLE client (
    client_id         SERIAL PRIMARY KEY,
    full_name         VARCHAR(100) NOT NULL,
    address           TEXT,
    ssn               VARCHAR(20) UNIQUE NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    hotel_id    INT REFERENCES hotel(hotel_id),
    full_name   VARCHAR(100) NOT NULL,
    address     TEXT,
    ssn         VARCHAR(20) UNIQUE NOT NULL,
    role        VARCHAR(50)
);

CREATE TABLE reservation (
    reservation_id SERIAL PRIMARY KEY,
    client_id      INT REFERENCES client(client_id),
    room_id        INT REFERENCES room(room_id),
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    status         VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','cancelled','converted')),
    CONSTRAINT check_reservation_dates CHECK (end_date > start_date)
);

CREATE TABLE rental (
    rental_id      SERIAL PRIMARY KEY,
    reservation_id INT REFERENCES reservation(reservation_id) NULL,
    client_id      INT REFERENCES client(client_id),
    room_id        INT REFERENCES room(room_id),
    employee_id    INT REFERENCES employee(employee_id),
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    CONSTRAINT check_rental_dates CHECK (end_date > start_date)
);

-- =============================================================================
-- Triggers (created BEFORE room inserts so num_rooms auto-increments)
-- =============================================================================

CREATE OR REPLACE FUNCTION update_hotel_num_rooms()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE hotel SET num_rooms = num_rooms + 1 WHERE hotel_id = NEW.hotel_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE hotel SET num_rooms = num_rooms - 1 WHERE hotel_id = OLD.hotel_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_hotel_num_rooms ON room;
CREATE TRIGGER trg_update_hotel_num_rooms
AFTER INSERT OR DELETE ON room
FOR EACH ROW EXECUTE FUNCTION update_hotel_num_rooms();

CREATE OR REPLACE FUNCTION update_reservation_on_rental()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_id IS NOT NULL THEN
        UPDATE reservation SET status = 'converted' WHERE reservation_id = NEW.reservation_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_reservation_status ON rental;
CREATE TRIGGER trg_update_reservation_status
AFTER INSERT ON rental
FOR EACH ROW EXECUTE FUNCTION update_reservation_on_rental();

-- =============================================================================
-- DML: Sample Data
-- =============================================================================

-- Hotel Chains
INSERT INTO hotel_chain (name, headquarters_address, num_hotels, contact_emails, contact_phones) VALUES
('Marriott International', '7750 Wisconsin Ave, Bethesda, MD', 0, ARRAY['info@marriott.com','support@marriott.com'], ARRAY['+1-301-380-3000','+1-800-627-7468']),
('Hilton Hotels',          '7930 Jones Branch Dr, McLean, VA', 0, ARRAY['info@hilton.com','support@hilton.com'],   ARRAY['+1-703-883-1000','+1-800-445-8667']),
('Hyatt Corporation',      '150 N Riverside Plaza, Chicago, IL', 0, ARRAY['info@hyatt.com','support@hyatt.com'],  ARRAY['+1-312-750-1234','+1-800-233-1234']),
('IHG Hotels',             '3 Ravinia Dr, Atlanta, GA', 0, ARRAY['info@ihg.com','support@ihg.com'],               ARRAY['+1-770-604-2000','+1-800-465-4329']),
('Best Western',           '6201 N 24th Pkwy, Phoenix, AZ', 0, ARRAY['info@bestwestern.com','help@bestwestern.com'], ARRAY['+1-602-957-4200','+1-800-780-7234']);

-- Hotels (8 per chain = 40 hotels)
-- Chain 1: Marriott
INSERT INTO hotel (chain_id, category, address, num_rooms, email, phone) VALUES
(1, 5, '1535 Broadway, New York',       0, 'nyc.times@marriott.com',    '+1-212-398-1900'),
(1, 4, '540 Park Ave, New York',        0, 'nyc.park@marriott.com',     '+1-212-421-0900'),
(1, 5, '333 S Grand Ave, Los Angeles',  0, 'la.downtown@marriott.com',  '+1-213-617-3300'),
(1, 4, '700 W Convention Way, Chicago', 0, 'chi.west@marriott.com',     '+1-312-786-1929'),
(1, 3, '1201 Collins Ave, Miami',       0, 'mia.beach@marriott.com',    '+1-305-604-1000'),
(1, 5, '1001 NW Couch St, Portland',    0, 'por.pearl@marriott.com',    '+1-503-226-7600'),
(1, 4, '255 E Flamingo Rd, Las Vegas',  0, 'lv.resort@marriott.com',    '+1-702-650-0000'),
(1, 3, '2101 Bush St, San Francisco',   0, 'sf.union@marriott.com',     '+1-415-345-5500');

-- Chain 2: Hilton
INSERT INTO hotel (chain_id, category, address, num_rooms, email, phone) VALUES
(2, 5, '1335 Avenue of the Americas, New York', 0, 'nyc.midtown@hilton.com',  '+1-212-586-7000'),
(2, 4, '720 S Michigan Ave, Chicago',           0, 'chi.michigan@hilton.com', '+1-312-922-4400'),
(2, 5, '9876 Wilshire Blvd, Los Angeles',       0, 'la.bevhills@hilton.com',  '+1-310-274-7777'),
(2, 4, '1750 Rockville Pike, Boston',           0, 'bos.rockville@hilton.com','+1-617-742-7630'),
(2, 3, '1340 Boylston St, Boston',              0, 'bos.back@hilton.com',     '+1-617-236-1100'),
(2, 5, '6000 Parc Corniche Dr, Orlando',        0, 'orl.parc@hilton.com',     '+1-407-239-7100'),
(2, 4, '800 Elysian Fields Ave, Atlanta',       0, 'atl.garden@hilton.com',   '+1-404-659-2000'),
(2, 3, '17 E Kiowa St, Denver',                 0, 'den.city@hilton.com',     '+1-303-607-9090');

-- Chain 3: Hyatt
INSERT INTO hotel (chain_id, category, address, num_rooms, email, phone) VALUES
(3, 5, '151 E Wacker Dr, Chicago',          0, 'chi.riverwalk@hyatt.com',  '+1-312-565-1234'),
(3, 4, '1 Aloha Tower Dr, Honolulu',        0, 'hnl.aloha@hyatt.com',      '+1-808-947-1234'),
(3, 5, '350 Mission St, San Francisco',     0, 'sf.embarcadero@hyatt.com', '+1-415-788-1234'),
(3, 4, '1000 H St NW, Washington',          0, 'dc.mcpherson@hyatt.com',   '+1-202-582-1234'),
(3, 3, '300 Reunion Blvd, Dallas',          0, 'dal.reunion@hyatt.com',    '+1-214-651-1234'),
(3, 5, '900 Bellevue Way NE, Seattle',      0, 'sea.bellevue@hyatt.com',   '+1-425-462-1234'),
(3, 4, '5400 E Lincoln Dr, Phoenix',        0, 'phx.resort@hyatt.com',     '+1-480-991-1234'),
(3, 3, '2101 Allen Pkwy, Houston',          0, 'hou.allen@hyatt.com',      '+1-713-861-1234');

-- Chain 4: IHG
INSERT INTO hotel (chain_id, category, address, num_rooms, email, phone) VALUES
(4, 4, '140 E 46th St, New York',           0, 'nyc.tudor@ihg.com',       '+1-212-755-8841'),
(4, 3, '300 N State St, Chicago',           0, 'chi.river@ihg.com',       '+1-312-836-5000'),
(4, 5, '555 South Grand Ave, Los Angeles',  0, 'la.figueroa@ihg.com',     '+1-213-617-8899'),
(4, 4, '8701 Collins Ave, Miami',           0, 'mia.surfside@ihg.com',    '+1-305-865-4500'),
(4, 3, '400 Soldiers Field Rd, Boston',     0, 'bos.soldiers@ihg.com',    '+1-617-783-0090'),
(4, 4, '3300 Las Vegas Blvd S, Las Vegas',  0, 'lv.strip@ihg.com',        '+1-702-791-2600'),
(4, 5, '1 Industrial Dr, Houston',          0, 'hou.galleria@ihg.com',    '+1-713-621-3300'),
(4, 3, '13225 E Iliff Ave, Denver',         0, 'den.aurora@ihg.com',      '+1-303-337-3000');

-- Chain 5: Best Western
INSERT INTO hotel (chain_id, category, address, num_rooms, email, phone) VALUES
(5, 3, '26 W 29th St, New York',            0, 'nyc.herald@bestwestern.com',  '+1-212-686-1600'),
(5, 2, '162 E Ontario St, Chicago',         0, 'chi.ontario@bestwestern.com', '+1-312-787-3100'),
(5, 4, '1711 N Highland Ave, Los Angeles',  0, 'la.highland@bestwestern.com', '+1-323-467-8800'),
(5, 2, '234 Causeway St, Boston',           0, 'bos.td@bestwestern.com',      '+1-617-742-7100'),
(5, 3, '1601 Biscayne Blvd, Miami',         0, 'mia.biscayne@bestwestern.com','+1-305-374-5100'),
(5, 4, '3227 Las Vegas Blvd S, Las Vegas',  0, 'lv.premier@bestwestern.com',  '+1-702-732-5000'),
(5, 2, '1400 Lamar St, Houston',            0, 'hou.lamar@bestwestern.com',   '+1-713-652-9400'),
(5, 3, '4411 E Colfax Ave, Denver',         0, 'den.colfax@bestwestern.com',  '+1-303-388-5561');

-- Rooms for Chain 1 (Marriott) hotels 1-8
-- Hotel 1 (Marriott NYC Times Square, hotel_id=1)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(1, 350.00, 'WiFi, TV, Minibar, Safe',         'double', 'city',     true,  NULL),
(1, 500.00, 'WiFi, TV, Jacuzzi, Minibar, Safe','suite',  'city',     true,  NULL),
(1, 220.00, 'WiFi, TV, Safe',                  'single', 'none',     false, NULL),
(1, 280.00, 'WiFi, TV, Coffee Maker',           'double', 'city',     false, 'Minor scratch on desk'),
(1, 420.00, 'WiFi, TV, Minibar, Gym Access',   'triple', 'city',     true,  NULL),
(1, 600.00, 'WiFi, TV, Jacuzzi, Balcony',      'suite',  'city',     true,  NULL);

-- Hotel 2 (Marriott NYC Park Ave, hotel_id=2)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(2, 310.00, 'WiFi, TV, Coffee Maker',           'single', 'city',    false, NULL),
(2, 400.00, 'WiFi, TV, Minibar',                'double', 'garden',  true,  NULL),
(2, 460.00, 'WiFi, TV, Minibar, Lounge Access', 'triple', 'city',    true,  NULL),
(2, 550.00, 'WiFi, TV, Jacuzzi, Minibar',       'suite',  'city',    true,  NULL),
(2, 250.00, 'WiFi, TV',                         'single', 'none',    false, 'Stained carpet'),
(2, 370.00, 'WiFi, TV, Coffee Maker, Safe',     'double', 'city',    false, NULL);

-- Hotel 3 (Marriott LA, hotel_id=3)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(3, 280.00, 'WiFi, TV, Pool Access',            'single', 'city',    false, NULL),
(3, 360.00, 'WiFi, TV, Pool Access, Minibar',   'double', 'mountain',true,  NULL),
(3, 440.00, 'WiFi, TV, Spa Access, Minibar',    'triple', 'mountain',true,  NULL),
(3, 530.00, 'WiFi, TV, Jacuzzi, Private Pool',  'suite',  'mountain',true,  NULL),
(3, 200.00, 'WiFi, TV',                         'single', 'none',    false, NULL),
(3, 340.00, 'WiFi, TV, Gym Access',             'quad',   'city',    true,  NULL);

-- Hotel 4 (Marriott Chicago, hotel_id=4)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(4, 260.00, 'WiFi, TV, Coffee Maker',           'single', 'city',    false, NULL),
(4, 340.00, 'WiFi, TV, Minibar',                'double', 'city',    true,  NULL),
(4, 410.00, 'WiFi, TV, Minibar, Safe',          'triple', 'city',    true,  NULL),
(4, 500.00, 'WiFi, TV, Jacuzzi, Minibar',       'suite',  'city',    true,  NULL),
(4, 230.00, 'WiFi, TV',                         'single', 'none',    false, 'Broken lamp'),
(4, 290.00, 'WiFi, TV, Coffee Maker',           'double', 'none',    false, NULL);

-- Hotel 5 (Marriott Miami, hotel_id=5)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(5, 320.00, 'WiFi, TV, Beach Access',           'single', 'sea',     false, NULL),
(5, 420.00, 'WiFi, TV, Beach Access, Minibar',  'double', 'sea',     true,  NULL),
(5, 500.00, 'WiFi, TV, Balcony, Jacuzzi',       'suite',  'sea',     true,  NULL),
(5, 270.00, 'WiFi, TV, Pool Access',            'double', 'garden',  false, NULL),
(5, 240.00, 'WiFi, TV',                         'single', 'none',    false, NULL),
(5, 380.00, 'WiFi, TV, Minibar, Safe',          'triple', 'sea',     true,  NULL);

-- Hotel 6 (Marriott Portland, hotel_id=6)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(6, 210.00, 'WiFi, TV, Coffee Maker',           'single', 'city',    false, NULL),
(6, 290.00, 'WiFi, TV, Minibar',                'double', 'city',    true,  NULL),
(6, 350.00, 'WiFi, TV, Minibar, Gym Access',    'triple', 'mountain',true,  NULL),
(6, 450.00, 'WiFi, TV, Jacuzzi',                'suite',  'mountain',true,  NULL),
(6, 180.00, 'WiFi, TV',                         'single', 'none',    false, NULL),
(6, 310.00, 'WiFi, TV, Coffee Maker, Safe',     'double', 'mountain',false, NULL);

-- Hotel 7 (Marriott Las Vegas, hotel_id=7)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(7, 300.00, 'WiFi, TV, Casino Access',          'single', 'city',    false, NULL),
(7, 400.00, 'WiFi, TV, Casino Access, Minibar', 'double', 'city',    true,  NULL),
(7, 480.00, 'WiFi, TV, Pool, Minibar',          'triple', 'city',    true,  NULL),
(7, 580.00, 'WiFi, TV, Jacuzzi, Pool, Minibar', 'suite',  'city',    true,  NULL),
(7, 250.00, 'WiFi, TV',                         'single', 'none',    false, NULL),
(7, 350.00, 'WiFi, TV, Gym Access',             'double', 'garden',  false, 'Scratched headboard');

-- Hotel 8 (Marriott San Francisco, hotel_id=8)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(8, 290.00, 'WiFi, TV, Coffee Maker',           'single', 'city',    false, NULL),
(8, 380.00, 'WiFi, TV, Minibar',                'double', 'city',    true,  NULL),
(8, 460.00, 'WiFi, TV, Minibar, Gym Access',    'triple', 'city',    true,  NULL),
(8, 560.00, 'WiFi, TV, Jacuzzi, Bay View',      'suite',  'sea',     true,  NULL),
(8, 230.00, 'WiFi, TV',                         'single', 'none',    false, NULL),
(8, 320.00, 'WiFi, TV, Coffee Maker, Safe',     'double', 'sea',     false, NULL);

-- Rooms for Chain 2 (Hilton) hotels 9-16
-- Hotel 9 (Hilton NYC Midtown)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(9, 370.00, 'WiFi, TV, Minibar, Concierge',     'double', 'city',    true,  NULL),
(9, 520.00, 'WiFi, TV, Jacuzzi, Lounge',        'suite',  'city',    true,  NULL),
(9, 240.00, 'WiFi, TV, Coffee Maker',           'single', 'city',    false, NULL),
(9, 300.00, 'WiFi, TV, Safe',                   'double', 'none',    false, 'Worn carpet'),
(9, 430.00, 'WiFi, TV, Minibar, Safe',          'triple', 'city',    true,  NULL),
(9, 610.00, 'WiFi, TV, Jacuzzi, Balcony',       'suite',  'city',    true,  NULL);

-- Hotel 10 (Hilton Chicago Michigan)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(10, 270.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(10, 360.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(10, 440.00, 'WiFi, TV, Spa Access, Minibar',   'triple', 'city',    true,  NULL),
(10, 540.00, 'WiFi, TV, Jacuzzi, Minibar',      'suite',  'city',    true,  NULL),
(10, 220.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(10, 300.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 11 (Hilton LA Beverly Hills)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(11, 400.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'mountain',true,  NULL),
(11, 580.00, 'WiFi, TV, Jacuzzi, Private Patio','suite',  'mountain',true,  NULL),
(11, 260.00, 'WiFi, TV, Pool Access',           'single', 'garden',  false, NULL),
(11, 350.00, 'WiFi, TV, Coffee Maker, Safe',    'double', 'garden',  false, NULL),
(11, 470.00, 'WiFi, TV, Spa, Minibar',          'triple', 'mountain',true,  NULL),
(11, 200.00, 'WiFi, TV',                        'single', 'none',    false, 'Chipped tile in bathroom');

-- Hotel 12 (Hilton Boston Rockville)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(12, 230.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(12, 310.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(12, 390.00, 'WiFi, TV, Minibar, Gym Access',   'triple', 'city',    true,  NULL),
(12, 480.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(12, 190.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(12, 270.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 13 (Hilton Boston Back Bay)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(13, 210.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(13, 290.00, 'WiFi, TV, Minibar',               'double', 'city',    false, NULL),
(13, 370.00, 'WiFi, TV, Gym Access',            'triple', 'city',    true,  NULL),
(13, 460.00, 'WiFi, TV, Jacuzzi, Minibar',      'suite',  'city',    true,  NULL),
(13, 180.00, 'WiFi, TV',                        'single', 'none',    false, 'Stain on ceiling'),
(13, 250.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 14 (Hilton Orlando)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(14, 290.00, 'WiFi, TV, Pool Access',           'single', 'garden',  false, NULL),
(14, 390.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'garden',  true,  NULL),
(14, 470.00, 'WiFi, TV, Waterpark Access',      'triple', 'garden',  true,  NULL),
(14, 570.00, 'WiFi, TV, Jacuzzi, Waterpark',    'suite',  'garden',  true,  NULL),
(14, 240.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(14, 330.00, 'WiFi, TV, Safe, Coffee Maker',    'double', 'none',    false, NULL);

-- Hotel 15 (Hilton Atlanta)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(15, 220.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(15, 300.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(15, 380.00, 'WiFi, TV, Gym Access, Minibar',   'triple', 'city',    true,  NULL),
(15, 470.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(15, 185.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(15, 260.00, 'WiFi, TV, Coffee Maker',          'double', 'none',    false, NULL);

-- Hotel 16 (Hilton Denver)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(16, 200.00, 'WiFi, TV, Coffee Maker',          'single', 'mountain',false, NULL),
(16, 280.00, 'WiFi, TV, Minibar',               'double', 'mountain',true,  NULL),
(16, 360.00, 'WiFi, TV, Ski Locker',            'triple', 'mountain',true,  NULL),
(16, 450.00, 'WiFi, TV, Jacuzzi, Ski Locker',   'suite',  'mountain',true,  NULL),
(16, 170.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(16, 240.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Rooms for Chain 3 (Hyatt) hotels 17-24
-- Hotel 17 (Hyatt Chicago Riverwalk)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(17, 330.00, 'WiFi, TV, Riverview Lounge',      'double', 'city',    true,  NULL),
(17, 490.00, 'WiFi, TV, Jacuzzi, Riverview',    'suite',  'city',    true,  NULL),
(17, 210.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(17, 280.00, 'WiFi, TV, Minibar',               'double', 'none',    false, NULL),
(17, 390.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(17, 160.00, 'WiFi, TV',                        'single', 'none',    false, 'Minor wall scuff');

-- Hotel 18 (Hyatt Honolulu)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(18, 420.00, 'WiFi, TV, Beach Access, Minibar', 'double', 'sea',     true,  NULL),
(18, 600.00, 'WiFi, TV, Jacuzzi, Lanai',        'suite',  'sea',     true,  NULL),
(18, 280.00, 'WiFi, TV, Pool Access',           'single', 'sea',     false, NULL),
(18, 360.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'garden',  false, NULL),
(18, 480.00, 'WiFi, TV, Spa, Minibar',          'triple', 'sea',     true,  NULL),
(18, 240.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 19 (Hyatt San Francisco)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(19, 370.00, 'WiFi, TV, Minibar, Bay View',     'double', 'sea',     true,  NULL),
(19, 540.00, 'WiFi, TV, Jacuzzi, Bay View',     'suite',  'sea',     true,  NULL),
(19, 240.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(19, 310.00, 'WiFi, TV, Safe',                  'double', 'city',    false, NULL),
(19, 420.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(19, 190.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 20 (Hyatt Washington DC)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(20, 350.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(20, 510.00, 'WiFi, TV, Jacuzzi, Lounge',       'suite',  'city',    true,  NULL),
(20, 230.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(20, 290.00, 'WiFi, TV, Safe',                  'double', 'none',    false, 'Broken blind'),
(20, 400.00, 'WiFi, TV, Minibar, Gym Access',   'triple', 'city',    true,  NULL),
(20, 170.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 21 (Hyatt Dallas)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(21, 260.00, 'WiFi, TV, Pool Access',           'single', 'city',    false, NULL),
(21, 350.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'city',    true,  NULL),
(21, 430.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(21, 530.00, 'WiFi, TV, Jacuzzi, Pool',         'suite',  'city',    true,  NULL),
(21, 210.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(21, 290.00, 'WiFi, TV, Coffee Maker, Safe',    'double', 'none',    false, NULL);

-- Hotel 22 (Hyatt Seattle)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(22, 310.00, 'WiFi, TV, Minibar, Mountain View','double', 'mountain',true,  NULL),
(22, 470.00, 'WiFi, TV, Jacuzzi, Mountain View','suite',  'mountain',true,  NULL),
(22, 200.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(22, 270.00, 'WiFi, TV, Safe',                  'double', 'city',    false, NULL),
(22, 370.00, 'WiFi, TV, Minibar, Gym',          'triple', 'mountain',true,  NULL),
(22, 150.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 23 (Hyatt Phoenix)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(23, 280.00, 'WiFi, TV, Pool, Minibar',         'double', 'mountain',true,  NULL),
(23, 440.00, 'WiFi, TV, Jacuzzi, Pool',         'suite',  'mountain',true,  NULL),
(23, 180.00, 'WiFi, TV, Pool Access',           'single', 'garden',  false, NULL),
(23, 240.00, 'WiFi, TV, Pool Access, Safe',     'double', 'garden',  false, NULL),
(23, 340.00, 'WiFi, TV, Spa, Minibar',          'triple', 'mountain',true,  NULL),
(23, 140.00, 'WiFi, TV',                        'single', 'none',    false, 'Faded upholstery');

-- Hotel 24 (Hyatt Houston)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(24, 240.00, 'WiFi, TV, Pool Access',           'single', 'city',    false, NULL),
(24, 320.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'city',    true,  NULL),
(24, 400.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(24, 500.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(24, 190.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(24, 270.00, 'WiFi, TV, Coffee Maker',          'double', 'none',    false, NULL);

-- Rooms for Chain 4 (IHG) hotels 25-32
-- Hotel 25 (IHG NYC Tudor)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(25, 340.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(25, 500.00, 'WiFi, TV, Jacuzzi, Lounge',       'suite',  'city',    true,  NULL),
(25, 220.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(25, 280.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL),
(25, 400.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(25, 170.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 26 (IHG Chicago River)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(26, 250.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(26, 330.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(26, 410.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(26, 510.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(26, 200.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(26, 280.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 27 (IHG LA Figueroa)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(27, 380.00, 'WiFi, TV, Pool, Minibar',         'double', 'city',    true,  NULL),
(27, 560.00, 'WiFi, TV, Jacuzzi, Pool',         'suite',  'city',    true,  NULL),
(27, 250.00, 'WiFi, TV, Pool Access',           'single', 'city',    false, NULL),
(27, 320.00, 'WiFi, TV, Safe, Coffee Maker',    'double', 'none',    false, 'Scratch on door'),
(27, 450.00, 'WiFi, TV, Spa, Minibar',          'triple', 'city',    true,  NULL),
(27, 200.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 28 (IHG Miami Surfside)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(28, 360.00, 'WiFi, TV, Beach Access, Minibar', 'double', 'sea',     true,  NULL),
(28, 530.00, 'WiFi, TV, Jacuzzi, Balcony',      'suite',  'sea',     true,  NULL),
(28, 240.00, 'WiFi, TV, Pool Access',           'single', 'sea',     false, NULL),
(28, 300.00, 'WiFi, TV, Pool Access, Safe',     'double', 'garden',  false, NULL),
(28, 420.00, 'WiFi, TV, Minibar, Beach Access', 'triple', 'sea',     true,  NULL),
(28, 190.00, 'WiFi, TV',                        'single', 'none',    false, NULL);

-- Hotel 29 (IHG Boston Soldiers Field)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(29, 220.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(29, 300.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(29, 380.00, 'WiFi, TV, Gym Access',            'triple', 'city',    true,  NULL),
(29, 470.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(29, 175.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(29, 250.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 30 (IHG Las Vegas Strip)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(30, 320.00, 'WiFi, TV, Casino Access',         'single', 'city',    false, NULL),
(30, 430.00, 'WiFi, TV, Casino, Minibar',       'double', 'city',    true,  NULL),
(30, 510.00, 'WiFi, TV, Pool, Minibar',         'triple', 'city',    true,  NULL),
(30, 620.00, 'WiFi, TV, Jacuzzi, Pool, Casino', 'suite',  'city',    true,  NULL),
(30, 260.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(30, 370.00, 'WiFi, TV, Gym Access',            'double', 'none',    false, NULL);

-- Hotel 31 (IHG Houston Galleria)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(31, 250.00, 'WiFi, TV, Pool Access',           'single', 'city',    false, NULL),
(31, 340.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'city',    true,  NULL),
(31, 420.00, 'WiFi, TV, Minibar, Gym',          'triple', 'city',    true,  NULL),
(31, 520.00, 'WiFi, TV, Jacuzzi, Minibar',      'suite',  'city',    true,  NULL),
(31, 200.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(31, 280.00, 'WiFi, TV, Coffee Maker',          'double', 'none',    false, NULL);

-- Hotel 32 (IHG Denver Aurora)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(32, 190.00, 'WiFi, TV, Coffee Maker',          'single', 'mountain',false, NULL),
(32, 260.00, 'WiFi, TV, Minibar',               'double', 'mountain',true,  NULL),
(32, 340.00, 'WiFi, TV, Ski Access',            'triple', 'mountain',true,  NULL),
(32, 430.00, 'WiFi, TV, Jacuzzi, Ski Access',   'suite',  'mountain',true,  NULL),
(32, 160.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(32, 220.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Rooms for Chain 5 (Best Western) hotels 33-40
-- Hotel 33 (BW NYC Herald Square)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(33, 250.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(33, 320.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(33, 390.00, 'WiFi, TV, Minibar, Safe',         'triple', 'city',    true,  NULL),
(33, 470.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(33, 200.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(33, 270.00, 'WiFi, TV, Coffee Maker',          'double', 'none',    false, 'Worn bedspread');

-- Hotel 34 (BW Chicago Ontario)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(34, 180.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(34, 240.00, 'WiFi, TV',                        'double', 'city',    false, NULL),
(34, 300.00, 'WiFi, TV, Minibar',               'triple', 'city',    true,  NULL),
(34, 380.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(34, 150.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(34, 210.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 35 (BW LA Highland)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(35, 260.00, 'WiFi, TV, Pool Access',           'single', 'city',    false, NULL),
(35, 340.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'city',    true,  NULL),
(35, 420.00, 'WiFi, TV, Minibar, Gym',          'triple', 'mountain',true,  NULL),
(35, 510.00, 'WiFi, TV, Jacuzzi, Pool',         'suite',  'mountain',true,  NULL),
(35, 210.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(35, 290.00, 'WiFi, TV, Coffee Maker, Safe',    'double', 'none',    false, NULL);

-- Hotel 36 (BW Boston TD)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(36, 200.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(36, 270.00, 'WiFi, TV, Minibar',               'double', 'city',    false, NULL),
(36, 340.00, 'WiFi, TV, Gym Access',            'triple', 'city',    true,  NULL),
(36, 420.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(36, 165.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(36, 230.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 37 (BW Miami Biscayne)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(37, 270.00, 'WiFi, TV, Pool Access',           'single', 'sea',     false, NULL),
(37, 360.00, 'WiFi, TV, Pool Access, Minibar',  'double', 'sea',     true,  NULL),
(37, 440.00, 'WiFi, TV, Beach Access, Minibar', 'triple', 'sea',     true,  NULL),
(37, 540.00, 'WiFi, TV, Jacuzzi, Beach Access', 'suite',  'sea',     true,  NULL),
(37, 220.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(37, 300.00, 'WiFi, TV, Coffee Maker, Safe',    'double', 'garden',  false, NULL);

-- Hotel 38 (BW Las Vegas Premier)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(38, 280.00, 'WiFi, TV, Casino Access',         'single', 'city',    false, NULL),
(38, 370.00, 'WiFi, TV, Casino, Minibar',       'double', 'city',    true,  NULL),
(38, 450.00, 'WiFi, TV, Pool, Minibar',         'triple', 'city',    true,  NULL),
(38, 560.00, 'WiFi, TV, Jacuzzi, Pool, Casino', 'suite',  'city',    true,  NULL),
(38, 230.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(38, 320.00, 'WiFi, TV, Gym Access',            'double', 'none',    false, NULL);

-- Hotel 39 (BW Houston Lamar)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(39, 210.00, 'WiFi, TV, Coffee Maker',          'single', 'city',    false, NULL),
(39, 280.00, 'WiFi, TV, Minibar',               'double', 'city',    true,  NULL),
(39, 360.00, 'WiFi, TV, Minibar, Pool',         'triple', 'city',    true,  NULL),
(39, 450.00, 'WiFi, TV, Jacuzzi',               'suite',  'city',    true,  NULL),
(39, 170.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(39, 240.00, 'WiFi, TV, Safe',                  'double', 'none',    false, NULL);

-- Hotel 40 (BW Denver Colfax)
INSERT INTO room (hotel_id, price, amenities, capacity, view, extendable, damages) VALUES
(40, 180.00, 'WiFi, TV, Coffee Maker',          'single', 'mountain',false, NULL),
(40, 250.00, 'WiFi, TV, Minibar',               'double', 'mountain',true,  NULL),
(40, 320.00, 'WiFi, TV, Ski Access',            'triple', 'mountain',true,  NULL),
(40, 410.00, 'WiFi, TV, Jacuzzi',               'suite',  'mountain',true,  NULL),
(40, 150.00, 'WiFi, TV',                        'single', 'none',    false, NULL),
(40, 210.00, 'WiFi, TV, Safe',                  'quad',   'none',    false, NULL);

-- Clients
INSERT INTO client (full_name, address, ssn, registration_date) VALUES
('Alice Johnson',    '45 Oak Street, New York',       '123-45-6789', '2023-01-15'),
('Bob Williams',     '220 Pine Ave, Los Angeles',     '234-56-7890', '2023-03-22'),
('Carol Martinez',   '78 Elm Rd, Chicago',            '345-67-8901', '2023-05-10'),
('David Brown',      '99 Maple Lane, Miami',          '456-78-9012', '2023-07-04'),
('Eva Davis',        '312 Cedar Dr, Boston',          '567-89-0123', '2023-08-19'),
('Frank Wilson',     '555 Birch Blvd, Seattle',       '678-90-1234', '2023-09-30'),
('Grace Lee',        '88 Walnut St, Las Vegas',       '789-01-2345', '2023-11-05'),
('Henry Taylor',     '14 Spruce Ct, Houston',         '890-12-3456', '2024-01-12'),
('Isabella Anderson','37 Aspen Way, Phoenix',         '901-23-4567', '2024-02-28'),
('James Thomas',     '601 Rosewood Ave, Denver',      '012-34-5678', '2024-04-07'),
('Karen Jackson',    '19 Magnolia Dr, Atlanta',       '111-22-3333', '2024-05-15'),
('Liam White',       '422 Cypress St, Orlando',       '222-33-4444', '2024-06-20');

-- Employees
INSERT INTO employee (hotel_id, full_name, address, ssn, role) VALUES
(1,  'Michael Scott',    '100 Manager Row, New York',    '321-54-9876', 'Manager'),
(1,  'Dwight Shrute',    '200 Beet Farm, New York',      '432-65-0987', 'Receptionist'),
(2,  'Jim Halpert',      '15 Prank St, New York',        '543-76-1098', 'Concierge'),
(3,  'Pam Beesly',       '77 Art Blvd, Los Angeles',     '654-87-2109', 'Receptionist'),
(4,  'Stanley Hudson',   '5 Crossword Ave, Chicago',     '765-98-3210', 'Manager'),
(5,  'Angela Martin',    '88 Cat Lane, Miami',           '876-09-4321', 'Housekeeping'),
(6,  'Kevin Malone',     '33 Chili Rd, Portland',        '987-10-5432', 'Receptionist'),
(7,  'Oscar Martinez',   '50 Accounting Blvd, Las Vegas','098-21-6543', 'Concierge'),
(8,  'Ryan Howard',      '22 Startup Way, San Francisco','109-32-7654', 'Manager'),
(9,  'Kelly Kapoor',     '99 Fashion St, New York',      '210-43-8765', 'Receptionist'),
(10, 'Toby Flenderson',  '14 HR Ave, Chicago',           '321-54-9765', 'Maintenance'),
(11, 'Phyllis Vance',    '60 Bouquet Dr, Los Angeles',   '432-65-0876', 'Housekeeping'),
(12, 'Meredith Palmer',  '75 Supply Rd, Boston',         '543-76-1987', 'Maintenance'),
(15, 'Creed Bratton',    '1 Mystery Ln, Atlanta',        '654-87-2098', 'Concierge'),
(20, 'Roy Anderson',     '45 Warehouse St, Washington',  '765-98-3109', 'Maintenance');

-- Reservations (mix of active, cancelled, converted)
INSERT INTO reservation (client_id, room_id, start_date, end_date, status) VALUES
(1,  1,  '2025-07-01', '2025-07-05', 'active'),
(2,  13, '2025-07-10', '2025-07-15', 'active'),
(3,  25, '2025-08-01', '2025-08-07', 'active'),
(4,  37, '2025-08-15', '2025-08-20', 'active'),
(5,  49, '2025-09-01', '2025-09-04', 'active'),
(6,  61, '2025-09-10', '2025-09-15', 'active'),
(7,  73, '2025-10-01', '2025-10-06', 'active'),
(8,  85, '2025-10-20', '2025-10-25', 'active'),
(1,  8,  '2024-12-20', '2024-12-27', 'cancelled'),
(2,  20, '2024-11-05', '2024-11-09', 'cancelled'),
(3,  32, '2024-10-15', '2024-10-18', 'converted'),
(4,  44, '2024-09-01', '2024-09-05', 'converted'),
(5,  56, '2025-01-10', '2025-01-14', 'cancelled'),
(9,  97, '2025-07-05', '2025-07-09', 'active'),
(10, 109,'2025-07-20', '2025-07-25', 'active'),
(11, 121,'2025-08-10', '2025-08-14', 'active'),
(12, 133,'2025-09-05', '2025-09-10', 'active');

-- Rentals (some linked to reservations, some direct)
INSERT INTO rental (reservation_id, client_id, room_id, employee_id, start_date, end_date) VALUES
(11, 3,  32, 11, '2024-10-15', '2024-10-18'),
(12, 4,  44,  5, '2024-09-01', '2024-09-05'),
(NULL, 6, 62,  8, '2024-08-01', '2024-08-05'),
(NULL, 7, 74,  1, '2024-07-20', '2024-07-25'),
(NULL, 9, 98, 10, '2024-06-10', '2024-06-15'),
(NULL,10,110,  4, '2024-05-01', '2024-05-06'),
(NULL,11,122,  7, '2025-03-15', '2025-03-20'),
(NULL,12,134,  3, '2025-04-01', '2025-04-04');

-- Update hotel_chain.num_hotels to reflect actual hotel counts
UPDATE hotel_chain SET num_hotels = (
    SELECT COUNT(*) FROM hotel WHERE hotel.chain_id = hotel_chain.chain_id
);

-- =============================================================================
-- Views
-- =============================================================================

CREATE OR REPLACE VIEW available_rooms_by_zone AS
SELECT
    SPLIT_PART(h.address, ', ', 2) AS zone,
    COUNT(r.room_id) AS available_rooms
FROM room r
JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE r.room_id NOT IN (
    SELECT room_id FROM reservation
    WHERE status = 'active'
      AND start_date <= CURRENT_DATE
      AND end_date   >= CURRENT_DATE
    UNION
    SELECT room_id FROM rental
    WHERE start_date <= CURRENT_DATE
      AND end_date   >= CURRENT_DATE
)
GROUP BY SPLIT_PART(h.address, ', ', 2);

CREATE OR REPLACE VIEW hotel_total_capacity AS
SELECT
    h.hotel_id,
    h.address,
    hc.name AS chain_name,
    COUNT(r.room_id) AS total_rooms,
    SUM(CASE r.capacity
        WHEN 'single' THEN 1
        WHEN 'double' THEN 2
        WHEN 'triple' THEN 3
        WHEN 'quad'   THEN 4
        WHEN 'suite'  THEN 4
        ELSE 0
    END) AS total_capacity
FROM hotel h
JOIN hotel_chain hc ON h.chain_id = hc.chain_id
LEFT JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_id, h.address, hc.name;

-- =============================================================================
-- Indexes
-- =============================================================================

CREATE INDEX idx_room_hotel_id       ON room(hotel_id);
CREATE INDEX idx_reservation_client  ON reservation(client_id);
CREATE INDEX idx_rental_client_id    ON rental(client_id);
CREATE INDEX idx_room_price          ON room(price);
CREATE INDEX idx_hotel_chain_id      ON hotel(chain_id);
