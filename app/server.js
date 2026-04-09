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