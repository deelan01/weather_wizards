document.addEventListener('DOMContentLoaded', () => {
    console.log('Dashboard initialized!');

    const tabs = document.querySelectorAll('.tab');
    const tabContents = document.querySelectorAll('.tab-content');

    // Show the default tab (Overview) on load
    showTab('overview');

    // Add event listeners to all tabs
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const tabName = tab.getAttribute('data-tab').trim();
            showTab(tabName);
        });
    });

    // Function to display the selected tab content and hide others
    function showTab(tabName) {
        tabContents.forEach(content => {
            content.style.display = content.id === tabName ? 'block' : 'none';
        });
    }

    // Initialize the Historical Storm Events visualizations when the tab is selected
    document.querySelector('.tab[data-tab="historical"]').addEventListener('click', async () => {
        await initializeHistoricalVisualizations();
    });

    // Initialize the Historical Storm Events tab
    async function initializeHistoricalVisualizations() {
        const years = await loadAvailableYears();
        const yearDropdown = document.getElementById('yearDropdown');

        // Populate the year dropdown with available years
        yearDropdown.innerHTML = '<option value="" disabled selected>Select a Year</option>';
        years.forEach(year => {
            const option = document.createElement('option');
            option.value = year;
            option.textContent = year;
            yearDropdown.appendChild(option);
        });

        yearDropdown.addEventListener('change', () => {
            const selectedYear = yearDropdown.value;
            console.log(`Selected Year: ${selectedYear}`);
            updateSeasonalChart(selectedYear);
            updateHeatmap(selectedYear);
        });
    }

    // Load available years from the CSV files
    async function loadAvailableYears() {
        try {
            const summaryData = await d3.csv('data/hurricane_summary.csv');
            const detailData = await d3.csv('data/hurricane_details_with_location.csv');

            const summaryYears = summaryData.map(d => +d.year);
            const detailYears = detailData.map(d => new Date(d.start_date).getFullYear());

            const uniqueYears = Array.from(new Set([...summaryYears, ...detailYears])).sort((a, b) => a - b);
            console.log('Available Years:', uniqueYears);
            return uniqueYears;
        } catch (error) {
            console.error('Error loading CSV files:', error);
            return [];
        }
    }

    // Update the seasonal chart based on the selected year
    async function updateSeasonalChart(year) {
        try {
            const data = await d3.csv('data/hurricane_summary.csv');
            const filteredData = data.filter(d => +d.year === +year);

            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            const monthlyCounts = Array(12).fill(0);

            filteredData.forEach(d => {
                const month = new Date(d.start_date).getMonth();
                monthlyCounts[month]++;
            });

            const chart = echarts.init(document.getElementById('seasonalChart'));
            chart.clear(); // Clear any previous data
            chart.setOption({
                title: { text: `Seasonal Patterns (${year})`, left: 'center' },
                xAxis: { type: 'category', data: months },
                yAxis: { type: 'value', name: 'Storm Count' },
                series: [{ type: 'bar', data: monthlyCounts }]
            });
        } catch (error) {
            console.error('Error updating seasonal chart:', error);
        }
    }

    // Update the heatmap based on the selected year
    async function updateHeatmap(year) {
        try {
            const data = await d3.csv('data/hurricane_details_with_location.csv');
            const filteredData = data.filter(d => new Date(d.start_date).getFullYear() === +year);

            const heatmapData = filteredData
                .map(d => [+d.latitude, +d.longitude, +d.wind_speed])
                .filter(entry => entry.every(val => !isNaN(val) && val !== undefined));

            console.log('Filtered Heatmap Data:', heatmapData);

            if (heatmapData.length === 0) {
                console.warn(`No valid data available for the year ${year}`);
                alert(`No valid data found for the selected year: ${year}`);
                return;
            }

            const chart = echarts.init(document.getElementById('intensityHeatmap'));
            chart.clear(); // Clear any previous data
            chart.setOption({
                title: { text: `Storm Intensity Heatmap (${year})`, left: 'center' },
                tooltip: {
                    trigger: 'item',
                    formatter: params =>
                        `Lat: ${params.value[0]}, Lon: ${params.value[1]}<br>Wind Speed: ${params.value[2]} mph`
                },
                visualMap: {
                    min: 0,
                    max: Math.max(...heatmapData.map(d => d[2])),
                    calculable: true,
                    orient: 'horizontal',
                    left: 'center',
                    bottom: '15%'
                },
                series: [{
                    type: 'heatmap',
                    data: heatmapData,
                    emphasis: {
                        itemStyle: {
                            shadowBlur: 10,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }]
            });
        } catch (error) {
            console.error('Error updating heatmap:', error);
        }
    }

    // Load the overview tab by default on page load
    showTab('overview');
});
