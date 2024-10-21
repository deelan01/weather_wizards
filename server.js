const express = require('express');
const cors = require('cors');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Ensure environment variables are loaded
if (!process.env.DB_USER || !process.env.DB_PASSWORD) {
    console.error('Missing environment variables. Please check your .env file.');
    process.exit(1);
}

// Configure PostgreSQL pool
const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

// Handle PostgreSQL pool errors
pool.on('error', (err) => {
    console.error('Unexpected error on idle PostgreSQL client:', err);
    process.exit(-1);
});

// Enable CORS (Modify origin for production)
app.use(cors());
// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// API Route: Fetch years range
app.get('/api/years-incidents', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT EXTRACT(YEAR FROM start_date) AS year, 
                    COUNT(we.event_id) AS number_of_hurricanes
             FROM weather_event we
             JOIN weather_event_type wet 
               ON we.weather_event_type_id = wet.weather_event_type_id
             WHERE wet.weather_event_type = 'Hurricane'
             GROUP BY year
             ORDER BY year DESC;`
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching year range:', error.message);
        res.status(500).json({ error: 'Failed to retrieve years and incidents data' });
    }
});

// API Route: Fetch hurricane damage data
app.get('/api/hurricane_damage', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT we.weather_event_name, 
                    TO_CHAR(SUM(weci.cost_amount), 'FM$999,999,999,999,990D00') AS damage_cost
             FROM weather_event we
             JOIN weather_event_type wet 
               ON we.weather_event_type_id = wet.weather_event_type_id
             JOIN weather_event_cost_impact weci 
               ON we.event_id = weci.weather_event_id
             WHERE wet.weather_event_type LIKE '%Hurricane%'
             GROUP BY we.weather_event_name
             ORDER BY damage_cost DESC;`
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching hurricane damage:', error.message);
        res.status(500).json({ error: 'Failed to retrieve hurricane damage data' });
    }
});

// API Route: Fetch casualties data
app.get('/api/casualties', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT EXTRACT(YEAR FROM we.start_date) AS year, 
                    SUM(wehi.casualties) AS number_of_casualties
             FROM weather_event we
             JOIN weather_event_type wet 
               ON we.weather_event_type_id = wet.weather_event_type_id
             JOIN weather_event_human_impact wehi 
               ON we.event_id = wehi.weather_event_id
             WHERE wet.weather_event_type = 'Hurricane'
             GROUP BY year
             ORDER BY year;`
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching casualties:', error.message);
        res.status(500).json({ error: 'Failed to retrieve casualties data' });
    }
});

// API Route: Fetch weather event types data
app.get('/api/event-types', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT wet.weather_event_type, 
                    COUNT(we.weather_event_name) AS weather_event_type_count
             FROM weather_event we
             JOIN weather_event_type wet 
               ON we.weather_event_type_id = wet.weather_event_type_id
             WHERE wet.weather_event_type LIKE '%Hurricane%' 
                OR wet.weather_event_type = 'Tornado'
             GROUP BY wet.weather_event_type
             ORDER BY weather_event_type_count DESC;`
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching event types:', error.message);
        res.status(500).json({ error: 'Failed to retrieve event types data' });
    }
});

// Catch-all route for serving index.html
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
