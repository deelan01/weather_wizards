document.addEventListener('DOMContentLoaded', () => {
    const tabs = document.querySelectorAll('.tab');  // All tab elements
    const tabContents = document.querySelectorAll('.tab-content');  // All tab contents
    const yearSlider = document.getElementById('yearSlider');  // Year slider element
    const yearLabel = document.getElementById('yearLabel');  // Label to display the year
    const hurricaneGraph = document.getElementById('hurricaneGraph');  // Graph container
    let historicalData = [];  // Store historical storm data

    // Add event listeners to tabs for switching content
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const tabName = tab.getAttribute('data-tab').trim();
            console.log(`Tab clicked: ${tabName}`);
            switchTab(tabName);  // Switch to the selected tab
        });
    });

    // Function to switch tabs and display the correct content
    function switchTab(tabName) {
        tabContents.forEach(content => {
            content.style.display = content.id === tabName ? 'block' : 'none';  // Show only the active tab
        });

        // If the 'historical' tab is selected, update the graph
        if (tabName === 'historical') {
            updateGraph(yearSlider.value);  // Plot the graph for the selected year
        }
    }

    // Fetch and set the min and max years for the slider
    async function fetchYearRange() {
        try {
            const response = await fetch('/api/years-range');  // Call the API for year range
            if (!response.ok) throw new Error('Failed to fetch year range');
            const { min_year, max_year } = await response.json();

            // Set slider attributes dynamically based on the API response
            yearSlider.min = min_year;
            yearSlider.max = max_year;
            yearSlider.value = min_year;
            yearLabel.textContent = `Year: ${min_year}`;

            // Fetch the historical data and plot the initial graph
            await fetchDataAndPlot(min_year);
        } catch (error) {
            console.error('Error fetching year range:', error);
        }
    }

    // Fetch historical storm data and store it
    async function fetchDataAndPlot(initialYear) {
        try {
            const response = await fetch('/api/historical');  // Call the API for historical data
            if (!response.ok) throw new Error('Failed to fetch historical data');
            historicalData = await response.json();  // Store the data
            console.log('Historical Data:', historicalData);
            updateGraph(initialYear);  // Plot the graph for the initial year
        } catch (error) {
            console.error('Error fetching historical data:', error);
        }
    }

    // Update the graph based on the selected year
    function updateGraph(year) {
        const dataForYear = historicalData.find(d => d.year == year);  // Find data for the selected year

        if (!dataForYear) {
            console.warn(`No data available for year: ${year}`);
            return;
        }

        // Initialize ECharts and configure the graph
        const chart = echarts.init(hurricaneGraph);
        const option = {
            title: {
                text: `Storms and Hurricanes in ${year}`,
                left: 'center'
            },
            tooltip: {
                trigger: 'axis'
            },
            xAxis: {
                type: 'category',
                data: ['Storms', 'Hurricanes']
            },
            yAxis: {
                type: 'value'
            },
            series: [{
                name: 'Count',
                type: 'bar',
                data: [dataForYear.storms, dataForYear.hurricanes],
                barWidth: '50%',
                itemStyle: {
                    color: '#0077B6'
                }
            }]
        };
        chart.setOption(option);  // Render the chart with the given options
    }

    // Event listener for the year slider to update the graph dynamically
    yearSlider.addEventListener('input', () => {
        const selectedYear = yearSlider.value;
        yearLabel.textContent = `Year: ${selectedYear}`;
        updateGraph(selectedYear);  // Update the graph with the selected year
    });

    // Initialize the application by fetching the year range
    fetchYearRange();
    switchTab('overview');  // Show the overview tab by default
});
