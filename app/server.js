const express = require('express');
const path = require('path');
const pool = require('./db');

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

app.post('/api/search-rooms', async (req, res) => {
  try {
    const {
      checkInDate,
      checkOutDate,
      area,
      chainId,
      category,
      capacity,
      surfaceArea,
      maxPrice
    } = req.body;

    if (!checkInDate || !checkOutDate) {
      return res.status(400).json({ error: 'Check-in and check-out dates are required.' });
    }

    if (checkOutDate <= checkInDate) {
      return res.status(400).json({ error: 'Check-out date must be after check-in date.' });
    }

    let query = `
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
      WHERE NOT EXISTS (
          SELECT 1
          FROM reservation res
          WHERE res.hotel_id = r.hotel_id
            AND res.room_number = r.room_number
            AND res.status IN ('pending', 'confirmed')
            AND $1 < res.check_out_date
            AND $2 > res.check_in_date
      )
      AND NOT EXISTS (
          SELECT 1
          FROM rental rt
          WHERE rt.hotel_id = r.hotel_id
            AND rt.room_number = r.room_number
            AND rt.status = 'active'
            AND $1 < rt.rental_end_date
            AND $2 > rt.rental_start_date
      )
    `;

    const values = [checkInDate, checkOutDate];
    let paramIndex = 3;

    if (area) {
      query += ` AND h.area = $${paramIndex}`;
      values.push(area);
      paramIndex++;
    }

    if (chainId) {
      query += ` AND h.chain_id = $${paramIndex}`;
      values.push(chainId);
      paramIndex++;
    }

    if (category) {
      query += ` AND h.category >= $${paramIndex}`;
      values.push(category);
      paramIndex++;
    }

    if (capacity) {
      query += ` AND r.capacity >= $${paramIndex}`;
      values.push(capacity);
      paramIndex++;
    }

    if (surfaceArea) {
      query += ` AND r.surface_area >= $${paramIndex}`;
      values.push(surfaceArea);
      paramIndex++;
    }

    if (maxPrice) {
      query += ` AND r.price <= $${paramIndex}`;
      values.push(maxPrice);
      paramIndex++;
    }

    query += ` ORDER BY h.hotel_name, r.price`;

    const result = await pool.query(query, values);
    res.json(result.rows);
  } catch (error) {
    console.error('Error searching rooms:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/clients', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT client_id, first_name, last_name
      FROM client
      ORDER BY client_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching clients:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/rooms-by-hotel/:hotelId', async (req, res) => {
  try {
    const { hotelId } = req.params;

    const result = await pool.query(`
      SELECT room_number, capacity, price
      FROM room
      WHERE hotel_id = $1
      ORDER BY room_number
    `, [hotelId]);

    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching rooms by hotel:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/reservations', async (req, res) => {
  try {
    const result = await pool.query(`
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
      JOIN client c ON res.client_id = c.client_id
      JOIN hotel h ON res.hotel_id = h.hotel_id
      ORDER BY res.reservation_id
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching reservations:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/reservations', async (req, res) => {
  try {
    const {
      clientId,
      hotelId,
      roomNumber,
      checkInDate,
      checkOutDate,
      status
    } = req.body;

    if (!clientId || !hotelId || !roomNumber || !checkInDate || !checkOutDate || !status) {
      return res.status(400).json({ error: 'All fields are required.' });
    }

    if (checkOutDate <= checkInDate) {
      return res.status(400).json({ error: 'Check-out date must be after check-in date.' });
    }

    const idResult = await pool.query(`
      SELECT COALESCE(MAX(reservation_id), 0) + 1 AS next_id
      FROM reservation
    `);

    const nextId = idResult.rows[0].next_id;

    await pool.query(`
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
      VALUES ($1, $2, $3, $4, CURRENT_DATE, $5, $6, $7)
    `, [nextId, clientId, hotelId, roomNumber, checkInDate, checkOutDate, status]);

    res.json({
      success: true,
      reservation_id: nextId
    });
  } catch (error) {
    console.error('Error creating reservation:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/employees', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT e.employee_id, e.first_name, e.last_name, h.hotel_name
      FROM employee e
      JOIN hotel h ON e.hotel_id = h.hotel_id
      ORDER BY e.employee_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching employees:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/rentals', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
          rt.rental_id,
          c.first_name || ' ' || c.last_name AS client_name,
          h.hotel_name,
          rt.room_number,
          rt.rental_start_date,
          rt.rental_end_date,
          rt.status,
          rt.reservation_id,
          e.first_name || ' ' || e.last_name AS processed_by
      FROM rental rt
      JOIN client c ON rt.client_id = c.client_id
      JOIN hotel h ON rt.hotel_id = h.hotel_id
      LEFT JOIN employee e ON rt.processed_by_employee_id = e.employee_id
      ORDER BY rt.rental_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching rentals:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/convertible-reservations', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
          r.reservation_id,
          r.client_id,
          r.hotel_id,
          r.room_number,
          r.check_in_date,
          r.check_out_date,
          c.first_name || ' ' || c.last_name AS client_name,
          h.hotel_name
      FROM reservation r
      JOIN client c ON r.client_id = c.client_id
      JOIN hotel h ON r.hotel_id = h.hotel_id
      LEFT JOIN rental rt ON r.reservation_id = rt.reservation_id
      WHERE r.status IN ('pending', 'confirmed')
        AND rt.rental_id IS NULL
      ORDER BY r.reservation_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching convertible reservations:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/rentals/direct', async (req, res) => {
  try {
    const { clientId, hotelId, roomNumber, employeeId, startDate, endDate, status } = req.body;

    if (!clientId || !hotelId || !roomNumber || !employeeId || !startDate || !endDate || !status) {
      return res.status(400).json({ error: 'All fields are required.' });
    }

    if (endDate <= startDate) {
      return res.status(400).json({ error: 'End date must be after start date.' });
    }

    const idResult = await pool.query(`
      SELECT COALESCE(MAX(rental_id), 0) + 1 AS next_id
      FROM rental
    `);

    const nextId = idResult.rows[0].next_id;

    await pool.query(`
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
      VALUES ($1, $2, $3, $4, NULL, $5, $6, $7, $8)
    `, [nextId, clientId, hotelId, roomNumber, employeeId, startDate, endDate, status]);

    res.json({ success: true, rental_id: nextId });
  } catch (error) {
    console.error('Error creating direct rental:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/rentals/convert', async (req, res) => {
  try {
    const { reservationId, employeeId, status } = req.body;

    if (!reservationId || !employeeId || !status) {
      return res.status(400).json({ error: 'All fields are required.' });
    }

    const reservationResult = await pool.query(`
      SELECT client_id, hotel_id, room_number, check_in_date, check_out_date
      FROM reservation
      WHERE reservation_id = $1
    `, [reservationId]);

    if (reservationResult.rows.length === 0) {
      return res.status(404).json({ error: 'Reservation not found.' });
    }

    const reservation = reservationResult.rows[0];

    const idResult = await pool.query(`
      SELECT COALESCE(MAX(rental_id), 0) + 1 AS next_id
      FROM rental
    `);

    const nextId = idResult.rows[0].next_id;

    await pool.query(`
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
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    `, [
      nextId,
      reservation.client_id,
      reservation.hotel_id,
      reservation.room_number,
      reservationId,
      employeeId,
      reservation.check_in_date,
      reservation.check_out_date,
      status
    ]);

    res.json({ success: true, rental_id: nextId });
  } catch (error) {
    console.error('Error converting reservation:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/clients/full', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT client_id, first_name, last_name, address, ssn, registration_date
      FROM client
      ORDER BY client_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching full clients:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/clients', async (req, res) => {
  try {
    const { firstName, lastName, address, ssn, registrationDate } = req.body;

    if (!firstName || !lastName || !address || !ssn || !registrationDate) {
      return res.status(400).json({ error: 'All fields are required.' });
    }

    const idResult = await pool.query(`
      SELECT COALESCE(MAX(client_id), 0) + 1 AS next_id
      FROM client
    `);

    const nextId = idResult.rows[0].next_id;

    await pool.query(`
      INSERT INTO client (client_id, first_name, last_name, address, ssn, registration_date)
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [nextId, firstName, lastName, address, ssn, registrationDate]);

    res.json({ success: true, client_id: nextId });
  } catch (error) {
    console.error('Error adding client:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/employees/full', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT e.employee_id, e.first_name, e.last_name, e.address, e.ssn, e.role, h.hotel_name
      FROM employee e
      JOIN hotel h ON e.hotel_id = h.hotel_id
      ORDER BY e.employee_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching full employees:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/employees', async (req, res) => {
  try {
    const { hotelId, firstName, lastName, address, ssn, role } = req.body;

    if (!hotelId || !firstName || !lastName || !address || !ssn || !role) {
      return res.status(400).json({ error: 'All fields are required.' });
    }

    const idResult = await pool.query(`
      SELECT COALESCE(MAX(employee_id), 0) + 1 AS next_id
      FROM employee
    `);

    const nextId = idResult.rows[0].next_id;

    await pool.query(`
      INSERT INTO employee (employee_id, hotel_id, first_name, last_name, address, ssn, role)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [nextId, hotelId, firstName, lastName, address, ssn, role]);

    res.json({ success: true, employee_id: nextId });
  } catch (error) {
    console.error('Error adding employee:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/hotels/full', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT h.hotel_id, h.hotel_name, h.category, h.area, h.address, h.room_count, hc.chain_name
      FROM hotel h
      JOIN hotel_chain hc ON h.chain_id = hc.chain_id
      ORDER BY h.hotel_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching full hotels:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/rooms', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT r.hotel_id, h.hotel_name, r.room_number, r.price, r.capacity, r.surface_area,
             r.view_type, r.extra_bed_possible, r.condition_state
      FROM room r
      JOIN hotel h ON r.hotel_id = h.hotel_id
      ORDER BY r.hotel_id, r.room_number
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching rooms:', error);
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/reservations/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ error: 'Status is required.' });
    }

    await pool.query(`
      UPDATE reservation
      SET status = $1
      WHERE reservation_id = $2
    `, [status, id]);

    res.json({ success: true });
  } catch (error) {
    console.error('Error updating reservation:', error);
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/reservations/:id', async (req, res) => {
  try {
    const { id } = req.params;

    await pool.query(`
      DELETE FROM reservation
      WHERE reservation_id = $1
    `, [id]);

    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting reservation:', error);
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/rentals/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ error: 'Status is required.' });
    }

    await pool.query(`
      UPDATE rental
      SET status = $1
      WHERE rental_id = $2
    `, [status, id]);

    res.json({ success: true });
  } catch (error) {
    console.error('Error updating rental:', error);
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/rentals/:id', async (req, res) => {
  try {
    const { id } = req.params;

    await pool.query(`
      DELETE FROM rental
      WHERE rental_id = $1
    `, [id]);

    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting rental:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/test-db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS current_time');
    res.json({
      success: true,
      message: 'Database connection successful',
      time: result.rows[0].current_time,
    });
  } catch (error) {
    console.error('Database connection error:', error);
    res.status(500).json({
      success: false,
      message: 'Database connection failed',
      error: error.message,
    });
  }
});

app.get('/api/chains', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT chain_id, chain_name
      FROM hotel_chain
      ORDER BY chain_name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching chains:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/areas', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT DISTINCT area
      FROM hotel
      ORDER BY area
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching areas:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/hotels', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT h.hotel_id, h.hotel_name, h.area, h.category, hc.chain_name
      FROM hotel h
      JOIN hotel_chain hc ON h.chain_id = hc.chain_id
      ORDER BY h.hotel_id
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching hotels:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});