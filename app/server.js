const express = require('express');
const path = require('path');
const pool = require('./db');

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

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