-- e-Hotels Project triggers
-- Drop old triggers and functions so the file can be run again
DROP TRIGGER IF EXISTS trg_check_hotel_manager_same_hotel ON hotel_manager;
DROP FUNCTION IF EXISTS check_hotel_manager_same_hotel();

DROP TRIGGER IF EXISTS trg_prevent_overlapping_reservations ON reservation;
DROP FUNCTION IF EXISTS prevent_overlapping_reservations();

DROP TRIGGER IF EXISTS trg_prevent_overlapping_rentals ON rental;
DROP FUNCTION IF EXISTS prevent_overlapping_rentals();

DROP TRIGGER IF EXISTS trg_validate_rental_conversion ON rental;
DROP FUNCTION IF EXISTS validate_rental_conversion();

DROP TRIGGER IF EXISTS trg_archive_reservation_before_delete ON reservation;
DROP FUNCTION IF EXISTS archive_reservation_before_delete();

DROP TRIGGER IF EXISTS trg_archive_rental_before_delete ON rental;
DROP FUNCTION IF EXISTS archive_rental_before_delete();

-- Makes sure the assigned hotel manager works at that same hotel
CREATE OR REPLACE FUNCTION check_hotel_manager_same_hotel()
RETURNS TRIGGER AS $$
DECLARE
    employee_hotel_id INTEGER;
BEGIN
    SELECT hotel_id
    INTO employee_hotel_id
    FROM employee
    WHERE employee_id = NEW.manager_employee_id;

    IF employee_hotel_id IS NULL THEN
        RAISE EXCEPTION 'Manager employee % does not exist.', NEW.manager_employee_id;
    END IF;

    IF employee_hotel_id <> NEW.hotel_id THEN
        RAISE EXCEPTION
            'Manager employee % must belong to hotel %.',
            NEW.manager_employee_id, NEW.hotel_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_hotel_manager_same_hotel
BEFORE INSERT OR UPDATE ON hotel_manager
FOR EACH ROW
EXECUTE FUNCTION check_hotel_manager_same_hotel();

-- Stops two active reservations from overlapping for the same room
-- Only checks reservations with pending or confirmed status
CREATE OR REPLACE FUNCTION prevent_overlapping_reservations()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('pending', 'confirmed') THEN
        IF EXISTS (
            SELECT 1
            FROM reservation r
            WHERE r.hotel_id = NEW.hotel_id
              AND r.room_number = NEW.room_number
              AND r.status IN ('pending', 'confirmed')
              AND r.reservation_id <> NEW.reservation_id
              AND NEW.check_in_date < r.check_out_date
              AND NEW.check_out_date > r.check_in_date
        ) THEN
            RAISE EXCEPTION
                'Overlapping active reservation detected for hotel %, room %.',
                NEW.hotel_id, NEW.room_number;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_overlapping_reservations
BEFORE INSERT OR UPDATE ON reservation
FOR EACH ROW
EXECUTE FUNCTION prevent_overlapping_reservations();

-- Stops two active rentals from overlapping for the same room
CREATE OR REPLACE FUNCTION prevent_overlapping_rentals()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'active' THEN
        IF EXISTS (
            SELECT 1
            FROM rental rt
            WHERE rt.hotel_id = NEW.hotel_id
              AND rt.room_number = NEW.room_number
              AND rt.status = 'active'
              AND rt.rental_id <> NEW.rental_id
              AND NEW.rental_start_date < rt.rental_end_date
              AND NEW.rental_end_date > rt.rental_start_date
        ) THEN
            RAISE EXCEPTION
                'Overlapping active rental detected for hotel %, room %.',
                NEW.hotel_id, NEW.room_number;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_overlapping_rentals
BEFORE INSERT OR UPDATE ON rental
FOR EACH ROW
EXECUTE FUNCTION prevent_overlapping_rentals();

-- Checks that a rental made from a reservation actually matches it
-- Also makes sure the rental does not conflict with another reservation
CREATE OR REPLACE FUNCTION validate_rental_conversion()
RETURNS TRIGGER AS $$
DECLARE
    res_client_id      INTEGER;
    res_hotel_id       INTEGER;
    res_room_number    VARCHAR(10);
    res_check_in       DATE;
    res_check_out      DATE;
BEGIN
    IF NEW.reservation_id IS NOT NULL THEN
        SELECT client_id, hotel_id, room_number, check_in_date, check_out_date
        INTO res_client_id, res_hotel_id, res_room_number, res_check_in, res_check_out
        FROM reservation
        WHERE reservation_id = NEW.reservation_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Reservation % does not exist.', NEW.reservation_id;
        END IF;

        IF NEW.client_id <> res_client_id THEN
            RAISE EXCEPTION
                'Rental client must match reservation client for reservation %.',
                NEW.reservation_id;
        END IF;

        IF NEW.hotel_id <> res_hotel_id OR NEW.room_number <> res_room_number THEN
            RAISE EXCEPTION
                'Rental room must match reservation room for reservation %.',
                NEW.reservation_id;
        END IF;

        IF NEW.rental_start_date <> res_check_in OR NEW.rental_end_date <> res_check_out THEN
            RAISE EXCEPTION
                'Rental dates must match reservation dates for reservation %.',
                NEW.reservation_id;
        END IF;
    END IF;

    -- Prevents conflicts with another reservation for the same room
    IF NEW.status = 'active' THEN
        IF EXISTS (
            SELECT 1
            FROM reservation r
            WHERE r.hotel_id = NEW.hotel_id
              AND r.room_number = NEW.room_number
              AND r.status IN ('pending', 'confirmed')
              AND r.reservation_id IS DISTINCT FROM NEW.reservation_id
              AND NEW.rental_start_date < r.check_out_date
              AND NEW.rental_end_date > r.check_in_date
        ) THEN
            RAISE EXCEPTION
                'Active rental conflicts with another active reservation for hotel %, room %.',
                NEW.hotel_id, NEW.room_number;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_rental_conversion
BEFORE INSERT OR UPDATE ON rental
FOR EACH ROW
EXECUTE FUNCTION validate_rental_conversion();

-- Saves reservation info before a reservation is deleted
CREATE OR REPLACE FUNCTION archive_reservation_before_delete()
RETURNS TRIGGER AS $$
DECLARE
    next_archive_id INTEGER;
    c_first_name    VARCHAR(50);
    c_last_name     VARCHAR(50);
BEGIN
    SELECT COALESCE(MAX(archive_reservation_id), 0) + 1
    INTO next_archive_id
    FROM archive_reservation;

    SELECT first_name, last_name
    INTO c_first_name, c_last_name
    FROM client
    WHERE client_id = OLD.client_id;

    INSERT INTO archive_reservation (
        archive_reservation_id,
        original_check_in_date,
        original_check_out_date,
        client_first_name,
        client_last_name,
        archived_status
    )
    VALUES (
        next_archive_id,
        OLD.check_in_date,
        OLD.check_out_date,
        COALESCE(c_first_name, 'Unknown'),
        COALESCE(c_last_name, 'Unknown'),
        OLD.status
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_reservation_before_delete
BEFORE DELETE ON reservation
FOR EACH ROW
EXECUTE FUNCTION archive_reservation_before_delete();

-- Saves rental info before a rental is deleted
-- Uses the room's current condition as the before-check-in damage value
CREATE OR REPLACE FUNCTION archive_rental_before_delete()
RETURNS TRIGGER AS $$
DECLARE
    next_archive_id   INTEGER;
    c_first_name      VARCHAR(50);
    c_last_name       VARCHAR(50);
    room_condition    VARCHAR(255);
BEGIN
    SELECT COALESCE(MAX(archive_rental_id), 0) + 1
    INTO next_archive_id
    FROM archive_rental;

    SELECT first_name, last_name
    INTO c_first_name, c_last_name
    FROM client
    WHERE client_id = OLD.client_id;

    SELECT condition_state
    INTO room_condition
    FROM room
    WHERE hotel_id = OLD.hotel_id
      AND room_number = OLD.room_number;

    INSERT INTO archive_rental (
        archive_rental_id,
        original_start_date,
        original_end_date,
        client_first_name,
        client_last_name,
        damages_before_check_in,
        damages_after_check_in
    )
    VALUES (
        next_archive_id,
        OLD.rental_start_date,
        OLD.rental_end_date,
        COALESCE(c_first_name, 'Unknown'),
        COALESCE(c_last_name, 'Unknown'),
        room_condition,
        NULL
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_rental_before_delete
BEFORE DELETE ON rental
FOR EACH ROW
EXECUTE FUNCTION archive_rental_before_delete();
