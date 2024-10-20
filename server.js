const express = require('express');
const cors = require('cors');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

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
app.get('/api/years-range', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT MIN(year) AS min_year, MAX(year) AS max_year 
             FROM hurricane_archive_summary_staging`
        );
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching year range:', error.message);
        res.status(500).json({ error: 'Database query failed' });
    }
});


// Catch-all route to serve index.html for unknown routes
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
