// API Route: Fetch hurricane data for visualizations
app.get('/api/hurricane-data', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT year, event_type, SUM(casualties) AS total_casualties
            FROM hurricane_archive_summary
            GROUP BY year, event_type
            ORDER BY year;
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching hurricane data:', error.message);
        res.status(500).json({ error: 'Database query failed' });
    }
});

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
// Fetch data from the API
async function fetchHurricaneData() {
    try {
        const response = await fetch('/api/hurricane-data');
        const data = await response.json();
        createChart(data);
    } catch (error) {
        console.error('Error fetching hurricane data:', error);
    }
}

// Create a Chart.js bar chart
function createChart(data) {
    const ctx = document.getElementById('myChart').getContext('2d');
    const labels = data.map(item => item.year);
    const casualties = data.map(item => item.total_casualties);

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Total Casualties',
                data: casualties,
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                borderColor: 'rgba(75, 192, 192, 1)',
                borderWidth: 1
            }]
        },
        options: {
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

// Run the fetch function on page load
fetchHurricaneData();