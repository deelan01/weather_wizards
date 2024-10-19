document.addEventListener('DOMContentLoaded', () => {
    console.log('Dashboard initialized!');

    // Function to fetch data from the backend
    async function fetchData(endpoint) {
        try {
            const response = await fetch(endpoint);
            if (!response.ok) {
                throw new Error(`Error fetching data from ${endpoint}: ${response.statusText}`);
            }
            return await response.json();
        } catch (error) {
            console.error('Error fetching data:', error);
            return null;
        }
    }

    // Function to initialize the chart
    function initializeChart(chartElementId, options) {
        const chart = echarts.init(document.getElementById(chartElementId));
        chart.setOption(options);
    }

    // Function to create options for casualties chart (Bar Chart)
    async function createCasualtiesChart() {
        const casualtiesData = await fetchData('/api/casualties');
        if (!casualtiesData) return;

        const events = casualtiesData.map(d => d.event);
        const casualties = casualtiesData.map(d => d.count);

        return {
            title: { text: 'Casualties by Event', left: 'center' },
            xAxis: { type: 'category', data: events },
            yAxis: { type: 'value', name: 'Casualties' },
            series: [{ type: 'bar', data: casualties }]
        };
    }

    // Function to create options for event type chart (Pie Chart)
    async function createEventTypeChart() {
        const eventData = await fetchData('/api/event-types');
        if (!eventData) return;

        const types = eventData.map(d => d.type);
        const counts = eventData.map(d => d.count);

        return {
            title: { text: 'Weather Event Types', left: 'center' },
            series: [{
                type: 'pie',
                radius: '50%',
                data: counts.map((count, index) => ({ value: count, name: types[index] })),
                emphasis: {
                    itemStyle: {
                        shadowBlur: 10,
                        shadowOffsetX: 0,
                        shadowColor: 'rgba(0, 0, 0, 0.5)'
                    }
                }
            }]
        };
    }

    // Function to initialize specific tabs
    async function initializeTab(tabName) {
        let chartOptions;
        switch (tabName) {
            case 'overview':
                chartOptions = await createOverviewChart();
                initializeChart('overviewChart', chartOptions);
                break;
            case 'historical':
                chartOptions = await createHistoricalChart();
                initializeChart('historicalChart', chartOptions);
                break;
            case 'damage':
                chartOptions = await createDamageChart();
                initializeChart('damageChart', chartOptions);
                break;
            case 'casualties':
                chartOptions = await createCasualtiesChart();
                initializeChart('casualtiesChart', chartOptions);
                break;
            case 'event-type':
                chartOptions = await createEventTypeChart();
                initializeChart('eventTypeChart', chartOptions);
                break;
            default:
                console.error(`No chart found for tab: ${tabName}`);
        }
    }

    // Function to show the selected tab
    function showTab(tabName) {
        const tabContents = document.querySelectorAll('.tab-content');
        tabContents.forEach(content => {
            content.style.display = content.id === tabName ? 'block' : 'none';
        });
    }

    // Tab click event handlers
    const tabs = document.querySelectorAll('.tab');
    tabs.forEach(tab => {
        tab.addEventListener('click', async () => {
            const tabName = tab.getAttribute('data-tab').trim();
            showTab(tabName); // Show selected tab
            await initializeTab(tabName); // Initialize the selected tab
        });
    });

    // Load the overview tab by default on page load
    showTab('overview');
    initializeTab('overview');
});



