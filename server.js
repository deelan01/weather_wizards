const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const config = require('./config.json'); // Load your config file

const app = express();
const PORT = 3000;

// PostgreSQL connection pool using config.json
const pool = new Pool({
    user: config.postgres_connection.user,
    host: config.postgres_connection.server,
    database: 'weather_wizards', // Ensure this matches your database name
    password: config.postgres_connection.password,
    port: config.postgres_connection.port,
});

// Middleware
app.use(cors());

// API endpoint: Fetch storm impact data for regions
app.get('/api/storms/impact', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT region_id, SUM(damage_amount) as total_damage
            FROM weather_event_cost_impact
            GROUP BY region_id
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching storm impact data:', error);
        res.status(500).send('Server Error');
    }
});

// API endpoint: Fetch seasonal patterns of storms
app.get('/api/storms/seasonal', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT EXTRACT(MONTH FROM start_date) as month, COUNT(*) as storm_count
            FROM weather_event
            GROUP BY month
            ORDER BY month;
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching seasonal storm data:', error);
        res.status(500).send('Server Error');
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
