document.addEventListener('DOMContentLoaded', () => {
    const tabs = document.querySelectorAll('.tab'); // All tab elements
    const tabContents = document.querySelectorAll('.tab-content'); // All tab contents

    // Helper function to fetch data from an endpoint
    async function fetchData(endpoint) {
        try {
            const response = await fetch(endpoint);
            if (!response.ok) throw new Error(`Failed to fetch data: ${response.statusText}`);
            return await response.json();
        } catch (error) {
            console.error(`Error fetching data from ${endpoint}:`, error);
            return null;
        }
    }

    // Function to switch tabs and display the correct content
    function switchTab(tabName) {
        tabContents.forEach(content => {
            content.style.display = content.id === tabName ? 'block' : 'none';
        });
    }

    // Event listeners for tabs
    tabs.forEach(tab => {
        tab.addEventListener('click', async () => {
            const tabName = tab.getAttribute('data-tab').trim();
            console.log(`Tab clicked: ${tabName}`);
            switchTab(tabName);

            // Render the chart when its tab is clicked
            if (tabName === 'historical') await renderYearsChart();
            else if (tabName === 'damage') await renderDamageChart();
            else if (tabName === 'casualties') await renderCasualtiesChart();
            else if (tabName === 'event-type') await renderEventTypesChart();
        });
    });

    // Chart rendering functions
    async function renderYearsChart() {
        const data = await fetchData('http://localhost:3000/api/years-incidents');
        const labels = data.map(item => item.year);
        const values = data.map(item => item.number_of_hurricanes);

        new Chart(document.getElementById('yearsChart'), {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Hurricanes per Year',
                    data: values,
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1
                }]
            },
            options: { responsive: true }
        });
    }

    async function renderDamageChart() {
        const data = await fetchData('http://localhost:3000/api/hurricane_damage');
        const labels = data.map(item => item.weather_event_name);
        const values = data.map(item => parseFloat(item.damage_cost.replace(/[^0-9.-]+/g, "")));

        new Chart(document.getElementById('damageChart'), {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{ data: values }]
            },
            options: { responsive: true }
        });
    }

    async function renderCasualtiesChart() {
        const data = await fetchData('http://localhost:3000/api/casualties');
        const labels = data.map(item => item.year);
        const values = data.map(item => item.number_of_casualties);

        new Chart(document.getElementById('casualtiesChart'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Hurricane Casualties',
                    data: values,
                    backgroundColor: 'rgba(255, 99, 132, 0.2)',
                    borderColor: 'rgba(255, 99, 132, 1)',
                    borderWidth: 1
                }]
            },
            options: { responsive: true }
        });
    }

    async function renderEventTypesChart() {
        const data = await fetchData('http://localhost:3000/api/event-types');
        const labels = data.map(item => item.weather_event_type);
        const values = data.map(item => item.weather_event_type_count);

        new Chart(document.getElementById('eventTypeChart'), {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{ data: values }]
            },
            options: { responsive: true }
        });
    }

    // Render the default tab on page load
    renderYearsChart(); // Load the 'historical' chart by default
});
