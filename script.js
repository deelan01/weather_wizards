document.addEventListener('DOMContentLoaded', () => {
    console.log('Dashboard initialized!');

<<<<<<< HEAD
    const tabs = document.querySelectorAll('.tab');
    const tabContents = document.querySelectorAll('.tab-content');

    // Show the default tab (Overview) on load
    showTab('overview');

    // Add event listeners to all tabs
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const tabName = tab.getAttribute('data-tab').trim();
            showTab(tabName);

            if (tabName === 'historical') initializeHistoricalVisualizations();
            if (tabName === 'damage') initializeDamageCharts();
        });
    });

    function showTab(tabName) {
        tabContents.forEach(content => {
            content.style.display = content.id === tabName ? 'block' : 'none';
        });
    }

    // Initialize Hurricane Damage Charts
   
        function initializeDamageCharts() {
            if (document.getElementById('damageLineChart')) {
                const damageLineChart = echarts.init(document.getElementById('damageLineChart'));
                const damageBarChart = echarts.init(document.getElementById('damageBarChart'));
                const choroplethChart = echarts.init(document.getElementById('damageChoroplethChart'));
                const pieChart = echarts.init(document.getElementById('damagePieChart'));
        
                // Set options for each chart (no changes in the options logic)
                damageLineChart.setOption({ 
                    title: { text: 'Damage Cost Over the Years', left: 'center' },
                    xAxis: { type: 'category', data: [2000, 2005, 2010, 2015, 2020] },
                    yAxis: { type: 'value', name: 'Damage (in Billion USD)' },
                    series: [{ data: [10, 25, 15, 30, 45], type: 'line', smooth: true }],
                });
        
                damageBarChart.setOption({
                    title: {
                        text: 'Damage Types Comparison',
                        left: 'center',
                        top: 10,  // Add some margin space above the title
                    },
                    tooltip: {
                        trigger: 'axis',
                        axisPointer: { type: 'shadow' },
                    },
                    legend: {
                        data: ['Property', 'Infrastructure'],
                        top: 50,  // Add space below the title to avoid overlap
                        left: 'center',
                    },
                    grid: {
                        top: 100,  // Adjust grid position to avoid overlap with legend
                        left: '10%',
                        right: '10%',
                        bottom: '10%',
                    },
                    xAxis: {
                        type: 'category',
                        data: [2000, 2005, 2010, 2015, 2020],
                    },
                    yAxis: {
                        type: 'value',
                        name: 'Damage (in Billion USD)',
                    },
                    series: [
                        {
                            name: 'Property',
                            type: 'bar',
                            stack: 'Total',
                            data: [5, 10, 8, 12, 18],
                        },
                        {
                            name: 'Infrastructure',
                            type: 'bar',
                            stack: 'Total',
                            data: [5, 15, 7, 18, 27],
                        },
                    ],
                });
                
        
                function initializeChoroplethChart() {
                    try {
                        const chart = echarts.init(document.getElementById('damageChoroplethChart'));
                
                        // Ensure the map is registered properly (only if using GeoJSON manually)
                        echarts.registerMap('USA', {});
                
                        chart.setOption({
                            title: { 
                                text: 'Regional Damage Visualization', 
                                left: 'center',
                                top: 10
                            },
                            tooltip: { 
                                trigger: 'item', 
                                formatter: '{b}<br/>Total Damage: {c} Billion USD' 
                            },
                            visualMap: { 
                                min: 0, 
                                max: 50, 
                                left: 'center', 
                                bottom: '10%', 
                                text: ['High', 'Low'], 
                                calculable: true 
                            },
                            series: [{
                                type: 'map',
                                map: 'USA',  // Make sure 'USA' map is registered/loaded correctly
                                label: {
                                    show: true,
                                    formatter: '{b}', // Show state names on the map
                                },
                                data: [
                                    { name: 'Florida', value: 20 },
                                    { name: 'Texas', value: 15 },
                                    { name: 'Louisiana', value: 25 },
                                ],
                                emphasis: {
                                    label: { show: true },
                                    itemStyle: { 
                                        areaColor: '#f4a460' 
                                    },
                                },
                            }]
                        });
                
                    } catch (error) {
                        console.error('Error initializing Choropleth Chart:', error);
                    }
                }
                
        
                pieChart.setOption({ 
                    title: { text: 'Percentage Breakdown of Damage Types', left: 'center' },
                    series: [{
                        type: 'pie',
                        radius: '50%',
                        data: [
                            { value: 60, name: 'Property Damage' },
                            { value: 40, name: 'Infrastructure Damage' },
                        ],
                    }],
                });
            }
        }
        

    // Initialize Historical Storm Events Charts
    function initializeHistoricalVisualizations() {
        initializeLineChart();
        initializeBarChart();
        initializeRadarChart();
        initializePieChart();
        initializeHeatmap();
    }

    function initializeLineChart() {
        const chart = echarts.init(document.getElementById('stormLineChart'));
        chart.setOption({
            title: { text: 'Number of Storms by Year', left: 'center' },
            xAxis: { type: 'category', data: [2000, 2001, 2002, 2003, 2004] },
            yAxis: { type: 'value', name: 'Number of Storms' },
            series: [{ type: 'line', data: [10, 15, 8, 12, 20], smooth: true, areaStyle: {} }],
        });
    }

    function initializeBarChart() {
        const chart = echarts.init(document.getElementById('stormBarChart'));
        chart.setOption({
            title: { text: 'Storms by Month (Seasonality)', left: 'center' },
            xAxis: { type: 'category', data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] },
            yAxis: { type: 'value', name: 'Number of Storms' },
            series: [{ type: 'bar', data: [1, 0, 0, 2, 5, 10, 15, 20, 25, 12, 8, 3] }],
        });
    }

    function initializeRadarChart() {
        const chart = echarts.init(document.getElementById('stormRadarChart'));
        chart.setOption({
            title: { text: 'Storm Metrics Comparison', left: 'center' },
            radar: {
                indicator: [
                    { name: 'Wind Speed', max: 200 },
                    { name: 'Pressure', max: 1000 },
                    { name: 'Duration (hrs)', max: 48 },
                ],
            },
            series: [{
                type: 'radar',
                data: [
                    { value: [180, 900, 24], name: 'Storm A' },
                    { value: [160, 950, 36], name: 'Storm B' },
                ],
            }],
        });
    }

    function initializePieChart() {
        const chart = echarts.init(document.getElementById('stormPieChart'));
        chart.setOption({
            title: { text: 'Storm Type Distribution', left: 'center' },
            series: [{
                type: 'pie',
                radius: '50%',
                data: [
                    { value: 30, name: 'Tropical Storm' },
                    { value: 50, name: 'Hurricane' },
                    { value: 20, name: 'Depression' },
                ],
            }],
        });
    }

    async function initializeHeatmap() {
        const chart = echarts.init(document.getElementById('stormHeatmap'));
        chart.setOption({
            title: { text: 'Storm Intensity by Location', left: 'center' },
            series: [{
                type: 'heatmap',
                data: [[25.76, -80.19, 120], [29.95, -90.07, 150], [35.22, -80.84, 80]],
            }],
        });
    }

    // Load Overview tab by default
=======
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
>>>>>>> main
    showTab('overview');
    initializeTab('overview');
});



