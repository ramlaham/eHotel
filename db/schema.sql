-- e-Hotels Project schema

-- Drop tables first so the file can be run again
DROP TABLE IF EXISTS archive_rental CASCADE;
DROP TABLE IF EXISTS archive_reservation CASCADE;
DROP TABLE IF EXISTS rental CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS room_amenity CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS hotel_manager CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS hotel_phone CASCADE;
DROP TABLE IF EXISTS hotel_email CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS hotel_chain_phone CASCADE;
DROP TABLE IF EXISTS hotel_chain_email CASCADE;
DROP TABLE IF EXISTS hotel_chain CASCADE;

-- Hotel chains
CREATE TABLE hotel_chain (
    chain_id                INTEGER PRIMARY KEY,
    chain_name              VARCHAR(100) NOT NULL,
    central_office_address  VARCHAR(150) NOT NULL,
    number_of_hotels        INTEGER NOT NULL CHECK (number_of_hotels >= 0)
);

CREATE TABLE hotel_chain_email (
    chain_id        INTEGER NOT NULL,
    email_address   VARCHAR(100) NOT NULL,
    PRIMARY KEY (chain_id, email_address),
    FOREIGN KEY (chain_id)
        REFERENCES hotel_chain(chain_id)
        ON DELETE CASCADE
);

CREATE TABLE hotel_chain_phone (
    chain_id        INTEGER NOT NULL,
    phone_number    VARCHAR(20) NOT NULL,
    PRIMARY KEY (chain_id, phone_number),
    FOREIGN KEY (chain_id)
        REFERENCES hotel_chain(chain_id)
        ON DELETE CASCADE
);

-- Hotels
-- Area is included for the area-based requirement and view
CREATE TABLE hotel (
    hotel_id         INTEGER PRIMARY KEY,
    chain_id         INTEGER NOT NULL,
    hotel_name       VARCHAR(100) NOT NULL,
    category         INTEGER NOT NULL CHECK (category BETWEEN 1 AND 5),
    address          VARCHAR(150) NOT NULL,
    area             VARCHAR(100) NOT NULL,
    room_count       INTEGER NOT NULL CHECK (room_count >= 0),
    FOREIGN KEY (chain_id)
        REFERENCES hotel_chain(chain_id)
        ON DELETE CASCADE
);

CREATE TABLE hotel_email (
    hotel_id         INTEGER NOT NULL,
    email_address    VARCHAR(100) NOT NULL,
    PRIMARY KEY (hotel_id, email_address),
    FOREIGN KEY (hotel_id)
        REFERENCES hotel(hotel_id)
        ON DELETE CASCADE
);

CREATE TABLE hotel_phone (
    hotel_id         INTEGER NOT NULL,
    phone_number     VARCHAR(20) NOT NULL,
    PRIMARY KEY (hotel_id, phone_number),
    FOREIGN KEY (hotel_id)
        REFERENCES hotel(hotel_id)
        ON DELETE CASCADE
);

-- Clients
CREATE TABLE client (
    client_id            INTEGER PRIMARY KEY,
    first_name           VARCHAR(50) NOT NULL,
    last_name            VARCHAR(50) NOT NULL,
    address              VARCHAR(150) NOT NULL,
    ssn                  VARCHAR(11) NOT NULL UNIQUE,
    registration_date    DATE NOT NULL
);

-- Employees
CREATE TABLE employee (
    employee_id      INTEGER PRIMARY KEY,
    hotel_id         INTEGER NOT NULL,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    address          VARCHAR(150) NOT NULL,
    ssn              VARCHAR(11) NOT NULL UNIQUE,
    role             VARCHAR(50) NOT NULL,
    FOREIGN KEY (hotel_id)
        REFERENCES hotel(hotel_id)
        ON DELETE CASCADE
);

-- Hotel managers
-- One manager row per hotel
-- The trigger later checks that the employee belongs to that hotel
CREATE TABLE hotel_manager (
    hotel_id               INTEGER PRIMARY KEY,
    manager_employee_id    INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (hotel_id)
        REFERENCES hotel(hotel_id)
        ON DELETE CASCADE,
    FOREIGN KEY (manager_employee_id)
        REFERENCES employee(employee_id)
);

-- Rooms
-- Uses the same composite primary key idea as liverable 1
-- Surface area is included for room search filters
CREATE TABLE room (
    hotel_id               INTEGER NOT NULL,
    room_number            VARCHAR(10) NOT NULL,
    price                  NUMERIC(10,2) NOT NULL CHECK (price > 0),
    capacity               INTEGER NOT NULL CHECK (capacity >= 1),
    surface_area           NUMERIC(8,2) NOT NULL CHECK (surface_area > 0),
    view_type              VARCHAR(50) NOT NULL,
    extra_bed_possible     BOOLEAN NOT NULL,
    condition_state        VARCHAR(255) NOT NULL,
    PRIMARY KEY (hotel_id, room_number),
    FOREIGN KEY (hotel_id)
        REFERENCES hotel(hotel_id)
        ON DELETE CASCADE
);

CREATE TABLE room_amenity (
    hotel_id         INTEGER NOT NULL,
    room_number      VARCHAR(10) NOT NULL,
    amenity          VARCHAR(255) NOT NULL,
    PRIMARY KEY (hotel_id, room_number, amenity),
    FOREIGN KEY (hotel_id, room_number)
        REFERENCES room(hotel_id, room_number)
        ON DELETE CASCADE
);

-- Reservations
CREATE TABLE reservation (
    reservation_id      INTEGER PRIMARY KEY,
    client_id           INTEGER NOT NULL,
    hotel_id            INTEGER NOT NULL,
    room_number         VARCHAR(10) NOT NULL,
    reservation_date    DATE NOT NULL,
    check_in_date       DATE NOT NULL,
    check_out_date      DATE NOT NULL,
    status              VARCHAR(20) NOT NULL,
    FOREIGN KEY (client_id)
        REFERENCES client(client_id),
    FOREIGN KEY (hotel_id, room_number)
        REFERENCES room(hotel_id, room_number),
    CHECK (check_out_date > check_in_date),
    CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed'))
);

-- Rentals
-- reservation_id can be null for direct rentals
-- UNIQUE(reservation_id) means one reservation can become only one rental
CREATE TABLE rental (
    rental_id                    INTEGER PRIMARY KEY,
    client_id                    INTEGER NOT NULL,
    hotel_id                     INTEGER NOT NULL,
    room_number                  VARCHAR(10) NOT NULL,
    reservation_id               INTEGER UNIQUE,
    processed_by_employee_id     INTEGER,
    rental_start_date            DATE NOT NULL,
    rental_end_date              DATE NOT NULL,
    status                       VARCHAR(20) NOT NULL,
    FOREIGN KEY (client_id)
        REFERENCES client(client_id),
    FOREIGN KEY (hotel_id, room_number)
        REFERENCES room(hotel_id, room_number),
    FOREIGN KEY (processed_by_employee_id)
        REFERENCES employee(employee_id),
    CHECK (rental_end_date > rental_start_date),
    CHECK (status IN ('active', 'completed', 'cancelled'))
);

-- Archive tables
-- These keep old data even after rows are deleted from active tables
CREATE TABLE archive_reservation (
    archive_reservation_id   INTEGER PRIMARY KEY,
    original_check_in_date   DATE NOT NULL,
    original_check_out_date  DATE NOT NULL,
    client_first_name        VARCHAR(50) NOT NULL,
    client_last_name         VARCHAR(50) NOT NULL,
    archived_status          VARCHAR(20) NOT NULL
);

CREATE TABLE archive_rental (
    archive_rental_id         INTEGER PRIMARY KEY,
    original_start_date       DATE NOT NULL,
    original_end_date         DATE NOT NULL,
    client_first_name         VARCHAR(50) NOT NULL,
    client_last_name          VARCHAR(50) NOT NULL,
    damages_before_check_in   VARCHAR(255),
    damages_after_check_in    VARCHAR(255)
);
